/**
 *  Purpose         :   This trigger is to handle all the pre and post processing operations for lead object
 *
 *  Create By       :   Bhavi Sharma
 *
 *  Created Date    :   01/31/2014
 *
 *  Revision Logs   :   V_1.0 - Created
                    :   V_1.1 - Modified By - Abhinav Sharma - 07/07/2014 - CR-20140618-5849 - Catch DML errors in triggers to reduce exception emails to SFAdmin
 **/
trigger Trigger_Lead on Lead (after update) {
    
    try {
        //Check for the request Type
        if(Trigger.isAfter) {
            
            //Check for the event type
            if(Trigger.isUpdate) {
                
                //Call helper class method to check when lead is being converted
                //Then pass the Lead Address information to Contact record - CR-20130419-2900
                LeadTriggerHelper.copyAddressToContactOnConversion(Trigger.New, Trigger.oldMap);
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