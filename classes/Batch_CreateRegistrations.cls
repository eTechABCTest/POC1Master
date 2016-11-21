/*
	Description		:	This class is to create the registration programs
	
	Created By		:	Bhavi Sharma
	
	Created Date	:	02/25/2013
	
	Revision Logs	:	v1.0 - Created
*/
global class Batch_CreateRegistrations implements Database.Batchable<sObject> {
	
	//SOQLQuery
	public String SOQLQuery;
	
	//Map to hold the Parent and child
	public Map<Id, Set<Id>> mapParentsWithChildMeetings;
	public Set<String> exitingChildRegistration;
	
	//Set meetingIds 
	public Set<Id> meetingIds;
	
	//Override start method
	global Database.QueryLocator start(Database.BatchableContext BC) {
		
		//Get data from Database
		return Database.getQueryLocator([Select Id, Meeting__c, Contact__c from Registration__c where Meeting__c IN: meetingIds]);
	}
	
	// Execute(Database.BatchableContext, List<sObject>) method from the Database.Batchable class
    global void execute(Database.BatchableContext BC, List<sObject> sObjects) {
    	
    	//Cast results is Registration
    	List<Registration__c> registrations = (List<Registration__c>)sObjects;
    	
    	//Create a new list of registration to be inserted
    	List<Registration__c> newRegistarations = new List<Registration__c>();
    	    	
    	//Loop through the registration records
    	for(Registration__c registration : registrations) {
    		
    		//Get the Auto subscribed Child from Map
    		if(mapParentsWithChildMeetings.containsKey(registration.Meeting__c)) {
    			
    			//Loop through the children and create registration record for each
    			for(Id childMeetingId : mapParentsWithChildMeetings.get(registration.Meeting__c)) {
    				
    				//Create the registration record for each Child Meeting
    				//Add registration record
					if(exitingChildRegistration == null || !exitingChildRegistration.contains(childMeetingId + '-' + registration.Contact__c))
						newRegistarations.add(new Registration__c(Contact__c = registration.Contact__c, Meeting__c = childMeetingId, Status__c = 'Registered'));
    			}
    		} 
    	}
    	
    	//Check for the registration list size()
    	if(newRegistarations.size() > 0)
    		insert newRegistarations;
    }
    
	// Finish(Database.BatchableContext) method from the Database.Batchable class
    global void finish(Database.BatchableContext BC) {
    	
    }
}