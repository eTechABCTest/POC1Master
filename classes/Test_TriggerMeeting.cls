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
@isTest
private class Test_TriggerMeeting {
	
	//Create Registration data
	public static Registration__c CreateRegistration(Id MeetingId, Id contactId, boolean CreateAndInsert) {
        // create the registration
        Registration__c registration = new Registration__c();
        registration.Contact__c = contactId;
        registration.Meeting__c = MeetingId;
        registration.Status__c = 'Scheduled';
        if (CreateAndInsert) insert registration;
        
        return registration;
    }
    
    //Create a meeting record
    public static Meeting__c CreateMeeting(boolean CreateAndInsert) {
        // create the meeting
        Meeting__c meeting = new Meeting__c();
        meeting.DateTime__c = system.now();
        meeting.Type__c = 'Onsite';
        if (CreateAndInsert) insert meeting;
        return meeting;
    }
    
	
	//This method is to create the records in registration object for already registered contacts
	//if Auto Subscribed checkbox is check on the child meeting
	static testMethod void testCreateRegistrationForParentRegisteredContacts() {
		
		//Create test data
		
		//Create Parent meeting records
		Meeting__c parentMeeting = CreateMeeting(true);
		
		//Create a list of Contatcs and Insert
		List<Contact> contacts = new List<Contact>();
		
		//Add contacts in list
		contacts.add(testUtilities.CreateNewContact(false));
		contacts.add(testUtilities.CreateNewContact(false));
		
		//Insert the contacts
		insert contacts;
		
		//Create a list of Registration records
		List<Registration__c> registrations = new List<Registration__c>();
		
		//Loop through the contacts and create the registration records
		for(Contact contact : contacts) {
			
			//Add registration records
			registrations.add(CreateRegistration(parentMeeting.Id, contact.Id, false));
		}
		
		//insert registrations
		insert registrations;
	
		//Create a Child Metting record
		Meeting__c childMeeting = CreateMeeting(false);
		childMeeting.Parent_Meeting__c = parentMeeting.Id;
		childMeeting.Auto_Subscribe__c = false;
		insert childMeeting;
		
		//Create a registration for Child Meeting
		insert new Registration__c(Meeting__c = childMeeting.Id, Contact__c = contacts[0].Id, Status__c = 'Registered');
	
		//Start testing from here
		Test.startTest();
		
		//Check meeting doesn't have any registarion record
		registrations = [Select Id from Registration__c where Meeting__c =: childMeeting.Id];
		System.assertEquals(1, registrations.size());
		
		//Update the Child Meeting record
		childMeeting.Auto_Subscribe__c = true;
		update childMeeting;
		
		//Check meeting have registarion records for all contacts
		registrations = [Select Id from Registration__c where Meeting__c =: childMeeting.Id AND Contact__c IN: contacts];
		System.assertEquals(contacts.size(), registrations.size());
		
		//Stop Testing from here
		Test.stopTest();
	}
	
	//This method is to create the records in registration object for already registered contacts
	//if Auto Subscribed checkbox is check on the child meeting
	static testMethod void testCreateRegistrationForParentRegisteredContactsWithBatch() {
		
		//Create test data
		
		//Create Parent meeting records
		Meeting__c parentMeeting = CreateMeeting(true);
		
		//Create a list of Contatcs and Insert
		List<Contact> contacts = new List<Contact>();
		
		//Add contacts in list
		contacts.add(testUtilities.CreateNewContact(false));
		contacts.add(testUtilities.CreateNewContact(false));
		
		//Insert the contacts
		insert contacts;
		
		//Create a list of Registration records
		List<Registration__c> registrations = new List<Registration__c>();
		
		//Loop through the contacts and create the registration records
		for(Contact contact : contacts) {
			
			//Add registration records
			registrations.add(CreateRegistration(parentMeeting.Id, contact.Id, false));
		}
		
		//insert registrations
		insert registrations;
	
		//Create a Child Metting record
		Meeting__c childMeeting = CreateMeeting(false);
		childMeeting.Parent_Meeting__c = parentMeeting.Id;
		childMeeting.Auto_Subscribe__c = false;
		insert childMeeting;
		
		//Create a registration for Child Meeting
		insert new Registration__c(Meeting__c = childMeeting.Id, Contact__c = contacts[0].Id, Status__c = 'Registered');
	
		//Start testing from here
		Test.startTest();
		
		//Check meeting doesn't have any registarion record
		registrations = [Select Id from Registration__c where Meeting__c =: childMeeting.Id];
		System.assertEquals(1, registrations.size());
		
		//Update the Child Meeting record
		childMeeting.Auto_Subscribe__c = true;
		
		//Set the Registration Creation Limit 
		MeetingTriggerHelper.LIMIT_REGISTRATION_CREATE = 0;
		update childMeeting;
		
		//Stop Testing from here
		Test.stopTest();
		
		//Check meeting have registarion records for all contacts
		registrations = [Select Id from Registration__c where Meeting__c =: childMeeting.Id AND Contact__c IN: contacts];
		System.assertEquals(contacts.size(), registrations.size());
	}
}