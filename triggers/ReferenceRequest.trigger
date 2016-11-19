/**
 *  Description     :  trigger for the Reference Request object
 *
 *  Revision Logs   :   v1.0 - 12/10/2015 - Created - Victor Hanson - Reference Tracking project (CR-20150826-9191)
 **/
trigger ReferenceRequest on Reference_Request__c (before insert, before update) {
	
    //trigger bypass
    if (util.BypassAllTriggers) return;
    
    if (trigger.isBefore) {
        //set the reference lead based on the Reference Module(s) selected
        ReferenceTriggerHelper.setReferenceLead(trigger.new);
        
    }
    
}