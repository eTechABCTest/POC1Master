/*
    Purpose         :   This class is the helper class for CR Action Item trigger
                
    Create By       :   The Advisory Board Company
    
    Created Date    :   31/03/16
    
    Current Version :   v1.0
    
    Revision Log    :   V_1.0 Created - Jason Bennett - 03/31/16
                        
*/
public class CRActionItemTriggerHelper {
        
	/** 
     * description 
     *              : This method returns a list of SFDC Change Request Ids for a given list of CR Action Items, based on 
     * 					the hierarchy at a given starting parent field
     * 					for example:  'ISMod' => CR_Action_Item__c.IS_System_Modification__c.Change_Request__c
     * @param - 1) list of CR Action Items
     *              : List of CR Action Items currently in context
     * 			2) string parent
     * 				: Valid options =>
     * 					a.  ISMod - hierarchy starting at CR_Action_Item__c.IS_System_Modification__c.Change_Request__c
     * 					c.	ActionItem - hierarchy starting at CR_Action_Item__c.Change_Request__c
     * @return 
     *              : List of SFDC Change Request Ids
     */
    public static Set<Id> getParentChangeRequestIds(List<CR_Action_Item__c> actions, string parent) {

        //Create empty sets to hold the Ids
        Set<Id> crIds = new Set<Id>();
        Set<Id> craIds = new Set<Id>();
        
        //Get the Ids for the CR Action Item records, which will be used in a SOQL query
        for(CR_Action_Item__c a : actions){
            craIds.add(a.Id);
        }
        system.debug('CRActionItemTriggerHelper.getParentChangeRequestIds - craIds: ' + craIds);

        //Run a query to get the requested Id fields
        List<CR_Action_Item__c> craParentIds = new list<CR_Action_Item__c>(
            [SELECT IS_System_Modification__r.Change_Request__c,
             		Change_Request__c
             FROM CR_Action_Item__c 
             WHERE Id in :craIds]);
                
        //Loop through the query results to get the requested Change Request Ids
        for(CR_Action_Item__c c : craParentIds){
            if(parent == 'ISMod'){
                system.debug('CRActionItemTriggerHelper.getParentChangeRequestIds - c.IS_System_Modification__r.Change_Request__c: ' + c.IS_System_Modification__r.Change_Request__c);
            	if(c.IS_System_Modification__r.Change_Request__c != null){
                	crIds.add(c.IS_System_Modification__r.Change_Request__c);
            	}
            }else if(parent == 'ActionItem'){
                system.debug('CRActionItemTriggerHelper.getParentChangeRequestIds - c.Change_Request__c: '+ c.Change_Request__c);
                if(c.Change_Request__c != null){
                	crIds.add(c.Change_Request__c);
            	}
        	}
        }
        system.debug('CRActionItemTriggerHelper.getParentChangeRequestIds - crIds: ' + crIds);
        
        return crIds;
    }

    
    /** 
     * description 
     *              : This method returns a list of SFDC Release Ids for a given list of CR Action Items, based on 
     * 					the hierarchy at a given starting parent field
     * 					for example:  'ISMod' => CR_Action_Item__c.IS_System_Modification__c.Change_Request__c.Release__c
     * @param - 1) list of CR Action Items
     *              : List of CR Action Items currently in context
     * 			2) string parent
     * 				: Valid options =>
     * 					a.  ISMod - hierarchy starting at CR_Action_Item__c.IS_System_Modification__c.Change_Request__c.Release__c
     * 					b.  CR - hierarchy starting at CR_Action_Item__c.Change_Request__c.Release__c
     * 					c.	ActionItem - hierarchy starting at CR_Action_Item__c.Release__c
     * @return 
     *              : Set of SFDC Release Ids
     */
    public static Set<Id> getParentReleaseIds(List<CR_Action_Item__c> actions, string parent) {
        
        //Create empty sets to hold the Ids
        Set<Id> relIds = new Set<Id>();
        Set<Id> craIds = new Set<Id>();
        
        //Get the Ids for the CR Action Item records, which will be used in a SOQL query
        for(CR_Action_Item__c a : actions){
            craIds.add(a.Id);
        }
        system.debug('CRActionItemTriggerHelper.getParentReleaseIds - craIds: ' + craIds);

        //Run a query to get the requested Id fields
        List<CR_Action_Item__c> craParentIds = new list<CR_Action_Item__c>(
            [SELECT IS_System_Modification__r.Change_Request__r.Release__c,
             		Change_Request__r.Release__c,
             		Release__c
             FROM CR_Action_Item__c 
             WHERE Id in :craIds]);
                
        //Loop through the query results to get the requested Release Ids
        for(CR_Action_Item__c c : craParentIds){
            if(parent == 'ISMod'){
                system.debug('CRActionItemTriggerHelper.getParentReleaseIds - c.IS_System_Modification__r.Change_Request__r.Release__c: ' + c.IS_System_Modification__r.Change_Request__r.Release__c);
            	if(c.IS_System_Modification__r.Change_Request__r.Release__c != null){
                	relIds.add(c.IS_System_Modification__r.Change_Request__r.Release__c);
            	}
            }else if(parent == 'CR'){
                system.debug('CRActionItemTriggerHelper.getParentReleaseIds - c.Change_Request__r.Release__c: '+ c.Change_Request__r.Release__c);
                if(c.Change_Request__r.Release__c != null){
                	relIds.add(c.Change_Request__r.Release__c);
            	}
            }else if(parent == 'ActionItem'){
                system.debug('CRActionItemTriggerHelper.getParentReleaseIds - c.Release__c: '+ c.Release__c);
                if(c.Release__c != null){
                	relIds.add(c.Release__c);
            	}
        	}
        }
        system.debug('CRActionItemTriggerHelper.getParentReleaseIds - relIds: ' + relIds);
        
        return relIds;
    }
    
    /** 
     * description 
     *              : This method calls a process in @Future context to recalculate the IS Mod Manual Steps on related Release records.
     * 					This method runs in @Future after the records have been deleted, so the calculations are correct.
     * @param - 1) set of Release Ids
     *              : Set of Release Ids to be recalculated
     * @return 
     *              : nothing
     */
    @future public static void recalculateManualStepsOnReleases(Set<Id> releaseIds) {
        //Call helper class method here to roll up data on SFDC Release
        SFDCChangeRequestTriggerHelper.rollUpDataOnSFDCRelease(releaseIds);
        
    }
        
    
}