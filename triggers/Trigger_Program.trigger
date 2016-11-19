//Modified By - Ajit Surana - 03/30/2015 - CR-20150312-8758 
//Modified By - Abhinav Sharma - 07/07/2014 - CR-20140618-5849 - Catch DML errors in triggers to reduce exception emails to SFAdmin
//Modified by - Subhash Garhwal - 06/25/2015 - CR-20150618-9014
//Code Modified by - Padmesh Soni - 08/04/2015 - CR-20150729-9114 - createIncentiveChangeLog method added.
//Modified By - Rajeev Jain - 04/19/2016 - CR-20151120-9402 - Removed createIncentiveChangeLog - ISSP Deployment E - As per the updated SDD of Change Management
//This trigger is to handle DML operations and validations of the program object
trigger Trigger_Program on Program__c (after insert, after update, before delete) {
    
    try {
        
        // bypass flag
        if (Util.BypassAllTriggers) return;
        
        //check if trigger is in after context
        if(Trigger.isAfter) {
            
            //check insert or update context
            if(Trigger.isInsert || Trigger.isUpdate) {
                
                //call the Helper class
                ProgramTriggerHelper.insertOrUpdateProductData(Trigger.isInsert, Trigger.New);
            }
            
            //Added by - Ajit Surana - 03/30/2015 - CR-20150312-8758
            if(Trigger.isUpdate) {
            
                //Calling helper class method
                ProgramTriggerHelper.updateInstitutionFromMembershipRelatedProgram(Trigger.new, Trigger.oldMap);
                
                //Added by - Subhash Garhwal - 06/25/2015 - CR-20150618-9014
                //Call the helper class method
                //This method is used to notify Progam Group and Perspective owner on program's key field changes
                ProgramTriggerHelper.keyInformationChangedNotification(Trigger.new, Trigger.oldMap);
                
                //Added by - Padmesh Soni - 08/04/2015 - CR-20150729-9114
                //Call the helper class method
                //This method is used to create IncentiveChangeLogs record when program key field changes
                //ProgramTriggerHelper.createIncentiveChangeLog(Trigger.new, Trigger.oldMap);
            }
        }
        
        //Added by - Ajit Surana - 03/30/2015 - CR-20150312-8758
        //Check for the request Type
        if(Trigger.isBefore) {
            
            //Check for the event type
            if(Trigger.isDelete) {
            
                //Calling helper class method
                ProgramTriggerHelper.updateInstitutionFromMembershipRelatedProgramDeletion(Trigger.oldMap);
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