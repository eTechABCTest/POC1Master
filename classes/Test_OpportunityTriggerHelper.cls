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
*/
/**
  *   Purpose         :     Test class for Trigger_Opportunity
  *            
  *   Create By       :     Bhavi Sharma   
  * 
  *   Created Date    :     01/31/2014
  *
  *   Revision Log    :     V_1.0 - Created
  *                         V_1.1 - Modified by - Abhinav Sharma - CR-20160127-9565 - 01/29/2016 - Commented out the grade field reference
  *                         V_1.2 - Modified by - Abhinav Sharma - CR-20150202-8638 - 7/21/2016 - A code refactor CR
  *                         V_1.3 - Modified by - MAhendra Swarnkar - CR-20151111-9378 - 7/25/2016 - Removed the "Welcome_Email_Sent__c", "Contact_List_Received__c", "Contact_List_Added_In_Salesforce__c", "Southwind_Program_Type__c" fields references.
  *                         V_1.4 - Modified by - Subhash Garhwal - CR-20160414-9762 - 07/19/2016 - Added a new method testPreventManualDuplicateProgramOpportunities.
  *                         V_1.5 - Modified by - Subhash Garhwal - CR-20160414-9762 - 07/20/2016 - Added a new method testValidateProgramOpportunities.
  *                         V_1.6 - Modified by - Subhash Garhwal - CR-20160414-9762 - 07/21/2016 - Added a new method testCreateIntegratedAccountForRenewalOpps
  *                         V_1.7 - Modified by - Mahendra Swarnkar - CR-20151111-9378 - 07/26/2016 - Removed the following field references, since these fields has been deleted in the Test SB via release 52.
  *                                                             "Welcome_Email_Sent__c", "Contact_List_Received__c", "Contact_List_Added_In_Salesforce__c", "Southwind_Program_Type__c"   
  *                         V_1.8 - Merged by - Mahnedra Swarnkar - 8/11/2016 - CR-20160810-10101 - Merged the code From RoyallDev SB to Test SB for CR-10101
  *             V_1.9 - Modified By - Mahendra Swarnkar - 10/07/2016 - CR-20160825-10152 - Updated test_updateOpportunityNonSOXFields method
  *                         V_2.0 - Modified - 10/12/2016 - Subhash Garhwal -  - Q2C Hypercare of Hypercare
  *                         
  * 
  *   Coverage        :     V_1.1 - 89% - OpportunityTriggerHelper
  *                         V_1.2 - 93% - OpportunityTriggerHelper
  **/
    
@isTest(seeAllData=false)
private class Test_OpportunityTriggerHelper {
    
    //Merged by - Mahnedra Swarnkar - 8/11/2016 - CR-20160810-10101 - Merged the code From RoyallDev SB to Test SB for CR-10101 - Statrs From here
    /**
     * Description: Insert an Opportunity with Record Type = "Royall" and verify the name does not auto-update
     * 
     * VH Added 8/10/16
     **/
    static testmethod void testOppNameBypass_Royall_RT() { 
        
        //name of opportunity
        string customOppName = 'This is a Royall Opportunity!';
        //create the Opportunity
        Opportunity o = TestUtilities.CreateNewOpportunity(false);
        o.RecordTypeId = OpportunityTriggerHelper.OPPORTUNITY_ROYALL_RT_ID;
        o.Name = customOppName;
        insert o;

        //verify the name was not modified upon insertion
        o = [SELECT Id, Name FROM Opportunity WHERE Id = :o.Id];
        system.assertEquals(o.Name, customOppName, 'Name should not have been overwritten because this is a Royall opportunity record type.');
    }
    //Merged by - Mahnedra Swarnkar - 8/11/2016 - CR-20160810-10101 - Merged the code From RoyallDev SB to Test SB for CR-10101 - Ends here
    
    //Modified by - Abhinav Sharma - CR-20150202-8638 - To refactor the existing code
    /** Description : Method to test out the logic which is responsible to populate "Initial_Visit_Date__c" field.
    **/
    static testmethod void myUnitTest() { 

        //Bypass Dupeblocker
        Util.IsTest(true);
        
        //Bypassing Triggers so then test data can be created easily
        Util.byPassAllTriggers = true;
        
        //Flag for triggers: this is just a test, don't do crazy things.
        Util.isTesting = true;
        
        //Create test data
        List<Opportunity> oppList = new List<Opportunity>();
        
        //Populating list with opportunity records instances
        for(integer i=1; i< 4; i++) {
            oppList.add(new Opportunity(Name='Test Opp' + i, CloseDate = system.today()+7, How_many_prewires_were_completed__c = 0, StageName = 'Pending'));
        }
        insert oppList;
        
        //Asserting for the results
        System.assert(oppList != null);
        System.assert(oppList.size() > 0);
        
        List<Event> evntList = new List<Event>();
        Id oppId = oppList[1].Id;
        DateTime DTStart = System.Now();
        Date DStart = Date.newInstance(DTStart.year(), DTStart.month(), DTStart.day());

        for(integer i=1; i<=5; i++) {
            Event evnt  = new Event( WhatId = oppId, StartDateTime = DTStart, ActivityDateTime = DTStart,
            ActivityDate = DStart, EndDateTime = DTStart, Event_Type__c = Constants.EVENT_TYPE_IN_PERSON_VISIT,
            Event_Purpose__c = Constants.EVENT_PURPOSE_RELATIONSHIP_VISIT, Executive_Type__c = 'CXO');
            evntList.add(evnt);
        }
        
        //Enabling triggers
        Util.byPassAllTriggers = false;
        
        //Setting flag values
        OpportunityTriggerHelper.EXECUTE_TRIGGER_BEFORE_UPDATE = true;
        OpportunityTriggerHelper.EXECUTE_TRIGGER_AFTER_UPDATE = true;

        //Insert data in bulk
        insert evntList;
        
        //Asserting for the results
        System.assert(evntList != null);
        System.assert(evntList.size() > 0);

        //Start testing from here
        Test.startTest();

        //Assert for the result if opportunity Initial Visit date is latest one
        oppList = [SELECT Initial_Visit_Date__c 
                            FROM Opportunity 
                            WHERE Id =: oppId];
        
        //Asserting for the results
        System.assert(oppList != null);
        System.assert(oppList.size() > 0);
        System.assertEquals(Date.valueOf(DTStart).format(), oppList[0].Initial_Visit_Date__c.format());

        //loop through the events and update the cancelled flag as true and assert the results
        for(Event evnt : evntList) {
            evnt.Cancelled_Did_Not_Occur__c = true;
        }

        //Update the events
        update evntList;
        
        //Asserting for the results
        System.assert(evntList != null);
        System.assert(evntList.size() > 0);

        ///Assert for the result if opportunity Initial Visit date is latest one
        oppList = [SELECT Initial_Visit_Date__c 
                            FROM Opportunity 
                            WHERE Id =: oppId];
                            
        //Asserting for the results
        System.assert(oppList != null);
        System.assert(oppList.size() > 0);                      
        System.assertEquals(null, oppList[0].Initial_Visit_Date__c);

        //Test bacth service
        Batch_UpdateInitialVisitDate batchJob = new Batch_UpdateInitialVisitDate();
        batchJob.SOQLQuery = 'Select Id from Opportunity limit 1';
        database.executeBatch(batchJob, 1); 

        //stop test here
        Test.stopTest();
    }

    //Modified by - Abhinav Sharma - CR-20150202-8638 - To refactor the existing code
    /** Description : Method to test out the functionality build for CR-20120920-1514
    **/
    static testmethod void myUnitTest1() { 

        //Bypass Dupeblocker
        Util.IsTest(true);
        
        //Bypassing Triggers so then test data can be created easily
        Util.byPassAllTriggers = true;
        
        //Flag for triggers: this is just a test, don't do crazy things.
        Util.isTesting = true;
        
        //Contacts
        List<Contact> contacts = new List<Contact>();
        Contact contact_1 = new Contact(LastName = 'Test', FirstName = 'Con');
        Contact contact_2 = new Contact(LastName = 'Testtesting', FirstName = 'ConTest');
        Contact contact_3 = new Contact(LastName = 'TesttestingTest', FirstName = 'ConTestTest');
        contacts.add(contact_1); contacts.add(contact_2); contacts.add(contact_3);
        insert contacts;
        
        //Assert for the results
        System.assert(contacts != null);
        System.assert(contacts.size() == 3);
        
        //Map
        Map<Id, Opportunity> mapOpportunity = new Map<Id, Opportunity>();

        //Boolean Variable
        Boolean DO_NOT_OVERWRITE_INITIAL_VISIT_DATE = false;

        //Date and Date Time Varibles
        DateTime DTStart = System.Now();
        Date DStart = Date.newInstance(DTStart.year(), DTStart.month(), DTStart.day());

        //Opportunity
        Opportunity opp = new Opportunity();
        opp.CloseDate = Date.today();
        opp.Name = 'Test_asddlkXYX112Z';
        opp.StageName = 'Prospect';
        opp.Main_Contact__c = contacts[0].Id;
        insert opp;

        //Populate Map with Values
        mapOpportunity.put(opp.Id, opp);
        
        //List of OpportunityContactRole records (Will Update)
        List<OpportunityContactRole> oCRsList = new List<OpportunityContactRole>();
            
        //Opportunity Contact Role record instance
        OpportunityContactRole oCRoleInsert1 = new OpportunityContactRole();
        
        //Populating OCR instance with field values
        oCRoleInsert1.ContactId = opp.Main_Contact__c;
        oCRoleInsert1.IsPrimary = true;
        oCRoleInsert1.OpportunityId = opp.Id;
        oCRoleInsert1.Role = System.Label.OCR_CONATCT_DEFAULT_ROLE;
        
        //Opportunity Contact Role record instance
        OpportunityContactRole oCRoleInsert2 = new OpportunityContactRole();
        
        //Populating OCR instance with field values
        oCRoleInsert2.ContactId = contacts[1].Id;
        oCRoleInsert2.IsPrimary = false;
        oCRoleInsert2.OpportunityId = opp.Id;
        oCRoleInsert2.Role = 'Other';
        
        //Adding instance into the list to be inserted
        oCRsList.add(oCRoleInsert1);
        oCRsList.add(oCRoleInsert2);
        insert oCRsList;
                    
        //Event
        Event evnt  = new Event( WhatId = opp.Id, StartDateTime = DTStart, ActivityDateTime = DTStart,
        ActivityDate = DStart, EndDateTime = DTStart,  Cancelled_Did_Not_Occur__c = false,
        Event_Type__c = Constants.EVENT_TYPE_IN_PERSON_VISIT, Event_Purpose__c = 'Initial');
        
        //Start testing from here
        Test.startTest();
        
        //Enabling trigger
        Util.byPassAlltriggers = false;
        
        //Setting flag values
        OpportunityTriggerHelper.EXECUTE_TRIGGER_BEFORE_UPDATE = true;
        OpportunityTriggerHelper.EXECUTE_TRIGGER_AFTER_UPDATE = true;

        //Calling Method
        OpportunityTriggerHelper.updateInitialVisitDateByEventDate(mapOpportunity);
        
        //Enabling triggers
        Util.byPassAllTriggers = false;
        
        //Setting flag values
        OpportunityTriggerHelper.EXECUTE_TRIGGER_BEFORE_UPDATE = true;
        OpportunityTriggerHelper.EXECUTE_TRIGGER_AFTER_UPDATE = true;
        
        //Update Main contact on opportunity
        opp.Main_Contact__c = contacts[2].Id;
        update opp;
        
        //Stop testing here
        Test.stopTest();
        
        //Enabling triggers
        Util.byPassAllTriggers = false;
        
        //Setting flag values
        OpportunityTriggerHelper.EXECUTE_TRIGGER_BEFORE_UPDATE = true;
        OpportunityTriggerHelper.EXECUTE_TRIGGER_AFTER_UPDATE = true;
        
        //Update opportunities
        opp.Main_Contact__c = contacts[1].Id;
        update opp;
    }

    //Modified by - Abhinav Sharma - CR-20150202-8638 - To refactor the existing code
    /** Description : Method to test out the functionality build for CR-20120920-1514
    **/
    static testmethod void  testTrgMarketWarmingEffortTrigger() {
        
        //Bypass Dupeblocker
        Util.IsTest(true);
        
        //Bypassing Triggers so then test data can be created easily
        Util.byPassAllTriggers = true;
        
        //Flag for triggers: this is just a test, don't do crazy things.
        Util.isTesting = true;

        // create 2 programs
        Program__c prog = TestUtilities.CreateNewProgram(false);
        Program__c prog2 = TestUtilities.CreateNewProgram(false);
        List<Program__c> programsToInsert = new List<Program__c> { prog, prog2 };
        insert programsToInsert;
        
        //Asserting for the results
        System.assert(programsToInsert != null);
        System.assert(programsToInsert.size() > 0);

        //Campaign
        Campaign camp = createMarketWarmingCampaign(prog.Id);
        insert camp;

        //Contact
        Contact ct = createContact();
        insert ct;

        //Contact
        Contact ct2 = createContact();
        ct2.email = 'testContact@email.com';
        insert ct2;

        //Opportunity
        Opportunity opp = new Opportunity();
        opp.CloseDate = Date.today();
        opp.Name = 'Test_asddlkXYX112Z';
        opp.StageName = 'Prospect';
        opp.Program__c = prog.id; 
        insert opp;

        //Opportunity contact role
        OpportunityContactRole ocr = new OpportunityContactRole(); // relate contact to opportunity
        ocr.ContactId = ct.id;
        ocr.OpportunityId = opp.id;
        insert ocr;

        //Opportunity contact role
        OpportunityContactRole ocr2 = new OpportunityContactRole(); // relate 2nd contact to opportunity
        ocr2.ContactId = ct2.id;
        ocr2.OpportunityId = opp.id;
        insert ocr2;

        //Querying for the updated opportunity details
        Opportunity updatedOpportunity = [SELECT id, Marketing_Warming_Effort__c, StageName, Primary_Reason_Lost__c, 
                                          Program__c, Additional_Info_Primary_Reason_Lost__c
                                          FROM Opportunity
                                          WHERE id=:opp.id];

        //Asserting for the results
        System.assert(updatedOpportunity != null);
        System.assertEquals(prog.id,updatedOpportunity.program__c);
        
        //Updating fields values on the opportunity
        updatedOpportunity.StageName = 'Closed Lost';
    updatedOpportunity.Additional_Info_Primary_Reason_Lost__c = 'Implementation Failure';
        updatedOpportunity.Marketing_Warming_Effort__c = 'YES';
        updatedOpportunity.Primary_Reason_Lost__c = 'Bad Timing';
        
        //Enabling triggers
        Util.byPassAllTriggers = false;
        
        //Setting flag values
        OpportunityTriggerHelper.EXECUTE_TRIGGER_BEFORE_UPDATE = true;
        OpportunityTriggerHelper.EXECUTE_TRIGGER_AFTER_UPDATE = true;
        
        //Updating opportunity
        update updatedOpportunity;

        //Asserting for the results
        System.assert(updatedOpportunity != null);
        System.assertEquals('Closed Lost',updatedOpportunity.StageName);
        System.assertEquals('YES',updatedOpportunity.Marketing_Warming_Effort__c);
    System.assertEquals('Implementation Failure', updatedOpportunity.Additional_Info_Primary_Reason_Lost__c);
        System.assertEquals('Bad Timing',updatedOpportunity.Primary_Reason_Lost__c);

        try {

            List<CampaignMember> cm = [SELECT id, CampaignId, ContactId, Opportunity__c, Status 
                                        FROM CampaignMember
                                        WHERE campaignId=:camp.id 
                                            AND contactId=:ct.id 
                                            AND Opportunity__c=:updatedOpportunity.id];
            
            //Asserting for the results                         
            System.assertNotEquals(null,cm);
            System.assertNotEquals(0,cm.size());

        } catch(System.QueryException e) {
            System.assert(false,'***** THE CAMPAIGN WAS NOT FOUND.');
        }
    }

    //Modified by - Abhinav Sharma - CR-20150202-8638 - To refactor the existing code
    /** Description : Method to test out the functionality asscoaited with "Marketing_Warming_Effort__c" field update and campaign record. 
    **/
    static testmethod void  testTrgMarketWarmingEffortTriggerCampaignNotFound() {

        //Bypass Dupeblocker
        Util.IsTest(true);
        
        //Bypassing Triggers so then test data can be created easily
        Util.byPassAllTriggers = true;
        
        //Flag for triggers: this is just a test, don't do crazy things.
        Util.isTesting = true;
        
        //Insert programs
        Program__c prog = TestUtilities.CreateNewProgram(false);
        Program__c prog2 = TestUtilities.CreateNewProgram(false);
        List<Program__c> programsToInsert = new List<Program__c> { prog, prog2 };
        insert programsToInsert;
        
        //Asserting for the results
        System.assert(programsToInsert != null);
        System.assert(programsToInsert.size() > 0);

        //Insert Campaign
        Campaign camp = createMarketWarmingCampaign(prog.Id);
        camp.Primary_Program__c = prog2.Id;
        insert camp;
        
        //Asserting for the results
        System.assertNotEquals(null,camp.id);
        
        //Contacts
        Contact ct = TestUtilities.CreateNewContact(false);
        Contact ct2 = TestUtilities.CreateNewContact(false);
        List<Contact> contactsToInsert = new List<Contact> { ct, ct2 };
        insert contactsToInsert;
        
        //Asserting for the results
        System.assert(contactsToInsert != null);
        System.assert(contactsToInsert.size() > 0);

        Opportunity opp = new Opportunity();
        opp.CloseDate = Date.today();
        opp.Name = 'Test_asddlkXYX112Z';
        opp.StageName = 'Prospect';
        opp.Program__c = prog.id; 
        
        //Test will start from here
        Test.startTest();
        
        //Enabling triggers again
        Util.byPassAlltriggers = false;
        
        //Insert opportunity
        insert opp;
        
        //Assert for the results
        System.assertNotEquals(null,opp.id);
        
        //Opportunity contact role
        OpportunityContactRole ocr = new OpportunityContactRole(); // relate contact to opportunity
        ocr.ContactId = ct.id;
        ocr.OpportunityId = opp.id;
        insert ocr;
        System.assertNotEquals(null,ocr.id);

        //Opportunity contact role
        OpportunityContactRole ocr2 = new OpportunityContactRole(); // relate 2nd contact to opportunity
        ocr2.ContactId = ct2.id;
        ocr2.OpportunityId = opp.id;
        insert ocr2;
        System.assertNotEquals(null,ocr2.id);
        
        //Querying for the opportunity details
        Opportunity updatedOpportunity = [SELECT id, Marketing_Warming_Effort__c, StageName, Primary_Reason_Lost__c, Program__c 
                                                FROM Opportunity
                                                WHERE id = :opp.id];
        
        //Asserting for the results
        System.assert(updatedOpportunity != null);
        System.assertEquals(prog.id,updatedOpportunity.program__c);
        
        //Updating fields values on the opportunity instance
        updatedOpportunity.StageName = 'Closed Lost';
        updatedOpportunity.Marketing_Warming_Effort__c = 'YES';
        updatedOpportunity.Primary_Reason_Lost__c = 'Bad Timing';
        
        try {

            //Setting flag values
            OpportunityTriggerHelper.EXECUTE_TRIGGER_BEFORE_UPDATE = true;
            OpportunityTriggerHelper.EXECUTE_TRIGGER_AFTER_UPDATE = true;

            //Update opportunity
            update updatedOpportunity;
            
            //Asserting for the results
            System.assert(false,'An exception should have been thrown.');
        
        } catch(DmlException e) {
            System.assert(true);
        }   
        
        //Test will stop Here
        Test.stopTest();
    }
     
    //Modified by - Abhinav Sharma - CR-20150202-8638 - To refactor the existing code
    /** Description : Method to test out the functionality implemented for CR-20130117-2187. 
    **/    
    static testmethod void  testRollUpOppsDataOnAccount() {

        //Bypass Dupeblocker
        Util.IsTest(true);
        
        //Bypassing Triggers so then test data can be created easily
        Util.byPassAllTriggers = true;
        
        //Flag for triggers: this is just a test, don't do crazy things.
        Util.isTesting = true;
        
        //Modified by - Abhinav Sharma - 12/23/2015 - CR-20150706-9060 - Updated SF Admin opportunity record type reference 
        //with some other record type reference. Since it is mark eligible for deletion cycle.
        //Creating Test Date
        //Getting Record Type Id Value for opportunity
        ID oppRecordTypeId = [Select Id, Name FROM RecordType WHERE SobjectType = 'Opportunity' 
                                and DeveloperName = 'TD_AM_Standard_Opp'].Id;
                                
        //Asserting for the results
        System.assert(oppRecordTypeId != null);
        
        //Account
        Account account = new Account(Name = 'Test Acc', Account_Formal_Name__c = 'testacc');
        insert account;

        //Contact
        Contact contact = new Contact(LastName = 'Test', FirstName = 'Con');
        insert contact;

        //Program Having Business Line as 'PT'
        Program__c program = TestUtilities.CreateNewProgram(false);
        insert program;
        System.assertNotEquals(null,program.id);

        //Program Having Business Line as 'RI'
        Program__c programRI = TestUtilities.CreateNewRIProgram(false);
        insert programRI;
        System.assertNotEquals(null,programRI.id);

        //Opportunity
        Opportunity opportunity1 = new Opportunity(AccountId = account.Id, Program__c = program.Id, Name = 'Test',
        StageName = 'Pending', pool_Month__c = '1',
        RecordTypeId = oppRecordTypeId, CloseDate = System.today().addDays(7), 
        Pool_Year__c = String.valueOf(Date.Today().Year()),
        Decision_Type__c = 'Need New LOA', Main_Contact__c = contact.Id,
        Previous_Year_Negotiated_Adjustment__c = 4000);

        //Opportunity
        Opportunity opportunity2 = new Opportunity(AccountId = account.Id, Program__c = program.Id, Name = 'Test',
        StageName = 'Pending', pool_Month__c = '1',
        RecordTypeId = oppRecordTypeId, CloseDate = System.today().addDays(7), 
        Pool_Year__c = String.valueOf(Date.Today().Year()),
        Decision_Type__c = 'Need New LOA',
        Previous_Year_Negotiated_Adjustment__c = 5000, Main_Contact__c = contact.Id);

        //List to hold the Opportunity records
        List<Opportunity> opportunitiesPT = new List<Opportunity>();

        //Populate list with the records
        opportunitiesPT.add(opportunity1);
        opportunitiesPT.add(opportunity2);

        //Opportunity
        Opportunity opportunity3 = new Opportunity(AccountId = account.Id, Program__c = programRI.Id, Name = 'Test',
        StageName = 'Pending', pool_Month__c = '1',
        RecordTypeId = oppRecordTypeId, CloseDate = System.today().addDays(7), 
        Pool_Year__c = String.valueOf(Date.Today().Year()),
        Decision_Type__c = 'Need New LOA', Main_Contact__c = contact.Id,
        Previous_Year_Negotiated_Adjustment__c = 3000);

        //Opportunity
        Opportunity opportunity4 = new Opportunity(AccountId = account.Id, Program__c = programRI.Id, Name = 'Test',
        StageName = 'Pending', pool_Month__c = '1',
        RecordTypeId = oppRecordTypeId, CloseDate = System.today().addDays(7), 
        Pool_Year__c = String.valueOf(Date.Today().Year()),
        Decision_Type__c = 'Need New LOA', Main_Contact__c = contact.Id,
        Previous_Year_Negotiated_Adjustment__c = 2000);

        //List to hold the Opportunity records
        List<Opportunity> opportunitiesRI = new List<Opportunity>();

        //Populate list with the records
        opportunitiesRI.add(opportunity3);
        opportunitiesRI.add(opportunity4);
        
        //Setting flag values
        OpportunityTriggerHelper.EXECUTE_TRIGGER_BEFORE_UPDATE = true;
        OpportunityTriggerHelper.EXECUTE_TRIGGER_AFTER_UPDATE = true;
        
        //Enabling triggers
        Util.byPassAllTriggers = false;
        
        //insert opportunities
        insert opportunitiesPT;

        //Start Test From Here
        Test.startTest();

        //Setting flag values
        OpportunityTriggerHelper.EXECUTE_TRIGGER_BEFORE_UPDATE = true;
        OpportunityTriggerHelper.EXECUTE_TRIGGER_AFTER_UPDATE = true;
        
        //Insert
        insert opportunitiesRI;

        //List of Account
        List<Account> accounts = [SELECT ID, Name, RI_TD_Renewal_CV__c, PT_Renewal_CV__c 
                                    FROM Account 
                                    Where ID =: account.Id];
        
        //Asserting for the results
        System.assert(accounts != null);
        System.assertEquals(1, accounts.size());
        System.assertEquals(9000, accounts[0].PT_Renewal_CV__c);
        System.assertEquals(5000, accounts[0].RI_TD_Renewal_CV__c);
        
        //Updating Previous_Year_Negotiated_Adjustment__c field on the RI type opportunity record
        opportunitiesRI[0].Previous_Year_Negotiated_Adjustment__c = 4000;

        //Setting flag values
        OpportunityTriggerHelper.EXECUTE_TRIGGER_BEFORE_UPDATE = true;
        OpportunityTriggerHelper.EXECUTE_TRIGGER_AFTER_UPDATE = true;
        
        //Updating opportunity
        update opportunitiesRI;
        
        //Stop Test Here
        Test.stopTest();
        
        //Asserting for the results
        List<Account> accountsAfterUpdate = [SELECT ID, Name, RI_TD_Renewal_CV__c, PT_Renewal_CV__c 
                                                FROM Account Where ID =: account.Id];
        
        //Asserting for the results
        System.assert(accountsAfterUpdate != null);
        System.assertEquals(1, accountsAfterUpdate.size());
        System.assertEquals(9000, accountsAfterUpdate[0].PT_Renewal_CV__c);
        System.assertEquals(6000, accountsAfterUpdate[0].RI_TD_Renewal_CV__c);
    }
  
    //Modified by - Abhinav Sharma - CR-20150202-8638 - To refactor the existing code
    //Modified By - Abhinav Sharma - 07/02/2014 - CR-20140502-5327
    //04/30/2012 - Bhavi - CR-20130408-2835
    static testMethod void testPopulateOpportunity(){

        //Bypass Dupeblocker
        Util.IsTest(true);
        
        //Bypassing Triggers so then test data can be created easily
        Util.byPassAllTriggers = true;
        
        //Flag for triggers: this is just a test, don't do crazy things.
        Util.isTesting = true;

        //Creating Test Date

        //Getting Record Type Id Value for opportunity
        ID oppRecordTypeId = [Select Id, Name FROM RecordType WHERE SobjectType = 'Opportunity' and Name = 'PT Contract Maintenance'].Id;
        System.assert(oppRecordTypeId != null);
        
        //Account
        Account account = new Account(Name = 'Test Acc', Account_Formal_Name__c = 'testacc');
        insert account;

        //Contact
        Contact contact = new Contact(LastName = 'Test', FirstName = 'Con');
        insert contact;

        //Program Having Business Line as 'PT'
        Program__c program = TestUtilities.CreateNewProgram(false);
        insert program;
        System.assertNotEquals(null,program.id);
  
        //Create membership data
        Membership__c mem = new Membership__c(Account_Name__c = account.id, Program__c = program.id);
        insert mem;
        
        //Setting flag values
        OpportunityTriggerHelper.EXECUTE_TRIGGER_BEFORE_UPDATE = true;
        OpportunityTriggerHelper.EXECUTE_TRIGGER_AFTER_UPDATE = true;

        //Opportunity
        Opportunity opp1 = new Opportunity(AccountId = account.Id, Program__c = program.Id, Name = 'Test-Opportunity',
                                            StageName = 'Verbal Yes', pool_Month__c = '1',
                                            RecordTypeId = oppRecordTypeId, CloseDate = System.today().addDays(7), 
                                            Pool_Year__c = String.valueOf(Date.Today().Year()-2), Amount = 5,
                                            Decision_Type__c = 'Need New LOA', Main_Contact__c = contact.Id,
                                            Previous_Year_Negotiated_Adjustment__c = 4000, Membership__c = mem.Id);

        //Opportunity
        Opportunity opp2 = new Opportunity(AccountId = account.Id, Program__c = program.Id, Name = 'Test-Opportunity',
                                            StageName = 'Verbal Yes', pool_Month__c = '1',
                                            RecordTypeId = oppRecordTypeId, CloseDate = System.today().addDays(7), 
                                            Pool_Year__c = String.valueOf(Date.Today().Year()-1), Amount = 5,
                                            Decision_Type__c = 'Need New LOA', Main_Contact__c = contact.Id,
                                            Previous_Year_Negotiated_Adjustment__c = 4000, Membership__c = mem.Id);
        
        //Opportunity
        Opportunity opp3 = new Opportunity(AccountId = account.Id, Program__c = program.Id, Name = 'Test-Opportunity',
                                            StageName = 'Verbal Yes', pool_Month__c = '1',
                                            RecordTypeId = oppRecordTypeId, CloseDate = System.today().addDays(7), 
                                            Pool_Year__c = String.valueOf(Date.Today().Year()+2), Amount = 5,
                                            Decision_Type__c = 'Need New LOA', Main_Contact__c = contact.Id,
                                            Previous_Year_Negotiated_Adjustment__c = 4000, Membership__c = mem.Id);
        
        //Setting flag values
        OpportunityTriggerHelper.EXECUTE_TRIGGER_BEFORE_UPDATE = true;
        OpportunityTriggerHelper.EXECUTE_TRIGGER_AFTER_UPDATE = true;

        //Enabling triggers
        Util.byPassAlltriggers = false; 
        
        //insert opportunity
        insert opp1;
        
        //List to hold the membership records
        List<Membership__c> memberships = new List<Membership__c>();
        
        //Querying for the updated details
        opp1 = [SELECT Id, Active_Renewal__c, Membership__c FROM Opportunity WHERE Id =: opp1.Id];
        memberships = [SELECT ID, Active_Renewal_Opportunity__c FROM Membership__c WHERE ID =: mem.ID];

        //assert statements
        System.assert(opp1 != null);
        System.assert(memberships != null);
        System.assertEquals(true,opp1.Active_Renewal__c);
        System.assertEquals(memberships[0].Active_Renewal_Opportunity__c, opp1.Id);

        //test starts here                                                  
        Test.startTest();
        
        //Setting flag values
        OpportunityTriggerHelper.EXECUTE_TRIGGER_BEFORE_UPDATE = true;
        OpportunityTriggerHelper.EXECUTE_TRIGGER_AFTER_UPDATE = true;
        
        //Enabling triggers
        Util.byPassAlltriggers = false; 
        
        //Insert opportunity
        insert opp2;

        //Querying for the updated details  
        opp1 = [SELECT Id, Active_Renewal__c, Membership__c FROM Opportunity WHERE Id =: opp1.Id];
        opp2 = [SELECT Id, Active_Renewal__c, Membership__c FROM Opportunity WHERE Id =: opp2.Id];
        memberships = [SELECT ID, Active_Renewal_Opportunity__c FROM Membership__c WHERE ID =: mem.ID];
        
        //assert statements
        System.assert(opp1 != null);
        System.assert(opp2 != null);
        System.assert(memberships != null);
        System.assertEquals(false,opp1.Active_Renewal__c);
        System.assertEquals(true,opp2.Active_Renewal__c);
        System.assertEquals(memberships[0].Active_Renewal_Opportunity__c, opp2.Id);
        
        opp2.Id = null;
        try {
            update opp2;
        } catch(Exception ex){}
        
        //test stops here
        Test.stopTest(); 
    }
    
