/**
 *   Purpose    :    This trigger is responsible for handling all the pre or post processing for
 *                   any dml operation for Research Study Interaction object.
 *              
 *   Created By    :  Ajit Surana
 *   
 *   Created Date    :   06/30/2014
 *   
 *   Current Version:    v1.1
 *   
 *   Revision Log    :    V_1.0 Created [CR-20140619-5855]
 *                   :    V_1.1 - Modified By - Abhinav Sharma - 07/07/2014 - CR-20140618-5849 - Catch DML errors in triggers to reduce exception emails to SFAdmin 
 * 						  
 **/
trigger Trigger_Syndicated_Research_Interaction on Syndicated_Research_Interaction__c (after insert, after update, after delete, before insert, before update) {
    
    try{
        //Bypassing trigger on the basis of flag value
        if(Util.BypassAllTriggers) 
            return;
            
        //Check for the request type
        if(Trigger.isBefore){
            
            //Added By - Mahendra swarnakar - 09/18/2015 - CR-20150819-9165
            //Start from here
            //Check for the event type
            if(Trigger.isInsert || Trigger.isUpdate) {
				
                //Call helper class method
                //This Method Populate the related institution lookup field with associated contact's Institution
                SyndicatedRITriggerHelper.populateInstitutionLookUpFieldForNPD(Trigger.new);
            }            
            //Ends here
        }else {
            
            //Check for the event type
            if(Trigger.isInsert || Trigger.isUpdate || Trigger.isDelete) {
                
                //Call helper class method
                SyndicatedRITriggerHelper.populateGPAOnSyndicatedStudy(Trigger.newMap, Trigger.oldMap);
            
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