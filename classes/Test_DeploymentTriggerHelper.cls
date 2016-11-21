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
private class Test_DeploymentTriggerHelper {

    /**
    *  Purpose          :   Test class for DeploymentTriggerHelper class.
    * 
    *  Created By       :   Bhavi Sharma    
    * 
    *  Created Date     :   05/25/2013
    * 
    *  Current Version  :   V_1.0 - Created -   CR-20130328-2773
    *                       V_1.1 - Modified by - Abhinav Sharma -03/03/2014 - CR-20130829-3543 - Method added (test_populateFirstDeploymentSignedOff) - 97% coverage
    *                       V1.2 - Abhinav Sharma - 04/29/2014 - CR-20140403-4958 - Method Modified (test_populateFirstDeploymentSignedOff)
    *                       V1.3 - Abhinav Sharma - 05/02/2014 - CR-20140408-5000 - New method added (test_populateDeploymentDataOnProject)
    *                       V1.4 - Ajit Surana   - 08/18/2014 -  CR-20140507-5388 - Test class modified
    *                       V1.5 - Ajit Surana - 09/08/2014 - CR-20140716-6256 - test_populateFirstDeploymentSignedOff method is modified
    *                       V1.6 - Abhinav Sharma - 10/17/2014 - CR-20140826-7138 - New method added (test_populateDeploymentSignOffOldestOnProject)
    *                       V1.7 - Ajit Surana - 03/10/2015 - CR-20141218-8365 - New method added (testupdateCalculatedDateFields)
    *                       V1.8 - Abhinav Sharma - 10/20/2015 - CR-20150623-9023 - Modified existing method (testupdateCalculatedDateFields)  
    **/ 
    static testMethod void testrollupDeploymentDataOnProject() {
        
        //Bypassing all the triggers
        Util.byPassAllTriggers = true;
        
        //Getting Record Type Id Value for Deployment object
        ID deployRecordTypeId = [Select Id, Name FROM RecordType WHERE SobjectType = 'Deployment__c' and Name = 'CCC Deployment'].Id;
        
        //Getting Record Type Id Value for Project object
        ID projRecordTypeId = [Select Id, Name FROM RecordType WHERE SobjectType = 'Project__c' and RecordType.DeveloperName = 'CPM'].Id;
        
        //Project record
        Project__c project = new Project__c(Name = 'Test-Project',RecordTypeId = projRecordTypeId);
        insert project;
        
        //Deployment Type record
        Deployment_Type__c deployType = new Deployment_Type__c(Name = 'Test-Deploy-type', Sign_Off_to_Move_to_Prod_Lag__c = 10);
        insert deployType;
        
        //Deployment Type record
        Deployment_Type__c deployType1 = new Deployment_Type__c(Name = 'Test-Deploy-type', Sign_Off_to_Move_to_Prod_Lag__c = 4);
        insert deployType1;
        
        //Enabling triggers
        Util.byPassAllTriggers = false;
        
        //Deployment record
        Deployment__c deployment = new Deployment__c(Name = 'Test-Deploy1', Project__c = project.Id, RecordTypeId = deployRecordTypeId,
                                                      C_A_DC__c = Date.today().addDays(5),Deployment_Type__c = deployType.Id, C_E_DC__c = Date.today().addDays(-40),
                                                      Actual_Initial_Site_Demo__c = Date.today(), Use_Standard_Milestone_Goals__c = false);
        insert deployment;
        
        //Test starts here
        Test.startTest();
        
        //Deployment record
        deployment = [SELECT Id, Name, C_A_DC__c, Move_to_Production_Team_Expected__c FROM Deployment__c WHERE Id =: deployment.Id];
        
        //Project record
        project = [SELECT Id, Move_to_Production_Team_Expected__c, Final_Deployment_Sign_Off_Date__c FROM Project__c WHERE Id =: project.Id];
        
        //assert statements
        System.assertEquals(deployment.Move_to_Production_Team_Expected__c, project.Move_to_Production_Team_Expected__c);
        System.assertEquals(deployment.C_A_DC__c, project.Final_Deployment_Sign_Off_Date__c);
        
        //Deployment record
        Deployment__c deployment1 = new Deployment__c(Name = 'Test-Deploy2', Project__c = project.Id, RecordTypeId = deployRecordTypeId,
                                                      C_A_DC__c = Date.today().addDays(7),Deployment_Type__c = deployType.Id, C_E_DC__c = Date.today().addDays(8),
                                                      Actual_Initial_Site_Demo__c = Date.today(), Use_Standard_Milestone_Goals__c = false);
        
        //insert Deployment record
        insert deployment1;
        
        //Deployment record
        deployment1 = [SELECT Id, C_A_DC__c, Move_to_Production_Team_Expected__c FROM Deployment__c WHERE Id =: deployment1.Id];
        
        //Project record
        project = [SELECT Id, Move_to_Production_Team_Expected__c, Final_Deployment_Sign_Off_Date__c FROM Project__c WHERE Id =: project.Id];
        
        //assert statements
        System.assertEquals(deployment1.Move_to_Production_Team_Expected__c, project.Move_to_Production_Team_Expected__c);
        System.assertEquals(deployment1.C_A_DC__c, project.Final_Deployment_Sign_Off_Date__c);
        
        //update deployment record
        deployment1.C_A_DC__c = Date.today().addDays(-1);
        update deployment1;
        
        //Deployment record
        deployment = [SELECT Id, C_A_DC__c, Move_to_Production_Team_Expected__c FROM Deployment__c WHERE Id =: deployment.Id];
        
        //Project record
        project = [SELECT Id, Move_to_Production_Team_Expected__c, Final_Deployment_Sign_Off_Date__c FROM Project__c WHERE Id =: project.Id];
        
        //assert statements
        System.assertEquals(deployment.Move_to_Production_Team_Expected__c, project.Move_to_Production_Team_Expected__c);
        System.assertEquals(deployment.C_A_DC__c, project.Final_Deployment_Sign_Off_Date__c);
        
        //Deployment record
        Deployment__c deployment2 = new Deployment__c(Name = 'Test-Deploy3', Project__c = project.Id, RecordTypeId = deployRecordTypeId,
                                                      C_A_DC__c = Date.today().addDays(8),Deployment_Type__c = deployType1.Id,C_E_DC__c = Date.today().addDays(7),
                                                      Actual_Initial_Site_Demo__c = Date.today(), Use_Standard_Milestone_Goals__c = false);
        
        //insert Deployment 
        insert deployment2;
        
        //Deployment record
        deployment = [SELECT Id, C_A_DC__c, Move_to_Production_Team_Expected__c FROM Deployment__c WHERE Id =: deployment.Id];
        
        //Deployment record
        deployment2 = [SELECT Id, C_A_DC__c, Move_to_Production_Team_Expected__c FROM Deployment__c WHERE Id =: deployment2.Id];
        
        //Project record
        project = [SELECT Id, Move_to_Production_Team_Expected__c, 
                    Final_Deployment_Sign_Off_Date__c FROM Project__c WHERE Id =: project.Id];
        
        //assert statements
        System.assertEquals(deployment.Move_to_Production_Team_Expected__c, project.Move_to_Production_Team_Expected__c);
        System.assertEquals(deployment2.C_A_DC__c, project.Final_Deployment_Sign_Off_Date__c);
            
        //Stop Test here
        Test.stopTest();
    }
    
