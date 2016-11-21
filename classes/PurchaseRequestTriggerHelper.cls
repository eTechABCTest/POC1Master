/*
	Purpose: 		find all budget approvers and send them an email notifying 
					them of the new purchase request waiting to be submitted for approval
	
	Created By:		Victor Hanson
	
	Created Date:	8/29/13
	
	Revision Log:	V_1.0: Created
*/
public with sharing class PurchaseRequestTriggerHelper {
	
	// require comments when an approval is rejected
	public static void RequireCommentsForAppRejection(List<Purchase_Request__c> triggerNew) {
    	// map to hold accounts with approval requests in process
    	Map<Id, Purchase_Request__c> purchReqMap = new Map<Id, Purchase_Request__c>();
    	for (Purchase_Request__c purchRequest : triggerNew) {
			if (purchRequest.Approval_Comment_Check__c == 'Requested') {
				purchReqMap.put(purchRequest.Id, purchRequest);
		      	// Reset the field value to null, 
				// so that the check is not repeated,
				// next time the object is updated
				purchRequest.Approval_Comment_Check__c = null; 
    		}
    	}
    	
    	if (!purchReqMap.isEmpty()) {
    		// Get the last approval process step for the approval processes, 
			// and check the comments.
			for (ProcessInstance pi : [SELECT TargetObjectId, 
			                            (SELECT Id, StepStatus, Comments FROM Steps WHERE StepStatus = 'Rejected' ORDER BY CreatedDate DESC LIMIT 1 )
			                           FROM ProcessInstance
			                           WHERE TargetObjectId In :purchReqMap.keySet()
			                           AND Id IN (SELECT ProcessInstanceId FROM ProcessInstanceStep WHERE StepStatus = 'Rejected')
			                           ORDER BY CreatedDate DESC LIMIT 1])
			{ 
				system.debug('@@Status:' + pi.Steps[0].StepStatus + '  Comments:' + pi.Steps[0].Comments);
				// If no comment exists, then prevent the object from saving.                 
				if ((pi.Steps[0].Comments == null || 
					pi.Steps[0].Comments.trim().length() == 0))
				{
					purchReqMap.get(pi.TargetObjectId).addError('Please provide a reason for your rejection.');
				}
			}
		}
    }
    
    // find all budget approvers and send them an email notifying 
	// them of the new purchase request waiting to be submitted for approval
	public static list<Messaging.SingleEmailMessage> NotifyBudgetApprovers(List<Purchase_Request__c> triggerNew) {
		
		// create a list of emails to return
    	list<Messaging.SingleEmailMessage> sentEmails = new list<Messaging.SingleEmailMessage>();
		
		// only send the email if the record was inserted on a one-off basis
		// we wouldn't want to send out thousands of emails if there is a dataload
    	if (triggerNew.size() > 1) return sentEmails;
    	
    	// get purchase request details so we can populate the text based email properly
    	List<Purchase_Request__c> pRequests = [SELECT Id, Department__c, Vendor__r.Name, Type_of_Purchase__c, 
    										   Submitted_By__r.FirstName, Submitted_By__r.LastName
    										   FROM Purchase_Request__c WHERE Id IN :triggerNew];
    	
		// go through each PR and get all budget approvers that need to be notified
		for (Purchase_Request__c purchaseRequest : pRequests) {
    		List<Department__c> departments = [SELECT Id, Budget_Manager__r.Email, Budget_Manager__c, Budget_Manager__r.Employee_Id__c
    											  FROM Department__c 
    											  WHERE Name = :purchaseRequest.Department__c];
    		
    		List<String> toAddresses = new List<String>();
    		if (departments.size() > 0 && departments[0].Budget_Manager__c != null) {
    			
    			// get all the ToAddresses
	    		for (Department__c department : departments) toAddresses.add(department.Budget_Manager__r.Email);
	    		
	    		String typeOfPurchase = '';
	    		if (purchaseRequest.Type_of_Purchase__c != null) typeOfPurchase = purchaseRequest.Type_of_Purchase__c.replace(';', ', ');
	    		
	    		String bodyText = 'An initial purchase or contract request for ' + typeOfPurchase + ' from ' + 
	    						   purchaseRequest.Vendor__r.Name + ' has been submitted by ' + 
	    						   purchaseRequest.Submitted_By__r.FirstName + ' ' + purchaseRequest.Submitted_By__r.LastName + 
	    						   ' for your completion.  Please review the request, attach budget information, and then submit it for ' +
	    						   'approval.  For information on completing your purchase request, please visit the Purchasing Portal at ' +
	    						   'http://portals.advisory.com/purchasing. <br> <br> ' +
	    						   'Purchase/Contract Request: ' + URL.getSalesforceBaseUrl().toExternalForm() + '/' + purchaseRequest.id;
	    		
	    		// create the email
	    		Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
	    		email.setToAddresses(toAddresses);
			    email.setSubject('A new Purchase Request is ready for review');
			    email.setPlainTextBody(bodyText.replaceAll('<br>', '\r\n'));
			    email.setHTMLBody(bodyText);
			    email.setSaveAsActivity(false);
			    
			    // add email to list
			    sentEmails.add(email);
			    
			    // send email
			    Messaging.sendEmail(new Messaging.SingleEmailMessage[] { email });
    		}
		}
		
		// return the sent emails
		return sentEmails;
	}
}