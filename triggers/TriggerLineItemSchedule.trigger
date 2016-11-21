//V1.0 - Created
//V1.1 - Modified By - Abhinav Sharma - 07/07/2014 - CR-20140618-5849 - Catch DML errors in triggers to reduce exception emails to SFAdmin
trigger TriggerLineItemSchedule on Line_Item_Schedule__c (before delete) {

    try {
    
        // if a trigger bypass is active, return immediately without processing
        if (Util.BypassAllTriggers) {
            return;
        }
    
        system.debug('### Begin TriggerLineItemSchedule : ' + trigger.old.size());
                    
        //Loop through the Line Items and make sure that they do not have a parent Sales Invoice.
        for(Line_Item_Schedule__c lineItemSchedule : trigger.old) {
            if(lineItemSchedule.Sales_Invoice__c != null) {
                system.debug('***Prevent deleting line item*** for ' + lineItemSchedule.Id); 
                lineItemSchedule.addError('This Line Item has already been billed. You cannot delete it.');
            }
        }
        system.debug('### End TriggerLineItemSchedule ###');
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