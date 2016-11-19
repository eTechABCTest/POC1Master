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
private class Test_Batch_Account_OutreachProgs_v2 {
    
    static testmethod void testBatch_Account_OutreachProgs_v2 ()
    { 
        //Bypass Dupeblocker
        Util.IsTest(true);
        util.IsBatch = true;
        Util.IsTesting = true;
        Util.ByPassAlltriggers = true;
        
        Contact testContact = TestUtilities.CreateNewContact(true);
        
        // Create test programs
        List<Program__c> testProgs = new List<Program__c>();
        
        Program__c pAcad = new Program__c(
            Program_Acronym__c = 'TAC',
            Program_Formal_Name__c = 'Test Program Formal',
            Name = 'Test Program',
            Create_Memberships__c = 'No',
            Renewal_Unit_Count__c = 1,
            Business_Line__c = 'TD');
        testProgs.add(pAcad);
        
        Program__c pBI = new Program__c(
            Program_Acronym__c = 'TBI',
            Program_Formal_Name__c = 'Test Program Formal',
            Name = 'Test Program',
            Create_Memberships__c = 'No',
            Renewal_Unit_Count__c = 1,
            Business_Line__c = 'PT');
        testProgs.add(pBI);
            
        Program__c pCore = new Program__c(
            Program_Acronym__c = 'TCO',
            Program_Formal_Name__c = 'Test Program Formal',
            Name = 'Test Program',
            Create_Memberships__c = 'No',
            Renewal_Unit_Count__c = 1,
            Business_Line__c = 'RI');
        testProgs.add(pCore);
        
        Program__c pHWorks = new Program__c(
            Program_Acronym__c = 'THW',
            Program_Formal_Name__c = 'Test Program Formal',
            Name = 'Test Program',
            Create_Memberships__c = 'No',
            Renewal_Unit_Count__c = 1,
            Business_Line__c = 'CM');
        testProgs.add(pHWorks);
        
        insert testProgs;
        
        // Create test accounts
        List<Account> testAccts = new List<Account>();
        
        for(integer i = 0; i < 10; i++)
        {
            if(i < 8)
                testAccts.add(new Account(Name='TestAcct' + i.format()));
            else
                testAccts.add(new Account(Name='TestAcct' + i.format(), Today__c = system.today().addDays(-1)));
        }
        
        insert testAccts;
        
        // Create Contracts
        Contract__c testContract1 = new Contract__c(
            Name='TestContract', Status__c = 'Honorary', Start__c = system.today().addDays(-1), End__c = system.today().addDays(2),
            Negotiated_Amount__c = 1,
            Type__c = 'NBB',
            Year__c = '2010',
            Join_Date__c = system.today().addDays(-5),
            Payer_Account__c = testAccts[0].Id,
            Main_Contact__c = testContact.Id,
            Invoice_Contact__c = testContact.Id,
            Program__c = testProgs[0].Id);
        Contract__c testContract2 = new Contract__c(
            Name='TestContract', Status__c = 'Honorary', Start__c = system.today().addDays(1), End__c = system.today().addDays(2),
            Negotiated_Amount__c = 1,
            Type__c = 'NBB',
            Year__c = '2010',
            Join_Date__c = system.today().addDays(-5),
            Payer_Account__c = testAccts[0].Id,
            Main_Contact__c = testContact.Id,
            Invoice_Contact__c = testContact.Id,
            Program__c = testProgs[0].Id);
        
        insert testContract1;
        insert testContract2;
        
        // Create test memberships
        List<Membership__c> testMembs = new List<Membership__c>();
        
        for(Account acc : testAccts)
        {
            // Membership Status = 'Member-Honorary'
            testMembs.add(new Membership__c(
                Name = 'Test Membership',
                Account_Name__c = acc.Id,
                Earliest_Contract__c = testContract1.Id,
                Active_Contract_Idenfied__c = testContract2.Id,
                Program__c = pAcad.Id));
            
            testMembs.add(new Membership__c(
                Name = 'Test Membership',
                Account_Name__c = acc.Id,
                Earliest_Contract__c = testContract1.Id,
                Active_Contract_Idenfied__c = testContract2.Id,
                Program__c = pBI.Id));
            
            testMembs.add(new Membership__c(
                Name = 'Test Membership',
                Account_Name__c = acc.Id,
                Earliest_Contract__c = testContract1.Id,
                Active_Contract_Idenfied__c = testContract2.Id,
                Program__c = pCore.Id));
            
            testMembs.add(new Membership__c(
                Name = 'Test Membership',
                Account_Name__c = acc.Id,
                Earliest_Contract__c = testContract1.Id,
                Active_Contract_Idenfied__c = testContract2.Id,
                Program__c = pHWorks.Id));
                
            // Membership Status does not contain 'Member' && Prospect Status = 'Available For Outreach'
            testMembs.add(new Membership__c(
                Name = 'Test Membership',
                Account_Name__c = acc.Id,
                Earliest_Contract__c = testContract2.Id,
                Active_Contract_Idenfied__c = testContract1.Id,
                Opportunity_in_Outreach__c = 'No',
                Opportunity_in_Prospect__c = 'No',
                Most_Recent_NBB_Visit__c = null,
                Program__c = pAcad.Id));
            
            testMembs.add(new Membership__c(
                Name = 'Test Membership',
                Account_Name__c = acc.Id,
                Earliest_Contract__c = testContract2.Id,
                Active_Contract_Idenfied__c = testContract1.Id,
                Opportunity_in_Outreach__c = 'No',
                Opportunity_in_Prospect__c = 'No',
                Most_Recent_NBB_Visit__c = null,
                Program__c = pBI.Id));
            
            testMembs.add(new Membership__c(
                Name = 'Test Membership',
                Account_Name__c = acc.Id,
                Earliest_Contract__c = testContract2.Id,
                Active_Contract_Idenfied__c = testContract1.Id,
                Opportunity_in_Outreach__c = 'No',
                Opportunity_in_Prospect__c = 'No',
                Most_Recent_NBB_Visit__c = null,
                Program__c = pCore.Id));
            
            testMembs.add(new Membership__c(
                Name = 'Test Membership',
                Account_Name__c = acc.Id,
                Earliest_Contract__c = testContract2.Id,
                Active_Contract_Idenfied__c = testContract1.Id,
                Opportunity_in_Outreach__c = 'No',
                Opportunity_in_Prospect__c = 'No',
                Most_Recent_NBB_Visit__c = null,
                Program__c = pHWorks.Id));
        }
        util.BypassAllTriggers = false;
        insert testMembs;
        
        // Start testing
        Batch_Account_OutreachProgs_v2 batch = new Batch_Account_OutreachProgs_v2();
       /* batch.Query = 'select Id, Name, Core_Memberships__c, BI_Memberships__c, Academies_Memberships__c, Hworks_Memberships__c, ' +
            'Core_Programs_Available_for_Outreach__c, Active_RI_Memberships__c, Active_PT_Memberships__c, Academy_Programs_Available_for_Outreach__c, BI_Programs_Available_for_Outreach__c, ' +
            '(select id, Program__r.Business_Line__c, Prospect_Status__c, Membership_Status__c, Renewal_Unit_Count__c, Program__c, Program__r.Program_Acronym__c ' +
            'from Memberships__r where Program__r.Business_line__c in ( \'RI\', \'PT\', \'TD\', \'CM\')) ' +
            'from Account Order By CreatedDate desc limit 10';
        */
        
        batch.Query = 'select Id, Name, Core_Memberships__c, Active_PT_Memberships__c, Active_RI_Memberships__c, Active_CM_Memberships__c, Active_SW_Memberships__c, Active_TD_Memberships__c, BI_Memberships__c, Academies_Memberships__c, Hworks_Memberships__c, ' +
            'Core_Programs_Available_for_Outreach__c, Academy_Programs_Available_for_Outreach__c, BI_Programs_Available_for_Outreach__c, ' +
            '(select id, Program__r.Business_Line__c, Prospect_Status__c, Membership_Status__c, Renewal_Unit_Count__c, Program__c, Program__r.Program_Acronym__c ' +
            'from Memberships__r where Program__r.Business_line__c in ( \'RI\', \'PT\', \'TD\', \'CM\', \'SW\')), ' +            
            'RNI_AM_Restrictions__c, (Select RNI_AM_Restriction__c from Restrictions_MtM__r where Restriction_Status__c  = \'Active\')' +
            'from Account Order By CreatedDate desc limit 10';
         
        
        test.startTest();
        Util.BypassAllTriggers = false;
        id batchId = database.executeBatch(batch);
        System.debug('### Launched Batch : '+ batchId);
        test.stopTest();
        
        system.assertNotEquals(null, batchId);
        
        //11/07/2012 - Bhavi - CR-20121016-1624
        Account checkAccount = [select Id, Name, Core_Memberships__c, BI_Memberships__c, Academies_Memberships__c, Hworks_Memberships__c,
            Core_Programs_Available_for_Outreach__c, Active_RI_Memberships__c, Active_PT_Memberships__c, Paid_PT_Memberships__c, Academy_Programs_Available_for_Outreach__c, BI_Programs_Available_for_Outreach__c
            from Account where Id = :testAccts[5].Id];
        
        /*Account checkAccount = [select Id, Name, Core_Memberships__c, BI_Memberships__c, Academies_Memberships__c, Hworks_Memberships__c,
            Core_Programs_Available_for_Outreach__c, Active_RI_Memberships__c, Active_PT_Memberships__c, Academy_Programs_Available_for_Outreach__c, BI_Programs_Available_for_Outreach__c
            from Account where Id = :testAccts[5].Id];*/
        
        //system.assertNotEquals(null, checkAccount.Core_Memberships__c);
        system.assertNotEquals(null, checkAccount.BI_Memberships__c);
        system.assertNotEquals(null, checkAccount.Academies_Memberships__c);
        system.assertNotEquals(null, checkAccount.Hworks_Memberships__c);
        /*VRH temporarily disabled until Bhavi sorts out the Prospect Status formula on Memberships*/
        system.assertNotEquals(null, checkAccount.Core_Programs_Available_for_Outreach__c);
        system.assertNotEquals(null, checkAccount.Academy_Programs_Available_for_Outreach__c);
        system.assertNotEquals(null, checkAccount.BI_Programs_Available_for_Outreach__c);
        system.assertEquals(true, checkAccount.Active_RI_Memberships__c.toLowerCase().contains('tco'));
        system.assertEquals(true, checkAccount.Active_PT_Memberships__c.toLowerCase().contains('tbi'));
     }
    
