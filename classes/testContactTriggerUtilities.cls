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
 **/
@isTest(seeAllData=false)
private class testContactTriggerUtilities {
/** 
 *  Description     :   Test class for ContactTriggerUtilities
 *
 *  Created By      :   
 *
 *  Created Date    :   
 *
 *  Revision Logs   :   V_1.0 - Created
 *                      V_1.1 - Modified - 12/11/2014 - By Bhavi Sharma
 *                      V_1.2 - Modified - 11/26/2015 - By Mahendra Swarnkar - CR-20150831-9207 - added a new test method "testvalidateContactFieldsForInvalidPhrase"
                        V_1.3 - Modified - 06/30/2016 - By Mahendra Swarnkar - CR-20160219-9621 - updated the "testvalidateContactFieldsForInvalidPhrase**" methods  
 *                              Modified - 07/22/2016 - By Abhinav Sharma - CR-20150202-8641 - A code refactor CR
 * 						V_1.4 - Modified - 11/07/2016 - By Colin McGloin - CR-20161103-10337 - Removed reference to "Delivery Chatter Plus - Restricted 15" profile and refined User Creation
 *
 *  Coverage        :   V_1.1 - ContactTriggerUtilities - 75%
 *                      V_1.2 - ContactTriggerUtilities - 95%
 *
 *
 **/
 
    //Modified By - Abhinav Sharma - CR-20150202-8641 - To refactor the existing code
    /** Description : Method to test out whether event title is populating as expected from associated contact record on insert. 
    **/
    static testmethod void testNewEventCreation() { 
        
        //Bypass Dupeblocker
        Util.IsTest(true);
        
        //Bypassing Triggers so then test data can be created easily
        Util.byPassAllTriggers = true;
        
        //Flag for triggers: this is just a test, don't do crazy things.
        Util.isTesting = true;
        
        //List of Account
        List<Account> accounts = new List<Account>();
        accounts.add(new Account(Name = 'TestAccounts1'));
        insert accounts;
        
        // create a contact with a title
        Contact con = TestUtilities.CreateNewContact(false);
        con.Title = 'Head Honcho';
        insert con;
        
        //Create team role
        List<Team_Role__c> teamRoles = new List<Team_Role__c>();
        
        //Add Team Role in list
        teamRoles.add(new Team_Role__c(Name = 'Test1',Active__c = true, Institution__c = true));
        insert teamRoles;
        
        //Record Types
        List<RecordType> recordTypes = [SELECT ID FROM RecordType WHERE sObjectType = 'Team_Membership__c' 
                                            AND IsActive = true 
                                            AND DeveloperName = 'Assigned'];
        System.assert(recordTypes != null);
        
        //Team Membership
        List<Team_Membership__c> teamMemberShips = new List<Team_Membership__c>();
           
        //Team Membership
        Team_Membership__c teamMembership3 = new Team_Membership__c(Name = 'TestTeamMember1', Staff_member__c = con.id,
                                                                    Employee__c = UserInfo.getUserId(), 
                                                                    Institution__c = accounts[0].Id, Role__c = teamRoles[0].Id, 
                                                                    Start_date__c = Date.today(), 
                                                                    End_date__c = Date.today().addDays(5),
                                                                    RecordTypeId = recordTypes[0].Id);
        
        //Insert teamMembership3
        teamMemberShips.add(teamMembership3);
        insert teamMemberShips;
        
        // create an event with this contact as the 'WhoId'
        Event newEvent = new Event();
        newEvent.StartDateTime = system.now();
        newEvent.EndDateTime = system.now();
        newEvent.Subject = 'Phone Appointment';
        newEvent.OwnerId = UserInfo.getUserId();
        newEvent.whoId = con.Id;
        newEvent.Event_Type__c = 'Phone Appointment';
        newEvent.Event_Purpose__c = 'Collection Call';
        
         //Start testing from here
        Test.startTest();
        
        //Enabling triggers
        Util.byPassAllTriggers = false;
        
        //Insert event under contact record
        insert newEvent;
        
        // get the newly updated Event
        Event evt = [SELECT Id, Title__c FROM Event WHERE Id = :newEvent.Id];
        
        //Asserting for the results
        // make sure that the new event contains Head Hancho in the 'Title' field
        system.assertEquals('Head Honcho', evt.Title__c);
        
        //Update contact
        con.FirstName = 'XYZ';
        update con;
        
        //Stop test here
        Test.stopTest();
    }
    
    //Modified By - Abhinav Sharma - CR-20150202-8641 - To refactor the existing code
    /** Description : Method to test out whether event title is updating as expected from associated contact record on contact record update. 
    **/
    static testmethod void testContactWithNewTitle() {
        
        //Bypass Dupeblocker
        Util.IsTest(true);
        
        //Bypassing Triggers so then test data can be created easily
        Util.byPassAllTriggers = true;
        
        //Flag for triggers: this is just a test, don't do crazy things.
        Util.isTesting = true; 
        
        // create a contact with a title
        Contact con = TestUtilities.CreateNewContact(false);
        insert con;
        
        // create an event with this contact as the 'WhoId'
        Event newEvent = new Event();
        newEvent.StartDateTime = system.now();
        newEvent.EndDateTime = system.now();
        newEvent.Subject = 'Phone Appointment';
        newEvent.OwnerId = UserInfo.getUserId();
        newEvent.whoId = con.Id;
        newEvent.Event_Type__c = 'Phone Appointment';
        newEvent.Event_Purpose__c = 'Collection Call';
        insert newEvent;
        
        // get the updated contact and update the title
        Contact updatedContact = [SELECT Name, Id, Title FROM Contact WHERE ID = :con.Id];
        updatedContact.Title = 'CIO';
        
         //Start testing from here
        Test.startTest();
        
        //Enabling triggers
        Util.byPassAllTriggers = false;
        
        //Update contact record
        update updatedContact;
        
        // get the newly updated Event
        Event evt = [SELECT Id, Title__c FROM Event WHERE Id = :newEvent.Id];
        
        //Asserting for the results
        // make sure that the new event contains CIO in the 'Title' field
        system.assertEquals('CIO', evt.Title__c);
    }
    
    //Modified By - Abhinav Sharma - CR-20150202-8641 - To refactor the existing code
    /** Description : Method to test out contact should never be created on an inactive institution. 
    **/
    static testmethod void insertContactWithInactiveInstitution() {
        
        //Bypass Dupeblocker
        Util.IsTest(true);
        
        //Bypassing Triggers so then test data can be created easily
        Util.byPassAllTriggers = true;
        
        //Flag for triggers: this is just a test, don't do crazy things.
        Util.isTesting = true;
        
        // create a new active and inactive institution
        Account acct_Active = TestUtilities.CreateNewAccount(false);
        acct_Active.RecordTypeId = Util.RecordTypeId('Account', 'US Provider - System');
        acct_Active.Status__c = Constants.ACTIVE;
        Account acct_Inactive = TestUtilities.CreateNewAccount(false);
        acct_Inactive.RecordTypeId = Util.RecordTypeId('Account', 'US Provider - System');
        acct_Inactive.Status__c = 'Inactive - Closed';
        list<Account> accts = new list<Account> { acct_Active, acct_Inactive };
        insert accts;
        
        // create a contact that will try to be added to the inactive institution first
        Contact con = TestUtilities.CreateNewContact(acct_Inactive, false);
        
        // flag to determine if the contact errored successfully
        boolean hasError = false;
        
         //Start testing from here
        Test.startTest();
        
        //Enabling triggers
        Util.byPassAllTriggers = false;
        
        //Insert contact
        try {
            insert con;
        } catch(DMLException ex) {
            hasError = true;
            system.assertEquals(Constants.ERROR_CANNOT_ADD_CONTACT_TO_INACTIVE_INSTITUTION, ex.getDMLMessage(0));
        }
        
        //Asserting for the results
        // make sure the error was thrown
        system.assertEquals(true, hasError, 'Error was not thrown when inserting a contact on an inactive institution.');
        
        // now insert the contact on an active institution
        con.AccountId = acct_Active.Id;
        insert con;
        
        //Asserting for the results
        system.assertNotEquals(con.Id, null, 'The contact id is null even though it should have been inserted successfully.');
        
        //Stop Testing here
        Test.stopTest();
        
    }
    
    //Modified By - Abhinav Sharma - CR-20150202-8641 - To refactor the existing code
    /** Description : Method to test out if two duplicate SIAM field exists then errors should have been thrown.
    **/
    static testmethod void testSIAMEmailDupe() {
        
        //Bypass Dupeblocker
        Util.IsTest(true);
        
        //Bypassing Triggers so then test data can be created easily
        Util.byPassAllTriggers = true;
        
        //Flag for triggers: this is just a test, don't do crazy things.
        Util.isTesting = true;
        
        //Account
        Account acct_Active = TestUtilities.CreateNewAccount(false);
        acct_Active.RecordTypeId = Util.RecordTypeId('Account', 'US Provider - System');
        acct_Active.Status__c = Constants.ACTIVE;
        
        //create 2 contacts
        Contact contact_SIAMEmail = TestUtilities.CreateNewContact(acct_Active, false);
        Contact contact_SIAMGUID = TestUtilities.CreateNewContact(acct_Active, false);
        contact_SIAMEmail.SIAM_Email__c = 'abc123@noreply.com';
        contact_SIAMGUID.SIAM_GUID__c = '12345';
        list<Contact> contacts = new list<Contact> { contact_SIAMEmail, contact_SIAMGUID };
        insert contacts;
        
        list<Id> fixedSearchResults = new list<Id>();
        for(Contact c : contacts){
            fixedSearchResults.add(c.Id);
        }
        
        //now, try to insert a duplicate of each email / GUID
        Contact contact_dupeSIAMEmail = TestUtilities.CreateNewContact(acct_Active, false);
        Contact contact_dupeSIAMGUID = TestUtilities.CreateNewContact(acct_Active, false);
        contact_dupeSIAMEmail.SIAM_Email__c = 'abc123@noreply.com';
        contact_dupeSIAMGUID.SIAM_GUID__c = '12345';
        list<Contact> dupeContacts = new list<Contact> { contact_dupeSIAMEmail, contact_dupeSIAMGUID };
        
        integer numDMLErrors = 0;
        
        //Start testing from here
        Test.startTest();
        
        //Enabling triggers
        Util.byPassAllTriggers = false;
        
        //Settng search results
        test.setFixedSearchResults(fixedSearchResults);
        
        //Try to insert duplicate contacts
        try {
            insert dupeContacts;
        }
        catch(DMLException e) {
            numDMLErrors = e.getNumDml();
             
            numDMLErrors++;
        }
        
        //Asserting for the results
        system.assertEquals(2, numDMLErrors,
                            'Two duplicate SIAM field errors should have been thrown.');
        
    }
    
    //Modified By - Abhinav Sharma - CR-20150202-8641 - To refactor the existing code
    /** Description : Method to test out whether dups can be created in bulk or not. Ideally it should results as an error.
    **/
    static testmethod void testSIAMDupe_BatchInsert() {
        
        //Bypass Dupeblocker
        Util.IsTest(true);
        
        //Bypassing Triggers so then test data can be created easily
        Util.byPassAllTriggers = true;
        
        //Flag for triggers: this is just a test, don't do crazy things.
        Util.isTesting = true;
        
        //Account
        Account acct_Active = TestUtilities.CreateNewAccount(false);
        acct_Active.RecordTypeId = Util.RecordTypeId('Account', 'US Provider - System');
        acct_Active.Status__c = Constants.ACTIVE;
        
        //create 2 contacts
        Contact contact_SIAMEmail = TestUtilities.CreateNewContact(acct_Active, false);
        Contact contact_SIAMEmail_Dupe = TestUtilities.CreateNewContact(acct_Active, false);
        contact_SIAMEmail.SIAM_Email__c = 'abc123@noreply.com';
        contact_SIAMEmail_Dupe.SIAM_Email__c = 'abc123@noreply.com';
        list<Contact> contacts = new list<Contact> { contact_SIAMEmail, contact_SIAMEmail_Dupe };
        integer numDMLErrors = 0;
        
        //Start testing from here
        Test.startTest();
        
        //Enabling triggers
        Util.byPassAllTriggers = false;
        
        try {
            insert contacts;
            
            numDMLErrors ++;
        }
        catch(DMLException e) {
            numDMLErrors = e.getNumDml();
            
        }
        
        //Asserting for the results
        system.assertEquals(1, numDMLErrors,
                            'one duplicate SIAM field error should have been thrown.');
        
        
        //Stop test here
        Test.stopTest();
    }
    
