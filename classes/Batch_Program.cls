global class Batch_Program implements Database.Batchable<SObject>, Database.Stateful
{
	/*
	Purpose: 	Update the Program Name
					If the Program formal Name is not null
						Name = Program Acronym - Program Formal Name
					else
						Name = Program Acronym
	
	Create By: 		
	
	Last Modified By: 	Jeffery Sun - 8/13/2015
	
	Current Version: 	v1.1
	
	Revision Log:		v1.0 - (NB) Created code
						v1.1 - (NB-2011-01-28) Added header and code comments
						v1.2 - (JS-2015-08-13) Move unit test to TestBatch_Program
	*/
	
	String debuglog = '\n';
	Integer batchnum = 0;
	Integer totalprocessed = 0;
	public string Query = null;
	
	// Constructor
	global Batch_Program()
	{
		if(Query == null)
		{
			Query = 'select id, Program_Acronym__c, Program_Formal_Name__c from Program__c';
		}
	}
	
	// Start(Database.BatchableContext) method from Database.Batchable class
	global Database.queryLocator start(Database.BatchableContext ctx)
	{
		AsyncApexJob a = [SELECT id, ApexClassId, JobItemsProcessed, TotalJobItems, NumberOfErrors,  CreatedBy.Email 
            FROM AsyncApexJob 
            WHERE id = :ctx.getJobId()];
        
        // Send email to indicate the start of this batch
        String emailMessage = 'Your batch job \"Update Program\" has been started.  Start Time: ' + system.now();
		Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
		String[] toAddresses = new String[] {a.createdBy.email};
		mail.setToAddresses(toAddresses);
		mail.setReplyTo('noreply@salesforce.com');
		mail.setSenderDisplayName('ABC Salesforce batch'); 
		mail.setSubject('Batch Program job started');
		mail.setPlainTextBody(emailMessage);
		
		Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
		
		return Database.getQueryLocator(Query);
	}
	
	// Execute(Database.BatchableContext, list<Sobject>) method from Database.Batchable class
	global void execute(Database.BatchableContext ctx, list<Sobject> scope)
	{
		// Convert the query of Sobjects into a List of Programs
		list<Program__c> recordlist = (list<Program__c>)scope;
		
		// Loop through all Programs
		for (Program__c n : recordlist)
		{
			// If the Program formal Name is not null, set the Name = Program Acronym - Program Formal Name
			if (n.Program_Formal_Name__c != null)
				n.Name = n.Program_Acronym__c + ' - ' + n.Program_Formal_Name__c;
			else // Otherwise set the Name = Program Acronym
				n.Name = n.Program_Acronym__c;
			
			// Increment records processed
			totalprocessed++;
		}
		
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
          'Your batch job \"Update Programs\" has finished.  It processed ' + totalprocessed + ' records in ' 
        + a.totalJobItems +
        ' batches.  Of which, ' 
        + a.jobitemsprocessed 
        + ' processed without any exceptions thrown and ' 
        + a.numberOfErrors 
        + ' batches threw unhandled exceptions.<br/><br/>'
        + '<br/>Log of process:<br/>'
        + debuglog;
		
		Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
		String[] toAddresses = new String[] {a.createdBy.email};
		mail.setToAddresses(toAddresses);
		mail.setReplyTo('noreply@salesforce.com');
		mail.setSenderDisplayName('Salesforce Batch'); 
		mail.setSubject('Program Batch job completed');
		mail.setPlainTextBody(emailMessage);
		mail.setHtmlBody(emailMessage);
		
		Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
	}
}