/**
 *  Description     :   This class is schedular to schedule Batch_UpdateCardHolderAddressInComdata updating Card Holder's Address in Comdata.
 *
 *  Created By      :	Bhavi Sharma
 *
 *  Created Date    :   09/25/2013
 *
 *  Revision Logs   :   V_1.0 - Created
 *
 **/
global class Sched_UpdateCardHolderAddressInComdata implements Schedulable {
	
	//execute method
	global void execute(SchedulableContext SC) {
		
		//Instance of Batch_UpdateCardHolderAddressInComdata
		Batch_UpdateCardHolderAddressInComdata batchJob = new Batch_UpdateCardHolderAddressInComdata();
		
		//Execute the batch
		Database.executeBatch(batchJob, 10);
	}
}