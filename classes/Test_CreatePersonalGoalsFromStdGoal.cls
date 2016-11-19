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
private class Test_CreatePersonalGoalsFromStdGoal {  
  /**
    *   Purpose         :   Test class for DefineStandardGoals Page.
    *            
    *   Create By       :   Subhash Garhwal
    *
    *   Created Date    :   09/02/2015
    *
    *   Revision Log    :   V_1.0 - Created - CR-20150729-9114 
    *                   :   V_1.1 - Modified - Rajeev Jain - 05/12/2016 - ISSP Deployment E - Improved asserts
    * 					:	V_1.2 - Modified - Rajeev Jain - 08/01/2016 - Fixed Run ALLTest failure issue, improved asserts.
    * 
    *   Coverage        :   V_1.0 - 75%
    **/
    
    //Setup test data from class
    @testSetup static void setupTestDataForClass(){
    
        //Create an institution
        Account account = TestUtilities.CreateNewAccount(false);
        
        //Insert
        insert account;
        
        //Create Contact
        List<Contact> contacts = new List<Contact>();
        
        //Add new contact in list
        contacts.add(new Contact(FirstName = 'Test', LastName = 'Contact', Email = 'test@test.com', AccountId = account.Id, 
                                      Employee_User_Record__c = Userinfo.getUserId()));
        contacts.add(new Contact(FirstName = 'Test1', LastName = 'Contact1', Email = 'test1@test.com', AccountId = account.Id, 
                                      Employee_User_Record__c = Userinfo.getUserId()));
        contacts.add(new Contact(FirstName = 'Test2', LastName = 'Contact2', Email = 'test2@test.com', AccountId = account.Id, 
                                      Employee_User_Record__c = Userinfo.getUserId()));
        contacts.add(new Contact(FirstName = 'Test3', LastName = 'Contact3', Email = 'test3@test.com', AccountId = account.Id, 
                                      Employee_User_Record__c = Userinfo.getUserId()));
        
        //Insert
        insert contacts;
        
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
    
        //Create Goal Type
        List<Goal_Type__c> goalTypes = new List<Goal_Type__c>();
        
        //Add new goal type in list
        goalTypes.add(new Goal_Type__c(Name = 'GoalType1', Active__c = true, Standard_Goal__c = true, Base_Process__c = 'NBB', Description__c = 'Testing of Goal Type',
                                       Discount_Type__c = ISSPConstants.GOAL_TYPE_DISCOUNT_TYPE_MULTIPLIERS));
        goalTypes.add(new Goal_Type__c(Name = 'GoalType2', Active__c = true, Standard_Goal__c = true, Base_Process__c = 'CM', Description__c = 'Testing of Goal Types'));
        goalTypes.add(new Goal_Type__c(Name = 'GoalType3', Active__c = true, Standard_Goal__c = false, Base_Process__c = 'Activity', Description__c = 'Testing of Goal'));
        goalTypes.add(new Goal_Type__c(Name = 'GoalType4', Active__c = true, Standard_Goal__c = false, Base_Process__c = 'Renewal', Description__c = 'Goal Type',
                                       Discount_Type__c = ISSPConstants.GOAL_TYPE_DISCOUNT_TYPE_MULTIPLIERS));
        
        //Insert 
        insert goalTypes;
        
        //Listt of Value Types
        List<Value_Type__c> valueTypes = new List<Value_Type__c>();
        
        //Add value type in list
        valueTypes.add(new Value_Type__c(Name = ISSPConstants.VALUE_TYPE_NAME_JOB_TITLE , Values_Permitted__c = 'Date',Category__c = 'Sales Role', Active__c = true, Rule__c = 'Staff member may have multiple, non-overlapping records for this category' ));
        valueTypes.add(new Value_Type__c(Name = 'BT', Values_Permitted__c = 'Text', Category__c = 'Business Title', Active__c = true, Adjustment__c = 40));
        valueTypes.add(new Value_Type__c(Name = 'Sales Role', Values_Permitted__c = 'Text', Category__c = 'Sales Role', Active__c = true));
        valueTypes.add(new Value_Type__c(Name = 'Tenure', Values_Permitted__c = 'Text', Category__c = 'Sales Role', Active__c = true));
        valueTypes.add(new Value_Type__c(Name = 'BT 1', Values_Permitted__c = 'Text', Category__c = 'Business Title', Active__c = true, Adjustment__c = 44));
        valueTypes.add(new Value_Type__c(Values_Permitted__c = 'Text',Category__c = 'Sales Role', Active__c = true, Rule__c = 'Staff member may have unlimited, overlapping records for this attribute' ));
        valueTypes.add(new Value_Type__c(Values_Permitted__c = 'Text', Category__c = 'Incentive Role', Active__c = true));
        
        //Insert
        insert valueTypes;
        
        //List of Staff History
        List<Staff_History__c> staffHistory = new List<Staff_History__c>();

        //Add new Staff History in list.
        staffHistory.add(new Staff_History__c(Staff_Member__c = contacts[0].Id, Value_Type__c = valueTypes[0].Id, Start_Date__c = System.today().addDays(-1), End_Date__c = System.today().addDays(20), Date_Value__c = System.today()));
        staffHistory.add(new Staff_History__c(Staff_Member__c = contacts[0].Id, Value_Type__c = valueTypes[1].Id, Start_Date__c = System.today().addDays(-5), End_Date__c = System.today().addDays(19), Text_Value__c = 'Testing'));
        staffHistory.add(new Staff_History__c(Staff_Member__c = contacts[0].Id, Value_Type__c = valueTypes[2].Id, Start_Date__c = System.today().addDays(-11), End_Date__c = System.today().addDays(23), Text_Value__c = 'Testing2'));
        staffHistory.add(new Staff_History__c(Staff_Member__c = contacts[0].Id, Value_Type__c = valueTypes[3].Id, Start_Date__c = System.today().addDays(-21), End_Date__c = System.today().addDays(32), Text_Value__c = 'Testing3'));
        staffHistory.add(new Staff_History__c(Staff_Member__c = contacts[0].Id, Value_Type__c = valueTypes[4].Id, Start_Date__c = System.today().addDays(-21), End_Date__c = System.today().addDays(30), Text_Value__c = 'Testing3'));
        staffHistory.add(new Staff_History__c(Staff_Member__c = contacts[0].Id, Value_Type__c = valueTypes[5].Id, Start_Date__c = System.today().addDays(-1), End_Date__c = System.today().addDays(9), Text_Value__c = 'Testing5'));
        staffHistory.add(new Staff_History__c(Staff_Member__c = contacts[0].Id, Value_Type__c = valueTypes[6].Id, Start_Date__c = System.today().addDays(-1), End_Date__c = System.today().addDays(5), Text_Value__c = 'Testing5'));
        
        //Insert 
        insert staffHistory;
        
        //Create list of rate template
        List<Rate_Template__c> rTs = new List<Rate_Template__c>();
        
        //Add Rate Template in list
        rTs.add(new Rate_Template__c(Name = 'TestRT1'));
        rTs.add(new Rate_Template__c(Name = 'TestRT2'));
        rTs.add(new Rate_Template__c(Name = 'TestRT3'));
        
        //Insert
        insert rTs;

        //Create Standard Goals
        List<Standard_Goal__c> standardGoals = new List<Standard_Goal__c>();
        
        //Add new Standard Goals in list
        standardGoals.add(new Standard_Goal__c(Name = 'StandardGoal1', Active__c = true, Amount__c = 10000000, Business_Owner__c = contacts[0].Id,
                                               Payee__c = contacts[0].Id, Description__c = 'Testing of Standard Goal 1', Goal_Type__c = goalTypes[0].Id, 
                                               Period_Start__c = System.today().addDays(-10), Period_End__c = System.today().addDays(100),
                                               Standard_Type__c = ISSPConstants.STANDARD_GOAL_STANDARD_TYPE_PERSONAL));
                                               
        standardGoals.add(new Standard_Goal__c(Name = 'StandardGoal2', Active__c = true, Counter__c = 2000000, Business_Owner__c = contacts[0].Id,
                                               Payee__c = contacts[0].Id,Description__c = 'Testing of Standard Goal', Goal_Type__c = goalTypes[0].Id,
                                               Period_Start__c = System.today().addDays(-10), Period_End__c = System.today().addDays(100)));
        
        standardGoals.add(new Standard_Goal__c(Name = 'StandardGoal3', Active__c = true, Percent__c = 100, Business_Owner__c = contacts[0].Id,
                                               Payee__c = contacts[0].Id,Description__c = 'Testing of Standard Goal 3', Goal_Type__c = goalTypes[1].Id, 
                                               Period_Start__c = System.today().addDays(-10), Period_End__c = System.today().addDays(100),
                                               Standard_Type__c = ISSPConstants.STANDARD_GOAL_STANDARD_TYPE_PERSONAL));
        //Insert 
        insert standardGoals;
        
        //Standard goal detail record for the  baseline.
        Standard_Goal_Detail__c stDForBaseLine = new Standard_Goal_Detail__c(Name = 'StandardGoalDetail7',   Active__c = true, Description__c = 'Testing 7',Summary__c = true,
                                                            Standard_Goal__c = standardGoals[0].Id, Goal_Type__c = goalTypes[3].Id,Amount__c = 100000);
        insert stDForBaseLine;
        
        //Create Standard Goal Details
        List<Standard_Goal_Detail__c> standardGoalDetails = new List<Standard_Goal_Detail__c>();
        
        //Add new Standard Goal Details in list
        standardGoalDetails.add(new Standard_Goal_Detail__c(Name = 'StandardGoalDetail1',   Active__c = true, Description__c = 'Testing 1',Summary__c = true,
                                                            Standard_Goal__c = standardGoals[0].Id, Goal_Type__c = goalTypes[3].Id,Amount__c = 100000));
        standardGoalDetails.add(new Standard_Goal_Detail__c(Name = 'StandardGoalDetail2', Baseline__c = stDForBaseLine.Id,  Active__c = true, Description__c = 'Testing 2',Summary__c = false,
                                                            Standard_Goal__c = standardGoals[0].Id, Goal_Type__c = goalTypes[3].Id,Amount__c = 100000));
        
        standardGoalDetails.add(new Standard_Goal_Detail__c(Name = 'StandardGoalDetail3',  Active__c = true, Description__c = 'Testing 3',Summary__c = true,
                                                            Standard_Goal__c = standardGoals[1].Id, Goal_Type__c = goalTypes[3].Id, Count__c = 10000));
    
        standardGoalDetails.add(new Standard_Goal_Detail__c(Name = 'StandardGoalDetail4',  Active__c = true, Description__c = 'Testing 4',Summary__c = false,
                                                            Standard_Goal__c = standardGoals[1].Id, Goal_Type__c = goalTypes[3].Id, Count__c = 10000));
        
        standardGoalDetails.add(new Standard_Goal_Detail__c(Name = 'StandardGoalDetail5', Active__c = true, Description__c = 'Testing 5',Summary__c = true,
                                                            Standard_Goal__c = standardGoals[2].Id, Goal_Type__c = goalTypes[3].Id, Percent__c = 100));
       
        standardGoalDetails.add(new Standard_Goal_Detail__c(Name = 'StandardGoalDetail6',  Active__c = true, Description__c = 'Testing 6',Summary__c = false,
                                                            Standard_Goal__c = standardGoals[2].Id, Goal_Type__c = goalTypes[3].Id, Percent__c = 100));
        
         //Insert 
        insert standardGoalDetails;
        
      
        
        //Create Standard Goal Detail Pacing
        List<Standard_Goal_Detail_Pacing__c> sGDPacings = new List<Standard_Goal_Detail_Pacing__c>();
        
        //Add standard goal detail pacing in list
        //Amount
        sGDPacings.add(new Standard_Goal_Detail_Pacing__c(Name = 'TestSGDP1', Standard_Goal_Detail__c = standardGoalDetails[0].Id, 
                                                          Standard_Goal__c = standardGoals[0].Id, Description__c = 'T', 
                                                          Period_Start__c = System.today().addDays(11),Period_End__c = System.today().addDays(20),
                                                          Percent_Manual__c = 50));
        
        sGDPacings.add(new Standard_Goal_Detail_Pacing__c(Name = 'TestSGDP2', Standard_Goal_Detail__c = standardGoalDetails[0].Id, 
                                                          Standard_Goal__c = standardGoals[0].Id, Description__c = 'Q', 
                                                          Period_Start__c = System.today().addDays(21), Period_End__c = System.today().addDays(40),
                                                          Percent_Manual__c = 50));
        
        sGDPacings.add(new Standard_Goal_Detail_Pacing__c(Name = 'TestSGDP3', Standard_Goal_Detail__c = standardGoalDetails[1].Id, 
                                                          Standard_Goal__c = standardGoals[0].Id, Description__c = 'P', 
                                                          Period_Start__c = System.today().addDays(41),Period_End__c = System.today().addDays(50), 
                                                          Percent_Manual__c = 50));
        
        sGDPacings.add(new Standard_Goal_Detail_Pacing__c(Name = 'TestSGDP4', Standard_Goal_Detail__c = standardGoalDetails[1].Id, 
                                                          Standard_Goal__c = standardGoals[0].Id, Description__c = 'M', 
                                                          Period_Start__c = System.today().addDays(51), Period_End__c = System.today().addDays(60),
                                                          Percent_Manual__c = 50));
        //Count
        sGDPacings.add(new Standard_Goal_Detail_Pacing__c(Name = 'TestSGDP1', Standard_Goal_Detail__c = standardGoalDetails[2].Id, 
                                                          Standard_Goal__c = standardGoals[1].Id, Description__c = 'Count 1', 
                                                          Period_Start__c = System.today().addDays(61),Period_End__c = System.today().addDays(70),
                                                          Percent_Manual__c = 100));
                                                          
        sGDPacings.add(new Standard_Goal_Detail_Pacing__c(Name = 'TestSGDP3', Standard_Goal_Detail__c = standardGoalDetails[3].Id, 
                                                          Standard_Goal__c = standardGoals[1].Id, Description__c = 'Count 2', 
                                                          Period_Start__c = System.today().addDays(71),Period_End__c = System.today().addDays(80), 
                                                          Percent_Manual__c = 100));
        
        //Persent
        sGDPacings.add(new Standard_Goal_Detail_Pacing__c(Name = 'TestSGDP1', Standard_Goal_Detail__c = standardGoalDetails[4].Id, 
                                                          Standard_Goal__c = standardGoals[2].Id, Description__c = 'Persent 1', 
                                                          Period_Start__c = System.today().addDays(81),Period_End__c = System.today().addDays(90),
                                                          Percent_Manual__c = 100));
                                                          
        sGDPacings.add(new Standard_Goal_Detail_Pacing__c(Name = 'TestSGDP3', Standard_Goal_Detail__c = standardGoalDetails[5].Id, 
                                                          Standard_Goal__c = standardGoals[2].Id, Description__c = 'Persent 2', 
                                                          Period_Start__c = System.today().addDays(91),Period_End__c = System.today().addDays(100), 
                                                          Percent_Manual__c = 100));
        //Insert   
        insert sGDPacings;
        
        //List of Condition                             
        List<Condition__c> conditions = new List<Condition__c>();
        
        //Add new condition in list
        conditions.add(new Condition__c(Name = 'condition1', Standard_Goal__c = standardGoals[0].Id, Collection_Perspective__c = programPerspectives[0].Id, Condition_Type__c = 'Exclude'));
        conditions.add(new Condition__c(Name = 'condition2', Standard_Goal__c = standardGoals[0].Id, Collection_Perspective__c = programPerspectives[0].Id, Condition_Type__c = 'Exclude'));
        conditions.add(new Condition__c(Name = 'condition3', Standard_Goal__c = standardGoals[1].Id, Collection_Perspective__c = programPerspectives[1].Id, Condition_Type__c = 'Exclude'));
        conditions.add(new Condition__c(Name = 'condition4', Standard_Goal__c = standardGoals[0].Id, Collection_Perspective__c = programPerspectives[0].Id, 
                                        Standard_Goal_Detail__c = standardGoalDetails[0].Id, Condition_Type__c = 'Exclude'));
        conditions.add(new Condition__c(Name = 'condition5', Standard_Goal__c = standardGoals[2].Id, Collection_Perspective__c = programPerspectives[1].Id, 
                                        Standard_Goal_Detail__c = standardGoalDetails[1].Id, Condition_Type__c = 'Exclude'));
        
        //Insert 
        insert conditions;
        
        //List of Goal Template Business Title
        List<Standard_Goal_Sales_Role__c> gTBTs = new List<Standard_Goal_Sales_Role__c>();
        
        //Add GTBTs in list
        gTBTs.add(new Standard_Goal_Sales_Role__c(Standard_Goal__c = standardGoals[0].Id, Sales_Role__c = valueTypes[1].Id));
        gTBTs.add(new Standard_Goal_Sales_Role__c(Standard_Goal__c = standardGoals[0].Id, Sales_Role__c = valueTypes[4].Id));
        gTBTs.add(new Standard_Goal_Sales_Role__c(Standard_Goal__c = standardGoals[1].Id, Sales_Role__c = valueTypes[1].Id));
        gTBTs.add(new Standard_Goal_Sales_Role__c(Standard_Goal__c = standardGoals[2].Id, Sales_Role__c = valueTypes[4].Id));
        
        //Insert
        insert gTBTs;
        
        //List of record type
        List<RecordType> recordTypes = [select Id, DeveloperName From RecordType Where SObjectType = 'Personal_Goal__c' 
                                        AND DeveloperName IN ('Personal_Goal', 'Proposal') ORDER BY DeveloperName ASC LIMIT 2];
        
        
        //Create Personal Plan
        List<Personal_Plan__c> personalPlans = new List<Personal_Plan__c>();
        
        //Add new Personal Plan in list
        personalPlans.add(new Personal_Plan__c(Name = 'PersonalPlan1', Active__c = true, Description__c = 'Testing', Staff_Member__c = contacts[0].Id,
                                              Plan_Start__c = System.today().addDays(1), Plan_End__c = System.today().addDays(10)));
        personalPlans.add(new Personal_Plan__c(Name = 'PersonalPlan2', Active__c = true, Description__c = 'Testing', Staff_Member__c = contacts[0].Id,
                                              Plan_Start__c = System.today().addDays(12), Plan_End__c = System.today().addDays(18)));
        personalPlans.add(new Personal_Plan__c(Name = 'PersonalPlan3', Active__c = true, Description__c = 'Testing', Staff_Member__c = contacts[0].Id,
                                              Plan_Start__c = System.today().addDays(20),  Plan_End__c = System.today().addDays(25)));
        
        //Insert
        insert personalPlans;
        
        //Create Personal Goal Instance
        List<Personal_Goal__c> personalGoals = new List<Personal_Goal__c>();
        
        //Create Personal Goal Instance   
        personalGoals.add(new Personal_Goal__c(Name = 'PersonalGoal1', Goal_Type__c = goalTypes[0].Id, Active__c = true, 
                                                             RecordTypeId = recordTypes[0].Id, Personal_Plan__c = personalPlans[0].Id, 
                                                             Description__c = 'd', Amount__c = 1000000, Payee__c = contacts[0].Id,
                                                             Standard_Goal__c = standardGoals[0].Id, Value_Type__c = valueTypes[6].Id,Rate_Template__c = rTs[0].Id, 
                                                             Status__c = ISSPConstants.PERSONAL_GOAL_STATUS_AVAILABLE,
                                                             Period_Start__c = System.today().addDays(11), Period_End__c = System.today().addDays(20)));
        
        personalGoals.add(new Personal_Goal__c(Name = 'PersonalGoal2', Goal_Type__c = goalTypes[0].Id, Active__c = true, 
                                                             RecordTypeId = recordTypes[0].Id, Personal_Plan__c = personalPlans[0].Id, 
                                                             Description__c = 'T', Amount__c = 1000000, Payee__c = contacts[0].Id,
                                                             Standard_Goal__c = standardGoals[0].Id, Business_Title__c = valueTypes[1].Id,Standard_Goal_Detail__c =  standardGoalDetails[0].Id, 
                                                             Status__c = ISSPConstants.PERSONAL_GOAL_STATUS_AVAILABLE,
                                                             Period_Start__c = System.today(), Period_End__c = System.today().addDays(40)));
        
        //Insert
        insert personalGoals;
        
        //LiSt of Relationship Type
        List<Relationship_Type__c> relationshipTypes = new List<Relationship_Type__c>();
        
        //Add Record in List
        relationshipTypes.add(new Relationship_Type__c(Business_Owner__c = contacts[0].Id, Name_When_From__c = 'Testing From', Name_When_To__c = 'Testing To', Active__c = true));
        relationshipTypes.add(new Relationship_Type__c(Business_Owner__c = contacts[0].Id, Name_When_From__c = 'Testing From', Name_When_To__c = 'Testing To', Active__c = true));
        relationshipTypes.add(new Relationship_Type__c(Business_Owner__c = contacts[1].Id, Name_When_From__c = 'Testing From', Name_When_To__c = 'Testing To', Active__c = true));
        
        //Insert
        insert relationshipTypes;
        
        //List of Staff Relationship
        List<Staff_Relationship__c> staffRelationships = new List<Staff_Relationship__c>();
        
        //Add Record in list
        staffRelationships.add(new Staff_Relationship__c(Relationship__c = relationshipTypes[0].Id,Start_Date__c = System.today().addDays(1), From__c = contacts[0].Id, To__c = contacts[1].Id ));
        staffRelationships.add(new Staff_Relationship__c(Relationship__c = relationshipTypes[1].Id,Start_Date__c = System.today().addDays(3), From__c = contacts[1].Id, To__c = contacts[0].Id ));
        staffRelationships.add(new Staff_Relationship__c(Relationship__c = relationshipTypes[2].Id,Start_Date__c = System.today().addDays(5), From__c = contacts[1].Id, To__c = contacts[2].Id ));
        
        //Insert
        insert staffRelationships;
        
        //Create Personal Goal Relationship
        List<Personal_Goal_Relationship__c> personalGoalRelationships = new List<Personal_Goal_Relationship__c>();
        
        //Add record in list
        personalGoalRelationships.add(new Personal_Goal_Relationship__c(Name = 'PGR 1', Personal_Goal__c = personalGoals[0].Id, Relationship__c = Staffrelationships[0].Id));
        personalGoalRelationships.add(new Personal_Goal_Relationship__c(Name = 'PGR 2', Personal_Goal__c = personalGoals[1].Id, Relationship__c = Staffrelationships[0].Id));
        personalGoalRelationships.add(new Personal_Goal_Relationship__c(Name = 'PGR 3', Personal_Goal__c = personalGoals[0].Id, Relationship__c = Staffrelationships[1].Id));
        personalGoalRelationships.add(new Personal_Goal_Relationship__c(Name = 'PGR 4', Personal_Goal__c = personalGoals[1].Id, Relationship__c = Staffrelationships[1].Id));
        
        //Insert 
        insert personalGoalRelationships;
        
        //Create Goal Type Business Title
        List<Goal_Type_Business_Title__c> goalTypeBusinessTitles = new List<Goal_Type_Business_Title__c>();
        
        //Add Goal Type Business Title in list
        goalTypeBusinessTitles.add(new Goal_Type_Business_Title__c(Name = 'Test', Business_Title__c = valueTypes[4].Id, Goal_Type__c = goalTypes[3].Id, Adjustment__c = 50));
        goalTypeBusinessTitles.add(new Goal_Type_Business_Title__c(Name = 'Test', Business_Title__c = valueTypes[4].Id, Goal_Type__c = goalTypes[0].Id, Adjustment__c = 50));
        goalTypeBusinessTitles.add(new Goal_Type_Business_Title__c(Name = 'Test', Business_Title__c = valueTypes[1].Id, Goal_Type__c = goalTypes[0].Id, Adjustment__c = 50));
        
        //Insert
        insert goalTypeBusinessTitles;
        
        //Assert  
        System.assert(goalTypeBusinessTitles.size() > 0);
        
        //Create Goal Template Detail Measurement Period Record
        List<Goal_Template_Detail_Measurement_Period__c> gTDMPeriods = new List<Goal_Template_Detail_Measurement_Period__c>();
        
        //Add Record in List
        gTDMPeriods.add(new Goal_Template_Detail_Measurement_Period__c(Name = 'gTDMP 1', Goal_Template_Detail__c = standardGoalDetails[0].Id, Measurement_Date__c = System.Today()));
        gTDMPeriods.add(new Goal_Template_Detail_Measurement_Period__c(Name = 'gTDMP 2', Goal_Template_Detail__c = standardGoalDetails[0].Id, Measurement_Date__c = System.Today().addDays(5)));
        gTDMPeriods.add(new Goal_Template_Detail_Measurement_Period__c(Name = 'gTDMP 3', Goal_Template_Detail__c = standardGoalDetails[1].Id, Measurement_Date__c = System.Today().addDays(10)));
        gTDMPeriods.add(new Goal_Template_Detail_Measurement_Period__c(Name = 'gTDMP 4', Goal_Template_Detail__c = standardGoalDetails[1].Id, Measurement_Date__c = System.Today().addDays(15)));
        
        //Insert
        insert gTDMPeriods;
        
        //Assert
        System.assert(gTDMPeriods.size() > 0);
        
        //List of Personal Goal Measurement Period
        List<Personal_Goal_Measurement_Period__c> pGMPeriods = new List<Personal_Goal_Measurement_Period__c>();
        
        //Added new Record in list
        pGMPeriods.add(new Personal_Goal_Measurement_Period__c(Name = 'PGMP 1', Personal_Goal__c = personalGoals[0].Id, Measurement_Date__c = System.today().addDays(-5)));
        pGMPeriods.add(new Personal_Goal_Measurement_Period__c(Name = 'PGMP 2', Personal_Goal__c = personalGoals[0].Id, Measurement_Date__c = System.today().addDays(5)));
        pGMPeriods.add(new Personal_Goal_Measurement_Period__c(Name = 'PGMP 3', Personal_Goal__c = personalGoals[1].Id, Measurement_Date__c = System.today().addDays(10)));
        pGMPeriods.add(new Personal_Goal_Measurement_Period__c(Name = 'PGMP 4', Personal_Goal__c = personalGoals[1].Id, Measurement_Date__c = System.today().addDays(15)));
        
        //Insert
        insert pGMPeriods;
        
        //Assert
        System.assert(pGMPeriods.size() > 0);
        
    }
    
   
    //Test methods for Amount GT
    static testMethod void myUnitTest1() {
        
        //Query to get Program Collection
        List<Program_Group__c> programCollectionsList = [Select Id, Name From Program_Group__c];
        
        //Assert
        System.assert(programCollectionsList.size() > 0);
        
        //Query to get Goal Type
        List<Goal_Type__c> goalTypesList = [Select Id, Name, Active__c, Standard_Goal__c, Base_Process__c, Description__c, Discount_Type__c From Goal_Type__c];
        
        //Assert
        System.assert(goalTypesList.size() > 0);
        
        //Query to get Standard Goals
        List<Standard_Goal__c> standardGoalsList = [Select Id, Name,Active__c,Amount__c,Business_Owner__c,Payee__c,Description__c,Goal_Type__c,
                                                    Period_Start__c, Period_End__c, Standard_Type__c From Standard_Goal__c];
        
        //Assert
        System.assert(standardGoalsList.size() > 0);
        
        //Query to get Standard Goal Details
        List<Standard_Goal_Detail__c> standardGoalDetailsList = [Select Id, Name,Active__c,Description__c,Summary__c,Standard_Goal__c,Goal_Type__c,
                                                                 Amount__c,Count__c From Standard_Goal_Detail__c];
        
        //Assert
        System.assert(standardGoalDetailsList.size() > 0);
        
        //Query to get Standard Goal Detail Pacing
        List<Standard_Goal_Detail_Pacing__c> sGDPacingsList = [Select Id, Name,Count_Manual__c,Standard_Goal_Detail__c,Standard_Goal__c,Description__c,
                                                               Period_Start__c,Period_End__c,Percent_Manual__c,Amount_Manual__c From Standard_Goal_Detail_Pacing__c];
        
        //Assert
        System.assert(sGDPacingsList.size() > 0);
        
        //List of record type
        List<RecordType> recordTypesList = [select Id, DeveloperName From RecordType Where SObjectType = 'Personal_Goal__c' 
                                            AND DeveloperName IN ('Personal_Goal', 'Proposal') ORDER BY DeveloperName ASC LIMIT 2];
         
         //Assert
        System.assert(recordTypesList.size() > 0);
                                       
        //Query to get Personal Goal Instance
        List<Personal_Goal__c> personalGoalsList = [Select Id,Name,Goal_Type__c,Active__c,RecordTypeId,Personal_Plan__c,Description__c,Amount__c,Payee__c,
                                                    Standard_Goal__c,Value_Type__c,Rate_Template__c,Status__c,Period_Start__c,Period_End__c,Business_Title__c,
                                                    Standard_Goal_Detail__c From Personal_Goal__c];
        
        //Assert
        System.assert(personalGoalsList.size() > 0);
        
        //Query to get of Value Types
        List<Value_Type__c> valueTypesList = [Select Id, Name, Values_Permitted__c,Category__c,Active__c,Rule__c,Adjustment__c From Value_Type__c];
        
        //Assert
        System.assert(valueTypesList.size() > 0);
        
        //Query to get rate template
        List<Rate_Template__c> rTsList = [Select Id, Name From Rate_Template__c];
        
        //Assert
        System.assert(rTsList.size() > 0);
        
        //List of Personal Goal Measurement Period
        List<Personal_Goal_Measurement_Period__c> pGMPeriodsList = [select Id,Name,Personal_Goal__c,Measurement_Date__c From Personal_Goal_Measurement_Period__c];
        
        //Assert
        System.assert(pGMPeriodsList.size() > 0);
        
        //Instance of controller
        CreatePersonalGoalsFromStdGoalController controller = new CreatePersonalGoalsFromStdGoalController();
        
        //Variable to hold limit to from select option
        controller.selectedLimitToValue = '1';
        
        //Assign values to Standard Goal
        controller.stdPersonalGoal.Standard_Goal__c = standardGoalsList[0].Id;
        
        //Calling controller method 
        controller.loadPayees();
        
        //Assert for results
        System.AssertEquals(1, controller.availablePayees.size());
        
        //Variable to hold limit to from select option
        controller.selectedLimitToValue = '';
        
        //Calling controller method 
        controller.loadPayees();
        
        //Assert for results
        System.AssertEquals(0, controller.availablePayees.size());
        
        //Variable to hold limit to from select option
        controller.selectedLimitToValue = '2';
        
        //Assign values to Standard Goal
        controller.stdPersonalGoal.Standard_Goal__c = standardGoalsList[0].Id;
        
        //Calling controller method 
        controller.loadPayees();
        
        //Assert for results
        System.AssertEquals(1, controller.availablePayees.size());
        
        //Variable to hold limit to from select options
        controller.selectedLimitToValue = '';
        
        //Calling controller method 
        controller.loadPayees();
        
        //Assert for results
        System.AssertEquals(0, controller.availablePayees.size());
        
        //Variable to hold limit to from select option
        controller.selectedLimitToValue = '3';
        
        //Assign value type
        controller.personalGoal.Value_Type__c = valueTypesList[0].Id;
        
        //Calling controller method
        controller.loadPayees();
        //controller.loadFilteredPayees();
        //Assert for results
        System.AssertEquals(1, controller.availablePayees.size());
        
        //Variable to hold limit to from select option
        controller.selectedLimitToValue = '2';
        
        //Assign values to Standard Goal
        controller.stdPersonalGoal.Standard_Goal__c = standardGoalsList[0].Id;
        
        //Calling controller method 
        controller.loadPayees();
        
        //Assert for results
        System.AssertEquals(1, controller.availablePayees.size());
        
        //Start Testing from here
        Test.startTest();
        
        //Variable to hold limit to from select option
        controller.selectedLimitToValue = '4';
        
        //Assign Standard Goal 
        controller.personalGoal.Business_Title__c = valueTypesList[1].Id;
        
        //Calling controller method 
        controller.loadFilteredPayees();
        
        //Assert for results
        System.AssertEquals(1, controller.availablePayees.size());
        
        //Variable to hold limit to from select option
        controller.selectedLimitToValue = '5';
        
        //Query on INCENTIV ROLE Value Type
        List<Value_Type__c> incentiveRoles = [select Id from Value_Type__c where Category__c = 'Incentive Role' LIMIT 1];
        
        controller.personalGoal.Value_Type__c = incentiveRoles[0].Id;
        
        //Calling controller method 
        controller.loadFilteredPayees();
        
        //Assert for results
        System.AssertEquals(1, controller.availablePayees.size());
       
        //Variable to hold limit to from select option
        controller.selectedLimitToValue = '6';
        
        //Assign rate template in personal goal 
        controller.personalGoal.Standard_Goal__c = standardGoalsList[0].Id;
        
        //Calling controller method 
        controller.loadFilteredPayees();
        
        //Assert for results
        System.AssertEquals(1, controller.availablePayees.size());
        
        //Variable to hold limit to from select option
        controller.selectedLimitToValue = '7';
        
        //Assign rate template in personal goal 
        controller.personalGoal.Rate_Template__c = rTsList[0].Id;
        
        //Calling controller method 
        controller.loadFilteredPayees();
        
        //Assert for results
        System.AssertEquals(1, controller.availablePayees.size());
        
        //Select payee from the list
        controller.availablePayees[0].selected = true;
        
        //Calling controller method 
        controller.selectPayee();
        
        //Assert for results
        System.AssertEquals(1, controller.selectedPayees.size());
         
        //Select payee from the list
        controller.selectedPayees[0].selected = true;
        
        //Calling controller method 
        controller.removeSelectedPayee();
        
        //Assert for results
        System.AssertEquals(0, controller.selectedPayees.size());
        System.AssertEquals(1, controller.availablePayees.size());
        
        //Variable to hold limit to from select option
        controller.selectedLimitToValue = '1';
        
        //Assign values to Standard Goal
        controller.stdPersonalGoal.Standard_Goal__c = standardGoalsList[0].Id;
        
        //Calling controller method 
        controller.loadPayees();
        
        //Assert for results
        System.AssertEquals(1, controller.availablePayees.size());
        
        //Select payee from the page list
        controller.availablePayees[0].selected = true;
        
        //Calling controller method 
        controller.selectPayee();
        
        //Assert for results
        System.AssertEquals(1, controller.selectedPayees.size());//TestContact contact[0].Id
        
        //Handle Individual Payee Selection
        controller.selectedLimitToValue = '8';
        
        //Populate Payee(With Matching with existing Staff Attributes) 
        //Query on Contact
        List<Contact> payees = [select Id from Contact where Name = :'Test Contact' order by Name ASC LIMIT 1];
        
        controller.personalGoal.Payee__c = payees[0].Id; 
        
        //Calling controller method 
        controller.loadFilteredPayees();
        
        //Now set contact which is not associated with anyone
        payees = [select Id from Contact where Name = :'Test1 Contact1' order by Name ASC LIMIT 1];
        
        controller.personalGoal.Payee__c = payees[0].Id; 
        
        //Calling controller method 
        controller.loadFilteredPayees();
        
        //Create Personal Goal section
        //Variable to hold select period
        controller.selectedPeriod = controller.createPGBegains[1].getValue();// standardgoaldetailpacing[0].id
        
       
        //Calling controller method 
        controller.drawCreatePersonalGoalSection();
        
        //Set row index , column index and item index
        ApexPages.currentPage().getParameters().put('rowIndex', '0');
        ApexPages.currentPage().getParameters().put('colIndex', '0');
        ApexPages.currentPage().getParameters().put('itemIndex', '0');
        ApexPages.currentPage().getParameters().put('desc', 'Test 1');
        controller.createPGSecWrapper[0].stdGoalDetails[0].stdGDetailPacings[0].pGoal.Amount__c = 100000;
        
        //call method
        controller.addDescription(); 
        
        //Set row index , column index and item index
        ApexPages.currentPage().getParameters().put('rowIndex', '0');
        ApexPages.currentPage().getParameters().put('colIndex', '0');
        ApexPages.currentPage().getParameters().put('itemIndex', '0');
        controller.createPGSecWrapper[0].stdGoalDetails[0].stdGDetailPacings[0].pGoal.Amount__c = 100000;
        
        //call method
        controller.doItemGoalCalculation();
        
         //set value
        ApexPages.currentPage().getParameters().put('rowIndex', '0');
        ApexPages.currentPage().getParameters().put('itemIndex', '0');
        ApexPages.currentPage().getParameters().put('selectCB','selectCB');
        controller.createPGSecWrapper[0].stdGoalDetails[1].stdGDetailPacings[1].pGoal.Amount__c = 100000;
        
        
        //System.assert(false, controller.createPGSecWrapper[0].stdGoalDetails);
        
        //call method
        controller.doInclineGoalCalculation();
        
        controller.createPGSecWrapper[0].stdGoalDetails[1].stdGDetailPacings[1].pGoal.Amount__c = null;
        //call method
        controller.doInclineGoalCalculation();
        
        
        //Set row index , column index and item index
        ApexPages.currentPage().getParameters().put('rowIndex', '0');
        ApexPages.currentPage().getParameters().put('colIndex', '1');
        ApexPages.currentPage().getParameters().put('itemIndex', '1');
        ApexPages.currentPage().getParameters().put('desc', 'Test 2');
        controller.createPGSecWrapper[0].stdGoalDetails[1].stdGDetailPacings[1].pGoal.Amount__c = 100000;
        
        //Call method
        controller.addDescription();
        
        //Set value 
        ApexPages.currentPage().getParameters().put('rowIndex', '0');
        ApexPages.currentPage().getParameters().put('colIndex', '1');
        ApexPages.currentPage().getParameters().put('itemIndex', '1');
        controller.createPGSecWrapper[0].stdGoalDetails[1].stdGDetailPacings[1].pGoal.Amount__c = 100000;
        
        //Call Method
        controller.doItemGoalCalculation();
        controller.loadPGStaffRelationship();
        controller.doInclineGoalCalculation();
        //Select value
        controller.createPGSecWrapper[0].stdGoalDetails[0].stdGDetailPacings[0].selected= true;
        controller.createPGSecWrapper[0].stdGoalDetails[1].stdGDetailPacings[1].selected= true;
        
        //Add Personal goal measurment period
        controller.pGMPeriod.Measurement_Date__c = system.today();
        controller.mainRow = 0;
        controller.gTDRow = 0;
        controller.columnRow = 0; 
        
        
        //Call method
        controller.addPGMeasurementPeriods();
        
        //Call method 
        controller.loadPGMPs();
        
        //remove Personal goal measurment period
        controller.createPGSecWrapper[0].stdGoalDetails[0].stdGDetailPacings[0].pGMPeriods[0].selected = true;
        controller.mainRow = 0;
        controller.gTDRow = 0;
        controller.columnRow = 0;
        
        //Call method
        controller.removePGMeasurementPeriods();
        
        //Call method
        controller.doSave();
         
        //Query through personal goals
        List<Personal_Goal__c> pGQ = [Select Id, Name, RecordTypeId, Description__c, Goal_Type__c,Count__c,Amount__c,Percent__c, Parent_Personal_Goal__c, Payee__c, Period_End__c,
                                    Period_Start__c, Personal_Plan__c, Rate_Template__c, Primary_Goal__c, Sales_Role_Percentage__c, 
                                    Standard_Goal__c, Standard_Goal_Detail__c, Tenure_Percentage__c, Value__c, Value_Type__c, Editable__c,
                                    Autocreated__c from Personal_Goal__c];
        
        //Query through task
        List<Task> task = [Select Id, Description, Priority, Subject, ActivityDate, Status from Task];
        
        //Assert for result
        System.assertEquals(2, task.size());
        System.assertEquals('Test 1', task[0].Description);
        System.assertEquals('Test 2', task[1].Description);
        System.assertEquals('Completed', task[0].Status);
        System.assertEquals('Completed', task[1].Status);
        System.assertEquals(8, pGQ.size());
        System.assertEquals(recordTypesList[0].Id, pGQ[4].RecordTypeId);
        System.assertEquals(recordTypesList[0].Id, pGQ[5].RecordTypeId);
        System.assertEquals(recordTypesList[1].Id, pGQ[6].RecordTypeId);
        System.assertEquals(recordTypesList[1].Id, pGQ[7].RecordTypeId);
        System.assertEquals(standardGoalsList[0].Id, pGQ[4].Standard_Goal__c);
        System.assertEquals(standardGoalsList[0].Id, pGQ[5].Standard_Goal__c);
        System.assertEquals(standardGoalsList[0].Id, pGQ[6].Standard_Goal__c);
        System.assertEquals(standardGoalsList[0].Id, pGQ[7].Standard_Goal__c);
        //System.assertEquals(standardGoalDetailsList[0].Id, pGQ[4].Standard_Goal_Detail__c);
        //System.assertEquals(standardGoalDetailsList[1].Id, pGQ[5].Standard_Goal_Detail__c);
        //System.assertEquals(standardGoalDetailsList[0].Id, pGQ[6].Standard_Goal_Detail__c);
        //System.assertEquals(standardGoalDetailsList[1].Id, pGQ[7].Standard_Goal_Detail__c);
        System.assertEquals(true, pGQ[4].Editable__c);
        System.assertEquals(true, pGQ[4].Autocreated__c);
        System.assertEquals(true, pGQ[5].Editable__c);
        System.assertEquals(true, pGQ[5].Autocreated__c);
        System.assertEquals(true, pGQ[6].Editable__c);
        System.assertEquals(true, pGQ[6].Autocreated__c);
        System.assertEquals(true, pGQ[7].Editable__c);
        System.assertEquals(true, pGQ[7].Autocreated__c);
        System.assertEquals(sGDPacingsList[0].Period_Start__c, pGQ[4].Period_Start__c);
        System.assertEquals(sGDPacingsList[0].Period_End__c, pGQ[4].Period_End__c);
        System.assertEquals(sGDPacingsList[2].Period_Start__c, pGQ[5].Period_Start__c);
        System.assertEquals(sGDPacingsList[2].Period_End__c, pGQ[5].Period_End__c);
        System.assertEquals(sGDPacingsList[0].Period_Start__c, pGQ[6].Period_Start__c);
        System.assertEquals(sGDPacingsList[0].Period_End__c, pGQ[6].Period_End__c);
        System.assertEquals(sGDPacingsList[2].Period_Start__c, pGQ[7].Period_Start__c);
        System.assertEquals(sGDPacingsList[2].Period_End__c, pGQ[7].Period_End__c);
        System.assertEquals(100000,pGQ[5].Amount__c);
        System.assertEquals(100000,pGQ[7].Amount__c);
        System.assertEquals(100000,pGQ[4].Amount__c);
        System.assertEquals(100000,pGQ[6].Amount__c);
        
    } 
    
