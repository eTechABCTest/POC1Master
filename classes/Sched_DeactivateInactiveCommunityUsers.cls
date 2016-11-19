/**
 *  Description     :   This class is schedular to schedule Batch_DeactivateInactiveCommunityUsers updating inactive community users.
 *
 *  Created By      :	Victor Hanson
 *
 *  Created Date    :   05/22/2014
 *
 *  Revision Logs   :   V1.0 - Created
 *
 **/
global class Sched_DeactivateInactiveCommunityUsers implements Schedulable {
	
	//execute method
	global void execute(SchedulableContext SC) {
		
		//Instance of Batch_DeactivateInactiveCommunityUsers
		Batch_DeactivateInactiveCommunityUsers batchJob = new Batch_DeactivateInactiveCommunityUsers();
		
		//Execute the batch
		Database.executeBatch(batchJob, 100);
	}
}