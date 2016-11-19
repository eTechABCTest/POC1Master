/**
Desription      :   Contains Helper methods for site functionality relating to Contacts  (ie: EAB.com/Advisory.com).

Created By      :   Victor Hanson

Created Date    :   08/07/2014

Revision Logs   :   v1 - Created
**/ 
public class ContactSiteHelper {
    
    public final static Set<String> CHANGEFIELDS = new Set<String> { 'AccountId','Email' };
    public final static string ELOQUA_STATUS_PRIMARY = 'Eloqua Hard Bounce - Primary';
    public final static string ELOQUA_STATUS_PREFERRED = 'Eloqua Hard Bounce - Preferred';
    
    /**
    * @description:	Send change email notification when Status is Hard Bounce and the eloqua hard bounce email or eloqua status changes from primary
    *
    * @params: 		list of new contacts, map of old contacts
    **/
    private static map<Id, Site_Profile__c> checkEloquaStatus(list<Contact> newContacts, map<Id, Contact> oldContactMap, map<Id, Contact> contactsWithSiteProfileMap, map<Id, Site_Profile__c> siteProfilesToUpdate) {
        //get all contacts with site profiles
        map<Id, Contact> contactWithSiteProfileMap = getContactsWithSiteProfiles(newContacts);
        
        for (Contact newCon : newContacts) {
            Contact oldCon;
            if (oldContactMap != null) oldCon = oldContactMap.get(newCon.Id);
            Contact conWithSiteProfile = contactWithSiteProfileMap.get(newCon.Id);
            list<Site_Profile__c> siteProfiles = conWithSiteProfile.Site_Profiles__r;
            for (Site_Profile__c sProfile : siteProfiles) {
            	if (siteProfilesToUpdate.containsKey(sProfile.Id)) sProfile = siteProfilesToUpdate.get(sProfile.Id);
                if (sProfile.Status__c == 'Hard Bounce'
                    && 
                    ((
                        oldCon.Eloqua_Hard_Bounce_Email__c == oldCon.Email
                        && newCon.Eloqua_Hard_Bounce_Email__c != newCon.Email
                    )
                     ||
                     (
                         sProfile.Status__c != null 
                         && oldCon.Eloqua_Status__c != null
                         && oldCon.Eloqua_Status__c.EqualsIgnoreCase(ELOQUA_STATUS_PRIMARY)
                         && newCon.Eloqua_Status__c != oldCon.Eloqua_Status__c)
                    )) 
                {
                    string notificationType = 'sendNewEmailVerification';
                    
                    //if the username was not changed, send the password reset email
                    if(oldCon.Email == newCon.Email) notificationType = 'sendPasswordResetEmail';
                    
                    sProfile.Status__c = SiteProfileTriggerHelper.SITE_PROFILE_STATUS_IN_PROGRESS;
                    SiteUserHelper.setVerificationStatus(newCon, sProfile);
                    SiteUserHelper.SendVerificationEmail(newCon, sProfile, notificationType, false);
                    
                    siteProfilesToUpdate.put(sProfile.Id, sProfile);
                }
            }
        }
        
        return siteProfilesToUpdate;
    }
    
