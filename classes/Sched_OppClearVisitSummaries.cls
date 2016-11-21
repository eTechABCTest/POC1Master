global class Sched_OppClearVisitSummaries implements Schedulable {
    /*
    Purpose:    To kick offBatch_Opportunity_ClearVisitSummaries.  Includes test method.
    
    Create By:          Drew Freeman 8/20/11
    
    Last Modified By:   
    
    Current Version:    v1.0
    
    Revision Log:       
                        
    Code Coverage as of 1/26/2011: 100%
    */
    
    //Reduce batch size to 50 to avoid governor overruns on SOQL rows
//    global Integer batchsize = 50;
    global Integer batchsize = 500;
    
    public Id batchprocessid;
    public static String CRON_EXP = '0 0 0 3 9 ? 2022'; //CRON notation for 9/3/2022 00:00:00, for testing
    
    global Sched_OppClearVisitSummaries() {
    }
    
    global void execute(SchedulableContext ctx) {
        Batch_Opportunity_ClearVisitSummaries batch = new Batch_Opportunity_ClearVisitSummaries();
        batchprocessid = Database.executeBatch(batch, 30);
        
        if (batchprocessid != null)
            Util.ScheduleHasRun = true;
    }
    
    /****** Testing *******/
    
    static testmethod void testSched() { 
        //Bypass Dupeblocker
        Util.IsTest(true);
        Util.IsTesting = true;
        system.assertEquals(false, Util.ScheduleHasRun);
        
        
        test.StartTest();  
            
        // Schedule the test job
        Sched_OppClearVisitSummaries sched = new Sched_OppClearVisitSummaries();
        
        String jobId = System.schedule('testSched_OppVisitSummaries',
            Sched_OppClearVisitSummaries.CRON_EXP, sched);
        
        // Get the information from the CronTrigger API object
        CronTrigger ct = [SELECT id, CronExpression, TimesTriggered, NextFireTime
            FROM CronTrigger WHERE id = :jobId];
        
        // Verify the expressions are the same
        System.assertEquals(Sched_OppVisitSummaries.CRON_EXP, ct.CronExpression);
        
        // Verify the job has not run
        System.assertEquals(0, ct.TimesTriggered);
        
        // Verify the next time the job will run
        System.assertEquals('2022-09-03 00:00:00', String.valueOf(ct.NextFireTime));
        
        ct = [SELECT TimesTriggered, TimeZoneSidKey, State, StartTime, PreviousFireTime, 
            OwnerId, NextFireTime,Id, EndTime, CronExpression   FROM CronTrigger WHERE id = :jobId];
        
        system.debug('\n\n52 ct ' + ct);        
        
        Test.stopTest();
        
        
        // Verify the job has now run
        system.assertEquals(True, Util.ScheduleHasRun);
    }
}