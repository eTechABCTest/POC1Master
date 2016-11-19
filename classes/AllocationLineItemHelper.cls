/*
	Purpose: 			Helper class that is used in the BudgetAllocationExtension
				
	Create By: 			Victor Hanson
	
	Created Date: 		10/29/2013
	
	Current Version: 	v1.0
	
	Revision Log:		V1.0 Created
*/
public with sharing class AllocationLineItemHelper {
	
	public static final string CAPEX = 'CapEx';
	
	// wrapper class to hold allocation line items + additional info
	public class AllocationWrapper implements Comparable {
		
		//public Budget__c Budget { get; set; }
		public Budget_Line__c BudgetLine { get; set; }
		public Budget_Allocation__c BudgetAllocation { get; set; }
		public decimal Budgeted { get; set; }
		public integer MonthInt { get; set; }
		public String Month {
			
			get {
				
				if (Month == null && BudgetAllocation != null && BudgetAllocation.Allocation_Date__c != null) {
					
					MonthInt = BudgetAllocation.Allocation_Date__c.month();
					Month = monthIntToStringMap.get(MonthInt);
				}
				return Month;
			}
			
			set;
		}
		
		public AllocationWrapper(Budget_Line__c budgetLine, Budget_Allocation__c budgetAllocation) {
			
			this.BudgetLine = budgetLine;
			this.BudgetAllocation = budgetAllocation;
			if (BudgetLine != null)
				Budgeted = budgetLine.Amount__c;
		}
		
		// implement sorting feature
		public Integer compareTo(Object compareTo) {
			
	        AllocationWrapper wrapper = (AllocationWrapper) compareTo;
	        if (BudgetAllocation.Allocation_Date__c == wrapper.BudgetAllocation.Allocation_Date__c) return 0;
	        if (BudgetAllocation.Allocation_Date__c > wrapper.BudgetAllocation.Allocation_Date__c) return 1;
	        return -1;
	    }
	}
	
	// return a list of wrappers based on a Budget Allocation
	public static list<AllocationWrapper> getItemWrappers(Budget__c budget, Budget_Allocation__c budgetAllocation) {
		
		// start date
		Date startDate = budgetAllocation.Start_Date__c;
		if (startDate == null) startDate = system.today();
		
		// default end date
		Date endDate = budgetAllocation.End_Date__c;
		if (endDate == null) endDate = system.today();
		
		// list to hold our wrappers
		map<Date, AllocationWrapper> ItemWrapperMap = new map<Date, AllocationWrapper>();
		
		map<date, Budget_Line__c> dateToBudgetLine = new map<date, Budget_Line__c>();
		
		if (budget != null) {
			
			boolean isCapEx = false;
			if (budget.RecordType.DeveloperName == CAPEX) isCapEx = true;
			
			// put the budget line data in to a map
			for (Budget_Line__c bLine : budget.Budget_Lines__r) {
				
				// convert the year string to integer
				integer yearInt = integer.valueOf(bLine.Year__c);
				
				// get the month integer
				integer monthInt = monthNameToIntegerMap.get(bLine.Month__c);
				
				// if the year and month are populated, create the date
				if (yearInt != null && monthInt != null) {
					
					// create a new instance for each month
					date d = date.newInstance(yearInt, monthInt, 1);
					
					// add the date/budget line to our map
					dateToBudgetLine.put(d, bLine);
				}
			}
		
			// figure out how many wrappers we need
			integer numWrappers = startDate.monthsBetween(endDate) + 1;
			
			for (integer i = 0; i < numWrappers; i++) {
				
				Budget_Allocation__c tempAllocation = new Budget_Allocation__c();
				date allocationDate;
				
				allocationDate = startDate.toStartOfMonth().addMonths(i);
				
				// if the budget's record type is CapEx, only display quarterly instances
				if (isCapEx) {
					
					integer quarterInt = getQuarter(allocationDate.month());
					
					// date for that quarter
					if (quarterInt == 1) allocationDate = date.newInstance(allocationDate.year(), 3, 1);
					if (quarterInt == 2) allocationDate = date.newInstance(allocationDate.year(), 6, 1);
					if (quarterInt == 3) allocationDate = date.newInstance(allocationDate.year(), 9, 1);
					if (quarterInt == 4) allocationDate = date.newInstance(allocationDate.year(), 12, 1);
					
				}
				
				// make sure the allocation date isn't already in our map (especially in the CapEx scenario)
				if (!ItemWrapperMap.containsKey(allocationDate)) {
					
					// create a new allocation line item, calculate date, and add to list of wrappers
					tempAllocation.Allocation_Date__c = allocationDate;
					Budget_Line__c budgetLine = dateToBudgetLine.get(tempAllocation.Allocation_Date__c);
					ItemWrapperMap.put(tempAllocation.Allocation_Date__c, new AllocationWrapper(budgetLine, tempAllocation));
				}
			}
			
			if (budgetAllocation.Id != null) {
				
				// get all existing allocation line items for the purchase request
				List<Budget_Allocation__c> allocations = [SELECT Id, Allocation_Amount__c, Allocation_Date__c
														   FROM Budget_Allocation__c
														   WHERE Purchase_Request__c = :budgetAllocation.Purchase_Request__c
														   AND Budget_Line__c = :budget.Id];
				
				map<date, Budget_Allocation__c> dateToBudgetMap = new map<date, Budget_Allocation__c>();
				for (Budget_Allocation__c ba : allocations) dateToBudgetMap.put(ba.Allocation_Date__c, ba);
				
				for (AllocationWrapper tempWrapper : ItemWrapperMap.values()) {
					
					// see if we already have a wrapper -- if so, replace it with the existing budget allocation
					Budget_Allocation__c existingAllocation = dateToBudgetMap.get(tempWrapper.BudgetAllocation.Allocation_Date__c);
					if (existingAllocation != null) {
						
						tempWrapper.BudgetAllocation = existingAllocation;
					}
					
					if (tempWrapper.BudgetAllocation.Allocation_Amount__c == 0) tempWrapper.BudgetAllocation.Allocation_Amount__c = null;
						
				}
			}
		}
		
		// return list of wrappers
		return ItemWrapperMap.values();
	}
	
	// map to easily get the name of the month from the integer value
	public static Map<integer, String> monthIntToStringMap {
		
		get {
			
			if (monthIntToStringMap == null) {
				
				monthIntToStringMap = new Map<integer, String>();
				monthIntToStringMap.put(1, 'Jan');
				monthIntToStringMap.put(2, 'Feb');
				monthIntToStringMap.put(3, 'Mar');
				monthIntToStringMap.put(4, 'Apr');
				monthIntToStringMap.put(5, 'May');
				monthIntToStringMap.put(6, 'Jun');
				monthIntToStringMap.put(7, 'Jul');
				monthIntToStringMap.put(8, 'Aug');
				monthIntToStringMap.put(9, 'Sep');
				monthIntToStringMap.put(10, 'Oct');
				monthIntToStringMap.put(11, 'Nov');
				monthIntToStringMap.put(12, 'Dec');
			}
			return monthIntToStringMap;
		}
		set;
	}
	
	// map to easily get integer value of the month based on the 3-letter name
	public static Map<string, integer> monthNameToIntegerMap {
		
		get {
			
			if (monthNameToIntegerMap == null) {
				
				monthNameToIntegerMap = new Map<string, integer>();
				monthNameToIntegerMap.put('Jan', 1);
				monthNameToIntegerMap.put('Feb', 2);
				monthNameToIntegerMap.put('Mar', 3);
				monthNameToIntegerMap.put('Apr', 4);
				monthNameToIntegerMap.put('May', 5);
				monthNameToIntegerMap.put('Jun', 6);
				monthNameToIntegerMap.put('Jul', 7);
				monthNameToIntegerMap.put('Aug', 8);
				monthNameToIntegerMap.put('Sep', 9);
				monthNameToIntegerMap.put('Oct', 10);
				monthNameToIntegerMap.put('Nov', 11);
				monthNameToIntegerMap.put('Dec', 12);
			}
			return monthNameToIntegerMap;
		}
		set;
	}
	
	public static integer getQuarter(integer monthInt) {
		
		Integer remainder = math.mod(monthInt, 3);
		
	    integer quarter;
	    if (remainder > 0) quarter = (monthInt / 3) + 1;
	    else quarter = (monthInt / 3);
	    
	    return quarter;
	}
	
}