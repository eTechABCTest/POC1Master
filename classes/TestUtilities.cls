/*
    Purpose         :   Utility class with methods to assist with unit test data creation.
                
    Create By       :   Victor Hanson
    
    Created Date    :   3/21/2012
    
    Revision Log    :   V1.0 Created
						v1.1 - Victor Hanson - 10/15/2015 -CR-20140407-4977 - optimized a recordType calls
						v1.2 - Abhinav Sharma - 05/30/2016 - CR-20150202-8624 - Added a new method - CreateNewCaseComment
						v1.3 - Abhinav Sharma - 06/02/2016 - CR-20150202-8625 - Added new variables
						v1.4 - Abhinav Sharma - 06/03/2016 - CR-20150202-8626 - Added new variables
						v1.5 - Abhinav Sharma - 06/07/2016 - CR-20150202-8629 - Added new variables
						v1.6 - Abhinav Sharma - 06/15/2016 - CR-20150202-8628 - Added new sync field mapping
						v1.6 - Mahedra Swarnkar - 07/25/2016 - CR-20160229-9651 - Added a new variable "DEADLINE_REASON_NOT_POPULATED_ERROR"
*/
public with sharing class TestUtilities {
    // get the record type id for a given record type name
    public static Id FindRecordTypeId(String ObjectType, String recordTypeName) {
        Id recordTypeId;
        List<RecordType> recordTypes = [SELECT Name, Id, SobjectType FROM RecordType WHERE IsActive = true AND SobjectType = :ObjectType AND Name = :recordTypeName LIMIT 1];
        if (recordTypes.size() > 0)
            recordTypeId = recordTypes[0].Id;
        return recordTypeId;
    }
    
    public static Opportunity CreateNewOpportunity(boolean CreateAndInsert) {
        return CreateNewOpportunity(null, CreateAndInsert);
    }
    
    public static SFDC_Change_Request__c CreateChangeRequest(boolean CreateAndInsert) {
        Id sysOutageRTId = Schema.SObjectType.SFDC_Change_Request__c.getRecordTypeInfosByName().get('Level II').getRecordTypeId();
        return CreateChangeRequest(sysOutageRTId, CreateAndInsert);
    }
    
    public static Contact CreateAdvUserContact(boolean CreateAndInsert) {
        // setup an account and contact
        Account acct = TestUtilities.CreateNewAccount(true);
        Eligible_Domain__c domain = new Eligible_Domain__c(Is_Included__c = true, Qualified_Domain__c = 'advisory.com', Account__c = acct.Id);
        insert domain;
        Contact con = CreateAdvUserContact(acct, CreateAndInsert);
        
        return con;
    }
    
    public static Contact CreateAdvUserContact(Account acct, boolean CreateAndInsert) {
        // create the eligible domain
        Eligible_Domain__c domain = new Eligible_Domain__c(Is_Included__c = true, Qualified_Domain__c = 'advisory.com', Account__c = acct.Id);
        insert domain;
        // setup an account and contact
        Contact con = TestUtilities.CreateNewContact(acct, false);
        con.Advisory_com_User_Status__c = 'Active';
        
        con.Email = 'hansonv@advisory.com';
        //Commented to delete the field Advisory_com_Username__c on the contact -by mahendra swarnakar - CR-20140811-6954 - 09/04/2015 
        //con.Advisory_com_Username__c = 'hansonv@advisory.com';
        con.Advisory_com_Email_Address__c = 'hansonv@advisory.com';
        con.Create_Advisory_com_User_Account__c = true;
        con.Primary_Country__c = 'USA';
        
        if (CreateAndInsert) insert con;
        
        return con;
    }
    
    
    public static SFDC_Change_Request__c CreateChangeRequest(Id recordTypeId, boolean CreateAndInsert) {
        
        // create ISS system
        
        IS_System__c ISS = new IS_System__c();
        ISS.Name = 'Servers' + crypto.getRandomInteger();
        insert ISS;
        
        // create a new Change Req
        
        Id sysOutageRTId = recordTypeId;
        SFDC_Change_Request__c CR = new SFDC_Change_Request__c();
        CR.RecordTypeId = sysOutageRTId;
        CR.Status__c = 'Open';
        CR.Functionality__c = 'All';
        CR.IS_System__c = ISS.Id;
        CR.Title__c = 'Maintenance';
        
        if (CreateAndInsert)
            insert CR;
        
        return CR;
    }
    
    public static SFDC_Request_Comment__c CreateRequestComment(boolean CreateAndInsert) {
        User u = CreateNewUser(true);
        SFDC_Change_Request__c changeRequest = CreateChangeRequest(true);
        SFDC_Request_Comment__c comment = CreateRequestComment(u.Id, changeRequest.Id, CreateAndInsert);
        return comment;
    }
    
    public static SFDC_Request_Comment__c CreateRequestComment(Id changeRequestID, Id userId, boolean CreateAndInsert) {
        SFDC_Request_Comment__c comment = new SFDC_Request_Comment__c();
        comment.User__c = userId;
        comment.Activity_Type__c = 'Analysis/Design';
        comment.Activity_Date__c = system.today();
        comment.Time__c = 2.5;
        comment.SFDC_Change_Request__c = changeRequestID;
        
        if (CreateAndInsert)
            insert comment;
            
        return comment;
    }
    
    public static Opportunity CreateNewOpportunity(Id accountId, boolean CreateAndInsert) {
        if (accountId == null)
            accountId = TestUtilities.CreateNewAccount(true).Id;
        Opportunity opp = new Opportunity();
        Id PTMarketingRT = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('PT Marketing').getRecordTypeId();
        // make the opportunity a PTMarketing Opportunity record type
        if (PTMarketingRT != null) opp.RecordTypeId = PTMarketingRT;
        opp.Name = 'test' + crypto.getRandomInteger();
        opp.AccountId = accountId;
        opp.StageName = 'Pending- Renewal Call Not Yet Occured';
        opp.Amount = 100;
        opp.CloseDate = system.today().addDays(10);
        if (CreateAndInsert)
            insert opp;
            
        return opp;
    }
    
    // create a basic event
    public static Event CreateNewEvent(boolean CreateAndInsert) {
        Event evt = new Event();
        evt.OwnerId = UserInfo.getUserId();
        evt.StartDateTime = system.now();
        evt.DurationInMinutes = 60;
        evt.Subject = 'Test';
        evt.Event_Type__c = 'Phone Appointment';
        evt.Event_Purpose__c = 'Prewire';
        if (CreateAndInsert)
            insert evt;
        
        return evt;
    }
    
    public static User CreatenewUser(boolean CreateAndInsert) {
        return CreateNewUser(null, CreateAndInsert);
    }
    
    public static User CreateNewUser(Profile aProfile, boolean CreateAndInsert) {
        // if profile is null, grab an existing one
        if (aProfile == null)
            aProfile = [SELECT Id FROM Profile LIMIT 1];
        
        User newUser = new User();
        newUser.Alias = 'tUser';
        newUser.Email = 'tUser@noreply.com';
        newUser.EmailEncodingKey = 'UTF-8';
        newUser.LastName = 'User';
        newUser.ProfileId = aProfile.Id;
        newUser.Username = 'tUser@noreply'+crypto.getRandomLong()+'.com';
        newUser.TimeZoneSidKey = 'America/New_York';
        newUser.LanguageLocaleKey = 'en_US';
        newUser.LocaleSidKey = 'en_US';
        if (CreateAndInsert)
            insert newUser;
        
        return newUser;
    }
    
    // create a new account record
    public static Account CreateNewAccount(boolean CreateAndInsert) {
        // get the us corporate record type id
        return CreateNewAccount('US Corporate', CreateAndInsert);
    }
    
    public static Membership__c CreateNewMembership(Id accountId, Id programId, boolean CreateAndInsert) {
        Membership__c retMembership = new Membership__c();
        retMembership.Name = 'test' + crypto.getRandomInteger();
        retMembership.Account_Name__c = accountId;
        retMembership.Program__c = programId;
        
        if (CreateAndInsert) {
            Util.IsTest(true);
            insert retMembership;
            Util.IsTest(false); 
        }
        
        return retMembership;
    }
    
    // overloaded method to create a new account record -- this method allows the user to specify a record type
    public static Account CreateNewAccount(String RecordTypeLabel, boolean CreateAndInsert) {
        Account retAccount = new Account();
        retAccount.Name = 'TestHospital-' + crypto.getRandomInteger();
        retAccount.Account_Formal_Name__c = retAccount.Name;
        retAccount.Primary_City__c = 'Columbus';
        retAccount.Primary_State_Province__c = 'OH';
        retAccount.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(RecordTypeLabel).getRecordTypeId();
        // if the recordtypemap is null for some reason, manually attempt to get the recordtypeId
        if (retAccount.RecordTypeId == null)
            retAccount.RecordTypeId = FindRecordTypeId('Account', RecordTypeLabel);
        
        retAccount.Academy_Programs_Available_for_Outreach__c = '';
        retAccount.BI_Programs_Available_for_Outreach__c = '';
        retAccount.Core_Programs_Available_for_Outreach__c = '';
        retAccount.Advisory_com_Organization_id__c = 14231;
        retAccount.Advisory_com_Organization_Status__c = 'Active';
        retAccount.Status__c = Constants.ACTIVE;
        
        if (CreateAndInsert)
            insert retAccount;
        
        return retAccount;
    }
    
    public static Contact CreateNewContact(boolean CreateAndInsert) {
        return CreateNewContact(null, CreateAndInsert);
    }
    
    public static Contact CreateNewContact(Account acct, boolean CreateAndInsert) {
        Id ExternalRecordType = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('External').getRecordTypeId();
        if (ExternalRecordType == null) {
            // reset record type settings
            Util.resetRecordtypeSettings();
            ExternalRecordType = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('External').getRecordTypeId();
        }
        
        Contact retContact = new Contact();
        retContact.FirstName = 'Joe';
        retContact.LastName = 'Thomas-' + Crypto.getRandomInteger();
        retContact.RecordTypeId = ExternalRecordType;
        if (retContact.RecordTypeId == null)
            FindRecordTypeId('Contact', 'External');
        if (acct == null)
            acct = CreateNewAccount(true);
        retContact.AccountId = acct.id;
        retContact.Is_Ignore_Phrase_Characters__c = true;
        retContact.Primary_Address_Line_1__c = '123 main st';
        retContact.Primary_City__c = 'Columbus';
        retContact.Primary_State_Province__c = 'OH';
        retContact.Primary_Postal_Code__c = '43235';
        retContact.Title = 'CEO';
        retContact.Email = 'testuser2' + crypto.getRandomInteger() + '@noreply.com';
        retContact.Phone = '614-555-8855';
        
        
        if (CreateAndInsert)
            insert retContact;
        
        return retContact;
    }
    
    public static Program__c CreateNewProgram(boolean CreateAndInsert) {
        return CreateNewProgram('RI Marketer', 'HCAB', 'No', 'PT', CreateAndInsert);
    }
    
    public static Program__c CreateNewRIProgram(boolean CreateAndInsert) {
        return CreateNewProgram('RI Marketer', 'HCAB', 'No', 'RI', CreateAndInsert);
    }
    
    public static Program__c CreateNewProgram(String NewBusMarketer, String ProgAcronym, String CreateMemberships, String BusinessLine, boolean CreateAndInsert) {
        Program__c retProgram = new Program__c();
        retProgram.Name = 'TestProgram-' + crypto.getRandomInteger();
        retProgram.New_Business_Marketer__c = NewBusMarketer;
        retProgram.Program_Acronym__c= ProgAcronym;
        retProgram.Create_memberships__c= CreateMemberships;
        retProgram.Business_line__c = BusinessLine;
        
        if (CreateAndInsert)
            insert retProgram;
        
        return retProgram;
    }   
    
    public static Subscription_Option__c CreateNewSubscriptionOption(boolean CreateAndInsert) {
        return CreateNewSubscriptionOption('Test Subscription Option',CreateAndInsert);
    }
    
    public static Subscription_Option__c CreateNewSubscriptionOption(string sName, boolean CreateAndInsert) {
        Subscription_Option__c retSubscrOption = new Subscription_Option__c();
        retSubscrOption.Name = 'Test Subscription Option - Test';
        retSubscrOption.Description__c = 'This is a test';
        retSubscrOption.Subscription_Category__c = 'Testing';
        
        if(CreateAndInsert)
            insert retSubscrOption;
        
        return retSubscrOption;
    }
    
    public static Eligible_Subscription_Option__c CreateNewEligibleSubscriptionOption(boolean CreateAndInsert) {
        Program__c p = CreateNewProgram(true);
        Subscription_Option__c so = CreateNewSubscriptionOption(true);
        return CreateNewEligibleSubscriptionOption(p, so, CreateAndInsert);
    }
    
    public static Eligible_Subscription_Option__c CreateNewEligibleSubscriptionOption(Program__c p, boolean CreateAndInsert) {
        Subscription_Option__c so = CreateNewSubscriptionOption(true);
        return CreateNewEligibleSubscriptionOption(p, so, CreateAndInsert);
    }
    
    public static Eligible_Subscription_Option__c CreateNewEligibleSubscriptionOption(Subscription_Option__c so, boolean CreateAndInsert) {
        Program__c p = CreateNewProgram(true);
        return CreateNewEligibleSubscriptionOption(p, so, CreateAndInsert);
    }
    
    public static Eligible_Subscription_Option__c CreateNewEligibleSubscriptionOption(Program__c p, Subscription_Option__c so, boolean CreateAndInsert) {
        Eligible_Subscription_Option__c retESO = new Eligible_Subscription_Option__c();
        retESO.Program__c = p.Id;
        retESO.Related_Subscription__c = so.Id;
        
        if(CreateAndInsert)
            insert retESO;
        
        return retESO;
    }
    
    public static Contract__c CreateNewContract(boolean CreateAndInsert) {
        Account acct = CreateNewAccount(true);
        Contact con = CreateNewContact(acct, true);
        Program__c program = CreateNewProgram(true);
        return CreateNewContract(acct.Id, con.Id, program.Id, CreateAndInsert);
    }
    
    public static Contract__c CreateNewContract(Id payerAccountId, Id mainContactId, Id programId, boolean CreateAndInsert) {
        Contract__c retContract = new Contract__c();
        retContract.Payer_Account__c = payerAccountId;
        retContract.Main_Contact__c = mainContactId;
        retContract.Invoice_Contact__c = mainContactId;
        retContract.Program__c = programId;
        retContract.Year__c = String.valueof(system.today().year());
        retContract.Start__c = system.today().addDays(-1);
        retContract.End__c = system.today().addDays(2);
        retContract.Type__c = 'NBB';
        retContract.Negotiated_Amount__c = 1;
        
        if (CreateAndInsert)
            insert retContract;
            
        return retContract;
    }
    
    //Reset flags for Oppotunity Trigger
    public static void resetOpportunityTriggerFlags() {
        
        //Reset all flags
        Util.BypassAllTriggers = false;
        Util.IsTrigger_NBBOppFields = false;
        Util.IsTrigger_EventPrewire  = false;
        Util.IsTrigger_EventUpdateFields = false;
        Util.IsBatch = false;
        Util.IsTrigger_Task_PopulateNoOfRevisitField = false;
    }
    
    public static Id vendorRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Vendor').getRecordTypeId();
    
    public static Department__c createDepartment(boolean CreateAndInsert) {
        
        Department__c department = new Department__c(Name='Enterprise Technology', Department_Number__c='123',
                                                     Department_Head__c=UserInfo.getUserId());
        
        if (CreateAndInsert) insert department;
        return department;
    }
    
    public static Budget__c createBudget(Id deptId, boolean CreateAndInsert) {
        
        if (deptId == null) deptId = createDepartment(true).Id;
        
        Budget__c budget = new Budget__c(Account_Number__c='321', Account_Name__c='payroll tax',
                                         Department__c=deptId);
        
        if (CreateAndInsert) insert budget;
        
        return budget;
    }
    
    public static Purchase_Request__c createPurchaseRequest(boolean CreateAndInsert) {
        
        Account acct = CreateVendorAccount(true);
        
        Purchase_Request__c purchaseRequest = new Purchase_Request__c(Vendor__c=acct.Id, Purchase_Amount__c=1000,
                                                                      Department__c='ET', Approval_Stage__c = 'Approved',
                                                                      Accounting_Manager__c=userInfo.getUserId(),
                                                                      Term_Start_Date__c = system.today().addMonths(1),
                                                                      Term_End_Date__c = system.today().addMOnths(13));
        
        if (CreateAndInsert) insert purchaseRequest;
        
        return purchaseRequest;
    }
    
    public static Budget_Allocation__c createBudgetAllocation(Id budgetId, Id purchReqId, Id payReqId, boolean CreateAndInsert) {
        
        if (budgetId == null) budgetId = createBudget(null, true).Id;
        
        if (purchReqId == null && payReqId == null) purchReqId = createPurchaseRequest(true).Id;
        
        Budget_Allocation__c budgetAllocation = new Budget_Allocation__c(Purchase_Request__c = purchReqId, Payment_Request__c = payReqId,
                                                                         Q1_Allocation__c = 1, Q2_Allocation__c = 2, Q3_Allocation__c = 3, Q4_Allocation__c = 4,
                                                                         Budget_Line__c = budgetId);
        
        if (CreateAndInsert) insert budgetAllocation;
        
        return budgetAllocation;
    }
    
    public static Account CreateVendorAccount(boolean CreateAndInsert) {
        
        // create the vendor with the correct record type and status
        Account acct = new Account(RecordTypeId = vendorRecordTypeId, Name = 'new vendor',
                                   Status__c = 'Approved - All Services');
        
        // insert if requested
        if (CreateAndInsert) insert acct;
        
        // return vendor account
        return acct;
    }
    
     // create a new Credit Card
    public static Credit_Card__c CreateNewCreditCard(boolean CreateAndInsert) {
        // create a contact
        Contact c = TestUtilities.CreateNewContact(true);
        //Portfolio__c paymentAccount = new Portfolio__c(Card_Owner__c = UserInfo.getUserId(), Portfolio_Owner__c = c.Id);
        Portfolio__c paymentAccount = new Portfolio__c(Card_Holder__c = c.Id);
        insert paymentAccount;
        
        // return the credit card record
        return CreateNewCreditCard(userInfo.getUserId(), paymentAccount.Id, CreateAndInsert);
    }
    
    // create a new Credit Card
    public static Credit_Card__c CreateNewCreditCard(Id userId, Id pymtAcctId, boolean CreateAndInsert) {
        // update the custom setting to include the default CC profile id
        Credit_Card_Settings__c ccSettings = CreditCardConstants.CONFIG_DEFAULT;
        ccSettings.Name = CreditCardConstants.CC_DEFAULT_SETTINGS_NAME;
        ccSettings.Status__c = 'Active';
        upsert ccSettings;
        
        // insert credit card record
        Credit_Card__c creditCard = new Credit_Card__c(Payment_Account__c = pymtAcctId
                                                       );
        if (CreateAndInsert) insert creditCard;
        return creditCard;
    }
    
    //Create the Credit Card Settings record
    public static Credit_Card_Settings__c CreateCreditCardSettings(){
        User u = createNewUser(true);
        Credit_Card_Settings__c configCCDefaultSetting = new Credit_Card_Settings__c(Name = 'CC Default Settings', 
                                                                                     Account_Code__c = 'CR412', 
                                                                                     CC_Default_Limit_Warning_Level__c = 10,
                                                                                     CC_Month_Cycle_Reset_Date__c = 1,
                                                                                     Company_Name__c = 'The Advisory Board Company', 
                                                                                     Customer_Id__c = 'CUST2', 
                                                                                     Decline_Alert_To_Finance__c = true, 
                                                                                     Endpoint__c = 'https://w6cert.iconnectdata.com/fcws/services/FleetCreditWS',
                                                                                     Last_Transaction_Pull__c = DateTime.now(), 
                                                                                     Mask_Card_Num_On_Create__c = 'N', 
                                                                                     Mask_Card_Num_On_Inquiry_Update__c = 'Y',
                                                                                     Password__c = 'TABTEST1', 
                                                                                     Username__c = 'ADVISORYWS',
                                                                                     Portfolio_Record_Owner__c = u.Id,
                                                                                     Transaction_History_Days__c = 45, 
                                                                                     Statement_Email_Template__c = '', 
                                                                                     Card_Profile_Flag__c = 'Y', 
                                                                                     Default_Card_Profile_Value__c = '008', 
                                                                                     Default_Vendor_Card_Status__c = 'Blocked',
                                                                                     Status__c = 'Active',
                                                                                     xmlns_main__c = 'http://fleetCredit02.comdata.com/maintenance/',
                                                                                     xmlns_soapenv__c = 'http://schemas.xmlsoap.org/soap/envelope/',
                                                                                     xmlns_wsse__c = 'http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-secext-1.0.xsd',
                                                                                     xmlns_wsu__c = 'http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-utility-1.0.xsd');  
                                                                                     
                                                                
        return configCCDefaultSetting;
    }
    
    // return an event
    public static Event createEvent(boolean createAndInsert, DateTime dtStart, Id whatId) {
        
        if (dtStart == null)
        	dtStart = system.now();
        
        Event evt = new Event(
                whatId = whatId,
                StartDateTime = dtStart,
                ActivityDateTime = dtStart,
                ActivityDate = dtStart.date(),
                EndDateTime = dtStart.addDays(1),
                Event_Type__c = 'Prewire',
                Event_Purpose__c = 'Prewire');
        
        if (createAndInsert) insert evt;
        
        return evt;
    }
    
    // return a task
    public static Task createTask(boolean createAndInsert, Id whatId) {
        
        Task tsk = new Task(Subject = 'test',
                            ActivityDate = system.today(),
                            Event_Type__c = 'revisit',
                            WhatId = whatId);
        
        if (createAndInsert) insert tsk;
        
        return tsk;
    }
    
    // create a new project
    public static Project__c createProject(boolean createAndInsert) {
    	
        Project__c project = new Project__c(Name = 'Test-Data', 
        									Implementation_Pod__c = 'Test', 
        									Crimson_Data_Lag__c = 10, 
        									Load_Frequency__c = 'Test');
        
        if (createAndInsert) insert project;
        
        return project;
    }
    
    // create a new member support record
    public static Site_Issue__c createSiteIssue(Id projectId, boolean createAndInsert) {
    	
    	Site_Issue__c sIssue = new Site_Issue__c(Site_Issue_Priority__c = 'High', 
    											 Site_Issue_Short_Description__c = 'Test-Description',
                                                 Category__c = 'Test-Category', 
                                                 Data_Load_Type__c = Constants.HISTORICAL_RELOAD,
                                                 Crimson_Site_Issue_Description__c = 'Test Issue Description', 
                                                 RecordTypeId = Constants.RECORD_TYPE_ID_SITE_ISSUE_CCA_SUPPORT_REQUEST, 
                                                 Project__c = projectId, 
                                                 CCC_Date_Observed__c = System.Today(), 
                                                 Site_Issue_Created_Date__c = System.now().addDays(-54), 
                                                 Site_Issue_Close_Date__c = System.now().addDays(8), 
                                                 Data_Load_Period_End__c = Date.Today().addDays(-62),
                                                 Data_Load_Period_Begin__c = Date.today(), 
                                                 Files_Received__c = Date.today());
    	
    	if (createAndInsert) insert sIssue;
        
        return sIssue;
    }
    
    @TestVisible private static Sync_Field__c createSyncField(string name, string srcRTDevName, string srcObjAPIName, string srcFieldAPIName,
    											 string targetObjAPIName, string targetFieldAPIName) 
    {
    	
    	return new Sync_Field__c(name = name,
    										Source_Record_Type_Developer_Name__c = srcRTDevName,
    										Source_Object_API_Name__c = srcObjAPIName,
    										Source_Field_API_Name__c = srcFieldAPIName,
    										Target_Object_API_Name__c = targetObjAPIName,
    										Target_Field_API_Name__c = targetFieldAPIName);
    }
    
    //Create test data for the Sync Fields custom setting
    public static void createSyncFields() {
    	
    	list<Sync_Field__c> syncFieldList = new list<Sync_Field__c>();
    	
    	//Sync Member Support fields to Case
    	syncFieldList.add(createSyncField('MS.BrowserUsd->Case.BrowserUsd_DL', Constants.RECORD_TYPE_SITE_ISSUE_DEVELOPER_NAME_CCA_DATA_LOAD, 
                                         'Site_Issue__c', 'Browser_Used__c', 'Case', 'Browser_Used__c'));
		syncFieldList.add(createSyncField('MS.DLPBegin->Case.Desc_DL', Constants.RECORD_TYPE_SITE_ISSUE_DEVELOPER_NAME_CCA_DATA_LOAD, 
		                                         'Site_Issue__c', 'Data_Load_Period_Begin__c', 'Case', 'Description'));
		syncFieldList.add(createSyncField('MS.DLPEnd->Case.Desc_DL', Constants.RECORD_TYPE_SITE_ISSUE_DEVELOPER_NAME_CCA_DATA_LOAD, 
		                                         'Site_Issue__c', 'Data_Load_Period_End__c', 'Case', 'Description'));
		syncFieldList.add(createSyncField('MS.CurrentRes->Case.CurrentRes_DL', Constants.RECORD_TYPE_SITE_ISSUE_DEVELOPER_NAME_CCA_DATA_LOAD, 
		                                         'Site_Issue__c', 'Current_Results__c', 'Case', 'Current_Results__c'));
		syncFieldList.add(createSyncField('MS.DiagNotes_DL->Case.DiagNotes', Constants.RECORD_TYPE_SITE_ISSUE_DEVELOPER_NAME_CCA_DATA_LOAD, 
		                                         'Site_Issue__c', 'Diagnostics_Notes_Comments__c', 'Case', 'Diagnostics_Notes__c'));
		syncFieldList.add(createSyncField('MS.ExpectedRes->Case.ExpectedRes_DL', Constants.RECORD_TYPE_SITE_ISSUE_DEVELOPER_NAME_CCA_DATA_LOAD, 
		                                         'Site_Issue__c', 'Expected_Results__c', 'Case', 'Expected_Results__c'));
		syncFieldList.add(createSyncField('MS.InteractionType->Case.Origin_DL', Constants.RECORD_TYPE_SITE_ISSUE_DEVELOPER_NAME_CCA_DATA_LOAD, 
		                                         'Site_Issue__c', 'Interaction_Type__c', 'Case', 'Origin'));
		syncFieldList.add(createSyncField('MS.ResSummary->Case.ResSummary_DL', Constants.RECORD_TYPE_SITE_ISSUE_DEVELOPER_NAME_CCA_DATA_LOAD, 
		                                         'Site_Issue__c', 'Member_Facing_Resolution_Summary__c', 'Case', 'Member_Facing_Resolution_Summary__c'));
		syncFieldList.add(createSyncField('MS.Project->Case.ProjectSrc_DL', Constants.RECORD_TYPE_SITE_ISSUE_DEVELOPER_NAME_CCA_DATA_LOAD, 
		                                         'Site_Issue__c', 'Project__c', 'Case', 'Project_Source_MS__c'));
		syncFieldList.add(createSyncField('MS.ReportedBy->Case.ContactId_DL', Constants.RECORD_TYPE_SITE_ISSUE_DEVELOPER_NAME_CCA_DATA_LOAD, 
		                                         'Site_Issue__c', 'Reported_By__c', 'Case', 'ContactId'));
		syncFieldList.add(createSyncField('MS.IssuePriority->Case.Priority_DL', Constants.RECORD_TYPE_SITE_ISSUE_DEVELOPER_NAME_CCA_DATA_LOAD, 
		                                         'Site_Issue__c', 'Site_Issue_Priority__c', 'Case', 'Priority'));
		syncFieldList.add(createSyncField('MS.ShortDescription->Case.Subj_DL', Constants.RECORD_TYPE_SITE_ISSUE_DEVELOPER_NAME_CCA_DATA_LOAD, 
		                                         'Site_Issue__c', 'Site_Issue_Short_Description__c', 'Case', 'Subject'));
		syncFieldList.add(createSyncField('MS.Status->Case.Status_DL', Constants.RECORD_TYPE_SITE_ISSUE_DEVELOPER_NAME_CCA_DATA_LOAD, 
		                                         'Site_Issue__c', 'Status__c', 'Case', 'Status'));
		syncFieldList.add(createSyncField('MS.StepsToRepro->Case.StepsToRepro_DL', Constants.RECORD_TYPE_SITE_ISSUE_DEVELOPER_NAME_CCA_DATA_LOAD, 
		                                         'Site_Issue__c', 'Steps_to_Reproduce__c', 'Case', 'Steps_to_Reproduce_MS__c'));
		syncFieldList.add(createSyncField('MS.SupportAnalyst->Case.TIIAnalyst_DL', Constants.RECORD_TYPE_SITE_ISSUE_DEVELOPER_NAME_CCA_DATA_LOAD, 
		                                         'Site_Issue__c', 'Support_Analyst__c', 'Site_Issue__c', 'Tier_II_Support_Analyst_Contact__c'));
		syncFieldList.add(createSyncField('MS.BrowserUsd->Case.BrowserUsd', Constants.RECORD_TYPE_SITE_ISSUE_DEVELOPER_NAME_CCA_SUPPORT_REQUEST, 
		                                         'Site_Issue__c', 'Browser_Used__c', 'Case', 'Browser_Used__c'));
		syncFieldList.add(createSyncField('MS.IssueDescription->Case.Description', Constants.RECORD_TYPE_SITE_ISSUE_DEVELOPER_NAME_CCA_SUPPORT_REQUEST, 
		                                         'Site_Issue__c', 'Crimson_Site_Issue_Description__c', 'Case', 'Description'));
		syncFieldList.add(createSyncField('MS.CurrentResults->Case.CurrentResults', Constants.RECORD_TYPE_SITE_ISSUE_DEVELOPER_NAME_CCA_SUPPORT_REQUEST, 
		                                         'Site_Issue__c', 'Current_Results__c', 'Case', 'Current_Results__c'));
		syncFieldList.add(createSyncField('MS.ExpectedResult->Case.ExpectedResult', Constants.RECORD_TYPE_SITE_ISSUE_DEVELOPER_NAME_CCA_SUPPORT_REQUEST, 
		                                         'Site_Issue__c', 'Expected_Results__c', 'Case', 'Expected_Results__c'));
		syncFieldList.add(createSyncField('MS.InteractionType->Case.Origin', Constants.RECORD_TYPE_SITE_ISSUE_DEVELOPER_NAME_CCA_SUPPORT_REQUEST, 
		                                         'Site_Issue__c', 'Interaction_Type__c', 'Case', 'Origin'));
		syncFieldList.add(createSyncField('MS.ResSummary->Case.ResSummary', Constants.RECORD_TYPE_SITE_ISSUE_DEVELOPER_NAME_CCA_SUPPORT_REQUEST, 
		                                         'Site_Issue__c', 'Member_Facing_Resolution_Summary__c', 'Case', 'Member_Facing_Resolution_Summary__c'));
		syncFieldList.add(createSyncField('MS.Project->Case.ProjectSrc', Constants.RECORD_TYPE_SITE_ISSUE_DEVELOPER_NAME_CCA_SUPPORT_REQUEST, 
		                                         'Site_Issue__c', 'Project__c', 'Case', 'Project_Source_MS__c'));
		syncFieldList.add(createSyncField('MS.ReportedBy->Case.ContactId', Constants.RECORD_TYPE_SITE_ISSUE_DEVELOPER_NAME_CCA_SUPPORT_REQUEST, 
		                                         'Site_Issue__c', 'Reported_By__c', 'Case', 'ContactId'));
		syncFieldList.add(createSyncField('MS.IssuePriority->Case.Priority', Constants.RECORD_TYPE_SITE_ISSUE_DEVELOPER_NAME_CCA_SUPPORT_REQUEST, 
		                                         'Site_Issue__c', 'Site_Issue_Priority__c', 'Case', 'Priority'));
		syncFieldList.add(createSyncField('MS.ShortDescription->Case.Subj', Constants.RECORD_TYPE_SITE_ISSUE_DEVELOPER_NAME_CCA_SUPPORT_REQUEST, 
		                                         'Site_Issue__c', 'Site_Issue_Short_Description__c', 'Case', 'Subject'));
		syncFieldList.add(createSyncField('MS.Status->Case.Status', Constants.RECORD_TYPE_SITE_ISSUE_DEVELOPER_NAME_CCA_SUPPORT_REQUEST, 
		                                         'Site_Issue__c', 'Status__c', 'Case', 'Status'));
		syncFieldList.add(createSyncField('MS.StepsToRepro->Case.StepsToRepro', Constants.RECORD_TYPE_SITE_ISSUE_DEVELOPER_NAME_CCA_SUPPORT_REQUEST, 
		                                         'Site_Issue__c', 'Steps_to_Reproduce__c', 'Case', 'Steps_to_Reproduce_MS__c'));
		syncFieldList.add(createSyncField('MS.SupportAnalyst->Case.TIIAnalyst', Constants.RECORD_TYPE_SITE_ISSUE_DEVELOPER_NAME_CCA_SUPPORT_REQUEST, 
		                                         'Site_Issue__c', 'Support_Analyst__c', 'Site_Issue__c', 'Tier_II_Support_Analyst_Contact__c'));
        syncFieldList.add(createSyncField('MS.PHI->Case.PHI', Constants.RECORD_TYPE_SITE_ISSUE_DEVELOPER_NAME_CCA_SUPPORT_REQUEST, 
		                                         'Site_Issue__c', 'PHI__c', 'Case', 'PHI__c'));
		syncFieldList.add(createSyncField('Case.CaseNum->MS.IssueNum_DL', Constants.RECORD_TYPE_CASE_DEVELOPER_NAME_PT_DATA_LOAD, 
		                                         'Case', 'CaseNumber', 'Site_Issue__c', 'Case_Number__c'));
		syncFieldList.add(createSyncField('Case.ContactId->MS.ReportedBy_DL', Constants.RECORD_TYPE_CASE_DEVELOPER_NAME_PT_DATA_LOAD, 
		                                         'Case', 'ContactId', 'Site_Issue__c', 'Reported_By__c'));
		syncFieldList.add(createSyncField('Case.CurrentRes->MS.CurrentRes_DL', Constants.RECORD_TYPE_CASE_DEVELOPER_NAME_PT_DATA_LOAD, 
		                                         'Case', 'Current_Results__c', 'Site_Issue__c', 'Current_Results__c'));
		syncFieldList.add(createSyncField('Case.DiagNotes->MS.DiagNotes_DL', Constants.RECORD_TYPE_CASE_DEVELOPER_NAME_PT_DATA_LOAD, 
		                                         'Case', 'Diagnostics_Notes__c', 'Site_Issue__c', 'Diagnostics_Notes_Comments__c'));
		syncFieldList.add(createSyncField('Case.ExpectedRes->MS.ExpextedRes_DL', Constants.RECORD_TYPE_CASE_DEVELOPER_NAME_PT_DATA_LOAD, 
		                                         'Case', 'Expected_Results__c', 'Site_Issue__c', 'Expected_Results__c'));
		syncFieldList.add(createSyncField('Case.ResSummary->MS.ResSummary_DL', Constants.RECORD_TYPE_CASE_DEVELOPER_NAME_PT_DATA_LOAD, 
		                                         'Case', 'Member_Facing_Resolution_Summary__c', 'Site_Issue__c', 'Member_Facing_Resolution_Summary__c'));
		syncFieldList.add(createSyncField('Case.Origin->MS.InteractionType_DL', Constants.RECORD_TYPE_CASE_DEVELOPER_NAME_PT_DATA_LOAD, 
		                                         'Case', 'Origin', 'Site_Issue__c', 'Interaction_Type__c'));
		syncFieldList.add(createSyncField('Case.Priority->MS.IssuePriority_DL', Constants.RECORD_TYPE_CASE_DEVELOPER_NAME_PT_DATA_LOAD, 
		                                         'Case', 'Priority', 'Site_Issue__c', 'Site_Issue_Priority__c'));
		syncFieldList.add(createSyncField('Case.ProjectSrc->MS.Project_DL', Constants.RECORD_TYPE_CASE_DEVELOPER_NAME_PT_DATA_LOAD, 
		                                         'Case', 'Project_Source_MS__c', 'Site_Issue__c', 'Project__c'));
		syncFieldList.add(createSyncField('Case.Status->MS.Status_DL', Constants.RECORD_TYPE_CASE_DEVELOPER_NAME_PT_DATA_LOAD, 
		                                         'Case', 'Status', 'Site_Issue__c', 'Status__c'));
		syncFieldList.add(createSyncField('Case.StepsToRepro->MS.StepsToRepro_DL', Constants.RECORD_TYPE_CASE_DEVELOPER_NAME_PT_DATA_LOAD, 
		                                         'Case', 'Steps_to_Reproduce_MS__c', 'Site_Issue__c', 'Steps_to_Reproduce__c'));
		syncFieldList.add(createSyncField('Case.Subj->MS.ShortDescription_DL', Constants.RECORD_TYPE_CASE_DEVELOPER_NAME_PT_DATA_LOAD, 
		                                         'Case', 'Subject', 'Site_Issue__c', 'Site_Issue_Short_Description__c'));
		syncFieldList.add(createSyncField('Case.Tier1->MS.Tier1_DL', Constants.RECORD_TYPE_CASE_DEVELOPER_NAME_PT_DATA_LOAD, 
		                                         'Case', 'Tier_I_Support_Analyst__c', 'Site_Issue__c', 'Tier_I_Support_Analyst__c'));
		syncFieldList.add(createSyncField('Case.TIIAnalyst->MS.SupportAnalyst_DL', Constants.RECORD_TYPE_CASE_DEVELOPER_NAME_PT_DATA_LOAD, 
		                                         'Case', 'Tier_II_Support_Analyst_Contact__c', 'Site_Issue__c', 'Support_Analyst__c'));
		syncFieldList.add(createSyncField('Case.CaseNum->MS.IssueNum', Constants.RECORD_TYPE_CASE_DEVELOPER_NAME_PT_SUPPORT_REQUEST, 
		                                         'Case', 'CaseNumber', 'Site_Issue__c', 'Case_Number__c'));
		syncFieldList.add(createSyncField('Case.ContactId->MS.ReportedBy', Constants.RECORD_TYPE_CASE_DEVELOPER_NAME_PT_SUPPORT_REQUEST, 
		                                         'Case', 'ContactId', 'Site_Issue__c', 'Reported_By__c'));
		syncFieldList.add(createSyncField('Case.CurrentResults->MS.CurrentResults', Constants.RECORD_TYPE_CASE_DEVELOPER_NAME_PT_SUPPORT_REQUEST, 
		                                         'Case', 'Current_Results__c', 'Site_Issue__c', 'Current_Results__c'));
		syncFieldList.add(createSyncField('Case.Description->MS.IssueDescription', Constants.RECORD_TYPE_CASE_DEVELOPER_NAME_PT_SUPPORT_REQUEST, 
		                                         'Case', 'Description', 'Site_Issue__c', 'Crimson_Site_Issue_Description__c'));
		syncFieldList.add(createSyncField('Case.ExpectedResult->MS.ExpextedResult', Constants.RECORD_TYPE_CASE_DEVELOPER_NAME_PT_SUPPORT_REQUEST, 
		                                         'Case', 'Expected_Results__c', 'Site_Issue__c', 'Expected_Results__c'));
		syncFieldList.add(createSyncField('Case.ResSummary->MS.ResSummary', Constants.RECORD_TYPE_CASE_DEVELOPER_NAME_PT_SUPPORT_REQUEST, 
		                                         'Case', 'Member_Facing_Resolution_Summary__c', 'Site_Issue__c', 'Member_Facing_Resolution_Summary__c'));
		syncFieldList.add(createSyncField('Case.Origin->MS.InteractionType', Constants.RECORD_TYPE_CASE_DEVELOPER_NAME_PT_SUPPORT_REQUEST, 
		                                         'Case', 'Origin', 'Site_Issue__c', 'Interaction_Type__c'));
		syncFieldList.add(createSyncField('Case.Priority->MS.IssuePriority', Constants.RECORD_TYPE_CASE_DEVELOPER_NAME_PT_SUPPORT_REQUEST, 
		                                         'Case', 'Priority', 'Site_Issue__c', 'Site_Issue_Priority__c'));
		syncFieldList.add(createSyncField('Case.ProjectSrc->MS.Project', Constants.RECORD_TYPE_CASE_DEVELOPER_NAME_PT_SUPPORT_REQUEST, 
		                                         'Case', 'Project_Source_MS__c', 'Site_Issue__c', 'Project__c'));
		syncFieldList.add(createSyncField('Case.Status->MS.Status', Constants.RECORD_TYPE_CASE_DEVELOPER_NAME_PT_SUPPORT_REQUEST, 
		                                         'Case', 'Status', 'Site_Issue__c', 'Status__c'));
		syncFieldList.add(createSyncField('Case.StepsToRepro->MS.StepsToRepro', Constants.RECORD_TYPE_CASE_DEVELOPER_NAME_PT_SUPPORT_REQUEST, 
		                                         'Case', 'Steps_to_Reproduce_MS__c', 'Site_Issue__c', 'Steps_to_Reproduce__c'));
		syncFieldList.add(createSyncField('Case.Subj->MS.ShortDescription', Constants.RECORD_TYPE_CASE_DEVELOPER_NAME_PT_SUPPORT_REQUEST, 
		                                         'Case', 'Subject', 'Site_Issue__c', 'Site_Issue_Short_Description__c'));
		syncFieldList.add(createSyncField('Case.Tier1->MS.Tier1', Constants.RECORD_TYPE_CASE_DEVELOPER_NAME_PT_SUPPORT_REQUEST, 
		                                         'Case', 'Tier_I_Support_Analyst__c', 'Site_Issue__c', 'Tier_I_Support_Analyst__c'));
		syncFieldList.add(createSyncField('Case.TIIAnalyst->MS.SupportAnalyst', Constants.RECORD_TYPE_CASE_DEVELOPER_NAME_PT_SUPPORT_REQUEST, 
		                                         'Case', 'Tier_II_Support_Analyst_Contact__c', 'Site_Issue__c', 'Support_Analyst__c'));
		syncFieldList.add(createSyncField('Case.PHI->MS.PHI', Constants.RECORD_TYPE_CASE_DEVELOPER_NAME_PT_SUPPORT_REQUEST, 
		                                         'Case', 'PHI__c', 'Site_Issue__c', 'PHI__c'));
        
        //Added - by- Abhinav Sharma - 06/15/2016 - CR-20150202-8628
        //Start from here
        syncFieldList.add(createSyncField('MS.DLPB__c->Case.DLPB__c', Constants.RECORD_TYPE_CASE_DEVELOPER_NAME_PT_SUPPORT_REQUEST, 
		                                         'Site_Issue__c', 'Data_Load_Period_Begin__c', 'Case', 'Description'));
        syncFieldList.add(createSyncField('MS.DLPE__c->Case.DLPE__c', Constants.RECORD_TYPE_CASE_DEVELOPER_NAME_PT_SUPPORT_REQUEST, 
		                                         'Site_Issue__c', 'Data_Load_Period_End__c', 'Case', 'Description'));
        
        syncFieldList.add(createSyncField('MS.DLPB1__c->Case.DLPB1__c', Constants.RECORD_TYPE_SITE_ISSUE_DEVELOPER_NAME_CCA_DATA_LOAD, 
		                                         'Site_Issue__c', 'Data_Load_Period_Begin__c', 'Case', 'Description'));
        syncFieldList.add(createSyncField('MS.DLPE1__c->Case.DLPE1__c', Constants.RECORD_TYPE_SITE_ISSUE_DEVELOPER_NAME_CCA_DATA_LOAD,
                                          'Site_Issue__c', 'Data_Load_Period_Begin__c', 'Case', 'Description'));
		
        
        syncFieldList.add(createSyncField('Case.DLPB__c->MS.DLPB__c', Constants.RECORD_TYPE_CASE_DEVELOPER_NAME_PT_SUPPORT_REQUEST, 
		                                         'Case', 'Date_of_Presentation__c', 'Site_Issue__c', 'Data_Load_Period_Begin__c'));
        syncFieldList.add(createSyncField('Case.DLPE__c->MS.DLPE__c', Constants.RECORD_TYPE_CASE_DEVELOPER_NAME_PT_SUPPORT_REQUEST, 
		                                  		'Case', 'Date_of_Presentation__c', 'Site_Issue__c', 'Data_Load_Period_End__c'));
        
        syncFieldList.add(createSyncField('Case.DLPB1__c->MS.DLPB1__c', Constants.RECORD_TYPE_ID_CASE_PT_DATA_LOAD, 
		                                         'Case', 'Date_of_Presentation__c', 'Site_Issue__c', 'Data_Load_Period_Begin__c'));
        syncFieldList.add(createSyncField('Case.DLPE1__c->MS.DLPE1__c', Constants.RECORD_TYPE_ID_CASE_PT_DATA_LOAD, 
		                                  		'Case', 'Date_of_Presentation__c', 'Site_Issue__c', 'Data_Load_Period_End__c'));
        //Upto here
        
    	insert syncFieldList;
    }
    
    
	//Create a Registration
	public static Event_Registration__c createRegistration(Id eventId, Id contactId, boolean CreateAndInsert) {
        // create the registration
        Event_Registration__c registration = new Event_Registration__c();
        registration.Contact__c = contactId;
        registration.Advisory_Event__c = eventId;
        registration.Status__c = 'Scheduled';
        if (CreateAndInsert) insert registration;
        
        return registration;
    }
    
    //Create a meeting
    public static Advisory_Event__c createEvent(boolean createAndInsert) {
        // create the meeting
        Advisory_Event__c meeting = createEvent(null, null, createAndInsert);
        if (createAndInsert) insert meeting;
        return meeting;
    }
    
    //create a meeting with a specific record type and cost center
    public static Advisory_Event__c createEvent(Id recordTypeId, Id costCenterId, boolean createAndInsert) {
        // create the meeting
        Advisory_Event__c meeting = new Advisory_Event__c(Cost_Center__c = costCenterId,
                                                          Begins__c = system.now().addDays(-30),
                                                          Ends__c = system.now().addDays(30),
                                                          Date_Begins__c = system.today().addDays(-30),
                                                          Date_Ends__c = system.today().addDays(30),
                                                          Type__c = 'Onsite');
        if (recordTypeId != null)
        	meeting.RecordTypeId = recordTypeId;
        
        if (createAndInsert) insert meeting;
        return meeting;
    }
    
    //Added By - Abhinav Sharma - 05/30/2016 - CR-20150202-8624
    //Start from here
    //Create a case comment
    public static CaseComment createNewCaseComment(Case parentCase, boolean createAndInsert) {
        
        //Checking parent case instance for null value and accordingly populating CaseComment instance with fields value
        if(parentCase != null && parentCase.Id != null) {
        	
            //Initializing case comment instance
            CaseComment com = new CaseComment();
            
            //Populating fields with appropriate values
            com.ParentId = parentCase.Id;
            com.CommentBody = 'Testing Going On';
            com.IsPublished = true;
			
            //Checking for flag value
        	if (createAndInsert) insert com;
            
            //Returning case comment instance
            return com;
        } else {
            return null;
		}
    }
    //Upto here
    
    //Added By - Abhinav Sharma - 06/02/2016 - CR-20150202-8625
    //Start from here
    //Constants like variables useful in test classes 
    public final static string EXPERT_CENTER_CASE_RECORD_TYPE = 'Expert Center';
    public final static string INTERNATIONAL_CASE_RECORD_TYPE = 'International';
    public final static string CONTACT_EMPLOYEE_RECORD_TYPE = 'Employee';
    public final static string CONTACT_OBJECT = 'Contact';
    public final static string SELECTED_DEADLINE_DATE_ERROR = 'Selected deadline date is conflicting with some Case Blackout Days records';
    public final static string ID_NOT_SPECIFIED_IN_UPDATE_CALL = 'Id not specified in an update call';
    //upto here
    
    //Added By - Mahedra Swarnkar - 07/25/2016 - CR-20160229-9651 - Starts from Here
    public final static  string DEADLINE_REASON_NOT_POPULATED_ERROR = 'Deadline is less than 5 business days from Today. Please provide a reason for this urgency.';
    //Added By - Mahedra Swarnkar - 07/25/2016 - CR-20160229-9651 - Ends Here
    
    //Added By - Abhinav Sharma - 06/03/2016 - CR-20150202-8626
    //Start from here
    //Constants like variables useful in test classes
    public static final string CASE_RECORD_TYPE_EAB_CUSTOM = 'Ask EAB';
    public static final string CASE_RECORD_TYPE_IRC_REQUEST = 'IRC Request';
    public static final string CASE_RECORD_TYPE_MEMBER_AND_SUPPORT_REQUEST = 'Member & Employee Support';
    //upto here
    
    //Added By - Abhinav Swarnkar - 06/07/2016 - CR-20150202-8629
    //Start from here
    //Constants like variables useful in test classes
    public static final String CHANGE_REQUEST_OBJECT = 'SFDC_Change_Request__c';
    public static final String CHANGE_REQUEST_RECORD_TYPE_LEVEL_I = 'Level I';
    public static final String CHANGE_REQUEST_RECORD_TYPE_LEVEL_II = 'Level II';
    public static final String CHANGE_REQUEST_RECORD_TYPE_LEVEL_III = 'Level III';
    //Upto here
}