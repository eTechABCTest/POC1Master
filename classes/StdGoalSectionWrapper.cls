/**
 *  Purpose         :   Wrapper for Define Standard Goal section on DefineStandardGoal VF page.
 *  
 *  Created By      :   Subhash Garhwal
 * 
 *  Created Date    :   08/17/2015 
 * 
 *  Revision Logs   :   V_1.0 - Created - CR-20150729-9114
 *                  :   V_2.0 - Modified By - Rajeev Jain - CR-20160304-9674 - 04/05/2016 - 
 *                      Added new properties for Condition set in order to maintain it for each seprated condition type, Sort By Conditiion Name
 * 
 **/
public with sharing class StdGoalSectionWrapper {
    
    //Properties
    public Condition__c condition{get;set;}
    public Standard_Goal_Sales_Role__c stdGSR {get;set;}
    public List<ConditionWrapper> conditionsWrapper {get;set;}
    public List<SalesRoleWrapper> stdGSRs {get;set;}
    public String selectedRType {get;set;}
    public String selectedConditionRowIndex{get;set;}
    public String selectedSalesRoleRowIndex{get;set;}
    public String selectedRecordTypeId{get;set;}
    public Map<Id,String> mapConRecordTypes;
    public List<SelectOption> conditionRTypes {get;set;}
    public List<SelectOption> stdGoalValueTypes {get;set;}
    public String selectedSGValueType {get;set;}
    
    //Constructor
    public StdGoalSectionWrapper() {
        
        //Initialize properties
        condition = new Condition__c(Condition_Type__c = 'Include');
        
        //Default value initialize
        condition.Condition_Set__c = ISSPConstants.DEFAULT_VALUE_CONDITION_SET;
        
        stdGSR = new Standard_Goal_Sales_Role__c();
        conditionsWrapper = new List<ConditionWrapper>();
        stdGSRs = new List<SalesRoleWrapper>();
        selectedConditionRowIndex = '';
        selectedSalesRoleRowIndex = '';
        selectedRecordTypeId = '';
        mapConRecordTypes = new Map<Id,String>();
        stdGoalValueTypes = new List<SelectOption>();
        
        //Select Option
        List<SelectOption> options = new List<SelectOption>();
        
        //Add option
        options.add(new SelectOption('', '--None--'));
        
        //Loop through condition record type
        for(RecordType rType : [Select Id, Name,DeveloperName From RecordType Where SObjectType = 'Condition__c' ORDER BY Name ASC]) {
            
            //Add Record Type in select option
            options.add(new SelectOption(rType.Id, rType.Name));
            
            //Add values in map
            mapConRecordTypes.put(rType.Id, rType.DeveloperName);
        }
        
        //Set Record Type Options   
        conditionRTypes = options;
        
        //Populate std goal value types
        stdGoalValueTypes.add(new SelectOption('Amount', 'Amount'));
        stdGoalValueTypes.add(new SelectOption('Count', 'Count'));
        stdGoalValueTypes.add(new SelectOption('Percent', 'Percent'));
        
        //Set amount to default
        selectedSGValueType = 'Amount';
        
    }
    
    // Wrapper class to hold the Instnace of Condition Wrapper corrosponding to each condition set
    public class ConditionWrapperWithConditionSet implements Comparable{
        
        public Decimal conditionSet{get;set;}
        public List<ConditionWrapper> conWrapList{get;set;}
        
        public ConditionWrapperWithConditionSet(Decimal conditionSet, List<ConditionWrapper> conWrapList){
            this.conditionSet = conditionSet;
            this.conWrapList = conWrapList;
        }
        
        // Implement the compareTo() method
        public Integer compareTo(Object compareTo) {
        
            ConditionWrapperWithConditionSet compareToEmp = (ConditionWrapperWithConditionSet)compareTo;
            
            if (conditionSet == compareToEmp.conditionSet) return 0;
            if (conditionSet > compareToEmp.conditionSet) return 1;
            return -1;        
        }
    }
    //V_2.0 - Modified By - Rajeev Jain - CR-20160304-9674 - 04/05/2016 - Provided Sorting by Condition Name
    //Wrapper to hold Condition Data
    public class ConditionWrapper implements Comparable{
        
        //Properties
        public Boolean selected {get;set;}
        public Condition__c con {get;set;}
        public String rType {get;set;} 
        public String value {get;set;}
        public Integer rowNumber {get;set;}
        
        //Var for compare to 
        public String compareName{get;set;}
        
        //Constructor
        public ConditionWrapper(Condition__c con, String rType, String value, Integer rowNumber) {
            
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
        
            ConditionWrapper compareToEmp = (ConditionWrapper)compareTo;
            
            if (compareName == compareToEmp.compareName) return 0;
            if (compareName > compareToEmp.compareName) return 1;
            return -1;        
        }
    }
    
    //Wrapper to hold Sales Role data
    public class SalesRoleWrapper {
        
        //Properties
        public Standard_Goal_Sales_Role__c stdGSR {get;set;}
        public String salesRole {get;set;}
        public Boolean selected {get;set;}
        public Integer rowNumber {get;set;}
        public Boolean isExisting;
        
        //Constuctor
        public SalesRoleWrapper(Standard_Goal_Sales_Role__c stdGSR, String salesRole, Integer rowNumber, Boolean isExisting) {
            
            //Set values
            this.stdGSR = stdGSR;
            this.salesRole = salesRole;
            this.rowNumber = rowNumber;
            selected = false;
            this.isExisting = isExisting;
        }
    }
}