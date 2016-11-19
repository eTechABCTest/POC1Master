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
 * Best Practices:-
    1) A test class should have all the proper assertions with it, for all possible negative and positive use cases.
    2) It should have atleast 90% overall code coverage for all of the corresponding main class(es)/Trigger(es)
    3) Use the runAs method to test your application in different user contexts.
    4) Where possible exercise bulk trigger functionality — use at least 20 records in your tests.
    5) Use the ORDER BY keywords to ensure that the records are returned in the expected order while asserting for the results.
    6) Use @testSetup method to create the test data, common for all the test methods.
    7) Add proper commenting the code for better understanding.
    8) Once done with all the changes, add final coverage detail on the top level comment of the class for future reference.
    9) Before creating the test data in the test class. Set below mentioned flags as true:-
        //Bypass Dupeblocker and existing triggers for test data creation purpose
        Util.IsTest(true);
        Util.isTesting = true;
        Util.BypassAllTriggers = true;
        Note:- They will bypass the triggers execution and dupeblocker execution while creating test data.
        When trigger execution is needed please set the flag to false as:-
        Util.bypassAlltriggers = false;
    10) Last but not the least properly use "Test.startTest()" and "Test.stopTest()" methods in the test class.
*/
@isTest(seeAllData=false)
private class Test_CaseCommentTriggerHelper {
  
/**
    Purpose         :   Test class for CaseCommentTriggerHelper
                
    Create By       :   Abhinav Sharma
    
    Created Date    :   05/30/2016
    
    Revision Log    :   v1.0 - Created - Abhinav Sharma - CR-20150202-8624

  Coverage    :  v1.0 - CaseCommentTriggerHelper - 100%  
                    :   V1.1 - Rajeev Jain - 09/06/2016 - CR-20160114-9520 - Added new test method to cover and test populateFirstCommentDateTimeOnCases method of the CaseCommentTriggerHelper class
**/
   
   public final static Integer LOOP_SIZE = 1;
      
    /**
     * @description: Common method to invoke various setup methods for creating the test data.
    **/
    //Setup test data
  @testSetup static void setup() {
      Test_CaseCommentTriggerHelper.setupTestData();
  }
      
  /**
     * @description: 1) Create Contact and Project record.
     *          2) Create member support record associated with earlier created project and contact record.
     *          3) Trigger code logic will create a new case record and will populate it's fields with sync logic.
    **/
    @TestVisible private static void setupTestData() {
    
        //Bypass Dupeblocker
        Util.IsTest(true);
        
        //Bypassing Triggers so then test data can be created easily
        Util.byPassAllTriggers = true;
        
        //Flag for triggers: this is just a test, don't do crazy things.
        Util.isTesting = true;
      
      //Create test data for the Sync Fields custom setting that syncs Mem Support -> Case fields
      TestUtilities.createSyncFields();
    
        //Create a contact
        Contact contact = TestUtilities.CreateNewContact(true);
        System.assert(contact != null);
        
        //Create a project
        Project__c project = TestUtilities.createProject(true);
        System.assert(project != null);
        
        //List of member supports
        List<Site_Issue__c> memberSupports = new List<Site_Issue__c>();
        
        //Temp. Variable
        Integer i = 0;
          
        //Create a member support record related to the project
        for(i=0; i<LOOP_SIZE; i++) {
            Site_Issue__c memberSupport = TestUtilities.createSiteIssue(project.Id, false);
            memberSupport.RecordTypeId = Constants.RECORD_TYPE_ID_SITE_ISSUE_CCA_SUPPORT_REQUEST;
            memberSupport.Reported_By__c = contact.Id;
            memberSupport.Status__c = '06 - Issue Resolved - Ticket Closed';
            memberSupport.Visible_In_Portal__c = true;
            memberSupport.Tier__c = 'Tier I';
            memberSupport.Interaction_Type__c = 'Community';
            memberSupport.Site_Issue_Priority__c = 'Normal';
          memberSupports.add(memberSupport);
        }    
        
        //Enabling triggers again
        Util.byPassAllTriggers = false;
    
        //The member support trigger will create a related case
        insert memberSupports;
        
        //Asserting for results
        System.assert(memberSupports != null);
        System.assertEquals(LOOP_SIZE, memberSupports.size());
    
        //Get the case related to the member support record
        List<Case> cases = [SELECT Id, Status, Member_Support_Ticket__c, 
                            ContactId, RecordTypeId, Visible_In_Portal__c,
                            Case_Comment_Notification__c
                            FROM Case 
                            WHERE Member_Support_Ticket__c != null 
                            AND Member_Support_Ticket__c IN : memberSupports
                           LIMIT 10];
      
      //Assert for the results
      System.assert(cases != null);
      System.assertEquals(LOOP_SIZE, cases.size());
        
        //Re-initializing variable value
        i = 0;
        
        //Asserting for results in bulk
        for(i=0; i<LOOP_SIZE; i++) {
            System.assertEquals(contact.Id, cases[i].ContactId);
            System.assertEquals(Constants.RECORD_TYPE_ID_CASE_PT_SUPPORT, cases[i].RecordTypeId);
            System.assertEquals(true, cases[i].Visible_In_Portal__c);
            System.assert(cases[i].Case_Comment_Notification__c == null);
        }      
      
      //Disabling triggers again
        Util.byPassAllTriggers = true;
        
        
        
    } 
    
