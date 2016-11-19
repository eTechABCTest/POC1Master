/**
 *  Purpose         :   This batch is used to pick all the newly created OSR records which are requested for replacement or deactivation
                            and process these immediately
 *
 *  Created By      :   Bhavi Sharma
 *
 *  Created Date    :   10/15/2013
 *
 *  Current Version :   v1.0 - Created - CR-20130109-2089
                        V_1.1 - Modified - CR-20140304-4695 - Do not process same credit card more than once
                        V_1.2 - 05/17/2014 - Bhavi Sharma - Modified - Only relace card with Lost or Stolen status - CR-20140515-5525
 *
 **/
global class Batch_ProcessOSRs implements Database.Batchable<SObject>, Database.Stateful, Database.AllowsCallouts {
    
    //Fraud Card Error Message
    public static final String FRAUD_CARD_ERROR_MESSAGE = 'Unable to change status of Stolen/Suspected Fraud card.';
    
    //List of Credit cards to be activated
    global Map<Id, OSR__c> mapCCIdWithOSR;
    
    //Debug Log
    global String debugLog;
    
    //Start method
    global Database.Querylocator start(Database.BatchableContext BC) {
        
        //Initialize
        mapCCIdWithOSR = new Map<Id, OSR__c>();
        debugLog = '';
        
        //Pick all the OSR where replacement or deactivation requested.
        return database.getQueryLocator([Select Id, Address_Updated__c, Related_Card__c, Request_Type__c,Expedited_Processing_Approval__c, Request_Reason__c, International_Address__c 
                                         from OSR__c Where Request_Type__c IN: CreditCardConstants.OSR_AUTOMATED_UNBLOCKING_REQUEST_TYPES
                                                                        AND Status__c =: CreditCardConstants.OSR_STATUS_NEW Order By Name]);
    }

    //Execute method
    global void execute(Database.BatchableContext BC, List<OSR__c> oSRs) {
        
        //Create a set to hold OSR ids
        Set<Id> cCIds = new Set<Id>();
        
        //Loop throgh the OSRs and populate the cCIDs
        for(OSR__c oSR : oSRs) {
            
            //add CC Id in set
            if(oSR.Related_Card__c != null) {
                
                cCIds.add(oSR.Related_Card__c);
            }
        }
        
        //Fecth all the relavent CC records 
        Map<Id, Credit_Card__c> mapCreditCards = new Map<Id, Credit_Card__c>([SELECT Id, Name, RecordTypeId,
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
                                                                Payment_Account__r.Card_Holder__r.Birthdate,
                                                                Payment_Account__r.Card_Count__c,
                                                                Original_Request__c,
                                                                Original_Request__r.International_Address__c,
                                                                Original_Request__r.Address_Line_1__c,
                                                                Original_Request__r.Address_Line_2__c,
                                                                Original_Request__r.Address_City__c,
                                                                Original_Request__r.Address_State__c,
                                                                Original_Request__r.Address_Postal_Code__c,
                                                                Original_Request__r.Expedited_Processing_Approval__c
                                                                FROM Credit_Card__c WHERE Id IN: cCIds]);
        
        //Create a list of credit cards to be updated
        Map<Id, Credit_Card__c> mapCreditCardsToUpdate = new Map<Id, Credit_Card__c>();
        Map<Credit_Card__c, OSR__c> cloneCardsForReplacement = new Map<Credit_Card__c, OSR__c>();
        map<Id, OSR__c> oSRsToUpdate = new map<Id, OSR__c>();
        List<Web_Service_Log__c> logs = new List<Web_Service_Log__c>();
        
        //Settings
        Credit_Card_Settings__c configCCDefaultSetting = CreditCardConstants.CONFIG_DEFAULT;
        
        //Loop through the OSRs
        for(OSR__c oSR : oSRs) {
            
            //Check if No credit card is attached to OSR, add error message on oSR record
            if(oSR.Related_Card__c == null)
                throw new CustomException('Credit card not found on OSR record');
            
            //Credit Card
            Credit_Card__c creditCard;
            
            //Check if this Credit Card was already added for any other OSR
            if(mapCreditCardsToUpdate.containsKey(oSR.Related_Card__c))
                creditCard = mapCreditCardsToUpdate.get(oSR.Related_Card__c);
            else
                creditCard = mapCreditCards.get(oSR.Related_Card__c);
            
            //Request time
            DateTime requestTime = DateTime.now();
            
            //Get request Envelope
            String requestEnvelope;
            
            try {
                
                //Check for the request type
                if(oSR.Request_Type__c == CreditCardConstants.OSR_REQUEST_TYPE_REPLACEMENT_ABC_CREDIT_CARD
                    || oSR.Request_Type__c == CreditCardConstants.OSR_REQUEST_TYPE_REPLACEMENT_ABC_CREDIT_CARD_EXPEDITED) {
                    
                    //Added by Bhavi Sharma - 05/17/2014 - Only deactivate the card if status is lost or stolen
                    if(oSR.Request_Reason__c != CreditCardConstants.OSR_REQUEST_REASON_LOST
                        && oSR.Request_Reason__c != CreditCardConstants.OSR_REQUEST_REASON_STOLEN) {
                            
                        //Populate and Update Credit Card record with some additional values
                        creditCard.Status__c = CreditCardConstants.CC_STATUS_PENDING_DEACTIVATION;
                        creditCard.Card_Deactivation_Status__c = CreditCardConstants.CC_DEACTIVATION_STATUS_PENDING_REPLACEMENT_ACTIVATION;
                        creditCard.Card_Deactivation_Reason__c = oSR.Request_Reason__c;
                        mapCreditCardsToUpdate.put(creditCard.Id, creditCard);
                        cloneCardsForReplacement.put(creditCard, oSR);
                        
                        //Close OSR record
                        if(oSR.Request_Type__c == CreditCardConstants.OSR_REQUEST_TYPE_REPLACEMENT_ABC_CREDIT_CARD_EXPEDITED)
                            oSR.Expedited_Processing_Approval__c = CreditCardConstants.OSR_EXPEDITED_PROCESSING_APPROVAL_APPROVED;
                        oSR.Status__c = CreditCardConstants.OSR_STATUS_COMPLETE;
                        oSRsToUpdate.put(oSR.Id, oSR);
                    } else  {
                    
                        //Request Envelope
                        requestEnvelope = CreditCardHelper.getDeactivateCreditCardForReplacementEnvelope(creditCard);
                        
                        //Make callout and parse response
                        HttpRequest request = HTTPRequestBuilder.CreateRequest(configCCDefaultSetting.Endpoint__c, CreditCardConstants.REQUEST_TYPE_POST, CreditCardConstants.SOAP_ACTION_UPDATE_CARD, requestEnvelope);
                        HttpResponse hResponse = HTTPService.send(request);
                        HTTPResponseParser.CardAddUpdateResponse response = HTTPResponseParser.parseUpdateCardResponse(hResponse);
            
                        //Check if this card in marked as Fraud in Comdata
                        System.debug('response.responseDescription:::::' + response.responseDescription);
                        
                        //Check for success
                        if(response.responseCode == CreditCardConstants.ZERO 
                            || response.responseDescription.containsIgnoreCase(Batch_ProcessOSRs.FRAUD_CARD_ERROR_MESSAGE)) {
            
                            //Check if request is validresponse
                            if(response.trackingNumber != CreditCardHelper.trackingNumberForEnvelope
                                && !response.responseDescription.containsIgnoreCase(Batch_ProcessOSRs.FRAUD_CARD_ERROR_MESSAGE))
                                throw new CustomException('Invalid request.');
            
                            //Populate and Update Credit Card record with some additional values
                            creditCard.Status__c = CreditCardConstants.CC_STATUS_DEACTIVATED;
                            creditCard.Comdata_Status__c = 'B';
                            creditCard.Card_Deactivation_Status__c = CreditCardConstants.CC_DEACTIVATION_STATUS_DEACTIVATED;
                            creditCard.Card_Deactivation_Reason__c = oSR.Request_Reason__c;
                            mapCreditCardsToUpdate.put(creditCard.Id, creditCard);
                            cloneCardsForReplacement.put(creditCard, oSR);
                            
                            //Close OSR record
                            oSR.Status__c = CreditCardConstants.OSR_STATUS_COMPLETE;
                            oSRsToUpdate.put(oSR.Id, oSR);
                            
                            //Create a log record
                            logs.add(CreditCardLogger.LogInstance(creditCard, null, requestTime, CreditCardService.Request_Log, requestEnvelope,
                                                    String.valueOf(response), 'CreditCardService', 'replacementCreditCard', 'updateCard'));
                        } else
                            throw new CustomException(response.responseDescription);
                    }
                } else {
                    
                    //Get request Envelope
                    requestEnvelope = CreditCardHelper.getDeactivateCreditCardEnvelope(creditCard);
                    
                    //Make callout and parse response
                    HttpRequest request = HTTPRequestBuilder.CreateRequest(configCCDefaultSetting.Endpoint__c, CreditCardConstants.REQUEST_TYPE_POST, CreditCardConstants.SOAP_ACTION_UPDATE_CARD, requestEnvelope);
                    HttpResponse hResponse = HTTPService.send(request);
                    HTTPResponseParser.CardAddUpdateResponse response = HTTPResponseParser.parseUpdateCardResponse(hResponse);
                    
                    //Check for success
                    if(response.responseCode == CreditCardConstants.ZERO
                        || response.responseDescription.containsIgnoreCase(Batch_ProcessOSRs.FRAUD_CARD_ERROR_MESSAGE)) {
        
                        //Check if request is validresponse
                        if(response.trackingNumber != CreditCardHelper.trackingNumberForEnvelope
                            && !response.responseDescription.containsIgnoreCase(Batch_ProcessOSRs.FRAUD_CARD_ERROR_MESSAGE))
                            throw new CustomException('Invalid request.');
        
                        //Populate and Update Credit Card record with some additional values
                        creditCard.Status__c = CreditCardConstants.CC_STATUS_DEACTIVATED;
                        creditCard.Comdata_Status__c = 'B';
                        creditCard.Card_Deactivation_Status__c = CreditCardConstants.CC_DEACTIVATION_STATUS_DEACTIVATED;
                        mapCreditCardsToUpdate.put(creditCard.Id, creditCard);
                        
                        //Close OSR record
                        oSR.Status__c = CreditCardConstants.OSR_STATUS_COMPLETE;
                        oSRsToUpdate.put(oSR.Id, oSR);
                            
                        //Create a log record
                        logs.add(CreditCardLogger.LogInstance(creditCard, null, requestTime, CreditCardService.Request_Log, requestEnvelope,
                                                String.valueOf(response), 'CreditCardService', 'deactivateCreditCard', 'updateCard'));
                    } else
                        throw new CustomException(response.responseDescription);
                }
        
                //Create clone for replacement
                for(Credit_Card__c cC : cloneCardsForReplacement.keySet()) {
                    
                    //Check if address of OSR is an international address, update credit card
                    if(oSR.International_Address__c == true
                        || oSR.Expedited_Processing_Approval__c == CreditCardConstants.OSR_EXPEDITED_PROCESSING_APPROVAL_APPROVED
                        ||  oSR.Address_Updated__c == true) {
                        
                        //Update Credit  Card field
                        cC.Update_Billing_Address_On_Activation__c = true;
                    } 
                    
                    //Clone card
                    cC = CreditCardService.cloneCreditCardForReplacement(cC, oSR);
                    mapCCIdWithOSR.put(cC.Id, cloneCardsForReplacement.get(cC));
                }
            } catch(Exception e){
                
                //Close OSR record
                oSR.Status__c = CreditCardConstants.OSR_STATUS_CANCELLED;
                oSR.Cancellation_Reason__c = e.getMessage();
                oSRsToUpdate.put(oSR.Id, oSR);
                
                //Create a log record
                logs.add(CreditCardLogger.LogInstance(creditCard, e.getMessage(), requestTime, CreditCardService.Request_Log, requestEnvelope,
                                        e.getMessage(), 'Batch_ProcessOSRs', 'replacementCreditCard', 'updateCard'));
                
                //Move to the next record, without doing anything
                debugLog += e.getMessage() + '\n';
            }                
        }
        
        //Update Credit Card records
        if(mapCreditCardsToUpdate.size() > 0) {
            
            //Allow partial update
            Database.SaveResult[] results = database.update(mapCreditCardsToUpdate.values(), false);
            
            //Create log
            debugLog += Util.createLog(results);
        }
        
        //Update OSrs
        if(oSRsToUpdate.size() > 0) {
            
            //Allow partial update
            Database.SaveResult[] results = database.update(oSRsToUpdate.values(), false);
            
            //Create log
            debugLog += Util.createLog(results);
        }
        
        //Create logs
        if(logs.size() > 0) {
            
            //Allow partial update
            Database.SaveResult[] results = database.insert(logs, false);
            
            //Create log
            debugLog += Util.createLog(results);
        }
    }

    // Finish method
    global void finish(Database.BatchableContext BC) {
        
        //Check if any error occured and then send the email
        if(debugLog != '') {
            
            Credit_Card_Settings__c configCCDefaultSetting = CreditCardConstants.CONFIG_DEFAULT;
            
            //Chekc  if traveldesk email is defined, then email the batch status
            if(!String.IsBlank(configCCDefaultSetting.Traveldesk_Email__c))
                EmailHandler.sendEmail(configCCDefaultSetting.Traveldesk_Email__c, 'Batch_ProcessOSRs', debugLog);
        }
        
        //Check if there is any replacement request, activate the newly Created Credit card
        if(mapCCIdWithOSR.size() > 0 && !Test.isRunningTest()) {
            
            //execute the 2nd batch which will be creating new credit cards from Replacement OSRs
            Batch_AddCardsForReplacementRequest batchJob = new Batch_AddCardsForReplacementRequest();
            batchJob.mapCCIdWithOSR = mapCCIdWithOSR;
            System.scheduleBatch(batchJob, 'Batch_AddCardsForReplacementRequest', 1, 1);
        }
    }
}