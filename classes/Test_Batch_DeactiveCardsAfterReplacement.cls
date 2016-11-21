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
 * to a production Test_OSRTriggerHelper
organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest(seeAllData = false)
private class Test_Batch_DeactiveCardsAfterReplacement {
/**
 *  Description     :   Test class for Batch_AddCardsForReplacementRequest
 *
 *  Created By      :   Bhavi Sharma
 *
 *  Created Date    :   01/29/2013
 *
 *  Revision Logs   :   V_1.0 - Created
 *                      V_1.1 - Modified - 12/9/2014 - By Bhavi Sharma
 *
 *  Coverage        :   78%
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
    
    static testMethod void myUnitTest() {
        
        //Query result of Record Types
        List<RecordType> recordTypes = [SELECT Id, DeveloperName FROM RecordType WHERE IsActive = true AND 
                                            SobjectType = 'Contact' AND DeveloperName =: Constants.CONTACT_RECORD_TYPE_DEVELOPER_NAME_EMPLOYEE Limit 1];
        
        //assert statements
        System.assertEquals(1, recordTypes.size());
                    
        //List to hold Contact and insert contacts
        List<Contact> contacts = new List<Contact>();
        contacts.add(new Contact(FirstName = 'Test', LastName = 'Contact 1', RecordTypeId = recordTypes[0].Id, Employee_Id__c = '12341'));
        insert contacts;
        
        //Modified - 12/9/2014 : 
        //Populate portfolio with new fields value
        //Payment Account record
        List<Portfolio__c> payments = new List<Portfolio__c>();
        payments.add(new Portfolio__c(Status__c = Constants.ACTIVE, Card_Holder__c = contacts[0].Id, Portfolio_Owner_Finance_Code__c = '678981'));
        insert payments;
        
        //Encrypt the card Number
        String encryptNumber1 = CreditCardService.Encrypt('5567356025410226');
        
        //Credit Card record   
        List<Credit_Card__c> cards = new List<Credit_Card__c>(); 
        cards.add(new Credit_Card__c(Card_Number__c = encryptNumber1, Payment_Account__c = payments[0].Id, 
                                        Status__c  = CreditCardConstants.CC_STATUS_PENDING_DEACTIVATION, 
                                        Card_Deactivation_Status__c = CreditCardConstants.CC_DEACTIVATION_STATUS_PENDING_REPLACEMENT_ACTIVATION));
        insert cards;
 
        //Test starts here
        Test.startTest();
        
        //Initialize method number for updateCreditCard
        CreditCardServiceMockClass.methodNumber = 1;
        
        //Response of addCreditCard request
        HttpService.response = mockController.respond(req);
            
        //Instantiate batch class here
        Batch_DeactiveCardsAfterReplacement batchDeactivation = new Batch_DeactiveCardsAfterReplacement();
        
        //Code modified - 12/9/2014 - Portfolio_Owner__c -> Card_Holder__c 
        batchDeactivation.cardsOwners = new Set<Id>{payments[0].Card_Holder__c};
        
        database.executeBatch(batchDeactivation, 10);
        
        //Test stops here
        Test.stopTest();
        
        //Query result of Credit Card
        List<Credit_Card__c> creditCards = [SELECT Status__c, Card_Deactivation_Status__c FROM Credit_Card__c WHERE Id IN: cards];
        
        //assert statements
        System.assertEquals(CreditCardConstants.CC_STATUS_DEACTIVATED, creditCards[0].Status__c);
        System.assertEquals(CreditCardConstants.CC_DEACTIVATION_STATUS_DEACTIVATED, creditCards[0].Card_Deactivation_Status__c);
    }
}