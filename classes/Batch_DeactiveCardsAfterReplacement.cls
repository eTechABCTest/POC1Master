/**
 *  Purpose         :   This batch is to deactivate the credit card once the user activates new credit card after his replacement request
 *
 *  Created By      :   Bhavi Sharma
 *
 *  Created Date    :   05/17/2017
 *
 *  Current Version :   v1.0 - Created - CR-20140515-5525
 *
 **/
global class Batch_DeactiveCardsAfterReplacement implements Database.Batchable<SObject>, Database.Stateful, Database.AllowsCallouts {
    
    //List of Credit cards to be activated
    global Map<Id, OSR__c> mapCCIdWithOSR;
    
    //Set to hold the contact Ids for deactivating credit cards
    public Set<Id> cardsOwners;
    
    //Start method
    global Database.Querylocator start(Database.BatchableContext BC) {
        
        //Pick all the OSR where replacement or deactivation requested.
        return database.getQueryLocator([SELECT Id, Name,
                                                    Card_Set_up_Status__c,
                                                    Card_Owner__c,
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
                                                    FROM Credit_Card__c WHERE Payment_Account__r.Card_Holder__c IN :cardsOwners 
                                                    AND Status__c =: CreditCardConstants.CC_STATUS_PENDING_DEACTIVATION
                                                    AND Card_Deactivation_Status__c =: CreditCardConstants.CC_DEACTIVATION_STATUS_PENDING_REPLACEMENT_ACTIVATION]);
    }

    //Execute method
    global void execute(Database.BatchableContext BC, List<Credit_Card__c> creditCards) {
        
        //Create a list of credit cards to be updated
        Map<Id, Credit_Card__c> mapCreditCardsToUpdate = new Map<Id, Credit_Card__c>();
        Map<Credit_Card__c, OSR__c> cloneCardsForReplacement = new Map<Credit_Card__c, OSR__c>();
        map<Id, OSR__c> oSRsToUpdate = new map<Id, OSR__c>();
        List<Web_Service_Log__c> logs = new List<Web_Service_Log__c>();
        
        //Settings
        Credit_Card_Settings__c configCCDefaultSetting = CreditCardConstants.CONFIG_DEFAULT;
        
        //Loop through the OSRs
        for(Credit_Card__c creditCard : creditCards) {
            
            //Request time
            DateTime requestTime = DateTime.now();
            
            //Get request Envelope
            String requestEnvelope;
            
            try {
                
                //Request Envelope
                requestEnvelope = CreditCardHelper.getDeactivateCreditCardForReplacementEnvelope(creditCard);
                
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
                    
                    //Create a log record
                    logs.add(CreditCardLogger.LogInstance(creditCard, null, requestTime, CreditCardService.Request_Log, requestEnvelope,
                                            String.valueOf(response), 'CreditCardService', 'replacementCreditCard', 'updateCard'));
                } else
                    throw new CustomException(response.responseDescription);
            } catch(Exception e){
                
                //Create a log record
                logs.add(CreditCardLogger.LogInstance(creditCard, e.getMessage(), requestTime, CreditCardService.Request_Log, requestEnvelope,
                                        e.getMessage(), 'Batch_ProcessOSRs', 'replacementCreditCard', 'updateCard'));
            }                
        }
        
        //Update Credit Card records
        if(creditCards.size() > 0)
            update creditCards;
        
        //Create logs
        if(logs.size() > 0)
            insert logs;
    }

    // Finish method
    global void finish(Database.BatchableContext BC) {
        
        //Map to hold to be deactivated cards
        Map<Id, Credit_Card__c> maPendingDeactivation = new Map<Id, Credit_Card__c>();
        
        Set<Id> toBeDeactivateCardOwners = new Set<Id>();
        Set<Id> cardsOwners = new Set<Id>();
        
        
        //Check if still there are pending records execute the batch again
        for(Credit_Card__c cC : [SELECT Id, Payment_Account__r.Card_Holder__c FROM Credit_Card__c 
                                                    WHERE Payment_Account__r.Card_Holder__c != null
                                                    AND Status__c =: CreditCardConstants.CC_STATUS_PENDING_DEACTIVATION
                                                    AND Card_Deactivation_Status__c =: CreditCardConstants.CC_DEACTIVATION_STATUS_PENDING_REPLACEMENT_ACTIVATION]) {
             
             //Add in map
             maPendingDeactivation.put(cC.Payment_Account__r.Card_Holder__c, cC);
                                
            //Add in Deactivation Owners Set
            toBeDeactivateCardOwners.add(cC.Payment_Account__r.Card_Holder__c);
        }
        
        //fetch all the records which have active cards, only cards(Pending deactivation) related to these need to be deactivated
        for(Credit_Card__c  cC : [Select Id, Payment_Account__r.Card_Holder__c from Credit_Card__c 
                                                    WHERE Payment_Account__r.Card_Holder__c IN: toBeDeactivateCardOwners
                                                    AND Status__c =: CreditCardConstants.CC_STATUS_ACTIVE]) {
            
            //Check if the same owner is in the Pending Deactivation list, then add the card in deactivation set
            if(maPendingDeactivation.containsKey(cC.Payment_Account__r.Card_Holder__c)) {
                
                //Add in Set
                cardsOwners.add(cC.Payment_Account__r.Card_Holder__c);
            }
        }
        
        
        //Check if there is any replacement request, activate the newly Created Credit card
        if(cardsOwners.size() > 0 && !Test.isRunningTest()) {
            
            //execute the 2nd batch which will be creating new credit cards from Replacement OSRs4
            Batch_DeactiveCardsAfterReplacement batchJob = new Batch_DeactiveCardsAfterReplacement();
            batchJob.cardsOwners = cardsOwners;
            database.executeBatch(batchJob, 10);
        }
    }
}