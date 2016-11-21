/**
 *  Description     :  Helper class for Trigger_StandardGoalDetail trigger.
 *
 *  Created By      :  Subhash Garhwal
 *
 *  Created Date    :  08/25/2015
 *
 *  Revision Logs   :   V_1.0 - Created - Subhash Garhwal - CR-20150729-9114
 *                  :   V_1.1 - Modified - Rajeev Jain - CR-20160307-9680 - Added new method rePopulateValueTypeBasedValues                       
 *
 **/
public without sharing class StandardGoalDetailTriggerHelper {
    
    //Flag to control the flow to Period Dates method
    public static Boolean isExecutePeriodsLogic = true;
    
    /**
     *  @description    :   This method is used to update the start and end date for GTD with the Min and Max dates of child Pacings
     *
     *  @args           :   List<Standard_Goal_Detail__c>, Map<Id, Standard_Goal_Detail__c>
     *
     *  @return         :   void
     *
     **/
     public static void rePopulateValueTypeBasedValues(List<Standard_Goal_Detail__c> goalTempDetails, Map<Id, Standard_Goal_Detail__c> mapOldGTDetails){
        
        //Loop over new GTD
        for(Standard_Goal_Detail__c gTD : goalTempDetails) {
            
            //Based on what valye Type is populated, Blank out other field
            if(gTD.Value_Type__c == 'Amount'){
                gTD.Count__c = null;
                gTD.Percent__c = null;
            }else if(gTD.Value_Type__c == 'Count'){
                gTD.Amount__c = null;
                gTD.Percent__c = null;
            }else if(gTD.Value_Type__c == 'Percent'){
                gTD.Count__c = null;
                gTD.Amount__c = null;
            }
        }
     }
    /**
     *  @description    :   This method is used to update the start and end date for GTD with the Min and Max dates of child Pacings
     *
     *  @args           :   List<Standard_Goal_Detail__c>, Map<Id, Standard_Goal_Detail__c>
     *
     *  @return         :   void
     *
     **/
    public static void validatePeriods(List<Standard_Goal_Detail__c> goalTempDetails, Map<Id, Standard_Goal_Detail__c> mapOldGTDetails) {
        
        //List to hold the Goal Template detials
        List<Standard_Goal_Detail__c> goalTemplateDetails = new List<Standard_Goal_Detail__c>();
        
        //Loop through the GTD
        for(Standard_Goal_Detail__c gTD : goalTempDetails) {
            
            //Check for Period start and end date
            if(gTD.Period_Start__c != mapOldGTDetails.get(gTD.Id).Period_Start__c || gTD.Period_End__c != mapOldGTDetails.get(gTD.Id).Period_End__c)
                goalTemplateDetails.add(gTD);   
        }
        
        //Check for list size
        if(goalTemplateDetails.size() > 0)
            validatePeriods(goalTemplateDetails);   
    }
    
    /**
     *  @description    :   This method is used to update the start and end date for GTD with the Min and Max dates of child Pacings
     *
     *  @args           :   List<Standard_Goal_Detail__c>
     *
     *  @return         :   void
     *
     **/
    public static void validatePeriods(List<Standard_Goal_Detail__c> goalTempDetails) {
        
        //Map to hold the Goal Template Details
        Map<Id, Standard_Goal_Detail__c> mapGoalTempDetails = new Map<Id, Standard_Goal_Detail__c>();
        
        //Aggregate Query on Std Goal Detail Pacings to get Min and Max Start and End Date
        for(AggregateResult aR : [Select Standard_Goal_Detail__c sGDId, MIN(Period_Start__c) pS, MAX(Period_End__c) pE
                                  From Standard_Goal_Detail_Pacing__c Where Standard_Goal_Detail__c IN : goalTempDetails
                                  AND Standard_Goal_Detail__r.Target_Type__c =: ISSPConstants.STANDARD_GOAL_DETAIL_TARGET_TYPE_PACED 
                                  GROUP BY Standard_Goal_Detail__c]) {
            
            //Standard Goal Detail Id
            Id stdGDetailId = Id.valueOf(String.valueOf(aR.get('sGDId')));
            
            //Variables to hold the min and max dates
            Date minDate;
            Date maxDate;
            
            //Check for start date
            if(aR.get('pS') != null)
                minDate = Date.valueOf(aR.get('pS'));
            
            //Check for end date
            if(aR.get('pE') != null)
                maxDate = Date.valueOf(aR.get('pE'));
            
            //Populate map with total
            mapGoalTempDetails.put(stdGDetailId, new Standard_Goal_Detail__c(Id = stdGDetailId, Period_Start__c = minDate, Period_End__c = maxDate)); 
        }
        
        //Check for map size
        if(mapGoalTempDetails.size() > 0) {
            
            //Set flag to false
            isExecutePeriodsLogic = false;
            
            //Update goal template detial
            update mapGoalTempDetails.values();
            
            //Set flag to false
            isExecutePeriodsLogic = true;
        }
    }
}