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
@isTest(seeAllData = false)
private class Test_Trigger_ProjectRole {
    /**
    Purpose         :   Test class for Trigger_ProjectRole
                
    Create By       :   Victor Hanson
    
    Created Date    :   12/12/2013
    
    Revision Log    :   v1.0 - Created
                        v1.1 - Modified By - Abhinav Sharma - CR-20141222-8389
    **/
    
    // create a project role associated with a project with eligible sub options and 'key con auto sub' checked
    static testMethod void createProjectRole_AutoSubscribe() {
        
        //By passing dupblocker and triggers. 
        Util.IsTest(true);
        Util.BypassAllTriggers = true;
        
        // create account with record type = US HCIC
        Account acct = TestUtilities.CreateNewAccount('US HCIC', true);
        
        // create eligible domain
        string eligibleDomainStr = 'adv.com';
        Eligible_Domain__c eligDomain = new Eligible_Domain__c(Account__c = acct.Id,
                                                               Qualified_Domain__c = eligibleDomainStr,
                                                               Is_Included__c = true);
        insert eligDomain;
        
        // create contact
        Contact con = TestUtilities.CreateNewContact(acct, false);
        con.Email = 'vhanson@' + eligibleDomainStr;
        Contact con2 = TestUtilities.CreateNewContact(acct, false);
        con2.Email = 'Bill@' + eligibleDomainStr;
        list<Contact> conList = new list<Contact> { con, con2 };
        insert conList;
        
        // create a program
        Program__c prog = TestUtilities.CreateNewProgram(false);
        prog.Business_line__c = 'PT';
        insert prog;
        
        //membership
        Membership__c membership = new Membership__c();
        membership.Membership_Status_Text__c = 'Member - Payer';
        membership.Account_Name__c = acct.Id;
        membership.Program__c = prog.Id;
        membership.Name = 'test';
        insert membership;
        
        // create an opportunity and contract
        Opportunity opp = testUtilities.CreateNewOpportunity(acct.Id, false);
        opp.CloseDate = system.today();
        opp.stageName = 'Closed Won';
        opp.Program__c = prog.Id;
        insert opp;
        
        //Contract
        Contract__c testContract1 = new Contract__c(
            Name='Test Contract1', Payer_Account__c = acct.Id, Program__c = prog.Id, Source_Opportunity__c=opp.Id,
            Start__c = System.Today().addDays(-10), End__c = system.today().addDays(355),
            Contract_Renewal_Opportunity__c = opp.Id, Status__c = 'ATL', Invoicing_Arrangement__c = 'Annual', Year__c = '2012',
            Type__c = 'NBB', Years_in_Term__c = 1, Initial_Invoice_Date__c = system.today()
            );
        insert testContract1;
        
        // create 2 new subscription options
        Subscription_Option__c subOption_Oncology = new Subscription_Option__c();
        subOption_Oncology.Subscription_Status__c = 'Active';
        subOption_Oncology.Subscription_Category__c = 'EMAIL_DAILY';
        subOption_Oncology.Name = 'Oncology Roundtable';
        
        Subscription_Option__c subOption_Clinical = new Subscription_Option__c();
        subOption_Clinical.Subscription_Status__c = 'Active';
        subOption_Clinical.Subscription_Category__c = 'EMAIL_DAILY';
        subOption_Clinical.Name = 'Clinical Advantage';
        
        List<Subscription_Option__c> subOptionList = new List<Subscription_Option__c> { subOption_Oncology, subOption_Clinical };
        insert subOptionList;
        
        // create 2 new eligible subscription option
        Eligible_Subscription_Option__c eligibleSub_Auto = new Eligible_Subscription_Option__c();
        eligibleSub_Auto.Program__c = prog.Id;
        eligibleSub_Auto.Key_Contact_Auto_Subscribe__c = true;
        eligibleSub_Auto.Related_Subscription__c = subOption_Oncology.Id;
        
        Eligible_Subscription_Option__c eligibleSub_Not_Auto = new Eligible_Subscription_Option__c();
        eligibleSub_Not_Auto.Program__c = prog.Id;
        eligibleSub_Not_Auto.Key_Contact_Auto_Subscribe__c = false;
        eligibleSub_Not_Auto.Related_Subscription__c = subOption_Clinical.Id;
        
        List<Eligible_Subscription_Option__c> esoList = new List<Eligible_Subscription_Option__c> { eligibleSub_Auto, eligibleSub_Not_Auto };
        insert esoList;
        
        // create a project
        Project__c proj = new Project__c(Name = 'test', Product__c = prog.Id, Institution__c = acct.Id, Project_Phase__c = '');
        insert proj;

        //List of project roles
        List<Project_Role__c> projectRoles = new List<Project_Role__c>(); 
        
        // create the project role.  This should cause a subscription to be generated and auto-subscribe the contact
        Project_Role__c pRole = new Project_Role__c(Name = 'pRole', Project_Type__c = 'CCC', Role__c = 'IT Lead', 
                                                    Project__c = proj.Id, Contact__c = con.Id);
        Project_Role__c pRole2 = new Project_Role__c(Name = 'pRole', Project_Type__c = 'CCC', Role__c = 'Business SME', 
                                                    Project__c = proj.Id, Contact__c = con2.Id);
        
        //Populating list with records
        projectRoles.add(pRole);
        projectRoles.add(pRole2);
        
        // start the test
        test.startTest();
        
        //Enabling the trigger again        
        Util.BypassAllTriggers = false;
        
        insert projectRoles;
        
        //Stop Test here
        test.stopTest();
        
        // get all subscriptions for this contact
        list<Subscription__c> subscriptions = [SELECT Id, Auto_Subscribed__c, Contact__c, Subscription_ID__c 
                                               FROM Subscription__c
                                               WHERE Contact__c = :con.Id];
                                               
        // make sure 1 subscription exists for this contact
        system.assertEquals(1, subscriptions.size());
        
        // make sure the subscription is auto subscribed and it's for the subscription we expected
        system.assertEquals(true, subscriptions[0].Auto_Subscribed__c);
        system.assertEquals(eligibleSub_Auto.Id, subscriptions[0].Subscription_ID__c);
        
        // make sure no subscription was inserted for Con2 because their Role was not valid ("Business SME")
        subscriptions = [SELECT Id, Auto_Subscribed__c, Contact__c, Subscription_ID__c 
                                               FROM Subscription__c
                                               WHERE Contact__c = :con2.Id];
                                               
        // make sure 1 subscription exists for this contact
        system.assertEquals(0, subscriptions.size());
        
    }
    
