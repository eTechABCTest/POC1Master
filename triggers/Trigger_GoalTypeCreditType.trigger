/**
 *  Description     :   Trigger is used to handle all the pre and post processing operation for Goal Type Credit Type
 *
 *  Created By      :   Subhash Garhwal
 *
 *  Created Date    :   12/02/2015
 *
 *  Revision Logs   :   V_1.0 - Created - CR-20150825-9114 
 *                    
 **/
trigger Trigger_GoalTypeCreditType on Goal_Type_Credit_Type__c (before insert, before update) {
    try {
        
        //Bypass flag
        if(Util.BypassAllTriggers) return;
        
        //Check for trigger context
        if(Trigger.isBefore) {
            
            //Check for trigger events
            if(Trigger.isInsert || Trigger.isUpdate) {
                
                //Call helper class method
                //This method is used to prevent duplicates.
                GoalTypeCreditTypeTriggerHelper.preventDuplicates(Trigger.new, Trigger.oldMap);
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