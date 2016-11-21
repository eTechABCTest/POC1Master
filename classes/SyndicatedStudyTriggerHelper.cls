/**
 *   Purpose         :   This class is helper class for Trigger_Syndicated_Study trigger.
 *               
 *   Created By      :   Ajit Surana
 *   
 *   Created Date    :   07/10/2014
 *   
 *   Current Version :   v1.0
 *   
 *   Revision Log    :   V1.0 - Created - [CR-20140619-5855]
 **/
public class SyndicatedStudyTriggerHelper {
    
    /**
     *  @description    :   This method will process only "NPD" records and will update the Research Study record
     *                      GPA field value with interactions Product Concept Grade field average values.
     *                       
     *  @args           :   List of Syndicated Study records, Map of old Syndicated Study records
     * 
     *  @return         :   void
     * 
    **/ 
    public static void updateGPAWithInteractionsProductGradeAverage(List<Syndicated_Study__c> newSyndicatedStudy, Map<Id,Syndicated_Study__c> oldMapSyndicatedStudies) {
        
        //NPD Record type
        Map<Id, RecordType> mapNPDRecordType = new Map<Id, RecordType>([Select Id FROM RecordType 
                                                                            WHERE sobjectType = 'Syndicated_Study__c' AND DeveloperName = 'NPD' AND IsActive = true]);
                                                                            
        //Proceed with below logic only if record type exists
        if(mapNPDRecordType != null && mapNPDRecordType.values().size() > 0) {
            
            //Map to hold the syndicated study records
            Map<Id, Syndicated_Study__c> mapSyndicatedStudies = new Map<Id, Syndicated_Study__c>();
        
            //Loop through new reocrds
            for(Syndicated_Study__c ss : newSyndicatedStudy) {
                //Making validations over record and then accordingly populating set with eligible records Id value
                if(ss.RecordTypeId != null && mapNPDRecordType.containsKey(ss.RecordTypeId))
                     mapSyndicatedStudies.put(ss.Id, new Syndicated_Study__c(Id=ss.Id, GPA__c = '0.0'));
            }
            
            //Map to hold "Product Concept Grade" field value combinations
            Map<String, Decimal> mapProductConceptGrades = new Map<String, Decimal>{'A'=>4.0,'B'=>3.0,'C'=>2.0};
        
            //Map to hold the Syndicated Study record Id as key and Count of eligible interaction records as value
            Map<Id, Integer> mapSyndicatedStudyWithInteractionsCount = new Map<Id, Integer>(); 
        
            //Checking if we are having any record to proceed with and if yes, then perform the below written logic
            if(mapSyndicatedStudies.values().size() > 0) {
                
                //Loop through Syndicated Research Interactions records associated with Syndicated Study records
                for(Syndicated_Research_Interaction__c sS : [Select ID, Product_Concept_Grade__c, Primary_Study__c
                                                                FROM Syndicated_Research_Interaction__c 
                                                                WHERE Primary_Study__c != null AND Primary_Study__c IN : mapSyndicatedStudies.keySet()]) {
                    //Checking record for its parent record presence
                    if(!String.isBlank(sS.Product_Concept_Grade__c)) {
                        if(mapSyndicatedStudies.get(sS.Primary_Study__c) != null && mapProductConceptGrades.get(sS.Product_Concept_Grade__c) != null) {
                            //Populating map with corresponding field values
                            if(mapSyndicatedStudyWithInteractionsCount.containsKey(sS.Primary_Study__c)) {
                                mapSyndicatedStudyWithInteractionsCount.put(sS.Primary_Study__c, (mapSyndicatedStudyWithInteractionsCount.get(sS.Primary_Study__c) + 1));
                                Decimal sumCount = Decimal.valueOf(mapSyndicatedStudies.get(sS.Primary_Study__c).GPA__c) + mapProductConceptGrades.get(sS.Product_Concept_Grade__c);
                                mapSyndicatedStudies.put(sS.Primary_Study__c, new Syndicated_Study__c(Id=sS.Primary_Study__c, GPA__c = String.valueOf(sumCount)));
                            } else {
                                mapSyndicatedStudyWithInteractionsCount.put(sS.Primary_Study__c , 1);
                                Decimal sumCnt = Decimal.valueOf(mapSyndicatedStudies.get(sS.Primary_Study__c).GPA__c) + mapProductConceptGrades.get(sS.Product_Concept_Grade__c);
                                mapSyndicatedStudies.put(sS.Primary_Study__c, new Syndicated_Study__c(Id=sS.Primary_Study__c, GPA__c = String.valueOf(sumCnt)));
                            }
                        } 
                    }                                               
                }
                
                //Debugging for the map values
                System.debug('@@@@@ mapSyndicatedStudies ' + mapSyndicatedStudies);
                System.debug('@@@@@ mapSyndicatedStudyWithInteractionsCount ' + mapSyndicatedStudyWithInteractionsCount);
            
                //Workaround for performing average on the GPA field value
                for(Id ssId : mapSyndicatedStudyWithInteractionsCount.keySet()) {
                    
                    //Checking for null value
                    if(mapSyndicatedStudies.get(ssId) != null) {
                        
                        //Getting GPA Sum Count value for the Syndicated Study Record calculated previosuly on the basis of interaction records
                        Decimal productGradeSum = Decimal.valueOf(mapSyndicatedStudies.get(ssId).GPA__c);
                        Integer interactionRecordCount = mapSyndicatedStudyWithInteractionsCount.get(mapSyndicatedStudies.get(ssId).Id);
                        if(interactionRecordCount > 0) {
                            Decimal averageGPAValue =  (productGradeSum/Decimal.valueOf(interactionRecordCount));
                            averageGPAValue = averageGPAValue.SetScale(2);
                            mapSyndicatedStudies.put(mapSyndicatedStudies.get(ssId).Id, new Syndicated_Study__c(Id=mapSyndicatedStudies.get(ssId).Id, GPA__c = String.valueOf(averageGPAValue)));
                        }
                    }   
                }
                
                //Debugging for the value
                System.debug('@@@@@ mapSyndicatedStudies after average ' + mapSyndicatedStudies);
            }
            
            //Loop through new records
            for(Syndicated_Study__c synsdy : newSyndicatedStudy) {
                //Checking for value in the map corresponding to the key value
                if(mapSyndicatedStudies.containsKey(synsdy.Id))     
                    synsdy.GPA__c = mapSyndicatedStudies.get(synsdy.Id).GPA__c;
                
                if(synsdy.GPA__c == '0.0')
                    synsdy.GPA__c = '';    
            } 
        }
    }
}