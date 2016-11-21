/*
    Purpose:        require comments for approval rejections
    
    Created By:     Victor Hanson
    
    Created Date:   8/29/13
    
    Revision Log:   V_1.0: Created
                    V_1.1: Modified By - Abhinav Sharma - 07/07/2014 - CR-20140618-5849 - Catch DML errors in triggers to reduce exception emails to SFAdmin
*/
trigger PaymentRequestTrigger on Payment_Request__c (before insert, before update, after insert, after update) {
    
    try {
    
        // check the request type
        if (trigger.isBefore) {
            
                // CR-2083 - update ABC Liaison = Vendor's ABC Liaison
                PaymentRequestTriggerHelper.PopuplateABCLiaison(trigger.New);
                
                // CR-2083 - calculate payment request's Total Qx_Budget Allocation Amt
                PaymentRequestTriggerHelper.calculateTotalBudgetPaymentAmount(trigger.new, false);
                
            if (trigger.isUpdate) {
                
                // CR-2083 - Require comments for approval rejections
                PaymentRequestTriggerHelper.RequireCommentsForAppRejection(trigger.New);
            }
        }
        if (trigger.isAfter) {
            
            if (trigger.isInsert) {
                
                // CR-2083 - begin the approval process for any Payment Requests that are created by a user with ABC Dataloader profile
                //PaymentRequestTriggerHelper.BeginApprovalProcess(trigger.New);
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