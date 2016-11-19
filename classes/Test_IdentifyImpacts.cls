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
 * to a production organization to confirm correctness, 
 ensure code
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
private class Test_IdentifyImpacts {
    
    
    /**
     *   Purpose         :   Test class for IdentifyImpact Controller class
     *            
     *   Create By       :   Subhash Garhwal
     *
     *   Created Date    :   11/16/2015
     *
     *   Revision Log    :   V_1.0 - Created - 
     *                   :   V_2.0 - Modifieid - Rajeev Jain - CR-20151120-9402 - 04/20/2016 - Remvoed the usage of the old fields as per the updated SDD of the Change management.
     *                              Corrected Asserts of the Class               
     *
     *   Coverage        :   95%
     **/
    static testMethod void testIdentifyImpactsFunctionality() {
        
        //Create an institution
        Account account = TestUtilities.CreateNewAccount(false);
        
        //Insert
        insert account;
        
        //List Of contact
        List<Contact> contacts = new List<Contact>();
        
        //Add Record in List
        contacts.add(new Contact(FirstName = 'Test 1', LastName = 'Contact 1', Email = 'test@test.com', AccountId = account.Id,
                                      Employee_User_Record__c = Userinfo.getUserId()));
        contacts.add(new Contact(FirstName = 'Test 2', LastName = 'Contact 2', Email = 'test@test.com', AccountId = account.Id,
                                      Employee_User_Record__c = Userinfo.getUserId()));
        contacts.add(new Contact(FirstName = 'Test 3', LastName = 'Contact 3', Email = 'test@test.com', AccountId = account.Id,
                                      Employee_User_Record__c = Userinfo.getUserId()));
        contacts.add(new Contact(FirstName = 'Test 4', LastName = 'Contact 3', Email = 'test@test.com', AccountId = account.Id,
                                      Employee_User_Record__c = Userinfo.getUserId()));
        //Insert
        insert contacts;   
        
        //Assert
        System.assert(contacts.size() > 0);
        
        //List of Program
        List<Program__c> programs = new List<Program__c>();
        
        //Add new Programs in list
        programs.add(new Program__c(Name = 'Test Program 1', Status__c = 'Active'));
        programs.add(new Program__c(Name = 'Test Program 2', Status__c = 'Active'));
        programs.add(new Program__c(Name = 'Test Program 3', Status__c = 'Active'));
        programs.add(new Program__c(Name = 'Test Program 3', Status__c = 'Active'));
        
        //Insert
        insert programs;
        
        //Assert
        System.assert(programs.size() > 0);
        
        //List of Program Groups
        List<Program_Group__c> programCollections = new List<Program_Group__c>();
        
        //Add new Program Groups in list
        programCollections.add(new Program_Group__c(Name = 'Test PG 1', Effective_Start__c = System.today().addDays(-3), Effective_End__c = System.today(),
                                               Business_Owner__c = contacts[0].Id, Short_Name__c = 'test12',Active__c = true));
        programCollections.add(new Program_Group__c(Name = 'Test PG 2', Effective_Start__c = System.today().addDays(-5), Effective_End__c = System.today(),
                                               Business_Owner__c = contacts[0].Id, Short_Name__c = 'test13', Active__c = true));
        programCollections.add(new Program_Group__c(Name = 'Test PG 3', Effective_Start__c = System.today().addDays(-2), Effective_End__c = System.today(),
                                               Business_Owner__c = contacts[0].Id, Short_Name__c = 'test14', Active__c = true));
        programCollections.add(new Program_Group__c(Name = 'Test PG 4', Effective_Start__c = System.today().addDays(-1), Effective_End__c = System.today(),
                                               Business_Owner__c = contacts[0].Id, Short_Name__c = 'test15', Active__c = true));
        programCollections.add(new Program_Group__c(Name = 'Test PG 5', Effective_Start__c = System.today(), Effective_End__c = System.today(),
                                               Business_Owner__c = contacts[0].Id, Short_Name__c = 'test16', Active__c = true));
        
        //Insert
        insert programCollections;
        
        //Assert
        System.assert(programCollections.size() > 0);
        
        //List of Perspective
        List<Perspective__c> perspectives = new List<Perspective__c>();
        
        //Add new Perspective record in list
        perspectives.add(new Perspective__c(Name = 'Test Perspective 1', Business_Owner__c = contacts[0].Id, Short_Name__c = '1232Test230', Active__c = true));
        perspectives.add(new Perspective__c(Name = 'Test Perspective 2', Business_Owner__c = contacts[0].Id, Short_Name__c = '1332Test230', Active__c = true));
        perspectives.add(new Perspective__c(Name = 'Test Perspective 3', Business_Owner__c = contacts[0].Id, Short_Name__c = '1222Test230', Active__c = true));
        
        //Insert
        insert perspectives;
        
        //Assert
        System.assert(perspectives.size() > 0);
        
        //List of Program Perspective
        List<Program_Perspective__c> programPerspectives = new List<Program_Perspective__c>();
        
        //Add new Program Perspective in list
        programPerspectives.add(new Program_Perspective__c(Name = 'PP 1', Program_Group__c = programCollections[0].Id, Perspective__c = perspectives[0].Id,
                                                           Business_Owner__c = contacts[0].Id, Effective_Start__c = System.today(), Effective_End__c = System.today().addDays(4), 
                                                           In_use_Plans_Direct__c = 2, In_use_Plans_Indirect__c = 2, Active__c = true));
        
        programPerspectives.add(new Program_Perspective__c(Name = 'PP 2', Program_Group__c = programCollections[1].Id, Perspective__c = perspectives[1].Id,
                                                           Business_Owner__c = contacts[0].Id, Effective_Start__c = System.today(), Effective_End__c = System.today().addDays(4), Active__c = true));
        
        programPerspectives.add(new Program_Perspective__c(Name = 'PP 3', Program_Group__c = programCollections[2].Id, Perspective__c = perspectives[2].Id,
                                                           Business_Owner__c = contacts[1].Id, Effective_Start__c = System.today(), Effective_End__c = System.today().addDays(4), Active__c = true));
                                                           
        programPerspectives.add(new Program_Perspective__c(Name = 'PP 4', Program_Group__c = programCollections[0].Id, Perspective__c = perspectives[1].Id,
                                                           Business_Owner__c = contacts[1].Id, Effective_Start__c = System.today(), Effective_End__c = System.today().addDays(4), Active__c = true));
        
        programPerspectives.add(new Program_Perspective__c(Name = 'PP 5', Program_Group__c = programCollections[4].Id, Perspective__c = perspectives[1].Id,
                                                           Business_Owner__c = contacts[1].Id, Effective_Start__c = System.today(), Effective_End__c = System.today().addDays(4), Active__c = true));
        
        //Insert
        insert programPerspectives;
        
        //Assert
        System.assert(programPerspectives.size() > 0);
        
        //Query on Program Relation Ship Record Types
        List<RecordType> cpcReocrdTypeList = [Select Id, DeveloperName From RecordType Where SobjectType = 'Program_Relationship__c' AND IsActive = true ORDER BY DeveloperName ASC];
        
        //List of Program Relationship
        List<Program_Relationship__c> collectionPerspectiveChildrens = new List<Program_Relationship__c>();
        
        //Add new Program Relationship in list
        collectionPerspectiveChildrens.add(new Program_Relationship__c(Name = 'Test PR 1', Program_Perspective__c = programPerspectives[0].Id, Program__c = programs[0].Id, Business_Owner__c = contacts[0].Id, 
                                           Effective_Start__c = System.today(), Effective_End__c = System.today().addDays(3), RecordTypeId = cpcReocrdTypeList[1].Id));
        
        collectionPerspectiveChildrens.add(new Program_Relationship__c(Name = 'Test PR 2', Program_Perspective__c = programPerspectives[0].Id, Program__c = programs[1].Id, Business_Owner__c = contacts[0].Id, 
                                           Effective_Start__c = System.today(), Effective_End__c = System.today().addDays(3), RecordTypeId = cpcReocrdTypeList[1].Id));
        
        collectionPerspectiveChildrens.add(new Program_Relationship__c(Name = 'Test PR 3', Program_Perspective__c = programPerspectives[1].Id, Program__c = programs[1].Id, Business_Owner__c = contacts[1].Id,
                                           Effective_Start__c = System.today(), Effective_End__c = System.today().addDays(3), RecordTypeId = cpcReocrdTypeList[1].Id));
        
        collectionPerspectiveChildrens.add(new Program_Relationship__c(Name = 'Test PR 4', Program_Perspective__c = programPerspectives[2].Id, Program__c = programs[2].Id, Business_Owner__c = contacts[1].Id, 
                                           Effective_Start__c = System.today(), Effective_End__c = System.today().addDays(3), RecordTypeId = cpcReocrdTypeList[1].Id));
        
        collectionPerspectiveChildrens.add(new Program_Relationship__c(Name = 'Test PR 5', Program_Perspective__c = programPerspectives[1].Id, Program_Group__c = programCollections[2].Id, Business_Owner__c = contacts[1].Id, 
                                           Effective_Start__c = System.today(), Effective_End__c = System.today().addDays(3), RecordTypeId = cpcReocrdTypeList[1].Id));
        
        collectionPerspectiveChildrens.add(new Program_Relationship__c(Name = 'Test PR 6', Program_Perspective__c = programPerspectives[2].Id, Program_Group__c = programCollections[3].Id, Business_Owner__c = contacts[1].Id, 
                                           Effective_Start__c = System.today(), Effective_End__c = System.today().addDays(3), RecordTypeId = cpcReocrdTypeList[1].Id));
        
        collectionPerspectiveChildrens.add(new Program_Relationship__c(Name = 'Test PR 7', Program_Perspective__c = programPerspectives[4].Id, Program_Group__c = programCollections[3].Id, Business_Owner__c = contacts[1].Id, 
                                           Effective_Start__c = System.today(), Effective_End__c = System.today().addDays(3), RecordTypeId = cpcReocrdTypeList[1].Id));
        
        //Insert
        insert collectionPerspectiveChildrens;
        
        
        //Insert Assignment Role records
        Team_Role__c assignmentRole = new Team_Role__c(Active__c = true, Business_Owner__c = contacts[0].Id, Name = 'Associate Manager', Institution__c = true);
        insert assignmentRole;
        
        //Insert Staff Assignment Records 
        List<Team_Membership__c> staffAssignements = new List<Team_Membership__c>();
        staffAssignements.add(new Team_Membership__c(Institution__c = account.Id, Staff_member__c = contacts[0].Id, Start_date__c = Date.Today(),
                                                        Role__c = assignmentRole.Id));
        staffAssignements.add(new Team_Membership__c(Institution__c = account.Id, Staff_member__c = contacts[1].Id, Start_date__c = Date.Today(),
                                                        Role__c = assignmentRole.Id));
        staffAssignements.add(new Team_Membership__c(Institution__c = account.Id, Staff_member__c = contacts[2].Id, Start_date__c = Date.Today(),
                                                        Role__c = assignmentRole.Id));
        
        insert staffAssignements;
        
        //Insert List of Staff Attribute
        //List of Value Type
        List<Value_Type__c> valueTypes = new List<Value_Type__c>();
        
        valueTypes.add(new Value_Type__c(Values_Permitted__c = 'Date',Category__c = 'Goals'));
        valueTypes.add(new Value_Type__c(Values_Permitted__c = 'Text', Category__c = 'Goals'));
        valueTypes.add(new Value_Type__c(Values_Permitted__c = 'Program Collection',Category__c = 'Goals'));
        valueTypes.add(new Value_Type__c(Values_Permitted__c = 'Percentage', Category__c = 'Goals'));
        
        //Insert
        insert valueTypes;
        
        //Assert 
        System.Assert(valueTypes.size() > 0);
        
        //List of Staff History
        List<Staff_History__c> staffHistory = new List<Staff_History__c>();

        //Add new Staff History in list.
        staffHistory.add(new Staff_History__c(Staff_Member__c = contacts[0].Id, Value_Type__c = valueTypes[0].Id, Start_Date__c = System.today().addDays(1), 
                                              Date_Value__c = System.today()));
        staffHistory.add(new Staff_History__c(Staff_Member__c = contacts[1].Id, Value_Type__c = valueTypes[1].Id, Start_Date__c = System.today().addDays(5),
                                              End_Date__c = System.today().addDays(10), Text_Value__c = 'Testing'));
        //Using Collection Perspective
        staffHistory.add(new Staff_History__c(Staff_Member__c = contacts[0].Id, Value_Type__c = valueTypes[2].Id, Start_Date__c = System.today().addDays(61), 
                                              End_Date__c = System.today().addDays(70), Lookup_Value__c = programPerspectives[2].Id));
        staffHistory.add(new Staff_History__c(Staff_Member__c = contacts[3].Id, Value_Type__c = valueTypes[2].Id, Start_Date__c = System.today().addDays(71), 
                                              End_Date__c = System.today().addDays(80), Lookup_Value__c = programPerspectives[3].Id));
        staffHistory.add(new Staff_History__c(Staff_Member__c = contacts[1].Id, Value_Type__c = valueTypes[2].Id, Start_Date__c = System.today().addDays(81), 
                                              End_Date__c = System.today().addDays(90), Lookup_Value__c = programPerspectives[3].Id));                                    
        
        //Insert 
        insert staffHistory;
        
        //Assert 
        System.Assert(staffHistory.size() > 0);
        
        //Assert
        System.assert(collectionPerspectiveChildrens.size() > 0);
        
        //Create Goal Types
        List<Goal_Type__c> goalTypes = new List<Goal_Type__c>();
        
        //Add new goal type in list
        goalTypes.add(new Goal_Type__c(Name = 'TestGoalType1', Active__c = true, Standard_Goal__c = true, Base_Process__c = 'NBB', Description__c = 'Testing of Goal Type'));
        goalTypes.add(new Goal_Type__c(Name = 'TestGoalType2', Active__c = true, Standard_Goal__c = true, Base_Process__c = 'CM', Description__c = 'Testing of Goal Types'));
        
        //Insert 
        insert goalTypes;
        
        //Assert
        System.assert(goalTypes.size() > 0);
        
        //Create Standard Goals
        List<Standard_Goal__c> standardGoals = new List<Standard_Goal__c>();
        
        //Add new Standard Goals in list
        standardGoals.add(new Standard_Goal__c(Name = 'StandardGoal1', Active__c = true, Amount__c = 100, Business_Owner__c = contacts[0].Id, Description__c = 'Testing of Standard Goal', Goal_Type__c = goalTypes[0].Id, 
                                               Period_Start__c = System.today(), Period_End__c = System.today().addDays(4)));
        standardGoals.add(new Standard_Goal__c(Name = 'StandardGoal2', Active__c = true, Amount__c = 200, Business_Owner__c = contacts[0].Id, Description__c = 'Testing of Standard Goal', Goal_Type__c = goalTypes[1].Id,
                                               Period_Start__c = System.today().addDays(10), Period_End__c = System.today().addDays(20)));
        standardGoals.add(new Standard_Goal__c(Name = 'StandardGoal1', Active__c = true, Amount__c = 100, Business_Owner__c = contacts[1].Id, Description__c = 'Testing of Standard Goal', Goal_Type__c = goalTypes[0].Id, 
                                               Period_Start__c = System.today().addDays(21), Period_End__c = System.today().addDays(30)));
        standardGoals.add(new Standard_Goal__c(Name = 'StandardGoal2', Active__c = true, Amount__c = 200, Business_Owner__c = contacts[1].Id, Description__c = 'Testing of Standard Goal', Goal_Type__c = goalTypes[1].Id, 
                                               Period_Start__c = System.today().addDays(31), Period_End__c = System.today().addDays(40)));
        //Insert 
        insert standardGoals;
        
        //Assert
        System.assert(standardGoals.size() > 0);
        
        //Create Standard Goal Details
        List<Standard_Goal_Detail__c> standardGoalDetails = new List<Standard_Goal_Detail__c>();
        
        //Add new Standard Goal Details in list
        standardGoalDetails.add(new Standard_Goal_Detail__c(Name = 'StandardGoalDetail1', Active__c = true, Description__c = 'Testing',Target_Type__c = 'Paced',
                                                            Standard_Goal__c = standardGoals[0].Id));
        standardGoalDetails.add(new Standard_Goal_Detail__c(Name = 'StandardGoalDetail2', Active__c = true, Description__c = 'Testing',Target_Type__c = 'Paced',
                                                            Standard_Goal__c = standardGoals[0].Id));
        standardGoalDetails.add(new Standard_Goal_Detail__c(Name = 'StandardGoalDetail1', Active__c = true, Description__c = 'Testing',Target_Type__c = 'Paced',
                                                            Standard_Goal__c = standardGoals[1].Id));
        standardGoalDetails.add(new Standard_Goal_Detail__c(Name = 'StandardGoalDetail2', Active__c = true, Description__c = 'Testing',Target_Type__c = 'Paced',
                                                            Standard_Goal__c = standardGoals[1].Id));
        
        //Insert 
        insert standardGoalDetails;
        
        //Assert
        System.assert(standardGoalDetails.size() > 0);
        
        //List of record type
        List<RecordType> recordTypes = [select Id, DeveloperName From RecordType Where SObjectType = 'Personal_Goal__c' 
                                        AND DeveloperName IN ('Personal_Goal', 'Proposal') ORDER BY DeveloperName ASC LIMIT 2];
        
        //Create Personal Goal
        List<Personal_Goal__c> personalGoals = new List<Personal_Goal__c>();
        
        //Add new Personal Goal in list
        personalGoals.add(new Personal_Goal__c(Name = 'PersonalGoal1', Goal_Type__c = goalTypes[0].Id, Active__c = true, RecordTypeId = recordTypes[1].Id,
                                               Description__c = 'Testing 1', Amount__c = 100, Standard_Goal_Detail__c = standardGoalDetails[0].Id, Payee__c = contacts[0].Id,
                                               Period_Start__c = System.today().addDays(1), Period_End__c = System.today().addDays(10)));
        personalGoals.add(new Personal_Goal__c(Name = 'PersonalGoal2', Goal_Type__c = goalTypes[0].Id, Active__c = true, RecordTypeId = recordTypes[1].Id,
                                               Description__c = 'Testing 2', Amount__c = 100, Standard_Goal_Detail__c = standardGoalDetails[0].Id, Payee__c = contacts[1].Id,
                                               Period_Start__c = System.today().addDays(12), Period_End__c = System.today().addDays(20)));
        personalGoals.add(new Personal_Goal__c(Name = 'PersonalGoal1', Goal_Type__c = goalTypes[0].Id, Active__c = true, RecordTypeId = recordTypes[1].Id,
                                               Description__c = 'Testing 3', Amount__c = 100, Standard_Goal_Detail__c = standardGoalDetails[0].Id, Payee__c = contacts[0].Id,
                                               Period_Start__c = System.today().addDays(1), Period_End__c = System.today().addDays(10)));
        personalGoals.add(new Personal_Goal__c(Name = 'PersonalGoal2', Goal_Type__c = goalTypes[0].Id, Active__c = true, RecordTypeId = recordTypes[1].Id,
                                               Description__c = 'Testing 4', Amount__c = 100, Standard_Goal_Detail__c = standardGoalDetails[0].Id, Payee__c = contacts[1].Id,
                                               Period_Start__c = System.today().addDays(12), Period_End__c = System.today().addDays(20)));
        
        //Insert
        insert personalGoals;
        
        //Assert
        System.assert(personalGoals.size() > 0);
        
        //Create Personal Goal
        List<Personal_Goal__c> personalGoalsList = new List<Personal_Goal__c>();
        
        personalGoalsList.add(new Personal_Goal__c(Name = 'PersonalGoal1', Goal_Type__c = goalTypes[0].Id, Active__c = true, RecordTypeId = recordTypes[1].Id,Active_Proposal__c = personalGoals[0].Id,
                                               Description__c = 'Testing 3', Amount__c = 100, Standard_Goal_Detail__c = standardGoalDetails[0].Id, Payee__c = contacts[0].Id,
                                               Period_Start__c = System.today().addDays(1), Period_End__c = System.today().addDays(10)));
        personalGoalsList.add(new Personal_Goal__c(Name = 'PersonalGoal2', Goal_Type__c = goalTypes[0].Id, Active__c = true, RecordTypeId = recordTypes[1].Id,Active_Proposal__c = personalGoals[1].Id,
                                               Description__c = 'Testing 4', Amount__c = 100, Standard_Goal_Detail__c = standardGoalDetails[0].Id, Payee__c = contacts[1].Id,
                                               Period_Start__c = System.today().addDays(12), Period_End__c = System.today().addDays(20)));
        
        //Insert
        insert personalGoalsList;
        
        //Assert
        System.assert(personalGoalsList.size() > 0);
        
        //Query on Record Type
        List<RecordType> collectionPerspectiveCondRecordType = [select Id, DeveloperName From RecordType Where SObjectType = 'Condition__c' 
                                        AND DeveloperName = 'Collection_Perspective'];
        
        //Map to hhold the Record Type Id corrosponding to its Developer Name
        Map<String,Id> conditionsRecordType = new Map<String,Id>();
        
        for(RecordType rt : [select Id, DeveloperName From RecordType Where SObjectType = 'Condition__c'])
            conditionsRecordType.put(rt.DeveloperName, rt.Id);
        
        
        //Inserts conditions for Personal GOal and Populate Program Collection Lookup field on condition 
        List<Condition__c> condList = new List<Condition__c>();
        condList.add(new Condition__c(Condition_Type__c = 'Include', Condition_Set__c = 1.0, RecordTypeId = conditionsRecordType.get('Collection_Perspective'),
                                                Collection_Perspective__c = programPerspectives[0].Id, Personal_Goal__c = personalGoals[0].Id));
        condList.add(new Condition__c(Condition_Type__c = 'Include', Condition_Set__c = 1.0, RecordTypeId = conditionsRecordType.get('Assignment_Role'),
                                                Assignment_Role__c = assignmentRole.Id, Personal_Goal__c = personalGoals[0].Id));
        
        //Insert Cond List
        insert condList;
        
        
        //Start Test
        Test.startTest();
        
        //Now Query on ICL Records and Debugged to check what Kind of data it is returning
        List<Incentive_Change_Log__c> iclList = [select Id, Category__c, Change_Element__c, Change_Record__c, Change_Type__c, Change_value__c, 
                                                        Collection_Perspective_Child__c, Contact__c, Staff_Assignment__c, Staff_History__c,
                                                        Start_Date__c, End_Date__c, Value__c, Incentive_Change_Batch__c from Incentive_Change_Log__c];
        
        //Create Incentive Change Batch Record and Assing it to each ICL record
        Incentive_Change_Batch__c iCB = new Incentive_Change_Batch__c();
        iCB.Applied__c = System.Today();
        iCB.Name = 'ICB 1';
        
        insert iCB;
        
        //Loop over ICL List and Populate this batch
        for(Incentive_Change_Log__c icl : iclList)
            icl.Incentive_Change_Batch__c = iCB.Id;
        
        update iclList;
             
          //Standard Controller
        Apexpages.StandardController iCBSTD = new Apexpages.StandardController(iCB);
        
        //Instance of controller
        IdentifyImpacts controller = new IdentifyImpacts(iCBSTD);
        
        //Put Perameter From URL
        Apexpages.currentPage().getParameters().Put('id',iCB.Id);
        
        //Call method
        PageReference pR = controller.indentifyImpact();
        
        //Asserts for Results
        List<Affected_Goal__c> agList = [select Id from Affected_Goal__c where Incentive_Change_Batch__c = :iCB.Id];
        
        System.assertEquals(true, agList.size() > 0);
        
        System.assertEquals(7, agList.size());
        
         //LiSt of Relationship Type
        List<Relationship_Type__c> relationshipTypes = new List<Relationship_Type__c>();
        
        //Add Record in List
        relationshipTypes.add(new Relationship_Type__c(Business_Owner__c = contacts[0].Id, Name_When_From__c = 'Testing From', Name_When_To__c = 'Testing To', Active__c = true));
        relationshipTypes.add(new Relationship_Type__c(Business_Owner__c = contacts[0].Id, Name_When_From__c = 'Testing From', Name_When_To__c = 'Testing To', Active__c = true));
        relationshipTypes.add(new Relationship_Type__c(Business_Owner__c = contacts[1].Id, Name_When_From__c = 'Testing From', Name_When_To__c = 'Testing To', Active__c = true));
        
        //Insert
        insert relationshipTypes;
        
        //Assert
        System.assert(relationshipTypes.size() > 0);
        
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
        
        personalGoalRelationships.add(new Personal_Goal_Relationship__c(Name = 'PGR 1', Personal_Goal__c = personalGoals[0].Id, Relationship__c = Staffrelationships[0].Id));
        personalGoalRelationships.add(new Personal_Goal_Relationship__c(Name = 'PGR 1', Personal_Goal__c = personalGoals[1].Id, Relationship__c = Staffrelationships[0].Id));
        personalGoalRelationships.add(new Personal_Goal_Relationship__c(Name = 'PGR 1', Personal_Goal__c = personalGoals[2].Id, Relationship__c = Staffrelationships[1].Id));
        personalGoalRelationships.add(new Personal_Goal_Relationship__c(Name = 'PGR 1', Personal_Goal__c = personalGoals[3].Id, Relationship__c = Staffrelationships[1].Id));
        
        //Insert 
        insert personalGoalRelationships;
        
        //Assert
        System.assert(personalGoalRelationships.size() > 0);
        
        //ICL Records Of contact Element only eligible in identifying Affected goal if ICL records are Change Type = Modified
        //Update all contact Records
        contacts[0].Employment_Start__c = Date.today();
        contacts[1].Employment_Start__c = Date.today();
        contacts[2].Employment_Start__c = Date.today();
        contacts[3].Employment_Start__c = Date.today();
        
        update contacts;
        
        List<Incentive_Change_Log__c> iclList1 = [select Id, Category__c, Change_Element__c, Change_Record__c, Change_Type__c, Change_value__c, 
                                                        Collection_Perspective_Child__c, Contact__c, Staff_Assignment__c, Staff_History__c,
                                                        Start_Date__c, End_Date__c, Value__c, Incentive_Change_Batch__c from Incentive_Change_Log__c where Change_Element__c = :ISSPConstants.INCENTIVE_CHANGE_LOG_CHANGE_ElEMENT_CONTACT
                                                        AND Start_Date__c != null];
                                                        
        //Check if four ICL Records created and their change type is Modified
        for(Incentive_Change_Log__c icl : iclList1){
            System.assertEquals(ISSPConstants.INCENTIVE_CHANGE_LOG_CHANGE_TYPE_MODIFIED, icl.Change_Type__c);
        }
        
        //Create Incentive Change Batch Record and Assing it to each ICL record
        Incentive_Change_Batch__c iCB1 = new Incentive_Change_Batch__c();
        iCB1.Applied__c = System.Today();
        iCB1.Name = 'ICB 2';
        
        insert iCB1;
        
        //Loop over ICL List and Populate this batch
        for(Incentive_Change_Log__c icl : iclList1)
            icl.Incentive_Change_Batch__c = iCB1.Id;
        
        update iclList1;
             
          //Standard Controller
        Apexpages.StandardController iCBSTD1 = new Apexpages.StandardController(iCB1);
        
        //Instance of controller
        IdentifyImpacts controller1 = new IdentifyImpacts(iCBSTD1);
        
        //Put Perameter From URL
        Apexpages.currentPage().getParameters().Put('id',iCB1.Id);
        
        //Call method
        PageReference pR1 = controller1.indentifyImpact();
        
        //Asserts for Results
        List<Affected_Goal__c> agList1 = [select Id from Affected_Goal__c where Incentive_Change_Batch__c = :iCB1.Id];
        
        System.assertEquals(true, agList1.size() > 0);
        
        //Test Stop Here
        Test.stopTest();
    }
}