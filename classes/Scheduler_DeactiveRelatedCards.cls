/**
 *	Purpose			:	As there is a limit that Setup and Non setup objects can not be updated in same transaction, 
 						so this class is being called from UserTriggerHelper class to create the OSR, 
 						deactivate portfolio and deactivate related credit cards
 *
 *	Created By		:	Bhavi Sharma	
 *
 *	Created Date	:	01/23/2015
 *
 *	Revision Logs	:	V_1.0 - Created
 *
 **/ 
global class Scheduler_DeactiveRelatedCards implements Schedulable {
	
	//Properties
	global List<OSR__c> oSRs;
	global List<Portfolio__c> portfolios;
	
	//Execute method
	global void execute(SchedulableContext SC) {
		
		//Check for the size and update
		insert oSRs;
		update portfolios;
	}
}