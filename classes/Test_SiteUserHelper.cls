/**
Desription      :   Test Class for SiteUserHelper

Created By      :   Victor Hanson

Created Date    :   07/29/2014

Revision Logs   :   v1.0 - Created
                    v1.1 - Modified by - Abhinav Sharma - 03/10/2015 - CR-20141222-8389 - Methods (projectRole_PT_AutoSubscribe_CreateSiteProfile, projectRole_PT_AutoSubscribe_CreateSubscription)
					V1.2 - Modified By - Rajeev Jain - 09/01/2016 - Fixed too many soql error found while production validation in (projectRole_NON_PT_AutoSubscribe, membershipKeyContact_AutoSubscribe_CreateSiteProfile) methods
					V1.3 - Modified By - Abhinav Sharma - 09/10/2016 - In order to fix "Too Many SOQL 101 error in it"
**/ 
@isTest
public class Test_SiteUserHelper {
    
    /**
     *  @description: returns a Web Program Access record.
     * 
     **/
    public static Web_Program_Access__c CreateWebProgramAccess(boolean CreateAndInsert) {
        Web_Program_Access__c webProgramAccess = new Web_Program_Access__c();
        webProgramAccess.A_com_Program_ID__c = 123;
        webProgramAccess.Description__c = 'test prog access';
        webProgramAccess.Program_Code_to_Member__c = '99';
        
        if (CreateAndInsert) insert webProgramAccess;
            
        return webProgramAccess;
    }
    
    /**
     *  @description: returns a web program access MtM record.
     * 
     **/
    public static Web_Program_Access_MTM__c CreateWebProgramAccessMtM(Id webProgramId, boolean CreateAndInsert) {
        
        if (webProgramId == null) {
            Web_Program_Access__c wpAccess = CreateWebProgramAccess(true);
            webProgramId = wpAccess.Id;
        }
        
        // create a new program
        Program__c prog = TestUtilities.CreateNewProgram(true);
        
        Web_Program_Access_MTM__c wpAccessMtM = new Web_Program_Access_MTM__c();
        wpAccessMtM.Web_Program__c = webProgramId;
        wpAccessMtM.Membership_Program__c = prog.Id;
        
        if (CreateAndInsert) insert wpAccessMtM;
        
        return wpAccessMtM;
    }
    
    /**
     *  @description: returns a Temporary Program Access record.
     * 
     **/
    public static Temporary_Program_Access__c CreateTempProgAccess(Id wpAccessMtMId, Site_Profile__c sProfile, boolean CreateAndInsert) {
        Temporary_Program_Access__c tempAccess = new Temporary_Program_Access__c();
        
        if (wpAccessMtMId == null) {
            Web_Program_Access_MTM__c wpAccessMtM = CreateWebProgramAccessMtM(null, true);
            wpAccessMtMId = wpAccessMtM.Id;
        }
        
        tempAccess.Site_Profile__c = sProfile.Id;
        tempAccess.Contact__c = sProfile.Contact__c;
        tempAccess.Web_Program__c = wpAccessMtMId;
        tempAccess.Start_Date__c = system.today().addDays(-10);
        tempAccess.End_Date__c = system.today().addDays(5);
        
        if (CreateAndInsert) insert tempAccess;
        
        return tempAccess;
    }
    
    /**
     * @description: Return an account with ADV/EAB organization Id & status
     **/
    public static Account createNewAccount(boolean createAndInsert) {
        Account acct = TestUtilities.CreateNewAccount(false);
        acct.EAB_com_Organization_Status__c = 'Active';
        
        if (createAndInsert == true)  {
            insert acct;
        }
        
        return acct;
    }
    
    /**
     * @description: Return an site profile of a given type
     **/
    public static Site_Profile__c createSiteProfile(string siteType, boolean CreateAndInsert) {
        // setup an account and contact
        Account acct = createNewAccount(true);
        Site_Profile__c site_Profile = createSiteProfile(acct, siteType, CreateAndInsert);
        
        return site_Profile;
    }
    
    /**
     * @description: Return an site profile related to a contact related to the Account provided.
     **/
    public static Site_Profile__c createSiteProfile(Account acct, string siteType, boolean CreateAndInsert) {
        
        //the type of user being created
        if (siteType == null) siteType = SiteUserHelper.SITE_ADVISORY;
        
        // create the eligible domain
        Eligible_Domain__c domain = new Eligible_Domain__c(Is_Included__c = true, Qualified_Domain__c = SiteUserHelper.SITE_ADVISORY, Account__c = acct.Id);
        insert domain;
        
        //create & insert site user
        Site_User__c site_User = new Site_User__c();
        insert site_User;
        
        //create & insert account & contact
        Contact con = TestUtilities.CreateNewContact(acct, false);
        con.site_User__c = site_User.Id;
        con.Contact_Status__c = 'Active';
        
        con.Email = 'test-' + String.valueOf(Crypto.getRandomInteger()) + '@advisory.com';
        con.Primary_Country__c = 'USA';
        insert con;
        
        //create site profile
        Site_Profile__c site_Profile = new Site_Profile__c(Status__c = 'Active',
                                                           Username__c = con.Email,
                                                           Password__c = 'test',
                                                           Site_User__c = site_User.Id,
                                                           Verify__c = '2',
                                                           Contact__c = con.Id,
                                                           Type__c = siteType);
        
        if (CreateAndInsert) insert site_Profile;
        
        return site_Profile;
    }
    
    //creates 4 subscription options and 4 eligible subscription options for the program.  The EMAIL_WATCH eligible sub options has key contact auto subscribe = true
    private static void setupSubscriptionOptions(Id programId) {
        // new subscription option
        List<Subscription_Option__c> subscriptionList = new List<Subscription_Option__c>();
        Subscription_Option__c subOption_EMAIL_WATCH = new Subscription_Option__c();
        subOption_EMAIL_WATCH.Subscription_Status__c = 'Active';
        subOption_EMAIL_WATCH.Subscription_Category__c = 'EMAIL_WATCH';
        subscriptionList.add(subOption_EMAIL_WATCH);
        
        Subscription_Option__c subOption_EMAIL_DAILY = new Subscription_Option__c();
        subOption_EMAIL_DAILY.Subscription_Status__c = 'Active';
        subOption_EMAIL_DAILY.Subscription_Category__c = 'EMAIL_DAILY';
        subscriptionList.add(subOption_EMAIL_DAILY);
        
        Subscription_Option__c subOption_EMAIL_BLOG = new Subscription_Option__c();
        subOption_EMAIL_BLOG.Subscription_Status__c = 'Active';
        subOption_EMAIL_BLOG.Subscription_Category__c = 'EMAIL_BLOG';
        subscriptionList.add(subOption_EMAIL_BLOG);
        
        Subscription_Option__c subOption_EMAIL_TOPICS = new Subscription_Option__c();
        subOption_EMAIL_TOPICS.Subscription_Status__c = 'Active';
        subOption_EMAIL_TOPICS.Subscription_Category__c = 'EMAIL_TOPICS';
        subscriptionList.add(subOption_EMAIL_TOPICS);
        
        insert subscriptionList;
        // new eligible subscription option
        List<Eligible_Subscription_Option__c> eligibleSubList = new List<Eligible_Subscription_Option__c>();
        Eligible_Subscription_Option__c eligibleSub_EMAIL_WATCH = new Eligible_Subscription_Option__c();
        eligibleSub_EMAIL_WATCH.Program__c = programId;
        eligibleSub_EMAIL_WATCH.Related_Subscription__c = subOption_EMAIL_WATCH.Id;
        eligibleSub_EMAIL_WATCH.Key_Contact_Auto_Subscribe__c = true;
        eligibleSubList.add(eligibleSub_EMAIL_WATCH);
        
        Eligible_Subscription_Option__c eligibleSub_EMAIL_DAILY = new Eligible_Subscription_Option__c();
        eligibleSub_EMAIL_DAILY.Program__c = programId;
        eligibleSub_EMAIL_DAILY.Related_Subscription__c = subOption_EMAIL_DAILY.Id;
        eligibleSubList.add(eligibleSub_EMAIL_DAILY);
        
        Eligible_Subscription_Option__c eligibleSub_EMAIL_BLOG = new Eligible_Subscription_Option__c();
        eligibleSub_EMAIL_BLOG.Program__c = programId;
        eligibleSub_EMAIL_BLOG.Related_Subscription__c = subOption_EMAIL_BLOG.Id;
        eligibleSubList.add(eligibleSub_EMAIL_BLOG);
        
        Eligible_Subscription_Option__c eligibleSub_EMAIL_TOPICS = new Eligible_Subscription_Option__c();
        eligibleSub_EMAIL_TOPICS.Program__c = programId;
        eligibleSub_EMAIL_TOPICS.Related_Subscription__c = subOption_EMAIL_TOPICS.Id;
        eligibleSubList.add(eligibleSub_EMAIL_TOPICS);
        
        insert eligibleSubList;
    }
    
    //register both an eab and advisory site profile for the same contact
    static testmethod void test_Action_Register_GoodDomain_EAB_Advisory() {
        
        //Bypass Dupeblocker
        Util.IsTest(true);
        
        //Bypassing Triggers so then test data can be created easily
        Util.byPassAllTriggers = true;
        
        //Flag for triggers: this is just a test, don't do crazy things.
        Util.isTesting = true;
        
        // setup an account and contact
        Account acct = createNewAccount(true);
        
        //Eligible Domain
        Eligible_Domain__c domain = new Eligible_Domain__c(Is_Included__c = true, 
                                                           Qualified_Domain__c = SiteUserHelper.SITE_ADVISORY, 
                                                           Account__c = acct.Id);
        insert domain;
        
        // set the page reference
        PageReference pageRef = Page.Site_JSON;
        Test.setCurrentPage(pageRef);
        
        // get historical_Linker
        acct = [SELECT Id, Historical_Linker__c, Advisory_com_Organization_id__c FROM Account WHERE Id = :acct.Id];
        
        // generate the request
        SiteUser sUser_EAB = new SiteUser();
        sUser_EAB.Site = SiteUserHelper.SITE_EAB;
        sUser_EAB.Email_Address = 'hansonv@advisory.com';
        sUser_EAB.Email_Address2 = 'hansonv@zzzzz.com';
        sUser_EAB.Organization_Id = integer.valueOf(acct.Advisory_com_Organization_id__c);
        sUser_EAB.Password = 'test';
        sUser_EAB.ClientId = acct.Historical_Linker__c;
        sUser_EAB.Prefix = 'Mr';
        sUser_EAB.Country = 'USA';
        sUser_EAB.First_Name = 'Victor';
        sUser_EAB.Last_Name = 'Hanson';
        sUser_EAB.Middle_Initial = 'R';
        sUser_EAB.Suffix = '';
        sUser_EAB.Job_Function = 'Developer';
        sUser_EAB.Title = 'SF Dev';
        sUser_EAB.Department = 'eTech';
        sUser_EAB.Command = 'register';
        sUser_EAB.Office_Phone = '555-555-5655';
        
        // generate the request
        SiteUser sUser_Advisory = new SiteUser();
        sUser_Advisory.Site = SiteUserHelper.SITE_ADVISORY;
        sUser_Advisory.Email_Address = 'hansonv@advisory.com';
        sUser_Advisory.Email_Address2 = 'hansonv@zzzzz.com';
        sUser_Advisory.Organization_Id = integer.valueOf(acct.Advisory_com_Organization_id__c);
        sUser_Advisory.Password = 'test';
        sUser_Advisory.ClientId = acct.Historical_Linker__c;
        sUser_Advisory.Prefix = 'Mr';
        sUser_Advisory.Country = 'USA';
        sUser_Advisory.First_Name = 'Victor';
        sUser_Advisory.Last_Name = 'Hanson';
        sUser_Advisory.Middle_Initial = 'R';
        sUser_Advisory.Suffix = '';
        sUser_Advisory.Job_Function = 'Developer';
        sUser_Advisory.Title = 'SF Dev';
        sUser_Advisory.Department = 'eTech';
        sUser_Advisory.Command = 'register';
        sUser_Advisory.Office_Phone = '555-555-5655';
        
        string origData = JSON.serialize(sUser_EAB);
        blob encryptedBlob = Crypto.encryptWithManagedIV('AES256', SiteControllerHelper.KEY, blob.valueOf(origData));
        String encryptedString = EncodingUtil.base64Encode(encryptedBlob);
        
        // Add parameters to page URL 
        ApexPages.currentPage().getParameters().put('req', encryptedString);
        
        //Start from here
        test.startTest();
        
        // controller
        SiteController controller = new SiteController();
        controller.initialize();
        
        // get the response
        system.debug('@@controller.JSONResponseDecrypted:' + EncryptionHelper.decrypt(EncodingUtil.base64Decode(controller.JSONResponse)));
        String decryptedJSONResponse = EncryptionHelper.decrypt(EncodingUtil.base64Decode(controller.JSONResponse));
        sUser_EAB = EncryptionHelper.deserializeSiteUser(decryptedJSONResponse);
        
        //Advisory
        origData = JSON.serialize(sUser_Advisory);
        encryptedBlob = Crypto.encryptWithManagedIV('AES256', SiteControllerHelper.KEY, blob.valueOf(origData));
        encryptedString = EncodingUtil.base64Encode(encryptedBlob);
        
        // Add parameters to page URL 
        ApexPages.currentPage().getParameters().put('req', encryptedString);
        
        // controller
        SiteController controller2 = new SiteController();
        controller2.initialize();
        
        // get the response
        system.debug('@@controller.JSONResponseDecrypted:' + EncryptionHelper.decrypt(EncodingUtil.base64Decode(controller2.JSONResponse)));
        decryptedJSONResponse = EncryptionHelper.decrypt(EncodingUtil.base64Decode(controller2.JSONResponse));
        sUser_Advisory = EncryptionHelper.deserializeSiteUser(decryptedJSONResponse);
        
        //Stop test here
        test.stopTest();
        
        //Assert for the results
        system.assertEquals('success', sUser_EAB.Response.toLowerCase());
        system.assertEquals('success', sUser_Advisory.Response.toLowerCase());
        system.assertEquals(true, decryptedJSONResponse.contains('5655'));
        
        // get make sure the contact didn't get inserted with a bad domain
        Contact updatedContact = [SELECT Name, Id, Email, Advisory_com_Preferred_Email_Address__c, Site_User__c, Member_Verified_Date__c,
                                  (SELECT Id, Password__c, Password_Reset_Token__c, Bypass_Domain_Validation__c, Last_Access__c, 
                                   Send_Password_Notification__c, Site_User__c, Verify__c, Verify_Date__c, Status__c, Status_Code__c, 
                                   Type__c, User_Id__c, Username__c FROM Site_Profiles__r) 
                                  FROM Contact WHERE Email = 'hansonv@advisory.com'];
        
        system.assertEquals(updatedContact.Id, sUser_EAB.UniqueId);
        
        // verify the contact was created properly
        system.assertEquals('hansonv@zzzzz.com', updatedContact.Advisory_com_Preferred_Email_Address__c);
        system.assertEquals(date.today(), updatedContact.Member_Verified_Date__c);
        
        system.assertequals(2, updatedContact.Site_Profiles__r.size(),
                           'There should be 2 Site Profile related to this contact - one for Advisory.com and one for EAB.com.');
        system.assertequals('In Progress', updatedContact.Site_Profiles__r[0].Status__c,
                           'The Site Profile status should be In Progress when registering a new Contact that has not set a PW yet.');
        system.assertEquals(updatedContact.Site_User__c, updatedContact.Site_Profiles__r[0].Site_User__c,
                           'The Contact and Site Profile should be related to the same Site User record.');
        system.assertNotEquals(null, updatedContact.Site_Profiles__r[0].Password_Reset_Token__c,
                           'The Password Reset Token field should not be null - this value is used in the verification email sent to the user.');
        
        // decrypt the verification token
        // remove the url encoding
        String encryptedPayload = updatedContact.Site_Profiles__r[0].Password_Reset_Token__c;
        encryptedPayload = encryptedPayload.split('payload')[1];
        encryptedPayload = encryptedPayload.substring(1, encryptedPayload.length());
        encryptedPayload = EncodingUtil.urlDecode(encryptedPayload , 'UTF-8');
        blob encryptedBlob2 = EncodingUtil.base64Decode(encryptedPayload);
        // decrypt the reset URL
        string DecryptedPayload = EncryptionHelper.decrypt(encryptedBlob2);
        
        system.assertEquals(false, DecryptedPayload.contains('UniqueId=null'));
        system.assertEquals(true, DecryptedPayload.contains('UniqueId=' + updatedContact.Site_Profiles__r[0].User_Id__c));
        
        //verify there is one web service log that has the response of Success
        list<Web_Service_Log__c> wsLogs = [SELECT Id, Web_Service_Method__c, Response_Message__c FROM Web_Service_Log__c WHERE Site_Profile__c = :updatedContact.Site_Profiles__r[0].Id];
        system.assertEquals(1, wsLogs.size(),
                            'Should have returned one webservice log.');
        system.assertEquals('register', wsLogs[0].Web_Service_Method__c.toLowerCase());
        system.assertEquals(SiteUserHelper.RESPONSE_SUCCESS, wsLogs[0].Response_Message__c);
    }
    