    /**
     * @description : Test method to check "When a new case comment record got inserted into the system. At the same time,
     *           parent case record is updating with "Case Comment Notification" field value as "System.now()" or not?".   
     * 
    **/
    static testMethod void caseCommentInsertUseCasesTest() {
        
        //Bypass Dupeblocker
        Util.IsTest(true);
        
        //Bypassing Triggers so then test data can be created easily
        Util.byPassAllTriggers = true;
        
        //Flag for triggers: this is just a test, don't do crazy things.
        Util.isTesting = true;
      
        //Get the Case record created in the testsetup method
        List<Case> cses = [SELECT Id, Description, Status, ContactId,
                             RecordTypeId, Case_Comment_Notification__c,
                             Visible_In_Portal__c
                             FROM Case
                            ORDER By Status DESC NULLS LAST LIMIT 10
                          ];
        
        //Assert for the results
      System.assert(cses != null);
      System.assertEquals(LOOP_SIZE, cses.size());
        
        //Temp. variable
        Integer j = 0;
        
        //Asserting for results in bulk
      for(j=0; j<LOOP_SIZE; j++) {
            System.assertEquals(Constants.RECORD_TYPE_ID_CASE_PT_SUPPORT, cses[j].RecordTypeId);
            System.assertEquals(true, cses[j].Visible_In_Portal__c);
            System.assert(cses[j].Case_Comment_Notification__c == null);
        }  
        
        //List of case comments
        List<CaseComment> caseComments = new List<CaseComment>();
        
        //Re-initializing variable value
        j = 0;
        
        //Creating Case Comment
        for(j=0; j<LOOP_SIZE; j++) {
            CaseComment caseCom = TestUtilities.createNewCaseComment(cses[j], false);
          caseComments.add(caseCom);
        }
        
        //Start test from here
        Test.startTest();
        
        //Enabling triggers
        Util.byPassAllTriggers = false;
        
        //Insert case comments
        insert caseComments;
        
        //Assert for result
        System.assert(caseComments != null);
        System.assertEquals(LOOP_SIZE, caseComments.size());
        
        //Stop Test here
        Test.stopTest();
        
        //Fetching updated information from the database
        cses = [SELECT Id, Case_Comment_Notification__c, Visible_In_Portal__c
                FROM Case
                ORDER By Status DESC NULLS LAST LIMIT 10
               ];
        
        //Assert for the results
      System.assert(cses != null);
      System.assertEquals(LOOP_SIZE, cses.size());
        
        //Re-initializing variable value
        j = 0;
        
        //Asserting for the result in bulk
        for(j=0; j<LOOP_SIZE; j++) {
            System.assert(cses[j].Case_Comment_Notification__c != null);
            System.assertEquals(true, cses[j].Visible_In_Portal__c);
        }          
    }
    
