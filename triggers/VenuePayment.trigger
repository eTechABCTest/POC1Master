trigger VenuePayment on Venue_Payment__c (before insert, before update) {
	
    //get all venue ids
    set<Id> venueIds = new set<Id>();
    for (Venue_Payment__c payment : trigger.new) venueIds.add(payment.Event_Venue__c);
    
    //get a map of all venues
    map<Id, Venue__c> venueMap = new map<Id, Venue__c>([SELECT Id, Advisory_Event__c FROM Venue__c WHERE Id IN :venueIds]);
    
    //set the Advisory Event to the same value as the related Venue
    for (Venue_Payment__c payment : trigger.new) {
        Venue__c venue = venueMap.get(payment.Event_Venue__c);
        if (venue != null) {
            payment.Advisory_Event__c = venue.Advisory_Event__c;
        }
    }
}