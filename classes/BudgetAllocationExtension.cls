/*
	Purpose: 			Controller class for BudgetAllocation Page
				
	Create By: 			Victor Hanson
	
	Created Date: 		10/10/2013
	
	Current Version: 	v1.0
	
	Revision Log:		V1.0 Created
*/
public class BudgetAllocationExtension {

    public Budget_Allocation__c PurchaseBA { get; set; }
    public Budget_Allocation__c BudgetAllocation { get; set; }
    private String RecordTypeId { get; set; }
    private String RecordTypeName { get; set; }
    private String PID { get; set; }
    private String RetURL { get; set; }
    private final String PURCHASE_REQUEST_RT_Name = 'Purchase Request Budget Allocation';
    private final String PAYMENT_REQUEST_RT_NAME = 'Budget Allocation Payment';
    private final Id PURCHASE_REQUEST_RT_ID = util.RecordTypeId('Budget_Allocation__c', PURCHASE_REQUEST_RT_Name);
    private final Id PAYMENT_REQUEST_RT_ID = util.RecordTypeId('Budget_Allocation__c', PAYMENT_REQUEST_RT_NAME);
    
    public String DeptSearchString { get; set; }
    public String DeptId { get; set; }
    public String BudgetSearchString { get; set; }
    public String AcctNum { get; set; }
    public String AcctSearchString { get; set; }
    
    // get the Payment Request record associated with this Budget Allocation
    public Payment_Request__c PaymentRequest {
    	get {
    		
    		if ((BudgetAllocation.Payment_Request__c != null && PaymentRequest == null) || 
            (PaymentRequest != null && PaymentRequest.Id != BudgetAllocation.Payment_Request__c && BudgetAllocation.Payment_Request__c != null))
	        {
	            List<Payment_Request__c> paymentRequests = [SELECT Id, Invoice_Due_Date__c, Payment_Amount__c, Amount__c, Purchase_Request__c
	                                                        FROM Payment_Request__c 
	                                                        WHERE Id = :BudgetAllocation.Payment_Request__c
	                                                        LIMIT 1];
	            if (paymentRequests.size() > 0) {
	            	
	            	// set the payment request
	                PaymentRequest = paymentRequests[0];
	                
	                // if payment date is null, populate the invoice due date
	                if (budgetAllocation.Payment_Date__c == null)
	                	BudgetAllocation.Payment_Date__c = PaymentRequest.Invoice_Due_Date__c;
	            }
	        }
	        
	        if (PaymentRequest == null) PaymentRequest = new Payment_Request__c();
	        
	        return PaymentRequest;
    	}
    	set;
    }
    
    // get the Purchase Request record associated with this Budget Allocation
    public Purchase_Request__c PurchaseRequest {
    	get {
    		
    		if ((BudgetAllocation.Purchase_Request__c != null && PaymentRequest == null) || 
            (PaymentRequest != null && PaymentRequest.Id != BudgetAllocation.Purchase_Request__c && BudgetAllocation.Purchase_Request__c != null))
	        {
	            List<Purchase_Request__c> purchaseRequests = [SELECT Id, Term_End_Date__c
	                                                        FROM Purchase_Request__c 
	                                                        WHERE Id = :BudgetAllocation.Purchase_Request__c
	                                                        LIMIT 1];
	            if (purchaseRequests.size() > 0) {
	            	
	                PurchaseRequest = purchaseRequests[0];
	            }
	        }
	        
	        if (PurchaseRequest == null) PurchaseRequest = new Purchase_Request__c();
	        
	        return PurchaseRequest;
    	}
    	set;
    }
    
    public Department__c Department {
        get {
            if (DeptId != null) {
                Department = new Department__c();
                List<Department__c> departments = [SELECT Id, Department_Number__c
                               FROM Department__c 
                               WHERE Id = :DeptId];
                if (departments.size() > 0) Department = departments[0];
            }
            return Department;
        }
        set;
    }
    