    //Modified By - Abhinav Sharma - CR-20150202-8641 - To refactor the existing code
    /**
     * @description:    1) setup 2 site profiles on different contacts.  Once site profile is active, the other is inactive.
     *                  2) Delete the contact with the inactive site profile - this should also delete the site profile and site user.
     *                  3) Delete the conact with the Active site profile - this should produce an error.
     **/
    static testmethod void validateContactBeforeDelete() {
        
        //Bypass Dupeblocker
        Util.IsTest(true);
        
        //Bypassing Triggers so then test data can be created easily
        Util.byPassAllTriggers = true;
        
        //Flag for triggers: this is just a test, don't do crazy things.
        Util.isTesting = true;
        
        //Site profiles
        Site_Profile__c sProfile_Inactive = Test_SiteUserHelper.createSiteProfile(SiteUserHelper.SITE_EAB, false);
        sProfile_Inactive.Status__c = SiteProfileTriggerHelper.SITE_PROFILE_STATUS_INACTIVE;
        Site_Profile__c sProfile_Active = Test_SiteUserHelper.createSiteProfile(SiteUserHelper.SITE_EAB, false);
        sProfile_Active.Status__c = SiteProfileTriggerHelper.SITE_PROFILE_STATUS_ACTIVE;
        list<Site_Profile__c> sProfiles = new list<Site_Profile__c> { sProfile_Active, sProfile_Inactive };
        insert sProfiles;
        
        //get the site profile details for both
        map<Id, Site_Profile__c> sProfileMap = new map<Id, Site_Profile__c>([SELECT Id, Contact__c, Status__c FROM Site_Profile__c WHERE Id IN :sProfiles]);
        
        //delete the contact associated with the inactive site profile
        Contact c_Inactive = new Contact(Id = sProfileMap.get(sProfile_Inactive.Id).Contact__c);
        string e;
        
        //Start testing from here
        Test.startTest();
        
        //Enabling triggers
        Util.byPassAllTriggers = false;
        
        try {
            delete c_Inactive;
        }
        catch(Exception ex) {
            e = ex.getMessage();
        }
        
        //Asserting for the results
        system.assertEquals(null, e,
                           'The deletion of this contact should have been successful because it is only associated with an inactive site profile.');
        
        //delete the contact associated with the inactive site profile
        Contact c_Active = new Contact(Id = sProfileMap.get(sProfile_Active.Id).Contact__c);
        
        //Enabling triggers
        Util.byPassAllTriggers = false;
        
        try {
            delete c_Active;
        }
        catch(DMLException ex) {
            e = ex.getDMLMessage(0);
        }
        catch(Exception ex) {
            e = ex.getMessage();
        }
        
        //Asserting for the results
        system.assertNotEquals(null, e,
                           'The deletion of this contact should have been thrown an error because it is associated with an active site profile.');
                           
        //Stop test here
        Test.stopTest();                   
    }
    
    //Modified By - Abhinav Sharma - CR-20150202-8641 - To refactor the existing code
    //Added By Ajit Surana - 02/12/2014 - CR-20130807-3381
    /** Description : Method to test out CR-20130807-3381 based functionality.
    **/
    static testmethod void testNewAdvUserContact_InstitutionChange() { 
        
       //Bypass Dupeblocker
        Util.IsTest(true);
        
        //Bypassing Triggers so then test data can be created easily
        Util.byPassAllTriggers = true;
        
        //Flag for triggers: this is just a test, don't do crazy things.
        Util.isTesting = true;
        
        //Insert Account
        Account acct1 = TestUtilities.CreateNewAccount(false);
        acct1.RecordTypeId = Util.RecordTypeId('Account', 'US Corporate');
        acct1.Status__c = Constants.ACTIVE;
        acct1.Name = 'Test Account 1';
        insert acct1;
        
        Account acct2 = TestUtilities.CreateNewAccount(false);
        acct2.RecordTypeId = Util.RecordTypeId('Account', 'US Corporate');
        acct2.Status__c = Constants.ACTIVE;
        acct2.Name = 'Test Account 2';
        insert acct2;
        
        //Insert Eligible Domain
        Eligible_Domain__c domain = new Eligible_Domain__c(Is_Included__c = true, Qualified_Domain__c = 'advisory2.com', Account__c = acct2.Id);
        
        //Insert Eligible Domain
        Eligible_Domain__c domain1 = new Eligible_Domain__c(Is_Included__c = true, Qualified_Domain__c = 'advisory1.com', Account__c = acct1.Id);
        
        //Inserting list of eligible domains      
        list<Eligible_Domain__c> eligibleDomains = new list<Eligible_Domain__c>{ domain, domain1 };
        insert eligibleDomains;
        
        //Updated by Colin McGloin - CR-10337
        //Query through  profile to get Id Of Profile
        Profile profile = [SELECT Id FROM Profile WHERE Name = :Label.DeliveryAppSubscriptionUser];
        
        //User Insert
        User testUser = TestUtilities.CreateNewUser(profile, True);
        
        //Site profile
        Site_Profile__c sProfile1 = Test_SiteUserHelper.createSiteProfile(acct1, SiteUserHelper.SITE_Advisory, false);
        sProfile1.Username__c = 'testUser1@advisory1.com';
        sProfile1.Status__c = 'Active';
        sProfile1.Password__c = 'test';
        sProfile1.Verify_Date__c = date.today();
        
        //Site profile
        Site_Profile__c sProfile2 = Test_SiteUserHelper.createSiteProfile(acct1, SiteUserHelper.SITE_EAB, false);
        sProfile2.Username__c = 'testUser2@advisory1.com';
        
        //Site profile
        Site_Profile__c sProfile3 = Test_SiteUserHelper.createSiteProfile(acct1, SiteUserHelper.SITE_EAB, false);
        sProfile3.Username__c = 'testUser3@advisory1.com';
        
        //List of site profiles
        list<Site_Profile__c> sProfiles = new list<Site_Profile__c> { sProfile1, sProfile2, sProfile3 };
        insert sProfiles;
        
        //Insert User
        System.runAs(new User(Id = UserInfo.getUserId())) {
            //Changing IsActive flag to false
            testUser.IsActive = false;
            update testUser;
        }
        
        //Contacts
        Contact con1 = [SELECT Id, AccountId, Email, Bypass_Domain_Validation__c FROM Contact WHERE Id = :sProfile1.Contact__c];
        Contact con2 = [SELECT Id, AccountId, Email, Bypass_Domain_Validation__c FROM Contact WHERE Id = :sProfile2.Contact__c];
        Contact con3 = [SELECT Id, AccountId, Email, Bypass_Domain_Validation__c FROM Contact WHERE Id = :sProfile3.Contact__c];
        
        //Contact1 - Changing Institution, Email and Create_Advisory_com_User_Account__c flag
        //This should not throw any exception and contact should be get updated successfully
        con1.AccountId = acct2.Id;
        con1.Email = 'testUser1@advisory2.com';
        con1.Bypass_Domain_Validation__c = true;
        
        //Test starts from here
        Test.startTest();
        
        //Enabling triggers
        Util.byPassAllTriggers = false;
        
        try {
            
            //Update contact record
            update con1;
            
        } catch(Exception e) {
            
            //Assert fails in case of exception
            System.assert(false, e.getMessage());
        }
        
        //Retrieving updated information for the database
        list<Contact> historicalContacts = [SELECT id, (SELECT Id, Status__c FROM Site_Profiles__r) FROM Contact WHERE AccountId = :acct1.Id];
        system.assertEquals(3, historicalContacts.size());
        
        //Contact2 - Changing Institution
        con2.AccountId = acct2.Id;
        con2.Bypass_Domain_Validation__c = false;
        con2.Email = 'testUser2-New@advisory2.com';
        
        //Execute trigger
        Util.BypassAllTriggers = false;
        
        //Setting properties and updating contacts
        SiteUserHelper.IsTriggerContact = false;
        ContactSiteHelper.hasCheckedInstitutionChange = false;
        update con2;
        
        //Querying for the updated values from the database
        historicalContacts = [SELECT id, (SELECT Id, Status__c FROM Site_Profiles__r) FROM Contact WHERE AccountId = :acct1.Id];
        
        //Asserting for the results
        system.assert(historicalContacts != null);
        system.assertEquals(3, historicalContacts.size());
        
        //Stop test here
        test.stopTest();
        
        //Contact3 - Changing Institution
        con3.AccountId = acct2.Id;
        con3.Bypass_Domain_Validation__c = false;
        
        //try saving the contact to the new institution where the email is not a valid domain
        string errMsg = '';
        
        try {
            
            //Execute trigger
            Util.BypassAllTriggers = false;
            SiteUserHelper.IsTriggerContact = false;
            ContactSiteHelper.hasCheckedInstitutionChange = false;
            update con3;
        
        } catch (DMLException ex) {
            errMsg = ex.getDMLMessage(0);
        } catch(Exception e) {
            errMsg = e.getMessage();
        }
        
        //Asserting for the results
        system.assertNotEquals(null, errMsg);
        system.assertEquals(SiteUserHelper.ERROR_INVALID_DOMAIN_USER_MESSAGE, errMsg);
        
        //try changing the email address and change the institution where the email is not a valid domain
        con3.Email = 'testUser3@BadDomain.com';
        con3.AccountId = acct2.Id;
        
        //Update contact record - note: the domain is not eligible, so an error should be thrown
        try {
            
            //Execute trigger
            Util.BypassAllTriggers = false;
            SiteUserHelper.IsTriggerContact = false;
            ContactSiteHelper.hasCheckedInstitutionChange = false;
            update con3;
        
        } catch (DMLException ex) {
            errMsg = ex.getDMLMessage(0);
        } catch(Exception e) {
            errMsg = e.getMessage();
        }
        
        //Asserting for the results
        system.assertNotEquals(null, errMsg);
        system.assertEquals(SiteUserHelper.ERROR_INVALID_DOMAIN_USER_MESSAGE, errMsg);
        
        //Query to retreive Contact record
        List<Contact> conList = [Select Id, OwnerId FROM Contact WHERE AccountId =: acct2.Id];
        
        //get updated contact with site profiles
        con2 = [SELECT Id, Email, 
                (SELECT Id, Username__c, Status__c FROM Site_Profiles__r)
                FROM Contact WHERE Id = :con2.Id];
                
        //Asserting for the results
        system.assertEquals(1, con2.Site_Profiles__r.size());
        system.assertEquals(SiteProfileTriggerHelper.SITE_PROFILE_STATUS_IN_PROGRESS, con2.Site_Profiles__r[0].Status__c);
        system.assertEquals(con2.Email, con2.Site_Profiles__r[0].Username__c);
        
        //Assert for results
        system.assert(conList != null);
        system.assertEquals(2, conList.size());
        System.assertEquals(conList[0].OwnerId, UserInfo.getUserId());
        System.assertEquals(conList[1].OwnerId, UserInfo.getUserId());
        
        //Querying for retrieving updated information from the database
        historicalContacts = [SELECT id, (SELECT Id, Status__c FROM Site_Profiles__r) FROM Contact WHERE AccountId = :acct1.Id AND Id != :con3.Id];
        
        //Assert for results
        system.assert(historicalContacts != null);
        system.assertEquals(2, historicalContacts.size());
        system.assertEquals(1, historicalContacts[0].Site_Profiles__r.size());
        system.assertEquals(1, historicalContacts[1].Site_Profiles__r.size());
        system.assertEquals(SiteProfileTriggerHelper.SITE_PROFILE_STATUS_INACTIVE, historicalContacts[0].Site_Profiles__r[0].Status__c);
        system.assertEquals(SiteProfileTriggerHelper.SITE_PROFILE_STATUS_INACTIVE, historicalContacts[1].Site_Profiles__r[0].Status__c);
    }
    
    //Modified By - Abhinav Sharma - CR-20150202-8641 - To refactor the existing code
    /**
     * @description:    Step 1: Create an Contact, Site User, and Site Profile with eligible domain for Advisory.com & EAB.com.
     *                  Step 2: Update the Eloqua Hard Bounce Email = Contact.Email
     *                  Step 3: Verify the Contact and related Site Profiles are updated with the Status = Hard Bounce
     **/
    private static testMethod void testContactUpdate_HardBounceEmail() {
        
        //Bypass Dupeblocker
        Util.IsTest(true);
        
        //Bypassing Triggers so then test data can be created easily
        Util.byPassAllTriggers = true;
        
        //Flag for triggers: this is just a test, don't do crazy things.
        Util.isTesting = true;
        
        // create account and eligible domain
        Account acct = Test_SiteUserHelper.CreateNewAccount(true);
        Eligible_Domain__c domain = new Eligible_Domain__c(Is_Included__c = true, Qualified_Domain__c = 'advisory.com', Account__c = acct.Id);
        insert domain;
        
        //create contact
        Contact c = TestUtilities.CreateNewContact(acct, false);
        c.Email = 'mike@advisory.com';
        insert c;
        
        //create Advisory.com site profile
        Site_Profile__c siteProfile_Advisory = new Site_Profile__c(Status__c = 'Active',
                                                                   Username__c = c.Email,
                                                                   Password__c = 'test',
                                                                   Site_User__c = null,
                                                                   Verify__c = '2',
                                                                   Contact__c = c.Id,
                                                                   Type__c = SiteUserHelper.SITE_ADVISORY);
        
        //create EAB.com site profile
        Site_Profile__c siteProfile_EAB_DUPLICATE = new Site_Profile__c(Status__c = 'Active',
                                                                        Username__c = c.Email,
                                                                        Password__c = 'test',
                                                                        Site_User__c = null,
                                                                        Verify__c = '2',
                                                                        Contact__c = c.Id,
                                                                        Type__c = SiteUserHelper.SITE_EAB);
        
        list<Site_Profile__c> siteProfiles = new list<Site_Profile__c> { siteProfile_Advisory, siteProfile_EAB_DUPLICATE };
        insert siteProfiles;
        
        //update the Contact's Email address
        c.Eloqua_Hard_Bounce_Email__c = c.Email;
        
        //Start testing from here
        Test.startTest();
        
        //flip these back to false so the trigger_Contact fires
        Util.BypassAllTriggers = false;
        SiteUserHelper.IsTriggerContact = false;
        
        //Update contact
        update c;
        
        //get the contact, site user, and site profile
        c = [SELECT Id, Site_User__c, Email, Eloqua_Status__c, 
                (SELECT Id, Type__c, Username__c, Status__c, Site_User__c FROM Site_Profiles__r) 
                FROM Contact 
                WHERE Id = :c.Id];
        
        //Asserting for the results
        //verify that all site profiles have the Status = Hard Bounce
        for (Site_Profile__c sp : c.Site_Profiles__r) {
            system.assertEquals(SiteProfileTriggerHelper.SITE_PROFILE_STATUS_HARD_BOUNCE, sp.Status__c);
        }
        
        //Stop Test here
        Test.stopTest();
    }
    
