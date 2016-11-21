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
private class Test_AccountTriggerHelper {
/*
 *  Purpose         :   This class is helper class for trigger on Membership object.
 *
 *  Create By       :   
 *
 *  Created Date    :   10/2/2012
 *
 *  Revision Log    :   V_1.0 Created
 *                      V_1.1 Modified By - Abhinav Sharma - 06/30/2016 - CR-20160419-9779 - Updated the existing method - testPopulateRegion
                        V_1.2 Modified By - Rajeev Jain - SFDC Royall Migration Release - 06/28/2016 - Manual merge of the shift_update_acc_years_status_test test class.
							- Following method manually merged and improved asserts for it. test1, test2, test3, test1_hd, test2_hd, test3_hd
						V_1.3 Modified By - Mahendra Swarnkar - CR-20160802-10078 - 09/10/2016 - Added a test method "test_PopulateSolutionFlagFieldOnAccount" for "populateSolutionFlagFieldOnAccount"
 *
**/    
    // ensure the account rollups are populated correctly based on their child account details.
    static testmethod void populateParentAcctRollups() {
        
        // skip all triggers temporarily so we can setup test data
        Util.BypassAllTriggers = true;
        
        // create a parent and child institution
        Account parentAcct = TestUtilities.CreateNewAccount(true);
        Account childAcct1 = TestUtilities.CreateNewAccount(false);
        childAcct1.ParentId = parentAcct.Id;
        childAcct1.At_Risk_Renewal__c = 111.11;
        Account childAcct2 = TestUtilities.CreateNewAccount(false);
        childAcct2.ParentId = parentAcct.Id;
        childAcct2.At_Risk_Renewal__c = 111.11;
        list<Account> childAccts = new list<Account> { childAcct1, childAcct2 };
        insert childAccts;
        
        // get the updated parent institution
        parentAcct = [SELECT Id, Fast_Track_Units_System__c, At_Risk_Renewal_System__c 
                      FROM Account WHERE Id = :parentAcct.Id];
        system.assertEquals(null, parentAcct.Fast_Track_Units_System__c);
        system.assertEquals(null, parentAcct.At_Risk_Renewal_System__c);
        
        Util.BypassAllTriggers = false;
        
        // create an opportunity with stageName = 'Verbal Yes'
        Opportunity opp1 = TestUtilities.CreateNewOpportunity(childAcct1.Id, false);
        opp1.StageName = 'Verbal Yes';
        Opportunity opp2 = TestUtilities.CreateNewOpportunity(childAcct2.Id, false);
        opp2.StageName = 'Verbal Yes';
        list<Opportunity> opps = new list<Opportunity> { opp1, opp2 };
        
        //Start Test from here
        Test.startTest();
        
        //Insert opportunity
        insert opps;
        
        // get the updated parent institution
        parentAcct = [SELECT Id, Fast_Track_Units_System__c, At_Risk_Renewal_System__c 
                      FROM Account WHERE Id = :parentAcct.Id];
        
        system.assertEquals(2, parentAcct.Fast_Track_Units_System__c);
        system.assertEquals(222.22, parentAcct.At_Risk_Renewal_System__c);
        
        //Added By Abhinav Sharma - 03-10-2014 - CR-20140220-4547 - as per CR changes
        parentAcct.At_Risk_Renewal__c = 111.11;
        update parentAcct;
        
        //Assert for the results
        parentAcct = [SELECT Id, Fast_Track_Units_System__c, At_Risk_Renewal_System__c 
                      FROM Account WHERE Id = :parentAcct.Id];
        system.assertEquals(2, parentAcct.Fast_Track_Units_System__c);
        system.assertEquals(222.22, parentAcct.At_Risk_Renewal_System__c);
        
        Util.BypassAllTriggers = false;
        
        //Updating children accounts
        childAccts[0].At_Risk_Renewal__c = 100;
        childAccts[1].At_Risk_Renewal__c = 100;
        update childAccts;
            
        //Assert for results
        parentAcct = [SELECT Id, Fast_Track_Units_System__c, At_Risk_Renewal_System__c 
                      FROM Account WHERE Id = :parentAcct.Id];
        system.assertEquals(2, parentAcct.Fast_Track_Units_System__c);
        system.assertEquals(311.11, parentAcct.At_Risk_Renewal_System__c);
        
        //Stop Test Here
        Test.stopTest();
    }
    
    // this test method will ensure vendor approval is working properly
    static testmethod void submitAndProcessApprovalRequest() {
        
        // skip all triggers temporarily so we can setup test data
        Util.BypassAllTriggers = true;
        Util.isTest(true);
        
        //Querying for ABC Data loader user profile
        Profile abcDataloaderProfile = [Select Id from Profile where Name = :Constants.PROFILE_ABC_DATA_LOADER limit 1];
        
        // run as a user with ABC Dataloader permissions
        User IS_Salesforce_Automation_User = TestUtilities.CreateNewUser(abcDataloaderProfile, true);
        
        // run as IS SF Automation user
        System.runAs(IS_Salesforce_Automation_User) {
            
            // Insert an account with Vendor RT
            Account a = TestUtilities.CreateNewAccount('Vendor', false);
            a.NDA_Attached__c = 'Yes';
            try {
                insert a;
                
                // verify the approval process was started
                List<ProcessInstance> approvals = [SELECT TargetObjectId, Status FROM ProcessInstance WHERE TargetObjectId = :a.Id];
                //system.assertEquals(1, approvals.size());
                //system.assertEquals('Pending', approvals[0].Status);
            } catch(Exception ex) {}        
        }
    }
    
