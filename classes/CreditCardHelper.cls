/**
 *  Purpose         :   Helper class for credit card functionality
 *
 *  Created By      :   Bhavi Sharma
 *
 *  Created Date    :   08/15/2013
 *
 *  Current Version :   V_1.0 - Created
 *                      v_1.1 - 02/27/2014 - Bhavi Sharma - Modiofied - CR-20140224-4621
 *                      V_1.2 - 09/11/2014 - Ajit Surana - Modified - CR-20140815-7030
 *                      v_1.3 - 10/10/2014 - Colin McGloin - Modified - CR-20141009-7724
 *						V_1.4 - 06/18/2015 - Bhavi Sharma - Modiofied - CR-20141212-8307  
 *						V_1.5 - 06/30/2015 - Bhavi Sharma - Modiofied - CR-20150630-9037: First Name and Last Name nodes removed from unblock  and deactivate calls
 *						V_1.6 - 10/23/2015 - Bhavi Sharma - Modiofied - CR-20151002-9293: getAddress method updated to pull the data from OSR only when Address Update is not request
 *						V_1.7 - 12/07/2015 - Mahendra Swarnkar - Modiofied - CR-20151109-9376 Formating First name and Last name in nodes and in creditcard's request log, so that FirstName and LastName contains only alphabatical characters and spaces with in it.
 *						V_1.8 - 12/17/2015 - Bhavi Sahrma - Modiofied - CR-20151209-9446 Credit Card - Billing/Alternate address fix  
 **/
