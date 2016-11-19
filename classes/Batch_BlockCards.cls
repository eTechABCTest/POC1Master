/**
 *  Purpose         :   This class is deactivate all the active cards which are associated with Deactivated Portfolio
 * 
 *  Created By      :   Bhavi Sharma
 * 
 *  Created Date    :   12/03/2014
 * 
 *  Revision Logs   :   V_1.0 - Created 
 * 						V_1.1 - By Mahendra Swarnkar - CR-20150901-9211 -09/09/2015. 
 * 								Modified the start query and addded the else if condition to set the requestReason to 
 * 								CreditCardConstants.EMPLOYEE_NO_LONGER_EXISTS based on the Portfolio deactivation reason
 *						V_1.2 - 10/23/2015 - Bhavi Sharma - CR-20151019-9335 - Start method query updated to User Warning Type = Deactivate criteria
 								instead of Final Warning Aging date field
 * 								
 **/ 
global class Batch_BlockCards implements Database.Batchable<SObject>, Database.AllowsCallouts, Database.Stateful {
    
    //Debug Log
    global String debugLog;
    
    //Start Method
    global Database.Querylocator start(Database.BatchableContext BC) {
        
        //Set default
        debugLog = '';
        
        //Query all the Active Credit Card records associated with a deactivated portfolio
        return Database.getQueryLocator([SELECT Card_Vendor__c, 
                                                Card_Expiration__c, 
                                                Card_Status_Code__c, 
                                                Card_Deactivation_Reason__c, 
                                                Status__c, 
                                                Card_Holder_First_Name__c, 
                                                Card_Holder_Last_Name__c,
                                                Card_Set_up_Status__c, 
                                                Card_Employee_Number__c, 
                                                Original_Request__c, 
                                                Card_Deactivation_Status__c, 
                                                Payment_Account__c,
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
                                         		Payment_Account__r.Final_warning_Aging__c,
                                                Payment_Account__r.Utilized_Balance__c,
                                                Payment_Account__r.Final_warning_Balance__c,
                                                Payment_Account__r.Deactivation_Reason__c,
                                                Payment_Account__r.Warning_Type__c
                                                FROM Credit_Card__c 
                                                Where ( 
                                                        (
                                                            Payment_Account__r.Utilized_Balance__c > 100        //Over balance Deactivatation
                                                            AND Payment_Account__r.Deactivation_Reason__c =: CreditCardConstants.PORTFOLIO_DEACTIVATION_REASON_OVER_CREDIT_BALANNCE_LIMIT
                                                        )
                                                        OR
                                                        (
                                                            Payment_Account__r.Warning_Type__c =: CreditCardConstants.PORTFOLIO_WARNING_TYPE_DEACTIVATE
                                                            AND Payment_Account__r.Deactivation_Reason__c =: CreditCardConstants.PORTFOLIO_DEACTIVATION_REASON_OVER_AGE_LIMIT 
                                                        )
                                                        OR
                                                        (
                                                        	Payment_Account__r.Deactivation_Reason__c =: CreditCardConstants.PORTFOLIO_DEACTIVATION_REASON_OTHER
                                                            OR Payment_Account__r.Deactivation_Reason__c =: CreditCardConstants.EMPLOYEE_NO_LONGER_EXISTS
                                                            OR Payment_Account__r.Deactivation_Reason__c =: CreditCardConstants.EMPLOYEE_NOT_FOUND_IN_COMDATA
                                                        	OR Payment_Account__r.Deactivation_Reason__c = null
                                                        )
                                                    )
                                                    AND Payment_Account__r.Status__c =: CreditCardConstants.PORTFOLIO_STATUS_DEACTIVATED 
                                                    AND Status__c =: CreditCardConstants.CC_STATUS_ACTIVE
                                                    AND Card_Deactivation_Status__c = null]);
    }
    
    //Process credit card records and deactivate them in Comdata
    //Execute method
    global void execute(Database.BatchableContext BC, List<Credit_Card__c> creditCards) {
        
        //Credit Card to be update
        List<Credit_Card__c> cardsToBeUpdate = new List<Credit_Card__c>();
        
        //Create a Map of portfolio records to be updated
        Map<Id, Portfolio__c> portfolios = new Map<Id, Portfolio__c>();
        
        //Get Record Type Id of OSR
        Id recordTypeId = Util.RecordTypeId('OSR__c','Credit Card Request');
        String requestReason = Label.DEACTIVATION_OTHER;
                
        //Loop through scope list
        for(Credit_Card__c creditCard : creditCards) {

            try {
                
                //Find the request reason
                if(creditCard.Payment_Account__r.Utilized_Balance__c > 100
                	&& creditCard.Payment_Account__r.Deactivation_Reason__c == CreditCardConstants.PORTFOLIO_DEACTIVATION_REASON_OVER_CREDIT_BALANNCE_LIMIT) {
                	
                	requestReason = Label.DEACTIVATION_OVER_CREDIT_LIMIT;
                        
                } else if(creditCard.Payment_Account__r.Warning_Type__c == CreditCardConstants.PORTFOLIO_WARNING_TYPE_DEACTIVATE
                    && creditCard.Payment_Account__r.Deactivation_Reason__c == CreditCardConstants.PORTFOLIO_DEACTIVATION_REASON_OVER_AGE_LIMIT) {
                    
                    requestReason = Label.DEACTIVATION_OVER_TRANSACTION_DAYS;
                        
                 //Added else if condition by Mahendra Swarnkar -09/09/2015 - CR-20150901-9211     
                } else if(creditCard.Payment_Account__r.Deactivation_Reason__c == CreditCardConstants.EMPLOYEE_NO_LONGER_EXISTS) {
                    
                    	requestReason = CreditCardConstants.EMPLOYEE_NO_LONGER_EXISTS;
                    
                 //Added else if condition by Mahendra Swarnkar -09/04/2015 - CR-20150731-9125
                } else if(creditCard.Payment_Account__r.Deactivation_Reason__c == CreditCardConstants.EMPLOYEE_NOT_FOUND_IN_COMDATA) {
                    
                    	requestReason = CreditCardConstants.EMPLOYEE_NOT_FOUND_IN_COMDATA;
                }
                
                //Block the card through deactivate card request
                CreditCardService.deactivateCreditCard(creditCard, requestReason);
                if(requestReason == Label.DEACTIVATION_OVER_TRANSACTION_DAYS)
                	portfolios.put(creditCard.Payment_Account__c, new Portfolio__c(Id = creditCard.Payment_Account__c, 
                						Warning_Email_Status__c = CreditCardConstants.PORTFOLIO_WARNING_EMAIL_STATUS_PORTFOLIO_DEACTIVATED));
                
            } catch(Exception e) {
                
                //Assign new value to Credit Card's field Over Credit Limit Completed and add Card into list
                creditCard.Status__c = CreditCardConstants.CC_STATUS_PENDING_DEACTIVATION;
                creditCard.Card_Deactivation_Status__c = CreditCardConstants.CC_DEACTIVATION_STATUS_PENDING_RESPONSE;
                creditCard.Card_Deactivation_Reason__c = requestReason;
                cardsToBeUpdate.add(creditCard);
                
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
        
        //Check for the portfolio size
        if(portfolios.size() > 0) {
        	
        	//Bypass the trigger as no additional processing needed
        	Util.BypassAllTriggers = true;
        	
        	//Update
        	update portfolios.values();
        	
        	//Reset
        	Util.BypassAllTriggers = false;
        }
	}
    
    // Finish method
    global void finish(Database.BatchableContext BC) {

        //Check if any error occured and then send the email
        if(debugLog != '') {

            //Send batch status to the person who executed this batch
            Util.sendBatchStatus(BC.getJobId(), 'Batch_BlockCards', debugLog);
        }
        
        //Check if still there are records to process, the execute the same batch again
        Integer remainingCount = [SELECT count()
                                                FROM Credit_Card__c 
                                                Where ( 
                                                        (
                                                            Payment_Account__r.Utilized_Balance__c > 100        //Over balance Deactivatation
                                                            AND Payment_Account__r.Deactivation_Reason__c =: CreditCardConstants.PORTFOLIO_DEACTIVATION_REASON_OVER_CREDIT_BALANNCE_LIMIT
                                                        )
                                                        OR
                                                        (
                                                            Payment_Account__r.Warning_Type__c =: CreditCardConstants.PORTFOLIO_WARNING_TYPE_DEACTIVATE
                                                            AND Payment_Account__r.Deactivation_Reason__c =: CreditCardConstants.PORTFOLIO_DEACTIVATION_REASON_OVER_AGE_LIMIT 
                                                        )
                                                        OR
                                                        (
                                                        	Payment_Account__r.Deactivation_Reason__c =: CreditCardConstants.PORTFOLIO_DEACTIVATION_REASON_OTHER
                                                        	OR Payment_Account__r.Deactivation_Reason__c =: CreditCardConstants.EMPLOYEE_NO_LONGER_EXISTS
                                                            OR Payment_Account__r.Deactivation_Reason__c =: CreditCardConstants.EMPLOYEE_NOT_FOUND_IN_COMDATA
                                                            OR Payment_Account__r.Deactivation_Reason__c = null
                                                        )
                                                    )
                                                    AND Payment_Account__r.Status__c =: CreditCardConstants.PORTFOLIO_STATUS_DEACTIVATED 
                                                    AND Status__c =: CreditCardConstants.CC_STATUS_ACTIVE
                                                    AND Card_Deactivation_Status__c = null];
    	
    	//Check for the remaining count and execute the batch again if required
    	if(remainingCount > 0) {
    		
    		//Execute the same batch again
    		Batch_BlockCards batchJob = new Batch_BlockCards();
    		System.scheduleBatch(batchJob, 'Batch_BlockCards', 1, 1);
    	}
    }
}