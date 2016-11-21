global class Batch_Contact implements Database.Batchable<SObject>, Database.Stateful
{
	/*
	Purpose: 	Set the Contact Restriction Status based on associated Restrictions and Account Restrictions.
	
	Create By: 	Jeremy Nottingham (SAP) 12/10	
	
	Last Modified By: 	Jeremy Nottingham (SAP) - 2/23/2011
	
	Current Version: 	v1.1
	
	Revision Log:		v1.0 - () Created code
						v1.1 - (NB-2011-01-28) Added header, code comments, and reviewed code coverage
						v1.2 - JN (2/23/11) Corrected typo. All instances now say "Restricted: Permission Required"
	*/
	
	String debuglog = '\n';
	Integer batchnum = 0;
	Integer totalprocessed = 0;
	map<String, Id> rtmap = Util.recordtypemap('Contact');
	public String Query = null;
	
	// Constructor
	global Batch_Contact()
	{
		if(Query == null)
		{
			Query = 'select id, Account.Account_Restriction_Status__c, Contact_Restriction_Status__c, ' +
			'(select Restriction__r.Category__c from Restrictions_MtM__r where Restriction__r.Status__c != \'Retired\') ' + 
			'from Contact';
		}
	}
	
	// Start(Database.BatchableContext) method from Database.Batchable class
	global Database.queryLocator start(Database.BatchableContext ctx)
	{
		AsyncApexJob a = [SELECT id, ApexClassId, JobItemsProcessed, TotalJobItems, NumberOfErrors,  CreatedBy.Email 
            FROM AsyncApexJob 
            WHERE id = :ctx.getJobId()];
        
        // Send email indicating the start of this batch
        String emailMessage = 'Your batch job \"Update Contact\" has been started.  Start Time: ' + system.now();
		
		Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
		String[] toAddresses = new String[] {a.createdBy.email};
		
		mail.setToAddresses(toAddresses);
		mail.setReplyTo('noreply@salesforce.com');
		mail.setSenderDisplayName('ABC Salesforce batch'); 
		mail.setSubject('Batch Contact job started');
		mail.setPlainTextBody(emailMessage);
		
		//Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
		
		// Query all contacts w/ related Restrictions where the Status is not 'Retired'
		return Database.getQueryLocator(Query);
	}
	
	// Execute(Database.BatchableContext, list<Sobject>) method from Database.Batchable class
	global void execute(Database.BatchableContext ctx, list<Sobject> scope)
	{
		Util.IsBatch = true;
		
		// Convert the Contacts returned from the getQueryLocator to a list of Contacts 
		list<Contact> recordlist = (list<Contact>)scope;
		
		// Loop through all Contacts
		for (Contact c : recordlist)
		{
			// Increment the number of records processed to return to our completion email
			totalprocessed++;
			
			// If the Contact's Account Restriction Status equals null then process
			if (c.Account.Account_Restriction_Status__c == null)
			{
				for (Restricted_MtM__c rmtm : c.Restrictions_MtM__r)
				{
					if (rmtm.Restriction__r.Category__c == 'Critical Background Information')
						c.Contact_Restriction_Status__c = 'Critical Background Information';
						
					if (rmtm.Restriction__r.Category__c == 'Restricted: Permission Required')
					{
						c.Contact_Restriction_Status__c = 'Restricted: Permission Required';
						break;
					}
				}
			}// If the Contact's Account Restriction Status equals 'Restriction - Permission Required' then set the Contact Restriction Status
			else if (c.Account.Account_Restriction_Status__c == 'Restricted: Permission Required')
				c.Contact_Restriction_Status__c = 'Account - Restricted: Permission Required';
			else
			{// If the Contact's Account Restriction Status is not null and not equal 'Restriction - Permission Required' then set the Contact Restriction Status from the Account
				c.Contact_Restriction_Status__c = 'Account - Critical Background Information';
				
				// Loop through Restriction MtM associated w/ this Contact
				for (Restricted_MtM__c rmtm : c.Restrictions_MtM__r)
				{
					// If the Restriction MtM Catagory is Info Alert, set the Contact Restriction Status
					if (rmtm.Restriction__r.Category__c == 'Critical Background Information') 
						c.Contact_Restriction_Status__c = 'Account - Critical Background Information';
					if (rmtm.Restriction__r.Category__c == 'Restricted: Permission Required') // If the Restriction MtM Catagory is a higher restriction, set the Contact Restriction Status and stop processing
					{
						c.Contact_Restriction_Status__c = 'Restricted: Permission Required';
						break;
					}
				}
			}
			
		}
		
		// Update all Contacts
		try
		{
			update recordlist;
		}
		catch (Exception e)
		{
			// Add errors to a debuglog that will be emailed in the completion email
			debuglog += e.getMessage();
		}
	}
	
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
          'Your batch job \"Update Contacts\" has finished.  It processed ' + totalprocessed + ' records in ' 
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
		mail.setSubject('Contact Batch job Completed');
		mail.setPlainTextBody(emailMessage);
		mail.setHtmlBody(emailMessage);
		
		Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
	}
	
	static testMethod void testBatch_Contact()
	{
		Test.startTest();
		
		string query = 'select id, Account.Account_Restriction_Status__c, Contact_Restriction_Status__c, ' +
			'(select Restriction__r.Category__c from Restrictions_MtM__r where Restriction__r.Status__c != \'Retired\') ' + 
			'from Contact limit 200';
		
		System.debug('### Test Batch Query String: ' + query);
	
		Batch_Contact batch = new Batch_Contact();
		batch.Query = query;
	
	    Id batchId = Database.executeBatch(batch);
	    
	    system.assertNotEquals(null, batchId);
	           
	    System.debug('### Launched Batch : '+batchId);
	    
	    Test.stopTest();
	}
}