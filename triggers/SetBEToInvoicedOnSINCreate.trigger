/*
    Purpose:
        Wnen a sales invoice is created, this trigger marks the billing event as invoiced.
            
    Author:     William Rich
    Company:    IconATG
    Contact:    william.rich@iconatg.com
    Created:    9/15/2015
*/

trigger SetBEToInvoicedOnSINCreate on c2g__codaInvoice__c (after insert) {
    Map<Id, c2g__codaInvoice__c> sinsByIBS = new Map<Id, c2g__codaInvoice__c>();
    for (c2g__codaInvoice__c sin : Trigger.new) {
        if (sin.InvoiceBillingSchedule__c != null) {
            sinsByIBS.put(sin.InvoiceBillingSchedule__c, sin);
            
            System.debug('&&&&& sin ' + sin.Id + ' => ibs ' + sin.InvoiceBillingSchedule__c);
        }
    }

    if (!sinsByIBS.isEmpty()) {
        List<Line_Item_Schedule__c> lises = [
            select
                Id,
                Invoice_Billing_Schedule_del__c
            from Line_Item_Schedule__c
            where Invoice_Billing_Schedule_del__c in :sinsByIBS.keySet()
        ];

        Set<Id> lisIds = new Set<Id>();
        for (Line_Item_Schedule__c lis : lises) {
            lisIds.add(lis.Id);
        }

        if (!lisIds.isEmpty()) {
            Set<Id> sObjIds = new Set<Id>();
            addIdsFor('pse__Milestone__c', lisIds, sObjIds);
            addIdsFor('pse__Timecard__c', lisIds, sObjIds);
            addIdsFor('pse__Expense__c', lisIds, sObjIds);
            addIdsFor('pse__Miscellaneous_Adjustment__c', lisIds, sObjIds);

            List<pse__Billing_Event_Item__c> beis = [
                select 
                    pse__Billing_Event__c,
                    pse__Expense__c,
                    pse__Expense__r.Line_Item_Schedule__c,
                    pse__Expense__r.Line_Item_Schedule__r.Invoice_Billing_Schedule_del__c,
                    pse__Milestone__c,
                    pse__Milestone__r.Line_Item_Schedule__c,
                    pse__Milestone__r.Line_Item_Schedule__r.Invoice_Billing_Schedule_del__c,
                    pse__Miscellaneous_Adjustment__c,
                    pse__Miscellaneous_Adjustment__r.Line_Item_Schedule__c,
                    pse__Miscellaneous_Adjustment__r.Line_Item_Schedule__r.Invoice_Billing_Schedule_del__c,
                    pse__Timecard_Split__c,
                    pse__Timecard_Split__r.Line_Item_Schedule__c,
                    pse__Timecard_Split__r.Line_Item_Schedule__r.Invoice_Billing_Schedule_del__c,
                    pse__Category__c
                from pse__Billing_Event_Item__c
                where 
                    pse__Object_Id__c in :sObjIds and
                    pse__Category__c != 'Budget' and
                    pse__Is_Released__c = 'Yes'
            ];
            
            System.debug('&&&&& beis: ' + beis.size());

            Map<Id, Id> ibsesByBE = new Map<Id, Id>();
            for (pse__Billing_Event_Item__c bei : beis) {
                if (bei.pse__Category__c.equals('Expense')) {
                    if (bei.pse__Expense__r.Line_Item_Schedule__c != null) {
                        System.debug('&&&&& Expense Category: ' + bei.pse__Expense__c + ', LIS is ' + bei.pse__Expense__r.Line_Item_Schedule__c + ', IBS is ' + bei.pse__Expense__r.Line_Item_Schedule__r.Invoice_Billing_Schedule_del__c);
                        ibsesByBE.put(bei.pse__Billing_Event__c, bei.pse__Expense__r.Line_Item_Schedule__r.Invoice_Billing_Schedule_del__c);
                    }
                }
                else if (bei.pse__Category__c.equals('Milestone')) {
                    if (bei.pse__Milestone__r.Line_Item_Schedule__c != null) {
                        System.debug('&&&&& Milestone Category: ' + bei.pse__Milestone__c + ', LIS is ' + bei.pse__Milestone__r.Line_Item_Schedule__c + ', IBS is ' + bei.pse__Milestone__r.Line_Item_Schedule__r.Invoice_Billing_Schedule_del__c);
                        ibsesByBE.put(bei.pse__Billing_Event__c, bei.pse__Milestone__r.Line_Item_Schedule__r.Invoice_Billing_Schedule_del__c);
                    }
                }
                else if (bei.pse__Category__c.equals('Miscellaneous Adjustment')) {
                    if (bei.pse__Miscellaneous_Adjustment__r.Line_Item_Schedule__c != null) {
                        System.debug('&&&&& Miscellaneous Adjustment Category: ' + bei.pse__Miscellaneous_Adjustment__c + ', LIS is ' + bei.pse__Miscellaneous_Adjustment__r.Line_Item_Schedule__c + ', IBS is ' + bei.pse__Miscellaneous_Adjustment__r.Line_Item_Schedule__r.Invoice_Billing_Schedule_del__c);
                        ibsesByBE.put(bei.pse__Billing_Event__c, bei.pse__Miscellaneous_Adjustment__r.Line_Item_Schedule__r.Invoice_Billing_Schedule_del__c);
                    }
                }
                else if (bei.pse__Category__c.equals('Timecard')) {
                    if (bei.pse__Timecard_Split__r.Line_Item_Schedule__c != null) {
                        System.debug('&&&&& Timecard Category: ' + bei.pse__Timecard_Split__c + ', LIS is ' + bei.pse__Timecard_Split__r.Line_Item_Schedule__c + ', IBS is ' + bei.pse__Timecard_Split__r.Line_Item_Schedule__r.Invoice_Billing_Schedule_del__c);
                        ibsesByBE.put(bei.pse__Billing_Event__c, bei.pse__Timecard_Split__r.Line_Item_Schedule__r.Invoice_Billing_Schedule_del__c);
                    }
                }
            }

            System.debug('&&&&& ibsesByBE: ' + ibsesByBE.size());

            List<pse__Billing_Event__c> bes = [
                select 
                    Id,
                    pse__Invoiced__c,
                    pse__Invoice_Date__c,
                    pse__Invoice_Number__c
                from pse__Billing_Event__c
                where Id in :ibsesByBE.keyset()
            ];
            /*
            System.debug('&&&&& bes: ' + bes.size());
            for (pse__Billing_Event__c be : bes) {
                for (pse__Billing_Event_Item__c bei : be.pse__Billing_Event_Items__r) {
                    System.debug('&&&&& be.Id = ' + be.Id + ', bei.Id = ' + bei.Id + ', bei.pse__Object_Id__c = ' + bei.pse__Object_Id__c + ', bei.pse__Miscellaneous_Adjustment__c = ' + bei.pse__Miscellaneous_Adjustment__c + ', bei.pse__Category__c = ' + bei.pse__Category__c);
                }
            }
            */
            List<pse__Billing_Event__c> invoicedBEs = new List<pse__Billing_Event__c>();
            for (pse__Billing_Event__c be : bes) {
                if (ibsesByBE.containsKey(be.Id)) {
                    Id ibsId = ibsesByBE.get(be.Id);
                    System.debug('&&&&& ibsId: ' + ibsId);
                    if (sinsByIBS.containsKey(ibsId)) {
                        c2g__codaInvoice__c sin = sinsByIBS.get(ibsId);
                        be.pse__Invoiced__c = true;
                        be.pse__Invoice_Date__c = sin.c2g__InvoiceDate__c;
                        be.pse__Invoice_Number__c = sin.Name; 

                        invoicedBEs.add(be);
                    }
                }
            }

            if (!invoicedBEs.isEmpty()) update invoicedBEs;
        }
    }

    private void addIdsFor(String objName, Set<Id> lisIds, Set<Id> sObjIds) {
        String sObjQuery = 
            'select Id ' +
            'from ' + objName + ' ' +
            'where Line_Item_Schedule__c in :lisIds';
        List<Sobject> sObjs = Database.query(sObjQuery);
        for (Sobject sObj : sObjs) {
            sObjIds.add(sObj.Id);
        }
    }
}