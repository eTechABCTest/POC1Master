/**
 *  Description     :   Helper class for various Financial Force triggers (ie: Transaction, SalesCreditNote, and SalesInvoice)
 * 
 *  Created By      :   Victor Hanson
 * 
 *  Created Date    :   05/13/2013
 * 
 *  Revision Logs   :   V1.0 - Created
 *                      V1.1 - Modified By - Abhinav Sharma - CR-20150308-8736 - 04/02/2015
**/ 
public with sharing class InvoiceTriggerHelper {
    
    // rollup the Invoice Total and Amount Credited Total
    public static List<Contract__c> RollupInvoiceAmtOnContract(Set<Id> contractIdSet, boolean calcCreditNoteTotal) {
        AggregateResult[] r = [select ContractABC__c, sum(c2g__NetTotal__c) NT
        from c2g__codaInvoice__c where ContractABC__c != null and ContractABC__c in :contractIdSet group by ContractABC__c];
       
        AggregateResult[] creditAggr = [select ContractABC__c, sum(c2g__NetTotal__c) crNT, sum(c2g__Transaction__r.c2g__DocumentOutstandingTotal__c) AC 
        from c2g__codaInvoice__c where ContractABC__c != null and ContractABC__c in :contractIdSet AND AmtCredited__c > 0 group by ContractABC__c];
        
        AggregateResult[] creditNoteAggr = [select ContractABC__c, sum(c2g__NetTotal__c) NT 
            from c2g__codaCreditNote__c where ContractABC__c != null and ContractABC__c in :contractIdSet group by ContractABC__c];
        
        // create a map of Contract_ABC.Id -> Amount_Credited_Total__c
        Map<Id, Decimal> contAbcToAmtCred = new Map<Id, Decimal>();
        Decimal NT, AC, crNT;
        for (Integer i = 0; i < creditAggr.size(); i++) {
            
            //V1.1 - Modified By - Abhinav Sharma - CR-20150308-8736 - 04/02/2015
            //Start From here
            //Id contractAbcId = String.valueOf(r[i].get('ContractABC__c'));
            Id contractAbcId = String.valueOf(creditAggr[i].get('ContractABC__c'));
            //Upto here
            
            AC = 0;
            crNT = 0;
            
            if (creditAggr[i].get('AC') != null) {
                AC = Decimal.valueOf(String.valueOf(creditAggr[i].get('AC')));
            }
            
            if (creditAggr[i].get('crNT') != null) {
                crNT = Decimal.valueOf(String.valueOf(creditAggr[i].get('crNT')));
            }
            
            
            Decimal amtCreditTotal = crNT - AC;
            system.debug('@@crNT:' + crNT);
            system.debug('@@AC:' + AC);
            system.debug('@@contractAbcId:' + contractAbcId + '    amtCreditTotal:' + amtCreditTotal);
            // add the contract abc and amt credited total to the map
            contAbcToAmtCred.put(contractAbcId, amtCreditTotal);
        }
        
        // create a map of Contract_ABC.Id -> CreditNote__c.SUM(c2g__NetTotal__c)
        Map<Id, Decimal> contAbcToCredNoteNetMap = new Map<Id, Decimal>();
        Decimal creditNoteNetTotal;
        for (Integer i = 0; i < creditNoteAggr.size(); i++) {
            creditNoteNetTotal = 0;
            if (creditNoteAggr[i].get('NT') != null) {
                creditNoteNetTotal = Decimal.valueOf(string.valueOf(creditNoteAggr[i].get('NT')));
            }
            Id contractAbcId = String.valueOf(creditNoteAggr[i].get('ContractABC__c'));
            // add credit note net total to map
            contAbcToCredNoteNetMap.put(contractAbcId, creditNoteNetTotal);
        }
        
        List<Contract__c> updContractList = new List<Contract__c>();
        for (Integer i = 0; i < r.size(); i++) {
            NT = 0;
            Id contractABCId = String.valueOf(r[i].get('ContractABC__c'));
    
            if (r[i].get('NT') != null) {
                NT = Decimal.valueOf(String.valueOf(r[i].get('NT')));
            }
            // get the credit note net total
            creditNoteNetTotal = contAbcToCredNoteNetMap.get(contractABCId);
            if (creditNoteNetTotal == null) creditNoteNetTotal = 0;
            
            // get the amount credit total
            Decimal amtCredTotal = contAbcToAmtCred.get(contractABCId);
            system.debug('@@contractABCId:' + contractABCId + '    amtCredTotal:' + amtCredTotal);
            if (amtCredTotal == null) amtCredTotal = 0;
            
            Contract__c updatedContract = new Contract__c( Id = contractABCId );
            
            if (calcCreditNoteTotal) {
                updatedContract.Credit_Note_Total__c = creditNoteNetTotal;
            }
            else {
                updatedContract.Invoice_Total__c = NT;
                updatedContract.Amount_Credited_Total__c = amtCredTotal;
            }
            updContractList.add(updatedContract);
                
        }
        return updContractList;
    }
    
}