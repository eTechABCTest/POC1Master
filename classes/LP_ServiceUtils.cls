/**
 * 	Purpose:    Utility class used to support the LiquidPlanner REST Services
 * 
 * 	Create By:  Victor Hanson
 * 
 * 	Created Date:   05/06/2015
 * 
 * 	Revision Log:	v1.0 - (Code Added) - Victor Hanson - Created
 **/
public without sharing class LP_ServiceUtils {
    
    public static Event event { get; set; }
    public static SFDC_Release__c release { get; set; }
    public static string type { get; set; }
    public static final string EVENT_ETECH_RT_ID = Schema.SObjectType.Event.getRecordTypeInfosByName().get('eTech Dev').getRecordTypeId();
    public static final string RELEASE_ETECH_RT_ID = Schema.SObjectType.SFDC_Release__c.getRecordTypeInfosByName().get('eTech Dev').getRecordTypeId();
    public static final string SITE_USER_TYPE = 'Guest';
    public static final string MILESTONE_DEPLOYMENT = 'Milestone - Deployment';
    public static final string RELEASE_STATUS_CANCELLED = 'Cancelled';
    public static final string RELEASE_STATUS_SCHEDULED = 'Scheduled - Planned';
    public static final string LP_TYPE_PROJECT = 'projects';
    public static final string LP_TYPE_FOLDER = 'folders';
    public static final string LP_TYPE_MILESTONE = 'milestones';
    public static final string CHANGE_TYPE_DELETE = 'delete';
    public static final string COMPLETED_CHECKMARK = '✔';
    
    /**
     * 
     * @description: deployment calendar user id - this is the calendar displayed when a user clicks deployment calendar from the left sidebar.
     * 
     **/
    public static string deploymentCalendarId {
        get {
            if (deploymentCalendarId == null) {
                list<User> users = [SELECT Id FROM User WHERE Username = :Label.Deployment_Calendar_Username];
                if (users.size() > 0) deploymentCalendarId = users[0].Id;
                else throw new customException('No user was found with the username ' + Label.Deployment_Calendar_Username + ' make sure the Deployment_Calendar_Username custom label is updated.');
            }
            return deploymentCalendarId;
        }
        set;
    }
    
    /**
     * 
     * @description: cancelled calendar user id - events associated with this calendar were related to a cancelled release record.
     * 
     **/
    public static string cancelledCalendarId {
        get {
            if (cancelledCalendarId == null) {
                list<User> users = [SELECT Id FROM User WHERE Username = :Label.Cancelled_Calendar_Username];
                if (users.size() > 0) cancelledCalendarId = users[0].Id;
                else throw new customException('No user was found with the username ' + Label.Cancelled_Calendar_Username + ' make sure the Cancelled_Calendar_Username custom label is updated.');
            }
            return cancelledCalendarId;
        }
        set;
    }
    
	/**
     * @description: add/update the event based on milestone info.  Or delete the record if it's a delete from LP.
     **/
    public static void processEvent(LiquidPlannerWrapper.LP_Milestone milestone) {
        
        //see if there is an existing event
        string milestoneId = string.valueOf(milestone.id);
        list<Event> foundEvents = [SELECT Id, WhatId, WhoId, ActivityDate, IsAllDayEvent, RecordTypeId, Subject FROM Event WHERE External_LP_Id__c = :milestoneId];
        if (foundEvents.size() > 0) event = foundEvents[0];
        
        //determine if it is a delete or upsert
        if (milestone.change_type != null && milestone.change_type.equalsIgnoreCase(CHANGE_TYPE_DELETE)) {
            delete event; //delete the event
        }
        else {
            upsertEvent(milestone); //create or update the event
        }
    }
    
    /**
     * @description: add/update the Release record based on LP Project info.
     **/
    public static void processProject(LiquidPlannerWrapper.LP_Project project) {
        
        //see if there is an existing release
        string projectId = string.valueOf(project.id);
        list<SFDC_Release__c> foundReleases = [SELECT Id, External_LP_Id__c, Status__c FROM SFDC_Release__c WHERE External_LP_Id__c = :projectId OR Name = :project.Name];
        if (foundReleases.size() > 0) release = foundReleases[0];
        
        //determine if it is a delete or upsert
        if (project.change_type != null && project.change_type.equalsIgnoreCase(CHANGE_TYPE_DELETE)) {
            //remove the external lp id from the project and all related events
            if (release != null && release.External_LP_Id__c != null) {
                release.External_LP_Id__c = null;
                release.Status__c = RELEASE_STATUS_CANCELLED;
                update release;
                
                //get all events and remove the external id
                list<Event> eventsToUpdate = [SELECT id, External_LP_Id__c FROM Event WHERE WhatId = :release.Id AND External_LP_Id__c != null];
                if (eventsToUpdate.size() > 0) {
                    for (Event e : eventsToUpdate) e.External_LP_Id__c = null;
                    update eventsToUpdate;
                }
            }
        }
        else {
            upsertRelease(project); //create or update the release
        }
    }
    
    /**
     * @description: get tags for the project.  If it contains 'CreateSFRelease', create the release and sync any existing milestones.
     **/
    public static void upsertRelease(LiquidPlannerWrapper.LP_Project project) {
        //get all tags related to the project.  a specific tag must be present (CreateSFRelease) in order to create the release in SF
        set<string> tagSet = getProjectTags(project.id);
        //if the tag isn't present AND there is no release associated with this Project Id, return without processing
        if (!tagSet.contains(Label.LP_Release_Creation_Tag.toLowerCase()) && (release == null || release.Id == null)) return;
        
        if (release == null) {
            release = new SFDC_Release__c(RecordTypeId = RELEASE_ETECH_RT_ID);
        }
        
        //sync related milestones
        syncProjectMilestones(project.Id);
        
        release.External_LP_Id__c = string.valueOf(project.id);
        release.Name = project.Name;
        
        //if the status is blank or cancelled, update to scheduled
        if (string.isBlank(release.Status__c) || release.Status__c == RELEASE_STATUS_CANCELLED) release.status__c = RELEASE_STATUS_SCHEDULED;
        
        upsert release;
    }
    
    /**
     * @description: upsert the Event record in Salesforce based on the Milestone from LP.
     **/
    public static void upsertEvent(LiquidPlannerWrapper.LP_Milestone milestone) {
        if (event == null) {
            event = new Event(OwnerId = deploymentCalendarId,
                              IsAllDayEvent = true, 
                              ShowAs = 'Busy',
                              RecordTypeId = EVENT_ETECH_RT_ID);
        }
        
        //set the event.WhatId
        event.WhatId = getReleaseId(string.valueOf(milestone.parent_id));
        
        event.Title__c = ''; //clear out the title
        //if the milestone is completed, place a checkmark in the beginning of the title
        if (milestone.is_done != null && milestone.is_done) event.Title__c += COMPLETED_CHECKMARK + ' ';
        event.Title__c += milestone.Name;
        
        //determine the parent type based on fields from the milestone
        if (milestone.parent_id == milestone.project_id) type = LP_TYPE_PROJECT;
        else type = LP_TYPE_FOLDER;
        //get the project from LP
        LiquidPlannerWrapper.LP_Project project = getProject(milestone.project_id);
        
        //populate the project name
        if (event.WhatId == null) {
            if (project != null) event.Title__c += ' : ' + project.name;
        }
        
        system.debug('@@event.ActivityDate:' + event.ActivityDate + '  milestone.started_on:' + milestone.started_on);
        if (event.id != null && event.ActivityDate != milestone.started_on)
        	notifyETechDevMgr(milestone, project);
        
        event.External_LP_Id__c = string.valueOf(milestone.id);
        event.Description = milestone.Description;
        event.ActivityDate = milestone.started_on;
        event.Event_Type__c = milestone.custom_field_values.task_type;
        event.Subject = event.Title__c;
        if (milestone.custom_field_values.task_type == null) event.Event_Type__c = 'Other';
        
        //if event type is milestone - deployment, change show time as to OOO
        if (event.Event_Type__c == MILESTONE_DEPLOYMENT) event.ShowAs = 'OutOfOffice';
        upsert event;
    }
    
    /**
     * @description: get the release Id based on the related project id.
     **/
    private static Id getReleaseId(string projectId) {
        Id whatId;
        if (projectId != null) {
            list<SFDC_Release__c> releases = [SELECT Id FROM SFDC_Release__c WHERE External_LP_Id__c = :projectId];
            if (releases.size() > 0) whatId = releases[0].Id;
        }
        return whatId;
    }
    
    /**
	 * 	@description	:	This method is to create a Log record for REST requests
	 *
	 *	@param			:	Id, string, string, exception
	 *
	 *	@return			:	void
	 *
	 **/
    public static void Log(integer liquidPlannerId, string request, string response, Exception ex){
        string errorMsg = 'Cause/Type:' + ex.getCause() + '/' + ex.getTypeName() + '\r\n'
            			+ 'LineNumber:' + ex.getLineNumber() + '\r\n'
            			+ 'Message:' + ex.getMessage() + '\r\n'
            			+ 'StackTraceString:' + ex.getStackTraceString() + '\r\n\r\n';
        //Create a webservice log record
        Web_Service_Log__c webServiceLog = new Web_Service_Log__c(RecordTypeId = Schema.SObjectType.Web_Service_Log__c.RecordTypeInfosByName.get('Site Profile').RecordTypeId,
                                                                  External_Id__c = string.valueOf(liquidPlannerId),
                                                                  Web_Service_Method__c = 'upsertEvent',
                                                                  Request_Sent__c = system.now(),
                                                                  Request_Message_Log__c = request,
                                                                  Response_Message_Log__c = errorMsg + response,
                                                                  Response_Message__c = 'Error');
        
        //insert log
        insert webServiceLog;
    }
    
    /**
     * @description: Send email notification to the eTech Dev Managers if an event that is related to an LP milestone has the date updated.
     * 
     * @params: list<Event>, map<Id, Event>
     * 
     * @return: void
     **/
    public static list<Messaging.SendEmailResult> notifyETechDevMgr(LiquidPlannerWrapper.LP_Milestone milestone, LiquidPlannerWrapper.LP_Project project) {
        list<Messaging.SendEmailResult> emailResults;
        list<Messaging.SingleEmailMessage> emails = new list<Messaging.SingleEmailMessage>();
        
        // only send milestone email if recordType is etech dev, and External LP Id is populated, and IsAllDayEvent=true
        if (event.RecordTypeId == EVENT_ETECH_RT_ID
            && event.Id != null) 
        {
        	string relatedToName = project.name;
            emails.add(createETechDevMgrEmail(milestone, project));
        }
        
        if (emails.size() > 0) {
            //send emails
			emailResults = Messaging.sendEmail(emails, false);
            for (Messaging.SendEmailResult result : emailResults) {
                if (!result.success) {
                    for (Messaging.SendEmailError e : result.getErrors())
                        throw new customException('Error sending email:' + e.message);
                }
            }
        }
        return emailResults;
    }
    
    /**
     * @description: create email to that will be sent to etech dev managers distribution list, notifying them of date updates for milestone events.
     **/
    public static Messaging.SingleEmailMessage createETechDevMgrEmail(LiquidPlannerWrapper.LP_Milestone milestone, LiquidPlannerWrapper.LP_Project project) {
        Messaging.SingleEmailMessage email;
        string delimiter = ' : ';
        
        //order of event / project name (ie: <<Project Name>> : <<Milestone Name>>)
        string fullEventTitle = project.name + delimiter + milestone.name;
        
        //get the emailTemplate
        EmailTemplate template = [SELECT Id, Body, htmlValue FROM EmailTemplate WHERE Name = :Label.Milestone_Date_Changed_Email_Template_Name];
        //createEmail(String toAddress, String subject, String body, String htmlBody)
        email = EmailHandler.createEmail(etechDevManagerEmails, 
                                         'Milestone Date Updated - ' + fullEventTitle, 
                                         getMilestoneEmailBody(template.Body, milestone, project, event.ActivityDate), 
                                         getMilestoneEmailBody(template.htmlValue, milestone, project, event.ActivityDate), 
                                         false);
        return email;
    }
    
    /**
     * @description: use a list of strings to customize the email body.
     **/
    public static string getMilestoneEmailBody(string bodyText, LiquidPlannerWrapper.LP_Milestone milestone, LiquidPlannerWrapper.LP_Project project, Date oldActivityDate) {
        string projectInfo, releaseId;
        if (event.WhatId == null && project.id != null) {
            string projectId = string.valueOf(project.id);
            list<SFDC_Release__c> releases = [SELECT Id FROM SFDC_Release__c WHERE External_LP_Id__c = :projectId LIMIT 1];
            if (releases.size() > 0) releaseId = releases[0].Id;
        }
        else if (event.WhatId != null) releaseId = event.WhatId;
        
        if (releaseId != null) {
            projectInfo = '<a href="' + baseURL + '/' + releaseId + '">' + project.name + '</a>';
        }
        else {
            projectInfo = project.name;
        }
        list<string> mailMergeList = new list<string> { baseURL + '/' + event.Id, 		//{0}
            											event.Subject, 					//{1}
            											Create_LP_URL(string.valueOf(milestone.id)), 	//{2}
            											milestone.started_on.format(), 	//{3}
            											oldActivityDate.format(), 		//{4}
            											projectInfo, 	//{5}
            											Create_LP_URL(string.valueOf(project.id)) 		//{6}
            										  };
        string retVal = string.format(bodyText, mailMergeList);
        return retVal;
    }
    
    /**
     * @description: returns the liquid planner custom settings - api url and credentials
     **/
    public static Liquid_Planner_Settings__c liquidPlannerSettings {
        get {
            if (liquidPlannerSettings == null) liquidPlannerSettings = Liquid_Planner_Settings__c.getInstance();
            return liquidPlannerSettings;
        }
        set;
    }
    
    /**
     * @description: return a LP Project
     **/
    public static LiquidPlannerWrapper.LP_Project getProject(integer LP_ID) {
        LiquidPlannerWrapper.LP_Project project;
        if (project == null) {
            HttpResponse res = doGet('/workspaces/' + Label.Workspace_Id + '/' + LP_TYPE_PROJECT + '/' + LP_ID);
            system.debug('@@@res.getBody():' + res.getBody());
            project = (LiquidPlannerWrapper.LP_Project) JSON.deserialize(res.getBody(), LiquidPlannerWrapper.LP_Project.class);
        }
        return project;
    }
    
    /**
     * @description: return a set of tags related to the lp project
     **/
    public static set<string> getProjectTags(integer LP_ID) {
        set<string> projTags = new set<string>();
        HttpResponse res = doGet('/workspaces/' + Label.Workspace_Id + '/' + type + '/' + LP_ID + '/tags');
        list<LiquidPlannerWrapper.LP_Tag> tags = (list<LiquidPlannerWrapper.LP_Tag>) JSON.deserialize(res.getBody(), list<LiquidPlannerWrapper.LP_Tag>.class);
        for (LiquidPlannerWrapper.LP_Tag tag : tags) projTags.add(tag.text.toLowerCase());
        return projTags;
    }
    
    /**
     * @description: synchronize milestones related to the lp project
     **/
    @future(callout=true)
    public static void syncProjectMilestones(integer LP_ID) {
        HttpResponse res = doGet('/workspaces/' + Label.Workspace_Id + '/' + LP_TYPE_MILESTONE + '?filter[]=parent_id=' + LP_ID);
        list<LiquidPlannerWrapper.LP_Milestone> milestones = (list<LiquidPlannerWrapper.LP_Milestone>) JSON.deserialize(res.getBody().replaceAll('"Task Type":', '"task_type":'), list<LiquidPlannerWrapper.LP_Milestone>.class);
        
        //skip this portion of the code if within a unit test that is testing project tags
        if (test.isRunningTest() && Test_LP_ServiceUtils.mockService.MethodName == 'getProjectTags') return;
        
        for (LiquidPlannerWrapper.LP_Milestone milestone : milestones) {
            //process the milestone
            LP_ServiceUtils.processEvent(milestone);
        }
    }
    
    // Return an HttpRequest with its HTTP method, URL (relative to LP URL), and Basic Auth header initialized.
    public static HttpRequest createRequest(String method, String url) {
        string LP_EMAIL = liquidPlannerSettings.Username__c;
        string LP_PASS = liquidPlannerSettings.Password__c;
        
        HTTPRequest req = new HTTPRequest();
        req.setEndpoint(liquidPlannerSettings.API_URL__c + '/api' + url);
        Blob headerValue = Blob.valueOf(LP_EMAIL + ':' + LP_PASS);
        // set the content-type
        req.setHeader('Content-Type', 'application/json');
        String authorizationHeader = 'BASIC ' + EncodingUtil.base64Encode(headerValue);
        req.setHeader('Authorization', authorizationHeader);
        system.debug('@@:' + req.getHeader('Authorization') + '   endpointURL:' + req.getEndpoint());
        req.setMethod(method);
        return req;
    }
    
    // Perform a GET request to url, returning the HTTPResponse
    public static HttpResponse doGet(String url) {
        HTTPRequest req = createRequest('GET', url);
        HTTPResponse res = new Http().send(req);
        return res;
    }
    
    /**
     * @description: returns liquid planner url to the given item
     **/
    public static String Create_LP_URL(string item_id) {
		String url = liquidPlannerSettings.API_URL__c + '/space/' + Label.Workspace_Id + '/projects/show/' + item_id;
		return url;
	}
    
    public static string baseURL {
        get {
            if (baseURL == null) {
                Base_URL__c setting = Base_URL__c.getInstance();
                baseURL = setting.URL__c;
                if (baseURL.lastIndexOf('/') == baseURL.length()-1) baseURL = baseURL.substring(0, baseURL.length()-1);
            }
            return baseURL;
        }
        set;
    }
    
    /**
     * @description: if the external lp id is popualted and user type is not 'guest', throw an error
     **/
    public static void validateDelete(list<event> evnts) {
        for (Event e : evnts) {
            if (string.isNotBlank(e.External_LP_Id__c) && !UserInfo.getUserType().equalsIgnoreCase(SITE_USER_TYPE)) {
                e.addError('Cannot delete record where External LP Id is populated.  Delete the record directly in Liquid Planner, which will also delete the record in Salesforce.');
            }
        }
    }
    
    /**
     * @description: Query for Deployment milestones.  If one is found for the Release, it will update the Release's Target Release Date.
     **/
    public static void checkTargetReleaseDate(list<event> evnts, map<Id, Event> oldEvntsMap) {
        list<SFDC_Release__c> releasesToUpdate = new list<SFDC_Release__c>();
        set<Id> releaseIds = new set<Id>();
        if (trigger.isDelete) evnts = oldEvntsMap.values();
        for (Event evnt : evnts) {
            if (evnt.External_LP_Id__c != null 
             && evnt.Event_Type__c != null) 
            {
                //get the old event
                Event oldEvnt;
                if (oldEvntsMap != null) oldEvnt = oldEvntsMap.get(evnt.Id);
                if (evnt.WhatId != null && (evnt.Event_Type__c.equalsIgnoreCase(MILESTONE_DEPLOYMENT) || oldEvnt != null && oldEvnt.Event_Type__c.equalsIgnoreCase(MILESTONE_DEPLOYMENT))
                    && (trigger.isDelete || oldEvnt == null || oldEvnt.WhatId == null && evnt.WhatId != null || oldEvnt.Title__c != evnt.Title__c
                                            || oldEvnt.ActivityDate != evnt.ActivityDate || oldEvnt.Event_Type__c != evnt.Event_Type__c || oldEvnt.WhatId != evnt.WhatId) ) 
                {
                    releaseIds.add(evnt.WhatId);
                    //if the whatId was updated, add both to the list
                    if (oldEvnt != null && oldEvnt.WhatId != evnt.WhatId) {
                        releaseIds.add(oldEvnt.WhatId);
                    }
                }
                
            }
        }
        
        list<SFDC_Release__c> releases = [SELECT Id, Target_Release_Date__c, 
                                          (SELECT Id, Title__c, ActivityDate FROM Events 
                                           WHERE Event_Type__c = :MILESTONE_DEPLOYMENT ORDER BY ActivityDate ASC)
                                          FROM SFDC_Release__c WHERE Id IN :releaseIds];
        for (SFDC_Release__c r : releases) {
            r.Target_Release_Date__c = null;
            
            for (Event e : r.Events) {
                r.Target_Release_Date__c = e.ActivityDate;
                
                if (e.Title__c.indexOf(COMPLETED_CHECKMARK) == -1) {
                    r.Target_Release_Date__c = e.ActivityDate;
                    break;
                }
            }
            releasesToUpdate.add(r);
        }
        
        if (releasesToUpdate.size() > 0) update releasesToUpdate;
    }
    
    /**
     * @description: if the external lp id is popualted and user type is not 'guest', throw an error
     **/
    public static void validateDelete(list<SFDC_Release__c> releases) {
        for (SFDC_Release__c r : releases) {
            if (string.isNotBlank(r.External_LP_Id__c) && !UserInfo.getUserType().equalsIgnoreCase(SITE_USER_TYPE)) {
                r.addError('Cannot delete record where External LP Id is populated.  Delete the record directly in Liquid Planner, which will then allow you to delete the record in Salesforce.');
            }
        }
    }
    
    /**
     * @description: return a list of email addresses for users that are part of the eTech_Dev_Management public group
     **/
    private static list<string> etechDevManagerEmails {
        get {
            if (etechDevManagerEmails == null) {
                etechDevManagerEmails = new list<string>();
                Group etechDevMgmtGroup = [SELECT Id, (SELECT UserOrGroupId FROM GroupMembers) FROM Group WHERE DeveloperName = :Label.eTech_Dev_Milestone_Notification_Name LIMIT 1];
                set<Id> groupUserIds = new set<Id>();
                for (GroupMember gm : etechDevMgmtGroup.GroupMembers) groupUserIds.add(gm.UserOrGroupId);
                list<User> users = [SELECT Id, Email FROM User WHERE Id IN :groupUserIds];
                for (User u : users) etechDevManagerEmails.add(u.Email);
            }
            return etechDevManagerEmails;
        }
        set;
    }
    
    /**
     * @description: If the release status changes to cancelled, remove events from the deployment calendar
     **/
    public static void checkEventOwner(list<SFDC_Release__c> newReleases, map<Id, SFDC_Release__c> oldReleaseMap) {
        map<Id, string> relIdsToCalendarId = new map<Id, string>();
        //get set of release ids that changed status to Cancelled
        for (SFDC_Release__c rel : newReleases) {
            SFDC_Release__c oldRel;
            if (oldReleaseMap != null) oldRel = oldReleaseMap.get(rel.Id);
            if (rel.Status__c == RELEASE_STATUS_CANCELLED && rel.Status__c != oldRel.Status__c) 
            {//if the status changed to Cancelled, send the events to a different calendar so they are no longer visible in deployment calendar
                relIdsToCalendarId.put(rel.Id, cancelledCalendarId);
            }
            else if (oldRel.Status__c == RELEASE_STATUS_CANCELLED && rel.Status__c != oldRel.Status__c) 
            {//if the status changed from Cancelled back to a different status, add the events back to the deployment calendar
                relIdsToCalendarId.put(rel.Id, deploymentCalendarId);
            }
        }
        
        //get all events related to the updated releases
        if (relIdsToCalendarId.size() > 0) {
            list<Event> evntsToUpdate = [SELECT Id, WhatId, OwnerId, IsAllDayEvent, RecordTypeId FROM Event WHERE WhatId IN :relIdsToCalendarId.keySet()];
            for (Event evnt : evntsToUpdate) {
                evnt.OwnerId = relIdsToCalendarId.get(evnt.WhatId);
            }
            update evntsToUpdate;
        }
    }
    
}