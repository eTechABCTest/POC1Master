/**
 *  Purpose         :   This Tirgger is used for pre and post insertion update of OSR record.
 *
 *  Created By      :   Bhavi Sharma
 *
 *  Created Date    :   09/20/2013
 *
 *  Current Version :   v1.0 - Created
                        V_1.1 - Bhavi Sharma - 01/27/2014 - Check the newly created OSR record and execute the batch to automate the Replacement or Deactivation
                        V_1.2 - Modified By - Abhinav Sharma - 07/07/2014 - CR-20140618-5849 - Catch DML errors in triggers to reduce exception emails to SFAdmin
                        V_1.3 - Mahendra Swarnakar - 09/16/2015 -CR-9236
 *
 **/
trigger Trigger_OSR on OSR__c (before insert, after insert) {

    try {
        
        //Check for event type
        if(Trigger.isBefore){
    
            //Check for request type
            if(Trigger.isInsert) {
    
                //Updated address fields on OSR if required
                OSRTriggerHelper.ProcessAddressUpdateRequest(Trigger.New, Trigger.oldMap);
                
                //Update OSR's Alert Finance field
                OSRTriggerHelper.updateOSRAlertFinance(Trigger.new);
                
                //populate Advisory profile field on the OSR - By- Mahendra Swarnakar - 09/16/2015 -CR-9236
                OSRTriggerHelper.populateDefaultAdvisoryProfile(Trigger.new);
                
            } else if(Trigger.isUpdate) {
                
                //Updated address fields on OSR if required
                OSRTriggerHelper.ProcessAddressUpdateRequest(Trigger.New, Trigger.oldMap);
            }
        }
    
        //Check for event type
        if(Trigger.isAfter){
    
            //Check for request type
            if(Trigger.isInsert) {
                
                //Send EchoSign agreement to Contact of OSR
                OSRTriggerHelper.sendAgreementForNewOSR(Trigger.new);
                
                //Added By Bhavi Sharma - 01/27/2014 - Check the newly created OSR record and execute the batch to automate the Replacement or Deactivation
                OSRTriggerHelper.ProcessRequest(Trigger.New);
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