    //Test methods for Count GT
    static testMethod void myUnitTest2() {
        
        //Query to get Program Collection
        List<Program_Group__c> programCollectionsList = [Select Id, Name From Program_Group__c];
        
        //Assert
        System.assert(programCollectionsList.size() > 0);
        
        //Query to get Goal Type
        List<Goal_Type__c> goalTypesList = [Select Id, Name, Active__c, Standard_Goal__c, Base_Process__c, Description__c, Discount_Type__c From Goal_Type__c];
        
        //Assert
        System.assert(goalTypesList.size() > 0);
        
        //Query to get Standard Goals
        List<Standard_Goal__c> standardGoalsList = [Select Id, Name,Active__c,Amount__c,Business_Owner__c,Payee__c,Description__c,Goal_Type__c,
                                                    Period_Start__c, Period_End__c, Standard_Type__c From Standard_Goal__c];
        
        //Assert
        System.assert(standardGoalsList.size() > 0);
        
        //Query to get Standard Goal Details
        List<Standard_Goal_Detail__c> standardGoalDetailsList = [Select Id, Name,Active__c,Description__c,Summary__c,Standard_Goal__c,Goal_Type__c,
                                                                 Amount__c,Count__c From Standard_Goal_Detail__c];
        
        //Assert
        System.assert(standardGoalDetailsList.size() > 0);
        
        //Query to get Standard Goal Detail Pacing
        List<Standard_Goal_Detail_Pacing__c> sGDPacingsList = [Select Id, Name,Count_Manual__c,Standard_Goal_Detail__c,Standard_Goal__c,Description__c,
                                                               Period_Start__c,Period_End__c,Percent_Manual__c,Amount_Manual__c From Standard_Goal_Detail_Pacing__c];
        
        //Assert
        System.assert(sGDPacingsList.size() > 0);
        
        //List of record type
        List<RecordType> recordTypesList = [select Id, DeveloperName From RecordType Where SObjectType = 'Personal_Goal__c' 
                                            AND DeveloperName IN ('Personal_Goal', 'Proposal') ORDER BY DeveloperName ASC LIMIT 2];
        
        //Assert
        System.assert(recordTypesList.size() > 0);
                                        
        //Query to get Personal Goal Instance
        List<Personal_Goal__c> personalGoalsList = [Select Id,Name,Goal_Type__c,Active__c,RecordTypeId,Personal_Plan__c,Description__c,Amount__c,Payee__c,
                                                    Standard_Goal__c,Value_Type__c,Rate_Template__c,Status__c,Period_Start__c,Period_End__c,Business_Title__c,
                                                    Standard_Goal_Detail__c From Personal_Goal__c];
        
        //Assert
        System.assert(personalGoalsList.size() > 0);
        
        //Query to get of Value Types
        List<Value_Type__c> valueTypesList = [Select Id, Name, Values_Permitted__c,Category__c,Active__c,Rule__c,Adjustment__c From Value_Type__c];
        
        //Assert
        System.assert(valueTypesList.size() > 0);
        
        //Query to get rate template
        List<Rate_Template__c> rTsList = [Select Id, Name From Rate_Template__c];
        
        //Assert
        System.assert(rTsList.size() > 0);
        
        //Start Testing from here
        Test.startTest();
        
        //Instance of controller
        CreatePersonalGoalsFromStdGoalController controller = new CreatePersonalGoalsFromStdGoalController();
        
        //Assign values to Standard Goal with Count
        controller.stdPersonalGoal.Standard_Goal__c = standardGoalsList[1].Id;
        
        //Calling controller method 
        controller.InIt();
        
        //Assert for results
        System.AssertEquals(1, controller.availablePayees.size());
        
        //Variable to hold limit to from select option
        controller.selectedLimitToValue = '1';  
        
        //Calling controller method 
        controller.loadPayees();
        
        //Assert for results
        System.AssertEquals(1, controller.availablePayees.size());   
        
        //Select payee from the page list
        controller.availablePayees[0].selected = true;
        
        //Calling controller method 
        controller.selectPayee();
        
        //Assert for results
        System.AssertEquals(1, controller.selectedPayees.size());
        System.AssertEquals(3, controller.createPGBegains.size());
        
        //Create Personal Goal section
        //Variable to hold select period
        controller.selectedPeriod = controller.createPGBegains[1].getValue();
        
        //Calling controller method 
        controller.drawCreatePersonalGoalSection();
     
        //Set row index , column index and item index
        ApexPages.currentPage().getParameters().put('rowIndex', '0');
        ApexPages.currentPage().getParameters().put('colIndex', '0');
        ApexPages.currentPage().getParameters().put('itemIndex', '0');
        ApexPages.currentPage().getParameters().put('desc', 'Test 1');
        controller.createPGSecWrapper[0].stdGoalDetails[0].stdGDetailPacings[0].pGoal.Count__c = 500000;
        
        //Call method
        controller.addDescription(); 
        
        //Creating a standard goal detail data.
        Standard_Goal_Detail__c stdGoalDetail = new Standard_Goal_Detail__c(Name = 'StandardGoalDetail1',   Active__c = true, Description__c = 'Testing 7',Summary__c = true,
                                                            Standard_Goal__c = standardGoalsList[0].Id, Goal_Type__c = goalTypesList[3].Id,Amount__c = 100000);
        
        insert  stdGoalDetail;
        
        //set value 
        ApexPages.currentPage().getParameters().put('rowIndex', '0');
        ApexPages.currentPage().getParameters().put('colIndex', '0');
        ApexPages.currentPage().getParameters().put('itemIndex', '0');
        controller.createPGSecWrapper[0].stdGoalDetails[0].stdGDetailPacings[0].pGoal.Count__c = 500000;
        controller.createPGSecWrapper[0].stdGoalDetails[0].stdGDetailPacings[0].stdGDPacing.Standard_Goal_Detail__r.Parent__c = stdGoalDetail.Id;
        
        //createPGSecWrapper[rowIndex].stdGoalDetails
        //Call method
        controller.doItemGoalCalculation();
        
        //Set row index , column index and item index
        ApexPages.currentPage().getParameters().put('rowIndex', '0');
        ApexPages.currentPage().getParameters().put('colIndex', '1');
        ApexPages.currentPage().getParameters().put('itemIndex', '1');
        ApexPages.currentPage().getParameters().put('desc', 'Test 2');
        controller.createPGSecWrapper[0].stdGoalDetails[1].stdGDetailPacings[1].pGoal.Count__c = 200000;
        
         //Call method
        controller.doItemGoalCalculation();
        
        //call method
        controller.addDescription();
        
        //Set row index , column index and item index
        ApexPages.currentPage().getParameters().put('rowIndex', '0');
        ApexPages.currentPage().getParameters().put('colIndex', '1');
        ApexPages.currentPage().getParameters().put('itemIndex', '1');
        controller.createPGSecWrapper[0].stdGoalDetails[1].stdGDetailPacings[1].pGoal.Count__c = 200000;
        
        //call method
        controller.doItemGoalCalculation();
        
        //assert for result
        System.assertEquals('Count 2',controller.createPGSecWrapper[0].stdGoalDetails[1].stdGDetailPacings[1].stdGDPacing.Description__c);
        
        //select value
        controller.createPGSecWrapper[0].stdGoalDetails[0].stdGDetailPacings[0].selected= true;
        controller.createPGSecWrapper[0].stdGoalDetails[1].stdGDetailPacings[1].selected= true;
        
        //create personal goal measurment period
        controller.pGMPeriod.Measurement_Date__c = system.today();
        controller.mainRow = 0;
        controller.gTDRow = 0;
        controller.columnRow = 0; 
        
        //Call method
        controller.addPGMeasurementPeriods();
        
        //add personal goal measurment period
        controller.pGMPeriod.Measurement_Date__c = system.today().addDays(5);
        controller.mainRow = 0;
        controller.gTDRow = 0;
        controller.columnRow = 0; 
        
        //Call method
        controller.addPGMeasurementPeriods();
        controller.doSave();
         
        //Query through personal goals
        List<Personal_Goal__c> pGQ = [Select Id, Name, RecordTypeId, Description__c, Goal_Type__c,Count__c,Amount__c,Percent__c, Parent_Personal_Goal__c, Payee__c, Period_End__c,
                                    Period_Start__c, Personal_Plan__c, Rate_Template__c, Primary_Goal__c, Sales_Role_Percentage__c, 
                                    Standard_Goal__c, Standard_Goal_Detail__c,Standard_Goal_Detail__r.Name, Tenure_Percentage__c, Value__c, Value_Type__c, Editable__c,
                                    Autocreated__c from Personal_Goal__c];
        
        //Query through task
        List<Task> task = [Select Id, Description, Priority, Subject, ActivityDate, Status from Task];
        
        //assert for result
        System.assertEquals(1, task.size());
        System.assertEquals('Test 1', task[0].Description);  
        //System.assertEquals('Test 2', task[1].Description);
        System.assertEquals('Completed', task[0].Status);
        //System.assertEquals('Completed', task[1].Status);  
        System.assertEquals(8, pGQ.size());
        System.assertEquals(recordTypesList[0].Id, pGQ[4].RecordTypeId);
        System.assertEquals(recordTypesList[0].Id, pGQ[5].RecordTypeId);
        System.assertEquals(recordTypesList[1].Id, pGQ[6].RecordTypeId);
        System.assertEquals(recordTypesList[1].Id, pGQ[7].RecordTypeId);
        System.assertEquals(standardGoalsList[1].Id, pGQ[4].Standard_Goal__c);
        System.assertEquals(standardGoalsList[1].Id, pGQ[5].Standard_Goal__c);
        System.assertEquals(standardGoalsList[1].Id, pGQ[6].Standard_Goal__c);
        System.assertEquals(standardGoalsList[1].Id, pGQ[7].Standard_Goal__c);
        //System.assertEquals(standardGoalDetailsList[2].Id, pGQ[4].Standard_Goal_Detail__c);
        //System.assertEquals(standardGoalDetailsList[3].Id, pGQ[5].Standard_Goal_Detail__c);
        //System.assertEquals(standardGoalDetailsList[2].Id, pGQ[6].Standard_Goal_Detail__c);
        //System.assertEquals(standardGoalDetailsList[3].Id, pGQ[7].Standard_Goal_Detail__c);
        System.assertEquals(true, pGQ[4].Editable__c);
        System.assertEquals(true, pGQ[4].Autocreated__c);
        System.assertEquals(true, pGQ[5].Editable__c);
        System.assertEquals(true, pGQ[5].Autocreated__c);
        System.assertEquals(true, pGQ[6].Editable__c);
        System.assertEquals(true, pGQ[6].Autocreated__c);
        System.assertEquals(true, pGQ[7].Editable__c);
        System.assertEquals(true, pGQ[7].Autocreated__c);
        System.assertEquals(sGDPacingsList[4].Period_Start__c, pGQ[4].Period_Start__c);
        System.assertEquals(sGDPacingsList[4].Period_End__c, pGQ[4].Period_End__c);
        System.assertEquals(sGDPacingsList[5].Period_Start__c, pGQ[5].Period_Start__c);
        System.assertEquals(sGDPacingsList[5].Period_End__c, pGQ[5].Period_End__c);
        System.assertEquals(sGDPacingsList[4].Period_Start__c, pGQ[6].Period_Start__c);
        System.assertEquals(sGDPacingsList[4].Period_End__c, pGQ[6].Period_End__c);
        System.assertEquals(sGDPacingsList[5].Period_Start__c, pGQ[7].Period_Start__c);
        System.assertEquals(sGDPacingsList[5].Period_End__c, pGQ[7].Period_End__c);
        System.assertEquals(500000, pGQ[4].Count__c);
        //System.assertEquals(200000, pGQ[5].Count__c);
        System.assertEquals(500000, pGQ[6].Count__c);
        //System.assertEquals(200000, pGQ[7].Count__c);    
        
        //Query on personal goal measurment period
        List<Personal_Goal_Measurement_Period__c> pGMPeriodsList = [select Id, Name, Personal_Goal__c, Measurement_Date__c From Personal_Goal_Measurement_Period__c order by LastModifiedDate DESC];
        
        //Assert for result(4 + 4 )
        System.assertEquals(8,pGMPeriodsList.size());
        
        //V_1.2 - Modified - Rajeev Jain - 08/01/2016 - Fixed Run ALLTest failure issue, improved asserts.
        System.assertEquals(system.today().addDays(-5), pGMPeriodsList[4].Measurement_Date__c);
        System.assertEquals(system.today().addDays(5), pGMPeriodsList[5].Measurement_Date__c);
        System.assertEquals(system.today().addDays(10), pGMPeriodsList[6].Measurement_Date__c);
        System.assertEquals(system.today().addDays(15), pGMPeriodsList[7].Measurement_Date__c);
        //V_1.2 - Modified - Rajeev Jain - 08/01/2016 - Fixed Run ALLTest failure issue, improved asserts. - Upto here
    } 
    