    //Modified By - Abhinav Sharma - 06/30/2016 - CR-20160419-9779 
    //Modified By - Ajit Surana - CR-20141216-8346 - 02/03/2015
    //Verify that the Region is updated properly when the Primary Country on the Institution is updated
    static testmethod void testPopulateRegion() {
        
        //Start test from here
        Test.startTest();
        
        // create an institution
        Account acct = TestUtilities.CreateNewAccount(false);
        acct.Primary_Country__c = 'Bulgaria';
        insert acct;
        
        // get the account
        acct = [SELECT Id, Region__c FROM Account WHERE Id = :acct.Id];
        
        // verify the region has chnaged accordingly
        system.assertEquals('Europe', acct.Region__c);
        
        acct.Primary_Country__c = 'Honduras';
        update acct;
        
        // get the account
        acct = [SELECT Id, Region__c FROM Account WHERE Id = :acct.Id];
        
        // verify the region has chnaged accordingly
        system.assertEquals('Latin America', acct.Region__c);
        
        //Setting primary country as russia
        acct.Primary_Country__c = 'Russia';
        update acct;
        
        // get the account
        acct = [SELECT Id, Region__c FROM Account WHERE Id = :acct.Id];
        
        // verify the region has chnaged accordingly
        system.assertEquals('Australasia', acct.Region__c);
        
        //update primary country to have null as value
        acct.Primary_Country__c = null;
        update acct;
        
        // get the account
        acct = [SELECT Id, Region__c FROM Account WHERE Id = :acct.Id];
        
        // verify the region has chnaged accordingly
        system.assertEquals(null, acct.Region__c);
        
        //Setting primary country as USA
        acct.Primary_Country__c = 'USA';
        update acct;
        
        // get the account
        acct = [SELECT Id, Region__c FROM Account WHERE Id = :acct.Id];
        
        // verify the region has chnaged accordingly
        system.assertEquals('USA', acct.Region__c);
        
        //Added by Ajit Surana - CR-20141216-8346 - 02/03/2015
        //Update Account "Primary Country's field value to United Kingdom
        acct.Primary_Country__c = 'United Kingdom';
        update acct;
        
        //Query to get the results
        acct = [SELECT Id, Region__c FROM Account WHERE Id = :acct.Id];
        
        //Assert for results
        system.assertEquals('UK', acct.Region__c);
        
        //Stop test here
        Test.stopTest();
        
        //Update Account "Primary Country's field value to Ireland
        acct.Primary_Country__c = 'Ireland';
        update acct;
        
        //Query to get the results
        acct = [SELECT Id, Region__c FROM Account WHERE Id = :acct.Id];
        
        //Assert for results
        system.assertEquals('Europe', acct.Region__c);
        
        //Update Account "Primary Country's field value to Spain
        acct.Primary_Country__c = 'Spain';
        update acct;
        
        //Query to get the results
        acct = [SELECT Id, Region__c FROM Account WHERE Id = :acct.Id];
        
        //Assert for results
        system.assertEquals('Latin America', acct.Region__c);
        
        //Update Account "Primary Country's field value to PortugalUn
        acct.Primary_Country__c = 'Portugal';
        update acct;
        
        //Query to get the results
        acct = [SELECT Id, Region__c FROM Account WHERE Id = :acct.Id];
        
        //Assert for results
        system.assertEquals('Latin America', acct.Region__c);
    }
    
    //This method test the populateTopParentInstitute method
    static testmethod void testPopulateTopParentInstitute() {
        
        //Bypass Dupeblocker
        Util.IsTest(true);
        
        //Create test data
        Account parentAccountLevel1 = new Account(Name = 'Test-Parent');
        insert parentAccountLevel1;
        
        //Create test data
        Account parentAccountLevel2 = new Account(Name = 'Test-Parent', ParentId = parentAccountLevel1.Id);
        insert parentAccountLevel2;
        
        //Create test data
        Account parentAccountLevel3 = new Account(Name = 'Test-Parent', ParentId = parentAccountLevel2.Id);
        insert parentAccountLevel3;
        
        //Create test data
        Account parentAccountLevel4 = new Account(Name = 'Test-Parent', ParentId = parentAccountLevel3.Id);
        insert parentAccountLevel4;
        
        //Create account data
        List<Account> accountsToCommit = new List<Account>();
        
        //Create test data 
        for(Integer i = 0; i < 5; i++) {
            
            //Add data
            accountsToCommit.add(new Account(Name = 'TestLevel-1', ParentId = parentAccountLevel1.Id));
            accountsToCommit.add(new Account(Name = 'TestLevel-2', ParentId = parentAccountLevel2.Id));
            accountsToCommit.add(new Account(Name = 'TestLevel-3', ParentId = parentAccountLevel3.Id));
            accountsToCommit.add(new Account(Name = 'TestLevel-4', ParentId = parentAccountLevel4.Id));
        }
        
        //Start test from here
        Test.startTest();
        
        //insert data in bulk
        insert accountsToCommit;
        
        //Assert for the results
        accountsToCommit = [Select Id, Top_Parent_Institution__c from Account where ID IN: accountsToCommit AND Top_Parent_Institution__c =: parentAccountLevel1.Id];
        
        System.assertEquals(20, accountsToCommit.size());   
        
        //Update parent Id with blank
        for(Account acc : accountsToCommit) {
            
            //Update parent with Null
            acc.ParentId = null;
        }
        
        //Update accounts
        update accountsToCommit;
        
        //Assert for the results
        accountsToCommit = [Select Id, Top_Parent_Institution__c from Account where ID IN: accountsToCommit AND Top_Parent_Institution__c =: parentAccountLevel1.Id];
        
        System.assertEquals(0, accountsToCommit.size());    
        
        //stop test here
        Test.stopTest();
    }
    
