/*
    Purpose         :   This class is helper class for trigger on Membership Key Contact object.
                
    Create By       :   Simplyforce Technology
    
    Created Date    :   12/15/2012
    
    Current Version :   v1.0
    
    Revision Log    :   V_1.0 Created
*/
public without sharing class MembershipKeyContactTriggerHelper {
	
	//This method is to fetch all the membership records from Membership Key Contacts and Populate the Contact Pubs and Contacts Meetings
	public static void populateContactData(List<Membership_Key_Contact__c> membershipKeyContacts) {
		
		//Create a Set of Membership Ids
		Set<Id> membershipIds = new Set<Id>();
		
		//Loop through the MKC
		for(Membership_Key_Contact__c mKC : membershipKeyContacts) {
			
			//Check for the Membership record id
			if(mKC.Membership__c != null) {
				
				//Add id in set
				membershipIds.add(mKC.Membership__c);
			}
		}
		
		//Fetch all the memebership records and push into the MembershipTriggerHelper.populateContactData(newMemberShips) method
		List<Membership__c> memberships = [Select Id, Membership_Status__c from Membership__c where Id IN: membershipIds];
		
		//Update Contacts
		MembershipTriggerHelper.populateContactData(memberShips);
	}
}