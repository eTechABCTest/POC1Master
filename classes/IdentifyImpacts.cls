/**
 *  Purpose         :   Apex class to hold the Identify Impacts button logic.
 *                      Identify Impacts button description : This button is used to Identify all the Personal Goals for the current ICB's ICLs
 *  
 *  Created By      :   Subhash Garhwal
 * 
 *  Created Date    :   09/30/2015
 * 
 *  Revision Logs   :   V_1.0 - Created - CR-20150729-9114
 *                  :   V_1.1 - Modified - CR-20151120-9402 - Removing the references of the fields which are deleted from schema.
 *                                          Identify impacts of ICL records on Personal Goal based on various Rule for macthing logic.
 * 
 **/
public with sharing class IdentifyImpacts {
    
    //Map to hold the Personal Goal Id with ICLs
    Map<Id, List<IncentiveChangeLogWrapper>> mapPGIdWithICLIds = new Map<Id, List<IncentiveChangeLogWrapper>>();
    
    //Constructor
    public IdentifyImpacts(ApexPages.StandardController controller) {}
    
    /**
     *  @description    :   This method is used to identify the impacts for current Icentive change batch
     *
     *  @args           :   
     *
     *  @return         :   Pagereference
     *
     **/
    private void populatePersonalGoalMap(Personal_Goal__C pg, List<IncentiveChangeLogWrapper> ICLList){

        //Loop through the wrapper list to update the personal Goal effective dates
        for(IncentiveChangeLogWrapper iCLW : ICLList) {
            
            //Instance of ICL wrapper
            IncentiveChangeLogWrapper iCL = new IncentiveChangeLogWrapper();
            
            //Populate values
            iCL.iCLId = iCLW.iCLId;
            iCL.startDate = iCLW.startDate;
            iCL.endDate = iCLW.endDate;
            iCL.pGStartDate = pg.Period_Start__c;
            iCL.pGEndDate = pg.Period_End__c;
            
            //Add Wrapper insatnce in map
            mapPGIdWithICLIds.get(pg.Id).add(iCL);
        }     
    }
    
    /**
     *  @description    :   This method is used to identify the impacts for current Icentive change batch
     *
     *  @args           :   
     *
     *  @return         :   Pagereference
     *
     **/
    public Pagereference indentifyImpact() {
        
        try {
            
            //Get the Batch Id from the URL
            String batchId = ApexPages.currentPage().getParameters().get('id');
            
            //Check for bach Id
            if(String.isNotBlank(batchId) && batchId instanceof Id) {
            
                //Map to hold the Program Id/Program Collection Id/ Relationship Type Id with corresponding IncentiveChangeLogWrappers
                //This map is used to get the Collection Perspective records
                Map<Id, List<IncentiveChangeLogWrapper>> mapPORPCIdORRTIdWithICLIds = new Map<Id, List<IncentiveChangeLogWrapper>>();
                
                //Map to hold the Contact Id with list of IncentiveChangeLogWrapper
                //This map is used in case of Contact and Staff Attribute ICLs
                Map<Id, List<IncentiveChangeLogWrapper>> mapConWithICLIds = new Map<Id, List<IncentiveChangeLogWrapper>>();
                
                //Map to hold the ICL records related to staff attributes
                Map<Id, List<IncentiveChangeLogWrapper>> mapSAConWithICLIds = new Map<Id, List<IncentiveChangeLogWrapper>>();
               
               //Map to hold ICL records related to Assignment Role
                Map<String, List<IncentiveChangeLogWrapper>> mapPayeeWithAssignmentRole = new Map<String, List<IncentiveChangeLogWrapper>>();
                
                //Set to hold unique Assignment Role
                Set<Id> assignmentRoleIds = new Set<Id>();
                
                //Set to hold unique payes
                Set<Id> payeeIds = new Set<Id>();
                
                //Query through the Incentive Change log
                //This query is used to identify the PG for these ICLs and then create affected goals for this
                for(Incentive_Change_Log__c iCL : [Select Id, Category__c, Collection_Perspective_Child__c, Collection_Perspective_Child__r.Program__c,
                                                          Collection_Perspective_Child__r.Effective_Start__c, Collection_Perspective_Child__r.Effective_End__c, 
                                                          Collection_Perspective_Child__r.Program_Group__c, Collection_Perspective_Child__r.Program_Perspective__c,
                                                          Collection_Perspective_Child__r.Program_Perspective__r.Program_Group__c, Contact__c,Start_Date__c, End_Date__c,
                                                          Staff_History__c, Staff_History__r.Staff_Member__c, Staff_History__r.Start_Date__c,
                                                          Staff_History__r.End_Date__c, Applied__c, Change_Element__c, Change_Record__c, Change_Type__c, 
                                                          Change_value__c, Disregard__c, Staff_Assignment__c, Staff_Assignment__r.Start_Date__c, Staff_Assignment__r.End_Date__c,
                                                          Staff_Assignment__r.Role__c, Staff_Assignment__r.Staff_Member__c  
                                                          From Incentive_Change_Log__c Where Incentive_Change_Batch__c =: batchId]) {
                    
                    //Instance of wrapper
                    IncentiveChangeLogWrapper iCLW = new IncentiveChangeLogWrapper();
                    
                    //Populate ICL Id
                    iCLW.iCLId = iCL.Id;
                    
                    //Check that incentive change log is related to Program or Payee
                    if(iCL.Collection_Perspective_Child__c != null) {
                        
                        //Start Date
                        if(iCL.Start_Date__c != null)
                            iCLW.startDate = iCL.Start_Date__c;
                        else
                            iCLW.startDate = iCL.Collection_Perspective_Child__r.Effective_Start__c;
                        
                        //End date
                        if(iCL.End_Date__c != null)
                            iCLW.endDate = iCL.End_Date__c;
                        else
                            iCLW.endDate = iCL.Collection_Perspective_Child__r.Effective_End__c;
                        
                        
                        //Check for Collection Perspective Id
                        if(iCL.Collection_Perspective_Child__r.Program_Perspective__c != null) {
                            
                            //Add Program Collection Id in map
                            if(!mapPORPCIdORRTIdWithICLIds.containsKey(iCL.Collection_Perspective_Child__r.Program_Perspective__c))
                                mapPORPCIdORRTIdWithICLIds.put(iCL.Collection_Perspective_Child__r.Program_Perspective__c, new List<IncentiveChangeLogWrapper>());
                            
                            //Add ICL id in set
                            mapPORPCIdORRTIdWithICLIds.get(iCL.Collection_Perspective_Child__r.Program_Perspective__c).add(iCLW);
                        }
                    //Payee Management case
                    } else if(iCL.Contact__c != null && iCL.Change_Type__c == ISSPConstants.INCENTIVE_CHANGE_LOG_CHANGE_TYPE_MODIFIED) {
                     
                        //Check for ICL effective dates
                        
                        //Start Date
                        if(iCL.Start_Date__c != null)
                            iCLW.startDate = iCL.Start_Date__c;
                        
                        //End date
                        if(iCL.End_Date__c != null)
                            iCLW.endDate = iCL.End_Date__c;
                        
                        //Add Contact Id in map
                        if(!mapConWithICLIds.containsKey(iCL.Contact__c))
                            mapConWithICLIds.put(iCL.Contact__c, new List<IncentiveChangeLogWrapper>());
                        
                        //Add ICL Id in set
                        mapConWithICLIds.get(iCL.Contact__c).add(iCLW);
                    
                    //Check for Various Staff Attribute Lookup
                    }else if(iCL.Staff_History__c != null && iCL.Staff_History__r.Staff_Member__c != null && (iCL.Change_Element__c == ISSPConstants.INCENTIVE_CHANGE_LOG_CHANGE_ElEMENT_BUSINESS_TITLE ||
                            iCL.Change_Element__c == ISSPConstants.INCENTIVE_CHANGE_LOG_CHANGE_ElEMENT_INCENTIVE_ROLE ||
                            iCL.Change_Element__c == ISSPConstants.INCENTIVE_CHANGE_LOG_CHANGE_ElEMENT_PRIMARY_PROGRAM_COLLECTION )){
                        
                        //Start Date
                        if(iCL.Start_Date__c != null)
                            iCLW.startDate = iCL.Start_Date__c;
                        else
                            iCLW.startDate = iCL.Staff_History__r.Start_Date__c;
                        
                        //End date
                        if(iCL.End_Date__c != null)
                            iCLW.endDate = iCL.End_Date__c;
                        else
                            iCLW.endDate = iCL.Staff_History__r.End_Date__c;    
                        
                        //Add Contact Id in map
                        if(!mapSAConWithICLIds.containsKey(iCL.Staff_History__r.Staff_Member__c))
                            mapSAConWithICLIds.put(iCL.Staff_History__r.Staff_Member__c, new List<IncentiveChangeLogWrapper>());
                        
                        //Add ICL Id in set
                        mapSAConWithICLIds.get(iCL.Staff_History__r.Staff_Member__c).add(iCLW);
                        
                    }else if(iCL.Staff_Assignment__c != null && iCL.Staff_Assignment__r.Staff_Member__c != null && iCL.Staff_Assignment__r.Role__c != null){
                        
                        //Add Assignement Role Id in the set
                        payeeIds.add(iCL.Staff_Assignment__r.Staff_Member__c);
                        assignmentRoleIds.add(iCL.Staff_Assignment__r.Role__c);
                        
                        
                        //Start Date
                        if(iCL.Start_Date__c != null)
                            iCLW.startDate = iCL.Start_Date__c;
                        else
                            iCLW.startDate = iCL.Staff_Assignment__r.Start_Date__c; 
                        
                        
                         //End date
                        if(iCL.End_Date__c != null)
                            iCLW.endDate = iCL.End_Date__c;
                        else
                            iCLW.endDate = iCL.Staff_Assignment__r.End_Date__c;
                        
                        String uniqueKey = iCL.Staff_Assignment__r.Staff_Member__c + '-' + iCL.Staff_Assignment__r.Role__c;
                        
                        if(! mapPayeeWithAssignmentRole.containsKey(uniqueKey))
                            mapPayeeWithAssignmentRole.put(uniqueKey, new List<IncentiveChangeLogWrapper>());
                       
                        //Add ICL Id in set
                        mapPayeeWithAssignmentRole.get(uniqueKey).add(iCLW);
                    }
                    
                }
                
                //Check Map Size
                if(mapPayeeWithAssignmentRole.size() > 0){
                    
                    //Loop over conditions
                    for(Condition__c con : [Select Id, Collection_Perspective__c, Collection_Perspective__r.Program_Group__c, Individual_Program__c,
                                                   Personal_Goal__c, Personal_Goal__r.Period_Start__c, Personal_Goal__r.Period_End__c, From_Relationship__c,
                                                   To_Relationship__c, Assignment_Role__c, Personal_Goal__r.Payee__c, Matches_Any_Staff__c
                                                   From Condition__c Where Personal_Goal__c != null AND Personal_Goal__r.RecordType.DeveloperName =: ISSPConstants.PERSONAL_GOAL_RECORD_TYPE_PROPOSAL
                                                   AND (Personal_Goal__r.Period_End__c = null OR Personal_Goal__r.Period_End__c >= TODAY)
                                                   AND Assignment_Role__c IN : assignmentRoleIds AND (Personal_Goal__r.Payee__c IN : payeeIds OR Matches_Any_Staff__c = true)]) {
                        
                        //Create Unique key in order to get list of ICL records from the map
                        String uniqueKey = con.Personal_Goal__r.Payee__c + '-' + con.Assignment_Role__c;
                        
                        //Add Personal Goal in map
                        if(!mapPGIdWithICLIds.containsKey(con.Personal_Goal__c))
                            mapPGIdWithICLIds.put(con.Personal_Goal__c, new List<IncentiveChangeLogWrapper>());
                              
                        if(mapPayeeWithAssignmentRole.containsKey(uniqueKey)){
                            
                            populatePersonalGoalMap(con.Personal_Goal__r, mapPayeeWithAssignmentRole.get(uniqueKey));           
                        }                                   
                    }
                }
                
                if(mapConWithICLIds.size() > 0 || mapPORPCIdORRTIdWithICLIds.size() > 0) {
                    
                    //Loop through the conditions
                    for(Condition__c con : [Select Id, Collection_Perspective__c, Collection_Perspective__r.Program_Group__c, Individual_Program__c,
                                                   Personal_Goal__c, Personal_Goal__r.Period_Start__c, Personal_Goal__r.Period_End__c, From_Relationship__c,
                                                   To_Relationship__c, Staff_Member__c From Condition__c 
                                                   Where Personal_Goal__c != null AND Personal_Goal__r.RecordType.DeveloperName =: ISSPConstants.PERSONAL_GOAL_RECORD_TYPE_PROPOSAL
                                                   AND (Personal_Goal__r.Period_End__c = null OR Personal_Goal__r.Period_End__c >= TODAY)
                                                   AND (Staff_Member__c IN : mapConWithICLIds.keySet() OR Collection_Perspective__c IN : mapPORPCIdORRTIdWithICLIds.keySet())]) {
                        
                        //Add Personal Goal in map
                        if(!mapPGIdWithICLIds.containsKey(con.Personal_Goal__c))
                            mapPGIdWithICLIds.put(con.Personal_Goal__c, new List<IncentiveChangeLogWrapper>());
                        
                        //Check for Collection Perspective
                        if(con.Collection_Perspective__c != null && mapPORPCIdORRTIdWithICLIds.containsKey(con.Collection_Perspective__c)) {
                            
                            populatePersonalGoalMap(con.Personal_Goal__r, mapPORPCIdORRTIdWithICLIds.get(con.Collection_Perspective__c));
                        }
                        
                        //Check for Contact Id Exist in Contact Map
                        if(con.Staff_Member__c != null && mapConWithICLIds.containsKey(con.Staff_Member__c)){
                            
                            populatePersonalGoalMap(con.Personal_Goal__r, mapConWithICLIds.get(con.Staff_Member__c));       
                        }                  
                    }
                    
                    //Query on Staff Attribute In order to Identify associated Payee with Primary Collection Perspective
                    //Check for Collection Perspective map
                    if(mapPORPCIdORRTIdWithICLIds.size() > 0) {
                        
                        //Query through the staff Attribute
                        for(Staff_History__c sH : [Select Id, Lookup_Value__c, Staff_Member__c From Staff_History__c Where Staff_Member__c != null
                                                                                               AND Lookup_Value__c IN : mapPORPCIdORRTIdWithICLIds.keySet()]) {
                            //Add Staff Member in map
                            if(!mapSAConWithICLIds.containsKey(sH.Staff_Member__c))
                                mapSAConWithICLIds.put(sH.Staff_Member__c, new List<IncentiveChangeLogWrapper>());
                            
                            //Add ICL record in map
                            mapSAConWithICLIds.get(sH.Staff_Member__c).addAll(mapPORPCIdORRTIdWithICLIds.get(sH.Lookup_Value__c));                                                                         
                        }
                                                                                                 
                    }
                }
                
                //Check for contact Map
                if(mapConWithICLIds.size() > 0 || mapSAConWithICLIds.size() > 0 ) {
                    
                    //Query through the Personal Goal
                    for(Personal_Goal__c pG : [Select Id, Payee__c, Period_Start__c, Period_End__c From Personal_Goal__c
                                                                    Where Payee__c != null AND (Payee__c IN : mapConWithICLIds.keySet() OR Payee__c IN: mapSAConWithICLIds.keySet()) 
                                                                    AND RecordType.DeveloperName =: ISSPConstants.PERSONAL_GOAL_RECORD_TYPE_PROPOSAL]) {
                        
                        //Add Personal Goal in map
                        if(!mapPGIdWithICLIds.containsKey(pG.Id))
                            mapPGIdWithICLIds.put(pG.Id, new List<IncentiveChangeLogWrapper>());
                        
                        //Check for Effective date
                        if(mapConWithICLIds.containsKey(pG.Payee__c)) {
                        
                            populatePersonalGoalMap(pg, mapConWithICLIds.get(pG.Payee__c));
                        }
                        if(mapSAConWithICLIds.containsKey(pG.Payee__c))
                            populatePersonalGoalMap(pg, mapSAConWithICLIds.get(pG.Payee__c));
                    }
               
                    
                    //Query through the Personal Goal Relationships
                    for(Personal_Goal_Relationship__c pGR : [Select Id, Personal_Goal__c, Personal_Goal__r.Period_Start__c, Personal_Goal__r.Period_End__c,
                                                                        Relationship__c, Relationship__r.From__c, Relationship__r.To__c From Personal_Goal_Relationship__c Where
                                                                        Relationship__c != null AND (Relationship__r.From__c IN : mapConWithICLIds.keySet() OR Relationship__r.To__c IN : mapConWithICLIds.keySet())
                                                                        AND Personal_Goal__r.RecordType.DeveloperName =: ISSPConstants.PERSONAL_GOAL_RECORD_TYPE_PROPOSAL]) {
                        //Add Personal Goal in map
                        if(!mapPGIdWithICLIds.containsKey(pGR.Personal_Goal__c))
                            mapPGIdWithICLIds.put(pGR.Personal_Goal__c, new List<IncentiveChangeLogWrapper>());
                        
                        //Check for Relationship
                        if(mapConWithICLIds.containsKey(pGR.Relationship__r.From__c)) {
                            
                            populatePersonalGoalMap(pGR.Personal_Goal__r, mapConWithICLIds.get(pGR.Relationship__r.From__c));
                            
                        }else if(mapConWithICLIds.containsKey(pGR.Relationship__r.To__c)){
                            
                            populatePersonalGoalMap(pGR.Personal_Goal__r, mapConWithICLIds.get(pGR.Relationship__r.To__c)); 
                        }
                    }
                }
                
                //Check for Personal Goal Map
                if(mapPGIdWithICLIds.size() > 0) {
                    
                    //Map to hold the Persoanl Goal Id with ICL Ids
                    //This map is used to insert Affacted Goal records
                    Map<Id, List<IncentiveChangeLogWrapper>> mapProposalIdWithICLIds = new Map<Id, List<IncentiveChangeLogWrapper>>();
                    
                    //Query through the Personal Goals
                    //This query is used to find out that Proposal is stamp as Active Proposal on the Personal goal or not
                    for(Personal_Goal__c pG : [Select Id, Active_Proposal__c From Personal_Goal__c Where Active_Proposal__c IN : mapPGIdWithICLIds.keySet()
                                                                                                         AND Active_Proposal__c != null]) {
                        
                        //Check for Active Perposal
                        if(mapPGIdWithICLIds.containsKey(pG.Active_Proposal__c)) {
                            
                            //Add Active Proposal in map
                            if(!mapProposalIdWithICLIds.containsKey(pG.Active_Proposal__c))
                                mapProposalIdWithICLIds.put(pG.Active_Proposal__c, new List<IncentiveChangeLogWrapper>()); {
                                    
                                //Add ICL Ids
                                mapProposalIdWithICLIds.get(pG.Active_Proposal__c).addAll(mapPGIdWithICLIds.get(pG.Active_Proposal__c));        
                            }
                        }
                    }
                    
                    //Check for Proposal map size
                    if(mapProposalIdWithICLIds.size() > 0) {
                        
                        //Set to hold the existing affected goals unqiue combo (Personal Goal - ICL - ICB)
                        Set<String> setExisingAGCombination = new Set<String>();
                        
                        //Query through the Affected Goals
                        for(Affected_Goal__c aG : [Select Id, Incentive_Change_Log__c, Incentive_Change_Batch__c, Personal_Goal__c From Affected_Goal__c
                                                               Where Incentive_Change_Batch__c =: batchId AND Personal_Goal__c IN : mapProposalIdWithICLIds.keySet()])
                            setExisingAGCombination.add(aG.Personal_Goal__c + '-' + aG.Incentive_Change_Log__c);
                        
                        
                        //Map to insert Affacted Goals
                        Map<String, Affected_Goal__c> mapAffectedGoals = new Map<String, Affected_Goal__c>();
                        
                        
                        //Loop through the Personal Goal map
                        for(Id pId : mapProposalIdWithICLIds.keySet()) {
                            
                            //Loop through the ICL Wrapper
                            for(IncentiveChangeLogWrapper iCLW : mapProposalIdWithICLIds.get(pId)) {
                                
                                //Check for unique date
                                if(iCLW.pGEndDate == null || iCLW.pGEndDate > System.today()) {
                                    
                                    //Unique Key
                                    String unqiueKey = pId + '-' + iCLW.iCLId;
                                
                                    //Check unqiue key in existing AG set and new map
                                    if(!setExisingAGCombination.contains(unqiueKey) && !mapAffectedGoals.containsKey(unqiueKey)) {
                                        
                                        //Add new Affected goal
                                        Affected_Goal__c aG = new Affected_Goal__c();
                                        
                                        //Populate field values
                                        aG.Personal_Goal__c = pId;
                                        aG.Incentive_Change_Log__c = iCLW.iCLId;
                                        aG.Incentive_Change_Batch__c = batchId;
                                        
                                        //Add Affected goal in map
                                        mapAffectedGoals.put(unqiueKey, aG);
                                        
                                        //Add Unique combo in set
                                        setExisingAGCombination.add(unqiueKey);
                                    }
                                }
                            }
                        }
                        
                        //Check for new affected goals
                        if(mapAffectedGoals.size() > 0) {
                            
                            //Insert
                            insert mapAffectedGoals.values();
                            
                            //Create a new task for batch
                            Task tsk = new Task();
                            
                            //Populate field values
                            tsk.OwnerId = Userinfo.getUserId();
                            tsk.WhatId = batchId;
                            tsk.Subject = ISSPConstants.TASK_SUBJECT_IMPACTS_IDENTIFIED;
                            tsk.ActivityDate = System.today();
                            tsk.Status = 'Completed';
                            
                            //Insert
                            insert tsk;
                        }   
                    }
                }
                
                //Return
                return new Pagereference('/apex/ViewAffectedGoals?id=' + batchId);
            }
        } catch(Exception e) {
            
            //Add error on page
            ApexPages.addMessages(e);
            
            return null;
        }
        
        //return
        return null;
    }
    
    //Wrapper class to hold the ICL data
    public class IncentiveChangeLogWrapper {
        
        //Variables
        public Id iCLId;
        public Date startDate;
        public Date endDate;
        public Date pGStartDate;
        public Date pGEndDate;
        
        //Constructor
        public IncentiveChangeLogWrapper() {}
    }
}