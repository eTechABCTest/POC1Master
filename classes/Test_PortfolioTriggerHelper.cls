/**
 *  Description     :   Test class for PortfolioTriggerHelper
 *
 *  Created By      :   
 *
 *  Created Date    :   
 *
 *  Revision Logs   :   V_1.0 - Created
 *                      V_1.1 - Modified - 12/1/2015- By Mahendra Swarnkar - Removed the Portfolio object field's Credit_Limit__c field reference, as it will no longer in use. 						 
 *						V_1.2 - Modified By - Abhinav Sharma - CR-20150202-8644 - 07/13/2016 - A code refactor CR						
 *
 *  Coverage        :	V_1.1 - PortfolioTriggerHelper - 94%
 * 						V_1.2 - PortfolioTriggerHelper - 95%   
 *
 **/
@isTest (seeAllData = false)
public class Test_PortfolioTriggerHelper {

    //instance of Mock service class 
    static CreditCardServiceMockClass mockController = new CreditCardServiceMockClass();

    //HttpRequest instance
    static Httprequest req = new Httprequest();
    
    //Modified By - Abhinav Sharma - CR-20150202-8644 - 07/13/2016 - A code refactor CR
    //Setup test data first. This will be available in the entire class
	@testSetup static void setup() {
        
        //Bypass Dupeblocker and triggers
        Util.IsTest(true);
        Util.byPassAllTriggers = true;
        Util.IsTesting = true;
	
		//insert Credit Card Settings record
        Credit_Card_Settings__c configCCDefaultSetting = TestUtilities.CreateCreditCardSettings();
        insert configCCDefaultSetting;
    	
        //Set helper class variable
        CreditCardHelper.configDefaults = configCCDefaultSetting;
        CreditCardConstants.CONFIG_DEFAULT = configCCDefaultSetting;
    }
    
    //Modified By - Abhinav Sharma - CR-20150202-8644 - 07/13/2016 - A code refactor CR
    /** Description : Method to test Functionality to populate Finace code from contact((Card holder))
    **/
    static testmethod void testUpdateFieldDefaults() {
    	
        //Bypass Dupeblocker and triggers
        Util.IsTest(true);
        Util.byPassAllTriggers = true;
        Util.IsTesting = true;
        
       	//Creating dummy test data
		string testFinanceCode = '12345';
        
        //List of users
        List<User> users = new List<User>();
        
        //Create the User record
        User testU1 = TestUtilities.CreateNewUser(false);
        testU1.Finance_Code__c = testFinanceCode;
        
        //Create a new user
        User testU2 = TestUtilities.CreateNewUser(false);
        testU2.Finance_Code__c = '23456';
        
        //Populating list with the instances
        users.add(testU1);
        users.add(testU2);
        
        //Insert users
        insert users;
        
        //Asserting for the results
        System.assert(users != null);
        System.assertEquals(2, users.size());
        
        //Credit Card Settings
        Credit_Card_Settings__c ccSettings = CreditCardConstants.CONFIG_DEFAULT;
        
        //List of users
        List<Contact> contacts = new List<Contact>();
        
        //Create the Contact records
        Contact testC1 = new Contact();
        testC1.FirstName = 'Mickey';
        testC1.LastName = 'Mouse';
        testC1.Employee_User_Record__c = testU1.Id;
        
        //Contact
        Contact testC2 = new Contact();
        testC2.FirstName = 'Donald';
        testC2.LastName = 'Duck';
        testC2.Employee_User_Record__c = testU2.Id;
        
        //Adding instance into the collection
        contacts.add(testC1);
        contacts.add(testC2);
        insert contacts;
        
        //Asserting for the results
        System.assert(contacts != null);
        System.assertEquals(2, contacts.size());
        
        //list of portfolios
        List<Portfolio__c> portfolios = new List<Portfolio__c>();
        
        //Create two Portfolio records (positive and negative test)
        Portfolio__c testP1 = new Portfolio__c();
        testP1.Portfolio_Owner_Finance_Code__c = testFinanceCode; 
        testP1.Card_Holder__c = testC1.Id;
        testP1.Status__c = 'Test';
        
        //Portfolio
        Portfolio__c testP2 = new Portfolio__c();
        testP2.Card_Holder__c = testC2.Id;
        testP2.Status__c = 'Weird';
        
        //Populating collection with the instances
        portfolios.add(testP1);
        portfolios.add(testP2);
        
		//Tset start here
        Test.startTest();
        
        //Enabling triggers
        Util.byPassAllTriggers = false;
        
        //insert portfolios
        insert portfolios;
        
        //Test stops here
		Test.stopTest();
        
        //Verify testP1 values were populated correctly
        Contact testC1Result = [SELECT Id FROM Contact WHERE Employee_Finance_Code__c = :testFinanceCode];
        System.assert(testC1Result != null);
        
        //Asserting for the results
        portfolios = [SELECT Id, Portfolio_Owner_Finance_Code__c,
                                 		Card_Holder__r.Employee_Finance_Code__c FROM Portfolio__c
                                    ORDER BY Status__c ASC];
        
        //Asserting for the results
        System.assert(portfolios != null);
        System.assertEquals(2, portfolios.size());
        System.assertEquals(portfolios[0].Card_Holder__r.Employee_Finance_Code__c , portfolios[0].Portfolio_Owner_Finance_Code__c);
        System.assertEquals(portfolios[1].Card_Holder__r.Employee_Finance_Code__c , portfolios[1].Portfolio_Owner_Finance_Code__c);
    }
    
