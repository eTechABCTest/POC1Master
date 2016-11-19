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
private class Test_CreditCardAlertService {
/**
 *  Purpose         :   This class is used for testing CreditCardAlertService class.
 *
 *  Created By      :   Bhavi Sharma
 *
 *  Created Date    :   09/07/2013
 *
 *  Current Version :   V_1.0 - Created
 *
 **/
    
    //Test method
    static testmethod void testInboundCreateOSR() {
        
        //query result of RecordTypes
        List<RecordType> recordTypes = [SELECT Id, DeveloperName FROM RecordType 
                                            WHERE (SobjectType = 'Account' OR SobjectType = 'Contact') 
                                                    AND (DeveloperName = 'US_Provider' OR DeveloperName = 'Employee') 
                                                    AND IsActive = true ORDER BY SobjectType];
        
        //assert statement
        System.assertEquals(2, recordTypes.size());
        
        //insert Account record
        Account account = new Account(Name = 'Test Account', RecordTypeId = recordTypes[0].Id, Status__c = 'Active');
        insert account;
        
        //insert Contact record
        List<Contact> contacts = new List<Contact>();
        contacts.add(new Contact(FirstName = 'Test', LastName = 'Contact', AccountId = account.Id, RecordTypeId = recordTypes[1].Id, Employee_ID__c = '23456'));
        contacts.add(new Contact(FirstName = 'Test', LastName = 'Contact', AccountId = account.Id, RecordTypeId = recordTypes[1].Id, Employee_ID__c = '55673560'));
        
        insert contacts;
        
        //insert Credit Card Settings record
        Credit_Card_Settings__c ccDefaultSetting = CreditCardConstants.CONFIG_DEFAULT;
        
        //Payment Account record
        List<Portfolio__c> payments = new List<Portfolio__c>();
        payments.add(new Portfolio__c(Status__c = Constants.ACTIVE, Card_Holder__c = contacts[0].Id, Portfolio_Owner_Finance_Code__c = '678981'));
        payments.add(new Portfolio__c(Status__c = Constants.ACTIVE, Card_Holder__c = contacts[1].Id, Portfolio_Owner_Finance_Code__c = '678941'));
        insert payments;
        
        //Encrypt Card Number String
        String encryptCardNumber1 = CreditCardService.Encrypt('5567356025410287');
        String encryptCardNumber2 = CreditCardService.Encrypt('5567356025413426');
        
        //Credit Card record
        List<Credit_Card__c> cards = new List<Credit_Card__c>(); 
        cards.add(new Credit_Card__c(Card_Number__c = encryptCardNumber1, Card_Employee_Number__c = '55673560', Status__c = 'Active', Card_Requested_By__c = contacts[0].Id, Payment_Account__c = payments[0].Id));
        cards.add(new Credit_Card__c(Card_Number__c = encryptCardNumber2, Card_Employee_Number__c = '23456', Status__c = 'Active', Card_Requested_By__c = contacts[0].Id, Payment_Account__c = payments[1].Id));
        insert cards;
                                                                                        
        // Create a new email, envelope object 
        Messaging.InboundEmail email1 = new Messaging.InboundEmail();
        Messaging.InboundEnvelope envelop1 = new Messaging.InboundEnvelope();
        email1.subject = 'This is Fraud credit card.'+ Math.random();
        envelop1.fromAddress = 'user@gmail.com';
        email1.PlainTextBody = 'This is fraud credit card.'+ '\n' + 'Employee ID: 55673560'+ '\n';
        
        // Create a new email, envelope object 
        Messaging.InboundEmail email2 = new Messaging.InboundEmail();
        Messaging.InboundEnvelope envelop2 = new Messaging.InboundEnvelope();
        email2.subject = 'This is Decline credit card.'+ Math.random();
        envelop2.fromAddress = 'user@gmail.com';
        email2.PlainTextBody = 'This is Decline credit card.'+ '\n' + 'Employee ID: 23456'+ '\n';
        
        // Create a new email, envelope object 
        Messaging.InboundEmail email3 = new Messaging.InboundEmail();
        Messaging.InboundEnvelope envelop3 = new Messaging.InboundEnvelope();
        email3.subject = 'This is Declined credit card.'+ Math.random();
        envelop3.fromAddress = 'user@gmail.com';
        email3.PlainTextBody = 'This is Declined credit card.';
        
        // Create a new email, envelope object 
        Messaging.InboundEmail email4 = new Messaging.InboundEmail();
        Messaging.InboundEnvelope envelop4 = new Messaging.InboundEnvelope();
        email4.subject = 'This is Declined credit card.'+ Math.random();
        envelop4.fromAddress = 'user@gmail.com';
        email4.PlainTextBody = 'This is Declined credit card.'+ '\n' + 'Card Number: 5567356025413426'+ '\n';
        
        //Test starts here
        Test.startTest();
        
        // call the class and test it with the data in the testMethod
        CreditCardAlertService creditAlertSrvc = new CreditCardAlertService();
        creditAlertSrvc.handleInboundEmail(email1, envelop1);  
        creditAlertSrvc.handleInboundEmail(email2, envelop2);  
        creditAlertSrvc.handleInboundEmail(email3, envelop3);  
        creditAlertSrvc.handleInboundEmail(email4, envelop4);  
        
        //query Result of OSR record
        List<OSR__c> oSRs = [SELECT Id, Alert_Message__c FROM OSR__c WHERE Alert_Summary__c =: email1.subject OR Alert_Summary__c =: email2.subject
                                    OR Alert_Summary__c =: email3.subject OR Alert_Summary__c =: email4.subject];
        
        //assert statement
        System.assertEquals(2, oSRs.size());
        
        //Test stops here
        Test.stopTest();
    }
}