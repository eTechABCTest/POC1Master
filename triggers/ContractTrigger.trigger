/**
 *  Purpose         :   This trigger is to handle all the pre and post processing operations for Contract object
 *
 *  Create By       :   Subhash Garhwal
 *
 *  Created Date    :   07/01/2016
 *
 *  Revision Logs   :   V_1.0 - Created - Subhash Garhwal - CR-20160414-9762
 **/
trigger ContractTrigger on Contract (after insert, before delete) {
	
	try {
		
		//Bypass flag
        if(Util.BypassAllTriggers) return;
        
        //Check for trigger context
        if(Trigger.isBefore) {
        	
        	//Check for trigger event
        	if(Trigger.isDelete) {
        		
        		//Call Helper class method to delete related contract integrated accounts
        		ContractTriggerHelper.syncContractIntegratedAccounts(Trigger.new, Trigger.oldMap);
        	}
        }
        
        //Check for trigger context
        if(Trigger.isAfter) {
        	
        	//Check for trigger event
        	if(Trigger.isInsert) {
        		
        		//Call Helper class method to create related contract integrated accounts
        		ContractTriggerHelper.syncContractIntegratedAccounts(Trigger.new, Trigger.oldMap);
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