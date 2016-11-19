global class Sched_CheckDeletedTMs implements Schedulable
{
/*
    Purpose:    Run multiple scheduled jobs
                    Check Deleted ATMs
                    Check Deleted OTMs
    
    Create By:          Jeremy Nottingham (Synaptic) 8/31/11
    
    Last Modified By:   Jeremy Nottingham (Synaptic) 9/20/11
    
    Current Version:    v1.2
    
    Revision Log:       v1.0 -  Created code
                        v1.1 - (JN 9/8/11) Modified to limit test records
                        v1.2 - (JN 9/20/11) fixed error in querystring
                        v1.3 - Modify by - Abhinav Sharma - 02/19/2014 - CR-20120208-412 - scheduled batch job automation
    */

    global void execute(SchedulableContext SC)
    {
        //Only run one execute for each batch if Testing
        String recordlimit ='';
        if (Util.IsTesting) recordlimit = ' limit 200';
        
        Batch_CheckDeletedATMs sObjBatch_CheckDeletedATMs = new Batch_CheckDeletedATMs();
        sObjBatch_CheckDeletedATMs.Query = 'Select Id, EA_AE__c, EA_Contact__c,'
            + ' (Select TeamMemberRole, UserId from AccountTeamMembers where TeamMemberRole like \'%Executive Advisor&\''
            + ' or TeamMemberRole like \'%Account Exec%\' or TeamMemberRole = \'AE or EA\' limit 1)'
            + ' from Account where EA_AE__c != null or EA_Contact__c != null'
            + recordlimit;
        
        Batch_CheckDeletedOTMs sObjBatch_CheckDeletedOTMs = new Batch_CheckDeletedOTMs();
        sObjBatch_CheckDeletedOTMs.Query = 'Select Id, Chairman_s_Team_Rep__c,'
            + ' (Select TeamMemberRole, UserId from OpportunityTeamMembers'
            + ' where TeamMemberRole like \'%Chairman\\\'s Team%\' limit 1)'
            + ' from Opportunity where Chairman_s_Team_Rep__c != null'
            + recordlimit;
            
        //Added By Abhinav Sharma - 02/19/2014 - CR-20120208-412 - scheduled batch job automation
        //Setting flag value to true for scheduling next jobs
        sObjBatch_CheckDeletedATMs.ExecuteNextJob = true;
        
        try
        {    
            ID batchprocessid1 = Database.executeBatch(sObjBatch_CheckDeletedATMs);
            ID batchprocessid2 = Database.executeBatch(sObjBatch_CheckDeletedOTMs);
            Util.resetRecordtypeSettings();
        }
        catch(Exception exceptionObj)
        {
            System.debug('Exception number ---- '+exceptionObj);
            throw exceptionObj;
        }
    }    
}