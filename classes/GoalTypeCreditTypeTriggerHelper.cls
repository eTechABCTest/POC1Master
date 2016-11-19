/**
 *  Description     :  Helper class for Trigger_GoalTypeCreditType trigger.
 *
 *  Created By      :  Subhash Garhwal
 *
 *  Created Date    :  12/02/2015
 *
 *  Revision Logs   :   V_1.0 - Created - CR-20151120-9407
 *
 **/
public with sharing class GoalTypeCreditTypeTriggerHelper {
    /**
     *  @description    :   This method is used to prevent duplicates.
     *                      A GTCT record must be uniquely identified as 
     *                      ? Goal Type
     *                      ? Value Type
     *
     *  @args           :   List<Goal_Type_Credit_Type__c>, Map<Id, Goal_Type_Credit_Type__c>
     *
     *  @return         :   void
     *
     **/
     public static void preventDuplicates(List<Goal_Type_Credit_Type__c> gTCreditTypes, Map<Id, Goal_Type_Credit_Type__c> mapOldgGTCreditType) {
        
        //Set to hold the Unique indentifier (Goal_Type_Credit_Type__c)
        Set<String> setUniqueIdentifiers = new Set<String>();
        
        //Set to hold the Goal Type Id
        Set<Id> setGTIds = new Set<Id>();
        
        //Set to hold the Value Type Id
        Set<Id> setVTIds = new Set<Id>();
        
        //Loop through the Goal_Type_Credit_Type__c
        for(Goal_Type_Credit_Type__c gTCT : gTCreditTypes) {
            
            //Check for Goal Type and Value Types
            if(mapOldgGTCreditType == null || gTCT.Goal_Type__c != mapOldgGTCreditType.get(gTCT.Id).Goal_Type__c
                || gTCT.Credit_Type__c != mapOldgGTCreditType.get(gTCT.Id).Credit_Type__c) {
                    
                //Add  Goal Types in set
                setGTIds.add(gTCT.Goal_Type__c);
                
                //Add Value Types in set
                setVTIds.add(gTCT.Credit_Type__c);
                
                //Unique Indentifier
                String uK = gTCT.Goal_Type__c + '-' + gTCT.Credit_Type__c;
                
                //Check Unique Indentifier in set
                if(setUniqueIdentifiers.contains(uK))
                    throw new CustomException(Label.ERROR_UNIQUENESS_GTCT);
                
                //Add Unique Indentifier in set
                setUniqueIdentifiers.add(uK);
            }
        }
        //Check for GT set size
        if(setGTIds.size() > 0 && setVTIds.size() > 0) {
            
            //Query through the Goal_Type_Credit_Type__c
            List<Goal_Type_Credit_Type__c> gTCTypes = [Select Id From Goal_Type_Credit_Type__c
                                                    Where Goal_Type__c IN : setGTIds AND Credit_Type__c IN : setVTIds
                                                          AND Id NOT IN : gTCreditTypes LIMIT 1];
            
            if(gTCTypes.size() > 0)
                throw new CustomException(Label.ERROR_UNIQUENESS_GTCT);
        }
    }
}