    //Modified by - Abhinav Sharma - CR-20150202-8638 - To refactor the existing code
    /** Description : Method to test out below mentioned use case:-
     *                  a) Create an opportunity associated with a program with a program abbreviation then create events associated with that 
     *                      opp and verify the abbreviation is populated on the Events.
    **/   
    static testmethod void testPopulateProgramAbbreviation() { 

        //Bypass Dupeblocker
        Util.IsTest(true);
        
        //Bypassing Triggers so then test data can be created easily
        Util.byPassAllTriggers = true;
        
        //Flag for triggers: this is just a test, don't do crazy things.
        Util.isTesting = true;

        // create a program
        Program__c prog = TestUtilities.CreateNewProgram(false);
        prog.Program_Abbreviation__c = 'Hlth Care Brd';
        insert prog;

        // create a secondary program
        Program__c prog2 = TestUtilities.CreateNewProgram(false);
        prog2.Program_Abbreviation__c = 'Med Care Cncl';
        insert prog2;

        //Create test data
        Opportunity opp = TestUtilities.CreateNewOpportunity(false);
        opp.Program__c = prog.Id;
        insert opp;

        // create a new Event and task associated with the Opportunity
        list<Task> tasks = new list<Task>();
        list<Event> events = new list<Event>();

        //Creating multiple event and task records
        for (integer i = 0; i < 5; i++) {

            // create a taks and event
            tasks.add(TestUtilities.CreateTask(false, opp.Id));
            events.add(TestUtilities.CreateEvent(false, system.now(), opp.Id));
        }
        
        //Enabling triggers
        Util.byPassAllTriggers = false;

        //Insert data in bulk
        insert events;
        insert tasks;

        // get the updated events and tasks
        events = [SELECT Id, Program__c, Program_Abbreviation__c FROM Event WHERE Id in :events];
        tasks = [SELECT Id, Program__c, Program_Abbreviation__c FROM Task WHERE Id in :tasks];

        // verify the events and tasks contain the correct abbreviation and program acronym
        for (Event e : events) {

            //Asserting for the results
            system.assertEquals(prog.Program_Acronym__c, e.Program__c);
            system.assertEquals(prog.Program_Abbreviation__c, e.Program_Abbreviation__c);
        }

        //Loop through task records
        for (Task t : tasks) {
            
            //Asserting for the results
            system.assertEquals(prog.Program_Acronym__c, t.Program__c);
            system.assertEquals(prog.Program_Abbreviation__c, t.Program_Abbreviation__c);
        }
        
        //Start testing from here
        Test.startTest();

        //Setting flag values
        OpportunityTriggerHelper.EXECUTE_TRIGGER_BEFORE_UPDATE = true;
        OpportunityTriggerHelper.EXECUTE_TRIGGER_AFTER_UPDATE = true;
        
        //Enabling triggers
        Util.byPassAllTriggers = false;

        // update the opportunity with the new program
        opp.Program__c = prog2.Id;
        update opp;

        // get the updated events
        events = [SELECT Id, Program__c, Program_Abbreviation__c FROM Event WHERE Id in :events];
        tasks = [SELECT Id, Program__c, Program_Abbreviation__c FROM Task WHERE Id in :tasks];

        // verify the events contain the correct abbreviation
        for (Event e : events) {
            
            //Asserting for the results
            system.assertEquals(prog2.Program_Abbreviation__c, e.Program_Abbreviation__c);
            system.assertEquals(prog2.Program_Acronym__c, e.Program__c);
        }

        //Loop through task records
        for (Task t : tasks) {

            //Asserting for the results
            system.assertEquals(prog2.Program_Acronym__c, t.Program__c);
            system.assertEquals(prog2.Program_Abbreviation__c, t.Program_Abbreviation__c);
        }
        
        //Stop testing from here
        Test.stopTest();
    }

    //Modified by - Abhinav Sharma - CR-20150202-8638 - To refactor the existing code
    /** Description : Method to test out below mentioned use case:-
     *                  a) Create an Opp with events.  Update the Opportunity's Program Abbreviation and verify that the related
     *                          events are updated with the correct abbreviation
    **/
    static testmethod void testPopulateProgramAbbreviation_Batch() { 

        //Bypass Dupeblocker
        Util.IsTest(true);
        
        //Bypassing Triggers so then test data can be created easily
        Util.byPassAllTriggers = true;
        
        //Flag for triggers: this is just a test, don't do crazy things.
        Util.isTesting = true;

        // create a program
        Program__c prog = TestUtilities.CreateNewProgram(false);
        prog.Program_Abbreviation__c = 'Hlth Care Brd';
        insert prog;

        //Create test data
        Opportunity opp = TestUtilities.CreateNewOpportunity(false);
        opp.Program__c = prog.Id;
        insert opp;

        // create a new Event and task associated with the Opportunity
        list<Task> tasks = new list<Task>();
        list<Event> events = new list<Event>();

        for (integer i = 0; i < 5; i++) {

            // create a taks and event
            tasks.add(TestUtilities.CreateTask(false, opp.Id));
            events.add(TestUtilities.CreateEvent(false, system.now(), opp.Id));
        }
        
        //Enabling triggers
        util.BypassAllTriggers = false;

        //Insert data in bulk
        insert events;
        insert tasks;

        // get the updated events and tasks
        events = [SELECT Id, Program__c, Program_Abbreviation__c FROM Event WHERE Id in :events];
        tasks = [SELECT Id, Program__c, Program_Abbreviation__c FROM Task WHERE Id in :tasks];

        // verify the events and tasks contain the correct abbreviation and program acronym
        for (Event e : events) {

            system.assertEquals(prog.Program_Acronym__c, e.Program__c);
            system.assertEquals(prog.Program_Abbreviation__c, e.Program_Abbreviation__c);
        }

        for (Task t : tasks) {

            system.assertEquals(prog.Program_Acronym__c, t.Program__c);
            system.assertEquals(prog.Program_Abbreviation__c, t.Program_Abbreviation__c);
        }

        // update the Program's abbreviation
        string newAbbreviation = 'NewAbbr';
        prog.Program_Abbreviation__c = newAbbreviation;
        update prog;

        //Start testing from here
        Test.startTest();
        
        //Execute batch for tasks and events
        Batch_Event_UpdateProgramAbbreviation batch = new Batch_Event_UpdateProgramAbbreviation();
        batch.isEvent = true;
        Database.executeBatch(batch);
        
        //Stop test here
        Test.stopTest();

        //Asseting for the results
        list<CronTrigger> jobs = [SELECT Id
                                    FROM CronTrigger
                                    WHERE CronJobDetail.Name = 'Sched_Event_UpdateProgramAbbreviation'];
        system.assertEquals(1, jobs.size());

        // verify the new prog acronym / abbreviation are populated on the events
        events = [SELECT Id, Program__c, Program_Abbreviation__c FROM Event WHERE Id in :Events];

        // verify the events contain the correct abbreviation
        for (Event e : events) {
            system.assertEquals(prog.Program_Abbreviation__c, e.Program_Abbreviation__c);
        }
    }

    /************************************************************************************************
    *   HELPER METHODS
    ***********************************************************************************************/

    static Contact createContact() {
        Contact ct = new Contact();
        ct.LastName = 'TestContact';
        ct.Email = 'testContact@email.com';
        return ct;
    } 

    static Campaign createMarketWarmingCampaign(Id programId) {
        Campaign cpn = new Campaign();
        cpn.Name = 'HCAB - null';
        cpn.IsActive = true;
        cpn.type = 'Marketing Warming Effort';
        cpn.Status = 'In Progress';
        cpn.Primary_Program__c = programId;
        return cpn;
    }
    
    //Modified By - Mahendra Swarnkar - 10/07/2016 - CR-20160825-10152 - to check the condion to bypass validation for Royall opportunity recordType.
    //Modified by - Abhinav Sharma - CR-20150202-8638 - To refactor the existing code
    //Method modified by - Abhinav Sharma - CR-20150925-9269 - Removed the 
    //NMI Received (NMI_LOA_Received_attached_in_Salesforce__c), Contacts Added to Adv.com (Contacts_added_to_adv_com__c) 
    //and Welcome Pack Sent (Publication_Library__c) field references from this method
    //Method modified by Ajit Surana - 07/08/2014 - CR-20131212-4143 - Removed reference for field "zzzProposal Value"
    //Method modified By Ajit Surana - 07/4/2014 - CR-20140602-5662
    //Method modified By Ajit Surana - 06/27/2014 - CR-20140527-5608
    //Added By Ajit Surana - 03/15/2014 - CR-20140205-4458
    //Test method to allow users to edit Non-SOX fields on Opportunity when opp stage is
    //"Closed Won, Dropped, Honorary, Sent to Finance - Opp Rejected, Void, ATL, Closed".
    static testMethod void test_updateOpportunityNonSOXFields(){
        
        //Bypass Dupeblocker
        Util.IsTest(true);
        
        //Bypassing Triggers so then test data can be created easily
        Util.byPassAllTriggers = true;
        
        //Flag for triggers: this is just a test, don't do crazy things.
        Util.isTesting = true;
        
        //Temp. variables
        Id specialistId;
        Id analystId;
        
        //Get profile list
        List<Profile> testProfile = [SELECT Id, Name from Profile WHERE Name = 'Specialist' OR Name = 'Analyst' ORDER BY Name];
        
        //Assert for the results
        System.assert(testProfile != null);
        System.assert(testProfile.size() > 0);
        
        //Checking for profile name and setting variables
        if( testProfile[0].Name == 'Specialist'){
            specialistId = testProfile[0].Id;
            analystId = testProfile[1].Id;
        }
        else {
            specialistId = testProfile[1].Id;
            analystId = testProfile[0].Id;
        }
        
        //Test User Create
        User testUser = new User(Username = Math.random()+'@abc.com', LastName = 'Test User1', FirstName = 'Test1', Email = Math.random()+'@test.com',
        Alias = 'Test1', EmailEncodingKey='UTF-8', languagelocalekey = 'en_US', ProfileId = specialistId, 
        timezonesidkey = 'America/Los_Angeles', localesidkey = 'en_US', EmployeeNumber = '12121212', IsActive = true);

        //insert users
        insert testUser;

        //Create another test user                    
        User testUser1 = new User(Username = Math.random()+'@abc.com', LastName = 'Test User2', FirstName = 'Test2', Email = Math.random()+'@test.com',
        Alias = 'Test1', EmailEncodingKey='UTF-8', languagelocalekey = 'en_US', ProfileId = analystId, 
        timezonesidkey = 'America/Los_Angeles', localesidkey = 'en_US', EmployeeNumber = '12121212', IsActive = true);

        //insert users
        insert testUser1;

        //Insert the Custom Setting
        List<Configuration_Manager__c> customSettings = new List<Configuration_Manager__c>();
        customSettings.add(new Configuration_Manager__c(Name = 'Profile_Analyst', Parameter_Key__c = 'Profile edit fields when Opp is closed',
                    Parameter_Value__c = 'analyst'));
                    
        customSettings.add(new Configuration_Manager__c(Name = 'Field_Workshops', Parameter_Key__c = 'Editable field after Opp is closed',
                    Parameter_Value__c = 'Workshops__c'));                                                          

        //Insert record
        insert customSettings;  
        
        //Assert for the results
        System.assert(customSettings != null);
        System.assert(customSettings.size() > 0);    

        //Create Account record
        Account testAccount = new Account(Name = 'Test-Account');

        //Insert record
        insert testAccount;

        //Create Program record
        Program__c program = TestUtilities.CreateNewProgram(false);

        //Insert record
        insert program;    

        //Set to hold Record Types
        Set<String> setRecordTypes = new Set<String> {'Core_AM_First_Year_Opp', 'Core_AM_Standard_Opp', 'BI_Contract_Maintenance', 'BI_Contract_Renewal'};

        //List of Record types
        List<RecordType> recordTypes = [SELECT Id, DeveloperName 
                                            FROM RecordType 
                                            WHERE IsActive = true AND SobjectType = 'Opportunity' 
                                            AND DeveloperName IN: setRecordTypes ORDER BY NAME];
                                            
        //Assert for the results
        System.assert(recordTypes != null);
        System.assert(recordTypes.size() > 0);    
        
        //Modified by - Mahendra Swarnkar - 12/04/2015 - CR-20151022-9350 - Update query to fetch southwind record type details with the help of DeveloperName of it in place of Name. 
        //Starts from here
        //Getting Record Type Id Value for Opportunity
        ID oppRecordTypeId = [SELECT Id, Name FROM RecordType WHERE SobjectType = 'Opportunity' and DeveloperName = 'Southwind'].Id;
        //Ends here
        
        //Assert for the results
        System.assert(oppRecordTypeId != null);
        
        //Create Test Opportunity records
        List<Opportunity> testOpportunity = new List<Opportunity>();
                 
        testOpportunity.add(new Opportunity (Name = 'Test1', RecordTypeId = recordTypes[0].Id, AccountId = testAccount.Id,
                StageName = 'Closed', CloseDate = System.today().addDays(3), Trigger_Update__c = true,
                 Amount = 100, Workshops__c = 10));
        testOpportunity.add(new Opportunity (Name = 'Test2', RecordTypeId = recordTypes[2].Id, AccountId = testAccount.Id,
                StageName = 'Closed', CloseDate = System.today().addDays(4), Trigger_Update__c = true,
                 Amount = 200, Workshops__c = 20));
        testOpportunity.add(new Opportunity (Name = 'Test3', RecordTypeId = oppRecordTypeId, AccountId = testAccount.Id,
                StageName = 'Void', CloseDate = System.today().addDays(5), Trigger_Update__c = true,
                 Amount = 300, Workshops__c = 30));  
        testOpportunity.add(new Opportunity (Name = 'Test4', RecordTypeId = recordTypes[0].Id, AccountId = testAccount.Id,
                StageName = 'Dropped', CloseDate = System.today().addDays(6), Trigger_Update__c = true,
                 Amount = 400, Workshops__c = 40));
        testOpportunity.add(new Opportunity (Name = 'Test5', RecordTypeId = recordTypes[0].Id, AccountId = testAccount.Id,
                StageName = 'Honorary', CloseDate = System.today().addDays(7), Trigger_Update__c = true,
                 Amount = 500, Workshops__c = 50)); 

        //Modified By Ajit Surana - 07/4/2014 - CR-20140602-5662 - Added Visit_Hierarchy__c field
        //Added By Ajit Surana - 06/27/2014 - CR-20140527-5608
        testOpportunity.add(new Opportunity (Name = 'Test6', RecordTypeId = recordTypes[0].Id, AccountId = testAccount.Id,
                                                StageName = 'ATL', CloseDate = System.today().addDays(7), Amount = 500,
                                                Welcome_Call__c = System.today().addDays(2),
                                                Quarterly_Checkin_Calls__c = System.today().addDays(2),
                                               
                                                User_Group_Scheduled__c = System.today().addDays(2), Visit_Hierarchy__c = 'Tier 1'));                                                        
        
        //Added By Mahendra Swarnkar - 07/12/2016 - CR-20150202-8638 - as per the refractor CR.
        testOpportunity.add(new Opportunity (Name = 'Test7', RecordTypeId = recordTypes[1].Id, AccountId = testAccount.Id,
                StageName = 'Prospect', Amount = 500, CloseDate = System.today().addDays(9), Workshops__c = 50, Editable_by_Finance_Ops_Only__c = true)); 
        
        //Added By Mahendra Swarnkar - 10/07/2016 - CR-20160825-10152 - Starts from here
        //create the Royall Opportunity
        testOpportunity.add(new Opportunity (Name = 'Test8', RecordTypeId = OpportunityTriggerHelper.OPPORTUNITY_ROYALL_RT_ID, 
                                              AccountId = testAccount.Id, StageName = 'Pending- Renewal Call Not Yet Occured',
                                              CloseDate = System.today().addDays(7), Trigger_Update__c = False, Amount = 500));
        //Added By Mahendra Swarnkar - 10/07/2016 - CR-20160825-10152 - Ends here
        //Insert Opportunity
        insert testOpportunity;
        
        //Assert for the results
        System.assert(testOpportunity != null);
        System.assert(testOpportunity.size() > 0);  

        //Update Opportunity Owner to Specialist Profile user
        testOpportunity[1].OwnerId = testUser.Id;
        testOpportunity[2].OwnerId = testUser.Id;
        testOpportunity[6].OwnerId = testUser.Id;

        //Update Opportunity Owner to Analyst Profile user
        testOpportunity[0].OwnerId = testUser1.Id; 
        testOpportunity[5].OwnerId = testUser1.Id;  

        //Test starts here
        Test.startTest();

        //Setting flag values
        OpportunityTriggerHelper.EXECUTE_TRIGGER_BEFORE_UPDATE = true;
        OpportunityTriggerHelper.EXECUTE_TRIGGER_AFTER_UPDATE = true; 

        //Enabling triggers
        Util.byPassAllTriggers=false;

        //updating opportunity
        update testOpportunity; 

        //Run as test User of Specialist profile    
        System.runAs(testUser){

            //Query to retreive Opportunity fields
            List<Opportunity> listOppRecord = [SELECT Id, Editable_by_Finance_Ops_Only__c, StageName, Workshops__c, OwnerId 
                                                FROM Opportunity 
                                                WHERE Id=: testOpportunity[1].Id];

            //Assert for the results
            System.assert(listOppRecord != null);
            System.assert(listOppRecord.size() > 0); 
            System.assertEquals(testUser.Id, listOppRecord[0].OwnerId);

            //Update Editable_by_Finance_Ops_Only__c field on Opp record
            listOppRecord[0].Editable_by_Finance_Ops_Only__c = false;

            //Update Opportunity record
            try {

                //Setting flag values
                OpportunityTriggerHelper.EXECUTE_TRIGGER_BEFORE_UPDATE = true;
                OpportunityTriggerHelper.EXECUTE_TRIGGER_AFTER_UPDATE = true;
                
                //Enabling trigger
                Util.byPassAllTriggers=false;
                
                //Updating opportunity
                update listOppRecord;  
            
            } catch(Exception ex){
                System.assert(true);  
            } 

            //List to hold Opportunity records
            List<Opportunity> oppList = [SELECT Id, Editable_by_Finance_Ops_Only__c, StageName, Workshops__c, OwnerId 
                                                FROM Opportunity 
                                                WHERE Id=: testOpportunity[2].Id];

            //Asserting for the results
            System.assert(oppList != null);
            System.assert(oppList.size() > 0); 
            System.assertEquals(1, oppList.size());
            
            //Update Editable_by_Finance_Ops_Only__c field on Opp record
            oppList[0].Editable_by_Finance_Ops_Only__c = true;

            //Update Opportunity record
            try {

                //Setting flag values
                OpportunityTriggerHelper.EXECUTE_TRIGGER_BEFORE_UPDATE = true;
                OpportunityTriggerHelper.EXECUTE_TRIGGER_AFTER_UPDATE = true;
                
                //Enabling trigger
                Util.byPassAllTriggers=false;

                //Updating opportunities
                update oppList;
            
            } catch(Exception exc){
                System.assert(true);  
            }
            
             //List to hold Opportunity records
            List<Opportunity>  oppList1 = [SELECT Id, Editable_by_Finance_Ops_Only__c, StageName, Workshops__c, OwnerId 
                                                FROM Opportunity 
                                                WHERE id =: testOpportunity[6].Id limit 1];

            //Asserting for the results
            System.assert(oppList1 != null);
            System.assert(oppList1.size() > 0); 
            System.assertEquals(1, oppList1.size());
            System.assertEquals('Prospect', oppList1[0].StageName);

            //Update Editable_by_Finance_Ops_Only__c field on Opp record
            oppList1[0].StageName = Constants.STATUS_ATL;
            
            //Update Opportunity record
            try {

                //Setting flag values
                OpportunityTriggerHelper.EXECUTE_TRIGGER_BEFORE_UPDATE = true;
                OpportunityTriggerHelper.EXECUTE_TRIGGER_AFTER_UPDATE = true;
                
                //Enabling triggers
                Util.byPassAllTriggers=false;
                
                //Updating opportunities
                update oppList1[0];
            
            } catch(Exception exc){
                
                System.assert((exc.getMessage().containsIgnoreCase(Label.ERROR_ONLY_FINANCE_OPS_CAN_CLOSE_AN_OPP)),exc.getMessage());  
            }
        }
        
        //Test stops here   
        Test.stopTest();
        
        //Run as test User of Analyst Profile
        System.runAs(testUser1){

            //Query to retreive Opportunity non-SOX fields
            List<Opportunity> listOpp = [SELECT Id, Workshops__c, OwnerId FROM Opportunity 
                                            WHERE Id=: testOpportunity[0].Id];

            //Asserting for the results
            System.assert(listOpp != null);
            System.assert(listOpp.size() > 0); 
            System.assertEquals(testUser1.Id, listOpp[0].OwnerId);

            //Update Opp field
            listOpp[0].Workshops__c = 20;

            //Update Opportunity record
            try{

                //Setting flag values
                OpportunityTriggerHelper.EXECUTE_TRIGGER_BEFORE_UPDATE = true;
                OpportunityTriggerHelper.EXECUTE_TRIGGER_AFTER_UPDATE = true;
                
                //Enabling triggers
                Util.byPassAllTriggers = false;
                
                //updtaing opportunities
                update listOpp;  
    
            }catch(Exception e){
                System.assert(true);  
            } 

            //Query to fetch Opportunity record
            listOpp = [SELECT Id, Workshops__c, OwnerId FROM Opportunity 
                        WHERE Id=: testOpportunity[0].Id];

            //Asserting for the results
            System.assert(listOpp != null);
            System.assert(listOpp.size() > 0);
            System.assertEquals(20, listOpp[0].Workshops__c);

            //Modified By Ajit Surana - 07/4/2014 - CR-20140602-5662 - Added Visit_Hierarchy__c field in the Query
            //Added By Ajit Surana - 06/27/2014 - CR-20140527-5608
            //Query to fetch Opportunity record
            listOpp = [SELECT Id,  Welcome_Call__c,
                                Quarterly_Checkin_Calls__c,
                                User_Group_Scheduled__c, OwnerId, Visit_Hierarchy__c
                                FROM Opportunity WHERE Id=: testOpportunity[5].Id];

            //Update Opp field
            listOpp[0].Welcome_Call__c = System.today().addDays(2);
            listOpp[0].Quarterly_Checkin_Calls__c = System.today().addDays(2);
            listOpp[0].User_Group_Scheduled__c = System.today().addDays(2);
            listOpp[0].Visit_Hierarchy__c = 'Tier 2';

            //Update Opportunity record
            try{

                //Setting flag values
                OpportunityTriggerHelper.EXECUTE_TRIGGER_BEFORE_UPDATE = true;
                OpportunityTriggerHelper.EXECUTE_TRIGGER_AFTER_UPDATE = true;
                
                //Enabling triggers
                Util.byPassAllTriggers = false;
                
                //updating opportunities
                update listOpp;  
            
            }catch(Exception e){
                System.assert(true);  
            } 

            //Modified By Ajit Surana - 07/4/2014 - CR-20140602-5662 - Added Visit_Hierarchy__c field in the Query
            //Query to fetch Opportunity record
            listOpp = [SELECT Id, Welcome_Call__c,
                        Quarterly_Checkin_Calls__c,
                        User_Group_Scheduled__c, OwnerId, Visit_Hierarchy__c
                        FROM Opportunity WHERE Id=: testOpportunity[5].Id];

            //Assert for results
            System.assert(listOpp != null);
            System.assert(listOpp.size() > 0);
            System.assertEquals(System.today().addDays(2), listOpp[0].Welcome_Call__c);
            System.assertEquals(System.today().addDays(2), listOpp[0].Quarterly_Checkin_Calls__c);
            System.assertEquals(System.today().addDays(2), listOpp[0].User_Group_Scheduled__c);
            System.assertEquals('Tier 2', listOpp[0].Visit_Hierarchy__c);
        }

        //List to hold Opportunity records
        List<Opportunity> oppList = [SELECT Id, StageName, OwnerId FROM Opportunity 
                                        WHERE Id=: testOpportunity[5].Id];

        //Update Opportunity Stage to "Closed"
        testOpportunity[5].StageName = Constants.CLOSED ;

        //Update Opportunity record
        try {

            //Setting flag values
            OpportunityTriggerHelper.EXECUTE_TRIGGER_BEFORE_UPDATE = true;
            OpportunityTriggerHelper.EXECUTE_TRIGGER_AFTER_UPDATE = true;
            
            //Updating opportunites
            update oppList;

        }catch(Exception exc){
            System.assert(true);  
        }
        
        
        //Added By Mahendra Swarnkar - 10/07/2016 - CR-20160825-10152 - Starts from here
        //Update Royall Opportunity Stage to "Closed"
        testOpportunity[7].StageName = Constants.CLOSED ;
        
        //Update Opportunity record
        try {

            //Setting flag values
            OpportunityTriggerHelper.EXECUTE_TRIGGER_BEFORE_UPDATE = true;
            OpportunityTriggerHelper.EXECUTE_TRIGGER_AFTER_UPDATE = true;
            
            update testOpportunity[7];
            
            //List to hold Opportunity records
            oppList = [SELECT Id, StageName FROM Opportunity WHERE Id=: testOpportunity[7].Id];
            System.assertEquals(Constants.CLOSED, oppList[0].StageName);

        }catch(Exception exc){
            System.assert(true);  
        }
        //Added By Mahendra Swarnkar - 10/07/2016 - CR-20160825-10152 - Ends here
        
    }

    //Modified by - Abhinav Sharma - CR-20150202-8638 - To refactor the existing code
    /** Description : Method to test out whether the associated contract records fields are updating/populating with expected value or not, on DML over opportunities.
    **/
    static testmethod void testCaseContractFieldUpdates(){
    
        //Bypass Dupeblocker
        Util.IsTest(true);
        
        //Bypassing Triggers so then test data can be created easily
        Util.byPassAllTriggers = true;
        
        //Flag for triggers: this is just a test, don't do crazy things.
        Util.isTesting = true;

        //Added by Ajit Surana - 05/03/2014 - CR-20140418-5151
        //Retreiving "NBB" Record type for Opportunity object
        RecordType nbbRecordType = [SELECT ID, DeveloperName FROM RecordType 
                                        WHERE SobjectType = 'Opportunity' AND IsActive = true AND DeveloperName = 'Core_Marketing' LIMIT 1];

        //Retreiving "Non-NBB" Record type for Opportunity object
        RecordType nonNbbRecordType = [SELECT ID, DeveloperName FROM RecordType 
                                        WHERE SobjectType = 'Opportunity' AND IsActive = true AND DeveloperName = 'Core_AM_Standard_Opp' LIMIT 1]; 
                                        
        //Assert for results
        System.assert(nbbRecordType != null);
        System.assert(nonNbbRecordType != null);

        //Removed 4/22/11 JN
        //Account acc = [select Id from Account limit 1];
        //Contract__c cnt = [select id, Negotiated_By__c from Contract__c where Status__c Not IN ('ATL', 'Honorary') limit 1];
        //User usr = [select id from User where isActive = true limit 1];
        //User usr2 = [select id from User where isActive = true and Id <>: usr.Id limit 1];
        Account acc = new Account(Name = 'testacc', Account_Formal_Name__c = 'testacc');
        insert acc;
        
        //Contacts
        List<Contact> contacts = new List<Contact>();
        Contact contact_1 = new Contact(LastName = 'Test', FirstName = 'Con');
        Contact contact_2 = new Contact(LastName = 'Testtesting', FirstName = 'ConTest');
        Contact contact_3 = new Contact(LastName = 'TesttestingTest', FirstName = 'ConTestTest');
        contacts.add(contact_1); contacts.add(contact_2); contacts.add(contact_3);
        insert contacts;
        
        //Assert for the results
        System.assert(contacts != null);
        System.assert(contacts.size() == 3);
        
        //Profile
        Profile prof = [select Id from Profile where Name = 'System Administrator' limit 1];
        
        //Asserting for the results
        System.assert(prof != null);
        
        //List of users
        list<User> users = new list<User>();
        
        //Populating list with user instances
        for (Integer i = 0; i < 3; i++) {
            String digit = String.valueOf(i);
            users.add(new User(
                alias = 'user' + digit, 
                email='standarduser@advisory.com', 
                emailencodingkey='UTF-8', 
                lastname='Testing ' + digit, 
                languagelocalekey='en_US', 
                localesidkey='en_US', 
                profileid = prof.id, 
                timezonesidkey='America/Los_Angeles', 
                username= math.random() + digit + '@advisory.com'
            ));
        }
        insert users;
        
        //Assert for the results
        System.assert(users != null);
        System.assert(users.size() > 0);
        
        //Users
        User usr = users[0];
        User usr2 = users[1];

        //Contracts
        Contract__c cnt = new Contract__c(Name = 'testcontract',
                                            Status__c = 'Pending',
                                            Payer_Account__c = acc.id);
        insert cnt;
        
        //List of Opportunity
        list<Opportunity> opps = new list<Opportunity>();
        Opportunity opp = new Opportunity();
        opp.AccountId = acc.Id;
        opp.Name = 'Test';
        opp.StageName = 'Pending';
        opp.CloseDate = System.today();
        opp.Signed_Opportunity_Contract__c = cnt.Id;
        opp.RecordTypeId = nbbRecordType.ID;
        opp.Marketer__c = usr.Id;
        opp.Main_Contact__c = contacts[0].Id;

        //Start test from here
        Test.startTest();
        
        //Setting flag values
        OpportunityTriggerHelper.EXECUTE_TRIGGER_BEFORE_UPDATE = true;
        OpportunityTriggerHelper.EXECUTE_TRIGGER_AFTER_UPDATE = true;
        
        //Enabling triggers
        Util.byPassAllTriggers = false;

        //Stop test here
        insert opp;

        //Stop test here
        Test.stopTest();

        //Assert for the results
        Contract__c cnt2 = [select id, Negotiated_By__c from Contract__c where Id =: cnt.Id];
        System.assert(cnt2 != null);
        System.assert(opp != null);
        System.assertEquals(opp.Marketer__c, cnt2.Negotiated_By__c);
        
        //Diabling triggers
        Util.byPassAllTriggers = true;
        
        //List of OpportunityContactRole records (Will Update)
        List<OpportunityContactRole> oCRsList = new List<OpportunityContactRole>();
            
        //Opportunity Contact Role record instance
        OpportunityContactRole oCRoleInsert1 = new OpportunityContactRole();
        
        //Populating OCR instance with field values
        oCRoleInsert1.ContactId = opp.Main_Contact__c;
        oCRoleInsert1.IsPrimary = true;
        oCRoleInsert1.OpportunityId = opp.Id;
        oCRoleInsert1.Role = System.Label.OCR_CONATCT_DEFAULT_ROLE;
        
        //Opportunity Contact Role record instance
        OpportunityContactRole oCRoleInsert2 = new OpportunityContactRole();
        
        //Populating OCR instance with field values
        oCRoleInsert2.ContactId = contacts[1].Id;
        oCRoleInsert2.IsPrimary = false;
        oCRoleInsert2.OpportunityId = opp.Id;
        oCRoleInsert2.Role = 'Other';
        
        //Adding instance into the list to be inserted
        oCRsList.add(oCRoleInsert1);
        oCRsList.add(oCRoleInsert2);
        insert oCRsList;
        
        //Enabling triggers
        Util.byPassAllTriggers = false;
        
        //Setting flag values
        OpportunityTriggerHelper.EXECUTE_TRIGGER_BEFORE_UPDATE = true;
        OpportunityTriggerHelper.EXECUTE_TRIGGER_AFTER_UPDATE = true;
        
        //Update opportunities
        opp.Main_Contact__c = contacts[2].Id;
        update opp;
        
         //Enabling triggers
        Util.byPassAllTriggers = false;
        
        //Setting flag values
        OpportunityTriggerHelper.EXECUTE_TRIGGER_BEFORE_UPDATE = true;
        OpportunityTriggerHelper.EXECUTE_TRIGGER_AFTER_UPDATE = true;
        
        //Update opportunities
        opp.Main_Contact__c = null;
        update opp;
    }

