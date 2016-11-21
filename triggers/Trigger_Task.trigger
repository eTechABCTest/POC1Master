/*
    Purpose         :   This trigger is responsible for handling all the pre or post processing for
                        any dml operation for Task object 
                
    Create By       :   Simplyforce Technology
    
    Created Date    :   11/03/2011
    
    Current Version :   V1.0
    
    Revision Log    :   V1.0 - Created  
                        V1.1 - 11/20/2013 - VH - Added populateActivityDatecopy (cr-3662)
                        v1.2 - 12/17/2013 - VH - Added reference to 
                        V_1.3 - 03/07/2014 - Bhavi Sharma - CR-20140214-4512
                        V_1.4 - Modified By - Abhinav Sharma - 07/07/2014 - CR-20140618-5849 - Catch DML errors in triggers to reduce exception emails to SFAdmin
						V_1.5 - Modified By - Abhinav Sharma - 06/15/2015 - CR-20150416-8890
*/
trigger Trigger_Task on Task (before insert, before update, after insert, after update, after delete) {
    
    try{
    
        // bypass if the bypass all trigger is true
        if (Util.BypassAllTriggers) return;
        
        //check for the trigger request type
        if (Trigger.isBefore) {
            
            //check for the trigger event type
            if (trigger.isInsert || trigger.isUpdate) {
                
                // update the activity date copy field
                TaskTriggerHelper.populateActivityDateCopy(trigger.new);
                
                // update the program/abbreviation on new tasks
                EventUtilities.populateOppInfoToActivities(null, trigger.new);
            }
            
            if(trigger.isdelete)
                TaskTriggerHelper.populateFieldsOnConsolidatedInvoice(Trigger.new, Trigger.oldMap);
        }
        
        //check for the trigger request type
        if(Trigger.isAfter) {
            
            //Added By Bhavi Sharma - 03/07/2014 - CR-20140214-4512
            if(Trigger.isInsert)
                TaskTriggerHelper.postMemberImpactStory(Trigger.New);
            
            //Added By - Abhinav Sharma - 06/15/2015 - CR-20150416-8890
            //Calling helper class method
            //Start FROM here
            if(Trigger.isInsert || Trigger.isUpdate || Trigger.isDelete) {
            	TaskTriggerHelper.populateFieldsOnConsolidatedInvoice(Trigger.new, Trigger.oldMap);
            }    
            //upto here
            
            //check for the trigger event type
            if(Trigger.isInsert || Trigger.isUpdate) { 
                
                //call the helper class
                TaskTriggerHelper.notifyTaskCretor(Trigger.Old, Trigger.New);
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