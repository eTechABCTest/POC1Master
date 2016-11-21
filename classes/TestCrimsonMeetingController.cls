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
private class TestCrimsonMeetingController {
/**
    Purpose         :   Test class for CrimsonMeeting and CrimsonMeetingController classes
                
    Created By      :   
    
    Created Date    :   
    
    Revision Log    :   v1.0 - Created
						v2.0 - 06/13/2016 - Abhinav Sharma - CR-20150202-8633

	Coverage Log	:	v1.0 - CrimsonMeeting - 73%, CrimsonMeetingController - 0%
						v2.0 - CrimsonMeeting - 97%, CrimsonMeetingController - 100%
**/
    public static Registration__c CreateRegistration(boolean CreateAndInsert) {
        
        // create a new contact
        Contact newContact = testUtilities.CreateNewContact(true);
        Registration__c registration = CreateRegistration(newContact.Id, CreateAndInsert);
        return registration;
    }
    
    public static Registration__c CreateRegistration(Id contactId, boolean CreateAndInsert) {
        
        // create the meeting
        Meeting__c meeting = CreateMeeting(true);
        
        // create the registration
        Registration__c registration = CreateRegistration(meeting.Id, contactId, CreateAndInsert);
        
        return registration;
    }
    
    public static Registration__c CreateRegistration(Id MeetingId, Id contactId, boolean CreateAndInsert) {
        
        // create the registration
        Registration__c registration = new Registration__c();
        registration.Contact__c = contactId;
        registration.Meeting__c = MeetingId;
        registration.Status__c = 'Scheduled';
        
        if (CreateAndInsert) insert registration;
        
        return registration;
    }
    
    public static Meeting__c CreateMeeting(boolean CreateAndInsert) {
        
        // create the meeting
        Meeting__c meeting = new Meeting__c();
        meeting.DateTime__c = system.now();
        meeting.Type__c = 'Onsite';
        
        if (CreateAndInsert) insert meeting;
        return meeting;
    }
    
    public static String EncryptString(String origData) {
        blob blobData = blob.valueOf(origData);
        blob encryptedBlob = Crypto.encryptWithManagedIV('AES256', CrimsonMeeting.KEY, blobData);
        String encryptedString = EncodingUtil.base64Encode(encryptedBlob);
        return encryptedString;
    }
    
    //Modified by - Abhinav Sharma - CR-20150202-8633 - To refactor the existing code
    /**
     * @description : Test method to check out for various use cases associated with the decryption functionality of CrimsonMeeting class.
     * 
    **/
    static testMethod void testDecryption() {
    	
    	//Bypass Dupeblocker
        Util.IsTest(true);
        
        //Bypassing Triggers so then test data can be created easily
        Util.byPassAllTriggers = true;
        
        //Flag for triggers: this is just a test, don't do crazy things.
        Util.isTesting = true;
        
        // create a new registration
        Registration__c registration = CreateRegistration(true);
        List<Registration__c> registrations = [SELECT Id FROM Registration__c];
        System.assert(registrations != null);
        system.assertEquals(1, registrations.size());
        
        // create our encrypted string
        String requestString = '{"Command":"FindRegistrations","RegistrationId":"' + registration.Id + '"}';
        String encryptedString = EncryptString(requestString);
        
        //Start test from here
        Test.startTest();
        
        // instantiate a new crimsonMeeting object
        CrimsonMeeting cMeeting = new CrimsonMeeting(encryptedString);
        
        //Asserting for the results
        system.assertEquals('FindRegistrations', cMeeting.mWrapper.Command);
        system.assertNotEquals(Null, cMeeting.ToEncryptedString());
        
        // decrypt the response
        blob encryptedBlob = EncodingUtil.base64Decode(cMeeting.ToEncryptedString());
        String decryptedResponse = CrimsonMeeting.Decrypt(encryptedBlob);
        
        //Asserting for the results
        system.debug('@@decryptedResponse:' + decryptedResponse);
        system.assertEquals(true, decryptedResponse.contains('Success'));
        
        //Stop test here
        Test.stopTest();
    }
    