    //Modified By - Abhinav Sharma - CR-20150202-8641 - To refactor the existing code
    /**
    * @description:     Step 1: Create an Contact, Site User, and Site Profile with eligible domain for Advisory.com & EAB.com.
    *                   Step 2: Update the Eloqua Hard Bounce Email = Contact.Email
    *                   Step 3: Verify the Contact and related Site Profiles are updated with the Status = Hard Bounce
    *                   Step 4: Remove the eloqua hard bounce email
    *                   Step 5: Verify the related Site Profiles are updated with Status = In Progress and PW Reset is sent
    **/
    private static testMethod void testContactUpdate_HardBounce_To_Active() {
        
        //Bypass Dupeblocker
        Util.IsTest(true);
        
        //Bypassing Triggers so then test data can be created easily
        Util.byPassAllTriggers = true;
        
        //Flag for triggers: this is just a test, don't do crazy things.
        Util.isTesting = true;
        
        // create account and eligible domain
        Account acct = Test_SiteUserHelper.CreateNewAccount(true);
        Eligible_Domain__c domain = new Eligible_Domain__c(Is_Included__c = true, Qualified_Domain__c = 'advisory.com', Account__c = acct.Id);
        insert domain;
        
        //create contact
        Contact c = TestUtilities.CreateNewContact(acct, false);
        c.Email = 'mike@advisory.com';
        insert c;
        
        //create Advisory.com site profile
        Site_Profile__c siteProfile_Advisory = new Site_Profile__c(Status__c = SiteProfileTriggerHelper.SITE_PROFILE_STATUS_ACTIVE,
                                                                   Username__c = c.Email,
                                                                   Password__c = 'test',
                                                                   Site_User__c = null,
                                                                   Verify__c = '2',
                                                                   Contact__c = c.Id,
                                                                   Type__c = SiteUserHelper.SITE_ADVISORY);
        
        //create EAB.com site profile
        Site_Profile__c siteProfile_EAB = new Site_Profile__c(Status__c = SiteProfileTriggerHelper.SITE_PROFILE_STATUS_INACTIVE,
                                                              Username__c = c.Email,
                                                              Password__c = 'test',
                                                              Site_User__c = null,
                                                              Verify__c = '1',
                                                              Contact__c = c.Id,
                                                              Type__c = SiteUserHelper.SITE_EAB);
        
        //Insert site profiles
        list<Site_Profile__c> siteProfiles = new list<Site_Profile__c> { siteProfile_Advisory, siteProfile_EAB };
        insert siteProfiles;
        
        //update the Contact's Email address
        c.Eloqua_Hard_Bounce_Email__c = c.Email;
        
        //flip these back to false so the trigger_Contact fires
        Util.BypassAllTriggers = false;
        SiteUserHelper.IsTriggerContact = false;
        
        //Update contact
        update c;
        
        //get the contact, site user, and site profile
        c = [SELECT Id, Site_User__c, Email, Eloqua_Status__c, Eloqua_Hard_Bounce_Email__c, 
                    (SELECT Id, Type__c, Username__c, Status__c, Site_User__c FROM Site_Profiles__r) 
                    FROM Contact 
                    WHERE Id = :c.Id];
        
        //Asserting for the results
        system.assertEquals(ContactSiteHelper.ELOQUA_STATUS_PRIMARY, c.Eloqua_Status__c);
        
        //verify that all site profiles have the Status = Hard Bounce
        for (Site_Profile__c sp : c.Site_Profiles__r) {
            if (sp.Id == siteProfile_Advisory.Id)
                system.assertEquals(SiteProfileTriggerHelper.SITE_PROFILE_STATUS_HARD_BOUNCE, sp.Status__c);
            else if (sp.Id == siteProfile_EAB.Id)
                system.assertEquals(SiteProfileTriggerHelper.SITE_PROFILE_STATUS_INACTIVE, sp.Status__c,
                                    'Site Profile status should remain Inactive because we should never auto-update an inactive Site Profile\'s status.');
        }
        
        //Start test from here
        Test.startTest();
       
        //reset trigger variables
        SiteProfileTriggerHelper.hasSynchronizedSiteProfile = false;
        
        //remove the email from the contact's eloqua hard bounce email field
        c.Eloqua_Hard_Bounce_Email__c = null;
        
        //Enabling triggers
        Util.BypassAllTriggers = false;
        
        //Update contact
        update c;
        
        //get the contact and related site profiles
        c = [SELECT Id, Site_User__c, Email, Eloqua_Status__c, Eloqua_Hard_Bounce_Email__c, 
             (SELECT Id, Type__c, Username__c, Status__c, Site_User__c, Password_Reset_Token__c FROM Site_Profiles__r) 
             FROM Contact WHERE Id = :c.Id];
        
        //Asserting for the results
        system.assertEquals(null, c.Eloqua_Status__c);
        
        //verify that all site profiles have the Status = Hard Bounce
        for (Site_Profile__c sp : c.Site_Profiles__r) {
            if (sp.Id == siteProfile_Advisory.Id) {
                system.assertEquals(SiteProfileTriggerHelper.SITE_PROFILE_STATUS_IN_PROGRESS, sp.Status__c);
                system.assertNotEquals(null, sp.Password_Reset_Token__c,
                                       'When a Site Profile goes from Hard Bounce to In Progress, this should trigger a password reset token and email to the user.');
            }
            else if (sp.Id == siteProfile_EAB.Id)
                system.assertEquals(SiteProfileTriggerHelper.SITE_PROFILE_STATUS_INACTIVE, sp.Status__c,
                                    'Site Profile status should remain Inactive because we should never auto-update an inactive Site Profile\'s status.');
        }
        
        //Stop Test here
        Test.stopTest();
        
    }

    //Modified By - Abhinav Sharma - CR-20150202-8641 - To refactor the existing code
    //Added By VH - 02/25/2014 - CR-3003
    /**
    * @description : Method to test out CR-3003 based functionality.
    **/
    static testmethod void testNewAdvUserContact_InstitutionChange_TopParent() { 
        
        //Bypass Dupeblocker
        Util.IsTest(true);
        
        //Bypassing Triggers so then test data can be created easily
        Util.byPassAllTriggers = true;
        
        //Flag for triggers: this is just a test, don't do crazy things.
        Util.isTesting = true;
        
        //Insert Account
        Account acct_TopParent = TestUtilities.CreateNewAccount(false);
        acct_TopParent.RecordTypeId = Util.RecordTypeId('Account', 'US Corporate');
        acct_TopParent.Status__c = Constants.ACTIVE;
        acct_TopParent.Name = 'Test Account 1';
        insert acct_TopParent;
        
        //Enabling triggers
        Util.bypassAllTriggers = false;
        
        Account acct_Child = TestUtilities.CreateNewAccount(false);
        acct_child.ParentId = acct_topParent.Id;
        acct_Child.RecordTypeId = Util.RecordTypeId('Account', 'US Corporate');
        acct_Child.Status__c = Constants.ACTIVE;
        acct_Child.Name = 'Test Account 2';
        insert acct_Child;
        
        // get the child acct and make sure the top parent field is populated correctly
        acct_Child = [SELECT Id, ParentId, Top_Parent_Institution__c FROM Account WHERE Id = :acct_Child.Id];
        system.assertEquals(acct_TopParent.Id, acct_Child.Top_Parent_Institution__c);
        
        //Diabling triggers
        Util.bypassAllTriggers = true;
        
        //Insert Eligible Domain
        Eligible_Domain__c domain_TopParent = new Eligible_Domain__c(Is_Included__c = true, Qualified_Domain__c = 'testDomain.com', Account__c = acct_TopParent.Id);
        Eligible_Domain__c domain_Child = new Eligible_Domain__c(Is_Included__c = true, Qualified_Domain__c = 'testDomain.com', Account__c = acct_Child.Id);
        list<Eligible_Domain__c> eligibleDomains = new list<Eligible_Domain__c> { domain_Child, domain_TopParent };
        insert eligibleDomains;
        
        //Insert contact1 and associate it with the child acct
        Contact con1 = TestUtilities.CreateAdvUserContact(acct_Child, false);
        con1.Email = 'con1Test@testDomain.com';
        Util.bypassAllTriggers = true;
        insert con1;
        
        //Insert contact2 and associate it with the topParent acct
        Contact con2 = TestUtilities.CreateAdvUserContact(acct_TopParent, false);
        con2.Email = 'con2Test@testDomain.com';
        Util.bypassAllTriggers = true;
        insert con2;
        
        //Test starts from here
        Test.startTest();
        
        //Changing Institution from acct_Child to acct_TopParent
        //This should not throw any exception and contact should be get updated successfully
        con1.AccountId = acct_TopParent.Id;
        
        //Enabling triggers
        Util.bypassAllTriggers = false;
        
        try {
            
            //Update contact record
            update con1;
        
        } catch(Exception e) {
            
            //Assert failed in case of exception
            system.assert(false, e.getMessage());
        }
        
        //Changing Institution from topParent to the Child acct
        con2.AccountId = acct_Child.Id;
        
        //Execute trigger
        Util.BypassAllTriggers = false;
        SiteUserHelper.IsTriggerContact = false;
        
        //Update contact record
        update con2;
        
        //Query to retreive Contact record
        List<Contact> contacts_at_child_acct = [Select Id, OwnerId FROM Contact WHERE AccountId =: acct_Child.Id];
        List<Contact> contacts_at_top_parent_acct = [Select Id, OwnerId FROM Contact WHERE AccountId =: acct_TopParent.Id];
        
        //Assert for results
        system.assert(contacts_at_child_acct != null);
        system.assert(contacts_at_top_parent_acct != null);
        system.assertEquals(1, contacts_at_child_acct.size());
        system.assertEquals(con2.Id, contacts_at_child_acct[0].Id);
        system.assertEquals(1, contacts_at_top_parent_acct.size());
        system.assertEquals(con1.Id, contacts_at_top_parent_acct[0].Id);
        
        //Stop Test here
        Test.stopTest();
    }
    
    //Modified By - Abhinav Sharma - CR-20150202-8641 - To refactor the existing code
     /**
    * @description : Test Method to test if on deletion of Account all associated children Restriction MtM records will be deleted or not.
    **/
    static testmethod void testDeleteAllRestrcitionMtmFuntionality() {
        
        //Bypass Dupeblocker
        Util.IsTest(true);
        
        //Bypassing Triggers so then test data can be created easily
        Util.byPassAllTriggers = true;
        
        //Flag for triggers: this is just a test, don't do crazy things.
        Util.isTesting = true;
        
        //List to hold the contact records
        List<Contact> contacts = new List<Contact>();
        
        // create a contact that will try to be added to the inactive institution first
        Contact con_1 = TestUtilities.CreateNewContact(false);
        con_1.Title = 'Head Honcho';
        Contact con_2 = TestUtilities.CreateNewContact(false);
        con_2.Title = 'Head Honcho 1';
        
        //Adding records into the list
        contacts.add(con_1);
        contacts.add(con_2);
        
        //Bypassing all the triggers
        Util.BypassAllTriggers = true;
        
        //Insert contacts
        insert contacts;
        
        //Assert for results
        System.assert(contacts != null);
        System.assertEquals(2, contacts.size());
        
        //Restriction
        Restrictions__c restrict = new Restrictions__c();
        restrict.Category__c = 'Critical Background Information';
        restrict.Expiration_Date__c = system.today().addDays(10);
        
        //Bypassing all the triggers
        Util.BypassAllTriggers = true;
        
        //Insert restrictions
        insert restrict;
        
        //List Restriction Mtms
        List<Restricted_MtM__c> restrictionMtMs = new List<Restricted_MtM__c>();
        
        //Restriction MtMs
        Restricted_MtM__c rest_1 = new Restricted_MtM__c(Contact__c = contacts[0].Id, Restriction__c = restrict.Id);
        Restricted_MtM__c rest_2 = new Restricted_MtM__c(Contact__c = contacts[0].Id, Restriction__c = restrict.Id);
        Restricted_MtM__c rest_3 = new Restricted_MtM__c(Contact__c = contacts[1].Id, Restriction__c = restrict.Id);
        Restricted_MtM__c rest_4 = new Restricted_MtM__c(Contact__c = contacts[1].Id, Restriction__c = restrict.Id);
        
        //Populating list with the records
        restrictionMtMs.add(rest_1);
        restrictionMtMs.add(rest_2);
        restrictionMtMs.add(rest_3);
        restrictionMtMs.add(rest_4);
        
        //Bypassing all the triggers
        Util.BypassAllTriggers = true;
        
        //Insert restriction
        insert restrictionMtMs;
        
        //Assert for the results
        System.assertEquals(4, restrictionMtMs.size());
        restrictionMtMs = [SELECT ID FROM Restricted_MtM__c WHERE Contact__c =: contacts[0].Id];
        System.assert(restrictionMtMs != null);
        System.assertEquals(2, restrictionMtMs.size());
        restrictionMtMs = [SELECT ID FROM Restricted_MtM__c WHERE Contact__c =: contacts[1].Id];
        System.assert(restrictionMtMs != null);
        System.assertEquals(2, restrictionMtMs.size());
        
        //Test start From here
        Test.startTest();
        
        //Setting flag value
        Util.BypassAllTriggers = false;
        SiteUserHelper.IsTriggerContact = false;
        
        //Delete Accounts
        delete contacts;
        
        //Assert for results
        restrictionMtMs = [Select ID FROM Restricted_MtM__c];
        contacts = [Select ID FROM Contact];
        System.assert(restrictionMtMs != null);
        System.assert(contacts != null);
        System.assertEquals(0, restrictionMtMs.size());
        System.assertEquals(0, contacts.size());
        
        //Stop Test Here
        Test.stopTest();
    }
    