public with sharing class CreditCardHelper {

    //get CC Default Settings instance  
    public static Credit_Card_Settings__c configDefaults = CreditCardConstants.CONFIG_DEFAULT;

    //Tracking Number
    public static String trackingNumberForEnvelope = String.valueOf(Math.random()).right(10);
    
    //Initializa Wrapper
    AttentionAddressWrapper addressWrapper = new AttentionAddressWrapper();
    
    /**
     *  @description    :   This method is to create a request Envelope for Add credit card request
     *
     *  @param          :   Credit Card
     *
     *  @return         :   fleetcreditComdataComMaintenance.card
     *
     **/
    public static String getAddCreditCardRequestEnvelope(Credit_Card__c creditCard) {
        
        //Initializa Wrapper
        AttentionAddressWrapper addressWrapper = CreditCardHelper.getAddress(creditCard);
           
        //request Envelope
        String requestEnvelope = CreditCardConstants.COMDATA_REQUEST_ENVELOPE_NAMESPACE_STRING
                                    + CreditCardConstants.COMDATA_REQUEST_ENVELOPE_HEADER
                                    + '<soapenv:Body>'
                                        + '<main:AddCardRequest>'
                                            + '<cardDetails>'
                                                + '<accountCode>'+ parseNull(configDefaults.Account_Code__c) +'</accountCode>'
                                                + '<customerId>'+ parseNull(configDefaults.Customer_Id__c) +'</customerId>'
                                                + '<trackingNumber>' + parseNull(trackingNumberForEnvelope) + '</trackingNumber>'
                                                + '<cardStatus>'+ parseNull(configDefaults.Default_Vendor_Card_Status__c) +'</cardStatus>'
                                                + '<profileFlag>'+ parseNull(configDefaults.Card_Profile_Flag__c) +'</profileFlag>'
                                                + '<profileValue>'+ parseNull(configDefaults.Default_Card_Profile_Value__c) +'</profileValue>'
                                                + '<cardFirstName>' + Util.formatToAlphabatical(parseNull(creditCard.Payment_Account__r.First_Name_On_Card__c)) + '</cardFirstName>'
                                                + '<cardLastName>' + Util.formatToAlphabatical(parseNull(creditCard.Payment_Account__r.Last_Name_On_Card__c)) + '</cardLastName>'
                                                + '<employeeNumber>' + parseNull(parseNull(creditCard.Card_Employee_Number__c)) + '</employeeNumber>'
                                            + '</cardDetails>'
                                            + '<mailingDetails>'
                                                + '<mailMethod>' + parseNull(configDefaults.Default_Delivery_Option_Code__c) + '</mailMethod>'
                                                + '<mailName>' + parseNull(configDefaults.Company_Name__c) + '</mailName>'
                                                + '<mailAttentionTo>' + addressWrapper.mailAttentionTo + '</mailAttentionTo>'
                                                + '<mailAddress1>' + addressWrapper.addressLine1 + '</mailAddress1>'
                                                + '<mailAddress2>' + addressWrapper.addressLine2 + '</mailAddress2>'
                                                + '<mailCity>' + addressWrapper.city + '</mailCity>'
                                                + '<mailState>' + addressWrapper.state + '</mailState>'
                                                + '<mailZip>' + addressWrapper.postalCode + '</mailZip>'
                                            + '</mailingDetails>'
                                            + '<maskCardFlag>' + parseNull(configDefaults.Mask_Card_Num_On_Create__c) + '</maskCardFlag>'
                                        + '</main:AddCardRequest>'
                                    + '</soapenv:Body>'
                                + '</soapenv:Envelope>';

        //Instance of Card
        CreditCardService.Request_Log += 'accountCode = ' + configDefaults.Account_Code__c + '\n';
        CreditCardService.Request_Log += 'customerId = ' + configDefaults.Customer_Id__c + '\n';
        CreditCardService.Request_Log += 'trackingNumber = ' + trackingNumberForEnvelope + '\n';
        CreditCardService.Request_Log += 'cardStatus = ' + configDefaults.Default_Vendor_Card_Status__c + '\n';
        CreditCardService.Request_Log += 'profileFlag = ' + configDefaults.Card_Profile_Flag__c + '\n';
        CreditCardService.Request_Log += 'profileValue = ' + configDefaults.Default_Card_Profile_Value__c + '\n';
        CreditCardService.Request_Log += 'cardFirstName = ' + Util.formatToAlphabatical(parseNull(creditCard.Payment_Account__r.First_Name_On_Card__c)) + '\n';
        CreditCardService.Request_Log += 'cardLastName = ' + Util.formatToAlphabatical(parseNull(creditCard.Payment_Account__r.Last_Name_On_Card__c)) + '\n';
        CreditCardService.Request_Log += 'employeeNumber = ' + parseNull(creditCard.Card_Employee_Number__c) + '\n';
        CreditCardService.Request_Log += 'mailMethod = ' + configDefaults.Default_Delivery_Option_Code__c + '\n';
        CreditCardService.Request_Log += 'mailName = ' + configDefaults.Company_Name__c + '\n';
        CreditCardService.Request_Log += 'mailAttentionTo = ' + addressWrapper.mailAttentionTo + '\n';
        CreditCardService.Request_Log += 'mailAddress1 = ' + addressWrapper.addressLine1 + '\n';
        CreditCardService.Request_Log += 'mailAddress2 = ' + addressWrapper.addressLine2+ '\n';
        CreditCardService.Request_Log += 'mailCity = ' + addressWrapper.city + '\n';
        CreditCardService.Request_Log += 'mailState = ' + addressWrapper.state + '\n';
        CreditCardService.Request_Log += 'mailZip = ' + addressWrapper.postalCode + '\n';
        CreditCardService.Request_Log += 'maskCardFlag = ' + configDefaults.Mask_Card_Num_On_Create__c + '\n';

        //Return Envelope String
        return requestEnvelope;
    }

    /**
     *  @description    :   This method is to create a request Envelope for Add credit card request
     *
     *  @param          :   Credit Card
     *
     *  @return         :   fleetcreditComdataComMaintenance.card
     *
     **/
    public static String getAddCreditCardExpediatedRequestEnvelope(Credit_Card__c creditCard) {
        
        //Initializa Wrapper
        AttentionAddressWrapper addressWrapper = CreditCardHelper.getAddress(creditCard);
        
        //request Envelope
        String requestEnvelope = CreditCardConstants.COMDATA_REQUEST_ENVELOPE_NAMESPACE_STRING
                                    + CreditCardConstants.COMDATA_REQUEST_ENVELOPE_HEADER
                                    + '<soapenv:Body>'
                                        + '<main:AddCardRequest>'
                                            + '<cardDetails>'
                                                + '<accountCode>'+ parseNull(configDefaults.Account_Code__c) +'</accountCode>'
                                                + '<customerId>'+ parseNull(configDefaults.Customer_Id__c) +'</customerId>'
                                                + '<trackingNumber>' + parseNull(trackingNumberForEnvelope) + '</trackingNumber>'
                                                + '<cardStatus>'+ parseNull(configDefaults.Default_Vendor_Card_Status__c) +'</cardStatus>'
                                                + '<profileFlag>'+ parseNull(configDefaults.Card_Profile_Flag__c) +'</profileFlag>'
                                                + '<profileValue>'+ parseNull(configDefaults.Default_Card_Profile_Value__c) +'</profileValue>'
                                                + '<cardFirstName>' + util.formatToAlphabatical(parseNull(creditCard.Payment_Account__r.First_Name_On_Card__c)) + '</cardFirstName>'
                                                + '<cardLastName>' + Util.formatToAlphabatical(parseNull(creditCard.Payment_Account__r.Last_Name_On_Card__c)) + '</cardLastName>'
                                                + '<employeeNumber>' + parseNull(creditCard.Card_Employee_Number__c) + '</employeeNumber>'
                                            + '</cardDetails>'
                                            + '<mailingDetails>'
                                                + '<mailMethod>' + parseNull(configDefaults.Expedited_Delivery_Option_Code__c) + '</mailMethod>'
                                                + '<mailName>' + parseNull(configDefaults.Company_Name__c) + '</mailName>'
                                                + '<mailAttentionTo>' + addressWrapper.mailAttentionTo + '</mailAttentionTo>'
                                                + '<mailAddress1>' + addressWrapper.addressLine1 + '</mailAddress1>'
                                                + '<mailAddress2>' + addressWrapper.addressLine2 + '</mailAddress2>'
                                                + '<mailCity>' + addressWrapper.city + '</mailCity>'
                                                + '<mailState>' + addressWrapper.state + '</mailState>'
                                                + '<mailZip>' + addressWrapper.postalCode + '</mailZip>'
                                            + '</mailingDetails>'
                                            + '<maskCardFlag>' + parseNull(configDefaults.Mask_Card_Num_On_Create__c) + '</maskCardFlag>'
                                        + '</main:AddCardRequest>'
                                    + '</soapenv:Body>'
                                + '</soapenv:Envelope>';

        //Instance of Card
        CreditCardService.Request_Log += 'accountCode = ' + configDefaults.Account_Code__c + '\n';
        CreditCardService.Request_Log += 'customerId = ' + configDefaults.Customer_Id__c + '\n';
        CreditCardService.Request_Log += 'trackingNumber = ' + trackingNumberForEnvelope + '\n';
        CreditCardService.Request_Log += 'cardStatus = ' + configDefaults.Default_Vendor_Card_Status__c + '\n';
        CreditCardService.Request_Log += 'profileFlag = ' + configDefaults.Card_Profile_Flag__c + '\n';
        CreditCardService.Request_Log += 'profileValue = ' + configDefaults.Default_Card_Profile_Value__c + '\n';
        CreditCardService.Request_Log += 'cardFirstName = ' + Util.formatToAlphabatical(parseNull(creditCard.Payment_Account__r.First_Name_On_Card__c)) + '\n';
        CreditCardService.Request_Log += 'cardLastName = ' + Util.formatToAlphabatical(parseNull(creditCard.Payment_Account__r.Last_Name_On_Card__c)) + '\n';
        CreditCardService.Request_Log += 'employeeNumber = ' + parseNull(creditCard.Card_Employee_Number__c) + '\n';
        CreditCardService.Request_Log += 'mailMethod = ' + configDefaults.Default_Delivery_Option_Code__c + '\n';
        CreditCardService.Request_Log += 'mailName = ' + configDefaults.Company_Name__c + '\n';
        CreditCardService.Request_Log += 'mailAttentionTo = ' + addressWrapper.mailAttentionTo + '\n';
        CreditCardService.Request_Log += 'mailAddress1 = ' + addressWrapper.addressLine1 + '\n';
        CreditCardService.Request_Log += 'mailAddress2 = ' + addressWrapper.addressLine2+ '\n';
        CreditCardService.Request_Log += 'mailCity = ' + addressWrapper.city + '\n';
        CreditCardService.Request_Log += 'mailState = ' + addressWrapper.state + '\n';
        CreditCardService.Request_Log += 'mailZip = ' + addressWrapper.postalCode + '\n';
        CreditCardService.Request_Log += 'maskCardFlag = ' + configDefaults.Mask_Card_Num_On_Create__c + '\n';

        //Return Envelope String
        return requestEnvelope;
    }
    
    /**
     *  @description    :   This method is to create a request Envelope for Add credit card request
     *
     *  @param          :   Credit Card
     *
     *  @return         :   fleetcreditComdataComMaintenance.card
     *
     **/
    public static String getAddCreditCardAlternateDeliveryRequestEnvelope(Credit_Card__c creditCard) {
        
        //Initializa Wrapper
        AttentionAddressWrapper addressWrapper = CreditCardHelper.getAddress(creditCard);
        
        //request Envelope
        String requestEnvelope = CreditCardConstants.COMDATA_REQUEST_ENVELOPE_NAMESPACE_STRING
                                    + CreditCardConstants.COMDATA_REQUEST_ENVELOPE_HEADER
                                    + '<soapenv:Body>'
                                        + '<main:AddCardRequest>'
                                            + '<cardDetails>'
                                                + '<accountCode>'+ parseNull(configDefaults.Account_Code__c) +'</accountCode>'
                                                + '<customerId>'+ parseNull(configDefaults.Customer_Id__c) +'</customerId>'
                                                + '<trackingNumber>' + parseNull(trackingNumberForEnvelope) + '</trackingNumber>'
                                                + '<cardStatus>'+ parseNull(configDefaults.Default_Vendor_Card_Status__c) +'</cardStatus>'
                                                + '<profileFlag>'+ parseNull(configDefaults.Card_Profile_Flag__c) +'</profileFlag>'
                                                + '<profileValue>'+ parseNull(configDefaults.Default_Card_Profile_Value__c) +'</profileValue>'
                                                + '<cardFirstName>' + Util.formatToAlphabatical(parseNull(creditCard.Payment_Account__r.First_Name_On_Card__c)) + '</cardFirstName>'
                                                + '<cardLastName>' + Util.formatToAlphabatical(parseNull(creditCard.Payment_Account__r.Last_Name_On_Card__c)) + '</cardLastName>'
                                                + '<employeeNumber>' + parseNull(creditCard.Card_Employee_Number__c) + '</employeeNumber>'
                                            + '</cardDetails>'
                                            + '<mailingDetails>'
                                                + '<mailMethod>' + parseNull(configDefaults.Expedited_Delivery_Option_Code__c) + '</mailMethod>'
                                                + '<mailName>' + parseNull(configDefaults.Company_Name__c) + '</mailName>'
                                                + '<mailAttentionTo>' + addressWrapper.mailAttentionTo + '</mailAttentionTo>'
                                                + '<mailAddress1>' + addressWrapper.addressLine1 + '</mailAddress1>'
                                                + '<mailAddress2>' + addressWrapper.addressLine2 + '</mailAddress2>'
                                                + '<mailCity>' + addressWrapper.city + '</mailCity>'
                                                + '<mailState>' + addressWrapper.state + '</mailState>'
                                                + '<mailZip>' + addressWrapper.postalCode + '</mailZip>'
                                            + '</mailingDetails>'
                                            + '<maskCardFlag>' + parseNull(configDefaults.Mask_Card_Num_On_Create__c) + '</maskCardFlag>'
                                        + '</main:AddCardRequest>'
                                    + '</soapenv:Body>'
                                + '</soapenv:Envelope>';

        //Instance of Card
        CreditCardService.Request_Log += 'accountCode = ' + configDefaults.Account_Code__c + '\n';
        CreditCardService.Request_Log += 'customerId = ' + configDefaults.Customer_Id__c + '\n';
        CreditCardService.Request_Log += 'trackingNumber = ' + trackingNumberForEnvelope + '\n';
        CreditCardService.Request_Log += 'cardStatus = ' + configDefaults.Default_Vendor_Card_Status__c + '\n';
        CreditCardService.Request_Log += 'profileFlag = ' + configDefaults.Card_Profile_Flag__c + '\n';
        CreditCardService.Request_Log += 'profileValue = ' + configDefaults.Default_Card_Profile_Value__c + '\n';
        CreditCardService.Request_Log += 'cardFirstName = ' + Util.formatToAlphabatical(parseNull(creditCard.Payment_Account__r.First_Name_On_Card__c)) + '\n';
        CreditCardService.Request_Log += 'cardLastName = ' + Util.formatToAlphabatical(parseNull(creditCard.Payment_Account__r.Last_Name_On_Card__c)) + '\n';
        CreditCardService.Request_Log += 'employeeNumber = ' + parseNull(creditCard.Card_Employee_Number__c) + '\n';
        CreditCardService.Request_Log += 'mailMethod = ' + configDefaults.Default_Delivery_Option_Code__c + '\n';
        CreditCardService.Request_Log += 'mailName = ' + configDefaults.Company_Name__c + '\n';
        CreditCardService.Request_Log += 'mailAttentionTo = ' + addressWrapper.mailAttentionTo + '\n';
        CreditCardService.Request_Log += 'mailAddress1 = ' + addressWrapper.addressLine1 + '\n';
        CreditCardService.Request_Log += 'mailAddress2 = ' + addressWrapper.addressLine2+ '\n';
        CreditCardService.Request_Log += 'mailCity = ' + addressWrapper.city + '\n';
        CreditCardService.Request_Log += 'mailState = ' + addressWrapper.state + '\n';
        CreditCardService.Request_Log += 'mailZip = ' + addressWrapper.postalCode + '\n';
        CreditCardService.Request_Log += 'maskCardFlag = ' + configDefaults.Mask_Card_Num_On_Create__c + '\n';

        //Return Envelope String
        return requestEnvelope;
    }
    
    /**
     *  @description    :   This method is to build replacement of Credit Card in Comdata SOAP web service request envelope.
     *
     *  @param          :   SFDC Credit Card record
     *
     *  @return         :   String
     *
     **/
    public static String getDeactivateCreditCardForReplacementEnvelope(Credit_Card__c creditCard) {

        //String to hold the request SOAP envelope string
        String deactivateCreditCardForReplacementRequestEnvelopeString = CreditCardConstants.COMDATA_REQUEST_ENVELOPE_NAMESPACE_STRING;

        //Appending Authorized Header String into request envelope
        deactivateCreditCardForReplacementRequestEnvelopeString += CreditCardConstants.COMDATA_REQUEST_ENVELOPE_HEADER;

        //Appending required input parameters body string to the request envelope
        deactivateCreditCardForReplacementRequestEnvelopeString += '<soapenv:Body>'
                                                 + '<main:UpdateCardRequest>'
                                                     + '<empNumCardNumFlag>E</empNumCardNumFlag>'
                                                     + '<empNumCardNumValue>' + parseNull(creditCard.Card_Employee_Number__c) + '</empNumCardNumValue>'
                                                     + '<cardDetails>'
                                                         + '<accountCode>'+ parseNull(configDefaults.Account_Code__c) +'</accountCode>'
                                                         + '<customerId>'+ parseNull(configDefaults.Customer_Id__c) +'</customerId>'
                                                         + '<trackingNumber>' + parseNull(trackingNumberForEnvelope) + '</trackingNumber>'
                                                         + '<cardStatus>' + 'B' + '</cardStatus>'
                                                         + '<profileFlag>'+ parseNull(configDefaults.Card_Profile_Flag__c) +'</profileFlag>'
                                                         + '<employeeNumber>' + parseNull(creditCard.Card_Employee_Number__c) + '</employeeNumber>'
                                                    + '</cardDetails>'
                                                    + '<mailingDetails>'
                                                    + '</mailingDetails>'
                                                    + '<maskCardFlag>' + parseNull(configDefaults.Mask_Card_Num_On_Inquiry_Update__c) + '</maskCardFlag>'
                                                 + '</main:UpdateCardRequest>'
                                             + '</soapenv:Body>'
                                         + '</soapenv:Envelope>';

        //Instance of Card
        CreditCardService.Request_Log += 'empNumCardNumFlag = ' + 'E' + '\n';
        CreditCardService.Request_Log += 'empNumCardNumValue = ' + parseNull(creditCard.Card_Employee_Number__c) + '\n';
        CreditCardService.Request_Log += 'accountCode = ' + configDefaults.Account_Code__c + '\n';
        CreditCardService.Request_Log += 'customerId = ' + configDefaults.Customer_Id__c + '\n';
        CreditCardService.Request_Log += 'trackingNumber = ' + trackingNumberForEnvelope + '\n';
        CreditCardService.Request_Log += 'cardStatus = ' + 'B' + '\n';
        CreditCardService.Request_Log += 'profileFlag = ' + configDefaults.Card_Profile_Flag__c + '\n';
        CreditCardService.Request_Log += 'employeeNumber = ' + parseNull(creditCard.Card_Employee_Number__c) + '\n';
        CreditCardService.Request_Log += 'maskCardFlag = ' + parseNull(configDefaults.Mask_Card_Num_On_Inquiry_Update__c) + '\n';

        //Return envelope string
        return deactivateCreditCardForReplacementRequestEnvelopeString;
    }

    /**
     *  @description    :   This method is to build deactiveCreditCard Comdata SOAP web service request envelope.
     *
     *  @param          :   SFDC Credit Card record
     *
     *  @return         :   String
     *
     **/
    public static String getDeactivateCreditCardEnvelope(Credit_Card__c creditCard) {

        //String to hold the request SOAP envelope string
        String deactivateCreditCardRequestEnvelopeString = CreditCardConstants.COMDATA_REQUEST_ENVELOPE_NAMESPACE_STRING;

        //Appending Authorized Header String into request envelope
        deactivateCreditCardRequestEnvelopeString += CreditCardConstants.COMDATA_REQUEST_ENVELOPE_HEADER;

        //Appending required input parameters body string to the request envelope
        //Bhavi Sharma - 06/30/2015 - CR-20150630-9037: Card First Name and Last Name  Nodes have been removed
        deactivateCreditCardRequestEnvelopeString += '<soapenv:Body>'
                                                 + '<main:UpdateCardRequest>'
                                                     + '<empNumCardNumFlag>E</empNumCardNumFlag>'
                                                     + '<empNumCardNumValue>' + parseNull(creditCard.Card_Employee_Number__c) + '</empNumCardNumValue>'
                                                     + '<cardDetails>'
                                                         + '<accountCode>'+ parseNull(configDefaults.Account_Code__c) +'</accountCode>'
                                                         + '<customerId>'+ parseNull(configDefaults.Customer_Id__c) +'</customerId>'
                                                         + '<trackingNumber>' + parseNull(trackingNumberForEnvelope) + '</trackingNumber>'
                                                         + '<cardStatus>B</cardStatus>'
                                                         + '<profileFlag>'+ parseNull(configDefaults.Card_Profile_Flag__c) +'</profileFlag>'
                                                         //+ '<cardFirstName>' + parseNull(creditCard.Card_Holder_First_Name__c) + '</cardFirstName>'
                                                         //+ '<cardLastName>' + parseNull(creditCard.Card_Holder_Last_Name__c) + '</cardLastName>'
                                                         + '<employeeNumber>' + parseNull(creditCard.Card_Employee_Number__c) + '</employeeNumber>'
                                                    + '</cardDetails>'
                                                    + '<mailingDetails>'
                                                    + '</mailingDetails>'
                                                    + '<maskCardFlag>' + parseNull(configDefaults.Mask_Card_Num_On_Inquiry_Update__c) + '</maskCardFlag>'
                                                 + '</main:UpdateCardRequest>'
                                             + '</soapenv:Body>'
                                         + '</soapenv:Envelope>';

        //Instance of Card
        CreditCardService.Request_Log += 'empNumCardNumFlag = ' + 'E' + '\n';
        CreditCardService.Request_Log += 'empNumCardNumValue = ' + parseNull(creditCard.Card_Employee_Number__c) + '\n';
        CreditCardService.Request_Log += 'accountCode = ' + configDefaults.Account_Code__c + '\n';
        CreditCardService.Request_Log += 'customerId = ' + configDefaults.Customer_Id__c + '\n';
        CreditCardService.Request_Log += 'profileFlag = ' + configDefaults.Card_Profile_Flag__c + '\n';
        CreditCardService.Request_Log += 'trackingNumber = ' + trackingNumberForEnvelope + '\n';
        CreditCardService.Request_Log += 'cardStatus = ' + 'B' + '\n';
        CreditCardService.Request_Log += 'profileFlag = ' + configDefaults.Card_Profile_Flag__c + '\n';
        CreditCardService.Request_Log += 'cardFirstName = ' + Util.formatToAlphabatical(parseNull(creditCard.Card_Holder_First_Name__c)) + '\n';
        CreditCardService.Request_Log += 'cardLastName = ' + Util.formatToAlphabatical(parseNull(creditCard.Card_Holder_Last_Name__c)) + '\n';
        CreditCardService.Request_Log += 'employeeNumber = ' + parseNull(creditCard.Card_Employee_Number__c) + '\n';
        CreditCardService.Request_Log += 'maskCardFlag = ' + parseNull(configDefaults.Mask_Card_Num_on_Inquiry_Update__c) + '\n';

        //Return envelope string
        return deactivateCreditCardRequestEnvelopeString;
    }

    /**
     *  @description    :   This method is to build activateCreditCard Comdata SOAP web service request envelope.
     *
     *  @param          :   SFDC Credit Card record
     *
     *  @return         :   String
     *
     **/
    public static String getActivateCreditCardEnvelope(Credit_Card__c creditCard) {

        //Initializa Wrapper
        AttentionAddressWrapper addressWrapper = CreditCardHelper.getAddress(creditCard);
        
        //String to hold the request SOAP envelope string
        String activateCreditCardRequestEnvelopeString = CreditCardConstants.COMDATA_REQUEST_ENVELOPE_NAMESPACE_STRING;

        //Appending Authorized Header String into request envelope
        activateCreditCardRequestEnvelopeString += CreditCardConstants.COMDATA_REQUEST_ENVELOPE_HEADER;

        //Appending required input parameters body string to the request envelope
        //Bhavi Sharma - 06/30/2015 - CR-20150630-9037: Card First Name and Last Name  Nodes have been removed
        activateCreditCardRequestEnvelopeString += '<soapenv:Body>'
                                                 + '<main:UpdateCardRequest>'
                                                     + '<empNumCardNumFlag>E</empNumCardNumFlag>'
                                                     + '<empNumCardNumValue>' + parseNull(creditCard.Card_Employee_Number__c) + '</empNumCardNumValue>'
                                                     + '<cardDetails>'
                                                         + '<accountCode>'+ parseNull(configDefaults.Account_Code__c) +'</accountCode>'
                                                         + '<customerId>'+ parseNull(configDefaults.Customer_Id__c) +'</customerId>'
                                                         + '<trackingNumber>' + parseNull(trackingNumberForEnvelope) + '</trackingNumber>'
                                                         + '<cardStatus>A</cardStatus>'
                                                         + '<profileFlag>'+ parseNull(configDefaults.Card_Profile_Flag__c) +'</profileFlag>'
                                                         + '<employeeNumber>' + parseNull(creditCard.Card_Employee_Number__c) + '</employeeNumber>'
                                                    + '</cardDetails>'
                                                    + '<mailingDetails>'
		                                                + '<mailMethod>' + parseNull(configDefaults.Default_Delivery_Option_Code__c) + '</mailMethod>'
		                                                + '<mailName>' + parseNull(configDefaults.Company_Name__c) + '</mailName>'
		                                                + '<mailAttentionTo>' + addressWrapper.mailAttentionTo + '</mailAttentionTo>'
		                                                + '<mailAddress1>' + addressWrapper.addressLine1 + '</mailAddress1>'
		                                                + '<mailAddress2>' + addressWrapper.addressLine2 + '</mailAddress2>'
		                                                + '<mailCity>' + addressWrapper.city + '</mailCity>'
		                                                + '<mailState>' + addressWrapper.state + '</mailState>'
		                                                + '<mailZip>' + addressWrapper.postalCode + '</mailZip>'
		                                            + '</mailingDetails>'
                                                    + '<maskCardFlag>' + parseNull(configDefaults.Mask_Card_Num_On_Inquiry_Update__c) + '</maskCardFlag>'
                                                 + '</main:UpdateCardRequest>'
                                             + '</soapenv:Body>'
                                         + '</soapenv:Envelope>';

        //Instance of Card
        CreditCardService.Request_Log += 'empNumCardNumFlag = ' + 'E' + '\n';
        CreditCardService.Request_Log += 'empNumCardNumValue = ' + parseNull(creditCard.Card_Employee_Number__c) + '\n';
        CreditCardService.Request_Log += 'accountCode = ' + configDefaults.Account_Code__c + '\n';
        CreditCardService.Request_Log += 'customerId = ' + configDefaults.Customer_Id__c + '\n';
        CreditCardService.Request_Log += 'trackingNumber = ' + trackingNumberForEnvelope + '\n';
        CreditCardService.Request_Log += 'profileFlag = ' + configDefaults.Card_Profile_Flag__c + '\n';
        CreditCardService.Request_Log += 'cardStatus = ' + 'A' + '\n';
        CreditCardService.Request_Log += 'employeeNumber = ' + parseNull(creditCard.Card_Employee_Number__c) + '\n';
        CreditCardService.Request_Log += 'mailMethod = ' + configDefaults.Default_Delivery_Option_Code__c + '\n';
        CreditCardService.Request_Log += 'mailName = ' + configDefaults.Company_Name__c + '\n';
        CreditCardService.Request_Log += 'mailAttentionTo = ' + addressWrapper.mailAttentionTo + '\n';
        CreditCardService.Request_Log += 'mailAddress1 = ' + addressWrapper.addressLine1 + '\n';
        CreditCardService.Request_Log += 'mailAddress2 = ' + addressWrapper.addressLine2+ '\n';
        CreditCardService.Request_Log += 'mailCity = ' + addressWrapper.city + '\n';
        CreditCardService.Request_Log += 'mailState = ' + addressWrapper.state + '\n';
        CreditCardService.Request_Log += 'mailZip = ' + addressWrapper.postalCode + '\n';
        CreditCardService.Request_Log += 'maskCardFlag = ' + parseNull(configDefaults.Mask_Card_Num_On_Inquiry_Update__c) + '\n';

        //Return envelope string
        return activateCreditCardRequestEnvelopeString;
    }


    /**
     *  @description    :   This method is to build inquire credit card request.
     *
     *  @param          :   SFDC Credit Card record
     *
     *  @return         :   String
     *
     **/
    public static String getInquireCreditCardEnvelope(Credit_Card__c creditCard) {

        //String to hold the request SOAP envelope string
        String inquireCardRequestEnvelopeString = CreditCardConstants.COMDATA_REQUEST_ENVELOPE_NAMESPACE_STRING;

        //Appending Authorized Header String into request envelope
        inquireCardRequestEnvelopeString += CreditCardConstants.COMDATA_REQUEST_ENVELOPE_HEADER;
        
        //Get value for MaskCardFlag
        String valMaskCardFlag;
        if(configDefaults.Mask_Card_Num_on_Inquiry_Update__c == null || configDefaults.Mask_Card_Num_on_Inquiry_Update__c == 'N'){
            valMaskCardFlag = '';
        }else{
            valMaskCardFlag = configDefaults.Mask_Card_Num_on_Inquiry_Update__c;
        }

        //Appending required input parameters body string to the request envelope
        inquireCardRequestEnvelopeString += '<soapenv:Body>'
                                                + '<main:CardInquiryRequest>'
                                                     + '<accountCode>'+ configDefaults.Account_Code__c +'</accountCode>'
                                                     + '<customerId>'+ configDefaults.Customer_Id__c +'</customerId>'
                                                     + '<trackingNumber>' + parseNull(trackingNumberForEnvelope) + '</trackingNumber>'
                                                     + '<empNumCardNumFlag>E</empNumCardNumFlag>'
                                                     + '<empNumCardNumValue>' + parseNull(creditCard.Card_Employee_Number__c) + '</empNumCardNumValue>'
                                                     + '<maskCardFlag>' + valMaskCardFlag + '</maskCardFlag>'
                                                + '</main:CardInquiryRequest>'
                                           + '</soapenv:Body>'
                                        + '</soapenv:Envelope>';

        //Instance of Card
        CreditCardService.Request_Log += 'accountCode = ' + configDefaults.Account_Code__c + '\n';
        CreditCardService.Request_Log += 'customerId = ' + configDefaults.Customer_Id__c + '\n';
        CreditCardService.Request_Log += 'trackingNumber = ' + trackingNumberForEnvelope + '\n';
        CreditCardService.Request_Log += 'empNumCardNumFlag = ' + 'E' + '\n';
        CreditCardService.Request_Log += 'empNumCardNumValue = ' + parseNull(creditCard.Card_Employee_Number__c) + '\n';
        CreditCardService.Request_Log += 'maskCardFlag = ' + valMaskCardFlag + '\n';

        //Return Envelope String
        return inquireCardRequestEnvelopeString;
    }

    /**
     *  @description    :   This method is to build updateCard Comdata SOAP web service request envelope.
     *
     *  @param          :   SFDC Credit Card record
     *
     *  @return         :   String
     *
     **/
    public static String getUpdateCreditCardEnvelope(Credit_Card__c creditCard) {

        //Initializa Wrapper
        AttentionAddressWrapper addressWrapper = CreditCardHelper.getAddress(creditCard);
        
        //String to hold the request SOAP envelope string
        String updateCardRequestEnvelopeString = CreditCardConstants.COMDATA_REQUEST_ENVELOPE_NAMESPACE_STRING;

        //Appending Authorized Header String into request envelope
        updateCardRequestEnvelopeString += CreditCardConstants.COMDATA_REQUEST_ENVELOPE_HEADER;

        //Appending required input parameters body string to the request envelope
        updateCardRequestEnvelopeString += '<soapenv:Body>'
                                                 + '<main:UpdateCardRequest>'
                                                     + '<empNumCardNumFlag>E</empNumCardNumFlag>'
                                                     + '<empNumCardNumValue>' + parseNull(creditCard.Card_Employee_Number__c) + '</empNumCardNumValue>'
                                                     + '<cardDetails>'
                                                         + '<accountCode>'+ parseNull(configDefaults.Account_Code__c) +'</accountCode>'
                                                         + '<customerId>'+ parseNull(configDefaults.Customer_Id__c) +'</customerId>'
                                                         + '<trackingNumber>' + parseNull(trackingNumberForEnvelope) + '</trackingNumber>'
                                                         + '<cardStatus>' + parseNull(creditCard.Card_Status_Code__c) + '</cardStatus>'
                                                         + '<profileFlag>'+ parseNull(configDefaults.Card_Profile_Flag__c) +'</profileFlag>'
                                                         + '<employeeNumber>' + parseNull(creditCard.Card_Employee_Number__c) + '</employeeNumber>'
                                                    + '</cardDetails>'
                                                    + '<mailingDetails>'
                                                         + '<mailMethod>' + parseNull(configDefaults.Default_Delivery_Option_Code__c) + '</mailMethod>'
                                                         + '<mailName>' + parseNull(configDefaults.Company_Name__c) + '</mailName>'
                                                         + '<mailAttentionTo>' + addressWrapper.mailAttentionTo + '</mailAttentionTo>'
                                                         + '<mailAddress1>' + addressWrapper.addressLine1 + '</mailAddress1>'
                                                         + '<mailAddress2>' + addressWrapper.addressLine2 + '</mailAddress2>'
                                                         + '<mailCity>' + addressWrapper.city + '</mailCity>'
                                                         + '<mailState>' + addressWrapper.state + '</mailState>'
                                                         + '<mailZip>' + addressWrapper.postalCode + '</mailZip>'
                                                    + '</mailingDetails>'
                                                    + '<maskCardFlag>' + parseNull(configDefaults.Mask_Card_Num_On_Inquiry_Update__c) + '</maskCardFlag>'
                                                 + '</main:UpdateCardRequest>'
                                             + '</soapenv:Body>'
                                         + '</soapenv:Envelope>';

        //instance of Card
        CreditCardService.Request_Log += 'empNumCardNumFlag = ' + 'E' + '\n';
        CreditCardService.Request_Log += 'empNumCardNumValue = ' + parseNull(creditCard.Card_Employee_Number__c) + '\n';
        CreditCardService.Request_Log += 'accountCode = ' + configDefaults.Account_Code__c + '\n';
        CreditCardService.Request_Log += 'customerId = ' + configDefaults.Customer_Id__c + '\n';
        CreditCardService.Request_Log += 'trackingNumber = ' + trackingNumberForEnvelope + '\n';
        CreditCardService.Request_Log += 'cardStatus = ' + creditCard.Card_Status_Code__c + '\n';
        CreditCardService.Request_Log += 'profileFlag = ' + configDefaults.Card_Profile_Flag__c + '\n';
        CreditCardService.Request_Log += 'profileFlag = ' + configDefaults.Default_Card_Profile_Value__c + '\n';
        CreditCardService.Request_Log += 'employeeNumber = ' + parseNull(creditCard.Card_Employee_Number__c) + '\n';
        CreditCardService.Request_Log += 'mailMethod = ' + configDefaults.Default_Delivery_Option_Code__c + '\n';
        CreditCardService.Request_Log += 'mailName = ' + configDefaults.Company_Name__c + '\n';
        CreditCardService.Request_Log += 'mailAttentionTo = ' + addressWrapper.mailAttentionTo + '\n';
        CreditCardService.Request_Log += 'mailAddress1 = ' + addressWrapper.addressLine1 + '\n';
        CreditCardService.Request_Log += 'mailAddress2 = ' + addressWrapper.addressLine2+ '\n';
        CreditCardService.Request_Log += 'mailCity = ' + addressWrapper.city + '\n';
        CreditCardService.Request_Log += 'mailState = ' + addressWrapper.state + '\n';
        CreditCardService.Request_Log += 'mailZip = ' + creditCard.Payment_Account__r.Billing_Address_PostalCode__c + '\n';
        CreditCardService.Request_Log += 'maskCardFlag = ' + parseNull(configDefaults.Mask_Card_Num_On_Inquiry_Update__c) + '\n';

        //Return envelope string
        return updateCardRequestEnvelopeString;
    }

    /**
     *  @description    :   This method is to build inquireCardSecurityCode Comdata SOAP web service request envelope.
     *
     *  @param          :   SFDC Credit Card record
     *
     *  @return         :   String
     *
     **/
    public static String getInquireCardSecurityCodeEnvelope(Credit_Card__c creditCard) {

        //String to hold the request SOAP envelope string
        String inquireCardSecurityCodeEnvelopeString = CreditCardConstants.COMDATA_REQUEST_ENVELOPE_NAMESPACE_STRING;

        //Appending Authorized Header String into request envelope
        inquireCardSecurityCodeEnvelopeString += CreditCardConstants.COMDATA_REQUEST_ENVELOPE_HEADER;

        //String variable to hold the expiration date field string
        String expDateString = processDate(creditCard.Card_Expiration__c);

        //Appending required input parameters body string to the request envelope
        inquireCardSecurityCodeEnvelopeString += '<soapenv:Body>'
                                                    + '<main:CardSecurityCodeInquiryRequest>'
                                                         + '<accountCode>'+ parseNull(configDefaults.Account_Code__c) +'</accountCode>'
                                                         + '<customerId>'+ parseNull(configDefaults.Customer_Id__c) +'</customerId>'
                                                         + '<trackingNumber>' + parseNull(trackingNumberForEnvelope) + '</trackingNumber>'
                                                         + '<empNumCardNumFlag>E</empNumCardNumFlag>'
                                                         + '<empNumCardNumValue>' + parseNull(creditCard.Card_Employee_Number__c) + '</empNumCardNumValue>'
                                                         + '<cardExpirationDate>' + expDateString + '</cardExpirationDate>'
                                                         + '<maskCardFlag>' + parseNull(configDefaults.Mask_Card_Num_On_Inquiry_Update__c) + '</maskCardFlag>'
                                                    + '</main:CardSecurityCodeInquiryRequest>'
                                                + '</soapenv:Body>'
                                            + '</soapenv:Envelope>';

        //Instance of Card
        CreditCardService.Request_Log += 'accountCode = ' + configDefaults.Account_Code__c + '\n';
        CreditCardService.Request_Log += 'customerId = ' + configDefaults.Customer_Id__c + '\n';
        CreditCardService.Request_Log += 'trackingNumber = ' + trackingNumberForEnvelope + '\n';
        CreditCardService.Request_Log += 'empNumCardNumFlag = ' + 'E' + '\n';
        CreditCardService.Request_Log += 'empNumCardNumValue = ' + parseNull(creditCard.Card_Employee_Number__c) + '\n';
        CreditCardService.Request_Log += 'cardExpirationDate = ' + expDateString + '\n';
        CreditCardService.Request_Log += 'maskCardFlag = ' + configDefaults.Mask_Card_Num_On_Inquiry_Update__c + '\n';

        //Return Envelope String
        return inquireCardSecurityCodeEnvelopeString;
    }

    /**
     *  @description    :   This method is to build realTimeTransactionHistory Comdata SOAP web service request envelope.
     *
     *  @param          :   SFDC Credit Card Transaction record
     *
     *  @return         :   String
     *
     **/
    public static String getRealTimeTransactionHistoryEnvelope(String cardNumber, Integer noOfDays) {

        //String to hold the request SOAP envelope string
        String realTimeTransactionHistoryEnvelopeString = CreditCardConstants.COMDATA_REQUEST_ENVELOPE_NAMESPACE_STRING;

        //Appending Authorized Header String into request envelope
        realTimeTransactionHistoryEnvelopeString += CreditCardConstants.COMDATA_REQUEST_ENVELOPE_HEADER;

        //Start DTM
        DateTime endDTM = DateTime.now();
        DateTime startDTM = endDTM.addDays(-noOfDays);
        
        //Appending required input parameters body string to the request envelope
        realTimeTransactionHistoryEnvelopeString += '<soapenv:Body>'
                                                         + '<main:RtTransactionRequest>'
                                                            + '<criteria>'
                                                                 /*+ '<accountCode>MC180</accountCode>'
                                                                 + '<customerIds>'
                                                                    + '<customerId>MCREG</customerId>'
                                                                 + '</customerIds>'
                                                                 */
                                                                 + '<accountCode>'+ parseNull(configDefaults.Account_Code__c) +'</accountCode>'
                                                                 + '<customerIds>'
                                                                    + '<customerId>'+ parseNull(configDefaults.Customer_Id__c) +'</customerId>'
                                                                 + '</customerIds>'
                                                                 + '<cardNumber>' + cardNumber + '</cardNumber>'
                                                                 + '<transactionStatuses>'
                                                                 + '<transactionStatus>All</transactionStatus>'
                                                                 + '</transactionStatuses>'
                                                                 + '<sortByDateType>Transaction</sortByDateType>'
                                                                 + '<selectionDateType>Transaction</selectionDateType>'
                                                                 + '<startDate>' + formatDate(startDTM.date()) + '</startDate>'
                                                                 + '<startTime>' + formatTime(startDTM.time()) + '</startTime>'
                                                                 + '<endDate>' + formatDate(endDTM.date()) + '</endDate>'
                                                                 + '<endTime>' + formatTime(endDTM.time()) + '</endTime>'
                                                                 /*
                                                                 + '<startDate>2014-03-22</startDate>'
                                                                 + '<endDate>2014-03-31</endDate>'
                                                                 */
                                                            + '</criteria>'
                                                         + '</main:RtTransactionRequest>'
                                                     + '</soapenv:Body>'
                                                 + '</soapenv:Envelope>';

        //Return Envelope String
        return realTimeTransactionHistoryEnvelopeString;
    }

     /**
     *  @description    :   This method is to create a new OSR record
     *
     *  @param          :   Subject, Request Type, Contact Id, Origin, Priority, alertMessage, osrStatus
     *
     *  @return         :   void
     *
     **/
    public static OSR__c createOSR(String subject, Id contactId, String origin, String priority, String alertMessage, String status) {

        //Create a new record of OSR and insert it
        OSR__c oSR = new OSR__c(Alert_Summary__c = subject, Contact__c = contactId, Origin__c = origin, Priority__c = priority, Alert_Message__c = alertMessage, Status__c = status);
        insert oSR;

        //query result of Credit Card
        Credit_Card__c creditCard = [SELECT Id, Original_Request__c, Card_Requested_By__c FROM Credit_Card__c WHERE Card_Requested_By__c =: contactId];

        //Check for null
        if(creditCard != null){

            //update Credit Card
            creditCard.Original_Request__c = oSR.Id;
            update creditCard;
        }

        //return OSR's record
        return oSR;
    }

    /**
     *  @description    :   This method is to create a new OSR record
     *
     *  @param          :   Subject, Request Type, Contact Id, Credit Card Id, Origin, Priority, alertMessage, osrStatus, requestType, requestReason, merchantName, amount
     *
     *  @return         :   void
     *
     **/
    public static void createOSR(String subject, String EmpIdNumber, String origin, String priority, String alertMessage, String status, String requestType, String requestReason, String merchantName, Decimal amount) {

        //query result of Contact
        //List<Credit_Card__c> creditCards = [SELECT Id, Requested_By__c FROM Credit_Card__c WHERE Card_Number__c =: CreditCardService.Encrypt(cardNumber)];
        List<Credit_Card__c> creditCards = [SELECT Id, CardHolder_ID__c, Credit_Card_Number__c FROM Credit_Card__c WHERE Card_Employee_Number__c =: EmpIdNumber];

        //Checking size of list
        if(creditCards.size() > 0){

            //Query result of Record Type of OSR
            List<RecordType> recordTypes = [SELECT Id FROM RecordType WHERE IsActive = true AND SobjectType = 'OSR__c'
                                                AND DeveloperName =: CreditCardConstants.OSR_RECORD_TYPE_DEVELOPER_NAME_CREDIT_CARD_ALERT];

            //Check for size of Record Types
            if(recordTypes.size() > 0) {

                //Create a new record of OSR and insert it
                OSR__c oSR = new OSR__c(Alert_Summary__c = subject, Contact__c = creditCards[0].CardHolder_ID__c, Related_Card__c = creditCards[0].Id,
                                            Origin__c = origin, Priority__c = priority, Alert_Message__c = alertMessage, Status__c = status,
                                            RecordTypeId = recordTypes[0].Id, Request_Type__c = requestType, Credit_Card_Number__c = creditCards[0].Credit_Card_Number__c,
                                            Request_Reason__c = requestReason, Merchant_Name__c = merchantName, Amount__c = amount);
                insert oSR;
            }
        }
    }

    //Check for Null and if yes, then return blank
    public static String parseNull(String value) {

        //Return blank if value is null
        if(value == null)
            return '';

        //return original value
        return value;
    }
    
    //Check for Null and if yes, then return blank
    public static String truncateAddress(String value) {

        //Return blank if value is null
        if(value != null && value.length() > 30)
            return value.left(30);

        //return original value
        return value;
    }
    
    //Method for processing Date field
    public static String processDate(Date dateFieldValue) {

        //Expiration Date String
        String expireDateString = '';

        //Checking for the date field for null value
        if(dateFieldValue != null) {

            //Month String
            String monthValue;
            if(Integer.valueOf(String.valueof(dateFieldValue.month()).length()) == 2) {
                monthValue = String.valueof(dateFieldValue.month());
            } else {
                monthValue = '0' + String.valueof(dateFieldValue.month());
            }

            //Day string
            String dayValue;
            if(Integer.valueOf(String.valueof(dateFieldValue.day()).length()) == 2) {
                dayValue = String.valueof(dateFieldValue.day());
            } else {
                dayValue = '0' + String.valueof(dateFieldValue.day());
            }

            //Construct Date String
            expireDateString = String.valueOf(dateFieldValue.year()) + '-' + monthValue + '-' + dayValue;
        }

        //Return String date value
        return expireDateString;
    }

    //Method for processing Date field
    public static String formatDate(Date dateFieldValue) {

        //Expiration Date String
        String formattedDate = '';

        //Checking for the date field for null value
        if(dateFieldValue != null) {
            Integer year = dateFieldValue.year();
            Integer month = dateFieldValue.month();
            Integer day = dateFieldValue.day();

            String monthValue = month > 9 ? String.valueOf(month) : '0' + month;
            String dayValue = day > 9 ? String.valueOf(day) : '0' + day;

            //Construct Date String
            formattedDate = year + '-' + monthValue + '-' + dayValue;
        }

        //Return String date value
        return formattedDate;
    }

    //Method for processing Date field
    public static String formatTime(Time timeFieldValue) {

        //Expiration Date String
        String formattedTime = '';

        //Checking for the date field for null value
        if(timeFieldValue != null) {
            Integer hours = timeFieldValue.hour();
            Integer minutes = timeFieldValue.minute();
            Integer seconds = timeFieldValue.second();

            String hoursValue = hours > 9 ? String.valueOf(hours) : '0' + hours;
            String minuteValue = minutes > 9 ? String.valueOf(minutes) : '0' + minutes;
            String secondValue = seconds > 9 ? String.valueOf(seconds) : '0' + seconds;

            //Construct Date String
            formattedTime = hoursValue + ':' + minuteValue + ':' + secondValue;
        }

        //Return String date value
        return formattedTime;
    }

    //Method for processing Date field
    public static Date buildDate(String dateFieldValue) {

        //date components
        String[] datePair = dateFieldValue.trim().split('-');
        return Date.newInstance(Integer.valueOf(datePair[0]), Integer.valueOf(datePair[1]), Integer.valueOf(datePair[2]));
    }

    //Method for processing Date field
    public static Time buildTime(String timeFieldValue) {

         //date components
        String[] timePair = timeFieldValue.trim().split(':');
        return Time.newInstance(Integer.valueOf(timePair[0]), Integer.valueOf(timePair[1]), Integer.valueOf(timePair[2]), 0);
    }

    //Parse null
    static String paseExpirationDate(Date dateObject) {
        if(dateObject == null) return '';
        return dateObject.year() + '-' + dateObject.month() + '-' + dateObject.day();
    }
    
    //Decimal conversion to Integer
    static Integer buildInteger(Decimal decimalObject) {
        Integer retValue;
        if(decimalObject == null){
            retValue = 0;
        }else{
            retValue = decimalObject.intValue();
        }
        return retValue;
    }
    
    /**
     *  @description    :   This method if to check if the OSR is for replacement and all the address fields are populated on OSR, 
                                then, rturn the OSR address
                                else, return the Portfolio address
     * 
     *  @args           :   Credit Card Record
     * 
     *  @return         :   Address wrapper
     *
     **/
    public static AttentionAddressWrapper getAddress(Credit_Card__c creditCard) {
        
        //Initializa Wrapper
        AttentionAddressWrapper addressWrapper = new AttentionAddressWrapper();
        OSR__c oSR = new OSR__c();
        
        //Fetch the OSR data from database
        if(creditCard.Original_Request__c != null)
        	oSR = [Select Id, Request_Type__c, Address_To_Name__c, Address_Line_1__c, Address_Line_2__c, Address_City__c,
        										 Address_State__c, Address_Postal_Code__c from OSR__c where Id =: creditCard.Original_Request__c];
        
        //Check if OSR Fields are blank, then pull address from related portfolio records
        //10/23/2015 - Bhavi Sharma - Modiofied - CR-20151002-9293: getAddress method updated to pull the data from OSR only when Address Update is not request
        //12/17/2015 - Bhavi Sharma - Modified - CR-20151209-9446: Removed all the additional criteria. Now code with checl if OSR is stamped
        //and Card is being sent to Comdata first time and address data is populated on card
        if(creditCard.Original_Request__c != null
        	&& String.IsBlank(creditCard.Credit_Card_Number__c)
        	&& !String.isBlank(oSR.Address_To_Name__c)
            && !String.isBlank(oSR.Address_Line_1__c)
            && !String.isBlank(oSR.Address_City__c)
            && !String.isBlank(oSR.Address_State__c)
            && !String.isBlank(oSR.Address_Postal_Code__c)) {
        
            //Populate address from OSR
            addressWrapper.mailAttentionTo = parseNull(oSR.Address_To_Name__c);
            addressWrapper.addressLine1 = parseNull(oSR.Address_Line_1__c);
            addressWrapper.addressLine2 = parseNull(oSR.Address_Line_2__c);
            addressWrapper.city = parseNull(oSR.Address_City__c);
            addressWrapper.state = parseNull(oSR.Address_State__c);
            addressWrapper.postalCode = parseNull(oSR.Address_Postal_Code__c);
        } else  {
            
            //Check for the mail attenntion to
            String mailAttentionTo;
            if(String.IsBlank(creditCard.Payment_Account__r.Billing_Address_Attention_To__c))
                addressWrapper.mailAttentionTo =  parseNull(creditCard.Payment_Account__r.First_Name_On_Card__c) + ' ' + parseNull(creditCard.Payment_Account__r.Last_Name_On_Card__c);
            else
                addressWrapper.mailAttentionTo =  parseNull(creditCard.Payment_Account__r.Billing_Address_Attention_To__c);
            
            addressWrapper.addressLine1 = parseNull(creditCard.Payment_Account__r.Billing_Address_Line_1__c);
            addressWrapper.addressLine2 = parseNull(creditCard.Payment_Account__r.Billing_Address_Line_2__c);
            addressWrapper.city = parseNull(creditCard.Payment_Account__r.Billing_Address_City__c);
            addressWrapper.state = parseNull(creditCard.Payment_Account__r.Billing_Address_State__c);
            addressWrapper.postalCode = parseNull(creditCard.Payment_Account__r.Billing_Address_PostalCode__c);
        }
        
        return addressWrapper;
    }
    
    //AttentionAddressWrapper class
    public class AttentionAddressWrapper {
        
        //Properties
        public String mailAttentionTo;
        public String addressLine1;
        public String addressLine2;
        public String city;
        public String state;
        public String postalCode;
    }    
}