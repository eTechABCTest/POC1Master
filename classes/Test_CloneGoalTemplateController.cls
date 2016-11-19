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
private class Test_CloneGoalTemplateController {

/**
 *   Purpose         :   Test class for CloneGoalTemplateController
 *            
 *   Create By       :   Subhash Garhwal
 *
 *   Created Date    :   10/24/2015
 *
 *   Revision Log    :   V_1.0 - Created - CR-20150729-9114
 * 
 *   Coverage        :   V_1.0 - 95%
 **/
    
    //Test Method
    static testMethod void myUnitTest() {
        
        // TO DO: implement unit test
        
        /********************       Create test data         **********************/
        
        //Query through the Conditions record type
        List<RecordType> rTypes = [Select Id, DeveloperName From RecordType Where SObjectType = 'Condition__c' ORDER BY DeveloperName ASC];
        
        //Account
        Account account = TestUtilities.CreateNewAccount(false);
        
        //Insert
        insert account;
        
        //Assert
        System.assert(account != null);
        
        //Create Contact records
        List<Contact> contacts = new List<Contact>();
        
        //Add new contact record in list
        contacts.add(new Contact(FirstName = 'Test', LastName = 'Contact 1', Email = 'test1@test.com', AccountId = account.Id, Employee_User_Record__c = Userinfo.getUserId()));
        contacts.add(new Contact(FirstName = 'Test', LastName = 'Contact 2', Email = 'test2@test.com', AccountId = account.Id, Employee_User_Record__c = Userinfo.getUserId()));
        
        //Insert
        insert contacts;
        
        //Assert
        System.assert(contacts.size() > 0);
        
        //List of goal type
        List<Goal_Type__c> goalTypes = new List<Goal_Type__c>();
        
        //Add new goal types in list to insert
        goalTypes.add(new Goal_Type__c(Description__c = 'GT 1', Base_Process__c = 'Other', Standard_Goal__c = true, Active__c = true));
        goalTypes.add(new Goal_Type__c(Description__c = 'GT 2', Base_Process__c = 'Other', Standard_Goal__c = true, Active__c = true));
        goalTypes.add(new Goal_Type__c(Description__c = 'GTD 1', Base_Process__c = 'Other', Standard_Goal__c = false, Active__c = true));
        goalTypes.add(new Goal_Type__c(Description__c = 'GTD 2', Base_Process__c = 'Other', Standard_Goal__c = false, Active__c = true));
        
        //Insert
        insert goalTypes;
        
        //Assert
        System.assert(goalTypes.size() > 0);
        
        //List of Goal Template
        List<Standard_Goal__c> goalTemplates = new List<Standard_Goal__c>();
        
        //Add new goal template in the list
        goalTemplates.add(new Standard_Goal__c(Active__c = true, Amount__c = 100000, Business_Owner__c = contacts[0].Id, Description__c = 'Goal Temp 1',
                                               Goal_Type__c = goalTypes[0].Id, Period_Start__c = System.today(), Period_End__c = System.today().addDays(365),
                                               Standard_Type__c = 'Group'));
        
        goalTemplates.add(new Standard_Goal__c(Active__c = true, Counter__c = 100000, Business_Owner__c = contacts[1].Id, Description__c = 'Goal Temp 2',
                                               Goal_Type__c = goalTypes[1].Id, Period_Start__c = System.today(), Period_End__c = System.today().addDays(365),
                                               Standard_Type__c = 'Group'));
        
        goalTemplates.add(new Standard_Goal__c(Active__c = true, Percent__c = 80, Business_Owner__c = contacts[1].Id, Description__c = 'Goal Temp 3',
                                               Goal_Type__c = goalTypes[1].Id, Period_Start__c = System.today(), Period_End__c = System.today().addDays(365),
                                               Standard_Type__c = 'Personal'));
        
        //Insert
        insert goalTemplates;
        
        //Assert
        System.assert(goalTemplates.size() > 0);
        
        //List of Goal Template Details
        List<Standard_Goal_Detail__c> goalTempDetails = new List<Standard_Goal_Detail__c>();
        
        //Add new GTD in the list
        goalTempDetails.add(new Standard_Goal_Detail__c(Standard_Goal__c = goalTemplates[0].Id, Active__c = true, Description__c = 'GT 1 GTD 1',
                                                        Goal_Type__c = goalTypes[2].Id, Target_Type__c = 'Paced'));
        
        goalTempDetails.add(new Standard_Goal_Detail__c(Standard_Goal__c = goalTemplates[0].Id, Active__c = true, Description__c = 'GT 1 GTD 2',
                                                        Goal_Type__c = goalTypes[3].Id, Target_Type__c = 'Paced', Period_Start__c = System.today(),
                                                        Period_End__c = System.today().addDays(100)));
                                                        
        goalTempDetails.add(new Standard_Goal_Detail__c(Standard_Goal__c = goalTemplates[0].Id, Active__c = true, Description__c = 'GT 1 GTD 3',
                                                        Goal_Type__c = goalTypes[2].Id, Target_Type__c = 'Explicit', Period_Start__c = System.today(),
                                                        Period_End__c = System.today().addDays(100)));
        
        goalTempDetails.add(new Standard_Goal_Detail__c(Standard_Goal__c = goalTemplates[1].Id, Active__c = true, Description__c = 'GT 2 GTD 1',
                                                        Goal_Type__c = goalTypes[2].Id, Target_Type__c = 'Paced'));
        
        goalTempDetails.add(new Standard_Goal_Detail__c(Standard_Goal__c = goalTemplates[1].Id, Active__c = true, Description__c = 'GT 2 GTD 2',
                                                        Goal_Type__c = goalTypes[3].Id, Target_Type__c = 'Paced', Period_Start__c = System.today(),
                                                        Period_End__c = System.today().addDays(20)));
                                                        
        goalTempDetails.add(new Standard_Goal_Detail__c(Standard_Goal__c = goalTemplates[1].Id, Active__c = true, Description__c = 'GT 2 GTD 3',
                                                        Goal_Type__c = goalTypes[2].Id, Target_Type__c = 'Explicit', Period_Start__c = System.today(),
                                                        Period_End__c = System.today().addDays(120)));
       
       //Insert
       insert goalTempDetails;
       
       //Assert
       System.assert(goalTempDetails.size() > 0);
       
       //List of Goal Template Detail Measurement Period
        List<Goal_Template_Detail_Measurement_Period__c> gTMPeriods = new List<Goal_Template_Detail_Measurement_Period__c>();
        
        //Add new GTDMP in the list
        gTMPeriods.add(new Goal_Template_Detail_Measurement_Period__c(Goal_Template_Detail__c= goalTempDetails[0].Id, Measurement_Date__c = System.today()));
       
       //Insert
       insert gTMPeriods ;
       
       //Assert
       System.assert(gTMPeriods .size() > 0);
       
       //Update Parent and baseline
       goalTempDetails[0].Baseline__c = goalTempDetails[2].Id;
       goalTempDetails[0].Parent__c = goalTempDetails[1].Id; 
       
       //update records
       update goalTempDetails;
       
       //List of goal template detail pacings
       List<Standard_Goal_Detail_Pacing__c> gTDPacings = new List<Standard_Goal_Detail_Pacing__c>();
       
       //add in pacings in the list
       gTDPacings.add(new Standard_Goal_Detail_Pacing__c(Standard_Goal__c = goalTemplates[0].Id, Standard_Goal_Detail__c = goalTempDetails[0].Id,
                                                         Period_Start__c = System.today().addDays(10), Period_End__c = System.today().addDays(50),
                                                         Description__c = 'GT 1 GTD 1 GTDP 1', Percent_Manual__c = 70));
        
        gTDPacings.add(new Standard_Goal_Detail_Pacing__c(Standard_Goal__c = goalTemplates[0].Id, Standard_Goal_Detail__c = goalTempDetails[0].Id,
                                                         Period_Start__c = System.today().addDays(51), Period_End__c = System.today().addDays(150),
                                                         Description__c = 'GT 1 GTD 1 GTDP 2', Percent_Manual__c = 30));
        
        gTDPacings.add(new Standard_Goal_Detail_Pacing__c(Standard_Goal__c = goalTemplates[0].Id, Standard_Goal_Detail__c = goalTempDetails[1].Id,
                                                         Period_Start__c = System.today().addDays(20), Period_End__c = System.today().addDays(90),
                                                         Description__c = 'GT 1 GTD 2 GTDP 1', Percent_Manual__c = 100));
        
        gTDPacings.add(new Standard_Goal_Detail_Pacing__c(Standard_Goal__c = goalTemplates[0].Id, Standard_Goal_Detail__c = goalTempDetails[2].Id,
                                                         Period_Start__c = System.today().addDays(20), Period_End__c = System.today().addDays(90),
                                                         Description__c = 'GT 1 GTD 3 GTDP 1', Percent_Manual__c = 100));
        
        gTDPacings.add(new Standard_Goal_Detail_Pacing__c(Standard_Goal__c = goalTemplates[1].Id, Standard_Goal_Detail__c = goalTempDetails[3].Id,
                                                         Period_Start__c = System.today().addDays(10), Period_End__c = System.today().addDays(50),
                                                         Description__c = 'GT 2 GTD 1 GTDP 1', Percent_Manual__c = 70));
        
        gTDPacings.add(new Standard_Goal_Detail_Pacing__c(Standard_Goal__c = goalTemplates[1].Id, Standard_Goal_Detail__c = goalTempDetails[3].Id,
                                                         Period_Start__c = System.today().addDays(51), Period_End__c = System.today().addDays(150),
                                                         Description__c = 'GT 2 GTD 1 GTDP 2', Percent_Manual__c = 30));
        
        gTDPacings.add(new Standard_Goal_Detail_Pacing__c(Standard_Goal__c = goalTemplates[1].Id, Standard_Goal_Detail__c = goalTempDetails[4].Id,
                                                         Period_Start__c = System.today().addDays(20), Period_End__c = System.today().addDays(90),
                                                         Description__c = 'GT 2 GTD 2 GTDP 1', Percent_Manual__c = 100));
        
        gTDPacings.add(new Standard_Goal_Detail_Pacing__c(Standard_Goal__c = goalTemplates[1].Id, Standard_Goal_Detail__c = goalTempDetails[5].Id,
                                                         Period_Start__c = System.today().addDays(20), Period_End__c = System.today().addDays(90),
                                                         Description__c = 'GT 2 GTD 3 GTDP 1', Percent_Manual__c = 100));
        
        //Insert
        insert gTDPacings;
        
        //Assert
        System.assert(gTDPacings.size() > 0);
        
        //List of conditions
        List<Condition__c> conditions = new List<Condition__c>();
        
        //Add new condition in list
        conditions.add(new Condition__c(RecordTypeId = rTypes[0].Id, Standard_Goal__c = goalTemplates[0].Id, Start_Date__c = System.today(),
                                        End_Date__c = System.today().addDays(1), Date_Type__c = 'Anniversary', Condition_Type__c = 'Include'));
        
        conditions.add(new Condition__c(RecordTypeId = rTypes[0].Id, Standard_Goal__c = goalTemplates[0].Id, Standard_Goal_Detail__c = goalTempDetails[0].Id,
                                        Start_Date__c = System.today().addDays(2), End_Date__c = System.today().addDays(10), Date_Type__c = 'Renewal',
                                        Condition_Type__c = 'Include'));
        
        conditions.add(new Condition__c(RecordTypeId = rTypes[6].Id, Standard_Goal__c = goalTemplates[0].Id, Standard_Goal_Detail__c = goalTempDetails[2].Id,
                                        Start_Date__c = System.today().addDays(11), End_Date__c = System.today().addDays(15), Agreement_Type__c = 'LOA',
                                        Condition_Type__c = 'Include'));
        
        conditions.add(new Condition__c(RecordTypeId = rTypes[0].Id, Standard_Goal__c = goalTemplates[1].Id, Start_Date__c = System.today(),
                                        End_Date__c = System.today().addDays(1), Date_Type__c = 'Anniversary', Condition_Type__c = 'Include'));
        
        conditions.add(new Condition__c(RecordTypeId = rTypes[0].Id, Standard_Goal__c = goalTemplates[1].Id, Standard_Goal_Detail__c = goalTempDetails[3].Id,
                                        Start_Date__c = System.today().addDays(2), End_Date__c = System.today().addDays(10), Date_Type__c = 'Renewal',
                                        Condition_Type__c = 'Include'));
        
        conditions.add(new Condition__c(RecordTypeId = rTypes[6].Id, Standard_Goal__c = goalTemplates[1].Id, Standard_Goal_Detail__c = goalTempDetails[4].Id,
                                        Start_Date__c = System.today().addDays(11), End_Date__c = System.today().addDays(15), Agreement_Type__c = 'LOA',
                                        Condition_Type__c = 'Include'));
        
        conditions.add(new Condition__c(RecordTypeId = rTypes[0].Id, Standard_Goal__c = goalTemplates[2].Id, Start_Date__c = System.today(),
                                        End_Date__c = System.today().addDays(1), Date_Type__c = 'Anniversary', Condition_Type__c = 'Include'));
        
        conditions.add(new Condition__c(RecordTypeId = rTypes[6].Id, Standard_Goal__c = goalTemplates[2].Id, Start_Date__c = System.today().addDays(11),
                                        End_Date__c = System.today().addDays(15), Agreement_Type__c = 'LOA', Condition_Type__c = 'Include'));
        
        //Insert
        insert conditions;
        
        //Assert
        System.assert(conditions.size() > 0);
        
        //List of Values Types
        List<Value_Type__c> valueTypes = new List<Value_Type__c>();
        
        //Add new value type in list
        valueTypes.add(new Value_Type__c(Category__c = 'Business Title', Values_Permitted__c = 'Text'));
        
        //Insert
        insert valueTypes;
        
        //Assert
        System.assert(valueTypes.size() > 0);
        
        //List of GTBTs
        List<Standard_Goal_Sales_Role__c> gTBTitles = new List<Standard_Goal_Sales_Role__c>();
        
        //Add new GTBT 
        gTBTitles.add(new Standard_Goal_Sales_Role__c(Standard_Goal__c = goalTemplates[1].Id, Sales_Role__c = valueTypes[0].Id));
        gTBTitles.add(new Standard_Goal_Sales_Role__c(Standard_Goal__c = goalTemplates[1].Id, Sales_Role__c = valueTypes[0].Id));
        gTBTitles.add(new Standard_Goal_Sales_Role__c(Standard_Goal__c = goalTemplates[2].Id, Sales_Role__c = valueTypes[0].Id));
        
        //Insert
        insert gTBTitles;
        
        //Assert
        System.assert(gTBTitles.size() > 0);
        
        //Start testing from here
        Test.startTest();
        
        //Query through the Goal Templates
        List<Standard_Goal__c> goalTemps = [Select Id From Standard_Goal__c];
        
        //Assert for result
        System.assertEquals(3, goalTemps.size());
        
        //Query through the GTD
        List<Standard_Goal_Detail__c> gTDetails = [Select Id From Standard_Goal_Detail__c];
        
        //Assert for result
        System.assertEquals(6, gTDetails.size());
        
        //Query through the GTDP
        List<Standard_Goal_Detail_Pacing__c> gTempDPacings = [Select Id From Standard_Goal_Detail_Pacing__c];
        
        //Assert for result
        System.assertEquals(8, gTempDPacings.size());
        
        //Query through the Condition
        List<Condition__c> conditionList = [Select Id From Condition__c];
        
        //Assert for result
        System.assertEquals(8, conditionList.size());
        
        //Query through the GTBT
        List<Standard_Goal_Sales_Role__c> gTBTs = [Select Id From Standard_Goal_Sales_Role__c];
        
        //Asset for result
        System.assertEquals(3, gTBTs.size());
        
        //Standard controller       
        ApexPages.StandardController sc = new ApexPages.standardController(new Standard_Goal__c());
        
        //Instance of controller
        CloneGoalTemplateController controller = new CloneGoalTemplateController(sc);
        
        //Call method to clone the Goal Template (As passed Goal Template not having any Id so no record will get cloned).
        controller.cloneGoalTemplates();
        
        //Query through the Goal Templates
        goalTemps = [Select Id From Standard_Goal__c];
        
        //Assert for result
        System.assertEquals(3, goalTemps.size());
        
        //Query through the Goal_Template_Detail_Measurement_Period__c
        gTMPeriods = [Select Id From Goal_Template_Detail_Measurement_Period__c];
        
        //Assert for result
        System.assertEquals(1, gTMPeriods.size());
        
        //Set saved record in std controller 
        sc = new ApexPages.standardController(goalTemplates[0]);
        
        //Constructor
        controller = new CloneGoalTemplateController(sc);
        
        //Call method to clone the Goal Template
        controller.cloneGoalTemplates();
        
        //Query through the Goal Templates
        goalTemps = [Select Id, CreatedDate, Description__c From Standard_Goal__c ORDER BY CreatedDate ASC];
        
        //Assert for result
        System.assertEquals(4, goalTemps.size());
        
        //Query through the Goal Template
        goalTemps = [Select Id, Description__c, (Select Id From Standard_Goal_Details__r), (Select Id From Conditions__r),
                                                (Select Id From Standard_Goal_Sales_Roles__r) From Standard_Goal__c Where Description__c = 'Clone of: Goal Temp 1'];
        
        //Asserts for results
        System.assertEquals(1, goalTemps.size());
        System.assertEquals('Clone of: Goal Temp 1', goalTemps[0].Description__c);
        System.assertEquals(3, goalTemps[0].Standard_Goal_Details__r.size());
        System.assertEquals(3, goalTemps[0].Conditions__r.size());
        System.assertEquals(0, goalTemps[0].Standard_Goal_Sales_Roles__r.size());
        
        //Query through the Pacings
        gTempDPacings = [Select Id From Standard_Goal_Detail_Pacing__c Where Standard_Goal_Detail__c IN : goalTemps[0].Standard_Goal_Details__r];
        
        System.assertEquals(4, gTempDPacings.size());
        
        //Query through the Goal_Template_Detail_Measurement_Period__c
        gTMPeriods = [Select Id From Goal_Template_Detail_Measurement_Period__c];
        
        //Assert for result
        System.assertEquals(2, gTMPeriods.size());
        
        //Re-Set saved record in std controller
        sc = new ApexPages.standardController(new Standard_Goal__c());
        
        //Constructor
        controller = new CloneGoalTemplateController(sc);
        
        //Set the standard set controller
        ApexPages.StandardSetController ssc = new ApexPages.StandardSetController(new List<Standard_Goal__c>());
        
        //Constructor
        controller = new CloneGoalTemplateController(ssc);
        
        //Call method to clone the Goal Template
        controller.cloneGoalTemplates();
        
        //Query through the Goal Templates
        goalTemps = [Select Id From Standard_Goal__c ORDER BY CreatedDate ASC];
        
        //Assert for result
        System.assertEquals(4, goalTemps.size());
        
        //Query through the Goal_Template_Detail_Measurement_Period__c
        gTMPeriods = [Select Id From Goal_Template_Detail_Measurement_Period__c];
        
        //Assert for result
        System.assertEquals(2, gTMPeriods.size());
        
        //Set the standard set controller
        ssc = new ApexPages.StandardSetController(new List<Standard_Goal__c>{goalTemplates[1], goalTemplates[2]});
        ssc.setSelected(new List<Standard_Goal__c>{goalTemplates[1], goalTemplates[2]});
        
        //Constructor
        controller = new CloneGoalTemplateController(ssc);
        
        //Call method to clone the Goal Template
        controller.cloneGoalTemplates();
        
        //Query through the Goal Templates
        goalTemps = [Select Id, Description__c From Standard_Goal__c];
        
        //Assert for result
        System.assertEquals(6, goalTemps.size());
        
        //Query through the GTD
        gTDetails = [Select Id From Standard_Goal_Detail__c];
        
        //Assert for result
        System.assertEquals(12, gTDetails.size());
        
        //Query through the Goal_Template_Detail_Measurement_Period__c
        gTMPeriods = [Select Id From Goal_Template_Detail_Measurement_Period__c];
        
        //Assert for result
        System.assertEquals(2, gTMPeriods.size());
        
        //Query through the GTDP
        gTempDPacings = [Select Id From Standard_Goal_Detail_Pacing__c];
        
        //Assert for result
        System.assertEquals(16, gTempDPacings.size());
        
        //Query through the Condition
        conditionList = [Select Id From Condition__c];
        
        //Assert for result
        System.assertEquals(16, conditionList.size());
        
        //Query through the GTBT
        gTBTs = [Select Id From Standard_Goal_Sales_Role__c];
        
        //Asset for result
        System.assertEquals(6, gTBTs.size());
        
        //Stop testing here
        Test.stopTest();
    }
}