     //This method test the populateTopParentInstitute method
    static testmethod void testPopulateTopParentInstituteForUpdate() {
        
        //Bypass Dupeblocker
        Util.IsTest(true);
        
        //Create test data
        Account parentAccountLevel1 = new Account(Name = 'Test-Parent');
        insert parentAccountLevel1;
        
        //Create test data
        Account parentAccountLevel2 = new Account(Name = 'Test-Parent', ParentId = parentAccountLevel1.Id);
        insert parentAccountLevel2;
        
        //Create test data
        Account parentAccountLevel3 = new Account(Name = 'Test-Parent', ParentId = parentAccountLevel2.Id);
        insert parentAccountLevel3;
        
        //Create test data
        Account parentAccountLevel4 = new Account(Name = 'Test-Parent', ParentId = parentAccountLevel3.Id);
        insert parentAccountLevel4;
        
        //Create account data
        List<Account> accountsToCommit = new List<Account>();
        
        //Create test data 
        for(Integer i = 0; i < 5; i++) {
            
            //Add data
            accountsToCommit.add(new Account(Name = 'TestLevel-1'));
            accountsToCommit.add(new Account(Name = 'TestLevel-2'));
            accountsToCommit.add(new Account(Name = 'TestLevel-3'));
            accountsToCommit.add(new Account(Name = 'TestLevel-4'));
        }
        
        //insert data in bulk
        insert accountsToCommit;
        
        //Update parent Id with blank
        for(Account acc : accountsToCommit) {
            
            //Update parent with Null
            acc.ParentId = parentAccountLevel4.Id;
        }
        
        //Start test from here
        Test.startTest();
        
        //Update accounts
        update accountsToCommit;
        
        //Assert for the results
        accountsToCommit = [Select Id, Top_Parent_Institution__c from Account where ID IN: accountsToCommit AND Top_Parent_Institution__c =: parentAccountLevel1.Id];
        
        System.assertEquals(20, accountsToCommit.size());    
        
        //stop test here
        Test.stopTest();
    }
    
    //Test Method to test if on deletion of Account all associated children Restriction MtM records will be deleted or not.
    static testmethod void testDeleteAllRestrcitionMtmFuntionality() {
        
        //Bypass Dupeblocker
        Util.IsTest(true);
        
        //List to hold the account records
        List<Account> accounts = new List<Account>();
        
        //Create test data 
        for(Integer i = 0; i < 2; i++) {
            accounts.add(new Account(Name = 'TestLevel ' + i));
        }
        
        //Bypassing all the triggers
        Util.BypassAllTriggers = true;
        
        //Insert accounts
        insert accounts;
        
        //Assert for results
        System.assertEquals(2, accounts.size());
        
        //Restriction
        Restrictions__c restrict = new Restrictions__c();
        restrict.Category__c = 'Critical Background Information';
        restrict.Expiration_Date__c = system.today().addDays(10);
        
        //Bypassing all the triggers
        Util.BypassAllTriggers = true;
        
        insert restrict;
        
        //List Restriction Mtms
        List<Restricted_MtM__c> restrictionMtMs = new List<Restricted_MtM__c>();
        
        Restricted_MtM__c rest_1 = new Restricted_MtM__c(Account__c = accounts[0].Id, Restriction__c = restrict.Id);
        Restricted_MtM__c rest_2 = new Restricted_MtM__c(Account__c = accounts[0].Id, Restriction__c = restrict.Id);
        Restricted_MtM__c rest_3 = new Restricted_MtM__c(Account__c = accounts[1].Id, Restriction__c = restrict.Id);
        Restricted_MtM__c rest_4 = new Restricted_MtM__c(Account__c = accounts[1].Id, Restriction__c = restrict.Id);
        
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
        restrictionMtMs = [SELECT ID FROM Restricted_MtM__c WHERE Account__c =: accounts[0].Id];
        System.assertEquals(2, restrictionMtMs.size());
        restrictionMtMs = [SELECT ID FROM Restricted_MtM__c WHERE Account__c =: accounts[1].Id];
        System.assertEquals(2, restrictionMtMs.size());
        
        //Test start From here
        Test.startTest();
        
        //Util.BypassAllTriggers = false;
        
        //Delete Accounts
        //delete accounts;
        
        //Bypassing all the triggers
        //Util.BypassAllTriggers = true;
        
        //Assert for results
        restrictionMtMs = [Select ID FROM Restricted_MtM__c];
        accounts = [Select ID FROM Account];
        System.assertEquals(4, restrictionMtMs.size());
        System.assertEquals(2, accounts.size());
        
        //Stop Test Here
        Test.stopTest();
    }
    
