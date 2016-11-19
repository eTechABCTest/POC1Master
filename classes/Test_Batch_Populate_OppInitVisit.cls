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
private class Test_Batch_Populate_OppInitVisit {

    static testMethod void testBatch_PopulateOppInitVisit() {
        
        util.BypassAllTriggers = true;
        // create an opp with initial visit date
        Opportunity opp = TestUtilities.CreateNewOpportunity(false);
        opp.Initial_Visit_Date__c = system.today().addDays(-5);
        insert opp;
        
        // create 2 events and 2 tasks
        Task tsk1 = new Task(
                            Subject = 'test',
                            ActivityDate = system.today(),
                            Event_Type__c = 'In Person Visit',
                            Event_Purpose__c = 'Initial',
                            WhatId = opp.Id
                        );
        Task tsk2 = new Task(
                            Subject = 'test',
                            ActivityDate = system.today(),
                            Event_Type__c = 'In Person Visit',
                            Event_Purpose__c = 'Initial',
                            WhatId = opp.Id
                        );
        
        Event evt1 = new Event(
                                whatId = opp.Id,
                                StartDateTime = system.today().addDays(-4),
                                ActivityDateTime = system.today().addDays(-4),
                                ActivityDate = system.today().addDays(-4),
                                Cancelled_Did_Not_Occur__c = false,
                                EndDateTime = system.today().addDays(-4),
                                Event_Type__c = 'In Person Visit',
                                Event_Purpose__c = 'Initial'
                            );
        Event evt2 = new Event(
                                whatId = opp.Id,
                                StartDateTime = system.today().addDays(-4),
                                ActivityDateTime = system.today().addDays(-4),
                                ActivityDate = system.today().addDays(-4),
                                Cancelled_Did_Not_Occur__c = false,
                                EndDateTime = system.today().addDays(-4),
                                Event_Type__c = 'In Person Visit',
                                Event_Purpose__c = 'Initial'
                            );
        
        list<Task> tasks = new list<Task> { tsk1, tsk2 };
        list<Event> events = new list<Event> { evt1, evt2 };
        
        insert tasks;
        insert events;
        
        Util.BypassAllTriggers = false;
        
        test.startTest();
        
        // execute the batch for events and tasks
        Batch_Populate_OppInitVisit batch = new Batch_Populate_OppInitVisit();
        batch.isEvent = true;
        database.executeBatch(batch);
        
        batch.isEvent = false;
        database.executeBatch(batch);
        
        test.stopTest();
        
        // get the events
        events = [SELECT Id, Opp_Initial_Visit_Date__c, StartDateTime FROM Event WHERE Id IN :events];
        
        for (Event e : events) {
            
            system.assertEquals(opp.Initial_Visit_Date__c, e.Opp_Initial_Visit_Date__c);
        }
        
        // get the tasks
        tasks = [SELECT Id, Opp_Initial_Visit_Date__c, ActivityDate FROM Task WHERE Id IN :Tasks];
        
        for (Task t : tasks) {
            
            system.assertEquals(opp.Initial_Visit_Date__c, t.Opp_Initial_Visit_Date__c);
        }
    }
}