    //Modified by - Abhinav Sharma - CR-20150202-8633 - To refactor the existing code
    /**
     * @description : Test method to check out for various use cases associated with the find registrations for registration Id based functionality 
     * 					of CrimsonMeeting class. 
    **/
    static testMethod void testFindRegistrations_RegistrationId() {
    	
    	//Bypass Dupeblocker
        Util.IsTest(true);
        
        //Bypassing Triggers so then test data can be created easily
        Util.byPassAllTriggers = true;
        
        //Flag for triggers: this is just a test, don't do crazy things.
        Util.isTesting = true;
        
        // create a new contact
        Contact newContact = testUtilities.CreateNewContact(false);
        newContact.FirstName = 'Joe';
        newContact.LastName = 'Testerson';
        insert newContact;
        
        // create a new registration
        Registration__c registration = CreateRegistration(newContact.Id, false);
        
        // create a second contact and a registration for the same meeting
        Contact contact2 = testUtilities.CreateNewContact(true);
        Registration__c registration2 = CreateRegistration(registration.Meeting__c, contact2.Id, false);
        
        // add both registrations to a list and insert them at the same time
        List<Registration__c> registrationsToInsert = new List<Registration__c> { registration, registration2 };
        insert registrationsToInsert;
        
        // create our encrypted string
        String requestString = '{"Command":"FindRegistrations","RegistrationId":"' + registration.Id + '"}';
        String encryptedString = EncryptString(requestString);
        
        //Start testing from here
        Test.startTest();
        
        // instantiate a new crimsonMeeting object
        CrimsonMeeting cMeeting = new CrimsonMeeting(encryptedString);
        
        //Asserting for the results
        System.assertEquals('FindRegistrations', cMeeting.mWrapper.Command);
        System.assertNotEquals(Null, cMeeting.ToEncryptedString());
        System.assertEquals('Success',cMeeting.mWrapper.Response);
        
        // decrypt the response
        blob encryptedBlob = EncodingUtil.base64Decode(cMeeting.ToEncryptedString());
        String decryptedResponse = CrimsonMeeting.Decrypt(encryptedBlob);
        
        //Asserting for the results
        system.debug('@@decryptedResponse:' + decryptedResponse);
        system.assertEquals(true, decryptedResponse.contains('Success'));
        
        // make sure it returns both of the registrations
        system.assertEquals(true, decryptedResponse.contains('Testerson'));
        system.assertEquals(2, cMeeting.mWrapper.Registrations.size());
        
        //Initilization inner class
        CrimsonMeeting.MeetingWrapper meetingWrapper = new CrimsonMeeting.MeetingWrapper();
        
        //Setting controller's variable
        meetingWrapper.EndpointURL = 'www.testing.com';
        meetingWrapper = cMeeting.mWrapper;
        
        //Asserting for the results
        System.assert(meetingWrapper != null);
        
        //Stop testing here
        Test.stopTest();
    }
    
    //Modified by - Abhinav Sharma - CR-20150202-8633 - To refactor the existing code
    /**
     * @description : Test method to check out for various use cases associated with the find registrations for meeting Id based functionality 
     * 					of CrimsonMeeting class. 
    **/
    static testMethod void testFindRegistrations_MeetingId() {
    	
    	//Bypass Dupeblocker
        Util.IsTest(true);
        
        //Bypassing Triggers so then test data can be created easily
        Util.byPassAllTriggers = true;
        
        //Flag for triggers: this is just a test, don't do crazy things.
        Util.isTesting = true;
        
        // create a new contact
        Contact newContact = testUtilities.CreateNewContact(false);
        newContact.FirstName = 'Joe';
        newContact.LastName = 'Testerson';
        insert newContact;
        
        // create a new registration
        Registration__c registration = CreateRegistration(newContact.Id, false);
        
        // create a second contact and a registration for the same meeting
        Contact contact2 = testUtilities.CreateNewContact(true);
        Registration__c registration2 = CreateRegistration(registration.Meeting__c, contact2.Id, false);
        
        // add both registrations to a list and insert them at the same time
        List<Registration__c> registrationsToInsert = new List<Registration__c> { registration, registration2 };
        insert registrationsToInsert;
        
        // create our encrypted string
        String requestString = '{"Command":"FindRegistrations","MeetingId":"' + registration.Meeting__c + '"}';
        String encryptedString = EncryptString(requestString);
        
        //Start testing from here
        Test.startTest();
        
        // instantiate a new crimsonMeeting object
        CrimsonMeeting cMeeting = new CrimsonMeeting(encryptedString);
        
        //Asserting for the results
        system.assertEquals('FindRegistrations', cMeeting.mWrapper.Command);
        system.assertNotEquals(Null, cMeeting.ToEncryptedString());
        
        // decrypt the response
        blob encryptedBlob = EncodingUtil.base64Decode(cMeeting.ToEncryptedString());
        String decryptedResponse = CrimsonMeeting.Decrypt(encryptedBlob);
        
        //Asserting for the results
        system.debug('@@decryptedResponse:' + decryptedResponse);
        system.assertEquals(true, decryptedResponse.contains('Success'));
        system.assertEquals(true, decryptedResponse.contains('Scheduled'));
        
        // make sure it returns the registration that was created
        system.assertEquals(true, decryptedResponse.contains(string.valueOf(registration.Id).subString(0, 15)));
        
        // make sure it returns both of the registrations
        system.assertEquals(2, cMeeting.mWrapper.Registrations.size());
        
        //Stop test here
        Test.stopTest();
    }
    
    //Modified by - Abhinav Sharma - CR-20150202-8633 - To refactor the existing code
    /**
     * @description : Test method to check and assert for various use cases where find registration based
     * 					functionality will results as an error.
    **/
    static testMethod void testFindRegistrations_error() {
    	
    	//Bypass Dupeblocker
        Util.IsTest(true);
        
        //Bypassing Triggers so then test data can be created easily
        Util.byPassAllTriggers = true;
        
        //Flag for triggers: this is just a test, don't do crazy things.
        Util.isTesting = true;
        
        // create a new registration
        Registration__c registration = CreateRegistration(true);
        
        // create our encrypted string
        String requestString = '{"Command":"FindRegistrations","RegistrationId":""}';
        String encryptedString = EncryptString(requestString);
        
        //Start Test from here
        Test.startTest();
        
        // instantiate a new crimsonMeeting object
        CrimsonMeeting cMeeting = new CrimsonMeeting(encryptedString);
        
        //Asserting for the results
        system.assertEquals('FindRegistrations', cMeeting.mWrapper.Command);
        system.assertNotEquals(Null, cMeeting.ToEncryptedString());
        
        // decrypt the response
        blob encryptedBlob = EncodingUtil.base64Decode(cMeeting.ToEncryptedString());
        String decryptedResponse = CrimsonMeeting.Decrypt(encryptedBlob);
        
        //Asserting for the results
        system.debug('@@decryptedResponse:' + decryptedResponse);
        system.assertEquals(true, decryptedResponse.contains('At least one of the following fields must be filled in'));
        
        //Stop test here
        Test.stopTest();
    }
    
