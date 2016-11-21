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
private class Test_TriggerEvent {

    /**
    *  Purpose     :    Test class for EventTriggerHelper to test the population of "Next Activity Date" field value on the Opportunity.
    *
    *  Created By   :   Mahendra Swarnkar
    *
    *  Created Date:    11/16/2013
    *
    *  Revision Log:    V1.0 - Created
    *
    *  Coverage    :    V1.0 - Created
    *                   v1.1 - Modified By - Abhinav Sharma - 09/03/2015 - CR-20140613-5790
    *                   v1.2 - Modified By - Abhinav Sharma - 09/07/2015 - CR-20140613-9161
    *                   v1.3 - Modified By - Abhinav Sharma - 11/25/2015 - CR-20150929-9281 - 95% Code Coverage
    *                   v1.4 - Modified By - Mahendra Swarnkar - 2/9/2016 - CR-20151221-9474 
    * 					v1.5 - Modified By - Mahendra Swarnkar - 8/26/2016 - CR-20160606-9903
    **/
    
    static testMethod void testUpdateNextActivityDate() {

        //Bypassing all triggers
        Util.byPassAllTriggers = true;
        Util.IsTest(true);
        
        //Query through Opportunity RecordTypes
        List<RecordType> oppRecord = [SELECT Id , DeveloperName FROM RecordType 
                                        WHERE DeveloperName = 'BI_Contract_Maintenance' 
                                        AND SObjectType = 'Opportunity'
                                        AND IsActive = true];

        //Query through Opportunity RecordTypes
        List<RecordType> eventRecordType = [SELECT Id , DeveloperName FROM RecordType 
                                                WHERE (DeveloperName = 'BI_Marketing' OR DeveloperName = 'BI_QA_Call') 
                                                AND SObjectType = 'Event' AND IsActive = true];

        //Map to hold record type DeveloperName as key and record type Id as value
        Map<String,Id> mapEventRecordType =  new Map<String,Id>();

        //Populate mapEventRecordType
        for(RecordType rt : eventRecordType){
            mapEventRecordType.put(rt.DeveloperName , rt.Id);
        }
        
        //Profile    
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator']; 
      
        //User
        User u = new User(Alias = 'standt', Email='standarduser@testorg.com', 
                            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                            LocaleSidKey='en_US', ProfileId = p.Id, department = 'STP',
                            TimeZoneSidKey='GMT', UserName=Math.random() + '@test.com');

        System.runAs(u) {
        
            //Insert Opportunity Records
            List<Opportunity> oppList = new List<Opportunity>();
            oppList.add(new Opportunity(RecordTypeId = oppRecord[0].Id , Name = 'Test Opportunity0' , StageName = 'Proposal In Progress' , Amount = 1234 , CloseDate=system.today().addDays(3) ));
            oppList.add(new Opportunity(RecordTypeId = oppRecord[0].Id , Name = 'Test Opportunity1' , StageName = 'Proposal In Progress' , Amount = 1234 , CloseDate=system.today().addDays(4) ));
            Insert oppList;
            
            //List to hold Events
            List<Event> events = new List<Event>();
            
            //Populate List
            events.add(new Event(RecordTypeId = mapEventRecordType.get('BI_Marketing') ,StartDateTime = system.today().addDays(4), 
                                 EndDateTime = system.today().addDays(7) , OwnerId = Userinfo.getUserId(),
                                 Subject = 'Will Auto-Populate',   WhatId = oppList[0].Id , Cancelled_Did_Not_Occur__c = false ,  
                                 Event_Type__c = 'Web Visit' ));
            events.add(new Event(RecordTypeId = mapEventRecordType.get('BI_Marketing') ,StartDateTime = system.today().addDays(3), 
                                 EndDateTime = system.today().addDays(7) , OwnerId = Userinfo.getUserId(),
                                 Subject = 'Will Auto-Populate',   WhatId = oppList[0].Id , Cancelled_Did_Not_Occur__c = false ,  
                                 Event_Type__c = 'Web Visit' ));
            events.add(new Event(RecordTypeId = mapEventRecordType.get('BI_Marketing') ,StartDateTime = system.today().addDays(5), 
                                 EndDateTime = system.today().addDays(7) , OwnerId = Userinfo.getUserId(),
                                 Subject = 'Will Auto-Populate',   WhatId = oppList[0].Id , Cancelled_Did_Not_Occur__c = false ,  
                                 Event_Type__c = 'Web Visit' ));
            events.add(new Event(RecordTypeId = mapEventRecordType.get('BI_QA_Call') ,StartDateTime = system.today().addDays(2), 
                                 EndDateTime = system.today().addDays(7) , OwnerId = Userinfo.getUserId(),
                                 Subject = 'Will Auto-Populate',   WhatId = oppList[0].Id , Cancelled_Did_Not_Occur__c = false ,  
                                 Event_Type__c = 'Web Visit' ));
            
            //Test Start from here
            Test.startTest();
            
            //Enables all the triggers
            Util.BypassAllTriggers = false;
            
            //Insert Events
            insert events;
            
            //Query through Opportunity for validate Next_Activity_Date field value
            List<Opportunity> oppResultList = [SELECT Id ,Next_Activity_Date__c FROM Opportunity WHERE Id =: oppList[0].Id];
            
            //Assert for result
            system.assertEquals(system.today().addDays(3) , oppResultList[0].Next_Activity_Date__c );
            
            //Update Event records
            events[0].StartDateTime = system.today().addDays(2);
        
            //Update Events
            update events[0];
        
            //Query through Opportunity for validate Next_Activity_Date field value
            oppResultList = [ SELECT Id ,Next_Activity_Date__c FROM Opportunity WHERE Id =: oppList[0].Id ];

            //Assert for result
            system.assertEquals(system.today().addDays(2) , oppResultList[0].Next_Activity_Date__c );

            //Update Event records
            events[1].WhatId = oppList[1].Id ;
        
            //Update events
            update events[1];

            //Query through Opportunity for validate Next_Activity_Date field value
            oppResultList = [ SELECT Id ,Next_Activity_Date__c FROM Opportunity WHERE Id =: oppList[1].Id ];

            //Assert for result
            system.assertEquals(system.today().addDays(3) , oppResultList[0].Next_Activity_Date__c );
        
            //Test stops here
            Test.stopTest();
            
            //Delete events
            delete events;

            //Query through Opportunity for validate Next_Activity_Date field value
            oppResultList = [ SELECT Id ,Next_Activity_Date__c FROM Opportunity WHERE Id =: oppList[1].Id OR Id =: oppList[0].Id ];

            //Assert for result
            system.assertEquals(null , oppResultList[0].Next_Activity_Date__c );
            system.assertEquals(null , oppResultList[1].Next_Activity_Date__c );
        }
    }
	
