/*
    Purpose:    Calculate total budget allocation / payment and populate the approver
                
    Create By:  Victor Hanson
    
    Created Date:   09/09/2013
    
    Current Version:    v1.1
    
    Revision Log:   V1.0 Created
                    v1.1 - Modified By - Abhinav Sharma - 07/07/2014 - CR-20140618-5849 - Catch DML errors in triggers to reduce exception emails to SFAdmin
*/
trigger BudgetAllocationTrigger on Budget_Allocation__c (before insert, before update, before delete, after insert, after update, after delete) {
    
    try {
    
        if (trigger.isAfter) {
            
            // calculate the total budget allocation for Qx Allocatoin fields
            BudgetAllocationTriggerHelper.CalcTotalBudgetAllocation(trigger.new, trigger.oldMap, trigger.isDelete);
            
            // calculate the total payments and populate on the Qx Payment fields
            BudgetAllocationTriggerHelper.CalcTotalBudgetPayment(trigger.new, trigger.oldMap, trigger.isDelete);
            
            // update related payment requests with the updated total Qx amount
            BudgetAllocationTriggerHelper.updatePaymentRequestQxAmount(trigger.new, trigger.old);
            
            if (!trigger.isDelete) {
                
                // populate the department head on the Purchase or Payment Request
                BudgetAllocationTriggerHelper.PopulateDepartmentHead(trigger.new, trigger.oldMap);
                
                // populate the Qx Allocation amount on all related payment request budget allocations
                BudgetAllocationTriggerHelper.updatePaymentAllocationQuarters(trigger.new);
            }
            else if (trigger.isDelete) {
                
                // get all related budget allocations and delete them as well
                BudgetAllocationTriggerHelper.deleteAllocations(trigger.old);
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