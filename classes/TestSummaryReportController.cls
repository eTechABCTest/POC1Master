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
@isTest
private class TestSummaryReportController {

    static testMethod void testSummary_Event_Opportunity() {
    
        //Setting flag to bypass all triggers so then test data can be created
        Util.IsTesting = true;
        Util.ByPassAllTriggers = true;

        // create a new program
        Program__c program = TestUtilities.CreateNewProgram(true);
        
        // create a new account
        Account acct = TestUtilities.CreateNewAccount(true);
        
        // new contact
        Contact con = TestUtilities.CreateNewContact(acct, true);
        
        // new membership
        Membership__c membership = TestUtilities.CreateNewMembership(acct.Id, program.Id, true);
        
        // new opportunity
        Opportunity opp = TestUtilities.CreateNewOpportunity(acct.Id, false);
        opp.Program__c = program.Id;
        insert opp;
        
        // create a couple of utilization records
        List<Other_Utilization__c> utilizationsToInsert = new List<Other_Utilization__c>();
        Other_Utilization__c otherUtilization1 = new Other_Utilization__c();
        otherUtilization1.Contact__c = con.Id;
        otherUtilization1.Institution__c = acct.Id;
        otherUtilization1.Start_Date__c = system.today().addDays(-1);
        otherUtilization1.End_Date__c = system.today();
        otherUtilization1.Utilization_Metric__c = 'Advisory.com Tools';
        utilizationsToInsert.add(otherUtilization1);
        Other_Utilization__c otherUtilization2 = new Other_Utilization__c();
        otherUtilization2.Contact__c = null;
        otherUtilization2.Institution__c = null;
        otherUtilization2.Start_Date__c = system.today().addDays(-1);
        otherUtilization2.End_Date__c = system.today();
        otherUtilization2.Utilization_Metric__c = 'Advisory.com Tools';
        utilizationsToInsert.add(otherUtilization2);
        
        insert utilizationsToInsert;
        
        List<Meeting_Utilization__c> utilizations = new List<Meeting_Utilization__c>();
        
        Meeting_Utilization__c meetingUtilization = new Meeting_Utilization__c();
        meetingUtilization.Contact__c = con.Id;
        meetingUtilization.Program__c = 'HE';
        meetingUtilization.Membership__c = membership.Id;
        meetingUtilization.Start_Date__c = system.today().addDays(-1);
        meetingUtilization.End_Date__c = system.today();
        utilizations.add(meetingUtilization);
        
        Meeting_Utilization__c meetingUtilization2 = new Meeting_Utilization__c();
        meetingUtilization2.Contact__c = con.Id;
        meetingUtilization2.Program__c = 'HE';
        meetingUtilization2.Membership__c = membership.Id;
        meetingUtilization2.Start_Date__c = system.today().addDays(+1);
        meetingUtilization2.End_Date__c = system.today();
        utilizations.add(meetingUtilization2);
        insert utilizations;
        
        // create a new event
        Event evt = TestUtilities.CreateNewEvent(false);
        evt.WhatId = opp.Id;
        evt.WhoId = con.Id;
        insert evt;
        
        // begin the test
        Test.startTest();
        
            // go to the summary report selection page
            test.setCurrentPage(Page.SummaryReportSelector);
            
            // set the event id
            ApexPages.currentPage().getParameters().put('Id',evt.id);
            
            // instantiate the controller
            SummaryReportController controller = new SummaryReportController();
            
            // check the 'Pricing history box'
            controller.ShowPricingHistory = true;
            controller.ShowOpportunities = true;
            controller.ShowRenewalNotes = true;
            controller.ShowUtilizationSnapshot = true;
            
            // generate the PDF
            PageReference pgRef = controller.GeneratePDF();
            
        // end test
        Test.stopTest();
        
        // make sure the page redirects properly
        system.assertEquals(false, pgRef.getUrl().contains('SummaryReport'));
        
        // ensure the account/opportunity/event is correct
        system.assertEquals(acct.Id, controller.mainAccount.Id);
        system.assertEquals(opp.Id, controller.mainOpportunity.Id);
        system.assertEquals(evt.Id, controller.mainEvent.Id);
        system.assertEquals(con.Id, controller.mainContact.Id);
        system.assertEquals(1, controller.DAGToolUtilizations.size());
    }
    
