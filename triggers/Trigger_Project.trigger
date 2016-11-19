/*
    Purpose         :   This trigger is responsible for handling all the pre or post processing for
                        any dml operation for Project object 
                
    Create By       :   Bhavi Sharma
    
    Created Date    :   01/18/2012
    
    Current Version :   V_1.7
    
    Revision Logs   :   V_1.0 - Created
                        V_1.1 - Bhavi Sharma - 04/26/2013 - CR-20130408-2822
                        V_1.2 - Bhavi Sharma - 05/31/2013 - CR-20130328-2773
                        V_1.5 - Bhavi Sharma - 12/23/2013 - CR-20130813-3414
                        V_1.6 - Abhinav Sharma - 03/03/2014 - CR-20130829-3543
                        V_1.7 - Modified By - Abhinav Sharma - 07/07/2014 - CR-20140618-5849 - Catch DML errors in triggers to reduce exception emails to SFAdmin
                        V_1.8 - Modified By - Abhinav Sharma - 10/17/2014 - CR-20140826-7138
                        V_1.9 - Modified By - Abhinav Sharma- 06/13/2015 - CR-20150601-8976
                        V_1.10 - Modified By - Abhinav Sharma - 07/29/2015 - CR-20150709-9070
                        V_1.11 - Modified By - Mahedra Swarnkar - 07/05/2016 - CR-20160229-9651
						V_1.12 - Modified by - Mahendra Swarnkar - CR-20160420-9785 - 09/01/2016
*/
trigger Trigger_Project on Project__c (before insert,before update, after insert, after update) {
    
    try{
    
        // if bypass all triggers is set to true, return without processing
        if (Util.BypassAllTriggers) return; 
        
        //check for the request type {
        if(Trigger.isAfter) {
            
            //Check for teh event type
            if(Trigger.isInsert || Trigger.isUpdate) {
                
                //Call helper class method
                ProjectTriggerHelper.updateMembershipData(Trigger.New, Trigger.oldMap);
                
                //Added By Mahedra Swarnkar - 07/05/2016 - CR-20160229-9651 - to populate case fields from Project
                //Call helper class method
                ProjectTriggerHelper.populateCaseFieldsFromProject(Trigger.New, Trigger.oldMap);
                
            }
            
            //Check for the update event
            if(Trigger.isUpdate) {
                
                //Call helper class method to check if the project data is changed and member support need to be updated
                ProjectTriggerHelper.UpdateSiteIssueByProject(Trigger.New, Trigger.oldMap);
                
                //Added by VH - 12/26/13 - CR-3856
                MemberSupportTriggerUtilities.populateMemberSupportProgramType(trigger.new, trigger.oldMap);
                
                //Added By - Abhinav Sharma - 10/17/2014 - CR-20140826-7138
                //Call helper class method here to find Oldest Deployment Sign Off on Project record
                ProjectTriggerHelper.populateDeploymentSignOffOldest(Trigger.new, Trigger.oldMap);
            }
        } 
        else if(Trigger.isBefore) {
            
            //Code added by Bhavi Sharma - 04/26/2013 - CR-20130408-2822
            //Check for event type 
            if(Trigger.isInsert || Trigger.isUpdate) {
                
                //Call helper class method
                ProjectTriggerHelper.UpdateProjectByMembershipEvent(Trigger.new, Trigger.oldMap);
                
                //Added by Bhavi Sharma - 05/31/2013 - CR-20130328-2773
                ProjectTriggerHelper.updateProjectByCurrentRenewalOpportunity(Trigger.New);
                
                //Added By - Abhinav Sharma- 06/13/2015 - CR-20150601-8976
                ProjectTriggerHelper.validateAndPopulateProjectFields(Trigger.new);
            }
            
            //Check for event type
            if(Trigger.isUpdate) {
                
                //Added by Abhinav Sharma - 03/03/2014 - CR-20130829-3543
                ProjectTriggerHelper.populateFirstDeploymentSignedOff(Trigger.new);
                
                //Added By - Abhinav Sharma - 07/29/2015 - CR-20150709-9070
                ProjectTriggerHelper.populateProjectFieldsFromChildren(Trigger.new, Trigger.oldMap);
                
                //Added by - Mahendra Swarnkar - CR-20160420-9785 - 09/01/2016
                ProjectTriggerHelper.populateProjectFieldsFromMemberSupport(Trigger.new, Trigger.oldMap);
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