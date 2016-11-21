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
private class Test_CreditCardService {
/**
 *  Description     :   Test class for CreditCardService.
 *
 *  Created By      :   Bhavi Sharma
 *
 *  Created Date    :   10/25/2013
 *
 *  Revision Logs   :   V_1.0 - Created
 *                  :   V_1.1 - Modified by Ajit Surana - 05/27/2014 - Fixes test failures
 * 						V_1.2 - Modified - 12/1/2015- By Mahendra Swarnkar - Removed the Portfolio object field's Credit_Limit__c field reference, as it will no longer in use.
 *
 *  Coverage        :
 *
 **/
    
    //HttpRequest instance
    static Httprequest req = new Httprequest();
    
    //instance of Mock service class 
    static CreditCardServiceMockClass mockController = new CreditCardServiceMockClass();
    
    //Setup test data first. This will be available in the entire class
	@testSetup static void setup() {
	
		//insert Credit Card Settings record
        Credit_Card_Settings__c configCCDefaultSetting = TestUtilities.CreateCreditCardSettings();
        insert configCCDefaultSetting;
    	
        //Set helper class variable
        CreditCardHelper.configDefaults = configCCDefaultSetting;
        CreditCardConstants.CONFIG_DEFAULT = configCCDefaultSetting;
    }

    //Test method for interimStageAddCreditCard
    static testMethod void testInterimStageAddCreditCard() {
        
        //User record
        User currentUser;
        
        //Update the User Finance Code if not alreayd populated
        System.runAs(new User(Id = UserInfo.getUserId())) {
            
            //Update the Employee Id
            currentUser = new User(Id = UserInfo.getUserId(), Finance_Code__c = '50011');
            update currentUser;
        }
        
        //Set Credit Card Settings record 
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
        
        //Assert for the results
        System.assert(rdTypesPortfolio != null); 
        
        //Update configCCDefaultSetting field
        configCCDefaultSetting.Staff_Portfolio_Record_Type__c = rdTypesPortfolio[0].id;
        update configCCDefaultSetting;
        
        //Payment Account record
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
        
        //List of OSR to be record
        List<OSR__c> osrs = new List<OSR__c>();
        osrs.add(new OSR__c(Request_Type__c = CreditCardConstants.OSR_REQUEST_TYPE_NEW_ABC_CREDIT_CARD, Expedited_Processing_Approval__c = 'Approved', Address_City__c = 'Chicago',
                                Address_Line_1__c = '32, West Street', Address_State__c = 'KS', Address_Postal_Code__c = '12345', Address_To_Name__c = 'test', Advisory_Profile__c = abcProfile.Id));
        insert osrs;
        
        //Encrypt the card Number
        String encryptNumber1 = CreditCardService.Encrypt('5567356025410226');
        
        //Credit Card record   
        List<Credit_Card__c> cards = new List<Credit_Card__c>(); 
        cards.add(new Credit_Card__c(Card_Number__c = encryptNumber1, Payment_Account__c = portfolio.Id, 
                                        Original_Request__c = osrs[0].Id,
                                        Card_Set_up_Status__c = CreditCardConstants.CC_SETUP_STATUS_PENDING_RESPONSE, Card_Requested_By__c = contact.Id));
        insert cards;
        
        //Test starts here
        Test.startTest();
        
        //call interim method for Add card
        CreditCardService.interimStageAddCreditCard(cards[0]);
        
        //Query result of Credit Card
        List<Credit_Card__c> creditCards = [SELECT Status__c, Card_Set_up_Status__c FROM Credit_Card__c WHERE Card_Number__c =: encryptNumber1];
        
        //Stop testing here 
        Test.stopTest();
    
        //assert statements
        System.assertEquals(CreditCardConstants.CC_STATUS_VENDOR_APPROVAL, creditCards[0].Status__c);
        System.assertEquals(CreditCardConstants.CC_SETUP_STATUS_PENDING_RESPONSE, creditCards[0].Card_Set_up_Status__c);
    }
    
    //Test method for interimStageDeactivateCreditCard
    static testMethod void testInterimStageDeactivateCreditCard() {
            
        //User record
        User currentUser;
        
        //Update the User Finance Code if not alreayd populated
        System.runAs(new User(Id = UserInfo.getUserId())) {
            
            //Update the Employee Id
            currentUser = new User(Id = UserInfo.getUserId(), Finance_Code__c = '50011');
            update currentUser;
        }
        
        //Set Credit Card Settings record 
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
        
        //Test starts here
        Test.startTest();
        
        //call interim method for Add card
        CreditCardService.interimStageDeactivateCreditCard(creditCard);
        
        //Query result of Credit Card
        creditCard = [SELECT Status__c, Card_Deactivation_Status__c FROM Credit_Card__c WHERE id =: creditCard.Id];
        
        //Test stops here
        Test.stopTest();
    
        //assert statements
        System.assertEquals(CreditCardConstants.CC_STATUS_PENDING_DEACTIVATION, creditCard.Status__c);
        System.assertEquals(CreditCardConstants.CC_DEACTIVATION_STATUS_PENDING_RESPONSE, creditCard.Card_Deactivation_Status__c);
    }
 
