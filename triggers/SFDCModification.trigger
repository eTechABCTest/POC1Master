trigger SFDCModification on IS_System_Modification__c (before insert, before update, before delete, after delete, after update) {
    
    try {
        
        if (Trigger.isBefore) {
            
            if(Trigger.isInsert || Trigger.isUpdate) {
                
                //flag mods with the same component on the CR or Release
                SFDCModificationHelper.flagDuplicateMods(Trigger.new, Trigger.oldMap);
                
                //Check for the request type
                SFDCModificationHelper.preventFieldEdits(Trigger.New, Trigger.oldMap);
                
                //Update the SOX Object field as needed.  
				SFDCModificationHelper.SOXObjectFieldUpdate(Trigger.new);
            }
            
            if (Trigger.isUpdate) {
                
                //verify all related action items have been deployed to the environments specified on the modification
                SFDCModificationHelper.verifyDeployedTo(Trigger.newMap, Trigger.oldMap);
            }
            
            if (Trigger.isDelete) {
                
                SFDCModificationHelper.deleteISMod (Trigger.Old);
            }
        }
        
        if (trigger.isAfter) {
            
            if(Trigger.isInsert || Trigger.isUpdate){
                
                SFDCModificationHelper.addDeleteMention(Trigger.New, Trigger.OldMap);
                
            }
            
            if (Trigger.isDelete) {
                
                //flag mods with the same component on the CR or Release
                SFDCModificationHelper.flagDuplicateMods(Trigger.new, Trigger.oldMap);
            }
                
        }
    }
    
    catch(DMLException e) {
        
        //Add Error Message on Page
        if(Trigger.isDelete)
            Trigger.Old[0].addError(e.getDmlMessage(0) + e.getStackTraceString());
        else
            Trigger.New[0].addError(e.getDmlMessage(0) + e.getStackTraceString());
        
        //Catching all Exceptions
    } catch(Exception e) {
        
        //Add Error Message on Page
        if(Trigger.isDelete)
            Trigger.Old[0].addError(e.getMessage() + e.getStackTraceString());
        else
            Trigger.New[0].addError(e.getMessage() + e.getStackTraceString());
    }
    
}