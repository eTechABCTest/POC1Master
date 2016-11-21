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
private class Test_Trigger_PersonalGoal {
  /**
    *   Purpose         :   Test class for Trigger_PersonalGoal
    *            
    *   Create By       :   Padmesh Soni
    *
    *   Created Date    :   08/18/2015
    *
    *   Revision Log    :   V_1.0 - Created - CR-20150729-9114 
    * 						V_2.0 - Modified By - Rajeev Jain - 1/13/2016 -  ISSP Deployment C Release QA changes.
    * 						Commented out validatesPersonalGoal(myUnitTest test method) , since its no longer needed.    
    * 
    *   Coverage        :   V_1.0 - 97%
    **/
  
    //Setup test data from class
    @testSetup static void setupTestDataForClass() {
        
        //Create an institution
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
        goalTypes.add(new Goal_Type__c(Name = 'TestGoalType1', Active__c = true, Standard_Goal__c = true, Base_Process__c = 'NBB', Description__c = 'Testing of Goal Type'));
        goalTypes.add(new Goal_Type__c(Name = 'TestGoalType2', Active__c = true, Standard_Goal__c = true, Base_Process__c = 'CM', Description__c = 'Testing of Goal Types'));
        goalTypes.add(new Goal_Type__c(Name = 'TestGoalType3', Active__c = false, Standard_Goal__c = true, Base_Process__c = 'Activity', Description__c = 'Testing of Goal'));
        goalTypes.add(new Goal_Type__c(Name = 'TestGoalType4', Active__c = false, Standard_Goal__c = true, Base_Process__c = 'Renewal', Description__c = 'Goal Type'));
        
        //Insert 
        insert goalTypes;

        //Create Standard Goals
        List<Standard_Goal__c> standardGoals = new List<Standard_Goal__c>();
        
        //Add new Standard Goals in list
        standardGoals.add(new Standard_Goal__c(Name = 'StandardGoal1', Active__c = true, Amount__c = 100, Business_Owner__c = contact.Id,
                                               Description__c = 'Testing of Standard Goal', Goal_Type__c = goalTypes[0].Id, 
                                               Period_Start__c = System.today(), Period_End__c = System.today().addDays(4)));
        standardGoals.add(new Standard_Goal__c(Name = 'StandardGoal2', Active__c = true, Amount__c = 200, Business_Owner__c = contact.Id,
                                               Description__c = 'Testing of Standard Goal', Goal_Type__c = goalTypes[1].Id,
                                               Period_Start__c = System.today().addDays(10), Period_End__c = System.today().addDays(20)));
        standardGoals.add(new Standard_Goal__c(Name = 'StandardGoal3', Active__c = false, Amount__c = 300, Business_Owner__c = contact.Id,
                                               Description__c = 'Testing of Standard Goal', Goal_Type__c = goalTypes[1].Id,
                                               Period_Start__c = System.today().addDays(25), Period_End__c = System.today().addDays(30)));
        
        //Insert 
        insert standardGoals;
                               
        //Create Standard Goal Details
        List<Standard_Goal_Detail__c> standardGoalDetails = new List<Standard_Goal_Detail__c>();
        
        //Add new Standard Goal Details in list
        standardGoalDetails.add(new Standard_Goal_Detail__c(Name = 'StandardGoalDetail1', Active__c = true, Description__c = 'Testing',Target_Type__c = 'Paced',
                                                            Standard_Goal__c = standardGoals[0].Id));
        standardGoalDetails.add(new Standard_Goal_Detail__c(Name = 'StandardGoalDetail2', Active__c = true, Description__c = 'Testing',Target_Type__c = 'Paced',
                                                            Standard_Goal__c = standardGoals[0].Id));
        standardGoalDetails.add(new Standard_Goal_Detail__c(Name = 'StandardGoalDetail3', Active__c = true, Description__c = 'Testing',Target_Type__c = 'Paced',
                                                            Standard_Goal__c = standardGoals[1].Id));
        standardGoalDetails.add(new Standard_Goal_Detail__c(Name = 'StandardGoalDetail4', Active__c = true, Description__c = 'Testing',Target_Type__c = 'Paced',
                                                            Standard_Goal__c = standardGoals[1].Id));
        standardGoalDetails.add(new Standard_Goal_Detail__c(Name = 'StandardGoalDetail5', Active__c = true, Description__c = 'Testing',Target_Type__c = 'Paced',
                                                            Standard_Goal__c = standardGoals[2].Id));
        
        //Insert 
        insert standardGoalDetails;
        
        //Create Personal Plan
        List<Personal_Plan__c> personalPlans = new List<Personal_Plan__c>();
        
        //Add new Personal Plan in list
        personalPlans.add(new Personal_Plan__c(Name = 'PersonalPlan1', Active__c = true, Description__c = 'Testing', Staff_Member__c = contact.Id,
                                              Plan_Start__c = System.today().addDays(1), Plan_End__c = System.today().addDays(10)));
        personalPlans.add(new Personal_Plan__c(Name = 'PersonalPlan2', Active__c = true, Description__c = 'Testing', Staff_Member__c = contact.Id,
                                              Plan_Start__c = System.today().addDays(12), Plan_End__c = System.today().addDays(18)));
        personalPlans.add(new Personal_Plan__c(Name = 'PersonalPlan3', Active__c = true, Description__c = 'Testing', Staff_Member__c = contact.Id,
                                              Plan_Start__c = System.today().addDays(20),  Plan_End__c = System.today().addDays(25)));
        
        //Insert
        insert personalPlans;
    
    }
    
