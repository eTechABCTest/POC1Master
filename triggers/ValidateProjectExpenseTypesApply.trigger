/*
    Purpose:
       This trigger throws an error if the Billable_Expense_Types_Apply__c checkbox is un-checked
       and there are expense types that are designmated as billable.
            
    Initiative: IconATG PSA Implementation
    Author:     William Rich
    Company:    IconATG
    Contact:    william.rich@iconatg.com
    Created:    7/13/2015
*/

trigger ValidateProjectExpenseTypesApply on pse__Proj__c (before update) {
    Set<Id> projectIds = new Set<Id>();
    for (pse__Proj__c newProject : Trigger.new) {
        if (!newProject.Billable_Expense_Types_Apply__c) {
            pse__Proj__c oldProject = Trigger.oldMap.get(newProject.Id);
            if (oldProject.Billable_Expense_Types_Apply__c) {
                projectIds.add(newProject.Id);
            }
        }
    }

    if (!projectIds.isEmpty()) {
        List<Project_Expense_Type__c> pets = [
            select Project__c
            from Project_Expense_Type__c
            where 
                Project__c in :projectIds and
                Billable__c = true
        ];

        Set<Id> projectsWithBillablePETs = new Set<Id>();
        for (Project_Expense_Type__c pet : pets) {
            projectsWithBillablePETs.add(pet.Project__c);
        }

        for (Id projectId : projectIds) {
            if (projectsWithBillablePETs.contains(projectId)) {
                String msg = 'Expense Types are being managed on this Project. Please select the ' +
                             '“Manage Expense Types” button on the Project page and deselect all Expense ' +
                             'Types before setting "Billable Expense Types Apply" to FALSE on the Project page.';
                Trigger.newMap.get(projectId).addError(msg);
            }
        }
    }
}