/*
    Purpose         :   This trigger is to handle all the pre and post processing operations for Institution_Roles__c object
                
    Create By       :   Simplyforce Technology
    
    Created Date    :   11/08/2012
    
    Revision Log    :   V_1.0 Created
                        V_1.1 - 02/04/2014 - Bhavi Sharma - CR-20140124-4353
                        V_1.2 - Modified By - Abhinav Sharma - 07/07/2014 - CR-20140618-5849 - Catch DML errors in triggers to reduce exception emails to SFAdmin
*/
trigger Trigger_InstitutionRole on Institution_Roles__c (before insert, before update, after insert, after update, after delete) {
    
    try {
        //Check for the request type
        if(Trigger.isBefore) {
            
            //Check for the event type
            if(Trigger.isInsert || Trigger.isUpdate) {
                
                //Call the helper class method to update the interaction Information
                InstitutionRoleTriggerHelper.UpdateInteractionInformation(Trigger.New, Trigger.oldMap);
            }
        } else if(Trigger.isAfter) {
            
            //Check for the event type
            if(Trigger.isInsert || Trigger.isUpdate) {
                
                //Call the helper class method to update the Roles Tags on Contact
                InstitutionRoleTriggerHelper.PopulateContactData(Trigger.newMap, Trigger.oldMap);
            } else if(Trigger.isDelete){
                
                //Call the helper class method to update the Roles Tags on Contact
                InstitutionRoleTriggerHelper.UpdateContactRoleTagForDelete(Trigger.Old);
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