    public List<SelectOption> AccountOptions {
    	get {
    		if (AccountOptions == null) AccountOptions = new List<SelectOption>();
    		
    		if (DeptId != null) {
    			
    			// set of Ids so we don't include dupes in our list
    			set<string> acctSet = new set<string>();
    			
    			// clear out the existing options
    			AccountOptions.clear();
    			
    			// add a blank option
    			AccountOptions.add(new SelectOption('', ''));
    			List<AggregateResult> aggr = [SELECT Id, Account_Number__c, Account_Name__c 
    										  FROM Budget__c  
    										  WHERE Department__c = :DeptId AND Account_Number__c != null
    										  GROUP BY Account_Name__c, Account_Number__c, Id];
    										  
    			for (AggregateResult ar : aggr) {
    				
    				// get the account number and name
    				string acctName = (String)ar.get('Account_Name__c');
    				string acctNumber = (String)ar.get('Account_Number__c');
    				
    				// do not add to the list of results if the account number is in our exclusion list
    				if (!budgetExclusionIdSet.contains(acctNumber)) {
	    				
	    				String displayName = acctName + ' - ' + acctNumber;
	    				
	    				// check to see if the account name and number already appear in the list
	    				if (!acctSet.contains(displayName)) {
	    					
	    					// add to the account picklist
		    				AccountOptions.add(new SelectOption(acctNumber, displayName));
		    				
		    				// add the account id to our set
		    				acctSet.add(displayName);
	    				}
    				}
    			}
    		}
    		return AccountOptions;
    	}
    	set;
    }
    
    public List<SelectOption> budgetOptions {
        get {
            if (budgetOptions == null) budgetOptions = new List<SelectOption>();
            
            if (DeptId != null && AcctNum != null) {
                budgetOptions.clear();
                budgetOptions.add(new SelectOption('', ''));
                List<Budget__c> budgetList = [SELECT Id, Name, Account_Name__c, Budget_Item__c FROM Budget__c WHERE Department__c = :DeptId AND Account_Number__c = :AcctNum];
                for (Budget__c b : budgetList) {
                	
                	string displayName = b.Name;
                	
                	// if there is budget item text, use that instead of the auto-generated budget line name
                	if (b.Budget_Item__c != null) displayName = b.Budget_Item__c;
                	
                	// add the budget line to the list
                	budgetOptions.add(new SelectOption(b.Id, displayName));
                }
            }
            return budgetOptions;
        }
        set;
    }
    
    // AllocationOptions
    public List<SelectOption> AllocationOptions {
    	get {
    		
    		if (AllocationOptions == null) AllocationOptions = new List<SelectOption>();
    		
    		// clear the allocation options
    		AllocationOptions.clear();
    		AllocationOptions.add(new SelectOption('', '--New--'));
    		if (PaymentRequest.Purchase_Request__c != null) {
    			
    			map<Id, Budget_Allocation__c> BudgetAllocationMap = PurchaseRequestExtension.getBudgetToAllocationMap(PaymentRequest.Purchase_Request__c);
	    		for (Budget_Allocation__c ba : BudgetAllocationMap.values()) AllocationOptions.add(new SelectOption(ba.Id, ba.Name));
    		}
    		return AllocationOptions;
    	}
    	set;
    }
    
    // query for all relevant budget allocation fields based on its ID
    public static Budget_Allocation__c getAllocation(Id allocationId) {
    	
    	Budget_Allocation__c retAllocation = new Budget_Allocation__c();
    	
    	List<Budget_Allocation__c> budgetAllocations = [SELECT Id, Purchase_Request__c, Q1_Allocation__c, Q2_Allocation__c, End_Date__c,
    							Q3_Allocation__c, Q4_Allocation__c, Q1_Payments__c, Q2_Payments__c, Q3_Payments__c, Q4_Payments__c, 
					            Percent_Q1_Allocation_Paid__c, Percent_Q2_Allocation_Paid__c, Percent_Q3_Allocation_Paid__c, 
					            Percent_Q4_Allocation_Paid__c, CurrencyISOCode, RecordTypeId, Budget_Line__r.OwnerId, Budget_Line__c,
					            Department_Name__c, Start_Date__c, Department_Number__c, Account_Name__c, Account_Number__c, Name, Budget_Manager__c,
					            Payment_Request__c, Payment_Date__c, Payment_Amount__c, Budget_Allocation__c, Budget_Line_Formula__c,
					            Budget_Approver__c, Fixed_Asset__c, 
					            Budget_Line__r.Department__r.Name, Budget_Line__r.Department__r.Id, Budget_Line__r.Account_Number__c
					            FROM Budget_Allocation__c 
					            WHERE Id = :allocationId LIMIT 1];
					            
    	if (budgetAllocations.size() > 0) retAllocation = budgetAllocations[0];
    	
    	return retAllocation;
    }
    
