/**
Desription      :   

Created By      :   Victor Hanson

Created Date    :   07/29/2014

Revision Logs   :   v1.1 - Created
					v1.2 - Modified By - Abhinav Sharma - 09/10/2016 - In order to fix "Too Many SOQL 101 error in it"
**/ 
@isTest
private class Test_SiteController {
	
    //Modified By - Abhinav Sharma - 09/10/2016 - In order to fix "Too Many SOQL 101 error in it"
    /**
     * @description: 	Step 1: Create a Contact, Site User, and Site Profile with eligible domain for Advisory.com & EAB.com.
     * 					Step 2: Execute the 'search' command on the Site_Json VF Page
     * 					Step 3: Verify that the contact is returned
     **/
    static testmethod void testSearchSiteProfiles() {
        
        //Bypass Dupeblocker
        Util.IsTest(true);
        
        //Bypassing Triggers so then test data can be created easily
        Util.byPassAllTriggers = true;
        
        //Flag for triggers: this is just a test, don't do crazy things.
        Util.isTesting = true;
        
        // setup an account and contact
        Account acct = Test_SiteUserHelper.createNewAccount(true);
        
        //Site Profile
        Site_Profile__c sProfile = Test_SiteUserHelper.createSiteProfile(acct, SiteUserHelper.SITE_EAB, true);
        
        // set the page reference
        PageReference pageRef = Page.Site_JSON;
        Test.setCurrentPage(pageRef);
        
        // get the site profile's contact
        Contact c = [SELECT Id, FirstName, LastName, Email, Primary_City__c, Primary_State_Province__c, Primary_Country__c FROM Contact WHERE Id = :sProfile.Contact__c];
        
        //get the site profile's user id
        sProfile = [SELECT Id, User_Id__c, Type__c FROM Site_Profile__c WHERE Id = :sProfile.Id];
        
        // generate the request
        SiteUser sUser = new SiteUser();
        sUser.Email_Address = c.Email;
        sUser.First_Name = c.FirstName;
        sUser.Last_Name = c.LastName;
        sUser.City = c.Primary_City__c;
        sUser.State = c.Primary_State_Province__c;
        sUser.Country = c.Primary_Country__c;
        sUser.User_Id = Integer.valueOf(sProfile.User_Id__c);
        sUser.Command = 'search';
        sUser.Site = SiteUserHelper.SITE_EAB;
        
        // search for non-inactive site profiles (ie: status = active, in progress, hard bounce)
        sUser.User_Status = 'non-inactive';
        
        //Serailizing site user instance
        string origData = JSON.serialize(sUser);
        blob encryptedBlob = Crypto.encryptWithManagedIV('AES256', SiteControllerHelper.KEY, blob.valueOf(origData));
        String encryptedString = EncodingUtil.base64Encode(encryptedBlob);
        
        //Start test from here
        Test.startTest();
        
        // Add parameters to page URL 
        ApexPages.currentPage().getParameters().put('req', encryptedString);
        
        // controller
        SiteController controller = new SiteController();
        controller.initialize();
        
        // get the response
        system.debug('@@controller.JSONResponseDecrypted:' + EncryptionHelper.decrypt(EncodingUtil.base64Decode(controller.JSONResponse)));
        String decryptedJSONResponse = EncryptionHelper.decrypt(EncodingUtil.base64Decode(controller.JSONResponse));
        sUser = EncryptionHelper.deserializeSiteUser(decryptedJSONResponse);
        
        //Asserting for the results
        system.assertEquals(c.Id, sUser.site_Profiles[0].Contact__c);
        system.assertEquals(4, controller.categoryToDisplayName.size());
        
        //Start test from here
        Test.stopTest();
    }
    
    //Modified By - Abhinav Sharma - 09/10/2016 - In order to fix "Too Many SOQL 101 error in it"
    /**
     * @description: 	Step 1: Create an Institution, Contact, Site User, and Site Profile with eligible domain for Advisory.com & EAB.com.
     * 					Step 2: Execute the 'SearchOrganization' command on the SiteProfileSearch VF Page
     * 					Step 3: Verify the correct institution was returned
     **/
    static testMethod void testSearchInstitution() {
        
        //Bypass Dupeblocker
        Util.IsTest(true);
        
        //Bypassing Triggers so then test data can be created easily
        Util.byPassAllTriggers = true;
        
        //Flag for triggers: this is just a test, don't do crazy things.
        Util.isTesting = true;
        
        // create a new institution with state "OH"
        Account acct = Test_SiteUserHelper.CreateNewAccount(false);
        acct.Primary_State_Province__c = 'OH';
        insert acct;
        
        // create a siteUser
        Site_Profile__c sProfile = Test_SiteUserHelper.createSiteProfile(acct, SiteUserHelper.SITE_EAB, true);
        
        //create the search string
        String searchString = '{"Command":"SearchOrganization","State":"OH"}';
        String encryptedSearchString = EncryptionHelper.EncryptString(searchString);
        
        //Start testing from here
        Test.startTest();
        
        // set the page reference
        PageReference pageRef = Page.SiteProfileSearch;
        Test.setCurrentPage(pageRef);
        
        // Add parameters to page URL 
        ApexPages.currentPage().getParameters().put('req', encryptedSearchString);
        
        // instantiate the controller
        Sitecontroller controller = new Sitecontroller();
        
        // make sure we found the right contact
        system.assertEquals(1, controller.sUser.Institutions.size());
        system.assertEquals('OH', controller.sUser.Institutions[0].Primary_State_Province__c);
        
        //Stop test here
        Test.stopTest();
    }
    
