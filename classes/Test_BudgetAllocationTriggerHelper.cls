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
private class Test_BudgetAllocationTriggerHelper{
    
    static testmethod void budgetApproval_PurchaseRequest() {
        
        Util.IsTest(true);
        
        Account acct = TestUtilities.CreateVendorAccount(true);
        
        Department__c department = TestUtilities.createDepartment(true);
    	
    	Budget__c budget = TestUtilities.createBudget(department.Id, true);
    	
        // Insert the purchase request
        Purchase_Request__c purchaseRequest = new Purchase_Request__c(Vendor__c=acct.Id, Purchase_Amount__c=1000,
        															  Department__c='ET', Accounting_Manager__c=userInfo.getUserId());
        insert purchaseRequest;
        
        // insert the budget allocation
        Budget_Allocation__c budgetAllocation = new Budget_Allocation__c(Purchase_Request__c = purchaseRequest.Id,
                                                                          Allocation_Date__c = system.today(),
                                                                          Allocation_Amount__c = 10,
                                                                          Budget_Line__c = budget.Id);
        insert budgetAllocation;
        
        // get the purchase request
        purchaseRequest = [SELECT Total_Budget_Allocation_Amount__c FROM Purchase_Request__c WHERE Id = :purchaseRequest.Id LIMIT 1];
        system.assertEquals(10, purchaseRequest.Total_Budget_Allocation_Amount__c);
        
        budgetAllocation.Allocation_Amount__c = budgetAllocation.Allocation_Amount__c + 1;
        update budgetAllocation;
        // get the purchase request - verify the increase of 1
        purchaseRequest = [SELECT Total_Budget_Allocation_Amount__c FROM Purchase_Request__c WHERE Id = :purchaseRequest.Id LIMIT 1];
        system.assertEquals(11, purchaseRequest.Total_Budget_Allocation_Amount__c);
        
        // delete the budget allocation
        delete budgetAllocation;
        
        // get the purchase request
        purchaseRequest = [SELECT Total_Budget_Allocation_Amount__c FROM Purchase_Request__c WHERE Id = :purchaseRequest.Id LIMIT 1];
        system.assertEquals(0, purchaseRequest.Total_Budget_Allocation_Amount__c);
    }
    
    static testmethod void budgetApproval_newPaymentRequest() {
    	
        Util.IsTest(true);
        
        // create a test user
        User budgetManagerUser = TestUtilities.CreateNewUser(true);
        
        Account acct = TestUtilities.CreateVendorAccount(true);
        
    	Department__c department = TestUtilities.createDepartment(false);
    	department.Department_Head__c = UserInfo.getUserId();
    	department.Budget_Manager__c = budgetManagerUser.Id;
    	insert department;
    	
    	Budget__c budget = TestUtilities.createBudget(department.Id, true);
    	
    	Purchase_Request__c purchaseRequest = TestUtilities.CreatePurchaseRequest(true);
    	
    	Budget_Allocation__c budgetAllocation = TestUtilities.createBudgetAllocation(budget.Id, purchaseRequest.Id, null, false);
    	budgetAllocation.Allocation_Amount__c = 100;
    	budgetAllocation.Allocation_Date__c = system.today();
    	insert budgetAllocation;
    	
        // Insert the payment request
        Payment_Request__c paymentRequest = new Payment_Request__c(Vendor__c=acct.Id, Date_Submitted__c=system.today(), 
        															Payment_Amount__c=500, Invoice_Num__c='123',
        															Purchase_Request__c=purchaseRequest.Id,
        															Invoice_Received_Date__c=system.today(),
        															Invoice_Due_Date__c=system.today(),
        															Type__c='Direct to Vendor Payment', Products_Services__c='test',
        															Why_do_we_need_it__c='test', Submitted_by__c=UserInfo.getUserId(),
        															Type_of_Purchase__c='Supplies', Amount__c=500);
        insert paymentRequest;
        
        test.startTest();
        
        // insert the budget allocation
        Budget_Allocation__c budgetAllocation2 = new Budget_Allocation__c(Payment_Request__c = paymentRequest.Id, 
        																  Budget_Allocation__c = budgetAllocation.Id,
        																  Payment_Date__c = system.today(),
                                                                          Payment_Amount__c = 10,
                                                                          Budget_Line__c = budget.Id);
        insert budgetAllocation2;
        
        // verify that the department/department head on the payment request is updated
        paymentRequest = [SELECT Department__c, Department_Head__c, Budget_Manager__c, Total_Qx_Budget_Allocation_Amt__c
        				  FROM Payment_Request__c WHERE Id = :paymentRequest.Id LIMIT 1];
        system.assertEquals(department.Name, paymentRequest.Department__c);
        system.assertEquals(UserInfo.getUserId(), paymentRequest.Department_Head__c);
        system.assertEquals(budgetManagerUser.Id, paymentRequest.Budget_Manager__c);
        system.assertEquals(budgetAllocation.Allocation_Amount__c, paymentRequest.Total_Qx_Budget_Allocation_Amt__c);
        
        // get the payment request and verify the amount
        paymentRequest = [SELECT Id, Total_Budget_Allocation_Payment_Amount__c FROM Payment_Request__c WHERE Id = :paymentRequest.Id];
        system.assertEquals(10, paymentRequest.Total_Budget_Allocation_Payment_Amount__c);
        
        // update the payment amount
        budgetAllocation2.Payment_Amount__c = 500;
        update budgetAllocation2;
        
        test.stopTest();
        
        // get the payment request and verify the amount
        paymentRequest = [SELECT Id, Total_Budget_Allocation_Payment_Amount__c FROM Payment_Request__c WHERE Id = :paymentRequest.Id];
        system.assertEquals(500, paymentRequest.Total_Budget_Allocation_Payment_Amount__c);
    }
    
