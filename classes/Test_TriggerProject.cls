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
private class Test_TriggerProject {
/**
    Purpose         :   Test class for Trigger_Project

    Create By       :   Bhavi Sharma

    Created Date    :   03/25/2013

    Revision Log    :   v1.0 - Created
                        v1.1 - Bhavi Sharma - 04/26/2013 - test data added - CR-20130408-2822
                        V1.2 - Bhavi Sharma - 06/28/2013 - Code modified - CR-20130617-3170
                        V1.3 - Bhavi Sharma - 10/21/2013 - Code modified - CR-20130529-3091
                        V1.4 - Bhavi Sharma - 12/23/2013 - Code modified - CR-20130813-3414
                        V1.5 - Abhinav Sharma - 03/03/2014 - Code Modified - CR-20130829-3543
                        V1.6 - Abhinav Sharma - 04/29/2014 - CR-20140403-4958 - Method Modified (test_populateFirstDeploymentSignedOff)
                        V1.7 - Ajit Surana - 08/20/2014 - CR-20140507-5388 - Method modified (test_populateFirstDeploymentSignedOff)
                        V1.8 - Ajit Surana - 09/08/2014 - CR-20140716-6256 - test_populateFirstDeploymentSignedOff method is modified
                        V1.9 - Abhinav Sharma - 10/17/2014 - CR-20140826-7138 - New method test_populateDeploymentSignOffOldestOnProject added.
                        v1.10 - Abhinav Sharma - 03/10/2015 - CR-20141222-8389 - Method modified - myUnitTest
                        v1.11 - Abhinav Sharma - 07/29/2015 - CR-20150709-9070
						v1.12 - Abhinav Sharma - 10/20/2015 - CR-20151016-9329
						V1.13 - Mahedra Swarnkar - 07/05/2016 - CR-20160229-9651 - Added a new Test Method "testPopulateCaseFieldsFromProject".
						V1.14 - Rajeev Jain - 09/10/2016 -  CR-20160420-9785 -
     					//Overall we wants to check code functionality of 'populateMarketDataPeriodFieldsOnProject' method in ProjectTriggerHelper
 **/
    static testMethod void myUnitTest() {

        //Bypass Dupeblocker
        Util.IsTest(true);

        //Test Name (Renewal), Membership__c, owner name
        Util.IsTesting = true;
        Util.BypassAllTriggers = true;

        //delete acc.Memberships__r;
        Account acc = new Account(Name = 'testacc', Account_Formal_Name__c = 'testacc');
        insert acc;

        //Program__c prog = [select id from Program__c limit 1];
        Program__c prog = new Program__c(Name = 'testprog', Program_Acronym__c = 'TEST', Status__c = 'Active', Create_Memberships__c = 'Yes');
        insert prog;

        //Create membership data
        Membership__c mem = new Membership__c(Account_Name__c = acc.id, Program__c = prog.id);
        insert mem;

        //Create a Project record
        Project__c project = new Project__c(Name = 'Test', Institution__c = acc.Id, Primary_Paid_Membership__c = mem.Id, 
                                                Project_Phase__c = '1 - Test', Implementation_Business_Analyst__c = UserInfo.getUserId());

        //Start testing here
        Test.startTest();

        //Insert project record
        Util.BypassAllTriggers = false;
        insert project;

        //Asset for the results
        mem = [Select Primary_Project__c, BA_Assignment2__c from Membership__c where Id =: mem.Id];
        System.assertEquals(project.Id, mem.Primary_Project__c);
        System.assertEquals(project.Implementation_Business_Analyst__c, mem.BA_Assignment2__c);

        //Create a new membership record
        Util.BypassAllTriggers = true;
        Membership__c mem2 = new Membership__c(Account_Name__c = acc.id, Program__c = prog.id);
        insert mem2;

        //Update Project object
        Util.BypassAllTriggers = false;
        project.Primary_Paid_Membership__c = mem2.Id;
        project.Project_Phase__c = '2 - Build';
        update project;

        //This should update the existing and new membership record
        Map<Id, Membership__c> mapMemberships = new Map<Id, Membership__c>([Select Primary_Project__c, BA_Assignment2__c from Membership__c
                                                                                where Id =: mem.Id OR Id =: mem2.Id]);
        System.assertEquals(null, mapMemberships.get(mem.Id).Primary_Project__c);
        System.assertEquals(project.Id, mapMemberships.get(mem2.Id).Primary_Project__c);
        
        //Creata new Project with the Same Membership, This should throw exception
        Project__c project2 = new Project__c(Name = 'Test', Institution__c = acc.Id, Primary_Paid_Membership__c = mem2.Id);

        //try to insert the record
        try {

            //Insert the records
            Util.BypassAllTriggers = false;
            insert project2;

            //Code Modified - Bhavi Sharma - 06/28/2013 - CR-20130617-3170
            //This should fail Test method
            System.assert(true);
            
        } catch(Exception e) {

            //Code Modified - Bhavi Sharma - 06/28/2013 - CR-20130617-3170
            //Test case is passed in exception occured
            System.assert(false);
        }

        //blank out the Primary_Paid_Membership__c field
        Util.BypassAllTriggers = false;
        project.Primary_Paid_Membership__c = null;
        update project;

        //Asset for the results
        mem2 = [Select Primary_Project__c from Membership__c where Id =: mem2.Id];
        System.assertEquals(null, mem2.Primary_Project__c);

        //Stop test here
        Test.stopTest();
    }

