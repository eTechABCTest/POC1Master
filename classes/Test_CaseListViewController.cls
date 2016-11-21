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
private class Test_CaseListViewController{
/**
 *  Purpose         :   This class is used to test the CaseCommentController class
 *
 *  Created By      :   Victor Hanson
 *
 *  Created Date    :   02/21/2014
 *
 *  Revision Log    :   v1.0 - Created
 *                      v1.1 - Modified By - Abhinav Sharma - 06/09/2016 - CR-20150202-8627
 * 
 *  Coverage Log    :   V1.0 - CaseListViewController - 73%
 *                      V1.1 - CaseListViewController - 96%
 **/
    
    //Modified By - Abhinav Sharma - 06/09/2016 - CR-20150202-8627
    /** 
     * Description : Static method to create the member support records for testing purpose
    **/
    private static list<Site_Issue__c> createMemberSupportRecords(Id projectId, Id contactId, boolean createAndInsert) {
        
        //Create a member support record. RType = 'Crimson Support Request' to make it create a case
        Site_Issue__c memberSupport_Open_Status_New = new Site_Issue__c(Status__c = '01- Issue Reported', 
                                                                        Visible_In_Portal__c = true,
                                                                        Category__c = 'Test-Category', 
                                                                        Data_Load_Type__c = Constants.HISTORICAL_RELOAD,
                                                                        RecordTypeId = Constants.RECORD_TYPE_ID_SITE_ISSUE_CCA_SUPPORT_REQUEST, 
                                                                        Project__c = projectId, 
                                                                        CCC_Date_Observed__c = System.Today(), 
                                                                        Site_Issue_Created_Date__c = System.now().addDays(-54), 
                                                                        Data_Load_Period_End__c = Date.Today().addDays(-62),
                                                                        Data_Load_Period_Begin__c = Date.today(),
                                                                        Site_Issue_Close_Date__c = null, 
                                                                        Files_Received__c = Date.today(),
                                                                        Tier__c = Constants.SITE_ISSUE_TIER_II,
                                                                        Site_Issue_Short_Description__c = 'subject',
                                                                        Crimson_Site_Issue_Description__c = 'description',
                                                                        Current_Results__c = 'test',
                                                                        Expected_Results__c = 'expected result',
                                                                        Interaction_Type__c = 'interactin type',
                                                                        Site_Issue_Priority__c = 'High',
                                                                        Reported_By__c = contactId,
                                                                        Steps_to_Reproduce__c = 'steps to repro');
        Site_Issue__c memberSupport_Open_Status_ResponseNeeded = new Site_Issue__c(Status__c = '03.1 - Member Input Required', 
                                                                                   Visible_In_Portal__c = true,
                                                                                   Category__c = 'Test-Category', 
                                                                                   Data_Load_Type__c = Constants.HISTORICAL_RELOAD,
                                                                                   RecordTypeId = Constants.RECORD_TYPE_ID_SITE_ISSUE_CCA_SUPPORT_REQUEST, 
                                                                                   Project__c = projectId, 
                                                                                   CCC_Date_Observed__c = System.Today(), 
                                                                                   Site_Issue_Created_Date__c = System.now().addDays(-54), 
                                                                                   Data_Load_Period_End__c = Date.Today().addDays(-62),
                                                                                   Data_Load_Period_Begin__c = Date.today(), 
                                                                                   Files_Received__c = Date.today(),
                                                                                   Site_Issue_Close_Date__c = null,
                                                                                   Tier__c = Constants.SITE_ISSUE_TIER_II,
                                                                                   Site_Issue_Short_Description__c = 'subject',
                                                                                   Crimson_Site_Issue_Description__c = 'description',
                                                                                   Current_Results__c = 'test',
                                                                                   Expected_Results__c = 'expected result',
                                                                                   Interaction_Type__c = 'interactin type',
                                                                                   Site_Issue_Priority__c = 'High',
                                                                                   Reported_By__c = contactId,
                                                                                   Steps_to_Reproduce__c = 'steps to repro');
        Site_Issue__c memberSupport_Open_Status_Closed = new Site_Issue__c(Status__c = '06 - Issue Resolved - Ticket Closed', 
                                                                           Visible_In_Portal__c = true,
                                                                           Category__c = 'Test-Category', 
                                                                           Data_Load_Type__c = Constants.HISTORICAL_RELOAD,
                                                                           RecordTypeId = Constants.RECORD_TYPE_ID_SITE_ISSUE_CCA_SUPPORT_REQUEST, 
                                                                           Project__c = projectId, 
                                                                           Member_Facing_Resolution_Summary__c = 'issue resolved!',
                                                                           CCC_Date_Observed__c = System.Today(), 
                                                                           Site_Issue_Created_Date__c = System.now().addDays(-54), 
                                                                           Site_Issue_Close_Date__c = System.now().addDays(8), 
                                                                           Data_Load_Period_End__c = Date.Today().addDays(-62),
                                                                           Data_Load_Period_Begin__c = Date.today(), 
                                                                           Files_Received__c = Date.today(),
                                                                           Tier__c = Constants.SITE_ISSUE_TIER_II,
                                                                           Site_Issue_Short_Description__c = 'subject',
                                                                           Crimson_Site_Issue_Description__c = 'description',
                                                                           Current_Results__c = 'test',
                                                                           Expected_Results__c = 'expected result',
                                                                           Interaction_Type__c = 'interactin type',
                                                                           Site_Issue_Priority__c = 'High',
                                                                           Reported_By__c = contactId,
                                                                           Steps_to_Reproduce__c = 'steps to repro');
        Site_Issue__c memberSupport_NotVisibleInPortal = new Site_Issue__c(Status__c = '01- Issue Reported', 
                                                                            Visible_In_Portal__c = false,
                                                                            Category__c = 'Test-Category', 
                                                                            Data_Load_Type__c = Constants.HISTORICAL_RELOAD,
                                                                            RecordTypeId = Constants.RECORD_TYPE_ID_SITE_ISSUE_CCA_SUPPORT_REQUEST, 
                                                                            Project__c = projectId, 
                                                                            CCC_Date_Observed__c = System.Today(), 
                                                                            Site_Issue_Created_Date__c = System.now().addDays(-54), 
                                                                            Data_Load_Period_End__c = Date.Today().addDays(-62),
                                                                            Data_Load_Period_Begin__c = Date.today(), 
                                                                            Files_Received__c = Date.today(),
                                                                            Site_Issue_Close_Date__c = null,
                                                                            Tier__c = Constants.SITE_ISSUE_TIER_II,
                                                                            Site_Issue_Short_Description__c = 'subject',
                                                                            Crimson_Site_Issue_Description__c = 'description',
                                                                            Current_Results__c = 'test',
                                                                            Expected_Results__c = 'expected result',
                                                                            Interaction_Type__c = 'interactin type',
                                                                            Site_Issue_Priority__c = 'High',
                                                                            Reported_By__c = contactId,
                                                                            Steps_to_Reproduce__c = 'steps to repro');
        
        //Adding records instance to the list of member supports
        list<Site_Issue__c> memSupportList = new list<Site_Issue__c> { memberSupport_Open_Status_New, 
                                                                        memberSupport_Open_Status_ResponseNeeded, 
                                                                        memberSupport_Open_Status_Closed,
                                                                        memberSupport_NotVisibleInPortal};
        
        //Checking for boolean flag value and then accordingly inserting the list of member supports
        if (createAndInsert) 
            insert memSupportList;
        
        //Retrun list of member support records
        return memSupportList;
    }
    
