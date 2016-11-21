trigger SalesCreditNoteTrigger on c2g__codaCreditNote__c (after insert, after update) {

    Util.IsTrigger_Invoice = true;
    
    Set<Id> ContractIDs = new Set<Id>();
    if (trigger.isInsert) {
        for (c2g__codaCreditNote__c s : trigger.new) {
            If (s.ContractABC__c != null) {ContractIDs.add(s.ContractABC__c);}
        }
    }

    if (trigger.isUpdate) {
        for (Integer i = 0; i < trigger.new.size(); i++) {
            if (trigger.new[i].c2g__NetTotal__c != trigger.old[i].c2g__NetTotal__c) { 
                if (trigger.new[i].ContractABC__c != null) {ContractIDs.add(trigger.new[i].ContractABC__c);}
            }
        }
    }
    
    if (ContractIDs.size() > 0) {
        List<Contract__c> updCon = InvoiceTriggerHelper.RollupInvoiceAmtOnContract(ContractIDs, true);
        Database.Saveresult[] sr = database.update(updcon,false);
    }

}