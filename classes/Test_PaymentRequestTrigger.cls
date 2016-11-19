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
private class Test_PaymentRequestTrigger {
	
	static testmethod void testPopulateABCLiaison() {
		Util.IsTest(true);
		Id employeeRTId =  [SELECT Id FROM RecordType WHERE DeveloperName = 'Employee' AND SObjectType='Contact' AND IsActive = true LIMIT 1].Id;
		List<RecordType> vendorRecordTypes = [SELECT Id FROM RecordType WHERE DeveloperName = 'Vendor' AND SObjectType='Account' AND IsActive = true LIMIT 1];
    	// create new user
    	User u = TestUtilities.CreateNewUser(false);
    	u.Employee_ID__c = '32';
    	insert u;
    	
    	// create an institution
    	Account acct = TestUtilities.CreateVendorAccount(true);
    	
    	// create at least 1 contact
    	Contact c = TestUtilities.CreateNewContact(false);
    	c.RecordTypeId = employeeRTId;
    	c.Employee_ID__c = '32';
    	insert c;
    	acct.Advisory_Board_Liaison__c = c.Id;
    	update acct;
    	// Insert the payment request
        Payment_Request__c pmtRequest = new Payment_Request__c(vendor__c = acct.Id,
        														Status__c = 'New Request',
        														Invoice_Num__c = '123');
        insert pmtRequest;
        // get the pmtReq and verify liaison
        pmtRequest = [SELECT Id, Advisory_Board_Liaison__c FROM Payment_Request__c WHERE Id = :pmtRequest.Id];
        system.assertEquals(u.Id, pmtRequest.Advisory_Board_Liaison__c);
	}

    /*static testmethod void SubmitApproval_PaymentRequest() {
    	Util.IsTest(true);
    	Profile abcDataloaderProfile = [Select Id from Profile where Name = :Constants.PROFILE_ABC_DATA_LOADER limit 1];
    	List<RecordType> vendorRecordTypes = [SELECT Id FROM RecordType WHERE DeveloperName = 'Vendor' AND SObjectType='Account' AND IsActive = true LIMIT 1];
    	// create an institution
    	Account acct = new Account(recordtypeid=vendorRecordTypes[0].Id);
    	insert acct;
    	// create at least 1 contact
    	Contact c = TestUtilities.CreateNewContact(true);
    	
    	// run as a user with ABC Dataloader permissions
    	User IS_Salesforce_Automation_User = TestUtilities.CreateNewUser(abcDataloaderProfile, true);
    	
    	// run as IS SF Automation user
    	System.runAs(IS_Salesforce_Automation_User) {
    		// Insert the payment request
	        Payment_Request__c pmtRequest = new Payment_Request__c(Status__c = 'New Request',
        														   Invoice_Num__c = '123');
	        insert pmtRequest;
	        // verify the approval process was started
	        List<ProcessInstance> approvals = [SELECT TargetObjectId, Status FROM ProcessInstance WHERE TargetObjectId = :pmtRequest.Id];
	        system.assertEquals(1, approvals.size());
	        system.assertEquals('Pending', approvals[0].Status);
    	}
    }*/
    
    static testmethod void SubmitApproval_PaymentRequest_NoApproval() {
    	Util.IsTest(true);
    	
    	Profile SysAdminProfile = [Select Id from Profile where Name != 'System Administrator' limit 1];
    	// run as a user with ABC Dataloader permissions
    	User SysAdmin_User = TestUtilities.CreateNewUser(SysAdminProfile, true);
    	
    	// run as IS SF Automation user
    	System.runAs(SysAdmin_User) {
    		// Insert the payment request
	        Payment_Request__c pmtRequest = new Payment_Request__c(Status__c = 'New Request',
        															Invoice_Num__c = '123');
	        insert pmtRequest;
	        // verify that no approval process was started
	        List<ProcessInstance> approvals = [SELECT TargetObjectId, Status FROM ProcessInstance WHERE TargetObjectId = :pmtRequest.Id];
	        system.assertEquals(0, approvals.size());
    	}
    }
    
    static testmethod void SubmitApproval_PurchaseRequest() {
    	Util.IsTest(true);
    	List<RecordType> vendorRecordTypes = [SELECT Id FROM RecordType WHERE DeveloperName = 'Vendor' AND SObjectType='Account' AND IsActive = true LIMIT 1];
    	
    	// create an institution
    	Account acct = TestUtilities.CreateVendorAccount(true);
    	
    	// create at least 1 contact
    	Contact c = TestUtilities.CreateNewContact(false);
    	c.Employee_ID__c = '123';
    	c.Email = 'test123@noreply.com';
    	insert c;
    	
    	// create a budget approver
    	Department__c budgetApprover = new Department__c(Department_Number__c = '123', 
    															   Name = 'ET',
    															   Department_Head__c = UserInfo.getUserId());
    	insert budgetApprover;
    	
		// Insert the payment request
        Purchase_Request__c purchaseRequest = new Purchase_Request__c(Vendor__c = acct.Id,
        															  Purchase_Amount__c = 1000,
        															  Department__c = 'ET',
        															  Accounting_Manager__c = userInfo.getUserId());
        insert purchaseRequest;
        // verify the purchase request was inserted properly.
        system.assertNotEquals(null, purchaseRequest, 'Purchase Request was not inserted.');
    }
    
}