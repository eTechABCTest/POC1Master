/**
 *  Purpose         :   This bacth is to unblock all the credit cards again which are under the credit limit or transaction days limit
 *
 *  Created By      :   Bhavi Sharma
 *
 *  Created Date    :   10/14/2013
 *
 *  Current Version :   V_1.0 - Created - CR-20130109-2089 
 						V_1.1 - Modified - CR-20151019-9335 - Updated start method query to remove the Final Warning date criteria.
 											// because whenever limit will be reset, final warning/aging values will be set to null.
 						V_1.2 - Modified By - Mahendra Swarnkar - 12/07/2015 - CR-20151105-9370 - 1) Updated start method query to add the portfolio field "#Of pending activation" ("Payment_Account__r.of_Pending_Activation__c").
											2) Updated execute method to check, if there is any related Credit Card record in "Pending Activation" status. If yes, then change the status of current card to "Pending Deactivation" after activating it in Comdata. 
 **/
global class Batch_UnblockUnderLimitsCards implements Database.Batchable<SObject>, Database.AllowsCallouts, Database.Stateful {

    //Debug Log
    global String debugLog;
   
    //Start method
    global Database.Querylocator start(Database.BatchableContext BC) {

        //Initialize
        debugLog = '';
        
        //Mahendra Swarnkar - 12/07/2015 - CR-20151105-9370 - Updated start method query to add the portfolio field "#Of pending activation"
        //Query all the records which are deactivated and now under the limits
        //Bhavi Sharma - CR-20151019-9335 - Updated start method query to remove the Final Warning date criteria.
        return Database.getQueryLocator([SELECT Id, Payment_Account__c, Payment_Account__r.of_Pending_Activation__c FROM Credit_Card__c 
                                            WHERE (
                                                    (
                                                        Payment_Account__r.Deactivation_Reason__c =: CreditCardConstants.PORTFOLIO_DEACTIVATION_REASON_OVER_CREDIT_BALANNCE_LIMIT
                                                        AND Card_Deactivation_Reason__c =: Label.DEACTIVATION_OVER_CREDIT_LIMIT
                                                        AND Payment_Account__r.Utilized_Balance__c <= 100 
                                                    )
                                                    OR
                                                    (
                                                        Payment_Account__r.Warning_Type__c !=: CreditCardConstants.PORTFOLIO_WARNING_TYPE_DEACTIVATE
                                                        AND Payment_Account__r.Deactivation_Reason__c =: CreditCardConstants.PORTFOLIO_DEACTIVATION_REASON_OVER_AGE_LIMIT
                                                        AND Card_Deactivation_Reason__c =: Label.DEACTIVATION_OVER_TRANSACTION_DAYS
                                                    )
                                                )
                                                AND Payment_Account__r.Status__c =: CreditCardConstants.PORTFOLIO_STATUS_ACTIVATED
                                                AND Status__c =: CreditCardConstants.CC_STATUS_DEACTIVATED
                                                AND Card_Deactivation_Status__c =: CreditCardConstants.CC_DEACTIVATION_STATUS_DEACTIVATED]
            );          
    }

    //Execute method
    global void execute(Database.BatchableContext BC, List<Credit_Card__c> creditCards) {
        
        //Create a Map of portfolio records to be updated
        Map<Id, Portfolio__c> portfolios = new Map<Id, Portfolio__c>();
        
        //Cards to be updated
        List<Credit_Card__c> listCardsToBeUpdated = new List<Credit_Card__c>();
        
        //Loop through scope list
        for(Credit_Card__c creditCard : creditCards) {
			
            //unbloack this credit card record as this is now under all the limits
            CreditCardService.activateCreditCardInRealTime(creditCard.Id);
            portfolios.put(creditCard.Payment_Account__c, new Portfolio__c(Id = creditCard.Payment_Account__c, Final_warning_Balance__c = null, Deactivation_Reason__c = null));
            
            //Modified By - Mahendra Swarnkar - 12/07/2015 - CR-20151105-9370
            //Starts from here
            //Check for presence of any other credit card of same porfolio, with status = Pending activation
			if(creditCard.Payment_Account__r.of_Pending_Activation__c >= 1) {
                
                //Update the status of Current card to pending deactivation 
                creditCard.Status__c = CreditCardConstants.CC_STATUS_PENDING_DEACTIVATION;
                
                //Update the Card deactivation status to pending response
                creditCard.Card_Deactivation_Status__c = CreditCardConstants.CC_DEACTIVATION_STATUS_PENDING_REPLACEMENT_ACTIVATION;
                
                //Populate the credit card list to be updated
                listCardsToBeUpdated.add(creditCard);
            }
            //Ends here
        }
        
        //Check for size of list
        if(portfolios.size() > 0) {

            //Bypass the trigger as no additional processing needed
        	Util.BypassAllTriggers = true;
        	
        	//Allow partial update
            Database.SaveResult[] results = database.update(portfolios.values(), false);
			
			//Bypass the trigger as no additional processing needed
        	Util.BypassAllTriggers = false;
        	
            //Create log
            debugLog += Util.createLog(results);
        }
        
        //Modified By - Mahendra Swarnkar - 12/07/2015 - CR-20151105-9370
		//Starts from here
		//Check for size
        if(listCardsToBeUpdated.size()>0) {
            
            //Bypass the trigger
        	Util.BypassAllTriggers = true;
        	
        	//Allow partial update
            Database.SaveResult[] results1 = database.update(listCardsToBeUpdated, false);
			
			//Bypass the trigger as no additional processing needed
        	Util.BypassAllTriggers = false;
        }
        //Ends here    
    }

    // Finish method
    global void finish(Database.BatchableContext BC) {
        
        //Check if any error occured and then send the email
        if(debugLog != '') {

            //Send batch status to the person who executed this batch
            Util.sendBatchStatus(BC.getJobId(), 'Batch_UnblockUnderLimitsCards', debugLog);
        }
        
        //Check if still there are records to process, the execute the same batch again
        //Bhavi Sharma - CR-20151019-9335 - Updated start method query to remove the Final Warning date criteria.
        Integer remainingCount = [SELECT count() FROM Credit_Card__c 
                                            WHERE (
                                                    (
                                                        Card_Deactivation_Reason__c =: Label.DEACTIVATION_OVER_CREDIT_LIMIT
                                                        AND Payment_Account__r.Utilized_Balance__c <= 100 
                                                    )
                                                    OR
                                                    (
                                                        Payment_Account__r.Warning_Type__c !=: CreditCardConstants.PORTFOLIO_WARNING_TYPE_DEACTIVATE
                                                        AND Payment_Account__r.Deactivation_Reason__c =: CreditCardConstants.PORTFOLIO_DEACTIVATION_REASON_OVER_AGE_LIMIT
                                                        AND Card_Deactivation_Reason__c =: Label.DEACTIVATION_OVER_TRANSACTION_DAYS 
                                                    )
                                                )
                                                AND Payment_Account__r.Status__c =: CreditCardConstants.PORTFOLIO_STATUS_ACTIVATED
                                                AND Status__c =: CreditCardConstants.CC_STATUS_DEACTIVATED
                                                AND Card_Deactivation_Status__c =: CreditCardConstants.CC_DEACTIVATION_STATUS_DEACTIVATED];
        
        //Check for the remaining count and execute the batch again if required
        if(remainingCount > 0) {
            
            //Execute the same batch again
            Batch_UnblockUnderLimitsCards batchJob = new Batch_UnblockUnderLimitsCards();
            System.scheduleBatch(batchJob, 'Batch_UnblockUnderLimitsCards', 1, 1);
        }
    }
}