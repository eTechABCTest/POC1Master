/*
 *  Purpose         :   Helper class of Trigger_Program_Package_Royall, manually merged code from Royall Enviournment to Corporate Instance.
 * 						- Moved code from shift_mass_update_programs trigger to this class
 *
 *  Create By       :   Rajeev Jain
 *
 *  Created Date    :   06/24/2016
 *
 *  Revision Log    :   V_1.0 Created
 *
 **/
public without sharing class ProgramPackageRoyallTriggerHelper {
	
    /**
     *  @description    :   Merged code from shift_mass_update_programs trigger from Royall Enviournment
     *
     *  @args           :   List of old Account records
     *
     *  @return         :   void
     *
     **/
    public static void massUpdatePrograms(List<Program_Package__c> newProgramPackage, map<Id, Program_Package__c> oldProgramPackage) {
    	
        Map <Id,Program_Package__c> theUpdatedProgramsMap= new Map <Id,Program_Package__c > ();
        
        //Loop over each new program Package record
        for(Program_Package__c pckg : newProgramPackage){
            if(pckg.Client_Status_New__c != oldProgramPackage.get(pckg.Id).Client_Status_New__c && pckg.Client_Status_New__c == 'Lost'){
            	theUpdatedProgramsMap.put(pckg.Id, pckg);    
            }
        }
        
        if(theUpdatedProgramsMap.size() > 0){
            
            Set<Id> lockedPrgPkgIdSet = new Set<Id> ();
            
            List<Royall_Program__c> theProgramList = [select Id, Status__c, Program_Package__c, Lock_the_Record__c  
                                                                       from Royall_Program__c 
                                                                       where Program_Package__c in : theUpdatedProgramsMap.KeySet()];
            
            for( Royall_Program__c theProg: theProgramList ){
                theProg.Status__c = 'Declined';
                if(theProg.Lock_the_Record__c == True)
                    lockedPrgPkgIdSet.add(theProg.Program_Package__c);
            }
            
            //Update Program List
            List <Database.SaveResult> srList = Database.update(theProgramList,false);
            
            Set <Id> UpdatedProg = new Set<Id> (); 
            
            // Iterate through each returned result
            for (Database.SaveResult sr : srList) {
                if (sr.isSuccess()) {
                    UpdatedProg.add(sr.getId());
                }
            }
            
            Set<Id> failedProg = new Set<Id>();
            
            for( Royall_Program__c prog : theProgramList){
                if(!UpdatedProg.contains(prog.Id))
                    failedProg.add(prog.Program_Package__c);
            }
            
            // Add error to the program Package that were not updated
            if(failedProg.size() > 0){
                for( Program_Package__c theProPkg: theUpdatedProgramsMap.values()){
                    if(failedProg.contains(theProPkg.Id)){
                        if(lockedPrgPkgIdSet.contains(theProPkg.Id)) theProPkg.addError(System.Label.Error_Msg_Locked_Prog_Pck_update);
                        else theProPkg.addError(System.Label.Error_Msg_Prog_Pck_update);
                    }
                }
            }
        }
    }
}