    //Modified by - Abhinav Sharma - CR-20150202-8638 - To refactor the existing code
    /** Description : Method to test out whether the associated warm lead records fields are updating/populating with expected value or not, on DML over opportunities.
    **/
    static testmethod void testCaseWarmLeadFieldUpdates(){ 

        //Bypass Dupeblocker
        Util.IsTest(true);
        
        //Test Update of Warm Lead field Initial_Visit_Date__c
        Util.IsTesting = true;

        //Bypassing triggers
        Util.BypassAllTriggers = true;

        // ensure that the record type custom setting has been updated with the correct values
        Util.resetRecordtypeSettings();
        Map<String, Id> rtmap = Util.recordtypemap('Opportunity');
        
        //NBB record type ID
        String NBBRecordTypeId = rtmap.get('RI Marketing');
        
        //Account
        Account acc = new Account(Name = 'testacc', Account_Formal_Name__c = 'testacc');
        insert acc;

        //Profile
        Profile prof = [select Id from Profile where Name = 'System Administrator' limit 1];
        System.assert(prof != null);
        
        //list of users
        list<User> users = new list<User>();
        
        //Populating list with users instances
        for (Integer i = 0; i < 1; i++) {
            String digit = String.valueOf(i);
            users.add(new User(
            alias = 'user' + digit, 
            email='standarduser@advisory.com', 
            emailencodingkey='UTF-8', 
            lastname='Testing ' + digit, 
            languagelocalekey='en_US', 
            localesidkey='en_US', 
            profileid = prof.id, 
            timezonesidkey='America/Los_Angeles', 
            username=math.random() + digit + '@advisory.com'
            ));
        }
        insert users;
        
        //Assert for the results
        System.assert(users != null);
        System.assert(users.size() > 0);

        //user
        User usr = users[0];

        //opportunity
        Opportunity opp = new Opportunity();
        opp.AccountId = acc.Id;
        opp.Name = 'Test';
        opp.StageName = 'Pending';
        opp.CloseDate = System.today();
        opp.RecordTypeId = NBBRecordTypeId;
        opp.Initial_Visit_Date__c = system.today().addDays(-10);

        //Opportunity
        Opportunity opp2 = new Opportunity();
        opp2.AccountId = acc.Id;
        opp2.Name = 'Test';
        opp2.StageName = 'Pending';
        opp2.CloseDate = System.today();
        opp2.RecordTypeId = NBBRecordTypeId;
        
        //List of oppotunities
        List<Opportunity> oppsToInsert = new List<Opportunity> { opp, opp2 };
        insert oppsToInsert;

        //Warm lead
        Warm_Lead__c wl = new Warm_Lead__c(Name = 'testwl');
        insert wl;

        //Asserting for results
        wl = [select Initial_Visit_Date__c from Warm_Lead__c where id = :wl.id];
        system.assertEquals(null, wl.Initial_Visit_Date__c);
        
        //Warm lead MTM
        Warm_Lead_MtM__c mtm0 = new Warm_Lead_MtM__c();
        mtm0.Opportunity__c = opp.Id;
        mtm0.Warm_Lead__c = wl.Id;
        insert mtm0;

        //Warm lead MTM
        Warm_Lead_MtM__c mtm1 = new Warm_Lead_MtM__c();
        mtm1.Opportunity__c = opp2.Id;
        mtm1.Warm_Lead__c = wl.Id;
        insert mtm1;
        
        //Start test from here
        Test.startTest();
        
        //insert Opportunity
        Util.BypassAllTriggers = false;

        //Event
        Event evt = TestUtilities.CreateNewEvent(false);
        evt.WhatId = opp2.Id;
        evt.StartDateTime = system.today().addDays(-100);
        evt.Event_Type__c = 'In Person Visit';
        evt.Event_Purpose__c = Constants.EVENT_PURPOSE_INITIAL;
        evt.Executive_Type__c = 'CXO';
        insert evt;
        
        //Retrieving updated information from the database
        opp2 = [SELECT Initial_Visit_Date__c FROM Opportunity 
                    WHERE Id = :opp2.Id];
        
        //Verify Initial Visit on the Warm Lead was set properly.
        wl = [select Initial_Visit_Date__c from Warm_Lead__c where Id =: wl.Id];
        system.assertEquals(system.today().addDays(-100), opp2.Initial_Visit_Date__c);
        system.assertEquals(system.today().addDays(-100), wl.Initial_Visit_Date__c); 

        Test.stopTest();
    } 
   
    //Modified by - Abhinav Sharma - CR-20150202-8638 - To refactor the existing code
    /** Description : Method to test out the various use cases associated with the functionality useful for the "Sales Team".
    **/
    static testmethod void testCaseSalesTeamFieldInsert(){ 

        //Bypass Dupeblocker
        Util.IsTest(true);
        
        //Test Update of Warm Lead field Initial_Visit_Date__c
        Util.IsTesting = true;

        //Bypassing triggers
        Util.BypassAllTriggers = true;

        //Account
        Account acc = new Account(Name = 'testacc', Account_Formal_Name__c = 'testacc');
        insert acc;
        
        //Profile
        Profile prof = [select Id from Profile where Name = 'System Administrator' limit 1];
        
        //Asserting for the results
        System.assert(prof != null);
        
        //List of users
        list<User> usrList = new list<User>();
        
        //Populating list with user instances
        for (Integer i = 0; i < 3; i++) {
            String digit = String.valueOf(i);
            usrList.add(new User(
            alias = 'user' + digit, 
            email='standarduser@advisory.com', 
            emailencodingkey='UTF-8', 
            lastname='Testing ' + digit, 
            languagelocalekey='en_US', 
            localesidkey='en_US', 
            profileid = prof.id, 
            timezonesidkey='America/Los_Angeles', 
            username=math.random() + digit + '@advisory.com'
            ));
        }
        insert usrList;
        
        //Assert for the results
        System.assert(usrList != null);
        System.assert(usrList.size() > 0);
        
        //Opportunity
        Opportunity opp = new Opportunity();
        opp.AccountId = acc.Id;
        opp.Name = 'Test';
        opp.StageName = 'Pending';
        opp.CloseDate = System.today();
        opp.Marketer__c = usrList[0].Id;
        opp.Marketing_Associate__c = usrList[1].Id;
        opp.Leadership_Team_Owner__c = usrList[2].Id;
        
        //Start test from here
        Test.startTest();
        
        //Setting flag values
        OpportunityTriggerHelper.EXECUTE_TRIGGER_BEFORE_UPDATE = true;
        OpportunityTriggerHelper.EXECUTE_TRIGGER_AFTER_UPDATE = true;
        
        //Enabling triggers
        Util.byPassAllTriggers = false;
        
        //insert opportunity
        insert opp;

        //Stop test here    
        Test.stopTest();
        
        //List of opportunity team member
        List<OpportunityTeamMember> oppMembersList = [select Id, UserId, OpportunityId, TeamMemberRole 
                                                            from OpportunityTeamMember 
                                                            where OpportunityId != null 
                                                            AND OpportunityId =: opp.Id];
        
        //Loop through opportunity team member records and asserting for the results
        for (OpportunityTeamMember otm : oppMembersList) {
            if ((otm.TeamMemberRole == 'PT - Marketer') || (otm.TeamMemberRole == 'RI - Marketer')) system.assertEquals(usrList[0].Id, otm.UserID);
            if ((otm.TeamMemberRole == 'PT - Marketing Associate') || (otm.TeamMemberRole == 'RI - Marketing Associate')) system.assertEquals(usrList[1].Id,    otm.UserID);
            if ((otm.TeamMemberRole == 'PT - Leadership Team') || (otm.TeamMemberRole == 'RI - Leadership Team')) system.assertEquals(usrList[2].Id, otm.UserID);
        }
    }

    //Modified by - Abhinav Sharma - CR-20150202-8638 - To refactor the existing code
    /** Description : Method to test out the various use cases associated with the functionality useful for the "Sales Team". (Specially for RI Marketing)
    **/
    static testmethod void testCaseSalesTeamFieldUpdateBI(){ 

        //Bypass Dupeblocker
        Util.IsTest(true);
        
        //Test Update of Warm Lead field Initial_Visit_Date__c
        Util.IsTesting = true;

        //Bypassing triggers
        Util.BypassAllTriggers = true;

        //Account
        Account acc = new Account(Name = 'testacc', Account_Formal_Name__c = 'testacc');
        insert acc;

        //Profile
        Profile prof = [select Id from Profile where Name = 'System Administrator' limit 1];
        
        //Asserting for the results
        System.assert(prof != null);
        
        //List of users
        list<User> usrList = new list<User>();
        
        //Populating list with user instances
        for (Integer i = 0; i < 3; i++) {
            String digit = String.valueOf(i);
            usrList.add(new User(
            alias = 'user' + digit, 
            email='standarduser@advisory.com', 
            emailencodingkey='UTF-8', 
            lastname='Testing ' + digit, 
            languagelocalekey='en_US', 
            localesidkey='en_US', 
            profileid = prof.id, 
            timezonesidkey='America/Los_Angeles', 
            username=math.random() + digit + '@advisory.com'
            ));
        }
        insert usrList;
        
        //Assert for the results
        System.assert(usrList != null);
        System.assert(usrList.size() > 0);

        //RI Marketing record type ID
        Id BIrtid = [select id from Recordtype where SObjectType = 'Opportunity' and Name = 'RI Marketing' limit 1].id;
        System.assert(BIrtid != null);

        //Opportunity
        Opportunity opp = new Opportunity();
        opp.AccountId = acc.Id;
        opp.Name = 'Test';
        opp.StageName = 'Pending';
        opp.CloseDate = System.today();
        opp.Marketer__c = usrList[0].Id;
        opp.Marketing_Associate__c = usrList[1].Id;
        opp.RecordtypeID = BIrtid;
        opp.Leadership_Team_Owner__c = usrList[2].Id;
        insert opp;

        //Start test from here
        Test.startTest();

        //Setting flag values
        OpportunityTriggerHelper.EXECUTE_TRIGGER_BEFORE_UPDATE = true;
        OpportunityTriggerHelper.EXECUTE_TRIGGER_AFTER_UPDATE = true;

        //Opportunity
        Opportunity opp2 = new Opportunity(Id=opp.Id);
        opp2.Marketer__c = usrList[1].Id;
        opp2.Leadership_Team_Owner__c = usrList[2].Id;
        opp2.Marketing_Associate__c = usrList[0].Id;

        //Setting flag values
        OpportunityTriggerHelper.EXECUTE_TRIGGER_BEFORE_UPDATE = true;
        OpportunityTriggerHelper.EXECUTE_TRIGGER_AFTER_UPDATE = true;
        
        //Enabling triggers
        Util.byPassAlltriggers = false;
        
        //Update opportunity
        update opp2;
        
        //Stop test here
        Test.stopTest();

        //Opportunity team members
        List<OpportunityTeamMember> oppMembersList = [select Id, UserId, OpportunityId, TeamMemberRole 
                                                            from OpportunityTeamMember 
                                                            where OpportunityId != null AND OpportunityId =: opp.Id];
        
        //Loop through opportunity team member records and applying asserts
        for (OpportunityTeamMember otm : oppMembersList) {
            if ((otm.TeamMemberRole == 'PT - Marketer') || (otm.TeamMemberRole == 'RI - Marketer')) system.assertEquals(usrList[1].Id, otm.UserID);
            if ((otm.TeamMemberRole == 'PT - Marketing Associate') || (otm.TeamMemberRole == 'RI - Marketing Associate')) system.assertEquals(usrList[0].Id, otm.UserID);
            if ((otm.TeamMemberRole == 'PT - Leadership Team') || (otm.TeamMemberRole == 'RI - Leadership Team')) system.assertEquals(usrList[2].Id, otm.UserID);
        }
    }

    //Modified by - Abhinav Sharma - CR-20150202-8638 - To refactor the existing code
    /** Description : Method to test out the various use cases associated with the functionality useful for the "Sales Team". (Specially for RI Marketing)
    **/ 
    static testmethod void testCaseSalesTeamFieldUpdateCore(){ 

        //Bypass Dupeblocker
        Util.IsTest(true);
        
        //Test Update of Warm Lead field Initial_Visit_Date__c
        Util.IsTesting = true;

        //Bypassing triggers
        Util.BypassAllTriggers = true;
        
        //Account
        Account acc = new Account(Name = 'testacc', Account_Formal_Name__c = 'testacc');
        insert acc;

        //Profile
        Profile prof = [select Id from Profile where Name = 'System Administrator' limit 1];
        
        //Asserting for the results
        System.assert(prof != null);
        
        //List of users
        list<User> usrList = new list<User>();
        
        //Populating list with user instances
        for (Integer i = 0; i < 3; i++) {
            String digit = String.valueOf(i);
            usrList.add(new User(
            alias = 'user' + digit, 
            email='standarduser@advisory.com', 
            emailencodingkey='UTF-8', 
            lastname='Testing ' + digit, 
            languagelocalekey='en_US', 
            localesidkey='en_US', 
            profileid = prof.id, 
            timezonesidkey='America/Los_Angeles', 
            username=math.random() + digit + '@advisory.com'
            ));
        }
        insert usrList;
        
        //Assert for the results
        System.assert(usrList != null);
        System.assert(usrList.size() > 0);

        //RI Marketing record type ID
        Id RIrtid = [select id from Recordtype where SObjectType = 'Opportunity' and Name = 'RI Marketing' limit 1].id;
        System.assert(RIrtid != null);

        //Setting flag values
        OpportunityTriggerHelper.EXECUTE_TRIGGER_BEFORE_UPDATE = true;
        OpportunityTriggerHelper.EXECUTE_TRIGGER_AFTER_UPDATE = true;
        
        //Opportunity
        Opportunity opp = new Opportunity();
        opp.AccountId = acc.Id;
        opp.Name = 'Test';
        opp.StageName = 'Pending';
        opp.CloseDate = System.today();
        opp.Marketer__c = usrList[0].Id;
        opp.Marketing_Associate__c = usrList[1].Id;
        opp.RecordtypeID = RIrtid;
        opp.Leadership_Team_Owner__c = usrList[2].Id;
        insert opp;

        //Start test from here
        Test.startTest();

        //Setting flag values
        OpportunityTriggerHelper.EXECUTE_TRIGGER_BEFORE_UPDATE = true;
        OpportunityTriggerHelper.EXECUTE_TRIGGER_AFTER_UPDATE = true;

        opp.Marketer__c = usrList[1].Id;
        opp.Leadership_Team_Owner__c = usrList[1].Id;
        opp.Marketing_Associate__c = usrList[0].Id;

        //Setting flag values
        OpportunityTriggerHelper.EXECUTE_TRIGGER_BEFORE_UPDATE = true;
        OpportunityTriggerHelper.EXECUTE_TRIGGER_AFTER_UPDATE = true;

        //Enabling triggers
        Util.byPassAlltriggers = false;
        
        //Update opportunity
        update opp;

        //Stop test here
        Test.stopTest();

        //Opportunity team members
        List<OpportunityTeamMember> oppMembersList = [SELECT Id, UserId, OpportunityId, TeamMemberRole 
                                                        FROM OpportunityTeamMember 
                                                        WHERE OpportunityId != null 
                                                        AND OpportunityId =: opp.Id];
       
        //Looping opportunity team members       
        for (OpportunityTeamMember otm : oppMembersList) {
            if ((otm.TeamMemberRole == 'PT - Marketer') || (otm.TeamMemberRole == 'RI - Marketer')) system.assertEquals(usrList[1].Id, otm.UserID);
            if ((otm.TeamMemberRole == 'PT - Marketing Associate') || (otm.TeamMemberRole == 'RI - Marketing Associate')) system.assertEquals(usrList[0].Id, otm.UserID);
            if ((otm.TeamMemberRole == 'PT - Leadership Team') || (otm.TeamMemberRole == 'RI - Leadership Team')) system.assertEquals(usrList[1].Id, otm.UserID);
        }
    }

    //Modified by - Abhinav Sharma - CR-20150202-8638 - To refactor the existing code
    /** Description : Method to test when Renewal Opp Owner changes, the applying Membership Owner also changes. 
     *                  Here, we're testing that we get to the place where it calls a future method.
    **/
    static testmethod void testRenewalOppOwnerChange() {

        //Bypass Dupeblocker
        Util.IsTest(true);
        
        //Test Update of Warm Lead field Initial_Visit_Date__c
        Util.IsTesting = true;

        //Bypassing triggers
        Util.BypassAllTriggers = true;
        
        //Account
        Account a = new Account(Name = 'testacc');
        insert a;

        //List of users
        list<User> testusers = [select id, LastName from User where IsActive = true and Profile.Name = 'System Administrator' limit 2];
        
        //Assert for the results
        System.assert(testusers != null);
        System.assert(testusers.size() > 0);

        //program
        Program__c prog = new Program__c(
        Name = 'testprog',
        Program_Acronym__c = 'TEST');
        insert prog;

        //membership
        Membership__c testmem = new Membership__c(
        Account_Name__c = a.id,
        Program__c = prog.id,
        Name = 'testmem');
        insert testmem;
        
        //Opportunity
        Opportunity testopp = new Opportunity(
                                                OwnerID = testusers[0].id,
                                                AccountID = a.id,
                                                Program__c = prog.id,
                                                Name = 'testopp',
                                                CloseDate = system.today(),
                                                StageName = 'Pending');
        insert testopp;

        //COntract
        Contract__c testcon = new Contract__c(
                                                Payer_Account__c = a.id,
                                                Program__c = prog.id,
                                                Name = 'testcon',
                                                Start__c = system.today().addDays(-100),
                                                End__c = system.today().addDays(100),
                                                Status__c='Payer',
                                                Contract_Renewal_Opportunity__c = testopp.id);

        
        //Updating opportunity
        testopp.Previous_Contract__c = testcon.id;
        testopp.OwnerID = testusers[1].id;
        
        //Start test from here
        test.startTest();
        
        //Setting flags
        OpportunityTriggerHelper.EXECUTE_TRIGGER_BEFORE_UPDATE = true;
        OpportunityTriggerHelper.EXECUTE_TRIGGER_AFTER_UPDATE = true;
        
        //Enabling triggers
        Util.byPassAlltriggers = false;
        
        //Update opportunity
        update testopp;     
        
        //Stop test here
        test.StopTest();

        //Retrieving information from the database
        testmem = [select OwnerID from Membership__c 
                        where id = :testmem.id];
                        
        //Asseting for the results
        system.assert(testmem != null);
        system.assert(Util.TestVariable.contains('Util.membershipOwnerCheckfromOpps'), 'Util.membershipOwnerCheckfromOpps not called on Renewal Opp Owner change');

        //Asserting for the results
        testopp = [select Membership__c from Opportunity where id = :testopp.id];
        
        //Asseting for the results
        system.assert(testopp != null);
        system.assertEquals(testmem.id, testopp.Membership__c);
    
    }

    //Modified by - Abhinav Sharma - CR-20150202-8638 - To refactor the existing code
    /** Description : Method to test out CR-20121019-1641 based functionality.
    **/
    //(Bhavi - 11/07/2012) - CR-20121019-1641
    static testmethod void testPopulateContactData1() { 

        //Bypass Dupeblocker
        Util.IsTest(true);
        
        //Test Update of Warm Lead field Initial_Visit_Date__c
        Util.IsTesting = true;

        //Bypassing triggers
        Util.BypassAllTriggers = true;
        
        //Added by Ajit Surana - 05/03/2014 - CR-20140418-5151
        //Retreiving "PT Contract Renewal" Record type for Opportunity object
        RecordType ptCRenewalRecordType = [SELECT ID, DeveloperName FROM RecordType WHERE SobjectType = 'Opportunity' 
                                                AND IsActive = true AND DeveloperName = 'BI_Contract_Renewal' LIMIT 1];
        
        //Asserting for the results                                     
        System.assert(ptCRenewalRecordType != null);
        
        //Account
        Account acc = new Account(Name = 'testacc', Account_Formal_Name__c = 'testacc');
        insert acc;
        
        //Program
        Program__c testProg1 = new Program__c(Name='Test Trigger Program', New_Business_Marketer__c = 'RI Marketer', Program_Acronym__c='ZZZ', Create_memberships__c='No', Business_line__c = 'PT');
        insert testProg1;

        //Contact
        Contact con = new Contact(FirstName = 'First', LastName = 'Last');
        insert con;
        
        //List of opportunities
        list<Opportunity> opps = new list<Opportunity>();
        
        //Opportunity
        Opportunity opp = new Opportunity();
        opp.AccountId = acc.Id;
        opp.Name = 'Test';
        opp.StageName = 'Pending';
        opp.CloseDate = System.today();
        opp.RecordTypeId = ptCRenewalRecordType.ID;
        opp.Main_Contact__c = con.Id;
        opp.Program__c = testProg1.Id;
        insert opp;

        //Insert Oppoeruntiy Contact Role
        OpportunityContactRole newocr = new OpportunityContactRole(OpportunityID = opp.id, ContactID = con.Id, IsPrimary = true);
        insert newocr;

        //Start test from here
        Test.startTest();

        //Setting flag values
        OpportunityTriggerHelper.EXECUTE_TRIGGER_BEFORE_UPDATE = true;
        OpportunityTriggerHelper.EXECUTE_TRIGGER_AFTER_UPDATE = true;
        
        //Enabling triggers
        Util.byPassAlltriggers = false;
        
        //Update Opportunity 
        opp.Main_Contact__c = con.Id;
        opp.Program__c = testProg1.Id;
        update opp;

        //Assert for the contact data
        con = [Select Main_Contact__c from Contact where Id =: con.Id];
        System.assertEquals(testProg1.Program_Acronym__c, con.Main_Contact__c);

        //Stop test here
        Test.stopTest();
    }

    //Modified by - Abhinav Sharma - CR-20150202-8638 - To refactor the existing code
    /** Description : Method to test out CR-20121019-1641 based functionality.
    **/
    static testmethod void testPopulateContactData2() { 

        //Bypass Dupeblocker
        Util.IsTest(true);
        
        //Test Update of Warm Lead field Initial_Visit_Date__c
        Util.IsTesting = true;

        //Bypassing triggers
        Util.BypassAllTriggers = true;

        //Added by Ajit Surana - 05/03/2014 - CR-20140418-5151
        //Retreiving "PT Contract Renewal" Record type for Opportunity object
        RecordType ptCRenewalRecordType = [SELECT ID, DeveloperName FROM RecordType 
                                                WHERE SobjectType = 'Opportunity' AND IsActive = true AND DeveloperName =: 'BI_Contract_Renewal' LIMIT 1];
                                                
         //Asserting for the results                                        
        System.assert(ptCRenewalRecordType != null);
        
        //Account
        Account acc = new Account(Name = 'testacc', Account_Formal_Name__c = 'testacc');
        insert acc;
        
        //Program
        Program__c testProg1 = new Program__c(Name='Test Trigger Program', New_Business_Marketer__c = 'RI Marketer', Program_Acronym__c='ZZZ', Create_memberships__c='No', Business_line__c = 'PT');
        insert testProg1;

        //Contact
        Contact con = new Contact(FirstName = 'First', LastName = 'Last', Main_Contact__c = 'Test');
        insert con;
        
        //List of opportunities
        list<Opportunity> opps = new list<Opportunity>();
        
        //Opportunity
        Opportunity opp = new Opportunity();
        opp.AccountId = acc.Id;
        opp.Name = 'Test';
        opp.StageName = 'Pending';
        opp.CloseDate = System.today();
        opp.RecordTypeId = ptCRenewalRecordType.ID;
        opp.Main_Contact__c = con.Id;
        opp.Program__c = testProg1.Id;
        insert opp;

        //Insert Oppoeruntiy Contact Role
        OpportunityContactRole newocr = new OpportunityContactRole(OpportunityID = opp.id, ContactID = con.Id, IsPrimary = true);
        insert newocr;

        //Start test from here
        Test.startTest();

        //Setting flag values
        OpportunityTriggerHelper.EXECUTE_TRIGGER_BEFORE_UPDATE = true;
        OpportunityTriggerHelper.EXECUTE_TRIGGER_AFTER_UPDATE = true;

        //Enabling triggers
        Util.byPassAlltriggers = false;
        
        //Update Opportunity 
        opp.Main_Contact__c = con.Id;
        opp.Program__c = testProg1.Id;
        
        //Updating opportunity
        update opp;

        //Assert for the contact data
        con = [Select Main_Contact__c from Contact where Id =: con.Id];
        System.assertEquals('Test, ' + testProg1.Program_Acronym__c, con.Main_Contact__c);

        //Stop test here
        Test.stopTest();
    }

    //Modified by - Abhinav Sharma - CR-20150202-8638 - To refactor the existing code
    /** Description : Method to test out CR-20121019-1641 based functionality.
    **/
    static testmethod void testPopulateContactData3() { 

        //Bypass Dupeblocker
        Util.IsTest(true);
        
        //Test Update of Warm Lead field Initial_Visit_Date__c
        Util.IsTesting = true;

        //Bypassing triggers
        Util.BypassAllTriggers = true;

        //Added by Ajit Surana - 05/03/2014 - CR-20140418-5151
        //Retreiving "PT Contract Renewal" Record type for Opportunity object
        RecordType ptCRenewalRecordType = [SELECT ID, DeveloperName FROM RecordType 
                                                WHERE SobjectType = 'Opportunity' AND IsActive = true AND DeveloperName = 'BI_Contract_Renewal' LIMIT 1];
                                                
        //Asserting for the results                                     
        System.assert(ptCRenewalRecordType != null);

        //Account
        Account acc = new Account(Name = 'testacc', Account_Formal_Name__c = 'testacc');
         insert acc;
        
        //program
        Program__c testProg1 = new Program__c(Name='Test Trigger Program', New_Business_Marketer__c = 'RI Marketer', Program_Acronym__c='ZZZ', Create_memberships__c='No', Business_line__c = 'PT');
        insert testProg1;

        //Contact
        Contact con = new Contact(FirstName = 'First', LastName = 'Last', Main_Contact__c = testProg1.Program_Acronym__c);
        insert con;

        //list of opportunities
        list<Opportunity> opps = new list<Opportunity>();
        Opportunity opp = new Opportunity();
        opp.AccountId = acc.Id;
        opp.Name = 'Test';
        opp.StageName = 'Pending';
        opp.CloseDate = System.today();
        opp.RecordTypeId = ptCRenewalRecordType.ID;
        opp.Main_Contact__c = con.Id;
        opp.Program__c = testProg1.Id;
        insert opp;

        //Insert Oppoeruntiy Contact Role
        OpportunityContactRole newocr = new OpportunityContactRole(OpportunityID = opp.id, ContactID = con.Id, IsPrimary = true);
        insert newocr;

        //Start test from here
        Test.startTest();

        //Setting flag values
        OpportunityTriggerHelper.EXECUTE_TRIGGER_BEFORE_UPDATE = true;
        OpportunityTriggerHelper.EXECUTE_TRIGGER_AFTER_UPDATE = true;
        
        //Enabling triggers
        Util.byPassAlltriggers = false;

        //Update Opportunity 
        opp.Main_Contact__c = con.Id;
        opp.Program__c = testProg1.Id;
        
        //Update opportunity
        update opp;

        //Assert for the contact data
        con = [Select Main_Contact__c from Contact where Id =: con.Id];
        System.assertEquals(testProg1.Program_Acronym__c, con.Main_Contact__c);

        //Stop test here
        Test.stopTest();
    }

    //Modified by - Abhinav Sharma - CR-20150202-8638 - To refactor the existing code
    /** Description : Method to test out CR-20121106-1687 based functionality.
    **/
    static testmethod void testValidateAgreementsStatus() {

        //Bypass Dupeblocker
        Util.IsTest(true);
        
        //Test Update of Warm Lead field Initial_Visit_Date__c
        Util.IsTesting = true;

        //bypassing triggers
        Util.BypassAllTriggers = true;

        //Added by Ajit Surana - 05/03/2014 - CR-20140418-5151
        //Retreiving "PT Contract Renewal" Record type for Opportunity object
        RecordType ptCRenewalRecordType = [SELECT ID, DeveloperName FROM RecordType 
                                                WHERE SobjectType = 'Opportunity' AND IsActive = true AND DeveloperName = 'BI_Contract_Renewal' LIMIT 1];
                                                
        //Asserting for the results                                     
        System.assert(ptCRenewalRecordType != null);
        
        //Account
        Account acc = new Account(Name = 'testacc', Account_Formal_Name__c = 'testacc');
        insert acc;
        
        //program
        Program__c testProg1 = new Program__c(Name='Test Trigger Program', New_Business_Marketer__c = 'RI Marketer', Program_Acronym__c='ZZZ', Create_memberships__c='No', Business_line__c = 'PT');
        insert testProg1;
        
        //Enabling triggers
        Util.byPassAlltriggers = false;
        
        //Opportunity
        Opportunity opp = new Opportunity();
        opp.AccountId = acc.Id;
        opp.Name = 'Test';
        opp.StageName = 'Pending';
        opp.CloseDate = System.today();
        opp.RecordTypeId = ptCRenewalRecordType.ID;
        opp.Program__c = testProg1.Id;
        insert opp;
        
        //Disbaling triggers
        Util.byPassAlltriggers = true;

        //Attach the Agreement records
        echosign_dev1__SIGN_Agreement__c agreement = new echosign_dev1__SIGN_Agreement__c(Name='test', echosign_dev1__Account__c=acc.Id, echosign_dev1__Status__c = 'Signed', echosign_dev1__Opportunity__c=opp.Id, Contract_Document_Type__c='Terms of Agreement');
        insert agreement;

        //Start test from here
        Test.startTest();

        //Setting flag values
        OpportunityTriggerHelper.EXECUTE_TRIGGER_BEFORE_UPDATE = true;
        OpportunityTriggerHelper.EXECUTE_TRIGGER_AFTER_UPDATE = true;
        
        //Enabling triggers
        Util.byPassAlltriggers = false;

        //Update the Opportunity stage to Closed lost
        opp.StageName = Constants.STAGE_OPPORTUNITY_CLOSED_LOST;
        opp.Primary_Reason_Lost__c = 'Test';

        //Setting flag values
        OpportunityTriggerHelper.EXECUTE_TRIGGER_BEFORE_UPDATE = true;
        OpportunityTriggerHelper.EXECUTE_TRIGGER_AFTER_UPDATE = true;
        
        //update opportunity
        update opp;

        //Assert for the contact data
        agreement = [Select echosign_dev1__Status__c from echosign_dev1__SIGN_Agreement__c where Id =: agreement.Id limit 1];
        System.assert(agreement != null);
        System.assertEquals(Constants.STATUS_AGREEMENT_CANCELLED_DECLINED, agreement.echosign_dev1__Status__c);

        //Stop test here
        Test.stopTest();
    }

    //Modified by - Abhinav Sharma - CR-20150202-8638 - To refactor the existing code
    /** Description : Method to test that create an opportunity with an event and then update the opp's initial visit date and ensure the events are
     *                  updated with the opp initial visit date.
    **/
    static testmethod void testPopulateInitialVisitOnEvents() {

        //Bypass Dupeblocker
        Util.IsTest(true);
        
        //Test Update of Warm Lead field Initial_Visit_Date__c
        Util.IsTesting = true;

        //Bypassing triggers
        Util.BypassAllTriggers = true;
        
        // set the initial visit date
        date initialVisitDate = system.today().addDays(-7);

        // set the updated initial visit date
        date updatedInitialVisitDate = system.today();

        // create the opportunity
        Opportunity opp = testUtilities.CreateNewOpportunity(true);
        
        //Disable all the triggers 
        Util.BypassAllTriggers = false;
        
        // create an event associated with this opp
        Event evt1 = testUtilities.CreateNewEvent(false);
        evt1.WhatId = opp.Id;
        evt1.StartDateTime = initialVisitDate;
        evt1.Event_Type__c = 'In Person Visit';
        evt1.Event_Purpose__c = Constants.EVENT_PURPOSE_INITIAL;
        evt1.Executive_Type__c = 'CXO';
        insert evt1;

        // create a task associated with this opp
        Task tsk1 = new Task(
                                    Subject = 'test',
                                    ActivityDate = system.today(),
                                    Event_Type__c = 'revisit',
                                    WhatId = opp.Id
        );      

        //insert task
        insert tsk1;

        //Start test from here
        test.startTest();

        // get the opp and verify the initial visit date is present
        opp = [SELECT Id, Initial_Visit_Date__c FROM Opportunity WHERE Id = :opp.Id];
        system.assertEquals(initialVisitDate, opp.Initial_Visit_Date__c);
        
        // verify the event's opp initial visit date field is populated
        evt1 = [SELECT Id, Opp_Initial_Visit_Date__c FROM Event WHERE Id = :evt1.Id];
        system.assertEquals(initialVisitDate, evt1.Opp_Initial_Visit_Date__c);

        // verify the task's opp initial visit date field is populated
        tsk1 = [SELECT Id, Opp_Initial_Visit_Date__c FROM Task WHERE Id = :tsk1.Id];
        system.assertEquals(initialVisitDate, tsk1.Opp_Initial_Visit_Date__c);

        // reset the flag that bypasses the future method
        Util.isPopulateInitVisitOnActivities_Future = false;

        //Setting flags
        OpportunityTriggerHelper.EXECUTE_TRIGGER_BEFORE_UPDATE = true;
        OpportunityTriggerHelper.EXECUTE_TRIGGER_AFTER_UPDATE = true;

        // update the Opportunity's initial visit date
        evt1.StartDateTime = updatedInitialVisitDate;
        update evt1;

        //Stop test here
        test.stopTest();

        // get the opp again and verify the initial visit date was updated
        opp = [SELECT Id, Initial_Visit_Date__c FROM Opportunity WHERE Id = :opp.Id];
        system.assertEquals(updatedInitialVisitDate, opp.Initial_Visit_Date__c);

        // get the task and verify the initial visit date updated
        tsk1 = [SELECT Id, Opp_Initial_Visit_Date__c FROM Task WHERE Id = :tsk1.Id];
        system.assertEquals(updatedInitialVisitDate, tsk1.Opp_Initial_Visit_Date__c);

        // get the event and verify the initial visit date updated
        evt1 = [SELECT Id, Opp_Initial_Visit_Date__c FROM Event WHERE Id = :evt1.Id];
        system.assertEquals(updatedInitialVisitDate, evt1.Opp_Initial_Visit_Date__c);
    }

