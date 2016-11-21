/**
 *   Purpose         :   Trigger for Trigger_Syndicated_Study object.[CR-20140619-5855]
 *               
 *   Created By      :   Ajit Surana
 *   
 *   Created Date    :   07/10/2014
 *   
 *   Current Version :   v1.0
 *   
 *   Revision Log    :   V1.0 - Created
 **/
trigger Trigger_Syndicated_Study on Syndicated_Study__c (before update) {

    try {
    
        //Bypassing trigger on the basis of flag value
        if(Util.BypassAllTriggers) 
            return;
    
        //Checking for event type
        if(Trigger.isBefore) {
        
            //Checking for request type
            if(Trigger.isUpdate) {
                
                //Calling Helper class method to do the calculation for GPA field
                SyndicatedStudyTriggerHelper.updateGPAWithInteractionsProductGradeAverage(Trigger.new, Trigger.oldMap);
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