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
@isTest(seeAllData=false)
private class TestMembershipTrigger {
/*
    Purpose         :   Test class for Trigger_Membership
                
    Create By       :   Simplyforce Technology
    
    Created Date    :   01/19/2012
    
    Current Version :   V1.0
    
    Revision Log    :   V1.0 - Created
                        V1.1 - Updated - CR-20111122-239
                        V1.3 - Bhavi - 06/15/2012 - Test Methid added for CR-20120518-905
                        v1.1 - (SUNJ 12/19/13) - CR-20130118-2218
						V1.4 - Modified by - Mahendra Swarnkar - 3/30/2016 - CR-20160107-9497

    Coverage        :   Trigger_Membership - 100%
                        MembershipTriggerHelper - 97%
*/
    
    static testmethod void testMembershipRelationshipGradeNotes() { 
        
        //Bypass Dupeblocker
        Util.IsTest(true);
        
        //Bypassing Triggers so then test data can be made easily
        Util.byPassAllTriggers = true;
        
        //Calling Util class methods
        util.resetRecordtypeSettings();
        
        //Create test data
        Account acc = TestUtilities.CreateNewAccount(true);
        
        //Program
        Program__c program = TestUtilities.CreateNewProgram(true);
        
        //Opportunity
        Opportunity opportunity = TestUtilities.CreateNewOpportunity(acc.Id, true);
        
        //Contract
        Contract__c contract = new Contract__c(Name='Test1', Payer_Account__c = acc.Id, Program__c = program.Id, Start__c = System.Today().addDays(-10), 
                                                    End__c = System.Today().addDays(355), Contract_Renewal_Opportunity__c = opportunity.Id);
        insert contract;
        
        //Enabling Triggers again for testing
        Util.byPassAllTriggers = false;
        
        //Membership
        Membership__c member = new Membership__c(Name = 'Test Membership', Account_Name__c = acc.Id, Program__c = program.Id, Active_Contract_Idenfied__c = contract.Id);
        
        //Update Membership
        insert member;
        
        //Assert the result
        member = [Select Id, Owner_Associate__c from Membership__c where Id =: member.Id];
        
        //insert membership record and assert the result
        test.startTest();
        
        //Associate Opportunity to the Membership
        opportunity.Membership__c = member.Id;
        update opportunity;
        
        // update the membership's relationship grade notes
        member.Relationship_Grade_Notes__c = 'New Grade Notes!';
        update member;
        
        //Stop Test here
        test.stopTest();
        
        //Querying Opportunity record details
        opportunity = [SELECT Id, Relationship_Grade_Notes__c, Membership__c FROM Opportunity WHERE Id = :opportunity.Id];
        member = [Select Id, Relationship_Grade_Notes__c from Membership__c where Id =: member.Id];
        system.assertEquals(member.Id, opportunity.Membership__c);
        system.assertEquals('New Grade Notes!', member.Relationship_Grade_Notes__c);
    }

    static testmethod void myUnitTest1() {
     
        //Bypass Dupeblocker
        Util.IsTest(true);
        
        //Bypassing Triggers so then test data can be made easily
        Util.byPassAllTriggers = true;
        
        //Calling Util class methods
        util.resetRecordtypeSettings();
        
        //Fecth active user
        List<User> listUser = [Select id from User where IsActive = true AND Id !=: UserInfo.getUserId() limit 1];
        
        //Checking list for its size value
        if(listUser.size() > 0) {
        
            //Bypassing Triggers so then test data can be made easily
            Util.byPassAllTriggers = true;
        
            //Update User
            User user = new User(Id = UserInfo.getUserId(), Associate__c = listUser[0].Id);
            update user;
            
            //Create test data
            Account acc = TestUtilities.CreateNewAccount(true);
            
            //Program
            Program__c program = TestUtilities.CreateNewProgram(true);
            
            //Opportunity
            Opportunity opportunity = TestUtilities.CreateNewOpportunity(acc.Id, true);
            
            //Contract
            Contract__c contract = new Contract__c(Name='Test1', Payer_Account__c = acc.Id, Program__c = program.Id, Start__c = System.Today().addDays(-10), 
                                                        End__c = System.Today().addDays(355), Contract_Renewal_Opportunity__c = opportunity.Id);
            insert contract;
            
            //Membership
            Membership__c member = new Membership__c(Name = 'Test Membership', Account_Name__c = acc.Id, Program__c = program.Id, Active_Contract_Idenfied__c = contract.Id);
            
            //Enabling Triggers
            Util.byPassAllTriggers = false;
        
            //insert membership record and assert the result
            insert member;
            
            //Assert the result
            member = [Select Id, Owner_Associate__c from Membership__c where Id =: member.Id];
            System.assertEquals(user.Associate__c, member.Owner_Associate__c);
            
            //Bypassing Triggers 
            Util.byPassAllTriggers = true;
        
            //Update Earliest_Contract__r on contract
            contract.Start__c = Date.today() + 7;
            update contract;
            
            //Bypassing Triggers so then test data can be made easily
            Util.byPassAllTriggers = false;
        
            //Update Earliest Contract
            member.Earliest_Contract__c = contract.Id;
            
            //update membership record
            update member;
            
            //start test from here
            Test.startTest();
            
            //assert for the result
            member = [Select Id, Earliest_Contract__c, Membership_Status_Text__c from Membership__c where Id =: member.Id];
            System.assertEquals(Constants.PROSPECT_PENDING_FUTURE_START_DATE, member.Membership_Status_Text__c);
            
            //Update Active_Contract_Idenfied__c on contract
            contract.Start__c = Date.today() - 7;
            contract.End__c = Date.today() + 7;
            contract.Status__c = Constants.HONORARY;
            update contract;
            member.Active_Contract_Idenfied__c = contract.Id;
            
            //update membership record
            update member;
            
            //assert for the result
            member = [Select Id, Active_Contract_Idenfied__c, Membership_Status_Text__c from Membership__c where Id =: member.Id];
            System.assertEquals(Constants.MEMBER_HONORARY, member.Membership_Status_Text__c);
            
            //Bypassing Triggers so then test data can be made easily
            Util.byPassAllTriggers = true;
        
            contract.Status__c = Constants.CLOSED;
            update contract;
            
            //Bypassing Triggers so then test data can be made easily
            Util.byPassAllTriggers = false;
        
            //update membership record
            member.Account_Name__c = acc.Id;
            update member;
            
            //stop test here
            Test.stopTest();
            
            //assert for the result
            member = [Select Id, Active_Contract_Idenfied__c, Membership_Status_Text__c from Membership__c where Id =: member.Id];
            System.assertEquals(Constants.MEMBER_PAYER, member.Membership_Status_Text__c);
            
            //update membership record
            member.Account_Name__c = null;
            update member;
            
            //assert for the result
            member = [Select Id, Active_Contract_Idenfied__c, Membership_Status_Text__c from Membership__c where Id =: member.Id];
            System.assertEquals(Constants.MEMBER_INTEGRATED, member.Membership_Status_Text__c);
        }
    }
    
