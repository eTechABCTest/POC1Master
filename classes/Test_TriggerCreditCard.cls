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
private class Test_TriggerCreditCard {
/**
 *  Description     :   Test class for Trigger_CreditCard
 *
 *  Created By      :   Bhavi Sharma
 *
 *  Created Date    :   
 *
 *  Revision Logs   :   V_1.0 - Created
 *                      V_1.1 - Modified - 12/9/2014 - By Bhavi Sharma
 *						V_1.2 - Modified - 12/1/2015- By Mahendra Swarnkar - Removed the Portfolio object field's Credit_Limit__c field reference, as it will no longer in use.

 *  Coverage        :   100%
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
    
    //Method to test updateOSRToInProgress method of trigger 
    static testmethod void testUpdateOSRToInProgress() {
        
        List<RecordType> recordTypes = [SELECT Id, DeveloperName FROM RecordType WHERE IsActive = true AND 
                                            SobjectType = 'Contact' AND DeveloperName =: Constants.CONTACT_RECORD_TYPE_DEVELOPER_NAME_EMPLOYEE Limit 1];
        
        //assert statements
        System.assertEquals(1, recordTypes.size());
                    
        //List to hold Contact
        List<Contact> contacts = new List<Contact>();
        contacts.add(new Contact(FirstName = 'Test', LastName = 'Contact 1', RecordTypeId = recordTypes[0].Id, Employee_Id__c = '12341'));
        contacts.add(new Contact(FirstName = 'Test', LastName = 'Contact 2', RecordTypeId = recordTypes[0].Id, Employee_Id__c = '12342'));
        
        //insert contacts
        insert contacts;
        
        //List hold to create OSRs 
        List<OSR__c> osrs = new List<OSR__c>();
        osrs.add(new OSR__c(Status__c = CreditCardConstants.OSR_STATUS_NEW));
        osrs.add(new OSR__c(Status__c = CreditCardConstants.OSR_STATUS_NEW));
        insert osrs;
        
        //Payment Account record
        List<Portfolio__c> payments = new List<Portfolio__c>();
        payments.add(new Portfolio__c(Status__c = Constants.ACTIVE, Card_Holder__c = contacts[0].Id, Portfolio_Owner_Finance_Code__c = '678981'));
        payments.add(new Portfolio__c(Status__c = Constants.ACTIVE, Card_Holder__c = contacts[1].Id, Portfolio_Owner_Finance_Code__c = '678941'));
        insert payments;
        
        //Encrypt the card Number
        String encryptNumber1 = CreditCardService.Encrypt('5567356025410226');
        String encryptNumber2 = CreditCardService.Encrypt('5567356025410227');
        
        //Credit Card record   
        List<Credit_Card__c> cards = new List<Credit_Card__c>(); 
        cards.add(new Credit_Card__c(Card_Number__c = encryptNumber1, Status__c = 'Active', Original_Request__c = osrs[0].Id,
                 Card_Requested_By__c = contacts[0].Id, Payment_Account__c = payments[0].Id, Card_Employee_Number__c = '9898'));
        cards.add(new Credit_Card__c(Card_Number__c = encryptNumber2, Status__c = 'Active', Original_Request__c = osrs[1].Id, 
                 Card_Requested_By__c = contacts[1].Id, Payment_Account__c = payments[1].Id, Card_Employee_Number__c = '98981'));
        
        //Test starts here
        Test.startTest();
        
        //insert Credit Card
        insert cards;
        
        //Query result of OSRs
        osrs = [SELECT Id, Status__c FROM OSR__c WHERE Id IN: osrs];
        
        //assert statements
        System.assertEquals(CreditCardConstants.OSR_STATUS_IN_PROGRESS, osrs[0].Status__c);  
        System.assertEquals(CreditCardConstants.OSR_STATUS_IN_PROGRESS, osrs[1].Status__c);
        
        //Test stops here
        Test.stopTest();
    }   
    
    //Method to test activateCardInComdata method of trigger 
    static testmethod void testActivateCardInComdata() {
        
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
        
        system.debug('@@@@@@@@@@@@@@'+CreditCardHelper.configDefaults);
        
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
                                                            Status__c = CreditCardConstants.CC_STATUS_PENDING_ACTIVATION);
        insert creditCard;
        
        //Initialize method number for addCreditCard
        CreditCardServiceMockClass.methodNumber = 3;
        	CreditCardServiceMockClass mock = new CreditCardServiceMockClass();
        	HTTPService.response = mock.respond(new HttpRequest());
        
        //Test starts here
        Test.startTest();
        
        //Once user activated the card
        creditCard.Card_Set_up_Status__c = CreditCardConstants.CC_SET_UP_STATUS_USER_ACTIVATED;
        update creditCard;
        
        //Test stops here
        Test.stopTest();
        
        //Query result of Credit Card
        creditCard = [SELECT Status__c, Card_Set_up_Status__c FROM Credit_Card__c WHERE Id =: creditCard.Id];
        
        //assert statements
        System.assertEquals(CreditCardConstants.CC_STATUS_ACTIVE, creditCard.Status__c);
        System.assertEquals(CreditCardConstants.CC_SETUP_STATUS_SUCCESS, creditCard.Card_Set_up_Status__c);
    }
}