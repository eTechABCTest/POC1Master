/**
 *  Description     :   This class is schedular for schedule batch for manage Card limits.
 *
 *  Created By      :   Bhavi Sharma
 *
 *  Created Date    :   05/19/2015
 *
 *  Revision Logs   :   V_1.0 - Created
 *
 **/
global class Sched_IdentifySFComdataMismatching implements Schedulable {
    
    //execute method
    global void execute(SchedulableContext SC) {
        
        //Batch_IdentifySFComdataMismatching
        Batch_IdentifySFComdataMismatching batchJob = new Batch_IdentifySFComdataMismatching();
        Database.executeBatch(batchJob, 100);   
    }
}