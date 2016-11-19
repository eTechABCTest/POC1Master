/**
 *  Purpose         :   Service calls for Credit Card functionlity
 *
 *  Created By      :   Bhavi Sharma
 *
 *  Created Date    :   08/10/2013
 *
 *  Current Version :   V_1.0 - Created
                        V_1.1 - 05/17/2014 - Bhavi Sharma - Modified updateCardProfileLimits method CR-20140515-5525
                        V_1.2 - 10/28/2014 - Colin McGloin - Commented out 'updateCardProfileLimits' method - CR-7702
                        V_1.3 - 10/24/2015 - Bhavi Sharma - Updated Billing_Address_Updated__c in updateCard query - CR-7702
                        V_1.4 - 12/1/2015 - Mahendra Swarnkar - CR-20151113-9381 -Updated the method "activateCreditCard", to provide/allow a 24 hour reprieve for cards that are over thresholds
                        V_1.5 - 12/07/2015 - Mahendra Swarnkar - CR-20151105-9370 -Updated the method "activateCreditCard".
                        
 **/
global class CreditCardService {

    //variable to create the request log
    public static String Request_Log = '';

    //String to hold status as Blocked
    public static String CARD_STATUS_BLOCKED = 'Blocked';

    //Variable to hold Comdata credit card Default Hierarchy custom setting
    public static Credit_Card_Settings__c configCCDefaultSetting = CreditCardConstants.CONFIG_DEFAULT;

    //Variable to hold the request time value
    static DateTime requestTime = DateTime.now();

    /**
     *  @description    :   This method is to set the credit card record from interim stage when user request for Create Credit Card
                                1.  Status = Vendor Approval
                                2.  Card Set Up Status = Pending Response

     *  @args           :   SFDC Credit Card record
     *
     *  @return         :   void
     *
     **/
    public static void interimStageAddCreditCard(Credit_Card__c creditCard) {

        //Setup Intermediate values
        creditCard.Status__c = CreditCardConstants.CC_STATUS_VENDOR_APPROVAL;
        creditCard.Card_Set_up_Status__c = CreditCardConstants.CC_SETUP_STATUS_PENDING_RESPONSE;
        update creditCard;
    }

    /**
     *  @description    :   This method is to create a credit card in comdata
     *
     *  @args           :   SFDC Credit Card record
     *
     *  @return         :   void
     *
     **/
    public static Credit_Card__c addCreditCard(Credit_Card__c creditCard) {

        //Get request Envelope
        String requestEnvelope;

        //Check for OSR's Internation Address is true, else Expedited Approved or not
        if(creditCard.Original_Request__r.Expedited_Processing_Approval__c == CreditCardConstants.OSR_EXPEDITED_PROCESSING_APPROVAL_APPROVED)
            requestEnvelope = CreditCardHelper.getAddCreditCardExpediatedRequestEnvelope(creditCard);
        else
            requestEnvelope = CreditCardHelper.getAddCreditCardRequestEnvelope(creditCard);

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
                if(!Test.isRunningTest())
                    inquireCardResponse = CreditCardService.inquireCreditCard(creditCard, false);
                
                //Populate and Update Credit Card record with some additional values
                creditCard.Status__c = CreditCardConstants.CC_STATUS_PENDING_ACTIVATION;
                creditCard.Comdata_Status__c  = 'B';
                creditCard.Card_Set_up_Status__c = CreditCardConstants.CC_SET_UP_STATUS_PENDING_ACTIVATION;
                creditCard.Credit_Card_Number__c = response.cardNumber;
                if(!Test.isRunningTest())
                    creditCard.Card_Expiration__c = CreditCardHelper.buildDate(inquireCardResponse.cardDetails.cardExpiration);
                creditCard.Card_Number__c = CreditCardService.Encrypt(response.cardNumber);
                update creditCard;

                //Close original request
                if(creditCard.Original_Request__c != null) {
                    OSR__c originalRequest = new OSR__c(Id = creditCard.Original_Request__c, Status__c = CreditCardConstants.OSR_STATUS_COMPLETE);
                    update originalRequest;
                }

                //Create a log record
                CreditCardLogger.Log(creditCard, null, requestTime, CreditCardService.Request_Log, requestEnvelope,
                                        String.valueOf(response), 'CreditCardService', 'addCreditCard', 'addCard');
            } else {

                //Populate and Update Credit Card record with some additional values
                creditCard.Status__c = CreditCardConstants.CC_STATUS_REQUEST_DECLINED;
                creditCard.Card_Set_up_Status__c = CreditCardConstants.CC_SETUP_STATUS_DECLINED;
                update creditCard;

                throw new CustomException(response.responseDescription);
            }

        } catch(Exception e){

            //Create a log record
            CreditCardLogger.Log(creditCard, e.getMessage(), requestTime, CreditCardService.Request_Log, requestEnvelope,
                                    e.getMessage(), 'CreditCardService', 'addCreditCard', 'addCard');

            throw e;
        }
        return creditCard;
    }

    /**
     *  @description    :   This method is to activate the Card in Comdata in real time
     *
     *  @args           :   SFDC Credit Card record id
     *
     *  @return         :   void
     *
     **/
    public static void activateCreditCardInRealTime(Id creditCardId) {

        //Call activate Card method
        CreditCardService.activateCreditCard(new Set<Id>{creditCardId});
    }

    /**
     *  @description    :   This method is to activate the Card in Comdata with async call
     *
     *  @args           :   SFDC Credit Card record id
     *
     *  @return         :   void
     *
     **/
    @future(callout=true)
    public static void activateCreditCardInFuture(Set<Id> creditCardIds) {

        //Call activate Card method
        try {
            CreditCardService.activateCreditCard(creditCardIds);
    
        } catch (Exception e) {
            
            //If any exception occurs during processing the card, set the Card Set up Status back to New
            
            //Create a list of Credit Cards
            List<Credit_Card__c> cCards = new List<Credit_Card__c>();
            
            for(Id cId : creditCardIds)
                cCards.add(new Credit_Card__c(Id = cId, Card_Set_up_Status__c = 'New'));
            
            //Bypass all the triggers
            Util.BypassAllTriggers = true;
            update cCards;
        	Util.BypassAllTriggers = false;
            
            //Put the error message in log
            System.debug('Error: ' + e);
        }
    }

    /**
     *  @description    :   This method is to create a request for activating card in Comdata
     *
     *  @args           :   SFDC Credit Card record id
     *
     *  @return         :   void
     *
     **/
    public static void activateCreditCard(Set<Id> creditCardIds) {
        
        //Modified By - Mahendra Swarnkar - CR-20151105-9370 - 12/11/2015 - Added the condition to also fetch those credit cards, 
        //whose portfolio as well as credit card itself were deactivated due to over age/credit transaction limit
        //Fetch credit card data
        List<Credit_Card__c> creditCards = [SELECT Id,
                                                    Card_Employee_Number__c,
                                                    Credit_Card_Number__c,
                                                    Payment_Account__r.Card_Holder__c,
                                                    Payment_Account__r.Portfolio_Owner_Finance_Code__c,
                                                    Card_Holder_First_Name__c,
                                                    Card_Holder_Last_Name__c,
                                                    Original_Request__c,
                                                    Update_Billing_Address_On_Activation__c, Payment_Account__r.Billing_Address_Line_1__c, Payment_Account__r.Billing_Address_Line_2__c, Payment_Account__r.Billing_Address_City__c, Payment_Account__r.Billing_Address_State__c, Payment_Account__r.Billing_Address_PostalCode__c, Payment_Account__r.Billing_Address_Attention_To__c ,Payment_Account__r.First_Name_On_Card__c, Payment_Account__r.Last_Name_On_Card__c,
                                                    Payment_Account__c,
                                                    Payment_Account__r.Status__c,
                                                    Payment_Account__r.Deactivation_Reason__c,
                                                    Payment_Account__r.Warning_Email_Status__c,
                                                    Status__c,
                                                    Card_Deactivation_Reason__c
                                                    FROM Credit_Card__c WHERE Id IN:creditCardIds];

        //Check for size of list
        if(creditCards.size() > 0) {
            
            //Added By - Mahendra Swarnkar - 12/07/2015 - CR-20151105-9370
            //Starts from here
            //Set of Portfolio
            Set<ID> setPortfolios = new Set<ID>();
            
            //Populating setPortfolios with those portfolios who have status = Deactivated, Deactivation Reason = Over Age or Over Balanc, Credit Card Status = Deactivated and Card Deactivation Reason = Over Age or Over Balance
            for(Credit_Card__c creditCard : creditCards){
                
                System.debug('creditCard:::::'+ creditCard);
                //Check for condition
                if(creditCard.Payment_Account__r.Status__c == CreditCardConstants.PORTFOLIO_STATUS_DEACTIVATED
                    && (creditCard.Payment_Account__r.Deactivation_Reason__c == CreditCardConstants.PORTFOLIO_DEACTIVATION_REASON_OVER_AGE_LIMIT 
                        || creditCard.Payment_Account__r.Deactivation_Reason__c == CreditCardConstants.PORTFOLIO_DEACTIVATION_REASON_OVER_CREDIT_BALANNCE_LIMIT )
                    && (((creditCard.Status__c == CreditCardConstants.CC_STATUS_DEACTIVATED
                            && (creditCard.Card_Deactivation_Reason__c == Label.DEACTIVATION_OVER_CREDIT_LIMIT 
                                || creditCard.Card_Deactivation_Reason__c == Label.DEACTIVATION_OVER_TRANSACTION_DAYS))
                        )
                        || (creditCard.Status__c == CreditCardConstants.CC_STATUS_PENDING_ACTIVATION 
                            && String.IsBlank(creditCard.Card_Deactivation_Reason__c)))
                    ) {
                    
                    //Populating setPortfolios
                    setPortfolios.add(creditCard.Payment_Account__c);
                }
            }
            //Ends here
            
            //List to be update
            List<Credit_Card__c> cardsToUpdate = new List<Credit_Card__c>();
            
            //List to be update
            List<Portfolio__c> portfolios = new List<Portfolio__c>();
            
            //Loop through queried result
            for(Credit_Card__c creditCard : creditCards) {
                
                System.debug('setPortfolios:::::'+ setPortfolios);
                
                
                //Modified By - Mahendra Swarnkar - 12/07/2015 - CR-20151105-9370 - Before activating the credit card, To check if there is any other card associated witth the same Portfolio which was deactivated due to Over Age or Over Balance and transaction has not been submitted yet.
                //In that case, do not allow user to activate the current card and throw an error messgae for clearing the old transactions. 
                //Starts from here
                if(setPortfolios.size()> 0 
                    && setPortfolios.contains(creditCard.Payment_Account__c)
                    && creditCard.Status__c == CreditCardConstants.CC_STATUS_PENDING_ACTIVATION) {
                    
                    //Error message
                    throw new CustomException('Clear your transactions before activating the new card');
                }else {
                    
                    //Get request Envelope
                    String requestEnvelope = CreditCardHelper.getActivateCreditCardEnvelope(creditCard);
    
                    try {
    
                        //Make callout and parse response
                        HttpRequest request = HTTPRequestBuilder.CreateRequest(configCCDefaultSetting.Endpoint__c, CreditCardConstants.REQUEST_TYPE_POST, CreditCardConstants.SOAP_ACTION_UPDATE_CARD, requestEnvelope);
                        HttpResponse hResponse = HTTPService.send(request);
                        HTTPResponseParser.CardAddUpdateResponse response = HTTPResponseParser.parseUpdateCardResponse(hResponse);
    
                        //Check for success
                        if(response.responseCode == CreditCardConstants.ZERO) {
    
                            //Check if request is validresponse
                            if(response.trackingNumber != CreditCardHelper.trackingNumberForEnvelope)
                                throw new CustomException('Invalid request.');
    
                            //Populate and Update Credit Card record with some additional values
                            creditCard.Status__c = CreditCardConstants.CC_STATUS_ACTIVE;
                            creditCard.Comdata_Status__c  = 'A';
                            creditCard.Card_Set_up_Status__c = CreditCardConstants.CC_SETUP_STATUS_SUCCESS;
                            creditCard.Card_Deactivation_Status__c = '';
                            creditCard.Card_Deactivation_Reason__c = null;
                            creditCard.Update_Billing_Address_On_Activation__c = false;
                            cardsToUpdate.add(creditCard);
                            
                            //Added by -Mahendra Swarnkar - CR-20151113-9381 -12/1/2015 - To provide/allow a 24 hour reprieve for cards that are over thresholds
                            //Start from here
                            //Criteria Condition
                            If(creditCard.Payment_Account__r.Status__c != CreditCardConstants.PORTFOLIO_STATUS_ACTIVATED 
                                || creditCard.Payment_Account__r.Deactivation_Reason__c != null 
                                || creditCard.Payment_Account__r.Warning_Email_Status__c != null) {
                             
                                //Add the portfolio instance in list
                                portfolios.add(new Portfolio__c(Id = creditCard.Payment_Account__c, Status__c = CreditCardConstants.PORTFOLIO_STATUS_ACTIVATED,  Deactivation_Reason__c = null, Warning_Email_Status__c = null));
                            }
                            //Ends here
                            
                            //Close original request
                            if(creditCard.Original_Request__c != null) {
                                OSR__c originalRequest = new OSR__c(Id = creditCard.Original_Request__c, Status__c = CreditCardConstants.OSR_STATUS_COMPLETE);
                                update originalRequest;
                            }
    
                            //Create a log record
                            CreditCardLogger.Log(creditCard, null, requestTime, CreditCardService.Request_Log, requestEnvelope,
                                                    String.valueOf(response), 'CreditCardService', 'activateCreditCard', 'updateCard');
                        } else
                            throw new CustomException(response.responseDescription);
                    } catch(Exception e){
    
                        //Populate and Update Credit Card record with some additional values
                        creditCard.Status__c = CreditCardConstants.CC_STATUS_DEACTIVATED;
                        creditCard.Card_Set_up_Status__c = CreditCardConstants.CC_SET_UP_STATUS_ACTIVATION_FAILED;
                        creditCard.Card_Deactivation_Reason__c = null;
                        update creditCard;
    
                        //Create a log record
                        CreditCardLogger.Log(creditCard, e.getMessage(), requestTime, CreditCardService.Request_Log, requestEnvelope,
                                                e.getMessage(), 'CreditCardService', 'activateCreditCard', 'updateCard');
    
                        throw e;
                    }
                } 
            }

            //Check for size of list and update Credit Card
            if(cardsToUpdate.size() > 0)
                update cardsToUpdate;
            
            //Added by -Mahendra Swarnkar - CR-20151113-9381 -12/1/2015
            //Start from here
            //Check for size of list and update Portfolios
            If(portfolios.size() > 0) {
               
                //Deactivate all the triggers    
                Util.BypassAllTriggers = true;
                
                //Update
                update portfolios;
               
                //Reactivate all the triggers        
                Util.BypassAllTriggers = false;
            }
            //Ends here
        }
    }

    /**
     *  @description    :   This method is to set the credit card record from interim stage when user request for Create Credit Card
                                1.  Status = Pending Deactivation
                                2.  Card Deactivation Status = Pending Response

     *  @args           :   SFDC Credit Card record
     *
     *  @return         :   void
     *
     **/
    public static void interimStageDeactivateCreditCard(Credit_Card__c creditCard) {

        //Setup Intermediate values
        creditCard.Status__c = CreditCardConstants.CC_STATUS_PENDING_DEACTIVATION;
        creditCard.Card_Deactivation_Status__c = CreditCardConstants.CC_DEACTIVATION_STATUS_PENDING_RESPONSE;
        update creditCard;
    }
    
    /**
     *  @description    :   This method is to set the credit card record from interim stage when user request for Create Credit Card
                                1.  Status = Pending Deactivation
                                2.  Card Deactivation Status = Pending Response

     *  @args           :   SFDC Credit Card record
     *
     *  @return         :   void
     *
     **/
    public static Credit_Card__c interimStageDeactivateCreditCardForReplacement(Credit_Card__c creditCard) {
        
        //Setup Intermediate values
        creditCard.Status__c = CreditCardConstants.CC_STATUS_PENDING_DEACTIVATION;
        
        //Check for the card dectivation Reason
        //If it is lost or stolen, Deactivate it
        //Else keep ot activated and only update the reson
        if(creditCard.Card_Deactivation_Reason__c == CreditCardConstants.CC_CARD_DEACTIVATION_REASON_LOST || creditCard.Card_Deactivation_Reason__c == CreditCardConstants.CC_CARD_DEACTIVATION_REASON_STOLEN) {
            creditCard.Card_Deactivation_Status__c = CreditCardConstants.CC_DEACTIVATION_STATUS_PENDING_RESPONSE; 
        } else {
            creditCard.Card_Deactivation_Status__c = CreditCardConstants.CC_DEACTIVATION_STATUS_PENDING_REPLACEMENT_ACTIVATION;  //To be deactivated once user activates new card
        }
        
        update creditCard;
        return creditCard;
    
    }

    /**
     *  @description    :   This method is to create a request for deactivating card in Comdata
     *
     *  @args           :   SFDC Credit Card record id
     *
     *  @return         :   void
     *
     **/
    public static void deactivateCreditCard(Credit_Card__c creditCard, String deactivationReason) {

        //Get request Envelope
        String requestEnvelope = CreditCardHelper.getDeactivateCreditCardEnvelope(creditCard);

        try {
            HTTPResponseParser.CardAddUpdateResponse response = new HTTPResponseParser.CardAddUpdateResponse();
            If(!Test.isRunningTest()){
                //Make callout and parse response
                HttpRequest request = HTTPRequestBuilder.CreateRequest(configCCDefaultSetting.Endpoint__c, CreditCardConstants.REQUEST_TYPE_POST, CreditCardConstants.SOAP_ACTION_UPDATE_CARD, requestEnvelope);
                HttpResponse hResponse = HTTPService.send(request);
                response = HTTPResponseParser.parseUpdateCardResponse(hResponse);
            }else{
                //If this is being run as a Test, mock the response since we don't actually want to call the web service
                //HTTPResponseParser.CardAddUpdateResponse response = new HTTPResponseParser.CardAddUpdateResponse();
                response.responseCode = CreditCardConstants.ZERO;
                response.trackingNumber = CreditCardHelper.trackingNumberForEnvelope;
                response.responseDescription = 'Test class';
            }

            //Check for success
            if(response.responseCode == CreditCardConstants.ZERO) {

                //Check if request is validresponse
                if(response.trackingNumber != CreditCardHelper.trackingNumberForEnvelope)
                    throw new CustomException('Invalid request.');

                //Populate and Update Credit Card record with some additional values
                creditCard.Status__c = CreditCardConstants.CC_STATUS_DEACTIVATED;
                creditCard.Comdata_Status__c = 'B';
                creditCard.Card_Deactivation_Status__c = CreditCardConstants.CC_DEACTIVATION_STATUS_DEACTIVATED;
                creditCard.Card_Deactivation_Reason__c = deactivationReason;
                update creditCard;

                //Close original request
                if(creditCard.Original_Request__c != null) {
                    OSR__c originalRequest = new OSR__c(Id = creditCard.Original_Request__c, Status__c = CreditCardConstants.OSR_STATUS_COMPLETE);
                    update originalRequest;
                }

                //Create a log record
                CreditCardLogger.Log(creditCard, null, requestTime, CreditCardService.Request_Log, requestEnvelope,
                                        String.valueOf(response), 'CreditCardService', 'deactivateCreditCard', 'updateCard');
            } else
                throw new CustomException(response.responseDescription);
        } catch(Exception e){

            //Create a log record
            CreditCardLogger.Log(creditCard, e.getMessage(), requestTime, CreditCardService.Request_Log, requestEnvelope,
                                    e.getMessage(), 'CreditCardService', 'deactivateCreditCard', 'updateCard');

            throw e;
        }
    }
    
    /**
     *  @description    :   This method is to create a request for replacement card in Comdata
     *
     *  @args           :   SFDC Credit Card record id
     *
     *  @return         :   void
     *
     **/
    public static void deactivateCreditCardForReplacement(Credit_Card__c creditCard) {
        
        //Validate Credit Card record for Required field values
        CreditCardService.validateCreditCardForRequiredField(creditCard);

        String requestEnvelope = CreditCardHelper.getDeactivateCreditCardForReplacementEnvelope(creditCard);

        try {

            //Make callout and parse response
            HttpRequest request = HTTPRequestBuilder.CreateRequest(configCCDefaultSetting.Endpoint__c, CreditCardConstants.REQUEST_TYPE_POST, CreditCardConstants.SOAP_ACTION_UPDATE_CARD, requestEnvelope);
            HttpResponse hResponse = HTTPService.send(request);
            HTTPResponseParser.CardAddUpdateResponse response = HTTPResponseParser.parseUpdateCardResponse(hResponse);

            //Check for success
            if(response.responseCode == CreditCardConstants.ZERO) {

                //Check if request is validresponse
                if(response.trackingNumber != CreditCardHelper.trackingNumberForEnvelope)
                    throw new CustomException('Invalid request.');

                //Populate and Update Credit Card record with some additional values
                creditCard.Status__c = CreditCardConstants.CC_STATUS_DEACTIVATED;
                creditCard.Comdata_Status__c  = 'B';
                creditCard.Card_Deactivation_Status__c = CreditCardConstants.CC_DEACTIVATION_STATUS_DEACTIVATED;
                update creditCard;

                //Close original request
                if(creditCard.Original_Request__c != null) {
                    OSR__c originalRequest = new OSR__c(Id = creditCard.Original_Request__c, Status__c = CreditCardConstants.OSR_STATUS_COMPLETE);
                    update originalRequest;
                }

                //Create a log record
                CreditCardLogger.Log(creditCard, null, requestTime, CreditCardService.Request_Log, requestEnvelope,
                                        String.valueOf(response), 'CreditCardService', 'replacementCreditCard', 'updateCard');
            } else
                throw new CustomException(response.responseDescription);
        } catch(Exception e){

            //Create a log record
            CreditCardLogger.Log(creditCard, e.getMessage(), requestTime, CreditCardService.Request_Log, requestEnvelope,
                                    e.getMessage(), 'CreditCardService', 'replacementCreditCard', 'updateCard');

            throw e;
        }
    }

    /**
     *  @description    :   This method is to inquiry a credit card in comdata
     *
     *  @args           :   SFDC Credit Card record ID, boolean
     *
     *  @return         :   void
     *
     **/
    public static HTTPResponseParser.InquireCardResponse inquireCreditCard(Credit_Card__c creditCard, Boolean createLog) {

        //Validate Credit Card record for Required field values
        CreditCardService.validateCreditCardForRequiredField(creditCard);

        //Get request Envelope
        String requestEnvelope = CreditCardHelper.getInquireCreditCardEnvelope(creditCard);
        HTTPResponseParser.InquireCardResponse response;
        try {

            //Make callout and parse response
            HttpRequest request = HTTPRequestBuilder.CreateRequest(configCCDefaultSetting.Endpoint__c, CreditCardConstants.REQUEST_TYPE_POST, CreditCardConstants.SOAP_ACTION_INQUIRE_CARD, requestEnvelope);
            HttpResponse hResponse = HTTPService.send(request);
            response = HTTPResponseParser.parseInquireCardResponse(hResponse);

            //Check if request is valid
            if(response.cardDetails.trackingNumber != CreditCardHelper.trackingNumberForEnvelope)
                throw new CustomException('Invalid request.');

            //Create a log record
            if(createLog) {

                //Get The Amount Limit instance
                HTTPResponseParser.Card cardDetails = response.cardDetails;

                //Get The Amount Limit instance
                HTTPResponseParser.AmountLimits amountLimits = response.amountLimits;

                //Note Body
                String body = 'Card details are:'
                                + '\nCard Number:\t'+ 'XXXX-XXXX-XXXX-'+ response.cardNumber.right(4)
                                + '\nAccount Code:\t'+ cardDetails.accountCode
                                + '\nCustomer Id:\t' + cardDetails.customerId
                                + '\nDiscretionary Data:\t'+ cardDetails.discretionaryData
                                + '\nTracking Number:\t'+ cardDetails.trackingNumber
                                + '\nCard Status:\t'+ cardDetails.cardStatus
                                + '\nProfile Flag:\t'+ cardDetails.profileFlag
                                + '\nProfile Value:\t'+ cardDetails.profileValue
                                + '\nProfile Description:\t'+ cardDetails.profileDescription
                                + '\nCard Holder First Name:\t'+ cardDetails.cardFirstName
                                + '\nCard Holder Last Name:\t'+ cardDetails.cardLastName
                                + '\nDriver License Number:\t'+ cardDetails.driverLicenseNumber
                                + '\nDriver License State:\t'+ cardDetails.driverLicenseState
                                + '\nTrip Number:\t'+ cardDetails.tripNumber
                                + '\nVehicle Number:\t'+ cardDetails.vehicleNumber
                                + '\nEmployee Number:\t'+ cardDetails.employeeNumber
                                + '\nVehicle VIN Number:\t'+ cardDetails.vehicleVINNumber
                                + '\n Vehicle Description:\t'+ cardDetails.vehicleDescription
                                + '\nVehicle Plate Number:\t'+ cardDetails.vehicleLicensePlateNumber
                                + '\nRegistration Expiration:\t'+ cardDetails.registrationExpiration
                                + '\nMiscellaneous 1:\t'+ cardDetails.miscellaneous1
                                + '\nMiscellaneous 1:\t'+ cardDetails.miscellaneous2
                                + '\nExpiration:\t'+ cardDetails.cardExpiration
                                +'\nAmount limit details are:'
                                + '\nCredit Limit Amount:\t' + amountLimits.cycleAmountLimit
                                + '\nMax Per Transaction:\t' + amountLimits.dailyTxnLimitAvailable
                                + '\nMax per Day:\t' + amountLimits.dailyAmountLimitAvailable
                                + '\nMax Cycle Amount:\t' +  amountLimits.cycleAmountLimitAvailable
                                + '\nDaily Amount Limit :\t' + amountLimits.dailyAmountLimit
                                + '\nDaily Transaction Limit Used:\t' + amountLimits.dailyAmountLimitUsed
                                + '\nDaily Transaction Limit Hold:\t' + amountLimits.dailyAmountLimitHold
                                + '\nDaily Transaction Limit :\t' + amountLimits.dailyTxnLimit
                                + '\nDaily Transaction Limit Used:\t' + amountLimits.dailyTxnLimitUsed
                                + '\nDaily Transaction Limit Hold:\t' + amountLimits.dailyTxnLimitHold
                                + '\nDaily Transaction Limit Available:\t' + amountLimits.dailyTxnLimitAvailable
                                + '\nCycle Amount Limit:\t' + amountLimits.cycleAmountLimit
                                + '\nCycle Amount Limit Used:\t' + amountLimits.cycleAmountLimitUsed
                                + '\nCycle Amount Limit Hold:\t' + amountLimits.cycleAmountLimitHold
                                + '\nCycle Transaction Limit:\t' + amountLimits.cycleTxnLimit
                                + '\nCycle Transaction Limit Used:\t' + amountLimits.cycleTxnLimitUsed
                                + '\nCycle Transaction Limit Hold:\t' + amountLimits.cycleTxnLimitHold
                                + '\nCycle Transaction Limit Available:\t' + amountLimits.cycleTxnLimitAvailable;


                //Create a Note record and attach it to the Credit card
                if(!System.isBatch()) {
                    insert new Note(ParentId = creditCard.Id, Title = 'Card Inquiry: ' + Date.today().format(), Body = body);
                }

                CreditCardLogger.Log(creditCard, null, requestTime, CreditCardService.Request_Log, requestEnvelope,
                                        String.valueOf(response), 'CreditCardService', 'inquireCreditCard', 'inquireCard');
            }

        } catch(Exception e) {

            //Create a log record
            if(createLog)
                CreditCardLogger.Log(creditCard, e.getMessage(), requestTime, CreditCardService.Request_Log, requestEnvelope,
                                        e.getMessage(), 'CreditCardService', 'inquireCreditCard', 'inquireCard');

            //Throwing exception
            throw e;
        }

        return response;
    }

    /**
     *  @description    :   This method is to update a credit card in comdata
     *
     *  @args           :   SFDC Credit Card record ID
     *
     *  @return         :   void
     *
     **/
    public static void updateCreditCard(Id creditCardId) {

        //Query for Credit Card record associated with the specified Id
        Credit_Card__c creditCard = [SELECT Id, Name, Credit_Card_Number__c,
                                            Payment_Account__r.Portfolio_Owner_Finance_Code__c,
                                            Card_Status_Code__c,
                                            Card_Holder_First_Name__c,
                                            Card_Holder_Last_Name__c,
                                            Card_Employee_Number__c,
                                            Card_Owner__c,
                                            Card_Vendor__c,
                                            Original_Request__c,
                                            Original_Request__r.Request_Type__c,
                                            Original_Request__r.Address_To_Name__c,
                                            Original_Request__r.Address_Line_1__c,
                                            Original_Request__r.Address_Line_2__c,
                                            Original_Request__r.Address_City__c,
                                            Original_Request__r.Address_State__c,
                                            Original_Request__r.Address_Postal_Code__c,
                                            Update_Billing_Address_On_Activation__c, 
                                            Payment_Account__r.Billing_Address_Updated__c,
                                            Payment_Account__r.Billing_Address_Line_1__c, 
                                            Payment_Account__r.Billing_Address_Line_2__c, 
                                            Payment_Account__r.Billing_Address_City__c, 
                                            Payment_Account__r.Billing_Address_State__c, 
                                            Payment_Account__r.Billing_Address_PostalCode__c, 
                                            Payment_Account__r.Billing_Address_Attention_To__c,
                                            Payment_Account__r.First_Name_On_Card__c, 
                                            Payment_Account__r.Last_Name_On_Card__c 
                                            FROM Credit_Card__c WHERE ID =: creditCardId];

        //Get request Envelope
        String requestEnvelope = CreditCardHelper.getUpdateCreditCardEnvelope(creditCard);

        try {

            //Make callout and parse response
            HttpRequest request = HTTPRequestBuilder.CreateRequest(configCCDefaultSetting.Endpoint__c, CreditCardConstants.REQUEST_TYPE_POST, CreditCardConstants.SOAP_ACTION_UPDATE_CARD, requestEnvelope);
            HttpResponse hResponse = HTTPService.send(request);
            HTTPResponseParser.CardAddUpdateResponse response = HTTPResponseParser.parseUpdateCardResponse(hResponse);

            //Check for success
            if(response.responseCode == CreditCardConstants.ZERO) {

                //Check if request has valid response
                if(response.trackingNumber != CreditCardHelper.trackingNumberForEnvelope)
                    throw new CustomException('Invalid request.');

                //Create a log record
                CreditCardLogger.Log(creditCard, null, requestTime, CreditCardService.Request_Log, requestEnvelope,
                                        String.valueOf(response), 'CreditCardService', 'updateCreditCard', 'updateCard');

            } else {

                throw new CustomException(response.responseDescription);
            }

        } catch(Exception e){

            //Create a log record
            CreditCardLogger.Log(creditCard, e.getMessage(), requestTime, CreditCardService.Request_Log, requestEnvelope,
                                    e.getMessage(), 'CreditCardService', 'updateCreditCard', 'updateCard');

            throw e;
        }
    }

    /**
     *  @description    :   This method is to Inquire Card Security Code in comdata
     *
     *  @args           :   SFDC Credit Card record ID
     *
     *  @return         :   void
     *
     **/
    public static void inquireCardSecurityCode(ID creditCardId, boolean CreateLog) {

        //Query for Credit Card record associated with the specified Id
        Credit_Card__c creditCard = [SELECT ID, Name, Card_Employee_Number__c, Card_Expiration__c, Card_Vendor__c
                                        FROM Credit_Card__c WHERE ID =: creditCardId];

        //Check for validation of required fields
        CreditCardService.validateCreditCardForRequiredField(creditCard);

        if(creditCard.Card_Expiration__c == null) {
            throw new CustomException('Required fields missing: Card Expiration should not be blank.');
        }

        //Get request Envelope
        String requestEnvelope = CreditCardHelper.getInquireCardSecurityCodeEnvelope(creditCard);

        try {

            //Make callout and parse response
            HttpRequest request = HTTPRequestBuilder.CreateRequest(configCCDefaultSetting.Endpoint__c, CreditCardConstants.REQUEST_TYPE_POST, CreditCardConstants.SOAP_ACTION_INQUIRE_CARD_SECURITY_CODE, requestEnvelope);
            HttpResponse hResponse = HTTPService.send(request);
            HTTPResponseParser.CardSecurityCodeInquiryResponse response = HTTPResponseParser.parseinquireCardSecurityCodeResponse(hResponse);

            //Check if request is validresponse
            if(response.trackingNumber != CreditCardHelper.trackingNumberForEnvelope)
                throw new CustomException('Invalid request.');

            //Check for Boolean
            if(CreateLog) {


                //Note Body
                String body = 'Card details are:'
                                + '\nCard Number:\t'+ 'XXXX-XXXX-XXXX-'+ response.cardNumber.right(4)
                                + '\nAccount Code:\t'+ response.accountCode
                                + '\nCustomer Id:\t' + response.customerId
                                + '\nDiscretionary Data:\t'+ response.discretionaryData
                                + '\nTracking Number:\t'+ response.trackingNumber
                                + '\nEmployee Number:\t'+ response.employeeNumber
                                + '\nCard Security Code:\t'+ response.cardSecurityCode;

                //Create a Note record and attach it to the Credit card
                insert new Note(ParentId = creditCard.Id, Title = 'Card Security Code Inquiry: ' + Date.today().format(), Body = body);

                CreditCardLogger.Log(creditCard, null, requestTime, CreditCardService.Request_Log, requestEnvelope,
                                        String.valueOf(response), 'CreditCardService', 'inquireCreditCard', 'inquireCard');
            }
            //Create a log record
            CreditCardLogger.Log(creditCard, null, requestTime, CreditCardService.Request_Log, requestEnvelope,
                                    String.valueOf(response), 'CreditCardService', 'inquireCardSecurityCode', 'inquireCardSecurityCode');

        } catch(Exception e){

            //Create a log record
            CreditCardLogger.Log(creditCard, e.getMessage(), requestTime, CreditCardService.Request_Log, requestEnvelope,
                                    e.getMessage(), 'CreditCardService', 'inquireCardSecurityCode', 'inquireCardSecurityCode');

            throw e;
        }
    }

    /**
     *  @description    :   This method is to download all transaction data from Comdata for the portfolio record
     *
     *  @args           :   Set of Transaction dates
     *
     *  @return         :   void
     *
     **/
    public static List<HTTPResponseParser.RtTransactionResponse> realTimeTransactionHistory(Id portfolioId, Integer noOfDays) {
        
        //Initialize
        List<HTTPResponseParser.RtTransactionResponse> listRtTransactionResponse = new List<HTTPResponseParser.RtTransactionResponse>();
        
        //Check if portfolio Id is not null
        if(portfolioId != null && noOfDays != null) {
            
            //Fetch all teh credit card records ralted to portfolio
            List<Credit_Card__c> creditCards = [Select Id, Credit_Card_Number__c from Credit_Card__c where Status__c =: CreditCardConstants.CC_STATUS_ACTIVE AND Payment_Account__c =: portfolioId];
            
            //Check for the size
            if(creditCards.size() > 0) {
                
                //Populate transaction
                listRtTransactionResponse = realTimeTransactionHistory(creditCards, noOfDays);
            }
        }
        return listRtTransactionResponse; 
    }
    
    /**
     *  @description    :   This method is to download all transaction data from Comdata
     *
     *  @args           :   Set of Transaction dates
     *
     *  @return         :   void
     *
     **/
    public static List<HTTPResponseParser.RtTransactionResponse> realTimeTransactionHistory(List<Credit_Card__c> creditCards, Integer noOfDays) {
        
        //List to Hold the transaction records
        List<HTTPResponseParser.RtTransactionResponse> listRtTransactionResponse = new List<HTTPResponseParser.RtTransactionResponse>();
            
        //Check for the size and transactions
        if(creditCards.size() > 0 && noOfDays != null) {
            
            //Settings
            Credit_Card_Settings__c configDefaults = CreditCardConstants.CONFIG_DEFAULT;
            String requestEnvelope;
            
            try {
            
                //Loop through the transaction dates and process each transaction date separately
                for(Credit_Card__c creditCard : creditCards) { 
                
                    //request envelope
                    requestEnvelope = CreditCardHelper.getRealTimeTransactionHistoryEnvelope(creditCard.Credit_Card_Number__c, noOfDays);
                    
                    //Make callout and parse response
                    HttpRequest request = HTTPRequestBuilder.CreateRequest(configCCDefaultSetting.Endpoint__c, CreditCardConstants.REQUEST_TYPE_POST, CreditCardConstants.SOAP_ACTION_REAL_TIME_TRANSACTION_HISTORY, requestEnvelope);
                    HttpResponse hResponse = HTTPService.send(request);
                    HTTPResponseParser.RtTransactionResponse response = HTTPResponseParser.parseRTTransactionHistory(hResponse);
                    listRtTransactionResponse.add(response);
                }
                
                //Create a log record
                CreditCardLogger.Log(null, requestTime, 'Real Time Transaction History', requestEnvelope, null,
                                            'CreditCardService', 'realTimeTransactionHistory', 'realTimeTransactionHistory');
            } catch(Exception e){
    
                //Create a log record
                CreditCardLogger.Log(e.getMessage(), requestTime, 'Real Time Transaction History', requestEnvelope, e.getMessage(),
                                        'CreditCardService', 'realTimeTransactionHistory', 'realTimeTransactionHistory');
            }
        }
        
        //Return response
        return listRtTransactionResponse;
    }
    
    /**
     *  @description    :   This method is to create a cloned copy of credit card record. This will be be used with replace Card functioanlity.
                            Whenever "Replace Card" will be requested, it will create the clone of teh existing card
     *
     *  @args           :   SFDC Credit Card Transaction  record ID
     *
     *  @return         :   void
     *
     **/
    public static Credit_Card__c cloneCreditCardForReplacement(Credit_Card__c originalCreditCard) {
        OSR__c o = [select Id, Contact__c from OSR__c where Id = :originalCreditCard.Original_Request__c];
        Credit_Card__c c = cloneCreditCardForReplacement(originalCreditCard,o);
        return c;
    }
    
    public static Credit_Card__c cloneCreditCardForReplacement(Credit_Card__c originalCreditCard, OSR__c oSR) {

        //Create a new Credit Card instance
        Credit_Card__c creditCard = originalCreditCard.clone(false);

        //Set Expiration date next 2 year of last sate of month
        creditCard.Status__c = CreditCardConstants.CC_STATUS_PENDING_ACTIVATION;
        creditCard.Card_Set_up_Status__c = CreditCardConstants.CC_SET_UP_STATUS_PENDING_ACTIVATION;
        creditCard.Card_Deactivation_Status__c = null;
        creditCard.Card_Deactivation_Reason__c = null;
        creditCard.Credit_Card_Number__c = null;
        creditCard.Card_Number__c = null;
        creditCard.Card_Employee_Number__c = getCardEmployeeNum(originalCreditCard);
        if(oSR != null){
            creditCard.Original_Request__c = oSR.Id;
            creditCard.Card_Requested_By__c = oSR.Contact__c;
        }
        system.debug('CreditCardService.cloneCreditCardForReplacement - creditCard: '+creditCard);

        //insert
        insert creditCard;
        return creditCard;
    }
    
    //Return the card employee number in the format:
    //[6 digit Employee Finance Code][2 digit Card Counter plus prefix of X][Birthday in DDMMMYY], for example 123456X0107FEB14
    public static string getCardEmployeeNum(Credit_Card__c originalCreditCard) {
        
        decimal cardNum;
        if(originalCreditCard.Payment_Account__c == null || originalCreditCard.Payment_Account__r.Card_Count__c == null){
            cardNum = 0;
        }else{
            cardNum = originalCreditCard.Payment_Account__r.Card_Count__c + 1;
        }
        string cardCount = leftpadString(string.valueOf(cardNum),2);
        
        Date bDate = originalCreditCard.Payment_Account__r.Card_Holder__r.Birthdate;
        
        //Birthdate is required.  Throw an error if it isn't present
        if (bDate == null) {
            throw new customException('Your request has been denied due to your Workday profile not containing your date of birth. ' +
                                      'Please log into Workday and add your birthday information. ' +
                                      'Once entered, please wait until the next business day to attempt to apply again.');
        }
        
        DateTime employeeBirthdate = datetime.newInstance(bDate.year(), bDate.month(),bDate.day());
        string cardEmployeeNum = originalCreditCard.Payment_Account__r.Portfolio_Owner_Finance_Code__c + 
                                 'X' + cardCount + employeeBirthdate.format('ddMMMYY').toUpperCase();
        system.debug('cardEmployeeNum: '+cardEmployeeNum);
        return cardEmployeeNum;
    }

    public static string leftpadString(string input, integer maxLength){
        string retValue = input;
        if(maxLength == null) maxLength = input.length();
        for(integer strLength = input.length(); strLength < maxLength; strLength = retValue.length()){
            retValue = '0' + retValue;
        }
        system.debug('leftpadString - retValue: '+retValue);
        return retValue;
    }
    
    //Static Method for validation record for required field
    static void validateCreditCardForRequiredField(Credit_Card__c creditCard) {

        if(creditCard.Card_Employee_Number__c == null) {
            throw new CustomException('Required fields missing: Card Employee Number Should not be blank.');
        }
    }

    /**
     *  @description    :   This method is to basically encrypt the Credit card number
     *
     *  @args           :   String
     *
     *  @return         :   String
     *
     **/
    public static String Encrypt(String cardNumber) {

        if(cardNumber != null && cardNumber != ''){
            Blob cNBlob = Blob.valueOf(cardNumber);
            Blob signatureBlob = Crypto.generateMac('HMacSHA1', cNBlob, cNBlob);
            String signature = EncodingUtil.base64Encode(signatureBlob);
            return signature;
        }else{
            return null;
        }
    }
    
    /**
     *  @description    :   This method is used to update the Card Number field with the encrypted value if it did not update for some reason.
     *
     *  @args           :   none
     *
     *  @return         :   none
     *
     *  @Comment        :   Two versions of this - one that takes no parameters and runs for all cards, and one that takes a list of
     *                      cards and only checks those.
     *
     **/    
    public static void FixEncryptedCardNumber(){
        List<credit_card__c> ccs = [select Id, credit_card_number__c, card_number__c, card_employee_number__c from credit_card__c where card_number__c = null and status__c = 'Active'];
        system.debug('1 - ccs: '+ccs);
        for(credit_card__c c : ccs){
            if(c.credit_card_number__c != null)
                c.card_number__c = CreditCardService.encrypt(c.credit_card_number__c);
        }
        update ccs;
        system.debug('2 - ccs: '+ccs);
    }
    
    public static void FixEncryptedCardNumber(map<Id,Credit_Card__c> mCards){
    
        for(Credit_Card__c c : mCards.values()){
            string ccnumber = c.credit_card_number__c;
            if((ccnumber != null && ccnumber != '') && (c.card_number__c == null || c.card_number__c == ''))
                c.card_number__c = CreditCardService.encrypt(ccnumber);
        }
    }    
}