    // create an inactive membership and ensure a subscription doesn't auto generate due to key contact auto subscribe
    static testMethod void createProjectRole_No_AutoSubscribe() {
        
        //Bypassing triggers and dupeblocker
        Util.IsTest(true);
        Util.BypassAllTriggers = true;
        
        // create account with record type = US HCIC
        Account acct = TestUtilities.CreateNewAccount('US HCIC', true);
        
        // create eligible domain
        string eligibleDomainStr = 'adv.com';
        Eligible_Domain__c eligDomain = new Eligible_Domain__c(Account__c = acct.Id,
                                                               Qualified_Domain__c = eligibleDomainStr,
                                                               Is_Included__c = true);
        insert eligDomain;
        
        // create contact
        Contact con = TestUtilities.CreateNewContact(acct, false);
        con.Email = 'vhanson@' + eligibleDomainStr;
        insert con;
        
        // create a program
        Program__c prog = TestUtilities.CreateNewProgram(false);
        prog.Business_line__c = 'PT';
        insert prog;
        
        Membership__c membership = new Membership__c();
        membership.Membership_Status_Text__c = 'Prospect - Pure';
        membership.Account_Name__c = acct.Id;
        membership.Program__c = prog.Id;
        membership.Name = 'test';
        insert membership;
        
        // create 2 new subscription options
        Subscription_Option__c subOption_Oncology = new Subscription_Option__c();
        subOption_Oncology.Subscription_Status__c = 'Active';
        subOption_Oncology.Subscription_Category__c = 'EMAIL_DAILY';
        subOption_Oncology.Name = 'Oncology Roundtable';
        
        Subscription_Option__c subOption_Clinical = new Subscription_Option__c();
        subOption_Clinical.Subscription_Status__c = 'Active';
        subOption_Clinical.Subscription_Category__c = 'EMAIL_DAILY';
        subOption_Clinical.Name = 'Clinical Advantage';
        
        List<Subscription_Option__c> subOptionList = new List<Subscription_Option__c> { subOption_Oncology, subOption_Clinical };
        insert subOptionList;
        
        // create 2 new eligible subscription option
        Eligible_Subscription_Option__c eligibleSub_Auto = new Eligible_Subscription_Option__c();
        eligibleSub_Auto.Program__c = prog.Id;
        eligibleSub_Auto.Key_Contact_Auto_Subscribe__c = true;
        eligibleSub_Auto.Related_Subscription__c = subOption_Oncology.Id;
        
        Eligible_Subscription_Option__c eligibleSub_Not_Auto = new Eligible_Subscription_Option__c();
        eligibleSub_Not_Auto.Program__c = prog.Id;
        eligibleSub_Not_Auto.Key_Contact_Auto_Subscribe__c = false;
        eligibleSub_Not_Auto.Related_Subscription__c = subOption_Clinical.Id;
        
        List<Eligible_Subscription_Option__c> esoList = new List<Eligible_Subscription_Option__c> { eligibleSub_Auto, eligibleSub_Not_Auto };
        insert esoList;
        
        // create a project
        Project__c proj = new Project__c(Name = 'test', Product__c = prog.Id, Institution__c = acct.Id);
        insert proj;
        
        // create the project role.  Since the member's subscription is inactive, no subscription should generate
        Project_Role__c pRole = new Project_Role__c(Name = 'pRole', Project_Type__c = 'CCC', Role__c = 'IT Lead', 
                                                    Project__c = proj.Id, Contact__c = con.Id);
        
        // start the test
        test.startTest();
        
        //Enabling triggers
        Util.BypassAllTriggers = false;
        insert pRole;
        
        //Stop Test here
        test.stopTest();
        
        // get all subscriptions for this contact
        list<Subscription__c> subscriptions = [SELECT Id, Auto_Subscribed__c, Contact__c, Subscription_ID__c 
                                               FROM Subscription__c
                                               WHERE Contact__c = :con.Id];
                                               
        // make sure no subscriptions exists for this contact
        system.assertEquals(0, subscriptions.size());
    }
    
    
    static testMethod void testProjectRolesTriggerLogic() {
        
        //Bypassing triggers and dupeblocker
        Util.IsTest(true);
        Util.BypassAllTriggers = true;
        
        //Profile    
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator']; 
      
        //User
        User u = new User(Alias = 'standt', Email='standarduser@testorg.com', 
                                EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                                LocaleSidKey='en_US', ProfileId = p.Id, department = 'STP',
                                TimeZoneSidKey='America/Los_Angeles', UserName=Math.random() + '@test.com');

        System.runAs(u) {
        
            // create account with record type = US HCIC
            Account acct = TestUtilities.CreateNewAccount('US HCIC', false);
            insert acct;
            
            // create contact
            Contact con = TestUtilities.CreateNewContact(acct, false);
            con.Email = 'testing466465675656@advisoty.com';
            insert con;
            
            // create a program
            Program__c prog = TestUtilities.CreateNewProgram(false);
            prog.Business_line__c = 'PT';
            insert prog;
            
            // create a project
            Project__c proj = new Project__c(Name = 'test', Product__c = prog.Id, Institution__c = acct.Id);
            insert proj;
            
            //List to hold the project role records
            List<Project_Role__c> projectRoles = new List<Project_Role__c>();
            
            Project_Role__c pRole1 = new Project_Role__c(Name = 'pRole 1', Project_Type__c = 'CCC', Role__c = 'Executive Sponsor', 
                                                        Project__c = proj.Id, Contact__c = con.Id);
            Project_Role__c pRole2 = new Project_Role__c(Name = 'pRole 2', Project_Type__c = 'CCC', Role__c = 'Executive Sponsor', 
                                                        Project__c = proj.Id, Contact__c = con.Id);
                                                        
            projectRoles.add(pRole1);
            projectRoles.add(pRole2);
            
            // start the test
            test.startTest();
            
            //Enabling triggers
            Util.BypassAllTriggers = false;
            try {
                insert projectRoles;
            } catch(Exception ex) {}
        
            //Stop Test here
            test.stopTest();
        }
    } 
    
