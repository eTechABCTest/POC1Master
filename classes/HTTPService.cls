/**
 *  Description     :   This class is to make ths webservice callout.
 *
 *  Created By      :   Bhavi Sharma
 *
 *  Created Date    :   08/23/2013
 *
 *  Revision Logs   :   V1.0 - Created
 *
**/
public with sharing class HTTPService {
	
	//HttpResponse instance
	public static HttpResponse response;
	
	//method to Make callout
    public static HttpResponse send(HttpRequest request) {

        //Create a HTTP instance and do callout
        Http http = new Http();
        
        //Check for Test is not running
        if(!Test.isRunningTest())
        	response = http.send(request);
        
        return response;
    }
}