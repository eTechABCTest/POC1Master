/*
    Purpose:   Monitor changed Sales Team members
                    Any changed/new OTMs with a "Chairman's Team" Role
                        pull Opportunities
                        query those Opportunities with OTMs
                        Populate Opportunity Chairman's Team Rep field with value from Chairman's Team OTM
    
    Create By:          Pratik (Synaptic contractor) 8/05/11
    
    Last Modified By:   Jeremy Nottingham (Synaptic) 8/30/11
    
    Current Version:    v1.1
    
    Revision Log:       v1.0 -  (PE 8/5/11) Created code
                        v1.1 -  (JN 8/30/11) Substantially changed logic, added comments, refined test code
                        v1.2 -  Modify by - Abhinav Sharma - 02/19/2014 - CR-20120208-412 - scheduled batch job automation
                        v1.3 -  Modify by - Abhinav Sharma - 04/19/2014 - CR-20140331-4909 - Updates to batch failure process
    */
    
global class Batch_MonitorOTMs implements Database.Batchable<sObject>, Database.Stateful
{
    
    public String debuglog = ''; // Variable to store errors to return in the completion email
    public Integer totalprocessed = 0; // Variable to store number of records processed
    Public String Query;
    
     //Added By Abhinav Sharma - 02/19/2014 - CR-20120208-412 - scheduled batch job automation
    //Variable is set to true when the batch job is executed from the Scheduled job.
    global Boolean ExecuteNextJob = false;
    
    //Added By Abhinav Sharma - 04/19/2014 - CR-20140331-4909
    //String variable to hold the entire log message string value
    global String debugLogStr;
    
    global Batch_MonitorOTMs () {
        debugLogStr = '';
    }
    
    global database.querylocator start(Database.BatchableContext BC)
    {
        if (Query == null)
        {
            Query = 'Select a.isDeleted,a.Opportunity.Signed_Opportunity_Contract__c,'
            + ' a.UserId,a.User.Name,a.TeamMemberRole, a.Id, a.OpportunityId From OpportunityTeamMember a'
            + ' where (a.lastModifiedDate = LAST_N_DAYS:3) and (a.TeamMemberRole=\'PT - Chairman\\\'s Team\''
            + ' or a.TeamMemberRole=\'RI - Chairman\\\'s Team\')';
        }

        return Database.getQueryLocator(query);
    }
   
    global void execute(Database.BatchableContext BC, List<sObject> lstReturnedRcrds)
    {
        Util.IsBatch = true;

        List<Opportunity> listOpportunity = new List<Opportunity>();
        
        Set<ID> OpportunityIDSet = new Set<ID>();
        
        totalprocessed += lstReturnedRcrds.size();
        for(sObject obj : lstReturnedRcrds) {
            OpportunityIDSet.add(((OpportunityTeamMember)obj).OpportunityId);
        }
            
        listOpportunity = [select Name,id, Chairman_s_Team_Rep__c,
            (select UserId from OpportunityTeamMembers 
                where (TeamMemberRole='PT - Chairman\'s Team' or TeamMemberRole='RI - Chairman\'s Team') limit 1) 
            from Opportunity 
            where Id in : OpportunityIDSet];
        
        for(Opportunity OpportunityObj:listOpportunity)
        {
            if(OpportunityObj.OpportunityTeamMembers.size() > 0)
            {
                OpportunityObj.Chairman_s_Team_Rep__c = OpportunityObj.OpportunityTeamMembers[0].UserId;
                debuglog += '<br/>opp updated: ' + OpportunityObj.Id + ' ' + OpportunityObj.Chairman_s_Team_Rep__c;
            }
        }
        
        //String variable to hold the error message string in case of any failure
        String logMessage = '';
            
        //Checking list for size value
        if(listOpportunity.size() > 0) {
        
            //Added By Abhinav Sharma - 04/19/2014 - CR-20140331-4909
            //Making a try to update the list of records and recording error messages will be wmailed to the SFAdmin 
            logMessage = Util.createLog(Database.update((listOpportunity),false));
            
            //Checking errors log messages string for blank value and append it to final error message string only and only if it have proper value with it
            if(logMessage != '') 
                debugLogStr += logMessage; 
        }   
        
       //Commented by - Abhinav Sharma - 04/19/2014 - CR-20140331-4909
       /*}
       catch(Exception exceptionObj)
       {
            //This catch block is not unit tested
           debuglog += '<br/>Exception after ' + totalprocessed + ' records:<br/>' + exceptionObj.getMessage();
       }*/
                
    }
    
    global void finish(Database.BatchableContext BC) {
        
        //Added By Abhinav Sharma - 04/19/2014 - Emailing recorded errors details to SFAdmin. - CR-20140331-4909
        //Checking logMessage  string for blank value but if it does not have blank value with it then emailed it to SFAdmin.
        if(debugLogStr != '') {
            
            //User Instance
            //Refactored By Doug Roberts - 08/31/2015 - Remove query for SF user email and change to custom label
            //List<User> sfAdminUser = [Select Email FROM User WHERE Name = 'Salesforce Administrator' AND IsActive = true AND Profile.Name = 'System Administrator' AND Email!= null LIMIT 1];
            
            //Send log to admin
            //if(sfAdminUser.size() > 0)
                Util.sendBatchStatus(BC.getJobId(), 'Batch_MonitorOTMs', debugLogStr, Label.Salesforce_Admin_Email);
        }
    }
}