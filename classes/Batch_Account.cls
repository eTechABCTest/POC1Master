global class Batch_Account implements Database.Batchable<SObject>, Database.Stateful
{
	/*
	Purpose: 	Batch to update Accounts in place, doing the work of triggers that will maintain field values.
		
					Name:	Set Name to standard naming convention
					EA_AE__c:
					EA_Contact__c:
					Account_Restriction_Status__c:
					BI_Memberships__c
						sum of Renewal_Unit_Count__c on Memberships on Account where Membership__r.Program__r.Business_Line__c = 'PT'
					Core_Memberships__c:
						sum of Renewal_Unit_Count__c on Memberships on Account where Membership__r.Program__r.Business_Line__c = 'RI'
					Academies_Memberships__c
						sum of Renewal_Unit_Count__c on Memberships on Account where Membership__r.Program__r.Business_Line__c = 'TD'
					Hworks_Memberships__c: 
						sum of Renewal_Unit_Count__c on Memberships on Account where Membership__r.Program__r.Business_Line__c = 'CM'
					
					
	Create By: 	Jeremy Nottingham (SAP) 11/2010		
	
	Last Modified By: 	Jeffery Sun - 8/13/2015
	
	Current Version: 	v1.3
	
	Revision Log:		v1.0 - (NB) Created code
						v1.1 - (NB-2011-01-28) Added header and code comments
						v1.2 - (JN 2/1/2011) Completed and clarified header, including Memberships fields
						v1.3 - (JS 8/13/2015) Move unit test to TestBatch_Account
	*/
	
	String debuglog = '\n';
	Integer batchnum = 0;
	Integer totalprocessed = 0;
	map<Id, Id> userid2contactidmap = new map<id, id>();
	public String Query = null;
	
	// Constructor
	global Batch_Account()
	{
		List<Contact> contacts = [select id, Employee_User_Record__c  from Contact where Employee_User_Record__c != null];
		for (Contact c : contacts) {
			userid2contactidmap.put(c.Employee_User_Record__c, c.Id); 
		}
		
		if(Query == null)
		{
			// Query to store the Accounts that will be returned to the Start(Database.BatchableContext) method
			Query = 'select id, Name, EA_AE__c, Account_Formal_Name__c, Primary_State_Province__c, Primary_City__c,' 
				+ ' Account_Restriction_Status__c, BI_Memberships__c, Academies_Memberships__c, Hworks_Memberships__c,'
				+ ' (select id, userid from AccountTeamMembers where TeamMemberRole = \'AE or EA\'),'
				+ ' (select id, Restriction__r.Category__c from Restrictions_MtM__r '
				+ ' where Restriction__c != null and Restriction__r.Category__c != null and Restriction__r.Status__c != \'Retired\'),'
				+ ' (select id, Program__r.Business_Line__c, Renewal_Unit_Count__c from Memberships__r '
				+ ' where Membership_Status__c like \'Member%\' and  Program__r.Business_Line__c in (\'CM\', \'TD\', \'RI\', \'PT\') )	'
				+ ' from Account'; // limit 1 (Nathan B. 1/4/2011 Removed Limit)
		}           
	}
	
	// Start(Database.BatchableContext) method of the Database.Batchable class
	global Database.queryLocator start(Database.BatchableContext ctx)
	{
		AsyncApexJob a = [SELECT id, ApexClassId, JobItemsProcessed, TotalJobItems, NumberOfErrors,  CreatedBy.Email 
            FROM AsyncApexJob 
            WHERE id = :ctx.getJobId()];
        
        // Send an email indicating the start of the batch
        String emailMessage = 'Your batch job \"Update Account\" has been started.  Start Time: ' + system.now();
			
		Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
		String[] toAddresses = new String[] {a.CreatedBy.email};
		
		mail.setToAddresses(toAddresses);
		mail.setReplyTo('noreply@salesforce.com');
		mail.setSenderDisplayName('ABC Salesforce batch'); 
		mail.setSubject('Batch Account job started');
		mail.setPlainTextBody(emailMessage);
		
		Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
		
		// Return the queried results to the execute method
		return Database.getQueryLocator(Query);
	}
	
	// Execute(Database.BatchableContext, list<Sobject>) method of the Database.Batchable class
	global void execute(Database.BatchableContext ctx, list<Sobject> scope)
	{
		Util.IsBatch = true;
		
		// Convert the queried records into a list of Accounts
		list<Account> recordlist = (list<Account>)scope;
		
		// Loop through all Accounts from the query
		for (Account a : recordlist)
		{
			totalprocessed++;
			debuglog += '<br/> a ' + a.id + ' size ' + a.Memberships__r.size();
			
			try
			{
				//Set standard name = left(([Account Formal Name] - [City] - [State]), 80)
				String accname;
					
				if (a.Account_Formal_Name__c != null)
					accname = a.Account_Formal_Name__c;
				else
					accname = 'No Account Name';
					
				if (a.Primary_City__c != null)
					accname += ' - ' + a.Primary_City__c;
				if (a.Primary_State_Province__c != null)
					accname += ' - ' + a.Primary_State_Province__c;
					
	            //truncate if too long for the field
	            a.Name = accname.substring(0,Math.min(accname.length(), Account.Name.getDescribe().getLength()));
	            
	            //Set EA/AE and EA Contact
				a.EA_AE__c = null;
				for (AccountTeamMember atm : a.AccountTeamMembers)
				{
					a.EA_AE__c = atm.userid;
				}
				
				if (a.EA_AE__c != null)
				{
					if (userid2contactidmap.keyset().contains(a.EA_AE__c))
						a.EA_Contact__c = userid2contactidmap.get(a.EA_AE__c);
				}
				
				//set Account Restriction Status based on Restrictions_MtM on Account
				a.Account_Restriction_Status__c = null;
				
				for (Restricted_MtM__c rmtm : a.Restrictions_MtM__r)
				{
					a.Account_Restriction_Status__c = rmtm.Restriction__r.Category__c;
					
					if (rmtm.Restriction__r.Category__c == 'Restricted: Permission Required')
						break;
				}
				
				//count the three different kinds of Memberships by Account
                a.Core_Memberships__c = 0;
                a.BI_Memberships__c = 0;
                a.Academies_Memberships__c = 0;
                a.Hworks_Memberships__c = 0;
                
                // Loop through related Memberships on this Account
                for (Membership__c mem : a.Memberships__r)
                {
                	debuglog += '<br/>146 mem ' + mem.Program__r.Business_Line__c;
                	
                    // Get Sums of Renewal Unit Count and return to account                        
                    if (mem.Program__r.Business_Line__c == 'PT')
                    	a.BI_Memberships__c += mem.Renewal_Unit_Count__c;
                    else if (mem.Program__r.Business_Line__c == 'RI')
                    	a.Core_Memberships__c += mem.Renewal_Unit_Count__c;
                    else if (mem.Program__r.Business_Line__c == 'TD')
                    	a.Academies_Memberships__c += mem.Renewal_Unit_Count__c;
                    else if (mem.Program__r.Business_Line__c == 'CM')
                    	a.Hworks_Memberships__c += mem.Renewal_Unit_Count__c;
                }
			}
			catch (Exception e)
			{
				debuglog += '<br/>' + e.getMessage();
			}
		}
		
		// Update Accounts
		try
		{
			update recordlist;
		}
		catch (Exception e)
		{
			debuglog += '<br/>Update failed: ' + e.getMessage();
		}
		
		Util.IsBatch = false;
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
		
		// Send an email indicating the completion of the batch
		String emailMessage = 
          'Your batch job \"Update Accounts\" has finished.  It processed ' + totalprocessed + ' records in ' 
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
		mail.setSubject('Account Batch job completed');
		mail.setPlainTextBody(emailMessage);
		mail.setHtmlBody(emailMessage);
		
		Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
	}
}