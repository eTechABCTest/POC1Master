/*
  Purpose:
        This trigger sets the Approver on an expense report
        
  Initiative: IconATG FinancialForce PSA Implementation 
  Author:     William Rich
  Company:    IconATG
  Contact:    william.rich@iconatg.com
  Created:    9/17/2013
*/

trigger SetExpenseReportApprover on pse__Expense_Report__c (before insert, before update) {
    Set<Id> projectIds = new Set<Id>();
    Set<Id> resourceIds = new Set<Id>();
    for (pse__Expense_Report__c expenseRpt : Trigger.new) {
        if (expenseRpt.pse__Project__c != null) {
            projectIds.add(expenseRpt.pse__Project__c);
        }
        
        if (expenseRpt.pse__Resource__c != null) {
            resourceIds.add(expenseRpt.pse__Resource__c);
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
    
    for (pse__Expense_Report__c expenseRpt : Trigger.new) {
        Id approver = null;
        if (projects != null && projects.containsKey(expenseRpt.pse__Project__c)) {
            pse__Proj__c project = projects.get(expenseRpt.pse__Project__c);
            if (project.Use_Reporting_Manager_as_Approver__c) {
                if (resources != null && resources.containsKey(expenseRpt.pse__Resource__c)) {
                    Contact resource = resources.get(expenseRpt.pse__Resource__c);
                    if (resource.pse__Salesforce_User__c != null) {
                    	System.debug('&&&&& using resource manager id: ' + resource.pse__Salesforce_User__r.ManagerId);
                        approver = resources.get(expenseRpt.pse__Resource__c).pse__Salesforce_User__r.ManagerId;
                    }
                }
                else {
                    if (project.pse__Project_Manager__c != null) {
                        System.debug('&&&&& using PM salesforce user id: ' + project.pse__Project_Manager__r.pse__Salesforce_User__c);
                        approver = project.pse__Project_Manager__r.pse__Salesforce_User__c;
                    }
                }
            }
            else {
                if (project.pse__Project_Manager__c != null) {
                    System.debug('&&&&& using PM salesforce user: ' + project.pse__Project_Manager__r.pse__Salesforce_User__c);
                    approver = project.pse__Project_Manager__r.pse__Salesforce_User__c;
                }
            }
        }
        
        if (approver != null) {
            System.debug('&&&&& setting approver: ' + approver);
            expenseRpt.pse__Approver__c = approver;
        }
    }
}