global class Batch_InvoicePosting implements Database.Batchable<SObject> {

    global String query = 'SELECT id FROM c2g__codaInvoice__c where c2g__InvoiceStatus__c = \'In Progress\'';
    
    //Override Start method
    global Database.queryLocator start(Database.BatchableContext ctx) {
        return Database.getQueryLocator(query);
    }
    
    //Override execute method
    global void execute(Database.BatchableContext ctx, list<Sobject> scope) {
    
        // Convert the query of Sobjects into a List of Invoice
        list<c2g__codaInvoice__c> invoices = (list<c2g__codaInvoice__c>) scope;
        // Loop through all Invoices
        for (c2g__codaInvoice__c invoice : invoices) {
            c2g.CODAAPICommon.Reference ref = new c2g.CODAAPICommon.Reference();
            ref.Id = invoice.Id;
            
            try {
                c2g.CODAAPISalesInvoice_7_0.PostInvoice(null, ref);
            } catch (Exception ex) {
                String emailMessage = 'Error has happend for invoice: ' + invoice.id + '\n' + ex;
                AsyncApexJob a = [SELECT CreatedBy.Id FROM AsyncApexJob WHERE id = :ctx.getJobId()];
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                mail.setTargetObjectId(a.CreatedBy.Id);
                mail.setReplyTo('noreply@salesforce.com');
                mail.setSenderDisplayName('Salesforce Batch'); 
                mail.setSubject('Batch_InvoicePosting: error');
                mail.setPlainTextBody(emailMessage);
                mail.setHtmlBody(emailMessage);
                mail.setSaveAsActivity(false);
                Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
            }
        }
    }
    
    // Override Finish method
    global void finish(Database.BatchableContext ctx) {
    
        AsyncApexJob a = [SELECT id, ApexClassId, JobItemsProcessed, TotalJobItems, NumberOfErrors,
                            CompletedDate, CreatedDate, CreatedBy.Id FROM AsyncApexJob WHERE id = :ctx.getJobId()];
        
        // Send email to confirm completion of this batch
        String emailMessage = 'The batch job \"Batch_CashEntryPosting\" has finished.  It has started at ' + a.CreatedDate + 
            ' and has finished at ' + a.CompletedDate + '. It has processed '  + a.TotalJobItems + ' batches.  Of which, ' +
            a.JobItemsProcessed + ' processed without any exceptions thrown and ' + a.NumberOfErrors +
            ' batches threw unhandled exceptions.';
        
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setTargetObjectId(a.CreatedBy.Id);
        mail.setReplyTo('noreply@salesforce.com');
        mail.setSenderDisplayName('Salesforce Batch'); 
        mail.setSubject('Batch_InvoicePosting: completed');
        mail.setPlainTextBody(emailMessage);
        mail.setHtmlBody(emailMessage);       
        mail.setSaveAsActivity(false);
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
    }

/*    
    static testmethod void testCashPosting() {
        c2g__codaCreditNote__c creditNote = new c2g__codaCreditNote__c();
        creditNote.c2g__status__c = 'In Progress';
        insert creditNote;
        
        Batch_CreditNotePosting batch = new Batch_CreditNotePosting();
        batch.query = 'SELECT id FROM c2g__codaCreditNote__c where id = \'' + creditNote.id + '\'';
        Id batchId = Database.executeBatch(batch, 10);
        
        system.assertEquals('Completed', creditNote.c2g__creditnotestatus__c);
    }
*/
}