    //Bhavi Sharma - CR-20130408-2822
    static testMethod void testProjectData() {
        
        //Bypass Dupeblocker
        Util.IsTest(true);

        //Test Name (Renewal), Membership__c, owner name
        Util.IsTesting = true;
        Util.BypassAllTriggers = true;

        // get one record type name
        List<RecordType> recordTypes = [SELECT Id, DeveloperName FROM RecordType WHERE SObjectType = 'Event'
                                                AND DeveloperName =: Constants.RECORD_TYPE_EVENT_DEVELOPER_NAME_BI_QA_CALL
                                                AND IsActive = true limit 1];

        //Asert or the record type
        System.assertEquals(1, recordTypes.size());

        //delete acc.Memberships__r;
        Account acc = new Account(Name = 'testacc', Account_Formal_Name__c = 'testacc');
        insert acc;

        //Program__c prog = [select id from Program__c limit 1];
        Program__c prog = new Program__c(Name = 'testprog', Program_Acronym__c = 'TEST', Status__c = 'Active', Create_Memberships__c = 'Yes');
        insert prog;

        //Create membership data
        Membership__c mem = new Membership__c(Account_Name__c = acc.id, Program__c = prog.id);
        insert mem;

        //Create membership data
        Membership__c mem1 = new Membership__c(Account_Name__c = acc.id, Program__c = prog.id);
        insert mem1;

        //Create event data
        Event event = new Event( RecordTypeId = recordTypes[0].Id, Reason_for_Not_Grading_Higher__c = 'Data concerns',
                                    Subject = 'Call', StartDateTime = System.now().addDays(-456),
                                    EndDateTime = System.now().addDays(-450), WhatId = mem.Id, Cancelled_Did_Not_Occur__c = false,
                                    Would_Buy_Again__c = '2', Event_Type__c = 'PT QA Call');

        //insert event
        insert event;
        
        //List to hold the project records
        List<Project__c> projects = new List<Project__c>();

        //Create a Project record
        Project__c project = new Project__c(Name = 'Test', Institution__c = acc.Id, Primary_Paid_Membership__c = mem.Id);
        Project__c project1 = new Project__c(Name = 'Test1', Institution__c = acc.Id, Primary_Paid_Membership__c = mem1.Id);
        projects.add(project);
        projects.add(project1);
        
        //Start testing from here
        Test.startTest();
        
        //Enable triggers again
        Util.BypassAllTriggers = false;

        //Insert Project
        insert projects;
        
        //Assert for the results
        project = [Select Id, PT_QA_Call_Event_DT__c, PT_QA_Call_Recommended_Score__c FROM Project__c WHERE Id =: projects[0].Id];
        System.assertEquals(event.StartDateTime, project.PT_QA_Call_Event_DT__c);
        System.assertEquals(Integer.valueOf(event.Would_Buy_Again__c), project.PT_QA_Call_Recommended_Score__c);

        //update event
        event.StartDateTime = System.now().addDays(-450);
        event.EndDateTime = System.now().addDays(-449);

        Event event1 = new Event( RecordTypeId = recordTypes[0].Id, Reason_for_Not_Grading_Higher__c = 'Data concerns',
                                    Subject = 'Call', StartDateTime = System.now().addDays(-445),
                                    EndDateTime = System.now().addDays(-440), WhatId = mem.Id, Cancelled_Did_Not_Occur__c = false,
                                    Would_Buy_Again__c = '2', Event_Type__c = 'PT QA Call');

        //insert event
        Util.BypassAllTriggers = false;
        update event;
        insert event1;

        //Assert for the results
        project = [Select Id, PT_QA_Call_Event_DT__c, PT_QA_Call_Recommended_Score__c FROM Project__c WHERE Id =: projects[0].Id];
        System.assertEquals(event1.StartDateTime, project.PT_QA_Call_Event_DT__c);
        System.assertEquals(Integer.valueOf(event1.Would_Buy_Again__c), project.PT_QA_Call_Recommended_Score__c);
        
        //Stop Test here
        Test.stopTest();

        //Update project
        project.PT_QA_Call_Event_DT__c = null;
        project.PT_QA_Call_Recommended_Score__c = null;
        Util.BypassAllTriggers = false;
        update project;

        //Assert for the results
        project = [Select Id, PT_QA_Call_Event_DT__c, PT_QA_Call_Recommended_Score__c FROM Project__c WHERE Id =: projects[0].Id];
        System.assertEquals(event1.StartDateTime, project.PT_QA_Call_Event_DT__c);
        System.assertEquals(Integer.valueOf(event1.Would_Buy_Again__c), project.PT_QA_Call_Recommended_Score__c);

        //update event
        event1.WhatId = mem1.Id;
        Util.BypassAllTriggers = false;
        update event1;

        //Assert for the results
        project = [Select Id, PT_QA_Call_Event_DT__c, PT_QA_Call_Recommended_Score__c FROM Project__c WHERE Id =: projects[0].Id];
        System.assertEquals(event.StartDateTime, project.PT_QA_Call_Event_DT__c);
        System.assertEquals(Integer.valueOf(event.Would_Buy_Again__c), project.PT_QA_Call_Recommended_Score__c);

        //Assert for the results
        project1 = [Select Id, PT_QA_Call_Event_DT__c, PT_QA_Call_Recommended_Score__c FROM Project__c WHERE Id =: projects[1].Id];
        System.assertEquals(event1.StartDateTime, project1.PT_QA_Call_Event_DT__c);
        System.assertEquals(Integer.valueOf(event1.Would_Buy_Again__c), project1.PT_QA_Call_Recommended_Score__c);

        //update event
        event.Would_Buy_Again__c = '8';
        event.StartDateTime = System.now().addDays(-440);
        event.EndDateTime = System.now().addDays(-430);
        Util.BypassAllTriggers = false;
        update event;

        //Assert for the results
        project = [Select Id, PT_QA_Call_Event_DT__c, PT_QA_Call_Recommended_Score__c FROM Project__c WHERE Id =: projects[0].Id];
        System.assertEquals(event.StartDateTime, project.PT_QA_Call_Event_DT__c);
        System.assertEquals(Integer.valueOf(event.Would_Buy_Again__c), project.PT_QA_Call_Recommended_Score__c);

        //update event
        event.Would_Buy_Again__c = 'N/A';
        Util.BypassAllTriggers = false;
        update event;

        //Assert for the results
        project = [Select Id, PT_QA_Call_Event_DT__c, PT_QA_Call_Recommended_Score__c FROM Project__c WHERE Id =: projects[0].Id];
        System.assertEquals(event.StartDateTime, project.PT_QA_Call_Event_DT__c);
        System.assertEquals(null, project.PT_QA_Call_Recommended_Score__c);
    }

    //Bhavi Sharma - CR-20130328-2773
    public static testMethod void testUpdateProjectByCurrentRenewalOpportunity() {

        // get one record type name
        List<RecordType> recordTypes = [SELECT Id, Name FROM RecordType WHERE SObjectType = 'Opportunity'
                                                AND Name =: Constants.RECORD_TYPE_OPPORTUNITY_PT_CONTRACT_MAINTENANCE
                                                AND IsActive = true limit 1];

        //Asert or the record type
        System.assertEquals(1, recordTypes.size());

        //delete acc.Memberships__r;
        Account acc = new Account(Name = 'testacc', Account_Formal_Name__c = 'testacc');
        insert acc;

        //Program__c prog = [select id from Program__c limit 1];
        Program__c prog = new Program__c(Name = 'testprog', Program_Acronym__c = 'TEST', Status__c = 'Active', Create_Memberships__c = 'Yes');
        insert prog;

        //Create membership data
        Membership__c mem = new Membership__c(Account_Name__c = acc.id, Program__c = prog.id);
        insert mem;

        //List of Opportunities
        List<Opportunity> opportunities = new List<Opportunity>();

        //Opportunity record
        Opportunity opportunity1 = new Opportunity( Name = 'oop1Test', RecordtypeId = recordTypes[0].Id, AccountId = acc.Id,
                                                    Program__c = prog.Id, StageName = 'Prospect',CloseDate = System.today(),
                                                    Membership__c = mem.Id,Pool_Year__c = String.valueOf(Date.today().year()),Special_Commitments__c = 'TestComitments');

        //Opportunity record
        Opportunity opportunity2 = new Opportunity( Name = 'oop1Test', RecordtypeId = recordTypes[0].Id, AccountId = acc.Id,
                                                    Program__c = prog.Id, StageName = 'Prospect',CloseDate = System.today(),
                                                    Membership__c = mem.Id,Pool_Year__c = String.valueOf(Date.today().year()),
                                                    Pool_Month__c = String.valueOf(Date.today().addMonths(2)),Special_Commitments__c = 'TestComitments');
        //Opportunity record
        Opportunity opportunity3 = new Opportunity( Name = 'oop1Test', RecordtypeId = recordTypes[0].Id, AccountId = acc.Id,
                                                    Program__c = prog.Id, StageName = 'Prospect',CloseDate = System.today(),
                                                    Membership__c = mem.Id,Pool_Year__c = String.valueOf(Date.today().year()),
                                                    Pool_Month__c = String.valueOf(Date.today().addMonths(-2)),Special_Commitments__c = 'TestComitments');
        //Opportunity record
        Opportunity opportunity4 = new Opportunity( Name = 'oop1Test', RecordtypeId = recordTypes[0].Id, AccountId = acc.Id,
                                                    Program__c = prog.Id, StageName = 'Prospect',CloseDate = System.today(),
                                                    Membership__c = mem.Id,Pool_Year__c = String.valueOf(Date.today().year()),
                                                    Pool_Month__c = String.valueOf(Date.today().addMonths(-14)),Special_Commitments__c = 'TestComitments');
        //Opportunity record
        Opportunity opportunity5 = new Opportunity( Name = 'oop1Test', RecordtypeId = recordTypes[0].Id, AccountId = acc.Id,
                                                    Program__c = prog.Id, StageName = 'Prospect',CloseDate = System.today(),
                                                    Membership__c = mem.Id,Pool_Year__c = String.valueOf(Date.today().year()),
                                                    Pool_Month__c = String.valueOf(Date.today().addMonths(8)),Special_Commitments__c = 'TestComitments');

        opportunities.add(opportunity1);
        opportunities.add(opportunity2);
        opportunities.add(opportunity3);
        opportunities.add(opportunity4);
        opportunities.add(opportunity5);

        //insert Opportunity List
        insert opportunities;

        //Create a Project record
        Project__c project = new Project__c(Name = 'Test', Institution__c = acc.Id, Primary_Paid_Membership__c = mem.Id);

        //Test starts here
        Test.startTest();

        //insert Project
        insert project;

        //get record
        project = [SELECT Current_Contract_Risk_Type__c,CPM_Special_Considerations__c FROM Project__c WHERE Id =: project.Id];

        opportunity1 = [SELECT Special_Commitments__c, Source_Contract_Type__c FROM Opportunity WHERE Id =: opportunities[0].Id];

        //assert statements
        System.assertEquals(project.Current_Contract_Risk_Type__c, opportunity1.Source_Contract_Type__c);
        System.assertEquals(project.CPM_Special_Considerations__c, opportunity1.Special_Commitments__c);

        //Test stops here
        Test.stopTest();
    }
    
