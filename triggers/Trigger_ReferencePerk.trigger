/** 
  * Description     :   Trigger on Refernece Perk Object.
  *
  * Created By      :   Rajeev Jain(Simplyforce)
  *
  * Created Date    :   12/21/2015
  *
  * Version         :   V1.0 Created : Check Refenrecne Perk Eligibiliity and autopopulate Contact on it. 
  **/ 
  
trigger Trigger_ReferencePerk on Reference_Perk__c (before insert, before update) {
    
    try {
        
        if (Util.BypassAllTriggers) 
            return;
        
        //Check for the request type
        if(Trigger.isBefore){
            
            
            //Check for Event Type
            if(Trigger.isInsert || Trigger.isUpdate) {
                
                ReferencePerkTriggerHelper.populateFieldsOfEligibleReferencePerk(Trigger.New, Trigger.oldMap);    
            }    
        }
            
    //Catching DML Exceptions
    }catch(Exception e) {
        
        //Add Error Message on Page
        if(Trigger.isDelete)
            Trigger.Old[0].addError(e.getMessage());
        else
            Trigger.New[0].addError(e.getMessage());
    }    
}