    //Modified By - Abhinav Sharma - CR-20150202-8641 - To refactor the existing code
     /**
    * @description : This method is to check if updating the contact address will update the Portfolio address
    **/
    static testMethod void testUpdatePersonalAddressInUS() {
        
        //Bypass Dupeblocker
        Util.IsTest(true);
        
        //Bypassing Triggers so then test data can be created easily
        Util.byPassAllTriggers = true;
        
        //Flag for triggers: this is just a test, don't do crazy things.
        Util.isTesting = true;
        
        //insert Credit Card Settings record
        Credit_Card_Settings__c configCCDefaultSetting = TestUtilities.CreateCreditCardSettings();
        configCCDefaultSetting.Alternate_Delivery_Attention_To__c = 'Config Test Config Test Config Test Config Test ';
        configCCDefaultSetting.Alternate_Delivery_Address_1__c = 'Config Test Config Test Config Test Config Test ';
        configCCDefaultSetting.Alternate_Delivery_Address_2__c = 'Test';
        configCCDefaultSetting.Alternate_Delivery_City__c = 'Test';
        configCCDefaultSetting.Alternate_Delivery_State__c = 'TE';
        configCCDefaultSetting.Alternate_Delivery_Postal_Code__c = 'Test';
        
        insert configCCDefaultSetting;
        
        //Query result of Record Types
        List<RecordType> recordTypes = [SELECT Id, DeveloperName FROM RecordType WHERE IsActive = true AND 
                                            SobjectType = 'Contact' AND DeveloperName =: Constants.CONTACT_RECORD_TYPE_DEVELOPER_NAME_EMPLOYEE Limit 1];
        
        //assert statements
        System.assert(recordTypes != null);
        System.assertEquals(1, recordTypes.size());
                    
        //List to hold Contact and insert contacts
        List<Contact> contacts = new List<Contact>();
        contacts.add(new Contact(FirstName = 'Test', LastName = 'Contact 1', RecordTypeId = recordTypes[0].Id, Employee_Id__c = '12341'));
        insert contacts;
        
        //Payment Account record
        List<Portfolio__c> payments = new List<Portfolio__c>();
        payments.add(new Portfolio__c(Status__c = Constants.ACTIVE, Card_Holder__c = contacts[0].Id, Portfolio_Owner_Finance_Code__c = '678981'));
        insert payments;
        
        //Encrypt Card Number String
        String encryptCardNumber1 = CreditCardService.Encrypt('5567356025410287');
        
        //Credit Card record   
        List<Credit_Card__c> cards = new List<Credit_Card__c>(); 
        cards.add(new Credit_Card__c(Card_Number__c = encryptCardNumber1, Status__c = 'Active', Payment_Account__c = payments[0].Id,
                                        /*Override_Card_Limit__c = 1000, Override_Balance_Limit_Warning_Level__c = 20,*/ Card_Requested_By__c = contacts[0].Id));
        insert cards;
        
        //HttpRequest instance
        Httprequest req = new Httprequest();
        
        //instance of Mock service class 
        CreditCardServiceMockClass mockController = new CreditCardServiceMockClass();
        
        //Set mock
        CreditCardServiceMockClass.methodNumber = 3;
        
        //Response of addCreditCard request
        HttpService.response = mockController.respond(req);
        
        //Start Testing from here
        Test.startTest();
        
        //Execute trigger
        Util.BypassAllTriggers = false;
        
        //Update the contact address and Update the flag.
        contacts[0].Personal_Address_Line_1__c = 'Test-Test-Test-Test-Test-Test-Test-Test-Test-Test-Test-Test';
        contacts[0].Personal_Address_Line_2__c = 'Test';
        contacts[0].Personal_Address_City__c = 'Test';
        contacts[0].Personal_Address_State__c = 'TE';
        contacts[0].Personal_Address_PostalCode__c = 'Test';
        contacts[0].Personal_Address_Country__c = 'US';
        contacts[0].Personal_Address_Updated__c = true;
        contacts[0].Legal_First_Name__c = 'Test';
        contacts[0].Legal_Last_Name__c = 'Test';
        
        //Update Contact
        update contacts[0];
        
        //Assert for the results
        Portfolio__c payment = [Select Id, Billing_Address_Line_1__c, Billing_Address_Line_2__c, Billing_Address_City__c, Billing_Address_State__c,
                                    Billing_Address_PostalCode__c /*,First_Name_On_Card__c, Last_Name_On_Card__c*/ from Portfolio__c where Id IN: payments];
        System.assert(payment.Billing_Address_Line_1__c.length() == 30);
        System.assertEquals(contacts[0].Personal_Address_Line_2__c, payment.Billing_Address_Line_2__c);
        System.assertEquals(contacts[0].Personal_Address_City__c, payment.Billing_Address_City__c);
        System.assertEquals(contacts[0].Personal_Address_State__c, payment.Billing_Address_State__c);
        System.assertEquals(contacts[0].Personal_Address_PostalCode__c, payment.Billing_Address_PostalCode__c);
        
        //Stop test here
        Test.stopTest();
    }
    
     //Modified By - Abhinav Sharma - CR-20150202-8641 - To refactor the existing code
     /**
    * @description : This method is to check if updating the contact address will update the Portfolio address
    **/
    static testMethod void testUpdatePersonalAddressNonUS() {
        
        //Bypass Dupeblocker
        Util.IsTest(true);
        
        //Bypassing Triggers so then test data can be created easily
        Util.byPassAllTriggers = true;
        
        //Flag for triggers: this is just a test, don't do crazy things.
        Util.isTesting = true;
        
        //insert Credit Card Settings record
        Credit_Card_Settings__c configCCDefaultSetting = TestUtilities.CreateCreditCardSettings();
        configCCDefaultSetting.Alternate_Delivery_Attention_To__c = 'Config Test Config Test Config Test Config Test ';
        configCCDefaultSetting.Alternate_Delivery_Address_1__c = 'Config Test Config Test Config Test Config Test ';
        configCCDefaultSetting.Alternate_Delivery_Address_2__c = 'Test';
        configCCDefaultSetting.Alternate_Delivery_City__c = 'Test';
        configCCDefaultSetting.Alternate_Delivery_State__c = 'TE';
        configCCDefaultSetting.Alternate_Delivery_Postal_Code__c = 'Test';
        
        insert configCCDefaultSetting;
        
        //Query result of Record Types
        List<RecordType> recordTypes = [SELECT Id, DeveloperName FROM RecordType WHERE IsActive = true AND 
                                            SobjectType = 'Contact' AND DeveloperName =: Constants.CONTACT_RECORD_TYPE_DEVELOPER_NAME_EMPLOYEE Limit 1];
        
        //assert statements
        System.assert(recordTypes != null);
        System.assertEquals(1, recordTypes.size());
                    
        //List to hold Contact and insert contacts
        List<Contact> contacts = new List<Contact>();
        contacts.add(new Contact(FirstName = 'Test', LastName = 'Contact 1', RecordTypeId = recordTypes[0].Id, Employee_Id__c = '12341'));
        insert contacts;
        
        //Payment Account record
        List<Portfolio__c> payments = new List<Portfolio__c>();
        payments.add(new Portfolio__c(Status__c = Constants.ACTIVE, Card_Holder__c = contacts[0].Id, Portfolio_Owner_Finance_Code__c = '678981'));
        insert payments;
        
        //Encrypt Card Number String
        String encryptCardNumber1 = CreditCardService.Encrypt('5567356025410287');
        
        //Credit Card record   
        List<Credit_Card__c> cards = new List<Credit_Card__c>(); 
        cards.add(new Credit_Card__c(Card_Number__c = encryptCardNumber1, Status__c = 'Active', Payment_Account__c = payments[0].Id,
                                         Card_Requested_By__c = contacts[0].Id));
        insert cards;
        
        //HttpRequest instance
        Httprequest req = new Httprequest();
        
        //instance of Mock service class 
        CreditCardServiceMockClass mockController = new CreditCardServiceMockClass();
        
        //Set mock
        CreditCardServiceMockClass.methodNumber = 3;
        
        //Response of addCreditCard request
        HttpService.response = mockController.respond(req);
        
        //Start Testing from here
        Test.startTest();
        
        //Execute trigger
        Util.BypassAllTriggers = false;
        
        //Update the contact address and Update the flag.
        contacts[0].Personal_Address_Line_1__c = 'Test-Test-Test-Test-Test-Test-Test-Test-Test-Test-Test-Test';
        contacts[0].Personal_Address_Line_2__c = 'Test';
        contacts[0].Personal_Address_City__c = 'Test';
        contacts[0].Personal_Address_State__c = 'TE';
        contacts[0].Personal_Address_PostalCode__c = 'Test';
        contacts[0].Personal_Address_Country__c = 'Test';
        contacts[0].Personal_Address_Updated__c = true;
        contacts[0].Legal_First_Name__c = 'Test';
        contacts[0].Legal_Last_Name__c = 'Test';
        
        //Update Contact
        update contacts[0];
        
        //Assert for the results
        Portfolio__c payment = [Select Id, Billing_Address_Updated__c, Billing_Address_Line_1__c, Billing_Address_Line_2__c, Billing_Address_City__c, Billing_Address_State__c,
                                    Billing_Address_PostalCode__c from Portfolio__c where Id IN: payments];
        System.assert(payment.Billing_Address_Line_1__c.length() == 30);
        System.assertEquals(configCCDefaultSetting.Alternate_Delivery_Address_2__c, payment.Billing_Address_Line_2__c);
        System.assertEquals(configCCDefaultSetting.Alternate_Delivery_City__c, payment.Billing_Address_City__c);
        System.assertEquals(configCCDefaultSetting.Alternate_Delivery_State__c, payment.Billing_Address_State__c);
        System.assertEquals(configCCDefaultSetting.Alternate_Delivery_Postal_Code__c, payment.Billing_Address_PostalCode__c);
        System.assert(payment.Billing_Address_Updated__c);
        
        //Stop test here
        Test.stopTest();
    }
    
    //Modified By - Abhinav Sharma - CR-20150202-8641 - To refactor the existing code
    //Added By - Abhinav Sharma - 08/13/2014 - CR-20140604-5691
     /**
    * @description : //This method is to check if switching can take place for a contact record in between inactive institution record to active institution record
    **/
    static testMethod void testContactSwitchInBetweenInActiveToActiveInstitution() {
        
        //Bypass Dupeblocker
        Util.IsTest(true);
        
        //Bypassing Triggers so then test data can be created easily
        Util.byPassAllTriggers = true;
        
        //Flag for triggers: this is just a test, don't do crazy things.
        Util.isTesting = true;
        
        //Creating test data
        
        //List to hold the Account record type
        List<RecordType> accountRdTypes = [SELECT ID FROM RecordType WHERE DeveloperName = 'US_Provider' AND sObjectType = 'Account' AND IsActive = true];
        
        //List to hold the contact record types
        List<RecordType> contactRdTypes = [SELECT ID FROM RecordType WHERE DeveloperName = 'External_Advisory_com_User' AND sObjectType = 'Contact' AND IsActive = true];
        
        //Asserting for the results
        System.assert(accountRdTypes != null);
        System.assert(contactRdTypes != null);
        System.assert(accountRdTypes.size() > 0);
        System.assert(contactRdTypes.size() > 0);
        
        //Profile    
        Profile p = [SELECT Id FROM Profile WHERE Name='Specialist'];
        System.assert(p != null);
      
        //User
        User u = new User(Alias = 'standt', Email='standarduser@testorg.com', 
                            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                            LocaleSidKey='en_US', ProfileId = p.Id, department = 'STP',
                            TimeZoneSidKey='America/Los_Angeles', UserName=Math.random() + '@test.com');

        //Running the test in context of specialist user context
        System.runAs(u) {
            
            //Ebaling triggers
            Util.bypassAllTriggers = false;
            
            //Site profile
            Site_Profile__c sProfile1 = Test_SiteUserHelper.createSiteProfile(SiteUserHelper.SITE_ADVISORY, false);
            sProfile1.Bypass_Domain_Validation__c = true;
            
            //Enabling triggers
            Util.bypassAllTriggers = false;
            
            //Site profile
            Site_Profile__c sProfile2 = Test_SiteUserHelper.createSiteProfile(SiteUserHelper.SITE_ADVISORY, false);
            sProfile2.Bypass_Domain_Validation__c = true;
            
            //List of site profiles
            list<Site_Profile__c> sProfiles = new list<Site_Profile__c> { sProfile1, sProfile2 };
            insert sProfiles;
            
            //Retrieving updated information from the database
            sProfiles = [SELECT Id, Bypass_Domain_Validation__c, Contact__r.AccountId, Contact__c FROM Site_Profile__c WHERE Id IN :sProfiles];
            
            //Asserting for the results
            for (Site_Profile__c sp : sProfiles)
                system.assertEquals(true, sp.Bypass_Domain_Validation__c);
            
            //List to hold the contact records
            List<Contact> contacts = new List<Contact>();
        
            //Contact Instance
            Contact contact_1 = new Contact(Id = sProfile1.Contact__c);
            contact_1.FirstName = 'Contact';
            contact_1.LastName = 'Record1';
            contact_1.Email = 't1' + sProfile1.Username__c;
            contact_1.Contact_Status__c = 'Active';
            contact_1.Advisory_com_Preferred_Email_Address__c = 'test2342243434@test.com';
            
            //Contact Instance
            Contact contact_2 = new Contact(Id = sProfile2.Contact__c);
            contact_2.FirstName = 'Contact';
            contact_2.LastName = 'Record2';
            contact_2.Email = 't2' + sProfile2.Username__c;
            contact_2.Contact_Status__c = 'Active';
            contact_2.Advisory_com_Preferred_Email_Address__c = 'test23422434884@test.com';
        
            //Adding records into the list
            contacts.add(contact_1);
            contacts.add(contact_2);
            
            //Insert Accounts
            update contacts;
            
            //Disbaling triggers
            Util.bypassAllTriggers = false;
            
            //Restriction 
            Restrictions__c restriction = new Restrictions__c();
            restriction.Category__c = 'Critical Background Information';
            restriction.Source_Department__c = 'EA';
            restriction.Expiration_Date__c = System.today().addDays(6);
            insert restriction;
        
            //Restriction mTM
            Restricted_MtM__c restrictMTM = new Restricted_MtM__c();
            restrictMTM.Account__c = sProfiles[0].Contact__r.AccountId;
            restrictMTM.Contact__c = sProfiles[1].Contact__c;
            restrictMTM.Restriction__c = restriction.ID;
            insert restrictMTM;
            
            //Start Test from Here
            Test.startTest();
            
            //Updating contact record which was associated with Inactive institution
            Util.BypassAllTriggers = false;
            SiteUserHelper.IsTriggerContact = false;
            ContactSiteHelper.hasCheckedInstitutionChange = false;
            contacts[0].AccountId = sProfiles[1].Contact__r.AccountId;
            update contacts[0];
            
            //Changing Institution status to "Inactive"
            Account acct1 = new Account(Id = sProfiles[0].Contact__r.AccountId);
            acct1.Status__c = 'Inactive - Closed';
            
            //Enabling triggers again
            Util.BypassAllTriggers = false;
            
            //Update Accounts
            update acct1;
            
            //Query for the contact records
            contacts = [SELECT ID, Bypass_Filters__c, FirstName, LastName FROM Contact ORDER BY LastName ASC];
            System.assert(contacts != null);
            system.assertEquals(3, contacts.size());
            
            //Asserting for results
            System.assert(!contacts[0].Bypass_Filters__c);
            System.assert(contacts[1].Bypass_Filters__c);
            System.assert(!contacts[2].Bypass_Filters__c);
            System.assertEquals('Record1', contacts[0].LastName);
            System.assertEquals('Record1', contacts[1].LastName);
            System.assertEquals('Record2', contacts[2].LastName);
               
            //Stop Test Here
            Test.stopTest();
        }
    }
    
