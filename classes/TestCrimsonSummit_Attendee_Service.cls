@isTest
private class TestCrimsonSummit_Attendee_Service {
    private static Registration__c CreateRegistration(boolean CreateAndInsert) {
        // create a new contact
        Contact newContact = testUtilities.CreateNewContact(true);
        Registration__c registration = CreateRegistration(newContact.Id, CreateAndInsert);
        return registration;
    }
    
    private static Registration__c CreateRegistration(Id contactId, boolean CreateAndInsert) {
        // create the meeting
        Meeting__c meeting = CreateMeeting(true);
        // create the registration
        Registration__c registration = CreateRegistration(meeting.Id, contactId, CreateAndInsert);
        
        return registration;
    }
    
    private static Registration__c CreateRegistration(Id MeetingId, Id contactId, boolean CreateAndInsert) {
        // create the registration
        Registration__c registration = new Registration__c();
        registration.Contact__c = contactId;
        registration.Meeting__c = MeetingId;
        registration.Status__c = 'Registered';
        if (CreateAndInsert) insert registration;
        
        return registration;
    }
    
    private static Meeting__c CreateMeeting(boolean CreateAndInsert) {
        // create the meeting
        Meeting__c meeting = new Meeting__c();
        meeting.DateTime__c = system.now();
        meeting.Type__c = 'Onsite';
        meeting.Name = 'Test';
        if (CreateAndInsert) insert meeting;
        return meeting;
    }
    
    static testmethod void testGet() {
        // create a new registration
        Registration__c registration0 = CreateRegistration(true);
        // create a child meeting from the one created above
        Meeting__c childMeeting1 = CreateMeeting(false);
        childMeeting1.Parent_Meeting__c = registration0.Meeting__c;
        insert childMeeting1;
        
        Meeting__c childMeeting2 = CreateMeeting(false);
        childMeeting2.Parent_Meeting__c = childMeeting1.Id;
        childMeeting2.Display_On_Badge__c = True;
        insert childMeeting2;
        
        Registration__c registration1 = CreateRegistration(childMeeting1.Id, registration0.Contact__c, true);
        Registration__c registration2 = CreateRegistration(childMeeting2.Id, registration0.Contact__c, true);
        
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
 
        req.requestURI = '/services/apexrest/Attendee/Test';
        RestContext.request = req;
        RestContext.response = res;
        
        test.startTest();
        List<CrimsonSummit_Attendee_Service.Attendee> result = CrimsonSummit_Attendee_Service.getAll();
        test.stopTest();

        system.assertEquals(1, result.size());
    }
    
    static testmethod void testGet2() {
        // create a new registration
        Registration__c registration0 = CreateRegistration(true);
        // create a child meeting from the one created above
        Meeting__c childMeeting1 = CreateMeeting(false);
        childMeeting1.Parent_Meeting__c = registration0.Meeting__c;
        childMeeting1.Location__c = 'Location 1';
        insert childMeeting1;
        
        Meeting__c childMeeting2 = CreateMeeting(false);
        childMeeting2.Parent_Meeting__c = childMeeting1.Id;
        childMeeting2.Display_On_Badge__c = True;
        childMeeting2.Location__c = 'Location 2';
        insert childMeeting2;
        
        Registration__c registration1 = CreateRegistration(childMeeting1.Id, registration0.Contact__c, true);
        Registration__c registration2 = CreateRegistration(childMeeting2.Id, registration0.Contact__c, true);
        registration1.Speaker_Note__c = 'Speaker Note 1';
        registration2.Speaker_Note__c = 'Speaker Note 2';
        
        Contact c = [SELECT Suffix__c FROM Contact WHERE ID= :registration1.Contact__c];
        c.Suffix__c = 'S';
        UPDATE c;
        
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
 
        req.requestURI = '/services/apexrest/Attendee/Test';
        RestContext.request = req;
        RestContext.response = res;
        
        test.startTest();
        List<CrimsonSummit_Attendee_Service.Attendee> result = CrimsonSummit_Attendee_Service.getAll();
        test.stopTest();

        system.assertEquals(1, result.size());
    }
}