    //Modified by - Abhinav Sharma - CR-20150202-8633 - To refactor the existing code
    /**
     * @description : Test method to check and assert for various use cases where find meetings based
     * 					functionality will results as an error.
    **/
    static testMethod void testFindMeetings_error() {
    	
    	//Bypass Dupeblocker
        Util.IsTest(true);
        
        //Bypassing Triggers so then test data can be created easily
        Util.byPassAllTriggers = true;
        
        //Flag for triggers: this is just a test, don't do crazy things.
        Util.isTesting = true;
        
        // create a contact 
        Contact contact = testUtilities.CreateNewContact(true);
        
        // create a new registration
        Registration__c registration = CreateRegistration(true);
        
        //Start testing here
        Test.startTest();
        
        // create our encrypted string
        String requestString = '{"Command":"FindRegisteredSubMeetings","ContactId":"' + contact.Id + '"}';
        String encryptedString = EncryptString(requestString);
        
        // instantiate a new crimsonMeeting object
        CrimsonMeeting cMeeting = new CrimsonMeeting(encryptedString);
        
        //Asserting for the results
        system.assertEquals('FindRegisteredSubMeetings', cMeeting.mWrapper.Command);
        system.assertNotEquals(Null, cMeeting.ToEncryptedString());
        
        // decrypt the response
        blob encryptedBlob = EncodingUtil.base64Decode(cMeeting.ToEncryptedString());
        String decryptedResponse = CrimsonMeeting.Decrypt(encryptedBlob);
        
        //Asserting for the results
        system.debug('@@decryptedResponse:' + decryptedResponse);
        system.assertEquals(true, decryptedResponse.contains('Meeting Id and Contact Id or Registration Id are required'));
        
        //Stop testing here
        Test.stopTest();
    }
    
    //Modified by - Abhinav Sharma - CR-20150202-8633 - To refactor the existing code
    /**
     * @description : Test method to check out for various use cases associated with the find meetings for registration Id based functionality 
     * 					of CrimsonMeeting class. 
    **/
    static testMethod void testFindMeetings_RegistrationId() {
    	
    	//Bypass Dupeblocker
        Util.IsTest(true);
        
        //Bypassing Triggers so then test data can be created easily
        Util.byPassAllTriggers = true;
        
        //Flag for triggers: this is just a test, don't do crazy things.
        Util.isTesting = true;
        
        // create a new registration
        Registration__c registration0 = CreateRegistration(true);
        
        // create a child meeting from the one created above
        Meeting__c childMeeting1 = CreateMeeting(false);
        childMeeting1.Parent_Meeting__c = registration0.Meeting__c;
        insert childMeeting1;
        
        Meeting__c childMeeting2 = CreateMeeting(false);
        childMeeting2.Parent_Meeting__c = registration0.Meeting__c;
        insert childMeeting2;
        
        //Creating a Contact record
        Contact contact = testUtilities.CreateNewContact(true);
        
        Registration__c registration1 = CreateRegistration(childMeeting1.Id, registration0.Contact__c, true);
        Registration__c registration2 = CreateRegistration(childMeeting2.Id, registration0.Contact__c, true);
        
        //Start testing from here
        Test.startTest();
        
        // create our encrypted string
        String requestString = '{"Command":"FindRegisteredSubMeetings","RegistrationId":"' + registration0.Id + '"}';
        String encryptedString = EncryptString(requestString);
        
        // instantiate a new crimsonMeeting object
        CrimsonMeeting cMeeting = new CrimsonMeeting(encryptedString);
        
        //Asserting for the results
        system.assertEquals('FindRegisteredSubMeetings', cMeeting.mWrapper.Command);
        system.assertNotEquals(Null, cMeeting.ToEncryptedString());
        
        // decrypt the response
        blob encryptedBlob = EncodingUtil.base64Decode(cMeeting.ToEncryptedString());
        String decryptedResponse = CrimsonMeeting.Decrypt(encryptedBlob);
        
        //Asserting for the results
        system.debug('@@decryptedResponse:' + decryptedResponse);
        system.assertEquals(true, decryptedResponse.contains('Success'));
        
        // make sure it returns only 2 child registration
        system.assertEquals(2, cMeeting.mWrapper.Meetings.size());
        system.assertEquals(true, decryptedResponse.contains(string.valueOf(childMeeting1.Id).subString(0, 15)));
        system.assertEquals(true, decryptedResponse.contains(string.valueOf(childMeeting2.Id).subString(0, 15)));
        
        //Creating our encrypted string with Contant Id and Meeting Id
        requestString = '{"Command":"FindRegisteredSubMeetings","ContactId":"' + contact.Id + '","MeetingId":"' + registration0.Id + '"}';
        encryptedString = EncryptString(requestString);
        
        //Re-intilization the object
        cMeeting = new CrimsonMeeting(encryptedString);
        
        //Asserting for the results
        System.assertEquals('FindRegisteredSubMeetings', cMeeting.mWrapper.Command);
        System.assertNotEquals(Null, cMeeting.ToEncryptedString());
        System.assertEquals('Success',cMeeting.mWrapper.Response);
        
        //Decryption of response
        encryptedBlob = EncodingUtil.base64Decode(cMeeting.ToEncryptedString());
        decryptedResponse = CrimsonMeeting.Decrypt(encryptedBlob);
        System.assertEquals(true, decryptedResponse.contains('Success'));
        
        //Creating our encrypted string with invalid registration Id
        requestString = '{"Command":"FindRegisteredSubMeetings","ContactId":null,"MeetingId":"' + registration0.Id + '","RegistrationId":"Test"}';
        encryptedString = EncryptString(requestString);
        
        //Re-intilization the object
        cMeeting = new CrimsonMeeting(encryptedString);
        
        //Asserting for the results
        System.assertEquals('Invalid Registration Id.', cMeeting.mWrapper.Response);
        System.assertNotEquals(Null, cMeeting.ToEncryptedString());
        
        // decrypt the response
        encryptedBlob = EncodingUtil.base64Decode(cMeeting.ToEncryptedString());
        decryptedResponse = CrimsonMeeting.Decrypt(encryptedBlob);
        
        //Asserting for the results
        system.assertEquals(true, decryptedResponse.contains('Invalid Registration Id.'));
        
        //Decryption of response
        encryptedBlob = EncodingUtil.base64Decode(cMeeting.ToEncryptedString());
        decryptedResponse = CrimsonMeeting.Decrypt(encryptedBlob);
        
        //Asserting for the results
        System.assertEquals(true, decryptedResponse.contains('Invalid Registration Id.'));
        
        //Stop testing here
        Test.stopTest();
    }
    
