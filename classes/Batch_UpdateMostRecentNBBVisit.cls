/**
 * 	Purpose			:	This batch class is to find all the events and update the Most_Recent_NBB_Visit__c field on the membership
 *							This is only one time batch script to update the existing data				
 * 
 * 	Created By		:	Bhavi Sharma(Simplyforce) 
 * 
 * 	Created Date	:	12/26/2013
 * 
 * 	Revision Logs	:	V_1.0 - Created
 *
 **/ 
global class Batch_UpdateMostRecentNBBVisit implements Database.Batchable<SObject>, Database.Stateful {
	
	//Debug Log
    global String debugLog;

    //Start method
    global Database.Querylocator start(Database.BatchableContext BC) {

        //Initialize
        debugLog = '';
        
        //return query result
        return Database.getQueryLocator([Select AccountId, Program__c from Opportunity where AccountId != null AND Program__c != null]);
    }
    
    //Execute method
    global void execute(Database.BatchableContext BC, List<Opportunity> opportunities) {
    	
    	//Create a set of opportunities
    	Set<Id> opportunitiesIds = (new Map<Id, Opportunity>(opportunities)).keySet();
    	
    	//call helper class method to update the membership data with the ralavent date
    	try {
    		
    		EventUtilities.UpdateMostRecentNBBVisitOnMembership(opportunitiesIds);
    	} catch (Exception e) {
    		
    		//Add error in debug message
    		debugLog += e.getMessage();
    	}
    }
    
    //Finish method
    global void finish(Database.BatchableContext BC) {

		//Check if any error occured and then send the email
    	if(debugLog != '' && debugLog != null) {
		
			//Query the asynchronous jobs results
			AsyncApexJob aSyncJob = [SELECT Id, JobItemsProcessed, TotalJobItems, NumberOfErrors, CreatedBy.Email FROM AsyncApexJob
	                            WHERE Id =: BC.getJobId()];
	
			// Send email indicating the completion of this batch
			String emailMessage = 'Your batch job Batch_UpdateMostRecentNBBVisit has finished.  It processed job items'
						+ aSyncJob.totalJobItems +
						' batches.  Of which, '
						+ aSyncJob.JobItemsProcessed
						+ ' processed without any exceptions thrown and '
						+ aSyncJob.numberOfErrors
						+ ' batches threw unhandled exceptions.' ; 
			
			emailMessage += '<br>' + debugLog;
			
			//Send batch status to the person who executed this batch
			EmailHandler.sendEmail(aSyncJob.CreatedBy.Email, 'Batch_UpdateMostRecentNBBVisit has been completed', emailMessage, emailMessage);
    	}
    }
}