    //Update Site Issues data - CR-20130813-3414
    static testmethod void testUpdateSiteIssueByProject(){
        
        //Bypass Dupeblocker
        Util.IsTest(true);

        //Test Name (Renewal), Membership__c, owner name
        Util.IsTesting = true;
        Util.BypassAllTriggers = false;
        
        //create new Project__c data
        Project__c project = new Project__c(Name = 'Test-Data', Implementation_Pod__c = 'Test', Crimson_Data_Lag__c = 10, Load_Frequency__c = 'Test', Application__c = 'Testing');
                                                
        //insert Project data
        insert project;
        
        Util.BypassAllTriggers = true;
        
        //Set of Developer Name for Site Issue's RecordType
        List<RecordType> recordTypes = [Select Id from RecordType where Name = 'CMA Data Load/Migration' AND IsActive = true AND sObjectType = 'Site_Issue__c'];
        System.assertEquals(1, recordTypes.size());
        
        //CMA Initial Deployment Support
        Id CMA_INITIAL_DEPLOYMENT_SUPPORT_RECORDTYPEID = recordTypes[0].Id;
        
        //Create List of Site
        Site_Issue__c sIssue = new Site_Issue__c(Site_Issue_Priority__c = 'High', Site_Issue_Short_Description__c = 'Test-Description',
                                                        Category__c = 'Test-Category', Data_Load_Type__c = Constants.HISTORICAL_RELOAD,
                                                        Crimson_Site_Issue_Description__c = 'Test Issue Description', RecordTypeId = CMA_INITIAL_DEPLOYMENT_SUPPORT_RECORDTYPEID,
                                                        Project__c = project.Id, CCC_Date_Observed__c = System.Today(),
                                                        Site_Issue_Created_Date__c = System.now().addDays(-54), Site_Issue_Close_Date__c = System.now().addDays(8),
                                                        Data_Load_Period_End__c = Date.Today().addDays(-62),Data_Load_Period_Begin__c = Date.today(), Files_Received__c = Date.today());
        
        //insert Site Issue
        insert sIssue;
        
        //Site Issue record
        sIssue = [SELECT Production_Business_Analyst__c, Dedicated_Advisor__c, Assigned_To_Contact__c, Data_Load_Period_End__c, 
                    Project_Implementation_Pod_1__c, Crimson_Data_Lag_1__c, Load_Frequency__c, Application_Version__c FROM Site_Issue__c WHERE Id =: sIssue.Id];
        
        //Set of Developer Name for Site Issue's RecordType
        recordTypes = [Select Id from RecordType where Name = 'CPM Data Load' AND IsActive = true AND sObjectType = 'Site_Issue__c'];
        System.assertEquals(1, recordTypes.size());
        
        //CMA Initial Deployment Support
        Id CPM_DATA_LOAD_RECORDTYPEID = recordTypes[0].Id;
        
        //Create List of Site
        Site_Issue__c cPMDataLoadIssue = new Site_Issue__c(Site_Issue_Priority__c = 'High', Site_Issue_Short_Description__c = 'Test-Description',
                                                        Category__c = 'Test-Category', Data_Load_Type__c = Constants.HISTORICAL_RELOAD,
                                                        Crimson_Site_Issue_Description__c = 'Test Issue Description', RecordTypeId = CPM_DATA_LOAD_RECORDTYPEID,
                                                        Project__c = project.Id, CCC_Date_Observed__c = System.Today(),
                                                        Site_Issue_Created_Date__c = System.now().addDays(-54), Site_Issue_Close_Date__c = System.now().addDays(8),
                                                        Data_Load_Period_End__c = Date.Today().addDays(-62),Data_Load_Period_Begin__c = Date.today(), Files_Received__c = Date.today());
        
        //Execute triggers
        Util.BypassAllTriggers = false;
        
        //insert Site Issue
        insert cPMDataLoadIssue;
        
        //Site Issue record
        cPMDataLoadIssue = [SELECT Production_Business_Analyst__c, Dedicated_Advisor__c, Assigned_To_Contact__c, Data_Load_Period_End__c, 
                    Project_Implementation_Pod_1__c, Crimson_Data_Lag_1__c, Load_Frequency__c, Application_Version__c FROM Site_Issue__c WHERE Id =: cPMDataLoadIssue.Id];
        
        //Update project data
        project.Implementation_Pod__c = 'Updated';
        project.Crimson_Data_Lag__c = 15;
        
        //Start Testing from here
        Test.StartTest();
        
        //Execute Trigger
        Util.BypassAllTriggers = false;
        
        //update Project
        update project;
        
        //Site Issue record
        sIssue = [SELECT Project_Implementation_Pod_1__c, Crimson_Data_Lag_1__c FROM Site_Issue__c WHERE Id =: sIssue.Id];
        
        //assert statements
        System.assertNotEquals(project.Implementation_Pod__c, sIssue.Project_Implementation_Pod_1__c);
        System.assertNotEquals(project.Crimson_Data_Lag__c, sIssue.Crimson_Data_Lag_1__c);
        
        //CCA Data Load
        recordTypes = [Select Id from RecordType where Name = 'CCA Data Load' AND IsActive = true AND sObjectType = 'Site_Issue__c'];
        System.assertEquals(1, recordTypes.size());
        
        //CMA Initial Deployment Support
        Id CCA_DATA_LOAD_RECORDTYPEID = recordTypes[0].Id;
        
        //Execute Trigger
        Util.BypassAllTriggers = false;

        //Update Site Issue
        sIssue.RecordTypeId = CCA_DATA_LOAD_RECORDTYPEID;
        update sIssue;
        
        //Test stops here
        Test.stopTest();
        
        //Execute Trigger
        Util.BypassAllTriggers = false;
        
        //Update project data
        project.Implementation_Pod__c = 'Updated Test';
        project.Crimson_Data_Lag__c = 20;
        project.Application__c = 'Updated';
        update project;
        
        //Site Issue record
        sIssue = [SELECT Project_Implementation_Pod_1__c, Crimson_Data_Lag_1__c, Application_Version__c FROM Site_Issue__c WHERE Id =: sIssue.Id];
        
        //assert statements
        System.assertEquals(project.Implementation_Pod__c, sIssue.Project_Implementation_Pod_1__c);
        System.assertEquals(project.Crimson_Data_Lag__c, sIssue.Crimson_Data_Lag_1__c);
        
        //Site Issue record
        cPMDataLoadIssue = [SELECT Project_Implementation_Pod_1__c, Crimson_Data_Lag_1__c, Application_Version__c FROM Site_Issue__c WHERE Id =: cPMDataLoadIssue.Id];
        
        System.assertEquals(project.Application__c, cPMDataLoadIssue.Application_Version__c);
    } 
    
