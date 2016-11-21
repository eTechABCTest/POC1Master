@isTest(SeeAllData=true)
private class Test_Transaction {

    static testMethod void test1() {
           List<c2g__codaTransaction__c> t = [Select Id from c2g__codaTransaction__c limit 1];
                update t;
        
    }
}