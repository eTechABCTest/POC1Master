global class Batch_MembershipNextActivityDate implements Database.Batchable<SObject>, Database.Stateful {
    global final String Query;
    global final String Entity;
    global final String Field;
    global final String Value;
    
    //Added By Abhinav Sharma - 02/12/2014 - if there are failures in the database.saveResults[], they should be recorded - CR-20130718-3280
    //String variable to hold the entire log message string value
    global String debugLog;
    
    global Batch_MembershipNextActivityDate(String q)
    {
        Date dt = Date.today();
        String datetoday = String.valueof(dt);
        Query = q;
        debugLog = '';
        if (Query == null) {
            Query='SELECT Id, Next_Decision_Date__c, (SELECT Id, Start__c, Opt_Out_Date__c FROM Opportunities__r WHERE Status__c = \'Pending\' '+
                'AND Start__c >= ' + datetoday + 'ORDER BY Start__c ASC) FROM Membership__c ' +
                'WHERE Next_Decision_Date__c != null AND Next_Decision_Date__c < ' + datetoday;
        }
    } 
    global Database.QueryLocator start(Database.BatchableContext BC)
    {
        return Database.getQueryLocator(Query);
    }
    global void execute(Database.BatchableContext BC,List<sObject> scope)
    {
        List<Membership__c> memberships = (List<Membership__c>)scope;
        
        //Added By Abhinav Sharma - 02/12/2014 - Modify Batch_MembershipNextActivityDate to it uses System.Update() with AllOrNone = false so one failure won't cause the entire batch to fail.
        //Also, if there are failures in the database.saveResults[], they should be recorded and emailed to SFAdmin. - CR-20130718-3280
        String logMessage = OpportunityTriggerUtilities.UpdateNextDecisionDate(memberships); 
        
        //Checking errors log messages string for blank value and append it to final error message string only and only if it have proper value with it
        if(logMessage != '') 
            debugLog += logMessage; 
    } 
    
    global void finish(Database.BatchableContext BC)
    {
         //Updated By Abhinav Sharma - 08/12/2014 - CR-20140506-5358 - Added Limits.getLimitDMLStatements() in CronTrigger SOQL 
        // find all scheduled jobs with no Next Fire date and un-schedule them... 
        // Why keep them if they've already fired!?
        //Modify By Abhinav Sharma for catching exception (if any) - 02/12/2014 - CR-20130718-3280
        List<CronTrigger> jobs = [SELECT Id, NextFireTime FROM CronTrigger WHERE NextFireTime = null LIMIT : Limits.getLimitDMLStatements()];
        for (CronTrigger job : jobs) {
            try {
                system.abortJob(job.Id);
            } catch(Exception ex) {
                if(ex.getMessage().contains('Invalid parameter value'))
                    continue;
                else if(ex.getMessage().contains('Job does not exist or is already aborted'))
                    continue;
                else
                    throw new CustomException(ex.getMessage());
            }
        }
            
        //Added By Abhinav Sharma - 02/12/2014 - Modify Batch_MembershipNextActivityDate to it uses System.Update() with AllOrNone = false so one failure won't cause the entire batch to fail.
        //Also, if there are failures in the database.saveResults[], they should be recorded and emailed to SFAdmin. - CR-20130718-3280
        //Checking logMessage  string for blank value but if it does not have blank value with it then emailed it to SFAdmin.
        if(debugLog != '') {
            
            //User Instance
            //Refactored By Doug Roberts - 09/02/2015 - Remove query for SF user email and change to custom label
            //List<User> sfAdminUser = [Select Email FROM User WHERE Name = 'Salesforce Administrator' AND IsActive = true AND Profile.Name = 'System Administrator' AND Email!= null LIMIT 1];
            
            //Send log to admin
            //if(sfAdminUser.size() > 0)
                Util.sendBatchStatus(BC.getJobId(), 'Batch_MembershipNextActivityDate', debugLog, Label.Salesforce_Admin_Email);
        }
        
        // VRH 4/9/12 - start the next batch by kicking off a scheduled job
        // the reason we don't just piggyback 
        //Build the system time of now + 20 Seconds to schedule the batch apex.
        Datetime sysTime = System.now();
        sysTime = sysTime.addSeconds(20);
        String chron_exp = '' + sysTime.second() + ' ' + sysTime.minute() + ' ' + sysTime.hour() + ' ' + sysTime.day() + ' ' + sysTime.month() + ' ? ' + sysTime.year();
        Sched_MeetingUtilizations meetingUtilizations = new Sched_MeetingUtilizations();
        //Schedule the next job, and give it the system time so name is unique
        if(!Test.isRunningTest())
            System.schedule('Sched_MeetingUtilizations' + sysTime.getTime(),chron_exp,meetingUtilizations);
    }
}