    //Modified by - Abhinav Sharma - CR-20150202-8633 - To refactor the existing code
    /**
     * @description : Test method to check out for various use cases associated with the find meetings by user based functionality 
     * 					of CrimsonMeeting class. 
    **/
    static testMethod void testFindMeetingsByUser() {
    	
    	//Bypass Dupeblocker
        Util.IsTest(true);
        
        //Bypassing Triggers so then test data can be created easily
        Util.byPassAllTriggers = true;
        
        //Flag for triggers: this is just a test, don't do crazy things.
        Util.isTesting = true;
        
        // create a new registration
        Registration__c registration0 = CreateRegistration(true);
        
        // create a child meeting from the one created above
        Meeting__c childMeeting1 = CreateMeeting(false);
        childMeeting1.Parent_Meeting__c = registration0.Meeting__c;
        insert childMeeting1;
        
        Meeting__c childMeeting2 = CreateMeeting(false);
        childMeeting2.Parent_Meeting__c = registration0.Meeting__c;
        childMeeting2.DateTime__c = datetime.valueOf('2016-06-08 07:23:00');
        insert childMeeting2;
        
        Registration__c registration1 = CreateRegistration(childMeeting1.Id, registration0.Contact__c, true);
        Registration__c registration2 = CreateRegistration(childMeeting2.Id, registration0.Contact__c, true);
        
        // create our encrypted string
        String requestString = '{"Command":"FindMeetingsByUser","ContactId":"' + registration0.Contact__c + '"}';
        String encryptedString = EncryptString(requestString);
        
        //Start testing from here
        Test.startTest();
        
        // instantiate a new crimsonMeeting object
        CrimsonMeeting cMeeting = new CrimsonMeeting(encryptedString);
        
        //Asserting for the results
        system.assertEquals('FindMeetingsByUser', cMeeting.mWrapper.Command);
        system.assertNotEquals(Null, cMeeting.ToEncryptedString());
        
        // decrypt the response
        blob encryptedBlob = EncodingUtil.base64Decode(cMeeting.ToEncryptedString());
        String decryptedResponse = CrimsonMeeting.Decrypt(encryptedBlob);
        
        //Asserting for the results
        system.debug('@@decryptedResponse:' + decryptedResponse);
        system.assertEquals(true, decryptedResponse.contains('Success'));
        
        // make sure it returns only 2 child registration
        system.assertEquals(3, cMeeting.mWrapper.Meetings.size());
        system.assertEquals(true, decryptedResponse.contains(string.valueOf(childMeeting1.Id).subString(0, 15)));
        system.assertEquals(true, decryptedResponse.contains(string.valueOf(childMeeting2.Id).subString(0, 15)));
        
        //Creating our encrypted string with blank Contact Id
        requestString = '{"Command":"FindMeetingsByUser","ContactId":""}';
        encryptedString = EncryptString(requestString);
        
        // instantiate a new crimsonMeeting object
        cMeeting = new CrimsonMeeting(encryptedString);
        
        //Asserting for the results
        System.assertEquals('FindMeetingsByUser', cMeeting.mWrapper.Command);
        System.assertNotEquals(Null, cMeeting.ToEncryptedString());
        System.assertEquals('Contact Id is required.', cMeeting.mWrapper.Response);
        
        //Decryption of response
        encryptedBlob = EncodingUtil.base64Decode(cMeeting.ToEncryptedString());
        decryptedResponse = CrimsonMeeting.Decrypt(encryptedBlob);
        system.assertEquals(true, decryptedResponse.contains('Contact Id is required.'));
        
        //create our encrypted string with invalid command
        requestString = '{"Command":"Testing","ContactId":""}';
        encryptedString = EncryptString(requestString);
        
        // instantiate a new crimsonMeeting object
        cMeeting = new CrimsonMeeting(encryptedString);
        
        //Asserting for the resultss
        System.assertEquals('Testing', cMeeting.mWrapper.Command);
        System.assertNotEquals(Null, cMeeting.ToEncryptedString());
        System.assertEquals(true, cMeeting.mWrapper.Response.contains('Error: Unrecognized command:'));
        
        //Decryption of response
        encryptedBlob = EncodingUtil.base64Decode(cMeeting.ToEncryptedString());
        decryptedResponse = CrimsonMeeting.Decrypt(encryptedBlob);
        
        //Asserting for the results
        System.assertEquals(true, decryptedResponse.contains('Error: Unrecognized command:'));
        
        //Stop testing here
        Test.stopTest();
    }
    
