/**
 *  Purpose         :   This  trigger is to handle all the pre and post processing opreration
 * 
 *  Created By      :   Bhavi Sharma
 * 
 *  Created Date    :   08/04/2014
 * 
 *  Revision Logs   :   V_1.0 - Created
 * 
 **/
trigger Trigger_IntranetSchedule on Intranet_Schedule__c (before insert, before update, after insert, after update) {
    
    try {
    	//Check  for the request Type
	    if(Trigger.isBefore) {
	        
	        //Check for the event type
	        if(Trigger.isInsert || Trigger.isUpdate) {
	            
	            //Call Helper class method to adjust the Name of intranet container
	            IntranetScheduleTriggerHelper.validateData(Trigger.New);
	        }
	    } else {
	        
	        //Check for event type
	        if(Trigger.isInsert || Trigger.isUpdate) {
	            
	            //Call helper method to update the Items Topics
	            IntranetScheduleTriggerHelper.createTopics(Trigger.New, Trigger.oldMap);
	        }
	    }
	} catch(DMLException e) {
        
    	//failed record
        String failureMessage = e.getDmlMessage(0);
       
        //Add Error Message on Page
        if(Trigger.isDelete)
        	Trigger.Old[0].addError(failureMessage);
        else
        	Trigger.New[0].addError(failureMessage);    
    } catch(Exception e) {
        
    	//Add Error Message on Page
        if(Trigger.isDelete)
            Trigger.Old[0].addError(e.getMessage());
        else
            Trigger.New[0].addError(e.getMessage());
    }
}