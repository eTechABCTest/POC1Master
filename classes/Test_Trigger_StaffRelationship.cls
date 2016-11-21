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
/**
    *   Purpose         :   Test class for Trigger_StaffRelationship
    *            
    *   Create By       :   Subhash Garhwal
    *
    *   Created Date    :   08/24/2015
    *
    *   Revision Log    :   V_1.0 - Created -  CR-20150825-9182
    *                   :   V_2.0 - Removed testCreateIncentiveChangeLog, since Staff Relationship object is no more applicable for Create Incentive Change Log.
    * 
    *   Coverage        :   98%
    **/
    
@isTest(seeAllData = false )
private class Test_Trigger_StaffRelationship {

    //Test method for CreateMyRelationship method
    static testMethod void testcreateMyRelationship() {
        
        //Create an institution
        Account account = TestUtilities.CreateNewAccount(false);
        
        //Insert
        insert account;
        
        //LiSt of contact
        List<Contact> contacts = new List<Contact>();
        
        //Create a Contact
        contacts.add(new Contact(FirstName = 'Test 1', LastName = 'Contact 1', Email = 'test@test.com', AccountId = account.Id, Employee_User_Record__c = Userinfo.getUserId()));
        contacts.add(new Contact(FirstName = 'Test 2', LastName = 'Contact 2', Email = 'test@test.com', AccountId = account.Id, Employee_User_Record__c = Userinfo.getUserId()));
        contacts.add(new Contact(FirstName = 'Test 3', LastName = 'Contact 3', Email = 'test@test.com', AccountId = account.Id, Employee_User_Record__c = Userinfo.getUserId()));
        
        //Insert
        insert contacts;
        
        //LiSt of Relationship Type
        List<Relationship_Type__c> relationshipTypes = new List<Relationship_Type__c>();
        
        //Add Record in List
        relationshipTypes.add(new Relationship_Type__c(Business_Owner__c = contacts[0].Id, Name_When_From__c = 'Testing From', Name_When_To__c = 'Testing To'));
        relationshipTypes.add(new Relationship_Type__c(Business_Owner__c = contacts[0].Id, Name_When_From__c = 'Testing From', Name_When_To__c = 'Testing To'));
        relationshipTypes.add(new Relationship_Type__c(Business_Owner__c = contacts[1].Id, Name_When_From__c = 'Testing From', Name_When_To__c = 'Testing To'));
        
        //Insert
        insert relationshipTypes;
        
        //List of Staff Relationship
        List<Staff_Relationship__c> staffRelationships = new List<Staff_Relationship__c>();
        
        //Add Record in list
        staffRelationships.add(new Staff_Relationship__c(Relationship__c = relationshipTypes[1].Id,Start_Date__c = System.today().addDays(3), End_Date__c = System.today().addDays(3), From__c = contacts[1].Id, To__c = contacts[0].Id ));
        staffRelationships.add(new Staff_Relationship__c(Relationship__c = relationshipTypes[2].Id,Start_Date__c = System.today().addDays(5), End_Date__c = System.today().addDays(10), From__c = contacts[1].Id, To__c = contacts[2].Id ));
        staffRelationships.add(new Staff_Relationship__c(Relationship__c = relationshipTypes[2].Id,Start_Date__c = System.today().addDays(5), From__c = contacts[2].Id, To__c = contacts[1].Id ));
        
        //Test start here
        Test.startTest();
        
        //Insert
        insert staffRelationships;
 
        //Query Through My Relationship
        List<My_RelationShips__c> myRelationShip = [Select Id, Staff_Relationship__c, Contact__c, Related_To__c From My_RelationShips__c Where Staff_Relationship__c IN : staffRelationships];
        
        //Assert for result
        System.assertEquals(6, myRelationShip.size());
        System.assertEquals(staffRelationships[0].Id, myRelationShip[0].Staff_Relationship__c);
        System.assertEquals(staffRelationships[0].To__c, myRelationShip[0].Related_To__c);
        System.assertEquals(staffRelationships[0].From__c, myRelationShip[0].Contact__c);
        System.assertEquals(staffRelationships[1].Id, myRelationShip[2].Staff_Relationship__c);
        System.assertEquals(staffRelationships[1].From__c, myRelationShip[3].Related_To__c);
        System.assertEquals(staffRelationships[1].To__c, myRelationShip[3].Contact__c); 
        
        //Test stop here
        Test.stopTest(); 
        
    }
    
