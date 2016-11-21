@istest
class Test_Sched_CheckDeletedTMs 
{
/*
    Purpose:    Test class for Sched_CheckDeletedTMs  
    
    Create By:          Jeremy Nottingham (Synaptic) 9/7/11
    
    Last Modified By:   Jeremy Nottingham (Synaptic) 9/7/11
    
    Current Version:    v1.0
    
    Revision Log:       v1.0 -  (JN 9/7/11) Created code
    */
    
    public static String CRON_EXP = '0 0 0 3 9 ? 2022';
    
    static testmethod void test()
    { 
        //Bypass Dupeblocker
        Util.IsTest(true);
        Util.IsTesting = true;
        
       
Test.startTest();
        // Schedule the test job at midnight Sept. 3rd. 2022
        String jobId = System.schedule('Test_Sched_CheckDeletedTMs', '0 0 0 3 9 ? 2022', new Sched_CheckDeletedTMs());
        // Get the information from the CronTrigger API object
        CronTrigger ct = [SELECT id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId];
        // Verify the expressions are the same
        System.assertEquals('0 0 0 3 9 ? 2022', ct.CronExpression);
        // Verify the job has not run
        System.assertEquals(0, ct.TimesTriggered);
Test.stopTest();
   }   
}