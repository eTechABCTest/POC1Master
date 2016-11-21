/**
Desription      :   Helper class for the SiteProfile trigger

Created By      :   Victor Hanson

Created Date    :   08/01/2014

Revision Logs   :   v1 - Created
                :   v1.1 - Modified By - Ajit Surana - 02/05/2015 - CR-20141016-7784
                :   v1.2 - Modified By - Ajit Surana - 04-29-2015 - CR-20150415-8874
                :   v1.3 - Modified By - Mark Szurlej - 08-18-2015 - CR-20150414-8873
				:   v1.4 - Modified By - Abhinav Sharma - 11/27/2015 - CR-20151118-9393
**/ 
public class SiteProfileTriggerHelper {
    
    /** Constants **/
    public final static string NOTIFICATION_TYPE_NEW_USER = 'New User';
    public final static string NOTIFICATION_TYPE_EMAIL_CHANGE = 'Email Change';
    public final static string NOTIFICATION_TYPE_PASSWORD_RESET = 'Password Reset';
    public final static string SITE_PROFILE_STATUS_ACTIVE = 'Active';
    public final static string SITE_PROFILE_STATUS_IN_PROGRESS = 'In Progress';
    public final static string SITE_PROFILE_STATUS_INACTIVE = 'Inactive';
    public final static string SITE_PROFILE_STATUS_HARD_BOUNCE = 'Hard Bounce';
    public final static string ERROR_INVALID_DOMAIN = 'Domain is not eligible for this Site Profile.';
    public final static string SITE_PROFILE_RT_ID_MYROYALL = Schema.SObjectType.Site_Profile__c.getRecordTypeInfosByName().get('MyRoyall').getRecordTypeId();
    
    /**
     * @description:    cache a map of Id to Contacts related to Site Profiles
     * 
     **/
    public static map<Id, Contact> mapSPContacts { get; set; }
    public static map<Id, Contact> getMapSPContacts(list<Site_Profile__c> sProfiles) {
        if (mapSPContacts == null) {
            //get contacts and set verification status
            set<Id> contactIds = new set<Id>();
            for (Site_Profile__c sp : sProfiles) {
                contactIds.add(sp.Contact__c);
            }
            mapSPContacts = new map<Id, Contact>([SELECT Id, Email, Contact_Status__c, AccountId, Site_User__c, Bypass_Domain_Validation__c,
                                                  (SELECT Id, Name, Username__c, Status__c, Bypass_Domain_Validation__c, Organization_Status__c, Verify__c, Type__c 
                                                   FROM Site_Profiles__r WHERE Id NOT IN :sProfiles) 
                                                  FROM Contact WHERE Id IN :contactIds]);
        }
        return mapSPContacts;
    }
    
    /**
     * @description:    variable that allows us to bypass the SiteProfile trigger
     * 
     **/
    public static boolean bypassSiteProfileTrigger {
        get {
            if (bypassSiteProfileTrigger == null) bypassSiteProfileTrigger = false;
            return bypassSiteProfileTrigger;
        }
        set;
    }
    
