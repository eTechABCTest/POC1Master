/*
  Purpose:
        This trigger manages sharing of the project with the resource assigned to the project

  Initiative: IconATG FinancialForce PSA Implementation 
  Author:     William Rich
  Company:    IconATG
  Contact:    william.rich@iconatg.com
  Created:    7/24/2015
*/

trigger RLSAssignment on pse__Assignment__c (before insert) {
    Set<Id> resourceIds = new Set<Id>();
    Set<Id> projectIds = new Set<Id>();
    for (pse__Assignment__c assignment : Trigger.new) {
        if (assignment.pse__Resource__c != null && assignment.pse__Project__c != null) {
            resourceIds.add(assignment.pse__Resource__c);
            projectIds.add(assignment.pse__Project__c);
        }
    }

    if (!resourceIds.isEmpty()) {
        List<Contact> resources = [
            select Id, pse__Salesforce_User__c
            from Contact 
            where
                Id in :resourceIds and
                pse__Salesforce_User__c != null and
                pse__Salesforce_User__r.IsActive = true
        ];

        Map<Id, Id> sfUsersByResource = new Map<Id, Id>();
        for (Contact resource : resources) {
            sfUsersByResource.put(resource.Id, resource.pse__Salesforce_User__c);
        }

        List<pse__Proj__Share> existingProjectShares = [
            select
                ParentId,
                UserOrGroupId
            from pse__Proj__Share
            where
                ParentId in :projectIds and
                UserOrGroupId in :sfUsersByResource.values()
        ];

        Set<String> resourcesAndProjects = new Set<String>();
        for (pse__Proj__Share projectShare : existingProjectShares) {
            String resourceAndProject = String.valueOf(projectShare.UserOrGroupId) + String.valueOf(projectShare.ParentId);
            resourcesAndProjects.add(resourceAndProject);
        }

        List<pse__Proj__Share> newProjectShares = new List<pse__Proj__Share>();
        for (pse__Assignment__c assignment : Trigger.new) {
            if (assignment.pse__Resource__c != null && assignment.pse__Project__c != null) {
                if (sfUsersByResource.containsKey(assignment.pse__Resource__c)) {
                    String resourceAndProject = String.valueOf(assignment.pse__Resource__c) + String.valueOf(assignment.pse__Project__c);
                    if (!resourcesAndProjects.contains(resourceAndProject)) {
                        newProjectShares.add(new pse__Proj__Share(
                            ParentId = assignment.pse__Project__c,
                            UserOrGroupId = sfUsersByResource.get(assignment.pse__Resource__c),
                            RowCause = Schema.pse__Proj__Share.RowCause.pse__PSE_Member_Share__c,
                            AccessLevel = 'Edit'
                        ));
                    }
                }
            }
        }

        if (!newProjectShares.isEmpty()) insert newProjectShares;
    }
}