    //Modified by - Abhinav Sharma - CR-20150202-8633 - To refactor the existing code
    /**
     * @description : Test method to check out for various use cases associated with the create registration functionality 
     * 					of CrimsonMeeting class. 
    **/
    static testMethod void testCreateRegistration() {
    	
    	//Bypass Dupeblocker
        Util.IsTest(true);
        
        //Bypassing Triggers so then test data can be created easily
        Util.byPassAllTriggers = true;
        
        //Flag for triggers: this is just a test, don't do crazy things.
        Util.isTesting = true;
        
        // create a new registration
        Registration__c registration0 = CreateRegistration(true);
        
        // create a child meeting from the one created above
        Meeting__c childMeeting1 = CreateMeeting(false);
        childMeeting1.Parent_Meeting__c = registration0.Meeting__c;
        insert childMeeting1;
        
        //Added By Bhavi
        //Create More child meeting records
        Meeting__c childMeeting2 = CreateMeeting(false);
        childMeeting2.Auto_Subscribe__c = true;
        childMeeting2.Parent_Meeting__c = childMeeting1.Id;
        insert childMeeting2;
        
        Meeting__c childMeeting3 = CreateMeeting(false);
        childMeeting3.Auto_Subscribe__c = false;
        childMeeting3.Parent_Meeting__c = childMeeting1.Id;
        insert childMeeting3;  
        
        //Start testing from here
        Test.startTest();
        
        // create our encrypted string
        String requestString = '{"Command":"CreateRegistration","ContactId":"' + registration0.Contact__c + '","MeetingId":"' + childMeeting1.Id + '","Status":"Attended"}';
        String encryptedString = EncryptString(requestString);
        
        // instantiate a new crimsonMeeting object
        CrimsonMeeting cMeeting = new CrimsonMeeting(encryptedString);
        
        //Asserting for the results
        system.assertEquals('CreateRegistration', cMeeting.mWrapper.Command);
        system.assertNotEquals(Null, cMeeting.ToEncryptedString());
        
        // decrypt the response
        blob encryptedBlob = EncodingUtil.base64Decode(cMeeting.ToEncryptedString());
        String decryptedResponse = CrimsonMeeting.Decrypt(encryptedBlob);
        system.debug('@@decryptedResponse:' + decryptedResponse);
        
        // get the registration record
        List<Registration__c> registrations = [SELECT Status__c, Id FROM Registration__c WHERE Status__c = 'Attended' AND Meeting__c =: childMeeting2.Id];
        system.assertEquals(1, registrations.size());
    	
    	// get the registration record
        registrations = [SELECT Id FROM Registration__c WHERE Meeting__c =: childMeeting2.Id];
        System.assert(registrations != null);
        system.assertEquals(1, registrations.size());
        
        registrations = [SELECT Id FROM Registration__c WHERE Meeting__c =: childMeeting3.Id];
        System.assert(registrations != null);
        system.assertEquals(0, registrations.size());
        
        //Creating our encrypted string with invalid Id to generate a exception
        requestString = '{"Command":"CreateRegistration","ContactId":"","MeetingId":"","Status":"Attended"}';
        encryptedString = EncryptString(requestString);
        
        //Re-instantiate the object
        cMeeting = new CrimsonMeeting(encryptedString);
        
        //Asserting for the results
        System.assertEquals('CreateRegistration', cMeeting.mWrapper.Command);
        System.assertNotEquals(Null, cMeeting.ToEncryptedString());
        System.assertEquals(true, cMeeting.mWrapper.Response.contains('Error:'));
        
        //Decryption of response
        encryptedBlob = EncodingUtil.base64Decode(cMeeting.ToEncryptedString());
        decryptedResponse = CrimsonMeeting.Decrypt(encryptedBlob);
        
        //Asserting for the results
        System.assertEquals(true, decryptedResponse.contains('Error:'));
        
        // Creating our encrypted string with Meeting Id is null
        requestString = '{"Command":"CreateRegistration","ContactId":"' + registration0.Contact__c + '","MeetingId":null,"Status":"Attended"}';
        encryptedString = EncryptString(requestString);
        
        //Re-intilization the object
        cMeeting = new CrimsonMeeting(encryptedString);
        
        //Asserting for the results
        System.assertEquals('CreateRegistration', cMeeting.mWrapper.Command);
        System.assertNotEquals(Null, cMeeting.ToEncryptedString());
        System.assertEquals('Meeting Id and Contact Id are required.',cMeeting.mWrapper.Response);
        
        //Decryption of response
        encryptedBlob = EncodingUtil.base64Decode(cMeeting.ToEncryptedString());
        decryptedResponse = CrimsonMeeting.Decrypt(encryptedBlob);
        
        //Asserting for the results
        System.assertEquals(true, decryptedResponse.contains('Meeting Id and Contact Id are required.'));
        
    	//Stop testing here
    	Test.stopTest();
    }
    
