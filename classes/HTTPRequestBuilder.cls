/**
 *  Description     :   This class is to Create a HTTP request
 *
 *  Created By      :	Bhavi Sharma
 *
 *  Created Date    :   08/23/2013
 *
 *  Revision Logs   :   V_1.0 - Created
 *
**/
public with sharing class HTTPRequestBuilder {

    //Method is to get serialize HTTPRequest
    public static HttpRequest CreateRequest(String endPoint, String method, String soapAction, String body) {

        //Load custom setting
		Credit_Card_Settings__c configDefaults = CreditCardConstants.CONFIG_DEFAULT;

        //Http Request Object
        HttpRequest request = new HttpRequest();
        request.setEndpoint(configDefaults.Endpoint__c);
        request.setMethod(CreditCardConstants.REQUEST_TYPE_POST);
        request.setHeader('SOAPAction', soapAction);
        request.setHeader('Content-Type', 'text/xml;charset=UTF-8');
        request.setBody(body);
        request.setTimeout(120000);

        System.debug('request message is: '+ request.getBody());

        return request;
    }
}