    //this method executes whenever a site profile is created internally.  Checks to see if the domain is valid for the username specified.
    public static void createSiteProfile(list<Site_Profile__c> newListSiteProfiles) {
        
        //list of site users to insert
        list<Site_User__c> siteUsers = new list<Site_User__c>();
        
        //list of contacts to update
        map<Id, Contact> mapContactsToUpdate = new map<Id, Contact>();
        
        //get the account w/eligible domains
        set<Id> accountIds = new set<Id>();
        
        //get related contact ids
        set<Id> contactIdSet = new set<Id>();
        for (Site_Profile__c sProfile : newListSiteProfiles) {
            contactIdSet.add(sProfile.Contact__c);
            if (sProfile.r_Institution__c != null) accountIds.add(sProfile.r_Institution__c);
        }
        
        //get the contact including all related site profiles
        map<Id, Contact> contacts =  new map<Id, Contact>((List<Contact>)database.query(SiteUserHelper.CONTACTBASEQUERY + ' WHERE  Id IN :contactIdSet'));
        
        
        for (Contact c : contacts.values()) accountIds.add(c.AccountId);
        map<Id, Account> accountMap = getAccountsWithEligibleDomains(accountIds);
        
        //loop through each profile, pull the contact, and determine if they are eligible
        for (Site_Profile__c sProfile : newListSiteProfiles) {
            
            //get the related contact w/site profiles
            Contact c = contacts.get(sProfile.Contact__c);
            
            //vh 6/23/16: set the account based on the contact, unless the SP (royall) institution lookup is populated
            Account a = accountMap.get(c.AccountId);
            if (sProfile.r_Institution__c != null) a = accountMap.get(sProfile.r_Institution__c);
            
            //verify the contact isn't already associated with a Site Profile of the same type
            for (Site_Profile__c existingSiteProfile : c.Site_Profiles__r) {
                if (existingSiteProfile.Type__c == sProfile.Type__c && sProfile.RecordTypeId != SITE_PROFILE_RT_ID_MYROYALL) 
                    sProfile.addError(SiteUserHelper.ERROR_DUPLICATE_SITE_PROFILE_TYPE, false);
            }
            
            //get the organization status
            string orgStatus;
            if (sProfile.Type__c.equalsIgnoreCase(SiteUserHelper.SITE_ADVISORY)) {
                if (a.Advisory_com_Organization_Status__c != null) {
                    orgStatus = a.Advisory_com_Organization_Status__c;
                }
            }
            else if (sProfile.Type__c.equalsIgnoreCase(SiteUserHelper.SITE_EAB)) {
                if (a.EAB_com_Organization_Status__c != null) {
                    orgStatus = a.EAB_com_Organization_Status__c;
                }
            }
            
            //vh 6/23/16: bypass this validation for MyRoyall record type
            //if the organization status != active, return an error
            if ((orgStatus == null || !orgStatus.equalsIgnoreCase('Active')) && sProfile.RecordTypeId != SITE_PROFILE_RT_ID_MYROYALL) {
                sProfile.addError(Label.Site_Profile_Organization_Status_Not_Active);
            }
            
            SiteUser sUser = new SiteUser();
            sUser.Email_Address = sProfile.Username__c;
            sUser.site_Profile = sProfile;
            sUser.Site = sProfile.Type__c;
            
            //only set status to in progress if the status is null            
            if (sProfile.Password__c != null
                && sProfile.Status__c == null && sProfile.RecordTypeId != SITE_PROFILE_RT_ID_MYROYALL) 
            {
                sProfile.Status__c = SITE_PROFILE_STATUS_IN_PROGRESS;
            }
            
            sUser = SiteUserHelper.getSiteUser(c, sUser, false, false);
            
            //check domain eligibility
            boolean isEligible = SiteUserHelper.hasEligibleDomain(a, sUser);
            if (!isEligible) {
                sProfile.addError('The email address provided does not contain a valid domain for that institution.');
            }
            
            //if the domain is eligible, check to see if there is already a Site Profile -- if not, create one
            if (c.Site_User__c == null) {
                Site_User__c siteUser = SiteUserHelper.createNewSite_User(true);
                
                //set the new site user id on the contact and site profile
                c.Site_User__c = siteUser.Id;
                sProfile.Site_User__c = siteUser.Id;
                
            } else {
                sProfile.Site_User__c = c.Site_User__c;
            }
            
            //vh 6/23/16: bypass default settings if this is a myRoyall Site Profile
            if (sProfile.RecordTypeId != SITE_PROFILE_RT_ID_MYROYALL) {
                // set some default values on the contact
                c = SiteUserHelper.UpdateDefaultUserSettings(c, sUser);
                //get the updated status code
                SiteUserHelper.getStatusCode(sUser);
            }
            
            if (!mapContactsToUpdate.containsKey(c.Id))
                mapContactsToUpdate.put(c.Id, c);
        }
        
        
        if (mapContactsToUpdate.size() > 0) {
            Util.BypassAllTriggers = true;
            update mapContactsToUpdate.values();
            Util.BypassAllTriggers = false;
        }
    }
    
