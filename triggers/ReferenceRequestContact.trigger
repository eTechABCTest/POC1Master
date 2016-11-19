/**
 *  Description     :  Trigger for the Reference Request Contact object
 *
 *  Revision Logs   :   v1.0 - 12/10/2015 - Created - Victor Hanson - Reference Tracking project (CR-20150826-9191)
 **/
trigger ReferenceRequestContact on Reference_Request_Contact__c (before insert, before update) {
	
    //trigger bypass
    if (util.BypassAllTriggers) return;
	
    if (trigger.isBefore) {
        
        //populate the approver
        ReferenceRequestContactHelper.populateApprover(trigger.new);
    }
}