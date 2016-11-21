/*
    Purpose:    This trigger is responsible for handling all the pre or post processing for
                any dml operation for Restriction object 
                
                Processes:
                1.  Copy actual owner id value to Owner_Details__c field before insertion.
                
                2.  Copy actual owner id value to Owner_Details__c field before updation.
                
                
    Create By   :   Simplyforce Technology
    
    Created Date:   10/08/2011
    
    Current Version:    v1.1
    
    Revision Log:       v1.0
                        v1.1 - Modified By - Abhinav Sharma - 07/07/2014 - CR-20140618-5849 - Catch DML errors in triggers to reduce exception emails to SFAdmin
*/
trigger Trigger_Restriction on Restrictions__c (before insert, before update) {
    
    try {
    
            // return immediately without processing if either of these are true
            if (Util.BypassAllTriggers) return;
            
            //Check for the trigger request type
            if(Trigger.isBefore) {
                
                //check for the event type
                if(Trigger.isInsert || Trigger.isUpdate) {
                    
                    //call the trigger helper call to execute the logic
                    RestrictionTriggerHelper.updateOwnerDetailsField(Trigger.New);
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