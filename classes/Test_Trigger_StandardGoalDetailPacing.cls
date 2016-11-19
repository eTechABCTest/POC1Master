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
private class Test_Trigger_StandardGoalDetailPacing {
  /**
    *   Purpose         :   Test class for Trigger_StandardGoalDetailPacing
    *            
    *   Create By       :   Padmesh Soni
    *
    *   Created Date    :   08/12/2015
    *
    *   Revision Log    :   V_1.0 - Created - Padmesh Soni - CR-20150729-9114
    *                       V_1.1 - Modified - Subhash Garhwal - CR-20150729-9114 - 09/02/2015 - Add new method validateRUSFields       
    * 
    *   Coverage        :   V_1.0 - 100%
    *                       V_1.1 - 100%
    **/
  
    //Test method for validateStandardGDPacing method
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
        
        //Create Goal Types
        List<Goal_Type__c> goalTypes = new List<Goal_Type__c>();
        
        //Add new goal type in list
        goalTypes.add(new Goal_Type__c(Name = 'TestGoalType1', Standard_Goal__c = true, Active__c = true, Base_Process__c = 'NBB', Description__c = 'Testing of Goal Type'));
        goalTypes.add(new Goal_Type__c(Name = 'TestGoalType2', Standard_Goal__c = true, Active__c = true, Base_Process__c = 'CM', Description__c = 'Testing of Goal Types'));
        goalTypes.add(new Goal_Type__c(Name = 'TestGoalType3', Standard_Goal__c = true, Active__c = false, Base_Process__c = 'Activity', Description__c = 'Testing of Goal'));
        goalTypes.add(new Goal_Type__c(Name = 'TestGoalType4', Standard_Goal__c = true, Active__c = false, Base_Process__c = 'Renewal', Description__c = 'Goal Type'));
        
        //Insert 
        insert goalTypes;

        //List of Record Type
        List<RecordType> recordTypes = [select Id, DeveloperName From RecordType Where SObjectType = 'Standard_Goal__c' ORDER BY DeveloperName ASC];
        
        //Create Standard Goals
        List<Standard_Goal__c> standardGoals = new List<Standard_Goal__c>();
        
        //Add new Standard Goals in list
        standardGoals.add(new Standard_Goal__c(Name = 'StandardGoal1', Active__c = true, Amount__c = 100, Business_Owner__c = contact.Id,
                                               Description__c = 'Testing of Standard Goal', Goal_Type__c = goalTypes[0].Id, 
                                               RecordTypeId = recordTypes[0].Id, 
                                               Period_Start__c = System.today(), Period_End__c = System.today().addDays(4)));
        standardGoals.add(new Standard_Goal__c(Name = 'StandardGoal2', Active__c = true, Amount__c = 200, Business_Owner__c = contact.Id,
                                               RecordTypeId = recordTypes[0].Id,
                                               Description__c = 'Testing of Standard Goal', Goal_Type__c = goalTypes[1].Id,
                                               Period_Start__c = System.today().addDays(10), Period_End__c = System.today().addDays(20)));
        standardGoals.add(new Standard_Goal__c(Name = 'StandardGoal3', Active__c = false, Amount__c = 300, Business_Owner__c = contact.Id,
                                               Description__c = 'Testing of Standard Goal', Goal_Type__c = goalTypes[1].Id,
                                               RecordTypeId = recordTypes[0].Id,
                                               Period_Start__c = System.today().addDays(25), Period_End__c = System.today().addDays(30)));
        
        //Insert 
        insert standardGoals;
                               
        //Create Standard Goal Details
        List<Standard_Goal_Detail__c> standardGoalDetails = new List<Standard_Goal_Detail__c>();
        
        //Add new Standard Goal Details in list
        standardGoalDetails.add(new Standard_Goal_Detail__c(Name = 'StandardGoalDetail1', Active__c = true, Description__c = 'Testing',
                                                            Standard_Goal__c = standardGoals[0].Id));
        standardGoalDetails.add(new Standard_Goal_Detail__c(Name = 'StandardGoalDetail2', Active__c = true, Description__c = 'Testing',
                                                            Standard_Goal__c = standardGoals[0].Id));
        standardGoalDetails.add(new Standard_Goal_Detail__c(Name = 'StandardGoalDetail3', Active__c = true, Description__c = 'Testing',
                                                            Standard_Goal__c = standardGoals[1].Id));
        standardGoalDetails.add(new Standard_Goal_Detail__c(Name = 'StandardGoalDetail4', Active__c = true, Description__c = 'Testing',
                                                            Standard_Goal__c = standardGoals[1].Id));
        standardGoalDetails.add(new Standard_Goal_Detail__c(Name = 'StandardGoalDetail5', Active__c = true, Description__c = 'Testing',
                                                            Standard_Goal__c = standardGoals[2].Id));
        
