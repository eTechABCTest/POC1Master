/**
    Purpose         :   This trigger to handle all the processing for OAB Lead Passer object.
                
    Create By       :   Ajit Surana
    
    Created Date    :   10/16/2014
    
    Revision Logs   :   V_1.0 - Created - CR-20140917-7382 - 10/16/2014
**/
trigger Trigger_OAB_Lead_Passer on OAB_Lead_Passer__c (after delete, after update, after insert) {

	//Flag to bypass the trigger logic when required
	if (Util.BypassAllTriggers) return;

	//Checking for event type
    if(Trigger.isAfter) {
        
        //Added By - Ajits Surana - CR-20140917-7382 - 10/16/2014    
		//Checking for request type
		if(Trigger.isInsert || Trigger.isUpdate || Trigger.isDelete) {
			
			//Allows this object to be used in the Compete App
			//Added as part of CR-7382
			//ePrize_Zemzu.SCBCustomContestEvaluator.evaluate('OAB_Lead_Passer__c',Trigger.new,Trigger.old);
		}
    }            
}