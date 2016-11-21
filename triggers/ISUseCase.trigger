/**
 * Desription      :   	Trigger for the IS Use Case object
 * 
 * Revision Logs   :   	v1.0 - Victor Hanson - 10/30/2015 - Created
 **/
trigger ISUseCase on IS_Use_Case__c (before insert, before update) {
	
    //bypass triggers if necessary
    if (util.BypassAllTriggers) return;
    
    if (trigger.isBefore) {
        
        if (trigger.isUpdate) {
            
            //clone old use cases
            ISUseCaseHelper.cloneOldUC(trigger.new, trigger.oldMap);
        }
        
        //update the version number
        ISUseCaseHelper.incrementVersionNumber(trigger.new);
    }
}