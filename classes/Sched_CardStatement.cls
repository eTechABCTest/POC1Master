global class Sched_CardStatement implements Schedulable {
    
    //Execute method
    global void execute(SchedulableContext sc) {

        //Execute batch
        Database.executeBatch(new Batch_CardStatement(),10);
    }
}