    static testMethod void testProjectRolesTriggerLogic1() {
        
        //Bypassing triggers and dupeblocker
        Util.IsTest(true);
        Util.BypassAllTriggers = true;
        
        //Profile    
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator']; 
      
        //User
        User u = new User(Alias = 'standt', Email='standarduser@testorg.com', 
                                EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                                LocaleSidKey='en_US', ProfileId = p.Id, department = 'STP',
                                TimeZoneSidKey='America/Los_Angeles', UserName=Math.random() + '@test.com');

        System.runAs(u) {
        
            // create account with record type = US HCIC
            Account acct = TestUtilities.CreateNewAccount('US HCIC', false);
            insert acct;
            
            // create contact
            Contact con = TestUtilities.CreateNewContact(acct, false);
            con.Email = 'testing466465675656@advisoty.com';
            insert con;
            
            // create a program
            Program__c prog = TestUtilities.CreateNewProgram(false);
            prog.Business_line__c = 'PT';
            insert prog;
            
            List<Project__c> projects = new List<Project__c>();
            
            // create a project
            Project__c proj1 = new Project__c(Name = 'test 1', Product__c = prog.Id, Institution__c = acct.Id);
            Project__c proj2 = new Project__c(Name = 'test 2', Product__c = prog.Id, Institution__c = acct.Id);
            projects.add(proj1);
            projects.add(proj2);
            insert projects;
            
            //List to hold the project role records
            List<Project_Role__c> projectRoles = new List<Project_Role__c>();
            
            Project_Role__c pRole1 = new Project_Role__c(Name = 'pRole 1', Project_Type__c = 'CCC', Role__c = 'Executive Sponsor', 
                                                        Project__c = projects[0].Id, Contact__c = con.Id);
            Project_Role__c pRole2 = new Project_Role__c(Name = 'pRole 2', Project_Type__c = 'CCC', Role__c = 'Contract Signer', 
                                                        Project__c = projects[0].Id, Contact__c = con.Id);
            Project_Role__c pRole3 = new Project_Role__c(Name = 'pRole 3', Project_Type__c = 'CCC', Role__c = 'Implementation Lead', 
                                                        Project__c = projects[0].Id, Contact__c = con.Id);
            Project_Role__c pRole4 = new Project_Role__c(Name = 'pRole 4', Project_Type__c = 'CCC', Role__c = 'Value Lead', 
                                                        Project__c = projects[0].Id, Contact__c = con.Id);
            Project_Role__c pRole5 = new Project_Role__c(Name = 'pRole 5', Project_Type__c = 'CCC', Role__c = 'Executive Sponsor', 
                                                        Project__c = projects[1].Id, Contact__c = con.Id);
            Project_Role__c pRole6 = new Project_Role__c(Name = 'pRole 6', Project_Type__c = 'CCC', Role__c = 'Contract Signer', 
                                                        Project__c = projects[1].Id, Contact__c = con.Id);
                                                        
            projectRoles.add(pRole1);
            projectRoles.add(pRole2);
            projectRoles.add(pRole3);
            projectRoles.add(pRole4);
            projectRoles.add(pRole5);
            projectRoles.add(pRole6);
            
            //Start the test
            test.startTest();
            
            //Enabling triggers
            Util.BypassAllTriggers = false;
            insert projectRoles;
            
            //Stop Test here
            test.stopTest();
        }
    } 
}