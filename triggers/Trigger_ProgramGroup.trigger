/**
 *  Description     :   This trigger to handle all the pre and post processing operation for Program Group
 *
 *  Created By      :   Subhash Garhwal
 *
 *  Created Date    :   06/24/2015
 *
 *  Revision Logs   :   V_1.0 - Created - Subhash Garhwal - CR-20150618-9014
 *                      V_1.1 - Added - Subhash Garhwal - CR-20150729-9114 - 08/04/2015 -  New method incentiveChangeLog called.
 *                      V_1.2 - Modified - Rajeev Jain - CR-20151120-9402 - 04/19/2016 - Removed usage of incentiveChangeLog
 *                  
 **/
trigger Trigger_ProgramGroup on Program_Group__c (after update, before delete, before insert, after insert, before update, after delete) {
    
    try {
        
        //Bypass flag
        if(Util.BypassAllTriggers) return;
        
        //Check for trigger context
        if(Trigger.isBefore) {
            
            //Check for trigger event
            if(Trigger.isInsert || Trigger.isUpdate) {
                
                //Call helper class method
                //This method is used to check Program Group name. The Name value must be unique across all Program Groups
                ProgramGroupTriggerHelper.validateProgramGroup(Trigger.new, Trigger.oldMap);
            }
            
            //Check for trigger event
            if(Trigger.isDelete) {
                
                //Call helper class method
                //Method to check related Program Perspective's In Use values on record delation, If "In Use" values > 0, then throw error.
                ProgramGroupTriggerHelper.validateBeforeDelete(Trigger.old);
                
                //Call helper class method
                //Method to notify related Perspective's owner, when update occurs to the following fields:
                //Name, Effective_Start__c, Effective_End__c or Active__c
                ProgramGroupTriggerHelper.keyInformationChangedNotification(Trigger.new, Trigger.oldMap);
                
                //Call helper class method
                //This method is to summarize RPPs on SA
                ProgramGroupTriggerHelper.SummarizeRPPs(Trigger.old);
            }
        }
        
        //Check for trigger context
        if(Trigger.isAfter) {
            
            //Check for trigger event
            if(Trigger.isUpdate) {
                
                //Call helper class method
                //Method to notify related Perspective's owner, when update occurs to the following fields:
                //Name, Effective_Start__c, Effective_End__c or Active__c
                ProgramGroupTriggerHelper.KeyInformationChangedNotification(Trigger.new, Trigger.oldMap);
                
                //Call helper class method
                //This method is to summarize RPPs on SA
                ProgramGroupTriggerHelper.SummarizeRPPs(Trigger.new, Trigger.oldMap);
                
                //Code Added - Subhash Garhwal - CR-20150729-9114 - 08/04/2015 -  New method incentiveChangeLog called.
                //Call helper class method 
                //This method is to incentiveChangeLog 
                //ProgramGroupTriggerHelper.incentiveChangeLog(Trigger.new, Trigger.oldMap);
            }
           
            //Check for trigger event
            if(Trigger.isDelete) {
                
                //Call helper class method
                //This method is to summarize RPPs on SA
                ProgramGroupTriggerHelper.SummarizeRPPs();
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