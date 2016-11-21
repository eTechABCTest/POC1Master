global class Batch_WarmLead implements Database.Batchable<SObject>, Database.Stateful
{
	/*
	Purpose: 	Populate Owner from Marketer Assignment on Warm Lead
	
	Create By: 		
	
	Last Modified By: 	Jeffery Sun - 8/13/2015
	
	Current Version: 	v1.2
	
	Revision Log:		v1.0 - (NB) Created code
						v1.1 - (NB-2011-01-28) Added header and code comments
						v1.2 - (JS-2015-08-13) Move unit test to TestBatch_WarmLead
	*/
	
	String debuglog = '\n';
	Integer batchnum = 0;
	Integer totalprocessed = 0;
	public string Query = null;
	
	// Constructor
	global Batch_WarmLead()
	{
		if(Query == null)
		{
			Query = 'select id, OwnerId, Marketer_Assignment__c from Warm_Lead__c';
		}
	}
	
	// Start(Database.BatchableContext) method from Database.Batchable class
	global Database.queryLocator start(Database.BatchableContext ctx)
	{
		AsyncApexJob a = [SELECT id, ApexClassId, JobItemsProcessed, TotalJobItems, NumberOfErrors,  CreatedBy.Email 
            FROM AsyncApexJob 
            WHERE id = :ctx.getJobId()];
        
        // Send email to indicate the start of this batch
        String emailMessage = 'Your batch job \"Update Warm Lead Owners\" has been started.  Start Time: ' + system.now();
		Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
		String[] toAddresses = new String[] {a.CreatedBy.email};
		mail.setToAddresses(toAddresses);
		mail.setReplyTo('noreply@salesforce.com');
		mail.setSenderDisplayName('ABC Salesforce batch'); 
		mail.setSubject('Batch Warm Lead Owners job started');
		mail.setPlainTextBody(emailMessage);
		
		Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
		
		return Database.getQueryLocator(Query);
	}
	
	// Execute(Database.BatchableContext, list<Sobject>) method from Database.Batchable class
	global void execute(Database.BatchableContext ctx, list<Sobject> scope)
	{ 
		Util.IsBatch = true;
		list<Warm_Lead__c> recordlist = (list<Warm_Lead__c>)scope;
		
		for (Warm_Lead__c wl : recordlist)
		{
			totalprocessed++;
			
			// Set Owner as Marketer // Nathan B 1/5/11 - Added to set Warm Lead's Owner equal to the Warm Lead's Marketer
	        if(wl.Marketer_Assignment__c != null)
	        {
		        if(wl.OwnerId != wl.Marketer_Assignment__c)
					wl.OwnerId = wl.Marketer_Assignment__c;
	        }
		}
		
		// Update Warm Leads
		try
		{
			update recordlist;
		}
		catch (Exception e)
		{
			debuglog += e.getMessage();
		}
	}
	
	// Finish(Database.BatchableContext) method from Database.Batchable class
	global void finish(Database.BatchableContext ctx)
	{
		AsyncApexJob a = [SELECT id, ApexClassId, 
              JobItemsProcessed, 
              TotalJobItems, 
              NumberOfErrors, 
              CreatedBy.Email 
              FROM AsyncApexJob 
              WHERE id = :ctx.getJobId()];
		
		// Send email to confirm the completion of this batch
		String emailMessage = 
          'Your batch job \"Update Warm Lead Owners\" has finished.  It processed ' + totalprocessed + ' records in ' 
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
		mail.setSenderDisplayName('ABC Salesforce batch'); 
		mail.setSubject('Batch Warm Lead Owners job finished');
		mail.setPlainTextBody(emailMessage);
		
		Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
	}
}