    //Test methods for Percent GT 
    static testMethod void myUnitTest3() {
        
        //Query to get Program Collection
        List<Program_Group__c> programCollectionsList = [Select Id, Name From Program_Group__c];
        
        //Query to get Goal Type
        List<Goal_Type__c> goalTypesList = [Select Id, Name, Active__c, Standard_Goal__c, Base_Process__c, Description__c, Discount_Type__c From Goal_Type__c];
        
        //Query to get Standard Goals
        List<Standard_Goal__c> standardGoalsList = [Select Id, Name,Active__c,Amount__c,Business_Owner__c,Payee__c,Description__c,Goal_Type__c,
                                                    Period_Start__c, Period_End__c, Standard_Type__c From Standard_Goal__c];
        
        //Assert for result
        system.assertEquals(3,standardGoalsList.size());
        
        //Query to get Standard Goal Details
        List<Standard_Goal_Detail__c> standardGoalDetailsList = [Select Id, Name,Active__c,Description__c,Summary__c,Standard_Goal__c,Goal_Type__c,
                                                                 Amount__c,Count__c From Standard_Goal_Detail__c];
        
        //Assert for result
        system.assertEquals(7, standardGoalDetailsList.size());
        
        //Cerating standadrd goal detail records as baseline.
        Standard_Goal_Detail__c stdGDBase = new Standard_Goal_Detail__c(Name = 'StandardGoalDetail', Baseline__c = standardGoalDetailsList[0].Id, Active__c = true, Description__c = 'Testing 1',Summary__c = true,
                                                            Standard_Goal__c = standardGoalsList[0].Id, Goal_Type__c = goalTypesList[3].Id,percent__c = 90);
                                                            
        insert stdGDBase;
        
        //Query to get Standard Goal Detail Pacing
        List<Standard_Goal_Detail_Pacing__c> sGDPacingsList = [Select Id, Name,Count_Manual__c,Standard_Goal_Detail__c,Standard_Goal__c,Description__c,
                                                               Period_Start__c,Period_End__c,Percent_Manual__c,Amount_Manual__c From Standard_Goal_Detail_Pacing__c];
        
        //List of record type
        List<RecordType> recordTypesList = [select Id, DeveloperName From RecordType Where SObjectType = 'Personal_Goal__c' 
                                            AND DeveloperName IN ('Personal_Goal', 'Proposal') ORDER BY DeveloperName ASC LIMIT 2];
                                        
        //Query to get Personal Goal Instance
        List<Personal_Goal__c> personalGoalsList = [Select Id,Name,Goal_Type__c,Active__c,RecordTypeId,Personal_Plan__c,Description__c,Amount__c,Payee__c,
                                                    Standard_Goal__c,Value_Type__c,Rate_Template__c,Status__c,Period_Start__c,Period_End__c,Business_Title__c,
                                                    Standard_Goal_Detail__c From Personal_Goal__c];
        
        //Query to get of Value Types
        List<Value_Type__c> valueTypesList = [Select Id, Name, Values_Permitted__c,Category__c,Active__c,Rule__c,Adjustment__c From Value_Type__c];
        
        //Query to get rate template
        List<Rate_Template__c> rTsList = [Select Id, Name From Rate_Template__c];
        
        //Start Testing from here
        Test.startTest();
        
        //Instance of controller
        CreatePersonalGoalsFromStdGoalController controller = new CreatePersonalGoalsFromStdGoalController();
        
        //Assign values to Standard Goal with Count
        controller.stdPersonalGoal.Standard_Goal__c = standardGoalsList[2].Id;
        
        //Variable to hold limit to from select option
        controller.selectedLimitToValue = '1';
        
        //Calling controller method 
        controller.loadPayees();
        
        //Assert for results
        System.AssertEquals(1, controller.availablePayees.size());   
        
        //Calling controller method 
        controller.InIt();
        
        //Assert for results
        System.AssertEquals(1, controller.availablePayees.size());
        
        //Select payee from the page list
        controller.availablePayees[0].selected = true;
        
        //Calling controller method 
        controller.selectPayee();
        
        //Assert for results
        System.AssertEquals(1, controller.selectedPayees.size());
        System.AssertEquals(3, controller.createPGBegains.size());
        
        //Create Personal Goal section
        //Variable to hold select period
        controller.selectedPeriod = controller.createPGBegains[1].getValue();
        
        //Calling controller method 
        controller.drawCreatePersonalGoalSection();
        
        //Set row index , column index and item index
        ApexPages.currentPage().getParameters().put('rowIndex', '0');
        ApexPages.currentPage().getParameters().put('colIndex', '0');
        ApexPages.currentPage().getParameters().put('itemIndex', '0');
        ApexPages.currentPage().getParameters().put('desc', 'Test 1');
        controller.createPGSecWrapper[0].stdGoalDetails[0].stdGDetailPacings[0].pGoal.Percent__c = 100;
        controller.addDescription(); 
        
        ApexPages.currentPage().getParameters().put('rowIndex', '0');
        ApexPages.currentPage().getParameters().put('colIndex', '0');
        ApexPages.currentPage().getParameters().put('itemIndex', '0');
        controller.createPGSecWrapper[0].stdGoalDetails[0].stdGDetailPacings[0].pGoal.Percent__c = 100;
        controller.doItemGoalCalculation();
        
        //Set row index , column index and item index  
        ApexPages.currentPage().getParameters().put('rowIndex', '0');
        ApexPages.currentPage().getParameters().put('colIndex', '1');
        ApexPages.currentPage().getParameters().put('itemIndex', '1');
        ApexPages.currentPage().getParameters().put('desc', 'Test 2');
        controller.createPGSecWrapper[0].stdGoalDetails[1].stdGDetailPacings[1].pGoal.Percent__c = 100;
        controller.addDescription();
        
        //set value
        ApexPages.currentPage().getParameters().put('rowIndex', '0');
        ApexPages.currentPage().getParameters().put('colIndex', '1');
        ApexPages.currentPage().getParameters().put('itemIndex', '1');
        controller.createPGSecWrapper[0].stdGoalDetails[1].stdGDetailPacings[1].pGoal.Percent__c = 100;
        
        //call method
        controller.doItemGoalCalculation();  
        
        //select value
        controller.createPGSecWrapper[0].stdGoalDetails[0].stdGDetailPacings[0].selected= true;
        controller.createPGSecWrapper[0].stdGoalDetails[1].stdGDetailPacings[1].selected= true;
        
        //call method
        controller.doSave();
        system.debug('$$$$$$$$$$$ : ');
         
        //Query through personal goals
        List<Personal_Goal__c> pGQ = [Select Id, Name, RecordTypeId, Description__c, Goal_Type__c,Count__c,Amount__c,Percent__c, Parent_Personal_Goal__c, Payee__c, Period_End__c,
                                    Period_Start__c, Personal_Plan__c, Rate_Template__c, Primary_Goal__c, Sales_Role_Percentage__c, 
                                    Standard_Goal__c, Standard_Goal_Detail__c,Standard_Goal_Detail__r.Name, Tenure_Percentage__c, Value__c, Value_Type__c, Editable__c,
                                    Autocreated__c from Personal_Goal__c];
        
        //Query through task  
        List<Task> task = [Select Id, Description, Priority, Subject, ActivityDate, Status from Task];
           
        //assert for result
        System.assertEquals(2, task.size());
        System.assertEquals('Test 1', task[0].Description);  
        System.assertEquals('Test 2', task[1].Description);
        System.assertEquals('Completed', task[0].Status);
        System.assertEquals('Completed', task[1].Status);  
        System.assertEquals(8, pGQ.size());
        System.assertEquals(recordTypesList[0].Id, pGQ[4].RecordTypeId);
        System.assertEquals(recordTypesList[0].Id, pGQ[5].RecordTypeId);
        System.assertEquals(recordTypesList[1].Id, pGQ[6].RecordTypeId);
        System.assertEquals(recordTypesList[1].Id, pGQ[7].RecordTypeId);
        System.assertEquals(standardGoalsList[2].Id, pGQ[4].Standard_Goal__c);
        System.assertEquals(standardGoalsList[2].Id, pGQ[5].Standard_Goal__c);
        System.assertEquals(standardGoalsList[2].Id, pGQ[6].Standard_Goal__c);
        System.assertEquals(standardGoalsList[2].Id, pGQ[7].Standard_Goal__c);
        //System.assertEquals(standardGoalDetailsList[4].Id, pGQ[4].Standard_Goal_Detail__c);
        //System.assertEquals(standardGoalDetailsList[5].Id, pGQ[5].Standard_Goal_Detail__c);
        //System.assertEquals(standardGoalDetailsList[4].Id, pGQ[6].Standard_Goal_Detail__c);
        //System.assertEquals(standardGoalDetailsList[5].Id, pGQ[7].Standard_Goal_Detail__c);
        System.assertEquals(true, pGQ[4].Editable__c);
        System.assertEquals(true, pGQ[4].Autocreated__c);
        System.assertEquals(true, pGQ[5].Editable__c);
        System.assertEquals(true, pGQ[5].Autocreated__c);
        System.assertEquals(true, pGQ[6].Editable__c);
        System.assertEquals(true, pGQ[6].Autocreated__c);
        System.assertEquals(true, pGQ[7].Editable__c);
        System.assertEquals(true, pGQ[7].Autocreated__c);
        System.assertEquals(sGDPacingsList[6].Period_Start__c, pGQ[4].Period_Start__c);
        System.assertEquals(sGDPacingsList[6].Period_End__c, pGQ[4].Period_End__c);
        System.assertEquals(sGDPacingsList[7].Period_Start__c, pGQ[5].Period_Start__c);
        System.assertEquals(sGDPacingsList[7].Period_End__c, pGQ[5].Period_End__c);
        System.assertEquals(sGDPacingsList[6].Period_Start__c, pGQ[6].Period_Start__c);
        System.assertEquals(sGDPacingsList[6].Period_End__c, pGQ[6].Period_End__c);
        System.assertEquals(sGDPacingsList[7].Period_Start__c, pGQ[7].Period_Start__c);
        System.assertEquals(sGDPacingsList[7].Period_End__c, pGQ[7].Period_End__c);
        System.assertEquals(100, pGQ[4].Percent__c);
        //System.assertEquals(100, pGQ[5].Percent__c);
        System.assertEquals(100, pGQ[6].Percent__c);
        //System.assertEquals(100, pGQ[7].Percent__c);
        
        //Instance of controller
        controller = new CreatePersonalGoalsFromStdGoalController();
        
        //Assign values to Standard Goal with Count
        controller.stdPersonalGoal.Standard_Goal__c = standardGoalsList[0].Id;
        
        //Variable to hold limit to from select option
        controller.selectedLimitToValue = '1';
        
        //Calling controller method 
        controller.loadPayees();
        
        //Assert for results
        System.AssertEquals(1, controller.availablePayees.size());   
        
        //Select payee from the page list
        controller.availablePayees[0].selected = true;
        
        //Calling controller method 
        controller.selectPayee();
        
        //Assert for results
        System.AssertEquals(1, controller.selectedPayees.size());
        System.AssertEquals(5, controller.createPGBegains.size()); 
        System.AssertEquals(sGDPacingsList[0].Id,controller.createPGBegains[1].getValue());
        System.AssertEquals(sGDPacingsList[1].Id,controller.createPGBegains[2].getValue());
        System.AssertEquals(sGDPacingsList[2].Id,controller.createPGBegains[3].getValue());
        System.AssertEquals(sGDPacingsList[3].Id,controller.createPGBegains[4].getValue());
        
        //Create Personal Goal section
        //Variable to hold select period
        controller.selectedPeriod = controller.createPGBegains[1].getValue();
        
        //Calling controller method 
        controller.drawCreatePersonalGoalSection();
        
        //Set row index , column index and item index
        ApexPages.currentPage().getParameters().put('rowIndex', '0');
        ApexPages.currentPage().getParameters().put('colIndex', '0');
        ApexPages.currentPage().getParameters().put('itemIndex', '0');
        ApexPages.currentPage().getParameters().put('desc', 'Test 1');
        controller.createPGSecWrapper[0].stdGoalDetails[0].stdGDetailPacings[0].pGoal.Amount__c = 2000000;
        
        //call method
        controller.addDescription(); 
        
        //set value
        ApexPages.currentPage().getParameters().put('rowIndex', '0');
        ApexPages.currentPage().getParameters().put('colIndex', '0');
        ApexPages.currentPage().getParameters().put('itemIndex', '0');
        controller.createPGSecWrapper[0].stdGoalDetails[0].stdGDetailPacings[0].pGoal.Amount__c = 2000000;
        
        //call method
        controller.doItemGoalCalculation();
        
        //set value
        ApexPages.currentPage().getParameters().put('rowIndex', '0');
        ApexPages.currentPage().getParameters().put('itemIndex', '0');
        ApexPages.currentPage().getParameters().put('selectCB','selectCB');
        
        
        
        //call method
        controller.doInclineGoalCalculation();
        //System.assert(false,controller.createPGSecWrapper[6].stdGoalDetails);
      
        
        //call method
        controller.doSave();
         
        //Query through personal goals
        pGQ = [Select Id, Name, RecordTypeId, Description__c, Goal_Type__c,Count__c,Amount__c,Percent__c, Parent_Personal_Goal__c, Payee__c, Period_End__c,
                                    Period_Start__c, Personal_Plan__c, Rate_Template__c, Primary_Goal__c, Sales_Role_Percentage__c, 
                                    Standard_Goal__c, Standard_Goal_Detail__c,Standard_Goal_Detail__r.Name, Tenure_Percentage__c, Value__c, Value_Type__c, Editable__c,
                                    Autocreated__c from Personal_Goal__c];

        //Query through task
        task = [Select Id, Description, Priority, Subject, ActivityDate, Status from Task];
        
        //Assert for result
        System.assertEquals(8,pGQ.size());
        System.assertEquals(2, task.size());
        System.assertEquals('Test 1', task[0].Description);  
        System.assertEquals('Test 2', task[1].Description);
        System.assertEquals('Completed', task[0].Status);
        System.assertEquals('Completed', task[1].Status);
        System.assertEquals(recordTypesList[0].Id, pGQ[4].RecordTypeId);
        System.assertEquals(recordTypesList[0].Id, pGQ[5].RecordTypeId);
        System.assertEquals(recordTypesList[1].Id, pGQ[6].RecordTypeId);
        System.assertEquals(recordTypesList[1].Id, pGQ[7].RecordTypeId);
        System.assertEquals(standardGoalsList[2].Id, pGQ[4].Standard_Goal__c);
        System.assertEquals(standardGoalsList[2].Id, pGQ[5].Standard_Goal__c);
        System.assertEquals(standardGoalsList[2].Id, pGQ[6].Standard_Goal__c);
        System.assertEquals(standardGoalsList[2].Id, pGQ[7].Standard_Goal__c);
        //System.assertEquals(standardGoalDetailsList[4].Id, pGQ[4].Standard_Goal_Detail__c);
        //System.assertEquals(standardGoalDetailsList[5].Id, pGQ[5].Standard_Goal_Detail__c);
        //System.assertEquals(standardGoalDetailsList[4].Id, pGQ[6].Standard_Goal_Detail__c);
        //System.assertEquals(standardGoalDetailsList[5].Id, pGQ[7].Standard_Goal_Detail__c);
        System.assertEquals(true, pGQ[4].Editable__c);
        System.assertEquals(true, pGQ[4].Autocreated__c);
        System.assertEquals(true, pGQ[5].Editable__c);
        System.assertEquals(true, pGQ[5].Autocreated__c);
        System.assertEquals(true, pGQ[6].Editable__c);
        System.assertEquals(true, pGQ[6].Autocreated__c);
        System.assertEquals(true, pGQ[7].Editable__c);
        System.assertEquals(true, pGQ[7].Autocreated__c);
        System.assertEquals(sGDPacingsList[6].Period_Start__c, pGQ[4].Period_Start__c);
        System.assertEquals(sGDPacingsList[6].Period_End__c, pGQ[4].Period_End__c);
        System.assertEquals(sGDPacingsList[7].Period_Start__c, pGQ[5].Period_Start__c);
        System.assertEquals(sGDPacingsList[7].Period_End__c, pGQ[5].Period_End__c);
        System.assertEquals(sGDPacingsList[6].Period_Start__c, pGQ[6].Period_Start__c);
        System.assertEquals(sGDPacingsList[6].Period_End__c, pGQ[6].Period_End__c);
        System.assertEquals(sGDPacingsList[7].Period_Start__c, pGQ[7].Period_Start__c);
        System.assertEquals(sGDPacingsList[7].Period_End__c, pGQ[7].Period_End__c);
        
        
    }    
    
