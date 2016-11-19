/**
 * @description: contains helper methods for the WebServiceLog trigger
 * 
 * Version	:	V_1.1 - Bhavi Sharma - 10/24/2015 - CR-20151023-9358: deActivateCardANDPortfolio method modified. 
 																		Deactivate the Credit Card only if it's  already active
 				V_1.1 - Bhavi Sharma - 10/30/2015 - CR-20151023-9358: deActivateCardANDPortfolio method modified:
 																		updated the method name to deactivateCard as we only want to deactivate the card														
 **/
global without sharing class WebServiceLogTriggerHelper {
	
    //Added By - Mahendra Swarnkar - 09/04/2015 - CR-20150731-9125
    /**
     *  @description    :   Method to deActivate credit card and Portfolio related to those web service log records which have fault string in callout response.
     *
     *  @args           :   List of new Membership
     *
     *  @return         :   void
     *
    **/
    public static void deactivateCard(List<Web_Service_Log__c> newWSLogs){
        
        //Set to hold the Web service log's related Credit record card Ids
        Set<Id> setCCIds = new Set<Id>();
        
        //Map to hold the Web service log and related credit card record
        Map<Id,Credit_Card__c> mapCCard = new Map<Id,Credit_Card__c>();
        
		//Map to hold the creditcard and related Portfolio record
        Map<Id,Portfolio__c> mapPortfolio = new Map<Id,Portfolio__c>();
        
        //loop through new web service log records
        for(Web_Service_Log__c wSLogs : newWSLogs) {
            
            //Check for the credit card related web services with fault string in responce 
            if(wSLogs.Credit_Card__C != null && wSLogs.Credit_Card_Response_Message__c != null  
               && wSLogs.Credit_Card_Response_Message__c.containsIgnoreCase(CreditCardConstants.EMPLOYEE_NUMBER_NOT_FOUND) ){
                
                //Populate the set with credit card ids
				setCCIds.add(wSLogs.Credit_Card__c);
            }
        }
        
        //Query through credit card records
        //Set status to deactivated and deactivation reason to "Employee Not Found in Comdata." for webservice logs related "credit card records/portfolio records"
        //Bhavi Sharma - 10/24/2015 - CR-20151023-9358: deActivateCardANDPortfolio method modified. 
 		//Deactivate the Credit Card only if it's  already active
        for(Credit_Card__c  cCard: [Select Id, Status__c, Card_Deactivation_Reason__c, Payment_Account__c , 
                                    	Payment_Account__r.Status__c, Payment_Account__r.Deactivation_Reason__c 
                                    	From Credit_Card__c where Id IN : setCCIds AND Status__c =: CreditCardConstants.CC_STATUS_ACTIVE] ){
            //Check for map    
			if(!mapCCard.containsKey(cCard.Id)){
            	
                //Check if already deactivated with valid deactivation reason 
                mapCCard.put(cCard.Id, new Credit_Card__c(Id = cCard.Id , Status__c = CreditCardConstants.CC_STATUS_DEACTIVATED,
														Card_Deactivation_Reason__c = CreditCardConstants.EMPLOYEE_NOT_FOUND_IN_COMDATA));
			}
        }
        
		//De-activate by pass all triggers
        Util.BypassAllTriggers = true;
        
        //Check for size & update the Credit card records
        if(mapCCard.values() != null && mapCCard.values().size() > 0)
             update mapCCard.values();
        
        //Activate by pass all triggers
        Util.BypassAllTriggers = false;
    }
}