    @future
    public static void sendVerificationEmail(set<Id> siteProfileIds) {
        
        list<Site_Profile__c> sProfiles = [SELECT Id, Password__c, Username__c, User_Id__c, Type__c, Status__c, User_Id_Override__c FROM Site_Profile__c WHERE Id IN :siteProfileIds];
        
        //if the site profile's password is set and status is active, don't reset their password as part of the initial insert in to the system.
        for (integer i = 0; i < sProfiles.size(); i++) {
            if (sProfiles[i].Password__c != null
                && sProfiles[i].Status__c != null
                //&& sProfiles[i].Status__c.equalsIgnoreCase(SiteProfileTriggerHelper.SITE_PROFILE_STATUS_ACTIVE)
               ) 
            {
                sProfiles.remove(i);
            }
        }
        
        if (sProfiles.size() > 0)
            sendVerificationEmail(sProfiles, NOTIFICATION_TYPE_NEW_USER, true);
    }
    
    /**
     * @description:    Send verification email to the Site Profile email address when a new Site Profile is created.
     * 
     * @params:         Valid notification types: 'New User', 'Email Change', 'Password Reset'
     */
    public static void sendVerificationEmail(list<Site_Profile__c> newListSiteProfiles, string notificationType, boolean updateSiteProfile) {
        
        for (Site_Profile__c sProfile : newListSiteProfiles) {
            
            SiteUser sUser = new SiteUser();
            sUser.Site = sProfile.Type__c;
            sUser.Email_Address = sProfile.Username__c;
            // set the password reset URL
            string pwResetURL = SiteUserHelper.createPWResetURL(sUser, string.valueOf(sProfile.User_Id__c));
            sProfile.Send_Password_Notification__c = notificationType;
            sProfile.Password_Reset_Token__c = pwResetURL;
        }
        
        if (updateSiteProfile) update newListSiteProfiles;
    }
    
    
    // get the associated Account record
    public static map<Id, Account> getAccountsWithEligibleDomains(set<Id> acctIdSet) {
        return new map<Id, Account>([SELECT Name, Id, Organization_Id__c, Advisory_com_Organization_Status__c, EAB_com_Organization_Status__c,
                                    (Select Id, Qualified_Domain__c, Is_Included__c FROM Eligible_Domains__r WHERE Is_Included__c = true)
                                    FROM Account WHERE Id IN :acctIdSet]);
    }
    
    /**
     * 
     * @description: Added By - Abhinav Sharma - 07/27/2015 - CR-20150629-9034
     * 				 Populate the Site Profile Created By field
     * 
     **/
    public static void updateSiteProfileCreatedBy(list<Site_Profile__c> newListSiteProfiles) {
        
        for (Site_Profile__c sProfile : newListSiteProfiles) {
            if (SiteControllerHelper.IsGuestUser)
                sProfile.Site_Profile_Created_By__c = sProfile.Username__c;
            else
                sProfile.Site_Profile_Created_By__c = UserInfo.getName();
        }
    }
    
    /**
     * @description: check for duplicate site profiles with the same username and type.
     * 
     **/
    public static void siteProfileDupeCheck(list<Site_Profile__c> newListSiteProfiles) {
        //get related contact ids
        set<string> sProfileUsernames = new set<string>();
        set<Id> sProfileIds = new set<Id>();
        for (Site_Profile__c sProfile : newListSiteProfiles) {
            sProfileUsernames.add(sProfile.Username__c);
            sProfileIds.add(sProfile.Id);
        }
        
        //create a map of [Username]+[Type], [SiteProfile] (ie: tUser1@abington.orgAdvisory.com, [Site Profile])
        map<string, Site_Profile__c> emailToSiteProfile = new map<string, Site_Profile__c>();
        //get the profiles with that username. check the username for null to restrict results and prevent query exceptions
        list<Site_Profile__c> siteProfiles = [SELECT Id, RecordTypeId, Name, Username__c, Type__c, Contact__c, Contact__r.Name FROM Site_Profile__c WHERE Username__c != null AND Username__c IN :sProfileUsernames AND Id NOT IN :sProfileIds];
        for (Site_Profile__c sp : siteProfiles) {
            emailToSiteProfile.put(sp.Username__c + sp.Type__c, sp);
        }
        
        for (Site_Profile__c sProfile : newListSiteProfiles) {
            //check for existing site profile with the same username + type
            Site_Profile__c duplicateSiteProfile = emailToSiteProfile.get(sProfile.Username__c+sProfile.Type__c);
            if (duplicateSiteProfile != null && duplicateSiteProfile.RecordTypeId != SITE_PROFILE_RT_ID_MYROYALL) {
                sProfile.addError(SiteUserHelper.ERROR_DUPLICATE_SITE_PROFILE(duplicateSiteProfile), false);
            }
        }
    }
    
