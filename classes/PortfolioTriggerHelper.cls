/*
    Purpose         :   This class is helper class for trigger on Portfolio.
                
    Create By       :   Jason Bennett
    
    Created Date    :   11/22/2013
    
    Current Version :   v1.0
                        V_1.1 - 01/24/2014 - Bhavi Sharma - Modified - CR-20140122-4316
                        V_1.2 - 02/26/2014 - Bhavi Sharma - Modified - CR-20140220-4557
                        V_1.3 - 06/04/2014 - Bhavi Sharma - Modified - CR-20140227-4667 - Updated CheckPortfolioForUnblocking method to  execute the batch only if it is not already sceduled
                        V_1.4 - 10/23/2014 - Colin McGloin - Modified - CR-20141008-7702 - Commented out UpdateBalanceInComdata method as it is no longer needed
    
*/
public class PortfolioTriggerHelper{
    
    /**
     *  @description    :   This method is to populate the Portfolio_Owner_Finance_Code__c field from the selected contact
     * 
     *  @args           :   List of portfolios
     * 
     *  @return         :   void
     * 
     **/
    public static void populatePortfolioData(List<Portfolio__c> portfilios) {
        
        //Create a set of Contacts. This will be used in fetching Portfolio_Owner_Finance_Code__c from database
        Set<Id> contactIds = new Set<Id>();
        
        //Loop through the records and set the Portfolio_Owner_Finance_Code__c
        for(Portfolio__c portfolio : portfilios) {
            if(portfolio.Card_Holder__c != null)
                contactIds.add(portfolio.Card_Holder__c);
        }
        
        //Query all teh contacts and prepare a map
        if(contactIds.size() > 0) {
            
            //Map to hold teh contact information, Key => Contact Id, Value = Contact record
            Map<Id, Contact> mapContacts = new Map<Id, Contact>([Select Id, Employee_Finance_Code__c from Contact where Id IN: contactIds]);
            
            //Loop through the records again and set the Owner Finance Code from User record
            for(Portfolio__c portfolio : portfilios) {
                if(portfolio.Card_Holder__c != null && mapContacts.containsKey(portfolio.Card_Holder__c))
                    portfolio.Portfolio_Owner_Finance_Code__c = mapContacts.get(portfolio.Card_Holder__c).Employee_Finance_Code__c;
            }
        }
    }
    
    
    /**
     *  @description    :   This method is to check if address need to  be updated in comdata
     * 
     *  @args           :   List of new portfolios, Mapof old Portfolios 
     * 
     *  @return         :   void
     * 
     * 
     * 
     **/
    public static void updateAddressInComdata(List<Portfolio__c> portfolios, Map<Id, Portfolio__c> mapOldPortfolios) {
        
        //Check if teh batch is already running, do not need to execute it again
        List<AsyncApexJob> aSyncJobs = [SELECT Id, JobItemsProcessed, TotalJobItems, NumberOfErrors, CreatedBy.Email FROM AsyncApexJob
                                                WHERE ApexClass.Name = 'Batch_UpdateCardHolderAddressInComdata' 
                                                    AND Status IN: CreditCardConstants.ASYNC_APEX_JOB_PENDING_STATUSES];
        
        //Check if any records is upfdated and address need to be updated in Comdata
        for(Portfolio__c payment : portfolios) {
            
            //Check if billing address flag is true
            if(payment.Billing_Address_Updated__c == true && mapOldPortfolios.get(payment.Id).Billing_Address_Updated__c == false) {
                
                //Check for the size
                if(aSyncJobs.size() == 0 && !test.isRunningTest()) {
                    
                    //Execute batch
                    Batch_UpdateCardHolderAddressInComdata batchJob = new Batch_UpdateCardHolderAddressInComdata();
                    database.executeBatch(batchJob, 1);
                }
                
                break;
            }
        }
    }
    
    /**
     *  @description    :   This method is to deactivate the card in Comadata if required 
     * 
     *  @args           :   List of new Credit cards and Map of old credit cards
     * 
     *  @return         :   void
     * 
     **/
    public static void deactivateCardInComdata(List<Portfolio__c> newPortfolios, Map<Id, Portfolio__c> mapOldPortfolio) {
        
        //Check if teh batch is already running, do not need to execute it again
        List<AsyncApexJob> aSyncJobs = [SELECT Id, JobItemsProcessed, TotalJobItems, NumberOfErrors, CreatedBy.Email FROM AsyncApexJob
                                                WHERE ApexClass.Name = 'Batch_BlockCards' 
                                                    AND Status IN: CreditCardConstants.ASYNC_APEX_JOB_PENDING_STATUSES];
       
        //Check if no batch is running, then if the batchneed to be executed
        for(Portfolio__c portfolio : newPortfolios) {
            
            //Check the status has been changed from Activated to Deactivated
            if(portfolio.Status__c == CreditCardConstants.PORTFOLIO_STATUS_DEACTIVATED 
                && portfolio.Status__c != mapOldPortfolio.get(portfolio.Id).Status__c
                && aSyncJobs.size() == 0) {
                
                //Execute the batch
                Batch_BlockCards batchJob = new Batch_BlockCards();
                database.executeBatch(batchJob, 1);
                
                //Break the loop
                break;
            }
        } 
    }
    
    /**
     *  @description    :   This method is to activate the card in Comadata if required 
     * 
     *  @args           :   List of new Credit cards and Map of old credit cards
     * 
     *  @return         :   void
     * 
     **/
    public static void activateCardInComdata(List<Portfolio__c> newPortfolios, Map<Id, Portfolio__c> mapOldPortfolio) {
        
        //Check if teh batch is already running, do not need to execute it again
        List<AsyncApexJob> aSyncJobs = [SELECT Id, JobItemsProcessed, TotalJobItems, NumberOfErrors, CreatedBy.Email FROM AsyncApexJob
                                                WHERE ApexClass.Name = 'Batch_UnblockUnderLimitsCards' 
                                                    AND Status IN: CreditCardConstants.ASYNC_APEX_JOB_PENDING_STATUSES];
       
        //Check if no batch is running, then if the batchneed to be executed
        for(Portfolio__c portfolio : newPortfolios) {
            System.debug('portfolio:::::'+ portfolio.Id + '-' + portfolio.Status__c + portfolio.Utilized_Balance__c);
            //Check the status has been changed from Activated to Deactivated
            if(portfolio.Status__c == CreditCardConstants.PORTFOLIO_STATUS_ACTIVATED 
                && portfolio.Status__c != mapOldPortfolio.get(portfolio.Id).Status__c
                && aSyncJobs.size() == 0) {
                
                //Execute the batch
                Batch_UnblockUnderLimitsCards batchJob = new Batch_UnblockUnderLimitsCards();
                database.executeBatch(batchJob, 1);
                
                //Break the loop
                break;
            }
        } 
    }
}