        //Insert 
        insert standardGoalDetails;
        
        //Create Standard Goal Detail Pacing
        List<Standard_Goal_Detail_Pacing__c> sGDPacings = new List<Standard_Goal_Detail_Pacing__c>();
        
        //Add standard goal detail pacing in list
        sGDPacings.add(new Standard_Goal_Detail_Pacing__c(Name = 'Test', Standard_Goal_Detail__c = standardGoalDetails[0].Id, 
                                                          Standard_Goal__c = standardGoals[0].Id, Description__c = 'Test', 
                                                          Period_Start__c = System.today(), Period_End__c = System.today().addDays(10),
                                                          Percent_Manual__c = 50));
        sGDPacings.add(new Standard_Goal_Detail_Pacing__c(Name = 'Test', Standard_Goal_Detail__c = standardGoalDetails[0].Id, 
                                                          Standard_Goal__c = standardGoals[0].Id, Description__c = 'Test', 
                                                          Period_Start__c = System.today().addDays(12), Period_End__c = System.today().addDays(20),
                                                          Percent_Manual__c = 50));
        sGDPacings.add(new Standard_Goal_Detail_Pacing__c(Name = 'Test', Standard_Goal_Detail__c = standardGoalDetails[0].Id, 
                                                          Standard_Goal__c = standardGoals[0].Id, Description__c = 'Test', 
                                                          Period_Start__c = System.today().addDays(21), Period_End__c = System.today().addDays(40),
                                                          Percent_Manual__c = 50));
        
        //Start testing from here
        Test.startTest();
        
        //Try to insert record that will throw an exception that will cover in catch part
        try {    
            
            //Insert
            insert sGDPacings;
            
            //Assert for Result
            System.assert(false);
        }
        
        //Catch block to handle exception
        catch(Exception ex) {
        
            //Assert for Result
            System.assert(ex.getMessage().contains(Label.ERROR_CONTINUOUS_SGDP));
        }
        
        //Update SGDP record with start date and insert
        sGDPacings[1].Period_Start__c = System.today().addDays(14);
        
        //Try to insert record that will throw an exception that will cover in catch part
        try {    
            
            //Insert 
            insert sGDPacings;
            
            //Assert for Result
            System.assert(false);
        }
        
        //Catch block to handle exception
        catch(Exception ex) {
        
            //Assert for Result
            System.assert(ex.getMessage().contains(Label.ERROR_CONTINUOUS_SGDP));
        }
        
        //Update SGDP record with start date and insert
        sGDPacings[1].Period_Start__c = System.today();
        
        //Try to insert record that will throw an exception that will cover in catch part
        try {    
            
            //Insert 
            insert sGDPacings;
            
            //Assert for Result
            System.assert(false);
        }
        
        //Catch block to handle exception
        catch(Exception ex) {
        
            //Assert for Result
            System.assert(ex.getMessage().contains(Label.ERROR_UNIQUENESS_SGDP));
        }
        
        //Update SGDP record with start date and insert
        sGDPacings[1].Period_Start__c = System.today().addDays(11);
        
        //Insert
        insert sGDPacings;
        
        //Update SGDP record with start date and insert
        sGDPacings[2].Period_Start__c = System.today().addDays(25);
        
        //Try to update record that will throw an exception that will cover in catch part
        try {    
        
            //Update
            update sGDPacings[2];

            //Assert for Result
            System.assert(false);
        }
        
        //Catch block to handle exception
        catch(Exception ex) {
        
            //Assert for Result
            System.assert(ex.getMessage().contains(Label.ERROR_CONTINUOUS_SGDP));
        }

        //Update SGDP record with start date and insert
        sGDPacings[2].Period_Start__c = System.today().addDays(18);
        
        //Try to update record that will throw an exception that will cover in catch part
        try {    
        
            //Update
            update sGDPacings[2];

            //Assert for Result
            System.assert(false);
        }
        
        //Catch block to handle exception
        catch(Exception ex) {
        
            //Assert for Result
            System.assert(ex.getMessage().contains(Label.ERROR_UNIQUENESS_SGDP));
        }
        
        //Update SGDP record with start date and insert
        sGDPacings[2].Period_Start__c = System.today().addDays(21);
        
        //Update
        update sGDPacings[2];

        //Create Standard Goal Detail Pacing
        List<Standard_Goal_Detail_Pacing__c> sGDPacingsNew = new List<Standard_Goal_Detail_Pacing__c>();
        
        //Add record in list
        sGDPacingsNew.add(new Standard_Goal_Detail_Pacing__c(Name = 'Test', Standard_Goal_Detail__c = standardGoalDetails[0].Id, 
                                                          Standard_Goal__c = standardGoals[0].Id, Description__c = 'Test', 
                                                          Period_Start__c = System.today().addDays(41), Period_End__c = System.today().addDays(50),
                                                          Percent_Manual__c = 50));
        
