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
@isTest(SeeAllData = false)
private class Test_CreateChangeBatch {
    
    /**
    *   Purpose         :   Test class for CreateChangeBatch Page.
    *            
    *   Create By       :   Subhash Garhwal
    *
    *   Created Date    :   1/9/2015  
    *
    *   Revision Log    :   V_1.0 - Created - CR-20150729-9114 
    *                   :   V_1.1 - Modified - Rajeev Jain - CR-20151120-9402 - 04/19/2016 - Removed Usage of Perspective__C field on the Incentive Change log, in order to this field is deleted
    *                                       - Rajeev Jain - CR-20151120-9402 - 05/10/2016 Improved code and asserts in test class,used Test setup method.
    * 
    *   Coverage        :   96%
    **/
    
    @testSetup static void setupTestData() {
        
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
    }
    
    // TO DO: implement unit test
    static testMethod void myUnitTest() {
        
        //Create Incentive Change Log Instance
        Incentive_Change_Batch__c incentiveChangebatch = new Incentive_Change_Batch__c();
        
        //Start From Here
        Test.startTest(); 
        
        //Set the standard set controller
        ApexPages.StandardSetController iCL = new ApexPages.StandardSetController(new List<Incentive_Change_Log__c>());
        
        //Constructor
        CreateChangeBatchController controller = new CreateChangeBatchController(iCL);
        
        //Assert For Result 
        System.assert(ApexPages.getMessages()[0].getDetail().contains( 'Please select at least one record' ));
        
        controller = new CreateChangeBatchController(iCL);
        
        try{
            //Call method
            controller.doSave();
            
        }catch(Exception ex){
            system.debug('^^^^^^^');
            //Assert For Result
            System.assert(ex.getMessage().contains('Please select at least one record'));
        }
        
        //Now query on Incentives Record and assign those to new batch
        List<Incentive_Change_Log__c> iclRecords = [select Id from Incentive_Change_Log__c];
        
        System.assertEquals(true, iclRecords.size() > 0);
        
        //Reinstantiate IncentiveChangebactchController
        iCL = new ApexPages.StandardSetController(iclRecords);
        iCL.setSelected(iclRecords);
        
        controller = new CreateChangeBatchController(iCL);
        
        System.assertEquals(true, controller.incentiveChangeLogs.size() > 0);
        
        //Provide a batch name to ICB of the controller
        controller.incentiveCBatch.Name = 'Test Incentive Change Batch';
        
        //Associate all ICL records to this new batch, call doSave Method
        controller.doSave();
        
        //Assert for Results
        for(Incentive_Change_Log__c iclData : controller.incentiveChangeLogs)
            System.assertEquals(true, iclData.Incentive_Change_Batch__c == controller.incentiveCBatch.Id);
            
        //Blank out id of the first Record in ICL
        controller.incentiveChangeLogs[0] = new Incentive_Change_Log__c();
        
        //Throw DML exception
        try{
            //Call method
            controller.doSave();
            
        }catch(Exception ex){
            
            //Assert For Result
            System.assert(ex.getMessage().contains('DML'));
        }
        
        //Set Null to ICL list and throw Exception in order to cover the exception code of controller
        controller.incentiveChangeLogs = new List<Incentive_Change_Log__c>();
        
        //Throw custom Exception
        try{
            //Call method
            controller.doSave();
            
        }catch(Exception ex){
            
            //Assert For Result
            System.assert(ex.getMessage().contains('Please select at least one record'));
        }
        
        //Stop Here
        Test.stopTest();
    }
}