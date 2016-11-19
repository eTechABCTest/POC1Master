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
private class Test_PurchaseRequestExtension{
	
    // add 2 budget allocations with the same budget associated with a purchase request
    // and assert that there is only 1 budget allocation displaying in the list(because we only want to display unique budget allocations in the related list)
    static testmethod void purchaseRequestExtension() {
        
        Account acct = TestUtilities.CreateVendorAccount(true);
    	
    	Department__c department = TestUtilities.createDepartment(true);
    	
    	Budget__c budget = TestUtilities.createBudget(department.Id, false);
        budget.Budget_Item__c = 'Budget Item Text';
        insert budget;
    	
    	Purchase_Request__c purchaseRequest = TestUtilities.CreatePurchaseRequest(true);
    	
        Budget_Allocation__c budgetAllocation = TestUtilities.createBudgetAllocation(budget.Id, purchaseRequest.Id, null, true);
        Budget_Allocation__c budgetAllocation2 = TestUtilities.createBudgetAllocation(budget.Id, purchaseRequest.Id, null, true);
        
        // create a standard controller
        ApexPages.standardController standardController = new ApexPages.standardController(purchaseRequest);
        
        // set the page
		test.setCurrentPage(Page.PurchaseRequest);
        
        // instantiate the controller with a few URL Params
        ApexPages.currentPage().getParameters().put('ID', purchaseRequest.id);
        PurchaseRequestExtension controller = new PurchaseRequestExtension(standardController);
        
        system.assertEquals(1, controller.BudgetAllocations.size());
        system.assertEquals('Budget Item Text', controller.BudgetAllocations[0].Budget_Line__r.Budget_Item__c);
    }
}