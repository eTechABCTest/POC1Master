/**
 *  Purpose         :   This trigger is to handle all the pre and post processing operations for SBQQ__Quote__c object
 *
 *  Create By       :   Subhash Garhwal
 *
 *  Created Date    :   06/23/2016
 *
 *  Revision Logs   :   V_1.0 - Created - Subhash Garhwal - CR-20160414-9762
 **/
trigger SBQQ_QuoteTrigger on SBQQ__Quote__c (after insert, after update, before delete, after delete) {
    
    try {
        
        //Bypass flag
        if(Util.BypassAllTriggers) return;
        
        //Check for trigger context
        if(Trigger.isBefore) {
            
            //Check for trigger event
            if(Trigger.isDelete) {
                
                //Call helper class method
                SBQQ_QuoteTriggerHelper.populateSetProgramOpportunitiesId(Trigger.old); 
            }
        }
        
        //Check for trigger context
        if(Trigger.isAfter) {
            
            //Check for trigger event
            if(Trigger.isInsert) {
                
                //Call helper class method to update contract LOA stage to piepline
                if(SBQQ_QuoteTriggerHelper.executeUpdateContractLOAStageLogic)
                    SBQQ_QuoteTriggerHelper.updateContractLOAStage(Trigger.new);    
            }
            
            //Check for trigger event
            if(Trigger.isUpdate) {
                
                //Call Helper class method to sync Quote Lines with Program Opportunities
                SBQQ_QuoteTriggerHelper.syncProgramOpportunities(Trigger.new, Trigger.oldMap);
            }
            
            //Check for trigger event
            if(Trigger.isDelete) {
                
                //Call helper class method
                SBQQ_QuoteTriggerHelper.validateProgramOpportunities(); 
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