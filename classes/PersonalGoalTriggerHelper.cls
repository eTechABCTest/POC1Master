/**
 *  Description     :  Helper class for Trigger_PersoanlGoal trigger.
 *
 *  Created By      :  Padmesh Soni
 *
 *  Created Date    :  08/17/2015
 *
 *  Revision Logs   :   V_1.0 - Created - CR-20150729-9114
 *                      V_1.1 - Modified - Subhash Garhwal - 12/02/2015 - CR-20151120-9407
 *                      V_2.0 - Modified By - Rajeev Jain - 1/13/2016 -  ISSP Deployment C Release QA changes.
 *                              Commented out validatesPersonalGoal, since its no longer needed.    
 *                      V_3.0 - Modified By - Rajeev Jain - 04/07/2016 - ISSP Deployment E - CR - 9674, 
 *                              Modified addCondtion method in order to implement condition set logic as per updated SDD
 *                      V_3.1 - Modified By - Rajeev Jain - 05/13/2016 - CR-20160421-9790 - Added new method populateGTAndGTDDataOnPg
 **/
public without sharing class PersonalGoalTriggerHelper {
    
    //Static Flag to control the execution of activateProposals method
    public static Boolean executeActiveProposals = true;
    
    //Variable to control the Status update execution
    public static Boolean executeStatusLogic = true;
    
    //V_3.1 - Added By - Rajeev Jain - 05/13/2016
    /**
     *  @description    :   Method to populate GT and GTD comments at the Personal Goal Level - Called on before Insert and Before Update Event
     *
     *  @args           :   List<Personal_Goal__c> personalGoals, Map<Id, Personal_Goal__c> mapOldPersonalGoals
     *
     *  @return         :   void
     *
     **/
     public static void populateGTAndGTDDataOnPg(List<Personal_Goal__c> personalGoals, Map<Id, Personal_Goal__c> mapOldPg){
        
        //Set to hold GTD Ids
        Set<Id> gtdIds = new Set<Id>();
        
        //Loop over new Pg
        for(Personal_Goal__c pg : personalGoals)
            //Add GTD id to the set
            if(pg.Standard_Goal_Detail__c != null)
                gtdIds.add(pg.Standard_Goal_Detail__c); 
        
        //Map to hold the GTD data corrospondint to its GTD id
        //Query on GTD
        if(gtdIds.size() > 0){
            
            Map<Id, Standard_Goal_Detail__c> mapGTD = new Map<Id, Standard_Goal_Detail__c>([select Id, GTD_Comments__c, Standard_Goal__r.GT_Comments__c 
                                                                                        from Standard_Goal_Detail__c where ID IN :gtdIds]);
            
            if(mapGTD.size() > 0){
                
                //Now Loop over new Pg which is either for insert or for update
                for(Personal_Goal__c pg : personalGoals){
                    //Check if Mapp contains key
                    if(pg.Standard_Goal_Detail__c != null && mapGTD.containsKey(pg.Standard_Goal_Detail__c)){
                        pg.GT_Comments__c = mapGTD.get(pg.Standard_Goal_Detail__c).Standard_Goal__r.GT_Comments__c;
                        pg.GTD_Comments__c = mapGTD.get(pg.Standard_Goal_Detail__c).GTD_Comments__c;
                    }
                }
            }   
        }
     }
     
    /**
     *  @description    :   Method to clone personal goal and create new proposal goal and associate condition on new proposal goal
     *
     *  @args           :   List<Personal_Goal__c> personalGoals, Map<Id, Personal_Goal__c> mapOldPersonalGoals
     *
     *  @return         :   void
     *
     **/
    public static void createProposalGoal(List<Personal_Goal__c> personalGoals) {
    
        //Map to hold Id corresponding to personal goal list
        Map<Id, Personal_Goal__c> mapPersoanlGoals = new Map<Id, Personal_Goal__c>();
        
        //List of Record Type
        List<RecordType> recordTypes = [select Id, DeveloperName From RecordType Where SObjectType =: ISSPConstants.PERSONAL_GOAL_OBJECT 
                                        AND DeveloperName IN (:ISSPConstants.PERSONAL_GOAL_RECORD_TYPE_PERSONAL_GOAL, :ISSPConstants.PERSONAL_GOAL_RECORD_TYPE_PROPOSAL)
                                        ORDER BY DeveloperName ASC LIMIT 2];
      
        //Check for record type
        if(recordTypes.size() == 2) {
            
            //Loop through List for Personal Goal 
            for(Personal_Goal__c pG : personalGoals) {
                
                //Check for record Types
                if(pG.RecordTypeId == recordTypes[0].Id){
                    
                    //Clone personal goal
                    Personal_Goal__c clonnedPG = pG.clone();
                    clonnedPG.Primary_Goal__c = pG.Id;
                    clonnedPG.Active__c = true;
                    clonnedPG.RecordTypeId = recordTypes[1].Id;
                    clonnedPG.Personal_Plan__c = null;
                    clonnedPG.Proposal_Counter__c = 1;
                    clonnedPG.OwnerId = UserInfo.getUserId();
                    
                    //Populate map
                    mapPersoanlGoals.put(pG.Id, clonnedPG);
                }
            }
            
            //Check for map size
            if(mapPersoanlGoals.size() > 0) {
                
                //Insert Proposaed Goal Type PGs
                insert mapPersoanlGoals.values();
                
                //Call method to create children records under clone proposed goal
                validateChildrenObjects(mapPersoanlGoals);
                
                //List of Personal Goals to update the Active Proposal on the Snashot
                List<Personal_Goal__c> snapshotPGs = new List<Personal_Goal__c>();
                
                //Loop through the map key set
                for(Id ssPGId : mapPersoanlGoals.keySet()) {
                    
                    //Update Active Proposal
                    snapshotPGs.add(new Personal_Goal__c(Id = ssPGId, Active_Proposal__c = mapPersoanlGoals.get(ssPGId).Id));
                }
                
                //Check for list size
                if(snapshotPGs.size() > 0) {
                    
                    //Set flag to false to control the trigger execution
                    executeActiveProposals = false;
                    
                    //Update SS PGs
                    update snapshotPGs;
                    
                    //Set flag to false to control the trigger execution
                    executeActiveProposals = true;
                }
            }
        }
    }
    
    /**
     *  @description    :   This method is used to update the children object records on the Active Proposed Goals
     *
     *  @args           :   Map<Id, Personal_Goal__c>
     *
     *  @return         :   void
     *
     **/
    public static void validateChildrenObjects(Map<Id, Personal_Goal__c> mapPersoanlGoals) {
        
        //Set to hold the Snapshot PG Ids
        Set<Id> setSSPGIds = mapPersoanlGoals.keySet();
        
        //Delete calls
        
        //Delete Conditions
        delete [Select Id From Condition__c Where Personal_Goal__c IN : mapPersoanlGoals.values()];
        
        //Delete PG Relationships
        delete [Select Id From Personal_Goal_Relationship__c Where Personal_Goal__c IN : mapPersoanlGoals.values()];
        
        //delete PGMPs
        delete [Select Id From Personal_Goal_Measurement_Period__c Where Personal_Goal__c IN : mapPersoanlGoals.values()];
        
        //Global describe
        Map<String, Schema.SObjectType> globalDescribe = Schema.getGlobalDescribe();
        
        //Query through the Condition to get all the conditions related to Snapshot PGs
        List<Condition__c> originalConditions = (List<Condition__c>)Database.query(buildSOQL(globalDescribe, 'Condition__c') + ' Where Personal_Goal__c IN : setSSPGIds');
        
        //Check for conditions
        if(originalConditions.size() > 0) {
            
            //Clone the conditions
            List<Condition__c> clonedConditions = originalConditions.deepClone(false,true);
            
            //Loop through the Cloned condtions
            for(Condition__c con : clonedConditions) {
                
                //Update Personal Goal
                if(mapPersoanlGoals.containsKey(con.Personal_Goal__c))
                    con.Personal_Goal__c = mapPersoanlGoals.get(con.Personal_Goal__c).Id;
            }
            
            //Insert Conditions
            insert clonedConditions;    
        }
        
        //Query through the Personal Goal Relationship to get all the Personal Goal Relationships related to Snapshot PGs
        List<Personal_Goal_Relationship__c> originalPGRelationships = (List<Personal_Goal_Relationship__c>)Database.query(buildSOQL(globalDescribe, 'Personal_Goal_Relationship__c') + ' Where Personal_Goal__c IN : setSSPGIds');
        
        //Check for PGRs
        if(originalPGRelationships.size() > 0) {
            
            //Clone the PGRs
            List<Personal_Goal_Relationship__c> clonedPGRelationships = originalPGRelationships.deepClone(false,true);
            
            //Loop through the cloned PGRs
            for(Personal_Goal_Relationship__c pGR : clonedPGRelationships) {
                
                //Update Personal Goal
                if(mapPersoanlGoals.containsKey(pGR.Personal_Goal__c))
                    pGR.Personal_Goal__c = mapPersoanlGoals.get(pGR.Personal_Goal__c).Id;
            }
            
            //Insert cloned PGRs
            insert clonedPGRelationships;   
        }
        
        //Query through the PG Measurement Periods to get all the PG Measurement Periods related to Snapshot PGs
        List<Personal_Goal_Measurement_Period__c> originalPGMPeriods = (List<Personal_Goal_Measurement_Period__c>)Database.query(buildSOQL(globalDescribe, 'Personal_Goal_Measurement_Period__c') + ' Where Personal_Goal__c IN : setSSPGIds');
        
        //Check for PGMPs
        if(originalPGMPeriods.size() > 0) {
            
            //Clone the PGMPs
            List<Personal_Goal_Measurement_Period__c> clonedPGMPeriods = originalPGMPeriods.deepClone(false,true);
            
            //Loop through the cloned PGMPs
            for(Personal_Goal_Measurement_Period__c pGMP : clonedPGMPeriods) {
                
                //Update Personal Goal
                if(mapPersoanlGoals.containsKey(pGMP.Personal_Goal__c))
                    pGMP.Personal_Goal__c = mapPersoanlGoals.get(pGMP.Personal_Goal__c).Id;
            }
            
            //Insert cloned PGMPs
            insert clonedPGMPeriods;    
        }
    }
   /**
     *  @description    :   Method to validate personal goal with date range.
     *                      If the Personal Plan is populated and the record type is “Personal Goal”, compare to other Personal Goals with the same Record
     *                      type and Personal Plan to ensure:
     *                      •   the Period start/end does not overlap with the Period start/end of any other related Personal Goal
     *                      •   the Periods defined across all related Personal Goals are unique, and contiguous with no the periods defining a continuous range of unique dates
     *
     *  @args           :   List<Personal_Goal__c>, Map<Id, Personal_Goal__c>
     *
     *  @return         :   void
     *
     **/
    /*public static void validatesPersonalGoal(List<Personal_Goal__c> personalGoals, Map<Id, Personal_Goal__c> mapOldPersonalGoals) {
    
        //Set to hold the Std goal detail Ids
        Set<Id> setSGDIds = new Set<Id>();
        //****
        
        //List of wrapper class
        List<PersonalGoalWrapper> pGsWrapper = new List<PersonalGoalWrapper>();
        
        //Loop through the Personal Gaol and populate set
        for(Personal_Goal__c pG : personalGoals) {
            
            //Add pG in wrapper
            pGsWrapper.add(new PersonalGoalWrapper(pG));
            
            //Check for std goal detail
            if(pG.Standard_Goal_detail__c != null)
                //Add GTD in set
                setSGDIds.add(pG.Standard_Goal_Detail__c);
        }
        
        //Check for std goal detail set
        if(setSGDIds.size() > 0) {
            
            //Set to hold the Personal Plan Ids
            Set<Id> setPPIds = new Set<Id>();
            
            //Query through the std goal details
            Map<Id, Standard_Goal_Detail__c> mapStdGDetails = new Map<Id, Standard_Goal_Detail__c>([Select Id, Target_Type__c From Standard_Goal_Detail__c
                                                                                                           Where Id IN : setSGDIds]);
                                                                                                           
            //Map to hold the Personal Plan
            Map<String, List<Personal_Goal__c>> mapPPIdWithPGs = new Map<String, List<Personal_Goal__c>>();
            
            //List of Record Type
            List<RecordType> recordTypes = [select Id, DeveloperName From RecordType Where SObjectType =: ISSPConstants.PERSONAL_GOAL_OBJECT 
                                            AND DeveloperName =: ISSPConstants.PERSONAL_GOAL_RECORD_TYPE_PERSONAL_GOAL LIMIT 1];
            
            //Loop through pGsWrapper List
            for(PersonalGoalWrapper pGW : pGsWrapper) {
                
                //Check for Record Types and Personal Plan is not null
                if((!mapStdGDetails.containsKey(pGW.pG.Standard_Goal_Detail__c) || mapStdGDetails.get(pGW.pG.Standard_Goal_Detail__c).Target_Type__c == ISSPConstants.STANDARD_GOAL_DETAIL_TARGET_TYPE_PACED)
                    && (pGW.pG.Personal_Plan__c != null && pGW.pG.RecordTypeId == recordTypes[0].Id && (mapOldPersonalGoals == null
                        || pGW.pG.Period_Start__c != mapOldPersonalGoals.get(pGW.pG.Id).Period_Start__c
                        || pGW.pG.Period_End__c != mapOldPersonalGoals.get(pGW.pG.Id).Period_End__c
                        || pGW.pG.Personal_Plan__c != mapOldPersonalGoals.get(pGW.pG.Id).Personal_Plan__c))) {
                    
                    //Add PP Id in set
                    setPPIds.add(pGW.pG.Personal_Plan__c);
                    
                    //Check Personal Plan Id
                    if(mapPPIdWithPGs.containsKey(pGW.pG.Personal_Plan__c + '-' + pGW.pG.Standard_Goal_Detail__c)) {
                        
                        //Variable to check for continus date
                        Boolean isContinuousDates = false;
                         
                        //Loop through Personal Goal
                        for(Personal_Goal__c exPG : mapPPIdWithPGs.get(pGW.pG.Personal_Plan__c + '-' + pGW.pG.Standard_Goal_Detail__c)) {
                            
                            //Check for current records Start date and end date, if conflicting with any existing one, then throw exception
                            if((pGW.pG.Period_End__c == null && exPG.Period_End__c == null)
                                || (pGW.pG.Period_End__c != null && exPG.Period_End__c == null && pGW.pG.Period_End__c >= exPG.Period_Start__c)
                                || (pGW.pG.Period_End__c == null && exPG.Period_End__c != null && pGW.pG.Period_Start__c <= exPG.Period_End__c)
                                || (pGW.pG.Period_Start__c <= exPG.Period_End__c && pGW.pG.Period_Start__c >= exPG.Period_Start__c)
                                || (pGW.pG.Period_End__c >= exPG.Period_Start__c && pGW.pG.Period_End__c <= exPG.Period_End__c)
                                || (exPG.Period_Start__c <= pGW.pG.Period_End__c && exPG.Period_Start__c >= pGW.pG.Period_Start__c)
                                || (exPG.Period_End__c >= pGW.pG.Period_Start__c && exPG.Period_End__c <= pGW.pG.Period_End__c)) {
                                
                                //Add Error
                                throw new CustomException(Label.ERROR_UNIQUENESS_PG);
                            
                            } else if(pGW.pG.Period_Start__c == exPG.Period_End__c.addDays(1) || pGW.pG.Period_End__c == exPG.Period_Start__c.addDays(-1)) {
                                
                                //Set Flag values
                                isContinuousDates = true;
                                    
                                break;
                            }
                        }       
                        
                        //Check for Continuous date 
                        if(!isContinuousDates)
                            throw new CustomException(Label.ERROR_CONTINUOUS_PG);
                        
                        //Add Personal Goal into map
                        mapPPIdWithPGs.get(pGW.pG.Personal_Plan__c + '-' + pGW.pG.Standard_Goal_Detail__c).add(pGW.pG);
                    } else
                        mapPPIdWithPGs.put(pGW.pG.Personal_Plan__c + '-' + pGW.pG.Standard_Goal_Detail__c, new List<Personal_Goal__c> {pGW.pG});
                }
            }
                
            //Check for map size
            if(mapPPIdWithPGs.size() > 0) {
                
                //Map to hold Personal Plan Id with list of Existing Personal Goal
                Map<String, List<Personal_Goal__c>> mapPPIdWithEPGs = new Map<String, List<Personal_Goal__c>>();
                
                //Query through Personal Goal
                for(Personal_Goal__c pG : [Select Id, Period_End__c, RecordType.DeveloperName, Period_Start__c, Personal_Plan__c, Standard_Goal_Detail__c From Personal_Goal__c
                                                                  Where Personal_Plan__c IN : setPPIds AND RecordTypeId =: recordTypes[0].Id
                                                                  AND Id NOT IN : personalGoals
                                                                  AND Standard_Goal_Detail__r.Target_Type__c =: ISSPConstants.STANDARD_GOAL_DETAIL_TARGET_TYPE_PACED]) {
                    
                    //Check for map
                    if(!mapPPIdWithEPGs.containsKey(pG.Personal_Plan__c + '-' + pG.Standard_Goal_Detail__c))
                        mapPPIdWithEPGs.put(pG.Personal_Plan__c + '-' + pG.Standard_Goal_Detail__c, new List<Personal_Goal__c>());
                    
                    //Populate map
                    mapPPIdWithEPGs.get(pG.Personal_Plan__c + '-' + pG.Standard_Goal_Detail__c).add(pG);                                                       
                }
                
                //Check for map
                if(mapPPIdWithEPGs.size() > 0) {
                
                    //Loop through map key set (Personal Plan Ids)
                    for(String pPId : mapPPIdWithPGs.keySet()) {
                    
                        //Query through Personal goal 
                        for(Personal_Goal__c pG : mapPPIdWithPGs.get(pPId)) {
                            
                            //Check if map contains Personal Plan Id
                            if(mapPPIdWithEPGs.containsKey(pPId)) {
                                
                                //Variable to check for continus date
                                Boolean isContinuousDates = false;
                                
                                //Loop through Personal Goal
                                for(Personal_Goal__c exPG : mapPPIdWithEPGs.get(pPId)) {
                                    
                                    //Check for current records Start date and end date, if conflicting with any existing one, then throw exception
                                    if((pG.Period_End__c == null && exPG.Period_End__c == null)
                                        || (pG.Period_End__c != null && exPG.Period_End__c == null && pG.Period_End__c >= exPG.Period_Start__c)
                                        || (pG.Period_End__c == null && exPG.Period_End__c != null && pG.Period_Start__c <= exPG.Period_End__c)
                                        || (pG.Period_Start__c <= exPG.Period_End__c && pG.Period_Start__c >= exPG.Period_Start__c)
                                        || (pG.Period_End__c >= exPG.Period_Start__c && pG.Period_End__c <= exPG.Period_End__c)
                                        || (exPG.Period_Start__c <= pG.Period_End__c && exPG.Period_Start__c >= pG.Period_Start__c)
                                        || (exPG.Period_End__c >= pG.Period_Start__c && exPG.Period_End__c <= pG.Period_End__c)) {
                                        
                                            //Add Error
                                            throw new CustomException(Label.ERROR_UNIQUENESS_PG);
                                    
                                    } else {
                                        
                                        //Check for Continuous date
                                        if(pG.Period_Start__c == exPG.Period_End__c.addDays(1) || pG.Period_End__c == exPG.Period_Start__c.addDays(-1)) {
                                            
                                            //Set flag
                                            isContinuousDates = true;
                                            
                                            break;
                                        }   
                                    }
                                }
                                
                                //Check for Continuous dates
                                if(!isContinuousDates)
                                    throw new CustomException(Label.ERROR_CONTINUOUS_PG);
                                
                                //Add record
                                mapPPIdWithEPGs.get(pPId).add(pG);
                            }                                                   
                        }
                    }
                }   
            }
        }
    }*/

    
     /**
     *  @description    :   Method to create new Condition and associate condition on Standard Goal Detail or Primary Goal.
     *
     *  @args           :   List<Personal_Goal__c> personalGoals
     *
     *  @return         :   void
     *
     **/
    public static void createConditionsForPG(List<Personal_Goal__c> personalGoals) {
        
        //Map to hold all the Personal Goal Ids with corresponding Std Goal Detail Id
        Map<Id,List<Id>> mapSGDIdWithPGIds = new Map<Id,List<Id>>();
        
        //Map to hold all the Personal Goal Ids with corresponding Std Goal Id
        Map<Id,List<Id>> mapSGIdWithPGIds = new Map<Id,List<Id>>();
        
        //Loop through trigger.new
        for(Personal_Goal__c pG : [Select Id, Primary_Goal__c, Standard_Goal__c, Standard_Goal_Detail__c, Standard_Goal_Detail__r.Standard_Goal__c,
                                          RecordType.DeveloperName, (Select Id From Conditions__r LIMIT 1) From Personal_Goal__c 
                                          Where Id IN : personalGoals AND (RecordType.DeveloperName =: ISSPConstants.PERSONAL_GOAL_RECORD_TYPE_PERSONAL_GOAL
                                          OR (RecordType.DeveloperName =: ISSPConstants.PERSONAL_GOAL_RECORD_TYPE_PROPOSAL AND Active__c = false))]){
            
            //Check Record Type
            if(pG.Conditions__r.size() == 0){
                
                //Check for std goal detail
                if(pG.Standard_Goal_Detail__c != null ) {
                    
                    //Add value to map
                    if(mapSGDIdWithPGIds.containskey(pG.Standard_Goal_Detail__c))
                        mapSGDIdWithPGIds.get(pG.Standard_Goal_Detail__c).add(pG.Id);
                    else
                        mapSGDIdWithPGIds.put(pG.Standard_Goal_Detail__c,new List<Id>{pG.Id});  
                
                //Check for Std goal
                }
                
                if(pG.Standard_Goal__c != null) {
                    
                    //Add value to map
                    if(mapSGIdWithPGIds.containskey(pG.Standard_Goal__c))
                        mapSGIdWithPGIds.get(pG.Standard_Goal__c).add(pG.Id);
                    else
                        mapSGIdWithPGIds.put(pG.Standard_Goal__c,new List<Id>{pG.Id});
                }
            }
        }
        
        //Check for size
        if(mapSGDIdWithPGIds.size() > 0 || mapSGIdWithPGIds.size() > 0) {
            
            //Call method to create condtion
            createCondition(mapSGDIdWithPGIds, mapSGIdWithPGIds);
        }
    }

    /**
     *  @description    :   When a Proposal’s Active flag is changed to be true:
     *                          1. Update the Primary Goal’s Active Proposal to reference the Proposal just marked as Active
     *                          2. Update all amounts, Description, dates, tenure and sales role percentages, and goal ID to  
     *                             be those of the Active Proposal
     *                          3. Replace the Conditions of the Primary Goal with those of the Active Proposal
     *
     *  @args           :   List<> personalGoals, Map<Id, Personal_Goal__c > mapOldPersonalGoals
     *
     *  @return         :   void
     *
     **/
    public static void activateProposals(List<Personal_Goal__c> personalGoals, Map<Id, Personal_Goal__c> mapOldPersonalGoals) {
    
        //Map to hold Primary Goal Id corresponding to Personal Goal
        Map<Id, Personal_Goal__c> mapPrimaryGIdWithPGs = new Map<Id, Personal_Goal__c>();
        
        //Map to hold Personl Goal Id (Proposal) with personal Goal Id (Personal Goal)
        Map<Id, Id> mapProIdWithPGIds = new Map<Id, Id>();
        
        //Set to hold the proposal Ids
        //This set is used if record is Personal goal type
        Set<Id> setProposalIds = new Set<Id>();
        
        //Set to hold the Personal goal ids
        //This set is used if record is Personal goal type
        Set<Id> setPersonalGoalIds = new Set<Id>();
            
        //List of Record Type
        List<RecordType> recordTypes = [select Id, DeveloperName From RecordType Where SObjectType =: ISSPConstants.PERSONAL_GOAL_OBJECT 
                                        AND DeveloperName IN (:ISSPConstants.PERSONAL_GOAL_RECORD_TYPE_PERSONAL_GOAL,
                                                              :ISSPConstants.PERSONAL_GOAL_RECORD_TYPE_PROPOSAL) ORDER BY DeveloperName ASC LIMIT 2];
                                        
        //Loop through Personal Goal
        for(Personal_Goal__c pG : personalGoals) {
            
            //This condition is for Proposal record type (If Active checkbox is set to true and Primary Goal is populated on record, then marked
            // Proposal as a active proposal on the record)
            
            if(pG.Primary_Goal__c != null && !mapPrimaryGIdWithPGs.containsKey(pG.Primary_Goal__c) && pG.Active__c 
                && pG.Active__c != mapOldPersonalGoals.get(pG.Id).Active__c && pG.RecordTypeId == recordTypes[1].Id) {
            
                //Populate Map with some required and specific fields as mentioned
                mapPrimaryGIdWithPGs.put(pG.Primary_Goal__c, new Personal_Goal__c(Id = pG.Primary_Goal__c, Active_Proposal__c = pG.Id,
                                                                                  Amount__c = pG.Amount__c, Description__c = pG.Description__c,
                                                                                  Period_Start__c = pG.Period_Start__c, Period_End__c = pG.Period_End__c,
                                                                                  Tenure_Percentage__c = pG.Tenure_Percentage__c,
                                                                                  Sales_Role_Percentage__c = pG.Sales_Role_Percentage__c,
                                                                                  /*Goal_ID__c = pG.Goal_ID__c,*/ Count__c = pG.Count__c,
                                                                                  Percent__c = pG.Percent__c, Adjustment__c = pG.Adjustment__c,
                                                                                  Condition_Handling__c = pG.Condition_Handling__c,
                                                                                  Status__c = pG.Status__c, Goal_Type_Business_Title__c = pG.Goal_Type_Business_Title__c,
                                                                                  Period__c = pG.Period__c, Baseline_Amount__c = pG.Baseline_Amount__c));
                
                //Populate map
                mapProIdWithPGIds.put(pG.Id, pG.Primary_Goal__c);
            
            //This condition is for Personal goal record type (if personal goal's Active Proposal field is changed)
            } else if(pG.Active_Proposal__c != mapOldPersonalGoals.get(pG.Id).Active_Proposal__c && pG.RecordTypeId == recordTypes[0].Id) {
                
                //Check for active proposal
                if(pG.Active_Proposal__c != null) {
                    
                    //Populate Map with some required and specific fields as mentioned
                    mapPrimaryGIdWithPGs.put(pG.Id, new Personal_Goal__c(Id = pG.Id, Active_Proposal__c = pG.Active_Proposal__c));
                    
                    //Populate map
                    mapProIdWithPGIds.put(pG.Active_Proposal__c, pG.Id);
                    
                    //Add Proposal Id in set
                    setProposalIds.add(pG.Active_Proposal__c);
                    
                    //Populate Map with some required and specific fields as mentioned
                    if(mapOldPersonalGoals.get(pG.Id).Active_Proposal__c != null) {
                        mapPrimaryGIdWithPGs.put(mapOldPersonalGoals.get(pG.Id).Active_Proposal__c,
                                                 new Personal_Goal__c(Id = mapOldPersonalGoals.get(pG.Id).Active_Proposal__c, Active__c = false,
                                                                      Status__c = ISSPConstants.PERSONAL_GOAL_STATUS_FORMER));
                    
                        setPersonalGoalIds.add(mapOldPersonalGoals.get(pG.Id).Active_Proposal__c);
                    }
                    
                } else {
                    
                    //Populate Map with some required and specific fields as mentioned
                    if(mapOldPersonalGoals.get(pG.Id).Active_Proposal__c != null) {
                        mapPrimaryGIdWithPGs.put(mapOldPersonalGoals.get(pG.Id).Active_Proposal__c,
                                                 new Personal_Goal__c(Id = mapOldPersonalGoals.get(pG.Id).Active_Proposal__c, Active__c = false, Status__c = ISSPConstants.PERSONAL_GOAL_STATUS_FORMER));
                        
                        setPersonalGoalIds.add(mapOldPersonalGoals.get(pG.Id).Active_Proposal__c);  
                    }
                    setPersonalGoalIds.add(pG.Id);
                }
            }
        }
        
        //Check for map size
        if(mapPrimaryGIdWithPGs.size() > 0) {
            
            //Check for set size
            if(setProposalIds.size() > 0) {
                
                //Query through the Propsoals to update personal goals
                for(Personal_Goal__c pG : [Select Id, Amount__c, Description__c, Period_Start__c, Period_End__c,Percent__c, Tenure_Percentage__c,Count__c,
                                                   Sales_Role_Percentage__c, /*Goal_ID__c,*/ Adjustment__c, Condition_Handling__c, Status__c,
                                                   Goal_Type_Business_Title__c, Period__c, Baseline_Amount__c From Personal_Goal__c
                                                   Where Id IN : setProposalIds]) {
                                                    
                    //Check if Proposal's map contains the proposal
                    if(mapProIdWithPGIds.containsKey(pG.Id)) {
                        
                        //Update personal goals
                        mapPrimaryGIdWithPGs.get(mapProIdWithPGIds.get(pG.Id)).Amount__c = pG.Amount__c;
                        mapPrimaryGIdWithPGs.get(mapProIdWithPGIds.get(pG.Id)).Count__c = pG.Count__c;
                        mapPrimaryGIdWithPGs.get(mapProIdWithPGIds.get(pG.Id)).Percent__c = pG.Percent__c;
                        mapPrimaryGIdWithPGs.get(mapProIdWithPGIds.get(pG.Id)).Description__c = pG.Description__c;
                        mapPrimaryGIdWithPGs.get(mapProIdWithPGIds.get(pG.Id)).Period_Start__c = pG.Period_Start__c;
                        mapPrimaryGIdWithPGs.get(mapProIdWithPGIds.get(pG.Id)).Period_End__c = pG.Period_End__c;
                        mapPrimaryGIdWithPGs.get(mapProIdWithPGIds.get(pG.Id)).Tenure_Percentage__c = pG.Tenure_Percentage__c;
                        mapPrimaryGIdWithPGs.get(mapProIdWithPGIds.get(pG.Id)).Sales_Role_Percentage__c = pG.Sales_Role_Percentage__c;
                        //mapPrimaryGIdWithPGs.get(mapProIdWithPGIds.get(pG.Id)).Goal_ID__c = pG.Goal_ID__c;
                        mapPrimaryGIdWithPGs.get(mapProIdWithPGIds.get(pG.Id)).Adjustment__c = pG.Adjustment__c;
                        mapPrimaryGIdWithPGs.get(mapProIdWithPGIds.get(pG.Id)).Condition_Handling__c = pG.Condition_Handling__c;
                        mapPrimaryGIdWithPGs.get(mapProIdWithPGIds.get(pG.Id)).Status__c = pG.Status__c;
                        mapPrimaryGIdWithPGs.get(mapProIdWithPGIds.get(pG.Id)).Goal_Type_Business_Title__c = pG.Goal_Type_Business_Title__c;
                        mapPrimaryGIdWithPGs.get(mapProIdWithPGIds.get(pG.Id)).Period__c = pG.Period__c;
                        mapPrimaryGIdWithPGs.get(mapProIdWithPGIds.get(pG.Id)).Baseline_Amount__c = pG.Baseline_Amount__c;
                        
                        //System.debug('CHeck for Primary Goal ID @@@ :::: ' + pG.Goal_ID__c);
                    }                                   
                }
            }
            
            //List to delete Conditions from Primary Goal
            List<Condition__c> conditionsGoingToDelete = [Select Id From Condition__c Where Personal_Goal__c IN : mapPrimaryGIdWithPGs.keyset()
                                                                                            AND Personal_Goal__c NOT IN : setPersonalGoalIds];
            
            //List to delete PGR from Primary Goal
            List<Personal_Goal_Relationship__c> pGRsGoingToDelete = [Select Id From Personal_Goal_Relationship__c Where Personal_Goal__c IN : mapPrimaryGIdWithPGs.keyset()
                                                                                            AND Personal_Goal__c NOT IN : setPersonalGoalIds];
            
            //List to delete PGMP from Primary Goal
            List<Personal_Goal_Measurement_Period__c> pGMPsGoingToDelete = [Select Id From Personal_Goal_Measurement_Period__c Where Personal_Goal__c IN : mapPrimaryGIdWithPGs.keyset()
                                                                                            AND Personal_Goal__c NOT IN : setPersonalGoalIds];
            
            //Loop through Personal Goals
            for(Personal_Goal__c pG : [Select Id, Active_Proposal__c, Active__c From Personal_Goal__c Where Id IN : mapPrimaryGIdWithPGs.keySet()
                                                            AND Active_Proposal__c != null AND Active_Proposal__c NOT IN : mapProIdWithPGIds.keySet()])
                mapPrimaryGIdWithPGs.put(pG.Active_Proposal__c, new Personal_Goal__c(Id = pG.Active_Proposal__c, Active__c = false, Status__c = ISSPConstants.PERSONAL_GOAL_STATUS_FORMER));
            
            //Set flag
            executeActiveProposals = false;
            
            //Update Personal Goal
            update mapPrimaryGIdWithPGs.values();
            
            //Delete existing condition
            if(conditionsGoingToDelete.size() > 0)
                delete conditionsGoingToDelete;
            
            //Delete existing PGRs
            if(pGRsGoingToDelete.size() > 0)
                delete pGRsGoingToDelete;
            
            //Delete existing PGMPs
            if(pGMPsGoingToDelete.size() > 0)
                delete pGMPsGoingToDelete;
            
            //Set to get Personal Goal Ids
            Set<Id> setPGIds = mapProIdWithPGIds.keySet();
            
            //Global describe
            Map<String, Schema.SObjectType> globalDescribe = Schema.getGlobalDescribe();
            
            //List of Conditions to get Existing condition
            List<Condition__c> conditions = Database.query(buildSOQL(globalDescribe, 'Condition__c') + ' Where Personal_Goal__c IN : setPGIds');
            
            //Check for Condition size
            if(conditions.size() > 0) {
                
                //Clone Conditions
                List<Condition__c> clonedConitions = conditions.deepClone(false,true);
                
                //Loop through the cloned conditions
                for(Condition__c con : clonedConitions)
                    con.Personal_Goal__c = mapProIdWithPGIds.get(con.Personal_Goal__c);
                
                //Insert cloned conditions
                if(clonedConitions.size() > 0)
                    insert clonedConitions;
            }
            
            //Query through the PG Relationships to get Existing PG Relationships
            List<Personal_Goal_Relationship__c> pGRelationships = Database.query(buildSOQL(globalDescribe, 'Personal_Goal_Relationship__c') + ' Where Personal_Goal__c IN : setPGIds');
            
            //Check for PGR size
            if(pGRelationships.size() > 0) {
                
                //Clone PGR
                List<Personal_Goal_Relationship__c> clonedPGRelationships = pGRelationships.deepClone(false,true);
                
                //Loop through the cloned PGR
                for(Personal_Goal_Relationship__c pGR : clonedPGRelationships)
                    pGR.Personal_Goal__c = mapProIdWithPGIds.get(pGR.Personal_Goal__c);
                
                //Insert cloned PGRs
                if(clonedPGRelationships.size() > 0)
                    insert clonedPGRelationships;
            }
            
            //Query through the PG Measurement Periods to get Existing PG Measurement Periods
            List<Personal_Goal_Measurement_Period__c> pGMPeriods = Database.query(buildSOQL(globalDescribe, 'Personal_Goal_Measurement_Period__c') + ' Where Personal_Goal__c IN : setPGIds');
            
            //Check for PGMP size
            if(pGMPeriods.size() > 0) {
                
                //Clone PGMP
                List<Personal_Goal_Measurement_Period__c> clonedPGMPeriods = pGMPeriods.deepClone(false,true);
                
                //Loop through the cloned PGR
                for(Personal_Goal_Measurement_Period__c pGMP : clonedPGMPeriods)
                    pGMP.Personal_Goal__c = mapProIdWithPGIds.get(pGMP.Personal_Goal__c);
                
                //Insert cloned PGMPs
                if(clonedPGMPeriods.size() > 0)
                    insert clonedPGMPeriods;
            }
            
            //Set flag
            executeActiveProposals = true;
        }
    }
    
    /**
     *  @description    :   This method is used to update the counterpart PG (Snapshot or Proposed Goal) whenever PG's status is changed to 
     *                      Payee Approved.
     *
     *                      Details from SDD :
     *                      If the Goal Snapshot or Proposed Goal is modified to a Status of “Payee Approved”, ensure that its counterpart
     *                      is also updated. So, an update to the Proposed Goal will update the Status of the referenced Goal Snapshot, and
     *                      an update to a Goal Snapshot will also update the Status of the active Proposed Goal.
     *
     *  @args           :   List<Personal_Goal__c>, Map<Id, Personal_Goal__c>
     *
     *  @return         :   void
     *
     **/
    public static void validateCounterpartPG(List<Personal_Goal__c> personalGoals, Map<Id, Personal_Goal__c> mapOldPGoals) {
        
        //Map to hold the Personal Goal to update
        Map<Id, Personal_Goal__c> mapPersonalGoals = new Map<Id, Personal_Goal__c>();
        
        //Loop through the Personal Goals
        for(Personal_Goal__c pG : personalGoals) {
            
            //Check for appropriate condition to fire the trigger
            if(pG.Status__c == ISSPConstants.PERSONAL_GOAL_STATUS_PAYEE_APPROVED && pG.Status__c != mapOldPGoals.get(pG.Id).Status__c) {
                
                //Check for Primary Goal
                if((pG.Active__c && pG.Primary_Goal__c != null && pG.Active_Proposal__c == null) || (pG.Active_Proposal__c != null)) {
                        
                    //Check for Primary Goal
                    if(pG.Primary_Goal__c != null && pG.Active_Proposal__c == null)
                        mapPersonalGoals.put(pG.Primary_Goal__c, new Personal_Goal__c(Id = pG.Primary_Goal__c, Status__c = pG.Status__c));
                    else if(pG.Active_Proposal__c != null)
                        mapPersonalGoals.put(pG.Active_Proposal__c, new Personal_Goal__c(Id = pG.Active_Proposal__c, Status__c = pG.Status__c));    
                }
            }
        }
        
        //Check for map size
        if(mapPersonalGoals.size() > 0) {
            
            //Set flag to false
            executeStatusLogic = false;
            
            //Update
            update mapPersonalGoals.values();
            
            //Set flag to true
            executeStatusLogic = true;
            
        }
    }
    
    /**
     *  @description    :   This method is used to build the SOQL query string.
     *
     *  @args           :   Map<String, Schema.SObjectType>, String
     *
     *  @return         :   String
     *
     **/
    public static String buildSOQL(Map<String, Schema.SObjectType> globalDescribe, String objName) {
        
        //SOQL query
        String SOQL = 'Select ';
        
        //Get the field of the object'
        for(String field : globalDescribe.get(objName).getDescribe().fields.getMap().keySet())
            SOQL += field + ',';
        
        //Check for object
        if(objName == 'Condition__c')
            SOQL = SOQL + ' Standard_Goal_Detail__r.Standard_Goal__c,';
                
        //Remove extra elements and add object
        SOQL = SOQL.removeEnd(',') + ' From ' + objName;
        
        //Return 
        return SOQL;
        
    }
    
    /**
     *  @description    :   This method is used to create conditions for Personal Goal  
     *
     *  @args           :   Map<Id,List<Id>>, Map<Id,List<Id>>
     *
     *  @return         :   void
     *
     **/
    //V_3.0 - Modified By - Rajeev Jain - 04/07/2016 - ISSP Deployment E - CR - 9674,
    //Modified addCondition logic on personal Goal, erlier we were including all condition from Goal Template on personal Goal.
    //• Compare the GT Condition Sets to the GTD Condition Sets.
    //     Assign to the PG all Conditions (and their Set indicators) where a Condition is assigned directly to the GTD.
    //     Add GT Conditions to each GTD Condition Set when none of the GT Condition types is found within the Condition Types of the GTD Condition set. 
    //     Illustration: For illustration, see attached diagram on the CR-20160304-9674, named with Condition_Example.
    public static void createCondition(Map<Id,List<Id>> mapSGDIdWithPGIds, Map<Id,List<Id>> mapSGIdWithPGIds) {
        
        //Map to hold all the conditions with correponding PG Id
        Map<Id,List<Condition__c>> mapConditions = new Map<Id,List<Condition__c>>();
        
        //set to hold Std Goal Ids
        set<Id> setSGIds = mapSGIdWithPGIds.keyset();
        
        //set to hold Std Goal Detail Ids
        set<Id> setSGDIds = mapSGDIdWithPGIds.keyset();
        
        //V_3.0 - Properties Added By - Rajeev Jain - 04/07/2016 - ISSP Deployment E - CR - 9674,
        
        //Map to hold Condtion set Map corrosponding to each GT
        //Map to hold the Map of Conditions with Condition Type corrosponding to each Condition Set field on the Condition Record associated on Goal Template
        Map<Id, Map<Decimal, Map<String, List<Condition__c>>>> gtConditionSetMap = new Map<Id, Map<Decimal, Map<String, List<Condition__c>>>>();
        
        //Map to hold Condtion set Map corrosponding to each GT
        Map<Id, Map<Decimal, Map<String, List<Condition__c>>>> gtdConditionSetMap = new Map<Id, Map<Decimal, Map<String, List<Condition__c>>>>();
        
        //Map to hold the List of Condition Set Corrosponding to each GTD
        Map<Id, List<Decimal>> mapGtdConditionSetList = new Map<Id, List<Decimal>>();
        Map<Id, List<Decimal>> mapGtConditionSetList = new Map<Id, List<Decimal>>();
              
        Map<Id, List<Condition__c>> mapGtdConditions = new Map<Id, List<Condition__c>>();
        Map<Id, List<Condition__c>> mapGtConditions = new Map<Id, List<Condition__c>>();
      
        //V_3.0 - Properties Added By - Rajeev Jain - 04/07/2016 - ISSP Deployment E - CR - 9674 - upto here
        
        //Global describe
        Map<String, Schema.SObjectType> globalDescribe = Schema.getGlobalDescribe();
            
        //Add Where clouse
        String SOQL =  buildSOQL(globalDescribe, 'Condition__c') + ' Where (Standard_Goal__c IN : setSGIds AND Standard_Goal_Detail__c = null) OR Standard_Goal_Detail__c IN : setSGDIds' ;
        
        //List to hold all common conditions on both Goal Template and Goal Template Details
        List<Condition__c> globalConditions = Database.query(SOQL);
        
        //Loop over global Conditions and fill the above map
        for(Condition__c con : globalConditions){
            
            //Check for std goal detail - to populate gtdConditionSetMap
            if(con.Standard_Goal_Detail__c != null && con.Standard_Goal__c != null && mapSGDIdWithPGIds.containsKey(con.Standard_Goal_Detail__c)) {
                
                if(mapGtdConditions.containsKey(con.Standard_Goal_Detail__c)){
                    mapGtdConditions.get(con.Standard_Goal_Detail__c).add(con); 
                }else{
                    mapGtdConditions.put(con.Standard_Goal_Detail__c, new List<Condition__c>{con});
                }   
            }else if(con.Standard_Goal__c != null && con.Standard_Goal_Detail__c == null && mapSGIdWithPGIds.containskey(con.Standard_Goal__c)){
                
                if(mapGtConditions.containsKey(con.Standard_Goal__c)){
                    mapGtConditions.get(con.Standard_Goal__c).add(con); 
                }else{
                    mapGtConditions.put(con.Standard_Goal__c, new List<Condition__c>{con});
                }
                        
            }
        }
        
        //Loop over mapSGDIdWithPGIds and check if any sgd is having no list of conditions
        for(Id sgdId : mapSGDIdWithPGIds.keySet()){
            
            //If mapGtdConditions is not having such id that means such records are not having any conditions associated with them, then put blank list
            if(!mapGtdConditions.containsKey(sgdId)){
                mapGtdConditions.put(sgdId, new List<Condition__c>());
            }
        }
        
        //Loop over mapSGDIdWithPGIds and check if any sgd is having no list of conditions
        for(Id sgId : mapSGIdWithPGIds.keySet()){
            
            //If mapGtdConditions is not having such id that means such records are not having any conditions associated with them, then put blank list
            if(!mapGtConditions.containsKey(sgId)){
                mapGtConditions.put(sgId, new List<Condition__c>());
            }
        }
        
        //Loop over Gt conditions and fill the map
        for(Id gtId : mapGtConditions.keySet()){
            
            if(mapGtConditions.get(gtId).size() == 0){
                
                //Here Putting null shows, there is not Condition created on GT level
                gtConditionSetMap.put(gtId, null);
            }else{
                
                //Loop over Gt Conditions and Prepate GTConditionSet 
                for(Condition__c con : mapGtConditions.get(gtId)){
                    
                    //BYpass Record if Condition Set field is null
                    if(con.Condition_Set__c != null && con.RecordTypeId != null){
                        
                        //Create Inner Map which will hold GT Condition set and corrosponding Data
                        if(gtConditionSetMap.containsKey(gtId)){
                            
                            //Get gtConditionSetMap and put corrosponding values in it
                            Map<Decimal, Map<String, List<Condition__c>>> gtConditionSetMapTemp = gtConditionSetMap.get(gtId);
                            
                            //Check if gtdConditionSetMap contians Condition's condition set then add it to existing one other wise put new one
                            if(gtConditionSetMapTemp.containsKey(con.Condition_Set__c)){
                                
                                //Map to hold list of the Conditions corrosponding to each Condition Type, this will be populated as inner map of Condition Set Map
                                Map<String, List<Condition__c>> gtdCondTypeMap = gtConditionSetMapTemp.get(con.Condition_Set__c);
                                
                                //Now check if Inner Map of Condition Set Contains Condition Type as a key then add newer one in existing map otherwise put newer one in map
                                if(gtdCondTypeMap.containsKey(con.RecordTypeId)){
                                    
                                    gtdCondTypeMap.get(con.RecordTypeId).add(con);
                                }else{
                                    gtdCondTypeMap.put(con.RecordTypeId, new List<Condition__c>{con});
                                }   
                            }else{
                                
                                //Initialize Inner Map and Put Condition Type and add one element in condition List
                                Map<String, List<Condition__c>> mapgtdCondTyp = new Map<String, List<Condition__c>>();
                                
                                //Map to hold List of Condition Corrosponding to Condition Type
                                mapgtdCondTyp.put(con.RecordTypeId, new List<Condition__c>{con});
                                
                                gtConditionSetMapTemp.put(con.Condition_Set__c, mapgtdCondTyp);
                                
                                mapGtConditionSetList.get(gtId).add(con.Condition_Set__c);
                            }
                        }else{
                            //Create Temp GT condition set map and put it into main map
                            Map<Decimal, Map<String, List<Condition__c>>> tempConditionSetGTMap = new Map<Decimal, Map<String, List<Condition__c>>>();
                            
                            //Initialize Inner Map and Put Condition Type and add one element in condition List
                            Map<String, List<Condition__c>> mapgtdCondTyp = new Map<String, List<Condition__c>>();
                            
                            //Map to hold List of Condition Corrosponding to Condition Type
                            mapgtdCondTyp.put(con.RecordTypeId, new List<Condition__c>{con});
                            
                            tempConditionSetGTMap.put(con.Condition_Set__c, mapgtdCondTyp);
                            
                            //Put inner ConditionsSet Map in Main ConditionSet Map
                            gtConditionSetMap.put(gtId, tempConditionSetGTMap);
                            
                            mapGtConditionSetList.put(gtId, new List<Decimal>{con.Condition_Set__c});
                        }
                    }
                }
            }
        }
        //---------------- Gt Condition Map Filling ends here --------------------
        
        //Gtd condition set filling starts from here
        //Loop over Gtd conditions and fill the map
        for(Id gtdId : mapGtdConditions.keySet()){
            
            if(mapGtdConditions.get(gtdId).size() == 0){
                
                //Here Putting null shows, there is not any Condition created on GTD level
                gtdConditionSetMap.put(gtdId, null);
            }else{
                
                //Loop over Gtd Conditions and Prepate GTConditionSet 
                for(Condition__c con : mapGtdConditions.get(gtdId)){
                    
                    //BYpass Record if Condition Set field is null
                    if(con.Condition_Set__c != null && con.RecordTypeId != null){
                        
                        //Create Inner Map which will hold GT Condition set and corrosponding Data
                        if(gtdConditionSetMap.containsKey(gtdId)){
                            
                            //Get gtConditionSetMap and put corrosponding values in it
                            Map<Decimal, Map<String, List<Condition__c>>> gtdConditionSetMapTemp = gtdConditionSetMap.get(gtdId);
                            
                            //Check if gtdConditionSetMap contians Condition's condition set then add it to existing one other wise put new one
                            if(gtdConditionSetMapTemp.containsKey(con.Condition_Set__c)){
                                
                                //Map to hold list of the Conditions corrosponding to each Condition Type, this will be populated as inner map of Condition Set Map
                                Map<String, List<Condition__c>> gtdCondTypeMap = gtdConditionSetMapTemp.get(con.Condition_Set__c);
                                
                                //Now check if Inner Map of Condition Set Contains Condition Type as a key then add newer one in existing map otherwise put newer one in map
                                if(gtdCondTypeMap.containsKey(con.RecordTypeId)){
                                    
                                    gtdCondTypeMap.get(con.RecordTypeId).add(con);
                                }else{
                                    gtdCondTypeMap.put(con.RecordTypeId, new List<Condition__c>{con});
                                }   
                            }else{
                                
                                //Initialize Inner Map and Put Condition Type and add one element in condition List
                                Map<String, List<Condition__c>> mapgtdCondTyp = new Map<String, List<Condition__c>>();
                                
                                //Map to hold List of Condition Corrosponding to Condition Type
                                mapgtdCondTyp.put(con.RecordTypeId, new List<Condition__c>{con});
                                
                                gtdConditionSetMapTemp.put(con.Condition_Set__c, mapgtdCondTyp);
                                
                                mapGtdConditionSetList.get(gtdId).add(con.Condition_Set__c);
                            }
                        }else{
                            //Create Temp GT condition set map and put it into main map
                            Map<Decimal, Map<String, List<Condition__c>>> tempConditionSetGTDMap = new Map<Decimal, Map<String, List<Condition__c>>>();
                            
                            //Initialize Inner Map and Put Condition Type and add one element in condition List
                            Map<String, List<Condition__c>> mapgtdCondTyp = new Map<String, List<Condition__c>>();
                            
                            //Map to hold List of Condition Corrosponding to Condition Type
                            mapgtdCondTyp.put(con.RecordTypeId, new List<Condition__c>{con});
                            
                            tempConditionSetGTDMap.put(con.Condition_Set__c, mapgtdCondTyp);
                            
                            mapGtdConditionSetList.put(gtdId, new List<Decimal>{con.Condition_Set__c});
                            
                            //Put inner ConditionsSet Map in Main ConditionSet Map
                            gtdConditionSetMap.put(gtdId, tempConditionSetGTDMap);
                        }
                    }
                }
            }
        }
        //---------------- Gt Condition Map Filling ends here --------------------
        
        //Default Assuming that any condition is on 
        Boolean isAnyConditionOnGT = true;
        
        //Now check if gtConditionSet Map is having null values that means there is no condition associated on it
        for(Id gtId : gtConditionSetMap.keySet()){
            if(gtConditionSetMap.get(gtId) == null){
                isAnyConditionOnGT = false; 
                break;
            }
        }
        
        //Map to hold new Map of Condition Set and condition List
        Map<Id, Map<Decimal,List<Condition__c>>> mapNewGtdConditionSet = new Map<Id, Map<Decimal, List<Condition__c>>>();
        
        // Set to Hold Unique combination 
        Set<String> ensureUniqueCondSetAtPGs = new Set<String>();
         
        //If not any condition populated on the GT level that means all GTD conditions are applicable to add on personal Goal level and no condition set comparision between both's conditions
        if(!isAnyConditionOnGT){
            
            //Add all GTd Condition as it is to final Combined list
            //combinedList.addAll(mapGtdConditions.values());
            
            for(Id gtdId : mapGtdConditions.keySet()){
                
                //Loop over GTD Conditions Values
                for(Condition__c con : mapGtdConditions.get(gtdId)){
                    
                    if(con.Standard_Goal_Detail__c != null && mapSGDIdWithPGIds.containsKey(con.Standard_Goal_Detail__c)) {
                
                        //Loop through mapSGDIdWithPGIds map 
                        for(Id pGId : mapSGDIdWithPGIds.get(con.Standard_Goal_Detail__c)){
                            
                            if(mapConditions.containskey(pGId))
                                mapConditions.get(pGId).add(con);
                            else
                                mapConditions.put(pGId,new List<Condition__c>{con});
                        }
                    
                    } 
                }
            }
        //If above is not true then process for Condition set comparision and prepare combined list
        }else{
            
            //Loop over GTD condition set
            for(Id gtdId : gtdConditionSetMap.keySet()){
                
                //Now check if gtdConditionSet is not populated with any condition list then pass whold GT level Condition list on it
                if(gtdConditionSetMap.get(gtdId) == null){
                    
                    //Get all assoicated Persoanl Goal List from Pre Existing Map
                    if(mapSGDIdWithPGIds.containsKey(gtdId)){
                        
                        //Loop through mapSGDIdWithPGIds map 
                        for(Id pGId : mapSGDIdWithPGIds.get(gtdId)){
                            
                            if(!mapConditions.containskey(pGId))
                                mapConditions.put(pGId,new List<Condition__c>());
                            if(mapConditions.containskey(pGId))
                                for(Id mgtdId : mapGtConditions.KeySet()){
                                    
                                    mapConditions.get(pGId).addAll(mapGtConditions.get(mgtdId));
                                }
                        }
                    }
                }else{
                    
                    Decimal conditionSetCounter = 1;
                    
                    Map<Decimal, List<Condition__c>> newConditionSetMap = new Map<Decimal,List<Condition__c>>();
                    
                    //Sorte List of Condition Set(Had to maintian this list due to Map Key set not return results in sequence order)
                    List<Decimal> sortedGtdConditionSets = mapGtdConditionSetList.get(gtdId);
                    sortedGtdConditionSets.sort();
                    
                    //Loop over actual Condition Set map and iterate on each condition set and compare with GT condition set
                    for(Decimal gtdConditionSet : sortedGtdConditionSets){
                        
                        //Loop over to gtConditionSet
                        for(Id gtId : gtConditionSetMap.keySet()){
                            
                            List<Decimal> sortedList = mapGtConditionSetList.get(gtId);
                            sortedList.sort();
                            
                            //Loop over each condition Type of GT
                            for(Decimal gtConditionSet : sortedList){
                                
                                //Now check if gtdCondtionType is matched with GT condition Type
                                Map<String, List<Condition__c>> gtConditionTypeMap = gtConditionSetMap.get(gtId).get(gtConditionSet);   
                                
                                Boolean isAnyMatched = false;
                                
                                for(String gtdCondType : gtdConditionSetMap.get(gtdId).get(gtdConditionSet).keySet()){
                                    
                                    if(gtConditionTypeMap.keySet().contains(gtdCondType)){
                                        isAnyMatched = true;
                                        break;
                                    }
                                }
                                //If not any condition Type matched then add all GTD conditions and then GT conditions and assign them one new Condition Set
                                String uniqueKey = gtdId + '';
                                if(!isAnyMatched){
                                    
                                    List<Condition__c> tempList = new List<Condition__c>();
                                    
                                    //Loop over all condType in order to check if set is alreay not having such unique combination of cond type then go to add it for next level
                                    for(String gtdCondTypeTemp : gtdConditionSetMap.get(gtdId).get(gtdConditionSet).keySet())
                                         uniqueKey += gtdCondTypeTemp;
                                    for(String condType : gtConditionTypeMap.keySet())   
                                        uniqueKey += condType;
                                    
                                    
                                    if(!ensureUniqueCondSetAtPGs.contains(uniqueKey)){
                                         
                                        //First Add GtD Value
                                        //Loop over all gtdType of that same gtdConditionSet and add all those values to temp list
                                        for(String gtdCondTypeTemp : gtdConditionSetMap.get(gtdId).get(gtdConditionSet).keySet()){
                                            
                                            //Loop over each condition and add it for further set if and only if Set does not already contain whole string pattern of all added element of the list 
                                            tempList.addAll(gtdConditionSetMap.get(gtdId).get(gtdConditionSet).get(gtdCondTypeTemp));
                                           
                                        }
                                        
                                        //if not matched then add that type Condition List in major list
                                        for(String condType : gtConditionTypeMap.keySet())    
                                            tempList.addAll(gtConditionTypeMap.get(condType));
                                        
                                        if(newConditionSetMap.containsKey(conditionSetCounter)){
                                            newConditionSetMap.get(conditionSetCounter).addAll(tempList);
                                        }else{
                                            newConditionSetMap.put(conditionSetCounter,tempList);
                                        }
                                        
                                        conditionSetCounter++;
                                        ensureUniqueCondSetAtPGs.add(uniqueKey);
                                    }
                                        
                                //At least add all conditions of that GTD condition set for GTD's pg
                                }else{
                                    
                                    List<Condition__c> tempList = new List<Condition__c>();
                                    
                                    //Loop over all condType in order to check if set is alreay not having such unique combination of cond type then go to add it for next level
                                    for(String gtdCondTypeTemp : gtdConditionSetMap.get(gtdId).get(gtdConditionSet).keySet())
                                         uniqueKey += gtdCondTypeTemp;
                                    
                                    if(!ensureUniqueCondSetAtPGs.contains(uniqueKey)){   
                                        
                                        //Loop over all gtdType of that same gtdConditionSet and add all those values to temp list
                                        for(String gtdCondTypeTemp : gtdConditionSetMap.get(gtdId).get(gtdConditionSet).keySet()){
                                            
                                            //Loop over each condition and add it for further set if and only if Set does not already contain whole string pattern of all added element of the list 
                                            tempList.addAll(gtdConditionSetMap.get(gtdId).get(gtdConditionSet).get(gtdCondTypeTemp));
                                        }
                                        
                                        if(newConditionSetMap.containsKey(conditionSetCounter)){
                                            newConditionSetMap.get(conditionSetCounter).addAll(tempList);
                                        }else{
                                            newConditionSetMap.put(conditionSetCounter,tempList);
                                        }
                                        
                                        conditionSetCounter++;
                                        ensureUniqueCondSetAtPGs.add(uniqueKey);
                                    }
                                }
                            }
                            
                        }
                        
                    }
                    
                    //Now clone Temp List and assign new condition set to each one then reset the temp list
                    //Also fill it in the mapCondition, which holds list of conditions for personal goal
                    List<Condition__c> clonedList = new List<Condition__c>();
                    
                    //Loop over new Condition Set and Assign it to each condition in list
                    for(Decimal dc : newConditionSetMap.keySet()){
                        
                        //Loop over each conditions
                        for(Condition__c con : newConditionSetMap.get(dc).deepClone(false,true)){
                            
                            con.Condition_Set__c = dc;
                            clonedList.add(con);
                        }
                    }
                    
                    //Get all assoicated Persoanl Goal List from Pre Existing Map
                    if(mapSGDIdWithPGIds.containsKey(gtdId)){
                        
                        //Loop through mapSGDIdWithPGIds map 
                        for(Id pGId : mapSGDIdWithPGIds.get(gtdId)){
                            
                            if(!mapConditions.containskey(pGId))
                                mapConditions.put(pGId,new List<Condition__c>());
                            if(mapConditions.containskey(pGId))
                                mapConditions.get(pGId).addAll(clonedList);
                        }
                    }
                }
            }
        }
        
        //List To insert Condition
        List<Condition__c> conditions = new List<Condition__c>();   
        
        //Loop through map mapCondition keyset
        for(Id pGId : mapConditions.keyset()){
        
            //List to clone Conditions
            List<Condition__c> clonedConditions = mapConditions.get(pGId).deepClone(false,true);
            
            //Loop through Conditions
            for(Condition__c con : clonedConditions){
                
                //Assign Key to id
                con.Personal_Goal__c = pGId;
                con.Standard_Goal__c = null;
                con.Standard_Goal_Detail__c = null;
            }
            
            //Add cloned Condition to new list.
            conditions.addAll(clonedConditions);
        }
        //Insert Condition
        if(conditions.size() > 0)   
            insert conditions;
    }
}