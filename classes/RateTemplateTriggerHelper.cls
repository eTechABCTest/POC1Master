/**
 *  Description     :   Helper class for Trigger_RateTemplate trigger.
 *
 *  Created By      :   Subhash Garhwal 
 *
 *  Created Date    :   10/7/2015
 *
 *  Revision Logs   :   V_1.0 - Created - CR-20150729-9114
 **/
public with sharing class RateTemplateTriggerHelper {
	
	/**
     *	@description	:	This method is used to Prevent Duplicate Name of Rate Template
     *
     *	@args			:	List<Rate_Template__c>
     *
     *	@return			:	void
     *
     **/
     public static void validateRateTemplates(List<Rate_Template__c> rateTemplates ,Map<Id, Rate_Template__c> mapOldRateTemplates){
     	
     	//Set to hold rate template name
     	Set<String> setRTName = new Set<String>();
     	
     	//Loop Through Rate Template
     	for(Rate_Template__c rT : rateTemplates){
     		
     		//Check For Condition
     		if(mapOldRateTemplates == null || rT.Name != mapOldRateTemplates.get(rT.Id).Name){
     			
     			//Check For Duplicate name Or show error
     			if(setRTName.contains(rT.Name))
     				throw new CustomException(Label.DUPLICATE_RATE_TEMPLATE);
     			
     			//Add name in set
     			setRTName.add(rT.Name);	
     		}
     	}
     	
     	//Query Throught Rate Template
     	List<Rate_Template__c> rTRecord = [Select Id, Name From Rate_Template__c Where Name IN : setRTName AND Id NOT IN : rateTemplates LIMIT 1];
     	
     	//Check Size
     	if(rTRecord.size() > 0)
     		throw new CustomException(Label.DUPLICATE_RATE_TEMPLATE);
     		
     }
     
     /**
     *	@description	:	This method is used to Prevent Deletion of record if it's use in personal goal 
     *
     *	@args			:	List<Rate_Template__c>
     *
     *	@return			:	void 
     * 
     **/
     public static void validateBeforeDelete(List<Rate_Template__c> rateTemplates){
     	
     	//Query Through Personal Goal
     	List<Personal_Goal__c> PGRecords = [Select Id, Name, Rate_Template__c From Personal_Goal__c Where Rate_Template__c != null AND Rate_Template__c IN : rateTemplates LIMIT 1];
     	
     	If(PGRecords.size() > 0){
     		throw new CustomException(label.RATE_TEMPLATE_IN_USE);
     	}
     }
}