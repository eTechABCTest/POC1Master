/**
 *  Description     :   This trigger is to handle all the pre and post processing operation for Event Registration record
 * 
 *  Created By      :   Victor Hanson
 * 
 *  Created Date    :   02/22/2014
 * 
 *  Revision Logs   :   V1.2 - Modified By - Victor Hanson - 01/26/2015 - CR-20140520-5562 - added reference to AdvisoryEventTriggerHelper.populateTopParent
 						V1.3 - Modified By - Bhavi Sharma - 02/23/2015 - CR-20140520-5562 - added reference to AdvisoryEventTriggerHelper.manageMeetingFollowers
 						V1.4 - Modified By - Bhavi Sharma - 03/03/2015 - CR-20140520-5562 - added reference to AdvisoryEventTriggerHelper.createDefaultTeamMembers
 						V1.5 - Modified By - Bhavi Sharma - 03/04/2015 - CR-20140520-5562 - added reference to AdvisoryEventTriggerHelper.manageCloneRulesFromParent
 						V1.6 - Modified By - Bhavi Sharma - 03/04/2015 - CR-20140520-5562 - added reference to AdvisoryEventTriggerHelper.deleteRulesForUseForParent
 						V1.7 - Modified By - Bhavi Sharma - 03/27/2015 - CR-20140520-5562 - added reference to AdvisoryEventTriggerHelper.deleteRulesForEstablishedIndependentRule
 * 
 **/
trigger AdvisoryEvent on Advisory_Event__c(before insert, before update, before delete, after insert, after update){

    try {
    	
        //VH added 1/26/15
        AdvisoryEventTriggerHelper.populateTopParent(trigger.new, trigger.oldMap, 'Advisory_Event__c', 'Parent_Event__c', 'Master_Event__c');
        
        //Check for the request type
        if(Trigger.isAfter) {
            
            //Insert/Update
            if(Trigger.isInsert || Trigger.isUpdate) {
            	
            	//Call Helper class Method to manage the followers
            	AdvisoryEventTriggerHelper.manageMeetingFollowers(Trigger.New, Trigger.oldMap);
            	
            	//Call Helper class Method to manageRules
            	AdvisoryEventTriggerHelper.manageCloneRulesFromParent(Trigger.New, Trigger.oldMap);
            	
            	//Call the helper class method to delete the related rule's is Use Rapent's rules are defined
                 AdvisoryEventTriggerHelper.deleteRulesForUseForParent(Trigger.New, Trigger.oldMap);
            }
            
            //Check for the event type
            if(Trigger.isInsert) {
                 
                 //Call the helper class method to create the registration records
                 AdvisoryEventTriggerHelper.createDefaultTeamMembers(Trigger.New);
            }
            
            //Insert/Update
            if(Trigger.isUpdate) {
        		
        		//Call the helper class method to delete all the rules when rule is changed from Parent to Estiblisehed Independent rule.
        		AdvisoryEventTriggerHelper.deleteRulesForEstablishedIndependentRule(Trigger.New, Trigger.oldMap);  	
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
            Trigger.Old[0].addError(e.getMessage() + e.getStackTraceString());
        else
            Trigger.New[0].addError(e.getMessage());
    }
}