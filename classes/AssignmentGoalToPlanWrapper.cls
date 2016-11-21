/**
 *  Purpose            :  	This class is used to draw Goals table on "Assign New Goals to Plans" page.
 *
 *  Created By         :   	Subhash Garhwal
 *
 *  Created Date       :   	10/09/2015
 *
 *  Current Version    :   	V_1.0
 *
 *  Revision Log       :   	V_1.0 - Created - CR-20150729-9114 - Goal Management System
 *							V_1.2 - Modified - Subhash Garhwal - 12/18/2015 - CR-20151217-9469 - ISSP Deployment C.
 *
 **/
public with sharing class AssignmentGoalToPlanWrapper implements Comparable {
	
	//Properties
	public String conName {get;set;}
	public String conId {get;set;}
	public String businessTitle {get;set;}
	public Id businessTitleId;
	public String incentiveRole {get;set;}
	public Id incentiveRoleId;
	public String programCollection {get;set;}
	public Id programCollectionId;
	public Boolean tenured {get;set;}
	public List<GoalTypeWrapper> goalTypes {get;set;}
	public Map<Integer, Boolean> mapSelectableRows {get;set;}
	public Integer maxRows {get;set;}
	public Map<Integer, Boolean> mapSelection {get;set;}
	
	//Constructor definition
	public AssignmentGoalToPlanWrapper() {
		
		//Initlize properties
		goalTypes = new List<GoalTypeWrapper>();
		mapSelectableRows = new Map<Integer, Boolean>();
		mapSelection = new Map<Integer, Boolean>();
		maxRows = 0;
	}
	
	//Wrapper to hold the Goal Type data
	public class GoalTypeWrapper {
		
		//Properties
		public Id gTId {get;set;}
		public List<PersonalGoalWrapper> personalGoals {get;set;}
		
		//Construcotr
		public GoalTypeWrapper(Id gTId) {
			
			//Set Values
			this.gTId = gTId;
			 
			//Initlize properties
			personalGoals = new List<PersonalGoalWrapper>();
		}
	}
	
	//Wrapper class to hold the Personal Goal data
	public class PersonalGoalWrapper {
		
		//Properties
		public Personal_Goal__c personalGoal {get;set;}
		public List<Condition__c> conditions {get;set;}
		public Boolean hasPP {get;set;}
		public Boolean selected {get;set;}
		public Boolean hasEmptyRow {get;set;}
		public String period {get;set;}
		public String pGsteps {get;set;}
		
		/** Decide color of the personal goal based on its Related Goal (Primary_Goal__c) properties
			1 - Green	:	If related goal's persoanl plan lookup is blank
			2 - Yellow	:	If related goal's Status is 'Pending'
			3 - Red		:	If related goal's Status is 'Payee Approved'
		**/
		public String pgColor{get;set;}
		
		//Constructor definition
		public PersonalGoalWrapper() {
			
			//Initlize properties
			personalGoal = new Personal_Goal__c(Weighting__c = 0);
			conditions = new List<Condition__c>();
			hasPP = false;
			selected = false;
			hasEmptyRow = false;
			period = '';
			pgColor = '#000';
			pGsteps = '';
		}
	}
	
	// Implement the compareTo() method
    public Integer compareTo(Object compareTo) {
    
        
        AssignmentGoalToPlanWrapper compareToEmp = (AssignmentGoalToPlanWrapper)compareTo;
        
        if (conName == compareToEmp.conName) return 0;
        if (conName > compareToEmp.conName) return 1;
        return -1;        
    }
}