    //Modified by Mahendra Swarnkar - 8/26/2016 - CR-20160606-9903
    //Test method to validate population of "Most Recent QA Call Date" field value on membership records
    static testMethod void testPopulateMostRecentQACallDate() {

        //Setting flag value to bypass manage package code execution while testing
        CRMfusionDBR101.DB_Globals.triggersDisabled = true;
        
        //Bypassing all triggers
        Util.byPassAllTriggers = true;
        Util.IsTest(true);

        //Account
        Account a = new Account(Name = 'testacct');
        insert a;

        //Program
        Program__c p = new Program__c(Name = 'testprog', Program_Acronym__c = 'test');
        insert p;

        //Membership
        Membership__c mem = new Membership__c(Account_Name__c = a.id, Program__c = p.id);
        insert mem;
        Membership__c mem2 = new Membership__c(Account_Name__c = a.id, Program__c = p.id);
        insert mem2;
        
        //Query the Event record type details
        List<RecordType> listEventRTypes = [Select Id, DeveloperName From RecordType 
                                                where SobjectType = 'Event' 
                                                AND IsActive = true 
                                                AND DeveloperName IN ('RI_QA_Call', 'BI_QA_Call')];
        Id eventPTRecordType;
        Id eventRIRecordType;
        if(listEventRTypes[0].DeveloperName == 'RI_QA_Call'){
            eventRIRecordType = listEventRTypes[0].Id;
            eventPTRecordType = listEventRTypes[1].Id;
        }
        else{
            eventRIRecordType = listEventRTypes[1].Id;
            eventPTRecordType = listEventRTypes[0].Id;
        }
            
        
        //Event
        List<Event> evntList = new List<Event>();

        //Setting date time variables
        DateTime DTStart = System.Now().addDays(Integer.valueOf(System.Label.POPULATE_MOST_RECENT_QA_CALL_ADD_DAYS)-2);
        Date DStart = DTStart.date();

        //Event s
        evntList.add(new Event(WhatId = mem.Id, recordTypeID = eventPTRecordType, StartDateTime = DTStart, ActivityDateTime = DTStart, ActivityDate = DStart, EndDateTime = DTStart, Event_Type__c = 'PT QA Call', Grade__c = 'C'));
        evntList.add(new Event(WhatId = mem.Id, recordTypeID = eventPTRecordType, StartDateTime = DTStart.addDays(-1), ActivityDateTime = DTStart.addDays(-1), ActivityDate = DStart.addDays(-1), EndDateTime = DTStart.addDays(-1), Event_Type__c = 'PT QA Call', Grade__c = 'C'));
        evntList.add(new Event( whatId = mem.Id, recordTypeID = eventRIRecordType, Event_Type__c = 'RI QA Call', Executive_Type__c = 'N/A', Grade__c = 'c', Would_Refer__c = '8', Would_Buy_Again__c = '9', 
                                StartDateTime = DTStart, ActivityDateTime = DTStart, ActivityDate = DStart, Project_Sponsor_On_Call__c = 'Yes',
                                EndDateTime = DTStart.addDays(1)));
        
        //Start testing from here
        Test.startTest();
        
        //Setting flag values and enabling triggers
        Util.byPassAllTriggers = false;
        OpportunityTriggerHelper.EXECUTE_TRIGGER_BEFORE_UPDATE = false;
        OpportunityTriggerHelper.EXECUTE_TRIGGER_AFTER_UPDATE = false;
        
        //Inserting the event records will execute the event trigger and that will update the membership data
        insert evntList;

        //Querying for membership record
        mem = [select Id, Most_Recent_QA_Call_Date__c FROM Membership__c where Id = :mem.id];

        //Asserting for the field value 
        System.assertEquals(DStart, mem.Most_Recent_QA_Call_Date__c);

        //Update the exisitng event
        evntList[0].WhatId = mem2.Id;
        evntList[1].recordTypeID = eventRIRecordType;
        evntList[2].Event_Type__c = 'CM QA Call';
        
        update evntList;

        //Querying for membership record
        mem = [select Id, Most_Recent_QA_Call_Date__c FROM Membership__c where Id = :mem.id];
        mem2 = [select Id, Most_Recent_QA_Call_Date__c FROM Membership__c where Id = :mem2.id];
        
        //Asserting for the field value
        System.assertEquals(DStart, mem.Most_Recent_QA_Call_Date__c);
        System.assertEquals(DStart, mem2.Most_Recent_QA_Call_Date__c);

        //Stop Test here
        Test.stopTest();
        
        //delete case
        delete evntList[0];

        //Querying for membership record
        mem = [select Id, Most_Recent_QA_Call_Date__c FROM Membership__c where Id = :mem.id];
        mem2 = [select Id, Most_Recent_QA_Call_Date__c FROM Membership__c where Id = :mem2.id];

        //Asserting for the field value
        System.assertEquals(DStart, mem.Most_Recent_QA_Call_Date__c);
        System.assertEquals(null, mem2.Most_Recent_QA_Call_Date__c);
    }
    
