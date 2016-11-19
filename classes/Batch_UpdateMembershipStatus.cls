/**
  *  Purpose		:    Perform the following actions:
  *                  Retrieve all the membership records where Membership records is in future
  *                  and update these records to keep the Membership_Status_Text__c up to date
  *                  
  *  Create By   :   Simplyforce Technology
  *  
  *  Created Date:   06/21/2012
  *  
  *  Revision Log:	v1.0 - Created
  *  				
 **/
global class Batch_UpdateMembershipStatus implements Database.Batchable<SObject> {
	
	//Override Start method
	global Database.queryLocator start(Database.BatchableContext ctx) {
		
		// Query all Memberships with Future status
        return Database.getQueryLocator([Select Id from Membership__c where Membership_Status_Text__c =: Constants.PROSPECT_PENDING_FUTURE_START 
        																OR Membership_Status_Text__c =: Constants.PROSPECT_PENDING_FUTURE_START_DATE]);	
	}
	
	//Override execute method
	global void execute(Database.BatchableContext ctx, list<Sobject> scope) {
		
		//Update the membership records so the trigger will be get fired and Update the membership status accordingly
		update 	(List<Membership__c>)scope;
	}
	
	 // Override Finish method
    global void finish(Database.BatchableContext ctx) {
    
    	AsyncApexJob a = [SELECT id, ApexClassId, JobItemsProcessed, TotalJobItems, NumberOfErrors, CreatedBy.Email FROM AsyncApexJob 
							WHERE id = :ctx.getJobId()];
        
        // Send email to confirm completion of this batch
        String emailMessage = 
          'Your batch job \"Batch_UpdateMembershipStatus\" has finished.  It processed '  
        + a.TotalJobItems +
        ' batches.  Of which, ' 
        + a.JobItemsProcessed 
        + ' processed without any exceptions thrown and ' 
        + a.NumberOfErrors 
        + ' batches threw unhandled exceptions.';
        
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        String[] toAddresses = new String[] {a.CreatedBy.email};
        
        mail.setToAddresses(toAddresses);
        mail.setReplyTo('noreply@salesforce.com');
        mail.setSenderDisplayName('Salesforce Batch'); 
        mail.setSubject('Batch_UpdateMembershipStatus Batch job completed');
        mail.setPlainTextBody(emailMessage);
        mail.setHtmlBody(emailMessage);
        
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
    }
    
}