    public static boolean hasSynchronizedSiteProfile {
        get {
            if (hasSynchronizedSiteProfile == null) hasSynchronizedSiteProfile = false;
            return hasSynchronizedSiteProfile;
        }
        set;
    }
    
    /**
     * @description:    synchronize differences from the contact to the site profile
     *                  (ie: Bypass domain flag on Contact is checked, make sure the new site profile also gets the bypass domain flag checked)
     * 
     **/
    public static void synchronizeContactWithSiteProfile(list<Site_Profile__c> newListSiteProfiles, map<Id, Site_Profile__c> oldMapSiteProfiles) {
        
        //get contact map
        map<Id, Contact> mapContacts = getMapSPContacts(newListSiteProfiles);
        
        for (Site_Profile__c sp : newListSiteProfiles) {
            //get the old site profile if present
            Site_Profile__c oldSP;
            if (oldMapSiteProfiles != null) oldSP = oldMapSiteProfiles.get(sp.Id);
            //get the related contact
            Contact c = mapContacts.get(sp.Contact__c);
            
            if (oldSP == null 
                && c.Bypass_Domain_Validation__c == true 
                && sp.Bypass_Domain_Validation__c == false) 
            {
                sp.Bypass_Domain_Validation__c = c.Bypass_Domain_Validation__c;
            }
        }
    }
    
