/**
*  Description      :   Class to hold the logic related to the "Mass Edit Contracts" functionality.
*
*  Created By       :   Abhinav Sharma
*
*  Created Date     :   01/19/2015
*
*  Revision Logs    :   V_1.0 - Created
*
**/
public class MassEditContractsController {

    /*Properties*/
    
    //Variables to hold the records count's
    public Integer allRecordsSize {get; set;}
    
    //Collections and variables related to Contract ABC object
    public List<Contract__c> contracts {get; set;}
    public Contract__c contract {get; set;}
    
    //Variable to hold the records scope related details
    public String updateScope {get; set;}
  
    //Calling Constructor
    public MassEditContractsController() {
        
        //Memory allocation
        contracts = new List<Contract__c>();
        contract = new Contract__c();
        
        //Checking for the invoice billing schedule record ID value, in the URL as parameter
        if(!String.isBlank(ApexPages.currentPage().getParameters().get('id'))) {
            
            //Seeting defaults
            updateScope = 'selected';
        
            //Set to hold the selected contracts Ids strings
            transient Set<String> selectedContractIds = new Set<String>();
    
            //Splitting selected contract Ids from the URL
            for(String str : ApexPages.currentPage().getParameters().get('conid').split(','))
                selectedContractIds.add(str);
                
            //Checking set for its size value
            if(selectedContractIds.size() > 0) {
        
                //Querying and fetching contact records
                contracts = [Select Id, Main_Contact__c, Invoice_Contact__c From Contract__c Where Id IN : selectedContractIds
                                AND Invoice_Billing_Schedule__c =: ApexPages.currentPage().getParameters().get('id')];
            
                //Checking list for size value
                if(contracts.size() > 0) {
                
                    //Populating integer variable with all associated records count
                    allRecordsSize = [Select Count() FROM Contract__c 
                                        WHERE Invoice_Billing_Schedule__c =: ApexPages.currentPage().getParameters().get('id')];
                }
            }
        }
    }
    
    /**
    *   @description    :   Method to mass update the contracts ABC records with user selected contact lookup(s) values.
    *
    *   @args           :   void
    *
    *   @return         :   void
    *
    **/
    public void saveContracts() {
        try{
            if(updateScope != 'all') {
                for(Contract__c c : contracts) {
                    if(contract.Main_Contact__c != null) 
                        c.Main_Contact__c = contract.Main_Contact__c;
                    if(contract.Invoice_Contact__c != null)
                        c.Invoice_Contact__c = contract.Invoice_Contact__c;
                }
            } else {
                contracts = new List<Contract__c>();  
                if(String.isNotBlank(ApexPages.currentPage().getParameters().get('id'))) {
                    for(Contract__c con : [SELECT ID, Main_Contact__c, Invoice_Contact__c From Contract__c
                                              WHERE Invoice_Billing_Schedule__c =: ApexPages.currentPage().getParameters().get('id')]) {
                        
                        if(contract.Main_Contact__c != null) 
                            con.Main_Contact__c = contract.Main_Contact__c;
                        if(contract.Invoice_Contact__c != null)
                            con.Invoice_Contact__c = contract.Invoice_Contact__c;
                            
                        //Populating list with records
                        contracts.add(con);
                    }
                }  
            }
            
            //Checking list for size value
            if(contracts.size() > 0)
                update contracts;
                
        }catch(exception e) {
        
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, 'Error Occured while updating the contracts '+ e.getMessage());
            ApexPages.addMessage(myMsg);
        }
    }
    
    public void doCancel() {}
}