    //Modified by - Abhinav Sharma - CR-20150202-8638 - To refactor the existing code
    /** Description : Method to test that create an opportunity with an event and then update the opp's initial visit date and ensure the events are
     *                  updated with the opp initial visit date.
    **/
    static testmethod void testPopulateInitialVisitOnEvents_CancelEvent() {

        //Bypass Dupeblocker
        Util.IsTest(true);
        
        //Test Update of Warm Lead field Initial_Visit_Date__c
        Util.IsTesting = true;

        //Bypassing triggers
        Util.BypassAllTriggers = true;

        // set the initial visit date
        date initialVisitDate = system.today().addDays(-7);

        // set the updated initial visit date
        date updatedInitialVisitDate = system.today();
        
        //Setting flag values
        OpportunityTriggerHelper.EXECUTE_TRIGGER_BEFORE_UPDATE = true;
        OpportunityTriggerHelper.EXECUTE_TRIGGER_AFTER_UPDATE = true;

        //Enable all the triggers 
        Util.BypassAllTriggers = false;
        
        // create the opportunity
        Opportunity opp = testUtilities.CreateNewOpportunity(true);
        
        //Setting flag values
        OpportunityTriggerHelper.EXECUTE_TRIGGER_BEFORE_UPDATE = true;
        OpportunityTriggerHelper.EXECUTE_TRIGGER_AFTER_UPDATE = true;

        // create an event associated with this opp
        Event evt1 = testUtilities.CreateNewEvent(false);
        evt1.WhatId = opp.Id;
        evt1.StartDateTime = initialVisitDate;
        evt1.Event_Type__c = 'In Person Visit';
        evt1.Event_Purpose__c = Constants.EVENT_PURPOSE_INITIAL;
        evt1.Executive_Type__c = 'CXO';
        insert evt1;

        // create a task associated with this opp
        Task tsk1 = new Task(
            Subject = 'test',
            ActivityDate = system.today(),
            Event_Type__c = 'revisit',
            WhatId = opp.Id
        );      
        
        //Setting flag values
        OpportunityTriggerHelper.EXECUTE_TRIGGER_BEFORE_UPDATE = true;
        OpportunityTriggerHelper.EXECUTE_TRIGGER_AFTER_UPDATE = true;
        
        //insert tasks
        insert tsk1;

        // get the opp and verify the initial visit date is present
        opp = [SELECT Id, Initial_Visit_Date__c FROM Opportunity WHERE Id = :opp.Id];
        system.assertEquals(initialVisitDate, opp.Initial_Visit_Date__c);

        // verify the event's opp initial visit date field is populated
        evt1 = [SELECT Id, Opp_Initial_Visit_Date__c FROM Event WHERE Id = :evt1.Id];
        system.assertEquals(initialVisitDate, evt1.Opp_Initial_Visit_Date__c);

        // verify the task's opp initial visit date field is populated
        tsk1 = [SELECT Id, Opp_Initial_Visit_Date__c FROM Task WHERE Id = :tsk1.Id];
        system.assertEquals(initialVisitDate, tsk1.Opp_Initial_Visit_Date__c);

        //start test from here
        test.startTest();
        
        //Setting flag values
        OpportunityTriggerHelper.EXECUTE_TRIGGER_BEFORE_UPDATE = true;
        OpportunityTriggerHelper.EXECUTE_TRIGGER_AFTER_UPDATE = true;

        // reset the flag that bypasses the future method
        Util.isPopulateInitVisitOnActivities_Future = false;

        // cancel the initial visit and make sure it is no longer populated on the event/task
        evt1.Cancelled_Did_Not_Occur__c = true;
        update evt1;

        //stop test here
        test.stopTest();

        // get the opp again and verify the initial visit date was updated
        opp = [SELECT Id, Initial_Visit_Date__c FROM Opportunity WHERE Id = :opp.Id];
        system.assertEquals(null, opp.Initial_Visit_Date__c);

        // get the event and verify the initial visit date updated
        evt1 = [SELECT Id, Opp_Initial_Visit_Date__c FROM Event WHERE Id = :evt1.Id];
        system.assertEquals(null, evt1.Opp_Initial_Visit_Date__c);

        // get the task and verify the initial visit date updated
        tsk1 = [SELECT Id, Opp_Initial_Visit_Date__c FROM Task WHERE Id = :tsk1.Id];
        system.assertEquals(null, tsk1.Opp_Initial_Visit_Date__c);
    }

    //Modified by - Abhinav Sharma - CR-20150202-8638 - To refactor the existing code
    /** Description : Method to test that create an opportunity with an event and then update the opp's initial visit date and ensure the events are
     *                  updated with the opp initial visit date.
    **/
    static testMethod void testPopulateStartDateClone() {

        //Bypass Dupeblocker
        Util.IsTest(true);
        
        //Test Update of Warm Lead field Initial_Visit_Date__c
        Util.IsTesting = true;

        //insert Opportunity
        Util.BypassAllTriggers = true;

        // set the initial visit date
        date initialVisitDate = system.today().addDays(-7);

        // set the updated initial visit date
        date updatedInitialVisitDate = system.today();

        // create the opportunity
        Opportunity opp = testUtilities.CreateNewOpportunity(true);
        
        //Enabling triggers
        Util.BypassAllTriggers = false;

        // create an event associated with this opp
        Event evt1 = testUtilities.CreateNewEvent(false);
        evt1.WhatId = opp.Id;
        evt1.StartDateTime = initialVisitDate;
        evt1.Event_Type__c = 'In Person Visit';
        evt1.Event_Purpose__c = Constants.EVENT_PURPOSE_INITIAL;
        evt1.Executive_Type__c = 'CXO';
        insert evt1;

        // create a task associated with this opp
        Task tsk1 = new Task(
            Subject = 'test',
            ActivityDate = system.today(),
            Event_Type__c = 'revisit',
            WhatId = opp.Id
        );      

        insert tsk1;

        //Start test from here
        test.startTest();

        // change the task dates
        tsk1.ActivityDate = system.today().addDays(5);
        update tsk1;

        // change the event dates
        evt1.StartDateTime = system.now().addDays(5);
        update evt1;

        //Stop test here
        test.stopTest();
    }

    //Modified by - Abhinav Sharma - CR-20150202-8638 - To refactor the existing code
    /** Description : Method to test out various valdation type of logics, those will be executed on insert of an opportunity.
    **/
    static testmethod void testCaseValidationinsert(){ 

        //Bypass Dupeblocker
        Util.IsTest(true);
        
        //Bypassing Triggers so then test data can be created easily
        Util.byPassAllTriggers = true;
        
        //Flag for triggers: this is just a test, don't do crazy things.
        Util.isTesting = true;
        
        //Error message string
        String errormessage;
        
        //Record types of opportunity object
        list<Recordtype> rts = [select id, Name from Recordtype where SObjectType = 'Opportunity' AND IsActive = true];
        
        //Assert for the results
        System.assert(rts != null);
        System.assert(rts.size() > 0);
        
        //Temp. variable
        ID rimarketingId;
        Id ptcontractmaintenanceId;

        //Code added - Bhavi Sharma - 10/22/2013 - CR-20130625-3205
        Id riAMFirstYearOppId;
        Id riAMStandardOppId;
        
        //loop through record types
        for (Recordtype rt : rts) {
            if (rt.Name == 'RI Marketing') rimarketingId = rt.id;
            if (rt.Name == 'PT Contract Maintenance') ptcontractmaintenanceId = rt.id;
    
            //Code added - Bhavi Sharma - 10/22/2013 - CR-20130625-3205
            if (rt.Name == 'RI AM First Year Opp') riAMFirstYearOppId = rt.id;
            if (rt.Name == 'RI AM Standard Opp') riAMStandardOppId = rt.id;
        }
        
        //Account
        Account acc = new Account(Name = 'testacc', Account_Formal_Name__c = 'testacc');
        insert acc;

        //Contact
        Contact cnt = new Contact(
        LastName = 'testcontact',
        AccountId = acc.id);
        insert cnt;

        //Insert bad opp(RI Marketing), expect it to break    
        Opportunity badopp = new Opportunity();
        badopp.RecordtypeID = rimarketingId;
        badopp.AccountId = acc.Id;
        badopp.Name = 'Test';
        badopp.StageName = 'Contract Received – Send to Finance';
        badopp.CloseDate = System.today();

        //Insert same bad opp (PT Contract Maintenance), expect it not to break    
        Opportunity notbadopp = new Opportunity();
        notbadopp.RecordtypeId = ptcontractmaintenanceId;
        notbadopp.AccountId = acc.Id;
        notbadopp.Name = 'Test';
        notbadopp.StageName = 'Contract Received – Send to Finance';
        notbadopp.CloseDate = System.today();

        //Code added - Bhavi Sharma - 10/22/2013 - CR-20130625-3205
        //Insert Opportunity of RI AM First Year Opp record type
        Opportunity opp1 = new Opportunity();
        opp1.RecordtypeId = ptcontractmaintenanceId;
        opp1.AccountId = acc.Id;
        opp1.Name = 'Test';
        opp1.StageName = 'Contract Received – Send to Finance';
        opp1.CloseDate = System.today();

        //Insert Opporutnity of RI AM Standard Opp record type    
        Opportunity opp2 = new Opportunity();
        opp2.RecordtypeId = ptcontractmaintenanceId;
        opp2.AccountId = acc.Id;
        opp2.Name = 'Test';
        opp2.StageName = 'Contract Received – Send to Finance';
        opp2.CloseDate = System.today();
        
        //Start test from here
        Test.startTest();
        
        try {
        
            //Setting flag values
            OpportunityTriggerHelper.EXECUTE_TRIGGER_BEFORE_UPDATE = true;
            OpportunityTriggerHelper.EXECUTE_TRIGGER_AFTER_UPDATE = true;
            
            //Enabling triggers
            Util.byPassAlltriggers = false;
        
            insert badopp;
        
        } catch(Exception e) {
            
            errormessage = e.getMessage();
            System.assert(errormessage.contains('The Stage you have selected requires an LOA and a Main Contact'));
        
        }

        //Code added - Bhavi Sharma - 10/22/2013 - CR-20130625-3205
        try {
            
            //Setting flag values
            OpportunityTriggerHelper.EXECUTE_TRIGGER_BEFORE_UPDATE = true;
            OpportunityTriggerHelper.EXECUTE_TRIGGER_AFTER_UPDATE = true;
            
            //Enabling triggers
            Util.byPassAlltriggers = false;
            
            //Insert oppoortunity
            insert opp1;
            
        } catch(Exception e){
            errormessage = e.getMessage();
            System.assert(errormessage.contains('The Stage you have selected requires an LOA, Main Contact and Contract Strategy Outcome'));
        }

        //Stop test here
        Test.stopTest();
        
        try {
            
            //Setting flag values
            OpportunityTriggerHelper.EXECUTE_TRIGGER_BEFORE_UPDATE = true;
            OpportunityTriggerHelper.EXECUTE_TRIGGER_AFTER_UPDATE = true;
            
            //Enabling triggers
            Util.byPassAlltriggers = false;
            
            //Insert opportunity
            insert opp2;
            
        } catch(Exception e){
            errormessage = e.getMessage();
            System.assert(errormessage.contains('The Stage you have selected requires an LOA, Main Contact and Contract Strategy Outcome'));
        }   
    }

    //Modified by - Abhinav Sharma - CR-20150202-8638 - To refactor the existing code
    /** Description : Method to test out various valdation type of logics, those will be executed on update of an opportunity.
    **/
    static testmethod void testCaseValidationupdate(){ 
        
        //Bypass Dupeblocker
        Util.IsTest(true);
        
        //Bypassing Triggers so then test data can be created easily
        Util.byPassAllTriggers = true;
        
        //Flag for triggers: this is just a test, don't do crazy things.
        Util.isTesting = true;
        
        //Error Message string
        String errormessage;
        
        //Account
        Account acc = new Account(Name = 'testacc', Account_Formal_Name__c = 'testacc');
        insert acc;

        //Contact
        Contact cnt = new Contact(
        LastName = 'testcontact',
        AccountId = acc.id);
        insert cnt;

        //make good opp, then update to contract received and pass test
        errormessage = 'no error';
        
        //Insert opportunity
        Opportunity opp = new Opportunity();
        opp.AccountId = acc.Id;
        opp.Name = 'Test';
        opp.StageName = 'Pending';
        opp.CloseDate = System.today();
        insert opp;

        //List of contract document
        list<Contract_Document__c> cntrct = new list<Contract_Document__c>();
        cntrct.add(new Contract_Document__c(
        Name__c = 'testcdoc name',
        Type__c = 'Engagement Agreement'));
        insert cntrct;

        //Contract Document to MTM
        Contract_Docs_to_Opps_MtM__c obj = new Contract_Docs_to_Opps_MtM__c();
        obj.Opportunity__c = opp.Id;
        obj.Contract_Documents__c = cntrct[0].Id;
        insert obj;
        
        //Opportunity
        Opportunity opp2 = new Opportunity(Id = opp.Id);
        opp2.StageName = 'Contract Received – Send to Finance';
        opp2.Main_Contact__c = cnt.Id;
        
        //Start testing from here
        Test.startTest();

        try{

            //Setting flag values
            OpportunityTriggerHelper.EXECUTE_TRIGGER_BEFORE_UPDATE = true;
            OpportunityTriggerHelper.EXECUTE_TRIGGER_AFTER_UPDATE = true;
            
            //Enabling triggers
            Util.byPassAlltriggers = false;

            //update opportunity
            update opp2;        

        } catch(Exception e){
        
            //This should not run
            errormessage = e.getMessage();
        }
        
        //Stop test here
        Test.stopTest();

        //Asserting for the resulst
        System.assert(errormessage.contains('no error'));
    }

    //Modified by - Abhinav Sharma - CR-20150202-8638 - To refactor the existing code
    /** Description : Method to test out functionality of updating account/membership name on the basis of DML over opportunity records.
    **/
    static testmethod void testCaseOppFieldUpdatesInsert(){ 

        //Bypass Dupeblocker
        Util.IsTest(true);
        
        //Bypassing Triggers so then test data can be created easily
        Util.byPassAllTriggers = true;
        
        //Flag for triggers: this is just a test, don't do crazy things.
        Util.isTesting = true;

        //Account
        Account acc = new Account(Name = 'testacc', Account_Formal_Name__c = 'testacc');
        insert acc;

        //program
        Program__c prog = new Program__c(
                                            Name = 'testprog', 
                                            Program_Acronym__c = 'TEST', 
                                            Status__c = 'Active', 
                                            Create_Memberships__c = 'Yes');
        insert prog;

        //get existing Memberships out of the way
        delete acc.Memberships__r;
        
        //Membership
        Membership__c mem = new Membership__c(
                                                Account_Name__c = acc.id,
                                                Program__c = prog.id);
        insert mem;

        //Contact
        Contact cnt = new Contact();
        cnt.AccountId = acc.Id;
        cnt.LastName = 'test';
        insert cnt;

        // ensure that the record type custom setting has been updated with the correct values
        Util.resetRecordtypeSettings();
        
        //Map of record types
        Map<String, Id> rtmap = Util.recordtypemap('Opportunity');
        System.debug('rtmap:'+rtmap);
        String RenewalRecordTypeId = rtmap.get('RI AM First Year Opp');

        //Opportunity
        Opportunity opp = new Opportunity();
        opp.AccountId = acc.Id;
        opp.Program__c = prog.Id;
        opp.Name = 'Test Opp';
        opp.StageName = 'Pending';
        opp.CloseDate = System.today();
        opp.recordTypeId = RenewalRecordTypeId;
        opp.Pool_Year__c = '2011';
        
        //Start Test from here
        Test.startTest();
       
        //Setting flag values
        OpportunityTriggerHelper.EXECUTE_TRIGGER_BEFORE_UPDATE = true;
        OpportunityTriggerHelper.EXECUTE_TRIGGER_AFTER_UPDATE = true;
        
        //Enabling triggers again
        Util.byPassAlltriggers = false;
        
        //insert opportunity
        insert opp;
        
        //Stop Test here
        Test.stopTest();
        
        //Retreiving opportunity details
        opp = [SELECT ID, Name, Membership__c FROM Opportunity WHERE Id =: opp.Id Limit 1];
        System.assert(opp != null);
        
        //Retrieving updated details from the database
        acc = [select Name from Account where id = :acc.id];
        
        //String varible to hold name combined string
        String nameStr = '' + acc.Name.substring(0,Math.min(acc.Name.length(), 55)) + ' - ' + prog.Program_Acronym__c + ' - ' + '2011 Renewal';  

        //calculated Name properly, assigned Membership appropriately.
        System.assertEquals(nameStr, opp.Name);
        System.assertEquals(mem.id, opp.Membership__c);

    }

    //Modified by - Abhinav Sharma - CR-20150202-8638 - To refactor the existing code
    /** Description : Method to test out functionality of updating account/membership name on the basis of DML over opportunity records.
    **/
    static testmethod void testCaseOppFieldUpdatesrenewalupdate(){ 

        //Bypass Dupeblocker
        Util.IsTest(true);
        
        //Bypassing Triggers so then test data can be created easily
        Util.byPassAllTriggers = true;
        
        //Flag for triggers: this is just a test, don't do crazy things.
        Util.isTesting = true;

        // ensure that the record type custom setting has been updated with the correct values
        Util.resetRecordtypeSettings();
        
        //Map of record types
        Map<String, Id> rtmap = Util.recordtypemap('Opportunity');
        String RenewalRecordTypeId = rtmap.get('RI AM First Year Opp');

        //program
        Program__c prog = new Program__c(
        Name = 'testprog', 
        Program_Acronym__c = 'TEST', 
        Status__c = 'Active', 
        Create_Memberships__c = 'Yes');
        insert prog;

        //Account
        Account acc = new Account(Name = 'testacc', Account_Formal_Name__c = 'testacc');
        insert acc;
        
        //Membership
        Membership__c mem = new Membership__c(
        Account_Name__c = acc.id,
        Program__c = prog.id);
        insert mem;
        
        //Contact
        Contact cnt = new Contact();
        cnt.AccountId = acc.Id;
        cnt.LastName = 'test';
        insert cnt;
        
        //Opportunity
        Opportunity opp = new Opportunity();
        opp.AccountId = acc.Id;
        opp.Program__c = prog.Id;
        opp.Name = 'Test Opp';
        opp.StageName = 'Pending';
        opp.CloseDate = System.today();
        opp.recordTypeId = RenewalRecordTypeId;
        opp.Pool_Year__c = '2011';
        
        //Test will start from here
        Test.startTest();
        
        //Setting flag values
        OpportunityTriggerHelper.EXECUTE_TRIGGER_BEFORE_UPDATE = true;
        OpportunityTriggerHelper.EXECUTE_TRIGGER_AFTER_UPDATE = true;
     
        //Enabling triggers again
        Util.byPassAlltriggers = false;
        
        //insert opportunity
        insert opp;
        
        //Retreiving updated informations and applying asserts
        opp = [select Id, Name from Opportunity where Id=: opp.Id];
        acc = [select Name from Account where id = :acc.id];
        String nameStr = '' + acc.Name.substring(0,Math.min(acc.Name.length(), 55)) + ' - ' + prog.Program_Acronym__c + ' - ' + '2011 Renewal';
        System.assert(opp != null);
        system.assertEquals(nameStr, opp.Name);

        //Change in Pool Year should change name
        opp.Pool_Year__c = '2012';

        //Setting flag values
        OpportunityTriggerHelper.EXECUTE_TRIGGER_BEFORE_UPDATE = true;
        OpportunityTriggerHelper.EXECUTE_TRIGGER_AFTER_UPDATE = true;
        Util.byPassAlltriggers = false;
        
        //Updating opportunity
        update opp;
        
        //Stop test here
        Test.stopTest();

        //Retreiving updated informations and applying asserts
        opp = [select Id, Name from Opportunity where Id=: opp.Id];
        nameStr = '' + acc.Name.substring(0,Math.min(acc.Name.length(), 55)) + ' - ' + prog.Program_Acronym__c + ' - ' + '2012 Renewal';
        System.assert(opp != null);
        system.assertEquals(nameStr, opp.Name);
    } 

    //Modified by - Abhinav Sharma - CR-20150202-8638 - To refactor the existing code
    /** Description : Method to test out the logic associated with various fields updates over the opportunity records.
    **/
    static testmethod void testCaseOppFieldUpdatesUpdate(){ 

       //Bypass Dupeblocker
        Util.IsTest(true);
        
        //Bypassing Triggers so then test data can be created easily
        Util.byPassAllTriggers = true;
        
        //Flag for triggers: this is just a test, don't do crazy things.
        Util.isTesting = true;

        //Account
        Account acc = new Account(Name = 'testacc', Account_Formal_Name__c = 'testacc');
        insert acc;
        
        //user
        User u = [select id from User where IsActive = true and Profile.Name = 'System Administrator' limit 1];
        System.assert(u != null);
        
        //Program
        Program__c prog = new Program__c(
                                            Name = 'testprog', 
                                            Program_Acronym__c = 'TEST', 
                                            Status__c = 'Active', 
                                            Create_Memberships__c = 'Yes');
        insert prog;
        
        //Contact
        Contact cnt = new Contact();
        cnt.AccountId = acc.Id;
        cnt.LastName = 'test';
        insert cnt;

        // ensure that the record type custom setting has been updated with the correct values
        Util.resetRecordtypeSettings();

        //Map of record types
        Map<String, Id> rtmap = Util.recordtypemap('Opportunity');
        String NBBRecordTypeId = rtmap.get('RI Marketing');

        //Opportunity
        Opportunity opp = new Opportunity();
        opp.AccountId = acc.Id;
        opp.Name = 'Test Opp';
        opp.StageName = 'Pending';
        opp.CloseDate = System.today();
        opp.recordTypeId = NBBRecordTypeId;
        opp.Pool_Year__c = '2011';
        
        //Test will start from here
        Test.startTest();
        
        //Setting flag values
        OpportunityTriggerHelper.EXECUTE_TRIGGER_BEFORE_UPDATE = true;
        OpportunityTriggerHelper.EXECUTE_TRIGGER_AFTER_UPDATE = true;

        //Enabling triggers again
        Util.byPassAlltriggers = false;
        
        //Insert opportunity
        insert opp;

        //opp = [select Id, Chairman_s_Team_Rep__c, Main_Contact__c, Name, Owner_Name__c, OwnerID from Opportunity where Id=: opp.Id];
        opp = [select Id, Chairman_s_Team_Rep__c, Main_Contact__c, Name, OwnerID 
                    from Opportunity where Id=: opp.Id];
        
        //Disabling triggers
        Util.byPassAlltriggers = true;

        //Opportuity team member
        OpportunityTeamMember member = new OpportunityTeamMember();
        member.TeamMemberRole = 'RI - Chairman\'s Team';
        member.UserId = u.id;
        member.OpportunityId = opp.Id;
        insert member;
        
        //Opportunity Contact Role
        OpportunityContactRole cRole = new OpportunityContactRole();
        cRole.ContactId = cnt.Id;
        cRole.isPrimary = true;
        cRole.OpportunityId = opp.Id;
        insert cRole;
        
        //Opportunity
        Opportunity opp2 = new Opportunity(Id = opp.Id);
        opp2.Program__c = prog.Id;

        //Setting flag values
        OpportunityTriggerHelper.EXECUTE_TRIGGER_BEFORE_UPDATE = true;
        OpportunityTriggerHelper.EXECUTE_TRIGGER_AFTER_UPDATE = true;
        Util.byPassAlltriggers = false;
        
        //Update opportunity
        update opp2;
        
        //Stop test here
        Test.stopTest();

        //Retrieving details from the database and asserting for the results
        Opportunity opp3 = [select Id, Chairman_s_Team_Rep__c, Main_Contact__c, Name, OwnerID from Opportunity where Id=: opp2.Id];
        opp = [select Id, Chairman_s_Team_Rep__c, Main_Contact__c, Name, OwnerID from Opportunity where Id=: opp.Id];
        acc = [select Name from Account where id = :acc.id];

        //name string
        String nameStr = '' + acc.Name.substring(0,Math.min(acc.Name.length(), 55)) + ' - ' + prog.Program_Acronym__c + ' - ' + System.today().year() + ' NBB';  

        //Asseting for results
        System.assert(opp3 != null);
        System.assert(cnt != null);
        System.assert(acc != null);
        System.assertEquals(u.id, opp3.Chairman_s_Team_Rep__c);
        System.assertEquals(nameStr, opp3.Name);
        
        //Update Opp
        opp.Marketer__c = Userinfo.getUserId();
        opp.Marketing_Associate__c = Userinfo.getUserId();
        opp.Leadership_Team_Owner__c = Userinfo.getUserId();
        update opp;
    } 

    //Modified by - Abhinav Sharma - CR-20150202-8638 - To refactor the existing code
    /** Description : Method to test out for membseship reference field value when no program is associated to it.
    **/
    static testmethod void testCaseOppFieldUpdatesNoProgram(){ 

        //Bypass Dupeblocker
        Util.IsTest(true);
        
        //Bypassing Triggers so then test data can be created easily
        Util.byPassAllTriggers = true;
        
        //Flag for triggers: this is just a test, don't do crazy things.
        Util.isTesting = true;
        
        //Account
        Account acc = new Account(Name = 'testacc', Account_Formal_Name__c = 'testacc');
        insert acc;

        //User
        User u = [select id from User where IsActive = true 
                        and Profile.Name = 'System Administrator' limit 1];
        System.assert(u != null);

        //Contact
        Contact cnt = new Contact();
        cnt.AccountId = acc.Id;
        cnt.LastName = 'test';
        insert cnt;

        // ensure that the record type custom setting has been updated with the correct values
        Util.resetRecordtypeSettings();
        
        //Map of record types
        Map<String, Id> rtmap = Util.recordtypemap('Opportunity');
        System.debug('rtmap:'+rtmap);
        String NBBRecordTypeId = rtmap.get('RI Marketing');
        
        //Opportunity
        Opportunity opp = new Opportunity();
        opp.AccountId = acc.Id;
        opp.Name = 'Test Opp';
        opp.StageName = 'Pending';
        opp.CloseDate = System.today();
        opp.recordTypeId = NBBRecordTypeId;
        opp.Pool_Year__c = '2011';
        
        //Start test from here
        Test.startTest();
        
        //Setting flag values
        OpportunityTriggerHelper.EXECUTE_TRIGGER_BEFORE_UPDATE = true;
        OpportunityTriggerHelper.EXECUTE_TRIGGER_AFTER_UPDATE = true;
        Util.byPassAlltriggers = false;
        
        //Insert opportunity
        insert opp;
        
        //Stop test here
        Test.stopTest();
        
        //Retreiving updated details from the database and applying assert for the results
        opp = [select Id, Membership__c from Opportunity where Id=: opp.id];
        system.assertEquals(null, opp.Membership__c);
    } 

    //Modified by - Abhinav Sharma - CR-20150202-8638 - To refactor the existing code
    /** Description : Method to test out Insert activity on Membership fields Opportunity_in_Outreach__c, Opportunity_in_Prospect__c, Most_Recent_Opportunity_Close_Date__c.
    **/
    static testmethod void testCaseMembershipFieldUpdatesfirst(){ 

        //Bypass Dupeblocker
        Util.IsTest(true);
        
        //Bypassing Triggers so then test data can be created easily
        Util.byPassAllTriggers = true;
        
        //Flag for triggers: this is just a test, don't do crazy things.
        Util.isTesting = true;

        // ensure that the record type custom setting has been updated with the correct values
        Util.resetRecordtypeSettings();
        
        //Map of record types
        Map<String, Id> rtmap = Util.recordtypemap('Opportunity');
        String NBBRecordTypeId = rtmap.get('RI Marketing');
        
        //program
        Program__c prog = new Program__c(
                                            Name = 'testprog', 
                                            Program_Acronym__c = 'TEST', 
                                            Status__c = 'Active', 
                                            Create_Memberships__c = 'Yes');
        insert prog;

        //List of accounts
        list<Account> accs = new list<Account>();
        
        //Populating list with account records instances
        for (Integer i = 0; i < 2; i++) {
            accs.add(new Account(
            Name = 'testacc' + String.valueOf(i), 
            Account_Formal_Name__c = 'testacc' + String.valueOf(i)
            ));
        }
        insert accs;
        
        //Assert for the results
        System.assert(accs != null);
        System.assert(accs.size() > 0);
        
        //List of memberships
        list<Membership__c> members = new list<Membership__c>();
        Membership__c member = new Membership__c();
        member.Name = 'Test Membership';
        member.Account_Name__c = accs[0].id;
        member.Program__c = prog.id;
        members.add(member);
        insert members;
        
        //Assert for the results
        System.assert(members != null);
        System.assert(members.size() > 0);
        
        //List of opportunity
        list<Opportunity> opps = new list<Opportunity>();
        Opportunity opp = new Opportunity();
        opp.AccountId = accs[0].Id;
        opp.Name = 'Test Opp';
        opp.StageName = 'Outreach';
        opp.CloseDate = System.today().addDays(-10);
        opp.recordTypeId = NBBRecordTypeId;
        opp.Program__c = members[0].Program__c;
        opps.add(opp);

        opp = new Opportunity();
        opp.AccountId = accs[0].Id;
        opp.Name = 'Test Opp2';
        opp.StageName = 'Outreach';
        opp.CloseDate = System.today().addDays(-10);
        opp.recordTypeId = NBBRecordTypeId;
        opp.Program__c = members[0].Program__c;
        opps.add(opp);

        opp = new Opportunity();
        opp.AccountId = accs[0].Id;
        opp.Name = 'Test Opp2';
        opp.StageName = 'Sent to Finance';
        opp.CloseDate = System.today().addDays(-10);
        opp.recordTypeId = NBBRecordTypeId;
        opp.Program__c = members[0].Program__c;
        opps.add(opp);

        //Start testing from here
        Test.startTest();
        
        //Setting flag values
        OpportunityTriggerHelper.EXECUTE_TRIGGER_BEFORE_UPDATE = true;
        OpportunityTriggerHelper.EXECUTE_TRIGGER_AFTER_UPDATE = true;
        Util.byPassAlltriggers = false;
        
        //Insert opportunity
        insert opps;
        
        //Stop testy here
        Test.stopTest();
        
        //Retrieving updated details for the membership records
        Membership__c member0 = [select Id, Most_Recent_Opportunity_Close_Date__c, 
                                    Most_Recent_Lost_Opportunity_Close_Date__c, Opportunity_in_Prospect__c, Opportunity_in_Outreach__c 
                                    from Membership__c where Id =: members[0].Id];

        //Assert for the results
        System.assert(member0 != null);
        System.assert(opp != null);
        System.assertEquals(opp.CloseDate, member0.Most_Recent_Opportunity_Close_Date__c);
        System.assert(member0.Opportunity_in_Outreach__c == 'Yes', 'Test Failed as Trigger didnt function properly for Membership updates from Opportunity');
        System.assert(member0.Opportunity_in_Prospect__c == 'Yes', 'Test Failed as Trigger didnt function properly for Membership updates from Opportunity');
    }