    public void RefreshAllocation() {
    	
    	// get the budget allocation record from the selected budget allocation
    	if (BudgetAllocation.Budget_Allocation__c != null) {
    		
    		// set the purchase budget allocation to the chosen purchase request allocation
    		PurchaseBA = getAllocation(BudgetAllocation.Budget_Allocation__c);
            
    		// get the Qx Allocation values from the purchase request Allocatoin
    		map<string, decimal> qxToAllocationAmtMap = BudgetAllocationTriggerHelper.getQxToAllocationAmtMap(PurchaseBA);
    		
    		// set the allocation amt for each Qx Allocation
			BudgetAllocation = BudgetAllocationTriggerHelper.populateQxAmt(BudgetAllocation, qxToAllocationAmtMap);
    		
    	}
    	else
    		PurchaseBA = BudgetAllocation;
    }
    
    public BudgetAllocationExtension(ApexPages.StandardController controller) {
        
        //Initialize Budget Allocation record
        BudgetAllocation = (Budget_Allocation__c)controller.getRecord();
        
        BudgetAllocation = getAllocation(BudgetAllocation.Id);
        
        // see if this is a clone action
        string clone = ApexPages.currentPage().getParameters().get('clone');
        if (clone == '1') BudgetAllocation = BudgetAllocation.clone();
        
        // if this is a payment budget allocation, see if there is a different budget allocation associated with this
        if (BudgetAllocation.Budget_Allocation__c != null) {
        	
            PurchaseBA = getAllocation(BudgetAllocation.Budget_Allocation__c);
        }
        else if (BudgetAllocation.Budget_Allocation__c == null) {
        	
        	PurchaseBA = BudgetAllocation;
        }
        
        // get parameters and populate either payment or purchase request field
        // set RetURL
        RetURL = ApexPages.currentPage().getParameters().get('retURL');
        if (RetURL == null) RetURL = '/';
        // set pid
        PID = ApexPages.currentPage().getParameters().get('PID');
        if (PID != null) {
            if (IsPurchaseRequest && BudgetAllocation.Purchase_Request__c == null) BudgetAllocation.Purchase_Request__c = PID;
            else if (!IsPurchaseRequest && BudgetAllocation.Payment_Request__c == null) BudgetAllocation.Payment_Request__c = PID;
        }
        
        // set department name and id
        if (BudgetAllocation.Budget_Line__c != null) {
	        DeptSearchString = BudgetAllocation.Budget_Line__r.Department__r.Name;
			DeptId = BudgetAllocation.Budget_Line__r.Department__r.Id;
			AcctNum = BudgetAllocation.Budget_Line__r.Account_Number__c;
        }
        
        // set the End Date to the term end date if this is a new budget allocation
        if (PurchaseRequest != null && BudgetAllocation.End_Date__c == null) BudgetAllocation.End_Date__c = PurchaseRequest.Term_End_Date__c;
    }
    
    // when a user selects a budget on the page, query for the details so we can display them immediately
    public Budget__c Budget {
        
        get {
            if (BudgetAllocation.Budget_Line__c != null && Budget == null ||
               BudgetAllocation.Budget_Line__c != null && Budget != null && Budget.Id != BudgetAllocation.Budget_Line__c) {
                List<Budget__c> budgets = BudgetAllocationTriggerHelper.getBudgetWithBLines(BudgetAllocation.Budget_Line__c);
                if (budgets.size() > 0) {
                	
                	// set the budget to the first budget returned
                	Budget = budgets[0];
                	
                	// populate the Qx Allocation Amounts for the given 
                }
            }
            return Budget;
        }
        set;
    }
    
    // redirect the user to the previous page
    public pageReference Cancel() {
        return new PageReference(RetURL);
    }
    
    public boolean SaveAndNew { 
    	get {
    		if (SaveAndNew == null) SaveAndNew = false;
    		return SaveAndNew;
    	}
    	set;
    }
    
