trigger Release on SFDC_Release__c (before insert, before update, after delete) {
	
    //return without processing if bypass all triggers is true
    if (Util.BypassAllTriggers) return;
    
    if (trigger.isBefore) {
        if (trigger.isUpdate) {
            
            //If the release status changes to cancelled, remove events from the deployment calendar.
            LP_ServiceUtils.checkEventOwner(trigger.new, trigger.oldMap);
        }
    }
    
    if (trigger.isAfter) {
        if (trigger.isDelete) {
            
            //do not allow deletion of records synched with LP unless it is the site guest user
            LP_ServiceUtils.validateDelete(trigger.old);
        }
    }
}