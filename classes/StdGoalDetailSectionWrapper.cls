/**
 *  Purpose         :   Wrapper for Define Standard Detail Goal section on DefineStandardGoal VF page.
 *  
 *  Created By      :   Subhash Garhwal
 * 
 *  Created Date    :   08/18/2015 
 * 
 *  Revision Logs   :   V_1.0 - Created - CR-20150729-9114
 *                      V_1.1 - Modified - Subhash Garhwal - 11/25/2015 - CR-20151120-9407
 *                      V_1.2 - Modified - Rajeev Jain - 1/21/2015 - SUMs To issue fix
 *                      V_1.2 - Modified - Rajeev Jain - 02/29/2016 - CR-20160125-9561 - ISSP Deployment D
 *                      V_1.3 - Modified - Rajeev Jain - 04/15/2016 - CR-20160304-9674 - ISSP Deployment E - Sort Conditions By Condition Name
 * 
 **/
public with sharing class StdGoalDetailSectionWrapper {
    
    //Proprties
    public Standard_Goal_Detail__c stdGD {get;set;}
    public List<StdGoalDetailWrapper> stdGoalDetailsWrapper {get;set;}
    public String selectedSGDRowIndex{get;set;}
    public List<selectOption> availableBaseLines {get;set;}
    public String selectedBaseLine {get;set;}
    public StdGoalDetailWrapper stdGDetailsWrapper {get;set;}
    public String discountType {get;set;}
    
    //V_1.2 - Added By - Rajeev Jain - 1/21/2015 - SUMs To issue fix
    //Map to Hold Hierachy of the Child GTD to maintain SUMs to List
    public Map<String, Set<String>> mapForSUMstoRelationship{get;set;}
    
    //Constructor
    public StdGoalDetailSectionWrapper() {
        
        //Initialize properties
        //V_1.2 - Modified - Rajeev Jain - 02/29/2016 - CR-20160125-9561 - ISSP Deployment D - Changed default target type to Explicit
        //stdGD = new Standard_Goal_Detail__c(Target_Type__c = ISSPConstants.STANDARD_GOAL_DETAIL_TARGET_TYPE_PACED, Baseline_Percentage__c = 100, Weighting__c = 0);
        stdGD = new Standard_Goal_Detail__c(Target_Type__c = ISSPConstants.STANDARD_GOAL_DETAIL_TARGET_TYPE_EXPLICIT, Baseline_Percentage__c = 100, Weighting__c = 0);
        //V_1.2 - Modified - Rajeev Jain - 02/29/2016 - CR-20160125-9561 - ISSP Deployment D - Up to here
        
        stdGoalDetailsWrapper = new List<StdGoalDetailWrapper>();
        selectedSGDRowIndex = '';
        availableBaseLines = new List<SelectOption>();
        availableBaseLines.add(new SelectOption('', '--NONE--'));
        availableBaseLines.add(new SelectOption(ISSPConstants.TEMPLATE_BASELINE, ISSPConstants.TEMPLATE_BASELINE));
        this.selectedBaseLine = ISSPConstants.TEMPLATE_BASELINE;
        discountType = '';
        
        stdGDetailsWrapper = new StdGoalDetailWrapper();
        
        mapForSUMstoRelationship = new Map<String, Set<String>>();
        
    }
    
    //Wrapper to hold Std Goal Details 
    public class StdGoalDetailWrapper implements Comparable {
        
        //Properties
        public Standard_Goal_Detail__c stdGDetail {get;set;}
        public String goalType {get;set;}
        public Boolean selected {get;set;}
        public String selectedBaseLine {get;set;}
        public String selectedBaseLineLabel {get;set;}
        public List<SelectOption> avaliableBaseLine {get;set;}
        public String selectedParent {get;set;}
        public List<SelectOption> availableParents {get;set;}
        public String selectedparentLabel {get;set;}
        public String selectedSalesRoleRowIndex{get;set;}
        public Integer rowIndex {get;set;}
        public List<StdGoalDetailConditions> stdGoalDetailConditions {get;set;}
        public List<SelectOption> valueTypes {get;set;}
        public String selectedValueType {get;set;}
        public List<SelectOption> bLValueTypes {get;set;}
        public Decimal gTAmount;
        public Decimal gTCounter;
        public Decimal gTPercent;
        public Decimal value;
        public Decimal discount;
        public Integer childGTDs;
        public Boolean isExisting;
        
        public Boolean isUseAsBaseline{get;set;}
        
        //Variables for Period functionality
        public List<SelectOption> periods {get;set;}
        public Map<String, Incentive_Defaults__c> mapPeriods;
        
        //Added - Subhash Garhwal - 11/25/2015 - CR-20151120-9407
        public List<GTDMPeriod> gTDMPeriods {get;set;}
        
        //Added - Rajeev Jain - 1/22/2016 - String to Hold the Unique Key of Previous SUMSTo
        public String previousSUMSto{get;set;}
             
        //Constructor
        public StdGoalDetailWrapper(Standard_Goal_Detail__c stdGDetail, String goalType, String selectedBaseLine, List<SelectOption> avaliableBaseLine,
                                    Integer rowIndex, String selectedBaseLineLabel, List<StdGoalDetailConditions> stdGoalDetailConditions,
                                    String selectedParent, List<SelectOption> availableParents, String selectedparentLabel, Decimal gTAmount,
                                    Decimal gTCounter, Decimal gTPercent, Boolean isExisting, List<GTDMPeriod> gTDMPeriods) {
            
            //Set values
            this.stdGDetail = stdGDetail;
            this.goalType = goalType;
            this.selectedBaseLine = selectedBaseLine;
            this.avaliableBaseLine = avaliableBaseLine;
            this.rowIndex = rowIndex;
            selected = false;
            this.selectedBaseLineLabel = selectedBaseLineLabel;
            this.stdGoalDetailConditions = stdGoalDetailConditions;
            this.selectedParent = selectedParent;
            this.availableParents = availableParents;
            this.selectedparentLabel = selectedparentLabel;
            this.gTAmount = gTAmount;
            this.gTCounter = gTCounter;
            this.gTPercent = gTPercent;
            this.isExisting = isExisting;
            this.gTDMPeriods = gTDMPeriods;
            this.isUseAsBaseline = false;
            //Set values
            discount = stdGDetail.Discount__c;
            
            //Initlize the option
            valueTypes = new List<SelectOption>();
            bLValueTypes = new List<SelectOption>();
            
            //Add available Options
            valueTypes.add(new SelectOption(ISSPConstants.GTD_VALUE_TYPE_AMOUNT, ISSPConstants.GTD_VALUE_TYPE_AMOUNT));
            valueTypes.add(new SelectOption(ISSPConstants.GTD_VALUE_TYPE_COUNT, ISSPConstants.GTD_VALUE_TYPE_COUNT));
            valueTypes.add(new SelectOption(ISSPConstants.GTD_VALUE_TYPE_PERCENT, ISSPConstants.GTD_VALUE_TYPE_PERCENT));
            
            bLValueTypes.add(new SelectOption(ISSPConstants.GTD_VALUE_TYPE_AMOUNT, ISSPConstants.GTD_VALUE_TYPE_AMOUNT));
            bLValueTypes.add(new SelectOption(ISSPConstants.GTD_VALUE_TYPE_COUNT, ISSPConstants.GTD_VALUE_TYPE_COUNT));
            
            //Set default selected value type
            selectedValueType = 'Amount';
            value = stdGDetail.Amount__c;
            childGTDs = 0;
            
            //Check for values
            if((stdGDetail.Amount__c != null && stdGDetail.Amount__c > 0)
                || (stdGDetail.Amount__c != null && stdGDetail.Count__c == null && stdGDetail.Percent__c == null)) {
                
                //Set Value and selected value type
                selectedValueType = ISSPConstants.GTD_VALUE_TYPE_AMOUNT;
                value = stdGDetail.Amount__c;
            
            }else if((stdGDetail.Count__c != null && stdGDetail.Count__c > 0)
                || (stdGDetail.Count__c != null && stdGDetail.Amount__c == null && stdGDetail.Percent__c == null)) {
                
                //Set Value and selected value type
                selectedValueType = ISSPConstants.GTD_VALUE_TYPE_COUNT;
                value = stdGDetail.Count__c;
            
            } else if((stdGDetail.Percent__c != null && stdGDetail.Percent__c > 0)
                || (stdGDetail.Percent__c != null && stdGDetail.Amount__c == null && stdGDetail.Count__c == null)) {
                
                //Set Value and selected value type
                selectedValueType = ISSPConstants.GTD_VALUE_TYPE_PERCENT;
                value = stdGDetail.Percent__c;
                
            }
            
            stdGDetail.Value_Type__c = selectedValueType;
                
            //Initlize Values
            periods = new List<SelectOption>();
            periods.add(new SelectOption('','--NONE--'));
            
            mapPeriods = new Map<String, Incentive_Defaults__c>();
            
            //Call method tp populate the period options and Period map
            populatePeriods(periods, mapPeriods);
        }
        
        //Constructor
        public StdGoalDetailWrapper() {
            
            //Initlize the option
            valueTypes = new List<SelectOption>();
            bLValueTypes = new List<SelectOption>();
            
            //Add available Options
            valueTypes.add(new SelectOption(ISSPConstants.GTD_VALUE_TYPE_AMOUNT, ISSPConstants.GTD_VALUE_TYPE_AMOUNT));
            valueTypes.add(new SelectOption(ISSPConstants.GTD_VALUE_TYPE_COUNT, ISSPConstants.GTD_VALUE_TYPE_COUNT));
            valueTypes.add(new SelectOption(ISSPConstants.GTD_VALUE_TYPE_PERCENT, ISSPConstants.GTD_VALUE_TYPE_PERCENT));
            
            bLValueTypes.add(new SelectOption(ISSPConstants.GTD_VALUE_TYPE_AMOUNT, ISSPConstants.GTD_VALUE_TYPE_AMOUNT));
            bLValueTypes.add(new SelectOption(ISSPConstants.GTD_VALUE_TYPE_COUNT, ISSPConstants.GTD_VALUE_TYPE_COUNT));
            
            //Set default selected value type
            selectedValueType = ISSPConstants.GTD_VALUE_TYPE_AMOUNT;
            childGTDs = 0;
            
            //Set Default Parent
            availableParents = new List<SelectOption>();
            
            //Add Default Parent
            availableParents.add(new SelectOption('', '--NONE--'));
            isExisting = false;
            
            //Initlize Values
            periods = new List<SelectOption>();
            periods.add(new SelectOption('','--NONE--'));
            
            mapPeriods = new Map<String, Incentive_Defaults__c>();
            
            //Call method tp populate the period options and Period map
            populatePeriods(periods, mapPeriods);
            
        }
        
        /**
         *  @description    :   Thiis method is used to populate the Periods Wrapper
         *
         *  @args           :   List<SelectOption>, Map<String, Incentive_Defaults__c>
         *
         *  @return         :   void
         *
         **/
        public void populatePeriods(List<SelectOption> options, Map<String, Incentive_Defaults__c> mapPeriods) {
            
            //Query through the Incentive Defaults
            for(Incentive_Defaults__c incentiveDef : [Select Id, Name, Start__c, End__c, Percent__c From Incentive_Defaults__c Where Description__c != null AND Category__c = 'Periods'
                                                   ORDER BY Description__c ASC, Start__c ASC]) {
                
                //Populate the Options
                options.add(new SelectOption(incentiveDef.Name, incentiveDef.Name));
                
                //Populate map
                mapPeriods.put(incentiveDef.Name, incentiveDef);
            }       
        }
        
        // Implement the compareTo() method
        public Integer compareTo(Object compareTo) {
        
            
            StdGoalDetailWrapper compareToEmp = (StdGoalDetailWrapper)compareTo;
            
            if (stdGDetail.Description__c == compareToEmp.stdGDetail.Description__c) return 0;
            if (stdGDetail.Description__c > compareToEmp.stdGDetail.Description__c) return 1;
            return -1;        
        }
    }
    
    //V_1.3 - Added By - Rajeev Jain - 04/15/2016 - CR-20160304-9674 - ISSP Deployment E - Sort Conditions By Condition Name
    // Wrapper class to hold the Instnace of Condition Wrapper corrosponding to each condition set
    public class StdGdConditionsWithConditionSet implements Comparable{
        
        public Decimal conditionSet{get;set;}
        public List<StdGoalDetailConditions> conWrapList{get;set;}
        
        public StdGdConditionsWithConditionSet(Decimal conditionSet, List<StdGoalDetailConditions> conWrapList){
            this.conditionSet = conditionSet;
            this.conWrapList = conWrapList;
        }
        
        // Implement the compareTo() method
        public Integer compareTo(Object compareTo) {
        
            StdGdConditionsWithConditionSet compareToEmp = (StdGdConditionsWithConditionSet)compareTo;
            
            if (conditionSet == compareToEmp.conditionSet) return 0;
            if (conditionSet > compareToEmp.conditionSet) return 1;
            return -1;        
        }
    }
    
    //V_1.3 - Modified By - Rajeev Jain - 04/15/2016 - CR-20160304-9674 - ISSP Deployment E - Sort Conditions By Condition Name
    //Wrapper class to hold the Std goal detail contions
    public class StdGoalDetailConditions implements Comparable{
        
        //Properties
        public Boolean selected {get;set;}
        public Condition__c con {get;set;}
        public String rType {get;set;} 
        public String value {get;set;}
        public Integer rowNumber {get;set;}
        
        //Var for compare to 
        public String compareName{get;set;}
        
        //Constructor
        public StdGoalDetailConditions(Condition__c con, String rType, String value, Integer rowNumber) {
            
            //Set values
            selected = false;
            this.con = con;
            this.rType = rType;
            this.value = value;
            this.rowNumber = rowNumber;
            compareName = this.value;
        }
        
        // Implement the compareTo() method
        public Integer compareTo(Object compareTo) {
        
            StdGoalDetailConditions compareToEmp = (StdGoalDetailConditions)compareTo;
            
            if (compareName == compareToEmp.compareName) return 0;
            if (compareName > compareToEmp.compareName) return 1;
            return -1;        
        }
    }
    
    //Added - Subhash Garhwal - 11/25/2015 - CR-20151120-9407
    //Wrapper class to hold the GTDMP
    public class GTDMPeriod implements Comparable {
        
        //Properties
        public Goal_Template_Detail_Measurement_Period__c gTDMP {get;set;}
        public Boolean selected {get;set;}
        public Integer rowNumber {get;set;}
        
        //Constructor
        public GTDMPeriod(Goal_Template_Detail_Measurement_Period__c gTDMP, Integer rowNumber) {
            
            //Set Values
            this.gTDMP = gTDMP;
            this.rowNumber = rowNumber;
            
            //Set default values
            selected = false;
        }
        
        // Implement the compareTo() method
        public Integer compareTo(Object compareTo) {
        
            GTDMPeriod compareToEmp = (GTDMPeriod)compareTo;
            
            if (gTDMP.Measurement_Date__c == compareToEmp.gTDMP.Measurement_Date__c) return 0;
            if (gTDMP.Measurement_Date__c > compareToEmp.gTDMP.Measurement_Date__c) return 1;
            return -1;        
        }
    }
}