    static testMethod void testSummary_Event_Membership() {
        
        //Setting flag to bypass all triggers so then test data can be created
        Util.IsTesting = true;
        Util.ByPassAllTriggers = true;
        
        // create a new program
        Program__c program = TestUtilities.CreateNewProgram(false);
        program.Account_Management_Reporting_Vertical__c = 'BI';
        insert program;
        
        // create a new account
        Account acct = TestUtilities.CreateNewAccount(true);
        
        Account childAcct = TestUtilities.CreateNewAccount(false);
        childAcct.ParentId = acct.Id;
        insert childAcct;
        
        Account grandChildAcct = TestUtilities.CreateNewAccount(false);
        grandChildAcct.ParentId = childAcct.Id;
        insert grandChildAcct;
        
        // new contact
        Contact con = TestUtilities.CreateNewContact(acct, true);
        
        // new membership
        Membership__c membership = TestUtilities.CreateNewMembership(acct.Id, program.Id, true);
        
        // new opportunity
        Opportunity opp = TestUtilities.CreateNewOpportunity(acct.Id, false);
        opp.Program__c = program.Id;
        opp.Pool_Year__c = '2012';
        opp.StageName = 'Closed Won';
        insert opp;
        
        // create a new event
        Event evt = TestUtilities.CreateNewEvent(false);
        evt.WhatId = membership.Id;
        evt.WhoId = con.Id;
        insert evt;
        
        // create a couple of utilization records
        Other_Utilization__c otherUtilization = new Other_Utilization__c();
        otherUtilization.Contact__c = con.Id;
        otherUtilization.Institution__c = acct.Id;
        otherUtilization.Start_Date__c = system.today().addDays(-1);
        otherUtilization.End_Date__c = system.today();
        insert otherUtilization;
        
        List<Meeting_Utilization__c> meetingUtilizations = new List<Meeting_Utilization__c>();
        
        // begin the test
        Test.startTest();
        
        Meeting_Utilization__c meetingUtilization = new Meeting_Utilization__c();
        meetingUtilization.Contact__c = con.Id;
        meetingUtilization.Program__c = 'HE';
        meetingUtilization.Institution__c = acct.Id;
        meetingUtilization.Membership__c = membership.Id;
        meetingUtilization.Start_Date__c = system.today().addDays(-1);
        meetingUtilization.End_Date__c = system.today();
        meetingUtilizations.add(meetingUtilization);
        
        Meeting_Utilization__c meetingUtilization2 = new Meeting_Utilization__c();
        meetingUtilization2.Contact__c = con.Id;
        meetingUtilization2.Program__c = 'HE';
        meetingUtilization2.Institution__c = acct.Id;
        meetingUtilization2.Membership__c = membership.Id;
        meetingUtilization2.Start_Date__c = system.today().addDays(+1);
        meetingUtilization2.End_Date__c = system.today();
        meetingUtilizations.add(meetingUtilization2);
        insert meetingUtilizations;
        
        Utilization_Data_Object__c teleconfUtilizations = new Utilization_Data_Object__c(); 
        teleconfUtilizations.Start_Date__c = system.today().addDays(-1);
        teleconfUtilizations.End_date__c = system.today();
        insert teleconfUtilizations;
        
            
        // fasttrack opp
        Opportunity fastTrackOpp = TestUtilities.CreateNewOpportunity(acct.Id, false);
        fastTrackOpp.Program__c = program.Id;
        fastTrackOpp.Pool_Year__c = '2012';
        fastTrackOpp.StageName = 'Active in Fast Track';
        insert fastTrackOpp;
            
            // go to the summary report selection page
            test.setCurrentPage(Page.SummaryReportSelector);
            
            // set the event id
            ApexPages.currentPage().getParameters().put('Id',evt.id);
            
            // instantiate the controller
            SummaryReportController controller = new SummaryReportController();
            
            // check the 'Pricing history box'
            controller.ShowPricingHistory = true;
            controller.ShowOpportunities = true;
            controller.ShowRenewalNotes = true;
            controller.ShowUtilizationSnapshot = true;
            
            // generate the PDF
            PageReference pgRef = controller.GeneratePDF();
            
        // make sure the page redirects properly
        system.assertEquals(false, pgRef.getUrl().contains('SummaryReport'));
        
        // ensure the account/opportunity/event is correct
        system.assertEquals(acct.Id, controller.mainAccount.Id);
        system.assertEquals(evt.Id, controller.mainEvent.Id);
        
        String s = controller.TimeStr;
        s = controller.StartTimeStr;
        s = controller.EndTimeStr;
        List<Event> acctMgmt = controller.AcctMgmtVisits;
        List<Opportunity> opps = controller.WonOpportunities;
        List<Utilization_Data_Object__c> objs = controller.TeleconferenceUtilizations;
        List<meeting_utilization__c> meetingUts = controller.MembershipUtilizations;
        List<Other_Utilization__c> otUt = controller.OtherUtilizations;
        List<Other_Utilization__c> pubReorders = controller.PubReorderUtilizations;
        List<Other_Utilization__c> onsites = controller.OnsiteUtilizations;
        List<Other_Utilization__c> dagTools = controller.DAGToolUtilizations;
        List<Other_Utilization__c> expertCenters = controller.ExpertCenterUtilizations;
        List<Membership__c> pastMemberships = controller.PastMemberships;
        List<Membership__c> currentMemberships = controller.CurrentMemberships;
        Account parent = controller.ParentAccount;
        List<Account> child = controller.ChildAccounts;
            
        // end test
        Test.stopTest();
                
    }
    