    //Modified By - Ajit Surana - 09/08/2014 - CR-20140716-6256
    //Modified By - Ajit Surana - 08/20/2014 - CR-20140507-5388 - Replaced "CPM" by "CMGA" record type reference
    //Modified By - Abhinav Sharma - 04/29/2014 - CR-20140403-4958
    //on the associated Deployment record correctly or not
    static testMethod void test_populateFirstDeploymentSignedOff() {
        
        //List to hold the project records
        List<Project__c> projects = new List<Project__c>();
        
        //Getting Record Type Id Value for Deployment object
        String Compass_Connect_RTID = Util.RecordTypeId('Deployment__c', Constants.RECORD_TYPE_DEPLOYMENT_COMPASS_CONNECT_DEPLOYMENT);
        
        //Getting Record Type Id Value for Project object
        ID cpmProjRecordTypeId = [Select Id, Name FROM RecordType WHERE SobjectType = 'Project__c' and RecordType.DeveloperName = 'CPM'].Id;
        
        //Getting Record Type Id Value for Project object
        ID sscProjRecordTypeId = [Select Id, Name FROM RecordType WHERE SobjectType = 'Project__c' and RecordType.DeveloperName = 'SSC'].Id;
        
        //create new Project__c data
        Project__c project_1 = new Project__c(Name = 'Test-Data1', RecordTypeId = cpmProjRecordTypeId );
        Project__c project_2 = new Project__c(Name = 'Test-Data2', RecordTypeId = cpmProjRecordTypeId );
        Project__c project_3 = new project__c(Name = 'Test-Data3', RecordTypeId = cpmProjRecordTypeId );
        Project__c project_4 = new project__c(Name = 'Test-Data4', RecordTypeId = cpmProjRecordTypeId );
        Project__c project_5 = new project__c(Name = 'Test-Data5', RecordTypeId = sscProjRecordTypeId );
        Project__c project_6 = new project__c(Name = 'Test-Data6', RecordTypeId = sscProjRecordTypeId );
        
        //Adding project records into the list
        projects.add(project_1);    
        projects.add(project_2);
        projects.add(project_3);
        projects.add(project_4);
        projects.add(project_5);
        projects.add(project_6);
        
        //Make a try to insert the record
        insert projects;
        
        //Retrieving program details
        projects = [Select ID, First_Deployment_Signed_Off__c, Date_Site_Live__c, Site_Live_Target__c FROM Project__c LIMIT 6];
        
        //Assert for the results
        System.assertEquals(6, projects.size());
        System.assertEquals(null, projects[0].First_Deployment_Signed_Off__c);
        System.assertEquals(null, projects[1].First_Deployment_Signed_Off__c);
        System.assertEquals(null, projects[2].First_Deployment_Signed_Off__c);
        System.assertEquals(null, projects[3].First_Deployment_Signed_Off__c);
        System.assertEquals(null, projects[0].Date_Site_Live__c);
        System.assertEquals(null, projects[1].Date_Site_Live__c);
        System.assertEquals(null, projects[2].Date_Site_Live__c);
        System.assertEquals(null, projects[3].Date_Site_Live__c);
        System.assertEquals(null, projects[0].Site_Live_Target__c);
        System.assertEquals(null, projects[1].Site_Live_Target__c);
        System.assertEquals(null, projects[2].Site_Live_Target__c);
        System.assertEquals(null, projects[3].Site_Live_Target__c);
        System.assertEquals(null, projects[4].Site_Live_Target__c);
        System.assertEquals(null, projects[5].Site_Live_Target__c);
        
        //Deployment Type record
        Deployment_Type__c deployType = new Deployment_Type__c(Name = 'Test-Deploy-type', Sign_Off_to_Move_to_Prod_Lag__c = 10);
        insert deployType;
        
        //List to hold the deployment records
        List<Deployment__c> deployments = new List<Deployment__c>();
        
        //Deployment record
        Deployment__c deployment_1 = new Deployment__c(Name = 'Test-Deploy1', Project__c = projects[0].Id, RecordTypeId = Compass_Connect_RTID,
                                                      Deployment_Type__c = deployType.Id, Use_Standard_Milestone_Goals__c = false,
                                                      C_A_DC__c = System.today().addDays(-2), C_E_DC__c = System.today().addDays(-3));
        Deployment__c deployment_2 = new Deployment__c(Name = 'Test-Deploy2', Project__c = projects[0].Id, RecordTypeId = Compass_Connect_RTID,
                                                      Deployment_Type__c = deployType.Id, Use_Standard_Milestone_Goals__c = false, 
                                                      C_A_DC__c = System.today().addDays(-3),C_E_DC__c = System.today().addDays(-4));
                                                      
        Deployment__c deployment_3 = new Deployment__c(Name = 'Test-Deploy3', Project__c = projects[1].Id, RecordTypeId = Compass_Connect_RTID,
                                                      Deployment_Type__c = deployType.Id, Use_Standard_Milestone_Goals__c = false,
                                                      C_A_DC__c = System.today().addDays(-1), C_E_DC__c = System.today().addDays(-1));
        Deployment__c deployment_4 = new Deployment__c(Name = 'Test-Deploy5', Project__c = projects[1].Id, RecordTypeId = Compass_Connect_RTID,
                                                      Deployment_Type__c = deployType.Id, C_E_DC__c = System.today().addDays(-2),
                                                      Use_Standard_Milestone_Goals__c = false);
                                                      
        Deployment__c deployment_5 = new Deployment__c(Name = 'Test-Deploy6', Project__c = projects[2].Id, RecordTypeId = Compass_Connect_RTID,
                                                      Deployment_Type__c = deployType.Id, Use_Standard_Milestone_Goals__c = false,
                                                      C_E_DC__c = System.today().addDays(-4));
        Deployment__c deployment_6 = new Deployment__c(Name = 'Test-Deploy7', Project__c = projects[2].Id, RecordTypeId = Compass_Connect_RTID,
                                                      Deployment_Type__c = deployType.Id, Use_Standard_Milestone_Goals__c = false,
                                                      C_E_DC__c = System.today().addDays(-3));
                                                      
        Deployment__c deployment_7 = new Deployment__c(Name = 'Test-Deploy4', Project__c = projects[3].Id, RecordTypeId = Compass_Connect_RTID,
                                                      Deployment_Type__c = deployType.Id);
        
        Deployment__c deployment_8 = new Deployment__c(Name = 'Test-Deploy Record', Project__c = projects[4].Id, RecordTypeId = Compass_Connect_RTID,
                                                      Deployment_Type__c = deployType.Id, Use_Standard_Milestone_Goals__c = false,
                                                      C_A_DC__c = System.today().addDays(-3));
        
        Deployment__c deployment_9 = new Deployment__c(Name = 'Test-Deploy', Project__c = projects[5].Id, RecordTypeId = Compass_Connect_RTID,
                                                      Deployment_Type__c = deployType.Id, Use_Standard_Milestone_Goals__c = false,
                                                      C_A_DC__c = System.today().addDays(-3));
        
        
        //populating list with the records
        deployments.add(deployment_1);  deployments.add(deployment_2); deployments.add(deployment_3);   
        deployments.add(deployment_4); deployments.add(deployment_5); deployments.add(deployment_6);
        deployments.add(deployment_7); deployments.add(deployment_8); deployments.add(deployment_9);   
        
        //Bypass all other triggers
        Util.IsTest(true);
        Util.BypassAllTriggers = true;
        
        //Insert deployment
        insert deployments;  
         
        //Start Test From Here
        Test.startTest();
        
        //Update Project
        Util.BypassAllTriggers = false;
        update projects;
        
        //Assert for results
        //Retrieving program details
        projects = [Select ID, First_Deployment_Signed_Off__c, Date_Site_Live__c, Site_Live_Target__c FROM Project__c LIMIT 6];
        
        //Assert for results
        System.assertEquals(6, projects.size());
        System.assertEquals(System.today().addDays(-3), projects[0].First_Deployment_Signed_Off__c);
        System.assertEquals(System.today().addDays(-3), projects[0].Date_Site_Live__c);
        System.assertEquals(System.today().addDays(-4), projects[0].Site_Live_Target__c);
        System.assertEquals(System.today().addDays(-1), projects[1].First_Deployment_Signed_Off__c);
        System.assertEquals(System.today().addDays(-1), projects[1].Date_Site_Live__c);
        System.assertEquals(System.today().addDays(-1), projects[1].Site_Live_Target__c);
        System.assertEquals(null, projects[2].First_Deployment_Signed_Off__c);
        System.assertEquals(null, projects[2].Date_Site_Live__c);
        System.assertEquals(System.today().addDays(-4), projects[2].Site_Live_Target__c);
        System.assertEquals(null, projects[3].First_Deployment_Signed_Off__c);
        System.assertEquals(null, projects[3].Date_Site_Live__c);
        System.assertEquals(null, projects[3].Site_Live_Target__c);
        
        System.assertEquals(System.today().addDays(-3), projects[4].Date_Site_Live__c);
        System.assertEquals(System.today().addDays(-3), projects[5].Date_Site_Live__c);
        
        projects[0].First_Deployment_Signed_Off__c = null;
        projects[0].Date_Site_Live__c = null;
        projects[0].Site_Live_Target__c = null;
        projects[1].Site_Live_Target__c = null;
        projects[2].First_Deployment_Signed_Off__c = null;
        
        projects[4].Date_Site_Live__c = System.today().addDays(-3);
        projects[5].Date_Site_Live__c = System.today().addDays(-2);
        
        update projects;
        
        //Assert for results
        //Retrieving program details
        projects = [Select ID, First_Deployment_Signed_Off__c, Date_Site_Live__c, Site_Live_Target__c FROM Project__c LIMIT 6];
        
        //Assert for the results
        System.assertEquals(6, projects.size());
        System.assertEquals(System.today().addDays(-3), projects[0].First_Deployment_Signed_Off__c);
        System.assertEquals(System.today().addDays(-3), projects[0].Date_Site_Live__c);
        System.assertEquals(System.today().addDays(-4), projects[0].Site_Live_Target__c);
        System.assertEquals(System.today().addDays(-1), projects[1].First_Deployment_Signed_Off__c);
        System.assertEquals(System.today().addDays(-1), projects[1].Date_Site_Live__c);
        System.assertEquals(System.today().addDays(-1), projects[1].Site_Live_Target__c);
        System.assertEquals(null, projects[2].First_Deployment_Signed_Off__c);
        System.assertEquals(null, projects[2].Date_Site_Live__c);
        System.assertEquals(System.today().addDays(-4), projects[2].Site_Live_Target__c);
        System.assertEquals(null, projects[3].First_Deployment_Signed_Off__c);
        System.assertEquals(null, projects[3].Date_Site_Live__c);
        System.assertEquals(null, projects[3].Site_Live_Target__c);
        
        System.assertEquals(System.today().addDays(-3), projects[4].Date_Site_Live__c);
        System.assertEquals(System.today().addDays(-3), projects[5].Date_Site_Live__c);
        
        //Stop Test Here
        Test.stopTest();
    }
    
