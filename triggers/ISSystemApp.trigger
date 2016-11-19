/**
 * Desription      :   	Trigger for the IS System App object
 * 
 * Revision Logs   :   	v1.0 - Victor Hanson - 11/05/2015 - Created
 **/
trigger ISSystemApp on IS_System__c (before insert, before update) {
	
    //bypass triggers if necessary
    if (util.BypassAllTriggers) return;
    
    if (trigger.isBefore) {
        
        if (trigger.isUpdate) {
            
            //
            ISSystemAppHelper.inactiveCheck(trigger.newMap, trigger.oldMap);
        }
    }
	
}