        //Insert
        insert sGDPacingsNew;
        
        //Stop Testing here
        Test.stopTest();
    }

    //V_1.1 - Modified - Subhash Garhwal - CR-20150729-9114 - 09/02/2015
    //Test method for validateRUSFields method 
    static testMethod void myUnitTest1() {

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
        standardGoals.add(new Standard_Goal__c(Name = 'StandardGoal1', Active__c = true, Amount__c = 10000, Business_Owner__c = contact.Id,
                                               Description__c = 'Testing of Standard Goal', Goal_Type__c = goalTypes[0].Id, 
                                               Period_Start__c = System.today(), Period_End__c = System.today().addDays(4)));
        standardGoals.add(new Standard_Goal__c(Name = 'StandardGoal2', Active__c = true, Amount__c = 20000, Business_Owner__c = contact.Id,
                                               Description__c = 'Testing of Standard Goal', Goal_Type__c = goalTypes[1].Id,
                                               Period_Start__c = System.today().addDays(10), Period_End__c = System.today().addDays(20)));
        standardGoals.add(new Standard_Goal__c(Name = 'StandardGoal3', Active__c = true, Counter__c = 1000, Business_Owner__c = contact.Id,
                                               Description__c = 'Testing of Standard Goal', Goal_Type__c = goalTypes[1].Id, 
                                               Period_Start__c = System.today().addDays(25), Period_End__c = System.today().addDays(30)));
        standardGoals.add(new Standard_Goal__c(Name = 'StandardGoal4', Active__c = true, Percent__c = 10, Business_Owner__c = contact.Id,
                                               Description__c = 'Testing of Standard Goal', Goal_Type__c = goalTypes[1].Id, 
                                               Period_Start__c = System.today().addDays(35), Period_End__c = System.today().addDays(40)));
        
        //Insert 
        insert standardGoals;
        
        //Create Standard Goal Details
        List<Standard_Goal_Detail__c> standardGoalDetails = new List<Standard_Goal_Detail__c>();
        
        //Add new Standard Goal Details in list
        standardGoalDetails.add(new Standard_Goal_Detail__c(Name = 'StandardGoalDetail1', Active__c = true, Description__c = 'Testing', Standard_Goal__c = standardGoals[0].Id, Target_Type__c = 'Paced', Baseline_Percentage__c = 100));
        standardGoalDetails.add(new Standard_Goal_Detail__c(Name = 'StandardGoalDetail2', Active__c = true, Description__c = 'Testing', Standard_Goal__c = standardGoals[1].Id, Target_Type__c = 'Paced', Baseline_Percentage__c = 100));
        standardGoalDetails.add(new Standard_Goal_Detail__c(Name = 'StandardGoalDetail3', Active__c = true, Description__c = 'Testing', Standard_Goal__c = standardGoals[1].Id, Target_Type__c = 'Paced', Baseline_Percentage__c = 100));
        standardGoalDetails.add(new Standard_Goal_Detail__c(Name = 'StandardGoalDetail4', Active__c = true, Description__c = 'Testing', Standard_Goal__c = standardGoals[2].Id, Target_Type__c = 'Paced', Baseline_Percentage__c = 100));
        standardGoalDetails.add(new Standard_Goal_Detail__c(Name = 'StandardGoalDetail5', Active__c = true, Description__c = 'Testing', Standard_Goal__c = standardGoals[2].Id, Target_Type__c = 'Paced', Baseline_Percentage__c = 100));
        standardGoalDetails.add(new Standard_Goal_Detail__c(Name = 'StandardGoalDetail6', Active__c = true, Description__c = 'Testing', Standard_Goal__c = standardGoals[3].Id, Target_Type__c = 'Paced', Baseline_Percentage__c = 100));
        
        //Insert 
        insert standardGoalDetails;
        
        //Create Standard Goal Detail Pacing
        List<Standard_Goal_Detail_Pacing__c> sGDPacings = new List<Standard_Goal_Detail_Pacing__c>();
        
        //Add standard goal detail pacing in list
        sGDPacings.add(new Standard_Goal_Detail_Pacing__c(Name = 'Test1', Standard_Goal_Detail__c = standardGoalDetails[0].Id, 
                                                          Standard_Goal__c = standardGoals[0].Id, Description__c = 'Test', 
                                                          Period_Start__c = System.today(), Period_End__c = System.today().addDays(10),
                                                          Percent_Manual__c = 50));
        sGDPacings.add(new Standard_Goal_Detail_Pacing__c(Name = 'Test2', Standard_Goal_Detail__c = standardGoalDetails[0].Id, 
                                                          Standard_Goal__c = standardGoals[0].Id, Description__c = 'Test', 
                                                          Period_Start__c = System.today().addDays(11), Period_End__c = System.today().addDays(20),
                                                          Percent_Manual__c = 50));
        sGDPacings.add(new Standard_Goal_Detail_Pacing__c(Name = 'Test3', Standard_Goal_Detail__c = standardGoalDetails[1].Id, 
                                                          Standard_Goal__c = standardGoals[1].Id, Description__c = 'Test', 
                                                          Period_Start__c = System.today().addDays(21), Period_End__c = System.today().addDays(40),
                                                          Percent_Manual__c = 50));
        sGDPacings.add(new Standard_Goal_Detail_Pacing__c(Name = 'Test4', Standard_Goal_Detail__c = standardGoalDetails[1].Id, 
                                                          Standard_Goal__c = standardGoals[1].Id, Description__c = 'Test', 
                                                          Period_Start__c = System.today().addDays(41), Period_End__c = System.today().addDays(50),
                                                          Percent_Manual__c = 50));
        sGDPacings.add(new Standard_Goal_Detail_Pacing__c(Name = 'Test5', Standard_Goal_Detail__c = standardGoalDetails[4].Id, 
                                                          Standard_Goal__c = standardGoals[2].Id, Description__c = 'Test', 
                                                          Period_Start__c = System.today().addDays(51), Period_End__c = System.today().addDays(60),
                                                          Percent_Manual__c = 50));
        sGDPacings.add(new Standard_Goal_Detail_Pacing__c(Name = 'Test6', Standard_Goal_Detail__c = standardGoalDetails[4].Id, 
                                                          Standard_Goal__c = standardGoals[2].Id, Description__c = 'Test', 
                                                          Period_Start__c = System.today().addDays(61), Period_End__c = System.today().addDays(70),
                                                          Percent_Manual__c = 50));
        sGDPacings.add(new Standard_Goal_Detail_Pacing__c(Name = 'Test7', Standard_Goal_Detail__c = standardGoalDetails[5].Id, 
                                                          Standard_Goal__c = standardGoals[3].Id, Description__c = 'Test', 
                                                          Period_Start__c = System.today().addDays(71), Period_End__c = System.today().addDays(80),
                                                          Percent_Manual__c = 50));
        sGDPacings.add(new Standard_Goal_Detail_Pacing__c(Name = 'Test8', Standard_Goal_Detail__c = standardGoalDetails[5].Id, 
                                                          Standard_Goal__c = standardGoals[3].Id, Description__c = 'Test', 
                                                          Period_Start__c = System.today().addDays(81), Period_End__c = System.today().addDays(90),
                                                          Percent_Manual__c = 50));
        
        //Start testing from here
        Test.startTest();

        //Insert 
        insert sGDPacings;
        
        //Query Through Standard Goal Detail
        List<Standard_Goal_Detail__c> standardGoalDetail = [Select Id, Amount__c, Count__c, Percent__c From Standard_Goal_Detail__c];
        /*
        //Assert for result for amount                                              
        System.assertEquals(10000, standardGoalDetail[0].Amount__c);
        System.assertEquals(20000, standardGoalDetail[1].Amount__c);
        
        //Assert for result for count
        System.assertEquals(1000, standardGoalDetail[4].Count__c);
        
        //Assert for result for percent
        System.assertEquals(10, standardGoalDetail[5].Percent__c);
        
        //Assign new values
        sGDPacings[0].Percent_Manual__c = 20;
        //standardGoalDetails[4].Baseline_Percentage__c = 20;
        //standardGoalDetails[5].Baseline_Percentage__c = 20;
        
        //Update
        update sGDPacings;
        
        //Update
        update standardGoalDetails;
        
        //Query Through Standard Goal Detail
        standardGoalDetail = [Select Id, Amount__c, Count__c, Percent__c From Standard_Goal_Detail__c];
        
        //Assert for result                                                 
        System.assertEquals(7000, standardGoalDetail[0].Amount__c);
        System.assertEquals(1000, standardGoalDetail[4].Count__c);
        System.assertEquals(10, standardGoalDetail[5].Percent__c);
        
        //Assign new values
        standardGoals[0].Amount__c = 50000;
        
        //Update
        update standardGoals;
        
        //Query Through Standard Goal Detail
        standardGoalDetail = [Select Id, Amount__c, Count__c, Percent__c From Standard_Goal_Detail__c];
        
        //Assert for result                                                 
        System.assertEquals(35000, standardGoalDetail[0].Amount__c);
        System.assertEquals(1000, standardGoalDetail[4].Count__c);
        System.assertEquals(10, standardGoalDetail[5].Percent__c);
        */
        //Stop Testing here
        Test.stopTest();
    }
}