    //New Test method added - Abhinav Sharma - 10/17/2014 - CR-20140826-7138
    static testMethod void test_populateDeploymentSignOffOldestOnProject() {
        
        //Getting Record Type for Project object
        List<RecordType> projectRecordTypes = [Select Id FROM RecordType WHERE SobjectType = 'Project__c' and (DeveloperName = 'SSM' 
                                                    OR DeveloperName = 'RCS') AND IsActive = true ORDER BY DeveloperName];
        
        //assert statement
        System.assertEquals(2, projectRecordTypes.size());
        
        //Getting "SSM" Record Type Id Value for Deployment object
        ID ssmDeployRecordTypeId = [Select Id, Name FROM RecordType WHERE SobjectType = 'Deployment__c' and Name = 'SSM Deployment'].Id;
        
        //Getting "CCC" Record Type Id Value for Deployment object
        ID cccDeployRecordTypeId = [Select Id, Name FROM RecordType WHERE SobjectType = 'Deployment__c' and Name = 'CCC Deployment'].Id;
        
        //List to hold test Project records
        List<Project__c> listProject = new List<Project__c>();
        
        listProject.add(new Project__c(Name = 'Test-Project1',RecordTypeId = projectRecordTypes[0].Id));
        listProject.add(new Project__c(Name = 'Test-Project2',RecordTypeId = projectRecordTypes[0].Id));
        listProject.add(new Project__c(Name = 'Test-Project3',RecordTypeId = projectRecordTypes[1].Id));
        
        //Insert records into List
        insert listProject;
        
        //Deployment Type record
        Deployment_Type__c deployType = new Deployment_Type__c(Name = 'Test-Deploy-type', Sign_Off_to_Move_to_Prod_Lag__c = 10);
        insert deployType;
        
        //List to hold test Deployment records
        List<Deployment__c> listDeployment = new List<Deployment__c>();
        
        listDeployment.add(new Deployment__c(Name = 'Test-Deploy1', Project__c = listProject[0].Id, RecordTypeId = ssmDeployRecordTypeId,
                                             Contingent_Revenue_Invoiced__c = 100, Deployment_Type__c = deployType.Id, Total_Actual_Revenue_to_Date__c = 200,
                                             Actual_Market_Basket_Size__c = 10, Use_Standard_Milestone_Goals__c = true,
                                             C_A_DC__c = Date.today()));
                                             
        listDeployment.add(new Deployment__c(Name = 'Test-Deploy2', Project__c = listProject[0].Id, RecordTypeId = ssmDeployRecordTypeId,
                                             Contingent_Revenue_Invoiced__c = 200, Deployment_Type__c = deployType.Id, Total_Actual_Revenue_to_Date__c = 100,
                                             Actual_Market_Basket_Size__c = 40, Use_Standard_Milestone_Goals__c = true,
                                             C_A_DC__c = Date.today().addMonths(-3)));
        
        listDeployment.add(new Deployment__c(Name = 'Test-Deploy3', Project__c = listProject[1].Id, RecordTypeId = cccDeployRecordTypeId,
                                             Contingent_Revenue_Invoiced__c = 200, Deployment_Type__c = deployType.Id, Total_Actual_Revenue_to_Date__c = 100,
                                             Actual_Market_Basket_Size__c = 40, Use_Standard_Milestone_Goals__c = true, C_A_DS__c = Date.today().addDays(8),
                                             C_A_DC__c = Date.today().addMonths(-4)));
        
        listDeployment.add(new Deployment__c(Name = 'Test-Deploy4', Project__c = listProject[1].Id, RecordTypeId = ssmDeployRecordTypeId,
                                             Contingent_Revenue_Invoiced__c = 50, Deployment_Type__c = deployType.Id, Total_Actual_Revenue_to_Date__c = 20,
                                             Actual_Market_Basket_Size__c = 30, Use_Standard_Milestone_Goals__c = true,
                                             C_A_DC__c = Date.today().addMonths(2)));
                                             
        listDeployment.add(new Deployment__c(Name = 'Test-Deploy5', Project__c = listProject[1].Id, RecordTypeId = ssmDeployRecordTypeId,
                                             Contingent_Revenue_Invoiced__c = 60, Deployment_Type__c = deployType.Id, Total_Actual_Revenue_to_Date__c = 125,
                                             Actual_Market_Basket_Size__c = 15, Use_Standard_Milestone_Goals__c = true,
                                             C_A_DC__c = Date.today().addMonths(1)));
        
        listDeployment.add(new Deployment__c(Name = 'Test-Deploy5', Project__c = listProject[0].Id, RecordTypeId = ssmDeployRecordTypeId,
                                             Contingent_Revenue_Invoiced__c = 60, Deployment_Type__c = deployType.Id, Total_Actual_Revenue_to_Date__c = 125,
                                             Actual_Market_Basket_Size__c = 15, Use_Standard_Milestone_Goals__c = true,
                                             C_A_DC__c = Date.today()));
        
        listDeployment.add(new Deployment__c(Name = 'Test-Deploy5', Project__c = listProject[2].Id, RecordTypeId = ssmDeployRecordTypeId,
                                             Contingent_Revenue_Invoiced__c = 60, Deployment_Type__c = deployType.Id, Total_Actual_Revenue_to_Date__c = 125,
                                             Actual_Market_Basket_Size__c = 15, Use_Standard_Milestone_Goals__c = true,
                                             C_A_DC__c = Date.today().addMonths(-3)));
        
        //Test starts here
        Test.startTest();
        
        //Insert test records into List                                     
        insert listDeployment;
                                             
        //Retreive all required fields needed for assert
        List<Project__c> projectList = [SELECT Id, Deployment_Sign_Off_Oldest__c FROM Project__c WHERE Id =: listProject ORDER BY Name];
        
        //Assert for reults  
        System.assertEquals(Date.today().addMonths(-3), projectList[0].Deployment_Sign_Off_Oldest__c);
        System.assertEquals(Date.today().addMonths(-4), projectList[1].Deployment_Sign_Off_Oldest__c);
        System.assertEquals(null, projectList[2].Deployment_Sign_Off_Oldest__c);
        
        projectList[0].Deployment_Sign_Off_Oldest__c = Date.today().addYears(-1);
        projectList[1].Deployment_Sign_Off_Oldest__c = Date.today().addYears(1);
        projectList[2].Deployment_Sign_Off_Oldest__c = Date.today().addMonths(15);
        
        Util.BypassAllTriggers = false;
        update projectList;
        
        //Retreive all required fields needed for assert
        projectList = [SELECT Id, Deployment_Sign_Off_Oldest__c FROM Project__c WHERE Id =: listProject ORDER BY Name];
        
        //Assert for reults  
        System.assertEquals(Date.today().addMonths(-3), projectList[0].Deployment_Sign_Off_Oldest__c);
        System.assertEquals(Date.today().addMonths(-4), projectList[1].Deployment_Sign_Off_Oldest__c);
        System.assertEquals(Date.today().addMonths(15), projectList[2].Deployment_Sign_Off_Oldest__c);
    }
    