    //test registering a new EAB.com user with a bad domain
    static testmethod void test_EAB_Action_Register_BadDomain() {
        
        //Bypass Dupeblocker
        Util.IsTest(true);
        
        //Bypassing Triggers so then test data can be created easily
        Util.byPassAllTriggers = true;
        
        //Flag for triggers: this is just a test, don't do crazy things.
        Util.isTesting = true;
        
        // setup an account and contact
        Account acct = createNewAccount(true);
        
        // set the page reference
        PageReference pageRef = Page.Site_JSON;
        Test.setCurrentPage(pageRef);
        
        // get historical_Linker
        acct = [SELECT Id, Historical_Linker__c, Advisory_com_Organization_id__c 
                	FROM Account WHERE Id = :acct.Id];
        
        // generate the request
        SiteUser sUser = new SiteUser();
        sUser.Email_Address = 'hansonv@zzzzz.com';
        sUser.Email_Address2 = 'victor.r.hanson@gmail.com';
        sUser.Organization_Id = integer.valueOf(acct.Advisory_com_Organization_id__c);
        sUser.Password = 'test';
        sUser.ClientId = acct.Historical_Linker__c;
        sUser.Prefix = 'Mr';
        sUser.Country = 'USA';
        sUser.First_Name = 'Victor';
        sUser.Last_Name = 'Hanson';
        sUser.Middle_Initial = 'R';
        sUser.Suffix = '';
        sUser.Job_Function = 'Developer';
        sUser.Title = 'SF Dev';
        sUser.Department = 'eTech';
        sUser.Command = 'register';
        sUser.Site = SiteUserHelper.SITE_EAB;
        
        string origData = JSON.serialize(sUser);
        blob encryptedBlob = Crypto.encryptWithManagedIV('AES256', SiteControllerHelper.KEY, blob.valueOf(origData));
        String encryptedString = EncodingUtil.base64Encode(encryptedBlob);
        
        // Add parameters to page URL 
        ApexPages.currentPage().getParameters().put('req', encryptedString);
        
        // controller
        SiteController controller = new SiteController();
        controller.initialize();
        
        // get the response
        system.debug('@@controller.JSONResponseDecrypted:' + EncryptionHelper.decrypt(EncodingUtil.base64Decode(controller.JSONResponse)));
        String decryptedJSONResponse = EncryptionHelper.decrypt(EncodingUtil.base64Decode(controller.JSONResponse));
        sUser = EncryptionHelper.deserializeSiteUser(decryptedJSONResponse);
        
        //Assert for the results
        system.assertEquals(SiteUserHelper.ERROR_INVALID_DOMAIN, sUser.Response);
        
        // get make sure the contact didn't get inserted with a bad domain
        List<Contact> cons = [SELECT Name, Id, Advisory_com_Email_Address__c, 
                              Advisory_com_Email_Address2__c FROM Contact WHERE Email = 'hansonv@advisory.com'];
        
        //Assert for the results
        system.assertEquals(0, cons.size());
        
    }
    
    static testmethod void test_EAB_Action_Register_GoodDomain() {
        
        //Bypass Dupeblocker
        Util.IsTest(true);
        
        //Bypassing Triggers so then test data can be created easily
        Util.byPassAllTriggers = true;
        
        //Flag for triggers: this is just a test, don't do crazy things.
        Util.isTesting = true;
        
        // setup an account and contact
        Account acct = createNewAccount(true);
        
        //Eligible domain
        Eligible_Domain__c domain = new Eligible_Domain__c(Is_Included__c = true, 
                                                           Qualified_Domain__c = SiteUserHelper.SITE_ADVISORY, Account__c = acct.Id);
        insert domain;
        
        // set the page reference
        PageReference pageRef = Page.Site_JSON;
        Test.setCurrentPage(pageRef);
        
        // get historical_Linker
        acct = [SELECT Id, Historical_Linker__c, Advisory_com_Organization_id__c 
                		FROM Account WHERE Id = :acct.Id];
        
        // generate the request
        SiteUser sUser = new SiteUser();
        sUser.Site = SiteUserHelper.SITE_EAB;
        sUser.Email_Address = 'hansonv@advisory.com';
        sUser.Email_Address2 = 'hansonv@zzzzz.com';
        sUser.Organization_Id = integer.valueOf(acct.Advisory_com_Organization_id__c);
        sUser.Password = 'test';
        sUser.ClientId = acct.Historical_Linker__c;
        sUser.Prefix = 'Mr';
        sUser.Country = 'USA';
        sUser.First_Name = 'Victor';
        sUser.Last_Name = 'Hanson';
        sUser.Middle_Initial = 'R';
        sUser.Suffix = '';
        sUser.Job_Function = 'Developer';
        sUser.Title = 'SF Dev';
        sUser.Department = 'eTech';
        sUser.Command = 'register';
        sUser.Office_Phone = '555-555-5655';
        
        string origData = JSON.serialize(sUser);
        blob encryptedBlob = Crypto.encryptWithManagedIV('AES256', SiteControllerHelper.KEY, blob.valueOf(origData));
        String encryptedString = EncodingUtil.base64Encode(encryptedBlob);
        
        // Add parameters to page URL 
        ApexPages.currentPage().getParameters().put('req', encryptedString);
        
        //Start test from here
        test.startTest();
        
        // controller
        SiteController controller = new SiteController();
        controller.initialize();
        
        //Stop test here
        test.stopTest();
        
        // get the response
        system.debug('@@controller.JSONResponseDecrypted:' + EncryptionHelper.decrypt(EncodingUtil.base64Decode(controller.JSONResponse)));
        String decryptedJSONResponse = EncryptionHelper.decrypt(EncodingUtil.base64Decode(controller.JSONResponse));
        
        sUser = EncryptionHelper.deserializeSiteUser(decryptedJSONResponse);
        
        //Asserting for the results
        system.assertEquals('success', sUser.Response.toLowerCase());
        system.assertEquals(true, decryptedJSONResponse.contains('5655'));
        
        // get make sure the contact didn't get inserted with a bad domain
        Contact updatedContact = [SELECT Name, Id, Email, Advisory_com_Preferred_Email_Address__c, Site_User__c,
                                  (SELECT Id, Password__c, Password_Reset_Token__c, Bypass_Domain_Validation__c, Last_Access__c, 
                                   Send_Password_Notification__c, Site_User__c, Verify__c, Verify_Date__c, Status__c, Status_Code__c, 
                                   Type__c, User_Id__c, Username__c FROM Site_Profiles__r) 
                                  FROM Contact WHERE Email = 'hansonv@advisory.com'];
        
        //Asserting for the results
        system.assertEquals(updatedContact.Id, sUser.UniqueId);
        
        // verify the contact was created properly
        system.assertEquals('hansonv@zzzzz.com', updatedContact.Advisory_com_Preferred_Email_Address__c);
        
        system.assertequals(1, updatedContact.Site_Profiles__r.size(),
                           'There should be one Site Profile related to this contact.');
        system.assertequals('In Progress', updatedContact.Site_Profiles__r[0].Status__c,
                           'The Site Profile status should be In Progress when registering a new Contact that has not set a PW yet.');
        system.assertEquals(updatedContact.Site_User__c, updatedContact.Site_Profiles__r[0].Site_User__c,
                           'The Contact and Site Profile should be related to the same Site User record.');
        system.assertNotEquals(null, updatedContact.Site_Profiles__r[0].Password_Reset_Token__c,
                           'The Password Reset Token field should not be null - this value is used in the verification email sent to the user.');
        
        // decrypt the verification token
        // remove the url encoding
        String encryptedPayload = updatedContact.Site_Profiles__r[0].Password_Reset_Token__c;
        encryptedPayload = encryptedPayload.split('payload')[1];
        encryptedPayload = encryptedPayload.substring(1, encryptedPayload.length());
        encryptedPayload = EncodingUtil.urlDecode(encryptedPayload , 'UTF-8');
        blob encryptedBlob2 = EncodingUtil.base64Decode(encryptedPayload);
        
        // decrypt the reset URL
        string DecryptedPayload = EncryptionHelper.decrypt(encryptedBlob2);
        
        //Asserting for the results
        system.assertEquals(false, DecryptedPayload.contains('UniqueId=null'));
        system.assertEquals(true, DecryptedPayload.contains('UniqueId=' + updatedContact.Site_Profiles__r[0].User_Id__c));
        
        //verify there is one web service log that has the response of Success
        list<Web_Service_Log__c> wsLogs = [SELECT Id, Web_Service_Method__c, Response_Message__c FROM Web_Service_Log__c WHERE Site_Profile__c = :updatedContact.Site_Profiles__r[0].Id];
        system.assertEquals(1, wsLogs.size(),
                            'Should have returned one webservice log.');
        system.assertEquals('register', wsLogs[0].Web_Service_Method__c.toLowerCase());
        system.assertEquals(SiteUserHelper.RESPONSE_SUCCESS, wsLogs[0].Response_Message__c);
    }
    
    /**
     * @description:    1) Create an Account, Contact, and Eligible Domain
     *                  2) Register a new EAB user with the same email as the contact from step #1
     *                  3) This should generate a new Site Profile and Site User associated with the Contact from step #1
     *                  4) Verify the Contact.Site_User__c field is also related to the same Site User as the Site Profile.
     * 
     **/
    static testmethod void test_EAB_Action_RegisterGoodDomain_ExistingContact() {
        
        //Bypass Dupeblocker
        Util.IsTest(true);
        
        //Bypassing Triggers so then test data can be created easily
        Util.byPassAllTriggers = true;
        
        //Flag for triggers: this is just a test, don't do crazy things.
        Util.isTesting = true;
        
        // setup an account and contact
        Account acct = TestUtilities.createNewAccount(true);
        Eligible_Domain__c domain = new Eligible_Domain__c(Is_Included__c = true, Qualified_Domain__c = SiteUserHelper.SITE_EAB, Account__c = acct.Id);
        insert domain;
        
        //creat a contact
        Contact c = TestUtilities.CreateNewContact(acct, false);
        c.Email = 'TestRegisterContact@EAB.com';
        insert c;
        
        // set the page reference
        PageReference pageRef = Page.Site_JSON;
        Test.setCurrentPage(pageRef);
        
        // get historical_Linker
        acct = [SELECT Id, Historical_Linker__c, Advisory_com_Organization_id__c FROM Account WHERE Id = :acct.Id];
        
        // generate the request
        SiteUser sUser = new SiteUser();
        sUser.Site = SiteUserHelper.SITE_EAB;
        sUser.Email_Address = c.Email;
        sUser.Email_Address2 = 'hansonv@zzzzz.com';
        sUser.Organization_Id = integer.valueOf(acct.Advisory_com_Organization_id__c);
        sUser.Password = 'test';
        sUser.ClientId = acct.Historical_Linker__c;
        sUser.Prefix = 'Mr';
        sUser.Country = 'USA';
        sUser.First_Name = 'Victor';
        sUser.Last_Name = 'Hanson';
        sUser.Middle_Initial = 'R';
        sUser.Suffix = '';
        sUser.Job_Function = 'Developer';
        sUser.Title = 'SF Dev';
        sUser.Department = 'eTech';
        sUser.Command = 'register';
        sUser.Office_Phone = '555-555-5655';
        
        string origData = JSON.serialize(sUser);
        blob encryptedBlob = Crypto.encryptWithManagedIV('AES256', SiteControllerHelper.KEY, blob.valueOf(origData));
        String encryptedString = EncodingUtil.base64Encode(encryptedBlob);
        
        // Add parameters to page URL 
        ApexPages.currentPage().getParameters().put('req', encryptedString);
        
        //Start test from here
        test.startTest();
        
        // controller
        SiteController controller = new SiteController();
        controller.initialize();
        
        //Stop tets here
        test.stopTest();
        
        // get the response
        String decryptedJSONResponse = EncryptionHelper.decrypt(EncodingUtil.base64Decode(controller.JSONResponse));
        
        sUser = EncryptionHelper.deserializeSiteUser(decryptedJSONResponse);
        
        //Asserting for the results
        system.assertEquals('success', sUser.Response.toLowerCase());
        
        // get the contact
        c = [SELECT Name, Id, Email, Advisory_com_Preferred_Email_Address__c, Site_User__c,
                                  (SELECT Id, Password__c, Password_Reset_Token__c, Bypass_Domain_Validation__c, Last_Access__c, 
                                   Send_Password_Notification__c, Site_User__c, Verify__c, Verify_Date__c, Status__c, Status_Code__c, 
                                   Type__c, User_Id__c, Username__c FROM Site_Profiles__r) 
                                  FROM Contact WHERE Id = :c.Id];
        
        //Asserting for the results
        system.assertEquals(c.Id, sUser.UniqueId);
        
        // verify the contact was created properly
        system.assertEquals('hansonv@zzzzz.com', c.Advisory_com_Preferred_Email_Address__c);
        
        system.assertequals(1, c.Site_Profiles__r.size(),
                           'There should be one Site Profile related to this contact.');
        system.assertequals('In Progress', c.Site_Profiles__r[0].Status__c,
                           'The Site Profile status should be In Progress when registering a new Contact that has not set a PW yet.');
        system.assertEquals(c.Site_User__c, c.Site_Profiles__r[0].Site_User__c,
                           'The Contact and Site Profile should be related to the same Site User record.');
        system.assertNotEquals(null, c.Site_Profiles__r[0].Password_Reset_Token__c,
                           'The Password Reset Token field should not be null - this value is used in the verification email sent to the user.');
        system.assertEquals(c.Site_User__c, c.Site_Profiles__r[0].Site_User__c);
    }
    
    static testmethod void testAction_Register_EmailInUseOnAnotherInstitution() {
    
        //Bypass Dupeblocker
        Util.IsTest(true);
        
        //Bypassing Triggers so then test data can be created easily
        Util.byPassAllTriggers = true;
        
        //Flag for triggers: this is just a test, don't do crazy things.
        Util.isTesting = true;
        
        // create a contact on a different institution
        Site_Profile__c profile1 = createSiteProfile(SiteUserHelper.SITE_EAB, false);
        insert profile1;
        
        //Site profiles
        list<Site_Profile__c> siteProfiles = [SELECT Id, Contact__c, Status__c, Type__c, 
                                              Username__c, User_Id__c FROM Site_Profile__c 
                                              WHERE Username__c = :profile1.Username__c];
        system.assertEquals(1, siteProfiles.size());
        
        // setup an account and contact
        Account acct = TestUtilities.CreateNewAccount(true);
        Eligible_Domain__c domain = new Eligible_Domain__c(Is_Included__c = true, Qualified_Domain__c = SiteUserHelper.SITE_ADVISORY, Account__c = acct.Id);
        insert domain;
        
        // set the page reference
        PageReference pageRef = Page.AdvisorySite;
        Test.setCurrentPage(pageRef);
        
        // get historical_Linker
        acct = [SELECT Id, Historical_Linker__c, Advisory_com_Organization_id__c FROM Account WHERE Id = :acct.Id];
        
        // generate the request
        SiteUser sUser = new SiteUser();
        sUser.Site = SiteUserHelper.SITE_EAB;
        sUser.Email_Address = profile1.Username__c;
        sUser.Email_Address2 = 'hansonv@zzzzz.com';
        sUser.Organization_Id = integer.valueOf(acct.Advisory_com_Organization_id__c);
        sUser.Password = 'test';
        sUser.ClientId = acct.Historical_Linker__c;
        sUser.Prefix = 'Mr';
        sUser.Country = 'USA';
        sUser.First_Name = 'Victor';
        sUser.Last_Name = 'Hanson';
        sUser.Middle_Initial = 'R';
        sUser.Suffix = '';
        sUser.Job_Function = 'Developer';
        sUser.Title = 'SF Dev';
        sUser.Department = 'eTech';
        sUser.Command = 'register';
        sUser.Office_Phone = '555-555-5655';
        
        string origData = JSON.serialize(sUser);
        blob encryptedBlob = Crypto.encryptWithManagedIV('AES256', SiteControllerHelper.KEY, blob.valueOf(origData));
        String encryptedString = EncodingUtil.base64Encode(encryptedBlob);
        // Add parameters to page URL 
        ApexPages.currentPage().getParameters().put('req', encryptedString);
        
        //Start test from here
        test.startTest();
        // controller
        SiteController controller = new SiteController();
        controller.initialize();
        //Stop test here
        test.stopTest();
        
        siteProfiles = [SELECT Id, Contact__c, Status__c, Type__c, Username__c, 
                        User_Id__c FROM Site_Profile__c WHERE Username__c = :profile1.Username__c];
        
        //Asserting for the results
        system.assertEquals(1, siteProfiles.size());
        
        // get the response
        String decryptedJSONResponse = EncryptionHelper.decrypt(EncodingUtil.base64Decode(controller.JSONResponse));
        
        sUser = EncryptionHelper.deserializeSiteUser(decryptedJSONResponse);
        
        // verify the proper error message was returned
        system.assertEquals(SiteUserHelper.ERROR_EXISTING_ACTIVE_USER, sUser.Response,
                           'There is already a Site Profile with the same email address associated with a different contact/institution -- an error should have been thrown');
    }
    