    public pageReference Save() {
        
        // custom save validation when saving Budget Allocations on Payment Requests
        if (!IsPurchaseRequest) {
        	
            // payment amount cannot be more than payment request's amount
            if (PaymentRequest != null && BudgetAllocation.Payment_Amount__c > PaymentRequest.Amount__c) {
                ApexPages.addMessage( new ApexPages.Message( ApexPages.Severity.ERROR, 'The budgeted amount must be less than or equal to the total payment request amount') );
                return null;
            }
        }
        
        // list of budget allocations to upsert
        List<Budget_Allocation__c> allocations;
        
        // try to upsert the budget allocation
        try {
        	
        	// if this is a payment request budget allocation, add the budget allocation to the 
        	if (AllocationsToUpsert.size() == 0) {
        		
        		if (PurchaseBA.Budget_Line__c != null && BudgetAllocation.Budget_Line__c == null)
        			BudgetAllocation.Budget_Line__c = PurchaseBA.Budget_Line__c;
        			
        		AllocationsToUpsert.add(BudgetAllocation);
        	}
        	
	        // propogate any updated budget allocation info to all allocations
	        allocations = cloneAllocations();
        	
        	if (allocations.size() > 0)
        		upsert allocations;
        	
        	if (AllocationsToDelete.size() > 0) {
        		
        		// bypass the special deletion logic that should only apply to manual deletions of entire budget allocations
        		Util.BypassAllTriggers = true;
        		
        		// delete only the allocations that are no longer in the list
        		delete AllocationsToDelete;
        		
        		Util.BypassAllTriggers = false;
        	}
        }
        catch(DMLException ex) {
        	
            ApexPages.addMessage( new ApexPages.Message( ApexPages.Severity.ERROR, ex.getDMLMessage(0) ) );
            return null;
        }
        
        // if saveAndNew, bring them to a new budget allocation page
        if (SaveAndNew) {
        	
	        // ID of the budget allocation object
        	Id budgetAllocationId = '01IC0000000yH03';
        	
	        String encodedReturnURL = EncodingUtil.urlEncode(RetURL, 'UTF-8');
	        String SaveAndNewURL = '/setup/ui/recordtypeselect.jsp?ent=' + budgetAllocationId + 
        						   '&retURL=' + encodedReturnURL + '&save_new_url=%2Fa00%2Fe%3FretURL%3D' + encodedReturnURL;
        	return new PageReference(SaveAndNewURL);
        }
        else {
        	
	        // return the user to the updated record
	        return new PageReference('/' + allocations[0].Id);
        }
    }
    
    public List<Budget_Allocation__c> cloneAllocations() {
    	
    	List<Budget_Allocation__c> retAllocations = new List<Budget_Allocation__c>();
    	for (Budget_Allocation__c allocation : AllocationsToUpsert) {
    		
    		// make sure all allocations match
    		allocation.Purchase_Request__c = BudgetAllocation.Purchase_Request__c;
    		if (allocation.Id == null) allocation.Budget_Line__c = BudgetAllocation.Budget_Line__c;
    		allocation.Start_Date__c = BudgetAllocation.Start_Date__c;
    		allocation.End_Date__c = BudgetAllocation.End_Date__c;
    		retAllocations.add(allocation);
    	}
    	return retAllocations;
    }
    
    // set the record type ID if it's a new record and figure out if this is a new purchase request
    public boolean IsPurchaseRequest { 
        get {
        	
            if (IsPurchaseRequest == null) {
            	
                if (BudgetAllocation != null && BudgetAllocation.RecordTypeId != null) {
                	
                    if (BudgetAllocation.RecordTypeId == PURCHASE_REQUEST_RT_ID) IsPurchaseRequest = true;
                    else IsPurchaseRequest = false;
                }
                else {
                	
                    // get record type name parameter
                    RecordTypeName = ApexPages.currentPage().getParameters().get('RecordTypeName');
                    if (RecordTypeName != null && RecordTypeName.equalsIgnoreCase(PURCHASE_REQUEST_RT_Name)) {
                    	
                        RecordTypeId = PURCHASE_REQUEST_RT_ID;
                    }
                    else {
                    	
                        RecordTypeId = PAYMENT_REQUEST_RT_ID;
                    }
                    
                    if (RecordTypeId == PURCHASE_REQUEST_RT_ID) IsPurchaseRequest = true;
                    else IsPurchaseRequest = false; 
                    
                    // if this is a new record, set the record type id
                    BudgetAllocation.RecordTypeId = RecordTypeId;
                }
            }
            return IsPurchaseRequest;
        }
        set;
    }
    
    public void refreshAllocationLineItems() {
    	
    	RefreshAllocations = true;
    }
    
    private boolean RefreshAllocations {
    	
    	get {
    		
    		if (RefreshAllocations == null) RefreshAllocations = false;
    		return RefreshAllocations;
    	}
    	
    	set;
    }
    
    List<Budget_Allocation__c> AllocationsToDelete {
    	
    	get {
    		
    		if (AllocationsToDelete == null) AllocationsToDelete = new List<Budget_Allocation__c>();
    		return AllocationsToDelete;
    	}
    	
    	set;
    }
    
    set<Budget_Allocation__c> AllocationsToUpsert {
    	
    	get {
    		
    		if (AllocationsToUpsert == null) AllocationsToUpsert = new set<Budget_Allocation__c>();
    		return AllocationsToUpsert;
    	}
    	
    	set;
    }
    
