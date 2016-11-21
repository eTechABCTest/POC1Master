/**
 *  Purpose         :   This trigger is to handle all the pre and post processing operations for SBQQ__QuoteLine__c object
 *
 *  Create By       :   Subhash Garhwal
 *
 *  Created Date    :   06/22/2016
 *
 *  Revision Logs   :   V_1.0 - Created - Subhash Garhwal - CR-20160414-9762
 *                      V_1.1 - Modified - Subhash Garhwal - 08/10/2016 - CR-20160414-9762 - Added a new call "validateQuoteYearOneDiscount"
 *                      V_1.2 - Modified - Subhash Garhwal - 08/19/2016 - CR-20160414-9762 - Added a new call "updateStandardPricing"
 **/
trigger SBQQ_QuoteLineTrigger on SBQQ__QuoteLine__c (before insert, before update, before delete,after insert, after update, after delete) {
    
    try {
        
        //Bypass flag
        if(Util.BypassAllTriggers) return;
        
        //Check for trigger context
        if(Trigger.isBefore) {
            
            //Check for event
            if(Trigger.isInsert || Trigger.isUpdate) {
                
                //Call helper class method
                SBQQ_QuoteLineTriggerHelper.updateStandardPricing(Trigger.new, Trigger.oldMap);
            }
        }
        //Check for trigger context
        if(Trigger.isAfter) {
            
            //Check for trigger event
            if(Trigger.isInsert || Trigger.isUpdate || Trigger.isDelete) {
                
                //Turn off DupeBlocker since it is not needed here to save some SOQL queries
                Util.disableDupeBlocker(true);
                
                //Call Helper class method to sync Quote Lines with Program Opportunities
                if(SBQQ_QuoteLineTriggerHelper.executeSyncProgramOpportunitiesLogic)
                    SBQQ_QuoteLineTriggerHelper.syncProgramOpportunities(Trigger.new, Trigger.oldMap);
                
                //Subhash Garhwal - 08/10/2016 - CR-20160414-9762
                //Call Helper class method to validate quote 1st year discount
                if(SBQQ_QuoteLineTriggerHelper.executeSyncProgramOpportunitiesLogic)
                    SBQQ_QuoteLineTriggerHelper.validateQuoteYearOneDiscount(Trigger.new, Trigger.oldMap);
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