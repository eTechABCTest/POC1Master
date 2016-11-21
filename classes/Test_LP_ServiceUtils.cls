@isTest
public class Test_LP_ServiceUtils {
	
    //LP Service Mock instance
    public static LP_ServiceMock mockService = new LP_ServiceMock();
    
    //HttpRequest instance
    static Httprequest httpReq = new Httprequest();
    
    @testSetup static void methodName() {
        //see if both the calendar users exist
        if ([SELECT Id FROM User WHERE Username = :Label.Deployment_Calendar_Username].size() == 0) {
            //create deploymentCalendarUser
            User deployCalendarUser = TestUtilities.CreateNewUser(false);
            deployCalendarUser.Username = Label.Deployment_Calendar_Username;
            insert deployCalendarUser;
        }
        if ([SELECT Id FROM User WHERE Username = :Label.Cancelled_Calendar_Username].size() == 0) {
            //create deploymentCalendarUser
            User cancelCalendarUser = TestUtilities.CreateNewUser(false);
            cancelCalendarUser.Username = Label.Cancelled_Calendar_Username;
            insert cancelCalendarUser;
        }
    }
    
    /**
     * @description: create fake LP Milestone Custom Field Values
     **/
    static LiquidPlannerWrapper.LP_Milestone_Custom_Fields createCustomFieldValues(string task_type) {
        LiquidPlannerWrapper.LP_Milestone_Custom_Fields fakeMilestoneCustomFields = new LiquidPlannerWrapper.LP_Milestone_Custom_Fields();
        fakeMilestoneCustomFields.task_type = task_type;
        return fakeMilestoneCustomFields;
    }
    
    /**
     * @description: create fake LP Milestone
     **/
    static LiquidPlannerWrapper.LP_Milestone createMilestone(string name, string task_type, integer milestoneId, integer projectId) {
        LiquidPlannerWrapper.LP_Milestone fakeMilestone = new LiquidPlannerWrapper.LP_Milestone();
        fakeMilestone.id = milestoneId; //fake LP Milestone Id
        fakeMilestone.custom_field_values = createCustomFieldValues(task_type);
        fakeMilestone.is_done = false;
        fakeMilestone.name = name;
        fakeMilestone.started_on = date.today().addDays(2);
        fakeMilestone.project_id = projectId;
        return fakeMilestone;
    }
    
    /**
     * @description: test the LP_MilestoneService.doPost() method.  This should generate an event that corresponds to the milestone in LP.
     **/
    static testMethod void lpMilestoneService_doPost() {
        //create the milestone json
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        
        //Initialize getProject mock response
        mockService.methodName = 'getProject';
        HttpService.response = mockService.respond(httpReq);
        Test.setMock(HttpCalloutMock.class, mockService);
        
        //test milestone params
        string milestoneName = 'test deploy milestone';
        string milestoneType = 'Milestone - Deployment';
        integer milestoneId = 12454;
        
        // pass the req and resp objects to the method     
        req.requestURI = '/LP_MilestoneService';  
        req.httpMethod = 'POST';
        req.requestBody = blob.valueOf(JSON.serialize(createMilestone(milestoneName, milestoneType, milestoneId, LP_ServiceMock.PROJECT_ID)));
        RestContext.request = req;
        RestContext.response = res;
        
        test.startTest();
        
        //perform http post to webservice
        LiquidPlannerWrapper.LP_Milestone result = LP_MilestoneService.doPost();
        
        test.stopTest();
        
        //verify the milestoneId was returned
        System.assertEquals(milestoneId, result.id); 
        
        //get the event that was generated for this milestone
        list<Event> milestoneEvents = [SELECT Id, External_LP_Id__c, ActivityDate FROM Event WHERE External_LP_Id__c = :string.valueOf(result.id)];
        //system.assertEquals(1, milestoneEvents.size());
        //system.assertEquals(result.started_on, milestoneEvents[0].ActivityDate);
        
        //check to see if a web service log was generated.  WSLog is only generated if there is an exception
        string errors = '';
        list<Web_Service_Log__c> wsLogs = [SELECT Id, Web_Service_Method__c, Response_Message_Log__c FROM Web_Service_Log__c];
        for (Web_Service_Log__c log : wsLogs) {
            errors += 'Method:' + log.Web_Service_Method__c + '  ErrorMsg:' + log.Response_Message_Log__c + '\r\n';
        }
        system.assertEquals('', errors);
        
        //add events to a map
        map<Id, Event> milestoneEventsMap = new map<Id, Event>(milestoneEvents.clone());
        //update event activityDate to trigger the email to eTech Dev Management
        milestoneEvents[0].ActivityDate = milestoneEvents[0].ActivityDate.addDays(2);
        
        //test sending email to dev mgr
        system.assertNotEquals(null, milestoneEventsMap);
        //list<Messaging.SendEmailResult> emailResults = LP_ServiceUtils.notifyETechDevMgr(milestoneEvents, milestoneEventsMap);
    }
    