    //Modified By - Abhinav Sharma - 09/10/2016 - In order to fix "Too Many SOQL 101 error in it"
    /**
     * @description: 	Step 1: Create an Institution, Contact, Site User, and Site Profile with eligible domain for Advisory.com & EAB.com.
     * 					Step 2: Execute the 'SearchOrganization' command on the SiteProfileSearch VF Page
     * 					Step 3: Verify the correct institution was returned
     **/
    static testMethod void testSearchInstitution_Contacts() {
        
        //Bypass Dupeblocker
        Util.IsTest(true);
        
        //Bypassing Triggers so then test data can be created easily
        Util.byPassAllTriggers = true;
        
        //Flag for triggers: this is just a test, don't do crazy things.
        Util.isTesting = true;
        
        // create a new institution with state "OH"
        Account acct = Test_SiteUserHelper.CreateNewAccount(false);
        acct.Primary_State_Province__c = 'OH';
        insert acct;
        
        // create a siteUser
        Site_Profile__c sProfile = Test_SiteUserHelper.createSiteProfile(acct, SiteUserHelper.SITE_EAB, true);
        
        //create the search string
        String searchString = '{"Command":"SearchOrganization","State":"OH"}';
        String encryptedSearchString = EncryptionHelper.EncryptString(searchString);
        
        //Start test from here
        Test.startTest();
        
        // set the page reference
        PageReference pageRef = Page.AdvisorySite;
        Test.setCurrentPage(pageRef);
        
        // Add parameters to page URL 
        ApexPages.currentPage().getParameters().put('req', encryptedSearchString);
        
        // instantiate the controller
        Sitecontroller controller = new Sitecontroller();
        
        // set the institution id
        controller.InstitutionId = string.valueOf(acct.Id);
        controller.FindInstitutionContacts();
        
        // make sure we found the contact
        system.assertEquals(1, controller.sUser.ContactWrappers.size());
        
        //Stop test here
        Test.stopTest();
    }
    
    //Modified By - Abhinav Sharma - 09/10/2016 - In order to fix "Too Many SOQL 101 error in it"
	/**
     * @description: 	Step 1: Create an Institution, Contact, Site User, and Site Profile with eligible domain for Advisory.com & EAB.com.
     * 					Step 2: Execute the '' command on the SiteProfileSearch VF Page
     * 					Step 3: Verify the 
     **/
    static testMethod void testAdvAdmin_GeneralInfo() {
        
        //Bypass Dupeblocker
        Util.IsTest(true);
        
        //Bypassing Triggers so then test data can be created easily
        Util.byPassAllTriggers = true;
        
        //Flag for triggers: this is just a test, don't do crazy things.
        Util.isTesting = true;
        
        // create a contact that is also an Adv.com User
        Site_Profile__c sProfile = Test_SiteUserHelper.createSiteProfile(SiteUserHelper.SITE_EAB, true);
        
        // get the site profile and contact info
        sProfile = [SELECT Id, User_Id__c, Contact__r.LastName, Status_Code_Description__c 
                    	FROM Site_Profile__c WHERE Id = :sProfile.Id];
        
        //create the search string
        String searchString = '{"Command":"UserDetails","User_Id":"' + sProfile.User_Id__c + '"}';
        String encryptedSearchString = EncryptionHelper.EncryptString(searchString);
        
        //Start test from here
        Test.startTest();
        
        // set the page reference
        PageReference pageRef = Page.SiteProfileInfo;
        Test.setCurrentPage(pageRef);
        
        // Add parameters to page URL 
        ApexPages.currentPage().getParameters().put('req', encryptedSearchString);
        
        // instantiate the controller
        Sitecontroller controller = new Sitecontroller();
        
        // make sure we found the right contact
        system.assertEquals(sProfile.Contact__r.LastName, controller.MainContact.Con.LastName);
        system.assertEquals(sProfile.Status_Code_Description__c, controller.sUser.Site_Profile.Status_Code_Description__c);
        
        //Stop test here
        Test.stopTest();
    }
    
