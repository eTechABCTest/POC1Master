/**
 *  Purpose            :    This class is used to create hole html body & control logic of "Assign New Goals to Plans" page.
 *                          Class is runing in without sharing. As VF page access is controlling by permission set, so this won't impact anything.
 *                          Users only having CRED access having access to all Incentive projects and they wants to delete others records through the VF page,
 *                          this only possiable using without sharing.
 *
 *  Created By         :    Subhash Garhwal
 *
 *  Created Date       :    10/09/2015
 *
 *  Revision Log       :    V_1.0 - Created - CR-20150729-9114 - Goal Management System
 *                          V_1.1 - Modified - Subhash Garhwal - 11/30/2015 - CR-20151120-9407 - PGMP functionality.
 *                          V_1.2 - Modified - Subhash Garhwal - 12/18/2015 - CR-20151217-9469 - ISSP Deployment C.
 *                          V_1.3 - Modified - Subhash Garhwal - 01/07/2016 - CR-20160106-9491
 *                          V_1.4 - Modified - Rajeev Jain - 02/25/2016 - CR-20160115-9543 - Replace where Clause to check Status =  Submitted to Status LIKE Submitted
 *                          V_1.5 - Modified - Rajeev Jain - 04/11/2016 - CR-20160309-9688 - ISSP Deployment E - Removed Tenure Column, add read only tenure on Hover popup               
 **/
