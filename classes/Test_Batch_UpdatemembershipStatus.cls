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
private class Test_Batch_UpdatemembershipStatus {
/*
    Purpose		:	Test class for Batch_UpdateMembershipStatus
                
    Create By	:  	Simplyforce Technology
    
    Created Date:   06/21/2012
    
    Revision Log:	v1.- Created - Coverage - 100%
*/
	static testmethod void myUnitTest1() { 
		//Bypass Dupeblocker
        Util.IsTest(true);
        
    	//Create test data
        Account acc = TestUtilities.CreateNewAccount(true);
		
	    Program__c program = TestUtilities.CreateNewProgram(true);
	    
	    Contract__c contract = new Contract__c(Name='Test1', Payer_Account__c = acc.Id, Program__c = program.Id, Start__c = System.Today().addDays(-10), 
	    											End__c = System.Today().addDays(355));
        insert contract;
	    
	    //Start test from here
	    Test.startTest();
	    
	    Membership__c member = new Membership__c(Name = 'Test Membership', Account_Name__c = acc.Id, Program__c = program.Id, Active_Contract_Idenfied__c = contract.Id);
	    
	    //insert membership record and assert the result
	    insert member;
	    
	    //Update Earliest_Contract__r on contract
	    contract.Start__c = Date.today() + 7;
	    update contract;
	    
	    //Update Earliest Contract
	    member.Earliest_Contract__c = contract.Id;
	    
	    //update membership record
	    update member;
	     
	    //assert for the result
	    member = [Select Id, Earliest_Contract__c, Membership_Status_Text__c from Membership__c where Id =: member.Id];
	    System.assertEquals(Constants.PROSPECT_PENDING_FUTURE_START_DATE, member.Membership_Status_Text__c);
	    
	    //Instantiate Batch and execute batch
	    Id jobId = database.executeBatch(new Batch_UpdateMembershipStatus(), 1);
	    
	    System.assert(jobId != null);
	    
	    //Stop Test here
	    Test.stopTest();
	    
	}
}