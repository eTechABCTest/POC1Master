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
private class Test_BatchAccountTeamReplication {
	
	//Setup test data first. This will be available in the entire class
	@testSetup static void setup() {
        
        //Disables all the trigger
        Util.IsTest(true);
        Util.BypassAllTriggers = true;
   
		// Create common Team Role
		Team_Role__c teamRole = new Team_Role__c(Name = 'UniqueName', Institution__c = true);
		insert teamRole;
		
		// Create common Team Role
		Team_Role__c teamRole2 = new Team_Role__c(Name = 'UniqueName2', Institution__c = true);
		insert teamRole2;
		
		Account account = new Account(Name = 'Test');
		insert account;
        
        //Record Types
        List<RecordType> tmRecordTypes = [SELECT ID FROM RecordType WHERE sObjectType = 'Team_Membership__c' 
                                        	AND IsActive = true 
                       						AND DeveloperName = 'Assigned'];
        System.assert(tmRecordTypes != null);
		
		//Team Membership
		Team_Membership__c teamMembership = new Team_Membership__c(Name = 'Test', Employee__c = UserInfo.getUserId(), 
                                                                   Institution__c = account.Id, Role__c = teamRole.Id, 
                                                                   Start_date__c = Date.today()-5,
                                                                   RecordTypeId = tmRecordTypes[0].Id);
		insert teamMembership;
	}
	
	//Test Account Team Replication
	//When a new Team Member is added
	static testMethod void testBatchAccountTeamReplication() {
        
        //Disables all the trigger
        Util.IsTest(true);
        Util.BypassAllTriggers = true;
    	
    	//Query Institution and Team role records
    	Account account = [Select Id from Account limit 1];
    	List<Team_Role__c> teamRoles = [Select Id, Name from Team_Role__c order by CreatedDate ASC limit 2];
    	
    	//Create a new ATM
    	AccountTeamMember aTM = new AccountTeamMember(AccountId = account.Id, UserId = UserInfo.getUserId(), TeamMemberRole = teamRoles[1].Name);
    	insert aTM;
    	
    	//Start Testing from here
    	Test.startTest();
        
        //Enabling triggers again
        Util.BypassAllTriggers = false;
    	
    	//Execute the batch class
    	Batch_AccountTeamReplication batchJob = new Batch_AccountTeamReplication();
    	batchJob.SOQLQuery = 'SELECT Id, TeamMemberRole, UserId, AccountId FROM AccountTeamMember WHERE Id = \'' +  aTM.Id + '\'';
    	database.executeBatch(batchJob);
    	
    	//Stop test here
    	Test.stopTest();
    	
    	//Asert for the results
    	List<Team_Membership__c> listTMs = [Select Id, Name, Employee__c, Institution__c, Role__c, 
                                            Start_date__c, End_date__c from Team_Membership__c 
                                            where Institution__c != null 
                                            AND Institution__c =: account.Id order by CreatedDate ASC];
        
    	System.assertEquals(2, listTMs.size());
    	System.assertEquals(Date.today(), listTMs[0].End_date__c);
    	System.assertEquals(Date.today(), listTMs[1].Start_date__c);
    	System.assertEquals(null, listTMs[1].End_date__c);
    }
}