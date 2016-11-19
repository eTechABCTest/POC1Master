/**
 *  Description     :   Trigger is used to handle all the pre and post processing operation for Personal Goal
 *
 *  Created By      :   Padmesh Soni 
 *
 *  Created Date    :   8/17/2015
 *
 *  Revision Logs   :   V_1.0 - Created - CR-20150729-9114
 *                      V_2.0 - Modified By - Rajeev Jain - 1/13/2016 - ISSP Deployment C Release QA changes.
 *                      Commented out validatesPersonalGoal method, since its no longer need.
 *                      V_3.0 - Modifieid By - Rajeev Jain - 05/13/2016 - ISSP Deploymet E - CR-20160421-9790                         
 *                    
 **/
trigger Trigger_PersonalGoal on Personal_Goal__c (before insert, before update, after insert, after update) {
    
    try {
        
        //Bypass flag
        if(Util.BypassAllTriggers) return;
        
        //Check for trigger context
        if(Trigger.isBefore) {
            
            //Check for trigger events
            if(Trigger.isInsert || Trigger.isUpdate) {
            
                //Call helper class method
                //This method is used to Validate personal goal with date range
                //PersonalGoalTriggerHelper.validatesPersonalGoal(Trigger.new, Trigger.oldMap);
                
                //V_3.0 - Added By - Rajeev Jain - 05/13/2016 - ISSP Deploymet E - CR-20160421-9790
                PersonalGoalTriggerHelper.populateGTAndGTDDataOnPg(Trigger.new, Trigger.oldMap);
            }
        }

        //Check for trigger context
        if(Trigger.isAfter) {
            
            //Check for trigger events
            if(Trigger.isInsert) {
                
                //Call helper class method
                //Method to create new Condition and associate condition on Standard Goal Detail or Primary Goal.
                PersonalGoalTriggerHelper.createConditionsForPG(Trigger.new);
                
                //Call helper class method
                //This method is used to clone personal goal and create new proposal goal and associate condition on new proposal goal
                PersonalGoalTriggerHelper.createProposalGoal(Trigger.new);
                
            }
            
            //Check for trigger events
            if(Trigger.isUpdate) {
                
                //Call helper class method
                //This method is used update the Primary Goal’s Active Proposal
                if(PersonalGoalTriggerHelper.executeActiveProposals)
                    PersonalGoalTriggerHelper.activateProposals(Trigger.new, Trigger.oldMap);
                
                //Call helper class method
                //This method is used update the counterpart PG
                if(PersonalGoalTriggerHelper.executeStatusLogic)
                    PersonalGoalTriggerHelper.validateCounterpartPG(Trigger.new, Trigger.oldMap);
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