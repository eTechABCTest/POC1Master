/**
 *  Purpose         :   Controller for CreatePersonalGoalsFromStdGoal VF page.
 *                      Class is runing in without sharing. As VF page access is controlling by permission set, so this won't impact anything.
 *                      Users only having CRED access having access to all Incentive projects and they wants to delete others records through the VF page,
 *                      this only possiable using without sharing.
 *  
 *  Created By      :   Subhash Garhwal
 * 
 *  Created Date    :   08/26/2015 
 * 
 *  Revision Logs   :   V_1.0 - Created - CR-20150729-9114
 *                      V_1.1 - Modified - Subhash Garhwal - 11/27/2015 - CR-20151120-9407 - PGMP functionality.
 *                      V_1.2 - Modified - Subhash Garhwal - 12/14/2015 - CR-20151217-9469 - ISSP Deployment C.
 *                      V_1.3 - Modified - Rajeev Jain - 02/25/2016 - CR-20160115-9543 - ISSP Deployment D - Fixed Tenure Issue
 *                      V_1.4 - Modified - Rajeev Jain - 03/22/2016 - CR-20160316-9698 - ISSP SFDC Critical NBB Calculation Fixes
 *`                     V_1.5 - Modified - Rajeev Jain - 03/29/2016 - CR-20160316-9699 - ISSP SFDC Critical NBB Calculation Fixes - QA Fixes
 *                      V_1.6 - Modified - Rajeev Jain - 04/10/2016 - CR - 9688 - ISSP Deployment E - Provided Tenure on each personal Goal level, included in calculation
 *                      V_1.7 - Modified - Rajeev Jain - 04/14/2016 - CR-20160307-9680 - ISSP Deployment E - Save GTD value type on Personal Goal Value Type
 *                      V_1.8 - Modified - Rajeev Jain - 05/04/2016 - CR-20160421-9789 - Populates Adj% value default(bTMultiplier) from GoalType business Title of GTDs.
 *                      V_1.9 - Modified - Rajeev Jain - 05/05/2016 - CR-20160429-9810 - Populate GTD changes on Personal Goal level
 *                      V_1.10 - Modified - Rajeev Jain - 05/17/2016 - CR-20160512-9852, along with fixed bug found in calculation 
 **/
