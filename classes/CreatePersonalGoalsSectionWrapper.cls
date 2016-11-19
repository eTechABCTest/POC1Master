/**
 *  Purpose         :   Wrapper class to hold data of Cretae Personal Goals Section on CreatePersonalGoalsFromStdGoalController.
 *  
 *  Created By      :   Subhash Garhwal
 * 
 *  Created Date    :   08/27/2015 
 * 
 *  Revision Logs   :   V_1.0 - Created - CR-20150729-9114
 *                      V_1.1 - Modified - Subhash Garhwal - 11/27/2015 - CR-20151120-9407 - PGMP functionality
 *                      V_1.2 - Modified - Rajeev Jain - 03/21/2016 - ISSP critical Fix March
 *                      V_1.3 - Modified - Rajeev Jain - 05/17/2016 - ISSP Deployment E - CR-20160512-9852 
 * 
 **/
public with sharing class CreatePersonalGoalsSectionWrapper {
    
    //Properties
    public String conName {get;set;}
    public String conId {get;set;}
    public String businessTitle {get;set;}
    public Decimal businessTitlePercent {get;set;}
    public Boolean tenured {get;set;}
    public Decimal tenuredPercent {get;set;}
    public Integer maxRowSize {get;set;}
    public Decimal cSTenuredPercent {get;set;}
    public List<StdGoaldetailsWrapper> stdGoalDetails {get;set;}
    public String tenuredSAId;
    public Boolean hasStaffRelationship {get;set;}
    public Map<Integer, Boolean> mapSelectableRows {get;set;}
    public Map<Integer, Boolean> mapSelection {get;set;}
    public List<Integer> maxRowSizeList {get;set;}
    
    //V_1.2 - Modified - Rajeev Jain - 03/22/2016 - CR-20160316-9698 - ISSP SFDC Critical NBB Calculation Fixes
    //Hold Standard Goal Detail's wrapper instamce corrosponding to each unique key.
    //Unique Key is formed of STDGoal.Id + '-' + STDGoal.Description__c + '-' + STDGoal.Period_Start__c  
    public Map<String, StdGoaldetailsWrapper> mapStdGoalDetails{get;set;}
    
    //V_1.3 - Modified - Rajeev Jain - 05/17/2016 - ISSP Deployment E - CR-20160512-9852
    //Map to hold the Sums To data
    public Map<String, Map<String, Personal_Goal__c>>  mapSummaryCalcsGoals{get;set;}
    
    //Constructor
    public CreatePersonalGoalsSectionWrapper(String conName, String conId, String businessTitle, Decimal businessTitlePercent, Boolean tenured,
                    Decimal tenuredPercent, Decimal cSTenuredPercent, List<StdGoaldetailsWrapper> stdGoalDetails, Integer maxRowSize, String tenuredSAId,
                    Boolean hasStaffRelationship, Map<Integer, Boolean> mapSelectableRows, Map<Integer, Boolean> mapSelection) {
        
        //set values
        this.conName = conName;
        this.conId = conId;
        this.businessTitle = businessTitle;
        this.businessTitlePercent = businessTitlePercent;
        this.tenured = false;
        this.tenuredPercent = tenuredPercent;
        this.stdGoalDetails = stdGoalDetails;
        this.maxRowSize = maxRowSize;
        this.tenured = tenured;
        this.cSTenuredPercent = cSTenuredPercent;
        this.tenuredSAId = tenuredSAId;
        this.hasStaffRelationship = hasStaffRelationship;
        this.mapSelectableRows = mapSelectableRows;
        this.mapSelection = mapSelection;
        
        //Set default
        maxRowSizeList = new List<Integer>();
        
        //Loop through the max rows
        for(Integer i = 0; i < maxRowSize; i++)
            maxRowSizeList.add(i);
            
        mapStdGoalDetails = new Map<String, StdGoaldetailsWrapper>();
        mapSummaryCalcsGoals = new Map<String, Map<String, Personal_Goal__c>>();
    }
    
    //Wrapper class to hold Std Goal details
    public class StdGoaldetailsWrapper {
        
        //Properties
        public Standard_Goal_Detail__c stdGoalDetail {get;set;}
        public List<StdGoalDetailPacingWrapper> stdGDetailPacings {get;set;}
        public String parentBaselineDescription{get;set;}
        public Decimal parentBaselineAmount{get;set;}
        public Date parentPeriodStart{get;set;}
        
        //Constructor
        public StdGoaldetailsWrapper(Standard_Goal_Detail__c stdGoalDetail, List<StdGoalDetailPacingWrapper> stdGDetailPacings) {
            
            //Set Values
            this.stdGoalDetail = stdGoalDetail;
            this.stdGDetailPacings = stdGDetailPacings;
        }
    }
    
    //Wrapper to hold Pacings corresponding to wrapper
    public class StdGoalDetailPacingWrapper {
        
        //Properties
        public Standard_Goal_Detail_Pacing__c stdGDPacing {get;set;}
        public Personal_Goal__c pGoal {get;set;}
        public String amount {get;set;}
        public Boolean selected {get;set;}
        public String description {get;set;}
        public Boolean showSelected {get;set;}
        public String comments {get;set;}
        public Decimal bTMultiplier {get;set;}
        public Boolean haveRelationships {get;set;}
        public String adjustmentValue {get;set;}
        public Boolean isCalc {get;set;}
        public Boolean isDisplay {get;set;}
        
        //Set to hold the Staff Relationship ids
        public Set<Id> setSRIds {get;set;}
        
        //Map to hold the Staff Relationship as key and PGR Id as value
        public Map<Id, Id> mapSRIdWithPGMPIds;
        
        //Variables to display the goal fields on the VF page
        public Boolean displayAmount {get;set;}
        public Boolean displayCount {get;set;}
        public Boolean displayPercent {get;set;}
        
        //V_1.3 - Modified - Rajeev Jain - 05/17/2016 - ISSP Deployment E - CR-20160512-9852
        //Hold Label Color for each one
        public String labelColorBTMultiplier{get;set;}
        public String labelColorAdjustmentValue{get;set;}
        public String labelColorTenured{get;set;}
        public String labelColorTenuredFlag{get;set;}
        public String labelColorValue{get;set;}
        //V_1.3 - Modified - Rajeev Jain - 05/17/2016 - ISSP Deployment E - CR-20160512-9852 - upto here
        
        //List of PGMP wrapper
        public List<PGMPeriodWrapper> pGMPeriods {get;set;}
        
        //Value to hold and check if already calculated in current transaction then don't calculate in the same transaction
        public Boolean isCalculated{get;set;}
        
        //Constructor
        public StdGoalDetailPacingWrapper(Standard_Goal_Detail_Pacing__c stdGDPacing, Personal_Goal__c pGoal, String description, Boolean showSelected,
                                          String amount, Decimal bTMultiplier, Boolean displayAmount, Boolean displayCount, Boolean displayPercent,
                                          Set<Id> setSRIds, List<PGMPeriodWrapper> pGMPeriods, Map<Id, Id> mapSRIdWithPGMPIds,
                                          String adjustmentValue, Boolean isDisplay) {
            
            //Set Values
            this.selected = false;
            this.showSelected = showSelected;
            this.stdGDPacing = stdGDPacing;
            this.pGoal = pGoal;
            this.description = description;
            this.amount = amount;
            this.comments = '';
            this.bTMultiplier = bTMultiplier;
            this.displayAmount = displayAmount;
            this.displayCount = displayCount;
            this.displayPercent = displayPercent;
            this.setSRIds = setSRIds;
            this.pGMPeriods = pGMPeriods;
            this.mapSRIdWithPGMPIds = mapSRIdWithPGMPIds;
            this.adjustmentValue = adjustmentValue;
            this.isDisplay = isDisplay;
            
            //Set Defaults
            isCalc = false;
            isCalculated = false;
            
            //Set Relationships flag
            if(setSRIds != null && setSRIds.size() > 0)
                haveRelationships = true;
            else
                haveRelationships = false;
        }
    }
    
    //Added - Subhash Garhwal - 11/25/2015 - CR-20151120-9407
    //Wrapper class to hold the Personal Goal Measurement Periods
    public class PGMPeriodWrapper implements Comparable {
        
        //Properties
        public Personal_Goal_Measurement_Period__c pGMP {get;set;}
        public Boolean selected {set;get;}
        
        //Constructor
        public PGMPeriodWrapper(Personal_Goal_Measurement_Period__c pGMP) {
            
            //Set values
            this.pGMP = pGMP;
            
            //Set defaults
            selected = false;
        }
        
        // Implement the compareTo() method
        public Integer compareTo(Object compareTo) {
        
            PGMPeriodWrapper compareToEmp = (PGMPeriodWrapper)compareTo;
            
            if (pGMP.Measurement_Date__c == compareToEmp.pGMP.Measurement_Date__c) return 0;
            if (pGMP.Measurement_Date__c > compareToEmp.pGMP.Measurement_Date__c) return 1;
            return -1;        
        }
    }
}