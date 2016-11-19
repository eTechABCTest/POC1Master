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
private class Test_ProcessOSRController {
/**
 *  Description     :   Test class for ProcessOSRController
 *
 *  Created By      :   Bhavi Sharma
 *
 *  Created Date    :   12/10/2014
 *
 *  Revision Logs   :   V_1.0 - Created
 * 						V_1.1 - Modified - 12/1/2015- By Mahendra Swarnkar - Removed the Portfolio object field's Credit_Limit__c field reference, as it will no longer in use.
 *
 *  Coverage        :   %
 *
 **/
 
    //instance of Mock service class 
    static CreditCardServiceMockClass mockController = new CreditCardServiceMockClass();
    
    //HttpRequest instance
    static Httprequest req = new Httprequest();
	
    //Setup test data first. This will be available in the entire class
	@testSetup static void setup() {
	
		//insert Credit Card Settings record
        Credit_Card_Settings__c configCCDefaultSetting = TestUtilities.CreateCreditCardSettings();
        insert configCCDefaultSetting;
    	
        //Set helper class variable
        CreditCardHelper.configDefaults = configCCDefaultSetting;
        CreditCardConstants.CONFIG_DEFAULT = configCCDefaultSetting;
    }
    
    //OSR REQUEST TYPE = OSR_REQUEST_TYPE_NEW_ABC_CREDIT_CARD
    //Existing portfolio
    static testMethod void testCreateCard() {
        
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
        													Provider_Profile__c = pP.Id);
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
        configCCDefaultSetting.New_Card_Status__c = CreditCardConstants.CC_STATUS_PENDING_ACTIVATION;
        update configCCDefaultSetting;
        
        
        //OSR Record
        List<OSR__c> osrs = new List<OSR__c>();
        osrs.add(new OSR__c(Contact__c = contact.Id, Request_Type__c = CreditCardConstants.OSR_REQUEST_TYPE_NEW_ABC_CREDIT_CARD,
                            Agreement_Verified__c = true, Status__c = CreditCardConstants.OSR_STATUS_PENDING_FINANCE,
                            Agreement_Received__c = Date.Today().addDays(-1),
                            Advisory_Profile__c = abcProfile.Id));
        insert osrs;
        
        //Initialize method number for addCreditCard
        CreditCardServiceMockClass.methodNumber = 9;
        HTTPService.response = mockController.respond(req);
        
        //Start test from here
        Test.startTest();
        
        //Initilize Standard controller
        ApexPages.StandardController sc = new ApexPages.StandardController(osrs[0]);
        ProcessOSRController controller  = new ProcessOSRController(sc);
        controller.Init();
    	
    	//Process this request in Comdata
    	controller.processCardInComdata();
    	
    	//Stop test
    	Test.stopTest();
        
        //Check if a new portfolio and Credit card record has been created 
        List<Portfolio__c> portfolios = [Select Id from Portfolio__c where Card_Holder__c =: contact.Id];
        System.assertEquals(1, portfolios.size());
        