    //Modified by - Abhinav Sharma - CR-20150202-8638 - To refactor the existing code
    /** Description : Method to test out activity on Membership fields Opportunity_in_Outreach__c, Opportunity_in_Prospect__c, Most_Recent_Opportunity_Close_Date__c.
    **/
    static testmethod void testCaseMembershipFieldUpdatessecond() { 

        //Bypass Dupeblocker
        Util.IsTest(true);
        
        //Bypassing Triggers so then test data can be created easily
        Util.byPassAllTriggers = true;
        
        //Flag for triggers: this is just a test, don't do crazy things.
        Util.isTesting = true;

        //Account
        Account acc = new Account(Name = 'testacc', Account_Formal_Name__c = 'testacc');
        insert acc;

        //program
        Program__c prog = new Program__c(
        Name = 'testprog', 
        Program_Acronym__c = 'TEST', 
        Status__c = 'Active', 
        Create_Memberships__c = 'Yes');
        insert prog;

        // ensure that the record type custom setting has been updated with the correct values
        Util.resetRecordtypeSettings();
        
        //Map of record types
        Map<String, Id> rtmap = Util.recordtypemap('Opportunity');
        String NBBRecordTypeId = rtmap.get('RI Marketing');
        
        //Membership
        Membership__c member = new Membership__c();
        member.Name = 'Test Membership';
        member.Program__c = prog.id;
        member.Account_Name__c = acc.id;
        insert member;
        
        //Setting flag values
        OpportunityTriggerHelper.EXECUTE_TRIGGER_BEFORE_UPDATE = true;
        OpportunityTriggerHelper.EXECUTE_TRIGGER_AFTER_UPDATE = true;
        
        //Enabling triggers
        Util.byPassAllTriggers = false;
        
        //Opportunity
        Opportunity opp1 = new Opportunity();
        opp1.AccountId = acc.Id;
        opp1.Program__c = prog.id;
        opp1.Name = 'Test Opp 2';
        opp1.StageName = 'Closed Lost';
        opp1.CloseDate = System.today();
        opp1.recordTypeId = NBBRecordTypeId;
        opp1.Membership__c = member.Id;
        opp1.Re_Approach_Within_12_Months__c = 'Yes';
        opp1.Re_approach_Date__c = System.today();
        opp1.Closed_Opp_Comments__c ='testing';
        opp1.Primary_Reason_Lost__c = 'test';
        insert opp1;

        //Reterieving update details from the database
        Opportunity opp5 = [select id, StageName, membership__c from Opportunity where Id =: opp1.Id];
        
        //Membership update details
        Membership__c member1= [select Id, Most_Recent_Opportunity_Close_Date__c, 
                                    Most_Recent_Lost_Opportunity_Close_Date__c, Opportunity_in_Prospect__c, Opportunity_in_Outreach__c 
                                    from Membership__c where Id =: member.Id];

        //Assert for the results
        System.assert(opp5 != null);
        System.assert(member1 != null);
        system.assertEquals(member1.id, opp5.Membership__c);
        System.assertEquals(System.today(), member1.Most_Recent_Lost_Opportunity_Close_Date__c);
        Id origmemid = opp1.Membership__c;

        //Populating membership reference field to have null value with it
        opp1.Membership__c = null;
        
        //Start test from here
        Test.startTest();

        //Setting flag values
        OpportunityTriggerHelper.EXECUTE_TRIGGER_BEFORE_UPDATE = true;
        OpportunityTriggerHelper.EXECUTE_TRIGGER_AFTER_UPDATE = true;
        Util.byPassAlltriggers = false;
        
        //Update opportunity
        update opp1;
        
        //Stop test here
        Test.stopTest();
        
        //Asserting for the results
        opp1 = [select Membership__c from Opportunity where id = :opp1.id];
        system.assertEquals(origmemid, opp1.Membership__c);
        
    }

    //Modified by - Abhinav Sharma - CR-20150202-8638 - To refactor the existing code
    /** Description : Method to test out Membership assignment related functionality on update operation over opportunity record.
    **/
    static testmethod void testCaseMembershipFieldUpdatesthird(){ 

        //Bypass Dupeblocker
        Util.IsTest(true);
        
        //Bypassing Triggers so then test data can be created easily
        Util.byPassAllTriggers = true;
        
        //Flag for triggers: this is just a test, don't do crazy things.
        Util.isTesting = true;

        //Acocunt
        Account acc = new Account(Name = 'testacc', Account_Formal_Name__c = 'testacc');
        insert acc;

        //program
        Program__c prog = new Program__c(
        Name = 'testprog', 
        Program_Acronym__c = 'TEST', 
        Status__c = 'Active', 
        Create_Memberships__c = 'Yes');
        insert prog;

        // ensure that the record type custom setting has been updated with the correct values
        Util.resetRecordtypeSettings();

        //Map of record types
        Map<String, Id> rtmap = Util.recordtypemap('Opportunity');
        String NBBRecordTypeId = rtmap.get('RI Marketing');

        //membership
        Membership__c member = new Membership__c();
        member.Account_Name__c = acc.id;
        member.Program__c = prog.id;
        member.Name = 'Test Membership';
        insert member;
        
        //Setting flag values
        OpportunityTriggerHelper.EXECUTE_TRIGGER_BEFORE_UPDATE = true;
        OpportunityTriggerHelper.EXECUTE_TRIGGER_AFTER_UPDATE = true;
        
        //Enabling triggers
        Util.byPassAlltriggers = false;

        //Opportunity
        Opportunity opp1 = new Opportunity();
        opp1.AccountId = acc.Id;
        opp1.Program__c = prog.id;
        opp1.Name = 'Test Opp 2';
        opp1.StageName = 'Closed Lost';
        opp1.CloseDate = System.today();
        opp1.recordTypeId = NBBRecordTypeId;
        opp1.Membership__c = member.Id;
        opp1.Re_Approach_Within_12_Months__c = 'Yes';
        opp1.Re_approach_Date__c = System.today();
        opp1.Closed_Opp_Comments__c ='testing';
        opp1.Primary_Reason_Lost__c = 'test';
        insert opp1;

        //Retrieving updated details from the database
        Opportunity opp5 = [select id, StageName, membership__c from Opportunity where Id =: opp1.Id];
        Membership__c member1= [select Id, Most_Recent_Opportunity_Close_Date__c, 
                                    Most_Recent_Lost_Opportunity_Close_Date__c, Opportunity_in_Prospect__c, Opportunity_in_Outreach__c 
                                    from Membership__c where Id =: member.Id];

         //Assert for the results
        System.assert(opp5 != null);
        System.assert(member1 != null);
        system.assertEquals(member.id, opp5.Membership__c);
        System.assertEquals(System.today(), member1.Most_Recent_Lost_Opportunity_Close_Date__c);
        
        //Setting membership reference to have null value with it
        Id origmemid = opp1.Membership__c;
        opp1.Membership__c = null;
        
        //Start testing from here
        Test.startTest();

        //Setting flag values
        OpportunityTriggerHelper.EXECUTE_TRIGGER_BEFORE_UPDATE = true;
        OpportunityTriggerHelper.EXECUTE_TRIGGER_AFTER_UPDATE = true;
        Util.byPassAlltriggers = false;

        //update opportunity
        update opp1;
        
        //Retrieving opportunity details and applying asserts
        opp1 = [select Membership__c from Opportunity where id = :opp1.id];
        system.assertEquals(origmemid, opp1.Membership__c);

        
        //Update Relationship_Grade_Notes__c field on member1
        Util.byPassAlltriggers = true;
        member1.Relationship_Grade_Notes__c = 'Test_Relationship_Grade_Notes';
        update member1;

        //Update opprotunity
        opp1.Membership__c = member1.Id;
        
        //Setting flag values
        OpportunityTriggerHelper.EXECUTE_TRIGGER_BEFORE_UPDATE = true;
        OpportunityTriggerHelper.EXECUTE_TRIGGER_AFTER_UPDATE = true;
        Util.byPassAlltriggers = false;
        
        //Update opportunity
        update opp1;

        //Assert for the results
        opp1 = [select Relationship_Grade_Notes__c from Opportunity where id = :opp1.id];
        system.assertEquals(member1.Relationship_Grade_Notes__c, opp1.Relationship_Grade_Notes__c);

        //Stop testing here 
        Test.stopTest();
    }

    //Modified by - Abhinav Sharma - CR-20150202-8638 - To refactor the existing code
    /** Description : Method to test out "How the existing code will behave in context of apex dataloader profile user?"
    **/
    static testmethod void testDataLoaderProfile() {

        //Bypass Dupeblocker
        Util.IsTest(true);
        
        //Bypassing Triggers so then test data can be created easily
        Util.byPassAllTriggers = true;
        
        //Flag for triggers: this is just a test, don't do crazy things.
        Util.isTesting = true;

        //Account
        Account acc = new Account(Name = 'testacc', Account_Formal_Name__c = 'testacc');
        insert acc;

        //program
        Program__c prog = new Program__c(
        Name = 'testprog', 
        Program_Acronym__c = 'TEST', 
        Status__c = 'Active', 
        Create_Memberships__c = 'Yes');
        insert prog;

        // ensure that the record type custom setting has been updated with the correct values
        Util.resetRecordtypeSettings();
        
        //Map of record types
        Map<String, Id> rtmap = Util.recordtypemap('Opportunity');
        String NBBRecordTypeId = rtmap.get('RI Marketing');

        //membership
        Membership__c member = new Membership__c();
        member.Account_Name__c = acc.id;
        member.Program__c = prog.id;
        member.Name = 'Test Membership';
        insert member;

        //Opportunity
        Opportunity opp1 = new Opportunity();
        opp1.AccountId = acc.Id;
        opp1.Program__c = prog.id;
        opp1.Name = 'Test Opp 2';
        opp1.StageName = 'Closed Lost';
        opp1.CloseDate = System.today();
        opp1.recordTypeId = NBBRecordTypeId;
        opp1.Membership__c = member.Id;
        opp1.Re_Approach_Within_12_Months__c = 'Yes';
        opp1.Re_approach_Date__c = System.today();
        opp1.Closed_Opp_Comments__c ='testing';
        opp1.Primary_Reason_Lost__c = 'test';
        opp1.Initial_Visit_Date__c = Date.today();

        //Start Test from here
        Util.IsTrigger_Opportunity_ValidationAndFieldUpdates = false;

        //Start Testing from here
        Test.startTest();
        
        //Setting flag values
        OpportunityTriggerHelper.EXECUTE_TRIGGER_BEFORE_UPDATE = true;
        OpportunityTriggerHelper.EXECUTE_TRIGGER_AFTER_UPDATE = true;
        Util.byPassAlltriggers = false;

        //insert opportunities
        insert opp1;

        //Assest for the result
        opp1 = [Select Initial_Visit_Date__c from Opportunity where Id =: opp1.Id];

        //This should be true, as trigger is currently executing in context of Admin profile
        System.assertEquals(null, opp1.Initial_Visit_Date__c);

        //Update user profile to System admin
        //Check users profile
        List<Profile> profiles = [Select Name From Profile where Name =: Constants.PROFILE_ABC_DATA_LOADER limit 1];

        //Check for the size
        if(profiles != null && profiles.size() > 0) {
            
            //User
            User usr = new User(alias = 'user0', email='standarduser@advisory.com', emailencodingkey='UTF-8', lastname='Testing', 
                                        languagelocalekey='en_US', localesidkey='en_US', profileid = profiles[0].Id, timezonesidkey='America/Los_Angeles', 
                                        username='testuser1971@advisory.com');

            //Insert new User
            System.runAs(new User(Id = UserInfo.getUserId())) {

                //User profile to data loader
                insert usr;
            }

            //Run as ABC data loader
            System.runAs(usr) {

                //reset the flag and update the opporutnity records. Falg shoudn't be change
                opp1.Initial_Visit_Date__c = Date.today();
                
                //Setting flag values
                OpportunityTriggerHelper.EXECUTE_TRIGGER_BEFORE_UPDATE = true;
                OpportunityTriggerHelper.EXECUTE_TRIGGER_AFTER_UPDATE = true;
                Util.byPassAlltriggers = false;
                
                //Update opportunity
                update opp1;

                //Assest for the result
                opp1 = [Select Initial_Visit_Date__c from Opportunity where Id =: opp1.Id];

                //This should be true, as trigger is currently executing in context of Admin profile
                System.assertNotEquals(null, opp1.Initial_Visit_Date__c);
            }
        }

        //Stop Test here
        Test.stopTest();
    }

    //Modified by - Abhinav Sharma - CR-20150202-8638 - To refactor the existing code
    /** Description : Method to test out CR-20121226-1993 based functionality.
    **/
    static testmethod void testOpportunityNameWithNBB() {

        //Bypass Dupeblocker
        Util.IsTest(true);
        
        //Bypassing Triggers so then test data can be created easily
        Util.byPassAllTriggers = true;
        
        //Flag for triggers: this is just a test, don't do crazy things.
        Util.isTesting = true;

        //string for error message
        String errormessage;

        //Added by Ajit Surana - 05/03/2014 - CR-20140418-5151
        //ensure that the record type custom setting has been updated with the correct values
        Util.resetRecordtypeSettings();
        
        //Map of record types
        Map<String, Id> rtmap = Util.recordtypemap('Opportunity');
        
        //Modified by - Mahendra Swarnkar - 12/04/2015 - CR-20151022-9350 
        String southwindRecordTypeId = rtmap.get('Consulting & Management');

        //Account
        Account acc = new Account(Name='acctest', Account_Formal_Name__c='acctest');

        //insert account
        insert acc;

        //Program
        Program__c prog = new Program__c(Name='progtest', Status__c = 'Active');

        //insert program
        insert prog;

        //Opportunity record
        Opportunity opportunity = new Opportunity( Name = 'oop1Test', RecordtypeId = southwindRecordTypeId, AccountId = acc.Id,Program__c = prog.Id,
                                                    StageName = 'Prospect', CloseDate = System.today());

        //Start Test here
        Test.startTest();
        
        //Setting flag values
        OpportunityTriggerHelper.EXECUTE_TRIGGER_BEFORE_UPDATE = true;
        OpportunityTriggerHelper.EXECUTE_TRIGGER_AFTER_UPDATE = true;
        Util.byPassAlltriggers = false;

        //insert Opportunity record 
        insert opportunity;

        //Opportunity data
        opportunity = [Select Id, Name From Opportunity Where Id =: opportunity.Id];

        //assert statement
        System.assert(opportunity.Name.endsWith('NBB'));

        //Stop Test here
        Test.stopTest();
    }
    
    //Modified by - Abhinav Sharma - CR-20150202-8638 - To refactor the existing code
    //Added By - Abhinav Sharma - CR-20140429-5272 - 09/15/2014
    /** Description : Method to test out CR-20140429-5272 based functionality.
    **/
    static testMethod void testRollUpSummaryCalculations() {
    
        //Bypass Dupeblocker
        Util.IsTest(true);
        
        //Bypassing Triggers so then test data can be created easily
        Util.byPassAllTriggers = true;
        
        //Flag for triggers: this is just a test, don't do crazy things.
        Util.isTesting = true;

        //Record Types
        List<RecordType> rdTypes = [Select ID, DeveloperName FROM RecordType 
                                                Where sObjectType='Opportunity' AND IsActive = true AND DeveloperName = 'Southwind'];
        
        //Assert for the result
        System.assert(rdTypes != null);
        System.assertEquals(1, rdTypes.size());
        
        //Account
        Account a = new Account(Name = 'testacc');
        insert a;
        
        //List to hold the Bundle records
        List<Bundle__c> bundles = new List<Bundle__c>();
        List<Bundle__c> bundleList = new List<Bundle__c>();
        
        //Bundles
        Bundle__c bundle_1 = new Bundle__c(Name = 'Test Bundle 1', Account__c = a.Id);
        Bundle__c bundle_2 = new Bundle__c(Name = 'Test Bundle 2', Account__c = a.Id);

        //Populating list with bundle record instances and then try to insert them
        bundles.add(bundle_1);
        bundles.add(bundle_2);

        //Insert Bundles
        insert bundles;
        
        //Assert for the result
        System.assert(bundles != null);
        System.assertEquals(2, bundles.size());
        
        //List to hold the opportunity records
        List<Opportunity> childrenOpportunities = new List<Opportunity>();
        
        //Retrieving newly created bundle records
        bundles = [Select ID FROM Bundle__c ORDER BY Name ASC LIMIT 3];

        //Assert for the results
        System.assert(bundles != null);
        System.assertEquals(2, bundles.size());

        //Children Opportunities instances
        Opportunity opp_1 = new Opportunity(StageName = 'Prospect', CloseDate = System.today().addDays(5), Name = 'Test Opp 1', Amount = 2000, Bundle__c = bundles[0].Id, RecordTypeId = rdTypes[0].ID);
        Opportunity opp_2 = new Opportunity(StageName = 'Verbal Yes', CloseDate = System.today().addDays(7), Name = 'Test Opp 2', Amount = 2000, Sell_Type__c = 'Upsell', Bundle__c = bundles[0].Id, RecordTypeId = rdTypes[0].ID);
        Opportunity opp_3 = new Opportunity(StageName = 'Outreach', CloseDate = System.today().addDays(6), Name = 'Test Opp 3', Amount = 2000, Bundle__c = bundles[0].Id, RecordTypeId = rdTypes[0].ID);
        Opportunity opp_4 = new Opportunity(StageName = 'Closed Won', CloseDate = System.today().addDays(4), Name = 'Test Opp 4', Amount = 2000, Bundle__c = bundles[0].Id, RecordTypeId = rdTypes[0].ID);
        Opportunity opp_5 = new Opportunity(StageName = 'Closed Lost', CloseDate = System.today().addDays(8), Name = 'Test Opp 5', Amount = 2000, Bundle__c = bundles[0].Id, RecordTypeId = rdTypes[0].ID, Primary_Reason_Lost__c = 'Bad Timing', Re_approach_Opportunity__c = 'No');
        
        //Children Opportunities instances
        Opportunity opp_6 = new Opportunity(StageName = 'Closed Lost', CloseDate = System.today().addDays(3), Name = 'Test Opp 6', Amount = 2000, Bundle__c = bundles[1].Id, RecordTypeId = rdTypes[0].ID, Primary_Reason_Lost__c = 'Bad Timing', Re_approach_Opportunity__c = 'No');
        Opportunity opp_7 = new Opportunity(StageName = 'Honorary', CloseDate = System.today().addDays(4), Name = 'Test Opp 7', Amount = 2000, Bundle__c = bundles[1].Id, RecordTypeId = rdTypes[0].ID, Primary_Reason_Lost__c = 'Bad Timing',  Re_approach_Opportunity__c = 'Yes', Re_approach_Date__c = System.today());
        Opportunity opp_8 = new Opportunity(StageName = 'Prewire', CloseDate = System.today().addDays(5), Name = 'Test Opp 8', Amount = 2000, Bundle__c = bundles[1].Id, RecordTypeId = rdTypes[0].ID);

        //Populating list with opportunity record instances and then try to insert them
        childrenOpportunities.add(opp_1);  childrenOpportunities.add(opp_2);  childrenOpportunities.add(opp_3);  childrenOpportunities.add(opp_4);  
        childrenOpportunities.add(opp_5);  childrenOpportunities.add(opp_6);  childrenOpportunities.add(opp_7);  childrenOpportunities.add(opp_8);  
        
        //Start test from here
        Test.startTest();
        
        //Setting flag values
        OpportunityTriggerHelper.EXECUTE_TRIGGER_BEFORE_UPDATE = true;
        OpportunityTriggerHelper.EXECUTE_TRIGGER_AFTER_UPDATE = true;
        
        //Enabing triggers again
        Util.ByPassAllTriggers = false;

        //Insert Bundled opportunities
        insert childrenOpportunities;
        
        //Assert for the results
        System.assert(childrenOpportunities != null);
        System.assert(childrenOpportunities.size() > 0);

        //Retrieving out the details of the bundle record
        bundleList = [SELECT ID, Name, Total_Value__c, Total_Count__c, Open_Count__c, Open_Value__c, Earliest_Close__c, Latest_Close__c,
                         Earliest_Stage__c, Latest_Stage__c, Prorated_Open_Value__c, Won_Count__c, Won_Value__c, Lost_Count__c, Lost_Value__c
                          FROM Bundle__c WHERE ID IN: bundles ORDER BY Name ASC];
        
        //Asserting for the results
        System.assert(bundleList != null);
        System.assertEquals(2, bundleList.size());
        System.assertEquals(10000, bundleList[0].Total_Value__c);
        System.assertEquals(5, bundleList[0].Total_Count__c);
        System.assertEquals(3, bundleList[0].Open_Count__c);
        System.assertEquals(1, bundleList[0].Won_Count__c);
        System.assertEquals(1, bundleList[0].Lost_Count__c);
        System.assertEquals(6000, bundleList[0].Open_Value__c);
        System.assertEquals(2000, bundleList[0].Won_Value__c);
        System.assertEquals(2000, bundleList[0].Lost_Value__c);
        System.assertEquals(System.today().addDays(4), bundleList[0].Earliest_Close__c);
        System.assertEquals('Prospect', bundleList[0].Earliest_Stage__c);
        System.assertEquals('Closed Lost', bundleList[0].Latest_Stage__c);
        System.assertEquals(System.today().addDays(8), bundleList[0].Latest_Close__c);
        System.assertEquals(1600.00, bundleList[0].Prorated_Open_Value__c);
        
        System.assertEquals(6000, bundleList[1].Total_Value__c);
        System.assertEquals(3, bundleList[1].Total_Count__c);
        System.assertEquals(1, bundleList[1].Open_Count__c);
        System.assertEquals(1, bundleList[1].Won_Count__c);
        System.assertEquals(1, bundleList[1].Lost_Count__c);
        System.assertEquals(2000, bundleList[1].Open_Value__c);
        System.assertEquals(2000, bundleList[1].Won_Value__c);
        System.assertEquals(2000, bundleList[1].Lost_Value__c);
        System.assertEquals(System.today().addDays(3), bundleList[1].Earliest_Close__c);
        System.assertEquals('Prewire', bundleList[1].Earliest_Stage__c);
        System.assertEquals('Honorary', bundleList[1].Latest_Stage__c);
        System.assertEquals(System.today().addDays(5), bundleList[1].Latest_Close__c);
        System.assertEquals(0.00, bundleList[1].Prorated_Open_Value__c);
        
        //Updating the child opportunity record "Bundle Opportunity" field to other second Opportunity record
        childrenOpportunities[2].Bundle__c = bundles[1].Id;
        
        //Setting flag values
        OpportunityTriggerHelper.EXECUTE_TRIGGER_BEFORE_UPDATE = true;
        OpportunityTriggerHelper.EXECUTE_TRIGGER_AFTER_UPDATE = true;

        //Update the opportunity record
        update childrenOpportunities;

        //Retrieving out the details of the bundle record
        bundleList = [SELECT ID, Name, Total_Value__c, Total_Count__c, Open_Count__c, Open_Value__c, Earliest_Close__c, Latest_Close__c,
                         Earliest_Stage__c, Latest_Stage__c, Prorated_Open_Value__c, Won_Count__c, Won_Value__c, Lost_Count__c, Lost_Value__c
                          FROM Bundle__c WHERE ID IN : bundles ORDER BY Name ASC];
        
        //Asserting for the results
        System.assert(bundleList != null);
        System.assertEquals(2, bundleList.size());
        System.assertEquals(8000, bundleList[0].Total_Value__c);
        System.assertEquals(4, bundleList[0].Total_Count__c);
        System.assertEquals(2, bundleList[0].Open_Count__c);
        System.assertEquals(1, bundleList[0].Won_Count__c);
        System.assertEquals(1, bundleList[0].Lost_Count__c);
        System.assertEquals(4000, bundleList[0].Open_Value__c);
        System.assertEquals(2000, bundleList[0].Won_Value__c);
        System.assertEquals(2000, bundleList[0].Lost_Value__c);
        System.assertEquals(System.today().addDays(4), bundleList[0].Earliest_Close__c);
        System.assertEquals('Prospect', bundleList[0].Earliest_Stage__c);
        System.assertEquals('Closed Lost', bundleList[0].Latest_Stage__c);
        System.assertEquals(System.today().addDays(8), bundleList[0].Latest_Close__c);
        System.assertEquals(1600.00, bundleList[0].Prorated_Open_Value__c);
        
        System.assertEquals(8000, bundleList[1].Total_Value__c);
        System.assertEquals(4, bundleList[1].Total_Count__c);
        System.assertEquals(2, bundleList[1].Open_Count__c);
        System.assertEquals(1, bundleList[1].Won_Count__c);
        System.assertEquals(1, bundleList[1].Lost_Count__c);
        System.assertEquals(4000, bundleList[1].Open_Value__c);
        System.assertEquals(2000, bundleList[1].Won_Value__c);
        System.assertEquals(2000, bundleList[1].Lost_Value__c);
        System.assertEquals(System.today().addDays(3), bundleList[1].Earliest_Close__c);
        System.assertEquals('Outreach', bundleList[1].Earliest_Stage__c);
        System.assertEquals('Honorary', bundleList[1].Latest_Stage__c);
        System.assertEquals(System.today().addDays(6), bundleList[1].Latest_Close__c);
        System.assertEquals(0.00, bundleList[1].Prorated_Open_Value__c);
        
        //Setting flag values
        OpportunityTriggerHelper.EXECUTE_TRIGGER_BEFORE_UPDATE = true;
        OpportunityTriggerHelper.EXECUTE_TRIGGER_AFTER_UPDATE = true;

        //Delete the child opportunities records from second Bundled Opportunity record
        delete childrenOpportunities;
        
        //Retrieving out the details of the bundle record
        bundleList = [SELECT ID, Name, Total_Value__c, Total_Count__c, Open_Count__c, Open_Value__c, Earliest_Close__c, Latest_Close__c,
                         Earliest_Stage__c, Latest_Stage__c, Prorated_Open_Value__c, Won_Count__c, Won_Value__c, Lost_Count__c, Lost_Value__c
                          FROM Bundle__c WHERE ID IN : bundles ORDER BY Name ASC];
        
        //Asserting for the results
        System.assert(bundleList != null);
        System.assertEquals(2, bundleList.size());
        System.assertEquals(0, bundleList[0].Total_Value__c);
        System.assertEquals(0, bundleList[0].Total_Count__c);
        System.assertEquals(0, bundleList[0].Open_Count__c);
        System.assertEquals(0, bundleList[0].Won_Count__c);
        System.assertEquals(0, bundleList[0].Lost_Count__c);
        System.assertEquals(0, bundleList[0].Open_Value__c);
        System.assertEquals(0, bundleList[0].Won_Value__c);
        System.assertEquals(0, bundleList[0].Lost_Value__c);
        System.assertEquals(null, bundleList[0].Earliest_Close__c);
        System.assertEquals(null, bundleList[0].Earliest_Stage__c);
        System.assertEquals(null, bundleList[0].Latest_Stage__c);
        System.assertEquals(null, bundleList[0].Latest_Close__c);
        System.assertEquals(0.00, bundleList[0].Prorated_Open_Value__c);
        
        System.assertEquals(0, bundleList[1].Total_Value__c);
        System.assertEquals(0, bundleList[1].Total_Count__c);
        System.assertEquals(0, bundleList[1].Open_Count__c);
        System.assertEquals(0, bundleList[1].Won_Count__c);
        System.assertEquals(0, bundleList[1].Lost_Count__c);
        System.assertEquals(0, bundleList[1].Open_Value__c);
        System.assertEquals(0, bundleList[1].Won_Value__c);
        System.assertEquals(0, bundleList[1].Lost_Value__c);
        System.assertEquals(null, bundleList[1].Earliest_Close__c);
        System.assertEquals(null, bundleList[1].Earliest_Stage__c);
        System.assertEquals(null, bundleList[1].Latest_Stage__c);
        System.assertEquals(null, bundleList[1].Latest_Close__c);
        System.assertEquals(0.00, bundleList[1].Prorated_Open_Value__c);
        
        //Test will stop here
        Test.stopTest();
    }
    
    //Modified by - Abhinav Sharma - CR-20150202-8638 - To refactor the existing code
    //Added By - Abhinav Sharma - CR-20140429-5272 - 09/15/2014
    /** Description : Method to test out CR-20140429-5272 based functionality.
    **/
    static testMethod void testManageBundledOppSiblings() {

        //Bypass Dupeblocker
        Util.IsTest(true);
        
        //Bypassing Triggers so then test data can be created easily
        Util.byPassAllTriggers = true;
        
        //Flag for triggers: this is just a test, don't do crazy things.
        Util.isTesting = true;

        //Record Types
        List<RecordType> rdTypes = [Select ID, DeveloperName FROM RecordType 
                                                Where sObjectType='Opportunity' AND IsActive = true AND DeveloperName = 'Southwind'];
        
        //Assert for the result
        System.assert(rdTypes != null);
        System.assertEquals(1, rdTypes.size());
        
        //Account
        Account a = new Account(Name = 'testacc');
        insert a;
        
        //List to hold the Bundle records
        List<Bundle__c> bundles = new List<Bundle__c>();
        
        //Bundles
        Bundle__c bundle_1 = new Bundle__c(Name = 'Test Bundle 1', Account__c = a.Id);
        Bundle__c bundle_2 = new Bundle__c(Name = 'Test Bundle 2', Account__c = a.Id);

        //Populating list with bundle record instances and then try to insert them
        bundles.add(bundle_1);
        bundles.add(bundle_2);

        //Insert Bundles
        insert bundles;
        
        //Assert for the result
        System.assert(bundles != null);
        System.assertEquals(2, bundles.size());

        //Retrieving newly created bundle records
        bundles = [Select ID FROM Bundle__c ORDER BY Name ASC LIMIT 3];

        //Assert for the results
        System.assertEquals(2, bundles.size());

        //List to hold the opportunity records
        List<Opportunity> childrenOpportunities = new List<Opportunity>();
        
        //Children Opportunities instances
        Opportunity opp_1 = new Opportunity(StageName = 'Prospect', CloseDate = System.today().addDays(5), Name = 'Test Opp 1', Amount = 2000, Bundle__c = bundles[0].Id, RecordTypeId = rdTypes[0].ID);
        Opportunity opp_2 = new Opportunity(StageName = 'Prospect', CloseDate = System.today().addDays(5), Name = 'Test Opp 2', Amount = 2000, Bundle__c = bundles[0].Id, RecordTypeId = rdTypes[0].ID);
        Opportunity opp_3 = new Opportunity(StageName = 'Outreach', CloseDate = System.today().addDays(5), Name = 'Test Opp 3', Amount = 2000, Bundle__c = bundles[0].Id, RecordTypeId = rdTypes[0].ID);
        Opportunity opp_4 = new Opportunity(StageName = 'Closed Won', CloseDate = System.today().addDays(5), Name = 'Test Opp 4', Amount = 2000, Bundle__c = bundles[0].Id, RecordTypeId = rdTypes[0].ID);
        Opportunity opp_5 = new Opportunity(StageName = 'Closed Lost', CloseDate = System.today().addDays(5), Name = 'Test Opp 5', Amount = 2000, Bundle__c = bundles[0].Id, RecordTypeId = rdTypes[0].ID, Primary_Reason_Lost__c = 'Bad Timing', Re_approach_Opportunity__c = 'No');
        
        //Children Opportunities instances
        Opportunity opp_6 = new Opportunity(StageName = 'Closed Won', CloseDate = System.today().addDays(5), Name = 'Test Opp 6', Amount = 2000, Bundle__c = bundles[1].Id, RecordTypeId = rdTypes[0].ID);
        Opportunity opp_7 = new Opportunity(StageName = 'Closed Lost', CloseDate = System.today().addDays(5), Name = 'Test Opp 7', Amount = 2000, Bundle__c = bundles[1].Id, RecordTypeId = rdTypes[0].ID, Primary_Reason_Lost__c = 'Bad Timing', Re_approach_Opportunity__c = 'No');
        
        //Populating list with opportunity record instances and then try to insert them
        childrenOpportunities.add(opp_1);  childrenOpportunities.add(opp_2);  childrenOpportunities.add(opp_3);  
        childrenOpportunities.add(opp_4);  
        childrenOpportunities.add(opp_5);  childrenOpportunities.add(opp_6);  childrenOpportunities.add(opp_7);
        
        //Setting flag values
        OpportunityTriggerHelper.EXECUTE_TRIGGER_BEFORE_UPDATE = true;
        OpportunityTriggerHelper.EXECUTE_TRIGGER_AFTER_UPDATE = true;

        //Start test from here
        Test.startTest();
        
        //Enabling triggers
        Util.ByPassAllTriggers = false;

        //Insert Bundled opportunities
        insert childrenOpportunities;
        
        //Assert for the results
        System.assert(childrenOpportunities != null);
        System.assert(childrenOpportunities.size() > 0);
        
        //List of Bundled Siblings
        List<Bundled_Siblings__c> listBundledSiblings = new List<Bundled_Siblings__c>();
        
        //Retrieving out the details of the opportunity records
        listBundledSiblings = [Select ID, From__c, To__c, Bundle__c FROM Bundled_Siblings__c 
                                    WHERE From__c =: childrenOpportunities[0].Id ORDER BY Name ASC];
        
        //Asserting for the results
        System.assertEquals(4, listBundledSiblings.size());
        System.assertEquals(childrenOpportunities[1].ID, listBundledSiblings[0].To__c);
        System.assertEquals(childrenOpportunities[2].ID, listBundledSiblings[1].To__c);
        System.assertEquals(childrenOpportunities[3].ID, listBundledSiblings[2].To__c);
        System.assertEquals(childrenOpportunities[4].ID, listBundledSiblings[3].To__c);
       
        //Retrieving out the details of the newly created opportunity records
        listBundledSiblings = [Select ID, From__c, To__c, Bundle__c FROM Bundled_Siblings__c 
                                WHERE From__c =: childrenOpportunities[5].Id ORDER BY Name ASC];
        
        //Asserting for the results
        System.assert(listBundledSiblings != null);
        System.assertEquals(1, listBundledSiblings.size());
        System.assertEquals(childrenOpportunities[6].ID, listBundledSiblings[0].To__c);
        
        //Updating the child opportunity record "Bundle Opportunity" field to other second Opportunity record
        childrenOpportunities[2].Bundle__c = bundles[1].Id;
        
        //Setting flag values
        OpportunityTriggerHelper.EXECUTE_TRIGGER_BEFORE_UPDATE = true;
        OpportunityTriggerHelper.EXECUTE_TRIGGER_AFTER_UPDATE = true;

        //Update the opportunity records
        update childrenOpportunities;
        
        //Retrieving out the details of the opportunity records
        listBundledSiblings = [Select ID, From__c, To__c, Bundle__c FROM Bundled_Siblings__c 
                                    WHERE From__c =: childrenOpportunities[0].Id ORDER BY Name ASC];
        
        //Asserting for the results
        System.assert(listBundledSiblings != null);
        System.assertEquals(3, listBundledSiblings.size());
        
        //Retrieving out the details of the opportunity records
        listBundledSiblings = [Select ID, From__c, To__c, Bundle__c FROM Bundled_Siblings__c 
                                    WHERE From__c =: childrenOpportunities[5].Id ORDER BY Name ASC];
                                    
        //Asserting for the results
        System.assert(listBundledSiblings != null);
        System.assertEquals(2, listBundledSiblings.size());
        
        //Setting flag values
        OpportunityTriggerHelper.EXECUTE_TRIGGER_BEFORE_UPDATE = true;
        OpportunityTriggerHelper.EXECUTE_TRIGGER_AFTER_UPDATE = true;

        //Delete the child opportunities records from second Bundled Opportunity record
        delete childrenOpportunities;
        
        //Retrieving out the details of the opportunity records
        listBundledSiblings = [Select ID, From__c, To__c, Bundle__c FROM Bundled_Siblings__c LIMIT 2];
        
        //Asserting for the results
        System.assert(listBundledSiblings != null);
        System.assertEquals(0, listBundledSiblings.size());
        
        //Test will stop here
        Test.stopTest();
    }
    