    static testMethod void testCreatePWResetURL() {
    
        //Bypass Dupeblocker
        Util.IsTest(true);
        
        //Bypassing Triggers so then test data can be created easily
        Util.byPassAllTriggers = true;
        
        //Flag for triggers: this is just a test, don't do crazy things.
        Util.isTesting = true;
        
        //create the sitecore settings
        sitecore_Settings__c settings = new sitecore_Settings__c(Advisory_Password_Reset_URL__c = 'Advisory.com',
                                                        EAB_Password_Reset_URL__c = 'EAB.com');
        insert settings;
        
        //test creating a PW reset token for an EAB user
        String requestString = '{"Username":"vhanson","Email_Address":"hansonv@advisory.com","Site":"EAB.com"}';
        SiteUser sUser = EncryptionHelper.deserializeSiteUser(requestString);
        string resetURL = SiteUserHelper.CreatePWResetURL(sUser, null);
        system.assertEquals(true, resetURL.containsIgnoreCase('eab.com'));
        string encryptedPayload = resetURL.split('\\?payload=')[1];
        
        // un-url-encode
        encryptedPayload = EncodingUtil.urlDecode(encryptedPayload, 'UTF-8');
        
        // convert string to blob
        blob encryptedBlob = EncodingUtil.base64Decode(encryptedPayload);
        
        // decrypt the reset URL
        string DecryptedPayload = EncryptionHelper.decrypt(encryptedBlob);
        system.assertEquals(true, DecryptedPayload.contains('hansonv@advisory.com'));
        system.assertEquals(true, DecryptedPayload.contains(dateTime.now().addDays(3).format('yyyy-MM-dd')));
        
        //Start test from here
        Test.startTest();
        
        //test creating a PW reset token when a passwordResetURL is specified in the callout
        requestString = '{"Username":"vhanson","Email_Address":"hansonv@advisory.com","PasswordResetUrl":"http://www.advisoryTEST.com/"}';
        sUser = EncryptionHelper.deserializeSiteUser(requestString);
        resetURL = SiteUserHelper.CreatePWResetURL(sUser, null);
        system.assertEquals(true, resetURL.containsIgnoreCase('advisoryTEST.com'));
        encryptedPayload = resetURL.split('\\?payload=')[1];
        // un-url-encode
        encryptedPayload = EncodingUtil.urlDecode(encryptedPayload, 'UTF-8');
        // convert string to blob
        encryptedBlob = EncodingUtil.base64Decode(encryptedPayload);
        // decrypt the reset URL
        DecryptedPayload = EncryptionHelper.decrypt(encryptedBlob);
        system.assertEquals(true, DecryptedPayload.contains(dateTime.now().addDays(3).format('yyyy-MM-dd')));
        
        //Stop test here
        Test.stopTest();
    }
    
    
    // test inserting a site profile with temp access, verify the proper access has been granted upon login
    static testMethod void testLogin_Login_WebProgAccess() {
        
        //Bypass Dupeblocker
        Util.IsTest(true);
        
        //Bypassing Triggers so then test data can be created easily
        Util.byPassAllTriggers = true;
        
        //Flag for triggers: this is just a test, don't do crazy things.
        Util.isTesting = true;
        
        //setup 2 web programs.  One that is accessible by employees and one that is not
        Web_Program_Access__c wpa_Access = Test_SiteUserHelper.CreateWebProgramAccess(false);
        Web_Program_Access__c wpa_NoAccess = Test_SiteUserHelper.CreateWebProgramAccess(false);
        wpa_NoAccess.ABC_Restricted__c = true;
        wpa_NoAccess.A_com_Program_Id__c = 321;
        wpa_NoAccess.Program_Code_To_Member__c = '101';
        list<Web_Program_Access__c> wpas = new list<Web_Program_Access__c> { wpa_Access, wpa_NoAccess };
        insert wpas;
        
        //setup 2 web program MTMs
        Web_Program_Access_MTM__c webProgMTM_Access = Test_SiteUserHelper.CreateWebProgramAccessMtM(wpa_Access.Id, false);
        Web_Program_Access_MTM__c webProgMTM_NoAccess = Test_SiteUserHelper.CreateWebProgramAccessMtM(wpa_NoAccess.Id, false);
        list<Web_Program_Access_MTM__c> wpaMTMs = new list<Web_Program_Access_MTM__c> { webProgMTM_Access, webProgMTM_NoAccess };
        insert wpaMTMs;
        
        //create & insert site user
        Site_User__c site_User = new Site_User__c();
        insert site_User;
        
        //create an account and employee contact
        Account acct = TestUtilities.CreateNewAccount(true);
        
        // create the eligible domain
        Eligible_Domain__c domain = new Eligible_Domain__c(Is_Included__c = true, Qualified_Domain__c = SiteUserHelper.SITE_ADVISORY, Account__c = acct.Id);
        insert domain;
        Contact employeeContact = TestUtilities.CreateNewContact(false);
        employeeContact.AccountId = acct.Id;
        employeeContact.RecordTypeId = Schema.SObjectType.Contact.RecordTypeInfosByName.get('Employee').RecordTypeId;
        employeeContact.Email = 'test-' + String.valueOf(Crypto.getRandomInteger()) + '@advisory.com';
        employeeContact.Site_User__c = site_User.Id;
        insert employeeContact;
        
        // create a contact on a different institution
        Site_Profile__c siteProfile = new Site_Profile__c(Status__c = 'Active',
                                                           Username__c = employeeContact.Email,
                                                           Password__c = 'test',
                                                           Site_User__c = site_User.Id,
                                                           Verify__c = '2',
                                                           Contact__c = employeeContact.Id,
                                                           Type__c = SiteUserHelper.SITE_ADVISORY);
        insert siteProfile;
        
        //create active memberships for both programs
        Membership__c membership_Access = new Membership__c();
        membership_Access.Membership_Status_Text__c = 'Member - Payer';
        membership_Access.Account_Name__c = acct.Id;
        membership_Access.Program__c = webProgMTM_Access.Membership_Program__c;
        membership_Access.Name = 'test';
        
        Membership__c membership_NoAccess = new Membership__c();
        membership_NoAccess.Membership_Status_Text__c = 'Member - Payer';
        membership_NoAccess.Account_Name__c = acct.Id;
        membership_NoAccess.Program__c = webProgMTM_NoAccess.Membership_Program__c;
        membership_NoAccess.Name = 'test';
        list<Membership__c> memberships = new list<Membership__c> { membership_Access, membership_NoAccess };
        util.BypassAllTriggers = true;
        insert memberships;
        util.BypassAllTriggers = false;
        
        // set the page reference
        PageReference pageRef = Page.Site_Json;
        Test.setCurrentPage(pageRef);
        
        // generate the request
        SiteUser sUser = new SiteUser();
        sUser.Site = SiteUserHelper.SITE_Advisory;
        sUser.Username = siteProfile.Username__c;
        sUser.Password = siteProfile.Password__c;
        sUser.Command = 'login';
        
        string origData = JSON.serialize(sUser);
        blob encryptedBlob = Crypto.encryptWithManagedIV('AES256', SiteControllerHelper.KEY, blob.valueOf(origData));
        String encryptedString = EncodingUtil.base64Encode(encryptedBlob);
        
        // Add parameters to page URL 
        ApexPages.currentPage().getParameters().put('req', encryptedString);
        
        // controller
        SiteController controller = new SiteController();
        controller.initialize();
        
        // get the response
        system.debug('@@controller.JSONResponseDecrypted:' + EncryptionHelper.decrypt(EncodingUtil.base64Decode(controller.JSONResponse)));
        String decryptedJSONResponse = EncryptionHelper.decrypt(EncodingUtil.base64Decode(controller.JSONResponse));
        
        sUser = EncryptionHelper.deserializeSiteUser(decryptedJSONResponse);
        
        system.assertEquals('Success', sUser.Response);
        system.assertEquals('L2', sUser.Status_Code, 'Status_Code should be \'L2\'');
        
        //verify only one web program was returned, since this was an employee contact and the other web program had ABC Restricted = true
        system.assertEquals(1, sUser.WebProgramAccessList.size());
        
        //verify there is one web service log that has the response of Success
        list<Web_Service_Log__c> wsLogs = [SELECT Id, Web_Service_Method__c, Response_Message__c FROM Web_Service_Log__c WHERE Site_Profile__c = :siteProfile.Id];
        system.assertEquals(1, wsLogs.size(),
                            'Should have returned one webservice log.');
        system.assertEquals(sUser.Command, wsLogs[0].Web_Service_Method__c);
        system.assertEquals(SiteUserHelper.RESPONSE_SUCCESS, wsLogs[0].Response_Message__c);
    }
    
    // attempt to login a user where the status is active, but the verify code is "1" -- should return R3
    static testMethod void testLogin_R3() {
        
        //Bypass Dupeblocker
        Util.IsTest(true);
        
        //Bypassing Triggers so then test data can be created easily
        Util.byPassAllTriggers = true;
        
        //Flag for triggers: this is just a test, don't do crazy things.
        Util.isTesting = true;
        
        // create a contact on a different institution
        Site_Profile__c siteProfile = createSiteProfile(SiteUserHelper.SITE_EAB, false);
        siteProfile.Verify__c = '1';
        insert siteProfile;
        
        // set the page reference
        PageReference pageRef = Page.Site_Json;
        Test.setCurrentPage(pageRef);
        
        // generate the request
        SiteUser sUser = new SiteUser();
        sUser.Site = SiteUserHelper.SITE_EAB;
        sUser.Username = siteProfile.Username__c;
        sUser.Password = siteProfile.Password__c;
        sUser.Command = 'login';
        
        string origData = JSON.serialize(sUser);
        blob encryptedBlob = Crypto.encryptWithManagedIV('AES256', SiteControllerHelper.KEY, blob.valueOf(origData));
        String encryptedString = EncodingUtil.base64Encode(encryptedBlob);
        
        // Add parameters to page URL 
        ApexPages.currentPage().getParameters().put('req', encryptedString);
        
        // controller
        SiteController controller = new SiteController();
        controller.initialize();
        
        // get the response
        system.debug('@@controller.JSONResponseDecrypted:' + EncryptionHelper.decrypt(EncodingUtil.base64Decode(controller.JSONResponse)));
        String decryptedJSONResponse = EncryptionHelper.decrypt(EncodingUtil.base64Decode(controller.JSONResponse));
        
        sUser = EncryptionHelper.deserializeSiteUser(decryptedJSONResponse);
        
        // make sure the returned string is correct
        system.assertEquals('R3', sUser.Status_Code,
                           'Status_Code should be \'R3\' when verify = \'1\'');
        
        //verify there is one web service log that has the response of Success
        list<Web_Service_Log__c> wsLogs = [SELECT Id, Web_Service_Method__c, Response_Message__c FROM Web_Service_Log__c WHERE Site_Profile__c = :siteProfile.Id];
        system.assertEquals(1, wsLogs.size(),
                            'Should have returned one webservice log.');
        system.assertEquals(sUser.Command, wsLogs[0].Web_Service_Method__c);
        system.assertEquals(SiteUserHelper.RESPONSE_SUCCESS, wsLogs[0].Response_Message__c);
    }
    
    static testMethod void testDecrypt_Invalid_EAB_SiteUser() {
        
        //Bypass Dupeblocker
        Util.IsTest(true);
        
        //Bypassing Triggers so then test data can be created easily
        Util.byPassAllTriggers = true;
        
        //Flag for triggers: this is just a test, don't do crazy things.
        Util.isTesting = true;
        
        //create a site profile for EAB.com
        Site_Profile__c siteProfile_EAB = createSiteProfile(SiteUserHelper.SITE_EAB, true);
        
        //create a second site profile with the same contact for Advisory.com
        Site_Profile__c siteProfile_ADV = createSiteProfile(SiteUserHelper.SITE_EAB, false);
        siteProfile_ADV.Type__c = SiteUserHelper.SITE_ADVISORY;
        siteProfile_ADV.Username__c = 'Advisory_Username@Advisory.com';
        siteProfile_ADV.Password__c = 'Advisory_Password';
        siteProfile_ADV.Contact__c = siteProfile_EAB.Contact__c;
        siteProfile_ADV.Site_User__c = siteProfile_EAB.Site_User__c;
        insert siteProfile_ADV;
        
        // set the page reference
        PageReference pageRef = Page.AdvisorySite;
        Test.setCurrentPage(pageRef);
        
        // try logging in to the EAB.com site using their Advisory.com credentials (which are different from their eab creds)
        SiteUser sUser = new SiteUser();
        sUser.Site = siteProfile_EAB.Type__c;
        sUser.Username = siteProfile_ADV.Username__c;
        sUser.Password = siteProfile_ADV.Password__c;
        sUser.Command = 'login';
        
        string origData = JSON.serialize(sUser);
        blob encryptedBlob = Crypto.encryptWithManagedIV('AES256', SiteControllerHelper.KEY, blob.valueOf(origData));
        String encryptedString = EncodingUtil.base64Encode(encryptedBlob);

        // Add parameters to page URL 
        ApexPages.currentPage().getParameters().put('req', encryptedString);
        
        // controller
        SiteController controller = new SiteController();
        controller.initialize();
        system.debug('@@controller.JSONResponseDecrypted:' + EncryptionHelper.decrypt(EncodingUtil.base64Decode(controller.JSONResponse)));
        String decryptedJSONResponse = EncryptionHelper.decrypt(EncodingUtil.base64Decode(controller.JSONResponse));
        
        // deserialize the response
        sUser = EncryptionHelper.deserializeSiteUser(decryptedJSONResponse);
        
        // make sure the returned string is correct
        system.assertEquals('invalid login', sUser.Response);
    }
    
    static testMethod void testAction_GetUser() {
        
        //Bypass Dupeblocker
        Util.IsTest(true);
        
        //Bypassing Triggers so then test data can be created easily
        Util.byPassAllTriggers = true;
        
        //Flag for triggers: this is just a test, don't do crazy things.
        Util.isTesting = true;
        
        // create a profile on a different institution
        Site_Profile__c siteProfile = createSiteProfile(SiteUserHelper.SITE_EAB, false);
        siteProfile.Password__c = 'test';
        siteProfile.Verify__c = '2';
        siteProfile.Status__c = 'Active';
        insert siteProfile;
        
        // insert 2 meeting utilizations
        Meeting_Utilization__c mUtilization_future = new Meeting_Utilization__c(Start_Date__c = system.today().addDays(1),
                                                                                End_Date__c = system.today().addDays(2),
                                                                                Status__c = 'Confirmed',
                                                                                EventID__c = '1111-1111-1111-1111',
                                                                                ABC_Contact__c = siteProfile.Contact__c);
        Meeting_Utilization__c mUtilization_past = new Meeting_Utilization__c(Start_Date__c = system.today().addDays(-4),
                                                                                End_Date__c = system.today().addDays(-5),
                                                                                Status__c = 'Attended',
                                                                                EventID__c = '2222-2222-2222-2222',
                                                                                ABC_Contact__c = siteProfile.Contact__c);
        List<Meeting_Utilization__c> utilzationsToInsert = new List<Meeting_Utilization__c> { mUtilization_future, mUtilization_past };
        insert utilzationsToInsert;
        
        // set the page reference
        PageReference pageRef = Page.AdvisorySite;
        Test.setCurrentPage(pageRef);
        
        SiteUser sUser = new SiteUser();
        sUser.Site = siteProfile.Type__c;
        sUser.Username = siteProfile.Username__c;
        sUser.IsOnline = true;
        sUser.Command = 'getUser';
        
        string origData = JSON.serialize(sUser);
        blob encryptedBlob = Crypto.encryptWithManagedIV('AES256', SiteControllerHelper.KEY, blob.valueOf(origData));
        String encryptedString = EncodingUtil.base64Encode(encryptedBlob);
        
        // Add parameters to page URL 
        ApexPages.currentPage().getParameters().put('req', encryptedString);
        
        // controller
        SiteController controller = new SiteController();
        controller.initialize();
        
        // deserialize the response
        String decryptedJSONResponse = EncryptionHelper.decrypt(EncodingUtil.base64Decode(controller.JSONResponse));
        sUser = EncryptionHelper.deserializeSiteUser(decryptedJSONResponse);
        
        Contact con = [SELECT Name, Id, FirstName, LastName, 
                       (SELECT Id, Password__c, Password_Reset_Token__c, Bypass_Domain_Validation__c, 
                        Last_Access__c, Send_Password_Notification__c, Site_User__c, Verify__c, Verify_Date__c, Status__c, Status_Code__c, Type__c, User_Id__c, Username__c 
                        FROM Site_Profiles__r 
                        ORDER BY Status__c DESC)
                       FROM Contact 
                       WHERE Id IN (SELECT Contact__c FROM Site_Profile__c WHERE Id = :siteProfile.Id)];
        
        // make sure the returned string is correct
        system.assertEquals('Success', sUser.Response);
        system.assertEquals(1, con.Site_Profiles__r.size());
        // verify the EventID of our future meeting is present in the JSON response
        system.assert(decryptedJSONResponse.contains('1111-1111-1111-1111'));
        // verify the EventID of our past meeting is NOT included in the JSON response
        system.assert(!decryptedJSONResponse.contains('2222-2222-2222-2222'));
        
        //verify there is one web service log that has the response of Success
        list<Web_Service_Log__c> wsLogs = [SELECT Id, Web_Service_Method__c, Response_Message__c FROM Web_Service_Log__c WHERE Site_Profile__c = :siteProfile.Id];
        system.assertEquals(1, wsLogs.size(),
                            'Should have returned one webservice log.');
        system.assertEquals(sUser.Command, wsLogs[0].Web_Service_Method__c);
        system.assertEquals(SiteUserHelper.RESPONSE_SUCCESS, wsLogs[0].Response_Message__c);
    }
    
