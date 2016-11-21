/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest
private class Test_Sched_PopulateFinalWarningBalance {
/**
 *  Description     :   Test class for Sched_PopulateFinalWarningBalance
 *
 *  Created By      :   Mahendra Swarnkar
 *
 *  Created Date    :   11/6/2015
 *
 *  Revision Logs   :   V_1.0 - Created CR-20151020-9342
 *
 *  Coverage        :   100%
 *
 **/

//instance of Mock service class 
    static CreditCardServiceMockClass mockController = new CreditCardServiceMockClass();
    
    //HttpRequest instance
    static Httprequest req = new Httprequest();
    
    //Setup test data first. This will be available in the entire class
    @testSetup static void setup() {
    	
    	//Quering portfolio record types details
        List<RecordType> rdTypesPortfolio = [select Id from RecordType 
                                            where DeveloperName = 'Employee_Payment_Account' AND
                                            SobjectType = 'Portfolio__c' AND IsActive = true];
        
        //Quering credit card record types details
        List<RecordType> rdTypesCreditCard = [select Id from RecordType 
                                                WHERE DeveloperName = 'ABC_Staff_Credit_Card' AND
                                                SobjectType = 'Credit_Card__c' AND IsActive = true];
        
        //Assert for the results
        System.assert(rdTypesPortfolio != null); 
        System.assert(rdTypesCreditCard != null);
        
        
        //insert Credit Card Settings record
        Credit_Card_Settings__c configCCDefaultSetting = TestUtilities.CreateCreditCardSettings();
        configCCDefaultSetting.Staff_Portfolio_Record_Type__c = rdTypesPortfolio[0].id;
        configCCDefaultSetting.Staff_Card_Record_Type__c = rdTypesCreditCard[0].id;
        insert configCCDefaultSetting;
        
        //User record
        User currentUser;
        
        //Update the User Finance Code if not alreayd populated
        System.runAs(new User(Id = UserInfo.getUserId())) {
            
            //Update the Employee Id
            currentUser = new User(Id = UserInfo.getUserId(), Finance_Code__c = '50011');
            update currentUser;
        }
        
        //insert Contact record
        Contact contact = TestUtilities.CreateNewContact(false);
        contact.Birthdate = System.today().addYears(-28);
        contact.Employee_ID__c = '50011';
        contact.Employee_User_Record__c = UserInfo.getUserId();
        insert contact;
        
        //Create a Provider Profile instance
        Provider_Profile__c pP = new Provider_Profile__c(Provider_Profile_ID__c = '2');
        insert pP;
        
        //Create a test ABC Profile record
        ABC_Profile__c abcProfile = new ABC_Profile__c(Name = 'Test', 
                                                            Over_aging_Warning_days__c = 20, 
                                                            Over_aging_Warning_days_2__c = 30, 
                                                            Over_aging_Warning_days_3__c = 40, 
                                                            Over_aging_Maximum_days__c = 45, 
                                                            Over_balance_Warning_threshold_1__c = .60, 
                                                            Over_balance_Warning_threshold_2__c = .80,
                                                            Over_balance_Warning_threshold_3__c = .90,
                                                            Over_balance_Countdown_days__c = 3,
                                                            Provider_Profile__c = pP.Id,
                                                      		Credit_Limit__c = 100);
        insert abcProfile;
        
        //Portfolio Records
        Portfolio__c portfolio = new Portfolio__c(Billing_Address_Attention_To__c = 'Test', 
                                                    Billing_Address_Line_1__c = 'Test', 
                                                    Billing_Address_Line_2__c = 'Test', 
                                                    Billing_Address_City__c = 'San Francisco', 
                                                    Billing_Address_State__c = 'CA', 
                                                    Billing_Address_PostalCode__c = '98565', 
                                                    First_Name_On_Card__c = 'Bhavi', 
                                                    Last_Name_On_Card__c = 'Sharma', 
                                                    Card_Holder__c = contact.Id,
                                                    Advisory_Profile__c = abcProfile.Id,
                                                    Oldest_transaction__c = Date.today(), 
                                                    RecordTypeId = configCCDefaultSetting.Staff_Portfolio_Record_Type__c, 
                                                    Status__c = CreditCardConstants.PORTFOLIO_STATUS_ACTIVATED,
                                                    Balance__c = 90);
        insert portfolio;
        
        //At this stage workflow will be get executed and Owner Finance code will be get populated
        //Assert for the results
        portfolio = [Select Id, Portfolio_Owner_Finance_Code__c from Portfolio__c where Id =: portfolio.Id];
        System.assertEquals(currentUser.Finance_Code__c, portfolio.Portfolio_Owner_Finance_Code__c);
        
        //Create a new Credit Card record
        Credit_Card__c creditCard = new Credit_Card__c(Card_Requested_By__c = contact.Id, 
                                                            Card_Vendor__c = configCCDefaultSetting.Card_Vendor__c,
                                                            Payment_Account__c = portfolio.Id, 
                                                            RecordTypeId = configCCDefaultSetting.Staff_Card_Record_Type__c, 
                                                            Status__c = CreditCardConstants.CC_STATUS_ACTIVE,
                                                            Card_Set_up_Status__c = CreditCardConstants.CC_SETUP_STATUS_SUCCESS);
        insert creditCard;
    }
    
