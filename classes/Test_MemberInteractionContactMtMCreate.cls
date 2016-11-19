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
private class Test_MemberInteractionContactMtMCreate {
/**
*   Purpose         :   This class is test class for MemberInteractionContactMtM_Create class.
*
*   Created By       :  Ajit Surana
*
*   Created Date    :   11/17/2014
*
*   Current Version :   v1.0
*
*   Revision Logs   :   v1.0 - Created - CR-20141106-8005
*						V1.1 - Modified By - Mahendra Swarnkar - 11/19/2015 - CR-20151119-9398 - Updated the "test_CreateMemberInteractionContactMtM" method, to modify the query on Contacts record, so that the contacts are returned in the same order as created. 
**/
    static testMethod void test_CreateMemberInteractionContactMtM() {
        
        //By passing Dupeblocker
        Util.IsTest(true);
        
        //Bypassing all the trigger when creating test data
        Util.BypassAllTriggers = True;
        
        //Insert account
        Account acc = new Account(Name = 'TestAcc', Account_Formal_Name__c = 'TestAcc');
        insert acc;
        
        //Create a list of Contact records
        List<Contact> conList = new List<Contact>();
        
        //create new Contact
        Contact con1 = new Contact(FirstName = 'Test', LastName = 'Contact1', Email = 'test1@test.com', Title = 'Test User 1',
                                    Phone = '21212121', AccountId = acc.Id);
        
        //Create new Contact
        Contact con2 = new Contact(FirstName = 'Test', LastName = 'Contact2', Email = 'test2@test.com', Title = 'Test User 2',
                                    Phone = '31313131', AccountId = acc.Id);
        
        //Create new Contact
        Contact con3 = new Contact(FirstName = 'Test', LastName = 'Contact3', Email = 'test3@test.com', Title = 'Test User 3',
                                    Phone = '41414141', AccountId = acc.Id);
        
        //Create new Contact
        Contact con4 = new Contact(FirstName = 'Test', LastName = 'Contact4', Email = 'test4@test.com', Title = 'Test User 4',
                                    Phone = '51515151', AccountId = acc.Id);
        
        conList.add(con1);
        conList.add(con2);
        conList.add(con3);
        conList.add(con4);
        
        //Insert Contacts
        insert conList;
        
        //Create test Syndicated Study record
        Syndicated_Study__c testSStudy = new Syndicated_Study__c(Name = 'Test RS Record', Year__c = '2014');
        insert testSStudy;
        
        //Create test RSI record
        Syndicated_Research_Interaction__c testRSI = new Syndicated_Research_Interaction__c (Name = 'Test RSI Record', Primary_Study__c = testSStudy.Id,
                                                                                                Institution__c = acc.Id);
                                                                                                
        //Insert RSI record
        insert testRSI;
            
        //start test from here
        Test.startTest();
        
        PageReference PageRef = Page.MemberInteractionContactMtM_Create_Page;
        Test.setCurrentPage(PageRef);
        ApexPages.currentPage().getParameters().put('parentId',testRSI.id);
        
        /*PageReference pageRef = Page.MemberInteractionContactMtM_Create_Page;
        pageRef.getParameters().put('parentId',testSStudy.id);
        Test.setCurrentPage(pageRef);*/
        
        //Calling Class Constructor
        MemberInteractionContactMtM_Create controller = new MemberInteractionContactMtM_Create();
        
        //Setting page reference parameter
        //Test.setCurrentPageReference(new PageReference('Page.MemberInteractionContactMtM_Create_Page'));
        
        //Modified By - Mahendra Swarnkar - 11/19/2015 - CR-20151119-9398
        //Query through Contact records
        conList = [SELECT Id, Email, Phone, Title FROM Contact WHERE AccountId =: acc.Id ORDER BY LastName ASC];
        
        //Assert for results
        System.assertEquals(conList.size(), 4);
        System.assertEquals(conList[0].Title, 'Test User 1');
        System.assertEquals(conList[0].Phone, '21212121');
        System.assertEquals(conList[0].Email, 'test1@test.com');
        
        //Calling controller methods
        controller.doSave();
        controller.first();
        controller.setSortDirection('ASC');
        controller.last();
        controller.previous();
        controller.next();
        controller.doCancel();
        
        //Test stops here
        Test.stopTest();
    }   
}