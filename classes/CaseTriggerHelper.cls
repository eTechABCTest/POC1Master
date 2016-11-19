/**
 *  Description     :   Helper class for case object trigger
 * 
 *  Created By      :   Bhavi Sharma    
 * 
 *  Created Date    :   03/23/2013
 * 
 *  Revision Logs   :   V_1.0 - Created
                        V_1.1 - Modified By Abhinav Sharma - 05/21/2014 - CR-20140108-4238        
 *                      V_1.2 - Modified by Ajit Surana - 05/24/2014 - CR-20140512-5440
 *                      v_1.3 - Modified by Victor Hanson 6/01/2014 - CR-4283
 *                      v_1.4 - Modified By - Abhinav Sharma - 06/19/2014 - CR-20140417-5120
 *                      v_1.5 - Modified By - Abhinav Sharma - CR-20140618-5845 - 07/03/2014 - Added new method - beforeEventsLogicHandler
 *                      v_1.6 - Modified By - Abhinav Sharma - CR-20140629-6015 - 07/04/2014 - Modified existing method - beforeEventsLogicHandler
 *                      v_1.7 - Modified By - Abhinav Sharma - CR-20140707-6093 - 08/06/2014 - Modified existing method - deletedOutOutOfOfficeCases
 *                      v_1.8 - Modified By - Ajit Surana - CR-20140812-6973 - 09/10/2014 - Modified existing method - populateCaseFromEmailToCase
 *                      v_1.9 - Modified By - Abhinav Sharma - CR-20140827-7164 - 10/08/2014 - Modified existing method - deletedOutOutOfOfficeCases and populateCaseFromEmailToCase
 *                      v_1.10 - Modified By - Abhinav Sharma - CR-20141001-7574 -10/15/2014 - Added new method - manageTasksForSyndicatedServiceCases
 *                      v_1.11 - Modified By - Ajit Surana - 11/16/2014 - CR-20141105-7987 - Modified method (populateCaseFromEmailToCase)
 *                      v_1.12 - Modified By - Ajit Surana - 11/17/2014 - CR-20141105-7992 - Modified method (populateCaseFromEmailToCase)
 *                      v_1.13 - Modified By - Ajit Surana - 11/22/2014 - CR-20140625-5930
 *                      v_1.14 - Modified By - Ajit Surana - CR-20141103-7949 - 12/4/2014 - Modified to comment and De-comment out of Member_Facing_Resolution_Summary__c reference
 *                      v_1.15 - Modified By - Abhinav Sharma - 11/26/2015 - CR-20151118-9394 - Modified the method beforeEventsLogicHandler
 *                      v_1.16 - Modified By - Abhinav Sharma - 12/01/2015 - CR-20150616-9006 - Modified existing method - deletedOutOutOfOfficeCases and populateCaseFromEmailToCase 
 *                      v_1.17 - Modified By - Mahendra Swarnakar - 12/02/2015 - CR-20151118-9397 - Modified existing method - deletedOutOutOfOfficeCases and populateCaseFromEmailToCase
 *                      v_1.18 - Modified By - Abhinav Sharma - 02/11/2016 - CR-20150925-9267 - Modified existing method - beforeEventsLogicHandler
 *                      v_1.19 - Modified By - Victor Hanson - 02/19/2016 - CR-20160113-9507 - Modified existing method - convertSourceFieldValue
 *                      v_1.20 - Modified By - Abhinav Sharma - 03/31/2016 - CR-20160224-9632 - Modified existing method - beforeEventsLogicHandler
 *                      v_1.21 - Modified By - Mahendra Swarnkar - 07/05/2016 - CR-20160229-9651 - Added a new method "populateCaseFields" and modify the "beforeEventsLogicHandler" method
 *                      V_1.22 - Modified By - Mahendra Swarnkar - 07/07/2016 - CR-20160609-9913 - Modified the existing method "beforeEventsLogicHandler", existing deadline field population logic.
 *                      V_1.23 - Modified By - MAhendra Swarnkar - CR-20160803-10082 - 08/23/2016 -  Modified the existing method "beforeEventsLogicHandler" to have logic to populate the Priority field on the case for Expert Center record type. Updating the logic of default value for deadline field and added validation logic for Deadine Reason field requiredness for syndicated case record type.
 *                      v_1.24 - Modified By - Abhinav Sharma - 08/30/2016 - CR-20160114-9520 - Added a new method "updateFirstCommentDateTimeOnMS"
 *                      v_1.25 - Modified By - Mahendra Swarnakar - 08/31/2016 - CR-20160715-10014
 * 						v_1.26 - Modified By - Abhinav Sharma - 09/29/2016 - CR-20160916-10182
**/ 
public without sharing class CaseTriggerHelper {
    
    //Static variables
    public final static String SYNDICATED_SERVICES_CASE_RECORD_TYPE = 'Syndicated Services';
    
    //Added By - Mahendra Swarnkar - 07/07/2016 - CR-20160609-9913 - Starts From here
    public final static String EXPERT_CENTER_CASE_RECORD_TYPE = 'Expert Center';
    public final static String TALENT_DEVELOPMENT_CASE_RECORD_TYPE = 'Talent Development';
    public final static String IRC_REQUEST_CASE_RECORD_TYPE = 'IRC Request';
    public final static String INTERNATIONAL_CASE_RECORD_TYPE = 'International';
    //Added By - Mahendra Swarnkar - 07/07/2016 - CR-20160609-9913 -Ends Here
    
    public final static String CASE_STATUS_TENTATIVE = 'Tentative';
    public static Boolean IS_ALREADY_EXECUTED_ONCE = false;
    public static Boolean IS_UPDATE_HAPPENS_ON_INSERT_EVENT = false;
    public static final string CASE_ORIGIN_WEB = 'Web';
    
    //Added By - Abhinav Sharma - 09/29/2016 - CR-20160916-10182
    //Start from here
    public static Boolean IS_RECURSIVE_ACTION_HAPPENS = false;
    //Upto here
   
    //Modified By - Abhinav Sharma - 03/31/2016 - CR-20160224-9632
    //Modified By - Abhinav Sharma - 02/11/2016 - CR-20150925-9267
    //Added By - Abhinav Sharma - CR-20140618-5845 - 07/03/2014
    /**
     *  @description    :   This method is to there to update & validate case records on before events of trigger.
     *                      (i) Method to populate "Member Type" field on case with "RIAMLargeContract" value 
                                    if Key Notes on Institution record contains 'RIAMLargeContract.  
     * 
     *  @args           :   List of cases, Map of Cases
     * 
     *  @return         :   void
     * 
    **/ 
    public static void beforeEventsLogicHandler(List<Case> newCases, Map<Id,Case> oldMapCases) {
        
        //CR-20140618-5845 changes - Start Here
        //Set to hold the parent Account Id values
        Set<Id> setAccountIds = new Set<Id>();
        Set<Id> setContactIds = new Set<Id>();
        
        //Loop through new case records
        for(Case cs : newCases) {
            if(cs.AccountId != null)
                setAccountIds.add(cs.AccountId);
            if(cs.ContactId != null)
                setContactIds.add(cs.ContactId);
        }
        
        //Map to hold the Account records
        Map<Id, Contact> mapContacts = new Map<Id, Contact>();
        
        //Checking for the size value
        if(setContactIds.size() > 0){
           mapContacts = new Map<Id, Contact>([Select Id, Name, AccountId, Account.Platinum_Services__c 
                                                From Contact 
                                                WHERE Id IN : setContactIds]);
        }
        
        //Map to hold the Account records
        Map<Id, Account> mapAccounts = new Map<Id, Account>();
        
        //Map to hold the account ID as key and associated contract records list as value
        Map<Id, List<Contract__c>> mapAccountWithContracts = new Map<Id, List<Contract__c>>();
        
        //Checking for the size value
        if(setAccountIds.size() > 0) {
            
            //Added By - Mahendra Swarnkar - 07/07/2016 - CR-20160609-9913 - Added account field 'Platinum_Services__c' in the Query to fetch its value -Starts From here
            //Map to hold the Account records
            mapAccounts = new Map<Id, Account>([SELECT ID, Description, Platinum_Services__c FROM Account 
                                                                    WHERE ID IN : setAccountIds]);
            
            //Added By - Mahendra Swarnkar - 07/07/2016 - CR-20160609-9913 - Added account field 'Platinum_Services__c' in the Query to fetch its value - Ends here
                             
            //Modified By - Mahedra Swarnkar - 07/05/2016 - CR-20160229-9651 - Updated the query to also fetch the Contract records whose Busines line is TD                                        
            //Added By - Abhinav Sharma - 02/11/2016 - CR-20150925-9267
            //Start from here
            //Loop through contract records and populating map accordingly
            for(Contract__c cABC : [SELECT ID, Program_Acronym__c, Payer_Account__c, Start__c, End__c, Business_Line__c
                                    FROM Contract__c
                                    WHERE Payer_Account__c != null 
                                    AND Payer_Account__c IN : setAccountIds
                                    AND Type__c =: Constants.CONTRACT_TYPE_NBB 
                                    AND (
                                            Business_Line__c =: System.Label.CASE_NEW_MEMBER_PROGRAMS_TYPE 
                                            OR Business_Line__c = 'TD' 
                                        )
                                    AND Start__c != null
                                    AND End__c != null
                                    ORDER By End__c DESC]) { 
                //Checking for parent account presence and populating map accordingly                       
                if(mapAccountWithContracts.containsKey(cABC.Payer_Account__c)) 
                    mapAccountWithContracts.get(cABC.Payer_Account__c).add(cABC);  
                else   
                    mapAccountWithContracts.put(cABC.Payer_Account__c, new List<Contract__c>{cABC});   
            }
            //Upto Here
        }
        
        //Get all record types on case object
        Map<String, Id> caseRecordTypesMap = Util.recordtypemap(Constants.CASE_OBJECT);
        
        //Set to hold the eligible record type IDs
        Set<Id> eligibleCaseRecordTypes = new Set<Id>();
        
        //Get case record types
        Map<Id, String> mapRecordTypes = new Map<Id, String>();
        
        //Modified By - Mahedra Swarnkar - 07/05/2016 - CR-20160229-9651- populating eligibleCaseRecordTypes WITH TD record type Id
        //Looping over map keyset and accordingly populating collection with map retrieved values
        for(String recordTypeLabel : caseRecordTypesMap.keySet()) {
            if(recordTypeLabel != null 
                && (recordTypeLabel.equalsIgnoreCase(System.Label.CASE_NEW_MEMBER_RECORD_TYPE)
                    || recordTypeLabel.equalsIgnoreCase('Talent Development'))
                && caseRecordTypesMap.get(recordTypeLabel) != null  
            )
                eligibleCaseRecordTypes.add(caseRecordTypesMap.get(recordTypeLabel));       
            
            //Populating map to hold the case record type Id as key and correspodning record type label as value
            if(String.isNotBlank(recordTypeLabel) 
               && caseRecordTypesMap.containsKey(recordTypeLabel)
               && caseRecordTypesMap.get(recordTypeLabel) != null)
                mapRecordTypes.put(caseRecordTypesMap.get(recordTypeLabel), recordTypeLabel);
        }                                                   
            
        //Loop through case new records
        for(Case c : newCases) {
                
            //Checking if we are having any record in map corresponding to the case record parent account Id value or not
            //In case if record exist in map then populate "Member Type" field on case with "RIAMLargeContract" value 
            //if Key Notes on Institution record contains 'RIAMLargeContract'.  
            if(c.AccountId != null) {
                    
                //Checking for value in the map
                if(mapAccounts != null && mapAccounts.get(c.AccountId) != null) {
                    if(mapAccounts.get(c.AccountId).Description != null 
                       && mapAccounts.get(c.AccountId).Description.contains(Constants.RIAM_LARGE_CONTRACTS)) {
                        c.Member_Type__c = Constants.RIAM_LARGE_CONTRACTS;
                    } else {
                        c.Member_Type__c = '';
                    }
                } else {
                    c.Member_Type__c = '';
                }
                    
                //Modified By - Mahedra Swarnkar - 07/05/2016 - CR-20160229-9651
                //Added By - Abhinav Sharma - 02/11/2016 - CR-20150925-9267
                //Start from here
                //Temporary variable to hold the contracts program acronyms Concatenated string literal value
                String programAcromyms = '';
                String programAcromymsForTD = '';   
                
                //Checking for the eligible case record types
                if(eligibleCaseRecordTypes != null && eligibleCaseRecordTypes.size() > 0
                    && eligibleCaseRecordTypes.contains(c.RecordTypeId)) {
                
                    //Checking for eligible contract records presence and then accordingly concatenating "Program Acronyms" string literal
                    if(mapAccountWithContracts != null && mapAccountWithContracts.containsKey(c.AccountId) 
                        && mapAccountWithContracts.get(c.AccountId) != null 
                        && mapAccountWithContracts.get(c.AccountId).size() > 0) {
                            
                        //Checking case "CreatedDate" field for null value
                        if(c.CreatedDate != null) {
                            
                            //getting created date GTM time zone value (for comparision in between value)    
                            Date myDate = Date.newInstance(c.CreatedDate.year(), c.CreatedDate.month(), c.CreatedDate.day());
                            Time myTime = Time.newInstance(0, 0, 0, 0);
                            DateTime dt = DateTime.newInstanceGMT(myDate, myTime);
                            
                            //Loop through contract records
                            for(Contract__c conABC : mapAccountWithContracts.get(c.AccountId)) {
                                   
                                //Checking and validating contract "Start" and "End" dates with respect to the case record 
                                //which is in current context
                                if(conABC.Start__c <= dt && conABC.End__c >= dt) {
                                    
                                    if(mapRecordTypes.get(c.RecordTypeId).equalsIgnoreCase(System.Label.CASE_NEW_MEMBER_RECORD_TYPE) && conABC.Business_Line__c == 'RI')
                                        programAcromyms += conABC.Program_Acronym__c + Constants.COMMA;
                                        
                                    if(mapRecordTypes.get(c.RecordTypeId).equalsIgnoreCase('Talent Development') && conABC.Business_Line__c == 'TD')
                                        programAcromymsForTD += conABC.Program_Acronym__c + Constants.COMMA;    
                                }
                            }
                        } else {
                            
                            //Loop through contract records
                            for(Contract__c coABC : mapAccountWithContracts.get(c.AccountId)) {
                                   
                                //Checking and validating contract "Start" and "End" dates with respect to the case record 
                                //which is in current context
                                if(coABC.Start__c <= System.today() && coABC.End__c >= System.today()) {
                                    if(mapRecordTypes.get(c.RecordTypeId).equalsIgnoreCase(System.Label.CASE_NEW_MEMBER_RECORD_TYPE))
                                        programAcromyms += coABC.Program_Acronym__c + Constants.COMMA;  
                                        
                                    if(mapRecordTypes.get(c.RecordTypeId).equalsIgnoreCase('Talent Development'))
                                        programAcromymsForTD += coABC.Program_Acronym__c + Constants.COMMA;
                                }
                            }                            
                        }    
                           
                        //Removing additional "," from the end of concatenated string literal (if exists)
                        if(programAcromyms != '') {
                               
                            //Trim the white spaces
                            programAcromyms = programAcromyms.trim();
                               
                            //Checking if last character of string literal is "Comma" or not
                            if(programAcromyms.substring((programAcromyms.length()-1), programAcromyms.length()) == Constants.COMMA)
                                programAcromyms = programAcromyms.removeEnd(Constants.COMMA);
                        }
                        if(programAcromymsForTD != '') {
                               
                            //Trim the white spaces
                            programAcromymsForTD = programAcromymsForTD.trim();
                               
                            //Checking if last character of string literal is "Comma" or not
                            if(programAcromymsForTD.substring((programAcromymsForTD.length()-1), programAcromymsForTD.length()) == Constants.COMMA)
                                programAcromymsForTD = programAcromymsForTD.removeEnd(Constants.COMMA);
                        }
                    }
                }    
                
                //Populating "New_Member_Programs_RI__c" field with "Program Acronym" concatenated string literal value
                c.New_Member_Programs_RI__c = programAcromyms;
                c.New_Member_Programs_TD__c = programAcromymsForTD;
                
                //Upto here
                    
            } else {
                c.Member_Type__c = '';
                c.New_Member_Programs_RI__c = '';
                c.New_Member_Programs_TD__c = '';
            } 
            //Upto Here
        }
           
        //Modified By - Mahendra Swarnkar- CR-20160609-9913 - 7/7/2016 - Starts from here
        //List to hold the all company holidays
        List<Case_Blackout_Days__c> holidays = Util.LIST_OF_COMPANY_HOLIDAYS;
        
        //CR-20140629-6015 - Changes Start From Here
        //Code will only be executed for case record "Insert" event
        if(oldMapCases == null) {
                                                    
            //Perform the below logic only & only if above queries record type exists in the system
            if(caseRecordTypesMap != null && caseRecordTypesMap.size() > 0) {
                
                //Modified By - Mahendra Swarnkar- CR-20160609-9913 - 7/7/2016 - 
                //Starts from here - Added the following logic:-
                //1) Pass the company holidays as an argument in the AddBusinessDays method
                //and extnding the deadline functionality for expert center and Talent Development Case record types
                //2) Setting Deadline to 3 business days for "Syndicated Services" and "Expert Cnter" Case type records
                //Loop through new case records
                for(Case c : newCases) {
                    
                    //Check for Record type 
                    if(c.RecordTypeId != null){
                        
                        //Setting Deadline to 3 business days for records of "IRC Request" Case record types,
                        if(caseRecordTypesMap.containsKey(IRC_REQUEST_CASE_RECORD_TYPE)
                            && caseRecordTypesMap.get(IRC_REQUEST_CASE_RECORD_TYPE) != null 
                            && c.RecordTypeId == caseRecordTypesMap.get(IRC_REQUEST_CASE_RECORD_TYPE)
                        ) {
                            c.Deadline__c = Util.AddBusinessDays(System.today(), Integer.valueOf(System.Label.IRC_DeadLine_Default),holidays);
                        }
                        
                        //Modified By - Mahendra Swarnkar - CR-20160803-10082 - 08/23/2016 - Starts from here
                        //Setting Deadline to 3 business days for records of Talent Development record types, 
                        //if Platinum Services on related Account is true
                        if(caseRecordTypesMap.containsKey(TALENT_DEVELOPMENT_CASE_RECORD_TYPE)
                            && caseRecordTypesMap.get(TALENT_DEVELOPMENT_CASE_RECORD_TYPE) != null 
                            && c.RecordTypeId == caseRecordTypesMap.get(TALENT_DEVELOPMENT_CASE_RECORD_TYPE)
                            && 
                            (
                                (c.AccountId != null
                                     && mapAccounts != null 
                                     && mapAccounts.size() > 0 
                                     && mapAccounts.containsKey(c.AccountId)
                                     && mapAccounts.get(c.AccountId) != null
                                     && mapAccounts.get(c.AccountId).Platinum_Services__c == true
                                )
                                || 
                                (c.ContactId != null
                                     && mapContacts != null 
                                     && mapContacts.size() > 0 
                                     && mapContacts.containsKey(c.ContactId)
                                     && mapContacts.get(c.ContactId) != null
                                     && mapContacts.get(c.ContactId).AccountId != null
                                     && mapContacts.get(c.ContactId).Account.Platinum_Services__c == true
                                )
                            )
                        ) {
                            c.Deadline__c = Util.AddBusinessDays(System.today(), Integer.valueOf(System.Label.TalentDevelopment_DeadLine_Platinum_True_Default), holidays);
                        }
                        
                        
                        //Populating Deadline field value for Syndicated services record types as follows:-
                        //if Platinum Services on related Account is true, then Setting Deadline to 3 business days after 
                        //else set to 7 business days after, as default value
                        if(caseRecordTypesMap.containsKey(SYNDICATED_SERVICES_CASE_RECORD_TYPE)
                            && caseRecordTypesMap.get(SYNDICATED_SERVICES_CASE_RECORD_TYPE) != null 
                            && c.RecordTypeId == caseRecordTypesMap.get(SYNDICATED_SERVICES_CASE_RECORD_TYPE)
                        ){
                           if(
                                (c.AccountId != null
                                     && mapAccounts != null 
                                     && mapAccounts.size() > 0 
                                     && mapAccounts.containsKey(c.AccountId)
                                     && mapAccounts.get(c.AccountId) != null
                                     && mapAccounts.get(c.AccountId).Platinum_Services__c == true
                                )
                                || 
                                (c.ContactId != null
                                     && mapContacts != null 
                                     && mapContacts.size() > 0 
                                     && mapContacts.containsKey(c.ContactId)
                                     && mapContacts.get(c.ContactId) != null
                                     && mapContacts.get(c.ContactId).AccountId != null
                                     && mapContacts.get(c.ContactId).Account.Platinum_Services__c == true
                                )
                            ) {
                                c.Deadline__c = Util.AddBusinessDays(System.today(), Integer.valueOf(System.Label.SyndicatedServices_DeadLine_Platinum_True_Default), holidays);
                            }
                            else{
                                
                                c.Deadline__c = Util.AddBusinessDays(System.today(), Integer.valueOf(System.Label.SyndicatedServices_DeadLine_Platinum_False_Default), holidays);
                            }
                        }
                        
                        //Populating Deadline field value for Expert Center record types as follows:-
                        //if Platinum Services on related Account is true, then Setting Deadline to 3 business days after 
                        //else if origin is Member Priority then, set to 7 business days after
                        //else set to 5 business days after, as a default value
                        if(caseRecordTypesMap.containsKey(EXPERT_CENTER_CASE_RECORD_TYPE)
                            && caseRecordTypesMap.get(EXPERT_CENTER_CASE_RECORD_TYPE) != null 
                            && c.RecordTypeId == caseRecordTypesMap.get(EXPERT_CENTER_CASE_RECORD_TYPE)    
                        ){
                           if(
                                (c.AccountId != null
                                     && mapAccounts != null 
                                     && mapAccounts.size() > 0 
                                     && mapAccounts.containsKey(c.AccountId)
                                     && mapAccounts.get(c.AccountId) != null
                                     && mapAccounts.get(c.AccountId).Platinum_Services__c == true
                                )
                                || 
                                (c.ContactId != null
                                     && mapContacts != null 
                                     && mapContacts.size() > 0 
                                     && mapContacts.containsKey(c.ContactId)
                                     && mapContacts.get(c.ContactId) != null
                                     && mapContacts.get(c.ContactId).AccountId != null
                                     && mapContacts.get(c.ContactId).Account.Platinum_Services__c == true
                                )
                            ) {
                                //Added as per the UAT Changes -CR-20160803-10082-:- the condition to auto populate the deadline if it is not < 3 Businesss days
                                if(c.Deadline__c >= Util.AddBusinessDays(System.today(), Integer.valueOf(System.Label.ExpertCenter_NoOfBusinessDaysToDeadLine_Priorty_Platinum_True) , holidays))
                                    c.Deadline__c = Util.AddBusinessDays(System.today(), Integer.valueOf(System.Label.ExpertCenter_DeadLine_Platinum_True_Default), holidays);
                            }
                            else {

                                //Check for Case requested from ie. if origin of Case request is from Member Priority
                                if(String.isNotBlank(c.Origin) 
                                    && c.Origin == System.Label.ORIGIN_MEMBER_PRIORITY) {
                                    
                                    //Added as per the UAT Changes -CR-20160803-10082-:- the condition to auto populate the deadline if it is not < 7 Businesss days
                                    if(c.Deadline__c >= Util.AddBusinessDays(System.today(), Integer.valueOf(System.Label.ExpertCenter_NoOfBusinessDaysToDeadLine_Priorty_MemberPriority) , holidays))
                                        c.Deadline__c = Util.AddBusinessDays(System.today(), Integer.valueOf(System.Label.ExpertCenter_DeadLine_Platinum_False_MemberPriority_Default), holidays);
                                }
                            
                                //Check for Case requeste is a Inbound Request ie. if origin of request is not Member Priority
                                else {
                                    
                                    //Added as per the UAT Changes -CR-20160803-10082-:- the condition to auto populate the deadline if it is not < 5 Businesss days
                                    if(c.Deadline__c >= Util.AddBusinessDays(System.today(), Integer.valueOf(System.Label.ExpertCenter_NoOfBusinessDaysToDeadLine_Priorty_Inbound) , holidays))
                                        c.Deadline__c = Util.AddBusinessDays(System.today(), Integer.valueOf(System.Label.ExpertCenter_DeadLine_Platinum_False_Inbound_Default), holidays);
                                }
                            }
                        }
                        
                        
                        //Modified By - Mahendra Swarnkar - CR-20160803-10082 - 08/23/2016 - Populating Deadline field value for Syndicated services record types - Starts from here
                    }
                }
                //Modified By - Mahendra Swarnkar- CR-20160609-9913 -passes the company holidays as an argument in the AddBusinessDays method and extnding the deadline functionality for expert center and Talent Development Case record types - 7/7/2016 -Ends here
            }
            
            //Setting flag value to true
            IS_UPDATE_HAPPENS_ON_INSERT_EVENT = true;
        }
        //Upto Here
        
        //Added By - Abhinav Sharma - 11/26/2015 - CR-20151118-9394
        //Start from here         
        //Apply this logic only to the record type Syndicated Services.
        //a) On Case record(s) insert:-
        //If Status = Tentative AND "Date of Presentation" is having non-null value with it.
        //then populate " Hold Expires" field with a value 10 business days from today.
        //b) On Case record(s) update:-
        //If the "Date of Presentation" field is updated while the Status=Tentative, the expiration date should also 
        //be updated accordingly.
        //If the Status is set to anything other than Tentative, the expiration date should be cleared out.
        //Set to hold the eligible record type Ids
        Set<Id> setOfEligibleRecordTypes = new Set<Id>();
        
        //Checking for key presence in the map and then adding corresponding record type Id value in the set
        if(caseRecordTypesMap != null 
            && caseRecordTypesMap.containsKey(SYNDICATED_SERVICES_CASE_RECORD_TYPE)
            && caseRecordTypesMap.get(SYNDICATED_SERVICES_CASE_RECORD_TYPE) != null)
            setOfEligibleRecordTypes.add(caseRecordTypesMap.get(SYNDICATED_SERVICES_CASE_RECORD_TYPE));
        
        //Checking set for size value
        if(setOfEligibleRecordTypes.size() > 0) {
            
            //Loop through case records
            for(Case ca : newCases) {
                
                //Check for record type SYNDICATED SERVICES on case 
                if(ca.RecordTypeId != null && setOfEligibleRecordTypes.contains(ca.RecordTypeId)) {
                    
                    //Check for case status to tentative
                    if(String.isNotBlank(ca.Status) && ca.Status == CASE_STATUS_TENTATIVE) {
                        
                        //Insert OR Update use case
                        if(oldMapCases == null
                            || 
                            (
                                oldMapCases != null 
                                && 
                                (ca.Date_of_Presentation__c != oldMapCases.get(ca.Id).Date_of_Presentation__c
                                 ||
                                 ca.Hold_Expires__c != oldMapCases.get(ca.Id).Hold_Expires__c
                                 ||
                                 ca.Status != oldMapCases.get(ca.Id).Status
                                )
                            ) 
                        ) {
                            
                            //Check for null for Date of presentation
                            //Populate the Hold Expire field value on case
                            if(ca.Date_of_Presentation__c != null)
                                //Modified By - Mahendra Swarnkar- CR-20160609-9913 -passes the company holidays as an argument in the AddBusinessDays method - 7/7/2016 -Starts from here
                                ca.Hold_Expires__c = Util.AddBusinessDays(System.today(), 10, holidays);
                                //Modified By - Mahendra Swarnkar- CR-20160609-9913 -passes the company holidays as an argument in the AddBusinessDays method - 7/7/2016 -Ends here
                            else
                                ca.Hold_Expires__c = null;
                           
                        }
                    } else {
                        ca.Hold_Expires__c = null;
                    }
                }
            }
        }
        //Upto here
        
        //Added By - Abhinav Sharma - 03/31/2016 - CR-20160224-9632
        //Start from here        
        //This code will only execute in the update use cases
        if(oldMapCases != null && !IS_ALREADY_EXECUTED_ONCE && !IS_UPDATE_HAPPENS_ON_INSERT_EVENT) {
            
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
                
                //Loop through case records
                for(Case cse : newCases) {
                    
                    //Checking record for eligibilty and throwing an error accordingly
                    if(cse.RecordTypeId != null 
                        && mapRecordTypes.containsKey(cse.RecordTypeId)
                        && mapRecordTypes.get(cse.RecordTypeId) != null
                        && (mapRecordTypes.get(cse.RecordTypeId) == Constants.RECORD_TYPE_CASE_PT_DATA_LOAD
                            || mapRecordTypes.get(cse.RecordTypeId) == Constants.RECORD_TYPE_CASE_PT_SUPPORT_REQUEST)
                        && cse.Button_Used__c == false
                        && (
                            (
                                oldMapCases.get(cse.Id).Status == System.Label.CASE_NEW_STATUS_PT_SUPPORT_REQUEST
                                &&
                                cse.Status != oldMapCases.get(cse.Id).Status
                            )
                            || (cse.OwnerId != oldMapCases.get(cse.Id).OwnerId)
                            || (cse.Tier_I_Support_Analyst__c != oldMapCases.get(cse.Id).Tier_I_Support_Analyst__c)
                        )
                    ) {
                        cse.addError(System.Label.ERROR_CASE_DIRECT_FIELDS_CHANGES);                    
                    } 
                    
                    if(cse.Button_Used__c == true)
                        cse.Button_Used__c = false; 
                    
                }
            } 
        }
        //Upto Here
        
        //Added By -Mahedra Swarnkar - 07/05/2016 - CR-20160229-9651 - Starts from here
        //Method Call to populate the Case fields on before event
        populateCaseFields(newCases, oldMapCases);
        //Added By -Mahedra Swarnkar - 07/05/2016 - CR-20160229-9651 - Ends here
        
        //Calling method to validate case deadline and Populate #Business Days to Deadline
        validateAndPopulateCaseData(newCases, oldMapCases);
        
        //Added By - Mahendra Swarnkar- CR-20160609-9913 - 7/12/2016
        //Starts from here
        //Loop through new case records for porforming validation over them
        for(Case cs : newCases) {
            
            //Checking if case is of expert center/international record type
            if(
                (
                    caseRecordTypesMap.containsKey(EXPERT_CENTER_CASE_RECORD_TYPE)
                    && caseRecordTypesMap.get(EXPERT_CENTER_CASE_RECORD_TYPE) != null 
                    && cs.RecordTypeId == caseRecordTypesMap.get(EXPERT_CENTER_CASE_RECORD_TYPE)
                )
                ||
                (
                    caseRecordTypesMap.containsKey(INTERNATIONAL_CASE_RECORD_TYPE)
                    && caseRecordTypesMap.get(INTERNATIONAL_CASE_RECORD_TYPE) != null 
                    && cs.RecordTypeId == caseRecordTypesMap.get(INTERNATIONAL_CASE_RECORD_TYPE)
                )
            ) {
                
                //Checking for the conditions when the deadline field based validation logic 
                //will bypass for expert center/international cases
                if(cs.AccountId != null) {
                
                    //Bypass the valiation logic if parent institution is of "Platinum Services" type
                    if(mapAccounts != null 
                        && mapAccounts.size() > 0 
                        && mapAccounts.containsKey(cs.AccountId)
                        && mapAccounts.get(cs.AccountId) != null
                        && mapAccounts.get(cs.AccountId).Platinum_Services__c == true
                    )
                        continue;
                    
                } else {
                    
                    //Bypass the valiation logic if parent institution is of "Platinum Services" type
                    if(cs.ContactId != null
                        && mapContacts != null 
                        && mapContacts.size() > 0 
                        && mapContacts.containsKey(cs.ContactId)
                        && mapContacts.get(cs.ContactId) != null
                        && mapContacts.get(cs.ContactId).AccountId != null
                        && mapContacts.get(cs.ContactId).Account.Platinum_Services__c == true
                    )
                        continue; 
                }
                    
                //Checking if case is of expert center record type
                if(caseRecordTypesMap.containsKey(EXPERT_CENTER_CASE_RECORD_TYPE)
                    && caseRecordTypesMap.get(EXPERT_CENTER_CASE_RECORD_TYPE) != null 
                    && cs.RecordTypeId == caseRecordTypesMap.get(EXPERT_CENTER_CASE_RECORD_TYPE)
                ) {
                    
                    //Deadline_Reason_Reqd_for_Member_Priority
                    if (
                        cs.origin == System.Label.ORIGIN_MEMBER_PRIORITY 
                        && String.isBlank(cs.Deadline_Reason__c)
                        && cs.Num_Business_Days_to_Deadline__c < Integer.valueOf(System.Label.DAYS_Deadline_Reason_Reqd_for_Member_Priority)
                    )
                        cs.addError(System.Label.ERROR_Deadline_Reason_Reqd_for_Member_Priority);
                
                }    
                
                //Deadline_Reason_required
                if (
                    cs.origin != System.Label.ORIGIN_MEMBER_PRIORITY
                    && String.isBlank(cs.Deadline_Reason__c)
                    && cs.Num_Business_Days_to_Deadline__c < Integer.valueOf(System.Label.DAYS_Deadline_Reason_required)
                )
                    cs.addError(System.Label.ERROR_Deadline_Reason_required);
            } 
        }
        //Upto here
        
        //Modified By - Mahendra Swarnkar - CR-20160803-10082 - 08/23/2016
        //Populating Priority field for Expert center case record type
        //Starts from here
        //Loop through new case records
        for(Case cas : newCases) {
            
            // Check for expert center record type
            if(caseRecordTypesMap.containsKey(EXPERT_CENTER_CASE_RECORD_TYPE)
                && caseRecordTypesMap.get(EXPERT_CENTER_CASE_RECORD_TYPE) != null 
                && cas.RecordTypeId == caseRecordTypesMap.get(EXPERT_CENTER_CASE_RECORD_TYPE)
            ) {
                //Check for platinum services on the related institution/Account record
                if(
                    (cas.AccountId != null
                         && mapAccounts != null 
                         && mapAccounts.size() > 0 
                         && mapAccounts.containsKey(cas.AccountId)
                         && mapAccounts.get(cas.AccountId) != null
                         && mapAccounts.get(cas.AccountId).Platinum_Services__c == true
                    )
                    || 
                    (cas.ContactId != null
                         && mapContacts != null 
                         && mapContacts.size() > 0 
                         && mapContacts.containsKey(cas.ContactId)
                         && mapContacts.get(cas.ContactId) != null
                         && mapContacts.get(cas.ContactId).AccountId != null
                         && mapContacts.get(cas.ContactId).Account.Platinum_Services__c == true
                    )
                ){
                    //Check if the no of business days to deadline is less than 3 business days 
                    //then set Case priority as urgent else standard
                    if(cas.Num_Business_Days_to_Deadline__c != null
                        && cas.Num_Business_Days_to_Deadline__c < Integer.valueOf(System.Label.ExpertCenter_NoOfBusinessDaysToDeadLine_Priorty_Platinum_True)) { 
                        
                        //Populating the priority as urgent
                        cas.Priority = System.Label.CASE_PRIORITY_URGENT_TYPE;
                        
                    } else {
                        cas.Priority = System.Label.CASE_PRIORITY_STANDARD_TYPE;
                    }
                    
                    if(cas.Priority == System.Label.CASE_PRIORITY_URGENT_TYPE && String.isBlank(cas.Deadline_Reason__c)){
                        cas.addError(System.Label.ERROR_Deadline_Reason_Reqd_for_Platinum_Type_ExpertCenter_Case);
                    }
                }
                //If platinum services is false on the related Institution record then
                else {
                    
                    //Check for Case requested from ie. if origin of Case request is from Member Priority
                    if(String.isNotBlank(cas.Origin) 
                        && cas.Origin == System.Label.ORIGIN_MEMBER_PRIORITY) {
                        
                        //Check if the no of business days to deadline is less than 7 business days then set Case priority as urgent else standard
                        if(cas.Num_Business_Days_to_Deadline__c != null
                            && cas.Num_Business_Days_to_Deadline__c < Integer.valueOf(System.Label.ExpertCenter_NoOfBusinessDaysToDeadLine_Priorty_MemberPriority)) { 
                            
                            //Populating the priority as urgent
                            cas.Priority = System.Label.CASE_PRIORITY_URGENT_TYPE;
                        }
                        else {
                            cas.Priority = System.Label.CASE_PRIORITY_STANDARD_TYPE;
                        }
                    }
                    
                    //Check for Case requeste is a Inbound Request ie. if origin of request is not Member Priority
                    else {
                        
                        //Check if the no of business days to deadline is less than 5 business days then set Case priority as urgent else standard
                        if(cas.Num_Business_Days_to_Deadline__c != null
                            && cas.Num_Business_Days_to_Deadline__c < Integer.valueOf(System.Label.ExpertCenter_NoOfBusinessDaysToDeadLine_Priorty_Inbound)) { 
                        
                            //Populating the priority as urgent
                            cas.Priority = System.Label.CASE_PRIORITY_URGENT_TYPE;
                        }
                        else {
                            cas.Priority = System.Label.CASE_PRIORITY_STANDARD_TYPE;
                        }
                    }
                }
            }
        }
        //Modified By - Mahendra Swarnkar - CR-20160803-10082 - 08/23/2016 - 
        //Populating Priority field for Expert center case record type - Ends here
    }
    
    //Validate case deadline and Populate #Business Days to Deadline
    public static void validateAndPopulateCaseData(List<Case> newCases, Map<Id, Case> mapOldCases) {
        
        //Get all Blackout Days
        List<Case_Blackout_Days__c> listCaseBlackoutDays = [Select Id, Type__c, Blackout_Begin_Date__c, Blackout_End_Date__c, User__c from Case_Blackout_Days__c
                                                                where Blackout_Begin_Date__c != null 
                                                                AND Blackout_End_Date__c != null];
        
        //Added by Ajit Surana - - 05/24/2014 - CR-20140512-5440
        //Set to hold Record Type Ids
        Set<Id> setRTypeIds = new Set<Id>();
       
        //Fetch Expert Center record type
        for(RecordType rec : [Select Id from RecordType 
                              where (DeveloperName = 'Expert_Center' OR DeveloperName = 'International') 
                              AND SObjectType = 'Case' AND IsActive = true]){
            setRTypeIds.add(rec.Id);
        }
        
        //Check if record type exists
        if(setRTypeIds.size() == 0)
            return;
        
        //Universal start date
        Date universalStartDate = date.newInstance(0001, 1, 1); 
                                                                
        //Loop through the case records
        for(Case caseObj : newCases) {
            
            //Check if case deadline doesn't fall during blackout
            if(setRTypeIds.contains(caseObj.RecordTypeId) && caseObj.Deadline__c != null 
                && (mapOldCases == null || caseObj.Deadline__c != mapOldCases.get(caseObj.Id).Deadline__c)) {
                
                //Variable to hold the created date
                Date createdDate = Date.today();
                
                if(caseObj.CreatedDate != null)
                    createdDate = caseObj.CreatedDate.date();
                    
                //Find day number of start date
                Integer startDay = Math.mod(universalStartDate.daysBetween(createdDate), 7);
                
                //Find day number of start date
                Integer endDay = Math.mod(universalStartDate.daysBetween(caseObj.Deadline__c), 7);
                
                //Days between Start date and end Date
                Integer ageInDays = createdDate.daysBetween(caseObj.Deadline__c);
                
                //variable to hold the age in hours
                Integer daysOfDeadline;
                
                //Skip Weekends
                if(createdDate == caseObj.Deadline__c) {
                    
                    //deadline is on the same day
                    daysOfDeadline = ageInDays;
                } else if(startDay > endDay) {
                    
                    //Aging Hours
                    daysOfDeadline = ageInDays - (2*((ageInDays+7)/7));
                } else {
                    
                    //Aging Hours
                    daysOfDeadline = ageInDays - (2*(ageInDays/7));
                }
                        
                //Loop through the blackout days
                for(Case_Blackout_Days__c cBD : listCaseBlackoutDays) {
                    //Check is deadline falls during Black out days
                    if(cBD.Blackout_Begin_Date__c <= caseObj.Deadline__c && cBD.Blackout_End_Date__c >= caseObj.Deadline__c
                        && (cBD.User__c == caseObj.OwnerId || cBD.User__c == null)) {
                        //V_1.1 - Modified By Abhinav Sharma - 05/21/2014 - CR-20140108-4238
                        //Throw exception
                        caseObj.addError('Selected deadline date is conflicting with some Case Blackout Days records. To see the records, Please ' + '<a href="" onclick=\"window.open(\'/apex/Blackout_Records_For_Case?deadLine=' + caseObj.Deadline__c + '&ownerId=' + caseObj.ownerId + '&inline=1\', \'Search\',\'dialogWidth:580px;dialogHeight:400px; dialogLeft:200px; dialogTop:200px; center:1; resizable: no;\');return false;\">Click Here</a>', false);
                        //throw new CustomException('Selected deadline date is conflicting with some Case Blackout Days records. To see the records, Please ' + '<a href="" onclick=\"window.open(\'/apex/Blackout_Records_For_Case?deadLine=' + caseObj.Deadline__c + '&ownerId=' + caseObj.ownerId + '&inline=1\', \'Search\',\'dialogWidth:580px;dialogHeight:400px; dialogLeft:200px; dialogTop:200px; center:1; resizable: no;\');return false;\">Click Here</a>');
                    
                    } else {
                        //Check for the blackout days
                        if(cBD.Blackout_Begin_Date__c >= createdDate && cBD.Blackout_End_Date__c <= caseObj.Deadline__c) {
                            
                            //Black out start date
                            Integer blackOutStartDay = Math.mod(universalStartDate.daysBetween(cBD.Blackout_Begin_Date__c), 7);
                            
                            //Find day number of start date
                            Integer blackOutEndDay = Math.mod(universalStartDate.daysBetween(cBD.Blackout_End_Date__c), 7);
                            
                            //Remove Weekends from blackout days and this has already been removed from above calculation
                            //Days between Start date and end Date
                            Integer blackOutAgeInDays = cBD.Blackout_Begin_Date__c.daysBetween(cBD.Blackout_End_Date__c);
                            
                            //variable to hold the age in hours
                            Integer daysOfBO;
            
                            //Skip Weekends
                            if(cBD.Blackout_Begin_Date__c == cBD.Blackout_End_Date__c) {
                                
                                //deadline is on the same day
                                daysOfBO = blackOutAgeInDays;
                            } else if(blackOutStartDay > blackOutEndDay) {
                                
                                //Aging days
                                daysOfBO = blackOutAgeInDays - (2*((blackOutAgeInDays+7)/7));
                            } else {
                                
                                //Aging Days
                                daysOfBO = blackOutAgeInDays - (2*(blackOutAgeInDays/7));
                            }
                                        
                            //Subtract blackoutDuration from daysOfDeadline
                            if(daysOfBO != null)
                                daysOfBO += 1;
                            daysOfDeadline = daysOfDeadline - daysOfBO;
                        }
                    }   
                }
                
                //Set blackout days
                if(daysOfDeadline != null)
                    daysOfDeadline += 1;
                
                //Check if it was saturday
                if(endDay == 0)
                    daysOfDeadline += 1;
                
                caseObj.Num_Business_Days_to_Deadline__c = daysOfDeadline;
            }       
        }
    }
    
    
    /**
     * 
     * @description: get the record type ids that are available for sync
     * 
     **/
    public static set<Id> syncRecordTypeIds { get; set; }
    public static set<Id> getSyncRecordTypeIds(string objectName) {
        if (syncRecordTypeIds == null) {
            syncRecordTypeIds = new set<Id>();
            set<string> rtDevNameSet = new set<string>();
            set<string> objNameSet = new set<string>();
            for (Sync_Field__c s : Constants.SYNC_FIELDS_LIST) rtDevNameSet.add(s.Source_Record_Type_Developer_Name__c);
            if (rtDevNameSet.size() > 0) {
                map<Id, RecordType> syncRecordTypeMap = new map<Id, RecordType>([SELECT Id FROM RecordType 
                                                                                 WHERE DeveloperName IN :rtDevNameSet 
                                                                                 AND SobjectType = :objectName 
                                                                                 AND IsActive = true]);
                syncRecordTypeIds = syncRecordTypeMap.keySet();
            }
        }
        return syncRecordTypeIds;
    }
    
    //Determine if a member support record needs to be created or synchronized.  CR-4283
    public static void syncCaseToMemberSupport(list<Case> newCases, map<Id, Case> mapOldCases) {
        
        list<Site_Issue__c> memberSupportToUpsert = new list<Site_Issue__c>();
        set<Id> memberSupportIdSet = new set<Id>();
        
        //Get a map of related member support records
        for (Case newCase : newCases) {
            if (newCase.Member_Support_Ticket__c != null) memberSupportIdSet.add(newCase.Member_Support_Ticket__c);
        }
        map<Id, Site_Issue__c> memberSupportMap = new map<Id, Site_Issue__c>([SELECT Id, Site_Issue_Short_Description__c, Case_Number__c,
                                                  Status__c, Tier_I_Support_Analyst__c, Site_Issue_Priority__c, Interaction_Type__c, 
                                                  Support_Category__c, Reported_By__c, Crimson_Site_Issue_Description__c, Created_from_Case__c,
                                                  Project__c, Browser__c, Browser_Version__c, Tier__c, Steps_to_Reproduce__c,
                                                  Current_Results__c, Expected_Results__c, Visible_In_Portal__c, PHI__c,
                                                  First_Comment_Date_Time__c
                                                  FROM Site_Issue__c
                                                  WHERE Id IN :memberSupportIdSet]);
        
        //Iterate over each case to determine if a member support record sync is necessary
        for (Case newCase : newCases) {
            
            if (getSyncRecordTypeIds('Case').contains(newCase.recordTypeId)) {
                
                //Get the old case
                Case oldCase;
                if (mapOldCases != null) oldCase = mapOldCases.get(newCase.Id);
                
                Site_Issue__c memberSupport;
                
                //If this is an update and the member support record exists in our map, get the existing member support record
                if (newCase.Member_Support_Ticket__c != null && memberSupportMap.containsKey(newCase.Member_Support_Ticket__c)) {
                    memberSupport = memberSupportMap.get(newCase.Member_Support_Ticket__c);
                }
                else {
                    memberSupport = new Site_Issue__c(RecordTypeId = MemberSupportTriggerUtilities.getMemSupportRTID(newCase.RecordTypeId));
                }
                
                //If certain case fields were modified, and the member support record is in Tier I, mirror changes to related member support record
                if (recordNeedsSynced((sObject) newCase, (sObject) oldCase)) 
                {
                    
                    //Populate case field values to the member support record
                    memberSupport = (Site_Issue__c) populateSourceFieldsToTarget((sObject) oldCase, (sObject) newCase, (sObject) memberSupport);
                    
                    //if the new Case is a PT Support Ticket with an Origin of 'Email' and Web Email is Blank
                    if (newCase.Origin == 'Email' && (newCase.SuppliedEmail != null && (newCase.RecordTypeId == Constants.RECORD_TYPE_ID_CASE_PT_SUPPORT))) {
                        
                        memberSupport.Visible_In_Portal__c = True;
                        memberSupport.Tier__c = 'Tier I';
                        memberSupport.Interaction_Type__c = 'Email to Case';
                        memberSupport.Site_Issue_Priority__c = 'Normal';
                    }
                    
                    //if this is a new member support record, we need to insert immediately so we can link it back to the case
                    if (memberSupport.Id == null) {
                        Util.BypassAllTriggers = true;
                            insert memberSupport;
                        Util.BypassAllTriggers = false;
                        
                        newCase.Member_Support_Ticket__c = memberSupport.Id;
                    }
                    
                    else {
                        
                        //if it is an update, add the updated memberSupport record to the upsert list
                        memberSupportToUpsert.add(memberSupport);
                    }
                    //Added By - Abhinav Sharma - 08/30/2016 - CR-20160114-9520
                    //Start from here
                    //Tier I Support Analyst
                    if(newCase.Tier_I_Support_Analyst__c != null) {
                        
                        User usr = CaseController.retrieveLoggedInUserDetails(newCase.Tier_I_Support_Analyst__c);
                        if(usr != null) {
                            memberSupport.Tier_I_Support_Analyst__c = usr.FirstName + ' ' + usr.LastName;    
                        }
                    }
                    
                    //Get all record types on case object
                    Map<String, Id> caseRecordTypesMap = Util.recordtypemap(Constants.CASE_OBJECT);
                    
                    //Execute this code logic only for "PT Support Request" record type of Case object
                    if(caseRecordTypesMap.containsKey(Constants.RECORD_TYPE_CASE_PT_SUPPORT_REQUEST)
                        && caseRecordTypesMap.get(Constants.RECORD_TYPE_CASE_PT_SUPPORT_REQUEST) != null 
                        && newCase.RecordTypeId == caseRecordTypesMap.get(Constants.RECORD_TYPE_CASE_PT_SUPPORT_REQUEST)) {
                            
                        //List to hold the all company holidays
                        List<Case_Blackout_Days__c> holidays = Util.LIST_OF_COMPANY_HOLIDAYS;    
                        
                        //Populate Elapsed: Open to Close (Hours) on Member support
                        if(newCase.CreatedDate != null && newCase.ClosedDate != null)
                            memberSupport.Elapsed_Open_to_Close_Hours__c = (Util.businessHoursForStartAndEndDate(newCase.CreatedDate, newCase.ClosedDate, holidays))/60;
                        else
                            memberSupport.Elapsed_Open_to_Close_Hours__c = null;
                            
                    }
                    //Upto here
                }
            }
        }
        
        if (memberSupportToUpsert.size() > 0) {
            Util.BypassAllTriggers = true;
            string errorMsg;
            
            try {
                upsert memberSupportToUpsert;
            }
            catch(DMLException ex) {
                errorMsg = ex.getDMLMessage(0);
            }
            catch(Exception ex) {
                errorMsg = ex.getMessage() + ex.getStackTraceString();
            }
            
            if (errorMsg != null && trigger.isExecuting) {
                //if we are inside a trigger, return a user-friendly error message to the page
                if (trigger.IsExecuting) newCases[0].addError(errorMsg);
            }
            else if (errorMsg != null && !trigger.isExecuting) {
                throw new customException(errorMsg);
            }
            
            Util.BypassAllTriggers = false;
        }
    }
    
    //Populate the targetRecord with the corresponding sourceRecord's field values and return the targetObject.  CR-4283
    public static sObject populateSourceFieldsToTarget(sObject sourceObj_Old, sObject sourceObj, sObject targetObj) {
        
        //Get the list of sync fields
        list<Sync_Field__c> syncFieldList = Constants.SYNC_FIELDS_LIST;
        
        //Get the source/target sObject types
        string sourceObjAPIName = sourceObj.getSObjectType().getDescribe().getName();
        string targetObjAPIName = targetObj.getSObjectType().getDescribe().getName();
        
        //Get the Source's record type developer name
        string sourceObjRTDevName;
        try {
            
            sourceObjRTDevName = [SELECT Id, DeveloperName FROM RecordType WHERE Id = :(string)sourceObj.get('RecordTypeId')].DeveloperName;
        }
        catch(Exception ex) {
            
            throw new customException(ex.getMessage() + '  Stack:' + ex.getStackTraceString());
        }
        
        boolean isNewSourceObj = (sourceObj_Old == null || sourceObj_Old.get('Id') == null);
        boolean isNewTargetObj = (targetObj.get('Id') == null);
        
        //Map the source fields to target record
        for (Sync_Field__c syncField : syncFieldList) {
            
            if (syncField.Source_Object_API_Name__c == sourceObjAPIName
                && syncField.Target_Object_API_Name__c == targetObjAPIName
                && (isNewSourceObj
                    || isNewTargetObj
                    || sourceObj_Old.get(syncField.Source_Field_API_Name__c) != sourceObj.get(syncField.Source_Field_API_Name__c))
                && (syncField.Source_Record_Type_Developer_Name__c == sourceObjRTDevName))
            {
                system.debug('@@@syncField.Source_Field_API_Name__c:' + syncField.Source_Field_API_Name__c + '-' + sourceObjRTDevName);
                //Sometimes the source value will need to be converted
                //For instance, the status '01-New' from Case is converted to '01 - Issue Reported' for Member Support
                object sourceFieldValue = convertSourceFieldValue(syncField.Source_Object_API_Name__c,
                                                           syncField.Target_Object_API_Name__c,
                                                           syncField.Source_Field_API_Name__c,
                                                           sourceObj);
                
                //if the field being synched is a boolean type, replace null values w/false (this is to resolve a SF field type error)
                if (sourceFieldValue == null) 
                {
                    if (Schema.DisplayType.Boolean == targetObj.getSObjectType().getDescribe().Fields.getMap().get(syncField.Target_Field_API_Name__c).getDescribe().getType()) {
                        sourceFieldValue = false;
                    }
                }
                
                
                targetObj.put(syncField.Target_Field_API_Name__c, sourceFieldValue);
            }
        }
        
        return targetObj;
    }
    
    private static object convertSourceFieldValue(string sourceObjType, string targetObjType, string sourceFieldAPIName, sobject sourceObj) {
        
        string sourceRecordTypeId = (string) sourceObj.get('RecordTypeId');
        
        string sourceFieldValue;
        object sourceFieldValue_object;
        
        try {
            //CR-20160113-9507 if this is an instance of a string, convert it and continue processing
            if (sourceObj.get(sourceFieldAPIName) instanceOf string)
                sourceFieldValue = (string) sourceObj.get(sourceFieldAPIName);
            else { //CR-20160113-9507 if it is not a string, leave it as an object and return if not auto-populated via the custom process below
                sourceFieldValue_object = sourceObj.get(sourceFieldAPIName);
                system.debug('@@sourceFieldValue_object:'+ sourceFieldValue_object);
            }
        }
        catch(exception ex) {
            system.debug('Error Converting value to string:' + ex + '  sourceFieldAPIName:' + sourceFieldAPIName + '---VALUE:' + sourceObj.get(sourceFieldAPIName));
        }
        
        if (sourceObjType.equalsIgnoreCase('Case') 
        && targetObjType.equalsIgnoreCase('Site_Issue__c') 
        && sourceFieldAPIName.equalsIgnoreCase('Status'))
        {
            
            if (sourceRecordTypeId == Constants.RECORD_TYPE_ID_CASE_PT_SUPPORT
             && caseToMemSupportStatus_SupportRT_Map.containsKey(sourceFieldValue))
            {
                sourceFieldValue = caseToMemSupportStatus_SupportRT_Map.get(sourceFieldValue);
            }
            else if (sourceRecordTypeId == Constants.RECORD_TYPE_ID_CASE_PT_DATA_LOAD
                  && caseToMemSupportStatus_DataLoadRT_Map.containsKey(sourceFieldValue))
            {
                sourceFieldValue = caseToMemSupportStatus_DataLoadRT_Map.get(sourceFieldValue);
            }
        }
        else if (sourceObjType.equalsIgnoreCase('Site_Issue__c') 
        && targetObjType.equalsIgnoreCase('Case') 
        && sourceFieldAPIName.equalsIgnoreCase('Status__c'))
        {
            
            if (sourceRecordTypeId == Constants.RECORD_TYPE_ID_SITE_ISSUE_CCA_SUPPORT_REQUEST
             && memSupportToCaseStatus_SupportRT_Map.containsKey(sourceFieldValue))
            {
                
                sourceFieldValue = memSupportToCaseStatus_SupportRT_Map.get(sourceFieldValue);
            }
            else if (sourceRecordTypeId == Constants.RECORD_TYPE_ID_SITE_ISSUE_CCA_DATA_LOAD
                  && memSupportToCaseStatus_DataLoadRT_Map.containsKey(sourceFieldValue))
            {
                
                sourceFieldValue = memSupportToCaseStatus_DataLoadRT_Map.get(sourceFieldValue);
            }
            
        }
        else if (sourceObjType.equalsIgnoreCase('Site_Issue__c') 
        && targetObjType.equalsIgnoreCase('Case') 
        && sourceFieldAPIName.equalsIgnoreCase('Site_Issue_Priority__c'))
        {
            
            if (memSupportToCasePriority_Map.containsKey(sourceFieldValue))
            {
                sourceFieldValue = memSupportToCasePriority_Map.get(sourceFieldValue);
            }
        }
        else if (sourceObjType.equalsIgnoreCase('Case') 
        && targetObjType.equalsIgnoreCase('Site_Issue__c') 
        && sourceFieldAPIName.equalsIgnoreCase('Priority'))
        {
            
            if (caseToMemSupportPriority_Map.containsKey(sourceFieldValue))
            {
                sourceFieldValue = caseToMemSupportPriority_Map.get(sourceFieldValue);
            }
        }
        else if (sourceObjType.equalsIgnoreCase('Site_Issue__c') 
        && targetObjType.equalsIgnoreCase('Case') 
        && (  sourceFieldAPIName.equalsIgnoreCase('Data_Load_Period_Begin__c') 
           || sourceFieldAPIName.equalsIgnoreCase('Data_Load_Period_End__c')))
        {
            
            date dBegin = (date) sourceObj.get('Data_Load_Period_Begin__c');
            date dEnd = (date) sourceObj.get('Data_Load_Period_End__c');
            
            if (dBegin != null && dEnd != null) {
                
                //CCA Dataload tickets map Site Issue DL dates to the Case Description
                sourceFieldValue = 'Data Load for '
                                   + dBegin.format()
                                   + ' to '
                                   + dEnd.format();
            }
        }
        
        if (sourceFieldValue != null) 
            sourceFieldValue_object = (object) sourceFieldValue;
        return sourceFieldValue_object;
    }
    
    //Check the fields that sync from Case -> MS and determine if the related MS record should be updated.  CR-4283
    public static boolean recordNeedsSynced(sObject newSourceObj, sObject oldSourceObj) {
        
        boolean isChanged = false;
        
        //Get the list of sync fields
        list<Sync_Field__c> syncFieldList = Constants.SYNC_FIELDS_LIST;
        
        //Get the source sObject types
        string sourceObjAPIName = newSourceObj.getSObjectType().getDescribe().getName();
        
        //Get the Source's record type developer name
        string sourceObjRTDevName;
        try {
            sourceObjRTDevName = [SELECT Id, DeveloperName FROM RecordType WHERE Id = :(string)newSourceObj.get('RecordTypeId')].DeveloperName;
        }
        catch(Exception ex) {
            system.debug('@@exception:' + ex);
        }
        
        //Go through each field value via dynamic dml and see if there was a change
        if (oldSourceObj != null) {
            
            for (Sync_Field__c syncField : syncFieldList) {
                
                if (syncField.Source_Object_API_Name__c == sourceObjAPIName
                    && syncField.Source_Record_Type_Developer_Name__c == sourceObjRTDevName) 
                {
                    
                    object newVal = convertSourceFieldValue(syncField.Source_Object_API_Name__c,
                                                                             syncField.Target_Object_API_Name__c,
                                                                             syncField.Source_Field_API_Name__c,
                                                                             newSourceObj);
                    object oldVal = convertSourceFieldValue(syncField.Source_Object_API_Name__c,
                                                                             syncField.Target_Object_API_Name__c,
                                                                             syncField.Source_Field_API_Name__c,
                                                                             oldSourceObj);
                    if (oldVal != newVal) {
                        system.debug('@@oldVal:' + oldVal + '  NewVal:' + newVal);
                        isChanged = true;
                        break;
                    }
                }
            }
        }
        else {
            isChanged = true;
        }
        
        return isChanged;
    }
    
    //Map Case Status => Member Support status equivalent for the Crimson Support Record Type
    public static map<string, string> caseToMemSupportStatus_SupportRT_Map {
        get {
            if (caseToMemSupportStatus_SupportRT_Map == null) {
                caseToMemSupportStatus_SupportRT_Map = new map<string, string> {
                    '01-New' => '01- Issue Reported',
                    '10-In Progress' => '02- Working on Issue',
                    '20-Response Needed' => '03.1 - Member Input Required',
                    '80-Solution Provided' => '05 - Issue Resolved - Request to Close Ticket',
                    '90-Closed' => '06 - Issue Resolved - Ticket Closed'
                };
            }
            return caseToMemSupportStatus_SupportRT_Map;
        }
        set;
    }
    
    //Map Member Support Status => Case status equivalent
    public static map<string, string> memSupportToCaseStatus_SupportRT_Map {
        get {
            if (memSupportToCaseStatus_SupportRT_Map == null) {
                memSupportToCaseStatus_SupportRT_Map = new map<string, string> {
                    '01- Issue Reported' => '01-New',
                    '01 - Awaiting Files' => '20-Response Needed',
                    '01- Waiting for Files' => '20-Response Needed',
                    '02 - Awaiting BA response' => '10-In Progress',
                    '02- Working on Issue' => '10-In Progress',
                    '2.5 - Waiting on Data Analyst Response' => '10-In Progress',
                    '03 - Need more information' => '20-Response Needed',
                    '03.1 - Member Input Required' => '20-Response Needed',
                    '03.5 - Need More Information' => '20-Response Needed',
                    '04 - Issue Resolved in Test - BA Response Needed' => '10-In Progress',
                    '4.5 - Issue Resolved in Test - Dedicated Advisor Response Required' => '10-In Progress',
                    '05- Issue Resolved in Production - Request to Close Ticket' => '80-Solution Provided',
                    '05 - Issue Resolved - Request to Close Ticket' => '80-Solution Provided',
                    '05.1 - Awaiting Verification from Dedicated Advisor' => '10-In Progress',
                    '06 - Issue Resolved - Ticket Closed' => '90-Closed',
                    'X - Duplicate/Cancelled' => '90-Closed'
                };
            }
            return memSupportToCaseStatus_SupportRT_Map;
        }
        set;
    }
    
    //Map Case Status => Member Support status equivalent for the CCA Data Load Record Type
    public static map<string, string> caseToMemSupportStatus_DataLoadRT_Map {
        get {
            if (caseToMemSupportStatus_DataLoadRT_Map == null) {
                caseToMemSupportStatus_DataLoadRT_Map = new map<string, string> {
                    '01-New' => '02 - Files Received',
                    '20-Response Needed' => '01 - Awaiting Files',
                    '10-In Progress' => '04 - Diagnostics Approved',
                    '80-Solution Provided' => '09 - Migration Complete',
                    '90-Closed' => '10 - Closed, Member Notified'
                };
            }
            return caseToMemSupportStatus_DataLoadRT_Map;
        }
        set;
    }
    
    //Modified By - Ajit Surana - 11/22/2014 - CR-20140625-5930
    //Map Member Support Status => Case status equivalent
    public static map<string, string> memSupportToCaseStatus_DataLoadRT_Map {
        get {
            if (memSupportToCaseStatus_DataLoadRT_Map == null) {
                memSupportToCaseStatus_DataLoadRT_Map = new map<string, string> {
                    '01 - Awaiting Files' => '20-Response Needed',
                    '02 - Files Received' => '01-New',
                    '03 - Diagnostics Created' => '20-Response Needed',
                    '03.1 - Member Input Required' => '20-Response Needed',
                    '04 - Diagnostics Approved' => '10-In Progress',
                    '05 - In Smoke Test' => '10-In Progress',
                    '06 - In System Test' => '10-In Progress',
                    '07 - In Final QA' => '10-In Progress',
                    '08 - Ready for Migration' => '10-In Progress',
                    '09 - Migration Complete' => '80-Solution Provided',
                    '10 - Closed, Member Notified' => '90-Closed',
                    'X - Duplicate/Cancelled' => '90-Closed'
                };
            }
            return memSupportToCaseStatus_DataLoadRT_Map;
        }
        set;
    }
    
    //Map Case Priority => Member Support Priority equivalent
    public static map<string, string> caseToMemSupportPriority_Map {
        get {
            if (caseToMemSupportPriority_Map == null) {
                caseToMemSupportPriority_Map = new map<string, string> {
                    'Low' => 'Normal',
                    'Medium' => 'Normal',
                    'High' => 'High'
                };
            }
            return caseToMemSupportPriority_Map;
        }
        set;
    }
    
    //Map MS Priority => Case Priority equivalent
    public static map<string, string> memSupportToCasePriority_Map {
        get {
            if (memSupportToCasePriority_Map == null) {
                memSupportToCasePriority_Map = new map<string, string> {
                    'Normal' => 'Low',
                    'High' => 'High',
                    'Critical' => 'High'
                };
            }
            return memSupportToCasePriority_Map;
        }
        set;
    }
    
    //Modified By - Abhinav Sharma - 09/29/2016 - CR-20160916-10182
    /**
    *
    *   Description: If the Resolution Summary field is updated and Status = 'Solution Provided', post the resolution to comments
    *               This method also calls caseCommentNotify, which will send a notification email to the member.
    *
    **/
    //Modified By - Mahendra Swarnakar - 08/31/2016 - CR-20160715-10014
    public static void postResolutionToComments(list<Case> newCases, map<Id, Case> mapOldCases) {
        
        list<CaseComment> commentsToInsert = new list<CaseComment>();
        Case oldCase;
        
        //get all contacts so we can reference their name in the email that is sent
        set<Id> contactIds = new set<Id>();
        for (Case c : newCases) contactIds.add(c.ContactId);
        map<Id, Contact> contactMap = new map<Id, Contact>([SELECT Id, FirstName, LastName, Email FROM Contact WHERE Id IN :contactIds]);
        
        for (Case newCase : newCases) {
            
            if (mapOldCases != null) oldCase = mapOldCases.get(newCase.Id);
            
            if (String.isNotBlank(newCase.Status) && (newCase.Status.equalsIgnoreCase('80-Solution Provided') || newCase.Status.equalsIgnoreCase('90-Closed')) 
                && newCase.Member_Facing_Resolution_Summary__c != oldCase.Member_Facing_Resolution_Summary__c) 
            {
                
                //Added By - Abhinav Sharma - 09/29/2016 - CR-20160916-10182
                //Start from here
                if(!IS_RECURSIVE_ACTION_HAPPENS) {
                //Upto here 
                
                    string bodyText = '[Case Close Resolution]\r\n' + newCase.Member_Facing_Resolution_Summary__c;
                    CaseComment comment = new CaseComment(ParentId = newCase.Id,
                                                          CommentBody = bodyText,
                                                          isPublished = true);
                    
                    commentsToInsert.add(comment);
                
                    //caseCommentController.caseCommentNotify(newCase, comment, contactMap.get(newCase.ContactId));
                    
                    //Commented By - Abhinav Sharma - 09/29/2016 - CR-20160916-10182
                    //Start from here  
                    //Commented because "populateCaseCommentNotify" method of "CaseCommentTriggerHelper" class is 
                    //also populating this field with the same time stamp 
                    //and due to that "Crimson: Case Comment Notice to Contact" WF rule is sending recursive emails.
                    //newCase.Case_Comment_Notification__c = system.now();
                    //Upto here
                	
                    //Added By - Abhinav Sharma - 09/29/2016 - CR-20160916-10182
                	//Start from here
                    //Setting the flag value to true, in order to stop recurssion
                    IS_RECURSIVE_ACTION_HAPPENS = true;
                    //upto here
                }        
            }
        }
        
        if (commentsToInsert.size() > 0) insert commentsToInsert;
    }
    
    //Modified By - Mahendra Swarnakar - 12/02/2015 - CR-20151118-9397
    //Modified By - Abhinav Sharma - 12/01/2015 - CR-20150616-9006
    //Modified By - Ajit Surana - 11/17/2014 - CR-20141105-7992
    //Modified By - Ajit Surana - 11/16/2014 - CR-20141105-7987
    //Modified By - Ajit Surana - 09/10/2014 - CR-20140812-6973
    //Added By - Abhinav Sharma - 06/19/2014 - CR-20140417-5120
    //Validate and Populate case record fields with desired values in case when it is coming via Email to Case functionality
    //Modified By - Abhinav Sharma - 10-08-2014 - CR-20140827-7164
    //Modified By - Mahendra Swarnakar - 08/31/2016 - CR-20160715-10014
    @future (callout=false)
    public static void populateCaseFromEmailToCase(Set<Id> caseIds) {
    
        //Set to hold the origins
        Set<String> setOrigins = new Set<String>();
        setOrigins.add(Constants.CASE_ORIGIN_MEETINGS);
        setOrigins.add(Constants.CASE_ORIGIN_WEBCONFERENCES);
        setOrigins.add(Constants.CASE_ORIGIN_CONFERENCE_ROOM_REQUESTS);
        setOrigins.add(Constants.CASE_ORIGIN_TRAVEL);
        setOrigins.add(Constants.CASE_ORIGIN_VOICE_MAIL);
        setOrigins.add(Constants.CASE_ORIGIN_ADVISORY);
        setOrigins.add(Constants.CASE_ORIGIN_EAB);
        setOrigins.add(Constants.CASE_ORIGIN_ABI);
        setOrigins.add(Constants.CASE_ORIGIN_EMAIL_TO_CASE_DATA_INTEGRATIONS);
        setOrigins.add(Constants.CASE_ORIGIN_EAB_MEETINGS);
        setOrigins.add(CaseTriggerHelper.CASE_ORIGIN_WEB);
        
        //Modified By - Ajit Surana - 11/16/2014 - CR-20141105-7987 - Removed Record Type check from the query
        //Query Cases
        List<Case> newCases = [SELECT Id, Origin, RecordTypeId, Description FROM Case 
                                    WHERE Id IN: caseIds 
                                        AND Origin IN : setOrigins];
        
        //Check for the size
        if(newCases.size() == 0)
          return;
        
        //Querying Details for "Member & Employee Support" record type on Case Object
        Map<Id, RecordType> mapCaseRecordTypes = new Map<Id, RecordType>([SELECT ID, DeveloperName FROM RecordType 
                                                                          Where sObjectType =: Constants.CASE_OBJECT 
                                                                          AND IsActive = true 
                                                                          AND (
                                                                                DeveloperName =: Constants.CASE_RECORD_TYPE_MEMBER_EMPLOYEE_SUPPORT
                                                                                OR
                                                                                DeveloperName =: Constants.CASE_RECORD_TYPE_WEBHELP
                                                                          )
                                                                         ]);
        
        //Map of queues
        Map<String, Id> mapQueues = new Map<String, Id>();
        
        //Loop through Queue records
        for(QueueSobject que : [SELECT Id, queue.DeveloperName, QueueId FROM QueueSobject 
                                WHERE SobjectType =: Constants.CASE_OBJECT
                                AND queue.DeveloperName != null
                                AND (
                                    queue.DeveloperName =: Constants.QUEUE_NAME_EVENTS_MEMBER_SUPPORT
                                    OR
                                    queue.DeveloperName =: Constants.QUEUE_NAME_WEBHELP
                                )
                                ORDER By queue.DeveloperName ASC]
        ) {
            if(que.QueueId != null)
                mapQueues.put(que.queue.DeveloperName, que.QueueId);                           
        }      
                                                  
        //Proceed further only and only if record type and queue are there as specified
        if(mapCaseRecordTypes != null && mapCaseRecordTypes.values().size() > 0 
            && mapQueues != null && mapQueues.values().size() > 0) {
              
            //Loop through case records
            for(Case cas : newCases) {
                    
                //Populating case record with fields values
                cas.Status = System.Label.E2C_BY_DEFAULT_CASE_STATUS;
                
                //Strip out the html tags from the Case description field value
                cas.Description = cas.Description.replaceAll('\\<.*?\\>', '');
                
                //Added By - Ajit Surana - 11/16/2014 - CR-20141105-7987
                //Update the Owner of case if case RecordType equals Member Employee Support
                If(cas.RecordTypeId != null
                    && mapCaseRecordTypes.containsKey(cas.RecordTypeId)
                    && mapCaseRecordTypes.get(cas.RecordTypeId) != null
                    && mapCaseRecordTypes.get(cas.RecordTypeId).DeveloperName != null) {
                        
                    //Populating owner field on the case object    
                    if(mapCaseRecordTypes.get(cas.RecordTypeId).DeveloperName == Constants.CASE_RECORD_TYPE_MEMBER_EMPLOYEE_SUPPORT) {    
                        if(mapQueues.containsKey(Constants.QUEUE_NAME_EVENTS_MEMBER_SUPPORT) && mapQueues.get(Constants.QUEUE_NAME_EVENTS_MEMBER_SUPPORT) != null)
                            cas.OwnerId = mapQueues.get(Constants.QUEUE_NAME_EVENTS_MEMBER_SUPPORT);
                    }    
                    else if(mapCaseRecordTypes.get(cas.RecordTypeId).DeveloperName == Constants.CASE_RECORD_TYPE_WEBHELP) {
                        if(mapQueues.containsKey(Constants.QUEUE_NAME_WEBHELP) && mapQueues.get(Constants.QUEUE_NAME_WEBHELP) != null)
                            cas.OwnerId = mapQueues.get(Constants.QUEUE_NAME_WEBHELP);        
                    }
                }
                     
                //Checking and validating for sender's email address and then populating field values on case record
                if(cas.Origin == Constants.CASE_ORIGIN_MEETINGS)
                    cas.Type = Constants.CASE_ORIGIN_MEETINGS;
                else if(cas.Origin == Constants.CASE_ORIGIN_WEBCONFERENCES)
                    cas.Type = Constants.CASE_ORIGIN_WEBCONFERENCES;
                else if(cas.Origin == Constants.CASE_ORIGIN_CONFERENCE_ROOM_REQUESTS)
                    cas.Type = Constants.CASE_ORIGIN_CONFERENCE_ROOM_REQUESTS;
                else if(cas.Origin == Constants.CASE_ORIGIN_TRAVEL)
                    cas.Type = Constants.CASE_ORIGIN_TRAVEL;
                else if(cas.Origin == Constants.CASE_ORIGIN_VOICE_MAIL)
                    cas.Type = Constants.CASE_ORIGIN_VOICE_MAIL;
                else if(cas.Origin == Constants.CASE_ORIGIN_ADVISORY)
                    cas.Type = Constants.CASE_ORIGIN_ADVISORY;
                else if(cas.Origin == Constants.CASE_ORIGIN_EAB)
                    cas.Type = Constants.CASE_ORIGIN_EAB;
                else if(cas.Origin == Constants.CASE_ORIGIN_ABI)
                    cas.Type = Constants.CASE_ORIGIN_ABI;
                else if(cas.Origin == Constants.CASE_ORIGIN_EMAIL_TO_CASE_DATA_INTEGRATIONS)
                    cas.Type = Constants.CASE_ORIGIN_DATA_INTEGRATIONS;
                else if(cas.Origin == Constants.CASE_ORIGIN_EAB_MEETINGS)
                    cas.Type = Constants.CASE_ORIGIN_MEETINGS;
                else {}
            }
            
            //Setting back the case origin to email    
            for(Case c : newCases) {
                if(c.Origin != Constants.CASE_ORIGIN_EAB_MEETINGS 
                    && c.Origin != Constants.CASE_ORIGIN_VOICE_MAIL
                    && c.Origin != CaseTriggerHelper.CASE_ORIGIN_WEB
                  )
                    c.Origin = Constants.EMAIL;    
            }
            
            //Checking list for it size value
            if(newCases.size() > 0) {
                Util.byPassAllTriggers = true;
                update newCases;
                Util.byPassAllTriggers = false;
            }
            
            //Set to hold the case records Id values
            Set<Id> setCases = new Set<Id>();
                
            //Loop through case records and populating set with ID values    
            for(Case cs : newCases)    
                setCases.add(cs.Id);    
               
            //Calling method to delete the cases    
            if(setCases.size() > 0)
                deletedOutOutOfOfficeCases(setCases);    
        }
    }
    
    //Modified By - Abhinav Sharma - 12/01/2015 - CR-20150616-9006
    //Modified By - Abhinav Sharma - 08/06/2014 - CR-20140707-6093
    //Added By - Abhinav Sharma - 06/19/2014 - CR-20140417-5120
    //Method to deleted out the case record after insertion of it, if is of "Out of Office" type
    //Modified By - Abhinav Sharma - 10-08-2014 - CR-20140827-7164
    public static void deletedOutOutOfOfficeCases(Set<Id> setCaseIds) {
    
        //List to hold the case record going to be delete and if of "Out Of Office" type
        List<Case> casesToBeDeleted = new List<Case>();
        
        //Querying Details for "Member & Employee Support" record type on Case Object
        Map<Id, RecordType> mapCaseRecordTypes = new Map<Id, RecordType>([SELECT ID, DeveloperName FROM RecordType 
                                                                          Where sObjectType =: Constants.CASE_OBJECT 
                                                                          AND IsActive = true 
                                                                          AND (
                                                                                DeveloperName =: Constants.CASE_RECORD_TYPE_MEMBER_EMPLOYEE_SUPPORT
                                                                                OR
                                                                                DeveloperName =: Constants.CASE_RECORD_TYPE_WEBHELP
                                                                                OR
                                                                                DeveloperName =: Constants.CASE_RECORD_TYPE_ETECH_SUPPORT
                                                                          )
                                                                         ]);
                                                
        //Query for queue                                
        Map<Id, QueueSobject> mapQueues = new Map<Id, QueueSobject>();
        
        //Loop through queue list and populating it with appropriate combination of values
        for(QueueSobject qs : [SELECT Id, queue.DeveloperName, QueueId FROM QueueSobject 
                               WHERE SobjectType =: Constants.CASE_OBJECT
                               AND queue.DeveloperName != null
                               AND (
                                    queue.DeveloperName =: Constants.QUEUE_NAME_EVENTS_MEMBER_SUPPORT
                                    OR
                                    queue.DeveloperName =: Constants.QUEUE_NAME_WEBHELP
                                    OR
                                    queue.DeveloperName =: Constants.QUEUE_NAME_DATA_INTEGRATIONS
                               )
                              ]) {
            if(qs.QueueId != null)
                mapQueues.put(qs.QueueId, qs);
        }
                                            
        //Misslenious Properties
        Set<String> setoutOfOfficesStrings = Constants.SET_OOO_AND_AUTOMATIC_REPLY;
        
        //Added By - Abhinav Sharma - 10-08-2014 - CR-20140827-7164
        //Start from here
        //Set to hold the email addresses should be filtered out
        Set<String> setOfEmailsToBeFiltered = new Set<String>();
        setOfEmailsToBeFiltered.add(Constants.MAILER_DAEMON_ADVISORY_COM);
        setOfEmailsToBeFiltered.add(Constants.SPAM_FILTER_ADVISORY_COM);
        //Upto here
                                            
        //Proceed further only and only if record type and queue are there as specified
        if(mapCaseRecordTypes != null && mapCaseRecordTypes.values().size() > 0 
            && mapQueues != null && mapQueues.values().size() > 0 
            && setoutOfOfficesStrings != null && setoutOfOfficesStrings.size() > 0) {
        
            //Loop throuh case records
            for(Case c : [SELECT ID, RecordTypeId, OwnerId, Subject, Description, Origin, SuppliedEmail 
                            FROM Case WHERE ID IN : setCaseIds]) {
            
                //Boolean variable helpful in making decision about record fiteration
                Boolean isOutOfOffices = false;
            
                //Checking Case record for its Owner, Origin, Record type and then for "Out of Office" string in subject and description
                //Add it to the list going to be delete if satisfies all of the desired conditions
                if(mapCaseRecordTypes.containsKey(c.RecordTypeId)
                    && mapCaseRecordTypes.get(c.RecordTypeId) != null 
                    && mapQueues.containsKey(c.OwnerId)
                    && mapQueues.get(c.OwnerId) != null
                   && (c.Origin == Constants.EMAIL || c.Origin == Constants.CASE_ORIGIN_EAB_MEETINGS || c.Origin == Constants.CASE_ORIGIN_VOICE_MAIL || c.Origin == CaseTriggerHelper.CASE_ORIGIN_WEB)) {
                    
                    //If case record is having "Out of offices" in Subject or Body will need to be filtered out.
                    if(!String.isBlank(c.Subject)) {
                        for(String outOfOffices : setoutOfOfficesStrings) {
                            if(c.Subject.toLowerCase().trim().contains(outOfOffices))
                                isOutOfOffices = true;  
                        }  
                    }
                    
                    //Added By - Abhinav Sharma - 10-08-2014 - CR-20140827-7164
                    //Start from here
                    //If case record having filtered out emails with it them also consider it for deletion
                    if(!String.isBlank(c.SuppliedEmail)) {
                        if(setOfEmailsToBeFiltered.contains(c.SuppliedEmail.toLowerCase().trim()))
                                isOutOfOffices = true;  
                    }
                    //Upto here
                    
                    //Checking for boolean variable value and if it is true it means that record will be deleted in future
                    //Since of "Out of Offices" type
                    if(isOutOfOffices)
                        casesToBeDeleted.add(c);
                }
            }
        }
        
        //Checking list for it size value'
        if(casesToBeDeleted.size() > 0) {
            Util.byPassAllTriggers = true;
            delete casesToBeDeleted;
            Util.byPassAllTriggers = false;
        }
    }
    
    /**
     *  @description    :   Method to manage the tasks for the Syndicated Service type cases on insert and update.
     * 
     *  @args           :   List of cases, Map of Cases
     * 
     *  @return         :   void
     * 
    **/ 
    //Added By - Abhinav Sharma - CR-20141001-7574 - 10/15/2014
    public static void manageTasksForSyndicatedServiceCases(List<Case> newCases, Map<Id, Case> mapOldCases) {
        
        //Query for the record type
        List<RecordType> recordTypes = [SELECT ID FROM RecordType WHERE DeveloperName = 'Syndicated_Services' AND IsActive = true AND sObjectType = 'Case'];
        List<RecordType> tasksRecordType = [SELECT ID FROM RecordType WHERE DeveloperName = 'General' AND IsActive = true AND sObjectType = 'Task'];
        
        //Checking if record type exists or not
        if(recordTypes != null && recordTypes.size() > 0 && tasksRecordType != null && tasksRecordType.size() > 0) {
            
            //Set to hold the case records Ids
            Map<Id, Case> mapCasesForTasksInsert = new Map<Id, Case>();
            Map<string, List<Task>> mapCasesForTasksUpdate = new Map<string, List<Task>>();
            
            //List of tasks to be deleted
            List<Task> tasksToBeDeleted = new List<Task>();
          
            //Set to hold the applicable subjects for the tasks
            Set<string> setCaseSubjects = new Set<String>();
            setCaseSubjects.add('Calendars held');
            setCaseSubjects.add('Logistics outreach completed');
            setCaseSubjects.add('Presite call scheduled');
            setCaseSubjects.add('Confirmation emailed and added to calendars');
            setCaseSubjects.add('Materials sent to member');
            setCaseSubjects.add('3 day-out check-in call completed');

            //Loop through case records
            for(Case c : [SELECT ID, OwnerId, RecordTypeId, ContactId,
                            (SELECT ID,OwnerId FROM Tasks WHERE Subject IN : setCaseSubjects AND Status != 'Completed' AND Status != 'Cancelled') 
                            FROM Case WHERE ID IN : newCases AND RecordTypeId =: recordTypes[0].Id AND OwnerId != null]) {
                //Insert Case
                if(mapOldCases == null && String.valueOf(c.OwnerId).startsWith('005'))
                    mapCasesForTasksInsert.put(c.Id, c);
                
                //Update Case
                if(mapOldCases != null && c.OwnerId != mapOldCases.get(c.Id).OwnerId && String.valueOf(c.OwnerId).startsWith('005')) {

                    //Insert new tasks if not already exists
                    if(c.tasks != null && c.tasks.size() > 0) {
                        for(Task t : c.tasks) {     
                            if(mapCasesForTasksUpdate.containsKey(c.Id + '-' + c.OwnerId))
                                mapCasesForTasksUpdate.get(c.Id + '-' + c.OwnerId).add(t);
                            else
                                mapCasesForTasksUpdate.put(c.Id + '-' + c.OwnerId, new List<Task>{t}); 
                        }    
                    } else {
                        mapCasesForTasksInsert.put(c.Id, c);
                    }   
                }
                
                if(mapOldCases != null && c.OwnerId != mapOldCases.get(c.Id).OwnerId && String.valueOf(c.OwnerId).startsWith('00G')) {
                    if(c.tasks != null && c.tasks.size() > 0)
                        tasksToBeDeleted.addAll(c.tasks);
                }
            }
            
            //Checking for size of list
            if(tasksToBeDeleted.size() > 0)
                delete tasksToBeDeleted;
            
            //List to hold the task records
            List<Task> tasks = new List<Task>();
            
            //Checking for the map value
            if(mapCasesForTasksInsert.values().size() > 0) {
                
                //Loop through case records
                for(Case cas : mapCasesForTasksInsert.values()) {
                    
                    //Creating and populating task new instances with field values and then additing to the list for inertion
                    Task task_1 = new Task();
                    task_1.WhatId = cas.id;
                    task_1.OwnerId = cas.OwnerId;
                    task_1.Status = 'Not Started';
                    task_1.Priority = 'Normal';
                    task_1.RecordTypeId = tasksRecordType[0].Id; 
                    task_1.ActivityDate = System.today();
                    task_1.WhoId = cas.ContactId;
                    task_1.Subject = 'Calendars held';
                    
                    Task task_2 = new Task();
                    task_2.WhatId = cas.id;
                    task_2.OwnerId = cas.OwnerId;
                    task_2.Status = 'Not Started';
                    task_2.Priority = 'Normal';
                    task_2.RecordTypeId = tasksRecordType[0].Id; 
                    task_2.ActivityDate = System.today();
                    task_2.WhoId = cas.ContactId;
                    task_2.Subject = 'Logistics outreach completed';
                    
                    Task task_3 = new Task();
                    task_3.WhatId = cas.id;
                    task_3.OwnerId = cas.OwnerId;
                    task_3.Status = 'Not Started';
                    task_3.Priority = 'Normal';
                    task_3.RecordTypeId = tasksRecordType[0].Id; 
                    task_3.ActivityDate = System.today();
                    task_3.WhoId = cas.ContactId;
                    task_3.Subject = 'Presite call scheduled';
                    
                    Task task_4 = new Task();
                    task_4.WhatId = cas.id;
                    task_4.OwnerId = cas.OwnerId;
                    task_4.Status = 'Not Started';
                    task_4.Priority = 'Normal';
                    task_4.RecordTypeId = tasksRecordType[0].Id; 
                    task_4.ActivityDate = System.today();
                    task_4.WhoId = cas.ContactId;
                    task_4.Subject = 'Confirmation emailed and added to calendars';
                    
                    Task task_5 = new Task();
                    task_5.WhatId = cas.id;
                    task_5.OwnerId = cas.OwnerId;
                    task_5.Status = 'Not Started';
                    task_5.Priority = 'Normal';
                    task_5.RecordTypeId = tasksRecordType[0].Id; 
                    task_5.ActivityDate = System.today();
                    task_5.WhoId = cas.ContactId;
                    task_5.Subject = 'Materials sent to member';
                    
                    Task task_6 = new Task();
                    task_6.WhatId = cas.id;
                    task_6.OwnerId = cas.OwnerId;
                    task_6.Status = 'Not Started';
                    task_6.Priority = 'Normal';
                    task_6.RecordTypeId = tasksRecordType[0].Id; 
                    task_6.ActivityDate = System.today();
                    task_6.WhoId = cas.ContactId;
                    task_6.Subject = '3 day-out check-in call completed';
                    
                    //Adding task records to the list
                    tasks.add(task_1); tasks.add(task_2); tasks.add(task_3);
                    tasks.add(task_4); tasks.add(task_5); tasks.add(task_6);
                }
                
                //Checking for the size value
                if(tasks.size() > 0)
                    insert tasks;
            }
            
            //Re-Intializing the list of tasks
            tasks = new List<Task>();
            
            //Checking for the map value
            if(mapCasesForTasksUpdate.values().size() > 0) {
                
                //Loop through map keyset
                for(String keyString : mapCasesForTasksUpdate.keySet()) {
                    
                    //Owner Id stamped on the case record
                    String ownerId = keyString.split('-')[1];
                     
                    //Loop through corresponding tasks records
                    for(Task tas : mapCasesForTasksUpdate.get(keyString)) {
                        if(tas.ownerId != ownerId) { 
                            tas.OwnerId = ownerId;
                            tasks.add(tas);
                        }
                    }
                }
                
                //Updating owner Id on the associated tasks
                if(tasks.size() > 0)
                    update tasks;
            }
        }
    }
    
    //Added By - Mahedra Swarnkar - 07/05/2016 - CR-20160229-9651
    /**
     *  @description    :   Method to populate the cases fields for the Talent development type cases on insert and update events.
     * 
     *  @args           :   List of cases, Map of Cases
     * 
     *  @return         :   void
     * 
    **/ 
    public static void populateCaseFields(List<Case> newCases, Map<Id, Case> mapOldCases) {
        
        //Set to hold the Project Ids
        Set<ID> setProjectIds = new Set<ID>();
        
        //Set to hold the All Project Ids
        Set<ID> setAllProjectIds = new Set<ID>();

        //Set to hold All Contract Ids
        Set<ID> setContractIds = new Set<ID>();
        
        //Case Talent Development Record Type Id
        Id caseTalentDevelopmentRecordType= Util.RecordTypeId('Case', 'Talent Development');
        
        //Populate the Set 
        for(Case tdCase :newCases) {
            
            //Insert and update case
            //Check for the Talent Development record type and Project Source on the Cases
            if(tdCase.RecordTypeId != null && tdCase.RecordTypeId == caseTalentDevelopmentRecordType ){
                if( tdCase.Project_Source_MS__c != null){
                
                    setAllProjectIds.add(tdCase.Project_Source_MS__c);
                    //Populate the Set "setProjectIds"
                    if(mapOldCases == null 
                        || (mapOldCases != null && tdCase.Project_Source_MS__c != mapOldCases.get(tdCase.Id).Project_Source_MS__c ))
                        setProjectIds.add(tdCase.Project_Source_MS__c);
                }
                if(tdCase.Contract__c != null) {
                    setContractIds.add(tdCase.Contract__c);
                }
            }   
        }
        
        Map<Id,Contract__c> mapContracts;
        if(setContractIds.size() > 0 ) {
            mapContracts = new Map<Id,Contract__c>([Select Id, End__c From Contract__c Where Id IN : setContractIds]);
        }
        
        Map<Id,Project__c> mapProjects;
        //Check for Size
        if(setAllProjectIds.size() > 0) {
            
            //Map to hold the Project records
            //Query through Project records
            mapProjects = new Map<Id,Project__c>([Select Id, Name, Membership_Advisor_Relationship_Manager__r.Name, Dedicated_Advisor__r.Name, Program_Associate__r.Name, 
                                                                        No_of_Participants__c, Cohort_ID_s__c, X1_2_Day__c, Full_Day__c, Contract_Start_Date__c, 
                                                                        Internal_Strat_Session_NPI_Actual__c, Service_Date_Start__c 
                                                                        From Project__c 
                                                                        Where Id IN : setAllProjectIds]);
        }
            
            
        //Loop through Case records
        for(Case tdCas :newCases) {
            
            //Check for the "Talent Development" Record type 
            if(tdCas.RecordTypeId != null && tdCas.RecordTypeId == caseTalentDevelopmentRecordType){
                
                //Check for the Project Source on the case and in the map "mapProjects"
                if(tdCas.Project_Source_MS__c != null) {
                    if( setProjectIds.size() > 0 && setProjectIds.contains(tdCas.Project_Source_MS__c) 
                       && mapProjects != null
                       && mapProjects.size() > 0 
                       && mapProjects.containsKey(tdCas.Project_Source_MS__c) 
                       && mapProjects.get(tdCas.Project_Source_MS__c) != null){
                           
                        //Populate the Case fields
                        tdCas.RM__c = mapProjects.get(tdCas.Project_Source_MS__c).Membership_Advisor_Relationship_Manager__r.Name;
                        tdCas.DA__c = mapProjects.get(tdCas.Project_Source_MS__c).Dedicated_Advisor__r.Name;
                        tdCas.Associate__c = mapProjects.get(tdCas.Project_Source_MS__c).Program_Associate__r.Name;
                        tdCas.No_of_Participants__c = mapProjects.get(tdCas.Project_Source_MS__c).No_of_Participants__c;
                        tdCas.Cohort_ID__c = mapProjects.get(tdCas.Project_Source_MS__c).Cohort_ID_s__c;
                           
                        if(mapProjects.get(tdCas.Project_Source_MS__c).X1_2_Day__c != null)
                               tdCas.Half_Day_or_Full_Day__c = '1/2 Day';
                        else {
                            if(mapProjects.get(tdCas.Project_Source_MS__c).Full_Day__c != null)
                                tdCas.Half_Day_or_Full_Day__c = 'Full Day';
                            else
                                tdCas.Half_Day_or_Full_Day__c = null;
                        }
                           
                        tdCas.Contract_Service_Start__c = mapProjects.get(tdCas.Project_Source_MS__c).Contract_Start_Date__c;
                        tdCas.Contract_Service_End__c = mapProjects.get(tdCas.Project_Source_MS__c).Internal_Strat_Session_NPI_Actual__c;
                        tdCas.Service_Start__c = mapProjects.get(tdCas.Project_Source_MS__c).Service_Date_Start__c; 
                    }   
                    
                    if(tdCas.Contract__c != null
                       && mapContracts != null
                       && mapContracts.containsKey(tdCas.Contract__c)
                       &&  mapContracts.get(tdCas.Contract__c) != null
                       && mapContracts.get(tdCas.Contract__c).End__c != null
                      ){
                          tdCas.Project_Year__c =  mapProjects.get(tdCas.Project_Source_MS__c).Name +' - ' + mapContracts.get(tdCas.Contract__c).End__c.year();
                      }
                    else{
                        tdCas.Project_Year__c =  mapProjects.get(tdCas.Project_Source_MS__c).Name +' - null' ;
                    }
                }
                else {
                    
                    //Populate the case fields to default values.
                    tdCas.RM__c = null;
                    tdCas.DA__c = null;
                    tdCas.Associate__c = null;
                    tdCas.No_of_Participants__c = null;
                    tdCas.Cohort_ID__c = null;
                    tdCas.Half_Day_or_Full_Day__c = null;
                    tdCas.Contract_Service_Start__c = null;
                    tdCas.Contract_Service_End__c = null;
                    tdCas.Service_Start__c = null;
                    
                    if(tdCas.Contract__c != null 
                       && mapContracts != null
                       && mapContracts.containsKey(tdCas.Contract__c)
                       && mapContracts.get(tdCas.Contract__c) != null
                       && mapContracts.get(tdCas.Contract__c).End__c != null
                      ){
                          tdCas.Project_Year__c =  'null -' + mapContracts.get(tdCas.Contract__c).End__c.year();
                      }
                    else{
                        tdCas.Project_Year__c =  'null - null' ;
                    }
                }
            }   
        }
    }
}