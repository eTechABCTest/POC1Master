/**
 *	Purpose			:	Site Profile Logging functionlity
 *
 *	Created By		:	Victor Hanson
 *
 *	Created Date	:	08/25/2014
 *
 *	Current Version	:	V1.0 - Created
 **/
public class SiteProfileLogger {
	
    private static final integer MAX_REQUEST_RESPONSE_LOG_LENGTH = 32768;
    private static final integer MAX_RESPONSE_MESSAGE_LENGTH = 5000;
    
    //get the Web Service Log's Site Profile record type id
    public static Id wsLogSiteProfileRTId {
        get {
            if (wsLogSiteProfileRTId == null)
                wsLogSiteProfileRTId = Schema.SObjectType.Web_Service_Log__c.RecordTypeInfosByName.get('Site Profile').RecordTypeId;
            return wsLogSiteProfileRTId;
        }
        set;
    }
    
    //get the Web Service Log's Institution record type id
    public static Id wsLogInstitutionRTId {
        get {
            if (wsLogInstitutionRTId == null)
                wsLogInstitutionRTId = Schema.SObjectType.Web_Service_Log__c.RecordTypeInfosByName.get('Institution').RecordTypeId;
            return wsLogInstitutionRTId;
        }
        set;
    }
	
    //holds the original siteUser prior to processing
    public static SiteUser originalSiteUser {
        get {
            if (originalSiteUser == null) originalSiteUser = new SiteUser();
            return originalSiteUser;
        }
        set;
    }
    
    /**
	 * 	@description	:	This method is to create a Log record for Site Profile requests
	 *
	 *	@param			:	SiteUser
	 *
	 *	@return			:	void
	 *
	 **/
	public static void Log(SiteUser sUser){
        Site_Profile__c sProfile = sUser.Site_Profile;
        if (sProfile == null) {
		    	
		    string userId = string.valueOf(sUser.User_Id);
		    if (userId == null && sUser.Attendee != null) userId = string.valueOf(sUser.Attendee.User_Id);
		    
		    if (userId != null) {
        		list<Site_Profile__c> siteProfiles = [SELECT Id, Type__c, Status__c, Username__c FROM Site_Profile__c WHERE User_Id__c = :userId LIMIT 1];
                if (siteProfiles.size() > 0) sProfile = siteProfiles[0];
		    }
        }
        
        if (sProfile != null) { 
            //Create a webservice log record
            Web_Service_Log__c webServiceLog = new Web_Service_Log__c(RecordTypeId = wsLogSiteProfileRTId,
                                                                      Site_Profile__c = sProfile.Id,
                                                                      Web_Service_Method__c = originalSiteUser.Command,
                                                                      Request_Sent__c = system.now(),
                                                                      Response_Message_Log__c = JSON.serializePretty(sUser),
                                                                      Response_Message__c = sUser.Response,
                                                                      Requested_By__c = sUser.Modified_By,
                                                                      Request_Message_Log__c = JSON.serializePretty(originalSiteUser));
            //trim field excess+3 and add elipse (...) to show that the log value had to be trimmed
            if (webServiceLog.Response_Message_Log__c != null && webServiceLog.Response_Message_Log__c.length() > MAX_REQUEST_RESPONSE_LOG_LENGTH) {
                webServiceLog.Response_Message_Log__c = webServiceLog.Response_Message_Log__c.subString(0, (MAX_REQUEST_RESPONSE_LOG_LENGTH-3)) + '...';
            }
            
            if (webServiceLog.Request_Message_Log__c != null && webServiceLog.Request_Message_Log__c.length() > MAX_REQUEST_RESPONSE_LOG_LENGTH) {
                webServiceLog.Request_Message_Log__c = webServiceLog.Request_Message_Log__c.subString(0, (MAX_REQUEST_RESPONSE_LOG_LENGTH-3)) + '...';
            }
            
            if (webServiceLog.Response_Message__c != null && webServiceLog.Response_Message__c.length() > MAX_RESPONSE_MESSAGE_LENGTH) {
                webServiceLog.Response_Message__c = webServiceLog.Response_Message__c.subString(0, (MAX_RESPONSE_MESSAGE_LENGTH-3)) + '...';
            }
            
            //insert log
            insert webServiceLog;
        }
	}
    
    /**
	 * 	@description	:	This method is to create a Log record for Site Profile requests
	 *
	 *	@param			:	SiteUser
	 *
	 *	@return			:	void
	 *
	 **/
    public static void Log(string institutionId, string institutionJSON, string command, string result, string response){
        
        //Create a webservice log record
        Web_Service_Log__c webServiceLog = new Web_Service_Log__c(RecordTypeId = wsLogInstitutionRTId,
                                                                  Institution__c = institutionId,
                                                                  Web_Service_Method__c = command,
                                                                  Request_Sent__c = system.now(),
                                                                  Response_Message_Log__c = response,
                                                                  Response_Message__c = result,
                                                                  Request_Message_Log__c = JSON.serializePretty(JSON.deserializeUntyped(institutionJSON)));
        
        //insert log
        insert webServiceLog;
    }
}