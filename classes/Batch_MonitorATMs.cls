/*
    Purpose:   Monitor changed Account Team Members
                If changed ATM is "AE or EA" type
                    query Accounts with ATMs
                    populate Account AE_EA__c field with UserID from ATM
                If changed ATM is "Marketer" type
                    query Accounts with those ATMs and associated Memberships
                    for each Membership, evaluate whether Assigned Marketer needs to change
                    for each Membership, evaluate whether OwnerId needs to change
                    
    
    Create By:          Pratik 8/05/11
    
    Last Modified By:   Jeremy Nottingham (9/20/11) 
    
    Current Version:    v1.2
    
    Revision Log:       v1.0 - (PE 8/5/11) Created code
                        v1.1 - (JN 8/30/11) Substantially changed logic, added comments, refined test code
                        v1.2 - (JN 9/20/11) fixed error in querystring
                        v1.3 - Code modified - Bhavi Sharma - 06/17/2013 - CR-20130513-3009
                        v1.4 - Code modified - Victor Hanson - 06/20/2013 - CR-20130501-2958
                        v1.5 - Code modified - Bhavi Sharma - 10/08/2013 - CR-20130821-3487
                        v1.6 - Modify by - Abhinav Sharma - 02/19/2014 - CR-20120208-412 - scheduled batch job automation
                        v1.7 - Modify by - Abhinav Sharma - 04/19/2014 - CR-20140331-4909 - Updates to batch failure process
*/
    
