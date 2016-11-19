//V1.0 - Created
//v1.1 - Modified By - Abhinav Sharma - 07/07/2014 - CR-20140618-5849 - Catch DML errors in triggers to reduce exception emails to SFAdmin
trigger ChangeRequest on SFDC_Change_Request__c (after delete, after insert, after update) {

    try {
    
        // get the list of change requests
        list<SFDC_Change_Request__c> changeRequests = (Trigger.IsDelete)? Trigger.old : Trigger.new;
        
        // update the current status of the IS System if applicable
        ChangeRequestUtilities.UpdateCurrentStatus(changeRequests);
        
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