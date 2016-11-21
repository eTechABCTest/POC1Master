trigger TransactionTrigger on c2g__codaTransaction__c (after insert, after update) {

    Util.IsTrigger_Invoice = true;
    
    Set<Id> cInvIdSet = new Set<Id>();
    
    // if the sales invoice is paid or amt = 0, add the related consolidated invoice Id to our set of Ids
    for (c2g__codaTransaction__c invc : Trigger.new) {
        
        cInvIdSet.add(invc.Id);
    }

    // get all consolidated invoices and update them
    List<ConsolidatedInvoiceLineItem__c> cInvsToUpdate = [SELECT Id FROM ConsolidatedInvoiceLineItem__c WHERE Invoice__r.c2g__Transaction__c IN :cInvIdSet AND Invoice__r.c2g__InvoiceStatus__c = 'Complete'];
    if (cInvsToUpdate.size() > 0)
        update cInvsToUpdate;

    Set<Id> ContractIDs = new Set<Id>();
    Set<Id> TransactionIDs = new Set<Id>();
    if (trigger.isInsert) {
        for (c2g__codaTransaction__c s : trigger.new) {
            TransactionIDs.add(s.Id);
        }
    }

    if (trigger.isUpdate) {
        for (Integer i = 0; i < trigger.new.size(); i++) {
            if (trigger.new[i].c2g__DocumentOutstandingTotal__c != trigger.old[i].c2g__DocumentOutstandingTotal__c) {
                TransactionIDs.add(trigger.new[i].Id);
            }
        }
    }

    for (c2g__codaInvoice__c s : [select ContractABC__c from c2g__codaInvoice__c where c2g__Transaction__c in :TransactionIds]) {
        If (s.ContractABC__c != null) {ContractIDs.add(s.ContractABC__c);}
    }

    if (ContractIDs.size() > 0) {
        List<Contract__c> updCon = InvoiceTriggerHelper.RollupInvoiceAmtOnContract(ContractIDs, false);
        Database.Saveresult[] sr = database.update(updcon,false);
    }

}