/**
*   Purpose         :   This Tirgger is used for update Project object fields which are have 
*                       lookup relationship with Deployment object with Deployment object fields.
*
*   Created By      :   Bhavi Sharma
* 
*   Created Date    :   05/25/2013
* 
*   Current Version :   v1.0 - Created  -   CR-20130328-2773
*                       v1.1 - Modified - CR-20130829-3543 - CMA - Elapsed Time Field - Moved to Prod Team - (Abhinav Sharma - 03-03-2014)
*                       v1.2 - Modified - Abhinav Sharma - 05/01/2014 - CR-20140408-5000
*                       v1.3 - Modified By - Abhinav Sharma - 07/07/2014 - CR-20140618-5849 - Catch DML errors in triggers to reduce exception emails to SFAdmin
*                       v1.4 - Modified By - Abhinav Sharma - 10/17/2014 - CR-20140826-7138
*                       v1.5 - Modified BY - Abhinav Sharma - 02/03/2015 - CR-20141218-8365 - CPRM Deployment Milestone Updates
**/
trigger Trigger_Deployment on Deployment__c (before insert, before update, after insert, after update, after delete) {

    try {
        //Check for requests
        if (Trigger.isBefore) {
            
            // check for event
            if (Trigger.isInsert || Trigger.isUpdate) {
                DeploymentTriggerHelper.updateDeploymentStatus(Trigger.new);
                
                //Added By - Abhinav Sharma - 02/03/2015 - CR-20141218-8365 - CPRM Deployment Milestone Updates
                DeploymentTriggerHelper.updateCalculatedDateFields(Trigger.new);
            }
        }
        if(Trigger.isAfter) {
            
            //Check for event
            if(Trigger.isInsert || Trigger.isUpdate) {
                
                //Rollup field of Project through Deployment object fields
                DeploymentTriggerHelper.rollupDeploymentDataOnProject(Trigger.new, Trigger.oldMap);
            }
            
            //Check for event
            if(Trigger.isInsert || Trigger.isUpdate || Trigger.isDelete) {
            
                //Added By - Abhinav Sharma - 03-03-2014 - CR-20130829-3543 - CMA - Elapsed Time Field - Moved to Prod Team 
                //Set First_Deployment_Signed_Off__c field on the Project with the earliest value from the "Deployment Sign Off (Actual)" field on the associated Deployment records 
                DeploymentTriggerHelper.populateFirstDeploymentSignedOff(Trigger.new, Trigger.oldMap);
                
                //Added By - Abhinav Sharma - 05/01/2014 - CR-20140408-5000
                //Call helper class method here to roll up data on Project record
                DeploymentTriggerHelper.populateDeploymentDataOnProject(Trigger.new, Trigger.oldMap); 
                
                //Added By - Abhinav Sharma - 10/17/2014 - CR-20140826-7138
                //Call helper class method here to find Oldest Deployment Sign Off on Project record
                DeploymentTriggerHelper.populateDeploymentSignOffOldestOnProject(Trigger.new, Trigger.oldMap);
            }
        }
    //Catching DML Exceptions
    } catch(DMLException e) {

        //Add Error Message on Page
        if(Trigger.isDelete)
            Trigger.Old[0].addError(e.getDmlMessage(0));
        else
            Trigger.New[0].addError(e.getDmlMessage(0));

    //Catching all Exceptions
    } catch(Exception e) {

        //Add Error Message on Page
        if(Trigger.isDelete)
            Trigger.Old[0].addError(e.getMessage());
        else
            Trigger.New[0].addError(e.getMessage());
    }
}