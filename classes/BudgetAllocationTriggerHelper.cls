/*
	Purpose: 	This class is helper class for trigger on Budget Allocation
				
	Create By: 	Victor Hanson
	
	Created Date: 	09/09/2013
	
	Current Version: 	v1.0
	
	Revision Log:	V1.0 Created
*/
public with sharing class BudgetAllocationTriggerHelper {
	
	// Total pymt amt for all budget allocations associated with the same pymt req written to payment request.total budget allocation payment amount
	// also, total pymt amt for all budget allocations related to the same budget alocation in the Budget Alocation's Qx field based on Payment Quarter
	public static void CalcTotalBudgetPayment(List<Budget_Allocation__c> triggerNew, map<Id, Budget_Allocation__c> oldMap, boolean isDelete) {
		
		Set<Id> paymentReqIdSet = new Set<Id>();
		Set<id> budgetAllocationIdSet = new Set<Id>();
		List<Payment_Request__c> paymentRequestsToUpdate = new List<Payment_Request__c>();
		List<Budget_Allocation__c> budgetAllocationsToUpdate = new List<Budget_Allocation__c>();
		// in case this is a delete, we must create an empty list
        if (triggerNew == null) triggerNew = new List<Budget_Allocation__c>();
		
		for (Budget_Allocation__c newAllocation : triggerNew) {
            boolean recalculateAmt = false;
            Budget_Allocation__c oldAllocation;
            if (oldMap != null) oldAllocation = oldMap.get(newAllocation.Id);
            
            // if oldAllocation is null, this is an insert so we definitely need to recalculate
            if (oldAllocation == null) {
                recalculateAmt = true;
            }
            else { // this is an update
                if (newAllocation.Payment_Request__c != oldAllocation.Payment_Request__c || 
                	newAllocation.Budget_Allocation__c != oldAllocation.Budget_Allocation__c ||
                	newAllocation.Payment_Amount__c != oldAllocation.Payment_Amount__c)
                {
                    recalculateAmt = true;
                }
            }
            
            // if recalculate amount is true, figure out which ids to add to our Sets
            if (recalculateAmt) {
                if (newAllocation.Payment_Request__c != null) paymentReqIdSet.add(newAllocation.Payment_Request__c);
                if (newAllocation.Budget_Allocation__c != null) budgetAllocationIdSet.add(newAllocation.Budget_Allocation__c);
                // if the pymt req or allocation was changed from an existing value, recalculate
                if (oldAllocation != null) {
                	if (oldAllocation.Payment_Request__c != newAllocation.Payment_Request__c)
                	{
                		if (oldAllocation.Payment_Request__c != null)
                			paymentReqIdSet.add(oldAllocation.Payment_Request__c);
                	}
                	if (oldAllocation.Budget_Allocation__c != newAllocation.Budget_Allocation__c)
                	{
                		if (oldAllocation.Budget_Allocation__c != null )
                			budgetAllocationIdSet.add(oldAllocation.Budget_Allocation__c);
                	}
                }
            }
        }
        
        // Aggregate query to find:
        // total Payment_Amount__c FROM Budget Allocations where Payment Request IN :paymentReqIdSet GROUP BY Payment_Request__c
        // get a map of all payment requests
        Map<Id, Payment_Request__c> paymentReqMap = new Map<Id, Payment_Request__c>([SELECT Id, Total_Budget_Allocation_Payment_Amount__c 
        																			 FROM Payment_Request__c
        																			 WHERE Id IN :paymentReqIdSet]);
        List<AggregateResult> aggr = [SELECT Payment_Request__c, SUM(Payment_Amount__c) 
        							  FROM Budget_Allocation__c 
        							  WHERE Payment_Request__c != null AND Payment_Request__c IN :paymentReqIdSet
        							  GROUP BY Payment_Request__c];
        for (AggregateResult ar : aggr) {
        	Payment_Request__c pmtReq = paymentReqMap.get((string)ar.get('Payment_Request__c'));
        	pmtReq.Total_Budget_Allocation_Payment_Amount__c = (decimal)ar.get('expr0');
        	paymentRequestsToUpdate.add(pmtReq);
        }
        
        
        // query to find Payment Amount, Payment Quarter FROM Budget Allocation WHERE Id IN :budgetAllocatoinIdSet
        // create a map of maps to calculate Qx amount for each allocation.
        // Map<BudgetAllocationId, Map<Qx, Amount>>
        Map<Id, Map<String, Decimal>> baToQxAmtMap = new Map<Id, Map<String, Decimal>>();
        // query for all records
        Map<Id, Budget_Allocation__c> budgetAllocationMap = new Map<Id, Budget_Allocation__c>([
        													 SELECT Id, Payment_Amount__c, Payment_Quarter__c, Budget_Allocation__c,
        													 Q1_Payments__c, Q2_Payments__c, Q3_Payments__c, Q4_Payments__c
														     FROM Budget_Allocation__c 
														     WHERE Budget_Allocation__c IN :budgetAllocationIdSet OR Id IN :budgetAllocationIdSet]);
        for (Budget_Allocation__c ba : budgetAllocationMap.values()) {
        	// if the budget allocation field is null, continue
        	if (ba.Budget_Allocation__c == null) 
        		continue;
        	
        	Map<String, Decimal> quarterAmtMap = new Map<String, Decimal>();
        	// get the existing map
        	if (baToQxAmtMap.containsKey(ba.Budget_Allocation__c)) quarterAmtMap = baToQxAmtMap.get(ba.Budget_Allocation__c);
        	// find the quarter
        	decimal qxAmt = quarterAmtMap.get(ba.Payment_Quarter__c);
        	if (qxAmt == null) qxAmt = 0;
        	if (ba.Payment_Amount__c != null)
        	qxAmt += ba.Payment_Amount__c;
        	quarterAmtMap.put(ba.Payment_Quarter__c, qxAmt);
        	baToQxAmtMap.put(ba.Budget_Allocation__c, quarterAmtMap);
        }
        
        // update quarterly allocations
        for (Budget_Allocation__c ba : budgetAllocationMap.values()) {
        	Map<String, Decimal> qxAmtMap = new Map<String, Decimal>();
        	if (baToQxAmtMap.containsKey(ba.Id)) {
        		qxAmtMap = baToQxAmtMap.get(ba.Id);
        		ba.Q1_Payments__c = qxAmtMap.get('Q1');
        		ba.Q2_Payments__c = qxAmtMap.get('Q2');
        		ba.Q3_Payments__c = qxAmtMap.get('Q3');
        		ba.Q4_Payments__c = qxAmtMap.get('Q4');
        		budgetAllocationsToUpdate.add(ba);
        	}
        }
        system.debug('@@baToQxAmtMap:' + baToQxAmtMap);
        
        // update records we modified
        if (paymentRequestsToUpdate.size() > 0) {
        	update paymentRequestsToUpdate;
        }
        if (budgetAllocationsToUpdate.size() > 0) {
        	update budgetAllocationsToUpdate;
        }
		
	}
	
	// delete all allocations associated with a single budget allocation
	public static void deleteAllocations(list<Budget_Allocation__c> budgetAllocationList) {
		
		// if the bypass all triggers flag is set to true, return immediately
    	if (Util.BypassAllTriggers == true) return;
		
		set<Id> budgetAllocationsAlreadyForDelete = new set<Id>();
		set<Id> purchReqIdSet = new set<Id>();
		set<Id> budgetIdSet = new set<Id>();
		
		// get the unique set of budget allocations
		for (Budget_Allocation__c ba : budgetAllocationList) {
			
			purchReqIdSet.add(ba.Purchase_Request__c);
			budgetIdSet.add(ba.Budget_Line__c);
			budgetAllocationsAlreadyForDelete.add(ba.Id);
		}
		
		system.debug('@@budgetAllocationsAlreadyForDelete:' + budgetAllocationsAlreadyForDelete);
		
		// get allocations associated with these purch requests and budgets and whose id is not already in our list
		list<Budget_Allocation__c> allocationsToDelete = [SELECT Id
														  FROM Budget_Allocation__c
														  WHERE Purchase_Request__c IN :purchReqIdSet
														  AND Budget_Line__c IN :budgetIdSet
														  AND (Id NOT IN :budgetAllocationsAlreadyForDelete)];
		
		for (Budget_Allocation__c ba : allocationsToDelete) system.debug('@@del:' + ba.Id);
		
		if (allocationsToDelete.size() > 0) {
			
			// delete the allocations that were returned
			delete allocationsToDelete;
		}
	}
	
    // Calculate the total budget allocation amount and populate it on the associated Purchase or Payment Request
    public static void CalcTotalBudgetAllocation(List<Budget_Allocation__c> triggerNew, map<Id, Budget_Allocation__c> oldMap, boolean isDelete) {
        
        List<Purchase_Request__c> purchaseReqsToUpdate = new List<Purchase_Request__c>();
        Set<Id> purchaseReqIdSet = new Set<Id>();
        
        // in case this is a delete, we must create an empty list
        if (triggerNew == null) triggerNew = new List<Budget_Allocation__c>();
        
        for (Budget_Allocation__c ba : triggerNew) {
            boolean recalculateAmt = false;
            Budget_Allocation__c oldAllocation;
            if (oldMap != null) oldAllocation = oldMap.get(ba.Id);
            
            // if oldAllocation is null, this is an insert
            if (oldAllocation == null) {
                recalculateAmt = true;
            }
            else {
                if (ba.Allocation_Amount__c != oldAllocation.Allocation_Amount__c)
                {
                    recalculateAmt = true;
                }
            }
            
            // if recalculate amount is true, add to our set of Ids
            if (recalculateAmt) {
                if (ba.Purchase_Request__c != null) purchaseReqIdSet.add(ba.Purchase_Request__c);
            }
        }
        
        Set<Id> deletedBAIdSet = new Set<Id>();
        
        // if this is a deletion, add all budget allocations
        if (isDelete) {
            for (Budget_Allocation__c ba : oldMap.values()) {
                if (ba.Purchase_Request__c != null) purchaseReqIdSet.add(ba.Purchase_Request__c);
            }
            deletedBAIdSet = oldMap.keySet();
        }
        
        // add amts for purchase requests
        if (purchaseReqIdSet.size() > 0) {
            String purchaseReqQry = 'SELECT Id, Total_Budget_Allocation_Amount__c,';
            if (isDelete) {
                purchaseReqQry += 	'(SELECT Allocation_Amount__c, Q1_Allocation__c,Q2_Allocation__c,Q3_Allocation__c,Q4_Allocation__c FROM Purchase_Request_Budget_Allocations__r ' +
                					'WHERE NOT (Id IN :deletedBAIdSet)) ';
            }
            else {
                purchaseReqQry += '(SELECT Allocation_Amount__c, Q1_Allocation__c,Q2_Allocation__c,Q3_Allocation__c,Q4_Allocation__c FROM Purchase_Request_Budget_Allocations__r) ';
            }
            purchaseReqQry += 'FROM Purchase_Request__c WHERE Id in :purchaseReqIdSet';
            
            
            List<Purchase_Request__c> purchaseRequests = database.query(purchaseReqQry);
            for (Purchase_Request__c purchaseReq : purchaseRequests) {
                purchaseReq.Total_Budget_Allocation_Amount__c = getTotalAmt(purchaseReq.Purchase_Request_Budget_Allocations__r);
                purchaseReqsToUpdate.add(purchaseReq);
            }
        }
        
        if (purchaseReqsToUpdate.size() > 0) update purchaseReqsToUpdate;
        
    }
    
    // populate the Department Head on the Purchase or Payment Request associated with this budget allocation
    public static void PopulateDepartmentHead(List<Budget_Allocation__c> triggerNew, map<Id, Budget_Allocation__c> oldMap) {
        
    	// lists to hold our purchase / payment request updates
    	Map<Id, Purchase_Request__c> purchReqsMap = new Map<Id, Purchase_Request__c>();
    	Map<Id, Payment_Request__c> pmtReqsMap = new Map<Id, Payment_Request__c>();
    	
    	// set of budget ids
    	Set<Id> budgetIdSet = new Set<Id>();
    	
    	for (Budget_Allocation__c newBA : triggerNew) {
    		
    		// hold the old budget allocation if this is an update
    		Budget_Allocation__c oldBA;
    		if (oldMap != null) oldBA = oldMap.get(newBA.Id);
    		
    		if (oldBA == null || 
    			(newBA.Payment_Request__c != null && newBA.Payment_Request__c != oldBA.Payment_Request__c) ||
    			(newBA.Purchase_Request__c != null && newBA.Purchase_Request__c != oldBA.Purchase_Request__c) ||
    			(newBA.Department_Name__c != oldBA.Department_Name__c))
    		{
    			budgetIdSet.add(newBA.Id);
    		}
    	}
    	
    	// get all budgets and related department info
		List<Budget_Allocation__c> bAllocations = [SELECT Id, Purchase_Request__c, Payment_Request__c,
												   Budget_Line__r.Department__r.Department_Head__c,
												   Budget_Line__r.Department__r.Budget_Manager__c,
												   Budget_Line__r.Department__r.Name,
												   Budget_Allocation__r.Budget_Line__r.Department__r.Department_Head__c,
												   Budget_Allocation__r.Budget_Line__r.Department__r.Budget_Manager__c,
												   Budget_Allocation__r.Budget_Line__r.Department__r.Name
											       FROM Budget_Allocation__c 
											       WHERE Id IN :budgetIdSet 
											       AND (Budget_Line__r.Department__r.Department_Head__c != null
											       OR Budget_Allocation__r.Budget_Line__r.Department__r.Department_Head__c != null)];
        
		// map each payment or purchase request to a budget and prepare to update
		Map<Id, Id> requestToBudgetMap = new Map<Id, Id>();
		for (Budget_Allocation__c ba : bAllocations) {
            
			if (ba.Purchase_Request__c != null) {
				purchReqsMap.put(ba.Purchase_Request__c, new Purchase_Request__c(Id = ba.Purchase_Request__c,
															  Department_Head__c = ba.Budget_Line__r.Department__r.Department_Head__c,
															  Budget_Manager__c = ba.Budget_Line__r.Department__r.Budget_Manager__c));
			}
			if (ba.Payment_Request__c != null) {
				
				// determine the dept name/head and populate them on the payment request
				String deptName;
				Id deptHead, budgetManager;
				
				if (ba.Budget_Line__c != null) {
					
					deptName = ba.Budget_Line__r.Department__r.Name;
					deptHead = ba.Budget_Line__r.Department__r.Department_Head__c;
					budgetManager = ba.Budget_Line__r.Department__r.Budget_Manager__c;
				}
				else if (ba.Budget_Allocation__c != null) {
					
					deptName = ba.Budget_Allocation__r.Budget_Line__r.Department__r.Name;
					deptHead = ba.Budget_Allocation__r.Budget_Line__r.Department__r.Department_Head__c;
					budgetManager = ba.Budget_Allocation__r.Budget_Line__r.Department__r.Budget_Manager__c;
				}
				
				pmtReqsMap.put(ba.Payment_Request__c, new Payment_Request__c(Id = ba.Payment_Request__c, Department__c = deptName, 
																			 Department_Head__c = deptHead, Budget_Manager__c = budgetManager));
			}
		}
        
		// update the payment / purchase requests
		if (purchReqsMap.size() > 0) update purchReqsMap.values();
		if (pmtReqsMap.size() > 0) update pmtReqsMap.values();
    }
    
    public static void updatePaymentAllocationQuarters(list<Budget_Allocation__c> triggerNew) {
    	
    	// list of budget allocations to update
    	list<Budget_Allocation__c> pmtBAsToUpdate = new list<Budget_Allocation__c>();
    	
    	// make sure there is only one budget allocation associated with all these BA Payments
    	set<Id> budgetIdSet = new set<Id>();
    	set<Id> allocationIdSet = new set<Id>();
    	for (Budget_Allocation__c ba : triggerNew) {
    		
    		if (!budgetIdSet.contains(ba.Budget_Line__c)) budgetIdSet.add(ba.Budget_Line__c);
    		if (!allocationIdSet.contains(ba.Id)) allocationIdSet.add(ba.Id);
    	}
    	
    	if (budgetIdSet.size() == 1) {
    		
    		map<string, decimal> qxToAllocationAmtMap = getQxToAllocationAmtMap(triggerNew[0]);
    		
    		// get all payment request budget allocations associated with this purchase request
    		list<Budget_Allocation__c> pmtReqBudgetAllocations = [SELECT Id, Payment_Date__c,
    															   Q1_Allocation__c, Q2_Allocation__c, Q3_Allocation__c, Q4_Allocation__c
			    												   FROM Budget_Allocation__c
			    												   WHERE Budget_Allocation__c IN :allocationIdSet];
			
			// set the Qx allocation amt on each payment req budget allocation
			for (Budget_Allocation__c pmtAllocation : pmtReqBudgetAllocations) {
				
				// set the allocation amt for each quarter
				pmtAllocation = populateQxAmt(pmtAllocation, qxToAllocationAmtMap);
				
				// add to update list
				pmtBAsToUpdate.add(pmtAllocation);
			}
    	}
    	
    	// update the list of payment request budget allocations
    	if (pmtBAsToUpdate.size() > 0)
    		update pmtBAsToUpdate;
    }
    
    // when a budget allocatoin is updated, find any payment requests related to its purchase request
    // and update the total Qx amount
    public static void updatePaymentRequestQxAmount(list<Budget_Allocation__c> triggerNew, list<Budget_Allocation__c> triggerOld) {
    	
    	// if this is a delete trigger, use the old map
    	if (triggerNew == null) triggerNew = triggerOld;
    	
    	// set of purchase request ids
    	set<Id> purchaseReqIdSet = new set<Id>();
    	
    	for (Budget_Allocation__c ba : triggerNew) {
    		
			// get the purchase request associated with all of these budget allocations
			purchaseReqIdSet.add(ba.Purchase_Request__c);
    	}
    	
    	// query for all payment requests associated with these purchase requests
    	list<Payment_Request__c> pmtRequests = [SELECT Id, Invoice_Due_Date__c, Amount__c, Purchase_Request__c, Total_Qx_Budget_Allocation_Amt__c
    											FROM Payment_Request__c 
    											WHERE Purchase_Request__c IN :purchaseReqIdSet
    											AND Purchase_Request__c != null];
    	
    	// submit these payment requests to be updated with the latest Total Qx Amt
    	PaymentRequestTriggerHelper.calculateTotalBudgetPaymentAmount(pmtRequests, true);
    }
    
    // populate the Qx Allocation fields on the Payment Request budget allocation
    public static Budget_Allocation__c populateQxAmt(Budget_Allocation__c pmtAllocation, map<string, decimal> qxToAllocationAmtMap) {
    	
    	string yearString = string.valueOf(pmtAllocation.Payment_Date__c.Year());
		
		// set the allocation amt for each quarter
		pmtAllocation.Q1_Allocation__c = qxToAllocationAmtMap.get(yearString + 'Q1');
		pmtAllocation.Q2_Allocation__c = qxToAllocationAmtMap.get(yearString + 'Q2');
		pmtAllocation.Q3_Allocation__c = qxToAllocationAmtMap.get(yearString + 'Q3');
		pmtAllocation.Q4_Allocation__c = qxToAllocationAmtMap.get(yearString + 'Q4');
		
		return pmtAllocation;
    }
    
    // map of purchase requests like map<YYYY"Q"+Q#, totalAllocationAmt>
    public static map<string, decimal> getQxToAllocationAmtMap(Budget_Allocation__c budgetAllocation) {
    	
    	// create the map
    	map<string, decimal> qxToAllocationAmtMap = new map<string, decimal>();
    	
    	// get the budget
    	Budget__c budget = getBudgetWithBLines(budgetAllocation.Budget_Line__c)[0];
    	
    	// get allocation item wrappers
		list<AllocationLineItemHelper.AllocationWrapper> AllocationWrappers = AllocationLineItemHelper.getItemWrappers(budget, budgetAllocation);
		
		// create the map based on the quarter
		for (AllocationLineItemHelper.AllocationWrapper wrapper : AllocationWrappers) {
			
			// create the key
			string yearQtrString = getYearQtrString(wrapper.BudgetAllocation.Allocation_Date__c);
			
			decimal amt = 0;
			
			if (qxToAllocationAmtMap.containsKey(yearQtrString)) amt = qxToAllocationAmtMap.get(yearQtrString);
			
			// add the amt
			if (wrapper.BudgetAllocation.Allocation_Amount__c != null) amt += wrapper.BudgetAllocation.Allocation_Amount__c;
			
			qxToAllocationAmtMap.put(yearQtrString, amt);
		}
		
		return qxToAllocationAmtMap;
    }
    
    // based on a list of budget allocations, return a map of Total Amt by Quarter by Purchase Request
    public static map<id, map<string, decimal>> getPurchReqToQxAllocationMap(list<Budget_Allocation__c> budgetAllocations) {
    	 
    	// create a map<Purchase Req Id, map<yyyyQx, Total Amt>>
		map<Id, map<string, decimal>> PurchReqToQxAllocationMap = new map<Id, map<string, decimal>>();
		
		// loop through each budget allocation
		for (Budget_Allocation__c ba : budgetAllocations) {
			
			// if the allocation amt is zero or null, skip processing
			if (ba.Allocation_Amount__c == null || ba.Allocation_Amount__c == 0) continue;
			
			// attempt to get the qxToAmt map
			map<string, decimal> qxToAmtMap = PurchReqToQxAllocationMap.get(ba.Purchase_Request__c);
			if (qxToAmtMap == null) qxToAmtMap = new map<string, decimal>();
			
			// create yyyyQx string based on the allocation date
			string yrQxString = getYearQtrString(ba.Allocation_Date__c);
			
			// attempt to get the qx value
			decimal qxAmt = qxToAmtMap.get(yrQxString);
			
			// set the qxAmt
			if (qxAmt != null) qxAmt += ba.Allocation_Amount__c;
			else qxAmt = ba.Allocation_Amount__c;
			
			// add to the qxAmtMap
			qxToAmtMap.put(yrQxString, qxAmt);
			system.debug('@@qxToAmtMap:' + qxToAmtMap);
			// add back to our map
			PurchReqToQxAllocationMap.put(ba.Purchase_Request__c, qxToAmtMap);
		}
		
		// return the map
		return PurchReqToQxAllocationMap;
    }
    
    // return string in format 2013Q1
    public static string getYearQtrString(Date d) {
    	
    	if (d == null) return null;
    	
    	return d.Year() + 'Q' + string.valueOf(AllocationLineItemHelper.getQuarter(d.Month()));
    }
    
    public static List<Budget__c> getBudgetWithBLines(Id budgetId) {
    	
    	List<Budget__c> budgets = [SELECT Id, CurrencyISOCode, Account_Name__c, Account_Number__c,
                                   Department__r.Department_Number__c, Department__r.Name, Department__r.Budget_Manager__r.Name,
                                   RecordType.DeveloperName,
	                                   (SELECT Id, Year__c, Month__c, Amount__c FROM Budget_Lines__r)
	                                    FROM Budget__c 
                                   WHERE Id = :budgetId 
                                   LIMIT 1];
        return budgets;
    }
    
    private static double getTotalAmt(List<Budget_Allocation__c> budgetAllocations) {
    	
        double totalAmt = 0;
        for (Budget_Allocation__c ba : budgetAllocations) {
        	
        	if (ba.Allocation_Amount__c != null)
            	totalAmt += ba.Allocation_Amount__c;
        }
        
        return totalAmt;
    }
}