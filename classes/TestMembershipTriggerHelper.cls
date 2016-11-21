@isTest(seeAllData = false)
private class TestMembershipTriggerHelper 
{
/**
 *  Purpose     :   Test class for NBBTriggerHelper.
 *               
 *  Create By   :   Bhavi
 *   
 *  Created Date:   11/16/2013
 *   
 *  Revision Log:   V1.1 - Created
 *                  V1.2 - Modified By - Mahendra Swarnakar - 09/15/2016 - CR-20160519-9865
 *                
 *  Coverage    :   V1.1 - 76%
 *                  V1.2 - 80%
 **/
        
    // Added on 8/6/2012 per CR-20120730-1221 
    /* Purpose: to verify that the process_membership is updating the Active_SW_Memberships__c field
     * on the membership records associated with a given account when the business_line_c field
     * of an associated program is 'SW' */
     
    static testMethod void testProcessAccount() {
        
        //Bypassing dupeblocker
        Util.IsTest(true);
        
        //Bypassing Triggers so then test data can be created easily
        Util.byPassAllTriggers = true;
            
        Contact testContact = TestUtilities.CreateNewContact(true);
        
        Program__c swProgram = new Program__c(
            Program_Acronym__c = 'TEST',
            Program_Formal_Name__c = 'Test Program Formal',
            Name = 'Test Program',
            Create_Memberships__c = 'No',
            Renewal_Unit_Count__c = 1,
            Business_Line__c = 'SW');         
        insert swProgram;
        System.assertNotEquals(null,swProgram.id);
        
        Account testAcct = TestUtilities.CreateNewAccount(false); 
        testAcct.Active_SW_Memberships__c = '';
        insert testAcct;
        
        //update testAcct;
        System.assertNotEquals(null,testAcct.id);
        
        Contract__c testContract = new Contract__c(
            Name='TestContract', Status__c = 'PAYER', Start__c = system.today().addDays(-1), End__c = system.today().addDays(2),
            Negotiated_Amount__c = 1,
            Type__c = 'NBB',
            Year__c = '2010',
            Join_Date__c = system.today().addDays(-5),
            Payer_Account__c = testAcct.Id,
            Main_Contact__c = testContact.Id,
            Invoice_Contact__c = testContact.Id,
            Program__c = swProgram.Id);
        insert testContract;
        System.assertNotEquals(null,testContract.id);
        
        Membership__c testMembership = TestUtilities.CreateNewMembership(testAcct.Id,swProgram.Id,true);
        testMembership.Active_Contract_Idenfied__c = testContract.Id;
        
        //Start test from here
        Test.startTest();
        
        //Enabling triggers again
        Util.byPassAllTriggers = false;
        
        //update record
        update testMembership;
        
        System.assertNotEquals(null,testMembership.id);
        System.assertNotEquals(null,testAcct.Memberships__r);
        
        testAcct = [select id, Active_SW_Memberships__c, Paid_SW_Memberships__c, (select id, Membership_Status__c, Program__r.Business_Line__c, Prospect_Status__c, Renewal_Unit_Count__c, Program__r.Program_Acronym__c from Memberships__r)from Account where id=:testAcct.id];
        System.assertNotEquals(0,testAcct.Memberships__r.size());
        
        if(testAcct != null) {
        
            List<Membership__c> memberships = testAcct.Memberships__r;
            Account processedTestAccount = MembershipTriggerHelper.process_membership(testAcct, memberships);
            System.debug('***** processedTestAccount: ' + processedTestAccount);
            System.debug('***** processedTestAccount.Active_SW_Memberships__c: ' + processedTestAccount.Active_SW_Memberships__c);
            System.assertEquals(testAcct.Id,processedTestAccount.Id);
        
            //Assert for the Paid_SW_Memberships__c
            System.assertEquals(swProgram.Program_Acronym__c, testAcct.Paid_SW_Memberships__c.trim());
        
            testMembership.Active_Contract_Idenfied__c = testContract.Id;
        
            //update record
            update testMembership;
            
            testAcct = [select id, Active_SW_Memberships__c, Paid_SW_Memberships__c, (select id, Membership_Status__c, Program__r.Business_Line__c, Prospect_Status__c, Renewal_Unit_Count__c, Program__r.Program_Acronym__c from Memberships__r)from Account where id=:testAcct.id];
        }
        
        //Test will stop here
        Test.stopTest();
    }
    