    //Test method for assignSource method
    static testMethod void testAssignSource() {
        
        //Create an institution
        Account account = TestUtilities.CreateNewAccount(false);
        
        //Insert
        insert account;
        
        //LiSt of contact
        List<Contact> contacts = new List<Contact>();
        
        //Create a Contact
        contacts.add(new Contact(FirstName = 'Test 1', LastName = 'Contact 1', Email = 'test@test.com', AccountId = account.Id, Employee_User_Record__c = Userinfo.getUserId()));
        contacts.add(new Contact(FirstName = 'Test 2', LastName = 'Contact 2', Email = 'test@test.com', AccountId = account.Id, Employee_User_Record__c = Userinfo.getUserId()));
        contacts.add(new Contact(FirstName = 'Test 3', LastName = 'Contact 3', Email = 'test@test.com', AccountId = account.Id, Employee_User_Record__c = Userinfo.getUserId()));
        
        //Insert
        insert contacts;
        
        //Profile    
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator']; 
      
        //User
        User u = new User(Alias = 'standt', Email='standarduser@testorg.com', 
                            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                            LocaleSidKey='en_US', ProfileId = p.Id, department = 'STP',
                            TimeZoneSidKey='America/Los_Angeles', UserName=Math.random() + '@test.com');
        //Insert
        insert u;
        
        //LiSt of Relationship Type
        List<Relationship_Type__c> relationshipTypes = new List<Relationship_Type__c>();
        
        //Add Record in List
        relationshipTypes.add(new Relationship_Type__c(Business_Owner__c = contacts[0].Id, Name_When_From__c = 'Testing From', Name_When_To__c = 'Testing To'));
        relationshipTypes.add(new Relationship_Type__c(Business_Owner__c = contacts[0].Id, Name_When_From__c = 'Testing From', Name_When_To__c = 'Testing To'));
        relationshipTypes.add(new Relationship_Type__c(Business_Owner__c = contacts[1].Id, Name_When_From__c = 'Testing From', Name_When_To__c = 'Testing To'));
        
        
        
        //List of Staff Relationship
        List<Staff_Relationship__c> staffRelationships = new List<Staff_Relationship__c>();
        
        //Add Record in list
        staffRelationships.add(new Staff_Relationship__c(Relationship__c = relationshipTypes[1].Id,Start_Date__c = System.today().addDays(3), End_Date__c = System.today().addDays(3), From__c = contacts[1].Id, To__c = contacts[0].Id ));
        staffRelationships.add(new Staff_Relationship__c(Relationship__c = relationshipTypes[2].Id,Start_Date__c = System.today().addDays(5), End_Date__c = System.today().addDays(10), From__c = contacts[1].Id, To__c = contacts[2].Id ));
        staffRelationships.add(new Staff_Relationship__c(Relationship__c = relationshipTypes[2].Id,Start_Date__c = System.today().addDays(5), From__c = contacts[2].Id, To__c = contacts[1].Id ));
        
        //Test start here
        Test.startTest();
        
        //Run As 
        System.runAs(u){
            
            //Insert
            insert relationshipTypes;
            
            //Insert
            insert staffRelationships;
    
            //Query over Staff Relationship
            List<Staff_Relationship__c> staffRelationshipRecords = [select Id,Source__c From Staff_Relationship__c];
            
            //Assert for result
            System.assertEquals('Native', staffRelationshipRecords[0].Source__c);
            System.assertEquals('Native', staffRelationshipRecords[1].Source__c);
            System.assertEquals('Native', staffRelationshipRecords[2].Source__c);
        }
        //Test stop here
        Test.stopTest();    
    }
    