    //Test methods for Percent GT 
    static testMethod void myUnitTest4() {
        
        //Query to get Program Collection
        List<Program_Group__c> programCollectionsList = [Select Id, Name From Program_Group__c];
        
        //Query to get Goal Type
        List<Goal_Type__c> goalTypesList = [Select Id, Name, Active__c, Standard_Goal__c, Base_Process__c, Description__c, Discount_Type__c From Goal_Type__c];
        
        //Query to get Standard Goals
        List<Standard_Goal__c> standardGoalsList = [Select Id, Name,Active__c,Amount__c,Business_Owner__c,Payee__c,Description__c,Goal_Type__c,
                                                    Period_Start__c, Period_End__c, Standard_Type__c From Standard_Goal__c];
        
        //Query to get Standard Goal Details
        List<Standard_Goal_Detail__c> standardGoalDetailsList = [Select Id, Name,Active__c,Description__c,Summary__c,Standard_Goal__c,Goal_Type__c,
                                                                 Amount__c,Count__c From Standard_Goal_Detail__c];
        
        //Query to get Standard Goal Detail Pacing
        List<Standard_Goal_Detail_Pacing__c> sGDPacingsList = [Select Id, Name,Count_Manual__c,Standard_Goal_Detail__c,Standard_Goal__c,Description__c,
                                                               Period_Start__c,Period_End__c,Percent_Manual__c,Amount_Manual__c From Standard_Goal_Detail_Pacing__c];
        
        //List of record type
        List<RecordType> recordTypesList = [select Id, DeveloperName From RecordType Where SObjectType = 'Personal_Goal__c' 
                                            AND DeveloperName IN ('Personal_Goal', 'Proposal') ORDER BY DeveloperName ASC LIMIT 2];
                                        
        //Query to get Personal Goal Instance
        List<Personal_Goal__c> personalGoalsList = [Select Id,Name,Goal_Type__c,Active__c,RecordTypeId,Personal_Plan__c,Description__c,Amount__c,Payee__c,
                                                    Standard_Goal__c,Value_Type__c,Rate_Template__c,Status__c,Period_Start__c,Period_End__c,Business_Title__c,
                                                    Standard_Goal_Detail__c From Personal_Goal__c];
        
        //Query to get of Value Types
        List<Value_Type__c> valueTypesList = [Select Id, Name, Values_Permitted__c,Category__c,Active__c,Rule__c,Adjustment__c From Value_Type__c];
        
        //Query to get rate template
        List<Rate_Template__c> rTsList = [Select Id, Name From Rate_Template__c];
        
        //Start Testing from here
        Test.startTest();
        
        //Instance of controller
        CreatePersonalGoalsFromStdGoalController controller = new CreatePersonalGoalsFromStdGoalController();
        
        //Assign values to Standard Goal with Count
        controller.stdPersonalGoal.Standard_Goal__c = standardGoalsList[2].Id;
        
        //Variable to hold limit to from select option
        controller.selectedLimitToValue = '1';
        
        //Calling controller method 
        controller.loadPayees();
        
        //Assert for results
        System.AssertEquals(1, controller.availablePayees.size());   
        
        //Select payee from the page list
        controller.availablePayees[0].selected = true;
        
        //Calling controller method 
        controller.selectPayee();
        
        //Assert for results
        System.AssertEquals(1, controller.selectedPayees.size());
        System.AssertEquals(3, controller.createPGBegains.size());
        
        //Create Personal Goal section
        //Variable to hold select period
        controller.selectedPeriod = controller.createPGBegains[1].getValue();
        
        //Calling controller method 
        controller.drawCreatePersonalGoalSection();
        
        //Set row index , column index and item index
        ApexPages.currentPage().getParameters().put('rowIndex', '0');
        ApexPages.currentPage().getParameters().put('colIndex', '0');
        ApexPages.currentPage().getParameters().put('itemIndex', '0');
        ApexPages.currentPage().getParameters().put('desc', 'Test 1');
        controller.createPGSecWrapper[0].stdGoalDetails[0].stdGDetailPacings[0].pGoal.Percent__c = 100;
        
        //call method
        controller.addDescription(); 
        
        //set value
        ApexPages.currentPage().getParameters().put('rowIndex', '0');
        ApexPages.currentPage().getParameters().put('colIndex', '0');
        ApexPages.currentPage().getParameters().put('itemIndex', '0');
        controller.createPGSecWrapper[0].stdGoalDetails[0].stdGDetailPacings[0].pGoal.Percent__c = 100;
        
        //call method
        controller.doItemGoalCalculation();
        
        //set value
        ApexPages.currentPage().getParameters().put('rowIndex', '0');
        ApexPages.currentPage().getParameters().put('itemIndex', '0');
        ApexPages.currentPage().getParameters().put('selectCB','selectCB');
        
        //call method
        controller.doInclineGoalCalculation();
        
        //select value
        controller.createPGSecWrapper[0].stdGoalDetails[0].stdGDetailPacings[0].selected= true;
        
        //call method
        controller.doSave();
         
        //Query through personal goals
        List<Personal_Goal__c> pGQ = [Select Id, Name, RecordTypeId, Description__c, Goal_Type__c,Count__c,Amount__c,Percent__c, Parent_Personal_Goal__c, Payee__c, Period_End__c,
                                    Period_Start__c, Personal_Plan__c, Rate_Template__c, Primary_Goal__c, Sales_Role_Percentage__c, 
                                    Standard_Goal__c, Standard_Goal_Detail__c,Standard_Goal_Detail__r.Name, Tenure_Percentage__c, Value__c, Value_Type__c, Editable__c,
                                    Autocreated__c from Personal_Goal__c];
        
        //Query through task
        List<Task> task = [Select Id, Description, Priority, Subject, ActivityDate, Status from Task];
        
        //Assert for result
        System.assertEquals(1, task.size());
        System.assertEquals('Test 1', task[0].Description);
        System.assertEquals('Completed', task[0].Status);  
        System.assertEquals(6, pGQ.size());
        System.assertEquals(100, pGQ[4].Percent__c);
        System.assertEquals(100, pGQ[5].Percent__c);
        
        
        //Instance of controller
        controller = new CreatePersonalGoalsFromStdGoalController();
        
        //Assign values to Standard Goal with Count
        controller.stdPersonalGoal.Standard_Goal__c = standardGoalsList[1].Id;
        
        //Variable to hold limit to from select option
        controller.selectedLimitToValue = '1';
        
        //Calling controller method 
        controller.loadPayees();
        
        //Assert for results
        System.AssertEquals(1, controller.availablePayees.size());   
        
        //Select payee from the page list
        controller.availablePayees[0].selected = true;
        
        //Calling controller method 
        controller.selectPayee();
        
        //Assert for results
        System.AssertEquals(1, controller.selectedPayees.size());
        System.AssertEquals(3, controller.createPGBegains.size()); 
        
        //Create Personal Goal section
        //Variable to hold select period
        controller.selectedPeriod = controller.createPGBegains[1].getValue();
        
        //Calling controller method 
        controller.drawCreatePersonalGoalSection();
        
        //Set row index , column index and item index
        ApexPages.currentPage().getParameters().put('rowIndex', '0');
        ApexPages.currentPage().getParameters().put('colIndex', '0');
        ApexPages.currentPage().getParameters().put('itemIndex', '0');
        ApexPages.currentPage().getParameters().put('desc', 'Test 1');
        controller.createPGSecWrapper[0].stdGoalDetails[0].stdGDetailPacings[0].pGoal.Count__c = 2000000;
        
        //call method
        controller.addDescription(); 
        
        //set value
        ApexPages.currentPage().getParameters().put('rowIndex', '0');
        ApexPages.currentPage().getParameters().put('colIndex', '0');
        ApexPages.currentPage().getParameters().put('itemIndex', '0');
        controller.createPGSecWrapper[0].stdGoalDetails[0].stdGDetailPacings[0].pGoal.Count__c = 2000000;
        
        //call method
        controller.doItemGoalCalculation();
        
        //set value
        ApexPages.currentPage().getParameters().put('rowIndex', '0');
        ApexPages.currentPage().getParameters().put('itemIndex', '0');
        ApexPages.currentPage().getParameters().put('selectCB','selectCB');
        
        //call method
        controller.doInclineSRAndGoalCalc();
        
        //call method
        controller.doSave();
         
        //Query through personal goals
        pGQ = [Select Id, Name, RecordTypeId, Description__c, Goal_Type__c,Count__c,Amount__c,Percent__c, Parent_Personal_Goal__c, Payee__c, Period_End__c,
                                    Period_Start__c, Personal_Plan__c, Rate_Template__c, Primary_Goal__c, Sales_Role_Percentage__c, 
                                    Standard_Goal__c, Standard_Goal_Detail__c,Standard_Goal_Detail__r.Name, Tenure_Percentage__c, Value__c, Value_Type__c, Editable__c,
                                    Autocreated__c from Personal_Goal__c];
        
        //Query through task
        task = [Select Id, Description, Priority, Subject, ActivityDate, Status from Task];
        
        //Assert for result
        System.assertEquals(6, pGQ.size());
        System.assertEquals(1, task.size());
        System.assertEquals('Test 1', task[0].Description);
        System.assertEquals('Completed', task[0].Status); 
        
    }
    
