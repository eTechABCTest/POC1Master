/**
 *   Purpose         :   This class is helper class for Trigger_Syndicated_Research_Interaction trigger.[CR-20140619-5855]
 *               
 *   Created By      :   Ajit Surana
 *   
 *   Created Date    :   06/30/2014
 *   
 *   Current Version :   v1.0
 *   
 *   Revision Log    :   V1.0 - Created
 * 						 V1.1 - Modified By - MAhendra swarnakar - 09/18/2015 - CR-20150819-9165 - New method added - populateInstitutionLookUpFieldForNPD
 * 
 **/
public class SyndicatedRITriggerHelper{

    /**
     *  @description    : This method will process only "NPD" records with data in the GPA field and whenever a new interaction 
     *                    record is added or existing record is updated/deleted, then  it will update the parent Research Study record
     *                    with Research Study’s GPA field = A=# of NPD interactions with Product Concept Grade = A, B=# of NPD interactions
     *                    with Product Concept Grade = B, c=# of NPD interactions with Product Concept Grade = C
     * 
     *  @args           : Map of new Syndicated Research Interaction Id and instance, Map of old Syndicated Research Interaction Id and instance 
     * 
     *  @return         : void
     **/
     public static void populateGPAOnSyndicatedStudy(Map<Id, Syndicated_Research_Interaction__c> mapNewSRInteractions, Map<Id, Syndicated_Research_Interaction__c> mapOldSRInteractions) {
     
        //Map to hold the Syndicated Study Id as key and instance as value
        Map<Id, Syndicated_Study__c> mapSRStudy = new Map<Id, Syndicated_Study__c>();
            
        //Validating and populating set with parent record Id value when the event is of delete type
        if(mapNewSRInteractions == null) {
            for(Syndicated_Research_Interaction__c oldSRInteraction : mapOldSRInteractions.values()) {
                if(oldSRInteraction.Primary_Study__c != null)
                    mapSRStudy.put(oldSRInteraction.Primary_Study__c, new Syndicated_Study__c(Id=oldSRInteraction.Primary_Study__c, GPA__c = '0.0'));
            }
        //Validating and populating set with parent record Id value for the insert and update case
        } else {
            for(Syndicated_Research_Interaction__c newSRInteraction : mapNewSRInteractions.values()) {
                if(mapOldSRInteractions == null || (newSRInteraction.Product_Concept_Grade__c != mapOldSRInteractions.get(newSRInteraction.Id).Product_Concept_Grade__c
                        || newSRInteraction.Primary_Study__c != mapOldSRInteractions.get(newSRInteraction.Id).Primary_Study__c)) {
                    
                    //Populate set with current parent lookup value
                    if(newSRInteraction.Primary_Study__c != null)
                        mapSRStudy.put(newSRInteraction.Primary_Study__c, new Syndicated_Study__c(Id=newSRInteraction.Primary_Study__c, GPA__c = '0.0'));
                        
                    //Populating set with old parent lookup value on parent change
                    if(mapOldSRInteractions != null && mapOldSRInteractions.get(newSRInteraction.Id) != null && mapOldSRInteractions.get(newSRInteraction.Id).Primary_Study__c != null)
                        mapSRStudy.put(mapOldSRInteractions.get(newSRInteraction.Id).Primary_Study__c, new Syndicated_Study__c(Id=mapOldSRInteractions.get(newSRInteraction.Id).Primary_Study__c, GPA__c = '0.0'));
                }
            }
        }
           
        //Checking if we are having Syndicate Study record with us or not going to be update and are of NPD record type
        if(mapSRStudy.keySet().size() > 0) {
            
            //Map to hold Product Concept Grade values combinations
            Map<String, Decimal> mapPCGCombinations = new Map<String, Decimal>{'A'=>4.0,'B'=>3.0,'C'=>2.0};
        
            //Map to hold the Syndicated Study record Id as key and Count of eligible interaction records as value
            Map<Id, Integer> mapSyndicatedStudyWithInteractionsCount = new Map<Id, Integer>(); 
        
            //Loop through Syndicated Research Interactions records already assigned to a Syndicated Study
            for(Syndicated_Research_Interaction__c sS : [Select ID, Product_Concept_Grade__c, Primary_Study__c, Primary_Study__r.GPA__c
                                                        FROM Syndicated_Research_Interaction__c 
                                                        WHERE Primary_Study__c != null 
                                                            AND Primary_Study__c IN : mapSRStudy.keySet() 
                                                            ORDER BY Product_Concept_Grade__c ASC]) {
                
                //Check for Product Concept Grade field is not blank
                if(!String.isBlank(sS.Product_Concept_Grade__c)) {
                
                    if(mapSRStudy.get(sS.Primary_Study__c) != null && mapPCGCombinations.get(sS.Product_Concept_Grade__c) != null) {
                    
                        //Populating map with corresponding field values
                        if(mapSyndicatedStudyWithInteractionsCount.containsKey(sS.Primary_Study__c)) {
                            mapSyndicatedStudyWithInteractionsCount.put(sS.Primary_Study__c, (mapSyndicatedStudyWithInteractionsCount.get(sS.Primary_Study__c) + 1));
                            Decimal sumCount = Decimal.valueOf(mapSRStudy.get(sS.Primary_Study__c).GPA__c) + mapPCGCombinations.get(sS.Product_Concept_Grade__c);
                            mapSRStudy.put(sS.Primary_Study__c, new Syndicated_Study__c(Id=sS.Primary_Study__c, GPA__c = String.valueOf(sumCount)));
                        } else {
                            mapSyndicatedStudyWithInteractionsCount.put(sS.Primary_Study__c , 1);
                            Decimal sumCnt = Decimal.valueOf(mapSRStudy.get(sS.Primary_Study__c).GPA__c) + mapPCGCombinations.get(sS.Product_Concept_Grade__c);
                            mapSRStudy.put(sS.Primary_Study__c, new Syndicated_Study__c(Id=sS.Primary_Study__c, GPA__c = String.valueOf(sumCnt)));
                        }
                    }        
                } 
            }
            
            //Debugging for the map values
            System.debug('@@@@@ mapSRStudy' + mapSRStudy);
            System.debug('@@@@@ mapSyndicatedStudyWithInteractionsCount ' + mapSyndicatedStudyWithInteractionsCount);
        
            //Workaround for performing average on the GPA field value
            for(Id ssId : mapSyndicatedStudyWithInteractionsCount.keySet()) {
                
                //Checking for null value
                if(mapSRStudy.get(ssId) != null) {
                    
                    //Getting GPA Sum Count value for the Syndicated Study Record calculated previosuly on the basis of interaction records
                    Decimal productGradeSum = Decimal.valueOf(mapSRStudy.get(ssId).GPA__c);
                    Integer interactionRecordCount = mapSyndicatedStudyWithInteractionsCount.get(mapSRStudy.get(ssId).Id);
                    if(interactionRecordCount > 0) {
                        Decimal averageGPAValue =  (productGradeSum/Decimal.valueOf(interactionRecordCount));
                        averageGPAValue = averageGPAValue.SetScale(2);
                        mapSRStudy.put(mapSRStudy.get(ssId).Id, new Syndicated_Study__c(Id=mapSRStudy.get(ssId).Id, GPA__c = String.valueOf(averageGPAValue)));
                    }
                }   
            }
            
            //Debugging for the value
            System.debug('@@@@@ mapSRStudyafter average ' + mapSRStudy);
        }
        
        //Check if their are values to update
        if(mapSRStudy.values().size() > 0){
            Util.BypassAllTriggers = true;
                update mapSRStudy.values();
            Util.BypassAllTriggers = false;
        }
    }   
    