        //List of Credit card
        List<Credit_Card__c> creditCards = [Select Id, Status__c from Credit_Card__c where Payment_Account__c =: portfolios[0].Id];
        System.assertEquals(1, creditCards.size());
        System.assertEquals(CreditCardConstants.CC_STATUS_PENDING_ACTIVATION, creditCards[0].Status__c);
    }
 
    //Existing portfolio
    static testMethod void testReplaceCard() {
        
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
        													Provider_Profile__c = pP.Id);
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
        
        
        //OSR Record
        List<OSR__c> osrs = new List<OSR__c>();
        osrs.add(new OSR__c(Contact__c = contact.Id, Request_Type__c = CreditCardConstants.OSR_REQUEST_TYPE_REPLACEMENT_ABC_CREDIT_CARD,
                            Agreement_Verified__c = false, Advisory_Profile__c = abcProfile.Id, Related_Card__c = creditCard.Id,
                           Address_To_Name__c = 'Test', Address_Line_1__c = 'Test', Address_City__c = 'Test', Address_State__c = 'CA', Address_Postal_Code__c = '94105'));
        insert osrs;
        
        //Initialize method number for addCreditCard
        CreditCardServiceMockClass.methodNumber = 9;
        CreditCardServiceMockClass mock = new CreditCardServiceMockClass();
        HTTPService.response = mock.respond(new HttpRequest());
        
        //Start Testing from here
        Test.startTest();
        
        //Initilize Standard controller
        ApexPages.StandardController sc = new ApexPages.standardController(osrs[0]);
        ProcessOSRController controller  = new ProcessOSRController(sc);
        
        //Deactivate Card
        controller.init();
        
        //Create a new Card
        controller.processCardInComdata();
        
        //Add Card in Comdata
        controller.processCardInComdata();
        
        //Test start here
        Test.stopTest();
    	
    	//Check if the current card is deactivated and a new card is issued to user
    	creditCard = [Select Card_Deactivation_Status__c from Credit_Card__c where Id =: creditCard.Id];
    	System.assertEquals(CreditCardConstants.CC_DEACTIVATION_STATUS_PENDING_REPLACEMENT_ACTIVATION, creditCard.Card_Deactivation_Status__c);
    	
    	//New Card
    	List<Credit_Card__c> newCard = [Select Id, Status__c, Card_Number__c from Credit_Card__c where Id !=: creditCard.Id AND Payment_Account__c =: portfolio.Id];
    	System.assertEquals(1, newCard.size());
    	System.assertEquals(CreditCardConstants.CC_STATUS_PENDING_ACTIVATION, newCard[0].Status__c);
    	
    }

   	//OSR REQUEST TYPE = OSR_REQUEST_TYPE_DEACTIVATE_ABC_CREDIT_CARD
    //Existing portfolio
    static testMethod void testDeactivateCard() {
        
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
        
        //OSR Record
        List<OSR__c> osrs = new List<OSR__c>();
        osrs.add(new OSR__c(Contact__c = contact.Id, Request_Type__c = CreditCardConstants.OSR_REQUEST_TYPE_DEACTIVATE_ABC_CREDIT_CARD,
                            Agreement_Verified__c = true, Status__c = CreditCardConstants.OSR_STATUS_PENDING_FINANCE,
                            Agreement_Received__c = Date.Today().addDays(-1),
                            Advisory_Profile__c = abcProfile.Id, Related_Card__c = creditCard.Id,
                            Request_Reason__c = 'Test'));
        insert osrs;
        
        //Initialize method number for Deactivate Card
        CreditCardServiceMockClass.methodNumber = 1;
        HTTPService.response = mockController.respond(req);
        
        //Start test from here
        Test.startTest();
        
        //Initilize Standard controller
        ApexPages.StandardController sc = new ApexPages.StandardController(osrs[0]);
        ProcessOSRController controller  = new ProcessOSRController(sc);
        controller.Init();
    	
    	//Process this request in Comdata
    	controller.processCardInComdata();
    	
    	//Stop test
    	Test.stopTest();
        
        //List of Credit card
        creditCard = [Select Id, Status__c from Credit_Card__c where Id =: creditCard.Id];
        System.assertEquals(CreditCardConstants.CC_STATUS_DEACTIVATED, creditCard.Status__c);
    }

    //Method to test error Case
     static testMethod void testErrorCase() {
     	
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
        
        //OSR Record
        List<OSR__c> osrs = new List<OSR__c>();
        osrs.add(new OSR__c(Contact__c = contact.Id, Request_Type__c = CreditCardConstants.OSR_REQUEST_TYPE_DEACTIVATE_ABC_CREDIT_CARD,
                            Agreement_Verified__c = true, Status__c = CreditCardConstants.OSR_STATUS_PENDING_FINANCE,
                            Agreement_Received__c = Date.Today().addDays(-1),
                            Advisory_Profile__c = abcProfile.Id, Related_Card__c = creditCard.Id,
                            Request_Reason__c = 'Test'));
        insert osrs;
        
        //Initialize method number for Deactivate Card
        CreditCardServiceMockClass.methodNumber = 13;
        HTTPService.response = mockController.respond(req);
        
        //Start test from here
        Test.startTest();
        
        //Initilize Standard controller
        ApexPages.StandardController sc = new ApexPages.StandardController(osrs[0]);
        ProcessOSRController controller  = new ProcessOSRController(sc);
        controller.Init();
    	
    	try {
	    	//Process this request in Comdata
	    	controller.processCardInComdata();
    	}catch (Exception e) {
    		
    		//Asseting for results
    		system.assertEquals('Invalid request.', e.getMessage());
    		
    		//Query through Log 
    		List<Web_Service_Log__c> logs = [Select ID From Web_Service_Log__c];
    		System.assertEquals(1, logs.size());
    	}
    	//Stop test
    	Test.stopTest();
        
        //List of Credit card
        creditCard = [Select Id, Status__c from Credit_Card__c where Id =: creditCard.Id];
        //System.assertEquals(CreditCardConstants.CC_STATUS_DEACTIVATED, creditCard.Status__c);
     }
}