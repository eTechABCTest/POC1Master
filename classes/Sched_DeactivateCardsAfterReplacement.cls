/**
 *  Description     :   This class is schedular for schedule batch Batch_DeactivateCardsAfterReplacement .
 *
 *  Created By      :   Bhavi Sharma
 *
 *  Created Date    :   05/17/2014
 *
 *  Revision Logs   :   V_1.0 - Created
 *
 **/
global class Sched_DeactivateCardsAfterReplacement implements Schedulable {
    
    //Set to hold the ids of the cards owners
    global Set<Id> cardsOwners;
    
    //execute method
    global void execute(SchedulableContext SC) {
        
        //Execute the batch again
        Batch_DeactiveCardsAfterReplacement batchJob = new Batch_DeactiveCardsAfterReplacement();
        batchJob.cardsOwners = cardsOwners;
        Database.executeBatch(batchJob, 10);
    }
}