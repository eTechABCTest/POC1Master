/*
    Purpose:        find all budget approvers and send them an email notifying 
                    them of the new purchase request waiting to be submitted for approval.  Require comments when approval is rejected.
    
    Created By:     Victor Hanson
    
    Created Date:   8/29/13
    
    Revision Log:   V_1.0: Created
                    V_1.1: Modified By - Abhinav Sharma - 07/07/2014 - CR-20140618-5849 - Catch DML errors in triggers to reduce exception emails to SFAdmin
*/
trigger PurchaseRequestTrigger on Purchase_Request__c (before insert, before update, after insert, after update) {

    try {
    
        if (trigger.isBefore) {
            
            if (trigger.isUpdate) {
                // CR-2083 - Require comments for approval rejections
                PurchaseRequestTriggerHelper.RequireCommentsForAppRejection(trigger.New);
            }
        }
        if (trigger.isAfter) {
            
            if (trigger.isInsert) {
                // CR-2083 - Send email to budget approvers
                PurchaseRequestTriggerHelper.NotifyBudgetApprovers(trigger.New);
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