    //Modified By - Abhinav Sharma - 10/20/2015 - CR-20151016-9329
    //New Test method added - Abhinav Sharma - 07/29/2015 - CR-20150709-9070
    static testMethod void test_populateProjectFieldsFromChildren() {

        //Bypass Dupeblocker
        Util.IsTest(true);
    
        //Bypassing all trigger so then testing data can be created with ease
        Util.BypassAllTriggers = true;
    
        //Project
        Project__c project = new Project__c(Name = 'Test-Data');
        insert project;
    
        //Query for the "Member Support" record types (CMA Data Load/Migration)
        List<RecordType> recordTypes = [SELECT Id FROM RecordType WHERE sObjectType = 'Site_Issue__c' 
                                        AND DeveloperName = 'CMA_Data_Load_Production' 
                                        AND isActive = true];
        //Asert or the record type
        System.assertEquals(1, recordTypes.size());
    
        //List to hold the member support records
        List<Site_Issue__c> memberSupports = new List<Site_Issue__c>();
    
        //Member Support
        Site_Issue__c sIssue_1 = new Site_Issue__c(Crimson_Site_Issue_Description__c = 'Test Issue Description', 
                                         RecordTypeId = recordTypes[0].Id, Project__c = project.Id, 
                                         Site_Issue_Created_Date__c = System.now().addDays(-3), 
                                         Site_Issue_Close_Date__c = System.now().addDays(2), 
                                         Data_Load_Period_End__c = Date.Today().addDays(3),
                                         Data_Load_Period_Begin__c = Date.today(), Files_Received__c = Date.today(),
                                         Status__c = ProjectTriggerHelper.STATUS_22_PRODUCTION_MIGRATION_COMPLETE,
                                         PRM_Application_Version__c = '2014.10', Estimated_Prod_Team_Transition_Date__c = Date.Today(), 
                                         Percent_of_PCP_Revenue_Not_Captured__c = 23,
                                         Data_Load_Type__c = 'PRM Migration');
    
        //Member Support
        Site_Issue__c sIssue_2 = new Site_Issue__c(Crimson_Site_Issue_Description__c = 'Test Issue Description', 
                                         RecordTypeId = recordTypes[0].Id, Project__c = project.Id, 
                                         Site_Issue_Created_Date__c = System.now().addDays(-3), 
                                         Site_Issue_Close_Date__c = System.now().addDays(1), 
                                         Data_Load_Period_End__c = Date.Today().addDays(3),
                                         Data_Load_Period_Begin__c = Date.today(), Files_Received__c = Date.today(),
                                         Status__c = ProjectTriggerHelper.STATUS_22_PRODUCTION_MIGRATION_COMPLETE,
                                         PRM_Application_Version__c = '2015.10',Estimated_Prod_Team_Transition_Date__c = Date.Today(),
                                         Percent_of_PCP_Revenue_Not_Captured__c = 23,
                                         Data_Load_Type__c = 'PRM Migration');
    
    
        memberSupports.add(sIssue_1);
        memberSupports.add(sIssue_2);
    
        //Bypassing all trigger so then testing data can be created with ease
        Util.BypassAllTriggers = true;
    
        //insert Site Issue
        insert memberSupports;
    
        //Query through project records
        List<Project__c> listProjects = [Select Id,PRM_Version__c From Project__c Where Id =: project.Id ];
        
        //Apply asserts on the results
        System.assertEquals(null , listProjects[0].PRM_Version__c);
        
        //Enabling all triggers
        Util.BypassAllTriggers = false;
        
         //Start Test
         Test.startTest();
        
        //Update the project records
        update project;
        
        //Query through project records
        listProjects = [Select Id,PRM_Version__c From Project__c Where Id =: project.Id ];
        
        //Apply asserts on the results
        System.assertEquals('2014.10' , listProjects[0].PRM_Version__c);
        
        //Disabling all triggers
        Util.BypassAllTriggers = True;
        memberSupports[1].Site_Issue_Close_Date__c = System.now().addDays(4);
            
        //Update the project records
        update memberSupports[1];
        
        //Enabling all triggers 
        Util.BypassAllTriggers = false;
        
        //Update the project records
        update project;
        
        //Query through project records
        listProjects = [Select Id,PRM_Version__c From Project__c Where Id =: project.Id ];
        
        //Apply asserts on the results
        System.assertEquals('2015.10' , listProjects[0].PRM_Version__c);
        
         //Stop Test
         Test.stopTest();
    }

