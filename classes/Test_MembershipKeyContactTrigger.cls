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
private class Test_MembershipKeyContactTrigger {
/*
    Purpose         :   Test class for Trigger_MembershipKeyContact
                
    Create By       :   Simplyforce Technology
    
    Created Date    :   12/16/2012
    
    Current Version :   V1.0
    
    Revision Log    :   V1.0 - Created
                        v1.1 - (SUNJ 12/19/13) - CR-20130118-2218

    Coverage        :   Trigger_MembershipKeyContact - 100%
                        MembershipKeyContactTriggerHelper - 100%
*/
    static User usr = [select id from User where isActive = true AND UserType = 'Standard' limit 1];
    
    static testMethod void myUnitTest() {
        //Bypass Dupeblocker
        Util.IsTest(true);
        Util.IsTesting = true;
        
        // setup the custom setting
        Util.resetRecordtypeSettings();
        
        system.debug('### Test Case 1 ###');
        
        Account acc = new Account(Name = 'Test Case Account 1', RecordTypeId = Util.recordtypemap('Account').get('US Corporate'), Academy_Programs_Available_for_Outreach__c = '', BI_Programs_Available_for_Outreach__c = '', Core_Programs_Available_for_Outreach__c = '');
        insert acc;
        
        Program__c testProg1 = new Program__c(Name='Test Trigger Program', New_Business_Marketer__c = 'RI Marketer', Program_Acronym__c='ZZZ', Create_memberships__c='No', Business_line__c = 'PT');
        insert testProg1;
        
        Program__c testProg2 = new Program__c(Name='Test Trigger Program', New_Business_Marketer__c = 'RI Marketer', Program_Acronym__c='Test Update', Create_memberships__c='No', Business_line__c = 'PT');
        insert testProg2;
        
        AccountTeamMember accMember = new AccountTeamMember(
            UserId = usr.Id,
            AccountId = acc.Id,
            TeamMemberRole = testProg1.New_Business_Marketer__c);
            //AccountAccessLevel = 'Read');
        insert accMember;
        
        Opportunity testOpp = new Opportunity(Name='Test Opp', StageName = 'Prospect', Amount=1, CloseDate = System.today(), AccountId = acc.Id);
        insert testOpp;
        
        Contract__c testContract1 = new Contract__c(
            Name='Test Contract1', Payer_Account__c = acc.Id, Program__c = testProg1.Id, 
            Start__c = System.Today().addDays(-10), End__c = system.today().addDays(355),
            Contract_Renewal_Opportunity__c = testOpp.Id
            );
            
        insert testContract1;
        
        List<Membership__c> memberships = new List<Membership__c>();
        
        //Test.startTest
        Test.startTest();
        
        Membership__c member1 = new Membership__c(
            Name = 'Test Membership',
            Account_Name__c = acc.Id,
            Program__c = testProg1.Id,
            Active_Contract_Idenfied__c = testContract1.Id);
        
        memberships.add(member1);
        
        Membership__c member2 = new Membership__c(
            Name = 'Test Membership',
            Account_Name__c = acc.Id,
            OwnerId = usr.Id,
            Assigned_Marketer__c = usr.Id, 
            Program__c = testProg1.Id,
            Active_Contract_Idenfied__c = testContract1.Id
        );
        
        memberships.add(member2);
        
        Membership__c member3 = new Membership__c(
            Name = 'Test Membership',
            Account_Name__c = acc.Id,
            Program__c = testProg1.Id,
            OwnerId = usr.Id,
            Assigned_Marketer__c = usr.Id);
        
        Util.IsBatch = false;
        Util.IsTrigger_ContractFieldUpdate = false;
        Util.IsTrigger_Opportunity_ValidationAndFieldUpdates = false;
        Util.IsTrigger_EventPrewire = false;
        Util.IsTrigger_EventUpdateFields = false;
        Util.IsTrigger_ContractIntegratedAcctRunning = false;
        
        insert memberships;
        insert member3;
        
        Site_Profile__c sProfile = Test_SiteUserHelper.CreateSiteProfile(SiteUserHelper.SITE_ADVISORY, true);
        
        Contact con = [SELECT Id, Name, Email FROM Contact WHERE Id = :sProfile.Contact__c];
        
        //Test Case for - CR-20121019-1641
        update member2;
        
        //Insert membership key contact record
        Membership_Key_Contact__c testMembershipKeyContact = new Membership_Key_Contact__c(
            Contact__c = con.id,
            Name='Test 1', 
            Role_Type__c = 'PT', 
            Role__c = 'Exec Sponsor', 
            Membership__c = member2.Id,
            Pubs__c = true,
            Meetings__c = true);
        insert testMembershipKeyContact;
        
        member2 = [select id, Membership_Status__c, OwnerId, Assigned_Marketer__c, Active_Contract_Idenfied__c, Latest_Contract__c, Earliest_Contract__c from Membership__c where Id = :member2.Id];
        system.debug('\n\nm2.Membership_Status__c ' + member2.Membership_Status__c);
        
        //Assert for the result
        con = [Select Id, Membership_Contact_Pubs__c, Membership_Contact_Meetings__c from Contact where Id =: con.Id];
        System.assertEquals(testProg1.Program_Acronym__c, con.Membership_Contact_Pubs__c);
        System.assertEquals(testProg1.Program_Acronym__c, con.Membership_Contact_Meetings__c);
        
        //Stop test here    
        Test.stopTest();
    }
}