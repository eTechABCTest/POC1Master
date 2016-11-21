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
private class Test_AddCaseCategoriesToCase {
/*
    Purpose:    This class is to search the case categories and add those to Case record.(CR-20111208-267)
                
    Create By:  Simplyforce Technology
    
    Created Date:   12/13/2011
    
    Current Version:    v1.0
    
    Revision Log:       
*/
    static testmethod void myUnitTest() { 
        //Bypass Dupeblocker
        Util.IsTest(true);
        Util.byPassAllTriggers = true;
        
        //Fetch Expert Center record type
        List<RecordType> expertCenters = [Select Id from RecordType 
                                          where DeveloperName = 'Expert_Center' AND SObjectType = 'Case' AND IsActive = true];
        
        //Assert for results
        System.assertEquals(1, expertCenters.size());
        
         //Create an institution
        Account acct = TestUtilities.CreateNewAccount(false);
        
        //Insert accounts
        insert acct;
        
        //Create a contact
        Contact contact = TestUtilities.CreateNewContact(true);
        
        //Create a sample case record
        Case aCase_1 = new Case(RecordTypeId = expertCenters[0].Id, Origin = 'Email', Subject = 'Test 1', Status = '01-New',
                                Description = 'test 1', AccountId = acct.Id, Priority = 'Low', ContactId = contact.Id);
        
        insert aCase_1;
        
        //delete existing case category records to test the fresh results
        delete [Select Id from Case_Category__c];
        
        //Create test Category record
        Case_Category__c existingCaseCategory = new Case_Category__c(Category1__c = 'existingCaseCategory');
        insert existingCaseCategory;
        
        Case_Category__c newCaseCategory = new Case_Category__c(Category1__c = 'newCaseCategory');
        insert newCaseCategory;
        
        //insert Case_Category_MTM__c record
        insert new Case_Category_MTM__c(Case__c = aCase_1.Id, Case_Category__c = existingCaseCategory.Id);
        
        //Set case id parameter in URL
        ApexPages.currentPage().getParameters().put('caseId', aCase_1.Id);
        
        //start test from here
        Test.startTest();
        
        Util.byPassAllTriggers = false;
        
        //instantiate controller
        AddCaseCategoriesToCase controller = new AddCaseCategoriesToCase();
        
        //assert for the constructor properties
        System.assert(controller.caseId != null);
        
        //set serach text and call search method
        controller.searchText = '*CaseCategory*';
        controller.searchCaseCategoriesByName();
        
        //assert the search results
        System.assertEquals(1, controller.listCaseCategoryWrapper.size());
        System.assertEquals(newCaseCategory.Id, controller.listCaseCategoryWrapper[0].caseCategory.Id);
        
        //Add search result on case
        controller.listCaseCategoryWrapper[0].selected = true;
        controller.createCaseCategoriesMTM();
        
        //assert the result
        Integer counter = [Select count() from Case_Category_MTM__c where Case__c =: aCase_1.Id AND Case_Category__c =: newCaseCategory.Id];
        System.assertEquals(1, counter);
        
        //stop test here
        Test.stopTest();
    }
}