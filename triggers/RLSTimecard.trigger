/*
  Purpose:
        This trigger manages sharing of Timecards with the Resource and Project Manager
        
  Initiative: IconATG FinancialForce PSA Implementation 
  Author:     William Rich
  Company:    IconATG
  Contact:    william.rich@iconatg.com
  Created:    7/24/2015
*/

trigger RLSTimecard on pse__Timecard_Header__c (before insert, after insert) {
    Set<Id> resourceIds = new Set<Id>();
    Set<Id> projectIds = new Set<Id>();
    for (pse__Timecard_Header__c timecard : Trigger.new) {
        if (timecard.OwnerId != timecard.pse__Resource__c) {
            resourceIds.add(timecard.pse__Resource__c);
        }

        if (timecard.pse__Project__c != null) {
            projectIds.add(timecard.pse__Project__c);
        }
    }
    
    if (Trigger.isBefore) {
        if (resourceIds.size() > 0) {
            Map<Id, Contact> activeResources = new Map<Id, Contact>([
                select Id, pse__Salesforce_User__c
                from Contact 
                where
                    Id in :resourceIds and
                    pse__Salesforce_User__c != null and
                    pse__Salesforce_User__r.IsActive = true
            ]);
            
            for (pse__Timecard_Header__c timecard : Trigger.new) {
                if (activeResources.containsKey(timecard.pse__Resource__c)) {
                    Contact theResource = activeResources.get(timecard.pse__Resource__c);
                    timecard.OwnerId = theResource.pse__Salesforce_User__c;
                }
            }
        }
    }
    else {
        if (projectIds.size() > 0) {
            Map<Id, pse__Proj__c> projects = new Map<Id, pse__Proj__c>([
                select
                    Id,
                    pse__Project_Manager__c,
                    pse__Project_Manager__r.pse__Salesforce_User__c,
                    pse__Project_Manager__r.pse__Salesforce_User__r.IsActive,
                    Group_Manager__c
                from pse__Proj__c
                where Id in :projectIds
            ]);

            List<pse__Timecard_Header__Share> tShares = new List<pse__Timecard_Header__Share>();
            for (pse__Timecard_Header__c timecard : Trigger.new) {
                if (projects.containsKey(timecard.pse__Project__c)) {
                    pse__Proj__c project = projects.get(timecard.pse__Project__c);

                    if (project.pse__Project_Manager__c != null && 
                        project.pse__Project_Manager__r.pse__Salesforce_User__c != null &&
                        project.pse__Project_Manager__r.pse__Salesforce_User__r.IsActive) {
                        
                        pse__Timecard_Header__Share tSharePM = new pse__Timecard_Header__Share(
                            ParentId = timecard.Id,
                            UserOrGroupId = project.pse__Project_Manager__r.pse__Salesforce_User__c,
                            RowCause = Schema.pse__Timecard_Header__Share.RowCause.pse__PSE_PM_Share__c,
                            AccessLevel = 'Edit'
                        );
                        tShares.add(tSharePM);
                    }

                    if (project.Group_Manager__c != null) {
                        pse__Timecard_Header__Share tShareGM = new pse__Timecard_Header__Share(
                            ParentId = timecard.Id,
                            UserOrGroupId = project.Group_Manager__c,
                            RowCause = Schema.pse__Timecard_Header__Share.RowCause.pse__PSE_Member_Share__c,
                            AccessLevel = 'Edit'
                        );
                        tShares.add(tShareGM);
                    }
                }
            }

            if (!tShares.isEmpty()) insert tShares;
        }
    }
}