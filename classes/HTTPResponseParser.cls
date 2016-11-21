/**
 *  Description     :   This class is to parse the response
 *
 *  Created By      :   Bhavi Sharma
 *
 *  Created Date    :   08/23/2013
 *
 *  Revision Logs   :   V_1.0 - Created
 						V_1.1 - Bhavi Sharma - 04/29/2014 - RTTH updated from Unique Key to Unique Transaction Key
 *
**/
public with sharing class HTTPResponseParser {

    //get CC Default Settings instance  
    public static Credit_Card_Settings__c configDefaults = CreditCardConstants.CONFIG_DEFAULT;
	
    /*Inner Class helpful in AddCard response Parsing*/

    //inner class to hold the AddCreditCard response
    public class AddCardResponse {

        //Variables
        public String discretionaryData;
        public String trackingNumber;
        public String cardNumber;
        public String employeeNumber;
        public String responseCode;
        public String responseDescription;

    }

    /*Inner class helpful in insertCard response Parsing*/

    //Inner Class to hold the inquire Card Resposne
    public class InquireCardResponse {

        public String cardNumber;
        public HTTPResponseParser.card cardDetails;
        public HTTPResponseParser.amountLimits amountLimits;
        
    }

    //Inner class to hold the card response details
    public class Card {

        public String accountCode;
        public String customerId;
        public String discretionaryData;
        public String trackingNumber;
        public String cardStatus;
        public String profileFlag;
        public String profileValue;
        public String profileDescription;
        public String cardFirstName;
        public String cardLastName;
        public String driverLicenseNumber;
        public String driverLicenseState;
        public String tripNumber;
        public String vehicleNumber;
        public String employeeNumber;
        public String vehicleVINNumber;
        public String vehicleDescription;
        public String vehicleLicensePlateNumber;
        public String registrationExpiration;
        public String miscellaneous1;
        public String miscellaneous2;
        public String cardExpiration;

    }

    //Class to hold card amount limits related response data
    public class AmountLimits {

        public String dailyAmountLimit;
        public String dailyAmountLimitUsed;
        public String dailyAmountLimitHold;
        public String dailyAmountLimitAvailable;
        public String dailyTxnLimit;
        public String dailyTxnLimitUsed;
        public String dailyTxnLimitHold;
        public String dailyTxnLimitAvailable;
        public String cycleAmountLimit;
        public String cycleAmountLimitUsed;
        public String cycleAmountLimitHold;
        public String cycleAmountLimitAvailable;
        public String cycleTxnLimit;
        public String cycleTxnLimitUsed;
        public String cycleTxnLimitHold;
        public String cycleTxnLimitAvailable;
    }

    /*Inner class helpful in updateCard response parsing*/

    //Inner class to hold the Update Card response
    public class CardAddUpdateResponse {

        public String accountCode;
        public String customerId;
        public String discretionaryData;
        public String trackingNumber;
        public String cardNumber;
        public String employeeNumber;
        public String responseCode;
        public String responseDescription;

    }

    /*Inner class Helpful in inquireCustomerProfileLimits repsonse parsing*/

    public class CustomerProfileLimitInquiryResponse {

        public HTTPResponseParser.customerProfileLimitReqRespUtil responseUtil;
        public HTTPResponseParser.profileLimits profileLimits;
        public String responseCode;
        public String responseDescription;
    }

    /*Inner class Helpful in updateCustomerProfileLimits repsonse parsing*/


    public class CustomerProfileLimitUpdateResponse {

        public HTTPResponseParser.customerProfileLimitReqRespUtil responseUtil;
        public String responseCode;
        public String responseDescription;
    }

    public class CustomerProfileLimitReqRespUtil {

        public String accountCode;
        public String customerId;
        public String discretionaryData;
        public String trackingNumber;
        public String profileID;
        public String productCode;
    }

    /*Inner class helpful in inquireCardSecurityCode response parsing*/

    public class CardSecurityCodeInquiryResponse {

        public String accountCode;
        public String customerId;
        public String discretionaryData;
        public String trackingNumber;
        public String cardNumber;
        public String employeeNumber;
        public String cardSecurityCode;

    }

    /*Inner Class helpful in inquireCardProfileLimits response parsing*/

    public class CardProfileLimitInquiryResponse {

        public HTTPResponseParser.cardProfileLimitReqResUtil responseUtil;
        public HTTPResponseParser.profileLimits profileLimits;
        public String responseCode;
        public String responseDescription;
    }

    //Inner Class
    public class ProfileLimits {

        public String openCloseFlag;
        public String productAvailableFlag;
        public String transactionDollarLimit;
        public String transactionQuantityLimit;
        public String dailyDollarLimit;
        public String dailyTransactionLimit;
        public String dailyQuantityLimit;
        public String cycleDollarLimit;
        public String cycleTransactionLimit;
        public String cycleQuantityLimit;
        public String cycleType;
        public String cycleDay;
    }

    /*Inner Class Helpful in cardProfileLimitsUpdate response parsing*/

    public class CardProfileLimitUpdateResponse {

        public HTTPResponseParser.cardProfileLimitReqResUtil responseUtil;
        public String responseCode;
        public String responseDescription;
    }

    //Inner Class
    public class CardProfileLimitReqResUtil {

        public String accountCode;
        public String customerId;
        public String discretionaryData;
        public String trackingNumber;
        public String productCode;
    }

    /*Inner class helpful in realTimeTransactionHistory response*/

    public class RTTransactionResponse {

        public String pageCount;
        public String pageNbr;
        public String recordCount;
        public List<RTTransactionRecord> transactionRecords {get; set;}
        public String responseCode;
        public String responseDescription;
        public Set<Id> cardIds;
        public List<Credit_Card_Transaction__c> creditCardTransactions;
        public List<Credit_Card_Transaction__c> creditCardTransactionsToDelete;
    }

    //Inner Class
    public class RTTransactionRecord {

        public String accountCode {get; set;}
        public String customerId {get; set;}
        public String customerName {get; set;}
        public String corporateCode {get; set;}
        public String transactionDate {get; set;}
        public String transactionTime {get; set;}
        public String postedDate {get; set;}
        public String postedTime {get; set;}
        public String transactionStatus {get; set;}
        public String cardNumber {get; set;}
        public String cardholderName {get; set;}
        public String cardExpireDate {get; set;}
        public String declineCode {get; set;}
        public String declineMessage {get; set;}
        public String correctiveAction {get; set;}
        public String promptedId {get; set;}
        public String mccGroup {get; set;}
        public String mccNumber {get; set;}
        public String mccDescription {get; set;}
        public String merchantName {get; set;}
        public String merchantAddress {get; set;}
        public String merchantCity {get; set;}
        public String merchantState {get; set;}
        public String merchantZip {get; set;}
        public String acceptLocation {get; set;}
        public String preAuthAmount {get; set;}
        public String postedAmount {get; set;}
        public String approvalCode {get; set;}
        public String reversalFlag {get; set;}
    }

    /**
     *  @description    :   This method is to parse the response for AddCard request
     *
     *  @param          :   HttpResponse
     *
     *  @return         :   instance of AddCardResponse class
     *
     **/
     public static AddCardResponse parseAddCardResponse(HttpResponse response) {

        //Create an instance of AddCardResponse
        AddCardResponse addCardResponse = new AddCardResponse();
        
        system.debug('@@getBodyDocument:' + response.getBodyDocument());
        system.debug('@@getBody:' + response.getBody());
        system.debug('@@getStatus:' + response.getStatus());
        system.debug('@@getStatusCode:' + response.getStatusCode());
        system.debug('@@getHeaderkeys:' + response.getHeaderkeys());
         
        //Get statusCode and throw error if it fails
        if(response.getStatusCode() != 200) {

            //Fault Deatils
            Dom.XmlNode responseNode = response.getBodyDocument().getRootElement()
                                        .getChildElement('Body', configDefaults.xmlns_soapenv__c)
                                        .getChildElement('Fault', configDefaults.xmlns_soapenv__c)
                                        .getChildElement('detail', null)
                                        .getChildElement('BusinessException', 'http://fleetCredit.comdata.com/exception/');

            //populate data
            addCardResponse.responseCode = responseNode.getChildElement('messageCode', null).getText();
            addCardResponse.responseDescription = responseNode.getChildElement('message', null).getText();

        } else {

            //Response Node
            Dom.XmlNode responseNode = response.getBodyDocument().getRootElement()
                                        .getChildElement('Body', configDefaults.xmlns_soapenv__c)
                                        .getChildElement('AddCardResponse', configDefaults.xmlns_main__c)
                                        .getChildElement('response', null);

            //Populate data
            addCardResponse.trackingNumber = responseNode.getChildElement('trackingNumber', null).getText();
            addCardResponse.responseCode = responseNode.getChildElement('responseCode', null).getText();
            addCardResponse.responseDescription = responseNode.getChildElement('responseDescription', null).getText();
            addCardResponse.cardNumber = responseNode.getChildElement('cardNumber', null).getText();
        }

        //return addCardResponse
        return addCardResponse;
     }

     /**
     *  @description    :   This method is to parse the response for inquireCard request
     *
     *  @param          :   HttpResponse
     *
     *  @return         :   instance of InquireCardResponse class
     *
     **/
     public static InquireCardResponse parseInquireCardResponse(HttpResponse response) {

        //Create an instance of InquireCardResponse
        InquireCardResponse inquireCardResponse = new InquireCardResponse();

        System.debug('response:::::' +response.getBody());
         
        //Get statusCode and throw error if it fails
        if(response.getStatusCode() != 200) {
			
            //Fault Deatils
            Dom.XmlNode responseNode = response.getBodyDocument().getRootElement()
                                        .getChildElement('Body', configDefaults.xmlns_soapenv__c)
                                        .getChildElement('Fault', configDefaults.xmlns_soapenv__c)
                                        .getChildElement('detail', null)
                                        .getChildElement('BusinessException', 'http://fleetCredit.comdata.com/exception/');
			
            throw new CustomException(responseNode.getChildElement('messageCode', null).getText() +':' + responseNode.getChildElement('message', null).getText());
           
        }else{

            //Response node
            Dom.XmlNode responseNode = response.getBodyDocument().getRootElement()
                                                        .getChildElement('Body', configDefaults.xmlns_soapenv__c)
                                                        .getChildElement('CardInquiryResponse', configDefaults.xmlns_main__c);
    
            //Populate Data
            inquireCardResponse.cardNumber = responseNode.getChildElement('cardNumber', null).getText();
    
            //Going in more depth of response node
            Dom.XmlNode responseNodeCardDetails = responseNode.getChildElement('cardDetails', null);
    
            //Create a inner class instance to hold the card details data
            Card cardDetails = new Card();
    
            //Populate data
            cardDetails.accountCode = responseNodeCardDetails.getChildElement('accountCode', null).getText();
            cardDetails.customerId = responseNodeCardDetails.getChildElement('customerId', null).getText();
            cardDetails.discretionaryData = responseNodeCardDetails.getChildElement('discretionaryData', null).getText();
            cardDetails.trackingNumber = responseNodeCardDetails.getChildElement('trackingNumber', null).getText();
            cardDetails.cardStatus = responseNodeCardDetails.getChildElement('cardStatus', null).getText();
            cardDetails.profileFlag = responseNodeCardDetails.getChildElement('profileFlag', null).getText();
            cardDetails.profileValue = responseNodeCardDetails.getChildElement('profileValue', null).getText();
            cardDetails.profileDescription = responseNodeCardDetails.getChildElement('profileDescription', null).getText();
            cardDetails.cardFirstName = responseNodeCardDetails.getChildElement('cardFirstName', null).getText();
            cardDetails.cardLastName = responseNodeCardDetails.getChildElement('cardLastName', null).getText();
            cardDetails.driverLicenseNumber = responseNodeCardDetails.getChildElement('driverLicenseNumber', null).getText();
            cardDetails.driverLicenseState = responseNodeCardDetails.getChildElement('driverLicenseState', null).getText();
            cardDetails.tripNumber = responseNodeCardDetails.getChildElement('tripNumber', null).getText();
            cardDetails.vehicleNumber = responseNodeCardDetails.getChildElement('vehicleNumber', null).getText();
            cardDetails.employeeNumber = responseNodeCardDetails.getChildElement('employeeNumber', null).getText();
            cardDetails.vehicleVINNumber = responseNodeCardDetails.getChildElement('vehicleVINNumber', null).getText();
            cardDetails.vehicleDescription = responseNodeCardDetails.getChildElement('vehicleDescription', null).getText();
            cardDetails.vehicleLicensePlateNumber = responseNodeCardDetails.getChildElement('vehicleLicensePlateNumber', null).getText();
            cardDetails.registrationExpiration = responseNodeCardDetails.getChildElement('registrationExpiration', null).getText();
            cardDetails.miscellaneous1 = responseNodeCardDetails.getChildElement('miscellaneous1', null).getText();
            cardDetails.miscellaneous2 = responseNodeCardDetails.getChildElement('miscellaneous2', null).getText();
            cardDetails.cardExpiration = responseNodeCardDetails.getChildElement('cardExpiration', null).getText();
    
            //Going in more depth of response node
            Dom.XmlNode responseNodeamountDetails = responseNode.getChildElement('amountLimits', null);
    
            //Create a inner class instance to hold the ammount details data
            AmountLimits amountLimitsDetails = new AmountLimits();
    
            //Populate data
            amountLimitsDetails.dailyAmountLimit = responseNodeamountDetails.getChildElement('dailyAmountLimit', null).getText();
            amountLimitsDetails.dailyAmountLimitUsed = responseNodeamountDetails.getChildElement('dailyAmountLimitUsed', null).getText();
            amountLimitsDetails.dailyAmountLimitHold = responseNodeamountDetails.getChildElement('dailyAmountLimitHold', null).getText();
            amountLimitsDetails.dailyAmountLimitAvailable = responseNodeamountDetails.getChildElement('dailyAmountLimitAvailable', null).getText();
            amountLimitsDetails.dailyTxnLimit = responseNodeamountDetails.getChildElement('dailyTxnLimit', null).getText();
            amountLimitsDetails.dailyTxnLimitUsed = responseNodeamountDetails.getChildElement('dailyTxnLimitUsed', null).getText();
            amountLimitsDetails.dailyTxnLimitHold = responseNodeamountDetails.getChildElement('dailyTxnLimitHold', null).getText();
            amountLimitsDetails.dailyTxnLimitAvailable = responseNodeamountDetails.getChildElement('dailyTxnLimitAvailable', null).getText();
            amountLimitsDetails.cycleAmountLimit = responseNodeamountDetails.getChildElement('cycleAmountLimit', null).getText();
            amountLimitsDetails.cycleAmountLimitUsed = responseNodeamountDetails.getChildElement('cycleAmountLimitUsed', null).getText();
            amountLimitsDetails.cycleAmountLimitHold = responseNodeamountDetails.getChildElement('cycleAmountLimitHold', null).getText();
            amountLimitsDetails.cycleAmountLimitAvailable = responseNodeamountDetails.getChildElement('cycleAmountLimitAvailable', null).getText();
            amountLimitsDetails.cycleTxnLimit = responseNodeamountDetails.getChildElement('cycleTxnLimit', null).getText();
            amountLimitsDetails.cycleTxnLimitUsed = responseNodeamountDetails.getChildElement('cycleTxnLimitUsed', null).getText();
            amountLimitsDetails.cycleTxnLimitHold = responseNodeamountDetails.getChildElement('cycleTxnLimitHold', null).getText();
            amountLimitsDetails.cycleTxnLimitAvailable = responseNodeamountDetails.getChildElement('cycleTxnLimitAvailable', null).getText();
    
            //Assigning values to the variables
            inquireCardResponse.cardDetails = cardDetails;
            inquireCardResponse.amountLimits = amountLimitsDetails;
        }
        //Return InquireCardResponse
        return inquireCardResponse;

     }

     /**
     *  @description    :   This method is to parse the response for updateCard request
     *
     *  @param          :   HttpResponse
     *
     *  @return         :   instance of CardAddUpdateResponse class
     *
     **/
     public static CardAddUpdateResponse parseUpdateCardResponse(HttpResponse response) {

        //Create an instance of InquireCardResponse
        CardAddUpdateResponse updateCardResponse = new CardAddUpdateResponse();

        //Get statusCode and throw error if it fails
        if(response.getStatusCode() != 200) {

            //Fault Deatils
            Dom.XmlNode responseNode = response.getBodyDocument().getRootElement()
                                        .getChildElement('Body', configDefaults.xmlns_soapenv__c)
                                        .getChildElement('Fault', configDefaults.xmlns_soapenv__c)
                                        .getChildElement('detail', null)
                                        .getChildElement('BusinessException', 'http://fleetCredit.comdata.com/exception/');

            //populate data
            updateCardResponse.responseCode = responseNode.getChildElement('messageCode', null).getText();
            updateCardResponse.responseDescription = responseNode.getChildElement('message', null).getText();

        } else {
			
            system.debug('response.getBodyDocument::::::::'+response.getBodyDocument());
            system.debug('response.getBodyDocument.getRootElement::::::::'+response.getBodyDocument().getRootElement());
            //Response node
            Dom.XmlNode responseNode = response.getBodyDocument().getRootElement()
                                                    .getChildElement('Body', configDefaults.xmlns_soapenv__c)
                                                    .getChildElement('UpdateCardResponse', configDefaults.xmlns_main__c)
                                                    .getChildElement('response', null);

            //Populate Data
            updateCardResponse.accountCode = responseNode.getChildElement('accountCode', null).getText();
            updateCardResponse.customerId = responseNode.getChildElement('customerId', null).getText();
            updateCardResponse.discretionaryData = responseNode.getChildElement('discretionaryData', null).getText();
            updateCardResponse.trackingNumber = responseNode.getChildElement('trackingNumber', null).getText();
            updateCardResponse.cardNumber = responseNode.getChildElement('cardNumber', null).getText();
            updateCardResponse.employeeNumber = responseNode.getChildElement('employeeNumber', null).getText();
            updateCardResponse.responseCode = responseNode.getChildElement('responseCode', null).getText();
            updateCardResponse.responseDescription = responseNode.getChildElement('responseDescription', null).getText();
        }

        //Return value
        return updateCardResponse;
     }

     /**
     *  @description    :   This method is to parse the response for inquireCustomerProfileLimits request
     *
     *  @param          :   HttpResponse
     *
     *  @return         :   instance of CustomerProfileLimitInquiryResponse class
     *
     **/
     public static CustomerProfileLimitInquiryResponse parseInquireCustomerProfileLimitsResponse(HttpResponse response) {

        //Create an instance of InquireCardResponse
        CustomerProfileLimitInquiryResponse inquireCustomerProfileLimits = new CustomerProfileLimitInquiryResponse();

        //Get statusCode and throw error if it fails
        if(response.getStatusCode() != 200) {

            //Fault Deatils
            Dom.XmlNode responseNode = response.getBodyDocument().getRootElement()
                                        .getChildElement('Body', configDefaults.xmlns_soapenv__c)
                                        .getChildElement('Fault', configDefaults.xmlns_soapenv__c)
                                        .getChildElement('detail', null)
                                        .getChildElement('BusinessException', 'http://fleetCredit.comdata.com/exception/');

            //populate data
            inquireCustomerProfileLimits.responseCode = responseNode.getChildElement('messageCode', null).getText();
            inquireCustomerProfileLimits.responseDescription = responseNode.getChildElement('message', null).getText();

        } else {

            //Response node
            Dom.XmlNode responseNode = response.getBodyDocument().getRootElement()
                                            .getChildElement('Body', configDefaults.xmlns_soapenv__c)
                                            .getChildElement('CustomerProfileLimitInquiryResponse', configDefaults.xmlns_main__c);

            //Getting More Inner node values
            Dom.XmlNode responseNodeResponseUtil = responseNode.getChildElement('responseUtil', null);
            Dom.XmlNode responseNodeProfileLimits = responseNode.getChildElement('profileLimits', null);

            //Instance of Inner class to hold Card Profile Utility values
            CustomerProfileLimitReqRespUtil cardProfileUtil = new CustomerProfileLimitReqRespUtil();

            //Populate data
            cardProfileUtil.accountCode = responseNodeResponseUtil.getChildElement('accountCode', null).getText();
            cardProfileUtil.customerId = responseNodeResponseUtil.getChildElement('customerId', null).getText();
            cardProfileUtil.discretionaryData = responseNodeResponseUtil.getChildElement('discretionaryData', null).getText();
            cardProfileUtil.trackingNumber = responseNodeResponseUtil.getChildElement('trackingNumber', null).getText();
            cardProfileUtil.productCode = responseNodeResponseUtil.getChildElement('productCode', null).getText();
            cardProfileUtil.profileID = responseNodeResponseUtil.getChildElement('productCode', null).getText();

            //Insatnce of Inner class for holding the profile limits
            ProfileLimits profileLimitsController = new ProfileLimits();

            //Populate data
            profileLimitsController.openCloseFlag = responseNodeProfileLimits.getChildElement('openCloseFlag', null).getText();
            profileLimitsController.productAvailableFlag = responseNodeProfileLimits.getChildElement('productAvailableFlag', null).getText();
            profileLimitsController.transactionDollarLimit = responseNodeProfileLimits.getChildElement('transactionDollarLimit', null).getText();
            profileLimitsController.transactionQuantityLimit = responseNodeProfileLimits.getChildElement('transactionQuantityLimit', null).getText();
            profileLimitsController.dailyDollarLimit = responseNodeProfileLimits.getChildElement('dailyDollarLimit', null).getText();
            profileLimitsController.dailyTransactionLimit = responseNodeProfileLimits.getChildElement('dailyTransactionLimit', null).getText();
            profileLimitsController.dailyQuantityLimit = responseNodeProfileLimits.getChildElement('dailyQuantityLimit', null).getText();
            profileLimitsController.cycleDollarLimit = responseNodeProfileLimits.getChildElement('cycleDollarLimit', null).getText();
            profileLimitsController.cycleTransactionLimit = responseNodeProfileLimits.getChildElement('cycleTransactionLimit', null).getText();
            profileLimitsController.cycleQuantityLimit = responseNodeProfileLimits.getChildElement('cycleQuantityLimit', null).getText();
            profileLimitsController.cycleType = responseNodeProfileLimits.getChildElement('cycleType', null).getText();
            profileLimitsController.cycleDay = responseNodeProfileLimits.getChildElement('cycleDay', null).getText();

            //Popualting variables with the values
            inquireCustomerProfileLimits.responseUtil = cardProfileUtil;
            inquireCustomerProfileLimits.profileLimits = profileLimitsController;
            inquireCustomerProfileLimits.responseCode = responseNode.getChildElement('responseCode', null).getText();
            inquireCustomerProfileLimits.responseDescription = responseNode.getChildElement('responseDescription', null).getText();
        }

        //Return value
        return inquireCustomerProfileLimits;
     }

     /**
     *  @description    :   This method is to parse the response for updateCustomerProfileLimits request
     *
     *  @param          :   HttpResponse
     *
     *  @return         :   instance of CustomerProfileLimitUpdateResponse class
     *
     **/
     public static CustomerProfileLimitUpdateResponse parseUpdateCustomerProfileLimits(HttpResponse response) {

        //Create an instance of updateCardProfileLimts response
        CustomerProfileLimitUpdateResponse updateCustomerProfileLimits = new CustomerProfileLimitUpdateResponse();

        //Get statusCode and throw error if it fails
        if(response.getStatusCode() != 200) {

            //Fault Deatils
            Dom.XmlNode responseNode = response.getBodyDocument().getRootElement()
                                        .getChildElement('Body', configDefaults.xmlns_soapenv__c)
                                        .getChildElement('Fault', configDefaults.xmlns_soapenv__c)
                                        .getChildElement('detail', null)
                                        .getChildElement('BusinessException', 'http://fleetCredit.comdata.com/exception/');

            //populate data
            updateCustomerProfileLimits.responseCode = responseNode.getChildElement('messageCode', null).getText();
            updateCustomerProfileLimits.responseDescription = responseNode.getChildElement('message', null).getText();

        } else {

            //Response node
            Dom.XmlNode responseNode = response.getBodyDocument().getRootElement()
                                            .getChildElement('Body', configDefaults.xmlns_soapenv__c)
                                            .getChildElement('CustomerProfileLimitUpdateResponse', configDefaults.xmlns_main__c);

            //Getting More Inner node values
            Dom.XmlNode responseNodeResponseUtil = responseNode.getChildElement('responseUtil', null);

            //Instance of Inner class to hold Card Profile Utility values
            CustomerProfileLimitReqRespUtil customerProfileUtil = new CustomerProfileLimitReqRespUtil();

            //Populate data
            customerProfileUtil.accountCode = responseNodeResponseUtil.getChildElement('accountCode', null).getText();
            customerProfileUtil.customerId = responseNodeResponseUtil.getChildElement('customerId', null).getText();
            customerProfileUtil.discretionaryData = responseNodeResponseUtil.getChildElement('discretionaryData', null).getText();
            customerProfileUtil.trackingNumber = responseNodeResponseUtil.getChildElement('trackingNumber', null).getText();
            customerProfileUtil.productCode = responseNodeResponseUtil.getChildElement('productCode', null).getText();

            //Popualting variables with the values
            updateCustomerProfileLimits.responseUtil = customerProfileUtil;
            updateCustomerProfileLimits.responseCode = responseNode.getChildElement('responseCode', null).getText();
            updateCustomerProfileLimits.responseDescription = responseNode.getChildElement('responseDescription', null).getText();
        }

        //Return value
        return updateCustomerProfileLimits;
     }

     /**
     *  @description    :   This method is to parse the response for inquireCardSecurityCode request
     *
     *  @param          :   HttpResponse
     *
     *  @return         :   instance of CardSecurityCodeInquiryResponse class
     *
     **/
     public static CardSecurityCodeInquiryResponse parseInquireCardSecurityCodeResponse(HttpResponse response) {

        //Create an instance of InquireCardResponse
        CardSecurityCodeInquiryResponse inquireCardSecurityCode = new CardSecurityCodeInquiryResponse();
		
         //Get statusCode and throw error if it fails
        if(response.getStatusCode() != 200) {
			
            //Fault Deatils
            Dom.XmlNode responseNode = response.getBodyDocument().getRootElement()
                                        .getChildElement('Body', configDefaults.xmlns_soapenv__c)
                                        .getChildElement('Fault', configDefaults.xmlns_soapenv__c)
                                        .getChildElement('detail', null)
                                        .getChildElement('BusinessException', 'http://fleetCredit.comdata.com/exception/');
			
            throw new CustomException(responseNode.getChildElement('messageCode', null).getText() +':' + responseNode.getChildElement('message', null).getText());
           
        }else{
            //Response node
        Dom.XmlNode responseNode = response.getBodyDocument().getRootElement()
                                        .getChildElement('Body', configDefaults.xmlns_soapenv__c)
                                        .getChildElement('CardSecurityCodeInquiryResponse', configDefaults.xmlns_main__c);

        //Populate Data
        inquireCardSecurityCode.accountCode = responseNode.getChildElement('accountCode', null).getText();
        inquireCardSecurityCode.customerId = responseNode.getChildElement('customerId', null).getText();
        inquireCardSecurityCode.cardNumber = responseNode.getChildElement('cardNumber', null).getText();
        inquireCardSecurityCode.cardSecurityCode = responseNode.getChildElement('cardSecurityCode', null).getText();
        inquireCardSecurityCode.discretionaryData = responseNode.getChildElement('discretionaryData', null).getText();
        inquireCardSecurityCode.employeeNumber = responseNode.getChildElement('employeeNumber', null).getText();
        inquireCardSecurityCode.trackingNumber = responseNode.getChildElement('trackingNumber', null).getText();

        }
        
        //Return InquireCardResponse
        return inquireCardSecurityCode;

     }

     /**
     *  @description    :   This method is to parse the response for inquireCardProfileLimits request
     *
     *  @param          :   HttpResponse
     *
     *  @return         :   instance of CardProfileLimitInquiryResponse class
     *
     **/
     public static CardProfileLimitInquiryResponse parseInquireCardProfileLimits(HttpResponse response) {

        //Create an instance of InquireCardResponse
        CardProfileLimitInquiryResponse inquireCardProfileLimits = new CardProfileLimitInquiryResponse();

        //Get statusCode and throw error if it fails
        if(response.getStatusCode() != 200) {

            //Fault Deatils
            Dom.XmlNode responseNode = response.getBodyDocument().getRootElement()
                                        .getChildElement('Body', configDefaults.xmlns_soapenv__c)
                                        .getChildElement('Fault', configDefaults.xmlns_soapenv__c)
                                        .getChildElement('detail', null)
                                        .getChildElement('BusinessException', 'http://fleetCredit.comdata.com/exception/');

            //populate data
            inquireCardProfileLimits.responseCode = responseNode.getChildElement('messageCode', null).getText();
            inquireCardProfileLimits.responseDescription = responseNode.getChildElement('message', null).getText();

        } else {

            //Response node
            Dom.XmlNode responseNode = response.getBodyDocument().getRootElement()
                                            .getChildElement('Body', configDefaults.xmlns_soapenv__c)
                                            .getChildElement('CardProfileLimitInquiryResponse', configDefaults.xmlns_main__c);

            //Getting More Inner node values
            Dom.XmlNode responseNodeResponseUtil = responseNode.getChildElement('responseUtil', null);
            Dom.XmlNode responseNodeProfileLimits = responseNode.getChildElement('profileLimits', null);

            //Instance of Inner class to hold Card Profile Utility values
            CardProfileLimitReqResUtil cardProfileUtil = new CardProfileLimitReqResUtil();

            //Populate data
            cardProfileUtil.accountCode = responseNodeResponseUtil.getChildElement('accountCode', null).getText();
            cardProfileUtil.customerId = responseNodeResponseUtil.getChildElement('customerId', null).getText();
            cardProfileUtil.discretionaryData = responseNodeResponseUtil.getChildElement('discretionaryData', null).getText();
            cardProfileUtil.trackingNumber = responseNodeResponseUtil.getChildElement('trackingNumber', null).getText();
            cardProfileUtil.productCode = responseNodeResponseUtil.getChildElement('productCode', null).getText();

            //Insatnce of Inner class for holding the profile limits
            ProfileLimits profileLimitsController = new ProfileLimits();

            //Populate data
            profileLimitsController.openCloseFlag = responseNodeProfileLimits.getChildElement('openCloseFlag', null).getText();
            profileLimitsController.productAvailableFlag = responseNodeProfileLimits.getChildElement('productAvailableFlag', null).getText();
            profileLimitsController.transactionDollarLimit = responseNodeProfileLimits.getChildElement('transactionDollarLimit', null).getText();
            profileLimitsController.transactionQuantityLimit = responseNodeProfileLimits.getChildElement('transactionQuantityLimit', null).getText();
            profileLimitsController.dailyDollarLimit = responseNodeProfileLimits.getChildElement('dailyDollarLimit', null).getText();
            profileLimitsController.dailyTransactionLimit = responseNodeProfileLimits.getChildElement('dailyTransactionLimit', null).getText();
            profileLimitsController.dailyQuantityLimit = responseNodeProfileLimits.getChildElement('dailyQuantityLimit', null).getText();
            profileLimitsController.cycleDollarLimit = responseNodeProfileLimits.getChildElement('cycleDollarLimit', null).getText();
            profileLimitsController.cycleTransactionLimit = responseNodeProfileLimits.getChildElement('cycleTransactionLimit', null).getText();
            profileLimitsController.cycleQuantityLimit = responseNodeProfileLimits.getChildElement('cycleQuantityLimit', null).getText();
            profileLimitsController.cycleType = responseNodeProfileLimits.getChildElement('cycleType', null).getText();
            profileLimitsController.cycleDay = responseNodeProfileLimits.getChildElement('cycleDay', null).getText();

            //Popualting variables with the values
            inquireCardProfileLimits.responseUtil = cardProfileUtil;
            inquireCardProfileLimits.profileLimits = profileLimitsController;
            inquireCardProfileLimits.responseCode = responseNode.getChildElement('responseCode', null).getText();
            inquireCardProfileLimits.responseDescription = responseNode.getChildElement('responseDescription', null).getText();
        }

        //Return value
        return inquireCardProfileLimits;
     }

     /**
     *  @description    :   This method is to parse the response for updateCardProfileLimits request
     *
     *  @param          :   HttpResponse
     *
     *  @return         :   instance of CardProfileLimitUpdateResponse class
     *
     **/
     public static CardProfileLimitUpdateResponse parseUpdateCardProfileLimits(HttpResponse response) {

        //Create an instance of updateCardProfileLimts response
        CardProfileLimitUpdateResponse updateCardProfileLimits = new CardProfileLimitUpdateResponse();

        //Get statusCode and throw error if it fails
        if(response.getStatusCode() != 200) {

            //Fault Deatils
            Dom.XmlNode responseNode = response.getBodyDocument().getRootElement()
                                        .getChildElement('Body', configDefaults.xmlns_soapenv__c)
                                        .getChildElement('Fault', configDefaults.xmlns_soapenv__c)
                                        .getChildElement('detail', null)
                                        .getChildElement('BusinessException', 'http://fleetCredit.comdata.com/exception/');

            //populate data
            updateCardProfileLimits.responseCode = responseNode.getChildElement('messageCode', null).getText();
            updateCardProfileLimits.responseDescription = responseNode.getChildElement('message', null).getText();

        } else {

            //Response node
            Dom.XmlNode responseNode = response.getBodyDocument().getRootElement()
                                            .getChildElement('Body', configDefaults.xmlns_soapenv__c)
                                            .getChildElement('CardProfileLimitUpdateResponse', configDefaults.xmlns_main__c);

            //Getting More Inner node values
            Dom.XmlNode responseNodeResponseUtil = responseNode.getChildElement('responseUtil', null);

            //Instance of Inner class to hold Card Profile Utility values
            CardProfileLimitReqResUtil cardProfileUtil = new CardProfileLimitReqResUtil();

            //Populate data
            cardProfileUtil.accountCode = responseNodeResponseUtil.getChildElement('accountCode', null).getText();
            cardProfileUtil.customerId = responseNodeResponseUtil.getChildElement('customerId', null).getText();
            cardProfileUtil.discretionaryData = responseNodeResponseUtil.getChildElement('discretionaryData', null).getText();
            cardProfileUtil.trackingNumber = responseNodeResponseUtil.getChildElement('trackingNumber', null).getText();
            cardProfileUtil.productCode = responseNodeResponseUtil.getChildElement('productCode', null).getText();

            //Popualting variables with the values
            updateCardProfileLimits.responseUtil = cardProfileUtil;
            updateCardProfileLimits.responseCode = responseNode.getChildElement('responseCode', null).getText();
            updateCardProfileLimits.responseDescription = responseNode.getChildElement('responseDescription', null).getText();
        }

        //Return value
        return updateCardProfileLimits;
     }

     /**
     *  @description    :   Parse realTimeTransactionHistory response and attach to transaction record to Creadit card
     *
     *  @param          :   HttpResponse
     *
     *  @return         :   instance of RTTransactionResponse class
     *
     **/
     public static RTTransactionResponse parseRTTransactionHistory(HttpResponse response) {

        //Create an instance of RtTransactionResponse response
        RTTransactionResponse rTTransactionResponse = new RTTransactionResponse();
        rTTransactionResponse.creditCardTransactions = new List<Credit_Card_Transaction__c>();
        rTTransactionResponse.creditCardTransactionsToDelete = new List<Credit_Card_Transaction__c>();

        //Set to hold Credit Card Ids
        rTTransactionResponse.cardIds = new Set<Id>();

        //Get statusCode and throw error if it fails
        if(response.getStatusCode() != 200) {

            //Fault Deatils
            Dom.XmlNode responseNode = response.getBodyDocument().getRootElement()
                                        .getChildElement('Body', configDefaults.xmlns_soapenv__c)
                                        .getChildElement('Fault', configDefaults.xmlns_soapenv__c)
                                        .getChildElement('detail', null)
                                        .getChildElement('BusinessException', 'http://fleetCredit.comdata.com/exception/');

            //populate data
            rTTransactionResponse.responseCode = responseNode.getChildElement('messageCode', null).getText();
            rTTransactionResponse.responseDescription = responseNode.getChildElement('message', null).getText();

        } else {

            //Response node
            Dom.XmlNode responseNode = response.getBodyDocument().getRootElement()
                                            .getChildElement('Body', configDefaults.xmlns_soapenv__c)
                                            .getChildElement('RtTransactionResponse', configDefaults.xmlns_main__c);

            rTTransactionResponse.pageCount = responseNode.getChildElement('pageCount', null).getText();
            rTTransactionResponse.pageNbr = responseNode.getChildElement('pageNbr', null).getText();
            rTTransactionResponse.recordCount = responseNode.getChildElement('recordCount', null).getText();

            //Set to hold all the credit card numbers for which, transaction happened
            Set<String> cardNumbers = new Set<String>();
            
            //Map to hold key is Combination of "cardNumber-mccNumber-mccGroup-approvalCode-transactionDate"
            //and Value as Credit Card Transaction instance
            Map<String, List<Credit_Card_Transaction__c>> ccTransactionUniqueMap = new Map<String, List<Credit_Card_Transaction__c>>();
            

            //Create a list of transaction records to be processed. This list will be used ti create the Credid Card transaction record
            List<RTTransactionRecord> transactionRecords = new List<RTTransactionRecord>();

            //Loop through Child Elements
            for(Dom.XMLNode xmlNode : responseNode.getChildElement('records', null).getChildElements()) {

                //Instance of Inner class
                RTTransactionRecord rtRecord = new RtTransactionRecord();

                //Populate Instance with the data
                rtRecord.accountCode = xmlNode.getChildElement('accountCode', null).getText();
                rtRecord.customerId = xmlNode.getChildElement('customerId', null).getText();
                rtRecord.customerName = xmlNode.getChildElement('customerName', null).getText();
                rtRecord.corporateCode = xmlNode.getChildElement('corporateCode', null).getText();
                rtRecord.transactionDate = xmlNode.getChildElement('transactionDate', null).getText();
                rtRecord.transactionTime = xmlNode.getChildElement('transactionTime', null).getText();
                rtRecord.postedDate = xmlNode.getChildElement('postedDate', null).getText();
                rtRecord.postedTime = xmlNode.getChildElement('postedTime', null).getText();
                rtRecord.transactionStatus = xmlNode.getChildElement('transactionStatus', null).getText();
                rtRecord.cardNumber = xmlNode.getChildElement('cardNumber', null).getText();
				rtRecord.cardNumber = 'XXXX-XXXX-XXXX-' + rtRecord.cardNumber.right(4);	
                rtRecord.cardholderName = xmlNode.getChildElement('cardholderName', null).getText();
                rtRecord.cardExpireDate = xmlNode.getChildElement('cardExpireDate', null).getText();
                rtRecord.declineCode = xmlNode.getChildElement('declineCode', null).getText();
                rtRecord.declineMessage = xmlNode.getChildElement('declineMessage', null).getText();
                rtRecord.correctiveAction = xmlNode.getChildElement('correctiveAction', null).getText();
                rtRecord.promptedId = xmlNode.getChildElement('promptedId', null).getText();
                rtRecord.mccGroup = xmlNode.getChildElement('mccGroup', null).getText();
                rtRecord.mccNumber = xmlNode.getChildElement('mccNumber', null).getText();
                rtRecord.mccDescription = xmlNode.getChildElement('mccDescription', null).getText();
                rtRecord.merchantName = xmlNode.getChildElement('merchantName', null).getText();
                rtRecord.merchantAddress = xmlNode.getChildElement('merchantAddress', null).getText();
                rtRecord.merchantCity = xmlNode.getChildElement('merchantCity', null).getText();
                rtRecord.merchantState = xmlNode.getChildElement('merchantState', null).getText();
                rtRecord.merchantZip = xmlNode.getChildElement('merchantZip', null).getText();
                rtRecord.acceptLocation = xmlNode.getChildElement('acceptLocation', null).getText();
                rtRecord.preAuthAmount = xmlNode.getChildElement('preAuthAmount', null).getText();
                rtRecord.postedAmount = xmlNode.getChildElement('postedAmount', null).getText();
                rtRecord.approvalCode = xmlNode.getChildElement('approvalCode', null).getText();
                rtRecord.reversalFlag = xmlNode.getChildElement('reversalFlag', null).getText();

                //Adding inner class instance populated with value in other one
                transactionRecords.add(rtRecord);
                cardNumbers.add(rtRecord.cardNumber);
            }

            //Popualting variables with the values
            rTTransactionResponse.responseCode = responseNode.getChildElement('responseCode', null).getText();
            rTTransactionResponse.responseDescription = responseNode.getChildElement('responseDescription', null).getText();
            rTTransactionResponse.transactionRecords = transactionRecords;

            //List of Credit_Card_Transaction__c records to be inserted
            List<Credit_Card_Transaction__c> creditCardTransactions = new List<Credit_Card_Transaction__c>();

            //Checking for Array size
            if(transactionRecords.size() > 0) {

                //Create a map to hold the credit card number and Credit card record id.
                Map<String, Id> mapCCNumberWithCCId = new Map<String, Id>();

                System.debug('creditCardTransactions:::::' + creditCardTransactions);
                System.debug('cardNumbers:::::' + cardNumbers);

                //Loop through credit card records if Card_Number__c is not null and Card Number in Set cardNumbers
                for(Credit_Card__c creditCard : [SELECT Id, Card_Number__c FROM Credit_Card__c
                                                         WHERE Card_Number__c != null AND Card_Number__c IN :cardNumbers]) {

                    //Populate map
                    mapCCNumberWithCCId.put(creditCard.Card_Number__c, creditCard.Id);

                    //Populate set
                    rTTransactionResponse.cardIds.add(creditCard.Id);
                }
                system.debug('HTTPResponseParser.parseRTTransactionHistory - rTTransactionResponse.cardIds.size : '+rTTransactionResponse.cardIds.size());

                //check for size of map
                if(mapCCNumberWithCCId.size() > 0) {

                    //Set to hold Unique word of combination "cardNumber-mccNumber-mccGroup-approvalCode-transactionDate"
                    Set<String> uniqenessString = new Set<String>();

                    //Loop through RtTransactionRecord array
                    for(RTTransactionRecord rtRecord : transactionRecords) {

                        //String to hold unique key
                        String uniqueData = '';
                        uniqueData += rtRecord.cardNumber + '-' + rtRecord.mccNumber + '-' + rtRecord.mccGroup + '-' + rtRecord.approvalCode;

                        if(rtRecord.transactionDate != null && rtRecord.transactionDate != '' && (!rtRecord.transactionDate.startsWith('0')) && rtRecord.transactionTime != null && rtRecord.transactionTime != '')
                            uniqueData += '-' + Datetime.newInstance(CreditCardHelper.buildDate(rtRecord.transactionDate), CreditCardHelper.buildTime(rtRecord.transactionTime)) + 'Z';
                        System.debug('uniqueData :::::::' + uniqueData);
                        uniqenessString.add(uniqueData);
                    }
                    system.debug('HTTPResponseParser.parseRTTransactionHistory - uniqenessString.size : '+uniqenessString.size());

                    //Check for size of set
                    if(uniqenessString.size() > 0){

                        //Status values to pull for potential updates
                        //set<string> tempStatus = new set<string>();
                        //tempStatus.add('Authorized');
						
						
                        //List to hold Credit Card Transactions
                        List<Credit_Card_Transaction__c> transactionList = [SELECT Id, Cleared__c, Closed__c, Transaction_Date_Time__c, Posted_Date_Time__c, Transaction_Status__c, Credit_Card__c,
                                                                                        Decline_Code__c, Decline_Message__c, Corrective_Action__c, MCC_Group__c, MCC_Description__c,
                                                                                        MCC_Number__c, Merchant_Name__c, Merchant_Address__c, Merchant_City__c, Merchant_State__c,
                                                                                        Merchant_Zip__c, Accept_Location__c, Pre_Auth_Amount__c, Posted_Amount__c, Approval_Code__c,
                                                                                        Reversal_Flag__c, Unique_Transaction_Key__c FROM Credit_Card_Transaction__c WHERE Unique_Transaction_Key__c IN :uniqenessString];
                                                                                        //AND Transaction_Status__c IN :tempStatus];
                        //Check for size of list
                        if(transactionList.size() > 0) {

                            //Loop through list of Credit Card Transcation
                            for(Credit_Card_Transaction__c creditTransaction : transactionList){

                                if(uniqenessString.contains(creditTransaction.Unique_Transaction_Key__c)) {
									
									//Add a new list in map if not already exists
									if(!ccTransactionUniqueMap.containsKey(creditTransaction.Unique_Transaction_Key__c))
										ccTransactionUniqueMap.put(creditTransaction.Unique_Transaction_Key__c, new List<Credit_Card_Transaction__c>());
									
                                    //put Unique Key field as key and Transcation record as value
                                    ccTransactionUniqueMap.get(creditTransaction.Unique_Transaction_Key__c).add(creditTransaction);
                                }
                            }
                        }
                        system.debug('HTTPResponseParser.parseRTTransactionHistory - transactionList.size : '+transactionList.size());
                    }

                    System.debug('ccTransactionUniqueMap:::::' + ccTransactionUniqueMap);

                    //Loop through RtTransactionRecord array
                    for(RTTransactionRecord rtRecord : transactionRecords) {

                        //Check if card exists
                        if(!mapCCNumberWithCCId.containsKey(rtRecord.cardNumber))
                            continue;

                        //String to hold unique key
                        String uniqueKey = '';
                        uniqueKey += rtRecord.cardNumber + '-' + rtRecord.mccNumber + '-' + rtRecord.mccGroup + '-' + rtRecord.approvalCode;

                        //Check for Posted Date and Time not null or blank
                        if(rtRecord.transactionDate != null && rtRecord.transactionDate != '' && (!rtRecord.transactionDate.startsWith('0')) && rtRecord.transactionTime != null && rtRecord.transactionTime != '')
                            uniqueKey += '-' + Datetime.newInstance(CreditCardHelper.buildDate(rtRecord.transactionDate), CreditCardHelper.buildTime(rtRecord.transactionTime)) + 'Z';
                        system.debug('HTTPResponseParser.parseRTTransactionHistory - uniqueKey1 : '+uniqueKey);

                        //Check map's keyset contains unique string
                        if(ccTransactionUniqueMap.containsKey(uniqueKey)) {
                        	
                        	//Get the list of transactions
                        	List<Credit_Card_Transaction__c> ccTransactions = ccTransactionUniqueMap.get(uniqueKey);
							Credit_Card_Transaction__c creditTransaction = ccTransactions[0];
							
							//Check if this is the only CCT with Unique Key, remove it from Map
							if(ccTransactions.size() == 1)
								ccTransactionUniqueMap.remove(uniqueKey);
							else
								ccTransactionUniqueMap.get(uniqueKey).remove(0);
								
							//If this is already closed, then move to the next record
							if(creditTransaction.Transaction_Status__c == 'Closed')
								continue;
	
                            //creditTransaction.Transaction_Date_Time__c = rtRecord.transactionTime;
                            //creditTransaction.Posted_Date_Time__c = ccTransactionUniqueMap.get(uniqueKey).Posted_Date_Time__c;
                            creditTransaction.Transaction_Status__c = rtRecord.transactionStatus;
                            creditTransaction.Decline_Code__c = rtRecord.declineCode;
                            creditTransaction.Decline_Message__c = rtRecord.declineMessage;
                            creditTransaction.Corrective_Action__c = rtRecord.correctiveAction;
                            creditTransaction.MCC_Group__c = rtRecord.mccGroup;
                            creditTransaction.MCC_Description__c = rtRecord.mccDescription;
                            creditTransaction.MCC_Number__c = rtRecord.mccNumber;
                            creditTransaction.Merchant_Name__c = rtRecord.merchantName;
                            creditTransaction.Merchant_Address__c = rtRecord.merchantAddress;
                            creditTransaction.Merchant_City__c = rtRecord.merchantCity;
                            creditTransaction.Merchant_State__c = rtRecord.merchantState;
                            creditTransaction.Merchant_Zip__c = rtRecord.merchantZip;
                            creditTransaction.Accept_Location__c = rtRecord.acceptLocation;
                            creditTransaction.Pre_Auth_Amount__c = rtRecord.preAuthAmount;
                            creditTransaction.Posted_Amount__c = rtRecord.postedAmount;
                            creditTransaction.Approval_Code__c = rtRecord.approvalCode;
                            creditTransaction.Reversal_Flag__c = rtRecord.reversalFlag;
                                
                            if(rtRecord.postedDate != null && rtRecord.postedDate != '' && (!rtRecord.postedDate.startsWith('0')) && rtRecord.postedTime != null && rtRecord.postedTime != '')
                                creditTransaction.Posted_Date_Time__c = Datetime.newInstance(CreditCardHelper.buildDate(rtRecord.postedDate), CreditCardHelper.buildTime(rtRecord.postedTime));

                            if(rtRecord.transactionDate != null && rtRecord.transactionDate != '' && (!rtRecord.transactionDate.startsWith('0')) && rtRecord.transactionTime != null && rtRecord.transactionTime != '')
                                creditTransaction.Transaction_Date_Time__c = DateTime.newInstance(CreditCardHelper.buildDate(rtRecord.transactionDate), CreditCardHelper.buildTime(rtRecord.transactionTime));

                                //add into list of Credit Card Transactions
                            creditCardTransactions.add(creditTransaction);
                            system.debug('HTTPResponseParser.parseRTTransactionHistory - creditTransaction_match : '+creditTransaction);
                        } else {

                            //instance of Credit Card Transaction
                            Credit_Card_Transaction__c creditTransaction = new Credit_Card_Transaction__c();
                            if(rtRecord.transactionDate != null && rtRecord.transactionDate != '' && (!rtRecord.transactionDate.startsWith('0')) && rtRecord.transactionTime != null && rtRecord.transactionTime != '')
                                creditTransaction.Transaction_Date_Time__c = DateTime.newInstance(CreditCardHelper.buildDate(rtRecord.transactionDate), CreditCardHelper.buildTime(rtRecord.transactionTime));

                            if(rtRecord.postedDate != null && rtRecord.postedDate != '' && (!rtRecord.postedDate.startsWith('0')) && rtRecord.postedTime != null && rtRecord.postedTime != '')
                                creditTransaction.Posted_Date_Time__c = Datetime.newInstance(CreditCardHelper.buildDate(rtRecord.postedDate), CreditCardHelper.buildTime(rtRecord.postedTime));

                            creditTransaction.Transaction_Status__c = rtRecord.transactionStatus;
                            System.debug('mapCCNumberWithCCId.get(rtRecord.cardNumber) :::::: ' + mapCCNumberWithCCId.get(rtRecord.cardNumber));
                            creditTransaction.Credit_Card__c = mapCCNumberWithCCId.get(rtRecord.cardNumber);
                            creditTransaction.Decline_Code__c = rtRecord.declineCode;
                            creditTransaction.Decline_Message__c = rtRecord.declineMessage;
                            creditTransaction.Corrective_Action__c = rtRecord.correctiveAction;
                            creditTransaction.MCC_Group__c = rtRecord.mccGroup;
                            creditTransaction.MCC_Description__c = rtRecord.mccDescription;
                            creditTransaction.MCC_Number__c = rtRecord.mccNumber;
                            creditTransaction.Merchant_Name__c = rtRecord.merchantName;
                            creditTransaction.Merchant_Address__c = rtRecord.merchantAddress;
                            creditTransaction.Merchant_City__c = rtRecord.merchantCity;
                            creditTransaction.Merchant_State__c = rtRecord.merchantState;
                            creditTransaction.Merchant_Zip__c = rtRecord.merchantZip;
                            creditTransaction.Accept_Location__c = rtRecord.acceptLocation;
                            creditTransaction.Pre_Auth_Amount__c = rtRecord.preAuthAmount;
                            creditTransaction.Posted_Amount__c = rtRecord.postedAmount;
                            creditTransaction.Approval_Code__c = rtRecord.approvalCode;
                            creditTransaction.Reversal_Flag__c = rtRecord.reversalFlag;

                            //add into list of Credit Card Transactions
                            creditCardTransactions.add(creditTransaction);
                            system.debug('HTTPResponseParser.parseRTTransactionHistory - creditTransaction_new : '+creditTransaction);
                        }
                    }
                }
            }
            //Checking for size of transactions list and Add in Response
            if(creditCardTransactions.size() > 0)
                rTTransactionResponse.creditCardTransactions.addAll(creditCardTransactions);
                
            //Now loop through the remaining list of transactions in Credit Card Transaction Map and add them in the list to be deleted
            for(List<Credit_Card_Transaction__c> lstCCT : ccTransactionUniqueMap.values()) {
            	
            	//Filter out the cleared and closed transaction
            	for(Credit_Card_Transaction__c ccT : lstCCT)
            		if(cCT.Cleared__c == false && cCT.Closed__c == false)
            			rTTransactionResponse.creditCardTransactionsToDelete.add(cCT);
            }
        }

        //Return value
        return rTTransactionResponse;
     }
}