    /**
     * @description:    synchronize any username updates back to the Contact and to all related Site Profiles.
     *                  Also, if the bypass domain validation flag is unchecked, check domain eligibility.
     * 
     **/
    public static void synchronizeSiteProfileWithContact(list<Site_Profile__c> newListSiteProfiles, map<Id, Site_Profile__c> oldMapSiteProfiles) {
        system.debug('@@@@@synchronizeSiteProfileWithContact.hasSynchronizedSiteProfile:' + hasSynchronizedSiteProfile);
        if (hasSynchronizedSiteProfile) return;
        hasSynchronizedSiteProfile = true;
        
        //get contact map
        map<Id, Contact> mapContacts = getMapSPContacts(newListSiteProfiles);
        
        //set of all site profile ids that have a new email
        list<Site_Profile__c> sProfilesNeedSync = new list<Site_Profile__c>();
        list<Site_Profile__c> relatedSiteProfilesToUpdate = new list<Site_Profile__c>();
        map<Id, Contact> contactsToUpdate = new map<Id, Contact>();
        
        for (Site_Profile__c sp : newListSiteProfiles) {
            Contact c = mapContacts.get(sp.Contact__c);
            Site_Profile__c oldSP;
            if (oldMapSiteProfiles != null) oldSP = oldMapSiteProfiles.get(sp.Id);
            
            //verify the username matches the Contact's Email Address
            if ((oldSP == null && sp.Username__c != c.Email) ||
                (oldSP != null && oldSP.Username__c != sp.Username__c) && sp.Username__c != c.Email) {
                sp.addError('Username must match the Contact Email address.');
            }
            
            //scenarios that will trigger the SiteProfile to sync with the contact:
            //1. Bypass domain validation flag is set from True to False
            //2. Status is changed from Hard Bounce to In Progress
            //3. Type = Advisory.com and Status id changed
            if ((oldSP == null && sp.Bypass_Domain_Validation__c == true) 
                || (oldSP != null 
                    && (oldSP.Bypass_Domain_Validation__c != sp.Bypass_Domain_Validation__c
                        || oldSP.Status__c == SiteProfileTriggerHelper.SITE_PROFILE_STATUS_HARD_BOUNCE && sp.Status__c == SiteProfileTriggerHelper.SITE_PROFILE_STATUS_IN_PROGRESS)
                   )
                || (oldSP != null && sp.Type__c == SiteUserHelper.SITE_ADVISORY && oldSP.Status__c != sp.Status__c)
               )
            {
                sProfilesNeedSync.add(sp);
            }
        }
        system.debug('@@sProfilesNeedSync:' + sProfilesNeedSync);
        
        if (sProfilesNeedSync.size() > 0) {
            
            for (Site_Profile__c sp : sProfilesNeedSync) {
                
                Site_Profile__c oldSP;
                if (oldMapSiteProfiles != null) oldSP = oldMapSiteProfiles.get(sp.Id);
                
                //get the related contact and set the verification status
                Contact c = mapContacts.get(sp.Contact__c);
                
                //make the contact's bypass flag = true if the site profile's flag is set to true
                //check to see if the Site Profile Username is different than the Contact Email
                if (sp.Username__c != c.Email
                   || sp.Bypass_Domain_Validation__c != c.Bypass_Domain_Validation__c
                   || (oldSP != null && oldSP.Status__c != sp.Status__c)) 
                {
                    c.Bypass_Domain_Validation__c = sp.Bypass_Domain_Validation__c;
                    c.Advisory_com_User_Status__c = sp.Status__c;
                    contactsToUpdate.put(c.Id, c);
                }
                
                string errMsg;
                
                //update any related site profiles that also need their username or bypass flag updated
                if (c.Site_Profiles__r != null) {
                    for (Site_Profile__c rsp : c.Site_Profiles__r) {
                        if (rsp.Username__c != sp.Username__c || rsp.Bypass_Domain_Validation__c != sp.Bypass_Domain_Validation__c) {
                            
                            if(rsp.Username__c != sp.Username__c) {
                                //update username & set verification status
                                rsp.Username__c = sp.Username__c;
                                rsp = SiteUserHelper.setVerificationStatus(c, rsp);
                            }
                            
                            if(rsp.Bypass_Domain_Validation__c != sp.Bypass_Domain_Validation__c) 
                                rsp.Bypass_Domain_Validation__c = sp.Bypass_Domain_Validation__c;
                            
                            
                            
                            relatedSiteProfilesToUpdate.add(rsp);
                        }
                    }
                }
                
                //if the username or status changes from hard bounce to in progress, set verification status and send reset pw email.
                if (oldSP != null 
                    && (oldSP.Username__c != sp.Username__c
                        || (oldSP.Status__c == SiteProfileTriggerHelper.SITE_PROFILE_STATUS_HARD_BOUNCE && sp.Status__c == SiteProfileTriggerHelper.SITE_PROFILE_STATUS_IN_PROGRESS)
                       )
                   )
                {
                    //set verification status
                    sp = SiteUserHelper.setVerificationStatus(c, sp);
                    string notificationType = NOTIFICATION_TYPE_EMAIL_CHANGE;
                    
                    //if the status was updated but the username was not, send the password reset email
                    if(oldSP.Status__c == SiteProfileTriggerHelper.SITE_PROFILE_STATUS_HARD_BOUNCE && sp.Status__c == SiteProfileTriggerHelper.SITE_PROFILE_STATUS_IN_PROGRESS
                        && oldSP.Username__c == sp.Username__c) 
                    {
                        notificationType = NOTIFICATION_TYPE_PASSWORD_RESET;
                    }
                    
                    //send password reset email to the site profile(s) affected by the trigger
                    sendVerificationEmail(sProfilesNeedSync, notificationType, false);
                    
                    //send pw reset email to the other site profiles related to the contact
                    sendVerificationEmail(relatedSiteProfilesToUpdate, notificationType, false);
                }
            }
            
            
            //update the related site profiles that also need their username(s) updated
            if (relatedSiteProfilesToUpdate.size() > 0) {
                util.BypassAllTriggers = true;
                update relatedSiteProfilesToUpdate;
                util.BypassAllTriggers = false;
            }
            
            if (contactsToUpdate.size() > 0 && !SiteUserHelper.IsTriggerContact) {
                util.BypassAllTriggers = true;
                update contactsToUpdate.values();
                util.BypassAllTriggers = false;
            }
        }
    }
    