    //Modified By - Abhinav Sharma - CR-20150202-8641 - To refactor the existing code
     /**
    * @description : Test methods to test the resendBouncedAgreement functionality.
    **/
    static testMethod void testResendBouncedAgreement() {
        
        //Bypass Dupeblocker
        Util.IsTest(true);
        
        //Bypassing Triggers so then test data can be created easily
        Util.byPassAllTriggers = true;
        
        //Flag for triggers: this is just a test, don't do crazy things.
        Util.isTesting = true;
        
        //Query result of Record Types
        List<RecordType> recordTypes = [SELECT Id, DeveloperName FROM RecordType WHERE IsActive = true AND 
                                            SobjectType = 'Contact' AND DeveloperName =: Constants.CONTACT_RECORD_TYPE_DEVELOPER_NAME_EMPLOYEE Limit 1];
        
        //assert statements
        System.assert(recordTypes != null);
        System.assertEquals(1, recordTypes.size());
        
        //Create a new document record
        Folder f = [Select Id from Folder where DeveloperName = 'Credit_Card_Admin' limit 1];
        System.assert(f != null);
        
        //Enabling triggers
        Util.byPassAlltriggers = false;
        
        Document document = new Document(FolderId = f.Id, Name = 'Test', DeveloperName = CreditCardConstants.DOCUMENT_DEVELOPER_NAME_ADVISORY_BOARD_CREDIT_CARD_AGREEMENT, Body = Blob.valueOf('TEST'));
        try {
            insert document;
        } catch(Exception e) {
            
            //Even teh test method is not using any org data, but at the time of production validation, 
            //Salesforce is not allowoing to create thus document record because of the DeveeloperName uniqueness.
            //Just catching the exception and only procedding in document was inserted
        }
        
        if(document.Id == null)
            return;
        
        //List to hold Contact
        List<Contact> contacts = new List<Contact>();
        contacts.add(new Contact(FirstName = 'Test', LastName = 'Contact 1', RecordTypeId = recordTypes[0].Id, Employee_Id__c = '12341'));
        
        //insert contacts
        insert contacts;
        
        //List of OSR to be record
        List<OSR__c> osrs = new List<OSR__c>();
        osrs.add(new OSR__c(Status__c = CreditCardConstants.OSR_STATUS_NEW, Request_Type__c = CreditCardConstants.OSR_REQUEST_TYPE_NEW_ABC_CREDIT_CARD, 
                                Contact__c = contacts[0].Id));
        
        //Test method starts here
        Test.startTest();
        
        //Enabling triggers
        Util.byPassAlltriggers = false;
        
        //Insert OSR
        insert osrs;
            
        //Query result of Agreement
        List<echosign_dev1__SIGN_Agreement__c> agreements = [SELECT Id, echosign_dev1__Recipient__c FROM echosign_dev1__SIGN_Agreement__c WHERE OSR__c IN: osrs];
        System.assert(agreements != null);
        System.assertEquals(1, agreements.size());
        agreements[0].echosign_dev1__Recipient__c = contacts[0].Id;
        update agreements;
        
        //Create a new Agreement Event record with the failure reson
        echosign_dev1__SIGN_AgreementEvent__c agreementEvent = new echosign_dev1__SIGN_AgreementEvent__c();
        agreementEvent.echosign_dev1__Description__c = 'Advisory Board Credit Card Agreement email bounced';
        agreementEvent.echosign_dev1__SIGN_Agreement__c = agreements[0].Id;
        insert agreementEvent;
        
        //We have been created a bounced email record. Now Change the email address of the contact.
        ContactTriggerUtilities.EXECUTE_RESEND_BOUNCED_AGREEMENT = true;
        contacts[0].Email = 'testingRecord@gmail.com';
        
        //Update contacts
        agreements = [SELECT Id FROM echosign_dev1__SIGN_Agreement__c WHERE OSR__c IN: osrs];
        update contacts[0];
        
        //Query result of Agreement
        agreements = [SELECT Id FROM echosign_dev1__SIGN_Agreement__c WHERE OSR__c IN: osrs];
        
        //Asserting for the results
        System.assert(agreements != null);
        System.assertEquals(2, agreements.size());
        
        //Stop test
        Test.stopTest();
    }
    
    //Modified By - Abhinav Sharma - CR-20150202-8641 - To refactor the existing code
    //Added - By Mahendra Swarnkar - CR-20150831-9207 - 11/26/2015 
    /**
    * @description : Test methods to test the CR-20150831-9207 based functionality.
    **/
    static testMethod void testvalidateContactFieldsForInvalidPhraseFirstName() {
        
        //Bypass Dupeblocker
        Util.IsTest(true);
        
        //Bypassing Triggers so then test data can be created easily
        Util.byPassAllTriggers = true;
        
        //Flag for triggers: this is just a test, don't do crazy things.
        Util.isTesting = true;
        
        //Inserting Custom setting 
        Invalid_Phrase_Characters__c invalidphraseCustomSeting = new Invalid_Phrase_Characters__c(Invalid_Phrase__c = '2', 
                                                                                                  Object_Name__c = 'Contact', 
                                                                                                  Name = '1');
        insert invalidphraseCustomSeting;
        
        //Create contact record
        Contact contactA = new Contact(FirstName = 'Test2', LastName = 'LastName1', Email = 'abc@abc.com', 
                                        Bypass_Domain_Validation__c = true, Is_Ignore_Phrase_Characters__c = true);
        
        //Test starts from here
        Test.startTest();
        
        //Bypass all triggers
        Util.BypassAllTriggers = false;
        
        //Insert contact
        insert contactA;
        
        //Asserts on result
        System.assert(contactA != null);
        System.assertEquals('Test2', contactA.FirstName);
        System.assertEquals('LastName1', contactA.LastName);
        System.assertEquals('abc@abc.com', contactA.Email);
        
        //Create contact record
        Contact contactB =new Contact(FirstName = 'Test2', LastName = 'LastName1', Email = 'abc@abc.com', 
                                      Bypass_Domain_Validation__c = true);
        
        //Making a try to insert the contact recird
        try {
            insert contactB;
        } catch(Exception e){
            system.assertEquals(true, e.getMessage().contains(System.Label.Invalid_Phrase_Error_On_Contact));
        }
        
        //Create contact record
        Contact contactC = new Contact(FirstName = 'Test3', LastName = 'LastName3', Email = 'abc@abc.com', 
                                        Bypass_Domain_Validation__c = true, Is_Ignore_Phrase_Characters__c = true);
        
        //Insert contact
        insert contactC;
        
        //Test Ends here
        Test.stopTest();
    }
    
    //Modified By - Abhinav Sharma - CR-20150202-8641 - To refactor the existing code
    //Added - By Mahendra Swarnkar - CR-20150831-9207 - 11/26/2015 
    /**
    * @description : Test methods to test the CR-20150831-9207 based functionality.
    **/
    static testMethod void testvalidateContactFieldsForInvalidPhrase_UpdateCase() {
        
        //Bypass Dupeblocker
        Util.IsTest(true);
        
        //Bypassing Triggers so then test data can be created easily
        Util.byPassAllTriggers = true;
        
        //Flag for triggers: this is just a test, don't do crazy things.
        Util.isTesting = true;
        
        //Inserting Custom setting
		List<Invalid_Phrase_Characters__c> invalidPhraseCustomSettingList = new List<Invalid_Phrase_Characters__c>();
		
		//Invaild Phrase Characters record
        Invalid_Phrase_Characters__c invalidphraseCustomSetting_1 = new Invalid_Phrase_Characters__c(Invalid_Phrase__c = '2', 
                                                                                                  		Object_Name__c = 'Contact',
                                                                                                  		Applicable_For__c = 'FirstName,LastName',
                                                                                                  		Name = '1');
        
         Invalid_Phrase_Characters__c invalidphraseCustomSetting_2 = new Invalid_Phrase_Characters__c(Invalid_Phrase__c = '*', 
                                                                                                  		Object_Name__c = 'Contact',
                                                                                                  		Applicable_For__c = 'FirstName,LastName,Title,Email',
                                                                                                  		Name = '2');        
                                                                                                  		
  		//Populating list with records
  		invalidPhraseCustomSettingList.add(invalidphraseCustomSetting_1);
  		invalidPhraseCustomSettingList.add(invalidphraseCustomSetting_2);                                                                             		
        insert invalidPhraseCustomSettingList;
        
        //Create contact record
        Contact contactA = new Contact( FirstName = 'Test', LastName = 'LastName1', Email = 'abc2@abc.com', Title = 'TestTitle2',
                                       	Bypass_Domain_Validation__c = true, Is_Ignore_Phrase_Characters__c = false);
        
        //Test starts from here
        Test.startTest();
        
        //Enables the trigger
        Util.BypassAllTriggers = false;
        
        //Insert contact
        insert contactA;
        
        //Asserts on result
        System.assert(contactA != null);
        System.assertEquals('Test', contactA.FirstName);
        System.assertEquals('LastName1', contactA.LastName);
        System.assertEquals('abc2@abc.com', contactA.Email);
        System.assertEquals('TestTitle2', contactA.Title);
        
        //Update the contact email
        contactA.Title = 'Test*Title2';
        
        try {
            
            //Enables the trigger
            Util.BypassAllTriggers = false;
            
            //Update contact
            update contactA;
            
        } catch(Exception e) {
            System.assertEquals(true, e.getMessage().contains(System.Label.Invalid_Phrase_Error_On_Contact));
        }
        
        //Test Ends here
        Test.stopTest();
    }
    
    //Modified By - Abhinav Sharma - CR-20150202-8641 - To refactor the existing code
    //Added - By Mahendra Swarnkar - CR-20150831-9207 - 11/26/2015 
    /**
    * @description : Test methods to test the CR-20150831-9207 based functionality.
    **/
    static testMethod void testvalidateContactFieldsForInvalidPhraseLastName() {
        
        //Bypass Dupeblocker
        Util.IsTest(true);
        
        //Bypassing Triggers so then test data can be created easily
        Util.byPassAllTriggers = true;
        
        //Flag for triggers: this is just a test, don't do crazy things.
        Util.isTesting = true;
        
        //Inserting Custom setting 
        Invalid_Phrase_Characters__c invalidphraseCustomSeting = new Invalid_Phrase_Characters__c(Invalid_Phrase__c = 'Duplicate', 
                                                                                                  Object_Name__c = 'Contact',
                                                                                                  Applicable_For__c = 'FirstName,LastName,Email,Title', 
                                                                                                  Name = '1');
        insert invalidphraseCustomSeting;
        
        //Create contact record
        Contact contactA = new Contact( FirstName = 'Test', LastName = 'LastNameDuplicate', Email = 'abc@abc.com', 
                                       	Bypass_Domain_Validation__c = true, Is_Ignore_Phrase_Characters__c = true);
        
        //Test starts from here
        Test.startTest();
        
        //Enable all triggers
        Util.BypassAllTriggers = false;
        
        //Insert contact
        insert contactA;
        
        //Asserts on result
        System.assert(contactA != null);
        System.assertEquals('Test', contactA.FirstName);
        System.assertEquals('LastNameDuplicate', contactA.LastName);
        System.assertEquals('abc@abc.com', contactA.Email);
        
        //Create contact record
        Contact contactB = new Contact(FirstName = 'Test2', LastName = 'LastNameDuplicate', Email = 'abc@abc.com', Bypass_Domain_Validation__c = true);
        
        try{
            insert contactB;
        } catch(Exception e){
            system.assertEquals(true, e.getMessage().contains(System.Label.Invalid_Phrase_Error_On_Contact));
        }
        
        //Test Ends here
        Test.stopTest();
    }
    
