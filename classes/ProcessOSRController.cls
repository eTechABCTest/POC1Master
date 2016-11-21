/**
 * 	Purpose			:	This class is to process the OSR request and handle all the transaction in real time
 * 
 * 	Created By		:	Bhavi Sharma
 * 
 * 	Created Date	:	12/04/2014
 * 
 * 	Revision Logs	:	V_1.0 - Created
 						V_1.1 - 10/26/2015 - Bhavi Sharma - CR-20151019-9335 - Only process tthe "Alternate Delivery Request" when it's approved
 *
 **/
public with sharing class ProcessOSRController {
	
	//Properties
	public OSR__c oSR {get; set;}
	public Credit_Card_Settings__c cardSettings = CreditCardConstants.CARD_SETTINGS;
	public String nextPageURL {get; set;}
	public Boolean IsError {get; set;}
    public Boolean makeCallout {get; set;}
	public Boolean IsRequestCompleted {get; set;}
	public String userMessage {get; set;}
	
	//Local properties
	Contact contact;
	Portfolio__c portfolio;
	Credit_Card__c creditCard;
	
	//Constructor
	public ProcessOSRController(ApexPages.StandardController controller) {
		
		//Standard Controller
		oSR = [Select Id, Request_Type__c,
               				Contact__c,
							Agreement_Verified__c, 
							Status__c, 
							Agreement_Received__c, 
							Related_Card__c, 
							Request_Reason__c, 
							Expedited_Processing_Approval__c, 
							Advisory_Profile__c,
               				Address_To_Name__c, 
							Address_Line_1__c, 
							Address_City__c, 
							Address_State__c, 
               				Address_Postal_Code__c from OSR__c 
						Where Id =: controller.getId()];
		
        //Set defaults
        IsError = false;
        makeCallout = false;
        IsRequestCompleted = false;
        userMessage = 'Your request is being processed. Please do not close the browser or click the browser back button.';
    }
	
	/**
	 * 
	 * 
	 * 
	 * 
	 * 
	 * 
	 * 
	 **/
	public void inIt() {
		
        //Create a savepoint to rollback the transaction in case of exception
        Savepoint sp = database.setSavePoint();
        
        try {
            
            //Check for the contact on OSR record
            if(oSR.Contact__c == null)
                throw new CustomException(Label.ERROR_PROCESS_OSR_MISSING_CONTACT);
            
            //Find the matching Protfolio record
            List<Portfolio__c> portfolios = [Select Id from Portfolio__c where Card_Holder__c =: oSR.Contact__c];
            contact = [SELECT Id, BirthDate, FirstName, LastName, Employee_Finance_Code__c, Personal_Address_Line_1__c, 
                                Personal_Address_Line_2__c, Personal_Address_City__c, Personal_Address_State__c, 
                                Personal_Address_PostalCode__c, Legal_First_Name__c, Legal_Last_Name__c, Personal_Address_Country__c 
                                FROM Contact WHERE Id =: oSR.Contact__c LIMIT 1];
            
            //Missing BirthDate
            if(contact.BirthDate == null)
                throw new CustomException(Label.ERROR_PROCESS_OSR_MISSING_CONTACT_BIRTHDATE);
            
            //New Card
            if(oSR.Request_Type__c == CreditCardConstants.OSR_REQUEST_TYPE_NEW_ABC_CREDIT_CARD) {
                
                //Check if Agreement is not verified
                if(oSR.Agreement_Verified__c != true)
                    throw new CustomException(Label.ERROR_PROCESS_OSR_AGREEMENT_UNVERIFIED);
                    
                //Status = Pending Finance
                if(oSR.Status__c != CreditCardConstants.OSR_STATUS_PENDING_FINANCE)
                    throw new CustomException(Label.ERROR_PROCESS_OSR_NOT_PENDING_FINANCE);
                
                //Agreement not received
                if(oSR.Agreement_Received__c == null)
                    throw new CustomException(Label.ERROR_PROCESS_OSR_MISSING_AGREEMENT_DATE);
                
                //portfolio doesn't exist
                if(portfolios.size() == 0) {
                    
                    //Create Portfolio
                    portfolio = new Portfolio__c(Billing_Address_Attention_To__c = mailAttentionTo, Billing_Address_Line_1__c = addressLine1, 
                                                Billing_Address_Line_2__c = addressLine2, Billing_Address_City__c = city, 
                                                Billing_Address_State__c = state, Billing_Address_PostalCode__c = postalCode, 
                                                First_Name_On_Card__c = legalFirstName, Last_Name_On_Card__c = legalLastName, 
                                                Card_Holder__c = contact.Id, Portfolio_Owner_Finance_Code__c = contact.Employee_Finance_Code__c, 
                                                RecordTypeId = cardSettings.Staff_Portfolio_Record_Type__c, Advisory_Profile__c = oSR.Advisory_Profile__c, 
                                                Status__c = cardSettings.Default_Portfolio_Status__c);
                    insert portfolio;
                } else {
                    portfolio = portfolios[0];
                }
             
                //Create a new Credit Card record Now
                creditCard = new Credit_Card__c(Card_Requested_By__c = contact.Id, Card_Set_up_Status__c = CreditCardConstants.CC_SETUP_STATUS_PENDING_RESPONSE, 
                                                            Card_Vendor__c = cardSettings.Card_Vendor__c, Original_Request__c = oSR.Id, 
                                                            Payment_Account__c = portfolio.Id, RecordTypeId = cardSettings.Staff_Card_Record_Type__c, 
                                                            Status__c = cardSettings.New_Card_Status__c);
                                                            
                //Insert Credit card
                insert creditCard;
                
                userMessage = 'Activating credit card in Comdata.';
                
                //OSR with Newly created credit card Id
                oSR.Related_Card__c = creditCard.Id;
                update oSR;
                
                makeCallout = true;
            }
            
            //Replacement Validations
            else if(oSR.Request_Type__c == CreditCardConstants.OSR_REQUEST_TYPE_REPLACEMENT_ABC_CREDIT_CARD
                || oSR.Request_Type__c == CreditCardConstants.OSR_REQUEST_TYPE_REPLACEMENT_ABC_CREDIT_CARD_EXPEDITED) {
                    
                //Check for the address fields
                if(String.isBlank(oSR.Address_To_Name__c) 
                    || String.isBlank(oSR.Address_Line_1__c) 
                    || String.isBlank(oSR.Address_City__c) 
                    || String.isBlank(oSR.Address_State__c) 
                    || String.isBlank(oSR.Address_Postal_Code__c)) {
                    
                    throw new CustomException(Label.ERROR_PROCESS_OSR_MISSING_ADDRESS);
                }
                
                //Check for the expediated approval
                //10/26/2015 - Bhavi Sharma - CR-20151019-9335 - Only process tthe "Alternate Delivery Request" when it's approved
                if(oSR.Request_Type__c == CreditCardConstants.OSR_REQUEST_TYPE_REPLACEMENT_ABC_CREDIT_CARD_EXPEDITED
                    && !CreditCardConstants.OSR_EXPEDITED_PROCESSING_APPROVAL_APPROVED.equalsIgnoreCase(oSR.Expedited_Processing_Approval__c))
                    throw new CustomException(Label.ERROR_PROCESS_OSR_MISSING_EXPEDIATED_APPROVAL);
            	
            	//Deactivate Current Credit card in Salesforce
            	creditCard = getCreditCard(oSR.Related_Card__c);
            	creditCard.Card_Deactivation_Reason__c = osr.Request_Reason__c;
            	creditCard = CreditCardService.interimStageDeactivateCreditCardForReplacement(creditCard);
            	
            	userMessage = 'Credit Card has been deactivated in Salesforce. Creating a new card.';
            	makeCallout = true;
            }
            
            //Deactivation Validation
            else if(oSR.Request_Type__c == CreditCardConstants.OSR_REQUEST_TYPE_DEACTIVATE_ABC_CREDIT_CARD ) {
				
				//Request Reason
				if(String.isBlank(oSR.Request_Reason__c))
                	throw new CustomException(Label.ERROR_PROCESS_OSR_REQUEST_REASON_NOT_APPROVED);
        		
        		//Deactivate Current Credit card in Salesforce
            	creditCard = getCreditCard(oSR.Related_Card__c);
            	creditCard.Status__c = CreditCardConstants.CC_STATUS_PENDING_DEACTIVATION;
            	creditCard.Card_Deactivation_Status__c = CreditCardConstants.CC_DEACTIVATION_STATUS_PENDING_RESPONSE;
            	creditCard.Card_Deactivation_Reason__c = oSR.Request_Reason__c;
            	update creditCard;
            	
            	userMessage = 'Credit Card has been deactivated in Salesforce. Deactivating it in Comdata now.';
            	makeCallout = true;
            }
        } catch(Exception e) {
            
            //Rollback the entire transaction
            database.rollback(sp);
            
            //Add error on page
            ApexPages.addMessages(e);
            IsError = true;
        }
	}
	
	//This method is to process the request in Comdata
	public void processCardInComdata() {
		
		try {
			//Check for the request type
			if(oSR.Request_Type__c == CreditCardConstants.OSR_REQUEST_TYPE_NEW_ABC_CREDIT_CARD) {
				
				//Create Credit card in Comdata
				creditCard = getCreditCard(creditCard.Id);
	            CreditCardService.addCreditCard(creditCard);
	            makeCallout = false;
	            IsRequestCompleted = true;
	            nextPageURL = '/' + creditCard.Id;
	            userMessage = 'Credit card has been created in Comdata';
	            
			} else if((oSR.Request_Type__c == CreditCardConstants.OSR_REQUEST_TYPE_REPLACEMENT_ABC_CREDIT_CARD
	                || oSR.Request_Type__c == CreditCardConstants.OSR_REQUEST_TYPE_REPLACEMENT_ABC_CREDIT_CARD_EXPEDITED)
	                && creditCard.Status__c == CreditCardConstants.CC_STATUS_PENDING_DEACTIVATION) {
	    
	    		
	    		//Replacement credit card in Comdata
	            if(creditCard.Card_Deactivation_Status__c == CreditCardConstants.CC_DEACTIVATION_STATUS_PENDING_RESPONSE)
	            	CreditCardService.deactivateCreditCardForReplacement(creditCard);
	
	            //Clone existing credit card recotrd
	            creditCard = CreditCardService.cloneCreditCardForReplacement(creditCard, oSR);
	            makeCallout = true;
	            IsRequestCompleted = false;
	            userMessage = 'Credit card has been created. Adding credit card in Comdata';
	            
	        } else if((oSR.Request_Type__c == CreditCardConstants.OSR_REQUEST_TYPE_REPLACEMENT_ABC_CREDIT_CARD
	                || oSR.Request_Type__c == CreditCardConstants.OSR_REQUEST_TYPE_REPLACEMENT_ABC_CREDIT_CARD_EXPEDITED)
	                && creditCard.Status__c == CreditCardConstants.CC_STATUS_PENDING_ACTIVATION
	                && creditCard.Card_Set_up_Status__c == CreditCardConstants.CC_SET_UP_STATUS_PENDING_ACTIVATION) {
	        	
	        	//Create Credit card in Comdata
				creditCard = getCreditCard(creditCard.Id);
	            CreditCardService.addCreditCard(creditCard);
	            makeCallout = false;
	            IsRequestCompleted = true;
	            nextPageURL = '/' + creditCard.Id;
	            userMessage = 'Credit card has been created in Comdata';        	
			
			} else if(oSR.Request_Type__c == CreditCardConstants.OSR_REQUEST_TYPE_DEACTIVATE_ABC_CREDIT_CARD ) {
	        	
	    		//Deactivate card in comdata
	    		CreditCardService.deactivateCreditCardForReplacement(creditCard);
	        	makeCallout = false;
	            IsRequestCompleted = true;
	            nextPageURL = '/' + creditCard.Id;
	            userMessage = 'Credit card has been deactivated in Comdata'; 
	        }
		}catch(Exception e) {
			ApexPages.addMessages(e);
            IsError = true;
		}
    }
	
	//Address fields
    public String addressLine1 {
        get {
            if(!String.IsBlank(contact.Personal_Address_Country__c) && CreditCardConstants.SET_UNITED_STATES.contains(contact.Personal_Address_Country__c.toLowerCase())) {
                
                return ContactTriggerUtilities.trunc(contact.Personal_Address_Line_1__c, 30);     
            } else {
                
                return ContactTriggerUtilities.trunc(cardSettings.Alternate_Delivery_Address_1__c, 30);
            }
        }
    }
    
    public String addressLine2 {
        get {
            if(!String.IsBlank(contact.Personal_Address_Country__c) && CreditCardConstants.SET_UNITED_STATES.contains(contact.Personal_Address_Country__c.toLowerCase())) {
                
                return ContactTriggerUtilities.trunc(contact.Personal_Address_Line_2__c, 30);     
            } else {
                
                return ContactTriggerUtilities.trunc(cardSettings.Alternate_Delivery_Address_2__c, 30);
            }
        }
    }
    
    public String city {
        get {
            if(!String.IsBlank(contact.Personal_Address_Country__c) && CreditCardConstants.SET_UNITED_STATES.contains(contact.Personal_Address_Country__c.toLowerCase())) {
                
                return ContactTriggerUtilities.trunc(contact.Personal_Address_City__c, 20);       
            } else {
                
                return ContactTriggerUtilities.trunc(cardSettings.Alternate_Delivery_City__c, 20);
            }
        }
    }
    
    public String state {
        get {
            if(!String.IsBlank(contact.Personal_Address_Country__c) && CreditCardConstants.SET_UNITED_STATES.contains(contact.Personal_Address_Country__c.toLowerCase())) {
                
                return ContactTriggerUtilities.trunc(contact.Personal_Address_State__c, 2);       
            } else {
                
                return ContactTriggerUtilities.trunc(cardSettings.Alternate_Delivery_State__c, 2);
            }
        }
    }
    
    public String postalCode {
        get {
            if(!String.IsBlank(contact.Personal_Address_Country__c) && CreditCardConstants.SET_UNITED_STATES.contains(contact.Personal_Address_Country__c.toLowerCase())) {
                
                return ContactTriggerUtilities.trunc(contact.Personal_Address_PostalCode__c, 10);     
            } else {
                
                return ContactTriggerUtilities.trunc(cardSettings.Alternate_Delivery_Postal_Code__c, 10);
            }
        }
    }
    
    public String mailAttentionTo {
        get {
            if(!String.IsBlank(contact.Personal_Address_Country__c) && CreditCardConstants.SET_UNITED_STATES.contains(contact.Personal_Address_Country__c.toLowerCase())) {
                
                return null;        
            } else {
                
                return ContactTriggerUtilities.trunc(cardSettings.Alternate_Delivery_Attention_To__c, 35);
            }
        }
    }
    
    public String legalFirstName {
        get {
            return ContactTriggerUtilities.trunc(contact.Legal_First_Name__c, 15);
        }
    }
    
    public String legalLastName {
        get {
            return ContactTriggerUtilities.trunc(contact.Legal_Last_Name__c, 20);
        }
    }
    
    //Query latest information of credit card
    public Credit_Card__c getCreditCard(Id creditCardId) {
        
        return [SELECT Id, Name,
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
                        Payment_Account__r.Billing_Address_Updated__c,
                        Payment_Account__r.Portfolio_Owner_Finance_Code__c,
                        Payment_Account__r.Card_Holder__r.Birthdate,
                        Payment_Account__r.Card_Count__c,
                        Payment_Account__r.First_Name_On_Card__c,
                        Payment_Account__r.Last_Name_On_Card__c,
                        Payment_Account__r.Billing_Address_Attention_To__c,
                        Payment_Account__r.Billing_Address_Line_1__c,
                        Payment_Account__r.Billing_Address_Line_2__c,
                        Payment_Account__r.Billing_Address_City__c,
                        Payment_Account__r.Billing_Address_State__c,
                        Payment_Account__r.Billing_Address_PostalCode__c,
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
                        FROM Credit_Card__c WHERE Id =: creditCardId];
    }
}