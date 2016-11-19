/**
 *  Purpose         :   This class is controller for add & update Credit Card request from pages.
 *
 *  Created By      :   Bhavi Sharma
 *
 *  Created Date    :   08/10/2013
 *
 *  Current Version :   V_1.0 - Created
                        V_1.1 - 05/17/2014 - Bhavi Sharma - Modified(Updated replaceCard method) - CR-20140515-5525
                        V_1.2 - 10/23/2015 - Bhavi Sharma - Modiofied - CR-20151002-9293: Added address field in query
                        V_1.2 - 11/06/2015 - Bhavi Sharma - Modiofied - CR-20151002-9293: When it's a new request, create an OSR  and mark it as completed
                        V_1.3 - 12/11/2015 - Mahendra Swarnkar - Modiofied - CR-20151105-9370 - Updated the replaceCreditCard method and added the portfolio fields status and deactivation reason
 **/
public without sharing class CreditCardController {

    //Credit Card Object record
    Credit_Card__c creditCard;

    //Page reference
    PageReference nextPage;

    //Constructor definition of standard controller
    public CreditCardController(ApexPages.StandardController controller) {
		
		//Modified By - Mahendra Swarnkar- CR-20151105-9370 - 12/11/2015 - Updated the query to fetch portfolio fields i.e. status and deactivation reason. 
        //Fetch credit card data
        creditCard = [SELECT Id, Name,
                        Card_Set_up_Status__c,
                        Card_Owner__c,
                        Credit_Card_Number__c,
                        Card_Number__c,
                        Card_Vendor__c,
                        Card_Expiration__c,
                        Card_Status_Code__c,
                        Card_Deactivation_Reason__c,
                        Status__c, 
                        Comdata_Status__c,
                        Card_Holder_First_Name__c,
                        Card_Holder_Last_Name__c,
                        Card_Deactivation_Status__c,
                        Card_Employee_Number__c,
                        Product_Code__c,
                        Cycle_Type__c,
                        Product_Available_Flag__c,
                        Payment_Account__c,
                        Update_Billing_Address_On_Activation__c,
                        Payment_Account__r.Billing_Address_Updated__c,
                        Payment_Account__r.Portfolio_Owner_Finance_Code__c,
                        Payment_Account__r.Card_Count__c,
                        Payment_Account__r.First_Name_On_Card__c,
                        Payment_Account__r.Last_Name_On_Card__c,
                        Payment_Account__r.Billing_Address_Attention_To__c,
                        Payment_Account__r.Billing_Address_Line_1__c,
                        Payment_Account__r.Billing_Address_Line_2__c,
                        Payment_Account__r.Billing_Address_City__c,
                        Payment_Account__r.Billing_Address_State__c,
                        Payment_Account__r.Billing_Address_PostalCode__c,
                        Payment_Account__r.Card_Holder__c,
                        Payment_Account__r.Card_Holder__r.BirthDate,
                        Original_Request__c,
                        Original_Request__r.International_Address__c,
                        Original_Request__r.Address_To_Name__c,
                        Original_Request__r.Address_Line_1__c,
                        Original_Request__r.Address_Line_2__c,
                        Original_Request__r.Address_City__c,
                        Original_Request__r.Address_State__c,
                        Original_Request__r.Address_Postal_Code__c,
                        Original_Request__r.Expedited_Processing_Approval__c,
                        Original_Request__r.Request_Type__c,
                        Payment_Account__r.Status__c,
                        Payment_Account__r.Deactivation_Reason__c
                        FROM Credit_Card__c WHERE Id =: controller.getId()];
    }

    /**
     *  @description    :   This method will be call when user clicks on "Create credit Card" button from the Credit Card detail page
     *
     *  @args           :
     *
     *  @return         :   PageReference
     *
     **/
    public Pagereference addCreditCard(){
       
        try {

            //Set intermediate stage
            if(creditCard.Status__c != CreditCardConstants.CC_STATUS_VENDOR_APPROVAL && (creditCard.Credit_Card_Number__c == null || creditCard.Credit_Card_Number__c == '')
                    && (creditCard.Card_Set_up_Status__c != null && creditCard.Card_Set_up_Status__c != CreditCardConstants.CC_SETUP_STATUS_PENDING_RESPONSE)) {

                //Call Credit card service to set the intermidiate stage
                CreditCardService.interimStageAddCreditCard(creditCard);
                nextPage = Page.CreditCard_Activation;
                nextPage.getParameters().put('id', creditCard.Id);
                nextPage.setRedirect(true);
            } else if(creditCard.Card_Set_up_Status__c != null && creditCard.Card_Set_up_Status__c == CreditCardConstants.CC_SETUP_STATUS_PENDING_RESPONSE) {
                    
                //Create Credit card in Comdata
                CreditCardService.addCreditCard(creditCard);
                nextPage = new ApexPages.StandardController(creditCard).view();
            } else{
                
                nextPage = new ApexPages.Standardcontroller(creditCard).view();
            }
        } catch(Exception e) {

            //Add error on page
            ApexPages.addMessages(e);
            nextPage = null;
        }

        return nextPage;
    }

    /**
     *  @description    :   This method will be call when user clicks on "Replace Credit Card" button from the Credit Card detail page
     *                          Replacing a card is basically 2 different steps
     *                          1.  Deactivating the current card
     *                          2.  Setting up a new Card
     *  @args           :
     *
     *  @return         :   PageReference
     *
     **/
    public Pagereference replaceCreditCard(){

        try {
			
			//Create a new OSR
			OSR__c oSR = new OSR__c(Request_Type__c = CreditCardConstants.OSR_REQUEST_TYPE_REPLACEMENT_ABC_CREDIT_CARD,
										Subject__c = CreditCardConstants.OSR_REQUEST_TYPE_REPLACEMENT_ABC_CREDIT_CARD,
										Status__c = CreditCardConstants.OSR_STATUS_IN_PROGRESS, Contact__c = creditCard.Payment_Account__r.Card_Holder__c, 
										Priority__c = CreditCardConstants.OSR_PRIORITY_CREATE_MEDIUM, 
										Origin__c = CreditCardConstants.OSR_ORIGIN_SALESFORCE, Related_Card__c =  creditCard.Id);
            insert oSR;
			
		    //Deactivate existing card first
            //Set intermediate stage
            if(creditCard.Status__c != CreditCardConstants.CC_STATUS_PENDING_DEACTIVATION && creditCard.Card_Deactivation_Status__c != CreditCardConstants.CC_DEACTIVATION_STATUS_PENDING_RESPONSE) {
				
				//Call Credit card service to set the intermidiate stage
            	CreditCardService.interimStageDeactivateCreditCardForReplacement(creditCard);
            	nextPage = Page.CreditCard_Replacement;
            	nextPage.getParameters().put('id', creditCard.Id);
            	nextPage.setRedirect(true);
                
            } else {
				
				//Updated By- Mahendra Swarnkar - 12/11/2015 - Updated the status and card deactivation reason of credit card to deactivated,
				//if new card will be replace the existing old card, which was deactivated due to the over age/balance transactions.
				//start From here
				//Check for condition
				if((creditCard.Card_Deactivation_Reason__c == Label.DEACTIVATION_OVER_TRANSACTION_DAYS
				   || creditCard.Card_Deactivation_Reason__c == Label.DEACTIVATION_OVER_CREDIT_LIMIT)
				   && creditCard.Payment_Account__r.Status__c == CreditCardConstants.PORTFOLIO_STATUS_DEACTIVATED
				   &&(creditCard.Payment_Account__r.Deactivation_Reason__c == CreditCardConstants.PORTFOLIO_DEACTIVATION_REASON_OVER_AGE_LIMIT 
						||creditCard.Payment_Account__r.Deactivation_Reason__c == CreditCardConstants.PORTFOLIO_DEACTIVATION_REASON_OVER_CREDIT_BALANNCE_LIMIT))
                {
                	//Update the existing old card with updated values 
                	creditCard.Card_Deactivation_Status__c = CreditCardConstants.CC_DEACTIVATION_STATUS_DEACTIVATED;
                	creditCard.Status__c = CreditCardConstants.CC_STATUS_DEACTIVATED;
                	update creditCard;
                
                } else{
                
                //Replacement credit card in Comdata 
                if(creditCard.Card_Deactivation_Status__c == CreditCardConstants.CC_DEACTIVATION_STATUS_PENDING_RESPONSE)
                    CreditCardService.deactivateCreditCardForReplacement(creditCard);
                }
				//Ends here
				
				//Clone existing credit card recotrd
                creditCard = CreditCardService.cloneCreditCardForReplacement(creditCard, oSR);
                
                nextPage = Page.CreditCard_Activation;
                nextPage.getParameters().put('id', creditCard.Id);
                nextPage.setRedirect(true);
			} 
        } catch(Exception e) {

            //Add error on page
            ApexPages.addMessages(e);
            nextPage = null;
        }

        return nextPage;
    }

    /**
     *  @description    :   This method will be call when user clicks on "Deactivate" button from the Credit Card detail page
     *
     *  @args           :
     *
     *  @return         :   PageReference
     *
     **/
    public Pagereference deactivateCreditCard() {

        try {

            //Deactivate existing card first
            //Set intermediate stage
            if(creditCard.Status__c != CreditCardConstants.CC_STATUS_PENDING_DEACTIVATION && creditCard.Card_Deactivation_Status__c != CreditCardConstants.CC_DEACTIVATION_STATUS_PENDING_RESPONSE) {

                //Call Credit card service to set the intermidiate stage
                CreditCardService.interimStageDeactivateCreditCard(creditCard);
                nextPage = Page.CreditCard_Deactivation;
                nextPage.getParameters().put('id', creditCard.Id);
                nextPage.setRedirect(true);
            } else {

                //deactivate credit card
                CreditCardService.deactivateCreditCard(creditCard, null);
                nextPage = new ApexPages.StandardController(creditCard).view();
            }
        }catch(Exception e) {

            //Add error on page
            ApexPages.addMessages(e);
            nextPage = null;
        }

        return nextPage;
    }

    /**
     *  @description    :   This method will be call when user clicks on "Unblock Card" button from the Credit Card detail page
     *
     *  @args           :
     *
     *  @return         :   PageRefrence
     *
     **/
     public Pagereference unBlockCreditCard() {

        try {

            //Create Credit card in Comdata
            CreditCardService.activateCreditCardInRealTime(creditCard.Id);
            nextPage = new ApexPages.StandardController(creditCard).view();
        } catch(Exception e) {

            //Add error on page
            ApexPages.addMessages(e);
            nextPage = null;
        }

        return nextPage;
    }

    /**
     *  @description    :   This method will be call when user clicks on "Inquire Card" button from the Credit Card detail page
     *
     *  @args           :
     *
     *  @return         :   PageRefrence
     *
     **/
     public Pagereference inquireCreditCard() {

        try {

            //Inquire Card
            HTTPResponseParser.InquireCardResponse inquireCardResponse = CreditCardService.inquireCreditCard(creditCard, true);
            
            //Match teh COmadata status with the Credit Card Status
            if(inquireCardResponse != null 
                && inquireCardResponse.cardDetails != null 
                && String.isNotBlank(inquireCardResponse.cardDetails.cardStatus)) {
            	
            	//Populate comdata status
            	if(creditCard.Comdata_Status__c != inquireCardResponse.cardDetails.cardStatus) {
            		
            		//Update the field comdata status
            		creditCard.Comdata_Status__c = inquireCardResponse.cardDetails.cardStatus;
            		update creditCard;
            	}
            }
            nextPage = new ApexPages.StandardController(creditCard).view();

        } catch(Exception e) {

            //Add error on page
            ApexPages.addMessages(e);
            nextPage = null;
        }

        return nextPage;
    }

    //Method to inquireCardSecurityCode request to Comdata Service
    public Pagereference inquireCardSecurityCode() {

        try {

            //Update Credit Card
            CreditCardService.inquireCardSecurityCode(creditCard.ID, true);
            nextPage = new ApexPages.StandardController(creditCard).view();

        } catch(Exception e) {

            //Add error on page
            ApexPages.addMessages(e);
            nextPage = null;
        }

        return nextPage;
    }

    //Method to update Credit Card request to Comdata Service
    public Pagereference updateCreditCard() {

        try {

            //Update Credit Card
            CreditCardService.updateCreditCard(creditCard.ID);
            nextPage = new ApexPages.StandardController(creditCard).view();

        } catch(Exception e) {

            //Add error on page
            ApexPages.addMessages(e);
            nextPage = null;
        }

        return null;
    }
}