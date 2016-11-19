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
private class Test_BatchIdentifySFComdataMismatching {
	
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
    }
	
    //Test Inquiry Credit Card method
    static testMethod void testInquiryCreditCard() {
        
        //Start testing from here
        Test.startTest();

		//Initialize method number for inquiryCreditCard
        CreditCardServiceMockClass.methodNumber = 2;
        
        //Response of inquiryCreditCard request
        HttpService.response = mockController.respond(req);
        
        //Batch_IdentifySFComdataMismatching
        Batch_IdentifySFComdataMismatching batchJob = new Batch_IdentifySFComdataMismatching();
        Database.executeBatch(batchJob, 1);
        
        //Start testing from here
        Test.stopTest();
        
        //Assert for the results
        List<Credit_Card__c> cards = [Select Comdata_Status__c from Credit_Card__c limit 1];
        
        System.assertEquals(cards[0].Comdata_Status__c, 'A');
    }
}