    //Modified by - Abhinav Sharma - CR-20150202-8633 - To refactor the existing code
    /**
     * @description : Test method to check out for various use cases associated with the delete registration functionality 
     * 					of CrimsonMeeting class. 
    **/
    static testMethod void testDeleteRegistration() {
    	
    	//Bypass Dupeblocker
        Util.IsTest(true);
        
        //Bypassing Triggers so then test data can be created easily
        Util.byPassAllTriggers = true;
        
        //Flag for triggers: this is just a test, don't do crazy things.
        Util.isTesting = true;
        
        // create a new registration
        Registration__c registration = CreateRegistration(true);
        
        // delete the registration having ContactId as null
        String requestString = '{"MeetingId":"' + registration.Meeting__c + '","ContactId":null,"Command":"DeleteRegistration"}';
        String encryptedString = EncryptString(requestString);
        
        // instantiate a new crimsonMeeting object
        CrimsonMeeting cMeeting = new CrimsonMeeting(encryptedString);
        
        // decrypt the response
        blob encryptedBlob = EncodingUtil.base64Decode(cMeeting.ToEncryptedString());
        String decryptedResponse = CrimsonMeeting.Decrypt(encryptedBlob);
        system.debug('@@decryptedResponse:' + decryptedResponse);
        
        // Attempt to find the original reg
        List<Registration__c> registrations = [SELECT Id FROM Registration__c WHERE Id = :registration.Id];
        System.assert(registrations != null);
        system.assertEquals(1, registrations.size());
        system.assertEquals('DeleteRegistration', cMeeting.mWrapper.Command);
        system.assertNotEquals(Null, cMeeting.ToEncryptedString());
        
        //Start testing from here
        Test.startTest();
        
        //Creating our encrypted string 
        requestString = '{"MeetingId":"' + registration.Meeting__c + '","RegistrationId":"' + registration.Id + '","Command":"DeleteRegistration"}';
        encryptedString = EncryptString(requestString);
        
        //Re-initilization a new crimsonMeeting object
        cMeeting = new CrimsonMeeting(encryptedString);
        
        //Asserting for the results
        System.assertEquals('DeleteRegistration', cMeeting.mWrapper.Command);
        System.assertNotEquals(Null, cMeeting.ToEncryptedString());
        
        //Creating our encrypted string having registration Id is null
        requestString = '{"MeetingId":"'+ registration.Meeting__c + '","ContactId":"' + registration.Contact__c + '" ,"Command":"DeleteRegistration"}';
        encryptedString = EncryptString(requestString);
        
        //Re-initilization a new crimsonMeeting object
        cMeeting = new CrimsonMeeting(encryptedString);
        
        //Asserting for the results
        System.assertEquals('DeleteRegistration', cMeeting.mWrapper.Command);
        System.assertNotEquals(null, cMeeting.ToEncryptedString());
        System.assertEquals('Success', cMeeting.mWrapper.Response);
        
        //Decryption of response
        encryptedBlob = EncodingUtil.base64Decode(cMeeting.ToEncryptedString());
        decryptedResponse = CrimsonMeeting.Decrypt(encryptedBlob);
        
        //Asserting for the results
        System.assertEquals(true, decryptedResponse.contains('Success'));
        
        //Creating our encrypted string having contact id is null
        requestString = '{"MeetingId":"' + registration.Meeting__c + '","ContactId":null,"RegistrationId":"' + registration.Id + '","Command":"DeleteRegistration"}';
        encryptedString = EncryptString(requestString);
        
        //Re-initilization a new crimsonMeeting object
        cMeeting = new CrimsonMeeting(encryptedString);
        
        //Asserting for the results
        System.assertEquals('DeleteRegistration', cMeeting.mWrapper.Command);
        System.assertNotEquals(Null, cMeeting.ToEncryptedString());
        System.assertEquals('Invalid Registration Id.',cMeeting.mWrapper.Response);
        
        //Decryption of response
        encryptedBlob = EncodingUtil.base64Decode(cMeeting.ToEncryptedString());
        decryptedResponse = CrimsonMeeting.Decrypt(encryptedBlob);
        
        //Asserting for the results
        System.assertEquals(true, decryptedResponse.contains('Invalid Registration Id.'));
        
        //Creating our encrypted string having registration Id is invalid
        requestString = '{"MeetingId":"test","ContactId":"' + registration.Contact__c + '" ,"Command":"DeleteRegistration"}';
        encryptedString = EncryptString(requestString);
        
        //Re-initilization a new crimsonMeeting object
        cMeeting = new CrimsonMeeting(encryptedString);
        
        //Asserting for the results
        System.assertEquals('DeleteRegistration', cMeeting.mWrapper.Command);
        System.assertNotEquals(null, cMeeting.ToEncryptedString());
        System.assertEquals('Invalid Meeting Id.', cMeeting.mWrapper.Response);
        
        //Decryption of response
        encryptedBlob = EncodingUtil.base64Decode(cMeeting.ToEncryptedString());
        decryptedResponse = CrimsonMeeting.Decrypt(encryptedBlob);
        
        //Asserting for the results
        System.assertEquals(true, decryptedResponse.contains('Invalid Meeting Id.'));
        
        //Creating our encrypted string having Contact Id is invalid
        requestString = '{"MeetingId":"' + registration.Meeting__c + '","ContactId":"test" ,"Command":"DeleteRegistration"}';
        encryptedString = EncryptString(requestString);
        
        //Re-initilization a new crimsonMeeting object
        cMeeting = new CrimsonMeeting(encryptedString);
        
        //Asserting for the results
        System.assertEquals('DeleteRegistration', cMeeting.mWrapper.Command);
        System.assertNotEquals(null, cMeeting.ToEncryptedString());
        System.assertEquals('Invalid Contact Id.', cMeeting.mWrapper.Response);
        
        //Decryption of response
        encryptedBlob = EncodingUtil.base64Decode(cMeeting.ToEncryptedString());
        decryptedResponse = CrimsonMeeting.Decrypt(encryptedBlob);
        
        //Asserting for the results
        System.assertEquals(true, decryptedResponse.contains('Invalid Contact Id.'));
        
        //Stop testing here
        Test.stopTest();
    }
    