    //Test method for validatesPersonalGoal method
    /*static testMethod void myUnitTest() {
        
        //List of Goal Type
        List<Goal_Type__c> goalTypes = [Select Id From Goal_Type__c];
       
        //List of Personal Plan
        List<Personal_Plan__c> personalPlans = [Select Id From Personal_Plan__c];
        
        //List of Stanndard Goal Detail
        List<Standard_Goal_Detail__c> fetchSGDs = [Select Id From Standard_Goal_Detail__c];
        
        //List of record type
        List<RecordType> recordTypes = [select Id, DeveloperName From RecordType Where SObjectType = 'Personal_Goal__c' 
                                        AND DeveloperName IN ('Personal_Goal', 'Proposal') ORDER BY DeveloperName ASC LIMIT 2];
        
        //Create Personal Goal
        List<Personal_Goal__c> personalGoals = new List<Personal_Goal__c>();
        
        //Add new Personal Goal in list
        personalGoals.add(new Personal_Goal__c(Name = 'PersonalGoal1', Goal_Type__c = goalTypes[0].Id, Active__c = true, RecordTypeId = recordTypes[0].Id,
                                               Personal_Plan__c = personalPlans[0].Id, Description__c = 'Testing', Amount__c = 100, Standard_Goal_Detail__c = fetchSGDs[0].Id,
                                               Period_Start__c = System.today().addDays(1), Period_End__c = System.today().addDays(10)));
        //Add new Personal Goal in list
        personalGoals.add(new Personal_Goal__c(Name = 'PersonalGoal2', Goal_Type__c = goalTypes[0].Id, Active__c = true, RecordTypeId = recordTypes[0].Id,
                                               Personal_Plan__c = personalPlans[0].Id, Description__c = 'Testing', Amount__c = 100, Standard_Goal_Detail__c = fetchSGDs[0].Id,
                                               Period_Start__c = System.today().addDays(12), Period_End__c = System.today().addDays(20)));
        //Add new Personal Goal in list
        personalGoals.add(new Personal_Goal__c(Name = 'PersonalGoal3', Goal_Type__c = goalTypes[0].Id, Active__c = true, RecordTypeId = recordTypes[0].Id,
                                               Personal_Plan__c = personalPlans[0].Id, Description__c = 'Testing', Amount__c = 100, Standard_Goal_Detail__c = fetchSGDs[0].Id,
                                               Period_Start__c = System.today().addDays(21), Period_End__c = System.today().addDays(40)));
        
        //Start testing from here
        Test.startTest();
        
        //Try to insert record that will throw an exception that will cover in catch part
        try {    
            
            //Insert
            insert personalGoals;
            
            //Assert for Result
            //System.assert(false);
        }
        
        //Catch block to handle exception
        catch(Exception ex) {
        
            //Assert for Result
            System.assert(ex.getMessage().contains(Label.ERROR_CONTINUOUS_PG));
        }
 
        personalGoals[1].Period_Start__c = System.today().addDays(5);
 
        //Try to insert record that will throw an exception that will cover in catch part
        try {    
            
            //Insert 
            insert personalGoals;
            
            //Assert for Result
            System.assert(false);
        }
        
        //Catch block to handle exception
        catch(Exception ex) {
        
            //Assert for Result
            System.assert(ex.getMessage().contains(Label.ERROR_UNIQUENESS_PG));
        }
        
        //Update Personal Goal record with start date and insert
        personalGoals[1].Period_Start__c = System.today().addDays(11);
        
        //Insert
        insert personalGoals;
        
        //Update Personal Goal record with start date and insert
        personalGoals[2].Period_Start__c = System.today().addDays(25);
        
        //Try to update record that will throw an exception that will cover in catch part
        try {    
        
            //Update
            update personalGoals[2];

            //Assert for Result
            System.assert(false);
        }
        
        //Catch block to handle exception
        catch(Exception ex) {
        
            //Assert for Result
            System.assert(ex.getMessage().contains(Label.ERROR_CONTINUOUS_PG));
        }

        //Update SGDP record with start date and insert
        personalGoals[2].Period_Start__c = System.today().addDays(18);
        
        //Try to update record that will throw an exception that will cover in catch part
        try {    
        
            //Update
            update personalGoals[2];

            //Assert for Result
            System.assert(false);
        }
        
        //Catch block to handle exception
        catch(Exception ex) {
        
            //Assert for Result
            System.assert(ex.getMessage().contains(Label.ERROR_UNIQUENESS_PG));
        }
        
        
        //Update Personal Goal record with start date and insert
        personalGoals[2].Period_Start__c = System.today().addDays(21);
        
        //Update
        update personalGoals[2];
        
        //Create New Personal Goal
        List<Personal_Goal__c> personalGoalsNew = new List<Personal_Goal__c>();
        
        //Add new Personal Goal in list
        personalGoalsNew.add(new Personal_Goal__c(Name = 'PersonalGoal1', Goal_Type__c = goalTypes[0].Id, Active__c = true, RecordTypeId = recordTypes[0].Id,
                                               Personal_Plan__c = personalPlans[1].Id, Description__c = 'Testing', Amount__c = 100,
                                               Period_Start__c = System.today().addDays(1), Period_End__c = System.today().addDays(10)));
        //Add new Personal Goal in list
        personalGoalsNew.add(new Personal_Goal__c(Name = 'PersonalGoal2', Goal_Type__c = goalTypes[0].Id, Active__c = true, RecordTypeId = recordTypes[0].Id,
                                               Personal_Plan__c = personalPlans[1].Id, Description__c = 'Testing', Amount__c = 100,
                                               Period_Start__c = System.today().addDays(11), Period_End__c = System.today().addDays(20)));
        
        //Insert
        insert personalGoalsNew;
        
        List<Personal_Goal__c> pGList = new List<Personal_Goal__c>();
        
        //Add new Personal Goal in list
        pGList.add(new Personal_Goal__c(Name = 'PersonalGoal3', Goal_Type__c = goalTypes[0].Id, Active__c = true, RecordTypeId = recordTypes[0].Id,
                                               Personal_Plan__c = personalPlans[0].Id, Description__c = 'Testing', Amount__c = 100, Standard_Goal_Detail__c = fetchSGDs[0].Id,
                                               Period_Start__c = System.today().addDays(41), Period_End__c = System.today().addDays(50)));
        insert pGList;
        
        pGList[0].Period_Start__c = System.today().addDays(42);
        
        //Try to update record that will throw an exception that will cover in catch part
        try {    
            
            //Update 
            update pGList;
            
            //Assert for Result
            System.assert(false);
        }
        
        //Catch block to handle exception
        catch(Exception ex) {
        
            //Assert for Result
            System.assert(ex.getMessage().contains(Label.ERROR_CONTINUOUS_PG));
        }
        
        
        //Stop Testing here
        Test.stopTest();
    }*/
    
