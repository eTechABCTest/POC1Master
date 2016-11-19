/**
 *  Purpose         :   This batch is to create the Credit card record in Comdata for the Replacemnet OSRs
 *
 *  Created By      :   Bhavi Sharma
 *
 *  Created Date    :   10/15/2013
 *
 *  Current Version :   This class is just a one time batch to update the Comdata Status value in Production 
 						after the CC Redegin deployment and then delete itin destructive changes
 *
 **/
global class Batch_UpdateCardsComdataStatus  implements Database.Batchable<SObject>, Database.Stateful, Database.AllowsCallouts {

	//Start method
    global Database.Querylocator start(Database.BatchableContext BC) {
        
        //Pick all the OSR where replacement or deactivation requested.
        return database.getQueryLocator([SELECT Id, Name,
					                        Card_Agreement_Signed__c,
					                        Card_Set_up_Status__c,
					                        Card_Owner__c,
					                        Card_Limit__c,
					                        Credit_Card_Number__c,
					                        Card_Number__c,
					                        Card_Vendor__c,
					                        Card_Expiration__c,
					                        Card_Status_Code__c,
					                        Card_Deactivation_Reason__c,
					                        Status__c, 
					                        Override_Card_Limit__c,
					                        Card_Holder_First_Name__c,
					                        Card_Holder_Last_Name__c,
					                        Card_Deactivation_Status__c,
					                        Card_Employee_Number__c,
					                        Max_Per_Transaction__c,
					                        Max_Per_Day__c,
					                        Max_Transactions_Per_Cycle__c,
					                        Max_Transactions_Per_Day__c,
					                        Age_Limit_Warning_Days__c,
					                        Max_Cycle_Amount__c,
					                        Product_Code__c,
					                        Cycle_Type__c,
					                        Open_Close_Flag__c,
					                        Product_Available_Flag__c,
					                        Payment_Account__c,
					                        Update_Billing_Address_On_Activation__c,
					                        Comdata_Status__c,
					                        Payment_Account__r.Portfolio_Owner_Finance_Code__c,
					                        Payment_Account__r.Portfolio_Owner__r.Birthdate,
					                        Payment_Account__r.Card_Count__c,
					                        Payment_Account__r.First_Name_On_Card__c,
					                        Payment_Account__r.Last_Name_On_Card__c,
					                        Payment_Account__r.Billing_Address_Attention_To__c,
					                        Payment_Account__r.Billing_Address_Line_1__c,
					                        Payment_Account__r.Billing_Address_Line_2__c,
					                        Payment_Account__r.Billing_Address_City__c,
					                        Payment_Account__r.Billing_Address_State__c,
					                        Payment_Account__r.Billing_Address_PostalCode__c,
					                        Original_Request__c,
					                        Original_Request__r.International_Address__c,
					                        Original_Request__r.Address_To_Name__c,
					                        Original_Request__r.Address_Line_1__c,
					                        Original_Request__r.Address_Line_2__c,
					                        Original_Request__r.Address_City__c,
					                        Original_Request__r.Address_State__c,
					                        Original_Request__r.Address_Postal_Code__c,
					                        Original_Request__r.Expedited_Processing_Approval__c,
					                        Original_Request__r.Request_Type__c
					                        FROM Credit_Card__c]);
    }

    //Execute method
    global void execute(Database.BatchableContext BC, List<Credit_Card__c> creditCards) {
    	
    	//List of Credit cards to update
    	List<Credit_Card__c> cCards = new List<Credit_Card__c>();
    	
    	//Loop through the credit cards
    	for( Credit_Card__c creditCard : creditCards) {
    	
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
	            		cCards.add(creditCard);
	            	}
	            }
	        } catch(Exception e) {
	        	System.debug(e.getMessage());
	        }
    	}
    	
    	if(cCards.size() > 0)
    		database.update(cCards, false);
    }
    
    // Finish method
    global void finish(Database.BatchableContext BC) {
    	
    }
}