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
@isTest(seeAllData=false)
private class Test_LeadTrigger {

/**
 *  Purpose         :   Test class for Lead trigger
 *
 *  Created By      :   Bhavi Sharma    
 *
 *  Created Date    :   01/31/2014  
 *
 *  Revision Logs   :   V_1.0 - Created
 *                  :   V_1.1 - Ajit Surana - 4/30/2014 - CR-20140409-5021 - testCopyAddressToContactOnConversion method modified.
 *
 *  Coverage        :   
 *
 **/
    
    static testMethod void testCopyAddressToContactOnConversion() {
        
        //Create Test data for Lead
        Lead lead = new Lead(LastName = 'Testing', Company = 'Testing', Address_Line_1__c = 'Testing 604', City__c = 'Dallas', 
                                State_Province__c = 'CA', Country__c = 'USA', Postal_Code__c = '12345');
        insert lead;
        
        //Convert lead record
        Database.LeadConvert lc = new Database.LeadConvert();
        lc.setLeadId(lead.Id);
        
        //Setting lead converted status
        lc.setConvertedStatus('Vetted');
        
        //Start Testing from here
        Test.startTest();
        
        //Convert Lead Record
        Database.LeadConvertResult lCR = Database.convertLead(lc);
        
        //Assret resultd
        System.assert(lCR.isSuccess());
        
        //Fetch lead information
        lead = [Select IsConverted, ConvertedContactId, Address_Line_1__c, City__c, State_Province__c, Country__c, Postal_Code__c from Lead where Id =: lead.Id];
        
        //Assert for the results
        System.assert(lead.IsConverted);
        System.assert(lead.ConvertedContactId != null);
        
        //Fetch contact data and assert for the address variables
        Contact contact = [Select Primary_Address_Line_1__c, Primary_City__c, Primary_State_Province__c, Primary_Country__c, 
                                    Primary_Postal_Code__c from Contact where Id =: lead.ConvertedContactId];
        System.assertEquals(lead.Address_Line_1__c, contact.Primary_Address_Line_1__c);
        System.assertEquals(lead.City__c, contact.Primary_City__c);
        System.assertEquals(lead.State_Province__c, contact.Primary_State_Province__c);
        System.assertEquals(lead.Country__c, contact.Primary_Country__c);
        System.assertEquals(lead.Postal_Code__c, contact.Primary_Postal_Code__c);
        
        //Stop test here
        Test.stopTest();
        
        //Added by Ajit Surana - 4/30/2014 - CR-20140409-5021
        //Create Test data for Lead passing "null" for Address_Line_1__c and Postal_Code__c fields
        Lead testLead = new Lead(LastName = 'Test', Company = 'Test Account', Address_Line_1__c = null, City__c = 'Dallas', 
                                State_Province__c = 'CA', Country__c = 'USA', Postal_Code__c = null);
        insert testLead;
        
        //Convert lead record
        Database.LeadConvert lc1 = new Database.LeadConvert();
        lc1.setLeadId(testLead.Id);
        lc1.setConvertedStatus('Vetted');
        
        //Convert Lead Record
        Database.LeadConvertResult lCR1 = Database.convertLead(lc1);
        
        //Assert resultd
        System.assert(lCR1.isSuccess());
        
        //Fetch lead information
        testLead = [Select IsConverted, ConvertedContactId, Address_Line_1__c, City__c, State_Province__c, Country__c, Postal_Code__c from Lead where Id =: testLead.Id];
        
        //Assert for the results
        System.assert(testLead.IsConverted);
        System.assert(testLead.ConvertedContactId != null);
        
        //Fetch contact data and assert for the address variables
        Contact contact1 = [Select Primary_Address_Line_1__c, Primary_City__c, Primary_State_Province__c, Primary_Country__c, 
                                    Primary_Postal_Code__c from Contact where Id =: testLead.ConvertedContactId];
        
        //Assert for the resuts
        System.assertEquals(null, contact1.Primary_Address_Line_1__c);
        System.assertEquals(testLead.City__c, contact1.Primary_City__c);
        System.assertEquals(testLead.State_Province__c, contact1.Primary_State_Province__c);
        System.assertEquals(testLead.Country__c, contact1.Primary_Country__c);
        System.assertEquals(null, contact1.Primary_Postal_Code__c);
        
    }
}