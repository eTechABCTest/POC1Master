global class Batch_Contract_Temp implements Database.Batchable<SObject>, Database.Stateful {
    /*
    Purpose:    Perform the following actions:
                    - Update Business_Line_From_Trigger__c, used for Roll Up Summary filtering
                    VRH - 4/16/12 - Updated to process all memberships and add membership status' to them.

	Notes:		This batch is only beign used on a one-time basis for the ABC Rebranding project.
				After that, it will likely be removed.
                    
    Create By:	Victor Hanson
    
    */
    
    String debuglog = '\n';
    Integer batchnum = 0;
    Integer totalprocessed = 0;
    public string Query = null; 
    
    global Batch_Contract_Temp()
    {
        if(Query == null)
        {List<Membership__c> m = [SELECT Name, Account_Name__c, Id, Payer_Status__c, Latest_Contract__c, Earliest_Contract__c, Active_Contract_Idenfied__c, Membership_Status__c, Membership_Status_Text__c
                         FROM Membership__c WHERE Membership_Status_Text__c = null LIMIT 1000];
            Query = 'SELECT Name, Account_Name__c, Id, Payer_Status__c, Latest_Contract__c, Earliest_Contract__c, Active_Contract_Idenfied__c, Membership_Status__c, Membership_Status_Text__c ' + 
            'FROM Membership__c WHERE Membership_Status_Text__c = null';
        }
    }
    
    // Start(Database.BatchableContext) method from Database.Batchable class
    global Database.queryLocator start(Database.BatchableContext ctx)
    {
        AsyncApexJob a = [SELECT id, ApexClassId, JobItemsProcessed, TotalJobItems, NumberOfErrors,  CreatedBy.Email 
            FROM AsyncApexJob 
            WHERE id = :ctx.getJobId()];
        
        // Send email indicating the start of this batch
        String emailMessage = 'Your batch job \"Update Contract__c\" has been started.  Start Time: ' + system.now();
            
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        String[] toAddresses = new String[] {a.CreatedBy.email};
        
        mail.setToAddresses(toAddresses);
        mail.setReplyTo('noreply@salesforce.com');
        mail.setSenderDisplayName('ABC Salesforce batch'); 
        mail.setSubject('Batch Contract__c job started');
        mail.setPlainTextBody(emailMessage);
        
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
        
        // Query all Contracts
        return Database.getQueryLocator(Query);
    }
    
    // Execute(Database.BatchableContext, list<Sobject>) method from Database.Batchable class
    global void execute(Database.BatchableContext ctx, list<Sobject> scope)
    {
        Util.isBatch = true;
        // Convert the queried Contracts into a list of Contracts
        list<Membership__c> recordlist = (list<Membership__c>)scope;
		
		MembershipTriggerHelper.updateMembershipStatusByContracts(recordlist);
        
        // Update Contracts
        try
        {
            update recordlist;
        }
        catch (Exception e)
        {
            // Record any errors to a debuglog variable that will be returned in the completion email
            debuglog += e.getMessage();
        }
    }
    
    // Finished(Database.BatchableContext) method from Database.Batchable class
    global void finish(Database.BatchableContext ctx)
    {
        AsyncApexJob a = [SELECT id, ApexClassId, 
              JobItemsProcessed, 
              TotalJobItems, 
              NumberOfErrors, 
              CreatedBy.Email 
              FROM AsyncApexJob 
              WHERE id = :ctx.getJobId()];
        
        // Send email indicating the completion of this batch
        String emailMessage = 
          'Your batch job \"Update Contract__c\" has finished.  It processed ' + totalprocessed + ' records in ' 
        + a.totalJobItems +
        ' batches.  Of which, ' 
        + a.jobitemsprocessed 
        + ' processed without any exceptions thrown and ' 
        + a.numberOfErrors 
        + ' batches threw unhandled exceptions.<br/><br/>'
        + '<br/>Log of process:<br/>'
        + debuglog;
        
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        String[] toAddresses = new String[] {a.CreatedBy.email};
        
        mail.setToAddresses(toAddresses);
        mail.setReplyTo('noreply@salesforce.com');
        mail.setSenderDisplayName('Salesforce Batch'); 
        mail.setSubject('Contract__c Batch job completed');
        mail.setPlainTextBody(emailMessage);
        mail.setHtmlBody(emailMessage);
        
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
    }

    static testmethod void testBatch_Contract()
    { 
        //Bypass Dupeblocker
        Util.IsTest(true);
        Test.startTest();
        
        String Query = 'SELECT Name, Account_Name__c, Id, Payer_Status__c, Latest_Contract__c, Earliest_Contract__c, Active_Contract_Idenfied__c, Membership_Status__c, Membership_Status_Text__c ' + 
            'FROM Membership__c WHERE Membership_Status_Text__c = null LIMIT 200';
        
        System.debug('### Test Batch Query String: ' + query);
    
        Batch_Contract_Temp batch = new Batch_Contract_Temp();
        batch.Query = query;
    
        Id batchId = Database.executeBatch(batch);
        
        system.assertNotEquals(null, batchId);
               
        System.debug('### Launched Batch : '+batchId);
        
        Test.stopTest();
    }
}