    //Modified By - Abhinav Sharma - 11/27/2015 - CR-20151118-9393 - Updated contact query to include additional fields
    //Modified By - Ajit Surana - 02/05/2015 - CR-20141016-7784 - Updated Contact query
    /**
     * @description:    validate that the email contains a valid domain unless bypass domain validation is checked.
     *
     *
     **/
    public static void validateEligibleDomain(list<Site_Profile__c> newListSiteProfiles, map<Id, Site_Profile__c> oldMapSiteProfiles) {
        //set of all site profile ids that have a new email
        list<Site_Profile__c> sProfilesNeedValidated = new list<Site_Profile__c>();
        set<id> siteProfileIdSet = new set<Id>();
        
        for (Site_Profile__c sp : newListSiteProfiles) {
            Site_Profile__c oldSP;
            if (oldMapSiteProfiles != null) oldSP = oldMapSiteProfiles.get(sp.Id);
            
            siteProfileIdSet.add(sp.Id);
            
            //scenarios that will trigger the site profile to be validated:
            //1. Username has changed
            //2. Bypass domain validation flag is changed
            //3. Status is changed from Hard Bounce to In Progress
            //4. User resets password
            if ((oldSP == null && sp.Bypass_Domain_Validation__c == true) 
                || (oldSP != null 
                    && (oldSP.Username__c != sp.Username__c
                        || (oldSP.Bypass_Domain_Validation__c != sp.Bypass_Domain_Validation__c)
                        || (oldSP.Status__c == SiteProfileTriggerHelper.SITE_PROFILE_STATUS_HARD_BOUNCE && sp.Status__c == SiteProfileTriggerHelper.SITE_PROFILE_STATUS_IN_PROGRESS)
                        || (oldSP.Send_Password_Notification__c == null && sp.Send_Password_Notification__c != null))
                   )
               )
            {
                sProfilesNeedValidated.add(sp);
            }
        }
        system.debug('@@sProfilesNeedValidated:' + sProfilesNeedValidated);
        
        //set of contact ids
        set<Id> contactIds = new set<Id>();
        if (sProfilesNeedValidated.size() > 0) {
            //get accounts with eligible domains
            set<Id> accountIds = new set<Id>();
            
            for (Site_Profile__c sp : sProfilesNeedValidated) {
                contactIds.add(sp.Contact__c);
                if (sp.r_Institution__c != null) accountIds.add(sp.r_Institution__c);
            }
            
            //Modified By - Ajit Surana - 04-29-2015 - CR-20150415-8874 - Added Account.Strategic_Account_Segment__c to the query
            //get contacts and set verification status
            map<Id, Contact> mapContacts = new map<Id, Contact>([SELECT Id, Email, Contact_Status__c, AccountId, Account.Name, Account.Organization_Id__c, Site_User__c, 
                                                                 Account.Status__c, Account.RecordType.Name, Account.Account_Formal_Name__c, Account.Advisory_com_Primary_AM__c, 
                                                                 Account.Advisory_com_Primary_AM_Email__c, Account.Advisory_com_Primary_AM_Phone__c, EAB_Department__c, EAB_Role__c, Account.RI_TD_Renewal_CV__c,
                                                                 Account.EAB_com_Organization_Status__c, Bypass_Domain_Validation__c, Account.Advisory_com_Organization_Status__c, Account.Strategic_Account_Segment__c,
                                                                 Account.Provider_Type__c, Account.Bed_Size__c, Account.RM_RI__c, Account.Principal__c,
                                                                 (SELECT Id, Name, Username__c, Status__c, Bypass_Domain_Validation__c, Last_Access__c, Verify_Date__c, 
                                                                  Organization_Status__c, Verify__c, Password__c, Type__c, User_Id__c 
                                                                  FROM Site_Profiles__r WHERE Id NOT IN :siteProfileIdSet) 
                                                                 FROM Contact WHERE Id IN :contactIds]);
            
            for (Contact c : mapContacts.values()) accountIds.add(c.AccountId);
            map<Id, Account> accountMap = getAccountsWithEligibleDomains(accountIds);
            
            for (Site_Profile__c sp : sProfilesNeedValidated) {
                
                Site_Profile__c oldSP;
                if (oldMapSiteProfiles != null) oldSP = oldMapSiteProfiles.get(sp.Id);
                
                //get the related contact and set the verification status
                Contact c = mapContacts.get(sp.Contact__c);
                
                //vh 6/23/16: set the account based on the contact, unless the SP (royall) institution lookup is populated
                Account acct = accountMap.get(c.AccountId);
                if (sp.r_Institution__c != null) acct = accountMap.get(sp.r_Institution__c);
                
                string errMsg;
                
                //update any related site profiles that also need their username updated
                if (c.Site_Profiles__r != null) {
                    for (Site_Profile__c rsp : c.Site_Profiles__r) {
                        if (rsp.Username__c != sp.Username__c) {
                            rsp.Username__c = sp.Username__c;
                            rsp.Bypass_Domain_Validation__c = sp.Bypass_Domain_Validation__c;
                            
                            //get the site user so we can validate the domain
                            SiteUser relatedSiteUser = SiteUserHelper.getSiteUser(c, rsp);
                            
                            if (!SiteUserHelper.hasEligibleDomain(acct, relatedSiteUser)) {
                                errMsg = 'Domain is not eligible for Site Profile <a href="/' + rsp.Id + '">' + rsp.Name + '</a>';
                            }
                        }
                    }
                }
                
                //get the site user so we can validate the domain
                SiteUser sUser = SiteUserHelper.getSiteUser(c, sp);
                if (!SiteUserHelper.hasEligibleDomain(acct, sUser))
                    errMsg = ERROR_INVALID_DOMAIN;
                
                //if there was an error, add it to the record and return immediately
                if (errMsg != null) {
                    sp.addError(errMsg, false);
                    return;
                }
            }
        }
        
        //null the contact map so it will pull a fresh list of contacts during the next trigger run (used for unit tests)
        mapSPContacts = null;
    }
    
