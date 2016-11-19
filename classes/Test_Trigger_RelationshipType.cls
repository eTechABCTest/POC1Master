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
    *   Purpose         :   Test class for Trigger_RelationshipType
    *            
    *   Create By       :   Subhash Garhwal
    *
    *   Created Date    :   09/30/2015
    *
    *   Revision Log    :	V_1.0 - Created -  CR-20150825-9182
    * 
    *	Coverage		:	
    **/
    
	@isTest(seeAllData = false )
private class Test_Trigger_RelationshipType {
	
	//Test Method of cascadeChanges
    static testMethod void testCascadeChanges() {
    	
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
		
		//List of Relationship
		List<Relationship_Type__c> relationshipTypes = new List<Relationship_Type__c>();
		
		//Create Relationship Type
		relationshipTypes.add(new Relationship_Type__c(Name = 'Relationship Type 1', Business_Owner__c = contacts[0].Id, Active__c = true, Name_When_From__c = 'When From 1', Name_When_To__c = 'When To 1'));
        relationshipTypes.add(new Relationship_Type__c(Name = 'Relationship Type 2', Business_Owner__c = contacts[0].Id, Active__c = true, Name_When_From__c = 'When From 2', Name_When_To__c = 'When To 2'));
        relationshipTypes.add(new Relationship_Type__c(Name = 'Relationship Type 3', Business_Owner__c = contacts[1].Id, Active__c = true, Name_When_From__c = 'When From 3', Name_When_To__c = 'When To 3'));
        relationshipTypes.add(new Relationship_Type__c(Name = 'Relationship Type 4', Business_Owner__c = contacts[2].Id, Active__c = true, Name_When_From__c = 'When From 4', Name_When_To__c = 'When To 4'));
		
		//Insert 
		insert relationshipTypes;
		
		//List of Staff Relationship
		List<Staff_Relationship__c> staffRelationships = new List<Staff_Relationship__c>();
		
		//Add Record in list
		staffRelationships.add(new Staff_Relationship__c(Relationship__c = relationshipTypes[1].Id,Start_Date__c = System.today().addDays(3), End_Date__c = System.today().addDays(3), From__c = contacts[1].Id, To__c = contacts[0].Id ));
		staffRelationships.add(new Staff_Relationship__c(Relationship__c = relationshipTypes[2].Id,Start_Date__c = System.today().addDays(5), End_Date__c = System.today().addDays(10), From__c = contacts[1].Id, To__c = contacts[2].Id ));
		staffRelationships.add(new Staff_Relationship__c(Relationship__c = relationshipTypes[3].Id,Start_Date__c = System.today().addDays(5), From__c = contacts[2].Id, To__c = contacts[1].Id ));
		
		//Insert
        insert staffRelationships;
        
        //List of My Relationship
        List<My_Relationships__c> myRelationships = new List<My_Relationships__c>();
        
        //Add Record in list
        myRelationships.add(new My_Relationships__c(Name = 'myRelationships 1', Staff_Relationship__c = staffRelationships[0].Id, Contact__c = contacts[0].Id, Related_To__c = contacts[1].Id));
		myRelationships.add(new My_Relationships__c(Name = 'myRelationships 1', Staff_Relationship__c = staffRelationships[1].Id, Contact__c = contacts[1].Id, Related_To__c = contacts[2].Id));
		myRelationships.add(new My_Relationships__c(Name = 'myRelationships 1', Staff_Relationship__c = staffRelationships[2].Id, Contact__c = contacts[2].Id, Related_To__c = contacts[0].Id));
		
		//Insert
		insert myRelationships;
		
		//Test Start Here
		Test.startTest();
		
		//Query Through Staff Relationship
		List<Staff_Relationship__c> sRRecords = [Select Id, Name, Relationship__r.Name, From__r.Name, To__r.Name  From Staff_Relationship__c Where Id IN: staffRelationships];
		
		//Assert For result
		system.assertEquals(sRRecords[0].Name, sRRecords[0].From__r.Name + ' - '+ sRRecords[0].To__r.Name + ' : '+ sRRecords[0].Relationship__r.Name);
		system.assertEquals(sRRecords[1].Name, sRRecords[1].From__r.Name + ' - '+ sRRecords[1].To__r.Name + ' : '+ sRRecords[1].Relationship__r.Name);
		system.assertEquals(sRRecords[2].Name, sRRecords[2].From__r.Name + ' - '+ sRRecords[2].To__r.Name + ' : '+ sRRecords[2].Relationship__r.Name);
		
		//Query Through My relationship
		List<My_Relationships__c> mRRecords = [Select Id, Name, Staff_Relationship__c,Relates_As__c, Contact__c, Related_To__r.Name, Staff_Relationship__r.Relationship__r.Name_When_From__c, Staff_Relationship__r.Relationship__r.Name_When_To__c From My_Relationships__c Where Id IN: myRelationships];
		
		//Asssert For Assert
		system.assertEquals(mRRecords[0].Name, mRRecords[0].Relates_As__c + ' ' + mRRecords[0].Related_To__r.Name);
		system.assertEquals(mRRecords[1].Name, mRRecords[1].Relates_As__c + ' ' + mRRecords[1].Related_To__r.Name);
		system.assertEquals(mRRecords[2].Name, mRRecords[2].Relates_As__c + ' ' + mRRecords[2].Related_To__r.Name);
		
		//Update Relationship Type
		relationshipTypes[1].Name = 'Relationship Type 2 Update';
		relationshipTypes[2].Name = 'Relationship Type 3 Update';
		
		//Update
		update relationshipTypes;
		
		//Query Through Staff Relationship
		sRRecords = [Select Id, Name, Relationship__r.Name, From__r.Name, To__r.Name  From Staff_Relationship__c Where Id IN: staffRelationships];
		
		//Assert For result
		system.assertEquals(sRRecords[0].Name, sRRecords[0].From__r.Name + ' - '+ sRRecords[0].To__r.Name + ' : '+ sRRecords[0].Relationship__r.Name);
		system.assertEquals(sRRecords[1].Name, sRRecords[1].From__r.Name + ' - '+ sRRecords[1].To__r.Name + ' : '+ sRRecords[1].Relationship__r.Name);
		
		//Update Relationship Type
		relationshipTypes[0].Name_When_To__c = 'When To Update';
		relationshipTypes[1].Name_When_From__c = 'When From Update';
		relationshipTypes[2].Name_When_From__c = 'When From Update';
		
		//Update
		update relationshipTypes;
		
		//Query Through Staff Relationship
		sRRecords = [Select Id, Name, Relationship__r.Name, From__r.Name, To__r.Name  From Staff_Relationship__c Where Id IN: staffRelationships];
		
		//Assert For result
		system.assertEquals(sRRecords[0].Name, sRRecords[0].From__r.Name + ' - '+ sRRecords[0].To__r.Name + ' : '+ sRRecords[0].Relationship__r.Name);
		system.assertEquals(sRRecords[1].Name, sRRecords[1].From__r.Name + ' - '+ sRRecords[1].To__r.Name + ' : '+ sRRecords[1].Relationship__r.Name);
		system.assertEquals(sRRecords[2].Name, sRRecords[2].From__r.Name + ' - '+ sRRecords[2].To__r.Name + ' : '+ sRRecords[2].Relationship__r.Name);
		
		//Test Stop Here
		Test.stopTest();  
    }
}