    /**
     * @description : Test method to check "When an existing case comment record "IsPublished" field value got changed from
     *           false to true then associated parent case "Case Comment Notification" field is updating with System.now()
     *           as a value with it or not?".
     * 
    **/
    static testMethod void caseCommentUpdateUseCasesTest() {
        
        //Bypass Dupeblocker
        Util.IsTest(true);
        
        //Bypassing Triggers so then test data can be created easily
        Util.byPassAllTriggers = true;
        
        //Flag for triggers: this is just a test, don't do crazy things.
        Util.isTesting = true;
      
        //Get the Case record created in the testsetup method
        List<Case> cses = [SELECT Id, Description, Status, ContactId,
                             RecordTypeId, Case_Comment_Notification__c,
                             Visible_In_Portal__c
                             FROM Case
                            ORDER By Status DESC NULLS LAST LIMIT 10
                          ];
        
        //Assert for the results
      System.assert(cses != null);
        System.assertEquals(LOOP_SIZE, cses.size());
      
        //Temp. Variable
        Integer k = 0;
        
        //Asserting for results in bulk
        for(k=0; k<LOOP_SIZE; k++) {
            System.assertEquals(Constants.RECORD_TYPE_ID_CASE_PT_SUPPORT, cses[k].RecordTypeId);
            System.assertEquals(true, cses[k].Visible_In_Portal__c);
            System.assert(cses[k].Case_Comment_Notification__c == null);
        }  
        
        //Re-initializing variable value
        k = 0;
        
        //Updating case record type to "PT Data Load" from "PT Support"
        for(k=0; k<LOOP_SIZE; k++)
          cses[k].RecordTypeId = Constants.RECORD_TYPE_ID_CASE_PT_DATA_LOAD;
            
        //Update case records
        update cses;
        
        //List of case comments
        List<CaseComment> caseComments = new List<CaseComment>();
        
        //Re-initializing variable value
        k = 0;
        
        //Creating Case Comment
        for(k=0; k<LOOP_SIZE; k++) {
      
            //Creating Case Comment
            CaseComment caseCom = TestUtilities.createNewCaseComment(cses[k], false);
            caseCom.IsPublished = false;
            caseComments.add(caseCom);
        }
        
        //Insert case comments
        insert caseComments;
        
        //Assert for result
        System.assert(caseComments != null);
        System.assertEquals(LOOP_SIZE, caseComments.size());
        
        //Start test from here
        Test.startTest();
        
        //Re-initializing variable value
        k = 0;
        
        //Creating Case Comment
        for(k=0; k<LOOP_SIZE; k++)
          caseComments[k].IsPublished = true;
        
        //Enabling triggers
        Util.byPassAllTriggers = false;
        
        //Update Case Comments
        update caseComments;
        
        //Stop Test here
        Test.stopTest();
        
        //Fetching updated information from the database
        cses = [SELECT Id, Case_Comment_Notification__c, 
                Visible_In_Portal__c, RecordTypeId
                FROM Case
                ORDER By Status DESC NULLS LAST LIMIT 10
               ];
        
        //Re-initializing variable value
        k = 0;
        
        //Assert for the results
      System.assert(cses != null);
      System.assertEquals(1, cses.size());
      
        //Asserting for the results in bulk
        for(k=0; k<LOOP_SIZE; k++) {
          System.assert(cses[k].Case_Comment_Notification__c != null);
            System.assertEquals(true, cses[k].Visible_In_Portal__c);
            System.assertEquals(Constants.RECORD_TYPE_ID_CASE_PT_DATA_LOAD, cses[k].RecordTypeId);
        }        
    }
    
