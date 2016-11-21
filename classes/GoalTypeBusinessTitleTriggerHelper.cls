/**
 *  Description     :  Helper class for Trigger_GoalTypeBusinessTitle trigger.
 *
 *  Created By      :  Subhash Garhwal
 *
 *  Created Date    :  09/11/2015
 *
 *  Revision Logs   :   V_1.0 - Created - CR-20150729-9114
 *                      
 **/
public without sharing class GoalTypeBusinessTitleTriggerHelper {
    
    /**
     *  @description    :   This method is to validate the data before inserting into database. If there is any Duplicate, display error message to user.
     *
     *  @args           :   List<Goal_Type_Business_Title__c>, Map<Id, Goal_Type_Business_Title__c>
     *
     *  @return         :   void
     *
     **/
    public static void validateGTBTs(List<Goal_Type_Business_Title__c> gTBusinessTitles, Map<Id, Goal_Type_Business_Title__c> mapGTBT) {
        
        //Set to hold Id of Goal type and value types
        Set<String> setGTWithVT = new Set<String>();
        
        //Set to hold Goal Type Ids
        Set<Id> setGTIds = new Set<Id>();
        
        //Set to hold Business Title Ids
        Set<Id> setBTIds = new Set<Id>();
        
        //Loop through Goal Type Business Title
        for(Goal_Type_Business_Title__c gTBT : gTBusinessTitles) {
            
            //Check Insert and Update case
            if(mapGTBT == null || gTBT.Goal_Type__c != mapGTBT.get(gTBT.Id).Goal_Type__c || gTBT.Business_Title__c != mapGTBT.get(gTBT.Id).Business_Title__c)   {
                
                //Unique Key with Goal type and Value type
                String uniqueKey = gTBT.Goal_Type__c + '-' + gTBT.Business_Title__c;
                
                //Check unique key in map
                if(setGTWithVT.contains(uniqueKey)) 
                    throw new CustomException(Label.ERROR_UNIQUENESS_GTBT);
                
                //Add Goal Type Id in set   
                setGTIds.add(gTBT.Goal_Type__c);
                
                //Add Business Title Id in set
                setBTIds.add(gTBT.Business_Title__c);
                    
                //Add Goal Type Business Title in map
                setGTWithVT.add(uniqueKey);
            }
        }
        
        //Check map and set size
        if(setGTIds.size() > 0 && setGTWithVT.size() > 0 ) {
        
            //Query through Goal Type Business Title
            for(Goal_Type_Business_Title__c gTBT : [Select Id, Business_Title__c, Goal_Type__c from Goal_Type_Business_Title__c where 
                                                  Goal_Type__c IN : setGTIds AND Business_Title__c IN : setBTIds AND Id NOT IN : gTBusinessTitles]) {
                                                      
            //Unique Key
            String uniqueKey = gTBT.Goal_Type__c + '-' + gTBT.Business_Title__c;
            
            //Check unique key in map
            if(setGTWithVT.contains(uniqueKey)) 
                throw new CustomException(Label.ERROR_UNIQUENESS_GTBT);
            }
        }
    }
}