    /**
    * @description	:	if the Contact Email or bypass domain validation flag is changed, update all Site Profile Usernames to match the Contact Email.
    * 
    * @params		:	contact list, contact map
    * 
    **/
    public static void updateSiteProfilesFromContact(List<Contact> newContacts, map<Id, Contact> oldContactMap) {
        
        map<Id, Site_Profile__c> mapSiteProfilesToUpdate = new map<Id, Site_Profile__c>();
        
        map<id, Contact> contactsWithSiteProfile = getContactsWithSiteProfiles(newContacts);
        
        // check each contact and update accordingly
        for (Contact newCon : newContacts) {
            
            //get the old contact
            Contact oldCon;
            if (oldContactMap != null) oldCon = oldContactMap.get(newCon.Id);
            
            //get the contact with site profiles
            Contact conWithSiteProfiles = contactsWithSiteProfile.get(newCon.Id);
            list<Site_Profile__c> siteProfileList = conWithSiteProfiles.Site_Profiles__r;
            
            //the email or bypass domain validation flag changed and there are related site profiles
            if (oldCon != null 
              && (oldCon.Email != newCon.Email && siteProfileList.size() > 0
              || oldCon.Bypass_Domain_Validation__c != newCon.Bypass_Domain_Validation__c)) 
            {
                for (Site_Profile__c sProfile : siteProfileList) {
                	if (mapSiteProfilesToUpdate.containsKey(sProfile.Id)) continue;
                	
                    mapSiteProfilesToUpdate.put(sProfile.Id, sProfile);
                    
                    sProfile.Username__c = newCon.Email;
                    sProfile.Bypass_Domain_Validation__c = newCon.Bypass_Domain_Validation__c;
                    
                    if (sProfile.Status__c != SiteProfileTriggerHelper.SITE_PROFILE_STATUS_INACTIVE && oldCon.Email != newCon.Email) {
                    	SiteUserHelper.setVerificationStatus(newCon, sProfile);
                        SiteUserHelper.SendVerificationEmail(newCon, sProfile, 'sendNewEmailVerification', false);
                    }
                }
            }
            
            //if this is a hard bounce email -- update the site profiles to hard bounce.
            if (newCon.Email == newCon.Eloqua_Hard_Bounce_Email__c) {
                for (Site_Profile__c sProfile : siteProfileList) {
                    //only set the status to hard bounce if the status != Inactive
                    if (sProfile.Status__c != SiteProfileTriggerHelper.SITE_PROFILE_STATUS_INACTIVE) {
                        sProfile.Status__c = SiteProfileTriggerHelper.SITE_PROFILE_STATUS_HARD_BOUNCE;
                        mapSiteProfilesToUpdate.put(sProfile.Id, sProfile);
                    }
                }
            }
        }
        
        //check the eloqua status for all site profiles and update as needed
        mapSiteProfilesToUpdate = checkEloquaStatus(newContacts, oldContactMap, contactsWithSiteProfile, mapSiteProfilesToUpdate);
        
        if (mapSiteProfilesToUpdate.size() > 0) {
            try {
            	SiteProfileTriggerHelper.hasSynchronizedSiteProfile = true;
                update mapSiteProfilesToUpdate.values();
                SiteProfileTriggerHelper.hasSynchronizedSiteProfile = false;
            }
            catch(DMLException ex) {
                newContacts[0].addError(ex.getDMLMessage(0), false);
            }
            catch(Exception ex) {
                newContacts[0].addError(ex.getMessage());
            }
        }
        
    }
    
    /**
     * @description:	return a map of contact id -> contact with related site profiles.
     * 
     **/
    public static map<Id, Contact> getContactsWithSiteProfiles(list<Contact> contacts) {
    	list<Contact> cons = database.query('SELECT Id, Email,'
                                                         + ' (SELECT Id, Status__c, Username__c, User_Id__c, User_Id_Autonumber__c, User_Id_Override__c, Type__c, Bypass_Domain_Validation__c,'
                                                         + ' Contact__r.Account.EAB_com_Organization_Status__c, Contact__r.Account.Advisory_com_Organization_Status__c, '
                                                         + ' Send_Password_Notification__c, Verify__c'
                                                         + ' FROM Site_Profiles__r) '
                                                         + ' FROM Contact '
                                                         + ' WHERE Id IN :contacts');
        map<Id, Contact> contactsWithSiteProfiles = new map<Id, Contact>(cons);
        return contactsWithSiteProfiles;
    }
    
    //count the number of times the institution change is checked
    public static boolean hasCheckedInstitutionChange = false;
    
