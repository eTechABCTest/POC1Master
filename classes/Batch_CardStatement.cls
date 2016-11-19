global class Batch_CardStatement implements Database.Batchable<SObject> {
    
    public integer TotalErrors = 0;
    global String DebugLog = '';
    
    //Variable to hold Comdata credit card Default Hierarchy custom setting
    public static Credit_Card_Settings__c configCCDefaultSetting = CreditCardConstants.CONFIG_DEFAULT;
    
    global Database.Querylocator start(Database.BatchableContext BC)  {
        
        // find credit cards with non-cleared transactions.
        //we limit the subquery to 1 because we only care if there are transactions, doesn't matter how many
        return Database.getQueryLocator([SELECT Id, Cardholder_ID__c FROM Credit_Card__c WHERE 
                                                Status__c = 'Active' AND Cardholder_ID__c != null AND Do_Not_Send_Card_Statement__c = false]);
    }
    
    global void execute(Database.BatchableContext BC, List<SObject> scope) {
                
        //List to hold Deployment__c records to be updated
        List<Credit_Card__c> ccRecords = (List<Credit_Card__c>)scope;
        
        // get the Credit Card Weekly Stmt email template
        Id cardStmtTemplateId = [SELECT Id FROM EmailTemplate WHERE DeveloperName = :ConfigCCDefaultSetting.Statement_Email_Template__c LIMIT 1].Id;
        
        List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();
        
        //Get Travel request Address
        List<OrgWideEmailAddress> travelEmailAddress = [Select Id, Address, DisplayName from OrgWideEmailAddress WHERE DisplayName = 'ABC Travel Updates' LIMIT 1];
        
        // create our emails
        for (Credit_Card__c card : ccRecords) {
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            if(travelEmailAddress.size() > 0)
                mail.setOrgWideEmailAddressId(travelEmailAddress[0].Id);
            mail.setTargetObjectId(card.Cardholder_ID__c);
            mail.setSaveAsActivity(false);
            mail.setTemplateId(cardStmtTemplateId);
            mail.setWhatId(card.Id);
            
            emails.add(mail);
        }
        
        try {
            // send all of the emails
            List<Messaging.SendEmailResult> sendResults = Messaging.sendEmail(emails, true);
            for (Messaging.SendEmailResult result : sendResults) {
                if (!result.isSuccess()) {
                    TotalErrors++;
                    DebugLog += '\r\n' + result.getErrors()[0].getMessage();
                }
            }
        }
        catch(Exception ex) {
            TotalErrors++;
            DebugLog += '\r\n' + ex.getMessage();
        }
    }
    
    global void finish(Database.BatchableContext BC){        
    
        AsyncApexJob a = [SELECT Id, JobItemsProcessed, TotalJobItems, NumberOfErrors, CreatedBy.Email FROM AsyncApexJob 
                            WHERE id = :BC.getJobId()];
        
        // Send email indicating the completion of this batch       
        String emailMessage = 'Your batch job \"Batch_CardStatement\" has finished.  It processed ' 
                                + a.totalJobItems + 
                                ' batches.  Of which, ' 
                                + a.JobItemsProcessed 
                                + ' processed without any exceptions thrown and ' 
                                + a.numberOfErrors 
                                + ' batches threw unhandled exceptions.  ' +
                                + TotalErrors + ' Erros occurred.  \r\n' +
                                + 'deubg log:' + DebugLog;
        
        //Send batch status to the person who executed this batch
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setToAddresses(new List<String>{a.CreatedBy.Email});
        mail.setReplyTo('noreply@salesforce.com');
        mail.setSenderDisplayName('Batch Processing'); 
        mail.setSubject('Batch_UpdateDeploymentStatus has been completed with ' + a.numberOfErrors + ' batch failures and ' + TotalErrors + ' errors');
        mail.setPlainTextBody(emailMessage);
        mail.setHtmlBody(emailMessage);
        
        if (TotalErrors > 0 || a.numberOfErrors > 0) {
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
        }
    }
}