    //Modified By - Abhinav Sharma - CR-20151008-9304 - In order to fix 101 SOQL error occred in test class itself
    //Added By - Abhinav Sharma - 09/03/2015 - CR-20140613-5790
    static testMethod void testpopulatePAsAndActivityFieldsOnWarmLead() {
        
        //Bypassing all trigger so then test data can be easily created
        Util.byPassAllTriggers = true;
        Util.isTest(true);
        
        //Find user with Profile = System Administrator
        Profile sysAdminProfile = [Select id from Profile where Name = 'System Administrator' limit 1];
        
        //Create user
        User usr = new User(Alias = 'standt', Email='standarduser@testorg.com', EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                            LocaleSidKey='en_US', ProfileId = sysAdminProfile.Id, TimeZoneSidKey='America/Los_Angeles',UserName=Math.random()+'@testorg.com');
        
        //insert user
        insert usr;
        
        //Running test in context of system admin user
        System.runAs(usr) {
        
            //list to hold the opportunity records
            List<Opportunity> opportunities = new List<Opportunity>();
            
            // get one record type name
            List<Id> recordTypes = new List<Id>();
            recordTypes.add(Util.RecordTypeId('Opportunity',Constants.RECORD_TYPE_OPPORTUNITY_PT_CONTRACT_MAINTENANCE));
            
            Date todayDate = Date.newInstance(2015, 9, 4);
            DateTime todayDateTime = DateTime.newInstance(2015, 9, 4, 8, 6, 16);
            
            //Create Opportunity record
            Opportunity opportunity_1 = new Opportunity(Name = 'Opportunity Test1', StageName = 'Prospect', Amount = 4.00,
                                                         CloseDate = todayDate, RecordTypeId = recordTypes[0],
                                                         Initial_PA_Date__c = todayDate.addDays(3),
                                                         Competitor_Notes__c = 'Test 1'
                                                       );
            
            //Create Opportunity record
            Opportunity opportunity_2 = new Opportunity(Name = 'Opportunity Test2', StageName = 'Prospect', Amount = 4.00,
                                                         CloseDate = todayDate.addDays(4), RecordTypeId = recordTypes[0],
                                                         Initial_PA_Date__c = todayDate.addDays(2),
                                                         Initial_Activity_Date__c = todayDate.addDays(5),
                                                         Competitor_Notes__c = 'Test 2');
                                                         
            //Create Opportunity record
            Opportunity opportunity_3 = new Opportunity(Name = 'Opportunity Test3', StageName = 'Prospect', Amount = 4.00,
                                                         CloseDate = todayDate.addDays(4), RecordTypeId = recordTypes[0],
                                                         Initial_PA_Date__c = null, Initial_Activity_Date__c = null,
                                                         Competitor_Notes__c = 'Test 3');
            
            //Create Opportunity record
            Opportunity opportunity_4 = new Opportunity(Name = 'Opportunity Test4', StageName = 'Prospect', Amount = 4.00,
                                                         CloseDate = todayDate.addDays(4), RecordTypeId = recordTypes[0],
                                                         Initial_PA_Date__c = todayDate.addDays(5),
                                                         Initial_Activity_Date__c = todayDate.addDays(3),
                                                         Competitor_Notes__c = 'Test 4');
                                                         
            //Create Opportunity record
            Opportunity opportunity_5 = new Opportunity(Name = 'Opportunity Test5', StageName = 'Prospect', Amount = 4.00,
                                                         CloseDate = todayDate.addDays(4), RecordTypeId = recordTypes[0],
                                                         Initial_PA_Date__c = null, Competitor_Notes__c = 'Test 5',
                                                         Initial_Activity_Date__c = todayDate.addDays(5));
            
            //Adding records in the list
            opportunities.add(opportunity_1);
            opportunities.add(opportunity_2);
            opportunities.add(opportunity_3);
            opportunities.add(opportunity_4);
            opportunities.add(opportunity_5);
            
            //Disabling triggers
            Util.byPassAllTriggers = true;
            
            //insert Opprotunity
            insert opportunities;
            
            //Querying for opportunity records
            opportunities = [SELECT ID, Name, Initial_PA_Date__c, Initial_Activity_Date__c, Competitor_Notes__c FROM Opportunity
                                ORDER BY Competitor_Notes__c ASC];
            
            //Program__c prog = [select id from Program__c limit 1];
            Program__c prog = new Program__c(Name = 'TestProg', Program_Acronym__c = 'TEST', Status__c = 'Active', 
                                                Create_Memberships__c = 'Yes');
            
            //insert program
            Util.byPassAllTriggers = true;
            insert prog;
        
            //List to hold the warm lead records
            List<Warm_Lead__c> warmLeads = new List<Warm_Lead__c>();
            
            //Warm lead
            Warm_Lead__c warmLead_1 = new Warm_Lead__c(Name = 'Test Warm Lead 1', Grade__c = '1', Lead_Date__c = todayDate,
                                                        Lead_Channel__c = 'Breakout', Contact_level__c = 'CXO', Marketing_Associate_Assignment__c = usr.Id,
                                                        Marketer_Assignment__c = usr.Id, Status__c = 'Pending', 
                                                        Primary_Program__c = prog.Id);
            
            Warm_Lead__c warmLead_2 = new Warm_Lead__c(Name = 'Test Warm Lead 2', Grade__c = '2', Lead_Date__c = todayDate,
                                                        Lead_Channel__c = 'Breakout', Contact_level__c = 'CXO', 
                                                        Marketing_Associate_Assignment__c = usr.Id,
                                                        Marketer_Assignment__c = usr.Id, Status__c = 'Pending', 
                                                        Primary_Program__c = prog.Id);
                                                        
            //Adding records into the list
            warmLeads.add(warmLead_1);
            warmLeads.add(warmLead_2);
            
            //Disabling triggers
            Util.byPassAllTriggers = true;
            
            //insert warm leads
            insert warmLeads;
            
            //List to hold the warm lead record
            List<Warm_Lead_MtM__c> warmLeadMtMs = new List<Warm_Lead_MtM__c>(); 
            
            //Create WarmLeadMtM record
            Warm_Lead_MtM__c warmLeadMtM_1 = new Warm_Lead_MtM__c(Warm_Lead__c = warmLeads[0].Id, Opportunity__c = opportunities[0].Id);
        
            //Create WarmLeadMtM record
            Warm_Lead_MtM__c warmLeadMtM_3 = new Warm_Lead_MtM__c(Warm_Lead__c = warmLeads[1].Id, Opportunity__c = opportunities[1].Id);
            
            //Create WarmLeadMtM record
            Warm_Lead_MtM__c warmLeadMtM_2 = new Warm_Lead_MtM__c(Warm_Lead__c = warmLeads[0].Id, Opportunity__c = opportunities[2].Id);
            
            //Create WarmLeadMtM record
            Warm_Lead_MtM__c warmLeadMtM_4 = new Warm_Lead_MtM__c(Warm_Lead__c = warmLeads[0].Id, Opportunity__c = opportunities[3].Id);
            
            //Create WarmLeadMtM record
            Warm_Lead_MtM__c warmLeadMtM_5 = new Warm_Lead_MtM__c(Warm_Lead__c = warmLeads[1].Id, Opportunity__c = opportunities[4].Id);
            
            //Populating list with records
            warmLeadMtMs.add(warmLeadMtM_1);
            warmLeadMtMs.add(warmLeadMtM_2);
            warmLeadMtMs.add(warmLeadMtM_3);
            warmLeadMtMs.add(warmLeadMtM_4);
            warmLeadMtMs.add(warmLeadMtM_5);
            
            //Disabling triggers
            Util.byPassAllTriggers = true;
            
            //Insert Warm lead Mtm's
            insert warmLeadMtMs;
            
            //Warm Lead MTMs
            warmLeadMtMs = [SELECT ID, Opportunity_Initial_PA__c, Opportunity_Initial_Activity__c, Opportunity__c,
                                Opportunity__r.Competitor_Notes__c FROM Warm_Lead_MtM__c
                                WHERE Opportunity__c != null ORDER BY Opportunity__c ASC];
            
            //Asserting for the results
            System.assertEquals(5, warmLeadMtMs.size());
            System.assertEquals(null, warmLeadMtMs[0].Opportunity_Initial_PA__c);
            System.assertEquals(null, warmLeadMtMs[0].Opportunity_Initial_Activity__c);
            System.assertEquals(null, warmLeadMtMs[1].Opportunity_Initial_PA__c);
            System.assertEquals(null, warmLeadMtMs[1].Opportunity_Initial_Activity__c);
            System.assertEquals(null, warmLeadMtMs[2].Opportunity_Initial_PA__c);
            System.assertEquals(null, warmLeadMtMs[2].Opportunity_Initial_Activity__c);
            System.assertEquals(null, warmLeadMtMs[3].Opportunity_Initial_PA__c);
            System.assertEquals(null, warmLeadMtMs[3].Opportunity_Initial_Activity__c);
            System.assertEquals(null, warmLeadMtMs[3].Opportunity_Initial_PA__c);
            System.assertEquals(null, warmLeadMtMs[3].Opportunity_Initial_Activity__c);            
            
            //List of event records
            List<Event> events = new List<Event>();
            
            //Event 1
            Event evt_1 = new Event(WhatId = opportunities[0].Id, StartDateTime = todayDateTime, 
                                    Cancelled_Did_Not_Occur__c = false,
                                    EndDateTime = todayDateTime.addHours(1), 
                                    Event_Type__c = 'Phone Appointment', Event_Purpose__c = 'Initial');
            Event evt_2 = new Event(WhatId = opportunities[1].Id, StartDateTime = todayDateTime.addDays(2), 
                                    Cancelled_Did_Not_Occur__c = false,
                                    EndDateTime = todayDateTime.addHours(1).addDays(2), 
                                    Event_Type__c = 'Phone Appointment', Event_Purpose__c = 'Intro PA');
            Event evt_3 = new Event(WhatId = opportunities[2].Id, StartDateTime = todayDateTime.addDays(-2), 
                                    Cancelled_Did_Not_Occur__c = false,
                                    EndDateTime = todayDateTime.addHours(1).addDays(-2), 
                                    Event_Type__c = 'In Person Visit', Event_Purpose__c = 'Initial');
            Event evt_4 = new Event(WhatId = opportunities[3].Id, StartDateTime = todayDateTime, 
                                    Cancelled_Did_Not_Occur__c = false,
                                    EndDateTime = todayDateTime.addHours(1), 
                                    Event_Type__c = 'Additional Contact Meeting', Event_Purpose__c = 'Initial');
            Event evt_5 = new Event(WhatId = opportunities[4].Id, StartDateTime = todayDateTime.addDays(-400), 
                                    Cancelled_Did_Not_Occur__c = true,
                                    EndDateTime = todayDateTime.addHours(1).addDays(-400), 
                                    Event_Type__c = 'Phone Appointment', Event_Purpose__c = 'Initial');
            Event evt_6 = new Event(WhatId = opportunities[0].Id, StartDateTime = todayDateTime, 
                                    Cancelled_Did_Not_Occur__c = false,
                                    EndDateTime = todayDateTime.addHours(1), 
                                    Event_Type__c = 'Phone Appointment', Event_Purpose__c = 'Follow Up');
            Event evt_7 = new Event(WhatId = opportunities[1].Id, StartDateTime = todayDateTime, 
                                    Cancelled_Did_Not_Occur__c = false,
                                    EndDateTime = todayDateTime.addHours(1), 
                                    Event_Type__c = 'Additional Contact Meeting', Event_Purpose__c = 'Follow Up');
            Event evt_8 = new Event(WhatId = opportunities[2].Id, StartDateTime = todayDateTime, 
                                    Cancelled_Did_Not_Occur__c = false,
                                    EndDateTime = todayDateTime.addHours(1), 
                                    Event_Type__c = 'In Person Visit', Event_Purpose__c = 'Initial');
            Event evt_9 = new Event(WhatId = opportunities[3].Id, StartDateTime = todayDateTime.addDays(110), 
                                    Cancelled_Did_Not_Occur__c = false,
                                    EndDateTime = todayDateTime.addHours(1).addDays(110), 
                                    Event_Type__c = 'Phone Appointment', Event_Purpose__c = 'Initial');
            Event evt_10 = new Event(WhatId = opportunities[4].Id, StartDateTime = todayDateTime.addDays(-10), 
                                    Cancelled_Did_Not_Occur__c = false,
                                    EndDateTime = todayDateTime.addHours(1).addDays(-10), 
                                    Event_Type__c = 'Phone Appointment', Event_Purpose__c = 'Intro PA');
            
            //Adding records into the list
            events.add(evt_1);
            events.add(evt_2);
            events.add(evt_3);
            events.add(evt_4);
            events.add(evt_5);
            events.add(evt_6);
            events.add(evt_7);
            events.add(evt_8);
            events.add(evt_9);
            events.add(evt_10);
            
            //Test will start from here
            Test.startTest();
            
            //Disabling triggers and setting flag value
            Util.byPassAllTriggers = false;
            OpportunityTriggerHelper.EXECUTE_TRIGGER_BEFORE_UPDATE = false;
            OpportunityTriggerHelper.EXECUTE_TRIGGER_AFTER_UPDATE = false;
            
            //Insert events
            insert events;
            
            //Querying for opportunity records
            opportunities = [SELECT ID, Name, Initial_PA_Date__c, Initial_Activity_Date__c 
                             FROM Opportunity
                             ORDER BY Competitor_Notes__c ASC];
            
            //Asserts for the results
            System.assertEquals(5, opportunities.size());
            
            System.assertEquals(todayDate, opportunities[0].Initial_PA_Date__c);
            System.assertEquals(todayDate, opportunities[0].Initial_Activity_Date__c);
            
            System.assertEquals(todayDate.addDays(2), opportunities[1].Initial_PA_Date__c);
            System.assertEquals(todayDate.addDays(2), opportunities[1].Initial_Activity_Date__c);
            
            System.assertEquals(null, opportunities[2].Initial_PA_Date__c);
            System.assertEquals(todayDate.addDays(-2), opportunities[2].Initial_Activity_Date__c);
            
            System.assertEquals(todayDate.addDays(110), opportunities[3].Initial_PA_Date__c);
            System.assertEquals(todayDate.addDays(110), opportunities[3].Initial_Activity_Date__c);
            
            System.assertEquals(todayDate.addDays(-10), opportunities[4].Initial_PA_Date__c);
            System.assertEquals(todayDate.addDays(-10), opportunities[4].Initial_Activity_Date__c);
             
            //Stop Test here
            Test.stopTest();
            
            //Disabling triggers and setting flag value
            Util.byPassAllTriggers = false;
            OpportunityTriggerHelper.EXECUTE_TRIGGER_BEFORE_UPDATE = false;
            OpportunityTriggerHelper.EXECUTE_TRIGGER_AFTER_UPDATE = false;
            
            //delete events
            List<Event> eventsToDeleteOrUpdate = new List<Event>();
            eventsToDeleteOrUpdate.add(events[0]);
            eventsToDeleteOrUpdate.add(events[6]);
            eventsToDeleteOrUpdate.add(events[7]);
            eventsToDeleteOrUpdate.add(events[8]);
            eventsToDeleteOrUpdate.add(events[9]);
            delete eventsToDeleteOrUpdate;
            
            //Querying for opportunity records
            opportunities = [SELECT ID, Name, Initial_PA_Date__c, Initial_Activity_Date__c
                             FROM Opportunity
                             ORDER BY Competitor_Notes__c ASC];
            
            //Asserts for the results
            System.assertEquals(5, opportunities.size());
            
            System.assertEquals(null, opportunities[0].Initial_PA_Date__c);
            System.assertEquals(null, opportunities[0].Initial_Activity_Date__c);
            
            System.assertEquals(todayDate.addDays(2), opportunities[1].Initial_PA_Date__c);
            System.assertEquals(todayDate.addDays(2), opportunities[1].Initial_Activity_Date__c);
            
            System.assertEquals(null, opportunities[2].Initial_PA_Date__c);
            System.assertEquals(todayDate.addDays(-2), opportunities[2].Initial_Activity_Date__c);
            
            System.assertEquals(null, opportunities[3].Initial_PA_Date__c);
            System.assertEquals(null, opportunities[3].Initial_Activity_Date__c);
            
            System.assertEquals(null, opportunities[4].Initial_PA_Date__c);
            System.assertEquals(null, opportunities[4].Initial_Activity_Date__c);
                                
            //Update events
            events[5].Event_Purpose__c = 'Initial';
            events[4].Cancelled_Did_Not_Occur__c = false;
            events[2].Event_Purpose__c = 'Intro PA';
            events[1].StartDateTime = todayDateTime.addDays(360);
            events[1].EndDateTime = todayDateTime.addDays(360).addHours(1);
                                
            eventsToDeleteOrUpdate = new List<Event>();  
            eventsToDeleteOrUpdate.add(events[5]);
            eventsToDeleteOrUpdate.add(events[4]);
            eventsToDeleteOrUpdate.add(events[2]);
            eventsToDeleteOrUpdate.add(events[1]);
            OpportunityTriggerHelper.EXECUTE_TRIGGER_BEFORE_UPDATE = false;
            OpportunityTriggerHelper.EXECUTE_TRIGGER_AFTER_UPDATE = false;
            update eventsToDeleteOrUpdate;
                                
            //Querying for opportunity records
            opportunities = [SELECT ID, Name, Initial_PA_Date__c, Initial_Activity_Date__c 
                             FROM Opportunity
                             ORDER BY Competitor_Notes__c ASC];
            
            //Asserts for the results
            System.assertEquals(5, opportunities.size());
            
            System.assertEquals(todayDate, opportunities[0].Initial_PA_Date__c);
            System.assertEquals(todayDate, opportunities[0].Initial_Activity_Date__c);
            
            System.assertEquals(todayDate.addDays(360), opportunities[1].Initial_PA_Date__c);
            System.assertEquals(todayDate.addDays(360), opportunities[1].Initial_Activity_Date__c);
            
            System.assertEquals(null, opportunities[2].Initial_PA_Date__c);
            System.assertEquals(todayDate.addDays(-2), opportunities[2].Initial_Activity_Date__c);
            
            System.assertEquals(null, opportunities[3].Initial_PA_Date__c);
            System.assertEquals(null, opportunities[3].Initial_Activity_Date__c);
            
            System.assertEquals(todayDate.addDays(-400), opportunities[4].Initial_PA_Date__c);
            System.assertEquals(todayDate.addDays(-400), opportunities[4].Initial_Activity_Date__c);
        }
    } 
    