    //Modified By - Abhinav Sharma - 09/10/2016 - In order to fix "Too Many SOQL 101 error in it"
    /**
     * @description:	step 1) Create an EAB Site Profile
     * 					step 2) Create a Program where Applicable Segment contains "Education" - this ensures it is picked up as an EAB Program
     * 					step 3) Create an active membership and associate that to the EAB program
     * 					step 4) Create Subscription Options and Eligible Subscription Options related to the EAB Program and Subscription Option
     * 					step 5) Instantiate the controller and pass an encrypted string containing the userDetail command + user Id
     * 					step 6) Verify the eligible subscription options are present.
     * 
     **/
    static testMethod void testSiteProfileManageSubscriptions_EligibleSubOptions_SiteProfile() {
        
        //Bypass Dupeblocker
        Util.IsTest(true);
        
        //Bypassing Triggers so then test data can be created easily
        Util.byPassAllTriggers = true;
        
        //Flag for triggers: this is just a test, don't do crazy things.
        Util.isTesting = true;
        
        // create a contact that is also an Adv.com User
        Site_Profile__c sProfile = Test_SiteUserHelper.createSiteProfile(SiteUserHelper.SITE_EAB, true);
        
        // get the site profile and contact info
        sProfile = [SELECT Id, User_Id__c, Contact__r.LastName, Status_Code_Description__c, 
                    	Type__c, Contact__r.AccountId FROM Site_Profile__c WHERE Id = :sProfile.Id];
        
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
        
        //Contract
        Contract__c testContract1 = new Contract__c(
            Name='Test Contract1', Payer_Account__c = sProfile.Contact__r.AccountId, Program__c = prog.Id, Source_Opportunity__c=opp.Id,
            Start__c = System.Today().addDays(-10), End__c = system.today().addDays(355),
            Contract_Renewal_Opportunity__c = opp.Id, Status__c = 'ATL', Invoicing_Arrangement__c = 'Annual', Year__c = '2012',
            Type__c = 'NBB', Years_in_Term__c = 1, Initial_Invoice_Date__c = system.today()
            );
        insert testContract1;
        
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
        eligibleSub_EMAIL_WATCH.Program__c = prog.Id;
        eligibleSub_EMAIL_WATCH.Related_Subscription__c = subOption_EMAIL_WATCH.Id;
        eligibleSubList.add(eligibleSub_EMAIL_WATCH);
        
        Eligible_Subscription_Option__c eligibleSub_EMAIL_DAILY = new Eligible_Subscription_Option__c();
        eligibleSub_EMAIL_DAILY.Program__c = prog.Id;
        eligibleSub_EMAIL_DAILY.Related_Subscription__c = subOption_EMAIL_DAILY.Id;
        eligibleSubList.add(eligibleSub_EMAIL_DAILY);
        
        Eligible_Subscription_Option__c eligibleSub_EMAIL_BLOG = new Eligible_Subscription_Option__c();
        eligibleSub_EMAIL_BLOG.Program__c = prog.Id;
        eligibleSub_EMAIL_BLOG.Related_Subscription__c = subOption_EMAIL_BLOG.Id;
        eligibleSubList.add(eligibleSub_EMAIL_BLOG);
        
        Eligible_Subscription_Option__c eligibleSub_EMAIL_TOPICS = new Eligible_Subscription_Option__c();
        eligibleSub_EMAIL_TOPICS.Program__c = prog.Id;
        eligibleSub_EMAIL_TOPICS.Related_Subscription__c = subOption_EMAIL_TOPICS.Id;
        eligibleSubList.add(eligibleSub_EMAIL_TOPICS);
        insert eligibleSubList;
        
        //create the search string
        String searchString = '{"Command":"UserDetails","User_Id":"' + sProfile.User_Id__c + '"}';
        String encryptedSearchString = EncryptionHelper.EncryptString(searchString);
        
        // set the page reference
        PageReference pageRef = Page.SiteProfileManageSubscriptions;
        
        // Add the encrypted request parameter to page URL 
        pageRef.getParameters().put('req', encryptedSearchString);
        Test.setCurrentPage(pageRef);
        
        // instantiate the controller
        Sitecontroller controller = new Sitecontroller();
        
        // make sure we found the right subscriptions
        system.assertEquals(4, controller.MainContact.mapTypeToSubscriptionList_EAB.size());
        system.assertEquals(1, controller.MainContact.mapTypeToSubscriptionList_EAB.get('EMAIL_DAILY').size());
        system.assertEquals(1, controller.MainContact.mapTypeToSubscriptionList_EAB.get('EMAIL_TOPICS').size());
        system.assertEquals(1, controller.MainContact.mapTypeToSubscriptionList_EAB.get('EMAIL_WATCH').size());
        system.assertEquals(1, controller.MainContact.mapTypeToSubscriptionList_EAB.get('EMAIL_BLOG').size());
        system.assertEquals(false, controller.isGuestUser);
        system.assertEquals(0, controller.countAdvisorySubscriptions);
        system.assertEquals(4, controller.countEABSubscriptions);
        
        //Stop test here
        test.stopTest();
    }
    
