/*
  Purpose:
        This trigger sets the Approver on a timecard
        
  Initiative: IconATG FinancialForce PSA Implementation 
  Author:     William Rich
  Company:    IconATG
  Contact:    william.rich@iconatg.com
  Created:    9/16/2013
*/

trigger SetTimecardApprover on pse__Timecard_Header__c (before insert, before update) {
    Set<Id> projectIds = new Set<Id>();
    Set<Id> resourceIds = new Set<Id>();
    for (pse__Timecard_Header__c timecard : Trigger.new) {
        if (timecard.pse__Project__c != null) {
            projectIds.add(timecard.pse__Project__c);
        }
        
        if (timecard.pse__Resource__c != null) {
            resourceIds.add(timecard.pse__Resource__c);
        }
    }
    
    Map<Id, pse__Proj__c> projects = null;
    if (!projectIds.isEmpty()) {
        projects = new Map<Id, pse__Proj__c>([
            select
                Id,
                pse__Project_Manager__c,
                pse__Project_Manager__r.pse__Salesforce_User__c,
                Use_Reporting_Manager_as_Approver__c
            from pse__Proj__c
            where Id in :projectIds
        ]);
    }
    
    Map<Id, Contact> resources = null;
    if (!resourceIds.isEmpty()) {
        resources = new Map<Id, Contact>([
            select
                Id,
                pse__Salesforce_User__c,
                pse__Salesforce_User__r.ManagerId
            from Contact
            where Id in :resourceIds
        ]);
    }
    
    for (pse__Timecard_Header__c timecard : Trigger.new) {
    	Id approver = null;
        if (projects != null && projects.containsKey(timecard.pse__Project__c)) {
            pse__Proj__c project = projects.get(timecard.pse__Project__c);
            if (project.Use_Reporting_Manager_as_Approver__c) {
                if (resources != null && resources.containsKey(timecard.pse__Resource__c)) {
                	Contact resource = resources.get(timecard.pse__Resource__c);
                	if (resource.pse__Salesforce_User__c != null) {
                        approver = resources.get(timecard.pse__Resource__c).pse__Salesforce_User__r.ManagerId;
                	}
                }
                else {
                	if (project.pse__Project_Manager__c != null) {
                        approver = project.pse__Project_Manager__r.pse__Salesforce_User__c;
                	}
                }
            }
            else {
                if (project.pse__Project_Manager__c != null) {
                    approver = project.pse__Project_Manager__r.pse__Salesforce_User__c;
                }
            }
        }
        
        if (approver != null) {
            timecard.pse__Approver__c = approver;
        }
    }
}