    static testmethod void testRecordLockUseCase()
    {
        Util.IsTest(true);
        util.IsBatch = true;
        Util.IsTesting = true;
        Util.ByPassAlltriggers = true;
        
        Account acc = new Account(Name = 'testacc1010', Account_Formal_Name__c = 'testacc');
        insert acc;
        Opportunity opp = new Opportunity(AccountId = acc.Id, Name = 'Test', StageName = 'Pending', CloseDate = System.today(), Are_They_Evaluating__c = 'Yes', 
                                        Is_there_are_hard_next_step__c = 'Yes', Initial_Visit_Date__c = date.today());
        insert opp;
        Event evt = new Event(WhatId = opp.Id, StartDateTime = datetime.now().addDays(4), EndDateTime = datetime.now().addDays(5));
        insert evt;     

        Event evt2 = new Event(WhatId = opp.Id, StartDateTime = datetime.now().addDays(5), EndDateTime = datetime.now().addDays(6));
        insert evt2;
            
        Batch_Opportunity_VisitSummaries batchProcess1 = new Batch_Opportunity_VisitSummaries();
        Batch_Opportunity_VisitSummaries batchProcess2 = new Batch_Opportunity_VisitSummaries();
        
        //Start Test from here
        Test.startTest();
        
        id batchId1 = database.executeBatch(batchProcess1,1);
        id batchId2 = database.executeBatch(batchProcess2,1);
        
        System.debug('***** BATCH ID (1): ' + batchId1);
    	System.debug('***** BATCH ID (2): ' + batchId2);     
    	
        //STop test here
        Test.stopTest();
    }
    
