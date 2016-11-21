/*
  Purpose:
        This trigger manages sharing of Expenses with the Resource and Project Manager
        
  Initiative: IconATG FinancialForce PSA Implementation 
  Author:     William Rich
  Company:    IconATG
  Contact:    william.rich@iconatg.com
  Created:    7/24/2015
*/

trigger RLSExpense on pse__Expense__c (before insert, after insert) {
    Set<Id> resourceIds = new Set<Id>();
    Set<Id> projectIds = new Set<Id>();
    Set<Id> expenseRptIds = new Set<Id>();
    for (pse__Expense__c expense : Trigger.new) {
        if (expense.OwnerId != expense.pse__Resource__c) {
            resourceIds.add(expense.pse__Resource__c);
        }

        if (expense.pse__Project__c != null) {
            projectIds.add(expense.pse__Project__c);
        }
        
        if (expense.pse__Expense_Report__c != null) {
            expenseRptIds.add(expense.pse__Expense_Report__c);
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
            
            for (pse__Expense__c expense : Trigger.new) {
                if (activeResources.containsKey(expense.pse__Resource__c)) {
                    Contact theResource = activeResources.get(expense.pse__Resource__c);
                    expense.OwnerId = theResource.pse__Salesforce_User__c;
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
            
            // Share with PM
            List<pse__Expense__Share> eShares = new List<pse__Expense__Share>();
            for (pse__Expense__c expense : Trigger.new) {
                if (projects.containsKey(expense.pse__Project__c)) {
                    pse__Proj__c project = projects.get(expense.pse__Project__c);

                    if (project.pse__Project_Manager__c != null && 
                        project.pse__Project_Manager__r.pse__Salesforce_User__c != null &&
                        project.pse__Project_Manager__r.pse__Salesforce_User__r.IsActive) {
                        
                        pse__Expense__Share eShare = new pse__Expense__Share(
                            ParentId = expense.Id,
                            UserOrGroupId = project.pse__Project_Manager__r.pse__Salesforce_User__c,
                            RowCause = Schema.pse__Expense__Share.RowCause.pse__PSE_PM_Share__c,
                            AccessLevel = 'Edit'
                        );
                        eShares.add(eShare);
                    }

                    if (project.Group_Manager__c != null) {
                        pse__Expense__Share eShare = new pse__Expense__Share(
                            ParentId = expense.Id,
                            UserOrGroupId = project.Group_Manager__c,
                            RowCause = Schema.pse__Expense__Share.RowCause.pse__PSE_Member_Share__c,
                            AccessLevel = 'Edit'
                        );
                        eShares.add(eShare);
                    }
                }
            }

            if (!eShares.isEmpty()) insert eShares;
        }
    }
}