   //Added By - Abhinav Sharma - 09/07/2015 - CR-20140613-9161
   static testMethod void updateEventHistoryTrackingFields() {
        
        //Bypassing all trigger so then test data can be easily created
        Util.byPassAllTriggers = true;
        Util.isTest(true);
        
        //Find user with Profile = System Administrator
        Profile sysAdminProfile = [Select id from Profile where Name = 'System Administrator' limit 1];
        
        //Create user
        User usr = new User(Alias = 'standt', Email='standarduser@testorg.com', EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                            LocaleSidKey='en_US', ProfileId = sysAdminProfile.Id, TimeZoneSidKey='America/Los_Angeles',UserName=Math.random()+'@testorg.com');
        
        //insert user
        insert usr;
        
        //Running test in context of system admin user
        System.runAs(usr) {
        
            //Account
            Account a = new Account(Name = 'testacct');
            insert a;
    
            //Program
            Program__c p = new Program__c(Name = 'testprog', Program_Acronym__c = 'test');
            insert p;
        
            //Membership
            Membership__c mem = new Membership__c(Account_Name__c = a.id, Program__c = p.id);
            insert mem;
            
            //Event
            List<Event> evntList = new List<Event>();
    
            //Setting date time variables
            DateTime DTStart = System.Now().addDays(62);
            Date DStart = DTStart.date();
            
            //Query through Opportunity RecordTypes
            List<RecordType> recordTypes = [SELECT Id , DeveloperName FROM RecordType 
                                                WHERE (DeveloperName = 'BI_Marketing' OR DeveloperName = 'BI_QA_Call') 
                                                AND SObjectType = 'Event' AND IsActive = true];

            //Event s
            evntList.add(new Event(OwnerId = usr.Id, WhatId = mem.Id, RecordTypeId = recordTypes[0].Id, StartDateTime = System.Now().addDays(-10), 
                                    Cancelled_Did_Not_Occur__c = false, Initial_Start_Date_Time__c = null,
                                    EndDateTime = System.Now().addHours(1), Event_Type__c = 'In Person Visit', Executive_Type__c = 'CXO'));
            evntList.add(new Event(OwnerId = usr.Id, WhatId = mem.Id, RecordTypeId = recordTypes[0].Id, StartDateTime = System.Now().addDays(-10), 
                                    Cancelled_Did_Not_Occur__c = false, Initial_Start_Date_Time__c = null,
                                    EndDateTime = System.Now().addHours(1), Event_Type__c = 'In Person Visit', Executive_Type__c = 'CXO'));
    
            //Start testing from here
            Test.startTest();
    
            //Inserting the event records will execute the event trigger and that will update the membership data
            insert evntList;
            
            //update event
            evntList[0].StartDateTime = System.Today().addDays(4);
            evntList[0].EndDateTime =   System.Today().addDays(4);
            evntList[0].EndDateTime = evntList[0].EndDateTime.addHours(1);
            
            //Setting flag values and enabling triggers
            Util.byPassAllTriggers = false;
            OpportunityTriggerHelper.EXECUTE_TRIGGER_BEFORE_UPDATE = false;
            OpportunityTriggerHelper.EXECUTE_TRIGGER_AFTER_UPDATE = false;

            //update event list
            update evntList;
            
            //List or query result
            List<Event> listEvent = [Select Id , Start_Date_Time_Last_Modified_Date__c,of_Times_Start_Date_Time_Updated__c ,Cancelled_Did_Not_Occur_Last_Modify_Date__c
                                                                FROM Event WHERE WhatId =: mem.Id and Id =: evntList[0].Id];
            
            //assert here                                                   
            system.assertEquals(1, listEvent[0].of_Times_Start_Date_Time_Updated__c);
            system.assertEquals(null, listEvent[0].Cancelled_Did_Not_Occur_Last_Modify_Date__c);
            
            //Test stop here
            Test.stopTest();
            
            //Enable triggers
            util.byPassAlltriggers = true;
            
            //update event
            evntList[0].StartDateTime = System.Today().addDays(6);
            evntList[0].EndDateTime =   System.Today().addDays(6);
            evntList[0].EndDateTime = evntList[0].EndDateTime.addHours(1);
            evntList[0].Cancelled_Did_Not_Occur__c = true;
            
            //Enable triggers
            Util.byPassAlltriggers = false;
            
            //update event list
            update evntList;
            
            //Query list of event
            listEvent = [Select Id , Start_Date_Time_Last_Modified_Date__c,of_Times_Start_Date_Time_Updated__c,
                            Cancelled_Did_Not_Occur_Last_Modify_Date__c
                            FROM Event WHERE WhatId =: mem.Id and Id =: evntList[0].Id];
            
            //assert here
            system.assertEquals(2, listEvent[0].of_Times_Start_Date_Time_Updated__c);
        }
    }
    