global class Batch_MonitorATMs implements Database.Batchable<sObject>, Database.Stateful
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
    
    global Batch_MonitorATMs () {
        debugLogStr = '';
    }
    
    global database.querylocator start(Database.BatchableContext BC)
    {
        if (Query == null)
        {
            //Code modified by - Bhavi Sharma - 06/17/2013 - CR-20130513-3009
            String atmRoleList = '(' + '\'AE or EA\'' + ',' +  ' \'RI' + ' ' + '-'  + ' ' + 'Executive' + ' ' + 'Advisor\'' +',' +' \'RI' + ' ' + '-'  + ' ' + 'Account ' + 'Exec\''+')';
        
            //Query String modified with filter criteria - Bhavi Sharma - 10/08/2013 - CR-20130821-3487
            Query = 'Select Id, (Select Id, TeamMemberRole From AccountTeamMembers where (TeamMemberRole IN '+ atmRoleLIst+' or TeamMemberRole like \'%Marketer\')'
                                        + ' and lastModifiedDate = LAST_N_DAYS:3) From Account Where Id IN (Select AccountId FROM AccountTeamMember where'
                                        + ' (TeamMemberRole IN '+ atmRoleLIst+' or TeamMemberRole like \'%Marketer\' or TeamMemberRole like \'%Research & Insights RM\')' 
                                        + ' and lastModifiedDate = LAST_N_DAYS:1)';
        }
        
        return Database.getQueryLocator(query); 
        
    }

    global void execute(Database.BatchableContext BC, List<sObject> lstReturnedRcrds)
    {
        Util.IsBatch = true;
        List<AccountTeamMember> listAccountTeamMember = new List<AccountTeamMember>();
        List<Account> listUpdateAccounts = new List<Account>();
        List<Account> listAccounts = new List<Account>();
        
        //String variable to hold the error message string in case of any failure
        String logMessage = '';
        
        //map of all Accounts connected to these ATMs
        MAP<Id,Account> accountMap = new MAP<Id,Account>();
        
        //Accounts to check for Marketer changes
        set<Id> accstocheckids = new set<id>(); 
        set<id> AEUsers = new set<id>();
        
        //Collect Account IDs
        Set<ID> AccountIDSet = new Set<ID>();
        for (Account acc : (list<Account>)lstReturnedRcrds)
        {
            AccountIDSet.add(acc.Id);
        }
        
        //read all Accounts from Database
        accountMap  = new Map<Id, Account>([select Id,EA_AE__c,Name,
            (Select UserId, TeamMemberRole from AccountTeamMembers)
            from Account where Id in :AccountIDSet]);
        
        for (Account acc : accountMap.values())
        {
            acc.RM_RI__c = null;
            for (AccountTeamMember atm : acc.AccountTeamMembers)
            {
                // update RM if different
                if (atm.TeamMemberRole.contains('Research & Insights RM')) {
                    acc.RM_RI__c = atm.UserId;
                }
                
                //Update EA/AE if different
                if (((atm.TeamMemberRole == 'RI - Account Exec') 
                        || (atm.TeamMemberRole == 'RI - Executive Advisor')
                        || (atm.TeamMemberRole == 'AE or EA'))
                    && (acc.EA_AE__c != atm.UserId))
                {
                    acc.EA_AE__c =  atm.UserId;
                }
            
                if (atm.TeamMemberRole.contains('Marketer'))
                {
                    accstocheckids.add(acc.Id);
                }
            }
        }
        
        //Update any EA/AEs and RMs
        if(accountMap.values().size() > 0) {
        
            //Added By Abhinav Sharma - 04/19/2014 - CR-20140331-4909
            //Making a try to update the list of records and recording error messages will be wmailed to the SFAdmin 
            logMessage = Util.createLog(Database.update((accountMap.values()),false));
            
            //Checking errors log messages string for blank value and append it to final error message string only and only if it have proper value with it
            if(logMessage != '') 
                debugLogStr += logMessage; 
        }   
            
        //Calculate Assigned Marketer for Accounts with Marketer ATMs
        listAccounts = [select id, Name,EA_AE__c, EA_Contact__c,
            (select id,Name,Active_Contract_Idenfied__r.Contract_Renewal_Opportunity__r.OwnerId,
                Active_Contract_Idenfied__r.Contract_Renewal_Opportunity__c,Program__c,OwnerId,Active_Contract_Idenfied__c, 
                Program__r.New_Business_Marketer__c,Assigned_Marketer__c,Membership_Status__c 
                from Memberships__r),
            (select id, UserId, TeamMemberRole 
                from AccountTeamMembers 
                where TeamMemberRole like '%Marketer') 
            from Account where Id in :accstocheckids];   
        List<Membership__c> updateMembershipList = new List<Membership__c>();   
        List<Membership__c> updateProspectMembershipList = new List<Membership__c>();   
        map<Id, Membership__c> updatememsmap = new map<Id, Membership__c>();    
        
        //Accounts to update EA Contact
        accountmap = new Map<id,Account>();                             
            
        for(Account accountObj : listAccounts)
        {
            if(accountObj.Memberships__r.size() > 0)
            {
                List<Membership__c> tempMembershipList = accountObj.Memberships__r;
                
                for(Membership__c Membership: tempMembershipList){
                    //Membership.Assigned_Marketer__c update logic START 
                    if(accountObj.AccountTeamMembers.size() > 0)
                    {
                        List<AccountTeamMember> tempAccountTeamMemberList = accountObj.AccountTeamMembers;
                        for(AccountTeamMember ATMObj :tempAccountTeamMemberList)
                        {
                            
                            if((Membership.Program__r.New_Business_Marketer__c != null)
                                && (ATMObj.TeamMemberRole.contains(Membership.Program__r.New_Business_Marketer__c)))
                            {
                                Membership.Assigned_Marketer__c = ATMObj.UserId;//1
                                updatememsmap.put(Membership.Id, Membership);
                            }
                        }
                    }
                    //Membership.Assigned_Marketer__c update logic END
                    
                    //Membership Owner start
                    if((Membership.Membership_Status__c != null)
                        && (Membership.Membership_Status__c.contains('Prospect')))
                    {
                        if(null != Membership.Assigned_Marketer__c)
                        {
                            Membership.OwnerId = Membership.Assigned_Marketer__c; //2
                            updateProspectMembershipList.add(Membership);
                            updatememsmap.put(Membership.Id, Membership);
                        }
                            
                    } else {
                        if ((Membership.Active_Contract_Idenfied__c != null)
                            && (Membership.Active_Contract_Idenfied__r.Contract_Renewal_Opportunity__c != null))
                        {
                            Membership.OwnerId = Membership.Active_Contract_Idenfied__r.Contract_Renewal_Opportunity__r.OwnerId;
                            updatememsmap.put(Membership.Id, Membership);
                            updateProspectMembershipList.add(Membership);
                        }
                    }
                    //Membership Owner end
                }
            }
            if(accountObj.EA_AE__c != null)
            {
                AEUsers.add(accountObj.EA_AE__c);
                accountMap.put(accountObj.Id, accountObj);
            }
        }
        
        //Checking list for the size value
        if(updatememsmap.values().size() > 0) {
        
            //Added By Abhinav Sharma - 04/19/2014 - CR-20140331-4909
            //Making a try to update the list of records and recording error messages will be wmailed to the SFAdmin 
            logMessage = Util.createLog(Database.update((updatememsmap.values()),false));
            
            //Checking errors log messages string for blank value and append it to final error message string only and only if it have proper value with it
            if(logMessage != '') 
                debugLogStr += logMessage; 
        }
                
        //Update EA Contact
        if (accountMap.size() > 0)
        {
            listUpdateAccounts = new List<Account>();
            map<Id, Contact> empuserid2empconmap = new map<Id, Contact>();
            for (Contact ContactObj : [select Id, AccountId, Employee_User_Record__c 
                from Contact 
                where Employee_User_Record__c in :AEUsers ])
            {
                empuserid2empconmap.put(ContactObj.Employee_User_Record__c, ContactObj);
            }
                
            for (Account acc : accountMap.values())
            {
                if ((empuserid2empconmap.containsKey(acc.EA_AE__c))
                    && (acc.EA_Contact__c != empuserid2empconmap.get(acc.EA_AE__c).Id))
                {
                    acc.EA_Contact__c = empuserid2empconmap.get(acc.EA_AE__c).Id;
                    listUpdateAccounts.add(acc);
                }
            
            }
                
            //Code modified - Bhavi Sharma - 10/08/2013 - CR-20130821-3487
            //Allow partial update and Bypass all Triggers 
            if(listUpdateAccounts.size() > 0) {
                
                Util.bypassAllTriggers = true;
                
                //Added By Abhinav Sharma - 04/19/2014 - CR-20140331-4909
                //Making a try to update the list of records and recording error messages will be wmailed to the SFAdmin 
                logMessage = Util.createLog(Database.update((listUpdateAccounts),false));
                
                //Checking errors log messages string for blank value and append it to final error message string only and only if it have proper value with it
                if(logMessage != '') 
                    debugLogStr += logMessage; 
            
            }
 
        } //end if accountMap.size() > 0
        
       //Commented By - Abhinav Sharma - 04/19/2014 - CR-20140331-4909
       /*}
       catch(Exception exceptionObj)
       {
           debuglog += '<br/>Exception after ' + totalprocessed + ' records:<br/>' + exceptionObj.getMessage();
       }*/         
    }
    
    global void finish(Database.BatchableContext BC) {
        
        //Added By Abhinav Sharma - 04/19/2014 - Emailing recorded errors details to SFAdmin. - CR-20140331-4909
        //Checking logMessage  string for blank value but if it does not have blank value with it then emailed it to SFAdmin.
        if(debugLogStr != '') {
            
            //User Instance
            List<User> sfAdminUser = [Select Email FROM User WHERE Name = 'Salesforce Administrator' AND IsActive = true AND Profile.Name = 'System Administrator' AND Email!= null LIMIT 1];
            
            //Send log to admin
            if(sfAdminUser.size() > 0)
                Util.sendBatchStatus(BC.getJobId(), 'Batch_MonitorATMs', debugLogStr, sfAdminUser[0].Email);
        }
        
        //Added By Abhinav Sharma - 02/19/2014 - CR-20120208-412 - scheduled batch job automation
        //Schedules the next job if the "ExecuteNextJob" variable = true
        if(ExecuteNextJob) {

            //Build the system time of now + 20 Seconds to schedule the batch apex.
            Datetime sysTime = System.now();
            sysTime = sysTime.addSeconds(20);
            String chron_exp = '' + sysTime.second() + ' ' + sysTime.minute() + ' ' + sysTime.hour() + ' ' + sysTime.day() + ' ' + sysTime.month() + ' ? ' + sysTime.year();
        
            //Scheduler class
            Sched_PopulateRNIAMRestrictionsOnAccount controller = new Sched_PopulateRNIAMRestrictionsOnAccount();
            
            //Schedule the next job, and give it the system time so name is unique
            System.schedule('Sched_PopulateRNIAMRestrictionsOnAccount' + sysTime.getTime(),chron_exp,controller);
        }
        
        //Commented By - Abhinav Sharma - 04/19/2014 - CR-20140331-4909
        /*// Get the ID of the AsyncApexJob representing this batch job
        // from Database.BatchableContext.
        // Query the AsyncApexJob object to retrieve the current job's information.
    
        // Retrieve the current Job information
        AsyncApexJob a = [Select Id, Status, NumberOfErrors, JobItemsProcessed, TotalJobItems, CreatedBy.Email from AsyncApexJob where Id = :BC.getJobId()];
        
        String emailMessage = 
            'Your batch job \"Batch_MonitorATMs\" has finished.  It processed ' + totalprocessed + ' records in ' 
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
        mail.setSubject('Batch_MonitorATMs job completed');
        mail.setPlainTextBody(emailMessage);
        mail.setHtmlBody(emailMessage);
        
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });*/
        
    }
}