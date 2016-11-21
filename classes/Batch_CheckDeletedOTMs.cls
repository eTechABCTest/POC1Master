global class Batch_CheckDeletedOTMs implements Database.Batchable<sObject>, Database.Stateful
{
    /*
    Purpose:   Monitor changed Account Team Members
                If changed ATM is "EA or AE" type
                    query Accounts with ATMs
                    populate Account AE_EA__c field with UserID from ATM
                If changed ATM is "Marketer" type
                    query Accounts with those ATMs and associated Memberships
                    for each Membership, evaluate whether Assigned Marketer needs to change
                    for each Membership, evaluate whether OwnerId needs to change
                    
    
    Create By:          Jeremy Nottingham (8/30/11)
    
    Last Modified By:   Jeremy Nottingham (8/30/11) 
    
    Current Version:    v1.1
    
    Revision Log:       v1.0 - (PE 8/5/11) Created code
                        v1.1 - (JN 8/30/11) Substantially changed logic, added comments, refined test code
                        v1.2 - modify by - Abhinav Sharma - 04/19/2014 - CR-20140331-4909 - Updates to batch failure process
    */
    public String debuglog = ''; // Variable to store errors to return in the completion email
    public Integer totalprocessed = 0; // Variable to store number of records processed
    Public String Query;
    
    //Added By Abhinav Sharma - 04/18/2014 - CR-20140331-4909
    //String variable to hold the entire log message string value
    global String debugLogStr;
    
    global Batch_CheckDeletedOTMs () {
        debugLogStr = '';
    }
    
    global database.querylocator start(Database.BatchableContext BC)
    {
        if (Query == null)
        {
            Query = 'Select Id, Chairman_s_Team_Rep__c,'
                + ' (Select TeamMemberRole, UserId from OpportunityTeamMembers where TeamMemberRole like \'%Chairman\\\'s Team%\''
                + ' limit 1)'
                + ' from Opportunity where Chairman_s_Team_Rep__c != null';
        }
        
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<sObject> scope)
    {
        Util.IsBatch = true;
        List<Opportunity> opps = (list<Opportunity>)scope;
        totalprocessed += opps.size();
        
        //String variable to hold the error message string in case of any failure
        String logMessage = '';
        
        //Loop through opportunity records
        for (Opportunity o : opps) {
            
            if (o.OpportunityTeamMembers.size() == 0) {
                o.Chairman_s_Team_Rep__c = null;
            } else {
                o.Chairman_s_Team_Rep__c = o.OpportunityTeamMembers[0].UserId;
            }
        }
        
        //Making a try to update the opportunity records
        //Checking list for size value
        if(opps.size() > 0) {
        
            //Added By Abhinav Sharma - 04/19/2014 - CR-20140331-4909
            //Making a try to update the list of records and recording error messages will be wmailed to the SFAdmin 
            logMessage = Util.createLog(Database.update((opps),false));
            
            //Checking errors log messages string for blank value and append it to final error message string only and only if it have proper value with it
            if(logMessage != '') 
                debugLogStr += logMessage; 
        } 
        
          //Commented By - Abhinav Sharma - 04/19/2014 - CR-20140331-4909  
        /*try {
            update opps;
        } catch (Exception e) {
            debuglog += '<br/> Exception: ' + e.getMessage();
        }*/
    }
    
    global void finish(Database.BatchableContext BC) {
        
        //Added By Abhinav Sharma - 04/18/2014 - Emailing recorded errors details to SFAdmin. - CR-20140331-4909
        //Checking logMessage  string for blank value but if it does not have blank value with it then emailed it to SFAdmin.
        if(debugLogStr != '') {
            
            //User Instance
			//Refactored By Doug Roberts - 08/31/2015 - Remove query for SF user email and change to custom label
			//List<User> sfAdminUser = [Select Email FROM User WHERE Name = 'Salesforce Administrator' AND IsActive = true AND Profile.Name = 'System Administrator' AND Email!= null LIMIT 1];
            
            //Send log to admin
			//if(sfAdminUser.size() > 0)
                Util.sendBatchStatus(BC.getJobId(), 'Batch_CheckDeletedOTMs', debugLogStr, Label.Salesforce_Admin_Email);
        }
        
        //Commented By - Abhinav Sharma - 04/19/2014 - CR-20140331-4909
        /*// Get the ID of the AsyncApexJob representing this batch job
        // from Database.BatchableContext.
        // Query the AsyncApexJob object to retrieve the current job's information.
        // Retrieve the current Job information
        AsyncApexJob a = [Select Id, Status, NumberOfErrors, JobItemsProcessed, TotalJobItems, CreatedBy.Email from AsyncApexJob where Id = :BC.getJobId()];
        
        String emailMessage = 
            'Your batch job \"Batch_CheckDeletedOTMs\" has finished.  It processed ' + totalprocessed + ' records in ' 
            + a.totalJobItems +
            ' batches.  Of which, ' 
            + a.jobitemsprocessed 
            + ' processed without any exceptions thrown and ' 
            + a.numberOfErrors 
            + ' batches threw unhandled exceptions.<br/><br/>'
            + '<br/>Log of process:<br/>'
            + debuglog;
        
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        String[] toAddresses = new String[] {a.CreatedBy.email};
        
        mail.setToAddresses(toAddresses);
        mail.setReplyTo('noreply@salesforce.com');
        mail.setSenderDisplayName('Salesforce Batch'); 
        mail.setSubject('Batch_CheckDeletedOTMs job completed');
        mail.setPlainTextBody(emailMessage);
        mail.setHtmlBody(emailMessage);
        
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });*/
    }
}