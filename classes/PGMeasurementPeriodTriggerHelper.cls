/**
 *  Description     :  Helper class for Trigger_PGMeasurementPeriod trigger.
 *
 *  Created By      :  Subhash Garhwal
 *
 *  Created Date    :  10/31/2015
 *
 *  Revision Logs   :   V_1.0 - Created - CR-20150729-9114
 *
 **/
public without sharing class PGMeasurementPeriodTriggerHelper {
    
    /**
     *  @description    :   This method is used to prevent duplicates.
     *                      A PGMP record must be uniquely identified as 
     *                      •   Personal Goal
     *                      •   Measurement Date
     *
     *  @args           :   List<Personal_Goal_Measurement_Period__c>, Map<Id, Personal_Goal_Measurement_Period__c>
     *
     *  @return         :   void
     *
     **/
    public static void preventDuplicates(List<Personal_Goal_Measurement_Period__c> pGMPeriods, Map<Id, Personal_Goal_Measurement_Period__c> mapOldPGMPeriods) {
        
        //Set to hold the Unique indentifier (Personal Goal Id and Measurement Date)
        Set<String> setUniqueIdentifiers = new Set<String>();
        
        //Set to hold the Personal goal Id
        Set<Id> setPGIds = new Set<Id>();
        
        //Set to hold the Measurement Date
        Set<Date> setMeasurementDates = new Set<Date>();
        
        //Loop through the Personal_Goal_Measurement_Period__c
        for(Personal_Goal_Measurement_Period__c pGMP : pGMPeriods) {
            
            //Check for Personal goal and Measurement Date
            if(mapOldPGMPeriods == null || pGMP.Personal_Goal__c != mapOldPGMPeriods.get(pGMP.Id).Personal_Goal__c
                || pGMP.Measurement_Date__c != mapOldPGMPeriods.get(pGMP.Id).Measurement_Date__c) {
                    
                //Add Personal Goal in set
                setPGIds.add(pGMP.Personal_Goal__c);
                
                //Add Measurement Date in set
                setMeasurementDates.add(pGMP.Measurement_Date__c);
                
                //Unique Indentifier
                String uK = pGMP.Personal_Goal__c + '-' + pGMP.Measurement_Date__c;
                
                //Check Unique Indentifier in set
                if(setUniqueIdentifiers.contains(uK))
                    throw new CustomException(Label.ERROR_UNIQUENESS_PGMP);
                
                //Add Unique Indentifier in set
                setUniqueIdentifiers.add(uK);
            }
        }
        
        //Check for Personal goal set size
        if(setPGIds.size() > 0) {
            
            //Loop throuh the PGMPs
            for(Personal_Goal_Measurement_Period__c pGMP : [Select Id, Personal_Goal__c, Measurement_Date__c From Personal_Goal_Measurement_Period__c
                                                                       Where Personal_Goal__c IN : setPGIds
                                                                       AND Measurement_Date__c IN : setMeasurementDates AND Id NOT IN : pGMPeriods]) {
                
                //String combination
                String uK = pGMP.Personal_Goal__c + '-' + pGMP.Measurement_Date__c;
                
                //Check the date in set
                if(setUniqueIdentifiers.contains(uK))
                    throw new CustomException(Label.ERROR_UNIQUENESS_PGMP); 
            }
        }
    }
}