    //Added By - Abhinav Sharma - 07/03/2014 - CR-20140618-5845
    //Test Method to test if on updation of Account all associated children Case records will be updated with "Member Type" field value or not
    static testmethod void testUpdateAllCasesMemberTypeFuntionality() {
        
        //Bypass Dupeblocker
        Util.IsTest(true);
        
        //Bypassing all triggers
        Util.BypassAllTriggers = true;
        
        //Querying Details for "Member & Employee Support" record type on Case Object
        List<RecordType> rdType = [SELECT ID FROM RecordType Where sObjectType = 'Case' AND IsActive = true 
                                                AND DeveloperName = 'Member_Employee_Support'];
        
        //List to hold the Account records
        List<Account> accounts = new List<Account>();
        
        //Institutions
        Account acct_1 = TestUtilities.CreateNewAccount(false);
        Account acct_2 = TestUtilities.CreateNewAccount(false);
        Account acct_3 = TestUtilities.CreateNewAccount(false);
        
        //Populating list with account records
        accounts.add(acct_1); accounts.add(acct_2); accounts.add(acct_3);
        
        //Insert accounts
        insert accounts;
        
        //Assert for the results
        System.assertEquals(3, accounts.size());
        
        //Bypassing all triggers
        Util.BypassAllTriggers = true;
        
        //List to hold the case records
        List<Case> cases = new List<Case>();
                                
        //Case
        Case aCase_1 = new Case(RecordTypeId = rdType[0].Id, Origin = 'Email', Subject = 'Test 1', 
                                Description = 'test 1', AccountId = accounts[0].Id);
                                
        //Case
        Case aCase_2 = new Case(RecordTypeId = rdType[0].Id, Origin = 'Phone', Subject = 'Test 2', 
                                Description = 'test 2', AccountId = accounts[1].Id);
                                
        //Case
        Case aCase_3 = new Case(RecordTypeId = rdType[0].Id, Origin = 'Web', Subject = 'Test 3', 
                                Description = 'test 3', AccountId = accounts[2].Id);
                                
        //Case
        Case aCase_4 = new Case(RecordTypeId = rdType[0].Id, Origin = 'Phone', Subject = 'Test 4', 
                                Description = 'test 4', AccountId = accounts[1].Id);
                    
        //Populating list with records instances
        cases.add(aCase_1); cases.add(aCase_2); cases.add(aCase_3); cases.add(aCase_4);
        
        //Insert Case
        insert cases;
        
        //Assert for the results
        System.assertEquals(4, cases.size());

        //Start Test from here
        Test.startTest();
        
        //Enabling all triggers
        Util.BypassAllTriggers = false;
        
        //Updating list of accounts
        accounts[0].Description = 'Testing RIAMLargeContract Testing';
        accounts[1].Description = 'RIAMLargeContract';
        accounts[2].Description = 'Testing RIAM';
        update accounts;
        
        System.assertEquals(3, accounts.size());
        
        //Set to hold the Account Ids
        Set<Id> setAccounts = new Set<Id>();
        
        //Loop through list of accounts
        for(Account acc : accounts) {
            setAccounts.add(acc.Id);            
        }
        
        //Asserting for results
        cases = [SELECT Id, Subject, Member_Type__c FROM Case WHERE AccountId IN : setAccounts ORDER BY Subject ASC];
        System.assertEquals(4, cases.size());  
        System.assertEquals('RIAMLargeContract', cases[0].Member_Type__c);
        System.assertEquals('RIAMLargeContract', cases[1].Member_Type__c);
        System.assertEquals(null, cases[2].Member_Type__c);
        System.assertEquals('RIAMLargeContract', cases[3].Member_Type__c);
        
        //Enabling all triggers
        Util.BypassAllTriggers = false;
        
        //Updating the existing case records
        cases[3].AccountId = null;
        cases[2].AccountId = accounts[1].Id;
        cases[1].AccountId = accounts[2].Id;
        
        //Update case records
        update cases;
        
        //Asserting for results
        cases = [SELECT Id, Subject, Member_Type__c FROM Case ORDER BY Subject ASC LIMIT 5];
        System.assertEquals(4, cases.size());  
        System.assertEquals('RIAMLargeContract', cases[0].Member_Type__c);
        System.assertEquals(null, cases[1].Member_Type__c);
        System.assertEquals('RIAMLargeContract', cases[2].Member_Type__c);
        System.assertEquals(null, cases[3].Member_Type__c);
    
        //Disable triggers execution for avoiding the limits errors
        Util.byPassAllTriggers = true;
    }
    // test for one Account with 2 concurrent active years
    static testMethod void test1() {
        Test.startTest();
        Account_Status_Management__c cs = new Account_Status_Management__c(Enable_Update_Account_Status_Trigger__c=true);
        insert cs;

        integer currentFY = shift_get_fiscal_year.current();   
        
        //Create Account associated to Opportnity with a Contact set to primary in the Contact Role
        Util.BypassAllTriggers = true;
         
        Account acc1 = new Account ( Name = 'Shift CRM'  );
        insert acc1;
        
        Util.BypassAllTriggers = false;
        
        Program_Package__c ppk1= new Program_Package__c ( Account__c = acc1.id, Name = 'ShiftTest1',
                                                            Fiscal_Year__c = string.ValueOf(currentFY - 1) ,
                                                                Client_Status_New__c = 'In Play' );
        insert ppk1;
        System.debug(ppk1);
        
        Program_Package__c ppk2= new Program_Package__c ( Account__c = acc1.id, Name = 'ShiftTest2', 
                                                            Fiscal_Year__c = string.ValueOf(currentFY), 
                                                                Client_Status_New__c = 'Secured' );
        insert ppk2;
        System.debug(ppk2);       

        Program_Package__c ppk3= new Program_Package__c ( Account__c = acc1.id, Name = 'ShiftTest3', 
                                                            Fiscal_Year__c = string.ValueOf(currentFY + 1), 
                                                                Client_Status_New__c = 'Secured' );
        insert ppk3;
        System.debug(ppk3);   
        Test.stopTest();
        
        Account result =  [SELECT Name, r_Current_Year_Status__c, 
                            r_Next_Year_Status__c, r_Previous_Year_Status__c 
                                FROM Account WHERE Id =: acc1.id ];
                            
        //System.assertEquals( 2, result.Concurrent_Active_Years__c, 'Error in concurrent years' ); 
        System.assertEquals( 'Secured', result.r_Current_Year_Status__c , 'Error in Current year status' ); 
        System.assertEquals( 'Secured', result.r_Next_Year_Status__c, 'Error in Next year status' );    
        System.assertEquals( 'In Play', result.r_Previous_Year_Status__c , 'Error in Previous year status' );

    }
    
