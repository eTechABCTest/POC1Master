global class Sched_OpportunityEvaluationCounts {

    /*
    Purpose:            Kicks off Batch_OpportunityEvaluationCounts  Includes test method.
    
    Created By:         Drew Freeman
    
    Last Modified By:   Drew Freeman - 1/4/2012
    
    Current Version:    v1.0
    
    Revision Log:       v1.0 - (DAF-2012-01-03) Created code as Sched_OpportunityEvaluationCounts
                        v1.1 - Modify by - Abhinav Sharma - 02/19/2014 - CR-20120208-412 - scheduled batch job automation
                        
    Code Coverage as of 1/4/2012: 100%
    

    global Integer batchsize = 200;
    
    public Id batchprocessid;
    public static String CRON_EXP = '0 0 0 3 9 ? 2022'; //CRON notation for 9/3/2022 00:00:00, for testing
    public boolean ScheduleHasRun = false;
    
    global Sched_OpportunityEvaluationCounts() {
    }

    global void execute(SchedulableContext BC)
    {
        //Call Batch with specified batch size
        Batch_OpportunityEvaluationCounts batch = new Batch_OpportunityEvaluationCounts();
        
        //Added By Abhinav Sharma - 02/19/2014 - CR-20120208-412 - scheduled batch job automation
        //Setting flag value to true for scheduling next jobs
        batch.ExecuteNextJob = true;
        
        //Execute Batch
        batchprocessid = Database.executeBatch(batch, batchsize); 
        
        if (batchprocessid != null)
           ScheduleHasRun = true;
    }
     
    
    
    static testmethod void testSched()
    { 
        //Bypass Dupeblocker
        Util.IsTest(true);
        Util.byPassAllTriggers = true;
//        Util.IsTesting = true;

        Account acc = new Account(Name = 'testacc', Account_Formal_Name__c = 'testacc');
        insert acc;

        Opportunity opp = new Opportunity(AccountId = acc.Id, Name = 'Test', StageName = 'Pending', CloseDate = System.today(), Are_They_Evaluating__c = 'Yes', 
        Is_there_are_hard_next_step__c = 'Yes', Initial_Visit_Date__c = date.today());
        insert opp;

        Event evt = new Event(WhatId = opp.Id, StartDateTime = datetime.now().addDays(4), EndDateTime = datetime.now().addDays(5));
        insert evt;             

        Event evt2 = new Event(WhatId = opp.Id, StartDateTime = datetime.now().addDays(5), EndDateTime = datetime.now().addDays(6));
        insert evt2;                
 
        test.StartTest();  
        
        Util.byPassAllTriggers = false;
             
        // Schedule the test job
        Sched_OpportunityEvaluationCounts sched = new Sched_OpportunityEvaluationCounts();
        system.assertEquals(false, Util.ScheduleHasRun);
        
        String jobId = System.schedule('testSched_OpportunityEvaluationCounts',
            Sched_OpportunityEvaluationCounts.CRON_EXP, sched);

        Test.stopTest();
        
        // Get the information from the CronTrigger API object
        CronTrigger ct = [SELECT id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId];
        
        // Verify the expressions are the same
        System.assertEquals(Sched_OpportunityEvaluationCounts.CRON_EXP, ct.CronExpression);
        
        // Verify the job has not run
        System.assertEquals(0, ct.TimesTriggered);
        
        // Verify the next time the job will run
        System.assertEquals('2022-09-03 00:00:00', String.valueOf(ct.NextFireTime));
        
        ct = [SELECT TimesTriggered, TimeZoneSidKey, State, StartTime, PreviousFireTime, 
            OwnerId, NextFireTime,Id, EndTime, CronExpression FROM CronTrigger WHERE id = :jobId];
        
        system.debug('\n\n52 ct ' + ct);        
        
    }*/
}