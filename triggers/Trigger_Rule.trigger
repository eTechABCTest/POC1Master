/**
 *	Purpose			:	This trigger is to handle all the pre and post processing operation for Rule trigger
 *
 *	Created By		:	Bhavi Sharma
 *
 *	Created Date	:	02/10/2015
 *
 *	Revision Logs	:	V_1.0 - Created
 						V_1.2 - Modified - Bhavi Sharma - 03/05/15 - added method: validateRuleBeforeInsert
 *
 **/ 
trigger Trigger_Rule on Rule__c (before insert, before update, after insert, after update, after delete) {
    
    try {
        
        //Check if trigger is enabled
        if(!RuleTriggerHelper.EXECUTE_RULE_TRIGGER)
            return;
        
        //Chekc for the request type
        if(Trigger.isBefore) {
            
            //Check for the Event Typoe
            if(Trigger.isInsert) {
            	
        		//Call helper class method for validate rule before inserting
        		RuleTriggerHelper.validateRuleBeforeInsert(Trigger.New);
            }
            
            //Check for the Event Typoe
            if(Trigger.isInsert || Trigger.isUpdate) {
                
                //Call helper class method to validate the uniqueness of rule
                RuleTriggerHelper.validateRulesUniqueness(Trigger.New, Trigger.oldMap);
                
                //Call helper class method to check the Unique primary flag
                RuleTriggerHelper.validatePrimaryRule(Trigger.New);
            }
        } else if(Trigger.isAfter) {
        	
        	//Insert
        	if(Trigger.IsInsert) {
        		
        		//Create Events rules
        		RuleTriggerHelper.manageCloneRulesFromParent(Trigger.New);
        	}
        	
        	//Check for the Event Type
        	if(Trigger.isInsert || Trigger.isUpdate) {
        		
        		//Check if the Primary Program on Meeting
		    	RuleTriggerHelper.updateMeeting(Trigger.New, Trigger.oldMap);
            }
            
            //Check for the Event Type
        	if(Trigger.isDelete) {
        		
        		//Check if the Primary Program on Meeting
		    	RuleTriggerHelper.updateMeeting(Trigger.New, Trigger.oldMap);
            }
        }
	} catch(Exception e) {
        
        //Add Error Message on Page
        if(Trigger.isDelete)
            Trigger.Old[0].addError(e.getMessage());
        else
            Trigger.New[0].addError(e.getMessage());
    }
}