    static testMethod void testSummary_Event_Marketing() {
    
        //Setting flag to bypass all triggers so then test data can be created
        Util.IsTesting = true;
        Util.ByPassAllTriggers = true;
        
        // create a new program
        Program__c program = TestUtilities.CreateNewProgram(true);
        
        // create a new account
        Account acct = TestUtilities.CreateNewAccount(true);
        
        // new contact
        Contact con = TestUtilities.CreateNewContact(acct, true);
        
        // Create a restriction record
        Restrictions__c restriction = new Restrictions__c();
        insert restriction;
        ApexPages.standardController standardController = new ApexPages.standardController(restriction);
        
        // create a restriction mtm record to link to this restriction
        Restricted_MtM__c restrictionMTM = new Restricted_MtM__c();
        restrictionMTM.Account__c = acct.Id;
        restrictionMTM.Restriction__c = restriction.Id;
        insert restrictionMTM;
        
        // new membership
        Membership__c membership = TestUtilities.CreateNewMembership(acct.Id, program.Id, true);
        
        // new opportunity
        Opportunity opp = TestUtilities.CreateNewOpportunity(acct.Id, false);
        opp.Program__c = program.Id;
        insert opp;
        
        // create a couple of utilization records
        Other_Utilization__c otherUtilization = new Other_Utilization__c();
        otherUtilization.Contact__c = con.Id;
        otherUtilization.Institution__c = acct.Id;
        otherUtilization.Start_Date__c = system.today().addDays(-1);
        otherUtilization.End_Date__c = system.today();
        insert otherUtilization;
        
        List<Meeting_Utilization__c> utilizations = new List<Meeting_Utilization__c>();
        
        Meeting_Utilization__c meetingUtilization = new Meeting_Utilization__c();
        meetingUtilization.Contact__c = con.Id;
        meetingUtilization.Program__c = 'HE';
        meetingUtilization.Membership__c = membership.Id;
        meetingUtilization.Start_Date__c = system.today().addDays(-1);
        meetingUtilization.End_Date__c = system.today();
        utilizations.add(meetingUtilization);
        
        Meeting_Utilization__c meetingUtilization2 = new Meeting_Utilization__c();
        meetingUtilization2.Contact__c = con.Id;
        meetingUtilization2.Program__c = 'HE';
        meetingUtilization2.Membership__c = membership.Id;
        meetingUtilization2.Start_Date__c = system.today().addDays(+1);
        meetingUtilization2.End_Date__c = system.today();
        utilizations.add(meetingUtilization2);
        insert utilizations;
        
        // create a new event where record type = PT Marketing
        Event evt = TestUtilities.CreateNewEvent(false);
        Id ptMarketingRT = Util.RecordTypeId('Event', 'PT Marketing');
        evt.WhatId = opp.Id;
        evt.WhoId = con.Id;
        evt.RecordTypeId = ptMarketingRT;
        insert evt;
        
        // begin the test
        Test.startTest();
        
            // go to the summary report selection page
            test.setCurrentPage(Page.SummaryReportSelector);
            
            // set the event id
            ApexPages.currentPage().getParameters().put('Id',evt.id);
            
            // instantiate the controller
            SummaryReportController controller = new SummaryReportController();
            
            // check the 'Pricing history box'
            controller.ShowRestrictions = true;
            controller.ShowMap = true;
            controller.ShowWarmLeads = true;
            controller.ShowMarketingOpps = true;
            controller.ShowAcctMgmtPhoneCalls = true;
            
            // generate the PDF
            PageReference pgRef = controller.GeneratePDF();
            
        // end test
        Test.stopTest();
        
        // make sure the page redirects properly
        system.assertEquals(false, pgRef.getUrl().contains('SummaryReport'));
        
        // ensure the account/opportunity/event is correct
        system.assertEquals(acct.Id, controller.mainAccount.Id);
        system.assertEquals(opp.Id, controller.mainOpportunity.Id);
        system.assertEquals(evt.Id, controller.mainEvent.Id);
        system.assertEquals(con.Id, controller.mainContact.Id);
        system.assertEquals(1, controller.MainAccount.Restrictions_MtM__r.size());
    }
    
