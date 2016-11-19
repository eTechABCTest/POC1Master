/**
*   Purpose:    Contains methods to assist the member support trigger
*               
*   Create By:  Victor Hanson
*    
*    Revision Log:       V1.0 - (Code Added)- Victor Hanson - 11/29/2012 - Created
*                        V1.1 - (Code Added)- Victor Hanson - 04/03/2014 - Crimson Community Project
*                        V1.2 - Modified By - Abhinav Sharma - 07/12/2014 - CR-20140422-5173 - Method Added (UpdateAssigndToContactOnSiteIssueByProject)
*                        V1.3 - Modified By - Ajit Surana - 10/16/2014 - CR-20140725-6664 - Method Added - (updateExpectedFileReceivedDateOnProject)
*                        V1.4 - Modified By - Ajit Surana - 10/20/2014 - CR-20140915-7353 - Method modified (SendDataLoadAutoEmail)
*                        V1.5 - Modified By - Ajit Surana - 1/21/2015 - CR-20150102-8430 - Method modified (UpdateProjectBySiteIssue)
*                        V1.6 - Modified By - Ajit Surana - 01/23/2015 - CR-20140716-6259 - Method modified (UpdateSiteIssueByProject) 
*                        V1.7 - Modified By - Abhinav Sharma - 01/29/2015 - CR-20141218-8363 - Added a new Method (populateCPRMDataLoadFields)
*                        V1.8 - Modified By - Abhinav Sharma - 04/02/2015 - CR-20130913-3640
*                        V1.9 - Modified By - Abhinav Sharma - 12/02/2015 - CR-20140623-5897
*                        V1.10 - Modified By - Ajit Surana - 02/16/2015 - CR-20150106-8468 - Method modified (SendDataLoadAutoEmail)
*                        V1.11 - Modified By - Ajit Surana - 02/27/2015 - Added a new method - validateContactFlagValues
*                        V1.12 - Modified By - Ajit Surana - 05/06/2015 - CR-20140813-6993 - Added a new method - validateAndPopulateQANotes
*                        V1.13 - Modified By - Mahendra Swarnkar - 06/11/2015 - CR-20150529-8971 - Erroneous email bounce messages
*                        V1.14 - Modified By - Abhinav Sharma - 07/29/2015 - CR-20150709-9070 - Added a new Method - populateFieldsOnAssociatedProject
*                        V1.15 - Modified By - Abhinav Sharma - 08/24/2015 - CR-20150127-8596 - Added a new method - populateCPRMCurrentDataPeriodOnProject
*                        V1.16 - Abhinav Sharma - 11/03/2015 - CR-20151016-9329 - Modified existing method (populateFieldsOnAssociatedProject)
*                        V1.17 - Abhinav SHarma - 11/28/2015 - CR-20150601-8977 - Modified existing method (populateCPRMDataLoadFields)
*                        V1.18 - Victor Hanson - 3/13/2016 - CR-20160413-9760 - Added a new method - populateInstitutionFormalName
*                        V1.19 - Abhinav Sharma - 04/01/2016 - CR-20160224-9632 - Added new method - (validateFieldsValueChangesForCrimsonAndPTDataLoadMS)
*                        V1.20 - Modified By - Mahendra Swarnkar - 07/07/2016 - CR-20160609-9913 - Modified the existing method  "populateCPRMDataLoadFields".
*						 V1.21 - Modified By - Mahendra Swarnkar- CR-20160114-9520 - 08/23/2016 - Added a "calculateBusinessHoursAges" method to populate fields on Member Support object
*						 V1.22 - Modified By - Mahendra Swarnkar - CR-20160420-9785 - 09/01/2016 - Added a new Methods "populateMarketDataPeriodFieldsOnProject" and "populateMarketDataPeriodFields" to populate the Market data period begin and Market data period End Fields on MS and then on Project
**/
public without sharing class MemberSupportTriggerUtilities {
    
    //Static flag to control the execution of SendDataLoadAutoEmail
    public static Boolean EXECUTE_SEND_DATA_LOAD_AUTO_EMAIL = true;
    public static Boolean IS_UPDATE_HAPPENS_ON_INSERT_EVENT = false;
    
    public static Boolean IS_ALREADY_EXECUTED_ONCE = false;
    public final static String MEMBER_SUPPORT_OBJECT = 'Site_Issue__c';
    public final static String SITE_ISSUE_TIER_IV = 'Tier IV';
    
    /**
     *  @description    :   Method to hold the logic to validate/restrict users
     *                      for changing certain fields values without use of approriate buttons
     *                      on member support records of "Crimson Support Request" and "CCA Data Load" record type
     *
     *  @args           :   List of new site issues, Old Map of Site Issues
     *
     *  @return         :   void
     *
    **/
    //Added By - Abhinav Sharma - 04/01/2016 - CR-20160224-9632
    //Start From here
    public static void validateFieldsValueChangesForCrimsonAndPTDataLoadMS(List<Site_Issue__c> newMemberSupports, Map<Id, Site_Issue__c> mapOldMemberSupports) {
        
        //Checking for the insert event
        if(mapOldMemberSupports == null) {
            
            //Setting flag value to true
            IS_UPDATE_HAPPENS_ON_INSERT_EVENT = true;
        }
        
        //Start from here        
        //This code will only execute in the update use cases
        if(mapOldMemberSupports != null && !IS_ALREADY_EXECUTED_ONCE && !IS_UPDATE_HAPPENS_ON_INSERT_EVENT) {
            
            // get the ABC Dataloader profile id
            Id dataloaderProfileId = label.ABC_Dataloader_Profile_Id;
            
            //Bypass the below written logic for ABC Dataloader profile users
            //This way data update can take place over the existing records
            if (dataloaderProfileId != null 
                && UserInfo.getProfileId() == dataloaderProfileId) {
            
                //Do nothing and just bypass the validation logic        
            
            } else {
                
                //Setting flag value to true
                IS_ALREADY_EXECUTED_ONCE = true;
            
                //Get all record types on member support object
                Map<String, Id> memeberSupportRecordTypesMap = Util.recordtypemap(MEMBER_SUPPORT_OBJECT);
    
                //Get member support record types
                Map<Id, String> mapRecordTypes = new Map<Id, String>();
        
                //Looping over map keyset and accordingly populating collection with map retrieved values
                for(String recordTypeLabel : memeberSupportRecordTypesMap.keySet()) {
                
                    //Populating map to hold the case record type Id as key and correspodning record type label as value
                    if(String.isNotBlank(recordTypeLabel) 
                       && memeberSupportRecordTypesMap.containsKey(recordTypeLabel)
                       && memeberSupportRecordTypesMap.get(recordTypeLabel) != null)
                        mapRecordTypes.put(memeberSupportRecordTypesMap.get(recordTypeLabel), recordTypeLabel);
                }       
        
                //Loop through member support records
                for(Site_Issue__c sI : newMemberSupports) {
                    
                    //Checking record for eligibilty and throwing an error accordingly
                    if(sI.RecordTypeId != null 
                        && mapRecordTypes.containsKey(sI.RecordTypeId)
                        && mapRecordTypes.get(sI.RecordTypeId) != null) {
                        
                        //Validation "Crimson Support Request" record type based member support record for field changes
                        if((mapRecordTypes.get(sI.RecordTypeId) == Constants.RECORD_TYPE_SITE_ISSUE_CCA_SUPPORT_REQUEST
                            && sI.Button_Used__c == false)
                            && (
                                (
                                    sI.Assigned_to_Contact__c == null //CR-20160511-9849
                                    &&
                                    (
                                    
                                        (
                                            mapOldMemberSupports.get(sI.Id).Status__c == System.Label.STATUS_NEW_VALUE_FOR_CRIMSON_SUPPORT_MS
                                            &&
                                            sI.Status__c != mapOldMemberSupports.get(sI.Id).Status__c
                                            && sI.Status__c != System.Label.MS_STATUS_DUPLICATE_OR_CANCELLED
                                        )
                                        ||
                                        sI.OwnerId != mapOldMemberSupports.get(sI.Id).OwnerId
                                        ||
                                        sI.Tier_I_Support_Analyst__c != mapOldMemberSupports.get(sI.Id).Tier_I_Support_Analyst__c
                                    )
                                )
                                || (sI.Tier__c != mapOldMemberSupports.get(sI.Id).Tier__c
                                   && sI.Tier__c != Constants.SITE_ISSUE_TIER_III
                                   && sI.Tier__c != SITE_ISSUE_TIER_IV)
                            )
                        )
                            sI.addError(System.Label.ERROR_CASE_DIRECT_FIELDS_CHANGES);
                        
                        //Validation "CCA Data Load" record type based member support record for field changes
                        if((mapRecordTypes.get(sI.RecordTypeId) == Constants.RECORD_TYPE_SITE_ISSUE_CCA_DATA_LOAD
                            && sI.Button_Used__c == false)
                            && (
                                /*(
                                    mapOldMemberSupports.get(sI.Id).Status__c == System.Label.STATUS_NEW_VALUE_FOR_CCA_DATA_LOAD_MS
                                    &&
                                    sI.Status__c != mapOldMemberSupports.get(sI.Id).Status__c
                                    && sI.Status__c != System.Label.MS_STATUS_DUPLICATE_OR_CANCELLED
                                )*/
                                (sI.OwnerId != mapOldMemberSupports.get(sI.Id).OwnerId)
                                || (sI.Tier__c != mapOldMemberSupports.get(sI.Id).Tier__c
                                   && sI.Tier__c != Constants.SITE_ISSUE_TIER_III
                                   && sI.Tier__c != SITE_ISSUE_TIER_IV)
                                || (sI.Tier_I_Support_Analyst__c != mapOldMemberSupports.get(sI.Id).Tier_I_Support_Analyst__c)
                            )
                        )
                            sI.addError(System.Label.ERROR_CASE_DIRECT_FIELDS_CHANGES); 
                            
                        //Checking for the field value
                        if(sI.Button_Used__c == true)
                            sI.Button_Used__c = false;
                            
                    } else {
                        sI.Button_Used__c = false;        
                    }
                }
            }
        }
    }
    
    /**
     *  @description    :   Method to hold the logic to populate QA Notes field on MS record on insert of it.
     *
     *  @args           :   List of new site issues
     *
     *  @return         :   void
     *
    **/
    //Added By - 05/06/2015 - CR-20141218-8363 - Abhinav Sharma - 05/06/2015 -  CR-20140813-6993
    //Start From here
    public static void validateAndPopulateQANotes(List<Site_Issue__c> newMemberSupports) {
        
        //Map to hold the eligible record type(s)
        Map<Id, RecordType> mapRecordTypes = new Map<Id, RecordType>([SELECT ID FROM RecordType 
                                                                        WHERE sObjectType = 'Site_Issue__c' 
                                                                        AND IsActive = true 
                                                                        AND DeveloperName = 'CMA_Data_Load_Production']);
                                            
        //Checking record type for it existance
        if(mapRecordTypes != null && mapRecordTypes.values().size() > 0) {
    
            //Set to hold the parent project records ID value
            Set<Id> setProjectIds = new Set<Id>();
        
            //Loop through the MS record
            for(Site_Issue__c mSupport : newMemberSupports) {
        
                //Only proceed with the MS record:- If Record Type = CMA Data Load/Migration AND Data Load Type = Current
                if(mSupport.Project__c != null 
                    && mSupport.RecordTypeId != null
                    && mapRecordTypes.containsKey(mSupport.RecordTypeId)
                    && mapRecordTypes.get(mSupport.RecordTypeId) != null
                    && mSupport.Data_Load_Type__c == 'Current')
                    setProjectIds.add(mSupport.Project__c);
            }
            
            //Map to hold project ID as key and Member support record as value
            Map<Id,Site_Issue__c> mapProjectIdwithMSupport = new Map<Id,Site_Issue__c>();
            
            //Searching for the another Member Support ticket on the same project with the following criteria:
            //Record Type = CMA Data Load/Migration
            //Data Load Type = Current
            //Status = 22 - Production Migration Complete
            //Date/Time Closed = Most recent date.
            for(Site_Issue__c mS : [Select Id, Name, QA_Notes_and_Comments__c, Project__c From Site_Issue__c 
                                            Where Project__c != null AND Project__c IN : setProjectIds
                                            AND RecordTypeId != null AND RecordTypeId IN : mapRecordTypes.keySet()
                                            AND Data_Load_Type__c = 'Current'
                                            AND Status__c = '22 - Production Migration Complete'
                                            AND Site_Issue_Close_Date__c != null
                                            Order By Site_Issue_Close_Date__c DESC]) {
                //Checking if map contains the key. If not, then populate it with the same.
                if(!mapProjectIdwithMSupport.containsKey(mS.Project__c))
                    mapProjectIdwithMSupport.put(mS.Project__c, mS);
            }
            
            //Loop through MS records and populating "QA Notes" field accordingly
            for(Site_Issue__c mSupport : newMemberSupports) {
                
                //Checking if map contains the key
                if(mSupport.Project__c != null 
                    && mapProjectIdwithMSupport.containsKey(mSupport.Project__c) 
                    && mapProjectIdwithMSupport.get(mSupport.Project__c) != null) {
                    
                    //Variable to hold the QA notes    
                    String qANotes = '';
                        
                    //Constructing QA notes concatinated string and populate field with value    
                    if(String.isNotBlank(mapProjectIdwithMSupport.get(mSupport.Project__c).QA_Notes_and_Comments__c)) {
                        qANotes += mapProjectIdwithMSupport.get(mSupport.Project__c).Name;
                        qANotes += '<br/><br/>';
                        qANotes += mapProjectIdwithMSupport.get(mSupport.Project__c).QA_Notes_and_Comments__c;
                        if(String.isNotBlank(mSupport.QA_Notes_and_Comments__c)) {
                            qANotes += '<br/>';
                            qANotes += mSupport.QA_Notes_and_Comments__c;
                        }    
                        
                        mSupport.QA_Notes_and_Comments__c = qANotes;
                    }
                }            
            }    
        }
    }
    
    //Modified By - Abhinav Sharma - 11/28/2015 - CR-20150601-8977
    /**
     *  @description    :   Method to populate the following fields on MS tickets from "Project" level 
                            having record type = 'CPRM Data Laod'
                            1) Notes: Implementation and Data
                            2) Crimson: Data Lag
                            3) Production Business Analyst
                            4) Project: Data Analyst Group Lead
                            5) Data Analyst
     *
     *  @args           :   List of new site issues
     *
     *  @return         :   void
     *
    **/
    //Added By - 01/29/2015 - CR-20141218-8363 - Abhinav Sharma
    public static void populateCPRMDataLoadFields(List<Site_Issue__c> newMemberSupports, Map<Id, Site_Issue__c> mapOldMemberSupports) {
    
        //List to hold the record type
        Map<Id, RecordType> mapRecordTypes = new Map<Id, RecordType>([SELECT ID FROM RecordType 
                                                                        WHERE sObjectType = 'Site_Issue__c' AND IsActive = true 
                                                                        AND DeveloperName = 'CPRM_Data_Load']);
                                            
        //Checking record type for it existance
        if(mapRecordTypes != null && mapRecordTypes.values().size() > 0) {
            
            //Addd By - Mahendra Swarnkar - CR-20160609-9913 - 7/7/2016 - Starts from here
            //List to hold the all company holidays
            List<Case_Blackout_Days__c> holidays = Util.LIST_OF_COMPANY_HOLIDAYS;
            //Addd By - Mahendra Swarnkar  - CR-20160609-9913 - 7/7/2016 - Ends here
            
            //Set to hold the project records ID value
            Set<Id> setProjectIds = new Set<Id>();
        
            //Loop through new member support records
            for(Site_Issue__c sIssue : newMemberSupports) {
                if(sIssue.Project__c != null)
                    setProjectIds.add(sIssue.Project__c);
            }
            
            //Checking set for size value
            if(setProjectIds.size() > 0) {
            
                //Map of Projects
                Map<Id, Project__c> mapProjects = new Map<Id, Project__c>([SELECT ID, Notes_Implementation__c, Crimson_Data_Lag__c, 
                                                                            Recurring_Business_Analyst__c, Milliman_Analyst__c,
                                                                            Crimson_Data_Analyst_Group_Lead__c, Data_Analyst__c,
                                                                            Custom_SQL__c
                                                                            FROM Project__c WHERE ID IN : setProjectIds]);
                //Loop through new member support records
                for(Site_Issue__c sI : newMemberSupports) {
                
                    //Populating fields on member support record. With the corresponding field value from associated project.
                    //Only for CPRM Data Laod record type member support records
                    if(sI.Project__c != null && sI.RecordTypeId != null 
                        && mapRecordTypes.get(sI.RecordTypeId) != null) {
                        sI.Notes_Recurring_Data__c = mapProjects.get(sI.Project__c).Notes_Implementation__c;
                        sI.Crimson_Data_Lag_1__c = mapProjects.get(sI.Project__c).Crimson_Data_Lag__c; 
                        sI.Data_Analyst_Group_Lead__c = mapProjects.get(sI.Project__c).Crimson_Data_Analyst_Group_Lead__c; 
                        sI.Milliman_Analyst__c= mapProjects.get(sI.Project__c).Milliman_Analyst__c;
                        sI.Custom_SQL__c = mapProjects.get(sI.Project__c).Custom_SQL__c;  
                        
                        //Modified By - Abhinav Sharma - 11/28/2015 - CR-20150601-8977
                        //Start from here
                        //Data Analyst, Production Business Analyst" will only auto populate with values for project in case of creation 
                        //of it. 
                        //No update/auto populate will take place for both the fields in case of update of a member support record(s).
                        if(mapOldMemberSupports == null) { 
                            sI.Crimson_Data_Analyst__c = mapProjects.get(sI.Project__c).Data_Analyst__c; 
                            sI.Production_Business_Analyst__c = mapProjects.get(sI.Project__c).Recurring_Business_Analyst__c;
                        }    
                    }
                }
            }
            
            //Populating elapsed field with date field differences (Excluding weekends)
            //Loop through new member support records
            for(Site_Issue__c sIssue : newMemberSupports) {
                
                //Populating fields on member support record.
                //Only for CPRM Data Laod record type member support records
                if(sIssue.RecordTypeId != null && mapRecordTypes.containsKey(sIssue.RecordTypeId)
                    && mapRecordTypes.get(sIssue.RecordTypeId) != null) {
                    
                    //Elapsed: Files Rec'd to Diagnostics Sent - Elapsed_Files_Rec_d_to_Diagnostics_Sent__c
                    if(sIssue.Diagnostics_Sent__c != null && sIssue.Files_Received__c != null)
                        sIssue.Elapsed_Files_Rec_d_to_Diagnostics_Sent__c = Util.bussinessDaysDifferenceInBetweenDates(sIssue.Files_Received__c, sIssue.Diagnostics_Sent__c);
                    else
                        sIssue.Elapsed_Files_Rec_d_to_Diagnostics_Sent__c = null;
                       
                    //Elapsed: Files Rec'd to Moved to Prod  - Elapsed_Files_Rec_d_to_Moved_to_Prod__c   
                    if(sIssue.Moved_to_Production__c != null && sIssue.Files_Received__c != null)
                        sIssue.Elapsed_Files_Rec_d_to_Moved_to_Prod__c = Util.bussinessDaysDifferenceInBetweenDates(sIssue.Files_Received__c, sIssue.Moved_to_Production__c);
                    else
                        sIssue.Elapsed_Files_Rec_d_to_Moved_to_Prod__c = null;
                        
                    //Elapsed: Prod Migr Appr to Moved to Prod - Elapsed_Prod_Migr_Appr_to_Moved_to_Prod__c
                    if(sIssue.Moved_to_Production__c != null && sIssue.Production_Migration_Approved__c != null)
                        sIssue.Elapsed_Prod_Migr_Appr_to_Moved_to_Prod__c = Util.bussinessDaysDifferenceInBetweenDates(sIssue.Production_Migration_Approved__c, sIssue.Moved_to_Production__c);
                    else
                        sIssue.Elapsed_Prod_Migr_Appr_to_Moved_to_Prod__c = null;
                        
                    //Elapsed: QA Complete to Prod Migr Appr - Elapsed_QA_Complete_to_Prod_Migr_Appr__c    
                    if(sIssue.Production_Migration_Approved__c != null && sIssue.Final_QA_Complete__c != null)
                        sIssue.Elapsed_QA_Complete_to_Prod_Migr_Appr__c = Util.bussinessDaysDifferenceInBetweenDates(sIssue.Final_QA_Complete__c, sIssue.Production_Migration_Approved__c);
                    else
                        sIssue.Elapsed_QA_Complete_to_Prod_Migr_Appr__c = null;
                        
                    //Elapsed: Testing Complete to QA Complete - Elapsed_Testing_Complete_to_QA_Complete__c    
                    if(sIssue.Final_QA_Complete__c != null && sIssue.Testing_Complete__c != null)
                        sIssue.Elapsed_Testing_Complete_to_QA_Complete__c = Util.bussinessDaysDifferenceInBetweenDates(sIssue.Testing_Complete__c, sIssue.Final_QA_Complete__c);
                    else
                        sIssue.Elapsed_Testing_Complete_to_QA_Complete__c = null;
                        
                    //Elapsed: DB Rec'd to Testing Complete - Elapsed_DB_Rec_d_to_Testing_Complete__c    
                    if(sIssue.Testing_Complete__c != null && sIssue.DB_Received_from_Milliman__c != null)
                        sIssue.Elapsed_DB_Rec_d_to_Testing_Complete__c = Util.bussinessDaysDifferenceInBetweenDates(sIssue.DB_Received_from_Milliman__c, sIssue.Testing_Complete__c);
                    else
                        sIssue.Elapsed_DB_Rec_d_to_Testing_Complete__c = null;
                        
                    //Elapsed: Files Sent to MM to DB Rec'd - Elapsed_Files_Sent_to_MM_to_DB_Rec_d__c    
                    if(sIssue.DB_Received_from_Milliman__c != null && sIssue.Files_Sent_to_Milliman__c != null)
                        sIssue.Elapsed_Files_Sent_to_MM_to_DB_Rec_d__c = Util.bussinessDaysDifferenceInBetweenDates(sIssue.Files_Sent_to_Milliman__c, sIssue.DB_Received_from_Milliman__c);
                    else
                        sIssue.Elapsed_Files_Sent_to_MM_to_DB_Rec_d__c = null;
                        
                    //Elapsed: Diag Sent to Files Sent to MM - Elapsed_Diag_Sent_to_Files_Sent_to_MM__c    
                    if(sIssue.Files_Sent_to_Milliman__c != null && sIssue.Diagnostics_Sent__c != null)
                        sIssue.Elapsed_Diag_Sent_to_Files_Sent_to_MM__c = Util.bussinessDaysDifferenceInBetweenDates(sIssue.Diagnostics_Sent__c, sIssue.Files_Sent_to_Milliman__c);
                    else
                        sIssue.Elapsed_Diag_Sent_to_Files_Sent_to_MM__c = null;
                        
                    //Modified By - Mahendra Swarnkar- CR-20160609-9913 - 7/7/2016 - passes the company holidays as an argument in the AddBusinessDays method - Starts from here
                    //Expected_Completion_Date_Calculated__c    
                    if(sIssue.Files_Received__c != null)
                        sIssue.Expected_Completion_Date_Calculated__c = Util.AddBusinessDays(sIssue.Files_Received__c, 10, holidays);
                    //Modified By - Mahendra Swarnkar- CR-20160609-9913 -passes the company holidays as an argument in the AddBusinessDays method - 7/7/2016 -Ends here
                }
            }                
        }
    }
    
    /**
     *  @description    :   Method to populate the following fields on MS tickets from "Project" level 
                            for record types "CCA Data Load" & "Crimson Support Request"
                            1) Technical Project Manager
                            
     *  @args           :   List of new site issues
     *
     *  @return         :   void
     *
    **/
    //Added By - Abhinav Sharma - 12/02/2015 - CR-20140623-5897
    public static void populateManagerFields(List<Site_Issue__c> newSiteIssues) {
        
        //List to hold the record type
        Map<Id, RecordType> mapRecordTypes = new Map<Id, RecordType>([SELECT ID FROM RecordType 
                                                                        WHERE sObjectType = 'Site_Issue__c' AND IsActive = true 
                                                                        AND (DeveloperName = 'CCA_Data_Load' OR DeveloperName = 'CCA_Support_Request')]);
        //Checking record type for it existance
        if(mapRecordTypes != null && mapRecordTypes.values().size() > 0) {
            
            //Set to hold the project records ID value
            Set<Id> setProjectIds = new Set<Id>();
        
            //Loop through new member support records
            for(Site_Issue__c sIssue : newSiteIssues) {
                if(sIssue.Project__c != null)
                    setProjectIds.add(sIssue.Project__c);
            }
                
            //Map of Projects
            Map<Id, Project__c> mapProjects = new Map<Id, Project__c>([SELECT ID, Project_Manager__c, Project_Manager__r.Name
                                                                        FROM Project__c WHERE ID IN : setProjectIds]);
                
            //Loop through new member support records
            for(Site_Issue__c sI : newSiteIssues) {
                
                //Populating fields on member support record. With the corresponding field value from associated project.
                if(sI.RecordTypeId != null && mapRecordTypes.containsKey(sI.RecordTypeId)
                    && mapRecordTypes.get(sI.RecordTypeId) != null) {
                    //Checking if project is there stamped on the member support record
                    if(sI.Project__c != null && mapProjects.get(sI.Project__c) != null) {
                        if(mapProjects.get(sI.Project__c).Project_Manager__c != null)
                            sI.Technical_Project_Manager_new__c = mapProjects.get(sI.Project__c).Project_Manager__r.Name;
                        else
                            sI.Technical_Project_Manager_new__c = null;
                    } else {
                        sI.Technical_Project_Manager_new__c = null;
                    }
                }
            }
        }   
    }

  public static void CalculateAssignment(Map<Id, Site_Issue__c> oldMap, List<Site_Issue__c> triggerNew) {
    
    Map<String, Member_Support_Assignment__c> assignments = Member_Support_Assignment__c.getAll();
    
    Set<String> recordNames = new Set<String>();
    Set<String> userNames = new Set<String>();
    for (Member_Support_Assignment__c assignment : assignments.values()) {
      recordNames.add(assignment.Record_Type_Name__c);
      userNames.add(assignment.Username__c);
    }

    // get the deployment ids
    Set<Id> deploymentIds = new Set<Id>();
    for (Site_Issue__c newIssue : triggerNew)
      deploymentIds.add(newIssue.Deployment__c);
    Map<Id, Deployment__c> deploymentMap = new Map<Id, Deployment__c>([SELECT Name, Id, PT_Production_Engineer__c FROM Deployment__c WHERE Id IN :deploymentIds]);

    // get all of the user ids
    List<User> users = [SELECT Name, Username, Id FROM User WHERE Username IN :userNames];
    // create a map<username, id>
    Map<String, String> userMap = new Map<String, String>();
    for (User u : users)
      userMap.put(u.Username, u.Id);

    // get all of the record type ids
    List<RecordType> recordTypes = [SELECT Name, Id FROM RecordType WHERE Name IN :recordNames];
    // create a map<RecordTypeName, Id>
    Map<String, String> recordTypeMap = new Map<String, String>();
    for (RecordType rt : recordTypes)
      recordTypeMap.put(rt.Name, rt.Id);

    // create a map of <RecordTypeId, UserId>
    Map<String, String> recordUserMap = new Map<String, String>();
    for (Member_Support_Assignment__c assignment : assignments.values()) {
      Id uId = userMap.get(assignment.Username__c);
      Id rtId = recordTypeMap.get(assignment.Record_Type_Name__c);
      recordUserMap.put(rtId, uId);
    }

    // go through each record and determine the appropriate user
    for (Site_Issue__c newIssue : triggerNew) {
      // get the old record
      Site_Issue__c oldIssue;
      if (oldMap != null)
        oldIssue = oldMap.get(newIssue.Id);

      Id newOwnerId;
      // check to see if the record type id has changed
      if (oldIssue == null) { // if it is an insert, it definitely needs updated
        newOwnerId = recordUserMap.get(newIssue.RecordTypeId);
      }
      else { // otherwise only update if the recordtype changed
        if (oldIssue.RecordTypeId != newIssue.RecordTypeId) {
          newOwnerId = recordUserMap.get(newIssue.RecordTypeId);
        }
      }

      // get the deployment record
      Deployment__c deployment = deploymentMap.get(newIssue.Deployment__c);
      if (newIssue.Engineer__c == null && deployment != null) { // set the engineer field
        if (deployment.PT_Production_Engineer__c != null)
          newIssue.Engineer__c = deployment.PT_Production_Engineer__c;
      }


      // if we found that a new owner should be applied to this record, set it
      if (newOwnerId != null)
        newIssue.OwnerId = newOwnerId;
    }
  }
    
    /**
     *  @description    :   Method to check if a Member Support record's status is '10 - Closed, Member Notified'and if the record meets the 
                            criteria for the automated email and any of the related Project Roles are related to Contacts where EmailBouncedReason 
                            or EmailBouncedDate are not null, we should display a user-friendly error message that says which
                            Project Role's Contacts are affected and tells the user how to resolve.  
                            
     *  @args           :   List of new site issues, map of old site issues records
     *
     *  @return         :   void
     *
    **/
    //Added By - Ajit Surana - 02/27/2015 - CR-20150106-8468
    public static void validateContactFlagValues(List<Site_Issue__c> newListSiteIssues, map<Id, Site_Issue__c> oldMapSiteIssues) {
        
        //Set to hold the project Ids
        Set<Id> projectIds = new Set<Id>();

        //Query out to get the record type name
        List<RecordType> recordTypes = [SELECT Id, DeveloperName FROM RecordType 
                                            WHERE DeveloperName =: Constants.RECORD_TYPE_SITE_ISSUE_DEVELOPER_NAME_CCA_DATA_LOAD 
                                            AND IsActive = true 
                                            AND sObjectType = 'Site_Issue__c' ORDER BY DeveloperName Limit 1];

        //Loop through new MS records
        for(Site_Issue__c sIssue : newListSiteIssues) {

            //Check for status field value '22- Sent Email Update' and Project__c field not null
            if(sIssue.Project__c != null
                &&((sIssue.Status__c == Constants.STATUS_SITE_ISSUE_22_SENT_EMAIL_UPDATE 
                && (oldMapSiteIssues == null || oldMapSiteIssues.get(sIssue.Id).Status__c != sIssue.Status__c))
                    ||(sIssue.RecordTypeId == recordTypes[0].Id
                            && (sIssue.Data_Load_Type__c == Constants.CURRENT || sIssue.Data_Load_Type__c == Constants.HISTORICAL_RELOAD)
                            && sIssue.Status__c == Constants.STATUS_SITE_ISSUE_10_CLOSED_MEMBER_NOTIFIED
                            && (oldMapSiteIssues == null || oldMapSiteIssues.get(sIssue.Id).Status__c != sIssue.Status__c
                                    || oldMapSiteIssues.get(sIssue.Id).Data_Load_Type__c != sIssue.Data_Load_Type__c)))){

                //Add projectIds in set
                projectIds.add(sIssue.Project__c);
            }
        }

        //Check if there are records to process
        if(projectIds.size() > 0 ) {
            
            //Map to hold project ID as key and List of project roles as value
            Map<Id, List<Project_Role__c>> mapProjectIdWithProjectRoles = new Map<Id, List<Project_Role__c>>();
            
            //Set to hold the contact IDS
            Set<Id> setContactIds = new Set<Id>();
            
            //Map to hold the contact Id as value and having true as value if having bounce email otherwise false
            Map<Id, Boolean> mapContactWithBounceEmailFlag = new Map<Id, Boolean>();
            
            //Loop through project role records
            for(Project_Role__c pR : [SELECT Project__c, Contact__c, Name, Project_Role_Contact_EMail__c From Project_Role__c 
                                                WHERE Project__c != null AND Project__c IN: projectIds 
                                                AND Contact__c != null
                                                AND Project__r.Program_Acronym__c =: Label.MEMBER_SUPPORT_AUTO_EMAIL_ACRONYM
                                                AND CCC_Include_in_Data_Load_Automated_Email__c = true 
                                                AND Project_Role_Contact_Email__c != null]) {
      
                //Populating map with approriate combination of records
                if(mapProjectIdWithProjectRoles.containsKey(pR.Project__c))
                    mapProjectIdWithProjectRoles.get(pR.Project__c).add(pR);
                else
                    mapProjectIdWithProjectRoles.put(pR.Project__c, new List<Project_Role__c>{pR});  
                    
                //Populating set with contact Ids               
                setContactIds.add(pR.Contact__c);
            }
        
            //Checking if record is there to proceed
            if(setContactIds.size() > 0) {
                
                //Loop through contact records
                for(Contact con : [Select ID, EmailBouncedDate, EmailBouncedReason FROM Contact WHERE ID IN : setContactIds]) {
                    
                    //Modified By - Mahendra Swarnkar - 06/11/2015 - CR-20150529-8971 - Erroneous email bounce messages
                    if(String.isNotBlank(con.EmailBouncedReason))
                        mapContactWithBounceEmailFlag.put(con.Id, true);
                    else
                        mapContactWithBounceEmailFlag.put(con.Id, false);
                }
            }
            
            //Map to hold project role record Id as key and relate contact boolean bounce email flag as value
            Map<Id, Boolean> mapProjectRoleWithBounceEmailFlag = new Map<Id, Boolean>();
            
            //Loop through map keyset
            for(Id key : mapProjectIdWithProjectRoles.keySet()) {
                for(Project_Role__c pRole : mapProjectIdWithProjectRoles.get(key)) {
                    if(pRole.Contact__c != null) {
                        if(mapContactWithBounceEmailFlag.containsKey(pRole.Contact__c) && mapContactWithBounceEmailFlag.containsKey(pRole.Contact__c) != null)
                            mapProjectRoleWithBounceEmailFlag.put(pRole.Id, mapContactWithBounceEmailFlag.get(pRole.Contact__c));       
                    }   
                }
            }
            
            //Loop through MS records as adding error message if any contact associated to PR is having bounce email with it
            //Loop through trigger.new
            for(Site_Issue__c sI : newListSiteIssues) {

                //Check for status field value '22- Sent Email Update' and Project__c field not null
                if(sI.Project__c != null
                    &&((sI.Status__c == Constants.STATUS_SITE_ISSUE_22_SENT_EMAIL_UPDATE 
                    && (oldMapSiteIssues == null || oldMapSiteIssues.get(sI.Id).Status__c != sI.Status__c))
                        ||(sI.RecordTypeId == recordTypes[0].Id
                                && (sI.Data_Load_Type__c == Constants.CURRENT || sI.Data_Load_Type__c == Constants.HISTORICAL_RELOAD)
                                && sI.Status__c == Constants.STATUS_SITE_ISSUE_10_CLOSED_MEMBER_NOTIFIED
                                    && (oldMapSiteIssues == null || oldMapSiteIssues.get(sI.Id).Status__c != sI.Status__c
                                        || oldMapSiteIssues.get(sI.Id).Data_Load_Type__c != sI.Data_Load_Type__c)))) {
                                        
                    //String to hold the Project Role Names value
                    String pRoleNames = '';
                    
                    //Checking for value in the map
                    if(mapProjectIdWithProjectRoles.get(sI.Project__c) != null) {
                        for(Project_Role__c pRol : mapProjectIdWithProjectRoles.get(sI.Project__c)) {
                            if(mapProjectRoleWithBounceEmailFlag.containsKey(pRol.Id) && mapProjectRoleWithBounceEmailFlag.get(pRol.Id) == true) {
                                pRoleNames += pRol.Name + ',';
                            }
                        }
                        
                        //Checking string for blank value
                        if(pRoleNames != '') {
                            pRoleNames = pRoleNames.removeEnd(',');
                            sI.addError(pRoleNames + System.Label.Error_Message_Bounce_Email);
                        }
                    }                               
                }
            }
        }
    }
    
    //Code added by Bhavi Sharma - 06/12/2013 - CR-20120716-1142
    //New method added for send outbound email to Project role's contact email address
    //with CC to Project: Business Analyst and Project: Dedicated Advisor user's email address
    //Update - (SUNJ 12/19/13) - CR-20130815-3433
  /**
  *
  *  Description: convert site issues to JSON and send to future method CR-5343
  *
  **/
  public static void SendDataLoadAutoEmail(list<Site_Issue__c> newListSiteIssues, map<Id, Site_Issue__c> oldMapSiteIssues) {
    
    string oldSiteIssueString;
        
    //convert or sObjects to JSON strings
    string newSiteIssueString = System.JSON.serialize(newListSiteIssues);
    if (oldMapSiteIssues != null)
      oldSiteIssueString = System.JSON.serialize(oldMapSiteIssues.values());
    
    //only continue processing if this is not being called from a future method or batch job.
    if (!system.isFuture() && !system.isBatch()) {
        //call our future method which will convert the strings back to sObjects and email the member if applicable
        SendDataLoadAutoEmail(newSiteIssueString, oldSiteIssueString);
    }
  }
    //Code modified by - Ajit Surana - 10/20/2014 - CR-20140915-7353 
    //Code added by Bhavi Sharma - 06/12/2013 - CR-20120716-1142
    //New method added for send outbound email to Project role's contact email address
    //with CC to Project: Business Analyst and Project: Dedicated Advisor user's email address
    //Update - (SUNJ 12/19/13) - CR-20130815-3433
    //Update - (VH 05/09/14) - CR-20140505-5343
    @future
    public static void SendDataLoadAutoEmail(string newSiteIssuesString, string oldSiteIssuesString){
    
    //Added By - Ajit Surana - 10/20/2014 - CR-20140915-7353 
    //Bypass dupeblocker
    CRMfusionDBR101.DB_Globals.triggersDisabled = true;
    
    //convert our JSON string to a list of the new sobjects
    list<Site_Issue__c> newListSiteIssues = (list<Site_Issue__c>) System.JSON.deserializeStrict(newSiteIssuesString, list<Site_Issue__c>.class);
    //convert our JSON string to a map of the old sObjects
    map<Id, Site_Issue__c> oldMapSiteIssues;
        if (oldSiteIssuesString != null) {
            list<Site_Issue__c> oldListSiteIssues = (list<Site_Issue__c>) System.JSON.deserializeStrict(oldSiteIssuesString, list<Site_Issue__c>.class);
            oldMapSiteIssues = new map<Id, Site_Issue__c>(oldListSiteIssues);
        }

        //Set for hold Project's Ids
        Set<Id> projectIds = new Set<Id>();

        //This map is to hold the first target object id for Project
        Map<Id, Id> mapContactsWithProjects = new Map<Id, Id>();

        //This map is to hold all the remaining contacts email toAddresses for Project
        Map<Id, List<String>> mapToAddresses = new Map<id, List<String>>();

        System.debug('####Data' + newListSiteIssues);

        // get one record type name
        List<RecordType> recordTypes = [SELECT Id, DeveloperName FROM RecordType WHERE DeveloperName =: Constants.RECORD_TYPE_SITE_ISSUE_DEVELOPER_NAME_CCA_DATA_LOAD AND IsActive = true AND sObjectType = 'Site_Issue__c' ORDER BY DeveloperName Limit 1];

        //Loop through trigger.new
        for(Site_Issue__c sIssue : newListSiteIssues) {

            //Check for status field value '22- Sent Email Update' and Project__c field not null
            if(sIssue.Project__c != null
                &&((sIssue.Status__c == Constants.STATUS_SITE_ISSUE_22_SENT_EMAIL_UPDATE && (oldMapSiteIssues == null || oldMapSiteIssues.get(sIssue.Id).Status__c != sIssue.Status__c))
                    ||(sIssue.RecordTypeId == recordTypes[0].Id
                            && (sIssue.Data_Load_Type__c == Constants.CURRENT || sIssue.Data_Load_Type__c == Constants.HISTORICAL_RELOAD)
                            && sIssue.Status__c == Constants.STATUS_SITE_ISSUE_10_CLOSED_MEMBER_NOTIFIED
                            && (oldMapSiteIssues == null || oldMapSiteIssues.get(sIssue.Id).Status__c != sIssue.Status__c
                                    || oldMapSiteIssues.get(sIssue.Id).Data_Load_Type__c != sIssue.Data_Load_Type__c)))){

                //Add projectIds in set
                projectIds.add(sIssue.Project__c);
            }
        }


        //Check if there are records to process
        if(projectIds.size() > 0 ){
            
            //Modified by - Ajit Surana - 02/16/2014 - CR-20150106-8468 - Updated SOQL query that use "ProjectName LIKE %CCC%" with 
            //a where clause that checks to see if the Project's Program_Acronym__c field = CustomLabel.DATA_LOAD_AUTO_EMAIL_ACRONYM
            //Modified by - Ajit Surana - 10/20/2014 - CR-20140915-7353 - Query modified to retreive Institution__c field
            //Get list of Project fields
            Map<Id, Project__c> projects = new Map<Id, Project__c>([SELECT Institution__c, Dedicated_Advisor__r.Email, Recurring_Business_Analyst__r.Email, Project_Manager__r.Email FROM Project__c
                                                                        WHERE Id IN: projectIds AND Program_Acronym__c =: Label.MEMBER_SUPPORT_AUTO_EMAIL_ACRONYM]);
                                                                        
            //Map of CC addresses to hold the CCAddresses for each project
            Map<Id, List<String>> mapCCAddresses = new Map<Id, List<String>>();

            //Loop through the projects and
            for(Project__c project : projects.values()){

                //Add a new record in Map
                mapCCAddresses.put(project.Id, new List<String>());

                //Check for the values and add in map
                if(project.Dedicated_Advisor__c != null)
                    mapCCAddresses.get(project.Id).add(project.Dedicated_Advisor__r.Email);
                if(project.Recurring_Business_Analyst__c != null)
                    mapCCAddresses.get(project.Id).add(project.Recurring_Business_Analyst__r.Email);
                if(project.Project_Manager__c != null)
                    mapCCAddresses.get(project.Id).add(project.Project_Manager__r.Email);
            }
            
            //Modified by - Ajit Surana - 02/16/2014 - CR-20150106-8468 - Updated SOQL query that use "ProjectName LIKE %CCC%" with 
            //a where clause that checks to see if the Project's Program_Acronym__c field = CustomLabel.DATA_LOAD_AUTO_EMAIL_ACRONYM
            //Loop through list of Project Role records associated within projectIds set
            for(Project_Role__c projectRole : [SELECT Project__c, Contact__c, Project_Role_Contact_EMail__c From Project_Role__c WHERE Project__c IN: projects.keySet() AND Project__c != null AND Project__r.Program_Acronym__c =: Label.MEMBER_SUPPORT_AUTO_EMAIL_ACRONYM
                                                    AND CCC_Include_in_Data_Load_Automated_Email__c = true AND Project_Role_Contact_EMail__c != null]) {

                //Check Contact__c is not null
                if(projectRole.Contact__c != null) {

                    //Check if project is already in map, then add contact directly in set
                    if(mapContactsWithProjects.containsKey(projectRole.Project__c) ) {

                        //As first Target Object Id have been added, Add remaining ones in to address
                        if(mapToAddresses.containsKey(projectRole.Project__c)) {

                            //Add in existing list
                            mapToAddresses.get(projectRole.Project__c).add(projectRole.Project_Role_Contact_EMail__c);
                        } else {

                            //Add new in Map
                            mapToAddresses.put(projectRole.Project__c, new List<String>{projectRole.Project_Role_Contact_EMail__c});
                        }
                    } else {

                        //Add a fresh record in map
                        mapContactsWithProjects.put(projectRole.Project__c, projectRole.Contact__c);
                    }
                }
            }

            //Check if there are records to send email
            if(projects.size() > 0) {

                //Map Email with Contact Id
                Map<String, Id> mapEmailWithContact = new Map<String, Id>();

                //Create a list of emails to be hold
                List<String> emails = new List<String>();
                for(List<String> emailList : mapCCAddresses.values())
                    emails.addAll(emailList);

                //Create a Map of Contact records with email addresses
                for(Contact cont : [Select Id, Email from Contact where Email IN: emails])
                    mapEmailWithContact.put(cont.Email, cont.Id);

                //get Email Template of DATA LOAD EMAIL TEMPLATE
                List<EmailTemplate> emailTemplates = [SELECT Id FROM EmailTemplate WHERE Name =: Constants.EMAIL_TEMPLATE_DATA_LOAD AND IsActive = true];

                if(emailTemplates.size() == 0)
                    throw new CustomException('Eamil tempalte ' + Constants.EMAIL_TEMPLATE_DATA_LOAD + ' not found.');

                //Initialize list of SingleEmailMessage
                List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();

                //List ot hold the temporary contacts
                List<Contact> cnts = new List<Contact>();

                //Loop through the projects and send email
                for(Project__c project : projects.values()) {

                    //Temporary Contact, thi swill be deleted after sending the email
                    Contact temporaryContact;

                    //Instantiates SingleEmailMessage
                    Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();

                    //Target object Id
                    Id targetObjectId;
                    if(mapContactsWithProjects.containsKey(project.Id)) {
                        targetObjectId = mapContactsWithProjects.get(project.Id);

                        //Set CC address
                        mail.setCcAddresses(mapCCAddresses.get(project.Id));
                    } else if(project.Dedicated_Advisor__r.Email != null) {
                        
                        //Modified By - Ajit Surana - CR-20140915-7353 - 10/20/2014
                        if(mapEmailWithContact.containsKey(project.Dedicated_Advisor__r.Email))
                            temporaryContact = new Contact(LastName = 'TBD_TemporaryContact', Email = project.Dedicated_Advisor__r.Email,
                                                            AccountId = project.Institution__c);
                            insert temporaryContact;
                            targetObjectId = temporaryContact.Id;
                            
                        //List to hold the CC addresses
                        List<String> ccEmailAddresses = new List<String>();
                        
                        if(project.Recurring_Business_Analyst__r.Email != null)
                            ccEmailAddresses.add(project.Recurring_Business_Analyst__r.Email);
                        
                        //Added By : Bhavi  - 12/28/2013 - CR-20130815-3433
                        if(project.Project_Manager__r.Email != null)
                            ccEmailAddresses.add(project.Project_Manager__r.Email);
                            
                        //If ccEmailAddresses's size is greater than 0
                        if(ccEmailAddresses.size() > 0)
                            mail.setCcAddresses(ccEmailAddresses);
                        
                    } else if(project.Recurring_Business_Analyst__r.Email != null) {
                        
                        //Modified By - Ajit Surana - CR-20140915-7353 - 10/20/2014
                        if(mapEmailWithContact.containsKey(project.Recurring_Business_Analyst__r.Email))
                            temporaryContact = new Contact(LastName = 'TBD_TemporaryContact', Email = project.Recurring_Business_Analyst__r.Email,
                                                            AccountId = project.Institution__c);
                            insert temporaryContact;
                            targetObjectId = temporaryContact.Id;
                            
                        //Added By : Bhavi  - 12/28/2013 - CR-20130815-3433
                        //List to hold the CC addresses
                        List<String> ccEmailAddresses = new List<String>();
                        
                        if(project.Project_Manager__r.Email != null)
                            ccEmailAddresses.add(project.Project_Manager__r.Email);
                            
                        //If ccEmailAddresses's size is greater than 0
                        if(ccEmailAddresses.size() > 0)
                            mail.setCcAddresses(ccEmailAddresses);
                    }  else if(project.Project_Manager__r.Email != null) {
                        
                        //Modified By - Ajit Surana - CR-20140915-7353 - 10/20/2014
                        //Added By : Bhavi  - 12/28/2013 - CR-20130815-3433
                        if(mapEmailWithContact.containsKey(project.Project_Manager__r.Email))
                            temporaryContact = new Contact(LastName = 'TBD_TemporaryContact', Email = project.Project_Manager__r.Email,
                                                            AccountId = project.Institution__c);
                            insert temporaryContact;
                            targetObjectId = temporaryContact.Id;
                    }

                    //Check if target object Id is not null
                    if(targetObjectId != null) {

                        //set Target Object Ids
                        mail.setTargetObjectId(targetObjectId);

                        //set Target Object Ids
                        if(mapToAddresses.containsKey(project.Id)) {

                            mail.setToAddresses(mapToAddresses.get(project.Id));
                        }

                        //Set EmailTemplate
                        mail.setTemplateId(emailTemplates[0].Id);

                        //Set whatIds as projectIds
                        mail.setWhatId(project.Id);

                        //Add mail in list
                        mails.add(mail);

                        //Add contact in To be deleted list
                        if(temporaryContact != null)
                            cnts.add(temporaryContact);
                    }
                }

                //Check for the size
                if(mails.size() > 0) {
                    Messaging.sendEmail(mails);

                    //Delete temporary contact
                    if(cnts != null)
                        delete cnts;
                }
            }
        }
    }

    //Code modified By - Ajit Surana - 01/21/2015 - CR-20150102-8430
    //This method is to update Delayed Load field on Project__c object - CR-20121219-1968
    //Code added - Bhavi Sharma - 06/04/2013 - CR-20130328-2773
    public static void UpdateProjectBySiteIssue(List<Site_Issue__c> listNewSiteIssues, Map<Id, Site_Issue__c> mapOldSiteIssues) {

        //Map of Project__c Key= ProjectId & Value= Site_Issue_Close_Date
        Map<Id,Datetime> mapProjectWithCloseDateForOneDelayed = new Map<Id,Datetime>();
        Map<Id,Datetime> mapProjectWithCloseDateForZeroDelayed = new Map<Id,Datetime>();
        
        //Map to hold Site Issue corresponding to ProjectId as key
        Map<Id,Site_Issue__c> mapProjectWithSiteIssue = new Map<Id,Site_Issue__c>();

        //List of projects to be updated
        Map<Id, Project__c> mapProjects = new Map<Id, Project__c>();

        //set of Project's Ids
        Set<Id> projectIds = new Set<Id>();

        //Set of Developer Name for Site Issue's RecordType
        Set<String> setRecordTypeNames = new Set<String>();
        setRecordTypeNames.add(Constants.RECORD_TYPE_SITE_ISSUE_DEVELOPER_NAME_CCA_DATA_LOAD);
        setRecordTypeNames.add(Constants.RECORD_TYPE_SITE_ISSUE_DEVELOPER_NAME_CCI_DATA_LOAD);
        setRecordTypeNames.add(Constants.RECORD_TYPE_SITE_ISSUE_DEVELOPER_NAME_CMA_DATA_LOAD_MIGRATION);
        setRecordTypeNames.add(Constants.RECORD_TYPE_SITE_ISSUE_DEVELOPER_NAME_CPM_DATA_LOAD);
        setRecordTypeNames.add(Constants.RECORD_TYPE_SITE_ISSUE_DEVELOPER_NAME_EHBI_DATA_LOAD);

        //Map of record type
        Map<Id,RecordType> mapCMAInitialRecordType = new Map<Id,RecordType>([SELECT Id, DeveloperName FROM RecordType
                                                                                WHERE DeveloperName =: Constants.RECORD_TYPE_SITE_ISSUE_DEVELOPER_NAME_CMA_INITIAL_DEPLOYMENT_SUPPORT
                                                                                        AND IsActive = true AND sObjectType = 'Site_Issue__c' limit 1]);

        //Loop through the trigger.new
        for(Site_Issue__c siteIssue : listNewSiteIssues){

            //Check Site is data and execute the code only if require
            if(siteIssue.Project__c != null) {

                //Add Project Ids in set
                projectIds.add(siteIssue.Project__c);

                //Check if Site issue close date is null
                if(siteIssue.Site_Issue_Close_Date__c != null) {

                    //Check for the site issue
                    if(siteIssue.Data_Load_Type__c == Constants.CURRENT || siteIssue.Data_Load_Type__c == Constants.HISTORICAL_RELOAD) {

                        //Code added - Bhavi Sharma - 06/04/2013 - CR-20130328-2773
                        if(mapCMAInitialRecordType.containsKey(siteIssue.RecordTypeId)){

                            //put map's key=Project Id and value = Site Issue Record
                            mapProjectWithSiteIssue.put(siteIssue.Project__c, siteIssue);
                        }

                        //Check if total delay is greater than 0
                        if(siteIssue.Total_Delay__c > 0 ) {

                            //Check if map already contains the key of new Project Reference
                            if(mapProjectWithCloseDateForOneDelayed.containsKey(siteIssue.Project__c)) {

                                //check the Site_Issue_Close_Date__C is greater then existing close date
                                if(siteIssue.Site_Issue_Close_Date__c > mapProjectWithCloseDateForOneDelayed.get(siteIssue.Project__c)) {

                                    //put site issue's close date in map
                                    mapProjectWithCloseDateForOneDelayed.put(siteIssue.Project__c, siteIssue.Site_Issue_Close_Date__c);
                                }
                            } else {

                                //put site issue's close date in map
                                mapProjectWithCloseDateForOneDelayed.put(siteIssue.Project__c, siteIssue.Site_Issue_Close_Date__c);
                            }
                        } else {

                            //Check if map already contains the key of new Project Reference
                            if(mapProjectWithCloseDateForZeroDelayed.containsKey(siteIssue.Project__c)) {

                                //check the Site_Issue_Close_Date__C is greater then existing close date
                                if(siteIssue.Site_Issue_Close_Date__c > mapProjectWithCloseDateForZeroDelayed.get(siteIssue.Project__c)) {

                                    //put site issue's close date in map
                                    mapProjectWithCloseDateForZeroDelayed.put(siteIssue.Project__c, siteIssue.Site_Issue_Close_Date__c);
                                }
                            } else {

                                //put site issue's close date in map
                                mapProjectWithCloseDateForZeroDelayed.put(siteIssue.Project__c, siteIssue.Site_Issue_Close_Date__c);
                            }
                        }
                    } else {

                        //Check if map already contains the key of new Project Reference
                        if(mapProjectWithCloseDateForZeroDelayed.containsKey(siteIssue.Project__c)) {

                            //check the Site_Issue_Close_Date__C is greater then existing close date
                            if(siteIssue.Site_Issue_Close_Date__c > mapProjectWithCloseDateForZeroDelayed.get(siteIssue.Project__c)) {

                                //put site issue's close date in map
                                mapProjectWithCloseDateForZeroDelayed.put(siteIssue.Project__c, siteIssue.Site_Issue_Close_Date__c);
                            }
                        } else {

                            //put site issue's close date in map
                            mapProjectWithCloseDateForZeroDelayed.put(siteIssue.Project__c, siteIssue.Site_Issue_Close_Date__c);
                        }
                    }
                }
            }
        }

        //Updated By Abhinav Sharma - 03-14-2014 - CR-20131107-3938 - CMA - P/MS - Create Null PCP Field
        //Code added - Bhavi Sharma - 06/04/2013 - CR-20130328-2773
        List<Project__c> projects = [SELECT Current_Data_Period_New__c, Percent_of_PCP_Not_Captured__c FROM Project__c WHERE Id IN: projectIds];
        
        //Added By Abhinav Sharma - 03-14-2014 - CR-20131107-3938 - CMA - P/MS - Create Null PCP Field
        //Set of Developer Name for Site Issue's RecordType applicable during "Percent of PCP Not Captured" update
        Set<String> setRecordTypeNamesForPercentofPCPNotCaptured = new Set<String>();
        setRecordTypeNamesForPercentofPCPNotCaptured.add(Constants.RECORD_TYPE_SITE_ISSUE_DEVELOPER_NAME_CMA_DATA_LOAD_MIGRATION);
        setRecordTypeNamesForPercentofPCPNotCaptured.add(Constants.RECORD_TYPE_SITE_ISSUE_DEVELOPER_NAME_CMA_INITIAL_DEPLOYMENT_SUPPORT);
        
        //Added By Ajit Surana - 01-20-2015 - CR-20150102-8430
        //Set of Data Load Type field names
        Set<String> setDataLoadTypeNames = new Set<String>();
        setDataLoadTypeNames.add(Constants.CURRENT);
        setDataLoadTypeNames.add(Constants.HISTORICAL_RELOAD);
        setDataLoadTypeNames.add(Constants.SITE_BUILD);
        setDataLoadTypeNames.add(Constants.PART_OF_BUILD);
        
        //Map to hold the Project Id as key and Most Recent Date/time closed field value Member support record as value
        Map<Id, Site_Issue__c> mapProjectWithMemberSupports = new Map<Id, Site_Issue__c>();
        
        //Reteriving site issue records for whom:- 1) Record Type = “CMA Data Load Migration” or “CMA Initial Deployment” 2) Date/Time closed != null
        //3) Status = 22 - Production Migration Complete 4) Most Recent Date/Time Closed
        for(Site_Issue__c sIssue : [SELECT Project__c, Percent_of_PCP_Revenue_Not_Captured__c FROM Site_Issue__c 
                                        WHERE Project__c  != null AND Project__c IN : projectIds
                                        AND RecordType.DeveloperName IN : setRecordTypeNamesForPercentofPCPNotCaptured
                                        AND Data_Load_Type__c IN : setDataLoadTypeNames
                                        AND Site_Issue_Close_Date__c != null            
                                        AND Status__c =: Constants.STATUS_22_PRODUCTION_MIGRATION_COMPLETE 
                                        ORDER BY Site_Issue_Close_Date__c DESC]) {
            //Checking for value in the map and populating it if value does exist in prior
            if(!mapProjectWithMemberSupports.containsKey(sIssue.Project__c))
                mapProjectWithMemberSupports.put(sIssue.Project__c, sIssue);
        }
        
        //Loop through project List
        for(Project__c project : projects) {

            //Check if project exists in Map and update Current data period in Project
            if(mapProjectWithSiteIssue.containsKey(project.Id)) {

                //assign Site Issue's field value on Project's field
                project.Current_Data_Period_New__c = mapProjectWithSiteIssue.get(project.Id).Data_Load_Period_End__c;

                //Add record in Map to be updated
                mapProjects.put(project.Id, project);
            }
        
            //Added By Abhinav Sharma - 03-14-2014 - CR-20131107-3938 - CMA - P/MS - Create Null PCP Field  
            //Check if project exists in map and updated the "Percent of PCP Not Captured" field for project
            if(mapProjectWithMemberSupports.containsKey(project.Id)) {
                
                //Populate Percent of PCP Not Captured field on project with most recent date/time closed Member support record value
                //Only Process the record if difference iin value is there 
                if(project.Percent_of_PCP_Not_Captured__c != mapProjectWithMemberSupports.get(project.Id).Percent_of_PCP_Revenue_Not_Captured__c) {
                    project.Percent_of_PCP_Not_Captured__c = mapProjectWithMemberSupports.get(project.Id).Percent_of_PCP_Revenue_Not_Captured__c;
                    mapProjects.put(project.Id, project);
                }
            }
        }

        //Chekc if there is any data to process
        if(mapProjectWithCloseDateForOneDelayed.size() > 0 || mapProjectWithCloseDateForZeroDelayed.size() > 0) {

            //Create a Map to hold the Most recent Site Issue with Project Id
            Set<Id> addedProjects = new Set<Id>();
            Map<Id, Site_Issue__c> mapExistingSiteIssues = new Map<Id, Site_Issue__c>();

            //Query Site Issue records and hold the maximum one in Map
            for(Site_Issue__c sIssue : [SELECT Project__c, Site_Issue_Close_Date__c, Data_Load_Type__c, Total_Delay__c
                                            from Site_Issue__c WHERE Project__c  != null
                                                            AND (Project__c IN :mapProjectWithCloseDateForOneDelayed.keySet()
                                                                OR Project__c IN :mapProjectWithCloseDateForZeroDelayed.keySet())
                                                            AND Site_Issue_Close_Date__c != null
                                                            AND ID NOT IN: listNewSiteIssues ORDER BY Site_Issue_Close_Date__c DESC]) {
                //check if already added
                if(!mapExistingSiteIssues.containsKey(sIssue.Project__c)) {

                    //add in set to avoid the next value
                    mapExistingSiteIssues.put(sIssue.Project__c, sIssue);
                }
            }

            //Get most recent data from existing records
            AggregateResult[] aggs = [SELECT Project__c projectId, Max(Site_Issue_Close_Date__c) mostRecentDate
                                                        FROM Site_Issue__c
                                                        WHERE Project__c  != null
                                                            AND (Project__c IN :mapProjectWithCloseDateForOneDelayed.keySet()
                                                                OR Project__c IN :mapProjectWithCloseDateForZeroDelayed.keySet())
                                                            AND Site_Issue_Close_Date__c != null
                                                            AND ID NOT IN: listNewSiteIssues GROUP BY Project__c];

            //loop through the aggregate results
            for(AggregateResult aR : aggs) {

                //Get Project Id
                Id projectId = (Id)aR.get('projectId');

                DateTime maxDTM = DateTime.valueOf(aR.get('mostRecentDate'));

                //Check if map already has project Id and Close date is recent than the existing one
                if(mapProjectWithCloseDateForOneDelayed.containsKey(projectId)) {

                    //Compare dates and add record in list to be updated
                    if(maxDTM < mapProjectWithCloseDateForOneDelayed.get(projectId)) {

                        //Add record in list to be updated
                        if(mapProjects.containsKey(projectId))
                            mapProjects.get(projectId).Delayed_Load__c = 1;
                        else
                            mapProjects.put(projectId, new Project__c(Id = projectId, Delayed_Load__c = 1));
                    } else if(mapExistingSiteIssues.containsKey(projectId)){

                        //Get the site Issue record from Map and check the value to be updated
                        Site_Issue__c sIssue = mapExistingSiteIssues.get(projectId);

                        //Check for zero else one
                        if((sIssue.Data_Load_Type__c == Constants.CURRENT || sIssue.Data_Load_Type__c == Constants.HISTORICAL_RELOAD) && sIssue.Total_Delay__c > 0) {

                             //Add record in list to be updated
                            if(mapProjects.containsKey(projectId))
                                mapProjects.get(projectId).Delayed_Load__c = 1;
                            else
                                mapProjects.put(projectId, new Project__c(Id = projectId, Delayed_Load__c = 1));
                        } else {

                             //Add record in list to be updated
                            if(mapProjects.containsKey(projectId))
                                mapProjects.get(projectId).Delayed_Load__c = 0;
                            else
                                mapProjects.put(projectId, new Project__c(Id = projectId, Delayed_Load__c = 0));
                        }
                    }
                }

                //Remove this from Map
                mapProjectWithCloseDateForOneDelayed.remove(projectId);

                //Check if map already has project Id and Close date is recent than the existing one
                if(mapProjectWithCloseDateForZeroDelayed.containsKey(projectId)) {

                    //Compare dates and add record in list to be updated
                    if(maxDTM < mapProjectWithCloseDateForZeroDelayed.get(projectId)) {

                        //Add record in list to be updated
                        if(mapProjects.containsKey(projectId))
                            mapProjects.get(projectId).Delayed_Load__c = 0;
                        else
                            mapProjects.put(projectId, new Project__c(Id = projectId, Delayed_Load__c = 0));
                    } else if(mapExistingSiteIssues.containsKey(projectId)){

                        //Get the site Issue record from Map and check the value to be updated
                        Site_Issue__c sIssue = mapExistingSiteIssues.get(projectId);

                        //Check for zero else one
                        if((sIssue.Data_Load_Type__c == Constants.CURRENT || sIssue.Data_Load_Type__c == Constants.HISTORICAL_RELOAD) && sIssue.Total_Delay__c > 0) {

                             //Add record in list to be updated
                            if(mapProjects.containsKey(projectId))
                                mapProjects.get(projectId).Delayed_Load__c = 1;
                            else
                                mapProjects.put(projectId, new Project__c(Id = projectId, Delayed_Load__c = 1));
                        } else {

                             //Add record in list to be updated
                            if(mapProjects.containsKey(projectId))
                                mapProjects.get(projectId).Delayed_Load__c = 0;
                            else
                                mapProjects.put(projectId, new Project__c(Id = projectId, Delayed_Load__c = 0));
                        }
                    }
                }

                //Remove this from Map
                mapProjectWithCloseDateForZeroDelayed.remove(projectId);
            }

            //Loop through the remaining records and add in list to be updated
            for(Id projectId : mapProjectWithCloseDateForOneDelayed.keySet()) {

                //Add record in list to be updated
                if(mapProjects.containsKey(projectId))
                    mapProjects.get(projectId).Delayed_Load__c = 1;
                else
                    mapProjects.put(projectId, new Project__c(Id = projectId, Delayed_Load__c = 1));
            }

            //Loop through the remaining records and add in list to be updated
            for(Id projectId : mapProjectWithCloseDateForZeroDelayed.keySet()) {

                //Add record in list to be updated
                if(mapProjects.containsKey(projectId))
                    mapProjects.get(projectId).Delayed_Load__c = 0;
                else
                    mapProjects.put(projectId, new Project__c(Id = projectId, Delayed_Load__c = 0));
            }

            //Code added - Bhavi Sharma - 06/06/2013 - CR-20130328-2773
            //Get most recent data from existing records
            AggregateResult[] aggResults = [SELECT Project__c projectId, Max(Site_Issue_Close_Date__c) mostRecentCloseDate FROM Site_Issue__c
                                                        WHERE Project__c  != null AND Project__c IN : projectIds AND RecordType.DeveloperName IN: setRecordTypeNames
                                                        AND Site_Issue_Close_Date__c != null GROUP BY Project__c];

            //Loop through Aggregate Results
            for(AggregateResult aR : aggResults) {

                //Get project Id
                Id projectId = (Id) aR.get('projectId');

                //Add record in list to be updated
                if(mapProjects.containsKey(projectId))
                    mapProjects.get(projectId).Latest_Data_Load__c = Datetime.valueOf(aR.get('mostRecentCloseDate'));
                else
                    mapProjects.put(projectId, new Project__c(Id = projectId, Latest_Data_Load__c = Datetime.valueOf(aR.get('mostRecentCloseDate'))));
            }

            //Check if data to update
            if(mapProjects.size() > 0) {

                //ByPass ALL trigger
                Util.BypassAllTriggers = true;
                update mapProjects.values();
                Util.BypassAllTriggers = false;
            }
        }
    }
    
    //Code modified - Ajit Surana - 01/23/2015 - CR-20140716-6259
    //Code added - Bhavi Sharma - 06/04/2013 - CR-20130328-2773
    //This method to update Member Support's fields corresponding to Project's fields
    public static void UpdateSiteIssueByProject(List<Site_Issue__c> listNewSiteIssues, Boolean isUpdate) {

        //Set of ProjectId which is associated with Site Issue 
        Set<Id> projectIds = new Set<Id>();

        //Map to hold Site Issue corresponding to ProjectId as key
        Map<Id,Site_Issue__c> mapProjWithSiteIssue = new Map<Id,Site_Issue__c>();
        
        //Loop through new list
        for(Site_Issue__c sIssue : listNewSiteIssues) {

            //Check Project__c field is not null
            if(sIssue.Project__c != null ) {

                //add ProjectId in set
                projectIds.add(sIssue.Project__c);

            }
        }

        //Query fields from project
        Map<Id, Project__c> mapProjects = new Map<Id, Project__c>([SELECT Id, Recurring_Business_Analyst__c, Dedicated_Advisor__c, Data_Analyst__c, 
                                                                    Crimson_Data_Analyst_Group_Lead__c, Implementation_Pod__c, Crimson_Data_Lag__c,
                                                                    Load_Frequency__c, Application__c FROM Project__c WHERE Id IN: projectIds]);

        //Set to hold recordType names
        Set<String> recordNames = New Set<String>();
        recordNames.add('CCA Data Load');
        recordNames.add('Crimson Support Request');
        recordNames.add('CMA Initial Deployment Support');
        recordNames.add('CMA Report Request');
        recordNames.add('CMA Support Issue');
        recordNames.add('CPM Support Issue');
        
        //more values added into recordtype name list by - Bhavi Sharma - 07/30/2013
        recordNames.add('Defect / Enhancement Request');
        recordNames.add('Internal Initiative');
        recordNames.add('Product Issue');
        recordNames.add('Internal Initiative Detail');
        
        //Added by Bhavi - 02/10/2014 - CR-20131213-4161
        recordNames.add('CPM Data Load');
        
        //Added by Ajit Surana - 01/23/2015 - CR-20140716-6259
        recordNames.add('Crimson Medical Director Service Request');
        
        //Map to put Id with RecordType's Name
        Map<Id, RecordType> recordTypeMap = new Map<Id,RecordType>();
        
        //Added by Bhavi - 02/10/2014 - CR-20131213-4161
        //Get record type for CPM Data Load
        Id cPMDataLoadRecordTypeId; 
        
        //Added by Ajit Surana - 01/23/2015 - CR-20140716-6259
        //Get record type Id for Crimson Medical Director Service Request
        Id cMDServiceRequestRecordTypeId; 
        
        //Fetch record types from database and add in map
        for(RecordType rType : [SELECT  Name FROM RecordType WHERE Name IN: recordNames AND SobjectType = 'Site_Issue__c' AND IsActive = true]) {
            
            //Check if the Name and add in appropriate Map
            if(rType.Name.equalsIgnoreCase('CPM Data Load'))
                cPMDataLoadRecordTypeId = rType.Id;
            else if(rType.Name.equalsIgnoreCase('Crimson Medical Director Service Request'))
                cMDServiceRequestRecordTypeId = rType.Id;
            else    
                recordTypeMap.put(rtype.Id, rType);
        }
        
        //Loop thruggh the site issue records and update the data
        //Loop through new list
        for(Site_Issue__c siteIssue : listNewSiteIssues) {

            //Check Project__c field is not null
            if(siteIssue.Project__c != null && mapProjects.containsKey(siteIssue.Project__c)) {

                //Added by Bhavi - 02/10/2014 - CR-20131213-4161
                //Check if it's CPM Data Load, then populate Application Version from Parent project
                if(siteIssue.RecordTypeId == cPMDataLoadRecordTypeId)
                    siteIssue.Application_Version__c = mapProjects.get(siteIssue.Project__c).Application__c;
                
                //Added by Ajit Surana - 01/23/2015 - CR-20140716-6259
                //Check if it's Crimson Medical Director Service Request, then populate "Assigned To contact" field with to the contact record created
                if(siteIssue.RecordTypeId == cMDServiceRequestRecordTypeId)
                    siteIssue.Assigned_To_Contact__c = Label.Crimson_Medical_Director_Service_Request_User;
                
                //Do not execute the below code if trigger is running for update
                //As this method was initially running on insert only, so checking if trigger is running for update, only populate the Application vesrsion
                if(isUpdate)
                    continue;
                
                //CR-4283
                //CR-4283
                if (siteIssue.RecordTypeId == Constants.RECORD_TYPE_ID_SITE_ISSUE_CCA_DATA_LOAD
                ||  siteIssue.RecordTypeId == Constants.RECORD_TYPE_ID_SITE_ISSUE_CCA_SUPPORT_REQUEST) {
                    
                    siteIssue.Data_Analyst_Group_Lead__c = mapProjects.get(siteIssue.Project__c).Crimson_Data_Analyst_Group_Lead__c;
                    siteIssue.Crimson_Data_Analyst__c = mapProjects.get(siteIssue.Project__c).Data_Analyst__c;
                }
                
                //assignment field values corresponding Project to Site Issue
                siteIssue.Production_Business_Analyst__c = mapProjects.get(siteIssue.Project__c).Recurring_Business_Analyst__c;
                siteIssue.Dedicated_Advisor__c = mapProjects.get(siteIssue.Project__c).Dedicated_Advisor__c;
                
                //Addedd by - Bhavi Sharma - 12/23/2013 - CR-20130813-3414
                siteIssue.Project_Implementation_Pod_1__c = mapProjects.get(siteIssue.Project__c).Implementation_Pod__c;
                siteIssue.Crimson_Data_Lag_1__c = mapProjects.get(siteIssue.Project__c).Crimson_Data_Lag__c;
                siteIssue.Load_Frequency__c = mapProjects.get(siteIssue.Project__c).Load_Frequency__c;
            }
        }
    }
    
    /**
     *  @description    :   Method to update "Assigned To Contact" field on Member support records on the basis of 
     *                        "Crimson_Data_Analyst_Group_Lead__c" field value on parent project record.
     *                        Only applicable to specific record types.
     *
     *  @args           :   List of new site issues
     *
     *  @return         :   void
     *
     **/
    //Added By - Abhinav Sharma - 07/12/2014 - CR-20140422-5173
    //updated by - Victor Hanson - 03/23/2016 - CR-1223 - added PIC record types to set of recordTypeNames to bypass
    public static void UpdateAssigndToContactOnSiteIssueByProject(List<Site_Issue__c> listNewSiteIssues) {
    
        //Set to hold recordType names
        Set<String> setRecordTypeNames = New Set<String>();
        setRecordTypeNames.add('CCA_Data_Load');
        setRecordTypeNames.add('CCA_Support_Request');
        setRecordTypeNames.add('CMA_Data_Load');
        setRecordTypeNames.add('CMA_Report_Request');
        setRecordTypeNames.add('CPM_Support_Issue');
        setRecordTypeNames.add('Defect_Enhancement_Request');
        setRecordTypeNames.add('Internal_Initiative');
        setRecordTypeNames.add('Product_Issue');
        setRecordTypeNames.add('Internal_Initiative_Detail');
        setRecordTypeNames.add('CPM_Data_Load');
        setRecordTypeNames.add('Compass_Connect_Ticket');
        setRecordTypeNames.add('Compass_Data_Analytics_Ticket');
        setRecordTypeNames.add('Compass_Implementation');
        setRecordTypeNames.add('Compass_Support_Issue');
        setRecordTypeNames.add('CPRM_Data_Load');
        setRecordTypeNames.add('PIC_Contract_Maintenance');
        setRecordTypeNames.add('PIC_Customer_Service_Request');
        setRecordTypeNames.add('PIC_Defect');
        setRecordTypeNames.add('PIC_Enhancement');
        setRecordTypeNames.add('PIC_Implementation_Task');
        setRecordTypeNames.add('PIC_Operations_Issue');
        setRecordTypeNames.add('PIC_Query_Component');
        setRecordTypeNames.add('PIC_Rate_Schedule');
        setRecordTypeNames.add('PIC_Support_Issue');
    
        //Map to put Id with RecordType's Name
        Map<Id, RecordType> recordTypeMap = new Map<Id,RecordType>([SELECT ID, DeveloperName FROM RecordType 
                                                                    WHERE DeveloperName IN : setRecordTypeNames 
                                                                    AND SobjectType = 'Site_Issue__c' AND IsActive = true]);
                                                                    
        //Proceed with below logic only and only if "Record Type(s)" exist on "Member Support" object with sepcified developer names
        if(recordTypeMap.values().size() > 0) {
    
            //Set of ProjectId which is associated with Site Issue 
            Set<Id> setProjectIds = new Set<Id>();
            
            //List to hold the site issue records to be update
            List<Site_Issue__c> listSiteIssues = [SELECT ID, RecordTypeId, Project__c, Assigned_To_Contact__c FROM Site_Issue__c WHERE ID IN : listNewSiteIssues];
    
            //Loop through new "Member Support" records and populating set with parent project records Id values
            for(Site_Issue__c sIssue : listSiteIssues) {
                if(sIssue.Project__c != null)
                    setProjectIds.add(sIssue.Project__c);
            }
            
            //Fetching details of the project records through Id values
            Map<Id, Project__c> mapProjects = new Map<Id, Project__c>([SELECT Id, Crimson_Data_Analyst_Group_Lead__c 
                                                                            FROM Project__c WHERE ID != null AND Id IN: setProjectIds]);
                
            //Map to hold the "Member Support" record Id as key and corresponding "Data Analyst Group Lead" as value
            Map<Id, Id> mapSiteIssueWithDataAnalystGroupLead = new Map<Id, Id>();
                    
            //Set to hold the "Data Analyst Group Lead" field value for the "Member Support" records
            Set<Id> setDataAnalystGroupLeads = new Set<Id>();
                    
            //Loop thruggh the "Member Support" records
            for(Site_Issue__c siteIssue : listSiteIssues) {

                //Check Project__c field is not null
                if(siteIssue.Project__c != null && mapProjects != null && mapProjects.containsKey(siteIssue.Project__c)) {

                    //Populating collections with appropriate field values after applying proper validations over them
                    if(mapProjects.get(siteIssue.Project__c) != null 
                        && mapProjects.get(siteIssue.Project__c).Crimson_Data_Analyst_Group_Lead__c != null) {
                        mapSiteIssueWithDataAnalystGroupLead.put(siteIssue.Id, mapProjects.get(siteIssue.Project__c).Crimson_Data_Analyst_Group_Lead__c);
                        setDataAnalystGroupLeads.add(mapProjects.get(siteIssue.Project__c).Crimson_Data_Analyst_Group_Lead__c);
                    }
                }
            }
                    
            //Map to hold the Contact "Employee_User_Record__c" field as key and contact record as value
            Map<Id, Contact> mapEmployeeUserRecordWithContact = new Map<Id, Contact>();
            
            //Retrieving contacts records with matching "Employee User Record" field values
            for(Contact con : [SELECT Id, Employee_User_Record__c FROM Contact 
                                WHERE Employee_User_Record__c != null 
                                    AND Employee_User_Record__c IN : setDataAnalystGroupLeads]) {
                //Populating map with the validated and appropriate combination of values
                mapEmployeeUserRecordWithContact.put(con.Employee_User_Record__c, con);
            }

            //Loop through site issue records
            for(Site_Issue__c stIssue : listSiteIssues) {
            
                //Filter out record types, so then below written logic will not be exected for them
                if(!(recordTypeMap.containsKey(stIssue.RecordTypeId))) {
                
                    //Checking and retrieving out field values from map if exists
                    if(stIssue.Project__c != null && mapSiteIssueWithDataAnalystGroupLead.get(stIssue.Id) != null
                        && mapEmployeeUserRecordWithContact.containsKey(mapSiteIssueWithDataAnalystGroupLead.get(stIssue.Id))) {
                    
                            //Popualte "Assigned to Contact" field on member support record type with associated project "Crimson Data Analyst Group Lead" field value
                            stIssue.Assigned_To_Contact__c = mapEmployeeUserRecordWithContact.get(mapSiteIssueWithDataAnalystGroupLead.get(stIssue.Id)).Id;
                    
                    } else {
                    
                        //Popualte "Assigned to Contact" field with null value
                        stIssue.Assigned_To_Contact__c = null;
                    }
                }
            }
            
            //Checking list for size value
            if(listSiteIssues.size() > 0) {
                Util.byPassAlltriggers = true;
                update listSiteIssues;
                Util.byPassAlltriggers = false;
            }
        }
    }
    
    //Code added By - Bhavi Sharma - 08/13/2013 - CR-20121219-1968
    //Method is used for populate Consecutively Delayed Load when there are two delayed records regularly
    public static void populateConsecutivelyDelyedOnSiteIssue(List<Site_Issue__c> newListSiteIssues) {

        //Set to hold projectIds
        Set<Id> projectIds = new Set<Id>();

        //Map of record type
        List<RecordType> recordTypes = new List<RecordType>([SELECT Id, DeveloperName FROM RecordType
                                                                WHERE DeveloperName =: Constants.RECORD_TYPE_SITE_ISSUE_DEVELOPER_NAME_CCA_DATA_LOAD
                                                                AND IsActive = true AND sObjectType = 'Site_Issue__c' limit 1]);

        //Loop through Trigger.new
        for(Site_Issue__c sIssue : newListSiteIssues) {

            //Set default
            sIssue.Consecutively_Delayed_Load__c = false;

            //Check for Project is not null and Total Delay is greater than Zero
            if(sIssue.Project__c != null && sIssue.Total_Delay__c > 0 && sIssue.RecordTypeId == recordTypes[0].Id) {

                //add Project Ids into set
                projectIds.add(sIssue.Project__c);
            }
        }

        if(projectIds.size() > 0) {

            //Map to hold Key = Project Id & Value = Member Support record
            Map<Id, Site_Issue__c> mapExistingSiteIssues = new Map<Id, Site_Issue__c>();

            //Loop thorugh aggregate query result
            for(Site_Issue__c sIssue : [SELECT Project__c, Site_Issue_Close_Date__c, Data_Load_Type__c, Total_Delay__c
                                            from Site_Issue__c WHERE Project__c  != null
                                                            AND Project__c IN :projectIds
                                                            AND Site_Issue_Close_Date__c != null
                                                            AND ID NOT IN: newListSiteIssues
                                                            AND RecordTypeId =: recordTypes[0].Id ORDER BY Site_Issue_Close_Date__c DESC]) {

                //check if already added
                if(!mapExistingSiteIssues.containsKey(sIssue.Project__c)) {

                    //add in set to avoid the next value
                    mapExistingSiteIssues.put(sIssue.Project__c, sIssue);
                }
            }


            //Check for size of mapExistingSiteIssues
            if(mapExistingSiteIssues.size() > 0) {

                //Loop thorugh the Trigger.New
                for(Site_Issue__c siteIssue : newListSiteIssues) {

                    if(siteIssue.Project__c != null && siteIssue.Total_Delay__c > 0) {

                        //Get Most record record from Map
                        Site_Issue__c maxSiteIssue = mapExistingSiteIssues.get(siteIssue.Project__c);

                        //Check for Project and Close date
                        if(maxSiteIssue == null)
                            continue;

                        if(maxSiteIssue.Total_Delay__c > 0 && siteIssue.Site_Issue_Close_Date__c > maxSiteIssue.Site_Issue_Close_Date__c) {

                            //assign true for Cosecutively
                            siteIssue.Consecutively_Delayed_Load__c = true;
                        }
                    }
                }
            }
        }
    }
    
    // if the program was updated, update the program type on all related member support records
    public static void populateMemberSupportProgramType(list<Project__c> projectList, map<Id, Project__c> ProjectOldMap) {
        
        // set of project ids that have an updated program
        set<Id> projectsWithUpdatedProgram = new set<Id>();
        
        // list of member support records to update
        list<Site_Issue__c> memSupportToUpdate = new list<Site_Issue__c>();
        
        // see which projects need to have their member support records updated
        for (Project__c proj : projectList) {
            
            // get the old project
            Project__c oldProj;
            if (projectOldMap != null) oldProj = projectOldMap.get(proj.Id);
            
            if (proj.Product__c != oldProj.Product__c) {
                
                // add project id to set
                projectsWithUpdatedProgram.add(proj.Id);
            }
        }
        
        if (projectsWithUpdatedProgram.size() > 0) {
            
            // get all projects an related member support records
            list<Project__c> projectswithMemSupport = [SELECT Id, Program_Acronym__c,
                                                       (SELECT Id, Project_Program_Type__c, Project__c FROM Site_Issues__r)
                                                       FROM Project__c WHERE Id IN :projectsWithUpdatedProgram];
                                                       
            for (Project__c proj : projectswithMemSupport) {
                
                // loop through each member support record and update the project program type
                for (Site_Issue__c memSupport : proj.Site_Issues__r) {
                    
                    // update the program type and add to the list to update
                    memSupport.Project_Program_Type__c = proj.Program_Acronym__c;
                    memSupportToUpdate.add(memSupport);
                }
            }
        }
        
        if (memSupportToUpdate.size() > 0) update memSupportToUpdate;
    }
    
    public static void populateProgramType(list<Site_Issue__c> memberSupportList) {
        
        // get all project ids
        set<Id> projectIdSet = new set<Id>();
        for (Site_Issue__c memSupport : memberSupportList) {
            
            if (memSupport.Project__c != null) 
                projectIdSet.add(memSupport.Project__c);
        }
        
        if (projectIdSet.size() > 0) {
            
            // get all projects
            map<Id, Project__c> projects = new map<Id, Project__c>([SELECT Id, Program_Acronym__c FROM Project__c WHERE Id IN :projectIdSet]);
            
            // see if the program type needs to be updated
            for (Site_Issue__c memSupport : memberSupportList) {
                
                Project__c project = projects.get(memSupport.Project__c);
                
                if (project != null && project.Program_Acronym__c != memSupport.Project_Program_Type__c) {
                    
                    memSupport.Project_Program_Type__c = project.Program_Acronym__c;
                }
            }
        }
    }
    
    /**
     *  @description    :   Method to peform calculation of the average of the past 3 values in  "Elapsed: Files Rec to Next Data Upload" field on Member Support(Site_Issue__c) records.  
     *                      A.  Calculate the average of the past 3 values in  Elapsed: Files Rec to Next Data Upload.  If the average is greater than 5.5, 
     *                          then the Project's Punctuality of Loads field should be "Typically Late".
     *                      B.  Calculate the average of the past 3 values in  Elapsed: Files Rec to Next Data Upload.  If the average is less than or equal to 5.5, 
     *                          then the Project's Punctuality of Loads field should be "Always on Time".
     *                      C.  When there is no pass support record for the project, the Punctuality of Loads will be set as "TBD".
     *
     *                      This should apply to the record type CMA Data Load / Migration Only
     *
     *  @args           :   List of new site issues, Map of old Site issues
     *
     *  @return         :   void
     *
     **/
    //Code added by Bhavi Sharma - 01/31/2014 - CR-20140113-4265
    public static void updatePunctualityOfLoadsOnTheBasisOfFileRecToNextDataUploadValue(List<Site_Issue__c> newSiteIssues, Map<Id, Site_Issue__c> mapOldSiteIssues) {
        
        //Set to hold Project records Id value
        Set<Id> setProjectIds = new Set<Id>();
        
        //Query for the "Member Support" record types (CMA Data Load/Migration)
        Map<Id, RecordType> mapRecordTypes = new Map<Id, RecordType>([SELECT Id FROM RecordType WHERE sObjectType = 'Site_Issue__c' 
                                                                                                    AND DeveloperName =: Constants.RECORD_TYPE_SITE_ISSUE_DEVELOPER_NAME_CMA_DATA_LOAD_MIGRATION 
                                                                                                    AND isActive = True LIMIT 1]);
        
        //Loop through list of "Member Support" records
        //Insert and Update case
        if(newSiteIssues != null) {
            
            for(Site_Issue__c siteIssue : newSiteIssues) {
                
                //Checking if "Member Support" record have "Project" record stamped as parent on it
                if(siteIssue.Project__c != null 
                    && mapRecordTypes.containsKey(siteIssue.RecordTypeId)
                    && (mapOldSiteIssues == null 
                        || siteIssue.Elapsed_Files_Rec_to_Next_Data_Upload__c != mapOldSiteIssues.get(siteIssue.Id).Elapsed_Files_Rec_to_Next_Data_Upload__c)) {
                    
                    //Add project Id in Set to be processed
                    setProjectIds.add(siteIssue.Project__c);
                }
            }
        } else {
            
            //Delete Scenario
            for(Site_Issue__c siteIssue : mapOldSiteIssues.values()) {
                
                //Checking if "Member Support" record have "Project" record stamped as parent on it
                if(siteIssue.Project__c != null && mapRecordTypes.containsKey(siteIssue.RecordTypeId)) {
                    
                    //Add project Id in Set to be processed
                    setProjectIds.add(siteIssue.Project__c);
                }
            }       
        }
        
        //Execute the code only if required
        if(setProjectIds.size() > 0) {
            
            //List of projects to be updated
            List<Project__c> projects = new List<Project__c>();
            
            //Quering Project records and corresponding children "Member Support" records
            for(Project__c p : [SELECT ID, Punctuality_of_Loads__c, 
                                    (Select ID, Elapsed_Files_Rec_to_Next_Data_Upload__c FROM Site_Issues__r where RecordType.DeveloperName =: Constants.RECORD_TYPE_SITE_ISSUE_DEVELOPER_NAME_CMA_DATA_LOAD_MIGRATION AND Elapsed_Files_Rec_to_Next_Data_Upload__c != null ORDER BY CreatedDate DESC LIMIT 3) 
                                        FROM Project__c WHERE Id IN : setProjectIds]) {
                                            
                //Integer variable to hold the sum of "Elapsed: Files Rec to Next Data Upload" field value for "member support" records
                Decimal sumElapsedFilesRecToNextDataUpload = 0;
                                            
                //When there is no pass support record for the project, the Punctuality of Loads will be set as "TBD".
                if(p.Site_Issues__r.size() == 0) {
                
                    //Update "Punctuality_of_Loads__c" field with desired value and instance into the list
                    p.Punctuality_of_Loads__c = Constants.PROJECT_PUNCTUALITY_OF_LOADS_TBD;
                    projects.add(p);
                } else {
                    
                    //Loop through children "Member Support" records corresponding to the Project record in current context
                    for(Site_Issue__c siteIssue : p.Site_Issues__r) {
                        
                        //Perform addition for the field values
                        if(siteIssue.Elapsed_Files_Rec_to_Next_Data_Upload__c != null)
                            sumElapsedFilesRecToNextDataUpload += siteIssue.Elapsed_Files_Rec_to_Next_Data_Upload__c;
                        else
                            sumElapsedFilesRecToNextDataUpload += 0;
                    }
                    
                    //Average
                    Decimal avgElapsedFilesRecToNextDataUpload = sumElapsedFilesRecToNextDataUpload/p.Site_Issues__r.size();
                    
                    //If the average is greater than 5.5, then the Project's Punctuality of Loads field should be "Typically Late".
                    if(avgElapsedFilesRecToNextDataUpload > 5.5) {
                        
                        //Checking picklist field value on project record before updation because if that were similar then there is no need for updation
                        if(p.Punctuality_of_Loads__c != Constants.PROJECT_PUNCTUALITY_OF_LOADS_TYPICALLY_LATE) {    
                            
                            //Project Instance and it to the list for update
                            p.Punctuality_of_Loads__c = Constants.PROJECT_PUNCTUALITY_OF_LOADS_TYPICALLY_LATE;
                            projects.add(p);
                        }
                    } else if (avgElapsedFilesRecToNextDataUpload <= 5.5) {
                        //If the average is less than or equal to 5.5, then the Project's Punctuality of Loads field should be "Always on Time".
                            
                        //Checking picklist field value on project record before updation because if that were similar then there is no need for updation
                        if(p.Punctuality_of_Loads__c != Constants.PROJECT_PUNCTUALITY_OF_LOADS_ALWAYS_ON_TIME) {    
                            
                            //Project Instance and it to the list for update
                            p.Punctuality_of_Loads__c = Constants.PROJECT_PUNCTUALITY_OF_LOADS_ALWAYS_ON_TIME;
                            projects.add(p);
                        }
                    }
                } 
            }
            
            //Checking list for size value
            if(projects.size() > 0) {
                
                //Bypass All other triggers
                Util.BypassAllTriggers = true;
                update projects;
            }           
        }
    }
    
    /**
     * 
     * @description: 
     * 
     * @revisions: added support for the PIC *** record types (excluding PIC Rate Schedule)
     * 
     **/
    //Determine if a case record needs to be created or synchronized.  CR-4283
    public static void syncMemberSupportToCase(list<Site_Issue__c> newMemSupportList, map<Id, Site_Issue__c> oldMemberSupportMap) {
        
        //Get the member support records and related case
        map<Id, Site_Issue__c> memSupportWithCaseMap = new map<Id, Site_Issue__c>([SELECT Id, (SELECT Id, Subject, CaseNumber, Status, Priority, 
                                                                                                Member_Support_Ticket__c, Origin, ContactId, Description FROM Cases__r)
                                                        FROM Site_Issue__c WHERE Id IN :newMemSupportList]);
        
        //get a map of projects with account Id
        set<Id> projectIdSet = new set<Id>();
        for (Site_Issue__c s : newMemSupportList) projectIdSet.add(s.Project__c);
        map<Id, Project__c> projectMap = new map<Id, Project__c>([SELECT Id, Institution__c FROM Project__c WHERE Id IN :projectIdSet]);
        
        list<Case> casesToUpsert = new list<Case>();
        
        boolean hasNewCases = false;
        
        //Iterate over each case to determine if a member support record sync is necessary
        for (Site_Issue__c newMemSupport : newMemSupportList) {
            
            //VH 3/14/16 - CR-1223
            if (CaseTriggerHelper.getSyncRecordTypeIds('Site_Issue__c').contains(newMemSupport.RecordTypeId)) {
                
                //Get the old member support record
                Site_Issue__c oldMemSupport;
                if (oldMemberSupportMap != null) oldMemSupport = oldMemberSupportMap.get(newMemSupport.Id);
                
                Case msCase;
                
                //If this is an update and the case record exists in our map, get the existing member support record
                if (memSupportWithCaseMap.get(newMemSupport.Id).Cases__r.size() > 0) {
                    msCase = memSupportWithCaseMap.get(newMemSupport.Id).Cases__r[0];
                }
                else {
                    
                    //get the related project associated with the member support Project, so we can get the accountId
                    Project__c msProject = projectMap.get(newMemSupport.Project__c);
                    
                    msCase = new Case(RecordTypeId = MemberSupportTriggerUtilities.getCaseRTID(newMemSupport.RecordTypeId),
                                      Project_Source_MS__c = newMemSupport.Project__c,
                                      ContactId = newMemSupport.Reported_By__c);
                    
                    if (newMemSupport.RecordTypeId == Constants.RECORD_TYPE_ID_SITE_ISSUE_CCA_SUPPORT_REQUEST
                        || newMemSupport.RecordTypeId == Constants.RECORD_TYPE_ID_SITE_ISSUE_CCA_DATA_LOAD)
                    {
                        msCase.OwnerId = Constants.tier2SupportQueue.Id;
                    }
                    
                    if (msProject != null)
                        msCase.AccountId = msProject.Institution__c;
                    else if (newMemSupport.Institution__c != null)
                        msCase.AccountId = newMemSupport.Institution__c;
                    
                    //Set hasNewCases = true so we can synchronize the case number with the mem support record
                    hasNewCases = true;
                }
                
                boolean isNewCase = (msCase.Id == null);
                
                //If certain fields were modified, mirror changes to related case record
                if (CaseTriggerHelper.recordNeedsSynced(newMemSupport, oldMemSupport) || isNewCase) {
                    
                    //Populate member support field values to the case record 
                    msCase = (Case) CaseTriggerHelper.populateSourceFieldsToTarget((sObject) oldMemSupport, (sObject) newMemSupport, (sObject) msCase);
                    
                    if (msCase.Member_Support_Ticket__c == null)
                        msCase.Member_Support_Ticket__c = newMemSupport.Id; 
                        
                    //add the updated memberSupport record to the upsert list
                    casesToUpsert.add(msCase);
                }
                
            }
        }
        
        if (casesToUpsert.size() > 0) {
            
            Util.BypassAllTriggers = true;
            upsert casesToUpsert;
            Util.BypassAllTriggers = false;
            
            //Popuate the caseNumber on the Member Support records
            map<Id, Case> caseMap = new map<Id, Case>();
            caseMap.putAll(casesToUpsert);
            map<Id, Site_Issue__c> memSupportMap = new map<Id, Site_Issue__c>();
            memSupportMap.putAll(newMemSupportList);
            populateCaseNumOnMS(memSupportMap.keySet(), caseMap.keySet());
        }
    }
    
    /**
    *
    *   @description: based on the member support rt id, return the corresponding case rt id
    * 
    *   @revisions: VH - 3/14/16 - added code to return the PIC Support record type
    *
    **/
    public static Id getCaseRTID(Id memSupportRTID) {
        
        Id caseRTID;
        if (memSupportRTID == Constants.RECORD_TYPE_ID_SITE_ISSUE_CCA_SUPPORT_REQUEST)
            caseRTID = Constants.RECORD_TYPE_ID_CASE_PT_SUPPORT;
        else if (memSupportRTID == Constants.RECORD_TYPE_ID_SITE_ISSUE_CCA_DATA_LOAD)
            caseRTID = Constants.RECORD_TYPE_ID_CASE_PT_DATA_LOAD;
        else
            caseRTId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('PIC Support').getRecordTypeId();
        return caseRTID;
    }
    
    /**
    *
    *   @description: based on the case rt id, return the corresponding member support rt id
    *
    **/
    public static Id getMemSupportRTID(Id caseRTID) {
        
        Id memSupportRTID;
        if (caseRTID == Constants.RECORD_TYPE_ID_CASE_PT_SUPPORT)
            memSupportRTID = Constants.RECORD_TYPE_ID_SITE_ISSUE_CCA_SUPPORT_REQUEST;
        else if (caseRTID == Constants.RECORD_TYPE_ID_CASE_PT_DATA_LOAD)
            memSupportRTID = Constants.RECORD_TYPE_ID_SITE_ISSUE_CCA_DATA_LOAD;
        return memSupportRTID;
    }
    
    @future
    public static void populateCaseNumOnMS(set<Id> memSupportIdSet, set<Id> caseIdSet) {
        
        list<Site_Issue__c> siteIssuesToUpdate = new list<Site_Issue__c>();
        
        list<Site_Issue__c> memSupportList = [SELECT Id, Case_Number__c, Case__c, (SELECT Id, CaseNumber FROM Cases__r) 
                                          FROM Site_Issue__c WHERE Id IN :memSupportIdSet];
        
        for (Site_Issue__c ms : memSupportList) {
            
            //Populate the case number to issue number field
            if (ms.Cases__r.size() > 0 && ms.Case_Number__c == null) {
                ms.Case_Number__c = ms.Cases__r[0].CaseNumber;
                ms.Case__c = ms.Cases__r[0].Id;
                siteIssuesToUpdate.add(ms);
            }
        }
        
        if (siteIssuesToUpdate.size() > 0) {
            
            update siteIssuesToUpdate;
        }
    }
    
    /**
    *
    *   @description: If the Tier 1 Support Analyst field on Member Support is an ID, lookup the users it corresponds to
    *                 and update the field with the user's name.
    *
    *   @params: list<Site_Issue__c>
    *
    **/
    public static list<Site_Issue__c> populateTier1Name(list<Site_Issue__c> newMemSupportList) {
        
        set<Id> userIdSet = new set<Id>();
        map<Id, User> userMap = new map<Id, User>();
        
        for (Site_Issue__c ms : newMemSupportList) {
            
            if (ms.Tier_I_Support_Analyst__c != null && ms.Tier_I_Support_Analyst__c instanceof Id) {
                
                userIdSet.add(ms.Tier_I_Support_Analyst__c);
            }
        }
        
        if (userIdSet.size() > 0) {
            userMap = new map<Id, User>([SELECT Id, Name FROM User WHERE Id IN :userIdSet]);
        }
        
        for (Site_Issue__c ms : newMemSupportList) {
            
            if (ms.Tier_I_Support_Analyst__c != null && ms.Tier_I_Support_Analyst__c instanceof Id) {
                
                User u = userMap.get(ms.Tier_I_Support_Analyst__c);
                if (u != null) ms.Tier_I_Support_Analyst__c = u.Name;
            }
        }
        
        return newMemSupportList;
    }
    
    public static void updateRelatedProjects(list<Site_Issue__c> siteIssueList) {
        
        Set<ID> projectids = new Set<ID>();
        list<Project__c> projectsToUpdate = new list<Project__c>();
        
        //Loop through Trigger.New
        for(site_issue__c siteissue : siteIssueList) projectids.add(siteissue.project__c);
        
        //Modified By Abhinav Sharma - 03-11-2014 - CR-20140108-4243 - CMA - MS - Version Workflow Update
        // query projects related to modified support issues and all their related support issues
        List<Project__c> projects = [Select Id, total_delay__c, current_data_period_new__c, version_bridge_new__c, site_issue_count_new__c, 
                                        (Select RecordType.DeveloperName, Support_Category__c, Data_Load_Type__c, data_load_period_end__c, 
                                            site_issue_close_date__c, total_delay__c, version_ms__c, counts_as_open_issue__c, 
                                            Counts_for_current_data_period__c, Status__c from Site_Issues__r 
                                                where counts_as_open_issue__c >0 or data_load_period_end__c>= 2011-01-01 or version_ms__c != null 
                                                order by site_issue_close_date__c asc) 
                                        from project__c Where Id in :projectids];
        if (projects.size()==0)
            return; 
        
        //for each project, calculate the virtual roll-up fields and the 'project delayed field'
        for(project__c project : projects) {
            
            date current_data_period_new;
            decimal site_issue_count_new, version_bridge_new;
            Integer i=0;
            for (site_issue__c issue : project.site_issues__r) {
                i++;
                System.debug('Version####'+project.version_bridge_new__c);
                 
                //this counts number of total open site issues for the project based on field counts as site issue
                if(issue.counts_as_open_issue__c>0){
                    if(site_issue_count_new == null){
                            site_issue_count_new=1;
                    }else{
                            site_issue_count_new+=issue.counts_as_open_issue__c;
                    }
                }
                        
                //this calculates the current data period based on max of data load period end where close date > jan 1 2011
                if(issue.data_load_period_end__c != null && issue.Counts_for_current_data_period__c==1){
            
                    if (current_data_period_new == null){
                        current_data_period_new=issue.data_load_period_end__c;
                    } else {
            
                        if(current_data_period_new<issue.data_load_period_end__c){
                            current_data_period_new=issue.data_load_period_end__c;
                        }
                    }
                }
                 
                //Code added by Bhavi Sharma - 04/29/2013 - CR-20130403-2801
                //Condition added for whole recordTypes which are contains 'CMA' in RecordTypeName - Bhavi Sharma - 07/19/2013 - CR-20130718-3283
                //Criteria Updated By Abhinav Sharma - 03-11-2014 - CR-20140108-4243 - CMA - MS - Version Workflow Update
                //Check criteria
                if((((issue.recordtype.DeveloperName == Constants.RECORD_TYPE_SITE_ISSUE_DEVELOPER_NAME_CMA_DATA_LOAD_MIGRATION && issue.Status__c != Constants.STATUS_X_DUPLICATE_CANCELLED)
                        || (issue.recordtype.DeveloperName == Constants.RECORD_TYPE_SITE_ISSUE_DEVELOPER_NAME_CMA_INITIAL_DEPLOYMENT_SUPPORT && issue.Status__c != Constants.STATUS_X_DUPLICATE_CANCELLED)) 
                    || (issue.recordtype.DeveloperName == Constants.RECORD_TYPE_SITE_ISSUE_DEVELOPER_NAME_CCA_DATA_LOAD
                         && (issue.Data_Load_Type__c == Constants.HISTORICAL_RELOAD || issue.Data_Load_Type__c == Constants.CURRENT))
                    || (issue.recordtype.DeveloperName == Constants.RECORD_TYPE_SITE_ISSUE_DEVELOPER_NAME_CRIMSON_SUPPORT_REQUEST 
                        && issue.Support_Category__c == Constants.CRIMSON_SUPPORT_REQUEST_SITE_ISSUE_SUPPORT_CATEGORY_PRODUCTION_MIGRATION))
                    && issue.Site_Issue_Close_Date__c != null) {
                
                    //this calculates max of version 
                    if(issue.version_ms__c != null) {
                        
                        //Check for Project's Version Bridge field has null
                        if (version_bridge_new == null){
                            
                            version_bridge_new=issue.version_ms__c;
                        }
                        //Check for Project's Version Bridge field > Member Support's Version Ms Value
                        else if(version_bridge_new < issue.version_ms__c) {
                            System.debug('@@@@@ version_bridge_new before ' + version_bridge_new);
                            version_bridge_new=issue.version_ms__c;
                            System.debug('@@@@@ version_bridge_new after ' + version_bridge_new);
                        }
                    }
                }
            }
            
            if (project.current_data_period_new__c != current_data_period_new
             || project.version_bridge_new__c != version_bridge_new
             || project.site_issue_count_new__c != site_issue_count_new) 
            {
                project.current_data_period_new__c = current_data_period_new;
                project.version_bridge_new__c = version_bridge_new;
                project.site_issue_count_new__c = site_issue_count_new;
                projectsToUpdate.add(project);
            }
        }
        
        //Update project list records
        if (projectsToUpdate.size() > 0) update projectsToUpdate;
    }
    
    //Added By - Ajit Surana - 10/16/2014 - CR-20140725-6664
    /**
     *  @description    :   Method to populate project field: "Expected File Received Date" with Member Support record having 
     *                      most recent Date/Time Closed(Site_Issue_Close_Date__c) in DESC order
     *                      Status = "10 - Closed, Member Notified", and
     *                      Record Type = ‘CCA Data Load Type”
     * 
     *  @args           :   List of cases, Map of Cases
     * 
     *  @return         :   void
     * 
    **/ 
    public static void updateExpectedFileReceivedDateOnProject(List<Site_Issue__c> newMemberSupports, map<Id, Site_Issue__c> oldMemberSupportsMap) {
        
        //Query for the "Member Support" record types (CCA Data Load Type)
        List<RecordType> recordTypes = [SELECT Id FROM RecordType WHERE sObjectType = 'Site_Issue__c' 
                                            AND DeveloperName = 'CCA_Data_Load' AND isActive = True LIMIT 1];
        
        //Checking if record type exists or not
        if(recordTypes != null && recordTypes.size() > 0) {
        
            //Set to hold the parent record Ids
            Set<Id> setProjectIds = new Set<Id>();
        
            //Loop through member support records
            for(Site_Issue__c sI : newMemberSupports) {
                
                //Insert Case
                if(oldMemberSupportsMap == null && sI.Project__c != null)
                    setProjectIds.add(sI.Project__c);
                
                //Update case
                if(oldMemberSupportsMap != null && oldMemberSupportsMap.get(sI.Id) != null
                    && (sI.Project__c != oldMemberSupportsMap.get(sI.Id).Project__c 
                        || sI.RecordTypeId != oldMemberSupportsMap.get(sI.Id).RecordTypeId
                        || sI.Status__c != oldMemberSupportsMap.get(sI.Id).Status__c
                        || sI.Site_Issue_Close_Date__c != oldMemberSupportsMap.get(sI.Id).Site_Issue_Close_Date__c
                        || sI.Data_Load_Period_End__c != oldMemberSupportsMap.get(sI.Id).Data_Load_Period_End__c
                        || sI.Crimson_Data_Lag_1__c != oldMemberSupportsMap.get(sI.Id).Crimson_Data_Lag_1__c
                        || sI.Expected_File_Received_Date__c != oldMemberSupportsMap.get(sI.Id).Expected_File_Received_Date__c
                       ) 
                  ) {
                    
                    //Checking for project value
                    if(sI.Project__c != null)
                        setProjectIds.add(sI.Project__c);
                        
                    //Checking for the project value previous to update
                    if(oldMemberSupportsMap.get(sI.Id).Project__c != null)
                        setProjectIds.add(oldMemberSupportsMap.get(sI.Id).Project__c);
                } 
            }
        
            //Debugging for the value
            System.debug('@@@@@@@ setProjectIds ' + setProjectIds);
            
            //Checking for size value
            if(setProjectIds.size() > 0) {
                                                                    
                //Map of projects
                Map<Id, Project__c> mapProjects = new Map<Id, Project__c>();
            
                //Loop through eligible project records
                for(Project__c pro : [SELECT ID, Elapsed_MS_Data_Load_Period_Data_Lag__c,
                                        (SELECT ID, Expected_File_Received_Date__c FROM Site_Issues__r 
                                            WHERE RecordTypeId IN : recordTypes
                                                AND Site_Issue_Close_Date__c != null 
                                                AND Status__c = '10 - Closed, Member Notified'
                                            ORDER BY Site_Issue_Close_Date__c DESC LIMIT 1) 
                                        FROM Project__c WHERE ID IN : setProjectIds]) {
                    
                    //Checking if project is having children "Member Support" associated to it or not
                    if(pro.Site_Issues__r != null && pro.Site_Issues__r.size() > 0) {
                        if(pro.Elapsed_MS_Data_Load_Period_Data_Lag__c != pro.Site_Issues__r[0].Expected_File_Received_Date__c) {
                            pro.Elapsed_MS_Data_Load_Period_Data_Lag__c = pro.Site_Issues__r[0].Expected_File_Received_Date__c;
                            mapProjects.put(pro.Id, pro);
                        }
                    } else {
                        if(pro.Elapsed_MS_Data_Load_Period_Data_Lag__c != null) {
                            pro.Elapsed_MS_Data_Load_Period_Data_Lag__c = null;
                            mapProjects.put(pro.Id, pro);
                        }
                    }
                }
            
                //Checking map for size value
                if(mapProjects.values().size() > 0)
                    update mapProjects.values();
            }
        }
    }
    
    //Added By - Abhinav Surana - 04/02/2015 - CR-20130913-3640
    /**
     *  @description    :   Method to populate "Estimated Prod Team Transition Date" field on project 
                            with most recent ticket Estimated Prod Team Transition Date
     *                      field value.
     * 
     *  @args           :   List of Member Support, Map of Member Supports
     * 
     *  @return         :   void
     * 
    **/ 
    public static void updateEstimatedProdTeamTransitionDateOnProject(List<Site_Issue__c> newMemberSupports, map<Id, Site_Issue__c> oldMemberSupportsMap) {
        
        //Query for the "Member Support" record types (CMA Data Load/Migration)
        List<RecordType> recordTypes = [SELECT Id FROM RecordType WHERE sObjectType = 'Site_Issue__c' 
                                            AND DeveloperName = 'CMA_Data_Load_Production' AND isActive = True LIMIT 1];
                                            
        //Map to hold the Project Id as key and Set of Member Support Ids as value
        Map<Id, Set<Id>> mapProjectIdWithTicketsIds = new Map<Id, Set<Id>>();
        
        //Loop through member support records and populating map accordingly
        for(Site_Issue__c ss : newMemberSupports) {
            if(ss.project__c != null) {
                if(mapProjectIdWithTicketsIds.containsKey(ss.project__c))
                    mapProjectIdWithTicketsIds.get(ss.project__c).add(ss.Id);
                else
                    mapProjectIdWithTicketsIds.put(ss.project__c, new Set<Id>{ss.Id});  
            }
        }
        
        System.debug('@@@@@@ mapProjectIdWithTicketsIds ' + mapProjectIdWithTicketsIds);
        
        //Checking if record type exists or not
        if(recordTypes != null && recordTypes.size() > 0) {
        
            //Set to hold the parent record Ids
            Set<Id> setProjectIds = new Set<Id>();
        
            //Loop through member support records
            for(Site_Issue__c sI : newMemberSupports) {
                
                //Insert Case
                if(oldMemberSupportsMap == null && sI.Project__c != null)
                    setProjectIds.add(sI.Project__c);
                
                //Update case
                if(oldMemberSupportsMap != null && oldMemberSupportsMap.get(sI.Id) != null) {
                    
                    //Checking for project value
                    if(sI.Project__c != null)
                        setProjectIds.add(sI.Project__c);
                        
                    //Checking for the project value previous to update
                    if(oldMemberSupportsMap.get(sI.Id).Project__c != null)
                        setProjectIds.add(oldMemberSupportsMap.get(sI.Id).Project__c);
                } 
            }
        
            //Checking for size value
            if(setProjectIds.size() > 0) {
                                                                    
                //Map of projects
                Map<Id, Project__c> mapProjects = new Map<Id, Project__c>();
            
                //Loop through eligible project records
                for(Project__c pro : [SELECT ID, Estimated_Prod_Transition_Date__c,
                                        (SELECT ID, Estimated_Prod_Team_Transition_Date__c FROM Site_Issues__r 
                                            WHERE Status__c = '22 - Production Migration Complete'
                                                  AND Site_Issue_Close_Date__c != null
                                                  AND RecordTypeId IN : recordTypes 
                                                  AND (
                                                      Data_Load_Type__c = 'Current' 
                                                      OR 
                                                      Data_Load_Type__c = 'Historical/Reload'
                                                      )
                                            ORDER BY CreatedDate DESC LIMIT 1) 
                                        FROM Project__c WHERE ID IN : setProjectIds AND Implementation_Pod__c != 'RMS']) {
                    
                    //Checking if project is having children "Member Support" associated to it or not
                    if(pro.Site_Issues__r != null && pro.Site_Issues__r.size() > 0) {
                        if(pro.Estimated_Prod_Transition_Date__c != pro.Site_Issues__r[0].Estimated_Prod_Team_Transition_Date__c
                            && mapProjectIdWithTicketsIds.containsKey(pro.Id)
                            && mapProjectIdWithTicketsIds.get(pro.Id) != null
                            && mapProjectIdWithTicketsIds.get(pro.Id).contains(pro.Site_Issues__r[0].ID)) {
                                pro.Estimated_Prod_Transition_Date__c = pro.Site_Issues__r[0].Estimated_Prod_Team_Transition_Date__c;
                                mapProjects.put(pro.Id, pro);
                        }
                    } else {
                        if(pro.Estimated_Prod_Transition_Date__c != null) {
                            pro.Estimated_Prod_Transition_Date__c = null;
                            mapProjects.put(pro.Id, pro);
                        }
                    }
                }
                
                //Checking map for size value
                if(mapProjects.values().size() > 0) {
                    Util.byPassAllTriggers = true;
                    update mapProjects.values();
                    Util.byPassAllTriggers = false;
                }
            }
        }
    }
    
    //Modify By - Abhinav Sharma - 11/03/2015 - CR-20151016-9329 - Added additional where clause for Data_Load_Type__c = 'PRM Migration' in SOQL query
    //Added By - Abhinav Sharma - 07/29/2015 - CR-20150709-9070
    /**
     *  @description    :   Method to validate and then populate PRM Version field on project records. (On before events)
     * 
     *  @args           :   List of projects
     *
     *  @return         :   void
     *
    **/
    public static void populateFieldsOnAssociatedProject(List<Site_Issue__c> newSiteIssues, Map<Id, Site_Issue__c> mapOldSiteIssues) {
        
        //Set to hold the project Ids
        Set<Id> setProjectIds = new Set<Id>();
            
        //Insert/Update case
        if(newSiteIssues != null) {
        
            //Loop through new MS records
            for(Site_Issue__c sIssue : newSiteIssues) {
        
                //Insert Case
                if(mapOldSiteIssues == null) {
                    
                    //Checking if MS record is associated with project record and populating set with the ID value
                    if(sIssue.Project__c != null)
                        setProjectIds.add(sIssue.Project__c);
                }
                
                //Update Case
                else {
                    
                    //Checking for the fields value changes
                    if(mapOldSiteIssues.get(sIssue.Id).PRM_Application_Version__c != sIssue.PRM_Application_Version__c
                        || mapOldSiteIssues.get(sIssue.Id).Status__c != sIssue.Status__c
                        || mapOldSiteIssues.get(sIssue.Id).RecordTypeId != sIssue.RecordTypeId
                        || mapOldSiteIssues.get(sIssue.Id).project__c != sIssue.Project__c
                        || mapOldSiteIssues.get(sIssue.Id).Site_Issue_Close_Date__c != sIssue.Site_Issue_Close_Date__c) {
                        
                        //Checking if MS record is associated with project record and populating set with the ID value
                        if(sIssue.Project__c != null)
                            setProjectIds.add(sIssue.Project__c);
                            
                        //Populating set with the Old project record Id value
                        if(mapOldSiteIssues.get(sIssue.Id).project__c != null)
                            setProjectIds.add(mapOldSiteIssues.get(sIssue.Id).project__c);    
                    }
                }
            }                
            
        //Delete Case
        } else {
            
            //Loop through old project records
            for(Site_Issue__c oldSiteIssue : mapOldSiteIssues.values()) {
                
                //Checking if MS record is associated with project record and populating set with the ID value
                if(oldSiteIssue.Project__c != null)
                    setProjectIds.add(oldSiteIssue.Project__c);
            }
        }
        
        //Map of Projects
        Map<Id, Project__c> mapProjectsToUpdate = new Map<Id, Project__c>();
            
        //Checking set for the size value
        if(setProjectIds.size() > 0) {  
            
            //Querying MS records associated with the project records and fulling all the eligibilty criteria's
            for(Project__c pro : [Select ID, PRM_Version__c,
                                    (SELECT ID, Project__c, PRM_Application_Version__c FROM Site_Issues__r 
                                     WHERE Project__c  != null AND Project__c IN : setProjectIds
                                     AND RecordType.DeveloperName = 'CMA_Data_Load_Production'
                                     AND Status__c =: ProjectTriggerHelper.STATUS_22_PRODUCTION_MIGRATION_COMPLETE
                                     AND Site_Issue_Close_Date__c != null
                                     AND Data_Load_Type__c = 'PRM Migration'
                                     ORDER BY Site_Issue_Close_Date__c DESC LIMIT 1)
                                 FROM Project__c WHERE ID IN : setProjectIds]) {
                                     
                //Checking for value in the map and populating it if value does exist in prior
                if(pro.Site_Issues__r != null && pro.Site_Issues__r.size() > 0) {
                    
                    //Checking if field values are already in sync or not    
                    if(pro.PRM_Version__c != pro.Site_Issues__r[0].PRM_Application_Version__c) {
                        
                        //Populating field with appropriate value and then putting it into the map of projects
                        pro.PRM_Version__c = pro.Site_Issues__r[0].PRM_Application_Version__c; 
                        mapProjectsToUpdate.put(pro.Id, pro);
                    }    
                } else {
                    
                    if(pro.PRM_Version__c != null) {
                        pro.PRM_Version__c = null;  
                        mapProjectsToUpdate.put(pro.Id, pro);        
                    }
                }
            }
        }
                    
        //Checking map for size values
        if(mapProjectsToUpdate != null && mapProjectsToUpdate.values() != null
            && mapProjectsToUpdate.values().size() > 0) {
            Util.BypassAllTriggers = true;
            Update mapProjectsToUpdate.values();
            Util.BypassAllTriggers = false;    
        }
    }
    
    //Added By - Abhinav Sharma - 08/24/2015 - CR-20150127-8596
    /**
    *  @description    :   Method to populate “CPRM Current Data Period” field on associated project record with "CPRM Data Load Ticket"
                           "Most recent" Data_Load_Period_End__c field value.
    * 
    *  @args           :   List of Member Support, Map of Member Supports
    * 
    *  @return         :   void
    * 
    **/ 
    public static void populateCPRMCurrentDataPeriodOnProject(List<Site_Issue__c> newMemberSupports, map<Id, Site_Issue__c> oldMemberSupportsMap) {

        //Set to hold Parent Project Ids
        Set<Id> setProjectsIds = new Set<Id>();

        //List to hold the current Context Member Support records
        List<Site_Issue__c> listMemberSupports = newMemberSupports != null ? newMemberSupports : oldMemberSupportsMap.values();

        //Loop through member support records and populating set with parent project records Id value
        for(Site_Issue__c ms : listMemberSupports) {
          
            //Checking for parent project Id value and applying some other valid validations use cases
            if(ms.Project__c != null 
                && 
                (
                    (
                        newMemberSupports != null 
                        && oldMemberSupportsMap != null 
                        && (
                            ms.Data_Load_Period_End__c != oldMemberSupportsMap.get(ms.Id).Data_Load_Period_End__c
                            || 
                            ms.Project__c != oldMemberSupportsMap.get(ms.Id).Project__c
                            ||
                            ms.Status__c != oldMemberSupportsMap.get(ms.Id).Status__c
                            ||
                            ms.RecordTypeId != oldMemberSupportsMap.get(ms.Id).RecordTypeId    
                        )
                    )
                    || (newMemberSupports != null && oldMemberSupportsMap == null)
                    || (newMemberSupports == null && oldMemberSupportsMap != null)
                )
            ) {
                setProjectsIds.add(ms.Project__c);  
                
                if(oldMemberSupportsMap != null && oldMemberSupportsMap.get(ms.Id).Project__c != null)
                    setProjectsIds.add(oldMemberSupportsMap.get(ms.Id).Project__c);
            }
        }
        
        //Chech set size before executing the further logic
        if(setProjectsIds.size() == 0)
            return;
        
        //Map of Projects
        Map<Id, Project__c> mapProjects = new Map<Id, Project__c>();
        
        //Query for the "Member Support" record types (CPRM Data Load)
        List<RecordType> recordTypes = [SELECT Id FROM RecordType 
                                            WHERE sObjectType = 'Site_Issue__c' 
                                            AND DeveloperName = 'CPRM_Data_Load' 
                                            AND isActive = true];
        
        //Checking record type for it's existance
        if(recordTypes != null && recordTypes.size() > 0) {
        
            //Loop through parent project records and populating CPRM_Current_Data_Period__c field on the Project 
            //with the "Most recent" Data_Load_Period_End__c field value of "CPRM Data Load Ticket".
            for(Project__c project : [SELECT Id, CPRM_Current_Data_Period__c,
                                        (SELECT Id, Data_Load_Period_End__c FROM Site_Issues__r 
                                            WHERE RecordTypeId != null
                                            AND RecordTypeId IN : recordTypes 
                                            AND Status__c = '15 - Cross-Verification Completed'
                                            AND Data_Load_Period_End__c != null 
                                            ORDER BY Data_Load_Period_End__c DESC LIMIT 1)
                                      FROM Project__c WHERE Id IN : setProjectsIds]) {
            
                //Only Process the record if found and
                if(project.Site_Issues__r.size() > 0) {
    
                    //Add record in the list to be updated
                    if(project.CPRM_Current_Data_Period__c != project.Site_Issues__r[0].Data_Load_Period_End__c) {
                        project.CPRM_Current_Data_Period__c = project.Site_Issues__r[0].Data_Load_Period_End__c;
                        mapProjects.put(project.Id, project);
                    }        
                } else {
                    
                    //Add record in the list to be updated
                    if(project.CPRM_Current_Data_Period__c != null) {
                        project.CPRM_Current_Data_Period__c = null;
                        mapProjects.put(project.Id, project);
                    }        
                }
            }
            
            //Checking map for size value
            if(mapProjects.values().size() > 0) {
            
                //Bypassing triggers and updating projects with field value
                Util.BypassAllTriggers = true;
                update mapProjects.values();
                Util.BypassAllTriggers = false;
            }
        }        
    }
    
    /**
     * 
     * @description: populate the Institution Formal Name field.  This will be used in formulas & workflow rules (CR-9760)
     * 
     **/
    public static void populateInstitutionFormalName(list<Site_Issue__c> memberSupportList) {
        
        // get all project ids
        set<Id> acctIdSet = new set<Id>();
        for (Site_Issue__c memSupport : memberSupportList) {
            
            if (memSupport.Institution__c != null) 
                acctIdSet.add(memSupport.Institution__c);
        }
        
        if (acctIdSet.size() > 0) {
            
            // get all accounts
            map<Id, Account> accts = new map<Id, Account>([SELECT Id, Account_Formal_Name__c FROM Account WHERE Id IN :acctIdSet]);
            
            // see if the program type needs to be updated
            for (Site_Issue__c memSupport : memberSupportList) {
                
                Account acct = accts.get(memSupport.Institution__c);
                
                if (acct != null && acct.Account_Formal_Name__c != memSupport.Institution_Formal_Name_Text__c) {
                    memSupport.Institution_Formal_Name_Text__c = acct.Account_Formal_Name__c;
                }
            }
        }
    }
    
    /**
      * @Description    :   Method to calculate the business hours ages
      *
      * @args           :   List<Site_Issue__c>
      *
      * @return         :   
      *
      * @Version        :   V1.0 - Created By - Mahendra Swarnkar - CR-20160114-9520 - 08/23/2016
    **/
    public static void calculateBusinessHoursAges(List<Site_Issue__c> memberSupports, Map<Id, Site_Issue__c> msMap) {
        
        //List to hold the all company holidays
        List<Case_Blackout_Days__c> holidays = Util.LIST_OF_COMPANY_HOLIDAYS;
    	
        //Loop through new records
        for(Site_Issue__c ms : memberSupports) {
            
            //Checking for update case only
            if(msMap != null && ms.RecordTypeId != null
            	&& (
                    ms.RecordTypeId == Util.recordtypemap(MemberSupportTriggerUtilities.MEMBER_SUPPORT_OBJECT).get(Constants.RECORD_TYPE_SITE_ISSUE_CCA_DATA_LOAD) 
                    || 
                    ms.RecordTypeId == Util.recordtypemap(MemberSupportTriggerUtilities.MEMBER_SUPPORT_OBJECT).get(Constants.RECORD_TYPE_SITE_ISSUE_CCA_SUPPORT_REQUEST)
                ) 
             	&& ms.Status__c != null 
                && msMap.get(ms.Id).Status__c != null 
                && msMap.get(ms.Id).Status__c.startsWith(System.Label.Member_Support_Status_Initial_Value_Prefix) 
                && msMap.get(ms.Id).Status__c != ms.Status__c
                && !ms.Status__c.startsWith(System.Label.Member_Support_Status_Initial_Value_Prefix)
                && msMap.get(ms.Id).Date_Time_Acknowledged__c == null
            )
            	ms.Date_Time_Acknowledged__c = System.now();
            
            //Populate Open to Acknowledged (Hours) on Member Support
            if(ms.Site_Issue_Created_Date__c != null && ms.Date_Time_Acknowledged__c != null)
            	ms.Elapsed_Open_to_Acknowledged_Hours__c = (Util.businessHoursForStartAndEndDate(ms.Site_Issue_Created_Date__c, ms.Date_Time_Acknowledged__c, holidays))/60;
            else
                ms.Elapsed_Open_to_Acknowledged_Hours__c = null;
            
            //Populate Elapsed: Open to First Response (Hours) on Member Support
            if(ms.Site_Issue_Created_Date__c != null && ms.First_Comment_Date_Time__c != null)
            	ms.Elapsed_Open_to_First_Response_Hours__c = (Util.businessHoursForStartAndEndDate(ms.Site_Issue_Created_Date__c, ms.First_Comment_Date_Time__c, holidays))/60;
            else
                ms.Elapsed_Open_to_First_Response_Hours__c = null;
            
            //Populate Elapsed Open to Actual Resolution -Hours on Member Support
            if(ms.Site_Issue_Created_Date__c != null && ms.Actual_Resolution_Date__c != null)
            	ms.Elapsed_Open_to_Actual_Resolution_Hours__c = (Util.businessHoursForStartAndEndDate(ms.Site_Issue_Created_Date__c, ms.Actual_Resolution_Date__c, holidays))/60;
            else
                ms.Elapsed_Open_to_Actual_Resolution_Hours__c = null;
            
            //Populate Elapsed: Open to Close (Hours) on Member support
            if(ms.Site_Issue_Created_Date__c != null && ms.Site_Issue_Close_Date__c != null)
            	ms.Elapsed_Open_to_Close_Hours__c = (Util.businessHoursForStartAndEndDate(ms.Site_Issue_Created_Date__c, ms.Site_Issue_Close_Date__c, holidays))/60;
            else
                ms.Elapsed_Open_to_Close_Hours__c = null;
        }
    }
    
    /**
      * @Description    :   Method to Populate following Member support field in before case
      *                     	1)	Market Data period begin with months First date 
      *							2)	Market Data period End with months Last date
      *
      * @args           :   List<Site_Issue__c>, Map<Id, Site_Issue__c> msMap
      *
      * @return         :   
      *
      * @Version        :   V1.0 - Created By - Mahendra Swarnkar - CR-20160420-9785 - 09/01/2016
    **/
    public static void populateMarketDataPeriodFields(List<Site_Issue__c> memberSupports, Map<Id, Site_Issue__c> msMap) {
    	
        //Id Of Member Support Record type "CMA Data Load/Migration"
        Id cmaDataLoadMigrationRtypeId = Util.RecordTypeId(ProjectTriggerHelper.MEMBER_SUPPORT_API_NAME, ProjectTriggerHelper.MEMBER_SUPPORT_RECORDTYPE_CMA_DATA_LOAD_MIGRATION);
        
        //Insert/Update case
        for(Site_Issue__c ms : memberSupports) {
            
            //Check for Member Support Record type "CMA Data Load/Migration"
            if( ms.recordTypeId != null
               && cmaDataLoadMigrationRtypeId != null
               && ms.recordTypeId == cmaDataLoadMigrationRtypeId ) {
               
                //A temporary date Instance   
				Date tempDate;
				
                //Populate the Market data period begin with months first date 
				if(ms.Market_Data_Period_Begin__c != null ) {
                    tempDate = ms.Market_Data_Period_Begin__c;
                    ms.Market_Data_Period_Begin__c = Date.newinstance(tempDate.year(), tempDate.month(), 01);    
                }
                   
                //Populate the Market data period End with months Last date   
                if(ms.Market_Data_Period_End__c != null) {
                    
                    tempDate = ms.Market_Data_Period_End__c;
                    
                    //Check for Last Month of the Year
                    if(tempDate.month() == 12){
                        ms.Market_Data_Period_End__c = Date.newinstance(tempDate.year(), 12 ,31);
                    }
                    else {
                        tempDate = Date.newinstance(tempDate.year(), tempDate.month(), 01);
                        ms.Market_Data_Period_End__c = (tempDate.addMonths(1)).addDays(-1);
                    }   
				}
			}
        }   
    }
    
    /**
      * @Description    :   Method to Populate following Member support field in before case
      *                     	1)	Market Data period begin with months First date 
      *							2)	Market Data period End with months Last date
      *
      * @args           :   List<Site_Issue__c>, Map<Id, Site_Issue__c> 
      *
      * @return         :   
      *
      * @Version        :   V1.0 - Created By - Mahendra Swarnkar - CR-20160420-9785 - 09/01/2016
    **/
    public static void populateMarketDataPeriodFieldsOnProject(List<Site_Issue__c> listNewMS, Map<Id, Site_Issue__c> mapOldMS) {
    	
        //Set to hold the eligible Projects
        Set<Id> setProjectIds = new Set<Id>();
        
        //Populate the setProjectIds
        for(Site_Issue__c ms : listNewMS != null ? listNewMS : mapOldMS.values() ) {
            
            //Insert/Update Use case
            if(listNewMS != null){
            
            	//Check the conditions
	            if(mapOldMS == null 
	                ||(  mapOldMS != null 
	                    && ( 
	                        ms.Market_Data_Period_Begin__c != mapOldMS.get(ms.Id).Market_Data_Period_Begin__c
	                        || ms.Market_Data_Period_End__c != mapOldMS.get(ms.Id).Market_Data_Period_End__c
	                        || ms.Status__c != mapOldMS.get(ms.Id).Status__c
	                        || ms.Data_Load_Type__c != mapOldMS.get(ms.Id).Data_Load_Type__c
	                        || ms.Site_Issue_Close_Date__c != mapOldMS.get(ms.Id).Site_Issue_Close_Date__c
	                        || ms.recordTypeId != mapOldMS.get(ms.Id).recordTypeId
	                        || ms.Project__c != mapOldMS.get(ms.Id).Project__c
	                    )
	                )
	            ) {
	            	//Populate the setProjectIds
					if(ms.Project__c != null)
		            	setProjectIds.add(ms.Project__c);
		            
		            //Populate the setProjectIds
		            if(mapOldMS != null && mapOldMS.get(ms.Id).Project__c != null 
		            	&& ms.Project__c != mapOldMS.get(ms.Id).Project__c )
						setProjectIds.add(mapOldMS.get(ms.Id).Project__c);
	            }            
            }
            
            //Delete Use Case
            if(listNewMS == null 
            	&& mapOldMS.get(ms.Id).Project__c != null ) 
				setProjectIds.add(ms.Project__c);
        }
        
        //Method call to populate the reated data perid fields on Project from most recent Member support 
        if(setProjectIds.size() > 0){
        	
        	Map<Id, Project__c> projects = ProjectTriggerHelper.populateMarketDataPeriodFieldsOnProject(setProjectIds);
        	
        	//Check for size
        	if(projects != null 
        		&& projects.values() != null
        		&& projects.values().size() > 0
        	){
        		
	            //By Pass All the triggers
	            Util.BypassAllTriggers = true; 
	            
	            //Update the Projects
	            update projects.values();
	            
	            //Enable All the triggers
	            Util.BypassAllTriggers = false;
                
        	}
        }
    }
}