    //Modified by - Abhinav Sharma - CR-20150202-8638 - To refactor the existing code
    //Added By - Abhinav Sharma - CR-20140429-5272 - 09/17/2014
    /** Description : Method to test out CR-20140429-5272 based functionality.
    **/
    static testMethod void testPopulateAccountOnBundleOpportunity() {
    
        //Bypass Dupeblocker
        Util.IsTest(true);
        
        //Bypassing Triggers so then test data can be created easily
        Util.byPassAllTriggers = true;
        
        //Flag for triggers: this is just a test, don't do crazy things.
        Util.isTesting = true;

        //Record Types
        List<RecordType> rdTypes = [Select ID, DeveloperName FROM RecordType 
                                                Where sObjectType='Opportunity' AND IsActive = true AND DeveloperName = 'Southwind'];
        
        //Assert for the result
        System.assert(rdTypes != null);
        System.assertEquals(1, rdTypes.size());
        
        //List to hold the Bundle records
        List<Bundle__c> bundles = new List<Bundle__c>();
        List<Bundle__c> bundleList = new List<Bundle__c>();
        
        //List to hold the Account records
        List <Account> accList = new List<Account>();
        
        //Account
        Account acc1 = new Account(Name = 'testacc 1');
        Account acc2 = new Account(Name = 'testacc 2');
        Account acc3 = new Account(Name = 'testacc 3');
        
        //Populating list with account record instances and then try to insert them
        accList.add(acc1);
        accList.add(acc2);
        accList.add(acc3);
        
        //Insert Acount
        insert accList;
        
        //Assert for the result
        System.assert(accList != null);
        System.assertEquals(3, accList.size());
        
        //Bundles
        Bundle__c bundle_1 = new Bundle__c(Name = 'Test Bundle 1', Account__c = null);
        Bundle__c bundle_2 = new Bundle__c(Name = 'Test Bundle 2', Account__c = null);
        Bundle__c bundle_3 = new Bundle__c(Name = 'Test Bundle 3', Account__c = null);

        //Populating list with bundle record instances and then try to insert them
        bundles.add(bundle_1);
        bundles.add(bundle_2);
        bundles.add(bundle_3);

        //Insert Bundles
        insert bundles;
        
        //Assert for the result
        System.assert(bundles != null);
        System.assertEquals(3, bundles.size());
        
        //List to hold the opportunity records
        List<Opportunity> childrenOpportunities = new List<Opportunity>();
        
        //Retrieving newly created bundle records
        bundles = [Select ID FROM Bundle__c ORDER BY Name ASC LIMIT 4];

        //Assert for the results
        System.assert(bundles != null);
        System.assertEquals(3, bundles.size());

        //Children Opportunities instances
        Opportunity opp_1 = new Opportunity(StageName = 'Prospect', CloseDate = System.today().addDays(5), Name = 'Test Opp 1', Amount = 2000, Bundle__c = bundles[0].Id, RecordTypeId = rdTypes[0].ID, AccountId = accList[0].Id);
        Opportunity opp_2 = new Opportunity(StageName = 'Prospect', CloseDate = System.today().addDays(7), Name = 'Test Opp 2', Amount = 2000, Bundle__c = bundles[1].Id, RecordTypeId = rdTypes[0].ID, AccountId = accList[1].Id);
        Opportunity opp_3 = new Opportunity(StageName = 'Outreach', CloseDate = System.today().addDays(6), Name = 'Test Opp 3', Amount = 2000, Bundle__c = bundles[2].Id, RecordTypeId = rdTypes[0].ID, AccountId = accList[2].Id);
        Opportunity opp_4 = new Opportunity(StageName = 'Closed Won', CloseDate = System.today().addDays(4), Name = 'Test Opp 4', Amount = 2000, Bundle__c = bundles[0].Id, RecordTypeId = rdTypes[0].ID);
        Opportunity opp_5 = new Opportunity(StageName = 'Closed Lost', CloseDate = System.today().addDays(8), Name = 'Test Opp 5', Amount = 2000, Bundle__c = bundles[0].Id, RecordTypeId = rdTypes[0].ID, Primary_Reason_Lost__c = 'Bad Timing', Re_approach_Opportunity__c = 'No');
        
        //Populating list with opportunity record instances and then try to insert them
        childrenOpportunities.add(opp_1);  childrenOpportunities.add(opp_2); 
        childrenOpportunities.add(opp_3);  childrenOpportunities.add(opp_4);  
        childrenOpportunities.add(opp_5);  
        
        //Start test from here
        Test.startTest();
        
        //Enabing triggers again
        Util.ByPassAllTriggers = false;

        //Setting flag values
        OpportunityTriggerHelper.EXECUTE_TRIGGER_BEFORE_UPDATE = true;
        OpportunityTriggerHelper.EXECUTE_TRIGGER_AFTER_UPDATE = true;

        //Insert Bundled opportunities
        insert childrenOpportunities;
        
        //Assert for the results
        System.assert(childrenOpportunities != null);
        System.assert(childrenOpportunities.size() > 0);

        //Retrieving out the details of the bundle record
        bundleList = [SELECT ID, Account__c FROM Bundle__c WHERE ID IN: bundles ORDER BY Name ASC];
        
        //Asserting for the results
        System.assert(bundleList != null);
        System.assertEquals(3, bundleList.size());
        System.assert(bundleList[0].Account__c != null);
        System.assert(bundleList[1].Account__c != null);
        System.assert(bundleList[2].Account__c != null);
    
        //Stoptest from here
        Test.stopTest();
    }
    
    //Modified by - Abhinav Sharma - CR-20150202-8638 - To refactor the existing code
    //Added By - Abhinav Sharma - CR-20140429-5272 - 09/23/2014
    /** Description : Method to test out CR-20140429-5272 based functionality.
    **/
    static testMethod void testPopulateBundleNameOnOpportunities() {
    
        //Bypass Dupeblocker
        Util.IsTest(true);
        
        //Bypassing Triggers so then test data can be created easily
        Util.byPassAllTriggers = true;
        
        //Flag for triggers: this is just a test, don't do crazy things.
        Util.isTesting = true;

        //Record Types
        List<RecordType> rdTypes = [Select ID, DeveloperName FROM RecordType 
                                                Where sObjectType='Opportunity' AND IsActive = true AND DeveloperName = 'Southwind'];
        
        //Assert for the result
        System.assert(rdTypes != null);
        System.assertEquals(1, rdTypes.size());
        
        //Account
        Account a = new Account(Name = 'testacc');
        insert a;
        
        //List to hold the Bundle records
        List<Bundle__c> bundles = new List<Bundle__c>();
        
        //Bundles
        Bundle__c bundle_1 = new Bundle__c(Name = 'Test Bundle 1', Account__c = a.Id);
        Bundle__c bundle_2 = new Bundle__c(Name = 'Test Bundle 2', Account__c = a.Id);

        //Populating list with bundle record instances and then try to insert them
        bundles.add(bundle_1);
        bundles.add(bundle_2);

        //Insert Bundles
        insert bundles;
        
        //Assert for the result
        System.assert(bundles != null);
        System.assertEquals(2, bundles.size());
        
        //List to hold the opportunity records
        List<Opportunity> childrenOpportunities = new List<Opportunity>();
        
        //Retrieving newly created bundle records
        bundles = [Select ID FROM Bundle__c ORDER BY Name ASC LIMIT 3];

        //Assert for the results
        System.assert(bundles != null);
        System.assertEquals(2, bundles.size());

        //Children Opportunities instances
        Opportunity opp_1 = new Opportunity(StageName = 'Prospect', CloseDate = System.today().addDays(5), Name = 'Test Opp 1', Amount = 2000, Bundle__c = bundles[0].Id, RecordTypeId = rdTypes[0].ID);
        Opportunity opp_2 = new Opportunity(StageName = 'Prospect', CloseDate = System.today().addDays(7), Name = 'Test Opp 2', Amount = 2000, Bundle__c = bundles[0].Id, RecordTypeId = rdTypes[0].ID);
        Opportunity opp_3 = new Opportunity(StageName = 'Outreach', CloseDate = System.today().addDays(6), Name = 'Test Opp 3', Amount = 2000, Bundle__c = null, RecordTypeId = rdTypes[0].ID);
        
        //Populating list with opportunity record instances and then try to insert them
        childrenOpportunities.add(opp_1);  
        childrenOpportunities.add(opp_2);  
        childrenOpportunities.add(opp_3);
        
        //Start test from here
        Test.startTest();
        
        //Enabing triggers again
        Util.ByPassAllTriggers = false;

        //Setting flag values
        OpportunityTriggerHelper.EXECUTE_TRIGGER_BEFORE_UPDATE = true;
        OpportunityTriggerHelper.EXECUTE_TRIGGER_AFTER_UPDATE = true;

        //Insert Bundled opportunities
        insert childrenOpportunities;

        //Retrieving out the details of the bundle record
        childrenOpportunities = [SELECT ID, BundleName__c FROM Opportunity WHERE ID IN: childrenOpportunities ORDER BY Name ASC];
        
        //Asserting for the results
        System.assert(childrenOpportunities != null);
        System.assert(childrenOpportunities[0].BundleName__c != null);
    }

    //Modified by - Abhinav Sharma - CR-20150202-8638 - To refactor the existing code
    //Modified By - Abhinav Sharma - 12/02/2015 - CR-20151022-9349
    //Added By - Abhinav Sharma - CR-20150820-9167 - 08/25/2015
    /** Description : Method to test out CR-20150820-9167 based functionality.
    **/
    static testMethod void test_PopulateOpportunityFields() {
    
        //Bypass Dupeblocker
        Util.IsTest(true);
        
        //Bypassing Triggers so then test data can be created easily
        Util.byPassAllTriggers = true;
        
        //Flag for triggers: this is just a test, don't do crazy things.
        Util.isTesting = true;
        
        //Record Types
        List<RecordType> rdTypes = [Select ID, DeveloperName FROM RecordType 
                                                Where sObjectType='Opportunity' 
                                                AND IsActive = true AND DeveloperName = 'Core_Marketing'];
        
        //Assert for the result
        System.assert(rdTypes != null);
        System.assertEquals(1, rdTypes.size());
        
        // This code runs as the system user
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator'];
        
        //User (GMT Time Zone)
        User u = new User(Alias = 'standt', Email='standarduser@testorg.com', 
                            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                            LocaleSidKey='en_US', ProfileId = p.Id, TimeZoneSidKey = 'GMT',
                            UserName=Math.random() + '@test.com', C_M_Channel__c = 'NASA');
        //User (GMT Time Zone)
        User testUser = new User(Alias = 'testUser', Email='TestUser@testorg.com', 
                            EmailEncodingKey='UTF-8', LastName='TestingA', LanguageLocaleKey='en_US', 
                            LocaleSidKey='en_US', ProfileId = p.Id, TimeZoneSidKey = 'GMT',
                            UserName=Math.random() + '@test.com', C_M_Channel__c = 'NASA');

        //Running code in context of a "GMT" time znoe user
        System.runAs(u) {
        
            //Account
            Account a = new Account(Name = 'testacc');
            insert a;
            
            // Create invoice billing data
            Invoice_Billing_Schedule__c ibs = new Invoice_Billing_Schedule__c(Institution__c = a.Id);
            insert ibs;
            
            //create Contract ABC test data
            List<Contract__c> contracts = new List<Contract__c>();
        
            //Contracts
            Contract__c contractABC_1 = new Contract__c(Payer_Account__c = a.Id, Invoice_Billing_Schedule__c = ibs.Id, 
                                                      Type__c = 'NBB');
            Contract__c contractABC_2 = new Contract__c(Payer_Account__c = a.Id, Invoice_Billing_Schedule__c = ibs.Id, 
                                                      Type__c = 'Renewal');
            contracts.add(contractABC_1);
            contracts.add(contractABC_2);
            insert contracts;
            
            //Assert for the results
            System.assert(contracts != null);
            System.assertEquals(2, contracts.size());
            
            //List to hold the opportunity records
            List<Opportunity> opportunities = new List<Opportunity>();
            
            //Children Opportunities instances
            Opportunity opp_1 = new Opportunity(StageName = 'Prospect', CloseDate = System.today().addDays(8), 
                                                Name = 'Test Opp 1', Amount = 2000, Marketer__c = UserInfo.getUserId(), 
                                                RecordTypeId = rdTypes[0].ID, Signed_Opportunity_Contract__c = contracts[0].Id,
                                                Parent_Opportunity__c = null, Originator__c = Userinfo.getUserId());
            Opportunity opp_2 = new Opportunity(StageName = 'Prospect', CloseDate = System.today().addDays(7), Marketer__c = null,
                                                Name = 'Test Opp 2', Amount = 2000, Signed_Opportunity_Contract__c = null,
                                                RecordTypeId = rdTypes[0].ID, Parent_Opportunity__c = null,
                                                Originator__c = null);
            Opportunity opp_3 = new Opportunity(StageName = 'Outreach', CloseDate = System.today().addDays(6), Marketer__c = UserInfo.getUserId(),
                                                Name = 'Test Opp 3', Amount = 2000, Parent_Opportunity__c = null,
                                                RecordTypeId = rdTypes[0].ID, Signed_Opportunity_Contract__c = contracts[1].Id,
                                                Originator__c = Userinfo.getUserId());
            
            //Populating list with opportunity record instances and then try to insert them
            opportunities.add(opp_1);  
            opportunities.add(opp_2);  
            opportunities.add(opp_3);
            
            //Start test from here
            Test.startTest();
            
            //Setting flag values
            OpportunityTriggerHelper.EXECUTE_TRIGGER_BEFORE_UPDATE = true;
            OpportunityTriggerHelper.EXECUTE_TRIGGER_AFTER_UPDATE = true;
    
            //Enabing triggers again
            Util.ByPassAllTriggers = false;
    
            //Insert Bundled opportunities
            insert opportunities;
    
            //Retrieving out the details of the bundle record
            opportunities = [SELECT ID, Name, Marketer_Name__c, Renewal_Contract_Type__c, Renewed_from_Chairman_s_Team__c, 
                                       Ownership_Channel__c, Origination_Channel__c FROM Opportunity 
                                       ORDER BY CloseDate DESC];    
            
            //Asserting for the results
            System.assert(opportunities != null);
            System.assertEquals(3, opportunities.size());
            System.assertEquals(UserInfo.getFirstName() + ' ' + UserInfo.getLastName(), opportunities[0].Marketer_Name__c);
            System.assertEquals('NBB', opportunities[0].Renewal_Contract_Type__c);
            System.assertEquals(null, opportunities[0].Renewed_from_Chairman_s_Team__c);
            System.assertEquals('NASA', opportunities[0].Ownership_Channel__c);
            System.assertEquals('NASA', opportunities[0].Origination_Channel__c);
            System.assertEquals(null, opportunities[1].Marketer_Name__c);
            System.assertEquals(null, opportunities[1].Renewal_Contract_Type__c);
            System.assertEquals(null, opportunities[1].Renewed_from_Chairman_s_Team__c);
            System.assertEquals('NASA', opportunities[1].Ownership_Channel__c);
            System.assertEquals(null, opportunities[1].Origination_Channel__c);
            System.assertEquals(UserInfo.getFirstName() + ' ' + UserInfo.getLastName(), opportunities[2].Marketer_Name__c);
            System.assertEquals('Renewal', opportunities[2].Renewal_Contract_Type__c);
            System.assertEquals(null, opportunities[2].Renewed_from_Chairman_s_Team__c);
            System.assertEquals('NASA', opportunities[2].Ownership_Channel__c);
            System.assertEquals('NASA', opportunities[2].Origination_Channel__c);
            
            //Enabing triggers again
            Util.ByPassAllTriggers = false;
            
            //Setting flag values
            OpportunityTriggerHelper.EXECUTE_TRIGGER_BEFORE_UPDATE = true;
            OpportunityTriggerHelper.EXECUTE_TRIGGER_AFTER_UPDATE = true;
        
            //Opportunity Team Member
            OpportunityTeamMember newOTM = new OpportunityTeamMember();
            newOTM.OpportunityId = opportunities[2].Id;
            newOTM.TeamMemberRole = 'RI - Chairman\'s Team';
            newOTM.UserId = Userinfo.getUserId();
            insert newOTM;
            
            opportunities = [SELECT ID, Marketer_Name__c, Renewal_Contract_Type__c, Renewed_from_Chairman_s_Team__c, 
                             Chairman_s_Team_Rep__c, Ownership_Channel__c, Origination_Channel__c
                             FROM Opportunity 
                             ORDER BY CloseDate DESC];
        
            //Asserting for the results
            System.assert(opportunities != null);
            System.assertEquals(3, opportunities.size());
            System.assertEquals(UserInfo.getFirstName() + ' ' + UserInfo.getLastName(), opportunities[0].Marketer_Name__c);
            System.assertEquals('NBB', opportunities[0].Renewal_Contract_Type__c);
            System.assertEquals(null, opportunities[0].Renewed_from_Chairman_s_Team__c);
            System.assertEquals('NASA', opportunities[0].Ownership_Channel__c);
            System.assertEquals('NASA', opportunities[0].Origination_Channel__c);
            System.assertEquals(null, opportunities[1].Marketer_Name__c);
            System.assertEquals(null, opportunities[1].Renewal_Contract_Type__c);
            System.assertEquals(null, opportunities[1].Renewed_from_Chairman_s_Team__c);
            System.assertEquals('NASA', opportunities[1].Ownership_Channel__c);
            System.assertEquals(null, opportunities[1].Origination_Channel__c);
            System.assertEquals(UserInfo.getFirstName() + ' ' + UserInfo.getLastName(), opportunities[2].Marketer_Name__c);
            System.assertEquals('Renewal', opportunities[2].Renewal_Contract_Type__c);
            System.assertEquals(null, opportunities[2].Renewed_from_Chairman_s_Team__c);
            System.assertEquals('NASA', opportunities[2].Ownership_Channel__c);
            System.assertEquals('NASA', opportunities[2].Origination_Channel__c);
            
            //Test stop here
            Test.stopTest();
            
            //Setting flag values
            OpportunityTriggerHelper.EXECUTE_TRIGGER_BEFORE_UPDATE = true;
            OpportunityTriggerHelper.EXECUTE_TRIGGER_AFTER_UPDATE = true;
            Util.ByPassAllTriggers = false;
           
            //Update opportunities
            opportunities[0].Signed_Opportunity_Contract__c = null;
            opportunities[1].Signed_Opportunity_Contract__c = contracts[0].Id;
            opportunities[1].Parent_Opportunity__c = opportunities[2].Id;
            opportunities[2].Parent_Opportunity__c = opportunities[1].Id;
            opportunities[0].Marketer__c = null;
            opportunities[0].Originator__c = null;
            opportunities[1].Originator__c = Userinfo.getUserId();
            update opportunities;
            
            opportunities = [SELECT ID, Marketer_Name__c, Renewal_Contract_Type__c, Renewed_from_Chairman_s_Team__c, 
                             Chairman_s_Team_Rep__c, Ownership_Channel__c, Origination_Channel__c
                             FROM Opportunity 
                             ORDER BY CloseDate DESC];
            
            //Asserting for the results
            System.assert(opportunities != null);
            System.assertEquals(3, opportunities.size());
            System.assertEquals(null, opportunities[0].Marketer_Name__c);
            System.assertEquals(null, opportunities[0].Renewal_Contract_Type__c);
            System.assertEquals(null, opportunities[0].Renewed_from_Chairman_s_Team__c);
            System.assertEquals('NASA', opportunities[0].Ownership_Channel__c);
            System.assertEquals(null, opportunities[0].Origination_Channel__c);
            System.assertEquals(null, opportunities[1].Marketer_Name__c);
            System.assertEquals('NBB', opportunities[1].Renewal_Contract_Type__c);
            System.assertEquals('NASA', opportunities[1].Ownership_Channel__c);
            System.assertEquals('NASA', opportunities[1].Origination_Channel__c);
            System.assertEquals(UserInfo.getFirstName() + ' ' + UserInfo.getLastName(), opportunities[2].Marketer_Name__c);
            System.assertEquals('Renewal', opportunities[2].Renewal_Contract_Type__c);
            System.assertEquals('No', opportunities[2].Renewed_from_Chairman_s_Team__c);
            System.assertEquals('NASA', opportunities[2].Ownership_Channel__c);
            System.assertEquals('NASA', opportunities[2].Origination_Channel__c);
        }
    }
    
    //Modified by - Abhinav Sharma - CR-20150202-8638 - To refactor the existing code
    //Added By - Abhinav Sharma - CR-20150820-9167 - 08/25/2015
    /** Description : Method to test out CR-20150820-9167 based functionality.
    **/
    static testMethod void test_ValidationRulesBuildLogic() {
    
        //Bypass Dupeblocker
        Util.IsTest(true);
        
        //Bypassing Triggers so then test data can be created easily
        Util.byPassAllTriggers = true;
        
        //Flag for triggers: this is just a test, don't do crazy things.
        Util.isTesting = true;

        //Record Types
        List<RecordType> rdTypes = [Select ID, DeveloperName FROM RecordType 
                                                Where sObjectType='Opportunity' 
                                          AND IsActive = true AND DeveloperName = 'Core_AM_Standard_Opp'];
        
        //Assert for the result
        System.assert(rdTypes != null);
        System.assertEquals(1, rdTypes.size());
        
        //Profile    
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User'];
        System.assert(p != null);
      
        //User
        User u = new User(Alias = 'standt', Email='standarduser@testorg.com', 
                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                          LocaleSidKey='en_US', ProfileId = p.Id, department = 'STP',
                          TimeZoneSidKey='America/Los_Angeles', UserName=Math.random() + '@test.com');

        System.runAs(u) {
            
            //Account
            Account a = new Account(Name = 'testacc');
            insert a;
                    
            //List to hold the opportunity records
            List<Opportunity> opportunities = new List<Opportunity>();
            
            //Children Opportunities instances
            Opportunity opp_1 = new Opportunity(StageName = 'Prospect', CloseDate = System.today().addDays(8), 
                                                Name = 'Test Opp 1', Amount = 2000, Marketer__c = UserInfo.getUserId(), 
                                                RecordTypeId = rdTypes[0].ID,
                                                Parent_Opportunity__c = null);
            Opportunity opp_2 = new Opportunity(StageName = 'Prospect', CloseDate = System.today().addDays(7), Marketer__c = null,
                                                Name = 'Test Opp 2', Amount = 2000, Signed_Opportunity_Contract__c = null,
                                                RecordTypeId = rdTypes[0].ID, Parent_Opportunity__c = null);
            Opportunity opp_3 = new Opportunity(StageName = 'Outreach', CloseDate = System.today().addDays(6), Marketer__c = UserInfo.getUserId(),
                                                Name = 'Test Opp 3', Amount = 2000, Parent_Opportunity__c = null,
                                                RecordTypeId = rdTypes[0].ID);
            
            //Populating list with opportunity record instances and then try to insert them
            opportunities.add(opp_1);  
            opportunities.add(opp_2);  
            opportunities.add(opp_3);
        
            //Start test from here
            Test.startTest();
        
            //Setting flag values
            OpportunityTriggerHelper.EXECUTE_TRIGGER_BEFORE_UPDATE = true;
            OpportunityTriggerHelper.EXECUTE_TRIGGER_AFTER_UPDATE = true;
            
            //Enabing triggers again
            Util.ByPassAllTriggers = false;
                
            try {
              
                //Insert Bundled opportunities
                insert opportunities;
            
            } catch(Exception ex) {
                System.assert(ex.getDmlMessage(0).indexOf(System.Label.Error_Create_Account_Management_Opportunity) > -1);
            }
            
            //Stop test here'
            Test.stopTest();
        }
        
        //Diabling triggers
        Util.ByPassAllTriggers = true;
    
        //Rate card set
        pse__Rate_Card_Set__c rd = new pse__Rate_Card_Set__c();
        rd.Name = 'test';
        insert rd;
          
        //Opportunity
        Opportunity opp = new Opportunity(StageName = 'Prospect', CloseDate = System.today().addDays(8), 
                                            Name = 'Test Opp 1', Amount = 2000, pse__Rate_Card_Set__c = rd.Id,
                                            RecordTypeId = rdTypes[0].ID, CurrencyIsoCode = '');
        try {
            
            //Setting flag values
            OpportunityTriggerHelper.EXECUTE_TRIGGER_BEFORE_UPDATE = true;
            OpportunityTriggerHelper.EXECUTE_TRIGGER_AFTER_UPDATE = true;
            Util.ByPassAllTriggers = false;
            
            //insert opportunity
            insert opp;
            
        } catch(Exception ex) {
          System.assert(ex.getDmlMessage(0).indexOf(System.Label.Error_Opp_Rate_Card_Set_Currency_Mismatch) > -1);    
        }
    }
   
    //Modified by - Abhinav Sharma - CR-20150202-8638 - To refactor the existing code
    //Added By - Abhinav Sharma - 09/03/2015 - CR-20140613-5790
    /** Description : Method to test out CR-20140613-5790 based functionality.
    **/
    static testMethod void testpopulatePAsAndActivityFieldsOnWarmLead() {
        
        //Bypass Dupeblocker
        Util.IsTest(true);
        
        //Bypassing Triggers so then test data can be created easily
        Util.byPassAllTriggers = true;
        
        //Flag for triggers: this is just a test, don't do crazy things.
        Util.isTesting = true;
        
        //Find user with Profile = System Administrator
        Profile sysAdminProfile = [Select id from Profile where Name = 'System Administrator' limit 1];
        System.assert(sysAdminProfile != null);
        
        //Create user
        User usr = new User(Alias = 'standt', Email='standarduser@testorg.com', EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                            LocaleSidKey='en_US', ProfileId = sysAdminProfile.Id, TimeZoneSidKey='America/Los_Angeles',UserName=Math.random()+'@testorg.com');
        
        //insert user
        insert usr;
        
        //Running test in context of system admin user
        System.runAs(usr) {
        
            //list to hold the opportunity records
            List<Opportunity> opportunities = new List<Opportunity>();
            
            // get one record type name
            List<Id> recordTypes = new List<Id>();
            recordTypes.add(Util.RecordTypeId('Opportunity',Constants.RECORD_TYPE_OPPORTUNITY_PT_CONTRACT_MAINTENANCE));
            
            //Create Opportunity record
            Opportunity opportunity_1 = new Opportunity(Name = 'Opportunity Test1', StageName = 'Prospect', Amount = 4.00,
                                                         CloseDate = Date.today(), RecordTypeId = recordTypes[0],
                                                         Initial_PA_Date__c = System.today().addDays(3),
                                                         Competitor_Notes__c = 'Test 1'
                                                       );
            
            //Create Opportunity record
            Opportunity opportunity_2 = new Opportunity(Name = 'Opportunity Test2', StageName = 'Prospect', Amount = 4.00,
                                                         CloseDate = Date.today().addDays(4), RecordTypeId = recordTypes[0],
                                                         Initial_PA_Date__c = System.today().addDays(2),
                                                         Initial_Activity_Date__c = System.today().addDays(5),
                                                         Competitor_Notes__c = 'Test 2');
                                                         
            //Create Opportunity record
            Opportunity opportunity_3 = new Opportunity(Name = 'Opportunity Test3', StageName = 'Prospect', Amount = 4.00,
                                                         CloseDate = Date.today().addDays(4), RecordTypeId = recordTypes[0],
                                                         Initial_PA_Date__c = null, Initial_Activity_Date__c = null,
                                                         Competitor_Notes__c = 'Test 3');
            
            //Create Opportunity record
            Opportunity opportunity_4 = new Opportunity(Name = 'Opportunity Test4', StageName = 'Prospect', Amount = 4.00,
                                                         CloseDate = Date.today().addDays(4), RecordTypeId = recordTypes[0],
                                                         Initial_PA_Date__c = System.today().addDays(5),
                                                         Initial_Activity_Date__c = System.today().addDays(3),
                                                         Competitor_Notes__c = 'Test 4');
                                                         
            //Create Opportunity record
            Opportunity opportunity_5 = new Opportunity(Name = 'Opportunity Test5', StageName = 'Prospect', Amount = 4.00,
                                                         CloseDate = Date.today().addDays(4), RecordTypeId = recordTypes[0],
                                                         Initial_PA_Date__c = null, Competitor_Notes__c = 'Test 5',
                                                         Initial_Activity_Date__c = System.today().addDays(5));
            
            //Adding records in the list
            opportunities.add(opportunity_1);
            opportunities.add(opportunity_2);
            opportunities.add(opportunity_3);
            opportunities.add(opportunity_4);
            opportunities.add(opportunity_5);
            
            //Disabling triggers
            Util.byPassAllTriggers = true;
            
            //insert Opprotunity
            insert opportunities;
            
            //Querying for opportunity records
            opportunities = [SELECT ID, Name, Initial_PA_Date__c, Initial_Activity_Date__c, Competitor_Notes__c FROM Opportunity
                                ORDER BY Competitor_Notes__c ASC];
            
            //Asserting for the results
            System.assert(opportunities != null);
            System.assert(opportunities.size() > 0);
            
            //Program__c prog = [select id from Program__c limit 1];
            Program__c prog = new Program__c(Name = 'TestProg', Program_Acronym__c = 'TEST', Status__c = 'Active', 
                                                Create_Memberships__c = 'Yes');
            insert prog;
        
            //List to hold the warm lead records
            List<Warm_Lead__c> warmLeads = new List<Warm_Lead__c>();
            
            //Warm lead
            Warm_Lead__c warmLead_1 = new Warm_Lead__c(Name = 'Test Warm Lead 1', Lead_Date__c = Date.today(),
                                                        Lead_Channel__c = 'Breakout', Contact_level__c = 'CXO', Marketing_Associate_Assignment__c = usr.Id,
                                                        Marketer_Assignment__c = usr.Id, Status__c = 'Pending', 
                                                        Primary_Program__c = prog.Id);
            
            Warm_Lead__c warmLead_2 = new Warm_Lead__c(Name = 'Test Warm Lead 2', Lead_Date__c = Date.today(),
                                                        Lead_Channel__c = 'Breakout', Contact_level__c = 'CXO', 
                                                        Marketing_Associate_Assignment__c = usr.Id,
                                                        Marketer_Assignment__c = usr.Id, Status__c = 'Pending', 
                                                        Primary_Program__c = prog.Id);
                                                        
            //Adding records into the list
            warmLeads.add(warmLead_1);
            warmLeads.add(warmLead_2);
            
            //Disabling triggers
            Util.byPassAllTriggers = true;
            
            //insert warm leads
            insert warmLeads;
            
            //List to hold the warm lead record
            List<Warm_Lead_MtM__c> warmLeadMtMs = new List<Warm_Lead_MtM__c>(); 
            
            //Create WarmLeadMtM record
            Warm_Lead_MtM__c warmLeadMtM_1 = new Warm_Lead_MtM__c(Warm_Lead__c = warmLeads[0].Id, Opportunity__c = opportunities[0].Id);
        
            //Create WarmLeadMtM record
            Warm_Lead_MtM__c warmLeadMtM_3 = new Warm_Lead_MtM__c(Warm_Lead__c = warmLeads[1].Id, Opportunity__c = opportunities[1].Id);
            
            //Create WarmLeadMtM record
            Warm_Lead_MtM__c warmLeadMtM_2 = new Warm_Lead_MtM__c(Warm_Lead__c = warmLeads[0].Id, Opportunity__c = opportunities[2].Id);
            
            //Create WarmLeadMtM record
            Warm_Lead_MtM__c warmLeadMtM_4 = new Warm_Lead_MtM__c(Warm_Lead__c = warmLeads[0].Id, Opportunity__c = opportunities[3].Id);
            
            //Create WarmLeadMtM record
            Warm_Lead_MtM__c warmLeadMtM_5 = new Warm_Lead_MtM__c(Warm_Lead__c = warmLeads[1].Id, Opportunity__c = opportunities[4].Id);
            
            //Added as per the Refactor CR - CR-20150202-8638 - 07/12/2016 - Mahendra Swarnkar - Starts from here
            //Create WarmLeadMtM record
            Warm_Lead_MtM__c warmLeadMtM_6 = new Warm_Lead_MtM__c(Warm_Lead__c = warmLeads[1].Id, Opportunity__c = opportunities[4].Id);
            //Added as per the Refactor CR - CR-20150202-8638 - 07/12/2016 - Mahendra Swarnkar - Ends here 
            
            //Populating list with records
            warmLeadMtMs.add(warmLeadMtM_1);
            warmLeadMtMs.add(warmLeadMtM_2);
            warmLeadMtMs.add(warmLeadMtM_3);
            warmLeadMtMs.add(warmLeadMtM_4);
            warmLeadMtMs.add(warmLeadMtM_5);
            warmLeadMtMs.add(warmLeadMtM_6);
            
            //Disabling triggers
            Util.byPassAllTriggers = true;
            
            //Insert Warm lead Mtm's
            insert warmLeadMtMs;
            
            //Test will start from here
            Test.startTest();
            
            //Setting flag values
            OpportunityTriggerHelper.EXECUTE_TRIGGER_BEFORE_UPDATE = true;
            OpportunityTriggerHelper.EXECUTE_TRIGGER_AFTER_UPDATE = true;
            Util.ByPassAllTriggers = false;
            
            //Upate Opportunity
            opportunities[2].Initial_PA_Date__c = System.today().addDays(2);
            opportunities[1].Initial_Activity_Date__c = System.today().addDays(3);
            opportunities[4].Initial_Activity_Date__c = System.today().addDays(3);
            update opportunities;
            
            //Querying for opportunity records
            opportunities = [SELECT ID, Name, Initial_PA_Date__c, Initial_Activity_Date__c FROM Opportunity
                                ORDER BY Competitor_Notes__c ASC];
            
            //Warm Lead MTMs
            warmLeadMtMs = [SELECT ID, Opportunity_Initial_PA__c, Opportunity_Initial_Activity__c, Opportunity__c,
                                Opportunity__r.Competitor_Notes__c FROM Warm_Lead_MtM__c
                                WHERE Opportunity__c != null ORDER BY Opportunity__c ASC];
            
            //Asserting for the results
            //Updated the assert value from 5 to 6. - CR-20150202-8638 - 07/12/2016 - Mahendra Swarnkar - Starts from here
            System.assert(warmLeadMtMs != null);
            System.assertEquals(6, warmLeadMtMs.size());
            System.assertEquals(null, warmLeadMtMs[0].Opportunity_Initial_PA__c);
            System.assertEquals(null, warmLeadMtMs[0].Opportunity_Initial_Activity__c);
            System.assertEquals(System.today().addDays(2), warmLeadMtMs[1].Opportunity_Initial_PA__c);
            System.assertEquals(System.today().addDays(3), warmLeadMtMs[1].Opportunity_Initial_Activity__c);
            System.assertEquals(System.today().addDays(2), warmLeadMtMs[2].Opportunity_Initial_PA__c);
            System.assertEquals(null, warmLeadMtMs[2].Opportunity_Initial_Activity__c);
            System.assertEquals(null, warmLeadMtMs[3].Opportunity_Initial_PA__c);
            System.assertEquals(null, warmLeadMtMs[3].Opportunity_Initial_Activity__c);
            System.assertEquals(null, warmLeadMtMs[3].Opportunity_Initial_PA__c);
            System.assertEquals(null, warmLeadMtMs[3].Opportunity_Initial_Activity__c);            
             
            //Stop Test here
            Test.stopTest();
        }
    }