    // get allocation item wrappers
    public List<AllocationLineItemHelper.AllocationWrapper> AllocationWrappers {
    	get {
    		
    		if (AllocationWrappers == null || AllocationWrappers.size() == 0 || RefreshAllocations == true) {
    			
    			List<AllocationLineItemHelper.AllocationWrapper> oldAllocationList = new List<AllocationLineItemHelper.AllocationWrapper>();
    			if (AllocationWrappers != null && AllocationWrappers.size() > 0) {
    				
    				// if this is a refresh, put the existing records in a map to be compared later
	    			// so we don't lose valuable info that was already entered
	    			oldAllocationList = AllocationWrappers.clone();
    			}
    			
    			// get allocation item wrappers
				AllocationWrappers = AllocationLineItemHelper.getItemWrappers(Budget, BudgetAllocation);
				
    			if (oldAllocationList.size() > 0) {
    				
	    			map<Date, AllocationLineItemHelper.AllocationWrapper> oldWrapperMap = new map<Date, AllocationLineItemHelper.AllocationWrapper>();
	    			map<Date, AllocationLineItemHelper.AllocationWrapper> newWrapperMap = new map<Date, AllocationLineItemHelper.AllocationWrapper>();
    				for (AllocationLineItemHelper.AllocationWrapper a : oldAllocationList) oldWrapperMap.put(a.BudgetAllocation.Allocation_Date__c, a);
    				for (AllocationLineItemHelper.AllocationWrapper a : AllocationWrappers) newWrapperMap.put(a.BudgetAllocation.Allocation_Date__c, a);
    				
    				// see if there is an existing wrapper for the old date
    				for (AllocationLineItemHelper.AllocationWrapper oldWrapper : oldWrapperMap.values()) {
    					
    					AllocationLineItemHelper.AllocationWrapper newWrapper = newWrapperMap.get(oldWrapper.BudgetAllocation.Allocation_Date__c);
    					
    					// replace the new version of this wrapper with the old version so we don't lose any allocation info
    					if (newWrapper != null) {
    						
    						
    						newWrapper.BudgetAllocation= oldWrapper.BudgetAllocation;
    						if (newWrapper.BudgetAllocation.Allocation_Amount__c == 0) newWrapper.BudgetAllocation.Allocation_Amount__c = null;
    						newWrapperMap.put(oldWrapper.BudgetAllocation.Allocation_Date__c, newWrapper);
    					}
    					else if (oldWrapper.BudgetAllocation.Id != null) {
    						
    						// if the oldWrapper item isn't in the new list and the old item is in the system, add to list to be deleted
    						AllocationsToDelete.add(oldWrapper.BudgetAllocation);
    					}
    				}
    				
    				// replace the 'new' list with this merged list
    				AllocationWrappers = newWrapperMap.values();
    			}
    			
    			// clear the lists first
    			AllocationsToUpsert.clear();
    			
    			// put each budget allocation in the upsert list
    			for (AllocationLineItemHelper.AllocationWrapper wrapper : AllocationWrappers) {
    				
    				if (!AllocationsToUpsert.contains(wrapper.BudgetAllocation)) {
    					
    					AllocationsToUpsert.add(wrapper.BudgetAllocation);
    				}
    			}
    			
    			// sort the items by Allocation Date
    			AllocationWrappers.sort();
    		}
    		
    		return AllocationWrappers;
    	}
    	set;
    }
    
    private set<string> budgetExclusionIdSet {
    	
    	get {
    		
    		if (budgetExclusionIdSet == null) {
    			
    			// create an empty set
    			budgetExclusionIdSet = new set<string>();
    			
    			// get all of the custom setting values
    			list<Budget_Exclusion__c> budgetExclusions = Budget_Exclusion__c.getall().values();
    			
    			// for each record, iterate through each number and add to our list
    			for (Budget_Exclusion__c bExclusion : budgetExclusions) {
    				
    				// turn the start / end exclusions to integers
    				integer exclusionStart = integer.valueOf(bExclusion.Exclusion_Start__c);
    				integer exclusionEnd = integer.valueOf(bExclusion.Exclusion_End__c);
    				
    				// continue if the exclusion Start is greater than exclusion end
    				if (exclusionStart > exclusionEnd) continue;
    				
    				for (integer i = exclusionStart; i < exclusionEnd; i++) {
    					
    					// convert the integer to a string (since account ids on budgets are stored as strings)
    					budgetExclusionIdSet.add(string.valueOf(i));
    				}
    			}
    		}
    		
    		// return the list of exclusions
    		return budgetExclusionIdSet;
    	}
    	
    	set;
    }
    
}