    //Modified By - Abhinav Sharma - 09/10/2016 - In order to fix "Too Many SOQL 101 error in it"
    /**
     * @description:	step 1) Create an Advisory Site Profile
     * 					step 2) Create a Program where Applicable Segment does not contains "Education" - this ensures it is picked up as an Advisory Program
     * 					step 3) Create an active membership and associate that to the Advisory program
     * 					step 4) Create Subscription Options and Eligible Subscription Options related to the Advisory Program and Subscription Option
     * 					step 5) Instantiate the controller and pass an encrypted string containing the userDetail command + user Id
     * 					step 6) Verify the eligible subscription options are present.
     * 
     **/
    static testMethod void testSiteProfileManageSubscriptions_Contact() {
        
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
        prog.Applicable_Segments__c = 'US Institution';
        insert prog;
        
        //membership
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
        
        // new subscription option
        List<Subscription_Option__c> subscriptionList = new List<Subscription_Option__c>();
        Subscription_Option__c subOption_EMAIL_WATCH = new Subscription_Option__c();
        subOption_EMAIL_WATCH.Subscription_Status__c = 'Active';
        subOption_EMAIL_WATCH.Subscription_Category__c = 'EMAIL_WATCH';
        subOption_EMAIL_WATCH.Name = 'Oncology Roundtable';
        subscriptionList.add(subOption_EMAIL_WATCH);
        
        Subscription_Option__c subOption_EMAIL_DAILY = new Subscription_Option__c();
        subOption_EMAIL_DAILY.Subscription_Status__c = 'Active';
        subOption_EMAIL_DAILY.Subscription_Category__c = 'EMAIL_DAILY';
        subOption_EMAIL_DAILY.Name = 'Clinical Advantage';
        subscriptionList.add(subOption_EMAIL_DAILY);
        
        Subscription_Option__c subOption_EMAIL_BLOG = new Subscription_Option__c();
        subOption_EMAIL_BLOG.Subscription_Status__c = 'Active';
        subOption_EMAIL_BLOG.Subscription_Category__c = 'EMAIL_BLOG';
        subOption_EMAIL_BLOG.Name = 'Email_Blog';
        subscriptionList.add(subOption_EMAIL_BLOG);
        
        Subscription_Option__c subOption_EMAIL_TOPICS = new Subscription_Option__c();
        subOption_EMAIL_TOPICS.Subscription_Status__c = 'Active';
        subOption_EMAIL_TOPICS.Subscription_Category__c = 'EMAIL_TOPICS';
        subOption_EMAIL_TOPICS.Name = 'Email_Topic';
        subscriptionList.add(subOption_EMAIL_TOPICS);
        
        insert subscriptionList;
        // new eligible subscription option
        List<Eligible_Subscription_Option__c> eligibleSubList = new List<Eligible_Subscription_Option__c>();
        Eligible_Subscription_Option__c eligibleSub_EMAIL_WATCH = new Eligible_Subscription_Option__c();
        eligibleSub_EMAIL_WATCH.Program__c = prog.Id;
        eligibleSub_EMAIL_WATCH.Related_Subscription__c = subOption_EMAIL_WATCH.Id;
        eligibleSubList.add(eligibleSub_EMAIL_WATCH);
        
        Eligible_Subscription_Option__c eligibleSub_EMAIL_DAILY = new Eligible_Subscription_Option__c();
        eligibleSub_EMAIL_DAILY.Program__c = prog.Id;
        eligibleSub_EMAIL_DAILY.Related_Subscription__c = subOption_EMAIL_DAILY.Id;
        eligibleSubList.add(eligibleSub_EMAIL_DAILY);
        
        Eligible_Subscription_Option__c eligibleSub_EMAIL_BLOG = new Eligible_Subscription_Option__c();
        eligibleSub_EMAIL_BLOG.Program__c = prog.Id;
        eligibleSub_EMAIL_BLOG.Related_Subscription__c = subOption_EMAIL_BLOG.Id;
        eligibleSubList.add(eligibleSub_EMAIL_BLOG);
        
        Eligible_Subscription_Option__c eligibleSub_EMAIL_TOPICS = new Eligible_Subscription_Option__c();
        eligibleSub_EMAIL_TOPICS.Program__c = prog.Id;
        eligibleSub_EMAIL_TOPICS.Related_Subscription__c = subOption_EMAIL_TOPICS.Id;
        eligibleSubList.add(eligibleSub_EMAIL_TOPICS);
        
        insert eligibleSubList;
        
        // set the page reference
        PageReference pageRef = Page.SiteProfileManageSubscriptions;
        
        // put the contact's id in the parameters
        pageRef.getParameters().put('id', sProfile.Contact__c);
        Test.setCurrentPage(pageRef);
        
        // instantiate the controller
        Sitecontroller controller = new Sitecontroller();
        
        //Stop test here
        test.stopTest();
        
        // make sure we found the right subscriptions
        system.assertEquals(4, controller.MainContact.mapTypeToSubscriptionList_Advisory.size());
        system.assertEquals(1, controller.MainContact.mapTypeToSubscriptionList_Advisory.get('EMAIL_DAILY').size());
        system.assertEquals(1, controller.MainContact.mapTypeToSubscriptionList_Advisory.get('EMAIL_TOPICS').size());
        system.assertEquals(1, controller.MainContact.mapTypeToSubscriptionList_Advisory.get('EMAIL_WATCH').size());
        system.assertEquals(1, controller.MainContact.mapTypeToSubscriptionList_Advisory.get('EMAIL_BLOG').size());
    }
    
