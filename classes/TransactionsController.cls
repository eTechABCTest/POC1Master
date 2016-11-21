/** 
 *	Purpose			:	Controller class for Transaction page
 *
 *	Created By		:	Bhavi Sharma
 *
 *	Created Date	:	12/06/2014
 *
 *	Revision Logs	:	V_1.0 - Created
 *
 **/ 
public with sharing class TransactionsController {
	
	//Properties
	Id recordId;
	public String noOfDays {get; set;}
    public List<HTTPResponseParser.RTTransactionRecord> transactionRecords {get; set;}
	ApexPages.StandardController stdController;
	
	//Constructor
	public TransactionsController(ApexPages.StandardController controller) {
		
		//Get record Id
		recordId = controller.getId();
		stdController = controller;
    }
	
	/**
	 * 	@description	:	This method is to pull the transactions from Comdata
	 * 
	 * 	@args			:	
	 * 
	 * 	@return			:	void
	 * 
	 **/
	public void refreshTransactions() {
		
		List<HTTPResponseParser.RtTransactionResponse> listRtTransactionResponse = new List<HTTPResponseParser.RtTransactionResponse>();
		transactionRecords = new List<HTTPResponseParser.RTTransactionRecord>();
	
		//Check for the object Type
		if(recordId.getSobjectType() == Schema.Portfolio__c.SObjectType) {
			
			listRtTransactionResponse = CreditCardService.realTimeTransactionHistory(recordId, Integer.valueOf(noOfDays));
		} else if(recordId.getSobjectType() == Schema.Credit_Card__c.SObjectType) {
			
			//Get the credit card record
			Credit_Card__c creditCard = [Select Id, Credit_Card_Number__c from Credit_Card__c where Id =: recordId];
            listRtTransactionResponse = CreditCardService.realTimeTransactionHistory(new List<Credit_Card__c>{creditCard}, Integer.valueOf(noOfDays));
		}
		
		//Check for the size
		if(listRtTransactionResponse.size() > 0) {
            
            //Loop through the recponse list and add items in transactions list
            for(HTTPResponseParser.RtTransactionResponse rTTransactionResponse : listRtTransactionResponse){
                
                //Chekc if transaction records not null and blank
                if(rTTransactionResponse.transactionRecords != null && rTTransactionResponse.transactionRecords.size() > 0) {
                    
                    //Add in list
                    transactionRecords.addAll(rTTransactionResponse.transactionRecords);
                    System.debug('transactionRecords Size: '+ transactionRecords.size());
                    System.debug('rTTransactionResponse.transactionRecords Size: '+ rTTransactionResponse.transactionRecords.size());
                }	
            }
        }       
	}	 
}