    //Added By - Ajit Surana - CR-20150312-8758 - 03/30/2015
    static testMethod void testpopulateIndustryMemberOnAccount() {
    
        //Bypassing dupeblocker
        Util.IsTest(true);

        //Bypassing Triggers so then test data can be created easily
        Util.byPassAllTriggers = true;

        //List to hold Account records
        List<Account> accList = new List<Account>();
        
        accList.add(new Account(Name = 'Test Account1'));
        accList.add(new Account(Name = 'Test Account2'));
        
        //Insert record
        insert accList;
        
        //Insert Program data
        List<Program__c> progList = new List<Program__c>();
        
        progList.add(new Program__c(Program_Acronym__c = 'TEST', Program_Formal_Name__c = 'Test Program Formal', 
                                    Business_line__c = 'RI', Name = 'Test Program', Create_Memberships__c = 'No', 
                                    Industry_Member_for_Meetings__c = true, 
                                    New_Business_Marketer__c = 'RI Marketer'));         
        
        progList.add(new Program__c(Program_Acronym__c = 'TEST', Program_Formal_Name__c = 'Test Program Formal', 
                                    Business_line__c = 'RI', Name = 'Test Program', Create_Memberships__c = 'No', 
                                    Industry_Member_for_Meetings__c = false, New_Business_Marketer__c = 'RI Marketer'));
        insert progList;
        
        //Opportunity
        Opportunity opportunity = new Opportunity(Name = 'Test Opp', StageName = Constants.CONTRACT_RECEIVED, 
                                                  Amount = 1, CloseDate = System.today(), AccountId = accList[0].ID);
        insert opportunity;
        
        //Contract
        Contract__c contract = new Contract__c(Name='Test1', Payer_Account__c = accList[0].ID, Program__c = progList[0].Id, 
                                               Start__c = System.Today().addDays(-10), End__c = System.Today().addDays(355), 
                                               Contract_Renewal_Opportunity__c = opportunity.Id);
        insert contract;
        
        //Update contract record
        contract.Start__c = Date.today() - 7;
        contract.End__c = Date.today() - 7;
        contract.Status__c = Constants.CLOSED;
        update contract;
           
        //List to hold Membership data
        List<Membership__c> membershipList = new List<Membership__c>();
        
        membershipList.add(new Membership__c(Name = 'Membership Test1', Account_Name__c = accList[0].Id, 
                                             Program__c = progList[0].Id, Active_Contract_Idenfied__c = contract.Id,
                                             Earliest_Contract__c = contract.Id,
                                             Latest_Contract__c = contract.Id, Membership_Status_Text__c = 'Member - Pure'));
        membershipList.add(new Membership__c(Name = 'Membership Test2', Account_Name__c = accList[1].Id, 
                                             Program__c = progList[1].Id, Active_Contract_Idenfied__c = contract.Id,
                                             Earliest_Contract__c = contract.Id,
                                             Latest_Contract__c = contract.Id, Membership_Status_Text__c = 'Member - Pure'));
        
        //Start test from here
        Test.startTest();

        //Enabling triggers again
        Util.byPassAllTriggers = false;

        //insert record
        insert membershipList;
        
        membershipList = [Select Id, Industry_Member__c, Active_Core_Membership__c, Membership_Status__c, 
                            Program__r.Business_line__c
                            FROM Membership__c Where Program__c != null];
        
        //Query to fetch Account record data
        accList = [Select Id, Name, Industry_Member__c FROM Account ORDER BY Name ASC];
        
        //Assert for results
        System.assertEquals(true,accList[0].Industry_Member__c);
        System.assertEquals(false,accList[1].Industry_Member__c);
        
        //Update the Membership record data
        membershipList[0].Account_Name__c =  accList[1].Id;
        membershipList[1].Account_Name__c =  accList[0].Id;

        //update record
        update membershipList;
        
        //Query to fetch Account record data
        accList = [Select Id, Name, Industry_Member__c FROM Account ORDER BY Name ASC];
        
        //Assert for results
        System.assertEquals(false,accList[0].Industry_Member__c);
        System.assertEquals(true,accList[1].Industry_Member__c);
        
        //delete record
        delete membershipList[0];
        
        //Query to fetch Account record data
        accList = [Select Id, Name, Industry_Member__c FROM Account ORDER BY Name ASC];
        
        //Assert for results
        System.assertEquals(false,accList[0].Industry_Member__c);
    
        //Test will stop here
        Test.stopTest();
    }   
    
