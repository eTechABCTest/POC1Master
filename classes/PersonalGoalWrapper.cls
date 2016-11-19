/**
 *  Description     :  Wrapper class to sort the PG records according to period start date
 *
 *  Created By      :  Subhash Garhwal
 *
 *  Created Date    :  11/19/2015
 *
 *  Revision Logs   :   V_1.0 - Created - Subhash Garhwal - CR-20150729-9114       
 *
 **/
public without sharing class PersonalGoalWrapper implements Comparable {
	
	//Properties
	public Personal_Goal__c pG;
	
	//Constructor
	public PersonalGoalWrapper(Personal_Goal__c pG) {
		
		//Set values
		this.pG = pG;
	}
	
	// Implement the compareTo() method
    public Integer compareTo(Object compareTo) {
    
        PersonalGoalWrapper compareToEmp = (PersonalGoalWrapper)compareTo;
        
        if (pG.Period_Start__c == compareToEmp.pG.Period_Start__c) return 0;
        if (pG.Period_Start__c > compareToEmp.pG.Period_Start__c) return 1;
        return -1;        
    }
}