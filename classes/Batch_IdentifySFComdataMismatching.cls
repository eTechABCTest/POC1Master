/**
 * 	Purpose			:	This class is to Match the Credit Card values in SFDC and Comdata and if there is diccrepncies, highlight them
 * 
 * 	Created By		:	Bhavi Sharma
 * 
 * 	Created Date	:	05/19/2015	
 * 
 * 	Revision Logs	:	V_1.0 - Created
 *
 **/ 
global class Batch_IdentifySFComdataMismatching implements Database.Batchable<SObject>, Database.AllowsCallouts, Database.Stateful {
    
    //Debug Log
    global String debugLog;
    
    //Start Method
    global Database.Querylocator start(Database.BatchableContext BC) {
        
        //Set default
        debugLog = '';
        
        //Query all the Creddit card records
        return Database.getQueryLocator([SELECT Status__c, 
        										Comdata_Status__c,
                                                Card_Employee_Number__c, 
                                                Original_Request__c, 
                                                Card_Deactivation_Status__c, 
                                                Payment_Account__c,
                                                Credit_Card_Number__c,
                                                Payment_Account__r.Portfolio_Owner_Finance_Code__c,
                                                Payment_Account__r.Card_Holder__c,
                                                Payment_Account__r.Billing_Address_Line_1__c, 
                                                Payment_Account__r.Billing_Address_Line_2__c, 
                                                Payment_Account__r.Billing_Address_City__c, 
                                                Payment_Account__r.Billing_Address_State__c, 
                                                Payment_Account__r.Billing_Address_PostalCode__c, 
                                                Payment_Account__r.Billing_Address_Attention_To__c, 
                                                Payment_Account__r.First_Name_On_Card__c, 
                                                Payment_Account__r.Last_Name_On_Card__c,
                                                Payment_Account__r.Advisory_Profile__r.Over_aging_Warning_days__c,
                                         		Payment_Account__r.Oldest_Transaction__c,
                                         		Payment_Account__r.Final_warning_Aging__c,
                                                Payment_Account__r.Utilized_Balance__c,
                                                Payment_Account__r.Final_warning_Balance__c,
                                                Payment_Account__r.Deactivation_Reason__c
                                                FROM Credit_Card__c]);
    }
    
    //Process credit card records and match the status
    //Execute method
    global void execute(Database.BatchableContext BC, List<Credit_Card__c> creditCards) {
        
        //Credit Card to be update
        List<Credit_Card__c> cardsToBeUpdate = new List<Credit_Card__c>();
        
        //Loop through scope list
        for(Credit_Card__c creditCard : creditCards) {

            try {
                
                //Inquire Card
                HTTPResponseParser.InquireCardResponse inquireCardResponse = CreditCardService.inquireCreditCard(creditCard, false);
                
                //Match teh COmadata status with the Credit Card Status
                if(inquireCardResponse != null 
	                && inquireCardResponse.cardDetails != null 
	                && String.isNotBlank(inquireCardResponse.cardDetails.cardStatus)) {
                	
                	//Populate comdata status
                	if(creditCard.Comdata_Status__c != inquireCardResponse.cardDetails.cardStatus) {
                		
                		//Update the field comdata status
                		creditCard.Comdata_Status__c = inquireCardResponse.cardDetails.cardStatus;
                		cardsToBeUpdate.add(creditCard);
                	}
                }
            } catch(Exception e) {
                
                //Assign new value to Credit Card's field Over Credit Limit Completed and add Card into list
                System.debug('Exception is :::::' + e.getMessage());
            }
        }

        //Check for size of list
        if(cardsToBeUpdate.size() > 0) {

            //Allow partial update
            Database.SaveResult[] results = database.update(cardsToBeUpdate, false);

            //Create log
            debugLog += Util.createLog(results);
        }
	}
    
    // Finish method
    global void finish(Database.BatchableContext BC) {

        //Check if any error occured and then send the email
        if(debugLog != '') {

            //Send batch status to the person who executed this batch
            Util.sendBatchStatus(BC.getJobId(), 'Batch_IdentifySFComdataMismatching', debugLog);
        }
    }
}