/**
    Purpose         :   Test class for Trigger_MemberSupport
                
    Create By       :   Colin McGloin
    
    Created Date    :   8/28/2015
    
    Revision Log    :   V_1.0 - Created - 8/28/2015 - Code Refactoring
                        V_1.1 - Modified By - Abhinav Sharma - 11/28/2015 - CR-20150601-8977 - Added new method (test_CPRMDataLoadTicketUseCases) 
                        V_1.2 - Modified By - Mahendra Swarnakar - 02/15/2016 - CR-20151210-9456 
                        V_1.3 - Modified By - Abhinav Sharma - 04/01/2016 - CR-20160224-9632
                        V_1.4 - Modified By - Victor Hanson - 04/13/2016 - CR-20160413-9760
                        V_1.5 - Modified By - Abhinav Sharma - 05/30/2016 - CR-20150326-8810
                        V_1.6 - Modified By - Mahendra Swarnkar - CR-20160420-9785 - 09/01/2016
						V_1.7 - Modified By - Rajeev Jain - 09/10/2016 - CR-20160114-9520 - Added new test method test_MSAcknowledgeFields
**/
@isTest(seeAllData=false)
Private class Test_MemberSupport {

    // this test is to make sure that issues can be created for a product
    static testMethod void createIssueOnProduct() {
    
        //Bypass Dupeblocker
        Util.IsTest(true);
        
        //Bypassing Triggers so then test data can be created easily
        Util.byPassAllTriggers = true;
        
        Id projectRTId = Schema.SObjectType.Project__c.getRecordTypeInfosByName().get('CMA').getRecordTypeId();
        
        Id rcordType = Schema.SObjectType.Site_Issue__c.getRecordTypeInfosByName().get('Crimson Support Request').getRecordTypeId();
        
        Project__c project = new project__c(RecordTypeId = projectRTId);
        insert project;
        system.assertNotEquals(null,project.id);
        
        //Member Support
        Site_issue__c issue1 = new site_issue__c();
        issue1.project__c = project.id;
        issue1.Data_Load_Type__c = Constants.CURRENT;
        issue1.site_issue_short_description__c = 'none';
        issue1.site_issue_close_date__c = system.now();
        issue1.site_issue_close_date__c = system.today();
        issue1.status__c = '06 - Issue Resolved - Ticket Closed';
        issue1.support_category__c = 'Production Migration';
        issue1.data_load_period_begin__c = system.today()-1;
        issue1.data_load_period_end__c = system.today();
        issue1.application_version__c='2011.00';
        issue1.RecordTypeId = rcordType;
        
        //Start Test from here
        Test.startTest();
        
        //Enabling triggers
        Util.byPassAllTriggers = false;
        
        //Insert site issue
        insert issue1;
        system.assertNotEquals(null,issue1.id);
        
        //Stop Test here
        Test.stopTest();
        
        //Site Issue
        site_issue__c issue3 = new site_issue__c(RecordTypeId = rcordType, project__c = project.id, Data_Load_Type__c = 'Current', status__c = '06 - Issue Resolved - Ticket Closed', site_issue_short_description__c = 'none', site_issue_close_date__c = system.now().date(), support_category__c = 'none', data_load_period_begin__c = system.today()-1, data_load_period_end__c = system.today(), application_version__c='2011.01' );
        insert issue3;
        system.assertNotEquals(null,issue3.id);
    }
    
    //Code added by Bhavi Sharma - 04/29/2013 - CR-20130403-2801
    //Code added by Bhavi Sharma - 07/19/2013 - CR-20130718-3283
    static testMethod void updateProjectWithSiteIssue() {
    
        //Bypass Dupeblocker
        Util.IsTest(true);
        
        //Bypass triggers
        Util.BypassAllTriggers = true;
        
        //account record
        Account account = new Account(Name = 'test');
        insert account;
        
        // create a contact
        Contact contact = new Contact(FirstName = 'test', LastName = 'Contact', Email = Math.random()+'@test.com', Employee_ID__c = 'TestEmployee');
        insert contact;
                
        //Start Testing from here
        Test.StartTest();
        
        //create new Project__c data
        Project__c project = new Project__c(Name = 'Test-Data');
        
        //insert Project data
        insert project;
        
        //Get the three record types from Member Support
        Id CMADLRT = Schema.SObjectType.Site_Issue__c.getRecordTypeInfosByName().get('CMA Data Load/Migration').getRecordTypeId();
        Id CCADLRT = Schema.SObjectType.Site_Issue__c.getRecordTypeInfosByName().get('CCA Data Load').getRecordTypeId();
        
        //Create List of Site
        Site_Issue__c sIssue = new Site_Issue__c(Site_Issue_Priority__c = 'High', Site_Issue_Short_Description__c = 'Test-Description',
                                                        Category__c = 'Test-Category', Data_Load_Type__c = Constants.HISTORICAL_RELOAD, Application_Version__c = '13.09',
                                                        Crimson_Site_Issue_Description__c = 'Test Issue Description', RecordTypeId = CCADLRT,
                                                        Project__c = project.Id, Assigned_To_Contact__c = contact.Id, CCC_Date_Observed__c = System.Today(),
                                                        Support_Category__c = Constants.CRIMSON_SUPPORT_REQUEST_SITE_ISSUE_SUPPORT_CATEGORY_PRODUCTION_MIGRATION, 
                                                        Site_Issue_Created_Date__c = System.now().addDays(-54), Site_Issue_Close_Date__c = System.now().addDays(10),
                                                        Data_Load_Period_End__c = System.today().addDays(-62));
          
        //insert Site Issue
        Util.BypassAllTriggers = false;
        insert sIssue;
        
        //test stops here
        Test.stopTest();
        
        project = [SELECT Id,Version_Bridge_New__c FROM Project__c WHERE Id =: project.Id];
        sIssue = [SELECT Id,version_ms__c FROM Site_Issue__c WHERE Id =: sIssue.Id];
        
        //Assert Results
        System.assertEquals(sIssue.version_ms__c,project.Version_Bridge_New__c);
    }
    
    //Code added by Bhavi Sharma - 04/29/2013 - CR-20130403-2801
    //Code added by Bhavi Sharma - 07/19/2013 - CR-20130718-3283
    static testMethod void updateProjectWithSiteIssue2() {
        
        //Bypass triggers
        Util.BypassAllTriggers = true;
        
        //Bypass Dupeblocker
        Util.IsTest(true);
        
        //account record
        Account account = new Account(Name = 'test');
        insert account;
        
        // create a contact
        Contact contact = new Contact(FirstName = 'test', LastName = 'Contact', Email = Math.random()+'@test.com', Employee_ID__c = 'TestEmployee');
        insert contact;
        
        //Get the three record types from Member Support
        Id CMADLRT = Schema.SObjectType.Site_Issue__c.getRecordTypeInfosByName().get('CMA Data Load/Migration').getRecordTypeId();
        Id CCADLRT = Schema.SObjectType.Site_Issue__c.getRecordTypeInfosByName().get('CCA Data Load').getRecordTypeId();
        Id CPMDLRT = Schema.SObjectType.Site_Issue__c.getRecordTypeInfosByName().get('CPM Data Load').getRecordTypeId();
        
        //List of Projects records to test
        List<Project__c> projectList = new List<Project__c>();
        projectList.add(new Project__c(Name = 'Test-Data',version_bridge_new__c = 13.15));
        projectList.add(new Project__c(Name = 'Test-Data 1'));
        
        //insert Project data
        Util.BypassAllTriggers = true;
        insert projectList;
        
        //Start Testing from here
        Test.startTest();
        
        //List of Member Support
        List<Site_Issue__c> listIssues = new List<Site_Issue__c>();
        
        listIssues.add(new Site_Issue__c(Site_Issue_Short_Description__c = 'Test-Description', Application_Version__c = '13.16',
                                                        RecordTypeId = CCADLRT, Project__c = projectList[0].Id, Assigned_To_Contact__c = contact.Id, 
                                                        Expected_Resolution_Date__c = System.Today(), Support_Category__c = Constants.CRIMSON_SUPPORT_REQUEST_SITE_ISSUE_SUPPORT_CATEGORY_PRODUCTION_MIGRATION, 
                                                        Site_Issue_Created_Date__c = System.now().addDays(-54), Site_Issue_Close_Date__c = System.now().addDays(10)
                                                        ,Data_Load_Type__c = Constants.HISTORICAL_RELOAD, Data_Load_Period_End__c = Date.today(), Data_Load_Period_Begin__c = Date.today()));
        
        listIssues.add(new Site_Issue__c(Site_Issue_Short_Description__c = 'Test-Description', Application_Version__c = '13.16',
                                                        RecordTypeId = CCADLRT, Project__c = projectList[0].Id, Assigned_To_Contact__c = contact.Id, 
                                                        Expected_Resolution_Date__c = System.Today(), Support_Category__c = Constants.CRIMSON_SUPPORT_REQUEST_SITE_ISSUE_SUPPORT_CATEGORY_PRODUCTION_MIGRATION, 
                                                        Site_Issue_Created_Date__c = System.now().addDays(-54), Site_Issue_Close_Date__c = System.now().addDays(10),Files_Received__c = Date.today()
                                                        ,Data_Load_Type__c = Constants.HISTORICAL_RELOAD, Data_Load_Period_End__c = Date.today(), Data_Load_Period_Begin__c = Date.today()));
        
        listIssues.add(new Site_Issue__c(Site_Issue_Short_Description__c = 'Test-Description', Application_Version__c = '13.15',
                                                        RecordTypeId = CMADLRT, Project__c = projectList[0].Id, Assigned_To_Contact__c = contact.Id, 
                                                        Expected_Resolution_Date__c = System.Today(), Support_Category__c = Constants.CRIMSON_SUPPORT_REQUEST_SITE_ISSUE_SUPPORT_CATEGORY_PRODUCTION_MIGRATION, 
                                                        Site_Issue_Created_Date__c = System.now().addDays(-54), Site_Issue_Close_Date__c = System.now().addDays(10),Files_Received__c = Date.today()
                                                        ,Data_Load_Type__c = Constants.HISTORICAL_RELOAD, Data_Load_Period_End__c = Date.today(), Data_Load_Period_Begin__c = Date.today()));
        
        listIssues.add(new Site_Issue__c(Site_Issue_Priority__c = 'High', Site_Issue_Short_Description__c = 'Test-Description',
                                                        Category__c = 'Test-Category', Data_Load_Type__c = Constants.HISTORICAL_RELOAD, Application_Version__c = '13.09',
                                                        Crimson_Site_Issue_Description__c = 'Test Issue Description', RecordTypeId = CPMDLRT,
                                                        Project__c = projectList[1].Id, Assigned_To_Contact__c = contact.Id, CCC_Date_Observed__c = System.Today(),
                                                        Support_Category__c = Constants.CRIMSON_SUPPORT_REQUEST_SITE_ISSUE_SUPPORT_CATEGORY_PRODUCTION_MIGRATION, 
                                                        Site_Issue_Created_Date__c = System.now().addDays(-54),Data_Load_Period_End__c = System.today().addDays(-62)));
        
        Util.BypassAllTriggers = false;
        
        insert listIssues;
        
        //test stops here
        Test.stopTest();
        
        projectList = [SELECT Id,Version_Bridge_New__c FROM Project__c WHERE Id =: projectList[0].Id LIMIT 1];
        
        listIssues = [SELECT Id,version_ms__c FROM Site_Issue__c WHERE Id =: listIssues[0].Id];
        
        //Assert Results
        System.assertEquals(listIssues[0].version_ms__c,projectList[0].Version_Bridge_New__c);
        
        projectList = [SELECT Id,Version_Bridge_New__c FROM Project__c LIMIT 2];
        
        //Assert Results
        System.assertEquals(null,projectList[1].Version_Bridge_New__c);
    }
    
    //Code added by Abhinav Sharma - 03/11/2014 - CR-20140108-4243
    static testMethod void updateProjectWithSiteIssueForCMARecordTypes() {
        
        //Bypassing all the triggers at the time of test data creation
        Util.BypassAllTriggers = true;        
        Util.IsTest(true);
        
        //account record
        Account account = new Account(Name = 'test');
        insert account;
        
        // create a contact
        Contact contact = new Contact(FirstName = 'test', LastName = 'Contact', Email = Math.random()+'@test.com', Employee_ID__c = 'TestEmployee');
        insert contact;
        
        //create new Project__c data
        Project__c project = new Project__c(Name = 'Test-Data');
        
        //insert Project data
        insert project;
        
        // get one record type name
        Id CMADLRT = Schema.SObjectType.Site_Issue__c.getRecordTypeInfosByName().get('CMA Data Load/Migration').getRecordTypeId();
        Id CMAIDSRT = Schema.SObjectType.Site_Issue__c.getRecordTypeInfosByName().get('CMA Initial Deployment Support').getRecordTypeId();
        
        //System Issue
        Site_Issue__c sIssue_1 = new Site_Issue__c(Site_Issue_Priority__c = 'High', Site_Issue_Short_Description__c = 'Test-Description',
                                                        Category__c = 'Test-Category', Application_Version__c = '13.00', Status__c = Constants.STATUS_X_DUPLICATE_CANCELLED,
                                                        Crimson_Site_Issue_Description__c = 'Test Issue Description', RecordTypeId = CMAIDSRT,
                                                        Project__c = project.Id, Assigned_To_Contact__c = contact.Id, CCC_Date_Observed__c = System.Today(),
                                                        Site_Issue_Created_Date__c = System.now().addDays(-54), Site_Issue_Close_Date__c = System.now().addDays(10),
                                                        Data_Load_Period_End__c = System.today().addDays(-62), Member_Facing_Resolution_Summary__c = 'Test');
        
        //Start Test from here
        Test.startTest();
        
        //Setting flag value, So, then trigger can execute
        Util.BypassAllTriggers = false;        
        
        //Insert site issue
        insert sIssue_1;
        
        List<Site_Issue__c> sIssues = [Select ID, Version_MS__c FROM Site_Issue__c LIMIT 2];
        Decimal VersionMSComparison = sIssues[0].Version_MS__c;
        Integer sIssueSize = sIssues.Size();
        
        List<Project__c> projects = [Select version_bridge_new__c FROM Project__c LIMIT 2];
        Decimal VersionBridgeNewComparison = projects[0].version_bridge_new__c;
        Integer projectsSize = projects.Size();
        
        //Stop Test Here
        Test.stopTest();
        
        //Updating Site Issue record
        sIssue_1.Status__c = 'Test';
        update sIssue_1;
        
        projects = [Select version_bridge_new__c FROM Project__c LIMIT 2];
        Decimal VersionBridgeNewComparison2 = projects[0].version_bridge_new__c;
        Integer projectsSize2 = projects.Size();
        
        //Retreiving Member Support details after Member Support insertion and asserting for the results
        System.assertEquals(1, sIssueSize);
        System.assertEquals(13.00, VersionMSComparison);
        
        //Retreiving project details after associated Member Support insertion and asserting for the results
        System.assertEquals(1, projectsSize);
        System.assertEquals(null, VersionBridgeNewComparison);
              
        //Retreiving project details after Member Support update to status of 'Test' and asserting for the results
        System.assertEquals(1, projectsSize2);
        System.assertEquals(13.00, VersionBridgeNewComparison2);
    }
    
    static testMethod void testPopulateProgramType() {
        
        //By Passing all triggers so then test data can be created easily for testing purpose 
        util.BypassAllTriggers = true;
        
        //Create Contact
        Contact con = testUtilities.CreateNewContact(false);
        con.Employee_ID__c = 'Test1';
        insert con;
        
        //Create 2 new programs
        Program__c program_HCC = TestUtilities.CreateNewProgram(false);
        program_HCC.Program_Acronym__c = 'HCC';
        Program__c program_HCAB = TestUtilities.CreateNewProgram(false);
        program_HCAB.Program_Acronym__c = 'HCAB';
        list<Program__c> programList = new list<Program__c> { program_HCC, program_HCAB };
            insert programList;
        
        //Create a new Project__c
        Project__c project = new Project__c(Name = 'Test-Data', Product__c = program_HCC.Id);
        insert project;
        
        //Get record type
        Id TestRecordType = Schema.SObjectType.Site_Issue__c.getRecordTypeInfosByName().get('Defect / Enhancement Request').getRecordTypeId();
        
        //create a member support record
        Site_Issue__c memSupport = new Site_Issue__c(Site_Issue_Priority__c = 'High', Site_Issue_Short_Description__c = 'Test-Description',
                                                     Category__c = 'Test-Category', Data_Load_Type__c = Constants.HISTORICAL_RELOAD,
                                                     Crimson_Site_Issue_Description__c = 'Test Issue Description', RecordTypeId = TestRecordType,
                                                     Project__c = project.Id, Assigned_To_Contact__c = con.Id, CCC_Date_Observed__c = System.Today(),
                                                     Site_Issue_Created_Date__c = System.now().addDays(-54), Site_Issue_Close_Date__c = System.now().addDays(8),
                                                     Data_Load_Period_End__c = Date.Today().addDays(-62));
        
        //Enabling triggers back
        util.BypassAllTriggers = false;
        
        //Insert member support record
        insert memSupport;
        
        //Get member support record
        memSupport = [SELECT Id, Project_Program_Type__c FROM Site_Issue__c WHERE Id = :memSupport.Id];
        
        //Variable for later assertion
        String ProjProgramType1 = memSupport.Project_Program_Type__c;
        
        //Start Testing from here
        Test.StartTest();
        
        // update the member support record's program
        project.Product__c = program_HCAB.Id;
        
        //Enabling trigger back
        util.BypassAllTriggers = false;
        
        //Update project record
        update project;
        
        //Stop testing here
        Test.StopTest();   
        
        //Get member support record
        memSupport = [SELECT Id, Project_Program_Type__c FROM Site_Issue__c WHERE Id = :memSupport.Id];
        
        //verify that the member support program acronym was updated
        System.assertEquals(program_HCC.Program_Acronym__c, ProjProgramType1);
        
        //verify that the member support program acronym was updated
        System.assertEquals(program_HCAB.Program_Acronym__c, memSupport.Project_Program_Type__c);
    }   
    
    static testMethod void testCompassSupportAssignment() {
        
        //Bypassing triggers so them test data can be created easily for testing
        Util.IsTesting = true;
        Util.BypassAllTriggers = true;
        
        //User record
        User compassSupportUser = [SELECT Name, Id, Username FROM User WHERE IsActive = true LIMIT 1];
        
        // get one record type name
        RecordType rt = [SELECT Id, Name FROM RecordType WHERE SobjectType='Site_Issue__c' AND Name='CPM Support Issue' AND IsActive=true LIMIT 1];
        
        //Member Support Assignment
        Member_Support_Assignment__c memberAssignment = new Member_Support_Assignment__c();
        memberAssignment.Record_Type_Name__c = rt.Name;
        memberAssignment.Username__c = compassSupportUser.Username;
        
        //Create the support issue
        Site_Issue__c newIssue = new Site_Issue__c();
        newIssue.RecordTypeId = rt.Id;
        newIssue.Data_Load_Type__c = 'Production Issue';
        
        //Set flag false for not to by pass all triggers
        Util.BypassAllTriggers = false;   
        
        //Insert member Support
        insert newIssue;
        
        // get the new issue and test the owner
        List<Site_Issue__c> issues = [SELECT Name, Id, OwnerId FROM Site_Issue__c WHERE Id = :newIssue.Id];
        
        // make sure the owner of the newly created issue matches the owner that is specified in the custom setting
        //system.assertEquals(compassSupportUserId, issues[0].OwnerId);
        Util.BypassAllTriggers = true;
        
        //Test data added by Bhavi Sharma - 04/24/2013 - CR-20121219-1968
        
        //create new Project__c data
        Project__c project = new Project__c(Name = 'Test-Data');
        
        //insert Project data
        insert project;
        
        // get one record type name
        List<RecordType> recordTypes = [SELECT Id, Name FROM RecordType WHERE Name='Defect / Enhancement Request' AND IsActive = true AND sObjectType = 'Site_Issue__c' limit 1];
        
        //Asert or the record type
        System.assertEquals(1, recordTypes.size());
        
        Contact con = testUtilities.CreateNewContact(true);
        con.Employee_ID__c = 'Test1';
        update con;
        
        System.debug('#### Contact' + con + '#### Id' + con.Id);
        
        //Create List of Site
        Site_Issue__c sIssue = new Site_Issue__c(Site_Issue_Priority__c = 'High', Site_Issue_Short_Description__c = 'Test-Description',
                                                 Category__c = 'Test-Category', Data_Load_Type__c = Constants.HISTORICAL_RELOAD,
                                                 Crimson_Site_Issue_Description__c = 'Test Issue Description', RecordTypeId = recordTypes[0].Id,
                                                 Project__c = project.Id, Assigned_To_Contact__c = con.Id, CCC_Date_Observed__c = System.Today(),
                                                 Site_Issue_Created_Date__c = System.now().addDays(-54), Site_Issue_Close_Date__c = System.now().addDays(8),
                                                 Data_Load_Period_End__c = Date.Today().addDays(-62));
        
        System.debug('Util.BypassAllTriggers 2:::::::::;'+ Util.BypassAllTriggers);
        
        //Set flag false for not to by pass all triggers
        Util.BypassAllTriggers = false;   
        
        //Start Testing from here
        Test.StartTest();
        
        //insert Site Issue
        insert sIssue;
        
        //Stop Testing from here
        Test.StopTest();
        
        //Get Project 
        project = [SELECT Id, Delayed_Load__c FROM Project__c WHERE Id =: project.Id];
        
        //assert statements
        System.assertEquals(1, project.Delayed_Load__c);
    }
    
    //New test Method added of Utility class's UpdateSiteIssueByProject method  - Bhavi Sharma - 06/04/2013 - CR-20130328-2773
    static testmethod void testUpdateSiteIssueByProject() {
        
        //Bypassing all triggers so then test data can be created for testing purpose
        Util.BypassAllTriggers = true;
        
        //Fetch profile from database
        List<Profile> profiles = [Select id from Profile where Name = 'System Administrator' limit 1];
        
        //Assert for result
        System.assertEquals(1, profiles.size());
        
        //Create User
        User user1 = TestUtilities.CreatenewUser(profiles[0], true);
        User user2 = TestUtilities.CreatenewUser(profiles[0], true);
        
        Contact con1 = TestUtilities.CreateNewContact(false);
        con1.Employee_ID__c = 'Test1';
        con1.Employee_User_Record__c = user1.Id;
        Contact con2 = TestUtilities.CreateNewContact(false);
        con2.Employee_ID__c = 'Test2';
        con2.Employee_User_Record__c = user2.Id;
        List<Contact> contacts = new List<Contact> { con1, con2 };
        insert contacts;
        
        //create new Project__c data
        Project__c project = new Project__c(Name = 'Test-Data',Recurring_Business_Analyst__c = user1.Id, Dedicated_Advisor__c = user1.Id, 
                                                Crimson_Data_Analyst_Group_Lead__c = user1.Id, Implementation_Pod__c = 'Test', Crimson_Data_Lag__c = 10, Load_Frequency__c = 'Test');
                                                
        //insert Project data
        insert project;
        
        //create new Project__c data
        Project__c project2 = new Project__c(Name = 'Test-Data2',Recurring_Business_Analyst__c = user1.Id, Dedicated_Advisor__c = user1.Id, 
                                             Crimson_Data_Analyst_Group_Lead__c = user1.Id, Current_Data_Period_New__c = Date.Today().addDays(-62),
                                             Latest_Data_Load__c = Date.today());
        
        //insert Project data
        insert project2;
        
        //Get the two record types from Member Support
        Id CMADLRT = Schema.SObjectType.Site_Issue__c.getRecordTypeInfosByName().get('CMA Data Load/Migration').getRecordTypeId();
        Id CCADLRT = Schema.SObjectType.Site_Issue__c.getRecordTypeInfosByName().get('CCA Data Load').getRecordTypeId();
        
        Contact con = TestUtilities.CreateNewContact(false);
        con.Employee_ID__c = 'Test1';
        insert con;
        
        //Create List of Site
        Site_Issue__c sIssue = new Site_Issue__c(Site_Issue_Priority__c = 'High', Site_Issue_Short_Description__c = 'Test-Description',
                                                        Category__c = 'Test-Category', Data_Load_Type__c = Constants.HISTORICAL_RELOAD,
                                                        Crimson_Site_Issue_Description__c = 'Test Issue Description', RecordTypeId = CMADLRT,
                                                        Project__c = project.Id, Assigned_To_Contact__c = con.Id, CCC_Date_Observed__c = System.Today(),
                                                        Site_Issue_Created_Date__c = System.now().addDays(-54), Site_Issue_Close_Date__c = System.now().addDays(8),
                                                        Data_Load_Period_End__c = Date.Today().addDays(-62),Data_Load_Period_Begin__c = Date.today(), Files_Received__c = Date.today());
        
        //Enabling triggers back
        Util.BypassAllTriggers = false;
        
        //Start Testing from here
        Test.StartTest();
        
        //insert Site Issue
        insert sIssue;
        
        //Site Issue record
        sIssue = [SELECT Production_Business_Analyst__c, Dedicated_Advisor__c, Assigned_To_Contact__c, Data_Load_Period_End__c, 
                    Project_Implementation_Pod_1__c, Crimson_Data_Lag_1__c, Load_Frequency__c FROM Site_Issue__c WHERE Id =: sIssue.Id];
        
        //update some fields of Site Issue
        sIssue.Data_Load_Period_End__c = Date.today();
        
        //Create Variables for assertions at the end of the test method
        Date projectDatePeriodNew1;
        DateTime projectLatestDataLoad1;
        Date projectDatePeriodNew2;
        DateTime projectLatestDataLoad2;
        
        //update Site Issue
        update sIssue;
        
        //Create List of Site
        Site_Issue__c sIssue2 = new Site_Issue__c(Site_Issue_Priority__c = 'High', Site_Issue_Short_Description__c = 'Test-Description',
                                                        Category__c = 'Test-Category', Data_Load_Type__c = Constants.HISTORICAL_RELOAD,
                                                        Crimson_Site_Issue_Description__c = 'Test Issue Description', RecordTypeId = CCADLRT,
                                                        Project__c = project2.Id, Assigned_To_Contact__c = con1.Id, CCC_Date_Observed__c = System.Today(),
                                                        Site_Issue_Created_Date__c = System.now().addDays(-54), Site_Issue_Close_Date__c = Date.today(),
                                                        Data_Load_Period_End__c = Date.Today().addDays(-62),Data_Load_Period_Begin__c = Date.today());
        
        //insert Site Issue
        insert sIssue2;
        
        //Project record
        project2 = [SELECT Latest_Data_Load__c, Current_Data_Period_New__c FROM Project__c WHERE Id =: project2.Id];
        
        //Pass to variables for testing at the end of the test
        projectDatePeriodNew1 = project2.Current_Data_Period_New__c;
        projectLatestDataLoad1 = project2.Latest_Data_Load__c;

        //Create List of Site
        Site_Issue__c sIssue3 = new Site_Issue__c(Site_Issue_Priority__c = 'High', Site_Issue_Short_Description__c = 'Test-Description',
                                                        Category__c = 'Test-Category', Data_Load_Type__c = Constants.HISTORICAL_RELOAD,
                                                        Crimson_Site_Issue_Description__c = 'Test Issue Description', RecordTypeId = CCADLRT,
                                                        Project__c = project2.Id, Assigned_To_Contact__c = con1.Id, CCC_Date_Observed__c = System.Today(),
                                                        Site_Issue_Created_Date__c = System.now().addDays(-54), Site_Issue_Close_Date__c = Date.today(),
                                                        Data_Load_Period_End__c = Date.Today().addDays(-62), Data_Load_Period_Begin__c = Date.today());
        
        //insert Site Issue
        insert sIssue3;
        
        //Test stops here
        Test.stopTest();
        
        //Site Issue record
        sIssue3 = [SELECT Site_Issue_Close_Date__c, RecordTypeId, Data_Load_Period_End__c FROM Site_Issue__c WHERE Id =: sIssue3.Id];
        
        //Project record
        project2 = [SELECT Latest_Data_Load__c, Current_Data_Period_New__c FROM Project__c WHERE Id =: project2.Id];
        
        //Assert statements
        System.assertEquals(sIssue2.Data_Load_Period_End__c, projectDatePeriodNew1);
        System.assertEquals(sIssue2.Site_Issue_Close_Date__c, projectLatestDataLoad1);
        
        //assert the fields mapped over from Member Support to Project correctly
        System.assertEquals(project.Recurring_Business_Analyst__c, sIssue.Production_Business_Analyst__c);
        System.assertEquals(project.Dedicated_Advisor__c, sIssue.Dedicated_Advisor__c);
        System.assertEquals(project.Implementation_Pod__c, sIssue.Project_Implementation_Pod_1__c);
        System.assertEquals(project.Crimson_Data_Lag__c, sIssue.Crimson_Data_Lag_1__c);
        System.assertEquals(project.Load_Frequency__c, sIssue.Load_Frequency__c);
        System.assertEquals(con1.Id, sIssue.Assigned_To_Contact__c);
        
        //Assert statements
        System.assertEquals(sIssue3.Data_Load_Period_End__c, project2.Current_Data_Period_New__c);
        System.assertEquals(sIssue3.Site_Issue_Close_Date__c, project2.Latest_Data_Load__c);
        
    } 
    
    //Method updated - Ajit Surana - -2/16/2015 - CR-20150106-8468 - Replaced CCC string with BIPC
    //New test Method added of Utility class's SendDataLoadAutoEmail method  - Bhavi Sharma - 07/24/2013 - CR-20120716-1142
    //Update - (SUNJ 12/19/13) - CR-20130815-3433
    static testmethod void testSendDataLoadAutoEmail() {
        
        //Byapssing all triggers so then test data can be created for testing purpose
        Util.BypassAllTriggers = true;
        
        //Fetch profile from database
        List<Profile> profiles = [Select id from Profile where Name = 'System Administrator' limit 1];
        
        //Assert for result
        System.assertEquals(1, profiles.size());
        
        //Create Users
        User user1 = TestUtilities.CreatenewUser(profiles[0], true);
        User user2 = TestUtilities.CreatenewUser(profiles[0], true);
        
        //create new Contact
        Contact con = TestUtilities.CreateNewContact(false);
        con.Employee_ID__c = 'Test1';
        insert con;
        
        //create new Account
        Account account = TestUtilities.CreateNewAccount(false);
        Account.Name = 'TestBIPC Account ';
        Account.Account_Formal_Name__c = 'BIPC Account';
        Insert account;
        
        //create new Contact
        Contact contact = TestUtilities.CreateNewContact(false);
        Contact.AccountId = account.Id;
        Contact.Employee_ID__c = 'Test';
        
        //Insert contact here
        Insert contact;
        
        //create new Program record 
        Program__c program_BIPC = TestUtilities.CreateNewProgram(false);
        program_BIPC.Program_Acronym__c = 'BIPC';
        
        insert program_BIPC;
        
        //create new Project__c data
        Project__c project1 = TestUtilities.createProject(false);
        project1.Recurring_Business_Analyst__c = user1.Id;
        project1.Dedicated_Advisor__c = user1.Id;
        project1.Product__c = program_BIPC.Id;
        project1.Project_Manager__c = user1.Id;
        project1.Crimson_Data_Analyst_Group_Lead__c = user1.Id;
        project1.Institution__c = account.Id;
        
        //insert Project data
        insert project1;
        
        project1 = [SELECT Name FROM Project__c WHERE Id =: project1.Id];
        System.debug('Name is ::::::' + project1.Name);
        
        //create new Project Role data
        Project_Role__c projectRole = new Project_Role__c(Project__c = project1.Id, Contact__c = contact.Id, CCC_Include_in_Data_Load_Automated_Email__c = true);
        
        //insert Project Role here
        insert projectRole;
        
        //create new Project__c data
        Project__c project2 = TestUtilities.createProject(false);
        project1.Recurring_Business_Analyst__c = user1.Id;
        project1.Dedicated_Advisor__c = user1.Id;
        project1.Project_Manager__c = user1.Id;
        project1.Crimson_Data_Analyst_Group_Lead__c = user1.Id;
        
        //insert Project data
        insert project2;
        
        Id CMADLRT = Schema.SObjectType.Site_Issue__c.getRecordTypeInfosByName().get('CMA Data Load/Migration').getRecordTypeId();
        Id CCADLRT = Schema.SObjectType.Site_Issue__c.getRecordTypeInfosByName().get('CCA Data Load').getRecordTypeId();
        
        //Create List of Site
        Site_Issue__c sIssue1 = new Site_Issue__c(Site_Issue_Priority__c = 'High', Site_Issue_Short_Description__c = 'Test-Description',
                                                        Category__c = 'Test-Category', Data_Load_Type__c = Constants.HISTORICAL_RELOAD,
                                                        Crimson_Site_Issue_Description__c = 'Test Issue Description', RecordTypeId = CMADLRT,
                                                        Status__c = Constants.STATUS_SITE_ISSUE_10_CLOSED_MEMBER_NOTIFIED,
                                                        Project__c = project1.Id, Assigned_To_Contact__c = con.Id, CCC_Date_Observed__c = System.Today(),
                                                        Site_Issue_Created_Date__c = System.now().addDays(-54), Site_Issue_Close_Date__c = System.now().addDays(8),
                                                        Data_Load_Period_End__c = Date.Today().addDays(-62),Application_Version__c='13.01',
                                                        Data_Load_Period_Begin__c = Date.today(), Files_Received__c = Date.today(),Internal_Load_Complete__c=Date.today(), Smoke_Test_Complete__c=Date.today(), Testing_Complete__c=Date.today(),
                                                        Ready_for_Final_QA__c=Date.today(), Moved_to_Production__c=Date.today(),
                                                        Member_Facing_Resolution_Summary__c='test', Data_Submission_Target_Date__c = Date.today(),
                                                        Diagnostics_Sent__c = Date.today(), Diagnostics_Sign_Off_Received__c = Date.today(),
                                                        Hours_Spent__c = 2);
                                                        
        
        //Create List of Site
        Site_Issue__c sIssue2 = new Site_Issue__c(Site_Issue_Priority__c = 'High', Site_Issue_Short_Description__c = 'Test-Description',
                                                        Category__c = 'Test-Category', Data_Load_Type__c = Constants.HISTORICAL_RELOAD,
                                                        Crimson_Site_Issue_Description__c = 'Test Issue Description', RecordTypeId = CMADLRT,
                                                        Status__c = Constants.STATUS_SITE_ISSUE_22_SENT_EMAIL_UPDATE,
                                                        Project__c = project1.Id, Assigned_To_Contact__c = con.Id, CCC_Date_Observed__c = System.Today(),
                                                        Site_Issue_Created_Date__c = System.now().addDays(-54), Site_Issue_Close_Date__c = System.now().addDays(8),
                                                        Data_Load_Period_End__c = Date.today().addDays(-62),Data_Load_Period_Begin__c = Date.today(), Files_Received__c = Date.today(),
                                                        Internal_Load_Complete__c=Date.today(), Smoke_Test_Complete__c=Date.today(), Testing_Complete__c=Date.today(),
                                                        Ready_for_Final_QA__c=Date.today(), Moved_to_Production__c=Date.today(),Application_Version__c='13.01',
                                                        Member_Facing_Resolution_Summary__c='test');
        
        //Enabling trigger back
        Util.BypassAllTriggers = false;
        
        insert sIssue2;
        
        //Start Testing from here
        Test.StartTest();
        
        //insert Site Issue
        insert sIssue1;
        
        //Stop Testing from here
        Test.stopTest();
        
        System.assertEquals(Constants.STATUS_SITE_ISSUE_22_SENT_EMAIL_UPDATE, sIssue2.Status__c);
        System.assertEquals(Constants.STATUS_SITE_ISSUE_10_CLOSED_MEMBER_NOTIFIED, sIssue1.Status__c);
        
    }
    
    //Method modified by Ajit Surana - 08/13/2014 - CR-20140417-5130
    //Created an admin user in this method and run the test method as this fixed admin user.
    //Code added By - Bhavi Sharma - 08/13/2013 - CR-20121219-1968
    //Test mehod added for CosecutivelyDelayedLoad updation on Member Support
    public static testMethod void testpopulateConsecutivelyDelyedOnSiteIssue() {
        
        //Bypass Dupeblocker
        Util.IsTest(true);
        
        //Bypassing all trigger so then testing data can be created with ease
        Util.BypassAllTriggers = true;
        
        //Fetch profile from database
        List<Profile> profiles = [Select Id from Profile where Name = 'System Administrator' limit 1];
        
        //Assert for result
        System.assertEquals(1, profiles.size());
        
        //Test User Create
        User user1 = TestUtilities.CreatenewUser(profiles[0], true);
        
        //List of projects
        List<Project__c> projects = new List<Project__c>();
        
        //create new Project__c data
        Project__c project1 = new Project__c(Name = 'Test-Data',Recurring_Business_Analyst__c = user1.Id, Dedicated_Advisor__c = user1.Id, Crimson_Data_Analyst_Group_Lead__c = user1.Id);
        Project__c project2 = new Project__c(Name = 'Test-Data2',Recurring_Business_Analyst__c = user1.Id, Dedicated_Advisor__c = user1.Id, Crimson_Data_Analyst_Group_Lead__c = user1.Id);
        
        projects.add(project1);
        projects.add(project2);
        
        //Bypassing all trigger so then testing data can be created with ease
        Util.BypassAllTriggers = true;
        
        //Insert project
        insert projects;
        
        // get one record type name
        List<RecordType> recordTypes = [SELECT Id, DeveloperName FROM RecordType WHERE DeveloperName =:Constants.RECORD_TYPE_SITE_ISSUE_DEVELOPER_NAME_CCA_DATA_LOAD AND IsActive = true AND sObjectType = 'Site_Issue__c' ORDER BY DeveloperName Limit 1];
        
        //Asert or the record type
        System.assertEquals(1, recordTypes.size());
        
        //Create List of Site
        Site_Issue__c sIssue = new Site_Issue__c(Data_Load_Type__c = Constants.HISTORICAL_RELOAD, Crimson_Site_Issue_Description__c = 'Test Issue Description', 
                                                 RecordTypeId = recordTypes[0].Id, Project__c = projects[0].Id, 
                                                 Site_Issue_Created_Date__c = System.now().addDays(-54), 
                                                 Site_Issue_Close_Date__c = System.now().addMonths(-2), 
                                                 Data_Load_Period_End__c = Date.Today().addDays(-62),
                                                 Data_Load_Period_Begin__c = Date.today(), Files_Received__c = Date.today());
        
        //Run as test User of Specialist profile    
        System.runAs(user1) {
            
            //Enabling triggers back
            Util.BypassAllTriggers = false;
            
            //insert Site Issue
            insert sIssue;
            
            //Test starts here 
            Test.startTest();
            
            //Enabling triggers back
            Util.BypassAllTriggers = true;
            
            //query result 
            sIssue = [SELECT Consecutively_Delayed_Load__c, Total_Delay__c FROM Site_Issue__c WHERE Id =: sIssue.Id];
            
            Boolean ConsDelay1 = sIssue.Consecutively_Delayed_Load__c;
            
            //Members Support record
            sIssue = new Site_Issue__c(Data_Load_Type__c = Constants.HISTORICAL_RELOAD, Crimson_Site_Issue_Description__c = 'Test Issue Description', 
                                       RecordTypeId = recordTypes[0].Id, Project__c = projects[1].Id, Site_Issue_Created_Date__c = System.now().addDays(-54), 
                                       Site_Issue_Close_Date__c = System.now().addMonths(-1), Data_Load_Period_End__c = Date.Today().addDays(-62),
                                       Data_Load_Period_Begin__c = Date.today(), Files_Received__c = Date.today());
            
            //Enabling triggers back
            Util.BypassAllTriggers = false;
            
            //insert Site Issue
            insert sIssue;
            
            //query result 
            sIssue = [SELECT Consecutively_Delayed_Load__c, Total_Delay__c FROM Site_Issue__c WHERE Id =: sIssue.Id];
            
            Boolean ConsDelay2 = sIssue.Consecutively_Delayed_Load__c;
            
            //Test stops here
            Test.stopTest();
            
            //assert statements 1& 2
            System.assertEquals(false, ConsDelay1);
            System.assertEquals(false, ConsDelay2);
            
        }
    }       
    
    //Create a member support record and verify that is creates a corresponding case and synchronizes field values.  CR-4283
    static testmethod void testSyncMemSupportWithCase() {
        
        //Bypassing all triggers
        Util.BypassAllTriggers = true;
        
        //Create test data for the Sync Fields custom setting that syncs Mem Support -> Case fields
        TestUtilities.createSyncFields();
        
        //Create a project
        Project__c project = TestUtilities.createProject(true);
        
        //Create a member support record related to the project
        Site_Issue__c memberSupport = TestUtilities.createSiteIssue(project.Id, false);
        memberSupport.RecordTypeId = Constants.RECORD_TYPE_ID_SITE_ISSUE_CCA_SUPPORT_REQUEST;
        memberSupport.Status__c = '06 - Issue Resolved - Ticket Closed';
        
        //Enabling triggers back
        Util.BypassAllTriggers = false;
        
        test.startTest();
        insert memberSupport;
        test.stopTest();
        
        //Get the related case and confirm the correct field values synced
        Case msCase = [SELECT Id, Subject, CaseNumber, Priority, Origin, ContactId, Description, RecordType.DeveloperName
                       FROM Case WHERE Member_Support_Ticket__c = :memberSupport.Id];
        //Get the updated member support record
        memberSupport = [SELECT Id, Site_Issue_Short_Description__c, Case_Number__c, Site_Issue_Priority__c, 
                         Interaction_Type__c, Reported_By__c, Crimson_Site_Issue_Description__c
                         FROM Site_Issue__c WHERE Id = :memberSupport.Id];
        
        system.assertNotEquals(null, msCase,
                               'A case record should have been auto-generated based on the Member Support record.');
        system.assertEquals(memberSupport.Site_Issue_Short_Description__c, msCase.Subject,
                            'The Site Issue Short Description should have synchronized with Case.Subject.');
        system.assertEquals(memberSupport.Case_Number__c, msCase.CaseNumber,
                            'The Support Issue Number should have synchronized with Case.CaseNumber.');
        system.assertEquals(memberSupport.Site_Issue_Priority__c, msCase.Priority);
        system.assertEquals(memberSupport.Interaction_Type__c, msCase.Origin);
        system.assertEquals(memberSupport.Reported_By__c, msCase.ContactId);
        system.assertEquals(memberSupport.Crimson_Site_Issue_Description__c, msCase.Description);
        system.assertEquals(msCase.RecordType.DeveloperName, Constants.RECORD_TYPE_CASE_DEVELOPER_NAME_PT_SUPPORT_REQUEST);
    }
    
    static testmethod void testPopulateAssignedToUser() {
        
        //Bypassing all triggers
        util.BypassAllTriggers = true;
        
        //Create a contact
        Contact contact = TestUtilities.CreateNewContact(false);
        contact.FirstName = 'Salty';
        contact.LastName = 'Baxter';
        contact.Employee_ID__c = '13';  
        insert contact;
        
        //create a community user associated with that contact Id
        Profile portalProfile = [SELECT Id FROM Profile WHERE UserLicense.Name like '%High Volume Customer Portal' LIMIT 1];
        User communityUser = TestUtilities.CreateNewUser(portalProfile, false);
        communityUser.FirstName = 'Salty';
        communityUser.LastName = 'Baxter';
        communityUser.ContactId = contact.Id;
        insert communityUser;
        
        //create new project
        Project__c proj = TestUtilities.createProject(true);
        
        util.BypassAllTriggers = false;
        
        test.startTest();
        
        //create member support
        Site_Issue__c memberSupport = TestUtilities.createSiteIssue(proj.Id, false);
        memberSupport.Assigned_To_Contact__c = contact.Id;
        memberSupport.Status__c = '06 - Issue Resolved - Ticket Closed';
        
        insert memberSupport;
        
        //Stop test here
        Test.stopTest();
        
        //Grab the Project 
        proj = [SELECT Id, Crimson_Data_Analyst_Group_Lead__c FROM Project__c WHERE Id =:proj.Id];
        
        //Test to see if the value moved over from Member Support to Project successfully
        System.assertEquals(contact.Name, communityUser.Name);
    }
    
    static testmethod void testPopulateAccountFormalName() {
        
        //Bypassing all triggers
        util.BypassAllTriggers = true;
        
        //Create a contact
        Contact contact = TestUtilities.CreateNewContact(false);
        contact.FirstName = 'Salty';
        contact.LastName = 'Baxter';
        contact.Employee_ID__c = '13';  
        insert contact;
        
        //create a new institution
        Account acct = TestUtilities.CreateNewAccount(false);
        acct.Account_Formal_Name__c = 'Cleveland Clinic';
        insert acct;
        
        util.BypassAllTriggers = false;
        
        test.startTest();
        
        //create member support
        Site_Issue__c memberSupport = TestUtilities.createSiteIssue(null, false);
        memberSupport.Institution__c = acct.Id;
        memberSupport.recordTypeId = Schema.SObjectType.Site_Issue__c.getRecordTypeInfosByName().get('PIC Defect').getRecordTypeId();
        memberSupport.Status__c = 'New';
        
        insert memberSupport;
        
        //Stop test here 
        Test.stopTest();
         
        //Grab the member support record 
        memberSupport = [SELECT Id, Institution_Formal_Name_Text__c FROM Site_Issue__c WHERE Id = :memberSupport.Id];
        
        //Test to see if the Institution Formal Name populated successfully
        System.assertEquals(acct.Account_Formal_Name__c, memberSupport.Institution_Formal_Name_Text__c);
    }
    
    //Code added By - Abhinav Sharma - 07/12/2014 - CR-20140422-5173
    static testMethod void testUpdateAssignedToContact() {
        
        //Bypass Dupeblocker
        Util.IsTest(true);
        
        //Bypassing all trigger so then testing data can be created with ease
        Util.BypassAllTriggers = true;
        
        //Set to hold the record type names
        Set<String> setRecordTypeNames = new Set<String>();
        setRecordTypeNames.add('Compass_Connect_Ticket');
        setRecordTypeNames.add('Compass_Data_Analytics_Ticket');
        setRecordTypeNames.add('Compass_Implementation');
        setRecordTypeNames.add('Compass_Support_Issue');
        
        //get one record type name
        Map<Id, RecordType> mapRecordTypes = new Map<Id, RecordType>([SELECT Id, DeveloperName FROM RecordType WHERE DeveloperName IN : setRecordTypeNames 
                                                                      AND IsActive = true AND sObjectType = 'Site_Issue__c']); 
        
        //Asert or the record type
        System.assertEquals(4, mapRecordTypes.values().size());
        
        //RecordType
        Id rdType = Schema.SObjectType.Site_Issue__c.getRecordTypeInfosByName().get('Crimson Medical Director Service Request').getRecordTypeId();
        
        //Fetch profile from database
        List<Profile> profiles = [Select id from Profile where Name = 'System Administrator' limit 1];
        
        //Assert for result
        System.assertEquals(1, profiles.size());
        
        //Create a list of users 
        List<User> users = new List<User>();
        
        //Create User
        users.add(new User(Username = Math.random()+'@abc.com', LastName = 'Test User1', FirstName = 'Test1', Email = Math.random()+'@test.com',
                           Alias = 'Test1', EmailEncodingKey='UTF-8', languagelocalekey = 'en_US', ProfileId = profiles[0].Id, 
                           timezonesidkey = 'America/Los_Angeles', localesidkey = 'en_US', EmployeeNumber = '12121212', IsActive = true));
        users.add(new User(Username = Math.random()+'@abc.com', LastName = 'Test User2', FirstName = 'Test2', Email = Math.random()+'@test.com',
                           Alias = 'Test2', EmailEncodingKey='UTF-8', languagelocalekey = 'en_US', ProfileId = profiles[0].Id, 
                           timezonesidkey = 'America/Los_Angeles', localesidkey = 'en_US', EmployeeNumber = '13131313', IsActive = true));
        
        //Insert users
        insert users;
        
        //create new Account
        Account account = new Account(Name = 'TestCCC Account ', Account_Formal_Name__c = 'CCC Account');
        
        //insert account here
        insert account;
        
        //Create a list of Contact records
        List<Contact> conList = new List<Contact>();
        
        //create new Contact
        Contact con1 = new Contact(FirstName = 'Test', LastName = 'Contact1', Email = 'test1@test.com',
                                   AccountId = account.Id, Employee_ID__c = 'Test 1', Employee_User_Record__c = users[0].Id);
        
        //create new Contact
        Contact con2 = new Contact(FirstName = 'Test', LastName = 'Contact2', Email = 'test2@test.com',
                                   AccountId = account.Id, Employee_ID__c = 'Test 2', Employee_User_Record__c = null);
        
        conList.add(con1);
        conList.add(con2);
        
        //Insert Contacts
        insert conList;
        
        //List to hold the Project records
        List<Project__c> projects = new List<Project__c>();
        
        //Create new Project__c data
        Project__c project1 = new Project__c(Name = 'Test-Data1', Recurring_Business_Analyst__c = users[0].Id, 
                                             Dedicated_Advisor__c = users[0].Id, 
                                             Crimson_Data_Analyst_Group_Lead__c = users[0].Id);
        Project__c project2 = new Project__c(Name = 'Test-Data2', Recurring_Business_Analyst__c = users[0].Id, 
                                             Dedicated_Advisor__c = users[0].Id);
        Project__c project3 = new Project__c(Name = 'Test-Data3', Recurring_Business_Analyst__c = users[0].Id, 
                                             Dedicated_Advisor__c = users[0].Id, 
                                             Crimson_Data_Analyst_Group_Lead__c = users[1].Id);
        
        //populating list with records
        projects.add(project1);
        projects.add(project2);
        projects.add(project3);
        
        //insert Project data
        insert projects;
        
        //List to hold the Member Support records
        List<Site_Issue__c> sitIssueList = new List<Site_Issue__c>();
        
        //Insert Member Support Data
        Site_Issue__c sIssue1 = new Site_Issue__c(Support_Category__c = 'Bug Report', Crimson_Site_Issue_Description__c = 'Test Issue Description', 
                                                  RecordTypeId = mapRecordTypes.values()[0].Id, 
                                                  Project__c = projects[0].Id, Assigned_To_Contact__c = conList[0].Id,
                                                  Site_Issue_Short_Description__c = 'Test');
        
        //Insert Member Support Data
        Site_Issue__c sIssue2 = new Site_Issue__c(Support_Category__c = 'Bug Report', Site_Issue_Short_Description__c = 'Test',
                                                  Crimson_Site_Issue_Description__c = 'Test Issue Description', 
                                                  RecordTypeId = mapRecordTypes.values()[1].Id, Project__c = projects[0].Id,  
                                                  Summary__c = 'xyz', Business_Impact__c = 'abc');
        
        //Insert Member Support Data
        Site_Issue__c sIssue3 = new Site_Issue__c(Support_Category__c = 'Bug Report', 
                                                  RecordTypeId = mapRecordTypes.values()[2].Id,
                                                  Project__c = projects[0].Id, Site_Issue_Short_Description__c = 'Test', 
                                                  Site_Issue_Priority__c = 'Normal', 
                                                  Products_to_be_Dropped_Added__c = 'Spend');
        
        //Insert Member Support Data
        Site_Issue__c sIssue4 = new Site_Issue__c(RecordTypeId = rdType, Project__c = projects[0].Id, 
                                                  Assigned_To_Contact__c = conList[0].Id);
        
        //Insert Member Support Data
        Site_Issue__c sIssue5 = new Site_Issue__c(RecordTypeId = rdType, Project__c = projects[0].Id);
        
        //Insert Member Support Data
        Site_Issue__c sIssue6 = new Site_Issue__c(RecordTypeId = rdType, Project__c = projects[1].Id, 
                                                  Assigned_To_Contact__c = conList[0].Id);
        
        //Insert Member Support Data
        Site_Issue__c sIssue7 = new Site_Issue__c(RecordTypeId = rdType, Project__c = projects[1].Id, 
                                                  Assigned_To_Contact__c = null);
        
        //Insert Member Support Data
        Site_Issue__c sIssue8 = new Site_Issue__c(RecordTypeId = rdType, Project__c = projects[2].Id, 
                                                  Assigned_To_Contact__c = null);
        
        //Insert Member Support Data
        Site_Issue__c sIssue9 = new Site_Issue__c(RecordTypeId = rdType, Project__c = projects[2].Id, 
                                                  Assigned_To_Contact__c = conList[0].Id);
        
        //Insert Member Support Data
        Site_Issue__c sIssue10 = new Site_Issue__c(RecordTypeId = rdType, Project__c = null, 
                                                   Assigned_To_Contact__c = conList[0].Id);
        
        //Add records to List
        sitIssueList.add(sIssue1);
        sitIssueList.add(sIssue2);
        sitIssueList.add(sIssue3);
        sitIssueList.add(sIssue4);
        sitIssueList.add(sIssue5);
        sitIssueList.add(sIssue6);
        sitIssueList.add(sIssue7);
        sitIssueList.add(sIssue8);
        sitIssueList.add(sIssue9);
        sitIssueList.add(sIssue10);
        
        //Start test from here
        Test.startTest();
        
        //Run as test User of System Administrator profile    
        System.runAs(users[0]) {
            
            try {
                
                //Enabling triggers back
                Util.BypassAllTriggers = false;
                
                //Insert list of Member Support records
                insert sitIssueList;
                
                //Enabling triggers again
                Util.byPassAllTriggers = true;
                
                //query result for "Compass_Connect_Ticket" Record Type
                sitIssueList = [SELECT Id, Assigned_To_Contact__c , Expected_File_Received_Date__c  FROM Site_Issue__c];   
                
            } catch(Exception e){
            }
            
        }    
        
        //Stop test here
        Test.stopTest();
        
        //assert statements
        System.assertEquals(conList[0].Id, sitIssueList[0].Assigned_To_Contact__c );
        System.assertEquals(null, sitIssueList[1].Assigned_To_Contact__c );
        System.assertEquals(null, sitIssueList[2].Assigned_To_Contact__c );
    }
    
    //V_1.6 - Modified By - Mahendra Swarnkar - 08/27/2016 - CR-20160114-9520
    //Modified By - Abhinav Sharma - 05/30/2016 - CR-20150326-8810
    //Code added By - Ajit Surana - 10/17/2014 - CR-20140725-6664
    static testMethod void test_updateExpectedFileReceivedDate() {
        
        //Bypass Dupeblocker
        Util.IsTest(true);
        
        //Bypassing all trigger so then testing data can be created with ease
        Util.BypassAllTriggers = true;
        
        //RecordType
        Id msRType = Schema.SObjectType.Site_Issue__c.getRecordTypeInfosByName().get('CCA Data Load').getRecordTypeId();
        
        //RecordType
        Id projectRType = Schema.SObjectType.Project__c.getRecordTypeInfosByName().get('CCA').getRecordTypeId();
        
        //Fetch profile from database
        List<Profile> profiles = [Select id from Profile where Name = 'System Administrator' limit 1];
        
        //Assert for result
        System.assertEquals(1, profiles.size());
        
        //Create Users
        User user1 = TestUtilities.CreatenewUser(profiles[0], false);
        user1.IsActive = true;
        User user2 = TestUtilities.CreatenewUser(profiles[0], false);
        insert user1;
        
        //Create new Account
        Account account = new Account(Name = 'TestCCC Account ', Account_Formal_Name__c = 'CCC Account');
        
        //Insert account here
        insert account;
        
        //Create new Contacts
        Contact con1 = TestUtilities.CreateNewContact(false);
        con1.Employee_User_Record__c = user1.Id;
        con1.Employee_ID__c = '13';
        con1.AccountId = account.Id;
        Contact con2 = TestUtilities.CreateNewContact(false);
        con2.AccountId = account.Id;
        con2.Employee_ID__c = '15';
        con2.Employee_User_Record__c = null;
        insert con1;
        insert con2;
        
        //List to hold the Project records
        List<Project__c> projects = new List<Project__c>();
        
        //Create new Project__c data
        Project__c project1 = new Project__c(Name = 'Test-Data1', Recurring_Business_Analyst__c = user1.Id, 
                                             Dedicated_Advisor__c = user1.Id, RecordTypeId = projectRType,
                                             Crimson_Data_Analyst_Group_Lead__c = user1.Id);
        Project__c project2 = new Project__c(Name = 'Test-Data2', Recurring_Business_Analyst__c = user1.Id, 
                                             RecordTypeId  = projectRType, Dedicated_Advisor__c = user1.Id);
        
        //populating list with records
        projects.add(project1);
        projects.add(project2);
        
        //Insert Project data
        insert projects;
        
        //List to hold the Member Support records
        List<Site_Issue__c> sitIssueList = new List<Site_Issue__c>();
        
        //Insert Member Support Data
        Site_Issue__c sIssue1 = new Site_Issue__c(Support_Category__c = 'Bug Report', Crimson_Site_Issue_Description__c = 'Test Issue Description', 
                                                  RecordTypeId = msRType, Data_Load_Type__c = 'OPPE Deployment',
                                                  Data_Load_Period_End__c = System.Today(), Crimson_Diagnostic_URL__c = 'Test',
                                                  Project__c = projects[0].Id, Assigned_To_Contact__c = con1.Id,
                                                  Site_Issue_Short_Description__c = 'Test',
                                                  No_OPPE_Measures_Implemented__c = 2);
        
        //Insert Member Support Data
        Site_Issue__c sIssue2 = new Site_Issue__c(Support_Category__c = 'Bug Report', Site_Issue_Short_Description__c = 'Test',
                                                  Crimson_Site_Issue_Description__c = 'Test Issue Description', 
                                                  Data_Load_Type__c = 'OPPE Deployment', Business_Impact__c = 'abc',
                                                  Data_Load_Period_End__c = System.Today(), Crimson_Diagnostic_URL__c = 'Test',
                                                  RecordTypeId = msRType, Project__c = projects[0].Id,
                                                  No_OPPE_Measures_Implemented__c = 2);
        
        //Insert Member Support Data
        Site_Issue__c sIssue3 = new Site_Issue__c(Support_Category__c = 'Bug Report', Data_Load_Period_End__c = System.Today(),
                                                  Data_Load_Type__c = 'OPPE Deployment', Project__c = projects[1].Id,
                                                  Site_Issue_Short_Description__c = 'Test', 
                                                  Site_Issue_Priority__c = 'Normal', Crimson_Diagnostic_URL__c = 'Test',
                                                  Products_to_be_Dropped_Added__c = 'Spend',
                                                  No_OPPE_Measures_Implemented__c = 2,
                                                  First_Comment_Date_Time__c = System.today(),
                                                  Site_Issue_Close_Date__c = System.today(),
                                                  Actual_Resolution_Date__c = System.today(),
                                                  Date_Time_Acknowledged__c = System.now());
        
        //Add records to List
        sitIssueList.add(sIssue1);
        sitIssueList.add(sIssue2);
        sitIssueList.add(sIssue3);
        
        //Variables for later test assertions
        Integer SiteIssueListSize1;
        Date SiteIssueListExpDate1;
        
        //Start test from here
        Test.startTest();
        
        //Enabling triggers back
        Util.BypassAllTriggers = false;
        
        //Insert list of Member Support records
        insert sitIssueList;
        
        //Enabling triggers again
        Util.byPassAllTriggers = true;
        
        //Update Site_Issue__c records values
        sitIssueList[0].Crimson_Data_Lag_1__c = 2;
        sitIssueList[1].Crimson_Data_Lag_1__c = 3;
        sitIssueList[2].Crimson_Data_Lag_1__c = 4;
        
        //Enabling triggers back
        Util.BypassAllTriggers = false;
        
        //Update the list
        update sitIssueList;
        
        //Enabling triggers again
        Util.byPassAllTriggers = true;
        
        //Query to get desired results
        sitIssueList = [SELECT Id, Expected_File_Received_Date__c FROM Site_Issue__c];
        
        SiteIssueListSize1 = sitIssueList.size();
        SiteIssueListExpDate1 = sitIssueList[0].Expected_File_Received_Date__c;
        
        //Update Site_Issue__c records values
        sitIssueList[0].Application_Version__c = '14.01';
        sitIssueList[0].Status__c = '10 - Closed, Member Notified';
        sitIssueList[0].Site_Issue_Close_Date__c = System.Today();
        sitIssueList[0].Files_Received__c = System.Today();
        sitIssueList[0].Internal_Load_Complete__c = System.Today();
        sitIssueList[0].Smoke_Test_Complete__c = System.Today();
        sitIssueList[0].Testing_Complete__c = System.Today();
        sitIssueList[0].Ready_for_Final_QA__c = System.Today();
        sitIssueList[0].Moved_to_Production__c = System.Today();
        sitIssueList[0].Data_Submission_Target_Date__c = System.Today();
        sitIssueList[0].Diagnostics_Sent__c = System.Today();
        sitIssueList[0].Diagnostics_Sign_Off_Received__c = System.Today();
        sitIssueList[0].Hours_Spent__c = 5;
        
        //Enabling triggers back
        Util.BypassAllTriggers = false;
        
        //V_1.6 - Added By - Mahendra Swarnkar - 08/27/2016 - CR-20160114-9520
        
        //Query to hold Member support
        List<Site_Issue__c> issues = [Select Id, Elapsed_Open_to_Close_Hours__c, Elapsed_Open_to_Actual_Resolution_Hours__c,
                                     Elapsed_Open_to_Acknowledged_Hours__c, Elapsed_Open_to_First_Response_Hours__c,
                                     Date_Time_Acknowledged__c From Site_Issue__c Where Id =: sitIssueList[2].Id];
        
        //Assertion
        System.assertNotEquals(null, issues[0].Elapsed_Open_to_Close_Hours__c);
        System.assertNotEquals(null, issues[0].Elapsed_Open_to_Actual_Resolution_Hours__c);
        System.assertNotEquals(null, issues[0].Elapsed_Open_to_Acknowledged_Hours__c);
        System.assertNotEquals(null, issues[0].Elapsed_Open_to_First_Response_Hours__c);
        System.assertNotEquals(null, issues[0].Elapsed_Open_to_Close_Hours__c);

        //System.assertEquals(18, issues[0].Elapsed_Open_to_Close_Hours__c);
        //System.assertEquals(18, issues[0].Elapsed_Open_to_Actual_Resolution_Hours__c);
        //System.assertEquals(9, issues[0].Elapsed_Open_to_Acknowledged_Hours__c);
        //System.assertEquals(18, issues[0].Elapsed_Open_to_First_Response_Hours__c);
        //System.assertEquals(18, issues[0].Elapsed_Open_to_Close_Hours__c);
        
        //V_1.6 - Modified By - Mahendra Swarnkar - 08/27/2016 - CR-20160114-9520 - Upto here
        
        //Stop test here
        Test.stopTest();
        
        //Update the list
        update sitIssueList;
        
        //Enabling triggers again
        Util.byPassAllTriggers = true;
        
        //Query to get desired results
        projects = [SELECT Id, Elapsed_MS_Data_Load_Period_Data_Lag__c FROM Project__c WHERE ID IN : projects];
        
        //Assert statements
        System.assert(SiteIssueListSize1>0);
        System.assertEquals(System.Today().addDays(2), SiteIssueListExpDate1);
        
        //Assert statements
        System.assertEquals(2, projects.size());
        System.assertEquals(System.Today().addDays(2), projects[0].Elapsed_MS_Data_Load_Period_Data_Lag__c );   
    }       
    
    //New test Method added - Ajit Surana - 01/20/2015 - CR-20150102-8430
    static testmethod void testUpdate_PCP_Revenue_On_Project() {
        
        //Bypassing all triggers so then test data can be created for testing purpose
        Util.BypassAllTriggers = true;
        
        //Fetch profile from database
        List<Profile> profiles = [Select id from Profile where Name = 'System Administrator' limit 1];
        
        //Assert for result
        System.assertEquals(1, profiles.size());
        
        //Create User
        User user1 = TestUtilities.CreatenewUser(profiles[0], true);
        User user2 = TestUtilities.CreatenewUser(profiles[0], true);
        
        Contact con1 = TestUtilities.CreateNewContact(false);
        con1.Employee_ID__c = 'Test1';
        con1.Employee_User_Record__c = user1.Id;
        
        Contact con2 = TestUtilities.CreateNewContact(false);
        con2.Employee_ID__c = 'Test2';
        con2.Employee_User_Record__c = user2.Id;
        
        //Create a list of Contacts 
        List<Contact> contacts = new List<Contact> { con1, con2 };
            insert contacts;
        
        //List to hold Project records
        List<Project__c> projects = new List<Project__c>();
        
        //create new Project__c data
        Project__c project1 = new Project__c(Name = 'Test-Data1',Recurring_Business_Analyst__c = user1.Id, Dedicated_Advisor__c = user1.Id, 
                                             Crimson_Data_Analyst_Group_Lead__c = user1.Id, Implementation_Pod__c = 'Test', Crimson_Data_Lag__c = 10, Load_Frequency__c = 'Test');
        
        //create new Project__c data
        Project__c project2 = new Project__c(Name = 'Test-Data2',Recurring_Business_Analyst__c = user1.Id, Dedicated_Advisor__c = user1.Id, 
                                             Crimson_Data_Analyst_Group_Lead__c = user1.Id, Current_Data_Period_New__c = Date.Today().addDays(-62),
                                             Latest_Data_Load__c = Date.today());
        
        projects.add(project1);
        projects.add(project2);
        
        //Insert list into database
        insert projects;
        
        //Set of Developer Name for Site Issue's RecordType
        Set<String> setRecordTypeNames = new Set<String>();
        setRecordTypeNames.add(Constants.RECORD_TYPE_SITE_ISSUE_DEVELOPER_NAME_CMA_DATA_LOAD_MIGRATION);
        setRecordTypeNames.add(Constants.RECORD_TYPE_SITE_ISSUE_DEVELOPER_NAME_CCA_DATA_LOAD);
        
        // get one record type name
        List<RecordType> recordTypes = [SELECT Id, DeveloperName FROM RecordType WHERE DeveloperName IN: setRecordTypeNames AND IsActive = true AND sObjectType = 'Site_Issue__c' ORDER BY DeveloperName Limit 2];
        
        //Asert or the record type
        System.assertEquals(2, recordTypes.size());
        
        Contact con = TestUtilities.CreateNewContact(false);
        con.Employee_ID__c = 'Test1';
        insert con;
        
        //Create List of Site
        Site_Issue__c sIssue = new Site_Issue__c(Site_Issue_Priority__c = 'High', Site_Issue_Short_Description__c = 'Test-Description',
                                                 Category__c = 'Test-Category', Data_Load_Type__c = Constants.HISTORICAL_RELOAD, Cause_for_Delay__c = 'CDA Issues',
                                                 Crimson_Site_Issue_Description__c = 'Test Issue Description', RecordTypeId = recordTypes[1].Id,
                                                 Project__c = projects[0].Id, Assigned_To_Contact__c = con.Id, CCC_Date_Observed__c = System.Today(),
                                                 Site_Issue_Created_Date__c = System.now().addDays(-54), Site_Issue_Close_Date__c = System.now().addDays(8),
                                                 Data_Load_Period_End__c = Date.Today().addDays(-62),Data_Load_Period_Begin__c = Date.today(),
                                                 Status__c = '22 - Production Migration Complete', Percent_of_PCP_Revenue_Not_Captured__c = 10,
                                                 Files_Received__c = Date.today(), Estimated_Prod_Team_Transition_Date__c = Date.today());
        
        //Enabling triggers back
        Util.BypassAllTriggers = false;
        
        //Test starts here
        Test.startTest();
        
        //insert Site Issue
        insert sIssue;
        
        //Test stops here
        Test.stopTest();
        
        //Query data 
        projects = [SELECT Id, Percent_of_PCP_Not_Captured__c FROM Project__c WHERE Id =: projects[0].Id];
        
        //assert statements
        System.assertEquals(sIssue.Percent_of_PCP_Revenue_Not_Captured__c, projects[0].Percent_of_PCP_Not_Captured__c);
    }
    
    static testMethod void test_BeforeEventsForMS() {
        
        //Bypass Dupeblocker
        Util.IsTest(true);
        
        //Bypassing all trigger so then testing data can be created with ease
        Util.BypassAllTriggers = true;
        
        //Create new Account
        Account account = new Account(Name = 'Test Account ', Account_Formal_Name__c = 'Test Account');
        insert account;
        
        //Create a list of Contact records
        List<Contact> conList = new List<Contact>();
        
        //create new Contact
        Contact con1 = new Contact(FirstName = 'Test', LastName = 'Contact1', Email = 'test1@test.com',
                                   AccountId = account.Id, Employee_ID__c = 'Test 1');
        
        //create new Contact
        Contact con2 = new Contact(FirstName = 'Test', LastName = 'Contact2', Email = 'test2@test.com',
                                   AccountId = account.Id, Employee_ID__c = 'Test 2');
        
        conList.add(con1);
        conList.add(con2);
        
        //Insert Contacts
        insert conList;
        
        //RecordType
        List<RecordType> projectRType = [SELECT ID, DeveloperName FROM RecordType WHERE DeveloperName = 'CCA' 
                                         AND IsActive = true AND sObjectType = 'Project__c'];
        System.assert(projectRType != null);
        
        //List to hold the Project records
        List<Project__c> projects = new List<Project__c>();
        
        //Create new Project__c data
        Project__c project1 = new Project__c(Name = 'Test-Data1', Notes_Implementation__c = 'testing', RecordTypeId = projectRType[0].ID,
                                             Crimson_Data_Lag__c = 2, Recurring_Business_Analyst__c = Userinfo.getuserid(),
                                             Milliman_Analyst__c = Userinfo.getuserid(), Crimson_Data_Analyst_Group_Lead__c = Userinfo.getuserid(),
                                             Data_Analyst__c = Userinfo.getuserid(), Custom_SQL__c = 'Testing');
        
        Project__c project2 = new Project__c(Name = 'Test-Data2', Notes_Implementation__c = 'testing', RecordTypeId = projectRType[0].ID,
                                             Crimson_Data_Lag__c = 2, Recurring_Business_Analyst__c = Userinfo.getuserid(),
                                             Milliman_Analyst__c = Userinfo.getuserid(), Crimson_Data_Analyst_Group_Lead__c = Userinfo.getuserid(),
                                             Data_Analyst__c = Userinfo.getuserid(), Custom_SQL__c = 'Testing');
        
        Project__c project3 = new Project__c(Name = 'Test-Data3', Notes_Implementation__c = 'testing', RecordTypeId = projectRType[0].ID,
                                             Crimson_Data_Lag__c = 2, Recurring_Business_Analyst__c = Userinfo.getuserid(),
                                             Milliman_Analyst__c = Userinfo.getuserid(), Crimson_Data_Analyst_Group_Lead__c = Userinfo.getuserid(),
                                             Data_Analyst__c = Userinfo.getuserid(), Custom_SQL__c = 'Testing');
        
        Project__c project4 = new Project__c(Name = 'Test-Data4', RecordTypeId = projectRType[0].ID, Project_Manager__c = Userinfo.getUserId());
        Project__c project5 = new Project__c(Name = 'Test-Data5', RecordTypeId = projectRType[0].ID, Project_Manager__c = Userinfo.getUserId());
        
        //populating list with records
        projects.add(project1);
        projects.add(project2);
        projects.add(project3);
        projects.add(project4);
        projects.add(project5);
        
        //insert Project data
        insert projects;
        
        //Set to hold the record type names
        Set<String> setRecordTypeNames = new Set<String>();
        setRecordTypeNames.add('CCA_Data_Load');
        setRecordTypeNames.add('CCA_Support_Request');
        setRecordTypeNames.add('CPRM_Data_Load');
        
        //get one record type name
        List<RecordType> listRecordTypes = new List<RecordType>([SELECT Id, DeveloperName FROM RecordType WHERE DeveloperName IN : setRecordTypeNames 
                                                                 AND IsActive = true AND sObjectType = 'Site_Issue__c' ORDER BY DeveloperName ASC]); 
        
        //List to hold the Member Support records
        List<Site_Issue__c> sitIssueList = new List<Site_Issue__c>();
        
        //Insert Member Support Data
        Site_Issue__c sIssue1 = new Site_Issue__c(RecordTypeId = listRecordTypes[2].ID, Project__c = projects[0].Id,
                                                  Files_Received__c = System.today(),
                                                  Diagnostics_Sent__c = System.today().addDays(2), 
                                                  Production_Migration_Approved__c = System.today().addDays(3),
                                                  Moved_to_Production__c = System.today().addDays(4), 
                                                  Final_QA_Complete__c = System.today().addDays(5),
                                                  Testing_Complete__c = System.today().addDays(6), 
                                                  Files_Sent_to_Milliman__c = System.today().addDays(7),
                                                  DB_Received_from_Milliman__c = System.today().addDays(8),
                                                  Data_Load_Type__c = 'testing',
                                                  Site_Issue_Short_Description__c = 'Test-Description',
                                                  Category__c = 'Test-Category',
                                                  Data_Load_Period_End__c = Date.Today().addDays(62),
                                                  Data_Load_Period_Begin__c = Date.today());
        
        //Insert Member Support Data
        Site_Issue__c sIssue2 = new Site_Issue__c(RecordTypeId = listRecordTypes[2].ID, Project__c = projects[1].Id,
                                                  Files_Received__c = System.today(),
                                                  Diagnostics_Sent__c = System.today().addDays(-2), 
                                                  Production_Migration_Approved__c = System.today().addDays(-3),
                                                  Moved_to_Production__c = System.today().addDays(-4), 
                                                  Final_QA_Complete__c = System.today().addDays(-5),
                                                  Testing_Complete__c = System.today().addDays(-6), 
                                                  Files_Sent_to_Milliman__c = System.today().addDays(-7),
                                                  DB_Received_from_Milliman__c = System.today().addDays(-8),
                                                  Data_Load_Type__c = 'testing',
                                                  Site_Issue_Short_Description__c = 'Test-Description',
                                                  Category__c = 'Test-Category',
                                                  Data_Load_Period_End__c = Date.Today().addDays(62),
                                                  Data_Load_Period_Begin__c = Date.today());
        
        //Insert Member Support Data
        Site_Issue__c sIssue3 = new Site_Issue__c(RecordTypeId = listRecordTypes[2].ID, Project__c = projects[2].Id,
                                                  Data_Load_Type__c = 'testing',
                                                  Site_Issue_Short_Description__c = 'Test-Description',
                                                  Category__c = 'Test-Category',
                                                  Data_Load_Period_End__c = Date.Today().addDays(62),
                                                  Data_Load_Period_Begin__c = Date.today());
        
        //Insert Member Support Data
        Site_Issue__c sIssue4 = new Site_Issue__c(RecordTypeId = listRecordTypes[1].ID, Project__c = projects[3].Id,
                                                  Data_Load_Type__c = 'testing',
                                                  Site_Issue_Short_Description__c = 'Test-Description',
                                                  Category__c = 'Test-Category',
                                                  Data_Load_Period_End__c = Date.Today().addDays(62),
                                                  Data_Load_Period_Begin__c = Date.today());
        
        //Insert Member Support Data
        Site_Issue__c sIssue5 = new Site_Issue__c(RecordTypeId = listRecordTypes[0].ID, Project__c = projects[4].Id,
                                                  Data_Load_Type__c = 'testing',
                                                  Site_Issue_Short_Description__c = 'Test-Description',
                                                  Category__c = 'Test-Category',
                                                  Data_Load_Period_End__c = Date.Today().addDays(62),
                                                  Data_Load_Period_Begin__c = Date.today());
        
        //Add records to List
        sitIssueList.add(sIssue1);
        sitIssueList.add(sIssue2);
        sitIssueList.add(sIssue3);
        sitIssueList.add(sIssue4);
        sitIssueList.add(sIssue5);
        
        //Start test from here
        Test.startTest();
        
        //Enabling triggers back
        Util.BypassAllTriggers = false;
        
        //Insert Member Support records
        insert sitIssueList;
        
        //Test will stop here
        Test.stopTest();
        
        //Asert or the record type
        System.assertEquals(3, listRecordTypes.size());
        System.assertEquals('CCA_Data_Load', listRecordTypes[0].DeveloperName);
        System.assertEquals('CCA_Support_Request', listRecordTypes[1].DeveloperName);
        System.assertEquals('CPRM_Data_Load', listRecordTypes[2].DeveloperName);
        
        //Quering for the results
        sitIssueList = [SELECT ID, Notes_Recurring_Data__c, Crimson_Data_Lag_1__c, Production_Business_Analyst__c, Data_Analyst_Group_Lead__c, Crimson_Data_Analyst__c,
                        Milliman_Analyst__c, Custom_SQL__c, Technical_Project_Manager_new__c FROM Site_Issue__c ORDER BY Name ASC];
        System.assertEquals('testing', sitIssueList[0].Notes_Recurring_Data__c);
        System.assertEquals(2, sitIssueList[0].Crimson_Data_Lag_1__c);
        System.assertEquals(Userinfo.getUserId(), sitIssueList[0].Production_Business_Analyst__c);  
        System.assertEquals(Userinfo.getUserId(), sitIssueList[0].Data_Analyst_Group_Lead__c);
        System.assertEquals(Userinfo.getUserId(), sitIssueList[0].Crimson_Data_Analyst__c);
        System.assertEquals(Userinfo.getUserId(), sitIssueList[0].Milliman_Analyst__c);
        System.assertEquals('Testing', sitIssueList[0].Custom_SQL__c);
        System.assertEquals(null, sitIssueList[0].Technical_Project_Manager_new__c);
        System.assertEquals(null, sitIssueList[1].Technical_Project_Manager_new__c);
        System.assertEquals(null, sitIssueList[2].Technical_Project_Manager_new__c);
        System.assertEquals(UserInfo.getName(), sitIssueList[3].Technical_Project_Manager_new__c);
        System.assertEquals(UserInfo.getName(), sitIssueList[3].Technical_Project_Manager_new__c);
    }
    
    //Updated by Colin McGloin as part of the refactoring for increased code coverage
    static testMethod void test_CPRMDataLoadMS() {
        
        //Bypass Dupeblocker
        Util.IsTest(true);
        
        //Bypassing all trigger so then testing data can be created with ease
        Util.BypassAllTriggers = true;
        
        //Create new Account
        Account account = new Account(Name = 'Test Account ', Account_Formal_Name__c = 'Test Account');
        insert account;
        
        //create new Contact
        Contact con = new Contact(FirstName = 'Test', LastName = 'Contact1', Email = 'test1@test.com',
                                  AccountId = account.Id, Employee_ID__c = 'Test 1');
        insert con;
        
        //RecordType
        List<RecordType> projectRType = [SELECT ID, DeveloperName FROM RecordType WHERE DeveloperName = 'CCA' 
                                         AND IsActive = true AND sObjectType = 'Project__c'];
        System.assert(projectRType != null);
        
        //Create new Project__c data
        Project__c project1 = new Project__c(Name = 'Test-Data1', Notes_Implementation__c = 'The Great Ohioan', RecordTypeId = projectRType[0].ID,
                                            Crimson_Data_Lag__c = 2, Recurring_Business_Analyst__c = Userinfo.getuserid(),
                                            Milliman_Analyst__c = Userinfo.getuserid(), Crimson_Data_Analyst_Group_Lead__c = Userinfo.getuserid(),
                                            Data_Analyst__c = Userinfo.getuserid(), Custom_SQL__c = 'Testing');
        insert project1;
        
        //get one record type name
        List<RecordType> listRecordTypes = new List<RecordType>([SELECT Id, DeveloperName FROM RecordType WHERE DeveloperName = 'CPRM_Data_Load' 
                                                                 AND IsActive = true AND sObjectType = 'Site_Issue__c']); 
        System.assert(listRecordTypes != null);      
        
        //List to hold the Member Support records
        List<Site_Issue__c> sitIssueList = new List<Site_Issue__c>();
        
        //Insert Member Support Data
        Site_Issue__c sIssue1 = new Site_Issue__c(RecordTypeId = listRecordTypes[0].ID, Project__c = project1.Id,
                                                  Files_Received__c = System.today(),
                                                  Diagnostics_Sent__c = System.today().addDays(2), 
                                                  Production_Migration_Approved__c = System.today().addDays(3),
                                                  Moved_to_Production__c = System.today().addDays(4), 
                                                  Final_QA_Complete__c = System.today().addDays(5),
                                                  Testing_Complete__c = System.today().addDays(6), 
                                                  Files_Sent_to_Milliman__c = System.today().addDays(7),
                                                  DB_Received_from_Milliman__c = System.today().addDays(8),
                                                  Data_Load_Type__c = 'testing',
                                                  Site_Issue_Short_Description__c = 'Test-Description',
                                                  Category__c = 'Test-Category',
                                                  Data_Load_Period_End__c = Date.Today().addDays(62),
                                                  Data_Load_Period_Begin__c = Date.today());
        
        Site_Issue__c sIssue2 = new Site_Issue__c(RecordTypeId = listRecordTypes[0].ID, Project__c = project1.Id,
                                                  Data_Load_Type__c = 'testing',
                                                  Site_Issue_Short_Description__c = 'Test-Description',
                                                  Category__c = 'Test-Category',
                                                  Data_Load_Period_End__c = Date.Today().addDays(62),
                                                  Data_Load_Period_Begin__c = Date.today());
        
        sitIssueList.add(sIssue1);                                  
        sitIssueList.add(sIssue2);
        
        //Start testing here
        Test.startTest();
        
        //Enabling triggers back
        Util.BypassAllTriggers = false;
        insert sitIssueList;
        
        //Stop test here
        Test.stopTest();
        
        //Pull through the Project & Member Support for record comparison
        project1 = [SELECT Name , Notes_Implementation__c ,Crimson_Data_Lag__c, Recurring_Business_Analyst__c, Milliman_Analyst__c,
                   Crimson_Data_Analyst_Group_Lead__c, Data_Analyst__c, Custom_SQL__c FROM Project__c WHERE Id = :project1.Id];
        
        sIssue1 = [SELECT Id, Notes_Recurring_Data__c, Crimson_Data_Lag_1__c, Production_Business_Analyst__c, Data_Analyst_Group_Lead__c,
                          Crimson_Data_Analyst__c, Milliman_Analyst__c, Custom_SQL__c FROM Site_Issue__c WHERE Id = :sitIssueList[0].Id];
        
        //Assert the Project values came over to the Member Support record without issue
        System.assertEquals(sIssue1.Notes_Recurring_Data__c, project1.Notes_Implementation__c);
        System.assertEquals(sIssue1.Crimson_Data_Lag_1__c, project1.Crimson_Data_Lag__c);
        System.assertEquals(sIssue1.Production_Business_Analyst__c, project1.Recurring_Business_Analyst__c);
        System.assertEquals(sIssue1.Data_Analyst_Group_Lead__c, project1.Data_Analyst__c);
        System.assertEquals(sIssue1.Milliman_Analyst__c, project1.Milliman_Analyst__c);
        System.assertEquals(sIssue1.Custom_SQL__c, project1.Custom_SQL__c);
    }
    
    //Added By - Ajit Surana - 03/02/2015 - CR-20150106-8468
    static testmethod void testvalidateContactFlagValues() {
        
        //Bypass Dupeblocker
        Util.IsTest(true);
        Util.IsTesting = true;
        
        //String to hold error message
        String errormessage;
        
        //Byapssing all triggers so then test data can be created for testing purpose
        Util.BypassAllTriggers = true;
        
        //Fetch profile from database
        List<Profile> profiles = [Select Id From Profile Where Name = 'System Administrator' LIMIT 1];
        
        //Assert for result
        System.assertEquals(1, profiles.size());
        
        //Create two users 
        User user1 = TestUtilities.CreatenewUser(profiles[0], true);
        User user2 = TestUtilities.CreatenewUser(profiles[0], true);
        
        //Create new Account
        Account account = new Account(Name = 'TestBIPC Account ', Account_Formal_Name__c = 'BIPC Account');
        
        //insert account here
        insert account;
        
        //Create a list of contact
        List<Contact> contacts = new List<Contact>();
        
        //Create new Contact
        contacts.add(new Contact(FirstName = 'Test', LastName = 'Contact1', Email = 'test1@test.com', AccountId = account.Id, Employee_ID__c = 'Test1',
                                 EmailBouncedReason = '', EmailBouncedDate = null));
        
        contacts.add(new Contact(FirstName = 'Test', LastName = 'Contact2', Email = 'test2@test.com', AccountId = account.Id, Employee_ID__c = 'Test2',
                                 EmailBouncedReason = '', EmailBouncedDate = null));
        
        //insert contacts
        insert contacts;
        
        //Create new Program record 
        Program__c program_BIPC = TestUtilities.CreateNewProgram(false);
        program_BIPC.Program_Acronym__c = 'BIPC';
        
        insert program_BIPC;
        
        //Create new Project__c data
        Project__c project1 = new Project__c(Name = 'Test-Data-BIPC',Recurring_Business_Analyst__c = user1.Id, Dedicated_Advisor__c = user1.Id, Product__c = program_BIPC.Id,
                                             Project_Manager__c = user1.Id, Crimson_Data_Analyst_Group_Lead__c = user1.Id, Institution__c = account.Id);
        
        //insert Project data
        insert project1;
        
        //Create a list of Project Roles
        List<Project_Role__c> pRoles = new List<Project_Role__c>();
        
        //Create new Project Role data
        pRoles.add(new Project_Role__c(Project__c = project1.Id, Contact__c = contacts[0].Id, CCC_Include_in_Data_Load_Automated_Email__c = true));
        pRoles.add(new Project_Role__c(Project__c = project1.Id, Contact__c = contacts[1].Id, CCC_Include_in_Data_Load_Automated_Email__c = true));
        
        //insert Project Roles
        insert pRoles;
        
        // get one record type name
        Id rcordType = Schema.SObjectType.Site_Issue__c.getRecordTypeInfosByName().get('CCA Data Load').getRecordTypeId();
        
        //Create List of Site
        Site_Issue__c sIssue1 = new Site_Issue__c(Site_Issue_Priority__c = 'High', Site_Issue_Short_Description__c = 'Test-Description',
                                                  Category__c = 'Test-Category', Data_Load_Type__c = Constants.CURRENT, Project__c = project1.Id,
                                                  Crimson_Site_Issue_Description__c = 'Test Issue Description', RecordTypeId = rcordType,
                                                  Status__c = Constants.STATUS_SITE_ISSUE_22_SENT_EMAIL_UPDATE, Assigned_To_Contact__c = contacts[0].Id, 
                                                  CCC_Date_Observed__c = System.Today(), Site_Issue_Created_Date__c = System.now().addDays(-54),
                                                  Site_Issue_Close_Date__c = System.now().addDays(8), Hours_Spent__c = 2,
                                                  Data_Load_Period_End__c = Date.Today().addDays(-62),Application_Version__c='13.01',
                                                  Data_Load_Period_Begin__c = Date.today(), Files_Received__c = Date.today(),Internal_Load_Complete__c=Date.today(), Smoke_Test_Complete__c=Date.today(), Testing_Complete__c=Date.today(),
                                                  Ready_for_Final_QA__c=Date.today(), Moved_to_Production__c=Date.today(), Reason_for_Delay__c = 'Other',
                                                  Member_Facing_Resolution_Summary__c='test', Data_Submission_Target_Date__c = Date.today(),
                                                  Diagnostics_Sent__c = Date.today(), Diagnostics_Sign_Off_Received__c = Date.today());
        
        //Enabling trigger back
        Util.BypassAllTriggers = false;
    
        //Start Testing from here
        Test.StartTest();
    
        //Try-catch block to catch any error message if occured
        try{
    
            //Enabling trigger back
            Util.BypassAllTriggers = false;
    
            //insert Site Issue
            insert sIssue1;
    
        }catch(Exception e){
            errormessage = e.getMessage();       
        }
        
        //Stop Testing from here
        Test.stopTest();
        
        contacts = [SELECT Name, EmailBouncedReason From Contact];
        
        //Assert the email bounced reason is equal to null
        System.assertEquals(Contacts[0].EmailBouncedReason, null);
}
    
    //Added By - Ajit Surana - 05/07/2015 - CR-20140813-6993
    static testmethod void testvalidateAndPopulateQANotes() {
        
    	Util.IsTest(true);
        Util.IsTesting = true;
        
        //Byapssing all triggers so then test data can be created for testing purpose
        Util.BypassAllTriggers = true;
        
        //Account
        Account account = new Account(Name = 'TestBIPC Account ', Account_Formal_Name__c = 'BIPC Account');
        insert account;
        
        //Contact
        Contact contact = new Contact(FirstName = 'Test', LastName = 'Contact1', Email = 'test1@test.com', 
                                      AccountId = account.Id, Employee_ID__c = 'Test1');
        insert contact;
        
        //Project
        Project__c project = new Project__c(Name = 'Test Project');
        insert project; 
        
        //List of eligible MS record types
        Id rcordType = Schema.SObjectType.Site_Issue__c.getRecordTypeInfosByName().get('CMA Data Load/Migration').getRecordTypeId();
        
        //List to hold the member support records
        List<Site_Issue__c> siteIssues = new List<Site_Issue__c>();
        List<Site_Issue__C> memberSupports = new List<Site_Issue__c>();
        
        //Ste issue
        Site_Issue__c sIssue_1 = new Site_Issue__c(Site_Issue_Priority__c = 'High', 
                                                   Site_Issue_Short_Description__c = 'Test-Description',
                                                   Category__c = 'Test-Category 1', Data_Load_Type__c = Constants.CURRENT, 
                                                   Project__c = project.Id, RecordTypeId = rcordType,
                                                   Assigned_To_Contact__c = contact.Id, 
                                                   Site_Issue_Created_Date__c = System.now().addDays(-20),
                                                   Files_Received__c = Date.today(),
                                                   QA_Notes_and_Comments__c = 'Testing Notes',
                                                   Market_Data_Period_Begin__c = Date.Today(), Market_Data_Period_End__c = Date.Today().addDays(6));
        
        //Populating list with the records
        siteIssues.add(sIssue_1);
        
        //Creating variables to hold data for assertions later
        String MemSuppNotes0;
        Integer MemSuppListSize1;
        String MemSuppName1;
        String MemSuppNotes1;
        String MemSuppNotes2;
        Integer MemSuppListSize2;
        String MemSuppNotes3;
        String MemSuppNotes4;
                    
        //Enabling trigger back
        Util.BypassAllTriggers = false;
        
        //Insert member supports
        insert siteIssues;  
        
        //Querying results for the assertions
        memberSupports = [SELECT ID, QA_Notes_and_Comments__c FROM Site_Issue__c ORDER BY Category__c DESC];
        
        MemSuppNotes0 = memberSupports[0].QA_Notes_and_Comments__c;
        
        //Updating member supports to mark them as closed
        memberSupports[0].Status__c = '22 - Production Migration Complete';
        memberSupports[0].Site_Issue_Close_Date__c = System.today().addDays(2);
        memberSupports[0].Data_Load_Period_Begin__c = System.today();
        memberSupports[0].Data_Load_Period_End__c = System.today().addDays(4);
        memberSupports[0].Percent_of_PCP_Revenue_Not_Captured__c = 10;
        memberSupports[0].Estimated_Prod_Team_Transition_Date__c = System.today();
        
        //Enabling trigger back
        Util.BypassAllTriggers = true;
        
        //Updating member supports
        update memberSupports; 
        
        //Re-initailizing the list
        siteIssues = new List<Site_Issue__c>();
        
        Site_Issue__c sIssue_2 = new Site_Issue__c(Site_Issue_Priority__c = 'High', 
                                                    Site_Issue_Short_Description__c = 'Test-Description',
                                                    Category__c = 'Test-Category 2', Data_Load_Type__c = Constants.CURRENT, 
                                                    Project__c = project.Id, RecordTypeId = rcordType,
                                                    Assigned_To_Contact__c = contact.Id, 
                                                    Site_Issue_Created_Date__c = System.now().addDays(-10),
                                                    Files_Received__c = Date.today(),
                                                    Market_Data_Period_Begin__c = Date.Today(), Market_Data_Period_End__c = Date.Today().addDays(6));
        
        Site_Issue__c sIssue_3 = new Site_Issue__c(Site_Issue_Priority__c = 'High', 
                                                    Site_Issue_Short_Description__c = 'Test-Description',
                                                    Category__c = 'Test-Category 3', Data_Load_Type__c = Constants.CURRENT, 
                                                    Project__c = project.Id, RecordTypeId = rcordType,
                                                    Assigned_To_Contact__c = contact.Id, 
                                                    Site_Issue_Created_Date__c = System.now().addDays(-20),
                                                    Files_Received__c = Date.today(),
                                                    QA_Notes_and_Comments__c = 'Testing',
                                                    Market_Data_Period_Begin__c = Date.Today(), Market_Data_Period_End__c = Date.Today().addDays(6));
        
        //Populating list with the records
        siteIssues.add(sIssue_2);
        siteIssues.add(sIssue_3);
        
        //Enabling trigger back
        Util.BypassAllTriggers = false;
        
        System.debug('Before Test :::: ' + Limits.getQueries());
        
        //Start Testing from here
        Test.StartTest();
        
        System.debug('Before Insert Site Issue :::: ' + Limits.getQueries());
        
        //Insert member supports
        //insert siteIssues;
        
        System.debug('After Innsert Siite Isuee :::: ' + Limits.getQueries());
        
        //Re-initailizing the list
        //siteIssues = new List<Site_Issue__c>();
        
        Site_Issue__c sIssue_4 = new Site_Issue__c(Site_Issue_Priority__c = 'High', 
                                                    Site_Issue_Short_Description__c = 'Test-Description',
                                                    Category__c = 'Test-Category 4', Data_Load_Type__c = Constants.CURRENT, 
                                                    Project__c = project.Id, RecordTypeId = rcordType,
                                                    Assigned_To_Contact__c = contact.Id, 
                                                    Site_Issue_Created_Date__c = System.now().addDays(-10),
                                                    Files_Received__c = Date.today(),
                                                    Market_Data_Period_Begin__c = Date.Today(), Market_Data_Period_End__c = Date.Today().addDays(6));
        
        Site_Issue__c sIssue_5 = new Site_Issue__c(Site_Issue_Priority__c = 'High', 
                                                    Site_Issue_Short_Description__c = 'Test-Description',
                                                    Category__c = 'Test-Category 5', Data_Load_Type__c = Constants.CURRENT, 
                                                    Project__c = project.Id, RecordTypeId = rcordType,
                                                    Assigned_To_Contact__c = contact.Id, 
                                                    Site_Issue_Created_Date__c = System.now().addDays(-20),
                                                    Files_Received__c = Date.today(),
                                                    QA_Notes_and_Comments__c = 'ABC',
                                                    Market_Data_Period_Begin__c = Date.Today(), Market_Data_Period_End__c = Date.Today().addDays(6));
        
        //Populating list with the records
        siteIssues.add(sIssue_4);
        siteIssues.add(sIssue_5);
        
        //Enabling trigger back
        Util.BypassAllTriggers = false;
        
        //Insert member supports
        insert siteIssues;
        
        //Stop Testing from here
        Test.stopTest();
       
        System.debug('After Test :::: ' + Limits.getQueries());
        
        //Querying results for the assertions
        memberSupports = [SELECT ID, Name, QA_Notes_and_Comments__c 
                          FROM Site_Issue__c ORDER BY Category__c DESC];
                          
		System.debug('After Query test :::: ' + Limits.getQueries());
		
        //Applying asserts for the results
        System.assertEquals('Testing Notes', MemSuppNotes0);
        
        //Applying asserts for the results
        System.assertEquals(5, memberSupports.size());
        System.assertEquals(memberSupports[4].Name + '<br><br>Testing Notes<br>ABC', memberSupports[0].QA_Notes_and_Comments__c);
        System.assertEquals(memberSupports[4].Name + '<br><br>Testing Notes', memberSupports[1].QA_Notes_and_Comments__c);
        System.assertEquals(memberSupports[4].Name + '<br><br>Testing Notes<br>Testing', memberSupports[2].QA_Notes_and_Comments__c);
        System.assertEquals(memberSupports[4].Name + '<br><br>Testing Notes', memberSupports[3].QA_Notes_and_Comments__c);
        System.assertEquals('Testing Notes', memberSupports[4].QA_Notes_and_Comments__c);
        
    }
    
    static testmethod void populateTier1Test(){
        
        //Bypassing all triggers so then test data can be created for testing purpose
        Util.BypassAllTriggers = true;
        
        //Create a new user
        User User1 = TestUtilities.CreateNewUser(null,true);
        
        //Create a new Project
        Project__c TestProj = TestUtilities.createProject(true);
        
        //Grab the Member Support record type
        Id CCAMemSuppRT = Schema.SObjectType.Site_Issue__c.getRecordTypeInfosByName().get('Crimson Support Request').getRecordTypeId();
        
        //Create a new Member Support
        Site_Issue__c sIssue_1 = new Site_Issue__c(Site_Issue_Priority__c = 'High', 
                                                   Site_Issue_Short_Description__c = 'Test-Description',
                                                   Category__c = 'Test-Category 4', Data_Load_Type__c = Constants.CURRENT, 
                                                   Project__c = TestProj.Id, RecordTypeId = CCAMemSuppRT,
                                                   Site_Issue_Created_Date__c = System.now().addDays(-10),
                                                   Files_Received__c = Date.today(),
                                                   Tier_I_Support_Analyst__c = User1.Id,
                                                   Market_Data_Period_Begin__c = Date.Today(), Market_Data_Period_End__c = Date.Today().addDays(6));
        
        
        //Turn the triggers back on
        Util.BypassAllTriggers = false;
        
        //Start Testing from here
        Test.StartTest();
        
        //Update the Member Support Tier I Support Analyst
        insert sIssue_1;
        
        //Start Testing from here
        Test.StopTest();
        
        //Pull through the Member Support and User Data
        sIssue_1 = [SELECT Id, Tier_I_Support_Analyst__c FROM Site_Issue__c WHERE ID =:sIssue_1.Id];
        User1 = [SELECT Id, Name FROM User WHERE Id =:User1.Id];
        
        //The User listed as Tier I Support Analyst should be the name entered into the field on the 
        System.assertEquals(User1.Name, sIssue_1.Tier_I_Support_Analyst__c);
    }
    
    static testmethod void testPunctualityofLoads(){
        
        //Bypassing all triggers so then test data can be created for testing purpose
        Util.BypassAllTriggers = true;
        
        //Create a new user
        User User1 = TestUtilities.CreateNewUser(null,true);
        
        //Create a new Project
        Project__c TestProj = TestUtilities.createProject(true);
        TestProj.Punctuality_of_Loads__c = Constants.PROJECT_PUNCTUALITY_OF_LOADS_TBD;
        
        Update TestProj;
        
        //Grab the Member Support record type
        Id CCADLMMemSuppRT = Schema.SObjectType.Site_Issue__c.getRecordTypeInfosByName().get('CMA Data Load/Migration').getRecordTypeId();
        
        //Create a new Member Support
        Site_Issue__c sIssue_1 = new Site_Issue__c(Site_Issue_Priority__c = 'High', 
                                                   Site_Issue_Short_Description__c = 'Test-Description',
                                                   Category__c = 'Test-Category 4', Data_Load_Type__c = Constants.CURRENT, 
                                                   Project__c = TestProj.Id, RecordTypeId = CCADLMMemSuppRT,
                                                   Site_Issue_Created_Date__c = System.now().addDays(-10),
                                                   Files_Received__c = Date.today(),
                                                   Next_Data_Upload_Expected_On2__c = Date.today().addDays(-54),
                                                   Tier_I_Support_Analyst__c = User1.Id,
                                                   Market_Data_Period_Begin__c = Date.Today(), Market_Data_Period_End__c = Date.Today().addDays(6));
        
        //Turn the triggers back on
        Util.BypassAllTriggers = false;
        
        //Start Testing from here
        Test.StartTest();

        insert sIssue_1;

        //Start Testing from here
        Test.StopTest();
        
        //Pull through the Project Data
        TestProj = [SELECT Id, Punctuality_of_Loads__c FROM Project__c WHERE ID =:TestProj.Id];
        
        //The Punctuality of Loads field should now be updated and match the 'Typically Late' status
        System.assertEquals(TestProj.Punctuality_of_Loads__c, Constants.PROJECT_PUNCTUALITY_OF_LOADS_TYPICALLY_LATE);
    }
    
    //V_1.6 - Modified By - Mahendra Swarnkar - 08/27/2016 - CR-20160114-9520
    //Added by - Abhinav Sharma - 11/28/2015 - CR-20150601-8977
    static testMethod void test_CPRMDataLoadTicketUseCases() {

        //Bypass Dupeblocker
        Util.IsTest(true);
    
        //Bypassing all trigger so then testing data can be created with ease
        Util.BypassAllTriggers = true;
       
        //Project
        Project__c project = new Project__c(Name = 'Test-Data', PRM_Version__c = '2014.14', 
                                            Data_Analyst__c = Userinfo.getUserId(),
                                            Recurring_Business_Analyst__c = Userinfo.getUserId());
        insert project;
        
        //Enabling all triggers
        Util.BypassAllTriggers = false;
        
        //Query for the "Member Support" record types (CMA Data Load/Migration)
        List<RecordType> recordTypes = [SELECT Id FROM RecordType WHERE sObjectType = 'Site_Issue__c' 
                                        AND DeveloperName = 'CPRM_Data_Load' 
                                        AND isActive = true];
        //Asert or the record type
        System.assert(recordTypes != null);
        System.assertEquals(1, recordTypes.size());
        
        //List to hold the member support records
        List<Site_Issue__c> memberSupports = new List<Site_Issue__c>();
        
        //Member Support
        Site_Issue__c sIssue_1 = new Site_Issue__c(Crimson_Site_Issue_Description__c = 'Test Issue Description 1', 
                                                   RecordTypeId = recordTypes[0].Id, Project__c = project.Id, 
                                                   Site_Issue_Created_Date__c = System.now().addDays(-3), 
                                                   Site_Issue_Close_Date__c = System.now().addDays(3), 
                                                   Data_Load_Period_End__c = System.Today().addDays(3),
                                                   Data_Load_Period_Begin__c = System.today(), 
                                                   Files_Received__c = System.today(),
                                                   Status__c = 'Test 1', PRM_Application_Version__c = '2014.10', 
                                                   Percent_of_PCP_Revenue_Not_Captured__c = 23);
        
        Site_Issue__c sIssue_2 = new Site_Issue__c(Crimson_Site_Issue_Description__c = 'Test Issue Description 2', 
                                                   RecordTypeId = recordTypes[0].Id, Project__c = project.Id, 
                                                   Site_Issue_Created_Date__c = System.now().addDays(-3), 
                                                   Site_Issue_Close_Date__c = System.now().addDays(3), 
                                                   Data_Load_Period_End__c = System.today().addDays(6),
                                                   Data_Load_Period_Begin__c = System.today(), 
                                                   Files_Received__c = System.today(),
                                                   Status__c = 'Test 2', PRM_Application_Version__c = '2014.10', 
                                                   Percent_of_PCP_Revenue_Not_Captured__c = 23);
        
        Site_Issue__c sIssue_3 = new Site_Issue__c(Crimson_Site_Issue_Description__c = 'Test Issue Description 3', 
                                                   RecordTypeId = recordTypes[0].Id, Project__c = project.Id, 
                                                   Site_Issue_Created_Date__c = System.now().addDays(-3), 
                                                   Site_Issue_Close_Date__c = System.now().addDays(3), 
                                                   Data_Load_Period_End__c = System.today().addDays(5),
                                                   Data_Load_Period_Begin__c = System.today(), 
                                                   Files_Received__c = System.today(),
                                                   Status__c = 'Test 3', PRM_Application_Version__c = '2014.10', 
                                                   Percent_of_PCP_Revenue_Not_Captured__c = 23);
        memberSupports.add(sIssue_1);
        memberSupports.add(sIssue_2);
        memberSupports.add(sIssue_3);
        
        //Start Test
        Test.startTest();
        
        //Enabling trigger again
        Util.BypassAllTriggers = false;
        
        //insert Site Issue
        insert memberSupports;
        
        //Retrieving member support details
        memberSupports = [SELECT ID, Crimson_Data_Analyst__c, Production_Business_Analyst__c, Status__c, Elapsed_Open_to_Actual_Resolution_Hours__c,
                          Elapsed_Open_to_Acknowledged_Hours__c, Elapsed_Open_to_First_Response_Hours__c, Elapsed_Open_to_Close_Hours__c
                          FROM Site_Issue__c ORDER BY Status__c ASC];
        
        //Asserting for the results
        System.assert(memberSupports != null);
        System.assert(memberSupports.size() == 3);
        System.assertEquals(Userinfo.getUserId(), memberSupports[0].Crimson_Data_Analyst__c);
        System.assertEquals(Userinfo.getUserId(), memberSupports[0].Production_Business_Analyst__c);
        System.assertEquals(Userinfo.getUserId(), memberSupports[1].Crimson_Data_Analyst__c);
        System.assertEquals(Userinfo.getUserId(), memberSupports[1].Production_Business_Analyst__c);
        System.assertEquals(Userinfo.getUserId(), memberSupports[2].Crimson_Data_Analyst__c);
        System.assertEquals(Userinfo.getUserId(), memberSupports[2].Production_Business_Analyst__c);
        
        //V_1.6 - Added By - Mahendra Swarnkar - 08/27/2016 - CR-20160114-9520
        System.assertEquals(null, memberSupports[0].Elapsed_Open_to_Actual_Resolution_Hours__c);
        System.assertEquals(null, memberSupports[1].Elapsed_Open_to_Actual_Resolution_Hours__c);
        System.assertEquals(null, memberSupports[2].Elapsed_Open_to_Actual_Resolution_Hours__c);
        System.assertEquals(null, memberSupports[0].Elapsed_Open_to_Acknowledged_Hours__c);
        System.assertEquals(null, memberSupports[1].Elapsed_Open_to_Acknowledged_Hours__c);
        System.assertEquals(null, memberSupports[2].Elapsed_Open_to_Acknowledged_Hours__c);
        System.assertEquals(null, memberSupports[0].Elapsed_Open_to_First_Response_Hours__c);
        System.assertEquals(null, memberSupports[1].Elapsed_Open_to_First_Response_Hours__c);
        System.assertEquals(null, memberSupports[2].Elapsed_Open_to_First_Response_Hours__c);
        System.assertNotEquals(null, memberSupports[0].Elapsed_Open_to_Close_Hours__c);
        //System.assertEquals(27, memberSupports[0].Elapsed_Open_to_Close_Hours__c);
        //System.assertEquals(27, memberSupports[1].Elapsed_Open_to_Close_Hours__c);
        //System.assertEquals(27, memberSupports[2].Elapsed_Open_to_Close_Hours__c);
        //V_1.6 - Added By - Mahendra Swarnkar - 08/27/2016 - CR-20160114-9520 - Upto here
        
        //Update member support fields
        memberSupports[0].Crimson_Data_Analyst__c = null;
        memberSupports[0].Production_Business_Analyst__c = null;
        
        //Enabling all triggers
        Util.BypassAllTriggers = false;
        
        //Update the member support records
        update memberSupports[0];
        
        //Stop Test
        Test.stopTest();
        
        //Enabling all triggers
        Util.BypassAllTriggers = false;
        
        //Querying remaining member supports
        memberSupports = [SELECT ID, Crimson_Data_Analyst__c, Production_Business_Analyst__c
                          FROM Site_Issue__c ORDER BY Status__c ASC];
        
        //Asserting for the results
        System.assert(memberSupports != null);
        System.assert(memberSupports.size() == 3);
        System.assertEquals(null, memberSupports[0].Crimson_Data_Analyst__c);
        System.assertEquals(null, memberSupports[0].Production_Business_Analyst__c);
        System.assertEquals(Userinfo.getUserId(), memberSupports[1].Crimson_Data_Analyst__c);
        System.assertEquals(Userinfo.getUserId(), memberSupports[1].Production_Business_Analyst__c);
        System.assertEquals(Userinfo.getUserId(), memberSupports[2].Crimson_Data_Analyst__c);
        System.assertEquals(Userinfo.getUserId(), memberSupports[2].Production_Business_Analyst__c);
    }
    
    //Re-added by - Mahendra Swarnakar - 02/15/2016 - CR-20151210-9456 
    //Modified By - Abhinav Sharma - 10/20/2015 - CR-20151016-9329
    //New Test method added - Abhinav Sharma - 08/24/2015 - CR-20150127-8596
    static testMethod void test_populateCPRMCurrentDataPeriodOnProject() {

        //Bypass Dupeblocker
        Util.IsTest(true);
    
        //Bypassing all trigger so then testing data can be created with ease
        Util.BypassAllTriggers = true;
       
        //Project
        Project__c project = new Project__c(Name = 'Test-Data', PRM_Version__c = '2014.14');
        insert project;
        
        //Enabling all triggers
        Util.BypassAllTriggers = false;
        
        //Query for the "Member Support" record types (CMA Data Load/Migration)
        List<RecordType> recordTypes = [SELECT Id FROM RecordType WHERE sObjectType = 'Site_Issue__c' 
                                        AND DeveloperName = 'CPRM_Data_Load' 
                                        AND isActive = true];
        //Asert or the record type
        System.assert(recordTypes != null);
        System.assertEquals(1, recordTypes.size());
        
        //List to hold the member support records
        List<Site_Issue__c> memberSupports = new List<Site_Issue__c>();
        
        //Member Support
        Site_Issue__c sIssue_1 = new Site_Issue__c(Crimson_Site_Issue_Description__c = 'Test Issue Description 1', 
                                                   RecordTypeId = recordTypes[0].Id, Project__c = project.Id, 
                                                   Site_Issue_Created_Date__c = System.now().addDays(-3), 
                                                   Site_Issue_Close_Date__c = System.now().addDays(3), 
                                                   Data_Load_Period_End__c = System.Today().addDays(3),
                                                   Data_Load_Period_Begin__c = System.today(), 
                                                   Files_Received__c = System.today(),
                                                   Status__c = 'Test', PRM_Application_Version__c = '2014.10', 
                                                   Percent_of_PCP_Revenue_Not_Captured__c = 23);
        
        Site_Issue__c sIssue_2 = new Site_Issue__c(Crimson_Site_Issue_Description__c = 'Test Issue Description 1', 
                                                   RecordTypeId = recordTypes[0].Id, Project__c = project.Id, 
                                                   Site_Issue_Created_Date__c = System.now().addDays(-3), 
                                                   Site_Issue_Close_Date__c = System.now().addDays(3), 
                                                   Data_Load_Period_End__c = System.today().addDays(6),
                                                   Data_Load_Period_Begin__c = System.today(), 
                                                   Files_Received__c = System.today(),
                                                   Status__c = 'Test', PRM_Application_Version__c = '2014.10', 
                                                   Percent_of_PCP_Revenue_Not_Captured__c = 23);
        
        Site_Issue__c sIssue_3 = new Site_Issue__c(Crimson_Site_Issue_Description__c = 'Test Issue Description 1', 
                                                   RecordTypeId = recordTypes[0].Id, Project__c = project.Id, 
                                                   Site_Issue_Created_Date__c = System.now().addDays(-3), 
                                                   Site_Issue_Close_Date__c = System.now().addDays(3), 
                                                   Data_Load_Period_End__c = System.today().addDays(5),
                                                   Data_Load_Period_Begin__c = System.today(), 
                                                   Files_Received__c = System.today(),
                                                   Status__c = 'Test', PRM_Application_Version__c = '2014.10', 
                                                   Percent_of_PCP_Revenue_Not_Captured__c = 23);
        
        
        
        memberSupports.add(sIssue_1);
        memberSupports.add(sIssue_2);
        memberSupports.add(sIssue_3);
        
        //Start Test
        Test.startTest();
        
        //Enabling trigger again
        Util.BypassAllTriggers = false;
        
        //insert Site Issue
        insert memberSupports;
        
        //List of projects
        List<Project__c> listProjects = new List<Project__c>();
        
        //Query through project records
        listProjects = [Select Id, CPRM_Current_Data_Period__c From Project__c Where Id =: project.Id ];
        
        //Apply asserts on the results
        System.assertEquals(null, listProjects[0].CPRM_Current_Data_Period__c);
        
        //Update member support fields
        memberSupports[0].Data_Load_Period_End__c = Date.Today().addDays(8);
        memberSupports[0].Status__c = '15 - Cross-Verification Completed';
        memberSupports[0].Site_Issue_Close_Date__c = System.today().addDays(10);
        memberSupports[0].Elapsed_Files_Rec_d_to_Diagnostics_Sent__c = 2;
        memberSupports[0].Files_Received__c = System.today();
        memberSupports[0].Diagnostics_Sent__c = System.today();
        memberSupports[0].Elapsed_Diag_Sent_to_Files_Sent_to_MM__c = 2;
        memberSupports[0].Elapsed_Files_Sent_to_MM_to_DB_Rec_d__c = 2;
        memberSupports[0].Elapsed_DB_Rec_d_to_Testing_Complete__c = 2;
        memberSupports[0].Elapsed_Testing_Complete_to_QA_Complete__c = 2;
        memberSupports[0].Elapsed_QA_Complete_to_Prod_Migr_Appr__c = 2;
        memberSupports[0].Elapsed_Prod_Migr_Appr_to_Moved_to_Prod__c = 2;
        memberSupports[0].Elapsed_Files_Rec_d_to_Moved_to_Prod__c = 2;
        memberSupports[0].Files_Sent_to_Milliman__c = System.today();
        memberSupports[0].DB_Received_from_Milliman__c = System.today();
        memberSupports[0].Testing_Complete__c = System.today();
        memberSupports[0].Final_QA_Complete__c = System.today();
        memberSupports[0].Production_Migration_Approved__c = System.today();
        memberSupports[0].Moved_to_Production__c = System.today();
        
        //Enabling all triggers
        Util.BypassAllTriggers = false;
        
        //Update the member support records
        update memberSupports[0];
        
        //Query through project records
        listProjects = [Select Id, CPRM_Current_Data_Period__c From Project__c Where Id =: project.Id];
        
        //Apply asserts on the results
        System.assertEquals(System.today().addDays(8), listProjects[0].CPRM_Current_Data_Period__c);
        
        //Stop Test
        Test.stopTest();
        
        //Enabling all triggers
        Util.BypassAllTriggers = false;
        
        //Querying remaining member supports
        memberSupports = [SELECT ID FROM Site_Issue__c];
        
        //Delete member support record
        delete memberSupports;
        
        //Query through project records
        listProjects = [Select Id, CPRM_Current_Data_Period__c From Project__c Where Id =: project.Id];
        
        //Apply asserts on the results
        System.assertEquals(null , listProjects[0].CPRM_Current_Data_Period__c);        
    }
    
    //Re-added by - Mahendra Swarnakar - 02/15/2016 - CR-20151210-9456 
    //New Test method added - Mahendra swarnakar - 07/31/2015 - CR-20150709-9070
    static testMethod void test_populateProjectFieldsFromChildren() {

        //Bypass Dupeblocker
        Util.IsTest(true);
    
        //Bypassing all trigger so then testing data can be created with ease
        Util.BypassAllTriggers = true;
        
        //Project
        Project__c project = new Project__c(Name = 'Test-Data', PRM_Version__c = '2014.14');
        insert project;
    
        //Query through project records
        List<Project__c> listProjects = [Select Id, PRM_Version__c From Project__c Where Id =: project.Id];
        
        //Applying assert for the results
        System.assertEquals('2014.14', listProjects[0].PRM_Version__c);
        
        //Enabling all triggers
        Util.BypassAllTriggers = false;
        
        //Query for the "Member Support" record types (CMA Data Load/Migration)
        List<RecordType> recordTypes = [SELECT Id FROM RecordType WHERE sObjectType = 'Site_Issue__c' 
                                        AND DeveloperName = 'CMA_Data_Load_Production' 
                                        AND isActive = true];
        //Asert or the record type
        System.assertEquals(1, recordTypes.size());
    
        //List to hold the member support records
        List<Site_Issue__c> memberSupports = new List<Site_Issue__c>();
    
        //Member Support
        Site_Issue__c sIssue_1 = new Site_Issue__c(Crimson_Site_Issue_Description__c = 'Test Issue Description 1', 
                                         RecordTypeId = recordTypes[0].Id, Project__c = project.Id, 
                                         Site_Issue_Created_Date__c = System.now().addDays(-3), 
                                         Site_Issue_Close_Date__c = System.now().addDays(3), 
                                         Data_Load_Period_End__c = Date.Today().addDays(3),
                                         Data_Load_Period_Begin__c = Date.today(), Files_Received__c = Date.today(),
                                         Status__c = '14 - QA testing complete',
                                         PRM_Application_Version__c = '2014.10', Estimated_Prod_Team_Transition_Date__c = Date.Today(), 
                                         Percent_of_PCP_Revenue_Not_Captured__c = 23,
                                         Data_Load_Type__c = 'PRM Migration');
    
        //Member Support
        Site_Issue__c sIssue_2 = new Site_Issue__c(Crimson_Site_Issue_Description__c = 'Test Issue Description 2', 
                                         RecordTypeId = recordTypes[0].Id, Project__c = project.Id, 
                                         Site_Issue_Created_Date__c = System.now().addDays(-3), 
                                         Site_Issue_Close_Date__c = System.now().addDays(1), 
                                         Data_Load_Period_End__c = Date.Today().addDays(3),
                                         Data_Load_Period_Begin__c = Date.today(), Files_Received__c = Date.today(),
                                         Status__c = ProjectTriggerHelper.STATUS_22_PRODUCTION_MIGRATION_COMPLETE,
                                         PRM_Application_Version__c = '2015.10',
                                         Estimated_Prod_Team_Transition_Date__c = Date.Today(),
                                         Percent_of_PCP_Revenue_Not_Captured__c = 23,
                                         Data_Load_Type__c = 'PRM Migration');
        //Member Support
        Site_Issue__c sIssue_3 = new Site_Issue__c(Crimson_Site_Issue_Description__c = 'Test Issue Description 3', 
                                         RecordTypeId = recordTypes[0].Id, Project__c = project.Id, 
                                         Site_Issue_Created_Date__c = System.now().addDays(-3), 
                                         Site_Issue_Close_Date__c = System.now().addDays(2), 
                                         Data_Load_Period_End__c = Date.Today().addDays(3),
                                         Data_Load_Period_Begin__c = Date.today(), Files_Received__c = Date.today(),
                                         Status__c = ProjectTriggerHelper.STATUS_22_PRODUCTION_MIGRATION_COMPLETE,
                                         PRM_Application_Version__c = '2015.14',
                                         Estimated_Prod_Team_Transition_Date__c = Date.Today(),
                                         Percent_of_PCP_Revenue_Not_Captured__c = 23,
                                         Data_Load_Type__c = 'PRM Migration');
    
    
        memberSupports.add(sIssue_1);
        memberSupports.add(sIssue_2);
        memberSupports.add(sIssue_3);
        
        //Start Test
         Test.startTest();
        
        //insert Site Issue
        insert memberSupports;
            
        //Query through project records
        listProjects = [Select Id, PRM_Version__c From Project__c Where Id =: project.Id ];
        
        //Apply asserts on the results
        System.assertEquals('2015.14' , listProjects[0].PRM_Version__c);
        
        //Enabling all triggers
        Util.BypassAllTriggers = false;
        
        //Delete member support record
        delete memberSupports[2];
        
        //Query through project records
        listProjects = [Select Id, PRM_Version__c From Project__c Where Id =: project.Id];
        
        //Apply asserts on the results
        System.assertEquals('2015.10' , listProjects[0].PRM_Version__c);
        
        //Stop Test
        Test.stopTest();
        
         //Update member support fields
        memberSupports[0].Status__c = ProjectTriggerHelper.STATUS_22_PRODUCTION_MIGRATION_COMPLETE;
        memberSupports[0].Site_Issue_Close_Date__c = System.now().addDays(4);
        
        //Enabling all triggers
        Util.BypassAllTriggers = false;
        
        //Update the member support records
        update memberSupports[0];
        
        memberSupports = [SELECT ID, Site_Issue_Close_Date__c, Status__c, PRM_Application_Version__c, 
                          Crimson_Site_Issue_Description__c
                          FROM Site_Issue__c];
        
        //Query through project records
        listProjects = [Select Id, PRM_Version__c From Project__c Where Id =: project.Id];
        
        //Apply asserts on the results
        System.assertEquals('2014.10' , listProjects[0].PRM_Version__c);
        
        //Enabling all triggers
        Util.BypassAllTriggers = false;
        
        //Delete member support record
        delete memberSupports;
        
        //Query through project records
        listProjects = [Select Id, PRM_Version__c From Project__c Where Id =: project.Id];
        
        //Apply asserts on the results
        System.assertEquals(null , listProjects[0].PRM_Version__c);
    }
    
    //Added by - Victor Hanson - 03/28/2016 - CR-1223
    //
    static testMethod void test_PICTicketToCase() {

        //Bypass Dupeblocker
        Util.IsTest(true);
    
        //Bypassing all trigger so then testing data can be created with ease
        Util.BypassAllTriggers = true;
        
        //create the sync field so the process knows to create the corresponding Case
        insert TestUtilities.createSyncField('MS.desc->Case.desc_PSI', 'PIC_Support_Issue', 
                                         'Site_Issue__c', 'Crimson_Site_Issue_Description__c', 'Case', 'Description');
        
        //Institution
        Account acct = TestUtilities.CreateNewAccount(true);
        
        //Enabling all triggers
        Util.BypassAllTriggers = false;
        
        //Get the "PIC Support Issue" record type
        Id supportIssueRTId = Schema.SObjectType.Site_Issue__c.getRecordTypeInfosByName().get('PIC Support Issue').getRecordTypeId();
        
        //Member Support
        Site_Issue__c sIssue_1 = new Site_Issue__c(Crimson_Site_Issue_Description__c = 'Test Issue Description 1', 
                                                   RecordTypeId = supportIssueRTId, Institution__c = acct.Id,
                                                   Status__c = 'Test 1');
        
        //Start Test
        Test.startTest();
        
        //Enabling trigger again
        Util.BypassAllTriggers = false;
        
        //insert Site Issue
        insert sIssue_1;
        
        //Stop Test
        Test.stopTest();
        
        //Retrieving member support details
        sIssue_1 = [SELECT ID, Case__c, Case__r.RecordType.Name
                          FROM Site_Issue__c WHERE Id = :sIssue_1.Id];
        
        //verify that a case was created and synced with the Member Support record
        system.assertNotEquals(null, sIssue_1.Case__c);
        system.assertEquals('PIC Support', sIssue_1.Case__r.RecordType.Name);
    }
    
    //Added By - Abhinav Sharma - 04/01/2016 - CR-20160224-9632
    static testmethod void test_MSForButtonsValidations() { 
        
        //Bypass Dupeblocker
        Util.IsTest(true);
        Util.isTesting = true;
        
        //Bypassing Triggers so then test data can be created easily
        Util.byPassAllTriggers = true;
        
        //Create test data for the Sync Fields custom setting that syncs Mem Support -> Case fields
        TestUtilities.createSyncFields();
        
        //List to hold the Account records
        List<Account> accounts = new List<Account>();
        
        //Create an institution
        Account acct_1 = TestUtilities.CreateNewAccount(false);
        
        //Populating list with account records
        accounts.add(acct_1); 
        
        //Insert accounts
        insert accounts;
        
        //Assert for the results
        System.assert(accounts != null);
        System.assert(accounts.size() == 1);
        
        //Querying Details for "Member & Employee Support" record type on Case Object
        List<RecordType> caseRdTypes = [SELECT ID, DeveloperName FROM RecordType 
                                        Where sObjectType = 'Case' 
                                        AND IsActive = true 
                                        AND DeveloperName IN ('PT_Support_Request')
                                        ORDER By DeveloperName ASC];
                
        //Assert for the results
        System.assert(caseRdTypes != null);
        System.assert(caseRdTypes.size() == 1);
        System.assert(caseRdTypes[0].DeveloperName == 'PT_Support_Request');
        
        //Record Type Setting list
        list<RecordType_Setting__c> listRTSettings = new list<RecordType_Setting__c>();

        //Record Type Setting instance
        RecordType_Setting__c rs_1 = new RecordType_Setting__c(Name = 'Test1', 
                                                             Name__c = 'PT Support Request', 
                                                             SFID__c = caseRdTypes[0].Id, SObjectType__c = 'Case');
        listRTSettings.add(rs_1);
        insert listRTSettings;
        
        //List to hold the case records
        List<Case> cases = new List<Case>();
        
        //Create a sample case record to insert and test case trigger
        Case aCase_1 = new Case(RecordTypeId = caseRdTypes[0].Id, Origin = 'ABC', Subject = 'Test', 
                                Description = 'Test', AccountId = accounts[0].Id);
       
        //Populating list with case records
        cases.add(aCase_1); 
        
        //Start test from here
        Test.startTest();
        
        //Enabling triggers
        Util.byPassAllTriggers = false;
       
        //Insert cases
        insert cases;
        
        //Assert for the results
        System.assert(cases != null);
        System.assert(cases.size() == 1);
        
        //Asserting for the results
        cases = [SELECT ID, Status, Member_Support_Ticket__c, Button_Used__c, RecordType.DeveloperName FROM Case ORDER BY Origin ASC];
        
        //Assert for the results
        System.assert(cases != null);
        System.assert(cases.size() == 1);
        System.assert(cases[0].Status == '01-New');
        System.assert(cases[0].Button_Used__c == false);
        System.assert(cases[0].Member_Support_Ticket__c != null);
        
        //Querying for the MS records
        List<Site_Issue__c> siteIssues = [SELECT ID, Tier__c, RecordType.DeveloperName FROM Site_Issue__c 
                                            WHERE ID =: cases[0].Member_Support_Ticket__c];
        
        //List of MS records
        List<RecordType> mSRecordTypes = [SELECT ID FROM RecordType WHERE IsActive = true 
                                            AND SObjectType = 'SIte_Issue__c'
                                            AND DeveloperName = 'CCA_Support_Request'];
        System.assert(mSRecordTypes != null);
        System.assert(mSRecordTypes.size() > 0);
        
        System.assert(siteIssues != null);
        System.assert(siteIssues.size() > 0);
        System.assertEquals(mSRecordTypes[0].Id, siteIssues[0].RecordTypeId);
        
        //Enabling triggers
        Util.byPassAllTriggers = false;
        
        //Making a try to update the status value
        try {
            
            //Setting the flags
            MemberSupportTriggerUtilities.IS_ALREADY_EXECUTED_ONCE = false;
            MemberSupportTriggerUtilities.IS_UPDATE_HAPPENS_ON_INSERT_EVENT = false; 
            
            //Updating cases
            siteIssues[0].Tier__c = 'Tier II';
            update siteIssues;
            
        } catch(Exception ex) {
            System.assert(ex.getMessage().contains(System.Label.ERROR_CASE_DIRECT_FIELDS_CHANGES));
        }
        
        //Updating as per "Button Used" field value
        //Setting the flags
        MemberSupportTriggerUtilities.IS_ALREADY_EXECUTED_ONCE = false;
        MemberSupportTriggerUtilities.IS_UPDATE_HAPPENS_ON_INSERT_EVENT = false; 
            
        //Updating cases
        siteIssues[0].Tier__c = 'Tier II';
        siteIssues[0].Button_Used__c = true;
        update siteIssues;
        
        //Query for MS
        siteIssues = [SELECT ID, Tier__c, RecordType.DeveloperName FROM Site_Issue__c 
                                            WHERE ID =: cases[0].Member_Support_Ticket__c];
        System.assert(siteIssues != null);
        System.assert(siteIssues.size() > 0);
        System.assertEquals('Tier II', siteIssues[0].Tier__c);
        
        //Stop test here
        Test.stopTest();
    }
    
    //Added By - Mahendra Swarnkar - CR-20160420-9785 - 09/01/2016
    /**
    * Test Method to test the functionality of Methods "populateMarketDataPeriodFieldsOnProject" and "populateMarketDataPeriodFields"n in class MemberSupportTriggerUtilities
    **/
    static testmethod void testpopulateProjectFieldsFromMemberSupport() { 
        
        //Bypass Dupeblocker
        Util.IsTest(true);
        Util.isTesting = true;
        
        //Bypassing Triggers so then test data can be created easily
        Util.byPassAllTriggers = true;
        
        //Create an institution
        Account acct = TestUtilities.CreateNewAccount(true);
        System.assertEquals(true, acct != null);
        
        //Create a Contact
        Contact c = TestUtilities.CreateNewContact(acct,false);
        c.Email = 'Testmilliman@test.com';
        insert c;
        System.assertEquals(true, c != null);
        System.assertEquals(acct.Id, c.AccountId );
        System.assertEquals('Testmilliman@test.com', c.Email );
        
		//Insert a new Program
        Program__c p = new Program__c(Name = 'Test Program 1', Program_Acronym__c = 'Test Program 1', Create_memberships__c = 'No');
        insert p;
        System.assertEquals(p.Program_Acronym__c, 'Test Program 1');
        
        //CMA Project Record type Id
        Id cmaProjectRType = Util.RecordTypeId('Project__c', 'CMA');
        System.assertEquals(true, cmaProjectRType != null);
        
        //List to hold the Project records
        List<Project__c> projects = new List<Project__c>();
        projects.add( new Project__c(Name = 'Test Projet 1', Product__c = p.Id, RecordTypeID = cmaProjectRType ));
        projects.add( new Project__c(Name = 'Test Projet 1', Product__c = p.Id, RecordTypeID = cmaProjectRType ));
        insert projects;
        
        //Asserts on results
        projects = [Select Id, RecordTypeID, Product__c, Market_Data_Period_Begin__c, Market_Data_Period_End__c From Project__c where Id IN : projects ];
        System.assertEquals(true, projects != null);
        System.assertEquals(2, projects.size());
        System.assertEquals(cmaProjectRType, projects[0].RecordTypeID);
        System.assertEquals(cmaProjectRType, projects[1].RecordTypeID);
        System.assertEquals(p.Id, projects[0].Product__c);
        System.assertEquals(p.Id, projects[1].Product__c);
        System.assertEquals(null, projects[0].Market_Data_Period_Begin__c);
        System.assertEquals(null, projects[0].Market_Data_Period_End__c);
        
        //Member support Record type Id
        Id cmaDataLoadMigrationRtypeId = Util.RecordTypeId('Site_Issue__c', 'CMA Data Load/Migration');
        System.assertEquals(true, cmaProjectRType != null);
        
        //Create a new Date Instance of specific date
        Date d = Date.newInstance(2016,5,4);
        
        //List to hold the Member Support records
        List<Site_Issue__c> memberSupports = new List<Site_Issue__c>();
        Site_Issue__c ms1 = new Site_Issue__c(Site_Issue_Short_Description__c = 'Test Member Support 1', Status__c = '22 - Production Migration Complete',
                                                Data_Load_Type__c = 'Off Cycle - Data Load and/or Migration', Site_Issue_Created_Date__c = System.today(), 
                                                Market_Data_Period_Begin__c = d , Market_Data_Period_End__c = d.addDays(5),
                                                RecordTypeId = cmaDataLoadMigrationRtypeId, Project__c = projects[0].Id,
                                                Assigned_To_Contact__c = c.Id, Site_Issue_Priority__c = 'Low', Files_Received__c = System.today());
                                                
        Site_Issue__c ms2 = new Site_Issue__c(Site_Issue_Short_Description__c = 'Test Member Support 2', Status__c = '22 - Production Migration Complete',
                                                Data_Load_Type__c = 'Off Cycle - Data Load and/or Migration', Site_Issue_Created_Date__c = System.today(), 
                                                Market_Data_Period_Begin__c = d.addMonths(3) , Market_Data_Period_End__c = d.addMonths(4).addDays(8),
                                                RecordTypeId = cmaDataLoadMigrationRtypeId, Project__c = projects[0].Id,
                                                Assigned_To_Contact__c = c.Id, Site_Issue_Priority__c = 'Low', Files_Received__c = System.today());
                                                
        memberSupports.add(ms1);
        memberSupports.add(ms2);
        
        Test.startTest();
        //Enable All the Triggers
        Util.byPassAllTriggers = false;
        
        //Insert Member support reccords
        insert memberSupports;
        Test.stopTest();
        
        memberSupports = [Select Id, Market_Data_Period_Begin__c , Market_Data_Period_End__c, Project__c, Project__r.Market_Data_Period_Begin__c , Project__r.Market_Data_Period_End__c From Site_Issue__c Order By Site_Issue_Short_Description__c ASC ];
        
        //Assert for the results
        System.assertEquals(true, memberSupports != null);
        System.assertEquals(2, memberSupports.size());
        System.assertEquals(Date.newInstance(2016,5,1), memberSupports[0].Market_Data_Period_Begin__c);
        System.assertEquals(Date.newInstance(2016,5,31), memberSupports[0].Market_Data_Period_End__c);
        System.assertEquals(projects[0].Id, memberSupports[0].Project__c);
        System.assertEquals(projects[0].Id, memberSupports[1].Project__c);
        System.assertEquals(Date.newInstance(2016,8,1), memberSupports[1].Market_Data_Period_Begin__c);
        System.assertEquals(Date.newInstance(2016,9,30), memberSupports[1].Market_Data_Period_End__c);
        
        List<Project__c> proj = [Select Id, Market_Data_Period_Begin__c , Market_Data_Period_End__c From Project__c where Id = : projects[0].Id ];
        //System.assertEquals(true, proj[0].Market_Data_Period_Begin__c != null);
        //System.assertEquals(true, proj[0].Market_Data_Period_End__c != null);
        
        //Update Member support record
        memberSupports[0].Project__c = projects[1].Id;
        
        //Enable All  the Triggers
        Util.byPassAllTriggers = false;
        update memberSupports[0];
        
        //Asserts On result
        memberSupports = [Select Id, Market_Data_Period_Begin__c , Market_Data_Period_End__c, Project__c, Project__r.Market_Data_Period_Begin__c , Project__r.Market_Data_Period_End__c From Site_Issue__c Order By Site_Issue_Short_Description__c ASC ];
        System.assertEquals(true, memberSupports != null);
        System.assertEquals(2, memberSupports.size());
        System.assertEquals(projects[1].Id, memberSupports[0].Project__c);
        //System.assertEquals(Date.newInstance(2016,5,1), memberSupports[0].Project__r.Market_Data_Period_Begin__c);
        //System.assertEquals(Date.newInstance(2016,5,31), memberSupports[0].Project__r.Market_Data_Period_End__c);
        System.assertEquals(Date.newInstance(2016,8,1), memberSupports[1].Market_Data_Period_Begin__c);
        System.assertEquals(Date.newInstance(2016,9,30), memberSupports[1].Market_Data_Period_End__c);
        //System.assertEquals(Date.newInstance(2016,8,1), memberSupports[1].Project__r.Market_Data_Period_Begin__c);
        //System.assertEquals(Date.newInstance(2016,9,30), memberSupports[1].Project__r.Market_Data_Period_End__c);
        
        
        //Add a new Member support record 
        Site_Issue__c ms3 = new Site_Issue__c(Site_Issue_Short_Description__c = 'Test Member Support 3', Status__c = '22 - Production Migration Complete',
                                                Data_Load_Type__c = 'Off Cycle - Data Load and/or Migration', Site_Issue_Created_Date__c = System.today(), 
                                                Market_Data_Period_Begin__c = d.addMonths(5) , Market_Data_Period_End__c = d.addMonths(5),
                                                RecordTypeId = cmaDataLoadMigrationRtypeId, Project__c = projects[0].Id,
                                                Assigned_To_Contact__c = c.Id, Site_Issue_Priority__c = 'Low', Files_Received__c = System.today());
        memberSupports.add(ms3);
        
        //Enable All  the Triggers
        Util.byPassAllTriggers = false;
        insert ms3;
        
        //Asserts on result
        memberSupports = [Select Id, Market_Data_Period_Begin__c , Market_Data_Period_End__c, Project__c, Project__r.Market_Data_Period_Begin__c , Project__r.Market_Data_Period_End__c From Site_Issue__c Order By Site_Issue_Short_Description__c ASC ];
        System.assertEquals(true, memberSupports != null);
        System.assertEquals(3, memberSupports.size());
        System.assertEquals(Date.newInstance(2016,10,1), memberSupports[2].Market_Data_Period_Begin__c);
        System.assertEquals(Date.newInstance(2016,10,31), memberSupports[2].Market_Data_Period_End__c);
        //System.assertEquals(Date.newInstance(2016,10,1), memberSupports[2].Project__r.Market_Data_Period_Begin__c);
        //System.assertEquals(Date.newInstance(2016,10,31), memberSupports[2].Project__r.Market_Data_Period_End__c);
        
        //Enable All  the Triggers
        Util.byPassAllTriggers = false;
        
        //Delete a member Support record
        delete memberSupports[2];
        //Asserts on result
        memberSupports = [Select Id, Market_Data_Period_Begin__c , Market_Data_Period_End__c, Project__c, Project__r.Market_Data_Period_Begin__c , Project__r.Market_Data_Period_End__c From Site_Issue__c Order By Site_Issue_Short_Description__c ASC ];
        System.assertEquals(true, memberSupports != null);
        System.assertEquals(2, memberSupports.size());
        //System.assertEquals(Date.newInstance(2016,8,1), memberSupports[0].Project__r.Market_Data_Period_Begin__c);
        //System.assertEquals(Date.newInstance(2016,9,30), memberSupports[0].Project__r.Market_Data_Period_End__c);
    }
    
    //Added By - Rajeev Jain - 09/10/2016 - CR-20160114-9520
    static testmethod void test_MSAcknowledgeFields() {
    	
    	 //Bypass Dupeblocker
        Util.IsTest(true);
        Util.isTesting = true;
        
        //Bypassing Triggers so then test data can be created easily
        Util.byPassAllTriggers = true;
        
        //Create test data for the Sync Fields custom setting that syncs Mem Support -> Case fields
        TestUtilities.createSyncFields();
        
        //List to hold the Account records
        List<Account> accounts = new List<Account>();
        
        //Create an institution
        Account acct_1 = TestUtilities.CreateNewAccount(false);
        
        //Populating list with account records
        accounts.add(acct_1); 
        
        //Insert accounts
        insert accounts;
        
         //create new project
        Project__c proj = TestUtilities.createProject(true);
       
        util.BypassAllTriggers = false;
        
        Site_Issue__c memberSupport = TestUtilities.createSiteIssue(proj.Id, false);
        memberSupport.Date_Time_Acknowledged__c = DateTime.now().addDays(5);
        memberSupport.Site_Issue_Created_Date__c = Date.Today();
        memberSupport.Site_Issue_Close_Date__c = null;
        insert memberSupport;
        
        //Start Test
        Test.startTest();
        
        //Update Site Issue with First_Comment_Date_Time__c
        memberSupport.First_Comment_Date_Time__c = DateTime.now().addDays(7);
        memberSupport.Actual_Resolution_Date__c = DateTime.now().addDays(10);
        //memberSupport.Site_Issue_Close_Date__c = DateTime.now().addDays(12);
        memberSupport.Status__c = '06-Issue Resolved-Ticket Closed';
        update memberSupport;
        
        //Stop Test
        Test.stopTest();
        
        //Now update Status_Date_Time_Acknowledged__c to days ahead of CreatedDate
        List<Site_Issue__c> memberSupports = [select Id, CreatedDate, Elapsed_Open_to_Acknowledged_Hours__c, Elapsed_Open_to_First_Response_Hours__c, Elapsed_Open_to_Close_Hours__c from Site_Issue__c where Id = :memberSupport.Id];
       
        //Assert for Results
        System.assertEquals(true, memberSupports[0].Elapsed_Open_to_Acknowledged_Hours__c != null);
        System.assertEquals(true, memberSupports[0].Elapsed_Open_to_First_Response_Hours__c != null);
    }
}