    //Modified By - Abhinav Sharma - CR-20150202-8641 - To refactor the existing code
    //Added - By Mahendra Swarnkar - CR-20150831-9207 - 11/26/2015 
    /**
    * @description : Test methods to test the CR-20150831-9207 based functionality.
    **/
    static testMethod void testvalidateContactFieldsForInvalidPhraseEmail() {
        
        //Bypass Dupeblocker
        Util.IsTest(true);
        
        //Bypassing Triggers so then test data can be created easily
        Util.byPassAllTriggers = true;
        
        //Flag for triggers: this is just a test, don't do crazy things.
        Util.isTesting = true;
        
        //Inserting Custom setting
		List<Invalid_Phrase_Characters__c> invalidPhraseCustomSettingList = new List<Invalid_Phrase_Characters__c>();
		
		//Invaild Phrase Characters record
        Invalid_Phrase_Characters__c invalidphraseCustomSetting_1 = new Invalid_Phrase_Characters__c(Invalid_Phrase__c = '2', 
                                                                                                  		Object_Name__c = 'Contact',
                                                                                                  		Applicable_For__c = 'FirstName,LastName',
                                                                                                  		Name = '1');
        
         Invalid_Phrase_Characters__c invalidphraseCustomSetting_2 = new Invalid_Phrase_Characters__c(Invalid_Phrase__c = '*', 
                                                                                                  		Object_Name__c = 'Contact',
                                                                                                  		Applicable_For__c = 'FirstName,LastName,Title,Email',
                                                                                                  		Name = '2');        
                                                                                                  		
  		//Populating list with records
  		invalidPhraseCustomSettingList.add(invalidphraseCustomSetting_1);
  		invalidPhraseCustomSettingList.add(invalidphraseCustomSetting_2);                                                                             		
        insert invalidPhraseCustomSettingList;
        
        //Create contact record
        Contact contactA = new Contact(FirstName = 'Test', LastName = 'LastNameDuplicate', Email = 'abc*@abc.com', 
                                       	Bypass_Domain_Validation__c = true, Is_Ignore_Phrase_Characters__c = true);
        
        //Test starts from here
        Test.startTest();
        
        //Enable all triggers
        Util.BypassAllTriggers = false;
        
        //Insert contact
        insert contactA;
        
        //Asserts on result
        System.assert(contactA != null);
        system.assertEquals('Test', contactA.FirstName);
        system.assertEquals('LastNameDuplicate', contactA.LastName);
        system.assertEquals('abc*@abc.com', contactA.Email);
        
        //Create contact record
        Contact contactB =new Contact(FirstName = 'Test', LastName = 'LastName', Email = 'abc*abc2@abc.com', 
                                      Bypass_Domain_Validation__c = true);
        try {
            //Insert contact
            insert contactB;
        } catch(Exception e){
           System.assertEquals(true, e.getMessage().contains(System.Label.Invalid_Phrase_Error_On_Contact));
        }
        
        //Memory allocation and populating email with some different value
        contactB =new Contact(FirstName = 'Test', LastName = 'LastName', Email = 'abcabc2@abc.com', 
                          Bypass_Domain_Validation__c = true);
        insert contactB;
        
        //Asserting for the results
        System.assert(contactB != null);
        
        //Test Ends here
        Test.stopTest();
    }
    
    //Modified By - Abhinav Sharma - CR-20150202-8641 - To refactor the existing code
    //Merged the code from Test_Contact_Restriction_Status class as per the Refactor Release
    /**
    * @description : Test methods to test out the code logic written in Test_Contact_Restriction_Status apex trigger.
    **/
    static testmethod void myUnitTest() {
         
        //Bypass Dupeblocker
        Util.IsTest(true);
        
        //Bypassing Triggers so then test data can be created easily
        Util.byPassAllTriggers = true;
        
        //Flag for triggers: this is just a test, don't do crazy things.
        Util.isTesting = true;
        
        // List to store test Accounts
        List<Account> testAccts = new List<Account>();
    
        // Create a restricted account
        Account a = new Account(
            Name = 'Test Case Account 1',
            Account_Restriction_Status__c = 'Restricted: Permission Required');
        
        //Populating collection with the instance
        testAccts.add(a);
        
        //Account
        Account a1 = new Account(
            Name = 'Test Case Account 2');
        
        //Populating collection with the instance
        testAccts.add(a1);
        
        //Insert account records
        insert testAccts;
        
        //Retreiving "External" Record type for Contact object
        RecordType externalRecordType = [SELECT ID, DeveloperName FROM RecordType WHERE SobjectType = 'Contact' AND IsActive = true 
                                            AND DeveloperName = 'External' LIMIT 1];
        System.assert(externalRecordType != null);                                      
        
        // List to store test Contacts
        List<Contact> testContacts = new List<Contact>();
        
        // Create a test Contact
        Contact c = new Contact(accountid = a.id , Lastname = 'toto', recordtypeid = externalRecordType.ID);
        testContacts.add(c);
        
        Contact c1 = new Contact(accountid = a1.id, Lastname = 'toto', recordtypeid = externalRecordType.ID);
        testContacts.add(c1);
        
        //Test Starts From Here
        test.startTest();
        
        //Enable triggers
        Util.byPassAllTriggers = false;
        
        // Insert test Contact
        insert testContacts;
        
        //Test Ends Here
        test.stopTest();
        
        // Requery the Contact to retrive updates
        c = [select id, Contact_Restriction_Status__c from Contact where id = :c.id];
        c1 = [select id, Contact_Restriction_Status__c from Contact where id = :c1.id];
        
        // Assert that the Contacts are restricted or unrestricted based on their account
        System.assertEquals('Account - Restricted: Permission Required', c.Contact_Restriction_Status__c);
        System.assertEquals(null, c1.Contact_Restriction_Status__c);
        
    }
    
    //Added by -  Mahendra Swarnkar - 7/16/2016 - CR-20150202-8641 
    /** Description : Method to test out various use cases associated with Contact trigger to the delete 
      *               functionality of Mambership Key Contact sfor Inactive Contacts .
      **/
    static testmethod void testdeleteKeyMemberContactsForInActiveContacts() {
    
        //Bypass Dupeblocker
        Util.IsTest(true);
        
        //Bypassing Triggers so then test data can be created easily
        Util.byPassAllTriggers = true;
        
        //Flag for triggers: this is just a test, don't do crazy things.
        Util.isTesting = true;
       
        //List of Program
        List<Program__c> programs = new List<Program__c>();
        
        //Add new Programs in list
        programs.add(new Program__c(Name = 'Test Program 1', Status__c = 'Active'));
        programs.add(new Program__c(Name = 'Test Program 2', Status__c = 'Active'));
        programs.add(new Program__c(Name = 'Test Program 3', Status__c = 'Active'));
        programs.add(new Program__c(Name = 'Test Program 4', Status__c = 'Active'));
        
        //Insert
        insert programs;
        
        //Create restricted accounts
        List<Account> accounts = new List<Account>();
        
        //Added records in list 
        accounts.add(new Account(Name = 'account 1'));
        accounts.add(new Account(Name = 'account 2'));
        accounts.add(new Account(Name = 'account 3'));
        accounts.add(new Account(Name = 'account 4'));
        
        //Insert 
        insert accounts;
        
        //Retreiving "External" Record type for Contact object
        RecordType externalRecordType = [SELECT ID, DeveloperName FROM RecordType 
                                         WHERE SobjectType = 'Contact' AND IsActive = true 
                                         AND DeveloperName = 'External' LIMIT 1];
        
        // List to store test Contacts
        List<Contact> contacts = new List<Contact>();
        
        //Add contact data in list
        contacts.add(new Contact(accountid = accounts[0].id , Lastname = 'contact 1', recordtypeid = externalRecordType.ID, Contact_Status__c = 'Inactive - Moved Institutions'));
        contacts.add(new Contact(accountid = accounts[1].id , Lastname = 'contact 2', recordtypeid = externalRecordType.ID, Contact_Status__c = 'Inactive - Moved Institutions'));
        contacts.add(new Contact(accountid = accounts[2].id , Lastname = 'contact 3', recordtypeid = externalRecordType.ID, Contact_Status__c = 'Inactive - Moved Institutions'));
        contacts.add(new Contact(accountid = accounts[3].id , Lastname = 'contact 4', recordtypeid = externalRecordType.ID, Contact_Status__c = 'Inactive - Moved Institutions'));
       
        //Insert Contact Data
        insert contacts;
        
        //List to hold membership records
        List<Membership__c> memberships = new List<Membership__c>();
        
        //Added records in list
        memberships.add(new Membership__c(Name = 'Membership 1',Account_Name__c = accounts[0].Id, Program__c = programs[0].Id));
        memberships.add(new Membership__c(Name = 'Membership 2',Account_Name__c = accounts[0].Id, Program__c = programs[0].Id));
        memberships.add(new Membership__c(Name = 'Membership 3',Account_Name__c = accounts[0].Id, Program__c = programs[0].Id));
        memberships.add(new Membership__c(Name = 'Membership 4',Account_Name__c = accounts[0].Id, Program__c = programs[0].Id));
        
        //Insert
        insert memberships;
            
        //Create a list of membership records
        List<Membership_Key_Contact__c> membershipKeyContacts = new List<Membership_Key_Contact__c>();
        
        //add record in list
        membershipKeyContacts.add(new Membership_Key_Contact__c(Contact__c = contacts[0].id, Name='Test 1', Role_Type__c = 'PT', Role__c = 'Exec Sponsor', Membership__c = memberships[0].Id));
        membershipKeyContacts.add(new Membership_Key_Contact__c(Contact__c = contacts[1].id, Name='Test 2', Role_Type__c = 'PT', Role__c = 'Exec Sponsor', Membership__c = memberships[0].Id));
        membershipKeyContacts.add(new Membership_Key_Contact__c(Contact__c = contacts[2].id, Name='Test 3', Role_Type__c = 'PT', Role__c = 'Exec Sponsor', Membership__c = memberships[0].Id));
        membershipKeyContacts.add(new Membership_Key_Contact__c(Contact__c = contacts[3].id, Name='Test 4', Role_Type__c = 'PT', Role__c = 'Exec Sponsor', Membership__c = memberships[0].Id));
        membershipKeyContacts.add(new Membership_Key_Contact__c(Contact__c = contacts[2].id, Name='Test 5', Role_Type__c = 'PT', Role__c = 'Exec Sponsor', Membership__c = memberships[0].Id));
        membershipKeyContacts.add(new Membership_Key_Contact__c(Contact__c = contacts[2].id, Name='Test 6', Role_Type__c = 'PT', Role__c = 'Exec Sponsor', Membership__c = memberships[0].Id));
        membershipKeyContacts.add(new Membership_Key_Contact__c(Contact__c = contacts[3].id, Name='Test 7', Role_Type__c = 'PT', Role__c = 'Exec Sponsor', Membership__c = memberships[0].Id));
        membershipKeyContacts.add(new Membership_Key_Contact__c(Contact__c = contacts[3].id, Name='Test 8', Role_Type__c = 'PT', Role__c = 'Exec Sponsor', Membership__c = memberships[0].Id));
        
        //Insert
        insert membershipKeyContacts;
        
        //List to hold records
        List<Subscription_Option__c> subscriptionOptions = new List<Subscription_Option__c>();
        
        //Added records in list 
        subscriptionOptions.add(new Subscription_Option__c(Name = 'Subscription 1'));
        subscriptionOptions.add(new Subscription_Option__c(Name = 'Subscription 2'));
        subscriptionOptions.add(new Subscription_Option__c(Name = 'Subscription 3'));
        subscriptionOptions.add(new Subscription_Option__c(Name = 'Subscription 4'));
        
        //Insert records
        insert subscriptionOptions;
        
        //List to hold Eligible Subscription Option records
        List<Eligible_Subscription_Option__c> eligibleSubOptions = new List<Eligible_Subscription_Option__c>();
        
        //Added records in list
        eligibleSubOptions.add(new Eligible_Subscription_Option__c(Program__c = programs[0].Id, Related_Subscription__c = subscriptionOptions[0].Id));
        eligibleSubOptions.add(new Eligible_Subscription_Option__c(Program__c = programs[0].Id, Related_Subscription__c = subscriptionOptions[1].Id));
        eligibleSubOptions.add(new Eligible_Subscription_Option__c(Program__c = programs[0].Id, Related_Subscription__c = subscriptionOptions[2].Id));
        eligibleSubOptions.add(new Eligible_Subscription_Option__c(Program__c = programs[0].Id, Related_Subscription__c = subscriptionOptions[3].Id));
        
        //Insert
        insert eligibleSubOptions;
        
        //Create subscription records
        List<Subscription__c> subscriptions = new List<Subscription__c>();
        
        //Added records
        subscriptions.add(new Subscription__c(Subscription_Status__c = 'Sub 1', Contact__c = contacts[0].Id, Subscription_ID__c = eligibleSubOptions[0].Id));
        subscriptions.add(new Subscription__c(Subscription_Status__c = 'Sub 2', Contact__c = contacts[1].Id, Subscription_ID__c = eligibleSubOptions[0].Id));
        subscriptions.add(new Subscription__c(Subscription_Status__c = 'Sub 3', Contact__c = contacts[2].Id, Subscription_ID__c = eligibleSubOptions[0].Id));
        subscriptions.add(new Subscription__c(Subscription_Status__c = 'Sub 4', Contact__c = contacts[3].Id, Subscription_ID__c = eligibleSubOptions[0].Id));
        
        //Insert 
        insert subscriptions;
          
        //Start Test from here
        Test.startTest();
        
        //Enabling trigger
        Util.BypassAllTriggers = false;
        Util.BypassContactRestrictionTrigger = false;
        
        //Query over Contactt
        List<Contact> ContactList = [Select Id,Name From Contact];
        
        //Update
        update contacts;
        
        //Query on Subscription
        List<Subscription__c> subscriptionList = [Select Id,Subscription_Status__c, Termination_Date__c  From Subscription__c];
        system.assert(subscriptionList != null);
        system.assertEquals(4, subscriptionList.size());
        system.assertEquals('Sub 1', subscriptionList[0].Subscription_Status__c);
        system.assertEquals('Inactive - No Eligible Memberships - null', subscriptionList[1].Subscription_Status__c);
        system.assertEquals('Inactive - No Eligible Memberships - null', subscriptionList[2].Subscription_Status__c);
        system.assertEquals('Inactive - No Eligible Memberships - null', subscriptionList[3].Subscription_Status__c);
        system.assertNotEquals(null, subscriptionList[1].Termination_Date__c);
        system.assertNotEquals(null, subscriptionList[2].Termination_Date__c);
        system.assertNotEquals(null, subscriptionList[3].Termination_Date__c);
        
        //Query on Membership Key Contact
        LIst<Membership_Key_Contact__c> memberContactsList= [Select Id From Membership_Key_Contact__c];
        system.assert(memberContactsList != null);
        system.assertEquals(0, memberContactsList.size());
        
        //Stop Test here
        Test.stopTest();
    }
    
