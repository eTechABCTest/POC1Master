/*
    Purpose         :   This trigger is to do all the pre and post processing operations for MembershipKeyContact object
                
    Create By       :   Simplyforce Technology
    
    Created Date    :   12/15/2012
    
    Current Version :   v1.1
    
    Revision Log    :   V_1.0 Created
                        V_1.1 - Modified By - Abhinav Sharma - 07/07/2014 - CR-20140618-5849 - Catch DML errors in triggers to reduce exception emails to SFAdmin
*/
trigger Trigger_MembershipKeyContact on Membership_Key_Contact__c (after insert, after update) {
    
    try {    
        //Check for the request type
        if(Trigger.isAfter) {
            
            //Check for the event type
            if(Trigger.isInsert || Trigger.isUpdate) {
                
                //Call helper class method
                MembershipKeyContactTriggerHelper.populateContactData(Trigger.New);         
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