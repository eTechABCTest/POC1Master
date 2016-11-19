/**
 * 	Purpose			:	This  trigger is to handle all the pre and post processing opreration
 * 
 * 	Created By		:	Bhavi Sharma
 * 
 * 	Created Date	:	08/04/2014
 * 
 * 	Revision Logs	:	V_1.0 - Created
 * 
 **/
trigger Trigger_IntranetContainer on Intranet_Container__c (before insert, before update) {
	
	//Check  for the request Type
	if(Trigger.isBefore) {
		
		//Check for the event type
		if(Trigger.isInsert || Trigger.isUpdate) {
			
			//Call Helper class method to adjust the Name of intranet container
			IntranetContainerTriggerHelper.validateDate(Trigger.New, Trigger.oldMap);
            
            //Update the Content Types Allowed Text field from the multi-select so it can be used in the lookup filter on Intranet Schedule
            IntranetContainerTriggerHelper.UpdateContentTypesAllowed(Trigger.New);
		}
        
        // Update
        if(Trigger.isUpdate) {
        	
            //Call help class method to update Trending data
			IntranetContainerTriggerHelper.updateTrendingData(Trigger.New, Trigger.oldMap);
        }
	}
}