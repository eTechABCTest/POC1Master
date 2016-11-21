/**
*  Description     :    Helper class for contact object trigger. This class is used to hold the various 
*                       Contact trigger routines
*  Created By      :      
* 
*  Created Date    :   
* 
*  Revision Logs   :    V_1.0 - Created
*                       V_1.1 - Modified By - Abhinav Sharma - 05/23/2014 - CR-20140507-5392
*                       V_1.2 - Modified By - Abhinav Sharma - 08/13/2014 - CR-20140604-5691
*                       V_1.3 - Modified By - Abhinav Sharma - 10/20/2014 - CR-20140923-7430
*                       V_1.4 - Modified By - Victor Hanson - 10/05/2014 - EAB / SF Integration Project
*                       V_1.5 - Modified By - Bhavi Sharma - 01/23/2015 - CR-20141209-8274 - New method addedd - resendBouncedAgreement()
*                       V_1.6 - Modified By - Bhavi Sharma - 06/10/2015 - CR-20141212-8307 - Updated - updateContactPersonalAddressUpdated
*                       V_1.7 - Modified By - Subhash Garhwal - 07/02/2015 - CR-20150618-9014 - New method added - updateStaffAssignment   
*                       V_1.8 - Modified By - MAhendra swarnakar - 09/18/2015 - CR-20150819-9165 - New method added - populateInstitutionLookUpFieldForNPD
*                       V_1.9 - Modified By - Padmesh Soni - 17/08/2015 - CR-20150729-9114 - New method added - createIncentiveChangeLog() 
*                       V_1.10 - Modified By - Mahendra Swarnakar - CR-20150831-9207 - 11/25/2015 - Contact Edit Validation - (validateContactFieldsForInvalidPhrase method)
*                       V_1.11 - Modified By - Rajeev Jain - 04/202/016 - CR-20151120-9402 - Modified createIncentiveChangeLog method logic as per the updated SDD of Change Management.
* 						V_1.12 - Modified By - Mahendra Swarnkar - 5/30/2016 - CR-20151209-9452 - Release 51 - Added a new methed "populateMASignOffDateOnUser" to 
*                                   populate the "Marketing Asssociated Sign Off Date" value on User record with "Marketing Asssociated Sign Off Date" field value on the contact
*						V_1.13 - Modified By - Mahendra Swarnakar - CR-20160219-9621 - 30/6/2016 - Updated the validateContactFieldsForInvalidPhrase method logic to bypass the Email and Title validation for numeric value '2' only
**/ 
public without sharing class ContactTriggerUtilities {
    
    public final static string ELOQUA_STATUS_PRIMARY = 'Eloqua Hard Bounce - Primary';
    public final static string ELOQUA_STATUS_PREFERRED = 'Eloqua Hard Bounce - Preferred';
    public static Boolean EXECUTE_RESEND_BOUNCED_AGREEMENT = true;
        
    //Added By - Mahendra Swarnakar - CR-20150831-9207 - 11/25/2015 - Contact Edit Validation
    //Modified By - Mahendra Swarnakar - CR-20160219-9621 - 30/6/2016 - Updated the logic to bypass the Email and Title validation for numeric value '2' only 
    /**
    *  @description    :   This method will check and validate First Name, Last Name, Title, or Email Address 
    *                       field values on contact record for invalid phrase/characters presence.  
    * 
    *  @args           :   List of contacts, Map of old contacts
    * 
    *  @return         :   void
    * 
    **/ 
    public static void validateContactFieldsForInvalidPhrase(List<Contact> newContacts, Map<Id, Contact> mapOldContacts) {

        //Bypassing the below written logic for "Adviosry Guest Users"
        if(UserInfo.getUserType() != null && UserInfo.getUserType().trim().toLowerCase() == System.Label.Adv_Guest_User_Type)
            return;
        
        //Map to hold the eligible contact records
        Map<Id, Contact> mapEligibleContacts = new Map<Id, Contact>();
        
        //Loop through contact records and bypassing records if having "Is_Ignore_Phrase_Characters__c" field as true.
        for(Contact con : newContacts) {
           
            //Insert use case
            if(mapOldContacts == null && !con.Is_Ignore_Phrase_Characters__c)
                mapEligibleContacts.put(con.Id, con);
            
            //Update use case
            if(mapOldContacts != null
                &&
                (
                    con.FirstName != mapOldContacts.get(con.Id).FirstName
                    ||
                    con.LastName != mapOldContacts.get(con.Id).LastName
                    ||
                    con.Email != mapOldContacts.get(con.Id).Email
                    ||
                    con.Title != mapOldContacts.get(con.Id).Title
                    ||
                    con.Is_Ignore_Phrase_Characters__c != mapOldContacts.get(con.Id).Is_Ignore_Phrase_Characters__c
                )
                && !con.Is_Ignore_Phrase_Characters__c
            )
                mapEligibleContacts.put(con.Id, con);    
        }
        
        //Checking map for size value
        if(mapEligibleContacts.keySet().size() > 0) {
            
            //Map to hold the field Label as a key and a set of invalid phrases for that field as avalue
            Map <String, Set<String>> mapOfFieldNameWithSetOfInvalidPhrases = new Map <String, Set<String>>();
            
            //Checking for null/blank values
            if(Invalid_Phrase_Characters__c.getall() != null 
                && Invalid_Phrase_Characters__c.getall().values() != null
                && Invalid_Phrase_Characters__c.getall().values().size() > 0
            ) {
                //Loop through custom setting records
                for(Invalid_Phrase_Characters__c iPC : Invalid_Phrase_Characters__c.getall().values()) {
                    if(String.isNotBlank(iPC.Object_Name__c) && iPC.Object_Name__c.trim().toLowerCase() == 'contact'
                        && String.isNotBlank(iPC.Invalid_Phrase__c) 
                        && String.isNotBlank(iPC.Applicable_For__c)){
                        
                        //Populating the mapOfFieldNameWithSetOfInvalidPhrases 
                    	for(String str : iPC.Applicable_For__c.trim().split(',')){
                    		if(String.isNotBlank(str)){
                    			str = str.trim().toLowerCase();
	                    		if(mapOfFieldNameWithSetOfInvalidPhrases.containsKey(str))
	                    			mapOfFieldNameWithSetOfInvalidPhrases.get(str).add(iPC.Invalid_Phrase__c.trim().toLowerCase());
	                    		else
	                    			mapOfFieldNameWithSetOfInvalidPhrases.put(str, new Set<String> {iPC.Invalid_Phrase__c.trim().toLowerCase()});
                    		}
                    	}
					}
                }
			}
			
            //Check for size
            if(mapOfFieldNameWithSetOfInvalidPhrases.keySet().size() > 0){
            	
				//Loop through contact records
				for(Contact c : newContacts) {
					if(mapEligibleContacts.containsKey(c.Id) && mapEligibleContacts.get(c.Id) != null) {
				        
				        //Boolean flag to decide that the Invalid phrase validation error message should be shown on page or not
				        Boolean isContainsInvalidPhrase = false;
				        
				        //Loop through mapOfFieldNameWithSetOfInvalidPhrases key set
				        for(String applicablefor : mapOfFieldNameWithSetOfInvalidPhrases.keySet()){
				        	
				        	if(mapOfFieldNameWithSetOfInvalidPhrases.get(applicablefor) != null && mapOfFieldNameWithSetOfInvalidPhrases.get(applicablefor).size() > 0 ){
				        	
				        		//check for the invalid phrases in the First name, Last name, Email, and title fields
					        	for(String invalidPhrase : mapOfFieldNameWithSetOfInvalidPhrases.get(applicablefor)) {
					            	
					            	//check for the invalid phrases in the First name
					            	if(applicablefor.equalsIgnoreCase('FirstName')
					            		&& String.isNotBlank(c.FirstName) 
										&& c.FirstName.containsIgnoreCase(invalidPhrase)){
										
										//Set the validation error flag
										isContainsInvalidPhrase = true;
					            	}
					            	
					            	//check for the invalid phrases in the Last name
					            	if(applicablefor.equalsIgnoreCase('LastName')
					            		&& String.isNotBlank(c.LastName) 
					            		&& c.LastName.containsIgnoreCase(invalidPhrase)){
											
					            		//Set the validation error flag
					            		isContainsInvalidPhrase = true;
					            	}
					            	
					            	//check for the invalid phrases in the Email
					            	if(applicablefor.equalsIgnoreCase('Email')
					            		&& String.isNotBlank(c.Email) 
										&& c.Email.containsIgnoreCase(invalidPhrase)){
										
					            		//Set the validation error flag
					            		isContainsInvalidPhrase = true;
					            	}
					            	
					            	//check for the invalid phrases in the Title
					            	if(applicablefor.equalsIgnoreCase('Title')
					            		&& String.isNotBlank(c.Title) 
										&& c.Title.containsIgnoreCase(invalidPhrase)){
											
					            		//Set the validation error flag
					            		isContainsInvalidPhrase = true;
					            	}
					        	}
				        	}
				        }
				        
				        //Show the validation error message on the page if flag is true
				        if(isContainsInvalidPhrase)
				        	c.addError(System.Label.Invalid_Phrase_Error_On_Contact);       
				    }
				}
            }
        }
    }    
        
    //Modified By - Abhinav Sharma - 10/20/2014 - CR-20140923-7430
    public static void UpdateRestrictionStatus(List<Contact> newCons) {
        Set<Id> acctIds = new Set<Id>();
        for (Contact c : newCons)
            acctIds.add(c.AccountId);
        
        Map<Id, Contact> consWithRestrictions = new Map<Id, Contact>([SELECT Id, AccountId, Account.Account_Restriction_Status__c,
                                                                      (SELECT Restriction__r.Category__c FROM Restrictions_MtM__r WHERE Restriction_Expired__c = false)
                                                                      FROM Contact WHERE Id IN :newCons AND AccountId != null]);
        
        for(Contact newCon : newCons) {
            // if the newAcc is null, move along
            if (newCon.AccountId == null) continue;
            
            // get that contact with restrictions so we can determine the proper restriction
            Contact conWithRestriction = consWithRestrictions.get(newCon.Id);
            system.debug('@@OldCon:' + conWithRestriction.AccountId + 'NewCon:' + newCon.AccountId + ' STATUS:' + conWithRestriction.Account.Account_Restriction_Status__c);
            // if the account has been updated, update the restriction
            if (conWithRestriction.AccountId != newCon.AccountId) {
                if (conWithRestriction.Account.Account_Restriction_Status__c == null
                    || conWithRestriction.Account.Account_Restriction_Status__c == '')
                {
                    if (conWithRestriction.Restrictions_MtM__r.size() == 0) {
                        newCon.Contact_Restriction_Status__c = null;
                    }
                }
                for (Restricted_MtM__c rMtM : conWithRestriction.Restrictions_MtM__r) {
                    if (rMtM.Restriction__r.Category__c == 'Restricted: Permission Required') {
                        newCon.Contact_Restriction_Status__c = 'Restricted: Permission Required';
                        break;
                    }
                    else {
                        if (rMtM.Restriction__r.Category__c == 'Critical Background Information') {
                            newCon.Contact_Restriction_Status__c = 'Critical Background Information';
                        }
                    }
                }
            }
        }
    }
    
    public static void PopulateContactTitleFromEvent(List<Event> events) {
        Set<Id> contactIds = new Set<Id>();
        // get all whoIds (contactIds)
        for (Event e : events) {
            if (e.WhoId != null)
                contactIds.add(e.WhoId);
        }
        // get all of the events and their associated contacts
        Map<Id, Contact> contactMap = new Map<Id, Contact>([SELECT Name, Id, Title FROM Contact WHERE Id IN :contactIds]);
        
        BuildEventTitle(events, contactMap, false);
    }
    
    public static void PopulateContactTitleFromEvent(List<Contact> triggerNew, Map<Id, Contact> triggerOldMap) {
        Map<Id, Contact> contactMap = new Map<Id, Contact>();
        // CR-2879 check to see if the contact's title actually changed
        for (Contact newCon : triggerNew) {
            // get theh old contact
            Contact oldCon;
            if (triggerOldMap != null) oldCon = triggerOldMap.get(newCon.Id);
            if (oldCon == null || (oldCon != null && oldCon.Title != newCon.Title)) {
                contactMap.put(newCon.Id, newCon);
            }
        }
        
        if (contactMap.size() > 0) {
            List<Event> events = [SELECT Id, RecurrenceActivityId, IsRecurrence, WhoId, Title__c FROM Event WHERE WhoId IN :contactMap.keySet() AND isrecurrence=false];
            
            BuildEventTitle(events, contactMap, true);
        }
    }
    
    public static void BuildEventTitle(List<Event> events, Map<Id, Contact> contactMap, boolean SaveUpdates) {
        List<Event> eventsToUpdate = new List<Event>();
        for (Event e : events) {
            // get the contact for this event
            Contact con = contactMap.get(e.WhoId);
            if (con != null) {
                // if the title isn't updated, check the next event
                if (e.Title__c == con.Title) continue;
                e.Title__c = con.Title;
                if (e.IsRecurrence || e.RecurrenceActivityId != null)
                    e.Exclude_From_Exchange_Synch__c = true;
                eventsToUpdate.add(e);
            }
        }
        
        // CR-2879 only update events if the title actually changed
        if (SaveUpdates && eventsToUpdate.size() > 0)
            update eventsToUpdate;
    }
    
    //This method is to delete  Key Member Contacts records if contact is not Active
    public static void deleteKeyMemberContactsForInActiveContacts(List<Contact> contacts) {
        
        //Create a set of Contact Ids to hold the Ids of InActive contacts
        Set<Id> inActiveContactsIds = new Set<Id>();
        
        //loop through the contacts
        for(Contact contact : contacts) {
            
            //Check for the contacts and add in set if Contact Status is not Active
            if(contact.Contact_Status__c != null && contact.Contact_Status__c != '' && contact.Contact_Status__c != Constants.ACTIVE) {
                
                //Add contact id
                inActiveContactsIds.add(contact.Id);
            }
        }
        
        //Check for the set size
        if(inActiveContactsIds.size() > 0) {
            
            //Delete all the Key membership Contacts, related to the inActiveContactsIds
            List<Membership_Key_Contact__c> keyContacts = [Select Id, Contact__r.AccountId, Membership__c from Membership_Key_Contact__c where Contact__c IN: inActiveContactsIds];
            
            // list all key contacts to update
            List<Subscription__c> keyConSubscriptionsToUpdate = new List<Subscription__c>();
            
            Set<Id> membershipIds = new Set<Id>();
            for (Membership_Key_Contact__c mkc : keyContacts) {
                membershipIds.add(mkc.Membership__c);
            }
            
            // get all memberships and their associated membership key contacts
            List<Membership__c> memberships = [SELECT Id, Account_Name__c, Program__c,
                                               (SELECT Id, Contact__r.AccountId FROM Membership_Key_Contacts__r WHERE Contact__c IN :inActiveContactsIds)
                                               FROM Membership__c WHERE Id IN :membershipIds];
            
            // process each unique membership individually
            for (Membership__c membership : memberships) {
                List<Membership_Key_Contact__c> keyContactsDiffInst = new List<Membership_Key_Contact__c>();
                for (Membership_Key_Contact__c mkc : keyContacts) {
                    if (mkc.Contact__r.AccountId != membership.Account_Name__c) keyContactsDiffInst.add(mkc);
                }
                
                // put the key contact institution ids in a set
                Set<Id> keyContactInstIdSet = new Set<Id>();
                for (Membership_Key_Contact__c keyCon : keyContactsDiffInst)
                    keyContactInstIdSet.add(keyCon.Contact__r.AccountId);
                
                // 2) get a list of all active memberships on these institutions
                List<Account> acctWithActiveMemberships = [SELECT Id,
                                                           (SELECT Id, Account_Name__c, Program__c FROM Memberships__r WHERE Membership_Status__c LIKE 'Member%')
                                                           FROM Account WHERE Id IN :keyContactInstIdSet];
                
                // 3) get all eligible subscription options for each institution and put them in a map
                Map<Id, Map<Id, Id>> acctIdToEligSubOptions = new Map<Id, Map<Id, Id>>();
                for(Account keyConAcct : acctWithActiveMemberships) {
                    // get all active programs for this acct
                    Set<Id> keyConProgIdSet = new Set<Id>();
                    for (Membership__c m : keyConAcct.Memberships__r) keyConProgIdSet.add(m.Program__c);
                    List<Eligible_Subscription_Option__c> keyConEligSubOpList = [SELECT Id, Related_Subscription__c FROM Eligible_Subscription_Option__c
                                                                                 WHERE Program__c IN :keyConProgIdSet];
                    Map<Id, Id> keyConSubToEligSubOption = new Map<Id, Id>();
                    for (Eligible_Subscription_Option__c keyConEligSubOp : keyConEligSubOpList) {
                        keyConSubToEligSubOption.put(keyConEligSubOp.Related_Subscription__c, keyConEligSubOp.Id);
                    }
                    acctIdToEligSubOptions.put(keyConAcct.Id, keyConSubToEligSubOption);
                }
                
                // get all active subscriptions for that program on that institution
                List<Subscription__c> subscriptions = [SELECT Id, Subscription_ID__c, Contact__r.AccountId, Subscription_Status__c, Subscription_ID__r.Related_Subscription__c, Subscription_ID__r.Program__c, Subscription_ID__r.Program__r.Program_Acronym__c
                                                       FROM Subscription__c
                                                       WHERE Termination_Date__c = null
                                                       AND Contact__r.AccountId IN :keyContactInstIdSet
                                                       AND Contact__c IN :inActiveContactsIds
                                                       AND Subscription_ID__r.Program__c = :membership.Program__c];
                
                // 4) determine which subscriptions need to be terminated and which can be re-associated with another active eligible subscription option
                for (Subscription__c sub : subscriptions) {
                    Map<Id, Id> keyConSubToEligSubOption = acctIdToEligSubOptions.get(sub.Contact__r.AccountId);
                    String keyConEligSubOptionId = keyConSubToEligSubOption.get(sub.Subscription_ID__r.Related_Subscription__c);
                    if (keyConEligSubOptionId == null) {
                        // add a termination date of today to the subscription
                        sub.Subscription_Status__c = 'Inactive - No Eligible Memberships - ' + sub.Subscription_ID__r.Program__r.Program_Acronym__c;
                        sub.Termination_Date__c = system.now();
                    }
                    else {
                        // update the eligible subscription option to match the ESO of the program whose membership is still active
                        sub.Subscription_ID__c = keyConEligSubOptionId;
                    }
                    // add the subscription to the update list
                    keyConSubscriptionsToUpdate.add(sub);
                }
            }
            
            // check if there are any subscriptions to update
            if (keyConSubscriptionsToUpdate.size() > 0)
                update keyConSubscriptionsToUpdate;
            
            
            //Check if there are records to delete
            if(keyContacts.size() > 0)
                delete keyContacts;
        }
    }
    
    //Validate contact before deleting
    public static void validateContactBeforeDelete(List<Contact> contacts) {
        
        //lists to hold records for deletion
        list<Site_Profile__c> sProfilesToDelete = new list<Site_Profile__c>();
        list<Site_User__c> sUsersToDelete = new list<Site_User__c>();
        
        //get a map of all contacts with site profiles
        map<Id, Contact> mapConWithSiteProfiles = new map<Id, Contact>([SELECT Id, Site_User__c, (SELECT Id, Status__c FROM Site_Profiles__r) FROM Contact WHERE Id IN :contacts]);
        
        //get all site users - delete any site users that will be orphaned by the deletion of this contact
        set<Id> sUserIdSet = new set<Id>();
        for (Contact con : contacts) sUserIdSet.add(con.Site_User__c);
        map<Id, Site_User__c> mapSiteUsers = new map<Id, Site_User__c>([SELECT Id, (SELECT Id FROM Site_Profiles__r), (SELECT Id FROM Contacts__r) FROM Site_User__c WHERE Id IN :sUserIdSet]);
        
        //loop through the contacts and check if any of the contact record have active site profiles.  If so, do not allow user to delete this contact
        for(Contact con : contacts) {
            
            //get the contact with site profiles
            Contact conWithSiteProfile = mapConWithSiteProfiles.get(con.Id);
            
            if (conWithSiteProfile.Site_Profiles__r.size() > 0) {
                for (Site_Profile__c sProfile : conWithSiteProfile.Site_Profiles__r) {
                    //Check for the field value
                    if(sProfile.Status__c == SiteUserHelper.STATUS_ACTIVE) {
                        con.addError('Unable to delete a Contact that is related to an active Site Profile.');
                        return;
                    }
                }
                
                //delete the site profiles
                sProfilesToDelete.addAll(conWithSiteProfile.Site_Profiles__r);
                
                //if the site user is only associated with the contact + site profiles that we are deleting, delete the site user too
                Site_User__c site_User = mapSiteUsers.get(con.Site_User__c);
                if (site_User.Contacts__r.size() == 1 && site_User.Site_Profiles__r.size() == conWithSiteProfile.Site_Profiles__r.size()) {
                    sUsersToDelete.add(site_User);
                }
            }
        }
        
        //delete the site profiles and site users
        if (sProfilesToDelete.size() > 0) delete sProfilesToDelete;
        if (sUsersToDelete.size() > 0) delete sUsersToDelete;
    }
        
    //Method added by VH - 1/7/14 - CR-20130514-3016
    public static void validateContactBeforeInsert(List<Contact> contacts) {
        
        // get the institution ids for all contacts
        set<Id> accountIdSet = new set<Id>();
        for (Contact contact : contacts) accountIdSet.add(contact.AccountId);
        
        // get a map of all accounts
        map<Id, Account> accountMap = new map<Id, Account>([SELECT Id, Status__c, RecordType.DeveloperName 
                                                            FROM Account WHERE Id IN :accountIdSet AND Status__c != null]);
        
        // check to see if any of these contacts are being created on inactive institutions
        for (Contact contact : contacts) {
            
            // do not attempt to validate if one of the following is true:
            //  1. AccountMap is null
            //  2. AccountMap doesnt contain the account
            //  3. Contact Email contains '_inactive' (ie: adv.com user being moved from one institution to another)
            if (accountMap == null 
                || !accountMap.containsKey(contact.AccountId) 
                || contact.Email != null && contact.Email.contains('_inactive')) continue;
            
            // get the account
            Account account = accountMap.get(contact.AccountId);
            
            // if the acct status is not active and the record type is not vendor, return an error
            if (!account.Status__c.equalsIgnoreCase(Constants.ACTIVE)
                && account.RecordType.DeveloperName != 'Vendor') {
                    
                    contact.addError(Constants.ERROR_CANNOT_ADD_CONTACT_TO_INACTIVE_INSTITUTION);
                }
        }
    }
    
    //Method added by Bhavi Sharma - 09/25/2013 - CR-20130109-2089
    /**
*  @description    :   This method is to check wheather any of the address data has been changed.
In case of any change, it will update the Personal_Address_Updated__c flag to true, so it can be picked up by batch.
Batch will send this updated address to comdata.
*
*  @args           :   Trigger.new, Trigger.oldMap
*
*  @return         :
*
*  Revision Logs   :   V_1.1 - Bhavi Sharma - 06/04/2014 - Method updated to update the contact's personal address on Portfolio - CR-20140224-4623
V_1.2 - Bhavi Sharma - 06/10/2015 - Code updated to update the Card Holder Name of Portfolio whenever Legal Name changes on Contact
*
**/
    public static void updateContactPersonalAddressUpdated(List<Contact> newContacts, Map<Id, Contact> oldMapContacts) {
        
        //Create a list of contacts which have been updated with address
        List<Contact> addressUpdatedContacts = new List<Contact>();
        List<Contact> nameUpdates = new List<Contact>();
        
        //Loop through Trigger.new
        for(Contact contact : newContacts) {
            
            //Check if Personal_Address_Updated__c = true and it was false earlier, then fetch all the related Portfolio record where Portfolio_Owner__c = Contact.Id   
            if(contact.Personal_Address_Updated__c == true && oldMapContacts.get(contact.Id).Personal_Address_Updated__c == false) {
                
                //Add in list of address updated contacts
                addressUpdatedContacts.add(new Contact(Id = contact.Id, Personal_Address_Updated__c = false));
            }
            
            //Check whenever the contact's Lagal First Name and Last Name is changed, update the same name on Portfiolio
            if((String.IsNotBlank(contact.Legal_First_Name__c) && contact.Legal_First_Name__c != oldMapContacts.get(contact.Id).Legal_First_Name__c)
               || (String.IsNotBlank(contact.Legal_Last_Name__c) && contact.Legal_Last_Name__c != oldMapContacts.get(contact.Id).Legal_Last_Name__c)) {
                   
                   //Add in list of address updated contacts
                   nameUpdates.add(contact);
               }
        }
        
        if(nameUpdates.size() > 0) {
            
            //Query all teh related portfolio from database
            //Get all the portfolio records where Portfolio_Owner__c in contact list
            //Then populate the Name on portfolio
            List<Portfolio__c> payments = [Select Id, Card_Holder__r.Personal_Address_Line_1__c, Card_Holder__r.Personal_Address_Line_2__c, 
                                           Card_Holder__r.Personal_Address_City__c, Card_Holder__r.Personal_Address_State__c, 
                                           Card_Holder__r.Personal_Address_PostalCode__c, Card_Holder__r.Legal_First_Name__c, 
                                           Card_Holder__r.Legal_Last_Name__c, Card_Holder__r.Personal_Address_Country__c, 
                                           First_Name_On_Card__c, Last_Name_On_Card__c
                                           from Portfolio__c where Card_Holder__c IN: nameUpdates];
            //Loop through the payments
            for(Portfolio__c payment : payments) {
                
                //Name Updates
                if(payment.First_Name_On_Card__c != payment.Card_Holder__r.Legal_First_Name__c)
                    payment.First_Name_On_Card__c = trunc(payment.Card_Holder__r.Legal_First_Name__c, 15);
                if(payment.Last_Name_On_Card__c != payment.Card_Holder__r.Legal_First_Name__c)
                    payment.Last_Name_On_Card__c = trunc(payment.Card_Holder__r.Legal_Last_Name__c, 15);
            }
            
            if(payments.size() > 0)
                update payments;
        }
        
        //Update the Payment records with new address
        if(addressUpdatedContacts.size() > 0) {
            
            updatePortfolioWithContactPersonalAddress(addressUpdatedContacts);
            
            //Bypass all triggers before updating contacts
            Util.BypassAllTriggers = true;
            update addressUpdatedContacts;  
            Util.BypassAllTriggers = false;
        }
    }
        
    //Method added by Bhavi Sharma - 06/04/2014 - CR-20140224-4623
    /**
*  @description    :   This method is to update the contact personal fields to the related portfolio
*
*  @args           :   List of contact
*
*  @return         :
*
**/
    public static void updatePortfolioWithContactPersonalAddress(List<Contact> contacts) {
        
        //get CC Default Settings instance  
        Credit_Card_Settings__c configDefaults = CreditCardConstants.CONFIG_DEFAULT;
        
        //Check if any of the contact was updated
        if(contacts.size() > 0) {
            
            //Query all teh related portfolio from database
            //Get all the portfolio records where Portfolio_Owner__c in contact list
            //Then populate the contact address on portfolio
            List<Portfolio__c> payments = [Select Id, Card_Holder__r.Personal_Address_Line_1__c, Card_Holder__r.Personal_Address_Line_2__c, 
                                           Card_Holder__r.Personal_Address_City__c, Card_Holder__r.Personal_Address_State__c, 
                                           Card_Holder__r.Personal_Address_PostalCode__c, Card_Holder__r.Legal_First_Name__c, 
                                           Card_Holder__r.Legal_Last_Name__c, Card_Holder__r.Personal_Address_Country__c, 
                                           First_Name_On_Card__c, Last_Name_On_Card__c
                                           from Portfolio__c where Card_Holder__c IN: contacts];
            
            //Loop through the payments
            for(Portfolio__c payment : payments) {
                
                //Populate address fields
                //Comdata doesn't  handle international addresses
                //So alll the contact with non US address will be process with the CC Setings default address
                if(!String.IsBlank(payment.Card_Holder__r.Personal_Address_Country__c) && Constants.SET_UNITED_STATES.contains(payment.Card_Holder__r.Personal_Address_Country__c.toLowerCase())) {
                    
                    //Populate from contact
                    payment.Billing_Address_Line_1__c = trunc(payment.Card_Holder__r.Personal_Address_Line_1__c, 30);
                    payment.Billing_Address_Line_2__c = trunc(payment.Card_Holder__r.Personal_Address_Line_2__c, 30);
                    payment.Billing_Address_City__c = trunc(payment.Card_Holder__r.Personal_Address_City__c, 20);
                    payment.Billing_Address_State__c = trunc(payment.Card_Holder__r.Personal_Address_State__c, 2);
                    payment.Billing_Address_PostalCode__c = trunc(payment.Card_Holder__r.Personal_Address_PostalCode__c, 10);
                    payment.Billing_Address_Attention_To__c = null;
                } else {
                    
                    //Populate from Credit Card Settings
                    payment.Billing_Address_Attention_To__c = trunc(configDefaults.Alternate_Delivery_Attention_To__c, 35);
                    payment.Billing_Address_Line_1__c = trunc(configDefaults.Alternate_Delivery_Address_1__c, 30);
                    payment.Billing_Address_Line_2__c = trunc(configDefaults.Alternate_Delivery_Address_2__c, 30);
                    payment.Billing_Address_City__c = trunc(configDefaults.Alternate_Delivery_City__c, 20);
                    payment.Billing_Address_State__c = trunc(configDefaults.Alternate_Delivery_State__c, 2);
                    payment.Billing_Address_PostalCode__c = trunc(configDefaults.Alternate_Delivery_Postal_Code__c, 10);
                }
                
                if(String.IsBlank(payment.First_Name_On_Card__c))
                    payment.First_Name_On_Card__c = trunc(payment.Card_Holder__r.Legal_First_Name__c, 15);
                if(String.IsBlank(payment.Last_Name_On_Card__c))
                    payment.Last_Name_On_Card__c = trunc(payment.Card_Holder__r.Legal_Last_Name__c, 20);
                
                //Update flag
                payment.Billing_Address_Updated__c = true; 
            }
            
            //Update Payments
            if(payments.size() > 0)
                update payments;
        }
    }
        
    /**
*  @description    :   This method is to truncate the value upto given limit 
* 
*  @args           :   Value to be truncated, Characters limit
* 
*  @return         :   truncated value
* 
**/ 
    public static String trunc(String value, Integer length) {
        
        //Chekc if value is not null
        if(value != null && value.length() >= length) {
            
            //Trunc upto given length
            return value.left(length);
        }
        
        //Return
        return value;
    }
        
    //Method added by Bhavi Sharma - 10/03/2013 - CR-20130109-2089
    /**
    *  @description    :   This method is to check if contact status has been changed from "Active" to "In-active"
    1. Create a OSR record with appropriate values
    2. Assign this OSR to "Card Request Queue" (TODO)
    *
    *  @args           :   Trigger.New, Trigger.oldMap
    *
    *  @return         :
    *
    **/
    /*
    public static void createOSRContactActiveToInactive(List<Contact> newContacts, Map<Id, Contact> oldMapContacts) {

        //List of OSR records to be created
        List<OSR__c> newOSRsToInsert = new List<OSR__c>();
        
        //Set to hold Ids of Contacts with Active to Inactive status changed
        Set<Id> inactiveContactIds = new Set<Id>();
        
        //Map to hold Key = ContactId and Value = CreditCardId
        Map<Id, Id> mapCCWithContact = new Map<Id, Id>();
        
        //Loop through Trigger.new
        for(Contact contact : newContacts) {

        //Check for Contact's Status field
        if(contact.Contact_Status__c != null && contact.Contact_Status__c.containsIgnoreCase(Constants.CONTACT_STATUS_INACTIVE)
        && (oldMapContacts != null && contact.Contact_Status__c != oldMapContacts.get(contact.Id).Contact_Status__c
        && oldMapContacts.get(contact.Id).Contact_Status__c.equalsIgnoreCase(Constants.CONTACT_STATUS_ACTIVE))) {
        
        inactiveContactIds.add(contact.Id);
        }
        }
        
        //Check size of list
        if(inactiveContactIds.size() > 0) {
        
        //Query result of Credit Card assoiciated with the inactive contacts
        List<Credit_Card__c> creditCards = [SELECT Id, Card_Requested_By__c FROM Credit_Card__c WHERE Card_Requested_By__c IN:inactiveContactIds ORDER BY Status__c];
        
        if(creditCards.size() > 0) {
        
        //Loop through Credit Cards
        for(Credit_Card__c creditCard : creditCards) {
        
        //Check if map is already contains the creditCard then continue
        //else put into map
        if(mapCCWithContact.containsKey(creditCard.Card_Requested_By__c))
        continue;
        else
        mapCCWithContact.put(creditCard.Card_Requested_By__c, creditCard.Id);
        }
        }
        
        //Check for size of Map
        if(mapCCWithContact.size() > 0) {
        
        //Loop through Trigger.new
        for(Id contact : mapCCWithContact.KeySet()) {
        
        //Add a new OSR instance in list
        newOSRsToInsert.add(new OSR__c(Status__c = Constants.OSR_STATUS_NEW, Subject__c = Constants.OSR_SUBJECT_EMPLOYEE_LEAVING,
        Request_Type__c = Constants.OSR_REQUEST_TYPE_DEACTIVATE_CARD, Contact__c = contact,
        Request_Reason__c = Constants.OSR_REQUEST_REASON_LEAVING_COMPANY, Origin__c = Constants.OSR_ORIGIN_TRAVEL_PORTAL,
        Priority__c = Constants.OSR_PRIORITY_CREATE_MEDIUM, Related_Card__c = mapCCWithContact.get(contact)));
        }
        }
        }
        
        //Check for size of list and insert OSR
        if(newOSRsToInsert.size() > 0)
        insert newOSRsToInsert;
        }
    */
    
    //Code Added - Bhavi Sharma - 11/14/2013 - CR-20130419-2900
    /**
    *  @description    :   This method is used to populate Contact's Primary Address fields from Parent Account's Primary Address fields
    *                      when All field are blank. Contact's fields are:
    *                          1.Primary Address Line 1
    *                          2.Primary City
    *                          3.Primary Country
    *                          4.Primary State
    *                          5.Primary Postal Code
    *
    *  @param          :   Trigger.new
    *
    *  @return         :
    *
    **/
    /*commented out 12/12/13 pending further discussion on how to implement
    public static void populateContactPrimaryAddress(List<Contact> newContacts) {

        //Map to hold Account Id with Contact
        Map<Id, List<Contact>> mapofContactsAccount = new Map<Id, List<Contact>>();
        
        //Set to hold AccountIds of Contact
        Set<Id> accountIds = new Set<Id>();
        
        //Loop through Trigger.new
        for(Contact contact : newContacts) {
        
        //Check Primary Address fields all are blank
        if(contact.AccountId != null
        && (contact.Primary_Address_Line_1__c == null || contact.Primary_Address_Line_1__c == '')
        && (contact.Primary_City__c == null || contact.Primary_City__c == '')
        && (contact.Primary_State_Province__c == null || contact.Primary_State_Province__c == '')
        && (contact.Primary_Postal_Code__c == null || contact.Primary_Postal_Code__c == '')
        && (contact.Primary_Country__c == null || contact.Primary_Country__c == '')
        ) {
        
        //populate set of AccountIds
        accountIds.add(contact.AccountId);
        
        //Check map is already not contain Contact's AccountId and Populate mapofContactsAccount
        if(!mapofContactsAccount.containsKey(contact.AccountId)) {
        
        mapofContactsAccount.put(contact.AccountId, new List<Contact>{contact});
        } else {
        
        mapofContactsAccount.get(contact.AccountId).add(contact);
        }
        }
        }
        
        //Check for size of set
        if(accountIds.size() > 0) {
        
        for(Account account : [SELECT Id, Primary_Address_Line_1__c, Primary_City__c, Primary_Country__c, Primary_Postal_Code__c, Primary_State_Province__c
        FROM Account WHERE Id IN: AccountIds]) {
        
        //Check map is already contain Account id
        if(mapofContactsAccount.containsKey(account.Id)) {
        
        //Loop through Map's values as List of Contacts
        for(List<Contact> contacts : mapofContactsAccount.values()) {
        
        //Loop through Contact list
        for(Contact contact : contacts) {
        
        //populate values
        contact.Primary_Address_Line_1__c = account.Primary_Address_Line_1__c;
        contact.Primary_City__c = account.Primary_City__c;
        contact.Primary_State_Province__c = account.Primary_State_Province__c;
        contact.Primary_Postal_Code__c = account.Primary_Postal_Code__c;
        contact.Primary_Country__c = account.Primary_Country__c;
        }
        }
        }
        }
        }
        }
    */
         
    //Added By Abhinav Sharma - CR-20140204-4441 - Restriction status not being updated properly as part of nightly batch job
    /**
    *  @description    :   This method is to delete all Restriction MtM records related to that Contacts when deleted.
    *
    *  @args           :   List of old Contact records 
    *
    *  @return         :   void
    *
    **/
    public static void deleteAllRestrictionMtMRecords(List<Contact> deletedContacts) {
            
        //List to hold the Restriction MtM records
        List<Restricted_MtM__c> restrictedMtms = [SELECT ID FROM Restricted_MtM__c WHERE Contact__c != null AND Contact__c IN : deletedContacts];
        
        //Checking list for size value
        if(restrictedMtms != null && restrictedMtms.size() > 0)
            delete restrictedMtms;
    }
         
    /**
    *  @description    :   This method is to resed the credit card agreement to user if it was bounced earlier and now correct email is being entered in the system
    *
    *  @args           :   List of nec Contacts, Map of old Contacts
    *
    *  @return         :   void
    *
    **/
    public static void resendBouncedAgreement(List<Contact> contacts, Map<Id, Contact> mapOldContacts) {
            
        //Create a set of the contacts where email Id is being updated and Contact  is Active
        Set<Id> setContactIds = new Set<Id>();
        
        //Loop through the contacts
        for(Contact contact : contacts) {
            
            //Check for the email change
            if(String.isNotBlank(contact.Email) && contact.Email != mapOldContacts.get(contact.Id).Email) {
                
                //Add in set
                setContactIds.add(contact.Id);
            }
        }
            
        //Check for the set size
        if(setContactIds.size() > 0) {
            
            //Map to hold the latest agreement event record for each contact
            Map<Id, echosign_dev1__SIGN_AgreementEvent__c> mapContactWithAgreementEvent = new Map<Id, echosign_dev1__SIGN_AgreementEvent__c>();
            
            //Query last agreement event record for these contacts
            for(echosign_dev1__SIGN_AgreementEvent__c agreement : [Select Id, echosign_dev1__SIGN_Agreement__r.OSR__c, echosign_dev1__SIGN_Agreement__r.echosign_dev1__Recipient__c, echosign_dev1__Description__c from echosign_dev1__SIGN_AgreementEvent__c where echosign_dev1__SIGN_Agreement__r.echosign_dev1__Recipient__c IN: setContactIds Order By CreatedDate DESC]) {
                
                //Add in Map
                if(!mapContactWithAgreementEvent.containsKey(agreement.echosign_dev1__SIGN_Agreement__r.echosign_dev1__Recipient__c))
                    mapContactWithAgreementEvent.put(agreement.echosign_dev1__SIGN_Agreement__r.echosign_dev1__Recipient__c, agreement);
            }
            
            //Map to hold the contacts and OSR to resend
            Map<Id, echosign_dev1__SIGN_AgreementEvent__c> mapOSRForAgreementToResendWithContacts = new Map<Id, echosign_dev1__SIGN_AgreementEvent__c>();
            
            //Loop through the agreements and check if the last agreement was failed because of bounce
            for(echosign_dev1__SIGN_AgreementEvent__c agreement : mapContactWithAgreementEvent.values()) {
                
                //Check for the description
                if(String.isNotBlank(agreement.echosign_dev1__Description__c) && agreement.echosign_dev1__Description__c.startsWith('Advisory Board Credit Card Agreement email bounced')) {
                    
                    //add in set
                    mapOSRForAgreementToResendWithContacts.put(agreement.echosign_dev1__SIGN_Agreement__r.OSR__c, agreement);
                }
            }
            
            //Check for the size
            if(mapOSRForAgreementToResendWithContacts.size() > 0) {
                
                //Fetch the OSR Records
                List<OSR__c> oSRs = [Select Id, Status__c, Request_Type__c, Contact__c from OSR__c where Id IN: mapOSRForAgreementToResendWithContacts.keySet()];
                for(OSR__c oSR : oSRs) {
                    
                    //Set the attributes so OSR trigger can be executed
                    oSR.Status__c = CreditCardConstants.OSR_STATUS_NEW;
                    oSR.Request_Type__c = CreditCardConstants.OSR_REQUEST_TYPE_NEW_ABC_CREDIT_CARD;
                }
                
                //Call send agreement methods
                ContactTriggerUtilities.EXECUTE_RESEND_BOUNCED_AGREEMENT = false;
                OSRTriggerHelper.sendAgreementForNewOSR(oSRs);
            }
        }
    }
        
    //Added by - Subhash Garhwal - 07/02/2015 - CR-20150618-9014 
    /**
    *  @decription :   This method is used to update all the related Staff Assignments name, if contact name is changed.
    *                  For this we will blank update all the related Staff Assignments, do to this Renaming workflow will execute and update SA names according    
    *
    *  @args       :   List<Contact>, Map<Id, Contact>
    *
    *  @return     :   void
    *
    **/
    public static void updateStaffAssignment(List<Contact> contacts, Map<Id, Contact> mapOldContacts) {
        
        //Set to hold Contact Ids
        Set<Id> setConIds = new Set<Id>();
        
        //Loop through contacts
        for(Contact con : contacts) {
            
            //Check for appropriate condition
            if(con.FirstName != mapOldContacts.get(con.Id).FirstName || con.LastName != mapOldContacts.get(con.Id).LastName)
                setConIds.add(con.Id);
        }
        
        //Check for set size
        if(setConIds.size() > 0) {
            
            //List of Staff Assignment
            List<Team_Membership__c> teamMemberships = [Select Id, Staff_member__r.FirstName, Staff_member__r.LastName, Role__c,
                                                        Role__r.Name From Team_Membership__c Where Staff_member__c IN : setConIds];
            
            //Loop through Staff Assignment
            for(Team_Membership__c tM : teamMemberships)
                tM.Name = Util.parseNull(tM.Staff_member__r.FirstName) + ' ' + Util.parseNull(tM.Staff_member__r.LastName) + '-' + Util.parseNull(tM.Role__r.Name);
            
            //Check for list size
            if(teamMemberships.size() > 0)
                update teamMemberships;
        }
    }
        
    /**
    *  @description    : This Method update the related Research Study Interaction if Institution is changed 
    * 
    *  @args           : List of new Contact instance, Map of old Contact Id and instance 
    * 
    *  @return         : void
    **/
    public static void populateInstitutionLookUpFieldForNPD(List<Contact> listNewContact, Map<Id,Contact> mapOldContact){
        
        //Fetch the NPD record type Id
        List<RecordType> rTypeNPD = [Select Id from RecordType where DeveloperName = 'NPD' AND SObjectType = 'Syndicated_Research_Interaction__c' AND IsActive = true limit 1];
        
        //Set to hold contact Id's
        Set<Id> setContactIds = new Set<Id>();
        
        //List to hold Research study Interaction records to be updated
        List<Syndicated_Research_Interaction__c> listRSItoBeUpdated = new List<Syndicated_Research_Interaction__c>();
        
        //loop through Trigger.New
        for(Contact con : listNewContact) {
            
            //Check for condition
            //Populate the set to hold Contact Id 
            if(mapOldContact.containsKey(con.Id) && con.AccountId != mapOldContact.get(con.Id).AccountId )
                setContactIds.add(con.Id);
        }
        
        //Check for size
        if(setContactIds.size() > 0) {
            
            //Fetch contact's childs(RSI)
            for(Syndicated_Research_Interaction__c rSI : [SELECT Id, Institution__c, RecordTypeId, Contact__r.AccountId FROM Syndicated_Research_Interaction__c WHERE Contact__c IN : setContactIds ]) {
                
                //Check for NPD record type then populate the institution lookup field on RSI with associated COntact's institution
                if(rTypeNPD.size() > 0 && rSI.RecordTypeId == rTypeNPD[0].Id ) {
                    rSI.Institution__c = rSI.Contact__r.AccountId;
                    
                    //Populate the list listRSItoBeUpdated
                    listRSItoBeUpdated.add(rSI);
                }
            }
        }
        
        //Check for size
        if(listRSItoBeUpdated.size() > 0) {
            
            //Bypass all triggers
            Util.BypassAllTriggers = true;
            
            //Update RSI's
            update listRSItoBeUpdated;
            
            //Enable all the triggers
            Util.BypassAllTriggers = false;
        }
    }
        
    //Manual Merger By - Rajeev Jain -11/09/2015
    //Added by - Padmesh Soni - 17/08/2015 - CR-20150729-9114 
    //V_1.11 - Modified By - Rajeev Jain - 04/202/016 - CR-20151120-9402 - Modified createIncentiveChangeLog method logic as per the updated SDD of Change Management.
    /**
    *  @decription  :  This method is used to create Incentive Change Log Records when contacts are created or updated Names
    *                   
    *
    *  @args    :  List<Contact>, Map<Id, Contact>
    *
    *  @return    :  void
    *
    **/
    public static void createIncentiveChangeLog(List<Contact> contacts, Map<Id, Contact> mapOldContacts) {
        
        //List of Incentive Change logs
        List<Incentive_Change_Log__c> incentiveChangeLogs = new List<Incentive_Change_Log__c>();
        
        //Request on Contact in order to get info of Contact's User Record
        Map<Id, Contact> mapContacts = new Map<Id, Contact>([select id, Employee_User_Record__r.IsActive 
                                                                from Contact where ID IN : contacts AND Employee_User_Record__c != null]);
       
        //Loop through contacts
        for(Contact con : contacts) {
            
            //Handle for Newly inserting record
            if(mapOldContacts == null && mapContacts != null && mapContacts.containsKey(con.Id) && mapContacts.get(con.Id).Employee_User_Record__r.IsActive){
                incentiveChangeLogs.add(new Incentive_Change_Log__c(Contact__c = con.Id, Change_Type__c = ISSPConstants.INCENTIVE_CHANGE_LOG_CHANGE_TYPE_NEW, 
                                                                    Change_Element__c = ISSPConstants.INCENTIVE_CHANGE_LOG_CHANGE_ElEMENT_CONTACT));
            
            //Handle for Update Case                                                        
            }else if(mapOldContacts != null && con.Employee_User_Record__c != null && 
                        mapContacts.containsKey(con.Id) && mapContacts.get(con.Id).Employee_User_Record__r.IsActive){
                
                //Check change in Employement Start Date
                if(con.Employment_Start__c != mapOldContacts.get(con.Id).Employment_Start__c)
                    incentiveChangeLogs.add(new Incentive_Change_Log__c(Contact__c = con.Id, Change_Type__c = ISSPConstants.INCENTIVE_CHANGE_LOG_CHANGE_TYPE_MODIFIED, 
                                                                    Change_Element__c = ISSPConstants.INCENTIVE_CHANGE_LOG_CHANGE_ElEMENT_CONTACT,
                                                                    Change_Value__c = ISSPConstants.INCENTIVE_CHANGE_LOG_CHANGE_VALUE_START_DATE,
                                                                    Start_Date__c = con.Employment_Start__c));  
                if(con.Employment_Termination__c != mapOldContacts.get(con.Id).Employment_Termination__c)
                    incentiveChangeLogs.add(new Incentive_Change_Log__c(Contact__c = con.Id, Change_Type__c = ISSPConstants.INCENTIVE_CHANGE_LOG_CHANGE_TYPE_MODIFIED, 
                                                                    Change_Element__c = ISSPConstants.INCENTIVE_CHANGE_LOG_CHANGE_ElEMENT_CONTACT,
                                                                    Change_Value__c = ISSPConstants.INCENTIVE_CHANGE_LOG_CHANGE_VALUE_END_DATE,
                                                                    End_Date__c = con.Employment_Termination__c));  
            }
        }
        
         //Check list Size for insert
        if(incentiveChangeLogs.size() > 0)
            insert incentiveChangeLogs;
    }
    //Manual Merger By - Rajeev Jain -11/09/2015 - upt to here

    //Added By - Mahendra Swarnkar - 5/30/2016 - CR-20151209-9452 - Release 51
    /**
    *  @decription  :   This method is used to Populate the "Marketing Asssociated Sign Off Date" value on User record with 
    *                   "Marketing Asssociated Sign Off Date" field value on the contact on the basis of the "Employee User Record" field value on the contact              
    *                  
    *  @args        :   List<Contact>, Map<Id, Contact>
    *
    *  @return      :   void
    *
    **/
    public static void populateMASignOffDateOnUser(List<Contact> contacts, Map<Id, Contact> mapOldContacts) {
        
        //Map to hold the User records
        Map<Id, User> mapUsers = new Map<Id,User>();
        Map<Id, Contact> mapContacts = new Map<Id, Contact>();
        Map<Id, Contact> mapContactsToUpdate = new Map<Id, Contact>();
        
        //Loop through contacts
        for(Contact con : contacts != null ? contacts : mapOldContacts.values()) {
            
            //Insert and Update case
            if(contacts != null) {
                
                //Check that a contact is of "Employee" record type and 
                //1) new Contact is inserted and Employee_User_Record__c is not blank
                //2) User associated with the Contact is changed
                //3) Contact record type is changed to "Employee" 
                //4) User associated with the Contact is not blank and Marketing_Associate_Sign_Off_Date__c field vlue is changed
                if(con.RecordTypeId == Util.RecordTypeId('Contact', 'Employee')
                    &&(mapOldContacts == null 
                        ||(mapOldContacts != null
                            && (
                                con.Employee_User_Record__c != mapOldContacts.get(con.Id).Employee_User_Record__c
                                || 
                                con.Marketing_Associate_Sign_Off_Date__c != mapOldContacts.get(con.Id).Marketing_Associate_Sign_Off_Date__c 
                                || 
                                con.RecordTypeId != mapOldContacts.get(con.Id).RecordTypeId
                            	)
                          )
                      )
                ) {
                    
                	//Checking for employee user records
                    if(con.Employee_User_Record__c != null) {
                       
                        //Populating map with new instance
                        mapUsers.put(con.Employee_User_Record__c, 
                        	new User(Id =con.Employee_User_Record__c, Marketing_Associate_Sign_Off_Date__c = null ));
                       
                        //Populating map with old instance
                        if(mapOldContacts != null && mapOldContacts.containsKey(con.Id)
                            && mapOldContacts.get(con.Id).RecordTypeId == Util.RecordTypeId('Contact', 'Employee') 
                            && mapOldContacts.get(con.Id).Employee_User_Record__c != null )
                            mapUsers.put(mapOldContacts.get(con.Id).Employee_User_Record__c , new User(Id = mapOldContacts.get(con.Id).Employee_User_Record__c, Marketing_Associate_Sign_Off_Date__c = null ));
                    } else
                        mapContacts.put(con.Id, con);
                }    
            }
        }
            
        //Loop through contacts
        for(Contact cont : contacts) {
                
            //check that a user is associated with the contact, then
            // Populate the Marketing_Associate_Sign_Off_Date__c field on the User record with the Marketing_Associate_Sign_Off_Date__c field value on the contact record
            if(cont.Employee_User_Record__c != null 
            	&& mapUsers.containsKey(cont.Employee_User_Record__c)
               	&& mapUsers.get(cont.Employee_User_Record__c) != null) {
            	
                //Checking if contact if of employeee type    
                if(cont.RecordTypeId == Util.RecordTypeId('Contact', 'Employee')) {
                   mapUsers.get(cont.Employee_User_Record__c).Marketing_Associate_Sign_Off_Date__c = cont.Marketing_Associate_Sign_Off_Date__c;
                } else {
                    
                   //Populate the Marketing_Associate_Sign_Off_Date__c field on the User record
                   if(mapUsers.get(cont.Employee_User_Record__c).Marketing_Associate_Sign_Off_Date__c != null)
                       mapUsers.get(cont.Employee_User_Record__c).Marketing_Associate_Sign_Off_Date__c = null;
                
                }    
            }
               
            //Checking if "employee user contact" field is having null value with it
            if(cont.Employee_User_Record__c == null 
            	&& cont.RecordTypeId == Util.RecordTypeId('Contact', 'Employee')
                && mapContacts.containsKey(cont.Id)
                && mapContacts.get(cont.Id) != null
            ) {
                if(mapContacts.get(cont.Id).Marketing_Associate_Sign_Off_Date__c != null) {
                    Contact c = new Contact(Id = cont.Id);
                    c.Marketing_Associate_Sign_Off_Date__c = null;
                	mapContactsToUpdate.put(c.Id, c);    
                }        
            }
        }
        
        //Checking list for size value
        if(mapUsers.values() != null && mapUsers.values().size() > 0) {
            
    		//Disable all the triggers
            Util.BypassAllTriggers = true;
                        
            //Update the User records
            update mapUsers.values();
            
            //Enable all the triggers
            Util.BypassAllTriggers = false;        
        }
        
        //Checking list for size value
        if(mapContactsToUpdate.values() != null && mapContactsToUpdate.values().size() > 0) {
            
    		//Disable all the triggers
            Util.BypassAllTriggers = true;
            
            //Update the User records
            update mapContactsToUpdate.values();
            
            //Enable all the triggers
            Util.BypassAllTriggers = false;
        }
    }
}