    /**
     *  @description    : This method will process only "NPD" records and populate the Instution lookup field.
     * 
     *  @args           : list of new Syndicated Research Interaction 
     * 
     *  @return         : void
     **/
    public static void populateInstitutionLookUpFieldForNPD(List<Syndicated_Research_Interaction__c> listNewSRInteractions){
        
        //Set of Contact Id's
        Set<Id> setContact = new Set<Id>();
        
        //Fetch the NPD record type Id
        List<RecordType> rtNPD = [Select Id from RecordType where DeveloperName = 'NPD' AND SObjectType = 'Syndicated_Research_Interaction__c' AND IsActive = true limit 1];
        
        //Check for size 
        if(rtNPD.size() > 0){
            
            //Populate the set of contact Id's
            for(Syndicated_Research_Interaction__c rSI : listNewSRInteractions){
                
                //Check for NPD record type on RSI record
                if(rSI.RecordTypeId == rtNPD[0].Id){
                    setContact.add(rSI.Contact__c);
                }
            }
            
            //Populate the Map to hold Contacts
            if(setContact.size() > 0) {
                
                //Query through contacts
        		Map<Id,Contact> mapContact = new Map<Id,Contact>([Select id, AccountId From Contact Where Id != null AND Id IN :setContact]);
                     
                //Loop through Research study Interaction records
                for(Syndicated_Research_Interaction__c rSI : listNewSRInteractions) {
                    
                    //Check for NPD record type on RSI record
                    if(mapContact.containsKey(rSI.Contact__c))
                    
                        //Populate the Institution lookup field on RSI with associated contact's institution
                        rSI.Institution__c = mapContact.get(rSI.Contact__c).AccountId;
                }
            }
        }
    }
}