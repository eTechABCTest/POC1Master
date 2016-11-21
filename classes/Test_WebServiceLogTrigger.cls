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
 **/
@isTest(seeAllData=false)
private class Test_WebServiceLogTrigger {
	
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
	
    static testmethod void testdeActivateCardANDPortfolio() {
        
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
        
        //Start testing from here
        Test.startTest();
		
        //Instantiate Controller
        CreditCardController controller = new CreditCardController(new ApexPages.StandardController(cards[0]));
        
        //Initialize method number for inquiryCreditCard
        CreditCardServiceMockClass.methodNumber = 2;
        
        //Call inquiryCreditCard method
        controller.inquireCreditCard();
        
        //Query result of Notes on Credit Card
        List<Note> notes = [SELECT Id FROM Note WHERE ParentId =: cards[0].Id];
        
        //assert statements
        //System.assertEquals(1, notes.size());
        
        //Query result of Notes on Credit Card
        List<Web_Service_Log__c> wSLogs = [SELECT Id, Response_Message__c, Credit_Card__C FROM Web_Service_Log__c WHERE Credit_Card__C =: cards[0].Id limit 1];
        
        //Debug
        System.debug('@@@@@Credit Card:::'+ wSLogs[0].Credit_Card__C+ ':::Response message:::' +wSLogs[0].Response_Message__c);
        
        //Initialize method number for inquiryCreditCard
        CreditCardServiceMockClass.methodNumber = 13; 
        
        //Response of inquiryCreditCard request
        HttpService.response = mockController.respond(req);
        
        try{
        
            //Call inquiryCreditCard method
            controller.inquireCreditCard();
        
            //Stop test here
            Test.stopTest();
            
        } catch(Exception e) {
        	
            //assert statements
        	System.assertEquals( '99901:00862,EMPLOYEE NUMBER NOT FOUND REF CUSTID: CUST2, REF USERID: ADVISORYWS', e.getMessage());
            
            //Query through Credit card records
            List<Credit_Card__c> cCards = [select Id, Status__c, Card_Deactivation_Reason__c, Payment_Account__r.Status__c, Payment_Account__r.Deactivation_Reason__c from Credit_Card__c where Id =: cards[0].Id];
            System.assertEquals(CreditCardConstants.PORTFOLIO_STATUS_DEACTIVATED, cCards[0].Payment_Account__r.Status__c);
            System.assertEquals(CreditCardConstants.EMPLOYEE_NOT_FOUND_IN_COMDATA, cCards[0].Payment_Account__r.Deactivation_Reason__c);
            System.assertEquals(CreditCardConstants.CC_STATUS_DEACTIVATED, cCards[0].Status__c);
            System.assertEquals(CreditCardConstants.EMPLOYEE_NOT_FOUND_IN_COMDATA, cCards[0].Card_Deactivation_Reason__c);
        }
    }
}