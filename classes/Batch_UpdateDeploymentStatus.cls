/**
 *  Purpose         :   This Batch is update the Deployment__c object's field CPM_Deployment_Status__c with CMA_Status_Formula__c field if 
 *                      both are not equals.
 *
 *  Created By      :   Bhavi Sharma
 *
 *  Created Date    :   05/14/2013
 *
 *  Revision Logs   :   V_1.0 - Created
 *                      V_1.2 - Modified - 9/3/13 - VH - CR-3154 - added references to CompassConnectRTId so those records are updated nightly
 *                      v_1.2 - Modify by - Abhinav Sharma - 02/19/2014 - CR-20120208-412 - scheduled batch job automation
 *                      v_1.3 - Modify by - Abhinav Sharma - 04/19/2014 - CR-20140331-4909 - Updates to batch failure process
 *
 **/ 
global class Batch_UpdateDeploymentStatus  implements Database.Batchable<SObject>, Database.Stateful {
    
    public String DebugLog = '';
    public Integer TotalErrors = 0;
    
    //Added By Abhinav Sharma - 02/19/2014 - CR-20120208-412 - scheduled batch job automation
    //Variable is set to true when the batch job is executed from the Scheduled job.
    global Boolean ExecuteNextJob = false;
    
    //Added By Abhinav Sharma - 04/19/2014 - CR-20140331-4909
    //String variable to hold the entire log message string value
    global String debugLogStr;
    
    public Id CompassConnectRTId {
        get {
            if (CompassConnectRTId == null) {
                CompassConnectRTId = util.RecordTypeId('Deployment__c', Constants.RECORD_TYPE_DEPLOYMENT_COMPASS_CONNECT_DEPLOYMENT);
            }
            return CompassConnectRTId;
        }
        set;
    }
    
    public Id CMADeploymentRTId {
        get {
            if (CMADeploymentRTId == null) {
                CMADeploymentRTId = util.RecordTypeId('Deployment__c', Constants.RECORD_TYPE_DEPLOYMENT_CMA_DEPLOYMENT);
            }
            return CMADeploymentRTId;
        }
        set;
    }
    
    //Added By - Abhinav Sharma - 04/19/2014 - CR-20140331-4909
    global Batch_UpdateDeploymentStatus () {
        debugLogStr = '';
    }
    
    //start Method
    global Database.Querylocator start(Database.BatchableContext BC)  {
        
        //return query result
        return Database.getQueryLocator([SELECT Id, RecordTypeId, CPM_Deployment_Status__c, CMA_Status_Formula__c FROM Deployment__c 
                                            WHERE CMA_Status_Formula__c != null OR RecordTypeId = :CompassConnectRTId]);
    }

    //Execute method
    global void execute(Database.BatchableContext BC, List<SObject> scope) {
    
        //String variable to hold the error message string in case of any failure
        String logMessage = '';
       
        //List to hold Deployment__c records to be updated
        List<Deployment__c> deploymentRecords = new List<Deployment__c>();
    
        //Loop through scope and check if the CPM_Deployment_Status__c not equals to CMA_Status_Formula__c
        for(Deployment__c deployment : (List<Deployment__c>)scope) {
            
            // Only process if this is a CMA Deployment Record Type
            if (deployment.RecordTypeId == CMADeploymentRTId) {
                
                //Check criteria
                if(deployment.CPM_Deployment_Status__c != deployment.CMA_Status_Formula__c)  {
                    
                    //assignment of field value
                    deployment.CPM_Deployment_Status__c = deployment.CMA_Status_Formula__c;
                    
                    //add in the List
                    deploymentRecords.add(deployment);
                }
            }
            else if (deployment.RecordTypeId == CompassConnectRTId) {
                //add to the list
                deploymentRecords.add(deployment);
            }
        }   
                     
        //Check list of Deployment record for update
        if(deploymentRecords.size() > 0)  {
               
            //Added By Abhinav Sharma - 04/19/2014 - CR-20140331-4909
            //Making a try to update the list of records and recording error messages will be wmailed to the SFAdmin 
            logMessage = Util.createLog(Database.update((deploymentRecords),false));
            
            //Checking errors log messages string for blank value and append it to final error message string only and only if it have proper value with it
            if(logMessage != '') 
                debugLogStr += logMessage; 
            
            //Commented By - Abhinav Sharma - 04/19/2014 - CR-20140331-4909
            /*List<Database.SaveResult> dsr = database.update(deploymentRecords, false);
            
            integer recordnum = 0;
            for (Database.SaveResult SR : dsr)
            {
                if (!SR.isSuccess())
                {
                    debuglog += 'Deployment Record, Error: ' + deploymentRecords[recordnum].id + ', ' + SR.getErrors()[0].getMessage() + '<br/>';
                    TotalErrors++;
                }
                recordnum++;
            }*/
        }
    }
    
    //finish method
    global void finish(Database.BatchableContext BC) {
        
        //Added By Abhinav Sharma - 04/19/2014 - Emailing recorded errors details to SFAdmin. - CR-20140331-4909
        //Checking logMessage  string for blank value but if it does not have blank value with it then emailed it to SFAdmin.
        if(debugLogStr != '') {
            
            //User Instance
            //Refactored By Doug Roberts - 08/31/2015 - Remove query for SF user email and change to custom label
            //List<User> sfAdminUser = [Select Email FROM User WHERE Name = 'Salesforce Administrator' AND IsActive = true AND Profile.Name = 'System Administrator' AND Email!= null LIMIT 1];
            
            //Send log to admin
            //if(sfAdminUser.size() > 0)
                Util.sendBatchStatus(BC.getJobId(), 'Batch_UpdateDeploymentStatus', debugLogStr,Label.Salesforce_Admin_Email);
        }
        
        //Added By Abhinav Sharma - 02/19/2014 - CR-20120208-412 - scheduled batch job automation
        //Schedules the next job if the "ExecuteNextJob" variable = true
        if(ExecuteNextJob) {

            //Build the system time of now + 20 Seconds to schedule the batch apex.
            Datetime sysTime = System.now();
            sysTime = sysTime.addSeconds(20);
            String chron_exp = '' + sysTime.second() + ' ' + sysTime.minute() + ' ' + sysTime.hour() + ' ' + sysTime.day() + ' ' + sysTime.month() + ' ? ' + sysTime.year();
        
            //Scheduler class
            Sched_CheckRestrictionExpiration controller = new Sched_CheckRestrictionExpiration();
            
            //Schedule the next job, and give it the system time so name is unique
            System.schedule('Sched_CheckRestrictionExpiration' + sysTime.getTime(),chron_exp,controller);
        }
    }
}