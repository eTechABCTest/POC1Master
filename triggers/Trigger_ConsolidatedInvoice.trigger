/**
  * Purpose :   This trigger is responsible for handling all the pre or post processing for
  *         any dml operation for Consolidated Invoice object 
  *     
  *         Processes:
  *         1.  Synchronize the values from Activity(Task) Histories.
  *                  
  * Create By   :   Abhinav Sharma
  *  
  * Created Date:   06/23/2015
  *  
  * Current Version:    v1.1
  *  
  * Revision Log:   v1.1 - Created     
**/

trigger Trigger_ConsolidatedInvoice on ConsolidatedInvoice__c (before update) {
    
    try {
    
    //Check for by-pass the Trigger
        if (Util.BypassAllTriggers) return;
    
        //Checking for the event type
        if(trigger.isBefore) {
            
            //Checking for the request type
            if(trigger.isUpdate) {
            
                //Calling helper class method
                ConsolidateInvoiceTriggerHelper.syncValuesFromActivityHistories(Trigger.new);
            
            }        
        }
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