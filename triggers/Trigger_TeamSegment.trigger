/**
 * 	Purpose			:	This trigger is to handle all teh pre and post processing operation
 * 
 * 	Created By		:	Bhavi Sharma
 * 
 * 	Created Date	:	03/31/2015
 * 
 * 	Revision Logs	:	V_1.0 - Created
 *
 **/ 
trigger Trigger_TeamSegment on Team_Segment__c (before insert, before update) {
	
	try {
        
        //Check for the request type 
        if(Trigger.isBefore) {
            
            //Check for the Event Type
            if(Trigger.isInsert || Trigger.isUpdate) {
                
                //Call helper class method
                TeamSegmentTriggerHelper.validateTeamSegments(Trigger.New);
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