    /**
     * @description:    
     * 
     **/
    static testmethod void testAction_UpdateUser() {
        
        //Bypass Dupeblocker
        Util.IsTest(true);
        
        //Bypassing Triggers so then test data can be created easily
        Util.byPassAllTriggers = true;
        
        //Flag for triggers: this is just a test, don't do crazy things.
        Util.isTesting = true;
        
        // create a profile on a different institution
        Site_Profile__c siteProfile = createSiteProfile(SiteUserHelper.SITE_EAB, false);
        siteProfile.Password__c = 'test';
        siteProfile.Verify__c = '2';
        siteProfile.Status__c = 'Active';
        insert siteProfile;
        
        //get the updated site profile (with user id)
        siteProfile = [SELECT Id, Password__c, Password_Reset_Token__c, Bypass_Domain_Validation__c, Last_Access__c, 
                       Send_Password_Notification__c, Site_User__c, Verify__c, Verify_Date__c, Status__c, Status_Code__c, Type__c, User_Id__c, Username__c 
                       FROM Site_Profile__c
                      WHERE Id = :siteProfile.Id];
        
        // set the page reference
        PageReference pageRef = Page.Site_Json;
        Test.setCurrentPage(pageRef);
        
        string jobFunction = 'Developer';
        string department = 'eTech';
        
        //generate the request
        SiteUser sUser = new SiteUser();
        sUser.Site = siteProfile.Type__c;
        sUser.Username = siteProfile.Username__c;
        sUser.Password = '';
        sUser.User_Id = integer.valueOf(siteProfile.User_Id__c);
        sUser.Prefix = 'Mr';
        sUser.Country = 'USA';
        sUser.First_Name = 'Victor';
        sUser.Last_Name = 'Hanson';
        sUser.Middle_Initial = 'R';
        sUser.Suffix = '';
        sUser.Title = 'SF Dev';
        //sUser.Job_Function = jobFunction;
        sUser.EAB_Role = jobFunction;
        //sUser.Department = department;
        sUser.EAB_Department = department;
        sUser.Office_Phone = '555-555-5655';
        sUser.Command = 'updateUser';
        
        string origData = JSON.serialize(sUser);
        blob encryptedBlob = Crypto.encryptWithManagedIV('AES256', SiteControllerHelper.KEY, blob.valueOf(origData));
        String encryptedString = EncodingUtil.base64Encode(encryptedBlob);
        
        // Add parameters to page URL 
        ApexPages.currentPage().getParameters().put('req', encryptedString);
        
        test.startTest();
        //reset the bypass variables to false
        SiteProfileTriggerHelper.hasSynchronizedSiteProfile = false;
        
        // controller
        SiteController controller = new SiteController();
        controller.initialize();
        test.stopTest();
        
        // deserialize the response
        String decryptedJSONResponse = EncryptionHelper.decrypt(EncodingUtil.base64Decode(controller.JSONResponse));
        sUser = EncryptionHelper.deserializeSiteUser(decryptedJSONResponse);
        
        system.assertEquals('Success', sUser.Response);
        
        // get the updated contact
        siteProfile = [SELECT Id, Username__c, Contact__r.EAB_Department__c, Contact__r.EAB_Role__c, Contact__r.Advisory_com_Modified_By__c FROM Site_Profile__c WHERE Id = :siteProfile.Id];
        
        // verify the contact was updated properly
        system.assertEquals(department, siteProfile.Contact__r.EAB_Department__c);
        system.assertEquals(jobFunction, siteProfile.Contact__r.EAB_Role__c);
        
        /*system.assertEquals(department, siteProfile.Contact__r.EAB_Department__c);
        system.assertEquals(jobFunction, siteProfile.Contact__r.EAB_Role__c);*/
    }
    
    /**
     * @description:    
     **/
    static testMethod void testTemporaryAccessDetails() {
        
        //Bypass Dupeblocker
        Util.IsTest(true);
        
        //Bypassing Triggers so then test data can be created easily
        Util.byPassAllTriggers = true;
        
        //Flag for triggers: this is just a test, don't do crazy things.
        Util.isTesting = true;
        
        // create an active Account/Contact/Site User/Site Profile on a different institution
        Site_Profile__c siteProfile = createSiteProfile(SiteUserHelper.SITE_EAB, false);
        siteProfile.Password__c = 'test';
        siteProfile.Verify__c = '2';
        siteProfile.Status__c = 'Active';
        insert siteProfile;
        
        // add a temporary access record
        Temporary_Program_Access__c tempAccess = CreateTempProgAccess(null, siteProfile, true);
        
        // set the page reference
        PageReference pageRef = Page.AdvisorySite;
        Test.setCurrentPage(pageRef);
        
        //generate the request
        SiteUser sUser = new SiteUser();
        sUser.Site = siteProfile.Type__c;
        sUser.Username = siteProfile.Username__c;
        sUser.IsOnline = true;
        sUser.Command = 'getUser';
        string origData = JSON.serialize(sUser);
        blob encryptedBlob = Crypto.encryptWithManagedIV('AES256', SiteControllerHelper.KEY, blob.valueOf(origData));
        String encryptedString = EncodingUtil.base64Encode(encryptedBlob);
        
        // Add parameters to page URL 
        ApexPages.currentPage().getParameters().put('req', encryptedString);
        
        // controller
        SiteController controller = new SiteController();
        controller.initialize();
        
        //decrypt/deserialize the response
        String decryptedJSONResponse = EncryptionHelper.Decrypt(EncodingUtil.base64Decode(controller.JSONResponse));
        sUser = EncryptionHelper.deserializeSiteUser(decryptedJSONResponse);
        
        system.debug('@@SiteUser:' + sUser);
        
        system.assertEquals('Success', sUser.Response);
        
        List<Temporary_Program_Access__c> taList = [SELECT Id, Site_Program_Id__c FROM Temporary_Program_Access__c WHERE Id = :tempAccess.Id];
        system.assertEquals(1, taList.size(),
                           'One temporary access record should have been created.');
        
        Contact con = [SELECT Name, Id, FirstName, LastName, Advisory_com_Last_Access__c,
               (SELECT Name, Id, Web_Program__r.Membership_Program__c, Web_Program__r.Program_Acronym__c, Web_Program__r.Adv_com_Program_Id__c, Web_Program__r.Program_Formal_Name__c FROM Temporary_Program_Access__r WHERE Start_Date__c <= TODAY AND End_Date__c >= TODAY LIMIT 1000)
               FROM Contact WHERE Id = :siteProfile.Contact__c];
        
        // make sure the Site Program Id is included in the webProgramAccessList
        system.assertEquals(1, sUser.webProgramAccessList.size(),
                           'One web program access record should have been included in the site user that was returned.');
        system.assertEquals(taList[0].Site_Program_Id__c, sUser.webProgramAccessList[0].siteProgramId,
                           'The Site Program Id should have been included in the webProgramAccessList that was returned.');
    }
    
    static testmethod void testAction_UpdateUser_Email() {
        
        // create a profile on a different institution
        Site_Profile__c siteProfile = createSiteProfile(SiteUserHelper.SITE_EAB, false);
        siteProfile.Password__c = 'test';
        siteProfile.Verify__c = '2';
        siteProfile.Status__c = 'Active';
        insert siteProfile;
        
        //get the updated site profile (with user id)
        siteProfile = [SELECT Id, Password__c, Password_Reset_Token__c, Bypass_Domain_Validation__c, Last_Access__c, Contact__c,
                       Send_Password_Notification__c, Site_User__c, Verify__c, Verify_Date__c, Status__c, Status_Code__c, Type__c, User_Id__c, Username__c 
                       FROM Site_Profile__c
                      WHERE Id = :siteProfile.Id];
        
        // set the page reference
        PageReference pageRef = Page.Site_Json;
        Test.setCurrentPage(pageRef);
        
        //generate the request
        SiteUser sUser = new SiteUser();
        sUser.Site = siteProfile.Type__c;
        sUser.Username = siteProfile.Username__c;
        sUser.Password = '';
        sUser.User_Id = integer.valueOf(siteProfile.User_Id__c);
        sUser.Email_Address = 'updatedemail@advisory.com';
        sUser.Prefix = 'Mr';
        sUser.Country = 'USA';
        sUser.First_Name = 'Victor';
        sUser.Last_Name = 'Hanson';
        sUser.Middle_Initial = 'R';
        sUser.Suffix = '';
        sUser.Job_Function = 'Developer';
        sUser.Title = 'SF Dev';
        sUser.Department = 'eTech';
        sUser.Office_Phone = '555-555-5655';
        sUser.Command = 'updateUser';
        
        string origData = JSON.serialize(sUser);
        blob encryptedBlob = Crypto.encryptWithManagedIV('AES256', SiteControllerHelper.KEY, blob.valueOf(origData));
        String encryptedString = EncodingUtil.base64Encode(encryptedBlob);
        
        // Add parameters to page URL 
        ApexPages.currentPage().getParameters().put('req', encryptedString);
        
        // controller
        SiteController controller = new SiteController();
        controller.initialize();
        
        // get the response and convert it to a Site User
        String decryptedJSONResponse = EncryptionHelper.decrypt(EncodingUtil.base64Decode(controller.JSONResponse));
        sUser = EncryptionHelper.deserializeSiteUser(decryptedJSONResponse);
        
        system.assertEquals('Success', sUser.Response);
        
        // get the updated contact and site user
        Contact con = [SELECT Name, Id, Email, Advisory_com_Email_Address2__c, Advisory_com_Modified_By__c, 
                       (SELECT Id, Name, Username__c, Verify__c, Status_Code__c FROM Site_Profiles__r) 
                       FROM Contact WHERE Id = :siteProfile.Contact__c];
        
        // verify the contact was updated properly
        system.assertEquals('updatedemail@advisory.com', con.Email);
        //verify the site profile was updated properly
        system.assertEquals('updatedemail@advisory.com', con.Site_Profiles__r[0].Username__c);
        system.assertEquals(siteProfile.Username__c, con.Advisory_com_Modified_By__c);
        system.assertEquals('1', con.Site_Profiles__r[0].Verify__c);
        // verify the response = success
        system.assertEquals(SiteUserHelper.RESPONSE_SUCCESS, sUser.Response);
        
        //check to see that there is a web service log created for this
        list<Web_Service_Log__c> wsLogs = [SELECT Id, Web_Service_Method__c, Response_Message__c, Requested_By__c FROM Web_Service_Log__c WHERE Site_Profile__c = :siteProfile.Id];
        system.assertEquals(1, wsLogs.size());
        system.assertEquals('updateUser', wsLogs[0].Web_Service_Method__c);
    }
    
    static testmethod void testAction_UpdateUser_Password() {
        
        //Bypass Dupeblocker
        Util.IsTest(true);
        
        //Bypassing Triggers so then test data can be created easily
        Util.byPassAllTriggers = true;
        
        //Flag for triggers: this is just a test, don't do crazy things.
        Util.isTesting = true;
        
        // create a profile on a different institution
        Site_Profile__c siteProfile = createSiteProfile(SiteUserHelper.SITE_EAB, false);
        siteProfile.Password__c = 'test';
        siteProfile.Verify__c = '2';
        siteProfile.Status__c = 'Active';
        insert siteProfile;
        
        //get the updated site profile (with user id)
        siteProfile = [SELECT Id, Password__c, Password_Reset_Token__c, Bypass_Domain_Validation__c, Last_Access__c, Contact__c,
                       Send_Password_Notification__c, Site_User__c, Verify__c, Verify_Date__c, Status__c, Status_Code__c, Type__c, User_Id__c, Username__c 
                       FROM Site_Profile__c
                       WHERE Id = :siteProfile.Id];
        
        // set the page reference
        PageReference pageRef = Page.Site_Json;
        Test.setCurrentPage(pageRef);
        
        //generate the request
        SiteUser sUser = new SiteUser();
        sUser.Site = siteProfile.Type__c;
        sUser.Username = siteProfile.Username__c;
        sUser.Password = 'newPassword';
        sUser.User_Id = integer.valueOf(siteProfile.User_Id__c);
        sUser.Email_Address = siteProfile.Username__c;
        sUser.Prefix = 'Mr';
        sUser.Country = 'USA';
        sUser.First_Name = 'Victor';
        sUser.Last_Name = 'Hanson';
        sUser.Middle_Initial = 'R';
        sUser.Suffix = '';
        sUser.Job_Function = 'Developer';
        sUser.Title = 'SF Dev';
        sUser.Department = 'eTech';
        sUser.Office_Phone = '555-555-5655';
        sUser.Command = 'updateUser';
        
        string origData = JSON.serialize(sUser);
        blob encryptedBlob = Crypto.encryptWithManagedIV('AES256', SiteControllerHelper.KEY, blob.valueOf(origData));
        String encryptedString = EncodingUtil.base64Encode(encryptedBlob);
        
        // Add parameters to page URL 
        ApexPages.currentPage().getParameters().put('req', encryptedString);
        
        // controller
        SiteController controller = new SiteController();
        controller.initialize();
        
        // get the response and convert it to a Site User
        String decryptedJSONResponse = EncryptionHelper.decrypt(EncodingUtil.base64Decode(controller.JSONResponse));
        sUser = EncryptionHelper.deserializeSiteUser(decryptedJSONResponse);
        
        // get the updated contact and site user
        Contact con = [SELECT Name, Id, Email, Advisory_com_Email_Address2__c, Advisory_com_Modified_By__c, 
                       (SELECT Id, Name, Username__c, Verify__c, Status_Code__c, Password__c FROM Site_Profiles__r) 
                       FROM Contact WHERE Id = :siteProfile.Contact__c];
        
        // verify the response = success
        system.assertEquals(SiteUserHelper.RESPONSE_SUCCESS, sUser.Response);
        // verify the site profile's password was updated
        system.assertEquals('newPassword', con.Site_Profiles__r[0].Password__c);
        //verify the site profile was updated properly
        system.assertEquals('2', con.Site_Profiles__r[0].Verify__c);
        
        //check to see that there is a web service log created for this
        list<Web_Service_Log__c> wsLogs = [SELECT Id, Web_Service_Method__c, Response_Message__c, Requested_By__c FROM Web_Service_Log__c WHERE Site_Profile__c = :siteProfile.Id];
        system.assertEquals(1, wsLogs.size());
        system.assertEquals('updateUser', wsLogs[0].Web_Service_Method__c);
    }
    
    // make sure the verify field doesnt change if it equals 4
    static testmethod void testVerify_4() {
        
        // create a profile on a different institution
        Site_Profile__c siteProfile = createSiteProfile(SiteUserHelper.SITE_EAB, false);
        siteProfile.Password__c = 'test';
        siteProfile.Verify__c = '4';
        siteProfile.Status__c = 'Active';
        insert siteProfile;
        
        //get the updated site profile (with user id)
        siteProfile = [SELECT Id, Password__c, Password_Reset_Token__c, Bypass_Domain_Validation__c, Last_Access__c, Contact__c,
                       Send_Password_Notification__c, Site_User__c, Verify__c, Verify_Date__c, Status__c, Status_Code__c, Type__c, User_Id__c, Username__c 
                       FROM Site_Profile__c
                       WHERE Id = :siteProfile.Id];
        
        system.assertEquals('4', siteProfile.Verify__c);
        // set the page reference
        PageReference pageRef = Page.Site_Json;
        Test.setCurrentPage(pageRef);
        
        //generate the request
        SiteUser sUser = new SiteUser();
        sUser.Site = siteProfile.Type__c;
        sUser.Username = siteProfile.Username__c;
        sUser.Password = 'newPassword';
        sUser.User_Id = integer.valueOf(siteProfile.User_Id__c);
        sUser.Email_Address = 'updatedemail@advisory.com';
        sUser.Prefix = 'Mr';
        sUser.Country = 'USA';
        sUser.First_Name = 'Victor';
        sUser.Last_Name = 'Hanson';
        sUser.Middle_Initial = 'R';
        sUser.Suffix = '';
        sUser.Job_Function = 'Developer';
        sUser.Title = 'SF Dev';
        sUser.Department = 'eTech';
        sUser.Office_Phone = '555-555-5655';
        sUser.Command = 'updateUser';
        
        string origData = JSON.serialize(sUser);
        blob encryptedBlob = Crypto.encryptWithManagedIV('AES256', SiteControllerHelper.KEY, blob.valueOf(origData));
        String encryptedString = EncodingUtil.base64Encode(encryptedBlob);
        
        // Add parameters to page URL 
        ApexPages.currentPage().getParameters().put('req', encryptedString);
        
        // controller
        SiteController controller = new SiteController();
        controller.initialize();
        
        // get the response and convert it to a Site User
        String decryptedJSONResponse = EncryptionHelper.decrypt(EncodingUtil.base64Decode(controller.JSONResponse));
        sUser = EncryptionHelper.deserializeSiteUser(decryptedJSONResponse);
        
        // get the updated contact and site user
        Contact con = [SELECT Name, Id, Email, Advisory_com_Email_Address2__c, Advisory_com_Modified_By__c, 
                       (SELECT Id, Name, Username__c, Verify__c, Status_Code__c, Password__c FROM Site_Profiles__r) 
                       FROM Contact WHERE Id = :siteProfile.Contact__c];
        
        // verify the response = success
        system.assertEquals(SiteUserHelper.RESPONSE_SUCCESS, sUser.Response);
        // ensure the verify flag is set
        system.assertEquals('4', con.Site_Profiles__r[0].Verify__c);
        // verify the contact was updated properly
        system.assertEquals('updatedemail@advisory.com', con.Email);
        system.assertEquals('updatedemail@advisory.com', con.Site_Profiles__r[0].Username__c);
    }
    
