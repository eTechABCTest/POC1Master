/**
 *  Purpose         :   Helper class for Trigger on Credit Card.
 *
 *  Created By      :   Bhavi Sharma
 *
 *  Created Date    :   10/12/2013
 *
 *  Current Version :   V_1.0 - Created
                        V_1.1 - Modified - Bhavi Sharma - 01/07/2014 - CR-20140102-4208
 **/
public without sharing class CreditCardTriggerHelper {

    /**
     *  @description    :   This methiod is to Activate the card in Comdata when user activate card
     *
     *  @args           :   Trigger.New, Trigger.oldMap
     *
     *  @return         :
     *
     **/
    public static void activateCardInComdata(List<Credit_Card__c> newCreditCards, Map<Id, Credit_Card__c> oldMapCreditCard) {

        //Set to hold Credit Card Ids
        Set<Id> creditCardIds = new Set<Id>();

        //Loop through Trigger.new
        for(Credit_Card__c creditCard : newCreditCards) {

            //Check for Card Set Up Status is changed to ?User Activated?
            if(creditCard.Card_Set_up_Status__c == CreditCardConstants.CC_SET_UP_STATUS_USER_ACTIVATED
                && creditCard.Card_Set_up_Status__c != oldMapCreditCard.get(creditCard.Id).Card_Set_up_Status__c) {

                //add into set of Ids
                creditCardIds.add(creditCard.Id);
            }
        }

        //Check for size of set
        if(creditCardIds.size() > 0) {

            //Check test is not running and Call future method to activate card In Comdata API
            CreditCardService.activateCreditCardInFuture(creditCardIds);
        }
    }

    /**
     *  @description    :   This method is to update the OSR record status to "In Progress", when New Credit Card record is being created
     *
     *  @args           :   Trigger.New
     *
     *  @return         :
     *
     **/
    public static void updateOSRToInProgress(List<Credit_Card__c> creditCards) {

        //Create a list of OSR records to be updated
        List<OSR__c> oSRs = new List<OSR__c>();

        //Loop through the cards
        for(Credit_Card__c card : creditCards) {

            //Check if OSR is not null, update the OSR status to In Progress
            if(card.Original_Request__c != null)
                oSRs.add(new OSR__c(Id = card.Original_Request__c, Status__c = CreditCardConstants.OSR_STATUS_IN_PROGRESS));
        }

        //Update the OSR records
        if(oSRs.size() > 0)
            update oSRs;
    }
    
    /**
	 *	@description	:	This method is to deactivate the other credit cards whenever a card is being activated on the same portfolio
	 *
	 *	@args			:	List of new Credit cards, Map of old CRedit cards
	 *
	 *	@return			:	void
	 *
	 **/
	public static void deactivateOtherCardsOnActivatingCard(List<Credit_Card__c> creditCards, Map<Id, Credit_Card__c> mapOldCreditCards) {
	
		//Set to hold the related portfolios
		Set<Id> setPortfolioIds = new Set<Id>();
		
		//Set to hold the cards recently activated
		Set<Id> recentlyActivatedCards = new Set<Id>();
	
		//Populate set
		for(Credit_Card__c cC : creditCards) {
			
			//Check if card status is just set to Active
			if(cC.Status__c == CreditCardConstants.CC_STATUS_ACTIVE && cC.Status__c != mapOldCreditCards.get(cC.Id).Status__c) {
				
				//Set portfolios Ids and Active Cards
				setPortfolioIds.add(cC.Payment_Account__c);
				recentlyActivatedCards.add(cC.Id);
			}
		}
		
		//Check if there are records to process
		if(recentlyActivatedCards.size() == 0)
			return;
		
		//Fetch all the  other Credit Card records which are Active other than the current one
		List<Credit_Card__c> creditCardsPendingDeactivation = [SELECT Id, Status__c, Payment_Account__r.Card_Holder__c FROM Credit_Card__c WHERE 
																	Id NOT IN: recentlyActivatedCards 
																		AND Payment_Account__c IN: setPortfolioIds
																		AND (Status__c =: CreditCardConstants.CC_STATUS_ACTIVE 
																			OR Status__c =: CreditCardConstants.CC_STATUS_PENDING_DEACTIVATION)];
		
		//Cards to deactivate
		List<Credit_Card__c> creditCardsToDeactivate = new List<Credit_Card__c>();
		
		
		//Loop through the records and mark them as Inactive
		//These cards will be picked up by the Batch
		for(Credit_Card__c cC : creditCardsPendingDeactivation) {
			
			//Check status
			if(cC.Status__c != CreditCardConstants.CC_STATUS_PENDING_DEACTIVATION) {
				
				cC.Status__c =  CreditCardConstants.CC_STATUS_PENDING_DEACTIVATION;
				cC.Card_Deactivation_Status__c = CreditCardConstants.CC_DEACTIVATION_STATUS_PENDING_REPLACEMENT_ACTIVATION;
				
				//Add in list
				creditCardsToDeactivate.add(cC);
			}
		}
		
		if(creditCardsToDeactivate.size() > 0)
			update creditCardsToDeactivate;
			
		//If there are records pending deactivation, execute the batch to deactivate them
		if(creditCardsPendingDeactivation.size() > 0) {
			
			//Check if batch class is not already running only in that case call 
            List<AsyncApexJob> aSyncJobs = [SELECT Id, JobItemsProcessed, TotalJobItems, NumberOfErrors, CreatedBy.Email FROM AsyncApexJob
                                                    WHERE ApexClass.Name = 'Batch_DeactiveCardsAfterReplacement' AND Status IN: CreditCardConstants.ASYNC_APEX_JOB_PENDING_STATUSES];
            
            
            //Check for the size
            if(aSyncJobs.size() == 0) {
                
                //Create a set to hold the card owners
                Set<Id> cardsOwners = new Set<Id>();
                
                //loop through the creadit card records and get the Card Holder id
                for(Credit_Card__c cC : creditCardsPendingDeactivation) {
                    
                    //Get the card holder name
                    if(cC.Payment_Account__r.Card_Holder__c != null) {
                        cardsOwners.add(cC.Payment_Account__r.Card_Holder__c);
                    }
                }
                
                //Call the Batch Process to deactivate the card in Status = Pending Replacement Activation'
                if(cardsOwners.size() > 0) {
                    
                    try {
                        
                        //Current time
                        DateTime dtm = DateTime.now();
                        dtm = dtm.addMinutes(1);
                        String cron = '0 '+ dtm.minute() + ' ' + dtm.hour() + ' ' + dtm.day() + ' '+ dtm.month() + ' ? ' + dtm.year();
                        Sched_DeactivateCardsAfterReplacement sched = new Sched_DeactivateCardsAfterReplacement();
                        sched.cardsOwners = cardsOwners;
                        System.schedule('Deactivate Cards' + cron, cron, sched);
                        
                    } catch(System.AsyncException e) {
                        
                        //Error message
                        String errorMessage = 'already scheduled for execution';
                        
                        //Catch the error is related to already scheduled job
                        if(e.getMessage().containsIgnoreCase(errorMessage)) {
                            
                            //Nothing to do here as the batch is already scheduled
                        } else {
                            
                            //Throw new error 
                            throw new CustomException(e.getMessage());
                        }
                        
                    }
                }
            }
        }
	}
}