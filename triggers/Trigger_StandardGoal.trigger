/**
 *  Description     :   This trigger to handle all the pre and post processing operation for Standard Goal object
 *
 *  Created By      :   Padmesh Soni 
 *
 *  Created Date    :   8/11/2015
 *
 *  Revision Logs   :   V_1.0 - Created - Padmesh Soni - CR-20150729-9114
 *					  
 **/
trigger Trigger_StandardGoal on Standard_Goal__c (after update) {
	
	try {
		
		//Bypass flag
		if(Util.BypassAllTriggers) return;
		
		//Check for trigger context
		if(Trigger.isAfter) {
			
			//Check for trigger event
			if(Trigger.isUpdate) {
				
				//Call helper class method
				//This method uncheck all active field of Standard Goal detail object if Standard Goal object active fields is uncheck
				StandardGoalTriggerHelper.inactiveStdGoalDetails(Trigger.new, Trigger.oldMap);
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