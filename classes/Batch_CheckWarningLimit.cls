/**
 *  Purpose         :   This batch is used to check for any cards that are nearing or over the threshold transcation limit.
 *
 *  Created By      :   Bhavi Sharma
 *
 *  Created Date    :   10/14/2013
 *
 *  Current Version :   v1.0 - Created - CR-20130109-2089
 **/
global class Batch_CheckWarningLimit implements Database.Batchable<SObject>, Database.Stateful{

    //Debug Log
    global String debugLog;
    global Set<Id> affectedPortfolios;

    //Start method
    global Database.Querylocator start(Database.BatchableContext BC) {

        //return query result  
        return Database.getQueryLocator([SELECT Id FROM Portfolio__c LIMIT 0]);
    }

    //Execute method
    global void execute(Database.BatchableContext BC, List<Portfolio__c> portfolios) {
    }

    // Finish method
    global void finish(Database.BatchableContext BC) {
	
	}
}