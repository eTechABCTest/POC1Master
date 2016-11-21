/**
 *  Purpose         :   All the vendor alert will be received by "CreditCardAlertService" email service. This email service is associated with this class.
 						This class is to process the Vendor Alert message and created a OSR record,
 						then this OSR record will be used for further processing.
 *
 *  Created By      :   Bhavi Sharma
 *
 *  Created Date    :   08/27/2013
 *
 *  Current Version :   V_1.0 - Created
 *						V_1.1 - 06/18/2015 - Bhavi Sharma - Modiofied - CR-20141212-8307
 *
 **/
global class CreditCardAlertService implements Messaging.InboundEmailHandler {

    /**
     *  @description    :   Parse the email body and create an instance of OSR record
     *
     *  @param          :   InboundEmail email, InboundEnvelope envelope
     *
     *  @return         :   Messaging.InboundEmailResult
     *
     **/
    global Messaging.InboundEmailResult handleInboundEmail(Messaging.InboundEmail email, Messaging.InboundEnvelope envelope) {

        //InboundEmailResult instance
        Messaging.InboundEmailResult result = new Messaging.InboundEmailresult();

        //Create a new Instance of OSR record
        OSR__c oSR = new OSR__c();

        //alert message for OSR record
	    String alertMessage = '';
		
		//Contact record - get identifying fields
	    //String cardNumber = creditCardNumber(email.plainTextBody);
        String empIdNumber = employeeIdNumber(email.plainTextBody);
        String alertType = alertType(email.subject);
        String requestType = '';
        String requestReason;
        String merchantName = merchantName(email.plainTextBody);
        Decimal amount = amount(email.plainTextBody);
	    
	    //Check for employeeNumber not null
	    //if(cardNumber != '' && cardNumber != null) {
        if(empIdNumber  != '' && empIdNumber != null) {
		 	
            String statusValue;
            if(alertType == 'Decline'){
            	
                statusValue = CreditCardConstants.OSR_STATUS_COMPLETE;
                requestType = CreditCardConstants.OSR_SUBJECT_CREATE_DECLINE_ALERT_ABC_CREDIT_CARD;
            } else {
                
                if(alertType == 'Fraud')
            		requestType = CreditCardConstants.OSR_SUBJECT_CREATE_FRAUD_ALERT_ABC_CREDIT_CARD;
            	else
            		requestType = CreditCardConstants.OSR_SUBJECT_CREATE_OTHER_ALERT_ABC_CREDIT_CARD;
            		
            	statusValue = CreditCardConstants.OSR_STATUS_NEW;
                
            }
            
            //Loop through possiable alert reasons
            for(String aR : CreditCardConstants.MAP_CREDIT_CARD_ALERT_REASON.keySet()) {
            	
            	//Check reason in email body
            	if(String.isNotBlank(email.plainTextBody) && email.plainTextBody.containsIgnoreCase(aR)) {
            		
            		//Get Request reason from map
            		requestReason = CreditCardConstants.MAP_CREDIT_CARD_ALERT_REASON.get(aR);
            		
            		break;
            	}
            }
            
			//call helper class method for create OSR record
	        CreditCardHelper.createOSR(email.subject, empIdNumber, CreditCardConstants.OSR_ORIGIN_CREATE_VENDOR_ALERT, CreditCardConstants.OSR_PRIORITY_CREATE_URGENT, 
	        									email.PlainTextBody, statusValue, requestType, requestReason, merchantName, amount);
	    }        
		else
		{
			//Create an error email to notify that an email was received but not recognized
			list<String> emailNotify = new list<string>();
			emailNotify.add('sfadmin@advisory.com');
			emailNotify.add('bennettj@advisory.com');
			string emailSender = 'CreditCardAlert';
			string emailSubject = 'Error processing credit card alert email';
			string emailMessage = 'There was an error processing an email sent to the Credit Card Alerts email service address.'+'<br/><br/>';
			emailMessage += 'Original Message:'+'<br/>';
			emailMessage += email.plainTextBody;
			Messaging.Singleemailmessage errorEmail = Util.createSingleEmail(emailNotify, 'sfadmin@advisory.com', 'CredCardAlert', emailSubject , emailMessage);
			
			boolean errorEmailResult = Util.sendSingleEmail(errorEmail);
		}
		//return Inbound Email result
        return result;
    }
	
	/**
     *  @description    :   method to parse mail body for getting Card Number
     *
     *  @param          :   String EmailBody
     *
     *  @return         :   String
     *
     **/
	//public String creditCardNumber(String body){
	//
	//	//Check email body contains Card Number and get Card Number 
	//	if(body != null && body.contains('Card Number:'))
	//		return body.subStringAfter('Card Number:').substringBefore('\n').trim();
	//		
	//	return null;
	//}
    
	/**
     *  @description    :   method to parse mail body for getting Card Employee Id
     *
     *  @param          :   String EmailBody
     *
     *  @return         :   String
     *
     **/
	public String employeeIdNumber(String body){

		//Check email body contains Employee Id and get Employee Id 
		if(body != null && body.contains('Employee ID:'))
			return body.subStringAfter('Employee ID:').substringBefore('\n').trim();
			
		return null;
	} 
    
    public string alertType(String subject){
        //Check if email Subject Contains specific keywords to indicate alert type
        string alert;
        if(subject != null && subject.contains('Fraud ')){
            alert = 'Fraud';
        }else if(subject != null && subject.contains('Decline ')){
            alert = 'Decline';
        }else{
            alert = 'Other';
        }
        return alert;
    }
    
    /**
     *  @description    :   method to parse mail body for getting Merchant Name
     *
     *  @param          :   String EmailBody
     *
     *  @return         :   String
     *
     **/
	public String merchantName(String body){

		//Check email body contains Employee Id and get Employee Id 
		if(body != null && body.contains('Merchant:'))
			return body.subStringAfter('Merchant:').substringBefore('\n').trim();
			
		return null;
	}
	
	/**
     *  @description    :   method to parse mail body for getting Merchant Name
     *
     *  @param          :   String EmailBody
     *
     *  @return         :   String
     *
     **/
	public Decimal amount(String body){

		//Check email body contains Employee Id and get Employee Id 
        if(body != null && body.contains('Amount:')) {
        	String amt = body.subStringAfter('Amount:').substringBefore('\n');
            amt = amt.replaceAll(' ', '').replaceAll(',', '').replaceAll('\\$', '');
            System.debug('amt:::::'+ amt);
            if(amt.replaceAll('\\.', '').isNumeric()) {
                return Decimal.valueOf(amt);
            }
        }
		return null;
	}
}