    //Test where an account has concurrent years set to 0 after deletion of prog. packages
    static testMethod void test2() {
        Test.startTest();
        
        Account_Status_Management__c cs = new Account_Status_Management__c(Enable_Update_Account_Status_Trigger__c=true);
        insert cs;
        
        integer currentFY = shift_get_fiscal_year.current(); 
    
        //Create Account associated to Opportnity with a Contact set to primary in the Contact Role
        Util.BypassAllTriggers = true;
         
        Account acc1 = new Account ( Name = 'Shift CRM'  );
        insert acc1;
		
		Util.BypassAllTriggers = false;
		
        List<Program_Package__c> ppList = new List<Program_Package__c>();
        Program_Package__c ppk1= new Program_Package__c ( Account__c = acc1.id, Name = 'ShiftTest1',
                                                            Fiscal_Year__c = string.ValueOf(currentFY - 1) ,
                                                                Client_Status_New__c = 'Secured' );
        ppList.add(ppk1);
        
        Program_Package__c ppk2= new Program_Package__c ( Account__c = acc1.id, Name = 'ShiftTest2', 
                                                            Fiscal_Year__c = string.ValueOf(currentFY), 
                                                                Client_Status_New__c = 'Lost' );
        ppList.add(ppk2);

        Program_Package__c ppk3= new Program_Package__c ( Account__c = acc1.id, Name = 'ShiftTest3', 
                                                            Fiscal_Year__c = string.ValueOf(currentFY + 1), 
                                                                Client_Status_New__c = 'Secured' );
        ppList.add(ppk3);
        
        Program_Package__c ppk4= new Program_Package__c ( Account__c = acc1.id, Name = 'ShiftTest4', 
                                                            Fiscal_Year__c = string.ValueOf(currentFY + 2 ), 
                                                                Client_Status_New__c = 'Secured' );

        ppList.add(ppk4);        
        Program_Package__c ppk5= new Program_Package__c ( Account__c = acc1.id, Name = 'ShiftTest5', 
                                                            Fiscal_Year__c = string.ValueOf(currentFY + 3 ), 
                                                                Client_Status_New__c = 'Committed' );
        ppList.add(ppk5);
        
        insert ppList;
        delete ppList;
        undelete ppList;        

        Test.StopTest();

        Account result2= [SELECT Name, r_Current_Year_Status__c, r_Next_Year_Status__c, r_Previous_Year_Status__c 
                            FROM Account WHERE Name = 'Shift CRM'];

        //System.assertEquals( 3, result2.Concurrent_Active_Years__c, 'Error in concurrent years' ); 
        System.assertEquals( 'Lost', result2.r_Current_Year_Status__c , 'Error in Current year status' ); 
        System.assertEquals( 'Secured' , result2.r_Next_Year_Status__c, 'Error in Next year status' );    
        System.assertEquals( 'Secured', result2.r_Previous_Year_Status__c , 'Error in Previous year status' ); 
       
    }