    //Test Methood for PreventDuplicate
    static testMethod void testPreventDuplicate(){
        
        //Create an institution
        Account account = TestUtilities.CreateNewAccount(false);
        
        //Insert
        insert account;
        
        //LiSt of contact
        List<Contact> contacts = new List<Contact>();
        
        //Create a Contact
        contacts.add(new Contact(FirstName = 'Test 1', LastName = 'Contact 1', Email = 'test@test.com', AccountId = account.Id, Employee_User_Record__c = Userinfo.getUserId()));
        contacts.add(new Contact(FirstName = 'Test 2', LastName = 'Contact 2', Email = 'test@test.com', AccountId = account.Id, Employee_User_Record__c = Userinfo.getUserId()));
        contacts.add(new Contact(FirstName = 'Test 3', LastName = 'Contact 3', Email = 'test@test.com', AccountId = account.Id, Employee_User_Record__c = Userinfo.getUserId()));
        
        //Insert
        insert contacts;
        
        //LiSt of Relationship Type
        List<Relationship_Type__c> relationshipTypes = new List<Relationship_Type__c>();
        
        //Add Record in List
        relationshipTypes.add(new Relationship_Type__c(Business_Owner__c = contacts[0].Id, Name_When_From__c = 'Testing From', Name_When_To__c = 'Testing To'));
        relationshipTypes.add(new Relationship_Type__c(Business_Owner__c = contacts[0].Id, Name_When_From__c = 'Testing From', Name_When_To__c = 'Testing To'));
        relationshipTypes.add(new Relationship_Type__c(Business_Owner__c = contacts[1].Id, Name_When_From__c = 'Testing From', Name_When_To__c = 'Testing To'));
        
        //Insert
        insert relationshipTypes;
        
        //List of Staff Relationship
        List<Staff_Relationship__c> staffRelationships = new List<Staff_Relationship__c>();
        
        //Add Record in list
        staffRelationships.add(new Staff_Relationship__c(Relationship__c = relationshipTypes[0].Id, Start_Date__c = System.today(), End_Date__c = System.today().addDays(5), From__c = contacts[0].Id, To__c = contacts[1].Id ));
        staffRelationships.add(new Staff_Relationship__c(Relationship__c = relationshipTypes[1].Id, Start_Date__c = System.today().addDays(6), End_Date__c = System.today().addDays(10), From__c = contacts[1].Id, To__c = contacts[0].Id ));
        staffRelationships.add(new Staff_Relationship__c(Relationship__c = relationshipTypes[1].Id, Start_Date__c = System.today().addDays(11), End_Date__c = System.today().addDays(15), From__c = contacts[1].Id, To__c = contacts[2].Id ));
        staffRelationships.add(new Staff_Relationship__c(Relationship__c = relationshipTypes[1].Id, Start_Date__c = System.today().addDays(6), End_Date__c = System.today().addDays(10), From__c = contacts[1].Id, To__c = contacts[0].Id ));
        staffRelationships.add(new Staff_Relationship__c(Relationship__c = relationshipTypes[1].Id, Start_Date__c = System.today().addDays(11), End_Date__c = System.today().addDays(20), From__c = contacts[1].Id, To__c = contacts[2].Id ));
        
        //Test start here
        Test.startTest();
        
        try{
            //Insert
            insert staffRelationships;
        }catch(Exception ex){
        
            //Assert for Result
            System.assert(ex.getMessage().contains(Label.ERROR_UNIQUENESS_SR));
        }
        
        //Change data of Staff Relationship
        staffRelationships[3].Relationship__c = relationshipTypes[2].Id;
        
        try{
            //Insert
            insert staffRelationships;
        }catch(Exception ex){
        
            //Assert for Result
            System.assert(ex.getMessage().contains(Label.ERROR_UNIQUENESS_SR));
        }
        //Change data of Staff Relationship
        staffRelationships[4].Start_Date__c = System.today().addDays(16);
        
        //Insert
        insert staffRelationships;
        
        //Update
        staffRelationships[3].Relationship__c = relationshipTypes[1].Id;
        
        try{
            //Update
            update staffRelationships[3];
        }catch(Exception ex){
        
            //Assert for Result
            System.assert(ex.getMessage().contains(Label.ERROR_UNIQUENESS_SR));
        }
        
        //Update Staff Relationship
        staffRelationships[4].Start_Date__c = System.today().addDays(11);
        
        try{
            //Update
            update staffRelationships[4];
        }catch(Exception ex){
        
            //Assert for Result
            System.assert(ex.getMessage().contains(Label.ERROR_UNIQUENESS_SR));
        }
             
        //Test Stoop here
        Test.stopTest();
 
    }
    
