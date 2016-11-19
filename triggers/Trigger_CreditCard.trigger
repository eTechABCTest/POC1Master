/**
 *  Purpose         :   This is Trigger on Credit Card to send "Activate Card Request" to Comdata.
 *
 *  Created By      :   Bhavi Sharma
 *
 *  Created Date    :   10/12/2013
 *
 *  Current Version :   V_1.0 - Created
 *                  :   V_1.1 - Modified By - Abhinav Sharma - 07/07/2014 - CR-20140618-5849 - Catch DML errors in triggers to reduce exception emails to SFAdmin
 **/
trigger Trigger_CreditCard on Credit_Card__c (before update, after insert, after update) {

    try {
    
        //Check for request type
        if(Trigger.isBefore) {
     
            //Check event type
            if(Trigger.isUpdate){
     
                //Update any missing Encrypted Card Numbers
                CreditCardService.FixEncryptedCardNumber(Trigger.newMap);
            }
        
        } else if(Trigger.isAfter) {
    
            //Check for event type
            if(Trigger.isInsert) {
    
                //Call helper class methos to update the related OSR record status to In Progress
                CreditCardTriggerHelper.updateOSRToInProgress(Trigger.New);
            } else if(Trigger.isUpdate) {
    
                //Call helper class method to Activate Card
                CreditCardTriggerHelper.activateCardInComdata(Trigger.new, Trigger.oldMap);
                
                //Call helper class to deactivate the other cards when another card is activated
                CreditCardTriggerHelper.deactivateOtherCardsOnActivatingCard(Trigger.New, Trigger.oldMap);
    
            }
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