    static testMethod void test_updateDeploymentStatus_Green() {
        
        //Getting Record Type Id Value for Deployment object
        String Compass_Connect_RTID = Util.RecordTypeId('Deployment__c', Constants.RECORD_TYPE_DEPLOYMENT_COMPASS_CONNECT_DEPLOYMENT);
        
        //Getting Record Type Id Value for Project object
        ID projRecordTypeId = [Select Id, Name FROM RecordType WHERE SobjectType = 'Project__c' and RecordType.DeveloperName = 'CPM'].Id;
        
        //Project record
        Project__c project = new Project__c(Name = 'Test-Project',RecordTypeId = projRecordTypeId);
        insert project;
        
        //Deployment Type record
        Deployment_Type__c deployType = new Deployment_Type__c(Name = 'Test-Deploy-type', Sign_Off_to_Move_to_Prod_Lag__c = 10);
        insert deployType;
        
        //Deployment record
        Deployment__c deployment = new Deployment__c(Name = 'Test-Deploy1', Project__c = project.Id, RecordTypeId = Compass_Connect_RTID,
                                                      Deployment_Type__c = deployType.Id, Use_Standard_Milestone_Goals__c = false);
        // set expected dates
        deployment.C_E_TPC__c = system.today().addDays(-1);
        deployment.C_E_IDI__c = system.today().addDays(0);
        deployment.C_E_CDI__c = system.today().addDays(1);
        deployment.C_E_DDC__c = system.today().addDays(2);
        deployment.C_E_IDC__c = system.today().addDays(3);
        deployment.C_E_IVC__c = system.today().addDays(4);
        deployment.C_E_DC__c = system.today().addDays(5);
        deployment.Expected_Recurring_Update_Sign_Off2__c = system.today().addDays(6);
        
        // set actual date
        deployment.C_A_TPC__c = system.today().addDays(-2);
        
        insert deployment;
        
        // verify the deployment status
        List<Deployment__c> deployments = [SELECT Id, CPM_Deployment_Status__c FROM Deployment__c WHERE Id = :deployment.Id];
        system.assertEquals('Green', deployments[0].CPM_Deployment_Status__c);
        
        // update the Initial Data In Actual date
        deployment.C_A_IDI__c = system.today().addDays(-1);
        update deployment;
        
        // verify the deployment status
        deployments = [SELECT Id, CPM_Deployment_Status__c FROM Deployment__c WHERE Id = :deployment.Id];
        system.assertEquals('Green', deployments[0].CPM_Deployment_Status__c);
        
        // update the Complete Data In Actual date
        deployment.C_A_CDI__c = system.today().addDays(0);
        update deployment;
        
        // verify the deployment status
        deployments = [SELECT Id, CPM_Deployment_Status__c FROM Deployment__c WHERE Id = :deployment.Id];
        system.assertEquals('Green', deployments[0].CPM_Deployment_Status__c);
        
        // update the Complete Data In Actual date
        deployment.C_A_DDC__c = system.today().addDays(1);
        update deployment;
        
        // verify the deployment status
        deployments = [SELECT Id, CPM_Deployment_Status__c FROM Deployment__c WHERE Id = :deployment.Id];
        system.assertEquals('Green', deployments[0].CPM_Deployment_Status__c);
        
        // update the Complete Data In Actual date
        deployment.C_A_ISBC__c = system.today().addDays(2);
        update deployment;
        
        // verify the deployment status
        deployments = [SELECT Id, CPM_Deployment_Status__c FROM Deployment__c WHERE Id = :deployment.Id];
        system.assertEquals('Green', deployments[0].CPM_Deployment_Status__c);
        
        // update the Complete Data In Actual date
        deployment.C_A_IVC__c = system.today().addDays(3);
        update deployment;
        
        // verify the deployment status
        deployments = [SELECT Id, CPM_Deployment_Status__c FROM Deployment__c WHERE Id = :deployment.Id];
        system.assertEquals('Green', deployments[0].CPM_Deployment_Status__c);
        
        // update the Complete Data In Actual date
        deployment.C_A_DC__c = system.today().addDays(4);
        update deployment;
        
        // verify the deployment status
        deployments = [SELECT Id, CPM_Deployment_Status__c FROM Deployment__c WHERE Id = :deployment.Id];
        system.assertEquals('Green', deployments[0].CPM_Deployment_Status__c);
        
        // update the Complete Data In Actual date
        deployment.Actual_Recurring_Update_Sign_Off__c = system.today().addDays(5);
        update deployment;
        
        // verify the deployment status
        deployments = [SELECT Id, CPM_Deployment_Status__c FROM Deployment__c WHERE Id = :deployment.Id];
        system.assertEquals('Green', deployments[0].CPM_Deployment_Status__c);
        
    }
    