    static testmethod void testAction_UpdateUser_EmailAlreadyExists() {
        
        //Bypass Dupeblocker
        Util.IsTest(true);
        
        //Bypassing Triggers so then test data can be created easily
        Util.byPassAllTriggers = true;
        
        //Flag for triggers: this is just a test, don't do crazy things.
        Util.isTesting = true;
        
        Account acct = createNewAccount(true);
        
        // create a profile on a different institution
        Site_Profile__c siteProfile = createSiteProfile(acct, SiteUserHelper.SITE_EAB, false);
        siteProfile.Username__c = 'hansonv@advisory.com';
        siteProfile.Password__c = 'test';
        siteProfile.Verify__c = '2';
        siteProfile.Status__c = 'Active';
        
        Site_Profile__c siteProfile2 = createSiteProfile(acct, SiteUserHelper.SITE_EAB, false);
        siteProfile2.Username__c = 'broman@advisory.com';
        siteProfile2.Password__c = 'test';
        siteProfile2.Verify__c = '2';
        siteProfile2.Status__c = 'Active';
        
        list<Site_profile__c> siteProfileList = new list<Site_Profile__c> { siteProfile, siteProfile2 };
        
        //Bypassing Triggers so then test data can be created easily
        Util.byPassAllTriggers = false;    
            
        //try to insert the site profiles and capture the error(s) that are returned
        String errMsg;
        try {
            insert siteProfileList;
        }
        catch(DMLException ex) {
            errMsg = ex.getDMLMessage(0);
        }
        catch(Exception ex) {
            system.assertEquals(null, ex.getMessage());
        }
        
        // verify that an error was thrown because the Username cannot be directly updated on the Site Profile
        system.assertNotEquals(null, errMsg);
       
    }
    
    /**
     * @description:    This test method is used to verify the sort on the Subscription items works as expected
     * 
     **/
    static testmethod void testSubscriptionWrapperSort() {
        
        //Bypass Dupeblocker
        Util.IsTest(true);
        
        //Bypassing Triggers so then test data can be created easily
        Util.byPassAllTriggers = true;
        
        //Flag for triggers: this is just a test, don't do crazy things.
        Util.isTesting = true;
        
        //Set up test data
        List<Subscription_Option__c> listSO = new list<Subscription_Option__c>();
        List<Eligible_Subscription_Option__c> listESO = new list<Eligible_Subscription_Option__c>();
        
        Util.BypassAllTriggers = true;
        
        //Subscription_Option__c records to insert
        Subscription_Option__c sOption0 = TestUtilities.CreateNewSubscriptionOption(false);
        sOption0.Name = 'The Grapefruit';
        listSO.add(sOption0);
        
        Subscription_Option__c sOption1 = TestUtilities.CreateNewSubscriptionOption(false);
        sOption1.Name = 'An Orange';
        listSO.add(sOption1);
        
        Subscription_Option__c sOption2 = TestUtilities.CreateNewSubscriptionOption(false);
        sOption2.Name = 'A Tangerine';
        listSO.add(sOption2);
        
        Subscription_Option__c sOption3 = TestUtilities.CreateNewSubscriptionOption(false);
        sOption3.Name = 'Three Cranberries';
        listSO.add(sOption3);
        
        Subscription_Option__c sOption4 = TestUtilities.CreateNewSubscriptionOption(false);
        sOption4.Name = 'Watermelon';
        listSO.add(sOption4);
        
        //Insert the Subscription Option records
        insert listSO;
        system.debug('test_SiteUserHelper.testSubscriptionWrapperSort - listSO: '+listSO);
        
        //Create the Eligible Subscription Option records
        for(integer i=0; i < listSO.size(); i++){
            Util.BypassAllTriggers = true;
            Eligible_Subscription_Option__c esOption = TestUtilities.CreateNewEligibleSubscriptionOption(listSO[i], false);
            listESO.add(esOption);
            Util.BypassAllTriggers = false;
        }
        
        //Insert the Eligible Subscription Option records
        insert listESO;
        system.debug('test_SiteUserHelper.testSubscriptionWrapperSort - listESO: '+listESO);
        
        //Get the Id's of the inserted ESO's
        set<Id> idESO = new set<Id>();
        for(Eligible_Subscription_Option__c j : listESO){
            idESO.add(j.Id);
        }
        system.debug('test_SiteUserHelper.testSubscriptionWrapperSort - idESO: '+idESO);                
        
        //Create the list to hold Subscriptions
        List<SiteSubscriptionHelper.SubscriptionWrapper> subscribed = new list<SiteSubscriptionHelper.SubscriptionWrapper>();
        
        //Run the code to test
        test.startTest();

            list<Eligible_Subscription_Option__c> testESOList = [SELECT Id, Program__c, Related_Subscription__c, 
                                                                 Related_Subscription__r.Subscription_Category__c, 
                                                                 Related_Subscription__r.Description__c, Name__c,
                                                                 Program__r.Applicable_Segments__c
                                                                 FROM Eligible_Subscription_Option__c
                                                                 WHERE Id in :idESO];
        List<Eligible_Subscription_Option__c> wrapList = new list<Eligible_Subscription_Option__c>();
        //add eligible_subscription_option items to the list in random order, some including a, an, and the
        for(Eligible_Subscription_Option__c eso : testESOList) {
            //for(Eligible_Subscription_Option__c eso : listESO) {
            wrapList = new list<Eligible_Subscription_Option__c>();
            wrapList.add(eso);
            system.debug('test_SiteUserHelper.testSubscriptionWrapperSort - wrapList: '+wrapList);
            SiteSubscriptionHelper.SubscriptionWrapper sw = new SiteSubscriptionHelper.SubscriptionWrapper(wrapList);
            subscribed.add(sw);
        }
        //sort the list
        subscribed.sort();
        test.stopTest();
        
        //Verify the results
        system.assertEquals('The Grapefruit',subscribed[0].SubscriptionDisplayName);
        system.assertEquals('An Orange',subscribed[1].SubscriptionDisplayName);
        system.assertEquals('A Tangerine',subscribed[2].SubscriptionDisplayName);
        system.assertEquals('Three Cranberries',subscribed[3].SubscriptionDisplayName);
        system.assertEquals('Watermelon',subscribed[4].SubscriptionDisplayName);
    }
    
    static testMethod void testCreateWebConference() {
        
        //Bypass Dupeblocker
        Util.IsTest(true);
        
        //Bypassing Triggers so then test data can be created easily
        Util.byPassAllTriggers = true;
        
        //Flag for triggers: this is just a test, don't do crazy things.
        Util.isTesting = true;
        
        Site_Profile__c sProfile_Attendee = CreateSiteProfile(SiteUserHelper.SITE_Advisory, false);
        Site_Profile__c sProfile_Registrant = CreateSiteProfile(SiteUserHelper.SITE_Advisory, false);
        sProfile_Registrant.Username__c = 'registrant@advisory.com';
        
        Contact contact_Registrant = [SELECT Id, Email FROM Contact WHERE id = :sProfile_Registrant.Contact__c];
        contact_Registrant.Email = sProfile_Registrant.Username__c;
        update contact_Registrant;
        
        list<Site_Profile__c> sProfiles = new list<Site_Profile__c> { sProfile_Attendee, sProfile_Registrant };
            insert sProfiles;
        
        // get this contact so we have the proper User_Id
        Contact attendeeContact = [SELECT Id, Email, (SELECT Id, Status__c, User_Id__c, Username__c FROM Site_Profiles__r) FROM Contact WHERE Id = :sProfile_Attendee.Contact__c];
        Contact registeredByContact = [SELECT Id, Email, (SELECT Id, Status__c, User_Id__c, Username__c FROM Site_Profiles__r) FROM Contact WHERE Id = :sProfile_Registrant.Contact__c];
        
        string request = '{"Command":"SendWebConferenceConfirmation","WebEvent" : {"Name": "event name","Url":"www.test.com","StartDate":"10/14/2012 1:00 PM",'+
            '"EndDate":"10/14/2012 11:00 AM"},"Attendee" : {"User_Id":"'+ attendeeContact.Site_Profiles__r[0].User_Id__c +'","Prefix":"Mr","FirstName":"Victor","LastName":"Hanson"'+
            ',"MiddleInitial":"R","Suffix":"","Phone":"","Fax":"614-775-8585","Email":"abc@advisory.com"},"RegisteredBy" :{"User_Id":"'+ registeredByContact.Site_Profiles__r[0].User_Id__c +
            '","Prefix":"","FirstName":"","LastName":"","MiddleInitial":"","Suffix":"","Phone":"","Fax":"",' +
            '"Email":""},"RegisterOther":true,"HasRegisteredAlready":false,"Site":"' + SiteUserHelper.SITE_Advisory + '"}';
        
        // encrypt this request
        blob blobData = blob.valueOf(request);
        blob encryptedBlob = Crypto.encryptWithManagedIV('AES256', SiteControllerHelper.KEY, blobData);
        String encryptedString = EncodingUtil.base64Encode(encryptedBlob);
        
        // set the page reference
        PageReference pageRef = Page.Site_JSON;
        Test.setCurrentPage(pageRef);
        
        // Add parameters to page URL 
        ApexPages.currentPage().getParameters().put('req', encryptedString);
        
        // controller
        SiteController controller = new SiteController();
        controller.initialize();
        
        // get the response and convert it to a Site User
        String decryptedJSONResponse = EncryptionHelper.decrypt(EncodingUtil.base64Decode(controller.JSONResponse));
        SiteUser sUser = EncryptionHelper.deserializeSiteUser(decryptedJSONResponse);
        
        system.assertEquals(SiteUserHelper.RESPONSE_SUCCESS, sUser.Response);
        
        //get the web conference
        attendeeContact = [SELECT id, (SELECT Name, Id FROM WebConferences__r) FROM Contact WHERE Id = :attendeeContact.Id];
        system.assertEquals(1, attendeeContact.WebConferences__r.size(), 'There should be one web conference associated with the attendee contact.');
        
        // get the updated web coference
        Web_Conference__c webConf = [SELECT Id, Canceled__c, Canceled_By__c, Advisory_com_Attendee_User__c, Attendee_Site_Profile__c, Advisory_com_Registered_By_User__c, Registered_By_Site_Profile__c 
                   FROM Web_Conference__c WHERE Id = :attendeeContact.WebConferences__r[0].Id];
        
        system.assertEquals(attendeeContact.Id, webConf.Advisory_com_Attendee_User__c);
        system.assertEquals(sProfile_Attendee.Id, webConf.Attendee_Site_Profile__c);
        system.assertEquals(registeredByContact.Id, webConf.Advisory_com_Registered_By_User__c);
        system.assertEquals(sProfile_Registrant.Id, webConf.Registered_By_Site_Profile__c);
    }
    
    static testMethod void testCancelWebConference() {
        
        //Bypass Dupeblocker
        Util.IsTest(true);
        
        //Bypassing Triggers so then test data can be created easily
        Util.byPassAllTriggers = true;
        
        //Flag for triggers: this is just a test, don't do crazy things.
        Util.isTesting = true;
        
        Site_Profile__c sProfile_Attendee = CreateSiteProfile(SiteUserHelper.SITE_Advisory, false);
        Site_Profile__c sProfile_Registrant = CreateSiteProfile(SiteUserHelper.SITE_Advisory, false);
        sProfile_Registrant.Username__c = 'registrant@advisory.com';
        
        Contact contact_Registrant = [SELECT Id, Email FROM Contact WHERE id = :sProfile_Registrant.Contact__c];
        contact_Registrant.Email = sProfile_Registrant.Username__c;
        update contact_Registrant;
        
        list<Site_Profile__c> sProfiles = new list<Site_Profile__c> { sProfile_Attendee, sProfile_Registrant };
            insert sProfiles;
        
        // get this contact so we have the proper User_Id
        Contact attendeeContact = [SELECT Id, Email, (SELECT Id, Status__c, User_Id__c, Username__c FROM Site_Profiles__r) FROM Contact WHERE Id = :sProfile_Attendee.Contact__c];
        Contact registeredByContact = [SELECT Id, Email, (SELECT Id, Status__c, User_Id__c, Username__c FROM Site_Profiles__r) FROM Contact WHERE Id = :sProfile_Registrant.Contact__c];
        
        Web_Conference__c webConf = new Web_Conference__c();
        webConf.Event_Name__c = 'TestEvent 123';
        webConf.Event_URL__c = 'http://test.com';
        webConf.Start_Date__c = DateTime.parse('10/14/2012 1:00 PM');
        webConf.End_Date__c = DateTime.parse('10/14/2012 2:00 PM');
        webConf.Advisory_com_Attendee_User__c = attendeeContact.Id;
        webConf.Advisory_com_Registered_By_User__c = registeredByContact.Id;
        webConf.Attendee_Email__c = 'abc@advisory.com';
        insert webConf;
        
        string request = '{"Command":"SendWebConferenceConfirmation","WebEvent" : {"Name": "TestEvent 123","IsCanceled":true,"Origin":"AdminTool","Url":"http://test.com","StartDate":"10/14/2012 1:00 PM",'+
            '"EndDate":"10/14/2012 2:00 PM"},"Attendee" : {"User_Id":"'+ attendeeContact.Site_Profiles__r[0].User_Id__c +'","Prefix":"Mr","FirstName":"Victor","LastName":"Hanson"'+
            ',"MiddleInitial":"R","Suffix":"","Phone":"","Fax":"614-775-8585","Email":"abc@advisory.com"},"RegisteredBy" :{"User_Id":"'+ registeredByContact.Site_Profiles__r[0].User_Id__c +
            '","Prefix":"","FirstName":"","LastName":"","MiddleInitial":"","Suffix":"","Phone":"",' +
            '"Email":""},"HasRegisteredAlready":true,"Site":"' + SiteUserHelper.SITE_Advisory + '"}';
        
        // encrypt this request
        blob blobData = blob.valueOf(request);
        blob encryptedBlob = Crypto.encryptWithManagedIV('AES256', SiteControllerHelper.KEY, blobData);
        String encryptedString = EncodingUtil.base64Encode(encryptedBlob);
        
        // set the page reference
        PageReference pageRef = Page.Site_JSON;
        Test.setCurrentPage(pageRef);
        
        // Add parameters to page URL 
        ApexPages.currentPage().getParameters().put('req', encryptedString);
        
        // controller
        SiteController controller = new SiteController();
        controller.initialize();
        
        // get the response
        String decryptedJSONResponse = EncryptionHelper.decrypt(EncodingUtil.base64Decode(controller.JSONResponse));
        
        SiteUser sUser = EncryptionHelper.deserializeSiteUser(decryptedJSONResponse);
        
        system.assertEquals(true, decryptedJSONResponse.toLowerCase().contains('success'));
        
        // get the updated web coference
        webConf = [SELECT Id, Canceled__c, Canceled_By__c, Advisory_com_Attendee_User__c, Attendee_Site_Profile__c, Advisory_com_Registered_By_User__c, Registered_By_Site_Profile__c 
                   FROM Web_Conference__c WHERE Id = :webConf.Id];
        
        system.assertEquals(true, webConf.Canceled__c);
        system.assertEquals('AdminTool', webConf.Canceled_By__c);
        system.assertEquals(attendeeContact.Id, webConf.Advisory_com_Attendee_User__c);
        system.assertEquals(sProfile_Attendee.Id, webConf.Attendee_Site_Profile__c);
        system.assertEquals(registeredByContact.Id, webConf.Advisory_com_Registered_By_User__c);
        system.assertEquals(sProfile_Registrant.Id, webConf.Registered_By_Site_Profile__c);
        
    }
    
