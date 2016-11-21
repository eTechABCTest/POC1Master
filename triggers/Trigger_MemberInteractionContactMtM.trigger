/**
    Purpose          :   This trigger to handle all the processing for MemberInteractionContactMtM object.
                
    Created By       :   Abhinav Sharma
    
    Created Date     :   08/24/2015
    
    Revision Logs    :   V_1.0 - Created - 08/24/2015
**/

trigger Trigger_MemberInteractionContactMtM on MemberInteractionContactMtM__c (before insert, before update) {
	
    try {
    
        if (Util.BypassAllTriggers) return;
        
        //Added By - Abhinav Sharma - 08/24/2015 - CR-20150813-9155
        //Start from Here
        //Checking for the event type
        if(Trigger.isBefore) {
            
            //Checking for the request type
            if(Trigger.isInsert || Trigger.isUpdate) {
                
                //Calling Helper class method to do the validation
                MemberInteractionContactMtMTriggerHelper.validateAttendeesForInteraction(trigger.new, trigger.oldMap);
            }
        }
        //Upto Here
                
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