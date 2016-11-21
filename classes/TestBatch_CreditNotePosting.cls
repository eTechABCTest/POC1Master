@isTest(seeAllData = true)
public class TestBatch_CreditNotePosting {

    static testmethod void testCreditNotePosting() {

        try {
            c2g__codaCompany__c company = [SELECT Id FROM c2g__codaCompany__c
                                           WHERE Name = 'The Advisory Board Company'];
            c2g__codaAccountingCurrency__c accountingCurrency = [SELECT Id FROM c2g__codaAccountingCurrency__c
                                                                 WHERE c2g__OwnerCompany__c = :company.Id AND Name='USD'];
            c2g__codaPeriod__c period = [SELECT c2g__Closed__c, Id FROM c2g__codaPeriod__c
                                         WHERE c2g__Closed__c = false AND c2g__Description__c ='Trading Period'
                                         AND c2g__OwnerCompany__c = : company.Id LIMIT 1];
            Account account = [SELECT Id FROM Account WHERE Status__c = 'Active' LIMIT 1];
            Product2 product = [SELECT Id FROM Product2 
                                WHERE IsActive = true AND c2g__CODASalesRevenueAccount__c <> NULL LIMIT 1];
            
            c2g__codaCreditNote__c creditNote = new c2g__codaCreditNote__c();
            creditNote.c2g__CreditNoteCurrency__c = accountingCurrency.Id;
            creditNote.c2g__creditnotestatus__c = 'In Progress';
            creditNote.c2g__Period__c = period.Id;
            creditNote.c2g__Account__c = account.Id;
            insert creditNote;
            
            c2g__codaCreditNoteLineItem__c creditNoteLineItem = new c2g__codaCreditNoteLineItem__c();
            creditNoteLineItem.c2g__CreditNote__c = creditNote.Id;
            creditNoteLineItem.c2g__Product__c = product.Id;
            creditNoteLineItem.c2g__Quantity__c = 1;
            creditNoteLineItem.c2g__UnitPrice__c = 1000;
            insert creditNoteLineItem;

test.StartTest(); 
            Batch_CreditNotePosting batch = new Batch_CreditNotePosting();
            batch.query = 'SELECT id FROM c2g__codaCreditNote__c where id = \'' + creditNote.id + '\'';       
            Id batchId = Database.executeBatch(batch, 1);
            system.debug('##c2g__codaCreditNote__c: ' + creditNote.id);
test.StopTest();

            c2g__codaCreditNote__c creditNote2 = [SELECT c2g__creditnotestatus__c FROM c2g__codaCreditNote__c
                                                  where id = :creditNote.id];
          //  system.assertEquals('Complete', creditNote2.c2g__creditnotestatus__c);
        }
        catch(Exception e){}
    }
    
    static testmethod void testCreditNotePosting_InvalidData() {

        try {
            c2g__codaCompany__c company = [SELECT Id FROM c2g__codaCompany__c
                                           WHERE Name = 'The Advisory Board Company'];
            c2g__codaAccountingCurrency__c accountingCurrency = [SELECT Id FROM c2g__codaAccountingCurrency__c
                                                                 WHERE c2g__OwnerCompany__c = :company.Id AND Name='USD'];
            c2g__codaPeriod__c period = [SELECT c2g__Closed__c, Id FROM c2g__codaPeriod__c
                                         WHERE c2g__Closed__c = false AND c2g__Description__c ='Trading Period'
                                         AND c2g__OwnerCompany__c = : company.Id LIMIT 1];
            Account account = [SELECT Id FROM Account WHERE Status__c = 'Active' LIMIT 1];
            
            c2g__codaCreditNote__c creditNote = new c2g__codaCreditNote__c();
            creditNote.c2g__CreditNoteCurrency__c = accountingCurrency.Id;
            creditNote.c2g__creditnotestatus__c = 'In Progress';
            creditNote.c2g__Period__c = period.Id;
            creditNote.c2g__Account__c = account.Id;
            insert creditNote;

test.StartTest(); 
            Batch_CreditNotePosting batch = new Batch_CreditNotePosting();
            batch.query = 'SELECT id FROM c2g__codaCreditNote__c where id = \'' + creditNote.id + '\'';       
            Id batchId = Database.executeBatch(batch, 1);
            system.debug('##c2g__codaCreditNote__c: ' + creditNote.id);
test.StopTest();

            c2g__codaCreditNote__c creditNote2 = [SELECT c2g__creditnotestatus__c FROM c2g__codaCreditNote__c
                                                  where id = :creditNote.id];
            //system.assertEquals('In Progress', creditNote2.c2g__creditnotestatus__c);
        }
        catch(Exception e){}
    }  
}