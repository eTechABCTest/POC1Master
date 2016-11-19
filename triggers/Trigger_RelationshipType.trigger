/**
 *  Description     :   Trigger is used to handle all the pre and post processing operation for Relationship Type.
 *
 *  Created By      :   Subhash Garhwal 
 *
 *  Created Date    :   9/29/2015
 *
 *  Revision Logs   :   V_1.0 - Created - CR-20150825-9182
 *                    
 **/
trigger Trigger_RelationshipType on Relationship_Type__c (after update) {
	
	try{
        
        //Bypass flag
        if (Util.BypassAllTriggers) return; 
        
		//Check for trigger context
	    if(Trigger.isAfter) {
	    	
	    	//Check for event
	    	if(Trigger.isUpdate){
	    		
	    		//Call Method
	    		//This method is used to update the child staff relationship and My relationship records
	    		RelationshipTypeTriggerHelper.cascadeChanges(Trigger.new, Trigger.oldMap);
	    	}
	    }
	//Catching DML Exceptions
	}catch(DMLException e) {

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