    //Modified By - Abhinav Sharma - 09/10/2016 - In order to fix "Too Many SOQL 101 error in it"
    /**
     * @description:	step 1) Create an EAB Site Profile
     * 					step 2) Create a Program where Applicable Segment contains "Education" - this ensures it is picked up as an EAB Program
     * 					step 3) Create an active membership and associate that to the EAB program
     * 					step 4) Create Subscription Options and Eligible Subscription Options related to the EAB Program and Subscription Option
     * 					step 5) Instantiate the controller and pass an encrypted string containing the userDetail command + user Id
     * 					step 6) Verify the eligible subscription options are present.
     * 
     **/
    static testMethod void testAdvAdmin_ManageSubscriptions_Create() {
        
        //Bypass Dupeblocker
        Util.IsTest(true);
        
        //Bypassing Triggers so then test data can be created easily
        Util.byPassAllTriggers = true;
        
        //Flag for triggers: this is just a test, don't do crazy things.
        Util.isTesting = true;
        
        // create a contact that is also an EAB.com User
        Site_Profile__c sProfile = Test_SiteUserHelper.createSiteProfile(SiteUserHelper.SITE_EAB, true);
        
        // get the site profile and contact info
        sProfile = [SELECT Id, User_Id__c, Contact__r.LastName, Status_Code_Description__c, 
                    Type__c, Contact__c, Contact__r.AccountId FROM Site_Profile__c 
                    WHERE Id = :sProfile.Id];
        
        // create a program
        Program__c prog = TestUtilities.CreateNewProgram(false);
        prog.Applicable_Segments__c = 'US Education';
        insert prog;
        
        //membership
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
        
        //Subscription options
        List<Subscription_Option__c> subscriptionList = new List<Subscription_Option__c>();
        
        //Subscription option
        Subscription_Option__c subOption_EMAIL_WATCH = new Subscription_Option__c();
        subOption_EMAIL_WATCH.Subscription_Status__c = 'Active';
        subOption_EMAIL_WATCH.Subscription_Category__c = 'EMAIL_WATCH';
        subOption_EMAIL_WATCH.Name = 'Oncology Roundtable';
        subscriptionList.add(subOption_EMAIL_WATCH);
		
		//Subscription option        
        Subscription_Option__c subOption_EMAIL_DAILY = new Subscription_Option__c();
        subOption_EMAIL_DAILY.Subscription_Status__c = 'Active';
        subOption_EMAIL_DAILY.Subscription_Category__c = 'EMAIL_DAILY';
        subOption_EMAIL_DAILY.Name = 'Clinical Advantage';
        subscriptionList.add(subOption_EMAIL_DAILY);
        
        //Subscription option
        Subscription_Option__c subOption_EMAIL_BLOG = new Subscription_Option__c();
        subOption_EMAIL_BLOG.Subscription_Status__c = 'Active';
        subOption_EMAIL_BLOG.Subscription_Category__c = 'EMAIL_BLOG';
        subOption_EMAIL_BLOG.Name = 'Email_Blog';
        subscriptionList.add(subOption_EMAIL_BLOG);
        
        //Subscription option
        Subscription_Option__c subOption_EMAIL_TOPICS = new Subscription_Option__c();
        subOption_EMAIL_TOPICS.Subscription_Status__c = 'Active';
        subOption_EMAIL_TOPICS.Subscription_Category__c = 'EMAIL_TOPICS';
        subOption_EMAIL_TOPICS.Name = 'Email_Topic';
        subscriptionList.add(subOption_EMAIL_TOPICS);
        
        //Inserting subscription options
        insert subscriptionList;
        
        // new eligible subscription option
        List<Eligible_Subscription_Option__c> eligibleSubList = new List<Eligible_Subscription_Option__c>();
        Eligible_Subscription_Option__c eligibleSub_EMAIL_WATCH = new Eligible_Subscription_Option__c();
        eligibleSub_EMAIL_WATCH.Program__c = prog.Id;
        eligibleSub_EMAIL_WATCH.Related_Subscription__c = subOption_EMAIL_WATCH.Id;
        eligibleSubList.add(eligibleSub_EMAIL_WATCH);
        
        Eligible_Subscription_Option__c eligibleSub_EMAIL_DAILY = new Eligible_Subscription_Option__c();
        eligibleSub_EMAIL_DAILY.Program__c = prog.Id;
        eligibleSub_EMAIL_DAILY.Related_Subscription__c = subOption_EMAIL_DAILY.Id;
        eligibleSubList.add(eligibleSub_EMAIL_DAILY);
        
        Eligible_Subscription_Option__c eligibleSub_EMAIL_BLOG = new Eligible_Subscription_Option__c();
        eligibleSub_EMAIL_BLOG.Program__c = prog.Id;
        eligibleSub_EMAIL_BLOG.Related_Subscription__c = subOption_EMAIL_BLOG.Id;
        eligibleSubList.add(eligibleSub_EMAIL_BLOG);
        
        Eligible_Subscription_Option__c eligibleSub_EMAIL_TOPICS = new Eligible_Subscription_Option__c();
        eligibleSub_EMAIL_TOPICS.Program__c = prog.Id;
        eligibleSub_EMAIL_TOPICS.Related_Subscription__c = subOption_EMAIL_TOPICS.Id;
        eligibleSubList.add(eligibleSub_EMAIL_TOPICS);
        
        //Insert eligible subscription options
        insert eligibleSubList;
        
        //create the search string
        String searchString = '{"Command":"UserDetails","User_Id":"' + sProfile.User_Id__c + '"}';
        String encryptedSearchString = EncryptionHelper.EncryptString(searchString);
        
        // set the page reference
        PageReference pageRef = Page.SiteProfileManageSubscriptions;
        
        // Add the encrypted request parameter to page URL 
        pageRef.getParameters().put('req', encryptedSearchString);
        
        //Set current page reference
        Test.setCurrentPage(pageRef);
        
        // instantiate the controller
        SiteController controller = new SiteController();
        
        // verify the sort worked
        system.assertEquals('Clinical Advantage', 
                            controller.MainContact.mapTypeToSubscriptionList_EAB.get('EMAIL_DAILY')[0].SubscriptionDisplayName);
        
        // toggle the selection
        controller.TempSubscriptionId = eligibleSub_EMAIL_DAILY.id;
        controller.TempSubscriptionCreate = true;
        controller.ToggleTempSubscription();
        
        // Save subscription choices
        controller.SubmitSubscriptions();
        
        // get this newly created subscription
        List<Subscription__c> activeSubscriptions = [SELECT Id, Subscription_Status__c, Subscription_Id__r.Program__c FROM Subscription__c WHERE Contact__c = :sProfile.Contact__c];
        
        //Stop test here
        test.stopTest();
        
        //Asserting for the results
        system.assertEquals(1, activeSubscriptions.size());
        system.assertEquals(Sitecontroller.SUBSCRIPTION_ACTIVE, activeSubscriptions[0].Subscription_Status__c);
        system.assertEquals(prog.Id, activeSubscriptions[0].Subscription_Id__r.Program__c);
    }
    
