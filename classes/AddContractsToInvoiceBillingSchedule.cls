/*
    Purpose:    This class is to allow user to add multiple contracts at a time with a specific criteria.
    			Class created under the CR-20111021-173
                
    Create By:  Simplyforce Technology
    
    Created Date:   10//2011
    
    Current Version:    v1.0
						v1.1 - Modified By - Mahendra Swarnkar - CR-20160113-9513 - 4/1/2016 - updated the "addContracts()" method 
								to populate the default value for Division field on the basis of business line value on the 
								program associated with the contract ABC
    
    Revision Log:       
*/
public with sharing class AddContractsToInvoiceBillingSchedule { 
	
	//variable to hold the Invoice Bu=illing Schedule properties
	public Invoice_Billing_Schedule__c invoiceBillingSchedule{get; set;}
	public List<ContractABCWrapper> listContractABCWrapper{get; set;}
	
	//flag to check if error occured in transaction
	//This flag will be used on the page to check wheater we need to show the error or we can close the window
	//as this page is using as a pop up page
	public Boolean isErrorOccured{get; set;}
	public Boolean isSaveCalled{get; set;}
	
	//properties to handle sorting functionality
	//Declare variable sorting parameter and Sorting direction(ASC/DESC)
    public String sortDirection {get; set;}
    public String sortExp{get; set;}
    private String lastSortExp;
    
	//Default constructor for the class
	public AddContractsToInvoiceBillingSchedule(ApexPages.StandardController controller) {
		
		invoiceBillingSchedule = (Invoice_Billing_Schedule__c)controller.getRecord();
		
		//setup the initiale properties
		inIt();
	}
	
	//method to set up the initiale properties
	public void inIt() {
		
		//initialize the listContractABCWrapper
		listContractABCWrapper = new List<ContractABCWrapper>();
		isErrorOccured = false;
		isSaveCalled = false;
		
		//set the initial sorting parameters
		sortDirection = 'ASC';
		sortExp = 'Name';
		
		//populate list
		populateListContractABCWrapper();
	}
	
	//Prperty to hold the list of contract records matching specified criteria
	public void populateListContractABCWrapper() {
		
		listContractABCWrapper = new List<ContractABCWrapper>();
		
		//get the invoice billing scheduled record id from the URL
		if(invoiceBillingSchedule.Id != null) {
			
			//fecth the contracts records those have Status = "ATL"
			//Invoice Billing Schedule = Null
			//Payer Account = Current Invoice Billing Schedule's Institution id
			for(Contract__c contractABC : Database.query('Select Id, Name, Start__c, End__c, Invoice_Contact__c, Invoice_Contact__r.Name, Negotiated_Amount__C, CreatedDate'
															+ ' from Contract__c where Status__c = \'' +  Constants.STATUS_ATL + '\''
															+ ' AND Invoice_Billing_Schedule__c = null AND Payer_Account__c = '
															+ '\'' + invoiceBillingSchedule.Institution__c + '\' order by ' + sortExp + ' ' + sortDirection )) {
				
				//add the contract record in wrapper class list
				listContractABCWrapper.add(new ContractABCWrapper(false, contractABC));
				
			}
		}
	}
		
	//Wrapper class to hold the contract record information with selected flag
	public class ContractABCWrapper {
		
		//public properties
		public Boolean selected{get; set;}
		public Contract__c contractABC {get; set;}
		
		//constructor
		public ContractABCWrapper(Boolean selected, Contract__c contractABC) {
			this.selected = selected;
			this.contractABC = contractABC;
		}
	}
	
	//Add contracts to the Invoice billing schedule
	public void addContracts() {
		
		//create a savepoint to rolllback the transaction in case of exception
		SavePoint sp = Database.setSavePoint();
		
		try {
			
			//set the flag as true
			isSaveCalled = true;
			
			//Create a new list of Contract ABC records to be updated
			List<Contract__c> listContractABCRecords = new List<Contract__c>();
			
            //Added By - Mahendra Swarnkar - CR-20160113-9513 - 4/1/2016 
            //Set to hold the business values from programs associated with those Contract ABCs which are associated with LIS
            Set<String> setBusinessLineValues = new Set<String> ();
            
			//get the selected records from the listContractABCWrapper list
			for(ContractABCWrapper wrapper : listContractABCWrapper) {
				if(wrapper.selected == true) {
					
					//update the invoice billing schedule id field with the current invoice billing schedule id
					wrapper.contractABC.Invoice_Billing_Schedule__c = invoiceBillingSchedule.Id;
					
					//add the contract abc record in list to update the record
					listContractABCRecords.add(wrapper.contractABC);
				}
			}
                        
			//check for the list size and update the records in bulk
			if(listContractABCRecords.size() > 0)
				update listContractABCRecords;
			
            //Added By - Mahendra Swarnkar - CR-20160113-9513 - 4/1/2016 - Starts from here	
			//Query trough Contract records which are associated with lis 
            for(Contract__c contractABC : [Select Id, Program__r.Business_line__c, Program__c, (Select Id From Line_Item_Schedule__r limit 1) 
										   from Contract__c where Status__c = : Constants.STATUS_ATL
										   AND Invoice_Billing_Schedule__c =: invoiceBillingSchedule.Id 
                                           AND Payer_Account__c =: invoiceBillingSchedule.Institution__c ]){
                
				//Populating set with business line values and it will help in when to populate the default division value on the IBS
                if(contractABC.Line_Item_Schedule__r != null && contractABC.Line_Item_Schedule__r.size() > 0
                   && contractABC.Program__c != null && String.isNotBlank(contractABC.Program__r.Business_line__c)){
                	
                    setBusinessLineValues.add(contractABC.Program__r.Business_line__c);       
                }                         
            }
            
            //Check for the size
			if(setBusinessLineValues.size() > 0) {
				
				//Counters to hold the count for business line values "SW" and "CLN"
				Integer countSW ;
				Integer countCLN;
				
				//Loop through Business line values helde by by setBusinessLineValues
				for(String businessLine : setBusinessLineValues){
					
					//Check for the Business line values and update their respective counter
                    if(businessLine == 'SW'){
                        if(countSW != null)
                            countSW++;
                        else
                            countSW = 1;
                    }
						
					else{
                        if(businessLine == 'CLN'){
                            if(countCLN != null)
                                countCLN++;
                            else
                                countCLN = 1;
                        }
					}
				}
                
                //Hold the prior value Division field on the IBS
                String priorIBS_Division = invoiceBillingSchedule.Division__c;
                
                //Check for business line values
                //  1)If all Contract ABCs associated with an Invoice Billing Schedule have Business Line = CLN, then Division = CLN.
                //	2) If all Contract ABCs associated with an Invoice Billing Schedule have Business Line = SW, then Division = SW.
                //	3) If more than 1 type of value  - then default Division on the IBS to "ABC Corporate"
                //	4) If have Business Line values other than CLN and SW - then default Division on the IBS to "ABC Corporate"
                if(countSW != null && countSW == setBusinessLineValues.size())
                    invoiceBillingSchedule.Division__c = 'SW';
                else {
                    if(countCLN != null && countCLN == setBusinessLineValues.size())
                        invoiceBillingSchedule.Division__c = 'CLN';
                    else
                        invoiceBillingSchedule.Division__c = 'ABC Corporate';
                }
                
                //Check for the change of the division on IBS and then update IBS record
                if(priorIBS_Division != invoiceBillingSchedule.Division__c){
                    Util.BypassAllTriggers = true;
                    update invoiceBillingSchedule;
                    Util.BypassAllTriggers = false;
                    priorIBS_Division = null;
                }
            }
			//Added By - Mahendra Swarnkar - CR-20160113-9513 - 4/1/2016 - Ends here
			
		} catch(Exception e) {
			
			//rollback the complete transaction as teh exception occured
			database.rollback(sp);
			
			//add error on page
			ApexPages.addmessages(e);
			
			//set the error flag as true
			isErrorOccured = true;
		}
	}
	
	//sorting function
	public void setupSort() {
		if(sortDirection == 'ASC')
			sortDirection = 'DESC';
		else
			sortDirection = 'ASC';
			
		//populate the data
		populateListContractABCWrapper();
	}
}