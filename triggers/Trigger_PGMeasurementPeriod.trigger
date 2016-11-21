/**
 *  Description     :   Trigger is used to handle all the pre and post processing operation for Personal Goal Measurement Period
 *
 *  Created By      :   Subhash Garhwal
 *
 *  Created Date    :   10/31/2015
 *
 *  Revision Logs   :   V_1.0 - Created - CR-20150825-9114 
 *					  
 **/
trigger Trigger_PGMeasurementPeriod on Personal_Goal_Measurement_Period__c (before insert, before update) {
	
	try {
		
		//Bypass flag
        if (Util.BypassAllTriggers) return;
        
		//Check for trigger context
		if(Trigger.isBefore) {
			
			//Check for trigger events
			if(Trigger.isInsert || Trigger.isUpdate) {
				
				//Call helper class method
                //This method is used to prevent duplicates.
                PGMeasurementPeriodTriggerHelper.preventDuplicates(Trigger.new, Trigger.oldMap);
				
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