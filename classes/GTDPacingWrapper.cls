/**
 *  Description     :  Wrapper class to sort the pacing records according to period start date
 *
 *  Created By      :  Subhash Garhwal
 *
 *  Created Date    :  11/19/2015
 *
 *  Revision Logs   :   V_1.0 - Created - Subhash Garhwal - CR-20150729-9114       
 *
 **/
public without sharing class GTDPacingWrapper implements Comparable {
	
	//Properties
	public Standard_Goal_Detail_Pacing__c gTDP;
	
	//Constructor
	public GTDPacingWrapper(Standard_Goal_Detail_Pacing__c gTDP) {
		
		//Set values
		this.gTDP = gTDP;
	}
	
	// Implement the compareTo() method
    public Integer compareTo(Object compareTo) {
    
        GTDPacingWrapper compareToEmp = (GTDPacingWrapper)compareTo;
        
        if (gTDP.Period_Start__c == compareToEmp.gTDP.Period_Start__c) return 0;
        if (gTDP.Period_Start__c > compareToEmp.gTDP.Period_Start__c) return 1;
        return -1;        
    }
}