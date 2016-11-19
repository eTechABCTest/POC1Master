/**
 *  Purpose: 	Create new Invoice Billing Shed and Associte it with the Contract ABC record
 *    			Role of this class is to populate the Institute field on Invoice Billing Shed screen 
 *   			and populate the Invoice Billing Shed field of Contract ABC record with this invoice billing record Id.
 *  			
 *  Create By:	Simplyforce - Bhavi - 10/02/2011 - CR-20110926-112
 * 
 *  Revision Log:	v1.0 - (Bhavi-10/02/2011) Created code.
 * 					v1.1 - Modified By - Mahendra Swarnkar - CR-20160113-9513 - 4/1/2016 - updated the "save()" method 
 * 					       to populate the default value for Division field on the basis of business line value on the 
 * 						   program associated with the contract ABC
 *                      
*/
public with sharing class AssociateContractABCWithInvoiceBilling {
   
    //variable to hold the Invoice billing information
    public Invoice_Billing_Schedule__c invoiceBillingShed{get;set;}
    
    //constructor with standard controller
    public AssociateContractABCWithInvoiceBilling(ApexPages.StandardController controller) {
    	
    	//intialize the new invoice billing record
    	invoiceBillingShed = (Invoice_Billing_Schedule__c)controller.getRecord();
    	
    	//get the Account Payer Id from URL and populate the Institute field of Invoice Billing
    	invoiceBillingShed.Institution__c = ApexPages.currentPage().getParameters().get('accountPayerId');
    }
    
    //override the save method
    public PageReference save(){
    	
    	//create a savepoint to rollback the transaction in case of unexpected error
    	SavePoint sp = Database.setSavePoint();
    	
    	try{
    		
    		//Get the Contract ABC id from URL and update contract ABC's  Invoice Billing Schedule record with invoice billing record id
    		String contractABCId = ApexPages.currentPage().getParameters().get('contractABCId');
    		
    		//Modified by - Mahendra Swarnkar - CR-20160113-9513 - 4/1/2016 - starts from here
    		//List to holds the contract ABC records
    		List<Contract__c> contractABC = new List<Contract__c>();
    		
    		//Check for the Id
    		if(contractABCId != null && contractABCId != ''){
    			
    			//Fethc the contract ABC record and then check 
    			// 1) If Business Line on the Program object equals CLN, then on IBS the default value of Division  = CLN.
    			// 2) If Business Line = SW, then on IBS the default value of Division = SW.
    			contractABC = [SELECT Id, Program__r.Business_line__c , Invoice_Billing_Schedule__c FROM Contract__c WHERE Id =: contractABCId];
    			
    			//Check for business line on the Program and populate Division on the IBS accordingly
    			if(contractABC.size()>0  && contractABC[0].Program__c != null 
    				&& String.isNotBlank(contractABC[0].Program__r.Business_line__c)){
    				
    				if(contractABC[0].Program__r.Business_line__c == 'CLN')
    					invoiceBillingShed.Division__c = 'CLN';
    				else {
    					if(contractABC[0].Program__r.Business_line__c == 'SW')
    						invoiceBillingShed.Division__c = 'SW';
    					else
    					    invoiceBillingShed.Division__c = 'ABC Corporate';
    				}
    			}	
    		}
    		//Modified by - Mahendra Swarnkar - CR-20160113-9513 - 4/1/2016 - Ends here
    		
    		//insert the invoice billing record 
    		insert invoiceBillingShed;
    		
    		//Modified by - Mahendra Swarnkar - CR-20160113-9513 - 4/1/2016 - starts from here
    		//Check for size
    		if(contractABC.size() > 0){
    			
    			//Associate the Contract record with newly created IBS by populating Invoice Billing Schedule field on the Contract ABC
    			contractABC[0].Invoice_Billing_Schedule__c = invoiceBillingShed.Id;
    			 
    			//Update the Contract record
    			update contractABC;
    			
    			//redirect back to the contract ABC detail page from where button "Created Invoice Billing Shed" was clicked
    			return new PageReference('/' + contractABC[0].Id);
    		} 
    		//Modified by - Mahendra Swarnkar - CR-20160113-9513 - 4/1/2016 - Ends here
    		else {
    			
    			//add message that contractABC record not found, Data will not be saved
    			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'Contract ABC record not found, Data will not be committed.'));
    		}
    	} catch(Exception e) {
    		
    		//roll back the complete transaction
    		Database.rollback(sp);
    		
    		//add error on page
    		ApexPages.addMessages(e);
    	}
    	
    	//return to the same page to see the error
    	return null;
    }
}