public without sharing class AssignNewGoalsToPlansController {
    
    //Class properties
    public Personal_Goal__c personalGoal {get; set;}
    public Staff_History__c staffHistory {get;set;}
    public Boolean isTenured {get;set;}
    public List<AssignmentGoalToPlanWrapper> assignWrapperList {get; set;}
    public List<GoalsToPlanAssignmentWrapper> selectedPersonalGoalsWrapper {get;set;}
    public List<GoalHeaderWrapper> goalHeaders {get;set;}
    Map<Id, GoalHeaderWrapper> mapGoalHeaders;
    
    //Added - Subhash Garhwal - 11/30/2015 - CR-20151120-9407
    public List<GoalsToPlanAssignmentWrapper.PGMeasurementPeriod> pGMPeriods {get;set;}
    public Personal_Goal_Measurement_Period__c pGMPeriod {get;set;}
    public Integer mainRow {get;set;}
    public Integer pGRow {get;set;}
    
    //Set to hold the PGMP Ids (This will use to remove the PGMPs)
    Set<Id> setPGMPs;
    
    //Local variables
    Map<Id, Personal_Plan__c> mapPersonalPlans;
    Map<Id, String> mapRTNameWithId;
    
    //Map to hold the Payee Id with Personal Plan Properties wrapper
    Map<Id,PPMinMaxWrapper> mapPPMinMaxWrapper;
    
    //Map to hold the Payee Id as key and Set of Snapshot as values
    Map<Id, Set<Id>> mapPIdWithSetPGIds;
        
    //Set to hold Personal Goal Ids
    List <Personal_Goal__c> selectedPersonalGoals;
   
    //Blank Constructor
    public AssignNewGoalsToPlansController(){
        
        //inIt method
        inIt();
    }
    
    /**
     *  @description    :   This method is to load or initialized view of page with reflected data set.
     *
     *  @param          :
     *
     *  @return         :   void
     **/
    public void inIt() {
        
        //Initialize properties
        personalGoal = new Personal_Goal__c();
        staffHistory = new Staff_History__c();
        assignWrapperList = new List<AssignmentGoalToPlanWrapper>();
        selectedPersonalGoalsWrapper = new List<GoalsToPlanAssignmentWrapper>();
        goalHeaders = new List<GoalHeaderWrapper>();
        isTenured = false;
        mapGoalHeaders = new Map<Id, GoalHeaderWrapper>();
        mapPersonalPlans = new Map<Id, Personal_Plan__c>();
        mapRTNameWithId = new Map<Id, String>();
        mapPPMinMaxWrapper = new Map<Id,PPMinMaxWrapper>();
        pGMPeriods = new List<GoalsToPlanAssignmentWrapper.PGMeasurementPeriod>();
        pGMPeriod = new Personal_Goal_Measurement_Period__c();
        setPGMPs = new Set<Id>();
        mapPIdWithSetPGIds = new Map<Id, Set<Id>>();
            
        //Call method
        loadPersonalGoalData();
    }
    
    /**
     *  @description    :   This method is used to load the personal goal data
     *
     *  @args           :
     *
     *  @return         :   void
     *
     **/
    public void loadPersonalGoalData() {
        
        //Re-Initialize properties
        assignWrapperList = new List<AssignmentGoalToPlanWrapper>();
        goalHeaders = new List<GoalHeaderWrapper>();
        mapGoalHeaders = new Map<Id, GoalHeaderWrapper>();
        
        //Dynamic SOQL String variable to query on the Staff Attributes
        String SOQL = 'Select Id, Staff_Member__c, Staff_Member__r.Name From Staff_History__c Where';
        
        //Map to hold the Payee Id with AssignmentGoalToPlanWrapper
        Map<Id, AssignmentGoalToPlanWrapper> mapPayeeWithGoals = new Map<Id, AssignmentGoalToPlanWrapper>();
        
        //Map to hold the contact Id with Name
        Map<Id, String> mapContacts = new Map<Id, String>();
        
        //Map to hold Payee Id and true or false value corrosponding to it to tell, if eligible for payee.
        Map<Id, Boolean> mapPayeeIsTenured = new Map<Id, Boolean>();
        
        //V_1.5 - Modified - Rajeev Jain - 04/11/2016 - CR-20160309-9688 - ISSP Deployment E - Commented in order to change the filter setting when tenure selected
        //Filters
        if(personalGoal.Business_Title__c != null || personalGoal.Value_Type__c != null || staffHistory.Lookup_Value__c != null || isTenured) {
        
            //Set to hold the Value Types
            Set<Id> setVTIds = new Set<Id>();
            
            //Business Title
            if(personalGoal.Business_Title__c != null)
                setVTIds.add(personalGoal.Business_Title__c);
            
            //Incentive Role
            if(personalGoal.Value_Type__c != null)
                setVTIds.add(personalGoal.Value_Type__c);
            
            //Add Filter in SOQL
            if(setVTIds.size() > 0)
                SOQL += ' Value_Type__c IN : setVTIds OR';
            
            //Program Collection
            if(staffHistory.Lookup_Value__c != null)
                SOQL += ' Lookup_Value__c = \'' + staffHistory.Lookup_Value__c + '\' OR';
            
            //V_1.5 - Modified - Rajeev Jain - 04/11/2016 - CR-20160309-9688 - ISSP Deployment E - Commented in order to change the filter setting when tenure selected
            //Tenured
            //if(isTenured)
                //SOQL += ' (Value_Type__r.Name = \'Tenure\' AND Value_Type__r.Category__c = \'Other\')';
            
            //V_1.5 - Modified - Rajeev Jain - 04/11/2016 - CR-20160309-9688 - ISSP Deployment E - Commented in order to change the filter setting when tenure selected - upto here
            
            //Remove extra characters from SOQL
            SOQL = SOQL.removeEnd('Where').removeEnd('OR');
            
            System.debug('####### SOQL : ' +SOQL);
            
            //Query through the Staff Attributes to get the Payee according to filter criteria
            for(Staff_History__c sA : database.query(SOQL)) {
                
                //Check for Payee Id
                if(sA.Staff_Member__c != null)
                    mapContacts.put(sA.Staff_Member__c, sA.Staff_Member__r.Name);  
            }
            
            String submitedStatus = '%' + ISSPConstants.PERSONAL_GOAL_STATUS_SUBMITTED + '%' ;  
            
            //Query through the personal goals and add satff member Id in set
            for(Personal_Goal__c pG : [Select Id, Name, Payee__c, Payee__r.Name, Tenure__c From Personal_Goal__c Where Personal_Plan__c = null AND Payee__c != null
                                                                 AND RecordType.DeveloperName =: ISSPConstants.PERSONAL_GOAL_RECORD_TYPE_PROPOSAL
                                                                     AND Status__c Like :submitedStatus]){
                //if any of the Pg is having tenured checked , that means that payee is avaialble on the page
                if(pG.Tenure__c && !mapContacts.containsKey(pG.Payee__c)){
                    mapContacts.put(pG.Payee__c, pG.Payee__r.Name); 
                    mapPayeeIsTenured.put(pG.Payee__c, true);
                }
            }   
        }else {
            
            String submitedStatus = '%' + ISSPConstants.PERSONAL_GOAL_STATUS_SUBMITTED + '%' ;  
            //Query through the personal goals and add satff member Id in set
            for(Personal_Goal__c pG : [Select Id, Name, Payee__c, Payee__r.Name From Personal_Goal__c Where Personal_Plan__c = null AND Payee__c != null
                                                                 AND RecordType.DeveloperName =: ISSPConstants.PERSONAL_GOAL_RECORD_TYPE_PROPOSAL
                                                                 AND Status__c Like :submitedStatus])
                mapContacts.put(pG.Payee__c, pG.Payee__r.Name);
        }
            
        //Check for set size
        if(mapContacts.size() > 0) {
            
            //Query through the Staff Attributes to prepare the available payee
            for(Staff_History__c sH : [Select Id, Name, Value__c, Staff_Member__c, Staff_Member__r.Name, Value_Type__c, Value_Type__r.Name,
                                              Value_Type__r.Category__c, Lookup_Value__c,Lookup_Value__r.Program_Group__c,Lookup_Value__r.Name  
                                              From Staff_History__c Where Staff_Member__c IN : mapContacts.keySet()]) {
                
                //Check if map contains the payee
                if(!mapPayeeWithGoals.containsKey(sH.Staff_Member__c)) {                            
                    
                    //Instance of wrapper
                    AssignmentGoalToPlanWrapper goalsWrapper = new AssignmentGoalToPlanWrapper();
                    
                    //Populate field values
                    goalsWrapper.conId = sH.Staff_Member__c;
                    goalsWrapper.conName = sH.Staff_Member__r.Name;
                    goalsWrapper.businessTitle = sH.Value_Type__c != null && sH.Value_Type__r.Category__c == ISSPConstants.VALUE_TYPE_CATEGORY_BUSINESS_TITLE
                                                 ? sH.Value__c : '';
                    
                    goalsWrapper.businessTitleId = sH.Value_Type__c != null && sH.Value_Type__r.Category__c == ISSPConstants.VALUE_TYPE_CATEGORY_BUSINESS_TITLE
                                                 ? sH.Value_Type__c : null;
                    
                    goalsWrapper.incentiveRole = sH.Value_Type__c != null && sH.Value_Type__r.Category__c == ISSPConstants.VALUE_TYPE_CATEGORY_INCENTIVE_ROLE
                                                 ? sH.Value__c : '';
                    
                    goalsWrapper.incentiveRoleId = sH.Value_Type__c != null && sH.Value_Type__r.Category__c == ISSPConstants.VALUE_TYPE_CATEGORY_INCENTIVE_ROLE
                                                 ? sH.Value_Type__c : null;
                    
                    /*goalsWrapper.tenured = sH.Value_Type__c != null && sH.Value_Type__r.Category__c == ISSPConstants.VALUE_TYPE_CATEGORY_OTHER
                                           && sH.Value_Type__r.Name == ISSPConstants.VALUE_TYPE_NAME_TENURE ? true : false;*/
                    
                    goalsWrapper.tenured = mapPayeeIsTenured.containsKey(sH.Staff_Member__c) ? true : false;
                    
                    goalsWrapper.programCollection = sH.Lookup_Value__c != null ? sH.Lookup_Value__r.Name : '';
                    goalsWrapper.programCollectionId = sH.Lookup_Value__c != null ? sH.Lookup_Value__c : null;
                    
                    //Put Payee in map
                    mapPayeeWithGoals.put(sH.Staff_Member__c,goalsWrapper);
                
                } else if(sH.Value_Type__c != null) {
                        
                    //Check for business title
                    if(sH.Value_Type__r.Category__c == ISSPConstants.VALUE_TYPE_CATEGORY_BUSINESS_TITLE) {
                        
                        //Set value
                        mapPayeeWithGoals.get(sH.Staff_Member__c).businessTitle = sH.Value__c;
                        mapPayeeWithGoals.get(sH.Staff_Member__c).businessTitleId = sH.Value_Type__c;       
                    
                    //Check for Incentive Role
                    } else if(sH.Value_Type__r.Category__c == ISSPConstants.VALUE_TYPE_CATEGORY_INCENTIVE_ROLE) {
                        
                        //Set Value
                        mapPayeeWithGoals.get(sH.Staff_Member__c).incentiveRole = sH.Value__c;
                        mapPayeeWithGoals.get(sH.Staff_Member__c).incentiveRoleId = sH.Value_Type__c;
                    
                    //Check for Tenured
                    }/* else if(sH.Value_Type__r.Category__c == ISSPConstants.VALUE_TYPE_CATEGORY_OTHER && sH.Value_Type__r.Name == ISSPConstants.VALUE_TYPE_NAME_TENURE)
                        mapPayeeWithGoals.get(sH.Staff_Member__c).tenured = true;*/
                    else if(mapPayeeIsTenured.containsKey(sH.Staff_Member__c))
                        mapPayeeWithGoals.get(sH.Staff_Member__c).tenured = true;
                            
                    //Check for Collection Perspective
                    if(sH.Lookup_Value__c != null && String.isBlank(mapPayeeWithGoals.get(sH.Staff_Member__c).programCollection)) {
                        
                        //Set Program Collection
                        mapPayeeWithGoals.get(sH.Staff_Member__c).programCollection = sH.Lookup_Value__r.Name;
                        mapPayeeWithGoals.get(sH.Staff_Member__c).programCollectionId = sH.Lookup_Value__c;
                    
                    } else if(sH.Lookup_Value__c != null && sH.Lookup_Value__c == staffHistory.Lookup_Value__c) {
                        
                        //Set Program Collection
                        mapPayeeWithGoals.get(sH.Staff_Member__c).programCollection = sH.Lookup_Value__r.Name;
                        mapPayeeWithGoals.get(sH.Staff_Member__c).programCollectionId = sH.Lookup_Value__c;
                    }   
                }
            }
            
            //Loop through the Contact map to add remaning contacts
            for(Id cId : mapContacts.keySet()) {
                
                //Check if map contains the contact Id
                if(!mapPayeeWithGoals.containsKey(cId)) {
                    
                    //Instance of wrapper
                    AssignmentGoalToPlanWrapper goalsWrapper = new AssignmentGoalToPlanWrapper();
                    
                    //Populate field values
                    goalsWrapper.conId = cId;
                    goalsWrapper.conName = mapContacts.get(cId);
                    goalsWrapper.businessTitle = '';
                    goalsWrapper.businessTitleId = null;
                    goalsWrapper.incentiveRole = '';
                    goalsWrapper.incentiveRoleId = null;
                    goalsWrapper.tenured = false;
                    goalsWrapper.programCollection = '';
                    goalsWrapper.programCollectionId = null;
                    
                    //Put Payee in map
                    mapPayeeWithGoals.put(cId,goalsWrapper);
                }
            }
            
            //Loop through the map key set
            for(Id payeeId : mapPayeeWithGoals.keySet()) {
                
                //Flag to remove the Payee from list
                Boolean isValidPayee = true;
                
                //Check for values according to filter
                
                //Check for business title
                if(personalGoal.Business_Title__c != null && mapPayeeWithGoals.get(payeeId).businessTitleId != personalGoal.Business_Title__c)
                    isValidPayee = false;
                
                //Check for Incntive Role
                if(personalGoal.Value_Type__c != null && mapPayeeWithGoals.get(payeeId).incentiveRoleId != personalGoal.Value_Type__c)
                    isValidPayee = false;
                
                //Check for tenure
                if(isTenured && (!mapPayeeWithGoals.get(payeeId).tenured || !mapPayeeIsTenured.containsKey(payeeId)))
                    isValidPayee = false;
                
                //Check for Collection Perspective
                if(staffHistory.Lookup_Value__c != null && mapPayeeWithGoals.get(payeeId).programCollectionId != staffHistory.Lookup_Value__c)
                    isValidPayee = false;
                
                //Check for flag
                if(!isValidPayee)
                    mapPayeeWithGoals.remove(payeeId);              
            }
            
            //Check for map size
            if(mapPayeeWithGoals.size() > 0) {
                
                //Set to hold the Payee Ids
                Set<Id> setPayeeIds = new Set<Id>();
                
                String submitedStatus = '%' + ISSPConstants.PERSONAL_GOAL_STATUS_SUBMITTED + '%' ;
                
                //Query through the Personal Goals to get the all submitted proposed goals related to payee
                for(Personal_Goal__c pG : [Select Id, Payee__c From Personal_Goal__c Where Payee__c IN : mapPayeeWithGoals.keySet()
                                                  AND Payee__c != null AND Status__c Like :submitedStatus
                                                  AND RecordType.DeveloperName =: ISSPConstants.PERSONAL_GOAL_RECORD_TYPE_PROPOSAL])
                    setPayeeIds.add(pG.Payee__c);
                
                //Where Clause String
                String whereClause = ' RecordType.DeveloperName = \'Proposal\' AND Goal_Type__c != null AND Payee__c != null AND Payee__c IN : setPayeeIds'
                                     + ' AND Status__c Like \'%Submitted%\'';
                
                //V_1.5 - Modified - Rajeev Jain - 04/11/2016 - CR-20160309-9688 - ISSP Deployment E
                //Added tenure fields in query
                //SOQL string for personal goals
                String pGSOQL = 'Select Id, Name, Payee__c, Description__c, Active__c, Period__c, Payee__r.Name, Value__c, Amount__c, Count__c, Percent__c, Goal_Type__c, Weighting__c, '
                                + 'Goal_Type__r.Name, Personal_Plan__c, Period_Start__c, Period_End__c, Rate_Template__c, Primary_Goal__c, Primary_Goal__r.Personal_Plan__c, Primary_Goal__r.Status__c,'
                                + ' Primary_Goal__r.Active_Proposal__c, Status__c, Standard_Goal_Detail__c, Standard_Goal_Detail__r.Target_Type__c, Primary_Goal__r.Active__c, '
                                + ' Goal_Type__r.Discount_Type__c, Adjustment__c, Supersedes__c, Supersedes__r.Primary_Goal__c, Supersedes__r.Active__c, Supersedes__r.Primary_Goal__r.Active__c, '
                                + ' Supersedes__r.Primary_Goal__r.Status__c, Supersedes__r.Primary_Goal__r.Active_Proposal__c, Tenure_Percentage__c, Tenure__c From Personal_Goal__c Where';
                
                //V_1.5 - Modified - Rajeev Jain - 04/11/2016 - CR-20160309-9688 - ISSP Deployment E - upto here
                
                //Check for where clause
                if(String.isNotBlank(whereClause))
                    pGSOQL += whereClause;
                
                //Map to hold the Payee Id with Map of Goal Type and Personal Goals
                Map<Id, Map<Id,List<Personal_Goal__c>>> mapPersonalGoals = new Map<Id, Map<Id,List<Personal_Goal__c>>>();
                
                System.debug('##########pGSOQL : ' +pGSOQL);
                
                //Query through the Personal Goals
                List<Personal_Goal__c> personalGoals = database.query(pGSOQL);
                        
                //Map to hold the Personal Goal Ids with List of conditions
                Map<Id, List<Condition__c>> mapPGIdWithConditions = new Map<Id, List<Condition__c>>();  
                
                //Loop through the Personal Goal
                for(Personal_Goal__c pG : personalGoals) {
                    
                    //Check if set contains the goal type Id
                    if(!mapGoalHeaders.containsKey(pG.Goal_Type__c)) {
                        
                        //Instance of Header Wrapper
                        GoalHeaderWrapper gHW = new GoalHeaderWrapper(pG.Goal_Type__r.Name, pG.Goal_Type__c);
                        
                        //Add Header in list
                        goalHeaders.add(gHW);
                        
                        mapGoalHeaders.put(pG.Goal_Type__c, gHW);
                    }
                    
                    //Check if map contains the Payee Id
                    if(!mapPersonalGoals.containsKey(pG.Payee__c))
                        mapPersonalGoals.put(pG.Payee__c, new Map<Id, List<Personal_Goal__c>>());
                    
                    //Check if map contains the Goal Type Id
                    if(!mapPersonalGoals.get(pG.Payee__c).containsKey(Pg.Goal_Type__c))
                        mapPersonalGoals.get(pG.Payee__c).put(pg.Goal_Type__c, new List<Personal_Goal__c>());
                    
                    //Add Personal Goal in the map
                    mapPersonalGoals.get(pG.Payee__c).get(pg.Goal_Type__c).add(pG); 
                    
                    //Check Personal Goal in map
                    if(!mapPGIdWithConditions.containsKey(pG.Id))
                        mapPGIdWithConditions.put(pG.Id, new List<Condition__c>());
                }
                
                //Check for map
                if(mapPersonalGoals.size() > 0) {
                    
                    //Query through the Conditions
                    for(Condition__c con : [Select Id, Personal_Goal__c, RecordTypeId, RecordType.DeveloperName, RecordType.Name, Value__c From Condition__c
                                                                                       Where Personal_Goal__c IN : mapPGIdWithConditions.keySet()])
                        //Add Condition in the map
                        mapPGIdWithConditions.get(con.Personal_Goal__c).add(con);
                    
                    //Map to hold the Payee Id with max counter for personal goals
                    Map<Id, Integer> mapPayeeWithMaxCounter = new Map<Id, Integer>();
                    
                    //Loop through the payees map
                    for(Id payeeId : mapPersonalGoals.keySet()) {
                        
                        //Variable to hold the max row count for payee
                        Integer maxRows = 0;
                        
                        //Loop throught goal types
                        for(Id gTId : mapPersonalGoals.get(payeeId).keySet()) {
                            
                            //Check for max row size
                            if(maxRows < mapPersonalGoals.get(payeeId).get(gTId).size())
                                maxRows = mapPersonalGoals.get(payeeId).get(gTId).size();   
                        }
                        
                        //Put max row count in map
                        mapPayeeWithMaxCounter.put(payeeId, maxRows);
                        
                        //Loop through the goal Type Ids to add the goal types that are not having any personal goal for payee
                        for(Id gTId : mapGoalHeaders.keySet()) {
                            
                            //Check if payee id having Personal goal for this goal type
                            if(!mapPersonalGoals.get(payeeId).containsKey(gTId))
                                mapPersonalGoals.get(payeeId).put(gTId, new List<Personal_Goal__c>());
                        }
                    }
                    
                    /************************       This loop is used to draw the Personal goals data on the VF page.      ***************************/
                    
                    //Loop through the Payee Id to perepare the Personal Goals list
                    for(Id payeeId : mapPersonalGoals.keySet()) {
                        
                        //List of Goal Type Wrapper
                        List<AssignmentGoalToPlanWrapper.GoalTypeWrapper> goalTypeWrapperList = new List<AssignmentGoalToPlanWrapper.GoalTypeWrapper>();
                        
                        //Map to hold the Row index with select checkbox
                        Map<Integer, Boolean> mapSelectableRows = new Map<Integer, Boolean>();
                        
                        //Max rows
                        Integer maxRows = mapPayeeWithMaxCounter.get(payeeId);
                       
                        //Loop through the goal Type Ids
                        for(GoalHeaderWrapper gHW : goalHeaders) {
                            
                            //List of Personal Goal wrapper
                            List<AssignmentGoalToPlanWrapper.PersonalGoalWrapper> personalGoalWrapperList = new List<AssignmentGoalToPlanWrapper.PersonalGoalWrapper>();
                            
                            //Goal Type Id
                            Id gTId = gHW.gTId;
                            
                            //Check if personal goals map contains the goal Type
                            if(mapPersonalGoals.get(payeeId).containsKey(gTId)) {
                            
                                //Total Proceed Rows
                                Integer proceedRows = 0;
                                
                                //Loop through the Personal Goals
                                for(Personal_Goal__c pG : mapPersonalGoals.get(payeeId).get(gTId)) {
                                    
                                    //Incrise the row counter
                                    proceedRows++;
                                    
                                    
                                    //Add row in map
                                    if(!mapSelectableRows.containsKey(proceedRows))
                                        mapSelectableRows.put(proceedRows, false);
                                    
                                    //Variable to hold the Period
                                    String period = pG.Period__c;
                                    
                                    //Check for period
                                    if(period == null || String.isBlank(period)) {
                                        
                                        //Check for Personal Goal start date
                                        if(pG.Period_Start__c != null)
                                            period = period + pG.Period_Start__c.month() + '/' + pG.Period_Start__c.day();
                                        
                                        //Check for Personal Goal end date
                                        if(pG.Period_End__c != null)
                                            period = period + '-' + pG.Period_End__c.month() + '/' + pG.Period_End__c.day();            
                                    }
                                    
                                    //Instance of Personal Goal Wrapper
                                    AssignmentGoalToPlanWrapper.PersonalGoalWrapper pGWrap = new AssignmentGoalToPlanWrapper.PersonalGoalWrapper();
                                    
                                    //Populate field values for personal goal wrapper
                                    pGWrap.personalGoal = pG;
                                    pGWrap.conditions = mapPGIdWithConditions.get(pG.Id);
                                    pGWrap.hasPP = !pG.Status__c.contains(ISSPConstants.PERSONAL_GOAL_STATUS_SUBMITTED) ? true : false;
                                    pGWrap.hasEmptyRow = false;
                                    pGWrap.period = period;
                                    
                                    //Check for GTD
                                    if(pG.Adjustment__c != null && pG.Adjustment__c > 0 && pG.Goal_Type__c != null && pG.Goal_Type__r.Discount_Type__c == ISSPConstants.GOAL_TYPE_DISCOUNT_TYPE_EXPLICIT)
                                        pGWrap.pGsteps = '(' + pG.Adjustment__c + ')';  
                                    
                                    /** Decide color of the personal goal based on its Related Goal (Primary_Goal__c) properties
                                        1 - Green   :   If related goal's persoanl plan lookup is blank
                                        2 - Yellow  :   If related goal's Status is 'Pending'
                                        3 - Red     :   If related goal's Status is 'Payee Approved'
                                    **/
                                    
                                    if(pG.Primary_Goal__r.Personal_Plan__c == null && pG.Supersedes__c == null)
                                        pGWrap.pgColor = ISSPConstants.PERSONAL_GOAL_COLOR_GREEN;
                                    else if(pG.Primary_Goal__r.Status__c == ISSPConstants.PERSONAL_GOAL_STATUS_PENDING
                                            || (pG.Supersedes__r.Primary_Goal__c != null && pG.Supersedes__r.Primary_Goal__r.Status__c == ISSPConstants.PERSONAL_GOAL_STATUS_PENDING))
                                        pGWrap.pgColor = ISSPConstants.PERSONAL_GOAL_COLOR_YELLOW;
                                    else if(pG.Primary_Goal__r.Status__c == ISSPConstants.PERSONAL_GOAL_STATUS_PAYEE_APPROVED
                                        || (pG.Supersedes__c != null && pG.Supersedes__r.Primary_Goal__c != null && pG.Supersedes__r.Primary_Goal__r.Status__c == ISSPConstants.PERSONAL_GOAL_STATUS_PAYEE_APPROVED))
                                        pGWrap.pgColor = ISSPConstants.PERSONAL_GOAL_COLOR_RED;
                                    
                                    //Add Personal Goal wrapper in list
                                    personalGoalWrapperList.add(pGWrap);
                                    
                                    //Check row in map
                                    if(pG.Status__c.contains(ISSPConstants.PERSONAL_GOAL_STATUS_SUBMITTED))
                                        mapSelectableRows.put(proceedRows, true);   
                                }
                                
                                //Check for total proceed row
                                if(proceedRows < maxRows) {
                                    
                                    //Loop to add the blank personal goal wrapper instance
                                    for(Integer i = proceedRows; i < maxRows; i++) {
                                        
                                        //Instance of Personal Goal Wrapper
                                        AssignmentGoalToPlanWrapper.PersonalGoalWrapper pGWrap = new AssignmentGoalToPlanWrapper.PersonalGoalWrapper();
                                        pGWrap.hasEmptyRow = true;
                                        
                                        //Add Personal Goal wrapper in list
                                        personalGoalWrapperList.add(pGWrap);
                                        
                                        //Add Row in the selected Rows map
                                        if(!mapSelectableRows.containsKey(i+1))
                                            mapSelectableRows.put(i+1, false);    
                                    }
                                }
                                
                                //Instance of Personal Goal wrapper
                                AssignmentGoalToPlanWrapper.GoalTypeWrapper gTWrapper = new AssignmentGoalToPlanWrapper.GoalTypeWrapper(gTId);
                                
                                //Populate field values
                                gTWrapper.personalGoals = personalGoalWrapperList;
                                
                                //Add Goal Type wrapper instance in list
                                goalTypeWrapperList.add(gTWrapper);
                            }
                            
                        }
                        
                        //Instance of Payee Wrapper
                        AssignmentGoalToPlanWrapper payeeWrapper = new AssignmentGoalToPlanWrapper();
                        
                        //Map for checkbox functionality
                        Map<Integer, Boolean> mapSelection = new Map<Integer, Boolean>();
                        
                        //Loop through the selectable map
                        for(Integer i : mapSelectableRows.keySet())
                            mapSelection.put(i,false);  
                        
                        //Get details from Payee Map
                        payeeWrapper = mapPayeeWithGoals.get(payeeId);
                        
                        //Add Goal Type Wrapper list
                        payeeWrapper.goalTypes = goalTypeWrapperList;
                        payeeWrapper.mapSelectableRows = mapSelectableRows;
                        payeeWrapper.maxRows = maxRows;
                        payeeWrapper.mapSelection = mapSelection;
                        
                        //Add Payee Wrapper in main list
                        assignWrapperList.add(payeeWrapper);
                    }
                    
                    /************************            End                   *********************************/
                    
                }
            }
        }
        
        //Sort the wrapper list
        assignWrapperList.sort();
              
    }
    
    /**
     *  @description    :   This method is used to update the tab 2 data (Plan Assignment)
     *
     *  @args           :   
     *
     *  @return         :   void
     *
     **/
    public void drawPlanAssignmentData() {
        
        //Re-Initilize properties
        selectedPersonalGoalsWrapper = new List<GoalsToPlanAssignmentWrapper>();
        
        //Map to hold the Personal Goals corresponding to Payee
        Map<Id, List<GoalsToPlanAssignmentWrapper.PersonalGoalWrapper>> mapPIdWithPersonalGoals = new Map<Id, List<GoalsToPlanAssignmentWrapper.PersonalGoalWrapper>>();
        
        //Map to hold the Payee Id with Personal Plans list
        Map<Id, List<SelectOption>> mapPIdWithPersonalPlans = new Map<Id, List<SelectOption>>();
        
        //Map to Hold the Payee Id with Personal Goal Wrapper Color, If any selected goal wrapper is having color equals to green,red or yellow for that payee add it in the list 
        Map<Id,Boolean> mapPayeesSelectedPGoalsColor = new Map<Id, Boolean>();
        
        //Map to hold the PGMPs with PG Id
        Map<Id, List<GoalsToPlanAssignmentWrapper.PGMeasurementPeriod>> mapPGMPeriods = new Map<Id, List<GoalsToPlanAssignmentWrapper.PGMeasurementPeriod>>();
        
        //Loop through the Main Wrapper (Payee wrapper)
        for(AssignmentGoalToPlanWrapper aGTP : assignWrapperList) {
            
            //Loop through the Goal Type wrapper
            for(AssignmentGoalToPlanWrapper.GoalTypeWrapper gTW : aGTP.goalTypes) {
                
                //Loop through the Personal Goal wrapper
                for(AssignmentGoalToPlanWrapper.PersonalGoalWrapper pGW : gTW.personalGoals) {
                    
                    //Check for selected checkbox and add PG Id in map
                    if(pGW.selected && !pGW.hasPP && !pGW.hasEmptyRow && pGW.personalGoal.Payee__c != null)
                        mapPGMPeriods.put(pGW.personalGoal.Id, new List<GoalsToPlanAssignmentWrapper.PGMeasurementPeriod>());
                }
            }
        }
       
        //Map to hold the SS Id as key and map of Date and PGMP Id as value
        Map<Id, Map<Date,Id>> mapSSIdWithPGMPs = new Map<Id, Map<Date,Id>>();
        
        //Query through the PGMPs
        for(Personal_Goal_Measurement_Period__c mP : [Select Id, Measurement_Date__c, Personal_Goal__c, Personal_Goal__r.Active_Proposal__c From Personal_Goal_Measurement_Period__c
                                                             Where Personal_Goal__c IN : mapPGMPeriods.keySet()
                                                                   OR Personal_Goal__r.Active_Proposal__c IN : mapPGMPeriods.keySet()]) {
                
            //Add PGMP in map
            if(mapPGMPeriods.containsKey(mP.Personal_Goal__c))
                mapPGMPeriods.get(mP.Personal_Goal__c).add(new GoalsToPlanAssignmentWrapper.PGMeasurementPeriod(mP));
            
            else if(mP.Personal_Goal__r.Active_Proposal__c != null){
                
                //Check for SS
                if(!mapSSIdWithPGMPs.containsKey(mP.Personal_Goal__r.Active_Proposal__c))
                    mapSSIdWithPGMPs.put(mP.Personal_Goal__r.Active_Proposal__c, new Map<Date,Id>());
                
                //populate the map
                mapSSIdWithPGMPs.get(mP.Personal_Goal__r.Active_Proposal__c).put(mP.Measurement_Date__c, mP.Id);
            }                                                     
        }
        
        //Map to hold the Proposaed Goal Id with PGMP Id map combo.
        Map<Id, Map<Id, Id>> mapPGIdWithPPGMPsmap = new Map<Id, Map<Id,Id>>();
        
        //Loop through the Proposed goals map
        for(Id pGId : mapPGMPeriods.keySet()) {
            
            //Check id in map
            if(mapSSIdWithPGMPs.containsKey(pGId)) {
                
                //Loop through the PGMPs
                for(GoalsToPlanAssignmentWrapper.PGMeasurementPeriod pGMPW : mapPGMPeriods.get(pGId)) {
                
                    //Date of Pro Goal PGMP's date
                    Date pGMPDate = pGMPW.pGMP.Measurement_Date__c;
                    
                    //Check date in map
                    if(mapSSIdWithPGMPs.get(pGId).containsKey(pGMPDate)) {
                        
                        //Check pro Goal Id in map
                        if(!mapPGIdWithPPGMPsmap.containsKey(pGId)) 
                            mapPGIdWithPPGMPsmap.put(pGId, new Map<Id, Id>());
                        
                        //Populate the map
                        mapPGIdWithPPGMPsmap.get(pGID).put(pGMPW.pGMP.Id, mapSSIdWithPGMPs.get(pGId).get(pGMPDate));    
                    }
                }
            }
        }
        
        //Loop through the Main Wrapper (Payee wrapper)
        for(AssignmentGoalToPlanWrapper aGTP : assignWrapperList) {
            
            //Variables to hold the min start date and max end date
            Date minSD;
            Date maxED;
            Decimal newWeight = 0;
            
            //Variable to check selected rows for current contatct (Payee)
            Boolean isSelected = false;
            
            //Loop through the Goal Type wrapper
            for(AssignmentGoalToPlanWrapper.GoalTypeWrapper gTW : aGTP.goalTypes) {
                
                //Loop through the Personal Goal wrapper
                for(AssignmentGoalToPlanWrapper.PersonalGoalWrapper pGW : gTW.personalGoals) {
                      
                    //Check for selected checkbox
                    if(pGW.selected && !pGW.hasPP && !pGW.hasEmptyRow && pGW.personalGoal.Payee__c != null) {
                        
                        //Check flag to true
                        isSelected = true;
                        
                        //Check Payee in the map
                        if(!mapPIdWithPersonalGoals.containsKey(pGW.personalGoal.Payee__c)){
                            
                            //Assuming that all selected pg will be Green for selected payee, Set default true
                            mapPayeesSelectedPGoalsColor.put(pGW.personalGoal.Payee__c,true);
                        
                            mapPIdWithPersonalGoals.put(pGW.personalGoal.Payee__c, new List<GoalsToPlanAssignmentWrapper.PersonalGoalWrapper>());
                        }
                       
                        //Check if Selected Pg found with different color then Green for particular payee mark it as false
                        if(pGW.pgColor != ISSPConstants.PERSONAL_GOAL_COLOR_GREEN)
                            mapPayeesSelectedPGoalsColor.put(pGW.personalGoal.Payee__c,false);  
                        
                        //Populate the Map
                        if(!mapPIdWithSetPGIds.containsKey(aGTP.conId))
                            mapPIdWithSetPGIds.put(aGTP.conId, new Set<Id>());
                        
                        //Add Proposed Goal Ids in set
                        mapPIdWithSetPGIds.get(aGTP.conId).add(pGW.personalGoal.Primary_Goal__c);
                        
                        //Check for superseded PG
                        if(pGW.personalGoal.Supersedes__c != null && pGW.personalGoal.Supersedes__r.Primary_Goal__c != null)
                            mapPIdWithSetPGIds.get(aGTP.conId).add(pGW.personalGoal.Supersedes__r.Primary_Goal__c);
                        
                        
                        //Add Personal Goal in the map
                        mapPIdWithPersonalGoals.get(pGW.personalGoal.Payee__c).add(new GoalsToPlanAssignmentWrapper.PersonalGoalWrapper(pGW.personalGoal,
                                                                                       aGTP.conName, mapPGMPeriods.get(pGW.personalGoal.Id),
                                                                                       mapPGIdWithPPGMPsmap.containsKey(pGW.personalGoal.Id)
                                                                                       ? mapPGIdWithPPGMPsmap.get(pGW.personalGoal.Id) : new Map<Id,Id>(),
                                                                                       pGW.pgColor));
                        
                        //Check for start date
                        if(pGW.personalGoal.Period_Start__c != null && (minSD == null || minSD > pGW.personalGoal.Period_Start__c))
                            minSD = pGW.personalGoal.Period_Start__c;
                        
                        //Check for end date
                        if(pGW.personalGoal.Period_End__c != null && (maxED == null || maxED < pGW.personalGoal.Period_End__c))
                            maxED = pGW.personalGoal.Period_End__c;
                        
                        //Check for weight
                        if(pGW.personalGoal.Weighting__c != null)
                            newWeight += pGW.personalGoal.Weighting__c;
                    }
                }
            }
            
            //Check for flag
            if(isSelected) {
                
                //Populate map with min start and max end date
                mapPPMinMaxWrapper.put(aGTP.conId, new PPMinMaxWrapper(minSD, maxED, newWeight));
                
                //Add new record option in list
                //mapPIdWithPersonalPlans.put(aGTP.conId, new List<SelectOption>{new SelectOption('', '<New>')}); 
            }
        }
        //Check for Personal Goal map
        if(mapPIdWithPersonalGoals.size() > 0) {
        
            //Query through the Personal Plan
            for(Personal_Plan__c pP : [Select Id, Name, Plan_Start__c, Plan_End__c, Staff_Member__c, Plan_Type__c, Description__c From Personal_Plan__c
                                                                 Where Staff_Member__c IN : mapPPMinMaxWrapper.keySet() AND Plan_Start__c != null]) {
                
                //Check if map contains the Payee Id
                if(mapPIdWithPersonalGoals.containsKey(pP.Staff_Member__c)) {
                    
                    //Loop through the Perssonal Goals
                    for(GoalsToPlanAssignmentWrapper.PersonalGoalWrapper pGW : mapPIdWithPersonalGoals.get(pP.Staff_Member__c)) {
                        
                        //Check for current records Start date and end date, if conflicting with any existing one,
                        if((pP.Plan_End__c == null && pGW.personalGoal.Period_End__c == null)
                            || (pP.Plan_End__c != null && pGW.personalGoal.Period_End__c == null && pP.Plan_End__c >= pGW.personalGoal.Period_Start__c)
                            || (pP.Plan_End__c == null && pGW.personalGoal.Period_End__c != null && pP.Plan_Start__c <= pGW.personalGoal.Period_End__c)
                            || (pP.Plan_Start__c <= pGW.personalGoal.Period_End__c && pP.Plan_Start__c >= pGW.personalGoal.Period_Start__c)
                            || (pP.Plan_End__c >= pGW.personalGoal.Period_Start__c && pP.Plan_End__c <= pGW.personalGoal.Period_End__c)
                            || (pGW.personalGoal.Period_Start__c <= pP.Plan_End__c && pGW.personalGoal.Period_Start__c >= pP.Plan_Start__c)
                            || (pGW.personalGoal.Period_End__c >= pP.Plan_Start__c && pGW.personalGoal.Period_End__c <= pP.Plan_End__c)) {
                            
                            //Check Payee in map
                            if(!mapPIdWithPersonalPlans.containsKey(pP.Staff_Member__c)) {
                            
                                if(mapPayeesSelectedPGoalsColor.containsKey(pP.Staff_Member__c) && mapPayeesSelectedPGoalsColor.get(pP.Staff_Member__c) == true)
                                    mapPIdWithPersonalPlans.put(pP.Staff_Member__c, new List<SelectOption>{new SelectOption('', '<New>')});
                                else
                                    mapPIdWithPersonalPlans.put(pP.Staff_Member__c, new List<SelectOption>{new SelectOption('None', '--None--')});
                            }
                            
                            //Add PP in the map
                            if(mapPIdWithPersonalPlans.containsKey(pP.Staff_Member__c))
                                mapPIdWithPersonalPlans.get(pP.Staff_Member__c).add(new SelectOption(pP.Id, pP.Name));
                            else
                                mapPIdWithPersonalPlans.put(pP.Staff_Member__c, new List<SelectOption>{new SelectOption(pP.Id, pP.Name)});
                            
                            //Add Personal Plan in map
                            mapPersonalPlans.put(pP.Id, pP);
                            
                            break;          
                        }
                    }
                }
            }
            
            //Loop through the select Payee
            for(Id pId : mapPIdWithPersonalGoals.keySet()) {
                
                //Instance of PP
                Personal_Plan__c pP = new Personal_Plan__c();
                
                List<SelectOption> planList = mapPIdWithPersonalPlans.get(pId);
                
                //Assign values
                pP.Plan_Start__c = mapPPMinMaxWrapper.get(pId).startDate;
                pP.Plan_End__c = mapPPMinMaxWrapper.get(pId).endDate;
                
                if(planList != null && planList.size() > 0 && planList[0].getValue() == 'None'){
                    pP.Plan_Start__c = null;
                    pP.Plan_End__c = null;      
                }
               
                if(!mapPIdWithPersonalPlans.containsKey(pId) && mapPayeesSelectedPGoalsColor.containsKey(pId) && mapPayeesSelectedPGoalsColor.get(pId) == true){
                    
                    mapPIdWithPersonalPlans.put(pId, new List<SelectOption>{new SelectOption('', '<New>')});    
                }
                //Loop over each goal 
                //Populate the Wrapper Instance
                selectedPersonalGoalsWrapper.add(new GoalsToPlanAssignmentWrapper(pId, mapPIdWithPersonalGoals.get(pId)[0].payeeName,
                                                                                  mapPPMinMaxWrapper.get(pId).newWeight,
                                                                                  mapPIdWithPersonalPlans.get(pId), mapPIdWithPersonalGoals.get(pId),
                                                                                  pP));
            }
            
            //Sort
            selectedPersonalGoalsWrapper.sort();
        }
    }
    
    /**
     *  @description    :   This method is used to load the PGMP records for selected PG
     *
     *  @args           :   
     *
     *  @return         :   void
     *
     **/
    public void loadPGMPs() {

        //Check for main row and selected PG row to display PGMP for selected PG 
        if(mainRow != null && pGRow != null)
            pGMPeriods = selectedPersonalGoalsWrapper[mainRow].personalGoals[pGRow].pGMPeriods;
            
        
    }
    
    /**
     *  @description    :   This method is used to Add new PGMP record on selected PG
     *
     *  @args           :   
     *
     *  @return         :   void
     *
     **/
    public void addPGMPeriod() {
        
        //Check for main row and selected PG row 
        if(pGMPeriod != null && mainRow != null && pGRow != null) {
            
            //Add new Reocrd in the list
            selectedPersonalGoalsWrapper[mainRow].personalGoals[pGRow].pGMPeriods.add(new GoalsToPlanAssignmentWrapper.PGMeasurementPeriod(pGMPeriod));
            selectedPersonalGoalsWrapper[mainRow].personalGoals[pGRow].pGMPeriods.sort();
            
            //Assign to display on VF page
            pGMPeriods = selectedPersonalGoalsWrapper[mainRow].personalGoals[pGRow].pGMPeriods;
        
            //Re-Init
            pGMPeriod = new Personal_Goal_Measurement_Period__c();
        }
    }
    
    /**
     *  @description    :   This method is used to remove PGMP from the selected PG
     *
     *  @args           :   
     *
     *  @return         :   void
     *
     **/
    public void removePGMPeriod() {
        
        //Check for main row and selected PG row 
        if(mainRow != null && pGRow != null) {
            
            //Temp list of PGMP wrapper
            List<GoalsToPlanAssignmentWrapper.PGMeasurementPeriod> tempPGMPWrapperList = new List<GoalsToPlanAssignmentWrapper.PGMeasurementPeriod>();
            
            //Loop through the Wrapper list
            for(GoalsToPlanAssignmentWrapper.PGMeasurementPeriod pGMPW : pGMPeriods) {
                
                //Check for selected checkbox
                if(!pGMPW.selected) {
                    
                    //Add in temp list
                    tempPGMPWrapperList.add(pGMPW);
                
                } else if(pGMPW.pGMP.Id != null)
                    setPGMPs.add(pGMPW.pGMP.Id);
            }
            
            //Update PGMP list on the PG
            selectedPersonalGoalsWrapper[mainRow].personalGoals[pGRow].pGMPeriods = tempPGMPWrapperList;
            
            //Assign to display on VF page
            pGMPeriods = selectedPersonalGoalsWrapper[mainRow].personalGoals[pGRow].pGMPeriods;
        }
    }
    
    /**
     *  @description    :   This method is used to update the Personal Plan
     *
     *  @args           :   
     *
     *  @return         :   void
     *
     **/
     public void updatePersonalPlan() {
        
        //Get Row index from URL
        String rowIndex = ApexPages.currentPage().getParameters().get('rowIndex');
        
        //Convert String to integer
        Integer rowIdx = Integer.valueOf(rowIndex);
        
        //Check for Wrapper size
        if(selectedPersonalGoalsWrapper.size() >= rowIdx) {
            
            //Get the selected Row
            GoalsToPlanAssignmentWrapper gTPAWrap = selectedPersonalGoalsWrapper[rowIdx];
            
            gTPAWrap.behaviourOptions = new List<SelectOption>();
            
            gTPAWrap.selectedBehaviourOption = '';
            
            //Check for Personal Plan
            if(String.isNotBlank(gTPAWrap.selectedPP) && gTPAWrap.selectedPP != 'None' && mapPersonalPlans.containsKey(gTPAWrap.selectedPP)) {
                
                //Query through the Personal Plans
                for(AggregateResult aR : [Select SUM(Weighting__c) wei From Personal_Goal__c Where Personal_Plan__c =: gTPAWrap.selectedPP
                                                                                                   AND Active__c = true AND Status__c IN (:ISSPConstants.PERSONAL_GOAL_STATUS_PENDING,
                                                                                                                                          :ISSPConstants.PERSONAL_GOAL_STATUS_PAYEE_APPROVED)])
                    gTPAWrap.currentWeight = (Decimal) aR.get('wei');
                
                //Decimal to store the current Weight
                Decimal currentWei = gTPAWrap.currentWeight;
                
                //Check Payee Id in map
                if(currentWei != null && currentWei > 0 && mapPIdWithSetPGIds.containsKey(gTPAWrap.payeeId)) {
                    
                    //Query through the Personal Plans
                    for(AggregateResult aR : [Select SUM(Weighting__c) wei From Personal_Goal__c Where Personal_Plan__c =: gTPAWrap.selectedPP
                                                                                                   AND Active__c = true AND Id IN : mapPIdWithSetPGIds.get(gTPAWrap.payeeId)
                                                                                                   AND Status__c IN (:ISSPConstants.PERSONAL_GOAL_STATUS_PENDING,
                                                                                                    :ISSPConstants.PERSONAL_GOAL_STATUS_PAYEE_APPROVED)])
                        currentWei = aR.get('wei') != null && currentWei != null ? (currentWei - (Decimal) aR.get('wei')) : currentWei;
                    
                }
                
                //Update the PP and Weight
                gTPAWrap.personalPlan = mapPersonalPlans.get(gTPAWrap.selectedPP);
                gTPAWrap.newWeight = currentWei != null ? currentWei + mapPPMinMaxWrapper.get(gTPAWrap.payeeId).newWeight : mapPPMinMaxWrapper.get(gTPAWrap.payeeId).newWeight;
                
                //var is any Selected Goal Plan is Red then bypass one option to add in picklist
                Integer redCounter = 0;
                
                for(GoalsToPlanAssignmentWrapper.PersonalGoalWrapper pgWrap : gTPAWrap.personalGoals){
                    
                    if(pgWrap.pgColor == ISSPConstants.PERSONAL_GOAL_COLOR_RED){
                        redCounter++;   
                        break;
                    }
                }
                
                //Add Default Optiion Blank
                gTPAWrap.behaviourOptions.add(new SelectOption('','--None--'));
                
                //If any goal is Red in selected PG's bypass this optiion
                if(redCounter == 0)
                    gTPAWrap.behaviourOptions.add(new SelectOption('updateAddGoal','Update or add goal(s)'));
                    
                gTPAWrap.behaviourOptions.add(new SelectOption('carryOverInNewVersion','Carry over Plan into new version'));
                
                //Make Default Option to Cary Over Plan if Selected Goal List size is 1 and having superseded populated on it.
                if(gTPAWrap.personalGoals != null && gTPAWrap.personalGoals.size() == 1){
                    
                    //Check if Personal Goal is Populated with Supersedes Goal
                    if(gTPAWrap.personalGoals[0].personalGoal != null && gTPAWrap.personalGoals[0].personalGoal.Supersedes__c != null){
                        
                        gTPAWrap.selectedBehaviourOption = 'carryOverInNewVersion';
                    }
                }
            } else {
                
                //Check for none option
                if(gTPAWrap.selectedPP != 'None'){
                    
                    //Update the PP and Weight
                    gTPAWrap.personalPlan = new Personal_Plan__c();
                    
                    //Assign values
                    gTPAWrap.personalPlan.Plan_Start__c = mapPPMinMaxWrapper.get(gTPAWrap.payeeId).startDate;
                    gTPAWrap.personalPlan.Plan_End__c = mapPPMinMaxWrapper.get(gTPAWrap.payeeId).endDate;
                    
                    gTPAWrap.currentWeight = null;
                    gTPAWrap.newWeight = mapPPMinMaxWrapper.get(gTPAWrap.payeeId).newWeight;
                    
                    gTPAWrap.behaviourOptions = new List<SelectOption>();
                    gTPAWrap.selectedBehaviourOption = '';
                    
                } else {
                    
                    //None case
                    gTPAWrap.personalPlan = new Personal_Plan__c();
                    gTPAWrap.behaviourOptions = new List<SelectOption>();
                    gTPAWrap.currentWeight = null;
                    gTPAWrap.newWeight = mapPPMinMaxWrapper.get(gTPAWrap.payeeId).newWeight;
                }
            }
        }
     }
    
    /**
     *  @description    :   This method is used to save the data
     *
     *  @args           :   
     *
     *  @return         :   void
     *
     **/
    public void doSave() {
        
        //Create a savepoint
        Savepoint sp = Database.setSavepoint();
        
        try {
            //Map to hold the Payee Id With Personal Plan
            Map<Id, Personal_Plan__c> mapPPWithPayeeId = new Map<Id, Personal_Plan__c>();
            
            //Map to hold the Personal Plans
            Map<Id, Personal_Plan__c> mapPersonalPlans = new Map<Id, Personal_Plan__c>();
            
            //Set to hold the Personal Goal Ids
            Set<Id> setPersonalGoalIds = new Set<Id>();
            
            //Loop through the Selected Payees
            for(GoalsToPlanAssignmentWrapper gTPAW : selectedPersonalGoalsWrapper) {
                
                //Check for PP
                if(gTPAW.personalPlan != null) {
                    
                    //Check for Plan Picklist select Value, it must be populated with Plan Id other wise will not save
                    if(gTPAW.selectedPP == 'None' || (String.isNotBlank(gTPAW.selectedPP) && String.isBlank(gTPAW.selectedBehaviourOption))){
                        
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Plan/Goal should have appropriate values selected.'));
                        return;
                    }   
                    
                    //Check for Dates
                    if(gTPAW.personalPlan.Plan_Start__c == null) {
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Plan Start date can not be blank.'));
                        
                        return; 
                    }
                    
                    //Check for Dates
                    if(gTPAW.personalPlan.Plan_End__c == null) {
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Plan End date can not be blank.'));
                        
                        return; 
                    }
                    
                    //Update Payee
                    gTPAW.personalPlan.Staff_Member__c = gTPAW.payeeId;
                    gTPAW.personalPlan.Active__c = true;
                    gTPAW.personalPlan.Submission_Status__c = ISSPConstants.PERSONAL_PLAN_STATUS_PENDING;
                    
                    //Add PP in map
                    mapPPWithPayeeId.put(gTPAW.payeeId, gTPAW.personalPlan);
                    
                    //Check for selected option
                    if(gTPAW.selectedBehaviourOption == ISSPConstants.CARRYOVERINNEWVERSION)
                        mapPersonalPlans.put(gTPAW.personalPlan.Id, gTPAW.personalPlan);
                }
            }
            
            //Map to hold the Primary Goal with proposal
            Map<Id, Personal_Goal__c> mapSSWithProposals = new Map<Id, Personal_Goal__c>();
            
            //Loop through the selected PG
            for(GoalsToPlanAssignmentWrapper gTPAW : selectedPersonalGoalsWrapper) {
                
                //Loop through the PGS
                for(GoalsToPlanAssignmentWrapper.PersonalGoalWrapper pG : gTPAW.personalGoals) {
                    
                    //Check for Id
                    if(pG.personalGoal.Primary_Goal__c != null)
                        mapSSWithProposals.put(pG.personalGoal.Primary_Goal__c, pG.personalGoal);
                    
                    ////Check for Supersedes
                    if(pG.personalGoal.Supersedes__c != null && pG.personalGoal.Supersedes__r.Primary_Goal__c != null && pG.personalGoal.Supersedes__r.Active__c)
                        setPersonalGoalIds.add(pG.personalGoal.Supersedes__r.Primary_Goal__c);
                }
            }
                 
             System.debug('########### : ' +mapPersonalPlans);
                    
            //Check for Personal Plan size
            if(mapPersonalPlans.size() > 0) {
                
                //Map to hold the Payee Id with PP
                Map<Id, Personal_Plan__c> mapPIdWithNPPId = new Map<Id, Personal_Plan__c>();
                
                //Call method to clone the personal plan and all other staff (Children objects data)
                clonePersonalPlans(mapPersonalPlans,mapPIdWithNPPId, mapSSWithProposals, setPersonalGoalIds);
                
                //Put values in payee Map
                mapPPWithPayeeId.putAll(mapPIdWithNPPId);
                
            }
            
            //Check for PP size
            if(mapPPWithPayeeId.size() > 0) {
                
                //Upsert PP
                upsert mapPPWithPayeeId.values();
                
                //List to update Personal Goals
                List<Personal_Goal__c> personalGoals = new List<Personal_Goal__c>();
                
                //List to upsert personal Goal Measurement Period data
                List<Personal_Goal_Measurement_Period__c> pGMPeriodGoingToUpsert = new List<Personal_Goal_Measurement_Period__c>();
                
                //Map to Hold Goal Snapshot Corrosponding to its id
                Map<Id, Personal_Goal__c> mapGoalSnapShots = new Map<Id, Personal_Goal__c>();
                
                //Map to hold the Personal Goal to update (Supersedes data)
                Map<Id, Personal_Goal__c> mapSSPersonalGoals = new Map<Id, Personal_Goal__c>();
                            
                //Loop through the selected PG
                for(GoalsToPlanAssignmentWrapper gTPAW : selectedPersonalGoalsWrapper) {
                    
                    //Check if PP map contains payee
                    if(mapPPWithPayeeId.containsKey(gTPAW.payeeId)) {
                        
                        //Loop through the PGS
                        for(GoalsToPlanAssignmentWrapper.PersonalGoalWrapper pG : gTPAW.personalGoals) {
                            
                            //Variable to hold the active checkbox property
                            Boolean isAlreadyAdded = false;
                            
                            if(mapGoalSnapShots.containsKey(pG.personalGoal.Primary_Goal__c))
                                isAlreadyAdded = true;
                                
                            //Update PP
                            pG.personalGoal.Status__c = ISSPConstants.PERSONAL_GOAL_STATUS_PENDING;
                            pG.personalGoal.Submission_Status__c = ISSPConstants.PERSONAL_GOAL_STATUS_PENDING;
                            
                            System.debug('########@@@@@@@@ : ' + pG.personalGoal.Primary_Goal__c);
                            //Check for Primary goal 
                            if(!mapGoalSnapShots.containsKey(pG.personalGoal.Primary_Goal__c)) {
                                
                                //Instance of Parent
                                Personal_Goal__c parentPG = new Personal_Goal__c();
                                
                                //Populate field values
                                parentPG.Id = pG.personalGoal.Primary_Goal__c;
                                parentPG.Status__c = ISSPConstants.PERSONAL_GOAL_STATUS_PENDING;
                                parentPG.Rate_Template__c = pG.personalGoal.Rate_Template__c;
                                parentPG.Weighting__c = pG.personalGoal.Weighting__c;
                                parentPG.Submission_Status__c = ISSPConstants.PERSONAL_GOAL_STATUS_PENDING;
                                
                                //Check for PP
                                if(pG.personalGoal.Primary_Goal__r.Personal_Plan__c == null || gTPAW.selectedBehaviourOption == ISSPConstants.CARRYOVERINNEWVERSION)
                                    parentPG.Personal_Plan__c = mapPPWithPayeeId.get(gTPAW.payeeId).Id;
                                    
                                //Add PG in list
                                personalGoals.add(parentPG);
                                
                                //Populate the map 
                                mapGoalSnapShots.put(pG.personalGoal.Primary_Goal__c, parentPG);
                                
                                //Check for Superseded PG
                                if(mapSSPersonalGoals.containsKey(pG.personalGoal.Primary_Goal__c)) {
                                    
                                    //Remove Record from map
                                    mapSSPersonalGoals.remove(pG.personalGoal.Primary_Goal__c);
                                    
                                    //Remove Active Proposal
                                    if(pG.personalGoal.Primary_Goal__r.Active_Proposal__c != null && mapSSPersonalGoals.containsKey(pG.personalGoal.Primary_Goal__r.Active_Proposal__c))
                                        mapSSPersonalGoals.remove(pG.personalGoal.Primary_Goal__c); 
                                }
                            }
                            
                            //Subhash Garhwal - 01/07/2016 - Code added to update the Supersedes's snapshot and active proposal as per SDD
                            //If a Superseded PG is referenced
                            //Update the Superseded PG’s records (both Snapshot and active Proposed Goal) to a Status of “Void”
                            
                            //Check for Supersedes
                            if(pG.personalGoal.Supersedes__c != null && pG.personalGoal.Supersedes__r.Primary_Goal__c != null &&
                                !mapGoalSnapShots.containsKey(pG.personalGoal.Supersedes__r.Primary_Goal__c)) {
                                
                                //Update the SS's SShot and active proposal 
                                mapSSPersonalGoals.put(pG.personalGoal.Supersedes__r.Primary_Goal__c, new Personal_Goal__c(Id = pG.personalGoal.Supersedes__r.Primary_Goal__c, Status__c = ISSPConstants.STATUS_VOID));
                                mapSSPersonalGoals.put(pG.personalGoal.Supersedes__c, new Personal_Goal__c(Id = pG.personalGoal.Supersedes__c, Status__c = ISSPConstants.STATUS_VOID));
                                
                                //Check for active proposal
                                if(pG.personalGoal.Supersedes__r.Primary_Goal__r.Active_Proposal__c != null)
                                    mapSSPersonalGoals.put(pG.personalGoal.Supersedes__r.Primary_Goal__r.Active_Proposal__c, new Personal_Goal__c(Id = pG.personalGoal.Supersedes__r.Primary_Goal__r.Active_Proposal__c, Status__c = ISSPConstants.STATUS_VOID));   
                            }
                            
                            System.debug('########## : ' +mapSSPersonalGoals);
                            System.debug('########## : ' +personalGoals);
                            
                            System.debug('########## : ' +personalGoals);
                            //Updat the Corrosponding Goal Snapsho
                            //Check if Plan is New
                                                                                                
                            //Loop over to Personal Goal measurement Periods and stamp personal goal Id on that 
                            for(GoalsToPlanAssignmentWrapper.PGMeasurementPeriod pGMPeriod : pG.pGMPeriods){
                                
                                //Check for flag
                                if(pG.personalGoal.Active__c && !isAlreadyAdded) {
                                    
                                    //Check for PGMP Id
                                    if(pGMPeriod.pGMP.Id != null) {
                                        
                                        //Check Id in map
                                        if(pG.mapPGPGMPWithSSPGMP != null && pG.mapPGPGMPWithSSPGMP.containsKey(pGMPeriod.pGMP.Id)) {
                                            
                                            //Add SS PG's PGMP in map
                                            pGMPeriodGoingToUpsert.add(new Personal_Goal_Measurement_Period__c(Id = pG.mapPGPGMPWithSSPGMP.get(pGMPeriod.pGMP.Id),
                                                                           Measurement_Date__c = pGMPeriod.pGMP.Measurement_Date__c));
                                            
                                            //Remove Id from map
                                            pG.mapPGPGMPWithSSPGMP.remove(pGMPeriod.pGMP.Id);                                  
                                        }
                                    } else {
                                        
                                        //Add SS PG's PGMP
                                        pGMPeriodGoingToUpsert.add(new Personal_Goal_Measurement_Period__c(Measurement_Date__c = pGMPeriod.pGMP.Measurement_Date__c,
                                                                           Personal_Goal__c = pG.personalGoal.Primary_Goal__c));
                                    }
                                }
                                    
                                //Check for PGMP Id
                                if(pGMPeriod.pGMP.Id == null)
                                    pGMPeriod.pGMP.Personal_Goal__c = pG.personalGoal.Id;   
                                    
                                pGMPeriodGoingToUpsert.add(pGMPeriod.pGMP);       
                            }
                            
                            //Check for map size
                            if(pG.personalGoal.Active__c && !isAlreadyAdded && pG.mapPGPGMPWithSSPGMP.size() > 0)
                                setPGMPs.addAll(pG.mapPGPGMPWithSSPGMP.values());   
                            
                            //Set active check box true
                            if(!pG.personalGoal.Active__c && !isAlreadyAdded)
                                pG.personalGoal.Active__c = true;
                                    
                            //Add Personal Goal in list
                            personalGoals.add(pG.personalGoal); 
                            
                        }   
                    }
                }
                
                System.debug('########## : ' +personalGoals);
                
                //Add all the Supersedes PG in list
                personalGoals.addAll(mapSSPersonalGoals.values());
                            
                //Check for set size
                if(setPGMPs.size() > 0)
                    delete [Select Id From Personal_Goal_Measurement_Period__c Where Id IN : setPGMPs];
                
                //Check pgmpList size
                if(pGMPeriodGoingToUpsert.size() > 0)
                    upsert pGMPeriodGoingToUpsert;
                    
                //Check for personal goal list size
                if(personalGoals.size() > 0)
                    update personalGoals;
            }
            
            selectedPersonalGoalsWrapper = new List<GoalsToPlanAssignmentWrapper>(); 
            
            //Call method to apply filters
            loadPersonalGoalData();
            
            //Page Message
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'The selected goals have been added to plans.'));
        } catch(Exception e) {
            
            //Rollback the entire transaction
            database.rollBack(sp);
            
            //Add message on page
            ApexPages.addMessages(e);
        }
    }
    
    /**
     *  @description    :   Save and close method.
     *
     *  @args           :   
     *
     *  @return         :   Pagereference
     *
     **/
    public Pagereference saveAndClose() {
        
        //Save the entire request
        doSave();
        
        if(ApexPages.hasMessages(ApexPages.Severity.ERROR))
            return null;
        
        //Get Personal Plan key prefix
        String pPKeyPreFix = Personal_Plan__c.sObjectType.getDescribe().getKeyPrefix();
        
        //return
        return new Pagereference('/' + pPKeyPreFix);
    }
    
    /**
     *  @description    :   Close method
     *
     *  @args           :   
     *
     *  @return         :   Pagereference
     *
     **/
    public Pagereference close() {
        
        //Get Personal Goal key prefix
        String pGKeyPreFix = Personal_Goal__c.sObjectType.getDescribe().getKeyPrefix();
        
        //return
        return new Pagereference('/' + pGKeyPreFix);
    }
    
    /**
     *  @description    :   This method is used to calculate the goal Weight for selected Row
     *
     *  @args           :   List<AssignmentGoalToPlanWrapper.GoalTypeWrapper>, Integer
     *
     *  @return         :   Decimal
     *
     **/
    public Decimal calculateWeighting(List<AssignmentGoalToPlanWrapper.GoalTypeWrapper> goalTypes, Integer i) {
        
        //Variable to hold the weightage
        Decimal rowWeighting = 0;
        
        //Loop through the Goal Type wrapper
        for(AssignmentGoalToPlanWrapper.GoalTypeWrapper gTW : goalTypes) {
            
            //Add Personal Goal weight in the decimal
            rowWeighting += gTW.personalGoals[i].personalGoal.Weighting__c != null ? gTW.personalGoals[i].personalGoal.Weighting__c : 0; 
        }
        
        //return
        return rowWeighting;
    }
    
    /**
     *  @description    :   Method to clone the personal plan, if user selected "Carry Over In New Version" option for existing plan
     *                      Original Description :
     *
     *                      •   If “Carry over Plan into new version”
     *                      o   Clone the existing Personal PlanTBD (PP)
     *                         Create a new PP record
     *                         Set the new PP’s values as follows
     *                      •   Active = True
     *                      •   Status = “Pending”
     *                      •   Prior Plan = the original PP
     *                      •   Dates/description/etc. as indicated in the UI
     *                      •   Increment the version by 1
     *                         Clone unaffected PGs within the existing PP
     *                      •   Identify any PGs on the existing PP that are not affected by the current change
     *                      •   For each identified PG, create a full clone of the Snapshot and the primary Proposed Goal, updating as follows:
     *                      o   Proposals must reference the new Snapshot
     *                      o   New Snapshot must reference the newly cloned Active Proposed Goal
     *                      o   Status = “Pending”
     *                      o   Personal Plan = newly cloned PP
     *                      •   All child objects (Conditions, etc.) are to be cloned
     *                         Act on the selected PGs as indicated in the “New” and “Update” sections, above
     *                      o   Update the existing PP
     *                         Set the existing PP’s values as follows
     *                      •   Active = False
     *                      •   Status = “Void”
     *                         Update the existing PGs
     *                      •   For each PG associated with the existing PP and having a status of “Pending” or “Payee Approved”, set the Status to “Void”
     *
     *
     *  @args           :   Map<Id, Personal_Plan__c> 
     *
     *  @return         :   void
     *
     *  @created BY     :   Subhash Garhwal - 01/07/2016 - CR-20160106-9491
     *
     **/
    private Map<Id, Personal_Plan__c> clonePersonalPlans(Map<Id, Personal_Plan__c> mapPersonalPlans, Map<Id, Personal_Plan__c> mapPIdWithNPPId, Map<Id, Personal_Goal__c> mapSSWithProposals, Set<Id> setSupercedesIds) {
        
        //Check for Personal Plan map size
        if(mapPersonalPlans.size() > 0) {
            
            //Global describe
            //This will use to get all the object field for dynamic SOQL
            Map<String, Schema.SObjectType> globalDescribe = Schema.getGlobalDescribe();
            
            //Set to hold the PP Ids
            Set<Id> setPPIds = mapPersonalPlans.keySet();
            
            //Query through the current (original) PPs 
            List<Personal_Plan__c> originalPersonalPlans = (List<Personal_Plan__c>)Database.query(buildSOQL(globalDescribe, 'Personal_Plan__c') + ' Where Id IN : setPPIds');
            
            //Check for list size
            if(originalPersonalPlans.size() > 0) {
                
                //Map to hold the current Plan Id with new Plan
                Map<String, Personal_Plan__c> mapOPPIdWithCPersonalPlan = new Map<String, Personal_Plan__c>();
            
                //Clone the Goal Templates using the stabdard salesforce Deepclone method
                List<Personal_Plan__c> clonedPersonalPlans = originalPersonalPlans.deepClone(false,true);
                
                //Loop through the Original cloned records
                for(Integer i = 0; i < originalPersonalPlans.size(); i++) {
                    
                    //Update the field values
                    clonedPersonalPlans[i].Active__c = true;
                    clonedPersonalPlans[i].Status__c = ISSPConstants.PERSONAL_PLAN_STATUS_PENDING;
                    clonedPersonalPlans[i].Prior_Plan__c = originalPersonalPlans[i].Id;
                    clonedPersonalPlans[i].Version__c = originalPersonalPlans[i].Version__c != null ? originalPersonalPlans[i].Version__c + 1 : 1; 
                    clonedPersonalPlans[i].Submission_Status__c = ISSPConstants.PERSONAL_PLAN_STATUS_PENDING;
                    
                    //Check for PP Id in map
                    if(mapPersonalPlans.containsKey(originalPersonalPlans[i].Id)) {
                        
                        //Update All the fields
                        clonedPersonalPlans[i].Description__c = mapPersonalPlans.get(originalPersonalPlans[i].Id).Description__c;
                        clonedPersonalPlans[i].Plan_Type__c = mapPersonalPlans.get(originalPersonalPlans[i].Id).Plan_Type__c;
                        clonedPersonalPlans[i].Plan_Start__c = mapPersonalPlans.get(originalPersonalPlans[i].Id).Plan_Start__c;
                        clonedPersonalPlans[i].Plan_End__c = mapPersonalPlans.get(originalPersonalPlans[i].Id).Plan_End__c;
                    }
                    
                    //Put PP in map
                    mapOPPIdWithCPersonalPlan.put(originalPersonalPlans[i].Id, clonedPersonalPlans[i]);
                    
                    //Update the Original PP
                    originalPersonalPlans[i].Active__c = false;
                    originalPersonalPlans[i].Status__c = ISSPConstants.STATUS_VOID;
                    originalPersonalPlans[i].Submission_Status__c = ISSPConstants.PERSONAL_PLAN_STATUS_PENDING;
                    
                    //Add in map
                    mapOPPIdWithCPersonalPlan.put('Original' + originalPersonalPlans[i].Id, originalPersonalPlans[i]);
                }
                
                //Insert PPs
                upsert mapOPPIdWithCPersonalPlan.values();
                
                //Loop thorugh the original PP Map
                for(Personal_Plan__c pP :  mapPersonalPlans.values()) {
                    
                    //Check PP in map
                    if(mapOPPIdWithCPersonalPlan.containsKey(pP.Id))
                        mapPIdWithNPPId.put(pP.Staff_Member__c, mapOPPIdWithCPersonalPlan.get(pP.Id));  
                }
                
                //SOQL String to query on Personal Goals
                String pGSOQL = buildSOQL(globalDescribe, 'Personal_Goal__c') + ' Where Personal_Plan__c IN : setPPIds'
                                + ' AND RecordType.DeveloperName = \'Personal_Goal\' AND Id NOT IN : setSupercedesIds';
                
                //Query through the Personal Goals
                List<Personal_Goal__c> originalPersonalGoals = (List<Personal_Goal__c>)Database.query(pGSOQL);
                
                //Check for size
                if(originalPersonalGoals.size() > 0) {
                    
                    //Clone the Personal Goals
                    List<Personal_Goal__c> clonedPersonalGoals = originalPersonalGoals.deepClone(false,true);
                    
                    //Map to hold the new Personal Goals with existing PG Id
                    Map<String, Personal_Goal__c> mapOPGIdWithCPersonalGoals = new Map<String, Personal_Goal__c>();
                    
                    //Loop through the Personal Goals
                    for(Integer i = 0; i < originalPersonalGoals.size(); i++) {
                        
                        //Update field values
                        clonedPersonalGoals[i].Status__c = ISSPConstants.PERSONAL_GOAL_STATUS_PENDING;
                        clonedPersonalGoals[i].Personal_Plan__c = mapOPPIdWithCPersonalPlan.get(originalPersonalGoals[i].Personal_Plan__c).Id;
                        clonedPersonalGoals[i].Active_Proposal__c = null;
                        clonedPersonalGoals[i].Submission_Status__c = ISSPConstants.PERSONAL_GOAL_STATUS_PENDING;
                        
                        //Add new PG in map
                        mapOPGIdWithCPersonalGoals.put(originalPersonalGoals[i].Id, clonedPersonalGoals[i]);
                        
                        //Check for Original PG status
                        if(originalPersonalGoals[i].Status__c == ISSPConstants.PERSONAL_GOAL_STATUS_PENDING
                            || originalPersonalGoals[i].Status__c == ISSPConstants.PERSONAL_GOAL_STATUS_PAYEE_APPROVED) {
                                
                            //Update the original PP
                            originalPersonalGoals[i].Status__c = ISSPConstants.STATUS_VOID;
                            originalPersonalGoals[i].Submission_Status__c = ISSPConstants.PERSONAL_GOAL_STATUS_PENDING;
                            
                            //Add original PG in map
                            mapOPGIdWithCPersonalGoals.put('Original' + originalPersonalGoals[i].Id, originalPersonalGoals[i]);
                            
                            //Check for Active Proposal
                            if(originalPersonalGoals[i].Active_Proposal__c != null)
                                mapOPGIdWithCPersonalGoals.put('OriginalAP' + originalPersonalGoals[i].Active_Proposal__c,
                                                               new Personal_Goal__c(Id = originalPersonalGoals[i].Active_Proposal__c, Status__c = ISSPConstants.STATUS_VOID,
                                                                                    Submission_Status__c = ISSPConstants.PERSONAL_GOAL_STATUS_PENDING));
                        }   
                    }
                    
                    //Insert
                    upsert mapOPGIdWithCPersonalGoals.values();
                    
                    ///Set to hold the newly created PG Ids
                    Set<Id> setNPGIds = new Set<Id>();
                    
                    //Set to delete the active proposals
                    Set<Id> setNSSPGIds = new Set<Id>();
                    
                    //Loop through the map key set
                    for(String pGId : mapOPGIdWithCPersonalGoals.keySet()) {
                        
                        System.debug('###### : ' +pGId);
                        
                        //Check for Id
                        if(!pGId.contains('Original')) {
                            
                            System.debug('###### : ' +pGId);
                            setNPGIds.add(mapOPGIdWithCPersonalGoals.get(pGId).Id);
                            
                            //Check Id in map
                            if(mapSSWithProposals.containsKey(pGId)) {
                                
                                //Update Primary Goal
                                mapSSWithProposals.get(pGId).Primary_Goal__c = mapOPGIdWithCPersonalGoals.get(pGId).Id;
                                
                                //Add Id in set
                                setNSSPGIds.add(mapOPGIdWithCPersonalGoals.get(pGId).Id);
                            }
                        }
                    }
                    
                    //Delete all the conditions from the newly created PGs
                    delete [Select Id From Condition__c Where Personal_Goal__c IN : setNPGIds];
                    
                    //Delete proposals
                    delete [Select Id From Personal_Goal__c Where Primary_Goal__c IN : setNSSPGIds];
                    
                    //Query through the Condtions
                    List<Condition__c> originalConditions = (List<Condition__c>)Database.query(buildSOQL(globalDescribe, 'Condition__c') + ' Where Personal_Goal__c IN : originalPersonalGoals');
                    
                    //Check for size
                    if(originalConditions.size() > 0) {
                        
                        //Clone the Condition
                        List<Condition__c> clonedConditions = originalConditions.deepClone(false,true);
                        
                        //Loop through the conditions
                        for(Integer i = 0; i < originalConditions.size(); i++) {
                            
                            //Update field values
                            clonedConditions[i].Personal_Goal__c = mapOPGIdWithCPersonalGoals.get(originalConditions[i].Personal_Goal__c).Id;
                        }
                        
                        //Insert
                        insert clonedConditions;
                        
                    }
                    
                    //Query through the Personal Goal Relationship
                    List<Personal_Goal_Relationship__c> originalPGRelationships = (List<Personal_Goal_Relationship__c>)Database.query(buildSOQL(globalDescribe, 'Personal_Goal_Relationship__c') + ' Where Personal_Goal__c IN : originalPersonalGoals');
                    
                    //Check for size
                    if(originalPGRelationships.size() > 0) {
                        
                        //Clone the PGR
                        List<Personal_Goal_Relationship__c> clonedPGRelationships = originalPGRelationships.deepClone(false,true);
                        
                        //Loop through the PGRs
                        for(Integer i = 0; i < originalPGRelationships.size(); i++) {
                            
                            //Update field values
                            clonedPGRelationships[i].Personal_Goal__c = mapOPGIdWithCPersonalGoals.get(originalPGRelationships[i].Personal_Goal__c).Id;
                        }
                        
                        //Insert
                        insert clonedPGRelationships;
                        
                    }
                    
                    //Query through the PG Measurement Periods to get all the PG Measurement Periods related to Snapshot PGs
                    List<Personal_Goal_Measurement_Period__c> originalPGMPeriods = (List<Personal_Goal_Measurement_Period__c>)Database.query(buildSOQL(globalDescribe, 'Personal_Goal_Measurement_Period__c') + ' Where Personal_Goal__c IN : originalPersonalGoals');
                    
                    //Check for PGMPs
                    if(originalPGMPeriods.size() > 0) {
                        
                        //Clone the PGMPs
                        List<Personal_Goal_Measurement_Period__c> clonedPGMPeriods = originalPGMPeriods.deepClone(false,true);
                        
                        //Loop through the cloned PGMPs
                        for(Integer i = 0; i < originalPGMPeriods.size(); i++) {
                            
                            //Update Personal Goal
                            clonedPGMPeriods[i].Personal_Goal__c = mapOPGIdWithCPersonalGoals.get(originalPGMPeriods[i].Personal_Goal__c).Id;
                        }
                        
                        //Insert cloned PGMPs
                        insert clonedPGMPeriods;    
                    }
                    
                    //Map to hold the Snapshot Id with Proposals
                    Map<Id, Personal_Goal__c> mapSSIdWithPersonalGoals = new Map<Id, Personal_Goal__c>();
                    
                    //Loop through the Proposals
                    for(Personal_Goal__c pG : [Select Id, Active__c, Primary_Goal__c From Personal_Goal__c Where RecordType.DeveloperName =: ISSPConstants.PERSONAL_GOAL_RECORD_TYPE_PROPOSAL
                                                          AND Primary_Goal__c != null AND Active__c = true AND Primary_Goal__c IN : setNPGIds])
                        mapSSIdWithPersonalGoals.put(pG.Primary_Goal__c, pG);
                    
                    //Check for map size
                    if(mapSSIdWithPersonalGoals.size() > 0)
                        PersonalGoalTriggerHelper.validateChildrenObjects(mapSSIdWithPersonalGoals);
                }
            }    
        }
        
        //return
        return mapPIdWithNPPId;
    }
    
    /**
     *  @description    :   This method is used to build the SOQL query string.
     *
     *  @args           :   Map<String, Schema.SObjectType>, String
     *
     *  @return         :   String
     *
     **/
    public String buildSOQL(Map<String, Schema.SObjectType> globalDescribe, String objName) {
        
        //SOQL query
        String SOQL = 'Select ';
        
        //Get the field of the object'
        for(String field : globalDescribe.get(objName).getDescribe().fields.getMap().keySet())
            SOQL += field + ',';
        
        //Remove extra elements and add object
        SOQL = SOQL.removeEnd(',') + ' From ' + objName;
        
        //Return 
        return SOQL;
        
    }
    
    //Method only used for mantained data on page
    public void reRender() {}
     
    //Wrapper class to hold the Goal Dynamic header
    public class GoalHeaderWrapper {
        
        //Properties
        public String gTName {get;set;}
        public Id gTId {get;set;}
        public Personal_Goal__c personalGoal {get;set;}
        
        //Constructor
        public GoalHeaderWrapper(String gTName, Id gTId) {
            
            //Set Values
            this.gTName = gTName;
            this.gTId = gTId;
            
            //Set default values
            personalGoal = new Personal_Goal__c();
        }
    }
    
    //Wrapper class to hold the min start date and max end date for payee.
    public class PPMinMaxWrapper {
        
        //Variables
        public Date startDate;
        public Date endDate;
        public Decimal newWeight;
        
        //Constructor
        public PPMinMaxWrapper(Date startDate, Date endDate, Decimal newWeight){
            
            //Set Values
            this.startDate = startDate;
            this.endDate = endDate;
            this.newWeight = newWeight;
        }
    }
}