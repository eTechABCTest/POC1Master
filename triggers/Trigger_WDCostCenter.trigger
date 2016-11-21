/**
 *  Description     :   Trigger is used to handle the duplicacy of same name records for Cost Center
 *
 *  Created By      :   Subhash Garhwal
 *
 *  Created Date    :   12/19/2015
 *
 *  Revision Logs   :	V_1.0 - Created - CR-20151123-9412    
 *                    
 **/
trigger Trigger_WDCostCenter on WD_Cost_Center__c(before insert, before update) {
    try {
        
        //Bypass flag
        if(Util.BypassAllTriggers) return;
        
        //Check for trigger context
        if(Trigger.isBefore) {
            
            //Check for trigger events
            if(Trigger.isInsert || Trigger.isUpdate) {
                
                //Call helper class method
                //This method is used to prevent duplicates.
                WDCostCenterTriggerHelper.preventDuplicates(Trigger.new, Trigger.oldMap);
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