    static testMethod void test_updateDeploymentStatus_Yellow() {
        
        //Getting Record Type Id Value for Deployment object
        String Compass_Connect_RTID = Util.RecordTypeId('Deployment__c', Constants.RECORD_TYPE_DEPLOYMENT_COMPASS_CONNECT_DEPLOYMENT);
        
        //Getting Record Type Id Value for Project object
        ID projRecordTypeId = [Select Id, Name FROM RecordType WHERE SobjectType = 'Project__c' and RecordType.DeveloperName = 'CPM'].Id;
        
        //Project record
        Project__c project = new Project__c(Name = 'Test-Project',RecordTypeId = projRecordTypeId);
        insert project;
        
        //Deployment Type record
        Deployment_Type__c deployType = new Deployment_Type__c(Name = 'Test-Deploy-type', Sign_Off_to_Move_to_Prod_Lag__c = 10);
        insert deployType;
        
        //Deployment record
        Deployment__c deployment = new Deployment__c(Name = 'Test-Deploy1', Project__c = project.Id, RecordTypeId = Compass_Connect_RTID,
                                                      Deployment_Type__c = deployType.Id, Use_Standard_Milestone_Goals__c = false);
        
        deployment.C_E_TPC__c = system.today().addDays(-11);
        deployment.C_E_IDI__c = system.today().addDays(-8);
        // Technical Planning Completed 2 days late
        deployment.C_A_TPC__c = system.today().addDays(-10);
        
        insert deployment;
        
        // get the deployment record
        List<Deployment__c> deployments = [SELECT Id, CPM_Deployment_Status__c FROM Deployment__c WHERE Id = :deployment.Id];
        system.assertEquals(1, deployments.size());
        system.assertEquals('Red', deployments[0].CPM_Deployment_Status__c);
        
    }
    
    static testMethod void test_updateDeploymentStatus_Red() {
        
        //Getting Record Type Id Value for Deployment object
        String Compass_Connect_RTID = Util.RecordTypeId('Deployment__c', Constants.RECORD_TYPE_DEPLOYMENT_COMPASS_CONNECT_DEPLOYMENT);
        
        //Getting Record Type Id Value for Project object
        ID projRecordTypeId = [Select Id, Name FROM RecordType WHERE SobjectType = 'Project__c' and RecordType.DeveloperName = 'CPM'].Id;
        
        //Project record
        Project__c project = new Project__c(Name = 'Test-Project',RecordTypeId = projRecordTypeId);
        insert project;
        
        //Deployment Type record
        Deployment_Type__c deployType = new Deployment_Type__c(Name = 'Test-Deploy-type', Sign_Off_to_Move_to_Prod_Lag__c = 10);
        insert deployType;
        
        //Deployment record
        Deployment__c deployment = new Deployment__c(Name = 'Test-Deploy1', Project__c = project.Id, RecordTypeId = Compass_Connect_RTID,
                                                      Deployment_Type__c = deployType.Id, Use_Standard_Milestone_Goals__c = false);
        // Technical Planning Completed 2 days late
        deployment.C_E_TPC__c = system.today().addDays(-11);
        deployment.C_A_TPC__c = system.today().addDays(-10);
        // the next 2 expected dates have passed
        deployment.C_E_IDI__c = system.today().addDays(-8);
        deployment.C_E_CDI__c = system.today().addDays(-6);
        
        insert deployment;
        
        // get the deployment record
        List<Deployment__c> deployments = [SELECT Id, CPM_Deployment_Status__c FROM Deployment__c WHERE Id = :deployment.Id];
        system.assertEquals(1, deployments.size());
        system.assertEquals('Red', deployments[0].CPM_Deployment_Status__c);
        
    }
    