    //Modified by - Abhinav Sharma - CR-20150202-8638 - To refactor the existing code
    //Added By - Abhinav Sharma - 10/14/2015 - CR-20150831-9204
    /** Description : Method to test out CR-20150831-9204 based functionality.
    **/
    static testMethod void testpopulateCTAssignmentManagerEmail() {
        
        //Bypass Dupeblocker
        Util.IsTest(true);
        
        //Bypassing Triggers so then test data can be created easily
        Util.byPassAllTriggers = true;
        
        //Flag for triggers: this is just a test, don't do crazy things.
        Util.isTesting = true;
        
        //Get profile list
        List<Profile> testProfile = [Select Id, Name from Profile where Name = 'System Administrator'];
        
        //Assert for results
        System.assert(testProfile != null);
        System.assert(testProfile.size()>0);
                
        //Test User Create
        List<User> userList = new List<User>();
        
        userList.add(new User(Username= Math.random()+'@abc.com', LastName='Test User1', FirstName='Test1', 
                            Email='testuser1@test.com',
                            Alias='Test1', EmailEncodingKey='UTF-8', languagelocalekey='en_US', ProfileId=testProfile[0].Id, 
                            timezonesidkey='America/Los_Angeles', localesidkey='en_US', EmployeeNumber = '12121212', IsActive = true));
        userList.add(new User(Username= Math.random()+'@abc.com', LastName='Test User2', FirstName='Test2', 
                            Email='testuser2@test.com',
                            Alias='Test2', EmailEncodingKey='UTF-8', languagelocalekey='en_US', ProfileId=testProfile[0].Id, 
                            timezonesidkey='America/Los_Angeles', localesidkey='en_US', EmployeeNumber = '12121212', IsActive = true));
        userList.add(new User(Username= Math.random()+'@abc.com', LastName='Test User3', FirstName='Test3', 
                            Email='testuser3@test.com',
                            Alias='Test3', EmailEncodingKey='UTF-8', languagelocalekey='en_US', ProfileId=testProfile[0].Id, 
                            timezonesidkey='America/Los_Angeles', localesidkey='en_US', EmployeeNumber = '121232412', IsActive = true));
                
        //Insert users
        insert userList;
        
        //Update first user Manager lookup to second user
        userList[0].ManagerId = userList[2].Id;
        userList[2].ManagerId = userList[1].Id;
        update userList;
        
        System.runAs(userList[0]){
         
            //list to hold the opportunity records
            List<Opportunity> opportunities = new List<Opportunity>();
            
            // get one record type name
            List<Id> recordTypes = new List<Id>();
            recordTypes.add(Util.RecordTypeId('Opportunity',Constants.RECORD_TYPE_OPPORTUNITY_PT_CONTRACT_MAINTENANCE));
            
            //Create Opportunity record
            Opportunity opportunity_1 = new Opportunity(Name = 'Opportunity Test1', StageName = 'Prospect', Amount = 4.00,
                                                         CloseDate = Date.today(), RecordTypeId = recordTypes[0],
                                                         Competitor_Notes__c = 'Test 1',
                                                         CT_Assignment__c = userList[0].Id, CT_Pass_Status__c = 'Assigned', 
                                                         CT_Reneg_Attempt__c = 'No');
           
            //Create Opportunity record
            Opportunity opportunity_2 = new Opportunity(Name = 'Opportunity Test2', StageName = 'Prospect', Amount = 4.00,
                                                         CloseDate = Date.today().addDays(4), RecordTypeId = recordTypes[0],
                                                         Competitor_Notes__c = 'Test 2');
                                                         
            
            //Adding records in the list
            opportunities.add(opportunity_1);
            opportunities.add(opportunity_2);
            
            //Start test from here
            Test.startTest();
            
            //Setting flag values
            OpportunityTriggerHelper.EXECUTE_TRIGGER_BEFORE_UPDATE = true;
            OpportunityTriggerHelper.EXECUTE_TRIGGER_AFTER_UPDATE = true;
            Util.ByPassAllTriggers = false;
            
            //insert Opprotunity
            insert opportunities;
            
            //Query to retrive "Owner Manager Email" field from Opportunity record
            List<Opportunity> oppList = [SELECT ID, CT_Assignment_s_Manager__c, Competitor_Notes__c FROM Opportunity
                                            ORDER BY Competitor_Notes__c ASC];
             
            //Assert for the result
            System.assert(oppList != null);
            System.assertEquals(2, oppList.size());
            System.assertEquals('testuser3@test.com', oppList[0].CT_Assignment_s_Manager__c);
            System.assertEquals(null, oppList[1].CT_Assignment_s_Manager__c);
            
            //Disabling triggers
            Util.ByPassAllTriggers = true;
            
            //Updating CT Assignment field value
            opportunities[0].CT_Assignment__c = null;
            opportunities[1].CT_Assignment__c = userList[2].Id;
            
            //Update Opportunities
            OpportunityTriggerHelper.EXECUTE_TRIGGER_BEFORE_UPDATE = true;
            OpportunityTriggerHelper.EXECUTE_TRIGGER_AFTER_UPDATE = true;
            Util.ByPassAllTriggers = false;
            update opportunities;
            
            //Query to retrive "Owner Manager Email" field from Opportunity record
            oppList = [SELECT ID, CT_Assignment_s_Manager__c, Competitor_Notes__c FROM Opportunity
                        ORDER BY Competitor_Notes__c ASC];
            
            //Assert for the result
            System.assert(oppList != null);
            System.assertEquals(2, oppList.size());
            System.assertEquals(null, oppList[0].CT_Assignment_s_Manager__c);
            System.assertEquals('testuser2@test.com', oppList[1].CT_Assignment_s_Manager__c);
            
            //Disabling triggers
            Util.ByPassAllTriggers = true;
            
            opportunities[1].CT_Assignment__c = userList[1].Id;
            
            //Update Opportunities
            OpportunityTriggerHelper.EXECUTE_TRIGGER_BEFORE_UPDATE = true;
            OpportunityTriggerHelper.EXECUTE_TRIGGER_AFTER_UPDATE = true;
            Util.ByPassAllTriggers = false;
            update opportunities;
            
            //Query to retrive "Owner Manager Email" field from Opportunity record
            oppList = [SELECT ID, CT_Assignment_s_Manager__c, Competitor_Notes__c FROM Opportunity where Id =: opportunities[1].Id];
            
            //Assert for the result
            System.assert(oppList != null);
            System.assertEquals(1, oppList.size());
            System.assertEquals(null, oppList[0].CT_Assignment_s_Manager__c);
            
            //Test stops from here
            Test.stopTest();
        }
    }
    
    //Added by - Abhinav Sharma - CR-20150202-8638 - To refactor the existing code
    /** Description : Method to test out various miscellaneous use cases.
    **/
    static testMethod void testpopulateInitialVisitOnActivities() {
        
        //Enable flag to bypass trigger
        CRMfusionDBR101.DB_Globals.triggersDisabled = true;
        Util.isBatch = true;
        
        //Bypass Dupeblocker
        Util.IsTest(true);
        
        //Bypassing Triggers so then test data can be created easily
        Util.byPassAllTriggers = true;
        
        //Flag for triggers: this is just a test, don't do crazy things.
        Util.isTesting = true;
        
        //Create opportunty records
        List<Opportunity> oppList = new List<Opportunity>();
        for(integer i=1; i <= 5; i++) {
            oppList.add(new Opportunity(Name='Test Opp' + i, CloseDate = system.today()+7, How_many_prewires_were_completed__c = 0,
                                        StageName = 'Pending', Amount = 2000));
        }
        
        //Insert opportunity
        insert oppList;
        
        //Set date
        DateTime DTStart = System.Now().addDays(-2);
        Date DStart = Date.newInstance(DTStart.year(), DTStart.month(), DTStart.day());
        Date dt = System.today();
        DateTime dtt = System.now();
        
        //List to hold Events records
        List<Event> evntList = new List<Event>();
        
        //Add in list
        evntList.add(new Event(whatId = oppList[0].Id, StartDateTime = DTStart.addDays(-3), EndDateTime = DTStart.addDays(1), Executive_Type__c = 'CXO',
                                    Event_Type__c = Constants.EVENT_TYPE_IN_PERSON_VISIT, Event_Purpose__c = Constants.EVENT_PURPOSE_INITIAL));
        evntList.add(new Event(whatId = oppList[1].Id, StartDateTime = DTStart.addDays(-3), EndDateTime = DTStart.addDays(2), Executive_Type__c = 'CXO',
                                    Event_Type__c = Constants.EVENT_TYPE_IN_PERSON_VISIT, Event_Purpose__c = Constants.EVENT_PURPOSE_RELATIONSHIP_VISIT));
        evntList.add(new Event(whatId = oppList[2].Id, StartDateTime = DTStart.addDays(-3), EndDateTime = DTStart.addDays(3), Executive_Type__c = 'CXO',
                                    Event_Type__c = Constants.EVENT_TYPE_IN_PERSON_VISIT, Event_Purpose__c = 'Follow Up'));
        evntList.add(new Event(whatId = oppList[3].Id, StartDateTime = DTStart.addDays(-3), EndDateTime = DTStart.addDays(4), Executive_Type__c = 'CXO',
                                    Event_Type__c = Constants.EVENT_TYPE_OPPORTUNITY_VISIT_FOR_OPPORTUNITY_GOAL));
        evntList.add(new Event(whatId = oppList[4].Id, StartDateTime = DTStart.addDays(-3), EndDateTime = DTStart.addDays(5), Executive_Type__c = 'CXO',
                                    Event_Type__c = Constants.EVENT_TYPE_PROSPECT_MEETING_ATTENDEE_COUNT_AS_VISIT));
        
        //Insert 
        insert evntList;

        // Start testing
        Test.startTest();
        
        //Constrcuting query string
        String qry = 'select Id, Event_Type__c, Event_Purpose__c, ActivityDate, StartDateTime, EndDateTime, Grade__c, WhatId, What.Type from Event '
                        + 'where WhatId IN (\'' + oppList[0].Id  + '\',\'' + oppList[1].Id  + '\',\'' + oppList[2].Id  + '\',\'' + oppList[3].Id  + '\',\'' + oppList[4].Id  + '\')';
        
        //Batch Job instance initialization and setting query parameter
        Batch_ActivityCount batch = new Batch_ActivityCount();
        batch.queryStr = qry;

        //Execute Batch Job
        Id batchId = Database.executeBatch(batch);

        //Stop testing here
        Test.stopTest();
        
        //Query over opportunity
        List<Opportunity> opportunities = [Select Id, Next_PA_Date__c, Last_PA_Date__c, Initial_Visit_Date__c, Last_Visit_Date__c 
                                            from Opportunity where Id IN: oppList order by Name];
        
        //Assert for result
        System.assert(opportunities != null);
        System.assertEquals(5, opportunities.size());
        System.assertNotEquals(null, opportunities[0].Initial_Visit_Date__c);
        System.assertNotEquals(null, opportunities[1].Initial_Visit_Date__c);
        System.assertEquals(null, opportunities[2].Initial_Visit_Date__c);
        System.assertNotEquals(null, opportunities[3].Initial_Visit_Date__c);
        System.assertNotEquals(null, opportunities[4].Initial_Visit_Date__c);
    }
   
    //Added by - Abhinav Sharma - CR-20150202-8638 - To refactor the existing code
    /** Description : Method to test out various miscellaneous use cases.
    **/
    static testMethod void testupdateOpportunityNonSOXFields(){
        
        //Enable flag to bypass trigger
        CRMfusionDBR101.DB_Globals.triggersDisabled = true;
        
        //Bypass Dupeblocker
        Util.IsTest(true);
        
        //Bypassing Triggers so then test data can be created easily
        Util.byPassAllTriggers = true;
        
        //Flag for triggers: this is just a test, don't do crazy things.
        Util.isTesting = true;
        
        //temp variable
        Id specialistId;
        Id analystId;
        
        //Get profile list
        List<Profile> testProfile = [SELECT Id, Name from Profile WHERE Name = 'Specialist' OR Name = 'Analyst' ORDER BY Name];
        
        //Asserting for the results
        System.assert(testProfile != null);
        System.assert(testProfile.size() > 0);
        
        //Checking for the profile name and accordingly assigning the values to the variables
        if(testProfile[0].Name == 'Specialist'){
            specialistId = testProfile[0].Id;
            analystId = testProfile[1].Id;
        }
        else {
            specialistId = testProfile[1].Id;
            analystId = testProfile[0].Id;
        }
            
        //Test User Create
        User testUser = new User(Username = Math.random()+'@abc.com', LastName = 'Test User1', FirstName = 'Test1', Email = Math.random()+'@test.com',
                                        Alias = 'Test1', EmailEncodingKey='UTF-8', languagelocalekey = 'en_US', ProfileId = specialistId, 
                                        timezonesidkey = 'America/Los_Angeles', localesidkey = 'en_US', EmployeeNumber = '12121212', IsActive = true);

        //insert users
        insert testUser;

        //Create another test user                    
        User testUser1 = new User(Username = Math.random()+'@abc.com', LastName = 'Test User2', FirstName = 'Test2', Email = Math.random()+'@test.com',
                                        Alias = 'Test1', EmailEncodingKey='UTF-8', languagelocalekey = 'en_US', ProfileId = analystId, 
                                        timezonesidkey = 'America/Los_Angeles', localesidkey = 'en_US', EmployeeNumber = '12121212', IsActive = true);

        //insert users
        insert testUser1;

        //Insert the Custom Setting
        List<Configuration_Manager__c> customSettings = new List<Configuration_Manager__c>();
        customSettings.add(new Configuration_Manager__c(Name = 'Profile_Analyst', Parameter_Key__c = 'Profile edit fields when Opp is closed',
                    Parameter_Value__c = 'analyst'));
                    
        customSettings.add(new Configuration_Manager__c(Name = 'Field_Workshops', Parameter_Key__c = 'Editable field after Opp is closed',
                    Parameter_Value__c = 'Workshops__c'));                                                          

        //Insert record
        insert customSettings;
        
        //Asserting for the results
        System.assert(customSettings != null);
        System.assert(customSettings.size() > 0);      
        
        //Chaning the current context user
        System.runAs(testUser){
            
            //Create Account record
            Account testAccount = new Account(Name = 'Test-Account');
    
            //Insert record
            insert testAccount;
    
            //Create Program record
            Program__c program = TestUtilities.CreateNewProgram(false);
    
            //Insert record
            insert program;    

            //Set to hold Record Types
            Set<String> setRecordTypes = new Set<String> {'Core_AM_First_Year_Opp', 'Core_AM_Standard_Opp', 'BI_Contract_Maintenance', 'BI_Contract_Renewal'};
    
            //List of Record types
            List<RecordType> recordTypes = [SELECT Id, DeveloperName FROM RecordType WHERE IsActive = true AND SobjectType = 'Opportunity' 
                                                AND DeveloperName IN: setRecordTypes ORDER BY NAME];
                                                
            //Asserting for the results
            System.assert(recordTypes != null);
            System.assert(recordTypes.size() > 0);      
        
            //Getting Record Type Id Value for Opportunity
            ID oppRecordTypeId = [SELECT Id, Name FROM RecordType WHERE SobjectType = 'Opportunity' and DeveloperName = 'Southwind'].Id;
            System.assert(oppRecordTypeId != null);
        
            //Create Test Opportunity records
            List<Opportunity> testOpportunity = new List<Opportunity>();
             
            //Added record in list        
            testOpportunity.add(new Opportunity (Name = 'Test1', RecordTypeId = recordTypes[0].Id, AccountId = testAccount.Id,
                    StageName = 'Prospect', CloseDate = System.today().addDays(3), Trigger_Update__c = false,
                     Amount = 100, Workshops__c = 10, Editable_by_Finance_Ops_Only__c = false));
            testOpportunity.add(new Opportunity (Name = 'Test2', RecordTypeId = recordTypes[2].Id, AccountId = testAccount.Id,
                    StageName = 'Prospect', CloseDate = System.today().addDays(4), Trigger_Update__c = false,
                     Amount = 200, Workshops__c = 20, Editable_by_Finance_Ops_Only__c = false));
            testOpportunity.add(new Opportunity (Name = 'Test3', RecordTypeId = recordTypes[1].Id, AccountId = testAccount.Id,
                    StageName = 'Prospect', Amount = 500, CloseDate = System.today().addDays(9), Workshops__c = 50, 
                    Editable_by_Finance_Ops_Only__c = false, Trigger_Update__c = false)); 
            
            testOpportunity.add(new Opportunity (Name = 'Test3', RecordTypeId = oppRecordTypeId, AccountId = testAccount.Id,
                    StageName = 'Prospect', Amount = 500, CloseDate = System.today().addDays(9), Workshops__c = 50, 
                    Editable_by_Finance_Ops_Only__c = false, Trigger_Update__c = false)); 
        
            //Insert Opportunity
            insert testOpportunity;

            //Test starts here
            Test.startTest();

            try {
                
                //Setting flags     
                OpportunityTriggerHelper.EXECUTE_TRIGGER_BEFORE_UPDATE = true;
                OpportunityTriggerHelper.EXECUTE_TRIGGER_AFTER_UPDATE = true;
                Util.byPassAllTriggers=false;
        
                //Update
                update testOpportunity[2];
                
                Util.byPassAllTriggers=true;
            
            } catch(Exception e){
            
                //Assert for result
                System.assert(false);
            
            } 
        
            try {
            
                //Sert value to update
                testOpportunity[0].StageName = Constants.CLOSED;
                testOpportunity[1].StageName = Constants.CLOSED;
                
                //Setting flag values
                OpportunityTriggerHelper.EXECUTE_TRIGGER_BEFORE_UPDATE = true;
                OpportunityTriggerHelper.EXECUTE_TRIGGER_AFTER_UPDATE = true; 
                Util.byPassAllTriggers=false;
            
                //Update list 
                update testOpportunity;
        
            } catch(Exception e){
                
                //Assert for result
                System.assert(e.getMessage().contains(Label.ERROR_ONLY_FINANCE_OPS_CAN_CLOSE_AN_OPP));
            }
        
            try {
            
                //Sert value to update
                testOpportunity[3].StageName = Constants.CLOSED;
                
                //Setting flag values
                OpportunityTriggerHelper.EXECUTE_TRIGGER_BEFORE_UPDATE = true;
                OpportunityTriggerHelper.EXECUTE_TRIGGER_AFTER_UPDATE = true; 
                Util.byPassAllTriggers=false;
            
                //Update list
                update testOpportunity[3];
            
            } catch(Exception e){
                
                //Assert for result
                System.assert(e.getMessage().contains(Label.ERROR_ONLY_FINANCE_OPS_CAN_CLOSE_AN_OPP));
            }  
        
            //Test method stopo here
            Test.stopTest();
        }
    }

    //Added by - Abhinav Sharma - CR-20150202-8638 - To refactor the existing code
    /** Description : Method to test out various miscellaneous use cases.
    **/
    static testMethod void testOpportunityValidationAndFieldUpdated() {
        
        //Enable flag to bypass trigger
        CRMfusionDBR101.DB_Globals.triggersDisabled = true;
        
        //Bypass Dupeblocker
        Util.IsTest(true);
        
        //Bypassing Triggers so then test data can be created easily
        Util.byPassAllTriggers = true;
        
        //Flag for triggers: this is just a test, don't do crazy things.
        Util.isTesting = true;
        
        //Creating Test Date
        //Set to hold Record Types
        Set<String> setRecordTypes = new Set<String> {'PT Marketing','RI AM First Year Opp', 'RI Marketing'};

        //List of Record types
        List<RecordType> recordTypes = [SELECT Id, DeveloperName FROM RecordType WHERE IsActive = true AND SobjectType = 'Opportunity' 
                                            AND Name IN: setRecordTypes ORDER BY NAME];
                                            
        //Asserting for the results
        System.assert(recordTypes != null);
        System.assert(recordTypes.size() > 0);
        
        //Account
        Account account = new Account(Name = 'Test Acc', Account_Formal_Name__c = 'testacc');
        insert account;

        //Contact
        Contact contact = new Contact(LastName = 'Test', FirstName = 'Con');
        insert contact;

        //Program Having Business Line as 'PT'
        Program__c program = TestUtilities.CreateNewProgram(false);
        insert program;
        
        //Asserting for the results
        System.assertNotEquals(null,program.id);
  
        //Create membership data
        Membership__c mem = new Membership__c(Account_Name__c = account.id, Program__c = program.id);
        insert mem;
        
        //List to hold the Opportunity records
        List<Opportunity> opportunities = new List<Opportunity>();
        
        //Added Opportunity records in list
        opportunities.add(new Opportunity(AccountId = account.Id, Program__c = program.Id, Name = 'Test1',
                                            StageName = 'Prospect', pool_Month__c = '1',
                                            RecordTypeId = recordTypes[0].Id, CloseDate = System.today().addDays(7), 
                                            Pool_Year__c = String.valueOf(Date.Today().Year()),
                                            Decision_Type__c = 'Need New LOA 1',
                                            Previous_Year_Negotiated_Adjustment__c = 4000));

        opportunities.add(new Opportunity(AccountId = account.Id, Program__c = program.Id, Name = 'Test2',
                                            StageName = 'Prospect', pool_Month__c = '1',
                                            RecordTypeId = recordTypes[0].Id, CloseDate = System.today().addDays(7), 
                                            Pool_Year__c = String.valueOf(Date.Today().Year()),
                                            Decision_Type__c = 'Need New LOA 2',
                                            Previous_Year_Negotiated_Adjustment__c = 5000));

        opportunities.add(new Opportunity(AccountId = account.Id, Program__c = program.Id, Name = 'Test3',
                                            StageName = 'Prospect', pool_Month__c = '1',
                                            RecordTypeId = recordTypes[1].Id, CloseDate = System.today().addDays(7), 
                                            Pool_Year__c = String.valueOf(Date.Today().Year()),
                                            Decision_Type__c = 'Need New LOA 3', Main_Contact__c = contact.Id,
                                            Previous_Year_Negotiated_Adjustment__c = 3000));

        opportunities.add(new Opportunity(AccountId = account.Id, Program__c = program.Id, Name = 'Test4',
                                            StageName = 'Prospect', pool_Month__c = '1',
                                            RecordTypeId = recordTypes[1].Id, CloseDate = System.today().addDays(7), 
                                            Pool_Year__c = String.valueOf(Date.Today().Year()),  
                                            Decision_Type__c = 'Need New LOA 4', Main_Contact__c = contact.Id,
                                            Previous_Year_Negotiated_Adjustment__c = 2000));
        
        //Insert
        insert opportunities;
        
        //List to hold Contract Document records
        List<Contract_Document__c> cntrct = new List<Contract_Document__c>();
        
        //Added records in list
        cntrct.add(new Contract_Document__c(Name__c = 'testcdoc name1', Type__c = 'Engagement Agreement'));
        cntrct.add(new Contract_Document__c(Name__c = 'testcdoc name2', Type__c = 'Engagement Agreement'));
        
        //Insert
        insert cntrct;
        
        //List to hold Contract_Docs_to_Opps_MtM records
        List<Contract_Docs_to_Opps_MtM__c> contractDocs = new List<Contract_Docs_to_Opps_MtM__c>();
        
        //Added records in list
        contractDocs.add(new Contract_Docs_to_Opps_MtM__c(Opportunity__c = opportunities[0].Id, Contract_Documents__c = cntrct[0].Id));
        contractDocs.add(new Contract_Docs_to_Opps_MtM__c(Opportunity__c = opportunities[0].Id, Contract_Documents__c = cntrct[0].Id));
        contractDocs.add(new Contract_Docs_to_Opps_MtM__c(Opportunity__c = opportunities[1].Id, Contract_Documents__c = cntrct[1].Id));
        contractDocs.add(new Contract_Docs_to_Opps_MtM__c(Opportunity__c = opportunities[1].Id, Contract_Documents__c = cntrct[1].Id));
        
        //Insert
        insert contractDocs;
        
        //Start Test From Here
        Test.startTest();
        
        //Set value to update in records
        opportunities[0].StageName = 'Contract Received – Send to Finance';
        opportunities[1].StageName = 'Contract Received – Send to Finance';
        opportunities[2].StageName = 'Contract Received – Send to Finance';
        opportunities[3].StageName = 'Contract Received – Send to Finance';
        
        try {
            
            //Setting flag value
            OpportunityTriggerHelper.EXECUTE_TRIGGER_BEFORE_UPDATE = true;
            OpportunityTriggerHelper.EXECUTE_TRIGGER_AFTER_UPDATE = true; 
                    
            // bypass all triggers so we don't hit soql query limits
            Util.BypassAllTriggers = false;
        
            //Update
            update opportunities;
            
                        
        } catch(Exception ex) {
            
            //Assert for result
            System.assert(ex.getMessage().contains('The Stage you have selected requires an LOA and a Main Contact'));
        }
        
        //Set value to update
        opportunities[0].StageName = 'Prospect';
        opportunities[1].StageName = 'Prospect';
        opportunities[2].StageName = 'Prospect';
        opportunities[3].StageName = 'Prospect';
        
        //Setting flag value
        OpportunityTriggerHelper.EXECUTE_TRIGGER_BEFORE_UPDATE = true;
        OpportunityTriggerHelper.EXECUTE_TRIGGER_AFTER_UPDATE = true; 
                
        // bypass all triggers so we don't hit soql query limits
        Util.BypassAllTriggers = false;
        
        //Update
        update opportunities;
        
        //Query over Opportunity
        List<Opportunity> oppList = [Select Id, StageName From Opportunity ORDER BY Decision_Type__c ASC LIMIT 5];
        
        //Assert for result
        System.assert(oppList != null);
        System.assertEquals('Prospect', oppList[0].StageName);
        System.assertEquals('Prospect', oppList[1].StageName);
        System.assertEquals('Prospect', oppList[2].StageName);
        System.assertEquals('Prospect', oppList[3].StageName);
        
        //Set vvalue to update
        opportunities[0].StageName = 'Contract Received – Send to Finance';
        opportunities[1].StageName = 'Contract Received – Send to Finance';
        opportunities[0].Main_Contact__c = contact.Id;
        opportunities[1].Main_Contact__c = contact.Id;
        opportunities[2].StageName = 'Contract Received – Send to Finance';
        opportunities[3].StageName = 'Contract Received – Send to Finance';
        
        try {
        
            //Setting flag values
            OpportunityTriggerHelper.EXECUTE_TRIGGER_BEFORE_UPDATE = true;
            OpportunityTriggerHelper.EXECUTE_TRIGGER_AFTER_UPDATE = true; 
            
            //Enabling triggers
            Util.byPassAlltriggers = false;
            
            //Update
            update opportunities;
            
        } catch(Exception ex) {
            
            //Assert for result
            System.assert(ex.getMessage().contains('The Stage you have selected requires an LOA, Main Contact and Contract Strategy Outcome'));
            
        }
        
        //Stop Test from here
        Test.stopTest();
    }
    
