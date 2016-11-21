/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.   
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest
global with sharing class CreditCardServiceMockClass implements HttpCalloutMock {

    //get CC Default Settings instance  
    public static Credit_Card_Settings__c configDefaults = CreditCardConstants.CONFIG_DEFAULT;
	
	//Integer variable
    public static Integer methodNumber;
    
    /*Add Credit Card*/
    public static String responseAddCard = '<soapenv:Envelope xmlns:soapenv="' + configDefaults.xmlns_soapenv__c + '" xmlns:soapenc="http://schemas.xmlsoap.org/soap/encoding/" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">'
                                               + '<soapenv:Header/>'
                                               + '<soapenv:Body>'
                                                  + '<p698:AddCardResponse xmlns:p698="' + configDefaults.xmlns_main__c + '">'
                                                     + '<response>'
                                                        + '<accountCode>CR412</accountCode>'
                                                        + '<customerId>CUST2</customerId>'
                                                        + '<discretionaryData xsi:nil="true"/>'
                                                        + '<trackingNumber>'+ CreditCardHelper.trackingNumberForEnvelope +'</trackingNumber>'
                                                        + '<cardNumber>5432897623450987</cardNumber>'
                                                        + '<employeeNumber>0040</employeeNumber>'
                                                        + '<responseCode>00000</responseCode>'
                                                        + '<responseDescription>CARD ADDED</responseDescription>'
                                                     + '</response>'
                                                  + '</p698:AddCardResponse>'
                                               + '</soapenv:Body>'
                                            + '</soapenv:Envelope>';
    
    /*Deactive Card*/
    public static String responseDeactivateCard = '<soapenv:Envelope xmlns:soapenv="' + configDefaults.xmlns_soapenv__c + '" xmlns:soapenc="http://schemas.xmlsoap.org/soap/encoding/" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">'
                                                    + '<soapenv:Header/>'
                                                    + '<soapenv:Body>'
                                                        + '<p698:UpdateCardResponse xmlns:p698="' + configDefaults.xmlns_main__c + '">'
                                                            + '<response>'
                                                                + '<accountCode>CR412</accountCode>'
                                                                + '<customerId>CUST2</customerId>'
                                                                + '<discretionaryData xsi:nil="true"/>'
                                                                + '<trackingNumber>'+ CreditCardHelper.trackingNumberForEnvelope +'</trackingNumber>'
                                                                + '<cardNumber>556735XXXXXX6515</cardNumber>'
                                                                + '<employeeNumber>015</employeeNumber>'
                                                                + '<responseCode>00000</responseCode>'
                                                                + '<responseDescription>UPDATE COMPLETED</responseDescription>'
                                                            + '</response>'
                                                        + '</p698:UpdateCardResponse>'
                                                    + '</soapenv:Body>'
                                                + '</soapenv:Envelope>';
    /* Inquiry Card*/
    public static String responseInquiryCard = '<soapenv:Envelope xmlns:soapenv="' + configDefaults.xmlns_soapenv__c + '" xmlns:soapenc="http://schemas.xmlsoap.org/soap/encoding/" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">'
                                                   + '<soapenv:Header/>'
                                                   + '<soapenv:Body>'
                                                      + '<p698:CardInquiryResponse xmlns:p698="' + configDefaults.xmlns_main__c + '">'
                                                         + '<cardNumber>5567356025306085</cardNumber>'
                                                         + '<cardDetails>'
                                                            + '<accountCode>CR412</accountCode>'
                                                            + '<customerId>CUST2</customerId>'
                                                            + '<discretionaryData xsi:nil="true"/>'
                                                            + '<trackingNumber>'+ CreditCardHelper.trackingNumberForEnvelope +'</trackingNumber>'
                                                            + '<cardStatus>A</cardStatus>'
                                                            + '<profileFlag>N</profileFlag>'
                                                            + '<profileValue>000</profileValue>'
                                                            + '<profileDescription>$0.00 LIMIT</profileDescription>'
                                                            + '<cardFirstName>BHAVI</cardFirstName>'
                                                            + '<cardLastName>SHARMA</cardLastName>'
                                                            + '<driverLicenseNumber/>'
                                                            + '<driverLicenseState/>'
                                                            + '<tripNumber/>'
                                                            + '<vehicleNumber/>'
                                                            + '<employeeNumber>0006</employeeNumber>'
                                                            + '<vehicleVINNumber/>'
                                                            + '<vehicleDescription/>'
                                                            + '<vehicleLicensePlateNumber/>'
                                                            + '<registrationExpiration xsi:nil="true"/>'
                                                            + '<miscellaneous1/>'
                                                            + '<miscellaneous2/>'
                                                            + '<cardExpiration>2017-08-01</cardExpiration>'
                                                         + '</cardDetails>'
                                                         + '<amountLimits>'
                                                            + '<dailyAmountLimit>0.01</dailyAmountLimit>'
                                                            + '<dailyAmountLimitUsed>0.00</dailyAmountLimitUsed>'
                                                            + '<dailyAmountLimitHold>0.00</dailyAmountLimitHold>'
                                                            + '<dailyAmountLimitAvailable>0.01</dailyAmountLimitAvailable>'
                                                            + '<dailyTxnLimit>1</dailyTxnLimit>'
                                                            + '<dailyTxnLimitUsed>0</dailyTxnLimitUsed>'
                                                            + '<dailyTxnLimitHold>0</dailyTxnLimitHold>'
                                                            + '<dailyTxnLimitAvailable>1</dailyTxnLimitAvailable>'
                                                            + '<cycleAmountLimit>0.01</cycleAmountLimit>'
                                                            + '<cycleAmountLimitUsed>0.00</cycleAmountLimitUsed>'
                                                            + '<cycleAmountLimitHold>0.00</cycleAmountLimitHold>'
                                                            + '<cycleAmountLimitAvailable>0.01</cycleAmountLimitAvailable>'
                                                            + '<cycleTxnLimit>1</cycleTxnLimit>'
                                                            + '<cycleTxnLimitUsed>0</cycleTxnLimitUsed>'
                                                            + '<cycleTxnLimitHold>0</cycleTxnLimitHold>'
                                                            + '<cycleTxnLimitAvailable>1</cycleTxnLimitAvailable>'
                                                         + '</amountLimits>'
                                                      + '</p698:CardInquiryResponse>'
                                                   + '</soapenv:Body>'
                                                 + '</soapenv:Envelope>';


        /*Update Card*/
        public static String responseUpdateCard = '<soapenv:Envelope xmlns:soapenv="' + configDefaults.xmlns_soapenv__c + '" xmlns:soapenc="http://schemas.xmlsoap.org/soap/encoding/" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">'
                                                   + '<soapenv:Header/>'
                                                   + '<soapenv:Body>'
                                                      + '<p698:UpdateCardResponse xmlns:p698="' + configDefaults.xmlns_main__c + '">'
                                                         + '<response>'
                                                            + '<accountCode>CR412</accountCode>'
                                                            + '<customerId>CUST2</customerId>'
                                                            + '<discretionaryData xsi:nil="true"/>'
                                                            + '<trackingNumber>'+ CreditCardHelper.trackingNumberForEnvelope +'</trackingNumber>'
                                                            + '<cardNumber>556735XXXXXX6507</cardNumber>'
                                                            + '<employeeNumber>015</employeeNumber>'
                                                            + '<responseCode>00000</responseCode>'
                                                            + '<responseDescription>UPDATE COMPLETED</responseDescription>'
                                                         + '</response>'
                                                      + '</p698:UpdateCardResponse>'
                                                   + '</soapenv:Body>'
                                                + '</soapenv:Envelope>';

        /*Inquire Customer Profile Limits*/
        public static String responseInquireCustomerProfileLimits = '<soapenv:Envelope xmlns:soapenv="' + configDefaults.xmlns_soapenv__c + '" xmlns:soapenc="http://schemas.xmlsoap.org/soap/encoding/" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">'
                                                                        + '<soapenv:Header/>'
                                                                        + '<soapenv:Body>'
                                                                            + '<p698:CustomerProfileLimitInquiryResponse xmlns:p698="' + configDefaults.xmlns_main__c + '">'
                                                                                + '<responseUtil>'
                                                                                    + '<accountCode>CR412</accountCode>'
                                                                                    + '<customerId>CUST2</customerId>'
                                                                                    + '<discretionaryData xsi:nil="true"/>'
                                                                                    + '<trackingNumber>'+ CreditCardHelper.trackingNumberForEnvelope +'</trackingNumber>'
                                                                                    + '<profileID>001</profileID>'
                                                                                    + '<productCode>12345</productCode>'
                                                                                + '</responseUtil>'
                                                                                + '<profileLimits>'
                                                                                    + '<openCloseFlag/>'
                                                                                    + '<productAvailableFlag/>'
                                                                                    + '<transactionDollarLimit>0.00</transactionDollarLimit>'
                                                                                    + '<transactionQuantityLimit>0</transactionQuantityLimit>'
                                                                                    + '<dailyDollarLimit>0.00</dailyDollarLimit>'
                                                                                    + '<dailyTransactionLimit>0</dailyTransactionLimit>'
                                                                                    + '<dailyQuantityLimit>0</dailyQuantityLimit>'
                                                                                    + '<cycleDollarLimit>0.00</cycleDollarLimit>'
                                                                                    + '<cycleTransactionLimit>0</cycleTransactionLimit>'
                                                                                    + '<cycleQuantityLimit>0</cycleQuantityLimit>'
                                                                                    + '<cycleType/>'
                                                                                    + '<cycleDay/>'
                                                                                + '</profileLimits>'
                                                                                + '<responseCode>00000</responseCode>'
                                                                                + '<responseDescription>INQUIRY SUCCESSFUL</responseDescription>'
                                                                            + '</p698:CustomerProfileLimitInquiryResponse>'
                                                                        + '</soapenv:Body>'
                                                                     + '</soapenv:Envelope>';

        /*Inquire Card Security Code*/
        public static String responseInquireCardSecurityCode = '<soapenv:Envelope xmlns:soapenv="' + configDefaults.xmlns_soapenv__c + '" xmlns:soapenc="http://schemas.xmlsoap.org/soap/encoding/" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">'
                                                                    + '<soapenv:Header/>'
                                                                    + '<soapenv:Body>'
                                                                        + '<p698:CardSecurityCodeInquiryResponse xmlns:p698="' + configDefaults.xmlns_main__c + '">'
                                                                            + '<accountCode>CR412</accountCode>'
                                                                            + '<customerId>CUST2</customerId>'
                                                                            + '<discretionaryData xsi:nil="true"/>'
                                                                            + '<trackingNumber>'+ CreditCardHelper.trackingNumberForEnvelope +'</trackingNumber>'
                                                                            + '<cardNumber>556735XXXXXX6515</cardNumber>'
                                                                            + '<employeeNumber>015</employeeNumber>'
                                                                            + '<cardSecurityCode>466</cardSecurityCode>'
                                                                        + '</p698:CardSecurityCodeInquiryResponse>'
                                                                    + '</soapenv:Body>'
                                                                 + '</soapenv:Envelope>';
        /*Inquire Card Profile Limits*/
        public static String responseInquireCardProfileLimits = '<soapenv:Envelope xmlns:soapenv="' + configDefaults.xmlns_soapenv__c + '" xmlns:soapenc="http://schemas.xmlsoap.org/soap/encoding/" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">'
                                                                    + '<soapenv:Header/>'
                                                                    + '<soapenv:Body>'
                                                                        + '<p698:CardProfileLimitInquiryResponse xmlns:p698="' + configDefaults.xmlns_main__c + '">'
                                                                            + '<responseUtil>'
                                                                            + '<accountCode>CR412</accountCode>'
                                                                            + '<customerId>CUST2</customerId>'
                                                                            + '<discretionaryData xsi:nil="true"/>'
                                                                            + '<trackingNumber>'+ CreditCardHelper.trackingNumberForEnvelope +'</trackingNumber>'
                                                                            + '<productCode>65646</productCode>'
                                                                            + '</responseUtil>'
                                                                            + '<profileLimits>'
                                                                            + '<openCloseFlag/>'
                                                                            + '<productAvailableFlag/>'
                                                                            + '<transactionDollarLimit>0.00</transactionDollarLimit>'
                                                                            + '<transactionQuantityLimit>0</transactionQuantityLimit>'
                                                                            + '<dailyDollarLimit>0.00</dailyDollarLimit>'
                                                                            + '<dailyTransactionLimit>0</dailyTransactionLimit>'
                                                                            + '<dailyQuantityLimit>0</dailyQuantityLimit>'
                                                                            + '<cycleDollarLimit>0.00</cycleDollarLimit>'
                                                                            + '<cycleTransactionLimit>0</cycleTransactionLimit>'
                                                                            + '<cycleQuantityLimit>0</cycleQuantityLimit>'
                                                                            + '<cycleType/>'
                                                                            + '<cycleDay/>'
                                                                            + '</profileLimits>'
                                                                            + '<responseCode>00000</responseCode>'
                                                                            + '<responseDescription>INQUIRY SUCCESSFUL</responseDescription>'
                                                                        + '</p698:CardProfileLimitInquiryResponse>'
                                                                    + '</soapenv:Body>'
                                                                 + '</soapenv:Envelope>';


        /*Update Card Profile Limits*/
        public static String responseUpdateCardProfileLimits = '<soapenv:Envelope xmlns:soapenv="' + configDefaults.xmlns_soapenv__c + '" xmlns:soapenc="http://schemas.xmlsoap.org/soap/encoding/" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">'
                                                                    + '<soapenv:Header/>'
                                                                    + '<soapenv:Body>'
                                                                        + '<p698:CardProfileLimitUpdateResponse xmlns:p698="' + configDefaults.xmlns_main__c + '">'
                                                                            + '<responseUtil>'
                                                                            + '<accountCode>CR412</accountCode>'
                                                                            + '<customerId>CUST2</customerId>'
                                                                            + '<discretionaryData xsi:nil="true"/>'
                                                                            + '<trackingNumber>'+ CreditCardHelper.trackingNumberForEnvelope +'</trackingNumber>'
                                                                            + '<productCode>10000</productCode>'
                                                                            + '</responseUtil>'
                                                                            + '<responseCode>00000</responseCode>'
                                                                            + '<responseDescription>UPDATE COMPLETE</responseDescription>'
                                                                        + '</p698:CardProfileLimitUpdateResponse>'
                                                                    + '</soapenv:Body>'
                                                                  + '</soapenv:Envelope>';

        /*Real Time Update*/
        public static String responseRealTimeUpdate = '<soapenv:Envelope xmlns:soapenv="' + configDefaults.xmlns_soapenv__c + '" xmlns:soapenc="http://schemas.xmlsoap.org/soap/encoding/" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">'
                                                            + '<soapenv:Header/>'
                                                            + '<soapenv:Body>'
                                                                + '<p698:RtTransactionResponse xmlns:p698="' + configDefaults.xmlns_main__c + '">'
                                                                    + '<pageCount>5</pageCount>'
                                                                    + '<pageNbr>1</pageNbr>'
                                                                    + '<recordCount>1000</recordCount>'
                                                                    + '<records>'
                                                                        + '<RtTransactionRecord>'
                                                                            + '<accountCode>MC180</accountCode>'
                                                                            + '<customerId>MCREG</customerId>'
                                                                            + '<customerName>MC REGRESSION STANDARD CUST</customerName>'
                                                                            + '<corporateCode/>'
                                                                            + '<transactionDate>2012-08-01</transactionDate>'
                                                                            + '<transactionTime>10:34:52</transactionTime>'
                                                                            + '<postedDate>2012-08-01</postedDate>'
                                                                            + '<postedTime>10:34:52</postedTime>'
                                                                            + '<transactionStatus>Posted</transactionStatus>'
                                                                            + '<cardNumber>5567356025272923</cardNumber>'
                                                                            + '<cardholderName>IRIS CARD</cardholderName>'
                                                                            + '<cardExpireDate/>'
                                                                            + '<declineCode/>'
                                                                            + '<declineMessage/>'
                                                                            + '<correctiveAction/>'
                                                                            + '<promptedId/>'
                                                                            + '<mccGroup/>'
                                                                            + '<mccNumber>CDNP</mccNumber>'
                                                                            + '<mccDescription/>'
                                                                            + '<merchantName/>'
                                                                            + '<merchantAddress/>'
                                                                            + '<merchantCity/>'
                                                                            + '<merchantState/>'
                                                                            + '<merchantZip/>'
                                                                            + '<acceptLocation>FARM FRESH #141 ALTOONA PA</acceptLocation>'
                                                                            + '<preAuthAmount>1034.97</preAuthAmount>'
                                                                            + '<postedAmount>1034.97</postedAmount>'
                                                                            + '<approvalCode>1121173</approvalCode>'
                                                                            + '<reversalFlag>N</reversalFlag>'
                                                                        + '</RtTransactionRecord>'
                                                                        + '<RtTransactionRecord>'
                                                                            + '<accountCode>MC180</accountCode>'
                                                                            + '<customerId>MCREG</customerId>'
                                                                            + '<customerName>MC REGRESSION STANDARD CUST</customerName>'
                                                                            + '<corporateCode/>'
                                                                            + '<transactionDate>2012-08-01</transactionDate>'
                                                                            + '<transactionTime>10:53:30</transactionTime>'
                                                                            + '<postedDate>2012-08-01</postedDate>'
                                                                            + '<postedTime>10:53:29</postedTime>'
                                                                            + '<transactionStatus>Posted</transactionStatus>'
                                                                            + '<cardNumber>5567356025266032</cardNumber>'
                                                                            + '<cardholderName>SPARE DRIVER II</cardholderName>'
                                                                            + '<cardExpireDate>0314</cardExpireDate>'
                                                                            + '<declineCode/>'
                                                                            + '<declineMessage/>'
                                                                            + '<correctiveAction/>'
                                                                            + '<promptedId>003957</promptedId>'
                                                                            + '<mccGroup>30001</mccGroup>'
                                                                            + '<mccNumber>5541</mccNumber>'
                                                                            + '<mccDescription>GAS / SERVICE STATIONS</mccDescription>'
                                                                            + '<merchantName>SERVICE STATIONS (WITH</merchantName>'
                                                                            + '<merchantAddress>1234 MAIN STREET</merchantAddress>'
                                                                            + '<merchantCity>QUEBEC</merchantCity>'
                                                                            + '<merchantState>QC</merchantState>'
                                                                            + '<merchantZip>G1A 1A1</merchantZip>'
                                                                            + '<acceptLocation>SERVICE STATIONS (WITH QUEBEC QC</acceptLocation>'
                                                                            + '<preAuthAmount/>'
                                                                            + '<postedAmount>330302.54</postedAmount>'
                                                                            + '<approvalCode>0</approvalCode>'
                                                                            + '<reversalFlag>N</reversalFlag>'
                                                                        + '</RtTransactionRecord>'
                                                                    + '</records>'
                                                                    + '<responseCode>0</responseCode>'
                                                                    + '<responseDescription>OK</responseDescription>'
                                                                + '</p698:RtTransactionResponse>'
                                                            + '</soapenv:Body>'
                                                         + '</soapenv:Envelope>';
    
    //String to hold updateCustomerProfileLimits
    public static String responseUpdateCustomerProfileLimits = '<soapenv:Envelope xmlns:soapenv="' + configDefaults.xmlns_soapenv__c + '" xmlns:soapenc="http://schemas.xmlsoap.org/soap/encoding/" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">'
                                                                   +'<soapenv:Header/>'
                                                                   +'<soapenv:Body>'
                                                                      +'<p698:CustomerProfileLimitUpdateResponse xmlns:p698="' + configDefaults.xmlns_main__c + '">'
                                                                         +'<responseUtil>'
                                                                            +'<accountCode>CR412</accountCode>'
                                                                            +'<customerId>CUST2</customerId>'
                                                                            +'<discretionaryData xsi:nil="true"/>'
                                                                            +'<trackingNumber>'+ CreditCardHelper.trackingNumberForEnvelope +'</trackingNumber>'
                                                                            +'<profileID>002</profileID>'
                                                                            +'<productCode>10000</productCode>'
                                                                         +'</responseUtil>'
                                                                         +'<responseCode>00000</responseCode>'
                                                                         +'<responseDescription>UPDATE COMPLETE</responseDescription>'
                                                                      +'</p698:CustomerProfileLimitUpdateResponse>'
                                                                   +'</soapenv:Body>'
                                                                +'</soapenv:Envelope>';
    //String to hold error envelop
    public static String errorEnvelop = '<soapenv:Envelope xmlns:soapenv="' + configDefaults.xmlns_soapenv__c + '" xmlns:soapenc="http://schemas.xmlsoap.org/soap/encoding/" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">'
                                            +'<soapenv:Header/>'
                                                +'<soapenv:Body>'
                                                    +'<soapenv:Fault>'
                                                        +'<faultcode>exception</faultcode>'
                                                        +'<faultstring>com.comdata.fleetCredit.exception.BusinessException: 00871,UNAUTHORIZED FIELD - XTN AMOUNT     REF CUSTID: CUST2,  REF USERID: ADVISORYWS</faultstring>'
                                                        +'<detail encodingStyle="">'
                                                            +'<p974:BusinessException xmlns:p974="http://fleetCredit.comdata.com/exception/">'
                                                            +'<messageCode>99901</messageCode>'
                                                            +'<message>00871,UNAUTHORIZED FIELD - XTN AMOUNT     REF CUSTID: CUST2,  REF USERID: ADVISORYWS</message>'
                                                            +'</p974:BusinessException>'
                                                        +'</detail>'
                                                    +'</soapenv:Fault>'
                                                +'</soapenv:Body>'
                                        +'</soapenv:Envelope>';
                                        
    //String to hold error envelop
    public static String fraudErrorEnvelope = '<soapenv:Envelope xmlns:soapenv="' + configDefaults.xmlns_soapenv__c + '" xmlns:soapenc="http://schemas.xmlsoap.org/soap/encoding/" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">'
                                            +'<soapenv:Header/>'
                                                +'<soapenv:Body>'
                                                    +'<soapenv:Fault>'
                                                        +'<faultcode>exception</faultcode>'
                                                        +'<faultstring>com.comdata.fleetCredit.exception.BusinessException: 00871,UNAUTHORIZED FIELD - XTN AMOUNT     REF CUSTID: CUST2,  REF USERID: ADVISORYWS</faultstring>'
                                                        +'<detail encodingStyle="">'
                                                            +'<p974:BusinessException xmlns:p974="http://fleetCredit.comdata.com/exception/">'
                                                            +'<messageCode>99901</messageCode>'
                                                            +'<message> ' + Batch_ProcessOSRs.FRAUD_CARD_ERROR_MESSAGE + '</message>'
                                                            +'</p974:BusinessException>'
                                                        +'</detail>'
                                                    +'</soapenv:Fault>'
                                                +'</soapenv:Body>'
                                        +'</soapenv:Envelope>';
                                        
    //Variable to set real time response
    public static String setRealTimeResponse() {
        
        String resp = '<soapenv:Envelope xmlns:soapenv="' + configDefaults.xmlns_soapenv__c + '" xmlns:soapenc="http://schemas.xmlsoap.org/soap/encoding/" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">'
                        + '<soapenv:Header/>'
                        + '<soapenv:Body>'
                            + '<p698:RtTransactionResponse xmlns:p698="' + configDefaults.xmlns_main__c + '">'
                                + '<pageCount>5</pageCount>'
                                + '<pageNbr>1</pageNbr>'
                                + '<recordCount>1000</recordCount>'
                                + '<records>';
                                                      
        
        //Loop through the 500 times
        for(Integer i = 0; i < 500; i++) {
            
            resp += '<RtTransactionRecord>'
                        + '<accountCode>MC180</accountCode>'
                        + '<customerId>MCREG</customerId>'
                        + '<customerName>MC REGRESSION STANDARD CUST</customerName>'
                        + '<corporateCode/>'
                        + '<transactionDate>2012-08-01</transactionDate>'
                        + '<transactionTime>10:34:52</transactionTime>'
                        + '<postedDate>2012-08-01</postedDate>'
                        + '<postedTime>10:34:52</postedTime>'
                        + '<transactionStatus>Posted</transactionStatus>'
                        + '<cardNumber>5567356025272923</cardNumber>'
                        + '<cardholderName>IRIS CARD</cardholderName>'
                        + '<cardExpireDate/>'
                        + '<declineCode/>'
                        + '<declineMessage/>'
                        + '<correctiveAction/>'
                        + '<promptedId/>'
                        + '<mccGroup/>'
                        + '<mccNumber>CDNP</mccNumber>'
                        + '<mccDescription/>'
                        + '<merchantName/>'
                        + '<merchantAddress/>'
                        + '<merchantCity/>'
                        + '<merchantState/>'
                        + '<merchantZip/>'
                        + '<acceptLocation>FARM FRESH #141 ALTOONA PA</acceptLocation>'
                        + '<preAuthAmount>1034.97</preAuthAmount>'
                        + '<postedAmount>1034.97</postedAmount>'
                        + '<approvalCode>1121173</approvalCode>'
                        + '<reversalFlag>N</reversalFlag>'
                    + '</RtTransactionRecord>';
        }
        
        resp +=                 '</records>'
                            + '<responseCode>0</responseCode>'
                            + '<responseDescription>OK</responseDescription>'
                        + '</p698:RtTransactionResponse>'
                    + '</soapenv:Body>'
                 + '</soapenv:Envelope>';
         return resp;
    }
                                            
    // Implement this interface method
    global HTTPResponse respond(HTTPRequest req) {
    
        // Create a fake response
        HttpResponse res = new HttpResponse();
        
        //Check for response for which request
        if(methodNumber == 1) {
         
            res.setHeader('Content-Type', 'text/xml');
            res.setBody(responseDeactivateCard);
            res.setStatusCode(200);
            res.setStatus('OK');
        }else if(methodNumber == 2) {
         
            res.setHeader('Content-Type', 'text/xml');
            res.setBody(responseInquiryCard);
            res.setStatusCode(200);
            res.setStatus('OK');
        }else if(methodNumber == 3) {
         
            res.setHeader('Content-Type', 'text/xml');
            res.setBody(responseUpdateCard);
            res.setStatusCode(200);
            res.setStatus('OK');
        }else if(methodNumber == 4) {
         
            res.setHeader('Content-Type', 'text/xml');
            res.setBody(responseInquireCustomerProfileLimits);
            res.setStatusCode(200);
            res.setStatus('OK');
        }else if(methodNumber == 5) {
         
            res.setHeader('Content-Type', 'text/xml');
            res.setBody(responseInquireCardSecurityCode);
            res.setStatusCode(200);
            res.setStatus('OK');
        }else if(methodNumber == 6) {
         
            res.setHeader('Content-Type', 'text/xml');
            res.setBody(responseInquireCardProfileLimits);
            res.setStatusCode(200);
            res.setStatus('OK');
        }else if(methodNumber == 7) {
         
            res.setHeader('Content-Type', 'text/xml');
            res.setBody(responseUpdateCardProfileLimits);
            res.setStatusCode(200);
            res.setStatus('OK');
        }else if(methodNumber == 8) {
         
            res.setHeader('Content-Type', 'text/xml');
            responseRealTimeUpdate = CreditCardServiceMockClass.setRealTimeResponse();
            res.setBody(responseRealTimeUpdate);
            System.debug('Body:::::'+res.getBody());
            res.setStatusCode(200);
            res.setStatus('OK');
        }else if(methodNumber == 9) {
         
            res.setHeader('Content-Type', 'text/xml');
            res.setBody(responseAddCard);
            res.setStatusCode(200);
            res.setStatus('OK');
        }else if(methodNumber == 10) {
         
            res.setHeader('Content-Type', 'text/xml');
            res.setBody(errorEnvelop);
            res.setStatusCode(400);
            res.setStatus('Bad Request');
        }else if(methodNumber == 11) {
         
            res.setHeader('Content-Type', 'text/xml');
            res.setBody(responseUpdateCustomerProfileLimits);
            res.setStatusCode(200);
            res.setStatus('OK');
        }else if(methodNumber == 12) {
         
            res.setHeader('Content-Type', 'text/xml');
            res.setBody(fraudErrorEnvelope);
            res.setStatusCode(400);
            res.setStatus('OK');
        }
        
        return res;
    }       
}