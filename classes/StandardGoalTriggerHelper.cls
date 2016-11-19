/**
 *  Description     :  Helper class for Trigger_StandardGoal trigger.
 *
 *  Created By      :  Padmesh Soni
 *
 *  Created Date    :  08/11/2015
 *
 *  Revision Logs   :   V_1.0 - Created - Padmesh Soni - CR-20150729-9114
 *
 **/
public without sharing class StandardGoalTriggerHelper {

	/**
     *	@description	:	Method to unCheck the active fields of Standard Goal Detail Object if Active field of Standard Goal is unchecked.
     *
	 *	@args			:	List<Standard_Goal__c> standardGoal, Map<Id, Standard_Goal__c> mapOldStandardGoal
	 *
	 *	@return			:	void
	 *
	 **/
	public static void inactiveStdGoalDetails(List<Standard_Goal__c> standardGoals, Map<Id, Standard_Goal__c> mapOldStandardGoals) {
	
		//Set to hold the Std Goal Ids
		Set<Id> setSGIds = new Set<Id>();
		
		//Loop through List for Standard Goal 
		for(Standard_Goal__c sG : standardGoals) {
			
			//Check for Active field and compare old and new active fields and populate set
			if(!sG.Active__c && (sG.Active__c != mapOldStandardGoals.get(sG.Id).Active__c))  
				setSGIds.add(sG.Id);
				
		}
		
		//Check Set Size
		if(setSGIds.size() >  0 ) {
			
			//List of Standard Goal Detail
			List<Standard_Goal_Detail__c> sGDetails = new List<Standard_Goal_Detail__c>();
		
			//Query on Standard Goal Detail to get all the active detail
			for(Standard_Goal_Detail__c sGD : [Select Id, Active__c from Standard_Goal_Detail__c where Standard_Goal__c IN : setSGIds AND Active__c = true]) {
				
				//Set Active fields to false
				sGD.Active__c = false; 
				sGDetails.Add(sGD);
			}
				
			//Check list size and update list
			if(sGDetails.size() > 0)
				update sGDetails;
		}
	}
}