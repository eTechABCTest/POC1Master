global class Batch_CreditNotePosting implements Database.Batchable<SObject> {

    global String query = 'SELECT id FROM c2g__codaCreditNote__c where c2g__creditnotestatus__c = \'In Progress\'';
    
    //Override Start method
    global Database.queryLocator start(Database.BatchableContext ctx) {
        return Database.getQueryLocator(query);
    }
    
    //Override execute method
    global void execute(Database.BatchableContext ctx, list<Sobject> scope) {
    
        // Convert the query of Sobjects into a List of CreditNote
        list<c2g__codaCreditNote__c> creditNotes = (list<c2g__codaCreditNote__c>) scope;
        // Loop through all CreditNotes
        for (c2g__codaCreditNote__c creditNote : creditNotes) {
            c2g.CODAAPICommon.Reference ref = new c2g.CODAAPICommon.Reference();
            ref.Id = creditNote.Id;
            
            try {
                c2g.CODAAPISalesCreditNote_7_0.PostCreditNote(null, ref);
            } catch (Exception ex) {
                String emailMessage = 'Error has happend for credit note: ' + creditNote.id + '\n' + ex;
                AsyncApexJob a = [SELECT CreatedBy.Email FROM AsyncApexJob WHERE id = :ctx.getJobId()];
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                String[] toAddresses = new String[] {a.CreatedBy.email};
                mail.setToAddresses(toAddresses);
                mail.setReplyTo('noreply@salesforce.com');
                mail.setSenderDisplayName('Salesforce Batch'); 
                mail.setSubject('Batch_CreditNotePosting: error');
                mail.setPlainTextBody(emailMessage);
                mail.setHtmlBody(emailMessage);
                Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
            }            
        }
    }
    
    // Override Finish method
    global void finish(Database.BatchableContext ctx) {
    
        AsyncApexJob a = [SELECT id, ApexClassId, JobItemsProcessed, TotalJobItems, NumberOfErrors,
                            CompletedDate, CreatedDate, CreatedBy.Email FROM AsyncApexJob WHERE id = :ctx.getJobId()];
        
        // Send email to confirm completion of this batch
        String emailMessage = 'The batch job \"Batch_CashEntryPosting\" has finished.  It has started at ' + a.CreatedDate + 
            ' and has finished at ' + a.CompletedDate + '. It has processed '  + a.TotalJobItems + ' batches.  Of which, ' +
            a.JobItemsProcessed + ' processed without any exceptions thrown and ' + a.NumberOfErrors +
            ' batches threw unhandled exceptions.';
        
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        String[] toAddresses = new String[] {a.CreatedBy.email};
        mail.setToAddresses(toAddresses);
        mail.setReplyTo('noreply@salesforce.com');
        mail.setSenderDisplayName('Salesforce Batch'); 
        mail.setSubject('Batch_CreditNotePosting: completed');
        mail.setPlainTextBody(emailMessage);
        mail.setHtmlBody(emailMessage);
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
    }

}