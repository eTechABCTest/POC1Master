/*
    Purpose:
       When an expense is inserted or updated, this trigger sets the Billable checkbox as a function
       of the Project Expense Types (Project_Expense_Type__c) and the project Billable Expense Types Apply checkbox.
            
    Initiative: IconATG PSA Implementation
    Author:     William Rich
    Company:    IconATG
    Contact:    william.rich@iconatg.com
    Created:    7/9/2015
*/

trigger SetBillableOnExpense on pse__Expense__c (before insert, before update) {
    Set<Id> projectIds = new Set<Id>();
    for (pse__Expense__c expense : Trigger.new) {
        if (expense.pse__Project__c != null) {
            projectIds.add(expense.pse__Project__c);
        }
    }

    if (!projectIds.isEmpty()) {
        List<pse__Proj__c> projects = [
            select
                Id,
                (select Name, Billable__c from Project_Expense_Types__r)
            from pse__Proj__c
            where 
                Id in :projectIds and
                Billable_Expense_Types_Apply__c = true
        ];

        Map<Id, Map<String, Project_Expense_Type__c>> petsByProject = new Map<Id, Map<String, Project_Expense_Type__c>>();
        for (pse__Proj__c project : projects) {
            Map<String, Project_Expense_Type__c> petsByExpenseType = new Map<String, Project_Expense_Type__c>();
            for (Project_Expense_Type__c pet : project.Project_Expense_Types__r) {
                petsByExpenseType.put(pet.Name, pet);

                System.debug('&&&&& ' + pet.Name + ': ' + pet.Billable__c);
            }
            petsByProject.put(project.Id, petsByExpenseType);
        }

        for (pse__Expense__c expense : Trigger.new) {
            if (expense.pse__Project__c != null && petsByProject.containsKey(expense.pse__Project__c)) {
                Map<String, Project_Expense_Type__c> petsByExpenseType = petsByProject.get(expense.pse__Project__c);
                if (petsByExpenseType.containsKey(expense.pse__Type__c)) {
                    expense.pse__Billable__c = petsByExpenseType.get(expense.pse__Type__c).Billable__c;
                }
            }
        }
    }
}