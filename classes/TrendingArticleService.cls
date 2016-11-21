/**
 *	Purpose			:	Service class for TrendingArticle
 * 
 * 	Created By		:	Bhavi Sharma
 * 
 * 	Created Date	:	09/11/2014
 * 
 * 	Revision Logs	:	V_1.0 - Created
 *
 **/ 
public with sharing class TrendingArticleService {
	
	/**
	 *	@description	:	This method is to hit the WebTrends endpoint and Get the Measures
	 *
	 *	@args			:	Endpoint URL
	 *
	 *	@return			:	HTTPResponse
	 *
	 **/
	public static HttpResponse GetTrends(String endPointURL) {
		
		//Get Trending Intranet Setting
        Map<String, Intranet_Settings__c> mapTrendingIntranetSettings = Intranet_Settings__c.getAll();
        
        //Create a HttpRequest
		HttpRequest req = new HttpRequest();
		req.setEndpoint(endPointURL);
		req.setMethod('GET');
		
		// Specify the required user name and password to access the endpoint
		String username = mapTrendingIntranetSettings.get(TrendingArticleConstants.WEBTRENDS_USER).Value__c;
		String password = mapTrendingIntranetSettings.get(TrendingArticleConstants.WEBTRENDS_PW).Value__c;
		
		//Authorization
		Blob headerValue = Blob.valueOf(username + ':' + password);
		String authorizationHeader = 'BASIC ' + EncodingUtil.base64Encode(headerValue);
		req.setHeader('Authorization', authorizationHeader);
		
		//Request
		Http http = new Http();
		HTTPResponse res = http.send(req);
		return res;
	}
	
	/**
	 * 	@description	:	This method is to hit the Endpoint URL
	 * 
	 * 	@args			:	
	 * 
	 * 	@return			:
	 * 
	 **/
	public static HttpResponse SendRequest(String endPointURL, String requestEnvelope) {
		
		//Create a HttpRequest
		HttpRequest req = new HttpRequest();
		req.setEndpoint(endPointURL);
		req.setMethod('POST');
        req.setHeader('Content-Type', 'text/xml;charset=UTF-8');
        req.setHeader('SOAPAction', 'http://tempuri.org/GetItemDetails');
		
		//Set Body
		req.setBody(requestEnvelope);
		
		//Request
		Http http = new Http();
		HTTPResponse res = http.send(req);
		return res;
	}
}