    //Test method for createProposalGoal method
    static testMethod void myUnitTest1() {
        
        //List of Goal Type
        List<Goal_Type__c> goalTypes = [Select Id From Goal_Type__c];
           
        //List of Personal Plan
        List<Personal_Plan__c> personalPlans = [Select Id From Personal_Plan__c];
           
        //List of record type
        List<RecordType> recordTypes = [select Id, DeveloperName From RecordType Where SObjectType = 'Personal_Goal__c' 
                                            AND DeveloperName IN ('Personal_Goal', 'Proposal') ORDER BY DeveloperName ASC LIMIT 2];
            
        //Create Personal Goal
        List<Personal_Goal__c> personalGoals = new List<Personal_Goal__c>();
            
        //Add new Personal Goal in list
        personalGoals.add(new Personal_Goal__c(Name = 'PersonalGoal1', Goal_Type__c = goalTypes[0].Id, Active__c = true, RecordTypeId = recordTypes[0].Id,
                                                   Personal_Plan__c = personalPlans[0].Id, Description__c = 'Testing', Amount__c = 100, 
                                                   Period_Start__c = System.today().addDays(1), Period_End__c = System.today().addDays(10)));
        //Add new Personal Goal in list
        personalGoals.add(new Personal_Goal__c(Name = 'PersonalGoal2', Goal_Type__c = goalTypes[0].Id, Active__c = true, RecordTypeId = recordTypes[0].Id,
                                                   Personal_Plan__c = personalPlans[0].Id, Description__c = 'Testing', Amount__c = 100,
                                                   Period_Start__c = System.today().addDays(11), Period_End__c = System.today().addDays(20)));
        //Add new Personal Goal in list
        personalGoals.add(new Personal_Goal__c(Name = 'PersonalGoal3', Goal_Type__c = goalTypes[0].Id, Active__c = true, RecordTypeId = recordTypes[1].Id,
                                               Personal_Plan__c = personalPlans[0].Id, Description__c = 'Testing', Amount__c = 100,
                                               Period_Start__c = System.today().addDays(21), Period_End__c = System.today().addDays(40)));
        
        //Start testing from here
        Test.startTest();
        
        //Insert
        insert personalGoals;
        
        //Query Through Personal Goal
        List<Personal_Goal__c> pGCount = [Select Id From Personal_Goal__c];
        
        //Assert for Result
        System.assertEquals(5, pGCount.size());
        
        //Stop Testing here
        Test.stopTest();
        
    }
    
