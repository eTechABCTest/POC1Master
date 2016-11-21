/**
 * 	Purpose			:	Wrapper for Define Standard Detail Goal Pacing section on DefineStandardGoal VF page.
 *	
 * 	Created By		:	Subhash Garhwal
 * 
 *	Created Date	:	08/18/2015 
 * 
 * 	Revision Logs	:	V_1.0 - Created - CR-20150729-9114
 * 
 **/
public with sharing class StdGoalDetailPacingSectionWrapper {
	
	//Properties
	public List<SelectOption> avaliableStdGDetails {get;set;}
	public List<SelectOption> periods {get;set;}
	public Map<String,List<StdGoalDetailPacing>> stdGDetailPacings {get;set;}
	public String selectedStdGDetail {get;set;}
	public String selectedPeriod {get;set;}
	public Standard_Goal_Detail_Pacing__c stdGDPacing {get;set;}
	public String selectedRowIndex{get;set;}
	public List<SelectOption> valueTypes {get;set;}
	public String selectedValueType {get;set;}
	public String stdGoalDetailTargetType {get;set;}
	
	//Map to hold the Incentive defaults list with unique description
    public Map<String, List<Incentive_Defaults__c>> mapIncentiveDefaults;
    
	//Constructor
	public StdGoalDetailPacingSectionWrapper() {
		
		//Set values
		mapIncentiveDefaults = new Map<String, List<Incentive_Defaults__c>>();
		stdGoalDetailTargetType = '';
		//Select Option
		List<SelectOption> options = new List<SelectOption>();
		options.add(new SelectOption('','--NONE--'));
		
		//Query through the Incentive Defaults
		for(Incentive_Defaults__c incDefaults : [Select Id, Name,Category__c, Description__c, End__c, Percent__c, Start__c From Incentive_Defaults__c
														Where Description__c != null AND Category__c = 'Periods' ORDER BY Start__c ASC]) {
															
			//Check description in map
			if(!mapIncentiveDefaults.containsKey(incDefaults.Description__c)) {
				
				//Populate map and select option
				mapIncentiveDefaults.put(incDefaults.Description__c, new List<Incentive_Defaults__c>());
				options.add(new SelectOption(incDefaults.Description__c, incDefaults.Description__c));
			}
			
			//Add custom setting data into map
			mapIncentiveDefaults.get(incDefaults.Description__c).add(incDefaults);												
		}
		
		//Set values
		periods = options; 
		selectedRowIndex = '';
		
		//Initialize properties
		avaliableStdGDetails = new List<SelectOption>();
		stdGDetailPacings = new Map<String,List<StdGoalDetailPacing>>();
		stdGDPacing = new Standard_Goal_Detail_Pacing__c();
		valueTypes = new List<SelectOption>();
		
		//Add options
		valueTypes.add(new SelectOption('Percent', 'Percent'));
		
		//Set default
		selectedValueType = 'Percent';
	}
	
	//Wrapper class to hold Std Goal Detail Pacings
	public class StdGoalDetailPacing {
		
		//Properties
		public Standard_Goal_Detail_Pacing__c stdGDPacing {get;set;}
		public Boolean selected {get;set;}
		public Integer rowNumber {get;set;}
		public List<SelectOption> valueTypes {get;set;}
		public String selectedValueType {get;set;}
		public String stdGoalDetailTargetType {get;set;}
		public Boolean isExisting;
		
		
		//Constructor
		public StdGoalDetailPacing(Standard_Goal_Detail_Pacing__c stdGDPacing, Integer rowNumber, String stdGoalDetailTargetType, Boolean isExisting) {
			
			//Set values
			this.stdGDPacing = stdGDPacing;
			this.rowNumber = rowNumber;
			this.stdGoalDetailTargetType = stdGoalDetailTargetType;
			this.isExisting = isExisting;
			selected = false;
			valueTypes = new List<SelectOption>();
			
			//Add options
			valueTypes.add(new SelectOption('Percent', 'Percent'));
			
			//Set default
			selectedValueType = 'Percent';
		}
	}
}