    //Method to test functionality
    static testMethod void testPopulateFinalWarningBalanceFirst () {
        
        //Bypass all the triggers
        Util.BypassAllTriggers = true;
        Util.IsTest(true);
        
        //Fetch teh Portfolio record
        Portfolio__c portfolio = [Select Id, Balance__c from Portfolio__c where Card_Holder__r.Employee_User_Record__c =: UserInfo.getUserId()];
        
        //Make portfolio to cross over balance limit
        portfolio.Balance__c = 120;
        update portfolio;
        
        //Enable all the triggers
        Util.BypassAllTriggers = false;
        
        //Start testing from here
        Test.startTest();
        
        //Initilize scheduler
        Sched_PopulateFinalWarningBalance sche = new Sched_PopulateFinalWarningBalance();
        String sch = '0 0 0 * * ?';
        system.schedule('Test', sch, sche);
        
        //Test stops hhere
        Test.stopTest();
        
        //Check if final warning balance date and Last_Over_Balance_Warning_Sent_On date will be populated
        portfolio = [Select Id, Final_warning_Balance__c, Over_balance_Countdown_days__c, Last_Over_Balance_Warning_Sent_On__c, Status__c FROM Portfolio__c WHERE ID =: portfolio.Id];
        
        //Asserts for result
        system.assertEquals(Date.today().addDays(3), portfolio.Final_warning_Balance__c);
        system.assertEquals(3, portfolio.Over_balance_Countdown_days__c);
        system.assertEquals(Date.today(), Date.newInstance(portfolio.Last_Over_Balance_Warning_Sent_On__c.year(), portfolio.Last_Over_Balance_Warning_Sent_On__c.month(), portfolio.Last_Over_Balance_Warning_Sent_On__c.day()));
        system.assertEquals(CreditCardConstants.PORTFOLIO_STATUS_ACTIVATED, portfolio.Status__c);
    }
    
    //Method to test functionality
    static testMethod void testPopulateFinalWarningBalanceFinal () {
        
        //Bypass all the triggers
        Util.BypassAllTriggers = true;
        Util.IsTest(true);
        
        //Fetch teh Portfolio record
        Portfolio__c portfolio = [Select Id, Balance__c, Final_warning_Balance__c from Portfolio__c where Card_Holder__r.Employee_User_Record__c =: UserInfo.getUserId()];
        
        //Make portfolio to cross over balance limit with final warning
        portfolio.Balance__c = 120;
        portfolio.Final_warning_Balance__c = Date.today();
        
        //Update the portfolio record
        update portfolio;
        
        //Enable all the triggers here
        Util.BypassAllTriggers = false;
        
        //Start testing from here
        Test.startTest();
        
        //Initilize scheduler
        Sched_PopulateFinalWarningBalance sche = new Sched_PopulateFinalWarningBalance();
        String sch1 = '0 0 0 * * ?';
        system.schedule('Test1', sch1, sche);
        
        //Test stops here
        Test.stopTest();
        
        //Check if Portfolio status to be deactivated
        portfolio = [Select Id, Status__c, Deactivation_Reason__c FROM Portfolio__c WHERE ID =: portfolio.Id];
        
        //Asserts for result
        system.assertEquals(CreditCardConstants.PORTFOLIO_STATUS_DEACTIVATED, portfolio.Status__c);
    	system.assertEquals(CreditCardConstants.PORTFOLIO_DEACTIVATION_REASON_OVER_CREDIT_BALANNCE_LIMIT, portfolio.Deactivation_Reason__c);
    }

}