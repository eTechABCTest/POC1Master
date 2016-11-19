/**
 *  Purpose            :   This class is used to draw Goals table on "Assign New Goals to Plans" page's tab 2 (Confirm Plan Assignment).
 *
 *  Created By         :   Subhash Garhwal
 *
 *  Created Date       :   11/17/2015
 *
 *  Current Version    :   V_1.0
 *
 *  Revision Log       :   V_1.0 - Created - CR-20150729-9114 - Goal Management System
 *
 **/
public with sharing class GoalsToPlanAssignmentWrapper implements Comparable {
    
    //Properties
    public String payeeId {get;set;}
    public String payeeName {get;set;}
    public String selectedPP {get;set;}
    public List<SelectOption> personalPlans {get;set;}
    public Personal_Plan__c personalPlan {get;set;}
    public Decimal currentWeight {get;set;}
    public Decimal newWeight {get;set;}
    public List<PersonalGoalWrapper> personalGoals {get;set;}
    
    //Behviour Picklist, populates when if user select any value in Plan Picklist(List<SelectOption> personalPlans) on the page, Default it will be blank
    public List<SelectOption> behaviourOptions{get;set;}
    public String selectedBehaviourOption{get;set;}
    
    //Constructor
    public GoalsToPlanAssignmentWrapper(String payeeId, String payeeName, Decimal newWeight, List<SelectOption> personalPlans, List<PersonalGoalWrapper> personalGoals,
                                        Personal_Plan__c personalPlan) {
        
        //Set values
        this.payeeId = payeeId;
        this.payeeName = payeeName;
        this.newWeight = newWeight;
        this.personalPlans = personalPlans;
        this.personalGoals = personalGoals;
        this.personalPlan = personalPlan;
        
        //Set Defaults
        personalPlan = new Personal_Plan__c();
        selectedPP = '';
        currentWeight = null;
        behaviourOptions = new List<SelectOption>();
        selectedBehaviourOption = '';
    }
    
    // Implement the compareTo() method
    public Integer compareTo(Object compareTo) {
    
        
        GoalsToPlanAssignmentWrapper compareToEmp = (GoalsToPlanAssignmentWrapper)compareTo;
        
        if (payeeName == compareToEmp.payeeName) return 0;
        if (payeeName > compareToEmp.payeeName) return 1;
        return -1;        
    }
    
    //Wrapper class to hold the Personal Plan Properties
    public class PersonalGoalWrapper {
        
        //Properties
        public Personal_Goal__c personalGoal {get;set;}
        public String rateTemplate {get;set;}
        public String payeeName {get;set;}
        public List<PGMeasurementPeriod> pGMPeriods {get;set;}
        
        /** Decide color of the personal goal based on its Related Goal (Primary_Goal__c) properties
			1 - Green	:	If related goal's persoanl plan lookup is blank
			2 - Yellow	:	If related goal's Status is 'Pending'
			3 - Red		:	If related goal's Status is 'Payee Approved'
		**/
		public String pgColor{get;set;}
		
		//Map to hold the Proposed Goal's PGMP Id with the Parent Snapshot's PGMP Id if dates are same
        public Map<Id, Id> mapPGPGMPWithSSPGMP;
		
        //Constructor
        public PersonalGoalWrapper(Personal_Goal__c personalGoal,String payeeName, List<PGMeasurementPeriod> pGMPeriods, Map<Id, Id> mapPGPGMPWithSSPGMP, String pgColor) {
            
            //Set Values
            this.personalGoal = personalGoal;
            this.payeeName = payeeName;
            this.pGMPeriods = pGMPeriods;
            this.mapPGPGMPWithSSPGMP = mapPGPGMPWithSSPGMP;
            this.pgColor = pgColor;
        }
    }
    
    //Wrapper to hold the Personal Goal Measurement Period dates
    public class PGMeasurementPeriod implements Comparable {
    	
    	//Properties
		public Personal_Goal_Measurement_Period__c pGMP {get;set;}
		public Boolean selected {set;get;}
		
		//Constructor
		public PGMeasurementPeriod(Personal_Goal_Measurement_Period__c pGMP) {
			
			//Set values
			this.pGMP = pGMP;
			
			//Set defaults
			selected = false;
		}
		
		// Implement the compareTo() method
	    public Integer compareTo(Object compareTo) {
	    
	        PGMeasurementPeriod compareToEmp = (PGMeasurementPeriod)compareTo;
	        
	        if (pGMP.Measurement_Date__c == compareToEmp.pGMP.Measurement_Date__c) return 0;
	        if (pGMP.Measurement_Date__c > compareToEmp.pGMP.Measurement_Date__c) return 1;
	        return -1;        
	    }
    }
}