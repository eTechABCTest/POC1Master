/*
    Purpose:    Run multiple scheduled jobs
                    Monitor changed Sales Team members
                    Monitor changed Account Team Members
                    Rebuild RecordtypeSettings custom settings table
    
    Create By:          Pratik (Synaptic contractor)
    
    Last Modified By:   Jeremy Nottingham (Synaptic) 9/20/11
    
    Current Version:    v1.2
    
    Revision Log:       v1.0 -  Created code
                        v1.1 - (JN 8/31/11) Modified to limit test records
                        v1.2 - (JN 9/20/11) fixed error in querystring
                        v1.3 - Code modified - Bhavi Sharma - 06/17/2013 - CR-20130513-3009
                        v1.4 - Code modified - Bhavi Sharma - 10/08/2013 - CR-20130821-3487
                        v1.5 - Modify by - Abhinav Sharma - 02/19/2014 - CR-20120208-412 - scheduled batch job automation
    */ 

global class Sched_MonitorTMs_Recordtypes implements Schedulable
{
    global void execute(SchedulableContext SC)
    {
        
        //Commented this line - Bhavi Sharma - 10/08/2013 - CR-20130821-3487
        //Integer batchsize = 25;   // DAF - added 10/5/11
        
        //Code modified - Bhavi Sharma - 10/08/2013 - CR-20130821-3487
        //Batch size reduce from 25 to 5
        Integer batchsize = 5;
        
        //Only run one execute for each batch if Testing
        String recordlimit ='';
        if (Util.IsTesting) recordlimit = ' limit 200';
        
        Batch_MonitorATMs sObjBatch_MonitorATMs = new Batch_MonitorATMs();
        
        //Code modified by - Bhavi Sharma - 06/17/2013 - CR-20130513-3009
        //String atmRoleList = '(' + '\'AE or EA\'' + ',' +  ' \'RI' + ' ' + '-'  + ' ' + 'Executive' + ' ' + 'Advisor\'' +',' +' \'RI' + ' ' + '-'  + ' ' + 'Account ' + 'Exec\''+')';
        
        // sObjBatch_MonitorATMs.Query = 'Select Id, (Select Id, TeamMemberRole From AccountTeamMembers where (TeamMemberRole IN '+ atmRoleLIst+' or TeamMemberRole like \'%Marketer\')'
        //                               + ' and lastModifiedDate = LAST_N_DAYS:3) From Account Where Id IN (Select AccountId FROM AccountTeamMember)' +recordlimit;
        
        Batch_MonitorOTMs sObjBatch_MonitorOTMs = new Batch_MonitorOTMs();
        
        sObjBatch_MonitorOTMs.Query = 'Select a.isDeleted,a.Opportunity.Signed_Opportunity_Contract__c,'
            + ' a.UserId,a.User.Name,a.TeamMemberRole, a.Id, a.OpportunityId From OpportunityTeamMember a'
            + ' where (a.lastModifiedDate = LAST_N_DAYS:3) and (a.TeamMemberRole=\'PT - Chairman\\\'s Team\''
            + ' or a.TeamMemberRole=\'RI - Chairman\\\'s Team\')'
            + recordlimit;
            
        //Added By Abhinav Sharma - 02/19/2014 - CR-20120208-412 - scheduled batch job automation
        //Setting flag value to true for scheduling next jobs
        sObjBatch_MonitorATMs.ExecuteNextJob = true;
        
        try
        {    
            ID batchprocessid1 = Database.executeBatch(sObjBatch_MonitorATMs, batchsize);   // DAF - 10/5/11 - added batchsize parameter
            ID batchprocessid2 = Database.executeBatch(sObjBatch_MonitorOTMs, batchsize);   // DAF - 10/5/11 - added batchsize parameter
            Util.resetRecordtypeSettings();
        }
        catch(Exception exceptionObj)
        {
            System.debug('Exception number ---- '+exceptionObj);
            throw exceptionObj;
        }
    }    
}