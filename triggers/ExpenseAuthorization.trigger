/**
 * 	@description	:	This  trigger is to handle all the pre and post processing opreration
 * 
 * 	@Created By		:	Victor Hanson
 * 
 * 	@Change History	:	V1.0 - Created - 01/27/2015 - Victor Hanson - CR-20140520-5562
 * 
 **/
trigger ExpenseAuthorization on Expense_Authorization__c (before insert, before update) {
	
    //Check  for the request Type
    if (trigger.isBefore) {
        
        //Check for the event type
        if (!trigger.isDelete) {
            
            //Call helper method to populate the approver based on the related Budget G/L
            ExpenseAuthTriggerHelper.populateApprover(trigger.new);
        }
    }
}