    static testmethod void myUnitTest2() { 
    
        //Bypass Dupeblocker
        Util.IsTest(true);
        
        //Bypassing Triggers so then test data can be made easily
        Util.byPassAllTriggers = true;
        
        //Fecth active user
        List<User> listUser = [Select id from User where IsActive = true AND Id !=: UserInfo.getUserId() limit 1];
        
        if(listUser.size() > 0) {
            User user = new User(Id = UserInfo.getUserId(), Associate__c = listUser[0].Id);
            update user;
            
            //Create test data
            Account acc = new Account(Name = 'Test 1');
            insert acc;
            
            Program__c program = new Program__c(Name = 'Test Trigger Program', New_Business_Marketer__c = 'RI Marketer', Program_Acronym__c = 'ZZZ', Create_memberships__c = 'No', Business_line__c = 'PT');
            insert program;
            
            Opportunity opportunity = new Opportunity(Name = 'Test Opp', StageName = Constants.CONTRACT_RECEIVED, Amount = 1, CloseDate = System.today(), AccountId = acc.Id);
            insert opportunity;
            
            Contract__c contract = new Contract__c(Name='Test1', Payer_Account__c = acc.Id, Program__c = program.Id, Start__c = System.Today().addDays(-10), 
                                                        End__c = System.Today().addDays(355), Contract_Renewal_Opportunity__c = opportunity.Id);
            insert contract;
            
            Membership__c member = new Membership__c(Name = 'Test Membership', Account_Name__c = acc.Id, Program__c = program.Id, Active_Contract_Idenfied__c = contract.Id);
            
            //Update contract record
            contract.Start__c = Date.today() - 7;
            contract.End__c = Date.today() - 7;
            contract.Status__c = Constants.CLOSED;
            update contract;
            
            //update membership
            member.Earliest_Contract__c = contract.Id;
            member.Active_Contract_Idenfied__c = contract.Id;
            member.Latest_Contract__c = contract.Id;
            member.Account_Name__c = acc.Id;
            
            //Enabling Triggers again
            Util.byPassAllTriggers = false;
            insert member;
            
            //assert for the result
            member = [Select Id, Membership_Status_Text__c from Membership__c where Id =: member.Id];
            System.assertEquals(Constants.MEMBER_PAYER_GRACE, member.Membership_Status_Text__c);
            
            //Enabling Triggers
            Util.byPassAllTriggers = false;
        
            member.Account_Name__c = null;
            update member;
            
            //assert for the result
            member = [Select Id, Membership_Status_Text__c, Membership_Status_Change_Date__c from Membership__c where Id =: member.Id];
            System.assertEquals(Constants.MEMBER_INTEGRATED_GRACE, member.Membership_Status_Text__c);
            system.assertEquals(system.today(), member.Membership_Status_Change_Date__c);
            
            //start test from here
            Test.startTest();
            
            //Update opportunity stage
            opportunity.StageName = Constants.DROPPED;
            update opportunity;
            update member;
            
            //assert for the result
            member = [Select Id, Membership_Status_Text__c from Membership__c where Id =: member.Id];
            //System.assertEquals(Constants.PROSPECT_RECENT_DROP, member.Membership_Status_Text__c);
            
            opportunity.StageName = Constants.HONORARY;
            update opportunity;
            update member; 
            
            //assert for the result
            member = [Select Id, Membership_Status_Text__c from Membership__c where Id =: member.Id];
            //System.assertEquals(Constants.PROSPECT_PAST_MEMBER, member.Membership_Status_Text__c);
        	
            //Added by - Mahendra Swarnkar - 3/30/2016 - CR-20160107-9497 - Starts from here
            //Fecth active user with ABC Dataloader profile
        	listUser = [Select id,ProfileId from User where IsActive = true AND ProfileId =: label.ABC_Dataloader_Profile_Id AND Id !=: UserInfo.getUserId() limit 1];
        	
            system.assertEquals(label.ABC_Dataloader_Profile_Id, listUser[0].ProfileId);
            //Run in the ABC dataloader Users context
            system.runAs(listUser[0]){
            	
                //Insert a new membership record 
                Membership__c membABCData = new Membership__c(Name = 'TestABCDataLoaderBypass');
                
				//Enable all the triggers
            	Util.BypassAllTriggers = false;
                
                //Insert membership
                insert membABCData;
                
                //Fetch the membership record 
                member = [Select Id, Membership_Status_Text__c from Membership__c where Id =: membABCData.Id];
                
                //Assert for the results
                system.debug('Prospect - Pure:::::'+ member.Membership_Status_Text__c);
                system.assertEquals('Prospect - Pure', member.Membership_Status_Text__c);    
            }
            //Added by - Mahendra Swarnkar - 3/30/2016 - CR-20160107-9497 - Ends here
            
            //stop test here
            Test.stopTest();
        }
    }
    