    /* VH commented out becasue this is part of CR-9197, which will not deploy on 11/18/15
    //test method for CR-20150827-9197
    static testmethod void testBatchPopulateRNIAMRestrictionsOnAcc() { 
        //Bypass Dupeblocker
        Util.IsTest(true);
        
        //Create test data
        Account account = new Account(Name = 'TestAccountName');
        insert account;
        
        //insert restricted data
        Restrictions__c restriction = new Restrictions__c(Name = 'Test Restrictions', Category__c = 'Restricted: Permission Required', Source_Department__c = 'EA', Expiration_Date__c = Date.today().addDays(1));
        insert restriction;
        
        //Restricted_MtM__c test data
        insert new Restricted_MtM__c(Restriction__c = restriction.Id, Account__c = account.Id );
        
        //insert restricted data
        restriction = new Restrictions__c(Name = 'Test Restrictions', Expiration_Date__c = Date.today().addDays(1), Category__c = 'Restricted: Permission Required', Source_Department__c = 'AE');
        insert restriction;
        
        //Restricted_MtM__c test data
        insert new Restricted_MtM__c(Restriction__c = restriction.Id, Account__c = account.Id);
        
        // retire restriction
        restriction = [SELECT Expiration_Date__c FROM Restrictions__c WHERE Id = :restriction.Id];
        restriction.Expiration_Date__c = system.today().addDays(-1);
        update restriction;
        
        //start test from here
        Test.startTest();
        
        //execute the batch process
        ID batchProcessId = Database.executeBatch(new Batch_Account_OutreachProgs_v2(), 10);
        
        //Stop test here 
        Test.stopTest();
        
        //assert the results
        System.assertEquals(1, [Select RNI_AM_Restrictions__c from Account where Id =: account.Id][0].RNI_AM_Restrictions__c);
    }*/
}