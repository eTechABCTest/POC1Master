/**
 *  Description     :  Trigger for the Reference object
 *
 *  Revision Logs   :   v1.0 - 12/10/2015 - Created - Victor Hanson - Reference Tracking project (CR-20150826-9191)
 **/
trigger Reference on Reference__c (before insert, before update, after insert, after update) {
	
    //trigger bypass
    if (Util.BypassAllTriggers) return;
    
    if (trigger.isBefore) {
        
        //populate the Reference default fields if they are blank (Reference Lead, Dedicated Advisor, NASA Principal/AP)
        ReferenceTriggerHelper.setReferenceDefaults(trigger.new);
    }
    else if (trigger.isAfter) {
        
        //populate the reference program status on the related Contacts/Accounts
        ReferenceTriggerHelper.updateReferenceStatusString(trigger.new, trigger.oldMap);
    }
}