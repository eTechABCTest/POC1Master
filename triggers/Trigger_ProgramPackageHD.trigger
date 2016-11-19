/* 
* Name          : Trigger_ProgramPackageHD 
* Author        : Shift CRM
* Description   : Manages firing of triggered events
*
* Maintenance History: 
* Date ------------ Name  ----  Version --- Remarks 
* 07/14/2014        Hermes      1.0         Initial
* 27/06/2016        Rajeev      1.2         Royall SFDC Schema release - Manual code migration.
*                                            - Recreated By -  Rajeev Jain - To standarise and follow Advisory best practices
*                                            - Created new trigger and merge code of Shift_ProgramPackageHD_Trigger trigger on Program_Package_Hardwick_Day__c object from Royall Instance to Corporate Instance

* 09/20/2016        Subhash        1.3      CR-20160817-10134
*
*/
trigger Trigger_ProgramPackageHD on Program_Package_Hardwick_Day__c (before insert, before update, after insert, after update, after delete, after undelete) {
    
    try{
         // if a trigger bypass is active, return immediately without processing
        if (Util.BypassAllTriggers) return;
        
        //Check for the request Type
        if(Trigger.isBefore) {
            
            if (Account_Status_Management__c.getOrgDefaults().Enable_Update_Account_Status_Trigger__c) 
                
                //update account status
                Shift_StatusRollup_Handler.setAccountStatus(trigger.new);
        } 
        
        if (Trigger.IsAfter) {
            
            //Check for All three operation on after event
            if (Account_Status_Management__c.getOrgDefaults().Enable_Update_Account_Status_Trigger__c) {
            
                //Commented - 9/20/2016 - Subhash Garhwal - CR-20160817-10134
                /*if(Trigger.isInsert)
                    Shift_StatusRollup_Handler.OnAfterInsert(Trigger.new);
                
                else if(Trigger.isUpdate)
                    Shift_StatusRollup_Handler.OnAfterUpdate(Trigger.new);
                
                else if(Trigger.isDelete)
                    Shift_StatusRollup_Handler.OnAfterDelete(Trigger.old);
                
                else if(Trigger.isUnDelete)
                    Shift_StatusRollup_Handler.OnUndelete(Trigger.new); 
                */
                //Added - 9/20/2016 - Subhash Garhwal - CR-20160817-10134
                
                //Check for event
                if(Trigger.isInsert || Trigger.isUpdate || Trigger.isDelete || Trigger.isUnDelete) {
                    Shift_StatusRollup_Handler.accountRollupsHD(Trigger.new, Trigger.oldMap);
                }
                
            }
            
        }
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