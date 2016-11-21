/**
 *  Description     :  Helper class for ContractTrigger trigger.
 *
 *  Created By      :  Subhash Garhwal
 *
 *  Created Date    :  07/01/2016
 *
 *  Revision Logs   :   V_1.0 - Created - Subhash Garhwal - CR-20160414-9762 
 *
 **/
public without sharing class ContractTriggerHelper {
	
	/**
	 *	@description	:	This method is used to create Contract Integrated Account according if parent opportunity is contracted and integrated
	 *						account exists under it
	 *
	 *						Details form WORK ORDER (Process): 
	 *						If Integrated Accounts exist on the parent Opportunity, create a Contract Integrated Account for each combination of Integrated Account and Contract record
	 *						Record Type = 'Standard Contract'
	 *						Integrated Account = <specific Integrated Account record>
	 *						LOA Contract = <specific standard Contract record>
	 *						Account = <Integrated Account.IntegratedAccount Id>
	 *
	 *	@args			:	List<Contract>, Map<Id, Contract>
	 *
	 *	@return			:	void
	 *
	 *	@revision Log	:	V_1.0 - 07/01/2016 - Created - Subhash Garhwal - CR-20160414-9762
	 *
	 **/
	public static void syncContractIntegratedAccounts(List<Contract> contracts, Map<Id, Contract> mapOldContracts) {
		
		//Map to hold the Contract Ids with related Opportunity (Contract LOA type) Id
		Map<Id, Set<Id>> mapOppIdWithContractIds = new Map<Id, Set<Id>>();
		 
		//Check for contract list size
		if(contracts != null && contracts.size() > 0) {
			
			//Query through the contract record
			for(Contract cont : [Select Id, SBQQ__Opportunity__c From Contract Where Id IN : contracts AND SBQQ__Opportunity__r.RecordType.DeveloperName =: CPQConstants.OPPORTUNITY_RECORD_TYPE_DEVELOPERNAME_CONTRACT_LOA
										AND SBQQ__Opportunity__r.SBQQ__Contracted__c = true]) {
				
				//Add Opportunity Id in map
				if(!mapOppIdWithContractIds.containsKey(cont.SBQQ__Opportunity__c))
					mapOppIdWithContractIds.put(cont.SBQQ__Opportunity__c, new Set<Id>());
				
				//Add Contract Id in set
				mapOppIdWithContractIds.get(cont.SBQQ__Opportunity__c).add(cont.Id);
				
			}
			
			//Check for map size
			if(mapOppIdWithContractIds.size() > 0) {
				
				//List ot insert Contract Integrated Accounts
				List<Contract_Integrated_Accounts__c> contractIntegratedAccounts = new List<Contract_Integrated_Accounts__c>();
				
				//Get Standard Contract Record Type
				List<RecordType> recordTypes = [Select Id From RecordType Where SobjectType = 'Contract_Integrated_Accounts__c' AND DeveloperName =: CPQConstants.CONTRACT_INT_ACC_RT_DN_STANDARD_CONTRACT LIMIT 1];
				
				//Query through the Integrated accounts
				for(Integrated_Account__c iA : [Select Id, Opportunity__c, Integrated_Account__c From Integrated_Account__c Where Opportunity__c IN : mapOppIdWithContractIds.keySet()]) {
					
					//Check Opprtunity Id in map
					if(mapOppIdWithContractIds.containsKey(iA.Opportunity__c)) {
						
						//Loop over the Contract Ids
						for(Id contId : mapOppIdWithContractIds.get(iA.Opportunity__c)) {
							
							//Instance of Contract_Integrated_Accounts__c
							Contract_Integrated_Accounts__c cIA = new Contract_Integrated_Accounts__c();
							
							//Set field values
							cIA.RecordTypeId = recordTypes.size() > 0 ? recordTypes[0].Id : cIA.RecordTypeId;
							cIA.LOA_Contract__c = contId;
							cIA.Integrated_Account__c = iA.Id;
							cIA.Account__c = iA.Integrated_Account__c;
							
							//Add record in lisr
							contractIntegratedAccounts.add(cIA);
						}
					}	
				}
				
				//Check for contractIntegratedAccounts size
				if(contractIntegratedAccounts.size() > 0)
					insert contractIntegratedAccounts;
			}	
		
		} else if(mapOldContracts != null) {
			
			//Delete Contract Integrated accounts
			delete [Select Id From Contract_Integrated_Accounts__c Where LOA_Contract__c IN : mapOldContracts.keySet()];	
		}
	}
}