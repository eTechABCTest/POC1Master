/**
*   Purpose         :   This trigger is responsible for handling all the pre or post processing for
*                       any dml operation for WarmLeadMtM object 
*
*   Create By       :   Bhavi Sharma
*
*   Created Date    :   06/13/2013
*
*   Current Version :   v1.2
*
*   Revision Logs   :   v1.0 - Created - CR-20121130-1808
                        Modified error message
                        v1.2 - Modified By - Abhinav Sharma - 07/07/2014 - CR-20140618-5849 - Catch DML errors in triggers to reduce exception emails to SFAdmin
                        V_1.3 - Modified By - Abhinav Sharma - 11/24/2014 - CR-20141029-7923
						V_1.4 - Modified By - Abhinav Sharma - 08/24/2015 - CR-20140613-5790
**/
trigger Trigger_WarmLeadMtM on Warm_Lead_MtM__c (before insert, before update, after insert, after update, after delete) {
    
    try {
    
        //Bypassing trigger according to the flag value
        if (Util.BypassAllTriggers) 
            return;
        
        //Check for request type
        if(Trigger.isBefore) {
            
            //Check for event type
            if(Trigger.isInsert || Trigger.isUpdate) {
                
                //call helper class method
                WarmLeadMtMTriggerHelper.ValidateWarmLeadMtMData(Trigger.new);
                WarmLeadMtMTriggerHelper.populateFieldsOnWarmLeadMTMItself(Trigger.new);
            }
        }
        
        //Checking for the request type
        if(Trigger.isAfter) {
            
            //Checking for the event type
            if(Trigger.isInsert || Trigger.isUpdate || Trigger.isDelete) {
            
                //Calling helper class method
                WarmLeadMtMTriggerHelper.populateInitialVisitDateOnWarmLead(Trigger.new, Trigger.oldMap);
                
                //Added By - Abhinav Sharma - 08/24/2015 - CR-20140613-5790
                WarmLeadMtMTriggerHelper.populatePAsAndActivityFieldsOnWarmLead(Trigger.new, Trigger.oldMap);
            }
        }
    
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