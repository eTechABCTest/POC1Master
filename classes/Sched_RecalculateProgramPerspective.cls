/**
 * 	Purpose			:	Scheduler class to validate Program Perspective on Staff Assignment.
 * 
 * 	Created By		:	Subhash Garhwal
 * 
 *	Created Date	:	06/30/2015 
 * 
 * 	Revision Logs	:	V_1.0 - Created - CR-20150618-9014
 * 
 **/ 
global class Sched_RecalculateProgramPerspective implements Schedulable {
	
	//Execute method
	global void execute(SchedulableContext sc) {
		
		//Set to hold Staff Assignment Ids
		Set<Id> setSAIds = new Set<Id>();
		
		//Query through Role Program Perspective
		for(Role_Program_Perspective__c rPP : [Select Id, Staff_Assignment__c, Effective_End__c From Role_Program_Perspective__c Where Staff_Assignment__c != null AND Effective_End__c = YESTERDAY])
			setSAIds.add(rPP.Staff_Assignment__c);
		
		//Check for set size
		if(setSAIds.size() > 0) {
			
			//Call TeamMembershipTriggerHelper class method to populate correct Program Perspectives on Staff Assignment
			TeamMembershipTriggerHelper.recalculateProgramPerspectives([Select Id, Program_Perspectives__c From Team_Membership__c Where Id IN : setSAIds]);
		}
	}
}