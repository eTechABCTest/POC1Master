/**
 *  Purpose         :   This batch is to create the Credit card record in Comdata for the Replacemnet OSRs
 *
 *  Created By      :   Bhavi Sharma
 *
 *  Created Date    :   10/15/2013
 *
 *  Current Version :   v1.0 - Created - CR-20130109-2089
                        v1.1 - 05/17/2014 - Bhavi Sharma - Modified(Added curly braces for if condition) - CR-20140515-5525
 *
 **/
global class Batch_AddCardsForReplacementRequest implements Database.Batchable<SObject>, Database.Stateful, Database.AllowsCallouts {
    
    //List of Credit cards to be activated
    global Map<Id, OSR__c> mapCCIdWithOSR;
    
    //Start method
    global Database.Querylocator start(Database.BatchableContext BC) {
        
        //Pick all the OSR where replacement or deactivation requested.
        return database.getQueryLocator([SELECT Id, Name,
                                                Card_Set_up_Status__c,
                                                Credit_Card_Number__c,
                                                Card_Number__c,
                                                Card_Vendor__c,
                                                Card_Expiration__c,
                                                Card_Status_Code__c,
                                                Card_Deactivation_Reason__c,
                                                Status__c, 
                                                Card_Holder_First_Name__c,
                                                Card_Holder_Last_Name__c,
                                                Card_Deactivation_Status__c,
                                                Card_Employee_Number__c,
                                                Product_Code__c,
                                                Cycle_Type__c,
                                                Product_Available_Flag__c,
                                                Payment_Account__c,
                                                Update_Billing_Address_On_Activation__c, 
                                                Payment_Account__r.Billing_Address_Line_1__c, 
                                                Payment_Account__r.Billing_Address_Line_2__c, 
                                                Payment_Account__r.Billing_Address_City__c, 
                                                Payment_Account__r.Billing_Address_State__c, 
                                                Payment_Account__r.Billing_Address_PostalCode__c, 
                                                Payment_Account__r.Billing_Address_Attention_To__c, 
                                                Payment_Account__r.First_Name_On_Card__c, 
                                                Payment_Account__r.Last_Name_On_Card__c, 
                                                Payment_Account__r.Portfolio_Owner_Finance_Code__c,
                                                Payment_Account__r.Card_Count__c,
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
                                                FROM Credit_Card__c where Id IN: mapCCIdWithOSR.keySet()]);
    }

    //Execute method
    global void execute(Database.BatchableContext BC, List<Credit_Card__c> creditCards) {
        
        //Create a list of credit cards to be updated
        List<Credit_Card__c> creditCardsToUpdate = new List<Credit_Card__c>();
        List<OSR__c> oSRsToUpdate = new List<OSR__c>();
        List<Web_Service_Log__c> logs = new List<Web_Service_Log__c>();
        
        //Settings
        Credit_Card_Settings__c configCCDefaultSetting = CreditCardConstants.CONFIG_DEFAULT;
        
        //Loop through the Credit_Card__c
        for(Credit_Card__c creditCard : creditCards) {
            
            //Get request Envelope
            DateTime requestTime = DateTime.now();
            String requestEnvelope;
    
            //Check for OSR's Internation Address is true, else Expedited Approved or not
            if(creditCard.Original_Request__r.International_Address__c == true) {
                requestEnvelope = CreditCardHelper.getAddCreditCardAlternateDeliveryRequestEnvelope(creditCard);
            } else if(creditCard.Original_Request__r.Expedited_Processing_Approval__c == CreditCardConstants.OSR_EXPEDITED_PROCESSING_APPROVAL_APPROVED) {
                requestEnvelope = CreditCardHelper.getAddCreditCardExpediatedRequestEnvelope(creditCard);
            } else {
                requestEnvelope = CreditCardHelper.getAddCreditCardRequestEnvelope(creditCard);
            }
            
            try {
    
                //Make callout and parse response
                HttpRequest request = HTTPRequestBuilder.CreateRequest(configCCDefaultSetting.Endpoint__c, CreditCardConstants.REQUEST_TYPE_POST, CreditCardConstants.SOAP_ACTION_ADD_CARD, requestEnvelope);
                HttpResponse hResponse = HTTPService.send(request);
                HTTPResponseParser.AddCardResponse response = HTTPResponseParser.parseAddCardResponse(hResponse);
    
                //Check for success
                if(response.responseCode == CreditCardConstants.ZERO) {
    
                    //Check if request is valid
                    if(response.trackingNumber != CreditCardHelper.trackingNumberForEnvelope)
                        throw new CustomException('Invalid request.');
    
                    //Get request Envelope
                    HTTPResponseParser.InquireCardResponse inquireCardResponse;
                    
                    //Do only when test methos is not running
                    if(!Test.isRunningTest())
                    	inquireCardResponse = CreditCardService.inquireCreditCard(creditCard, false);
                    
                    //Populate and Update Credit Card record with some additional values
                    creditCard.Status__c = CreditCardConstants.CC_STATUS_PENDING_ACTIVATION;
                    creditCard.Card_Set_up_Status__c = CreditCardConstants.CC_SET_UP_STATUS_PENDING_ACTIVATION;
                    creditCard.Credit_Card_Number__c = response.cardNumber;
                    if(!Test.isRunningTest())
                        creditCard.Card_Expiration__c = CreditCardHelper.buildDate(inquireCardResponse.cardDetails.cardExpiration);
                    creditCard.Card_Number__c = CreditCardService.Encrypt(response.cardNumber);
                    creditCardsToUpdate.add(creditCard);
    
                    //Create a log record
                    logs.add(CreditCardLogger.LogInstance(creditCard, null, requestTime, CreditCardService.Request_Log, requestEnvelope,
                                            String.valueOf(response), 'Batch_AddCardsForReplacementRequest', 'addCreditCard', 'addCard'));
                } else {
    
                    //Populate and Update Credit Card record with some additional values
                    creditCard.Status__c = CreditCardConstants.CC_STATUS_REQUEST_DECLINED;
                    creditCard.Card_Set_up_Status__c = CreditCardConstants.CC_SETUP_STATUS_DECLINED;
                    creditCardsToUpdate.add(creditCard);
                    
                    throw new CustomException(response.responseDescription);
                }
            } catch(Exception e){
    
                //Update OSR
                OSR__c oSR = mapCCIdWithOSR.get(creditCard.Id);
                oSR.Status__c = CreditCardConstants.OSR_STATUS_CANCELLED;
                oSR.Cancellation_Reason__c = e.getMessage();
                oSRsToUpdate.add(oSR);
                    
                //Create a log record
                logs.add(CreditCardLogger.LogInstance(creditCard, e.getMessage(), requestTime, CreditCardService.Request_Log, requestEnvelope,
                                        e.getMessage(), 'Batch_AddCardsForReplacementRequest', 'addCreditCard', 'addCard'));
                
            }
        }
        
        //Update Credit Card records
        if(creditCardsToUpdate.size() > 0)
            update creditCardsToUpdate;
        
        //Update OSRs
        if(oSRsToUpdate.size() > 0)
            update oSRsToUpdate;
        
        //Create logs
        if(logs.size() > 0)
            insert logs;
    }

    // Finish method
    global void finish(Database.BatchableContext BC) {
        
        //Check if there is still any replacement or deactivation request, restart the batch
        Integer remainingOSRs = [Select count() from OSR__c 
                                            Where Request_Type__c IN: CreditCardConstants.OSR_AUTOMATED_UNBLOCKING_REQUEST_TYPES
                                                                        AND Status__c =: CreditCardConstants.OSR_STATUS_NEW];
        
        //Check for the count and invoke tge batch again
        if(remainingOSRs > 0) {
            
            //Execute the batch again
            Batch_ProcessOSRs batchProcessOSRsJob = new Batch_ProcessOSRs();
            System.scheduleBatch(batchProcessOSRsJob, 'Batch_ProcessOSRs', 1, 1);
        }
    }
}