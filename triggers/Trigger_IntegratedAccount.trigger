/**
 *  Purpose         :   This trigger is to handle all the pre and post processing operations for Integrated_Account__c object
 *
 *  Create By       :   Colin
 *
 *  Created Date    :   06/24/2016
 *
 *  Revision Logs   :   V_1.0 - Created - Colin - CR-20160414-9762
 *						V_1.1 - Modified - 08/17/2016 - Subhash Garhwal - CR-20160414-9762 - Added a new call preventIntegratedAccountDeletion
 * 
 *						
 **/
trigger Trigger_IntegratedAccount on Integrated_Account__c (before insert, before update, before delete) {
    
    try {
        
        //Check trigger context
        if (Trigger.isBefore) {
            
            //Check for the request type
            if(Trigger.isInsert){
                
                //Prevents the user from creating an Integrated Account record if there is a Proposal in "In Review" or "Approved Status" associated with the Contract LOA Opp
                IntegratedTriggerHelper.preventIntegratedAccountDeletionCreation(Trigger.New);
                
            }
            
            //Check for the request type
            if(Trigger.isUpdate){
                
                //Prevents the user from modifying the Integrated Account record if it has a CIA record which references it
                IntegratedTriggerHelper.preventEditOfIntegratedAccount (Trigger.New, Trigger.OldMap);
                
            }
            
            //Check for request type
            if (Trigger.isDelete) {
                
                //Call Helper class method
                IntegratedTriggerHelper.preventDeleteOfIntegratedAccount (Trigger.Old);
                
                //Added - 08/17/2016 - Subhash Garhwal - CR-20160414-9762
                //Call helper class method to validate integrated account
                IntegratedTriggerHelper.preventIntegratedAccountDeletionCreation(Trigger.old);
            }  
        }   
    }
    
    catch(DMLException e) {
        
        //Add Error Message on Page
        if(Trigger.isDelete)
            Trigger.Old[0].addError(e.getDmlMessage(0) + e.getStackTraceString());
        else
            Trigger.New[0].addError(e.getDmlMessage(0) + e.getStackTraceString());
        
        //Catching all Exceptions
    } catch(Exception e) {
        
        //Add Error Message on Page
        if(Trigger.isDelete)
            Trigger.Old[0].addError(e.getMessage() + e.getStackTraceString());
        else
            Trigger.New[0].addError(e.getMessage() + e.getStackTraceString());
    }
    
}