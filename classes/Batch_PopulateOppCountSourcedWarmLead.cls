/**
 *  Purpose         :   This batch is used for populate Opporutnity's Count of Sourced Warm Lead field.
 *
 *  Created By      :   Bhavi Sharma
 *
 *  Created Date    :   11/14/2013
 *
 *  Current Version :   v1.0 - Created - CR-20130417-2892
 **/
global class Batch_PopulateOppCountSourcedWarmLead implements Database.Batchable<SObject>{
	
	//Debug Log
    global String debugLog;

    //Start method
    global Database.Querylocator start(Database.BatchableContext BC) {

        //Initialize
        debugLog = '';
        
        //return query result
        return Database.getQueryLocator([SELECT Id, Warm_Lead__c, Count_of_Warm_Leads__c, Initial_Visit_Date__c, Count_of_Sourced_Warm_Leads__c,
        									(SELECT Id, Warm_Lead__r.Lead_Date__c FROM Warm_Leads_MtM__r) FROM Opportunity ]);
    }
    
    //Execute method
    global void execute(Database.BatchableContext BC, List<Opportunity> opportunities) {
    	
    	//Loop through Opportunities
    	for(Opportunity opportunity : opportunities) {
    		
    		//initialize Count of Source Warm Leads Zero initially
    		opportunity.Count_of_Sourced_Warm_Leads__c = 0;
    		
    		if(opportunity.Initial_Visit_Date__c == null)
    			opportunity.Count_of_Sourced_Warm_Leads__c = opportunity.Warm_Leads_MtM__r.size();
	    	else {
	    		
	    		//Loop through WarmLeadMtm
	    		for(Warm_Lead_MtM__c warmLeadMtm : opportunity.Warm_Leads_MtM__r){
	    			
	    			//Check if Opportunity's Initial Visit Date is greater its Child Warm Lead's Lead Date
	    			if(warmLeadMtm.Warm_Lead__r.Lead_Date__c == null || warmLeadMtm.Warm_Lead__r.Lead_Date__c < opportunity.Initial_Visit_Date__c){
	    				
	    				//Check for Count_of_Sourced_Warm_Leads__c field value is not null or blank
	    				opportunity.Count_of_Sourced_Warm_Leads__c += 1;
	    			}	
	    		}
	    	}
    	}
    	
    	//Allow partial update
    	Util.BypassAllTriggers = true;
        Database.SaveResult[] results = database.update(opportunities, false);

        //Create log
        debugLog += Util.createLog(results);
    }
    
    //Finish method
    global void finish(Database.BatchableContext BC) {

		//Check if any error occured and then send the email
    	if(debugLog != '' && debugLog != null) {
		
			//Query the asynchronous jobs results
			AsyncApexJob aSyncJob = [SELECT Id, JobItemsProcessed, TotalJobItems, NumberOfErrors, CreatedBy.Email FROM AsyncApexJob
	                            WHERE id = :BC.getJobId()];
	
			// Send email indicating the completion of this batch
			String emailMessage = 'Your batch job Batch_PopulateOppCountSourcedWarmLead has finished.  It processed job items'
						+ aSyncJob.totalJobItems +
						' batches.  Of which, '
						+ aSyncJob.JobItemsProcessed
						+ ' processed without any exceptions thrown and '
						+ aSyncJob.numberOfErrors
						+ ' batches threw unhandled exceptions.' ; 
					
			emailMessage += '<br>' + debugLog;
    	
			//Send batch status to the person who executed this batch
			EmailHandler.sendEmail(aSyncJob.CreatedBy.Email, 'Batch_PopulateOppCountSourcedWarmLead has been completed', emailMessage, emailMessage);
    	}
    }
}