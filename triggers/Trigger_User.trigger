/*
    Purpose         :   This class is helper class for trigger on User object.
                
    Create By       :   Simplyforce Technology
    
    Created Date    :   01/18/2012
    
    Current Version :   V_1.3
    
    Revision Log    :   V_1.1 Created
                    :   V_1.2 Ajit Surana - 04/19/2014 - CR-20140403-4951
                    :   V_1.3 Modified By - Abhinav Sharma - 07/07/2014 - CR-20140618-5849 - Catch DML errors in triggers to reduce exception emails to SFAdmin
                    :   V_1.4 Modified By - Bhavi Sharma - 01/23/2015 - CR-20141209-8273 - Deactivate Credit card records if the user in marked as deactivated
                    :   V_1.5 Modified By - Ajit Surana - 04/29/2015 - CR-20150112-8537
                    :   V_1.6 - Modified By - Abhinav Sharma - 08/25/2015 - CR-20150820-9167
                    :   "V_1.7 - Manual merged in FFDC1 from Test SB - by - Rajeev Jain - 08/19/2016 - As found Q2C Overlapping as part of deployment task."
                    :   V_1.7 - Modified By - Rajeev Jain - 06/27/2016 - Royall SFDC Migration Release - Manual merge of Royall User Trigger with Corporate Instance\                    
                                    - Migrated from Shift_User_Trigger on User object, from Royall Instance
					:	 V_1.8 Updated By - Mahendra swarnakar - 11/8/2015 - CR-20160729-10074

*/
trigger Trigger_User on User (before insert, before update, after insert, after update) {
        
    try{
        
        // if bypass all triggers is true, return without processing
        if (util.BypassAllTriggers) return;
        //Check for the request type
        if(Trigger.isAfter) {
            
            if(Trigger.isInsert) {
                
                //Added as part of the Steelbrick Approval Process - Added by Colin McGloin
                UserTriggerHelper.checkForOrCreateApproverRecord(Trigger.New);
                
            }
            
            //Check for the event type
            if(Trigger.isUpdate) {
                
                //Bhavi Sharma - 01/23/2015 - CR-20141209-8273 - Deactivate Credit card records if the user in marked as deactivated
                UserTriggerHelper.deactivateCreditCardsForInactiveUsers(Trigger.New, Trigger.oldMap);
                
                //Call Helper class method to update the Owner Associate
                UserTriggerHelper.updateMembershipRecords(Trigger.oldMap, Trigger.newMap);
                
                //Added by Ajit Surana - 04/19/2014 - CR-20140403-4951
                UserTriggerHelper.updateOwnerManagerEmailOnOpportunities(Trigger.new, Trigger.oldMap);
                
                //Added by Ajit Surana - 04/29/2015 - CR-20150112-8537
                UserTriggerHelper.updateCTAssignmentManagerEmailOnOpportunities(Trigger.new, Trigger.oldMap);
                
                //Added By - Abhinav Sharma - 08/25/2015 - CR-20150820-9167
                UserTriggerHelper.doUpdateOnOpportunitiesOnUserUpdate(Trigger.new, Trigger.oldMap);
                
                //"V_1.7 - Manual merged in FFDC1 from Test SB - by - Rajeev Jain - 08/19/2016 - As found Q2C Overlapping as part of deployment task."
                //V_1.7 - Modified By - Rajeev Jain - 06/27/2016 - Royall SFDC Migration Release
                // V_1.8 Updated By - Mahendra swarnakar - 11/8/2015 - CR-20160729-10074
                if (!system.isFuture() && !system.isScheduled() && !system.isBatch() && Shift_ChangeDelete_Callout.calloutSettings.Enable_User_Trigger__c) {
                    Shift_ChangeDelete_Callout.processRecords((List<SObject>)trigger.new, 'update', 'User');
                }
                //V_1.7 - Modified By - Rajeev Jain - 06/27/2016 - Royall SFDC Migration Release - upto here
            }
        }
        
        //Bwfore
        else if(Trigger.isBefore) {
            
            //Event Type
            if(Trigger.isInsert || Trigger.isUpdate) {
                
                //Call helper call method to update data related to Cost Center
                UserTriggerHelper.updateCostCenterRelatedData(Trigger.New, Trigger.oldMap);
                
                //Update the Office Info for the User (for Workday integration)
                UserTriggerHelper.populateUserInfoOffice(trigger.new, trigger.oldMap);
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