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
private class Test_BudgetAllocationExtension {
	
	// create a purchase request budget allocation with a date range of 2 years and verify a budget allocation is created for 
    // each month in that 2 year period (ie: 12x2 = 24 months)
    static testMethod void testPurchaseBudgetAllocation_TwoYears() {
        
        // create and insert department
    	Department__c department = TestUtilities.createDepartment(true);
    	
        // create and insert budget
    	Budget__c budget = TestUtilities.createBudget(department.Id, true);
    	
    	// create and insert purchase request with term end date 2 years in future and start date = next month
    	Purchase_Request__c purchaseRequest = TestUtilities.CreatePurchaseRequest(false);
    	purchaseRequest.Term_Start_Date__c = system.today().addMonths(1);
    	purchaseRequest.Term_End_Date__c = system.today().addYears(2);
    	insert purchaseRequest;
    	
        // Create an allocatoin record and get the standard controller
        //Budget_Allocation__c budgetAllocation = TestUtilities.createBudgetAllocation(budget.Id, purchaseRequest.Id, null, false);
        Budget_Allocation__c budgetAllocation = new Budget_Allocation__c();
        ApexPages.standardController standardController = new ApexPages.standardController(budgetAllocation);
        
        // set the page
		test.setCurrentPage(Page.BudgetAllocationEdit);
        
        // instantiate the controller with a few URL Params
        ApexPages.currentPage().getParameters().put('PID', purchaseRequest.id);
        ApexPages.currentPage().getParameters().put('recordtypename', 'Purchase Request Budget Allocation');
        BudgetAllocationExtension controller = new BudgetAllocationExtension(standardController);
        
        controller.BudgetAllocation.Budget_Line__c = budget.Id;
        
        // verify the start / end date match term start / term end
        //system.assertEquals(purchaseRequest.Id, controller.BudgetAllocation.Purchase_Request__c);
        controller.BudgetAllocation.Start_Date__c = purchaseRequest.Term_Start_Date__c;
        controller.BudgetAllocation.End_Date__c = purchaseRequest.Term_End_Date__c;
        
        // refresh allocation line items
        controller.refreshAllocationLineItems();
        
        // verify that there is a wrapper for each month for 2 years
        system.assertEquals(24, controller.AllocationWrappers.size());
        
        // give each allocation wrapper an allocation amount
        for (AllocationLineItemHelper.AllocationWrapper wrapper : controller.AllocationWrappers) {
            wrapper.BudgetAllocation.Allocation_Amount__c = 200.00;
        }
        
        // save the budget allocation(s)
        controller.Save();
        
        // query for all budget allocations
        list<Budget_Allocation__c> budgetAllocations = [SELECT Id, Allocation_Amount__c 
                                                        FROM Budget_Allocation__c 
                                                        WHERE Purchase_Request__c = :purchaseRequest.Id];
        
        // make sure we returned all 24 records
        system.assertEquals(24, budgetAllocations.size());
        system.assertEquals(200, budgetAllocations[0].Allocation_Amount__c);
    }
    