    //Modified By - Abhinav Sharma - 06/09/2016 - CR-20150202-8627
    /** Description : Method to test out the functionality of switching in between different types of views 
     *                  on "Crimson Community" home page in the context of a community user. 
    **/
    static testMethod void testCaseView_AllProjects() {
        
        //Bypass Dupeblocker and triggers for test data creation purpose
        Util.IsTest(true);
        Util.BypassAllTriggers = true;
        Util.isTesting = true;
        
        //Create test data for the Sync Fields custom setting that syncs Case -> Mem Support fields
        TestUtilities.createSyncFields();
        
        //Create a Contact that will act like a community user contact
        Contact communityContact = TestUtilities.CreateNewContact(false);
        communityContact.PT_Community_Case_View__c = Constants.COMMUNITY_CASE_VIEW_ALL_PROJECT_CASES;
        communityContact.Email = 'testusername@abc.com';
        insert communityContact;
        
        //Assert for the results
        System.assert(communityContact != null);
        
        //create a community user
        Profile portalProfile = [SELECT Id FROM Profile WHERE UserLicense.Name like '%High Volume Customer Portal' LIMIT 1];
        User communityUser = TestUtilities.CreateNewUser(portalProfile, false);
        communityUser.ContactId = communityContact.Id;
        insert communityUser;
        
        //Assert for the results
        System.assert(communityUser != null);
        
        //Create a project
        Project__c project = TestUtilities.createProject(true);
        
        //Assert for the results
        System.assert(project != null);
        
        //Create a project role
        Project_Role__c pRole = new Project_Role__c(Name='Test',
                                                   Project_Type__c = 'CCC',
                                                   Role__c = 'Implementation Leader',
                                                   Contact__c = communityContact.Id,
                                                   Project__c = project.Id);
        insert pRole;
        
        //Assert for the results
        System.assert(pRole != null);
        
        //Enable triggers again
        Util.BypassAllTriggers = false;
        
        //Create 4 (2 New & 2 Response Needed) open cases and 2 closed cases
        list<Site_Issue__c> memSupportList = new list<Site_Issue__c>();
        memSupportList.addAll(createMemberSupportRecords(project.Id, communityContact.Id, false));
        memSupportList.addAll(createMemberSupportRecords(project.Id, communityContact.Id, false));
        insert memSupportList;
        
        //Assert for the results
        System.assert(memSupportList != null);
        
        //Disabling triggers again
        Util.BypassAllTriggers = true;
        
        //get the cases that should be closed and update their status NOTE: this is only needed prior to release 34
        //because the new case closed status of '90-closed' is not in the case status picklist in prod
        list<Case> casesToClose = [SELECT Id, Status FROM Case WHERE Status = '90-Closed'];
        
        //Loop through case records
        if(casesToClose != null && casesToClose.size() > 0) {
            for (Case c : casesToClose) c.Status = 'Closed';
                update casesToClose;
        }
        
        //Start the test
        Test.startTest();
        
        //Run as "Community User" context
        system.runAs(communityUser) {
        
            //Set the page reference
            PageReference pageRef = Page.Case_ListView;
            test.setCurrentPage(pageRef);
            
            //Instantiate the controller and set the page
            CaseListViewController controller = new CaseListViewController();
            controller.Contact = communityContact;
            controller.ContactId = communityContact.Id;
            
            //Assertions
            system.assert(controller.viewPicklist.size() > 0);
            system.assertEquals(controller.LIST_VIEW_ALL_OPEN_CASES, controller.fieldSetAPIName, 
                                'The default view should be LIST_VIEW_ALL_OPEN_CASES');
            system.assertEquals(true, controller.selectedTileName.equalsIgnoreCase('Response Needed'),
                                'Response Needed tile should be selected by default when there are records that require member response.');
            system.assertEquals(2, controller.getCaseList().size());
            
            //Change the view
            controller.fieldSetAPIName = controller.LIST_VIEW_ALL_CLOSED_CASES;
            
            //Refresh the list of projects
            controller.refresh();
            
            //Assertions
            system.assertEquals(2, controller.getCaseList().size());
            
            //Change the view
            controller.fieldSetAPIName = controller.LIST_VIEW_ALL_OPEN_CASES;
            controller.selectedTileName = 'ALL';
            
            //Refresh the list of projects
            controller.refresh();
            
            //Assertions
            system.assertEquals(4, controller.getCaseList().size());
            
            //Change the view
            controller.fieldSetAPIName = controller.LIST_VIEW_MY_OPEN_CASES;
            
            //Refresh the list of projects
            controller.refresh();
            
            //Assertions
            system.assertEquals(4, controller.getCaseList().size());
            
            //Toggle the sort direction
            controller.SortExpression = 'CaseNumber';
            system.assertEquals('DESC', controller.sortDirection);
            
            //get the pageRef for a new case
            PageReference newCasePg = controller.newCase();
            system.assertNotEquals(null, newCasePg);
            controller.search();
            controller.redirectToTimeout();
        }
        
        //Test will stop here
        Test.stopTest();
    }
    
