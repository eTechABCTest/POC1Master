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
private class Test_ContractABCTrigger {
/* 
    Purpose:    This class is  ttest class for InstituteRoleController
                
    Create By:  Simplyforce Technology
    
    Created Date:   10/13/2011
    
    Current Version:    v1.0
    
    Revision Log:   V_1.0 - 10/13/2011 - Created
                    V_2.0 - 10/27/2011 - Class updated for LIS object validation
		    		V_3.0 - 08/26/2015  - CR-20150820-9167
					V_4.0 - Modified By - Abhinav Sharma - 02/15/2016 - CR-20150925-9267
    
    Coverage :  Trigger_ContractABC (80%)
                ContractABCTriggerHelper (90%)
*/
    static testMethod void myUnitTest() {

	//Bypassing all triggers
        Util.byPassAllTriggers = true;
        Util.IsTest(true);
        
        //create Test data for Account object as an institute
        Account institute = new Account(Name = 'TestInstitute');
        insert institute;
        
        // Create invoice billing data
        Invoice_Billing_Schedule__c ibs = new Invoice_Billing_Schedule__c(Institution__c = institute.Id);
        insert ibs;
        
        //start test from here
        Test.startTest();
        
	//Enabling triggers
        Util.byPassAllTriggers = false;
        
        //create Contract ABC test data
        Contract__c contractABC = new Contract__c(Payer_Account__c = institute.Id, Invoice_Billing_Schedule__c = ibs.Id);
        insert contractABC;
        
        //Create 200 LIS records to test the ContractABCTriggerHelper.validateIBSIdForContactABC functionality
        List<Line_Item_Schedule__c> listLIS = new List<Line_Item_Schedule__c>();
        
        for(Integer i = 0; i < 101; i++) {
            listLIS.add(new Line_Item_Schedule__c(Contract__c = contractABC.Id, Invoice_Billing_Schedule_del__c = ibs.Id, 
                                                                Type__c = 'Test', Invoice_Date__c = Date.today(), Invoice_Comment__c = 'Test', 
                                                                Amount__c = 20));
        }
        
        //insert data in bulk
        insert listLIS;
        
         // Create invoice billing data to test LIS functionality
        Invoice_Billing_Schedule__c ibsToUpdate = new Invoice_Billing_Schedule__c(Institution__c = institute.Id); 
        insert ibsToUpdate;
                
        //update the billing invoice record id
        contractABC.Invoice_Billing_Schedule__c = ibsToUpdate.Id;                                   
        update contractABC;
        
        ContractABCTriggerHelper.updateLISWithContractABCIBS(new List<Contract__c>{contractABC});
        
        //stop test here
        Test.stopTest();
        
        //assert for the trigger
        Integer counter = [Select count() from Line_Item_Schedule__c where Contract__c =: contractABC.Id];
        System.assertEquals(101, counter);
            
        //Record Types
        List<RecordType> rdTypes = [Select ID, DeveloperName FROM RecordType 
                                    Where sObjectType='Opportunity' 
                                    AND IsActive = true AND DeveloperName = 'Southwind'];
        
        //Assert for the result
        System.assert(rdTypes != null);
        System.assertEquals(1, rdTypes.size());
        
        //List to hold the opportunity records
        List<Opportunity> opportunities = new List<Opportunity>();
        
        //Children Opportunities instances
        Opportunity opp_1 = new Opportunity(StageName = 'Prospect', CloseDate = System.today().addDays(8), 
                                            Name = 'Test Opp 1', Amount = 2000, Signed_Opportunity_Contract__c = contractABC.id,
                                            RecordTypeId = rdTypes[0].ID);
        
        
        //Children Opportunities instances
        Opportunity opp_2 = new Opportunity(StageName = 'Prospect', CloseDate = System.today().addDays(7), 
                                            Name = 'Test Opp 1', Amount = 2000, Signed_Opportunity_Contract__c = null,
                                            RecordTypeId = rdTypes[0].ID);
        
        
        //Children Opportunities instances
        Opportunity opp_3 = new Opportunity(StageName = 'Prospect', CloseDate = System.today().addDays(6), 
                                            Name = 'Test Opp 1', Amount = 2000, Signed_Opportunity_Contract__c = contractABC.id, 
                                            RecordTypeId = rdTypes[0].ID);
        
        //Populating list with records
        opportunities.add(opp_1);
        opportunities.add(opp_2);
        opportunities.add(opp_3);
            
        //Diabling triggers
        Util.ByPassAllTriggers = true;
        
        //Setting flag values
        OpportunityTriggerHelper.EXECUTE_TRIGGER_BEFORE_UPDATE = false;
        OpportunityTriggerHelper.EXECUTE_TRIGGER_AFTER_UPDATE = false;
        
        insert opportunities;
        
        //Retrieving out the details of the bundle record
        opportunities = [SELECT ID, Renewal_Contract_Type__c 
                         FROM Opportunity 
                         ORDER BY CloseDate DESC];
        
        //Asserting for the results
        System.assertEquals(3, opportunities.size());
        System.assertEquals(null, opportunities[0].Renewal_Contract_Type__c);
        System.assertEquals(null, opportunities[1].Renewal_Contract_Type__c);
        System.assertEquals(null, opportunities[2].Renewal_Contract_Type__c);

        //Setting flag values
        OpportunityTriggerHelper.EXECUTE_TRIGGER_BEFORE_UPDATE = true;
        OpportunityTriggerHelper.EXECUTE_TRIGGER_AFTER_UPDATE = true;
		
        //Enabing triggers again
        Util.ByPassAllTriggers = false;
        ContractABCTriggerHelper.isContractABCTriggerExecuted = false;
        
        //updating type field value on contract ABC record
        contractABC.Type__c = 'Renewal';
        update contractABC;
        
        //Retrieving out the details of the bundle record
        opportunities = [SELECT ID, Renewal_Contract_Type__c 
                         FROM Opportunity 
                         ORDER BY CloseDate DESC];
        
        //Asserting for the results
        System.assertEquals(3, opportunities.size());
        System.assertEquals('Renewal', opportunities[0].Renewal_Contract_Type__c);
        System.assertEquals(null, opportunities[1].Renewal_Contract_Type__c);
        System.assertEquals('Renewal', opportunities[2].Renewal_Contract_Type__c);
	}
    