    //Added by - Abhinav Sharma - CR-20150202-8633 - To refactor the existing code
    /**
     * @description : Test method to check and assert for FindAllSubMeetings method based use cases.
     * 
    **/
    static testMethod void testFindAllSubMeetings() {
    	
    	//Bypass Dupeblocker
        Util.IsTest(true);
        
        //Bypassing Triggers so then test data can be created easily
        Util.byPassAllTriggers = true;
        
        //Flag for triggers: this is just a test, don't do crazy things.
        Util.isTesting = true;
        
    	//Create a Meeting
    	Meeting__c parentMeeting = CreateMeeting(false);
    	parentMeeting.DateTime__c = system.now();
    	insert parentMeeting;
    	System.assertNotEquals(null, parentMeeting.Id);
    	
    	//Create a Meeting with parent
    	Meeting__c meeting = CreateMeeting(false);
    	meeting.Parent_Meeting__c = parentMeeting.Id;
    	insert meeting;
    	System.assertNotEquals(null,meeting.Id);
    	
    	//Create a Contact
    	Contact contact = testUtilities.CreateNewContact(true);
    	System.assertNotEquals(null, contact.Id);
    	
    	// create a new registration
        Registration__c registration = CreateRegistration(meeting.Id, contact.Id, true);
        System.assertNotEquals(null, registration.Id);
        
        //Start testing from here
        Test.startTest();
        
        //Creating our encrypted string with meeting id and contact Id
        String requestString = '{"MeetingId":"' + parentMeeting.Id + '","ContactId":"' + registration.Contact__c + '","Command":"FindAllSubMeetings"}';
        String encryptedString = EncryptString(requestString);
        
        // instantiate a new crimsonMeeting object
        CrimsonMeeting cMeeting = new CrimsonMeeting(encryptedString);
        
        //Asserting for the results
        System.assertEquals('FindAllSubMeetings', cMeeting.mWrapper.Command);
        System.assertNotEquals(Null, cMeeting.ToEncryptedString());
        System.assertEquals('Success',cMeeting.mWrapper.Response);
        
        //Decryption of response
        blob encryptedBlob = EncodingUtil.base64Decode(cMeeting.ToEncryptedString());
        String decryptedResponse = CrimsonMeeting.Decrypt(encryptedBlob);
        
        //Asserting for the results
        System.assertEquals(true, decryptedResponse.contains('Success'));
        
        //Find all sub meeting registration with null MeetingId
        requestString = '{"MeetingId": null ,"RegistrationId":"' + registration.Id + '","Command":"FindAllSubMeetings"}';
        encryptedString = EncryptString(requestString);
        
        //Re-instantiate the object
        cMeeting = new CrimsonMeeting(encryptedString);
        
        //Asserting for the results
        System.assertEquals('FindAllSubMeetings', cMeeting.mWrapper.Command);
        System.assertNotEquals(Null, cMeeting.ToEncryptedString());
        System.assertEquals('Success',cMeeting.mWrapper.Response);
        
        //Decryption of response
        encryptedBlob = EncodingUtil.base64Decode(cMeeting.ToEncryptedString());
        decryptedResponse = CrimsonMeeting.Decrypt(encryptedBlob);
        
        //Asserting for the results
        System.assertEquals(true, decryptedResponse.contains('Success'));
        
        //Creating encrypted string with Meeting Id and Registration Id are null
        requestString = '{"MeetingId": null ,"RegistrationId": null ,"Command":"FindAllSubMeetings"}';
        encryptedString = EncryptString(requestString);
        
        //Re-instantiate the object
        cMeeting = new CrimsonMeeting(encryptedString);
        System.assertEquals('FindAllSubMeetings', cMeeting.mWrapper.Command);
        
        //Asserting for the results
        System.assertNotEquals(Null, cMeeting.ToEncryptedString());
        System.assertEquals('Meeting Id or Registration Id are required.',cMeeting.mWrapper.Response);
        
        //Decryption of response
        encryptedBlob = EncodingUtil.base64Decode(cMeeting.ToEncryptedString());
        decryptedResponse = CrimsonMeeting.Decrypt(encryptedBlob);
        
        //Asserting for the results
        System.assertEquals(true, decryptedResponse.contains('Meeting Id or Registration Id are required.'));
        
        //Creating encrypted string with Meeting Id and Contact Id 
        requestString = '{"MeetingId":"'+ meeting + '","ContactId":"' + registration.Contact__c + '","Command":"FindMeetings"}';
        encryptedString = EncryptString(requestString);
        
        //Re-instantiate the object
        cMeeting = new CrimsonMeeting(encryptedString);
        
        //Asserting for the results
        System.assertEquals('FindMeetings', cMeeting.mWrapper.Command);
        System.assertNotEquals(Null, cMeeting.ToEncryptedString());
        System.assertEquals('Success', cMeeting.mWrapper.Response);
        
        //Decryption of response
        encryptedBlob = EncodingUtil.base64Decode(cMeeting.ToEncryptedString());
        decryptedResponse = CrimsonMeeting.Decrypt(encryptedBlob);
        
        //Asserting for the results
        System.assertEquals(true, decryptedResponse.contains('Success'));
        
        //Find all sub meeting the registration with null MeetingId
        requestString = '{"MeetingId": null ,"RegistrationId":"' + registration.Id + '","Command":"FindMeetings"}';
        encryptedString = EncryptString(requestString);
        
        //Re-instantiate the object
        cMeeting = new CrimsonMeeting(encryptedString);
        System.assertEquals('FindMeetings', cMeeting.mWrapper.Command);
        
        //Asserting for the results
        System.assertNotEquals(Null, cMeeting.ToEncryptedString());
        System.assertEquals('Success', cMeeting.mWrapper.Response);
        
        //Decryption of response
        encryptedBlob = EncodingUtil.base64Decode(cMeeting.ToEncryptedString());
        decryptedResponse = CrimsonMeeting.Decrypt(encryptedBlob);
        
        //Asserting for the results
        System.assertEquals(true, decryptedResponse.contains('Success'));
        
        //Creating our encrypted string with Parent Meeting Id
        requestString = '{"ParentMeetingId":"' + registration.Meeting__c + '","RegistrationId":"' + registration.Id + '","Command":"FindMeetings"}';
        encryptedString = EncryptString(requestString);
        
        //Re-instantiate the object
        cMeeting = new CrimsonMeeting(encryptedString);
        
        //Asserting for the results
        System.assertEquals('FindMeetings', cMeeting.mWrapper.Command);
        System.assertNotEquals(Null, cMeeting.ToEncryptedString()); 
        System.assertEquals('Success', cMeeting.mWrapper.Response);
        
        //Decryption of response
        encryptedBlob = EncodingUtil.base64Decode(cMeeting.ToEncryptedString());
        decryptedResponse = CrimsonMeeting.Decrypt(encryptedBlob);
        System.assertEquals(true, decryptedResponse.contains('Success'));
        
        //Creating our encrypted string with invalid Registration Id
        requestString = '{"MeetingId":null,"Command":"FindAllSubMeetings", "RegistrationId":"123"}';
        encryptedString = EncryptString(requestString);
        
        //Re-instantiate the object
        cMeeting = new CrimsonMeeting(encryptedString);
        
        //Asserting for the results
        System.assertNotEquals(Null, cMeeting.ToEncryptedString());
        System.assertEquals('FindAllSubMeetings', cMeeting.mWrapper.Command);
        System.assertEquals('Invalid Registration Id.', cMeeting.mWrapper.Response);
        
        //Decryption of response
        encryptedBlob = EncodingUtil.base64Decode(cMeeting.ToEncryptedString());
        decryptedResponse = CrimsonMeeting.Decrypt(encryptedBlob);
        
        //Asserting for the results
        System.assertEquals(true, decryptedResponse.contains('Invalid Registration Id.'));
        
        //Generating exception
        cMeeting = new CrimsonMeeting(null);
        
        //Asserting for the results
        System.assertEquals(true,cMeeting.mWrapper.Response.contains('Error: '));
        
        //Decryption of response
        encryptedBlob = EncodingUtil.base64Decode(cMeeting.ToEncryptedString());
        decryptedResponse = CrimsonMeeting.Decrypt(encryptedBlob);
        
        //Asserting for the results
        System.assertEquals(true, decryptedResponse.contains('Error: '));
		
        //Stop testing here
        Test.stopTest();
    }
    
    //Added by - Abhinav Sharma - CR-20150202-8634 - To refactor the existing code
    /**
     * @description : Test method to check the functionality of Initialize method of CrimsonMeetingController class.
     * 
    **/
    static testMethod void testCrimsonMeetingController(){
        
        //Bypass Dupeblocker
        Util.IsTest(true);
        
        //Bypassing Triggers so then test data can be created easily
        Util.byPassAllTriggers = true;
        
        //Flag for triggers: this is just a test, don't do crazy things.
        Util.isTesting = true;
        
        //Setting current page parameter
        ApexPages.currentPage().getParameters().put('req','test');
        
        //Start testing from here
        Test.startTest();
        
        //Instantiate a new CrimsonMeetingController object
        CrimsonMeetingController controller = new CrimsonMeetingController();
        
        //Calling controller's method
		controller.Initialize();   
        
        //Asserting for the results
        System.assertNotEquals(null, controller.JSONResponse);
        
        //Stop testing here
        Test.stopTest();
    }
}