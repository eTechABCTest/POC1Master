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
private class testChangeRequestUtilities {
	
	static testMethod void testISSystem_PartialOut() {
        
        // create a new Change Req
        
        SFDC_Change_Request__c CR = testUtilities.CreateChangeRequest(false);
        CR.Functionality__c = 'Partial';
        insert CR;
        
        // get the updated IS System
        
        IS_System__c ISS = [SELECT Name, Id, Current_Status__c FROM IS_System__c WHERE Id = :CR.IS_System__c];
        system.assertEquals('Partial Out', ISS.Current_Status__c);
        
    }
	
    static testMethod void testISSystem_AllOut() {
        
        Test.startTest();
        
        // create a new Change Req
        
        SFDC_Change_Request__c CR = testUtilities.CreateChangeRequest(true);
		
		update CR;
		
        Test.stopTest();
        
        // get the updated IS System
        IS_System__c ISS = [SELECT Name, Id, Current_Status__c FROM IS_System__c WHERE Id = :CR.IS_System__c];
        system.assertEquals('All Out', ISS.Current_Status__c);
        
    }
    
    static testMethod void testISSystem_AllOut2() {
        
        // create a new Change Req
        Id sysOutageRTId = Util.RecordTypeId('SFDC_Change_Request__c', 'System Outage');
        SFDC_Change_Request__c CR = testUtilities.CreateChangeRequest(true);
        
        // create a new Change Req
        SFDC_Change_Request__c CR2 = testUtilities.CreateChangeRequest(false);
        CR2.Functionality__c = 'Partial';
        CR2.IS_System__c = CR.IS_System__c;
        CR2.Title__c = 'Maintenance';
        insert CR2;
        
        // get the updated IS System
        IS_System__c ISS = [SELECT Name, Id, Current_Status__c FROM IS_System__c WHERE Id = :CR.IS_System__c];
        system.assertEquals('All Out', ISS.Current_Status__c);
        
    }
    
    static testMethod void testISSystem_AllOut3() {
        // create a new is system
        IS_System__c ISS = new IS_System__c();
        ISS.Name = 'Servers';
        insert ISS;
        
        IS_System__c ISS2 = new IS_System__c();
        ISS2.Name = 'Email';
        ISS2.Primary_System__c = ISS.Id;
        ISS2.Reason__c = 'because';
        insert ISS2;
        
        // create a new Change Req
        SFDC_Change_Request__c CR = testUtilities.CreateChangeRequest(false);
        CR.IS_System__c = ISS.Id;
        insert CR;
        
        // get the updated IS System
        ISS2 = [SELECT Name, Id, Current_Status__c FROM IS_System__c WHERE Id = :ISS2.Id];
        system.assertEquals('All Out', ISS2.Current_Status__c);
    }
    
    static testMethod void testISTeamInvolved() {
    	Util.IsTest(true);
        
    	// create a new Change Req
    	
        SFDC_Change_Request__c CR = testUtilities.CreateChangeRequest(true);
        
        User sysAdmin = [SELECT Name, Id FROM User WHERE Profile.Name = 'System Administrator' AND IsActive = true AND Name != 'Salesforce Administrator' AND FirstName != 'Salesforce' LIMIT 1];
        
        // create a new user
        
        User u = TestUtilities.CreateNewUser(false);
        u.FirstName = 'Roger';
        u.LastName = 'Smith';
        insert u;
        
        // run as the sys admin user
        
        system.runAs(sysAdmin) {
	        
	        // create a request comment
	        
	        SFDC_Request_Comment__c comment = testUtilities.CreateRequestComment(CR.Id, u.Id, false);
	        insert comment;
        }
        
        // get the updated Change Request
        
        CR = [SELECT Id, IS_Team_Involved__c FROM SFDC_Change_Request__c WHERE Id = :CR.Id];
        u = [SELECT Name FROM User WHERE Id = :u.Id];
        
        // make sure the user's name is in the IS Team Involved field
        
        system.assertEquals(u.Name, CR.IS_Team_Involved__c);
        
    }
}