    /**
     * @description:    1) Create an Institution, Valid Domain, Contact, Site Profile
     *                  2) Delete the Valid Domain
     *                  3) Make an update to the Contact's basic info (ie: FirstName) and Save the changes
     *                  4) Verify that the contact was updated successfully even though the domain is invalid.
     * 
     **/
    static testmethod void testEditContact_BadDomain() {
        
        //Bypass Dupeblocker
        Util.IsTest(true);
        
        //Bypassing Triggers so then test data can be created easily
        Util.byPassAllTriggers = true;
        
        //Flag for triggers: this is just a test, don't do crazy things.
        Util.isTesting = true;
        
        //Bypass Dupeblocker
        CRMfusionDBR101.DB_Globals.triggersDisabled = true;
        
        //create a site profile
        Site_Profile__c sProfile = createSiteProfile(SiteUserHelper.SITE_Advisory, true);
        
        //get the site profile's contact
        Contact con = [SELECT Id, FirstName, Email FROM Contact WHERE Id = :sProfile.Contact__c];
        
        // get the domain of the contact
        String contactDomain = con.Email.split('@')[1];
        
        // find the domain record on the account & Delete it
        List<Eligible_Domain__c> eligibleDomains = [SELECT Id FROM Eligible_Domain__c WHERE Qualified_Domain__c = :contactDomain];
        system.assertNotEquals(0, eligibleDomains.size());
        delete eligibleDomains;
        
        // now edit / save the contact successfully
        String newFirstName = 'moseby';
        con.FirstName = newFirstName;
        update con;
        
        // get the updated contact
        List<Contact> cons = [SELECT Id, FirstName FROM Contact WHERE Id = :con.Id];
        system.assertEquals(1, cons.size());
        system.assertEquals(newFirstName, cons[0].FirstName);
    }
    
    static testmethod void testSiteUserContact_BadDomain_UncheckFalse() {
        
        //Bypass Dupeblocker
        Util.IsTest(true);
        
        //Bypassing Triggers so then test data can be created easily
        Util.byPassAllTriggers = true;
        
        //Flag for triggers: this is just a test, don't do crazy things.
        Util.isTesting = true;
        
        //Bypass Dupeblocker
        CRMfusionDBR101.DB_Globals.triggersDisabled = true;
        
        //create a site profile
        Site_Profile__c sProfile = createSiteProfile(SiteUserHelper.SITE_Advisory, true);
        
        //get the site profile's contact
        Contact con = [SELECT Id, FirstName, Email, Primary_Country__c, Bypass_Domain_Validation__c FROM Contact WHERE Id = :sProfile.Contact__c];
        // change the email to an invalid domain
        con.Email = 'test@zzzzz.com';
        con.Primary_Country__c = 'USA';
        con.Bypass_Domain_Validation__c = true;
        update con;
        
        con = [SELECT Id, FirstName, Email, Primary_Country__c, Bypass_Domain_Validation__c FROM Contact WHERE Id = :sProfile.Contact__c];
        system.assertEquals(true, con.Bypass_Domain_Validation__c);
        
        // now attempt to update the contact
        con.Bypass_Domain_Validation__c = false;
        
        boolean isSuccessful = false;
        try {
            Util.BypassAllTriggers = false;
            SiteProfileTriggerHelper.hasSynchronizedSiteProfile = false;
            update con;
        }
        catch(Exception ex) {
            if (ex.getMessage().contains('Domain is not eligible for this Site')) {
                // if we caught an error, this is a success
                isSuccessful = true;
            }
            else {
                system.assert(false, ex.getMessage());
            }
        }
        
        // get the contact even though it shouldn't have been updated
        con = [SELECT Id, Bypass_Domain_Validation__c FROM Contact WHERE Id = :con.Id];
        system.assertEquals(true, con.Bypass_Domain_Validation__c);
        
        system.assertEquals(true, isSuccessful);
	}
    
    /**
     * @description:    1) Create an Advisory.com site profile and simulate login
     *                  2) verify login history is tracked
     * 
     **/
    static testmethod void testTrackLoginHistory() {
        
        //Create an Advisory Site Profile
        Site_Profile__c sProfile = createSiteProfile(SiteUserHelper.SITE_Advisory, false);
        sProfile.Verify__c = '1';
        sProfile.Status__c = 'In Progress';
        insert sProfile;
        Contact contact = [SELECT Id, Advisory_com_Last_Access__c FROM Contact WHERE Id = :sProfile.Contact__c];
        
        //fetch histories
        List<Advisory_Com_Visit__c> histories = [Select Id, Advisory_Com_Visits__c from Advisory_Com_Visit__c where Contact__c = :sProfile.Contact__c];
        System.assertEquals(0, histories.size());
        
        //Start Testing from here
        Test.startTest();
        
        // set the page reference
        PageReference pageRef = Page.Site_Json;
        Test.setCurrentPage(pageRef);
        
        // generate the request
        SiteUser sUser = new SiteUser();
        sUser.Site = SiteUserHelper.SITE_ADVISORY;
        sUser.Username = sProfile.Username__c;
        sUser.Password = sProfile.Password__c;
        sUser.Command = 'login';
        
        string origData = JSON.serialize(sUser);
        blob encryptedBlob = Crypto.encryptWithManagedIV('AES256', SiteControllerHelper.KEY, blob.valueOf(origData));
        String encryptedString = EncodingUtil.base64Encode(encryptedBlob);
        
        // Add parameters to page URL 
        ApexPages.currentPage().getParameters().put('req', encryptedString);
        
        // controller
        SiteController controller = new SiteController();
        controller.initialize();
        
        // get the response
        String decryptedJSONResponse = EncryptionHelper.decrypt(EncodingUtil.base64Decode(controller.JSONResponse));
        
        sUser = EncryptionHelper.deserializeSiteUser(decryptedJSONResponse);
        
        contact = [SELECT Id, Advisory_com_Last_Access__c, (SELECT Id, Last_Access__c FROM Site_Profiles__r) FROM Contact WHERE Id = :sProfile.Contact__c];
        
        system.assertEquals(1, contact.site_profiles__r.size());
        system.assertNotEquals(null, contact.site_profiles__r[0].Last_Access__c);
        system.assertNotEquals(null, contact.Advisory_com_Last_Access__c);
        
        //fetch histories
        histories = [Select Id, Advisory_Com_Visits__c from Advisory_Com_Visit__c where Contact__c = :sProfile.Contact__c];
        System.assertEquals(1, histories.size());
        System.assertEquals(1, histories[0].Advisory_Com_Visits__c);
        
        // manually set the TrackHistoryHasRun flag back to false
        Util.TrackHistoryHasRun = false;
        
        // update the last access date with system.now() + 5 seconds.
        // a new visit should only be recorded when the time between last access dates is greater than 30 seconds
        contact.Advisory_com_Last_Access__c = system.now().addSeconds(5);
        update contact;
        
        //fetch histories
        histories = [Select Id, Advisory_Com_Visits__c from Advisory_Com_Visit__c where Contact__c = :sProfile.Contact__c];
        System.assertEquals(1, histories.size());
        System.assertEquals(1, histories[0].Advisory_Com_Visits__c);
        
        // manually set the TrackHistoryHasRun flag back to false
        Util.TrackHistoryHasRun = false;
        
        // update the contact as if the user logged in on adv.com.
        sProfile.Last_Access__c = system.now().addDays(1);
        update sProfile;
        
        //fetch histories
        histories = [Select Id, Advisory_Com_Visits__c from Advisory_Com_Visit__c where Contact__c = :sProfile.Contact__c];
        System.assertEquals(1, histories.size());
        System.assertEquals(2, histories[0].Advisory_Com_Visits__c);
        
        //Stop Test
        Test.stopTest();
    }
    
    /**
     * @description:    1) Create an EAB.com site profile and simulate login
     *                  2) verify no login history is tracked
     *                  3) Login history is only tracked for Advisory.com Site Profiles.
     * 
     **/
    static testmethod void testTrackLoginHistory_EAB() {
        
        //Bypass Dupeblocker
        Util.IsTest(true);
        
        //Bypassing Triggers so then test data can be created easily
        Util.byPassAllTriggers = true;
        
        //Flag for triggers: this is just a test, don't do crazy things.
        Util.isTesting = true;
        
        //Create an Advisory Site Profile
        Site_Profile__c sProfile = createSiteProfile(SiteUserHelper.SITE_EAB, false);
        sProfile.Verify__c = '1';
        sProfile.Status__c = 'In Progress';
        insert sProfile;
        Contact contact = [SELECT Id, Advisory_com_Last_Access__c FROM Contact WHERE Id = :sProfile.Contact__c];
        
        //fetch histories
        List<Advisory_Com_Visit__c> histories = [Select Id, Advisory_Com_Visits__c from Advisory_Com_Visit__c where Contact__c = :sProfile.Contact__c];
        System.assertEquals(0, histories.size());
        
        //Start Testing from here
        Test.startTest();
        
        // set the page reference
        PageReference pageRef = Page.Site_Json;
        Test.setCurrentPage(pageRef);
        
        // generate the request
        SiteUser sUser = new SiteUser();
        sUser.Site = SiteUserHelper.SITE_EAB;
        sUser.Username = sProfile.Username__c;
        sUser.Password = sProfile.Password__c;
        sUser.Command = 'login';
        
        string origData = JSON.serialize(sUser);
        blob encryptedBlob = Crypto.encryptWithManagedIV('AES256', SiteControllerHelper.KEY, blob.valueOf(origData));
        String encryptedString = EncodingUtil.base64Encode(encryptedBlob);
        
        // Add parameters to page URL 
        ApexPages.currentPage().getParameters().put('req', encryptedString);
        
        // controller
        SiteController controller = new SiteController();
        controller.initialize();
        
        // get the response
        String decryptedJSONResponse = EncryptionHelper.decrypt(EncodingUtil.base64Decode(controller.JSONResponse));
        
        sUser = EncryptionHelper.deserializeSiteUser(decryptedJSONResponse);
        
        contact = [SELECT Id, Advisory_com_Last_Access__c, (SELECT Id, Last_Access__c FROM Site_Profiles__r) FROM Contact WHERE Id = :sProfile.Contact__c];
        
        system.assertEquals(1, contact.site_profiles__r.size());
        system.assertNotEquals(null, contact.site_profiles__r[0].Last_Access__c);
        system.assertEquals(null, contact.Advisory_com_Last_Access__c);
        
        //fetch histories
        histories = [Select Id, Advisory_Com_Visits__c from Advisory_Com_Visit__c where Contact__c = :sProfile.Contact__c];
        System.assertEquals(0, histories.size());
        
        //Stop Test
        Test.stopTest();
    }
    
    /**
     * @description:    Create a site profile, add a membership key contact, and verify the subscription was auto-generated
     * 
     **/
    static testMethod void membershipKeyContact_AutoSubscribe_CreateSubscription() {
        
        //Bypass Dupeblocker
        Util.IsTest(true);
        
        //Bypassing Triggers so then test data can be created easily
        Util.byPassAllTriggers = true;
        
        //Flag for triggers: this is just a test, don't do crazy things.
        Util.isTesting = true;
        
        // create a contact that is also an Adv.com User
        Site_Profile__c sProfile = Test_SiteUserHelper.createSiteProfile(SiteUserHelper.SITE_EAB, true);
        
        // get the site profile and contact info
        sProfile = [SELECT Id, User_Id__c, Contact__r.LastName, Status_Code_Description__c, Type__c, 
                    	Contact__c, Contact__r.AccountId FROM Site_Profile__c WHERE Id = :sProfile.Id];
        
        // create a program
        Program__c prog = TestUtilities.CreateNewProgram(false);
        prog.Applicable_Segments__c = 'US Education';
        insert prog;
        
        Membership__c membership = new Membership__c();
        membership.Membership_Status_Text__c = 'Member - Payer';
        membership.Account_Name__c = sProfile.Contact__r.AccountId;
        membership.Program__c = prog.Id;
        membership.Name = 'test';
        insert membership;
        
        // create an opportunity and contract
        Opportunity opp = testUtilities.CreateNewOpportunity(sProfile.Contact__r.AccountId, false);
        opp.CloseDate = system.today();
        opp.stageName = 'Closed Won';
        opp.Program__c = prog.Id;
        insert opp;
        
        //Start test from here
        test.startTest();
        
        Contract__c testContract1 = new Contract__c(
            Name='Test Contract1', Payer_Account__c = sProfile.Contact__r.AccountId, Program__c = prog.Id, Source_Opportunity__c=opp.Id,
            Start__c = System.Today().addDays(-10), End__c = system.today().addDays(355),
            Contract_Renewal_Opportunity__c = opp.Id, Status__c = 'ATL', Invoicing_Arrangement__c = 'Annual', Year__c = '2012',
            Type__c = 'NBB', Years_in_Term__c = 1, Initial_Invoice_Date__c = system.today()
        );
        insert testContract1;
        
        setupSubscriptionOptions(prog.Id);
        
        //Bypassing Triggers so then test data can be created easily
        Util.byPassAllTriggers = false;
        
        //create the membership key contact
        Membership_Key_Contact__c membershipKeyContact = new Membership_Key_Contact__c(Contact__c = sProfile.Contact__c,
                                                                                       Name='Test',
                                                                                       Membership__c = membership.Id);
        insert membershipKeyContact;
        
        //Stop test here
        test.stopTest();
        
        // make sure we found the right subscriptions
        list<Subscription__c> subscriptions = [SELECT Id, Auto_Subscribed__c, Subscription_Id__c FROM Subscription__c WHERE Contact__c = :sProfile.Contact__c];
        system.assertEquals(1, subscriptions.size(),
                           'One subscription should have been auto-generated due to the membership key contact that was created.');
    }
    
    /**
     * @description:    Create an Advisory site profile, add a membership key contact for an EAB program, and verify the EAB Site Profile & subscription was auto-generated
     * 
     **/
    static testMethod void membershipKeyContact_AutoSubscribe_CreateSiteProfile() {
        
        // create a contact that is also an Adv.com User
        Site_Profile__c sProfile = Test_SiteUserHelper.createSiteProfile(SiteUserHelper.SITE_Advisory, true);
        
        // get the site profile and contact info
        sProfile = [SELECT Id, User_Id__c, Contact__r.LastName, Status_Code_Description__c, 
                    	Type__c, Contact__c, Contact__r.AccountId FROM Site_Profile__c WHERE Id = :sProfile.Id];
        
        //Bypass Dupeblocker
        Util.IsTest(true);
        
        //Bypassing Triggers so then test data can be created easily
        Util.byPassAllTriggers = true;
        
        //Flag for triggers: this is just a test, don't do crazy things.
        Util.isTesting = true;
        
        // create a program
        Program__c prog = TestUtilities.CreateNewProgram(false);
        prog.Applicable_Segments__c = 'US Education';
        insert prog;
        
        Membership__c membership = new Membership__c();
        membership.Membership_Status_Text__c = 'Member - Payer';
        membership.Account_Name__c = sProfile.Contact__r.AccountId;
        membership.Program__c = prog.Id;
        membership.Name = 'test';
        insert membership;
        
        // create an opportunity and contract
        Opportunity opp = testUtilities.CreateNewOpportunity(sProfile.Contact__r.AccountId, false);
        opp.CloseDate = system.today();
        opp.stageName = 'Closed Won';
        opp.Program__c = prog.Id;
        insert opp;
        
        test.startTest();
        
        Contract__c testContract1 = new Contract__c(
            Name='Test Contract1', Payer_Account__c = sProfile.Contact__r.AccountId, Program__c = prog.Id, Source_Opportunity__c=opp.Id,
            Start__c = System.Today().addDays(-10), End__c = system.today().addDays(355),
            Contract_Renewal_Opportunity__c = opp.Id, Status__c = 'ATL', Invoicing_Arrangement__c = 'Annual', Year__c = '2012',
            Type__c = 'NBB', Years_in_Term__c = 1, Initial_Invoice_Date__c = system.today()
        );
        insert testContract1;
        
        setupSubscriptionOptions(prog.Id);
        
        //Bypassing Triggers so then test data can be created easily
        Util.byPassAllTriggers = false;
        
        //create the membership key contact
        Membership_Key_Contact__c membershipKeyContact = new Membership_Key_Contact__c(Contact__c = sProfile.Contact__c,
                                                                                       Name='Test',
                                                                                       Membership__c = membership.Id);
        insert membershipKeyContact;
        
        // make sure we found the right subscriptions
        list<Subscription__c> subscriptions = [SELECT Id, Auto_Subscribed__c, Subscription_Id__c FROM Subscription__c WHERE Contact__c = :sProfile.Contact__c];
        system.assertEquals(1, subscriptions.size(),
                           'One subscription should have been auto-generated due to the membership key contact that was created.');
        
        test.stopTest();
        
        //verify an EAB site profile was auto-generated by the CreateAutoSubscriptions method
        Contact con = [SELECT Id, (SELECT Id, Type__c FROM Site_Profiles__r WHERE Type__c = :SiteUserHelper.SITE_EAB) FROM Contact WHERE Id = :sProfile.Contact__c];
        system.assertEquals(1, con.Site_Profiles__r.size(),
                           'an EAB Site Profile should have been generated due to the membership key contact that was created.');
    }
    
