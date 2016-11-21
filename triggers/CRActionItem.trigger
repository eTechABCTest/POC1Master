trigger CRActionItem on CR_Action_Item__c (after insert, after update, before delete, after delete) {
    
        try {
        //Check for the request type
        if(Trigger.isInsert || Trigger.isUpdate) {
            
            //Call helper class method here to roll up data to parent SFDC Modification
            SFDCModificationHelper.recalculateManualStepsTime (Trigger.New);
            
            //Call helper class method here to roll up data on SFDC Release
            SFDCChangeRequestTriggerHelper.rollUpDataOnSFDCRelease(CRActionItemTriggerHelper.getParentReleaseIds(Trigger.new,'ISMod'));
            
        }
        
        else if (Trigger.isDelete) {
            
            if(Trigger.isBefore){
                //Call method to get the Release Ids that will need to have recalculations
            	set<Id> setReleaseIds = CRActionItemTriggerHelper.getParentReleaseIds(Trigger.old,'ISMod');
                
                //Call method to run the recalculation.  This runs in @Future once the records are deleted.
                CRActionItemTriggerHelper.recalculateManualStepsOnReleases(setReleaseIds);
            }
            
            if(Trigger.isAfter){
            
            	//Call helper class method here to roll up data to parent SFDC Modification
            	SFDCModificationHelper.recalculateManualStepsTime (Trigger.Old);
            
            }
        }
        
    }
    
    catch(DMLException e) {

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