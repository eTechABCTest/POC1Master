/**
 *  Desription      :   Test class for VenuePayment Trigger
 * 
 *  Created By      :   
 * 
 *  Created Date    :   4/27/2015
 * 
 *  Revision Logs   :   V1.0 - Created
 *						V2.0 - Modified - Mahendra swarnkar - 9/3/2016 - CR-20160126-9564.
 *
 *	Code Covrage	:	V1.0 - Created
 *						V2.0 - 100%
 *
 **/
@isTest(SeeAllData = false)
public class Test_VenuePaymentTrigger {
	
    static testmethod void testVenuePayment() {
        
        //create advisory events
        Advisory_Event__c series = TestUtilities.createEvent(Constants.RECORD_TYPE_ID_ADV_EVENT_SERIES, null, true);
        Advisory_Event__c event = TestUtilities.createEvent(Constants.RECORD_TYPE_ID_ADV_EVENT_EVENT, null, false);
        event.Master_Event__c = series.Id;
        event.Parent_Event__c = series.Id;
        insert event;
        
        Account acctVenue = TestUtilities.CreateNewAccount('Vendor or Venue', false);
        acctVenue.Accommodations__c = true;
        acctVenue.Event_Venue__c = true;
        acctVenue.Type = 'Hotel';
        acctVenue.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Vendor or Venue').getRecordTypeId();
        insert acctVenue;
        
        Venue__c eventVenue = new Venue__c(Name = 'BTest', Advisory_Event__c = event.Id, Primary__c = true, Venue__c = acctVenue.Id,
                                          RecordTypeId = Schema.SObjectType.Venue__c.getRecordTypeInfosByName().get('Event Venue').getRecordTypeId());
        insert eventVenue;
        
        Venue_Payment__c venuePayment = new Venue_Payment__c(Amount__c = 456, Date_Due__c = system.today(), Event_Venue__c = eventVenue.Id);
        insert venuePayment;
        
		//get the venue payment and verify
		venuePayment = [SELECT Id, Advisory_Event__c FROM Venue_Payment__c WHERE Id = :venuePayment.Id];
        system.assertEquals(event.Id, venuePayment.Advisory_Event__c);
    }
}