    //Modified By - Abhinav Sharma - 09/10/2016 - In order to fix "Too Many SOQL 101 error in it"
    static testMethod void testAdvAdmin_ManageSubscriptions_Delete() {
        
        //Bypass Dupeblocker
        Util.IsTest(true);
        
        //Bypassing Triggers so then test data can be created easily
        Util.byPassAllTriggers = true;
        
        //Flag for triggers: this is just a test, don't do crazy things.
        Util.isTesting = true;
        
        // create a contact that is also an EAB.com User
        Site_Profile__c sProfile = Test_SiteUserHelper.createSiteProfile(SiteUserHelper.SITE_EAB, true);
        
        // get the site profile and contact info
        sProfile = [SELECT Id, User_Id__c, Contact__r.LastName, Status_Code_Description__c, 
                    Type__c, Contact__c, Contact__r.AccountId FROM Site_Profile__c WHERE Id = :sProfile.Id];
        
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
        
        // new subscription option
        List<Subscription_Option__c> subscriptionList = new List<Subscription_Option__c>();
        Subscription_Option__c subOption_EMAIL_WATCH = new Subscription_Option__c();
        subOption_EMAIL_WATCH.Subscription_Status__c = 'Active';
        subOption_EMAIL_WATCH.Subscription_Category__c = 'EMAIL_WATCH';
        subOption_EMAIL_WATCH.Name = 'Oncology Roundtable';
        subscriptionList.add(subOption_EMAIL_WATCH);
        
        Subscription_Option__c subOption_EMAIL_DAILY = new Subscription_Option__c();
        subOption_EMAIL_DAILY.Subscription_Status__c = 'Active';
        subOption_EMAIL_DAILY.Subscription_Category__c = 'EMAIL_DAILY';
        subOption_EMAIL_DAILY.Name = 'Clinical Advantage';
        subscriptionList.add(subOption_EMAIL_DAILY);
        
        Subscription_Option__c subOption_EMAIL_BLOG = new Subscription_Option__c();
        subOption_EMAIL_BLOG.Subscription_Status__c = 'Active';
        subOption_EMAIL_BLOG.Subscription_Category__c = 'EMAIL_BLOG';
        subOption_EMAIL_BLOG.Name = 'Email_Blog';
        subscriptionList.add(subOption_EMAIL_BLOG);
        
        Subscription_Option__c subOption_EMAIL_TOPICS = new Subscription_Option__c();
        subOption_EMAIL_TOPICS.Subscription_Status__c = 'Active';
        subOption_EMAIL_TOPICS.Subscription_Category__c = 'EMAIL_TOPICS';
        subOption_EMAIL_TOPICS.Name = 'Email_Topic';
        subscriptionList.add(subOption_EMAIL_TOPICS);
        
        insert subscriptionList;
        // new eligible subscription option
        List<Eligible_Subscription_Option__c> eligibleSubList = new List<Eligible_Subscription_Option__c>();
        Eligible_Subscription_Option__c eligibleSub_EMAIL_WATCH = new Eligible_Subscription_Option__c();
        eligibleSub_EMAIL_WATCH.Program__c = prog.Id;
        eligibleSub_EMAIL_WATCH.Related_Subscription__c = subOption_EMAIL_WATCH.Id;
        eligibleSubList.add(eligibleSub_EMAIL_WATCH);
        
        Eligible_Subscription_Option__c eligibleSub_EMAIL_DAILY = new Eligible_Subscription_Option__c();
        eligibleSub_EMAIL_DAILY.Program__c = prog.Id;
        eligibleSub_EMAIL_DAILY.Related_Subscription__c = subOption_EMAIL_DAILY.Id;
        eligibleSubList.add(eligibleSub_EMAIL_DAILY);
        
        Eligible_Subscription_Option__c eligibleSub_EMAIL_BLOG = new Eligible_Subscription_Option__c();
        eligibleSub_EMAIL_BLOG.Program__c = prog.Id;
        eligibleSub_EMAIL_BLOG.Related_Subscription__c = subOption_EMAIL_BLOG.Id;
        eligibleSubList.add(eligibleSub_EMAIL_BLOG);
        
        Eligible_Subscription_Option__c eligibleSub_EMAIL_TOPICS = new Eligible_Subscription_Option__c();
        eligibleSub_EMAIL_TOPICS.Program__c = prog.Id;
        eligibleSub_EMAIL_TOPICS.Related_Subscription__c = subOption_EMAIL_TOPICS.Id;
        eligibleSubList.add(eligibleSub_EMAIL_TOPICS);
        
        insert eligibleSubList;
        
        // create the subscription
        Subscription__c subscription = new Subscription__c();
        subscription.Contact__c = sProfile.Contact__c;
        subscription.Subscription_Id__c = eligibleSub_EMAIL_DAILY.Id;
        subscription.Activation_Date__c = system.today();
        subscription.Auto_Subscribed__c = true;
        insert subscription;
        
        //create the search string
        String searchString = '{"Command":"UserDetails","User_Id":"' + sProfile.User_Id__c + '"}';
        String encryptedSearchString = EncryptionHelper.EncryptString(searchString);
        
        // set the page reference
        PageReference pageRef = Page.SiteProfileManageSubscriptions;
        
        // Add the encrypted request parameter to page URL 
        pageRef.getParameters().put('req', encryptedSearchString);
        Test.setCurrentPage(pageRef);
        
        // instantiate the controller
        Sitecontroller controller = new Sitecontroller();
        
        // toggle the selection
        controller.TempSubscriptionId = eligibleSub_EMAIL_DAILY.id;
        controller.TempSubscriptionCreate = false;
        controller.ToggleTempSubscription();
        
        // Save subscription choices
        controller.SubmitSubscriptions();
        
        // make sure the subscription still exists, but has a termination date
        List<Subscription__c> inactiveSubscriptions = [SELECT Id, Subscription_Status__c, Subscription_Id__r.Program__c, Termination_Date__c FROM Subscription__c WHERE Contact__c = :sProfile.Contact__c];
        
        //Stop test here
        test.stopTest();
        
        //Asserting for the results
        system.assertEquals(1, inactiveSubscriptions.size());
        system.assertEquals(Sitecontroller.UNSUBSCRIBE_BY_SF_USER, inactiveSubscriptions[0].Subscription_Status__c);
        system.assertNotEquals(null, inactiveSubscriptions[0].Termination_Date__c);
    }
    
