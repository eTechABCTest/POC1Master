/**
*   Purpose         :   This trigger is responsible for handling all the pre or post processing for
*                       any dml operation for Member Interaction object 
*
*   Create By       :   Bhavi Sharma
*
*   Created Date    :   06/13/2013
*
*   Current Version :   v1.0
*
*   Revision Logs   :   v1.0 - Created - CR-20130228-2612
                        V_1.1 - Bhavi Sharma - 12/20/2013 - CR-20130925-3694
                        V_1.2 - Bhavi Sharma - 02/04/2014 - CR-20140124-4353
                        V_1.3 - Abhinav Sharma - 04/18/2014 - CR-20130730-3316
                        V_1.4 - Modified By - Abhinav Sharma - 07/07/2014 - CR-20140618-5849 - Catch DML errors in triggers to reduce exception emails to SFAdmin
						V_1.5 - Mahendra Swarnkar - CR-20160610-9915 - 08/27/2016 - Call new method "updateDateOfFirstELOnWarmLead"
**/
trigger Trigger_MemberInteractions on Call__c (before insert, before update, after insert, after update, after delete) {
    
    try {
    	
    	//By Pass trigger check
    	if (Util.BypassAllTriggers) return;
    	
        //Check for request type
        if(Trigger.isBefore) {
            
            //Check for event type
            if(Trigger.isInsert) {
                
                //call helper class method
                MemberInteractionTriggerHelper.PopulateMemberInteractionData(Trigger.new);
            }
            
            //Check for event type
            if(Trigger.isInsert || Trigger.isUpdate) {
                
                //Added By - Abhinav Sharma - 04/18/2014 - CR-20130730-3316
                //Call helper class method
                MemberInteractionTriggerHelper.ValidateAndPopulateDataOnInteratcionRecords(Trigger.new);
            }
            
        } else {
            
            //Check for the event
            if(Trigger.isInsert || Trigger.isUpdate || Trigger.isDelete) {
            
                //Call helper class method to update opps
                MemberInteractionTriggerHelper.updateOpportunityELSSentCounter(Trigger.New, Trigger.oldMap);
                
                //Mahendra Swarnkar - CR-20160610-9915 - 08/27/2016
	            //Call helper class method to update WarmLead records
	            MemberInteractionTriggerHelper.updateDateOfFirstELOnWarmLead(Trigger.New, Trigger.oldMap);
            }
            
            //Update Institution Roles
            MemberInteractionTriggerHelper.UpdateInteractionInformation(Trigger.New, Trigger.oldMap);
            
            //Update Interaction Grade on NPD Records
            MemberInteractionTriggerHelper.UpdateInteractionGradeNPD(Trigger.New, Trigger.oldMap);
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