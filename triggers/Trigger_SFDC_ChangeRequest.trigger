/*
    Purpose:    This trigger is responsible for handling all the pre or post processing for
                any dml operation for SFDC Chnage Request object  - CR-20120424-757
                
                Processes:
                Roll up Data from SFDC Change Request to SFDC Release   
                
                
    Create By:  Simplyforce Technology
    
    Created Date:   05/28/2012
    
    Current Version:    v1.0
    
    Revision Log:       V_1.1 Created
                        V_1.2 Ajit Surana - 04/18/2014 - CR-20140303-4690
                        V_1.3 Modified By - Abhinav Sharma - 07/07/2014 - CR-20140618-5849 - Catch DML errors in triggers to reduce exception emails to SFAdmin
*/
trigger Trigger_SFDC_ChangeRequest on SFDC_Change_Request__c (after insert, after update, after delete, after undelete) {
    
    try {
        //Check for the request type
        if(Trigger.isAfter) {
            
            //Added by Ajit Surana - 04/18/2014 - CR-20140303-4690
            //Check for the event type
            if(Trigger.isInsert || Trigger.isUpdate || Trigger.isDelete) {
                
                //Call helper class method here to roll up data on SFDC Release
                SFDCChangeRequestTriggerHelper.rollUpStorySizeDataOnSFDCRelease(Trigger.New, Trigger.oldMap);
            
            }
            
            //Check for the event type
            if(Trigger.isInsert || Trigger.isUpdate || Trigger.isUnDelete) {
                
                //Call helper class method here to roll up data on SFDC Release
                SFDCChangeRequestTriggerHelper.checkIfRollupUpdateNeeded(Trigger.New);
                
            } else if (Trigger.isDelete) {
            
                //Call helper class method here to roll up data on SFDC Release
                SFDCChangeRequestTriggerHelper.checkIfRollupUpdateNeeded(Trigger.Old);
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