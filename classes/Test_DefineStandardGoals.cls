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
private class Test_DefineStandardGoals {
  /**
    *   Purpose         :   Test class for DefineStandardGoals Page.
    *            
    *   Create By       :   Padmesh Soni
    *
    *   Created Date    :   08/22/2015  
    *
    *   Revision Log    :   V_1.0 - Created - CR-20150729-9114 
    *                       V_1.2 - Modified - Subhash Garhwal - 11/25/2015
    *                       V_1.3 - Modified - Rajeev Jain - 02/29/2016 - CR-20160125-9561 - ISSP Deployment D
    *                       V_1.4 - Modified - Rajeev Jain - 05/13/2016 - ISSP Deployment E - Additional code coverage and imroved asserts
    *   Coverage        :   V_1.0 - 88%
    **/
    
    
    //Test methods for addNewCondition method
    static testMethod void myUnitTest() {
        
        //Create an institution  
        Account account = TestUtilities.CreateNewAccount(false);
        
        //Insert
        insert account;
        
        //Create a Contact
        Contact contact = new Contact(FirstName = 'Test', LastName = 'Contact', Email = 'test@test.com', AccountId = account.Id, 
                                      Employee_User_Record__c = Userinfo.getUserId());
        
        //Insert
        insert contact;
    
        //Create team role
        List<Team_Role__c> teamRoles = new List<Team_Role__c>();
        
        //Add Team Role in list
        teamRoles.add(new Team_Role__c(Name = 'Test1',Active__c = true));
        teamRoles.add(new Team_Role__c(Name = 'Test2',Active__c = true));
        teamRoles.add(new Team_Role__c(Name = 'Test3',Active__c = true));
        teamRoles.add(new Team_Role__c(Name = 'Test4',Active__c = true));
        
        //Insert
        insert teamRoles;
        
        //Create value type
        List<Value_Type__c> valueTypes =  new List<Value_Type__c>();
        
        //Add value type in list
        valueTypes.add(new Value_Type__c(Name = 'Test1', Values_Permitted__c = 'Date', Category__c ='Business Title', Active__c = true));
        valueTypes.add(new Value_Type__c(Name = 'Test2', Values_Permitted__c = 'Date', Category__c ='Business Title', Active__c = true));
        valueTypes.add(new Value_Type__c(Name = 'Test3', Values_Permitted__c = 'Date', Category__c ='Business Title', Active__c = true));
        valueTypes.add(new Value_Type__c(Name = 'Test3', Values_Permitted__c = 'Date', Category__c ='Credit Type', Active__c = true));
        
        //Insert
        insert valueTypes;
    
        //Create Goal Types
        List<Goal_Type__c> goalTypes = new List<Goal_Type__c>();
        
        //Add new goal type in list
        goalTypes.add(new Goal_Type__c(Name = 'TG1', Active__c = true, Base_Process__c = 'NBB', Description__c = 'T', Standard_Goal__c = true));
        goalTypes.add(new Goal_Type__c(Name = 'TestGoalType2', Active__c = true, Base_Process__c = 'CM', Description__c = 'Testing of Goal Types', Standard_Goal__c = false));
        goalTypes.add(new Goal_Type__c(Name = 'TestGoalType3', Active__c = false, Base_Process__c = 'Activity', Description__c = 'Testing of Goal', Standard_Goal__c = false));
        goalTypes.add(new Goal_Type__c(Name = 'TestGoalType4', Active__c = true, Base_Process__c = 'Renewal', Description__c = 'Goal Type3', Standard_Goal__c = false));
        goalTypes.add(new Goal_Type__c(Name = 'TestGoalType5', Active__c = true, Base_Process__c = 'Renewal', Description__c = 'Goal Type4', Standard_Goal__c = false));
        goalTypes.add(new Goal_Type__c(Name = 'TestGoalType6', Active__c = true, Base_Process__c = 'Renewal', Description__c = 'Goal Type5', Standard_Goal__c = false));
        goalTypes.add(new Goal_Type__c(Name = 'TestGoalType7', Active__c = true, Base_Process__c = 'Renewal', Description__c = 'Goal Type6', Standard_Goal__c = false));
        goalTypes.add(new Goal_Type__c(Name = 'TestGoalType8', Active__c = true, Base_Process__c = 'Renewal', Description__c = 'Goal Type7', Standard_Goal__c = false));
        goalTypes.add(new Goal_Type__c(Name = 'TestGoalType9', Active__c = true, Base_Process__c = 'Renewal', Description__c = 'Goal Type8', Standard_Goal__c = false));
        
        //Insert 
        insert goalTypes;  
        
        //Create Perspective 
        List<Perspective__c> perspectives = new List<Perspective__c>();
        
        //Add new recrods in list 
        perspectives.add(new Perspective__c(Name = 'Perspective 1'));
        perspectives.add(new Perspective__c(Name = 'Perspective 2'));
        
        //Insert
        insert perspectives;
        
        //Create Program Collection
        List<Program_Group__c> programCollections = new List<Program_Group__c>();
        
        //Add new recrods in list 
        programCollections.add(new Program_Group__c(Name = 'PC 1'));
        programCollections.add(new Program_Group__c(Name = 'PC 2'));
        
        //Insert
        insert programCollections;
        
        // Create program Perspective
        List<Program_Perspective__c> programPerspectives = new List<Program_Perspective__c>();
        
        //Add new recrods in list 
        programPerspectives.add(new Program_Perspective__c(Name = 'pp1' , Active__c = true,Perspective__c = perspectives[0].Id, Program_Group__c = programCollections[0].Id ));
        programPerspectives.add(new Program_Perspective__c(Name = 'pp2' , Active__c = true,Perspective__c = perspectives[1].Id, Program_Group__c = programCollections[1].Id));
        
        //Insert
        insert programPerspectives;
        
        //Create Program
        List<Program__c> programs = new  List<Program__c>();
        
        //Add new Programs in list
        programs.add(new Program__c(Name = 'Test Program 1', Status__c = 'Active'));
        programs.add(new Program__c(Name = 'Test Program 2', Status__c = 'Active'));
        programs.add(new Program__c(Name = 'Test Program 3', Status__c = 'Active'));
        
        //Insert
        insert programs;
        
        //Create Relationship type
        List<Relationship_Type__c> relationShips = new  List<Relationship_Type__c>();
        
        //Add new Programs in lists
        relationShips.add(new Relationship_Type__c(Name = 'Test Relationship1', Business_Owner__c = contact.Id, Name_When_From__c ='TestForm',
                                                      Name_When_To__c = 'TestTo', Active__c = true));
        relationShips.add(new Relationship_Type__c(Name = 'Relationship2', Business_Owner__c = contact.Id, Name_When_From__c ='TestForm1',
                                                     Name_When_To__c = 'TestTo1', Active__c = true));
        
        //Insert
        insert relationShips;
        
        //Create custom Setting Incentive Defaults
        List<Incentive_Defaults__c> incetiveDefaults = new List<Incentive_Defaults__c>();
        
        //Add new Incentive Defaults
        incetiveDefaults.add(new Incentive_Defaults__c(Name = 'TH1', Amount__c = 100 , Category__c = 'Periods', Description__c = 'Semi-annual', Count__c = 1, End__c = System.today().addDays(15),
                                                       Start__c = System.today(), Percent__c = 50));
        incetiveDefaults.add(new Incentive_Defaults__c(Name = 'TH2', Amount__c = 100 , Category__c = 'Periods', Description__c = 'Semi-annual', Count__c = 2, End__c = System.today().addDays(30),
                                                       Start__c = System.today().addDays(16), Percent__c = 50));
        incetiveDefaults.add(new Incentive_Defaults__c(Name = 'TQ1', Amount__c = 20 , Category__c = 'Periods', Description__c = 'Quarters', Count__c = 3, End__c = System.today().addDays(8),
                                                       Start__c = System.today(), Percent__c = 25));
        incetiveDefaults.add(new Incentive_Defaults__c(Name = 'TQ2', Amount__c = 20 , Category__c = 'Periods', Description__c = 'Quarters', Count__c = 4, End__c = System.today().addDays(16),
                                                       Start__c = System.today().addDays(9), Percent__c = 25));
        incetiveDefaults.add(new Incentive_Defaults__c(Name = 'TQ3', Amount__c = 20 , Category__c = 'Periods', Description__c = 'Quarters', Count__c = 5, End__c = System.today().addDays(24),
                                                       Start__c = System.today().addDays(17), Percent__c = 25));
        incetiveDefaults.add(new Incentive_Defaults__c(Name = 'TQ4', Amount__c = 20 , Category__c = 'Periods', Description__c = 'Quarters', Count__c = 6, End__c = System.today().addDays(32),
                                                       Start__c = System.today().addDays(25), Percent__c = 25));
        incetiveDefaults.add(new Incentive_Defaults__c(Name = 'TQ5', Amount__c = 20 , Category__c = 'NonPer', Description__c = 'Quarters', Count__c = 6, End__c = System.today().addDays(40),
                                                       Start__c = System.today().addDays(33), Percent__c = 25));
        
        //Insert 
        insert incetiveDefaults;
                
        //Create Standard Goal Instance
        Standard_Goal__c standardGoals = new Standard_Goal__c();
        
        //Standard controller       
        ApexPages.StandardController sc = new ApexPages.standardController(standardGoals);

        //Start Testing from here
        Test.startTest();  
        
        //Instance of controller
        DefineStandardGoalsController controller = new DefineStandardGoalsController(sc);
        
        //Instance of StdGoalSectionWrapper class
        StdGoalSectionWrapper sGSWrapper = new StdGoalSectionWrapper();
          
        //Loop through condition record type
        List<RecordType> rType = [Select Id, Name, DeveloperName From RecordType Where SObjectType = 'Condition__c' ORDER BY DeveloperName ASC];
        
        //Assign values to Satndard Goal fields
        controller.stdGoal.Description__c = 'Teting';
        controller.stdGoal.Amount__c = 100;
        controller.stdGoal.Period_Start__c = System.today().addDays(-100);
        controller.stdGoal.Period_End__c = System.today().addDays(100);
        controller.stdGoal.Business_Owner__c = contact.Id;
        controller.stdGoal.Goal_Type__c = goalTypes[0].Id;
        
        //Select record type for condition Activity date
        controller.stdGSWrapper.selectedRType = rType[0].Id;
        
        //Assign Values according to record type for new condition
        controller.stdGSWrapper.condition.Start_Date__c = System.today();
        controller.stdGSWrapper.condition.End_Date__c = System.today().addDays(4);
        controller.stdGSWrapper.condition.Date_Type__c = 'Close';
        controller.stdGSWrapper.condition.Condition_Type__c = 'Include';
        
        //Calling the method of controller
        controller.doCancel();
        
        //Select record type for condition Activity date
        controller.stdGSWrapper.selectedRType = rType[0].Id;
        
        //Assign Values according to record type for new condition
        controller.stdGSWrapper.condition.Start_Date__c = System.today();
        controller.stdGSWrapper.condition.End_Date__c = System.today().addDays(4);
        controller.stdGSWrapper.condition.Date_Type__c = 'Close';
        controller.stdGSWrapper.condition.Condition_Type__c = 'Include';
        
        //Calling the method of controller
        controller.addNewCondition();
        
        //Assert for results
        System.assertEquals(1, controller.stdGSWrapper.conditionsWrapper.size());
        System.assertEquals('Activity Date', controller.stdGSWrapper.conditionsWrapper[0].rtype);
        System.assert(controller.stdGSWrapper.conditionsWrapper[0].value.contains('Close'));
        
        //Select record type for condition Asignment Role
        controller.stdGSWrapper.selectedRType = rType[1].Id;
        
        //Assign Values according to record type for new condition
        controller.stdGSWrapper.condition.Assignment_Role__c = teamRoles[0].Id;
        controller.stdGSWrapper.condition.Condition_Type__c = 'Include';
        
        //Calling the method of controller  
        controller.addNewCondition();
        
        //Assert for results
        System.assertEquals(2, controller.stdGSWrapper.conditionsWrapper.size());
        System.assertEquals('Assignment Role', controller.stdGSWrapper.conditionsWrapper[1].rtype);
        System.assert(controller.stdGSWrapper.conditionsWrapper[1].value.contains(teamRoles[0].Name));
        
        //Select record type for condition Collection Perspective
        controller.stdGSWrapper.selectedRType = rType[2].Id;
        
        //Assign Values according to record type for new condition
        controller.stdGSWrapper.condition.Collection_Perspective__c = programPerspectives[0].Id;
        controller.stdGSWrapper.condition.Condition_Type__c = 'Include';
        
        //Calling the method of controller
        controller.addNewCondition();
        
        //Assert for results
        System.assertEquals(3, controller.stdGSWrapper.conditionsWrapper.size());
        System.assertEquals('Assignment Role', controller.stdGSWrapper.conditionsWrapper[2].rtype);
        
        //Select record type for condition Institution
        controller.stdGSWrapper.selectedRType = rType[4].Id;
        
        //Assign Values according to record type for new condition
        controller.stdGSWrapper.condition.Institution__c = account.Id;
        controller.stdGSWrapper.condition.Condition_Type__c = 'Include';
    
        //Calling the method of controller
        controller.addNewCondition();
        
        //Assert for results
        System.assertEquals(4, controller.stdGSWrapper.conditionsWrapper.size());
        System.assertEquals('Institution', controller.stdGSWrapper.conditionsWrapper[3].rtype);
        
        //Select record type for condition Relationship
        controller.stdGSWrapper.selectedRType = rType[5].Id;
        
        //Assign Values according to record type for new condition
        controller.stdGSWrapper.condition.To_Relationship__c = relationShips[1].Id;
        controller.stdGSWrapper.condition.From_Relationship__c = null;
        controller.stdGSWrapper.condition.Condition_Type__c = 'Include';
        
        //Calling the method of controller
        controller.addNewCondition();
        
        //Assert for results
        System.assertEquals(5, controller.stdGSWrapper.conditionsWrapper.size());
        System.assertEquals('Institution', controller.stdGSWrapper.conditionsWrapper[4].rtype);
        
        //Select record type for condition Relationship
        controller.stdGSWrapper.selectedRType = rType[5].Id;
        
        //Assign Values according to record type for new condition
        controller.stdGSWrapper.condition.To_Relationship__c = relationShips[1].Id;
        controller.stdGSWrapper.condition.Condition_Type__c = 'Include';
    
        //Calling the method of controller
        controller.addNewCondition();
        
        //Assert for results
        System.assertEquals(6, controller.stdGSWrapper.conditionsWrapper.size());
        System.assertEquals('Institution', controller.stdGSWrapper.conditionsWrapper[5].rtype);
    
        //Select record type Renewal Type for condition
        controller.stdGSWrapper.selectedRType = rType[6].Id;
        
        //Assign Values according to record type for new condition
        controller.stdGSWrapper.condition.Agreement_Type__c = relationShips[0].Id;
        controller.stdGSWrapper.condition.Condition_Type__c = 'Include';
        
        //Calling the method of controller
        controller.addNewCondition();
        
        //Assert for results
        System.assertEquals(7, controller.stdGSWrapper.conditionsWrapper.size());
        System.assertEquals('Institution', controller.stdGSWrapper.conditionsWrapper[6].rtype);
        
        //Select record type for condition Collection Perspective
        controller.stdGSWrapper.selectedRType = rType[2].Id;
        
        //Assign Values according to record type for new condition
        controller.stdGSWrapper.condition.Condition_Type__c = 'Include';
        controller.stdGSWrapper.condition.Individual_Program__c = programs[0].Id;
        
        //Calling the method of controller
        controller.addNewCondition();
        
        //Assert for results
        System.assertEquals(8, controller.stdGSWrapper.conditionsWrapper.size());
        System.assertEquals('Institution', controller.stdGSWrapper.conditionsWrapper[7].rtype);
        
        //Check condition check box for first records
        controller.stdGSWrapper.selectedConditionRowIndex = '1';
        
        //Calling do edit method
        controller.doEditContiditon();
        controller.stdGSWrapper.selectedRType = rType[6].Id;
        
        //Assign Values according to record type for new condition
        controller.stdGSWrapper.condition.Agreement_Type__c = relationShips[0].Id;
        controller.stdGSWrapper.condition.Condition_Type__c = 'Exclude';
        
        //Calling the method of controller
        controller.addNewCondition();
        
        //Assert for results
        System.assertEquals(8, controller.stdGSWrapper.conditionsWrapper.size());
        
        //Check condition check box for first records
        controller.stdGSWrapper.selectedConditionRowIndex = '7';
        controller.stdGSWrapper.conditionsWrapper[6].selected = true;
        
        //Calling the remove condition method
        controller.removeCondition();
        
        //Assert for results
        System.assertEquals(7, controller.stdGSWrapper.conditionsWrapper.size());
        
        //----------Add sales Role Method----------
        //Add Business Title or sales role 
        controller.stdGSR.Sales_Role__c = valueTypes[0].Id;
        
        //Calling the method of controller
        controller.addSalesRole(); 
        
        //Assert for results
        System.assertEquals(1, controller.stdGSWrapper.stdGSRs.size());
        
        //Add sales role 
        controller.stdGSR.Sales_Role__c = valueTypes[1].Id;
        
        //Calling the method of controller   
        controller.addSalesRole();
        
        //Assert for results
        System.assertEquals(2, controller.stdGSWrapper.stdGSRs.size());
        
        //Check condition check box for first records
        controller.stdGSWrapper.selectedSalesRoleRowIndex = '1';
        
        //Calling the method of controller to edit sales role
        controller.doEditSalesRole();
        
        //Assign Standard goal value
        controller.stdGSR.Sales_Role__c = valueTypes[0].Id;
        
        //Calling the method of controller
        controller.addSalesRole();
        
        //Assert for results
        System.assertEquals(2, controller.stdGSWrapper.stdGSRs.size());
        
        //Set Check box true 
        controller.stdGSWrapper.stdGSRs[0].selected = true;
        
        //Calling the method of controller
        controller.removeSalesRole();
        
        //Assert for results
        System.assertEquals(1, controller.stdGSWrapper.stdGSRs.size());
        
        //---------Add Standard Goal Detail-------------
        //Add fields
        controller.stdGDWrapper.stdGD.Goal_Type__c = goalTypes[2].Id;
        controller.stdGDWrapper.stdGD.Description__c = 'Goal Type 2';
        controller.stdGDWrapper.stdGD.Target_Type__c = 'Paced';
        controller.stdGDWrapper.stdGD.GT_Basline__c = 'Template';
        controller.stdGDWrapper.stdGD.Period_Start__c = System.today().addDays(-90);
        controller.stdGDWrapper.stdGD.Period_End__c = System.today().addDays(90);
        
        //Calling controller method
        controller.addStdGoalDetail();
        
        //Assert for results
        System.assertEquals(1, controller.stdGDWrapper.stdGoalDetailsWrapper.size());
        
        //Add Field
        controller.stdGDWrapper.stdGD.Goal_Type__c = goalTypes[1].Id;
        controller.stdGDWrapper.stdGD.Description__c = 'Goal Type 1';
        //controller.stdGDWrapper.stdGD.Target_Type__c = 'Paced';
        controller.stdGDWrapper.stdGD.GT_Basline__c = 'Template';
        controller.stdGDWrapper.stdGD.Period_Start__c = System.today().addDays(-90);
        controller.stdGDWrapper.stdGD.Period_End__c = System.today().addDays(90);
        
        //Calling controller method
        controller.addStdGoalDetail();
        
        //Assert for results
        System.assertEquals(2, controller.stdGDWrapper.stdGoalDetailsWrapper.size());
        
        //Add Field
        controller.stdGDWrapper.stdGD.Goal_Type__c = goalTypes[3].Id;
        controller.stdGDWrapper.stdGD.Description__c = 'Goal Type 3';
        //controller.stdGDWrapper.stdGD.Target_Type__c = 'Paced';
        controller.stdGDWrapper.stdGD.GT_Basline__c = 'Template';
        controller.stdGDWrapper.stdGD.Period_Start__c = System.today().addDays(-90);
        controller.stdGDWrapper.stdGD.Period_End__c = System.today().addDays(90);
        
        //Calling controller method
        controller.addStdGoalDetail();
        
        //Assert for results
        System.assertEquals(3, controller.stdGDWrapper.stdGoalDetailsWrapper.size());
        
        //Add fields
        controller.stdGDWrapper.stdGD.Goal_Type__c = goalTypes[7].Id;
        controller.stdGDWrapper.stdGD.Description__c = 'Goal Type 7';
        //controller.stdGDWrapper.stdGD.Target_Type__c = 'Paced';
        controller.stdGDWrapper.stdGD.GT_Basline__c = 'Template';
        controller.stdGDWrapper.stdGD.Period_Start__c = System.today().addDays(-90);
        controller.stdGDWrapper.stdGD.Period_End__c = System.today().addDays(90);
        
        //Calling controller method
        controller.addStdGoalDetail();
        
        //Assert for results
        System.assertEquals(4, controller.stdGDWrapper.stdGoalDetailsWrapper.size());
        
        //Set row index
        controller.stdGDWrapper.selectedSGDRowIndex = '3';      
        
        //Calling the method of controller
        controller.doEditstdGoalDetail();
        
        //Set goal type  
        controller.stdGDWrapper.stdGD.Goal_Type__c = goalTypes[4].Id;
        controller.stdGDWrapper.stdGD.Description__c ='EditGoalType';
        //controller.stdGDWrapper.stdGD.Target_Type__c = 'Paced';
        controller.stdGDWrapper.stdGD.GT_Basline__c = 'Template';
        controller.stdGDWrapper.stdGD.Period_Start__c = System.today().addDays(-90);
        controller.stdGDWrapper.stdGD.Period_End__c = System.today().addDays(90);
        
        //Calling controller method
        controller.addStdGoalDetail();
         
        //Assert for results
        System.assertEquals(4, controller.stdGDWrapper.stdGoalDetailsWrapper.size());
        
        //Add fields
        controller.stdGDWrapper.stdGD.Goal_Type__c = goalTypes[4].Id;
        controller.stdGDWrapper.stdGD.Description__c = 'Goal Type 4';
        //controller.stdGDWrapper.stdGD.Target_Type__c = 'Paced';
        controller.stdGDWrapper.stdGD.GT_Basline__c = 'Template';
        controller.stdGDWrapper.stdGD.Period_Start__c = System.today().addDays(-90);
        controller.stdGDWrapper.stdGD.Period_End__c = System.today().addDays(90);
        
        //Calling controller method
        controller.addStdGoalDetail();
        
        //Assert for results
        System.assertEquals(5, controller.stdGDWrapper.stdGoalDetailsWrapper.size());
        
        //---------Removing Satndard Goal Details--------------
        //Set row index
        controller.stdGDWrapper.stdGoalDetailsWrapper[2].selected = true;       
        controller.stdGDWrapper.stdGoalDetailsWrapper[3].selected = true;       
        controller.stdGDWrapper.stdGoalDetailsWrapper[4].selected = true;       
        
        //Call remove method from controller
        controller.removeStdGoalDetail();
        
        //Assert for results
        System.assertEquals(2, controller.stdGDWrapper.stdGoalDetailsWrapper.size());
            
        //Call Method
        PageReference pR = controller.doSave();
        
        //Assert for result 

        System.assert(pR.getUrl().contains('/'+controller.stdGoal.Id));
        
        //Query on Condition
        List<Condition__c> conditionsFetch = [Select Id from Condition__c];
        
        //Query on Standard goal
        List<Standard_Goal__c> standardGoalFetch = [Select Id from Standard_Goal__c];
        
        //Query on Standard goal sales role
        List<Standard_Goal_Sales_Role__c> sGSRoleFetch = [Select Id from Standard_Goal_Sales_Role__c];
         
        //Query on Standard goal detail
        List<Standard_Goal_Detail__c> sGDetailFetch = [Select Id from Standard_Goal_Detail__c];
        
        
        //Assert for results
        //System.assertEquals(7, conditionsFetch.size());
        System.assertEquals(2, sGDetailFetch.size()); 
        //System.assertEquals(6, sGDPacingFetch.size());
        System.assertEquals(1, sGSRoleFetch.size());
        System.assertEquals(1, standardGoalFetch.size());
       
        //Standard controller       
        sc = new ApexPages.standardController(standardGoalFetch[0]);
        
        //Instance of controller
        controller = new DefineStandardGoalsController(sc);
        
        //Assert For Result
        System.assertEquals(2, controller.stdGDWrapper.stdGoalDetailsWrapper.size());
        System.assertEquals(1, controller.stdGSWrapper.stdGSRs.size());
        System.assertEquals(7, controller.stdGSWrapper.conditionsWrapper.size());
         
        //Stop test here
        Test.stopTest();
    
    }
    
    
    //Test methods for addNewCondition method
    static testMethod void myUnitTest2() {
        
        //Create Account
        Account account = TestUtilities.CreateNewAccount(false);
        
        //Insert
        insert account;
        
        //Create a Contact
        Contact contact = new Contact(FirstName = 'Test', LastName = 'Contact', Email = 'test@test.com', AccountId = account.Id, 
                                      Employee_User_Record__c = Userinfo.getUserId());
        
        //Insert
        insert contact;
    
        //Create Goal Types
        List<Goal_Type__c> goalTypes = new List<Goal_Type__c>();
        
        //Add new goal type in list
        goalTypes.add(new Goal_Type__c(Name = 'TG1', Active__c = true, Base_Process__c = 'NBB', Description__c = 'Goal Type 0', Standard_Goal__c = true));
        goalTypes.add(new Goal_Type__c(Name = 'TestGoalType2', Active__c = true, Base_Process__c = 'CM', Description__c = 'Goal Type1', Standard_Goal__c = false));
        goalTypes.add(new Goal_Type__c(Name = 'TestGoalType3', Active__c = false, Base_Process__c = 'Activity', Description__c = 'Goal Type2', Standard_Goal__c = false));
        goalTypes.add(new Goal_Type__c(Name = 'TestGoalType4', Active__c = true, Base_Process__c = 'CM', Description__c = 'Goal Type3', Standard_Goal__c = false));
        goalTypes.add(new Goal_Type__c(Name = 'TestGoalType5', Active__c = true, Base_Process__c = 'Renewal', Description__c = 'Goal Type4', Standard_Goal__c = false));
        goalTypes.add(new Goal_Type__c(Name = 'TestGoalType6', Active__c = true, Base_Process__c = 'Renewal', Description__c = 'Goal Type5', Standard_Goal__c = false));
        goalTypes.add(new Goal_Type__c(Name = 'TestGoalType7', Active__c = true, Base_Process__c = 'Renewal', Description__c = 'Goal Type6', Standard_Goal__c = false));
        goalTypes.add(new Goal_Type__c(Name = 'TestGoalType8', Active__c = true, Base_Process__c = 'Renewal', Description__c = 'Goal Type7', Standard_Goal__c = false));
        goalTypes.add(new Goal_Type__c(Name = 'TestGoalType9', Active__c = true, Base_Process__c = 'Renewal', Description__c = 'Goal Type8', Standard_Goal__c = false));
        
        //Insert 
        insert goalTypes;  
        
        //Create Relationship type
        List<Relationship_Type__c> relationShips = new  List<Relationship_Type__c>();
        
        //Add new Programs in lists
        relationShips.add(new Relationship_Type__c(Name = 'Test Relationship1', Business_Owner__c = contact.Id, Name_When_From__c ='TestForm',
                                                      Name_When_To__c = 'TestTo', Active__c = true));
        relationShips.add(new Relationship_Type__c(Name = 'Relationship2', Business_Owner__c = contact.Id, Name_When_From__c ='TestForm1',
                                                     Name_When_To__c = 'TestTo1', Active__c = true));
        
        //Insert
        insert relationShips;
        
        //Create custom Setting Incentive Defaults
        List<Incentive_Defaults__c> incetiveDefaults = new List<Incentive_Defaults__c>();
        
        //Add new Incentive Defaults
        incetiveDefaults.add(new Incentive_Defaults__c(Name = 'TH1', Amount__c = 100 , Category__c = 'Periods', Description__c = 'Semi-annual', Count__c = 1, End__c = System.today().addDays(15),
                                                       Start__c = System.today(), Percent__c = 50));
        incetiveDefaults.add(new Incentive_Defaults__c(Name = 'TH2', Amount__c = 100 , Category__c = 'Periods', Description__c = 'Semi-annual', Count__c = 2, End__c = System.today().addDays(30),
                                                       Start__c = System.today().addDays(16), Percent__c = 50));
        
        //Insert 
        insert incetiveDefaults;
        
        //Standard controller       
        ApexPages.StandardController sc = new ApexPages.standardController(new Standard_Goal__c());

        //Loop through condition record type
        List<RecordType> rType = [Select Id, Name, DeveloperName From RecordType Where SObjectType = 'Condition__c' ORDER BY DeveloperName ASC];
        
        //Test Start here
        Test.startTest();
        
        //Instance of controller
        DefineStandardGoalsController controller = new DefineStandardGoalsController(sc);
    
        //Instance of StdGoalSectionWrapper class
        StdGoalSectionWrapper sGSWrapper = new StdGoalSectionWrapper();
        
        //Assign values to Satndard Goal fields
        controller.stdGoal.Description__c = 'GT Testing 1';
        controller.stdGoal.Amount__c = 100000;
        controller.stdGoal.Period_Start__c = System.today().addDays(-100);
        controller.stdGoal.Period_End__c = System.today().addDays(100);
        controller.stdGoal.Business_Owner__c = contact.Id;
        controller.stdGoal.Goal_Type__c = goalTypes[0].Id;
        controller.stdGSWrapper.selectedRType = rType[5].Id;
        
        
        //Assign Values according to record type for new condition
        controller.stdGSWrapper.condition.To_Relationship__c = relationShips[1].Id;
        controller.stdGSWrapper.condition.Condition_Type__c = 'Include';
    
        //Calling the method of controller
        controller.addNewCondition();  
        
        //Assert for results
        System.assertEquals(1, controller.stdGSWrapper.conditionsWrapper.size());
        System.assertEquals('Relationship', controller.stdGSWrapper.conditionsWrapper[0].rtype);
            
        //Add Standard Goal Detail 1
        controller.stdGDWrapper.stdGD.Goal_Type__c = goalTypes[1].Id;
        controller.stdGDWrapper.stdGD.Description__c ='GTDTest1';
        controller.stdGDWrapper.selectedBaseLine = 'Template';
        controller.stdGDWrapper.stdGD.Period_Start__c = System.today().addDays(-90);
        controller.stdGDWrapper.stdGD.Period_End__c = System.today().addDays(90);
        
        //Calling controller method
        controller.addStdGoalDetail();

        //Assert for results
        System.assertEquals(1, controller.stdGDWrapper.stdGoalDetailsWrapper.size());
        
        //Call Method
        PageReference pR = controller.doSaveAndCPGS();
        
        //Assert for result
        System.assert(pR.getUrl().contains('/apex/CreatePersonalGoalsFromStdGoal?id='+controller.stdGoal.Id));
        
        //Query on Standard goal
        List<Standard_Goal__c> standardGoalFetch = [Select Id from Standard_Goal__c];
        
        //Query on Standard goal detail
        List<Standard_Goal_Detail__c> sGDetailFetch = [Select Id, Description__c from Standard_Goal_Detail__c];
        
      
        //Assert for results
        //System.assertEquals(1, standardGoalFetch.size()); 
        System.assertEquals(1, sGDetailFetch.size());
        System.assertEquals('GTDTest1', sGDetailFetch[0].Description__c);       
        
        /*------ EDIT Record  -------- */
        
        //Standard controller       
        sc = new ApexPages.standardController(standardGoalFetch[0]);
        
        //Instance of controller
        controller = new DefineStandardGoalsController(sc);
        
        //Assert For Result
        System.assertEquals(1, controller.stdGDWrapper.stdGoalDetailsWrapper.size());
        
        //Add Standard Goal Detail 2
        controller.stdGDWrapper.stdGD.Goal_Type__c = goalTypes[1].Id;
        controller.stdGDWrapper.stdGD.Description__c ='GTDTest2';
        controller.stdGDWrapper.selectedBaseLine = 'Template';
        controller.stdGDWrapper.stdGD.Amount__c = 20000;
        controller.stdGDWrapper.stdGD.Period_Start__c = System.today().addDays(-90);
        controller.stdGDWrapper.stdGD.Period_End__c = System.today().addDays(90);
        
        
        //Call Method
        controller.addStdGoalDetail();
        
        //Assert for results
        System.assertEquals(2, controller.stdGDWrapper.stdGoalDetailsWrapper.size());
        
        //Add Standard Goal Detail 3
        controller.stdGDWrapper.stdGD.Goal_Type__c = goalTypes[1].Id;
        controller.stdGDWrapper.stdGD.Description__c ='GTDTest3';
        controller.stdGDWrapper.stdGD.Discount__c = 50;
        controller.stdGDWrapper.selectedBaseLine = 'Template';
        controller.stdGDWrapper.stdGD.Amount__c = 20000;
        
        //Calling the method of controller  
        controller.populateGTDetailFields();
        controller.populatePeriods();  
        controller.addStdGoalDetail();
        
        //Assert for result
        System.assertEquals(100000,controller.stdGDWrapper.stdGoalDetailsWrapper[0].stdGDetail.Amount__c);
        
        //Set row index SGD 3
        controller.stdGDWrapper.stdGoalDetailsWrapper[2].selected = true;
        controller.removeStdGoalDetail();
        
        //Add Standard Goal Detail 3
        controller.stdGDWrapper.stdGD.Goal_Type__c = goalTypes[1].Id;
        controller.stdGDWrapper.stdGD.Description__c ='GTDTest3';
        controller.stdGDWrapper.stdGD.Discount__c = 50;
        controller.stdGDWrapper.selectedBaseLine = 'Template';
        controller.stdGDWrapper.stdGD.Amount__c = 20000;
        controller.stdGDWrapper.stdGD.Period_Start__c = System.today().addDays(-90);
        controller.stdGDWrapper.stdGD.Period_End__c = System.today().addDays(90);
        
        
        //Add Pacing using Period Field 3
        controller.stdGDWrapper.stdGD.Period__c = incetiveDefaults[0].Name;
        
        //Calling the method of controller  
        controller.populatePeriods();
        controller.addStdGoalDetail();
        
        //Assert For Result
        System.assertEquals(3, controller.stdGDWrapper.stdGoalDetailsWrapper.size());
        
        //Edit 2 GDT
        //Set row index
        controller.stdGDWrapper.selectedSGDRowIndex = '2';
        
        //Call Method
        controller.doEditstdGoalDetail();
        
        //Set Value
        controller.stdGDWrapper.stdGD.Goal_Type__c = goalTypes[3].Id;
        controller.stdGDWrapper.stdGD.Description__c ='GTDTest223';
        controller.stdGDWrapper.stdGD.Discount__c = 20;
        controller.stdGDWrapper.selectedBaseLine = 'Template';
        controller.stdGDWrapper.stdGDetailsWrapper.selectedParent = controller.stdGDWrapper.stdGDetailsWrapper.availableParents[1].getValue();
        controller.stdGDWrapper.stdGD.Amount__c = 20000;
        controller.stdGDWrapper.stdGD.Period_Start__c = System.today().addDays(-90);
        controller.stdGDWrapper.stdGD.Period_End__c = System.today().addDays(90);
        
        
        //Call Method
        controller.addStdGoalDetail();
        
        //Assert For Result
        System.assertEquals(3, controller.stdGDWrapper.stdGoalDetailsWrapper.size());
        
        //Set Value
        controller.stdGoal.Amount__c = 500000;
        
        //Select row
        controller.stdGDWrapper.stdGoalDetailsWrapper[0].selected = true;       
        controller.stdGDWrapper.stdGoalDetailsWrapper[1].selected = true;       
        controller.stdGDWrapper.stdGoalDetailsWrapper[2].selected = true;
        
        //Call Method
        controller.doCalculate();
        
        //Assert For Result
        System.assertEquals(400000, controller.stdGDWrapper.stdGoalDetailsWrapper[0].stdGDetail.Amount__c);
        System.assertEquals(400000, controller.stdGDWrapper.stdGoalDetailsWrapper[1].stdGDetail.Amount__c);
        System.assertEquals(250000, controller.stdGDWrapper.stdGoalDetailsWrapper[2].stdGDetail.Amount__c);
       
        //Select row
        controller.stdGDWrapper.stdGoalDetailsWrapper[0].selected = true;       
        controller.stdGDWrapper.stdGoalDetailsWrapper[1].selected = true;       
        controller.stdGDWrapper.stdGoalDetailsWrapper[2].selected = true;
        
        //Call Method  
        controller.cloneGoalTemplateDetails();
        
        //Assert For Result
        System.assertEquals(6, controller.stdGDWrapper.stdGoalDetailsWrapper.size());
        
        //Select Row Index
        controller.stdGDWrapper.stdGoalDetailsWrapper[0].selected = true;       
        controller.stdGDWrapper.stdGoalDetailsWrapper[2].selected = true;       
        controller.stdGDWrapper.stdGoalDetailsWrapper[3].selected = true;
        controller.stdGDWrapper.stdGoalDetailsWrapper[5].selected = true;
        
        //Call remove method from controller
        controller.removeStdGoalDetail();
        
        //Assert For Result
        System.assertEquals(2, controller.stdGDWrapper.stdGoalDetailsWrapper.size());
        
        //Add Standard Goal Detail 4
        controller.stdGDWrapper.stdGD.Goal_Type__c = goalTypes[1].Id;
        controller.stdGDWrapper.stdGD.Description__c ='GTDTest4';
        controller.stdGDWrapper.selectedBaseLine = 'Template';
        controller.stdGDWrapper.stdGD.Amount__c = 20000;
        
        //Call Method
        controller.addStdGoalDetail();
        
        //Assert for results
        System.assertEquals(3, controller.stdGDWrapper.stdGoalDetailsWrapper.size());
        System.assertEquals(400000, controller.stdGDWrapper.stdGoalDetailsWrapper[0].stdGDetail.Amount__c);
        System.assertEquals(400000, controller.stdGDWrapper.stdGoalDetailsWrapper[1].stdGDetail.Amount__c);
        System.assertEquals(500000, controller.stdGDWrapper.stdGoalDetailsWrapper[2].stdGDetail.Amount__c);
        
        //Call Method
        pR = controller.doSaveAndCPGS();
        
        
        //Assert Foe Result
        //System.assert(pR.getUrl().contains('/apex/CreatePersonalGoalsFromStdGoal?id='+controller.stdGoal.Id));
        
        /* Edit Goal Template For Counter */
    
        //Standard controller       
        sc = new ApexPages.standardController(standardGoalFetch[0]);
        
        //Instance of controller
        controller = new DefineStandardGoalsController(sc);
        
        //Assert For Result
        System.assertEquals(1, controller.stdGDWrapper.stdGoalDetailsWrapper.size());
        
        //Set Count in Goal Template
        controller.stdGoal.Description__c = 'Edit Goal Template';
        controller.stdGoal.Counter__c = 400000;
        controller.stdGoal.Amount__c = null;
        
        
        //Edit 1 GDT
        //Set row index
        controller.stdGDWrapper.selectedSGDRowIndex = '1';
        
        //Call Method
        controller.doEditstdGoalDetail();
        
        //Set Counter Goal Template Detail
        controller.stdGDWrapper.stdGD.Count__c = 20000;
        controller.stdGDWrapper.stdGD.Discount__c = 50;
        controller.stdGDWrapper.stdGD.Period_Start__c = System.today().addDays(-90);
        controller.stdGDWrapper.stdGD.Period_End__c = System.today().addDays(90);
        
        
        //Call Method
        controller.addStdGoalDetail();
        
        //Edit 2 GDT
        //Set row index
        controller.stdGDWrapper.selectedSGDRowIndex = '2';
        
        //Call Method
        controller.doEditstdGoalDetail();
        
        //Set Counter Goal Template Detail
        controller.stdGDWrapper.stdGD.Count__c = 20000;
        controller.stdGDWrapper.stdGD.Discount__c = 50;
        controller.stdGDWrapper.stdGD.Period_Start__c = System.today().addDays(-90);
        controller.stdGDWrapper.stdGD.Period_End__c = System.today().addDays(90);
        
        
        //Call Method
        controller.addStdGoalDetail();
        
        //Edit 3 GDT
        //Set row index
        controller.stdGDWrapper.selectedSGDRowIndex = '3';
        
        //Call Method
        controller.doEditstdGoalDetail();
        
        //Set Counter Goal Template Detail
        controller.stdGDWrapper.stdGD.Count__c = 20000;
        controller.stdGDWrapper.stdGD.Discount__c = 50;
        
        //Call Method
        controller.addStdGoalDetail();
        
        //Select row
        controller.stdGDWrapper.stdGoalDetailsWrapper[0].selected = true;       
        
        //Call Method
        controller.doCalculate();  
        
        //Assert For Result
        System.assertEquals(1, controller.stdGDWrapper.stdGoalDetailsWrapper.size());
        System.assertEquals(200000, controller.stdGDWrapper.stdGoalDetailsWrapper[0].stdGDetail.Count__c);
        
        //Edit 3 GDT
        //Set row index
        controller.stdGDWrapper.selectedSGDRowIndex = '3';
        
        //Call Method
        controller.doEditstdGoalDetail();
        
        //Set Sums To
        controller.stdGDWrapper.stdGDetailsWrapper.selectedParent = controller.stdGDWrapper.stdGDetailsWrapper.availableParents[1].getValue();
        
        //Call Method
        controller.addStdGoalDetail();
        
        //Set row index
        controller.stdGDWrapper.selectedSGDRowIndex = '2';
        
        //Call Method
        controller.doEditstdGoalDetail();
        
        //Set Sums To
        controller.stdGDWrapper.stdGDetailsWrapper.selectedParent = controller.stdGDWrapper.stdGDetailsWrapper.availableParents[1].getValue();
        
        //Call Method
        controller.addStdGoalDetail();
        
        //Select Row
        controller.stdGDWrapper.stdGoalDetailsWrapper[0].selected = true;       
       
        //Call Method
        controller.doCalculate();
        
        //Assert For Result
        System.assertEquals(200000, controller.stdGDWrapper.stdGoalDetailsWrapper[0].stdGDetail.Count__c);
       
        //Edit 3 GDT   
        //Set row index
        controller.stdGDWrapper.selectedSGDRowIndex = '1';
        
        //Call Method
        controller.doEditstdGoalDetail();
        
        //Create Pacing 
        controller.stdGDWrapper.stdGD.Period__c = incetiveDefaults[0].Name;
        
        //Calling the method of controller  
        controller.populatePeriods();
        controller.addStdGoalDetail();
        
        //Set row index
        controller.stdGDWrapper.selectedSGDRowIndex = '2';
        
        //Call Method
        controller.doEditstdGoalDetail();
        
        //Create Pacing 
        controller.stdGDWrapper.stdGD.Period__c = incetiveDefaults[0].Name;
        
        //Calling the method of controller  
        controller.populatePeriods();
        controller.addStdGoalDetail();
        
        //Call Method
        pR = controller.doSaveAndCPGS();
        
        //Assert For Result
        System.assert(pR.getUrl().contains('/apex/CreatePersonalGoalsFromStdGoal?id='+controller.stdGoal.Id));
        
        /* Edit For Parcent */ 
              
        //Standard controller       
        sc = new ApexPages.standardController(standardGoalFetch[0]);
        
        //Instance of controller
        controller = new DefineStandardGoalsController(sc);
        
        //Assert For Result
        System.assertEquals(1, controller.stdGDWrapper.stdGoalDetailsWrapper.size());
        
        //Set Count in Goal Template
        controller.stdGoal.Percent__c = 100;
        controller.stdGoal.Counter__c = null;
        controller.stdGoal.Amount__c = null;
        
        //Edit 1 GDT
        //Set row index
        controller.stdGDWrapper.selectedSGDRowIndex = '1';
        
        //Call Method
        controller.doEditstdGoalDetail();
        
        //Set Counter Goal Template Detail
        controller.stdGDWrapper.stdGD.Percent__c = 50;
        
        //Call Method
        controller.addStdGoalDetail();
        
        //Edit 2 GDT
        //Set row index
        controller.stdGDWrapper.selectedSGDRowIndex = '2';
        
        //Call Method
        controller.doEditstdGoalDetail();
        
        //Set Counter Goal Template Detail
        controller.stdGDWrapper.stdGD.Percent__c = 50;
        
        //Call Method
        controller.addStdGoalDetail();
        
        //Edit 3 GDT
        //Set row index
        controller.stdGDWrapper.selectedSGDRowIndex = '3';
        
        //Call Method
        controller.doEditstdGoalDetail();
        
        //Set Counter Goal Template Detail  
        controller.stdGDWrapper.stdGD.Percent__c = 50;
        
        //Call Method
        controller.addStdGoalDetail();
        
        //Select Row
        controller.stdGDWrapper.stdGoalDetailsWrapper[0].selected = true;       
       
        //Call Method
        controller.doCalculate();  
        
        //Assert For Result
        System.assertEquals(1, controller.stdGDWrapper.stdGoalDetailsWrapper.size());
        System.assertEquals(0, controller.stdGDWrapper.stdGoalDetailsWrapper[0].stdGDetail.Percent__c);
        
        //Call Method
        pR = controller.doSaveAndCPGS();
        
        //Assert For Result
        System.assert(pR.getUrl().contains('/apex/CreatePersonalGoalsFromStdGoal?id='+controller.stdGoal.Id));
            
        //Stop test here
        Test.stopTest();  
    }
    
