public with sharing class ChangeRequestUtilities {
	
	// determine the current status for newly inserted IS System records
	public static void UpdateCurrentStatus(List<IS_System__c> triggerNew) {
		Set<Id> parentIds = new Set<Id>();
		Set<Id> triggerNewIds = new Set<Id>();
		for (IS_System__c ISS : triggerNew) {
			parentIds.add(ISS.Primary_System__c);
			triggerNewIds.add(ISS.Id);
		}
		
		// get a map of all parent systems
		Map<Id, IS_System__c> parentSystemMap = new Map<Id, IS_System__c>([SELECT Id, Current_Status__c FROM IS_System__c WHERE Id IN :parentIds]);
		Map<Id, IS_System__c> triggerNewMap = new Map<Id, IS_System__c>([SELECT Id, Current_Status__c, (SELECT Id, Status__c, Functionality__c FROM Change_Requests__r) FROM IS_System__c WHERE Id IN :triggerNewIds]);
		
		for (IS_System__c ISS : triggerNew) {
			String status = 'Fully Functional';
			IS_System__c parentSystem = parentSystemMap.get(ISS.Primary_System__c);
			if (parentSystem != null && parentSystem.Current_Status__c == 'All Out') {
				status = 'All Out';
			}
			else {
				IS_System__c ISSystem = triggerNewMap.get(ISS.Id);
				List<SFDC_Change_Request__c> relatedCRs;
				if (ISSystem != null && ISSystem.Change_Requests__r != null) {
					relatedCRs = ISSystem.Change_Requests__r;
				}
				status = FindSystemStatus(relatedCRs);
			}
			system.debug('@@' + status);
			ISS.Current_Status__c = status;
		}
	}
	
	// class is used by ChangeRequest.trigger to ensure that the correct IS System Status is on the associated IS System.
	public static void UpdateCurrentStatus(List<SFDC_Change_Request__c> triggerNew) {
		Set<Id> ISSystemIds = new Set<Id>();
		Set<Id> triggerNewIds = new Set<Id>();
		// Map<IS System Id, List<Change Requests>>
		Map<Id, List<SFDC_Change_Request__c>> ISSystemToCRMap = new Map<Id, List<SFDC_Change_Request__c>>();
		
		// get a list of all IS Systems involved
		for (SFDC_Change_Request__c CR : triggerNew) {
			if (CR.IS_System__c != null) {
				triggerNewIds.add(CR.Id);
				ISSystemIds.add(CR.IS_System__c);
				// add to our ISSystem -> List<Change Request> map
				List<SFDC_Change_Request__c> tempCRList = new List<SFDC_Change_Request__c>();
				tempCRList = ISSystemToCRMap.get(CR.IS_System__c);
				if (tempCRList == null) {
					tempCRList = new List<SFDC_Change_Request__c>();
					tempCRList.add(CR);
				} else {
					tempCRList.add(CR);
				}
				ISSystemToCRMap.put(CR.IS_System__c, tempCRList);
			}
		}
		
		// if none of these updates are a "system outage" record type, don't do anything
		if (ISSystemIds.size() == 0) return;
		
		// grab all associated CR's (except the ones that triggered this method)
		List<SFDC_Change_Request__c> AllCRs = [SELECT Name, Id, Status__c, IS_System__c, Functionality__c, Users_Affected__c FROM SFDC_Change_Request__c WHERE Id NOT IN :triggerNewIds AND IS_System__c IN :ISSystemIds];
		
		// add these CR's to their appropriate place in the map
		for (SFDC_Change_Request__c CR : AllCRs) {
			// add to our ISSystem -> List<Change Request> map
			List<SFDC_Change_Request__c> tempCRList = new List<SFDC_Change_Request__c>();
			tempCRList = ISSystemToCRMap.get(CR.IS_System__c);
			if (tempCRList == null) {
				tempCRList = new List<SFDC_Change_Request__c>();
				tempCRList.add(CR);
			} else {
				tempCRList.add(CR);
			}
			ISSystemToCRMap.put(CR.IS_System__c, tempCRList);
		}
		
		// list of ISSystem records to update
		List<IS_System__c> ISSystemUpdates = new List<IS_System__c>();
		// get a map of all CR's
		Map<Id, IS_System__c> ISSystemMap = new Map<Id, IS_System__c>([SELECT Id, Primary_System__r.Current_Status__c, Current_Status__c FROM IS_System__c WHERE Id IN :ISSystemToCRMap.keySet()]);
		// now that we have all the system info, see if any IS System records need to be updated
		for (IS_System__c ISS : ISSystemMap.values()) {
			
			List<SFDC_Change_Request__c> CRList = ISSystemToCRMap.get(ISS.Id);
			
			// if parent system is out, the child must be marked as out also
			if (ISS.Primary_System__r.Current_Status__c == 'All Out') {
				ISS.Current_Status__c = 'All Out';
				ISSystemUpdates.add(ISS);
				continue;
			}
			
			// get the temporary system status based on the list of related Change Requests
			String tempStatus = FindSystemStatus(CRList);
			
			system.debug('@@tempStatus:' + tempStatus);
			
			// add the IS System record to the update list of the tempstatus is not equal
			if (ISS.Current_Status__c != tempStatus) {
				ISS.Current_Status__c = tempStatus;
				ISSystemUpdates.add(ISS);
			}
			system.debug('@@ISS SYSTEM UPDATES:' + ISSystemUpdates);
				
		}
		
		if (ISSystemUpdates.size() > 0) {
			update ISSystemUpdates;
			ChangeRequestUtilities.UpdateDependentStatus(ISSystemUpdates);
		}
		
	}
	
	// return the system status based on a list of related CR's
	public static String FindSystemStatus(List<SFDC_Change_Request__c> CRList) {
		String tempStatus = 'Fully Operational';
		if (CRList == null) {
			return tempStatus;
		}
		
		for (SFDC_Change_Request__c CR : CRList) {
			if (CR.Status__c.toLowerCase().contains('open')) {
				if (CR.Functionality__c.toLowerCase().contains('all')) {
					tempStatus = 'All Out';
					break;
				}
				else if (CR.Functionality__c.toLowerCase().contains('critical')) {
					tempStatus = 'Critical Out';
					break;
				}
				else if (CR.Functionality__c.toLowerCase().contains('partial') && tempStatus != 'Partial Out') {
					tempStatus = 'Partial Out';
				}
			}
			if (CR.Status__c.toLowerCase().contains('reported')) {
				tempStatus = 'Reported - pending verification';
			}
		}
		
		return tempStatus;
	}
	
	
	// make sure all users that add Request Comments (ie: activities with time) on a CR that they are added to the list of "IS Team Involved"
	public static void UpdateISTeamInvolved(List<SFDC_Request_Comment__c> triggerNew) {
		
		// get all the change requests associated with the list of Request Comments passed in
		
		Map<Id, SFDC_Change_Request__c> changeRequestMap = new Map<Id, SFDC_Change_Request__c>([SELECT Id, IS_QA_Lead2__c, IS_QA_Lead2__r.Name, OwnerId, IS_Team_Involved__c, CreatedById
														FROM SFDC_Change_Request__c
														WHERE Id IN (SELECT SFDC_Change_Request__c FROM SFDC_Request_Comment__c WHERE Id IN :triggerNew)]);
		
		// retreive all users associated with the CR Comments
		
		Map<Id, User> userMap = new Map<Id, User>([SELECT Id, Name FROM User WHERE Id IN (SELECT User__c FROM SFDC_Request_Comment__c WHERE Id IN :triggerNew)]);
		
		// list to hold the change requests that will need to be updated
		
		List<SFDC_Change_Request__c> changeRequestsToUpdate = new List<SFDC_Change_Request__c>();
		
		// go through each CR Comment and ensure that the user is either the owner or in the IS Team Involved field
		
		for (SFDC_Request_Comment__c activity : triggerNew) {
			SFDC_Change_Request__c aChangeRequest = changeRequestMap.get(activity.SFDC_Change_Request__c);
			User aUser = userMap.get(activity.User__c);
			if (activity.User__c != null && aChangeRequest.OwnerId != aUser.Id && aChangeRequest.IS_QA_Lead2__r.Name != aUser.Name) {
				if (aChangeRequest.IS_Team_Involved__c != null && !aChangeRequest.IS_Team_Involved__c.contains(aUser.Name))
					aChangeRequest.IS_Team_Involved__c += ', ' + aUser.Name;
				else if (aChangeRequest.IS_Team_Involved__c == null)
					aChangeRequest.IS_Team_Involved__c = aUser.Name;
				
				changeRequestsToUpdate.add(aChangeRequest);
			}
		}
		
		// Update any applicable CRs
		
		if (!changeRequestsToUpdate.isEmpty())
			update changeRequestsToUpdate;
		
	}
	
	// called from the ISSystems trigger to update any dependent IS Systems that may be effected by system outages
	public static void UpdateDependentStatus(List<IS_System__c> systems) {
		Map<Id, String> sysIdToStatusMap = new Map<Id, String>();
		// get a map of all system ids with their corresponding status
		for (IS_System__c sys : systems) {
			sysIdToStatusMap.put(sys.Id, sys.Current_Status__c);
		}
		
		// get all systems with their associated CR's to determine the proper Current Status
		Map<Id, IS_System__c> dependentSystemMap = new Map<Id, IS_System__c>([SELECT Name, Primary_System__r.Current_Status__c, Id, Current_Status__c,
		(SELECT Id, Status__c, Functionality__c FROM Change_Requests__r),
		(SELECT Id, Primary_System__r.Current_Status__c, Current_Status__c, Primary_System__c FROM IS_Systems__r)
		FROM IS_System__c WHERE Primary_System__c IN :sysIdToStatusMap.keySet()]);
		
		if (dependentSystemMap.IsEmpty()) {
			dependentSystemMap = new Map<Id, IS_System__c>([SELECT Name, Primary_System__r.Current_Status__c, Id, Current_Status__c,
		(SELECT Id, Status__c, Functionality__c FROM Change_Requests__r)
		FROM IS_System__c WHERE Id IN :sysIdToStatusMap.keySet()]);
		}
		
		//list<IS_System__c> ISSystemList = (dependentSystemMap.IsEmpty())? systems : dependentSystemMap.values();
		list<IS_System__c> ISSystemList = dependentSystemMap.values();
		
		// list of IS System records to update
		List<IS_System__c> ISSUpdates = new List<IS_System__c>();
		Set<Id> GrandChildSystemIds = new Set<Id>();
		
		for (IS_System__c ISS : ISSystemList) {
			
			list<SFDC_Change_Request__c> CRList = ISS.Change_Requests__r;
			// prep the list to update grand children
			if (ISS.IS_Systems__r != null) {
				//GrandChildSystems.addAll(ISS.IS_Systems__r);
				for (IS_System__c GrandChildSys : ISS.IS_Systems__r) {
					GrandChildSystemIds.add(GrandChildSys.Id);
				}
			}
				
				
			// if parent system is out, the child must be marked as out also
			if (ISS.Primary_System__r.Current_Status__c == 'All Out') {
				ISS.Current_Status__c = 'All Out';
				ISSUpdates.add(ISS);
				continue;
			}
			
			// get the temporary system status based on the list of related Change Requests
			String tempStatus = FindSystemStatus(CRList);
			// if the status has changes, update the status and add this record to our list of IS Systems to update
			if (tempStatus != null && tempStatus != ISS.Current_Status__c) {
				ISS.Current_Status__c = tempStatus;
				ISSUpdates.add(ISS);
			}
		}
		List<IS_System__c> GrandChildSystems = new List<IS_System__c>();
		if (GrandChildSystemIds.size() > 0) {
			GrandChildSystems = [SELECT Name, Primary_System__r.Current_Status__c, Id, Current_Status__c,
												(SELECT Id, Status__c, Functionality__c FROM Change_Requests__r),
												(SELECT Id, Primary_System__r.Current_Status__c, Current_Status__c, Primary_System__c FROM IS_Systems__r)
												FROM IS_System__c WHERE Id IN :GrandChildSystemIds];
		}
		
		if (ISSUpdates.size() > 0) {
			update ISSUpdates;
			if (GrandChildSystems.size() > 0)
				UpdateGrandChildStatus(GrandChildSystems);
		}
	}
	
	// called from the ISSystems trigger to update any dependent IS Systems that may be effected by system outages
	public static void UpdateGrandChildStatus(List<IS_System__c> systems) {
		Map<Id, String> sysIdToStatusMap = new Map<Id, String>();
		// get a map of all system ids with their corresponding status
		for (IS_System__c sys : systems) {
			sysIdToStatusMap.put(sys.Id, sys.Current_Status__c);
		}
		
		// get all systems with their associated CR's to determine the proper Current Status
		Map<Id, IS_System__c> dependentSystemMap = new Map<Id, IS_System__c>([SELECT Name, Primary_System__r.Current_Status__c, Id, Current_Status__c,
		(SELECT Id, Status__c, Functionality__c FROM Change_Requests__r),
		(SELECT Id, Primary_System__r.Current_Status__c, Current_Status__c, Primary_System__c FROM IS_Systems__r)
		FROM IS_System__c WHERE Primary_System__c IN :sysIdToStatusMap.keySet()]);
		
		list<IS_System__c> ISSystemList = (dependentSystemMap.IsEmpty())? systems : dependentSystemMap.values();
		
		// list of IS System records to update
		List<IS_System__c> ISSUpdates = new List<IS_System__c>();
		List<IS_System__c> GrandChildSystems = new List<IS_System__c>();
		
		for (IS_System__c ISS : ISSystemList) {
			system.debug('@@ISS CRs' + ISS.Change_Requests__r);
			list<SFDC_Change_Request__c> CRList = ISS.Change_Requests__r;
			// prep the list to update grand children
			if (ISS.IS_Systems__r != null)
				GrandChildSystems.addAll(ISS.IS_Systems__r);
			
			// if parent system is out, the child must be marked as out also
			if (ISS.Primary_System__r.Current_Status__c != 'All Out') {
				ISS.Current_Status__c = 'All Out';
				ISSUpdates.add(ISS);
				continue;
			}
			
			// get the temporary system status based on the list of related Change Requests
			String tempStatus = FindSystemStatus(CRList);
			
			// if the status has changes, update the status and add this record to our list of IS Systems to update
			if (tempStatus != null && tempStatus != ISS.Current_Status__c) {
				ISS.Current_Status__c = tempStatus;
				ISSUpdates.add(ISS);
			}
		}
		
		if (ISSUpdates.size() > 0) {
			update ISSUpdates;
			if (GrandChildSystems.size() > 0)
				UpdateDependentStatus(GrandChildSystems);
		}
	}
	
	public static Set<Id> QueryISSystems(Set<Id> ISSystemIds) {
		Set<Id> retIds = new Set<Id>();
		// query for all is systems involved
		List<IS_System__c> ISSystemList = [SELECT Name, Id, Current_Status__c, Primary_System__c FROM IS_System__c WHERE Id IN :ISSystemIds];
		Set<Id> PrimarySystemIds = new Set<Id>();
		// create a set of ids for "Primary_System" records
		for (IS_System__c ISS : ISSystemList) {
			retIds.add(ISS.Id);
			if (ISS.Primary_System__c != null) {
				retIds.add(ISS.Primary_System__c);
			}
		}
		
		return retIds;
		
	}
	
}