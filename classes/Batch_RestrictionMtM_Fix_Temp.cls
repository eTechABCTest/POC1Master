global class Batch_RestrictionMtM_Fix_Temp implements Database.Batchable<SObject>, Database.Stateful {
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
    
    global Batch_RestrictionMtM_Fix_Temp()
    {
        if(Query == null)
        {
            Query = 'SELECT Id FROM Restricted_MtM__c WHERE Restriction__r.Status__c = \'Active\'';
        }
    }
    
    // Start(Database.BatchableContext) method from Database.Batchable class
    global Database.queryLocator start(Database.BatchableContext ctx)
    {
        AsyncApexJob a = [SELECT id, ApexClassId, JobItemsProcessed, TotalJobItems, NumberOfErrors,  CreatedBy.Email 
            FROM AsyncApexJob 
            WHERE id = :ctx.getJobId()];
        
        // Send email indicating the start of this batch
        String emailMessage = 'Your batch job \"Batch_RestrictionMtM_Fix_Temp\" has been started.  Start Time: ' + system.now();
            
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
        list<Restricted_MtM__c> recordlist = (list<Restricted_MtM__c>)scope;
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
          'Your batch job \"Batch_RestrictionMtM_Fix_Temp\" has finished.  It processed ' + totalprocessed + ' records in ' 
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

    static testmethod void testBatch_RestrictionMtM_Fix_Temp()
    { 
        //Bypass Dupeblocker
        Util.IsTest(true);
    	// create an institution and a contact
    	Account acct = TestUtilities.CreateNewAccount(true);
    	//Contact con = TestUtilities.CreateNewContact(acct, true);
    	
    	// bypass all trigger while we create a restriction and restriction mtm
    	Util.BypassAllTriggers = true;
    	Util.IsBatch = true;
    	Restrictions__c restriction = new Restrictions__c();
    	restriction.Category__c = 'Critical Background Information ';
    	restriction.Source_Department__c = 'TEST';
    	restriction.Expiration_Date__c = system.today().addDays(3);
    	insert restriction;
    	
    	List<Restricted_MtM__c> restrictionMtMList = new List<Restricted_MtM__c>();
    	Restricted_MtM__c restrictionMtM_Account = new Restricted_MtM__c();
    	restrictionMtM_Account.Account__c = acct.Id;
    	restrictionMtM_Account.Restriction__c = restriction.Id;
    	restrictionMtMList.add(restrictionMtM_Account);
    	
    	insert restrictionMtMList;
    	
    	// re-enable triggers
    	Util.BypassAllTriggers = false;
    	Util.IsBatch = false;
    	
        Test.startTest();
        
        String Query = 'SELECT Id FROM Restricted_MtM__c WHERE Restriction__r.Status__c = \'Active\' LIMIT 200';
        
        System.debug('### Test Batch Query String: ' + query);
    
        Batch_RestrictionMtM_Fix_Temp batch = new Batch_RestrictionMtM_Fix_Temp();
        batch.Query = query;
    
        Id batchId = Database.executeBatch(batch, 2);
        
        system.assertNotEquals(null, batchId);
               
        System.debug('### Launched Batch : '+batchId);
        
        Test.stopTest();
        
        // verify that the contact and account have the proper restriction status
        Acct = [SELECT Account_Restriction_Status__c FROM Account WHERE Id = :Acct.Id];
        system.assertEquals('Critical Background Information', Acct.Account_Restriction_Status__c);
    }
}