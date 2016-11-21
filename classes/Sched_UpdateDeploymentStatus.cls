/**
 *  Purpose         :   Scheduler for Batch_UpdateDeploymentStatus
 *
 *  Created By      :   Bhavi Sharma
 *
 *  Created Date    :   05/14/2013
 *
 *  Revision Logs   :   V_1.0 - Created
                        V_1.1 - Modify by - Abhinav Sharma - 02/19/2014 - CR-20120208-412 - scheduled batch job automation
 *
 **/ 
global class Sched_UpdateDeploymentStatus implements Schedulable {
    
    //Execute method
    global void execute(SchedulableContext sc) {

        //Added By Abhinav Sharma - 02/19/2014 - CR-20120208-412 - scheduled batch job automation
        //Setting flag value to true for scheduling next jobs
        Batch_UpdateDeploymentStatus batch = new Batch_UpdateDeploymentStatus();
        batch.ExecuteNextJob = true;
        
        //Execute batch
        Database.executeBatch(batch,200);
    }
}