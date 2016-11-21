/*
    Purpose         :   This class is helper class for trigger on Aggrement object.
                
    Create By       :   Simplyforce Technology
    
    Created Date    :   12/20/2012
    
    Current Version :   v1.0
         
    Revision Log    :   V_1.0 Created
    					V_1.1 - New method validateAgreementStatusOnOSR added - Bhavi Sharma - 10/26/2013 - CR-20130109-2089
*/
public with sharing class AgreementTriggerHelper {
	
	//This method is to update the LOA Sent field on opportunity whenever Agreement is set to 'Out to Signature'
	public static void updateLOASentOnOpportunity(Map<Id, echosign_dev1__SIGN_Agreement__c> mapNewAggrements, 
														Map<Id, echosign_dev1__SIGN_Agreement__c > mapOldAggrements) {
	
		//Create a set to hold the opportunity ids which needs to be updated
		Set<Id> opportunityIds = new Set<Id>();
		
		//Loop through the new records
		for(echosign_dev1__SIGN_Agreement__c agreement : mapNewAggrements.values()) {
			
			//Check if Opportunity needs to be updated
			if(agreement.echosign_dev1__Status__c == Constants.STATUS_AGREEMENT_OUT_FOR_SIGNATURE
				&& (mapOldAggrements == null || agreement.echosign_dev1__Status__c != mapOldAggrements.get(agreement.Id).echosign_dev1__Status__c)) {
				
				//Add opportunity Id in set
				opportunityIds.add(agreement.echosign_dev1__Opportunity__c);
			}
		}
		
		//Check if there are opprotunities to process
		if(opportunityIds.size() > 0) {
			
			//Create a list of Opportunities to be updated
			List<Opportunity> opportunities = new List<Opportunity>();
			
			//fetch all the opportunity records
			for(Opportunity opportunity : [Select Id, LOA_Sent_Date__c from Opportunity where Id IN: opportunityIds]) {
				
				//Update the filed only if this is originally null
				if(opportunity.LOA_Sent_Date__c == null) {
					
					//Set today's date
					opportunity.LOA_Sent_Date__c = Date.today();
					
					//Add record in the list to be updated
					opportunities.add(opportunity);
				}
			}
			
			//Check if there are records to update
			if(opportunities.size() > 0)
				update opportunities;
		}										
	}
	
	/**
	 *	@description	:	This method is to update Agreement Send, Agreement Received & OSR Status when Agreement Status is 'Out for Signature' or 'Signed'.
	 *						New method added - Bhavi Sharma - 10/26/2013 - CR-20130109-2089
	 *
	 *	@param			:	Trigger.new, Trigger.oldMap
	 *
	 *	@retrun			:	void
	 **/
	public static void validateAgreementStatusOnOSR(List<echosign_dev1__SIGN_Agreement__c > newAgreements , Map<Id, echosign_dev1__SIGN_Agreement__c > mapOldAggrements) {
		
		//Create a list of OSR records to be updated
		List<OSR__c> oSRs = new List<OSR__c>();
		
		//Loop through the new records
		for(echosign_dev1__SIGN_Agreement__c agreement : newAgreements) {
				
			//Check if Agreement Status is on OSR record and Status has been changed
			if(agreement.OSR__c != null && 
				(mapOldAggrements == null || agreement.echosign_dev1__Status__c != mapOldAggrements.get(agreement.Id).echosign_dev1__Status__c)) {
			
				//Update Agreement Sent/Received date` and Status
				if(agreement.echosign_dev1__Status__c == Constants.STATUS_AGREEMENT_OUT_FOR_SIGNATURE) {
					
					//Update OSR status to Apgreement Sent
					oSRs.add(new OSR__c(Id = agreement.OSR__c, Agreement_Sent__c = DateTime.now(), Status__c = Constants.STATUS_OSR_PENDING_APPLICATION));
				} else if(agreement.echosign_dev1__Status__c == Constants.STATUS_AGREEMENT_SIGNED) {
					
					//Update OSR status to Agreement Signed
					oSRs.add(new OSR__c(Id = agreement.OSR__c, Agreement_Received__c = DateTime.now(), Status__c = Constants.STATUS_OSR_PENDING_FINANCE));
				}
			}
		}
		
		//Update OSR records
		if(oSRs.size() > 0)
			update oSRs;
	}
}