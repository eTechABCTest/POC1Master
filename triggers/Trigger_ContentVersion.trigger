/**
 *   Purpose         :  This trigger to handle all the processing for ContentVersion object.
 *               
 *   Created By      :  Abhinav Sharma
 *   
 *   Created Date    :  09/01/2016
 *   
 *   Revision Logs   :  V_1.0 - Created - CR-20160224-9640
 *
**/
trigger Trigger_ContentVersion on ContentVersion (after insert) {
    
    try {
        
        //Bypass trigger logic if Util.byPassAllTriggers = true
        if (Util.BypassAllTriggers) 
            return;
        
        //Checking for the event type
        if (trigger.isAfter) {
            
            //Checking for the request type
            if(Trigger.isInsert) {
                
                //Calling helper class method
                ContentVersionTriggerHelper.grantAdditionalSharingonFiles(trigger.new);
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