    // If the Actual date of most recent milestone missed the expected date 
    // AND the Actual date of the previous milestone passed the Expected date, status = Red
    static testMethod void test_updateDeploymentStatus_Red_2MissedDates() {
        
        //Getting Record Type Id Value for Deployment object
        String Compass_Connect_RTID = Util.RecordTypeId('Deployment__c', Constants.RECORD_TYPE_DEPLOYMENT_COMPASS_CONNECT_DEPLOYMENT);
        
        //Getting Record Type Id Value for Project object
        ID projRecordTypeId = [Select Id, Name FROM RecordType WHERE SobjectType = 'Project__c' and RecordType.DeveloperName = 'CPM'].Id;
        
        //Project record
        Project__c project = new Project__c(Name = 'Test-Project',RecordTypeId = projRecordTypeId);
        insert project;
        
        //Deployment Type record
        Deployment_Type__c deployType = new Deployment_Type__c(Name = 'Test-Deploy-type', Sign_Off_to_Move_to_Prod_Lag__c = 10);
        insert deployType;
        
        //Deployment record
        Deployment__c deployment = new Deployment__c(Name = 'Test-Deploy1', Project__c = project.Id, RecordTypeId = Compass_Connect_RTID,
                                                      Deployment_Type__c = deployType.Id, Use_Standard_Milestone_Goals__c = false);
        
        deployment.C_E_TPC__c = system.today().addDays(-3);
        deployment.C_E_IDI__c = system.today().addDays(-2);
        // Technical Planning AND Initial Data In are 1 day late
        deployment.C_A_TPC__c = system.today().addDays(-2);
        deployment.C_A_IDI__c = system.today().addDays(-1);
        
        insert deployment;
        
        // get the deployment record
        List<Deployment__c> deployments = [SELECT Id, CPM_Deployment_Status__c FROM Deployment__c WHERE Id = :deployment.Id];
        system.assertEquals(1, deployments.size());
        system.assertEquals('Red', deployments[0].CPM_Deployment_Status__c);
        
    }
    
    //Modified By - Ajit Surana - 09/08/2014 - CR-20140716-6256
    //Modified By - Abhinav Sharma - 04/29/2014 - CR-20140403-4958 - Site Live - Target, Actual - not completed with 3968
    //Testing if methiod is setting First_Deployment_Signed_Off__c field on the Project with the earliest value from the "Deployment Sign Off (Actual)" field
    //on the associated Deployment record correctly or not
    static testMethod void test_populateFirstDeploymentSignedOff() {
    
        //Getting Record Type Id Value for Deployment object
        String Compass_Connect_RTID = Util.RecordTypeId('Deployment__c', Constants.RECORD_TYPE_DEPLOYMENT_COMPASS_CONNECT_DEPLOYMENT);
        
        //Getting Record Type Id Value for Project object
        ID cpmProjRecordTypeId = [Select Id, Name FROM RecordType WHERE SobjectType = 'Project__c' and RecordType.DeveloperName = 'CPM'].Id;
        
        //Getting Record Type Id Value for Project object
        ID sscProjRecordTypeId = [Select Id, Name FROM RecordType WHERE SobjectType = 'Project__c' and RecordType.DeveloperName = 'SSC'].Id;
        
        //List to hold project records
        List<Project__c> projects = new List<Project__c>();
        
        //create new Project__c data
        Project__c project_1 = new Project__c(Name = 'Test-Data1', RecordTypeId = cpmProjRecordTypeId );
        Project__c project_2 = new Project__c(Name = 'Test-Data2', RecordTypeId = cpmProjRecordTypeId );
        Project__c project_3 = new project__c(Name = 'Test-Data3', RecordTypeId = cpmProjRecordTypeId );
        Project__c project_4 = new project__c(Name = 'Test-Data4', RecordTypeId = cpmProjRecordTypeId );
        Project__c project_5 = new Project__c(Name = 'Test-Data5', RecordTypeId = sscProjRecordTypeId );
        Project__c project_6 = new Project__c(Name = 'Test-Data6', RecordTypeId = sscProjRecordTypeId );
        
        //Adding project records into the list
        projects.add(project_1);    
        projects.add(project_2);
        projects.add(project_3);
        projects.add(project_4);
        projects.add(project_5);
        projects.add(project_6);
        
        //Bypass all other triggers
        Util.IsTest(true);
        Util.BypassAllTriggers = true;
        
        //Make a try to insert the record
        insert projects;
        
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
        
        Deployment__c deployment_8 = new Deployment__c(Name = 'Test-Deploy8', Project__c = projects[4].Id, RecordTypeId = Compass_Connect_RTID,
                                                      Deployment_Type__c = deployType.Id, Use_Standard_Milestone_Goals__c = false,
                                                      C_A_DC__c = System.today().addDays(-4));
        
        Deployment__c deployment_9 = new Deployment__c(Name = 'Test-Deploy9', Project__c = projects[5].Id, RecordTypeId = Compass_Connect_RTID,
                                                      Deployment_Type__c = deployType.Id, Use_Standard_Milestone_Goals__c = false,
                                                      C_A_DC__c = System.today().addDays(-4));
        
        
        //populating list with the records
        deployments.add(deployment_1);  deployments.add(deployment_2); deployments.add(deployment_3);   
        deployments.add(deployment_4); deployments.add(deployment_5); deployments.add(deployment_6);
        deployments.add(deployment_7); deployments.add(deployment_8); deployments.add(deployment_9);   
        
        //Test start from here
        Test.startTest();
        
        //Setting flag value so then triggers can be execute again
        Util.BypassAllTriggers = false;
        
        //Make a try to insert the deployment records
        insert deployments;
        
        //Retrieving updated project record details
        projects = [SELECT Id, First_Deployment_Signed_Off__c, Date_Site_Live__c, Site_Live_Target__c FROM Project__c LIMIT 6];
        
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
        
        //Added By - Ajit Surana - 09/08/2014 - CR-20140716-6256
        System.assertEquals(System.today().addDays(-4), projects[4].Date_Site_Live__c);
        System.assertEquals(System.today().addDays(-4), projects[5].Date_Site_Live__c);
        
        //Updating deployment records
        deployments[1].C_A_DC__c = System.today().addDays(-1);
        deployments[2].C_A_DC__c = null;
        deployments[5].C_A_DC__c = System.today().addDays(-1);
        deployments[6].C_E_DC__c = System.today().addDays(-2);
        deployments[6].Use_Standard_Milestone_Goals__c = false;
        update deployments; 
        
        //Retrieving updated project record details
        projects = [SELECT Id, First_Deployment_Signed_Off__c, Date_Site_Live__c, Site_Live_Target__c FROM Project__c LIMIT 6];
        
        //Assert for results
        //Assert for results
        System.assertEquals(6, projects.size());
        System.assertEquals(System.today().addDays(-2), projects[0].First_Deployment_Signed_Off__c);
        System.assertEquals(System.today().addDays(-2), projects[0].Date_Site_Live__c);
        System.assertEquals(System.today().addDays(-3), projects[0].Site_Live_Target__c);
        System.assertEquals(null, projects[1].First_Deployment_Signed_Off__c);
        System.assertEquals(null, projects[1].Date_Site_Live__c);
        System.assertEquals(System.today().addDays(-2), projects[1].Site_Live_Target__c);
        System.assertEquals(System.today().addDays(-1), projects[2].First_Deployment_Signed_Off__c);
        System.assertEquals(System.today().addDays(-1), projects[2].Date_Site_Live__c);
        System.assertEquals(System.today().addDays(-3), projects[2].Site_Live_Target__c);
        System.assertEquals(null, projects[3].First_Deployment_Signed_Off__c);
        System.assertEquals(null, projects[3].Date_Site_Live__c);
        System.assertEquals(System.today().addDays(-2), projects[3].Site_Live_Target__c);
        
        //Set to hold the Ids
        Set<Id> setIds = new Set<Id>();
        
        for(Integer i=0; i<2; i++)
            setIds.add(deployments[i].Id);     
            
        //Deleting deployment records
        delete [SELECT Id FROM Deployment__c WHERE ID IN : setIDs];
        
        //Assert for results
        projects = [SELECT Id, First_Deployment_Signed_Off__c, Date_Site_Live__c, Site_Live_Target__c FROM Project__c WHERE ID =: projects[0].Id];
        
        //Assert for results
        System.assertEquals(null, projects[0].First_Deployment_Signed_Off__c);
        System.assertEquals(null, projects[0].Date_Site_Live__c);
        System.assertEquals(null, projects[0].Site_Live_Target__c);
       
        //Stop Test Here
        Test.stopTest();                             
    }
    
