/*
  Purpose:
        When a Line Item Schedule is deleted, this trigger throws an error if the Line Item Schedule
        is associated with a Billing Milestone
        
  Initiative: IconATG FinancialForce PSA Implementation 
  Author:     William Rich
  Company:    IconATG
  Contact:    william.rich@iconatg.com
  Created:    8/17/2015
*/

trigger ValidateLISDeletion on Line_Item_Schedule__c (before delete) {
    Set<Id> lisIds = new Set<Id>();
    for (Line_Item_Schedule__c lis : Trigger.old) {
        if (lis.Invoiced__c) {
            String msg = 'A Line Item Schedule that has been invoiced cannot be deleted';
            lis.addError(msg);
        }
        else if (!lis.Bypass_Delete_Validation__c) {
            lisIds.add(lis.Id);
        }
    }

    if (!lisIds.isEmpty()) {
        
        List<pse__Milestone__c> billingMilestones = [
            select
                Id,
                Line_Item_Schedule__c
            from pse__Milestone__c
            where Line_Item_Schedule__c in :lisIds
        ];

        if (!billingMilestones.isEmpty()) {
            for (pse__Milestone__c billingMilestone : billingMilestones) {
                Line_Item_Schedule__c lis = Trigger.oldMap.get(billingMilestone.Line_Item_Schedule__c);
                String msg = 'This Line Item schedule is associated with a Billing Milestone. You must delete the ' +
                             'Billing Milestone which will then delete the Line Item Schedule.';
                lis.addError(msg);
            }
        }
        
        List<pse__Miscellaneous_Adjustment__c> adminFeeMAs = [
            select Id, Line_Item_Schedule__c
            from pse__Miscellaneous_Adjustment__c
            where 
                Line_Item_Schedule__c in :lisIds and 
                pse__Transaction_Category__c = 'Ready-to-Bill Revenue'
        ];

        if (!adminFeeMAs.isEmpty()) {
            for (pse__Miscellaneous_Adjustment__c adminFeeMA : adminFeeMAs) {
                Line_Item_Schedule__c lis = Trigger.oldMap.get(adminFeeMA.Line_Item_Schedule__c);
                String msg = 'This Line Item Schedule has a relationship with a Miscellaneous Adjustment used for Admin Fees and ' +
                             'cannot be deleted. To credit Admin Fees back to the customer, manually create a Miscellaneous Adjustment ' +
                             'of type Ready To Bill Revenue with a negative dollar amount on the Project and generate and release ' +
                             'a Billing Event. This will create another LIS with a negative dollar amount.';
                lis.addError(msg);
            }
        }
    }
}