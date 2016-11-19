/**
 *  Description     :   Trigger is used to handle all the pre and post processing operation for Staff Relationship.
 *
 *  Created By      :   Subhash Garhwal 
 *
 *  Created Date    :   8/20/2015
 *
 *  Revision Logs   :   V_1.0 - Created - CR-20150825-9182
 *                      V_1.1 - Modified - 9/29/2015 - CR-20150825-9182 - Add new call preventDuplicates
 *                      V_1.2 - Modified - Rajeev Jain - CR-20151120-9402 - Remove the usage of createIncentiveChangeLog              
 **/
trigger Trigger_StaffRelationship on Staff_Relationship__c (after insert, after update,before insert, before update) {
        
    try {
        
        //Bypass flag
        if (Util.BypassAllTriggers) return;
        
        //Ckeck for Trigger context
        if(Trigger.isBefore) {
            
            //Check for trigger events
            if(Trigger.isInsert ) {
                
                //Call helper class method
                //This method is used to assign Source corresponding to usre.
                StaffRelationshipTriggerHelper.assignSource(Trigger.new);               
            }
            
            //Check for trigger events
            if(Trigger.isInsert || Trigger.isUpdate) {
                
                //Call helper class method
                //This method is used to rename Staff Relationship
                StaffRelationshipTriggerHelper.reNameStaffRelationship(Trigger.new);

                //Call helper class method
                //This method is used to Prevent Duplicate Staff Relationship
                StaffRelationshipTriggerHelper.preventDuplicates(Trigger.new, Trigger.oldMap);              
            }
        }
        
        //Check for trigger context
        if(Trigger.isAfter) {
            
            //Check for trigger events
            //V_1.2 - Modified - Rajeev Jain - CR-20151120-9402 - Remove the usage of createIncentiveChangeLog 
            /*if(Trigger.isInsert || Trigger.isUpdate) {
                
                //Code Added - Subhash Garhwal - 08/20/2015
                //Call helper class method
                StaffRelationshipTriggerHelper.createIncentiveChangeLog(Trigger.new, Trigger.oldMap);               
            }*/
                
            //Check for trigger events
            if(Trigger.isInsert || Trigger.isUpdate || Trigger.isDelete) { 
                
                //Code Added - Subhash Garhwal - 08/20/2015
                //Call helper class method
                if(!StaffRelationshipTriggerHelper.isByPassCreateMyRelationshipMethod)
                    StaffRelationshipTriggerHelper.createMyRelationship(Trigger.new, Trigger.oldMap);
                
            }
            
            //Check for trigger events
            if(Trigger.isUpdate) {
                
                //Code Added - Subhash Garhwal - 10/10/2015
                //Call helper class method
                StaffRelationshipTriggerHelper.validateMyRelationship(Trigger.new, Trigger.oldMap);
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