    //Test method for inquireCreditCard
    static testMethod void testInquireCreditCard() {
        
        //User record
        User currentUser;
        
        //Update the User Finance Code if not alreayd populated
        System.runAs(new User(Id = UserInfo.getUserId())) {
            
            //Update the Employee Id
            currentUser = new User(Id = UserInfo.getUserId(), Finance_Code__c = '50011');
            update currentUser;
        }
        
        //Set Credit Card Settings record 
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
        
        //Fetch credit card data
        creditCard = [SELECT Id, Name,
                        Card_Set_up_Status__c,
                        Credit_Card_Number__c,
                        Card_Number__c,
                        Card_Vendor__c,
                        Card_Expiration__c,
                        Card_Status_Code__c,
                        Card_Deactivation_Reason__c,
                        Status__c,
                        Card_Holder_First_Name__c,
                        Card_Holder_Last_Name__c,
                        Card_Deactivation_Status__c,
                        Card_Employee_Number__c,
                        Payment_Account__c,
                        Payment_Account__r.Portfolio_Owner_Finance_Code__c,
                        Payment_Account__r.Card_Holder__r.Personal_Address_Line_1__c,
                        Payment_Account__r.Card_Holder__r.Personal_Address_Line_2__c,
                        Payment_Account__r.Card_Holder__r.Personal_Address_City__c,
                        Payment_Account__r.Card_Holder__r.Personal_Address_State__c,
                        Payment_Account__r.Card_Holder__r.Personal_Address_PostalCode__c,
                        Original_Request__c,
                        Original_Request__r.Address_Line_1__c,
                        Original_Request__r.Address_Line_2__c,
                        Original_Request__r.Address_City__c,
                        Original_Request__r.Address_State__c,
                        Original_Request__r.Address_Postal_Code__c,
                        Original_Request__r.Expedited_Processing_Approval__c
                        FROM Credit_Card__c WHERE Id =: creditCard.Id];
                     
        //Initialize method number for inquireCreditCard
        CreditCardServiceMockClass.methodNumber = 2;
        HttpService.response = mockController.respond(req);
        
        //Test starts here
        Test.startTest();
                   
        //call interim method for inquire Credit Card
        CreditCardService.inquireCreditCard(creditCard, true);
        
        //Test stops here
        Test.stopTest();
        
        //Query result of Credit Card
        List<Note> notes = [SELECT Id FROM Note WHERE ParentId =: creditCard.Id];
        
        //assert statements
        System.assertEquals(1, notes.size());
    }   
    
    //Test method for getInquireCardSecurityCodeEnvelope
    static testMethod void testGetInquireCardSecurityCodeEnvelope() {
        
        //User record
        User currentUser;
        
        //Update the User Finance Code if not alreayd populated
        System.runAs(new User(Id = UserInfo.getUserId())) {
            
            //Update the Employee Id
            currentUser = new User(Id = UserInfo.getUserId(), Finance_Code__c = '50011');
            update currentUser;
        }
        
        //Set Credit Card Settings record 
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
        
        //Fetch credit card data
        creditCard = [SELECT Id, Name,
                        Card_Set_up_Status__c,
                        Credit_Card_Number__c,
                        Card_Number__c,
                        Card_Vendor__c,
                        Card_Expiration__c,
                        Card_Status_Code__c,
                        Card_Deactivation_Reason__c,
                        Status__c,
                        Card_Holder_First_Name__c,
                        Card_Holder_Last_Name__c,
                        Card_Deactivation_Status__c,
                        Card_Employee_Number__c,
                        Payment_Account__c,
                        Payment_Account__r.Portfolio_Owner_Finance_Code__c,
                        Payment_Account__r.Card_Holder__r.Personal_Address_Line_1__c,
                        Payment_Account__r.Card_Holder__r.Personal_Address_Line_2__c,
                        Payment_Account__r.Card_Holder__r.Personal_Address_City__c,
                        Payment_Account__r.Card_Holder__r.Personal_Address_State__c,
                        Payment_Account__r.Card_Holder__r.Personal_Address_PostalCode__c,
                        Original_Request__c,
                        Original_Request__r.Address_Line_1__c,
                        Original_Request__r.Address_Line_2__c,
                        Original_Request__r.Address_City__c,
                        Original_Request__r.Address_State__c,
                        Original_Request__r.Address_Postal_Code__c,
                        Original_Request__r.Expedited_Processing_Approval__c
                        FROM Credit_Card__c WHERE Id =: creditCard.Id];
        
        //Test starts here
        Test.startTest();
        
        //call interim method for clone Credit Card for replacement
        CreditCardHelper.getInquireCardSecurityCodeEnvelope(creditCard);
        CreditCardHelper.processDate(Date.today());
        
        //Test stops here
        Test.stopTest();
    }
}