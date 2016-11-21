/**
    Purpose:    		Helper class for the Campaign Member trigger.
                
    Create By:  		Victor Hanson
    
    Created Date:   	06/24/2014
    
    Current Version:    v1.0
    
    Revision Log:       
 **/
public class CampaignMemberTriggerHelper{
	
    /*	Developer:	Drew Freeman
        Date:		8/27/11
        Purpose:	To populate MA Assignment, Marketer Assignment, and Primary Program lookups on Campaign Member
        Custom field lookups cannot be imported through the Campaign Member import wizard
        
        Revision Logs : V1.1 : 	Simplyforce-Bhavi[12/13/2011] - Added code to avoid the case sensitivity while comparing the usernames with
        MA Username and Marketer Username - CR-20111012-161
    */
    public static void PopulateCampaignMemberLookups(list<CampaignMember> campaignMemberList) {
        
        Set<String> MName = new Set<String>();
        Set<String> ProgAcro = new Set<String>();
        for (CampaignMember cm : campaignMemberList) {
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
        
        for (CampaignMember cm : campaignMemberList) {
            
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
    }
    
    /**
     * @description:	if the campaign member has the Undeliverable flag checked, add +1 to the related contact's
     * 					# Undeliverable Mailings field.
     * 
     * @params:			trigger.new, trigger.oldMap
     **/
    public static void updateUndeliverableMailings(list<CampaignMember> campaignMemberList, map<Id, CampaignMember> oldCampaignMemberMap) {
        
        set<Id> contactIds = new set<Id>();
        list<Contact> contactsToUpdate = new list<Contact>();
        
        for (CampaignMember cm : campaignMemberList) contactIds.add(cm.ContactId);
        map<Id, Contact> contactMap = new map<Id, Contact>([SELECT Id, Num_Undeliverable_Mailings__c FROM Contact WHERE Id IN :contactIds]);
        
        for (CampaignMember cm : campaignMemberList) {
            
            CampaignMember oldCM;
            if (oldCampaignMemberMap != null) oldCM = oldCampaignMemberMap.get(cm.Id);
            
            if ((oldCM == null && cm.Undeliverable__c) || (oldCM != null && oldCM.Undeliverable__c != cm.Undeliverable__c)) 
            {
                Contact c = contactMap.get(cm.ContactId);
                
                if (c.Num_Undeliverable_Mailings__c == null) c.Num_Undeliverable_Mailings__c = 0;
                
                if (cm.Undeliverable__c) c.Num_Undeliverable_Mailings__c++;
                else if (c.Num_Undeliverable_Mailings__c > 0) c.Num_Undeliverable_Mailings__c--;
                
                contactsToUpdate.add(c);
            }
        }
        
        if (contactsToUpdate.size() > 0) {
            util.BypassAllTriggers = true;
            update contactsToUpdate;
            util.BypassAllTriggers = false;
        }
    }
}