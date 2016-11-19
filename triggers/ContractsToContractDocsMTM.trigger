//v1.0 - Created
//V1.1 - v1.1 - Modified By - Abhinav Sharma - 07/07/2014 - CR-20140618-5849 - Catch DML errors in triggers to reduce exception emails to SFAdmin
trigger ContractsToContractDocsMTM on Contracts_to_Contract_Docs_MtM__c (after delete, after insert, after update) {
    try {
        if (trigger.isAfter && !trigger.isDelete) {
            // Add documents to the opportunities that are associated with these contracts.
            ContractsToContractDocsMTMUtilities.AddDocsToOpps(trigger.newMap);
        }
    //Catching DML Exceptions
    } catch(DMLException e) {

        //Add Error Message on Page
        if(Trigger.isDelete)
            Trigger.Old[0].addError(e.getDmlMessage(0));
        else
            Trigger.New[0].addError(e.getDmlMessage(0));

    //Catching all Exceptions
    } catch(Exception e) {

        //Add Error Message on Page
        if(Trigger.isDelete)
            Trigger.Old[0].addError(e.getMessage());
        else
            Trigger.New[0].addError(e.getMessage());
    }
}