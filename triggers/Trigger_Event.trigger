/**
 *  Purpose         :   This trigger is to handle all teh pre and post processing operation for Event trigger
 * 
 *  Created By      :   Bhavi Sharma
 * 
 *  Created Date    :   01/19/2015
 * 
 *  Revision Logs   :   V_1.0 - Created (CR-20141119-8126)
                        V_1.1 - Modified By - Mahendra Swarnkar - 05/16/2015 - CR-20150401-8835
                        V_1.2 - Modified By - Mahendra Swarnkar - 08/26/2015 - CR-20140613-5790
                        V_1.3 - Modified By - Abhinav Sharma - 09/04/2015 - R-20150817-9161 
 **/ 
trigger Trigger_Event on Event (after insert, after update,  after delete, before insert, before update) {
    
    //Bypass
    if(Util.BypassAllTriggers
        || Util.IsBatch
        || EventTriggerHelper.EXECUTE_TRIGGER == false)
        return;
    
    //Check for the request type
    if(Trigger.isAfter) {
        
        //Check for the event type
        if(Trigger.isInsert || Trigger.isUpdate || Trigger.isDelete) {
            
            //Call helper class method to update the most recent QA Call data
            EventTriggerHelper.populateMostRecentQACall(Trigger.New, Trigger.oldMap);
            
            //Added by - Mahendra Swarnkar -05/16/2015 - CR-20150401-8835
            //Starts from here
            //Call helper class method to update the Next Activity Date field on Opporutnity.
            EventTriggerHelper.updateNextActivityDate(Trigger.New, Trigger.oldMap);
            
            //Added by - Abhinav Sharma - 08/26/2015 - CR-20140613-5790
            //Starts from here
            //Call helper class method to update the Next Activity Date field on Opporutnity.
            EventTriggerHelper.populatePAsAndActivityFieldsOnOpportunity(Trigger.New, Trigger.oldMap);
            //Ends here
        }
    }
    
    //Check for request type
    if(Trigger.isBefore) {
        //Added By - Abhinav Sharma - 09/04/2015 - R-20150817-9161 
        if(Trigger.isInsert || Trigger.isUpdate) {
            EventTriggerhelper.updateEventHistoryTrackingFields(Trigger.new, Trigger.oldMap);    
        }
    }
}