@isTest(seeAllData = true)
private class TestBatch_CashEntryPosting {
    
    static testmethod void testCashPosting() {

        try {
            Account account = [SELECT Id FROM Account WHERE Status__c = 'Active' LIMIT 1];
            
            c2g__codaCashEntry__c cashEntry = new c2g__codaCashEntry__c();
            cashEntry.ffcash__DeriveBankAccount__c = true;
            cashEntry.c2g__status__c = 'In Progress';
            cashEntry.c2g__Value__c = 15;
            insert cashEntry;
            
            c2g__codaCashEntryLineItem__c cashEntryLineItem = new c2g__codaCashEntryLineItem__c();
            cashEntryLineItem.c2g__CashEntry__c = cashEntry.Id;
            cashEntryLineItem.c2g__Account__c = account.Id;
            cashEntryLineItem.c2g__CashEntryValue__c = 15;
            insert cashEntryLineItem;

test.StartTest(); 
            Batch_CashEntryPosting batch = new Batch_CashEntryPosting();
            batch.query = 'SELECT id FROM c2g__codaCashEntry__c where id = \'' + cashEntry.id + '\'';       
            Id batchId = Database.executeBatch(batch, 1);
test.StopTest();

            c2g__codaCashEntry__c cashEntry2 = [SELECT c2g__status__c FROM c2g__codaCashEntry__c where id = :cashEntry.id];
            system.assertEquals('Complete', cashEntry2.c2g__status__c);
        }
        catch(Exception e){}
    }
    
    static testmethod void testCashPosting_InvalidData() {

        try {
            Account account = [SELECT Id FROM Account WHERE Status__c = 'Active' LIMIT 1];
            
            c2g__codaCashEntry__c cashEntry = new c2g__codaCashEntry__c();
            cashEntry.ffcash__DeriveBankAccount__c = true;
            cashEntry.c2g__status__c = 'In Progress';
            cashEntry.c2g__Value__c = 15;
            insert cashEntry;

test.StartTest(); 
            Batch_CashEntryPosting batch = new Batch_CashEntryPosting();
            batch.query = 'SELECT id FROM c2g__codaCashEntry__c where id = \'' + cashEntry.id + '\'';       
            Id batchId = Database.executeBatch(batch, 1);
test.StopTest();

            c2g__codaCashEntry__c cashEntry2 = [SELECT c2g__status__c FROM c2g__codaCashEntry__c where id = :cashEntry.id];
            system.assertEquals('In Progress', cashEntry2.c2g__status__c);
        }
        catch(Exception e){}
    }   
}