    //Modified By - Abhinav Sharma - CR-20150202-8644 - 07/13/2016 - A code refactor CR
    /** Description : Method to test out the functionality to Deactivate card in comdata
    **/
    static testmethod void testActivateCardInComdata() {
        
        //Bypass Dupeblocker and triggers
        Util.IsTest(true);
        Util.byPassAllTriggers = true;
        Util.IsTesting = true;
        
        //User record
        User currentUser;
        
        //Update the User Finance Code if not alreayd populated
        System.runAs(new User(Id = UserInfo.getUserId())) {
        	
        	//Update the Employee Id
        	currentUser = new User(Id = UserInfo.getUserId(), Finance_Code__c = '50011');
        	update currentUser;
        }
        
        //insert Credit Card Settings record 
        Credit_Card_Settings__c configCCDefaultSetting = CreditCardConstants.CONFIG_DEFAULT;
        System.assert(configCCDefaultSetting != null);
        
        //insert Contact record
        Contact contact = TestUtilities.CreateNewContact(false);
        contact.Birthdate = System.today().addYears(-28);
        contact.Employee_ID__c = '50011';
        contact.Employee_User_Record__c = UserInfo.getUserId();
        insert contact;
		System.assert(contact != null);		
        
        //Create a Provider Profile instance
        Provider_Profile__c pP = new Provider_Profile__c(Provider_Profile_ID__c = '2');
        insert pP;
        System.assert(pP != null);	
        
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
        System.assert(abcProfile != null);
        
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
	                                                Status__c = CreditCardConstants.PORTFOLIO_STATUS_DEACTIVATED,
	                                                Deactivation_Reason__c = CreditCardConstants.PORTFOLIO_DEACTIVATION_REASON_OVER_CREDIT_BALANNCE_LIMIT,
	                                                Final_warning_Balance__c = Date.today() - 1,
	                                                Balance__c = 110,
                                                 	Billing_Address_Updated__c = false);
        //Enabling triggers
        Util.byPassAllTriggers = false;
        
        //insert portfolio
        insert portfolio;
        
        //Assert for results
        System.assert(portfolio != null);	
        
        //At this stage workflow will be get executed and Owner Finance code will be get populated
        //Assert for the results
        portfolio = [SELECT Id, Portfolio_Owner_Finance_Code__c, Billing_Address_Updated__c FROM Portfolio__c 
                     	WHERE Id =: portfolio.Id];
        
        //Asserting for the results
        System.assertEquals(currentUser.Finance_Code__c, portfolio.Portfolio_Owner_Finance_Code__c);
        