    //Test method for createConditionsForPG method
    static testMethod void testcreateConditionsForPG(){
        
        //List of Goal Type
        List<Goal_Type__c> goalTypes = [Select Id From Goal_Type__c];
        
        //List of Standard Goal
        List<Standard_Goal__c> standardGoals = [Select Id From Standard_Goal__c];
        
        //List of Standard Goal Detail
        List<Standard_Goal_Detail__c> standardGoalDetails = [Select Id From Standard_Goal_Detail__c];
       
        //List of record type
        List<RecordType> recordTypes = [select Id, DeveloperName From RecordType Where SObjectType = 'Personal_Goal__c' 
                                        AND DeveloperName IN ('Personal_Goal', 'Proposal') ORDER BY DeveloperName ASC LIMIT 2];

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
        
        //Insert Program Pespective
        insert programPerspectives;
                
        //List of Condition                             
        List<Condition__c> conditions = new List<Condition__c>();
        
        conditions.add(new Condition__c(Name = 'condition1', Standard_Goal__c = standardGoals[0].Id, Collection_Perspective__c = programPerspectives[0].Id, Condition_Type__c = 'Exclude'));
        conditions.add(new Condition__c(Name = 'condition2', Standard_Goal__c = standardGoals[0].Id, Collection_Perspective__c = programPerspectives[0].Id, Condition_Type__c = 'Exclude'));
        conditions.add(new Condition__c(Name = 'condition3', Standard_Goal__c = standardGoals[1].Id, Collection_Perspective__c = programPerspectives[1].Id, Condition_Type__c = 'Exclude'));
        conditions.add(new Condition__c(Name = 'condition4', Standard_Goal__c = standardGoals[0].Id, Standard_Goal_Detail__c = standardGoalDetails[0].Id, Collection_Perspective__c = programPerspectives[0].Id, Condition_Type__c = 'Exclude'));
        conditions.add(new Condition__c(Name = 'condition5', Standard_Goal__c = standardGoals[2].Id, Standard_Goal_Detail__c = standardGoalDetails[0].Id, Collection_Perspective__c = programPerspectives[1].Id, Condition_Type__c = 'Exclude'));
        
        //Insert 
        insert conditions;
        
        //Create Personal Goal
        List<Personal_Goal__c> personalGoals = new List<Personal_Goal__c>();
        
        //Add new Personal Goal in list
        personalGoals.add(new Personal_Goal__c(Name = 'PersonalGoal1', Goal_Type__c = goalTypes[0].Id, Active__c = true, RecordTypeId = recordTypes[0].Id,
                                               Standard_Goal__c = standardGoals[0].Id, Standard_Goal_Detail__c = standardGoalDetails[0].Id, Description__c = 'Testing', Amount__c = 100, 
                                               Period_Start__c = System.today().addDays(1), Period_End__c = System.today().addDays(10)));
        //Add new Personal Goal in list
        personalGoals.add(new Personal_Goal__c(Name = 'PersonalGoal2', Goal_Type__c = goalTypes[0].Id, Active__c = true, RecordTypeId = recordTypes[0].Id,
                                               Standard_Goal__c = standardGoals[1].Id, Standard_Goal_Detail__c = standardGoalDetails[1].Id, Description__c = 'Testing', Amount__c = 100,
                                               Period_Start__c = System.today().addDays(12), Period_End__c = System.today().addDays(20)));
        //Add new Personal Goal in list
        personalGoals.add(new Personal_Goal__c(Name = 'PersonalGoal3', Goal_Type__c = goalTypes[0].Id, Active__c = true, RecordTypeId = recordTypes[1].Id,
                                               Standard_Goal__c = standardGoals[2].Id, Standard_Goal_Detail__c = standardGoalDetails[2].Id, Description__c = 'Testing', Amount__c = 100,
                                               Period_Start__c = System.today().addDays(21), Period_End__c = System.today().addDays(40)));
        
        //Create Personal Goal
        List<Personal_Goal__c> pGWithPrGList = new List<Personal_Goal__c>();
        
        //Start testing from here
        Test.startTest();

        //Insert
        insert personalGoals;
        /*
        //Add new Personal Goal in list
        pGWithPrGList.add(new Personal_Goal__c(Name = 'PersonalGoal1', Goal_Type__c = goalTypes[0].Id, Active__c = true, RecordTypeId = recordTypes[1].Id,
                                               Primary_Goal__c = personalGoals[0].Id, Description__c = 'Testing', Amount__c = 100, 
                                               Period_Start__c = System.today().addDays(1), Period_End__c = System.today().addDays(10)));
        //Add new Personal Goal in list
        pGWithPrGList.add(new Personal_Goal__c(Name = 'PersonalGoal2', Goal_Type__c = goalTypes[0].Id, Active__c = true, RecordTypeId = recordTypes[1].Id,
                                               Primary_Goal__c = personalGoals[1].Id, Description__c = 'Testing', Amount__c = 100,
                                               Period_Start__c = System.today().addDays(12), Period_End__c = System.today().addDays(20)));
        
        //Query through Condition
        List<Condition__c> conditionsList = [Select Id, Personal_Goal__c From Condition__c Where Personal_Goal__c IN : personalGoals];
        
        //Assert for result
        System.assertEquals(5,conditionsList.size());
        
        //Update personal goal
        personalGoals[0].Name = 'testing1';
        
        //Update
        update personalGoals;
        
        //Query Through Condition
        List<Condition__c> conditionsL = [Select Id, Personal_Goal__c From Condition__c Where Personal_Goal__c IN : personalGoals];
        
        //Assert for result
        System.assertEquals(5, conditionsL.size());
        
        //Insert
        insert pGWithPrGList; 
        
        //Query through Condition
        List<Condition__c> conditionRecords = [Select Id, Personal_Goal__c From Condition__c Where Personal_Goal__c IN : pGWithPrGList];
        
        //Assert for result
        System.assertEquals(5,conditionRecords.size());
        */
        //Stop testing from here
        Test.stopTest();
    }
    
