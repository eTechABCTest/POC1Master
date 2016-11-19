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
 /*
    Purpose:    This class is  ttest class for InstituteRoleController
                
    Create By:  Simplyforce Technology
    
    Created Date:   10/13/2011
    
    Current Version:    v1.1
    
    Revision Log:       v1.0 - Created
                        v1.1 - Modified By - Abhinav Sharma - 11/21/2014 - CR-20141016-7783
*/
@isTest(seeAllData= false)
private class Test_InstituteRoleController {
    
    //test method
    static testmethod void myUnitTest() { 
    
        //Bypass Dupeblocker
        Util.IsTest(true);
        
        //Bypassing all triggers
        Util.byPassAlltriggers = true;
        
        //fecth the existing record type from data base
        List<RecordType> listRecordType = [Select SobjectType, Name, IsActive, Id, DeveloperName From RecordType
                                            where IsActive = true and SobjectType = 'Account' and DeveloperName ='US_Provider' limit 1];
        
        //check for the list size
        if(listRecordType.size() > 0) {
            
            //create the account and contact sample data
            Account account = new Account(Name = 'TestAccount', RecordTypeId = listRecordType[0].Id);
            insert account;
            
            //insert the contact record
            Contact contact = new Contact(LastName = 'TestLastName', AccountId = account.Id, Record_Type__c = listRecordType[0].Name);
            insert contact;
            
            //add a garbage record
            Contact garbageContact = new Contact(LastName = 'TestLastName', AccountId = account.Id, Record_Type__c = 'Garbage');
            insert garbageContact;
            
            //create a garbeage institute role
            Institution_Roles__c  instRole = new Institution_Roles__c(Role__c = 'CEO', Contact__c = garbageContact.Id, Institution__c = account.Id, Record_Type__c = listRecordType[0].Id);
            insert instRole;
            
            //create a garbeage institute role
            Institution_Roles__c instRoleGarbage = new Institution_Roles__c(Contact__c = garbageContact.Id, Institution__c = account.Id, Record_Type__c = listRecordType[0].Id);
            insert instRoleGarbage;
            
            //set current page parameters
            ApexPages.currentPage().getParameters().put('accId', account.Id);
            ApexPages.currentPage().getParameters().put('recordType', listRecordType[0].Name);
            
            //start test from here 
            Test.startTest();
            
            //Enabling trigger again
            Util.byPassAlltriggers = false;
            
            //instantiate controller
            InstituteRoleController controller = new InstituteRoleController(new ApexPages.StandardController(new Institution_Roles__c()));
            
            //call the delete method
            controller.instituteRoleId = instRole.Id;
            controller.deleteInstituteRole();
            
            //call save method
            controller.save();
            
            //stop test here
            Test.stopTest();
        }
    }
}