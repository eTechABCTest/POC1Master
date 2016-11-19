public class PurchaseRequestExtension{
    
    public Purchase_Request__c PurchaseRequest { get; set; }
    
    public list<Budget_Allocation__c> BudgetAllocations {
        get {
            
            if (BudgetAllocations ==  null) BudgetAllocations = new list<Budget_Allocation__c>();
            return BudgetAllocations;
        }
        set;
    }
    
    public PurchaseRequestExtension(ApexPages.StandardController controller) {
        
        //Query purchase request record 
        Id purchaseRequestId = controller.getId();
        PurchaseRequest = [SELECT Id, Name FROM Purchase_Request__c WHERE Id = :purchaseRequestId LIMIT 1];
        
        //Query the budget allocations
        BudgetAllocations.addAll(getBudgetToAllocationMap(purchaseRequestId).values());
    }
    
    public static map<Id, Budget_Allocation__c> getBudgetToAllocationMap(Id purchaseRequestId) {
            
            //Query the budget allocations
            list<Budget_Allocation__c> allBudgetAlocations = [SELECT Name, Id, Account_Name__c, Account_Number__c, Department_Name__c, 
                                 Department_Number__c, Start_Date__c, End_Date__c, Budget_Line__c, Budget_Line__r.Budget_Item__c, Budget_Line__r.RecordType.Name, Budget_Line__r.Name
                                 FROM Budget_Allocation__c WHERE Purchase_Request__c = :purchaseRequestId AND Purchase_Request__c != null
                                ORDER BY Start_Date__c DESC];
            
            //Create a map of budget line to budget allocation
            map<Id, Budget_Allocation__c> budgetToAllocationMap = new map<Id, Budget_Allocation__c>();
            for (Budget_Allocation__c ba : allBudgetAlocations) {
                
                if (!budgetToAllocationMap.containsKey(ba.Budget_Line__c)) budgetToAllocationMap.put(ba.Budget_Line__c, ba);
            }
            
            return budgetToAllocationMap;
    }
    
}