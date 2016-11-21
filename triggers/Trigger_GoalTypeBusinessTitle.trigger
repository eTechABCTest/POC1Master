/**
 *  Description     :   This trigger to handle all the pre processing operation for Goal Type Business Title
 *
 *  Created By      :   Subhash Garhwal
 *
 *  Created Date    :   09/09/2015
 *
 *  Revision Logs   :   V_1.0 - Created - CR-20150729-9114
 *						
 **/
trigger Trigger_GoalTypeBusinessTitle on Goal_Type_Business_Title__c (before insert, before update) {

	 try {
    
        //Bypass flag
        if (Util.BypassAllTriggers) return;
        
        //Check for trigger context
        if(Trigger.isBefore) {
            
            //Check for trigger event
            if(Trigger.isInsert || Trigger.isUpdate) {
            	
            	//Call helper class method
            	//This methiod is to validate the data before inserting into database. If there is any Duplicate, display error message to user.
            	GoalTypeBusinessTitleTriggerHelper.validateGTBTs(Trigger.new, Trigger.oldMap);
            }
        }
     }    
	//Catching DML Exceptions
    catch(DMLException e) {

        //Add Error Message on Page
        if(Trigger.isDelete)
            Trigger.Old[0].addError(e.getDmlMessage(0));
        else
            Trigger.New[0].addError(e.getDmlMessage(0));
    }

	//Catching all Exceptions
	catch(Exception e) {

		//Add Error Message on Page
		if(Trigger.isDelete)
            Trigger.Old[0].addError(e.getMessage());
        else
            Trigger.New[0].addError(e.getMessage());
    }
}