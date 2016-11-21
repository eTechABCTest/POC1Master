/* 
* Name          : shiftMassUpdatePrograms 
* Author        : Shift CRM
* Description   : Mass Updates programs of a Program Package who status was changed to Lost
*
* Maintenance History: 
* Date ------------ Name  ----  Version --- Remarks 
* 09/08/2013        Edward         1.0        Initial
* 20/08/2013        Edward         1.1        Update code to display error when update fails
* 24/06/2016        Rajeev         1.2        Royall SFDC Schema release - Manual code migration.
                                              - Recreated By -  Rajeev Jain - To standarise and follow Advisory best practices
                                              - Created new trigger and merge code of shift_mass_update_programs trigger on Program Package from Royall Instance to Corporate Instance
                                              - Created new additional helper class, and moved whole code from Trigger to helper class.
                                              - Merged from following two triggers : shift_mass_update_programs, Shift_ProgramPackage
  
  09/20/2016    Subhash       1.3    CR-20160817-10134
*/
trigger Trigger_Program_Package_Royall on Program_Package__c (before insert, before update, after insert, after update, after delete, after undelete) {
    
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
            
            //Commented - 9/20/2016 - Subhash Garhwal - CR-20160817-10134
            //Check for All three operation on after event
            if (Account_Status_Management__c.getOrgDefaults().Enable_Update_Account_Status_Trigger__c) {
            
                /*if(Trigger.isInsert)
                    Shift_StatusRollup_Handler.OnAfterInsert(Trigger.new);
                
                else if(Trigger.isUpdate)
                    Shift_StatusRollup_Handler.OnAfterUpdate(Trigger.new);
                
                else if(Trigger.isDelete)
                    Shift_StatusRollup_Handler.OnAfterDelete(Trigger.old);
                
                else if(Trigger.isUnDelete)
                    Shift_StatusRollup_Handler.OnUndelete(Trigger.new); */
                
              //Added - 9/20/2016 - Subhash Garhwal - CR-20160817-10134
              
              //Check for event
              if(Trigger.isInsert || Trigger.isUpdate || Trigger.isDelete || Trigger.isUnDelete) {
          Shift_StatusRollup_Handler.accountRollupsRoyal(Trigger.new, Trigger.oldMap);
        }
            }
            
            //Check if Update
            if(Trigger.isUpdate)        
                ProgramPackageRoyallTriggerHelper.massUpdatePrograms(Trigger.New, Trigger.oldMap);
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