    //Added By - Mahedra Swarnkar - 07/05/2016 - CR-20160229-9651
    static testmethod void testPopulateCaseFieldsFromProject() {
      	
        //Bypass Dupeblocker
        Util.IsTest(true);
        
        //Bypassing Triggers so then test data can be created easily
        Util.byPassAllTriggers = true;
        
        //Profile    
        Profile p = [SELECT Id FROM Profile WHERE Name = 'System Administrator']; 
        
        //List to hold the users
        List<User> users = new List<User>();
      
        //User 1
        User user_1 = new User(Alias = 'standt', Email='standarduser@testorg.com', 
                            EmailEncodingKey='UTF-8', LastName='Testing1', LanguageLocaleKey='en_US', 
                            LocaleSidKey='en_US', ProfileId = p.Id, department = 'STP',
                            TimeZoneSidKey = 'GMT', UserName=Math.random() + '@test.com');
                            
        //User 2
        User user_2 = new User(Alias = 'standt', Email='standarduser@testorg1.com', 
                            EmailEncodingKey='UTF-8', LastName='Testing2', LanguageLocaleKey='en_US', 
                            LocaleSidKey='en_US', ProfileId = p.Id, department = 'STP',
                            TimeZoneSidKey='GMT', UserName=Math.random() + '@test.com');
        //User 3
        User user_3 = new User(Alias = 'standt', Email='standarduser@testorg2.com', 
                            EmailEncodingKey='UTF-8', LastName='Testing3', LanguageLocaleKey='en_US', 
                            LocaleSidKey='en_US', ProfileId = p.Id, department = 'STP',
                            TimeZoneSidKey='GMT', UserName=Math.random() + '@test.com');
                            
        //Populating list with the user instance
        users.add(user_1); users.add(user_2); users.add(user_3);
        insert users;
        
        //Create an institution
        Account account = TestUtilities.CreateNewAccount(false);
        
        //Insert accounts
        insert account;
        
        //create contact
        Contact c = TestUtilities.CreateNewContact(account, false);
        c.AccountId = account.Id;
        insert c;
        
        //Create program data
        List<Program__c> programs = new List<Program__c>();
        Program__c program_1 = new Program__c(Name = 'testName 1', Program_Acronym__c = 'testing TD', 
                                              Business_line__c = 'TD', Status__c = 'Active');
        Program__c program_2 = new Program__c(Name = 'testName 2', Program_Acronym__c = 'testing', 
                                              Business_line__c = 'TD', Status__c = 'Active');
        programs.add(program_1); programs.add(program_2);
        insert programs;
        
        //Assert for the results
        System.assert(programs != null);
        System.assert(programs.size() == 2);
        
        
        //create Contract ABC test data
        List<Contract__c> contracts = new List<Contract__c>();
        Contract__c contractABC_1 = new Contract__c(Payer_Account__c = account.Id, Type__c = 'NBB', 
                                                    Program__c = programs[0].Id, Start__c = System.today().addDays(-5),
                                                    End__c = System.today().addDays(5));
        Contract__c contractABC_2 = new Contract__c(Payer_Account__c = account.Id, Type__c = 'NBB', 
                                                    Program__c = programs[1].Id, Start__c = System.today().addDays(-5),
                                                    End__c = System.today().addDays(7));
        
        contracts.add(contractABC_1); contracts.add(contractABC_2);
        insert contracts;
        
        //Assert for the results
        System.assert(contracts != null);
        System.assert(contracts.size() == 2);
        
        //create Contract ABC test data
        List<Project__c> projects = new List<Project__c>();
        Project__c project_1 = new Project__c( Name = 'Test1', Membership_Advisor_Relationship_Manager__c = users[0].Id, 
                                               Dedicated_Advisor__c = users[1].Id, Program_Associate__c = users[2].Id, 
                                               No_of_Participants__c = 1, Cohort_ID_s__c = 'Testing', X1_2_Day__c = 1, 
                                               Contract_Start_Date__c = System.today().addDays(-2), 
                                               Internal_Strat_Session_NPI_Actual__c = System.today().addDays(2), 
                                               Service_Date_Start__c = System.today().addDays(-1));
        
        Project__c project_2 = new Project__c( Name = 'Test2', Membership_Advisor_Relationship_Manager__c = users[1].Id, 
                                               Dedicated_Advisor__c = users[2].Id, Program_Associate__c = users[0].Id, 
                                               No_of_Participants__c = 2, Cohort_ID_s__c = 'Test_Cohort', Full_Day__c = 1, 
                                               Contract_Start_Date__c = System.today().addDays(-2), 
                                               Internal_Strat_Session_NPI_Actual__c = System.today().addDays(2), 
                                               Service_Date_Start__c = System.today().addDays(-1));
        
        projects.add(project_1); projects.add(project_2);
        insert projects;
        
        //Assert for the results
        System.assert(projects != null);
        System.assert(projects.size() == 2);
        
        //Querying Details for "Member & Employee Support" record type on Case Object
        List<RecordType> caseRdTypes = [SELECT ID, DeveloperName FROM RecordType 
                                   		Where sObjectType = 'Case' 
                                   		AND IsActive = true 
                                   		AND DeveloperName IN ('Talent_Development')];
                
        //Assert for the results
        System.assert(caseRdTypes != null);
        System.assert(caseRdTypes.size() == 1);
        System.assert(caseRdTypes[0].DeveloperName == 'Talent_Development');
        
        //Record Type Setting list
        list<RecordType_Setting__c> listRTSettings = new list<RecordType_Setting__c>();

        //Record Type Setting instance
        RecordType_Setting__c rs_1 = new RecordType_Setting__c(Name = 'Test1', 
                                                             Name__c = 'Talent Development', 
                                                             SFID__c = caseRdTypes[0].Id, SObjectType__c = 'Case');
		listRTSettings.add(rs_1);
        insert listRTSettings;
        
        //List to hold the case records
        List<Case> cases = new List<Case>();
        
        //Create a sample case record to insert and test case trigger
        cases.add( new Case(RecordTypeId = caseRdTypes[0].Id, Origin = 'ABC', Subject = 'Test', 
                                Description = 'Test', ContactId = c.Id, Deadline__c = System.today().addDays(1),
                                Project_Source_MS__c = projects[0].Id, Contract__c = contracts[0].Id));
        
        //Create a sample case record to insert and test case trigger
        cases.add( new Case(RecordTypeId = caseRdTypes[0].Id, Origin = 'ABC1', Subject = 'Test', Description = 'Test2',
                            	ContactId = c.Id, Deadline__c = System.today().addDays(1), Contract__c = contracts[1].Id,
                          		Project_Source_MS__c = projects[1].Id));
        
        //Create a sample case record to insert and test case trigger
        cases.add( new Case(RecordTypeId = caseRdTypes[0].Id, Origin = 'ABC2', Subject = 'Test', Description = 'Test3',
                            	ContactId = c.Id, Deadline__c = System.today().addDays(1)));
        
        //Start test from here
        Test.startTest();
        
        //Insert Cases
        Util.byPassAllTriggers = false;
        insert cases;
        
        //By pass all the triggers
        Util.byPassAllTriggers = true;
        
        //Query through Cases
       	cases = [Select Id, Origin, RM__c, DA__c, Associate__c, No_of_Participants__c, Cohort_ID__c, Half_Day_or_Full_Day__c, 
                 Contract_Service_Start__c, Contract_Service_End__c, Service_Start__c, Project_Year__c FROM Case Where Project_Source_MS__c != null ORDER BY Origin ASC];
        
        //Asserts on results
        System.assertEquals(2, cases.size());
        System.assertEquals('ABC', cases[0].Origin);
        System.assertEquals('Testing1', cases[0].RM__c);
        System.assertEquals('Testing2', cases[0].DA__c);
        System.assertEquals('Testing3', cases[0].Associate__c);
        System.assertEquals(1, cases[0].No_of_Participants__c);
        System.assertEquals('Testing', cases[0].Cohort_ID__c);
        System.assertEquals('1/2 Day', cases[0].Half_Day_or_Full_Day__c);
        System.assertEquals(System.today().addDays(-2), cases[0].Contract_Service_Start__c);
        System.assertEquals(System.today().addDays(2), cases[0].Contract_Service_End__c);
        System.assertEquals(System.today().addDays(-1), cases[0].Service_Start__c);
        System.assert((cases[0].Project_Year__c.contains(' - 2016')));
        
        //update Case to change the Project source
        cases[0].Contract__c = contracts[1].Id;
        cases[1].Contract__c = null;
		
        //Enable All the Triggers 
        Util.byPassAllTriggers = true;
        
        //Update the case
        update cases;
        
        projects[0].Membership_Advisor_Relationship_Manager__c = users[1].Id;
        projects[0].Dedicated_Advisor__c = users[2].Id;
        projects[0].Program_Associate__c = users[0].Id;
        projects[0].No_of_Participants__c = 2;
        projects[0].Cohort_ID_s__c = 'Test_Cohort';
        projects[0].Full_Day__c = 1;
        projects[0].X1_2_Day__c = null;
        projects[0].Contract_Start_Date__c = System.today().addDays(-2);
        projects[0].Internal_Strat_Session_NPI_Actual__c = System.today().addDays(2);
        projects[0].Service_Date_Start__c = System.today().addDays(-1);
        
        projects[1].Membership_Advisor_Relationship_Manager__c = users[2].Id;
        projects[1].Dedicated_Advisor__c = users[0].Id;
        projects[1].Program_Associate__c = users[1].Id;
        projects[1].No_of_Participants__c = 4;
        projects[1].Cohort_ID_s__c = 'Test_Cohort_ABC';
        
        //By pass all the triggers
        Util.byPassAllTriggers = false;
        
        //Update the projects.
        update projects;
        
        //Query through Cases
       	cases = [Select Id, Origin, RM__c, DA__c, Associate__c, No_of_Participants__c, Cohort_ID__c, Half_Day_or_Full_Day__c, 
                 Contract_Service_Start__c, Contract_Service_End__c, Service_Start__c, Project_Year__c 
                 FROM Case Where Project_Source_MS__c != null ORDER BY Origin ASC ];
        
        //Asserts on results
        System.assertEquals(2, cases.size());
        System.assertEquals('Testing2', cases[0].RM__c);
        System.assertEquals('Testing3', cases[0].DA__c);
        System.assertEquals('Testing1', cases[0].Associate__c);
        System.assertEquals(2, cases[0].No_of_Participants__c);
        System.assertEquals('Test_Cohort', cases[0].Cohort_ID__c);
        System.assertEquals('Full Day', cases[0].Half_Day_or_Full_Day__c);
        System.assert((cases[0].Project_Year__c.contains(' - 2016')));
        
        System.assertEquals('Testing3', cases[1].RM__c);
        System.assertEquals('Testing1', cases[1].DA__c);
        System.assertEquals('Testing2', cases[1].Associate__c);
        System.assertEquals(4, cases[1].No_of_Participants__c);
        System.assertEquals('Test_Cohort_ABC', cases[1].Cohort_ID__c);
        //Stop test here
        Test.stopTest();
    }
    
