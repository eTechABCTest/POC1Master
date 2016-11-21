/** 
  * Description     :   Helper class for Trigger_ReferencePerk 
  *
  * Created By      :   Rajeev Jain(Simplyforce)
  *
  * Created Date    :   12/15/2015
  *
  * Version         :   V1.0 Created
  **/ 
public without sharing class ReferencePerkTriggerHelper {
    
    //Static Variables
    public static Map<Id, RecordType> mapReferencePerkRecordTypes{
        
        get{
            if(mapReferencePerkRecordTypes == null)
            
                mapReferencePerkRecordTypes = new Map<Id, RecordType>([select Id, DeveloperName from RecordType 
                                                                        where sObjectType = 'Reference_Perk__c' 
                                                                        AND IsActive = true]);  
            
            return mapReferencePerkRecordTypes;
        }
    } 
    
    /**
     *  @description    :   Method to populate Eligible Reference Perk fields. Eligibiliy criteria are as follow
     *                      Record Type = 'Performance Technology'
     *                      •   Reference.IsActive__c = true
     *                      •   Reference.Reference_Level__c = “Ambassador”
     *                      •   Perk Template.Status__c = “Available”
     *                      •   Reference.Reference_Module__c = Perk Template.Applicable_Reference_Module__c
     *
     *  @args           :   List of new Reference Perk, Map of old Reference Perk
     *
     *  @return         :   void
     *
    **/
    public static void populateFieldsOfEligibleReferencePerk(List<Reference_Perk__c> newMemberSupports, Map<Id, Reference_Perk__c> mapOldMemberSupports){
        
        //Checkk for Insert and Update Case
        if(newMemberSupports != null){
            
            //Map to hold the Reference Records corrosponding to its each record Id
            Map<Id, Reference__c> mapReferenceRecords = new Map<Id, Reference__c>();
            
            //Map to hold Perk Templates Records Corrosponding to its each record Id
            Map<Id, Reference_Perk__c> mapPerkTemplates = new Map<Id, Reference_Perk__c>();
            
            //Set to Hold Refernece id
            Set<Id> setReferenceIds = new Set<Id>();
            
            //Set to Hold ids of the Perk Template
            Set<Id> serPerkTemplateIds = new Set<Id>();
            
            //Loop over eahc Refernece Perk
            for(Reference_Perk__c perk : newMemberSupports){
                
                //Check for Reference Perk eligibility Criteria
                if(mapReferencePerkRecordTypes.get(perk.RecordTypeId).DeveloperName == Label.PT && 
                        perk.Reference__c != null && perk.Perk_Template__c != null){
                    
                    if(mapOldMemberSupports == null || perk.Reference__c != mapOldMemberSupports.get(perk.Id).Reference__c)
                        setReferenceIds.add(perk.Reference__c);
                    
                    if(mapOldMemberSupports == null || perk.Perk_Template__c != mapOldMemberSupports.get(perk.Id).Perk_Template__c)
                        serPerkTemplateIds.add(perk.Perk_Template__c);
                }
            }
            
            //Check size of SetReferneceIds
            if(setReferenceIds.size() > 0){
                mapReferenceRecords = new Map<Id, Reference__c>([select Id, IsActive__c, Reference_Level__c, Reference_Module__c, Contact_Name__c from Reference__c where Id IN :setReferenceIds]); 
            }
            
            //Check size of serPerkTemplateIds
            if(serPerkTemplateIds.size() > 0){
                mapPerkTemplates = new Map<Id, Reference_Perk__c>([select Id, Status__c, Applicable_Reference_Module__c from Reference_Perk__c where Id IN :serPerkTemplateIds]);
            }
            
            //Reloop over on the New Reference Perks Records and Populated its Contact field based on criteria
            for(Reference_Perk__c perk : newMemberSupports){
                
                //Check if all above mentioned conditions matched 
                Reference__c ref = mapReferenceRecords.containsKey(perk.Reference__c) ? mapReferenceRecords.get(perk.Reference__c) : new Reference__c();
                Reference_Perk__c perkTemp = mapPerkTemplates.containsKey(perk.Perk_Template__c) ? mapPerkTemplates.get(perk.Perk_Template__c) : new Reference_Perk__c();
                
                //Check if all condition meets criteira as mentioned on the method description then populate contact field on refernece perk
                if(ref.IsActive__c && ref.Reference_Level__c.equalsIgnoreCase('Ambassador') && 
                    ref.Reference_Module__c == perkTemp.Applicable_Reference_Module__c &&
                    perkTemp.Status__c.equalsIgnoreCase('Available')){
                    perk.Contact__c = ref.Contact_Name__c;          
                }
            }
        }   
    }
}