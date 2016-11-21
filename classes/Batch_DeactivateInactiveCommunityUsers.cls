/*
    Purpose			:	This batch is used to deactivate all inactive community users
    
    Create By		:  	Victor Hanson
    
    Current Version	:   v1.0
    
    Revision Log	:   Created.
*/
global class Batch_DeactivateInactiveCommunityUsers implements Database.Batchable<sObject>{
	
	
	public String debugLogStr = ''; // Variable to store errors to return in the completion email
	
	//override start method to initiate the init processing
	global Database.queryLocator start(Database.BatchableContext BC) {
		
        set<Id> profileIdSet = new set<Id>();
        
        //get the list of community profile names
        map<string, Community_Profiles__c> communityProfileMap = Community_Profiles__c.getAll();
        list<string> communityProfileNames = new list<string>();
        for (Community_Profiles__c cp : communityProfileMap.values()) communityProfileNames.add(cp.Profile_Name__c);
        
        //get the profile ids and create the SOQL query
        string profileIdString = '';
        map<Id, Profile> profileMap = new map<Id, Profile>([SELECT Id FROM Profile WHERE Name IN :communityProfileNames]);
        
		//Query to fecth Opportunities
		return Database.getQueryLocator([SELECT Id, ContactId, IsActive 
                                         FROM User 
                                         WHERE ProfileId IN :profileMap.keySet() 
                                         AND IsActive = true]);
	}
	
	//process the result reurned by start method
    global void execute(Database.BatchableContext ctx, List<Sobject> scope) {
    	
        //String variable to hold the error message string in case of any failure
        String logMessage = '';
        
    	//send all user records to our deactivation method
    	list<User> usersToDeactivate = UserTriggerHelper.deactivateInactiveCommunityUsers((list<User>) scope);
        
        //Checking list for the size value
        if(usersToDeactivate.size() > 0) {
        
            //try to update the list of records and record error messages will be emailed to the SFAdmin 
            logMessage = Util.createLog(Database.update((usersToDeactivate),false));
            
            //Checking errors log messages string for blank value and append it to final error message string only and only if it have proper value with it
            if(logMessage != '') 
                debugLogStr += logMessage; 
        }
        
    }
    
    //method for post processing
    global void finish(Database.BatchableContext BC) {
    	
        //Checking logMessage  string for blank value but if it does not have blank value with it then emailed it to SFAdmin.
        if(debugLogStr != '') {
            
            //User Instance
			//Refactored By Doug Roberts - 08/31/2015 - Remove query for SF user email and change to custom label
			//List<User> sfAdminUser = [Select Email FROM User WHERE Name = 'Salesforce Administrator' AND IsActive = true AND Profile.Name = 'System Administrator' AND Email!= null LIMIT 1];
            
            //Send log to admin
			//if(sfAdminUser.size() > 0)
                Util.sendBatchStatus(BC.getJobId(), 'Batch_MonitorATMs', debugLogStr, Label.Salesforce_Admin_Email);
        }
    }
}