    //Modified By - Mahedra Swarnkar - 07/25/2016 - CR-20160229-9651
    //Added By - Abhinav Sharma - 02/15/2016 - CR-20150925-9267
    static testmethod void test_PopulateFieldsOnCase() { 
    
        //Bypass Dupeblocker
        Util.IsTest(true);
        
        //Bypassing Triggers so then test data can be created easily
        Util.byPassAllTriggers = true;
        
        //Profile    
        Profile p = [SELECT Id FROM Profile WHERE Name = 'System Administrator']; 
        
        //List to hold the users
        List<User> users = new List<User>();
      
        //User 1
        User user_1 = new User(Alias = 'standt', Email='standarduser@testorg.com', 
                            EmailEncodingKey='UTF-8', LastName='Testing1', LanguageLocaleKey='en_US', 
                            LocaleSidKey='en_US', ProfileId = p.Id, department = 'STP',
                            TimeZoneSidKey = 'GMT', UserName=Math.random() + '@test.com');
                            
        //User 2
        User user_2 = new User(Alias = 'standt', Email='standarduser@testorg1.com', 
                            EmailEncodingKey='UTF-8', LastName='Testing2', LanguageLocaleKey='en_US', 
                            LocaleSidKey='en_US', ProfileId = p.Id, department = 'STP',
                            TimeZoneSidKey='GMT', UserName=Math.random() + '@test.com');
        //User 3
        User user_3 = new User(Alias = 'standt', Email='standarduser@testorg2.com', 
                            EmailEncodingKey='UTF-8', LastName='Testing3', LanguageLocaleKey='en_US', 
                            LocaleSidKey='en_US', ProfileId = p.Id, department = 'STP',
                            TimeZoneSidKey='GMT', UserName=Math.random() + '@test.com');
                            
        //Populating list with the user instance
        users.add(user_1); users.add(user_2); users.add(user_3);
        insert users;
        
        //List to hold the Account records
        List<Account> accounts = new List<Account>();
        
        //Create an institution
        Account acct_1 = TestUtilities.CreateNewAccount(false);
        Account acct_2 = TestUtilities.CreateNewAccount(false);
        
        //Populating list with account records
        accounts.add(acct_1); accounts.add(acct_2); 
        
        //Insert accounts
        insert accounts;
        
        //Assert for the results
        System.assert(accounts != null);
        System.assert(accounts.size() == 2);
        
        //Create program data
        List<Program__c> programs = new List<Program__c>();
        Program__c program_1 = new Program__c(Name = 'testName 1', Program_Acronym__c = 'testCode', 
                                              Business_line__c = 'RI', Status__c = 'Active');
        Program__c program_2 = new Program__c(Name = 'testName 2', Program_Acronym__c = 'testing', 
                                              Business_line__c = 'PT', Status__c = 'Active');
        Program__c program_3 = new Program__c(Name = 'testName 3', Program_Acronym__c = 'testing TD', 
                                              Business_line__c = 'TD', Status__c = 'Active');
        programs.add(program_1); programs.add(program_2);  programs.add(program_3);
        insert programs;
        
        //Assert for the results
        System.assert(programs != null);
        System.assert(programs.size() == 3);
        
        //create Contract ABC test data
        List<Project__c> projects = new List<Project__c>();
        Project__c project_1 = new Project__c( Name = 'Test1', Membership_Advisor_Relationship_Manager__c = users[0].Id, 
                                               Dedicated_Advisor__c = users[1].Id, Program_Associate__c = users[2].Id, 
                                               No_of_Participants__c = 1, Cohort_ID_s__c = 'Test_Cohort', X1_2_Day__c = 1, 
                                               Contract_Start_Date__c = System.today().addDays(-2), 
                                               Internal_Strat_Session_NPI_Actual__c = System.today().addDays(2), 
                                               Service_Date_Start__c = System.today().addDays(-1));
        
        Project__c project_2 = new Project__c( Name = 'Test2', Membership_Advisor_Relationship_Manager__c = users[1].Id, 
                                               Dedicated_Advisor__c = users[2].Id, Program_Associate__c = users[0].Id, 
                                               No_of_Participants__c = 2, Cohort_ID_s__c = 'Test_Cohort', Full_Day__c = 1, 
                                               Contract_Start_Date__c = System.today().addDays(-2), 
                                               Internal_Strat_Session_NPI_Actual__c = System.today().addDays(2), 
                                               Service_Date_Start__c = System.today().addDays(-1));
        
        projects.add(project_1); projects.add(project_2);
        insert projects;
        
        //Assert for the results
        System.assert(projects != null);
        System.assert(projects.size() == 2);
        
        
        //Querying Details for "Member & Employee Support" record type on Case Object
        List<RecordType> caseRdTypes = [SELECT ID, DeveloperName FROM RecordType 
                                   		Where sObjectType = 'Case' 
                                   		AND IsActive = true 
                                   		AND DeveloperName IN ('Expert_Center', 'WebHelp' , 'Talent_Development')
                                   		ORDER By DeveloperName ASC];
                
        //Assert for the results
        System.assert(caseRdTypes != null);
        System.assert(caseRdTypes.size() == 3);
        System.assert(caseRdTypes[0].DeveloperName == 'Expert_Center');
        System.assert(caseRdTypes[1].DeveloperName == 'Talent_Development');
        System.assert(caseRdTypes[2].DeveloperName == 'WebHelp');
        
        //Record Type Setting list
        list<RecordType_Setting__c> listRTSettings = new list<RecordType_Setting__c>();

        //Record Type Setting instance
        RecordType_Setting__c rs_1 = new RecordType_Setting__c(Name = 'Test1', 
                                                             Name__c = System.Label.CASE_NEW_MEMBER_RECORD_TYPE, 
                                                             SFID__c = caseRdTypes[0].Id, SObjectType__c = 'Case');
		RecordType_Setting__c rs_2 = new RecordType_Setting__c(Name = 'Test2', 
                                                             Name__c = 'Webhelp', 
                                                             SFID__c = caseRdTypes[2].Id, SObjectType__c = 'Case');
        RecordType_Setting__c rs_3 = new RecordType_Setting__c(Name = 'Test3', 
                                                             Name__c = 'Talent Development', 
                                                             SFID__c = caseRdTypes[1].Id, SObjectType__c = 'Case');
        listRTSettings.add(rs_1); listRTSettings.add(rs_2); listRTSettings.add(rs_3);
        insert listRTSettings;
        
        //List to hold the case records
        List<Case> cases = new List<Case>();
        
        //Create a sample case record to insert and test case trigger
        Case aCase_1 = new Case(RecordTypeId = caseRdTypes[0].Id, Origin = 'ABC1', Subject = 'Test', 
                                Description = 'Test', AccountId = accounts[0].Id);
                                
        //Create a sample case record to insert and test case trigger
        Case aCase_2 = new Case(RecordTypeId = caseRdTypes[2].Id, Origin = 'Email', Subject = 'Test 1', 
                                Description = 'test 1', AccountId = accounts[1].Id);
        
        //Create a sample case record to insert and test case trigger
        Case aCase_3 = new Case(RecordTypeId = caseRdTypes[1].Id, Origin = 'ABC2', Subject = 'Test 2', 
                                Description = 'test 2', AccountId = accounts[0].Id);
        
        //Create a sample case record to insert and test case trigger
        Case aCase_4 = new Case(RecordTypeId = caseRdTypes[1].Id, Origin = 'ABC3', Subject = 'Test 3', 
                                Description = 'test 2', AccountId = accounts[0].Id, Project_Source_MS__c = projects[0].Id);
        
        //Populating list with case records
        cases.add(aCase_1); cases.add(aCase_2); cases.add(aCase_3); cases.add(aCase_4);  
        
        //Insert cases
        insert cases;
        
        //Assert for the results
        System.assert(cases != null);
        System.assert(cases.size() == 4);
        
        //Asserting for the results
        cases = [SELECT ID, Origin, New_Member_Programs_RI__c, New_Member_Programs_TD__c FROM Case ORDER BY Origin ASC];
            
        //Assert for the results
        System.assert(cases != null);
        System.assert(cases.size() == 4);
        System.assertEquals('Email', cases[0].Origin);
        System.assertEquals(null, cases[0].New_Member_Programs_RI__c);
        System.assertEquals('ABC1', cases[1].Origin);
        System.assertEquals(null, cases[1].New_Member_Programs_RI__c);
        System.assertEquals('ABC2', cases[2].Origin);
        System.assertEquals(null, cases[2].New_Member_Programs_TD__c);
        System.assertEquals('ABC3', cases[3].Origin);
        System.assertEquals(null, cases[3].New_Member_Programs_TD__c);
        
        //create Contract ABC test data
        List<Contract__c> contracts = new List<Contract__c>();
        Contract__c contractABC_1 = new Contract__c(Payer_Account__c = accounts[0].Id, Type__c = 'NBB', 
                                                    Program__c = programs[0].Id, Start__c = System.today().addDays(-5),
                                                    End__c = System.today().addDays(5));
        Contract__c contractABC_2 = new Contract__c(Payer_Account__c = accounts[1].Id, Type__c = 'NBB', 
                                                    Program__c = programs[1].Id, Start__c = System.today().addDays(-5),
                                                    End__c = System.today().addDays(7));
        
        Contract__c contractABC_3 = new Contract__c(Payer_Account__c = accounts[0].Id, Type__c = 'NBB', 
                                                    Program__c = programs[2].Id, Start__c = System.today().addDays(-5),
                                                    End__c = System.today().addDays(7));
        
        contracts.add(contractABC_1); contracts.add(contractABC_2); contracts.add(contractABC_3);
        
        //Start test from here
        Test.startTest();
        
        //Enabling triggers
        Util.byPassAllTriggers = false;
       
        insert contracts;
        
        //Assert for results
        System.assert(contracts != null);
        System.assert(contracts.size() == 3);
        
        //Asserting for the results
        cases = [SELECT ID, Origin, New_Member_Programs_RI__c, New_Member_Programs_TD__c, Project_Year__c, Project_Source_MS__r.Name  FROM Case ORDER BY Origin ASC];
            
        //Assert for the results
        System.assert(cases != null);
        System.assert(cases.size() == 4);
        System.assertEquals('Email', cases[0].Origin);
        System.assertEquals(null, cases[0].New_Member_Programs_RI__c);
        System.assertEquals('ABC1', cases[1].Origin);
        System.assertEquals('testCode', cases[1].New_Member_Programs_RI__c);
        System.assertEquals('ABC2', cases[2].Origin);
        System.assertEquals('testing TD', cases[2].New_Member_Programs_TD__c);
        System.assertEquals('ABC3', cases[3].Origin);
        System.assertEquals('testing TD', cases[3].New_Member_Programs_TD__c);
        System.assertEquals(null, cases[2].Project_Year__c);
        System.assertEquals(null, cases[3].Project_Year__c);
        
        //Bypassing triggers
        Util.BypassAllTriggers = true;
        
        //Update case
        cases[0].RecordTypeId = caseRdTypes[0].Id;
        cases[0].New_Member_Programs_RI__c = 'test';
        cases[1].New_Member_Programs_RI__c = 'test';
        cases[2].Contract__c = contracts[2].Id;
        cases[3].Contract__c = contracts[2].Id;
        update cases; 
        
        //Updating contracts
        contracts[0].End__c = System.today().addDays(-2);
        contracts[1].Program__c = programs[0].Id;
        contracts[2].End__c = System.today().addYears(2);
        
        //Enabling triggers
        Util.BypassAllTriggers = false;
        update contracts;
        
        //Asserting for the results
        cases = [SELECT ID, Origin, AccountID, New_Member_Programs_RI__c, Project_Year__c,Project_Source_MS__r.Name  FROM Case ORDER BY Origin ASC];
        
        //Assert for the results
        System.assert(cases != null);
        System.assert(cases.size() == 4);
        System.assertEquals('Email', cases[0].Origin);
        System.assertEquals('testCode', cases[0].New_Member_Programs_RI__c);
        System.assertEquals('ABC1', cases[1].Origin);
        System.assertEquals(null, cases[1].New_Member_Programs_RI__c);
        System.assertEquals('null - ' + System.today().addYears(2).year(), cases[2].Project_Year__c);
        System.assertEquals(cases[3].Project_Source_MS__r.Name + ' - '+System.today().addYears(2).year(), cases[3].Project_Year__c);
        
        //test will stop here
        Test.stopTest();
    }
}