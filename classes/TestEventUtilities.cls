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
private class TestEventUtilities {

    static testmethod void testIsPrewire() { 
        //Bypass Dupeblocker
        Util.IsTest(true);
        Event evt = TestUtilities.CreateNewEvent(false);
        evt.Event_Type__c = 'Phone Appointment';
        evt.Event_Purpose__c = 'Prewire';
        insert evt;
        
        boolean isPrewire = EventUtilities.IsPrewire(evt);
        // assert that it returns true
        system.assertEquals(true, isPrewire);
    }
    
    static testmethod void testIsNotPrewire() { 
        //Bypass Dupeblocker
        Util.IsTest(true);
        Event evt = TestUtilities.CreateNewEvent(false);
        evt.Event_Type__c = 'Phone Appointment';
        evt.Event_Purpose__c = 'Call';
        insert evt;
        
        boolean isPrewire = EventUtilities.IsPrewire(evt);
        // assert that it returns false
        system.assertEquals(false, isPrewire);
    }
    
    //Added By - Ajit Surana - 07/03/2014 - CR-20140602-5661
    static testmethod void test_sendNegativeFeedBackEmailAlert() { 
        
        //Bypass Dupeblocker
        Util.IsTest(true);
        
        //Disable all the triggers 
        Util.BypassAllTriggers = true;

        //Get profile list
        List<Profile> testProfile = [Select Id, Name from Profile where Name = 'System Administrator'];
        
        //Assert for results
        System.assert(testProfile.size()>0);
                
        //Test User Create
        List<User> users = new List<User>();
        users.add(new User(Username= Math.random()+'@abc.com', LastName='Test User1', FirstName='Test1', Email='ajit.k.surana@simplyforce.com',
                            Alias='Test1', EmailEncodingKey='UTF-8', languagelocalekey='en_US', ProfileId=testProfile[0].Id, 
                            timezonesidkey='America/Los_Angeles', localesidkey='en_US', EmployeeNumber = '12121212', IsActive = true));
        users.add(new User(Username= Math.random()+'@abc.com', LastName='Test User2', FirstName='Test1', Email='abhinav@simplyforce.com',
                            Alias='Test2', EmailEncodingKey='UTF-8', languagelocalekey='en_US', ProfileId=testProfile[0].Id, 
                            timezonesidkey='America/Los_Angeles', localesidkey='en_US', EmployeeNumber = '12121212', IsActive = true));
        
        //insert users
        insert users;
        
        //Test Account Record
        Account acc = new Account(Name = 'testacct', EA_AE__c = users[0].Id,  
                                   RM_RI__c = users[0].Id);
        
        //Insert Account
        insert acc;
        
        //Contact
        Contact contact = new Contact(LastName = 'Test', FirstName = 'Con');
        
        //Insert Contact
        insert contact;
        
        //Test Program Record
        Program__c program = new Program__c(Name = 'testprog', Program_Acronym__c = 'test');
        
        //Insert Program
        insert program;
        
        //Test Membership Record
        Membership__c mem = new Membership__c(Account_Name__c = acc.id, Program__c = program.id);
        
        //Insert Membership record
        insert mem;
        
        //Getting Record Type Id Value for opportunity
        ID oppRecordTypeId = [Select Id, Name FROM RecordType WHERE SobjectType = 'Opportunity' and Name = 'PT Contract Maintenance'].Id;
        
        //Insert Test Opportunity record
        Opportunity opp = new Opportunity(AccountId = acc.Id, Program__c = program.Id, Name = 'Test-Opportunity', 
                                                   StageName = 'Verbal Yes', pool_Month__c = '1', Owner_Manager_Email__c = users[1].Email,
                                                   RecordTypeId = oppRecordTypeId, CloseDate = System.today().addDays(7), 
                                                   Pool_Year__c = String.valueOf(Date.Today().Year()-2),
                                                   Decision_Type__c = 'Need New LOA', Main_Contact__c = contact.Id, Membership__c = mem.Id);
        
        //Insert record
        insert opp;
            
        //Getting Record Type Id Value for Opportunity
        ID eventRecordTypeId = [Select Id, Name FROM RecordType WHERE SobjectType = 'Event' and Name = 'PT QA Call'].Id;
        
        //List to hold the Account records
        List<Event> eventList = new List<Event>();
        
        //Making data for Event records
        eventList.add(new Event(Subject = 'Email', StartDateTime = Date.today(), EndDateTime = Date.today(), WhatId = mem.Id,
                                 RecordTypeId = eventRecordTypeId, Executive_Type__c = 'VP', Negative_Feedback__c = Constants.NEGATIVE_FEEDBACK_MARKETING, Event_Type__c = 'PT QA Call'));
        eventList.add(new Event(Subject = 'Email', StartDateTime = Date.today(), EndDateTime = Date.today(), WhatId = mem.Id,
                                 RecordTypeId = eventRecordTypeId, Executive_Type__c = 'VP', Negative_Feedback__c = Constants.NEGATIVE_FEEDBACK_MARKETING, Event_Type__c = 'PT QA Call'));
        eventList.add(new Event(Subject = 'Email', StartDateTime = Date.today(), EndDateTime = Date.today(), WhatId = mem.Id,
                                 RecordTypeId = eventRecordTypeId, Executive_Type__c = 'VP', Negative_Feedback__c = Constants.NEGATIVE_FEEDBACK_MARKETING, Event_Type__c = 'PT QA Call'));
       
        //Test starts from here
        Test.startTest();
        
        //Enable all the triggers 
        Util.BypassAllTriggers = true;

        //Insert Event records
        insert eventList;
        
        //List to hold Account record values
        List <Membership__c> listMemberships = [Select Id, Account_Name__r.EA_AE__r.Email, 
                                             Account_Name__r.RM_RI__r.Email FROM Membership__c]; 
        
        
        //Assert for results
        System.assertEquals(listMemberships[0].Account_Name__r.EA_AE__r.Email, 'ajit.k.surana@simplyforce.com');
        
        //Test stops from here
        Test.stopTest();
    }
}