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
 /**
 *  Desription      :   Test class for Venue Trigger
 * 
 *  Created By      :   
 * 
 *  Created Date    :   4/27/2015
 * 
 *  Revision Logs   :   V1.0 - Created
 *						V2.0 - Modified - Mahendra swarnkar - 9/3/2016 - CR-20160126-9564.
 *
 *	Code Covrage	:	V1.0 - Created
 *						V2.0 - 98%
 *
 **/
@isTest
private class Test_TriggerVenue {
    
	//test update Staff rate on the Team Member
    static testMethod void testUpdateStaffRateOnTeamMembers() {
        
        //Bypassing triggers
        Util.isTest(true);
        Util.BypassAllTriggers = true;
       
        //Account's Venuue record type Id
        Id acctVenueRTId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Vendor or Venue').getRecordTypeId();
        System.assert(acctVenueRTId != null);
        
		//Account  
        Account accountVenue = new Account(Name = 'Test Acc', Account_Formal_Name__c = 'Test', Type = 'Hotel', Accommodations__c = true, Event_Venue__c = true, RecordTypeId=acctVenueRTId);
        insert accountVenue;
        
        //Create Parent event records
        Advisory_Event__c event = testUtilities.createEvent(Constants.RECORD_TYPE_ID_ADV_EVENT_EVENT, null, true);
        System.assert(event != null);
        
        //Bypassing triggers
        Util.BypassAllTriggers = false;
        
        //List of team members
		List<Team_Member__c> listTeamMembers = [SELECT Id, Staff_Rate__c FROM Team_Member__c 
                                                	WHERE Advisory_Event__c != null AND 
                                                			Advisory_Event__c =: event.ID]; 
        System.assert(listTeamMembers.size() > 0);
        system.assertEquals(null, listTeamMembers[0].Staff_Rate__c);
        
        //Bypassing triggers again
        Util.BypassAllTriggers = true;
        
        //Set of recordtype developernames
        Set<String> rdTypesDeveloperNames = new Set<String>();
        rdTypesDeveloperNames.add(VenueTriggerHelper.EVENT_VENUE_AND_ACCOMODATION_RdTYPE);
        rdTypesDeveloperNames.add(VenueTriggerHelper.ACCOMODATIONS_RdTYPES);
        
        //Map to hold event venue record types as a value and record types developerName as a key
        Map<String, RecordType> mapVenueRecordTypes = new Map<String, RecordType>();
        	
        //loop through recordtypes
        for(RecordType  rType : [Select Id, DeveloperName From RecordType 
                                 Where SobjectType = 'Venue__c' AND IsActive = True 
                                 AND RecordType.DeveloperName IN : rdTypesDeveloperNames])
        	mapVenueRecordTypes.put(rType.DeveloperName, rType);
        
        //Asserting for the results
        System.assert(mapVenueRecordTypes != null);
        System.assertEquals(2, mapVenueRecordTypes.values().size());

        //Start test from here
        Test.startTest();
        
        //Enabling trigger again
        Util.BypassAllTriggers = false;
        
        //Create a Venue record
        Venue__c venue0 = new Venue__c(Name = 'Test', 
                                      RecordTypeId = mapVenueRecordTypes.get(VenueTriggerHelper.ACCOMODATIONS_RdTYPES).Id,
                                      Advisory_Event__c = event.Id,
                                      Staff_Rate__c = 121,
                                      Venue__c = accountVenue.Id);
        insert venue0;
        
        //Asserting for the results
        listTeamMembers =[SELECT Id, Staff_Rate__c FROM Team_Member__c WHERE Advisory_Event__c =: event.ID limit 1];
        System.assert(listTeamMembers != null);
        system.assertEquals(121, listTeamMembers[0].Staff_Rate__c);
        
        //Create a Venue record
        Venue__c venue1 = new Venue__c(Name = 'Test', 
                                      RecordTypeId = mapVenueRecordTypes.get(VenueTriggerHelper.EVENT_VENUE_AND_ACCOMODATION_RdTYPE).ID,
                                      Advisory_Event__c = event.Id, 
                                      Staff_Rate__c = 122,
                                      Venue__c = accountVenue.Id);
        
        //Create a Venue record
        Venue__c venue2 = new Venue__c(Name = 'Test', 
                                      RecordTypeId = mapVenueRecordTypes.get(VenueTriggerHelper.ACCOMODATIONS_RdTYPES).ID,
                                      Advisory_Event__c = event.Id, 
                                      Staff_Rate__c = 123,
                                      Venue__c = accountVenue.Id);
        
        //list of venues
        List<Venue__c> listVenues = new List<Venue__c>();
        
        //Populating list with records instances
        listVenues.add(venue1);
        listVenues.add(venue2);
        
        //Make a try to insert venue records
        insert listVenues;
        
        //Asserting for results
        listTeamMembers =[SELECT Id, Staff_Rate__c FROM Team_Member__c WHERE Advisory_Event__c =: event.ID limit 1];
        System.assert(listTeamMembers != null);
        system.assertEquals(122, listTeamMembers[0].Staff_Rate__c);
        
        //Updating venue record staff rate value
        venue0.Staff_Rate__c = 126;
        update venue0;
        
        //Asserting for results
        listTeamMembers =[SELECT Id, Staff_Rate__c FROM Team_Member__c WHERE Advisory_Event__c =: event.ID limit 1];
        system.assertEquals(122, listTeamMembers[0].Staff_Rate__c);
        
        //Delete records
        listVenues = [SELECT ID FROM Venue__c];
        delete listVenues;
        
        //Asserting for the results
        listTeamMembers =[SELECT Id, Staff_Rate__c FROM Team_Member__c WHERE Advisory_Event__c =: event.ID limit 1];
        system.assertEquals(null, listTeamMembers[0].Staff_Rate__c);
        
        //Stop Test here
        Test.stopTest();
    }
    
