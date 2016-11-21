/**
 *  Purpose         :   Controller for DefineStandardGoal VF page.
 *                      Class is runing in without sharing. As VF page access is controlling by permission set, so this won't impact anything.
 *                      Users only having CRED access having access to all Incentive projects and they wants to delete others records through the VF page,
 *                      this only possiable using without sharing.
 *  
 *  Created By      :   Subhash Garhwal
 * 
 *  Created Date    :   08/17/2015 
 * 
 *  Revision Logs   :   V_1.0 - Created - CR-20150729-9114
 *                      V_1.1 - Modified - Rajeev Jain - 10/22/2015 - CR-20150729-9114 - Edit functionality
 *                      V_1.2 - Modified - Subhash Garhwal - 11/25/2015 - CR-20151120-9407 - GTDMP functionality
 *                      V_1.3 - Modified - Subhash Garhwal - 12/16/2015 - CR-20151217-9469 - ISSP Deployment C.
 *                      V_1.4 - Modified - Rajeev Jain - 1/20/2016 - CR-20160115-9523 - SumSTo Issue Fix
 *                      V_1.5 - Modified - Rajeev Jain - 02/29/2016 - CR-20160125-9561 - ISSP Deployment D
 *                      V_1.6 - Modified - Rajeev Jain - 04/05/2016 - CR-20160304-9674 - ISSP Deployment E
 *                              - Included Condition Set and Staff Member Logic in order to save it at GT and GTD level as mentioned in SDD.
 *                      V_1.7 - Modified - Rajeev Jain - 04/14/2016 - CR-20160307-9680, CR-20160421-9790
 *                              - Included Value Type field save functionality on Goal Template, Goal Template Details, Included new GT Comments and GTD comments field in the code.
 * 
 **/