     //Test methods 
    static testMethod void myUnitTest3() {
        
        //Create Institute
        Account account = TestUtilities.CreateNewAccount(false);
        
        //Insert
        insert account;
        
        //Create a Contact
        Contact contact = new Contact(FirstName = 'Test', LastName = 'Contact', Email = 'test@test.com', AccountId = account.Id, 
                                      Employee_User_Record__c = Userinfo.getUserId());
        
        //Insert
        insert contact;
    
        //Create value type
        List<Value_Type__c> valueTypes =  new List<Value_Type__c>();
        
        //Add value type in list
        valueTypes.add(new Value_Type__c(Name = 'Test1', Values_Permitted__c = 'Date', Category__c ='Business Title', Active__c = true));
        valueTypes.add(new Value_Type__c(Name = 'Test2', Values_Permitted__c = 'Date', Category__c ='Business Title', Active__c = true));
        valueTypes.add(new Value_Type__c(Name = 'Test3', Values_Permitted__c = 'Date', Category__c ='Business Title', Active__c = true));
        valueTypes.add(new Value_Type__c(Name = 'Test3', Values_Permitted__c = 'Date', Category__c ='Credit Type', Active__c = true));
        
        //Insert
        insert valueTypes;
    
        //Create Goal Types
        List<Goal_Type__c> goalTypes = new List<Goal_Type__c>();
        
        //Add new goal type in list
        goalTypes.add(new Goal_Type__c(Name = 'TG1', Active__c = true, Base_Process__c = 'NBB', Description__c = 'Goal Type 0', Standard_Goal__c = true));
        goalTypes.add(new Goal_Type__c(Name = 'TestGoalType2', Active__c = true, Base_Process__c = 'CM', Description__c = 'Goal Type1', Standard_Goal__c = false));
        goalTypes.add(new Goal_Type__c(Name = 'TestGoalType3', Active__c = false, Base_Process__c = 'Activity', Description__c = 'Goal Type2', Standard_Goal__c = false));
        goalTypes.add(new Goal_Type__c(Name = 'TestGoalType4', Active__c = true, Base_Process__c = 'CM', Description__c = 'Goal Type3', Standard_Goal__c = false));
        goalTypes.add(new Goal_Type__c(Name = 'TestGoalType5', Active__c = true, Base_Process__c = 'Renewal', Description__c = 'Goal Type4', Standard_Goal__c = false));
        goalTypes.add(new Goal_Type__c(Name = 'TestGoalType6', Active__c = true, Base_Process__c = 'Renewal', Description__c = 'Goal Type5', Standard_Goal__c = false));
        goalTypes.add(new Goal_Type__c(Name = 'TestGoalType7', Active__c = true, Base_Process__c = 'Renewal', Description__c = 'Goal Type6', Standard_Goal__c = false));
        goalTypes.add(new Goal_Type__c(Name = 'TestGoalType8', Active__c = true, Base_Process__c = 'Renewal', Description__c = 'Goal Type7', Standard_Goal__c = false));
        goalTypes.add(new Goal_Type__c(Name = 'TestGoalType9', Active__c = true, Base_Process__c = 'Renewal', Description__c = 'Goal Type8', Standard_Goal__c = false));
        
        //Insert 
        insert goalTypes;  
        
        //Create Relationship type
        List<Relationship_Type__c> relationShips = new  List<Relationship_Type__c>();
        
        //Add new Programs in lists
        relationShips.add(new Relationship_Type__c(Name = 'Test Relationship1', Business_Owner__c = contact.Id, Name_When_From__c ='TestForm',
                                                      Name_When_To__c = 'TestTo', Active__c = true));
        relationShips.add(new Relationship_Type__c(Name = 'Relationship2', Business_Owner__c = contact.Id, Name_When_From__c ='TestForm1',
                                                     Name_When_To__c = 'TestTo1', Active__c = true));
        
        //Insert
        insert relationShips;
        
        //Create custom Setting Incentive Defaults
        List<Incentive_Defaults__c> incetiveDefaults = new List<Incentive_Defaults__c>();
        
        //Add new Incentive Defaults
        incetiveDefaults.add(new Incentive_Defaults__c(Name = 'TH1', Amount__c = 100 , Category__c = 'Periods', Description__c = 'Semi-annual', Count__c = 1, End__c = System.today().addDays(15),
                                                       Start__c = System.today(), Percent__c = 50));
        incetiveDefaults.add(new Incentive_Defaults__c(Name = 'TH2', Amount__c = 100 , Category__c = 'Periods', Description__c = 'Semi-annual', Count__c = 2, End__c = System.today().addDays(30),
                                                       Start__c = System.today().addDays(16), Percent__c = 50));
        
        //Insert 
        insert incetiveDefaults;
        
        //Standard controller       
        ApexPages.StandardController sc = new ApexPages.standardController(new Standard_Goal__c());

        //Loop through condition record type
        List<RecordType> rType = [Select Id, Name, DeveloperName From RecordType Where SObjectType = 'Condition__c' ORDER BY DeveloperName ASC];
        
        //Test Start here
        Test.startTest();
        
        //Instance of controller
        DefineStandardGoalsController controller = new DefineStandardGoalsController(sc);
    
        //Instance of StdGoalSectionWrapper class
        StdGoalSectionWrapper sGSWrapper = new StdGoalSectionWrapper();
        
        //Assign values to Satndard Goal fields
        controller.stdGoal.Description__c = 'GT Testing 1';
        controller.stdGoal.Percent__c = 100;
        controller.stdGoal.Period_Start__c = System.today().addDays(-100);
        controller.stdGoal.Period_End__c = System.today().addDays(100);
        controller.stdGoal.Business_Owner__c = contact.Id;
        controller.stdGoal.Goal_Type__c = goalTypes[0].Id;
        
        /* Create Conditon */
         
        //Select record type for condition Relationship
        controller.stdGSWrapper.selectedRType = rType[5].Id;
        
        //Assign Values according to record type for new condition
        controller.stdGSWrapper.condition.To_Relationship__c = null;
        controller.stdGSWrapper.condition.From_Relationship__c = relationShips[1].Id;
        controller.stdGSWrapper.condition.Condition_Type__c = 'Include';
        
        //Calling the method of controller
        controller.addNewCondition();  
        
        //Assert For Results
        System.assertEquals(1, controller.stdGSWrapper.conditionsWrapper.size());
        System.assertEquals('Relationship', controller.stdGSWrapper.conditionsWrapper[0].rtype);
        System.assertEquals('Include', controller.stdGSWrapper.conditionsWrapper[0].con.Condition_Type__c);
        
        /* Update Condition */
        
        //Check condition check box for first records
        controller.stdGSWrapper.selectedConditionRowIndex = '1';
        
        //Calling do edit method
        controller.doEditContiditon();
        controller.stdGSWrapper.condition.Condition_Type__c = 'Exclude';
    
        //Calling the method of controller
        controller.addNewCondition();
        
        //Assert For Results
        System.assertEquals(1, controller.stdGSWrapper.conditionsWrapper.size());
        System.assertEquals('Relationship', controller.stdGSWrapper.conditionsWrapper[0].rtype);
        System.assertEquals('Exclude', controller.stdGSWrapper.conditionsWrapper[0].con.Condition_Type__c);
        
            
        //Add Standard Goal Detail 1
        controller.stdGDWrapper.stdGD.Goal_Type__c = goalTypes[1].Id;
        controller.stdGDWrapper.stdGD.Description__c ='GTDTest1';
        //controller.stdGDWrapper.stdGD.Target_Type__c = 'Paced';
        controller.stdGDWrapper.selectedBaseLine = 'Template';
        controller.stdGDWrapper.stdGD.Period_Start__c = System.today().addDays(-90);
        controller.stdGDWrapper.stdGD.Period_End__c = System.today().addDays(90);
   
        //Calling controller method
        controller.addStdGoalDetail();

        //Assert for results
        System.assertEquals(1, controller.stdGDWrapper.stdGoalDetailsWrapper.size());
        System.assertEquals('Template', controller.stdGDWrapper.stdGoalDetailsWrapper[0].selectedBaseLine);
        
        //Add Standard Goal Detail 2
        controller.stdGDWrapper.stdGD.Goal_Type__c = goalTypes[1].Id;
        controller.stdGDWrapper.stdGD.Description__c ='GTDTest2';
        //controller.stdGDWrapper.stdGD.Target_Type__c = 'Paced';
        controller.stdGDWrapper.selectedBaseLine = controller.stdGDWrapper.availableBaseLines[2].getValue();
        controller.stdGDWrapper.stdGD.Period_Start__c = System.today().addDays(-90);
        controller.stdGDWrapper.stdGD.Period_End__c = System.today().addDays(90);
        
        //Calling controller method
        controller.addStdGoalDetail();
        
        //Assert for results
        System.assertEquals(2, controller.stdGDWrapper.stdGoalDetailsWrapper.size());
        
        //Add Standard Goal Detail 3
        controller.stdGDWrapper.stdGD.Goal_Type__c = goalTypes[1].Id;
        controller.stdGDWrapper.stdGD.Description__c ='GTDTest3';
        //controller.stdGDWrapper.stdGD.Target_Type__c = 'Paced';
        controller.stdGDWrapper.selectedBaseLine = controller.stdGDWrapper.availableBaseLines[3].getValue();
        controller.stdGDWrapper.stdGD.Period_Start__c = System.today().addDays(-90);
        controller.stdGDWrapper.stdGD.Period_End__c = System.today().addDays(90);
   
        //Calling controller method
        controller.addStdGoalDetail();
        
        //Assert for results
        System.assertEquals(3, controller.stdGDWrapper.stdGoalDetailsWrapper.size());
        System.assertEquals(goalTypes[1].Id+'-'+controller.stdGDWrapper.stdGoalDetailsWrapper[1].stdGDetail.Description__c+'-'+controller.stdGDWrapper.stdGoalDetailsWrapper[1].stdGDetail.Target_Type__c, controller.stdGDWrapper.stdGoalDetailsWrapper[2].selectedBaseLine);
        
        //Select Row
        controller.stdGDWrapper.stdGoalDetailsWrapper[0].selected = true;       
        controller.stdGDWrapper.stdGoalDetailsWrapper[1].selected = true;       
        controller.stdGDWrapper.stdGoalDetailsWrapper[2].selected = true;
        
        //Call Method
        controller.doCalculate();
        
        //Assert for result
        System.assertEquals(100, controller.stdGDWrapper.stdGoalDetailsWrapper[0].stdGDetail.Percent__c);
        System.assertEquals(100, controller.stdGDWrapper.stdGoalDetailsWrapper[1].stdGDetail.Percent__c);
        System.assertEquals(100, controller.stdGDWrapper.stdGoalDetailsWrapper[2].stdGDetail.Percent__c);
        System.assertEquals('Template', controller.stdGDWrapper.stdGoalDetailsWrapper[0].selectedBaseLine);
        //System.assertEquals(goalTypes[1].Id+'-'+controller.stdGDWrapper.stdGoalDetailsWrapper[0].stdGDetail.Description__c+'-'//+controller.stdGDWrapper.stdGoalDetailsWrapper[0].stdGDetail.Target_Type__c, //controller.stdGDWrapper.stdGoalDetailsWrapper[1].selectedBaseLine);
        System.assertEquals(goalTypes[1].Id+'-'+controller.stdGDWrapper.stdGoalDetailsWrapper[1].stdGDetail.Description__c+'-'+controller.stdGDWrapper.stdGoalDetailsWrapper[1].stdGDetail.Target_Type__c, controller.stdGDWrapper.stdGoalDetailsWrapper[2].selectedBaseLine);
        
        //Set row index
        controller.stdGDWrapper.selectedSGDRowIndex = '3';
        
        //Call Method
        controller.doEditstdGoalDetail();
        
        //Set Counter Goal Template Detail
        controller.stdGDWrapper.stdGD.Baseline_Percentage__c = 50;
        
        //Call Method
        controller.addStdGoalDetail();
        
        //Set row index
        controller.stdGDWrapper.selectedSGDRowIndex = '2';
        
        //Call Method
        controller.doEditstdGoalDetail();
        
        //Set Counter Goal Template Detail
        controller.stdGDWrapper.stdGD.Baseline_Percentage__c = 50;
        
        //Call Method
        controller.addStdGoalDetail();
        
        //Select Index Row
        controller.stdGDWrapper.stdGoalDetailsWrapper[0].selected = true;       
        controller.stdGDWrapper.stdGoalDetailsWrapper[1].selected = true;       
        controller.stdGDWrapper.stdGoalDetailsWrapper[2].selected = true;
        
        //Call Method
        controller.doCalculate();
        
        //Assert for result
        System.assertEquals(100, controller.stdGDWrapper.stdGoalDetailsWrapper[0].stdGDetail.Percent__c);
        System.assertEquals(50, controller.stdGDWrapper.stdGoalDetailsWrapper[1].stdGDetail.Percent__c);
        System.assertEquals(25, controller.stdGDWrapper.stdGoalDetailsWrapper[2].stdGDetail.Percent__c);
        System.assertEquals('Template', controller.stdGDWrapper.stdGoalDetailsWrapper[0].selectedBaseLine);
        //System.assertEquals(goalTypes[1].Id+'-'+controller.stdGDWrapper.stdGoalDetailsWrapper[0].stdGDetail.Description__c+'-'//+controller.stdGDWrapper.stdGoalDetailsWrapper[0].stdGDetail.Target_Type__c, //controller.stdGDWrapper.stdGoalDetailsWrapper[1].selectedBaseLine);
        System.assertEquals(goalTypes[1].Id+'-'+controller.stdGDWrapper.stdGoalDetailsWrapper[1].stdGDetail.Description__c+'-'+controller.stdGDWrapper.stdGoalDetailsWrapper[1].stdGDetail.Target_Type__c, controller.stdGDWrapper.stdGoalDetailsWrapper[2].selectedBaseLine);
        
        //Set row index
        controller.stdGDWrapper.selectedSGDRowIndex = '3';
        
        //Call Method
        controller.doEditstdGoalDetail();
        
        //Set Sums To select 1
        controller.stdGDWrapper.stdGDetailsWrapper.selectedParent = controller.stdGDWrapper.stdGDetailsWrapper.availableParents[1].getValue();
        
        //Call Method
        controller.addStdGoalDetail();
        
        //Assert For Result
        System.assertEquals(25.00, controller.stdGDWrapper.stdGoalDetailsWrapper[2].stdGDetail.Percent__c);
        
        //Select Index Row
        controller.stdGDWrapper.stdGoalDetailsWrapper[0].selected = true;       
        controller.stdGDWrapper.stdGoalDetailsWrapper[1].selected = true;       
        controller.stdGDWrapper.stdGoalDetailsWrapper[2].selected = true;
        
        //Call Method
        controller.doCalculate();
        
        //Assert for result
        System.assertEquals(3, controller.stdGDWrapper.stdGoalDetailsWrapper.size());
        System.assertEquals('Explicit', controller.stdGDWrapper.stdGoalDetailsWrapper[0].stdGDetail.Target_Type__c);
        //System.assertEquals('Paced', controller.stdGDWrapper.stdGoalDetailsWrapper[1].stdGDetail.Target_Type__c);
        //System.assertEquals('Paced', controller.stdGDWrapper.stdGoalDetailsWrapper[2].stdGDetail.Target_Type__c);
        System.assertEquals(6.25, controller.stdGDWrapper.stdGoalDetailsWrapper[0].stdGDetail.Percent__c);
        System.assertEquals(12.5, controller.stdGDWrapper.stdGoalDetailsWrapper[1].stdGDetail.Percent__c);
        System.assertEquals(6.25, controller.stdGDWrapper.stdGoalDetailsWrapper[2].stdGDetail.Percent__c);
        System.assertEquals(3, controller.stdGDWrapper.stdGoalDetailsWrapper.size());
        System.assertEquals('',controller.stdGDWrapper.stdGoalDetailsWrapper[0].selectedBaseLine);
        //System.assertEquals(goalTypes[1].Id+'-'+controller.stdGDWrapper.stdGoalDetailsWrapper[0].stdGDetail.Description__c+'-'//+controller.stdGDWrapper.stdGoalDetailsWrapper[0].stdGDetail.Target_Type__c, //controller.stdGDWrapper.stdGoalDetailsWrapper[1].selectedBaseLine);
        //System.assertEquals(goalTypes[1].Id+'-'+controller.stdGDWrapper.stdGoalDetailsWrapper[1].stdGDetail.Description__c+'-'//+controller.stdGDWrapper.stdGoalDetailsWrapper[1].stdGDetail.Target_Type__c, //controller.stdGDWrapper.stdGoalDetailsWrapper[2].selectedBaseLine);
        
        //Set row index
        controller.stdGDWrapper.selectedSGDRowIndex = '1';
        
        //Call Method
        controller.doEditstdGoalDetail();
        
        //Create Pacing 
        controller.stdGDWrapper.stdGD.Period__c = incetiveDefaults[0].Name;
        
        //Calling the method of controller  
        controller.populatePeriods();
        controller.addStdGoalDetail();
        
        //Call Method
        PageReference pR = controller.doSaveAndCPGS();
        
        //Assert For Result    
        //System.assert(pR.getUrl().contains('/apex/CreatePersonalGoalsFromStdGoal?id='+controller.stdGoal.Id));
        
        //Query on Standard goal
        List<Standard_Goal__c> standardGoalFetch = [Select Id from Standard_Goal__c];
        
        //Standard controller       
        sc = new ApexPages.standardController(standardGoalFetch[0]);
        
        //Instance of controller
        controller = new DefineStandardGoalsController(sc);
        
        //Assert For Result
        System.assertEquals(3, controller.stdGDWrapper.stdGoalDetailsWrapper.size());
        
        //Select Row  
        controller.stdGDWrapper.stdGoalDetailsWrapper[0].selected = true;
        controller.stdGDWrapper.stdGoalDetailsWrapper[2].selected = true;
        
        //Call Method
        controller.removeStdGoalDetail();
        pR = controller.doSaveAndCPGS();
        
        //Assert For Result
        System.assert(pR.getUrl().contains('/apex/CreatePersonalGoalsFromStdGoal?id='+controller.stdGoal.Id));
        
        //Query on Standard goal
        standardGoalFetch = [Select Id from Standard_Goal__c];
          
        //Standard controller       
        sc = new ApexPages.standardController(standardGoalFetch[0]);
        
        //Instance of controller
        controller = new DefineStandardGoalsController(sc);
        
        //Assert For Result
        System.assertEquals(1, controller.stdGDWrapper.stdGoalDetailsWrapper.size());
        
        //Select Index Row
        controller.stdGDWrapper.stdGoalDetailsWrapper[0].selected = true;
        
        //Call Method
        controller.removeStdGoalDetail(); 
        
        //Assert For Result
        System.assertEquals(0, controller.stdGDWrapper.stdGoalDetailsWrapper.size());
        
        
        /*----------Add sales Role Method----------*/
        
        //Add Business Title or sales role 
        controller.stdGSR.Sales_Role__c = valueTypes[0].Id;
        
        //Calling the method of controller
        controller.addSalesRole();
        controller.displayBusinessTitle();
        
        //Add Standard Goal Detail 1
        controller.stdGDWrapper.stdGD.Goal_Type__c = goalTypes[1].Id;
        controller.stdGDWrapper.stdGD.Description__c ='GTDTest1';
        //controller.stdGDWrapper.stdGD.Target_Type__c = 'Paced';
        controller.stdGDWrapper.selectedBaseLine = 'Template';
        controller.stdGDWrapper.stdGD.Period_Start__c = System.today().addDays(-90);
        controller.stdGDWrapper.stdGD.Period_End__c = System.today().addDays(90);
   
        //Calling controller method
        controller.addStdGoalDetail();

        //Assert for results
        System.assertEquals(1, controller.stdGDWrapper.stdGoalDetailsWrapper.size());
        
        //Add Standard Goal Detail 2
        controller.stdGDWrapper.stdGD.Goal_Type__c = goalTypes[1].Id;
        controller.stdGDWrapper.stdGD.Description__c ='GTDTest2';
        //controller.stdGDWrapper.stdGD.Target_Type__c = 'Paced';
        controller.stdGDWrapper.selectedBaseLine = 'Template';
        controller.stdGDWrapper.stdGD.Period_Start__c = System.today().addDays(-90);
        controller.stdGDWrapper.stdGD.Period_End__c = System.today().addDays(90);
   
        //Calling controller method
        controller.addStdGoalDetail();

        //Assert for results
        System.assertEquals(2, controller.stdGDWrapper.stdGoalDetailsWrapper.size());
        

        //Add Standard Goal Detail 3
        controller.stdGDWrapper.stdGD.Goal_Type__c = goalTypes[1].Id;
        controller.stdGDWrapper.stdGD.Description__c ='GTDTest3';
        //controller.stdGDWrapper.stdGD.Target_Type__c = 'Paced';
        controller.stdGDWrapper.selectedBaseLine = 'Template';
        controller.stdGDWrapper.stdGD.Period_Start__c = System.today().addDays(-90);
        controller.stdGDWrapper.stdGD.Period_End__c = System.today().addDays(90);
   
        //Calling controller method
        controller.addStdGoalDetail();

        //Assert for results
        System.assertEquals(3, controller.stdGDWrapper.stdGoalDetailsWrapper.size());
        
        //Add Standard Goal Detail 4
        controller.stdGDWrapper.stdGD.Goal_Type__c = goalTypes[1].Id;
        controller.stdGDWrapper.stdGD.Description__c ='GTDTest4';
        //controller.stdGDWrapper.stdGD.Target_Type__c = 'Paced';
        controller.stdGDWrapper.selectedBaseLine = 'Template';
        controller.stdGDWrapper.stdGD.Period_Start__c = System.today().addDays(-90);
        controller.stdGDWrapper.stdGD.Period_End__c = System.today().addDays(90);
   
        //Calling controller method
        controller.addStdGoalDetail();

        //Assert for results
        System.assertEquals(4, controller.stdGDWrapper.stdGoalDetailsWrapper.size());
        
        //Add Standard Goal Detail 
        controller.stdGDWrapper.stdGD.Goal_Type__c = goalTypes[1].Id;
        controller.stdGDWrapper.stdGD.Description__c ='GTDTest5';
        //controller.stdGDWrapper.stdGD.Target_Type__c = 'Paced';
        controller.stdGDWrapper.selectedBaseLine = 'Template';
        controller.stdGDWrapper.stdGD.Period_Start__c = System.today().addDays(-90);
        controller.stdGDWrapper.stdGD.Period_End__c = System.today().addDays(90);
   
        //Calling controller method
        controller.addStdGoalDetail();

        //Assert for results
        System.assertEquals(5, controller.stdGDWrapper.stdGoalDetailsWrapper.size());
        
        //Set row index
        controller.stdGDWrapper.selectedSGDRowIndex = '3';
        
        //Call Method
        controller.doEditstdGoalDetail();
        
        //Set Parent, Baseline
        controller.stdGDWrapper.selectedBaseLine = controller.stdGDWrapper.availableBaseLines[3].getValue();
        controller.stdGDWrapper.stdGDetailsWrapper.selectedParent = controller.stdGDWrapper.stdGDetailsWrapper.availableParents[2].getValue();
        
        //Call Method
        controller.addStdGoalDetail();
        
        //Set row index
        controller.stdGDWrapper.selectedSGDRowIndex = '4';
        
        //Call Method
        controller.doEditstdGoalDetail();
        
        //Set Parent, Baseline
        controller.stdGDWrapper.selectedBaseLine = controller.stdGDWrapper.availableBaseLines[4].getValue();
        controller.stdGDWrapper.stdGDetailsWrapper.selectedParent = controller.stdGDWrapper.stdGDetailsWrapper.availableParents[1].getValue();
        
        //Call Method
        controller.addStdGoalDetail();
        
        //Select Index Row
        controller.stdGDWrapper.stdGoalDetailsWrapper[0].selected = true;
        controller.stdGDWrapper.stdGoalDetailsWrapper[1].selected = true;
        
        //Call Method
        controller.removeStdGoalDetail();
        
        System.assertEquals(3, controller.stdGDWrapper.stdGoalDetailsWrapper.size());
        System.assertEquals('GTDTest3', controller.stdGDWrapper.stdGoalDetailsWrapper[0].stdGDetail.Description__c);
        System.assertEquals('GTDTest4', controller.stdGDWrapper.stdGoalDetailsWrapper[1].stdGDetail.Description__c);
        System.assertEquals('GTDTest5', controller.stdGDWrapper.stdGoalDetailsWrapper[2].stdGDetail.Description__c);
        System.assertEquals('', controller.stdGDWrapper.stdGoalDetailsWrapper[0].selectedBaseLine);
        //System.assertEquals(goalTypes[1].Id+'-'+controller.stdGDWrapper.stdGoalDetailsWrapper[0].stdGDetail.Description__c+'-'//+controller.stdGDWrapper.stdGoalDetailsWrapper[0].stdGDetail.Target_Type__c, //controller.stdGDWrapper.stdGoalDetailsWrapper[1].selectedBaseLine);
        System.assertEquals('Template', controller.stdGDWrapper.stdGoalDetailsWrapper[2].selectedBaseLine);
        
        /* Goal Template Detail Conditon */
        
        //Set row index data 1
        controller.stdGDWrapper.selectedSGDRowIndex = '1';
        controller.sGDCondition = 'true';
        controller.stdGDRowIndex = 1;
               
        //Select record type for condition Activity date
        controller.stdGSWrapper.selectedRType = rType[0].Id;
        
        //Assign Values according to record type for new condition
        controller.stdGSWrapper.condition.Start_Date__c = System.today();
        controller.stdGSWrapper.condition.End_Date__c = System.today().addDays(4);
        controller.stdGSWrapper.condition.Date_Type__c = 'Close';
        controller.stdGSWrapper.condition.Condition_Type__c = 'Include';
        
        //Calling the method of controller
        controller.addNewCondition();  
        controller.stdGDetailCondtions();
        
        //Assert for results
        System.assertEquals(1, controller.stdGoalDetailConditions.size());
        
        //Set row index data 2
        controller.stdGDWrapper.selectedSGDRowIndex = '1';
        controller.sGDCondition = 'true';
        controller.stdGDRowIndex = 1;
               
        //Select record type for condition Activity date
        controller.stdGSWrapper.selectedRType = rType[0].Id;
        
        //Assign Values according to record type for new condition
        controller.stdGSWrapper.condition.Start_Date__c = System.today();
        controller.stdGSWrapper.condition.End_Date__c = System.today().addDays(4);
        controller.stdGSWrapper.condition.Date_Type__c = 'Close';
        controller.stdGSWrapper.condition.Condition_Type__c = 'Include';
        
        //Calling the method of controller
        controller.addNewCondition();  
        controller.stdGDetailCondtions();
        
        //Assert for results
        System.assertEquals(2, controller.stdGoalDetailConditions.size());
        
        //Select Index
        controller.stdGSWrapper.selectedConditionRowIndex = '1';
        controller.sGDCondition = 'true';
        controller.stdGDRowIndex = 1;
        
        //Call Method
        controller.doEditContiditon();
        
        //Set Value 
        controller.stdGSWrapper.condition.Date_Type__c = 'Other';
        
        //Call Method
        controller.addNewCondition();
        
        //Select Conditon Of Goal Template Detail
        controller.stdGSWrapper.selectedConditionRowIndex = '1';
        controller.stdGoalDetailConditions[0].selected = true;
        controller.sGDCondition = 'true';
        controller.stdGDRowIndex = 1;
        
        //Call Method
        controller.removeCondition();
        
        //Assert For Result
        System.assertEquals(1, controller.stdGoalDetailConditions.size());
        
        controller.stdGDWrapper.stdGoalDetailsWrapper[0].selected = true;
        
        //Call Method  
        controller.cloneGoalTemplateDetails();
        
        /* Update Goal Template Detial Condition*/
        
        //Assert For Result
        System.assertEquals(1, controller.stdGoalDetailConditions.size());
        System.assertEquals('Close', controller.stdGoalDetailConditions[0].con.Date_Type__c);
        
        //Select Index
        controller.stdGSWrapper.selectedConditionRowIndex = '1';
        controller.sGDCondition = 'true';
        controller.stdGDRowIndex = 1;
        
        //Call Method
        controller.doEditContiditon();
        
        //Set Value 
        controller.stdGSWrapper.condition.Date_Type__c = 'Other';
        
        //Call Method
        controller.addNewCondition();
        controller.stdGDetailCondtions();
        
        //Assert For Result
        System.assertEquals(1, controller.stdGoalDetailConditions.size());
        System.assertEquals('Other', controller.stdGoalDetailConditions[0].con.Date_Type__c);
        
        /* Add Goal Template Detail Mesarument Period on Goal Template Detail*/
        
        //Select Row index
        controller.stdGDWrapper.selectedSGDRowIndex = '1';
        controller.stdGDRowIndex = 1;
        
        //Set date for Goal template detail mesurement period
        controller.gTDMPWrapper.gTDMP.Measurement_Date__c = System.Today().addDays(5);
        
        //Call Method
        controller.populateGTDMPs();  
        controller.addGTDMP();
        
        //Assert For Result
        System.assertEquals(1, controller.gTDMPeriods.size());
        
        //Select Index
        controller.stdGDWrapper.selectedSGDRowIndex = '1';
        controller.stdGDRowIndex = 1;
        
        //Call Mehtod
        controller.removeGTDMP();
        
        //Select Index
        controller.stdGDWrapper.selectedSGDRowIndex = '1';
        controller.gTDMPeriods[0].selected = true;
        controller.stdGDRowIndex = 1;
        
        //Call Mehtod
        controller.removeGTDMP();
        
        //Assert For Result
        System.assertEquals(0, controller.gTDMPeriods.size());
        
        //Select Index
        controller.stdGDWrapper.selectedSGDRowIndex = '1';
        controller.stdGDRowIndex = 1;
        controller.gTDMPWrapper.gTDMP.Measurement_Date__c = System.Today().addDays(5);
        
        //Call Method
        controller.populateGTDMPs();  
        controller.addGTDMP();
        
        //Assert For Result
        System.assertEquals(1, controller.gTDMPeriods.size());
        
        /* Added new Goal Template Detail Condition of credit Type */
        
        //Set row index
        controller.stdGDWrapper.selectedSGDRowIndex = '1';
        controller.sGDCondition = 'true';
        controller.stdGDRowIndex = 1;
               
        //Select record type for condition Activity date
        controller.stdGSWrapper.selectedRType = rType[3].Id;
        
        //Assign Values according to record type for new condition
        controller.stdGSWrapper.condition.Credit_Type__c = valueTypes[3].Id;
        
        //Calling the method of controller
        controller.addNewCondition();  
        controller.stdGDetailCondtions();
        
        //Assert for Results
        System.assertEquals(1, controller.stdGoalDetailConditions.size());
        System.assertEquals(valueTypes[3].Id, controller.stdGoalDetailConditions[0].con.Credit_Type__c);
        
        /*Add Goal Template Detail */
        
        //Add Standard Goal Detail 
        controller.stdGDWrapper.stdGD.Goal_Type__c = goalTypes[1].Id;
        controller.stdGDWrapper.stdGD.Description__c ='zzPacedGoalTemplate';
        //controller.stdGDWrapper.stdGD.Target_Type__c = 'Paced';
        controller.stdGDWrapper.selectedBaseLine = 'Template';
   
        //Calling controller method
        controller.addStdGoalDetail();

        //Assert for results
        System.assertEquals(4, controller.stdGDWrapper.stdGoalDetailsWrapper.size());
        
        /* Update Goal Template Detail Type */
        
        //Select Row Index
        controller.stdGDWrapper.selectedSGDRowIndex = '4';
        
        //Call Method
        controller.doEditstdGoalDetail();
        
        //Set value
        controller.stdGDWrapper.stdGD.Discount__c = 50;
        //controller.stdGDWrapper.stdGD.Target_Type__c = 'Explicit';
        controller.stdGDWrapper.selectedBaseLine = 'Template';
        controller.stdGDWrapper.stdGD.Amount__c = 20000;
        
        //Add Pacing using Period Field 3
        controller.stdGDWrapper.stdGD.Period__c = incetiveDefaults[0].Name;
        
        //Calling the method of controller  
        controller.populatePeriods();
        controller.addStdGoalDetail();
        
        //Set Row Index
        controller.stdGDWrapper.selectedSGDRowIndex = '4';
        
        //Call method
        controller.doEditstdGoalDetail();
        
        //Set value
        controller.stdGDWrapper.stdGD.Period__c = incetiveDefaults[1].Name;
        
        //Call Method
        controller.populatePeriods();
        controller.addStdGoalDetail();
  
        //Call Method
        pR = controller.doSaveAndCPGS();
        
        //Assert For Result
        System.assert(pR.getUrl().contains('/apex/CreatePersonalGoalsFromStdGoal?id='+controller.stdGoal.Id));
        
        //Query on Standard goal
        standardGoalFetch = [Select Id from Standard_Goal__c];
        
        //Assert For Result
        System.assertEquals(1 , standardGoalFetch.size());
          
        //Standard controller       
        sc = new ApexPages.standardController(standardGoalFetch[0]);
        
        //Instance of controller
        controller = new DefineStandardGoalsController(sc);
        
        //Assert For Result
        System.assertEquals(4, controller.stdGDWrapper.stdGoalDetailsWrapper.size());
        System.assertEquals(1, controller.stdGSWrapper.conditionsWrapper.size());
        System.assertEquals(0, controller.gTDMPeriods.size());
        
        //Test Method Stop Here
        Test.stopTest();
    } 
       
}