/**
 *  Description     :  Helper class for Trigger_GTDMeasurementPeriod trigger.
 *
 *  Created By      :  Subhash Garhwal
 *
 *  Created Date    :  11/25/2015
 *
 *  Revision Logs   :   V_1.0 - Created - CR-20151120-9407
 *
 **/
public without sharing class GTDMeasurementPeriodTriggerHelper {
    /**
     *  @description    :   This method is used to prevent duplicates.
     *                      A GTDMD record must be uniquely identified as 
     *                      ?   Goal Template Detail
     *                      ?   Measurement Date
     *
     *  @args           :   List<Goal_Template_Detail_Measurement_Date__c>, Map<Id, Goal_Template_Detail_Measurement_Date__c>
     *
     *  @return         :   void
     *
     **/
     public static void preventDuplicates(List<Goal_Template_Detail_Measurement_Period__c> gTDMPeriods, Map<Id, Goal_Template_Detail_Measurement_Period__c> mapOldgTDMPeriods) {
        
        //Set to hold the Unique indentifier (Goal Template Detail Id and Measurement Date)
        Set<String> setUniqueIdentifiers = new Set<String>();
        
        //Set to hold the Goal Template Detail Id
        Set<Id> setGTDIds = new Set<Id>();
        
        //Set to hold the Measurement Date
        Set<Date> setMeasurementDates = new Set<Date>();
        
        //Loop through the Goal_Template_Detail_Measurement_Date__c
        for(Goal_Template_Detail_Measurement_Period__c gTDMP : gTDMPeriods) {
            
            //Check for Personal goal and Measurement Dates
            if(mapOldgTDMPeriods == null || gTDMP.Goal_Template_Detail__c != mapOldgTDMPeriods.get(gTDMP.Id).Goal_Template_Detail__c
                || gTDMP.Measurement_Date__c != mapOldgTDMPeriods.get(gTDMP.Id).Measurement_Date__c) {
                    
                //Add Goal Template Detail in set
                setGTDIds.add(gTDMP.Goal_Template_Detail__c);
                
                //Add Measurement Date in set
                setMeasurementDates.add(gTDMP.Measurement_Date__c);
                
                //Unique Indentifier
                String uK = gTDMP.Goal_Template_Detail__c + '-' + gTDMP.Measurement_Date__c;
                
                //Check Unique Indentifier in set
                if(setUniqueIdentifiers.contains(uK))
                    throw new CustomException(Label.ERROR_UNIQUENESS_GTDMP);
                
                //Add Unique Indentifier in set
                setUniqueIdentifiers.add(uK);
            }
     	}
     	
     	//Check for GTD set size
		if(setGTDIds.size() > 0) {
			
			//Loop throuh the GTDMPs
      		for(Goal_Template_Detail_Measurement_Period__c gTDMP : [Select Id, Goal_Template_Detail__c, Measurement_Date__c From Goal_Template_Detail_Measurement_Period__c
                                     Where Goal_Template_Detail__c IN : setGTDIds
                                     AND Measurement_Date__c IN : setMeasurementDates AND Id NOT IN : gTDMPeriods]) {
        
	        	//String combination
	        	String uK = gTDMP.Goal_Template_Detail__c + '-' + gTDMP.Measurement_Date__c;
	        
	        	//Check the date in set
	        	if(setUniqueIdentifiers.contains(uK))
	          	throw new CustomException(Label.ERROR_UNIQUENESS_GTDMP);  
      		}
		}
	}
}