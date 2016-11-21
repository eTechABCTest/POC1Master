/**
 *  Description     :   Trigger is used to handle all the pre and post processing operation for Staff History.
 *
 *  Created By      :   Subhash Garhwal 
 *
 *  Created Date    :   8/21/2015
 *
 *  Revision Logs   :   V_1.0 - Created - 
 *                      V_1.1 - Modified - Subhash Garhwal - CR-20150825-9182 - 09/02/2015 - New method added - onChangeValue
 *                    
 **/
trigger Trigger_StaffHistory on Staff_History__c (before insert, before update, after insert, after update) {
    
    try {
        
        //Bypass flag
        if (Util.BypassAllTriggers) return;
        
        //Check for trigger context
        if(Trigger.isBefore) {
            
            //Check for trigger events
            if(Trigger.isInsert){
            
                //Call helper class method
                //This method is used to assign Source Corresponding to User. 
                StaffHistoryTriggerHelper.assignSource(Trigger.new);
            }
            
            //Check for trigger events
            if(Trigger.isInsert || Trigger.isUpdate) {
                
                
                //Modified - Subhash Garhwal - CR-20150825-9182 - 09/02/2015 - New method called from helper - onChangeValue
                //Call helper class method
                //This method is used to change checkbox value Staff History
                StaffHistoryTriggerHelper.onChangeValues(Trigger.new, Trigger.oldMap);                
            
                //Call helper class method
                //This method is used to rename Staff History 
                StaffHistoryTriggerHelper.preventDuplicates(Trigger.new,Trigger.oldMap);                
            
                //Modified - Subhash Garhwal - CR-20150825-9182 - 09/18/2015 - New method called from helper - calculateCount
                //Call helper class method
                //This method is use to Calculate count
                StaffHistoryTriggerHelper.calculateCount(Trigger.new);                
            }
        }
        
        //Check for trigger context
        if(Trigger.isAfter) {
            
            //Check for trigger events
            if(Trigger.isInsert || Trigger.isUpdate) {
            
                //Call helper class method
                //This method is used to rename Staff History 
                StaffHistoryTriggerHelper.reNameStaffHistory(Trigger.new);
                
                //Call helper class method
                //This method is used to create Incentive Change Log record to track the Staff History changes 
                StaffHistoryTriggerHelper.createIncentiveChangeLog(Trigger.new, Trigger.oldMap);                
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