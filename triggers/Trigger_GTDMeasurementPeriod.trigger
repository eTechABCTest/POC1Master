/**
 *  Description     :   Trigger is used to handle all the pre and post processing operation for Goal Template Detail Measurement Date
 *
 *  Created By      :   Subhash Garhwal
 *
 *  Created Date    :   11/25/2015
 *
 *  Revision Logs   :   V_1.0 - Created - CR-20151120-9407 
 *                    
 **/
trigger Trigger_GTDMeasurementPeriod on Goal_Template_Detail_Measurement_Period__c (before insert, before update) {
    try {
        
        //Bypass flag
        if(Util.BypassAllTriggers) return;
        
        //Check for trigger context
        if(Trigger.isBefore) {
            
            //Check for trigger events
            if(Trigger.isInsert || Trigger.isUpdate) {
                
                //Call helper class method
                //This method is used to prevent duplicates.
                GTDMeasurementPeriodTriggerHelper.preventDuplicates(Trigger.new, Trigger.oldMap);
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