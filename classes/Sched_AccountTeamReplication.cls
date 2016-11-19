/**
 *	Purpose			:	This class is to schedule the AccountTeamReplication batch
 *
 *	Created By		:	Bhavi Sharma
 *
 *	Created Date	:	04/02/2015
 *
 *	Revision Logs	:	V_1.0 - Created 
 *
 **/ 
global class Sched_AccountTeamReplication implements Schedulable {
	
	//Execute Schedular
	global void execute(SchedulableContext ctx) {
		
		//Execute the batch
		Batch_AccountTeamReplication batchJob = new Batch_AccountTeamReplication();
		database.executeBatch(batchJob, 200);
	}
}