    //Added By - Subhash Garhwal - 06/25/2016 - CR-20160414-9762 
    static testMethod void testPreventManualDuplicateProgramOpportunities() { 
    
        //List of opportunities
        List<Opportunity> opportunities = new List<Opportunity>();
    
        //List of custom setting
        List<Recordtype_Setting__c> customSettings = new List<Recordtype_Setting__c>();
        
        //Query on record type
        List<RecordType> recordTypes = [SELECT ID,Name, sObjectType, DeveloperName FROM RecordType WHERE sObjectType = 'Opportunity' 
                                         AND DeveloperName IN : CPQConstants.SET_OPPORTUNITY_CPQ_RT_DEVELOPER_NAME ORDER BY DeveloperName];
                                          
        //Loop through opportunity active record types and populating the map accordingly
        for(RecordType rT : recordTypes)
            customSettings.add(new Recordtype_Setting__c(SFID__c = rT.Id, Name = rT.Id, 
                                                         Name__c = rT.Name, SObjectType__c = rT.SObjectType));
        
        //Check list size and insert
        if(customSettings.size() > 0)
            insert customSettings;
        
        //Parent Opportunity
        opportunities.add(new Opportunity(Name = 'Opportunity Test1', StageName = 'Prospect', Amount = 4.00, CloseDate = Date.today(),
                                         RecordTypeId = recordTypes[0].Id, Competitor_Notes__c = 'Test 1', CT_Pass_Status__c = 'Assigned', 
                                     CT_Reneg_Attempt__c = 'No'));
        opportunities.add(new Opportunity(Name = 'Opportunity Test2', StageName = 'Prospect', Amount = 4.00, CloseDate = Date.today(),
                                         RecordTypeId = recordTypes[0].Id, Competitor_Notes__c = 'Test 1', CT_Pass_Status__c = 'Assigned', 
                                         CT_Reneg_Attempt__c = 'No'));
        
        //By pass for parent Opportunity
        Util.BypassAllTriggers = true;
        
        //Insert
        insert opportunities;
        
        //Assert
        System.assert(opportunities.size() > 0);
        
        //List of Programs
        List<Program__c> programs = new List<Program__c>();
        
        //Create a program and Insert
        Program__c prog = TestUtilities.CreateNewProgram(false);
        prog.Program_Abbreviation__c = 'Test Program';
        
        //Add Program into list
        programs.add(prog);
        
        //Create a program and Insert
        Program__c prog1 = TestUtilities.CreateNewProgram(false);
        prog1.Program_Abbreviation__c = 'Test Program 1';
        
        //Add Program into list
        programs.add(prog1);
        
        //By pass trigger
        Util.bypassAllTriggers = true;
        
        //Insert
        insert programs;
        
        //Assert
        System.assert(programs.size() > 0);
        
        //Child opportunity To Insert
        List<Opportunity> childOpportunities = new List<Opportunity>();
        
        //Add child Opp in list
        childOpportunities.add(new Opportunity(Name = 'OpportunityChild1', StageName = 'Prospect', Amount = 4.00, CloseDate = Date.today(),
                                         RecordTypeId = recordTypes[1].Id, Competitor_Notes__c = 'Test 1', CT_Pass_Status__c = 'Assigned',
                                         Program__c = programs[0].Id, Parent_Opportunity__c = opportunities[0].Id,
                                         CT_Reneg_Attempt__c = 'No', Admin_Override__c = false));
        childOpportunities.add(new Opportunity(Name = 'OpportunityChild2', StageName = 'Prospect', Amount = 4.00, CloseDate = Date.today().addDays(1),
                                         RecordTypeId = recordTypes[2].Id, Competitor_Notes__c = 'Test 1', CT_Pass_Status__c = 'Assigned', 
                                         Program__c = programs[0].Id, Parent_Opportunity__c = opportunities[1].Id, CT_Reneg_Attempt__c = 'No',
                                         Admin_Override__c = false));
        childOpportunities.add(new Opportunity(Name = 'OpportunityChild3', StageName = 'Prospect', Amount = 4.00, CloseDate = Date.today().addDays(2),
                                         RecordTypeId = recordTypes[3].Id, Competitor_Notes__c = 'Test 1', CT_Pass_Status__c = 'Assigned', 
                                         Program__c = programs[0].Id, Parent_Opportunity__c = opportunities[0].Id, CT_Reneg_Attempt__c = 'No',
                                         Admin_Override__c = false));
        
        //Start Testing Here
        Test.startTest();
        
        //Fire trigger
        Util.bypassAllTriggers = false;
        
        //Insert Opp records 
        try{    
            insert childOpportunities;
            System.assert(false);
        }
        
        //Handle  Exception
        Catch(Exception ex) {
            System.assert(true);
            System.assert(ex.getMessage().contains(CPQConstants.PROGRAM_OPPORTUNITY_DUPLICATE_ERROR_MESG));
        }
        
        //Change Program record
        childOpportunities[2].Program__c = programs[1].Id;
        
        //Insert
        insert childOpportunities;
        
        // Query on Opportunity
        List<Opportunity> insertedOpps =  [Select Id, Name From Opportunity Where Id IN : childOpportunities order By CloseDate];
        
        //Assert for results
        System.assertEquals(3, insertedOpps.size());
        
        //Delete custom setting data
        delete [Select Id From Recordtype_Setting__c];
        
        //Record Type custom setting
        customSettings = new List<Recordtype_Setting__c>();
        
        //Loop through opportunity active record types and populating the map accordingly
        for(RecordType rT : recordTypes)
            customSettings.add(new Recordtype_Setting__c(SFID__c = rT.Id, Name = rT.Id, 
                                                         Name__c = rT.Name, SObjectType__c = rT.SObjectType));
        
        //Check list size and insert
        if(customSettings.size() > 0) {
            
            try {
                insert customSettings;  
            } catch(Exception e) {
                
            }
        }
            
        //Fire trigger
        Util.bypassAllTriggers = false;
        OpportunityTriggerHelper.EXECUTE_TRIGGER_BEFORE_UPDATE = true;
        
        //Update Inserted Opp
        insertedOpps[0].Program__c = programs[1].Id;
        
        //Insert Opp records 
        try{
            update insertedOpps;
            System.assert(false);
        }
        //Handle  Exception
        Catch(Exception ex) {
            System.assert(ex.getMessage().contains(CPQConstants.PROGRAM_OPPORTUNITY_DUPLICATE_ERROR_MESG));
        }
        
        delete [Select Id From Recordtype_Setting__c];
        
        //Record Type custom setting
        customSettings = new List<Recordtype_Setting__c>();
        
        //Loop through opportunity active record types and populating the map accordingly
        for(RecordType rT : recordTypes)
            customSettings.add(new Recordtype_Setting__c(SFID__c = rT.Id, Name = rT.Id, 
                                                         Name__c = rT.Name, SObjectType__c = rT.SObjectType));
        
        //Check list size and insert
        if(customSettings.size() > 0) {
            
            try {
                insert customSettings;  
            } catch(Exception e) {
                
            }
        }
        
        Opportunity opp = new Opportunity(Name = 'OpportunityChild1', StageName = 'Prospect', Amount = 4.00, CloseDate = Date.today(),
                                         RecordTypeId = recordTypes[1].Id, Competitor_Notes__c = 'Test 1', CT_Pass_Status__c = 'Assigned',
                                         Program__c = programs[0].Id, Parent_Opportunity__c = opportunities[0].Id,
                                         CT_Reneg_Attempt__c = 'No', Admin_Override__c = false);
        
        //Insert Opp records 
        try{
            insert opp;
            System.assert(false);
        }
        
        //Handle  Exception
        Catch(Exception ex) {
            System.assert(ex.getMessage().contains(CPQConstants.PROGRAM_OPPORTUNITY_DUPLICATE_ERROR_MESG));
        }
        
        //Stop test
        Test.stopTest();
    }
    
    //Added By - Subhash Garhwal - 7/11/2016 - CR-20160414-9762
    static testMethod void testValidateProgramOpportunities() {
        
        //Set all the required flags
        Util.IsTest(true);
        Util.byPassAllTriggers = true;
        
        //List to hold account Records
        List<Account> accounts = new List<Account>();
        
        //Add new account record in list
        accounts.add(new Account(Name = ' Acc1'));
        accounts.add(new Account(Name = ' Acc2'));
        
        //Insert accounts
        insert accounts;
        
        //Assert
        System.assert(accounts.size() > 0);
        
        //List of Programs
        List<Program__c> programs = new List<Program__c>();
        
        //Create a program and Insert
        Program__c prog = TestUtilities.CreateNewProgram(false);
        prog.Program_Abbreviation__c = 'Test Program';
        
        //Add Program into list
        programs.add(prog);
        
        //Create a program and Insert
        Program__c prog1 = TestUtilities.CreateNewProgram(false);
        prog1.Program_Abbreviation__c = 'Test Program 1';
        
        //Add Program into list
        programs.add(prog1);
        
        //ByPass triggers
        Util.byPassAllTriggers = true;
        
        //Insert
        insert programs;
        
        //Assert
        System.assert(programs.size() > 0);
        
        //Query on record type
        List<RecordType> recordTypes = [SELECT ID,Name, sObjectType, DeveloperName FROM RecordType WHERE sObjectType = 'Opportunity' 
                                         AND DeveloperName IN : CPQConstants.SET_OPPORTUNITY_CPQ_RT_DEVELOPER_NAME ORDER BY DeveloperName];
        
        //list to hold the opportunity records
        List<Opportunity> contractLOAOpps = new List<Opportunity>();
        
        //Create Opportunity record (Contract LOA opps) 
        contractLOAOpps.add(new Opportunity(Name = 'Test 1', StageName = CPQConstants.OPPORTUNITY_STAGE_ON_DECK, Amount = 4.00, CloseDate = Date.today(),
                                        RecordTypeId = recordTypes[0].Id, Competitor_Notes__c = 'ABC 1', CT_Pass_Status__c = 'Assigned', 
                                        CT_Reneg_Attempt__c = 'No', AccountId = accounts[0].Id));
        
        contractLOAOpps.add(new Opportunity(Name = 'Test 2', StageName = CPQConstants.OPPORTUNITY_STAGE_ON_DECK, Amount = 4.00,CloseDate = Date.today(), 
                                        RecordTypeId = recordTypes[0].Id, Competitor_Notes__c = 'ABC 2',CT_Pass_Status__c = 'Assigned',
                                        CT_Reneg_Attempt__c = 'No', AccountId = accounts[1].Id));
        
        //ByPass triggers
        Util.byPassAllTriggers = true;
                                                     
        //Insert 
        insert contractLOAOpps;
        
        //Assert
        System.assert(contractLOAOpps.size() > 0);
        
        //List to hold the Program Opps
        List<Opportunity> programOpps = new List<Opportunity>();
        
        //Add Program Opps in list 
        programOpps.add(new Opportunity(Name = 'Test 1', StageName = CPQConstants.OPPORTUNITY_STAGE_ON_DECK, Amount = 4.00, CloseDate = Date.today(),
                                        RecordTypeId = recordTypes[1].Id, Competitor_Notes__c = 'Test 1', CT_Pass_Status__c = 'Assigned', 
                                        CT_Reneg_Attempt__c = 'No', Parent_Opportunity__c = contractLOAOpps[0].Id,  AccountId = accounts[0].Id,
                                        Program__c = programs[0].Id));
        
        programOpps.add(new Opportunity(Name = 'Test 2', StageName = CPQConstants.OPPORTUNITY_STAGE_ON_DECK, Amount = 5.00,CloseDate = Date.today(), 
                                        RecordTypeId = recordTypes[2].Id, Competitor_Notes__c = 'Test 2',CT_Pass_Status__c = 'Assigned',
                                        CT_Reneg_Attempt__c = 'No', Parent_Opportunity__c = contractLOAOpps[0].Id,  AccountId = accounts[0].Id,
                                        Program__c = programs[0].Id));
        
        programOpps.add(new Opportunity(Name = 'Test 3', StageName = CPQConstants.OPPORTUNITY_STAGE_ON_DECK, Amount = 6.00, CloseDate = Date.today(),
                                        RecordTypeId = recordTypes[3].Id, Competitor_Notes__c = 'Test 3', CT_Pass_Status__c = 'Assigned', 
                                        CT_Reneg_Attempt__c = 'No', Parent_Opportunity__c = contractLOAOpps[1].Id,  AccountId = accounts[1].Id,
                                        Program__c = programs[1].Id));
        
        //ByPass triggers
        Util.byPassAllTriggers = true;
        
        //Insert
        insert programOpps;
        
        //Update Contract LOA Opps account and close date
        contractLOAOpps[0].AccountId = accounts[1].Id;
        contractLOAOpps[1].CloseDate = System.today().addDays(10); 
        
        //Start methed 
        Test.startTest();
        
        Util.byPassAllTriggers = false;
        
        //Update
        update contractLOAOpps;
        
        //Query through Program Opps
        List<Opportunity> programOpportunities = [Select Id, AccountId, CloseDate, Parent_Opportunity__c From Opportunity
                                                         Where Parent_Opportunity__c IN : contractLOAOpps ORDER BY Amount ASC];
        
        //Assert for result
        System.assertEquals(3, programOpportunities.size());
        System.assertEquals(accounts[1].Id, programOpportunities[0].AccountId);
        System.assertEquals(System.today(), programOpportunities[0].CloseDate);
        System.assertEquals(accounts[1].Id, programOpportunities[1].AccountId);
        System.assertEquals(System.today(), programOpportunities[1].CloseDate);
        System.assertEquals(accounts[1].Id, programOpportunities[2].AccountId);
        System.assertEquals(System.today().addDays(10), programOpportunities[2].CloseDate);
        
        //Stop test
        Test.stopTest();   
    }
    
    //Added By - Subhash Garhwal - 7/20/2016 - CR-20160414-9762
    static testMethod void testSyncRenewalOpp() {
        
        //Set Flags
        Util.IsTest(true);
        Util.byPassAllTriggers=true;
        
        //Insert Account
        Account acc = new Account(Name = 'Account 1');
        
        insert acc;
        
        //Assert
        System.assert(acc != null);
        
        //Get Contract LOA record type
        List<RecordType> recordTypes = [Select Id, Name FROM RecordType WHERE SobjectType = 'Opportunity' AND DeveloperName =: CPQConstants.OPPORTUNITY_RECORD_TYPE_DEVELOPERNAME_CONTRACT_LOA LIMIT 1];
        
        //Assert
        System.assertEquals(1, recordTypes.size());
        
        //Opportunity List (Contract LOA)
        List<Opportunity> opportunities = new List<Opportunity>();
        
        //Create Opportunity record 
        opportunities.add(new Opportunity(Name = 'Test 1', Opportunity_Nickname__c = 'Contract LOA Opp 1', StageName = CPQConstants.OPPORTUNITY_STAGE_ON_DECK, Amount = 4.00, CloseDate = Date.today(),
                                        RecordTypeId = recordTypes[0].Id, Competitor_Notes__c = 'ABC 1', CT_Pass_Status__c = 'Assigned', 
                                        CT_Reneg_Attempt__c = 'No', AccountId = acc.Id));
        
        opportunities.add(new Opportunity(Name = 'Test 2', Opportunity_Nickname__c = 'Contract LOA Opp 2', StageName = CPQConstants.OPPORTUNITY_STAGE_ON_DECK, Amount = 4.00, CloseDate = Date.today(), 
                                        RecordTypeId = recordTypes[0].Id, Competitor_Notes__c = 'ABC 2',CT_Pass_Status__c = 'Assigned',
                                        CT_Reneg_Attempt__c = 'No', AccountId = acc.Id));
        
        //ByPass triggers
        Util.byPassAllTriggers=true;                                            
        
        //Insert 
        insert opportunities;
        
        //Assert
        System.assert(opportunities.size() > 0);
        
        //List of Quote
        List<SBQQ__Quote__c> quotes = new List<SBQQ__Quote__c>();
        
        //Add new quote record in list
        quotes.add(new SBQQ__Quote__c(SBQQ__Status__c = 'Draft', SBQQ__Type__c = 'Quote', SBQQ__Primary__c = true, SBQQ__Opportunity2__c = opportunities[0].Id));
        quotes.add(new SBQQ__Quote__c(SBQQ__Status__c = 'Draft', SBQQ__Type__c = 'Quote', SBQQ__Primary__c = true, SBQQ__Opportunity2__c = opportunities[1].Id));
        
        //ByPass triggers
        Util.byPassAllTriggers = true;
        
        //Insert
        insert quotes;
        
        
        //List to create contract records
        List<Contract> contracts = new List<Contract>();
        
        //Contracts
        contracts.add(new Contract(Name = 'contract1', AccountId = acc.Id, SBQQ__Quote__c = quotes[0].Id, SBQQ__Opportunity__c = opportunities[0].Id, StartDate = System.today(), ContractTerm = 1));
        contracts.add(new Contract(Name = 'contract2', AccountId = acc.Id, SBQQ__Quote__c = quotes[1].Id, SBQQ__Opportunity__c = opportunities[1].Id, StartDate = System.today(), ContractTerm = 2));
        
        //By Pass triggers
        Util.byPassAllTriggers = true;
        
        //Insert
        insert contracts;
        
        //Assert
        System.assert(contracts.size() > 0);
        
        //Opportunity List (Renewal Opps)
        List<Opportunity> renewalOpps = new List<Opportunity>();
        
        //Create Opportunity record 
        renewalOpps.add(new Opportunity(Name = 'Test 1', Opportunity_Nickname__c = 'Renewal Opp 1', StageName = 'Pipeline', Amount = 0, CloseDate = Date.today(),
                                        RecordTypeId = recordTypes[0].Id, Competitor_Notes__c = 'ABC 1', CT_Pass_Status__c = 'Assigned', 
                                        CT_Reneg_Attempt__c = 'No', AccountId = acc.Id, SBQQ__Renewal__c = true, SBQQ__RenewedContract__c = contracts[0].Id));
        
        renewalOpps.add(new Opportunity(Name = 'Test 2', Opportunity_Nickname__c = 'Renewal Opp 2', StageName = 'Pipeline', Amount = 0, CloseDate = Date.today(), 
                                        RecordTypeId = recordTypes[0].Id, Competitor_Notes__c = 'ABC 2',CT_Pass_Status__c = 'Assigned',
                                        CT_Reneg_Attempt__c = 'No', AccountId = acc.Id, SBQQ__Renewal__c = true, SBQQ__RenewedContract__c = contracts[1].Id));
        
        //Start testing from here 
        Test.startTest();  
        
        //Set flag to flase to execute triggers
        Util.byPassAllTriggers=false;
        
        //Insert
        insert renewalOpps;
        
        //Query through renewal opps
        List<Opportunity> renewalOpportunities = [Select Id, StageName, CloseDate,Opportunity_Nickname__c,Calculated_Close_Date__c, Type,
                                                         SBQQ__RenewedContract__r.EndDate From Opportunity Where Id IN :renewalOpps ORDER BY CloseDate ASC];
        
        //Assert for result
        System.assertEquals(2, renewalOpportunities.size());
        System.assertEquals('Contract LOA Opp 1', renewalOpportunities[0].Opportunity_Nickname__c);
        System.assertEquals(CPQConstants.OPPORTUNITY_STAGE_ON_DECK, renewalOpportunities[0].StageName);
        System.assertEquals(CPQConstants.OPPORTUNITY_TYPE_CONTRACT_RENEWAL_OPPORTUNITY, renewalOpportunities[0].Type);
        System.assertEquals(renewalOpportunities[0].SBQQ__RenewedContract__r.EndDate, renewalOpportunities[0].CloseDate);
        System.assertEquals(renewalOpportunities[0].SBQQ__RenewedContract__r.EndDate, renewalOpportunities[0].Calculated_Close_Date__c);
        System.assertEquals('Contract LOA Opp 2', renewalOpportunities[1].Opportunity_Nickname__c);
        System.assertEquals(CPQConstants.OPPORTUNITY_STAGE_ON_DECK, renewalOpportunities[1].StageName);
        System.assertEquals(CPQConstants.OPPORTUNITY_TYPE_CONTRACT_RENEWAL_OPPORTUNITY, renewalOpportunities[1].Type);
        System.assertEquals(renewalOpportunities[1].SBQQ__RenewedContract__r.EndDate, renewalOpportunities[1].CloseDate);
        System.assertEquals(renewalOpportunities[1].SBQQ__RenewedContract__r.EndDate, renewalOpportunities[1].Calculated_Close_Date__c);
        
        //Stop testing here
        Test.stopTest();
    }
    
    //Added By - Subhash Garhwal - 7/21/2016 - CR-20160414-9762 
    static testMethod void testCreateIntegratedAccountForRenewalOpps() {
        
        //Set Flags
        Util.IsTest(true);
        Util.byPassAllTriggers=true;
        
        //List of Account
        List<Account> accounts = new List<Account>();
        
        //Add new account in list
        accounts.add(new Account(Name = 'Account 1'));
        accounts.add(new Account(Name = 'Account 2'));
        accounts.add(new Account(Name = 'Account 3'));
        
        //Insert
        insert accounts;
        
        //Assert
        System.assert(accounts.size() > 0);
        
        //Get Contract LOA record type
        List<RecordType> recordTypes = [Select Id, Name FROM RecordType WHERE SobjectType = 'Opportunity' AND DeveloperName =: CPQConstants.OPPORTUNITY_RECORD_TYPE_DEVELOPERNAME_CONTRACT_LOA LIMIT 1];
        
        //Assert
        System.assertEquals(1, recordTypes.size());
        
        //Opportunity List (Contract LOA)
        List<Opportunity> opportunities = new List<Opportunity>();
        
        //Create Opportunity record 
        opportunities.add(new Opportunity(Name = 'Test 1', Opportunity_Nickname__c = 'Contract LOA Opp 1', StageName = CPQConstants.OPPORTUNITY_STAGE_ON_DECK, Amount = 4.00, CloseDate = Date.today(),
                                        RecordTypeId = recordTypes[0].Id, Competitor_Notes__c = 'ABC 1', CT_Pass_Status__c = 'Assigned', 
                                        CT_Reneg_Attempt__c = 'No', AccountId = accounts[0].Id));
        
        opportunities.add(new Opportunity(Name = 'Test 2', Opportunity_Nickname__c = 'Contract LOA Opp 2', StageName = CPQConstants.OPPORTUNITY_STAGE_ON_DECK, Amount = 4.00, CloseDate = Date.today(), 
                                        RecordTypeId = recordTypes[0].Id, Competitor_Notes__c = 'ABC 2',CT_Pass_Status__c = 'Assigned',
                                        CT_Reneg_Attempt__c = 'No', AccountId = accounts[0].Id));
        
        //ByPass triggers
        Util.byPassAllTriggers=true;                                            
        
        //Insert 
        insert opportunities;
        
        //Assert
        System.assert(opportunities.size() > 0);
        
        //List of Quote
        List<SBQQ__Quote__c> quotes = new List<SBQQ__Quote__c>();
        
        //Add new quote record in list
        quotes.add(new SBQQ__Quote__c(SBQQ__Status__c = 'Draft', SBQQ__Type__c = 'Quote', SBQQ__Primary__c = true, SBQQ__Opportunity2__c = opportunities[0].Id));
        quotes.add(new SBQQ__Quote__c(SBQQ__Status__c = 'Draft', SBQQ__Type__c = 'Quote', SBQQ__Primary__c = true, SBQQ__Opportunity2__c = opportunities[1].Id));
        
        //ByPass triggers
        Util.byPassAllTriggers = true;
        
        //Insert
        insert quotes;
        
        
        //List to create contract records
        List<Contract> contracts = new List<Contract>();
        
        //Contracts
        contracts.add(new Contract(Name = 'contract1', AccountId = accounts[0].Id, SBQQ__Quote__c = quotes[0].Id, SBQQ__Opportunity__c = opportunities[0].Id, StartDate = System.today(), ContractTerm = 1));
        contracts.add(new Contract(Name = 'contract2', AccountId = accounts[0].Id, SBQQ__Quote__c = quotes[1].Id, SBQQ__Opportunity__c = opportunities[1].Id, StartDate = System.today(), ContractTerm = 2));
        
        //By Pass triggers
        Util.byPassAllTriggers = true;
        
        //Insert
        insert contracts;
        
        //Assert
        System.assert(contracts.size() > 0);
        
        //Create Integrated account record
        List<Integrated_Account__c> integratedAccounts = new List<Integrated_Account__c>();
        
        //Add new record in list
        integratedAccounts.add(new Integrated_Account__c(Opportunity__c = opportunities[0].Id, Integrated_Account__c = accounts[0].Id));
        integratedAccounts.add(new Integrated_Account__c(Opportunity__c = opportunities[0].Id, Integrated_Account__c = accounts[1].Id));
        
        //By Pass triggers
        Util.byPassAllTriggers = true;
        
        //Insert
        insert integratedAccounts;
        
        //Assert
        System.assert(integratedAccounts.size() > 0);
        
        //Opportunity List (Renewal Opps)
        List<Opportunity> renewalOpps = new List<Opportunity>();
        
        //Create Opportunity record 
        renewalOpps.add(new Opportunity(Name = 'Test 1', Opportunity_Nickname__c = 'Renewal Opp 1', StageName = 'Pipeline', Amount = 0, CloseDate = Date.today(),
                                        RecordTypeId = recordTypes[0].Id, Competitor_Notes__c = 'ABC 1', CT_Pass_Status__c = 'Assigned', 
                                        CT_Reneg_Attempt__c = 'No', AccountId = accounts[0].Id, SBQQ__Renewal__c = true, SBQQ__RenewedContract__c = contracts[0].Id));
         
        renewalOpps.add(new Opportunity(Name = 'Test 2', Opportunity_Nickname__c = 'Renewal Opp 2', StageName = 'Pipeline', Amount = 0, CloseDate = Date.today(), 
                                        RecordTypeId = recordTypes[0].Id, Competitor_Notes__c = 'ABC 2',CT_Pass_Status__c = 'Assigned',
                                        CT_Reneg_Attempt__c = 'No', AccountId = accounts[0].Id, SBQQ__Renewal__c = true, SBQQ__RenewedContract__c = contracts[1].Id));
        
        //Start testing from here 
        Test.startTest();  
        
        //Set flag to flase to execute triggers
        Util.byPassAllTriggers=false;
        
        //Insert
        insert renewalOpps;
        
        //Query through the integratedAccount
        List<Integrated_Account__c> inteAccounts = [Select Id From Integrated_Account__c Where Opportunity__c =: renewalOpps[0].Id];
        
        //Assert for result
        System.assertEquals(2, inteAccounts.size());
        
        //Query through the integratedAccount
        inteAccounts = [Select Id From Integrated_Account__c Where Opportunity__c =: renewalOpps[1].Id];
        
        //Assert for result
        System.assertEquals(0, inteAccounts.size());
        
        //Stop testing here 
        Test.stopTest();
    }
    
    //Added By - Subhash Garhwal - 7/21/2016 - CR-20160414-9762 
    static testMethod void testRollupProgramOpps() {
        
        //Set Flags
        Util.IsTest(true);
        Util.byPassAllTriggers=true;
        
        //List of Account
        List<Account> accounts = new List<Account>();
        
        //Add new account in list
        accounts.add(new Account(Name = 'Account 1'));
        accounts.add(new Account(Name = 'Account 2'));
        accounts.add(new Account(Name = 'Account 3'));
        
        //Insert
        insert accounts;
        
        //Assert
        System.assert(accounts.size() > 0);
        
        //Get Contract LOA record type
        List<RecordType> recordTypes = [Select Id, Name FROM RecordType WHERE SobjectType = 'Opportunity' AND DeveloperName IN: CPQConstants.SET_OPPORTUNITY_CPQ_RT_DEVELOPER_NAME ORDER BY DeveloperName ASC];
        
        //Opportunity List (Contract LOA)
        List<Opportunity> opportunities = new List<Opportunity>();
        
        //Create Opportunity record 
        opportunities.add(new Opportunity(Name = 'Test 1', Opportunity_Nickname__c = 'Contract LOA Opp 1', StageName = CPQConstants.OPPORTUNITY_STAGE_ON_DECK, Amount = 4.00, CloseDate = Date.today(),
                                        RecordTypeId = recordTypes[0].Id, Competitor_Notes__c = 'ABC 1', CT_Pass_Status__c = 'Assigned', 
                                        CT_Reneg_Attempt__c = 'No', AccountId = accounts[0].Id));
        
        opportunities.add(new Opportunity(Name = 'Test 2', Opportunity_Nickname__c = 'Contract LOA Opp 2', StageName = CPQConstants.OPPORTUNITY_STAGE_ON_DECK, Amount = 4.00, CloseDate = Date.today(), 
                                        RecordTypeId = recordTypes[0].Id, Competitor_Notes__c = 'ABC 2',CT_Pass_Status__c = 'Assigned',
                                        CT_Reneg_Attempt__c = 'No', AccountId = accounts[0].Id));
        
        //ByPass triggers
        Util.byPassAllTriggers=true;                                            
        
        //Insert 
        insert opportunities;
        
        //Assert
        System.assert(opportunities.size() > 0);
        
        //List of Programs
        List<Program__c> programs = new List<Program__c>();
        
        //Create a program and Insert
        Program__c prog = TestUtilities.CreateNewProgram(false);
        prog.Program_Abbreviation__c = 'Test Program';
        
        //Add Program into list
        programs.add(prog);
        
        //Create a program and Insert
        Program__c prog1 = TestUtilities.CreateNewProgram(false);
        prog1.Program_Abbreviation__c = 'Test Program 1';
        
        //Add Program into list
        programs.add(prog1);
        
        //ByPass triggers
        Util.byPassAllTriggers = true;
        
        //Insert
        insert programs;
        
        //Assert
        System.assert(programs.size() > 0);
        
        //List to hold the Program Opps
        List<Opportunity> programOpps = new List<Opportunity>();
        
        //Add Program Opps in list 
        programOpps.add(new Opportunity(Name = 'Test 1', StageName = CPQConstants.OPPORTUNITY_STAGE_ON_DECK, Amount = 4.00, CloseDate = Date.today(),
                                        RecordTypeId = recordTypes[1].Id, Competitor_Notes__c = 'Test 1', CT_Pass_Status__c = 'Assigned', 
                                        CT_Reneg_Attempt__c = 'No', Parent_Opportunity__c = opportunities[0].Id,  AccountId = accounts[0].Id,
                                        Program__c = programs[0].Id, Program_Proposal_Status__c = CPQConstants.PROGRAM_PROPOSAL_STATUS_PRIMARY_PROPOSAL));
        
        programOpps.add(new Opportunity(Name = 'Test 2', StageName = CPQConstants.OPPORTUNITY_STAGE_ON_DECK, Amount = 5.00,CloseDate = Date.today(), 
                                        RecordTypeId = recordTypes[2].Id, Competitor_Notes__c = 'Test 2',CT_Pass_Status__c = 'Assigned',
                                        CT_Reneg_Attempt__c = 'No', Parent_Opportunity__c = opportunities[0].Id,  AccountId = accounts[0].Id,
                                        Program__c = programs[1].Id));
        
        programOpps.add(new Opportunity(Name = 'Test 3', StageName = CPQConstants.OPPORTUNITY_STAGE_ON_DECK, Amount = 6.00, CloseDate = Date.today(),
                                        RecordTypeId = recordTypes[3].Id, Competitor_Notes__c = 'Test 3', CT_Pass_Status__c = 'Assigned', 
                                        CT_Reneg_Attempt__c = 'No', Parent_Opportunity__c = opportunities[1].Id,  AccountId = accounts[1].Id,
                                        Program__c = programs[1].Id));
        
        //Start testing from here 
        Test.startTest();  
        
        //Set flag to flase to execute triggers
        Util.byPassAllTriggers = false;
        
        //Insert
        insert programOpps;
        
        //Query through the Contract LOA opps to check the Program Opp counters
        List<Opportunity> contractLOAOpps = [Select Id, Total_Program_Opps__c,Primary_Program_Opps__c From Opportunity Where Id IN : opportunities ORDER BY Total_Program_Opps__c DESC];
        
        //Assert for result
        System.assertEquals(2, contractLOAOpps.size());
        System.assertEquals(1, contractLOAOpps[0].Total_Program_Opps__c);
        System.assertEquals(1, contractLOAOpps[0].Primary_Program_Opps__c);
        System.assertEquals(1, contractLOAOpps[1].Total_Program_Opps__c);
        System.assertEquals(0, contractLOAOpps[1].Primary_Program_Opps__c);
        
        //Update Program Opp
        programOpps[2].Program_Proposal_Status__c = CPQConstants.PROGRAM_PROPOSAL_STATUS_PRIMARY_PROPOSAL;
        
        //Update 
        update programOpps[2];
        
        //Query through the Contract LOA opps to check the Program Opp counters
        contractLOAOpps = [Select Id, Total_Program_Opps__c,Primary_Program_Opps__c From Opportunity Where Id IN : opportunities ORDER BY Total_Program_Opps__c DESC];
        
        //Assert for result
        System.assertEquals(2, contractLOAOpps.size());
        System.assertEquals(1, contractLOAOpps[0].Total_Program_Opps__c);
        System.assertEquals(1, contractLOAOpps[0].Primary_Program_Opps__c);
        System.assertEquals(1, contractLOAOpps[1].Total_Program_Opps__c);
        System.assertEquals(1, contractLOAOpps[1].Primary_Program_Opps__c);
        
        //Stop testing here 
        Test.stopTest();
    }
}