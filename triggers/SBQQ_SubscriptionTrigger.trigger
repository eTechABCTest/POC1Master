/**
 *  Purpose         :   This trigger is to handle all the pre and post processing operations for SBQQ__Subscription__c object
 *
 *  Create By       :   Subhash Garhwal
 *
 *  Created Date    :   06/30/2016
 *
 *  Revision Logs   :   V_1.0 - Created - Subhash Garhwal - CR-20160414-9762
 *                      V_1.1 - Modified - 8/01/2016 - Subhash Garhwal - CR-20160414-9762 - Call helper class method "validateProgramOpportunities"
 **/

trigger SBQQ_SubscriptionTrigger on SBQQ__Subscription__c (after insert, after update, after delete) {
    
    try {
        
        //Bypass flag
        if(Util.BypassAllTriggers) return;
        
        //Check for trigger context
        if(Trigger.isAfter) {
            
            //Check for trigger event
            if(Trigger.isInsert) {
                
                //Call Helper class method to sync Quote Lines with Program Opportunities
                SBQQ_SubscriptionTriggerHelper.syncProgramOppsWithSubscriptions(Trigger.newMap.keySet());
            }
            
            //Check for trigger event
            if(Trigger.isUpdate || Trigger.isDelete) {
                
                //Added - 8/01/2016 - Subhash Garhwal - CR-20160414-9762
                //Call helper class method to validate Opportunity Amount
                SBQQ_SubscriptionTriggerHelper.validateProgramOpportunities(Trigger.new, Trigger.oldMap);
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