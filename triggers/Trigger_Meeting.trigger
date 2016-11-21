/**
 *  Description     :   This trigger is to handle all the pre and post processing operation for Meeting record
 * 
 *  Created By      :   Bhavi Sharma
 * 
 *  Created Date    :   02/22/2013
 * 
 *  Revision Logs   :   V1.0 - Created
                        V1.1 - Modified By - Abhinav Sharma - 07/07/2014 - CR-20140618-5849 - Catch DML errors in triggers to reduce exception emails to SFAdmin
 * 
 **/
trigger Trigger_Meeting on Meeting__c(after update){

    try {
    
        //Check for the request type
        if(Trigger.isAfter) {
            
            //Check for the event type
            if(Trigger.isUpdate) {
                 
                 //Call the helper class method to create the registration records
                 MeetingTriggerHelper.createRegistrationForParentRegisteredContacts(Trigger.newMap, Trigger.oldMap);
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