    //Test an account which concurrent years is set to 0 because there were no client status defined
    static testMethod void test3() {
        Test.startTest();
        
        Account_Status_Management__c cs = new Account_Status_Management__c(Enable_Update_Account_Status_Trigger__c=true);
        insert cs;

		Util.BypassAllTriggers = true;
		
        //Create Account associated to Opportnity with a Contact set to primary in the Contact Role 
        Account acc1 = new Account ( Name = 'Shift CRM'  );
        insert acc1;
        
        Util.BypassAllTriggers = false;
        
        integer currentFY = shift_get_fiscal_year.current(); 
        
        Program_Package__c ppk1= new Program_Package__c ( Account__c = acc1.id, Name = 'ShiftTest1', 
                                                            Fiscal_Year__c = string.ValueOf(currentFY) );
        insert ppk1;
        System.debug(ppk1);
        Test.stopTest();

        Account result=  [SELECT Name, r_Current_Year_Status__c, 
                            r_Next_Year_Status__c, r_Previous_Year_Status__c 
                                FROM Account WHERE Name = 'Shift CRM'];
                            
        //System.assertEquals( 0, result.Concurrent_Active_Years__c, 'Error in concurrent years' ); 
        System.assertEquals( null, result.r_Current_Year_Status__c , 'Error in Current year status' ); 
        System.assertEquals( null, result.r_Next_Year_Status__c, 'Error in Next year status');    
        System.assertEquals( null, result.r_Previous_Year_Status__c , 'Error in Previous year status' );     
    } 
    // test for one Account with 2 concurrent active years
    static testMethod void test1_hd() {
        Test.startTest();
        
        Account_Status_Management__c cs = new Account_Status_Management__c(Enable_Update_Account_Status_Trigger__c=true);
        insert cs;

        integer currentFY = shift_get_fiscal_year.current();   
        
        //Create Account associated to Opportnity with a Contact set to primary in the Contact Role
        Util.BypassAllTriggers = true;
         
        Account acc1 = new Account ( Name = 'Shift CRM'  );
        insert acc1;
        
        Util.BypassAllTriggers = false;
        
        Program_Package_Hardwick_Day__c ppk1= new Program_Package_Hardwick_Day__c ( Account__c = acc1.id, Name = 'ShiftTest1',
                                                            Fiscal_Year_HD__c = string.ValueOf(currentFY - 1) ,
                                                                Client_Engagement_Status_HD__c = 'In Play' );
        insert ppk1;
        System.debug(ppk1);
        
        Program_Package_Hardwick_Day__c ppk2= new Program_Package_Hardwick_Day__c ( Account__c = acc1.id, Name = 'ShiftTest2', 
                                                            Fiscal_Year_HD__c = string.ValueOf(currentFY), 
                                                                Client_Engagement_Status_HD__c = 'Secured' );
        insert ppk2;
        System.debug(ppk2);       

        Program_Package_Hardwick_Day__c ppk3= new Program_Package_Hardwick_Day__c ( Account__c = acc1.id, Name = 'ShiftTest3', 
                                                            Fiscal_Year_HD__c = string.ValueOf(currentFY + 1), 
                                                                Client_Engagement_Status_HD__c = 'Secured' );
        insert ppk3;
        System.debug(ppk3);   

        Test.stopTest();
        
        Account result =  [SELECT Name, r_HD_Current_Year_Engagement_Status__c, 
                            r_HD_Next_Year_Engagement_Status__c, r_HD_Previous_Year_Engagement_Status__c 
                                FROM Account WHERE Id =: acc1.id ];
                            
        //System.assertEquals( 2, result.Concurrent_Active_Years_HD__c, 'Error in concurrent years' ); 
        System.assertEquals( 'Secured', result.r_HD_Current_Year_Engagement_Status__c , 'Error in Current year status' ); 
        System.assertEquals( 'Secured', result.r_HD_Next_Year_Engagement_Status__c, 'Error in Next year status' );    
        System.assertEquals( 'In Play', result.r_HD_Previous_Year_Engagement_Status__c , 'Error in Previous year status' );

    }
    
