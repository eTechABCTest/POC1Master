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
private class Test_TeamRoleTrigger {

    //Setup test data first. This will be available in the entire class
    @testSetup static void setup() {
    
        // Create common Team Role
        Team_Role__c teamRole = new Team_Role__c(Name = 'UniqueName', Institution__c = true);
        insert teamRole;
    }
    
    //Test method to check the valid Team role
    static testMethod void testValidateTeamRoles() {
        
        //Start Testing from here
        Test.startTest();
        
        //Create duplicate team role
        Team_Role__c teamRole = new Team_Role__c(Name = 'UniqueName', Institution__c = true);
        
        //Try to insert team role
        try {
            
            insert teamRole;
            
            //If the role get added, that means trigger is not working as expected and fail the test method
            System.assert(false, 'Duplaicate Team Role was added.');
        
        } catch(Exception e) {
            
            //Check teh exception message and pass the test method
            System.assert(e.getMessage().contains(Label.ERROR_UNIQUENESS_ROLE_NAME));
        }
        
        //Change the Name and the insert. It should be inserted successfully this time
        teamRole.Name = 'UniqueName II';
        insert teamRole;
        
        //Try to update the Name with a name already exists
        try {
        
            teamRole.Name = 'UniqueName';
            update teamRole;
            
            //If the role get added, that means trigger is not working as expected and fail the test method
            System.assert(false, 'Duplaicate Team Role was added.');
        
        } catch(Exception e) {
            
            //Check teh exception message and pass the test method
            System.assert(e.getMessage().contains(Label.ERROR_UNIQUENESS_ROLE_NAME));
        }
        
        //Try to update  without changing anything, Just to amke sure record in not referencing it's own instance
        teamRole.Name = 'UniqueName II';
        update teamRole;
        
        //Try to update with a different name
        teamRole.Name = 'UniqueName I';
        update teamRole;
        
        //Stop Test
        Test.stopTest();
    }
    
    //Added by - Subhash Garhwal
    //Test method to test updateStaffAssignment methods functionality
	static testMethod void updateStaffAssignment() {
        
        //Disables all the trigger
        Util.IsTest(true);
        Util.BypassAllTriggers = true;
    
	    //Create account 
	    //List to hold Account records
	    List<Account> accounts = new List<Account>();
	    
	    //Add new accounts in list
	    accounts.add(new Account(Name = 'Test Account1'));
	    accounts.add(new Account(Name = 'Test Account2'));
	    accounts.add(new Account(Name = 'Test Account3'));
	        
	    //Insert 
	    insert accounts;
	    
	    //Create contact
	    List<Contact> contacts = new List<Contact>();
	    
	    //Add contacts in list
	    contacts.add(new Contact(FirstName = 'Test', LastName = 'Contact 1',Employee_User_Record__c = Userinfo.getUserId(), Email = 'test@test.com', AccountId = accounts[0].Id,Active_PSS__c = true));
	    contacts.add(new Contact(FirstName = 'Test', LastName = 'Contact 2',Employee_User_Record__c = Userinfo.getUserId(), Email = 'test@test.com', AccountId = accounts[1].Id,Active_PSS__c = true));
	    contacts.add(new Contact(FirstName = 'Test', LastName = 'Contact 3',Employee_User_Record__c = Userinfo.getUserId(), Email = 'test@test.com', AccountId = accounts[2].Id,Active_PSS__c = true));
	    
	    //Insert contact
	    insert contacts;
	    
	    //Create Team Role (Assignment Roles)
	    List<Team_Role__c> staffRoles = new List<Team_Role__c>();
	    
	    //Add new Team Roles in list
	    staffRoles.add(new Team_Role__c(Name = 'Test 1',Active__c = true, Institution__c = true));
	    staffRoles.add(new Team_Role__c(Name = 'Test 2',Active__c = true, Institution__c = true));
	    
	    //Insert
	    insert staffRoles;
        
        //Record Types
        List<RecordType> tmRecordTypes = [SELECT ID FROM RecordType WHERE sObjectType = 'Team_Membership__c' 
                                        	AND IsActive = true 
                       						AND DeveloperName = 'Assigned'];
        System.assert(tmRecordTypes != null);
        
        //Enable triggers again
        Util.BypassAllTriggers = false;
	            
	    //Create staff Assignment 
	    List<Team_Membership__c> staffAssignments = new List<Team_Membership__c>();
	    
	    //Add Staff Assignments in list
	    staffAssignments.add(new Team_Membership__c(Name = 'Test As 1', Staff_member__c = contacts[0].Id, 
                                                    Role__c = staffRoles[0].Id, Institution__c = accounts[0].Id , 
                                                    Start_date__c = System.today().addDays(-3), 
                                                    End_date__c = System.today().addDays(+5),
                                                   	RecordTypeId = tmRecordTypes[0].Id));
	    staffAssignments.add(new Team_Membership__c(Name = 'Test As 2',Staff_member__c = contacts[1].Id, 
                                                    Role__c = staffRoles[1].Id, Institution__c = accounts[1].Id , 
                                                    Start_date__c = System.today().addDays(-3), 
                                                    End_date__c = System.today().addDays(+5),
                                                   	RecordTypeId = tmRecordTypes[0].Id));
	    
	    //Insert
	    insert staffAssignments; 
	    
	    //Start tesing form here
	    Test.startTest();
	    
	    //Query through Staff Assignment
        List<Team_Membership__c> teamMemberships = [Select Id, Name From Team_Membership__c ORDER BY CreatedDate ASC];
        
        //Assert for result
        System.assertEquals(2, teamMemberships.size());
        System.assertEquals('Test Contact 1-Test 1', teamMemberships[0].Name);
        System.assertEquals('Test Contact 2-Test 2', teamMemberships[1].Name);
        
        //Update
	    update staffRoles;
	    
	    //Query through Staff Assignment
        teamMemberships = [Select Id, Name From Team_Membership__c ORDER BY CreatedDate ASC];
        
        //Assert for result
        System.assertEquals(2, teamMemberships.size());
        System.assertEquals('Test Contact 1-Test 1', teamMemberships[0].Name);
        System.assertEquals('Test Contact 2-Test 2', teamMemberships[1].Name);
        
	    //Update staffRole
	    staffRoles[0].Name = 'TestChange';
	    
	    //Update
	    update staffRoles;
	    
	   //Query through Staff Assignment
        teamMemberships = [Select Id, Name From Team_Membership__c ORDER BY CreatedDate ASC];
        
        //Assert for result
        System.assertEquals(2, teamMemberships.size());
        System.assertEquals('Test Contact 1-TestChange', teamMemberships[0].Name);
        System.assertEquals('Test Contact 2-Test 2', teamMemberships[1].Name);
	   
	    Test.stopTest(); 
	}