    // check to see if institution has been changed
    public static void CheckInstitutionChange(list<Contact> newContacts, Map<Id, Contact> oldContactMap) {
    	system.debug('@@@hasCheckedInstitutionChange:' + hasCheckedInstitutionChange);
        if (hasCheckedInstitutionChange) return;
        hasCheckedInstitutionChange = true;
        
        // create a new contact stub
        Contact newContactToInsert;
        Set<Id> institutionIdSet = new Set<Id>();
        list<Site_Profile__c> siteProfilesToInsert = new list<Site_Profile__c>();
        
        //get a map of contacts with site profiles
        map<id, Contact> contactsWithSiteProfile = getContactsWithSiteProfiles(newContacts);
        
        //Return if there are no old contacts
        if (oldContactMap == null) return;
        
        //Pull the old/new institution ids of any contacts that are changing institution
        set<Id> AcctIdSet = new set<Id>();
        for (Contact newCon : newContacts) {
            if (oldContactMap.containsKey(newCon.Id)) {
            	Contact oldCon = oldContactMap.get(newCon.Id);
                Contact conWithSiteProfiles = contactsWithSiteProfile.get(newCon.Id);
                if (oldCon.AccountId != newCon.AccountId 
                && conWithSiteProfiles.Site_Profiles__r != null 
                && conWithSiteProfiles.Site_Profiles__r.size() > 0) 
                {
                    AcctIdSet.add(oldCon.AccountId);
                    AcctIdSet.add(newCon.AccountId);
                }
            }
        }
        
        system.debug('@@@AcctIdSet:' + AcctIdSet);
        
        //Return if there are no records in our list -- this means no contacts changed institution
        if (AcctIdSet.size() == 0) return;
        
        //Assuming there are results, query for the old/new account so we can compare the top parent fields.
        map<Id, Account> acctMap = new map<Id, Account>([SELECT Id, Top_Parent_Institution__c FROM Account WHERE Id IN :AcctIdSet]);
        
        //Updated by Ajit Surana -02/13/2014 - CR-20130911-3629
        //Set to hold the old contacts ownerId
        Set<Id> setOldContactOwnerIds  = new Set<Id>();
        
        // assume the institution is not being updated
        boolean updatedInstitution = false;
        
        // Step 1: Check the hierarchy to see if it changed -- if not, return immediately and don't continue to next step
        for (Contact contact : newContacts) {
            
            Contact oldContact = oldContactMap.get(contact.Id);
            
            //Get the old and new accounts so we can see if the Top Parent is the same
            Account newAcct = acctMap.get(contact.AccountId);
            Account oldAcct = acctMap.get(oldContact.AccountId);
            
            //Check to see if the new Contact's accountId is completely unrelated to the old Contact's accountId
            if (contact.AccountId != oldContact.AccountId
                && (
                    (newAcct.Top_Parent_Institution__c != null && oldAcct.Top_Parent_Institution__c != null && newAcct.Top_Parent_Institution__c == oldAcct.Top_Parent_Institution__c)
                    || (oldAcct.Top_Parent_Institution__c != null && newAcct.Id == oldAcct.Top_Parent_Institution__c)
                    || (newAcct.Top_Parent_Institution__c == oldAcct.Id)
                )
              )
            {
                updatedInstitution = false;
            }
            else {
                system.debug('@@InstitutionOld:' + oldContact.AccountId + ' InstNew:' + contact.AccountId);
                updatedInstitution = true;
                
                //Updated by Ajit Surana -02/13/2014 - CR-20130911-3629
                //Populate set with contact owner Id value
                setOldContactOwnerIds.add(oldcontact.OwnerId);
            }
        }
        
        system.debug('@@@updatedInstitution:' + updatedInstitution);

        // if the institution is not being updated, return immediately
        if (updatedInstitution == false) return;
        
        //Updated by Ajit Surana -02/13/2014 - CR-20130911-3629
        //Check for size value
        if(setOldContactOwnerIds.size() > 0) {
            
            //Updated by Ajit Surana -02/13/2014 - CR-20130911-3629
            //Map of users
            Map<Id, User> mapUsers = new Map<Id, User>([Select Id, isActive FROM USER WHERE ID IN : setOldContactOwnerIds]); 
            System.debug('@@@@@ mapUsers ' + mapUsers);
            
	        //get accounts for domain eligibility check
		    acctMap = SiteProfileTriggerHelper.getAccountsWithEligibleDomains(AcctIdSet);
            
            // Step 2: set existing contact status to inactive
            for (Contact contact : newContacts) {
                Contact oldContact = oldContactMap.get(contact.Id);
                
                //check domain validity
                boolean isEligible = SiteUserHelper.hasEligibleDomain(acctMap.get(contact.AccountId), contact.Email);
                if (!isEligible && !contact.Bypass_Domain_Validation__c) {
                	contact.addError(SiteUserHelper.ERROR_INVALID_DOMAIN_USER_MESSAGE);
                	return;
                }
                
                //Updated by Ajit Surana -02/13/2014 - CR-20130911-3629
                //Check if Owner Id is not null
                if(mapUsers.get(oldContact.OwnerId) != null) {
                    
                    //Check if User is not Active
                    if(!mapUsers.get(oldContact.OwnerId).IsActive) {
                        contact.OwnerId = UserInfo.getUserId();
                        newContactToInsert = contact.clone();
                        //System.debug('@@@@@ newContactToInsert ' + newContactToInsert);
                    } else {
                        //Clone contact
                        newContactToInsert = contact.clone();
                    }
    
                    // set the newContactToInsert back to the original institution which will serve as the historic record of this adv.com user
                    newContactToInsert.AccountId = oldContact.AccountId;
                    newContactToInsert.Email = DeactivateEmailString(oldContact.Email);
                    newContactToInsert.Contact_Status__c = 'Inactive';
                    
                    //Added By - Abhinav Sharma - 08/13/2014 - CR-20140604-5691
                    //Starts from here
                    newContactToInsert.Bypass_Filters__c = true;
                    //UpTo Here
                    
                    //insert the new contact
                    CRMfusionDBR101.DB_Globals.triggersDisabled = true;
                    Util.BypassAllTriggers = true;
                    insert newContactToInsert;
                    
                    
                    //clone the site profiles
                    for (Site_Profile__c sp : contactsWithSiteProfile.get(contact.Id).Site_Profiles__r) {
                    	Site_Profile__c spClone = sp.clone();
                    	spClone.Contact__c = newContactToInsert.Id;
	                    spClone.Status__c = 'Inactive';
	                    spClone.Type__c = sp.Type__c;
	                    spClone.Username__c = newContactToInsert.Email;
	                    spClone.User_Id_Override__c = decimal.valueOf(sp.User_Id__c);
	                    siteProfilesToInsert.add(spClone);
                    }
                    
                    // insert the new site profiles
                    // bypass dupeblocker
                    CRMfusionDBR101.DB_Globals.triggersDisabled = true;
                    Util.BypassAllTriggers = true;
                    insert siteProfilesToInsert;
                    Util.BypassAllTriggers = false;
                    
                    
                    
                    //get the site profiles that were inserted so we can take the new autonumber and apply it to our site profile that is moving institutions.
                    for (Site_Profile__c sp : database.query('SELECT Id, User_Id_Autonumber__c, User_Id__c, Status__c, Contact__c, Verify__c, Password_Reset_Token__c, Send_Password_Notification__c, Type__c FROM Site_Profile__c WHERE Id IN :siteProfilesToInsert')) {
                        for (Site_Profile__c sProfile : contactsWithSiteProfile.get(contact.Id).Site_Profiles__r) {
                            if (sProfile.User_Id__c == sp.User_Id__c) {
                                sProfile.User_Id_Override__c = decimal.valueOf( (string) sp.get('User_Id_Autonumber__c') );
                                SiteUserHelper.SendVerificationEmail(contact, sProfile, 'sendPasswordResetEmail', true);
                            }
                        }
                    }
                    
                }
            }
        }
    }
    
    
    // take an email address and convert it to an inactive address 'abc@aol.com' -> 'abc_inactive@aol.com'
    public static String DeactivateEmailString(String emailAddress) {
        
        //Updated by Ajit Surana -02/12/2014 - CR-20130807-3381
        //Check if emailAddress is Null and return immediately
        if(String.isBlank(emailAddress))
            return null;
            
        List<String> emailParts = emailAddress.split('@');
        
        // build our email search string
        String emailSearch = emailParts[0] + '%@' + emailParts[1];
        // determine the numeric value that needs to be added to the end
        List<Contact> inactiveContacts = [SELECT Id, Email FROM Contact WHERE Email LIKE :emailSearch ORDER BY Email DESC LIMIT 100];

        String emailAddition = '';
        if (inactiveContacts.size() > 0) {
            system.debug('@@inactiveContacts[0]:' + inactiveContacts[0]);
            String latestEmail = inactiveContacts[0].Email.split('@')[0];
            list<string> parts = latestEmail.split('_inactive');
            if (parts.size() > 1) {
                // we can assume the we have parsed out a numeric value because the email addresses are like 'abc_inactive3@aol.com' if the contact was moved 3 times
                integer appendNumber = Integer.valueOf(parts[1]);
                appendNumber++;
                emailAddition = string.valueOf(appendNumber);
            }
            else emailAddition = '1';
        }
        else emailAddition = '1';


        emailAddress = emailParts[0] + '_inactive' + emailAddition + '@' + emailParts[1];
        return emailAddress;
    }
}