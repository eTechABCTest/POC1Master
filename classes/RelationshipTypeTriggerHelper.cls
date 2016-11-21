/**
 *  Description     :   Helper class for Trigger_RelationshipType trigger.
 *
 *  Created By      :   Subhash Garhwal 
 *
 *  Created Date    :   9/29/2015
 *
 *  Revision Logs   :   V_1.0 - Created - CR-20150825-9182
 *                    
 **/
public without sharing class RelationshipTypeTriggerHelper {

	/**
     *  @description    :	This method is used to update the child staff relationship and My relationship records.
     *  
     *  @args           :   List<Relationship_Type__c>, Map<Id, Relationship_Type__c>
     *
     *  @return         :   void
     *
     **/
     public static void cascadeChanges(List<Relationship_Type__c> NewRelationshipTypes, Map<Id, Relationship_Type__c> mapOldRelationshipTypes){
     	
     	//Set To Hold relationship Type Id
     	Set<Id> setRTIds = new Set<Id>();
     	
     	//Loop Through RelationshipType
     	for(Relationship_Type__c rT : NewRelationshipTypes){
     		
     		//Check For apporiate condition and add Id in set
     		if(mapOldRelationshipTypes != null && (rT.Name != mapOldRelationshipTypes.get(rT.Id).Name || rT.Name_When_From__c != mapOldRelationshipTypes.get(rT.Id).Name_When_From__c
     			|| rT.Name_When_To__c != mapOldRelationshipTypes.get(rT.Id).Name_When_To__c))
     			setRTIds.add(rT.Id);
     	}
     	
     	//Check size
     	if(setRTIds.size() > 0){
	     	
	     	//Update Staff Relationship or My Relationship
	     	update [Select Id, Relationship__c From Staff_Relationship__c Where Relationship__c IN: setRTIds];
	     	update [Select Id, Staff_Relationship__r.Relationship__c From My_Relationships__c Where Staff_Relationship__r.Relationship__c IN : setRTIds];
     	}
     }
}