global class Batch_OpportunityEvaluationCounts {

    /*
    Purpose:    Called by Sched_OpportunityEvaluationCounts
    
                Update fields on Opportunity: 
                
                - Most_Recent_Activity__c
                - Number_of_Follow_Up_Activities__c
    
    Created By: Drew Freeman
    
    Last Modified By:   Drew Freeman - 1/4/2012
    
    Current Version:    v1.0  
                        v1.1 - Modify by - Abhinav Sharma - 02/19/2014 - CR-20120208-412 - scheduled batch job automation
                        v1.2 - Modify by - Abhinav Sharma - 04/19/2014 - CR-20140331-4909 - Updates to batch failure process 
    
    
    // Variable to store the query string used by the Query Locator
    public String queryStr = null;
    public Integer totalprocessed = 0;
    public Integer totalErrors = 0;
    public string debuglog = '';
    
    //Added By Abhinav Sharma - 02/19/2014 - CR-20120208-412 - scheduled batch job automation
    //Variable is set to true when the batch job is executed from the Scheduled job.
    global Boolean ExecuteNextJob = false;
    
    //Added By Abhinav Sharma - 04/19/2014 - CR-20140331-4909
    //String variable to hold the entire log message string value
    global String debugLogStr;
    
    global Batch_OpportunityEvaluationCounts () {
        debugLogStr = '';
    }

    // Start(Database.BatchableContext) method from the Database.Batchable class
    global Database.QueryLocator start(Database.BatchableContext BC) {

        if(queryStr == null) {
            String sDate = DateTime.newinstance(2012, 01, 01).format('yyyy-MM-dd') + 'T00:00:00Z';
            queryStr = 'select Id, Initial_Visit_Date__c, Most_Recent_Activity__c, Number_of_Follow_Up_Activities__c from Opportunity Where (CreatedDate >= ' +
                sDate + ' or LastModifiedDate >= ' + sDate + ') and (RecordType.DeveloperName=\'BI_Marketing\' or RecordType.DeveloperName=\'Core_Marketing\')';
        }

        System.debug('Executing Query: '+queryStr);
        return Database.getQueryLocator(queryStr);
    }
    
    // Execute(Database.BatchableContext, List<sObject>) method from the Database.Batchable class
    global void execute(Database.BatchableContext BC, List<sObject> scope) {

        // Flag the static variable in the Util class to show that a batch is running and therefore bypass triggers
        Util.IsBatch = true;

        list<Opportunity> oList = (list<Opportunity>)scope;

        Set<Id> oIDs = new Set<Id>();
        Map<Id, Date> oMap = new Map<Id, Date>();
        Map<Id, Integer> oCount = new Map<Id, Integer>();
        Map<Id, Date> oLatestActivity = new Map<Id, Date>();
        for (Opportunity o : oList) {
            oIDs.add(o.Id);
            oMap.put(o.Id, o.Initial_Visit_Date__c);
            oCount.put(o.Id, 0);
        }
    
        Date lDate;
        Date eDate;
        for (Event e : [select id, EndDateTime, WhatId, What.Type from Event where WhatId in :oIDs and Count__c = 1 and IsDeleted = false ALL ROWS]) {
            eDate = date.newinstance(e.EndDateTime.year(), e.EndDateTime.month(), e.EndDateTime.day());

            if (oMap.get(e.WhatId) < eDate) {
                oCount.put(e.WhatId,oCount.get(e.WhatId) + 1);
                totalprocessed++;
            }
            if (oLatestActivity.containsKey(e.WhatId)) {
                lDate = oLatestActivity.get(e.WhatId);
                if (lDate < eDate) {
                    oLatestActivity.put(e.WhatId, eDate);
                }
            } else {
                oLatestActivity.put(e.WhatId, eDate);
            }
        }
    
        for (Opportunity o : oList) {
            o.Most_Recent_Activity__c = null;
            if (oLatestActivity.containsKey(o.Id)) {
                o.Most_Recent_Activity__c = oLatestActivity.get(o.Id); 
            }
            o.Number_of_Follow_Up_Activities__c = oCount.get(o.Id);
        }
        
        //Modified By - Abhianv Sharma - 04/19/2014 - CR-20140331-4909
        //String variable to hold the error message string in case of any failure
        String logMessage = '';
        
        //Checking list for size value
        if(oList.size() > 0) {
        
            //Added By Abhinav Sharma - 04/19/2014 - CR-20140331-4909
            //Making a try to update the list of records and recording error messages will be wmailed to the SFAdmin 
            util.BypassAllTriggers = true;
            logMessage = Util.createLog(Database.update((oList),false));
            
            //Checking errors log messages string for blank value and append it to final error message string only and only if it have proper value with it
            if(logMessage != '') 
                debugLogStr += logMessage; 
        }   
        
    }

    global void finish(Database.BatchableContext BC) {
        
        //Added By Abhinav Sharma - 04/19/2014 - Emailing recorded errors details to SFAdmin. - CR-20140331-4909
        //Checking logMessage  string for blank value but if it does not have blank value with it then emailed it to SFAdmin.
        if(debugLogStr != '') {
            //Send log to admin
            //    if(sfAdminUser.size() > 0)
            Util.sendBatchStatus(BC.getJobId(), 'Batch_OpportunityEvaluationCounts', debugLogStr, Label.Salesforce_Admin_Email);
        }
        
        //Added By Abhinav Sharma - 02/19/2014 - CR-20120208-412 - scheduled batch job automation
        //Schedules the next job if the "ExecuteNextJob" variable = true
        if(ExecuteNextJob) {

            //Build the system time of now + 20 Seconds to schedule the batch apex.
            Datetime sysTime = System.now();
            sysTime = sysTime.addSeconds(20);
            String chron_exp = '' + sysTime.second() + ' ' + sysTime.minute() + ' ' + sysTime.hour() + ' ' + sysTime.day() + ' ' + sysTime.month() + ' ? ' + sysTime.year();
        
            //Scheduler class
            Sched_OAB_Lead_Passer controller = new Sched_OAB_Lead_Passer();
            
            //Schedule the next job, and give it the system time so name is unique
            System.schedule('Sched_OAB_Lead_Passer' + sysTime.getTime(),chron_exp,controller);
        }
    }*/
        
        
}