/**
    Purpose         :   This trigger to handle all the processing for case object.(CR-20121127-1787)
                
    Create By       :  Simplyforce Technology
    
    Created Date    :   12/20/2011
    
    Current Version :    v1.2
    
    Revision Log    :   v1.0 - Created
                        v1.1 - New Method called for validate Agreement's Status on OSR - Bhavi Sharma - 10/26/2013 - CR-20130109-2089  
                        v1.2 - Modified By - Abhinav Sharma - 07/07/2014 - CR-20140618-5849 - Catch DML errors in triggers to reduce exception emails to SFAdmin
 **/
trigger Trigger_SignAgreement on echosign_dev1__SIGN_Agreement__c (after insert, after update) {
    
    try{
        //Check for the request type
        if(Trigger.isAfter) {
            
            //Check for the event type
            if(Trigger.isInsert || Trigger.isUpdate) {
                
                //call the helper class method to Update the Opportunity LOA Sent Date field
                AgreementTriggerHelper.updateLOASentOnOpportunity(Trigger.newMap, Trigger.oldMap);
                
                //New Code added - Bhavi Sharma - 10/26/2013 - CR-20130109-2089
                //Call the helper class method to Update the OSR Agreement Sent, Agreement Received & Status field
                AgreementTriggerHelper.validateAgreementStatusOnOSR(Trigger.new, Trigger.oldMap); 
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