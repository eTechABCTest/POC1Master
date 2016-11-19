/**
    Purpose         :   This trigger to handle all the processing for case object.(CR-20111219-287)
                
    Create By       :   Simplyforce Technology
    
    Created Date    :   12/24/2011
    
    Revision Logs   :   V_1.0 - Created
                        V_1.1 - Trigger refactored and added logic for CR-20130109-2074    
                        v_1.2 - Added reference to syncCaseToMemberSupport method CR-4283 
                        v_1.3 - Modified By - Abhinav Sharma - 06/19/2014 - CR-20140417-5120  
                        v_1.4 - Modfied By - Abhinav Sharma - 07/03/2014 - CR-20140618-5845
                        v_1.5 - Modified By - Abhinav Sharma - 07/07/2014 - CR-20140618-5849 - Catch DML errors in triggers to reduce exception emails to SFAdmin
                        v_1.6 - Modified By - Abhinav Sharma - 10/15/2014 - CR-20141001-7574
 **/
trigger Trigger_Case on Case (before insert, before update, after insert, after update) {
    
    try {
    
        if (Util.BypassAllTriggers) return;
        
        //Checking for the event
        if (trigger.isBefore) {
            
            //Checking for the request type
            if(Trigger.isInsert || Trigger.isUpdate) {
                
                //Populate data from Case -> MS record CR-4283
                CaseTriggerHelper.syncCaseToMemberSupport(Trigger.New, Trigger.oldMap);
                
                //Calling Helper class method to do the validation and then populating fields on case records
                CaseTriggerHelper.beforeEventsLogicHandler(Trigger.New, Trigger.oldMap);
                
                //If the Resolution Summary field is updated and Status = 'Solution Provided', post the resolution to comments
                CaseTriggerHelper.postResolutionToComments(Trigger.New, Trigger.oldMap);
        	}
        }            
        
        //Added By - Abhinav Sharma - 06/19/2014 - CR-20140417-5120
        //Checking for event type
        if(Trigger.isAfter) {
            
            //Checking for request type
            if(Trigger.isInsert) {
            
                //Calling helper class method
                CaseTriggerHelper.populateCaseFromEmailToCase(Trigger.newMap.keySet());
                
                //Calling Helper class method to deleted out the "Out of Office" Type case records
                CaseTriggerHelper.deletedOutOutOfOfficeCases(Trigger.newMap.keySet());
                
            }
            
            //Added By - Abhinav Sharma - 10/15/2014 - CR-20141001-7574
            //Checking for the request type
            if(Trigger.isInsert || Trigger.isUpdate) {
                
                //Calling helper class method to manage the tasks according to events on Case records
                CaseTriggerHelper.manageTasksForSyndicatedServiceCases(Trigger.New, Trigger.oldMap);        
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