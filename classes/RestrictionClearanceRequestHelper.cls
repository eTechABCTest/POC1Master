/*
    Purpose         :   This class is helper class for trigger on Restriction Clearance Requests object.
                
    Create By       :   Simplyforce Technology
    
    Created Date    :   11/07/2012
    
    Current Version :   v1.0
    
    Revision Log    :   V_1.0 Created - CR-20120924-1526
*/
public without sharing class RestrictionClearanceRequestHelper {
	
	//This method is to update the Warm Lead status when restriction Clearance Request is getting created
	public static void updateWarmLeads(List<Restriction_Clearance_Request__c> rCRequests) {
		
		//Create a set to hold the warm lead Ids and maintian the uniqueness
		Set<Id> warmLeadsIds = new Set<Id>();
		
		//Create a list of the Warm Lead records to be updated
		List<Warm_Lead__c> warmLeads = new List<Warm_Lead__c>();
		
		//Loop through the requests
		for(Restriction_Clearance_Request__c rCR : rCRequests) {
			
			//Check if Warm_Lead__c is not null and add in set
			if(rCR.Warm_Lead__c != null)
				warmLeadsIds.add(rCR.Warm_Lead__c);
		}
		
		//Query all the Warm leads which are not having status = 'Pending Restriction Clearance'
		for(Warm_Lead__c warmLead : [Select Status__c from Warm_Lead__c where Status__c !=: Constants.STATUS_WARM_LEAD_PENDING_RESTRICTION_CLEARANCE
										AND ID IN: warmLeadsIds]) {
			
			//Set the status and add recotrds in the list to be updated
			warmLead.Status__c = Constants.STATUS_WARM_LEAD_PENDING_RESTRICTION_CLEARANCE;
			warmLeads.add(warmLead);
		}
		
		//check for the size and update the records
		if(warmLeads.size() > 0)
			update warmLeads;
	}
}