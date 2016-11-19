/**
 *  Description     :   This trigger to handle all the pre and post processing operation for Standard Goal Detail Pacing
 *
 *  Created By      :   Subhash Garhwal
 *
 *  Created Date    :   08/12/2015
 *
 *  Revision Logs   :   V_1.0 - Created - Subhash Garhwal - CR-20150729-9114
 *                  
 **/
trigger Trigger_StandardGoalDetailPacing on Standard_Goal_Detail_Pacing__c (before insert, before update, after insert, after update, after delete) {
	
	try {
        
        //Bypass flag
        if(Util.BypassAllTriggers) return;
        
        //Check for trigger context
        if(Trigger.isBefore) {
            
            //Check for trigger event
            if(Trigger.isInsert || Trigger.isUpdate) {
                
                //Call helper class method
                //This method is used to validate Standard Goal Detail Pacing
                StandardGoalDetailPacingTriggerHelper.validateStandardGDPacing(Trigger.new, Trigger.oldMap);
            }
		}
		
		//Check for trigger context
		if(Trigger.isAfter) {
			
			//Check for trigger event
			if(Trigger.isInsert || Trigger.isUpdate || Trigger.isDelete) {
				
				//Call the helper class method
				//This method is used to validate the Periods on the Parent GTD
				StandardGoalDetailPacingTriggerHelper.valudateGTDPeriods(Trigger.new, Trigger.oldMap);
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