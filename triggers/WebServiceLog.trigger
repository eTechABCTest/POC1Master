/**
 * 	Purpose			:	Trigger to handle all teh pre and post processing operations for WSL
 * 
 * 	Created By		:
 * 
 * 	Created Date	:
 * 
 * 	Revision Logs	:	V_1.1 - 10/28/2015 - Bhavi Sharma - CR-20151023-9358 - deActivateCardANDPortfolio: This should only run if the Credit Card is active
 *
 **/ 
trigger WebServiceLog on Web_Service_Log__c (before insert, before update,after insert, after update) {
	
    try {
    
        if (Util.BypassAllTriggers) return;
        
        if(Trigger.isInsert || Trigger.isUpdate){
        	
        	//Trigger's before insert update operations
            WebServiceLogTriggerHelper.deactivateCard(Trigger.New);
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