public without sharing class CreatePersonalGoalsFromStdGoalController {
        
    //Properties
    public Personal_Goal__c personalGoal {get;set;}
    public Personal_Goal__c stdPersonalGoal {get;set;}
    public Standard_Goal__c stdGoal {get;set;}
    public String selectedLimitToValue {get;set;}
    public List<PayeesWrapper> availablePayees {get;set;}
    public List<PayeesWrapper> selectedPayees {get;set;}
    public List<CreatePersonalGoalsSectionWrapper> createPGSecWrapper {get;set;}
    public List<SelectOption> createPGBegains {get;set;}
    public String selectedPeriod {get;set;}
    public Boolean showEarlier {get;set;}
    public Boolean showLater {get;set;}
    public Map<Integer, Boolean> mapControlCalcs {get;set;}
    
    //Variable to control the calc button on the PGs section
    public Boolean showMultiplier {get;set;}
    
    //Variable to hold select all checkbox value
    public Boolean selectAll {get;set;}
    
    //Map to hold Std Goal Detail Pacing records
    Map<Id, Standard_Goal_Detail_Pacing__c> mapStdGoalDetailPacings;
    
    //Set to hold selected Payees Id
    Set<Id> setSelectedPayeesIds;
    
    //Map to hold the combination of payee Id and goal type Id with business multiplier
    //This map is used to get the busienss multiplier for the goal
    Map<String, Decimal> mapPayeeIdWithBTMultiplier;
    
    //Map to hold the Business Title Ids with Payee Ids
    Map<String, String> mapBTIdWIthPayeeId = new Map<String, String>();
        
    //List of value types
    List<Value_Type__c> valueTypes;
    
    //Select List for Limit To select list
    public List<SelectOption> limitTo {get;set;}
    
    //Added - Subhash Garhwal - 11/27/2015 - CR-20151120-9407
    public List<CreatePersonalGoalsSectionWrapper.PGMPeriodWrapper> pGMPeriods {get;set;}
    public Personal_Goal_Measurement_Period__c pGMPeriod {get;set;}
    public Integer mainRow {get;set;}
    public Integer gTDRow {get;set;}
    public Integer columnRow {get;set;}
    
    //Map to hold the payee Id and Pacing Id as key (uK) and list of PGMP wrapper
    Map<String, List<CreatePersonalGoalsSectionWrapper.PGMPeriodWrapper>> mapPGMPWithPIdAndPId;
    
    //Map to hold the GTD Id with List of GTDMPs
    Map<Id, List<Goal_Template_Detail_Measurement_Period__c>> mapGTDMPeriods;
    
    //Set to hold the PGRs Ids to delete
    Set<Id> setPGRIds;
    
    //Map to hold the Personal Goal Id with List of PGMP
    Map<Id, List<Personal_Goal_Measurement_Period__c>> mapPGMPGoingToDelete;
    
    //Variable to check select checkbox action
    Boolean isSelect;
        
    
    /************    Variables for Staff Relationship and Condition functionality   **************/
    
    //Insatance of Staff Relationship wrapper class
    public StaffRelationshipWrapper sRelationship {get;set;}
    
    //Variable to hold the payee Id
    public String payeeId {get;set;}
    
    //List of condition
    //This list is used to display the conditions for the std goal detail
    public List<Condition__c> conditions {get;set;}
    
    //List of GTDMP
    //This list is used to display the GTDMPs for the goal temp detail
    public List<Goal_Template_Detail_Measurement_Period__c> gTDMPeriods {get;set;}
    
    //List of Std Goal detail wrapper
    //This list will used to draw the std goal detail headers and to display condition
    public List<StdGoalDetailWrapper> stdGoalDetails {get;set;}
    
    //Convert String into Integer
    public Integer rowIndex {get;set;}
    public Integer colIndex {get;set;}
    public Integer itemIndex {get;set;}
    
    /**********  End   ************/
    
    //Local variables
    
    //Map to hold the Snapshot id as key and Proposed Goal as value
    Map<Id, Id> mapExistingProposals;
    
    //Map to hold the Snapshot with max proposal counter
    Map<Id, Decimal> mapSSIdWIthPPCounter; 
    
    //Constructor
    public CreatePersonalGoalsFromStdGoalController() {
        
        //Initilize
        stdPersonalGoal = new Personal_Goal__c();
        
        //inIt method
        inIt();
    }
    
    /**
     *  @description    :   This method is used to load all the properties
     *
     *  @args           :   
     *
     *  @return         :   void
     *
     **/
    public void inIt() {
        
        //Initilize all the properties
        personalGoal = new Personal_Goal__c();
        stdGoal = new Standard_Goal__c();
        availablePayees = new List<PayeesWrapper>();
        selectedPayees = new List<PayeesWrapper>();
        createPGSecWrapper = new List<CreatePersonalGoalsSectionWrapper>(); 
        createPGBegains = new List<SelectOption>();
        mapStdGoalDetailPacings = new Map<Id, Standard_Goal_Detail_Pacing__c>();
        setSelectedPayeesIds = new Set<Id>();
        mapPayeeIdWithBTMultiplier = new Map<String, Decimal>();
        mapBTIdWIthPayeeId = new Map<String,String>();
        conditions = new List<Condition__c>();
        stdGoalDetails = new List<StdGoalDetailWrapper>();
        limitTo = new List<SelectOption>();
        mapControlCalcs = new Map<Integer, Boolean>();
        gTDMPeriods = new List<Goal_Template_Detail_Measurement_Period__c>();
        pGMPeriods = new List<CreatePersonalGoalsSectionWrapper.PGMPeriodWrapper>();
        pGMPeriod = new Personal_Goal_Measurement_Period__c();
        mapPGMPWithPIdAndPId = new Map<String, List<CreatePersonalGoalsSectionWrapper.PGMPeriodWrapper>>();
        mapGTDMPeriods = new Map<Id, List<Goal_Template_Detail_Measurement_Period__c>>();
        setPGRIds = new Set<Id>();
        mapPGMPGoingToDelete = new Map<Id, List<Personal_Goal_Measurement_Period__c>>();
        mapExistingProposals = new Map<Id,Id>();
        mapSSIdWIthPPCounter = new Map<Id, Decimal>();
        
        //Set Defaults
        selectedLimitToValue = '';
        selectedPeriod = '';
        showEarlier = false;
        showLater = false;
        selectAll = false;
        showMultiplier = false;
        isSelect = false;
        
        //Query through the Value Type
        valueTypes = [Select Id, Adjustment__c From Value_Type__c Where Name =: ISSPConstants.VALUE_TYPE_NAME_TENURE LIMIT 1];
        
        //Get the Parameter from URL
        String stdGoalId = ApexPages.currentPage().getParameters().get('id');
        
        //Check for value
        if(stdPersonalGoal.Standard_Goal__c == null && stdGoalId instanceof Id)
            stdPersonalGoal.Standard_Goal__c = stdGoalId;
        
        //Add Blank Option in LIMIT to list
        limitTo.add(new SelectOption('', '--None--'));
        
        //Check for std goal
        if(stdPersonalGoal.Standard_Goal__c != null) {
            
            stdGoal = [Select Id, Name, Payee__c, Payee__r.Name, Standard_Type__c, Description__c, Amount__c,Counter__c, Percent__c, Period_Start__c,Period_End__c
                                  From Standard_Goal__c Where Id =: stdPersonalGoal.Standard_Goal__c LIMIT 1];
            
            String payeeId = ApexPages.currentPage().getParameters().get('payeeId');
            
            //Check for Std Goal group type
            if(stdGoal.Standard_Type__c == ISSPConstants.STANDARD_GOAL_STANDARD_TYPE_PERSONAL) {
                
                //Add Payee Option
                limitTo.add(new SelectOption('1', ISSPConstants.LIMIT_TO_NAMED_PAYEE));
                
                //Set default
                selectedLimitToValue = '1';
            
            //Set default for group type std goal
            } else if(stdGoal.Standard_Type__c == ISSPConstants.STANDARD_GOAL_STANDARD_TYPE_GROUP)
                selectedLimitToValue = '3';
                
            if((String.isNotBlank(payeeId) && payeeId instanceof Id)){
                selectedLimitToValue = '2';
            }
        }
        
        //Add other options in list
        limitTo.add(new SelectOption('2', ISSPConstants.LIMIT_TO_PAYEES_ALREADY_ASSIGNED));  
        limitTo.add(new SelectOption('3', ISSPConstants.LIMIT_TO_BUSINESS_TITLE_MATCHES_GOAL_TEMPLATE));
        limitTo.add(new SelectOption('4', ISSPConstants.LIMIT_TO_SPECIFIC_BUSINESS_TITLE));
        limitTo.add(new SelectOption('5', ISSPConstants.LIMIT_TO_SPECIFIC_INCENTIVE_ROLE));
        limitTo.add(new SelectOption('6', ISSPConstants.LIMIT_TO_SPECIFIC_GOAL_TEMPLATE));
        limitTo.add(new SelectOption('7', ISSPConstants.LIMIT_TO_SPECIFIC_RATE_TEMPLATE));
        limitTo.add(new SelectOption('8', ISSPConstants.LIMIT_TO_INDIVIDUAL_PAYEE));
        
        //Call load payees method
        loadPayees();
    }
    
    /**
     *  @description    :   This method is used to load Payee list according to select LIMIT To option.
     *
     *  @args           :   
     *
     *  @return         :   void
     *
     **/
    public void loadPayees() {
        
        //Initilize the properties
        createPGBegains = new List<SelectOption>();
        selectedPeriod = '';
        createPGSecWrapper = new List<CreatePersonalGoalsSectionWrapper>();
        
        //Check for Standard goal detail
        if(stdPersonalGoal.Standard_Goal__c != null)
            stdGoal = [Select Id, Name, Payee__c, Payee__r.Name, Payee__r.Function__c, Payee__r.LastName, Description__c, Amount__c,Counter__c, Percent__c, Period_Start__c,Period_End__c
                                        From Standard_Goal__c Where Id =: stdPersonalGoal.Standard_Goal__c];
            
        //Re-Initilize Properties
        availablePayees = new List<PayeesWrapper>();
        personalGoal = new Personal_Goal__c();
        
        //Check for selected type
        if(String.isNotBlank(selectedLimitToValue)) {
            
            //Check for payee
            if(selectedLimitToValue == '1' && stdGoal.Payee__c != null) {
                
                //Set to hold Payee Ids for Personal Goal
                Set<Id> setPGPayeesIds = new Set<Id>();
                
                //Query through Personal Gaols
                for(Personal_Goal__c pG : [Select Id, Payee__c, Sales_Role_Percentage__c, Tenure_Percentage__c,Goal_Type_Business_Title__c From Personal_Goal__c
                                                   Where Payee__c =: stdGoal.Payee__c AND Standard_Goal__c =: stdGoal.Id
                                                         AND RecordType.DeveloperName =: ISSPConstants.PERSONAL_GOAL_RECORD_TYPE_PERSONAL_GOAL])
                    setPGPayeesIds.add(pG.Payee__c);
                
                //V_1.5 - Modified - Rajeev Jain - 03/29/2016 - CR-20160316-9699 - ISSP SFDC Critical NBB Calculation Fixes - QA Fixes
                //Modified Query criteria to query only those staff attr which are active for today dates
                //List of Staff History
                List<Staff_History__c> staffAttributes = [Select Id, Name, Start_Date__c, Staff_Member__c, Staff_Member__r.Name, Staff_Member__r.FirstName,
                                                                 Staff_Member__r.LastName, Staff_Member__r.Function__c, Value__c, Value_Type__c, Value_Type__r.Name,
                                                                 Percent_Value__c, Value_Type__r.Category__c,Value_Type__r.Adjustment__c From Staff_History__c
                                                                 Where Staff_Member__c =: stdGoal.Payee__c AND Start_Date__c <= :Date.Today() AND (End_Date__c = NULL OR End_Date__c >= :Date.Today()) ORDER BY Start_Date__c DESC NULLS LAST];
                
                //Check for list size
                if(staffAttributes.size() > 0) {
                    
                    //Map to hold the Payee Id with Payee Wrapper instance
                    Map<Id,PayeesWrapper> mapAvailablePayees = mapAvailablePayees(staffAttributes,setPGPayeesIds);
                    
                    //Add Payees in available apyees list
                    availablePayees.addAll(mapAvailablePayees.values());
                    
                } else {
                        
                    availablePayees.add(new PayeesWrapper(stdGoal.Payee__r.Name, '','', '', null, 'No', null,
                                                          setPGPayeesIds.contains(stdGoal.Payee__c) ? 'Yes' : 'No', stdGoal.Payee__c,
                                                          null, null, stdGoal.Payee__r.Function__c));
                }
            
            //Check for selected option (Check if user selects Payees already assigned)
            } else if(selectedLimitToValue == '2' && stdPersonalGoal.Standard_Goal__c != null) {
                
                //Populate Wrapper
                availablePayees =  getAvailablePayees(stdPersonalGoal.Standard_Goal__c, stdPersonalGoal.Standard_Goal__c);
                
            //Check for selected option (Check for Sales Role matches Standard Goal)
            } else if(selectedLimitToValue == '3' && stdPersonalGoal.Standard_Goal__c != null) {
                
                //Set to hold Value Type Ids
                Set<Id> setVTIds = new Set<Id>();
                
                //Query through all the Std goal Sales Role records
                for(Standard_Goal_Sales_Role__c sGSR : [Select Id, Sales_Role__c From Standard_Goal_Sales_Role__c Where Standard_Goal__c =: stdPersonalGoal.Standard_Goal__c
                                                                                                                  AND Sales_Role__c != null])
                    setVTIds.add(sGSR.Sales_Role__c);
                
                //Check for set size
                if(setVTIds.size() > 0) {
                    
                    //Set to hold the Payee (Staff Member Id)
                    Set<Id> setSMIds = new Set<Id>();
                    
                    //V_1.5 - Modified - Rajeev Jain - 03/29/2016 - CR-20160316-9699 - ISSP SFDC Critical NBB Calculation Fixes - QA Fixes
                    //Modified Query criteria to query only those staff attr which are active for today dates    
                    //Query through the Syaff Attributes 
                    for(Staff_History__c sA : [Select Id, Name, Start_Date__c, Staff_Member__c, Staff_Member__r.Name, Staff_Member__r.FirstName,
                                                                     Staff_Member__r.LastName, Staff_Member__r.Function__c, Value__c, Value_Type__c, Value_Type__r.Name,
                                                                     Value_Type__r.Category__c,Value_Type__r.Adjustment__c, Percent_Value__c From Staff_History__c
                                                                     Where Value_Type__c IN : setVTIds AND Staff_Member__c != null AND Start_Date__c <= :Date.Today() AND (End_Date__c = NULL OR End_Date__c >= :Date.Today()) ORDER BY Start_Date__c DESC NULLS LAST])
                        setSMIds.add(sA.Staff_Member__c);
                            
                    //List of Staff History
                    List<Staff_History__c> staffAttributes = [Select Id, Start_Date__c, Name, Staff_Member__c, Staff_Member__r.Name, Staff_Member__r.FirstName,
                                                                     Staff_Member__r.LastName, Staff_Member__r.Function__c, Value__c, Value_Type__c, Value_Type__r.Name,
                                                                     Value_Type__r.Category__c,Value_Type__r.Adjustment__c, Percent_Value__c From Staff_History__c
                                                                     Where Staff_Member__c IN : setSMIds AND Staff_Member__c != null ORDER BY Start_Date__c DESC NULLS LAST];
                    
                    //Map to hold Payee Id with Payees Wrapper instance
                    Map<Id, PayeesWrapper> mapAvailablePayees = mapAvailablePayees(staffAttributes,new Set<Id>());
                    
                    //Add all Payees data in list
                    availablePayees.addAll(mapAvailablePayees.values());
                    
                    //Map to hold Payee Id wiith personal goal on selected std goal
                    Map<Id, Boolean> mapPayeeIdWIthPG = new Map<Id, Boolean>();
                    
                    //Loop through the Personal Goal
                    for(Personal_Goal__c pG : [Select Id, Payee__c, Standard_Goal__c, Sales_Role_Percentage__c, Tenure_Percentage__c, Goal_Type_Business_Title__c From Personal_Goal__c Where Standard_Goal__c =: stdPersonalGoal.Standard_Goal__c
                                                AND Payee__c IN : mapAvailablePayees.keySet() AND RecordType.DeveloperName = 'Personal_Goal'])
                        mapPayeeIdWIthPG.put(pG.Payee__c, true);
                    
                    //Loop through Wrapper
                    for(PayeesWrapper pW : availablePayees) {
                        
                        //Check for contact Id
                        if(mapPayeeIdWIthPG.containsKey(pW.contactId))
                            pW.hasGoal = 'Yes';     
                    }
                }
            }
            
            //Added By - Rajeev Jain - 11/13 - Resolve Payee Issue list and Enhancment - To Sort by LastName for Available Payees List
            availablePayees.sort();
        }
        
        //Map to hold the Description with List of same pacings
        Map<String, List<Standard_Goal_Detail_Pacing__c>> mapBeginsPacings = new Map<String, List<Standard_Goal_Detail_Pacing__c>>();
        
        //Add None option in list
        createPGBegains.add(new SelectOption('', '--NONE--'));
        
        //Query through the Std Goal Detail Pacings and populate Personal Goal Begains options
        for(Standard_Goal_Detail_Pacing__c sGDP : [Select Id, Period_Start__c, Amount__c,Period_End__c, Description__c, Standard_Goal_Detail__c, Standard_Goal__c From Standard_Goal_Detail_Pacing__c
                                                              Where Standard_Goal_Detail__r.Standard_Goal__c =: stdPersonalGoal.Standard_Goal__c
                                                              AND Description__c != null ORDER BY Period_Start__c ASC]) {
            
            //Check Description in the list
            if(!mapBeginsPacings.containsKey(sGDP.Description__c))
                mapBeginsPacings.put(sGDP.Description__c, new List<Standard_Goal_Detail_Pacing__c>());
            
            //Add Pacing in the map
            mapBeginsPacings.get(sGDP.Description__c).add(sGDP);
            
            //Add Pacing record in Map
            mapStdGoalDetailPacings.put(sGDP.Id, sGDP);
        }
        
        //Loop through the Pacings Description
        for(String des : mapBeginsPacings.keySet()) {
            
            //Map to hold the Year with Pacings Id
            Map<String, Id> mapPacingsWithYear = new Map<String, Id>();
            
            //Loop through the Pacings
            for(Standard_Goal_Detail_Pacing__c gTDP : mapBeginsPacings.get(des)) {
                
                //Check for start date
                if(gTDP.Period_Start__c != null) {
                    
                    //Get the Year from Start date
                    String pSYear = String.valueOf(gTDP.Period_Start__c.year());
                    
                    //Check year in map
                    if(!mapPacingsWithYear.containsKey(pSYear))
                        mapPacingsWithYear.put(pSYear, gTDP.Id);
                }
            }
            
            //Check for map size
            if(mapPacingsWithYear.size() == 1)
                createPGBegains.add(new SelectOption(mapBeginsPacings.get(des)[0].Id, des));
            else {
                
                //Loop through the Pacings
                for(String pYear : mapPacingsWithYear.keySet()) {
                    
                    //Add option in begins list with year
                    createPGBegains.add(new SelectOption(mapPacingsWithYear.get(pYear), des + ' ' + pYear));
                }
            }
        }
         
    }
    
    /**
     *  @description    :   This method is used to fatch the Payee data according to selected Value Type/Std Goal/Rate Template from loopup
     *                      next to LIMIT TO picklist
     *
     *  @args           :   
     *
     *  @return         :   void
     *
     **/
    public void loadFilteredPayees() {
        
        //Initilize the properties
        selectedPeriod = '';
        createPGSecWrapper = new List<CreatePersonalGoalsSectionWrapper>();
        
        //Re-Initilize Properties
        availablePayees = new List<PayeesWrapper>();
        
        //Check for selected type
        if(String.isNotBlank(selectedLimitToValue)) {
            
            //Check for selectd type
            if((selectedLimitToValue == '4' && personalGoal.Business_Title__c != null) || (selectedLimitToValue == '5' && personalGoal.Value_Type__c != null)) {
                
                //Variable to hold the Value type Id
                String vTypeId = (selectedLimitToValue == '4' && personalGoal.Business_Title__c != null) ? personalGoal.Business_Title__c
                                                                                                        : personalGoal.Value_Type__c;
                
                //Set to hold Payees Ids
                Set<Id> setPayeesIds = new Set<Id>();
                
                //V_1.5 - Modified - Rajeev Jain - 03/29/2016 - CR-20160316-9699 - ISSP SFDC Critical NBB Calculation Fixes - QA Fixes
                //Modified Query criteria to query only those staff attr which are active for today dates
                //Loop through Staff History
                for(Staff_History__c sA : [Select Id, Start_Date__c, Name, Staff_Member__c, Staff_Member__r.Name, Staff_Member__r.FirstName, Staff_Member__r.LastName, Staff_Member__r.Function__c,
                                                  Value__c, Value_Type__c, Value_Type__r.Name, Value_Type__r.Category__c, Value_Type__r.Adjustment__c,
                                                  Percent_Value__c From Staff_History__c Where Value_Type__c =: vTypeId AND Staff_Member__c != null AND Start_Date__c <= :Date.Today() AND (End_Date__c = NULL OR End_Date__c >= :Date.Today())])
                    setPayeesIds.add(sA.Staff_Member__c);
                
                //Set to hold Payee Ids for Personal Goal
                Set<Id> setPGPayeesIds = new Set<Id>();
                
                //Query through Personal Gaols
                for(Personal_Goal__c pG : [Select Id, Payee__c, Sales_Role_Percentage__c, Tenure_Percentage__c, Goal_Type_Business_Title__c From Personal_Goal__c Where Payee__c IN : setPayeesIds
                                                   AND Standard_Goal__c =: stdPersonalGoal.Standard_Goal__c AND RecordType.DeveloperName = 'Personal_Goal'])
                    setPGPayeesIds.add(pG.Payee__c);
                
                //Query through of Staff History
                List<Staff_History__c> staffHistories = [Select Id, Start_Date__c, Name, Staff_Member__c, Staff_Member__r.Name, Staff_Member__r.FirstName,Staff_Member__r.LastName,
                                                                Staff_Member__r.Function__c, Value__c, Value_Type__c, Value_Type__r.Name, Value_Type__r.Category__c,
                                                                Value_Type__r.Adjustment__c, Percent_Value__c
                                                                From Staff_History__c Where Staff_Member__c =: setPayeesIds AND Staff_Member__c != null
                                                                AND Start_Date__c <= :Date.Today() AND (End_Date__c = NULL OR End_Date__c >= :Date.Today())];
                
                //Map to hold the Payee Id with Payee Wrapper instance
                Map<Id,PayeesWrapper> mapAvailablePayees = mapAvailablePayees(staffHistories,setPGPayeesIds);
                    
                //Add All the payees in list
                availablePayees.addAll(mapAvailablePayees.values());
            
            //Check for Specific Standard Goal type
            } else if(selectedLimitToValue == '6' && personalGoal.Standard_Goal__c != null) {
                
                //Populate Wrapper
                availablePayees =  getAvailablePayees(personalGoal.Standard_Goal__c, stdPersonalGoal.Standard_Goal__c);
            
            //Check for Specific Rate Template
            } else if(selectedLimitToValue == '7' && personalGoal.Rate_Template__c != null) {
                
                //Set to hold Payee Id
                Set<Id> setPayeesId = new Set<Id>();
                
                //Set to hold Payee Id if Personal Goal is on default Std Goal
                Set<Id> setPGPayeesId = new Set<Id>();
                
                //Query through Personal Goal
                for(Personal_Goal__c pG : [Select Id, Payee__c, Standard_Goal__c, Sales_Role_Percentage__c, Tenure_Percentage__c, Goal_Type_Business_Title__c From Personal_Goal__c Where
                                                Rate_Template__c =: personalGoal.Rate_Template__c AND Payee__c != null
                                                AND RecordType.DeveloperName =: ISSPConstants.PERSONAL_GOAL_RECORD_TYPE_PERSONAL_GOAL]) {
                    
                    //Add Payee Id
                    setPayeesId.add(pG.Payee__c);
                    
                    //Check for Std Goal
                    if(pG.Standard_Goal__c == stdPersonalGoal.Standard_Goal__c)
                        setPGPayeesId.add(pG.Payee__c);
                }
                
                //V_1.5 - Modified - Rajeev Jain - 03/29/2016 - CR-20160316-9699 - ISSP SFDC Critical NBB Calculation Fixes - QA Fixes
                //Modified Query criteria to query only those staff attr which are active for today dates
                //List of Staff Attributes
                List<Staff_History__c> staffAttributes = [Select Id, Start_Date__c, Name, Staff_Member__c, Staff_Member__r.Name, Staff_Member__r.FirstName,
                                                                 Staff_Member__r.LastName, Staff_Member__r.Function__c, Value__c, Value_Type__c, Value_Type__r.Name,
                                                                 Value_Type__r.Category__c, Value_Type__r.Adjustment__c,Percent_Value__c From Staff_History__c
                                                                 Where Staff_Member__c != null AND Staff_Member__c IN : setPayeesId AND Start_Date__c <= :Date.Today() AND (End_Date__c = NULL OR End_Date__c >= :Date.Today()) ORDER BY Start_Date__c DESC NULLS LAST];
                
                //Map to hold Payee Id with Payees wrapper
                Map<Id, PayeesWrapper> mapAvailablePayees = mapAvailablePayees(staffAttributes,setPGPayeesId);
                
                //Add all the Payyes in list
                availablePayees.addAll(mapAvailablePayees.values());
                
            }else if(selectedLimitToValue == '8' && personalGoal.Payee__c != null){
                
                //Query on Staff Attributes in order to get all of its staff attribbute and fill the payee wrapper in order to complete all additional properties of payee
                List<Staff_History__c> staffAttributes = [Select Id, Start_Date__c, Name, Staff_Member__c, Staff_Member__r.Name, Staff_Member__r.FirstName,
                                                                 Staff_Member__r.LastName, Staff_Member__r.Function__c, Value__c, Value_Type__c, Value_Type__r.Name,
                                                                 Value_Type__r.Category__c, Value_Type__r.Adjustment__c,Percent_Value__c From Staff_History__c
                                                                 Where Staff_Member__c != null AND Staff_Member__c = : personalGoal.Payee__c AND Start_Date__c <= :Date.Today() AND (End_Date__c = NULL OR End_Date__c >= :Date.Today()) ORDER BY Start_Date__c DESC NULLS LAST];
                
                //Check for Staff hitory records
                if(staffAttributes.size() > 0) {
                    
                    //Set to hold Payee Id
                    Set<Id> setPayeesId = new Set<Id>();
                    setPayeesId.add(personalGoal.Payee__c);     
                                                 
                    //Map to hold Payee Id with Payees wrapper
                    Map<Id, PayeesWrapper> mapAvailablePayees = mapAvailablePayees(staffAttributes,setPayeesId);
                    
                    //Add all the Payyes in list
                    availablePayees.addAll(mapAvailablePayees.values());
                    
                } else {
                    
                    //Query on the Payee
                    List<Contact> payees = [Select Id, Name, Function__c,(select Id from Personal_Goals__r LIMIT1) From Contact Where Id =: personalGoal.Payee__c LIMIT 1];
                    
                    //Check for size
                    if(payees.size() > 0)
                        availablePayees.add(new PayeesWrapper(payees[0].Name, '', '', '', null, '', null, payees[0].Personal_Goals__r.size()>0 ? 'Yes' : 'No' ,payees[0].Id,'','',payees[0].Function__c));
                }
                        
                for(PayeesWrapper pW : availablePayees) {
                    pW.selected = true;
                }
                selectPayee();
            }
            
            //Added By - Rajeev Jain - 11/13 - Resolve Payee Issue list and Enhancment - To Sort by LastName for Available Payees List
            availablePayees.sort();
        }
    }
    
    /**
     *  @description    :   Utility Method to populate the Payees map.
     *
     *  @args           :   List<Staff_History__c>, 
     *
     *  @return         :   Map<Id, PayeesWrapper>
     *
     **/
    public Map<Id, PayeesWrapper> mapAvailablePayees(List<Staff_History__c> staffAttributes, Set<Id> setPGPayeeIds) {
        
        //Map to hold Payee Id with Payees wrapper
        Map<Id, PayeesWrapper> mapAvailablePayees = new Map<Id, PayeesWrapper>();
        
        //Map to hold the Most recent Business Title with related contact
        Map<Id, Staff_History__c> mapBTSAWithStaffMember = new Map<Id, Staff_History__c>();
        
        //Map to hold the Most recent incentive role with related contact
        Map<Id, Staff_History__c> mapIRSAWithStaffMember = new Map<Id, Staff_History__c>();
        
        //Query through all the Staff History records
        for(Staff_History__c sA : staffAttributes) {
           
            //Check if map contains the Staff Member
            if(!mapBTSAWithStaffMember.containsKey(sA.Staff_Member__c) && sA.Value_Type__r.Category__c == ISSPConstants.VALUE_TYPE_CATEGORY_BUSINESS_TITLE)
                mapBTSAWithStaffMember.put(sA.Staff_Member__c, sA);
            
            else if(mapBTSAWithStaffMember.containsKey(sA.Staff_Member__c) && sA.Value_Type__r.Category__c == ISSPConstants.VALUE_TYPE_CATEGORY_BUSINESS_TITLE) {
                
                //Check for selected option
                if(selectedLimitToValue == '4') {
                    
                    //Check for value type
                    if(personalGoal.Business_Title__c == sA.Value_Type__c && mapBTSAWithStaffMember.get(sA.Staff_Member__c).Value_Type__c != personalGoal.Business_Title__c)
                        mapBTSAWithStaffMember.put(sA.Staff_Member__c, sA);
                    
                    else if((personalGoal.Business_Title__c == sA.Value_Type__c && mapBTSAWithStaffMember.get(sA.Staff_Member__c).Value_Type__c == personalGoal.Business_Title__c)
                             || (personalGoal.Business_Title__c != sA.Value_Type__c && mapBTSAWithStaffMember.get(sA.Staff_Member__c).Value_Type__c != personalGoal.Business_Title__c)) {
                        
                        //Check for start date
                        if(sA.Start_Date__c != null && (mapBTSAWithStaffMember.get(sA.Staff_Member__c).Start_Date__c == null
                            ||sA.Start_Date__c > mapBTSAWithStaffMember.get(sA.Staff_Member__c).Start_Date__c))
                            mapBTSAWithStaffMember.put(sA.Staff_Member__c, sA);                 
                    }   
                
                //If selected option if other than business title
                } else  {
                    
                    //Check for start date
                    if(sA.Start_Date__c != null && (mapBTSAWithStaffMember.get(sA.Staff_Member__c).Start_Date__c == null
                        ||sA.Start_Date__c > mapBTSAWithStaffMember.get(sA.Staff_Member__c).Start_Date__c))
                        mapBTSAWithStaffMember.put(sA.Staff_Member__c, sA);
                }
            }
            
            //Check if map contains the Staff Member
            if(!mapIRSAWithStaffMember.containsKey(sA.Staff_Member__c) && sA.Value_Type__r.Category__c == ISSPConstants.VALUE_TYPE_CATEGORY_INCENTIVE_ROLE)
                mapIRSAWithStaffMember.put(sA.Staff_Member__c, sA);
            
            else if(mapIRSAWithStaffMember.containsKey(sA.Staff_Member__c) && sA.Value_Type__r.Category__c == ISSPConstants.VALUE_TYPE_CATEGORY_INCENTIVE_ROLE) {
                
                //Check for selected option
                if(selectedLimitToValue == '5') {
                    
                    //Check for value type
                    if(personalGoal.Value_Type__c == sA.Value_Type__c && mapIRSAWithStaffMember.get(sA.Staff_Member__c).Value_Type__c != personalGoal.Value_Type__c)
                        mapIRSAWithStaffMember.put(sA.Staff_Member__c, sA);
                    
                    else if((personalGoal.Value_Type__c == sA.Value_Type__c && mapIRSAWithStaffMember.get(sA.Staff_Member__c).Value_Type__c == personalGoal.Value_Type__c)
                             || (personalGoal.Value_Type__c != sA.Value_Type__c && mapIRSAWithStaffMember.get(sA.Staff_Member__c).Value_Type__c != personalGoal.Value_Type__c)) {
                        
                        //Check for start date
                        if(sA.Start_Date__c != null && (mapIRSAWithStaffMember.get(sA.Staff_Member__c).Start_Date__c == null
                            || sA.Start_Date__c > mapIRSAWithStaffMember.get(sA.Staff_Member__c).Start_Date__c))
                            mapIRSAWithStaffMember.put(sA.Staff_Member__c, sA);                 
                    }   
                
                //If selected option if other than business title
                } else  {
                    
                    //Check for start date
                    if(sA.Start_Date__c != null && (mapIRSAWithStaffMember.get(sA.Staff_Member__c).Start_Date__c == null
                        || sA.Start_Date__c > mapIRSAWithStaffMember.get(sA.Staff_Member__c).Start_Date__c))
                        mapIRSAWithStaffMember.put(sA.Staff_Member__c, sA);
                }
            }
            
            //Check for Payee
            if(!mapAvailablePayees.containsKey(sA.Staff_Member__c) && !setSelectedPayeesIds.contains(sA.Staff_Member__c)) {
                
                //Populate Wrapper
                if(sA.Value_Type__c != null)
                    mapAvailablePayees.put(sA.Staff_Member__c, new PayeesWrapper(sA.Staff_Member__r.Name,
                                                            sA.Value_Type__r.Name == ISSPConstants.VALUE_TYPE_NAME_JOB_TITLE ? sA.Value__c : '',
                                                            '',
                                                            '',
                                                            null,
                                                            sA.Value_Type__r.Name == ISSPConstants.VALUE_TYPE_NAME_TENURE && sA.Value_Type__r.Category__c == ISSPConstants.VALUE_TYPE_CATEGORY_OTHER ? 'Yes' : 'No',
                                                            sA.Value_Type__r.Name == ISSPConstants.VALUE_TYPE_NAME_TENURE && sA.Value_Type__r.Category__c == ISSPConstants.VALUE_TYPE_CATEGORY_OTHER ? sA.Percent_Value__c > 0 ? sA.Percent_Value__c : sA.Value_Type__r.Adjustment__c : null,
                                                            setPGPayeeIds.contains(sA.Staff_Member__c) ? 'Yes' : 'No', sA.Staff_Member__c,
                                                            sA.Value_Type__r.Category__c == ISSPConstants.VALUE_TYPE_CATEGORY_BUSINESS_TITLE ? sA.Value_Type__c : null,
                                                            sA.Value_Type__r.Name == ISSPConstants.VALUE_TYPE_NAME_TENURE && sA.Value_Type__r.Category__c == ISSPConstants.VALUE_TYPE_CATEGORY_OTHER ? sA.Id : null,
                                                            sA.Staff_Member__r.Function__c));
                
                else if(!setSelectedPayeesIds.contains(sA.Staff_Member__c))
                    mapAvailablePayees.put(sA.Staff_Member__c, new PayeesWrapper(sA.Staff_Member__r.Name, '', '','', null, 'No', null,
                                            setPGPayeeIds.contains(sA.Staff_Member__c) ? 'Yes' : 'No', sA.Staff_Member__c, null, null,
                                            sA.Staff_Member__r.Function__c));                                      
            
            } else if(mapAvailablePayees.containsKey(sA.Staff_Member__c) && sA.Value_Type__c != null) {
            
                //Check for Value Type
                if(sA.Value_Type__r.Name == ISSPConstants.VALUE_TYPE_NAME_JOB_TITLE)
                    mapAvailablePayees.get(sA.Staff_Member__c).title = sA.Value__c;
              /*  else if(sA.Value_Type__r.Category__c == ISSPConstants.VALUE_TYPE_CATEGORY_INCENTIVE_ROLE)
                    mapAvailablePayees.get(sA.Staff_Member__c).incentiveRole = sA.Value__c;
                else if(sA.Value_Type__r.Category__c == ISSPConstants.VALUE_TYPE_CATEGORY_BUSINESS_TITLE) {
                    
                    mapAvailablePayees.get(sA.Staff_Member__c).businessTitle = sA.Value__c;
                    mapAvailablePayees.get(sA.Staff_Member__c).businessTitlePercent = sA.Value_Type__r.Adjustment__c;
                
                }*/ else if(sA.Value_Type__r.Name == ISSPConstants.VALUE_TYPE_NAME_TENURE && sA.Value_Type__r.Category__c == ISSPConstants.VALUE_TYPE_CATEGORY_OTHER) {
                    
                    mapAvailablePayees.get(sA.Staff_Member__c).tenured = 'Yes';
                    mapAvailablePayees.get(sA.Staff_Member__c).tenuredPercent = sA.Percent_Value__c > 0 ? sA.Percent_Value__c : sA.Value_Type__r.Adjustment__c;
                    mapAvailablePayees.get(sA.Staff_Member__c).staffAttributeId = sA.Id;
                }
            }
        }
       
        //Loop through the staff memeber map key set
        for(Id sMId : mapAvailablePayees.keySet()) {
            
            //Check the Staff member id in map
            if(mapBTSAWithStaffMember.containsKey(sMId)) {
                
                mapAvailablePayees.get(sMId).businessTitle = mapBTSAWithStaffMember.get(sMId).Value__c;
                    mapAvailablePayees.get(sMId).businessTitlePercent = mapBTSAWithStaffMember.get(sMId).Value_Type__r.Adjustment__c;
            }
            
            //Check the Staff member id in map
            if(mapIRSAWithStaffMember.containsKey(sMId))
                mapAvailablePayees.get(sMId).incentiveRole = mapIRSAWithStaffMember.get(sMId).Value__c;
        }
        
        //Return
        return mapAvailablePayees;  
    }
    
    /**
     *  @description    :   This method is used to add Payee in selected Payees list and remove from available Payees list
     *
     *  @args           :   
     *
     *  @return         :   void
     *
     **/
    public void selectPayee() {
        
        //Initilize the properties
        selectedPeriod = '';
        createPGSecWrapper = new List<CreatePersonalGoalsSectionWrapper>();
        mapBTIdWIthPayeeId = new Map<String,String>();
        
        //Temp list of Available Payee
        List<PayeesWrapper> tempAvailablePayees = new List<PayeesWrapper>();
        
        //Loop through Payees Wrapper
        for(PayeesWrapper pW : availablePayees) {
            
            //Check for selected Payee
            if(!pW.selected)
                tempAvailablePayees.add(pW);
            else {
                
                //Uncheck the selected checkbox
                pW.selected = false;
                
                //Add Payee in selected payee list
                selectedPayees.add(pW);
                
                //Add Payee Id in set to avoid duplicate add
                setSelectedPayeesIds.add(pW.contactId);
                
                //Add Business Title Id in set
                if(String.isNotBlank(pW.businessTitleId))
                    mapBTIdWIthPayeeId.put(pW.businessTitleId, pW.contactId);
            }
        }
        //Populate Availabe Payees List
        availablePayees = tempAvailablePayees;
        //Short the Selected payee list
        selectedPayees.sort();
    }
    
    /**
     *  @description    :   This method is used to remove selected Payees from selected Payees list
     *
     *  @args           :   
     *
     *  @return         :   void
     *
     **/
    public void removeSelectedPayee() {
        
        //Temp list of Selected Payee
        List<PayeesWrapper> tempSelectedPayees = new List<PayeesWrapper>();
        
        //Loop through selected Payees
        for(PayeesWrapper pW : selectedPayees) {
            
            //Check for selected Payee
            if(pW.selected) {
                
                //Uncheck the selected checkbox
                pW.selected = false;
                
                //Add Payees back to Available list
                availablePayees.add(pW);
                
                //Remove Payee from list
                setSelectedPayeesIds.remove(pW.contactId);
                
                //Remove Payee from the business title map
                if(String.isNotBlank(pW.businessTitleId) && mapBTIdWIthPayeeId.containsKey(pW.businessTitleId))
                    mapBTIdWIthPayeeId.remove(pW.businessTitleId);
                    
            }else
                tempSelectedPayees.add(pW);
        }
        
        //Populate selected Payees list
        selectedPayees = tempSelectedPayees;
        createPGSecWrapper = new List<CreatePersonalGoalsSectionWrapper>();
        selectAll = false;
        
        //Added By - Rajeev Jain - 11/13 - Resolve Payee Issue list and Enhancment - To Sort by LastName for Available Payees List
        availablePayees.sort();
    }
    
    /**
     *  @description    :   This method is used to draw the Create Personal Goals section, when user selected any period
     *
     *  @args           :   
     *
     *  @return         :   void
     *
     **/
    public void drawCreatePersonalGoalSection() {
        
        //Re-Initilize
        stdGoalDetails = new List<StdGoalDetailWrapper>();
        Map<Id, StdGoalDetailWrapper> mapStdGoalDetails = new Map<Id, StdGoalDetailWrapper>();
        createPGSecWrapper = new List<CreatePersonalGoalsSectionWrapper>();
        selectAll = false;
        mapGTDMPeriods = new Map<Id, List<Goal_Template_Detail_Measurement_Period__c>>();
        mapExistingProposals = new Map<Id,Id>();
        mapPGMPGoingToDelete = new Map<Id, List<Personal_Goal_Measurement_Period__c>>();
        mapSSIdWIthPPCounter = new Map<Id, Decimal>();
        
        //V_1.5 - Modified - Rajeev Jain - 03/29/2016 - CR-20160316-9699 - ISSP SFDC Critical NBB Calculation Fixes - QA Fixes
        //Map to hold the Best Businees Title Properties corrosponding to each payee Id
        Map<Id, PayeeBusinessTitleWrapper> mapPayeeBusinessTitleData = new Map<Id, PayeeBusinessTitleWrapper>();
        
        //V_1.8 - Modified - Rajeev Jain - 05/04/2016 - CR-20160421-9789 
        //Map to hold the GoalType Business Title' Adjustment Value corrosponding to its Goal Type Id
        Map<Id, List<Goal_Type_Business_Title__c>> mapAdjustmentValueWithGTBT = new Map<Id, List<Goal_Type_Business_Title__c>>();
        
        //Map to hold Default Busines Title, we can use those titles if criteria based business Title not found
        Map<Id, String> mapDefaultBusinessTitleData = new Map<Id, String>();
        
        //V_1.8 - Modified - Rajeev Jain - 05/04/2016 - CR-20160421-9789 - Upto here
               
        //Check for selected Period
        if(String.isNotBlank(selectedPeriod)) {
            
            //Set to hold the goal type id
            //This set is used to fetch the business title multiplier for each std goal
            Set<Id> setGoalTypeId = new Set<Id>();
            
            //Set to hold Contact (Payees) Ids
            Set<Id> setConIds = new Set<Id>();
            
            //Map to hold Contact Id with Personal Goals (This map will use to display existing personal goals)
            Map<Id, List<Personal_Goal__c>> mapPersonalGoals = new Map<Id, List<Personal_Goal__c>>();
            
            //Map to hold the Id of SGDP corropsonding to its Personal Goal
            Map<String, Personal_Goal__c> mapPgsWithPacingIds = new Map<String, Personal_Goal__c>();
            
            //Map to Payee Id as key and Map of Std Id and List of Pacings as value
            Map<Id, Map<Id, List<CreatePersonalGoalsSectionWrapper.StdGoalDetailPacingWrapper>>> mapStdGoalPacings = new Map<Id, Map<Id, List<CreatePersonalGoalsSectionWrapper.StdGoalDetailPacingWrapper>>>();
            
            //Map to hold the Personal Goal Id with list of PGMPs
            Map<Id, List<Personal_Goal_Measurement_Period__c>> mapPGMPWithPGIds = new Map<Id, List<Personal_Goal_Measurement_Period__c>>();
            
            //Map to hold the Personal Goal Id with set of Personal Goal Relationship Ids
            Map<Id, Set<Id>> mapPGRelationshipsWithPGId = new Map<Id, Set<Id>>();
            
            //Map to hold the Personal Goal Id with Map of SR Id and PGMP Id
            Map<Id, Map<Id,Id>> mapPGIdWithSRIdAndPGMPIds = new Map<Id, Map<Id,Id>>();
            
            //Variables to hold Selected Period Start and End Dates
            Date periodStart = mapStdGoalDetailPacings.containsKey(selectedPeriod) ? mapStdGoalDetailPacings.get(selectedPeriod).Period_Start__c : null;
            Date periodEnd = mapStdGoalDetailPacings.containsKey(selectedPeriod) ? mapStdGoalDetailPacings.get(selectedPeriod).Period_End__c : null;
            
            //Query through the GTDMPs
            for(Goal_Template_Detail_Measurement_Period__c gTDMP : [Select Id, Measurement_Date__c, Goal_Template_Detail__c From
                                                                    Goal_Template_Detail_Measurement_Period__c Where
                                                                    Goal_Template_Detail__r.Standard_Goal__c =: stdPersonalGoal.Standard_Goal__c
                                                                    ORDER BY Measurement_Date__c ASC]) {
                                                                        
                //Check for GTD
                if(!mapGTDMPeriods.containsKey(gTDMP.Goal_Template_Detail__c))
                    mapGTDMPeriods.put(gTDMP.Goal_Template_Detail__c, new List<Goal_Template_Detail_Measurement_Period__c>());
                
                //Add GTDMP in list
                mapGTDMPeriods.get(gTDMP.Goal_Template_Detail__c).add(gTDMP);                                                               
            }
            
            //Loop through the Std goal detail
            for(Standard_Goal_Detail__c sGD : [Select Id, Description__c, Goal_Type__c, Name, Goal_Type__r.Discount_Type__c,  
                                                      (Select Id From Conditions__r LIMIT 1), (Select Id From Goal_Template_Detail_Measurement_Periods__r LIMIT 1)
                                                        From Standard_Goal_Detail__c
                                                      Where Standard_Goal__c =: stdPersonalGoal.Standard_Goal__c]) {
                
                //Condition flag
                Boolean hasCons = sGD.Conditions__r.size() > 0 ? true : false;
                Boolean hasGTDMPs = sGD.Goal_Template_Detail_Measurement_Periods__r.size() > 0 ? true : false; 
                
                //Add GTD details in map
                mapStdGoalDetails.put(sGD.Id, new StdGoalDetailWrapper(sGD.Description__c, sGD.Id, hasCons, hasGTDMPs));
                
                //Check for Target Type showMultiplier
                if(sGD.Goal_Type__c != null
                    && sGD.Goal_Type__r.Discount_Type__c == ISSPConstants.GOAL_TYPE_DISCOUNT_TYPE_MULTIPLIERS)
                    showMultiplier = true;
                
                //Check for goal type
                if(sGD.Goal_Type__c != null)
                    setGoalTypeId.add(sGD.Goal_Type__c);                                    
            }
            
            //Re-Initilize map
            mapPayeeIdWithBTMultiplier = new Map<String, Decimal>();
            
            //V_1.8 - Modified - Rajeev Jain - 05/04/2016 - CR-20160421-9789
            //Loop through the Goal Type Business Title to get selectd business title multiplier
            for(Goal_Type_Business_Title__c gTBT : [Select Id, Adjustment__c,Goal_Type__c, Business_Title__c, Business_Title__r.Name From Goal_Type_Business_Title__c
                                                            Where Goal_Type__c IN : setGoalTypeId AND Adjustment__c != null AND Adjustment__c > 0 order by CreatedDate]) {    
                //Populate map
                /*if(mapBTIdWIthPayeeId.containsKey(gTBT.Business_Title__c))
                    mapPayeeIdWithBTMultiplier.put(mapBTIdWIthPayeeId.get(gTBT.Business_Title__c) + '-' + gTBT.Goal_Type__c, gTBT.Adjustment__c);*/ 
                  if(!mapAdjustmentValueWithGTBT.containsKey(gTBT.Goal_Type__c))
                    mapAdjustmentValueWithGTBT.put(gTBT.Goal_Type__c, new List<Goal_Type_Business_Title__c>());
                  
                  mapAdjustmentValueWithGTBT.get(gTBT.Goal_Type__c).add(gTBT);
            }
            //V_1.8 - Modified - Rajeev Jain - 05/04/2016 - CR-20160421-9789 - Upto here
            
            //Loop through the selected Payees
            for(PayeesWrapper pW : selectedPayees) {
                
                //Add Contact Id in set
                setConIds.add(pW.contactId);
                
                mapDefaultBusinessTitleData.put(pW.contactId, pW.businessTitle);
                
                //Populate map
                mapStdGoalPacings.put(pW.contactId, new Map<Id, List<CreatePersonalGoalsSectionWrapper.StdGoalDetailPacingWrapper>>());
            }
            
            //V_1.5 - Modified - Rajeev Jain - 03/29/2016 - CR-20160316-9699 - ISSP SFDC Critical NBB Calculation Fixes - QA Fixes   
            for(Staff_History__c sA : [Select Id, Staff_Member__c, Staff_Member__r.Name, Start_Date__c, End_Date__c, Value__c, Value_Type__c, 
                                                Value_Type__r.Name, Value_Type__r.Adjustment__c
                                                  From Staff_History__c Where Staff_Member__c IN : setConIds 
                                                  AND Start_Date__c != null AND Start_Date__c <= :periodStart AND(End_Date__c = NULL OR End_Date__c >= :periodStart) AND Value_Type__r.Category__c =: ISSPConstants.VALUE_TYPE_CATEGORY_BUSINESS_TITLE
                                                  ORDER BY Start_Date__c ASC NULLS LAST]) {
                
                //Check for Payee Id
                if(!mapPayeeBusinessTitleData.containsKey(sA.Staff_Member__c)){
                    mapPayeeBusinessTitleData.put(sA.Staff_Member__c, new PayeeBusinessTitleWrapper(sA.Value_Type__r.Name, sA.Value_Type__r.Adjustment__c, sA.Start_Date__c));
                }
            }
            
            //Map to hold the Payee Id as key and list of corresponding Staff Attributes as value
            Map<Id, List<Staff_History__c>> mapPayeeWithSAs = new Map<Id, List<Staff_History__c>>();
            
            //Query through the Staff Attributes
            for(Staff_History__c sA : [Select Id, Staff_Member__c, Start_Date__c, End_Date__c, Value__c, Value_Type__c, Value_Type__r.Name
                                                  From Staff_History__c Where Staff_Member__c IN : setConIds
                                                  AND Value_Type__r.Category__c =: ISSPConstants.VALUE_TYPE_CATEGORY_BUSINESS_TITLE
                                                  ORDER BY End_Date__c ASC NULLS LAST]) {
                                                    
                //Check for Payee Id
                if(!mapPayeeWithSAs.containsKey(sA.Staff_Member__c))
                    mapPayeeWithSAs.put(sA.Staff_Member__c, new List<Staff_History__c>());
                
                //Add Staff Attribute record in map
                mapPayeeWithSAs.get(sA.Staff_Member__c).add(sA);
            } 
                
            //SOQL String to query on Personal Goal
            String pGSOQL = 'Select ';
            
            //Sobject getDescribe method to fatch all the Personal goal fields and add fields in SOQL query string
            for(String pGF : Personal_Goal__c.getSobjectType().getDescribe().fields.getMap().KeySet())
                pGSOQL += pGF + ',';
            
            //Add Where clouse
            pGSOQL = pGSOQL.removeEnd(',') + ' From Personal_Goal__c Where RecordType.DeveloperName = \'Personal_Goal\' AND Status__c != \'Void\' AND Payee__c IN : setConIds AND Standard_Goal__c = \''
                     + stdPersonalGoal.Standard_Goal__c + '\'';
        
            //Query through the Personal Goals
            for(Personal_Goal__c pG : Database.query(pGSOQL)) {
                                            
                //Personal Goal map with payees
                if(!mapPersonalGoals.containsKey(pG.Payee__c))
                    mapPersonalGoals.put(pG.Payee__c, new List<Personal_Goal__c>());
                
                //Put Personal Goal
                mapPersonalGoals.get(pG.Payee__c).add(pG);
                
                String unKey = pG.Payee__c + '-' + pG.Standard_Goal_Detail__c;
                
                if(!mapPgsWithPacingIds.containsKey(unKey))
                    mapPgsWithPacingIds.put(unKey, pG);
               
                //Populate PGMP map with PG
                mapPGMPWithPGIds.put(pG.Id, new List<Personal_Goal_Measurement_Period__c>()); 
                
                //Populate the PGR map
                mapPGRelationshipsWithPGId.put(pG.Id, new Set<Id>());  
                
                //Populate the PGMP Ids
                mapPGIdWithSRIdAndPGMPIds.put(pG.Id, new Map<Id,Id>());                               
            }
            
            //Loop through the Proposed Goals to get the Proposal Counter
            for(Personal_Goal__c pG : [Select Id, Proposal_Counter__c, Primary_Goal__c From Personal_Goal__c Where RecordType.DeveloperName =: ISSPConstants.PERSONAL_GOAL_RECORD_TYPE_PROPOSAL
                                                                                                    AND Primary_Goal__c IN : mapPGMPWithPGIds.keySet()
                                                                                                    ORDER BY Proposal_Counter__c DESC]) {
                
                //Check for Primary Goal Id in map
                if(!mapSSIdWIthPPCounter.containsKey(pG.Primary_Goal__c))
                    mapSSIdWIthPPCounter.put(pG.Primary_Goal__c, pG.Proposal_Counter__c);
                                                                                                            
            }
            
            //Query through the Proposed Goals
            for(Personal_Goal__c pG : [Select Id, Primary_Goal__c, Primary_Goal__r.Active_Proposal__c,Goal_Type_Business_Title__c From Personal_Goal__c Where
                                        RecordType.DeveloperName =: ISSPConstants.PERSONAL_GOAL_RECORD_TYPE_PROPOSAL
                                        AND Primary_Goal__c IN : mapPGMPWithPGIds.keySet()
                                            AND Status__c IN  (:ISSPConstants.PERSONAL_GOAL_STATUS_AVAILABLE, :ISSPConstants.PERSONAL_GOAL_STATUS_SUBMITTED)]) {
                                            
                //Check for Active Proposal
                if(pG.Primary_Goal__c != null && pG.Id != pG.Primary_Goal__r.Active_Proposal__c)
                    mapExistingProposals.put(pG.Primary_Goal__c, pG.Id);
            }
            
            //Query through the Personal Goal Measurement Periods
            for(Personal_Goal_Measurement_Period__c pGMP : [Select Id, Measurement_Date__c, Personal_Goal__c From Personal_Goal_Measurement_Period__c
                                                                   Where Personal_Goal__c IN : mapPGMPWithPGIds.keySet() AND Measurement_Date__c != null
                                                                   ORDER BY Measurement_Date__c ASC]) {
                                                                    
                //Add PGMP in the map
                mapPGMPWithPGIds.get(pGMP.Personal_Goal__c).add(pGMP);
            }
            
            //Query through the Personal Goal Relationships
            for(Personal_Goal_Relationship__c pGR : [Select Id, Relationship__c, Personal_Goal__c From Personal_Goal_Relationship__c
                                                                   Where Personal_Goal__c IN : mapPGRelationshipsWithPGId.keySet() AND Relationship__c != null]) {
                                                                    
                //Add PGR in map
                mapPGRelationshipsWithPGId.get(pGR.Personal_Goal__c).add(pGR.Relationship__c);
                
                //Popuate PGR map with SR
                mapPGIdWithSRIdAndPGMPIds.get(pGR.Personal_Goal__c).put(pGR.Relationship__c, pGR.Id);
            }
            
            
            //Map to hold Standard Goal Detail Id with List of Standard Goal Detail Pacings
            Map<Id, List<Standard_Goal_Detail_Pacing__c>> mapStdGDIdWithStdGSDPacings = new Map<Id, List<Standard_Goal_Detail_Pacing__c>>();
            
            /***********      This code is used for Tooltip        *********/
            //Map to hold Unique Key of Payee Id and Std Goal Detail with appropriate tooltip
            Map<String, String> mapToolTip = new Map<String, String>();
            
            //Map to hold Std Goal detail with Pacings
            Map<Id, List<Standard_Goal_Detail_Pacing__c>> mapTTStdGDWithPacings = new Map<Id, List<Standard_Goal_Detail_Pacing__c>>();
            
            //Check for Show earlier and later options
            if(!showEarlier || !showLater) {
                
                //SOQL String
                String toolTipSOQL = 'Select Id, Name, Description__c, Standard_Goal__c, Standard_Goal_Detail__c, Standard_Goal_Detail__r.Goal_Type__c,'
                                     + 'Standard_Goal_Detail__r.Goal_Type__r.Name, Amount__c, Standard_Goal_Detail__r.Name, Standard_Goal_Detail__r.Description__c,'
                                     + 'Period_Start__c,' + 'Period_End__c,Standard_Goal_Detail__r.Standard_Goal__c From Standard_Goal_Detail_Pacing__c '
                                     + 'Where Standard_Goal_Detail__r.Standard_Goal__c = \'' + stdPersonalGoal.Standard_Goal__c + '\' AND ';
               
                //Check for Show earlier and later options
                if(!showEarlier && !showLater)
                    toolTipSOQL = toolTipSOQL + 'Period_Start__c !=: periodStart';
                else if(showEarlier && !showLater)
                    toolTipSOQL = toolTipSOQL + 'Period_Start__c >: periodStart';
                else if(!showEarlier && showLater)
                    toolTipSOQL = toolTipSOQL + 'Period_Start__c <: periodStart';
                
                //Query through Std Goal detail Pacing
                for(Standard_Goal_Detail_Pacing__c sGDP : Database.query(toolTipSOQL)) {
                    
                    //Populate map
                    if(!mapTTStdGDWithPacings.containsKey(sGDP.Standard_Goal_Detail__c))
                        mapTTStdGDWithPacings.put(sGDP.Standard_Goal_Detail__c, new List<Standard_Goal_Detail_Pacing__c>());
                    
                    //Add Pacing record in map
                    mapTTStdGDWithPacings.get(sGDP.Standard_Goal_Detail__c).add(sGDP);
                }
                
                //Loop over the Selected Payyes
                for(PayeesWrapper pW : selectedPayees) {
                    
                    //Loop through the Std Goal Map
                    for(Id sGDId : mapTTStdGDWithPacings.keySet()) {
                        
                        //Unique Key
                        String uniqueKey = pW.contactId + '-' + sGDId;
                            
                        //Loop through the Pacings
                        for(Standard_Goal_Detail_Pacing__c sGDP : mapTTStdGDWithPacings.get(sGDId)) {
                            
                            //Boolean Variable to check is there any Personal goal for given pacing
                            Boolean isPG = false;
                                
                            //Check for Personal Goals for this payee
                            if(mapPersonalGoals.containsKey(pW.contactId)) {
                                
                                //Loop through the Personal Goals
                                for(Personal_Goal__c pG : mapPersonalGoals.get(pW.contactId)) {
                                    
                                    //Check for Std Goal detail and Dates
                                    if(pG.Standard_Goal_Detail__c == sGDP.Standard_Goal_Detail__c && pG.Period_Start__c == sGDP.Period_Start__c
                                        && pG.Period_End__c == sGDP.Period_End__c) {
                                        
                                        //Set flag to true
                                        isPG = true;
                                        
                                        //PG Values
                                        String pGValue = pG.Value__c != null ? pG.Value__c : '';
                                        
                                        //Check if map contains Unique Key
                                        if(!mapToolTip.containsKey(uniqueKey)) {
                                            
                                            //Variable to add in map as value
                                            String ttValue = '<B>' + sGDP.Standard_Goal_Detail__r.Description__c + ' History </B><BR></BR>'
                                                            + sGDP.Description__c + ': ' + pGValue;
                                            
                                            //Populate map
                                            mapToolTip.put(uniqueKey, ttValue);
                                        } else {
                                            
                                            //Variable to add in map as key
                                            String ttValue = mapToolTip.get(uniqueKey) + '<BR></BR>' + sGDP.Description__c + ': ' + pGValue;
                                            
                                            //Populate map
                                            mapToolTip.put(uniqueKey, ttValue); 
                                        }
                                        
                                        break;
                                    }
                                }
                            }  
                            
                            //Add only Pacing description in case of only pacing
                            if(!mapPersonalGoals.containsKey(pW.contactId) || !isPG) {
                                
                                if(!mapToolTip.containsKey(uniqueKey)) {
                                
                                    //Variable to add in map as value
                                    String ttValue = '<B>' + sGDP.Standard_Goal_Detail__r.Description__c + ' History</B><BR></BR>'
                                                    + sGDP.Description__c + ': '; 
                                    
                                    //Populate map
                                    mapToolTip.put(uniqueKey, ttValue);
                                } else {
                                    
                                    //Variable to add in map as key
                                    String ttValue = mapToolTip.get(uniqueKey) + '<BR></BR>' + sGDP.Description__c + ': ';
                                    
                                    //Populate map
                                    mapToolTip.put(uniqueKey, ttValue);
                                }
                            }
                        }
                    }   
                }
            }
            
            /********************          End            ***********************/
            
            /********************    This code is used to build the Create Personal Goals list     ***************/    
            
            //SOQL String
            String SOQL = 'Select Id, Name, Description__c, Standard_Goal__c, Standard_Goal_Detail__c, Standard_Goal_Detail__r.Description__c, Standard_Goal_Detail__r.Goal_Type__c,'
                         + 'Standard_Goal_Detail__r.Goal_Type__r.Name, Amount__c, Standard_Goal_Detail__r.Name, Period_Start__c, Period_End__c, '
                         + 'Amount_Manual__c, Count_Manual__c, Percent_Manual__c, Standard_Goal_Detail__r.Target_Type__c, Count__c, Percent__c, '
                         + 'Standard_Goal_Detail__r.Goal_Type__r.Discount_Type__c,Standard_Goal_Detail__r.Summary__c,Standard_Goal_Detail__r.Goal_Type__r.Discount__c,'
                         + 'Standard_Goal_Detail__r.Baseline__c, Standard_Goal_Detail__r.Goal_Type__r.Minimum__c, Standard_Goal_Detail__r.Baseline_Percentage__c, '
                         + 'Standard_Goal_Detail__r.Weighting__c, Standard_Goal_Detail__r.Condition_Handling__c, Standard_Goal_Detail__r.Period__c, '
                         + 'Standard_Goal_Detail__r.Baseline__r.Amount__c, Standard_Goal_Detail__r.Baseline__r.Count__c, Standard_Goal_Detail__r.Baseline__r.Percent__c, Standard_Goal_Detail__r.Baseline__r.Description__c, '
                         + 'Standard_Goal_Detail__r.Baseline__r.Period_Start__c, Standard_Goal_Detail__r.Period_Start__c, Standard_Goal_Detail__r.Value_Type__c, Standard_Goal_Detail__r.Amount__c, Standard_Goal_Detail__r.Count__c, Standard_Goal_Detail__r.Percent__c, Standard_Goal_Detail__r.Parent__r.Period_Start__c, '
                         + 'Standard_Goal_Detail__r.Parent__c, Standard_Goal_Detail__r.Discount__c, Standard_Goal_Detail__r.Minimum__c, Standard_Goal_Detail__r.Standard_Goal__c '
                         + 'From Standard_Goal_Detail_Pacing__c Where Standard_Goal_Detail__r.Standard_Goal__c = \'' + stdPersonalGoal.Standard_Goal__c + '\' AND ';
            
            //Check for Show earlier and later options
            /*if(!showEarlier && !showLater)
                SOQL = SOQL + 'Period_Start__c =: periodStart';
            else if(showEarlier && !showLater)
                SOQL = SOQL + 'Period_Start__c <=: periodStart';
            else if(!showEarlier && showLater)
                SOQL = SOQL + 'Period_Start__c >=: periodStart';
           */ 
            SOQL = SOQL.removeEnd(' AND ') + ' ORDER BY Period_Start__c ASC, Period_End__c ASC';
            
            //SOQL String
            String maxRowSOQL = 'Select Id, Name, Description__c, Standard_Goal__c, Standard_Goal_Detail__c, Standard_Goal_Detail__r.Description__c, Standard_Goal_Detail__r.Goal_Type__c,'
                         + 'Standard_Goal_Detail__r.Goal_Type__r.Name, Amount__c, Standard_Goal_Detail__r.Name, Period_Start__c, Period_End__c, '
                         + 'Amount_Manual__c, Count_Manual__c, Percent_Manual__c, Standard_Goal_Detail__r.Target_Type__c, Count__c, Percent__c, '
                         + 'Standard_Goal_Detail__r.Goal_Type__r.Discount_Type__c,Standard_Goal_Detail__r.Summary__c,Standard_Goal_Detail__r.Goal_Type__r.Discount__c,'
                         + 'Standard_Goal_Detail__r.Baseline__c, Standard_Goal_Detail__r.Goal_Type__r.Minimum__c, Standard_Goal_Detail__r.Baseline_Percentage__c, '
                         + 'Standard_Goal_Detail__r.Weighting__c, Standard_Goal_Detail__r.Condition_Handling__c, Standard_Goal_Detail__r.Period__c, '
                         + 'Standard_Goal_Detail__r.Baseline__r.Amount__c, Standard_Goal_Detail__r.Baseline__r.Count__c, Standard_Goal_Detail__r.Baseline__r.Percent__c, Standard_Goal_Detail__r.Baseline__r.Description__c, '
                         + 'Standard_Goal_Detail__r.Baseline__r.Period_Start__c, Standard_Goal_Detail__r.Period_Start__c, Standard_Goal_Detail__r.Value_Type__c, Standard_Goal_Detail__r.Amount__c, Standard_Goal_Detail__r.Count__c, Standard_Goal_Detail__r.Percent__c, Standard_Goal_Detail__r.Parent__r.Period_Start__c, '
                         + 'Standard_Goal_Detail__r.Parent__c, Standard_Goal_Detail__r.Discount__c, Standard_Goal_Detail__r.Minimum__c, Standard_Goal_Detail__r.Standard_Goal__c '
                         + 'From Standard_Goal_Detail_Pacing__c Where Standard_Goal_Detail__r.Standard_Goal__c = \'' + stdPersonalGoal.Standard_Goal__c + '\' AND ';
            
            //Check for Show earlier and later options
            if(!showEarlier && !showLater)
                maxRowSOQL = maxRowSOQL + 'Period_Start__c =: periodStart';
            else if(showEarlier && !showLater)
                maxRowSOQL = maxRowSOQL + 'Period_Start__c <=: periodStart';
            else if(!showEarlier && showLater)
                maxRowSOQL = maxRowSOQL + 'Period_Start__c >=: periodStart';
           
           maxRowSOQL = maxRowSOQL.removeEnd(' AND ') + ' ORDER BY Period_Start__c ASC, Period_End__c ASC';
            
            //Set to hold Std Goal Detail Id
            Set<Id> setSGDIds = new Set<Id>();
            
            //Query through Standard Goal Detail Pacings
            for(Standard_Goal_Detail_Pacing__c sGDP : Database.query(SOQL)) {
                
                //Check for std goal detail Id in set and map
                if(!setSGDIds.contains(sGDP.Standard_Goal_Detail__c) && mapStdGoalDetails.containsKey(sGDP.Standard_Goal_Detail__c)) {
                    
                    //Populate Headers list
                    stdGoalDetails.add(mapStdGoalDetails.get(sGDP.Standard_Goal_Detail__c));
                    
                    //Remove SGD from map
                    mapStdGoalDetails.remove(sGDP.Standard_Goal_Detail__c);
                }
                    
                //Add Std Gaol Detail Id
                setSGDIds.add(sGDP.Standard_Goal_Detail__c);
                    
                //Check Std Goal Detail Id in map
                if(!mapStdGDIdWithStdGSDPacings.containsKey(sGDP.Standard_Goal_Detail__c))
                    mapStdGDIdWithStdGSDPacings.put(sGDP.Standard_Goal_Detail__c, new List<Standard_Goal_Detail_Pacing__c>());
                
                //Add Std Goal Detail Pacing in map
                mapStdGDIdWithStdGSDPacings.get(sGDP.Standard_Goal_Detail__c).add(sGDP);
            
            }
            
            //Map to hold Standard Goal Detail Id with List of Standard Goal Detail Pacings
            Map<Id, List<Standard_Goal_Detail_Pacing__c>> mapMaxRowStdGDIdWithStdGSDPacings = new Map<Id, List<Standard_Goal_Detail_Pacing__c>>();
            
            //Query through Standard Goal Detail Pacings
            for(Standard_Goal_Detail_Pacing__c sGDP : Database.query(maxRowSOQL)) {
                
                //Check Std Goal Detail Id in map
                if(!mapMaxRowStdGDIdWithStdGSDPacings.containsKey(sGDP.Standard_Goal_Detail__c))
                    mapMaxRowStdGDIdWithStdGSDPacings.put(sGDP.Standard_Goal_Detail__c, new List<Standard_Goal_Detail_Pacing__c>());
                
                //Add Std Goal Detail Pacing in map
                mapMaxRowStdGDIdWithStdGSDPacings.get(sGDP.Standard_Goal_Detail__c).add(sGDP);
            
            }
            //Max Row Size
            Integer maxRows = 0;
            
            //Loop through map key Set
            for(Id stdGDId : mapMaxRowStdGDIdWithStdGSDPacings.keySet()) {
                
                //Check for size
                if(mapMaxRowStdGDIdWithStdGSDPacings.get(stdGDId).size() > maxRows)
                    //Assign values
                    maxRows = mapMaxRowStdGDIdWithStdGSDPacings.get(stdGDId).size();
            }
            
            //Map to hold Payee Id with Peronal Goal's Percent field value
            Map<Id, Decimal> mapPGSalesPercent = new Map<Id, Decimal>();
            
            //Temp Map to hold the Map to Payee Id as key and Map of Std Id and List of Pacings as value
            Map<Id, Map<Id, List<CreatePersonalGoalsSectionWrapper.StdGoalDetailPacingWrapper>>> mapTempStdGoalPacings = new Map<Id, Map<Id, List<CreatePersonalGoalsSectionWrapper.StdGoalDetailPacingWrapper>>>();
            
            //Loop through Payees
            for(Id payeeId : mapStdGoalPacings.keySet()) {
                
                //Map to hold Std Goal detail Id with List of Pacing Wrapper
                Map<Id, List<CreatePersonalGoalsSectionWrapper.StdGoalDetailPacingWrapper>> mapStdGDIdWithPacings = mapStdGoalPacings.get(payeeId);
                
                //Check payee Id in map
                if(!mapTempStdGoalPacings.containsKey(payeeId))
                    mapTempStdGoalPacings.put(payeeId, new Map<Id, List<CreatePersonalGoalsSectionWrapper.StdGoalDetailPacingWrapper>>());
                
                //Temp map to hold the extra Pacings
                Map<Id, List<CreatePersonalGoalsSectionWrapper.StdGoalDetailPacingWrapper>> mapTempStdGDIdWithPacings = mapTempStdGoalPacings.get(payeeId);
            
                //Loop through map key Set
                for(Id stdGDId : mapStdGDIdWithStdGSDPacings.keySet()) {
                    
                    //Populate map
                    if(!mapStdGDIdWithPacings.containsKey(stdGDId))
                        mapStdGDIdWithPacings.put(stdGDId, new List<CreatePersonalGoalsSectionWrapper.StdGoalDetailPacingWrapper>());
                    
                    //Populate temp map
                    if(!mapTempStdGDIdWithPacings.containsKey(stdGDId))
                        mapTempStdGDIdWithPacings.put(stdGDId, new List<CreatePersonalGoalsSectionWrapper.StdGoalDetailPacingWrapper>());
                        
                    //Loop through Pacings
                    for(Standard_Goal_Detail_Pacing__c sGDP : mapStdGDIdWithStdGSDPacings.get(stdGDId)) {
                        
                        //Variable to controle the display of value fields on the VF page
                        Boolean displayAmount = false;
                        Boolean displayCount = false;
                        Boolean displayPercent = false;
                         
                        //Check for Amount
                        if((sGDP.Amount__c != null && sGDP.Amount__c > 0) || (sGDP.Amount__c != null && sGDP.Count__c == null && sGDP.Percent__c == null))
                            displayAmount = true;
                        else if(sGDP.Count__c != null && sGDP.Count__c > 0 || (sGDP.Count__c != null && sGDP.Amount__c == null && sGDP.Percent__c == null))
                            displayCount = true;
                        else if(sGDP.Percent__c != null && sGDP.Percent__c > 0 || (sGDP.Percent__c != null && sGDP.Amount__c == null && sGDP.Count__c == null))
                            displayPercent = true;
                        
                        //Boolean
                        Boolean showSelected = false;
                            
                        if(sGDP.Period_Start__c >= periodStart)
                            showSelected = true;
                            
                        //Personal Goal
                        Personal_Goal__c pG;
                        
                        String mapUnKey = payeeId + '-' + sGDP.Standard_Goal_Detail__c;
                        
                        if(mapPgsWithPacingIds.containsKey(mapUnKey)){
                            pG = mapPgsWithPacingIds.get(mapUnKey);
                            pG.Goal_Type__c = sGDP.Standard_Goal_Detail__r.Goal_Type__c;
                            pG.Description__c = sGDP.Standard_Goal_Detail__r.Name + '-'+ sGDP.Description__c;
                            pG.Period_Start__c = sGDP.Period_Start__c;
                            pG.Period_End__c = sGDP.Period_End__c;
                            pG.Weighting__c = sGDP.Standard_Goal_Detail__r.Weighting__c;
                            
                            //Check for value Type populated and If it is differet on GTD then what is on PG then popualte that value  type
                            if(pG.Value_Type_Quantity__c != sGDP.Standard_Goal_Detail__r.Value_Type__c){
                                
                                pG.Amount__c = sGDP.Standard_Goal_Detail__r.Amount__c;
                                pG.Count__c = sGDP.Standard_Goal_Detail__r.Count__c;
                                pG.Percent__c = sGDP.Standard_Goal_Detail__r.Percent__c;
                                pG.Value_Type_Quantity__c = sGDP.Standard_Goal_Detail__r.Value_Type__c; 
                            }
                             
                        }else
                            pG = getPersonalGoal(sGDP, mapPersonalGoals.get(payeeId) != null ? mapPersonalGoals.get(payeeId) : null);
                                          
                        //Check for Payee Id in map
                        if(mapPayeeWithSAs.containsKey(payeeId)) {
                            
                            //Loop through the Staff Attributes
                            for(Staff_History__c sA : mapPayeeWithSAs.get(payeeId)) {
                                
                                //Check for Period Date
                                if((sA.End_Date__c != null && sA.Start_Date__c <= sGDP.Period_Start__c && sA.End_Date__c >= sGDP.Period_Start__c)
                                        || (sA.End_Date__c == null && sA.Start_Date__c <= sGDP.Period_Start__c)) {
                                    
                                    //Update PG business title
                                    pG.Business_Title_Txt__c = sA.Value_Type__r.Name;
                                    
                                    break;          
                                }
                            }   
                        }
                        
                        //Set to hold the GTDMP dates
                        Set<Date> setGTDMPMDs = new Set<Date>();
                        
                        //List of Personal Goal Measurement Periods wrapper
                        List<CreatePersonalGoalsSectionWrapper.PGMPeriodWrapper> tempPGMPsWrapper = new List<CreatePersonalGoalsSectionWrapper.PGMPeriodWrapper>();
                        
                        //Check for Personal Goal in map
                        if(mapPGMPWithPGIds.containsKey(pG.Id)) {
                            
                            //Loop through the Personal Goal Measurement Periods
                            for(Personal_Goal_Measurement_Period__c pGMP : mapPGMPWithPGIds.get(pG.Id)) {
                                
                                //Add Measurement date in set
                                setGTDMPMDs.add(pGMP.Measurement_Date__c);
                                
                                //Add PGMP wrapper instance in list
                                tempPGMPsWrapper.add(new CreatePersonalGoalsSectionWrapper.PGMPeriodWrapper(pGMP));
                            }
                        }
                        
                        //Check GTD in map
                        if(mapGTDMPeriods.containsKey(sGDP.Standard_Goal_Detail__c)) {
                            
                            //Loop through the GTDMP dates
                            for(Goal_Template_Detail_Measurement_Period__c gTDMP : mapGTDMPeriods.get(sGDP.Standard_Goal_Detail__c)) {
                                
                                
                                //Check Date in set and add PGMP wrapper instance in list
                                if(!setGTDMPMDs.contains(gTDMP.Measurement_Date__c))
                                    tempPGMPsWrapper.add(new CreatePersonalGoalsSectionWrapper.PGMPeriodWrapper(
                                                         new Personal_Goal_Measurement_Period__c(Measurement_Date__c = gTDMP.Measurement_Date__c)));
                                                                      
                            }   
                        }
                        
                        //Check for Personal Goal
                        if(String.isNotBlank(pG.Name))
                            mapPGSalesPercent.put(payeeId, pG.Sales_Role_Percentage__c);
                            
                        //ToolTip String
                        String toolTip = '';
                            
                        //Check the need to tooltip
                        if(String.isNotBlank(mapToolTip.get(payeeId + '-' + sGDP.Standard_Goal_Detail__c)))
                            toolTip = mapToolTip.get(payeeId + '-' + sGDP.Standard_Goal_Detail__c);
                         
                        //V_1.8 - Modified - Rajeev Jain - 05/04/2016 - CR-20160421-9789    
                        //Variable to hold the Business type multiplier
                        Decimal bTMultiplier;
                            
                        //Check Payee Id and Goal Type Id in set
                        /*if(mapPayeeIdWithBTMultiplier.containsKey(payeeId + '-' + sGDP.Standard_Goal_Detail__r.Goal_Type__c))
                            bTMultiplier = mapPayeeIdWithBTMultiplier.get(payeeId + '-' + sGDP.Standard_Goal_Detail__r.Goal_Type__c);*/
                        
                        if(mapAdjustmentValueWithGTBT.containsKey(sGDP.Standard_Goal_Detail__r.Goal_Type__c)){
                            
                            //Get GTBT Record and Match its Business Title With Payee Business Title 
                            for(Goal_Type_Business_Title__c gtBT : mapAdjustmentValueWithGTBT.get(sGDP.Standard_Goal_Detail__r.Goal_Type__c)){
                            
                                if((mapPayeeBusinessTitleData.containsKey(payeeId) && mapPayeeBusinessTitleData.get(payeeId).businessTitle == gtBT.Business_Title__r.Name) || (mapDefaultBusinessTitleData.containsKey(payeeId) && mapDefaultBusinessTitleData.get(payeeId) == gtBT.Business_Title__r.Name)){
                                    
                                    bTMultiplier = gtBT.Adjustment__c;
                                    break;
                                }
                            }
                        }
                        //V_1.8 - Modified - Rajeev Jain - 05/04/2016 - CR-20160421-9789 - upto here
                        
                        //Check for Personal Goal
                        if(pG != null && pG.Goal_Type_Business_Title__c != null && pG.Goal_Type_Business_Title__c > 0)
                            bTMultiplier = pG.Goal_Type_Business_Title__c;
                        
                        //Boolean variable to display the pacing record
                        Boolean isDisplay = false;
                        
                        //Check for Show earlier and later options
                        if(!showEarlier && !showLater && sGDP.Period_Start__c == periodStart)
                            isDisplay = true;
                        
                        else if(showEarlier && !showLater && sGDP.Period_Start__c <= periodStart)
                            isDisplay = true;
                        
                        else if(!showEarlier && showLater && sGDP.Period_Start__c >= periodStart)
                            isDisplay = true;
                        
                        else if(showEarlier && showLater)
                            isDisplay = true;
                       
                        //Check for flag
                        if(isDisplay) {
                            
                            //Add Pacing in wrapper
                            mapStdGDIdWithPacings.get(stdGDId).add(
                                                    new CreatePersonalGoalsSectionWrapper.StdGoalDetailPacingWrapper(sGDP,pG, toolTip, showSelected,
                                                                        pG.Value__c, bTMultiplier, displayAmount, displayCount, displayPercent,
                                                                        mapPGRelationshipsWithPGId.containsKey(pG.Id) ? mapPGRelationshipsWithPGId.get(pG.Id) : new Set<Id>(),
                                                                        tempPGMPsWrapper, mapPGIdWithSRIdAndPGMPIds.containsKey(pG.Id) ? mapPGIdWithSRIdAndPGMPIds.get(pG.Id) : new Map<Id,Id>(),
                                                                        pG.Adjustment__c != null ? String.valueOf(pG.Adjustment__c) : '', isDisplay));
                        
                        } else {
                            
                            //Add Pacing in wrapper
                            mapTempStdGDIdWithPacings.get(stdGDId).add(
                                                    new CreatePersonalGoalsSectionWrapper.StdGoalDetailPacingWrapper(sGDP,pG, toolTip, showSelected,
                                                                        pG.Value__c, bTMultiplier, displayAmount, displayCount, displayPercent,
                                                                        mapPGRelationshipsWithPGId.containsKey(pG.Id) ? mapPGRelationshipsWithPGId.get(pG.Id) : new Set<Id>(),
                                                                        tempPGMPsWrapper, mapPGIdWithSRIdAndPGMPIds.containsKey(pG.Id) ? mapPGIdWithSRIdAndPGMPIds.get(pG.Id) : new Map<Id,Id>(),
                                                                        pG.Adjustment__c != null ? String.valueOf(pG.Adjustment__c) : '', isDisplay));
                        }
                        
                    }
                }
                
                //Put Data into Map
                mapStdGoalPacings.put(payeeId, mapStdGDIdWithPacings);
                
                //Put Data in temp map
                mapTempStdGoalPacings.put(payeeId, mapTempStdGDIdWithPacings);
            }
            
            //Map of Payee Ids with Std Goal Detail Wrapper
            Map<Id, List<CreatePersonalGoalsSectionWrapper.StdGoaldetailsWrapper>> mapStdGoalDetailWrapper = new Map<Id, List<CreatePersonalGoalsSectionWrapper.StdGoaldetailsWrapper>>();
            
            //Map to hold the Row number with boolean (This map will use to verify that we need to show selected checkbox or not)
            Map<Integer, Boolean> mapSelectableRows = new Map<Integer, Boolean>();
            Map<Integer, Boolean> mapSelection = new Map<Integer, Boolean>();
        
            /********************   This code is used to make the ordering of pacing according to start date       **********************/
            for(Id payeeId : mapStdGoalPacings.keySet()) {
                
                //Loop to the max rows
                for(Integer i = 0; i < maxRows; i++) {
                    
                    //Temp Map
                    //Map to hold Std Goal detail Id with List of Pacing Wrapper
                    Map<Id, List<CreatePersonalGoalsSectionWrapper.StdGoalDetailPacingWrapper>> mapTempGTDWithPacings = new Map<Id, List<CreatePersonalGoalsSectionWrapper.StdGoalDetailPacingWrapper>>();
                    
                    //Variable to hold the min start date of the Row
                    Date tempMinSD;
                    
                    //Loop through the GTDs Id
                    for(Id stdGDId : mapStdGoalPacings.get(payeeId).keySet()) {
                        
                        //Check for size
                        if(mapStdGoalPacings.get(payeeId).get(stdGDId).size() > i) {
                            
                            //Check for start date
                            if(tempMinSD == null || mapStdGoalPacings.get(payeeId).get(stdGDId)[i].stdGDPacing.Period_Start__c < tempMinSD)
                                tempMinSD = mapStdGoalPacings.get(payeeId).get(stdGDId)[i].stdGDPacing.Period_Start__c;         
                                
                        }
                    }
                    
                    //Loop through the GTDs Id
                    for(Id stdGDId : mapStdGoalPacings.get(payeeId).keySet()) {
                        
                        //Check for size
                        if(mapStdGoalPacings.get(payeeId).get(stdGDId).size() > i) {
                            
                            //Check for start date
                            if(tempMinSD != null && mapStdGoalPacings.get(payeeId).get(stdGDId)[i].stdGDPacing.Period_Start__c > tempMinSD) {
                                
                                //Put goal template detail in map
                                if(!mapTempGTDWithPacings.containsKey(stdGDId))
                                    mapTempGTDWithPacings.put(stdGDId, new List<CreatePersonalGoalsSectionWrapper.StdGoalDetailPacingWrapper>());   
                                
                                //Loop through the Pacings for this GTD
                                for(Integer j = 0; j < mapStdGoalPacings.get(payeeId).get(stdGDId).size(); j++) {
                                    
                                    //Check for integer
                                    if(j == i)
                                        mapTempGTDWithPacings.get(stdGDId).add(new CreatePersonalGoalsSectionWrapper.StdGoalDetailPacingWrapper(null,null, '', false, null, null, false, false, false, null, null, null, '', true));
                                        
                                    mapTempGTDWithPacings.get(stdGDId).add(mapStdGoalPacings.get(payeeId).get(stdGDId)[j]);     
                                }
                                
                                //Check max row
                                if(mapTempGTDWithPacings.containsKey(stdGDId) && maxRows < mapTempGTDWithPacings.get(stdGDId).size())
                                    maxRows = mapTempGTDWithPacings.get(stdGDId).size();
                        
                            }
                        }
                    }
                    
                    //Update list size in map
                    if(mapTempGTDWithPacings.size() > 0)
                        mapStdGoalPacings.get(payeeId).putAll(mapTempGTDWithPacings);
                }
            }
            
            //Loop through the payee to get max number of rows
            for(Id payeeId : mapStdGoalPacings.keySet()) {
                
                //Loop through Map key set
                for(Id stdGDId : mapStdGoalPacings.get(payeeId).keySet()) {
                    
                    //Check for max row
                    if(mapStdGoalPacings.get(payeeId).get(stdGDId).size() > maxRows)
                        maxRows = mapStdGoalPacings.get(payeeId).get(stdGDId).size();
                    
                    //Loop through the Paicngs
                    for(Integer i = 0; i < mapStdGoalPacings.get(payeeId).get(stdGDId).size(); i++) {
                        
                        //Check if map contains the selected row
                        if(!mapSelectableRows.containsKey(i))
                            mapSelectableRows.put(i,false);
                        
                        //Populate the map
                        mapSelection.put(i,false);
                        
                        //Check for show selected
                        if(mapStdGoalPacings.get(payeeId).get(stdGDId)[i].stdGDPacing.Period_Start__c >= periodStart)
                            mapSelectableRows.put(i, true);     
                        
                    }
                }
                
                break;
            }
            
            //Map to hold the Payee Id with Select Roww map
            Map<String, Map<Integer, Boolean>> mapSelectableRowsWithPId = new Map<String, Map<Integer, Boolean>>();
            Map<String, Map<Integer, Boolean>> mapSelectOptionWithPId = new Map<String, Map<Integer, Boolean>>();
            
            //Loop through Payees
            for(Id payeeId : mapStdGoalPacings.keySet()) {
                
                //Populate map
                mapSelectableRowsWithPId.put(payeeId, mapSelectableRows.clone());
                mapSelectOptionWithPId.put(payeeId, mapSelection.clone());
                
                //List of StdGoal Detail Wrapper
                List<CreatePersonalGoalsSectionWrapper.StdGoaldetailsWrapper> stdGoalDetailWrapper = new List<CreatePersonalGoalsSectionWrapper.StdGoaldetailsWrapper>();
                
                //Loop through Map key set
                for(Id stdGDId : mapStdGoalPacings.get(payeeId).keySet()) {
                    
                    //Check for max rows
                    if(maxRows > mapStdGoalPacings.get(payeeId).get(stdGDId).size()) {
                        
                        //Loop to add blank Pacings
                        for(Integer i = mapStdGoalPacings.get(payeeId).get(stdGDId).size(); i < maxRows; i++) {
                            
                            //Add blank pacing
                            mapStdGoalPacings.get(payeeId).get(stdGDId).add(new CreatePersonalGoalsSectionWrapper.StdGoalDetailPacingWrapper(null,null, '', true, null, null, false, false, false, null, null, null, '', true));
                        }
                    }
                    
                    //Check payee Id in temp map
                    if(mapTempStdGoalPacings.containsKey(payeeId)) {
                        
                        //Loop through the Pacings
                        for(String gTDId : mapTempStdGoalPacings.get(payeeId).keySet()) {
                            
                            //Add values
                            if(stdGDId == gTDId)
                                mapStdGoalPacings.get(payeeId).get(gTDId).addAll(mapTempStdGoalPacings.get(payeeId).get(gTDId));
                        }
                    } 
                            
                    //Add Std goal detail with pacings wrapper in the SGD wrapper
                    stdGoalDetailWrapper.add(new CreatePersonalGoalsSectionWrapper.StdGoaldetailsWrapper(new Standard_Goal_Detail__c(Id = stdGDId),
                                                 mapStdGoalPacings.get(payeeId).get(stdGDId)));
                }
                
                //Populate map
                mapStdGoalDetailWrapper.put(payeeId, stdGoalDetailWrapper);
            }
            
            /**********************     End        ****************************/
            
            /*************   This code is used to add blank rows of pacing for equal the pacings count for each SGD that are not having any pacings   **************/
            
            //Check std goal detail map
            if(mapStdGoalDetails.size() > 0) {
                
                //Add header
                stdGoalDetails.addAll(mapStdGoalDetails.values());
                        
                //List of Pacings to add blank row for std goal detail
                List<CreatePersonalGoalsSectionWrapper.StdGoalDetailPacingWrapper> emptyPacings = new List<CreatePersonalGoalsSectionWrapper.StdGoalDetailPacingWrapper>();
                
                //Loop to add blank pacings
                for(Integer i = 0; i < maxRows; i++)
                    emptyPacings.add(new CreatePersonalGoalsSectionWrapper.StdGoalDetailPacingWrapper(null,null, '', false, null, null, false, false, false, null, null, null,'', true));
                
                //Loop through Payees
                for(Id payeeId : mapStdGoalPacings.keySet()) {
                    
                    //List of StdGoal Detail Wrapper
                    List<CreatePersonalGoalsSectionWrapper.StdGoaldetailsWrapper> stdGoalDetailWrapper = new List<CreatePersonalGoalsSectionWrapper.StdGoaldetailsWrapper>();
                    
                    //Loop through Map key set
                    for(Id stdGDId : mapStdGoalDetails.keySet()) {
                        
                        //Add Std goal detail with pacings wrapper in the SGD wrapper
                        stdGoalDetailWrapper.add(new CreatePersonalGoalsSectionWrapper.StdGoaldetailsWrapper(new Standard_Goal_Detail__c(Id = stdGDId),
                                                     emptyPacings));
                    }
                    
                    //Check payee Id in map
                    if(mapStdGoalDetailWrapper.containsKey(payeeId))
                        mapStdGoalDetailWrapper.get(payeeId).addAll(stdGoalDetailWrapper);  
                }
            }
            
            /*******************    End   ********************/
            
            /********************** This peace of code will use to control the calc button on each row         *************/
            
            //Loop through the PayeeId
            for(Id pId : mapStdGoalDetailWrapper.keySet()) {
                
                //Loop through the 1st GTD'Pacings
                for(Integer i = 0; i < mapStdGoalDetailWrapper.get(pId)[0].stdGDetailPacings.size(); i++) {
                    
                    //Put values in map
                    mapControlCalcs.put(i, false);
                    
                    //Loop through the GTDs
                    for(CreatePersonalGoalsSectionWrapper.StdGoaldetailsWrapper gTDW : mapStdGoalDetailWrapper.get(pId)) {
                        
                        //Check for ith row
                        if(gTDW.stdGDetailPacings.size() > i && gTDW.stdGDetailPacings[i].stdGDPacing.Standard_Goal_Detail__r.Goal_Type__c != null
                            && gTDW.stdGDetailPacings[i].stdGDPacing.Standard_Goal_Detail__r.Goal_Type__r.Discount_Type__c == ISSPConstants.GOAL_TYPE_DISCOUNT_TYPE_MULTIPLIERS)
                            mapControlCalcs.put(i, true);   
                    }
                }
                
                break;
            }
            
            /************     End        ************/
            
            //Query through the custom setting
            List<Incentive_Defaults__c> incentiveDefaults = [Select Id, Amount__c, Count__c, Percent__c From Incentive_Defaults__c Where Name = 'Tenure' LIMIT 1];
            
            /************     This code is used to full fill the staff Relationship requirement   ****************/ 
            //Map to hold the Contact with boolean
            Map<Id, Boolean> mapIsPayeeHasSR = new Map<Id, Boolean>();
            
            //Loop through the staff Relationships to get the Staff Relationships for contact
            for(Staff_Relationship__c sR : [Select Id, From__c, To__c From Staff_Relationship__c Where From__c IN : setCOnIds OR To__c IN : setCOnIds]) {
                
                //Check for from date
                if(sR.From__c != null)
                    mapIsPayeeHasSR.put(sR.From__c, true);
                
                //Check for to date
                if(sR.To__c != null)
                    mapIsPayeeHasSR.put(sR.To__c, true);    
            }
                
            /*********     End     ***********/
            
            //V_1.5 - Modified - Rajeev Jain - 03/29/2016 - CR-20160316-9699 - ISSP SFDC Critical NBB Calculation Fixes - QA Fixes   
            //Hold StadGoalDetailsWrapper and Ppoulate its full data
            List<CreatePersonalGoalsSectionWrapper.StdGoaldetailsWrapper> tempStdGoaldetailsWrapperList = new List<CreatePersonalGoalsSectionWrapper.StdGoaldetailsWrapper>();
                
            //Loop through the selected Payees
            for(PayeesWrapper pW : selectedPayees) {
                
                if(mapStdGoalDetailWrapper.get(pW.contactId) != null && mapStdGoalDetailWrapper.get(pW.contactId).size()> 0)
                    tempStdGoaldetailsWrapperList.addAll(mapStdGoalDetailWrapper.get(pW.contactId));
                
                String businessTitle = mapPayeeBusinessTitleData.containsKey(pW.contactId) ?  mapPayeeBusinessTitleData.get(pW.contactId).businessTitle : pW.businessTitle;
                Decimal businessTitlePercent = mapPayeeBusinessTitleData.containsKey(pW.contactId) ?  mapPayeeBusinessTitleData.get(pW.contactId).businessTitlePercent : mapPGSalesPercent.containsKey(pW.contactId) ? mapPGSalesPercent.get(pW.contactId) : pW.businessTitlePercent;
                
                //Add Data in Create Personal Goal Section Wrapper
                createPGSecWrapper.add(new CreatePersonalGoalsSectionWrapper(pW.contactName, pW.contactId, businessTitle,
                                           businessTitlePercent,
                                           pW.tenured == 'Yes' ? true : false, pW.tenured == 'Yes' ? pW.tenuredPercent : valueTypes.size() > 0 ? valueTypes[0].Adjustment__c : null,
                                           incentiveDefaults.size() > 0 ? incentiveDefaults[0].Percent__c : null, mapStdGoalDetailWrapper.get(pW.contactId),
                                           maxRows, pW.StaffAttributeId, mapIsPayeeHasSR.containsKey(pW.contactId) ? true : false,
                                           mapSelectableRowsWithPId.containsKey(pW.contactId) ? mapSelectableRowsWithPId.get(pW.contactId) : new Map<Integer, Boolean>(),
                                           mapSelectOptionWithPId.containsKey(pW.contactId) ? mapSelectOptionWithPId.get(pW.contactId) : new Map<Integer, Boolean>()));
                
            }
            
            //V_1.4 - Modified - Rajeev Jain - 03/22/2016 - CR-20160316-9698 - ISSP SFDC Critical NBB Calculation Fixes
            
            //Set to hold Id of GTDs and Requery the STDGD data
            Set<Id> stdGdIds = new Set<Id>();
            
            for(CreatePersonalGoalsSectionWrapper.StdGoaldetailsWrapper wrap :tempStdGoaldetailsWrapperList){
                stdGdIds.add(wrap.stdGoalDetail.Id);        
            }
            
            //Get Additional Data Related Standard Goal and repopulated wrapper instances with additional info
            Map<Id, Standard_Goal_Detail__c> mapStdGdData = new Map<Id, Standard_Goal_Detail__c>([select Amount__c, Count__c, Percent__c, Baseline__c, Baseline_Percentage__c, Period_Start__c,
                                                                Baseline__r.Description__c, Description__c, Baseline__r.Amount__c, Baseline__r.Period_Start__c
                                                                from Standard_Goal_Detail__c where Id IN : stdGdIds]);
            //Loop over again to the reference the  data
            for(CreatePersonalGoalsSectionWrapper.StdGoaldetailsWrapper wrap :tempStdGoaldetailsWrapperList){
                
                if(mapStdGdData.containsKey(wrap.stdGoalDetail.Id)){
                    
                    Standard_Goal_Detail__c tempWrapData =  mapStdGdData.get(wrap.stdGoalDetail.Id);
                    wrap.stdGoalDetail.BaseLine__c = tempWrapData.Baseline__c;
                    wrap.stdGoalDetail.Baseline_Percentage__c = tempWrapData.Baseline_Percentage__c;
                    wrap.stdGoalDetail.Description__c = tempWrapData.Description__c;
                    wrap.stdGoalDetail.Period_Start__c = tempWrapData.Period_Start__c;
                    wrap.parentBaselineDescription = tempWrapData.Baseline__r.Description__c;
                    wrap.parentBaselineAmount = tempWrapData.Baseline__r.Amount__c;
                    wrap.parentPeriodStart = tempWrapData.Baseline__r.Period_Start__c;
                }
            }
            for(CreatePersonalGoalsSectionWrapper pgWrapper : createPGSecWrapper){
                
                pgWrapper.mapSummaryCalcsGoals = new Map<String, Map<String, Personal_Goal__c>>();
                
                //Now get StgdDetail Wrappper List instance
                for(CreatePersonalGoalsSectionWrapper.StdGoaldetailsWrapper wrap : pgWrapper.stdGoalDetails){
                    
                    String unKey = wrap.stdGoalDetail.Id + '-' +wrap.stdGoalDetail.Description__c + '-' + wrap.stdGoalDetail.Period_Start__c;
                    pgWrapper.mapStdGoalDetails.put(unKey,wrap);
                    
                    //Loop over each pacing
                    for(CreatePersonalGoalsSectionWrapper.StdGoalDetailPacingWrapper pacing : wrap.stdGDetailPacings){
                        
                        if(pacing.stdGDPacing != null && pacing.stdGDPacing.Standard_Goal_Detail__r.Parent__c != null && pacing.pGoal != null) {
                            
                            //Unique Key
                            String uniqueKey = pgWrapper.conId + '-' + pacing.stdGDPacing.Standard_Goal_Detail__r.Parent__c;
                            
                            //Check unique Key in map
                            if(!pgWrapper.mapSummaryCalcsGoals.containsKey(uniqueKey))
                                pgWrapper.mapSummaryCalcsGoals.put(uniqueKey, new Map<String,Personal_Goal__c>());
                            
                            //Put current records details in map
                            pgWrapper.mapSummaryCalcsGoals.get(uniqueKey).put(pgWrapper.conId + '-' + pacing.stdGDPacing.Standard_Goal_Detail__c, pacing.pGoal);
                        }
                    }    
                }
            }
            //V_1.4 - Modified - Rajeev Jain - 03/22/2016 - CR-20160316-9698 - ISSP SFDC Critical NBB Calculation Fixes - Upto Here                   
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
        
        //Check for values and Assign PGMP list into main list (this will display on the VF page) 
        if(mainRow != null && gTDRow != null && columnRow != null)
            pGMPeriods = createPGSecWrapper[mainRow].stdGoalDetails[gTDRow].stdGDetailPacings[columnRow].pGMPeriods;
    }
     
    /**
     *  @description    :   This method is used to add PGMP on the selected PG
     *
     *  @args           :   
     *
     *  @return         :   void
     *
     **/
    public void addPGMeasurementPeriods() {
        
        //Check for PGMP
        if(pGMPeriod != null) {
            
            //Check for values
            if(mainRow != null && gTDRow != null && columnRow != null) {
                
                //Add PGMP in the list
                createPGSecWrapper[mainRow].stdGoalDetails[gTDRow].stdGDetailPacings[columnRow].pGMPeriods.add(
                                                                                        new CreatePersonalGoalsSectionWrapper.PGMPeriodWrapper(pGMPeriod));
                
                //Sort list
                createPGSecWrapper[mainRow].stdGoalDetails[gTDRow].stdGDetailPacings[columnRow].pGMPeriods.sort();
                
                //Assign PGMP list into main list (this will display on the VF page)
                pGMPeriods = createPGSecWrapper[mainRow].stdGoalDetails[gTDRow].stdGDetailPacings[columnRow].pGMPeriods;    
            }
            
            pGMPeriod = new Personal_Goal_Measurement_Period__c();
        }
    }
    
    /**
     *  @description    :   This method is used to Remove PGMP from the selected PG
     *
     *  @args           :   
     *
     *  @return         :   void
     *
     **/
    public void removePGMeasurementPeriods() {
        
        //Check for values
        if(mainRow != null && gTDRow != null && columnRow != null) {
            
            //Temp list
            List<CreatePersonalGoalsSectionWrapper.PGMPeriodWrapper> tempPGMPeriods = new List<CreatePersonalGoalsSectionWrapper.PGMPeriodWrapper>(); 
            
            //Loop through the PGMP wrapper list
            for(CreatePersonalGoalsSectionWrapper.PGMPeriodWrapper pGMPW : pGMPeriods) {
                
                //Check for flag and Add PGMP in the wrapper
                if(!pGMPW.selected)
                    tempPGMPeriods.add(pGMPW);
                else if(pGMPW.pGMP.Id != null && pGMPW.pGMP.Personal_Goal__c != null) {
                    
                    //Check Personal Goal Id in map
                    if(!mapPGMPGoingToDelete.containsKey(pGMPW.pGMP.Personal_Goal__c))
                        mapPGMPGoingToDelete.put(pGMPW.pGMP.Personal_Goal__c, new List<Personal_Goal_Measurement_Period__c>());
                    
                    //Add PGMP in list
                    mapPGMPGoingToDelete.get(pGMPW.pGMP.Personal_Goal__c).add(pGMPW.pGMP);
                }
            }
            
            //Add PGMP in the list
            createPGSecWrapper[mainRow].stdGoalDetails[gTDRow].stdGDetailPacings[columnRow].pGMPeriods = tempPGMPeriods;
            
            //Sort list
            createPGSecWrapper[mainRow].stdGoalDetails[gTDRow].stdGDetailPacings[columnRow].pGMPeriods.sort();
            
            //Assign PGMP list into main list (this will display on the VF page)
            pGMPeriods = createPGSecWrapper[mainRow].stdGoalDetails[gTDRow].stdGDetailPacings[columnRow].pGMPeriods;    
        }
    }
     
    /**
     *  @description    :   This method is used to add description on Personal Goal
     *
     *  @args           :   
     *
     *  @return         :   void
     *
     **/
    public void addDescription() {
        
        //Get Variables from URL
        String mainWrapIndex = ApexPages.currentPage().getParameters().get('rowIndex');
        String stdGDWrapIndex = ApexPages.currentPage().getParameters().get('colIndex');
        String stdGDPWrapIndex = ApexPages.currentPage().getParameters().get('itemIndex');
        String description = ApexPages.currentPage().getParameters().get('desc');
        
        //Convert String into Integer
        rowIndex = String.isNotBlank(mainWrapIndex) ? Integer.valueOf(mainWrapIndex) : null;
        colIndex = String.isNotBlank(stdGDWrapIndex) ? Integer.valueOf(stdGDWrapIndex) : null;
        itemIndex = String.isNotBlank(stdGDPWrapIndex) ? Integer.valueOf(stdGDPWrapIndex) : null;
        
        //Check for values
        if(rowIndex != null && colIndex != null && itemIndex != null)
            createPGSecWrapper[rowIndex].stdGoalDetails[colIndex].stdGDetailPacings[itemIndex].comments = description;
    
        //Call method to parse blank in URL Parameters
        parseURLParameters();
        
        //Call the method to execute the select logic
        //executeSelectRowLogic();
        
        //Loop through the Main Wrapper list (List which is having all the contact with Std Goal Detial, Pacings and Personal Goal)
        for(CreatePersonalGoalsSectionWrapper cPGW : createPGSecWrapper) {
            
            //Set Values
            if(cPGW.businessTitlePercent == 0)
            cPGW.businessTitlePercent = null;
            
            if(cPGW.tenuredPercent == 0)
            cPGW.tenuredPercent = null;
            
            if(cPGW.cSTenuredPercent == 0)
            cPGW.cSTenuredPercent = null;
        }
    }
    
    /**
     *  @description    :   This method is used to do calculations for selected Row
     *
     *  @args           :   
     *
     *  @return         :   void
     *
     **/
    public void doItemGoalCalculation() {
        
        //Get Variables from URL
        String mainWrapIndex = ApexPages.currentPage().getParameters().get('rowIndex');
        String stdGDWrapIndex = ApexPages.currentPage().getParameters().get('colIndex');
        String stdGDPWrapIndex = ApexPages.currentPage().getParameters().get('itemIndex');
        
        //Convert String into Integer
        rowIndex = String.isNotBlank(mainWrapIndex) ? Integer.valueOf(mainWrapIndex) : null;
        colIndex = String.isNotBlank(stdGDWrapIndex) ? Integer.valueOf(stdGDWrapIndex) : null;
        itemIndex = String.isNotBlank(stdGDPWrapIndex) ? Integer.valueOf(stdGDPWrapIndex) : null;
        
        //Check for Row Index
        if(rowIndex != null && colIndex != null && itemIndex != null) {
            
            //Integer to Calculate Proper Amount
            Decimal conMultipliers = 1;
            
            //Check for sales Role Percentage
            if(createPGSecWrapper[rowIndex].businessTitlePercent != null && createPGSecWrapper[rowIndex].businessTitlePercent != 0)
                conMultipliers =  conMultipliers * (createPGSecWrapper[rowIndex].businessTitlePercent/100);
            
            //V_1.6 - Modified - Rajeev Jain - 04/10/2016 - CR - 9688 - ISSP Deployment E
            //Commented out the code since Tenured multiplier at payee level is no longer in use, instead using it at each individual goal level
            //Check for tenured Percentage
            /*if(createPGSecWrapper[rowIndex].tenured && createPGSecWrapper[rowIndex].tenuredPercent != null && createPGSecWrapper[rowIndex].tenuredPercent != 0)
                conMultipliers =  conMultipliers * (createPGSecWrapper[rowIndex].tenuredPercent/100);
            else if(!createPGSecWrapper[rowIndex].tenured && createPGSecWrapper[rowIndex].cSTenuredPercent != null && createPGSecWrapper[rowIndex].cSTenuredPercent != 0)
                conMultipliers =  conMultipliers * (createPGSecWrapper[rowIndex].cSTenuredPercent/100);*/
            //V_1.6 - Modified - Rajeev Jain - 04/10/2016 - CR - 9688 - ISSP Deployment E - upto here
            
            //Check for Pacing description
            if(String.isNotBlank(createPGSecWrapper[rowIndex].stdGoalDetails[colIndex].stdGDetailPacings[itemIndex].stdGDPacing.Description__c)) {
                
                //Check for calc button
                //if((createPGSecWrapper[rowIndex].stdGoalDetails[colIndex].stdGDetailPacings[itemIndex].stdGDPacing.Standard_Goal_Detail__r.Summary__c
                //  || (createPGSecWrapper[rowIndex].stdGoalDetails[colIndex].stdGDetailPacings[itemIndex].stdGDPacing.Standard_Goal_Detail__r.Goal_Type__c != null
                    //  && createPGSecWrapper[rowIndex].stdGoalDetails[colIndex].stdGDetailPacings[itemIndex].stdGDPacing.Standard_Goal_Detail__r.Goal_Type__r.Discount_Type__c == 'Multipliers'))
                    //&& createPGSecWrapper[rowIndex].mapSelection.containsKey(itemIndex) && !createPGSecWrapper[rowIndex].mapSelection.get(itemIndex))
                    //createPGSecWrapper[rowIndex].mapSelection.put(itemIndex, true);
                                            
                //Variable to hold the multiplier
                Decimal payeeMultiplier = conMultipliers;
                
                //Set Calc flag to true
                createPGSecWrapper[rowIndex].stdGoalDetails[colIndex].stdGDetailPacings[itemIndex].isCalc = true;
                
                //Check for Summary PG
                if(createPGSecWrapper[rowIndex].stdGoalDetails[colIndex].stdGDetailPacings[itemIndex].stdGDPacing.Standard_Goal_Detail__r.Summary__c) {
                    
                    //Map to hold the Unique Key and Personal Goal Id
                    Map<String, Personal_Goal__c> mapInlineSummaryCalcs = new Map<String, Personal_Goal__c>();
                    
                    //Unique Key
                    String uniqueKey = createPGSecWrapper[rowIndex].conId + '-' + createPGSecWrapper[rowIndex].stdGoalDetails[colIndex].stdGDetailPacings[itemIndex].stdGDPacing.Standard_Goal_Detail__c;
                    
                    //Populate map
                    mapInlineSummaryCalcs.put(uniqueKey, new Personal_Goal__c(Amount__c = 0, Count__c = 0, Percent__c = 0));
                    
                    //Get max rows
                    Integer maxGTDPRows = maxGTDPRows(createPGSecWrapper[rowIndex]);
                    
                    //Map to hold the Unique Key (Payee Id + GTD Id)as key and Instance of personal goal as value
                    //This map will used to perform the calculations for summary goals
                    Map<String, Map<String,Personal_Goal__c>> mapSummaryCalcs = new Map<String, Map<String,Personal_Goal__c>>();
                    
                    //Fill the summary map with other child as well
                    //Check if Map contains Personal Goal as Key
                    if(createPGSecWrapper[rowIndex].mapSummaryCalcsGoals.containsKey(uniqueKey)){
                        
                        //Get inner Map
                        Map<String, Personal_Goal__c> globalMap = createPGSecWrapper[rowIndex].mapSummaryCalcsGoals.get(uniqueKey);
                        
                        //Loop over each GTD in map and fill in the summary map
                        if(!mapSummaryCalcs.containsKey(uniqueKey))
                            mapSummaryCalcs.put(uniqueKey, new Map<String,Personal_Goal__c>());
                        
                        for(String str : globalMap.keySet())
                            mapSummaryCalcs.get(uniqueKey).put(str, globalMap.get(str));    
                    }                   
                    
                    //Parent UK
                    String parentUK = null;
                    
                    //Check for Parent
                    if(createPGSecWrapper[rowIndex].stdGoalDetails[colIndex].stdGDetailPacings[itemIndex].stdGDPacing.Standard_Goal_Detail__r.Parent__c != null)
                        parentUK = createPGSecWrapper[rowIndex].conId + '-' + createPGSecWrapper[rowIndex].stdGoalDetails[colIndex].stdGDetailPacings[itemIndex].stdGDPacing.Standard_Goal_Detail__r.Parent__c;
                        
                    //Call method to perform the calculations for Parent PGS
                    summaryPGCalcs(createPGSecWrapper[rowIndex].stdGoalDetails, mapSummaryCalcs, conMultipliers, createPGSecWrapper[rowIndex].conId, parentUK, null, true); 
                
                //Check for Multiplier (Calculate for those GTD,pG, which are not summary and there Basline lookup is null) 
                } else if(createPGSecWrapper[rowIndex].stdGoalDetails[colIndex].stdGDetailPacings[itemIndex].stdGDPacing.Standard_Goal_Detail__r.Goal_Type__c != null
                    && createPGSecWrapper[rowIndex].stdGoalDetails[colIndex].stdGDetailPacings[itemIndex].stdGDPacing.Standard_Goal_Detail__r.Goal_Type__r.Discount_Type__c == ISSPConstants.GOAL_TYPE_DISCOUNT_TYPE_MULTIPLIERS) {    
                    
                    //Check for Summary PG
                    if(!createPGSecWrapper[rowIndex].stdGoalDetails[colIndex].stdGDetailPacings[itemIndex].stdGDPacing.Standard_Goal_Detail__r.Summary__c && createPGSecWrapper[rowIndex].stdGoalDetails[colIndex].stdGDetailPacings[itemIndex].stdGDPacing.Standard_Goal_Detail__r.BaseLine__c == null) {
                        
                        //Check for amount
                        if(createPGSecWrapper[rowIndex].stdGoalDetails[colIndex].stdGDetailPacings[itemIndex].stdGDPacing.Amount__c > 0
                            || (createPGSecWrapper[rowIndex].stdGoalDetails[colIndex].stdGDetailPacings[itemIndex].stdGDPacing.Amount__c != null
                                && createPGSecWrapper[rowIndex].stdGoalDetails[colIndex].stdGDetailPacings[itemIndex].stdGDPacing.Count__c == null
                                && createPGSecWrapper[rowIndex].stdGoalDetails[colIndex].stdGDetailPacings[itemIndex].stdGDPacing.Percent__c == null)) {
                                    
                            //Call the method for calculation
                            Decimal value = doValueCalculation(payeeMultiplier, createPGSecWrapper[rowIndex].stdGoalDetails[colIndex].stdGDetailPacings[itemIndex].stdGDPacing.Amount__c,
                                                               createPGSecWrapper[rowIndex].stdGoalDetails[colIndex].stdGDetailPacings[itemIndex].bTMultiplier,
                                                               createPGSecWrapper[rowIndex].stdGoalDetails[colIndex].stdGDetailPacings[itemIndex].adjustmentValue,
                                                               createPGSecWrapper[rowIndex].stdGoalDetails[colIndex].stdGDetailPacings[itemIndex].stdGDPacing.Standard_Goal_Detail__r.Minimum__c,
                                                               createPGSecWrapper[rowIndex].stdGoalDetails[colIndex].stdGDetailPacings[itemIndex].stdGDPacing.Standard_Goal_Detail__r.Target_Type__c,
                                                               ISSPConstants.PERSONAL_GOAL_VALUE_TYPE_AMOUNT,
                                                               createPGSecWrapper[rowIndex].stdGoalDetails[colIndex].stdGDetailPacings[itemIndex].pGoal.Tenure_Percentage__c);
                                    
                            //Update amount
                            createPGSecWrapper[rowIndex].stdGoalDetails[colIndex].stdGDetailPacings[itemIndex].pGoal.Amount__c = value == null ? 0 : value;
                            createPGSecWrapper[rowIndex].stdGoalDetails[colIndex].stdGDetailPacings[itemIndex].pGoal.Count__c = null;
                            createPGSecWrapper[rowIndex].stdGoalDetails[colIndex].stdGDetailPacings[itemIndex].pGoal.Percent__c = null; 
                                
                        //Check for count
                        } else if(createPGSecWrapper[rowIndex].stdGoalDetails[colIndex].stdGDetailPacings[itemIndex].stdGDPacing.Count__c > 0
                            || (createPGSecWrapper[rowIndex].stdGoalDetails[colIndex].stdGDetailPacings[itemIndex].stdGDPacing.Count__c != null
                                && createPGSecWrapper[rowIndex].stdGoalDetails[colIndex].stdGDetailPacings[itemIndex].stdGDPacing.Amount__c == null
                                && createPGSecWrapper[rowIndex].stdGoalDetails[colIndex].stdGDetailPacings[itemIndex].stdGDPacing.Percent__c == null)) {
                            
                            //Call the method for calculation
                            Decimal value = doValueCalculation(payeeMultiplier, createPGSecWrapper[rowIndex].stdGoalDetails[colIndex].stdGDetailPacings[itemIndex].stdGDPacing.Count__c,
                                                               createPGSecWrapper[rowIndex].stdGoalDetails[colIndex].stdGDetailPacings[itemIndex].bTMultiplier,
                                                               createPGSecWrapper[rowIndex].stdGoalDetails[colIndex].stdGDetailPacings[itemIndex].adjustmentValue,
                                                               createPGSecWrapper[rowIndex].stdGoalDetails[colIndex].stdGDetailPacings[itemIndex].stdGDPacing.Standard_Goal_Detail__r.Minimum__c,
                                                               createPGSecWrapper[rowIndex].stdGoalDetails[colIndex].stdGDetailPacings[itemIndex].stdGDPacing.Standard_Goal_Detail__r.Target_Type__c,
                                                               ISSPConstants.PERSONAL_GOAL_VALUE_TYPE_COUNT,
                                                               createPGSecWrapper[rowIndex].stdGoalDetails[colIndex].stdGDetailPacings[itemIndex].pGoal.Tenure_Percentage__c);
                            
                            //Update amount
                            createPGSecWrapper[rowIndex].stdGoalDetails[colIndex].stdGDetailPacings[itemIndex].pGoal.Count__c = value == null ? 0 : value;
                            createPGSecWrapper[rowIndex].stdGoalDetails[colIndex].stdGDetailPacings[itemIndex].pGoal.Amount__c = null;
                            createPGSecWrapper[rowIndex].stdGoalDetails[colIndex].stdGDetailPacings[itemIndex].pGoal.Percent__c = null;  
                        
                        //Check for Percent
                        } else if(createPGSecWrapper[rowIndex].stdGoalDetails[colIndex].stdGDetailPacings[itemIndex].stdGDPacing.Percent__c > 0
                            || (createPGSecWrapper[rowIndex].stdGoalDetails[colIndex].stdGDetailPacings[itemIndex].stdGDPacing.Percent__c != null
                                && createPGSecWrapper[rowIndex].stdGoalDetails[colIndex].stdGDetailPacings[itemIndex].stdGDPacing.Amount__c == null
                                && createPGSecWrapper[rowIndex].stdGoalDetails[colIndex].stdGDetailPacings[itemIndex].stdGDPacing.Count__c == null)) {
                            
                            //Call the method for calculation
                            Decimal value = doValueCalculation(payeeMultiplier, createPGSecWrapper[rowIndex].stdGoalDetails[colIndex].stdGDetailPacings[itemIndex].stdGDPacing.Percent__c,
                                                               createPGSecWrapper[rowIndex].stdGoalDetails[colIndex].stdGDetailPacings[itemIndex].bTMultiplier,
                                                               createPGSecWrapper[rowIndex].stdGoalDetails[colIndex].stdGDetailPacings[itemIndex].adjustmentValue,
                                                                createPGSecWrapper[rowIndex].stdGoalDetails[colIndex].stdGDetailPacings[itemIndex].stdGDPacing.Standard_Goal_Detail__r.Minimum__c,
                                                               createPGSecWrapper[rowIndex].stdGoalDetails[colIndex].stdGDetailPacings[itemIndex].stdGDPacing.Standard_Goal_Detail__r.Target_Type__c,
                                                               ISSPConstants.PERSONAL_GOAL_VALUE_TYPE_PERCENT,
                                                               createPGSecWrapper[rowIndex].stdGoalDetails[colIndex].stdGDetailPacings[itemIndex].pGoal.Tenure_Percentage__c);
                            
                            //Update Percent
                            createPGSecWrapper[rowIndex].stdGoalDetails[colIndex].stdGDetailPacings[itemIndex].pGoal.Percent__c = value == null ? 0 : value;
                            createPGSecWrapper[rowIndex].stdGoalDetails[colIndex].stdGDetailPacings[itemIndex].pGoal.Amount__c = null;
                            createPGSecWrapper[rowIndex].stdGoalDetails[colIndex].stdGDetailPacings[itemIndex].pGoal.Count__c = null;    
                        }
                    //V_1.4 - Modified - Rajeev Jain - 03/22/2016 - CR-20160316-9698 - ISSP SFDC Critical NBB Calculation Fixes
                    //Calculate thos pg which are not summary type and having Baseline as parent    
                    }else if(!createPGSecWrapper[rowIndex].stdGoalDetails[colIndex].stdGDetailPacings[itemIndex].stdGDPacing.Standard_Goal_Detail__r.Summary__c && createPGSecWrapper[rowIndex].stdGoalDetails[colIndex].stdGDetailPacings[itemIndex].stdGDPacing.Standard_Goal_Detail__r.BaseLine__c != null){
                        
                        performCalculationOnParentBaseLine(createPGSecWrapper[rowIndex], createPGSecWrapper[rowIndex].stdGoalDetails[colIndex], conMultipliers, itemIndex, new Map<String, Map<String,Personal_Goal__c>> (), null, new Map<String, Personal_Goal__c> (), true, true);
                    }
                    //V_1.4 - Modified - Rajeev Jain - 03/22/2016 - CR-20160316-9698 - ISSP SFDC Critical NBB Calculation Fixes - Upto here
                } else {
                    
                    //Populate pacing's values directly to PG
                    createPGSecWrapper[rowIndex].stdGoalDetails[colIndex].stdGDetailPacings[itemIndex].pGoal.Amount__c = createPGSecWrapper[rowIndex].stdGoalDetails[colIndex].stdGDetailPacings[itemIndex].stdGDPacing.Amount__c;
                    createPGSecWrapper[rowIndex].stdGoalDetails[colIndex].stdGDetailPacings[itemIndex].pGoal.Count__c = createPGSecWrapper[rowIndex].stdGoalDetails[colIndex].stdGDetailPacings[itemIndex].stdGDPacing.Count__c;
                    createPGSecWrapper[rowIndex].stdGoalDetails[colIndex].stdGDetailPacings[itemIndex].pGoal.Percent__c = createPGSecWrapper[rowIndex].stdGoalDetails[colIndex].stdGDetailPacings[itemIndex].stdGDPacing.Percent__c; 
                }
                
                Integer maxGTDPRows = maxGTDPRows(createPGSecWrapper[rowIndex]);
                
                //Mark is caluclated false once transaction get complete
                for(Integer i = 0; i < maxGTDPRows; i++) {
                    for(CreatePersonalGoalsSectionWrapper.StdGoaldetailsWrapper stdGDW : createPGSecWrapper[rowIndex].stdGoalDetails) {
                        if(stdGDW.stdGDetailPacings.size() > i && String.isNotBlank(stdGDW.stdGDetailPacings[i].stdGDPacing.Description__c)){
                            stdGDW.stdGDetailPacings[i].isCalculated = false;
                        }
                    }
                }
                
                //Reset Box color, once calculation gets complete
                createPGSecWrapper[rowIndex].stdGoalDetails[colIndex].stdGDetailPacings[itemIndex].labelColorBTMultiplier = 'black';
                createPGSecWrapper[rowIndex].stdGoalDetails[colIndex].stdGDetailPacings[itemIndex].labelColorAdjustmentValue = 'black';
                createPGSecWrapper[rowIndex].stdGoalDetails[colIndex].stdGDetailPacings[itemIndex].labelColorTenured = 'black';
                createPGSecWrapper[rowIndex].stdGoalDetails[colIndex].stdGDetailPacings[itemIndex].labelColorValue = 'black';
                createPGSecWrapper[rowIndex].stdGoalDetails[colIndex].stdGDetailPacings[itemIndex].labelColorTenuredFlag = 'black';
            }
        }
        
        //Loop through the Main Wrapper list (List which is having all the contact with Std Goal Detial, Pacings and Personal Goal)
        for(CreatePersonalGoalsSectionWrapper cPGW : createPGSecWrapper) {
            
            //Set Values
            if(cPGW.businessTitlePercent == 0)
            cPGW.businessTitlePercent = null;
            
            if(cPGW.tenuredPercent == 0)
            cPGW.tenuredPercent = null;
            
            if(cPGW.cSTenuredPercent == 0)
            cPGW.cSTenuredPercent = null;
        }
        
        //Call method to parse blank in URL Parameters
        parseURLParameters();
        
    }
    /**
     *  @description    :   This method is used for value calculation for item goal
     *
     *  @args           :   Decimal, Decimal,Decimal, String, Decimal, String, String
     *
     *  @return         :   Decimal
     *
     **/
    private Decimal doValueCalculation(Decimal conMultipliers, Decimal actualValue, Decimal multiplier, String adjustment, Decimal minimumValue, String gTDTT, String valueType, Decimal tenurePercent) {
        
        //Add Amount
        Decimal value = conMultipliers * actualValue;
        
        //Subhash - 01/05/2016 - Condition commented to incorprate the Adj% and Adj value in the Calculation.
        //Check for Target Type
        //if(gTDTT != ISSPConstants.STANDARD_GOAL_DETAIL_TARGET_TYPE_EXPLICIT) {
        
        //Add Tenure multipler
        if(tenurePercent != null && tenurePercent > 0)
            value *= (tenurePercent/100);
                
        //Add Goal type business multipler
        if(multiplier != null && multiplier > 0)
            value *= (multiplier/100);
        
        //Add Goal type business multipler
        if(String.isNotBlank(adjustment))
            value += Decimal.valueOf(adjustment);
        //}    
        
        //Check for value Type
        //Apply 25K logic to only Amount and Count value types
        if(valueType != ISSPConstants.STANDARD_GOAL_DETAIL_PACING_VALUE_TYPE_PERCENT) {
            
            //Round the calculation according to standard criteria
            Integer rMultiplier = Math.ROUND(value/ISSPConstants.CREATE_PERSONAL_GOAL_MULTIPLIER);
            
            //Recalculate the Amount
            value = ISSPConstants.CREATE_PERSONAL_GOAL_MULTIPLIER * rMultiplier;
            
            //Check for minimum value
            if(minimumValue != null && minimumValue > value)
                value = minimumValue;   
        
        } else if(valueType == ISSPConstants.STANDARD_GOAL_DETAIL_PACING_VALUE_TYPE_PERCENT) {
            
            //Round the calculation according to standard criteria
            Integer rMultiplier = Math.ROUND(value/ISSPConstants.CREATE_PERSONAL_GOAL_PERCENT_MULTIPLIER);
            
            //Recalculate the Amount
            value = ISSPConstants.CREATE_PERSONAL_GOAL_PERCENT_MULTIPLIER * rMultiplier;
        }
        return value;
    }
    
    /**
     *  @description    :   This method is used to do calculations and select records logic for selected Row
     *
     *  @args           :   
     *
     *  @return         :   void
     *
     **/
    public void doInclineSRAndGoalCalc() {
        
        //Set flag to true
        isSelect = true;
        
        //Call method to perform the calculations
        doInclineGoalCalculation();
    }
    
    /**
     *  @description    :   This method is used to do calculations for selected Row
     *
     *  @args           :   
     *
     *  @return         :   void
     *
     **/
    public void doInclineGoalCalculation() {
        
        //Get Variables from URL
        String mainWrapIndex = ApexPages.currentPage().getParameters().get('rowIndex');
        String stdGDPWrapIndex = ApexPages.currentPage().getParameters().get('itemIndex');
        
        //Convert String into Integer
        rowIndex = String.isNotBlank(mainWrapIndex) ? Integer.valueOf(mainWrapIndex) : null;
        itemIndex = String.isNotBlank(stdGDPWrapIndex) ? Integer.valueOf(stdGDPWrapIndex) : null;
        
        //Check for Row Index
        if(rowIndex != null && itemIndex != null) {
            
            //Integer to Calculate Proper Amount
            Decimal conMultipliers = 1;
            
            //Check for sales Role Percentage
            if(createPGSecWrapper[rowIndex].businessTitlePercent != null && createPGSecWrapper[rowIndex].businessTitlePercent != 0)
                conMultipliers =  conMultipliers * (createPGSecWrapper[rowIndex].businessTitlePercent/100);
            
            //V_1.6 - Modified - Rajeev Jain - 04/10/2016 - CR - 9688 - ISSP Deployment E
            //Commented out the code, since Tenured multiplier at payee level is no longer in used - instead applying it at each goal level
            //Check for tenured Percentage
            /*if(createPGSecWrapper[rowIndex].tenured && createPGSecWrapper[rowIndex].tenuredPercent != null && createPGSecWrapper[rowIndex].tenuredPercent != 0)
                conMultipliers =  conMultipliers * (createPGSecWrapper[rowIndex].tenuredPercent/100);
            else if(!createPGSecWrapper[rowIndex].tenured && createPGSecWrapper[rowIndex].cSTenuredPercent != null && createPGSecWrapper[rowIndex].cSTenuredPercent != 0)
                conMultipliers =  conMultipliers * (createPGSecWrapper[rowIndex].cSTenuredPercent/100);  */           
            //V_1.6 - Modified - Rajeev Jain - 04/10/2016 - CR - 9688 - ISSP Deployment E - upto here
            
            //Map to hold the Unique Key and Personal Goal Id
            Map<String, Personal_Goal__c> mapInlineSummaryCalcs = new Map<String, Personal_Goal__c>();
            
            //Get max rows
            Integer maxGTDPRows = maxGTDPRows(createPGSecWrapper[rowIndex]);
            
            //Map to hold the Unique Key (Payee Id + GTD Id)as key and Instance of personal goal as value
            //This map will used to perform the calculations for summary goals
            Map<String, Map<String,Personal_Goal__c>> mapSummaryCalcs = new Map<String, Map<String,Personal_Goal__c>>();
            
            //Call method for goal calculation
            doPersonlGoalCalculation(createPGSecWrapper[rowIndex], createPGSecWrapper[rowIndex].stdGoalDetails, conMultipliers, itemIndex, new Map<String, Map<String,Personal_Goal__c>>(), createPGSecWrapper[rowIndex].conId, mapInlineSummaryCalcs, true);
            
            //Call the method to perform the calculation
            doBaseLineCalculations(createPGSecWrapper[rowIndex], createPGSecWrapper[rowIndex].stdGoalDetails, conMultipliers, itemIndex, mapSummaryCalcs, createPGSecWrapper[rowIndex].conId, mapInlineSummaryCalcs, true);
            
            //Fill the summary map with other child as well
            //Get existing Summary map and add other remaining child as well for summary calculation
            for(String unKey : createPGSecWrapper[rowIndex].mapSummaryCalcsGoals.keySet()){
                
                //Get inner Map
                Map<String, Personal_Goal__c> globalMap = createPGSecWrapper[rowIndex].mapSummaryCalcsGoals.get(unKey);
                
                if(mapSummaryCalcs.containsKey(unKey)){
                    
                    //Get Local Map
                    Map<String, Personal_Goal__c> innerMap = mapSummaryCalcs.get(unKey);
                    
                    //Loop over global Mpa
                    for(String str : globalMap.keySet()){
                        if(!innerMap.containsKey(str))
                            innerMap.put(str, globalMap.get(str));
                    }   
                }   
            }
            
            //Call method to perform the calculations for Parent PGS
            summaryPGCalcs(createPGSecWrapper[rowIndex].stdGoalDetails, mapSummaryCalcs, conMultipliers, createPGSecWrapper[rowIndex].conId, null, itemIndex, false);
            
            
            doBaseLineCalculations(createPGSecWrapper[rowIndex], createPGSecWrapper[rowIndex].stdGoalDetails, conMultipliers, itemIndex, mapSummaryCalcs, createPGSecWrapper[rowIndex].conId, mapInlineSummaryCalcs, true);
            
            //Reset if Calculated flag once calculation gets complete
            //Mark is caluclated false once transaction get complete
            for(Integer i = 0; i < maxGTDPRows; i++) {
                for(CreatePersonalGoalsSectionWrapper.StdGoaldetailsWrapper stdGDW : createPGSecWrapper[rowIndex].stdGoalDetails) {
                    if(stdGDW.stdGDetailPacings.size() > i && String.isNotBlank(stdGDW.stdGDetailPacings[i].stdGDPacing.Description__c)){
                        stdGDW.stdGDetailPacings[i].isCalculated = false;
                    }
                }
            }
            //Reset Color of the all input boxes when Row calculation
            for(CreatePersonalGoalsSectionWrapper.StdGoaldetailsWrapper stdGDW : createPGSecWrapper[rowIndex].stdGoalDetails) {
                
                if(stdGDW.stdGDetailPacings.size() > itemIndex){
                    stdGDW.stdGDetailPacings[itemIndex].labelColorBTMultiplier = 'black';
                    stdGDW.stdGDetailPacings[itemIndex].labelColorAdjustmentValue = 'black';
                    stdGDW.stdGDetailPacings[itemIndex].labelColorTenured = 'black';
                    stdGDW.stdGDetailPacings[itemIndex].labelColorValue = 'black';
                    stdGDW.stdGDetailPacings[itemIndex].labelColorTenuredFlag = 'black';
                }
            }
                        
            //Check for checkbox
            if(String.isNotBlank(ApexPages.currentPage().getParameters().get('selectCB'))
                && ApexPages.currentPage().getParameters().get('selectCB') == 'selectCB') {
                
                //Instance of CreatePersonalGoalsSectionWrapper
                CreatePersonalGoalsSectionWrapper cPGW = createPGSecWrapper[rowIndex];
                
                //Loop through Std Goal Detail Wrapper
                for(CreatePersonalGoalsSectionWrapper.StdGoaldetailsWrapper stdGDW : cPGW.stdGoalDetails) {
                    
                    //Check for Row
                    if(cPGW.mapSelection.get(itemIndex) != null && cPGW.mapSelection.get(itemIndex))
                        stdGDW.stdGDetailPacings[itemIndex].selected = true;
                    else
                        stdGDW.stdGDetailPacings[itemIndex].selected = false;   
                }
            }
        }
        
        //Loop through the Main Wrapper list (List which is having all the contact with Std Goal Detial, Pacings and Personal Goal)
        for(CreatePersonalGoalsSectionWrapper cPGW : createPGSecWrapper) {
            
            //Set Values
            if(cPGW.businessTitlePercent == 0)
            cPGW.businessTitlePercent = null;
            
            if(cPGW.tenuredPercent == 0)
            cPGW.tenuredPercent = null;
            
            if(cPGW.cSTenuredPercent == 0)
            cPGW.cSTenuredPercent = null;
        }
        
        //Call method to parse blank in URL Parameters
        parseURLParameters();
        
        //Set flag to false
        isSelect = false;
        
    }
    
    /**
     *  @description    :   This method is used to execute the select row logic and perform the calculations
     *
     *  @args           :   
     *
     *  @return         :   void
     *
     **/
    public void doGlobalSelectRowAndCalc() {
        
        //Call the method to execute the select logic
        executeSelectRowLogic();
        
        isSelect = true;
        
        //Call the method for calculations
        doGoalCalculation();
        
    }
    /**
     *  @description    :   This method is used to do Amount calculation for all the Personal Goal Records
     *
     *  @args           :   
     *
     *  @return         :   void
     *
     **/        
    public void doGoalCalculation() {
        
        //Loop through the Main Wrapper list (List which is having all the contact with Std Goal Detial, Pacings and Personal Goal)
        for(CreatePersonalGoalsSectionWrapper cPGW : createPGSecWrapper) {
            
            //Integer to Calculate Proper Amount
            Decimal conMultipliers = 1;
            
            //Check for sales Role Percentage
            if(cPGW.businessTitlePercent != null && cPGW.businessTitlePercent != 0)
                conMultipliers =  conMultipliers * (cPGW.businessTitlePercent/100);
            
            //Check for tenured Percentage
            //V_1.6 - Modified - Rajeev Jain - 04/10/2016 - CR - 9688 - ISSP Deployment E
            //Commented out the code of Gloabal tenured multiplier, instead apply it on each individual goal level.
            /*if(cPGW.tenured && cPGW.tenuredPercent != null && cPGW.tenuredPercent != 0)
                conMultipliers =  conMultipliers * (cPGW.tenuredPercent/100);
            else if(!cPGW.tenured && cPGW.cSTenuredPercent != null && cPGW.cSTenuredPercent != 0)
                conMultipliers =  conMultipliers * (cPGW.cSTenuredPercent/100);*/
            //V_1.6 - Modified - Rajeev Jain - 04/10/2016 - CR - 9688 - ISSP Deployment E - upto here
            
            //Map to hold the Unique Key (Payee Id + GTD Id)as key and Instance of personal goal as value
            //This map will used to perform the calculations for summary goals
            Map<String, Map<String,Personal_Goal__c>> mapSummaryCalcs = new Map<String, Map<String,Personal_Goal__c>>();
            
            //Variable to hold the max pacings row size
            Integer maxPacings = maxGTDPRows(cPGW);
            
            //Loop through the Pacing for 0th Std Goal Detail
            for(Integer i = 0; i < maxPacings; i++) {
                
                //Call the method to perform the calculation
                doPersonlGoalCalculation(cPGW, cPGW.stdGoalDetails, conMultipliers, i, mapSummaryCalcs, cPGW.conId, null, true);
            }
            
            //V_1.4 - Modified - Rajeev Jain - 03/22/2016 - CR-20160316-9698 - ISSP SFDC Critical NBB Calculation Fixes
            //After completing the Goal Summary calculation we can calculate for Those which are as a child of Baseline
            //So calculate here in sequence from top parent to bottom.
            //In order to accomplish this Just create sequence
            for(Integer i = 0; i < maxPacings; i++) {
                
                //Call the method to perform the calculation
                doBaseLineCalculations(cPGW, cPGW.stdGoalDetails, conMultipliers, i, mapSummaryCalcs, cPGW.conId, null, true);
            }
            //V_1.4 - Modified - Rajeev Jain - 03/22/2016 - CR-20160316-9698 - ISSP SFDC Critical NBB Calculation Fixes - Upto here
            
            //Call method to perform the Summary PG calcs
            summaryPGCalcs(cPGW.stdGoalDetails, mapSummaryCalcs, conMultipliers, cPGW.conId, null, null, false);
            
            //Again call baseline Caluclation Method, this time only for thos Goals which parents are populated as a Basline but parents are having summary checkbox true
            //V_1.4 - Modified - Rajeev Jain - 03/22/2016 - CR-20160316-9698 - ISSP SFDC Critical NBB Calculation Fixes
            //After completing the Goal Summary calculation we can calculate for Those which are as a child of Baseline
            //So calculate here in sequence from top parent to bottom.
            //In order to accomplish this Just create sequence
            for(Integer i = 0; i < maxPacings; i++) {
                
                //Call the method to perform the calculation
                doBaseLineCalculations(cPGW, cPGW.stdGoalDetails, conMultipliers, i, mapSummaryCalcs, cPGW.conId, null, true);
            }
            
            //Mark is caluclated false once transaction get complete
            for(Integer i = 0; i < maxPacings; i++) {
                for(CreatePersonalGoalsSectionWrapper.StdGoaldetailsWrapper stdGDW : cPGW.stdGoalDetails) {
                    if(stdGDW.stdGDetailPacings.size() > i && String.isNotBlank(stdGDW.stdGDetailPacings[i].stdGDPacing.Description__c)){
                        stdGDW.stdGDetailPacings[i].isCalculated = false;
                        stdGDW.stdGDetailPacings[i].labelColorBTMultiplier = 'black';
                        stdGDW.stdGDetailPacings[i].labelColorAdjustmentValue = 'black';
                        stdGDW.stdGDetailPacings[i].labelColorTenured = 'black';
                        stdGDW.stdGDetailPacings[i].labelColorValue = 'black';
                        stdGDW.stdGDetailPacings[i].labelColorTenuredFlag = 'black';
                    }
                }
            }
            //Set Values
            if(cPGW.businessTitlePercent == 0)
                cPGW.businessTitlePercent = null;
            
            if(cPGW.tenuredPercent == 0)
                cPGW.tenuredPercent = null;
            
            if(cPGW.cSTenuredPercent == 0)
                cPGW.cSTenuredPercent = null;
        }
        
        //Set flag to false
        isSelect = false;
    }
    
    /**
     *  @description    :   This method is used to do Amount calculation for all the Personal Goal Records which are child baseline of any other goal
     *
     *  @args           :   
     *
     *  @return         :   void
     *
     **/ 
     //V_1.4 - Added By  - Rajeev Jain - 03/22/2016 - CR-20160316-9698 - ISSP SFDC Critical NBB Calculation Fixes
    public void doBaseLineCalculations(CreatePersonalGoalsSectionWrapper cPGW, List<CreatePersonalGoalsSectionWrapper.StdGoaldetailsWrapper> stdGoalDetails, Decimal conMultipliers, Integer i, Map<String, Map<String,Personal_Goal__c>> mapSummaryCalcs, Id payeeId, Map<String, Personal_Goal__c> mapInlineSummaryCalcs, Boolean isUpdate){
        
        //Loop through Std Goal Detail Wrapper
        for(CreatePersonalGoalsSectionWrapper.StdGoaldetailsWrapper stdGDW : stdGoalDetails) {
            
            //Check for pacing description
            if(stdGDW.stdGDetailPacings.size() > i && String.isNotBlank(stdGDW.stdGDetailPacings[i].stdGDPacing.Description__c) && (!isSelect || stdGDW.stdGDetailPacings[i].pGoal.Id == null)) {
                
                if(stdGDW.stdGDetailPacings[i].stdGDPacing != null && stdGDW.stdGDetailPacings[i].stdGDPacing.Standard_Goal_Detail__r.BaseLine__c != null && !stdGDW.stdGDetailPacings[i].stdGDPacing.Standard_Goal_Detail__r.Summary__c){
                    performCalculationOnParentBaseLine(cPGW, stdGDW, conMultipliers, i, mapSummaryCalcs, payeeId, mapInlineSummaryCalcs, isUpdate, false); 
                }
            }
        }   
    }
    //V_1.4 - Added By - Rajeev Jain - 03/22/2016 - CR-20160316-9698 - ISSP SFDC Critical NBB Calculation Fixes - Upto here
    
    /**
     *  @description    :   This method is used to perform the goal calculation
     *
     *  @args           :   List<CreatePersonalGoalsSectionWrapper.StdGoaldetailsWrapper>, Decimal, Map<String, Map<String,Personal_Goal__c>>, Id, Map<Id, Personal_Goal__c>, Boolean
     *
     *  @return         :   void
     *
     **/
    private void doPersonlGoalCalculation(CreatePersonalGoalsSectionWrapper cPGW, List<CreatePersonalGoalsSectionWrapper.StdGoaldetailsWrapper> stdGoalDetails, Decimal conMultipliers, Integer i, Map<String, Map<String,Personal_Goal__c>> mapSummaryCalcs, Id payeeId, Map<String, Personal_Goal__c> mapInlineSummaryCalcs, Boolean isUpdate) {
        
        //Map to hold the List of Std Goal Detail wrapper with Unique Key (Std Goal Detail Baseline + Pacing Start Date)
        Map<String, List<CreatePersonalGoalsSectionWrapper.StdGoaldetailsWrapper>> mapBaselineWithSGDetails = new Map<String, List<CreatePersonalGoalsSectionWrapper.StdGoaldetailsWrapper>>();
        
        //Map to hold the Parent baseline (Where baseline is null) with calculated value
        Map<String,Decimal> mapParentBaselines = new Map<String, Decimal>();
        
        //Loop through Std Goal Detail Wrapper
        for(CreatePersonalGoalsSectionWrapper.StdGoaldetailsWrapper stdGDW : stdGoalDetails) {
            
            //Check for pacing description
            if(stdGDW.stdGDetailPacings.size() > i && String.isNotBlank(stdGDW.stdGDetailPacings[i].stdGDPacing.Description__c) && (!isSelect || stdGDW.stdGDetailPacings[i].pGoal.Id == null)) {
                
                //Check for Inline Map
                if(mapInlineSummaryCalcs != null && stdGDW.stdGDetailPacings[i].stdGDPacing != null && stdGDW.stdGDetailPacings[i].stdGDPacing.Standard_Goal_Detail__r.Summary__c)
                    mapInlineSummaryCalcs.put(payeeId + '-' + stdGDW.stdGDetailPacings[i].stdGDPacing.Standard_Goal_Detail__c, new Personal_Goal__c(Amount__c = 0, Count__c = 0, Percent__c = 0));    
                
                if(stdGDW.stdGDetailPacings[i].stdGDPacing != null && stdGDW.stdGDetailPacings[i].stdGDPacing.Standard_Goal_Detail__r.BaseLine__c != null){
                    
                    //Handle Such Records once Summarry calculation has performed, since summary type GTD can be a baseline of other one, then calculation must be performed based on summary data
                    continue;
                }        
                //Check for Summary
                if(stdGDW.stdGDetailPacings[i].stdGDPacing != null && !stdGDW.stdGDetailPacings[i].stdGDPacing.Standard_Goal_Detail__r.Summary__c) {
                       
                    Decimal payeeMultiplier = conMultipliers;
                    
                    //Check for PG Id
                    if(stdGDW.stdGDetailPacings[i].pGoal.Id != null)
                        stdGDW.stdGDetailPacings[i].isCalc = true;
                    
                    stdGDW.stdGDetailPacings[i].isCalculated = true;
                            
                    //Check for GT's Discount Type
                    if(stdGDW.stdGDetailPacings[i].stdGDPacing.Standard_Goal_Detail__r.Goal_Type__c != null
                        && stdGDW.stdGDetailPacings[i].stdGDPacing.Standard_Goal_Detail__r.Goal_Type__r.Discount_Type__c == ISSPConstants.GOAL_TYPE_DISCOUNT_TYPE_MULTIPLIERS) {           
                                           
                        //Check for Pacing amount
                        if(stdGDW.stdGDetailPacings[i].stdGDPacing.Amount__c > 0 || (stdGDW.stdGDetailPacings[i].stdGDPacing.Amount__c != null
                            && stdGDW.stdGDetailPacings[i].stdGDPacing.Count__c == null && stdGDW.stdGDetailPacings[i].stdGDPacing.Percent__c == null)) {
                            
                            //Check for Personal Goal amount/flag
                            if(isUpdate || stdGDW.stdGDetailPacings[i].pGoal.Amount__c == null) {
                                
                                //Update Amount
                                stdGDW.stdGDetailPacings[i].pGoal.Amount__c = payeeMultiplier *  stdGDW.stdGDetailPacings[i].stdGDPacing.Amount__c;
                                
                                //Subhash - 01/05/2016 - Condition commented to incorprate the Adj% and Adj value in the Calculation.
                                //Check for Target Type
                                //if(stdGDW.stdGDetailPacings[i].stdGDPacing.Standard_Goal_Detail__r.Target_Type__c != ISSPConstants.STANDARD_GOAL_DETAIL_TARGET_TYPE_EXPLICIT) {
                                
                                //V_1.6 - Modified - Rajeev Jain - 04/10/2016 - CR - 9688 - ISSP Deployment E
                                //Calculate Tenured multiplier on each gaol level
                                if(stdGDW.stdGDetailPacings[i].pGoal.Tenure_Percentage__c != null && stdGDW.stdGDetailPacings[i].pGoal.Tenure_Percentage__c > 0)
                                    stdGDW.stdGDetailPacings[i].pGoal.Amount__c *= (stdGDW.stdGDetailPacings[i].pGoal.Tenure_Percentage__c/100);
                                   
                                //Add Extra BT multiplier amount
                                if(stdGDW.stdGDetailPacings[i].bTMultiplier != null
                                    && stdGDW.stdGDetailPacings[i].bTMultiplier > 0)
                                     stdGDW.stdGDetailPacings[i].pGoal.Amount__c *= (stdGDW.stdGDetailPacings[i].bTMultiplier/100);
                                
                                //Add Adjustment value
                                if(String.isNotBlank(stdGDW.stdGDetailPacings[i].adjustmentValue))
                                     stdGDW.stdGDetailPacings[i].pGoal.Amount__c += Decimal.valueOf(stdGDW.stdGDetailPacings[i].adjustmentValue);
                                //}
                                
                                //Round the calculation according to standard criteria
                                Integer multiplier = Math.ROUND(stdGDW.stdGDetailPacings[i].pGoal.Amount__c/ISSPConstants.CREATE_PERSONAL_GOAL_MULTIPLIER);
                                
                                //Recalculate the Amount
                                stdGDW.stdGDetailPacings[i].pGoal.Amount__c = ISSPConstants.CREATE_PERSONAL_GOAL_MULTIPLIER * multiplier;
                                
                                //Check for Minimum value
                                if(stdGDW.stdGDetailPacings[i].stdGDPacing.Standard_Goal_Detail__r.Minimum__c > stdGDW.stdGDetailPacings[i].pGoal.Amount__c)
                                    stdGDW.stdGDetailPacings[i].pGoal.Amount__c = stdGDW.stdGDetailPacings[i].stdGDPacing.Standard_Goal_Detail__r.Minimum__c;
                                
                                //Check for Amount
                                if(stdGDW.stdGDetailPacings[i].pGoal.Amount__c == null)
                                    stdGDW.stdGDetailPacings[i].pGoal.Amount__c = 0;
                                
                                //Set Count and Percent to null
                                stdGDW.stdGDetailPacings[i].pGoal.Count__c = null;
                                stdGDW.stdGDetailPacings[i].pGoal.Percent__c = null;
                            }
                                    
                            //Unique key
                            String pUniqueKey = stdGDW.stdGDetailPacings[i].stdGDPacing.Standard_Goal_Detail__c + '-' + stdGDW.stdGDetailPacings[i].stdGDPacing.Period_Start__c
                                                + '-' + ISSPConstants.PERSONAL_GOAL_VALUE_TYPE_AMOUNT;   
                            //Populate map
                            mapParentBaselines.put(pUniqueKey, stdGDW.stdGDetailPacings[i].pGoal.Amount__c);
                                                        
                            //Unique key
                            String uniqueKey = stdGDW.stdGDetailPacings[i].stdGDPacing.Standard_Goal_Detail__c + '-' + stdGDW.stdGDetailPacings[i].stdGDPacing.Period_Start__c;
                            
                            //Check if map contains the parent baseline and call utility method to populate child baselines
                                if(mapBaselineWithSGDetails.containsKey(uniqueKey)){}
                                //executeGoalCalculationLogic(mapBaselineWithSGDetails, uniqueKey, i, ISSPConstants.PERSONAL_GOAL_VALUE_TYPE_AMOUNT,
                                //                            stdGDW.stdGDetailPacings[i].pGoal.Amount__c, mapParentBaselines);
                                
                        
                        //Check for Pacing Count
                        } else if(stdGDW.stdGDetailPacings[i].stdGDPacing.Count__c > 0 || (stdGDW.stdGDetailPacings[i].stdGDPacing.Count__c != null
                            && stdGDW.stdGDetailPacings[i].stdGDPacing.Amount__c == null && stdGDW.stdGDetailPacings[i].stdGDPacing.Percent__c == null)) {
                            
                            //Check for Personal Goal count/flag
                            if(isUpdate || stdGDW.stdGDetailPacings[i].pGoal.Count__c == null) {
                                
                                //Update Count
                                stdGDW.stdGDetailPacings[i].pGoal.Count__c = payeeMultiplier * stdGDW.stdGDetailPacings[i].stdGDPacing.Count__c;
                                
                                //Subhash - 01/05/2016 - Condition commented to incorprate the Adj% and Adj value in the Calculation.
                                //Check for Target Type
                                //if(stdGDW.stdGDetailPacings[i].stdGDPacing.Standard_Goal_Detail__r.Target_Type__c != ISSPConstants.STANDARD_GOAL_DETAIL_TARGET_TYPE_EXPLICIT) {
                                
                                //V_1.6 - Modified - Rajeev Jain - 04/10/2016 - CR - 9688 - ISSP Deployment E
                                //Calculate Tenured multiplier on each gaol level
                                if(stdGDW.stdGDetailPacings[i].pGoal.Tenure_Percentage__c != null && stdGDW.stdGDetailPacings[i].pGoal.Tenure_Percentage__c > 0)
                                    stdGDW.stdGDetailPacings[i].pGoal.Count__c *= (stdGDW.stdGDetailPacings[i].pGoal.Tenure_Percentage__c/100);
                                    
                                //Add Extra BT multiplier amount
                                if(stdGDW.stdGDetailPacings[i].bTMultiplier != null
                                    && stdGDW.stdGDetailPacings[i].bTMultiplier > 0)
                                    stdGDW.stdGDetailPacings[i].pGoal.Count__c *= (stdGDW.stdGDetailPacings[i].bTMultiplier/100);
                                
                                //Add Adjustment value
                                if(String.isNotBlank(stdGDW.stdGDetailPacings[i].adjustmentValue))
                                    stdGDW.stdGDetailPacings[i].pGoal.Count__c += Decimal.valueOf(stdGDW.stdGDetailPacings[i].adjustmentValue);
                                //}
                                
                                //Round the calculation according to standard criteria
                                Integer multiplier = Math.ROUND(stdGDW.stdGDetailPacings[i].pGoal.Count__c/ISSPConstants.CREATE_PERSONAL_GOAL_MULTIPLIER);
                                
                                //Recalculate the Amount
                                stdGDW.stdGDetailPacings[i].pGoal.Count__c = ISSPConstants.CREATE_PERSONAL_GOAL_MULTIPLIER * multiplier;
                                
                                //Check for Minimum value
                                if(stdGDW.stdGDetailPacings[i].stdGDPacing.Standard_Goal_Detail__r.Minimum__c > stdGDW.stdGDetailPacings[i].pGoal.Count__c)
                                    stdGDW.stdGDetailPacings[i].pGoal.Count__c = stdGDW.stdGDetailPacings[i].stdGDPacing.Standard_Goal_Detail__r.Minimum__c;
                                
                                //Check for Amount
                                if(stdGDW.stdGDetailPacings[i].pGoal.Count__c == null)
                                    stdGDW.stdGDetailPacings[i].pGoal.Count__c = 0;
                                
                                //Set Count and Percent to null
                                stdGDW.stdGDetailPacings[i].pGoal.Amount__c = null;
                                stdGDW.stdGDetailPacings[i].pGoal.Percent__c = null;
                            }
                            
                            //Unique key
                            String pUniqueKey = stdGDW.stdGDetailPacings[i].stdGDPacing.Standard_Goal_Detail__c + '-' + stdGDW.stdGDetailPacings[i].stdGDPacing.Period_Start__c
                                                + '-' + ISSPConstants.PERSONAL_GOAL_VALUE_TYPE_COUNT;   
                            //Populate map
                            mapParentBaselines.put(pUniqueKey, stdGDW.stdGDetailPacings[i].pGoal.Count__c);
                            
                            //Unique key
                            String uniqueKey = stdGDW.stdGDetailPacings[i].stdGDPacing.Standard_Goal_Detail__c + '-' + stdGDW.stdGDetailPacings[i].stdGDPacing.Period_Start__c;
                            
                            //Check if map contains the parent baseline and call utility method to populate child baselines
                                if(mapBaselineWithSGDetails.containsKey(uniqueKey)){}
                                //executeGoalCalculationLogic(mapBaselineWithSGDetails, uniqueKey, i, ISSPConstants.PERSONAL_GOAL_VALUE_TYPE_COUNT,
                                //                            stdGDW.stdGDetailPacings[i].pGoal.Count__c,mapParentBaselines);
                        
                        } else if(stdGDW.stdGDetailPacings[i].stdGDPacing.Percent__c > 0 || (stdGDW.stdGDetailPacings[i].stdGDPacing.Percent__c != null
                            && stdGDW.stdGDetailPacings[i].stdGDPacing.Amount__c == null && stdGDW.stdGDetailPacings[i].stdGDPacing.Count__c == null)) {
                            
                            //Check for Personal Goal count/flag
                            if(isUpdate || stdGDW.stdGDetailPacings[i].pGoal.Percent__c == null) {
                            
                                //Update Percent
                                stdGDW.stdGDetailPacings[i].pGoal.Percent__c = payeeMultiplier * stdGDW.stdGDetailPacings[i].stdGDPacing.Percent__c;
                                
                                //Subhash - 01/05/2016 - Condition commented to incorprate the Adj% and Adj value in the Calculation.
                                //Check for Target Type
                                //if(stdGDW.stdGDetailPacings[i].stdGDPacing.Standard_Goal_Detail__r.Target_Type__c != ISSPConstants.STANDARD_GOAL_DETAIL_TARGET_TYPE_EXPLICIT) {
                                
                                //V_1.6 - Modified - Rajeev Jain - 04/10/2016 - CR - 9688 - ISSP Deployment E
                                //Calculate Tenured multiplier on each gaol level
                                if(stdGDW.stdGDetailPacings[i].pGoal.Tenure_Percentage__c != null && stdGDW.stdGDetailPacings[i].pGoal.Tenure_Percentage__c > 0)
                                    stdGDW.stdGDetailPacings[i].pGoal.Percent__c *= (stdGDW.stdGDetailPacings[i].pGoal.Tenure_Percentage__c/100);
                                        
                                //Apply Adj%
                                if(stdGDW.stdGDetailPacings[i].bTMultiplier != null
                                    && stdGDW.stdGDetailPacings[i].bTMultiplier > 0)
                                    stdGDW.stdGDetailPacings[i].pGoal.Percent__c *= (stdGDW.stdGDetailPacings[i].bTMultiplier/100);
                                
                                //Add Adjustment value
                                if(String.isNotBlank(stdGDW.stdGDetailPacings[i].adjustmentValue))
                                    stdGDW.stdGDetailPacings[i].pGoal.Percent__c += Decimal.valueOf(stdGDW.stdGDetailPacings[i].adjustmentValue);
                                //}
                                
                                //Round the calculation according to standard criteria
                                Integer multiplier = Math.ROUND(stdGDW.stdGDetailPacings[i].pGoal.Percent__c/ISSPConstants.CREATE_PERSONAL_GOAL_PERCENT_MULTIPLIER);
                               
                                //Recalculate the Percent
                                stdGDW.stdGDetailPacings[i].pGoal.Percent__c = ISSPConstants.CREATE_PERSONAL_GOAL_PERCENT_MULTIPLIER * multiplier;
                                
                                //Check for Amount
                                if(stdGDW.stdGDetailPacings[i].pGoal.Percent__c == null)
                                    stdGDW.stdGDetailPacings[i].pGoal.Percent__c = 0;
                                
                                //Set Count and Percent to null
                                stdGDW.stdGDetailPacings[i].pGoal.Amount__c = null;
                                stdGDW.stdGDetailPacings[i].pGoal.Count__c = null;
                            }
                            
                            //Unique key
                            String pUniqueKey = stdGDW.stdGDetailPacings[i].stdGDPacing.Standard_Goal_Detail__c + '-' + stdGDW.stdGDetailPacings[i].stdGDPacing.Period_Start__c
                                                + '-' + ISSPConstants.PERSONAL_GOAL_VALUE_TYPE_PERCENT;   
                            //Populate map
                            mapParentBaselines.put(pUniqueKey, stdGDW.stdGDetailPacings[i].pGoal.Percent__c);
                            
                            //Unique key
                            String uniqueKey = stdGDW.stdGDetailPacings[i].stdGDPacing.Standard_Goal_Detail__c + '-' + stdGDW.stdGDetailPacings[i].stdGDPacing.Period_Start__c;
                            
                            //Check if map contains the parent baseline and call utility method to populate child baselines
                                if(mapBaselineWithSGDetails.containsKey(uniqueKey)){}
                                //executeGoalCalculationLogic(mapBaselineWithSGDetails, uniqueKey, i, ISSPConstants.PERSONAL_GOAL_VALUE_TYPE_PERCENT,
                                //                            stdGDW.stdGDetailPacings[i].pGoal.Percent__c,mapParentBaselines);
                        }
                    
                    } else {
                        
                        //Directly put values
                        stdGDW.stdGDetailPacings[i].pGoal.Amount__c = stdGDW.stdGDetailPacings[i].stdGDPacing.Amount__c;
                        stdGDW.stdGDetailPacings[i].pGoal.Count__c = stdGDW.stdGDetailPacings[i].stdGDPacing.Count__c;
                        stdGDW.stdGDetailPacings[i].pGoal.Percent__c = stdGDW.stdGDetailPacings[i].stdGDPacing.Percent__c;
                    }
                    //Check for Parent
                    if(stdGDW.stdGDetailPacings.size() > i && stdGDW.stdGDetailPacings[i].stdGDPacing != null && stdGDW.stdGDetailPacings[i].stdGDPacing.Standard_Goal_Detail__r.Parent__c != null
                        && stdGDW.stdGDetailPacings[i].pGoal != null) {
                        
                        //Check for map
                        if(mapInlineSummaryCalcs == null || stdGDW.stdGDetailPacings[i].stdGDPacing.Standard_Goal_Detail__r.Parent__r.Period_Start__c == stdGDW.stdGDetailPacings[i].stdGDPacing.Standard_Goal_Detail__r.Period_Start__c) {
                            
                            //Map to hold the Current Personal Goal details
                            Map<String, Personal_Goal__c> mapCurrentPG = new Map<String,Personal_Goal__c>();
                            
                            //Unique Key
                            String uniqueKey = payeeId + '-' + stdGDW.stdGDetailPacings[i].stdGDPacing.Standard_Goal_Detail__r.Parent__c;
                            
                            //Check unique Key in map
                            if(!mapSummaryCalcs.containsKey(uniqueKey))
                                mapSummaryCalcs.put(uniqueKey, new Map<String,Personal_Goal__c>());
                            
                            //Put current records details in map
                            mapSummaryCalcs.get(uniqueKey).put(payeeId + '-' + stdGDW.stdGDetailPacings[i].stdGDPacing.Standard_Goal_Detail__c, stdGDW.stdGDetailPacings[i].pGoal);     
                        }
                    }
                }
            }
        }
    }
    
    /**
     *  @description    :   This method is used to do Amount calculation for all the Personal Goal Records which are child baseline of any other goal
     *
     *  @args           :   
     *
     *  @return         :   void
     *
     **/ 
     //V_1.4 - Added By  - Rajeev Jain - 03/22/2016 - CR-20160316-9698 - ISSP SFDC Critical NBB Calculation Fixes
    public void performCalculationOnParentBaseLine(CreatePersonalGoalsSectionWrapper cPGW, CreatePersonalGoalsSectionWrapper.StdGoaldetailsWrapper stdGDW, Decimal conMultipliers, Integer i, Map<String, Map<String,Personal_Goal__c>> mapSummaryCalcs, Id payeeId, Map<String, Personal_Goal__c> mapInlineSummaryCalcs, Boolean isUpdate, Boolean isItemCalculation){
        
        if(stdGDW != null && stdGDW.stdGDetailPacings.size() > i && String.isNotBlank(stdGDW.stdGDetailPacings[i].stdGDPacing.Description__c) && (!isSelect || stdGDW.stdGDetailPacings[i].pGoal.Id == null) && !stdGDW.stdGDetailPacings[i].stdGDPacing.Standard_Goal_Detail__r.Summary__c){
            
            if(stdGDW.stdGDetailPacings[i].stdGDPacing.Standard_Goal_Detail__r.BaseLine__c != null && !isItemCalculation){
                
                //Then Get the Instance of the Parent BaseLine and Pass it for further calculations
                String parentKey = stdGDW.stdGoalDetail.BaseLine__c + '-' +stdGDW.parentBaselineDescription + '-' + stdGDW.parentPeriodStart;
                
                //Get parent Instance and Pass it for further caculation
                performCalculationOnParentBaseLine(cPGW, cPGW.mapStdGoalDetails.get(parentKey), conMultipliers, i, mapSummaryCalcs, payeeId, mapInlineSummaryCalcs, isUpdate, false);
                
                //stdGDW.stdGDetailPacings[i].pGoal.Amount__c = payeeMultiplier *  stdGDW.stdGDetailPacings[i].stdGDPacing.Amount__c;
            }
            
            if(stdGDW.stdGDetailPacings.size() > i && stdGDW.stdGDetailPacings[i].stdGDPacing != null){
                    
                Decimal payeeMultiplier = conMultipliers;
                            
                //Check for PG Id
                if(stdGDW.stdGDetailPacings[i].pGoal.Id != null)
                    stdGDW.stdGDetailPacings[i].isCalc = true;
                
                //Check for Parent
                if(stdGDW.stdGDetailPacings.size() > i && stdGDW.stdGDetailPacings[i].stdGDPacing != null && stdGDW.stdGDetailPacings[i].stdGDPacing.Standard_Goal_Detail__r.Parent__c != null
                    && stdGDW.stdGDetailPacings[i].pGoal != null) {
                    
                    if(mapInlineSummaryCalcs == null || stdGDW.stdGDetailPacings[i].stdGDPacing.Standard_Goal_Detail__r.Parent__r.Period_Start__c == stdGDW.stdGDetailPacings[i].stdGDPacing.Standard_Goal_Detail__r.Period_Start__c) {
                        
                        //Map to hold the Current Personal Goal details
                        Map<String, Personal_Goal__c> mapCurrentPG = new Map<String,Personal_Goal__c>();
                        
                        //Unique Key
                        String uniqueKey = payeeId + '-' + stdGDW.stdGDetailPacings[i].stdGDPacing.Standard_Goal_Detail__r.Parent__c;
                        
                        //Check unique Key in map
                        if(!mapSummaryCalcs.containsKey(uniqueKey))
                            mapSummaryCalcs.put(uniqueKey, new Map<String,Personal_Goal__c>());
                        
                        //Put current records details in map
                        mapSummaryCalcs.get(uniqueKey).put(payeeId + '-' + stdGDW.stdGDetailPacings[i].stdGDPacing.Standard_Goal_Detail__c, stdGDW.stdGDetailPacings[i].pGoal); 
                    }
                }
                
                if(stdGDW.stdGDetailPacings[i].isCalculated)
                    return;
                    
                //Check for GT's Discount Type
                if(stdGDW.stdGDetailPacings[i].stdGDPacing.Standard_Goal_Detail__r.Goal_Type__c != null
                    && stdGDW.stdGDetailPacings[i].stdGDPacing.Standard_Goal_Detail__r.Goal_Type__r.Discount_Type__c == ISSPConstants.GOAL_TYPE_DISCOUNT_TYPE_MULTIPLIERS) {
                    
                    //Check for Pacing amount
                    if(stdGDW.stdGDetailPacings[i].stdGDPacing.Amount__c > 0 || (stdGDW.stdGDetailPacings[i].stdGDPacing.Amount__c != null
                        && stdGDW.stdGDetailPacings[i].stdGDPacing.Count__c == null && stdGDW.stdGDetailPacings[i].stdGDPacing.Percent__c == null)) {
                        
                        //Check for Personal Goal amount/flag
                        if(isUpdate || stdGDW.stdGDetailPacings[i].pGoal.Amount__c == null) {
                            
                            if(stdGDW.stdGDetailPacings[i].stdGDPacing.Standard_Goal_Detail__r.BaseLine__c != null){
                                
                                String pKey = stdGDW.stdGoalDetail.BaseLine__c + '-' +stdGDW.parentBaselineDescription + '-' + stdGDW.parentPeriodStart;
                                
                                //Loop over to Pacings of the Parent
                                for(CreatePersonalGoalsSectionWrapper.StdGoalDetailPacingWrapper pacing : cPGW.mapStdGoalDetails.get(pKey).stdGDetailPacings){
                                    
                                    if(pacing.pGoal.Amount__c != null){
                                        
                                        if(stdGDW.stdGoalDetail.Baseline_Percentage__c != null && stdGDW.stdGoalDetail.Baseline_Percentage__c > 0){
                                            
                                            //Since this is the child of Baseline, so we are not applying payeeMultiplier again on this
                                            //stdGDW.stdGDetailPacings[i].pGoal.Amount__c = payeeMultiplier *  (pacing.pGoal.Amount__c*stdGDW.stdGoalDetail.Baseline_Percentage__c/100).setScale(0);
                                            stdGDW.stdGDetailPacings[i].pGoal.Amount__c = (pacing.pGoal.Amount__c*stdGDW.stdGoalDetail.Baseline_Percentage__c/100).setScale(0);
                                            
                                        }else{
                                            stdGDW.stdGDetailPacings[i].pGoal.Amount__c = pacing.pGoal.Amount__c;
                                        }
                                        break;  
                                    }
                                }
                                if(stdGDW.stdGDetailPacings[i].pGoal.Amount__c == null || stdGDW.stdGDetailPacings[i].pGoal.Amount__c == 0){
                                    stdGDW.stdGDetailPacings[i].pGoal.Amount__c = stdGDW.stdGDetailPacings[i].stdGDPacing.Amount__c;
                                }
                            }else{
                                //Update Amount
                                //stdGDW.stdGDetailPacings[i].pGoal.Amount__c = payeeMultiplier *  stdGDW.stdGDetailPacings[i].stdGDPacing.Amount__c;
                            }
                            
                            //V_1.6 - Modified - Rajeev Jain - 04/10/2016 - CR - 9688 - ISSP Deployment E
                            //Calculate Tenured multiplier on each gaol level
                            if(stdGDW.stdGDetailPacings[i].pGoal.Tenure_Percentage__c != null && stdGDW.stdGDetailPacings[i].pGoal.Tenure_Percentage__c > 0)
                                stdGDW.stdGDetailPacings[i].pGoal.Amount__c *= (stdGDW.stdGDetailPacings[i].pGoal.Tenure_Percentage__c/100);
                            
                            //Add Extra BT multiplier amount
                            if(stdGDW.stdGDetailPacings[i].bTMultiplier != null
                                && stdGDW.stdGDetailPacings[i].bTMultiplier > 0)
                                 stdGDW.stdGDetailPacings[i].pGoal.Amount__c *= (stdGDW.stdGDetailPacings[i].bTMultiplier/100);
                            
                            //Add Adjustment value
                            if(String.isNotBlank(stdGDW.stdGDetailPacings[i].adjustmentValue))
                                 stdGDW.stdGDetailPacings[i].pGoal.Amount__c += Decimal.valueOf(stdGDW.stdGDetailPacings[i].adjustmentValue);
                           
                            //Round the calculation according to standard criteria
                            Integer multiplier = Math.ROUND(stdGDW.stdGDetailPacings[i].pGoal.Amount__c/ISSPConstants.CREATE_PERSONAL_GOAL_MULTIPLIER);
                            
                            //Recalculate the Amount
                            stdGDW.stdGDetailPacings[i].pGoal.Amount__c = ISSPConstants.CREATE_PERSONAL_GOAL_MULTIPLIER * multiplier;
                            
                            //Check for Minimum value
                            if(stdGDW.stdGDetailPacings[i].stdGDPacing.Standard_Goal_Detail__r.Minimum__c > stdGDW.stdGDetailPacings[i].pGoal.Amount__c)
                                stdGDW.stdGDetailPacings[i].pGoal.Amount__c = stdGDW.stdGDetailPacings[i].stdGDPacing.Standard_Goal_Detail__r.Minimum__c;
                            
                            //Check for Amount
                            if(stdGDW.stdGDetailPacings[i].pGoal.Amount__c == null)
                                stdGDW.stdGDetailPacings[i].pGoal.Amount__c = 0;
                            
                            //Set Count and Percent to null
                            stdGDW.stdGDetailPacings[i].pGoal.Count__c = null;
                            stdGDW.stdGDetailPacings[i].pGoal.Percent__c = null;
                        }
                    }else if(stdGDW.stdGDetailPacings[i].stdGDPacing.Count__c > 0 || (stdGDW.stdGDetailPacings[i].stdGDPacing.Count__c != null
                                        && stdGDW.stdGDetailPacings[i].stdGDPacing.Amount__c == null && stdGDW.stdGDetailPacings[i].stdGDPacing.Percent__c == null)) {
                                        
                        //Check for Personal Goal count/flag
                        if(isUpdate || stdGDW.stdGDetailPacings[i].pGoal.Count__c == null) {
                                        
                            if(stdGDW.stdGDetailPacings[i].stdGDPacing.Standard_Goal_Detail__r.BaseLine__c != null){
                                            
                                String pKey = stdGDW.stdGoalDetail.BaseLine__c + '-' +stdGDW.parentBaselineDescription + '-' + stdGDW.parentPeriodStart;
                                
                                //Loop over to Pacings of the Parent
                                for(CreatePersonalGoalsSectionWrapper.StdGoalDetailPacingWrapper pacing : cPGW.mapStdGoalDetails.get(pKey).stdGDetailPacings){
                                    if(pacing.pGoal.Count__c != null){
                                        
                                        if(stdGDW.stdGoalDetail.Baseline_Percentage__c != null && stdGDW.stdGoalDetail.Baseline_Percentage__c > 0)
                                            stdGDW.stdGDetailPacings[i].pGoal.Count__c = (pacing.pGoal.Count__c*stdGDW.stdGoalDetail.Baseline_Percentage__c/100).setScale(0);
                                        else
                                            stdGDW.stdGDetailPacings[i].pGoal.Count__c =  pacing.pGoal.Count__c;
                                        break;  
                                    }
                                }
                                if(stdGDW.stdGDetailPacings[i].pGoal.Count__c == null || stdGDW.stdGDetailPacings[i].pGoal.Count__c == 0){
                                    stdGDW.stdGDetailPacings[i].pGoal.Count__c = stdGDW.stdGDetailPacings[i].stdGDPacing.Count__c;
                                }
                            }else{
                                
                                //Update Count
                                //stdGDW.stdGDetailPacings[i].pGoal.Count__c = payeeMultiplier * stdGDW.stdGDetailPacings[i].stdGDPacing.Count__c;   
                            }   
                            
                            //V_1.6 - Modified - Rajeev Jain - 04/10/2016 - CR - 9688 - ISSP Deployment E
                            //Calculate Tenured multiplier on each gaol level
                            if(stdGDW.stdGDetailPacings[i].pGoal.Tenure_Percentage__c != null && stdGDW.stdGDetailPacings[i].pGoal.Tenure_Percentage__c > 0)
                                stdGDW.stdGDetailPacings[i].pGoal.Count__c *= (stdGDW.stdGDetailPacings[i].pGoal.Tenure_Percentage__c/100);
                                
                            //Add Extra BT multiplier amount
                            if(stdGDW.stdGDetailPacings[i].bTMultiplier != null
                                && stdGDW.stdGDetailPacings[i].bTMultiplier > 0)
                                stdGDW.stdGDetailPacings[i].pGoal.Count__c *= (stdGDW.stdGDetailPacings[i].bTMultiplier/100);
                            
                            //Add Adjustment value
                            if(String.isNotBlank(stdGDW.stdGDetailPacings[i].adjustmentValue))
                                stdGDW.stdGDetailPacings[i].pGoal.Count__c += Decimal.valueOf(stdGDW.stdGDetailPacings[i].adjustmentValue);
                           
                            
                            //Round the calculation according to standard criteria
                            Integer multiplier = Math.ROUND(stdGDW.stdGDetailPacings[i].pGoal.Count__c/ISSPConstants.CREATE_PERSONAL_GOAL_MULTIPLIER);
                            
                            //Recalculate the Amount
                            stdGDW.stdGDetailPacings[i].pGoal.Count__c = ISSPConstants.CREATE_PERSONAL_GOAL_MULTIPLIER * multiplier;
                            
                            //Check for Minimum value
                            if(stdGDW.stdGDetailPacings[i].stdGDPacing.Standard_Goal_Detail__r.Minimum__c > stdGDW.stdGDetailPacings[i].pGoal.Count__c)
                                stdGDW.stdGDetailPacings[i].pGoal.Count__c = stdGDW.stdGDetailPacings[i].stdGDPacing.Standard_Goal_Detail__r.Minimum__c;
                            
                            //Check for Amount
                            if(stdGDW.stdGDetailPacings[i].pGoal.Count__c == null)
                                stdGDW.stdGDetailPacings[i].pGoal.Count__c = 0;
                            
                            //Set Count and Percent to null
                            stdGDW.stdGDetailPacings[i].pGoal.Amount__c = null;
                            stdGDW.stdGDetailPacings[i].pGoal.Percent__c = null;
                        }
                        
                    }else if(stdGDW.stdGDetailPacings[i].stdGDPacing.Percent__c > 0 || (stdGDW.stdGDetailPacings[i].stdGDPacing.Percent__c != null
                                        && stdGDW.stdGDetailPacings[i].stdGDPacing.Amount__c == null && stdGDW.stdGDetailPacings[i].stdGDPacing.Count__c == null)) {
                                        
                        //Check for Personal Goal count/flag
                        if(isUpdate || stdGDW.stdGDetailPacings[i].pGoal.Percent__c == null) {
                            
                            if(stdGDW.stdGDetailPacings[i].stdGDPacing.Standard_Goal_Detail__r.BaseLine__c != null){
                            
                                String pKey = stdGDW.stdGoalDetail.BaseLine__c + '-' +stdGDW.stdGoalDetail.BaseLine__r.Description__c + '-' + stdGDW.stdGoalDetail.BaseLine__r.Period_Start__c;
                                                            
                                //Loop over to Pacings of the Parent
                                for(CreatePersonalGoalsSectionWrapper.StdGoalDetailPacingWrapper pacing : cPGW.mapStdGoalDetails.get(pKey).stdGDetailPacings){
                                    if(pacing.pGoal.Percent__c != null){
                                        
                                        if(stdGDW.stdGoalDetail.Baseline_Percentage__c != null && stdGDW.stdGoalDetail.Baseline_Percentage__c > 0)
                                            stdGDW.stdGDetailPacings[i].pGoal.Percent__c = (pacing.pGoal.Percent__c*stdGDW.stdGoalDetail.Baseline_Percentage__c/100).setScale(0);
                                        else
                                            stdGDW.stdGDetailPacings[i].pGoal.Percent__c = pacing.pGoal.Percent__c;
                                        break;  
                                    }
                                }
                                if(stdGDW.stdGDetailPacings[i].pGoal.Percent__c == null || stdGDW.stdGDetailPacings[i].pGoal.Percent__c == 0){
                                    stdGDW.stdGDetailPacings[i].pGoal.Percent__c = stdGDW.stdGDetailPacings[i].stdGDPacing.Percent__c;
                                }
                            }else{
                                
                                //Update Percent
                               // stdGDW.stdGDetailPacings[i].pGoal.Percent__c = payeeMultiplier *  stdGDW.stdGDetailPacings[i].stdGDPacing.Percent__c;
                            }   
                            
                            //V_1.6 - Modified - Rajeev Jain - 04/10/2016 - CR - 9688 - ISSP Deployment E
                            //Calculate Tenured multiplier on each gaol level
                            if(stdGDW.stdGDetailPacings[i].pGoal.Tenure_Percentage__c != null && stdGDW.stdGDetailPacings[i].pGoal.Tenure_Percentage__c > 0)
                                stdGDW.stdGDetailPacings[i].pGoal.Percent__c *= (stdGDW.stdGDetailPacings[i].pGoal.Tenure_Percentage__c/100);
                                
                            //Apply Adj%
                            if(stdGDW.stdGDetailPacings[i].bTMultiplier != null
                                && stdGDW.stdGDetailPacings[i].bTMultiplier > 0)
                                stdGDW.stdGDetailPacings[i].pGoal.Percent__c *= (stdGDW.stdGDetailPacings[i].bTMultiplier/100);
                            
                            //Add Adjustment value
                            if(String.isNotBlank(stdGDW.stdGDetailPacings[i].adjustmentValue))
                                stdGDW.stdGDetailPacings[i].pGoal.Percent__c += Decimal.valueOf(stdGDW.stdGDetailPacings[i].adjustmentValue);
                            
                            
                            //Round the calculation according to standard criteria
                            Integer multiplier = Math.ROUND(stdGDW.stdGDetailPacings[i].pGoal.Percent__c/ISSPConstants.CREATE_PERSONAL_GOAL_PERCENT_MULTIPLIER);
                           
                            //Recalculate the Percent
                            stdGDW.stdGDetailPacings[i].pGoal.Percent__c = ISSPConstants.CREATE_PERSONAL_GOAL_PERCENT_MULTIPLIER * multiplier;
                            
                            //Check for Amount
                            if(stdGDW.stdGDetailPacings[i].pGoal.Percent__c == null)
                                stdGDW.stdGDetailPacings[i].pGoal.Percent__c = 0;
                            
                            //Set Count and Percent to null
                            stdGDW.stdGDetailPacings[i].pGoal.Amount__c = null;
                            stdGDW.stdGDetailPacings[i].pGoal.Count__c = null;
                        
                        }
                    } 
                }else{
                    
                    //Directly put values
                    stdGDW.stdGDetailPacings[i].pGoal.Amount__c = stdGDW.stdGDetailPacings[i].stdGDPacing.Amount__c;
                    stdGDW.stdGDetailPacings[i].pGoal.Count__c = stdGDW.stdGDetailPacings[i].stdGDPacing.Count__c;
                    stdGDW.stdGDetailPacings[i].pGoal.Percent__c = stdGDW.stdGDetailPacings[i].stdGDPacing.Percent__c;
                }
            }
        }
    }
    //V_1.4 - Modified - Rajeev Jain - 03/22/2016 - CR-20160316-9698 - ISSP SFDC Critical NBB Calculation Fixes - Upto here
    
    /**
     *  @description    :   This method is used to perform the calculations for Summary PGs
     *
     *  @args           :   List<CreatePersonalGoalsSectionWrapper.StdGoaldetailsWrapper>, Map<String, Personal_Goal__c>, Decimal, Id, String, Integer
     *
     *  @return         :   void
     *
     **/
    private void summaryPGCalcs(List<CreatePersonalGoalsSectionWrapper.StdGoaldetailsWrapper> stdGoalDetails, Map<String, Map<String,Personal_Goal__c>> mapSummaryCalcs, Decimal conMultipliers, Id payeeId, String currentPUK, Integer itemIndex, Boolean isItemCalculation) {
        
        //Map to hold the Parent GTDs Detail
        Map<String, Map<String,Personal_Goal__c>> mapSummaryGTDs = new Map<String, Map<String,Personal_Goal__c>>();
        
        //Variable to hold the Item Index
        Integer currentItemIndex = 0;
        
        //Loop through Std Goal Detail Wrapper
        for(CreatePersonalGoalsSectionWrapper.StdGoaldetailsWrapper stdGDW : stdGoalDetails) {
            
            //Loop through the Pacings
            for(CreatePersonalGoalsSectionWrapper.StdGoalDetailPacingWrapper pG : stdGDW.stdGDetailPacings) {
            
                //Check for pacing description
                if(pG.stdGDPacing != null && String.isNotBlank(pG.stdGDPacing.Description__c) && (!isSelect || pG.pGoal.Id == null)
                    && pG.stdGDPacing.Standard_Goal_Detail__r.Summary__c) {
                
                    //Unique Key
                    String uniqueKey = payeeId + '-' + pG.stdGDPacing.Standard_Goal_Detail__c;
                    
                    //Check for unique Key in map
                    if(mapSummaryCalcs.containsKey(uniqueKey) && (pG.stdGDPacing.Standard_Goal_Detail__r.Parent__c != null || itemIndex != currentItemIndex)) {
                        
                        //Update Amount, Count and Percentage
                        Personal_Goal__c summaryPG = sUMsToCalc(mapSummaryCalcs.get(uniqueKey));
                        
                        //Check for Values
                        if(summaryPG.Amount__c > 0)
                            pG.pGoal.Amount__c = summaryPG.Amount__c;
                        
                        else if(summaryPG.Count__c > 0)
                            pG.pGoal.Count__c = summaryPG.Count__c;
                        
                        else if(summaryPG.Percent__c > 0)
                            pG.pGoal.Percent__c = summaryPG.Percent__c; 

                        //Variable to check for discount type
                        Decimal payeeMultiplier = conMultipliers;
                    
                        //Check for PG Id
                        if(pG.pGoal.Id != null)
                            pG.isCalc = true;
                            
                        //Check for GT's Discount Type
                        if(pG.stdGDPacing.Standard_Goal_Detail__r.Goal_Type__c != null
                            && pG.stdGDPacing.Standard_Goal_Detail__r.Goal_Type__r.Discount_Type__c == ISSPConstants.GOAL_TYPE_DISCOUNT_TYPE_MULTIPLIERS) {           
                            
                            //Check for Pacing amount
                            if(pG.pGoal.Amount__c > 0 || (pG.pGoal.Amount__c != null && pG.pGoal.Count__c == null && pG.pGoal.Percent__c == null)) {
                                
                                //Check for GTD Discount
                                if(pG.stdGDPacing.Standard_Goal_Detail__r.Discount__c > 0)
                                    pG.pGoal.Amount__c = pG.pGoal.Amount__c - (pG.pGoal.Amount__c * (pG.stdGDPacing.Standard_Goal_Detail__r.Discount__c/100));
                                
                                //Update Amount
                                //pG.pGoal.Amount__c = payeeMultiplier *  pG.pGoal.Amount__c;
                                
                                //Subhash - 01/05/2016 - Condition commented to incorprate the Adj% and Adj value in the Calculation. 
                                //Check for Target Type
                                //if(pG.stdGDPacing.Standard_Goal_Detail__r.Target_Type__c != ISSPConstants.STANDARD_GOAL_DETAIL_TARGET_TYPE_EXPLICIT) {
                                
                                //V_1.6 - Modified - Rajeev Jain - 04/10/2016 - CR - 9688 - ISSP Deployment E
                                //Calculate Tenured multiplier on each gaol level
                                if(pG.pGoal.Tenure_Percentage__c != null && pG.pGoal.Tenure_Percentage__c > 0)
                                    pG.pGoal.Amount__c *= (pG.pGoal.Tenure_Percentage__c/100);
                                    
                                //Add Extra BT multiplier amount
                                if(pG.bTMultiplier != null && pG.bTMultiplier > 0)
                                     pG.pGoal.Amount__c *= (pG.bTMultiplier/100);
                            
                                //Add Adjustment value
                                if(String.isNotBlank(pG.adjustmentValue))
                                     pG.pGoal.Amount__c += Decimal.valueOf(pG.adjustmentValue);
                                //}
                                
                                //Round the calculation according to standard criteria
                                Integer multiplier = Math.ROUND(pG.pGoal.Amount__c/ISSPConstants.CREATE_PERSONAL_GOAL_MULTIPLIER);
                                
                                //Recalculate the Amount
                                pG.pGoal.Amount__c = ISSPConstants.CREATE_PERSONAL_GOAL_MULTIPLIER * multiplier;
                            
                                //Check for Minimum value
                                if(pG.stdGDPacing.Standard_Goal_Detail__r.Minimum__c > pG.pGoal.Amount__c)
                                    pG.pGoal.Amount__c = pG.stdGDPacing.Standard_Goal_Detail__r.Minimum__c;
                            
                                //Check for Amount
                                if(pG.pGoal.Amount__c == null)
                                    pG.pGoal.Amount__c = 0;
                                
                                //Set Count and Percent to null
                                pG.pGoal.Count__c = null;
                                pG.pGoal.Percent__c = null;
                            
                            //Check for Pacing Count
                            } else if(pG.pGoal.Count__c > 0 || (pG.pGoal.Count__c != null && pG.pGoal.Amount__c == null
                                        && pG.pGoal.Percent__c == null)) {
                                
                                //Apply GTD Discount
                                if(pG.stdGDPacing.Standard_Goal_Detail__r.Discount__c > 0)
                                    pG.pGoal.Count__c = pG.pGoal.Count__c - (pG.pGoal.Count__c * (pG.stdGDPacing.Standard_Goal_Detail__r.Discount__c/100));
                                
                                //Update Count
                                //pG.pGoal.Count__c = payeeMultiplier * pG.pGoal.Count__c;
                                
                                //Subhash - 01/05/2016 - Condition commented to incorprate the Adj% and Adj value in the Calculation.
                                //Check for Target Type
                                //if(pG.pGoal.Standard_Goal_Detail__r.Target_Type__c != ISSPConstants.STANDARD_GOAL_DETAIL_TARGET_TYPE_EXPLICIT) {
                                
                                //V_1.6 - Modified - Rajeev Jain - 04/10/2016 - CR - 9688 - ISSP Deployment E
                                //Calculate Tenured multiplier on each gaol level
                                if(pG.pGoal.Tenure_Percentage__c != null && pG.pGoal.Tenure_Percentage__c > 0)
                                    pG.pGoal.Count__c *= (pG.pGoal.Tenure_Percentage__c/100);
                                    
                                //Add Extra BT multiplier amount
                                if(pG.bTMultiplier != null && pG.bTMultiplier > 0)
                                    pG.pGoal.Count__c *= (pG.bTMultiplier/100);
                                
                                //Add Adjustment value
                                if(String.isNotBlank(pG.adjustmentValue))
                                    pG.pGoal.Count__c += Decimal.valueOf(pG.adjustmentValue);
                                //}
                            
                                //Round the calculation according to standard criteria
                                Integer multiplier = Math.ROUND(pG.pGoal.Count__c/ISSPConstants.CREATE_PERSONAL_GOAL_MULTIPLIER);
                                
                                //Recalculate the Amount
                                pG.pGoal.Count__c = ISSPConstants.CREATE_PERSONAL_GOAL_MULTIPLIER * multiplier;
                            
                                //Check for Minimum value
                                if(pG.stdGDPacing.Standard_Goal_Detail__r.Minimum__c > pG.pGoal.Count__c)
                                    pG.pGoal.Count__c = pG.stdGDPacing.Standard_Goal_Detail__r.Minimum__c;
                                
                                //Check for Count
                                if(pG.pGoal.Count__c == null)
                                    pG.pGoal.Count__c = 0;
                                
                                //Set Count and Percent to null
                                pG.pGoal.Amount__c = null;
                                pG.pGoal.Percent__c = null;
                            
                            
                            } else if(pG.pGoal.Percent__c > 0 || (pG.pGoal.Percent__c != null && pG.pGoal.Amount__c == null
                                        && pG.pGoal.Count__c == null)) {
                                
                                //Apply GTD Discount
                                if(pG.stdGDPacing.Standard_Goal_Detail__r.Discount__c > 0)
                                    pG.pGoal.Percent__c = pG.pGoal.Percent__c - (pG.pGoal.Percent__c * (pG.stdGDPacing.Standard_Goal_Detail__r.Discount__c/100));
                                
                                //Update Percent
                                //pG.pGoal.Percent__c = payeeMultiplier * pG.pGoal.Percent__c;
                                
                                //Subhash - 01/05/2016 - Condition commented to incorprate the Adj% and Adj value in the Calculation.
                                //Check for Target Type
                                //if(pG.stdGDPacing.Standard_Goal_Detail__r.Target_Type__c != ISSPConstants.STANDARD_GOAL_DETAIL_TARGET_TYPE_EXPLICIT) {
                                
                                //V_1.6 - Modified - Rajeev Jain - 04/10/2016 - CR - 9688 - ISSP Deployment E
                                //Calculate Tenured multiplier on each gaol level
                                if(pG.pGoal.Tenure_Percentage__c != null && pG.pGoal.Tenure_Percentage__c > 0)
                                    pG.pGoal.Percent__c *= (pG.pGoal.Tenure_Percentage__c/100);
                                        
                                //Add Extra BT multiplier amount
                                if(pG.bTMultiplier != null && pG.bTMultiplier > 0)
                                    pG.pGoal.Percent__c *= (pG.bTMultiplier/100);
                                
                                //Add Adjustment value
                                if(String.isNotBlank(pG.adjustmentValue))
                                    pG.pGoal.Percent__c += Decimal.valueOf(pG.adjustmentValue);
                                //}
                            
                                //Round the calculation according to standard criteria
                                Integer multiplier = Math.ROUND(pG.pGoal.Percent__c/ISSPConstants.CREATE_PERSONAL_GOAL_PERCENT_MULTIPLIER);
                                
                                //Recalculate the Percent
                                pG.pGoal.Percent__c = ISSPConstants.CREATE_PERSONAL_GOAL_PERCENT_MULTIPLIER * multiplier;
                                
                                //Check for Amount
                                if(pG.pGoal.Percent__c == null)
                                    pG.pGoal.Percent__c = 0;
                                
                                //Set Count and Percent to null
                                pG.pGoal.Amount__c = null;
                                pG.pGoal.Count__c = null;
                            }
                        }
                        
                        //Check for Parent
                        if(pG.stdGDPacing.Standard_Goal_Detail__r.Parent__c != null && !isItemCalculation) {
                            
                            //Unique Key
                            String parentUK = payeeId + '-' + pG.stdGDPacing.Standard_Goal_Detail__r.Parent__c;
                            
                            //Check for parent
                            if(currentPUK != parentUK) {
                                
                                //Check unique Key in map
                                if(!mapSummaryGTDs.containsKey(parentUK))
                                    mapSummaryGTDs.put(parentUK, new Map<String,Personal_Goal__c>());
                                
                                //Check if Parent (SUMs To) is already exists in map
                                if(mapSummaryCalcs.containsKey(parentUK))
                                    mapSummaryGTDs.get(parentUK).putAll(mapSummaryCalcs.get(parentUK));
                                
                                //Add current record in map
                                mapSummaryGTDs.get(parentUK).put(payeeId + '-' + pG.stdGDPacing.Standard_Goal_Detail__c, pG.pGoal);
                            }
                        } 
                    }
                }
            }
            
            currentItemIndex++;
        }
        
        //Check for Map size
        if(mapSummaryGTDs.size() > 0)
            summaryPGCalcs(stdGoalDetails, mapSummaryGTDs, conMultipliers, payeeId, currentPUK, itemIndex,false);
    }
    
    /**
     *  @description    :   This method is used to perform the calculations for Summary PGs
     *
     *  @args           :   Map<String, Personal_Goal__c>
     *
     *  @return         :   Personal_Goal__c
     *
     *  @author         :   Rajeev Jain
     *
     *  @revision Log   :   V1.0 - 01/29/2016 - Created
     *
     **/
    private Personal_Goal__c sUMsToCalc(Map<String, Personal_Goal__c> mapPersonalGoals) {
        
        //Instance of Personal Goal
        Personal_Goal__c personalGoal = new Personal_Goal__c(Amount__c = 0, Count__c = 0, Percent__c = 0);
        
        //Loop through the Map
        for(String uK : mapPersonalGoals.keySet()) {
            
            //Get Personal Goal from map
            Personal_Goal__c tempPG = mapPersonalGoals.get(uK);
            
            //Add values in personal goal
            if(tempPG.Amount__c != null)
                personalGoal.Amount__c += tempPG.Amount__c;
            
            if(tempPG.Count__c != null)
                personalGoal.Count__c += tempPG.Count__c;
            
            if(tempPG.Percent__c != null)
                personalGoal.Percent__c += tempPG.Percent__c;
        }
        
        //Return
        return personalGoal;
    }
    
    /**
     *  @description    :   Method to selected all the Row Pacing of the selected row
     *
     *  @args           :   
     *
     *  @return         :   void
     *
     **/
    public void executeSelectRowLogic() {
        
        //Loop through the Main Wrapper list (List which is having all the contact with Std Goal Detial, Pacings and Personal Goal)
        for(CreatePersonalGoalsSectionWrapper cPGW : createPGSecWrapper) {
                
            //Check for Std Goal Detail
            if(cPGW.stdGoalDetails.size() > 0) {
                
                //Loop through Std Goal Detail Wrapper
                for(CreatePersonalGoalsSectionWrapper.StdGoaldetailsWrapper stdGDW : cPGW.stdGoalDetails) {
                    
                    //Loop through Personal Goals wrapper
                    for(Integer i : cPGW.mapSelection.keySet()) {
                        
                        //Check for 0th Row
                        if(cPGW.mapSelection.get(i))
                            stdGDW.stdGDetailPacings[i].selected = true;
                        else
                            stdGDW.stdGDetailPacings[i].selected = false;   
                    }
                }
            }
        }
    }
    
    /**
     *  @description    :   This method is used to display the Staff Relationships for payee.
     *
     *  @args           :   
     *
     *  @return         :   void
     *
     **/
    public void loadPayeeStaffRelationships() {
        
        //Check for Payee Id
        if(String.isNotBlank(payeeId) && payeeId instanceof Id)
            sRelationship = new StaffRelationshipWrapper(payeeId, ISSPConstants.CLICKED_ICON_PAYEE, stdGoal.Period_Start__c, stdGoal.Period_End__c, new Set<Id>()); 
    }
    
    /**
     *  @description    :   This method is used to display the Staff Relatiionships for Personal Goal
     *
     *  @args           :   
     *
     *  @return         :   void
     *
     **/
    public void loadPGStaffRelationship() {
        
        //Check for values
        if(rowIndex != null && colIndex != null && itemIndex != null) {
            
            //Variables
            payeeId = createPGSecWrapper[rowIndex].conId;
            Date startDate = createPGSecWrapper[rowIndex].stdGoalDetails[colIndex].stdGDetailPacings[itemIndex].stdGDPacing.Period_Start__c;
            Date endDate = createPGSecWrapper[rowIndex].stdGoalDetails[colIndex].stdGDetailPacings[itemIndex].stdGDPacing.Period_End__c;
            Set<Id> setSRIds = new Set<Id>();
            setSRIds.addAll(createPGSecWrapper[rowIndex].stdGoalDetails[colIndex].stdGDetailPacings[itemIndex].setSRIds);
            
            //Pass Parameters in the Staff Relationship wrapper to fatch default data
            sRelationship = new StaffRelationshipWrapper(payeeId, ISSPConstants.CLICKED_ICON_PERSONAL_GOAL, startDate, endDate, setSRIds);
        }
    }
    
    /**
     *  @description    :   Method for save and close method.
     *
     *  @args           :   
     *
     *  @return         :   void
     *
     **/
    public void saveAndClose() {
        
        //Call the Staff Relationship save method
        sRelationship.doSave();
        
        //Execute the Staff Relationship logic
        executeStaffRelationshipLogic();
    }
    
    /**
     *  @description    :   This method is used to perform the Staff Relationship logic
     *
     *  @args           :   
     *
     *  @return         :   void
     *
     **/
    public void executeStaffRelationshipLogic(){
        
        //Check for values
        if(rowIndex != null && colIndex != null && itemIndex != null) {
            
            //Check for Staff Relationship size
            if(sRelationship.listStaffRelationshipWrapper.size() > 0)
                createPGSecWrapper[rowIndex].hasStaffRelationship = true;
            
            //Check for staff relationship set size
            if(sRelationship.setSRIds.size() > 0)
                createPGSecWrapper[rowIndex].stdGoalDetails[colIndex].stdGDetailPacings[itemIndex].setSRIds.addAll(sRelationship.setSRIds);
            
            //Check for Removed Set size
            if(sRelationship.setRemovedSRIds.size() > 0)
                createPGSecWrapper[rowIndex].stdGoalDetails[colIndex].stdGDetailPacings[itemIndex].setSRIds.removeAll(sRelationship.setRemovedSRIds);
            
            //Loop through the Set
            for(Id sRId : sRelationship.setRemovedSRIds) {
                
                //Check Id in map
                if(createPGSecWrapper[rowIndex].stdGoalDetails[colIndex].stdGDetailPacings[itemIndex].mapSRIdWithPGMPIds != null
                    && createPGSecWrapper[rowIndex].stdGoalDetails[colIndex].stdGDetailPacings[itemIndex].mapSRIdWithPGMPIds.containsKey(sRId)) {
                        
                        //Check for Personal Goal status
                        if(createPGSecWrapper[rowIndex].stdGoalDetails[colIndex].stdGDetailPacings[itemIndex].pGoal.Id != null
                            && createPGSecWrapper[rowIndex].stdGoalDetails[colIndex].stdGDetailPacings[itemIndex].pGoal.Status__c != ISSPConstants.PERSONAL_GOAL_STATUS_PENDING
                            && createPGSecWrapper[rowIndex].stdGoalDetails[colIndex].stdGDetailPacings[itemIndex].pGoal.Status__c != ISSPConstants.PERSONAL_GOAL_STATUS_PAYEE_APPROVED)
                            setPGRIds.add(createPGSecWrapper[rowIndex].stdGoalDetails[colIndex].stdGDetailPacings[itemIndex].mapSRIdWithPGMPIds.get(sRId));
                }
            }
            
            //Check for set size
            if(createPGSecWrapper[rowIndex].stdGoalDetails[colIndex].stdGDetailPacings[itemIndex].setSRIds.size() > 0)
                createPGSecWrapper[rowIndex].stdGoalDetails[colIndex].stdGDetailPacings[itemIndex].haveRelationships = true;
            else
                createPGSecWrapper[rowIndex].stdGoalDetails[colIndex].stdGDetailPacings[itemIndex].haveRelationships = false;
            
            //Loop through the Main Wrapper list (List which is having all the contact with Std Goal Detial, Pacings and Personal Goal)
            for(CreatePersonalGoalsSectionWrapper cPGW : createPGSecWrapper) {
                
                //Set Values
                if(cPGW.businessTitlePercent == 0)
                cPGW.businessTitlePercent = null;
                
                if(cPGW.tenuredPercent == 0)
                cPGW.tenuredPercent = null;
                
                if(cPGW.cSTenuredPercent == 0)
                cPGW.cSTenuredPercent = null;
            }
        
        //Payee Case
        } else {
            
            //Loop through the Main Wrapper list (List which is having all the contact with Std Goal Detial, Pacings and Personal Goal)
            for(CreatePersonalGoalsSectionWrapper cPGW : createPGSecWrapper) {
                
                //Check for Payee Id
                if(String.isNotBlank(payeeId) && payeeId == cPGW.conId) {
                
                    //Check for Staff Relationship size
                    if(sRelationship.listStaffRelationshipWrapper.size() > 0)
                        cPGW.hasStaffRelationship = true;
                    
                    //Loop through the GTDs
                    for(CreatePersonalGoalsSectionWrapper.StdGoaldetailsWrapper stdGDW : cPGW.stdGoalDetails) {
                        
                        //Loop through the Pacings
                        for(CreatePersonalGoalsSectionWrapper.StdGoalDetailPacingWrapper pW : stdGDW.stdGDetailPacings) {
                            
                            //Check for Description
                            if(String.isNotBlank(pW.stdGDPacing.Description__c) && pW.selected) {
                                
                                //Add relationship on goal
                                pW.setSRIds.addAll(sRelationship.setSRIds);
                                
                                //Remove relationships from the goal
                                pW.setSRIds.removeAll(sRelationship.setRemovedSRIds);
                                
                                //Check the relationships
                                if(pW.setSRIds.size() > 0)
                                    pW.haveRelationships = true;
                                else
                                    pW.haveRelationships = false;
                            }
                        }
                    }    
                }
                
                //Set Values
                if(cPGW.businessTitlePercent == 0)
                    cPGW.businessTitlePercent = null;
                
                if(cPGW.tenuredPercent == 0)
                    cPGW.tenuredPercent = null;
                
                if(cPGW.cSTenuredPercent == 0)
                    cPGW.cSTenuredPercent = null;
            }
        }
        
        //Call method to parse blank in URL Parameters
        parseURLParameters();
        
        //executeSelectRowLogic();
    }
    
    /**
     *  @description    :   This method is used to fatch the condition data of selected std goal detail.
     *
     *  @args           :   
     *
     *  @return         :   void
     *
     **/
    public void fatchStdGoalDetailConditions() {
        
        //Get Std goal detail Id from URL
        String stdGDetailId = ApexPages.currentPage().getParameters().get('stdGDId');
        
        //Check for Id and get condition for SGD
        if(String.isNotBlank(stdGDetailId) && stdGDetailId instanceof Id)
            conditions = [Select Id, RecordType.Name, Value__c, Condition_Type__c From Condition__c Where Standard_Goal_Detail__c =: stdGDetailId];            
    }
    
    /**
     *  @description    :   This method is used to fatch the GTDMP data of selected goal temp detail.
     *
     *  @args           :   
     *
     *  @return         :   void
     *
     **/
    public void fatchGTDMPeriods() {
        
        //Get Std goal detail Id from URL
        String stdGDetailId = ApexPages.currentPage().getParameters().get('stdGDId');
        
        //Check for Id and get condition for SGD
        if(String.isNotBlank(stdGDetailId) && stdGDetailId instanceof Id)
            gTDMPeriods = [Select Id, Measurement_Date__c From Goal_Template_Detail_Measurement_Period__c Where Goal_Template_Detail__c =: stdGDetailId];            
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
                
            //Map to hold Personal Goal with Unique Key (Payee Id + Std Goal Detail Id + Std Goal Detail Pacing)
            Map<String,Personal_Goal__c> mapPersonalGoals = new Map<String,Personal_Goal__c>();
            
            //Map to hold Task with Unique Key (Payee Id + Std Goal Detail Id + Std Goal Detail Pacing)
            Map<String,Task> mapTasks = new Map<String,Task>();
            
            //Map to hold the Set of Staff Relationship Ids with Unique Key (Payee Id + Std Goal Detail Id + Std Goal Detail Pacing)
            Map<String, Set<Id>> mapStaffRelationships = new Map<String,Set<Id>>();
            
            //Map to hold the Map of Staff Relationship Id and PGR Id with Unique Key (Payee Id + Std Goal Detail Id + Std Goal Detail Pacing)
            Map<String, Map<Id, Id>> mapSRAndPGRIds = new Map<String,Map<Id, Id>>();
            
            //Map to hold the Personal Goal Id with unique Key
            //Map<Id, String> mapExistingPGs = new Map<Id,String>();
            
            //Set to hold the Active Proposed Goals Ids
            Set<Id> setAProGoalIds = new Set<Id>();
            
            //Map to hold all the Personal Goal Ids with corresponding Goal Template Detail Id
            Map<Id,List<Id>> mapSGDIdWithPGIds = new Map<Id,List<Id>>();
            
            //Map to hold all the Personal Goal Ids with corresponding Goal Template Id
            Map<Id,List<Id>> mapSGIdWithPGIds = new Map<Id,List<Id>>();
            
            //Set to hold the Personal Goal Ids (This set will use to delete conditions for Personal Goals)
            Set<Id> setPGIds = new Set<Id>();
            
            //Query through record type
            List<RecordType> rTypes = [Select Id From RecordType Where SobjectType = 'Personal_Goal__c' AND 
                                              DeveloperName IN ('Personal_Goal', 'Proposal') ORDER BY DeveloperName ASC LIMIT 2];
            
            //Set to hold the Staff Attributes ids that are going to delete
            Set<String> setSAIds = new Set<String>();
            
            //List of Staff Attributes to insert new staff assignments
            List<Staff_History__c> staffHistories = new List<Staff_History__c>();
            
            //Set to hold the Proposed Goals Ids
            //This set is used to delete the Personal Goals Periods and PGRs
            Set<Id> setProGoalIds = new Set<Id>();
            
            //Loop through the Main Wrapper list (List which is having all the contact with Std Goal Detial, Pacings and Personal Goal)
            for(CreatePersonalGoalsSectionWrapper cPGW : createPGSecWrapper) {
                
                //Loop through Std Goal Detail Wrapper
                for(CreatePersonalGoalsSectionWrapper.StdGoaldetailsWrapper stdGDW : cPGW.stdGoalDetails) {
                    
                    //Loop through Pacing Wrapper
                    for(CreatePersonalGoalsSectionWrapper.StdGoalDetailPacingWrapper pW : stdGDW.stdGDetailPacings) {
                        
                        //Check for selected PGs
                        if(pW.selected && String.isNotBlank(pW.stdGDPacing.Description__c) && pW.pGoal.Id != null && pW.pGoal.Active_Proposal__c != null) {
                            
                                //Add Active Proposed Goals Id in set
                                setAProGoalIds.add(pW.pGoal.Active_Proposal__c);
                        }
                    }   
                }
            }
            
            //Map to hold the Snapshot Id with Cloned Proposed Goal Ids
            Map<Id, Personal_Goal__c> mapClonedProposedGoals = new Map<Id, Personal_Goal__c>();
            
            //Global describe
            Map<String, Schema.SObjectType> globalDescribe = Schema.getGlobalDescribe();
            
            //Get the current Proposed Goals
            List<Personal_Goal__c> currentActiveProposals = Database.query(buildSOQL(globalDescribe, 'Personal_Goal__c') + ' Where Id IN : setAProGoalIds');
            
            //Check for list size
            if(currentActiveProposals.size() > 0) {
                
                //Clone the list
                List<Personal_Goal__c> clonedProposales = currentActiveProposals.deepClone(false,true);
                
                //Loop through the Cloned records
                for(Personal_Goal__c pG : clonedProposales) {
                    
                    //Check for Primary Goal
                    if(pG.Primary_Goal__c != null)
                        mapClonedProposedGoals.put(pG.Primary_Goal__c, pG); 
                }   
            }
            
            //V_1.6 - Modified - Rajeev Jain - 04/10/2016 - CR - 9688 - ISSP Deployment E
            //Handling  Staff Attribute Creation or upddation as per the udated Goal manangent SDD, Save Behaviour of Create PG VF Page
            
            //Map to hold the List of Personal Goal which Tenured Checkbox is checked
            Map<String, List<Personal_Goal__c>> mapPayeeWithActiveTenuredPg = new Map<String, List<Personal_Goal__c>>();
            
            //V_1.6 - Modified - Rajeev Jain - 04/10/2016 - CR - 9688 - ISSP Deployment E - upto here
            
            //Loop through the Main Wrapper list (List which is having all the contact with Std Goal Detial, Pacings and Personal Goal)
            for(CreatePersonalGoalsSectionWrapper cPGW : createPGSecWrapper) {
                
                //Loop through Std Goal Detail Wrapper
                for(CreatePersonalGoalsSectionWrapper.StdGoaldetailsWrapper stdGDW : cPGW.stdGoalDetails) {
                    
                    //Loop through Pacing Wrapper
                    for(CreatePersonalGoalsSectionWrapper.StdGoalDetailPacingWrapper pW : stdGDW.stdGDetailPacings) {
                        
                        //Check for selected Pacing
                        if(pW.selected && String.isNotBlank(pW.stdGDPacing.Description__c)) {
                            
                            //Unique Key
                            String uniqueKey = cPGW.conId + '-' + stdGDW.stdGoalDetail.Id + '-' + pW.stdGDPacing.Id;
                            
                            //Instance of Personal Goal
                            Personal_Goal__c personalGoalToInsert = new Personal_Goal__c();
                            
                            //Populated Payee
                            personalGoalToInsert.Payee__c = cPGW.conId;
                            
                            //V_1.6 - Modified - Rajeev Jain - 04/10/2016 - CR - 9688 - ISSP Deployment E
                            //Check if Personal Goal is having active checkbox, then add it to the map to perform staff attribute save logic later
                            //05/02/2016 - Commented out the code - As per the Taylor's Request on the Cr chatter.
                            /*if(pW.pGoal.Tenure__c)
                                
                                if(!mapPayeeWithActiveTenuredPg.containsKey(cPGW.conId))
                                    mapPayeeWithActiveTenuredPg.put(cPGW.conId, new List<Personal_Goal__c>());
                                    
                                mapPayeeWithActiveTenuredPg.get(cPGW.conId).add(pW.pGoal);
                            }*/
                            
                            //V_1.6 - Modified - Rajeev Jain - 04/10/2016 - CR - 9688 - ISSP Deployment E - upto here
                                    
                            //Check for Personal Goal Id
                            if(String.isBlank(pW.pGoal.Id)) {
                                
                                //Call method to populate field values
                                populatePGField(personalGoalToInsert, cPGW, pW);
                                
                                //Populate fields value
                                personalGoalToInsert.RecordTypeId = rTypes[0].Id;
                                personalGoalToInsert.Standard_Goal__c = stdPersonalGoal.Standard_Goal__c;
                                personalGoalToInsert.Standard_Goal_Detail__c = pW.stdGDPacing.Standard_Goal_Detail__c;
                                personalGoalToInsert.Goal_Type__c = pW.stdGDPacing.Standard_Goal_Detail__r.Goal_Type__c;
                                personalGoalToInsert.Active__c = true;
                                personalGoalToInsert.Editable__c = true;
                                personalGoalToInsert.Autocreated__c = true;
                                personalGoalToInsert.Description__c = pW.stdGDPacing.Standard_Goal_Detail__r.Name + '-'
                                                             + pW.stdGDPacing.Description__c;
                                
                                personalGoalToInsert.Period_Start__c = pW.stdGDPacing.Period_Start__c;
                                personalGoalToInsert.Period_End__c = pW.stdGDPacing.Period_End__c;
                                personalGoalToInsert.Weighting__c = pW.stdGDPacing.Standard_Goal_Detail__r.Weighting__c;
                                personalGoalToInsert.Business_Title_Txt__c = pW.pGoal.Business_Title_Txt__c;
                            
                                //Add Personal Goal in list
                                mapPersonalGoals.put(cPGW.conId + '-' + stdGDW.stdGoalDetail.Id + '-' + pW.stdGDPacing.Id,personalGoalToInsert);
                                
                                //Check for comments
                                if(String.isNotBlank(pW.comments)) {
                                    
                                    //Instance of Task
                                    Task tsk = addTask(pW.comments, ISSPConstants.TASK_STATUS_COMPLETED, System.today(),
                                                       ISSPConstants.TASK_PRIORITY_NORMAL, ISSPConstants.TASK_SUBJECT_GOAL_COMMENTS, null);
                                    
                                    
                                    //Populate map
                                    mapTasks.put(uniqueKey, tsk);
                                }
                            
                            //Check for existing Personal Goal
                            } else {
                                
                                //Check for Snapshot Status
                                if(pW.pGoal.Status__c == ISSPConstants.PERSONAL_GOAL_STATUS_AVAILABLE || pW.pGoal.Status__c.Contains(ISSPConstants.PERSONAL_GOAL_STATUS_SUBMITTED)) {
                                    
                                    //Update the Id in the cloned Record
                                    if(mapClonedProposedGoals.containsKey(pW.pGoal.Id))
                                        mapClonedProposedGoals.get(pW.pGoal.Id).Id = pW.pGoal.Active_Proposal__c;
                                        
                                    //Call method to populate field values
                                    populatePGField(personalGoalToInsert, cPGW, pW);
                                    
                                    //Update Business Title
                                    mapClonedProposedGoals.get(pW.pGoal.Id).Business_Title_Txt__c = pW.pGoal.Business_Title_Txt__c;
                                    
                                    //Call method to populate the field values
                                    populatePGField(mapClonedProposedGoals.get(pW.pGoal.Id), cPGW, pW);
                                    
                                    //Update Active Proposed goals status
                                    mapClonedProposedGoals.get(pW.pGoal.Id).Status__c = ISSPConstants.PERSONAL_GOAL_STATUS_AVAILABLE;
                                    
                                    //Add Personal Goal in list
                                    mapPersonalGoals.put(mapClonedProposedGoals.get(pW.pGoal.Id).Id,mapClonedProposedGoals.get(pW.pGoal.Id));
                                
                                    //Update the Status of the Snapshot
                                    personalGoalToInsert.Id = pW.pGoal.Id;
                                    personalGoalToInsert.Business_Title_Txt__c = pW.pGoal.Business_Title_Txt__c;
                                    personalGoalToInsert.RecordTypeId = rTypes[0].Id;
                                    personalGoalToInsert.Status__c = ISSPConstants.PERSONAL_GOAL_STATUS_AVAILABLE;
                                    
                                    
                                    //Add Personal Goal in list
                                    mapPersonalGoals.put(cPGW.conId + '-' + stdGDW.stdGoalDetail.Id + '-' + pW.stdGDPacing.Id,personalGoalToInsert);
                                    
                                    //Instance of Task
                                    Task tskUpdate = addTask(ISSPConstants.TASK_SUBJECT_GOAL_COMMENTS_UPDATED, ISSPConstants.TASK_STATUS_COMPLETED, System.today(),
                                                   ISSPConstants.TASK_PRIORITY_NORMAL, ISSPConstants.TASK_SUBJECT_GOAL_COMMENTS_UPDATED,pW.pGoal.Id);
                                    
                                    //Populate map
                                    mapTasks.put(pW.pGoal.Id, tskUpdate);
                                        
                                    //Check for comments
                                    if(String.isNotBlank(pW.comments)) {
                                        
                                        //Instance of Task
                                        Task tsk = addTask(pW.comments, ISSPConstants.TASK_STATUS_COMPLETED, System.today(),
                                                       ISSPConstants.TASK_PRIORITY_NORMAL, ISSPConstants.TASK_SUBJECT_GOAL_COMMENTS, null);
                                        
                                        //Populate map
                                        mapTasks.put(uniqueKey, tsk);
                                    }
                                    
                                    //Subhash Garhwal - 01/05/2016 - Code added to validate the conditions on the Personal Goal according to parent GTD
                                    
                                    /********************       Start       *****************/
                                    //Check for GTD
                                    if(pW.stdGDPacing.Standard_Goal_Detail__c != null ) {
                                        
                                        //Add value to map
                                        if(!mapSGDIdWithPGIds.containskey(pW.stdGDPacing.Standard_Goal_Detail__c))
                                            mapSGDIdWithPGIds.put(pW.stdGDPacing.Standard_Goal_Detail__c, new List<Id>());
                                        
                                        //Add Personal Goal Id in map
                                        mapSGDIdWithPGIds.get(pW.stdGDPacing.Standard_Goal_Detail__c).add(pW.pGoal.Id);
                                    }
                                    
                                    //Check for GT
                                    if(pW.stdGDPacing.Standard_Goal_Detail__r.Standard_Goal__c != null ) {
                                        
                                        //Add value to map
                                        if(!mapSGIdWithPGIds.containskey(pW.stdGDPacing.Standard_Goal_Detail__r.Standard_Goal__c))
                                            mapSGIdWithPGIds.put(pW.stdGDPacing.Standard_Goal_Detail__r.Standard_Goal__c, new List<Id>());
                                        
                                        //Add Personal Goal Id in map
                                        mapSGIdWithPGIds.get(pW.stdGDPacing.Standard_Goal_Detail__r.Standard_Goal__c).add(pW.pGoal.Id);
                                    }
                                    
                                    //Add Personal Goal Ids in set
                                    setPGIds.add(pW.pGoal.Id);
                                    
                                    /********************       End     *****************/
                                
                                } else if((pW.pGoal.Status__c == ISSPConstants.PERSONAL_GOAL_STATUS_PENDING || pW.pGoal.Status__c == ISSPConstants.PERSONAL_GOAL_STATUS_PAYEE_APPROVED)) {
                                    
                                    //Check snapshot in map
                                    if(mapClonedProposedGoals.containsKey(pW.pGoal.Id)) {
                                        
                                        //Remove all the PGMP and PGR that are going to delete
                                        if(mapPGMPGoingToDelete.containsKey(pW.pGoal.Id))
                                            mapPGMPGoingToDelete.remove(pW.pGoal.Id);
                                            
                                        //Clone the Active Proposal
                                        personalGoalToInsert = mapClonedProposedGoals.get(pW.pGoal.Id);
                                        personalGoalToInsert.Submission_Status__c = null;
                                        personalGoalToInsert.Active__c = false;
                                        personalGoalToInsert.Personal_Plan__c = null;
                                        personalGoalToInsert.OwnerId = UserInfo.getUserId();
                                        personalGoalToInsert.Business_Title_Txt__c = pW.pGoal.Business_Title_Txt__c;
                                        
                                        //Check for SS in map
                                        if(mapSSIdWIthPPCounter.containsKey(pW.pGoal.Id) && mapSSIdWIthPPCounter.get(pW.pGoal.Id) != null)
                                            personalGoalToInsert.Proposal_Counter__c = mapSSIdWIthPPCounter.get(pW.pGoal.Id) + 1;
                                        else
                                            personalGoalToInsert.Proposal_Counter__c = 1;
                                        
                                        //Chek personal goal in map
                                        if(mapExistingProposals.containsKey(pW.pGoal.Id)) {
                                            
                                            //Set Id
                                            personalGoalToInsert.Id = mapExistingProposals.get(pW.pGoal.Id);
                                            
                                            //Add Id in set 
                                            setProGoalIds.add(mapExistingProposals.get(pW.pGoal.Id));
                                        }
                                            
                                        //Call method to populate field values
                                        populatePGField(personalGoalToInsert, cPGW, pW);
                                    }
                                    
                                    //Add Personal Goal in list
                                    mapPersonalGoals.put(cPGW.conId + '-' + stdGDW.stdGoalDetail.Id + '-' + pW.stdGDPacing.Id,personalGoalToInsert);
                                    
                                    //Instance of Task
                                    Task tskAdded = addTask(pW.comments, ISSPConstants.TASK_STATUS_COMPLETED, System.today(), ISSPConstants.TASK_PRIORITY_NORMAL,
                                                       ISSPConstants.TASK_SUBJECT_GOAL_COMMENTS_GOAL_ADDED,pW.pGoal.Id);
                                    
                                    //Populate map
                                    mapTasks.put(pW.pGoal.Id, tskAdded);
                                    
                                    //Check for comments
                                    if(String.isNotBlank(pW.comments)) {
                                        
                                        //Instance of Task
                                        Task tsk = addTask(pW.comments, ISSPConstants.TASK_STATUS_COMPLETED, System.today(),
                                                       ISSPConstants.TASK_PRIORITY_NORMAL, ISSPConstants.TASK_SUBJECT_GOAL_COMMENTS, null);
                                        
                                        //Populate map
                                        mapTasks.put(uniqueKey, tsk);
                                    }
                                }
                            }
                            
                            //Check unique key in Staff Relationship map
                            if(!mapStaffRelationships.containsKey(uniqueKey))
                                mapStaffRelationships.put(uniqueKey, new Set<Id>());
                            
                            //Populate map
                            mapStaffRelationships.get(uniqueKey).addAll(pW.setSRIds);
                            
                            //Check unique key in Staff Relationship and PGR map
                            if(!mapSRAndPGRIds.containsKey(uniqueKey))
                                mapSRAndPGRIds.put(uniqueKey, new Map<Id, Id>());
                            
                            //Check for mapSRIdWithPGMPIds
                            if(pW.mapSRIdWithPGMPIds != null)
                                mapSRAndPGRIds.get(uniqueKey).putAll(pW.mapSRIdWithPGMPIds);
                        }
                    }   
                }
                
                //Code added to delete/create new Staff Attribute records 
                //Check for tenured
                /*if(!cPGW.tenured && String.isNotBlank(cPGW.tenuredSAId))
                    setSAIds.add(cPGW.tenuredSAId);
                
                //Create a new Staff Attribute record
                else if(cPGW.tenured && valueTypes.size() == 1) {
                    
                    //Instance of Staff Attribute
                    Staff_History__c sA = new Staff_History__c(Staff_Member__c = cPGW.conId, Value_Type__c = valueTypes[0].Id,Percent_Value__c = cPGW.tenuredPercent);
                    
                    //Check for Id
                    if(String.isNotBlank(cPGW.tenuredSAId))
                        sA.Id = cPGW.tenuredSAId;
                            
                    //Add Staff Attribute record in list
                    staffHistories.add(sA);
                }*/
                
                //V_1.6 - Modified - Rajeev Jain - 04/10/2016 - CR - 9688 - ISSP Deployment E
                //• If the Contact does not have a Tenure Staff Attribute
                //         Create a Staff Attribute for the Tenure Value Type
                //         Adjustment value is derived from the Adjustment % for the PG with
                //      •   The earliest start date
                //      •   Tenure checkbox checked
                //• If the Contact already has a Tenure Staff Attribute
                //         Update the existing Staff Attribute’s Adjustment value based on the Adjustment % for the PG with
                //      •   The earliest start date
                //      •   Tenure checkbox checked
                //05/02/2016 - Commented out the code - As per the Taylor's Request on the Cr chatter.
                /*if(mapPayeeWithActiveTenuredPg.size() > 0 && mapPayeeWithActiveTenuredPg.containsKey(cPGW.conId) && valueTypes.size() == 1){
                    
                    Date earliestStartDate;
                    Personal_Goal__c pGoalWithEarliestStartDate;
                    
                    //Loop over active tennured pg and find earliest start date out of them 
                    for(Personal_Goal__c pGoal : mapPayeeWithActiveTenuredPg.get(cPGW.conId)){
                        
                        if(earliestStartDate == null)
                            earliestStartDate = pGoal.Period_Start__c;
                        if(pGoal.Period_Start__c <= earliestStartDate){
                            earliestStartDate = pGoal.Period_Start__c;
                            pGoalWithEarliestStartDate = pGoal; 
                        }
                    }
                    if(pGoalWithEarliestStartDate != null){
                        
                        //Instance of Staff Attribute
                        Staff_History__c sA = new Staff_History__c(Staff_Member__c = cPGW.conId, Value_Type__c = valueTypes[0].Id,
                                                                    Percent_Value__c = pGoalWithEarliestStartDate.Tenure_Percentage__c, Start_Date__c = Date.Today());
                        
                        if(String.isNotBlank(cPGW.tenuredSAId))
                            sA.Id = cPGW.tenuredSAId;
                        
                        //Add Staff Attribute record in list
                        staffHistories.add(sA);
                    }
                }*/
            }
            
            //Check for size
            if(mapPersonalGoals.size() > 0) {
                
                //Insert personal goals
                upsert mapPersonalGoals.values();
                
                //Check for set size
                if(setSAIds.size() > 0)
                    delete [Select Id From Staff_History__c Where Id IN : setSAIds];
                
                //Check for list size to insert Staff Attributes
                //05/02/2016 - Commented out the code - As per the Taylor's Request on the Cr chatter.
                /*if(staffHistories.size() > 0)
                    upsert staffHistories;*/
                
                //Loop through the Tasks map
                for(String uK : mapTasks.KeySet()) {
                    
                    //Check if Personal Goal map contains unique Key
                    if(mapPersonalGoals.containsKey(uK) && mapTasks.get(uK).WhatId == null)
                        mapTasks.get(uK).WhatId = mapPersonalGoals.get(uK).Id;
                }
                
                //Check for map size
                if(mapTasks.size() > 0)
                    insert mapTasks.values();
                    
                //Delete PGRs
                if(setPGRIds.size() > 0 || setProGoalIds.size() > 0)
                    delete [Select Id From Personal_Goal_Relationship__c Where Personal_Goal__c IN : setProGoalIds OR Id IN : setPGRIds];
                
                //Check for PGMP list size
                if(mapPGMPGoingToDelete.size() > 0 || setProGoalIds.size() > 0) {
                    
                    //Temp list to delete the PGMPs
                    List<Personal_Goal_Measurement_Period__c> pGMPeriodsTemp = new List<Personal_Goal_Measurement_Period__c>();
                    
                    //Loop through the Personal Goal Ids
                    for(Id pGId : mapPGMPGoingToDelete.keySet())
                        pGMPeriodsTemp.addAll(mapPGMPGoingToDelete.get(pGId));
                    
                    //Query through the PGMP
                    for(Personal_Goal_Measurement_Period__c pGMP : [Select Id From Personal_Goal_Measurement_Period__c Where Personal_Goal__c IN : setProGoalIds])
                        pGMPeriodsTemp.add(pGMP);   
                    
                    //Delete
                    delete pGMPeriodsTemp;
                }
                 
                //List of PGR
                List<Personal_Goal_Relationship__c> pGRelationships = new List<Personal_Goal_Relationship__c>();
                
                //Loop through the Staff Relationship map to create PGR records for PG
                for(String uK : mapStaffRelationships.keySet()) {
                    
                    //Check if Personal goal map contains unique key
                    if(mapPersonalGoals.containsKey(uK)) {
                        
                        //Loop through the Staff Relationship Ids
                        for(Id sRId : mapStaffRelationships.get(uK)) {
                            
                            //Instance of PGR
                            Personal_Goal_Relationship__c pGR = new Personal_Goal_Relationship__c();
                            
                            //Populate field
                            pGR.Personal_Goal__c = mapPersonalGoals.get(uK).Id;
                            pGR.Relationship__c = sRId;
                            
                            //Check for UK
                            if(mapPersonalGoals.get(uK).RecordTypeId == rTypes[0].Id && mapSRAndPGRIds.containsKey(uK) && mapSRAndPGRIds.get(uK).containsKey(sRId))
                                pGR.Id = mapSRAndPGRIds.get(uK).get(sRId);  
                                
                            //Add PGR record in list
                            pGRelationships.add(pGR);
                        }
                    }
                }
                
                //Check for size
                if(pGRelationships.size() > 0)
                    upsert pGRelationships;
                
                //List of PGMP to insert
                List<Personal_Goal_Measurement_Period__c> pGMeasurementPeriods = new List<Personal_Goal_Measurement_Period__c>();
                
                //Loop through the Main Wrapper list (List which is having all the contact with Std Goal Detial, Pacings and Personal Goal)
                for(CreatePersonalGoalsSectionWrapper cPGW : createPGSecWrapper) {
                    
                    //Loop through Std Goal Detail Wrapper
                    for(CreatePersonalGoalsSectionWrapper.StdGoaldetailsWrapper stdGDW : cPGW.stdGoalDetails) {
                        
                        //Loop through Pacing Wrapper
                        for(CreatePersonalGoalsSectionWrapper.StdGoalDetailPacingWrapper pW : stdGDW.stdGDetailPacings) {
                            
                            //Check for selected Pacing
                            if(pW.selected && String.isNotBlank(pW.stdGDPacing.Description__c)) {
                                
                                //Unique Key
                                String uniqueKey = cPGW.conId + '-' + stdGDW.stdGoalDetail.Id + '-' + pW.stdGDPacing.Id;
                                
                                //Check for Personal Goal map
                                if(mapPersonalGoals.containsKey(uniqueKey)) {
                                    
                                    
                                    //Loop through the PGMP wrapper
                                    for(CreatePersonalGoalsSectionWrapper.PGMPeriodWrapper pGMPW : pW.pGMPeriods) {
                                        
                                        //Check for Record Type
                                        if(mapPersonalGoals.get(uniqueKey).RecordTypeId == rTypes[1].Id) {
                                            
                                            //Clone the PGMP record
                                            Personal_Goal_Measurement_Period__c clonedPGMP = pGMPW.pGMP.clone();
                                            
                                            //Change PG
                                            clonedPGMP.Personal_Goal__c = mapPersonalGoals.get(uniqueKey).Id;
                                            
                                            //Add Cloned record in list
                                            pGMeasurementPeriods.add(clonedPGMP);
                                        
                                        //Update the Peronal Goal Id on the PGMP
                                        } else {
                                            
                                            if(pGMPW.pGMP.Id == null)
                                                pGMPW.pGMP.Personal_Goal__c = mapPersonalGoals.get(uniqueKey).Id;
                                            
                                            //Add PGMP in list
                                            pGMeasurementPeriods.add(pGMPW.pGMP); 
                                        }  
                                    }       
                                }
                            }
                        }   
                    }
                }
                
                //Check for list size
                if(pGMeasurementPeriods.size() > 0)
                    upsert pGMeasurementPeriods;
                
                //Check for set size
                if(setPGIds.size() > 0)
                    delete [Select Id From Condition__c Where Personal_Goal__c In : setPGIds];
                
                //Check for map size
                if(mapSGDIdWithPGIds.size() > 0 || mapSGIdWithPGIds.size() > 0)
                    PersonalGoalTriggerHelper.createCondition(mapSGDIdWithPGIds, mapSGIdWithPGIds);
                    
                //Map to hold the Snapshot Id as key and Proposed Goal as values
                Map<Id, Personal_Goal__c> mapProGoalWithSSId = new Map<Id, Personal_Goal__c>();
                
                //Query through the Personal Goals
                for(Personal_Goal__c pG : [Select Id, Active_Proposal__c From Personal_Goal__c Where Id IN : mapPersonalGoals.values()
                                                  AND RecordType.DeveloperName =: ISSPConstants.PERSONAL_GOAL_RECORD_TYPE_PERSONAL_GOAL])
                    mapProGoalWithSSId.put(pG.Id, new Personal_Goal__c(Id = pG.Active_Proposal__c));    
                
                //Check for proposal map size and call method to create children records
                if(mapProGoalWithSSId.size() > 0)
                    PersonalGoalTriggerHelper.validateChildrenObjects(mapProGoalWithSSId);
            }
                
            return new Pagereference('/' + stdPersonalGoal.Standard_Goal__c);
        
        }catch(Exception e) {
            
            //Roll Back changes
            Database.rollback(sp);
            
            //Add Error on page
            ApexPages.addMessages(e);
            return null;
        }
        
        return null;
    }
    /**
     *  @description    :   Generic method to load Available Payees wrapper list
     *
     *  @args           :   String,String
     *
     *  @return         :   List<PayeesWrapper>
     *
     **/
    public List<PayeesWrapper> getAvailablePayees(String defaultStdGoal, String stdGoalId) {
       
        //Set to hold Payees to avoid duplicate addition of payee
        Set<Id> setPayeeIds = new Set<Id>();
        
        //Map to hold Payee Id with Payees Wrapper
        Map<Id, PayeesWrapper> mapAvailablePayees = new Map<Id, PayeesWrapper>();
                
        //Query through the personal goals
        for(Personal_Goal__c pG : [Select Id, Payee__c, Sales_Role_Percentage__c, Tenure_Percentage__c, Weighting__c, Goal_Type_Business_Title__c From Personal_Goal__c Where Standard_Goal__c =: defaultStdGoal
                                                                                   AND Payee__c != null AND RecordType.DeveloperName = 'Personal_Goal'])
            setPayeeIds.add(pG.Payee__c);
        
        //Check for set size
        if(setPayeeIds.size() > 0) {
            
            //V_1.5 - Modified - Rajeev Jain - 03/29/2016 - CR-20160316-9699 - ISSP SFDC Critical NBB Calculation Fixes - QA Fixes
            //Modified Query criteria to query only those staff attr which are active for today dates
            //Query through all the Staff History records
            for(Staff_History__c sA : [Select Id, Start_Date__c, Name, Percent_Value__c, Staff_Member__c, Staff_Member__r.Name, Staff_Member__r.FirstName, Staff_Member__r.LastName, Staff_Member__r.Function__c,  
                                              Value__c, Value_Type__c, Value_Type__r.Name, Value_Type__r.Category__c, Value_Type__r.Adjustment__c From Staff_History__c Where Staff_Member__c IN : setPayeeIds
                                               AND Start_Date__c <= :Date.Today() AND (End_Date__c = NULL OR End_Date__c >= :Date.Today()) ORDER BY Start_Date__c DESC NULLS LAST]) {
                
                //Check for payee
                if(!mapAvailablePayees.containsKey(sA.Staff_Member__c) && !setSelectedPayeesIds.contains(sA.Staff_Member__c)) {
                   
                    //Populate Wrapper
                    if(sA.Value_Type__c != null)
                        //V_1.3 - Modified - Rajeev Jain - 02/25/2016 - CR-20160115-9543 - ISSP Deployment D - Fixed Tenure Issue
                        mapAvailablePayees.put(sA.Staff_Member__c, new PayeesWrapper(sA.Staff_Member__r.Name,
                                                             sA.Value_Type__r.Name == ISSPConstants.VALUE_TYPE_NAME_JOB_TITLE ? sA.Value__c : '',
                                                             sA.Value_Type__r.Category__c == ISSPConstants.VALUE_TYPE_CATEGORY_INCENTIVE_ROLE ? sA.Value__c : '',
                                                             sA.Value_Type__r.Category__c == ISSPConstants.VALUE_TYPE_CATEGORY_BUSINESS_TITLE ? sA.Value__c : '',
                                                             sA.Value_Type__r.Category__c == ISSPConstants.VALUE_TYPE_CATEGORY_BUSINESS_TITLE ? sA.Value_Type__r.Adjustment__c : null,
                                                             sA.Value_Type__r.Name == ISSPConstants.VALUE_TYPE_NAME_TENURE && sA.Value_Type__r.Category__c == ISSPConstants.VALUE_TYPE_CATEGORY_OTHER ? 'Yes' : 'No',
                                                             sA.Value_Type__r.Name == ISSPConstants.VALUE_TYPE_NAME_TENURE && sA.Value_Type__r.Category__c == ISSPConstants.VALUE_TYPE_CATEGORY_OTHER ? sA.Percent_Value__c > 0 ? sA.Percent_Value__c : sA.Value_Type__r.Adjustment__c : null,
                                                             defaultStdGoal == stdGoalId ? 'Yes' : 'No',sA.Staff_Member__c,
                                                             sA.Value_Type__r.Category__c == ISSPConstants.VALUE_TYPE_CATEGORY_BUSINESS_TITLE ? sA.Value_Type__c : null,
                                                             sA.Value_Type__r.Name == ISSPConstants.VALUE_TYPE_NAME_TENURE && sA.Value_Type__r.Category__c == ISSPConstants.VALUE_TYPE_CATEGORY_OTHER ? sA.Id : null,
                                                             sA.Staff_Member__r.Function__c));
                        //V_1.3 - Modified - Rajeev Jain - 02/25/2016 - CR-20160115-9543 - ISSP Deployment D - Fixed Tenure Issue - upto here
                    else if(!setSelectedPayeesIds.contains(sA.Staff_Member__c))
                        mapAvailablePayees.put(sA.Staff_Member__c, new PayeesWrapper(sA.Staff_Member__r.Name, '','', '', null, 'No', null,
                                                defaultStdGoal == stdGoalId ? 'Yes' : 'No', sA.Staff_Member__c, null, null,
                                                sA.Staff_Member__r.Function__c));    
                
                } else if(mapAvailablePayees.containsKey(sA.Staff_Member__c) && sA.Value_Type__c != null) {
                    
                    //Check for Value Type
                    if(sA.Value_Type__r.Name == ISSPConstants.VALUE_TYPE_NAME_JOB_TITLE)
                        mapAvailablePayees.get(sA.Staff_Member__c).title = sA.Value__c;
                    else if(sA.Value_Type__r.Category__c == ISSPConstants.VALUE_TYPE_CATEGORY_INCENTIVE_ROLE && String.isBlank(mapAvailablePayees.get(sA.Staff_Member__c).incentiveRole))
                        mapAvailablePayees.get(sA.Staff_Member__c).incentiveRole = sA.Value__c;
                    else if(sA.Value_Type__r.Category__c == ISSPConstants.VALUE_TYPE_CATEGORY_BUSINESS_TITLE && String.isBlank(mapAvailablePayees.get(sA.Staff_Member__c).businessTitle)) {
                        
                        mapAvailablePayees.get(sA.Staff_Member__c).businessTitle = sA.Value__c;
                        mapAvailablePayees.get(sA.Staff_Member__c).businessTitlePercent = sA.Value_Type__r.Adjustment__c;
                        mapAvailablePayees.get(sA.Staff_Member__c).businessTitleId = sA.Value_Type__c;
                    
                    } else if(sA.Value_Type__r.Name == ISSPConstants.VALUE_TYPE_NAME_TENURE && sA.Value_Type__r.Category__c == ISSPConstants.VALUE_TYPE_CATEGORY_OTHER) {
                        
                        mapAvailablePayees.get(sA.Staff_Member__c).tenured = 'Yes';
                        
                        //V_1.3 - Modified - Rajeev Jain - 02/25/2016 - CR-20160115-9543 - ISSP Deployment D - Fixed Tenure Issue
                        mapAvailablePayees.get(sA.Staff_Member__c).tenuredPercent = sA.Percent_Value__c > 0 ? sA.Percent_Value__c : sA.Value_Type__r.Adjustment__c;
                        //V_1.3 - Modified - Rajeev Jain - 02/25/2016 - CR-20160115-9543 - ISSP Deployment D - Fixed Tenure Issue - Upto Here
                        
                        mapAvailablePayees.get(sA.Staff_Member__c).staffAttributeId = sA.Id;
                    }
                }
            }
        }
        
        //Return
        return mapAvailablePayees.values();
    }
    
    /**
     *  @description    :   This method is used to Get the Personal Goal.
     *
     *  @args           :   Standard_Goal_Detail__c, List<Personal_Goal__c>
     *
     *  @return         :   Personal_Goal__c
     *
     **/
    public Personal_Goal__c getPersonalGoal(Standard_Goal_Detail_Pacing__c stdGoalDetailPacing, List<Personal_Goal__c> personalGoals) {
        
        //Check for Personal Goal List
        if(personalGoals != null) {
            
            //Loop through Personal Goal
            for(Personal_Goal__c pG : personalGoals) {
                
                //Check for Start and End Date
                if(pG.Standard_Goal_Detail__c == stdGoalDetailPacing.Standard_Goal_Detail__c && pG.Period_Start__c == stdGoalDetailPacing.Period_Start__c
                    && pG.Period_End__c == stdGoalDetailPacing.Period_End__c)
                    return pG;
            }
        }
        
        return new Personal_Goal__c();
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
        
        //Remove extra elements and add object
        SOQL = SOQL.removeEnd(',') + ' From ' + objName;
        
        //Return 
        return SOQL;
        
    }
    
    /**
     *  @description    :   This method is used to create Tasks
     *
     *  @args           :   String, String, Date, String, String, Id
     *
     *  @return         :   Task
     *
     **/
    private Task addTask(String description, String status, Date activityDate, String priority, String subject, Id whtId) {
        
        //Instance of task
        Task tsk = new Task();
        
        //Populate field values
        tsk.Description = description;
        tsk.Status = status;
        tsk.ActivityDate = activityDate;
        tsk.Priority = priority;
        tsk.Subject = subject;
        tsk.WhatId = whtId;
        
        //Return
        return tsk;
    }
    
    /**
     *  @description    :   This method is used to assign Personal Goal values
     *
     *  @args           :   Personal_Goal__c, CreatePersonalGoalsSectionWrapper, CreatePersonalGoalsSectionWrapper.StdGoalDetailPacingWrapper
     *
     *  @return         :   void
     *
     **/
    private void populatePGField(Personal_Goal__c personalGoalToInsert, CreatePersonalGoalsSectionWrapper cPGW, CreatePersonalGoalsSectionWrapper.StdGoalDetailPacingWrapper pW) {
        
        if(String.isNotBlank(pW.adjustmentValue))
            personalGoalToInsert.Adjustment__c = Decimal.valueOf(pW.adjustmentValue);
        else
            personalGoalToInsert.Adjustment__c = null;
        
        //Add Weighting for PG
        personalGoalToInsert.Amount__c = pW.pGoal.Amount__c;
        personalGoalToInsert.Count__c = pW.pGoal.Count__c;
        personalGoalToInsert.Percent__c = pW.pGoal.Percent__c;
        personalGoalToInsert.Condition_Handling__c = pW.stdGDPacing.Standard_Goal_Detail__r.Condition_Handling__c;
        personalGoalToInsert.Status__c = ISSPConstants.PERSONAL_GOAL_STATUS_AVAILABLE;
        personalGoalToInsert.Goal_Type_Business_Title__c = pW.bTMultiplier;
        personalGoalToInsert.Goal_Type__c = pW.pGoal.Goal_Type__c;
        personalGoalToInsert.Description__c = pW.pGoal.Description__c;
        personalGoalToInsert.Period_Start__c = pW.pGoal.Period_Start__c;
        personalGoalToInsert.Period_End__c = pW.pGoal.Period_End__c;
        personalGoalToInsert.Weighting__c = pW.pGoal.Weighting__c;
        
        //V_1.7 - Modified - Rajeev Jain - 04/14/2016 - CR-20160307-9680 - ISSP Deployment E
        //Populate the Value Type field from GTD to Personal Goal level
        personalGoalToInsert.Value_Type_Quantity__c = pW.stdGDPacing.Standard_Goal_Detail__r.Value_Type__c;
        
        //V_1.7 - Modified - Rajeev Jain - 04/14/2016 - CR-20160307-9680 - ISSP Deployment E - upto here
        
        //Check for GTD TT
        if(pW.stdGDPacing.Standard_Goal_Detail__r.Target_Type__c == ISSPConstants.STANDARD_GOAL_DETAIL_TARGET_TYPE_EXPLICIT)
            personalGoalToInsert.Period__c = pW.stdGDPacing.Standard_Goal_Detail__r.Period__c;
        else
            personalGoalToInsert.Period__c = pW.stdGDPacing.Description__c;
        
        //Check for Goal Type
        if(pW.stdGDPacing.Standard_Goal_Detail__r.Goal_Type__c != null
            && pW.stdGDPacing.Standard_Goal_Detail__r.Goal_Type__r.Discount_Type__c == ISSPConstants.GOAL_TYPE_DISCOUNT_TYPE_MULTIPLIERS) {
            
            personalGoalToInsert.Sales_Role_Percentage__c = cPGW.businessTitlePercent;
            
            //Modified By - Rajeev Jain - 04/10/2015 - CR - 9688 - ISSP Deployment E
            //Update the tenure details whate ever eneterd on gaol level
            personalGoalToInsert.Tenure_Percentage__c = pW.pGoal.Tenure_Percentage__c;
            personalGoalToInsert.Tenure__c = pw.pGoal.Tenure__c;     
        }
        
        //Check for Target Type
        if(pW.stdGDPacing.Standard_Goal_Detail__r.Target_Type__c == ISSPConstants.STANDARD_GOAL_DETAIL_TARGET_TYPE_PACED) {
            
            //Populate the baseline
            if(pW.stdGDPacing.Amount__c != null && pW.stdGDPacing.Amount__c > 0)
                personalGoalToInsert.Baseline_Amount__c = pW.stdGDPacing.Percent_Manual__c != null && pW.stdGDPacing.Percent_Manual__c > 0 ? (pW.stdGDPacing.Amount__c * 100/pW.stdGDPacing.Percent_Manual__c) : pW.stdGDPacing.Amount__c;
            else if(pW.stdGDPacing.Count__c != null && pW.stdGDPacing.Count__c > 0)
                personalGoalToInsert.Baseline_Amount__c = pW.stdGDPacing.Percent_Manual__c != null && pW.stdGDPacing.Percent_Manual__c > 0 ? (pW.stdGDPacing.Count__c * 100/pW.stdGDPacing.Percent_Manual__c) : pW.stdGDPacing.Count__c;
            else if(pW.stdGDPacing.Percent__c != null && pW.stdGDPacing.Percent__c > 0)
                personalGoalToInsert.Baseline_Amount__c = pW.stdGDPacing.Percent_Manual__c != null && pW.stdGDPacing.Percent_Manual__c > 0 ? (pW.stdGDPacing.Percent__c * 100/pW.stdGDPacing.Percent_Manual__c) : pW.stdGDPacing.Percent__c;
        }
    }
    
    /**
     *  @description    :   This method is used to Parse URL Parameters values
     *
     *  @args           :   
     *
     *  @return         :   void
     *
     **/
    public void parseURLParameters() {
        
        //Re-Set Variables
        ApexPages.currentPage().getParameters().put('rowIndex', '');
        ApexPages.currentPage().getParameters().put('colIndex', '');
        ApexPages.currentPage().getParameters().put('itemIndex', null);
        ApexPages.currentPage().getParameters().put('desc', '');
        ApexPages.currentPage().getParameters().put('selectCB', '');
        
        rowIndex = null;
        colIndex = null;
        itemIndex = null;
    }
    
    /**
     *  @description    :   This method is used to get the max Rows in the list
     *
     *  @args           :   CreatePersonalGoalsSectionWrapper
     *
     *  @return         :   Integer
     *
     **/
    private Integer maxGTDPRows(CreatePersonalGoalsSectionWrapper cPGW) {
        
        //Variable to hold the max pacings row size
        Integer maxPacings = 0;
        
        //Loop through the GTDs
        for(CreatePersonalGoalsSectionWrapper.StdGoaldetailsWrapper gTDW : cPGW.stdGoalDetails) {
            
            //Check for max Pacings
            if(gTDW.stdGDetailPacings.size() > maxPacings)
                maxPacings = gTDW.stdGDetailPacings.size();
        }
        
        return maxPacings;
    }
    
    //Method only used for mantained data on page
    public void reRender() {}
    
    //Wrapper class to hold all the payee data
    public class PayeesWrapper implements comparable{
        
        //Properties
        public String contactName {get;set;}
        public String title {get;set;}
        public String incentiveRole {get;set;}
        public String businessTitle {get;set;}
        public Decimal businessTitlePercent {get;set;}
        public String tenured {get;set;}
        public Decimal tenuredPercent {get;set;}
        public String hasGoal {get;set;}
        public String contactId {get;set;}
        public Boolean selected {get;set;}
        public String businessTitleId {get;set;}
        public String StaffAttributeId;
        
        //Added By - Rajeev Jain - 11/13/2015 - ISSP UAT Issue and Enhancement, add new Department Column Available Payees table
        public String payeeDepartment{get;set;}
        
        //Using this property for SortByLast Name
        public String payeeLastName{get;set;}
        //Added By - Rajeev Jain - 11/13/2015 - upto Here
        
        //Constructor
        public PayeesWrapper(String contactName, String title, String incentiveRole, String businessTitle, Decimal businessTitlePercent, String tenured, Decimal tenuredPercent,
                             String hasGoal, String contactId, String businessTitleId, String StaffAttributeId, String payeeDepartment) {
            
            //Set Properties
            this.contactName = contactName;
            this.title = title;
            this.incentiveRole = incentiveRole;
            this.businessTitle = businessTitle;
            this.businessTitlePercent = businessTitlePercent;
            this.tenured = tenured;
            this.tenuredPercent = tenuredPercent;
            this.hasGoal = hasGoal;
            this.contactId = contactId;
            this.businessTitleId = businessTitleId;
            this.selected = false;
            this.StaffAttributeId = StaffAttributeId;
            this.payeeDepartment = payeeDepartment;
        }
        
        // Implement the compareTo() method
        public Integer compareTo(Object compareTo) {
        
            
            PayeesWrapper compareToEmp = (PayeesWrapper)compareTo;
            
            if (this.contactName == compareToEmp.contactName) return 0;
            if (this.contactName > compareToEmp.contactName) return 1;
            return -1;        
        }
    } 
    
    //Wrapper class to hold the std goal details
    public class StdGoalDetailWrapper {
        
        //Properties
        public String sGDdesc {get;set;}
        public String sGDId {get;set;}
        public Boolean hasConditions {get;set;}
        public Boolean hasGTDMPs {get;set;}  
        
        //Constructor
        public StdGoalDetailWrapper(String sGDdesc, String sGDId, Boolean hasConditions, Boolean hasGTDMPs) {
            
            //Set values
            this.sGDdesc = sGDdesc;
            this.sGDId = sGDId;
            this.hasConditions = hasConditions;
            this.hasGTDMPs = hasGTDMPs;
        }
    }
    
    //Wrapper Class to hold Business Title Properties(This class is only for use in internal purpose)
    public class PayeeBusinessTitleWrapper{
        
        //Properties
        public String businessTitle{get;set;}
        public Decimal businessTitlePercent{get;set;}
        public Date startDate{get;set;}
        
        public PayeeBusinessTitleWrapper(String businessTitle, Decimal businessTitlePercent, Date startDate){
            
            this.businessTitle = businessTitle;
            this.businessTitlePercent = businessTitlePercent;
            this.startDate = startDate;
        }
    }
}