    //Modified By - Abhinav Sharma - 06/09/2016 - CR-20150202-8627
    /** Description : Method to test out various functionality which a community user will have and utilize on
     *                  the  "Crimson Community" home page.  
    **/
    static testMethod void testCaseView_MyProjects() {
        
        //Bypass Dupeblocker
        Util.IsTest(true);
        Util.BypassAllTriggers = true;
        Util.isTesting = true;
        
        //Create test data for the Sync Fields custom setting that syncs Case -> Mem Support fields
        TestUtilities.createSyncFields();
        
        //Create a Contact that will act like a community user contact
        Contact communityContact_Mike = TestUtilities.CreateNewContact(false);
        communityContact_Mike.PT_Community_Case_View__c = Constants.COMMUNITY_CASE_VIEW_MY_CASES;
        communityContact_Mike.Email = 'mike@abc.com';
        
        //Create a Contact that will act like a community user contact
        Contact otherContact_Bob = TestUtilities.CreateNewContact(false);
        
        //Adding contact instances into the list and performing an insert operation over them
        list<Contact> contacts = new list<Contact> { communityContact_Mike, otherContact_Bob };
        insert contacts;
        
        //Asserting for the results
        System.assert(contacts != null);
        System.assertEquals(2, contacts.size());
        
        //Create a project
        Project__c project = TestUtilities.createProject(true);
        
        //Assert for the results
        System.assert(project != null);
        
        //Create a project role
        Project_Role__c pRole = new Project_Role__c(Name='Test',
                                                   Project_Type__c = 'CCC',
                                                   Role__c = 'Implementation Leader',
                                                   Contact__c = communityContact_Mike.Id,
                                                   Project__c = project.Id);
        insert pRole;
        
        //Assert for the results
        System.assert(pRole != null);
        
        //create a community user
        Profile portalProfile = [SELECT Id FROM Profile WHERE UserLicense.Name like '%High Volume Customer Portal' LIMIT 1];
        User communityUser_Mike = TestUtilities.CreateNewUser(portalProfile, false);
        communityUser_Mike.ContactId = communityContact_Mike.Id;
        insert communityUser_Mike;
        
        //Assert for the results
        System.assert(communityUser_Mike != null);
        
        //Enabling triggers again
        Util.BypassAllTriggers = false;
        
        //Create 4 (2 New & 2 Response Needed) open cases  and 2 closed cases
        list<Site_Issue__c> memSupportList = new list<Site_Issue__c>();
        memSupportList.addAll(createMemberSupportRecords(project.Id, communityContact_Mike.Id, false));
        memSupportList.addAll(createMemberSupportRecords(project.Id, communityContact_Mike.Id, false));
        insert memSupportList;
        
        //Assert for the results
        System.assert(memSupportList != null);
        
        //Disabling triggers
        Util.BypassAllTriggers = true;
        
        //get the cases that should be closed and update their status NOTE: this is only needed prior to release 34
        //because the new case closed status of '90-closed' is not in the case status picklist in prod
        list<Case> casesToClose = [SELECT Id, Status, Subject, Visible_in_Portal__c, contactId FROM Case 
                                    WHERE Status = '90-Closed'];
        
        //Checking for the size value
        if(casesToClose != null && casesToClose.size() > 0) {
            for (Case c : casesToClose) {
                c.Status = 'Closed';    
                c.Subject = 'test';    
            }
            
            //update cases
            update casesToClose;
        }
        
        //Start the test
        Test.startTest();
        
        //Run as community user
        system.runAs(communityUser_Mike) {
        
            //Set the page reference
            PageReference pageRef = Page.Case_ListView;
            test.setCurrentPage(pageRef);
            
            //Instantiate the controller and set the page
            CaseListViewController controller = new CaseListViewController();
            controller = new CaseListViewController();
            controller.Contact = communityContact_Mike;
            controller.ContactId = communityContact_Mike.Id;
            
            //Assertions
            system.assert(controller.viewPicklist.size() > 0);
            system.assertEquals(controller.LIST_VIEW_MY_OPEN_CASES, controller.fieldSetAPIName, 
                                'The default view should be LIST_VIEW_MY_OPEN_CASES');
            system.assertEquals(true, controller.selectedTileName.equalsIgnoreCase('Response Needed'),
                                'Response Needed tile should be selected by default when there are records that require member response.');
            system.assertEquals(2, controller.getCaseList().size());
            system.assertEquals(1, controller.getTotalPages());
            
            //Change the view
            controller.fieldSetAPIName = controller.LIST_VIEW_MY_CLOSED_CASES;
            
            //Refresh the list of projects
            controller.refresh();
            
            //Assertions
            system.assertEquals(2, controller.getCaseList().size());
            
            //Toggle the sort direction
            controller.SortExpression = 'CaseNumber';
            system.assertEquals('DESC', controller.sortDirection);
            
            //List to hold the closed case records Ids
            List<Id> fixedSearchResults = new List<Id>();
            
            //loop through closed case and populating list useful in SOSL testing
            for(Case c : casesToClose)
                fixedSearchResults.add(c.Id);
            
            //Setting test data for SOSL testing
            Test.setFixedSearchResults(fixedSearchResults);
            
            //Search for cases
            controller.searchString = 'test';
            pageReference searchpg = controller.search();
            
            //get the pageRef for a new case
            PageReference newCasePg = controller.newCase();
            system.assertNotEquals(null, newCasePg);
            controller.redirectToTimeout();
        }
        
        //Stop test here
        Test.stopTest();
    }
    