    /**
     * @description: test the LP_ProjectService.doPost() method.  This should generate a Release that corresponds to the Project in LP.
     **/
    static testMethod void lpProjectService_doPost() {
        //create the milestone json
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        
        //create the project
        LiquidPlannerWrapper.LP_Project project = new LiquidPlannerWrapper.LP_Project();
        project.name = 'Credit Card Phase 1';
        project.id = LP_ServiceMock.PROJECT_ID;
        
        //Initialize getProjectTags mock response
        mockService.methodName = 'getProjectTags';
        HttpService.response = mockService.respond(httpReq);
        Test.setMock(HttpCalloutMock.class, mockService);
        
        // pass the req and resp objects to the method     
        req.requestURI = '/LP_ProjectService/' + LP_ServiceUtils.LP_TYPE_PROJECT;  
        req.httpMethod = 'POST';
        req.requestBody = blob.valueOf(JSON.serialize(project));
        RestContext.request = req;
        RestContext.response = res;
        
        test.startTest();
        
        //perform http post to webservice
        LiquidPlannerWrapper.LP_Project result = LP_ProjectService.doPost();
        
        test.stopTest();
        
        //verify the projectId was returned
        System.assertEquals(LP_ServiceMock.PROJECT_ID, result.id);
        
        //get the event that was generated for this milestone
        list<SFDC_Release__c> releases = [SELECT Id, Name, External_LP_Id__c FROM SFDC_Release__c WHERE External_LP_Id__c = :string.valueOf(result.id)];
        system.assertEquals(1, releases.size());
        system.assertEquals(releases[0].Name, project.name);
        
        //check to see if a web service log was generated.  WSLog is only generated if there is an exception
        string errors = '';
        list<Web_Service_Log__c> wsLogs = [SELECT Id, Web_Service_Method__c, Response_Message_Log__c FROM Web_Service_Log__c];
        for (Web_Service_Log__c log : wsLogs) {
            errors += 'Method:' + log.Web_Service_Method__c + '  ErrorMsg:' + log.Response_Message_Log__c + '\r\n';
        }
        system.assertEquals('', errors);
    }
    
    /**
     * @description: cancel a release and verify the related event milestones are removed from the deployment calendar.
     **/
    static testmethod void testCheckEventOwner() {
        //create a release with external lp id
        SFDC_Release__c release = new SFDC_Release__c(Name = 'test sf release',
                                                      Target_Release_Date__c = date.today().addDays(7),
                                                      Status__c = 'Planned',
                                                      External_LP_Id__c = '12341');
        insert release;
        
        //add events
        list<Event> evnts = new list<Event>();
        Event evt1 = new Event(StartDateTime = system.today().addDays(5),
                               EndDateTime = system.today().addDays(6),
                               Subject = 'test event 1',
                               WhatId = release.Id,
                               OwnerId = LP_ServiceUtils.deploymentCalendarId);
        evnts.add(evt1);
        Event evt2 = new Event(StartDateTime = system.today().addDays(5),
                               EndDateTime = system.today().addDays(6),
                               Subject = 'test event 2',
                               WhatId = release.Id,
                               OwnerId = LP_ServiceUtils.deploymentCalendarId);
        evnts.add(evt2);
        insert evnts;
        
        test.startTest();
        
        //update release status to cancelled
        release.Status__c = LP_ServiceUtils.RELEASE_STATUS_CANCELLED;
        update release;
        
        //get the events and verify the new owner Id
        evnts = [SELECT Id, OwnerId FROM Event WHERE Id IN :evnts];
        for (Event e : evnts) system.assertEquals(e.OwnerId, LP_ServiceUtils.cancelledCalendarId);
        
        //change status back to planned
        release.Status__c = 'Planned';
        update release;
        
        //get the events and verify the new owner Id
        evnts = [SELECT Id, OwnerId FROM Event WHERE Id IN :evnts];
        for (Event e : evnts) system.assertEquals(e.OwnerId, LP_ServiceUtils.deploymentCalendarId);
        
        test.stopTest();
    }
    
    /**
     * @description: test the email to etech dev managers when a milestone event's date changes
     **/
    static testMethod void testCreateETechDevMgrEmail() {
        //create custom setting
        Base_URL__c setting = new Base_URL__c(URL__c = 'http://www.test.com');
        insert setting;
        
        //create 2 events
        string relatedToName = 'SFDC Release 100';
        list<Event> evnts = new list<Event>();
        Event evt1 = new Event(ActivityDate = system.today().addDays(4),
                               IsAllDayEvent = true,
                               Subject = 'test event 1',
                               External_LP_Id__c = '12344',
                               OwnerId = LP_ServiceUtils.deploymentCalendarId);
        evnts.add(evt1);
        Event evt2 = new Event(ActivityDate = system.today().addDays(5),
                               IsAllDayEvent = true,
                               Subject = 'test event 2',
                               External_LP_Id__c = '12345',
                               OwnerId = LP_ServiceUtils.deploymentCalendarId);
        evnts.add(evt2);
        insert evnts;
        
        //create the email to etech dev mgmt
        //Messaging.SingleEmailMessage email = LP_ServiceUtils.createETechDevMgrEmail(evt1, evt2, relatedToName);
        //system.assertNotEquals(null, email);
    }
    
    /**
     * @description: Test the deletion of release and event records synched with LP.  Users shold not be able to delete these records unless the delete request comes from the integration user.
     **/
    static testMethod void testDeleteLPRecords() {
        //create release record
        SFDC_Release__c release = new SFDC_Release__c(Name = 'SFDC Release 100',
                                                      Target_Release_Date__c = system.today().addDays(5),
                                                      External_LP_Id__c = '12341');
        insert release;
        
        //boolean to determine if an error occurred
        boolean error = false;
        
        //attempt the deletion of a release where external lp id is populated
        try { delete release; }
        catch(exception e) { error = true; }
        system.assertEquals(true, error);
        
        //reset error to false
        error = false;
        
        //insert an Event record
        Event evt = new Event(ActivityDate = system.today().addDays(4),
                               IsAllDayEvent = true,
                               Subject = 'test event 1',
                               External_LP_Id__c = '12344',
                               OwnerId = LP_ServiceUtils.deploymentCalendarId);
        insert evt;
        
        //attempt the deletion of an event where external lp id is populated
        try { delete evt; }
        catch(exception e) { error = true; }
        system.assertEquals(true, error);
    }
}