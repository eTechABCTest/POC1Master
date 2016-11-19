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
private class Test_EventDetailsForOutlook {
/**
    Purpose:    Test class for EventDetailsForOutlook controller.-  CR-20111219-286
    
    Create By:  Simplyforce Technology
    
    Created Date:   12/23/2011
    
    Current Version:    v1.0
    
    Revision Log:
    
 **/
 
    
    static testmethod void myUnitTest() { 
        //Bypass Dupeblocker
        Util.IsTest(true);
        
        //Create test data
        Account account = new Account(Name = 'TestAccount');
        insert account;
        
        //Create contact
        Contact contact = new Contact(LastName = 'LastName', AccountId = account.Id);
        insert contact;
        
        //insert Opportunity
        Opportunity opportunity = new Opportunity(Name = 'TestOpportunity', AccountId = account.Id, StageName = 'testSatge', CloseDate = Date.toDay());
        insert opportunity;
        
        //Create event record
        Event event = new Event(Subject = 'TestEvent', WhatId = opportunity.Id, WhoId = contact.Id, DurationInMinutes = 1000, ActivityDateTime = DateTime.now());
        insert event;
        
        //start test from here
        Test.startTest();
        
        //instantiate controller
        EventDetailsForOutlook controller = new EventDetailsForOutlook(new ApexPages.StandardController(event));
        
        //assert results
        System.assertEquals(contact.Id, controller.contact.Id);
        System.assertEquals(opportunity.Id, controller.opportunity.Id);
        
        //stop test here
        Test.stopTest();
    }
}