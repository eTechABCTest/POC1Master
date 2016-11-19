/*
  Purpose:
        When a billing event is released, this trigger changes the Type field on all Line Item Schedules
        that are associated with a milestone billing event item and whose type is Risk Fee or Risk Travel
        to Member Fee or Travel, respectively.
        
  Initiative: IconATG FinancialForce PSA Implementation 
  Author:     William Rich
  Company:    IconATG
  Contact:    william.rich@iconatg.com
  Created:    8/12/2015
*/

trigger UpdateLISOnBillingEventRelease on pse__Billing_Event__c (after update) {
    Set<Id> releasedBEs = new Set<Id>();
    for (pse__Billing_Event__c newBE : Trigger.new) {
        pse__Billing_Event__c oldBE = Trigger.oldMap.get(newBE.Id);
        if (newBE.pse__Is_Released__c == true) {
            releasedBEs.add(newBE.Id);
        }
    }

    if (!releasedBEs.isEmpty()) {
        List<pse__Billing_Event_Item__c> beis = [
            select
                pse__Billing_Event__c,
                pse__Milestone__c,
                pse__Milestone__r.Line_Item_Schedule__c
            from pse__Billing_Event_Item__c
            where
                pse__Billing_Event__c in :releasedBEs and
                pse__Milestone__c != null and
                pse__Milestone__r.Line_Item_Schedule__c != null and
                (
                    pse__Milestone__r.Line_Item_Schedule__r.Type__c = 'Risk Fee' or
                    pse__Milestone__r.Line_Item_Schedule__r.Type__c = 'Risk Travel'
                )
        ];

        if (!beis.isEmpty()) {
            Set<Id> lisIds = new Set<Id>();
            for (pse__Billing_Event_Item__c bei : beis) {
                lisIds.add(bei.pse__Milestone__r.Line_Item_Schedule__c);
            }

            List<Line_Item_Schedule__c> lises = [
                select Id, Type__c
                from Line_Item_Schedule__c
                where Id in :lisIds
            ];

            if (!lises.isEmpty()) {
                for (Line_Item_Schedule__c lis : lises) {
                    lis.Type__c = lis.Type__c.equals('Risk Fee') ? 'Member Fee' : 'Travel';
                }

                update lises;
            }
        }
    }
}