    //Modified - Mahendra swarnkar - 9/3/2016 - CR-20160126-9564.
    //test validatePrimaryVenue and updateMeeting
    static testMethod void testValidatePrimaryVenueWhenNoVenueExistAlready() {
    	
        Id acctVenueRTId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Vendor or Venue').getRecordTypeId();
        
        //Account
        Account parentAccount = new Account(Name = 'Test Acc', Account_Formal_Name__c = 'Test', Type = 'Hotel', Accommodations__c = true, Event_Venue__c = true, RecordTypeId=acctVenueRTId);
        insert parentAccount;
        Account account = new Account(Name = 'Test Acc', Account_Formal_Name__c = 'Test', Type = 'Hotel', Accommodations__c = true, Event_Venue__c = true, ParentId = parentAccount.Id, RecordTypeId=acctVenueRTId);
        insert account;
        
        //Create Parent event records
        Advisory_Event__c event = testUtilities.createEvent(Constants.RECORD_TYPE_ID_ADV_EVENT_SERIES, null, true);
        
        //Start test from here
        Test.startTest();
        
        //Create a Venue record
        Venue__c venue = new Venue__c(Name = 'Test', 
                                      RecordTypeId = Schema.SObjectType.Venue__c.getRecordTypeInfosByName().get('Event Venue').getRecordTypeId(),
                                      Advisory_Event__c = event.Id, 
                                      Venue__c = account.Id);
        VenueTriggerHelper.EXECUTE_Venue_TRIGGER = true;
        insert venue;
        
        //Stop Test here
        Test.stopTest();
        
        //This Venue should be marked as Primary
        venue = [Select Primary__c from Venue__c where Id =: venue.Id];
        System.assert(venue.Primary__c);
    }
    
    //test validatePrimaryVenue and updateMeeting
    static testMethod void testValidatePrimaryVenueWhenPrimaryVenuesExistAlready() {
    	
        Id acctVenueRTId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Vendor or Venue').getRecordTypeId();
        
    	//Account
        Account parentAccount = new Account(Name = 'Test Acc', Account_Formal_Name__c = 'Test', Type = 'Hotel', Accommodations__c = true, Event_Venue__c = true, RecordTypeId=acctVenueRTId);
        insert parentAccount;
		Account account = new Account(Name = 'Test Acc', Account_Formal_Name__c = 'Test', Type = 'Hotel', Accommodations__c = true, Event_Venue__c = true, ParentId = parentAccount.Id, RecordTypeId=acctVenueRTId);
        insert account;
		
    	//Create Parent event records
        Advisory_Event__c event = testUtilities.createEvent(Constants.RECORD_TYPE_ID_ADV_EVENT_SERIES, null, true);
        
        //Create a Venue record
        List<Venue__c> venues = new List<Venue__c>();
        venues.add(new Venue__c(Name = 'ATest',
                                RecordTypeId = Schema.SObjectType.Venue__c.getRecordTypeInfosByName().get('Event Venue').getRecordTypeId(),
                                Advisory_Event__c = event.Id, 
                                Primary__c = true, 
                                Venue__c = account.Id));
		    
        //Try inserting the Venues, it should be successfully inserted
        VenueTriggerHelper.EXECUTE_VENUE_TRIGGER = true;
        insert venues;
        
        //Start Test
        Test.startTest();
        
        //Create a Venue record
        venues = new List<Venue__c>();
        venues.add(new Venue__c(Name = 'BTest', Advisory_Event__c = event.Id, Primary__c = true, Venue__c = account.Id));
        
        //Try inserting the Venues, it should be successfully inserted
        VenueTriggerHelper.EXECUTE_VENUE_TRIGGER = true;
        insert venues;
        
        //Stop Test here
        Test.stopTest();
        
        //Fetch the Venues order by created date, firstone should be set to not primary and secont one as Primary. 
        //Meeting record should be updated with Second Venue Program
        venues = [Select Primary__c from Venue__c where Advisory_Event__c =: event.Id Order by Name ASC];
        System.assert(!venues[0].Primary__c);
        System.assert(venues[1].Primary__c);
    }
}