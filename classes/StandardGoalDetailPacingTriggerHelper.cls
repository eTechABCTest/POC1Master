/**
 *  Description     :  Helper class for Trigger_StandardGoalDetailPacing trigger.
 *
 *  Created By      :  Subhash Garhwal
 *
 *  Created Date    :  08/12/2015
 *
 *  Revision Logs   :   V_1.0 - Created - Subhash Garhwal - CR-20150729-9114  
 *                      V_1.1 - Modified - Subhash Garhwal - 01/05/2016 - CR-20151217-9469 - ISSP Deployment C.     
 *
 **/
public without sharing class StandardGoalDetailPacingTriggerHelper {
    
    /**
     *  @description    :   This method is used to validate Standard Goal Detail Pacing
     *
     *  @args           :   List<Standard_Goal_Detail_Pacing__c>, Map<Id, Standard_Goal_Detail_Pacing__c>
     *
     *  @return         :   void
     *
     **/
    public static void validateStandardGDPacing(List<Standard_Goal_Detail_Pacing__c> stdGDPacings, Map<Id, Standard_Goal_Detail_Pacing__c> mapSGDPacings) {
        
        //Set to hold the std goal detail ids
        Set<Id> setSGDIds = new Set<Id>();
        
        //List of wrapper class
        List<GTDPacingWrapper> gTDPsWrapper = new List<GTDPacingWrapper>();
        
        //Loop through the Pacings and populate set
        for(Standard_Goal_Detail_Pacing__c sGDP : stdGDPacings) {
            
            //Add GTDP in wrapper
            gTDPsWrapper.add(new GTDPacingWrapper(sGDP));
            
            //Add GTD in set
            setSGDIds.add(sGDP.Standard_Goal_Detail__c);
        }
            
        //Check for SGD Set
        if(setSGDIds.size() > 0) {
            
            //Short list
            gTDPsWrapper.sort();
            
            //Query through the Std goal detail
            //This map is used to check std goal detail's target type
            Map<Id, Standard_Goal_Detail__c> mapStdGDetails = new Map<Id, Standard_Goal_Detail__c>([Select Id, Target_Type__c From Standard_Goal_Detail__c
                                                                                                    Where Id IN : setSGDIds]); 
        
            //Map to hold Std Goal Detail Id with list of Std Goal Detail Pacing
            Map<String, List<Standard_Goal_Detail_Pacing__c>> mapSGDIdWithSGDPacings = new Map<String, List<Standard_Goal_Detail_Pacing__c>>();
            
            //Loop through the Std Goal Detail Pacings
            for(GTDPacingWrapper sGDP : gTDPsWrapper) {
                
                //Check for appropriate condition to fire trigger
                if((!mapStdGDetails.containsKey(sGDP.gTDP.Standard_Goal_Detail__c) || mapStdGDetails.get(sGDP.gTDP.Standard_Goal_Detail__c).Target_Type__c == ISSPConstants.STANDARD_GOAL_DETAIL_TARGET_TYPE_PACED)
                    && (mapSGDPacings == null || sGDP.gTDP.Period_Start__c != mapSGDPacings.get(sGDP.gTDP.Id).Period_Start__c 
                        || sGDP.gTDP.Period_End__c != mapSGDPacings.get(sGDP.gTDP.Id).Period_End__c)) {
                    
                    //Check Std Goal Detail Id
                    if(mapSGDIdWithSGDPacings.containsKey(sGDP.gTDP.Standard_Goal_Detail__c)) {
                        
                        //Variable to check for continus date
                        Boolean isContinuousDate = false;
                        
                        //Loop through Std Goal detail Pacings
                        for(Standard_Goal_Detail_Pacing__c exSGDP : mapSGDIdWithSGDPacings.get(sGDP.gTDP.Standard_Goal_Detail__c)) {
                            
                            //Check for current records Start date and end date, if conflicting with any existing one, then throw exception
                            if((sGDP.gTDP.Period_End__c == null && exSGDP.Period_End__c == null)
                                || (sGDP.gTDP.Period_End__c != null && exSGDP.Period_End__c == null && sGDP.gTDP.Period_End__c >= exSGDP.Period_Start__c)
                                || (sGDP.gTDP.Period_End__c == null && exSGDP.Period_End__c != null && sGDP.gTDP.Period_Start__c <= exSGDP.Period_End__c)
                                || (sGDP.gTDP.Period_Start__c <= exSGDP.Period_End__c && sGDP.gTDP.Period_Start__c >= exSGDP.Period_Start__c)
                                || (sGDP.gTDP.Period_End__c >= exSGDP.Period_Start__c && sGDP.gTDP.Period_End__c <= exSGDP.Period_End__c)
                                || (exSGDP.Period_Start__c <= sGDP.gTDP.Period_End__c && exSGDP.Period_Start__c >= sGDP.gTDP.Period_Start__c)
                                || (exSGDP.Period_End__c >= sGDP.gTDP.Period_Start__c && exSGDP.Period_End__c <= sGDP.gTDP.Period_End__c)) {
                                
                                //Add Error
                                throw new CustomException(Label.ERROR_UNIQUENESS_SGDP);
                            
                            } else {
                                
                                //Check for Continuous date
                                if(sGDP.gTDP.Period_Start__c == exSGDP.Period_End__c.addDays(1) || sGDP.gTDP.Period_End__c == exSGDP.Period_Start__c.addDays(-1)) {
                                    
                                    //Set Flag
                                    isContinuousDate = true;
                                }
                            }
                        }
                        
                        //Check for Continuous date 
                        if(!isContinuousDate)
                            throw new CustomException(Label.ERROR_CONTINUOUS_SGDP);
                        
                        //Add Std Goal Detail Pacing into map
                        mapSGDIdWithSGDPacings.get(sGDP.gTDP.Standard_Goal_Detail__c).add(sGDP.gTDP);
                    } else
                        mapSGDIdWithSGDPacings.put(sGDP.gTDP.Standard_Goal_Detail__c, new List<Standard_Goal_Detail_Pacing__c> {sGDP.gTDP});
                }
            }
            
            //Check for map size
            if(mapSGDIdWithSGDPacings.size() > 0) {
                
                //Map to hold Std Goal Id with list of Existing SGDP
                Map<String, List<Standard_Goal_Detail_Pacing__c>> mapSGDIdWithESGDPs = new Map<String, List<Standard_Goal_Detail_Pacing__c>>();
                
                //Query through Standard goal detail pacing
                for(Standard_Goal_Detail_Pacing__c sGDP : [Select Id, Period_End__c, Period_Start__c, Standard_Goal_Detail__c From Standard_Goal_Detail_Pacing__c
                                                                  Where Standard_Goal_Detail__c IN : mapSGDIdWithSGDPacings.keySet()
                                                                  AND Id NOT IN : stdGDPacings]) {
                    
                    //Check for map
                    if(!mapSGDIdWithESGDPs.containsKey(sGDP.Standard_Goal_Detail__c))
                        mapSGDIdWithESGDPs.put(sGDP.Standard_Goal_Detail__c, new List<Standard_Goal_Detail_Pacing__c>());
                    
                    //Populate map
                    mapSGDIdWithESGDPs.get(sGDP.Standard_Goal_Detail__c).add(sGDP);                                                     
                }
                
                //Check for map
                if(mapSGDIdWithESGDPs.size() > 0) {
                
                    //Loop through map key set (Std Goal Detail Ids)
                    for(String sGDId : mapSGDIdWithSGDPacings.keySet()) {
                    
                        //Query through Standard goal detail pacing
                        for(Standard_Goal_Detail_Pacing__c sGDP : mapSGDIdWithSGDPacings.get(sGDId)) {
                            
                            //Check if map contains Std Goal Detail Id
                            if(mapSGDIdWithESGDPs.containsKey(sGDId)) {
                                
                                //Variable to check for continus date
                                Boolean isContinuousDate = false;
                                
                                //Loop through Std Goal detail Pacings
                                for(Standard_Goal_Detail_Pacing__c exSGDP : mapSGDIdWithESGDPs.get(sGDId)) {
                                    
                                    //Check for current records Start date and end date, if conflicting with any existing one, then throw exception
                                    if((sGDP.Period_End__c == null && exSGDP.Period_End__c == null)
                                        || (sGDP.Period_End__c != null && exSGDP.Period_End__c == null && sGDP.Period_End__c >= exSGDP.Period_Start__c)
                                        || (sGDP.Period_End__c == null && exSGDP.Period_End__c != null && sGDP.Period_Start__c <= exSGDP.Period_End__c)
                                        || (sGDP.Period_Start__c <= exSGDP.Period_End__c && sGDP.Period_Start__c >= exSGDP.Period_Start__c)
                                        || (sGDP.Period_End__c >= exSGDP.Period_Start__c && sGDP.Period_End__c <= exSGDP.Period_End__c)
                                        || (exSGDP.Period_Start__c <= sGDP.Period_End__c && exSGDP.Period_Start__c >= sGDP.Period_Start__c)
                                        || (exSGDP.Period_End__c >= sGDP.Period_Start__c && exSGDP.Period_End__c <= sGDP.Period_End__c)) {
                                        
                                        //Add Error
                                        throw new CustomException(Label.ERROR_UNIQUENESS_SGDP);
                                    
                                    } else {
                                        
                                        //Check for Continuous date
                                        if(sGDP.Period_Start__c == exSGDP.Period_End__c.addDays(1) || sGDP.Period_End__c == exSGDP.Period_Start__c.addDays(-1)) {
                                            
                                            //Set flag
                                            isContinuousDate = true;
                                        }   
                                    }
                                }
                                
                                //Check for Continuous date 
                                if(!isContinuousDate)
                                    throw new CustomException(Label.ERROR_CONTINUOUS_SGDP);
                                    
                                //Add new Pacing in map
                                mapSGDIdWithESGDPs.get(sGDId).add(sGDP);
                            }                                                   
                        }
                    }
                }
            }
        }       
    }
    /**
     *  @description    :   This method is used to validate the Parent GTD's Period
     *
     *  @args           :   List<Standard_Goal_Detail_Pacing__c>, Map<Id, Standard_Goal_Detail_Pacing__c>
     *
     *  @return         :   void
     *
     **/
    public static void valudateGTDPeriods(List<Standard_Goal_Detail_Pacing__c> goalDetailPacings, Map<Id, Standard_Goal_Detail_Pacing__c> mapOldGTDPacings) {
        
        //Set to hold the Goal Template Detail Ids
        Set<Id> setGTDIds = new Set<Id>();
        
        //Loop through the pacings
        for(Standard_Goal_Detail_Pacing__c gTDP : goalDetailPacings != null ? goalDetailPacings : mapOldGTDPacings.values()) {
            
            //Insert Case
            if(goalDetailPacings == null || mapOldGTDPacings == null)
                setGTDIds.add(gTDP.Standard_Goal_Detail__c);
            
            //Update Case
            if(goalDetailPacings != null && mapOldGTDPacings != null && (gTDP.Period_Start__c != mapOldGTDPacings.get(gTDP.Id).Period_Start__c
                || gTDP.Period_End__c != mapOldGTDPacings.get(gTDP.Id).Period_End__c))
                setGTDIds.add(gTDP.Standard_Goal_Detail__c);        
        }
        
        //Check for set size and call the goal template detail method to validate the Periods
        if(setGTDIds.size() > 0)
            StandardGoalDetailTriggerHelper.validatePeriods([Select Id, Period_Start__c, Period_End__c From Standard_Goal_Detail__c Where Id IN : setGTDIds
                                                                    AND Target_Type__c =: ISSPConstants.STANDARD_GOAL_DETAIL_TARGET_TYPE_PACED]);
    }
}