    //Test method for activateProposals method
    static testMethod void myUnitTest2() {

        //List of Standard Goal
        List<Standard_Goal__c> standardGoals = [Select Id From Standard_Goal__c];

        //List of Standard Goal Detail
        List<Standard_Goal_Detail__c> standardGoalDetails = [Select Id From Standard_Goal_Detail__c];

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

        //Insert Program Pespective
        insert programPerspectives;
        
        //List of Goal Type
        List<Goal_Type__c> goalTypes = [Select Id From Goal_Type__c];
           
        //List of Personal Plan
        List<Personal_Plan__c> personalPlans = [Select Id From Personal_Plan__c];
           
        //List of record type
        List<RecordType> recordTypes = [Select Id, DeveloperName From RecordType Where SObjectType = 'Personal_Goal__c' 
                                            AND DeveloperName IN ('Personal_Goal', 'Proposal') ORDER BY DeveloperName ASC LIMIT 2];
            
        //Create Personal Goal
        List<Personal_Goal__c> personalGoals = new List<Personal_Goal__c>();
            
        //Add new Personal Goal in list
        personalGoals.add(new Personal_Goal__c(Name = 'PersonalGoal1', Active__c = true, Goal_Type__c = goalTypes[0].Id, RecordTypeId = recordTypes[0].Id,
                                               Standard_Goal__c = standardGoals[0].Id, Description__c = 'Testing', Amount__c = 100,  
                                               Period_Start__c = System.today().addDays(1), Period_End__c = System.today().addDays(10)));
        
        //Insert
        insert personalGoals;
        
        //Create Personal Goal
        List<Personal_Goal__c> pGwithProposals = new List<Personal_Goal__c>();
        
        
        //Add new Personal Goal in list
        pGwithProposals.add(new Personal_Goal__c(Name = 'PersonalGoal2', Active__c = true, Goal_Type__c = goalTypes[0].Id, RecordTypeId = recordTypes[1].Id,
                                                 Primary_Goal__c = personalGoals[0].Id,  Description__c = 'Testing', Amount__c = 10011, 
                                                 Period_Start__c = System.today().addDays(11), Period_End__c = System.today().addDays(20)));
        
        //Add new Personal Goal in list
        pGwithProposals.add(new Personal_Goal__c(Name = 'PersonalGoal3',  Active__c = true, Goal_Type__c = goalTypes[0].Id, RecordTypeId = recordTypes[1].Id,
                                                 Primary_Goal__c = personalGoals[0].Id,  Description__c = 'Testing', Amount__c = 10012, 
                                                 Period_Start__c = System.today().addDays(11), Period_End__c = System.today().addDays(20)));
        
        //Insert 
        insert pGwithProposals;

        List<Personal_Goal__c> tests = [Select Id from Personal_Goal__c];
        System.assertEquals(4, tests.size());
        
        //List of Condition                             
        List<Condition__c> conditions = new List<Condition__c>();

        conditions.add(new Condition__c(Name = 'condition1', Personal_Goal__c = pGwithProposals[0].Id, Collection_Perspective__c = programPerspectives[1].Id, Condition_Type__c = 'Exclude'));
        conditions.add(new Condition__c(Name = 'condition2', Personal_Goal__c = pGwithProposals[0].Id, Collection_Perspective__c = programPerspectives[0].Id, Condition_Type__c = 'Include'));
        conditions.add(new Condition__c(Name = 'condition3', Personal_Goal__c = pGwithProposals[1].Id, Collection_Perspective__c = programPerspectives[0].Id, Condition_Type__c = 'Exclude'));
        conditions.add(new Condition__c(Name = 'condition4', Personal_Goal__c = pGwithProposals[1].Id, Collection_Perspective__c = programPerspectives[1].Id, Condition_Type__c = 'Include'));
        conditions.add(new Condition__c(Name = 'condition5', Personal_Goal__c = personalGoals[0].Id, Collection_Perspective__c = programPerspectives[0].Id, Condition_Type__c = 'Exclude'));
        
        //Insert  
        insert conditions;

        //Start testing from here
        Test.startTest();
        
        //Update Proposals Active field to true (Old = false)
        pGwithProposals[1].Active__c = true;
        
        //Update
        update pGwithProposals;

        //Query Through Personal Goal
        List<Personal_Goal__c> pG = [Select Id, Primary_Goal__c, Active_Proposal__c, Active__c From Personal_Goal__c order by CreatedDate];

        //Assert For Result
        System.assertEquals(personalGoals[0].Id, pG[1].Primary_Goal__c);
        System.assertEquals(personalGoals[0].Id, pG[2].Primary_Goal__c);
        System.assertEquals(true, pG[1].Active__c);
        
        //Query through Condition
        List<Condition__c> conditionRecords = [Select Id, Personal_Goal__c, Name From Condition__c Where Personal_Goal__c IN : pGwithProposals];
        
        System.assertEquals(4 , conditionRecords.size());
        
        //
        PersonalGoalTriggerHelper.executeActiveProposals = true;
        
        //Update Proposals Active field to true (Old = false)
        pGwithProposals[0].Active__c = true;
        
        //Update
        update pGwithProposals;
        
        //Query Through Personal Goals
        List<Personal_Goal__c> pGs = [Select Id, Primary_Goal__c, Active_Proposal__c, Active__c From Personal_Goal__c order by CreatedDate];
                
        //Query through Condition for Proposals type
        List<Condition__c> conditionss = [Select Id, Personal_Goal__c, Name From Condition__c Where Personal_Goal__c IN : pGwithProposals];
        
        //Query through Condition for Personal Goal Type
        List<Condition__c> conditionPG = [Select Id, Personal_Goal__c, Name From Condition__c Where Personal_Goal__c IN : personalGoals];
        
        //Assert for results
        System.assertEquals(personalGoals[0].Id, pGs[1].Primary_Goal__c);
        System.assertEquals(personalGoals[0].Id, pGs[2].Primary_Goal__c);
        System.assertEquals(4 , conditionss.size());
        System.assertEquals(1 , conditionPG.size());
        
        //Set flag value
        PersonalGoalTriggerHelper.executeActiveProposals = true;
        
        //Set proposal goal to true
        pGwithProposals[0].Active__c = true;
        pGwithProposals[1].Active__c = true;
        
        //Update
        update pGwithProposals;
        
        
        //Query to fetch record type for personal goal record type
        List<Personal_Goal__c> personalRT = [Select Id, Name, Amount__c , Period_Start__c, Period_End__c, Active_Proposal__c, RecordTypeId From Personal_Goal__c Where RecordTypeId =: recordTypes[0].Id];
        
        //Assert for result
        System.assertEquals(1 , personalRT.size());
        
        //Query to fetch record type for personal goal record type
        List<Personal_Goal__c> personalRTss = [Select Id, Name, Amount__c , Active__c, Period_Start__c, Period_End__c, Active_Proposal__c, RecordTypeId From Personal_Goal__c Where RecordTypeId =: recordTypes[1].Id];
        
        System.debug('personalRTss:::::' + personalRTss);
        System.debug('pGwithProposals' +personalRTss[0].Active__c);
        System.debug('pGwithProposals::' +personalRTss[0].RecordTypeId); 
        
        //Assign Active Proposal to proposal goal 
        personalRT[0].Active_Proposal__c = pGwithProposals[0].Id;
        
        //Set flag value
        PersonalGoalTriggerHelper.executeActiveProposals = true;
        
        //update personal goal
        update personalRT;
        
        //Query to fetch record type for personal goal record type
        List<Personal_Goal__c> personalRTs = [Select Id, Name, Amount__c , Period_Start__c, Period_End__c, Active_Proposal__c, RecordTypeId From Personal_Goal__c Where RecordTypeId =: recordTypes[0].Id];
        
        //System.debug('personalRTpersonalRT ::::'  + personalRT);
    
        System.assertEquals(personalRTs[0].Amount__c, pGwithProposals[0].Amount__c);
        System.assertEquals(personalRTs[0].Period_Start__c, pGwithProposals[0].Period_Start__c);
        System.assertEquals(personalRTs[0].Period_End__c, pGwithProposals[0].Period_End__c);
                
        //Update Proposals Active field to false
        pGwithProposals[0].Active__c = false;
        pGwithProposals[1].Active__c = false;
        
        //Update proposal goal
        update pGwithProposals;
        
        //Update Proposals Active field to true (Old = false)
        pGwithProposals[0].Active__c = true;
        pGwithProposals[1].Active__c = true;
                
        //Update proposal goal
        update pGwithProposals;
                
        //System.assertEquals(personalGoals[0].Id, pGs[1].Primary_Goal__c);
    
        //System.assertEquals();
        
        //Stop testing from here
        Test.stopTest();
        
    }   
}