    /**
     * @description:    Create a site profile, add a Project Role associated with a PT program, and verify the subscription was auto-generated
     * 
     **/
    static testMethod void projectRole_PT_AutoSubscribe_CreateSubscription() {
        
        //Bypass Dupeblocker
        Util.IsTest(true);
        
        //Bypassing Triggers so then test data can be created easily
        Util.byPassAllTriggers = true;
        
        //Flag for triggers: this is just a test, don't do crazy things.
        Util.isTesting = true;
        
        // create a contact that is also an Adv.com User
        Site_Profile__c sProfile = Test_SiteUserHelper.createSiteProfile(SiteUserHelper.SITE_EAB, true);
        
        // get the site profile and contact info
        sProfile = [SELECT Id, User_Id__c, Contact__r.LastName, Status_Code_Description__c, Type__c, Contact__c, Contact__r.AccountId FROM Site_Profile__c WHERE Id = :sProfile.Id];
        
        // create a program
        Program__c prog = TestUtilities.CreateNewProgram(false);
        prog.Applicable_Segments__c = 'US Education';
        prog.Business_Line__c = 'PT';
        insert prog;
        
        Membership__c membership = new Membership__c();
        membership.Membership_Status_Text__c = 'Member - Payer';
        membership.Account_Name__c = sProfile.Contact__r.AccountId;
        membership.Program__c = prog.Id;
        membership.Name = 'test';
        util.BypassAllTriggers = true;
        insert membership;
        util.BypassAllTriggers = false;
        
        // create an opportunity and contract
        Opportunity opp = testUtilities.CreateNewOpportunity(sProfile.Contact__r.AccountId, false);
        opp.CloseDate = system.today();
        opp.stageName = 'Closed Won';
        opp.Program__c = prog.Id;
        insert opp;
        
        test.startTest();
        
        Contract__c testContract1 = new Contract__c(
            Name='Test Contract1', Payer_Account__c = sProfile.Contact__r.AccountId, Program__c = prog.Id, Source_Opportunity__c=opp.Id,
            Start__c = System.Today().addDays(-10), End__c = system.today().addDays(355),
            Contract_Renewal_Opportunity__c = opp.Id, Status__c = 'ATL', Invoicing_Arrangement__c = 'Annual', Year__c = '2012',
            Type__c = 'NBB', Years_in_Term__c = 1, Initial_Invoice_Date__c = system.today()
        );
        insert testContract1;
        
        //create project
        Project__c project = new Project__c(Name = 'Test',
                                            Institution__c = sProfile.Contact__r.AccountId,
                                            Primary_Paid_Membership__c = membership.Id,
                                            Product__c = prog.Id);
        insert project;
        
        setupSubscriptionOptions(prog.Id);
        
        util.BypassAllTriggers = false;
        
        //create the Project Role 
        Project_Role__c pRole = new Project_Role__c(Name='Test',
                                                    Project_Type__c = 'CCC',
                                                    Role__c = 'IT Lead',
                                                    Contact__c = sProfile.Contact__c,
                                                    Project__c = project.Id);
        
        insert pRole;
        
        test.stopTest();
        
        // make sure we found the right subscriptions
        list<Subscription__c> subscriptions = [SELECT Id, Auto_Subscribed__c, Subscription_Id__c FROM Subscription__c WHERE Contact__c = :sProfile.Contact__c];
        system.assertEquals(1, subscriptions.size(),
                           'One subscription should have been auto-generated due to the Project Role that was created.');
    }
    
    /**
     * @description:    Create an Advisory site profile, add a Project Role related to an EAB program, and verify the EAB Site Profile & subscription was auto-generated
     * 
     **/
    static testMethod void projectRole_PT_AutoSubscribe_CreateSiteProfile() {
        
        //Bypass Dupeblocker
        Util.IsTest(true);
        
        //Bypassing Triggers so then test data can be created easily
        Util.byPassAllTriggers = true;
        
        //Flag for triggers: this is just a test, don't do crazy things.
        Util.isTesting = true;
        
        // create a contact that is also an Adv.com User
        Site_Profile__c sProfile = Test_SiteUserHelper.createSiteProfile(SiteUserHelper.SITE_Advisory, true);
        
        // get the site profile and contact info
        sProfile = [SELECT Id, User_Id__c, Contact__r.LastName, Status_Code_Description__c, Type__c, Contact__c, Contact__r.AccountId FROM Site_Profile__c WHERE Id = :sProfile.Id];
        
        // create a program
        Program__c prog = TestUtilities.CreateNewProgram(false);
        prog.Applicable_Segments__c = 'US Education';
        prog.Business_Line__c = 'PT';
        insert prog;
        
        Membership__c membership = new Membership__c();
        membership.Membership_Status_Text__c = 'Member - Payer';
        membership.Account_Name__c = sProfile.Contact__r.AccountId;
        membership.Program__c = prog.Id;
        membership.Name = 'test';
        util.BypassAllTriggers = true;
        insert membership;
        util.BypassAllTriggers = false;
        membership = [SELECT Id, Membership_Status_Text__c FROM Membership__c WHERE Id = :membership.Id];
        system.assertEquals('Member - Payer', membership.Membership_Status_Text__c);
        
        // create an opportunity and contract
        Opportunity opp = testUtilities.CreateNewOpportunity(sProfile.Contact__r.AccountId, false);
        opp.CloseDate = system.today();
        opp.stageName = 'Closed Won';
        opp.Program__c = prog.Id;
        insert opp;
        
        test.startTest();
        
        Contract__c testContract1 = new Contract__c(
            Name='Test Contract1', Payer_Account__c = sProfile.Contact__r.AccountId, Program__c = prog.Id, Source_Opportunity__c=opp.Id,
            Start__c = System.Today().addDays(-10), End__c = system.today().addDays(355),
            Contract_Renewal_Opportunity__c = opp.Id, Status__c = 'ATL', Invoicing_Arrangement__c = 'Annual', Year__c = '2012',
            Type__c = 'NBB', Years_in_Term__c = 1, Initial_Invoice_Date__c = system.today()
        );
        insert testContract1;
        
        //create project
        Project__c project = new Project__c(Name = 'Test',
                                            Institution__c = sProfile.Contact__r.AccountId,
                                            Primary_Paid_Membership__c = membership.Id,
                                            Product__c = prog.Id);
        insert project;
        
        setupSubscriptionOptions(prog.Id);
        
        util.BypassAllTriggers = false;
        
        //create the Project Role
        Project_Role__c pRole = new Project_Role__c(Name='Test',
                                                    Project_Type__c = 'CCC',
                                                    Role__c = 'IT Lead',
                                                    Contact__c = sProfile.Contact__c,
                                                    Project__c = project.Id);
        
        insert pRole;
        test.stopTest();
        
        
        //verify an EAB site profile was auto-generated by the CreateAutoSubscriptions method
        Contact con = [SELECT Id, (SELECT Id, Type__c FROM Site_Profiles__r WHERE Type__c = :SiteUserHelper.SITE_EAB) FROM Contact WHERE Id = :sProfile.Contact__c];
        system.assertEquals(1, con.Site_Profiles__r.size(),
                           'an EAB Site Profile should have been generated due to the Project Role that was created.');
        
        // make sure we found the right subscriptions
        list<Subscription__c> subscriptions = [SELECT Id, Auto_Subscribed__c, Subscription_Id__c FROM Subscription__c WHERE Contact__c = :sProfile.Contact__c];
        system.assertEquals(1, subscriptions.size(),
                           'One subscription should have been auto-generated due to the Project Role that was created.');
        
    }
    
    /**
     * @description:    Create an Advisory site profile, add a Project Role related to a Non-PT program, and verify nothing was auto-generated because it wasn't a PT program
     * 
     */
    static testMethod void projectRole_NON_PT_AutoSubscribe() {
        
        //Bypass Dupeblocker
        Util.IsTest(true);
        
        //Bypassing Triggers so then test data can be created easily
        Util.byPassAllTriggers = true;
        
        //Flag for triggers: this is just a test, don't do crazy things.
        Util.isTesting = true;
        
        // create a contact that is also an Adv.com User
        Site_Profile__c sProfile = Test_SiteUserHelper.createSiteProfile(SiteUserHelper.SITE_Advisory, true);
        
        // get the site profile and contact info
        sProfile = [SELECT Id, User_Id__c, Contact__r.LastName, Status_Code_Description__c, Type__c, Contact__c, Contact__r.AccountId FROM Site_Profile__c WHERE Id = :sProfile.Id];
        
        // create a program
        Program__c prog = TestUtilities.CreateNewProgram(false);
        prog.Applicable_Segments__c = 'US Education';
        prog.Business_Line__c = 'ZZ';
        insert prog;
        
        Membership__c membership = new Membership__c();
        membership.Membership_Status_Text__c = 'Member - Payer';
        membership.Account_Name__c = sProfile.Contact__r.AccountId;
        membership.Program__c = prog.Id;
        membership.Name = 'test';
        insert membership;
        
        // create an opportunity and contract
        Opportunity opp = testUtilities.CreateNewOpportunity(sProfile.Contact__r.AccountId, false);
        opp.CloseDate = system.today();
        opp.stageName = 'Closed Won';
        opp.Program__c = prog.Id;
        insert opp;
        
        test.startTest();
        
        Contract__c testContract1 = new Contract__c(
            Name='Test Contract1', Payer_Account__c = sProfile.Contact__r.AccountId, Program__c = prog.Id, Source_Opportunity__c=opp.Id,
            Start__c = System.Today().addDays(-10), End__c = system.today().addDays(355),
            Contract_Renewal_Opportunity__c = opp.Id, Status__c = 'ATL', Invoicing_Arrangement__c = 'Annual', Year__c = '2012',
            Type__c = 'NBB', Years_in_Term__c = 1, Initial_Invoice_Date__c = system.today()
        );
        insert testContract1;
        
        //create project
        Project__c project = new Project__c(Name = 'Test',
                                            Institution__c = sProfile.Contact__r.AccountId,
                                            Primary_Paid_Membership__c = membership.Id,
                                            Product__c = prog.Id);
        insert project;
        
        setupSubscriptionOptions(prog.Id);
        
        //create the Project Role
        Project_Role__c pRole = new Project_Role__c(Name='Test',
                                                    Project_Type__c = 'CCC',
                                                    Role__c = 'Implementation Leader',
                                                    Contact__c = sProfile.Contact__c,
                                                    Project__c = project.Id);
        
        insert pRole;
        
        // make sure we found the right subscriptions
        list<Subscription__c> subscriptions = [SELECT Id, Auto_Subscribed__c, Subscription_Id__c FROM Subscription__c WHERE Contact__c = :sProfile.Contact__c];
        system.assertEquals(0, subscriptions.size(),
                           'No subscription should have been generated because the program is not PT.');
        
        test.stopTest();
        
        //verify an EAB site profile was auto-generated by the CreateAutoSubscriptions method
        Contact con = [SELECT Id, (SELECT Id, Type__c FROM Site_Profiles__r WHERE Type__c = :SiteUserHelper.SITE_EAB) FROM Contact WHERE Id = :sProfile.Contact__c];
        system.assertEquals(0, con.Site_Profiles__r.size(),
                           'No Site Profile should have been generated because the program is not PT.');
    }
    
    /***
     * 
     * @description: Create 40 contacts, active site profiles, site users.
     * 				 Update the email address for all 40 as another user - this should trigger the SiteUserHelper.createAccountAndContactSharing() method
     * 				 Verify that the contacts and site profiles were updated properly and 40 manual share records exist
     * 				 (created for CR-20150330-8821)
     ***/
    static testmethod void testCreateMultipleSiteProfiles() {
        
        //Bypass Dupeblocker
        Util.IsTest(true);
        
        //Bypassing Triggers so then test data can be created easily
        Util.byPassAllTriggers = true;
        
        //Flag for triggers: this is just a test, don't do crazy things.
        Util.isTesting = true;
        
        util.isTest(true);
        //determines who many records to create
        integer RECORD_COUNT = 40;
        string emailDomain = 'junkabcadvisory.com';
        util.BypassAllTriggers = true;
        //create account with eligible domain
        Account a = TestUtilities.CreateNewAccount(true);
        // create the eligible domain
        Eligible_Domain__c domain = new Eligible_Domain__c(Is_Included__c = true, Qualified_Domain__c = emailDomain, Account__c = a.Id);
        insert domain;
        //create site users
        list<Site_User__c> siteUsers = new list<Site_User__c>();
        for (integer i = 0; i < RECORD_COUNT; i++) {
            siteUsers.add(new Site_User__c());
        }
        insert siteUsers;
        //create contacts
        list<Contact> contacts = new list<Contact>();
        for (integer i = 0; i < RECORD_COUNT; i++) {
            Contact c = TestUtilities.CreateNewContact(a, false);
            c.Email = 'testContact' + i + '_' + crypto.getRandomInteger() + '@' + emailDomain;
            contacts.add(c);
        }
        insert contacts;
        //create site profiles
        list<Site_Profile__c> sProfiles = new list<Site_Profile__c>();
        for (integer i = 0; i < RECORD_COUNT; i++) {
            Contact c = contacts[i];
            Site_Profile__c sp = new Site_Profile__c(Status__c = 'Active',
                                                     Username__c = c.Email,
                                                     Password__c = 'test',
                                                     Site_User__c = siteUsers[i].Id,
                                                     Verify__c = '2',
                                                     Contact__c = c.Id,
                                                     Type__c = SiteUserHelper.SITE_ADVISORY
                                                    );
            sProfiles.add(sp);
        }
        insert sProfiles;
        
        //create a new system admin user
        Profile sysAdminProfile = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];
        User u = TestUtilities.CreateNewUser(sysAdminProfile, false);
        u.IsActive = true;
        insert u;
        
