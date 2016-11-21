/**
 *  Description     :   Helper class for Trigger_StaffRelationship trigger.
 *
 *  Created By      :   Subhash Garhwal 
 *
 *  Created Date    :   8/20/2015
 *
 *  Revision Logs   :   V_1.0 - Created - CR-20150825-9182
 *                      V_1.1 - Modified - 9/29/2015 - CR-20150825-9182 - Add new method preventDuplicates
 *                      V_1.2 - Modified - Rajeev Jain - CR-20151120-9402 - Remove the usage of createIncentiveChangeLog
 *                      V_1.3 - Modified - Rajeev Jain  - CR-20160301-9654 - Modified CreateMyRelationship Method in order to execute it at all after trigger events                    
 **/
public without sharing class StaffRelationshipTriggerHelper {
    
    //Flag to bypass Rerun of the Trigger
    public Static Boolean isByPassCreateMyRelationshipMethod = false;
    /**
     *  @description    :   This method is used to rename Staff Relationship record before the record is commited.
     *  
     *  @args           :   List<Staff_Relationship__c>
     *
     *  @return         :   void
     *
     **/
    public static void reNameStaffRelationship(List<Staff_Relationship__c> staffRealtionships){
        
        //Loop through Staff Relationship to Rename it
        for(Staff_Relationship__c sR : staffRealtionships)
            sR.Name = sR.SR_Name__c;
    }
    
    /**
     *  @description    :   This method is used to create Incentive Change Log, whenever a new Staff Relationship inserted
     *                      Effective Dates, From (Lookup to contact) or To (Lookup tp contact) are changed.
     *  
     *  @args           :   List<Staff_Relationship__c>, Map<Id, Staff_Relationship__c>
     *
     *  @return         :   void
     *
     **/
     //V_1.2 - Modified - Rajeev Jain - CR-20151120-9402 - Remove the usage of createIncentiveChangeLog
    /*public static void createIncentiveChangeLog(List<Staff_Relationship__c> staffRealtionships, Map<Id, Staff_Relationship__c> mapOldStaffReslationships){
    
        //List of Incentive Change logs
        List<Incentive_Change_Log__c> incentiveChangeLogs = new List<Incentive_Change_Log__c>();
        
        //Loop Througt Staff Relationship
        for(Staff_Relationship__c sR : staffRealtionships){
            
            //Add new Incentive change log into list for insert case or From or To modification.
            if(mapOldStaffReslationships == null || sR.From__c != mapOldStaffReslationships.get(sR.Id).From__c
                || sR.To__c != mapOldStaffReslationships.get(sR.Id).To__c)
                incentiveChangeLogs.add(new Incentive_Change_Log__c(Staff_Relationship__c = sR.Id, Change_Type__c = ISSPConstants.INCENTIVE_CHANGE_LOG_VALUE_TYPE_ADDITION));
                
            //Add new Incentive change log into list for Effective Date modification.
            if(mapOldStaffReslationships != null && (sR.Start_Date__c != null || sR.End_Date__c != null) && (sR.Start_Date__c != mapOldStaffReslationships.get(sR.Id).Start_Date__c || sR.End_Date__c != mapOldStaffReslationships.get(sR.Id).End_Date__c)){
                Incentive_Change_Log__c iCL = new Incentive_Change_Log__c(Staff_Relationship__c = sR.Id, Change_Type__c = ISSPConstants.INCENTIVE_CHANGE_LOG_VALUE_TYPE_EFFECTIVE_DATES);
                
                //Assign start date 
                if(sR.Start_Date__c != mapOldStaffReslationships.get(sR.Id).Start_Date__c)
                    iCL.Start_Date__c = sR.Start_Date__c;
                 
                //Assign End date 
                if(sR.End_Date__c != mapOldStaffReslationships.get(sR.Id).End_Date__c)
                    iCL.End_Date__c = sR.End_Date__c;
                
                //Add List
                incentiveChangeLogs.add(iCL);
            }
        }   
        //Insert Incentive Change Log
        if(incentiveChangeLogs.size() > 0)
            insert incentiveChangeLogs;  
    }*/
    
    /**
     *  @description    :   This method is used to create My Relationship, whenever a new Staff Relationship inserted.
     *                      One for From Contact and other one for To Contact
     *                      Mapping:
     *                      First My relationship record:
     *                      Contact = From 
     *                      Related To = To
     *                      Second My relationship record:
     *                      Contact = To
     *                      Related To= From
     *
     *  
     *  @args           :   List<Staff_Relationship__c>
     *
     *  @return         :   void
     *
     **/
     public static void createMyRelationship(List<Staff_Relationship__c> staffRealtionships, Map<Id, Staff_Relationship__c> mapOldStaffRelationships){
        
        //List of My Relationship
        List<My_Relationships__c> myRelationshipsForInsert = new List<My_Relationships__c>();
        
        //List to hold the Relationship for Delete
        List<My_Relationships__c> myRelationshipsForDelete = new List<My_Relationships__c>();
        
        //Set of Staff Relationship id which will be used to query to get those records of my relationsship which are going to be delete
        Set<Id> staffRelationshipIds = new Set<Id>();
        
        //Loop Througt Staff Relationship to create new My Relationsips records(Check for Insert and Update)
        if(staffRealtionships != null){
            for(Staff_Relationship__c sR : staffRealtionships){
                
                //Check for Insert Case
                if(mapOldStaffRelationships == null || (mapOldStaffRelationships != null && (sR.Relationship__c != mapOldStaffRelationships.get(sR.id).Relationship__c || sR.From__c != mapOldStaffRelationships.get(sR.id).From__c || 
                                                                sR.To__c != mapOldStaffRelationships.get(sR.id).To__c || sR.Start_Date__c != mapOldStaffRelationships.get(sR.id).Start_Date__c ||
                                                                sR.End_Date__c != mapOldStaffRelationships.get(sR.id).End_Date__c))){
                    
                    //Create new My relationship record for From contact  
                    if(sR.From__c != null)
                        myRelationshipsForInsert.add(new My_Relationships__c(Staff_Relationship__c = sR.Id, Contact__c = sR.From__c, Related_To__c = sR.To__c, Start_Date__c = sR.Start_Date__c, End_Date__c = sR.End_Date__c));
                    
                    //Create new My relationship record for To contact
                    if(sR.To__c != null)
                        myRelationshipsForInsert.add(new My_Relationships__c(Staff_Relationship__c = sR.Id, Contact__c = sR.To__c, Related_To__c = sR.From__c, Start_Date__c = sR.Start_Date__c,  End_Date__c = sR.End_Date__c));
                        
                    //If Record is for update then delete old my relationship record as well.
                    if(mapOldStaffRelationships != null)
                        staffRelationshipIds.add(sR.Id);    
                }
            }
        }else if(staffRealtionships == null && mapOldStaffRelationships != null){
            
            myRelationshipsForDelete = [select Id from My_Relationships__c where Staff_Relationship__c IN : mapOldStaffRelationships.values()]; 
        }
        
        //Query on all My Relationship Record which are associated with Staff Relationship
        List<My_Relationships__c> tempMyRelationshipForDelete = [select Id from My_Relationships__c where Staff_Relationship__c IN :staffRelationshipIds];
        
        //Check for the size
        myRelationshipsForDelete.addAll(tempMyRelationshipForDelete);
        
        //Set the Flag 
        isByPassCreateMyRelationshipMethod = true;
        
        //Delete My Relationship Records for all parent Staff Relationship records change
        if(myRelationshipsForDelete.size() > 0)
            delete myRelationshipsForDelete;
            
        //Insert My Relationship
        if(myRelationshipsForInsert.size() > 0)
            insert myRelationshipsForInsert;
    }
    
    /**
     *  @description    :   Method is use to assign source Corresponding to User  
     *  
     *  @args           :   List<Staff_Relationship__c>
     *
     *  @return         :   void
     *
     **/
    public static void assignSource(List<Staff_Relationship__c> staffRelationships){
        
        //Loop Through staff Relationship.
        for(Staff_Relationship__c sR : staffRelationships){
            
            //Assign Source
            if(Userinfo.getUserName() == Label.INTEGRATION_USER_NAME) {
                sR.Source__c = ISSPConstants.STAFF_ATTRIBUTE_SOURCE_INTEGRATION;
            }else
                sR.Source__c = ISSPConstants.STAFF_ATTRIBUTE_SOURCE_NATIVE;
                
        }
    }
    
     /**
     *  @description    :   This method is used to prevent the duplicate record of Staff Relationship.  
     *                      Duplicate Defination:
     *                      Where the two records have the same From, To, and Relationship Type IDs, and the effective dates overlap
     *
     *  @args           :   List<Staff_Relationship__c>, Map<Id, Staff_Relationship__c>
     *
     *  @return         :   void
     *
     **/
    public static void preventDuplicates(List<Staff_Relationship__c> staffRelationships, Map<Id, Staff_Relationship__c> mapOldStaffReslationships){
    
        //Map to hold unique Key (Combination of From, To, Relationship Type) with List of Staff Relaionship
        Map<String, List<Staff_Relationship__c>> mapSRsWithUK = new Map<String, List<Staff_Relationship__c>>();
        
        //Set to hold the From contact Ids
        Set<Id> setFromIds = new Set<Id>();
        
        //Set to hold the TO contact Ids
         Set<Id> setToIds = new Set<Id>();
        
        //Loop through Staff Relationship
        for(Staff_Relationship__c sR : staffRelationships) {
            
            //Check for appropriate condition
            if(mapOldStaffReslationships == null || sR.From__c != mapOldStaffReslationships.get(sR.Id).From__c
                || sR.To__c != mapOldStaffReslationships.get(sR.Id).To__c || sR.Relationship__c != mapOldStaffReslationships.get(sR.Id).Relationship__c
                || sR.Start_Date__c != mapOldStaffReslationships.get(sR.Id).Start_Date__c || sR.End_Date__c != mapOldStaffReslationships.get(sR.Id).End_Date__c){
                    
                //Add From Id in set
                setFromIds.add(sR.From__c);
                
                //Add TO Id in set
                setToIds.add(sR.To__c);
                
                //Generate Unique Key
                String uniqueKey = sR.From__c + '-' + sR.To__c;
                
                ///Check for Relationship type
                if(sR.Relationship__c != null)
                    uniqueKey += '-' + sR.Relationship__c;
                
                //Check if any new record has same unique key
                if(mapSRsWithUK.containsKey(uniqueKey)) {
                    
                    //Loop through Staff Relationship
                    for(Staff_Relationship__c exsR : mapSRsWithUK.get(uniqueKey)) {
                        
                        //Check for current record’s effective date if conflicting with any existing one
                        if((sR.End_Date__c == null && exsR.End_Date__c == null)
                            || (sR.End_Date__c != null && exsR.End_Date__c == null && sR.End_Date__c >= exsR.Start_Date__c)
                            || (sR.End_Date__c == null && exsR.End_Date__c != null && sR.Start_Date__c <= exsR.End_Date__c)
                            || (sR.Start_Date__c <= exsR.End_Date__c && sR.Start_Date__c >= exsR.Start_Date__c)
                            || (sR.End_Date__c >= exsR.Start_Date__c && sR.End_Date__c <= exsR.End_Date__c)
                            || (exsR.Start_Date__c <= sR.End_Date__c && exsR.Start_Date__c >= sR.Start_Date__c)
                            || (exsR.End_Date__c >= sR.Start_Date__c && exsR.End_Date__c <= sR.End_Date__c))
                            //Add Error
                            throw new CustomException(Label.ERROR_UNIQUENESS_SR);       
                    }
                    
                    //Add Staff Relationship in map
                    mapSRsWithUK.get(uniqueKey).add(sR);
                
                } else {
                    
                    //Populate map
                    mapSRsWithUK.put(uniqueKey, new List<Staff_Relationship__c>{sR});
                }
            }
        }
        
        //Check for size
        if(mapsRsWithUK.size() > 0) {
            
            //Query through sRs
            for(Staff_Relationship__c sR : [Select Id, Relationship__c, From__c, To__c, End_Date__c, Start_Date__c From Staff_Relationship__c
                                             Where From__c IN : setFromIds AND To__c IN : setToIds AND Id NOT IN : staffRelationships]) {
                
                //Generate Unique Key
                String uniqueKey = sR.From__c + '-' + sR.To__c;
                
                //Check for Relationship type
                if(sR.Relationship__c != null)
                    uniqueKey = uniqueKey + '-' + sR.Relationship__c;
                
                //Check if any new record has same unique key
                if(mapsRsWithUK.containsKey(uniqueKey)) {
                    
                    //Loop through Staff Assignment
                    for(Staff_Relationship__c exsR : mapsRsWithUK.get(uniqueKey)) {
                        
                        //Check for current record’s effective date if conflicting with any existing one
                        if((sR.End_Date__c == null && exsR.End_Date__c == null)
                            || (sR.End_Date__c != null && exsR.End_Date__c == null && sR.End_Date__c >= exsR.Start_Date__c)
                            || (sR.End_Date__c == null && exsR.End_Date__c != null && sR.Start_Date__c <= exsR.End_Date__c)
                            || (sR.Start_Date__c <= exsR.End_Date__c && sR.Start_Date__c >= exsR.Start_Date__c)
                            || (sR.End_Date__c >= exsR.Start_Date__c && sR.End_Date__c <= exsR.End_Date__c)
                            || (exsR.Start_Date__c <= sR.End_Date__c && exsR.Start_Date__c >= sR.Start_Date__c)
                            || (exsR.End_Date__c >= sR.Start_Date__c && exsR.End_Date__c <= sR.End_Date__c))
                            //Add Error
                            throw new CustomException(Label.ERROR_UNIQUENESS_SR);       
                    }
                }                                               
            }   
        }
    }
    
     /**
     *  @description    :   This method use to change Start Date or End Date of My Relationship.
     *  
     *  @args           :   List<Staff_Relationship__c>, Map<Id, Staff_Relationship__c>
     *
     *  @return         :   void
     *
     **/
    public static void validateMyRelationship(List<Staff_Relationship__c> staffRelationships, Map<Id, Staff_Relationship__c> mapOldSRs) {
        
        //Set to hold staff Relationship Ids
        Set<Id> setSRIds = new Set<Id>();
        
        //Loop Through Staff Relationship
        for(Staff_Relationship__c sR : staffRelationships){
            
            //Check condition
            if(sR.Start_Date__c != mapOldSRs.get(sR.Id).Start_Date__c || sR.End_Date__c != mapOldSRs.get(sR.Id).End_Date__c)
                setSRIds.add(sR.Id);
        }
        
        //Check Set Size
        if(setSRIds.size() > 0){
            
            //List To Update My Relationship
            List<My_Relationships__c> myRelationships = new List<My_Relationships__c>();
            
            //Loop Througt My Relationship
            for(My_Relationships__c mR : [Select Id, Name, Start_Date__c, End_Date__c, Staff_Relationship__c, Staff_Relationship__r.Start_Date__c, Staff_Relationship__r.End_Date__c from My_Relationships__c 
                                      Where Staff_Relationship__c != null AND Staff_Relationship__c IN : setSRIds]){
                
                //Check Appropriate condition
                if(mR.Start_Date__c != mR.Staff_Relationship__r.Start_Date__c || mR.End_Date__c != mR.Staff_Relationship__r.End_Date__c){
                    
                    //Update Effective dates
                    mR.Start_Date__c = mR.Staff_Relationship__r.Start_Date__c;
                    mR.End_Date__c = mR.Staff_Relationship__r.End_Date__c;
                    
                    //Add My relationship to list for update
                    myRelationships.add(mR);
                }
            }
            
            //Update My Relationship
            if(myRelationships.size() > 0){
                update myRelationships;
            } 
        }
    }
        
}