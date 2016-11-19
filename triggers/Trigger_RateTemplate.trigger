/**
	*	Description		:	Trigger is used to habdle all pre or post oprationn for Rate Template.
	*
	*	Created By		:	Subhash Garhwal
	*
	*	Created Date	:	10/8/2015
	*
	*	Revision Logs   :   V_1.0 - Created - CR-20150729-9114
	*
	**/
trigger Trigger_RateTemplate on Rate_Template__c (before delete, before insert, before update) {
	
	try {
		
		//Bypass flag
		if(Util.BypassAllTriggers) return;
		
		//Check for trigger context
		if(Trigger.isBefore){
			
			//Check for Trigger Event 
			if(Trigger.isInsert || Trigger.isUpdate) {
				
				//Call helper class method
				RateTemplateTriggerHelper.validateRateTemplates(Trigger.new, Trigger.oldMap);
			}
			
			//Check for Trigger Event
			if(Trigger.isDelete){
				
				//Call helper class method
				RateTemplateTriggerHelper.validateBeforeDelete(Trigger.old);
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