     //Added by - Rajeev Jain - 09/10/2016 -  CR-20160420-9785 -
     //Overall we wants to check code functionality of 'populateMarketDataPeriodFieldsOnProject' method in ProjectTriggerHelper
    static testmethod void testpopulateMarketDataPeriodFieldsOnProject(){
    	
    	 //Bypass Dupeblocker
        Util.IsTest(true);
    
        //Bypassing all trigger so then testing data can be created with ease
        Util.BypassAllTriggers = true;
    
        //Project
        Project__c project = new Project__c(Name = 'Test-Data');
        insert project;
    
        //Query for the "Member Support" record types (CMA Data Load/Migration)
        List<RecordType> recordTypes = [SELECT Id FROM RecordType WHERE sObjectType = 'Site_Issue__c' 
                                        AND DeveloperName = 'CMA_Data_Load_Production' 
                                        AND isActive = true];
        //Asert or the record type
        System.assertEquals(1, recordTypes.size());
    
        //List to hold the member support records
        List<Site_Issue__c> memberSupports = new List<Site_Issue__c>();
    
        //Member Support
        Site_Issue__c sIssue_1 = new Site_Issue__c(Crimson_Site_Issue_Description__c = 'Test Issue Description', 
                                         RecordTypeId = recordTypes[0].Id, Project__c = project.Id, 
                                         Site_Issue_Created_Date__c = System.now().addDays(-3), 
                                         Site_Issue_Close_Date__c = System.now().addDays(2), 
                                         Data_Load_Period_End__c = Date.Today().addDays(3),
                                         Data_Load_Period_Begin__c = Date.today(), Files_Received__c = Date.today(),
                                         Status__c = ProjectTriggerHelper.STATUS_22_PRODUCTION_MIGRATION_COMPLETE,
                                         PRM_Application_Version__c = '2014.10', Estimated_Prod_Team_Transition_Date__c = Date.Today(), 
                                         Percent_of_PCP_Revenue_Not_Captured__c = 23,
                                         Data_Load_Type__c = 'PRM Migration',
                                         Market_Data_Period_Begin__c = Date.Today().addDays(1),
                                         Market_Data_Period_End__c = Date.Today().addDays(5));
    
        //Member Support
        Site_Issue__c sIssue_2 = new Site_Issue__c(Crimson_Site_Issue_Description__c = 'Test Issue Description', 
                                         RecordTypeId = recordTypes[0].Id, Project__c = project.Id, 
                                         Site_Issue_Created_Date__c = System.now().addDays(-3), 
                                         Site_Issue_Close_Date__c = System.now().addDays(1), 
                                         Data_Load_Period_End__c = Date.Today().addDays(3),
                                         Data_Load_Period_Begin__c = Date.today(), Files_Received__c = Date.today(),
                                         Status__c = ProjectTriggerHelper.STATUS_22_PRODUCTION_MIGRATION_COMPLETE,
                                         PRM_Application_Version__c = '2015.10',Estimated_Prod_Team_Transition_Date__c = Date.Today(),
                                         Percent_of_PCP_Revenue_Not_Captured__c = 23,
                                         Data_Load_Type__c = 'PRM Migration',
                                         Market_Data_Period_Begin__c = Date.Today().addDays(1),
                                         Market_Data_Period_End__c = Date.Today().addDays(7));
    
    
        memberSupports.add(sIssue_1);
        memberSupports.add(sIssue_2);
    
        //Bypassing all trigger so then testing data can be created with ease
        Util.BypassAllTriggers = true;
    
        //insert Site Issue
        insert memberSupports;	
        
        //Start Test
        Test.startTest();
        
        //Now Update only sIssue_2 instance in order to make it recently modified Member Support Reocrd
        //By doing this, we would be able to populate sIssue_2's Market_Data_Period_Begin__c and Market_Data_Period_End__c values on Ms's Parent Project Record
        sIssue_2.Status__c = ProjectTriggerHelper.STATUS_22_PRODUCTION_MIGRATION_COMPLETE;
        sIssue_2.Data_Load_Type__c = ProjectTriggerHelper.DATA_LOADTYPE_OFF_CYCLE_MIGRATION ;
        update sIssue_2;
        
        //Now Update Project's  Market_Data_Period_Begin__c, Market_Data_Period_End__c fields value, since trigger is checking update for this
        project.Market_Data_Period_Begin__c = Date.today();
        project.Market_Data_Period_End__c = Date.today().adddays(4);
        
        //Disabling the bypass trigger check and want's to run ProjectTriggeHelper' class code logic for Mentioned method in comment section
        Util.BypassAllTriggers = false;
        
        //Stop Test
        Test.stopTest();
        
        //Update Project
        update project;
        
        //Asserts for Results
        //Since sIssue_2 intance is Most Ms record for Project as a child, 
        //so as per the Trigger logic, Projet's Market_Data_Period_Begin__c and Market_Data_Period_End__c fields must be populated with most Recent Ms's Market_Data_Period_Begin__c and Market_Data_Period_End__c field value
        
        //Query on project to get laterst record details
        List<Project__c> projects = [select Id, Market_Data_Period_Begin__c, Market_Data_Period_End__c from Project__c where Id = : project.Id];
        
        System.assertEquals(true, projects.size()>0);
        System.assertEquals(true, projects[0].Market_Data_Period_Begin__c == sIssue_2.Market_Data_Period_Begin__c);
        System.assertEquals(true, projects[0].Market_Data_Period_End__c == sIssue_2.Market_Data_Period_End__c);
    }
}