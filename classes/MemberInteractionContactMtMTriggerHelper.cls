/**
 *  Description     :   Helper class for MemberInteractionContactMtM object trigger
 * 
 *  Created By      :   Abhinav Sharma    
 * 
 *  Created Date    :   08/24/2015
 * 
 *  Revision Logs   :   V_1.0 - Created - 08/24/2015
 * 						V_1.1 - Modified by - Mahendra Swarnkar -CR-20151229-9481- 04/2/2016 - updated the method "validateAttendeesForInteraction" to provide the MemberInteractionContactMtM uniqueness.
**/ 

public without sharing class MemberInteractionContactMtMTriggerHelper {
    
    //Added By - Abhinav Sharma - CR-20150813-9155 - 08/24/2015
    /**
     *  @description    :   Method to prevent tagging the same contact multiple times for Interaction Attendees.
     * 
     *  @args           :   List of cases, Map of Cases
     * 
     *  @return         :   void
     * 
    **/
    public static void validateAttendeesForInteraction(List<MemberInteractionContactMtM__c> listMtms, Map<Id, MemberInteractionContactMtM__c> mapOfOldMtms) {
		
        //Map to hold unique key and corresponding MTM record as value
		Map<String, MemberInteractionContactMtM__c> mapOfMtms = new Map<String, MemberInteractionContactMtM__c>();
        
        //Set to hold Relationship interaction's Ids
        Set<Id> setInteractionsIds = new Set<Id>();
        
        //Set to hold Member interaction's Ids
        Set<Id> setMemberInteractionsIds = new Set<Id>();
        
        //Set to hold Research Study interaction's Ids
        Set<Id> setResearchStudyInteractionsIds = new Set<Id>();
        
        //Set to hold the contact Ids
        Set<Id> setContactIds = new Set<Id>();
        
        //Loop through MTM records
		for (MemberInteractionContactMtM__c mtm : listMtms) {

            // Make sure we don't treat a contact that isn't changing during an update as a duplicate.  
            if (mtm.Contact__c != null 
                 && (mtm.Relationship_Interaction__c != null 
                      || mtm.Member_Interaction__c != null
                      || mtm.Research_Study_Interaction__c != null)){
                          
                if(mapOfOldMtms == null 
                    || (mapOfOldMtms != null
                    && (mtm.Relationship_Interaction__c != mapOfOldMtms.get(mtm.Id).Relationship_Interaction__c
                         || mtm.Member_Interaction__c != mapOfOldMtms.get(mtm.Id).Member_Interaction__c
                         || mtm.Research_Study_Interaction__c != mapOfOldMtms.get(mtm.Id).Research_Study_Interaction__c
                         || mtm.Contact__c != mapOfOldMtms.get(mtm.Id).Contact__c))){
                
                    // Make sure another new MTM isn't also a duplicate  
                    if (mtm.Relationship_Interaction__c  != null && !mapOfMtms.containsKey(mtm.Relationship_Interaction__c + '-' + mtm.Contact__c)){
                        
                        mapOfMtms.put(mtm.Relationship_Interaction__c + '-' + mtm.Contact__c, mtm);
                        setInteractionsIds.add(mtm.Relationship_Interaction__c);
                        setContactIds.add(mtm.Contact__c);
                    
                    }else {
            
                        // Make sure another new MTM isn't also a duplicate  
                        if ( mtm.Member_Interaction__c != null && !mapOfMtms.containsKey(mtm.Member_Interaction__c + '-' + mtm.Contact__c)){
                            
                            mapOfMtms.put(mtm.Member_Interaction__c + '-' + mtm.Contact__c, mtm);
                            setMemberInteractionsIds.add(mtm.Member_Interaction__c);
                            setContactIds.add(mtm.Contact__c);
                        }
                        else {
            
                            // Make sure another new MTM isn't also a duplicate  
                            if (mtm.Research_Study_Interaction__c != null && !mapOfMtms.containsKey(mtm.Research_Study_Interaction__c + '-' + mtm.Contact__c)){
                                
                                mapOfMtms.put(mtm.Research_Study_Interaction__c + '-' + mtm.Contact__c, mtm);
                                setResearchStudyInteractionsIds.add(mtm.Research_Study_Interaction__c);
                                setContactIds.add(mtm.Contact__c);
                            }
                            else {
                                if((mtm.Research_Study_Interaction__c  != null && mapOfMtms.containsKey(mtm.Research_Study_Interaction__c + '-' + mtm.Contact__c))
                                   ||(mtm.Member_Interaction__c  != null &&  mapOfMtms.containsKey(mtm.Member_Interaction__c + '-' + mtm.Contact__c))
                                   ||(mtm.Relationship_Interaction__c  != null &&  mapOfMtms.containsKey(mtm.Relationship_Interaction__c + '-' + mtm.Contact__c))){
                                    mtm.addError(System.Label.Error_Duplicate_Contact_Tagging);
                                }
                            }
                        }
                    }
                }
            }
		}
        //Checking for set and map size values
        if((setMemberInteractionsIds.size() > 0 
             || setResearchStudyInteractionsIds.size()>0 
             || setInteractionsIds.size() > 0)
            && setContactIds.size() > 0 
            && mapOfMtms.values().size() > 0) {
            
            // Using a single database query, find all the Mtms in the database that have the same interaction-Contact key 
            // as any of the MTM being inserted or updated.  
        	for (MemberInteractionContactMtM__c m : [SELECT ID, Relationship_Interaction__c, Research_Study_Interaction__c, Member_Interaction__c, Contact__c 
                                                	FROM MemberInteractionContactMtM__c
        											WHERE Contact__c != null
                                                     	AND Contact__c IN : setContactIds
                                                        AND ((Relationship_Interaction__c != null 
                                                             	AND Relationship_Interaction__c IN : setInteractionsIds)
                                                        	 OR (Research_Study_Interaction__c != null 
                                                             	AND  Research_Study_Interaction__c IN : setResearchStudyInteractionsIds)
                                                        	 OR (Member_Interaction__c != null 
                                                             	AND Member_Interaction__c IN : setMemberInteractionsIds))]
			) {
                MemberInteractionContactMtM__c newMtM ;
        		if(m.Relationship_Interaction__c != null)
                    newMtM = mapOfMtms.get(m.Relationship_Interaction__c + '-' + m.Contact__c);
                else {
                    if(m.Research_Study_Interaction__c != null)
                        newMtM = mapOfMtms.get(m.Research_Study_Interaction__c + '-' + m.Contact__c);
                    else{
                     	if(m.Member_Interaction__c != null)
                            newMtM = mapOfMtms.get(m.Member_Interaction__c + '-' + m.Contact__c);
                    }
                }   
                newMtM.addError(System.Label.Error_Duplicate_Contact_Tagging);
        	}
        }
    }
}