    //Added by Abhinav Sharma - - 05/02/2014 - CR-20140408-5000
    static testMethod void test_populateDeploymentDataOnProject() {
        
        //Getting "SSM" Record Type Id Value for Project object
        ID projRecordTypeId = [Select Id, Name FROM RecordType WHERE SobjectType = 'Project__c' and Name = 'SSM'].Id;
        
        //Getting "SSM" Record Type Id Value for Deployment object
        ID ssmDeployRecordTypeId = [Select Id, Name FROM RecordType WHERE SobjectType = 'Deployment__c' and Name = 'SSM Deployment'].Id;
        
        //Getting "CCC" Record Type Id Value for Deployment object
        ID cccDeployRecordTypeId = [Select Id, Name FROM RecordType WHERE SobjectType = 'Deployment__c' and Name = 'CCC Deployment'].Id;
        
        //List to hold test Project records
        List<Project__c> listProject = new List<Project__c>();
        
        listProject.add(new Project__c(Name = 'Test-Project1',RecordTypeId = projRecordTypeId));
        listProject.add(new Project__c(Name = 'Test-Project2',RecordTypeId = projRecordTypeId));
        
        //Insert records into List
        insert listProject;
        
        //Deployment Type record
        Deployment_Type__c deployType = new Deployment_Type__c(Name = 'Test-Deploy-type', Sign_Off_to_Move_to_Prod_Lag__c = 10);
        insert deployType;
        
        //List to hold test Deployment records
        List<Deployment__c> listDeployment = new List<Deployment__c>();
        
        listDeployment.add(new Deployment__c(Name = 'Test-Deploy1', Project__c = listProject[0].Id, RecordTypeId = ssmDeployRecordTypeId,
                                             Contingent_Revenue_Invoiced__c = 100, Deployment_Type__c = deployType.Id, Total_Actual_Revenue_to_Date__c = 200,
                                             Actual_Market_Basket_Size__c = 10, Use_Standard_Milestone_Goals__c = true));
                                             
        listDeployment.add(new Deployment__c(Name = 'Test-Deploy2', Project__c = listProject[0].Id, RecordTypeId = ssmDeployRecordTypeId,
                                             Contingent_Revenue_Invoiced__c = 200, Deployment_Type__c = deployType.Id, Total_Actual_Revenue_to_Date__c = 100,
                                             Actual_Market_Basket_Size__c = 40, Use_Standard_Milestone_Goals__c = true));
        
        listDeployment.add(new Deployment__c(Name = 'Test-Deploy3', Project__c = listProject[1].Id, RecordTypeId = cccDeployRecordTypeId,
                                             Contingent_Revenue_Invoiced__c = 200, Deployment_Type__c = deployType.Id, Total_Actual_Revenue_to_Date__c = 100,
                                             Actual_Market_Basket_Size__c = 40, Use_Standard_Milestone_Goals__c = true, C_A_DS__c = Date.today().addDays(8)));
        
        listDeployment.add(new Deployment__c(Name = 'Test-Deploy4', Project__c = listProject[1].Id, RecordTypeId = ssmDeployRecordTypeId,
                                             Contingent_Revenue_Invoiced__c = 50, Deployment_Type__c = deployType.Id, Total_Actual_Revenue_to_Date__c = 20,
                                             Actual_Market_Basket_Size__c = 30, Use_Standard_Milestone_Goals__c = true));
                                             
        listDeployment.add(new Deployment__c(Name = 'Test-Deploy5', Project__c = listProject[1].Id, RecordTypeId = ssmDeployRecordTypeId,
                                             Contingent_Revenue_Invoiced__c = 60, Deployment_Type__c = deployType.Id, Total_Actual_Revenue_to_Date__c = 125,
                                             Actual_Market_Basket_Size__c = 15, Use_Standard_Milestone_Goals__c = true));
        
        //Test starts here
        Test.startTest();
        
        //Insert test records into List                                     
        insert listDeployment;
                                             
        //Retreive all required fields needed for assert
        List<Project__c> projectList = [SELECT Id, Actual_Risk_Payment_w_Sign_Off__c, Total_Actual_Revenue_to_Date__c, Minimum_Market_Basket_Size__c FROM Project__c WHERE Id =: listProject[0].Id];
        
        //Assert for reults  
        System.assertEquals(300, projectList[0].Actual_Risk_Payment_w_Sign_Off__c);
        System.assertEquals(300, projectList[0].Total_Actual_Revenue_to_Date__c);
        System.assertEquals(50, projectList[0].Minimum_Market_Basket_Size__c);
        
        //Retreive all required fields needed for assert
        projectList = [SELECT Id, Actual_Risk_Payment_w_Sign_Off__c, Total_Actual_Revenue_to_Date__c, Minimum_Market_Basket_Size__c FROM Project__c WHERE Id =: listProject[1].Id];
        
        //Assert for reults
        System.assertEquals(110, projectList[0].Actual_Risk_Payment_w_Sign_Off__c);
        System.assertEquals(145, projectList[0].Total_Actual_Revenue_to_Date__c);
        System.assertEquals(45, projectList[0].Minimum_Market_Basket_Size__c);
        
        //Update first and last Deployment record "Project" field
        listDeployment[0].Project__c = listProject[1].Id;
        listDeployment[4].Project__c = listProject[0].Id;
        
        update listDeployment;
        
        //Retreive all required fields needed for assert
        projectList = [SELECT Id, Actual_Risk_Payment_w_Sign_Off__c, Total_Actual_Revenue_to_Date__c, Minimum_Market_Basket_Size__c FROM Project__c WHERE Id =: listProject[0].Id];
        
        //Assert for reults
        System.assertEquals(260, projectList[0].Actual_Risk_Payment_w_Sign_Off__c);
        System.assertEquals(225, projectList[0].Total_Actual_Revenue_to_Date__c);
        System.assertEquals(55, projectList[0].Minimum_Market_Basket_Size__c);
        
        //Retreive all required fields needed for assert
        projectList = [SELECT Id, Actual_Risk_Payment_w_Sign_Off__c, Total_Actual_Revenue_to_Date__c, Minimum_Market_Basket_Size__c FROM Project__c WHERE Id =: listProject[1].Id];
        
        //Assert for reults
        System.assertEquals(150, projectList[0].Actual_Risk_Payment_w_Sign_Off__c);
        System.assertEquals(220, projectList[0].Total_Actual_Revenue_to_Date__c);
        System.assertEquals(40, projectList[0].Minimum_Market_Basket_Size__c);
        
        //Update Contingent_Revenue_Invoiced__c, Total_Actual_Revenue_to_Date__c, Actual_Market_Basket_Size__c values on Deployment record
        listDeployment[0].Contingent_Revenue_Invoiced__c = 90;
        listDeployment[0].Total_Actual_Revenue_to_Date__c = 60;
        listDeployment[0].Actual_Market_Basket_Size__c = 30;
        
        listDeployment[4].Contingent_Revenue_Invoiced__c = 80;
        listDeployment[4].Total_Actual_Revenue_to_Date__c = 60;
        listDeployment[4].Actual_Market_Basket_Size__c = 25;
        
        update listDeployment;
        
        //Retreive all required fields needed for assert
        projectList = [SELECT Id, Actual_Risk_Payment_w_Sign_Off__c, Total_Actual_Revenue_to_Date__c, Minimum_Market_Basket_Size__c FROM Project__c WHERE Id =: listProject[0].Id];
        
        //Assert for reults
        System.assertEquals(280, projectList[0].Actual_Risk_Payment_w_Sign_Off__c);
        System.assertEquals(160, projectList[0].Total_Actual_Revenue_to_Date__c);
        System.assertEquals(65, projectList[0].Minimum_Market_Basket_Size__c);
        
        //Delete deployment record
        delete listDeployment[1];
        delete listDeployment[2];
        delete listDeployment[3];
        
        //Retreive all required fields needed for assert
        projectList = [SELECT Id, Actual_Risk_Payment_w_Sign_Off__c, Total_Actual_Revenue_to_Date__c, Minimum_Market_Basket_Size__c FROM Project__c WHERE Id =: listProject[0].Id];
        
        //Assert for reults
        System.assertEquals(80, projectList[0].Actual_Risk_Payment_w_Sign_Off__c);
        System.assertEquals(60, projectList[0].Total_Actual_Revenue_to_Date__c);
        System.assertEquals(25, projectList[0].Minimum_Market_Basket_Size__c);
        
        //Retreive all required fields needed for assert
        projectList = [SELECT Id, Actual_Risk_Payment_w_Sign_Off__c, Total_Actual_Revenue_to_Date__c, Minimum_Market_Basket_Size__c FROM Project__c WHERE Id =: listProject[1].Id];
        
        //Assert for reults
        System.assertEquals(90, projectList[0].Actual_Risk_Payment_w_Sign_Off__c);
        System.assertEquals(60, projectList[0].Total_Actual_Revenue_to_Date__c);
        System.assertEquals(30, projectList[0].Minimum_Market_Basket_Size__c);
        
        //Delete deployment record
        delete listDeployment[0];
        delete listDeployment[4];
        
        //Retreive all required fields needed for assert
        projectList = [SELECT Id, Actual_Risk_Payment_w_Sign_Off__c, Total_Actual_Revenue_to_Date__c, Minimum_Market_Basket_Size__c FROM Project__c WHERE Id =: listProject[0].Id];
        
        //Assert for reults
        System.assertEquals(0, projectList[0].Actual_Risk_Payment_w_Sign_Off__c);
        System.assertEquals(0, projectList[0].Total_Actual_Revenue_to_Date__c);
        System.assertEquals(0, projectList[0].Minimum_Market_Basket_Size__c);
        
        //Retreive all required fields needed for assert
        projectList = [SELECT Id, Actual_Risk_Payment_w_Sign_Off__c, Total_Actual_Revenue_to_Date__c, Minimum_Market_Basket_Size__c FROM Project__c WHERE Id =: listProject[1].Id];
        
        //Assert for reults
        System.assertEquals(0, projectList[0].Actual_Risk_Payment_w_Sign_Off__c);
        System.assertEquals(0, projectList[0].Total_Actual_Revenue_to_Date__c);
        System.assertEquals(0, projectList[0].Minimum_Market_Basket_Size__c);
        
        //Stop Test here
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
        
        //Update first and last Deployment record "Project" field
        listDeployment[1].Project__c = listProject[1].Id;
        update listDeployment[1];
        
        listDeployment[2].Project__c = listProject[0].Id;
        update listDeployment[2];
        
        //Retreive all required fields needed for assert
        projectList = [SELECT Id, Deployment_Sign_Off_Oldest__c FROM Project__c WHERE Id =: listProject ORDER BY Name];
        
        //Assert for reults  
        System.assertEquals(Date.today().addMonths(-3), projectList[1].Deployment_Sign_Off_Oldest__c);
        System.assertEquals(Date.today().addMonths(-4), projectList[0].Deployment_Sign_Off_Oldest__c);
        System.assertEquals(null, projectList[2].Deployment_Sign_Off_Oldest__c);
        
        delete listDeployment[1];
        delete listDeployment[2];
        
        //Retreive all required fields needed for assert
        projectList = [SELECT Id, Deployment_Sign_Off_Oldest__c FROM Project__c WHERE Id =: listProject ORDER BY Name];
        
        //Assert for reults  
        System.assertEquals(Date.today().addMonths(1), projectList[1].Deployment_Sign_Off_Oldest__c);
        System.assertEquals(Date.today(), projectList[0].Deployment_Sign_Off_Oldest__c);
        System.assertEquals(null, projectList[2].Deployment_Sign_Off_Oldest__c);
               
        //Stop Test here
        Test.stopTest();
    }