    static testmethod void budgetApproval_updatedBAPaymentRequest() {
    	
        Util.IsTest(true);
        
        // create a test user
        User budgetManagerUser = TestUtilities.CreateNewUser(true);
        
        Account acct = TestUtilities.CreateVendorAccount(true);
    	
    	Department__c department = TestUtilities.createDepartment(false);
    	department.Department_Head__c = UserInfo.getUserId();
    	department.Budget_Manager__c = budgetManagerUser.Id;
    	insert department;
    	
    	Budget__c budget = TestUtilities.createBudget(department.Id, true);
    	
    	Purchase_Request__c purchaseRequest = TestUtilities.CreatePurchaseRequest(true);
    	
    	Date q4Date = date.newInstance(2013, 11, 1);
        
        test.startTest();
        
        Budget_Allocation__c budgetAllocation = TestUtilities.createBudgetAllocation(budget.Id, purchaseRequest.Id, null, true);
    	
        // Insert the payment request
        Payment_Request__c paymentRequest1 = new Payment_Request__c(Vendor__c=acct.Id, Date_Submitted__c=system.today(), 
        															Payment_Amount__c=500, Invoice_Num__c='123',
        															Purchase_Request__c=purchaseRequest.Id,
        															Invoice_Received_Date__c=system.today(),
        															Invoice_Due_Date__c=system.today(),
        															Type__c='Direct to Vendor Payment', Products_Services__c='test',
        															Why_do_we_need_it__c='test', Submitted_by__c=UserInfo.getUserId(),
        															Type_of_Purchase__c='Supplies', Amount__c=500);
        
        insert paymentRequest1;
        
        // Insert the payment request
        Payment_Request__c paymentRequest2 = new Payment_Request__c(Vendor__c=acct.Id, Date_Submitted__c=system.today(), 
        															Payment_Amount__c=800, Invoice_Num__c='123',
        															Purchase_Request__c=purchaseRequest.Id,
        															Invoice_Received_Date__c=system.today(),
        															Invoice_Due_Date__c=system.today(),
        															Type__c='Direct to Vendor Payment', Products_Services__c='test',
        															Why_do_we_need_it__c='test', Submitted_by__c=UserInfo.getUserId(),
        															Type_of_Purchase__c='Supplies', Amount__c=800);
        insert paymentRequest2;
        
        Id paymentReqRTId = Util.RecordTypeId('Budget_Allocation__c', 'Budget Allocation Payment');
        
        // insert the budget allocation
        Budget_Allocation__c budgetAllocation2 = new Budget_Allocation__c(Payment_Request__c = paymentRequest1.Id,
        																  Budget_Allocation__c = budgetAllocation.Id,
        																  RecordTypeId = paymentReqRTId,
                                                                          Allocation_Amount__c = 10,
                                                                          Payment_Date__c = q4Date,
                                                                          Budget_Line__c = budget.Id);
        insert budgetAllocation2;
        
        test.stopTest();
        
        // verify that the department/department head on the payment request is updated
        Payment_Request__c paymentRequest = [SELECT Department__c, Department_Head__c, Budget_Manager__c FROM Payment_Request__c WHERE Id = :paymentRequest1.Id LIMIT 1];
        system.assertEquals(department.Name, paymentRequest.Department__c);
        system.assertEquals(UserInfo.getUserId(), paymentRequest.Department_Head__c);
        system.assertEquals(budgetManagerUser.Id, paymentRequest.Budget_Manager__c);
        
        // update the budget allocation's payment request
        budgetAllocation2.Payment_Request__c = paymentRequest2.Id;
        update budgetAllocation2;
        
        // verify that the department/department head on the payment request is updated
        paymentRequest = [SELECT Department__c, Department_Head__c, Budget_Manager__c FROM Payment_Request__c WHERE Id = :paymentRequest2.Id LIMIT 1];
        system.assertEquals(department.Name, paymentRequest.Department__c);
        system.assertEquals(UserInfo.getUserId(), paymentRequest.Department_Head__c);
        system.assertEquals(budgetManagerUser.Id, paymentRequest.Budget_Manager__c);
    }
    
}