        //Create a new Credit Card record
        Credit_Card__c creditCard = new Credit_Card__c(Card_Requested_By__c = contact.Id, 
        													Card_Vendor__c = configCCDefaultSetting.Card_Vendor__c,
                                                            Payment_Account__c = portfolio.Id, 
                                                            RecordTypeId = configCCDefaultSetting.Staff_Card_Record_Type__c, 
                                                            Status__c = CreditCardConstants.CC_STATUS_DEACTIVATED,
                                                            Card_Deactivation_Status__c = CreditCardConstants.CC_DEACTIVATION_STATUS_DEACTIVATED,
                                                            Card_Deactivation_Reason__c = Label.DEACTIVATION_OVER_CREDIT_LIMIT);
        insert creditCard;

		//Assert of the results
        System.assert(creditCard != null);	
        
        //Initialize method number for addCreditCard
        CreditCardServiceMockClass.methodNumber = 3;
        CreditCardServiceMockClass mock = new CreditCardServiceMockClass();
        
        //Making a callout to comdata
        try {
        	HTTPService.response = mock.respond(new HttpRequest());    
        } Catch(exception e){}
        
        //Test start here
        Test.startTest();
        
        //Now Update the Utilized Balance to under 100%, that will execute the workflow and Batch will also be get executed
        //Updating the Credit Card Balance will Rollup the same infomration on Portfolio record also
        portfolio.Balance__c = 10;
        portfolio.Billing_Address_Updated__c = true;
       	update portfolio;
       	
       	//Check for the Final Balance Warning on Portfolio record
        //It Should be Today + abcProfile.Over_balance_Countdown_days__c
        portfolio = [SELECT Id, Status__c, Deactivation_Reason__c, Final_warning_Balance__c 
                     	FROM Portfolio__c 
                     	WHERE Id =: portfolio.Id];
        
        //After countdown days, 
        //Field Updates will mark the Portfolio Status = Deactivated and Reason = Over Credit Limit
        //Trigger will then call the batch Process
        //Batch will fetch the Active Credit Card related to this Portfolio and will mark them deacitvate
        //Deactivation reason will be set to "Over Credit Limit"
       	portfolio.Status__c = CreditCardConstants.PORTFOLIO_STATUS_ACTIVATED;
       	update portfolio;
       	
        //Test stopss here
        Test.stopTest();
        
        //Check for the Credit Card Status 
        creditCard = [Select Status__c, Card_Set_up_Status__c, Card_Deactivation_Status__c, 
                      	Card_Deactivation_Reason__c from Credit_Card__c where Id =: creditCard.Id];
        
        //Assert for the results
        System.assertEquals('Deactivated', creditCard.Status__c);
	    System.assertEquals('Deactivated', creditCard.Card_Deactivation_Status__c);
        System.assertEquals('Over Credit Limit', creditCard.Card_Deactivation_Reason__c);
	    
	    //Portfolio Deactivation reason will be cleaned up and Warning date will be also cleaned up
	    portfolio = [SELECT Id, Final_warning_Balance__c, Deactivation_Reason__c 
                     	FROM Portfolio__c 
                     	WHERE Id =: portfolio.Id];
        
