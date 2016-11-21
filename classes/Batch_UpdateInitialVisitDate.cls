/*
    Purpose			:	This batch is to get all the AccountTeamMember data and subscribe them with account records - CR-20120104-298
    
    Create By		:  	Simplyforce - Bhavi - 12/15/2011
    
    Current Version	:   v1.0
    
    Revision Log	:   Created.
*/
global class Batch_UpdateInitialVisitDate implements Database.Batchable<sObject>{
	
	//Create the variable for SOQL Quesry - This will help to set the query manually
	global String SOQLQuery;
	
	//override start method to initiate the init processing
	global Database.queryLocator start(Database.BatchableContext BC) {
		
		//check if SOQLQuery is not set manually
		if(SOQLQuery == null && SOQLQuery == '' ) {
			SOQLQuery = 'Select Id from Opportunity';
		}
		
		//Query to fecth Opportunities
		return Database.getQueryLocator(SOQLQuery);
	}
	
	//process the result reurned by start method
    global void execute(Database.BatchableContext ctx, List<Sobject> scope) {
    	
    	//update opportunity data
    	Database.update(scope);
    }
    
    //method for post processing
    global void finish(Database.BatchableContext ctx) {
    	
    }
}