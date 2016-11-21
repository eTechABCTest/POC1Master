/**
 *  Purpose         :   This class is used to update the OSR status to Denied, whenever User clicked on the "Deny Request" button on the OSR Detailed page. 
 *
 *  Created By      :   Mahendra Swarnakar
 *
 *  Created Date    :   10/26/2015
 *
 *  Revision Logs   :   V_1.0 - Created - CR-20150707-9062 - 10/26/2015 (Method UpdateOSRStatusToDeny)
 *
 **/ 
public with sharing class OSRDenyRequestController {
	
	//String to hold OSR ID
	public String oSRId {get;set;}
	
	//Constructor
    public OSRDenyRequestController(ApexPages.StandardController controller) {
    	
    	//Getting OSR ID from curent page URL
    	oSRId = Apexpages.currentPage().getParameters().get('id');    		
    }
    
    //Method update the OSR Status field to denied
	public Pagereference updateOSRStatusToDeny() {
		
		//Pagereference
		Pagereference pageRef;
		
		//Checking if URL is having OSR record ID with it or not
		if(!String.isBlank(oSRId)) {
			
			//List to hold OSR records
        	List<OSR__c> listOSR = [SELECT ID, Status__c FROM OSR__c where ID =: oSRId];
        	
        	//Checking list for null and size value
        	if(listOSR != null && listOSR.size() > 0) {
        			
    			//only proceed further if the status field value not equals to Denied
				if(listOSR[0].Status__c != CreditCardConstants.OSR_STATUS_DENIED) {
			    	
					//Processing OSR current instance and updating OSR status to Denied
		    		listOSR[0].Status__c = CreditCardConstants.OSR_STATUS_DENIED;	
		    	
			    	//Update OSR
			    	try {
			    	
			    		//Adding page message
			    		ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, CreditCardConstants.UPDATING_OSR_STATUS_TO_DENIED));
			    		
			    		//make a try to update the OSR record for status value
			    		update listOSR;
			    		
			    		//Constructing page reference to navigate back to OSR detail page
		    	 		pageRef = new Pagereference(CreditCardConstants.BACKSLASH_VAR + listOSR[0].ID);
		    	
				    	//Return pagereference
				    	return pageRef;
					    	
			    	} catch(Exception ex){
			    		
			    		//Adding page message
			    		ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ex.getMessage()));
			    		
			    		//Returning page reference as null
			    		pageRef = null;
			    		return pageRef;
			    	}
			    	
		    	} else {
		    		
		    		//Adding page message
			    	ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, CreditCardConstants.OSR_ALREADY_HAVING_DENIED_STATUS));
		    		
		    		//Returning page reference as null
	    	 		pageRef = null;
			    	return pageRef;
				}	
        	
        	} else {
        	
				//Adding message on the page that OSR record ID value should exists in the current page URL for status update
				ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, CreditCardConstants.NO_OSR_RECORD_FOUND));
				
				//Returning page reference as null
	    		pageRef = null;
	    		return pageRef;        	
			}	
    	} else {
    		
    		//Adding message on the page that OSR record ID value should exists in the current page URL for status update
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, CreditCardConstants.ID_ABSENCE_IN_URL));
			
			//Returning page reference as null
    		pageRef = null;
    		return pageRef; 
    	}
	}
}