    //Added by - Subhash Garhwal
    //Test method to test updateStaffAssignment methods functionality
    static testMethod void validateDelete() {
        
        //Disables all the trigger
        Util.IsTest(true);
        Util.BypassAllTriggers = true;
        
        //Create Account
        List<Account> accounts = new List<Account>();
        
        //Add account in list
        accounts.add(new Account(Name = 'Test Account1'));
        
        //Insert
        insert accounts;
        
        // Create contact
        List<Contact> contacts = new List<Contact>();
        
        //Add Contact in list
        contacts.add(new Contact(FirstName = 'Test', LastName = 'Contact 1', Email = 'test@test.com',Employee_User_Record__c = UserInfo.getUserId(), AccountId = accounts[0].Id));
        contacts.add(new Contact(FirstName = 'Test', LastName = 'Contact 2', Email = 'test@test.com',Employee_User_Record__c = UserInfo.getUserId(), AccountId = accounts[0].Id));
    
        //Insert contact
        insert contacts;
        
        //Create Team Role
        List<Team_Role__c> staffRoles = new List<Team_Role__c>();
        
        //Add new Team Roles in list
        staffRoles.add(new Team_Role__c(Name = 'Test1',Active__c = true, Institution__c = true));
        staffRoles.add(new Team_Role__c(Name = 'Test2',Active__c = true, Institution__c = true));
        
        //Insert
        insert staffRoles;
        
        //Record Types
        List<RecordType> tmRecordTypes = [SELECT ID FROM RecordType WHERE sObjectType = 'Team_Membership__c' 
                                        	AND IsActive = true 
                       						AND DeveloperName = 'Assigned'];
        System.assert(tmRecordTypes != null);
        
        //Enable triggers again
        Util.BypassAllTriggers = false;
        
        //Create Staff Assignment 
        List<Team_Membership__c> staffAssignments = new List<Team_Membership__c>();
        
        staffAssignments.add(new Team_Membership__c(Name = 'Test As 1', Staff_member__c = contacts[0].Id, 
                                                    Institution__c = accounts[0].Id, Start_date__c = System.today().addDays(-3), 
                                                    End_date__c = System.today().addDays(+5),
                                                    RecordTypeId = tmRecordTypes[0].Id));
        staffAssignments.add(new Team_Membership__c(Name = 'Test As 1',Staff_member__c = contacts[1].Id,
                                                    Institution__c = accounts[0].Id, Role__c = staffRoles[0].Id, 
                                                    Start_date__c = System.today().addDays(-3), 
                                                    End_date__c = System.today().addDays(+5),
                                                    RecordTypeId = tmRecordTypes[0].Id));
        
        //Insert
        insert staffAssignments;
        
        // Test method start
        Test.startTest();
        
        //Delete
        delete staffRoles[1];
        
        try {
        
	        // Delete    
	        delete staffRoles[0];
        
        } catch(Exception e){
            
            System.assert(e.getMessage().contains(Label.ASSIGNMENT_ROLE_IN_USE));
        }
        
        //Test method Stop
        Test.stopTest();
    }
}