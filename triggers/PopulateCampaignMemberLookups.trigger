trigger PopulateCampaignMemberLookups on CampaignMember (before insert) {
/*


	Set<String> MName = new Set<String>();
	Set<String> ProgAcro = new Set<String>();
	for (CampaignMember cm :trigger.new) {
		MName.add(cm.MA_Username__c);
		MName.add(cm.Marketer_Username__c);
		ProgAcro.add(cm.Program_Acronym__c);
	}

	Map<String, Id> MNameMap = new Map<String, Id>(); 
	for (User u : [select Username, Id from User where Username in :MName and isActive = true]) {
		
		//commented by Bhavi
		//MNameMap.put(u.Username, u.Id);
		
		//Bhavi - Added code to put the username in small letter in map
		MNameMap.put(u.Username.toLowerCase(), u.Id);
	}

	Map<String, Id> ProgAcroMap = new Map<String, Id>(); 
	for (Program__c p : [select Program_Acronym__c, Id from Program__c where Program_Acronym__c in :ProgAcro and Status__c = 'Active']) {
		ProgAcroMap.put(p.Program_Acronym__c, p.Id);
	}

	for (CampaignMember cm :trigger.new) {

		
		//Bhavi - Added code to avoid the case sensitivity
		if (cm.MA_Username__c != null && MNameMap.containsKey(cm.MA_Username__c.toLowerCase())) {
			cm.MA_Assignment__c = MNameMap.get(cm.MA_Username__c.toLowerCase());
		}
		if (cm.Marketer_Username__c != null && MNameMap.containsKey(cm.Marketer_Username__c.toLowerCase())) {
			cm.Marketer_Assignment__c = MNameMap.get(cm.Marketer_Username__c.toLowerCase());
		}
		//Upto here
		
		if (ProgAcroMap.containsKey (cm.Program_Acronym__c)) {
			cm.Primary_Program__c = ProgAcroMap.get(cm.Program_Acronym__c);
		}
	}
*/
}