        //Assert for the results
        System.assert(portfolio != null);
	    System.assertNotEquals(null, portfolio.Final_warning_Balance__c);
        System.assertEquals('Over Credit Balance Limit', portfolio.Deactivation_Reason__c);
	}
    
    //Modified By - Abhinav Sharma - CR-20150202-8644 - 07/13/2016 - A code refactor CR
    /** Description : Method to test Functionality to Activate card in comdata
    **/
    static testmethod void testDeactivateCardInComdata() {
        
        //Bypass Dupeblocker and triggers
        Util.IsTest(true);
        Util.byPassAllTriggers = true;
        Util.IsTesting = true;
        
        //User record
        User currentUser;
        
        //Update the User Finance Code if not alreayd populated
        System.runAs(new User(Id = UserInfo.getUserId())) {
        	
        	//Update the Employee Id
        	currentUser = new User(Id = UserInfo.getUserId(), Finance_Code__c = '50011');
        	update currentUser;
        }
        
        //insert Credit Card Settings record 
        Credit_Card_Settings__c configCCDefaultSetting = CreditCardConstants.CONFIG_DEFAULT;
        System.assert(configCCDefaultSetting != null);
        
        //insert Contact record
        Contact contact = TestUtilities.CreateNewContact(false);
        contact.Birthdate = System.today().addYears(-28);
        contact.Employee_ID__c = '50011';
        contact.Employee_User_Record__c = UserInfo.getUserId();
        insert contact;
        System.assert(contact != null);
        
        //Create a Provider Profile instance
        Provider_Profile__c pP = new Provider_Profile__c(Provider_Profile_ID__c = '2');
        insert pP;
        System.assert(pP != null);
        
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
        System.assert(abcProfile != null);
 		
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
                                                  	Advisory_Profile__c = abcProfile.Id,
	                                                RecordTypeId = configCCDefaultSetting.Staff_Portfolio_Record_Type__c, 
	                                                Status__c = CreditCardConstants.PORTFOLIO_STATUS_ACTIVATED,
	                                                Balance__c = 10);
        //Enabling triggers
        Util.byPassAllTriggers = false;
        
        //insert portfolio
        insert portfolio;
        
        //At this stage workflow will be get executed and Owner Finance code will be get populated
        //Assert for the results
        portfolio = [SELECT Id, Portfolio_Owner_Finance_Code__c  
                     FROM Portfolio__c 
                     WHERE Id =: portfolio.Id];
        
        //Asserting for the results
        System.assertEquals(currentUser.Finance_Code__c, portfolio.Portfolio_Owner_Finance_Code__c);
        
        //Create a new Credit Card record
        Credit_Card__c creditCard = new Credit_Card__c(Card_Requested_By__c = contact.Id, 
        													Card_Vendor__c = configCCDefaultSetting.Card_Vendor__c,
                                                            Payment_Account__c = portfolio.Id, 
                                                            RecordTypeId = configCCDefaultSetting.Staff_Card_Record_Type__c, 
                                                            Status__c = CreditCardConstants.CC_STATUS_ACTIVE,
                                                            Card_Set_up_Status__c = CreditCardConstants.CC_SETUP_STATUS_SUCCESS);
        insert creditCard;
        
        //Initialize method number for addCreditCard
        CreditCardServiceMockClass.methodNumber = 1;
        CreditCardServiceMockClass mock = new CreditCardServiceMockClass();
        HTTPService.response = mock.respond(new HttpRequest());
        
        //Test start here
        Test.startTest();
        
        //Now Update the Utilized Balance to over 100%, that will execute the workflow and Batch will also be get executed
        //Updating the Credit Card Balance will Rollup the same infomration on Portfolio record also
        portfolio.Balance__c = 110;
       	update portfolio;
       	
       	//Check for the Final Balance Warning on Portfolio record
        //It Should be Today + abcProfile.Over_balance_Countdown_days__c
        portfolio = [SELECT Id, Status__c, Deactivation_Reason__c, Final_warning_Balance__c 
                     	FROM Portfolio__c 
                     	WHERE Id =: portfolio.Id];
        
        //After countdown days, 
        //Field Updates will mark the Portfolio Status = Deactivated and Reason = Over Credit Limit
        //Trigger will then call the batch Process
        //Batch will fetch the Active Credit Card related to this Portfolio and will mark them deacitvate
        //Deactivation reason will be set to "Over Credit Limit"
       	portfolio.Status__c = CreditCardConstants.PORTFOLIO_STATUS_DEACTIVATED;
       	portfolio.Deactivation_Reason__c = CreditCardConstants.PORTFOLIO_DEACTIVATION_REASON_OVER_CREDIT_BALANNCE_LIMIT;
       	portfolio.Final_warning_Balance__c = Date.today() - 1;
       	update portfolio;
       	
        //Test stopss here
        Test.stopTest();
        
        //Check for the Credit Card Status 
        creditCard = [SELECT Status__c, Card_Deactivation_Status__c, Card_Deactivation_Reason__c 
                      	FROM Credit_Card__c 
                      	WHERE Id =: creditCard.Id];
        
        //Assert for the results
        System.assertEquals(CreditCardConstants.CC_STATUS_DEACTIVATED, creditCard.Status__c);
	    System.assertEquals(CreditCardConstants.CC_DEACTIVATION_STATUS_DEACTIVATED, creditCard.Card_Deactivation_Status__c);
	    System.assertEquals(Label.DEACTIVATION_OVER_CREDIT_LIMIT, creditCard.Card_Deactivation_Reason__c);
	}
}