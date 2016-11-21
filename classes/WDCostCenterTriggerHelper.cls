/**
 *  Description     :  Helper class for Trigger_CostCenter1.
 *
 *  Created By      :  Subhash Garhwal
 *
 *  Created Date    :  12/19/2015
 *
 *  Revision Logs   :  V_1.0 - Created - CR-20151123-9412 
 *
 **/
public without sharing class WDCostCenterTriggerHelper  {
    
    /**
     *  @description    :   This method is used to prevent duplicates of same Name.                     
     *
     *  @args           :   List<WD_Cost_Center__c>, Map<Id, WD_Cost_Center__c>
     *
     *  @return         :   void
     *
     **/
     
   public static void preventDuplicates(List<WD_Cost_Center__c> wDcostCenters, Map<Id, WD_Cost_Center__c> mapOldWDCostCenter) {
        
        //Set to hold the Cost Center Name of new records
        Set<String> setCCName = new Set<String>();
        
        //Loop through the WD_Cost_Center__c
        for(WD_Cost_Center__c wDCC : wDcostCenters) {
            
            //Check for insert and  update Case
            if(mapOldWDCostCenter == null || wDCC.Name != mapOldWDCostCenter.get(wDCC.Id).Name) {
                
                //Check the duplicacy in the inserting or updating the records
                if(setCCName.contains(wDCC.Name))
                    throw new CustomException(Label.ERROR_UNIQUENESS_WDCC);   
                
                // Add records in set
                setCCName.add(wDCC.Name); 
            }
        }
        
        ///Check the size of the set
        if(setCCName.size() > 0){
            
            //Qurey through the existing records which are present in set
            List<WD_Cost_Center__c> cCenterList = [SELECT Id, Name FROM WD_Cost_Center__c WHERE Name IN : setCCName
                                                                 AND Id NOT IN : wDcostCenters LIMIT 1];
            
            //Check the size of Set
            if(cCenterList.size() > 0)
                throw new CustomException(Label.ERROR_UNIQUENESS_WDCC);
        }       
    }
}