    //Added by - Abhinav Sharma - 06/03/2016 - CR-20150202-8627
    /**
     * @description : Test method to get coverage and assertions for miscellaneous code logic.
     * 
    **/
    static testMethod void testMiscellaneousFunctionalities() {
        
        //Bypass all triggers
        Util.IsTest(true);
        Util.byPassAlltriggers = true;
        Util.isTesting = true;
        
        //Create a Account
        Account account = new Account(Name = 'Testing');
        insert account;
        System.assert(account != null);
        
        //Create new contact
        Contact contact = TestUtilities.CreateNewContact(true);
        System.assert(contact != null);
        
        //Create a project
        Project__c project = TestUtilities.createProject(true);
        System.assert(project != null);
        
        //Select Record Types Id from Custom Setting
        Id expertCentersRTTypeId = Util.RecordTypeId(Constants.CASE_OBJECT, TestUtilities.EXPERT_CENTER_CASE_RECORD_TYPE);
        System.assert(expertCentersRTTypeId != null);
        
        //Insert cases
        List<Case> cases = new List<Case>();
        cases.add(new Case(RecordTypeId = expertCentersRTTypeId, Origin = 'Email', Subject = 'Test 1', Status = 'IN PROGRESS',
                                Description = 'test 1', AccountId = account.Id, Priority = 'Low', ContactId = contact.Id));
        cases.add(new Case(RecordTypeId = expertCentersRTTypeId, Origin = 'Email', Subject = 'Test 2', Status = 'SOLUTION PROVIDED',
                                Description = 'test 2', AccountId = account.Id, Priority = 'Low', ContactId = contact.Id));
        insert cases;
        
        //Assertion to make sure that records are inserted
        System.assert(cases != null);
        System.assertEquals(2, cases.size());
        
        //Setting project Id on page
        ApexPages.currentPage().getParameters().put('pid', project.Id);
        
        //Start testing from here
        Test.startTest();
        
        //Setting page reference
        PageReference pageRf = Page.Case_ListView;
        test.setCurrentPage(pageRf);
        
        //Loading the page
        CaseListViewController controller = new CaseListViewController();
        
        //Asserting for the page size
        System.assertEquals(10, controller.size);
        
        //Setting controller's variables
        Integer noOfRecords = controller.NoOfRecords;
        String projectid = controller.projectID;
        Integer pageNo = controller.pageNo;
        String pageNoString = controller.pageNoString;
        String caseQueryFields = controller.caseQueryFields;
        String caseQuery = controller.caseQuery;
        controller.projectID = project.Id;
        
        //Asserting for list start no.
        Integer listStartNo = controller.ListStartNo;
        System.assertNotEquals(null, listStartNo);
        System.assertEquals(1, listStartNo);
        
        //Asserting for list end no.
        Integer listEndNo = controller.ListEndNo;
        System.assertNotEquals(null, listEndNo);
        System.assertEquals(0, listEndNo);
        
        //Asserting for the results
        System.assertEquals(0, noOfRecords);
        System.assertEquals(0, pageNo);
        System.assertEquals('1', pageNoString);
        System.assert(caseQueryFields != null);
        System.assert(caseQuery != null);
        
        //Calling redirect
        pageRf = controller.redirect();
        
        //Setting pageReference to null
        pageRf = null;
        
        //Calling redirect
        pageRf = controller.redirect();
        
        //Assertion for the result
        System.assertNotEquals(null, pageRf);
        
        //Assertion for result
        pageRf = controller.redirectToTimeout();
        
        //Asserting for the results
        System.assert(pageRf == null);
        
        //Calling go to page method
        controller.goToPage();
        
        //Refereshing the search
        controller.refreshSearch();
        
        //Use case when no project record ID as exists in the URL
        ApexPages.currentPage().getParameters().put('pid', null);
        
        //Re-intilize the controller
        controller = new CaseListViewController();
        
        //Setting property
        controller.sortExpression = 'ASC';
        controller.sortDirection = 'DESC';
        
        //Stop testing here
        Test.stopTest();
    }
}