    //Added By - Abhinav Sharma - 11/25/2015 - CR-20150929-9281
    static testMethod void testPopulateinitialStartDate() {
        
        //Bypassing all trigger so then test data can be easily created
        Util.byPassAllTriggers = true;
        Util.isTest(true);
        
        //Find user with Profile = System Administrator
        Profile sysAdminProfile = [Select id from Profile where Name = 'System Administrator' limit 1];
        
        //Create user
        User usr = new User(Alias = 'standt', Email='standarduser@testorg.com', EmailEncodingKey='UTF-8', LastName='Testing', 
                            LanguageLocaleKey='en_US',
                            LocaleSidKey='en_US', ProfileId = sysAdminProfile.Id, 
                            TimeZoneSidKey='America/Los_Angeles',UserName=Math.random()+'@testorg.com');
        
        //insert user
        insert usr;
        
        //Running test in context of system admin user
        System.runAs(usr) {
        
            //Account
            Account a = new Account(Name = 'testacct');
            insert a;
    
            //Program
            Program__c p = new Program__c(Name = 'testprog', Program_Acronym__c = 'test');
            insert p;
        
            //Membership
            Membership__c mem = new Membership__c(Account_Name__c = a.id, Program__c = p.id);
            insert mem;
            
            //Event
            List<Event> evntList = new List<Event>();
    
            //Setting date time variables
            DateTime DTStart = System.Now().addDays(62);
            Date DStart = DTStart.date();
            
            //Query through Opportunity RecordTypes
            List<RecordType> recordTypes = [SELECT Id , DeveloperName FROM RecordType 
                                                WHERE (DeveloperName = 'BI_Marketing' OR DeveloperName = 'BI_QA_Call') 
                                                AND SObjectType = 'Event' AND IsActive = true];

            //Event s
            evntList.add(new Event(OwnerId = usr.Id, WhatId = mem.Id, RecordTypeId = recordTypes[0].Id, 
                                    StartDateTime = System.now().addDays(-10), 
                                    Cancelled_Did_Not_Occur__c = false, Initial_Start_Date_Time__c = null,
                                    EndDateTime = System.now().addHours(1), Event_Type__c = 'Testing', 
                                    Executive_Type__c = 'CXO'));
            evntList.add(new Event(OwnerId = usr.Id, WhatId = mem.Id, RecordTypeId = recordTypes[0].Id, 
                                   StartDateTime = System.now().addDays(-10), 
                                   Cancelled_Did_Not_Occur__c = false, 
                                   Initial_Start_Date_Time__c = null,
                                   EndDateTime = System.now().addHours(1), 
                                   Event_Type__c = 'In Person Visit', Executive_Type__c = 'CXO'));
            
            //Start Test from here
            Test.startTest();
            
            //Enabling triggers again
            Util.byPassAllTriggers = false;
            
            //Insert events
            insert evntList;
            
            //Querying for the results and applying asserts
            evntList = [SELECT ID, Event_Type__c, Initial_Start_Date_Time__c, StartDateTime
                            FROM Event ORDER BY Event_Type__c ASC];
            
            //Asserting for the results
            System.assertEquals('In Person Visit', evntList[0].Event_Type__c);
            System.assertEquals('Testing', evntList[1].Event_Type__c);
            System.assertEquals(evntList[0].StartDateTime, evntList[0].Initial_Start_Date_Time__c);
            System.assertEquals(null, evntList[1].Initial_Start_Date_Time__c);
            
            //Updating event
            evntList[0].StartDateTime = System.now();
            evntList[1].Event_Type__c = 'In Person Visit';
            update evntList;
            
            //Querying for the results and applying asserts
            evntList = [SELECT ID, Event_Type__c, Initial_Start_Date_Time__c, StartDateTime
                            FROM Event ORDER BY StartDateTime ASC];
            
            //Asserting for the results
            System.assertEquals('In Person Visit', evntList[0].Event_Type__c);
            System.assertEquals('In Person Visit', evntList[1].Event_Type__c);
            System.assert(evntList[0].Initial_Start_Date_Time__c != null);
            System.assert(evntList[1].Initial_Start_Date_Time__c != null);
            System.assertNotEquals(System.now(), evntList[0].Initial_Start_Date_Time__c);
            System.assertNotEquals(evntList[1].StartDateTime, evntList[1].Initial_Start_Date_Time__c);
            
            //Stop Test here
            Test.stopTest();
        }        
    }
    