    /**
     * @description :  Test method to check PopulateMostRecentPublicCaseComment Method of trigger CaseComment
     *           Check method for populate most recent case comment of case to associate Member Support record.
    **/
    static testMethod void testPopulateMostRecentPublicCaseComment() {
        
        //Bypass Dupeblocker
        Util.IsTest(true);
        
        //Bypassing Triggers so then test data can be created easily
        Util.byPassAllTriggers = true;
        
        //Flag for triggers: this is just a test, don't do crazy things.
        Util.isTesting = true;
      
      //Code Added by Mahendra swarnkar - CR-20160603-9890 - 7/4/2016
        
        Account acct_1 = TestUtilities.CreateNewAccount(false);
        acct_1.Description = 'Testing RIAMLargeContract Testing';
        
        //Insert Account 
        insert acct_1;
        
        //Create Member Support Records
        List<Site_Issue__c> siteIssueRecords = new List<Site_Issue__c>();
        
        //Added new record in list 
        siteIssueRecords.add(new Site_Issue__c(Site_Issue_Priority__c = 'High', 
                           Site_Issue_Short_Description__c = 'Test-Description',
                                                 Category__c = 'Test-Category', 
                                                 Data_Load_Type__c = Constants.HISTORICAL_RELOAD,
                                                 Site_Issue_Created_Date__c = System.now().addDays(-50), 
                                                 Site_Issue_Close_Date__c = System.now().addDays(5), 
                                                  Data_Load_Period_End__c = Date.Today().addDays(-62),
                                                 Data_Load_Period_Begin__c = Date.today(), 
                                                 Files_Received__c = Date.today()));
    siteIssueRecords.add(new Site_Issue__c(Site_Issue_Priority__c = 'High', 
                           Site_Issue_Short_Description__c = 'Test-Description',
                                                 Category__c = 'Test-Category', 
                                                 Data_Load_Type__c = Constants.HISTORICAL_RELOAD,
                                                 Site_Issue_Created_Date__c = System.now().addDays(-40), 
                                                 Site_Issue_Close_Date__c = System.now().addDays(10),
                                                  Data_Load_Period_End__c = Date.Today().addDays(-62),
                                                 Data_Load_Period_Begin__c = Date.today(), 
                                                 Files_Received__c = Date.today()));
    siteIssueRecords.add(new Site_Issue__c(Site_Issue_Priority__c = 'High', 
                           Site_Issue_Short_Description__c = 'Test-Description',
                                                 Category__c = 'Test-Category', 
                                                 Data_Load_Type__c = Constants.HISTORICAL_RELOAD,
                                                 Site_Issue_Created_Date__c = System.now().addDays(-30), 
                                                 Site_Issue_Close_Date__c = System.now().addDays(15),
                                                  Data_Load_Period_End__c = Date.Today().addDays(-62),
                                                 Data_Load_Period_Begin__c = Date.today(), 
                                                 Files_Received__c = Date.today()));
    siteIssueRecords.add(new Site_Issue__c(Site_Issue_Priority__c = 'High', 
                           Site_Issue_Short_Description__c = 'Test-Description',
                                                 Category__c = 'Test-Category', 
                                                 Data_Load_Type__c = Constants.HISTORICAL_RELOAD,
                                                 Site_Issue_Created_Date__c = System.now().addDays(-20), 
                                                 Site_Issue_Close_Date__c = System.now().addDays(20),
                                                  Data_Load_Period_End__c = Date.Today().addDays(-62),
                                                 Data_Load_Period_Begin__c = Date.today(), 
                                                 Files_Received__c = Date.today()));
        
        //Insert Member support records
        insert siteIssueRecords;
        
        //Querying Details for "Member & Employee Support" record type on Case Object
        List<RecordType> rdType = [SELECT ID FROM RecordType Where sObjectType = 'Case' AND IsActive = true 
                                                AND DeveloperName = 'Member_Employee_Support'];
                                                
        //Create List to hold case records
        List<Case> caseRecords = new List<Case>();
        
        //Added case records in list 
        //Create a sample case record to insert and test case trigger
        caseRecords.add(new Case(RecordTypeId = rdType[0].Id, Origin = 'Email', Subject = 'Test 1', 
                                 Description = 'test 1', AccountId = acct_1.Id, Member_Support_Ticket__c = siteIssueRecords[0].Id));
                                
        caseRecords.add(new Case(RecordTypeId = rdType[0].Id, Origin = 'Phone', Subject = 'Test 2', 
                                 Description = 'test 2', AccountId = acct_1.Id, Member_Support_Ticket__c = siteIssueRecords[1].Id));
                                
        caseRecords.add(new Case(RecordTypeId = rdType[0].Id, Origin = 'Web', Subject = 'Test 3', 
                                 Description = 'test 3', AccountId = acct_1.Id, Member_Support_Ticket__c = siteIssueRecords[2].Id));
                                
        caseRecords.add(new Case(RecordTypeId = rdType[0].Id, Origin = 'Email', Subject = 'Test 4', 
                     Description = 'Test 4', Member_Support_Ticket__c = siteIssueRecords[3].Id));
        
        //Insert Case Records
        insert caseRecords;
                          
        //Get the Case record created in the testsetup method
        List<Case> caseRecordsList = [SELECT Id,Subject, Description, Origin,RecordTypeId, Visible_In_Portal__c, Member_Support_Ticket__c, Member_Support_Ticket__r.Latest_Public_Case_Comment__c FROM Case 
                       WHERE ID IN : caseRecords ORDER By Subject ASC ];
        
        //Assert for result
        System.assertEquals('test 1',caseRecordsList[0].Description);
        System.assertEquals('test 2',caseRecordsList[1].Description);
        System.assertEquals('test 3',caseRecordsList[2].Description);
        System.assertEquals(null ,caseRecordsList[0].Member_Support_Ticket__r.Latest_Public_Case_Comment__c);
        System.assertEquals(null ,caseRecordsList[1].Member_Support_Ticket__r.Latest_Public_Case_Comment__c);
        System.assertEquals(null ,caseRecordsList[2].Member_Support_Ticket__r.Latest_Public_Case_Comment__c);  
        
        //Create list to hold case comment 
        List<CaseComment> caseCommentRecords = new List<CaseComment>();
        
        //Added new record in list
    caseCommentRecords.add(new CaseComment(ParentId = caseRecordsList[0].Id, CommentBody = 'Testing Going On 0', IsPublished = true));
    caseCommentRecords.add(new CaseComment(ParentId = caseRecordsList[0].Id, CommentBody = 'Testing Going On 00', IsPublished = false));
    caseCommentRecords.add(new CaseComment(ParentId = caseRecordsList[1].Id, CommentBody = 'Testing Going On 1', IsPublished = true)); 
    caseCommentRecords.add(new CaseComment(ParentId = caseRecordsList[1].Id, CommentBody = 'Testing Going On 11', IsPublished = false));
    caseCommentRecords.add(new CaseComment(ParentId = caseRecordsList[2].Id, CommentBody = 'Testing Going On 2', IsPublished = true)); 
    caseCommentRecords.add(new CaseComment(ParentId = caseRecordsList[2].Id, CommentBody = 'Testing Going On 22', IsPublished = false)); 
    
    //Retrive Member support records
    List<Site_Issue__c> mamberSupportList = [Select ID,Latest_Public_Case_Comment__c From Site_Issue__c Where ID IN: siteIssueRecords];
    
    //Assert for result
    System.assertEquals(null ,mamberSupportList[0].Latest_Public_Case_Comment__c);
        System.assertEquals(null ,mamberSupportList[1].Latest_Public_Case_Comment__c);
        System.assertEquals(null ,mamberSupportList[2].Latest_Public_Case_Comment__c);
    
    //Start method 
    Test.startTest();
    
    //Enable trigger
    Util.byPassAllTriggers = false;
     
    //Insert caseComment
    insert caseCommentRecords;
    
    //Disable trigger
    Util.byPassAllTriggers = true;
    
    //Retriver MamberSupport records 
    mamberSupportList = [Select ID,Latest_Public_Case_Comment__c From Site_Issue__c Where ID IN: siteIssueRecords];
        
        //Assert for result
        System.assertEquals('Testing Going On 0',mamberSupportList[0].Latest_Public_Case_Comment__c);
        System.assertEquals('Testing Going On 1',mamberSupportList[1].Latest_Public_Case_Comment__c);
        System.assertEquals('Testing Going On 2',mamberSupportList[2].Latest_Public_Case_Comment__c);
    
    //Query over CaseComment
    List<CaseComment> CaseCommentList = [Select Id, ParentId, CommentBody, IsPublished From CaseComment WHERE ID IN : caseCommentRecords ORDER By CommentBody ASC];
    
    //Set update value 
    CaseCommentList[1].IsPublished = true;
    
    Util.byPassAllTriggers = false;
    
    //Update casecomment
    update CaseCommentList[1];
    
    //Retrive updated member sypport records
    mamberSupportList = [Select ID,Latest_Public_Case_Comment__c From Site_Issue__c Where ID IN: siteIssueRecords];
        
        //Asserr for result
        System.assertEquals('Testing Going On 00',mamberSupportList[0].Latest_Public_Case_Comment__c);
        
    //Query over CaseComment
    CaseCommentList = [Select Id, ParentId, CommentBody, IsPublished From CaseComment WHERE ID IN : caseCommentRecords ORDER By CommentBody ASC];
    
    //Assert for result
    system.assertEquals(6, CaseCommentList.size());
    
    //Delete CaseComments
    delete CaseCommentList[1];
    
    //Retrive updated member sypport records
    mamberSupportList = [Select ID,Latest_Public_Case_Comment__c From Site_Issue__c Where ID IN: siteIssueRecords];
        
        //Assert for result   
        System.assertEquals('Testing Going On 0',mamberSupportList[0].Latest_Public_Case_Comment__c);
        
        //Retriver CaseComment records
        CaseCommentList = [Select Id, ParentId, CommentBody, IsPublished From CaseComment WHERE ID IN : caseCommentRecords ORDER By CommentBody ASC];
    
    //Delete CaseComments
    delete CaseCommentList[0];
    
    //Test method stop here
    Test.stopTest();
    
  }
    /** V1.1 - Rajeev Jain - 09/06/2016 - CR-20160114-9520 - 
     *  Added new test method to cover and test populateFirstCommentDateTimeOnCases method of the CaseCommentTriggerHelper class
    **/
    static testMethod void testPopulateFirstCommentDateTimeOnCases() {
        
        //Bypass Dupeblocker
        Util.IsTest(true);
        
        //Bypassing Triggers so then test data can be created easily
        Util.byPassAllTriggers = true;
        
        //Flag for triggers: this is just a test, don't do crazy things.
        Util.isTesting = true;
        
        //Code Added by Mahendra swarnkar - CR-20160603-9890 - 7/4/2016
        
        Account acct_1 = TestUtilities.CreateNewAccount(false);
        acct_1.Description = 'Testing RIAMLargeContract Testing';
        
        //Insert Account 
        insert acct_1;  
        
        //Create Member Support Records
        List<Site_Issue__c> siteIssueRecords = new List<Site_Issue__c>();
        
        //Added new record in list 
        siteIssueRecords.add(new Site_Issue__c(Site_Issue_Priority__c = 'High', 
                                                 Site_Issue_Short_Description__c = 'Test-Description',
                                                 Category__c = 'Test-Category', 
                                                 Data_Load_Type__c = Constants.HISTORICAL_RELOAD,
                                                 Site_Issue_Created_Date__c = System.now().addDays(-50), 
                                                 Site_Issue_Close_Date__c = System.now().addDays(5), 
                                                  Data_Load_Period_End__c = Date.Today().addDays(-62),
                                                 Data_Load_Period_Begin__c = Date.today(), 
                                                 Files_Received__c = Date.today()));
        siteIssueRecords.add(new Site_Issue__c(Site_Issue_Priority__c = 'High', 
                                                 Site_Issue_Short_Description__c = 'Test-Description',
                                                 Category__c = 'Test-Category', 
                                                 Data_Load_Type__c = Constants.HISTORICAL_RELOAD,
                                                 Site_Issue_Created_Date__c = System.now().addDays(-40), 
                                                 Site_Issue_Close_Date__c = System.now().addDays(10),
                                                  Data_Load_Period_End__c = Date.Today().addDays(-62),
                                                 Data_Load_Period_Begin__c = Date.today(), 
                                                 Files_Received__c = Date.today()));
        siteIssueRecords.add(new Site_Issue__c(Site_Issue_Priority__c = 'High', 
                                                 Site_Issue_Short_Description__c = 'Test-Description',
                                                 Category__c = 'Test-Category', 
                                                 Data_Load_Type__c = Constants.HISTORICAL_RELOAD,
                                                 Site_Issue_Created_Date__c = System.now().addDays(-30), 
                                                 Site_Issue_Close_Date__c = System.now().addDays(15),
                                                  Data_Load_Period_End__c = Date.Today().addDays(-62),
                                                 Data_Load_Period_Begin__c = Date.today(), 
                                                 Files_Received__c = Date.today()));
        siteIssueRecords.add(new Site_Issue__c(Site_Issue_Priority__c = 'High', 
                                                 Site_Issue_Short_Description__c = 'Test-Description',
                                                 Category__c = 'Test-Category', 
                                                 Data_Load_Type__c = Constants.HISTORICAL_RELOAD,
                                                 Site_Issue_Created_Date__c = System.now().addDays(-20), 
                                                 Site_Issue_Close_Date__c = System.now().addDays(20),
                                                  Data_Load_Period_End__c = Date.Today().addDays(-62),
                                                 Data_Load_Period_Begin__c = Date.today(), 
                                                 Files_Received__c = Date.today()));
        
        //Insert Member support records
        insert siteIssueRecords;
        
        //Querying Details for "Member & Employee Support" record type on Case Object
        List<RecordType> rdType = [SELECT ID FROM RecordType Where sObjectType = 'Case' AND IsActive = true 
                                                AND DeveloperName =: Constants.RECORD_TYPE_CASE_DEVELOPER_NAME_PT_SUPPORT_REQUEST];
                                                
        //Create List to hold case records
        List<Case> caseRecords = new List<Case>();
        
        //Added case records in list 
        //Create a sample case record to insert and test case trigger
        caseRecords.add(new Case(RecordTypeId = rdType[0].Id, Origin = 'Email', Subject = 'Test 1', 
                                 Description = 'test 1', AccountId = acct_1.Id, Member_Support_Ticket__c = siteIssueRecords[0].Id));
                                
        caseRecords.add(new Case(RecordTypeId = rdType[0].Id, Origin = 'Phone', Subject = 'Test 2', 
                                 Description = 'test 2', AccountId = acct_1.Id, Member_Support_Ticket__c = siteIssueRecords[1].Id));
                                
        caseRecords.add(new Case(RecordTypeId = rdType[0].Id, Origin = 'Web', Subject = 'Test 3', 
                                 Description = 'test 3', AccountId = acct_1.Id, Member_Support_Ticket__c = siteIssueRecords[2].Id));
                                
        caseRecords.add(new Case(RecordTypeId = rdType[0].Id, Origin = 'Email', Subject = 'Test 4', 
                                 Description = 'Test 4', Member_Support_Ticket__c = siteIssueRecords[3].Id));
        
        //Insert Case Records
        insert caseRecords;
        
        //Start Test
        Test.startTest();
                          
        //Get the Case record created in the testsetup method
        List<Case> caseRecordsList = [SELECT Id,Subject, Description, Origin,RecordTypeId, Visible_In_Portal__c, Member_Support_Ticket__c, Member_Support_Ticket__r.Latest_Public_Case_Comment__c FROM Case 
                                   WHERE ID IN : caseRecords ORDER By Subject ASC ];
        
        
        //Bypassing Triggers so then test data can be created easily
        Util.byPassAllTriggers = false;
        
        List<CaseComment> caseCommentRecords = new List<CaseComment>();
        
        //Added new record in list
        caseCommentRecords.add(new CaseComment(ParentId = caseRecordsList[0].Id, CommentBody = 'Testing Going On 0', IsPublished = true));
        caseCommentRecords.add(new CaseComment(ParentId = caseRecordsList[0].Id, CommentBody = 'Testing Going On 00', IsPublished = false));
        caseCommentRecords.add(new CaseComment(ParentId = caseRecordsList[1].Id, CommentBody = 'Testing Going On 1', IsPublished = true)); 
        caseCommentRecords.add(new CaseComment(ParentId = caseRecordsList[1].Id, CommentBody = 'Testing Going On 11', IsPublished = false));
        caseCommentRecords.add(new CaseComment(ParentId = caseRecordsList[2].Id, CommentBody = 'Testing Going On 2', IsPublished = true)); 
        caseCommentRecords.add(new CaseComment(ParentId = caseRecordsList[2].Id, CommentBody = 'Testing Going On 22', IsPublished = false));
        caseCommentRecords.add(new CaseComment(ParentId = caseRecordsList[3].Id, CommentBody = 'Testing Going On 3', IsPublished = true)); 
        caseCommentRecords.add(new CaseComment(ParentId = caseRecordsList[3].Id, CommentBody = 'Testing Going On 33', IsPublished = false));
        insert caseCommentRecords;
        
        //Stop Test
        Test.stopTest();
        
        //Query on Case Record to check if First_Comment_Date_Time__c is populated on case records
        //Assert for Results
        for(Case ca : [select Id, First_Comment_Date_Time__c, Member_Support_Ticket__r.First_Comment_Date_Time__c from Case where Id IN :caseRecordsList]){
            System.assertEquals(true, ca.First_Comment_Date_Time__c != null);
            System.assertEquals(true, ca.First_Comment_Date_Time__c == ca.Member_Support_Ticket__r.First_Comment_Date_Time__c);
        }
        
    }
}