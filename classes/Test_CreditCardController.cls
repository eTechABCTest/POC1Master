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
private class Test_CreditCardController {
/**
 *  Description     :   Test class for CreditCardController
 *
 *  Created By      :   Bhavi Sharma
 *
 *  Created Date    :   08/14/2013
 *
 *  Revision Logs   :   V_1.0 - Created
 * 						V_1.1 - Modified (Line no - 514) - CR-20150707-9062 - 11/03/2015 - By Mahendra Swarnkar
 *
 *  Coverage        :
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
    
    //Test add Credit Card method
    static testMethod void testAddCreditCard() {
        
        try{
        
            //Query result of Record Types
            List<RecordType> recordTypes = [SELECT Id, DeveloperName FROM RecordType WHERE IsActive = true AND 
                                                SobjectType = 'Contact' AND DeveloperName =: Constants.CONTACT_RECORD_TYPE_DEVELOPER_NAME_EMPLOYEE Limit 1];
            
            //assert statements
            System.assertEquals(1, recordTypes.size());
                        
            //List to hold Contact and insert contacts
            List<Contact> contacts = new List<Contact>();
           contacts.add(new Contact(FirstName = 'Test', LastName = 'Contact 1', RecordTypeId = recordTypes[0].Id, Employee_Id__c = '1241', Legal_First_Name__c = 'Test1',
                                        Legal_Last_Name__c = 'Contact 1', Personal_Address_Line_1__c = 'Abc Street', Personal_Address_Line_2__c = 'Test', 
                                        Personal_Address_PostalCode__c = '32234', Personal_Address_City__c = 'Dallas', Personal_Address_State__c = 'CA'));
            contacts.add(new Contact(FirstName = 'Test', LastName = 'Contact 2', RecordTypeId = recordTypes[0].Id, Employee_Id__c = '1234', Legal_First_Name__c = 'Test2',
                                        Legal_Last_Name__c = 'Contact 1', Personal_Address_Line_1__c = 'Abc Street', Personal_Address_Line_2__c = 'Test', 
                                        Personal_Address_PostalCode__c = '32124', Personal_Address_City__c = 'Dallas', Personal_Address_State__c = 'CA'));
            contacts.add(new Contact(FirstName = 'Test', LastName = 'Contact 3', RecordTypeId = recordTypes[0].Id, Employee_Id__c = '1231', Legal_First_Name__c = 'Test3',
                                        Legal_Last_Name__c = 'Contact 1', Personal_Address_Line_1__c = 'Abc Street', Personal_Address_Line_2__c = 'Test', 
                                        Personal_Address_PostalCode__c = '32134', Personal_Address_City__c = 'Dallas', Personal_Address_State__c = 'CA'));
            contacts.add(new Contact(FirstName = 'Test', LastName = 'Contact 4', RecordTypeId = recordTypes[0].Id, Employee_Id__c = '1230', Legal_First_Name__c = 'Test4',
                                        Legal_Last_Name__c = 'Contact 1', Personal_Address_Line_1__c = 'Abc Street', Personal_Address_Line_2__c = 'Test', 
                                        Personal_Address_PostalCode__c = '32134', Personal_Address_City__c = 'Dallas', Personal_Address_State__c = 'CA'));
            insert contacts;
            
            //Payment Account record
            List<Portfolio__c> payments = new List<Portfolio__c>();
            payments.add(new Portfolio__c(Status__c = Constants.ACTIVE, Card_Holder__c = contacts[0].Id, Portfolio_Owner_Finance_Code__c = '678981'));
            payments.add(new Portfolio__c(Status__c = Constants.ACTIVE, Card_Holder__c = contacts[1].Id, Portfolio_Owner_Finance_Code__c = '678982'));
            payments.add(new Portfolio__c(Status__c = Constants.ACTIVE, Card_Holder__c = contacts[2].Id, Portfolio_Owner_Finance_Code__c = '678983'));
            payments.add(new Portfolio__c(Status__c = Constants.ACTIVE, Card_Holder__c = contacts[3].Id, Portfolio_Owner_Finance_Code__c = '678984'));
            insert payments;
            
                        //List of OSR to be record
            List<OSR__c> osrs = new List<OSR__c>();
            osrs.add(new OSR__c(Request_Type__c = CreditCardConstants.OSR_REQUEST_TYPE_NEW_ABC_CREDIT_CARD));
            osrs.add(new OSR__c(Request_Type__c = CreditCardConstants.OSR_REQUEST_TYPE_NEW_ABC_CREDIT_CARD, Expedited_Processing_Approval__c = 'Approved'));
            osrs.add(new OSR__c(Request_Type__c = CreditCardConstants.OSR_REQUEST_TYPE_NEW_ABC_CREDIT_CARD, Expedited_Processing_Approval__c = 'Approved'));
            insert osrs;
            
            //Encrypt the card Number
            String encryptNumber1 = CreditCardService.Encrypt('5567356025410226');
            String encryptNumber2 = CreditCardService.Encrypt('5567356025410227');
            String encryptNumber3 = CreditCardService.Encrypt('5567356025410228');
           
            //Credit Card record   
            List<Credit_Card__c> cards = new List<Credit_Card__c>(); 
            cards.add(new Credit_Card__c(Card_Number__c = encryptNumber1, Status__c = CreditCardConstants.CC_STATUS_VENDOR_APPROVAL, Payment_Account__c = payments[0].Id, 
                                            Original_Request__c = osrs[0].Id, 
                                            Card_Set_up_Status__c = CreditCardConstants.CC_SETUP_STATUS_PENDING_RESPONSE, Card_Requested_By__c = contacts[0].Id, Card_Employee_Number__c = 'CARD-1'));
            cards.add(new Credit_Card__c(Card_Number__c = encryptNumber2, Status__c = CreditCardConstants.CC_STATUS_VENDOR_APPROVAL, Payment_Account__c = payments[1].Id, 
                                            Original_Request__c = osrs[1].Id, Card_Set_up_Status__c = CreditCardConstants.CC_SETUP_STATUS_PENDING_RESPONSE,
                                           Card_Requested_By__c = contacts[1].Id, Card_Employee_Number__c = 'CARD-2'));
            cards.add(new Credit_Card__c(Status__c = CreditCardConstants.CC_SET_UP_STATUS_NEW_REQUEST, Payment_Account__c = payments[1].Id, 
                                            Original_Request__c = osrs[2].Id, Card_Set_up_Status__c = CreditCardConstants.CC_SET_UP_STATUS_NEW_REQUEST,
                                            Card_Requested_By__c = contacts[1].Id, Card_Employee_Number__c = 'CARD-3'));
            cards.add(new Credit_Card__c(Payment_Account__c = payments[3].Id, Card_Employee_Number__c = 'CARD-4'));
            insert cards;
            
            //Check for size of list
            if(cards.size() > 0){
            
                //Start testing from here
                Test.startTest();
        
                //Instantiate Controller
                CreditCardController controller = new CreditCardController(new ApexPages.StandardController(cards[0]));
                
                //Initialize method number for addCreditCard
                CreditCardServiceMockClass.methodNumber = 9;
                
                //Response of addCreditCard request
                HttpService.response = mockController.respond(req);
                
                //Call deactivateCreditCard method
                controller.addCreditCard();
                
                //Instantiate Controller
                controller = new CreditCardController(new ApexPages.StandardController(cards[1]));
                
                //Initialize method number for addCreditCard
                CreditCardServiceMockClass.methodNumber = 9;
                
                //Response of addCreditCard request
                HttpService.response = mockController.respond(req);
                
                //Call addCreditCard method
                controller.addCreditCard();
                
                //Query result of Credit Cards
                List<Credit_Card__c> creditCards = [SELECT Status__c, Card_Set_up_Status__c FROM Credit_Card__c WHERE Card_Number__c =: encryptNumber2];
                
                //assert statements
                //System.assertEquals(CreditCardConstants.CC_STATUS_INACTIVE, creditCards[0].Status__c);
                //System.assertEquals(CreditCardConstants.CC_SETUP_STATUS_SUCCESS, creditCards[0].Card_Set_up_Status__c);
                
                //Instantiate Controller
                controller = new CreditCardController(new ApexPages.StandardController(cards[2]));
                
                //Initialize method number for addCreditCard
                CreditCardServiceMockClass.methodNumber = 9;
                
                //Response of addCreditCard request
                HttpService.response = mockController.respond(req);
                
                //Call addCreditCard method
                controller.addCreditCard();
                
                //Query result of Credit Cards
                creditCards = [SELECT Status__c, Card_Set_up_Status__c FROM Credit_Card__c WHERE Card_Number__c =: encryptNumber3];
                
                //assert statements
                System.assertEquals(CreditCardConstants.CC_STATUS_VENDOR_APPROVAL, creditCards[0].Status__c);
                System.assertEquals(CreditCardConstants.CC_SETUP_STATUS_PENDING_RESPONSE, creditCards[0].Card_Set_up_Status__c);
                
                //Instantiate Controller
                controller = new CreditCardController(new ApexPages.StandardController(cards[3]));
                
                //Initialize method number for addCreditCard
                CreditCardServiceMockClass.methodNumber = 10;
                
                //Response of addCreditCard request
                HttpService.response = mockController.respond(req);
                
                //Call addCreditCard method
                controller.addCreditCard();
                
                //Stop test here
                Test.stopTest();
            }
        }catch(Exception e) {
            
        }
    }
      
    //Test Replace Credit Card method
    static testMethod void testReplaceCreditCard() {
        
        //Create provider profile
        Provider_Profile__c providerProfile = new Provider_Profile__c(Name = 'Test');
        insert providerProfile;
        
        //Create ABC profile(Advisory profile)
        ABC_Profile__c advisoryProfile = new ABC_Profile__c(Name = 'Test Advisory Profile',Provider_Profile__c = providerProfile.Id);
        insert advisoryProfile;
        
        //Query result of Record Types
        List<RecordType> recordTypes = [SELECT Id, DeveloperName FROM RecordType WHERE IsActive = true AND 
                                            SobjectType = 'Contact' AND DeveloperName =: Constants.CONTACT_RECORD_TYPE_DEVELOPER_NAME_EMPLOYEE Limit 1];
        
        //assert statements
        System.assertEquals(1, recordTypes.size());
                    
        //List to hold Contact and insert contacts
        List<Contact> contacts = new List<Contact>();
        contacts.add(new Contact(FirstName = 'Test', LastName = 'Contact 1', RecordTypeId = recordTypes[0].Id, Employee_Id__c = '1241', Legal_First_Name__c = 'Test1',
                                    Legal_Last_Name__c = 'Contact 1', Personal_Address_Line_1__c = 'Abc Street', Personal_Address_Line_2__c = 'Test', 
                                    Personal_Address_PostalCode__c = '32234', Personal_Address_City__c = 'Dallas', Personal_Address_State__c = 'CA'));
        contacts.add(new Contact(FirstName = 'Test', LastName = 'Contact 2', RecordTypeId = recordTypes[0].Id, Employee_Id__c = '1234', Legal_First_Name__c = 'Test2',
                                    Legal_Last_Name__c = 'Contact 1', Personal_Address_Line_1__c = 'Abc Street', Personal_Address_Line_2__c = 'Test', 
                                    Personal_Address_PostalCode__c = '32124', Personal_Address_City__c = 'Dallas', Personal_Address_State__c = 'CA'));
        contacts.add(new Contact(FirstName = 'Test', LastName = 'Contact 3', RecordTypeId = recordTypes[0].Id, Employee_Id__c = '1231', Legal_First_Name__c = 'Test3',
                                    Legal_Last_Name__c = 'Contact 1', Personal_Address_Line_1__c = 'Abc Street', Personal_Address_Line_2__c = 'Test', 
                                    Personal_Address_PostalCode__c = '32134', Personal_Address_City__c = 'Dallas', Personal_Address_State__c = 'CA'));
        insert contacts;
        
        //Payment Account record
        List<Portfolio__c> payments = new List<Portfolio__c>();
        payments.add(new Portfolio__c(Status__c = Constants.ACTIVE, Card_Holder__c = contacts[0].Id, Portfolio_Owner_Finance_Code__c = '678981'));
        payments.add(new Portfolio__c(Status__c = Constants.ACTIVE, Card_Holder__c = contacts[1].Id, Portfolio_Owner_Finance_Code__c = '678982'));
        payments.add(new Portfolio__c(Status__c = Constants.ACTIVE, Card_Holder__c = contacts[2].Id, Portfolio_Owner_Finance_Code__c = '678983'));
        insert payments;
        
        //List of OSR to be record
        List<OSR__c> osrs = new List<OSR__c>();
        osrs.add(new OSR__c(Request_Type__c = CreditCardConstants.OSR_REQUEST_TYPE_NEW_ABC_CREDIT_CARD, Advisory_Profile__c = advisoryProfile.Id));
        osrs.add(new OSR__c(Request_Type__c = CreditCardConstants.OSR_REQUEST_TYPE_NEW_ABC_CREDIT_CARD, Advisory_Profile__c = advisoryProfile.Id));
        insert osrs;
        
        //Encrypt the card Number
        String encryptNumber1 = CreditCardService.Encrypt('5567356025410226');
        String encryptNumber2 = CreditCardService.Encrypt('5567356025410227');
        String encryptNumber3 = CreditCardService.Encrypt('5567356025410228');
       
        //Credit Card record   
        List<Credit_Card__c> cards = new List<Credit_Card__c>(); 
        cards.add(new Credit_Card__c(Card_Number__c = encryptNumber1, Status__c = CreditCardConstants.CC_STATUS_ACTIVE, Payment_Account__c = payments[0].Id, 
                                        Original_Request__c = osrs[0].Id, Card_Employee_Number__c = 'CARD-1'));
        cards.add(new Credit_Card__c(Card_Number__c = encryptNumber2, Status__c = CreditCardConstants.CC_STATUS_PENDING_DEACTIVATION, Payment_Account__c = payments[1].Id, 
                                        Original_Request__c = osrs[1].Id, Card_Deactivation_Status__c = CreditCardConstants.CC_DEACTIVATION_STATUS_PENDING_RESPONSE, Card_Employee_Number__c = 'CARD-2'));
        cards.add(new Credit_Card__c(Payment_Account__c = payments[2].Id, Card_Employee_Number__c = 'CARD-3'));
        insert cards;
        
        //Check for size of list
        if(cards.size() > 0){
        
            //Start testing from here
            Test.startTest();
    
            //Instantiate Controller
            CreditCardController controller = new CreditCardController(new ApexPages.StandardController(cards[0]));
            
            //Initialize method number for replaceCreditCard
            CreditCardServiceMockClass.methodNumber = 3;
            
            //Response of replaceCreditCard request
            HttpService.response = mockController.respond(req);
            
            try{
                
                //Call deactivateCreditCard method
                controller.replaceCreditCard();
                
                //Query result of Credit Cards
                List<Credit_Card__c> creditCards = [SELECT Status__c, Card_Deactivation_Status__c FROM Credit_Card__c WHERE Card_Number__c =: encryptNumber1];
                
                //assert statements
                System.assertEquals(CreditCardConstants.CC_STATUS_PENDING_DEACTIVATION, creditCards[0].Status__c);
                System.assertEquals('Pending Replacement Activation', creditCards[0].Card_Deactivation_Status__c);
                
                //Instantiate Controller
                controller = new CreditCardController(new ApexPages.StandardController(cards[1]));
                
                //Initialize method number for replaceCreditCard
                CreditCardServiceMockClass.methodNumber = 3;
                
                //Response of replaceCreditCard request
                HttpService.response = mockController.respond(req);
                
                //Call replaceCreditCard method
                controller.replaceCreditCard();
                
                //Query result of Credit Cards
                creditCards = [SELECT Status__c, Card_Deactivation_Status__c FROM Credit_Card__c WHERE Card_Number__c =: encryptNumber2];
                
                //assert statements
                System.assertEquals(CreditCardConstants.CC_STATUS_DEACTIVATED, creditCards[0].Status__c);
                System.assertEquals(CreditCardConstants.CC_DEACTIVATION_STATUS_DEACTIVATED, creditCards[0].Card_Deactivation_Status__c);
                
                //Instantiate Controller
                controller = new CreditCardController(new ApexPages.StandardController(cards[2]));
                
                //Initialize method number for replaceCreditCard
                CreditCardServiceMockClass.methodNumber = 10;
                
                //Response of replaceCreditCard request
                HttpService.response = mockController.respond(req);
                
                //Call replaceCreditCard method
                controller.replaceCreditCard();
            
                //Stop test here
                Test.stopTest();
            }catch(Exception e) {
            
            }
        }
    }
    
    
    //Test deactivate Credit Card method
    static testMethod void testDeactivateCreditCard() {
        
        //Create provider profile
        Provider_Profile__c providerProfile = new Provider_Profile__c(Name = 'Test');
        insert providerProfile;
        
        //Create ABC profile(Advisory profile)
        ABC_Profile__c advisoryProfile = new ABC_Profile__c(Name = 'Test Advisory Profile',Provider_Profile__c = providerProfile.Id);
        insert advisoryProfile;
            
        //Query result of Record Types
        List<RecordType> recordTypes = [SELECT Id, DeveloperName FROM RecordType WHERE IsActive = true AND 
                                            SobjectType = 'Contact' AND DeveloperName =: Constants.CONTACT_RECORD_TYPE_DEVELOPER_NAME_EMPLOYEE Limit 1];
        
        //assert statements
        System.assertEquals(1, recordTypes.size());
                    
        //List to hold Contact and insert contacts
        List<Contact> contacts = new List<Contact>();
        contacts.add(new Contact(FirstName = 'Test', LastName = 'Contact 1', RecordTypeId = recordTypes[0].Id, Employee_Id__c = '12341'));
        contacts.add(new Contact(FirstName = 'Test', LastName = 'Contact 2', RecordTypeId = recordTypes[0].Id, Employee_Id__c = '12342'));
        contacts.add(new Contact(FirstName = 'Test', LastName = 'Contact 3', RecordTypeId = recordTypes[0].Id, Employee_Id__c = '12343'));
        insert contacts;
        
        //Payment Account record
        List<Portfolio__c> payments = new List<Portfolio__c>();
        payments.add(new Portfolio__c(Status__c = Constants.ACTIVE, Card_Holder__c = contacts[0].Id, Portfolio_Owner_Finance_Code__c = '678981', Advisory_Profile__c = advisoryProfile.Id));
        payments.add(new Portfolio__c(Status__c = Constants.ACTIVE, Card_Holder__c = contacts[1].Id, Portfolio_Owner_Finance_Code__c = '678982', Advisory_Profile__c = advisoryProfile.Id));
        payments.add(new Portfolio__c(Status__c = Constants.ACTIVE, Card_Holder__c = contacts[2].Id, Portfolio_Owner_Finance_Code__c = '678983', Advisory_Profile__c = advisoryProfile.Id));
        insert payments;
        
        //List of OSR to be record
        List<OSR__c> osrs = new List<OSR__c>();
        osrs.add(new OSR__c(Request_Type__c = CreditCardConstants.OSR_REQUEST_TYPE_NEW_ABC_CREDIT_CARD, Advisory_Profile__c = advisoryProfile.Id));
        osrs.add(new OSR__c(Request_Type__c = CreditCardConstants.OSR_REQUEST_TYPE_NEW_ABC_CREDIT_CARD, Advisory_Profile__c = advisoryProfile.Id));
        insert osrs;
        
        //Encrypt the card Number
        String encryptNumber1 = CreditCardService.Encrypt('5567356025410226');
        String encryptNumber2 = CreditCardService.Encrypt('5567356025410227');
        String encryptNumber3 = CreditCardService.Encrypt('5567356025410228');
       
        //Credit Card record   
        List<Credit_Card__c> cards = new List<Credit_Card__c>(); 
        cards.add(new Credit_Card__c(Card_Number__c = encryptNumber1, Status__c = CreditCardConstants.CC_STATUS_ACTIVE, Payment_Account__c = payments[0].Id, 
                                        Original_Request__c = osrs[0].Id, Card_Employee_Number__c = 'CARD-1'));
        cards.add(new Credit_Card__c(Card_Number__c = encryptNumber2, Status__c = CreditCardConstants.CC_STATUS_PENDING_DEACTIVATION, Payment_Account__c = payments[1].Id, 
                                        Original_Request__c = osrs[1].Id, Card_Deactivation_Status__c = CreditCardConstants.CC_DEACTIVATION_STATUS_PENDING_RESPONSE, Card_Employee_Number__c = 'CARD-2'));
        cards.add(new Credit_Card__c(Payment_Account__c = payments[2].Id, Card_Employee_Number__c = 'CARD-3'));
        insert cards;
        
        //Check for size of list
        if(cards.size() > 0){
        
            //Start testing from here
            Test.startTest();
    
            //Instantiate Controller
            CreditCardController controller = new CreditCardController(new ApexPages.StandardController(cards[0]));
            
            //Initialize method number for deactivateCreditCard
            CreditCardServiceMockClass.methodNumber = 3;
            
            //Response of deactivateCreditCard request
            HttpService.response = mockController.respond(req);
            
            //Call deactivateCreditCard method
            controller.deactivateCreditCard();
            
            //Query result of Credit Cards
            List<Credit_Card__c> creditCards = [SELECT Status__c, Card_Deactivation_Status__c FROM Credit_Card__c WHERE Card_Number__c =: encryptNumber1];
            
            //assert statements
            System.assertEquals(CreditCardConstants.CC_STATUS_PENDING_DEACTIVATION, creditCards[0].Status__c);
            System.assertEquals(CreditCardConstants.CC_DEACTIVATION_STATUS_PENDING_RESPONSE, creditCards[0].Card_Deactivation_Status__c);
            
            //Instantiate Controller
            controller = new CreditCardController(new ApexPages.StandardController(cards[1]));
            
            //Initialize method number for deactivateCreditCard
            CreditCardServiceMockClass.methodNumber = 3;
            
            //Response of deactivateCreditCard request
            HttpService.response = mockController.respond(req);
            
            //Call deactivateCreditCard method
            controller.deactivateCreditCard();
            
            //Query result of Credit Cards
            creditCards = [SELECT Status__c, Card_Deactivation_Status__c FROM Credit_Card__c WHERE Card_Number__c =: encryptNumber2];
            
            //assert statements
            System.assertEquals(CreditCardConstants.CC_STATUS_DEACTIVATED, creditCards[0].Status__c);
            System.assertEquals(CreditCardConstants.CC_DEACTIVATION_STATUS_DEACTIVATED, creditCards[0].Card_Deactivation_Status__c);
            
            //Instantiate Controller
            controller = new CreditCardController(new ApexPages.StandardController(cards[2]));
            
            try{
        
                //Initialize method number for deactivateCreditCard
                CreditCardServiceMockClass.methodNumber = 10;
                
                //Response of deactivateCreditCard request
                HttpService.response = mockController.respond(req);
                
                //Call deactivateCreditCard method
                controller.deactivateCreditCard();
            
                //Stop test here
                Test.stopTest();
            }catch(Exception e) {
            
            }
        }
        
    }
    
    static testMethod void testUnblockCreditCard() {
        
        //Create provider profile
        Provider_Profile__c providerProfile = new Provider_Profile__c(Name = 'Test');
        insert providerProfile;
        
        //Create ABC profile(Advisory profile)
        ABC_Profile__c advisoryProfile = new ABC_Profile__c(Name = 'Test Advisory Profile',Provider_Profile__c = providerProfile.Id);
        insert advisoryProfile;
        
        //Query result of Record Types
        List<RecordType> recordTypes = [SELECT Id, DeveloperName FROM RecordType WHERE IsActive = true AND 
                                            SobjectType = 'Contact' AND DeveloperName =: Constants.CONTACT_RECORD_TYPE_DEVELOPER_NAME_EMPLOYEE Limit 1];
        
        //assert statements
        System.assertEquals(1, recordTypes.size());
                    
        //List to hold Contact and insert contacts
        List<Contact> contacts = new List<Contact>();
        contacts.add(new Contact(FirstName = 'Test', LastName = 'Contact 1', RecordTypeId = recordTypes[0].Id, Employee_Id__c = '12341', Legal_First_Name__c = 'Test',
                                    Legal_Last_Name__c = 'Contact 1', Personal_Address_Line_1__c = 'Abc Street', Personal_Address_Line_2__c = 'Test', 
                                    Personal_Address_PostalCode__c = '321234', Personal_Address_City__c = 'Dallas', Personal_Address_State__c = 'CA'));
        insert contacts;
        
        //Payment Account record
        List<Portfolio__c> payments = new List<Portfolio__c>();
        payments.add(new Portfolio__c(Status__c = Constants.ACTIVE, Card_Holder__c = contacts[0].Id, Portfolio_Owner_Finance_Code__c = '678981'));
        payments.add(new Portfolio__c(Status__c = Constants.ACTIVE, Card_Holder__c = contacts[0].Id, Portfolio_Owner_Finance_Code__c = '678982'));
        
        insert payments;
        
        //List of OSR to be record
        List<OSR__c> osrs = new List<OSR__c>();
        osrs.add(new OSR__c(Request_Type__c = CreditCardConstants.OSR_REQUEST_TYPE_NEW_ABC_CREDIT_CARD, Advisory_Profile__c = advisoryProfile.Id));
        osrs.add(new OSR__c(Request_Type__c = CreditCardConstants.OSR_REQUEST_TYPE_NEW_ABC_CREDIT_CARD, Advisory_Profile__c = advisoryProfile.Id));
        insert osrs;
        
        //Encrypt the card Number
        String encryptNumber1 = CreditCardService.Encrypt('5567356025410226');
        String encryptNumber2 = CreditCardService.Encrypt('5567356025410227');
            
        //Credit Card record   
        List<Credit_Card__c> cards = new List<Credit_Card__c>(); 
        cards.add(new Credit_Card__c(Card_Number__c = encryptNumber1, Card_Vendor__c = 'Comdata', Status__c = CreditCardConstants.CC_STATUS_DEACTIVATED, Payment_Account__c = payments[0].Id, 
                                      Card_Deactivation_Status__c = CreditCardConstants.CC_DEACTIVATION_STATUS_DEACTIVATED,
                                        Original_Request__c = osrs[0].Id, Card_Employee_Number__c = 'CARD-1'));
        insert cards;

        Credit_Card__c card = new Credit_Card__c(Card_Number__c = encryptNumber2, Card_Vendor__c = 'Comdata', Status__c = CreditCardConstants.CC_STATUS_DEACTIVATED, Payment_Account__c = payments[1].Id, 
                                    Card_Deactivation_Status__c = CreditCardConstants.CC_DEACTIVATION_STATUS_DEACTIVATED,
                                    Original_Request__c = osrs[1].Id, Card_Employee_Number__c = 'CARD-2');
                                    
        insert card;
            
        
        //Check for size of list
        if(cards.size() > 0){
            
            //Start testing from here
            Test.startTest();
    
            //Instantiate Controller
            CreditCardController controller = new CreditCardController(new ApexPages.StandardController(cards[0]));
            
            //Initialize method number for inquiryCreditCard
            CreditCardServiceMockClass.methodNumber = 3;
            
            //Response of inquiryCreditCard request
            HttpService.response = mockController.respond(req);
            
            //Call inquiryCreditCard method
            controller.unBlockCreditCard();
            
            //Query result of OSR
            osrs = [SELECT Status__c FROM OSR__c WHERE Id IN: osrs];
            
            //Query result of Credit Cards
            List<Credit_Card__c> creditCards = [SELECT Status__c, Card_Set_up_Status__c, Card_Deactivation_Status__c FROM Credit_Card__c WHERE Status__c =: CreditCardConstants.CC_STATUS_ACTIVE AND Id IN: cards];
            
            //assert statements
            System.assertEquals('Complete', osrs[0].Status__c);
            System.assertEquals('Active', creditCards[0].Status__c);
            System.assertEquals('Success' , creditCards[0].Card_Set_up_Status__c);
            System.assert(creditCards[0].Card_Deactivation_Status__c == null);
            
            //Update the Card to deactivated
            cards[0].Status__c = CreditCardConstants.CC_STATUS_DEACTIVATED;
            cards[0].Card_Deactivation_Status__c = CreditCardConstants.CC_STATUS_DEACTIVATED;
            cards[0].Card_Set_up_Status__c = CreditCardConstants.CC_SET_UP_STATUS_PENDING_ACTIVATION;
            
            //Bypass all trigger
            Util.BypassAllTriggers = True;
            
            //Update Card
            update cards;
            
            //Update the Portfolio to be deactivated
            payments[0].Status__c = CreditCardConstants.PORTFOLIO_STATUS_DEACTIVATED;
            payments[0].Deactivation_Reason__c = CreditCardConstants.PORTFOLIO_DEACTIVATION_REASON_OVER_AGE_LIMIT;
            payments[0].Warning_Email_Status__c = CreditCardConstants.PORTFOLIO_WARNING_EMAIL_STATUS_PORTFOLIO_DEACTIVATED;
            
            //update the Portfolio
            Update payments;
            
			//Enable all the trigger
            Util.BypassAllTriggers = False;
            
            controller = new CreditCardController(new ApexPages.StandardController(cards[0]));
            
            //Initialize method number for inquiryCreditCard
            CreditCardServiceMockClass.methodNumber = 3;
            
            //Response of inquiryCreditCard request
            HttpService.response = mockController.respond(req);
            
            //Call inquiryCreditCard method
            controller.unBlockCreditCard();
            
            //Query result of Credit Cards
            creditCards = [SELECT Status__c, Card_Set_up_Status__c, Card_Deactivation_Status__c, Payment_Account__c FROM Credit_Card__c WHERE Status__c =: CreditCardConstants.CC_STATUS_ACTIVE AND Id IN: cards];
            
            //assert statements
            System.assertEquals('Active', creditCards[0].Status__c);
            System.assertEquals('Success' , creditCards[0].Card_Set_up_Status__c);
            System.assert(creditCards[0].Card_Deactivation_Status__c == null);
            
            //Query result of Credit Cards
            List<Portfolio__c> portfolios = [SELECT Status__c, Deactivation_Reason__c, Warning_Email_Status__c FROM Portfolio__c WHERE Id =: creditCards[0].Payment_Account__c];
            
            //assert statements
            System.assertEquals('Activated', portfolios[0].Status__c);
            System.assert(portfolios[0].Deactivation_Reason__c == null);
            System.assert(portfolios[0].Warning_Email_Status__c == null);
            
            controller = new CreditCardController(new ApexPages.StandardController(card));
            
            //Initialize method number for inquiryCreditCard
            CreditCardServiceMockClass.methodNumber = 10;
            
            //Response of inquiryCreditCard request
            HttpService.response = mockController.respond(req);
        
            try{
            
                //Call inquiryCreditCard method
                controller.unBlockCreditCard();
                
                //Query result of Credit Cards
                cards = [SELECT Status__c, Card_Set_up_Status__c FROM Credit_Card__c WHERE Card_Number__c =: encryptNumber2];
                
                //assert statements
                System.assertEquals(CreditCardConstants.CC_STATUS_DEACTIVATED, cards[0].Status__c);
                System.assertEquals('Activation Failed', cards[0].Card_Set_up_Status__c);
                
                //Stop test here
                Test.stopTest();
            }catch(Exception e) {
            
            }
        }
    }
    
    //Test Inquiry Credit Card method
    static testMethod void testInquiryCreditCard() {
        
        //Query result of Record Types
        List<RecordType> recordTypes = [SELECT Id, DeveloperName FROM RecordType WHERE IsActive = true AND 
                                            SobjectType = 'Contact' AND DeveloperName =: Constants.CONTACT_RECORD_TYPE_DEVELOPER_NAME_EMPLOYEE Limit 1];
        
        //assert statements
        System.assertEquals(1, recordTypes.size());
                    
        //List to hold Contact and insert contacts
        List<Contact> contacts = new List<Contact>();
        contacts.add(new Contact(FirstName = 'Test', LastName = 'Contact 1', RecordTypeId = recordTypes[0].Id, Employee_Id__c = '12341'));
        insert contacts;
        
        //Payment Account record
        List<Portfolio__c> payments = new List<Portfolio__c>();
        payments.add(new Portfolio__c(Status__c = Constants.ACTIVE, Card_Holder__c = contacts[0].Id, Portfolio_Owner_Finance_Code__c = '678981'));
        insert payments;
        
        //Encrypt the card Number
        String encryptNumber = CreditCardService.Encrypt('5567356025410226');
        
        //Credit Card record   
        List<Credit_Card__c> cards = new List<Credit_Card__c>(); 
        cards.add(new Credit_Card__c(Card_Number__c = encryptNumber, Status__c = CreditCardConstants.CC_STATUS_ACTIVE, Payment_Account__c = payments[0].Id
                                        ));
        insert cards;
        
        //Check for size of list
        if(cards.size() > 0){
        
            //Start testing from here
            Test.startTest();
    
            //Instantiate Controller
            CreditCardController controller = new CreditCardController(new ApexPages.StandardController(cards[0]));
            
            //Initialize method number for inquiryCreditCard
            CreditCardServiceMockClass.methodNumber = 2;
            
            //Response of inquiryCreditCard request
            HttpService.response = mockController.respond(req);
            
            //Call inquiryCreditCard method
            controller.inquireCreditCard();
            
            //Query result of Notes on Credit Card
            List<Note> notes = [SELECT Id FROM Note WHERE ParentId =: cards[0].Id];
            
            //assert statements
            System.assertEquals(1, notes.size());
            
            //Initialize method number for inquiryCreditCard
            CreditCardServiceMockClass.methodNumber = 10;
            
            //Response of inquiryCreditCard request
            HttpService.response = mockController.respond(req);
            
            try{
            
                //Call inquiryCreditCard method
                controller.inquireCreditCard();
            
                //Stop test here
                Test.stopTest();
            }catch(Exception e) {
            
            }
        }
    }
    
    //Test Inquire Card Security Code method
    static testMethod void testInquireCardSecurityCode() {
        
        //Query result of Record Types
        List<RecordType> recordTypes = [SELECT Id, DeveloperName FROM RecordType WHERE IsActive = true AND 
                                            SobjectType = 'Contact' AND DeveloperName =: Constants.CONTACT_RECORD_TYPE_DEVELOPER_NAME_EMPLOYEE Limit 1];
        
        //assert statements
        System.assertEquals(1, recordTypes.size());
                    
        //List to hold Contact and insert contacts
        List<Contact> contacts = new List<Contact>();
        contacts.add(new Contact(FirstName = 'Test', LastName = 'Contact 1', RecordTypeId = recordTypes[0].Id, Employee_Id__c = '12341'));
        contacts.add(new Contact(FirstName = 'Test', LastName = 'Contact 1', RecordTypeId = recordTypes[0].Id, Employee_Id__c = '12342'));
        insert contacts;
        
        //Payment Account record
        List<Portfolio__c> payments = new List<Portfolio__c>();
        payments.add(new Portfolio__c(Status__c = Constants.ACTIVE, Card_Holder__c = contacts[0].Id, Portfolio_Owner_Finance_Code__c = '678981'));
        payments.add(new Portfolio__c(Status__c = Constants.ACTIVE, Card_Holder__c = contacts[1].Id, Portfolio_Owner_Finance_Code__c = '678982'));
        insert payments;
        
        //Encrypt the card Number
        String encryptNumber1 = CreditCardService.Encrypt('5567356025410226');
        String encryptNumber2 = CreditCardService.Encrypt('5567356025410227');
        
        //Credit Card record   
        List<Credit_Card__c> cards = new List<Credit_Card__c>(); 
        cards.add(new Credit_Card__c(Card_Number__c = encryptNumber1, Status__c = CreditCardConstants.CC_STATUS_ACTIVE, Payment_Account__c = payments[0].Id, 
                                        Card_Expiration__c = Date.today().addYears(4), Card_Employee_Number__c = 'CARD-1'));
        cards.add(new Credit_Card__c(Card_Number__c = encryptNumber2, Status__c = CreditCardConstants.CC_STATUS_ACTIVE, Payment_Account__c = payments[1].Id, 
                                        Card_Expiration__c = Date.today().addYears(4), Card_Employee_Number__c = 'CARD-2'));
        insert cards;
        
        //Check for size of list
        if(cards.size() > 0){
        
            //Start testing from here
            Test.startTest();
    
            //Instantiate Controller
            CreditCardController controller = new CreditCardController(new ApexPages.StandardController(cards[0]));
            
            //Initialize method number for inquireCardSecurityCode
            CreditCardServiceMockClass.methodNumber = 5;
            
            //Response of inquireCardSecurityCode request
            HttpService.response = mockController.respond(req);
            
            //Call inquireCardSecurityCode method
            controller.inquireCardSecurityCode();
            
            //Query result of Notes on Credit Card
            List<Note> notes = [SELECT Id FROM Note WHERE ParentId =: cards[0].Id];
            
            //assert statements
            System.assertEquals(1, notes.size());
            
            //Instantiate Controller
            controller = new CreditCardController(new ApexPages.StandardController(cards[1]));
            
            //Initialize method number for inquireCardSecurityCode
            CreditCardServiceMockClass.methodNumber = 10;
            
            //Response of inquireCardSecurityCode request
            HttpService.response = mockController.respond(req);
            
            try{
        
                //Call inquireCardSecurityCode method
                controller.inquireCardSecurityCode();
            
                //Stop test here
                Test.stopTest();
            }catch(Exception e) {
            
            }
        }
    }
}