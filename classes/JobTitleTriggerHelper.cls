/**
 *  Description     :   Helper class for Trigger_JobTitle trigger.
 *
 *  Created By      :   Subhash Garhwal 
 *
 *  Created Date    :   8/21/2015
 *
 *  Revision Logs   :   V_1.0 - Created - CR-20150825-9182						
 *                    
 **/
public with sharing class JobTitleTriggerHelper {
	
/**
 *  @description    :   Method to check Job Title name. The Name value must be unique across all Job Title
 *
 *  @args           :   List<Job_Title__c>, Map<Id, Job_Title__c>
 *
 *  @return         :   void
 *
 **/
    public static void validateJobTitle(List<Job_Title__c> JobTitles, Map<Id, Job_Title__c> mapOldJobTitles) {
        
        //Set to hold Job Title name
        Set<String> setJTName = new Set<String>();

        //Loop through the Job Titles
        for(Job_Title__c jT : JobTitles) {
            
            //Check appropriate condition
            if(mapOldJobTitles == null || jT.Name != mapOldJobTitles.get(jT.Id).Name) {
                
                //Check Job Title name in set
                if(setJTName.contains(jT.Name))
                    throw new CustomException(Label.DUPLICATE_JOB_TITLE);
                
                //Add Job Title name in set
                setJTName.add(jT.Name);
            }
                
        }

        //Query through the Job Titles
        List<Job_Title__c> jTList = [Select Id, Name From Job_Title__c Where Name IN : setJTName LIMIT 1];
        
        //Check for list size
        if(jTList.size() > 0) {
            
            //Add Duplicate record error
            throw new CustomException(Label.DUPLICATE_JOB_TITLE);
        }
    }	
}