    /**
     * @description:    
     **/
    public static void updateSiteProfileCount(list<Site_Profile__c> newListSiteProfiles, map<Id, Site_Profile__c> oldMapSiteProfiles) {
        //set of contact ids
        set<Id> contactIds = new set<Id>();
        list<Contact> contactsToUpdate = new list<Contact>();
        
        //figure out which list of site profiles we should use for counting site profiles on contact
        list<Site_Profile__c> siteProfiles = newListSiteProfiles;
        if (trigger.isDelete) siteProfiles = oldMapSiteProfiles.values();
        
        for (Site_Profile__c sp : siteProfiles) contactIds.add(sp.Contact__c);
        
        //get all site profiles by contact
        contactsToUpdate = [SELECT Id, (SELECT Id, Type__c, Contact__c FROM Site_Profiles__r) FROM Contact WHERE Id IN :contactIds];
        
        for (Contact c : contactsToUpdate)  {
            //reset counts to zero
            integer count_Advisory = 0;
            integer count_EAB = 0;
            
            for(Site_Profile__c sp : c.Site_Profiles__r) {
                if (sp.Type__c == SiteUserHelper.SITE_ADVISORY) count_Advisory++;
                else if (sp.Type__c == SiteUserHelper.SITE_EAB) count_EAB++;
            }
            
            if (count_Advisory > 0) c.Advisory_com_Site_Profile_Count__c = count_Advisory;
            else c.Advisory_com_Site_Profile_Count__c = null;
            
            if (count_EAB > 0) c.EAB_com_Site_Profile_Count__c = count_EAB;
            else c.EAB_com_Site_Profile_Count__c = null;
            
        }
        
        if (contactsToUpdate.size() > 0 && !SiteUserHelper.IsTriggerContact) {
            util.BypassAllTriggers = true;
            update contactsToUpdate;
            util.BypassAllTriggers = false;
        }
    }
}