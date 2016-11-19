public with sharing class PaymentReqProcessController {
	
	// this is a dummy object only used so we could use the existing MultiSelectPicklist component to display & choose batches to print
	public SFDC_Change_Request__c ChangeRequest {
		get {
			if (ChangeRequest == null) ChangeRequest = new SFDC_Change_Request__c();
			return ChangeRequest;
		}
		set;
	}
	
	public final String ACTION_CREATE = 'Create';
	public final String ACTION_PRINT = 'Print';
	// name of the chosen action (create or print)
	public String ActionName { get; set; }
	public boolean AddExistingBatch { get; set; }
	public String ExistingBatchNum { get; set; }
	private Set<Id> PaymentReqListSet {
		get {
			if (PaymentReqListSet == null) PaymentReqListSet = new Set<Id>();
			return PaymentReqListSet;	
		}
		set;
	}
	public String SelectedBatches_Formatted { get; set; }
	
	public PaymentReqProcessController() {
		// get the list of IDs supplied in the format xxxxxxx,xxxxxxxx,xxxxxxx and add them to a set
		String ids = ApexPages.currentPage().getParameters().get('ids');
		if (ids != null && ids != '') {
			PaymentReqListSet.addAll((List<Id>)ids.split(','));
			ActionName = ACTION_CREATE;
			
			// initialize the paymentRequestWrapperMap and see if we have any invalid selections
			Map<Id, PaymentReqWrapper> wrappers = PaymentReqWrapperMap;
			
			if (PaymentReqListSet.size() > 0) {
				ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'Some of the selected records do not meet the criteria.'));
			}
		}
		
		// get the list of batch nums to print
		String batchNums = ApexPages.currentPage().getParameters().get('batches');
		if (batchNums != null) {
			batchNums = EncodingUtil.urlDecode(batchNums, 'UTF-8');
			// trim the bracket [] characters from the beginning and end of string
			batchNums = batchNums.subString(1,batchNums.length()-1);
			SelectedBatches_Formatted = batchNums;
			SelectedBatches = batchNums.split(', ');
		}
	}
	
	public List<SelectOption> ExistingBatches {
		get {
			if (ExistingBatches == null) {
				ExistingBatches = new List<SelectOption>();
				List<AggregateResult> groupedRequests = [SELECT Batch_Num__c
													     FROM Payment_Request__c
													     WHERE Batch_Num__c != null GROUP BY Batch_Num__c];
				ExistingBatches.add(new SelectOption('', ''));
				for (AggregateResult ar : groupedRequests) {
					String batchNum = (string)ar.get('Batch_Num__c');
				    ExistingBatches.add(new SelectOption(batchNum, batchNum));
				}
			}
			return ExistingBatches;
		}
		set;
	}
	
	public class PaymentReqWrapper {
		public Payment_Request__c PaymentRequest { get; set; }
		public list<Budget_Allocation__c> BudgetAllocations { get; set; }
		public boolean IsSelected { get; set; }
		public PaymentReqWrapper() { }
		public PaymentReqWrapper(Payment_Request__c paymentRequest, boolean isSelected) {
			this.PaymentRequest = paymentRequest;
			this.IsSelected = isSelected;
			
			// set the budget allocation
			if (PaymentRequest.Budget_Allocation_Payments__r.size() > 0) 
				BudgetAllocations = PaymentRequest.Budget_Allocation_Payments__r;
			else
				BudgetAllocations = new list<Budget_Allocation__c>();
		}
	}
	
	// generate a new batch number
	public String BatchNum {
		get {
			if (BatchNum == null) {
				BatchNum = GenerateBatchNum();
			}
			// if the user chose to add PRs to an existing batch, return that number
			if (AddExistingBatch == true && ExistingBatchNum != null && ExistingBatchNum != '') {
				BatchNum = ExistingBatchNum;
			}
			return BatchNum;
		}
		set;
	}
	
	public PageReference PrintToPDF() {
		// make sure at least one batch is chosen
		if (SelectedBatches.size() == 0) {
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'At least one batch must be selected.'));
			return null;
		}
		return null;
	}
	
	// set the batch number for the selected payment requests
	public PageReference GenerateBatch() {
		List<Payment_Request__c> paymentReqsToUpdate = new List<Payment_Request__c>();
		for (PaymentReqWrapper wrapper : PaymentReqWrappers) {
			if (wrapper.IsSelected) {
				wrapper.PaymentRequest.Batch_Num__c = BatchNum;
				paymentReqsToUpdate.add(wrapper.PaymentRequest);
			}
		}
		// make sure at least one payment request is selected
		if (paymentReqsToUpdate.size() == 0) {
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'At least one payment request must be selected.'));
			return null;
		}
		if (AddExistingBatch == true && (ExistingBatchNum == null || ExistingBatchNum == '')) {
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Please choose an existing batch number.'));
			return null;
		}
		
		try {
			update paymentReqsToUpdate;
		}
		catch(DMLException ex) {
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ex.getDmlMessage(0)));
			return null;
		}
		catch(Exception ex) {
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ex.getMessage()));
			return null;
		}
		
		// Add the new batch to the list of selected batches to print
		ChangeRequest.Work_Required__c = BatchNum;
		// reset the batch number
		BatchNum = null;
		// if the records updated properly, display the print area
		ActionName = ACTION_PRINT;
		// clear the list of payment requests so it refreshes in case the user wants to create additional batches
		PaymentReqWrapperMap = null;
		PaymentReqWrappers = null;
		
		return null;
	}
	
	// payment request wrapper map - used to track which payment requests need to be in the same batch
	private Map<Id, PaymentReqWrapper> PaymentReqWrapperMap {
		get {
			if (PaymentReqWrapperMap == null) {
				PaymentReqWrapperMap = new Map<Id, PaymentReqWrapper>();
				List<Payment_Request__c> PaymentRequests = [SELECT Vendor__c, Vendor__r.Name, Date_Submitted__c, Submitted_By__c, 
								   Amount__c, Invoice_Num__c, Purchase_Order_Num__c, Status__c, Reference_Num__c, 
								   Invoice_Received_Date__c, Invoice_Due_Date__c, Department__c, 
								   Purchase_Request__r.Term_Start_Date__c, Purchase_Request__r.Term_End_Date__c,
								     (SELECT Id, Account_Number__c, Department_Number__c, Department_Name__c, Payment_Amount__c 
								      FROM Budget_Allocation_Payments__r ORDER BY Department_Number__c)
								   FROM Payment_Request__c
								   WHERE Batch_Num__c = null AND Status__c LIKE 'Approved%' ORDER BY Amount__c DESC LIMIT 50];
				for (Payment_Request__c pr : PaymentRequests) {
					// if the PR was selected from the list view page, set isSelected to true
					if (PaymentReqListSet.contains(pr.Id)) {
						PaymentReqWrapperMap.put(pr.Id, new PaymentReqWrapper(pr, true));
						// remove PR ID from our list -- if we are left with any PR Ids we know that some were chosen that don't meet the criteria
						PaymentReqListSet.remove(pr.Id);
					}
					else
						PaymentReqWrapperMap.put(pr.Id, new PaymentReqWrapper(pr, false));
				}
			}
			return PaymentReqWrapperMap;
		}
		set;
	}
	
	// payment requests in each of the batches selected
	public List<PaymentReqWrapper> PaymentRequestsByBatchNum {
		get {
			
			PaymentRequestsByBatchNum = new list<PaymentReqWrapper>();
			
			list<Payment_Request__c> paymentRequests = [SELECT Vendor__c, Vendor__r.Name, Date_Submitted__c, Submitted_By__c, 
							   Amount__c, Department__c, Invoice_Num__c, Purchase_Order_Num__c, Status__c, Reference_Num__c, 
							   Invoice_Received_Date__c, Invoice_Due_Date__c, 
							   Purchase_Request__r.Term_Start_Date__c, Purchase_Request__r.Term_End_Date__c, 
							     (SELECT Id, Account_Number__c, Department_Number__c, Department_Name__c, Payment_Amount__c
								  FROM Budget_Allocation_Payments__r ORDER BY Department_Number__c ASC)
							   FROM Payment_Request__c
							   WHERE Batch_Num__c != null AND Batch_Num__c IN :SelectedBatches ORDER BY Batch_Num__c ASC];
			
			for (Payment_Request__c pmtReq : paymentRequests) {
				
				// add to our list of wrappers
				PaymentRequestsByBatchNum.add(new PaymentReqWrapper(pmtReq, false));
			}
			
			return PaymentRequestsByBatchNum;
		}
		set;
	}
	
	public List<PaymentReqWrapper> PaymentReqWrappers {
		get {
			if (PaymentReqWrappers == null) {
				PaymentReqWrappers = new List<PaymentReqWrapper>();
				if (PaymentReqWrapperMap != null)
					PaymentReqWrappers.addAll(PaymentReqWrapperMap.values());
			}
			return PaymentReqWrappers;
		}
		set;
	}
	
	public String TodaysDate {
        get {
            if (TodaysDate == null) {
                TodaysDate = system.now().format('MM/dd/yyyy');
            }
            return TodaysDate;
        }
        set;
    }
	
	public List<String> BatchIdStringList {
		get {
			BatchIdStringList = new List<String>();
			List<AggregateResult> groupedResults = [SELECT Batch_Num__c FROM Payment_Request__c WHERE Batch_Num__c != null GROUP BY Batch_Num__c];
			for (AggregateResult ar : groupedResults) {
				String batchId = (string)ar.get('Batch_Num__c');
				BatchIdStringList.add(batchId);
			}
			return BatchIdStringList;
		}
		set;
	}
	
	public List<String> SelectedBatches {
		get {
			if (SelectedBatches == null) SelectedBatches = new List<String>();
			if (ChangeRequest.Work_Required__c != null)
				SelectedBatches = ChangeRequest.Work_Required__c.split(';');
			return SelectedBatches;
		}
		set;
	}
	
	private static String GenerateBatchNum() {
		Integer batchNum;
		// get the payment request with the highest batch number
		List<Payment_Request__c> paymentRequests = [SELECT Batch_Num__c 
													FROM Payment_Request__c 
													WHERE Batch_Num__c != null ORDER BY Batch_Num__c DESC LIMIT 1];
		if (paymentRequests.size() > 0) {
			String batchNumString = paymentRequests[0].Batch_Num__c;
			// add 1 to the existing batch size
			Integer curNum = Integer.valueOf(batchNumString.split('-')[1]);
			batchNum = curNum + 1;
		}
		else
			batchNum = 1;
		
		String batchString = String.valueOf(batchNum);
		
		// add trailing zeros so the batchNumber has at least 8 characters total
		String zeroStr = '0';
		if (batchString.length() < 4) {
			integer numZeros = 4 - batchString.length();
			batchString = zeroStr.repeat(numZeros) + batchString;
		}
		
		// add todays date in format YYYYMMDD to the beginning
		String year = string.valueOf(Date.today().year());
		String month = string.valueOf(Date.today().month());
		if (month.length() < 2) month = zeroStr + month;
		String day = string.valueOf(Date.today().day());
		if (day.length() < 2) day = zeroStr + day;
		String dateString = year + month + day;
		
		batchString = dateString + '-' + batchString;
		
		return batchString;
	}
	
}