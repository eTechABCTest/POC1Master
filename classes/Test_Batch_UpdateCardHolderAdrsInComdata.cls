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
private class Test_Batch_UpdateCardHolderAdrsInComdata {
/**
 *  Description     :   Test class for Batch_UpdateCardHolderAdrsInComdata
 *
 *  Created By      :   Bhavi Sharma
 *
 *  Created Date    :   10/21/2013
 *
 *  Revision Logs   :   V_1.0 - Created
 *
 *  Coverage        :
 *
 **/
    static testmethod void testUpdateContactAddressInComdata() {
        
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
        
        //Payment Account record
        List<Portfolio__c> payments = new List<Portfolio__c>();
        payments.add(new Portfolio__c(Status__c = Constants.ACTIVE, Card_Holder__c = contacts[0].Id, Portfolio_Owner_Finance_Code__c = '678981'));
        payments.add(new Portfolio__c(Status__c = Constants.ACTIVE, Card_Holder__c = contacts[1].Id, Portfolio_Owner_Finance_Code__c = '678941'));
        insert payments;
        
        //Credit Card record   
        List<Credit_Card__c> cards = new List<Credit_Card__c>(); 
        cards.add(new Credit_Card__c(Card_Number__c = '5567356025410226', Status__c = 'Active', Card_Requested_By__c = contacts[0].Id, Payment_Account__c = payments[0].Id, Card_Employee_Number__c = 'CARD-1'/*, Override_Card_Limit__c = 1000*/));
        cards.add(new Credit_Card__c(Card_Number__c = '5567888885410288', Status__c = 'Active', Card_Requested_By__c = contacts[1].Id, Payment_Account__c = payments[1].Id, Card_Employee_Number__c = 'CARD-2'/*, Override_Card_Limit__c = 1000*/));
        insert cards;
        
        //update contact
        Contacts[0].Personal_Address_Line_1__c = '710 College Ten Road';
        Contacts[0].Personal_Address_State__c = 'CA';
        Contacts[0].Personal_Address_City__c = 'Santa Cruz';
        Contacts[0].Personal_Address_PostalCode__c = '95064';
        update contacts[0];
        
        //update contact
        Contacts[1].Personal_Address_State__c = 'CA';
        Contacts[1].Personal_Address_City__c = 'Santa Cruz';
        Contacts[1].Personal_Address_PostalCode__c = '95064';
        update contacts[1];
        
        //Test starts here
        Test.startTest();

        //Batch insatance of Batch_UpdateCardHolderAddressInComdata and execute batch
        Batch_UpdateCardHolderAddressInComdata bc = new Batch_UpdateCardHolderAddressInComdata();
        Database.executeBatch(bc, 200);
        
        //Test stops here
        Test.stopTest();
        
        //query result of contacts
        contacts = [SELECT Id, Personal_Address_Updated__c FROM Contact WHERE Id IN: contacts];
        
        //assert statements
        System.assertEquals(false, contacts[0].Personal_Address_Updated__c);
        System.assertEquals(false, contacts[1].Personal_Address_Updated__c);
    }
}