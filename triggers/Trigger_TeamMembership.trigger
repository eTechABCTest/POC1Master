/**
 *  Purpose         :   This trigger is to handle all teh pre and post processing operation
 * 
 *  Created By      :   Bhavi Sharma
 * 
 *  Created Date    :   03/31/2015
 * 
 *  Revision Logs   :   V_1.0 - Created
 *                      V_1.1 - Modified - Subhash Garhwal - 06/30/2015 - CR-20150618-9014
 *                      V_1.2 - Modified - by - Mahendra swarnkar - 03/16/2016 - CR-20150908-9224
 * 						Manual Merged By - Rajeev Jain - In Test Sandbox - 05/29/2016 - Conflict found with Release 50 CR-20150908-9224
 * 						V_1.3 - Modified - Rajeev Jain - 04/20/2016 - CR-20151120-9402 - Added IncentiveChangeLog Method
 **/ 
trigger Trigger_TeamMembership on Team_Membership__c (before insert, before update, after Insert, after update) {
    
    try {
        //Check for the request type 
        if(Trigger.isBefore) {
            
            //Check for the Event Type
            if(Trigger.isInsert || Trigger.isUpdate) {
                
                //Call helper class method
                TeamMembershipTriggerHelper.validateTeamMemberships(Trigger.New);
            }
        }
        
        //Check for trigger request type
        if(Trigger.isAfter) {
            
            //V_1.3 - Added By - Rajeev Jain - 04/20/2016 - CR-20151120-9402
            if(Trigger.isInsert || Trigger.isUpdate)
            	if(!TeamMembershipTriggerHelper.isByPassIncentiveChangeLogMethod)
            		TeamMembershipTriggerHelper.incentiveChangeLog(Trigger.new, Trigger.oldMap);
            
            //Check for trigger event type
            if(Trigger.isInsert || Trigger.isUpdate) {
                
                //Added by - Mahendra swarnkar - 03/16/2016 - CR-20150908-9224
                //Call helper class method
                //This method is used to update the Institutions to relicate the solution data on the related institution record
                if(!TeamMembershipTriggerHelper.isMethodExecutedOnce)
                    TeamMembershipTriggerHelper.updateInstitutionToReplicateSolutionData(Trigger.new, Trigger.oldMap);
                
                if(Trigger.isUpdate) {
                    //Added by - Subhash Garhwal - 06/30/2015 - CR-20150618-9014
                    //Call helper class method
                    //This method is used to validate all the related RPPs Effective dates according to Staff Assignments Effective dates
                    TeamMembershipTriggerHelper.validateUpdate(Trigger.new, Trigger.oldMap);
                    
                    //Added by - Subhash Garhwal - 07/02/2015 - CR-20150618-9014
                    //Call helper class method
                    //This method is used to update all the related RPPs name, if SA name is changed.
                    TeamMembershipTriggerHelper.updateRPPs(Trigger.new, Trigger.oldMap);
                }
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
    }catch(Exception e) {
        
        //Add Error Message on Page
        if(Trigger.isDelete)
            Trigger.Old[0].addError(e.getMessage());
        else
            Trigger.New[0].addError(e.getMessage());
    }
}