   //Modified by Mahendra Swarnkar - 8/26/2016 - CR-20160606-9903
   // Modified by Mahendra Swarnkar - 8/26/2016 - CR-20160725-10063
   //Added by Mahendra Swarnakar -  5/16/2016 CR-20160219-9619
   // Test method to validate population of "Most Recent QA Call Date" field value on membership records
    static testMethod void testPopulateMostRecentQACallDate() {
        
        //Setting flags for test 
        Util.IsTest(true);
        Util.IsTesting = true;
        Util.BypassAllTriggers = true;
        
        //Insert Account
        Account acc = new Account(Name = 'testacct');
        insert acc;
        
        //Insert Account
        Program__c prog = new Program__c(Name = 'testprog', Program_Acronym__c = 'test');
        insert prog;
        
        //Insert Membership
        Membership__c mem = new Membership__c(Account_Name__c = acc.id, Program__c = prog.id);
        insert mem;
        
        //List to hold the event list
        List<Event> evntList = new List<Event>();
        
        //Date/DateTime Instances
        DateTime DTStart = System.now().addDays(Integer.valueOf(System.Label.POPULATE_MOST_RECENT_QA_CALL_ADD_DAYS)-2);
        Date DStart = DTStart.date();
        
        //Populating event list
        for(integer i=1; i<=6; i++)
        {
            Event tsk = new Event(
                whatId = mem.Id,
                StartDateTime = DTStart.addDays(-i),
                ActivityDateTime = DTStart.addDays(-i),
                ActivityDate = DStart.addDays(-i),
                EndDateTime = DTStart.addDays(-i),
                Event_Type__c = 'CM QA Call');
                
            if(i==1)
            {
                tsk.Event_Type__c = 'PT QA Call';
                tsk.Would_Refer__c = '5'; 
                tsk.Would_Buy_Again__c = '6'; 
                tsk.Grade__c = 'C';
                tsk.StartDateTime = DTStart;
                tsk.EndDateTime = DTStart;
                tsk.ActivityDateTime = DTStart;
                tsk.ActivityDate = DStart;
                tsk.Project_Sponsor_On_Call__c = 'Yes';
                
            }
            else if(i==2)
            {
                tsk.Event_Type__c = 'PT QA Call';
                tsk.Would_Refer__c = '8'; // should come over to Membership.Most_Recent_QA_Call_Recommended_Grade__c
                tsk.Would_Buy_Again__c = '9'; // should come over to Most_Recent_QA_Call_Renew_Grade__c
                tsk.Grade__c = 'B';
                tsk.StartDateTime = DTStart;
                tsk.ActivityDateTime = DTStart;
                tsk.ActivityDate = DStart;
                tsk.Project_Sponsor_On_Call__c = 'Yes';
                tsk.EndDateTime = DTStart.addDays(1);
            }
            else if(i==3){
                tsk.Event_Type__c = 'RI QA Call';
                tsk.Executive_Type__c = 'N/A';
                tsk.Grade__c = 'c';
                tsk.Would_Refer__c = '8'; 
                tsk.Would_Buy_Again__c = '9';
                tsk.StartDateTime = DTStart;
                tsk.ActivityDateTime = DTStart;
                tsk.ActivityDate = DStart;
                tsk.Project_Sponsor_On_Call__c = 'Yes';
                tsk.EndDateTime = DTStart.addDays(1);
            }
            else
            {
                tsk.Grade__c = 'A';
            }
            evntList.add(tsk);
        }
        
        //Bypass all the triggers
        Util.BypassAllTriggers = true;
        
        //Insert events
        insert evntList;
        
        //Setting flag values and enabling triggers
        Util.byPassAllTriggers = false;
        
        //Set to hold the Membership Ids
        Set<Id> setMemIds = new Set<Id>();
        setMemIds.add(mem.Id);
        
        //Start testing from here
        Test.startTest();
        
        //Setting flag values and enabling triggers
        Util.byPassAllTriggers = false;
        
        //Memthod call to update membership record with most recent QA call date, Grads etc 
        if(setMemIds.size() > 0)
            MembershipTriggerHelper.PopulateMostRecentQACall(setMemIds);
        
        //Start testing from here
        Test.stopTest();
        
        //Fatching Membership record
        List<Membership__c> listMembership = [select Id, Most_Recent_QA_Call_Grade__c, Most_Recent_QA_Call_Renew_Grade__c, Most_Recent_QA_Call_Recommend_Grade__c from Membership__c where Id IN : setMemIds];
        
        //Asserts on result
        System.assertEquals(1, listMembership.size());
        System.assertEquals('B', listMembership[0].Most_Recent_QA_Call_Grade__c);
        System.assertEquals('8', listMembership[0].Most_Recent_QA_Call_Recommend_Grade__c);
        System.assertEquals('9', listMembership[0].Most_Recent_QA_Call_Renew_Grade__c);
    }
    