    //Test method to test the delete functionality of Mambership Key Contact sfor Non Membership records
    static testmethod void testDeleteMembershipKeyContact() {
        
        //Bypass Dupeblocker
        Util.IsTest(true);
        
        //Bypassing Triggers so then test data can be made easily
        Util.byPassAllTriggers = true;
        
        //Calling Utility method
        util.resetRecordtypeSettings();
    
        //Create test data
        Account acc = new Account(Name = 'Test Account Data');
        insert acc;
        
        //Program
        Program__c program = TestUtilities.CreateNewProgram(true);
        
        //Opportunity
        Opportunity opportunity = TestUtilities.CreateNewOpportunity(acc.Id, true);
        
        //Contract
        Contract__c contract = new Contract__c(Name='Test1', Payer_Account__c = acc.Id, Program__c = program.Id, Start__c = System.Today().addDays(-10), 
                                                    End__c = System.Today().addDays(355), Contract_Renewal_Opportunity__c = opportunity.Id);
        insert contract;
        
        //Create a list of membership record to insert the data in bulk
        List<Membership__c> memberships = new List<Membership__c>();
        
        //Prepare data
        for(Integer i = 0; i < 20; i++) {
            memberships.add(new Membership__c(Name = 'Test Membership', Account_Name__c = acc.Id, Program__c = program.Id, 
                                                Active_Contract_Idenfied__c = contract.Id));
        }
        
        //Enabling Triggers
        Util.byPassAllTriggers = false;
        
        
        //insert membership record and assert the result
        insert memberships;
        
        //Create a list of membership records
        List<Membership_Key_Contact__c> membershipKeyContacts = new List<Membership_Key_Contact__c>();
        
        //Add membership Records for Contacts
        for(Membership__c membership : memberships) {
            
            //add record in list
            membershipKeyContacts.add(new Membership_Key_Contact__c(Membership__c = membership.id, Name='Test 1', Role_Type__c = 'PT', 
                                                                    Role__c = 'Exec Sponsor'));
        }
        
        /* Test Insert */
        insert membershipKeyContacts;
        
        //Start Test from here
        Test.startTest();
        
        //Update membership records
        update memberships;
        
        //check if membership key Contacts has been associated with Contacts
        Integer counter = [Select count() from Membership_Key_Contact__c where Id IN: membershipKeyContacts and Membership__c != null];
        System.assertEquals(memberships.size(), counter);
        
        //Update contract record
        contract.Start__c = Date.today() - 7;
        contract.End__c = Date.today() - 7;
        contract.Status__c = Constants.CLOSED;
        update contract;
        
        //assert for the results
        memberships = [Select Membership_Status__c from Membership__c where Id IN: memberships];
        
        //Loop through the results
        for(Membership__c membership : memberships) {
            
            System.assertEquals(Constants.PROSPECT_PURE, membership.Membership_Status__c);
        }
        
        //Commenting out assert as per the Original method has been commened with below comments in Trigger_Membership trigger
        // VRH commented out for CR-2556, these membership key contacts will be deleted in the overnight batch
        //check if membership key Contacts has been associated with Contacts
        //counter = [Select count() from Membership_Key_Contact__c where Id IN: membershipKeyContacts and Membership__c != null];
        //System.assertEquals(0, counter);
        
        //Stop Test here
        Test.stopTest();
   }
}