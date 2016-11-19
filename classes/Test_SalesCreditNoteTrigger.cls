@isTest(SeeAllData=true)
private class Test_SalesCreditNoteTrigger {

    static testMethod void test1() {
             List<c2g__codaCreditNote__c> salesinvoice2 = [Select Id from c2g__codaCreditNote__c limit 1];
            update salesinvoice2;
        
    }
}