    //Added by -  Mahendra Swarnkar - 7/16/2016 - CR-20150202-8641 
    /** Description : Method to test out various use cases associated with Contact trigger to create Incentive change log records,
     *                on Create contact records or Update contact fields.
     **/
    static testMethod void testCreateIncentiveChangeLog(){
        
        //Bypass Dupeblocker
        Util.IsTest(true);
        
        //Bypassing Triggers so then test data can be created easily
        Util.byPassAllTriggers = true;
        
        //Flag for triggers: this is just a test, don't do crazy things.
        Util.isTesting = true;
       
        //List of Program
        List<Program__c> programs = new List<Program__c>();
        
        //Add new Programs in list
        programs.add(new Program__c(Name = 'Test Program 1', Status__c = 'Active'));
        programs.add(new Program__c(Name = 'Test Program 2', Status__c = 'Active'));
        programs.add(new Program__c(Name = 'Test Program 3', Status__c = 'Active'));
        programs.add(new Program__c(Name = 'Test Program 4', Status__c = 'Active'));
        
        //Insert
        insert programs;
        
        //Create restricted accounts
        List<Account> accounts = new List<Account>();
        
        accounts.add(new Account(Name = 'account 1'));
        accounts.add(new Account(Name = 'account 2'));
        accounts.add(new Account(Name = 'account 3'));
        
        //Insert 
        insert accounts;
        
        //Retreiving "External" Record type for Contact object
        RecordType externalRecordType = [SELECT ID, DeveloperName FROM RecordType WHERE SobjectType = 'Contact' AND IsActive = true AND DeveloperName = 'External' LIMIT 1];
        
        // List to store test Contacts
        List<Contact> contacts = new List<Contact>();
        
        //Add contact data in list
        contacts.add(new Contact(accountid = accounts[0].id , Lastname = 'contact 1', recordtypeid = externalRecordType.ID, Contact_Status__c = 'Inactive - Moved Institutions', Employee_User_Record__c = Userinfo.getUserId()));
        contacts.add(new Contact(accountid = accounts[1].id , Lastname = 'contact 2', recordtypeid = externalRecordType.ID, Contact_Status__c = 'Inactive - Moved Institutions', Employee_User_Record__c = Userinfo.getUserId()));
        contacts.add(new Contact(accountid = accounts[2].id , Lastname = 'contact 3', recordtypeid = externalRecordType.ID, Contact_Status__c = 'Inactive - Moved Institutions', Employee_User_Record__c = Userinfo.getUserId()));
        contacts.add(new Contact(accountid = accounts[2].id , Lastname = 'contact 4', recordtypeid = externalRecordType.ID, Contact_Status__c = 'Inactive - Moved Institutions', Employee_User_Record__c = Userinfo.getUserId()));
        
        //Start Test from here
        Test.startTest();
        
        //Enabling triggers
        Util.BypassAllTriggers = false;
        Util.BypassContactRestrictionTrigger = false;
        
        //Insert Contact Data
        insert contacts;
        
        //Query on Incentive change log
        List<Incentive_Change_Log__c> incenticeChangeLogs = [Select Id, Contact__c, Change_Type__c, Change_Element__c From Incentive_Change_Log__c];
        
        //Assert for result
        system.assert(incenticeChangeLogs != null);
        System.assertEquals(4, incenticeChangeLogs.size());
        System.assertEquals(contacts[0].Id, incenticeChangeLogs[0].Contact__c);
        System.assertEquals(ISSPConstants.INCENTIVE_CHANGE_LOG_CHANGE_TYPE_NEW, incenticeChangeLogs[0].Change_Type__c);
        System.assertEquals(ISSPConstants.INCENTIVE_CHANGE_LOG_CHANGE_ElEMENT_CONTACT, incenticeChangeLogs[0].Change_Element__c);
        System.assertEquals(contacts[1].Id, incenticeChangeLogs[1].Contact__c);
        System.assertEquals(ISSPConstants.INCENTIVE_CHANGE_LOG_CHANGE_TYPE_NEW, incenticeChangeLogs[1].Change_Type__c);
        System.assertEquals(ISSPConstants.INCENTIVE_CHANGE_LOG_CHANGE_ElEMENT_CONTACT, incenticeChangeLogs[1].Change_Element__c);
        System.assertEquals(contacts[2].Id, incenticeChangeLogs[2].Contact__c);
        System.assertEquals(ISSPConstants.INCENTIVE_CHANGE_LOG_CHANGE_TYPE_NEW, incenticeChangeLogs[2].Change_Type__c);
        System.assertEquals(ISSPConstants.INCENTIVE_CHANGE_LOG_CHANGE_ElEMENT_CONTACT, incenticeChangeLogs[2].Change_Element__c);
        System.assertEquals(contacts[3].Id, incenticeChangeLogs[3].Contact__c);
        System.assertEquals(ISSPConstants.INCENTIVE_CHANGE_LOG_CHANGE_TYPE_NEW, incenticeChangeLogs[3].Change_Type__c);
        System.assertEquals(ISSPConstants.INCENTIVE_CHANGE_LOG_CHANGE_ElEMENT_CONTACT, incenticeChangeLogs[3].Change_Element__c);
        
        //Set value to update
        contacts[0].Employment_Start__c = System.today().addDays(5);
        contacts[1].Employment_Start__c = System.today().addDays(5);
        contacts[2].Employment_Termination__c = System.today().addDays(5);
        contacts[3].Employment_Termination__c = System.today().addDays(5);
        
        //Update Contact Data
        update contacts;
        
        //Query on Incentive change log
        incenticeChangeLogs = [Select Id From Incentive_Change_Log__c];
        
        //Assert for result
        system.assert(incenticeChangeLogs != null);
        System.assertEquals(8, incenticeChangeLogs.size());
        
        //Update contact employment date value
        contacts[0].Employment_Start__c = System.today().addDays(10);
        update contacts[0];
        
        //Query on insentive change records
        List<Incentive_Change_Log__c> incenticeChangeLogsRecord = [Select Id, Contact__c, Change_Type__c, Change_Element__c,Start_Date__c 
                                                                        From Incentive_Change_Log__c Where ID NOT IN : incenticeChangeLogs];
        
        //Assert for result
        system.assert(incenticeChangeLogsRecord != null);
        System.assertEquals(1, incenticeChangeLogsRecord.size());
        System.assertEquals(contacts[0].Id, incenticeChangeLogsRecord[0].Contact__c);
        System.assertEquals(ISSPConstants.INCENTIVE_CHANGE_LOG_CHANGE_TYPE_MODIFIED, incenticeChangeLogsRecord[0].Change_Type__c);
        System.assertEquals(ISSPConstants.INCENTIVE_CHANGE_LOG_CHANGE_ElEMENT_CONTACT, incenticeChangeLogsRecord[0].Change_Element__c);
        System.assertEquals(contacts[0].Employment_Start__c, incenticeChangeLogsRecord[0].Start_Date__c);
        
        //Update contacgt vaule
        contacts[0].Employment_Termination__c = System.today().addDays(15);
        update contacts[0];
        
        //Query on insentive change records
        List<Incentive_Change_Log__c> incenticeChangeLogsList = [Select Id, Contact__c, Change_Type__c, Change_Element__c,End_Date__c From Incentive_Change_Log__c 
                                                                    Where ID NOT IN : incenticeChangeLogs AND ID NOT IN : incenticeChangeLogsRecord];
        
        //Assert for result
        system.assert(incenticeChangeLogsList != null);
        System.assertEquals(1, incenticeChangeLogsList.size());
        System.assertEquals(contacts[0].Id, incenticeChangeLogsList[0].Contact__c);
        System.assertEquals(ISSPConstants.INCENTIVE_CHANGE_LOG_CHANGE_TYPE_MODIFIED, incenticeChangeLogsList[0].Change_Type__c);
        System.assertEquals(ISSPConstants.INCENTIVE_CHANGE_LOG_CHANGE_ElEMENT_CONTACT, incenticeChangeLogsList[0].Change_Element__c);
        System.assertEquals(contacts[0].Employment_Termination__c, incenticeChangeLogsList[0].End_Date__c);
        
        //Stop Test here
        Test.stopTest();
        
    }
    
    //Added by -  Mahendra Swarnkar - 7/16/2016 - CR-20150202-8641 
    /** Description : Method to test out various use cases associated with Contact trigger to update Syndicated Research Interaction Contact field.
     **/
    static testMethod void testPopulateInstitutionLookUpFieldForNPD() {
        
        //Bypass Dupeblocker
        Util.IsTest(true);
        
        //Bypassing Triggers so then test data can be created easily
        Util.byPassAllTriggers = true;
        
        //Flag for triggers: this is just a test, don't do crazy things.
        Util.isTesting = true;
        
        //Create restricted accounts
        List<Account> accounts = new List<Account>();
        accounts.add(new Account(Name = 'account 1'));
        accounts.add(new Account(Name = 'account 2'));
        accounts.add(new Account(Name = 'account 3'));
        
        //Insert 
        insert accounts;
        
        //Retreiving "External" Record type for Contact object
        RecordType externalRecordType = [SELECT ID, DeveloperName FROM RecordType WHERE SobjectType = 'Contact' 
                                            AND IsActive = true AND DeveloperName = 'External' LIMIT 1];
        system.assert(externalRecordType != null);                                  
        
        // List to store test Contacts
        List<Contact> contacts = new List<Contact>();
        
        //Add contact data in list
        contacts.add(new Contact(accountid = accounts[0].id , Lastname = 'contact 1', recordtypeid = externalRecordType.ID, Contact_Status__c = 'Inactive - Moved Institutions', Employee_User_Record__c = Userinfo.getUserId()));
        contacts.add(new Contact(accountid = accounts[1].id , Lastname = 'contact 2', recordtypeid = externalRecordType.ID, Contact_Status__c = 'Inactive - Moved Institutions', Employee_User_Record__c = Userinfo.getUserId()));
        contacts.add(new Contact(accountid = accounts[2].id , Lastname = 'contact 3', recordtypeid = externalRecordType.ID, Contact_Status__c = 'Inactive - Moved Institutions', Employee_User_Record__c = Userinfo.getUserId()));
        contacts.add(new Contact(accountid = accounts[2].id , Lastname = 'contact 4', recordtypeid = externalRecordType.ID, Contact_Status__c = 'Inactive - Moved Institutions', Employee_User_Record__c = Userinfo.getUserId()));
        
        //Insert Contact Data
        insert contacts;
        
        //Retriveing record type related details
        List<RecordType> sdRIRdTypes = [SELECT Id FROM RecordType WHERE sobjectType = 'Syndicated_Research_Interaction__c'
                                            AND DeveloperName = 'NPD'
                                            AND IsActive = true];
        //Asserting for the results
        System.assert(sdRIRdTypes != null);
        System.assertEquals(1, sdRIRdTypes.size());
        
        //Set to hold the record type names
        Set<String> recordTypeNames = new Set<String>();
        recordTypeNames.add('NPD');
        recordTypeNames.add('Syndicated_Study');
        
        //List to hold recordstype of Syndicated Study
        List<RecordType> recordTypes = new List<RecordType>();
        
        //loop through record types and populating the collection with records
        for(RecordType rType : [Select Id FROM RecordType WHERE sobjectType = 'Syndicated_Study__c'
                                AND DeveloperName IN : recordTypeNames
                                AND IsActive = true]) {
            recordTypes.add(rType);
        }
        
        //Asserting for the results
        System.assert(recordTypes != null);
        System.assertEquals(2, recordTypes.size());
        
        //List to hold the Account records
        List<Syndicated_Study__c> sStudyList = new List<Syndicated_Study__c>();
        
        //Making data for Syndicated Study records
        sStudyList.add(new Syndicated_Study__c(Name = 'Test1', GPA__c = '', RecordTypeId = recordTypes[0].Id, Research_Type__c = 'Test1'));
        sStudyList.add(new Syndicated_Study__c(Name = 'Test2', GPA__c = '', RecordTypeId = recordTypes[0].Id, Research_Type__c = 'Test2'));
        sStudyList.add(new Syndicated_Study__c(Name = 'Test3', Year__c = '2014', RecordTypeId = recordTypes[1].Id, Research_Type__c = 'Test3'));
        
        //Insert Syndicated study records
        insert sStudyList;
        
        //Asserts for results
        System.assert(sStudyList != null);
        System.assertEquals(3, sStudyList.size());
        
        //List to hold the Syndicated Research Interaction records
        List<Syndicated_Research_Interaction__c> sRIList = new List<Syndicated_Research_Interaction__c>();
        
        //Making data for Syndicated Research Interaction records
        sRIList.add(new Syndicated_Research_Interaction__c(Primary_Study__c = sStudyList[0].Id, Name = 'Test1', Product_Concept_Grade__c = 'A', Contact__c = contacts[0].Id, RecordTypeId = sdRIRdTypes[0].Id, Status__c = 'Test1'));
        sRIList.add(new Syndicated_Research_Interaction__c(Primary_Study__c = sStudyList[0].Id, Name = 'Test2', Product_Concept_Grade__c = 'A', Contact__c = contacts[1].Id, RecordTypeId = sdRIRdTypes[0].Id, Status__c = 'Test1'));
        sRIList.add(new Syndicated_Research_Interaction__c(Primary_Study__c = sStudyList[0].Id, Name = 'Test3', Product_Concept_Grade__c = 'B', Contact__c = contacts[2].Id, RecordTypeId = sdRIRdTypes[0].Id, Status__c = 'Test1'));
        sRIList.add(new Syndicated_Research_Interaction__c(Primary_Study__c = sStudyList[0].Id, Name = 'Test1', Product_Concept_Grade__c = 'B', Contact__c = contacts[3].Id, RecordTypeId = sdRIRdTypes[0].Id, Status__c = 'Test1'));
        
        //Insert Syndicated Research Interaction records
        insert sRIList;
        
        //Start Test from here
        Test.startTest();
        
        //By pass trigger
        Util.BypassAllTriggers = false;
        Util.BypassContactRestrictionTrigger = false;
        
        //Set value to update
        contacts[0].accountid = accounts[1].Id;
        
        //Update
        update contacts[0];
        
        //Query on contact
        List<Syndicated_Research_Interaction__c> synResInteractions = [Select Id, Contact__r.AccountId From Syndicated_Research_Interaction__c WHERE Contact__r.AccountId =:accounts[1].Id];
        
        //Assert for result
        System.assertEquals(2, synResInteractions.size());
        
        //Set value to update
        contacts[0].accountid = accounts[1].Id;
        
        //Update
        update contacts[0];
        
        //Query on Syndicated_Research_Interaction__c
        synResInteractions = [Select Id, Contact__r.AccountId From Syndicated_Research_Interaction__c WHERE Contact__r.AccountId =:accounts[1].Id];
        
        //Assert for result
        System.assertEquals(2, synResInteractions.size());
        
        //Set value to update
        contacts[0].Lastname = 'contact test 1';
        
        //Stop Test from here
        Test.stopTest();
        
        //Update
        update contacts[0];
        
        //Query on Syndicated_Research_Interaction__c
        synResInteractions = [Select Id, Contact__r.AccountId From Syndicated_Research_Interaction__c WHERE Contact__r.AccountId =:accounts[1].Id];
        
        //Assert for result
        System.assertEquals(2, synResInteractions.size());
    }
    