    //Test where an account has concurrent years set to 0 after deletion of prog. packages
    static testMethod void test2_hd() {
        Test.startTest();
        
        Account_Status_Management__c cs = new Account_Status_Management__c(Enable_Update_Account_Status_Trigger__c=true);
        insert cs;

        integer currentFY = shift_get_fiscal_year.current(); 
    
        //Create Account associated to Opportnity with a Contact set to primary in the Contact Role
        Util.BypassAllTriggers = true;
         
        Account acc1 = new Account ( Name = 'Shift CRM'  );
        insert acc1;
        
        Util.BypassAllTriggers = false;
        
        List<Program_Package_Hardwick_Day__c> pphd_list = new List<Program_Package_Hardwick_Day__c>();
        Program_Package_Hardwick_Day__c ppk1= new Program_Package_Hardwick_Day__c ( Account__c = acc1.id, Name = 'ShiftTest1',
                                                            Fiscal_Year_HD__c = string.ValueOf(currentFY - 1) ,
                                                                Client_Engagement_Status_HD__c = 'Secured' );
        pphd_list.add(ppk1);
        
        Program_Package_Hardwick_Day__c ppk2= new Program_Package_Hardwick_Day__c ( Account__c = acc1.id, Name = 'ShiftTest2', 
                                                            Fiscal_Year_HD__c = string.ValueOf(currentFY), 
                                                                Client_Engagement_Status_HD__c = 'Lost' );
        pphd_list.add(ppk2);

        Program_Package_Hardwick_Day__c ppk3= new Program_Package_Hardwick_Day__c ( Account__c = acc1.id, Name = 'ShiftTest3', 
                                                            Fiscal_Year_HD__c = string.ValueOf(currentFY + 1), 
                                                                Client_Engagement_Status_HD__c = 'Secured' );
        pphd_list.add(ppk3);
        
        Program_Package_Hardwick_Day__c ppk4= new Program_Package_Hardwick_Day__c ( Account__c = acc1.id, Name = 'ShiftTest4', 
                                                            Fiscal_Year_HD__c = string.ValueOf(currentFY + 2 ), 
                                                                Client_Engagement_Status_HD__c = 'Secured' );
        pphd_list.add(ppk4);
        
        Program_Package_Hardwick_Day__c ppk5= new Program_Package_Hardwick_Day__c ( Account__c = acc1.id, Name = 'ShiftTest5', 
                                                            Fiscal_Year_HD__c = string.ValueOf(currentFY + 3 ), 
                                                                Client_Engagement_Status_HD__c = 'Committed' );
        pphd_list.add(ppk5);
        
        
        insert pphd_list;

        
        delete pphd_list;
        undelete pphd_list;

        Test.stopTest();

        Account result2= [SELECT Name, r_HD_Current_Year_Engagement_Status__c, r_HD_Next_Year_Engagement_Status__c, r_HD_Previous_Year_Engagement_Status__c 
                            FROM Account WHERE Name = 'Shift CRM'];

        //System.assertEquals( 3, result2.Concurrent_Active_Years_HD__c, 'Error in concurrent years' ); 
        System.assertEquals( 'Lost', result2.r_HD_Current_Year_Engagement_Status__c , 'Error in Current year status' ); 
        System.assertEquals( 'Secured' , result2.r_HD_Next_Year_Engagement_Status__c, 'Error in Next year status' );    
        System.assertEquals( 'Secured', result2.r_HD_Previous_Year_Engagement_Status__c , 'Error in Previous year status' );
            
    }

    //Test an account which concurrent years is set to 0 because there were no client status defined
    static testMethod void test3_hd() {
        
        Test.startTest();
        
        Account_Status_Management__c cs = new Account_Status_Management__c(Enable_Update_Account_Status_Trigger__c=true);
        insert cs;

        //Create Account associated to Opportnity with a Contact set to primary in the Contact Role
        Util.BypassAllTriggers = true;
         
        Account acc1 = new Account ( Name = 'Shift CRM'  );
        insert acc1;
        
        Util.BypassAllTriggers = false;
        
        integer currentFY = shift_get_fiscal_year.current(); 
        
        Program_Package_Hardwick_Day__c ppk1= new Program_Package_Hardwick_Day__c ( Account__c = acc1.id, Name = 'ShiftTest1', 
                                                            Fiscal_Year_HD__c = string.ValueOf(currentFY) );
        insert ppk1;
        System.debug(ppk1);

        Test.stopTest();
        Account result=  [SELECT Name, r_HD_Current_Year_Engagement_Status__c, 
                            r_HD_Next_Year_Engagement_Status__c, r_HD_Previous_Year_Engagement_Status__c 
                                FROM Account WHERE Name = 'Shift CRM'];
                            
        //System.assertEquals( 0, result.Concurrent_Active_Years_HD__c, 'Error in concurrent years' ); 
        System.assertEquals( null, result.r_HD_Current_Year_Engagement_Status__c , 'Error in Current year status' ); 
        System.assertEquals( null, result.r_HD_Next_Year_Engagement_Status__c, 'Error in Next year status');    
        System.assertEquals( null, result.r_HD_Previous_Year_Engagement_Status__c , 'Error in Previous year status' );     
    }
    