    //Added By - Mahendra Swarnakar - 09/15/2016 - CR-20160519-9865
    static testMethod void testmembershipPopulateAssignedMarketer() {
        
        //Setting flags for test 
        Util.IsTest(true);
        Util.IsTesting = true;
        Util.BypassAllTriggers = true;
        
        //Get System Admin profile list
        List<Profile> profile = [select Id, Name From Profile Where Name = 'System Administrator'];
        
        //Test User Create
        List<User> users = new List<User>();
        users.add(new User(Username= Math.random()+'@abc.com', LastName='TESTER1', FirstName='Test1', Email=Math.random()+'@test.com',
                            Alias='Test1', EmailEncodingKey='UTF-8', languagelocalekey='en_US', ProfileId=profile[0].Id, 
                            timezonesidkey='America/Los_Angeles', localesidkey='en_US', EmployeeNumber = '12121212', IsActive = true));
        users.add(new User(Username= Math.random()+'@abc.com', LastName='TESTER2', FirstName='Test1', Email=Math.random()+'@test.com',
                            Alias='Test2', EmailEncodingKey='UTF-8', languagelocalekey='en_US', ProfileId=profile[0].Id, 
                            timezonesidkey='America/Los_Angeles', localesidkey='en_US', EmployeeNumber = '12121212', IsActive = true));
        
        //insert users
        insert users;
        
        //List to hold Account records
        List<Account> accList = new List<Account>();
        
        accList.add(new Account(Name = 'Test Account1', Academy_Programs_Available_for_Outreach__c= 'Academy1'));
        accList.add(new Account(Name = 'Test Account2', BI_Programs_Available_for_Outreach__c = 'BIProgram1'));
        
        //Insert record
        insert accList;
        
        //Insert Program data
        List<Program__c> progList = new List<Program__c>();
        
        progList.add(new Program__c(Program_Acronym__c = 'TEST', Program_Formal_Name__c = 'Test Program Formal', 
                                    Business_line__c = 'RI', Name = 'Test Program', Create_Memberships__c = 'No', 
                                    Industry_Member_for_Meetings__c = true, 
                                    New_Business_Marketer__c = 'RI Marketer'));         
        
        progList.add(new Program__c(Program_Acronym__c = 'TEST', Program_Formal_Name__c = 'Test Program Formal', 
                                    Business_line__c = 'RI', Name = 'Test Program', Create_Memberships__c = 'No', 
                                    Industry_Member_for_Meetings__c = false, New_Business_Marketer__c = 'RI Marketer'));
        insert progList;
        
        //Opportunity
        Opportunity opportunity = new Opportunity(Name = 'Test Opp', StageName = Constants.CONTRACT_RECEIVED, 
                                                  Amount = 1, CloseDate = System.today(), AccountId = accList[0].ID);
        insert opportunity;
        
        //Contract
        Contract__c contract = new Contract__c(Name='Test1', Payer_Account__c = accList[0].ID, Program__c = progList[0].Id, 
                                               Start__c = System.Today().addDays(-10), End__c = System.Today().addDays(355), 
                                               Contract_Renewal_Opportunity__c = opportunity.Id);
        insert contract;
        
        //Update contract record
        contract.Start__c = Date.today() - 7;
        contract.End__c = Date.today() - 7;
        contract.Status__c = Constants.CLOSED;
        update contract;
        
        //List to hold Account Team Member to be insert 
        List<AccountTeamMember> accountTeamMembers = new List<AccountTeamMember>();
        
        //List to hold Account Team Member to be insert 
        accountTeamMembers.add(new AccountTeamMember(UserId = users[0].Id, AccountId = accList[0].Id, TeamMemberRole = 'Research & Insights - RM'));
        accountTeamMembers.add(new AccountTeamMember(UserId = users[0].Id, AccountId = accList[0].Id, TeamMemberRole = 'AE or EA'));
        
        //insert Account Team Members
        insert accountTeamMembers;
           
        //List to hold Membership data
        List<Membership__c> membershipList = new List<Membership__c>();
        
        membershipList.add(new Membership__c(Name = 'Membership Test1', Account_Name__c = accList[0].Id, 
                                             Program__c = progList[0].Id, Active_Contract_Idenfied__c = contract.Id,
                                             Earliest_Contract__c = contract.Id,
                                             Latest_Contract__c = contract.Id, Membership_Status_Text__c = 'Member - Pure'));
        membershipList.add(new Membership__c(Name = 'Membership Test2', Account_Name__c = accList[1].Id, 
                                             Program__c = progList[1].Id,
                                             Earliest_Contract__c = contract.Id,
                                             Latest_Contract__c = contract.Id, Membership_Status_Text__c = 'prospect'));
                                             
        
        //Start test from here
        Test.startTest();
        
        //Query to fetch Account record data
        accList = [Select Id, Name, Industry_Member__c, Academy_Programs_Available_for_Outreach__c, BI_Programs_Available_for_Outreach__c FROM Account ORDER BY Name ASC];
        
        //Assert for results
        System.assertEquals('Academy1',accList[0].Academy_Programs_Available_for_Outreach__c);
        System.assertEquals('BIProgram1',accList[1].BI_Programs_Available_for_Outreach__c);
        
        //Enabling triggers again
        Util.byPassAllTriggers = false;

        //insert record
        insert membershipList;
        
        membershipList = [Select Id, Industry_Member__c, Active_Core_Membership__c, Membership_Status__c, 
                            Program__r.Business_line__c
                            FROM Membership__c Where Program__c != null];
        
        //Query to fetch Account record data
        accList = [Select Id, Name, Industry_Member__c FROM Account ORDER BY Name ASC];
        
        //Assert for results
        System.assertEquals(true,accList[0].Industry_Member__c);
        System.assertEquals(false,accList[1].Industry_Member__c);
        
        //Update the Membership record data
        membershipList[0].Account_Name__c =  accList[1].Id;
        membershipList[1].Account_Name__c =  accList[0].Id;

        //update record
        update membershipList;
        
        //Query to fetch Account record data
        accList = [Select Id, Name, Industry_Member__c, Academy_Programs_Available_for_Outreach__c, BI_Programs_Available_for_Outreach__c FROM Account ORDER BY Name ASC];
        
        //Assert for results
        System.assertEquals(false,accList[0].Industry_Member__c);
        System.assertEquals(null,accList[0].Academy_Programs_Available_for_Outreach__c);
        System.assertEquals(true,accList[1].Industry_Member__c);
        System.assertEquals(null,accList[1].BI_Programs_Available_for_Outreach__c);
       
        //Test will stop here
        Test.stopTest();
    }
}