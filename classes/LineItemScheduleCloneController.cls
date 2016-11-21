//Modified By - Abhinav Sharma - 05/24/2014 - CR-20140321-4840
public class LineItemScheduleCloneController{
    
    //Variables
    public Contract__c contractABC { get; set; }
    public boolean isSuccess {
        get {
            if (isSuccess == null) isSuccess = false;
            return isSuccess;
        }
        set;
    }
    private set<Id> selectedContractIds { get; set; }
    public boolean selectValue { get; set; }
    public string selectAllType { get; set; }
    public boolean isChecked_LineItems { get; set; }
    
    //Calling Constructor
    public LineItemScheduleCloneController() {
        
        //Get the contract ABC Id from the page parameters
        string contractABCId = ApexPages.currentPage().getParameters().get('id');
                
        //Get the contract ABC record we are going to clone IBS records to
        contractABC = [SELECT Id, Invoice_Billing_Schedule__c, Name, Program_Acronym__c,
                        (SELECT Id, Name, Contract__c, Invoice_Amount__c, Invoice_Billing_Schedule_del__c, Invoice_Comment__c,
                         Invoice_Date__c, Line_Item_Comment__c, Line_Item_Comment_2__c, OriginalLineItemSchedule__c, SalesCreditNote__c,
                         Sales_Invoice__c, Solomon_Product_Code__c, Type__c, Amount__c, Validation__c FROM Line_Item_Schedule__r ORDER BY Invoice_Date__c ASC)  
                       FROM Contract__c WHERE Id = :contractABCId];
        
        getContractMap();
        
        //Checking for Invoice Billing Schedule attached on ContractsABC record
        if (contractABC.Invoice_Billing_Schedule__c == null) {
        
            //Return error to the VF Page
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'The Contract ABC record must contain an Invoice Billing Schedule'));
        
        } else if (contractABC.Line_Item_Schedule__r.size() == 0) {
        
            //Return error to the VF Page
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'The Contract ABC record must contain at least one Line Item Schedule'));
        }
        
        isChecked_LineItems = true;
    }
    
    //Save the line item schedules to the contract
    public pageReference save() {
        
        //get the record type for un-invoiced line items
        Id rtId = Schema.SObjectType.Line_Item_Schedule__c.RecordTypeInfosByName.get('Line Item Schedule').RecordTypeId;
        
        //List to hold the line item schedule records
        list<Line_Item_Schedule__c> lineItemSchedToInsert = new list<Line_Item_Schedule__c>();
        
        //clone the line item schedules from the chosen contract(s)
        for (ContractWrapper wrapper : selectedContractWrappers) {
            
            //Modified By - Abhinav Sharma - 05/24/2014 - CR-20140321-4840
            //loop through each line item schedule and clone / add to our insert list
            for (LineItemWrapper lineItemWrapper : wrapper.lineItems) {
                
                //Checking for the selected value
                if (lineItemWrapper.isSelected) {
                    lineItemWrapper.LineItem.Invoice_Amount__c = lineItemWrapper.LineItem.Amount__c;
                    lineItemWrapper.LineItem.Sales_Invoice__c = null;
                    lineItemWrapper.LineItem.RecordTypeId = rtId;
                    lineItemWrapper.LineItem.Invoiced__c = false;
                    lineItemSchedToInsert.add(lineItemWrapper.LineItem);
                }
            }
        }
        
        //Make sure there is at least one record to clone
        if (lineItemSchedToInsert.size() == 0) {
            
            //Return errors to the VF Page
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'You must select at least one record to clone'));
            return null;
        }
        
        //save
        try {
        
            insert lineItemSchedToInsert;
        
        } catch(DMLException ex) {
        
            //Return errors to the VF Page
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ex.getDMLMessage(0)));
            return null;
        
        } catch(Exception ex) {
          
            //Return errors to the VF Page
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ex.getMessage()));
            return null;
        
        }
        
        //Reset our lists so we pull updated contract info
        contractWrappers = null;
        contractMap = null;
        
        //Saved successfully
        isSuccess = true;
        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM, 'Saved Successfully'));
        return null;
    }
    
    transient map<Id, Contract__c> contractMap { get; set; }
    
    //Get all contracts and related line item schedules with the same Invoice Billing Schedule
    private map<Id, Contract__c> getContractMap() {
        if (contractMap == null) {
            Id invBillingSched = contractABC.Invoice_Billing_Schedule__c;
            Id contractId = contractABC.Id;
            string queryString = 'SELECT Id, Name, Start__c, End__c, Program_Acronym__c, Historical_Linker__c, Negotiated_Amount__c, Line_Item_Schedule_Total__c,' +
                '(SELECT Id, Name, Contract__c, Invoice_Amount__c, Invoice_Billing_Schedule_del__c, Invoice_Comment__c,' +
                'Invoice_Date__c, Line_Item_Comment__c, Line_Item_Comment_2__c, OriginalLineItemSchedule__c, SalesCreditNote__c,' +
                'Sales_Invoice__c, Solomon_Product_Code__c, Type__c, Amount__c, Validation__c FROM Line_Item_Schedule__r) ' +
                'FROM Contract__c ' +
                'WHERE Invoice_Billing_Schedule__c = :invBillingSched AND Id != :contractId';
            if (selectedContractIds != null && selectedContractIds.size() > 0) queryString += ' AND Id IN :selectedContractIds';
            queryString += ' ORDER BY Start__c ASC';
            contractMap = new map<Id, Contract__c>((list<Contract__c>)database.query(queryString));
        }
        return contractMap;
    }
    
    //Wrapper list
    public list<ContractWrapper> contractWrappers {
        get {
            if (contractWrappers == null) {
                contractWrappers = new list<ContractWrapper>();
                for (Contract__c contract : getContractMap().values()) contractWrappers.add(new ContractWrapper(contract, contractABC.Line_Item_Schedule__r));
            }
            return contractWrappers;
        }
        set;
    }
    
    public list<ContractWrapper> selectedContractWrappers {
        get {
        	selectedContractWrappers = new list<ContractWrapper>();
            for (ContractWrapper wrapper : contractWrappers) {
            	if (wrapper.isSelected) selectedContractWrappers.add(wrapper);
            }
            return selectedContractWrappers;
        }
        set;
    }
    
    //recalculate totals
    public void recalculateTotals() {
        for (ContractWrapper wrapper : selectedContractWrappers) {
            wrapper.total = null;
        }
    }
    
    //Wrapper Class for contracts
    public class ContractWrapper {
        
        //Properties
        public boolean isSelected { get; set; }
        public Id contractId { get; set; }
        public string contractName { get; set; }
        public string historicalLinker { get; set; }
        public string programAcronym { get; set; }
        public date startDate { get; set; }
        public date endDate { get; set; }
        public double negotiatedAmount { get; set; }
        public integer numLineItems { get; set; }
        public double total {
            get {
                if (total == null) {
                    total = 0;
                    for (LineItemWrapper item : lineItems) {
                        if (item.lineItem.Amount__c != null)
                            total += item.lineItem.Amount__c;
                    }
                }
                return total;
            }
            set;
        }
        public double discrepancy {
            get {
                //just in case negotiated amt or total is null, default to zero
                if (negotiatedAmount == null)
                    negotiatedAmount = 0;
                if (total != null && negotiatedAmount != null)
                	discrepancy = total - negotiatedAmount;
                return discrepancy;
            }
            set;
        }
        public list<LineItemWrapper> lineItems {
        	get {
        		if (lineItems == null) lineItems = new list<LineItemWrapper>();
        		return lineItems;
        	}
        	set;
        }
        
        //Constructor
        public ContractWrapper(Contract__c contract, list<Line_Item_Schedule__c> originalLineItems) {
            this.isSelected = false;
            this.contractId = contract.Id;
            this.contractName = contract.Name;
            this.programAcronym = contract.Program_Acronym__c;
            this.historicalLinker = contract.Historical_Linker__c;
            this.startDate = contract.Start__c;
            this.endDate = contract.End__c;
            this.negotiatedAmount = contract.Negotiated_Amount__c;
            this.numLineItems = contract.Line_Item_Schedule__r.size();
            this.total = contract.Line_Item_Schedule_Total__c;
            this.lineItems = createLineItemWrappers(originalLineItems);
        }
        
        private list<LineItemWrapper> createLineItemWrappers(list<Line_Item_Schedule__c> items) {
			//loop through each line item schedule and clone / add to our list
            for (Line_Item_Schedule__c lineItemSched : items) {
	            
	            lineItems.add(new LineItemWrapper(lineItemSched, contractId));
	        }
	        return lineItems;
        }
    }
    
    //wrapper class for line items
    public class LineItemWrapper {
    	
    	//properties
    	public boolean isSelected { get; set; }
    	public Id originalLineItemId { get; set; }
    	public Line_Item_Schedule__c lineItem { get; set; }
    	
    	public LineItemWrapper(Line_Item_Schedule__c originalLineItem, Id contractId) {
    		this.originalLineItemId = originalLineItem.Id;
			this.lineItem = cloneLineItem(originalLineItem, contractId);
            this.isSelected = true;
    	}
        
        //this constructor is used on the lineItemScheduleUpsertController
        public LineItemWrapper(Line_Item_Schedule__c originalLineItem, Id contractId, boolean cloneItem) {
    		this.originalLineItemId = originalLineItem.Id;
            if (cloneItem)
				this.lineItem = cloneLineItem(originalLineItem, contractId);
            else
                this.lineItem = originalLineItem;
            this.isSelected = true;
    	}
        
        private Line_Item_Schedule__c cloneLineItem(Line_Item_Schedule__c originalLineItem, Id contractId) {
            Line_Item_Schedule__c item = originalLineItem.clone();
            item.Contract__c = contractId;
            item.Invoice_Amount__c = item.Amount__c;
            item.Line_Item_Comment__c = null;
            item.Line_Item_Comment_2__c = null;
            item.Invoiced__c = false;
            return item;
        }
    }
    
    //toggle the selected values
    public void toggleSelected() {
        if (selectAllType != null) {
            if (selectAllType.equalsIgnoreCase('CONTRACTS')) {
                for (ContractWrapper contractWrapper : contractWrappers) {
                    contractWrapper.isSelected = selectValue;
                }
            }
            else if (selectAllType.equalsIgnoreCase('LINEITEMS')) {
                isChecked_LineItems = selectValue;
                for (ContractWrapper contractWrapper : contractWrappers) {
                    for (LineItemWrapper itemWrapper : contractWrapper.lineItems) {
                        itemWrapper.isSelected = selectValue;
                    }
                }
            }
            else if (selectAllType instanceof Id) {
                //toggle the value for all items in the selected row
                for (ContractWrapper contractWrapper : ContractWrappers) {
                    for (LineItemWrapper itemWrapper : contractWrapper.lineItems) {
                        if (itemWrapper.originalLineItemId == selectAllType) itemWrapper.isSelected = selectValue;
                    }
                }
                //recalculate totals once the proper items have been checked or un-checked
                recalculateTotals();
            }
        }
    }
    
    public boolean hasErrors {
        get {
            return (apexPages.getMessages() != null && apexPages.getMessages().size() > 0 && !isSuccess);
        }
        set;
    }
}