    //Test methods for Percent GT 
    static testMethod void myUnitTest5() {
        
        //Query to get Program Collection
        List<Program_Group__c> programCollectionsList = [Select Id, Name From Program_Group__c];
        
        //Query to get Goal Type
        List<Goal_Type__c> goalTypesList = [Select Id, Name, Active__c, Standard_Goal__c, Base_Process__c, Description__c, Discount_Type__c From Goal_Type__c];
        
        //Query to get Standard Goals
        List<Standard_Goal__c> standardGoalsList = [Select Id, Name,Active__c,Amount__c,Business_Owner__c,Payee__c,Description__c,Goal_Type__c,
                                                    Period_Start__c, Period_End__c, Standard_Type__c From Standard_Goal__c];
        
        //Query to get Standard Goal Details
        List<Standard_Goal_Detail__c> standardGoalDetailsList = [Select Id, Name,Active__c,Description__c,Summary__c,Standard_Goal__c,Goal_Type__c,
                                                                 Amount__c,Count__c From Standard_Goal_Detail__c];
        
        //Query to get Standard Goal Detail Pacing
        List<Standard_Goal_Detail_Pacing__c> sGDPacingsList = [Select Id, Name,Count_Manual__c,Standard_Goal_Detail__c,Standard_Goal__c,Description__c,
                                                               Period_Start__c,Period_End__c,Percent_Manual__c,Amount_Manual__c From Standard_Goal_Detail_Pacing__c];
        
        //List of record type
        List<RecordType> recordTypesList = [select Id, DeveloperName From RecordType Where SObjectType = 'Personal_Goal__c' 
                                            AND DeveloperName IN ('Personal_Goal', 'Proposal') ORDER BY DeveloperName ASC LIMIT 2];
                                        
        //Query to get Personal Goal Instance
        List<Personal_Goal__c> personalGoalsList = [Select Id,Name,Goal_Type__c,Active__c,RecordTypeId,Personal_Plan__c,Description__c,Amount__c,Payee__c,
                                                    Standard_Goal__c,Value_Type__c,Rate_Template__c,Status__c,Period_Start__c,Period_End__c,Business_Title__c,
                                                    Standard_Goal_Detail__c From Personal_Goal__c];
        
        //Query to get of Value Types
        List<Value_Type__c> valueTypesList = [Select Id, Name, Values_Permitted__c,Category__c,Active__c,Rule__c,Adjustment__c From Value_Type__c];
        
        //Query to get rate template
        List<Rate_Template__c> rTsList = [Select Id, Name From Rate_Template__c];
        
        //Start Testing from here
        Test.startTest();
        
        //Instance of controller
        CreatePersonalGoalsFromStdGoalController controller = new CreatePersonalGoalsFromStdGoalController();
        
        //Assign values to Standard Goal with Count
        controller.stdPersonalGoal.Standard_Goal__c = standardGoalsList[2].Id;
        
        //Variable to hold limit to from select option
        controller.selectedLimitToValue = '1';
        
        //Calling controller method 
        controller.loadPayees();
        
        //Assert for results
        System.AssertEquals(1, controller.availablePayees.size());   
        
        //Select payee from the page list
        controller.availablePayees[0].selected = true;
        
        //Calling controller method 
        controller.selectPayee();
        
        //Assert for results
        System.AssertEquals(1, controller.selectedPayees.size());
        System.AssertEquals(3, controller.createPGBegains.size()); 
        
        //Create Personal Goal section
        //Variable to hold select period
        controller.selectedPeriod = controller.createPGBegains[1].getValue();
        
        //Calling controller method 
        controller.drawCreatePersonalGoalSection();
        
        //Set row index , column index and item index
        ApexPages.currentPage().getParameters().put('rowIndex', '0');
        ApexPages.currentPage().getParameters().put('colIndex', '0');
        ApexPages.currentPage().getParameters().put('itemIndex', '0');
        ApexPages.currentPage().getParameters().put('desc', 'Test 1');
        controller.createPGSecWrapper[0].stdGoalDetails[0].stdGDetailPacings[0].pGoal.Percent__c = 100;
        
        //call method
        controller.addDescription(); 
        
        //set value
        ApexPages.currentPage().getParameters().put('rowIndex', '0');
        ApexPages.currentPage().getParameters().put('colIndex', '0');
        ApexPages.currentPage().getParameters().put('itemIndex', '0');
        controller.createPGSecWrapper[0].stdGoalDetails[0].stdGDetailPacings[0].pGoal.Percent__c = 100;
        
        //call method
        controller.doItemGoalCalculation();
        
        //set value
        ApexPages.currentPage().getParameters().put('rowIndex', '0');
        ApexPages.currentPage().getParameters().put('itemIndex', '0');
        ApexPages.currentPage().getParameters().put('selectCB','selectCB');
        
        //call method
        controller.doGoalCalculation();
        
        //select value
        controller.createPGSecWrapper[0].stdGoalDetails[0].stdGDetailPacings[0].selected= true;
        
        //call method
        controller.doSave();
         
        //Query through personal goals
        List<Personal_Goal__c> pGQ = [Select Id, Name, RecordTypeId, Description__c, Goal_Type__c,Count__c,Amount__c,Percent__c, Parent_Personal_Goal__c, Payee__c, Period_End__c,
                                    Period_Start__c, Personal_Plan__c, Rate_Template__c, Primary_Goal__c, Sales_Role_Percentage__c, 
                                    Standard_Goal__c, Standard_Goal_Detail__c,Standard_Goal_Detail__r.Name, Tenure_Percentage__c, Value__c, Value_Type__c, Editable__c,
                                    Autocreated__c from Personal_Goal__c];
        
        //Query through task
        List<Task> task = [Select Id, Description, Priority, Subject, ActivityDate, Status from Task];
        
        //Assert for result
        System.assertEquals(1, task.size());
        System.assertEquals('Test 1', task[0].Description);
        System.assertEquals('Completed', task[0].Status);  
        System.assertEquals(6, pGQ.size());
        System.assertEquals(100, pGQ[4].Percent__c);
        System.assertEquals(100, pGQ[5].Percent__c);
        
        
        //Instance of controller
        controller = new CreatePersonalGoalsFromStdGoalController();
        
        //Assign values to Standard Goal with Count
        controller.stdPersonalGoal.Standard_Goal__c = standardGoalsList[1].Id;
        
        //Variable to hold limit to from select option
        controller.selectedLimitToValue = '1';
        
        //Calling controller method 
        controller.loadPayees();
        
        //Assert for results
        System.AssertEquals(1, controller.availablePayees.size());   
        
        //Select payee from the page list
        controller.availablePayees[0].selected = true;
        
        //Calling controller method 
        controller.selectPayee();
        
        //Assert for results
        System.AssertEquals(1, controller.selectedPayees.size());
        System.AssertEquals(3, controller.createPGBegains.size()); 
        
        //Create Personal Goal section
        //Variable to hold select period
        controller.selectedPeriod = controller.createPGBegains[1].getValue();
        
        //Calling controller method 
        controller.drawCreatePersonalGoalSection();
        
        //Set row index , column index and item index
        ApexPages.currentPage().getParameters().put('rowIndex', '0');
        ApexPages.currentPage().getParameters().put('colIndex', '0');
        ApexPages.currentPage().getParameters().put('itemIndex', '0');
        ApexPages.currentPage().getParameters().put('desc', 'Test 1');
        controller.createPGSecWrapper[0].stdGoalDetails[0].stdGDetailPacings[0].pGoal.Count__c = 2000000;
        
        //call method
        controller.addDescription(); 
        
        //set value
        ApexPages.currentPage().getParameters().put('rowIndex', '0');
        ApexPages.currentPage().getParameters().put('colIndex', '0');
        ApexPages.currentPage().getParameters().put('itemIndex', '0');
        controller.createPGSecWrapper[0].stdGoalDetails[0].stdGDetailPacings[0].pGoal.Count__c = 2000000;
        
        //call method
        controller.doItemGoalCalculation();
        
        //set value
        ApexPages.currentPage().getParameters().put('rowIndex', '0');
        ApexPages.currentPage().getParameters().put('itemIndex', '0');
        ApexPages.currentPage().getParameters().put('selectCB','selectCB');
        
        //call method
        controller.doInclineGoalCalculation();
        controller.doGlobalSelectRowAndCalc();
        controller.loadPayeeStaffRelationships();
        
        ApexPages.currentPage().getParameters().put('selectCB','selectCB');
        controller.fatchStdGoalDetailConditions();
        controller.fatchGTDMPeriods();
        
        //call method
        controller.doSave();
         
        //Query through personal goals
        pGQ = [Select Id, Name, RecordTypeId, Description__c, Goal_Type__c,Count__c,Amount__c,Percent__c, Parent_Personal_Goal__c, Payee__c, Period_End__c,
                                    Period_Start__c, Personal_Plan__c, Rate_Template__c, Primary_Goal__c, Sales_Role_Percentage__c, 
                                    Standard_Goal__c, Standard_Goal_Detail__c,Standard_Goal_Detail__r.Name, Tenure_Percentage__c, Value__c, Value_Type__c, Editable__c,
                                    Autocreated__c from Personal_Goal__c];
        
        //Query through task
        task = [Select Id, Description, Priority, Subject, ActivityDate, Status from Task];
        
        //Assert for result
        System.assertEquals(1, task.size());
        System.assertEquals('Test 1', task[0].Description);
        System.assertEquals('Completed', task[0].Status);  
        System.assertEquals(6, pGQ.size());
         
    }   
}