    //Test to test the PopulateSolutionFlagFieldOnAccount method.
    public static testMethod void test_PopulateSolutionFlagFieldOnAccount() {
        
        //Bypass Dupeblocker
        Util.IsTest(true);
        
        //Bypassing Triggers so then test data can be created easily
        Util.byPassAllTriggers = true;
        
        //Flag for triggers: this is just a test, don't do crazy things.
        Util.isTesting = true;
        
        List<Account> accounts =  new List<Account>();
        
        accounts.add( new Account ( Name = 'Test 1', Account_Formal_Name__c = 'Test Account 1', Solution_Adopted__c = system.today(), Solution_Status__c = 'Active' ));
        accounts.add( new Account ( Name = 'Test 2', Account_Formal_Name__c = 'Test Account 2', Solution_Adopted__c = system.today(), Solution_Status__c = '' ));
        
        //Start test from here
        Test.startTest();
        
        //Enabling all Triggers
        Util.byPassAllTriggers = False;
        
        insert accounts;
        
        //QUery through Account records
        accounts = [SELECT Id, Solution_Status__c, Solutions_Flag_Image_Holder__c FROM Account ORDER BY Account_Formal_Name__c ASC ];
        
        //Asserts on result
        System.assertEquals(2, accounts.size());
        System.assertEquals('Active', accounts[0].Solution_Status__c);
        System.assertEquals('Active', accounts[0].Solutions_Flag_Image_Holder__c);
        System.assertEquals(true, String.isBlank(accounts[1].Solution_Status__c));
        System.assertEquals(true, String.isBlank(accounts[1].Solutions_Flag_Image_Holder__c));
        
        //Update the Accounts
        accounts[0].Solution_Status__c = 'Former';
        accounts[1].Solution_Status__c = 'Former';
        
        //Add More account records
        accounts.add( new Account ( Name = 'Test 3', Account_Formal_Name__c = 'Test Account 3', Solution_Adopted__c = system.today(), ParentId = accounts[0].Id, Solution_Status__c = 'Active' ));
        accounts.add( new Account ( Name = 'Test 4', Account_Formal_Name__c = 'Test Account 4', Solution_Adopted__c = system.today(), ParentId = accounts[1].Id, Solution_Status__c = 'Active' ));
        upsert accounts;
        
        //QUery through Account records
        accounts = [SELECT Id, Solution_Status__c, Solutions_Flag_Image_Holder__c FROM Account ORDER BY Account_Formal_Name__c ASC ];
        
        //Asserts on result
        System.assertEquals(4, accounts.size());
        System.assertEquals('Former', accounts[0].Solution_Status__c);
        System.assertEquals('Former', accounts[0].Solutions_Flag_Image_Holder__c);
        System.assertEquals('Former', accounts[1].Solution_Status__c);
        System.assertEquals('Former', accounts[1].Solutions_Flag_Image_Holder__c);
        System.assertEquals('Active', accounts[2].Solution_Status__c);
        System.assertEquals('Active', accounts[2].Solutions_Flag_Image_Holder__c);
        System.assertEquals('Active', accounts[3].Solution_Status__c);
        System.assertEquals('Active', accounts[3].Solutions_Flag_Image_Holder__c);
        
        //Add More account records
        accounts.add( new Account ( Name = 'Test 5', Account_Formal_Name__c = 'Test Account 5', ParentId = accounts[2].Id, Solution_Status__c = '', Solution_Adopted__c = system.today() ));
        accounts.add( new Account ( Name = 'Test 6', Account_Formal_Name__c = 'Test Account 6', ParentId = accounts[3].Id, Solution_Status__c = '', Solution_Adopted__c = system.today() ));
        upsert accounts;
        
        //QUery through Account records
        accounts = [SELECT Id, Solution_Status__c, Solutions_Flag_Image_Holder__c FROM Account ORDER BY Account_Formal_Name__c ASC ];
        
        //Asserts on result
        System.assertEquals(6, accounts.size());
        System.assertEquals('Former', accounts[0].Solution_Status__c);
        System.assertEquals('Former', accounts[0].Solutions_Flag_Image_Holder__c);
        System.assertEquals('Former', accounts[1].Solution_Status__c);
        System.assertEquals('Former', accounts[1].Solutions_Flag_Image_Holder__c);
        System.assertEquals('Active', accounts[2].Solution_Status__c);
        System.assertEquals('Active', accounts[2].Solutions_Flag_Image_Holder__c);
        System.assertEquals('Active', accounts[3].Solution_Status__c);
        System.assertEquals('Active', accounts[3].Solutions_Flag_Image_Holder__c);
        
        System.assertEquals(true, String.isBlank(accounts[4].Solution_Status__c));
        System.assertEquals('Active', accounts[4].Solutions_Flag_Image_Holder__c);
        System.assertEquals(true, String.isBlank(accounts[5].Solution_Status__c));
        System.assertEquals('Active', accounts[5].Solutions_Flag_Image_Holder__c);
        
        //Update the Accounts
        accounts[2].Solution_Status__c = 'Former';
        accounts[3].Solution_Status__c = '';
        update accounts;
        
        //QUery through Account records
        accounts = [SELECT Id, Solution_Status__c, Solutions_Flag_Image_Holder__c FROM Account ORDER BY Account_Formal_Name__c ASC ];
        
        //Asserts on result
        System.assertEquals(6, accounts.size());
        System.assertEquals('Former', accounts[0].Solution_Status__c);
        System.assertEquals('Former', accounts[0].Solutions_Flag_Image_Holder__c);
        System.assertEquals('Former', accounts[1].Solution_Status__c);
        System.assertEquals('Former', accounts[1].Solutions_Flag_Image_Holder__c);
        System.assertEquals('Former', accounts[2].Solution_Status__c);
        System.assertEquals('Former', accounts[2].Solutions_Flag_Image_Holder__c);
        System.assertEquals(true, String.isBlank(accounts[3].Solution_Status__c));
        System.assertEquals('Former', accounts[3].Solutions_Flag_Image_Holder__c);
        
        System.assertEquals(true, String.isBlank(accounts[4].Solution_Status__c));
        System.assertEquals('Former', accounts[4].Solutions_Flag_Image_Holder__c);
        System.assertEquals(true, String.isBlank(accounts[5].Solution_Status__c));
        System.assertEquals('Former', accounts[5].Solutions_Flag_Image_Holder__c);
        
		//Stop test here
        Test.stopTest();     
    }    
}