	//Modified By - Abhinav Sharma - 09/10/2016 - In order to fix "Too Many SOQL 101 error in it"
    static testMethod void testAdvAdmin_ManageSubscriptions_SubscribeAll() {
        
        //Bypass Dupeblocker
        Util.IsTest(true);
        
        //Bypassing Triggers so then test data can be created easily
        Util.byPassAllTriggers = true;
        
        //Flag for triggers: this is just a test, don't do crazy things.
        Util.isTesting = true;
        
        // create a contact that is also an EAB.com User
        Site_Profile__c sProfile = Test_SiteUserHelper.createSiteProfile(SiteUserHelper.SITE_EAB, true);
        
        // get the site profile and contact info
        sProfile = [SELECT Id, User_Id__c, Contact__r.LastName, Status_Code_Description__c, 
                    	Type__c, Contact__c, Contact__r.AccountId FROM Site_Profile__c WHERE Id = :sProfile.Id];
        
        // create a program
        Program__c prog = TestUtilities.CreateNewProgram(false);
        prog.Applicable_Segments__c = 'US Education';
        insert prog;
        
        //Membership
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
        
        //Contract
        Contract__c testContract1 = new Contract__c(
            Name='Test Contract1', Payer_Account__c = sProfile.Contact__r.AccountId, Program__c = prog.Id, Source_Opportunity__c=opp.Id,
            Start__c = System.Today().addDays(-10), End__c = system.today().addDays(355),
            Contract_Renewal_Opportunity__c = opp.Id, Status__c = 'ATL', Invoicing_Arrangement__c = 'Annual', Year__c = '2012',
            Type__c = 'NBB', Years_in_Term__c = 1, Initial_Invoice_Date__c = system.today()
            );
        insert testContract1;
        
        // new subscription option
        List<Subscription_Option__c> subscriptionList = new List<Subscription_Option__c>();
        Subscription_Option__c subOption_EMAIL_WATCH = new Subscription_Option__c();
        subOption_EMAIL_WATCH.Subscription_Status__c = 'Active';
        subOption_EMAIL_WATCH.Subscription_Category__c = 'EMAIL_WATCH';
        subscriptionList.add(subOption_EMAIL_WATCH);
        // add a second option in the same category
        Subscription_Option__c subOption_EMAIL_WATCH_2 = new Subscription_Option__c();
        subOption_EMAIL_WATCH_2.Subscription_Status__c = 'Active';
        subOption_EMAIL_WATCH_2.Subscription_Category__c = 'EMAIL_WATCH';
        subscriptionList.add(subOption_EMAIL_WATCH_2);
        
        Subscription_Option__c subOption_EMAIL_DAILY = new Subscription_Option__c();
        subOption_EMAIL_DAILY.Subscription_Status__c = 'Active';
        subOption_EMAIL_DAILY.Subscription_Category__c = 'EMAIL_DAILY';
        subscriptionList.add(subOption_EMAIL_DAILY);
        
        Subscription_Option__c subOption_EMAIL_BLOG = new Subscription_Option__c();
        subOption_EMAIL_BLOG.Subscription_Status__c = 'Active';
        subOption_EMAIL_BLOG.Subscription_Category__c = 'EMAIL_BLOG';
        subscriptionList.add(subOption_EMAIL_BLOG);
        // add a second option in the same category
        Subscription_Option__c subOption_EMAIL_BLOG_2 = new Subscription_Option__c();
        subOption_EMAIL_BLOG_2.Subscription_Status__c = 'Active';
        subOption_EMAIL_BLOG_2.Subscription_Category__c = 'EMAIL_BLOG';
        subscriptionList.add(subOption_EMAIL_BLOG_2);
        
        Subscription_Option__c subOption_EMAIL_TOPICS = new Subscription_Option__c();
        subOption_EMAIL_TOPICS.Subscription_Status__c = 'Active';
        subOption_EMAIL_TOPICS.Subscription_Category__c = 'EMAIL_TOPICS';
        subscriptionList.add(subOption_EMAIL_TOPICS);
        // add a second option in the same category
        Subscription_Option__c subOption_EMAIL_TOPICS_2 = new Subscription_Option__c();
        subOption_EMAIL_TOPICS_2.Subscription_Status__c = 'Active';
        subOption_EMAIL_TOPICS_2.Subscription_Category__c = 'EMAIL_TOPICS';
        subscriptionList.add(subOption_EMAIL_TOPICS_2);
        
        insert subscriptionList;
        
        // new eligible subscription option
        List<Eligible_Subscription_Option__c> eligibleSubList = new List<Eligible_Subscription_Option__c>();
        Eligible_Subscription_Option__c eligibleSub_EMAIL_WATCH = new Eligible_Subscription_Option__c();
        eligibleSub_EMAIL_WATCH.Program__c = prog.Id;
        eligibleSub_EMAIL_WATCH.Related_Subscription__c = subOption_EMAIL_WATCH.Id;
        eligibleSubList.add(eligibleSub_EMAIL_WATCH);
        Eligible_Subscription_Option__c eligibleSub_EMAIL_WATCH_2 = new Eligible_Subscription_Option__c();
        eligibleSub_EMAIL_WATCH_2.Program__c = prog.Id;
        eligibleSub_EMAIL_WATCH_2.Related_Subscription__c = subOption_EMAIL_WATCH_2.Id;
        eligibleSubList.add(eligibleSub_EMAIL_WATCH_2);
        
        Eligible_Subscription_Option__c eligibleSub_EMAIL_DAILY = new Eligible_Subscription_Option__c();
        eligibleSub_EMAIL_DAILY.Program__c = prog.Id;
        eligibleSub_EMAIL_DAILY.Related_Subscription__c = subOption_EMAIL_DAILY.Id;
        eligibleSubList.add(eligibleSub_EMAIL_DAILY);
        Eligible_Subscription_Option__c eligibleSub_EMAIL_DAILY_2 = new Eligible_Subscription_Option__c();
        
        Eligible_Subscription_Option__c eligibleSub_EMAIL_BLOG = new Eligible_Subscription_Option__c();
        eligibleSub_EMAIL_BLOG.Program__c = prog.Id;
        eligibleSub_EMAIL_BLOG.Related_Subscription__c = subOption_EMAIL_BLOG.Id;
        eligibleSubList.add(eligibleSub_EMAIL_BLOG);
        Eligible_Subscription_Option__c eligibleSub_EMAIL_BLOG_2 = new Eligible_Subscription_Option__c();
        eligibleSub_EMAIL_BLOG_2.Program__c = prog.Id;
        eligibleSub_EMAIL_BLOG_2.Related_Subscription__c = subOption_EMAIL_BLOG_2.Id;
        eligibleSubList.add(eligibleSub_EMAIL_BLOG_2);
        
        Eligible_Subscription_Option__c eligibleSub_EMAIL_TOPICS = new Eligible_Subscription_Option__c();
        eligibleSub_EMAIL_TOPICS.Program__c = prog.Id;
        eligibleSub_EMAIL_TOPICS.Related_Subscription__c = subOption_EMAIL_TOPICS.Id;
        eligibleSubList.add(eligibleSub_EMAIL_TOPICS);
        Eligible_Subscription_Option__c eligibleSub_EMAIL_TOPICS_2 = new Eligible_Subscription_Option__c();
        eligibleSub_EMAIL_TOPICS_2.Program__c = prog.Id;
        eligibleSub_EMAIL_TOPICS_2.Related_Subscription__c = subOption_EMAIL_TOPICS_2.Id;
        eligibleSubList.add(eligibleSub_EMAIL_TOPICS_2);
        insert eligibleSubList;
        
        // set the page reference
        PageReference pageRef = Page.AdvAdmin_ManageSubscriptions;
        
        // put the contact's id in the parameters
        pageRef.getParameters().put('id', sProfile.Contact__c);
        Test.setCurrentPage(pageRef);
        
        // instantiate the controller
        Sitecontroller controller = new Sitecontroller();
        
        // subscribe to all TOPIC
        controller.SectionName = Sitecontroller.SUBSCRIPTION_CATEGORY_TOPIC;
        controller.SubscribeAll();
        
        // subscribe to all PRODUCT
        controller.SectionName = Sitecontroller.SUBSCRIPTION_CATEGORY_PRODUCT;
        controller.SubscribeAll();
        
        // subscribe to all BLOG
        controller.SectionName = Sitecontroller.SUBSCRIPTION_CATEGORY_BLOG;
        controller.SectionType = 'EAB.com';
        controller.SubscribeAll();
        
        //Stop test here
        test.stopTest();
        
        // make sure we found the right subscriptions
        system.assertEquals(7, controller.MainContact.EligibleSubscriptions.size());
        
        // make sure we found the right subscriptions
        system.assertEquals(4, controller.MainContact.mapTypeToSubscriptionList_EAB.size());
        system.assertEquals(1, controller.MainContact.mapTypeToSubscriptionList_EAB.get('EMAIL_DAILY').size());
        system.assertEquals(2, controller.MainContact.mapTypeToSubscriptionList_EAB.get('EMAIL_TOPICS').size());
        system.assertEquals(2, controller.MainContact.mapTypeToSubscriptionList_EAB.get('EMAIL_WATCH').size());
        system.assertEquals(2, controller.MainContact.mapTypeToSubscriptionList_EAB.get('EMAIL_BLOG').size());
        
        // make sure we subscribed to all TOPIC, PRODUCT, and BLOG subscription options
        List<Subscription__c> activeSubscriptions = [SELECT Id FROM Subscription__c WHERE Contact__c = :sProfile.Contact__c AND Termination_Date__c = null];
        system.assertEquals(2, activeSubscriptions.size());
    }
}