    //Added by -  Mahendra Swarnkar - 7/16/2016 - CR-20150202-8641 
    /** Description : Method to test out various use cases associated with Contact trigger to update "Contact Restriction Status" filed on Account change.
     **/
    static testMethod void testUpdateRestrictionStatus(){
        
        //Bypass Dupeblocker
        Util.IsTest(true);
        
        //Bypassing Triggers so then test data can be created easily
        Util.byPassAllTriggers = true;
        
        //Flag for triggers: this is just a test, don't do crazy things.
        Util.isTesting = true;
        
        //Create restricted accounts
        List<Account> accounts = new List<Account>();
        
        //Added record in list
        accounts.add(new Account(Name = 'account 1'));
        accounts.add(new Account(Name = 'account 2'));
        accounts.add(new Account(Name = 'account 3'));
        
        //Insert 
        insert accounts;
        
        //Retreiving "External" Record type for Contact object
        RecordType externalRecordType = [SELECT ID, DeveloperName FROM RecordType WHERE SobjectType = 'Contact' 
                                            AND IsActive = true AND DeveloperName = 'External' LIMIT 1];
                                            
        //Asserts for results
        System.assert(externalRecordType != null);
        
        // List to store test Contacts
        List<Contact> contacts = new List<Contact>();
        
        //Add contact data in list
        contacts.add(new Contact(accountid = accounts[0].id , Lastname = 'contact 1', recordtypeid = externalRecordType.ID, Contact_Status__c = 'Inactive - Moved Institutions', Employee_User_Record__c = Userinfo.getUserId()));
        contacts.add(new Contact(accountid = accounts[1].id , Lastname = 'contact 2', recordtypeid = externalRecordType.ID, Contact_Status__c = 'Inactive - Moved Institutions', Employee_User_Record__c = Userinfo.getUserId()));
        contacts.add(new Contact(accountid = accounts[2].id , Lastname = 'contact 3', recordtypeid = externalRecordType.ID, Contact_Status__c = 'Inactive - Moved Institutions', Employee_User_Record__c = Userinfo.getUserId()));
        
        //Insert Contact Data
        insert contacts;
        
        //Retreiving "Account Restriction" Record type for Restrictions MtM object
        RecordType accRestrictionRecordType = [SELECT ID, DeveloperName FROM RecordType WHERE SobjectType = 'Restricted_MtM__c' 
                                                    AND IsActive = true AND DeveloperName = 'Account_Restriction' LIMIT 1];
        
        //Retreiving "Contact Restriction" Record type for Restrictions MtM object
        RecordType conRestrictionRecordType = [SELECT ID, DeveloperName FROM RecordType WHERE SobjectType = 'Restricted_MtM__c' 
                                                        AND IsActive = true AND DeveloperName = 'Contact_Restriction' LIMIT 1];
                                                        
        //Asserts for results
        System.assert(accRestrictionRecordType != null);
        System.assert(conRestrictionRecordType != null);           
        
        //Create record for Restrictions
        Restrictions__c rest1 = new Restrictions__c();
        rest1.Category__c = 'Restricted: Permission Required';
        rest1.Expiration_Date__c = system.today().addDays(10);
        insert rest1;         
        
        //Create record for Restrictions
        Restrictions__c rest2 = new Restrictions__c();
        rest2.Category__c = 'Critical Background Information';
        rest2.Expiration_Date__c = system.today().addDays(10);
        insert rest2;
        
        //Create record for Restricted MtM
        List<Restricted_MtM__c> restrictedMTM = new List<Restricted_MtM__c>();
        
        //Added record in list
        restrictedMTM.add(new Restricted_MtM__c(Restriction__c = rest2.Id, RecordTypeId = accRestrictionRecordType.ID, Account__c = accounts[0].Id, Restriction_Expired__c = false, Contact__c = contacts[0].Id));
        restrictedMTM.add(new Restricted_MtM__c(Restriction__c = rest1.Id, RecordTypeId = accRestrictionRecordType.ID, Account__c = accounts[0].Id, Restriction_Expired__c = false, Contact__c = contacts[1].Id));
        restrictedMTM.add(new Restricted_MtM__c(Restriction__c = rest1.Id, RecordTypeId = accRestrictionRecordType.ID, Account__c = accounts[1].Id, Restriction_Expired__c = false, Contact__c = contacts[2].Id));
        
        //Insert records
        insert restrictedMTM;
        
        //Start Test from here
        Test.startTest();
        
        //By pass trigger
        Util.BypassAllTriggers = false;
        Util.BypassContactRestrictionTrigger = false;
        
        //Set value to update
        contacts[0].accountid = accounts[1].Id;
        contacts[1].accountid = accounts[2].Id;
        
        //Update
        update contacts;
        
        //Query on Contact
        List<Contact> contactList = [Select Id from Contact WHERE Contact_Restriction_Status__c =: 'Critical Background Information'];
        
        //Assert for result
        System.assert(contactList != null);
        System.assertEquals(1, contactList.size());
        
        //Query on Contact
        contactList = [Select Id from Contact WHERE Contact_Restriction_Status__c =: 'Restricted: Permission Required'];
        
        //Assert for result
        System.assert(contactList != null);
        System.assertEquals(1, contactList.size());
        
        //Stop Test from here
        Test.stopTest();
    }
    
        //Modified - 06/30/2016 - By Mahendra Swarnkar - CR-20160219-9621    
    //Added By - Mahendra Swarnkar - CR-20151209-9452 - 06/01/2016
    //Test methods to test the populateMASignOffDateOnUser
    static testMethod void testpopulateMASignOffDateOnUser() {
        
        //Bypass all triggers
        Util.BypassAllTriggers = true;
        Util.IsTest(true);
        
        //Get Admin profile
        List<Profile> testProfile = [Select Id, Name from Profile where Name = 'System Administrator'];
        
        //Assert for results
        System.assert(testProfile != null);
        System.assert(testProfile.size()>0);
        
        //Insert the Test Users
        List<User> userList = new List<User>();
        
        userList.add(new User(Username= Math.random()+'@abc.com', LastName='Test User1', FirstName='Test1', Email='testuser1@test.com',
                            Alias='Test1', EmailEncodingKey='UTF-8', languagelocalekey='en_US', ProfileId=testProfile[0].Id, 
                            timezonesidkey='America/Los_Angeles', localesidkey='en_US', EmployeeNumber = '12121212', IsActive = true));
        userList.add(new User(Username= Math.random()+'@abc.com', LastName='Test User2', FirstName='Test2', Email='testuser2@test.com',
                            Alias='Test2', EmailEncodingKey='UTF-8', languagelocalekey='en_US', ProfileId=testProfile[0].Id, 
                            timezonesidkey='America/Los_Angeles', localesidkey='en_US', EmployeeNumber = '12121212', IsActive = true ,
                            Marketing_Associate_Sign_Off_Date__c = System.today()));
        
        userList.add(new User(Username= Math.random()+'@abc.com', LastName='Test User2', FirstName='Test2', Email='testuser2@test.com',
                            Alias='Test2', EmailEncodingKey='UTF-8', languagelocalekey='en_US', ProfileId=testProfile[0].Id, 
                            timezonesidkey='America/Los_Angeles', localesidkey='en_US', EmployeeNumber = '12121212', IsActive = true ,
                            Marketing_Associate_Sign_Off_Date__c = System.today()));
                
        //Insert users
        insert userList;
        
        //Assert for results
        System.assert(userList.size()>0);
        
        //List to hold Contact Records
        List<Contact> contacts = new List<Contact>();
        contacts.add(new Contact(RecordTypeId = util.RecordTypeId('Contact', 'Employee'), LastName = 'Test Contact', Employee_User_Record__c = userList[0].id, Marketing_Associate_Sign_Off_Date__c = system.today().addDays(-10)));
        contacts.add(new Contact(RecordTypeId = util.RecordTypeId('Contact', 'Employee'), LastName = 'Test Contact Test', Employee_User_Record__c = userList[1].id, Marketing_Associate_Sign_Off_Date__c = system.today().addDays(-1)));
        contacts.add(new Contact(RecordTypeId = util.RecordTypeId('Contact', 'External'), LastName = 'Test Contact Testing', Employee_User_Record__c = userList[2].id, Marketing_Associate_Sign_Off_Date__c = system.today().addDays(-2)));
        
        //Test starts from here
        Test.startTest();
        
        //Enable all triggers
        Util.BypassAllTriggers = false;
        
        //Insert the contacts
        insert contacts;
        
        //Fetch User records
        Map<Id,User> userMap = new Map<Id,User>([SELECT Id, Marketing_Associate_Sign_Off_Date__c 
                                                 FROM User WHERE Id IN : userList]);
        
        //Asserts on result
        System.assertEquals(system.today().addDays(-10), userMap.get(contacts[0].Employee_User_Record__c).Marketing_Associate_Sign_Off_Date__c);
        System.assertEquals(system.today().addDays(-1), userMap.get(contacts[1].Employee_User_Record__c).Marketing_Associate_Sign_Off_Date__c);
        System.assertEquals(system.today(), userMap.get(contacts[2].Employee_User_Record__c).Marketing_Associate_Sign_Off_Date__c);
        
        //Update Contact records
        contacts[0].Marketing_Associate_Sign_Off_Date__c = null;
        contacts[1].Marketing_Associate_Sign_Off_Date__c = system.today().addDays(10);
        update contacts;
        
        //Fetch User records
        userMap = new Map<Id,User>([SELECT Id, Marketing_Associate_Sign_Off_Date__c FROM User WHERE Id IN : userList]);
        
        //Asserts on result
        System.assertEquals(null, userMap.get(contacts[0].Employee_User_Record__c).Marketing_Associate_Sign_Off_Date__c);
        System.assertEquals(system.today().addDays(10), userMap.get(contacts[1].Employee_User_Record__c).Marketing_Associate_Sign_Off_Date__c);
        
        //Disable triggers
        Util.BypassAllTriggers = true;
        
        //Changing user context
        System.runAs(userList[0]) {
            
            //Setting field value as null
            for(Contact c : contacts)
            	c.Employee_User_Record__c = null;
            
            //Enable all triggers
        	Util.BypassAllTriggers = false;
            
            //Update contacts
            update contacts;
            
            //Disable triggers
        	Util.BypassAllTriggers = true;
        }
        
        //Test Stop here
        Test.stopTest();   
    }
}