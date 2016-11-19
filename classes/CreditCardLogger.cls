/**
 *	Purpose			:	Credit Card Infomation Logging functionlity
 *
 *	Created By		:	Bhavi Sharma
 *
 *	Created Date	:	08/15/2013
 *
 *	Current Version	:	V_1.0 - Created
 *                      V_1.1 - Modified By - Mahendra Swarnkar - 10/19/2015 - CR-20150917-9254 - Replaced the following fields to 
 * 								ensure the security of sensitive information of the records from comdata credit card record type records.
 * 								Fields to be replaced:-
								Request Message -->  Credit Card Request Message
								Request Message Log -->  Credit Card Request Message Log 
								Response Message -->  Credit Card Response Message
								Response Message Log  -->  Credit Card Response Message Log  	
 **/
public class CreditCardLogger {

	/**
	 * 	@description	:	This method is to create a Log record for web service callout
	 *
	 *	@param			:	creditCard, errorMessage, requestTime, requestMessage, responseMessage, Classname, method name
	 *
	 *	@return			:	void
	 *
	 **/
	public static void Log(Credit_Card__c creditCard, String errorMessage, DateTime requestTime, String requestMessage, String requestMessageLog,String responseMessage,
    									String webServiceClass, String webServiceMethod, String webServiceName){

		//Create a webservice log record
		Web_Service_Log__c webServiceLog = new Web_Service_Log__c();
		webServiceLog.Credit_Card__c = creditCard.Id;
		webServiceLog.Card_Vendor__c = creditCard.Card_Vendor__c;
		webServiceLog.Error_Message__c = errorMessage;
		webServiceLog.Request_Sent__c = requestTime;
        
		//Modified By - Mahendra Swarnkar - 10/19/2015 - CR-20150917-9254 
		//Starts from here
		/*
        webServiceLog.Request_Message__c = requestMessage;
		webServiceLog.Request_Message_Log__c = requestMessageLog;
		webServiceLog.Response_Message__c = responseMessage;
		*/
		webServiceLog.Credit_Card_Request_Message__c = requestMessage;
		webServiceLog.Credit_Card_Request_Message_Log__c = requestMessageLog;
		webServiceLog.Credit_Card_Response_Message__c = responseMessage;
        //Ends here
                                            
		webServiceLog.Response_Received__c = DateTime.now();
		webServiceLog.Web_Service_Class__c = webServiceClass;
		webServiceLog.Web_Service_Method__c = webServiceMethod;
		webServiceLog.Web_Service_Name__c = webServiceName;
		                                   
        //insert log
		insert webServiceLog;
	}

	/**
	 * 	@description	:	This method is to create a Log record for web service callout.
	 *
	 *	@param			:	errorMessage, requestTime, requestMessage, requestMessageLog, responseMessage, Classname, method name
	 *
	 *	@return			:	void
	 *
	 **/
	public static void Log(String errorMessage, DateTime requestTime, String requestMessage, String requestMessageLog,String responseMessage,
    									String webServiceClass, String webServiceMethod, String webServiceName){

		//Create a webservice log record
		Web_Service_Log__c webServiceLog = new Web_Service_Log__c();
		webServiceLog.Error_Message__c = errorMessage;
		webServiceLog.Request_Sent__c = requestTime;
		
		//Modified By - Mahendra Swarnkar - 10/19/2015 - CR-20150917-9254 
		//Starts from here
		/*
		webServiceLog.Request_Message__c = requestMessage;
		webServiceLog.Request_Message_Log__c = requestMessageLog;
		webServiceLog.Response_Message__c = responseMessage;
		*/
		webServiceLog.Credit_Card_Request_Message__c = requestMessage;
		webServiceLog.Credit_Card_Request_Message_Log__c = requestMessageLog;
		webServiceLog.Credit_Card_Response_Message__c = responseMessage;
		// Ends here
                                            
		webServiceLog.Response_Received__c = DateTime.now();
		webServiceLog.Web_Service_Class__c = webServiceClass;
		webServiceLog.Web_Service_Method__c = webServiceMethod;
		webServiceLog.Web_Service_Name__c = webServiceName;
		
		//insert log
		insert webServiceLog;
	}
	
	/**
	 * 	@description	:	This method is to create a Log record instance but do not insert it for web service callout
	 *
	 *	@param			:	creditCard, errorMessage, requestTime, requestMessage, responseMessage, Classname, method name
	 *
	 *	@return			:	void
	 *
	 **/
	public static Web_Service_Log__c LogInstance(Credit_Card__c creditCard, String errorMessage, DateTime requestTime, String requestMessage, String requestMessageLog,String responseMessage,
    									String webServiceClass, String webServiceMethod, String webServiceName){

		//Create a webservice log record
		Web_Service_Log__c webServiceLog = new Web_Service_Log__c();
		webServiceLog.Credit_Card__c = creditCard.Id;
		webServiceLog.Card_Vendor__c = creditCard.Card_Vendor__c;
		webServiceLog.Error_Message__c = errorMessage;
		webServiceLog.Request_Sent__c = requestTime;
		
		//Modified By - Mahendra Swarnkar - 10/19/2015 - CR-20150917-9254 
		//Starts from here
		/*
		webServiceLog.Request_Message__c = requestMessage;
		webServiceLog.Request_Message_Log__c = requestMessageLog;
		webServiceLog.Response_Message__c = responseMessage;
		*/
		webServiceLog.Credit_Card_Request_Message__c = requestMessage;
		webServiceLog.Credit_Card_Request_Message_Log__c = requestMessageLog;
		webServiceLog.Credit_Card_Response_Message__c = responseMessage;
		//Ends here
                                            
		webServiceLog.Response_Received__c = DateTime.now();
		webServiceLog.Web_Service_Class__c = webServiceClass;
		webServiceLog.Web_Service_Method__c = webServiceMethod;
		webServiceLog.Web_Service_Name__c = webServiceName;
		
		//insert log
		return webServiceLog;
	}
}