    //Modified by - Abhinav Sharma - 10/20/2015 - CR-20150623-9023 
    //Test method added - Abhinav Surana - 03/10/2015 - CR-20141218-8365
    static testMethod void testupdateCalculatedDateFields() {
        
        //Bypass Dupeblocker
        Util.IsTest(true);
        
        //Bypassing Triggers so then test data can be created easily
        Util.byPassAllTriggers = true;
    
        //Getting Record Type for Project object
        List<RecordType> projectRecordTypes = [Select Id, DeveloperName FROM RecordType WHERE SobjectType = 'Project__c' 
                                                AND DeveloperName = 'CCA' 
                                                AND IsActive = true];
        
        //assert statement
        System.assertEquals(1, projectRecordTypes.size());
        
        //List to hold test Project records
        List<Project__c> listProject = new List<Project__c>();
        listProject.add(new Project__c(Name = 'Test-Project1',RecordTypeId = projectRecordTypes[0].Id));
        insert listProject;
        
        //Deployment Type record
        Deployment_Type__c deployType = new Deployment_Type__c(Name = 'Test-Deploy-type');
        insert deployType;
        
        //Record types list
        List<RecordType> rdTypes = [Select Id, DeveloperName FROM RecordType 
                                            WHERE SobjectType = 'Deployment__c'
                                            AND IsActive = true
                                            AND DeveloperName IN ('CPRM_Deployment', 'Data_Hub_Deployment')
                                            ORDER By DeveloperName ASC];
        
        //List to hold test Deployment records
        List<Deployment__c> listDeployment = new List<Deployment__c>();
        listDeployment.add(new Deployment__c(Name = 'Test-Deploy1', Project__c = listProject[0].Id, RecordTypeId = rdTypes[0].Id,
                                             Deployment_Type__c = deployType.Id, Use_Standard_Milestone_Goals__c = true, C_A_DS__c = Date.today(),
                                             Welcome_Call_Expected__c = date.today().addDays(2)));
        listDeployment.add(new Deployment__c(Name = 'Test-Deploy2', Project__c = listProject[0].Id, RecordTypeId = rdTypes[1].Id,
                                             Deployment_Type__c = deployType.Id, Use_Standard_Milestone_Goals__c = true, C_A_DS__c = Date.today(),
                                             Welcome_Call_Expected__c = date.today(), Compass_Connect__c = true));
        
        //Test starts here
        Test.startTest();
        
        //Enabling triggers again
        Util.byPassAllTriggers = false;
        
        //Insert test records into List                                     
        insert listDeployment;
        
        //Query the data to get correct asserts
        listDeployment = [SELECT Id, Template_Sent_Expected__c, C_E_TPC__c, Redlining_Complete_Expected__c, Legal_Complete_Expected__c,
                          C_E_IDI__c, Feedback_on_Initial_Data_Expected__c, C_E_CDI__c, C_E_DDC__c, Data_Sent_to_Vendor_Expected__c,
                          DAS_Received_Expected__c, DAS_Approved_Expected__c, C_E_ISBC__c, C_E_IVC__c, UAT_Diagnostics_Call_Expected__c,
                          UAT_Onsite_Expected__c, C_E_DC__c, Expected_Recurring_Update_Sign_Off2__c, 
                          Welcome_Call_Expected__c, Data_Acquisition_Call_Expected__c, Feed_Transport_setup_complete_Expected__c,
                          Receive_Test_Data_Expected__c, Extract_data_in_ECDM_Expected__c, Transform_data_ECDM_to_ICDM_Exp__c,
                          ICDM_sample_data_diagnostics_Expected__c, ICDM_sample_data_diagnostic_resolved_Exp__c,
                          Historical_Data_Received_Expected__c, ICDM_historical_data_diagnostics_Exp__c, ICDM_historical_data_diags_resolved_Exp__c,
                          Enrichment_service_setup_complete_Exp__c, Enrichment_service_diagnostics_Exp__c, Enrichment_service_diags_resolved_Exp__c,
                          Data_Handoff_to_Product_Expected__c, Recurring_Update_Sign_Off_Expected__c 
                          FROM Deployment__c ORDER BY Welcome_Call_Expected__c DESC];
        
        //Assert for the correct results                  
        System.assertEquals(2, listDeployment.size());
        System.assertEquals(Date.today().addDays(2), listDeployment[0].Template_Sent_Expected__c);
        System.assertEquals(Date.today().addDays(14), listDeployment[0].C_E_TPC__c);
        System.assertEquals(Date.today().addDays(23), listDeployment[0].Redlining_Complete_Expected__c);
        System.assertEquals(Date.today().addDays(44), listDeployment[0].Legal_Complete_Expected__c);
        System.assertEquals(Date.today().addDays(46), listDeployment[0].C_E_IDI__c);
        System.assertEquals(Date.today().addDays(60), listDeployment[0].Feedback_on_Initial_Data_Expected__c);
        System.assertEquals(Date.today().addDays(67), listDeployment[0].C_E_CDI__c);
        System.assertEquals(Date.today().addDays(81), listDeployment[0].C_E_DDC__c);
        System.assertEquals(Date.today().addDays(88), listDeployment[0].Data_Sent_to_Vendor_Expected__c);
        System.assertEquals(Date.today().addDays(103), listDeployment[0].DAS_Received_Expected__c);
        System.assertEquals(Date.today().addDays(105), listDeployment[0].DAS_Approved_Expected__c);
        System.assertEquals(Date.today().addDays(121), listDeployment[0].C_E_ISBC__c);
        System.assertEquals(Date.today().addDays(123), listDeployment[0].C_E_IVC__c);
        System.assertEquals(Date.today().addDays(128), listDeployment[0].UAT_Diagnostics_Call_Expected__c);
        System.assertEquals(Date.today().addDays(130), listDeployment[0].UAT_Onsite_Expected__c);
        System.assertEquals(Date.today().addDays(160), listDeployment[0].C_E_DC__c);
        System.assertEquals(Date.today().addDays(160), listDeployment[0].Expected_Recurring_Update_Sign_Off2__c);
                
        System.assertEquals(Date.today(), listDeployment[1].Welcome_Call_Expected__c);
        System.assertEquals(Date.today().addDays(5), listDeployment[1].Data_Acquisition_Call_Expected__c);
        System.assertEquals(Date.today().addDays(10), listDeployment[1].Feed_Transport_setup_complete_Expected__c);
        System.assertEquals(Date.today().addDays(13), listDeployment[1].Receive_Test_Data_Expected__c);
        System.assertEquals(Date.today().addDays(18), listDeployment[1].Extract_data_in_ECDM_Expected__c);
        System.assertEquals(Date.today().addDays(21), listDeployment[1].Transform_data_ECDM_to_ICDM_Exp__c);
        System.assertEquals(Date.today().addDays(23), listDeployment[1].ICDM_sample_data_diagnostics_Expected__c);
        System.assertEquals(Date.today().addDays(28), listDeployment[1].ICDM_sample_data_diagnostic_resolved_Exp__c);
        System.assertEquals(Date.today().addDays(31), listDeployment[1].Historical_Data_Received_Expected__c);
        System.assertEquals(Date.today().addDays(32), listDeployment[1].ICDM_historical_data_diagnostics_Exp__c);
        System.assertEquals(Date.today().addDays(40), listDeployment[1].ICDM_historical_data_diags_resolved_Exp__c);
        System.assertEquals(Date.today().addDays(42), listDeployment[1].Enrichment_service_setup_complete_Exp__c);
        System.assertEquals(Date.today().addDays(43), listDeployment[1].Enrichment_service_diagnostics_Exp__c);
        System.assertEquals(Date.today().addDays(48), listDeployment[1].Enrichment_service_diags_resolved_Exp__c);
        System.assertEquals(Date.today().addDays(49), listDeployment[1].Data_Handoff_to_Product_Expected__c);
        System.assertEquals(Date.today().addDays(54), listDeployment[1].C_E_IVC__c);
        System.assertEquals(Date.today().addDays(69), listDeployment[1].Recurring_Update_Sign_Off_Expected__c);
        
        //Test stop here
        Test.stopTest();
    }
}