    // create a purchase req budget allocation and a payment request budget allocation.
    // verify the pymt req Qx amts stay consistent with the amts from the related purch req
    static testMethod void testPurchaseBudgetAllocation_WithPymtAllocation() {
        
        util.BypassAllTriggers = true;
        
        Account acct = TestUtilities.CreateVendorAccount(false);
        acct.Name = 'newVendor';
        insert acct;
        
        // create and insert department
    	Department__c department = TestUtilities.createDepartment(true);
    	
        // create and insert budget
    	Budget__c budget = TestUtilities.createBudget(department.Id, true);
    	
    	// create and insert purchase request with term end date 2 years in future and start date = next month
    	Purchase_Request__c purchaseRequest = TestUtilities.createPurchaseRequest(false);
    	purchaseRequest.Term_Start_Date__c = date.newInstance(system.today().year(), 1, 1);
    	purchaseRequest.Term_End_Date__c = date.newInstance(system.today().year(), 12, 1);
    	insert purchaseRequest;
    	
        // Create an allocatoin record and get the standard controller
        //Budget_Allocation__c budgetAllocation = TestUtilities.createBudgetAllocation(budget.Id, purchaseRequest.Id, null, false);
        Budget_Allocation__c budgetAllocation = new Budget_Allocation__c();
        ApexPages.standardController standardController = new ApexPages.standardController(budgetAllocation);
        
        // set the page
		test.setCurrentPage(Page.BudgetAllocationEdit);
        
        // instantiate the controller with a few URL Params
        ApexPages.currentPage().getParameters().put('PID', purchaseRequest.id);
        ApexPages.currentPage().getParameters().put('recordtypename', 'Purchase Request Budget Allocation');
        BudgetAllocationExtension controller = new BudgetAllocationExtension(standardController);
        
        controller.BudgetAllocation.Budget_Line__c = budget.Id;
        
        // verify the start / end date match term start / term end
        //system.assertEquals(purchaseRequest.Id, controller.BudgetAllocation.Purchase_Request__c);
        controller.BudgetAllocation.Start_Date__c = purchaseRequest.Term_Start_Date__c;
        controller.BudgetAllocation.End_Date__c = purchaseRequest.Term_End_Date__c;
        
        // refresh allocation line items
        controller.refreshAllocationLineItems();
        
        // verify that there is a wrapper for each month for 2 years
        system.assertEquals(12, controller.AllocationWrappers.size());
        
        // give each allocation wrapper an allocation amount
        for (AllocationLineItemHelper.AllocationWrapper wrapper : controller.AllocationWrappers) {
            wrapper.BudgetAllocation.Allocation_Amount__c = 200.00;
        }
        
        // save the budget allocation(s)
        controller.Save();
        
        
        // get the budget allocation we just inserted
        list<Budget_Allocation__c> purchBudgetAllocations = [SELECT Id FROM Budget_Allocation__c WHERE Purchase_Request__c = :purchaseRequest.Id];
        
        // query for all budget allocations
        list<Budget_Allocation__c> budgetAllocations = [SELECT Id, Allocation_Amount__c 
                                                        FROM Budget_Allocation__c 
                                                        WHERE Purchase_Request__c = :purchaseRequest.Id];
        
        // make sure we returned all 12 records
        system.assertEquals(12, budgetAllocations.size());
        system.assertEquals(200, budgetAllocations[0].Allocation_Amount__c);
        
        // Create a new pymt budget allocation
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
        
        Budget_Allocation__c pmtBudgetAllocation = new Budget_Allocation__c();
        
        // set the page
		test.setCurrentPage(Page.BudgetAllocationEdit);
        
        // instantiate the controller with a few URL Params
        ApexPages.currentPage().getParameters().put('PID', paymentRequest.id);
        ApexPages.currentPage().getParameters().put('recordtypename', 'Budget Allocation Payment');
        BudgetAllocationExtension pmtController = new BudgetAllocationExtension(standardController);
        
        // set the budget allocation
        pmtController.BudgetAllocation.Budget_Allocation__c = purchBudgetAllocations[0].Id;
        
        pmtController.RefreshAllocation();
        
        pmtController.BudgetAllocation.Payment_Amount__c = 100;
        pmtController.BudgetAllocation.Payment_Date__c = purchaseRequest.Term_Start_Date__c;
        
        system.debug('@@:' + pmtController.BudgetAllocation.Q1_Allocation__c);
        
        pmtController.Save();
        
        update purchBudgetAllocations;
        
        // get the pmt request budget allocation
        Budget_Allocation__c pmtReqBudgetAllocation = [SELECT Id, Q1_Allocation__c, Q2_Allocation__c 
												       FROM Budget_Allocation__c 
												       WHERE Budget_Allocation__c = :purchBudgetAllocations[0].Id];
        system.debug('@@pmtReqBudgetAllocation:' + pmtReqBudgetAllocation);
        system.assertEquals(600, pmtController.BudgetAllocation.Q1_Allocation__c);
    }
    
    // enter a budget exclusion and verify that the accounts are not available in the Budget Allocatoin Account picklist
    static testMethod void testBudgetExclusion() {
    	
    	// setup some basic objects
    	Account acct = TestUtilities.CreateVendorAccount(false);
        acct.Name = 'newVendor';
        insert acct;
        
        // create and insert department
    	Department__c department = TestUtilities.createDepartment(true);
    	
        // create and insert budget
    	Budget__c budget = TestUtilities.createBudget(department.Id, false);
    	Budget__c budget_Exclusion = TestUtilities.createBudget(department.Id, false);
    	budget.Account_Number__c = '300';
    	
    	// set the account number for this budget so it's included in the exclusion range
    	budget_Exclusion.Account_Number__c = '4000';
    	
    	// insert this lsit of budgets
    	insert new list<Budget__c> { budget, budget_Exclusion };
    	
    	// create and insert purchase request with term end date 2 years in future and start date = next month
    	Purchase_Request__c purchaseRequest = TestUtilities.createPurchaseRequest(false);
    	purchaseRequest.Term_Start_Date__c = date.newInstance(system.today().year(), 1, 1);
    	purchaseRequest.Term_End_Date__c = date.newInstance(system.today().year(), 12, 1);
    	insert purchaseRequest;
    	
    	// add an exclusion for account Id 4000 - 4999
    	Budget_Exclusion__c bExclusion = new Budget_Exclusion__c(name='Test', Exclusion_Start__c=4000, Exclusion_End__c=4999);
    	insert bExclusion;
    	
    	// Create an allocatoin record and get the standard controller
        //Budget_Allocation__c budgetAllocation = TestUtilities.createBudgetAllocation(budget.Id, purchaseRequest.Id, null, false);
        Budget_Allocation__c budgetAllocation = new Budget_Allocation__c();
        ApexPages.standardController standardController = new ApexPages.standardController(budgetAllocation);
        
        // set the page
		test.setCurrentPage(Page.BudgetAllocationEdit);
        
        // instantiate the controller with a few URL Params
        ApexPages.currentPage().getParameters().put('PID', purchaseRequest.id);
        ApexPages.currentPage().getParameters().put('recordtypename', 'Purchase Request Budget Allocation');
        BudgetAllocationExtension controller = new BudgetAllocationExtension(standardController);
        
        // set the department name manually
        controller.DeptId = department.Id;
        
        // get the list of accounts for this department
        list<SelectOption> acctOptions = controller.AccountOptions;
        
        // verify there is only 2 option in the list - a blank value, and our budget with acct num = 300
        system.assertEquals(2, acctOptions.size());
        system.assertEquals('', acctOptions[0].getValue());
        system.assertEquals(budget.Account_Number__c, acctOptions[1].getValue());
    }
}