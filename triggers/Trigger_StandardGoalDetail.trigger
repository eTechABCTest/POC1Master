/**
 *  Description     :   This trigger to handle all the pre and post processing operation for Standard Goal Detail
 *
 *  Created By      :   Subhash Garhwal
 *
 *  Created Date    :   08/25/2015
 *
 *  Revision Logs   :   V_1.0 - Created - Subhash Garhwal - CR-20150729-9114
 *                      V_1.1 - Modified - Rajeev Jan - 05/11/2016 - CR-20160307-9680 - Added Before Event
 *                  
 **/
trigger Trigger_StandardGoalDetail on Standard_Goal_Detail__c (before insert, before update, after update) {
    
    try {
        
        //Bypass flag
        if(Util.BypassAllTriggers) return;
        
        //V_1.1 - Modified - Rajeev Jan - CR-20160307-9680 
        //Handle Before Trigger
        if(Trigger.isBefore){
            
            if(Trigger.isInsert || Trigger.isUpdate)
                StandardGoalDetailTriggerHelper.rePopulateValueTypeBasedValues(Trigger.new, Trigger.oldMap);    
        }
        //V_1.1 - Modified - Rajeev Jan - CR-20160307-9680 - upto here
        
        //Check for trigger context
        if(Trigger.isAfter) {
            
            //Check for trigger event
            if(Trigger.isUpdate) {
                
                //Call the helper class method
                //This method is used to validate the Period Start and End date
                if(StandardGoalDetailTriggerHelper.isExecutePeriodsLogic)
                    StandardGoalDetailTriggerHelper.validatePeriods(Trigger.new, Trigger.oldMap);
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