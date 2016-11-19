/**
 *  Description     :   Helper class for Trigger_StaffHistory trigger.
 *
 *  Created By      :   Subhash Garhwal 
 *
 *  Created Date    :   8/21/2015
 *
 *  Revision Logs   :   V_1.0 - Created - CR-20150825-9182
 *                      V_1.1 - Modified - Subhash Garhwal - CR-20150825-9182 - 09/02/2015 - New method added - onChangeValue
 *                      V_1.2 - Modified - Rajeev Jain - CR-20151120-9402 - 04/21/2016 - Modified IncentiveChangeLog method logic
 *                    
 **/
public without sharing class StaffHistoryTriggerHelper {

    //Variable to co
    /**
     *  @description    :   This method is used to rename Staff History record
     *
     *  @args           :   List<Staff_History__c>
     *
     *  @return         :   void
     *
     **/
    public static void reNameStaffHistory(List<Staff_History__c> staffHistories) {
        
        //Set to hold the Staff Attributes Ids
        Set<Id> setSAIds = new Set<Id>();
        
        //Loop through Staff Histories to update name
        for(Staff_History__c sH : staffHistories) {
            
            //Check for name
            if(sH.Name != sH.SH_Name__c)
                setSAIds.add(sH.Id); 

        }
        
        //Check for list size
        if(setSAIds.size() > 0) {
            
            //List of Staff History
            List<Staff_History__c> staffAttributes = new List<Staff_History__c>();
        
            //Query through the Staff Attributes
            for(Staff_History__c SH : [Select Id, Name, SH_Name__c From Staff_History__c Where Id IN : setSAIds]) {
                
                //Check for name
                if(sH.Name != sH.SH_Name__c) {
                    
                    //Update name
                    sH.Name = sH.SH_Name__c;
                    
                    //Add in list
                    staffAttributes.add(sH);
                }
            }
            
            //Set flag to true to avoid rerun of the any trigger
            Util.BypassAllTriggers = true;
            
            //Check for size
            if(staffAttributes.size() > 0)
                update staffAttributes;  
            
            //Set flag to true to avoid rerun of the any trigger
            Util.BypassAllTriggers = false; 
        }
    }
    
    //V_1.2 - Modified - Rajeev Jain - CR-20151120-9402 - 04/21/2016 
    /**
     *  @description    :   This method is used to create Incentive Change Log, whenever a new Staff History inserted or Updated
     *                      
     *  
     *  @args           :   List<Staff_History__c>, map<Id, Staff_History__c>
     *
     *  @return         :   void
     *
     **/
    public static void createIncentiveChangeLog(List<Staff_History__c> staffAttributes, Map<Id, Staff_History__c> mapOldStaffAttributes){
    
        //List of Incentive Change logs
        List<Incentive_Change_Log__c> incentiveChangeLogs = new List<Incentive_Change_Log__c>();
        
        //Map to hold Staff Attribute additional data, Like we need to Compare ValueType etc.
        Map<Id, Staff_History__c> mapStaffAttributes = new Map<Id, Staff_History__c>([select Id, Name, Value_Type__c, Value_Type__r.Name, Value_Type__r.Category__c
                                                                                    from Staff_History__c where Id IN : staffAttributes]);
        //Loop Througt Staff History
        for(Staff_History__c sH : staffAttributes){
            
            //Inserts ICL Records when SA inserts 
            if(mapOldStaffAttributes == null){
                
                //Insert ICL Record If Value Type = Business Title OR Incentive Role OR Primary Collection Perspective
                Incentive_Change_Log__c iCL = new Incentive_Change_Log__c(Staff_History__c = sH.Id, 
                                                                          Change_Type__c = ISSPConstants.INCENTIVE_CHANGE_LOG_CHANGE_TYPE_NEW);
                if(mapStaffAttributes.containsKey(sH.Id) && mapStaffAttributes.get(sH.Id).Value_Type__r.Category__c == ISSPConstants.VALUE_TYPE_CATEGORY_BUSINESS_TITLE)
                    iCL.Change_Element__c = ISSPConstants.INCENTIVE_CHANGE_LOG_CHANGE_ElEMENT_BUSINESS_TITLE;
                else if(mapStaffAttributes.containsKey(sH.Id) && mapStaffAttributes.get(sH.Id).Value_Type__r.Category__c == ISSPConstants.VALUE_TYPE_CATEGORY_INCENTIVE_ROLE)
                    iCL.Change_Element__c = ISSPConstants.INCENTIVE_CHANGE_LOG_CHANGE_ElEMENT_INCENTIVE_ROLE;
                else if(sH.Lookup_Value__c != null) //Check if Value Type = Primary Collection Perspective
                    iCL.Change_Element__c = ISSPConstants.INCENTIVE_CHANGE_LOG_CHANGE_ElEMENT_PRIMARY_PROGRAM_COLLECTION;
                
                //Add to ICL List
                incentiveChangeLogs.add(iCL);       
            }else if(mapOldStaffAttributes != null && (sH.Start_Date__c != mapOldStaffAttributes.get(sH.Id).Start_Date__c || sH.End_Date__c != mapOldStaffAttributes.get(sH.Id).End_Date__c)) {
                
                //Insert ICL Record If Value Type = Business Title OR Incentive Role OR Primary Collection Perspective - For Update of Staff Attribute
                Incentive_Change_Log__c iCL = new Incentive_Change_Log__c(Staff_History__c = sH.Id, 
                                                                          Change_Type__c = ISSPConstants.INCENTIVE_CHANGE_LOG_CHANGE_TYPE_MODIFIED);
                
                if(mapStaffAttributes.containsKey(sH.Id) && mapStaffAttributes.get(sH.Id).Value_Type__r.Category__c == ISSPConstants.VALUE_TYPE_CATEGORY_BUSINESS_TITLE)
                    iCL.Change_Element__c = ISSPConstants.INCENTIVE_CHANGE_LOG_CHANGE_ElEMENT_BUSINESS_TITLE;
                else if(mapStaffAttributes.containsKey(sH.Id) && mapStaffAttributes.get(sH.Id).Value_Type__r.Category__c == ISSPConstants.VALUE_TYPE_CATEGORY_INCENTIVE_ROLE)
                    iCL.Change_Element__c = ISSPConstants.INCENTIVE_CHANGE_LOG_CHANGE_ElEMENT_INCENTIVE_ROLE;
                else if(sH.Lookup_Value__c != null)
                    iCL.Change_Element__c = ISSPConstants.INCENTIVE_CHANGE_LOG_CHANGE_ElEMENT_PRIMARY_PROGRAM_COLLECTION;
                        
                //check for start date
                if(sH.Start_Date__c != mapOldStaffAttributes.get(sH.Id).Start_Date__c){
                    iCL.Start_Date__c = sH.Start_Date__c;
                    iCL.Change_Value__c = ISSPConstants.INCENTIVE_CHANGE_LOG_CHANGE_VALUE_START_DATE;
                }
                
                //Check for end date 
                if(sH.End_Date__c != mapOldStaffAttributes.get(sH.Id).End_Date__c){
                    iCL.End_Date__c = sH.End_Date__c;
                    iCL.Change_Value__c = ISSPConstants.INCENTIVE_CHANGE_LOG_CHANGE_VALUE_END_DATE;
                }
                //Add to ICL List
                incentiveChangeLogs.add(iCL); 
            }    
        }
        //Insert Incentive Change Log
        if(incentiveChangeLogs.size() > 0)
            insert incentiveChangeLogs;  
    }
    /**
     *  @description    :  This methiod is to validate the data before inserting into database according to Rule picklist field value on the Parent
     *                     Value Type and Staff Member record
     *  
     *  @args           :   List<Staff_History__c>, map<Id, Staff_History__c>
     *
     *  @return         :   void
     *
     **/
    public static void preventDuplicates(List<Staff_History__c> staffAttributes, Map<Id, Staff_History__c> mapOldStaffAttributes){
        
        //Set to hold the Value Type Id
        Set<Id> setValueTypeId = new Set<Id>();
        
        //Loop through Staff History
        for(Staff_History__c sH : staffAttributes) {
            
            //Check for Appropriate condition to execute trigger logic
            if(sH.Value_Type__c != null && sH.Staff_Member__c != null && (mapOldStaffAttributes == null || sH.Start_Date__c != mapOldStaffAttributes.get(sH.Id).Start_Date__c
                || sH.End_Date__c != mapOldStaffAttributes.get(sH.Id).End_Date__c || sH.Value_Type__c != mapOldStaffAttributes.get(sH.Id).Value_Type__c))
                setValueTypeId.add(sH.Value_Type__c);
        }
        
        //Check for set size
        if(setValueTypeId.size() > 0) {
            
            //Map to hold the Value Types
            //This map hold all the Value Types according to set populate through Staff Attribute loop
            Map<Id, Value_Type__c> mapValueTypes = new Map<Id, Value_Type__c>([Select Id, Category__c, Rule__c From Value_Type__c Where Id IN : setValueTypeId
                                                    AND Rule__c !=: ISSPConstants.VALUE_TYPE_RULE_STAFF_MEMBER_MAY_HAVE_UNLIMITED_OVERLAPPING_RECORDS_FOR_THIS_ATTRIBUTE
                                                    AND Rule__c != null]);
            
            //Map to hold the Unique Key with List of Staff History
            //Unique Key may be the combination of diff. diff. type of values Like : Contact Id + Value Type Id OR Contact Id + Category etc..
            //This map is used in case of maultiple records rule (Rule is the picklist field on Value Type object)
            Map<String, List<Staff_History__c>> mapSMWithSAttributes = new Map<String, List<Staff_History__c>>();
            
            //Map to hold the Unique Key with List of Staff History
            //Unique Key may be the combination of diff. diff. type of values Like : Contact Id + Value Type Id OR Contact Id + Category etc..
            //This map is used in case of one record rule (Rule is the picklist field on Value Type object)
            Map<String, Staff_History__c> mapSMWithSingleSAttributes = new Map<String,Staff_History__c>();
            
            //Set to hold the Contact Ids
            Set<Id> setConIds = new Set<Id>();
            
            //Loop through Staff History
            //This loop is used to validate all the new data (If user insert data in bulk)
            for(Staff_History__c sH : staffAttributes) {
                
                //Check for Appropriate condition to execute trigger logic
                if(sH.Value_Type__c != null && sH.Staff_Member__c != null && (mapOldStaffAttributes == null || sH.Start_Date__c != mapOldStaffAttributes.get(sH.Id).Start_Date__c
                    || sH.End_Date__c != mapOldStaffAttributes.get(sH.Id).End_Date__c || sH.Value_Type__c != mapOldStaffAttributes.get(sH.Id).Value_Type__c)) {
                    
                    //Add Staff Member Id in set
                    setConIds.add(sH.Staff_Member__c);
                    
                    //Check if map contains Value Type
                    if(mapValueTypes.containsKey(sH.Value_Type__c)) {
                        
                        //Check for Rule field
                        //This is for unlimited rule 
                        if(mapValueTypes.get(sH.Value_Type__c).Rule__c == ISSPConstants.VALUE_TYPE_RULE_STAFF_MEMBER_MAY_HAVE_UNLIMITED_OVERLAPPING_RECORDS_FOR_THIS_ATTRIBUTE)
                            continue;
                        
                        //Check for Rule field
                        //This is for Single record rule (Signle record with Category or with Value Type)
                        else if(mapValueTypes.get(sH.Value_Type__c).Rule__c == ISSPConstants.VALUE_TYPE_RULE_STAFF_MEMBER_MAY_HAVE_ONLY_ONE_RECORD_FOR_THIS_ATTRIBUTE
                                || mapValueTypes.get(sH.Value_Type__c).Rule__c == ISSPConstants.VALUE_TYPE_RULE_STAFF_MEMBER_MAY_HAVE_ONLY_ONE_RECORD_ASSOCIATED_WITH_THIS_CATEGORY) {
                                
                            //Unique Key (This key holds the combination of Staff Member and Value Type/Category)
                            String uniqueKey = sH.Staff_Member__c + '-';
                            
                            //Check for rule
                            if(mapValueTypes.get(sH.Value_Type__c).Rule__c == ISSPConstants.VALUE_TYPE_RULE_STAFF_MEMBER_MAY_HAVE_ONLY_ONE_RECORD_FOR_THIS_ATTRIBUTE)
                                uniqueKey += mapValueTypes.get(sH.Value_Type__c).Id;
                            else
                                uniqueKey += mapValueTypes.get(sH.Value_Type__c).Category__c;
                            
                            //Check if single rule map contains the unique key
                            if(mapSMWithSingleSAttributes.containsKey(uniqueKey)) {
                                
                                //Add Error
                                throw new CustomException(mapValueTypes.get(sH.Value_Type__c).Rule__c == ISSPConstants.VALUE_TYPE_RULE_STAFF_MEMBER_MAY_HAVE_ONLY_ONE_RECORD_FOR_THIS_ATTRIBUTE
                                                          ? Label.SA_ONLY_HAVE_ONE_RECORD_PER_ATTRIBUTE
                                                          : Label.SA_ONLY_HAVE_ONE_RECORD_FOR_THIS_CATEGORY);
                            } else
                                mapSMWithSingleSAttributes.put(uniqueKey, sH);
                        
                        //Check for rule field
                        //This is for multiple records rule (Multiple reocrds with Category or with Value Type)
                        } else {
                            
                            //Unique (This key holds the combination of Staff Member and Value Type/Category)
                            String uniqueKey = sH.Staff_Member__c + '-';
                            
                            //Check for rule
                            if(mapValueTypes.get(sH.Value_Type__c).Rule__c == ISSPConstants.VALUE_TYPE_RULE_STAFF_MEMBER_MAY_HAVE_MULTIPLE_NON_OVERLAPPING_RECORDS_FOR_THIS_ATTRIBUTE)
                                uniqueKey += mapValueTypes.get(sH.Value_Type__c).Id;
                            else
                                uniqueKey += mapValueTypes.get(sH.Value_Type__c).Category__c;
                            
                            //Check if map multiple records map contains unique key
                            if(mapSMWithSAttributes.containsKey(uniqueKey)) {
                                
                                //Loop through related Staff Attributes records
                                for(Staff_History__c exiSH : mapSMWithSAttributes.get(uniqueKey)) {
                                    
                                    //Check for current records effective date if conflicting with any existing one
                                    if((sH.End_Date__c == null && exiSH.End_Date__c == null)
                                        || (sH.End_Date__c != null && exiSH.End_Date__c == null && sH.End_Date__c >= exiSH.Start_Date__c)
                                        || (sH.End_Date__c == null && exiSH.End_Date__c != null && sH.Start_Date__c <= exiSH.End_Date__c)
                                        || (sH.Start_Date__c <= exiSH.End_Date__c && sH.Start_Date__c >= exiSH.Start_Date__c)
                                        || (sH.End_Date__c >= exiSH.Start_Date__c && sH.End_Date__c <= exiSH.End_Date__c)
                                        || (exiSH.Start_Date__c <= sH.End_Date__c && exiSH.Start_Date__c >= sH.Start_Date__c)
                                        || (exiSH.End_Date__c >= sH.Start_Date__c && exiSH.End_Date__c <= sH.End_Date__c)) {
                                        
                                        //Add error
                                        throw new CustomException(mapValueTypes.get(sH.Value_Type__c).Rule__c == ISSPConstants.VALUE_TYPE_RULE_STAFF_MEMBER_MAY_HAVE_MULTIPLE_NON_OVERLAPPING_RECORDS_FOR_THIS_ATTRIBUTE
                                                          ? Label.SA_OVERLAPPING_FOR_ATTRIBUTE
                                                          : Label.SA_OVERLAPPING_FOR_CATEGORY);
                                                
                                    }
                                }
                                
                                //In case of valid data add Staff Attribute record in map
                                mapSMWithSAttributes.get(uniqueKey).add(sH);
                            
                            //Populate map with unique key and Staff Attribute
                            } else
                                mapSMWithSAttributes.put(uniqueKey, new List<Staff_History__c>{sH});
                        }
                    }       
                }
            }
            
            //Check for set size
            if(setConIds.size() > 0 && (mapSMWithSAttributes.size() > 0 || mapSMWithSingleSAttributes.size() > 0)) {
                
                //Query through Staff Attribute
                //This loop is used to check existing data in database
                for(Staff_History__c sH : [Select Id, Staff_Member__c, Value_Type__c, Value_Type__r.Category__c, Value_Type__r.Rule__c, Start_Date__c,
                                                 End_Date__c From Staff_History__c Where Staff_Member__c IN : setConIds AND Value_Type__c != null
                                                 AND Id NOT IN : staffAttributes]) {
                                                    
                    //Check for unlimited Rule
                    if(sH.Value_Type__r.Rule__c == ISSPConstants.VALUE_TYPE_RULE_STAFF_MEMBER_MAY_HAVE_UNLIMITED_OVERLAPPING_RECORDS_FOR_THIS_ATTRIBUTE)
                        continue;
                    
                    //Check for Rule field
                    //This is for Single record rule (Signle record with Category or with Value Type)
                    else if(sH.Value_Type__r.Rule__c == ISSPConstants.VALUE_TYPE_RULE_STAFF_MEMBER_MAY_HAVE_ONLY_ONE_RECORD_FOR_THIS_ATTRIBUTE
                            || sH.Value_Type__r.Rule__c == ISSPConstants.VALUE_TYPE_RULE_STAFF_MEMBER_MAY_HAVE_ONLY_ONE_RECORD_ASSOCIATED_WITH_THIS_CATEGORY) {
                            
                        //Unique Key (This key holds the combination of Staff Member and Value Type/Category)
                        String uniqueKey = sH.Staff_Member__c + '-';
                        
                        //Check for Rule
                        if(sH.Value_Type__r.Rule__c == ISSPConstants.VALUE_TYPE_RULE_STAFF_MEMBER_MAY_HAVE_ONLY_ONE_RECORD_FOR_THIS_ATTRIBUTE)
                            uniqueKey += sH.Value_Type__c;
                        else
                            uniqueKey += sH.Value_Type__r.Category__c;
                        
                        //Check if Single map contains the unique key
                        if(mapSMWithSingleSAttributes.containsKey(uniqueKey)) {
                            //Add Error
                            throw new CustomException(sH.Value_Type__r.Rule__c == ISSPConstants.VALUE_TYPE_RULE_STAFF_MEMBER_MAY_HAVE_ONLY_ONE_RECORD_FOR_THIS_ATTRIBUTE
                                                      ? Label.SA_ONLY_HAVE_ONE_RECORD_PER_ATTRIBUTE
                                                      : Label.SA_ONLY_HAVE_ONE_RECORD_FOR_THIS_CATEGORY);
                        }
                    
                    //Check for rule field
                    //This is for multiple records rule (Multiple reocrds with Category or with Value Type)
                    } else {
                        
                        //Unique (This key holds the combination of Staff Member and Value Type/Category)
                        String uniqueKey = sH.Staff_Member__c + '-';
                        
                        //Check for rule
                        if(sH.Value_Type__r.Rule__c == ISSPConstants.VALUE_TYPE_RULE_STAFF_MEMBER_MAY_HAVE_MULTIPLE_NON_OVERLAPPING_RECORDS_FOR_THIS_ATTRIBUTE)
                            uniqueKey += sH.Value_Type__c;
                        else
                            uniqueKey += sH.Value_Type__r.Category__c;
                        
                        //Check if map multiple records map contains unique key
                        if(mapSMWithSAttributes.containsKey(uniqueKey)) {
                            
                            //Loop through related Staff Attributes records
                            for(Staff_History__c exiSH : mapSMWithSAttributes.get(uniqueKey)) {
                                
                                //Check for current records effective date if conflicting with any existing one
                                if((sH.End_Date__c == null && exiSH.End_Date__c == null)
                                    || (sH.End_Date__c != null && exiSH.End_Date__c == null && sH.End_Date__c >= exiSH.Start_Date__c)
                                    || (sH.End_Date__c == null && exiSH.End_Date__c != null && sH.Start_Date__c <= exiSH.End_Date__c)
                                    || (sH.Start_Date__c <= exiSH.End_Date__c && sH.Start_Date__c >= exiSH.Start_Date__c)
                                    || (sH.End_Date__c >= exiSH.Start_Date__c && sH.End_Date__c <= exiSH.End_Date__c)
                                    || (exiSH.Start_Date__c <= sH.End_Date__c && exiSH.Start_Date__c >= sH.Start_Date__c)
                                    || (exiSH.End_Date__c >= sH.Start_Date__c && exiSH.End_Date__c <= sH.End_Date__c)) {
                                    
                                    //Add error
                                    throw new CustomException(sH.Value_Type__r.Rule__c == ISSPConstants.VALUE_TYPE_RULE_STAFF_MEMBER_MAY_HAVE_MULTIPLE_NON_OVERLAPPING_RECORDS_FOR_THIS_ATTRIBUTE
                                                      ? Label.SA_OVERLAPPING_FOR_ATTRIBUTE
                                                      : Label.SA_OVERLAPPING_FOR_CATEGORY);
                                            
                                }
                            }
                        }                                       
                    }
                }
            } 
        }
    }
    
    /**
     *  @description    :   Method is use to assign source Corresponding to User  
     *  
     *  @args           :   List<Staff_History__c>
     *
     *  @return         :   void
     *
     **/
    public static void assignSource(List<Staff_History__c> staffAttributes){
        
        //Loop Through staff History.
        for(Staff_History__c sH : staffAttributes){
            
            //Assign Source
            if(Userinfo.getUserName() == Label.INTEGRATION_USER_NAME) 
                sH.Source__c = ISSPConstants.STAFF_ATTRIBUTE_SOURCE_INTEGRATION;
            else
                sH.Source__c = ISSPConstants.STAFF_ATTRIBUTE_SOURCE_NATIVE;
        }
    }
    
    //Modified - Subhash Garhwal - CR-20150825-9182 - 09/02/2015 - New method added - onChangeValue
    /**
     *  @description    :   Method is use to Override the Value assignment to be Text-based, and use the Name
     *                      of the associated Value Type as the Text Value.
     *  
     *  @args           :   List<Staff_History__c> , Map<Id, Staff_History__c> 
     *
     *  @return         :   void
     *
     **/
    public static void onChangeValues(List<Staff_History__c> staffAttributes, Map<Id, Staff_History__c> mapOldStaffAttributes){
    
        //set to hold Value type Ids
        Set<Id> setVTIds = new Set<Id>();
            
        //Loop Through staff History.
        for(Staff_History__c sH : staffAttributes){
            
            //Check when fields value are changed then fill the set
            if(sH.Value_Type__c != null)
                setVTIds.add(sH.Value_Type__c);
        }
        
        //Check set size 
        if(setVTIds.size() > 0) {
            
            //Map to hold Id and name of value type 
            Map<Id, String> mapValueTypes = new Map<Id, String>();
            
            //Loop Through value type and fetching record using query
            for(Value_Type__c VT : [Select Id, Name from Value_Type__c where Id IN : setVTIds AND Use_As_Value__c = true]){
        
                //Put id and name of value type in map  
                mapValueTypes.put(VT.Id, VT.Name);
            }
            
            //Check map size
            if(mapValueTypes.size() > 0){
            
                //Loop Through staff History.
                for(Staff_History__c sH : staffAttributes){
        
                    //Check value type in map
                    if(mapValueTypes.containsKey(sH.Value_Type__c)){
                    
                        //Set new values
                        sH.Text_Value__c = mapValueTypes.get(sH.Value_Type__c);
                        sH.Checkbox_Value__c = false;
                        sH.Number_Value__c = null;
                        sH.Percent_Value__c = null;
                        sH.Date_Value__c = null;
                        sH.Lookup_Value__c = null;
                    }
                }
            }
        }
    }
    
    //Modified - Subhash Garhwal - CR-20150825-9182 - 09/18/2015 - New method added - CalculateCount
    /**
     *  @description    :   Method is use to Calculate count.
     *  
     *  @args           :   List<Staff_History__c> 
     *
     *  @return         :   void
     *
     **/
    public static void calculateCount(List<Staff_History__c> staffAttributes){
    
        //set to hold Value type Ids
        Set<Id> setVTIds = new Set<Id>();
        
        //Loop Through staff History.
        for(Staff_History__c sH : staffAttributes){
        
            //Set to add value type Id
            setVTIds.add(sH.Value_Type__c);
        }
    
        //Check for set size
        if(setVTIds.size() > 0) {   
        
            //Map to hold Id and value type
            Map<Id, Value_Type__c> mapValueTypes = new Map<Id, Value_Type__c>([Select Id, Values_Permitted__c From Value_Type__c Where 
                                                                                                                   Id IN : setVTIds]);
            
            //Loop Through staff History.
            for(Staff_History__c sH : staffAttributes){
        
                //Set count
                Integer counts = (String.isNotBlank(sH.Text_Value__c) ? 1 : 0) + 
                                 (sH.Lookup_Value__c != null ? 1 : 0) + 
                                 (sH.Date_Value__c != null ? 1 : 0) + 
                                 (sH.Number_Value__c != null ? 1 : 0) + 
                                 (sH.Percent_Value__c != null ? 1 : 0) + 1;
                                 
                //Check for value permitted if select checkbox then throw exception
                if(mapValueTypes.get(sH.Value_Type__c).Values_Permitted__c.equalsIgnoreCase(ISSPConstants.STAFF_ATTRIBUTES_CHECKBOX) && counts != 1)
                    throw new CustomException(Label.CHECKBOX_ON_STAFF_ATTRIBUTES);
                    
                //Check if check box is not selectd
                else if(!mapValueTypes.get(sH.Value_Type__c).Values_Permitted__c.equalsIgnoreCase(ISSPConstants.STAFF_ATTRIBUTES_CHECKBOX) && !sH.Checkbox_Value__c)
                    counts--;
                        
                //Check count value
                if(counts != 1)
                    throw new CustomException(Label.CHECKBOX_ON_STAFF_ATTRIBUTES);
            }
        }
    }
}