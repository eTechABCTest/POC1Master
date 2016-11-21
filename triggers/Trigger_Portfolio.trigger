//Modified By - Abhinav Sharma - 07/07/2014 - CR-20140618-5849 - Catch DML errors in triggers to reduce exception emails to SFAdmin
//Modified By - Colin McGloin - 10/24/2014 - CR-20141008-7702 - Comment out calls to UpdateBalanceinComdata method
trigger Trigger_Portfolio on Portfolio__c (before insert, before update, after update) {

    try {
        if(Trigger.isBefore){
            
            if(Trigger.isInsert){
                
                //Populate owner Finance Code
                PortfolioTriggerHelper.populatePortfolioData(Trigger.New);
            }
        } else if(Trigger.isAfter){
            
            if(Trigger.isUpdate){
                
                //Check if Portfolio has been deactivated and it was activated aearlier Update the same in Comdata
                PortfolioTriggerHelper.deactivateCardInComdata(Trigger.New, Trigger.oldMap);
                
                //Check if Portfolio has been deactivated and it was activated aearlier Update the same in Comdata
                PortfolioTriggerHelper.activateCardInComdata(Trigger.New, Trigger.oldMap);
                
                //Check if address need to be updated in Comdata
                PortfolioTriggerHelper.updateAddressInComdata(Trigger.New, Trigger.oldMap);
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