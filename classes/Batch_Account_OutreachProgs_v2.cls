global class Batch_Account_OutreachProgs_v2 implements Database.Batchable<SObject>, Database.Stateful
{
    /*
    Purpose:    Updates Programs available for outreach on Accounts.  Also updates field Today__c on Account w/ today's date.
                This batch is also part of a nightly scheduled job.
    
    Create By:  Nathan Banas (SAP) - 2/9/2011
    
    Last Modified By:   Nathan Banas (Synaptic) 4/21/11
    
    Current Version:    v1.3
    
    Revision Log:       v1.0 - (NB-2011-02-09) Created code.
                        v1.1 - (JN 3/22/11) Copied code into new Class file due to corrupt old Class
                        v1.2 - (NB 3/20/11) Updated API version from 19 to 20.  Added try/catch block around the Outreach Program
                                trim section.  Added null check to each Outreach Program condition prior to trim to ensure no
                                exceptions are being thrown.
                        v1.3 - (NB-2011-04-21) Modified test method to be remove the reliance on data being present within the system
                        v1.4 - Modify by - Abhinav Sharma - 02/19/2014 - CR-20120208-412 - scheduled batch job automation
                        v1.5 - Modify by - Abhinav Sharma - 04/19/2014 - CR-20140331-4909 - Updates to batch failure process
                        v1.6 - Modify by - Ajit Surana - 02/23/2015 - CR-20150122-8591 - Updated Finish() method
						v1.7 - Modify By - Abhinav Sharma - 07/16/2015 - CR-20150520-8962 - Update start method to include fields in query
    
    Code Coverage as of 2/9/2011: 99%
    Code Coverage as of 4/21/2011: 96% (Loss in coverage is due to the addition of the try/catch surrounding the trim section.)
    */
    
    public string Query = null;
    
    date TodaysDate = system.today();
    
    global string debuglog = '';
    Integer batchnum = 0;
    Integer totalprocessed = 0;
    public Integer totalErrors = 0;
    
    //Added By Abhinav Sharma - 02/19/2014 - CR-20120208-412 - scheduled batch job automation
    //Variable is set to true when the batch job is executed from the Scheduled job.
    global Boolean ExecuteNextJob = false;
    
    //Added By Abhinav Sharma - 04/19/2014 - CR-20140331-4909
    //String variable to hold the entire log message string value
    global String debugLogStr;
    
    global Batch_Account_OutreachProgs_v2 ()
    {
        debugLogStr = '';
    }
    
    global Database.queryLocator start(Database.BatchableContext ctx)
    {
        AsyncApexJob a = [SELECT id, ApexClassId, JobItemsProcessed, TotalJobItems, NumberOfErrors,  CreatedBy.Email 
                          FROM AsyncApexJob 
                          WHERE id = :ctx.getJobId()];
        System.debug('### Current Query: ' + Query);
        Util.BypassAllTriggers  = true;
        if(Query == null)
        {
            Query = 
            'SELECT Id, Name, Core_Memberships__c, Active_PT_Memberships__c, Active_RI_Memberships__c,  Active_TD_Memberships__c, Active_CM_Memberships__c, Active_SW_Memberships__c, BI_Memberships__c, Academies_Memberships__c, Hworks_Memberships__c, ' +
            'Core_Programs_Available_for_Outreach__c, Academy_Programs_Available_for_Outreach__c, BI_Programs_Available_for_Outreach__c, Active_CLN_Memberships__c ' +
            'FROM Account ORDER BY CreatedDate desc';
        }
        System.debug('### Executing Batch for Query: ' + Query);
        return Database.getQueryLocator(Query);
    }
    
    global void execute(Database.BatchableContext ctx, list<Sobject> scope)
    {
        Util.IsBatch = true;
        list<Account> recordList = (list<Account>)scope;
        
        //String variable to hold the error message string in case of any failure
        String logMessage = '';
        
        // get a map of all institutions
        Map<Id, Account> acctMap = new Map<Id, Account>();
        for (Account acct : recordList) acctMap.put(acct.Id, acct);
        
        List<String> progAcronymList = new List<String> { 'RI', 'PT', 'TD', 'CM', 'SW', 'CLN' };
        
        // get ALL memberships associated with those institutions
        List<Membership__c> membershipList = [SELECT id, Account_Name__c, Program__r.Business_Line__c, Prospect_Status__c, Membership_Status__c,
                                              Program__c, Program__r.Program_Acronym__c, Renewal_Unit_Count__c 
                                              FROM Membership__c 
                                              WHERE Account_Name__c IN :acctMap.keySet() AND Program__r.Business_line__c IN :progAcronymList];
        
        Map<Id, List<Membership__c>> acctToMembershipsMap = new Map<Id, List<Membership__c>>();
        
        for (Membership__c mem : membershipList) {
            List<Membership__c> tempMemList = acctToMembershipsMap.get(mem.Account_Name__c);
            if (tempMemList == null) tempMemList = new List<Membership__c>();
            tempMemList.add(mem);
            acctToMembershipsMap.put(mem.Account_Name__c, tempMemList);
        }
        
        for(Account a : acctMap.values())
        {
            // Set Today's Date on Account
            a.Today__c = TodaysDate;
            
            // Zero out the 4 kinds of Membership Counts on this Account & the 3 kinds of Membership Program Acronyms
            a.Core_Memberships__c = 0;
            a.BI_Memberships__c = 0;
            a.Academies_Memberships__c = 0;
            a.Hworks_Memberships__c = 0;
            a.Core_Programs_Available_for_Outreach__c = '';
            a.Academy_Programs_Available_for_Outreach__c = '';
            a.BI_Programs_Available_for_Outreach__c = '';
       
            // clear out active membership list
            a.Active_RI_Memberships__c = '';
            a.Active_PT_Memberships__c = '';
            a.Active_CM_Memberships__c = ''; // added lines 83-86 8/6/2012
            a.Active_SW_Memberships__c = '';
            a.Active_TD_Memberships__c = '';
            a.Active_CLN_Memberships__c = '';
            
            system.debug('### Processing Account: ' + a);
            system.debug('@@mems:' + acctToMembershipsMap.get(a.Id));
            a = MembershipTriggerHelper.process_membership(a, acctToMembershipsMap.get(a.Id));           
            
            System.debug('### Academy_Programs_Available_for_Outreach__c (untrimmed): ' + a.Academy_Programs_Available_for_Outreach__c);
            System.debug('### BI_Programs_Available_for_Outreach__c (untrimmed): ' + a.BI_Programs_Available_for_Outreach__c);
            System.debug('### Core_Programs_Available_for_Outreach__c (untrimmed): ' + a.Core_Programs_Available_for_Outreach__c);
            
            // Format the Programs Available for Outreach to remove blank spaces and ensure the max length is not exceeded then return the results to account
            try
            {
                if (a.Academy_Programs_Available_for_Outreach__c != null && a.Academy_Programs_Available_for_Outreach__c != '')
                    a.Academy_Programs_Available_for_Outreach__c = 
                        a.Academy_Programs_Available_for_Outreach__c.trim().substring(0,Math.min(255, a.Academy_Programs_Available_for_Outreach__c.trim().length()));
                if (a.BI_Programs_Available_for_Outreach__c != null && a.BI_Programs_Available_for_Outreach__c != '')
                    a.BI_Programs_Available_for_Outreach__c = 
                        a.BI_Programs_Available_for_Outreach__c.trim().substring(0,Math.min(255, a.BI_Programs_Available_for_Outreach__c.trim().length()));
                if (a.Core_Programs_Available_for_Outreach__c != null && a.Core_Programs_Available_for_Outreach__c != '')
                    a.Core_Programs_Available_for_Outreach__c = 
                        a.Core_Programs_Available_for_Outreach__c.trim().substring(0,Math.min(255, a.Core_Programs_Available_for_Outreach__c.trim().length()));
            }
            catch (exception ex)
            {
                debuglog += 'Trim Exception: ' + a.Name + ' (' + a.Id + ') - ' + ex.getMessage() + '\n';
                debugLogStr += 'Trim Exception: ' + a.Name + ' (' + a.Id + ') - ' + ex.getMessage() + '\n';
            }
            System.debug('### Academy_Programs_Available_for_Outreach__c (trimmed): ' + a.Academy_Programs_Available_for_Outreach__c);
            System.debug('### BI_Programs_Available_for_Outreach__c (trimmed): ' + a.BI_Programs_Available_for_Outreach__c);
            System.debug('### Core_Programs_Available_for_Outreach__c (trimmed): ' + a.Core_Programs_Available_for_Outreach__c);
            totalprocessed++;
        }
        
        //Checking list for size value
        if(recordList.size() > 0) {
        
            //Added By Abhinav Sharma - 04/18/2014 - CR-20140331-4909
            //Making a try to update the list of records and recording error messages will be wmailed to the SFAdmin 
            logMessage = Util.createLog(Database.update((recordList),false));
            
            //Checking errors log messages string for blank value and append it to final error message string only and only if it have proper value with it
            if(logMessage != '') 
                debugLogStr += logMessage; 
        }   
        
        /*if(recordList.size() > 0)
        {   
            Database.SaveResult[] lsr = Database.update(recordList,false);
            Integer recordid = 0;
            for (Database.SaveResult SR : lsr)
            {
                if (!SR.isSuccess())
                {
                    debuglog += 'Account Record (Error): ' + recordList[recordid].id + ', ' + SR.getErrors()[0].getMessage() + '<br/>';
                    totalErrors++;
                }
                recordid++;
            }
        }*/
    }
    
    global void finish(Database.BatchableContext ctx)
    {
        
        //Added By Abhinav Sharma - 04/19/2014 - Emailing recorded errors details to SFAdmin. - CR-20140331-4909
        //Checking logMessage  string for blank value but if it does not have blank value with it then emailed it to SFAdmin.
        if(debugLogStr != '') {
            
            //User Instance
            List<User> sfAdminUser = [Select Email FROM User WHERE Name = 'Salesforce Administrator' AND IsActive = true AND Profile.Name = 'System Administrator' AND Email!= null LIMIT 1];
            
            //Send log to admin
            if(sfAdminUser.size() > 0)
                Util.sendBatchStatus(ctx.getJobId(), 'Batch_Account_OutreachProgs_v2', debugLogStr, sfAdminUser[0].Email);
        }
        
        //Added By Abhinav Sharma - 02/19/2014 - CR-20120208-412 - scheduled batch job automation
        //Schedules the next job if the "ExecuteNextJob" variable = true
        if(ExecuteNextJob) {

            //Build the system time of now + 20 Seconds to schedule the batch apex.
            Datetime sysTime = System.now();
            
            //Added By - Ajit Surana - 02/23/2015 - CR-20150122-8591
            //Build the system time of now +60 Seconds to schedule the batch apex.
            Datetime sysTime2 = System.now();
            
            sysTime = sysTime.addSeconds(20);
            sysTime2 = sysTime.addSeconds(60);
            String chron_exp = '' + sysTime.second() + ' ' + sysTime.minute() + ' ' + sysTime.hour() + ' ' + sysTime.day() + ' ' + sysTime.month() + ' ? ' + sysTime.year();
            
            //Scheduler class
            Sched_UpdateAccTeamMemberSharingOppNBB controller = new Sched_UpdateAccTeamMemberSharingOppNBB();
            
            //Schedule the next job, and give it the system time so name is unique
            System.schedule('Sched_UpdateAccTeamMemberSharingOppNBB' + sysTime.getTime(),chron_exp,controller);
            
            //Added By - Ajit Surana - 02/23/2015 - CR-20150122-8591
            //Scheduler class
            String chron_exp2 = '' + sysTime2.second() + ' ' + sysTime2.minute() + ' ' + sysTime2.hour() + ' ' + sysTime2.day() + ' ' + sysTime2.month() + ' ? ' + sysTime2.year();
            Sched_DeleteWebServiceLogs controller2 = new Sched_DeleteWebServiceLogs();
            
            //Schedule the next job, and give it the system time so name is unique
            System.schedule('Sched_DeleteWebServiceLogs' + sysTime2.getTime(),chron_exp2,controller2);
        }
    }
}