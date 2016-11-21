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
@isTest(seeAllData = false)
private class Test_TransactionsController {
/**
 *  Description     :   Test class for Transaction Controller
 *
 *  Created By      :   Bhavi Sharma
 *
 *  Created Date    :   12/10/2014
 *
 *  Revision Logs   :   V_1.0 - Created
 * 						V_1.1 - Modified - 12/1/2015- By Mahendra Swarnkar - Removed the Portfolio object field's Credit_Limit__c field reference, as it will no longer in use.
 *
 *  Coverage        :   94%
 *
 **/
    static testMethod void myUnitTest() {
    	
    	//User record
        User currentUser;
        
        //Update the User Finance Code if not alreayd populated
        System.runAs(new User(Id = UserInfo.getUserId())) {
        	
        	//Update the Employee Id
        	currentUser = new User(Id = UserInfo.getUserId(), Finance_Code__c = '50011');
        	update currentUser;
        }
        
         //insert Credit Card Settings record 
        Credit_Card_Settings__c configCCDefaultSetting = TestUtilities.CreateCreditCardSettings();
        insert configCCDefaultSetting;
        
        //Set helper class variable
        CreditCardHelper.configDefaults = configCCDefaultSetting;
        CreditCardConstants.CONFIG_DEFAULT = configCCDefaultSetting;
        
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
        													Over_aging_Warning_days__c = 35, 
        													Over_aging_Maximum_days__c = 45, 
        													Over_balance_Warning_threshold_1__c = .75, 
        													Over_balance_Warning_threshold_2__c = .90, 
        													Over_balance_Countdown_days__c = 3,
        													Provider_Profile__c = pP.Id,
	                                                		Credit_Limit__c = 100);
        insert abcProfile;
        
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
        
        //Update configCCDefaultSetting field
        configCCDefaultSetting.Staff_Portfolio_Record_Type__c = rdTypesPortfolio[0].id;
        configCCDefaultSetting.Staff_Card_Record_Type__c = rdTypesCreditCard[0].id;
        configCCDefaultSetting.xmlns_soapenv__c = 'http://schemas.xmlsoap.org/soap/envelope/';
        configCCDefaultSetting.xmlns_main__c = 'http://fleetCredit.comdata.com/maintenance/';
        update configCCDefaultSetting;
        
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
	                                                RecordTypeId = configCCDefaultSetting.Staff_Portfolio_Record_Type__c, 
	                                                Status__c = CreditCardConstants.PORTFOLIO_STATUS_ACTIVATED);
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
        
        
        //Create a new Credit Card record
        Credit_Card__c creditCard2 = new Credit_Card__c(Card_Requested_By__c = contact.Id, 
        													Card_Vendor__c = configCCDefaultSetting.Card_Vendor__c,
                                                            Payment_Account__c = portfolio.Id, 
                                                            RecordTypeId = configCCDefaultSetting.Staff_Card_Record_Type__c, 
                                                            Status__c = CreditCardConstants.CC_STATUS_ACTIVE,
                                                            Card_Set_up_Status__c = CreditCardConstants.CC_SETUP_STATUS_SUCCESS);
        insert creditCard2;
        
        //Initialize method number for addCreditCard
        CreditCardServiceMockClass.methodNumber = 8;
        CreditCardServiceMockClass mock = new CreditCardServiceMockClass();
        HTTPService.response = mock.respond(new HttpRequest());
        
        //Test start here
        Test.startTest();
        
    	//Constructor Initilization
        TransactionsController portfolioController = new TransactionsController(new ApexPages.StandardController(portfolio));
        portfolioController.noOfDays = '9';
        portfolioController.refreshTransactions();
        
        //Constructor Initilization
        TransactionsController creditCardController = new TransactionsController(new ApexPages.StandardController(creditCard));
        creditCardController.noOfDays = '9';
        creditCardController.refreshTransactions();
        
        //Stop Test here
        Test.stopTest();
        
        //Check for the transaction list size
        System.assertEquals(1000, portfolioController.transactionRecords.size());
        System.assertEquals(500, creditCardController.transactionRecords.size());
    }
}