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
private class Test_PaymentReqProcessController {
	
	public static Payment_Request__c CreatePaymentRequest(boolean CreateAndInsert) {
		Payment_Request__c pmtReq = new Payment_Request__c(Amount__c = 100, Payment_Amount__c = 100,
															Status__c = 'Approved - Awaiting Procurement');
		if (CreateAndInsert) insert pmtReq;
		return pmtReq;
	}
	
	static testMethod void Test_PaymentReqProcessController() {
    	List<Payment_Request__c> pmtRequests = new List<Payment_Request__c>();
    	String idString = '';
    	// 1) Create 10 payment requests
    	for (Integer i = 0; i < 10; i++) {
    		pmtRequests.add(CreatePaymentRequest(false));
    	}
    	insert pmtRequests;
    	// 2) add ids to a comma delimited string
    	for (Payment_Request__c pmtReq : pmtRequests) {
    		if (idString == '') idString = pmtReq.Id;
    		else idString += ',' + pmtReq.Id;
    	}
    	
    	// set the page reference
    	PageReference pageRef = Page.PaymentReqProcess;
        Test.setCurrentPage(pageRef);
        
        // instantiate the controller
        PaymentReqProcessController controller = new PaymentReqProcessController();
    	
    	// make sure the action is chosen immediately since we provided ids to batch
    	system.assertEquals(10, controller.PaymentReqWrappers.size());
    	system.assertEquals(false, controller.PaymentReqWrappers[5].IsSelected);
    	
    	// Select one payment request
    	controller.PaymentReqWrappers[5].IsSelected = true;
    	
    	system.assertEquals(1, Controller.ExistingBatches.size());
    	
    	// 4) generate batch
    	controller.GenerateBatch();
    	// verify we are on the print page
    	system.assertEquals(controller.ACTION_PRINT, controller.ActionName);
    	
    	// get the list of payment requests
    	pmtRequests = [SELECT Id FROM Payment_Request__c WHERE Batch_Num__c != null];
    	system.assertEquals(1, pmtRequests.size());
    }
	
    static testMethod void Test_PaymentReqProcessController_SelectedReqs() {
    	List<Payment_Request__c> pmtRequests = new List<Payment_Request__c>();
    	String idString = '';
    	// 1) Create 10 payment requests
    	for (Integer i = 0; i < 10; i++) {
    		pmtRequests.add(CreatePaymentRequest(false));
    	}
    	insert pmtRequests;
    	// 2) add ids to a comma delimited string
    	for (Payment_Request__c pmtReq : pmtRequests) {
    		if (idString == '') idString = pmtReq.Id;
    		else idString += ',' + pmtReq.Id;
    	}
    	
    	// set the page reference
    	PageReference pageRef = Page.PaymentReqProcess;
        Test.setCurrentPage(pageRef);
        
        // 3) Add ids param to page URL 
        ApexPages.currentPage().getParameters().put('ids', idString);
        
        // instantiate the controller
        PaymentReqProcessController controller = new PaymentReqProcessController();
    	
    	// make sure the action is chosen immediately since we provided ids to batch
    	system.assertEquals(controller.ACTION_CREATE, controller.ActionName);
    	system.assertEquals(10, controller.PaymentReqWrappers.size());
    	// make sure at least one of the requests is already selected
    	system.assertEquals(true, controller.PaymentReqWrappers[0].IsSelected);
    	
    	// 4) generate batch
    	controller.GenerateBatch();
    	// verify we are on the print page
    	system.assertEquals(controller.ACTION_PRINT, controller.ActionName);
    	
    	// get the list of payment requests
    	pmtRequests = [SELECT Batch_Num__c FROM Payment_Request__c];
    	for (Payment_Request__c pmtReq : pmtRequests) {
    		system.assertNotEquals(null, pmtReq.Batch_Num__c);
    	}
    }
    
    static testMethod void Test_PaymentReqProcessController_PrintPDF() {
    	List<Payment_Request__c> pmtRequests = new List<Payment_Request__c>();
    	String idString = '';
    	List<String> batchNums = new List<String> { '201307070001' };
    	String batchNumString = String.valueOf(batchNums);
    	// 1) Create 10 payment requests
    	for (Integer i = 0; i < 10; i++) {
    		Payment_Request__c pmtRequest = CreatePaymentRequest(false);
    		pmtRequest.Batch_Num__c = batchNums[0];
    		pmtRequests.add(pmtRequest);
    	}
    	insert pmtRequests;
    	
    	// set the page reference
    	PageReference pageRef = Page.PaymentReqProcess;
        Test.setCurrentPage(pageRef);
        
        // 2) Add list of batches param to page URL 
        ApexPages.currentPage().getParameters().put('batches', batchNumString);
        
        // instantiate the controller
        PaymentReqProcessController controller = new PaymentReqProcessController();
        
    	system.assertEquals(10, controller.PaymentRequestsByBatchNum.size());
    	system.assertEquals(1, controller.SelectedBatches.size());
    }
}