    //Added By - Mahendra Swarnkar - 2/9/2016 - CR-20151221-9474
    static testMethod void testpopulateVisitActivityField() {
        
        //Bypassing all trigger so then test data can be easily created
        Util.byPassAllTriggers = true;
        Util.isTest(true);
        
        //Find user with Profile = System Administrator
        Profile sysAdminProfile = [Select id from Profile where Name = 'System Administrator' limit 1];
        
        //Create user
        User usr = new User(Alias = 'standt', Email='standarduser@testorg.com', EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                            LocaleSidKey='en_US', ProfileId = sysAdminProfile.Id, TimeZoneSidKey='America/Los_Angeles',UserName=Math.random()+'@testorg.com');
        
        //insert user
        insert usr;
        
        //Running test in context of system admin user
        System.runAs(usr) {
            
            //Create account records
            List<Account> accList = new list<Account>();
            accList.add(new Account(Name = 'Test_Account1', Account_Formal_Name__c = 'TestAccount1 ascbamdvlamcajzxmmzxjsjzxczxmczmzmxzmxzmxjjncnncncncncnnvvnvnvnvnvnvnvnvnvnvnnvnvnvnvnvnvnvnvnvncscnscknjsncknsjnjscnjncjncnmnmznxmzmnxzmnmznxmznxzmnmznxmznmnxmznxmzxnmznxmzxnmzxnmznxmzxnzmnxmznxzmnxmzxnmzxnmznxmznmnxjhshdgdncnnccnbvhdkjcmcjv' ));
            accList.add(new Account(Name = 'Test_Account2', Account_Formal_Name__c = 'TestAccountFormalName2' ));
            
            //Insert Account records
            insert accList;
            
            //Assert for the results
            System.assert(accList != null);
            System.assertEquals(2, accList.size());
            
            //list to hold the opportunity records
            List<Opportunity> opportunities = new List<Opportunity>();
            
            // get one record type name
            List<Id> recordTypes = new List<Id>();
            recordTypes.add(Util.RecordTypeId('Opportunity',Constants.RECORD_TYPE_OPPORTUNITY_PT_CONTRACT_MAINTENANCE));
            
            //Create Opportunity record
            opportunities.add(new Opportunity(Name = 'Opportunity Test1', StageName = 'Prospect', Amount = 4.00,
                                              AccountId = accList[0].Id, CloseDate = system.today(),    
                                              RecordTypeId = recordTypes[0]));
            opportunities.add(new Opportunity(Name = 'Opportunity Test2', StageName = 'Prospect', Amount = 4.00,
                                              AccountId = accList[1].Id, CloseDate = system.today().addDays(4), 
                                              RecordTypeId = recordTypes[0]));
            
            //Disabling triggers
            Util.byPassAllTriggers = true;
            
            //insert Opprotunities
            insert opportunities;
            
            //Assert for the results
            System.assert(opportunities != null);
            System.assertEquals(2, opportunities.size());
            
            //Create Event records
            List<Event> events = new List<Event>();
            events.add(new Event(WhatId = opportunities[0].Id, StartDateTime = system.now(),
                                 EndDateTime = system.now().addHours(1), 
                                 Event_Type__c = 'Phone Appointment', Event_Purpose__c = 'Initial'));
            events.add(new Event(WhatId = opportunities[1].Id, StartDateTime = system.now(),
                                 EndDateTime = system.now().addHours(1), 
                                 Event_Type__c = 'Phone Appointment', Event_Purpose__c = 'Initial'));
            
            //Test will start from here
            Test.startTest();
            
            //Disabling triggers and setting flag value
            Util.byPassAllTriggers = false;
            
            //Insert events
            insert events;
            
            //Querying for event records
            events = [SELECT ID, Visit__c, WhatID, EndDateTime FROM Event];
            
            //Querying for opportunity records
            Map<Id,Opportunity> mapOpp  = new Map<Id,Opportunity>([SELECT ID, Name, Account.Account_Formal_Name__c 
                                                                   FROM Opportunity]);
            
            //Asserts for the results
            System.assertEquals(2, events.size());
            
            //String to hold expected Visit fields value for events[0]
            String str = ((String.valueOf(events[0].EndDateTime.month()).length() == 1 ? '0' + String.valueOf(events[0].EndDateTime.month()) : String.valueOf(events[0].EndDateTime.month())) +  
                                '/' + (String.valueOf(events[0].EndDateTime.day()).length() == 1 ? '0' + String.valueOf(events[0].EndDateTime.day()) : String.valueOf(events[0].EndDateTime.day())) + 
                                '/' + events[0].EndDateTime.year() + ' - ' + mapOpp.get(events[0].WhatId).Account.Account_Formal_Name__c).trim();
            
            //Assert for the result
            System.assertEquals(str.length() > Integer.valueOf(Label.EVENT_VISIT_MAX_ALLOWED_LENGTH) ? str.substring(0, Integer.valueOf(Label.EVENT_VISIT_MAX_ALLOWED_LENGTH)) : str, events[0].Visit__c);
             
            //String to hold expected Visit fields value for events[1]
            str = ((String.valueOf(events[1].EndDateTime.month()).length() == 1 ? '0' + String.valueOf(events[1].EndDateTime.month()) : String.valueOf(events[1].EndDateTime.month())) +  
                                '/' + (String.valueOf(events[1].EndDateTime.day()).length() == 1 ? '0' + String.valueOf(events[1].EndDateTime.day()) : String.valueOf(events[1].EndDateTime.day())) + 
                                '/' + events[1].EndDateTime.year() + ' - ' + mapOpp.get(events[1].WhatId).Account.Account_Formal_Name__c).trim();
            
            //Assert for the result                    
            System.assertEquals( str.length() > Integer.valueOf(Label.EVENT_VISIT_MAX_ALLOWED_LENGTH) ? str.substring(0, Integer.valueOf(Label.EVENT_VISIT_MAX_ALLOWED_LENGTH)) : str, events[1].Visit__c);
  
           //Stop Test here
           Test.stopTest(); 
        }
    } 
}