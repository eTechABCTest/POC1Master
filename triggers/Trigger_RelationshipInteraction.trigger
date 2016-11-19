/**
    Purpose         :   This trigger to handle all the processing for Relationship Interaction object.
                
    Create By       :   Abhinav Sharma
    
    Created Date    :   10/20/2015
    
    Revision Logs   :   V_1.0 - Created
**/
trigger Trigger_RelationshipInteraction on Relationship_Interaction__c (after insert, after update, after delete) {
	
    try {
    	
        //Bypassing trigger if flag value equals to true
        if (Util.BypassAllTriggers) return;
        
        //Checking for the event type
    	if(trigger.isAfter) {
        	
            //Checking for the request type
            if(Trigger.isInsert || Trigger.isUpdate || Trigger.isDelete) {
            	
                //Calling helper class method
                RelationshipInteractionTriggerHelper.populateNameOnReleationshipInteractions(trigger.new, trigger.oldMap);
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