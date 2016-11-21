/*
  Purpose:
        When the PM on a project is changed, this trigger shares timecards,
        expense reports and expenses with the new PM.
        
  Initiative: IconATG FinancialForce PSA Implementation 
  Author:     William Rich
  Company:    IconATG
  Contact:    william.rich@iconatg.com
  Created:    7/24/2015
*/

trigger RLSProject on pse__Proj__c (after insert, before update) {
    if (Trigger.isInsert) {
        Map<Id, Id> newPMsByProject = new Map<Id, Id>();
        Map<Id, Id> newGMsByProject = new Map<Id, Id>();
        for (pse__Proj__c project : Trigger.new) {
            if (project.pse__Project_Manager__c != null) {
                newPMsByProject.put(project.Id, project.pse__Project_Manager__c);
            }

            if (project.Group_Manager__c != null) {
                newGMsByProject.put(project.Id, project.Group_Manager__c);
            }
        }

        if (newPMsByProject.size() > 0 || newGMsByProject.size() > 0) {
            Map<Id, Contact> activePMs = new Map<Id, Contact>([
                select Id, pse__Salesforce_User__c
                from Contact 
                where
                    Id in :newPMsByProject.values() and
                    pse__Salesforce_User__c != null and
                    pse__Salesforce_User__r.IsActive = true
            ]);

            List<pse__Proj__Share> projectShares = new List<pse__Proj__Share>();
            for (Id projectId : newPMsByProject.keySet()) {
                if (activePMs.containsKey(newPMsByProject.get(projectId))) {
                    Id pmSFUser = activePMs.get(newPMsByProject.get(projectId)).pse__Salesforce_User__c;
                    projectShares.add(new pse__Proj__Share(
                        ParentId = projectId,
                        UserOrGroupId = pmSFUser,
                        RowCause = Schema.pse__Proj__Share.RowCause.pse__PSE_PM_Share__c,
                        AccessLevel = 'Edit'
                    ));
                }
            }

            for (Id projectId : newGMsByProject.keySet()) {
                projectShares.add(new pse__Proj__Share(
                    ParentId = projectId,
                    UserOrGroupId = newGMsByProject.get(projectId),
                    RowCause = Schema.pse__Proj__Share.RowCause.pse__PSE_Member_Share__c,
                    AccessLevel = 'Edit'
                ));
            }

            if (!projectShares.isEmpty()) insert projectShares;
        }
    }
    else {
        Map<Id, Id> newPMsByProject = new Map<Id, Id>();
        Map<Id, Id> newGMsByProject = new Map<Id, Id>();
        for (pse__Proj__c newProject : Trigger.new) {
            pse__Proj__c oldProject = Trigger.oldMap.get(newProject.Id);
            if (newProject.pse__Project_Manager__c != null && newProject.pse__Project_Manager__c != oldProject.pse__Project_Manager__c) {
                    newPMsByProject.put(newProject.Id, newProject.pse__Project_Manager__c);
            }

            if (newProject.Group_Manager__c != null && newProject.Group_Manager__c != oldProject.Group_Manager__c) {
                    newGMsByProject.put(newProject.Id, newProject.Group_Manager__c);
            }
        }
        
        if (newPMsByProject.size() > 0 || newGMsByProject.size() > 0) {
            Map<Id, Contact> activePMs = new Map<Id, Contact>([
                select Id, pse__Salesforce_User__c
                from Contact 
                where
                    Id in :newPMsByProject.values() and
                    pse__Salesforce_User__c != null and
                    pse__Salesforce_User__r.IsActive = true
            ]);
            
            List<pse__Proj__Share> projectShares = new List<pse__Proj__Share>();
            for (Id projectId : newPMsByProject.keySet()) {
                if (activePMs.containsKey(newPMsByProject.get(projectId))) {
                    Id pmSFUser = activePMs.get(newPMsByProject.get(projectId)).pse__Salesforce_User__c;
                    projectShares.add(new pse__Proj__Share(
                        ParentId = projectId,
                        UserOrGroupId = pmSFUser,
                        RowCause = Schema.pse__Proj__Share.RowCause.pse__PSE_PM_Share__c,
                        AccessLevel = 'Edit'
                    ));
                }
            }
            
            for (Id projectId : newGMsByProject.keySet()) {
                projectShares.add(new pse__Proj__Share(
                    ParentId = projectId,
                    UserOrGroupId = newGMsByProject.get(projectId),
                    RowCause = Schema.pse__Proj__Share.RowCause.pse__PSE_Member_Share__c,
                    AccessLevel = 'Edit'
                ));
            }
            
            if (!projectShares.isEmpty()) insert projectShares;
            
            // Share Timecards with the new PM
            List<pse__Timecard_Header__c> timecards = [
                select
                    Id,
                    pse__Project__c
                from pse__Timecard_Header__c
                where pse__Project__c in :newPMsByProject.keySet()
            ];
            
            List<pse__Timecard_Header__Share> tShares = new List<pse__Timecard_Header__Share>();
            for (pse__Timecard_Header__c timecard : timecards) {
                if (newPMsByProject.containsKey(timecard.pse__Project__c)) {
                    if (activePMs.containsKey(newPMsByProject.get(timecard.pse__Project__c))) {
                        pse__Timecard_Header__Share tShare = new pse__Timecard_Header__Share(
                            ParentId = timecard.Id,
                            UserOrGroupId = activePMs.get(newPMsByProject.get(timecard.pse__Project__c)).pse__Salesforce_User__c,
                            RowCause = Schema.pse__Timecard_Header__Share.RowCause.pse__PSE_PM_Share__c,
                            AccessLevel = 'Edit'
                        );
                        tShares.add(tShare);
                    }
                }

                if (newGMsByProject.containsKey(timecard.pse__Project__c)) {
                    pse__Timecard_Header__Share tShare = new pse__Timecard_Header__Share(
                        ParentId = timecard.Id,
                        UserOrGroupId = newGMsByProject.get(timecard.pse__Project__c),
                        RowCause = Schema.pse__Timecard_Header__Share.RowCause.pse__PSE_Member_Share__c,
                        AccessLevel = 'Edit'
                    );
                    tShares.add(tShare);
                }
            }
            
            if (tShares.size() > 0) insert tShares;
                             
            // Share Expense Reports with the new PM
            List<pse__Expense_Report__c> expenseRpts = [
                select
                    Id,
                    pse__Project__c
                from pse__Expense_Report__c
                where pse__Project__c in :newPMsByProject.keySet()
            ];
            
            List<pse__Expense_Report__Share> erShares = new List<pse__Expense_Report__Share>();
            for (pse__Expense_Report__c expenseRpt : expenseRpts) {
                if (newPMsByProject.containsKey(expenseRpt.pse__Project__c)) {
                    if (activePMs.containsKey(newPMsByProject.get(expenseRpt.pse__Project__c))) {
                        pse__Expense_Report__Share erShare = new pse__Expense_Report__Share(
                            ParentId = expenseRpt.Id,
                            UserOrGroupId = activePMs.get(newPMsByProject.get(expenseRpt.pse__Project__c)).pse__Salesforce_User__c,
                            RowCause = Schema.pse__Expense_Report__Share.RowCause.pse__PSE_PM_Share__c,
                            AccessLevel = 'Edit'
                        );
                        erShares.add(erShare);
                    }
                }

                if (newGMsByProject.containsKey(expenseRpt.pse__Project__c)) {
                    pse__Expense_Report__Share erShare = new pse__Expense_Report__Share(
                        ParentId = expenseRpt.Id,
                        UserOrGroupId = newGMsByProject.get(expenseRpt.pse__Project__c),
                        RowCause = Schema.pse__Expense_Report__Share.RowCause.pse__PSE_Member_Share__c,
                        AccessLevel = 'Edit'
                    );
                    erShares.add(erShare);
                }
            }
            
            if (erShares.size() > 0) insert erShares;
                             
            // Share Expenses with the new PM
            List<pse__Expense__c> expenses = [
                select
                    Id,
                    pse__Project__c
                from pse__Expense__c
                where pse__Project__c in :newPMsByProject.keySet()
            ];
            
            List<pse__Expense__Share> eShares = new List<pse__Expense__Share>();
            for (pse__Expense__c expense : expenses) {
                if (newPMsByProject.containsKey(expense.pse__Project__c)) {
                    if (activePMs.containsKey(newPMsByProject.get(expense.pse__Project__c))) {
                        pse__Expense__Share eShare = new pse__Expense__Share(
                            ParentId = expense.Id,
                            UserOrGroupId = activePMs.get(newPMsByProject.get(expense.pse__Project__c)).pse__Salesforce_User__c,
                            RowCause = Schema.pse__Expense__Share.RowCause.pse__PSE_PM_Share__c,
                            AccessLevel = 'Edit'
                        );
                        eShares.add(eShare);
                    }
                }

                if (newGMsByProject.containsKey(expense.pse__Project__c)) {
                    pse__Expense__Share eShare = new pse__Expense__Share(
                        ParentId = expense.Id,
                        UserOrGroupId = newGMsByProject.get(expense.pse__Project__c),
                        RowCause = Schema.pse__Expense_Report__Share.RowCause.pse__PSE_Member_Share__c,
                        AccessLevel = 'Edit'
                    );
                    eShares.add(eShare);
                }
            }
            
            if (eShares.size() > 0) insert eShares;
        }
    }
}