        test.startTest();
        //runas system admin
        system.runAs(u) {
            //resume triggers
            util.BypassAllTriggers = false;
            
            //update all email addresses
            for (integer i = 0; i < RECORD_COUNT; i++) {
                Contact c = contacts[i];
                c.Email = 'a' + c.Email;
            }
            update contacts;
			
			map<Id, Contact> contactMap = new map<Id, Contact>(contacts);            
            //verify sharing records were created for all records
            list<UserRecordAccess> recordAccess = [SELECT RecordId, HasEditAccess FROM UserRecordAccess 
                                                   WHERE UserId = :userInfo.getUserId() AND RecordId IN :contactMap.keySet()];
            system.assertEquals(RECORD_COUNT, recordAccess.size());
        }
        test.stopTest();
    }
    
    /***
     * 
     * @description: Create 100 contacts, active site profiles, site users.
     * 				 Update the email address for all contacts - this should trigger the SiteUserHelper.createAccountAndContactSharing() method but no contact sharing should be added.
     * 				 Verify that the contacts and site profiles were updated properly.
     * 				 (created for CR-20150330-8821)
     ***/
    static testmethod void testCreateMultipleSiteProfiles_noSharing() {
        
        //Bypass Dupeblocker
        Util.IsTest(true);
        
        //Bypassing Triggers so then test data can be created easily
        Util.byPassAllTriggers = true;
        
        //Flag for triggers: this is just a test, don't do crazy things.
        Util.isTesting = true;
        
        util.isTest(true);
        //determines who many records to create
        integer RECORD_COUNT = 100;
        string emailDomain = 'junkabcadvisory.com';
        util.BypassAllTriggers = true;
        //create account with eligible domain
        Account a = TestUtilities.CreateNewAccount(true);
        // create the eligible domain
        Eligible_Domain__c domain = new Eligible_Domain__c(Is_Included__c = true, Qualified_Domain__c = emailDomain, Account__c = a.Id);
        insert domain;
        //create site users
        list<Site_User__c> siteUsers = new list<Site_User__c>();
        for (integer i = 0; i < RECORD_COUNT; i++) {
            siteUsers.add(new Site_User__c());
        }
        insert siteUsers;
        //create contacts
        list<Contact> contacts = new list<Contact>();
        for (integer i = 0; i < RECORD_COUNT; i++) {
            Contact c = TestUtilities.CreateNewContact(a, false);
            c.Email = 'testContact' + i + '_' + crypto.getRandomInteger() + '@' + emailDomain;
            contacts.add(c);
        }
        insert contacts;
        Contact co = [SELECT Id, OwnerId FROM Contact WHERE Id = :contacts[0].Id];
        system.assertEquals(userinfo.getUserId(), co.OwnerId);
        //create site profiles
        list<Site_Profile__c> sProfiles = new list<Site_Profile__c>();
        for (integer i = 0; i < RECORD_COUNT; i++) {
            Contact c = contacts[i];
            Site_Profile__c sp = new Site_Profile__c(Status__c = 'Active',
                                                     Username__c = c.Email,
                                                     Password__c = 'test',
                                                     Site_User__c = siteUsers[i].Id,
                                                     Verify__c = '2',
                                                     Contact__c = c.Id,
                                                     Type__c = SiteUserHelper.SITE_ADVISORY
                                                    );
            sProfiles.add(sp);
        }
        insert sProfiles;
        
        
        
        test.startTest();
        //resume triggers
        util.BypassAllTriggers = false;
        
        //update all email addresses
        for (integer i = 0; i < RECORD_COUNT; i++) {
            Contact c = contacts[i];
            c.Email = 'a' + c.Email;
        }
        update contacts;
        
        map<Id, Contact> contactMap = new map<Id, Contact>(contacts);            
        //verify sharing records were created for all records
        list<UserRecordAccess> recordAccess = [SELECT RecordId, HasEditAccess FROM UserRecordAccess 
                                               WHERE UserId = :userInfo.getUserId() AND RecordId = :a.Id];
        system.assertEquals(1, recordAccess.size());
        test.stopTest();
    }
    
    /**
     * @description:    create a membership key contact on an institution that is a US Higher Ed record type
     *                  This should create a new site profile.
     * 
     **
    static testmethod void testAction_CreateKeyContact_HigherEd() {
        // create a contact on a different institution
        Contact contact = CreateSiteUserContact(false);
        contact.Create_Advisory_com_User_Account__c = false;
        
        contact.Advisory_com_Preferred_Email_Address__c = null;
        contact.Advisory_com_Uncheck_Domain__c = false;
        contact.Email = 'hansonv@BadDomain.com';
        insert contact;
        // set the account record type
        Account acct = [SELECT Id, RecordTypeId FROM Account WHERE Id = :contact.AccountId];
        acct.RecordTypeId = Util.RecordTypeId('Account', 'US Education');
        update acct;
        // create a program
        Program__c prog = TestUtilities.CreateNewProgram(true);
        // create a membership
        Membership__c membership = TestUtilities.CreateNewMembership(contact.AccountId, prog.Id, true);
        
        Test.startTest();
            Membership_Key_Contact__c membershipKeyContact = new Membership_Key_Contact__c(
                Contact__c = contact.id,
                Name='Test',
                Membership__c = membership.Id);
            insert membershipKeyContact;
        Test.stopTest();
        
        // get the contact and verify the Create Adv.com User flag is un-checked
        contact = [SELECT Id, Create_Advisory_com_User_Account__c FROM Contact WHERE Id = :contact.Id];
        system.assertEquals(false, contact.Create_Advisory_com_User_Account__c);
        
        // get the membership key contact and make sure it was created successfully
        List<Membership_Key_Contact__c> keyContacts = [SELECT Id FROM Membership_Key_Contact__c WHERE Id = :membershipKeyContact.Id];
        system.assertEquals(1, keyContacts.size());
    }
    
    static testmethod void testAction_Register_Employee() {
        // setup an account and contact
        Account acct = TestUtilities.CreateNewAccount(true);
        Eligible_Domain__c domain = new Eligible_Domain__c(Is_Included__c = true, Qualified_Domain__c = SiteUserHelper.SITE_ADVISORY, Account__c = acct.Id);
        insert domain;
        // create a new employee contact
        Id employeeContactRTId = Util.RecordTypeId('Contact', 'Employee');
        Contact contact = TestUtilities.CreateNewContact(acct, false);
        contact.RecordTypeId = employeeContactRTId;
        contact.Email = 'employee@advisory.com';
        contact.Create_Advisory_com_User_Account__c = false;
        insert contact;
        
        // set the page reference
        PageReference pageRef = Page.AdvisorySite;
        Test.setCurrentPage(pageRef);
        
        // get historical_Linker
        acct = [SELECT Id, Historical_Linker__c, Advisory_com_Organization_id__c FROM Account WHERE Id = :acct.Id];
        
        // generate the request
        String origData = '{"Email_Address":"employee@advisory.com","Email_Address2":"",' +
            '"Organization_Id":"' + acct.Advisory_com_Organization_id__c + '",' +
            '"Password":"test","ClientId":"' + acct.Historical_Linker__c + '","Prefix":"Mr","First_Name":"Victor","Country":"USA","Last_Name":"Hanson","Middle_Initial":"R","Suffix":"","Job_Function":"Developer",' +
            '"Title":"SF Dev","Department":"IS","Modified_By":"","Modified_Date":"",' +
            '"Command":"register","Office_Phone":"555-555-5655"}';
        blob blobData = blob.valueOf(origData);
        blob encryptedBlob = Crypto.encryptWithManagedIV('AES256', SiteControllerHelper.KEY, blobData);
        String encryptedString = EncodingUtil.base64Encode(encryptedBlob);
        // Add parameters to page URL 
        ApexPages.currentPage().getParameters().put('req', encryptedString);
        
        test.startTest();
        SiteController controller = new SiteController();
        controller.initialize();
        test.stopTest();
        
        // get the response
        String decryptedJSONResponse = EncryptionHelper.decrypt(EncodingUtil.base64Decode(controller.JSONResponse));
        SiteUser sUser = EncryptionHelper.deserializeSiteUser(decryptedJSONResponse);
        
        system.assertEquals(true, decryptedJSONResponse.toLowerCase().contains('success'));
        system.assertEquals(true, decryptedJSONResponse.contains('5655'));
        
        // get make sure the contact didn't get inserted with a bad domain
        Contact updatedContact = [SELECT Name, Id, Advisory_com_Email_Address__c, RecordTypeId, Create_Advisory_com_User_Account__c, Advisory_com_Password_Reset_Token__c FROM Contact WHERE Id = :contact.Id];
        
        system.assertEquals(updatedContact.Id, sUser.UniqueId);
        
        // verify the contact was updated properly
        system.assertEquals(true, updatedContact.Create_Advisory_com_User_Account__c);
        // verify the record type remains employee
        system.assertEquals(employeeContactRTId, updatedContact.RecordTypeId);
        system.assertNotEquals(null, updatedContact.Advisory_com_Password_Reset_Token__c);
        
    }
    
    /*
    static testmethod void testAction_Register_AlreadyRegisteredWithDupe() {
        List<Contact> cons = new List<Contact>();
        // create a contact on a different institution
        Contact dupeContact = CreateSiteUserContact(false);
        dupeContact.Create_Advisory_com_User_Account__c = false;
        dupeContact.Email = 'hansonv@advisory.com';
        cons.add(dupeContact);
        // create another contact on that account with the same email
        Contact dupeContact2 = CreateSiteUserContact(false);
        dupeContact2.Email = 'hansonv@advisory.com';
        dupeContact2.AccountId = dupeContact.AccountId;
        dupeContact2.Create_Advisory_com_User_Account__c = true;
        cons.add(dupeContact2);
        insert cons;
        
        // get the account's historical linker
        Account acct = [SELECT Id, Historical_Linker__c FROM Account WHERE ID = :dupeContact2.AccountId];
        
        
        // set the page reference
        PageReference pageRef = Page.AdvisorySite;
        Test.setCurrentPage(pageRef);
        
        // get historical_Linker
        acct = [SELECT Id, Historical_Linker__c FROM Account WHERE Id = :acct.Id];
        
        // generate the request
        String origData = '{"Email_Address":"hansonv@advisory.com","Email_Address2":"victor.r.hanson@gmail.com",' +
            '"Password":"test","ClientId":"' + acct.Historical_Linker__c + '","Prefix":"Mr","First_Name":"Victor","Country":"USA","Last_Name":"Hanson","Middle_Initial":"R","Suffix":"","Job_Function":"Developer",' +
            '"Title":"SF Dev","Department":"IS","Modified_By":"","Modified_Date":"",' +
            '"Command":"register","Office_Phone":"555-555-5655"}';
        blob blobData = blob.valueOf(origData);
        blob encryptedBlob = Crypto.encryptWithManagedIV('AES256', SiteControllerHelper.KEY, blobData);
        String encryptedString = EncodingUtil.base64Encode(encryptedBlob);
        // Add parameters to page URL 
        ApexPages.currentPage().getParameters().put('req', encryptedString);
        
        test.startTest();
        // controller
        SiteController controller = new SiteController();
        controller.initialize();
        test.stopTest();
        // get the response
        String decryptedJSONResponse = EncryptionHelper.decrypt(EncodingUtil.base64Decode(controller.JSONResponse));
        
        SiteUser sUser = EncryptionHelper.deserializeSiteUser(decryptedJSONResponse);
        
        system.assertNotEquals(true, decryptedJSONResponse.toLowerCase().contains('success'));
        system.debug('@@DecryptedResponse::::' + decryptedJSONResponse.toLowerCase());
       // system.assertEquals(true, decryptedJSONResponse.contains('5655'));
        
        // get make sure the contact didn't get inserted with a bad domain
        List<Contact> updatedContacts = [SELECT Name, Id, Advisory_com_Email_Address__c, Advisory_com_Email_Address2__c, Advisory_com_Password_Reset_Token__c FROM Contact WHERE Email = 'hansonv@advisory.com' ORDER BY Create_Advisory_com_User_Account__c DESC];
        
        // verify the proper error message was returned
        system.assertEquals(true, decryptedJSONResponse.toLowerCase().contains(advUtils.ERROR_EXISTING_ACTIVE_USER.ToLowerCase()));
        
    }
    
    static testmethod void testAction_Register_Dupe_FirstLastInst() {
        List<Contact> cons = new List<Contact>();
        // create a contact on a different institution
        Contact dupeContact = CreateSiteUserContact(false);
        dupeContact.Create_Advisory_com_User_Account__c = false;
        dupeContact.FirstName = 'Sam';
        dupeContact.LastName = 'Smith';
        dupeContact.Email = 'UniqueEmail1@advisory.com';
        cons.add(dupeContact);
        // create another contact on that account with the same email
        Contact dupeContact2 = CreateSiteUserContact(false);
        dupeContact.FirstName = 'Sam';
        dupeContact.LastName = 'Smith';
        dupeContact2.Email = 'hansonv@advisory.com';
        dupeContact2.AccountId = dupeContact.AccountId;
        dupeContact2.Create_Advisory_com_User_Account__c = true;
        cons.add(dupeContact2);
        insert cons;
        
        // get the account's historical linker
        Account acct = [SELECT Id, Historical_Linker__c FROM Account WHERE ID = :dupeContact2.AccountId];
        
        
        // set the page reference
        PageReference pageRef = Page.AdvisorySite;
        Test.setCurrentPage(pageRef);
        
        // get historical_Linker
        acct = [SELECT Id, Historical_Linker__c FROM Account WHERE Id = :acct.Id];
        
        // generate the request
        String origData = '{"Email_Address":"hansonv@advisory.com","Email_Address2":"victor.r.hanson@gmail.com",' +
            '"Password":"test","ClientId":"' + acct.Historical_Linker__c + '","Prefix":"Mr","First_Name":"Victor","Country":"USA","Last_Name":"Hanson","Middle_Initial":"R","Suffix":"","Job_Function":"Developer",' +
            '"Title":"SF Dev","Department":"IS","Modified_By":"","Modified_Date":"",' +
            '"Command":"register","Office_Phone":"555-555-5655"}';
        blob blobData = blob.valueOf(origData);
        blob encryptedBlob = Crypto.encryptWithManagedIV('AES256', SiteControllerHelper.KEY, blobData);
        String encryptedString = EncodingUtil.base64Encode(encryptedBlob);
        // Add parameters to page URL 
        ApexPages.currentPage().getParameters().put('req', encryptedString);
        
        test.startTest();
        // controller
        SiteController controller = new SiteController();
        controller.initialize();
        test.stopTest();
        // get the response
        String decryptedJSONResponse = EncryptionHelper.decrypt(EncodingUtil.base64Decode(controller.JSONResponse));
        
        SiteUser sUser = EncryptionHelper.deserializeSiteUser(decryptedJSONResponse);
        
        system.assertNotEquals(true, decryptedJSONResponse.toLowerCase().contains('success'));
        system.debug('@@DecryptedResponse::::' + decryptedJSONResponse.toLowerCase());
       // system.assertEquals(true, decryptedJSONResponse.contains('5655'));
        
        // get make sure the contact didn't get inserted with a bad domain
        List<Contact> updatedContacts = [SELECT Name, Id, Advisory_com_Email_Address__c, Advisory_com_Email_Address2__c, Advisory_com_Password_Reset_Token__c FROM Contact WHERE Email = 'hansonv@advisory.com' ORDER BY Create_Advisory_com_User_Account__c DESC];
        
        // verify the proper error message was returned
        system.assertEquals(true, decryptedJSONResponse.toLowerCase().contains(advUtils.ERROR_EXISTING_ACTIVE_USER.ToLowerCase()));
        
    }
    
    
    
    static testmethod void testAction_Register_ExternalRT() {
        // setup an account and contact
        Account acct = TestUtilities.CreateNewAccount(true);
        Eligible_Domain__c domain = new Eligible_Domain__c(Is_Included__c = true, Qualified_Domain__c = SiteUserHelper.SITE_ADVISORY, Account__c = acct.Id);
        insert domain;
        // create a new employee contact
        Id externalContactRTId = Util.RecordTypeId('Contact', 'External');
        Id externalAdvComContactRTId = Util.RecordTypeId('Contact', 'External - Advisory.com User');
        Contact contact = TestUtilities.CreateNewContact(acct, false);
        contact.RecordTypeId = externalContactRTId;
        contact.Email = 'member@advisory.com';
        contact.Create_Advisory_com_User_Account__c = false;
        insert contact;
        
        // set the page reference
        PageReference pageRef = Page.AdvisorySite;
        Test.setCurrentPage(pageRef);
        
        // get historical_Linker
        acct = [SELECT Id, Historical_Linker__c, Advisory_com_Organization_id__c FROM Account WHERE Id = :acct.Id];
        
        // generate the request
        String origData = '{"Email_Address":"member@advisory.com","Email_Address2":"",' +
            '"Organization_Id":"' + acct.Advisory_com_Organization_id__c + '",' +
            '"Password":"test","ClientId":"' + acct.Historical_Linker__c + '","Prefix":"Mr","First_Name":"Victor","Country":"USA","Last_Name":"Hanson","Middle_Initial":"R","Suffix":"","Job_Function":"Developer",' +
            '"Title":"SF Dev","Department":"IS","Modified_By":"","Modified_Date":"",' +
            '"Command":"register","Office_Phone":"555-555-5655"}';
        blob blobData = blob.valueOf(origData);
        blob encryptedBlob = Crypto.encryptWithManagedIV('AES256', SiteControllerHelper.KEY, blobData);
        String encryptedString = EncodingUtil.base64Encode(encryptedBlob);
        // Add parameters to page URL 
        ApexPages.currentPage().getParameters().put('req', encryptedString);
        
        test.startTest();
        SiteController controller = new SiteController();
        controller.initialize();
        test.stopTest();
        
        // get the response
        String decryptedJSONResponse = EncryptionHelper.decrypt(EncodingUtil.base64Decode(controller.JSONResponse));
        SiteUser sUser = EncryptionHelper.deserializeSiteUser(decryptedJSONResponse);
        
        system.assertEquals(true, decryptedJSONResponse.toLowerCase().contains('success'));
        system.assertEquals(true, decryptedJSONResponse.contains('5655'));
        
        // get make sure the contact didn't get inserted with a bad domain
        Contact updatedContact = [SELECT Name, Id, Advisory_com_Email_Address__c, RecordTypeId, Create_Advisory_com_User_Account__c, Advisory_com_Password_Reset_Token__c FROM Contact WHERE Id = :contact.Id];
        
        system.assertEquals(updatedContact.Id, sUser.UniqueId);
        
        // verify the contact was updated properly
        system.assertEquals(true, updatedContact.Create_Advisory_com_User_Account__c);
        // verify the record type remains employee
        system.assertEquals(externalAdvComContactRTId, updatedContact.RecordTypeId);
        system.assertNotEquals(null, updatedContact.Advisory_com_Password_Reset_Token__c);
        
    }
    **/
     
    static testMethod void test_CreateNewUser() {
        
        //Bypass Dupeblocker
        Util.IsTest(true);
        
        //Bypassing Triggers so then test data can be created easily
        Util.byPassAllTriggers = true;
        
        //Flag for triggers: this is just a test, don't do crazy things.
        Util.isTesting = true;
        
    	Util.IsTest(true);
		// create an new account
		Account newAccount = TestUtilities.CreateNewAccount(true);
        Eligible_Domain__c domain = new Eligible_Domain__c(Is_Included__c = true, Qualified_Domain__c = 'advisory.com', Account__c = newAccount.Id);
        insert domain;
		// generate the request
        SiteUser sUser_Advisory = new SiteUser();
        sUser_Advisory.Site = SiteUserHelper.SITE_ADVISORY;
        sUser_Advisory.Email_Address = 'hansonv@advisory.com';
        sUser_Advisory.Email_Address2 = 'hansonv@zzzzz.com';
        sUser_Advisory.Organization_Id = integer.valueOf(newAccount.Advisory_com_Organization_id__c);
        sUser_Advisory.Password = 'test';
        //  sUser_Advisory.ClientId = acct.Historical_Linker__c;
        sUser_Advisory.Prefix = 'Mr';
        sUser_Advisory.Country = 'USA';
        sUser_Advisory.First_Name = 'Victor';
        sUser_Advisory.Last_Name = 'Hanson';
        sUser_Advisory.Middle_Initial = 'R';
        sUser_Advisory.Suffix = '';
        sUser_Advisory.Job_Function = 'Developer';
        sUser_Advisory.Title = 'SF Dev';
        sUser_Advisory.Department = 'eTech';
        sUser_Advisory.Command = 'register';
        sUser_Advisory.Office_Phone = '555-555-5655';
		test.startTest();
		// update the sUser
		sUser_Advisory = SiteUserHelper.Action_Register(sUser_Advisory);
        System.assertEquals('Success', sUser_Advisory.response);
		test.stopTest();
        List<Contact> cons = [SELECT Id, Owner.Name FROM Contact WHERE AccountId = :newAccount.Id];
		System.assertEquals(1, cons.size());
        System.debug('Owner Name: ' + cons[0].Owner.Name);
		System.assertEquals('Salesforce Administrator', cons[0].Owner.Name);
    }   
}