    //Added by Subhash Garhwal - 10/10/2015
    static testMethod void testvalidateMyRelationship(){
        
        //Create an institution
        Account account = TestUtilities.CreateNewAccount(false);
        
        //Insert
        insert account;
        
        //LiSt of contact
        List<Contact> contacts = new List<Contact>();
        
        //Create a Contact
        contacts.add(new Contact(FirstName = 'Test 1', LastName = 'Contact 1', Email = 'test@test.com', AccountId = account.Id, Employee_User_Record__c = Userinfo.getUserId()));
        contacts.add(new Contact(FirstName = 'Test 2', LastName = 'Contact 2', Email = 'test@test.com', AccountId = account.Id, Employee_User_Record__c = Userinfo.getUserId()));
        contacts.add(new Contact(FirstName = 'Test 3', LastName = 'Contact 3', Email = 'test@test.com', AccountId = account.Id, Employee_User_Record__c = Userinfo.getUserId()));
        
        //Insert
        insert contacts;
        
        //LiSt of Relationship Type
        List<Relationship_Type__c> relationshipTypes = new List<Relationship_Type__c>();
        
        //Add Record in List
        relationshipTypes.add(new Relationship_Type__c(Business_Owner__c = contacts[0].Id, Name_When_From__c = 'Testing From', Name_When_To__c = 'Testing To'));
        relationshipTypes.add(new Relationship_Type__c(Business_Owner__c = contacts[0].Id, Name_When_From__c = 'Testing From', Name_When_To__c = 'Testing To'));
        relationshipTypes.add(new Relationship_Type__c(Business_Owner__c = contacts[1].Id, Name_When_From__c = 'Testing From', Name_When_To__c = 'Testing To'));
        
        //Insert
        insert relationshipTypes;
        
        //List of Staff Relationship
        List<Staff_Relationship__c> staffRelationships = new List<Staff_Relationship__c>();
        
        //Add Record in list
        staffRelationships.add(new Staff_Relationship__c(Relationship__c = relationshipTypes[1].Id,Start_Date__c = System.today().addDays(3), End_Date__c = System.today().addDays(3), From__c = contacts[1].Id, To__c = contacts[0].Id ));
        staffRelationships.add(new Staff_Relationship__c(Relationship__c = relationshipTypes[2].Id,Start_Date__c = System.today().addDays(5), End_Date__c = System.today().addDays(10), From__c = contacts[1].Id, To__c = contacts[2].Id ));
        staffRelationships.add(new Staff_Relationship__c(Relationship__c = relationshipTypes[2].Id,Start_Date__c = System.today().addDays(5), From__c = contacts[2].Id, To__c = contacts[1].Id ));
        
        //Test start here
        Test.startTest();
        
        //Insert
        insert staffRelationships;
 
        //Query Through My Relationship
        List<My_RelationShips__c> myRelationShip = [Select Id, Staff_Relationship__c, End_Date__c, Start_Date__c, Contact__c, Related_To__c From My_RelationShips__c Where Staff_Relationship__c IN : staffRelationships];
        
        //Assert for result
        System.assertEquals(6, myRelationShip.size());
        System.assertEquals(staffRelationships[0].Id, myRelationShip[0].Staff_Relationship__c);
        System.assertEquals(staffRelationships[0].Start_Date__c, myRelationShip[0].Start_Date__c);
        System.assertEquals(staffRelationships[0].End_Date__c, myRelationShip[0].End_Date__c);
        System.assertEquals(staffRelationships[1].Id, myRelationShip[2].Staff_Relationship__c);
        System.assertEquals(staffRelationships[1].Start_Date__c, myRelationShip[2].Start_Date__c);
        System.assertEquals(staffRelationships[1].End_Date__c, myRelationShip[2].End_Date__c);
        
        //Update Record of Staff Relationship
        staffRelationships[0].Start_Date__c = System.today().addDays(1);
        staffRelationships[1].Start_Date__c = System.today().addDays(6);
        staffRelationships[0].End_Date__c = System.today().addDays(4);
        staffRelationships[1].End_Date__c = System.today().addDays(11); 
        
        //Update
        update staffRelationships;
        
        //Query Through My Relationship
        myRelationShip = [Select Id, Staff_Relationship__c, End_Date__c, Start_Date__c, Contact__c, Related_To__c From My_RelationShips__c Where Staff_Relationship__c IN : staffRelationships];
        
        //Assert for result
        System.assertEquals(6, myRelationShip.size());
        System.assertEquals(staffRelationships[0].Id, myRelationShip[0].Staff_Relationship__c);
        System.assertEquals(staffRelationships[0].Start_Date__c, myRelationShip[0].Start_Date__c);
        System.assertEquals(staffRelationships[0].End_Date__c, myRelationShip[0].End_Date__c);
        System.assertEquals(staffRelationships[1].Id, myRelationShip[2].Staff_Relationship__c);
        System.assertEquals(staffRelationships[1].Start_Date__c, myRelationShip[2].Start_Date__c);
        System.assertEquals(staffRelationships[1].End_Date__c, myRelationShip[2].End_Date__c);
        
        //Test stop here
        Test.stopTest();
    }
}