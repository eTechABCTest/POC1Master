/**
 *  Purpose         :   This batch is used to update Card Holder's Address in Comdata.
 *
 *  Created By      :   Bhavi Sharma
 *
 *  Created Date    :   09/25/2013
 *
 *  Current Version :   v1.0 - Created - CR-20130109-2089
 **/
global class Batch_UpdateCardHolderAddressInComdata implements Database.Batchable<SObject>, Database.Stateful, Database.AllowsCallouts {

    //Debug Log
    global String debugLog;

    //Start method
    global Database.Querylocator start(Database.BatchableContext BC) {

        //Initialize
        debugLog = '';
        
        //return query result
        return Database.getQueryLocator([SELECT Id, Payment_Account__c FROM Credit_Card__c
                                            WHERE Payment_Account__r.Billing_Address_Updated__c = true AND Status__c =: CreditCardConstants.CC_STATUS_ACTIVE]);
    }

    //Execute method
    global void execute(Database.BatchableContext BC, List<Credit_Card__c> creditCards) {

        //Create a lidt of contact sto be updated
        List<Portfolio__c> payments = new List<Portfolio__c>();

        //Loop through list of CreditCards
        for(Credit_Card__c creditCard : creditCards) {

            //try - cat ch statement addedd, so if there is any error with any record, corsor will move to the next record.
            //in this scenario, contact flag will also remain set to true, so this will be picked by the next batch
            try {

                //Call comdata API to update the contact address in comdata
                CreditCardService.updateCreditCard(creditCard.Id);

                //reset the flag if Comdata was call successfully
                payments.add(new Portfolio__c(Id = creditCard.Payment_Account__c, Billing_Address_Updated__c = false));
            } catch(Exception e) {

                //Move to the next record, without doing anything
                debugLog += e.getMessage() + '\n';
            }
        }

        //Check for size of Contacts list
        if(payments.size() > 0) {

            //Allow partial update
            Database.SaveResult[] results = database.update(payments, false);

            //Create log
            debugLog += Util.createLog(results);
        }
    }

    // Finish method
    global void finish(Database.BatchableContext BC) {

        //Check if any error occured and then send the email
        if(debugLog != '') {

            //get CC Default Settings instance  
            Credit_Card_Settings__c configDefaults = CreditCardConstants.CONFIG_DEFAULT;
            if(!String.IsBlank(configDefaults.Traveldesk_Email__c))
                EmailHandler.sendEmail(configDefaults.Traveldesk_Email__c, 'Batch_UpdateCardHolderAddressInComdata', debugLog);
        }
        
        //chekc if there is still any pending record
        //invoke the batch again
        Integer remianingCount = [SELECT count() FROM Credit_Card__c 
                                    WHERE Payment_Account__r.Billing_Address_Updated__c = true AND Status__c =: CreditCardConstants.CC_STATUS_ACTIVE];
        
        if(remianingCount > 0) {
            
            //Execute batch
            if(!Test.isRunningTest()) {
                Batch_UpdateCardHolderAddressInComdata batchJob = new Batch_UpdateCardHolderAddressInComdata();
                System.scheduleBatch(batchJob, 'Batch_UpdateCardHolderAddressInComdata', 1, 1);
            }
        }
    }
}