public without sharing class DefineStandardGoalsController {
    
    //Properties
    //Instance of Standard Goal
    public Standard_Goal__c stdGoal {get;set;}
    public StdGoalSectionWrapper stdGSWrapper {get;set;}
    public StdGoalDetailSectionWrapper stdGDWrapper {get;set;}
    public StdGoalDetailPacingSectionWrapper stdGDPacingWrapper {get;set;}
    public List<StdGoalDetailPacingSectionWrapper.StdGoalDetailPacing> stdGoalDPacings {get;set;}
    public List<StdGoalDetailSummaryWrapper> stdGDSummary {get;set;}
    public Standard_Goal_Sales_Role__c stdGSR {get;set;}
    public String vTKeyPreFix {get;set;}
    public String gTBTKeyPreFix {get;set;}
    
    //Variable to control the condition save logic
    public String sGDCondition {get;set;}
    
    //List to display the condtion data for std goal detail
    public List<StdGoalDetailSectionWrapper.stdGoalDetailConditions> stdGoalDetailConditions {get;set;}
    
    //Added - Subhash Garhwal - 11/25/2015 - CR-20151120-9407
    //List to display the GTDMP data for Goal Template Detail (GTD)
    public List<StdGoalDetailSectionWrapper.GTDMPeriod> gTDMPeriods {get;set;}
    public StdGoalDetailSectionWrapper.GTDMPeriod gTDMPWrapper {get;set;}
    
    //Varible to pass std goal detail row index
    public Integer stdGDRowIndex {get;set;}
    
    /******************    Local varibles to control the controller processing     **********************/
    
    //Map to hold the Std goal detail for summary section
    Map<String, StdGoalDetailSummaryWrapper> mapStdGDSummary;
    
    //Map to hold Goal Type Id with Goal Type
    Map<String, Goal_Type__c> mapGoalTypes;
    
    //String to hold the unique key (old std goal detail's goal type and description)
    String uniqueKey;
    
    //String to hold the Target Type (old goal template detail's)
    String oldTargetType;
    
    //Variable to hold the Previours GTD
    Standard_Goal_Detail__c oldGTD;
    
    //Set to hold the Std goal detail description
    Set<String> setStdGDetailsDesc;
    
    //Map to hold the combination of goal type and description as key and std goal details target type as value
    Map<String,String> mapTargetTypes;
    
    //Map to hold the Unique Key (Combo of Goal Type Id + GTD.description + GTD.Target_Type) with GTD wrapper instance
    Map<String, StdGoalDetailSectionWrapper.StdGoalDetailWrapper> mapGTDWrapper;
    
    /*********************     These variables are used in the edit functionality    *********************/
    
    //Map to hold the Goal Template Detial Id with list of conditions
    Map<Id, List<StdGoalDetailSectionWrapper.StdGoalDetailConditions>> mapGTDConditions;
    
    //Map to hold the Pacing record with Parent GTD Id
    //This map will use if GTD is explicit type
    Map<Id, Standard_Goal_Detail_Pacing__c> mapExplicitPacings = new Map<Id, Standard_Goal_Detail_Pacing__c>();
    
    //List of Conditions which needs to be delete, This list will hold actual saved record, which needs to delete at later
    private List<Condition__c> conditionsToBeDelete = new List<Condition__c>();
    private List<Standard_Goal_Sales_Role__c> busnessTitlesToBeDelete = new List<Standard_Goal_Sales_Role__c>();
    private List<Standard_Goal_Detail__c> stdGoalDetailsToBeDelete = new List<Standard_Goal_Detail__c>();
    private List<Standard_Goal_Detail_Pacing__c> pacingsToBeDelete = new List<Standard_Goal_Detail_Pacing__c>();
    private List<Goal_Template_Detail_Measurement_Period__c> gTDMPToBeDelete = new List<Goal_Template_Detail_Measurement_Period__c>();
    
    //Variable to control the goal template Id
    private Boolean isExisting;
    
    /***********************    End        *********************************/
    
    /*********************   End       ***********************/
    
    //Constructor
    public DefineStandardGoalsController(ApexPages.StandardController controller) {
        
        //Get Record
        stdGoal = (Standard_Goal__c)controller.getRecord();
        
        //Call method
        inIt();
    }
    
    /**
     *  @description    :   This method to load all the Properties
     *
     *  @args           :
     *
     *  @return         :   void
     *
     **/
    public void inIt() {
        
        //Populate wrapper
        stdGSWrapper = new StdGoalSectionWrapper();
        stdGDWrapper = new StdGoalDetailSectionWrapper();
        stdGDPacingWrapper = new StdGoalDetailPacingSectionWrapper();
        stdGoalDPacings = new List<StdGoalDetailPacingSectionWrapper.StdGoalDetailPacing>();
        stdGDSummary = new List<StdGoalDetailSummaryWrapper>();
        mapStdGDSummary = new Map<String, StdGoalDetailSummaryWrapper>();
        mapGoalTypes = new Map<String, Goal_Type__c>();
        setStdGDetailsDesc = new Set<String>();
        stdGoal.Standard_Type__c = ISSPConstants.STANDARD_GOAL_STANDARD_TYPE_GROUP;
        mapTargetTypes = new Map<String,String>();
        mapGTDWrapper = new Map<String, StdGoalDetailSectionWrapper.StdGoalDetailWrapper>();
        stdGSR = new Standard_Goal_Sales_Role__c();
        mapGTDConditions = new Map<Id, List<StdGoalDetailSectionWrapper.StdGoalDetailConditions>>();
        isExisting = false;
        oldGTD = new Standard_Goal_Detail__c();
        vTKeyPreFix = Value_Type__c.sObjectType.getDescribe().getKeyPrefix();
        gTBTKeyPreFix = Standard_Goal_Sales_Role__c.sObjectType.getDescribe().getKeyPrefix();
        gTDMPeriods = new List<StdGoalDetailSectionWrapper.GTDMPeriod>();
        gTDMPWrapper = new StdGoalDetailSectionWrapper.GTDMPeriod(new Goal_Template_Detail_Measurement_Period__c(), null);
        
        //Check if stdGoal is not null then record is for Edit purpose.
        if(stdGoal != null && String.isNotBlank(stdGoal.Id))
            populateData();
    }
    
    /**
     *  @description    :   This method to Populate Goal Template and its child Objects data if it comes for edit.
     *
     *  @args           :
     *
     *  @return         :   void
     *
     **/
     private void populateData(){
        
        //Query to get Standard Goal Data
        List<Standard_Goal__c> stdGoalTemplate = [SELECT Id, Name, RecordTypeId, Period_End__c, Period_Start__c, Business_Owner__c, Description__c, Goal_Type__c, GT_Comments__c, 
                                                     Amount__c, Percent__c, Counter__c, Active__c, Counter_ID__c, Standard_Type__c, Payee__c, Value__c, Value_Type__c
                                                     FROM Standard_Goal__c where Id = :stdGoal.Id];
        
        //Check if Data is Returned then Assign to Std Instance stdGSWrapper
        if(stdGoalTemplate.size() > 0 ) {
            
            //Assign goal template
            stdGoal = stdGoalTemplate[0];
            
            //Check if Selected Value Type is null then backfill with Based on what value populated on it
            if(String.isBlank(stdGoal.Value_Type__c)){
                
                //Check for value
                if(stdGoal.Amount__c != null && stdGoal.Amount__c > 0){
                    stdGSWrapper.selectedSGValueType = 'Amount';
                    stdGoal.Value_Type__c = 'Amount';
                }else if(stdGoal.Counter__c != null && stdGoal.Counter__c > 0){
                    stdGSWrapper.selectedSGValueType = 'Count';
                    stdGoal.Value_Type__c = 'Count';
                }else if(stdGoal.Percent__c != null && stdGoal.Percent__c > 0){
                    stdGSWrapper.selectedSGValueType = 'Percent';
                    stdGoal.Value_Type__c = 'Percent';
                }
                
                //Check for Value
                if(stdGoal.Amount__c != null && stdGoal.Counter__c == null && stdGoal.Percent__c == null){
                    stdGSWrapper.selectedSGValueType = 'Amount';
                    stdGoal.Value_Type__c = 'Amount';
                }else if(stdGoal.Counter__c != null && stdGoal.Amount__c == null && stdGoal.Percent__c == null){
                    stdGSWrapper.selectedSGValueType = 'Count';
                    stdGoal.Value_Type__c = 'Count';
                }else if(stdGoal.Percent__c != null && stdGoal.Amount__c == null && stdGoal.Counter__c == null){
                    stdGSWrapper.selectedSGValueType = 'Percent';
                    stdGoal.Value_Type__c = 'Percent';
                }
            }else
                stdGSWrapper.selectedSGValueType = stdGoal.Value_Type__c;
                        
            //Set flag to true
            isExisting = true;
            
            //Populate Condition Data of Goal Template
            populateConditions();
            
            //Populate the GTBT data
            loadGTBTitles();
            
            //Populate the GTD and Pacings
            loadGoalTempDetails();
        }
    }
    
    /**
     *  @description    :   This method to Populate Condition Data
     *
     *  @args           :
     *
     *  @return         :   void
     *
     **/
     private void populateConditions(){
        
        //V_1.6 - Modified - Rajeev Jain - 04/05/2016 - CR-20160304-9674 - ISSP Deployment E - Modified Query to include Condition_Set__c, Staff_Member__c, Staff_Member__r.Name
        //Query on Conditions and Add to Condition Wrapper List of stdGSWrapper instance
        for(Condition__c condition : [Select Id, Name, RecordTypeId, RecordType.Name, RecordType.DeveloperName, Condition_Type__c, Collection_Perspective__c, Individual_Program__c, Assignment_Role__c, 
                                    Institution__c, Agreement_Type__c, Start_Date__c, End_Date__c, Date_Type__c, Personal_Goal__c, Standard_Goal__c, 
                                    From_Relationship__c, To_Relationship__c, Counter_ID__c, Standard_Goal_Detail__c, Value__c, Matches_Any_Staff__c,
                                    Collection_Perspective__r.Name, Assignment_Role__r.Name, Institution__r.Name, From_Relationship__r.Name, To_Relationship__r.Name,
                                    Credit_Type__c,Credit_Type__r.Name, Condition_Set__c, Staff_Member__c, Staff_Member__r.Name
                                    FROM Condition__c Where Standard_Goal__c =: stdGoal.Id ORDER BY RecordType.Name ASC]){
            
            
            //Populate Value in Condition wrapper based on what Record Types is selected on Condition Object
            String rTypeDName = condition.RecordType.DeveloperName;
            
            //Record Type Name and Value which Needs to Be Populate on the wrapper
            String rTypeName = rTypeDName == ISSPConstants.CONDITION_RECORD_TYPE_DEVELOPER_NAME_COLLECTION_PERSPECTIVE ? 'Collection' : condition.RecordType.Name;
            String value = condition.Value__c;
            
            //Check for Goal Template Detail and populate Goal Template Conditions
            if(condition.Standard_Goal_Detail__c == null)
                stdGSWrapper.conditionsWrapper.add(new StdGoalSectionWrapper.ConditionWrapper(condition, rTypeName, value, stdGSWrapper.conditionsWrapper.size() + 1));
            else {
                //Add GTD in the map
                if(!mapGTDConditions.containsKey(condition.Standard_Goal_Detail__c))
                    mapGTDConditions.put(condition.Standard_Goal_Detail__c, new List<StdGoalDetailSectionWrapper.StdGoalDetailConditions>());
                
                //Add Condition with Parent GTD
                mapGTDConditions.get(condition.Standard_Goal_Detail__c).add(new StdGoalDetailSectionWrapper.StdGoalDetailConditions(condition, rTypeName, value,
                                                                            mapGTDConditions.get(condition.Standard_Goal_Detail__c).size() + 1));   
            }
        }
        sortGoalTemplateConditions(stdGSWrapper.conditionsWrapper);
        
        //Loop over each GTD and sort its associated conditions based on Condition Set then Condition Name
        for(Id  gtdId : mapGTDConditions.keySet()){
            sortGoalTemplateDetailsConditions(mapGTDConditions.get(gtdId), gtdId, null);    
        }
    }
    
    /**
     *  @description    :   This method to sort Goal Template Details Conditions first By Condition Set then By Condition Name
     *                      V_1.6 - Added - Rajeev Jain - 04/05/2016 - CR-20160304-9674 - ISSP Deployment E 
     *
     *  @args           :   
     *
     *  @return         :   void
     *
     **/
     public void sortGoalTemplateDetailsConditions(List<StdGoalDetailSectionWrapper.StdGoalDetailConditions> conditions, Id gtdId, StdGoalDetailSectionWrapper.StdGoalDetailWrapper stdWrap){
        
        //Map to hold List of Conditions corrosponding to each condition set
        Map<Decimal, List<StdGoalDetailSectionWrapper.StdGoalDetailConditions>> mapGTDConditionSet = new Map<Decimal, List<StdGoalDetailSectionWrapper.StdGoalDetailConditions>>();
        
        //Loop over each conditions and fill in the map in order to categorised by Condition set
        for(StdGoalDetailSectionWrapper.StdGoalDetailConditions wrapper : conditions){
            
            if(!mapGTDConditionSet.containsKey(wrapper.con.Condition_Set__c))
                mapGTDConditionSet.put(wrapper.con.Condition_Set__c, new List<StdGoalDetailSectionWrapper.StdGoalDetailConditions>{wrapper});
            else
                mapGTDConditionSet.get(wrapper.con.Condition_Set__c).add(wrapper);  
        }
        
        //List to hold Wrapper Instance of ConditionWrapper
        List<StdGoalDetailSectionWrapper.StdGdConditionsWithConditionSet> condWrapperWithCondSetList = new List<StdGoalDetailSectionWrapper.StdGdConditionsWithConditionSet>();
        
        //Loop over map and put the list in another wrapper in order to sort coditions order by condition set
        for(Decimal condSet  : mapGTDConditionSet.keySet()){
            
            List<StdGoalDetailSectionWrapper.StdGoalDetailConditions> conditionWrapperSort = mapGTDConditionSet.get(condSet);
            
            //Sort Condition List By Condition Name
            conditionWrapperSort.sort();
            
            //Add it to the annother wrapper in order to sort it at furthher leverl
            condWrapperWithCondSetList.add(new StdGoalDetailSectionWrapper.StdGdConditionsWithConditionSet(condSet, conditionWrapperSort)); 
        }
        condWrapperWithCondSetList.sort();
        
        //Now Reinitialize List and Repopulates it with Sorted data
        List<StdGoalDetailSectionWrapper.StdGoalDetailConditions> tempConditions = new List<StdGoalDetailSectionWrapper.StdGoalDetailConditions>();
        
        Integer rowCount = 1;
        
        for(StdGoalDetailSectionWrapper.StdGdConditionsWithConditionSet condSetWrappper : condWrapperWithCondSetList){
            
            for(StdGoalDetailSectionWrapper.StdGoalDetailConditions conWrap : condSetWrappper.conWrapList){
                
                conWrap.rowNumber = rowCount;
                tempConditions.add(conWrap);
                rowCount++;
            }
        }
        if(gtdId != null)
            mapGTDConditions.put(gtdId, tempConditions);
        else if(stdWrap != null)
            stdWrap.stdGoalDetailConditions = tempConditions;   
            
     }
     
    /**
     *  @description    :   This method to sort Goal Template Conditions first By Condition Set then By Condition Name
     *                      V_1.6 - Added - Rajeev Jain - 04/05/2016 - CR-20160304-9674 - ISSP Deployment E 
     *
     *  @args           :   
     *
     *  @return         :   void
     *
     **/
     public void sortGoalTemplateConditions(List<StdGoalSectionWrapper.ConditionWrapper> conditions){
        
        //Map to hold List of Conditions corrosponding to each condition set
        Map<Decimal, List<StdGoalSectionWrapper.ConditionWrapper>> mapGTConditionSet = new Map<Decimal, List<StdGoalSectionWrapper.ConditionWrapper>>();
        
        //Loop over each conditions and fill in the map in order to categorised by Condition set
        for(StdGoalSectionWrapper.ConditionWrapper wrapper : conditions){
            
            if(!mapGTConditionSet.containsKey(wrapper.con.Condition_Set__c))
                mapGTConditionSet.put(wrapper.con.Condition_Set__c, new List<StdGoalSectionWrapper.ConditionWrapper>{wrapper});
            else
                mapGTConditionSet.get(wrapper.con.Condition_Set__c).add(wrapper);   
        }
        
        //List to hold Wrapper Instance of ConditionWrapper
        List<StdGoalSectionWrapper.ConditionWrapperWithConditionSet> condWrapperWithCondSetList = new List<StdGoalSectionWrapper.ConditionWrapperWithConditionSet>();
        
        //Loop over map and put the list in another wrapper in order to sort coditions order by condition set
        for(Decimal condSet  : mapGTConditionSet.keySet()){
            
            List<StdGoalSectionWrapper.ConditionWrapper> conditionWrapperSort = mapGTConditionSet.get(condSet);
            
            //Sort Condition List By Condition Name
            conditionWrapperSort.sort();
            
            //Add it to the annother wrapper in order to sort it at furthher leverl
            condWrapperWithCondSetList.add(new StdGoalSectionWrapper.ConditionWrapperWithConditionSet(condSet, conditionWrapperSort));  
        }
        
        condWrapperWithCondSetList.sort();
        
        //Now Reinitialize List and Repopulates it with Sorted data
        List<StdGoalSectionWrapper.ConditionWrapper> tempConditions = new List<StdGoalSectionWrapper.ConditionWrapper>();
        
        Integer rowCount = 1;
        
        for(StdGoalSectionWrapper.ConditionWrapperWithConditionSet condSetWrappper : condWrapperWithCondSetList){
            
            for(StdGoalSectionWrapper.ConditionWrapper conWrap : condSetWrappper.conWrapList){
                
                conWrap.rowNumber = rowCount;
                tempConditions.add(conWrap);
                rowCount++;
            }
        }
        stdGSWrapper.conditionsWrapper = tempConditions;
     }
     
    /**
     *  @description    :   This method is used to populate the Goal Template Business Titles for Goal Template
     *
     *  @args           :   
     *
     *  @return         :   void
     *
     **/
    public void loadGTBTitles() {
        
        //Query on Business Title and add to the wrapper
        for(Standard_Goal_Sales_Role__c bT : [SELECT Id, Name, RecordTypeId, Standard_Goal__c, Sales_Role__c, Counter_ID__c 
                                                            FROM Standard_Goal_Sales_Role__c where Standard_Goal__c = : stdGoal.Id ORDER BY Sales_Role__r.Name ASC])
            stdGSWrapper.stdGSRs.add(new StdGoalSectionWrapper.SalesRoleWrapper(bT, bT.Name, stdGSWrapper.stdGSRs.size() + 1, true));
    }
    
    /**
     *  @description    :   This method is used to populate the Goal Template detials list and children Pacings data
     *
     *  @args           :
     *
     *  @return         :   void
     *
     **/
    public void loadGoalTempDetails() {
        
        //Query through the Pacings
        for(Standard_Goal_Detail_Pacing__c gTDP : [Select Id, Description__c, Period_Start__c, Period_End__c, Percent_Manual__c, Amount_Manual__c,
                                                          Count_Manual__c, Standard_Goal_Detail__c, Standard_Goal_Detail__r.Goal_Type__c, 
                                                          Standard_Goal_Detail__r.Goal_Type__r.Name, Standard_Goal_Detail__r.Description__c,
                                                          Standard_Goal_Detail__r.Target_Type__c, Value__c, Standard_Goal_Detail__r.Minimum__c, Standard_Goal_Detail__r.GTD_Comments__c
                                                          From Standard_Goal_Detail_Pacing__c Where Standard_Goal__c =: stdGoal.Id
                                                          ORDER BY Period_Start__c ASC]) {
            
            //Check for Target Type
            /*if(gTDP.Standard_Goal_Detail__r.Target_Type__c == ISSPConstants.STANDARD_GOAL_DETAIL_TARGET_TYPE_PACED) {
                
                //Instance of pacing wrapper
                String uniqueKey = gTDP.Standard_Goal_Detail__r.Goal_Type__c + '-' + gTDP.Standard_Goal_Detail__r.Description__c.trim() + '-'
                                   + gTDP.Standard_Goal_Detail__r.Target_Type__c;
                
                //Add GTD in map
                if(!stdGDPacingWrapper.stdGDetailPacings.containsKey(uniqueKey))
                    stdGDPacingWrapper.stdGDetailPacings.put(uniqueKey, new List<StdGoalDetailPacingSectionWrapper.StdGoalDetailPacing>());
                
                //Add Pacing record
                stdGDPacingWrapper.stdGDetailPacings.get(uniqueKey).add(new StdGoalDetailPacingSectionWrapper.StdGoalDetailPacing(
                                                                             gTDP,stdGDPacingWrapper.stdGDetailPacings.get(uniqueKey).size() + 1,
                                                                             gTDP.Standard_Goal_Detail__r.Target_Type__c, true));
            
            //Check for Explicit Type Pacings
            } else*/ if(gTDP.Standard_Goal_Detail__r.Target_Type__c == ISSPConstants.STANDARD_GOAL_DETAIL_TARGET_TYPE_EXPLICIT) 
                mapExplicitPacings.put(gTDP.Standard_Goal_Detail__c, gTDP);
        }
        
        //Map to hold the Parent GTD with Aggregate of children
        Map<Id, Integer> mapChildrens = new Map<Id, Integer>();
        
        //Query on the Goal Template Details
        for(AggregateResult aR : [Select count(Id) tcount, Parent__c parent From Standard_Goal_Detail__c Where Standard_Goal__c =: stdGoal.Id AND Parent__c != null
                                    GROUP BY Parent__c])
            mapChildrens.put((Id) aR.get('parent'), (Integer) aR.get('tcount'));
            
        //Map to hold the Goal Template Details
        Map<Id, Standard_Goal_Detail__c> mapGoalTempDetails = new Map<Id, Standard_Goal_Detail__c>(
                                                              [Select Id, Name, Amount__c, Baseline__c, Baseline_Percentage__c, Description__c, Minimum__c,
                                                                      Discount__c, Standard_Goal__c, Goal_Type__c, Goal_Type__r.Name, Parent__c,
                                                                      Period__c, Period_End__c, Period_Start__c,Summary__c, Target_Type__c,GT_Basline__c,
                                                                      Value__c, Weighting__c, Count__c, Percent__c,Condition_Handling__c, GTD_Comments__c From
                                                                      Standard_Goal_Detail__c Where Standard_Goal__c =: stdGoal.Id ORDER BY
                                                                      Description__c ASC]
                                                                ); 
        
        //Added - Subhash Garhwal - 111/25/2015 - CR-20151120-9407
        //Map to hold the Goal Template Detail Id with List of GTDMP wrapper 
        Map<Id, List<StdGoalDetailSectionWrapper.GTDMPeriod>> mapGTDIdWithGTDPs = new Map<Id, List<StdGoalDetailSectionWrapper.GTDMPeriod>>();
        
        //Loop through the GTDMP
        for(Goal_Template_Detail_Measurement_Period__c gTDMP : [Select Id, Goal_Template_Detail__c, Measurement_Date__c From
                                                                Goal_Template_Detail_Measurement_Period__c Where Goal_Template_Detail__c IN : mapGoalTempDetails.keySet()
                                                                AND Measurement_Date__c != null ORDER BY Measurement_Date__c ASC]) {
                                                                    
            //Check for GTD Id in map
            if(!mapGTDIdWithGTDPs.containsKey(gTDMP.Goal_Template_Detail__c))
                mapGTDIdWithGTDPs.put(gTDMP.Goal_Template_Detail__c, new List<StdGoalDetailSectionWrapper.GTDMPeriod>());
            
            //Add GTDMP in list
            mapGTDIdWithGTDPs.get(gTDMP.Goal_Template_Detail__c).add(new StdGoalDetailSectionWrapper.GTDMPeriod(gTDMP, mapGTDIdWithGTDPs.get(gTDMP.Goal_Template_Detail__c).size() + 1));                                                           
        }
         
        
        //Prepare a global Baseline options list for new record
        List<SelectOption> baselines = new List<SelectOption>();
        
        //Add Standard Baseline
        baselines.add(new SelectOption('', '--NONE--'));
        baselines.add(new SelectOption(ISSPConstants.TEMPLATE_BASELINE, ISSPConstants.TEMPLATE_BASELINE));
        
        //Prepare a global Parent options list for new records
        List<SelectOption> parents = new List<SelectOption>();
        
        //Add add blank in parent
        parents.add(new SelectOption('', '--NONE--'));
        
        //Loop thorugh the GTDs
        for(Standard_Goal_Detail__c gTD : mapGoalTempDetails.values()) {
            
            //Variable to hold the unqiue key
            String uniqueKey = gTD.Goal_Type__c + '-' + gTD.Description__c + '-' + gTD.Target_Type__c;
            
            //Populate map with goal type details
            mapGoalTypes.put(uniqueKey, new Goal_Type__c(Id = gTD.Goal_Type__c));
            
            //Populate Target Type map
            mapTargetTypes.put(uniqueKey, gTD.Target_Type__c);
            
            //Populate map
            mapStdGDSummary.put(uniqueKey, new StdGoalDetailSummaryWrapper(gTD.Description__c,gTD.Period_Start__c,gTD.Period_End__c));
            
            //Add GTD in baseline options
            baselines.add(new SelectOption(uniqueKey, gTD.Description__c));
            
            //Check for Parent
            if(gTD.Parent__c == null)
                parents.add(new SelectOption(uniqueKey, gTD.Description__c));
            
            //Baseline select options for this GTD
            List<SelectOption> tempBaselines = new List<SelectOption>();
            
            //Variable to hold the selected baseline
            String selectedBL = '';
            String selectBLLabel = '';
            
            //Check for Baseline
            if(gTD.GT_Basline__c == ISSPConstants.TEMPLATE_BASELINE) {
                selectBLLabel = ISSPConstants.TEMPLATE_BASELINE;
                selectedBL = ISSPConstants.TEMPLATE_BASELINE;
            
            } 
            
            //Check for Summary
            if(gTD.Summary__c)
                selectBLLabel = '';
            
            //Add standard in option
            tempBaselines.add(new SelectOption('', '--NONE--'));
            tempBaselines.add(new SelectOption(ISSPConstants.TEMPLATE_BASELINE, ISSPConstants.TEMPLATE_BASELINE));
            
            //Parent select options for this GTD
            List<SelectOption> tempParents = new List<SelectOption>();
            
            //Variable to hold the selected parent
            String selectedParent = '';
            String selectedParentLabel = '';
            
            //Add standard in option
            tempParents.add(new SelectOption('', '--NONE--'));
            
            //Loop through the existing data
            for(Standard_Goal_Detail__c tGTD : mapGoalTempDetails.values()) {
                
                //Check for record Id
                if(tGTD.Id != gTD.Id) {
                    
                    //Temp unique Key
                    String tempUK = tGTD.Goal_Type__c + '-' + tGTD.Description__c + '-' + tGTD.Target_Type__c;
                    
                    //Add GTD in baseline option
                    tempBaselines.add(new SelectOption(tempUK, tGTD.Description__c));
                    
                    //Check for baseline on main GTD
                    if(gTD.Baseline__c != null && gTD.Baseline__c == tGTD.Id) {
                        
                        //Set Baseline values
                        selectedBL = tempUK;
                        selectBLLabel = tGTD.Description__c;
                    }
                    
                    //Check for Parent
                    if(tGTD.Parent__c == null)
                        tempParents.add(new selectOption(tempUK, tGTD.Description__c));
                    
                    //Check for Parent
                    if(gTD.Parent__c != null && gTD.Parent__c == tGTD.Id) {
                        
                        //Set Parents
                        selectedParent = tempUK;
                        selectedParentLabel = tGTD.Description__c;
                    }
                }
            }
            
            //Instance of GTD Wrapper
            StdGoalDetailSectionWrapper.StdGoalDetailWrapper gTDWrapper = new StdGoalDetailSectionWrapper.StdGoalDetailWrapper(gTD, gTD.Goal_Type__r.Name,
                                                                       selectedBL, tempBaselines, stdGDWrapper.stdGoalDetailsWrapper.size() + 1,
                                                                       selectBLLabel, mapGTDConditions.containsKey(gTD.Id) ? mapGTDConditions.get(gTD.Id) :
                                                                       new List<StdGoalDetailSectionWrapper.StdGoalDetailConditions>(),
                                                                       selectedParent, tempParents, selectedParentLabel, stdGoal.Amount__c, stdGoal.Counter__c, stdGoal.Percent__c, true,
                                                                       mapGTDIdWithGTDPs.containsKey(gTD.Id) ? mapGTDIdWithGTDPs.get(gTD.Id)
                                                                       : new List<StdGoalDetailSectionWrapper.GTDMPeriod>());
            
            //Set the child record count
            if(mapChildrens.containsKey(gTD.Id))
                gTDWrapper.childGTDs = mapChildrens.get(gTD.Id);
            
            //Populate the map
            mapGTDWrapper.put(uniqueKey, gTDWrapper);
            
            //Add new Std Goal Detail in wrapper
            stdGDWrapper.stdGoalDetailsWrapper.add(gTDWrapper);
            
            //Call method
            setRowIndex();
            
            //Add Std Summary list
            stdGDSummary = mapStdGDSummary.values();
            
            //Sort
            stdGDSummary.sort();
        
            //Check for target type and Call method to prepare the goal template detail's list for pacings
            /*if(gTD.Target_Type__c == ISSPConstants.STANDARD_GOAL_DETAIL_TARGET_TYPE_PACED)
                prepareGTDList(stdGDPacingWrapper, gTD.Goal_Type__c, gTD);*/
        }
        
        //Call method to prepare the options
        populateBaselineAndParents();
    }
    
    /**
     *  @description    :   This method is used to create a new
     *                      V_1.6 - Modified - Rajeev Jain - 04/05/2016 - CR-20160304-9674 - ISSP Deployment E 
     *
     *  @args           :   
     *
     *  @return         :   void
     *
     **/
    public Pagereference addNewCondition() {
        
        try {
              
            //String to hold value
            String value = '';
            String rType = '';
            
            //Check for record Type Id
            if(stdGSWrapper.mapConRecordTypes.containsKey(stdGSWrapper.selectedRType)) {
                
                //Instance of Condition
                Condition__c condition = new Condition__c();
                
                //Set Null values
                condition.Collection_Perspective__c = null;
                condition.Individual_Program__c = null;
                condition.Assignment_Role__c = null;
                condition.Institution__c = null;
                condition.From_Relationship__c = null;
                condition.To_Relationship__c = null;
                condition.Agreement_Type__c = null;
                condition.Start_Date__c = null;
                condition.End_Date__c = null;
                condition.Date_Type__c = null;
                condition.Condition_Type__c = stdGSWrapper.condition.Condition_Type__c;
                condition.Matches_Any_Staff__c = false;
                condition.Credit_Type__c = null;
                condition.Id = stdGSWrapper.condition.Id;
                
                //V_1.6 - Added By - Rajeev Jain - 04/05/2016 - CR-20160304-9674 - ISSP Deployment E
                if(stdGSWrapper.condition.Condition_Set__c == null || stdGSWrapper.condition.Condition_Set__c == 0)
                    stdGSWrapper.condition.Condition_Set__c = ISSPConstants.DEFAULT_VALUE_CONDITION_SET;
                    
                condition.Condition_Set__c = stdGSWrapper.condition.Condition_Set__c;
                //V_1.6 - Added By - Rajeev Jain - 04/05/2016 - CR-20160304-9674 - ISSP Deployment E - upto here
                
                //String to hold record type developer name
                String rTypeDName =  stdGSWrapper.mapConRecordTypes.get(stdGSWrapper.selectedRType);
                
                //Check for recrod Type (Collection Perspective)
                if(rTypeDName == ISSPConstants.CONDITION_RECORD_TYPE_DEVELOPER_NAME_COLLECTION_PERSPECTIVE) {
                    
                    //Populate Type
                    rtype = ISSPConstants.CONDITION_RECORD_TYPE_COLLECTION;
                    
                    //Check for fields
                    if(stdGSWrapper.condition.Collection_Perspective__c != null) {
                        
                        //Set values
                        value = [Select Id, Name From Program_Perspective__c Where Id =: stdGSWrapper.condition.Collection_Perspective__c].Name;
                        condition.Collection_Perspective__c = stdGSWrapper.condition.Collection_Perspective__c;
                    
                    } else if(stdGSWrapper.condition.Individual_Program__c != null) {
                        
                        //Set values
                        value = [Select Id, Name From Program__c Where Id =: stdGSWrapper.condition.Individual_Program__c].Name;
                        condition.Individual_Program__c = stdGSWrapper.condition.Individual_Program__c;
                    }
                
                //Check for recrod Type (Assignment Role)
                } else if(rTypeDName == ISSPConstants.CONDITION_RECORD_TYPE_DEVELOPER_NAME_ASSIGNMENT_ROLE && stdGSWrapper.condition.Assignment_Role__c != null) { 
                    
                    //Populate value
                    value = [Select Id, Name From Team_Role__c Where Id =: stdGSWrapper.condition.Assignment_Role__c].Name;
                    rtype = ISSPConstants.CONDITION_RECORD_TYPE_ASSIGNMENT_ROLE;
                    condition.Assignment_Role__c = stdGSWrapper.condition.Assignment_Role__c;
                    condition.Matches_Any_Staff__c = stdGSWrapper.condition.Matches_Any_Staff__c;
                
                //Check for recrod Type (Institution)
                }else if(rTypeDName == ISSPConstants.CONDITION_RECORD_TYPE_DEVELOPER_NAME_INSTITUTION && stdGSWrapper.condition.Institution__c != null) {
                    
                    //Populate values
                    value = [Select Id, Name From Account Where Id =: stdGSWrapper.condition.Institution__c].Name;
                    rtype = ISSPConstants.CONDITION_RECORD_TYPE_DEVELOPER_NAME_INSTITUTION;
                    condition.Institution__c = stdGSWrapper.condition.Institution__c;
                
                //Check for recrod Type (Relationship)
                } else if(rTypeDName == ISSPConstants.CONDITION_RECORD_TYPE_DEVELOPER_NAME_RELATIONSHIP) {
                    
                    //Set Type
                    rtype = ISSPConstants.CONDITION_RECORD_TYPE_DEVELOPER_NAME_RELATIONSHIP;
                    
                    //Check for From Relationship
                    if(stdGSWrapper.condition.From_Relationship__c != null) {
                    
                        //Populate values
                        value = [Select Id, Name From Relationship_Type__c Where Id =: stdGSWrapper.condition.From_Relationship__c].Name;
                        condition.From_Relationship__c = stdGSWrapper.condition.From_Relationship__c;
                    }
                    
                    if(stdGSWrapper.condition.To_Relationship__c != null) {
                    
                        //Populate value
                        value = value != '' ? value + '-' + [Select Id, Name From Relationship_Type__c Where Id =: stdGSWrapper.condition.To_Relationship__c].Name
                                              : [Select Id, Name From Relationship_Type__c Where Id =: stdGSWrapper.condition.To_Relationship__c].Name;
                        
                        condition.To_Relationship__c = stdGSWrapper.condition.To_Relationship__c;
                    }
                
                } else if(rTypeDName == ISSPConstants.CONDITION_RECORD_TYPE_DEVELOPER_NAME_RENEWAL_TYPE && String.isNotBlank(stdGSWrapper.condition.Agreement_Type__c)) {
                    
                    //Populate value
                    value = stdGSWrapper.condition.Agreement_Type__c;
                    rtype = ISSPConstants.CONDITION_RECORD_TYPE_RENEWAL_TYPE;
                    condition.Agreement_Type__c = stdGSWrapper.condition.Agreement_Type__c;             
                
                } else if(rTypeDName == ISSPConstants.CONDITION_RECORD_TYPE_DEVELOPER_NAME_ACTIVITY_DATE) {
                    
                    if(stdGSWrapper.condition.Start_Date__c != null || stdGSWrapper.condition.End_Date__c != null
                        || String.isNotBlank(stdGSWrapper.condition.Date_Type__c)) {
                            
                        value = String.isNotBlank(stdGSWrapper.condition.Date_Type__c) ? stdGSWrapper.condition.Date_Type__c + '-' : '';
                        value += stdGSWrapper.condition.Start_Date__c != null ? stdGSWrapper.condition.Start_Date__c.format()  + '-' : '';
                        value += stdGSWrapper.condition.End_Date__c != null ? stdGSWrapper.condition.End_Date__c.format() : '';
                        value = value.removeEnd('-');
                        
                        rtype = ISSPConstants.CONDITION_RECORD_TYPE_ACTIVITY_DATE;
                        
                        condition.Start_Date__c = stdGSWrapper.condition.Start_Date__c;
                        condition.End_Date__c = stdGSWrapper.condition.End_Date__c;
                        condition.Date_Type__c = stdGSWrapper.condition.Date_Type__c;        
                    }
                
                } else if(rTypeDName == ISSPConstants.CONDITION_RECORD_TYPE_DEVELOPER_NAME_CREDIT_TYPE && stdGSWrapper.condition.Credit_Type__c != null) {
                    
                    //Populate values
                    rtype = ISSPConstants.CONDITION_RECORD_TYPE_CREDIT_TYPE;
                    value = [Select Id, Name From Value_Type__c Where Id =: stdGSWrapper.condition.Credit_Type__c].Name;
                    condition.Credit_Type__c = stdGSWrapper.condition.Credit_Type__c;
                
                //V_1.6 - Added By - Rajeev Jain - 04/05/2016 - CR-20160304-9674 - ISSP Deployment E    
                }else if(rTypeDName == ISSPConstants.CONDITION_RECORD_TYPE_DEVELOPER_NAME_STAFF_MEMBER && stdGSWrapper.condition.Staff_Member__c != null){
                    
                    //Populate Staff Member Values
                    rtype = ISSPConstants.CONDITION_RECORD_TYPE_STAFF_MEMBER;
                    value = [Select Id, Name From Contact Where Id =: stdGSWrapper.condition.Staff_Member__c].Name;
                    condition.Staff_Member__c = stdGSWrapper.condition.Staff_Member__c;
                    
                }//V_1.6 - Added By - Rajeev Jain - 04/05/2016 - CR-20160304-9674 - ISSP Deployment E - Upto here
                
                condition.RecordTypeId = stdGSWrapper.selectedRType;
                
                //Check for Selected Row Index
                if(String.isNotBlank(stdGSWrapper.selectedConditionRowIndex)) {
                    
                    //Convert String to Integer
                    Integer rowIndex = Integer.valueOf(stdGSWrapper.selectedConditionRowIndex);
                        
                    /********************* This code is used to update std goal detail conditions *********************/
                    //Check that condition is added for std goal detail or std goal
                    if(sGDCondition == 'true' && stdGDRowIndex != null) {
                        
                        //Get condition
                        StdGoalDetailSectionWrapper.StdGoalDetailConditions tempStdGDCon = stdGDWrapper.stdGoalDetailsWrapper.get(stdGDRowIndex -1).stdGoalDetailConditions.get(rowIndex -1);
                        
                        //Update selected Condition
                        tempStdGDCon.con = condition;
                        tempStdGDCon.rType = rtype;
                        tempStdGDCon.value = value;
                        
                        //Update selected Index
                        stdGSWrapper.selectedConditionRowIndex = '';
                        
                        //Repopulate list
                        stdGoalDetailConditions = stdGDWrapper.stdGoalDetailsWrapper.get(stdGDRowIndex -1).stdGoalDetailConditions;
                    
                    /********************* End *******************/
                    
                    } else if(sGDCondition != 'true') {
                    
                        //Get Sales Role Wrapper instance according to selected index 
                        StdGoalSectionWrapper.ConditionWrapper tempCondition = stdGSWrapper.conditionsWrapper.get(rowIndex -1);
                        
                        //Check for list and sales role
                        if(tempCondition != null && condition != null) {
                            
                            //Update selected Condition
                            tempCondition.con = condition;
                            tempCondition.rType = rtype;
                            tempCondition.value = value;
                            
                            //Update selected Index
                            stdGSWrapper.selectedConditionRowIndex = '';
                        }
                    }
                       
                } else {
                    
                    /********************* This code is used to add std goal detail condition *********************/
                    //Check that condition is added for std goal detail or std goal
                    if(sGDCondition == 'true' && stdGDRowIndex != null) {
                        
                        //Add new condition
                        stdGDWrapper.stdGoalDetailsWrapper.get(stdGDRowIndex -1).stdGoalDetailConditions.add(new StdGoalDetailSectionWrapper.StdGoalDetailConditions(
                                                                            condition, rtype, value, stdGDWrapper.stdGoalDetailsWrapper.get(stdGDRowIndex -1).stdGoalDetailConditions.size() + 1));
                        
                        //Pass the List of Conditions and sort it out
                        sortGoalTemplateDetailsConditions(stdGDWrapper.stdGoalDetailsWrapper.get(stdGDRowIndex -1).stdGoalDetailConditions, null, stdGDWrapper.stdGoalDetailsWrapper.get(stdGDRowIndex -1));
                        
                        //Repopulate list
                        stdGoalDetailConditions = stdGDWrapper.stdGoalDetailsWrapper.get(stdGDRowIndex -1).stdGoalDetailConditions;
                    
                    /********************* End *******************/
                    
                    } else if(sGDCondition != 'true') {
                        //Populate wrapper
                        stdGSWrapper.conditionsWrapper.add(new StdGoalSectionWrapper.ConditionWrapper(condition, rtype, value, stdGSWrapper.conditionsWrapper.size() + 1));
                        sortGoalTemplateConditions(stdGSWrapper.conditionsWrapper);     
                    }
                }
                
                //Initialize Condition Instance
                stdGSWrapper.condition = new Condition__c(Condition_Type__c = 'Include');
                stdGSWrapper.condition.Condition_Set__c = ISSPConstants.DEFAULT_VALUE_CONDITION_SET;
                stdGSWrapper.selectedRType = '';
            }    
        }catch(Exception e) {
            //Add Error on page
            ApexPages.addMessages(e);
            return null;
        }
        return null;
    }
    
    /**
     *  @description    :   This method is used to edit Conditions
     *
     *  @args           :   
     *
     *  @return         :   void
     *
     **/
    public void doEditContiditon(){
        
        try {
            
            //Check for Selected Row Index
            if(String.isNotBlank(stdGSWrapper.selectedConditionRowIndex)) {
                
                //Convert String to Integer
                Integer rowIndex = Integer.valueOf(stdGSWrapper.selectedConditionRowIndex);
                
                /********************* This code is used to update std goal detail conditions *********************/
                //Check that condition is added for std goal detail or std goal
                if(sGDCondition == 'true' && stdGDRowIndex != null) {
                    
                    //Get condition
                    StdGoalDetailSectionWrapper.StdGoalDetailConditions tempStdGDCon = stdGDWrapper.stdGoalDetailsWrapper.get(stdGDRowIndex -1).stdGoalDetailConditions.get(rowIndex -1);
                    
                    //Check for condition
                    if(tempStdGDCon != null)
                        stdGSWrapper.condition = tempStdGDCon.con;
                
                /********************* End *******************/
                
                } else if(sGDCondition != 'true') {
                    
                    //Get Sales Role Wrapper instance according to selected index 
                    StdGoalSectionWrapper.ConditionWrapper tempCondition = stdGSWrapper.conditionsWrapper.get(rowIndex -1);
                    
                    //Check for list and sales role
                    if(tempCondition != null){
                        stdGSWrapper.condition = tempCondition.con; 
                    }
                }
            }
        }catch(Exception e) {
            //Add Error on page
            ApexPages.addMessages(e);
        }
    }
    
    /**
     *  @description    :   This method is used to remove conditions
     *
     *  @args           :   
     *
     *  @return         :   void
     *
     **/
    public void removeCondition() {
        
        try {
            
            /********************* This code is used to Remove std goal detail conditions *********************/
            //Check that condition is added for std goal detail or std goal
            if(sGDCondition == 'true' && stdGDRowIndex != null) {
                
                //Temp list of condition wrapper
                List<StdGoalDetailSectionWrapper.StdGoalDetailConditions> tempConditions = new List<StdGoalDetailSectionWrapper.StdGoalDetailConditions>();
                
                //Integer
                Integer rowIndex = 1;
                
                for(StdGoalDetailSectionWrapper.stdGoalDetailConditions cW : stdGDWrapper.stdGoalDetailsWrapper.get(stdGDRowIndex -1).stdGoalDetailConditions) {
                    
                    //Check for selected instance
                    if(!cW.selected) {
                        
                        //Update Condition Index
                        cW.rowNumber = rowIndex;
                        rowIndex += 1;
                        tempConditions.add(cW);
                    
                    //Code added to delete the condition from the database in case of edit Goal Template
                    //Check if Condition is Existing Record then we need to delete it from database later,
                    //when gloabal save will be called from last section
                    } else if(cW.con.Id != null)
                        conditionsToBeDelete.add(cW.con);
                }
                
                //Repopulate std goal detail conditions
                stdGDWrapper.stdGoalDetailsWrapper.get(stdGDRowIndex -1).stdGoalDetailConditions = tempConditions;
                
                //Pass the List of Conditions and sort it out
                sortGoalTemplateDetailsConditions(stdGDWrapper.stdGoalDetailsWrapper.get(stdGDRowIndex -1).stdGoalDetailConditions, null, stdGDWrapper.stdGoalDetailsWrapper.get(stdGDRowIndex -1));
                        
                //Populate comman list
                stdGoalDetailConditions = tempConditions;
            
            /********************* End *******************/
            
            } else if(sGDCondition != 'true'){
            
                //Temp list of condition wrapper
                List<StdGoalSectionWrapper.ConditionWrapper> tempConditions = new List<StdGoalSectionWrapper.ConditionWrapper>();
                
                //Integer
                Integer rowIndex = 1;
                
                for(StdGoalSectionWrapper.ConditionWrapper cW : stdGSWrapper.conditionsWrapper) {
                    
                    //Check for selected instance
                    if(!cW.selected) {
                        
                        //Update Condition Index
                        cW.rowNumber = rowIndex;
                        rowIndex += 1;
                        tempConditions.add(cW);
                    //Code added to delete the condition from the database in case of edit Goal Template
                    //Check if Condition is Existing Record then we need to delete it from database later,
                    //when gloabal save will be called from last section
                    } else if(cW.con.Id != null)
                        conditionsToBeDelete.add(cW.con);
                }
                
                stdGSWrapper.conditionsWrapper = tempConditions;
                sortGoalTemplateConditions(stdGSWrapper.conditionsWrapper);
            }
        }catch(Exception e) {
            //Add Error on page
            ApexPages.addMessages(e);
        }
    }
    
    /**
     *  @description    :   This method is used to add Sales Roles
     *
     *  @args           :   
     *
     *  @return         :   void
     *
     **/
    public void addSalesRole() {
        
        try {
            
            //Check for Selected Row Index
            if(String.isNotBlank(stdGSWrapper.selectedSalesRoleRowIndex)) {
                
                //Convert String to Integer
                Integer rowIndex = Integer.valueOf(stdGSWrapper.selectedSalesRoleRowIndex);
                
                //Get Sales Role Wrapper instance according to selected index 
                StdGoalSectionWrapper.SalesRoleWrapper tempSalesRole = stdGSWrapper.stdGSRs.get(rowIndex -1);
                
                //Check for list and sales role
                if(tempSalesRole != null && stdGSWrapper.stdGSR.Sales_Role__c != null){
                    
                    //Update sales Role
                    tempSalesRole.stdGSR = stdGSWrapper.stdGSR;
                    tempSalesRole.salesRole = [Select Id, Name From Value_Type__c Where Id =: stdGSWrapper.stdGSR.Sales_Role__c LIMIT 1].Name;
                    
                    //Initialize Sales Role
                    stdGSWrapper.stdGSR = new Standard_Goal_Sales_Role__c();
                    
                    //Blank Sales Role
                    stdGSWrapper.selectedSalesRoleRowIndex = '';
                }   
            
            } else if(stdGSR.Sales_Role__c != null) {
                    
                //Assign value
                stdGSWrapper.stdGSR.Sales_Role__c = stdGSR.Sales_Role__c;
                
                //Query through the sales role
                List<Value_Type__c> vType = [Select Id, Name From Value_Type__c Where Id =: stdGSWrapper.stdGSR.Sales_Role__c LIMIT 1];
                
                //Check for size
                if(vType.size() > 0) {
                    
                    //Query through sales role to get name
                    String salesRole = vType[0].Name;
                    
                    stdGSWrapper.stdGSRs.add(new StdGoalSectionWrapper.SalesRoleWrapper(stdGSWrapper.stdGSR, salesRole, stdGSWrapper.stdGSRs.size() + 1, false));
                }
                
                //Initialize Sales Role Instance
                stdGSWrapper.stdGSR = new Standard_Goal_Sales_Role__c();
                stdGSR.Sales_Role__c = null;
                    
            }
        }catch(Exception e) {
            //Add Error on page
            ApexPages.addMessages(e);
        }
    }
    
    /**
     *  @description    :   This method is used to edit sales role
     *
     *  @args           :   
     *
     *  @return         :   Pagereference
     *
     **/
    public Pagereference doEditSalesRole() {
        
        try {
            
            //Check for Selected Row Index
            if(String.isNotBlank(stdGSWrapper.selectedSalesRoleRowIndex)) {
                
                //Convert String to Integer
                Integer rowIndex = Integer.valueOf(stdGSWrapper.selectedSalesRoleRowIndex);
                
                //Get Sales Role Wrapper instance according to selected index 
                StdGoalSectionWrapper.SalesRoleWrapper tempSalesRole = stdGSWrapper.stdGSRs.get(rowIndex -1);
                
                //Check for list and sales role
                if(tempSalesRole != null)
                    stdGSWrapper.stdGSR = tempSalesRole.stdGSR;
                
            }
        }catch(Exception e) {
            //Add Error on page
            ApexPages.addMessages(e);
        }
        
        //Return
        return null;
    }
    
    
    /**
     *  @description    :   This method is used to remove Sales Role
     *
     *  @args           :   
     *
     *  @return         :   void
     *
     **/
    public void removeSalesRole() {
        
        try {
            //Temp list of condition wrapper
            List<StdGoalSectionWrapper.SalesRoleWrapper> tempSalesRoles = new List<StdGoalSectionWrapper.SalesRoleWrapper>();
            
            //Integer
            Integer rowIndex = 1;
            
            //Loop through conditions
            for(StdGoalSectionWrapper.SalesRoleWrapper sRW : stdGSWrapper.stdGSRs) {
                
                //Check for selected check box
                if(!sRW.selected) {
                    
                    //Update Condition Index
                    sRW.rowNumber = rowIndex;
                    rowIndex += 1;
                    tempSalesRoles.add(sRW);
                
                //Code added to delete the GTBT from the database in case of edit Goal Template
                } else if(sRW.stdGSR.Id != null)
                    busnessTitlesToBeDelete.add(sRW.stdGSR);
            }
            stdGSWrapper.stdGSRs = tempSalesRoles;
       }catch(Exception e) {
            //Add Error on page
            ApexPages.addMessages(e);
        } 
    }
    
    /**
     *  @description    :   This method is used to update Business Title list according to selected Standard Type on the std goal
     *
     *  @args           :   
     *
     *  @return         :   void
     *
     **/
    public void displayBusinessTitle() {
        
        //Loop through the GTBT wrapper to add the GTBTs in delete list
        for(StdGoalSectionWrapper.SalesRoleWrapper gTBT : stdGSWrapper.stdGSRs) {
            
            //Check for id
            if(gTBT.stdGSR.Id != null)
                busnessTitlesToBeDelete.add(gTBT.stdGSR);
        }
        
        //Re-Initialize the business title list
        stdGSWrapper.stdGSRs = new List<StdGoalSectionWrapper.SalesRoleWrapper>();
        
        //Remove Payee from std goal
        stdGoal.Payee__c = null;
        
        //V_1.5 - Modified - Rajeev Jain - 02/29/2016 - CR-20160125-9561 - ISSP Deployment D - Replace Paced with Explicit in if part 
        //Change the Default Goal Template Detail's Target type
        if(stdGoal.Standard_Type__c == ISSPConstants.STANDARD_GOAL_STANDARD_TYPE_GROUP)
            stdGDWrapper.stdGD = new Standard_Goal_Detail__c(Target_Type__c = ISSPConstants.STANDARD_GOAL_DETAIL_TARGET_TYPE_EXPLICIT, Baseline_Percentage__c = 100, Weighting__c = 0,
                                                             Condition_Handling__c = 'Conditions OR Ownership');
        else
            stdGDWrapper.stdGD = new Standard_Goal_Detail__c(Target_Type__c = ISSPConstants.STANDARD_GOAL_DETAIL_TARGET_TYPE_EXPLICIT, Baseline_Percentage__c = null, Weighting__c = 0,
                                                             Condition_Handling__c = 'Conditions OR Ownership');
    }
    
    /**
     *  @description    :   This method is used to add new Std Goal Detail
     *
     *  @args           :   
     *
     *  @return         :   void
     *
     **/
    public void addStdGoalDetail() {
        
        try {
            
            /***********************************     This code is used to update the std goal details        ******************/             
            
            //Check for Selected Row Index
            //This case only happens in case of Std goal detail edit
            if(String.isNotBlank(stdGDWrapper.selectedSGDRowIndex)) {
                
                //Convert String to Integer
                //This variable is used to get the selected row from the Std goal detail wrapper list
                Integer rowIndex = Integer.valueOf(stdGDWrapper.selectedSGDRowIndex);
                
                //Get Std goal detail Wrapper instance according to selected index 
                StdGoalDetailSectionWrapper.StdGoalDetailWrapper tempstdGoalDetail = stdGDWrapper.stdGoalDetailsWrapper.get(rowIndex -1);
                
                //Check for Std goal detail wrapper instance and updated goal type
                if(tempstdGoalDetail != null && stdGDWrapper.stdGD.Goal_Type__c != null){
                    
                    //Query through the Goal Type
                    List<Goal_Type__c> gType = [Select Id, Name,Description__c From Goal_Type__c Where Id =: stdGDWrapper.stdGD.Goal_Type__c LIMIT 1];
                    
                    //Check for goal type
                    if(gType.size() > 0) {
                        
                        //Check if user changed the Target Type
                        //This code is used to remove pacing from explicit type GTD
                        if(stdGDWrapper.stdGD.Target_Type__c != oldTargetType && stdGDWrapper.stdGD.Id != null && mapExplicitPacings.containsKey(stdGDWrapper.stdGD.Id)) {
                            
                            //Add Pacing in delete list
                            pacingsToBeDelete.add(mapExplicitPacings.get(stdGDWrapper.stdGD.Id));
                            
                            //Remove Pacing from map
                            mapExplicitPacings.remove(stdGDWrapper.stdGD.Id);
                        }
                        
                        //Check for Target Type
                        /*if(stdGDWrapper.stdGD.Target_Type__c == ISSPConstants.STANDARD_GOAL_DETAIL_TARGET_TYPE_PACED) {
                            
                            //Update the start and date
                            stdGDWrapper.stdGD.Period_Start__c = null;
                            stdGDWrapper.stdGD.Period_End__c = null;
                            stdGDWrapper.stdGD.Period__c = null;
                        }*/
                        
                        //Remove old one and add new one
                        if(mapGoalTypes.containsKey(uniqueKey))
                            mapGoalTypes.remove(uniqueKey);
                        
                         //Variable to hold the current unique key of GTD
                        String currentGTD = gType[0].Id + + '-' + stdGDWrapper.stdGD.Description__c + '-' + stdGDWrapper.stdGD.Target_Type__c;
                         
                        //Populate Goal Type map
                        mapGoalTypes.put(currentGTD, gType[0]);
                        
                        //Check the old key with updated key
                        if(currentGTD != uniqueKey) {
                         
                            //Populate the map with new values
                            stdGDWrapper.mapForSUMstoRelationship.put(currentGTD, new Set<String>());
                             
                            //Check old key in map
                            if(stdGDWrapper.mapForSUMstoRelationship.containsKey(uniqueKey)) {
                              
                                //Add values from old
                                stdGDWrapper.mapForSUMstoRelationship.get(currentGTD).addAll(stdGDWrapper.mapForSUMstoRelationship.get(uniqueKey));
                                  
                                //Remove old key
                                stdGDWrapper.mapForSUMstoRelationship.remove(uniqueKey);  
                            }
                                
                            //Loop over map Key and check each element of the map and updated its elemment if necessarry
                            for(String str : stdGDWrapper.mapForSUMstoRelationship.keySet()){
                                
                                //Check if unique key in any set element then update that also
                                if(stdGDWrapper.mapForSUMstoRelationship.get(str).contains(uniqueKey)){
                                        
                                    stdGDWrapper.mapForSUMstoRelationship.get(str).add(currentGTD);
                                    
                                    //Remove old element
                                    stdGDWrapper.mapForSUMstoRelationship.get(str).remove(uniqueKey);
                                }
                            }
                            
                        }
                        
                        //Variable to hold the Previous parent (SUMs To) value
                        String existingSUMsTo = '';
                        
                        //Check for Parent value
                        //This is used to decrease the child count on the old (Previous) Parent (SUMs To) and perform the recalculations 
                        if(stdGDWrapper.stdGDetailsWrapper.selectedParent != tempstdGoalDetail.selectedParent
                            && String.isNotBlank(tempstdGoalDetail.selectedParent))
                            existingSUMsTo = tempstdGoalDetail.selectedParent;      
                            
                        //Remove Unique key Value form map
                        if(mapGTDWrapper.containsKey(uniqueKey))
                            mapGTDWrapper.remove(uniqueKey);
                       
                        //Check for old values
                        if(oldGTD.Amount__c != stdGDWrapper.stdGD.Amount__c || oldGTD.Count__c != stdGDWrapper.stdGD.Count__c
                            || oldGTD.Percent__c != stdGDWrapper.stdGD.Percent__c || oldGTD.Discount__c != stdGDWrapper.stdGD.Discount__c
                            || oldGTD.Baseline_Percentage__c != stdGDWrapper.stdGD.Baseline_Percentage__c
                            || tempstdGoalDetail.selectedBaseLine != stdGDWrapper.selectedBaseLine
                            || oldGTD.Target_Type__c != stdGDWrapper.stdGD.Target_Type__c) {
                            //Call the method to perform the calculations
                            calculateValues();
                        }
                                
                        //Update Goal template detail
                        tempstdGoalDetail.stdGDetail = stdGDWrapper.stdGD;
                        tempstdGoalDetail.goalType = gType[0].Name;
                        tempstdGoalDetail.gTAmount = stdGDWrapper.stdGDetailsWrapper.gTAmount;
                        tempstdGoalDetail.gTCounter = stdGDWrapper.stdGDetailsWrapper.gTCounter;
                        tempstdGoalDetail.gTPercent = stdGDWrapper.stdGDetailsWrapper.gTPercent;
                        
                        //Put goal template detail in map with updated value
                        mapGTDWrapper.put(tempstdGoalDetail.stdGDetail.Goal_Type__c + '-' + tempstdGoalDetail.stdGDetail.Description__c + '-'
                                          + tempstdGoalDetail.stdGDetail.Target_Type__c, tempstdGoalDetail);
                        
                        System.debug('Check for stdGDWrapper.stdGDetailsWrapper.selectedValueType :::: ' + stdGDWrapper.stdGDetailsWrapper.selectedValueType);
                        if(stdGDWrapper.stdGDetailsWrapper.selectedValueType == 'Amount'){
                            tempstdGoalDetail.value = stdGDWrapper.stdGD.Amount__c;
                            stdGDWrapper.stdGD.Count__c = null;
                            stdGDWrapper.stdGD.Percent__c = null;
                            tempstdGoalDetail.selectedValueType = 'Amount';
                            tempstdGoalDetail.stdGDetail.Value_Type__c = 'Amount';
                        }else if(stdGDWrapper.stdGDetailsWrapper.selectedValueType == 'Count'){
                            tempstdGoalDetail.value = stdGDWrapper.stdGD.Count__c;
                            stdGDWrapper.stdGD.Amount__c = null;
                            stdGDWrapper.stdGD.Percent__c = null;
                            tempstdGoalDetail.selectedValueType = 'Count';
                            tempstdGoalDetail.stdGDetail.Value_Type__c = 'Count';
                        }else if(stdGDWrapper.stdGDetailsWrapper.selectedValueType == 'Percent'){
                            tempstdGoalDetail.value = stdGDWrapper.stdGD.Percent__c;
                            stdGDWrapper.stdGD.Amount__c = null;
                            stdGDWrapper.stdGD.Count__c = null;
                            tempstdGoalDetail.selectedValueType = 'Percent';
                            tempstdGoalDetail.stdGDetail.Value_Type__c = 'Percent';
                        }               
                        System.debug('Check for stdGDWrapper.stdGDetailsWrapper.selectedValueType :::: ' + tempstdGoalDetail.selectedValueType);       
                        //Populate the Value
                        /*if(stdGDWrapper.stdGD.Amount__c > 0 || (stdGDWrapper.stdGD.Amount__c != null && stdGDWrapper.stdGD.Count__c == null
                            && stdGDWrapper.stdGD.Percent__c == null)) {
                            
                            //Update Value
                            tempstdGoalDetail.value = stdGDWrapper.stdGD.Amount__c;
                            tempstdGoalDetail.selectedValueType = 'Amount';
                            tempstdGoalDetail.stdGDetail.Value_Type__c = 'Amount';
                        
                        }else if(stdGDWrapper.stdGD.Count__c > 0 || (stdGDWrapper.stdGD.Count__c != null && stdGDWrapper.stdGD.Amount__c == null
                        
                            && stdGDWrapper.stdGD.Percent__c == null)) {
                            
                            //Update Value
                            tempstdGoalDetail.value = stdGDWrapper.stdGD.Count__c;
                            tempstdGoalDetail.selectedValueType = 'Count';
                            tempstdGoalDetail.stdGDetail.Value_Type__c = 'Count';
                            
                        } else if(stdGDWrapper.stdGD.Percent__c > 0 || (stdGDWrapper.stdGD.Percent__c != null && stdGDWrapper.stdGD.Amount__c == null
                            && stdGDWrapper.stdGD.Count__c == null)) {
                            
                            //Update value
                            tempstdGoalDetail.value = stdGDWrapper.stdGD.Percent__c;
                            tempstdGoalDetail.selectedValueType = 'Percent';
                            tempstdGoalDetail.stdGDetail.Value_Type__c = 'Percent';
                        }*/
                        
                        //Populate Target Type map
                        mapTargetTypes.put(gType[0].Id + + '-' + stdGDWrapper.stdGD.Description__c + '-' + stdGDWrapper.stdGD.Target_Type__c,
                                           stdGDWrapper.stdGD.Target_Type__c);
                        
                        //Check for SUMs To value
                        if(String.isBlank(stdGDWrapper.stdGDetailsWrapper.selectedParent)) {
                            
                            //Check for Child record
                            if(!tempstdGoalDetail.stdGDetail.Summary__c) {
                                
                                //Update the Baseline details
                                
                                //Check for Baseline Percentage
                                if(stdGDWrapper.stdGD.Baseline_Percentage__c == null || stdGDWrapper.stdGD.Baseline_Percentage__c <= 0)
                                    stdGDWrapper.stdGD.Baseline_Percentage__c = 100;
                                
                                //Set baseline
                                tempstdGoalDetail.selectedBaseLine = stdGDWrapper.selectedBaseLine;
                                tempstdGoalDetail.selectedBaseLineLabel = String.isBlank(tempstdGoalDetail.selectedBaseLine) ? '' : selectedOption(stdGDWrapper.availableBaseLines, tempstdGoalDetail.selectedBaseLine);
                                
                                //Check for baseline label
                                if(String.isBlank(tempstdGoalDetail.selectedBaseLineLabel))
                                    stdGDWrapper.stdGD.Baseline_Percentage__c = null;               
                                
                            } else {
                                
                                //Update values
                                stdGDWrapper.stdGD.Baseline_Percentage__c = null;
                                tempstdGoalDetail.selectedBaseLine = '';
                                tempstdGoalDetail.selectedBaseLineLabel = '';
                                
                            }
                            
                            //Set SUMs To values
                            tempstdGoalDetail.selectedParent = '';
                            tempstdGoalDetail.selectedparentLabel = '';
                            
                        } else {
                            
                            //Set Values
                            //Check for Baseline Percentage
                            if(stdGDWrapper.stdGD.Baseline_Percentage__c == null || stdGDWrapper.stdGD.Baseline_Percentage__c <= 0)
                                stdGDWrapper.stdGD.Baseline_Percentage__c = 100;
                            
                            //Set baseline
                            tempstdGoalDetail.selectedBaseLine = stdGDWrapper.selectedBaseLine;
                            tempstdGoalDetail.selectedBaseLineLabel = String.isBlank(tempstdGoalDetail.selectedBaseLine) ? '' : selectedOption(stdGDWrapper.availableBaseLines, tempstdGoalDetail.selectedBaseLine);            
                            
                            //Check for baseline and set baseline %
                            if(String.isBlank(tempstdGoalDetail.selectedBaseLineLabel))
                                stdGDWrapper.stdGD.Baseline_Percentage__c = null;
                                       
                            tempstdGoalDetail.selectedParent = stdGDWrapper.stdGDetailsWrapper.selectedParent;
                            tempstdGoalDetail.selectedparentLabel = selectedOption(stdGDWrapper.stdGDetailsWrapper.availableParents,stdGDWrapper.stdGDetailsWrapper.selectedParent);
                            
                        }
                        
                        //Check if If Current Sums to is Blank but previously it was not blank
                        if(tempstdGoalDetail.selectedParent != stdGDWrapper.stdGDetailsWrapper.previousSUMSto){
                            String currentUniqueKey = gType[0].Id + '-' + tempstdGoalDetail.stdGDetail.Description__c + '-' + tempstdGoalDetail.stdGDetail.Target_Type__c;
                            if(String.isNotBlank(tempstdGoalDetail.selectedParent) && stdGDWrapper.mapForSUMstoRelationship.containsKey(tempstdGoalDetail.selectedParent))
                                stdGDWrapper.mapForSUMstoRelationship.get(tempstdGoalDetail.selectedParent).add(currentUniqueKey);
                                
                            if(String.isNotBlank(stdGDWrapper.stdGDetailsWrapper.previousSUMSto) && stdGDWrapper.mapForSUMstoRelationship.containsKey(stdGDWrapper.stdGDetailsWrapper.previousSUMSto)){
                                stdGDWrapper.mapForSUMstoRelationship.get(stdGDWrapper.stdGDetailsWrapper.previousSUMSto).remove(currentUniqueKey);
                            }
                        }
                        
                        //Check for target type
                        //This code is used to update the pacings options according to GTD
                        /*if(stdGDWrapper.stdGD.Target_Type__c == ISSPConstants.STANDARD_GOAL_DETAIL_TARGET_TYPE_PACED) {
                            
                            //Check for unique key in pacing list
                            if(!stdGDPacingWrapper.stdGDetailPacings.containsKey(gType[0].Id + '-' + stdGDWrapper.stdGD.Description__c + '-' + stdGDWrapper.stdGD.Target_Type__c))
                                stdGDPacingWrapper.stdGDetailPacings.put(gType[0].Id + '-' + stdGDWrapper.stdGD.Description__c + '-' + stdGDWrapper.stdGD.Target_Type__c,new List<StdGoalDetailPacingSectionWrapper.StdGoalDetailPacing>());
                        
                            //Check for unique key
                            if(!uniqueKey.equalsIgnoreCase(gType[0].Id + '-' + stdGDWrapper.stdGD.Description__c + '-' + stdGDWrapper.stdGD.Target_Type__c)) {
                                
                                //Remove from pacings
                                if(stdGDPacingWrapper.stdGDetailPacings.containsKey(uniqueKey)) {
                                    
                                    //Put new value in map
                                    stdGDPacingWrapper.stdGDetailPacings.put(gType[0].Id + '-' + stdGDWrapper.stdGD.Description__c + '-' + stdGDWrapper.stdGD.Target_Type__c,
                                                                             stdGDPacingWrapper.stdGDetailPacings.get(uniqueKey));
                                    
                                    stdGDPacingWrapper.stdGDetailPacings.remove(uniqueKey); 
                                }
                            }
                        
                            //Loop through the map values
                            for(StdGoalDetailPacingSectionWrapper.StdGoalDetailPacing pacings : stdGDPacingWrapper.stdGDetailPacings.get(gType[0].Id + '-' + stdGDWrapper.stdGD.Description__c + '-' + stdGDWrapper.stdGD.Target_Type__c)) {
                                
                                //Check for std goal detail target type
                                if(stdGDWrapper.stdGD.Target_Type__c == ISSPConstants.STANDARD_GOAL_DETAIL_TARGET_TYPE_PACED)
                                    pacings.selectedValueType = ISSPConstants.STANDARD_GOAL_DETAIL_PACING_VALUE_TYPE_PERCENT;       
                            }
                        
                            //Check for Selected Std Goal detail
                            if(stdGDPacingWrapper.stdGDetailPacings.containsKey(stdGDPacingWrapper.selectedStdGDetail))
                                stdGoalDPacings = stdGDPacingWrapper.stdGDetailPacings.get(stdGDPacingWrapper.selectedStdGDetail);
                        
                        //Check for Explicit Target Type
                        } else if(stdGDWrapper.stdGD.Target_Type__c == ISSPConstants.STANDARD_GOAL_DETAIL_TARGET_TYPE_EXPLICIT) {
                            
                            //Remove the goal template detail from pacings
                            if(oldTargetType == ISSPConstants.STANDARD_GOAL_DETAIL_TARGET_TYPE_PACED
                                && stdGDPacingWrapper.stdGDetailPacings.containsKey(uniqueKey)) {
                                
                                //Loop through the Pacings wrapper
                                for(StdGoalDetailPacingSectionWrapper.StdGoalDetailPacing gTDP : stdGDPacingWrapper.stdGDetailPacings.get(uniqueKey)) {
                                    
                                    //Check for Id
                                    if(gTDP.stdGDPacing.Id != null)
                                        pacingsToBeDelete.add(gTDP.stdGDPacing);        
                                }
                                
                                //Remove Pacings for this goal template detail
                                stdGDPacingWrapper.stdGDetailPacings.remove(uniqueKey);
                                
                                //Check for map size
                                if(stdGDPacingWrapper.stdGDetailPacings.size() > 0) {
                                    
                                    //Add First variables list and value in map
                                    for(String pacing : stdGDPacingWrapper.stdGDetailPacings.keySet()) {
                                        
                                        //Set values
                                        stdGoalDPacings = stdGDPacingWrapper.stdGDetailPacings.get(pacing);
                                        
                                        //Set selected goal template
                                        stdGDPacingWrapper.selectedStdGDetail = pacing;
                                        
                                        break;
                                    }
                                } else {
                                    
                                    //Set values
                                    stdGoalDPacings = new List<StdGoalDetailPacingSectionWrapper.StdGoalDetailPacing>();
                                    
                                    //Set selected goal template detail
                                    stdGDPacingWrapper.selectedStdGDetail = '';
                                }
                            }
                        }*/
                        
                        //Check goal template details
                        if(mapStdGDSummary.containsKey(gType[0].Id + '-' + tempstdGoalDetail.stdGDetail.Description__c + '-' + tempstdGoalDetail.stdGDetail.Target_Type__c)) {
                                
                            //Update the start date and end date
                            if(stdGDWrapper.stdGD.Target_Type__c == ISSPConstants.STANDARD_GOAL_DETAIL_TARGET_TYPE_EXPLICIT) {
                                
                                mapStdGDSummary.get(gType[0].Id + '-' + tempstdGoalDetail.stdGDetail.Description__c + '-' + tempstdGoalDetail.stdGDetail.Target_Type__c).startDate = stdGDWrapper.stdGD.Period_Start__c;
                                mapStdGDSummary.get(gType[0].Id + '-' + tempstdGoalDetail.stdGDetail.Description__c + '-' + tempstdGoalDetail.stdGDetail.Target_Type__c).endDate = stdGDWrapper.stdGD.Period_End__c;    
                            
                            }/* else if(oldTargetType == ISSPConstants.STANDARD_GOAL_DETAIL_TARGET_TYPE_EXPLICIT
                                        && stdGDWrapper.stdGD.Target_Type__c == ISSPConstants.STANDARD_GOAL_DETAIL_TARGET_TYPE_PACED) {
                                
                                mapStdGDSummary.get(gType[0].Id + '-' + tempstdGoalDetail.stdGDetail.Description__c + '-' + tempstdGoalDetail.stdGDetail.Target_Type__c).startDate = null;
                                mapStdGDSummary.get(gType[0].Id + '-' + tempstdGoalDetail.stdGDetail.Description__c + '-' + tempstdGoalDetail.stdGDetail.Target_Type__c).endDate = null;
                            }*/
                        }
                        
                        //Check for Std Goal Detail in summary map
                        if(mapStdGDSummary.containsKey(uniqueKey)) {
                            
                            //Instance of Summary wrapper
                            StdGoalDetailSummaryWrapper sGDSW = mapStdGDSummary.get(uniqueKey);
                            sGDSW.goalType = tempstdGoalDetail.stdGDetail.Description__c;
                            
                            //Check for goal template target type
                            if(stdGDWrapper.stdGD.Target_Type__c == ISSPConstants.STANDARD_GOAL_DETAIL_TARGET_TYPE_EXPLICIT) {
                                
                                //Update the start date and end date
                                sGDSW.startDate = stdGDWrapper.stdGD.Period_Start__c;
                                sGDSW.endDate = stdGDWrapper.stdGD.Period_End__c;
                            }/* else if(oldTargetType == ISSPConstants.STANDARD_GOAL_DETAIL_TARGET_TYPE_EXPLICIT
                                        && stdGDWrapper.stdGD.Target_Type__c == ISSPConstants.STANDARD_GOAL_DETAIL_TARGET_TYPE_PACED) {
                                
                                //Update the start date and end date
                                sGDSW.startDate = null;
                                sGDSW.endDate = null;           
                            }*/
                            
                            //Remove old values form map
                            mapStdGDSummary.remove(uniqueKey);
                            
                            //Populate map
                            mapStdGDSummary.put(gType[0].Id + '-' + tempstdGoalDetail.stdGDetail.Description__c + '-'
                                                + tempstdGoalDetail.stdGDetail.Target_Type__c, sGDSW);
                            
                            //Add Std Summary list
                            stdGDSummary = mapStdGDSummary.values();
                            
                            stdGDSummary.sort();
                        }
                        
                        //Loop through the already added std goal details
                        //This is used to maintain the Baseline list on all the existing std goal details 
                        for(StdGoalDetailSectionWrapper.StdGoalDetailWrapper sGDW : stdGDWrapper.stdGoalDetailsWrapper) {
                            
                            //Check the old key with updated key
                            if(currentGTD != uniqueKey && sGDW.selectedParent == uniqueKey) {
                                            
                                sGDW.selectedParent = currentGTD;
                                sGDW.selectedparentLabel = stdGDWrapper.stdGD.Description__c;
                            }
                            //Loop through the available baseline list
                            for(Integer i = 0; i < sGDW.avaliableBaseLine.size(); i++) {
                                
                                //Check for Value
                                if(sGDW.avaliableBaseLine[i].getValue() == uniqueKey) {
                                    
                                    //Update 
                                    sGDW.avaliableBaseLine[i].setValue(gType[0].Id + '-' + stdGDWrapper.stdGD.Description__c + '-' + stdGDWrapper.stdGD.Target_Type__c);
                                    sGDW.avaliableBaseLine[i].setLabel(stdGDWrapper.stdGD.Description__c != null ? stdGDWrapper.stdGD.Description__c : '');
                                    
                                    //Check for selected std Goal Detail
                                    if(sGDW.selectedBaseLine == uniqueKey) {
                                        
                                        //Set the baseline line and selected baseline
                                        sGDW.selectedBaseLineLabel = stdGDWrapper.stdGD.Description__c;
                                        sGDW.selectedBaseLine = gType[0].Id + '-' + stdGDWrapper.stdGD.Description__c + '-' + stdGDWrapper.stdGD.Target_Type__c;
                                    }
                                        
                                    break;
                                }
                            }
                            
                            //Loop through the available baseline list
                            /*for(Integer i = 0; i < sGDW.availableParents.size(); i++) {
                                
                                //Check for Value
                                if(sGDW.availableParents[i].getValue() == uniqueKey) {
                                    
                                    //V_1.4 - Modified - Rajeev Jain - 1/20/2016 - CR-20160115-9523 - SumSTo Reparenting Issue fix
                                    //Check if new value have the parent or not
                                    if(String.isBlank(tempstdGoalDetail.selectedParent)) {
                                        
                                        //Replace values with new ones
                                        sGDW.availableParents[i].setValue(gType[0].Id + '-' + stdGDWrapper.stdGD.Description__c + '-' + stdGDWrapper.stdGD.Target_Type__c);
                                        sGDW.availableParents[i].setLabel(stdGDWrapper.stdGD.Description__c != null ? stdGDWrapper.stdGD.Description__c : '');
                                        
                                        //Check for selected std Goal Detail
                                        if(sGDW.selectedParent == uniqueKey) {
                                        
                                            //Set the baseline line and selected baseline
                                            sGDW.selectedparentLabel = stdGDWrapper.stdGD.Description__c;
                                            sGDW.selectedParent = gType[0].Id + '-' + stdGDWrapper.stdGD.Description__c + '-' + stdGDWrapper.stdGD.Target_Type__c;
                                        }
                                    } else {
                                        
                                        //Remove Goal template details from parents list
                                        sGDW.availableParents.remove(i);
                                        
                                        //Set the baseline line and selected baseline
                                        //Check for Target Type
                                        if(sGDW.selectedParent == uniqueKey) {
                                            
                                            sGDW.selectedParent = tempstdGoalDetail.selectedParent;
                                            sGDW.selectedparentLabel = tempstdGoalDetail.selectedparentLabel; 
                                        } 
                                    }
                                    //V_1.4 - Modified - Rajeev Jain - 1/20/2016 - CR-20160115-9523 - SumSTo Reparenting Issue fix - Upto Here    
                                    break;
                                }
                            }*/
                        }
                        
                        //Call method to re-calculate GTD for Pacings
                        populatePacingGTDs(uniqueKey,tempstdGoalDetail);
                        
                        //Check for Target Type
                        /*if(stdGDWrapper.stdGD.Target_Type__c == ISSPConstants.STANDARD_GOAL_DETAIL_TARGET_TYPE_PACED
                            && (stdGDPacingWrapper.avaliableStdGDetails.size() == 0 || oldTargetType == ISSPConstants.STANDARD_GOAL_DETAIL_TARGET_TYPE_EXPLICIT)
                            && !uniqueKey.equalsIgnoreCase(gType[0].Id + '-' + stdGDWrapper.stdGD.Description__c + '-' + stdGDWrapper.stdGD.Target_Type__c)) {
                            
                            //Call method to prepare the goal template detail's list for pacings
                            prepareGTDList(stdGDPacingWrapper, gType[0].Id, stdGDWrapper.stdGD);
                        }*/
                        
                        //Perfomr the calc for eixsting (Previous) parent (SUMs To) GTD
                        //Check for Parent value
                        //This is used to decrease the child count on the old (Previous) Parent (SUMs To) and perform the recalculations 
                        if(String.isNotBlank(existingSUMsTo)) {
                            
                            //Get previous SUM To GTD
                            StdGoalDetailSectionWrapper.StdGoalDetailWrapper gTDWrap = goalTemplateDetail(existingSUMsTo);
                            
                            //Populate field values
                            if(gTDWrap.childGTDs != null && gTDWrap.childGTDs > 0)
                                gTDWrap.childGTDs--;
                            
                            gTDWrap.stdGDetail.Summary__c = gTDWrap.childGTDs != null && gTDWrap.childGTDs > 0 ? true : false;
                            
                            //Check for Summary
                            if(gTDWrap.stdGDetail.Summary__c)
                                doCalculation(gTDWrap);
                        }
                        
                        //Check if record is summary
                        //Id record is summary, than perform the calc according to children records
                        if(stdGDWrapper.stdGD.Summary__c && String.isBlank(tempstdGoalDetail.selectedParent))
                            doCalculation(tempstdGoalDetail);
                        
                        //Check for Parent record on the record
                        if(String.isNotBlank(tempstdGoalDetail.selectedParent)) {
                            
                            //Goal Template detail wrapper instance
                            StdGoalDetailSectionWrapper.StdGoalDetailWrapper gTDWrap = goalTemplateDetail(tempstdGoalDetail.selectedParent);
                            
                            //Variable to control the flow of the Parent
                            Boolean isTTChanged = false;
                            
                            //Varible to remove the GTDWrapper from map
                            if(mapGTDWrapper.containsKey(gTDWrap.stdGDetail.Goal_Type__c + '-' + gTDWrap.stdGDetail.Description__c + '-' + gTDWrap.stdGDetail.Target_Type__c))
                                mapGTDWrapper.remove(gTDWrap.stdGDetail.Goal_Type__c + '-' + gTDWrap.stdGDetail.Description__c + '-' + gTDWrap.stdGDetail.Target_Type__c);
                            
                            //Check for Target Type
                            /*if(gTDWrap.stdGDetail.Target_Type__c != ISSPConstants.STANDARD_GOAL_DETAIL_TARGET_TYPE_EXPLICIT)
                                isTTChanged = true;*/
                                    
                            //Update values
                            gTDWrap.childGTDs++;
                            gTDWrap.stdGDetail.Target_Type__c = ISSPConstants.STANDARD_GOAL_DETAIL_TARGET_TYPE_EXPLICIT;
                            gTDWrap.stdGDetail.Summary__c = true;
                            gTDWrap.stdGDetail.Baseline_Percentage__c = null;
                            gTDWrap.selectedBaseLineLabel = '';
                            gTDWrap.selectedBaseLine = '';
                            
                            //Check for Parent TT
                            /*if(isTTChanged) {
                                
                                //Variablre to hold the UK for Parent (SUMs To) GTD
                                 String parentGTDUK = gTDWrap.stdGDetail.Goal_Type__c + '-' + gTDWrap.stdGDetail.Description__c + '-' + gTDWrap.stdGDetail.Target_Type__c;
                                 
                                 //String to hold the Old UK for Parent (SUMs TO) GTD
                                 String pGTDUK = gTDWrap.stdGDetail.Goal_Type__c + '-' + gTDWrap.stdGDetail.Description__c + '-' + ISSPConstants.STANDARD_GOAL_DETAIL_TARGET_TYPE_PACED;
                                 
                                 //Populate the map with new values
                                 stdGDWrapper.mapForSUMstoRelationship.put(parentGTDUK, new Set<String>());
                                  
                                 //Check old key in map
                                 if(stdGDWrapper.mapForSUMstoRelationship.containsKey(pGTDUK)) {
                                   
                                     //Add values from old
                                     stdGDWrapper.mapForSUMstoRelationship.get(parentGTDUK).addAll(stdGDWrapper.mapForSUMstoRelationship.get(pGTDUK));
                                       
                                     //Remove old key
                                     stdGDWrapper.mapForSUMstoRelationship.remove(pGTDUK);  
                                 }
                                 
                                //Loop over map Key and check each element of the map and updated its elemment if necessarry
                                for(String str : stdGDWrapper.mapForSUMstoRelationship.keySet()){
                                    
                                    System.debug('Check Map Key When Targget Type Changed::: ' + str + ' Map Child :::: ' + stdGDWrapper.mapForSUMstoRelationship.get(str));
                                    System.debug('Chheck Unique for Map When Targget Type Changed::: ' + pGTDUK);
                                    //Check if unique key in any set element then update that also
                                    if(stdGDWrapper.mapForSUMstoRelationship.get(str).contains(pGTDUK)){
                                            
                                        stdGDWrapper.mapForSUMstoRelationship.get(str).add(parentGTDUK);
                                        
                                        //Remove old element
                                        stdGDWrapper.mapForSUMstoRelationship.get(str).remove(pGTDUK);
                                    }
                                }
                                    
                                //Check key in map
                                if(mapStdGDSummary.containsKey(gTDWrap.stdGDetail.Goal_Type__c + '-' + gTDWrap.stdGDetail.Description__c
                                                                + '-' + ISSPConstants.STANDARD_GOAL_DETAIL_TARGET_TYPE_PACED)) {
                                                                    
                                    //Instance of Summary wrapper
                                    StdGoalDetailSummaryWrapper sGDSW = mapStdGDSummary.get(gTDWrap.stdGDetail.Goal_Type__c + '-' + gTDWrap.stdGDetail.Description__c
                                                                                            + '-' + ISSPConstants.STANDARD_GOAL_DETAIL_TARGET_TYPE_PACED);
                                    sGDSW.goalType = gTDWrap.stdGDetail.Description__c;
                                    
                                    //Update the start date and end date
                                    sGDSW.startDate = gTDWrap.stdGDetail.Period_Start__c;
                                    sGDSW.endDate = gTDWrap.stdGDetail.Period_End__c;
                                    
                                    //Remove
                                    mapStdGDSummary.remove(gTDWrap.stdGDetail.Goal_Type__c + '-' + gTDWrap.stdGDetail.Description__c
                                                                                            + '-' + ISSPConstants.STANDARD_GOAL_DETAIL_TARGET_TYPE_PACED);
                                    
                                    //Put
                                    mapStdGDSummary.put(gTDWrap.stdGDetail.Goal_Type__c + '-' + gTDWrap.stdGDetail.Description__c
                                                                                            + '-' + gTDWrap.stdGDetail.Target_Type__c, sGDSW);
                                    
                                    //Add Std Summary list
                                    stdGDSummary = mapStdGDSummary.values();
                                }
                                
                            
                                //Add Std Summary list
                                stdGDSummary = mapStdGDSummary.values();
                                
                                //Get Goal Type from map
                                Goal_Type__c parentGT = new Goal_Type__c();
                                
                                //Populate the goal type map
                                if(mapGoalTypes.containsKey(gTDWrap.stdGDetail.Goal_Type__c + '-' + gTDWrap.stdGDetail.Description__c + '-' + ISSPConstants.STANDARD_GOAL_DETAIL_TARGET_TYPE_PACED)) {
                                    
                                    //Get the goal type
                                    parentGT = mapGoalTypes.get(gTDWrap.stdGDetail.Goal_Type__c + '-' + gTDWrap.stdGDetail.Description__c + '-' + ISSPConstants.STANDARD_GOAL_DETAIL_TARGET_TYPE_PACED);
                                    
                                    //Remove exising key of parent form map 
                                    mapGoalTypes.remove(gTDWrap.stdGDetail.Goal_Type__c + '-' + gTDWrap.stdGDetail.Description__c + '-' + ISSPConstants.STANDARD_GOAL_DETAIL_TARGET_TYPE_PACED);
                                }
                                
                                //Add new in the map
                                mapGoalTypes.put(gTDWrap.stdGDetail.Goal_Type__c + '-' + gTDWrap.stdGDetail.Description__c + '-' + gTDWrap.stdGDetail.Target_Type__c,
                                                 parentGT);
                                                    
                                //call method to update goal template detail on all the GTD's available options
                                updateGTDOptions(gTDWrap.stdGDetail.Goal_Type__c + '-' + gTDWrap.stdGDetail.Description__c + '-' + ISSPConstants.STANDARD_GOAL_DETAIL_TARGET_TYPE_EXPLICIT,
                                                 gTDWrap.stdGDetail.Goal_Type__c + '-' + gTDWrap.stdGDetail.Description__c + '-' + ISSPConstants.STANDARD_GOAL_DETAIL_TARGET_TYPE_PACED);
                                
                                //Call method to re-calculate GTD for Pacings
                                populatePacingGTDs(gTDWrap.stdGDetail.Goal_Type__c + '-' + gTDWrap.stdGDetail.Description__c + '-' + ISSPConstants.STANDARD_GOAL_DETAIL_TARGET_TYPE_PACED,gTDWrap);
                            }*/
                            
                            //Sort
                            stdGDSummary.sort();
                            
                            //Check if record is summary
                            //Id record is summary, than perform the calc according to children records
                            if(stdGDWrapper.stdGD.Summary__c)
                                doCalculation(tempstdGoalDetail);
                            else
                                doCalculation(gTDWrap);
                        }
                        
                        //Repopulate the map
                        mapGTDWrapper.put(tempstdGoalDetail.stdGDetail.Goal_Type__c + '-' + tempstdGoalDetail.stdGDetail.Description__c + '-'
                                            + tempstdGoalDetail.stdGDetail.Target_Type__c, tempstdGoalDetail);
                        
                        //Blank selected row parameter
                        stdGDWrapper.selectedSGDRowIndex = '';
                    }   
                }   
            
            //Call method for shorting
            setRowIndex();
            
            /*************************    End    *******************************/
            
            /************************    This code is used to add new std goal details   ***********************/
            //This code will execute in case of new Std goal detail
            } else if(stdGDWrapper.stdGD != null) {
                
                //Blank to instance
                oldGTD = new Standard_Goal_Detail__c();
                
                //Query through Goal type
                List<Goal_Type__c> gT = [Select Id, Name,Description__c From Goal_Type__c Where Id =: stdGDWrapper.stdGD.Goal_Type__c LIMIT 1];
                
                //Check for goal Type.
                //In order to upsert a goal template detail user must have to populate the goal type on the goal template details
                if(gT.size() > 0) {
                    
                    //Check for description
                    //If discription of goal template detail is blank, populate description with goal type's description
                    //From SDD : If not populated on save, populate based on the Apply Description workflow.
                    if(String.isBlank(stdGDWrapper.stdGD.Description__c))
                        stdGDWrapper.stdGD.Description__c = gT[0].Description__c;
                    
                    //Populate map with goal type details
                    mapGoalTypes.put(gT[0].Id + '-' + stdGDWrapper.stdGD.Description__c + '-' + stdGDWrapper.stdGD.Target_Type__c, gT[0]);
                    
                    //Check for Description
                    if(String.isNotBlank(stdGDWrapper.stdGD.Description__c)) {
                        
                        //Call method
                        //This method is used to populate the goal template detail list
                        prepareGoalTemplateDetails(gT[0].Id, gT[0].Name, stdGDWrapper.stdGD, stdGDWrapper.selectedBaseLine, stdGDWrapper.stdGDetailsWrapper.selectedParent);    
                    }
                }
                
                //Call method for shorting
                setRowIndex();
            }
            
            /***********************       End          ***********************/
            
            //Call method
            populateBaselineAndParents();
            
       }catch(Exception e) {
            //Add Error on page
            ApexPages.addMessages(e);
       }
    }
    
    /**
     *  @description    :   This method is used to edit Std goal details
     *
     *  @args           :   
     *
     *  @return         :   Pagereference
     *
     **/
    public Pagereference doEditstdGoalDetail() {
        
        try {
            
            //Check for Selected Row Index
            if(String.isNotBlank(stdGDWrapper.selectedSGDRowIndex)) {
                
                //Convert String to Integer
                Integer rowIndex = Integer.valueOf(stdGDWrapper.selectedSGDRowIndex);
                
                //Get Sales Role Wrapper instance according to selected index 
                StdGoalDetailSectionWrapper.StdGoalDetailWrapper tempstdGoalDetail = stdGDWrapper.stdGoalDetailsWrapper.get(rowIndex -1);
                
                //Set unique Key
                uniqueKey = tempstdGoalDetail.stdGDetail.Goal_Type__c + '-' + tempstdGoalDetail.stdGDetail.Description__c + '-' + tempstdGoalDetail.stdGDetail.Target_Type__c;
                
                //Set Old target type
                oldTargetType = tempstdGoalDetail.stdGDetail.Target_Type__c;
                
                //Set Values in old GTD
                oldGTD =  tempstdGoalDetail.stdGDetail.clone(false,true);
                
                //Check for list and sales role
                if(tempstdGoalDetail != null)
                    stdGDWrapper.stdGD = tempstdGoalDetail.stdGDetail;
                
                //Update baseline
                stdGDWrapper.availableBaseLines = tempstdGoalDetail.avaliableBaseLine;
                stdGDWrapper.selectedBaseLine = tempstdGoalDetail.selectedBaseLine;
                //stdGDWrapper.stdGDetailsWrapper.availableParents = tempstdGoalDetail.availableParents;
                stdGDWrapper.stdGDetailsWrapper.selectedParent = tempstdGoalDetail.selectedParent;
                stdGDWrapper.stdGDetailsWrapper.previousSUMSto = tempstdGoalDetail.selectedParent;
                stdGDWrapper.stdGDetailsWrapper.valueTypes = tempstdGoalDetail.valueTypes;
                stdGDWrapper.stdGDetailsWrapper.selectedValueType = tempstdGoalDetail.selectedValueType;
                stdGDWrapper.stdGDetailsWrapper.value = tempstdGoalDetail.value;
                stdGDWrapper.stdGDetailsWrapper.discount = tempstdGoalDetail.discount;
                stdGDWrapper.stdGDetailsWrapper.childGTDs = tempstdGoalDetail.childGTDs;
                
                //Repopulate availableParents Parent List, On Each Edit of the Record there SUMS to Picklist should be decide Dyanmically
                List<SelectOption> avaialbaleParents = new List<SelectOption>();
                
                //ReInitialize this Set on Each edit of the GTD
                relatedChildOfEditedGTD = new Set<String>();
                
                //Add Default Value in ReInitialized Available List
                avaialbaleParents.add(new SelectOption('','--NONE--'));
                
                //Current Edited Records Unique Key, Needs to check if this Is SUMS to the ANy Record
                //If yes that means itself and its child record never can come in SUMs to Picklist
                String currentRecordKey = tempstdGoalDetail.stdGDetail.Goal_Type__c + '-' + tempstdGoalDetail.stdGDetail.Description__c + '-' + tempstdGoalDetail.stdGDetail.Target_Type__c;
                
                //Check if Current Edited Record is SUMS to any GTD, then we need to check in Depth of the Map
                //To do that We need to User Recursion and prepare one list of all related child
                if(stdGDWrapper.mapForSUMstoRelationship.containsKey(currentRecordKey)){
                    
                    //Call this Recursive method to Parse Whole SumsTo map(stdGDWrapper.mapForSUMstoRelationship)
                    parseAndCreateChildList(currentRecordKey);
                }
                //Now loop over on each GTD and check if it is eligible for to be 
                for(StdGoalDetailSectionWrapper.StdGoalDetailWrapper sgDW : stdGDWrapper.stdGoalDetailsWrapper) {
                    String mapKey = sgDW.stdGDetail.Goal_Type__c + '-' + sgDW.stdGDetail.Description__c + '-' + sgDW.stdGDetail.Target_Type__c;
                    
                    //If Existing is Matched then No need to Add in SUMsto List
                    if(mapKey == currentRecordKey){
                        continue;
                    
                    //If Existing is not matched but having SUMS to Relationship then check its child list                          
                    }else if(mapKey != currentRecordKey && stdGDWrapper.mapForSUMstoRelationship.containsKey(currentRecordKey) && relatedChildOfEditedGTD.size() > 0){
                        if(relatedChildOfEditedGTD.contains(mapKey)){
                            continue;
                        }else{
                            
                            avaialbaleParents.add(new SelectOption(mapKey, sGDW.stdGDetail.Description__c != null ? sGDW.stdGDetail.Description__c : ''));  
                        }
                    }else{
                        avaialbaleParents.add(new SelectOption(mapKey, sGDW.stdGDetail.Description__c != null ? sGDW.stdGDetail.Description__c : ''));                      
                    }
                }
                stdGDWrapper.stdGDetailsWrapper.availableParents = avaialbaleParents;   
            }
        }catch(Exception e) {
            //Add Error on page
            ApexPages.addMessages(e);
        }
        
        //Return
        return null;
    }
    
    //Set to Hold Identify all related child of Edited Record which can be holded in Mutliple Hierarchy level in the Map
    Set<String> relatedChildOfEditedGTD = new Set<String>();
    
    /**
     *  @description    :   Recursion method to parse all child in the map corrosponding to orignal key passed.
     *                  :   Added BY - Rajeev Jain - 1/21/2016 - To Resolve SUMs to Issue
     *
     *  @args           :   
     *
     *  @return         :   void
     *
     **/
    //Parse Sum to Map
    public void parseAndCreateChildList(String key){
        
        if(stdGDWrapper.mapForSUMstoRelationship.containsKey(key)){
            
            //Loop over on each set value corrosponding to key 
            for(String setKey : stdGDWrapper.mapForSUMstoRelationship.get(key)){
                
                //Add in Related Child Set
                relatedChildOfEditedGTD.add(setKey);
                
                //Further Process Each Set child Key to check in Main Map as Key, because each child can hold its further child
                parseAndCreateChildList(setKey);
            }
        }else{
            
            //Return Blank if Map Key not found, that means not any element found matched in related list
            return;
        }
    }
    /**
     *  @description    :   This method is used to remove Std Goal Detail
     *
     *  @args           :   
     *
     *  @return         :   void
     *
     **/
    public void removeStdGoalDetail() {
        
        try {
            
            //Temp list of condition wrapper
            List<StdGoalDetailSectionWrapper.StdGoalDetailWrapper> tempStdGDetails = new List<StdGoalDetailSectionWrapper.StdGoalDetailWrapper>();
            
            //Add StdGoalDetailPacings in list
            stdGDPacingWrapper.avaliableStdGDetails = new List<SelectOption>();
            stdGDPacingWrapper.selectedStdGDetail = null;
            
            //Set to hold the baselines that are removed
            Set<String> setRemovedBLs = new Set<String>();
            
            //Integer
            Integer rowIndex = 1;
            
            //Set to hold the Parents unique Key
            Set<String> setParents = new Set<String>();
            
            //Loop through Std Goal Detail
            for(StdGoalDetailSectionWrapper.StdGoalDetailWrapper sgDW : stdGDWrapper.stdGoalDetailsWrapper) {
                
                String mapKey = sgDW.stdGDetail.Goal_Type__c + '-' + sgDW.stdGDetail.Description__c + '-' + sgDW.stdGDetail.Target_Type__c;
                
                //Remove Element from SUMSto Relationship Map
                if(sgDW.selected){
                    
                    if(stdGDWrapper.mapForSUMstoRelationship.containsKey(mapKey))
                        stdGDWrapper.mapForSUMstoRelationship.remove(mapKey);
                    else{
                        
                        //Loop over each map key and find it record going to be remove is exist as child in Map's Set
                        for(String str : stdGDWrapper.mapForSUMstoRelationship.keySet()){
                            if(stdGDWrapper.mapForSUMstoRelationship.get(str).contains(mapKey)){
                                stdGDWrapper.mapForSUMstoRelationship.get(str).remove(mapKey);
                            }
                        }
                    }   
                }
                
                //Code added to remove the GTD from the database. This only works in case of edit template
                if(sgDW.selected && sgDW.stdGDetail.id != null)
                    stdGoalDetailsToBeDelete.add(sgDW.stdGDetail);
                        
                //Check for selected check box
                if(!sgDW.selected) {
                    
                    //Update Std Goal Detail Index
                    sgDW.rowIndex = rowIndex;
                    rowIndex += 1;
                    
                    //Add in tem list
                    tempStdGDetails.add(sgDW);
                    
                    //Check for Target Type
                   /* if(sgDW.stdGDetail.Target_Type__c == ISSPConstants.STANDARD_GOAL_DETAIL_TARGET_TYPE_PACED) {
                        
                        //Check for size
                        if(stdGDPacingWrapper.avaliableStdGDetails.size() == 0) {
                            
                            //Set Std Goal detail
                            stdGDPacingWrapper.selectedStdGDetail = sgDW.stdGDetail.Goal_Type__c + '-' + sgDW.stdGDetail.Description__c + '-' + sgDW.stdGDetail.Target_Type__c;
                        }
                            
                            
                        //Add select option
                        stdGDPacingWrapper.avaliableStdGDetails.add(new SelectOption(sgDW.stdGDetail.Goal_Type__c + '-' + sgDW.stdGDetail.Description__c
                                                                                     + '-' + sgDW.stdGDetail.Target_Type__c,sgDW.stdGDetail.Description__c != null ? sgDW.stdGDetail.Description__c : ''));
                    }*/
                
                //Remove std goal detail from list
                } else if(mapGoalTypes.containsKey(sgDW.stdGDetail.Goal_Type__c + '-' + sgDW.stdGDetail.Description__c + '-' + sgDW.stdGDetail.Target_Type__c)) {
                    
                    //Remove Pacing list
                    if(stdGDPacingWrapper.stdGDetailPacings.containsKey(sgDW.stdGDetail.Goal_Type__c + '-' + sgDW.stdGDetail.Description__c + '-' + sgDW.stdGDetail.Target_Type__c))
                        stdGDPacingWrapper.stdGDetailPacings.remove(sgDW.stdGDetail.Goal_Type__c + '-' + sgDW.stdGDetail.Description__c + '-' + sgDW.stdGDetail.Target_Type__c);
                    
                    //Remove from summary field
                    if(mapStdGDSummary.containsKey(sgDW.stdGDetail.Goal_Type__c + '-' + sgDW.stdGDetail.Description__c + '-' + sgDW.stdGDetail.Target_Type__c))
                        mapStdGDSummary.remove(sgDW.stdGDetail.Goal_Type__c + '-' + sgDW.stdGDetail.Description__c + '-' + sgDW.stdGDetail.Target_Type__c);
                    
                    //Remove goal type
                    if(mapGoalTypes.containsKey(sgDW.stdGDetail.Goal_Type__c + '-' + sgDW.stdGDetail.Description__c + '-' + sgDW.stdGDetail.Target_Type__c))
                        mapGoalTypes.remove(sgDW.stdGDetail.Goal_Type__c + '-' + sgDW.stdGDetail.Description__c + '-' + sgDW.stdGDetail.Target_Type__c);
                    
                    //Populate set
                    setRemovedBLs.add(sgDW.stdGDetail.Goal_Type__c + '-' + sgDW.stdGDetail.Description__c + '-' + sgDW.stdGDetail.Target_Type__c);
                    
                    //Check for Parent SUMs to
                    if(String.isNotBlank(sgDW.selectedParent)) {
                        
                        //Check Parnet Id in set
                        setParents.add(sgDW.selectedParent);
                        
                        //Get the Parent GTD
                        StdGoalDetailSectionWrapper.StdGoalDetailWrapper sumsTo = goalTemplateDetail(sgDW.selectedParent);
                        
                        //Update the Values
                        if(sumsTo != null) {
                            
                            //Check for Childs
                            if(sumsTo.childGTDs != null && sumsTo.childGTDs > 0)
                                sumsTo.childGTDs--;
                            
                            //Check for total child
                            if(sumsTo.childGTDs == null || sumsTo.childGTDs <= 0)
                                sumsTo.stdGDetail.Summary__c = false;       
                        }
                    }   
                }
            }
            
            //Add in wrapper list
            if(stdGDPacingWrapper.stdGDetailPacings.containsKey(stdGDPacingWrapper.selectedStdGDetail))
                stdGoalDPacings = stdGDPacingWrapper.stdGDetailPacings.get(stdGDPacingWrapper.selectedStdGDetail);
            else
                stdGoalDPacings = new List<StdGoalDetailPacingSectionWrapper.StdGoalDetailPacing>();
            
            //Loop through the std goal details
            for(StdGoalDetailSectionWrapper.StdGoalDetailWrapper sgDW : tempStdGDetails) {
                
                //Baseline counter
                Integer bLCounter = sgDW.avaliableBaseLine.size();
                
                //Baseline Options
                List<SelectOption> baselineOptions = new List<SelectOption>();
                
                //Loop to remove removed std goal detail from available baseline
                for(Integer i = 0; i < bLCounter; i++) {
                    
                    //Check for value
                    if(setRemovedBLs.contains(sgDW.avaliableBaseLine[i].getValue())) {
                        
                        //Check for selected baseline
                        if(sgDW.selectedBaseLine == sgDW.avaliableBaseLine[i].getValue()) {
                            
                            //Set BL
                            sgDW.selectedBaseLine = '';
                            sgDW.stdGDetail.Baseline__c = null;
                        }
                            
                        
                        //Update Baseline Label
                        sgDW.selectedBaseLineLabel = sgDW.selectedBaseLine == null || sgDW.selectedBaseLine == '' ? '' : selectedOption(sgDW.avaliableBaseLine,sgDW.selectedBaseLine);
                        
                        //Check for BL label
                        if(String.isBlank(sgDW.selectedBaseLineLabel))
                            sgDW.stdGDetail.Baseline_Percentage__c = null;  
                       
                    } else
                        baselineOptions.add(new SelectOption(sgDW.avaliableBaseLine[i].getValue(), sgDW.avaliableBaseLine[i].getLabel()));
                }
                
                //Update Baseline Options
                sgDW.avaliableBaseLine = baselineOptions;
                
                //Parent (SUMs To) counter
                Integer aPCounter = sgDW.availableParents.size();
                
                //Baseline Options
                List<SelectOption> parentOptions = new List<SelectOption>();
                
                //Loop to remove removed goal template detail from available parents
                for(Integer i = 0; i < aPCounter; i++) {
                    
                    //Check for value
                    if(setRemovedBLs.contains(sgDW.availableParents[i].getValue())) {
                        
                        //Check for selected baseline
                        if(sgDW.selectedParent == sgDW.availableParents[i].getValue()) {
                            sgDW.selectedParent = '';
                            sgDW.selectedparentLabel = '';
                            sgDW.stdGDetail.Parent__c = null;
                        }
                        
                    } else
                        parentOptions.add(new SelectOption(sgDW.availableParents[i].getValue(), sgDW.availableParents[i].getLabel()));
                }
                
                //Update Parents
                sgDW.availableParents = parentOptions;
            }
            
            //Repopulate the Goal template details wrapper
            stdGDWrapper.stdGoalDetailsWrapper = tempStdGDetails;
            stdGDSummary = mapStdGDSummary.values();
            
            //Sort
            stdGDSummary.sort();
            
            //Check for Parents
            if(setParents.size() > 0) {
                
                //Loop through the GTDs to re-calculate the Parent's value 
                for(StdGoalDetailSectionWrapper.StdGoalDetailWrapper sgDW : stdGDWrapper.stdGoalDetailsWrapper) {
                    
                    //Unique Key
                    String pUK = sgDW.stdGDetail.Goal_Type__c + '-' + sgDW.stdGDetail.Description__c + '-' +  sgDW.stdGDetail.Target_Type__c;
                    
                    //Check unique key in set
                    if(setParents.contains(pUK))
                        doCalculation(sgDW);
                }
            } 
            
            //Call method for shorting
            setRowIndex();
            
            //Call method
            populateBaselineAndParents();
            
        }catch(Exception e) {
            //Add Error on page
            ApexPages.addMessages(e);
        }
    }
    
    /**
     *  @description    :   This method is used to clone the goal template details
     *
     *  @args           :   
     *
     *  @return         :   void
     *
     **/
    public void cloneGoalTemplateDetails() {
        
        //Temp list of goal template details wrapper
        List<StdGoalDetailSectionWrapper.StdGoalDetailWrapper> tempStdGDetails = new List<StdGoalDetailSectionWrapper.StdGoalDetailWrapper>();
        
        //Temp list of children explicit type goal template details
        List<StdGoalDetailSectionWrapper.StdGoalDetailWrapper> tempExplicitGTDetails = new List<StdGoalDetailSectionWrapper.StdGoalDetailWrapper>();
        
        //Add All the goal template details in temp list
        tempStdGDetails.addAll(stdGDWrapper.stdGoalDetailsWrapper);
        
        //Map to hold the Parent goal template details
        Map<String, String> mapParentGTDs = new Map<String,String>();
            
        //Loop through Std Goal Detail
        for(StdGoalDetailSectionWrapper.StdGoalDetailWrapper sgDW : tempStdGDetails) {
                  
            //Check for selected check box
            if(sgDW.selected) {
                
                //Instance of Goal template detail
                Standard_Goal_Detail__c sGD = sgDW.stdGDetail.clone(false,true);
                sGD.Summary__c = false;
                
                //Update description of goal template detail
                if(sgDW.stdGDetail.Description__c != null)
                    sGD.Description__c = (ISSPConstants.CLONED_GOAL_TEMPLATE_DETAIL_DESCRIPTION_PREPEND_VALUE + sgDW.stdGDetail.Description__c).left(25).trim();
                else
                    sGD.Description__c = ISSPConstants.CLONED_GOAL_TEMPLATE_DETAIL_DESCRIPTION_PREPEND_VALUE.trim();
                
                //Populate the GOal Types map
                mapGoalTypes.put(sGD.Goal_Type__c + '-' + sGD.Description__c + '-' + sGD.Target_Type__c,
                                 mapGoalTypes.get(sgDW.stdGDetail.Goal_Type__c + '-' + sgDW.stdGDetail.Description__c + '-' + sgDW.stdGDetail.Target_Type__c));
                
                //Add Parent explicit goal template detail in map
                    mapParentGTDs.put(sgDW.stdGDetail.Goal_Type__c + '-' + sgDW.stdGDetail.Description__c + '-' + sgDW.stdGDetail.Target_Type__c,
                                      sgDW.stdGDetail.Goal_Type__c + '-' + sGD.Description__c + '-' + sGD.Target_Type__c);
                //Check for Parent
                /*if(String.isBlank(sgDW.selectedParent)) {
                    
                    //Add Parent explicit goal template detail in map
                    mapParentGTDs.put(sgDW.stdGDetail.Goal_Type__c + '-' + sgDW.stdGDetail.Description__c + '-' + sgDW.stdGDetail.Target_Type__c,
                                      sgDW.stdGDetail.Goal_Type__c + '-' + sGD.Description__c + '-' + sGD.Target_Type__c);
                    
                    //Call method to clone the goal template details
                    prepareGoalTemplateDetails(sgDW.stdGDetail.Goal_Type__c, sgDW.goalType, sGD, sgDW.selectedBaseLine, sgDW.selectedParent);
                    
                    //Clone the conditions
                    cloneGTDConditions(sgDW.stdGoalDetailConditions);
                    
                    //Clone GTDMPs
                    cloneGTDMPs(sgDW.gTDMPeriods);
                
                } else if(String.isNotBlank(sgDW.selectedParent))
                    tempExplicitGTDetails.add(sgDW);*/
                //Hnadle child records
                 if(String.isNotBlank(sgDW.selectedParent))
                    tempExplicitGTDetails.add(sgDW);
                 //Handle Parent Record   
                 else{   
                    
                    //Call method to clone the goal template details
                    prepareGoalTemplateDetails(sgDW.stdGDetail.Goal_Type__c, sgDW.goalType, sGD, sgDW.selectedBaseLine, sgDW.selectedParent);
                    
                    //Clone the conditions
                    cloneGTDConditions(sgDW.stdGoalDetailConditions);
                    
                    //Clone GTDMPs
                    cloneGTDMPs(sgDW.gTDMPeriods);
                 }
                 
                //Reset selected flag
                sgDW.selected = false;
            }   
        }
        
        //Check for child list
        if(tempExplicitGTDetails.size() > 0) {
            
            //Loop through the children explicit goal template details
            for(StdGoalDetailSectionWrapper.StdGoalDetailWrapper sgDW : tempExplicitGTDetails) {
                
                //Instance of Goal template detail
                Standard_Goal_Detail__c sGD = sgDW.stdGDetail.clone(false,true);
                
                //Update description of goal template detail
                sGD.Description__c = (ISSPConstants.CLONED_GOAL_TEMPLATE_DETAIL_DESCRIPTION_PREPEND_VALUE + sgDW.stdGDetail.Description__c).left(25).trim();
                
                //Populate the GOal Types map
                mapGoalTypes.put(sGD.Goal_Type__c + '-' + sGD.Description__c + '-' + sGD.Target_Type__c,
                                 mapGoalTypes.get(sgDW.stdGDetail.Goal_Type__c + '-' + sgDW.stdGDetail.Description__c + '-' + sgDW.stdGDetail.Target_Type__c));
                
                //Check if map contains the selected parent
                if(mapParentGTDs.containsKey(sgDW.selectedParent)) {
                    
                    //Call method to clone the goal template details
                    prepareGoalTemplateDetails(sgDW.stdGDetail.Goal_Type__c, sgDW.goalType, sGD, sgDW.selectedBaseLine, mapParentGTDs.get(sgDW.selectedParent));
                    
                    //Clone the conditions
                    cloneGTDConditions(sgDW.stdGoalDetailConditions);
                    
                    //Clone GTDMPs
                    cloneGTDMPs(sgDW.gTDMPeriods);
                    
                } else {
                    
                    //Call method to clone the goal template details
                    prepareGoalTemplateDetails(sgDW.stdGDetail.Goal_Type__c, sgDW.goalType, sGD, sgDW.selectedBaseLine, sgDW.selectedParent);
                    
                    //Clone the conditions
                    cloneGTDConditions(sgDW.stdGoalDetailConditions);
                    
                    //Clone GTDMPs
                    cloneGTDMPs(sgDW.gTDMPeriods);
                }
            }
        }
        
        //Call method for shorting
        setRowIndex();
        
        //Call method
        populateBaselineAndParents();    
    }
    
    /**
     *  @description    :   This method is used to load the Discription and Discount according to selected Goal Type
     *
     *  @args           :   
     *
     *  @return         :   void
     *
     **/
    public void populateGTDetailFields() {
        
        //Query through Goal type
        List<Goal_Type__c> gT = [Select Id, Name,Description__c, Discount__c, Minimum__c, Discount_Type__c From Goal_Type__c Where Id =: stdGDWrapper.stdGD.Goal_Type__c];
        
        //Check for goal type
        if(gT.size() > 0) {
            
            //Update discount Type value
            stdGDWrapper.discountType = gT[0].Discount_Type__c;
            stdGDWrapper.stdGD.Minimum__c = gT[0].Minimum__c;
            
            //Check for description
            if(String.isBlank(stdGDWrapper.stdGD.Description__c))
                stdGDWrapper.stdGD.Description__c = gT[0].Description__c;
            
            //Update Discount
            if(stdGDWrapper.stdGD.Discount__c == null || stdGDWrapper.stdGD.Discount__c <= 0)
                stdGDWrapper.stdGD.Discount__c = gT[0].Discount__c;
            else
                stdGDWrapper.stdGD.Discount__c = null;  
        }
    }
    
    /**
     *  @description    :   This method is used to populate the start and end date on the Goal Template Detail according to selected Period
     *
     *  @args           :   
     *
     *  @return         :   void
     *
     **/
    public void populatePeriods() {
        
        //Check for Period Value
        if(String.isNotBlank(stdGDWrapper.stdGD.Period__c) && stdGDWrapper.stdGDetailsWrapper.mapPeriods.containsKey(stdGDWrapper.stdGD.Period__c)) {
            
            //Set Start and End date
            stdGDWrapper.stdGD.Period_Start__c = stdGDWrapper.stdGDetailsWrapper.mapPeriods.get(stdGDWrapper.stdGD.Period__c).Start__c;
            stdGDWrapper.stdGD.Period_End__c = stdGDWrapper.stdGDetailsWrapper.mapPeriods.get(stdGDWrapper.stdGD.Period__c).End__c;
            
            populateBaselinePercent();
        } else {
            
            //Set Start and End date
            stdGDWrapper.stdGD.Period_Start__c = null;
            stdGDWrapper.stdGD.Period_End__c = null;
        }
        
    }
    
    /**
     *  @description    :   This method is used to calculate the Value for Goal Template Detail
     *
     *  @args           :   
     *
     *  @return         :   void
     *
     **/
    public void calculateValues() {
        
        //Set values
        stdGDWrapper.stdGDetailsWrapper.gTAmount = stdGoal.Amount__c;
        stdGDWrapper.stdGDetailsWrapper.gTCounter = stdGoal.Counter__c;
        stdGDWrapper.stdGDetailsWrapper.gTPercent = stdGoal.Percent__c;
        
        //Set default values
        if(String.isBlank(stdGDWrapper.selectedBaseLine) && stdGDWrapper.stdGD.Amount__c == null && stdGDWrapper.stdGD.Count__c == null && stdGDWrapper.stdGD.Percent__c == null)
            stdGDWrapper.stdGD.Amount__c = 0;   
        
        System.debug('stdGSWrapper.selectedSGValueType ::: ' + stdGSWrapper.selectedSGValueType);
        System.debug('Check for stdGDWrapper.stdGDetailsWrapper.selectedValueType :::: ' + stdGDWrapper.stdGDetailsWrapper.selectedValueType);
        //Check for Baseline
        if(String.isNotBlank(stdGDWrapper.selectedBaseLine) && stdGDWrapper.selectedBaseLine == ISSPConstants.TEMPLATE_BASELINE) {
            
            //Check for value Type
            if(stdGSWrapper.selectedSGValueType == 'Amount') {
                
                stdGDWrapper.stdGD.Amount__c = stdGDWrapper.stdGD.Baseline_Percentage__c != null && stdGDWrapper.stdGD.Baseline_Percentage__c > 0 && stdGoal.Amount__c > 0
                                                ? (stdGoal.Amount__c * stdGDWrapper.stdGD.Baseline_Percentage__c/100).setScale(0) : stdGoal.Amount__c;
                
                stdGDWrapper.stdGD.Count__c = null;
                stdGDWrapper.stdGD.Percent__c = null;
            
            } else if(stdGSWrapper.selectedSGValueType == 'Count') {
                
                stdGDWrapper.stdGD.Count__c = stdGDWrapper.stdGD.Baseline_Percentage__c != null && stdGDWrapper.stdGD.Baseline_Percentage__c > 0 && stdGoal.Counter__c > 0
                                                ? (stdGoal.Counter__c * stdGDWrapper.stdGD.Baseline_Percentage__c/100).setScale(0) : stdGoal.Counter__c;
                
                stdGDWrapper.stdGD.Amount__c = null;
                stdGDWrapper.stdGD.Percent__c = null;
            
            } else if(stdGSWrapper.selectedSGValueType == 'Percent') {
                
                stdGDWrapper.stdGD.Percent__c = stdGDWrapper.stdGD.Baseline_Percentage__c != null && stdGDWrapper.stdGD.Baseline_Percentage__c > 0 && stdGoal.Percent__c > 0
                                                ? (stdGoal.Percent__c * stdGDWrapper.stdGD.Baseline_Percentage__c/100).setScale(0) : stdGoal.Percent__c;
                
                stdGDWrapper.stdGD.Amount__c = null;
                stdGDWrapper.stdGD.Count__c = null;
            }
                
        } else if(String.isNotBlank(stdGDWrapper.selectedBaseLine) && mapGTDWrapper.containsKey(stdGDWrapper.selectedBaseLine)) {
            
            //Instance of Wrapper
            StdGoalDetailSectionWrapper.StdGoalDetailWrapper gTDW = mapGTDWrapper.get(stdGDWrapper.selectedBaseLine);
            
            //Apply Values according to Baseline
            
            //Check for Amount
            if(gTDW.stdGDetail.Amount__c != null) {
                
                stdGDWrapper.stdGD.Amount__c = stdGDWrapper.stdGD.Baseline_Percentage__c != null && stdGDWrapper.stdGD.Baseline_Percentage__c > 0
                                               ? gTDW.stdGDetail.Amount__c * (stdGDWrapper.stdGD.Baseline_Percentage__c/100) : gTDW.stdGDetail.Amount__c;
                
                stdGDWrapper.stdGD.Count__c = null;
                stdGDWrapper.stdGD.Percent__c = null;
            }
                
            //Check for Count
            if(gTDW.stdGDetail.Count__c != null) {
                
                stdGDWrapper.stdGD.Count__c = stdGDWrapper.stdGD.Baseline_Percentage__c != null && stdGDWrapper.stdGD.Baseline_Percentage__c > 0
                                               ? gTDW.stdGDetail.Count__c * (stdGDWrapper.stdGD.Baseline_Percentage__c/100) : gTDW.stdGDetail.Count__c;
                
                stdGDWrapper.stdGD.Amount__c = null;
                stdGDWrapper.stdGD.Percent__c = null;
            }
                
            //Check for Percent
            if(gTDW.stdGDetail.Percent__c != null) {
                
                stdGDWrapper.stdGD.Percent__c = stdGDWrapper.stdGD.Baseline_Percentage__c != null && stdGDWrapper.stdGD.Baseline_Percentage__c > 0
                                               ? gTDW.stdGDetail.Percent__c * (stdGDWrapper.stdGD.Baseline_Percentage__c/100) : gTDW.stdGDetail.Percent__c;
                
                stdGDWrapper.stdGD.Amount__c = null;
                stdGDWrapper.stdGD.Count__c = null;
            }
                
        }
        
        //Check for Taget Type
        if(String.isBlank(stdGDWrapper.selectedBaseLine) && oldGTD != null && oldGTD.Target_Type__c == ISSPConstants.STANDARD_GOAL_DETAIL_TARGET_TYPE_EXPLICIT
            && stdGDWrapper.stdGD.Target_Type__c == ISSPConstants.STANDARD_GOAL_DETAIL_TARGET_TYPE_PACED && oldGTD.Discount__c > 0) {
            
            //Check for value
            if(stdGDWrapper.stdGD.Amount__c != null && stdGDWrapper.stdGD.Amount__c > 0 && oldGTD.Amount__c == stdGDWrapper.stdGD.Amount__c)
                stdGDWrapper.stdGD.Amount__c = (stdGDWrapper.stdGD.Amount__c * (100/(100 - oldGTD.Discount__c))).setScale(0);
            
            else if(stdGDWrapper.stdGD.Count__c != null && stdGDWrapper.stdGD.Count__c > 0 && oldGTD.Count__c == stdGDWrapper.stdGD.Count__c)
                stdGDWrapper.stdGD.Count__c = (stdGDWrapper.stdGD.Count__c * (100/(100 - oldGTD.Discount__c))).setScale(0);
            
            else if(stdGDWrapper.stdGD.Percent__c != null && stdGDWrapper.stdGD.Percent__c > 0 && oldGTD.Count__c == stdGDWrapper.stdGD.Percent__c)
                stdGDWrapper.stdGD.Percent__c = (stdGDWrapper.stdGD.Percent__c * (100/(100 - oldGTD.Discount__c))).setScale(0);         
        }
        
        //Apply discount
        //Check for Discount field
        if(stdGDWrapper.stdGD.Target_Type__c == ISSPConstants.STANDARD_GOAL_DETAIL_TARGET_TYPE_EXPLICIT) {
            
            //Check for old Target Type
            if(String.isBlank(stdGDWrapper.selectedBaseLine) && oldGTD != null && oldGTD.Target_Type__c == stdGDWrapper.stdGD.Target_Type__c
                && oldGTD.Discount__c > 0 && oldGTD.Discount__c != stdGDWrapper.stdGD.Discount__c && oldGTD.Amount__c == stdGDWrapper.stdGD.Amount__c
                && oldGTD.Count__c == stdGDWrapper.stdGD.Count__c && oldGTD.Percent__c == stdGDWrapper.stdGD.Percent__c) {
                
                //Add old values discount
                if(stdGDWrapper.stdGD.Amount__c != null && stdGDWrapper.stdGD.Amount__c > 0)
                    stdGDWrapper.stdGD.Amount__c = (stdGDWrapper.stdGD.Amount__c * (100/(100 - oldGTD.Discount__c))).setScale(0);
                else if(stdGDWrapper.stdGD.Count__c != null && stdGDWrapper.stdGD.Count__c > 0)
                    stdGDWrapper.stdGD.Count__c = (stdGDWrapper.stdGD.Count__c * (100/(100 - oldGTD.Discount__c))).setScale(0);
                else if(stdGDWrapper.stdGD.Percent__c != null && stdGDWrapper.stdGD.Percent__c > 0)
                    stdGDWrapper.stdGD.Percent__c = (stdGDWrapper.stdGD.Percent__c * (100/(100 - oldGTD.Discount__c))).setScale(0);
            }
            
            //Apply discount
            if(stdGDWrapper.stdGD.Discount__c != null && stdGDWrapper.stdGD.Discount__c > 0
                && (String.isNotBlank(stdGDWrapper.selectedBaseLine) || oldGTD.Target_Type__c != stdGDWrapper.stdGD.Target_Type__c
                    || oldGTD.Amount__c != stdGDWrapper.stdGD.Amount__c
                    || oldGTD.Count__c != stdGDWrapper.stdGD.Count__c
                    || oldGTD.Percent__c != stdGDWrapper.stdGD.Percent__c
                    || oldGTD.Discount__c != stdGDWrapper.stdGD.Discount__c)) {
            
                if(stdGDWrapper.stdGD.Amount__c != null && stdGDWrapper.stdGD.Amount__c > 0)
                    stdGDWrapper.stdGD.Amount__c -= (stdGDWrapper.stdGD.Amount__c * (stdGDWrapper.stdGD.Discount__c/100)).setScale(0);  
                else if(stdGDWrapper.stdGD.Count__c != null && stdGDWrapper.stdGD.Count__c > 0)
                    stdGDWrapper.stdGD.Count__c -= (stdGDWrapper.stdGD.Count__c * (stdGDWrapper.stdGD.Discount__c/100)).setScale(0);
                else if(stdGDWrapper.stdGD.Percent__c != null && stdGDWrapper.stdGD.Percent__c > 0)
                    stdGDWrapper.stdGD.Percent__c -= (stdGDWrapper.stdGD.Percent__c * (stdGDWrapper.stdGD.Percent__c/100)).setScale(0);
            }
        }
    }
    
    /**
     *  @description    :   This method is used to calculate the children sum on the parent explicit goal template
     *
     *  @args           :   
     *
     *  @return         :   void
     *
     **/
    public void doCalculate() {
        
        //Set to hold the selected GTDs Unique Combo
        Set<String> setGTDUniqueKeys = new Set<String>();
        
        //Set to hold the Parent (SUMs TO) GTDs
        Set<String> setSUMsTos = new Set<String>();
        
        //Map to hold the GTDs
        Map<String, StdGoalDetailSectionWrapper.StdGoalDetailWrapper> mapTempGTDetails = new Map<String, StdGoalDetailSectionWrapper.StdGoalDetailWrapper>();
        
        //Loop through the Goal template detail wrapper to perform the calculation for parent explicit goal templates
        for(StdGoalDetailSectionWrapper.StdGoalDetailWrapper sgDW : stdGDWrapper.stdGoalDetailsWrapper) {
            
            //Check if record is selected or not
            if(sgDW.selected) 
                //Add unique key in map
                setGTDUniqueKeys.add(sgDW.stdGDetail.Goal_Type__c + '-' + sgDW.stdGDetail.Description__c + '-' + sgDW.stdGDetail.Target_Type__c);
             
        }
        
        //Temp Wrapper list
        List<StdGoalDetailSectionWrapper.StdGoalDetailWrapper> tempGTDWrapper = new List<StdGoalDetailSectionWrapper.StdGoalDetailWrapper>();
        
        //Loop through the Goal template detail wrapper to perform the calculation for parent explicit goal templates
        for(StdGoalDetailSectionWrapper.StdGoalDetailWrapper sgDW : stdGDWrapper.stdGoalDetailsWrapper) {
            
            //Baseline instance
            StdGoalDetailSectionWrapper.StdGoalDetailWrapper baseline = String.isNotBlank(sgDW.selectedBaseLine) ? goalTemplateDetail(sgDW.selectedBaseLine) : null;
            
            //Check if record is selected or not
            if(sgDW.selected && String.isNotBlank(sgDW.selectedBaseLine)
                && (sgDW.selectedBaseLine == ISSPConstants.TEMPLATE_BASELINE || !setGTDUniqueKeys.contains(sgDW.selectedBaseLine)
                    || (baseline != null && String.isBlank(baseline.selectedBaseLine)))) {
                
                //Add Parent in set
                if(String.isNotBlank(sgDW.selectedParent))
                    setSUMsTos.add(sgDW.selectedParent);
                
                //Call the calculation method
                doCalculation(sgDW, mapGTDWrapper);
                
                //Populate map
                mapGTDWrapper.put(sgDW.stdGDetail.Goal_Type__c + '-' + sgDW.stdGDetail.Description__c + '-' + sgDW.stdGDetail.Target_Type__c, sgDW);
                
                //Populate temp map as well
                mapTempGTDetails.put(sgDW.stdGDetail.Goal_Type__c + '-' + sgDW.stdGDetail.Description__c + '-' + sgDW.stdGDetail.Target_Type__c, sgDW);
            
            } else if(sgDW.selected && String.isNotBlank(sgDW.selectedBaseLine))
                tempGTDWrapper.add(sgDW);   
        }
        
        //Check for list size
        if(tempGTDWrapper.size() > 0)
            doCalculation(tempGTDWrapper, mapTempGTDetails, setSUMsTos);
        
        //Loop through the Goal template detail wrapper to perform the calculation for parent explicit goal templates
        for(StdGoalDetailSectionWrapper.StdGoalDetailWrapper sgDW : stdGDWrapper.stdGoalDetailsWrapper) {
            
            //Parent unique key
            String pUK = sgDW.stdGDetail.Goal_Type__c + '-' + sgDW.stdGDetail.Description__c + '-' +  sgDW.stdGDetail.Target_Type__c;
            
            //Check if record is selected or not
            if((sgDW.selected && String.isBlank(sgDW.selectedParent)) || setSUMsTos.contains(pUK)) {
                
                //Call the method
                doCalculation(sgDW);
            }
        }
    }
    
    /**
     *  @description    :   This method is used to perform the calculation on the click of Calc button
     *
     *  @args           :   List<StdGoalDetailSectionWrapper.StdGoalDetailWrapper>, Map<String, StdGoalDetailSectionWrapper.StdGoalDetailWrapper>
     *
     *  @return         :   void
     *
     **/
    private void doCalculation(List<StdGoalDetailSectionWrapper.StdGoalDetailWrapper> stdGoalDetailsWrappers,
                               Map<String, StdGoalDetailSectionWrapper.StdGoalDetailWrapper> mapTempGTDetails, Set<String> setSUMsTos) {
        
        //Temp Wrapper list
        List<StdGoalDetailSectionWrapper.StdGoalDetailWrapper> tempGTDWrapper = new List<StdGoalDetailSectionWrapper.StdGoalDetailWrapper>();
        
        //Loop through the Goal template detail wrapper to perform the calculation for parent explicit goal templates
        for(StdGoalDetailSectionWrapper.StdGoalDetailWrapper sgDW : stdGoalDetailsWrappers) {
            
            //Check if record is selected or not
            if(sgDW.selected && String.isNotBlank(sgDW.selectedBaseLine) && mapTempGTDetails.containsKey(sgDW.selectedBaseLine)) {
                
                //Add Parent in set
                setSUMsTos.add(sgDW.selectedParent);
                
                //Call the calculation method
                doCalculation(sgDW, mapTempGTDetails);
                
                //Populate map
                mapGTDWrapper.put(sgDW.stdGDetail.Goal_Type__c + '-' + sgDW.stdGDetail.Description__c + '-' + sgDW.stdGDetail.Target_Type__c, sgDW);
                
                //Populate temp map as well
                mapTempGTDetails.put(sgDW.stdGDetail.Goal_Type__c + '-' + sgDW.stdGDetail.Description__c + '-' + sgDW.stdGDetail.Target_Type__c, sgDW);
            
            } else if(sgDW.selected && String.isNotBlank(sgDW.selectedBaseLine))
                tempGTDWrapper.add(sgDW);   
        }
        
        //Check for list size
        if(tempGTDWrapper.size() > 0)
            doCalculation(tempGTDWrapper, mapTempGTDetails, setSUMsTos);    
    }
    
    /**
     *  @description    :   This method is used to perform the calculation on the click of Calc button
     *
     *  @args           :   StdGoalDetailSectionWrapper.StdGoalDetailWrapper, Map<String, StdGoalDetailSectionWrapper.StdGoalDetailWrapper>
     *
     *  @return         :   void
     *
     **/
    private void doCalculation(StdGoalDetailSectionWrapper.StdGoalDetailWrapper sgDW, Map<String, StdGoalDetailSectionWrapper.StdGoalDetailWrapper> mapTempGTDetails) {
        
        //Set default values
        if(sgDW.stdGDetail.Amount__c == null && sgDW.stdGDetail.Count__c == null && sgDW.stdGDetail.Percent__c == null)
            sgDW.stdGDetail.Amount__c = 0;  
        
        //Check for Baseline
        if(sgDW.selectedBaseLine == ISSPConstants.TEMPLATE_BASELINE) {
            
            //Apply the Values
            sgDW.stdGDetail.Amount__c = sgDW.stdGDetail.Baseline_Percentage__c != null && sgDW.stdGDetail.Baseline_Percentage__c > 0 && stdGoal.Amount__c > 0
                                           ? (stdGoal.Amount__c * sgDW.stdGDetail.Baseline_Percentage__c/100).setScale(0) : stdGoal.Amount__c;
            sgDW.stdGDetail.Count__c = sgDW.stdGDetail.Baseline_Percentage__c != null && sgDW.stdGDetail.Baseline_Percentage__c > 0 && stdGoal.Counter__c > 0
                                          ? (stdGoal.Counter__c * sgDW.stdGDetail.Baseline_Percentage__c/100).setScale(0) : stdGoal.Counter__c;
            sgDW.stdGDetail.Percent__c = sgDW.stdGDetail.Baseline_Percentage__c != null && sgDW.stdGDetail.Baseline_Percentage__c > 0 && stdGoal.Percent__c > 0
                                          ? (stdGoal.Percent__c * sgDW.stdGDetail.Baseline_Percentage__c/100).setScale(0) : stdGoal.Percent__c;
           
            System.debug('Check Template Baseline Section ::: ');
            System.debug('Check stdGoal.Value_Type__c ::: ' + stdGoal.Value_Type__c);
            System.debug('Check sgDW.stdGDetail.Value_Type__c ::: ' + sgDW.stdGDetail.Value_Type__c)
            ;           
            sgDW.selectedValueType = stdGoal.Value_Type__c;           
            sgDW.stdGDetail.Value_Type__c = sgDW.selectedValueType;
            
            //Set Value option
            /*if(sgDW.stdGDetail.Amount__c > 0 || (sgDW.stdGDetail.Amount__c != null && sgDW.stdGDetail.Count__c == null && sgDW.stdGDetail.Percent__c == null)){
                sgDW.selectedValueType = 'Amount';
                sgDW.stdGDetail.Value_Type__c = 'Amount';
            }else if(sgDW.stdGDetail.Count__c > 0 || (sgDW.stdGDetail.Count__c != null && sgDW.stdGDetail.Amount__c == null && sgDW.stdGDetail.Percent__c == null)){
                sgDW.selectedValueType = 'Count';
                sgDW.stdGDetail.Value_Type__c = 'Count';
            }else if(sgDW.stdGDetail.Percent__c > 0 || (sgDW.stdGDetail.Percent__c != null && sgDW.stdGDetail.Amount__c == null && sgDW.stdGDetail.Count__c == null)){
                sgDW.selectedValueType = 'Percent';
                sgDW.stdGDetail.Value_Type__c = 'Percent';
            }  */  
        } else if(mapTempGTDetails.containsKey(sgDW.selectedBaseLine)) {
            
            //Instance of Wrapper
            StdGoalDetailSectionWrapper.StdGoalDetailWrapper gTDW = mapTempGTDetails.get(sgDW.selectedBaseLine);
            
            //Apply Values according to Baseline
            
            //Check for Amount
            if(gTDW.stdGDetail.Amount__c != null)
                sgDW.stdGDetail.Amount__c = sgDW.stdGDetail.Baseline_Percentage__c != null && sgDW.stdGDetail.Baseline_Percentage__c > 0
                                               ? gTDW.stdGDetail.Amount__c * (sgDW.stdGDetail.Baseline_Percentage__c/100) : gTDW.stdGDetail.Amount__c;
            
            //Check for Count'
            if(gTDW.stdGDetail.Count__c != null)
                sgDW.stdGDetail.Count__c = sgDW.stdGDetail.Baseline_Percentage__c != null && sgDW.stdGDetail.Baseline_Percentage__c > 0
                                               ? gTDW.stdGDetail.Count__c * (sgDW.stdGDetail.Baseline_Percentage__c/100) : gTDW.stdGDetail.Count__c;
            
            //Check for Percent
            if(gTDW.stdGDetail.Percent__c != null)
                sgDW.stdGDetail.Percent__c = sgDW.stdGDetail.Baseline_Percentage__c != null && sgDW.stdGDetail.Baseline_Percentage__c > 0
                                               ? gTDW.stdGDetail.Percent__c * (sgDW.stdGDetail.Baseline_Percentage__c/100) : gTDW.stdGDetail.Percent__c;
            
            //Set Value option
           /* if(sgDW.stdGDetail.Amount__c > 0 || (sgDW.stdGDetail.Amount__c != null && sgDW.stdGDetail.Count__c == null && sgDW.stdGDetail.Percent__c == null)){
                sgDW.selectedValueType = 'Amount';
                sgDW.stdGDetail.Value_Type__c = 'Amount';
            }else if(sgDW.stdGDetail.Count__c > 0 || (sgDW.stdGDetail.Count__c != null && sgDW.stdGDetail.Amount__c == null && sgDW.stdGDetail.Percent__c == null)){
                sgDW.selectedValueType = 'Count';
                sgDW.stdGDetail.Value_Type__c = 'Count';
            } else if(sgDW.stdGDetail.Percent__c > 0 || (sgDW.stdGDetail.Percent__c != null && sgDW.stdGDetail.Amount__c == null && sgDW.stdGDetail.Count__c == null)){
                sgDW.selectedValueType = 'Percent';
                sgDW.stdGDetail.Value_Type__c = 'Percent';
            }*/
            sgDW.selectedValueType = gTDW.selectedValueType;
            sgDW.stdGDetail.Value_Type__c = sgDW.selectedValueType;
        }
        
        //Apply discount
        //Check for Discount field
        if(sgDW.stdGDetail.Target_Type__c == ISSPConstants.STANDARD_GOAL_DETAIL_TARGET_TYPE_EXPLICIT && 
            sgDW.stdGDetail.Discount__c != null && sgDW.stdGDetail.Discount__c > 0) {
            
            //Apply discount
            if(sgDW.stdGDetail.Amount__c != null && sgDW.stdGDetail.Amount__c > 0)
                sgDW.stdGDetail.Amount__c -= (sgDW.stdGDetail.Amount__c * (sgDW.stdGDetail.Discount__c/100)).setScale(0);  
            else if(sgDW.stdGDetail.Count__c != null && sgDW.stdGDetail.Count__c > 0)
                sgDW.stdGDetail.Count__c -= (sgDW.stdGDetail.Count__c * (sgDW.stdGDetail.Discount__c/100)).setScale(0);
            else if(sgDW.stdGDetail.Percent__c != null && sgDW.stdGDetail.Percent__c > 0)
                sgDW.stdGDetail.Percent__c -= (sgDW.stdGDetail.Percent__c * (sgDW.stdGDetail.Percent__c/100)).setScale(0); 
        }
    }
    
    /**
     *  @description    :   Method to perform the calculations for explicit type goal templates
     *
     *  @args           :   StdGoalDetailSectionWrapper.StdGoalDetailWrapper 
     *
     *  @return         :   void
     *
     **/
    public void doCalculation(StdGoalDetailSectionWrapper.StdGoalDetailWrapper parentGTD) {
        
        //Variable to hold the parent identification
        String selectedParent = parentGTD.stdGDetail.Goal_Type__c + '-' + parentGTD.stdGDetail.Description__c + '-' + parentGTD.stdGDetail.Target_Type__c;
        
        //Variables to hold the Amount and Count total
        Decimal totalAmount = 0;
        Decimal totalCount = 0;
        Decimal totalPercent = 0;
        
        //Update the value
        parentGTD.gTAmount = stdGoal.Amount__c;
        parentGTD.gTCounter = stdGoal.Counter__c;
        parentGTD.gTPercent = stdGoal.Percent__c;
        
        //Variable to identify that parent has the children or not
        Boolean hasChildren = false;
        
        //Loop through the goal template details
        for(StdGoalDetailSectionWrapper.StdGoalDetailWrapper sgDW : stdGDWrapper.stdGoalDetailsWrapper) {
            
            //Check for Target Type
            if(sgDW.selectedParent == selectedParent) {
                
                //Set flag to true
                hasChildren = true;
                
                //Update Parent goal template detail's value
                totalAmount += sgDW.stdGDetail.Amount__c != null ? sgDW.stdGDetail.Amount__c : 0;
                totalCount +=  sgDW.stdGDetail.Count__c != null ? sgDW.stdGDetail.Count__c : 0;
                totalPercent +=  sgDW.stdGDetail.Percent__c != null ? sgDW.stdGDetail.Percent__c : 0;
            }       
        }
        
        //Check for flag
        if(hasChildren) {
            
            //Check for Amount
            if(totalAmount > 0) {
                
                //Update Parent Amount
                parentGTD.stdGDetail.Amount__c = totalAmount;
                parentGTD.stdGDetail.Count__c = null;
                parentGTD.stdGDetail.Percent__c = null;
                parentGTD.selectedValueType = 'Amount';
                parentGTD.stdGDetail.Value_Type__c = 'Amount';
                
                //Check for discount
                if(parentGTD.stdGDetail.Discount__c != null && parentGTD.stdGDetail.Discount__c > 0)
                    parentGTD.stdGDetail.Amount__c -= (parentGTD.stdGDetail.Amount__c * (parentGTD.stdGDetail.Discount__c/100)).setScale(0);
                
                //Update Value
                parentGTD.value = parentGTD.stdGDetail.Amount__c;    
            
            } else if(totalCount > 0){
                
                //Update Parent Amount
                parentGTD.stdGDetail.Count__c = totalCount;
                parentGTD.stdGDetail.Amount__c = null;
                parentGTD.stdGDetail.Percent__c = null;
                parentGTD.selectedValueType = 'Count';
                parentGTD.stdGDetail.Value_Type__c = 'Count';
                
                //Check for discount
                if(parentGTD.stdGDetail.Discount__c != null && parentGTD.stdGDetail.Discount__c > 0)
                    parentGTD.stdGDetail.Count__c -= (parentGTD.stdGDetail.Count__c * (parentGTD.stdGDetail.Discount__c/100)).setScale(0);
                
                //Update Value
                parentGTD.value = parentGTD.stdGDetail.Count__c;
            
            }  else if(totalPercent > 0){
                
                //Update Parent Amount
                parentGTD.stdGDetail.Percent__c = totalPercent;
                parentGTD.stdGDetail.Amount__c = null;
                parentGTD.stdGDetail.Count__c = null;
                parentGTD.selectedValueType = 'Percent';
                parentGTD.stdGDetail.Value_Type__c = 'Percent';
                
                //Check for discount
                if(parentGTD.stdGDetail.Discount__c != null && parentGTD.stdGDetail.Discount__c > 0)
                    parentGTD.stdGDetail.Percent__c -= (parentGTD.stdGDetail.Percent__c * (parentGTD.stdGDetail.Discount__c/100)).setScale(0);
                
                //Update Value
                parentGTD.value = parentGTD.stdGDetail.Percent__c;
            }
        }
        
        //Put parent GTD in map with updated values
        mapGTDWrapper.put(parentGTD.stdGDetail.Goal_Type__c + '-' + parentGTD.stdGDetail.Description__c + '-' + parentGTD.stdGDetail.Target_Type__c,
                          parentGTD); 
        
        //Check for Parent (SUMs To GTD)
        
        if(String.isNotBlank(parentGTD.selectedParent)){
            doCalculation(goalTemplateDetail(parentGTD.selectedParent)); 
        }
    }
    
    /**
     *  @description    :   Method is used to find out the Parent goal template details according to SUMs To value.
     *
     *  @args           :   String
     *  
     *  @return         :   StdGoalDetailSectionWrapper.StdGoalDetailWrapper
     *
     **/
    public StdGoalDetailSectionWrapper.StdGoalDetailWrapper goalTemplateDetail(String gTDUniqueKey) {
        
        
        //Loop through the goal template detail wrapper list to find out the goal template detail
        for(StdGoalDetailSectionWrapper.StdGoalDetailWrapper gTD : stdGDWrapper.stdGoalDetailsWrapper) {
            
            //Goal Template Detail identifier
            String gTDIdentifier = gTD.stdGDetail.Goal_Type__c + '-' + gTD.stdGDetail.Description__c + '-' + gTD.stdGDetail.Target_Type__c;
            
            //Check identfier with string
            if(gTDUniqueKey == gTDIdentifier)
                return gTD;
        }
        
        return null;
    }
    
    /**
     *  @description    :   This method is used to populate the pacing list
     *
     *  @args           :   String, StdGoalDetailSectionWrapper.StdGoalDetailWrapper
     *
     *  @return         :   void
     *
     **/
    public void populatePacingGTDs(String uniqueKey, StdGoalDetailSectionWrapper.StdGoalDetailWrapper gTDWrap) {
        
        //Loop through Standard Goal Detail Select Option
        for(Integer i = 0; i < stdGDPacingWrapper.avaliableStdGDetails.size(); i++) {
            
            //Check for values
            if(stdGDPacingWrapper.avaliableStdGDetails[i].getValue() == uniqueKey) {
                
                //Check for Target Type
                /*if(gTDWrap.stdGDetail.Target_Type__c == ISSPConstants.STANDARD_GOAL_DETAIL_TARGET_TYPE_PACED) {
                    
                    stdGDPacingWrapper.avaliableStdGDetails[i].setValue(gTDWrap.stdGDetail.Goal_Type__c + '-' + gTDWrap.stdGDetail.Description__c + '-' + gTDWrap.stdGDetail.Target_Type__c);
                    stdGDPacingWrapper.avaliableStdGDetails[i].setLabel(gTDWrap.stdGDetail.Description__c != null ? gTDWrap.stdGDetail.Description__c : '');
                    
                    //Check for selected std Goal Detail
                    if(stdGDPacingWrapper.selectedStdGDetail == uniqueKey) {
                        
                        stdGDPacingWrapper.selectedStdGDetail = gTDWrap.stdGDetail.Goal_Type__c + '-' + gTDWrap.stdGDetail.Description__c + '-' + gTDWrap.stdGDetail.Target_Type__c;
                        //stdGDPacingWrapper.stdGoalDetailTargetType = gTDWrap.stdGDetail.Target_Type__c;
                    }   
                } else {*/
                    
                    //Check for selected std Goal Detail
                    if(stdGDPacingWrapper.selectedStdGDetail == uniqueKey) {
                        
                        //Check for Avaliable Goal Template size
                        if(stdGDPacingWrapper.avaliableStdGDetails.size() == 1)
                            stdGDPacingWrapper.selectedStdGDetail = '';
                        else if(i > 0)      
                            stdGDPacingWrapper.selectedStdGDetail = stdGDPacingWrapper.avaliableStdGDetails[0].getValue();
                        else if(i == 0)
                            stdGDPacingWrapper.selectedStdGDetail = stdGDPacingWrapper.avaliableStdGDetails[1].getValue();
                    }
                    
                    //Remove Goal Template detail from list
                    stdGDPacingWrapper.avaliableStdGDetails.remove(i);
                    
                    //Check unique Key in the map
                    if(stdGDPacingWrapper.stdGDetailPacings.containsKey(uniqueKey)) {
                        
                        //Loop through the pacings wrapper
                        for(StdGoalDetailPacingSectionWrapper.StdGoalDetailPacing gTDP : stdGDPacingWrapper.stdGDetailPacings.get(uniqueKey)) {
                            
                            //Check for Id
                            if(gTDP.stdGDPacing.Id != null)
                                pacingsToBeDelete.add(gTDP.stdGDPacing);        
                        }
                        //Remove GTD from list
                        stdGDPacingWrapper.stdGDetailPacings.remove(uniqueKey);
                    }
                        
                    
                    //Check selected pacing in the map
                    if(stdGDPacingWrapper.stdGDetailPacings.containsKey(stdGDPacingWrapper.selectedStdGDetail))
                        stdGoalDPacings = stdGDPacingWrapper.stdGDetailPacings.get(stdGDPacingWrapper.selectedStdGDetail);
                    else
                        stdGoalDPacings = new List<StdGoalDetailPacingSectionWrapper.StdGoalDetailPacing>();
                /*}*/
                
                break;
            }
        }
    }
     
    
    /**
     *  @description    :   This method is used to add new Std Goal detail Pacing record according to selected period
     *
     *  @args           :   
     *
     *  @return         :   void
     *
     **/
    //V_1.5 - Modified - Rajeev Jain - 02/29/2016 - CR-20160125-9561 - ISSP Deployment D
    //Functionality is related to Pacing which no longer need
    /*public void addStdGDPacingsAccordingPeriod() {
        
        try {
            
            //Check for selected period
            if(String.isNotBlank(stdGDPacingWrapper.selectedPeriod) && String.isNotBlank(stdGDPacingWrapper.selectedStdGDetail)
                && stdGDPacingWrapper.stdGDetailPacings.containsKey(stdGDPacingWrapper.selectedStdGDetail)) {
                
                //List of Wrapper to hold pacings
                List<StdGoalDetailPacingSectionWrapper.StdGoalDetailPacing> stdGoalDetailPacings = new List<StdGoalDetailPacingSectionWrapper.StdGoalDetailPacing>();
                
                //Date variables to hold the start and end dats
                Date minStartDate;
                Date maxEndDate;
                
                //Check for selected Period in map
                if(stdGDPacingWrapper.mapIncentiveDefaults.containsKey(stdGDPacingWrapper.selectedPeriod)) {
                    
                    //Integer
                    Integer rowIndex = 1;
                    
                    //Loop through Incentive defaults custom setting
                    for(Incentive_Defaults__c iD : stdGDPacingWrapper.mapIncentiveDefaults.get(stdGDPacingWrapper.selectedPeriod)) {
                        
                        //Instance of Std Goal Detail Pacing
                        Standard_Goal_Detail_Pacing__c sGDPacing = new Standard_Goal_Detail_Pacing__c();
                        
                        //Populate field values
                        sGDPacing.Description__c = iD.Name;
                        sGDPacing.Period_Start__c = iD.Start__c;
                        sGDPacing.Period_End__c = iD.End__c;
                        sGDPacing.Percent_Manual__c = iD.Percent__c;
                        
                        //Populate Std Goal Detail Pacing in Wrapper
                        stdGoalDetailPacings.add(new StdGoalDetailPacingSectionWrapper.StdGoalDetailPacing(sGDPacing, rowIndex, stdGDPacingWrapper.stdGoalDetailTargetType,
                                                                                                           sGDPacing.Id == null ? false : true));
                        
                        rowIndex++;
                        
                        //Check for start and end dates
                        if(minStartDate == null || minStartDate > iD.Start__c)
                            minStartDate = iD.Start__c;
                        
                        if(maxEndDate == null || maxEndDate < iD.End__c)
                            maxEndDate = iD.End__c;
                    }
                }
                
                //Loop through the Existing pacings to add the pacings in the delete list
                for(StdGoalDetailPacingSectionWrapper.StdGoalDetailPacing pW : stdGoalDPacings) {
                    
                    //Check if pacing record exists in the database
                    if(pW.stdGDPacing.Id != null)
                        pacingsToBeDelete.add(pW.stdGDPacing);
                }
                
                //Override map
                stdGDPacingWrapper.stdGDetailPacings.put(stdGDPacingWrapper.selectedStdGDetail, stdGoalDetailPacings);
                stdGoalDPacings = stdGoalDetailPacings;
                
                //Update summary list
                if(mapStdGDSummary.containsKey(stdGDPacingWrapper.selectedStdGDetail)) {
                    
                    //Update Dates
                    mapStdGDSummary.get(stdGDPacingWrapper.selectedStdGDetail).startDate = minStartDate;
                    mapStdGDSummary.get(stdGDPacingWrapper.selectedStdGDetail).endDate = maxEndDate;
                    
                    //Add Std Summary list
                    stdGDSummary = mapStdGDSummary.values();
                    
                    //Sort
                    stdGDSummary.sort();
                }
                
                stdGDPacingWrapper.selectedPeriod = '';
            }
        }catch(Exception e) {
            //Add Error on page
            ApexPages.addMessages(e);
        }
    }*/
    //V_1.5 - Modified - Rajeev Jain - 02/29/2016 - CR-20160125-9561 - ISSP Deployment D - Upto here
    
    /**
     *  @description    :   Method is used to toggle pacings list according to selected std goal detail
     *
     *  @args           :   
     *
     *  @return         :   void
     *
     **/
    //V_1.5 - Modified - Rajeev Jain - 02/29/2016 - CR-20160125-9561 - ISSP Deployment D 
    //Functionality is related to Pacing which no longer need
    /*public void changeStdGDetail() {
        
        try {
            //Check for std Goal Detail Pacing
            if(String.isNotBlank(stdGDPacingWrapper.selectedStdGDetail)
                && stdGDPacingWrapper.stdGDetailPacings.containsKey(stdGDPacingWrapper.selectedStdGDetail)) {
                
                //Add in wrapper list
                stdGoalDPacings = stdGDPacingWrapper.stdGDetailPacings.get(stdGDPacingWrapper.selectedStdGDetail);
                
                //Change target type
                stdGDPacingWrapper.stdGoalDetailTargetType = mapTargetTypes.containsKey(stdGDPacingWrapper.selectedStdGDetail) ?
                                                             mapTargetTypes.get(stdGDPacingWrapper.selectedStdGDetail) : '';
            }
        }catch(Exception e) {
            //Add Error on page
            ApexPages.addMessages(e);
        }
    }*/
    //V_1.5 - Modified - Rajeev Jain - 02/29/2016 - CR-20160125-9561 - ISSP Deployment D - Upto here
    
    /**
     *  @description    :   This method is used to add new Std Goal detail Pacing record according to selected period
     *
     *  @args           :   
     *
     *  @return         :   void
     *
     **/
     //V_1.5 - Modified - Rajeev Jain - 02/29/2016 - CR-20160125-9561 - ISSP Deployment D - Upto here
    //Functionality is related to Pacing which no longer need
    /*public void addStdGDPacings() {
        
        try {
            
            //Check for Row index
            //This peace of code will work in case of edit case
            if(String.isNotBlank(stdGDPacingWrapper.selectedRowIndex)) {
                
                //Integer
                Integer roIndex = Integer.valueOf(stdGDPacingWrapper.selectedRowIndex);
                 
                StdGoalDetailPacingSectionWrapper.StdGoalDetailPacing temSGDPacing = stdGoalDPacings.get(roIndex -1);
                
                if(temSGDPacing != null){
                    
                    temSGDPacing.stdGDPacing = stdGDPacingWrapper.stdGDPacing;
                    temSGDPacing.selectedValueType = stdGDPacingWrapper.selectedValueType;
                    
                    stdGDPacingWrapper.stdGDPacing = new Standard_Goal_Detail_Pacing__c();
                    stdGDPacingWrapper.selectedValueType = 'Percent';
                    stdGDPacingWrapper.selectedRowIndex = '';
                }   
            }else {
                //Check for std Goal Detail Pacing
                if(stdGDPacingWrapper.stdGDPacing != null && String.isNotBlank(stdGDPacingWrapper.selectedStdGDetail)
                    && stdGDPacingWrapper.stdGDetailPacings.containsKey(stdGDPacingWrapper.selectedStdGDetail)) {
                    
                    //Add in wrapper list
                    stdGDPacingWrapper.stdGDetailPacings.get(stdGDPacingWrapper.selectedStdGDetail).add(new StdGoalDetailPacingSectionWrapper.StdGoalDetailPacing
                                                        (stdGDPacingWrapper.stdGDPacing, stdGDPacingWrapper.stdGDetailPacings.get(stdGDPacingWrapper.selectedStdGDetail).size() + 1,
                                                         stdGDPacingWrapper.stdGoalDetailTargetType, stdGDPacingWrapper.stdGDPacing.Id == null ? false : true));
                    
                    //Update Value type
                    stdGDPacingWrapper.stdGDetailPacings.get(stdGDPacingWrapper.selectedStdGDetail)[stdGDPacingWrapper.stdGDetailPacings.get(stdGDPacingWrapper.selectedStdGDetail).size() -1].selectedValueType = stdGDPacingWrapper.selectedValueType; 
                    stdGoalDPacings = stdGDPacingWrapper.stdGDetailPacings.get(stdGDPacingWrapper.selectedStdGDetail);
                    
                    stdGDPacingWrapper.stdGDPacing = new Standard_Goal_Detail_Pacing__c();
                    stdGDPacingWrapper.selectedValueType = ISSPConstants.STANDARD_GOAL_DETAIL_PACING_VALUE_TYPE_PERCENT;
                }
            }
            
            //Date variables
            Date minStartDate;
            Date maxEndDate;
            
            //Loop through Starandard Deatil Pacing
            for(StdGoalDetailPacingSectionWrapper.StdGoalDetailPacing stdDPacing : stdGoalDPacings) {
                
                //Check for Start Date
                if(minStartDate == null || minStartDate > stdDPacing.stdGDPacing.Period_Start__c)
                    minStartDate = stdDPacing.stdGDPacing.Period_Start__c;
                
                //Check for End date
                if(maxEndDate == null || maxEndDate < stdDPacing.stdGDPacing.Period_End__c)
                    maxEndDate = stdDPacing.stdGDPacing.Period_End__c;
            }
            
            //Update start and end date on Std Detail Summary Wrapper
            if(mapStdGDSummary.containsKey(stdGDPacingWrapper.selectedStdGDetail)) {
                
                mapStdGDSummary.get(stdGDPacingWrapper.selectedStdGDetail).startDate = minStartDate;
                mapStdGDSummary.get(stdGDPacingWrapper.selectedStdGDetail).endDate = maxEndDate;
                
                //Add Std Summary list
                stdGDSummary = mapStdGDSummary.values();
                
                //Sort
                stdGDSummary.sort();
            }
        }catch(Exception e) {
            //Add Error on page
            ApexPages.addMessages(e);
        }
    }*/
    //V_1.5 - Modified - Rajeev Jain - 02/29/2016 - CR-20160125-9561 - ISSP Deployment D - Upto here
    
    /**
     *  @description    :   This method is used to edit Std goal detail Pacings
     *
     *  @args           :   
     *
     *  @return         :   Pagereference
     *
     **/
     //V_1.5 - Modified - Rajeev Jain - 02/29/2016 - CR-20160125-9561 - ISSP Deployment D - Upto here
    //Functionality is related to Pacing which no longer need
    /*public Pagereference doEditstdGoalDetailPacings() {
        
        try {
            
            //Check for Selected Row Index
            if(String.isNotBlank(stdGDPacingWrapper.selectedRowIndex)) {
                
                //Convert String to Integer
                Integer rowIndex = Integer.valueOf(stdGDPacingWrapper.selectedRowIndex);
                
                //Get Sales Role Wrapper instance according to selected index 
                StdGoalDetailPacingSectionWrapper.StdGoalDetailPacing temSGDPacing = stdGoalDPacings.get(rowIndex -1);
                
                //Check for list and pacings
                if(temSGDPacing != null) {
                    
                    //Set Pacing
                    stdGDPacingWrapper.stdGDPacing = temSGDPacing.stdGDPacing;
                    stdGDPacingWrapper.selectedValueType = temSGDPacing.selectedValueType;
                }
            }
        }catch(Exception e) {
            //Add Error on page
            ApexPages.addMessages(e);
        }
        
        //Return
        return null;
    }*/
    //V_1.5 - Modified - Rajeev Jain - 02/29/2016 - CR-20160125-9561 - ISSP Deployment D - Upto here
    
    /**
     *  @description    :   This method is used to remove Std Goal detail Pacing record
     *
     *  @args           :   
     *
     *  @return         :   void
     *
     **/
    //V_1.5 - Modified - Rajeev Jain - 02/29/2016 - CR-20160125-9561 - ISSP Deployment D - Upto here
    //Functionality is related to Pacing which no longer need
    /*public void removeStdGDPacings() {
        
        try {
            //List of Wrapper to hold pacings
            List<StdGoalDetailPacingSectionWrapper.StdGoalDetailPacing> stdGoalDetailPacings = new List<StdGoalDetailPacingSectionWrapper.StdGoalDetailPacing>();
            
            //Integer
            Integer rowIndex = 1;
            
            //Check for std Goal Detail Pacing
            if(String.isNotBlank(stdGDPacingWrapper.selectedStdGDetail) && stdGDPacingWrapper.stdGDetailPacings.containsKey(stdGDPacingWrapper.selectedStdGDetail)) {
                
                //Loop through Wrapper list
                for(StdGoalDetailPacingSectionWrapper.StdGoalDetailPacing sGDP : stdGDPacingWrapper.stdGDetailPacings.get(stdGDPacingWrapper.selectedStdGDetail)) {
                    
                    //Check for selected checkbox
                    if(!sGDP.selected) {
                        
                        sGDP.rowNumber = rowIndex;
                        rowIndex += 1;
                        stdGoalDetailPacings.add(sGDP);
                    
                    //Code added to remove the pacing from the data. This only works in the Edit Template
                    } else if(sGDP.stdGDPacing.Id != null)
                        pacingsToBeDelete.add(sGDP.stdGDPacing);
                }
                
                //Add in wrapper list
                stdGDPacingWrapper.stdGDetailPacings.put(stdGDPacingWrapper.selectedStdGDetail,stdGoalDetailPacings);
                stdGoalDPacings = stdGoalDetailPacings;
            }
            
            //Date variables
            Date minStartDate;
            Date maxEndDate;
            
            //Loop through Starandard Deatil Pacing
            for(StdGoalDetailPacingSectionWrapper.StdGoalDetailPacing stdDPacing : stdGoalDPacings) {
                
                //Check for Start Date
                if(minStartDate == null || minStartDate > stdDPacing.stdGDPacing.Period_Start__c)
                    minStartDate = stdDPacing.stdGDPacing.Period_Start__c;
                
                //Check for End date
                if(maxEndDate == null || maxEndDate < stdDPacing.stdGDPacing.Period_End__c)
                    maxEndDate = stdDPacing.stdGDPacing.Period_End__c;
            }
            
            //Update start and end date on Std Detail Summary Wrapper
            if(mapStdGDSummary.containsKey(stdGDPacingWrapper.selectedStdGDetail)) {
                
                mapStdGDSummary.get(stdGDPacingWrapper.selectedStdGDetail).startDate = minStartDate;
                mapStdGDSummary.get(stdGDPacingWrapper.selectedStdGDetail).endDate = maxEndDate;
                
                //Add Std Summary list
                stdGDSummary = mapStdGDSummary.values();
                
                //Sort
                stdGDSummary.sort();
            }
        }catch(Exception e) {
            //Add Error on page
            ApexPages.addMessages(e);
        }
    }*/
        //V_1.5 - Modified - Rajeev Jain - 02/29/2016 - CR-20160125-9561 - ISSP Deployment D - Upto here

        
        //Added - Subhash Garhwal - CR-20151120-9407
        /**
     *  @description    :   This method is used to add GTDMP.
     *
     *  @args           :   
     *
     *  @return         :   void
     *
     **/
    public void addGTDMP() {
        
        try {
            
            //Check for GTD Index
            if(stdGDRowIndex != null) {
                
                if(gTDMPWrapper != null) {
                    
                    //Add new record in list
                    stdGDWrapper.stdGoalDetailsWrapper.get(stdGDRowIndex -1).gTDMPeriods.add(
                                  new StdGoalDetailSectionWrapper.GTDMPeriod(gTDMPWrapper.gTDMP, stdGDWrapper.stdGoalDetailsWrapper.get(stdGDRowIndex -1).gTDMPeriods.size() + 1));
                }
                
                //Call method
                setRowIndex(stdGDWrapper.stdGoalDetailsWrapper.get(stdGDRowIndex -1).gTDMPeriods);  
            }
            
            //Re-Initialize the GTDMP Wrapper
            gTDMPWrapper = new StdGoalDetailSectionWrapper.GTDMPeriod(new Goal_Template_Detail_Measurement_Period__c(), null);
            
        }catch(Exception e) {
        
            //Add Error on page
            ApexPages.addMessages(e);
        }
    }
    
    /**
     *  @description    :   This method is used to remove GTDMP
     *
     *  @args           :   
     *
     *  @return         :   void
     *
     **/
    public void removeGTDMP() {
        
        try {
            
            //Check for GTD index
            if(stdGDRowIndex != null) {
                    
                //Temp list of GTDMP wrapper
                List<StdGoalDetailSectionWrapper.GTDMPeriod> tempGTDMPs = new List<StdGoalDetailSectionWrapper.GTDMPeriod>();
                
                //Integer
                Integer rowIndex = 1;
                
                //Loop through conditions
                for(StdGoalDetailSectionWrapper.GTDMPeriod gTDMP : gTDMPeriods) {
                    
                    //Check for selected check box
                    if(!gTDMP.selected) {
                        
                        //Update Condition Index
                        gTDMP.rowNumber = rowIndex;
                        rowIndex += 1;
                        tempGTDMPs.add(gTDMP);
                    
                    //Code added to delete the GTDMP from the database in case of edit Goal Template
                    } else if(gTDMP.gTDMP.Id != null)
                      gTDMPToBeDelete.add(gTDMP.gTDMP);
                }
                
                //Assign values in list
                gTDMPeriods = tempGTDMPs;
                stdGDWrapper.stdGoalDetailsWrapper.get(stdGDRowIndex -1).gTDMPeriods = gTDMPeriods;
            }
       }catch(Exception e) {
            //Add Error on page
            ApexPages.addMessages(e);
        } 
    }
    
    /**
     *  @description    :   Method to populate the GTDMPs
     *
     *  @args           :   
     *
     *  @return         :   void
     *
     **/
    public void populateGTDMPs() {
        
        //Check for Row index
        if(stdGDRowIndex != null) {
            
            //Get goal template detail's GTDMP 
            gTDMPeriods = stdGDWrapper.stdGoalDetailsWrapper.get(stdGDRowIndex -1).gTDMPeriods;
        }
    }
    
    /**
     *  @description    :   This method is used to set the Integer number according to shorted GTDMP list
     *
     *  @args           :   
     *
     *  @return         :   void
     *
     **/
    public void setRowIndex(List<StdGoalDetailSectionWrapper.GTDMPeriod> gTDMPsWrapper) {
        
        //Short the list
        gTDMPsWrapper.sort();
        
        //Variable to hold the Integer
        Integer rowIndex = 1;
        
        //Loop through GTDMP wrapper
        for(StdGoalDetailSectionWrapper.GTDMPeriod gTDMPW : gTDMPsWrapper) {
            
            //Set Row Index
            gTDMPW.rowNumber = rowIndex;
            
            rowIndex++;
        }
        
        //Add GTD in the GTDMP list
        gTDMPeriods = gTDMPsWrapper;
        
    }
    
    /**
     *  @description    :   Method to populate the std goal detail conditions
     *
     *  @args           :   
     *
     *  @return         :   void
     *
     **/
    public void stdGDetailCondtions() {
        
        //Check for Row index
        if(stdGDRowIndex != null) {
            
            //Get goal template detail's conditions 
            stdGoalDetailConditions = stdGDWrapper.stdGoalDetailsWrapper.get(stdGDRowIndex -1).stdGoalDetailConditions;
        }
    } 
    
    /**
     *  @description    :   This method is call from cancel buttons.
     *
     *  @args           :   
     *
     *  @return         :   void
     *
     **/
    public void doCancel() {
        
        //Set values to blank
        stdGSWrapper.selectedRType = '';
        stdGSWrapper.condition = new Condition__c(Condition_Type__c = 'Include');
        
        //V_1.6 - Modified - Rajeev Jain - 04/05/2016 - CR-20160304-9674 - ISSP Deployment E
        //Reset Default Value
        stdGSWrapper.condition.Condition_Set__c = ISSPConstants.DEFAULT_VALUE_CONDITION_SET;
        //V_1.6 - Modified - Rajeev Jain - 04/05/2016 - CR-20160304-9674 - ISSP Deployment E
        
        stdGSWrapper.stdGSR = new Standard_Goal_Sales_Role__c();
        
        //V_1.5 - Modified - Rajeev Jain - 02/29/2016 - CR-20160125-9561 - ISSP Deployment D - Replace Paced with Explicit in if part
        //Check for Personal Goal
        //Change the Default Goal Template Detail's Target type
        if(stdGoal.Standard_Type__c == ISSPConstants.STANDARD_GOAL_STANDARD_TYPE_GROUP)
            stdGDWrapper.stdGD = new Standard_Goal_Detail__c(Target_Type__c = ISSPConstants.STANDARD_GOAL_DETAIL_TARGET_TYPE_EXPLICIT, Baseline_Percentage__c = 100, Weighting__c = 0,
                                                             Condition_Handling__c = 'Conditions OR Ownership');
        else
            stdGDWrapper.stdGD = new Standard_Goal_Detail__c(Target_Type__c = ISSPConstants.STANDARD_GOAL_DETAIL_TARGET_TYPE_EXPLICIT, Baseline_Percentage__c = null, Weighting__c = 0,
                                                             Condition_Handling__c = 'Conditions OR Ownership');
        stdGDPacingWrapper.stdGDPacing = new Standard_Goal_Detail_Pacing__c();
        stdGSWrapper.selectedConditionRowIndex = '';
        stdGSWrapper.selectedSalesRoleRowIndex = '';
        stdGDWrapper.selectedSGDRowIndex = '';
        stdGDPacingWrapper.selectedRowIndex = '';
        gTDMPWrapper = new StdGoalDetailSectionWrapper.GTDMPeriod(new Goal_Template_Detail_Measurement_Period__c(), null);
        
        //Call method
        populateBaselineAndParents();
    }
    
    /**
     *  @description    :   This method is used to save the data
     *
     *  @args           :
     *
     *  @return         :   Pagereference
     *
     **/
    public Pagereference doSave() {
        
        //Save Point to roll back changes
        Savepoint sp = Database.setSavepoint();
        
        try {
            
             //Decimal to Check Maximum condition Set on Goal Template level
            Decimal maxGTConditionSet = 0;
            
             //Decimal to Identify Maximum Condition Set Number
            Decimal maxGTDCondSet = 0;
                    
            //Delete the record from the database
            
            //Check for GTD list
            if(stdGoalDetailsToBeDelete.size() > 0) {
                
                //Query through the Consitions
                List<Condition__c> gTDConditions = [Select Id From Condition__c Where Standard_Goal_Detail__c IN : stdGoalDetailsToBeDelete AND
                                                                                      Id NOT IN : conditionsToBeDelete];
                
                //Add Conditions in list
                conditionsToBeDelete.addAll(gTDConditions); 
            }
            
            //Delete Conditions
            if(conditionsToBeDelete.size() > 0)
                delete conditionsToBeDelete;
            
            //Delete GTBT
            if(busnessTitlesToBeDelete.size() > 0)
                delete busnessTitlesToBeDelete;
            
            //Delete Pacings
            if(pacingsToBeDelete.size() > 0)
                delete pacingsToBeDelete;
            
            //Delete GTDs
            if(stdGoalDetailsToBeDelete.size() > 0)
                delete stdGoalDetailsToBeDelete;
            
            //Delete GTDMPs
            if(gTDMPToBeDelete.size() > 0)
                delete gTDMPToBeDelete;
                
            //Boolean to check data
            Boolean isValuePopulated = false;
            
            //Check for Payee if goal template type is Personal
            if(stdGoal.Standard_Type__c == ISSPConstants.STANDARD_GOAL_STANDARD_TYPE_PERSONAL && stdGoal.Payee__c == null)
                throw new CustomException(Label.DEFINE_GT_SELECT_PAYEE);
             
            stdGoal.Value_Type__c = stdGSWrapper.selectedSGValueType;
                    
            //Insert Standard Goal
            upsert stdGoal;
            
            //List of Conditions
            List<Condition__c> conditions = new List<Condition__c>();
            
            //Loop through condition wrapper
            for(StdGoalSectionWrapper.ConditionWrapper cW : stdGSWrapper.conditionsWrapper) {
                
                //Populate condition data
                cW.con.Standard_Goal__c = stdGoal.Id;
                 
                //Add Condtion in list
                conditions.add(cW.con);
                
                //Check the checkbox
                isValuePopulated = true;
                
                If(cW.con.Condition_Set__c > maxGTConditionSet)
                    maxGTConditionSet = cW.con.Condition_Set__c;
            }
            
            //Check for Standard Type
            if(stdGoal.Standard_Type__c == ISSPConstants.STANDARD_GOAL_STANDARD_TYPE_GROUP) {
            
                //List of Sales Role
                List<Standard_Goal_Sales_Role__c> salesRoles = new List<Standard_Goal_Sales_Role__c>();
                
                //Loop through Sales Role
                for(StdGoalSectionWrapper.SalesRoleWrapper sRW : stdGSWrapper.stdGSRs) {
                    
                    //Populate the Goal Template on the GTBT
                    if(!sRW.isExisting)
                        sRW.stdGSR.Standard_Goal__c = stdGoal.Id;
                        
                    //Add Sales Role in list
                    salesRoles.add(sRW.stdGSR); 
                }
                
                //Deep Clone sales Role
                List<Standard_Goal_Sales_Role__c> tempSalesRoles = salesRoles.deepClone(true,true);
                
                //Check for sales role size
                if(tempSalesRoles.size() > 0) {
                    
                    //Insert sales role
                    upsert tempSalesRoles;
                    
                    //Check the checkbox
                    isValuePopulated = true;
                }
            } else
                isValuePopulated = true;
            
            //Map to hold Standard Goal Details with unique key (Goal Type Id + description)
            Map<String, Standard_Goal_Detail__c> mapStandardGoalDetails = new Map<String, Standard_Goal_Detail__c>();
            
            //Loop through Standard Goal details
            for(StdGoalDetailSectionWrapper.StdGoalDetailWrapper sGDW : stdGDWrapper.stdGoalDetailsWrapper) {
                
                //Check for Target Type
                if(String.isNotBlank(sGDW.stdGDetail.Target_Type__c) && sGDW.selectedBaseLine == ISSPConstants.TEMPLATE_BASELINE
                    && stdGoal.Amount__c == null && stdGoal.Counter__c == null && stdGoal.Percent__c == null)
                    //Add Error on page
                    throw new CustomException(Label.GT_PLEASE_PROVIDE_VALUE);
                    
                //Add Std goal on Std Goal detail
                if(!sGDW.isExisting)
                    sGDW.stdGDetail.Standard_Goal__c = stdGoal.Id;
                
                //Update Baseline
                sGDW.stdGDetail.GT_Basline__c = sGDW.selectedBaseLine;
                
                //Check for baseline and Parent
                if(String.isBlank(sGDW.selectedBaseLine))
                    sGDW.stdGDetail.Baseline__c = null;
                
                //Check for Parent
                if(String.isBlank(sGDW.selectedParent))
                    sGDW.stdGDetail.Parent__c = null;   
                
                //Check for goal Type
                if(sGDW.stdGDetail.Goal_Type__c != null) {
                         
                    //Populate map
                    mapStandardGoalDetails.put(sGDW.stdGDetail.Goal_Type__c + '-' + sGDW.stdGDetail.Description__c
                                                + '-' + sGDW.stdGDetail.Target_Type__c,sGDW.stdGDetail);
                }   
            }
            
            //Temp Map to hold Standard Goal Details with Goal Type Id
            Map<String, Standard_Goal_Detail__c> tempMapStandardGoalDetails = mapStandardGoalDetails.deepClone();
            
            //Insert 
            if(tempMapStandardGoalDetails.size() > 0) {
                
                //Insert
                upsert tempMapStandardGoalDetails.values();
                
                //Check the checkbox
                isValuePopulated = true;
                
                //List to update the std goal detail with baseline
                List<Standard_Goal_Detail__c> stdGoalDetails = new List<Standard_Goal_Detail__c>();
                
                //Set to hold the parent goal template Ids
                Set<Id> setPGTDIds = new Set<Id>();
                
                //List of Std Goal Detail Pacing
                List<Standard_Goal_Detail_Pacing__c> stdGoalDetailPacings = new List<Standard_Goal_Detail_Pacing__c>();
                
                //List of GTDMP to insert
                List<Goal_Template_Detail_Measurement_Period__c> gTDMeasurementPeriods = new List<Goal_Template_Detail_Measurement_Period__c>();
                
                //Loop through Standard Goal details
                for(StdGoalDetailSectionWrapper.StdGoalDetailWrapper sGDW : stdGDWrapper.stdGoalDetailsWrapper) {
                    
                    //Check for Baseline and Parent
                    if((String.isNotBlank(sGDW.selectedBaseLine) || String.isNotBlank(sGDW.selectedParent))
                        && tempMapStandardGoalDetails.containsKey(sGDW.stdGDetail.Goal_Type__c + '-' + sGDW.stdGDetail.Description__c + '-' + sGDW.stdGDetail.Target_Type__c)) {
                        
                        //Std goal detail
                        Standard_Goal_Detail__c stdGoalDetail = tempMapStandardGoalDetails.get(sGDW.stdGDetail.Goal_Type__c + '-' + sGDW.stdGDetail.Description__c + '-' + sGDW.stdGDetail.Target_Type__c);
                        
                        //Check for selected baseline
                        if(String.isNotBlank(sGDW.selectedBaseLine) && tempMapStandardGoalDetails.containsKey(sGDW.selectedBaseLine)) {
                            
                            //Update baseline
                            stdGoalDetail.BaseLine__c = tempMapStandardGoalDetails.get(sGDW.selectedBaseLine).Id;
                        
                        }
                        
                        //Check for selected Parent
                        if(String.isNotBlank(sGDW.selectedParent) && tempMapStandardGoalDetails.containsKey(sGDW.selectedParent)) {
                            
                            //Update Parent Goal template detail
                            stdGoalDetail.Parent__c = tempMapStandardGoalDetails.get(sGDW.selectedParent).Id;
                            
                            //Check if set contains the parent goal template detail
                            /*if(!setPGTDIds.contains(tempMapStandardGoalDetails.get(sGDW.selectedParent).Id)) {
                                
                                //Add in list
                                stdGoalDetails.add(new Standard_Goal_Detail__c(Id = tempMapStandardGoalDetails.get(sGDW.selectedParent).Id, Summary__c = true));
                                
                                //Add Parent Id in set
                                setPGTDIds.add(tempMapStandardGoalDetails.get(sGDW.selectedParent).Id);
                            }*/
                        }
                        
                        //Add in list
                        stdGoalDetails.add(stdGoalDetail); 
                    }
                     
                    //Check for Target Type
                    if(sGDW.stdGDetail.Target_Type__c == ISSPConstants.STANDARD_GOAL_DETAIL_TARGET_TYPE_EXPLICIT) {
                        
                        //Check for GTD in map
                        if(tempMapStandardGoalDetails.containsKey(sGDW.stdGDetail.Goal_Type__c + '-' + sGDW.stdGDetail.Description__c + '-' + sGDW.stdGDetail.Target_Type__c)) {
                            
                            //Instance of Goal Template Detail Pacing
                            Standard_Goal_Detail_Pacing__c gTDPacing = new Standard_Goal_Detail_Pacing__c();
                            
                            //Check SGD Id in map
                            if(mapExplicitPacings.containsKey(sGDW.stdGDetail.Id))
                                gTDPacing = mapExplicitPacings.get(sGDW.stdGDetail.Id);
                            else
                                gTDPacing.Standard_Goal_Detail__c = tempMapStandardGoalDetails.get(sGDW.stdGDetail.Goal_Type__c + '-' + sGDW.stdGDetail.Description__c + '-' + sGDW.stdGDetail.Target_Type__c).Id; 
                                
                            //Populate field values
                            gTDPacing.Standard_Goal__c = stdGoal.Id;
                            gTDPacing.Description__c = sGDW.stdGDetail.Period__c;
                            gTDPacing.Period_Start__c = sGDW.stdGDetail.Period_Start__c;
                            gTDPacing.Period_End__c = sGDW.stdGDetail.Period_End__c;
                            gTDPacing.Percent_Manual__c = 100;
                            
                            //Add Pacing record in list to upsert
                            stdGoalDetailPacings.add(gTDPacing);
                        }
                    }
                    
                    //Loop through the std goal detail condtions
                    for(StdGoalDetailSectionWrapper.StdGoalDetailConditions sGDCon : sGDW.stdGoalDetailConditions) {
                        
                        //Populate condition data
                        sGDCon.con.Standard_Goal__c = stdGoal.Id;
                        sGDCon.con.Standard_Goal_Detail__c = tempMapStandardGoalDetails.get(sGDW.stdGDetail.Goal_Type__c + '-' + sGDW.stdGDetail.Description__c + '-' + sGDW.stdGDetail.Target_Type__c).Id;
                        
                        //Add Condtion in list
                        conditions.add(sGDCon.con);
                        
                        if(sGDCon.con.Condition_Set__c > maxGTDCondSet)
                            maxGTDCondSet = sGDCon.con.Condition_Set__c;    
                    }
                    
                    //Loop through the GTDMP list gTDMeasurementPeriods
                    for(StdGoalDetailSectionWrapper.GTDMPeriod gTDMPW : sGDW.gTDMPeriods) {
                        
                        //Update GTD Id
                        if(gTDMPW.gTDMP.Id == null)
                            gTDMPW.gTDMP.Goal_Template_Detail__c = tempMapStandardGoalDetails.get(sGDW.stdGDetail.Goal_Type__c + '-' + sGDW.stdGDetail.Description__c + '-' + sGDW.stdGDetail.Target_Type__c).Id;
                        
                        //Add GTDMP in list
                        gTDMeasurementPeriods.add(gTDMPW.gTDMP);
                    }
                }
                
                //Check for list size
                if(gTDMeasurementPeriods.size() > 0) {
                    
                    //Clone the GTDMP
                    List<Goal_Template_Detail_Measurement_Period__c> clonedGTDMPs = gTDMeasurementPeriods.deepClone(true,true);
                    
                    //Upsert
                    upsert clonedGTDMPs;
                }
                
                //List of Goal Template Details
                List<Standard_Goal_Detail__c> gTDetails = stdGoalDetails.deepClone(true,true);
                
                //Check for size
                if(stdGoalDetails.size() > 0)
                    update gTDetails;
                
                //Map to hold the Std Goal Id with Pacing Percentage
                Map<Id, Decimal> mapstdGDWithPacings = new Map<Id, Decimal>();
                
                //Loop through goaltypes map
                for(String gTId : mapGoalTypes.keySet()) {
                    
                    //Check if map contains Goal Type Id
                    if(tempMapStandardGoalDetails.containsKey(gTId) && stdGDPacingWrapper.stdGDetailPacings.containsKey(gTId)) {
                        
                        //Id to hold Standard Goal detail Id
                        Id stdGDId = tempMapStandardGoalDetails.get(gTId).Id;
                        
                        //Loop through Pacing Map
                        for(StdGoalDetailPacingSectionWrapper.StdGoalDetailPacing sgDPW : stdGDPacingWrapper.stdGDetailPacings.get(gTId)) {
                            
                            //Populate Std Goal detail and Std Goal
                            if(!sgDPW.isExisting)
                                sgDPW.stdGDPacing.Standard_Goal_Detail__c = stdGDId;
                            sgDPW.stdGDPacing.Standard_Goal__c = stdGoal.Id;
                            
                            //Check if map contains Std Goal detail Id
                            if(sgDPW.stdGoalDetailTargetType == ISSPConstants.STANDARD_GOAL_DETAIL_TARGET_TYPE_PACED && !mapstdGDWithPacings.containsKey(stdGDId))
                                mapstdGDWithPacings.put(stdGDId, 0);
                            
                            //Add Percent in map
                            if(sgDPW.stdGoalDetailTargetType == ISSPConstants.STANDARD_GOAL_DETAIL_TARGET_TYPE_PACED && sgDPW.stdGDPacing.Percent_Manual__c != null)
                                mapstdGDWithPacings.put(stdGDId, mapstdGDWithPacings.get(stdGDId) + sgDPW.stdGDPacing.Percent_Manual__c);
                            
                            //Add Pacing in list
                            stdGoalDetailPacings.add(sgDPW.stdGDPacing); 
                        }   
                    }
                }
                
                //Loop through Map
                for(Id sgdId : mapstdGDWithPacings.keySet()) {
                    
                    //Check for Pacing Percent
                    if(mapstdGDWithPacings.get(sgdId) > 100 || mapstdGDWithPacings.get(sgdId) < 100)
                        throw new CustomException(Label.GTDP_PERCENTAGE);
                     
                }
                
                //List of Std Goal Detail Pacing
                List<Standard_Goal_Detail_Pacing__c> tempStdGoalDetailPacings = stdGoalDetailPacings.deepClone(true,true);
                
                //Check for size
                if(tempStdGoalDetailPacings.size() > 0) {
                    //Insert
                    upsert tempStdGoalDetailPacings;
                    
                    //Check the checkbox
                    isValuePopulated = true;
                }
            }
            
            //V_1.6 - Added By - Rajeev Jain - 05/03/2016
            //Check if condition size is Greate then zero and Maximum Condition Set does not exceed then hierarchial limit
            Decimal maxPgConditionLevel = (maxGTDCondSet*maxGTConditionSet);
            
            //Check the size of conditions
            if(conditions.size() > 0){
                
                if(String.isNotBlank(Label.DEFINE_GT_CONDITION_SET_LIMIT) && maxPgConditionLevel <= Decimal.valueOf(Label.DEFINE_GT_CONDITION_SET_LIMIT)){
                    
                    //Cone the Conditions to insert
                    List<Condition__c> tempConditions = conditions.deepClone(true,true);
                    
                    //Insert Condition
                    upsert tempConditions;
                     
                    //Check the checkbox
                    isValuePopulated = true;
                }else
                    throw new CustomException(Label.DEFINE_GT_CONDITION_SET_LIMIT_EXCEED_ERROR);
            }
            //V_1.6 - Added By - Rajeev Jain - 05/03/2016 - upto here
            
            //Date fields
            Date minStartDate;
            Date maxEndDate;
            
            //Loop through the Summary 
            for(StdGoalDetailSummaryWrapper sW : stdGDSummary) {
                
                //Check for Start and End Date
                if(sW.startDate == null) {
                    
                    //Check flag to false
                    isValuePopulated = false;
                    
                    break;
                }
                
                //Fill Start Date
                if(minStartDate == null || minStartDate > sW.startDate)
                    minStartDate = sW.startDate;
                
                //Fill End Date
                if(maxEndDate == null || maxEndDate < sW.endDate)
                    maxEndDate = sW.endDate;
                
            }
            
            if(!isValuePopulated)
                throw new CustomException(Label.DEFINE_GT_AT_LEAST_ONE_CHILD);
            
            //List of STDGD which needs to update in case of no child record found
            List<Standard_Goal_Detail__c> gtdsNeedsToBeUpdate = new List<Standard_Goal_Detail__c>();
            
            //Restructure Data if any Summary type GTD is found but it is not populated as summarry on the other GTD then reset there Summary field to false
            for(Standard_Goal_Detail__c summarryGTD : [select Id, Name, (select Id, Name, Summary__c from Goal_Template_Details__r LIMIT 1) from Standard_Goal_Detail__c where Standard_Goal__c  = :stdGoal.Id AND Summary__c = true]){
                
                if(summarryGTD.Goal_Template_Details__r.size() == 0){
                    summarryGTD.Summary__c = false;
                    gtdsNeedsToBeUpdate.add(summarryGTD);
                }
            } 
            
            //Update
            update gtdsNeedsToBeUpdate;
            
            //Return
            return new Pagereference('/' +stdGoal.Id);
            
        } catch(DMLException dmlExp) {
            
            //Roll Back changes
            Database.rollback(sp);
            
            //Check for edit case
            if(!isExisting)
                stdGoal.Id = null;
            
            //Add Error on page
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,dmlExp.getDmlMessage(0)));
            return null;
            
        }catch(Exception e) {
            
            //Roll Back changes
            Database.rollback(sp);
            
            //Check for edit case
            if(!isExisting)
                stdGoal.Id = null;
            
            //Add Error on page
            ApexPages.addMessages(e);
            return null;
        }
        
        return null;
    }
    
    /**
     *  @description    :   Save and Create Personal Goal method
     *
     *  @args           :   
     *
     *  @return         :   
     *
     **/
    public Pagereference doSaveAndCPGS() {
        
        try {
            
            //Call Do save method
            Pagereference savePage = doSave();
            
            //Return
            if(savePage == null)
                return null;
            else
                return new Pagereference('/apex/CreatePersonalGoalsFromStdGoal?id=' +stdGoal.Id);
                 
        } catch(Exception e) {
            
            //Add Error on page
            ApexPages.addMessages(e);
            return null;
        }
    }
    
    /**
     *  @Description    :   This method is used to display Label of select option
     *
     *  @args           :   List<SelectOption>, String
     *
     *  @return         :   String
     *
     **/
    public String selectedOption(List<SelectOption> options, String selectedValue) {
        
        //Loop through options
        for(SelectOption sO : options) {
            
            //Check for value
            if(sO.getValue() == selectedValue)
                return sO.getLabel();
        }
        
        return null;
    }
    
    //Method only used for mantained data on page
    public void reRender() {}
    
    /**
     *  @description    :   This method is used to prepare the goal template detail's available list for pacings
     *
     *  @args           :   StdGoalDetailPacingSectionWrapper, String   
     *
     *  @return         :   void
     *
     **/
    public void prepareGTDList(StdGoalDetailPacingSectionWrapper pacingWrapperInstance, String gTId, Standard_Goal_Detail__c sGD) {
        
        //Check for Avaliable options size
        if(pacingWrapperInstance.avaliableStdGDetails.size() == 0) {
            
            //Set detail
            pacingWrapperInstance.selectedStdGDetail = gTId + '-' + sGD.Description__c + '-' + sGD.Target_Type__c;
        }
            
        //Add newly added std goal detail in avaliable options list
        pacingWrapperInstance.avaliableStdGDetails.add(new SelectOption(gTId + '-' + sGD.Description__c + '-'
                                                                     + sGD.Target_Type__c,sGD.Description__c != null ? sGD.Description__c : ''));
        
        //Add empty pacings list to the newly added std goal detail 
        if(!pacingWrapperInstance.stdGDetailPacings.containsKey(gTId + '-' + sGD.Description__c + '-' + sGD.Target_Type__c))
            pacingWrapperInstance.stdGDetailPacings.put(gTId + '-' + sGD.Description__c + '-'
                                                     + sGD.Target_Type__c, new List<StdGoalDetailPacingSectionWrapper.StdGoalDetailPacing>());
        
        //Update current Pacings list according to selected std goal detail
        stdGoalDPacings = pacingWrapperInstance.stdGDetailPacings.get(stdGDPacingWrapper.selectedStdGDetail);
    }
    
    /**
     *  @description    :   This method is used to populate the available baselines and available Parents for new goal template details
     *
     *  @args           :   
     *
     *  @return         :   void
     *
     **/
    public void populateBaselineAndParents() {
        
        //Options for baseline
        List<SelectOption> baselines = new List<SelectOption>();
        
        //Add default option
        baselines.add(new SelectOption('','--NONE--'));
        baselines.add(new SelectOption('Template','Template'));
        
        //Options for baseline
        List<SelectOption> parents = new List<SelectOption>();
        
        //Add default option
        parents.add(new SelectOption('','--NONE--'));
        
        //Loop through the Std Goal Detail wrapper
        for(StdGoalDetailSectionWrapper.StdGoalDetailWrapper sGDW : stdGDWrapper.stdGoalDetailsWrapper) {
            
            //Add existing std goal details in the newly added std goal detail's available baselines
            baselines.add(new SelectOption(sGDW.stdGDetail.Goal_Type__c + '-' + sGDW.stdGDetail.Description__c + '-' + sGDW.stdGDetail.Target_Type__c,
                                                sGDW.stdGDetail.Description__c != null ? sGDW.stdGDetail.Description__c : ''));
            
            //Add existing Goal Template details in the newly added std goal detail's available parents
            //Updated By - Rajeev Jain - 1/21/2016 - Now in every new case every GTD will be available for selection as SUMsto.
            /*if(String.isBlank(sGDW.selectedParent))*/
                parents.add(new SelectOption(sGDW.stdGDetail.Goal_Type__c + '-' + sGDW.stdGDetail.Description__c + '-' + sGDW.stdGDetail.Target_Type__c,
                                                sGDW.stdGDetail.Description__c != null ? sGDW.stdGDetail.Description__c : '')); 
            //Updated By - Rajeev Jain - 1/21/2016 - Now in every new case every GTD will be available for selection as SUMsto. - Upto here
        }
        
        //V_1.5 - Modified - Rajeev Jain - 02/29/2016 - CR-20160125-9561 - ISSP Deployment D - Replace Paced with Explicit in if part
        //Change the Default Goal Template Detail's Target type
        if(stdGoal.Standard_Type__c == ISSPConstants.STANDARD_GOAL_STANDARD_TYPE_GROUP)
            stdGDWrapper.stdGD = new Standard_Goal_Detail__c(Target_Type__c = ISSPConstants.STANDARD_GOAL_DETAIL_TARGET_TYPE_EXPLICIT, Baseline_Percentage__c = 100, Discount__c = null, Weighting__c = 0,
                                                             Condition_Handling__c = 'Conditions OR Ownership');
        else
            stdGDWrapper.stdGD = new Standard_Goal_Detail__c(Target_Type__c = ISSPConstants.STANDARD_GOAL_DETAIL_TARGET_TYPE_EXPLICIT, Baseline_Percentage__c = null, Discount__c = null, Weighting__c = 0,
                                                             Condition_Handling__c = 'Conditions OR Ownership');
        
        //Set Baseline
        stdGDWrapper.availableBaseLines = baselines;
        stdGDWrapper.selectedBaseLine = ISSPConstants.TEMPLATE_BASELINE;
        stdGDWrapper.stdGDetailsWrapper.availableParents = parents;
        stdGDWrapper.stdGDetailsWrapper.selectedParent = '';
        //stdGDWrapper.stdGDetailsWrapper.selectedValueType = 'Amount';
    }
    
    /**
     *  @description    :   This method is used to populate the goal template details list with new goal template details
     *
     *  @args           :   String, String, Standard_Goal_Detail__c, StdGoalDetailSectionWrapper.StdGoalDetailWrapper
     *
     *  @return         :   void    
     *
     **/
    public void prepareGoalTemplateDetails(String goalTypeId, String goalTypeName, Standard_Goal_Detail__c stdGD, String baseline, String parentGTD) {
        
        //Populate Target Type map
        mapTargetTypes.put(goalTypeId + '-' + stdGD.Description__c + '-' + stdGD.Target_Type__c, stdGD.Target_Type__c);
        
        //Select Option to display Baseline drop-down on the goal template detail
        List<SelectOption> availableBaseLines = new List<SelectOption>();
    
        //Add Standard Baseline
        availableBaseLines.add(new SelectOption('', '--NONE--'));
        availableBaseLines.add(new SelectOption('Template', 'Template'));
        
        //Select Option to display Parent drop-down on the Goal Template Details
        List<SelectOption> availableParents = new List<SelectOption>();
    
        //Add Standard Baseline
        availableParents.add(new SelectOption('', '--NONE--'));
        
        //Loop through the already added std goal details
        for(StdGoalDetailSectionWrapper.StdGoalDetailWrapper sGDW : stdGDWrapper.stdGoalDetailsWrapper) {
            
            //Add new baseline to each existing std goal detail
            sGDW.avaliableBaseLine.add(new SelectOption(goalTypeId + '-' + stdGD.Description__c + '-' + stdGD.Target_Type__c,
                                                        stdGD.Description__c != null ? stdGD.Description__c : ''));
            
            //Add existing std goal details in the newly added std goal detail's available baselines
            availableBaseLines.add(new SelectOption(sGDW.stdGDetail.Goal_Type__c + '-' + sGDW.stdGDetail.Description__c + '-'
                                                        + sGDW.stdGDetail.Target_Type__c, sGDW.stdGDetail.Description__c != null ? sGDW.stdGDetail.Description__c : ''));
        }
       
        //Loop through the already added goal template details
        for(StdGoalDetailSectionWrapper.StdGoalDetailWrapper sGDW : stdGDWrapper.stdGoalDetailsWrapper) {
            
            //Check for parent
            //Commnet By Rajeev -  If new which is going to add is having blank SUMSTo that means this is available as parent to evry GTD in the list
            //No need to populate here, we will populate available list when user will click on Edit
            /*if(String.isBlank(parentGTD))
                //Add new baseline to each existing std goal detail
                sGDW.availableParents.add(new SelectOption(goalTypeId + '-' + stdGD.Description__c + '-'
                                                            + stdGD.Target_Type__c, stdGD.Description__c != null ? stdGD.Description__c : ''));*/
            
            //Check for existing Goal Template detail's Parent
            //Comment By Rajeev - If Every existing is not stamped as SUMS to or not having Parent that means, it is also available as Parent for newly added
            /*if(String.isBlank(sGDW.selectedParent))*/
            //Add existing std goal details in the newly added std goal detail's available baselines
            availableParents.add(new SelectOption(sGDW.stdGDetail.Goal_Type__c + '-' + sGDW.stdGDetail.Description__c + '-'
                                                  + sGDW.stdGDetail.Target_Type__c, sGDW.stdGDetail.Description__c != null ? sGDW.stdGDetail.Description__c : ''));
        }
        
        //Check for Target Type
        if(stdGD.Target_Type__c == ISSPConstants.STANDARD_GOAL_DETAIL_TARGET_TYPE_PACED)
            //Call method to prepare the goal template detail's list for pacings
            prepareGTDList(stdGDPacingWrapper, goalTypeId, stdGD);
        
        //Populate map
        mapStdGDSummary.put(goalTypeId + '-' + stdGD.Description__c + '-' + stdGD.Target_Type__c,
                            new StdGoalDetailSummaryWrapper(stdGD.Description__c,
                                stdGD.Target_Type__c == ISSPConstants.STANDARD_GOAL_DETAIL_TARGET_TYPE_EXPLICIT ? stdGD.Period_Start__c : null,
                                stdGD.Target_Type__c == ISSPConstants.STANDARD_GOAL_DETAIL_TARGET_TYPE_EXPLICIT ? stdGD.Period_End__c : null));
        
        //Add Std Summary list
        stdGDSummary = mapStdGDSummary.values();
        
        //Sort
        stdGDSummary.sort();
        
        //Vairable to hold the Parent goal template detail wrapper instance
        StdGoalDetailSectionWrapper.StdGoalDetailWrapper sumsTo = null;
        
        //Variable to control the Parent goal template processing,
        //Comment Added By - Rajeev Flag sets to True when Parent GTD Target type got changed
        Boolean isTTChanged = false;
        
        //Set baseline (This is used to display selected baseline label on the page)
        String selectedBaseLine = baseline == null || baseline == '' ? '' : selectedOption(availableBaseLines, baseline);
        
        //Set baseline percentage
        stdGD.Baseline_Percentage__c = stdGD.Baseline_Percentage__c == null || stdGD.Baseline_Percentage__c <= 0 ? 
                                                    100 : stdGD.Baseline_Percentage__c;
         
        //Set Baseline %
        if(String.isBlank(selectedBaseLine))
            stdGD.Baseline_Percentage__c = null;
                
        //Set Parent
        String selectedSUMTo = '';
        
        //Added  By - Rajeev Jain  - 1/21/2016 - SumsTo Issue Fix
        //Populate SumsTo Relationship Map to hold the Hiearachial Data
        //Current Record's unique key
        String currentGTD = goalTypeId + '-' + stdGD.Description__c + '-'+ stdGD.Target_Type__c;
        
        //Add current record in map
        stdGDWrapper.mapForSUMstoRelationship.put(currentGTD, new Set<String>());
             
        //Check for Parent
        if(String.isNotBlank(parentGTD))
            selectedSUMTo = selectedOption(availableParents, parentGTD);
            
        //Check for SUM To Parent
        if(String.isNotBlank(parentGTD)) {
                
            //Call method to get Parent (SUM To)
            sumsTo = goalTemplateDetail(parentGTD);
            
            //Added  By - Rajeev Jain  - 1/21/2016 - SumsTo Issue Fix
            //Populate SumsTo Relationship Map to hold the Hiearachial Data
            
            if(stdGDWrapper.mapForSUMstoRelationship.containsKey(parentGTD))
                stdGDWrapper.mapForSUMstoRelationship.get(parentGTD).add(currentGTD);
            
            //Added  By - Rajeev Jain  - 1/21/2016 - SumsTo Issue Fix - Upto here
            
            //Unique Key
            String summaryMapKey = sumsTo.stdGDetail.Goal_Type__c + '-' + sumsTo.stdGDetail.Description__c + '-' + sumsTo.stdGDetail.Target_Type__c;
            
            //Check for Target Type
            /*if(sumsTo.stdGDetail.Target_Type__c != ISSPConstants.STANDARD_GOAL_DETAIL_TARGET_TYPE_EXPLICIT) {
                
                //Update the Parent goal template detail
                sumsTo.stdGDetail.Target_Type__c = ISSPConstants.STANDARD_GOAL_DETAIL_TARGET_TYPE_EXPLICIT;
                
                isTTChanged = true;
                
            }*/
            
            //Update details on Parent
            sumsTo.stdGDetail.Summary__c = true;
            sumsTo.stdGDetail.Baseline_Percentage__c = null;
            sumsTo.selectedBaseLine = '';
            sumsTo.selectedBaseLineLabel = '';
            sumsTo.childGTDs++;
            
            //Check if summary map contains the Parent SUMs To
            if(mapStdGDSummary.containsKey(summaryMapKey)) {
                
                //Get the summary wrapper
                StdGoalDetailSummaryWrapper gTDSummaryWrap = mapStdGDSummary.get(summaryMapKey);
                
                //Remove Exising
                mapStdGDSummary.remove(summaryMapKey);
                
                //Put new Instance
                mapStdGDSummary.put(sumsTo.stdGDetail.Goal_Type__c + '-' + sumsTo.stdGDetail.Description__c + '-' + sumsTo.stdGDetail.Target_Type__c,gTDSummaryWrap);
            }
            
        }
        
        //Call the method to calculate the values
        calculateValues();
        
        //Instance of GTD Wrapper
        StdGoalDetailSectionWrapper.StdGoalDetailWrapper gTDWrapper = new StdGoalDetailSectionWrapper.StdGoalDetailWrapper(stdGD, goalTypeName,
                                                                       baseline, availableBaseLines, stdGDWrapper.stdGoalDetailsWrapper.size() + 1,
                                                                       selectedBaseLine, new List<StdGoalDetailSectionWrapper.StdGoalDetailConditions>(),
                                                                       parentGTD, availableParents, selectedSUMTo, stdGDWrapper.stdGDetailsWrapper.gTAmount,
                                                                       stdGDWrapper.stdGDetailsWrapper.gTCounter, stdGDWrapper.stdGDetailsWrapper.gTPercent,
                                                                       stdGD.Id == null ? false : true, new List<StdGoalDetailSectionWrapper.GTDMPeriod>());
        
        //Populate the map
        mapGTDWrapper.put(goalTypeId + '-' + stdGD.Description__c + '-' + stdGD.Target_Type__c, gTDWrapper);
        
        //Add new Std Goal Detail in wrapper
        stdGDWrapper.stdGoalDetailsWrapper.add(gTDWrapper);
                                                   
        //Check for Parent goal template detail
        if(sumsTo != null) {
            
            //Check for change flag
            /*if(isTTChanged) {
                
                //Variablre to hold the UK for Parent (SUMs To) GTD
                 String parentGTDUK = sumsTo.stdGDetail.Goal_Type__c + '-' + sumsTo.stdGDetail.Description__c + '-' + sumsTo.stdGDetail.Target_Type__c;
                 
                 //String to hold the Old UK for Parent (SUMs TO) GTD
                 String pGTDUK = sumsTo.stdGDetail.Goal_Type__c + '-' + sumsTo.stdGDetail.Description__c + '-' + ISSPConstants.STANDARD_GOAL_DETAIL_TARGET_TYPE_PACED;
                 
                 //Populate the map with new values
                 stdGDWrapper.mapForSUMstoRelationship.put(parentGTDUK, new Set<String>());
                  
                 //Check old key in map
                 if(stdGDWrapper.mapForSUMstoRelationship.containsKey(pGTDUK)) {
                   
                     //Add values from old
                     stdGDWrapper.mapForSUMstoRelationship.get(parentGTDUK).addAll(stdGDWrapper.mapForSUMstoRelationship.get(pGTDUK));
                       
                     //Remove old key
                     stdGDWrapper.mapForSUMstoRelationship.remove(pGTDUK);  
                 }
                 
                //Loop over map Key and check each element of the map and updated its elemment if necessarry
                for(String str : stdGDWrapper.mapForSUMstoRelationship.keySet()){
                    
                    System.debug('Check Map Key When Targget Type Changed::: ' + str + ' Map Child :::: ' + stdGDWrapper.mapForSUMstoRelationship.get(str));
                    System.debug('Chheck Unique for Map When Targget Type Changed::: ' + pGTDUK);
                    //Check if unique key in any set element then update that also
                    if(stdGDWrapper.mapForSUMstoRelationship.get(str).contains(pGTDUK)){
                            
                        stdGDWrapper.mapForSUMstoRelationship.get(str).add(parentGTDUK);
                        
                        //Remove old element
                        stdGDWrapper.mapForSUMstoRelationship.get(str).remove(pGTDUK);
                    }
                }
                //Check key in map
                if(mapStdGDSummary.containsKey(sumsTo.stdGDetail.Goal_Type__c + '-' + sumsTo.stdGDetail.Description__c
                                                + '-' + ISSPConstants.STANDARD_GOAL_DETAIL_TARGET_TYPE_PACED)) {
                                                    
                    //Instance of Summary wrapper
                    StdGoalDetailSummaryWrapper sGDSW = mapStdGDSummary.get(sumsTo.stdGDetail.Goal_Type__c + '-' + sumsTo.stdGDetail.Description__c
                                                                            + '-' + ISSPConstants.STANDARD_GOAL_DETAIL_TARGET_TYPE_PACED);
                    sGDSW.goalType = sumsTo.stdGDetail.Description__c;
                    
                    //Update the start date and end date
                    sGDSW.startDate = sumsTo.stdGDetail.Period_Start__c;
                    sGDSW.endDate = sumsTo.stdGDetail.Period_End__c;
                    
                    //Remove
                    mapStdGDSummary.remove(sumsTo.stdGDetail.Goal_Type__c + '-' + sumsTo.stdGDetail.Description__c
                                                                            + '-' + ISSPConstants.STANDARD_GOAL_DETAIL_TARGET_TYPE_PACED);
                    
                    //Put
                    mapStdGDSummary.put(sumsTo.stdGDetail.Goal_Type__c + '-' + sumsTo.stdGDetail.Description__c
                                                                            + '-' + sumsTo.stdGDetail.Target_Type__c, sGDSW);
                    
                    //Add Std Summary list
                    stdGDSummary = mapStdGDSummary.values();
                    
                    //Sort
                    stdGDSummary.sort();
                }
                
                //Get Goal Type from map
                Goal_Type__c parentGT = new Goal_Type__c();
                
                //Populate the goal type map
                if(mapGoalTypes.containsKey(sumsTo.stdGDetail.Goal_Type__c + '-' + sumsTo.stdGDetail.Description__c + '-' + ISSPConstants.STANDARD_GOAL_DETAIL_TARGET_TYPE_PACED)) {
                    
                    //Get the goal type
                    parentGT = mapGoalTypes.get(sumsTo.stdGDetail.Goal_Type__c + '-' + sumsTo.stdGDetail.Description__c + '-' + ISSPConstants.STANDARD_GOAL_DETAIL_TARGET_TYPE_PACED);
                    
                    //Remove exising key of parent form map 
                    mapGoalTypes.remove(sumsTo.stdGDetail.Goal_Type__c + '-' + sumsTo.stdGDetail.Description__c + '-' + ISSPConstants.STANDARD_GOAL_DETAIL_TARGET_TYPE_PACED);
                }
                
                //Add new in the map
                mapGoalTypes.put(sumsTo.stdGDetail.Goal_Type__c + '-' + sumsTo.stdGDetail.Description__c + '-' + sumsTo.stdGDetail.Target_Type__c,
                                 parentGT);
                
                //call method to update goal template detail on all the GTD's available options
                updateGTDOptions(sumsTo.stdGDetail.Goal_Type__c + '-' + sumsTo.stdGDetail.Description__c + '-' + ISSPConstants.STANDARD_GOAL_DETAIL_TARGET_TYPE_EXPLICIT,
                                 sumsTo.stdGDetail.Goal_Type__c + '-' + sumsTo.stdGDetail.Description__c + '-' + ISSPConstants.STANDARD_GOAL_DETAIL_TARGET_TYPE_PACED);
                                 
                //Call method to re-calculate GTD for Pacings
                populatePacingGTDs(sumsTo.stdGDetail.Goal_Type__c + '-' + sumsTo.stdGDetail.Description__c + '-' + ISSPConstants.STANDARD_GOAL_DETAIL_TARGET_TYPE_PACED,sumsTo);
            }*/
                                
            //Call method to perform the calculations for parent (SUMs To) goal template detail
            doCalculation(sumsTo);
        }
    }
    
    /**
     *  @description    :   This method is used to update the Options on the existing goal template details according to updated values
     *
     *  @args           :   String, String
     *
     *  @return         :   void
     *
     **/
    /*public void updateGTDOptions(String updatedOption, String existingOption) {
        
        //Loop through the goal template detail wrapper
        for(StdGoalDetailSectionWrapper.StdGoalDetailWrapper gTDW : stdGDWrapper.stdGoalDetailsWrapper) {
            
            //Loop through the baseline options
            for(SelectOption sO : gTDW.avaliableBaseLine) {
                
                //Check for value
                if(sO.getValue() == existingOption) {
                    
                    //Update the selecte Option
                    sO.setValue(updatedOption);
                    
                    //Check for selected value
                    if(gTDW.selectedBaseLine == existingOption)
                        gTDW.selectedBaseLine = updatedOption;  
                    
                    break;
                }
            }
            
            //Loop through the SUMs To options
            for(SelectOption sO : gTDW.availableParents) {
                
                //Check for value
                if(sO.getValue() == existingOption) {
                    
                    //Update the selecte Option
                    sO.setValue(updatedOption);
                    
                    //Check for selected value
                    if(gTDW.selectedParent == existingOption)
                        gTDW.selectedParent = updatedOption;    
                    
                    break;
                }
            }
        }
    }*/
    
    /**
     *  @description    :   This method is used to clone the conditions with the GTD
     *
     *  @args           :   List<StdGoalDetailSectionWrapper.StdGoalDetailConditions>
     *
     *  @return         :   void
     *
     **/
    private void cloneGTDConditions(List<StdGoalDetailSectionWrapper.StdGoalDetailConditions> originalGTDConditions) {
        
        //List of GTD conditions
        List<StdGoalDetailSectionWrapper.StdGoalDetailConditions> gTDConditions = new List<StdGoalDetailSectionWrapper.StdGoalDetailConditions>();
        
        //Loop through the original conditions
        for(StdGoalDetailSectionWrapper.StdGoalDetailConditions gTDC : originalGTDConditions) {
            
            //Instance of GTD Condition
            StdGoalDetailSectionWrapper.StdGoalDetailConditions gTDCOn = new StdGoalDetailSectionWrapper.StdGoalDetailConditions(
                                                                                gTDC.con.clone(false,true), gTDC.rType,gTDC.value,
                                                                                gTDC.rowNumber);
            
            //Add GTD Condition in the list
            gTDConditions.add(gTDCOn);
        }
        
        //Add Conditions on the cloned GTD
        stdGDWrapper.stdGoalDetailsWrapper.get(stdGDWrapper.stdGoalDetailsWrapper.size() - 1).stdGoalDetailConditions = gTDConditions;
        
    }
    
    /**
     *  @description    :   This method is used to clone the GTDMPs with the GTD
     *
     *  @args           :   List<StdGoalDetailSectionWrapper.GTDMPeriod>
     *
     *  @return         :   void
     *
     **/
    private void cloneGTDMPs(List<StdGoalDetailSectionWrapper.GTDMPeriod> originalGTDMPs) {
        
        //List of GTD conditions
        List<StdGoalDetailSectionWrapper.GTDMPeriod> gTDMPeriodWraps = new List<StdGoalDetailSectionWrapper.GTDMPeriod>();
        
        //Loop through the original GTDMPs
        for(StdGoalDetailSectionWrapper.GTDMPeriod gTDMPW : originalGTDMPs) {
            
            //Instance of GTDMP
            StdGoalDetailSectionWrapper.GTDMPeriod gTDMPWrap = new StdGoalDetailSectionWrapper.GTDMPeriod(
                                                                                gTDMPW.gTDMP.clone(false,true),gTDMPW.rowNumber);
            
            //Add GTDMP in list
            gTDMPeriodWraps.add(gTDMPWrap);
        }
        
        //Add Conditions on the cloned GTD
        stdGDWrapper.stdGoalDetailsWrapper.get(stdGDWrapper.stdGoalDetailsWrapper.size() - 1).gTDMPeriods = gTDMPeriodWraps;
        
    }
    
    /**
     *  @description    :   This method is used to set the Integer number according to shorted GTD list
     *
     *  @args           :   
     *
     *  @return         :   void
     *
     **/
    public void setRowIndex() {
        
        //Short the list
        stdGDWrapper.stdGoalDetailsWrapper.sort();
        
        //Variable to hold the Integer
        Integer rowIndex = 1;
        
        //Loop through GTD wrapper
        for(StdGoalDetailSectionWrapper.StdGoalDetailWrapper gTDW : stdGDWrapper.stdGoalDetailsWrapper) {
            
            //Set Row Index
            gTDW.rowIndex = rowIndex;
            
            rowIndex++;
        }
    }
    
    //Wrapper to hold Std Goal Details summary
    public class StdGoalDetailSummaryWrapper implements Comparable {

        //Properties
        public String goalType {get;set;}
        public Date startDate {get;set;}
        public Date endDate {get;set;}

        //Constructor
        public StdGoalDetailSummaryWrapper(String goalType, Date startDate, Date endDate) {
            
            this.goalType = goalType;
            this.startDate = startDate;
            this.endDate = endDate;
        }
        
        // Implement the compareTo() method
        public Integer compareTo(Object compareTo) {
        
            StdGoalDetailSummaryWrapper compareToEmp = (StdGoalDetailSummaryWrapper)compareTo;
            
            if (goalType == compareToEmp.goalType) return 0;
            if (goalType > compareToEmp.goalType) return 1;
            return -1;        
        }
    }
    
    /**
    * Method to populate Baseline 
    **/
    public void populateBaselinePercent(){
        
        if(stdGDWrapper.stdGDetailsWrapper != null && stdGDWrapper.stdGDetailsWrapper.isUseAsBaseline != null && stdGDWrapper.stdGDetailsWrapper.isUseAsBaseline && stdGDWrapper.stdGD != null && String.isNotBlank(stdGDWrapper.stdGD.Period__c)){
            
            stdGDWrapper.stdGD.Baseline_Percentage__c = stdGDWrapper.stdGDetailsWrapper.mapPeriods.get(stdGDWrapper.stdGD.Period__c).Percent__c;
        }
    }
}