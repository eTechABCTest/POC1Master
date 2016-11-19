/**
 *  Purpose         :   This batch is used to check for any transactions that are nearing or over the threshold transaction age Limit .
 *
 *  Created By      :   Bhavi Sharma
 *
 *  Created Date    :   10/15/2013
 *
 *  Current Version :   v1.0 - Created - CR-20130109-2089
 **/
global class Batch_CheckTransactionAgeLimit implements Database.Batchable<SObject>, Database.Stateful {

    //Debug Log
    global String debugLog;
    global Set<Id> affectedPortfolios;

    //This set is to hold all the credit card records that have been process
    global Set<Id> addedCreditCards;

    //Start method
    global Database.Querylocator start(Database.BatchableContext BC) {

        //return query result  
        return Database.getQueryLocator([SELECT Id FROM Portfolio__c  limit 0]);
    }

    //Execute method
    global void execute(Database.BatchableContext BC, List<Portfolio__c> portfolios) {
        
    }

    // Finish method
    global void finish(Database.BatchableContext BC) {
	        
    }
}