    static testMethod void testSummary_OtherUtilizations() {
        
        //Setting flag to bypass all triggers so then test data can be created
        Util.IsTesting = true;
        Util.ByPassAllTriggers = true;

        // create a new program
        Program__c program = TestUtilities.CreateNewProgram(true);
        
        // create a new account
        Account acct = TestUtilities.CreateNewAccount(true);
        
        // new contact
        Contact con = TestUtilities.CreateNewContact(acct, true);
        
        // Create a restriction record
        Restrictions__c restriction = new Restrictions__c();
        insert restriction;
        ApexPages.standardController standardController = new ApexPages.standardController(restriction);
        
        // create a restriction mtm record to link to this restriction
        Restricted_MtM__c restrictionMTM = new Restricted_MtM__c();
        restrictionMTM.Account__c = acct.Id;
        restrictionMTM.Restriction__c = restriction.Id;
        insert restrictionMTM;
        
        // new membership
        Membership__c membership = TestUtilities.CreateNewMembership(acct.Id, program.Id, true);
        
        // new opportunity
        Opportunity opp = TestUtilities.CreateNewOpportunity(acct.Id, false);
        opp.Program__c = program.Id;
        insert opp;
        
        // create a couple of utilization records
        List<Other_Utilization__c> utilizationsToInsert = new List<Other_Utilization__c>();
        Other_Utilization__c otherUtilization1 = new Other_Utilization__c();
        otherUtilization1.Contact__c = con.Id;
        otherUtilization1.Institution__c = acct.Id;
        otherUtilization1.Start_Date__c = system.today().addDays(-2);
        otherUtilization1.End_Date__c = system.today();
        otherUtilization1.Utilization_Metric__c = 'Advisory.com Tools';
        utilizationsToInsert.add(otherUtilization1);
        
        Other_Utilization__c otherUtilization2 = new Other_Utilization__c();
        otherUtilization2.Contact__c = null;
        otherUtilization2.Institution__c = null;
        otherUtilization2.Start_Date__c = system.today().addDays(-2);
        otherUtilization2.End_Date__c = system.today();
        otherUtilization2.Utilization_Metric__c = 'Advisory.com Tools';
        utilizationsToInsert.add(otherUtilization2);
        
        insert utilizationsToInsert;
        
        // create a new event where record type = PT Marketing
        Event evt = TestUtilities.CreateNewEvent(false);
        evt.WhatId = opp.Id;
        evt.WhoId = null;
        insert evt;
        
        // begin the test
        Test.startTest();
        
            // go to the summary report selection page
            test.setCurrentPage(Page.SummaryReportSelector);
            
            // set the event id
            ApexPages.currentPage().getParameters().put('Id',evt.id);
            
            // instantiate the controller
            SummaryReportController controller = new SummaryReportController();
            
            // check the 'Pricing history box'
            controller.ShowRestrictions = true;
            controller.ShowMap = true;
            controller.ShowWarmLeads = true;
            controller.ShowMarketingOpps = true;
            controller.ShowAcctMgmtPhoneCalls = true;
            
            // generate the PDF
            PageReference pgRef = controller.GeneratePDF();
            
        // end test
        Test.stopTest();
        
        // make sure the page redirects properly
        system.assertEquals(false, pgRef.getUrl().contains('SummaryReport'));
        
        // ensure the account/opportunity/event is correct
        system.assertEquals(acct.Id, controller.mainAccount.Id);
        system.assertEquals(opp.Id, controller.mainOpportunity.Id);
        system.assertEquals(evt.Id, controller.mainEvent.Id);
        system.assertEquals(null, controller.mainContact.Id);
        system.assertEquals(1, controller.DAGToolUtilizations.size());
    }
    
}