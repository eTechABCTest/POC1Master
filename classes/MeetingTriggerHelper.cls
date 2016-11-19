/**
 * 	Description 	:	Helper class for Trigger Meeting
 * 
 * 	Created By		:	Bhavi Sharma
 * 
 * 	Created Date	:	02/22/2013
 * 
 * 	Revision Logs	:	V1.0 - Created
 * 
 **/
public class MeetingTriggerHelper {
	
	//This flag is to set the Registration creation limit
	public static Integer LIMIT_REGISTRATION_CREATE = 2000;

	//This method is to create the regitration record for the child records associated with the Parent in Context
	public static void createRegistrationForParentRegisteredContacts(Map<Id, Meeting__c> mapNewMeetings, Map<Id, Meeting__c> mapOldMeetings) {
		
		//Get all the parent Meeting and Create a set for that
		Set<Id> parentMeetings = new Set<Id>();
		Map<Id, Set<Id>> mapParentsWithChildMeetings = new Map<Id, Set<Id>>();
		
		//Loop through the new meetings
		for(Meeting__c meeting : mapNewMeetings.values()) {
			
			//Check if parent is not null
			if(meeting.Parent_Meeting__c != null && meeting.Auto_Subscribe__c == true && mapOldMeetings.containsKey(meeting.Id) 
					&& meeting.Auto_Subscribe__c != mapOldMeetings.get(meeting.Id).Auto_Subscribe__c)
				
				//Add meeting in Set
				parentMeetings.add(meeting.Parent_Meeting__c);
				
				//Add in map
				if(mapParentsWithChildMeetings.containsKey(meeting.Parent_Meeting__c))
					mapParentsWithChildMeetings.get(meeting.Parent_Meeting__c).add(meeting.Id);
				else
					mapParentsWithChildMeetings.put(meeting.Parent_Meeting__c, new Set<Id>{meeting.Id});
		}
		
		//Create a set to hold teh existing registrations for Child
		Set<String> exitingChildRegistration = new Set<String>();
		
		if(mapOldMeetings != null) {
			
			//Get registration data
			for(Registration__c r : [Select Id, Meeting__c, Contact__c from Registration__c where Meeting__c != null 
													AND Meeting__c IN: mapOldMeetings.keySet() AND Contact__c != null]) {
				
				//Add data in Set
				exitingChildRegistration.add(r.Meeting__c + '-' + r.Contact__c);										
			}
		}
		
		//Get all the existing registrations for parents
		if(parentMeetings.size() > 0) {
			
			//Create a map to hold all the registration against a Meeting
			Map<Id, List<Registration__c>> mapMeetingIdsWithRegistration = new Map<Id, List<Registration__c>>();
			
			List<Registration__c> existingRegs = [Select Id, Meeting__c, Contact__c from Registration__c where Meeting__c != null 
													AND Meeting__c IN: parentMeetings AND Contact__c != null];
			
			//Check if existingRegs are more than 2000, then execute the batch 
			//else create the registration from trigger itself
			if(existingRegs.size() > MeetingTriggerHelper.LIMIT_REGISTRATION_CREATE) {
				
				//Execute batch
				Batch_CreateRegistrations batchJob = new Batch_CreateRegistrations();
				batchJob.meetingIds = parentMeetings;
				batchJob.exitingChildRegistration = exitingChildRegistration;
				batchJob.mapParentsWithChildMeetings = mapParentsWithChildMeetings;
				
				//Execute batch job
				database.executeBatch(batchJob);
			
				return;
			}
			
			
			//Get all the data from database
			for(Registration__c registration : existingRegs) {
				
				//Check for the parent and add registration in map
				if(mapMeetingIdsWithRegistration.containsKey(registration.Meeting__c)) {
					
					//Add the contact id in set of contact
					mapMeetingIdsWithRegistration.get(registration.Meeting__c).add(registration);
				} else {
					
					//Create a new registration
					mapMeetingIdsWithRegistration.put(registration.Meeting__c, new List<Registration__c>{registration});
				}
			}
			
			//Create a list of registration to be inserted
			List<Registration__c> registrations = new List<Registration__c>();
			
			//Loop through the new registrattion records
			for(Meeting__c meeting : mapNewMeetings.values()) {
				
				//Check if Parent is not null
				if(meeting.Parent_Meeting__c != null && mapMeetingIdsWithRegistration.containsKey(meeting.Parent_Meeting__c)) {
					
					//Loop through the contacts
					for(Registration__c registration : mapMeetingIdsWithRegistration.get(meeting.Parent_Meeting__c)) { 
						
						//Add registration record
						if(!exitingChildRegistration.contains(meeting.Id + '-' + registration.Contact__c))
							registrations.add(new Registration__c(Meeting__c = meeting.Id, Contact__c = registration.Contact__c, Status__c = 'Registered'));
					}
				} 
			}
			
			//Check for the registration size
			if(registrations.size() > 0)
				insert registrations;
		}
	}
}