/*
    Purpose         :   This class is helper class for trigger on Opportunity object.
                
    Create By       :   Simplyforce Technology
    
    Created Date    :   04/11/2012
    
    Current Version :   v1.0
    
    Revision Log    :   V_1.0 Created  
                        V_1.1 New method added  - CR-20111205-259
                        V_1.2 Bhavi - 11/05/2012 - CR-20120920-1514
                        V_1.3 Bhavi - 11/08/2012 - Added a new Method(PopulateContactData) - CR-20121019-1641
                        V_1.4 Bhavi - 12/12/2012 - Added a new Method(validateAgreementsStatus) - CR-20121106-1687
                        V_1.5 Bhavi - 02/17/2013 - Added a new Method(rollupOppsDataOnAccount) - CR-20130117-2187
                        V_1.6 Bhavi - 04/30/2013 - Added a new Method(populateFieldOnOpportunityWithMembership) - CR-20130408-2835
                        v_1.7 VH    - 10/15/2013 - Checking for null and bypassing triggers in populateContactData - CR-20130624-3196
                        v_1.8 VH    - 11/20/2013 - Added a new method (populateInitialVisitOnEvents) - CR-20130919-3662
                        v_1.9 Bhavi - 01/11/2014 - Added a new method (updateWarmLeadInfoOnOpportunity) - CR-20130417-2892
                        v_1.10 Ajit Surana - 03/13/2014 - Added a new method (updateOpportunityNonSOXFields) - CR-20140205-4458
                        v_1.11 Abhinav Sharma - 07/02/2014 - Added new method (updateOpportunitiesWithDesiredFieldValues) - CR-20140502-5327
                        v_1.12 Ajit Surana - 08//4/2014 - Modified updateOpportunitiesWithDesiredFieldValues() method - CR-20140731-6814
                        v_1.13 Abhinav Sharma - 08/26/2014 - Modified to fix the Too many SOQL queries error - CR-20140808-6940
                        v_1.14 Abhinav Sharma - 09/15/2014 - Added new method - (rollUpSummaryFieldValuesOnBundleOpp) - CR-20140429-5272
                        v_1.15 Abhinav Sharma - 09/15/2014 - Added new method - (manageBundledOppSiblings) - CR-20140429-5272
                        v_1.16 Abhinav Sharma - 09/17/2014 - Added new method - (populateAccountOnBundleOpportunity) - CR-20140429-5272 
                        v_1.17 Abhinav Sharma - 09/19/2014 - Added new method - (populateBundleNameOnOpportunities) - CR-20140429-5272
                        v_1.18 Ajit Surana - 01/22/2015 - Modified the method (populateFieldOnOpporutnityWithmembership) - CR-20141210-8281                            
                        v_1.19 Abhianv Sharma - 04/10/2015 - CR-20150220-8700 - Added isDeleted =false and ALL ROWS at line 657
                        v_1.20 Abhinav Sharma - 08/25/2015 - CR-20150820-9167 - Added new methods(doCalculationAndPopulateFieldsOnOpportunities, applyValidationsOverOpportunityRecords)
                        v_1.21 - Abhinav Sharma - 08/28/2015 - CR-20140613-5790 - Added new methods (populatePAsAndActivityFieldsOnWarmLeadMTMs)
                        v_1.22 - Victor Hanson - 10/09/2015 - CR-20151009-9309 - Hypercare fix to bypass superfluous SOQL (populatePAsAndActivityFieldsOnWarmLeadMTMs)
                        v_1.23 - Abhinav Sharma - 10/14/2015 - CR-20150831-9204 - CT Assignment Manager - update logic
                        V_1.24 - Modified By - Abhinav Sharma - 10/17/2015 - CR-20151008-9304 - Triggers repetative execution
                        V_1.25 - Modified By - Abhinav Sharma - 12/02/2015 - CR-20151022-9349 - Modified doCalculationAndPopulateFieldsOnOpportunities existing method
                        v_1.26 - Modified by - Mahendra Swarnkar - 12/04/2015 - CR-20151022-9350 -updated the method "opportunityValidationAndFieldUpdated" to update opportunity record type label name from Southwind to 'Consulting & Management'
                        v_1.27 - Modified By - Abhinav Sharma - 05/19/2016 - CR-20160308-9682 - Updated the method "opportunityValidationAndFieldUpdated"
                        v_1.28 - Modified By - Abhinav Sharma - 05/20/2016 - CR-20160308-9682 - Added a method "syncOppMainContactAndPrimayOCR"
                        V1.29 - Modified - Subhash Garhwal - 06/16/2016 - CR-20160414-9762 - updated opportunityValidationAndFieldUpdated method to change the opportunity name logic for Contract LOA opps.
                        V3.30 - Modified - Subhash Garhwal - 06/16/2016 - CR-20160414-9762 - Added a new method validateProgramOpportunities and  PreventManualDuplicateProgramOpportunities to validate/sync Children Program Opportunity.
                        V3.31 - Modified - Subhash Garhwal - 07/14/2016 - CR-20160414-9762 - Added a new method rollupProgramOpps to roll-up Program Opps.
                        v_1.32 - Modified by - Victor Hanson - 8/10/2016 - CR-20160810-10101 - bypassed the auto-naming logic for Royall record type in the 'opportunityValidationAndFieldUpdated' method.
                        v_1.33 - Modified by - Mahnedra Swarnkar - 8/11/2016 - CR-20160810-10101 - Merged the code From RoyallDev SB to Test SB for CR-10101.
                        v_1.34 - Modified By - Mahendra Swarnkar - 10/07/2016 - CR-20160825-10152 - Updated method "updateOpportunityNonSOXFields" added only a check in the If condition to bypass validation for Royall opportunity recordType.
            V_1.35 - Modified - 10/12/2016 - Subhash Garhwal -  - Q2C Hypercare of Hypercare
                        
*
*/
public without sharing class OpportunityTriggerHelper {
    
    //Static variable to hold the opportuny records to be updated
    public static Map<Id, Opportunity> opportunities;
    public static Boolean DO_NOT_OVERWRITE_INITIAL_VISIT_DATE = false;
    
    //Modified by - Mahnedra Swarnkar - 8/11/2016 - CR-20160810-10101 - Merged the code From RoyallDev SB to Test SB for CR-10101. - Starts from here
    public static final string OPPORTUNITY_ROYALL_RT_ID = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Royall').getRecordTypeId();    
    //Modified by - Mahnedra Swarnkar - 8/11/2016 - CR-20160810-10101 - Merged the code From RoyallDev SB to Test SB for CR-10101. - Ends here
    
    //Added By - Abhinav Sharma - 08/26/2014
    //Start from here
    //Static variables responsible to control the order of execution
    public static Boolean EXECUTE_TRIGGER_BEFORE_UPDATE = true;
    public static Boolean EXECUTE_TRIGGER_AFTER_UPDATE = true;
    //Upto Here
    
    //Added By - Abhinav Sharma - 05/20/2016 - CR-20160308-9682
    /**
     *  @description    :   Method to keep opportunity "Main Contact" field and associated Opportunity Contact Role records. 
     *                      in sync.
     * 
     *  @args           :   List of opportunities, Map of old opprtunities
     * 
     *  @return         :   void
     * 
    **/
    public static void syncOppMainContactAndPrimayOCR(List<Opportunity> newOpportunities, Map<Id, Opportunity> mapOldOpportunities) {
        
        //Set to hold the eligible opportunity records IDs
        Set<Id> setOpportunitiesIds = new Set<Id>();
        
        //loop through opportunity records
        for(Opportunity opp : newOpportunities) {
            
            //Insert use case
            if(newOpportunities != null && mapOldOpportunities == null) {
                if(opp.Main_Contact__c != null)
                    setOpportunitiesIds.add(opp.Id);
            }
            
            //Update use case
            if(newOpportunities != null && mapOldOpportunities != null) {
                if(opp.Main_Contact__c != mapOldOpportunities.get(opp.Id).Main_Contact__c)
                    setOpportunitiesIds.add(opp.Id);
            }
        }
        
        //Checking set for size value
        if(setOpportunitiesIds.size() > 0) {
            
            //Map to hold the opportunity record Id as key and associated opportunity contact role records list as value
            Map<Id, List<OpportunityContactRole>> mapOppIdWithOCRs = new Map<Id, List<OpportunityContactRole>>();
            
            //Map to hold the Opportunity Id as key and associated primary opportunity contact role as value
            Map<Id, OpportunityContactRole> mapOppIdWithPrimaryOCR = new Map<Id, OpportunityContactRole>();
            
            //Retreving associated "Opportunity Contact Role" records from the database
            for(OpportunityContactRole oCR : [SELECT Id, ContactId, OpportunityId, IsPrimary 
                                              FROM OpportunityContactRole 
                                              WHERE OpportunityId != null
                                              AND OpportunityId IN : setOpportunitiesIds]) {
                if(mapOppIdWithOCRs.containsKey(oCR.OpportunityId))
                    mapOppIdWithOCRs.get(oCR.OpportunityId).add(oCR);
                else
                    mapOppIdWithOCRs.put(oCR.OpportunityId, new List<OpportunityContactRole>{oCR});
                                
                if(oCR.IsPrimary)                                  
                    mapOppIdWithPrimaryOCR.put(oCR.OpportunityId, oCR);                                  
            }
                
            //List of OpportunityContactRole records (Will insert)
            List<OpportunityContactRole> oCRsListToBeInserted = new List<OpportunityContactRole>();
            
            //List of OpportunityContactRole records (Will Update)
            List<OpportunityContactRole> oCRsListToBeUpdated = new List<OpportunityContactRole>();
            
            //Loop through trigger.new instance and populating main contact field with contact reference
            //a) When the Main Contact field on Opportunity is updated via field edit, this will also set the Primary flag 
            //on the contact in the Contact Roles list.
            //b) If the contact set in Main Contact is not in the current Contact Roles, add the contact to Contact Roles
            //and set the contact as Primary.
            //c) This function must also still allow the Primary Contact to be set by updating the Contact Role record. 
            //Therefore, the Primary Contact can be set either by setting Main Contact on the Opportunity, 
            //or by setting the Primary flag on the Contact Role. (Handled by opportunity page inline VF page)
            for(Opportunity oppt : newOpportunities) {
                
                //Checking if no OCR record is associated with Opportunity record
                if(!mapOppIdWithOCRs.containsKey(oppt.Id)) {
                    
                    //Checking for "Main Contact" field value on the opportunity record
                    if(oppt.Main_Contact__c != null) {
                        
                        //Opportunity Contact Role record instance
                        OpportunityContactRole oCRoleInsert = new OpportunityContactRole();
                        
                        //Populating OCR instance with field values
                        oCRoleInsert.ContactId = oppt.Main_Contact__c;
                        oCRoleInsert.IsPrimary = true;
                        oCRoleInsert.OpportunityId = oppt.Id;
                        oCRoleInsert.Role = System.Label.OCR_CONATCT_DEFAULT_ROLE;
                        
                        //Adding instance into the list to be inserted
                        oCRsListToBeInserted.add(oCRoleInsert);
                    
                    } else {
                        //Do nothing
                    }
                
                //If OCR record(s) is already associated with opportunity record    
                } else {
                        
                    //Checking if "Main Contact" field is having a contact reference with it
                    if(oppt.Main_Contact__c != null) {
                            
                        //Boolean variable helpful in making decision about any existing OCR 
                        //with matching contact exists or not
                        Boolean isMatchingOCRExists = false;
                        
                        //Loop through OCR records and seraching out that if we are having any existing matching OCR
                        for(OpportunityContactRole oCRole : mapOppIdWithOCRs.get(oppt.Id)) {
                            if(oCRole.ContactId == oppt.Main_Contact__c)
                                isMatchingOCRExists = true;
                        }
                        
                        //If Main contact based OCR is not exists 
                        if(!isMatchingOCRExists) {
                            
                            //Opportunity Contact Role record instance
                            OpportunityContactRole oCRoleInsert1 = new OpportunityContactRole();
                            
                            //Populating OCR instance with field values
                            oCRoleInsert1.ContactId = oppt.Main_Contact__c;
                            oCRoleInsert1.IsPrimary = true;
                            oCRoleInsert1.OpportunityId = oppt.Id;
                            oCRoleInsert1.Role = System.Label.OCR_CONATCT_DEFAULT_ROLE;
                            
                            //Adding instance into the list to be inserted
                            oCRsListToBeInserted.add(oCRoleInsert1);
                            
                            //Updating existing OCR to mark it as non-primary
                            if(mapOppIdWithPrimaryOCR.containsKey(oppt.Id)
                                && mapOppIdWithPrimaryOCR.get(oppt.Id) != null) {
                                   
                                //Opportunity Contact Role record instance
                                OpportunityContactRole oCRoleUpdate = new OpportunityContactRole();
                                oCRoleUpdate = mapOppIdWithPrimaryOCR.get(oppt.Id);
                                oCRoleUpdate.IsPrimary = false;
                                oCRsListToBeUpdated.add(oCRoleUpdate);
                                    
                            } else {
                                //Do nothing
                            }
                        } else {
                            
                            //Loop through OCR records and seraching out that if we are having any existing matching OCR
                            for(OpportunityContactRole oCRole1 : mapOppIdWithOCRs.get(oppt.Id)) {
                                if(oCRole1.ContactId == oppt.Main_Contact__c) {
                                    oCRole1.IsPrimary = true;
                                    oCRsListToBeUpdated.add(oCRole1);        
                                }
                            }
                            
                            //Updating existing OCR to mark it as non-primary
                            if(mapOppIdWithPrimaryOCR.containsKey(oppt.Id)
                                && mapOppIdWithPrimaryOCR.get(oppt.Id) != null) {
                                   
                                //Opportunity Contact Role record instance
                                OpportunityContactRole oCRoleUpdate2 = new OpportunityContactRole();
                                oCRoleUpdate2 = mapOppIdWithPrimaryOCR.get(oppt.Id);
                                oCRoleUpdate2.IsPrimary = false;
                                oCRsListToBeUpdated.add(oCRoleUpdate2);
                                    
                            } else {
                                //Do nothing
                            }
                        }
                    } else {
                        
                        //Updating existing OCR to mark it as non-primary
                        if(mapOppIdWithPrimaryOCR.containsKey(oppt.Id)
                            && mapOppIdWithPrimaryOCR.get(oppt.Id) != null) {
                               
                            //Opportunity Contact Role record instance
                            OpportunityContactRole oCRoleUpdate3 = new OpportunityContactRole();
                            oCRoleUpdate3 = mapOppIdWithPrimaryOCR.get(oppt.Id);
                            oCRoleUpdate3.IsPrimary = false;
                            oCRsListToBeUpdated.add(oCRoleUpdate3);
                               
                        } else {
                            //Do nothing
                        }
                    }
                }
            }
                        
            //Checking for the size value
            if(oCRsListToBeUpdated.size() > 0)
                update oCRsListToBeUpdated;
            
            //Checking for the size value
            if(oCRsListToBeInserted.size() > 0)
                insert oCRsListToBeInserted;
        }
    }
    
    //Added By - Abhinav Sharma - 10/14/2015 - CR-20150831-9204 - CT Assignment Manager - update logic
    /**
     *  @description    :   Method to populate CT Assignment's Manager field. 
     *                      Whenever the related CT Assignment field gets populated or changed. 
     * 
     *  @args           :   List of opportunities
     * 
     *  @return         :   void
     * 
    **/
    public static void populateCTAssignmentManagerEmail(List<Opportunity> listOpportunities) {
        
        //Set to users ids
        Set<Id> setUsersIds = new Set<Id>();
        
        //Loop through oportunity records
        for(Opportunity opp : listOpportunities) {
            if(opp.CT_Assignment__c != null)
                setUsersIds.add(opp.CT_Assignment__c);
        }
        
        //Map of users
        Map<Id, User> mapUsers = new Map<Id, User>();
        
        //Checking set for size value
        if(setUsersIds.size() > 0) {
            
            //Map to hold the opportunity ID as key and CT Assignment Manager email as value
            mapUsers = new Map<Id, User>([SELECT ID, ManagerId, Manager.Email FROM User
                                                            WHERE ID IN: setUsersIds]);
            
        }
        
        //Loop through new version of opportunity records and updating/populating CT Assignment's Manager 
        //field with value
        for(Opportunity op : listOpportunities) {
            
            //Checking for CT Assignment value
            if(op.CT_Assignment__c != null) {
                
                if(mapUsers.containsKey(op.CT_Assignment__c)
                   && mapUsers.get(op.CT_Assignment__c) != null
                   && mapUsers.get(op.CT_Assignment__c).ManagerId != null) {
                       if(op.CT_Assignment_s_Manager__c != mapUsers.get(op.CT_Assignment__c).Manager.Email)    
                           op.CT_Assignment_s_Manager__c = mapUsers.get(op.CT_Assignment__c).Manager.Email;
                   }        
                else
                    op.CT_Assignment_s_Manager__c = null;
                
            } else {
                op.CT_Assignment_s_Manager__c = null;
            }
        }
    }
     
    //Modified By - Abhinav Sharma - 12/02/2015 - CR-20151022-9349
    //Added By - Abhinav Sharma - CR-20150820-9167 - 08/25/2015 - Exceeded the Spanning Relationship limit on Opportunities
    /**
     *  @description    :   This method to populate fields on opportunity records, while those were committing to the database. (On before event)
     * 
     *  @args           :   List of opportunities, Map of Opportunities
     * 
     *  @return         :   void
     * 
    **/
    public static void doCalculationAndPopulateFieldsOnOpportunities(List<Opportunity> listOpportunities, Map<Id, Opportunity> mapOpportunities) {
        
        //Set to hold opportunity Ids having "not null" value for Marketer__c lookup field
        Set<Id> setOppIdsHavingNotNullMarketer = new Set<Id>();
        
        //Set to hold the opportunity Ids having "not null" value for Signed_Opportunity_Contract__c lookup field
        Set<Id> setOppIdsHavingNotNullSignedOpportunityContract = new Set<Id>();
        
        //Set to hold the opportunity Ids having "not null" value for "Parent_Opportunity__c" lookup field
        Set<Id> setOppIdsWIthNotNullParentOpportunity = new Set<Id>();
        
        //Map to hold the opportunity records on whom marketer field got changed
        Map<Id, Opportunity> mapOpportunityWithMarketerChange = new Map<Id, Opportunity>();
        
        //Map to hold the opportunity records on whom originator field got changed
        Map<Id, Opportunity> mapOpportunityWithOriginatorChange = new Map<Id, Opportunity>();
        
        //Set to hold the marketer and originator Ids
        Set<Id> setUsersIds = new Set<Id>();
        
        //Loop through opportunity records
        for(Opportunity opp : listOpportunities) {
            
            //Checking marketer field for null value
            if(opp.Marketer__c != null)
                setOppIdsHavingNotNullMarketer.add(opp.Marketer__c);
            
            //Checking signed opportunity contract field for null value
            if(opp.Signed_Opportunity_Contract__c != null)
                setOppIdsHavingNotNullSignedOpportunityContract.add(opp.Signed_Opportunity_Contract__c);

            //Checking parent opportunity field for null value            
            if(opp.Parent_Opportunity__c != null)
                setOppIdsWIthNotNullParentOpportunity.add(opp.Parent_Opportunity__c);
            
            //Checking for marketer field value change and populating map with instances accordingly
            if(mapOpportunities != null 
                && 
                (opp.Marketer__c != mapOpportunities.get(opp.Id).Marketer__c
                ||
                opp.OwnerId != mapOpportunities.get(opp.Id).OwnerId)
            )               
                mapOpportunityWithMarketerChange.put(opp.Id, opp);
            
            //Checking for originator field value change and populating map with instances accordingly
            if(mapOpportunities != null && opp.Originator__c != mapOpportunities.get(opp.Id).Originator__c)
                mapOpportunityWithOriginatorChange.put(opp.Id, opp);
            
            //Checking for the field value and populating collection with value
            if(opp.Marketer__c != null)
                setUsersIds.add(opp.Marketer__c);
            
            //Checking for the field value and populating collection with value
            if(opp.Originator__c != null)
                setUsersIds.add(opp.Originator__c);
            
            //Checking for the owner value and populating collection with it's value
            if(opp.OwnerId != null)
                setUsersIds.add(opp.OwnerId);
            
            //Checking for the field value and populating collection with value
            if(mapOpportunities != null && mapOpportunities.get(opp.Id).Marketer__c != null)
                setUsersIds.add(mapOpportunities.get(opp.Id).Marketer__c);
            
            //Checking for the field value and populating collection with value
            if(mapOpportunities != null && mapOpportunities.get(opp.Id).Originator__c != null)
                setUsersIds.add(mapOpportunities.get(opp.Id).Originator__c);
            
            //Checking for the owner value and populating collection with it's value
            if(mapOpportunities != null && mapOpportunities.get(opp.Id).OwnerId != null)
                setUsersIds.add(mapOpportunities.get(opp.Id).OwnerId);
        }
        
        //Map of users
        Map<Id, User> mapOfUsers = new Map<Id, User>();
        
        //Checking set for size value
        if(setUsersIds.size() > 0) {
            mapOfUsers = new Map<Id, User>([SELECT ID, C_M_Channel__c FROM User 
                                            WHERE IsActive = true AND ID IN : setUsersIds]);
        }
            
        //Map of Marketers
        Map<Id, User> mapMarketers = new Map<Id, User>();
        
        //Map of Signed Opportunity Contracts
        Map<Id, Contract__c> mapSignedOppContracts = new Map<Id, Contract__c>();
        
        //Map of parent opportunities
        Map<Id, Opportunity> mapParentOpportunities = new Map<Id, Opportunity>();
        
        //Checking set for size value
        if(setOppIdsHavingNotNullMarketer.size() > 0) {
            
            //Loop through marketers and populating map with appropriate key-value pair value
            for(User u :  [SELECT ID, FirstName, LastName FROM User
                            WHERE ID IN : setOppIdsHavingNotNullMarketer])
                mapMarketers.put(u.Id, u);
        }
        
        //Checking set for size value
        if(setOppIdsHavingNotNullSignedOpportunityContract.size() > 0) {
            
            //Loop through signed opp contracts and populating map accordingly
            for(Contract__c con : [SELECT ID, Type__c FROM Contract__c 
                                   WHERE ID IN : setOppIdsHavingNotNullSignedOpportunityContract])
               mapSignedOppContracts.put(con.Id, con); 
        }
        
        //Checking set for size value
        if(setOppIdsWIthNotNullParentOpportunity.size() > 0) {
            
            //Loop through parent opportunities and populating map accordingly
            for(Opportunity op : [SELECT ID, Chairman_s_Team_Rep__c FROM Opportunity 
                                   WHERE ID IN : setOppIdsWIthNotNullParentOpportunity])
               mapParentOpportunities.put(op.Id, op);
        }
        
        //Loop through opportunity records
        for(Opportunity o : listOpportunities) {
            
            //Marketer Name (Marketer_Name__c)
            if(o.Marketer__c != null 
                && mapMarketers.containsKey(o.Marketer__c)
                && mapMarketers.get(o.Marketer__c) != null   
            ) {
                o.Marketer_Name__c = mapMarketers.get(o.Marketer__c).FirstName + ' ' + mapMarketers.get(o.Marketer__c).LastName;
            } else {
                o.Marketer_Name__c = null;
            }
            
            //Renewal Contract Type (Renewal_Contract_Type__c)
            if(o.Signed_Opportunity_Contract__c != null 
                && mapSignedOppContracts.containsKey(o.Signed_Opportunity_Contract__c)
                && mapSignedOppContracts.get(o.Signed_Opportunity_Contract__c) != null   
            ) {
                o.Renewal_Contract_Type__c = mapSignedOppContracts.get(o.Signed_Opportunity_Contract__c).Type__c;
            } else {
                o.Renewal_Contract_Type__c = null;
            }
            
            //Renewed from Chairman’s Team (Renewed_from_Chairman_s_Team__c)
            if(o.Parent_Opportunity__c != null 
                && mapParentOpportunities.containsKey(o.Parent_Opportunity__c)
                && mapParentOpportunities.get(o.Parent_Opportunity__c) != null   
            ) {
                if(String.isBlank(mapParentOpportunities.get(o.Parent_Opportunity__c).Chairman_s_Team_Rep__c))
                    o.Renewed_from_Chairman_s_Team__c = 'No';
                else
                    o.Renewed_from_Chairman_s_Team__c = 'Yes';           
            } else {
                o.Renewed_from_Chairman_s_Team__c = null;
            }
            
            //Added By - Abhinav Sharma - 12/02/2015 - CR-20151022-9349
            //Start from here
            //Logic to populate "Ownership Channel" and "Origination Channel" fields
            //Insert event - Use cases
            if(listOpportunities != null && mapOpportunities == null) {
                
                //Insert use case default logic:- 
                //IF Marketer__c is NULL, THEN Owner.C_M_Channel__c ELSE Mareter__c.C_M_Channel__c
                if(o.Marketer__c == null) {
                    if(mapOfUsers != null && mapOfUsers.containsKey(o.OwnerId) && mapOfUsers.get(o.OwnerId) != null)
                        o.Ownership_Channel__c = mapOfUsers.get(o.OwnerId).C_M_Channel__c;
                    else
                        o.Ownership_Channel__c = null;
                } else {
                    if(mapOfUsers != null && mapOfUsers.containsKey(o.Marketer__c) && mapOfUsers.get(o.Marketer__c) != null)
                        o.Ownership_Channel__c = mapOfUsers.get(o.Marketer__c).C_M_Channel__c;
                    else
                        o.Ownership_Channel__c = null;
                }
                    
                //Insert use case Default Value: If Originator__c is null, Then null, Else Originator.C&C_M_Channel__c
                if(o.Originator__c == null)
                    o.Origination_Channel__c = null;
                else {
                    if(mapOfUsers.containsKey(o.Originator__c) && mapOfUsers.get(o.Originator__c) != null)
                        o.Origination_Channel__c = mapOfUsers.get(o.Originator__c).C_M_Channel__c;
                    else
                        o.Origination_Channel__c = null;
                }
            }
            
            //Update event - Use cases
            if(listOpportunities != null && mapOpportunities != null) {
                
                //IF value in Marketer__c is changed then only update the Ownership Channel field with value 
                //as per above mentioned if logic.
                //Otherwise, Users should be able to update the value in this field.
                //So if a user updates the value, that value stays unless the Marketer__c field is updated.
                if(mapOpportunityWithMarketerChange.containsKey(o.Id) && mapOpportunityWithMarketerChange.get(o.Id) != null) {
                    if(o.Marketer__c == null) {
                        if(mapOfUsers != null && mapOfUsers.containsKey(o.OwnerId) && mapOfUsers.get(o.OwnerId) != null)
                            o.Ownership_Channel__c = mapOfUsers.get(o.OwnerId).C_M_Channel__c;
                        else
                            o.Ownership_Channel__c = null;
                    } else {
                        if(mapOfUsers != null && mapOfUsers.containsKey(o.Marketer__c) && mapOfUsers.get(o.Marketer__c) != null)
                            o.Ownership_Channel__c = mapOfUsers.get(o.Marketer__c).C_M_Channel__c;
                        else
                            o.Ownership_Channel__c = null;
                    }
                }
                
                //IF value in Originator__c is changed then only update the Origination Channel field.
                //Otherwise, Users should be able to update the value in this field. 
                if(mapOpportunityWithOriginatorChange.containsKey(o.Id) && mapOpportunityWithOriginatorChange.get(o.Id) != null) {
                    if(o.Originator__c == null)
                        o.Origination_Channel__c = null;
                    else {
                        if(mapOfUsers.containsKey(o.Originator__c) && mapOfUsers.get(o.Originator__c) != null)
                            o.Origination_Channel__c = mapOfUsers.get(o.Originator__c).C_M_Channel__c;
                        else
                            o.Origination_Channel__c = null;
                    }
                }
            }
        }
    }    
    
    //Added By - Abhinav Sharma - CR-20150820-9167 - 08/25/2015 - Exceeded the Spanning Relationship limit on Opportunities
    /**
     *  @description    :   This method is apply validations over opportunity records, while those were committing to the database. 
     * 
     *  @args           :   List of opportunities, Map of Opportunities
     * 
     *  @return         :   void
     * 
    **/
    public static void applyValidationsOverOpportunityRecords(List<Opportunity> listOpportunities, Map<Id, Opportunity> mapOpportunities) {
        
        //Current logged in user Id
        Id loggedInUserProfileId = Userinfo.getProfileId();
        
        //Map of profiles will be helpful in bypassing of validation logic for few specific profiles
        Map<Id, String> mapOfProfiles = new Map<Id, String>();
        
        //Retrieving administrator type profiles and populating set with their Ids
        for(Profile pr : [SELECT ID, Name FROM profile
                            WHERE Name != null AND (Name = 'System Administrator' OR Name = 'Finance Ops')])
            mapOfProfiles.put(pr.Id, pr.Name);
      
        //Will satisfied to true only on Insert of record(s)
        if(listOpportunities != null && mapOpportunities == null) {
            
            //Bypassing validation logic for administrator type profiles
            if(loggedInUserProfileId != null && !mapOfProfiles.containsKey(loggedInUserProfileId)) {
                
                //Map of records types
                Map<Id, RecordType> mapRecordTypes = new Map<Id, RecordType>();
                
                //Loop through opportunity active record types and populating the map accordingly
                for(RecordType rd : [SELECT ID, DeveloperName FROM RecordType WHERE IsActive = true 
                                     AND sObjectType = 'Opportunity'])
                    mapRecordTypes.put(rd.Id, rd);
        
                //loop through opportunity records
                for(Opportunity opp : listOpportunities) {
                    
                    //Your profile is not allowed to create Account Management Opportunities.
                    if(opp.RecordTypeId != null 
                        && mapRecordTypes.containsKey(opp.RecordTypeId)
                        && mapRecordTypes.get(opp.RecordTypeId) != null
                        && mapRecordTypes.get(opp.RecordTypeId).DeveloperName != null) {
                        
                        //Subhash Garhwal - 07/13/2016 - CR-20160414-9762 - Added new check for Program Opps record types
                        //Will add error on record if record type equals 
                        //RI AM Standard Opp or RI AM First Year Opp or PT Contract Maintenance or PT Contract Renewal
                        if(CPQConstants.SET_PROGRAM_OPP_RENEWAL_MAINTENANCE_RECORDTYPE_DN.contains(mapRecordTypes.get(opp.RecordTypeId).DeveloperName))
                            opp.addError(System.Label.Error_Create_Account_Management_Opportunity);      
                    }
                }
            }        
        } 
        
        //Set to hold the "Rate Card Set" records Ids 
        Set<Id> setRateCardSets = new Set<Id>();
        
        //Loop through opportunities and populating set with parent rate card set id values
        for(Opportunity o : listOpportunities) {
            
            //Checking if "Rate Card Set" field for null value
            if(o.pse__Rate_Card_Set__c != null)
                setRateCardSets.add(o.pse__Rate_Card_Set__c);
        }
        
        //Checking set for size value
        if(setRateCardSets.size() > 0) {
            
            //Map of Rate Card Sets
            Map<Id, pse__Rate_Card_Set__c> mapRateCardSets = new Map<Id, pse__Rate_Card_Set__c>([SELECT ID, CurrencyIsoCode 
                                                                                                FROM pse__Rate_Card_Set__c
                                                                                                WHERE ID IN : setRateCardSets]);
        
            //Opp_Rate_Card_Set_Currency_Mismatch
            for(Opportunity op : listOpportunities) {
                
                if(op.pse__Rate_Card_Set__c != null 
                    && 
                    (
                        op.CurrencyIsoCode == ''
                        ||
                        (mapRateCardSets.containsKey(op.pse__Rate_Card_Set__c) 
                         && mapRateCardSets.get(op.pse__Rate_Card_Set__c) != null
                         && mapRateCardSets.get(op.pse__Rate_Card_Set__c).CurrencyIsoCode == ''
                        )
                        ||
                        (mapRateCardSets.containsKey(op.pse__Rate_Card_Set__c) 
                         && mapRateCardSets.get(op.pse__Rate_Card_Set__c) != null
                         && mapRateCardSets.get(op.pse__Rate_Card_Set__c).CurrencyIsoCode != op.CurrencyIsoCode
                        )
                    )
                )       
                op.addError(System.Label.Error_Opp_Rate_Card_Set_Currency_Mismatch);
            }
        }
    }
    
    //This method is to rollup the opportunity info on account level
    public static void rollupOppsDataOnAccount(List<Opportunity> listOpportunities) {
        
        //Preapre a set of account Ids
        Set<Id> accIds = new Set<Id>();
        
        //Loop through the opportunitites and get the account Ids
        for(Opportunity opp : listOpportunities) {
            
            //Populate account Ids
            if(opp.AccountId != null)
                accIds.add(opp.AccountId);
        }
        
        //Create a Map of accounts to be updated
        Map<Id, Account> mapAccounts = new Map<Id, Account>();
        
        //Checking set for size value
        if(accIds.size() > 0) {
        
            //Query the rollup data
            List<AggregateResult> aggsPT = [Select SUM(Previous_Year_Negotiated_Credit__c) totalPYNC, AccountId accId from Opportunity 
                                            where AccountId IN: accIds AND Type2__c = 'Renewal' AND Business_Line__c = 'PT' 
                                            AND StageName !=: Constants.STAGE_OPPORTUNITY_VOID AND StageName != 'Closed' 
                                            AND (Pool_Date__c = THIS_YEAR OR (Pool_Date__c = LAST_YEAR AND IsClosed  = false 
                                            AND Decision_Type__c = 'Need New LOA')) Group By AccountId ];
            
            List<AggregateResult> aggsRI_TD = [Select SUM(Previous_Year_Negotiated_Credit__c) totalPYNC, AccountId accId from Opportunity 
                                                where AccountId IN: accIds AND Type2__c = 'Renewal' AND (Business_Line__c = 'RI' OR Business_Line__c = 'TD') 
                                                AND StageName !=: Constants.STAGE_OPPORTUNITY_VOID AND StageName != 'Closed' 
                                                AND (Pool_Date__c = THIS_YEAR OR (Pool_Date__c = LAST_YEAR AND IsClosed  = false AND Decision_Type__c = 'Need New LOA')) Group By AccountId];
            
            //Check if there are results
            if(aggsPT.size() > 0) {
            
                for(AggregateResult agg : aggsPT) {
                    
                    if(agg.get('accId') != null && agg.get('totalPYNC') != null) {
                        
                        //Account Id
                        Id accId = Id.valueOf(String.valueOf(agg.get('accId')));
                        
                        //Add values in Map
                        mapAccounts.put(accId, new Account(Id = accId, PT_Renewal_CV__c = Integer.valueOf(agg.get('totalPYNC'))));
                    }
                }
            }
        
            //Check for RI and TD bussiness line 
            if(aggsRI_TD.size() > 0) {
            
                for(AggregateResult agg : aggsRI_TD) {
                    
                    //Account Id
                    Id accId = Id.valueOf(String.valueOf(agg.get('accId')));
                    
                    //Add values in Map
                    //Check if already in map
                    if(mapAccounts.containsKey(accId)) {
                    
                        //Add in existing
                        mapAccounts.get(accId).RI_TD_Renewal_CV__c = Integer.valueOf(agg.get('totalPYNC')); 
                    } else {
                        
                        //Add in existing
                        mapAccounts.put(accId, new Account(Id = accId, RI_TD_Renewal_CV__c = Integer.valueOf(agg.get('totalPYNC'))));
                    }
                }
            }
        
            //Check for the size and update the records
            if(mapAccounts.size() > 0)
                update mapAccounts.values();
        }
    }        
    
    // This method is to update the Initial Visit Date on opportunity object with the most recent active event
    //if no active event is there flag will be false
    public static void updateInitialVisitDateByEventDate(Map<Id, Opportunity> mapOpportunities){
        
        //Check if Opportunity initial visit date need to be modified
        if(DO_NOT_OVERWRITE_INITIAL_VISIT_DATE == false) {
        
            //Map to hold the Opportunity ID as key and corresponding event record as value
            Map<Id, Event> mapOppIdWithEvent = new Map<Id, Event>();
            
            //Loop through events
            for(Event evt : [Select Id, StartDateTime from Event where Cancelled_Did_Not_Occur__c = false  
                             AND IsDeleted = false AND WhatId != null AND WhatId IN : mapOpportunities.keySet() 
                             AND (Event_Type__c =: Constants.EVENT_TYPE_OPPORTUNITY_VISIT_FOR_OPPORTUNITY_GOAL 
                              OR (Event_Type__c =: Constants.EVENT_TYPE_IN_PERSON_VISIT AND 
                                  (Event_Purpose__c =: Constants.EVENT_PURPOSE_INITIAL OR Event_Purpose__c =: Constants.EVENT_PURPOSE_RELATIONSHIP_VISIT)) 
                              OR Event_Type__c =: Constants.EVENT_TYPE_PROSPECT_MEETING_ATTENDEE_COUNT_AS_VISIT) 
                             ORDER BY CreatedDate DESC limit 1 ALL ROWS]) {
                if(!mapOppIdWithEvent.containsKey(evt.WhatId))
                    mapOppIdWithEvent.put(evt.WhatId, evt);
            }
            
            //if(DO_NOT_EXECUTE == false) {
            //fecth all the events associated with the opportunities
            //and loop through the records to get the lastest active event
            //11/05/2012 - Bhavi - CR-20120920-1514
            if(mapOpportunities.keySet().size() > 0) {
                
                //Loop through opportunity records
                for(Opportunity opp : [Select Id, Initial_Visit_Date__c from Opportunity where Id IN: mapOpportunities.keySet()]) {
                
                    //Check if there is any active event is assciated 
                    if(mapOppIdWithEvent != null && mapOppIdWithEvent.values().size() > 0 
                        && mapOppIdWithEvent.containsKey(opp.Id) && mapOppIdWithEvent.get(opp.Id) != null
                        && mapOppIdWithEvent.get(opp.Id).StartDateTime != null) {
                        
                        //Not Cancelled latest event: So copy this date to opportunity's Initial Visit Date
                        mapOpportunities.get(opp.Id).Initial_Visit_Date__c = Date.valueOf(opp.Events[0].StartDateTime);
                    
                    } else {
                    
                        //No events associted with this opportunity record or all events have been cancelled so mark Initial Visit Date as null
                        mapOpportunities.get(opp.Id).Initial_Visit_Date__c = null;
                    }
                }        
            }
        }
    }
    
    // associate a given contact record to a given campaign 
    // by creating a campaign member record for it
    public static CampaignMember assignContactToCampaign(String contactId, String campaignId, Opportunity oppty) {
        
        CampaignMember cm = new CampaignMember();
        cm.CampaignId = campaignId;
        cm.ContactId = contactId;
        cm.Opportunity__c = oppty.Id;
        cm.Status = 'Warm From Opp';
        cm.Marketer_Assignment__c = oppty.Marketer__c;
        cm.MA_Assignment__c = oppty.Marketing_Associate__c;
        return cm;
    }
    
    public static List<Campaign> getMarketWarmingCampaigns() {
        
        List<Campaign> result = [select id, Primary_Program__r.Name from Campaign
                      where isActive = true
                      and type = 'Marketing Warming Effort'
                      and status = 'In Progress' and Primary_Program__c != null];
        return result;  
    }
    
    public static Map<Id,Program__c> getPrograms() {
        
        Map<Id,Program__c> result = new Map<Id,Program__c>([select id, name from Program__c LIMIT 1000]);
        return result;
    }
    
    // returns map like Map<{'HCAB', 'BIPZ'}, campaign>
    public static Map<String,Campaign> getCampaignsAssociatedWithPrograms(List<Campaign> campaigns) {
        
        Map<String,Campaign> associatedCampaigns = new Map<String,Campaign>();
        for(Campaign c : campaigns) {
            
            Set<String> acronyms = getProgAcronym(c.Primary_Program__r.Name);
            
            // if no acronyms are found, continue
            if (acronyms == null || acronyms.size() == 0) continue;
            
            for (String acronym : acronyms)
                associatedCampaigns.put(acronym,c);
        }
        return associatedCampaigns;
    }
    
    public static List<Contact> getContactsAssociatedWithOpportunities(Map<Id,Opportunity> opportunitiesParam) {
        List<Contact> result = [select id, email 
                     from Contact where id in
                     (select contactid from OpportunityContactRole 
                      where opportunityid in :opportunitiesParam.keyset())
                      ];
        return result;
    }
    
    public static Map<String,List<Contact>> getContactsPerOpportunity(List<Opportunity> opportunitiesParam, List<Contact> contacts) {
        
        Map<String,List<Contact>> result = new Map<String,List<Contact>>();
        
        for(Opportunity o : opportunitiesParam) {
            
            for(Contact c : contacts) {
                
                List<Contact> tempCts;
                
                if(result.get(o.id)==null) {
                    
                    tempCts = new List<Contact>();
                    tempCts.add(c);
                    result.put(o.id,tempCts);
                }
                
                else {
                    
                    tempCts = result.get(o.id);
                    tempCts.add(c);
                    result.remove(o.id);  // remove old entry
                    result.put(o.id,tempCts); // add updated entry
                }
            }
        }
        return result;
    }
    
    public static Set<String> getProgAcronym(String programs) {
        
        // if programs is null, return immediately
        if (programs == null) return null;
        
        String acronym = '';
        Set<String> acronyms = new Set<String>();
        // get the program acronym from the prog name which is like "HCAB - Health care advisory board"
        List<String> progNames = programs.split(';');
        for (String prog : progNames) {
            List<String> parts = prog.split(' ');
            if (parts.size() > 0) {
                acronym = parts[0];
                acronyms.add(acronym);
            }
        }
        
        return acronyms;
    }
 
    public static List <CampaignMember> setCampaignMembers(Map<Id,Opportunity> opptyMap, Map<Id,Program__c> programs, Map<String,Campaign> associatedCampaigns,Map<String,List<Contact>> opportunityContacts,Map<Id,Opportunity> oldOpptyMap) {
        
        List <CampaignMember> campaignMembers = new List <CampaignMember>();
        
        for(Opportunity oppty : opptyMap.values()) {
            
            String oldStageName = oldOpptyMap.get(oppty.id).StageName;
            
            if(oppty.Marketing_Warming_Effort__c=='YES' && oppty.StageName=='Closed Lost' && oldStageName != 'Closed Lost') {
                
                try {
                    
                    String acronym = '';
                    
                    if(oppty.Program__c != null && programs.containsKey(oppty.Program__c) && programs.get(oppty.Program__c) != null) {
                        
                        Program__c prog = programs.get(oppty.Program__c);
                    
                        // get the program acronym from the prog name which is like "HCAB - Health care advisory board"
                        List<String> parts = prog.Name.split(' ');
                        
                        //Checking for the size value
                        if (parts.size() > 0) 
                            acronym = parts[0];
                    }    
                    
                    Campaign camp = associatedCampaigns.get(acronym);
                    
                    if(camp==null) {
                        throw new CustomException('Campaign not found.');
                    }
                    
                    List<Contact> contacts = opportunityContacts.get(oppty.id);
                    
                    if(contacts==null) {
                        throw new CustomException('Contacts not found. - null');
                    }
                    
                    else if(contacts.size()==0) {
                        throw new CustomException('Contacts not found. - size 0');
                    }
                    
                    else if(contacts.size() >0) {
                        
                        for(Contact c : contacts) {
                        
                            if(c.email!=null) {
                                
                                CampaignMember cm = assignContactToCampaign(c.id,Camp.id,oppty);
                                campaignMembers.add(cm);
                            }
                        }
                    }
                    
                    if(campaignMembers.size()==0)
                    {
                        throw new CustomException('No Email Address found');
                    }
                    
                } catch(CustomException e) {
                    
                    if(e.getMessage().contains('Campaign not found.'))
                    {
                        oppty.addError('An active warm up campaign for this program does not exist.  Please notify Strategic Marketing.');
                    }
                    else if(e.getMessage().contains('Contacts not found'))
                    {
                        oppty.addError('No Contacts exist for this opportunity to add to a Marketing Warming Effort. Please add contacts or set Marketing Warming Effort to \'No\'.');
                    }
                    else if(e.getMessage().contains('No Email Address found'))
                    {
                        oppty.addError('None of the opportunity Contacts have email addresses on this opportunity. Please update the contacts first or set Marketing Warming Effort to \'No\'.');
                    }
                }
            }
        }
        return campaignMembers; 
    }

    public static void insertCampaignMembers(List <CampaignMember> campaignMembers) {
        
        if(campaignMembers.size()>0)
        {
            try
            {
                insert campaignMembers;
            }
            catch(System.DMLException e)
            {
                if(!e.getMessage().contains('This entity is already a member of this campaign'))
                {
                    System.debug('***** Error in trgMarketWarmingEffort: ' + e.getMessage());
                }
            }
        }
    }
    
    public static void assignOpptyContactsToMarketWarmingCampaign(Map<Id,Opportunity> opptyMap, Map<Id,Opportunity> oldOpptyMap) {
            
        Map<Id,Program__c> programs = getPrograms();
        List<Campaign> campaigns = getMarketWarmingCampaigns();
        Map<String,Campaign> associatedCampaigns = getCampaignsAssociatedWithPrograms(campaigns);
        List<Contact> cnts = getContactsAssociatedWithOpportunities(opptyMap);
        Map<String,List<Contact>> opportunityContacts = getContactsPerOpportunity(opptyMap.values(),cnts);
        List <CampaignMember> campaignMembers = setCampaignMembers(opptyMap,programs,associatedCampaigns,opportunityContacts,oldOpptyMap);
        if(campaignMembers!=null && campaignMembers.size()!=0) {
                insertCampaignMembers(campaignMembers);
        }
    }
    
    //This method is to set the Agreement status to cancelled for agreements if the Opportunity status dropped/lost/void
    public static void validateAgreementsStatus(Map<Id, Opportunity> mapNewOpportunities, Map<Id, Opportunity> mapOldOpportunities) {
        
        //Create a set to hold the opprotunities id where status has been changed and set to dropped/lost/void
        Set<Id> setOpportunityIDs = new Set<Id>();
        
        //Loop though the Opportunities
        for(Opportunity opp : mapNewOpportunities.values()) {
            
            //If the Opportunity status has been changed and set to dropped/lost/void
            if(opp.StageName != null && opp.StageName != Constants.BLANK && opp.StageName != mapOldOpportunities.get(opp.Id).StageName
                && (Constants.STAGE_OPPORTUNITY_CLOSED_LOST.equalsIgnoreCase(opp.StageName)
                    || Constants.STAGE_OPPORTUNITY_VOID.equalsIgnoreCase(opp.StageName)
                    || Constants.STAGE_OPPORTUNITY_DROPPED.equalsIgnoreCase(opp.StageName))
                ) {
                
                //add opportunity id in set
                setOpportunityIDs.add(opp.Id);
            }
        }
        
        //Check if there are opportunities to process
        if(setOpportunityIDs.size() > 0) {
            
            //Create a list to hold the Agreement records to be updated
            List<echosign_dev1__SIGN_Agreement__c> agreements = new List<echosign_dev1__SIGN_Agreement__c>();
            
            //Query all the agreements related to the opportunities records and not having cancelled status
            for(echosign_dev1__SIGN_Agreement__c agreement : [Select Id from echosign_dev1__SIGN_Agreement__c where echosign_dev1__Status__c !=: Constants.STATUS_AGREEMENT_CANCELLED_DECLINED AND echosign_dev1__Opportunity__c IN: setOpportunityIDs]) {
                
                //Set the Agreement status
                agreement.echosign_dev1__Status__c = Constants.STATUS_AGREEMENT_CANCELLED_DECLINED;
                
                //Add record in list
                agreements.add(agreement);
            }
            
            //Check if tehre are records to update
            if(agreements.size() > 0)
                update agreements;
        }
    }
    
    //This method is to update the related Main Contact  field on Contact
    public static void populateContactData(Map<Id, Opportunity> mapNewOpportunities, Map<Id, Opportunity> mapOldOpportunities) {
        
        //Get all the opportunity record types for record Type Like Renewal
        Set<String> setRecordTypeName = new Set<String>();
        setRecordTypeName.add(Constants.RECORD_TYPE_OPPORTUNITY_PT_CONTRACT_MAINTENANCE);
        setRecordTypeName.add(Constants.RECORD_TYPE_OPPORTUNITY_PT_CONTRACT_RENEWAL);
        setRecordTypeName.add(Constants.RECORD_TYPE_OPPORTUNITY_RI_AM_FIRST_YEAR_OPP);
        setRecordTypeName.add(Constants.RECORD_TYPE_OPPORTUNITY_RI_AM_STANDARD_OPP);
        
        // get all record types on opportunity object
        Map<String, Id> oppRecordTypeMap = Util.recordtypemap('Opportunity');
        
        // get opportunity record types
        Map<Id, String> mapRecordTypes = new Map<Id, String>();
        for (String rtName : setRecordTypeName) {
            mapRecordTypes.put(oppRecordTypeMap.get(rtName), rtName);
        }
        
        //Loop through the opportunity records and create a set of appropriate records
        Set<Id> oppIds = new Set<Id>();
        
        //Create a Map to hold teh Contact records
        Set<Id> mainContacts = new Set<Id>();
        
        //Map to hold contacts
        Map<Id, Contact> mapContact = new Map<Id, Contact>();
        
        //Check for teh update and delete case
        if(mapOldOpportunities != null) {
            
            //loop through the Old records
            for(Opportunity opportunity : mapOldOpportunities.values()) {
            
                //Check for the conditions
                if(mapRecordTypes.containsKey(opportunity.RecordTypeId) 
                    && opportunity.CloseDate != null && opportunity.CloseDate.year() == Date.today().year() 
                    && opportunity.StageName != null && (opportunity.StageName.toLowerCase().contains(Constants.PENDING.toLowerCase()) 
                                                            || opportunity.StageName.toLowerCase().contains(Constants.STATUS_ATL.toLowerCase())
                                                            || opportunity.StageName.toLowerCase().contains(Constants.STAGE_OPPORTUNITY_VOID.toLowerCase())
                                                            || opportunity.StageName.toLowerCase().contains(Constants.STAGE_OPPORTUNITY_DROPPED.toLowerCase()))) {
                    
                    //Check if record has Main Contact
                    if(opportunity.Main_Contact__c != null)
                        mainContacts.add(opportunity.Main_Contact__c);
                }
            }
        }
        
        //Check for the insert and update case
        if(mapNewOpportunities != null) {
        
            //loop through the new records
            for(Opportunity opportunity : mapNewOpportunities.values()) {
            
                //Check for the conditions
                if(mapRecordTypes.containsKey(opportunity.RecordTypeId) 
                    && opportunity.CloseDate != null && opportunity.CloseDate.year() == Date.today().year() 
                    && opportunity.StageName != null && (opportunity.StageName.toLowerCase().contains(Constants.PENDING.toLowerCase()) 
                                                            || opportunity.StageName.toLowerCase().contains(Constants.STATUS_ATL.toLowerCase())
                                                            || opportunity.StageName.toLowerCase().contains(Constants.STAGE_OPPORTUNITY_VOID.toLowerCase())
                                                            || opportunity.StageName.toLowerCase().contains(Constants.STAGE_OPPORTUNITY_DROPPED.toLowerCase()))) {
                    
                    //Check if record has Main Contact
                    if(opportunity.Main_Contact__c != null)
                        mainContacts.add(opportunity.Main_Contact__c);
                }
            }
        }
        
        //Check if there are Main Contacts to Process
        if(mainContacts.size() > 0) {
            
            //Fecth all the Contact records
            Map<Id, Contact> mapMainContacts = new Map<Id, Contact>([Select Id, Main_Contact__c from Contact where Id IN: mainContacts]);
            
            //Check for the update and delete case
            if(mapOldOpportunities != null) {
            
                //Loop through the Old records first and Update the Main 
                for(Opportunity opportunity : mapOldOpportunities.values()) {
                    
                    //Check for the opportunity.Main_Contact__c
                    if(opportunity.Main_Contact__c != null) {
                    
                        //Contact cloneContact
                        Contact cloneContact;
                        
                        //Check for the contact and update contact's data
                        if(mapContact.containsKey(opportunity.Main_Contact__c)) {
                            
                            //Get the contact record from map
                            cloneContact = mapContact.get(opportunity.Main_Contact__c);
                        } else if(mapMainContacts.containsKey(opportunity.Main_Contact__c)) {
                            
                            //Create a contact clone
                            cloneContact = new Contact(Id = opportunity.Main_Contact__c, 
                                                        Main_Contact__c = mapMainContacts.get(opportunity.Main_Contact__c).Main_Contact__c);
                        }
                        
                        // if cloneContact wasn't found -- continue to the next record
                        if (cloneContact == null) continue;
                        
                        if(cloneContact.Main_Contact__c != null && cloneContact.Main_Contact__c != '' 
                                && cloneContact.Main_Contact__c.contains(opportunity.Program_Acronym__c)) {
                                
                            //Set program acronym in cloneContact
                            cloneContact.Main_Contact__c = cloneContact.Main_Contact__c
                                                                                .replace(Constants.COMMA + Constants.SPACE + opportunity.Program_Acronym__c, '')
                                                                                .replace(opportunity.Program_Acronym__c, '');
                        }
                        
                        //Put the contact record in map
                        mapContact.put(opportunity.Main_Contact__c, cloneContact);
                    }
                }
            }
            
            //Check for the Insert and Update
            if(mapNewOpportunities != null) {
            
                //Loop through the New records
                for(Opportunity opportunity : mapNewOpportunities.values()) {
                    
                    //Check for the opportunity.Main_Contact__c
                    if(opportunity.Main_Contact__c != null) {
                    
                        //Contact cloneContact
                        Contact cloneContact;
                        
                        //Check for the contact and update contact's data
                        if(mapContact.containsKey(opportunity.Main_Contact__c)) {
                            
                            //Get the contact record from map
                            cloneContact = mapContact.get(opportunity.Main_Contact__c);
                        } else if(mapMainContacts.containsKey(opportunity.Main_Contact__c)) {
                            
                            //Create a contact clone
                            cloneContact = new Contact(Id = opportunity.Main_Contact__c, 
                                                        Main_Contact__c = mapMainContacts.get(opportunity.Main_Contact__c).Main_Contact__c);
                        }
                        
                        // if cloneContact wasn't found -- continue to the next record
                        if (cloneContact == null) continue;
                        
                        if(cloneContact.Main_Contact__c != null && cloneContact.Main_Contact__c != '') {
                                
                            //Check if Contact doesn't have this already
                            if(!cloneContact.Main_Contact__c.contains(opportunity.Program_Acronym__c)) {
                                    
                                //Set program acronym in cloneContact
                                cloneContact.Main_Contact__c += Constants.COMMA + Constants.SPACE + opportunity.Program_Acronym__c;
                            }
                        } else {
                                
                            //Set program acronym in cloneContact
                            cloneContact.Main_Contact__c = opportunity.Program_Acronym__c;
                        }
                        
                        //Check for void and droppped opportunities
                        if(opportunity.StageName.toLowerCase().contains(Constants.STAGE_OPPORTUNITY_VOID.toLowerCase())
                            || opportunity.StageName.toLowerCase().contains(Constants.STAGE_OPPORTUNITY_DROPPED.toLowerCase())) {
                            
                            //Remove Program acronym from Main Contact 
                            if(cloneContact.Main_Contact__c != null && cloneContact.Main_Contact__c != '' 
                                && cloneContact.Main_Contact__c.contains(opportunity.Program_Acronym__c)) {
                                
                                //Set program acronym in cloneContact
                                cloneContact.Main_Contact__c = cloneContact.Main_Contact__c
                                                                                    .replace(Constants.COMMA + Constants.SPACE + opportunity.Program_Acronym__c, '')
                                                                                    .replace(opportunity.Program_Acronym__c, '');
                            }
                        }
                        
                        //Put the contact record in map
                        mapContact.put(opportunity.Main_Contact__c, cloneContact);
                    }
                }
            }
            
            //Check if there are records to update
            if(mapContact.size() > 0) {
                // bypass triggers when updating the contact's Main_Contact__c field
                Util.BypassAllTriggers = true;
                update mapContact.values();
                Util.BypassAllTriggers = false;
            }
        }
    }
    
    public static void populateInitialVisitOnActivities(list<Opportunity> newOppList, Map<Id, Opportunity> oldOppMap) {
        
        // set of opp ids to update
        set<Id> oppIdSet = new set<Id>();
        
        map<Id, Opportunity> oppMap = new map<Id, Opportunity>();
        
        // figure out which opportunities need to be updated
        for (Opportunity opp : newOppList) {
            
            Opportunity oldOpp = oldOppMap.get(opp.Id);
            
            if (opp.Initial_Visit_Date__c != oldOpp.Initial_Visit_Date__c) {
                
                oppMap.put(opp.Id, opp);
                oppIdSet.add(opp.Id);
            }
        }
        
        //Checking for size value
        if (oppIdSet.size() > 0) {
            
            if (system.isFuture() || system.isBatch()) {
                
                // update opp initial visit date on related events when the opportunity initial visit date is updated
                OpportunityTriggerHelper.populateInitialVisitOnEvents(oppMap);
                
                // update opp initial visit date on related events when the opportunity initial visit date is updated
                OpportunityTriggerHelper.populateInitialVisitOnTasks(oppMap);
            }
            else if (!Util.isPopulateInitVisitOnActivities_Future) {
                
                // set this to true to prevent recursive updates
                Util.isPopulateInitVisitOnActivities_Future = true;
                
                // if this is being triggered by a 
                populateInitialVisitOnActivities_Future(oppIdSet);
            }
        }
    }
    
    @future
    public static void populateInitialVisitOnActivities_Future(set<Id> oppIds) {
        
        //Checking for size and null value
        if(oppIds != null && oppIds.size() > 0) {
        
            // get a map of opportunities
            map<Id, Opportunity> oppMap = new map<Id, Opportunity>([SELECT Id, Initial_Visit_Date__c FROM Opportunity WHERE Id IN :oppIds]);
            
            // update opp initial visit date on related events when the opportunity initial visit date is updated
            OpportunityTriggerHelper.populateInitialVisitOnEvents(oppMap);
            
            // update opp initial visit date on related events when the opportunity initial visit date is updated
            OpportunityTriggerHelper.populateInitialVisitOnTasks(oppMap);
        }
    }
    
    // when the Initial Visit Date is updated on the Opportunity, update the Opp Initial Visit Date field on all related Events
    public static void populateInitialVisitOnEvents(Map<Id,Opportunity> oppMap) {
        
        //Checking for null and size value
        if(oppMap != null && oppMap.keySet().size() > 0) {
        
            // list to hold events that will be updated
            list<Event> eventsToUpdate = new list<Event>();
            
            // map of Opp Id to list of Events
            map<Id, list<Event>> oppToEventsMap = new map<Id, list<Event>>();
        
            // loop through each event and add to a map
            for (Event evt : [SELECT Id, Opp_Initial_Visit_Date__c, WhatId FROM Event 
                                WHERE IsDeleted = false AND WhatId IN :oppMap.keySet() ALL ROWS]) {
                
                // see if the list already exists
                list<Event> eventList = oppToEventsMap.get(evt.WhatId);
                if (eventList == null) eventList = new list<Event>();
                
                eventList.add(evt);
                
                // add the updated list back to the map
                oppToEventsMap.put(evt.whatId, eventList);
            }
        
            for (Opportunity opp : oppMap.values()) {
                
                // get the events for this opp
                list<Event> events = oppToEventsMap.get(opp.Id);
                
                // make sure event is not null
                if (events != null) {
                
                    for (Event evt : events) {
                        
                        // update the opp initial visit date on the event
                        evt.Opp_Initial_Visit_Date__c = opp.Initial_Visit_Date__c;
                        
                        // add to list of events to update
                        eventsToUpdate.add(evt);
                    }
                }
            }
        
            if (eventsToUpdate.size() > 0) {
                
                // update events
                util.BypassAllTriggers = true;
                update eventsToUpdate;
                util.BypassAllTriggers = false;
            }
        }        
    }
    
    // when the Initial Visit Date is updated on the Opportunity, update the Opp Initial Visit Date field on all related Events
    public static void populateInitialVisitOnTasks(Map<Id,Opportunity> oppMap) {
        
        // list to hold Tasks that will be updated
        list<Task> TasksToUpdate = new list<Task>();
        
        // map of Opp Id to list of Tasks
        map<Id, list<Task>> oppToTasksMap = new map<Id, list<Task>>();
        
        //Checking map for size and null value
        if(oppMap != null && oppMap.size() > 0) {
        
            // loop through each Task and add to a map
            for (Task tsk : [SELECT Id, Opp_Initial_Visit_Date__c, WhatId FROM Task WHERE WhatId IN :oppMap.keySet()]) {
                
                // see if the list already exists
                list<Task> TaskList = oppToTasksMap.get(tsk.WhatId);
                if (TaskList == null) TaskList = new list<Task>();
                
                TaskList.add(tsk);
                
                // add the updated list back to the map
                oppToTasksMap.put(tsk.whatId, TaskList);
            }
            
            for (Opportunity opp : oppMap.values()) {
                
                // get the Tasks for this opp
                list<Task> Tasks = oppToTasksMap.get(opp.Id);
                
                // make sure Task is not null
                if (Tasks != null) {
                
                    for (Task tsk : Tasks) {
                        
                        // update the opp initial visit date on the Task
                        tsk.Opp_Initial_Visit_Date__c = opp.Initial_Visit_Date__c;
                        
                        // add to list of Tasks to update
                        TasksToUpdate.add(tsk);
                    }
                }
            }
        
            if (TasksToUpdate.size() > 0) {
            
                // update Tasks
                util.BypassAllTriggers = true;
                update TasksToUpdate;
                util.BypassAllTriggers = false;
            }
        }        
    }
    
    //This method to update and populate the Opportunity Field Active Renewal according to associated Membership
    public static void populateFieldOnOpportunityWithMembership(List<Opportunity> newListOpportunities, Map<Id,Opportunity> oldMapOpportunities) {
        
        //Set of Membership associate with Opportunities
        Set<Id> setMembership = new Set<Id>();
        
        //Set of Record type Name
        Set<String> setRecordTypeName = new Set<String>();
        setRecordTypeName.add(Constants.RECORD_TYPE_OPPORTUNITY_PT_CONTRACT_MAINTENANCE);
        setRecordTypeName.add(Constants.RECORD_TYPE_OPPORTUNITY_PT_CONTRACT_RENEWAL);
        setRecordTypeName.add(Constants.RECORD_TYPE_OPPORTUNITY_RI_AM_FIRST_YEAR_OPP);
        setRecordTypeName.add(Constants.RECORD_TYPE_OPPORTUNITY_RI_AM_STANDARD_OPP);
        
        // get all record types on opportunity object
        Map<String, Id> oppRecordTypeMap = Util.recordtypemap('Opportunity');
        
        // get opportunity record types
        Map<Id, String> mapRecordTypes = new Map<Id, String>();
        for (String rtName : setRecordTypeName)
            mapRecordTypes.put(oppRecordTypeMap.get(rtName), rtName);
        
        //Loop through the trigger.new
        for(Opportunity opp : newListOpportunities) {
            
            //Check criteria
            if(!opp.IsClosed && opp.Membership__c != null && opp.Pool_Date__c != null && mapRecordTypes.containsKey(opp.RecordTypeId)) {
                
                //Add Membership in set    
                setMembership.add(opp.Membership__c);
            }
        }
        
        //Check set size
        if(setMembership.size() > 0) {
            
            //Map to hold the existing active opportunities with Memnbership ids
            Map<Id, Opportunity> mapExistingActiveOpportunities = new Map<Id, Opportunity>();
            
            //Loop through list of Opportunities
            for(Opportunity opportunity : [SELECT Id, Name, Membership__c, Active_Renewal__c,IsClosed, Pool_Date__c FROM Opportunity 
                                                    WHERE Id NOT IN: Trigger.New AND Membership__c != null AND Membership__c IN: setMembership
                                                    AND Active_Renewal__c = true ]){
                
                //Put data in Map
                mapExistingActiveOpportunities.put(opportunity.Membership__c, opportunity);
            }
            
            //List to hold the opportunities to be updated'
            map<Id, Opportunity> opportunitiesToBeUpdated = new map<Id, Opportunity>();
            
            //Loop through the trigger.new
            for(Opportunity opp : newListOpportunities) {
                
                //Check criteria
                if(!opp.IsClosed && opp.Membership__c != null && opp.Pool_Date__c != null && mapRecordTypes.containsKey(opp.RecordTypeId)) {
                    
                    //Check if memship already has active opportunity
                    if(mapExistingActiveOpportunities.containsKey(opp.Membership__c)) {
                        
                        //Initialize opportunity record
                        Opportunity existingOpportunity = mapExistingActiveOpportunities.get(opp.Membership__c);
                        
                        //Check if exisitng opportunity is in the current year
                        //Exsiting record is in past and greater than new opportunity record
                        //Exsiting record is in future and smaller than new opportunity record
                        //do nothing
                        if(!existingOpportunity.IsClosed &&
                            (existingOpportunity.Pool_Date__c.year() == Date.today().year() 
                                || (existingOpportunity.Pool_Date__c.year() < Date.today().year() && (opp.Pool_Date__c.year() > Date.today().year() || existingOpportunity.Pool_Date__c.year() > opp.Pool_Date__c.year()))
                                || (existingOpportunity.Pool_Date__c.year() > Date.today().year() && existingOpportunity.Pool_Date__c.year() < opp.Pool_Date__c.year())))
                            continue;
                        else {
                            
                            //Mark is Active on currect record
                            opp.Active_Renewal__c = true;
                            
                            //Remove active flag from existing record
                            existingOpportunity.Active_Renewal__c = false;
                            
                            //add in list to be updated
                            opportunitiesToBeUpdated.put(existingOpportunity.Id, existingOpportunity);
                        }
                    } else {
                        
                        //Mark is Active on currect record
                        //opp.Trigger_Update__c = true;
                        opp.Active_Renewal__c = true;
                    }
                }
            }
            
            //Modified By - Ajit Surana - 01/22/2015 - CR-20141210-8281   
            //String to hold the log message
            String logMessage = '';
            
            //Check for the size and update the records
            if(opportunitiesToBeUpdated.size() > 0) {
                Util.BypassAllTriggers = true;
                Database.SaveResult[] results = database.update(opportunitiesToBeUpdated.values(), false);
                logMessage = Util.createLog(results); 
                Util.BypassAllTriggers = false;
            }
            
            //Checking if log message is there in case of error
            if(logMessage != '') {
                
                //User Instance
                List<User> sfAdminUser = [Select Email FROM User WHERE Name = 'Salesforce Administrator' 
                                            AND IsActive = true AND Profile.Name = 'System Administrator' 
                                            AND Email != null LIMIT 1];
            
                //Send log to admin
                if(sfAdminUser.size() > 0)
                    EmailHandler.sendEmail(sfAdminUser[0].Email, System.Label.Error_OpportunityUpdate, logMessage);
            }
        }
    }
    
    //Method modified by Ajit Surana - 08/14/2014 - CR-20140731-6814
    //Added By - Abhinav Sharma - CR-20140502-5327 - 07/02/2014
    /**
     *  @description    :   This method is to update the Membership record with associated opportunity records fields value.
     *                      (i) Method to populate "Active Renewal Opportunity" field on membership record with opportunity Id value 
     * 
     *  @args           :   List of opportunities, Map of Opportunities
     * 
     *  @return         :   void
     * 
    **/ 
    public static void updateOpportunitiesWithDesiredFieldValues(List<Opportunity> newListOpportunities, Map<Id,Opportunity> oldMapOpportunities) {
        
        //Set of Membership associate with Opportunities
        Set<Id> setMembership = new Set<Id>();
        
        //Modified By - Ajit Surana - 08/14/2014 - CR-20140731-6814 - Use Map instead of List
        //Map to hold the membership records to be updated with appropriate values
        Map<Id, Membership__c> mapMembershipsGoingToBeUpdate = new Map<Id, Membership__c>();
        
        //Loop through the trigger.new
        for(Opportunity opp : newListOpportunities) {
            
            //Check criteria and then populate the set with Id values
            if(opp.Membership__c != null)
                setMembership.add(opp.Membership__c);
        }
        
        //Map to hold the Membership records to be updated
        Map<Id, Membership__c> mapMemberships = new Map<Id, Membership__c>();
        
        //Checking set for size value
        if(setMembership.size() > 0) {
        
            //Map to hold the Membership records to be updated
            mapMemberships = new Map<Id, Membership__c>([Select ID, Active_Renewal_Opportunity__c FROM Membership__c 
                                                            WHERE ID IN : setMembership]);
        }
        
        //Checking map for size value
        if(mapMemberships.keySet().size() > 0) {
            
            //Loop through the trigger.new
            for(Opportunity op : [SELECT Id, Name, Membership__c, Active_Renewal__c,IsClosed, Pool_Date__c, RecordTypeId FROM Opportunity 
                                               WHERE Membership__c != null AND Membership__c IN: mapMemberships.keySet()
                                               AND Active_Renewal__c = true]) {
                
                    
                //Proceed further only and only if we are having differences in between values for the field on membership record
                if(mapMemberships != null && mapMemberships.get(op.Membership__c) != null && op.Id != mapMemberships.get(op.Membership__c).Active_Renewal_Opportunity__c) {
                        
                    //Updating field values on membership record and then adding it to the list to be update
                    mapMemberships.get(op.Membership__c).Active_Renewal_Opportunity__c = op.Id;
                    mapMembershipsGoingToBeUpdate.put(op.Membership__c, mapMemberships.get(op.Membership__c));           
                }
            }
            
            //Check for the size and update the records
            if(mapMembershipsGoingToBeUpdate.size() > 0) {
                Util.BypassAllTriggers = true;
                update mapMembershipsGoingToBeUpdate.values();
                Util.BypassAllTriggers = false;
            }
        }            
   }
    
    /**
     *  @description    :   This method is to update the Warm lead counter information on opportunities
     * 
     *  @args           :   List of opportunities, Map of Opportunities
     * 
     *  @return         :   void
     * 
     **/ 
    public static void updateWarmLeadInfoOnOpportunity(List<Opportunity> newOpportunities, Map<Id, Opportunity> mapOldOpportunities) {
        
        //Set of opportunities Ids to hold the records where Initial visit date has been changed
        Set<Id> oppIds = new Set<Id>();
        
        //Loop through the opportunities
        for(Opportunity opportunity : newOpportunities) {
            
            //Check if initial data is not equals to old Initial date
            //Only include these opportunities to update
            if(opportunity.Initial_Visit_Date__c != mapOldOpportunities.get(opportunity.Id).Initial_Visit_Date__c) {
                
                //Add opportunity in set to be processed
                oppIds.add(opportunity.Id);
            }
        }
        
        //Check if set has opportunities to process
        if(oppIds.size() > 0) {
            
            //Call method to update these opportunities
            WarmLeadMtMTriggerHelper.updateWarmLeadInfoOnOpportunity(oppIds);
        }
    }
    
    //Added by Ajit Surana - 03/13/2014 - CR-20140205-4458
    /**
     *  @description    :   This method is to allow users to edit Non-SOX fields on Opportunity.
     * 
     *  @args           :   List of opportunities, Map of Opportunities
     * 
     *  @return         :   void
     * 
     **/ 
    public static void updateOpportunityNonSOXFields(List<Opportunity> newOpportunities, Map<Id, Opportunity> mapOldOpportunities) {
        
        //Query to retreive current logged-in user Profile name 
        Profile currentUserProfile = [Select Id, Name from Profile where Id=: UserInfo.getProfileId()];
        String currentUserProfileName = currentUserProfile.Name.toLowerCase();
        
        //Variable to hold config manager data
        Map<String, Set<String>> MAP_Config_Manager = Constants.MAP_CONFIGURATION_MANAGER;     
        
        //JRB 2014-04-17 No longer using as criteria per hypercare update to CR-21040205-4458
        //Set to hold Profile names
        //Set<String> profilesAllowedForEditFields = new Set<String>();
        //if(MAP_Config_Manager.containsKey(Constants.PROFILE_EDIT_FIELDS_WHEN_OPP_IS_CLOSED))
        //  profilesAllowedForEditFields = MAP_Config_Manager.get(Constants.PROFILE_EDIT_FIELDS_WHEN_OPP_IS_CLOSED);
            
        //Set to hold Field values
        Set<String> fieldsAllowedForEdit = new Set<String>();
        if(MAP_Config_Manager.containsKey(Constants.EDITABLE_FIELD_AFTER_OPP_IS_CLOSED))
            fieldsAllowedForEdit = MAP_Config_Manager.get(Constants.EDITABLE_FIELD_AFTER_OPP_IS_CLOSED);
            
        //Code for Validation Rule - 'Only_Finance_Ops_can_close_an_Opp' and 'Only_Finance_Ops_can_edit'
        //Set to hold Validation related Profile names
        Set<String> setRecordLevelEditableProfiles = new Set<String> {'finance ops', 'financialforce accountant', 'system administrator', 'abc dataloader', 'financialforce ap operations', 'financialforce ar operations', 'financialforce controller', 'financialforce read only'}; 
        
        //Set to hold Validation related Opportunity Record Type names 
        Set<String> setRecordLevelEditableRecordTypes = new Set<String> {'Core_AM_First_Year_Opp', 'Core_AM_Standard_Opp', 'BI_Contract_Maintenance', 'BI_Contract_Renewal'};
        Set<Id> setCoreRecordTypes = new Set<Id>();
        
        //Query to retreive Record Type
        Map<Id, RecordType> mapRecordTypes = new Map<Id, RecordType>([SELECT Id, DeveloperName FROM RecordType WHERE DeveloperName IN: setRecordLevelEditableRecordTypes ORDER BY DeveloperName]);
        
        //Loop through the record types
        for(RecordType rType : mapRecordTypes.values()) {
            
            //Add in set
            if(rType.DeveloperName.startsWithIgnoreCase('Core'))
                setCoreRecordTypes.add(rType.Id);
        }

        //JRB 2014-04-17  Hypercare fix.  The original coded logic displayed the wrong error message for users in profiles that could edit fields after Opp Close
        //Check if user is in a profile that allows an Opp to be Closed
        Boolean isFinanceOpsUser = setRecordLevelEditableProfiles.contains(currentUserProfileName);
        
        //Loop through all Opps being updated
        for(Opportunity opp : newOpportunities){
            if(!isFinanceOpsUser){
                Boolean fieldChangeNotAllowed;
                //check if the StageName field changed, which would indicate the opp might be being closed.  Also check other specific criteria.
                if(opp.StageName != mapOldOpportunities.get(opp.Id).StageName){
                    //check that previous value of StageName was not set to a Closed value
                    if(mapOldOpportunities.get(opp.Id).StageName != Constants.CLOSED_WON 
                        && mapOldOpportunities.get(opp.Id).StageName != Constants.STAGE_OPPORTUNITY_DROPPED
                        && mapOldOpportunities.get(opp.Id).StageName != Constants.HONORARY
                        //&& mapOldOpportunities.get(opp.Id).StageName != Constants.STAGE_OPPORTUNITY_SENT_TO_FINANCE_OPP_REJECTED
                        && mapOldOpportunities.get(opp.Id).StageName != Constants.STAGE_OPPORTUNITY_VOID
                        && mapOldOpportunities.get(opp.Id).StageName != Constants.STATUS_ATL
                        && mapOldOpportunities.get(opp.Id).StageName != Constants.CLOSED
                       ) {
                            //check if new value of StageName is being set to a Closed value
                            if(opp.StageName == Constants.CLOSED_WON 
                                || opp.StageName == Constants.STAGE_OPPORTUNITY_DROPPED
                                || opp.StageName == Constants.HONORARY
                                //|| opp.StageName == Constants.STAGE_OPPORTUNITY_SENT_TO_FINANCE_OPP_REJECTED
                                || opp.StageName == Constants.STAGE_OPPORTUNITY_VOID
                                || opp.StageName == Constants.STATUS_ATL
                                || opp.StageName == Constants.CLOSED
                               ) {
                                   //Modified By Mahendra Swarnkar - 10/07/2016 - CR-20160825-10152 - added only a check in the If condition to bypass validation for Royall opportunity recordType.
                                   //These conditions indicate the Opp is going from an Open status to a Closed status.
                                   if(opp.Trigger_Update__c == mapOldOpportunities.get(opp.Id).Trigger_Update__c 
                                        && ((!setCoreRecordTypes.contains(opp.RecordTypeId))
                                            || (setCoreRecordTypes.contains(opp.RecordTypeId) 
                                                && opp.Editable_by_Finance_Ops_Only__c == false))
                                        && opp.RecordTypeId != OPPORTUNITY_ROYALL_RT_ID
                                     ) {
                                        //Generate error since user is not a Finance Ops user
                                        throw new CustomException(Label.ERROR_ONLY_FINANCE_OPS_CAN_CLOSE_AN_OPP); 
                                     }
                               }
                           }
                } else 
                    //StageName did not changed.  Check if Opp is currently in a Closed status
                    if(opp.StageName == Constants.CLOSED_WON 
                        || opp.StageName == Constants.STAGE_OPPORTUNITY_DROPPED
                        || opp.StageName == Constants.HONORARY
                        //|| opp.StageName == Constants.STAGE_OPPORTUNITY_SENT_TO_FINANCE_OPP_REJECTED
                        || opp.StageName == Constants.STAGE_OPPORTUNITY_VOID
                        || opp.StageName == Constants.STATUS_ATL
                        || opp.StageName == Constants.CLOSED
                    ) {
                        fieldChangeNotAllowed = false;
                        
                        //Populate map with all Opportunity fields
                        Map<String, Schema.SObjectField> mapObjectFields = Schema.SobjectType.Opportunity.fields.getMap();
                          
                        //Loop through all field values      
                        for(String fieldName : mapObjectFields.KeySet()) {
                        
                            fieldName = fieldName.toLowerCase();
                            
                            //Check if field value is updated or not
                            if((opp.get(fieldName) != null 
                                && mapOldOpportunities.get(opp.Id).get(fieldName) != null 
                                && String.valueOf(opp.get(fieldName)).trim() != String.valueOf(mapOldOpportunities.get(opp.Id).get(fieldName)).trim())
                                || opp.get(fieldName) != mapOldOpportunities.get(opp.Id).get(fieldName)
                            ) {
                            
                                //Check if the field is allowed for Editing 
                                if(!fieldsAllowedForEdit.contains(fieldName)) { 
                                
                                    //set flag for error message to generate
                                    fieldChangeNotAllowed = true;
                                    
                                    //Generate the error message
                                    //throw new CustomException(Label.ERROR_CLOSED_OPP_INVALID_PROFILE); 
                                }
                            }
                        }
                    }
                
                    //check if the error should be generated
                    if(fieldChangeNotAllowed == true){
                        throw new CustomException(Label.ERROR_CLOSED_OPP_INVALID_PROFILE);
                }
            }
        
            //loop through Opps
            //if  stagename is changed and old stagename is not one of the Closed Stages (not incl Closed lost)
                //if changed to a closed status (not incl Closed Lost) for Finance Only and meets recordtype and other criteria
                //if not in Finance profile
                    //generate error
                //end if
            //end if
            //comment, else if changed to Closed Lost, allow change
            //else (stagename not changed) and newOpp in Closed status
            //if user is in list of allowed edit profiles
                //get list of fields on Opp
                //loop through fields to see what changed
                    //if a field changed that is not in the allowed list, 
                        //set error flag
                    //end if
                //end loop
            //else (not in list)
                //set error flag
            //end for
            //if error flag set
                //generate error
            //end if
            //end if
        
            /*
            //Check if user has field editable access
            if(!setRecordLevelEditableProfiles.contains(currentUserProfileName)
                && !profilesAllowedForEditFields.contains(currentUserProfileName)) {
            
            //Loop through the opportunity records    
            for(Opportunity opp : newOpportunities) {
                
                //Check for the Opportunity Stage is "Closed Won, Dropped, Honorary, Sent to Finance - Opp Rejected, Void, ATL, Closed"
                if((opp.StageName == Constants.CLOSED_WON 
                    || opp.StageName == Constants.STAGE_OPPORTUNITY_DROPPED
                    || opp.StageName == Constants.HONORARY
                    || opp.StageName == Constants.STAGE_OPPORTUNITY_SENT_TO_FINANCE_OPP_REJECTED
                    || opp.StageName == Constants.STAGE_OPPORTUNITY_VOID
                    || opp.StageName == Constants.STATUS_ATL
                    || opp.StageName == Constants.CLOSED
                ) 
                && opp.Trigger_Update__c == mapOldOpportunities.get(opp.Id).Trigger_Update__c 
                && ((!setCoreRecordTypes.contains(opp.RecordTypeId)) 
                        || 
                    (setCoreRecordTypes.contains(opp.RecordTypeId) && opp.Editable_by_Finance_Ops_Only__c == false))
                ) {

                    //Generate the error message
                    //Validtion: Only_Finance_Ops_can_close_an_Opp
                    throw new CustomException(Label.ERROR_ONLY_FINANCE_OPS_CAN_CLOSE_AN_OPP);                                                               
                
                } else if(opp.Editable_by_Finance_Ops_Only__c  == true 
                            && opp.Trigger_Update__c == mapOldOpportunities.get(opp.Id).Trigger_Update__c 
                            && !mapRecordTypes.containsKey(opp.RecordTypeId)) {
                    
                        //Generate the error message
                        //Validtion: Only_Finance_Ops_can_edit
                        throw new CustomException(Label.ERROR_ONLY_FINANCE_OPS_CAN_EDIT);   
                }
            }
            } else if(profilesAllowedForEditFields.contains(currentUserProfileName)) {
            
            //If the profile is in the set of edit access for specific fields
            //Populate map with all Opportunity fields
            Map<String, Schema.SObjectField> mapObjectFields = Schema.SobjectType.Opportunity.fields.getMap();
            
            //Loop through the opportunities
            for(Opportunity opportunity : newOpportunities) {
                
                //Check for the Opportunity Stage is "Dropped, Honorary, Sent to Finance - Opp Rejected, Void, ATL, Closed,Closed Won,Closed Lost"
                if(opportunity.StageName == Constants.STAGE_OPPORTUNITY_DROPPED
                    || opportunity.StageName == Constants.HONORARY
                    || opportunity.StageName == Constants.STAGE_OPPORTUNITY_SENT_TO_FINANCE_OPP_REJECTED
                    || opportunity.StageName == Constants.STAGE_OPPORTUNITY_VOID
                    || opportunity.StageName == Constants.STATUS_ATL
                    || opportunity.StageName == Constants.CLOSED
                    || opportunity.StageName == Constants.CLOSED_WON
                    || opportunity.StageName == Constants.CLOSED_LOST
                ) {
                    
                    //Loop through all field values      
                    for(String fieldName : mapObjectFields.KeySet()) {
                        
                        fieldName = fieldName.toLowerCase();
                        
                        //Check if field value is updated or not
                        if((opportunity.get(fieldName) != null && mapOldOpportunities.get(opportunity.Id).get(fieldName) != null && 
                            String.valueOf(opportunity.get(fieldName)).trim() != String.valueOf(mapOldOpportunities.get(opportunity.Id).get(fieldName)).trim())
                            || opportunity.get(fieldName) != mapOldOpportunities.get(opportunity.Id).get(fieldName)) {
                            
                            //Check if the field is allowed for Editing 
                            if(!fieldsAllowedForEdit.contains(fieldName)) { 
                                
                                //Generate the error message
                                throw new CustomException(Label.ERROR_CLOSED_OPP_INVALID_PROFILE); 
                            }
                        }
                    }
                }
            }  
            */
        }
    }
    
    //Modified By - Abhinav Sharma - 05/19/2016 - CR-20160308-9682
    /**
     *  @description    :   This method is to validate the Main Contact on Opportunity
     *
     *  @args           :   List of opportunities
     *
     *  @return         : void
     *
     *  @revision Log   :   V1.1 - Modified - Subhash Garhwal - 06/16/2016 - CR-20160414-9762
     *
     **/
    public static void opportunityValidationAndFieldUpdated(List<Opportunity> lstOpportunities, Map<Id, Opportunity> mapNewOpportunities, Map<Id, Opportunity> mapOldOpportunities) {
        
        /*
        Purpose:
            A custom validation rule should not allow saving under the following conditions:
                StageName = ‘Contract Received – Send to Finance’
                AND
                (Main_Contact__c == null) OR (there is no “LOA” Contract Document record connected to this Opp through the Contract_Docs_to_Opps_MtM__c intersection object)
    
                    An LOA Contract Document is one that has Type__c in this list:
                        Letter of Agreement (Standard Terms)
                        Letter of Agreement (W/O Standard Terms)
                        Engagement Agreement
    
            Opportunity record field updates:
                Name
                    If NBB
                     [Account Name] - [Program Acronym] - [Year of Close Date] NBB
                    If Renewal (else)
                     [Account Name] - [Program Acronym] - [Pool Year] Renewal
                Membership__c = Membership with same Program__c and same Account_Name__c as Opportunity
                Main_Contact__c = First Opportunity Contact Role where IsPrimary = True
                REMOVED 2013-12-16 CR-20130912-3630 - Owner_Name__c = Name from User that's the Owner of the Opp - 
    
            Attached Membership record (through Opp.Membership__c) field updates
                Most_Recent_Opportunity_Close_Date__c: Of all attached Opps, the latest CloseDate
                Most_Recent_Lost_Opportunity_Close_Date__c: Of all Lost attached Opps (StageName in ( 'Dropped', 'Closed Lost', 'Void', 'Sent to Finance - Request Drop') ), the latest CloseDate
                Opportunity_in_Outreach__c: If any attached NBB Opps have StageName in  { 'Outreach', 'Prospect' }, this is 'Yes'
                Opportunity_in_Prospect__c: If any attached NBB Opps have StageName in { 'Sent to Finance', 'Verbal Yes', 'Active in SlowTrack', 'Active in FastTrack', 'Prewire', 'Initial Visit Scheduled' }, this is 'Yes'
    
    
        Create By:  Angela Williams (SAP)) - 11/2011
    
        Last Modified By:   Jeremy Nottingham) - 2/15/2011
    
        Current Version:    v1.3
    
        Revision Log:       v1.0 - (AW) Created this trigger.
                            v1.1 - (JN) Edited Trigger for clarity and performance. Added this header and verified test coverage. JN 1/24/2011
                            v1.2 - (NB-2011-02-09) - Added line 22 in the header Purpose for informational purposes.
                                        Added Purpose: "Main_Contact__c = First Opportunity Contact Role where IsPrimary = True"
                            v1.3 - (JN 2/15/2011) - Added condition to not trigger if Util.IsTrigger_NBBOppFields
                                 - Fixed naming convention to run on every save
                                 - Fixed Main Contact and Chairman's Team Rep to default to null unless there is a contact role / OpportunityTeamMember
                            v1.4 - Bhavi - 02/01/2013 - Modified UpdateRelationshipGradeNotes method to execute only when required - CR-20130131-2377
                            v1.5 - (Bhavi - 03/23/2013) - CR-20130301-2625
                            v1.6 - (Bhavi - 05/02/2013) - CR-20121226-1993
                            v1.7 - (Bhavi - 10/22/2013) - CR-20130625-3205
                            v1.8 - (Jason - 12/16/2013) - CR-20130912-3630 - Removed update to Owner_Name__c field
                            v1.9 - (Ajit Surana - 03/13/2014) - CR-20140205-4458 
    */  
        // NB20110114 - Added condition to prevent duplicate execution
        try {
                
                Map<String, Id> rtmap = Util.recordtypemap('Opportunity');
                System.debug('rtmap:'+rtmap);
                String NBBRecordTypeId1 = rtmap.get('RI Marketing');
                String NBBRecordTypeId2 = rtmap.get('PT Marketing');
                
                //Modified by - Mahendra Swarnkar - 12/04/2015 - CR-20151022-9350
                //Start from here
                String NBBRecordTypeId3 = rtmap.get('Consulting & Management');
                //Ends here
                
                //Modified by - Subhash Garhwal - 07/13/2016 - CR-20160414-9762 - Get Program - PT Marketing and Program - RI Marketing Record types
                //Start from here
                String NBBRecordTypeId4 = rtmap.get(CPQConstants.OPPORTUNITY_RECORD_TYPE_NAME_PROGRAM_PT_MARKETING);
                String NBBRecordTypeId5 = rtmap.get(CPQConstants.OPPORTUNITY_RECORD_TYPE_NAME_PROGRAM_RI_MARKETING);
                //Ends here
                
                //Add All the NBB record types in set
                Set<id> NBBRecordtypeIDs = new set<id>{ NBBRecordTypeId1, NBBRecordTypeId2, NBBRecordTypeId3,NBBRecordTypeId4,NBBRecordTypeId5}; 
                
                Set<String> outreachStages = new Set<String> { 'Outreach', 'Prospect' };
                Set<String> prospectStages = new Set<String> { 'Sent to Finance', 'Verbal Yes', 'Active in SlowTrack', 'Active in FastTrack', 'Prewire', 'Initial Visit Scheduled' };
                Set<String> closedlostStages = new Set<String>{ 'Dropped', 'Closed Lost', 'Void', 'Sent to Finance - Request Drop'};
                
                String riAMFirstYrRTID = rtmap.get('RI AM First Year Opp');
                String riAMStandardRTID = rtmap.get('RI AM Standard Opp');
                
                /*
                Code for Validation Rule
                --------------------------
                A custom validation rule should not allow saving under the following conditions:
                if (Recordtype is a NBB recordtype OR Decision_Type__c == 'Need New LOA')
                AND StageName = ‘Contract Received – Send to Finance’
                AND
                ((Main_Contact__c == null) OR (there is no “LOA” Contract Document record connected to this Opp through the Contract_Docs_to_Opps_MtM__c intersection object))
        
                An LOA Contract Document is one that has Type__c in this list:
                ·         Letter of Agreement (Standard Terms)
                ·         Letter of Agreement (W/O Standard Terms)
                ·         Engagement Agreement
        
                */
        
                List<Id> oppIdList = new List<Id>();
                set<id> valruleids = new set<id>();
                set<id> ownerids = new set<id>();
                set<id> idsForContractStrategyOutcome = new set<id>();
                
                //Added by Subhash Garhwal - 06/16/2016 - CR-20160414-9762
                String contractLOARecordTypeId = rtmap.get('Contract LOA');
            
                //Added by Colin McGloin - 06/28/2016 - CR-20160414-9762
                Set <String> programOppIds = new Set <String>();
                programOppIds.add(rtmap.get('Program – Consulting & Management'));
                programOppIds.add(rtmap.get('Program – PT Marketing'));
                programOppIds.add(rtmap.get('Program – RI Marketing'));
                
                //Added by Subhash Garhwal - 06/30/2016 - CR-20160414-9762
                Set<String> setRenewalAndMaintenanceRTIds = new Set<String>();
                setRenewalAndMaintenanceRTIds.add(rtmap.get('Program – PT Contract Maintenance'));
                setRenewalAndMaintenanceRTIds.add(rtmap.get('Program – PT Contract Renewal'));
                setRenewalAndMaintenanceRTIds.add(rtmap.get('Program – RI AM First Year Opp'));
                setRenewalAndMaintenanceRTIds.add(rtmap.get('Program – RI AM Standard Opp'));
                
                //Added by Colin McGloin - 06/29/2016 - CR-20160414-9762
                Map<Integer, String> mapofMonths = new Map<Integer, String>();
                mapofMonths.put(1, 'Jan');
                mapofMonths.put(2, 'Feb');
                mapofMonths.put(3, 'Mar');
                mapofMonths.put(4, 'Apr');
                mapofMonths.put(5, 'May');
                mapofMonths.put(6, 'Jun');
                mapofMonths.put(7, 'Jul');
                mapofMonths.put(8, 'Aug');
                mapofMonths.put(9, 'Sep');
                mapofMonths.put(10, 'Oct');
                mapofMonths.put(11, 'Nov');
                mapofMonths.put(12, 'Dec');
            
                system.debug('zzz@@@' + programOppIds.size());
                
                //Loop through opportunity records
                for(Opportunity opp: lstOpportunities) {
                    
                    oppIdList.add(opp.Id);
                    ownerids.add(opp.OwnerID);
        
                    //Requirements to run Validation on this opp: complicated.
                    if( //Must be one of these: (RI Marketing OR PT Marketing) Recordtype OR Decision Type == 'Need New LOA'
                        ((NBBRecordtypeIDs.contains(opp.RecordtypeID)) || (opp.Decision_Type__c == 'Need New LOA'))
                        &&
                        //Either new record or Stage was just changed
                        ((Trigger.IsInsert) || ((Trigger.IsUpdate) && (opp.StageName != mapOldOpportunities.get(opp.id).StageName)))
                        &&
                        //Stage is 'Contract Received - Send to Finance'. This is split up because the '-' in the middle is actually a 'long dash' rather than a hyphen.
                        ((opp.StageName.startswith('Contract Received ')) && (opp.StageName.endswith(' Send to Finance'))))
                    {
                        valruleids.add(opp.Id);
                    } //else if(mapRecordTypes.containsKey(opp.RecordTypeId))
                        //idsForContractStrategyOutcome.add(opp.Id);
                }
                    
                //Only run validation if one of the Opps might be affected
                if (valruleids.size() > 0 ) {
                    
                    List<Contract_Docs_to_Opps_MtM__c> listContracts = [select Id, Opportunity__c, Contract_Documents__r.Type__c
                                                                        from Contract_Docs_to_Opps_MtM__c
                                                                        where Opportunity__c != null AND Opportunity__c IN: valruleids 
                                                                        And
                                                                        Contract_Documents__r.Type__c IN ('Letter of Agreement (Standard Terms)','Letter of Agreement (W/O Standard Terms)','Engagement Agreement')];
                    
                    Map<Id, boolean> oppContractMap = new Map<Id, boolean>();
        
                    //Loop through contract docs
                    for(Contract_Docs_to_Opps_MtM__c obj: listContracts)
                    {
                        oppContractMap.put(obj.Opportunity__c, true);
                    }
        
                    //Code added - Bhavi Sharma - 10/22/2013 - CR-20130625-3205
                    //Loop through Trigger.new
                    for(Opportunity opp: lstOpportunities) {
                        
                        if(opp.StageName.startswith('Contract Received ') 
                            && opp.StageName.endswith(' Send to Finance') 
                            && (opp.Main_Contact__c == null || oppContractMap.get(opp.Id) == null)
                            
                        ) {
                            
                            //Check if opportunity is related to specific record types
                            if((opp.Contract_Strategy_Outcome__c == null || opp.Contract_Strategy_Outcome__c == '') &&
                                (opp.RecordTypeId == riAMFirstYrRTID || opp.RecordTypeId == riAMStandardRTID))
                                opp.addError('The Stage you have selected requires an LOA, Main Contact and Contract Strategy Outcome');
                            else
                                opp.addError('The Stage you have selected requires an LOA and a Main Contact');
                        }
                    }
                }
                /* End */
        
                /*
                Requirements -
                1) Format Opportunity Name
        
                If NBB
                 [Account Name] - [Program Acronym] - [Year of Close Date] NBB
                If Renewal (else)
                 [Account Name] - [Program Acronym] - [Pool Year] Renewal
        
        
                2) Chairman's Team Representative
                    If Chairman's Team Rep field is null
                        (a) Update with User on Sales Team with Chairman's Team Role
        
                3) Main Contact
                     If Main Contact is null
                        a) Contact with Primary Contact Role
        
                4) Membership__c
                    Query Account and Program to find Membership
        
                UPDATE REMOVED 2013-12-16 CR-20130912-3630 
                5) Owner_Name__c
                    Name from User that is Owner
                */
        
                set<Id> newnameaccids = new set<Id>();
                set<id> progids = new set<id>();
                set<id> accids = new set<id>();
                
                //Loop through opportunity records
                for(Opportunity opp: lstOpportunities) {
                    
                    Opportunity oldopp;
                    if (Trigger.IsUpdate) oldopp = mapOldOpportunities.get(opp.id);
        
                    if (opp.Program__c != null)
                        progids.add(opp.Program__c);
        
                    if (opp.AccountID != null)
                        accids.add(opp.AccountID);
        
                }
        
                String teamRole1 = 'RI - Chairman\'s Team';
                String teamRole2 = 'PT - Chairman\'s Team';
        
                /* Begin Opp Naming Convention */
                map<id, Account> accid2accmap = new map<id, Account>();
                map<id, Program__c> progid2progmap = new map<id, Program__c>();
            
                //Checking set for size value
                if(accids.size() > 0)
                    accid2accmap = new map<id, Account>([select id, Name from Account where id in :accids]);
                
                //Checking set for size value
                if(progids.size() > 0)
                    progid2progmap = new map<id, Program__c>([select Program_Acronym__c, Program_Abbreviation__c from Program__c where id in :progids]);
            
                //Loop through opportunity records
                for(Opportunity opp: lstOpportunities) {
                    
                    //Modified by - Mahnedra Swarnkar - 8/11/2016 - CR-20160810-10101 - Merged the code From RoyallDev SB to Test SB for CR-10101. - Starts from here
                    //VH 8/10/16: bypass opportunity auto-name logic for Royall opps.
                    if (opp.RecordTypeId == OPPORTUNITY_ROYALL_RT_ID) continue;
                    //Modified by - Mahnedra Swarnkar - 8/11/2016 - CR-20160810-10101 - Merged the code From RoyallDev SB to Test SB for CR-10101. - Ends here
                    
                    //Calculate Name
                    Integer maxaccnamelength = 55;
                    String nameSuffix = '';
                    String acronym = ' - - ';
        
                    //Checking program for null value
                    if(opp.Program__c != null) {
                        if(progid2progmap.containsKey(opp.Program__c) && progid2progmap.get(opp.Program__c) != null
                        && progid2progmap.get(opp.Program__c).Program_Acronym__c != null)
                        acronym = ' - ' + progid2progmap.get(opp.Program__c).Program_Acronym__c + ' - ';
                        
                        //Check for Opportunity Record types
                        if(programOppIds.contains(opp.RecordTypeId) || setRenewalAndMaintenanceRTIds.contains(opp.RecordTypeId)) {
                            
                            //Check for Program
                            if(progid2progmap.containsKey(opp.Program__c) && progid2progmap.get(opp.Program__c) != null
                                && progid2progmap.get(opp.Program__c).Program_Abbreviation__c != null)
                                acronym = ' - ' + progid2progmap.get(opp.Program__c).Program_Abbreviation__c + ' - ';    
                        }
                    }
        
                    String accname = ' ';
                    
                    //Checking account Id for null value
                    if(opp.AccountId != null)
                        accname = accid2accmap.get(opp.AccountId).Name;
        
                    Integer maxnamelength = Opportunity.Name.getDescribe().getLength();
                    Integer yearsuffix = opp.CloseDate.year();
                    String monthsuffix = mapofMonths.get(opp.CloseDate.month());
        
                    //Determine NBB or Renewal and construct last part of oppname
                    if (NBBRecordtypeIDs.contains(opp.RecordtypeID)) {
                        
                        if(opp.CloseDate != null)
                            nameSuffix = opp.CloseDate.year() + ' ';
        
                        nameSuffix += 'NBB';
                    
                    } else {
                        
                        if (opp.Pool_Year__c != null)
                            nameSuffix = opp.Pool_Year__c;
        
                        nameSuffix += ' Renewal';
                    }
        
                    //see how much of the account name we can use
                    Integer maxaccountnamelength = 55;
        
                    //truncate account name if necessary
                    accname = accname.substring(0,Math.min(accname.length(), maxaccountnamelength));
                    
                    //Update month siffix for new Record Types (CPQ)
                    if(opp.CloseDate != null)
                        monthsuffix = String.valueOf(opp.CloseDate.month()).length() == 1 ? '0' + String.valueOf(opp.CloseDate.month()) : String.valueOf(opp.CloseDate.month());
                    
                    //Update Naming for Program Opp records
                    if(programOppIds.contains(opp.RecordTypeId)){
                        if(opp.SBQQ__Renewal__c == True){
                            nameSuffix = monthsuffix + '-' + yearsuffix;  
                        }
                        else {
                            nameSuffix = yearsuffix + ' ' + 'NBB';
                        }
                    } else if(setRenewalAndMaintenanceRTIds.contains(opp.RecordTypeId)) {
                        
                        //Check for Renewal Opp
                        if(opp.SBQQ__Renewal__c)
                            nameSuffix = monthsuffix + '-' + yearsuffix;
                        else
                            nameSuffix = yearsuffix + ' ' + 'Renewal';
                    }
                    
                    //build final name
                    opp.Name = accname + acronym + nameSuffix;
                    
                    //Added by Subhash Garhwal - 06/16/2016 - CR-20160414-9762
                    //Start
                    //Check for COntract LOA Record Type
                    if(String.isNotBlank(contractLOARecordTypeId) && Id.valueOf(contractLOARecordTypeId) == opp.RecordTypeId) {
                        
                        //Variable to hold the Name
                        String oppName = '';
                        
                        if(String.isNotBlank(opp.Opportunity_Nickname__c))
                            oppName = opp.Opportunity_Nickname__c;
                        
                        //Add divider   
                        oppName += ' - ';
                        
                        //Add account name
                        oppName += accname;
                        
                        //Check for Renewal Flag
                        if(opp.SBQQ__Renewal__c)
                            oppName += ' - Contract Renewal ';
                        else    
                            oppName += ' - Contract ';
                        
                        //Add close date
                        oppName = oppName + monthsuffix + '-' + yearsuffix;
                        
                        //Set Name
                        opp.Name = oppName.left(120);
                    }//End of Contract LOA naming
                    
                } //end for opp in Trigger.new
                /* End Naming Convention*/
        
                if (Trigger.IsUpdate) {
                    
                    map<Id, Opportunity> oppid2oppmap = new map<id, Opportunity>();
                    
                    //Checking for size value
                    if(mapNewOpportunities.keyset().size() > 0) {
                        
                        oppid2oppmap = new map<id, Opportunity>([select id, AccountID, Account.Name,
                                                                 Membership__c, Membership__r.Program__c, Membership__r.Account_Name__c, Program__c, Program__r.Program_Acronym__c, Recordtype.Name, CloseDate,
                                                                 (select TeamMemberRole, UserId from OpportunityTeamMembers where TeamMemberRole =: teamRole1 or TeamMemberRole =: teamRole2),
                                                                 (select ContactId, Role from OpportunityContactRoles where IsPrimary = true)
                                                                 from Opportunity where id in : mapNewOpportunities.keyset()]);
                    }
                    
                    //Get whole list of Memberships based on matching Account and/or Program (Can't do it if we don't have a Program and an Account)
                    list<Membership__c> membersList0 = new list<Membership__c>();
        
                    //Checking for size value
                    if ((progids.size() >0) && (accids.size() > 0)) {
                        
                        membersList0 = [SELECT id, Account_Name__c, Program__c FROM Membership__c
                            WHERE Account_Name__c != null AND Program__c != null 
                            AND Program__c in :progids and Account_Name__c in :accids];
                    }
        
                    //Loop through opportunity records
                    for(Opportunity opp: lstOpportunities) {
                        
                        //Checking for value in map
                        if(oppid2oppmap.containsKey(opp.id) && oppid2oppmap.get(opp.id) != null) {
                        
                            Opportunity queriedOpp = oppid2oppmap.get(opp.id);
            
                            //Chairmans Team Rep defaults to null unless this is an insert or there's an otm for it.
                            if (Trigger.IsUpdate) opp.Chairman_s_Team_Rep__c = null;
                            if (queriedOpp.OpportunityTeamMembers.size() > 0)
                                opp.Chairman_s_Team_Rep__c = queriedOpp.OpportunityTeamMembers[0].UserID;
            
                            //Commented By - Abhinav Sharma - 05/19/2016 - CR-20160308-9682
                            //Start from here
                            //Main Contact is null unless this is an insert or there's a Primary Contact Role
                            //if (Trigger.IsUpdate) opp.Main_Contact__c = null;
                            
                            //if (queriedOpp.OpportunityContactRoles.size() > 0)
                                //opp.Main_Contact__c = queriedOpp.OpportunityContactRoles[0].ContactID;
                            //Upto here
            
                            //Assign Membership__c if necessary
                            if ((opp.Program__c != null) && (opp.AccountId !=null)
                                && ((opp.Membership__c == null)
                                || ((queriedOpp.Membership__r.Program__c != opp.Program__c) || (queriedOpp.Membership__r.Account_Name__c != opp.AccountID))))
                            {
                                for(Membership__c mem: membersList0)
                                {
                                    if((mem.Account_Name__c == opp.AccountId) && (mem.Program__c == opp.Program__c)) {
                                        opp.Membership__c = mem.Id;
                                        break;
                                    }
                                }
                            }
                        }        
                    }
                }
                else if (Trigger.IsInsert) {
                    
                    list<Membership__c> membersList0 = new List<Membership__c>();
                    
                    //Checking for size value
                    if ((progids.size() >0) && (accids.size() > 0)) {
                        
                        //Query for membership records
                        membersList0 = [select id, Account_Name__c, Program__c from Membership__c
                                            where Program__c  != null AND Account_Name__c != null 
                                                                AND Program__c in :progids and Account_Name__c in :accids];
                    }    

                    //Map of opportunities
                    map<id, Membership__c> membersmap = new map<id, Membership__c>();
                    
                    //Checking for size value
                    if(membersList0.size() > 0)
                        membersmap = new map<id, Membership__c>(membersList0);
                    
                    //Loop through opportunity records
                    for(Opportunity opp: lstOpportunities) {
        
                        //Assign Membership if necessary if (Has Program AND Has Account)
                        if ((opp.Program__c != null) && (opp.AccountId !=null)) {
                            
                            for(Membership__c mem: membersList0) {
                                
                                if((mem.Account_Name__c == opp.AccountId) && (mem.Program__c == opp.Program__c)) {
                                    
                                    opp.Membership__c = mem.Id;
                                    break;
                                }
                            }
                        }//end if membership update needed
                    }
                } //end if isUpdate, IsInsert
        
                /* Membership Field Updates
        
                Requirements:
                1. Membership
                    a) Update Most Recent Lost Opportunity Close Date on Membership
                        1) On update with Stage changed to Closed Lost
                            a) Of all Closed Lost Opportunities on Membership, MAX(CloseDate)
        
                    b) Most Recent Opportunity Close Date
                        (1) if this closedate is more recent than Membership's Most Recent close date
                            (a) Update Membership with most recent closedate
        
                    c) Opportunity in Outreach
                        1) If Open NBB-Type Opportunity(see above) on Membership with Stage = "Outreach" OR "Prospect"
                            Yes
                        Else
                            No
        
                    d) Opportunity in Prospect
                        (1) If Open NBB-Type Opportunity on Membership with Stage = "Active in Fast Track", "Active in Slow Track", "Verbal Yes", "Sent to Finance"
                            Yes
                        Else
                            No
        
                    e) Owner
                        Same as Owner of Renewal Opp from Active Contract Identified
                */
        
                Map<Id, Opportunity> oppMap = new Map<Id, Opportunity>();
                map<id, list<Opportunity>> memid2opplistmap = new map<id, list<Opportunity>>();
                List<Id> membershipIdList = new List<Id>();
        
                //loop through opportunity record
                for(Opportunity opp: lstOpportunities) {
                    
                    membershipIdList.add(opp.Membership__c);
                    
                    if (opp.Membership__c != null)
                    {
                        //get map of lists of inserted opps to compare to what's on the Membership already
                        if (memid2opplistmap.containsKey(opp.Membership__c))
                        {
                            memid2opplistmap.get(opp.Membership__c).add(opp);
                        }
                        else
                        {
                            memid2opplistmap.put(opp.Membership__c, new list<Opportunity>{ opp});
                        }
                    }
                }
        
                Map<Id, Membership__c> memRecordsToUpdate = new Map<Id, Membership__c>();
                set<Id> triggeringids = new set<Id>();
        
                if (Trigger.IsUpdate)
                    triggeringids = mapNewOpportunities.keyset();
            
                //List of memberships    
                List<Membership__c> membershipList = new  List<Membership__c>();
                
                //Checking for size value
                if(membershipIdList.size() > 0) {
        
                    //Query membership with existing Opps (that aren't being updated)
                    membershipList = [select Id, Most_Recent_Opportunity_Close_Date__c, Most_Recent_Lost_Opportunity_Close_Date__c,
                                        Opportunity_in_Outreach__c, Opportunity_in_Prospect__c, Active_Contract_Idenfied__c, 
                                        Active_Contract_Idenfied__r.Contract_Renewal_Opportunity__c,
                                        Active_Contract_Idenfied__r.Contract_Renewal_Opportunity__r.OwnerID, Relationship_Grade_Notes__c,
                                        (select id, IsWon, IsClosed, StageName, CloseDate, Recordtype.Name from Opportunities__r
                                            where id not in :triggeringids)
                                        from Membership__c where ID IN: membershipIdList
                                        ];
                }     
        
                //Added by Bhavi - 02/01/2013 - CR-20130131-2377
                //Check if Trigger is before Update]
                if(Trigger.isBefore && Trigger.isUpdate) {
        
                    //Create a map of Mameberships
                    Map<Id, Membership__c> mapMembership = new Map<Id, Membership__c>(membershipList);
        
                    //Check if there are records to process
                    if(mapMembership.size() > 0) {
        
                        //Loop through the new Opportunities
                        for(Opportunity opp : lstOpportunities) {
        
                            //Check if Membership is not null on records
                            if(opp.Membership__c != null && mapMembership.containsKey(opp.Membership__c)) {
        
                                //Update Opportunity Relational Grade with Membership relational grade
                                opp.Relationship_Grade_Notes__c = mapMembership.get(opp.Membership__c).Relationship_Grade_Notes__c;
                            }
                        }
                    }
                }
        
                //Loop through membership records
                for(Membership__c membr: membershipList) {
                    
                    //queried opps
                    List<Opportunity> oppList0 = membr.Opportunities__r;
        
                    //also go through inserted/updated opps
                    if(memid2opplistmap.containsKey(membr.id)) 
                        oppList0.addall(memid2opplistmap.get(membr.id));
        
                    Membership__c member0 = memRecordsToUpdate.get(membr.Id);
                    
                    if(member0 == null) 
                        member0 = new Membership__c(Id = membr.Id);
        
                    member0.Opportunity_in_Prospect__c = 'No';
                    member0.Opportunity_in_Outreach__c = 'No';
                    
                    //Loop through opportunity records
                    for(Opportunity opp0: oppList0)
                    {
                        //Most_Recent_Lost_Opportunity_Close_Date__c
                        if(closedlostStages.contains(opp0.StageName))
                        {
                            if(member0.Most_Recent_Lost_Opportunity_Close_Date__c == null ||  member0.Most_Recent_Lost_Opportunity_Close_Date__c < opp0.CloseDate)
                                member0.Most_Recent_Lost_Opportunity_Close_Date__c = opp0.CloseDate;
                        }
        
                        if(member0.Most_Recent_Opportunity_Close_Date__c == null || member0.Most_Recent_Opportunity_Close_Date__c < opp0.CloseDate)
                            member0.Most_Recent_Opportunity_Close_Date__c = opp0.CloseDate;
        
                        //Opportunity In Prospect, Opportunity in Outreach
                        if(NBBRecordtypeIDs.contains(opp0.RecordtypeID))
                        {
                            if(outreachStages.contains(opp0.StageName))
                                member0.Opportunity_in_Outreach__c = 'Yes';
        
                            if (prospectStages.contains(opp0.StageName))
                                member0.Opportunity_in_Prospect__c = 'Yes';
                        }
        
                    } //end for opp0 : oppList0
                    //Put this member in list to be updated.
                    memRecordsToUpdate.put(membr.Id, member0);
                }
        
                //Update all membership records
                if(memRecordsToUpdate.values().size()>0) {
        
                    //Do not fire memebrship method which updates opportunity
                    MembershipTriggerHelper.EXECUTE_UPDATE_RELATIONSHIP_GRADE_NOTES = false;
                    update memRecordsToUpdate.values();
                }
                
                //Setting flag value
                Util.IsTrigger_Opportunity_ValidationAndFieldUpdates = false;
        } catch (Exception e) {
            
            Trigger.New[0].addError(e.getMessage());
        }
    }
    
    /**
     *  @description    :   Opportunity Signed Contract
     * 
     *  @args           :   List on new and old opportunities
     * 
     *  @return         :   Void
     * 
     **/
    public static void opportunitySignedContract(List<Opportunity> lstNewOpportunities, List<Opportunity> lstOldOpportunities) {
        
        Map<String, Id> rtmap = Util.recordtypemap('Opportunity');
        String NBBRecordTypeId1 = rtmap.get('RI Marketing');
        String NBBRecordTypeId2 = rtmap.get('PT Marketing');
        
        /* 
        1. Contract : Signed Opportunity Contract
        If one of these fields changed: (RecordtypeID, Marketer__c, OwnerId)
            a) Negotiated By
                (1) If  Marketer, Owner on Opp changes
                    (a) If Opportunity NBB type
                        (i) Marketer on Opportunity
                    (b) If Renewal type
                        (i) Owner of Opp
        */
        
        List<Contract__c> contractsToUpdate = new List<Contract__c>();
        integer i=0;
        for(Opportunity opp: lstNewOpportunities){
            if(opp.Signed_Opportunity_Contract__c !=null){
                if(Trigger.isUpdate){
                    if( (lstOldOpportunities[i].RecordTypeId != lstNewOpportunities[i].RecordTypeId) || (lstOldOpportunities[i].Marketer__c != lstNewOpportunities[i].Marketer__c) || (lstOldOpportunities[i].OwnerId != lstNewOpportunities[i].OwnerId)) {     
                        If ((opp.RecordTypeId == NBBRecordTypeId1 || opp.RecordTypeId == NBBRecordTypeId2) && opp.Signed_Opportunity_Contract__c != null) { //NBB type
                            Contract__c cnt = new Contract__c(Id = opp.Signed_Opportunity_Contract__c);
                            cnt.Negotiated_By__c = opp.Marketer__c;
                            contractsToUpdate.add(cnt);
                        }else{
                            Contract__c cnt = new Contract__c(Id = opp.Signed_Opportunity_Contract__c);
                            cnt.Negotiated_By__c = opp.OwnerId;
                            contractsToUpdate.add(cnt);
                        }
                    }
                }else{
                    System.debug('opp.RecordTypeId :'+opp.RecordTypeId);
                    If ((opp.RecordTypeId == NBBRecordTypeId1 || opp.RecordTypeId == NBBRecordTypeId2) && opp.Signed_Opportunity_Contract__c != null) { //NBB type
                        Contract__c cnt = new Contract__c(Id = opp.Signed_Opportunity_Contract__c);
                        cnt.Negotiated_By__c = opp.Marketer__c;
                        contractsToUpdate.add(cnt);
                    }else{
                        Contract__c cnt = new Contract__c(Id = opp.Signed_Opportunity_Contract__c);
                        cnt.Negotiated_By__c = opp.OwnerId;
                        contractsToUpdate.add(cnt);
                    }
                }
            }
            i++;
        }
        
        if(contractsToUpdate.size()>0){
            // CR-2879 bypass all triggers when updating the Negotiated_By__c field on Contracts associated with this opp
            Util.BypassAllTriggers = true;
            update contractsToUpdate;
            Util.BypassAllTriggers = false;
        }
    }
    
    /**
     *  @description    :   Update role on Sales Team
     *
     *  @args           :   Map of new and Old opporutnities
     *
     *  @return         :   void
     *
     **/
    public static void updateSalesTeamRole(Map<Id, Opportunity> mapNewOpportunities, Map<Id, Opportunity> mapOldOpportunities) {
        
        /* 
        Requirements - 
        Sales Teams
            a) Leadership Team Owner
                (1) If changed on Opportunity field, replace that Role in Sales Team
            b) Marketer
                (1) If changed on Opportunity field, replace that Role in Sales Team
            c) Marketing Associate
                (1) If changed on Opportunity field, replace that Role in Sales Team
        
        */
        
        Map<String, Id> rtmap = Util.recordtypemap('Opportunity');
        String NBBRecordTypeId1 = rtmap.get('RI Marketing');
        String NBBRecordTypeId2 = rtmap.get('PT Marketing');
        String NBBRecordTypeId3 = rtmap.get('Program – RI Marketing');
        String NBBRecordTypeId4 = rtmap.get('Program – PT Marketing');
        
        String thisrole;
        map<id, String> backmap = new map<id, String>();
        for (String rtname : rtmap.keyset()) {
            backmap.put(rtmap.get(rtname), rtname);
        }
        
        List<OpportunityTeamMember> otmsToInsert = new List<OpportunityTeamMember>();
        List<OpportunityTeamMember> otmsToDelete = new List<OpportunityTeamMember>();
        
        map<id, Opportunity> oppmap = new map<id, Opportunity>([select id, RecordtypeId, Owner.IsActive, Marketer__c, Marketer__r.IsActive, 
            Marketing_Associate__c, Marketing_Associate__r.IsActive, Leadership_Team_Owner__c, Leadership_Team_Owner__r.IsActive,
            (select Id, UserId, OpportunityId, TeamMemberRole from OpportunityTeamMembers) from Opportunity where id in : mapNewOpportunities.keyset()]);
        
        for (Id oppid : oppmap.keyset()) {
            Opportunity opp = oppmap.get(oppid);
            Opportunity oldopp = (Trigger.isUpdate) ? mapOldOpportunities.get(oppid) : null;
            
            //Can't make changes to an Opp with an inactive Owner
            if (opp.Owner.IsActive) {
                //Marketer
                if ((opp.Marketer__c != null) && (opp.Marketer__r.IsActive)
                    && ((Trigger.IsInsert) || (opp.Marketer__c != oldopp.Marketer__c))) {
                    thisrole = 'PT - Marketer';
                    if (String.isNotBlank(backmap.get(opp.RecordtypeId)) && (backmap.get(opp.RecordtypeId).startswith('RI')
                        || backmap.get(opp.RecordtypeId).startswith('Program – RI')))
                        thisrole = 'RI - Marketer';
                
                    for (OpportunityTeamMember otm : oppmap.get(opp.id).OpportunityTeamMembers) {
                        if (otm.TeamMemberRole == thisrole) {
                            otmstodelete.add(otm);
                        }
                    }
                    otmsToInsert.add(new OpportunityTeamMember(
                        OpportunityId = opp.Id, 
                        UserId=opp.Marketer__c, 
                        TeamMemberRole = thisrole ));
                }
                
                //Marketing Associate
                if ((opp.Marketing_Associate__c != null) && (opp.Marketing_Associate__r.IsActive)
                    && ((Trigger.IsInsert) || (opp.Marketing_Associate__c != oldopp.Marketing_Associate__c))) {
                    thisrole = 'PT - Marketing Associate';
                    if (String.isNotBlank(backmap.get(opp.RecordtypeId)) && (backmap.get(opp.RecordtypeId).startswith('RI')
                        || backmap.get(opp.RecordtypeId).startswith('Program – RI')))
                        thisrole = 'RI - Marketing Associate';
                        
                    for (OpportunityTeamMember otm : oppmap.get(opp.id).OpportunityTeamMembers) {
                        if (otm.TeamMemberRole == thisrole) otmstodelete.add(otm);
                    }   
                    otmsToInsert.add(new OpportunityTeamMember(
                        OpportunityId = opp.Id, 
                        UserId=opp.Marketing_Associate__c, 
                        TeamMemberRole = thisrole ));
                }
                
                //Leadership Team Owner
                if ((opp.Leadership_Team_Owner__c != null) && (opp.Leadership_Team_Owner__r.IsActive)
                    && ((Trigger.IsInsert) || (opp.Leadership_Team_Owner__c != oldopp.Leadership_Team_Owner__c))) {
                    thisrole = 'PT - Leadership Team';
                    if (String.isNotBlank(backmap.get(opp.RecordtypeId)) && (backmap.get(opp.RecordtypeId).startswith('RI')
                        || backmap.get(opp.RecordtypeId).startswith('Program – RI')))
                        thisrole = 'RI - Leadership Team';
                        
                    for (OpportunityTeamMember otm : oppmap.get(opp.id).OpportunityTeamMembers) {
                        if (otm.TeamMemberRole == thisrole) otmstodelete.add(otm);
                    }   
                    otmsToInsert.add(new OpportunityTeamMember(
                        OpportunityId = opp.Id, 
                        UserId=opp.Leadership_Team_Owner__c, 
                        TeamMemberRole = thisrole ));
                    
                }
            } //end if Owner IsActive
        }
        
        if (otmsToDelete.size() > 0) {
            Util.byPassAllTriggers = true;
            delete otmsToDelete;
            Util.byPassAllTriggers = false;
        }
        
        if (otmsToInsert.size() > 0) {
            Util.byPassAllTriggers = true;
            insert otmsToInsert;
            Util.byPassAllTriggers = false;
        }
    }
    
    /**
     * 
     *
     *
     *
     **/
    public static void populateInitialVisitDate(Map<Id, Opportunity> mapNewOpportunities) {
        
        /*
        Requirements:
        
        1. Warm Lead (through Warm Lead MtM)
            a) Initial Visit Date
                (1) Should be earliest Initial Visit Date of all connected (through WarmLeadMtM) Opportunities
        
        Warm_Lead__c Object
            Initial Visit Date > Initial_Visit_Date__c
        
        Warm_Lead_MtM__c Object
            Opportunity__c
            Warm_Lead__c
        
        */
        
        List<Id> oppIdList = new List<Id>();
        for(Opportunity opp: mapNewOpportunities.values()){
            oppIdList.add(opp.Id);
        }
        
        List<Warm_Lead__c> warmLeadsToUpdate = new List<Warm_Lead__c>();
        List<Warm_Lead__c> wllist = new List<Warm_Lead__c>();
        
        //Checking for size value
        if(wllist.size() > 0) {
        
            wllist = [select Id, Initial_Visit_Date__c, 
                (select Id, Opportunity__r.Initial_Visit_Date__c from Warm_Leads_MtM__r where Opportunity__c != null) 
                from Warm_Lead__c 
                where id in (select Warm_Lead__c from Warm_Lead_MtM__c where Opportunity__c IN :oppIdList)];
        }
        
        for (Warm_Lead__c wl: wllist) {
            Boolean IsUpdate = false;
            Warm_Lead__c wlObj = new Warm_Lead__c(Id = wl.Id);
            wlObj.Initial_Visit_Date__c = wl.Initial_Visit_Date__c;
            
            for (Warm_Lead_MtM__c wlmtm : wl.Warm_Leads_MtM__r) {
                
                //If this wlmtm is connected to a triggering record, take the new version of it. If not, take the queried version
                Date oppInitialVisit = (mapNewOpportunities.keyset().contains(wlmtm.Opportunity__c)) 
                    ? mapNewOpportunities.get(wlmtm.Opportunity__c).Initial_Visit_Date__c 
                    : wlmtm.Opportunity__r.Initial_Visit_Date__c;
                if (oppInitialVisit == null) continue;
                
                if(wlObj.Initial_Visit_Date__c == null || ( oppInitialVisit < wlObj.Initial_Visit_Date__c)){
                    wlObj.Initial_Visit_Date__c = oppInitialVisit;
                    IsUpdate = true;
                }
            }
    
            if (IsUpdate) warmLeadsToUpdate.add(wlObj);
        }
    
        if(warmLeadsToUpdate.size()>0) {
            Util.byPassAlltriggers = true;  
            update warmLeadsToUpdate;
            Util.byPassAlltriggers = false; 
        }
    }
    
    /**
     *  @description    :   membershipOwnerCheckfromOpps
     *
     *  @args           :   List of opprotunities
     *
     *  @return         :   void
     *
     **/
    public static void membershipOwnerCheckfromOpps(List<Opportunity> lstOpportunities) {
        
        //Opp Ids
        set<id> selectoppids = new set<id>();
        
        //filter list to exclude the ones that aren't even on a Contract
        for (Opportunity o : lstOpportunities) {
            if (o.Previous_Contract__c != null) selectoppids.add(o.id);//Membership__c);
        }
        
        //Call @future method to update Membership owners
        if (!Util.IsTesting) {
            
            //Bhavi Sharma - 04/26/2013 - CR-20130227-2597 - Added condition to make the callout only if not current context is not batch or future
            if(!System.isFuture() && !System.isBatch()) {
                
                Util.membershipOwnerCheckfromOpps(selectoppids);
            }
        }
        Util.TestVariable += 'Util.membershipOwnerCheckfromOpps '; // demonstrate to unit test that we got here.
    }
    
    //Added by Abhinav Sharma - 09/19/2014 - CR-20140429-5272
    /**
    *  @description    :   Method to populate parent bundle name on the opportunities records
    * 
    *  @args           :   List of opportunities
    * 
    *  @return         :   void
    * 
    **/
    public static void populateBundleNameOnOpportunities(List<Opportunity> newOpportunities) {
    
        //Set to hold the Bundle Ids
        Set<Id> setBundlesIds = new Set<Id>();
        
        //Loop through new opportunities
        for(Opportunity opp : newOpportunities) {
            if(opp.Bundle__c != null)
                setBundlesIds.add(opp.Bundle__c);
        }
        
        //Checking set for size value
        if(setBundlesIds.size() > 0) {
            
            //Map of Bundles
            Map<Id, Bundle__c> mapBundles = new Map<Id, Bundle__c>([SELECT ID, Name FROM Bundle__c WHERE ID IN : setBundlesIds]);
                
            //Loop through new opportunity records
            for(Opportunity newOpp : newOpportunities) {
                if(newOpp.Bundle__c != null && mapBundles.get(newOpp.Bundle__c) != null) {
                    newOpp.BundleName__c = mapBundles.get(newOpp.Bundle__c).Name;
                } else {
                    newOpp.BundleName__c = null;
                }
            }
        }        
    } 
    
    //Added by Abhinav Sharma - 09/15/2014 - CR-20140429-5272
    /**
    *  @description    :   Method to perform Roll Up Summary type calculation on children opportunities and then to populate corresponding fields on "Bundled Opportunity"
    *                      record with corresponding values.
    * 
    *  @args           :   List of opportunities, Map of old Opportunities
    * 
    *  @return         :   void
    * 
    **/ 
    public static void rollUpSummaryFieldValuesOnBundleOpp(List<Opportunity> newOpportunities, Map<Id, Opportunity> mapOldOpportunities) {

        //Map of Bundles
        Map<Id, Bundle__c> mapBundle = new Map<Id, Bundle__c>();
        
        //Loop through opportunity records
        for(Opportunity opp : newOpportunities != null ? newOpportunities : mapOldOpportunities.values()) {

            //Checking for the Insert request
            if(mapOldOpportunities == null && opp.Bundle__c != null)
                mapBundle.put(opp.Bundle__c, new Bundle__c(Id = opp.Bundle__c, Total_Value__c = 0, Total_Count__c = 0, 
                                                                                Won_Count__c = 0, Won_Value__c = 0, 
                                                                                Lost_Count__c = 0, Lost_Value__c = 0,
                                                                                Open_Count__c = 0, Open_Value__c = 0,
                                                                                Earliest_Close__c = null, Latest_Close__c = null, 
                                                                                Earliest_Stage__c ='', Latest_Stage__c ='',
                                                                                Prorated_Open_Value__c = 0
                                                            ));

            //Checking for the Update request
            else if(mapOldOpportunities != null && newOpportunities != null && (opp.Bundle__c != mapOldOpportunities.get(opp.Id).Bundle__c 
                                                                                || opp.StageName != mapOldOpportunities.get(opp.Id).StageName
                                                                                || opp.Amount != mapOldOpportunities.get(opp.Id).Amount
                                                                                || opp.CloseDate != mapOldOpportunities.get(opp.Id).CloseDate
                                                                                || opp.Prorated_Proposal_Value__c != mapOldOpportunities.get(opp.Id).Prorated_Proposal_Value__c
                                                                                )) {

                //Checking lookup field value for null value
                if(opp.Bundle__c != null)
                    mapBundle.put(opp.Bundle__c, new Bundle__c(Id = opp.Bundle__c, Total_Value__c = 0, Total_Count__c = 0, 
                                                                                Won_Count__c = 0, Won_Value__c = 0, 
                                                                                Lost_Count__c = 0, Lost_Value__c = 0,
                                                                                Open_Count__c = 0, Open_Value__c = 0,
                                                                                Earliest_Close__c = null, Latest_Close__c = null, 
                                                                                Earliest_Stage__c ='', Latest_Stage__c ='',
                                                                                Prorated_Open_Value__c = 0
                                                            ));
                    
                //Checking for the old opportunity
                if(mapOldOpportunities.get(opp.Id) != null && mapOldOpportunities.get(opp.Id).Bundle__c != null)
                    mapBundle.put(mapOldOpportunities.get(opp.Id).Bundle__c, new Bundle__c(Id = mapOldOpportunities.get(opp.Id).Bundle__c, 
                                                                                            Total_Value__c = 0, Total_Count__c = 0, 
                                                                                            Won_Count__c = 0, Won_Value__c = 0, 
                                                                                            Lost_Count__c = 0, Lost_Value__c = 0,
                                                                                            Open_Count__c = 0, Open_Value__c = 0,
                                                                                            Earliest_Close__c = null, Latest_Close__c = null, 
                                                                                            Earliest_Stage__c ='', Latest_Stage__c ='',
                                                                                            Prorated_Open_Value__c = 0
                                                            ));
            }

            //Checking for the delete case
            if(newOpportunities == null && mapOldOpportunities != null && mapOldOpportunities.get(opp.Id) != null && mapOldOpportunities.get(opp.Id).Bundle__c != null)
                mapBundle.put(mapOldOpportunities.get(opp.Id).Bundle__c, new Bundle__c(Id = mapOldOpportunities.get(opp.Id).Bundle__c, 
                                                                                            Total_Value__c = 0, Total_Count__c = 0, 
                                                                                            Won_Count__c = 0, Won_Value__c = 0, 
                                                                                            Lost_Count__c = 0, Lost_Value__c = 0,
                                                                                            Open_Count__c = 0, Open_Value__c = 0,
                                                                                            Earliest_Close__c = null, Latest_Close__c = null, 
                                                                                            Earliest_Stage__c ='', Latest_Stage__c ='',
                                                                                            Prorated_Open_Value__c = 0
                                                            ));
        }
        
        //Calling method to do the calculations
        performRollUpSummary(mapBundle);
    }
    
    public static void performRollUpSummary(Map<Id, Bundle__c> mapBundles) {
    
        //Set to hold the opportunity standard picklist field "Stage" values
        Map<String, Integer> mapOfStages = MassCreateBundleOppUtility.mapOpportunityStages();
        
        //Set to hold the opportunity standard picklist field "Stage" values is of "Closed Won" type
        Set<String> setClosedWonStatus = MassCreateBundleOppConstants.setClosedWonStatus;
        
        //Set to hold the opportunity standard picklist field "Stage" values is of "Open" type
        Set<String> setOpenStatus = MassCreateBundleOppConstants.setOpenStatus;
        
        //Set to hold the opportunity standard picklist field "Stage" values is of "Closed Lost" type
        Set<String> setCloseLostStatus = MassCreateBundleOppConstants.setClosedLostStatus;
        
        //Checking for size value
        if(mapOfStages != null && mapBundles != null && mapBundles.keySet().size() > 0 && mapOfStages.keySet().size() > 0) {
        
            //Performing aggregation/Roll up summary calculations over opportunity records associated with the bundles
            for(AggregateResult aR : [Select Bundle__c b, StageName s, Count(Id) cnt, SUM(Amount) amt, SUM(Prorated_Proposal_Value__c) proposalAmt,
                                        MIN(CloseDate) earliestCloseDate, MAX(CloseDate) latestCloseDate FROM Opportunity 
                                        WHERE Bundle__c IN : mapBundles.keySet() AND StageName IN : mapOfStages.keySet()
                                        GROUP BY ROLLUP (Bundle__c, StageName)]) {
                
                //Checking and validating AggregateResult attributes values
                if(String.isNotBlank(String.valueof(aR.get('b')))) {
    
                    //Retrieving attributes values from the aggregated result instance
                    Id bundleId = Id.valueOf(String.valueof(aR.get('b')));
                    
                    //Checking statgeName field value for null/blank
                    if(String.isNotBlank(String.valueOf(aR.get('s'))) && mapBundles.get(bundleId) != null) {
                        
                        //Opportunity with StageName = Closed Won (Close Won Type)
                        if(setClosedWonStatus != null && setClosedWonStatus.size() > 0 && setClosedWonStatus.contains(String.valueOf(aR.get('s')))) {
                            
                            //Count all related opportunities with StageName = Closed Won
                            mapBundles.get(bundleId).Won_Count__c += Integer.valueOf(aR.get('cnt'));
                            
                            //Sum the Amount field on all related opportunities with StageName  = Closed Won
                            if(String.isNotBlank(String.valueOf(aR.get('amt'))))
                                mapBundles.get(bundleId).Won_Value__c += Decimal.valueOf(String.valueOf(aR.get('amt')));
                        }
                        
                        //Opportunity with StageName = Closed Lost (Close Lost Type)
                        if(setCloseLostStatus != null && setCloseLostStatus.size() > 0 && setCloseLostStatus.contains(String.valueOf(aR.get('s')))) {
                            
                            //Count all related opportunities with StageName = Closed Won
                            mapBundles.get(bundleId).Lost_Count__c += Integer.valueOf(aR.get('cnt'));
                            
                            //Sum the Amount field on all related opportunities with StageName  = Closed Won
                            if(String.isNotBlank(String.valueOf(aR.get('amt'))))
                                mapBundles.get(bundleId).Lost_Value__c += Decimal.valueOf(String.valueOf(aR.get('amt')));
                        }
                                  
                        //Opportunity with Opportunity.Closed = False (Open Type)
                        if(setOpenStatus != null && setOpenStatus.size() > 0 && setOpenStatus.contains(String.valueOf(aR.get('s')))) {
                            
                            //Count of all related opportunities with Opportunity.Closed = False (Open Type)
                            mapBundles.get(bundleId).Open_Count__c += Integer.valueOf(aR.get('cnt'));
                            
                            //Sum the Amount field on all related opportunities with Opportunity.Closed = False (Open Type)
                            if(String.isNotBlank(String.valueOf(aR.get('amt'))))
                                mapBundles.get(bundleId).Open_Value__c += Decimal.valueOf(String.valueOf(aR.get('amt')));
                                
                            //Sum the Prorated_Proposal_Value__c field on all related opportunities with Opportunity.Closed = False (Open Type)
                            if(String.isNotBlank(String.valueOf(aR.get('proposalAmt'))))
                                mapBundles.get(bundleId).Prorated_Open_Value__c += Decimal.valueOf(String.valueOf(aR.get('proposalAmt')));
                                   
                        }
                            
                        //Count all related opportunities.
                        mapBundles.get(bundleId).Total_Count__c += Integer.valueOf(aR.get('cnt'));
    
                        //Sum the Amount field on all related opportunities.
                        if(String.isNotBlank(String.valueOf(aR.get('amt'))))
                            mapBundles.get(bundleId).Total_Value__c += Decimal.valueOf(String.valueOf(aR.get('amt')));
                        
                        //Checking "Earliest Close Date" for null/blank value
                        if(String.isNotBlank(String.valueOf(aR.get('earliestCloseDate')))) {
                            
                            //Checking corresponding for null/blank value
                            if(mapBundles.get(bundleId).Earliest_Close__c == null) { 
                                
                                //Close Date from the Smallest/Earliest related opportunities.
                                mapBundles.get(bundleId).Earliest_Close__c = Date.valueOf(String.valueOf(aR.get('earliestCloseDate')));
                            
                            } else {
                                
                                //Comparing dates to make ensure that only earliest date opportunities field values will be set for bundle
                                if(mapBundles.get(bundleId).Earliest_Close__c > Date.valueOf(String.valueOf(aR.get('earliestCloseDate')))) {
                                    
                                    //Close Date from the Smallest/Earliest related opportunities.
                                    mapBundles.get(bundleId).Earliest_Close__c = Date.valueOf(String.valueOf(aR.get('earliestCloseDate')));
                            
                                }
                            }
                        }
                        
                        //Checking "Latest Close Date" for null/blank value
                        if(String.isNotBlank(String.valueOf(aR.get('latestCloseDate')))) {
    
                            //Largest/Latest Close date on the related opportunities.
                            if(mapBundles.get(bundleId).Latest_Close__c == null) {
                                
                                //Populating "Latest Close" field with the latest close date value
                                mapBundles.get(bundleId).Latest_Close__c = Date.valueOf(String.valueOf(aR.get('latestCloseDate')));
                        
                            } else {
                                
                                //Comparing dates to make ensure that only latest date opportunities field values will be set for bundle
                                if(mapBundles.get(bundleId).Latest_Close__c < Date.valueOf(String.valueOf(aR.get('latestCloseDate')))) {
                                
                                    //Populating "Latest Close" field with the latest close date value
                                    mapBundles.get(bundleId).Latest_Close__c = Date.valueOf(String.valueOf(aR.get('latestCloseDate')));
                                }
                            }
                        }
    
                        //Checking "Earliest Stage" field for null/blank value
                        if(mapBundles.get(bundleId).Earliest_Stage__c == '') {
                            
                            //Populating "Earliest Stage" field with the corresponding stage value
                            if(mapOfStages.get(String.valueOf(aR.get('s'))) != null)
                                mapBundles.get(bundleId).Earliest_Stage__c = String.valueOf(aR.get('s'));
                        } else {
                            
                            //Comparing stages for ordering to make ensure that only earliest stage value will be set for bundle
                            if(mapOfStages.get(mapBundles.get(bundleId).Earliest_Stage__c) != null
                                && mapOfStages.get(String.valueOf(aR.get('s'))) != null) {
                                
                                //Populating "Earliest Stage" field with the latest close date value
                                if(mapOfStages.get(mapBundles.get(bundleId).Earliest_Stage__c) > mapOfStages.get(String.valueOf(aR.get('s'))))
                                    mapBundles.get(bundleId).Earliest_Stage__c = String.valueOf(aR.get('s'));
                            }   
                        }
    
                        //Checking "Latest Stage" field for null/blank value
                        if(mapBundles.get(bundleId).Latest_Stage__c == '') {
                            
                            //Populating "Latest Stage" field with the corresponding stage value
                            if(mapOfStages.get(String.valueOf(aR.get('s'))) != null)
                                mapBundles.get(bundleId).Latest_Stage__c = String.valueOf(aR.get('s'));
                        } else {
                            
                            //Comparing stages for ordering to make ensure that only latest stage value will be set for bundle
                            if(mapOfStages.get(mapBundles.get(bundleId).Latest_Stage__c) != null
                                && mapOfStages.get(String.valueOf(aR.get('s'))) != null) {
                                //Populating "Latest Stage" field with the latest close date value
                                if(mapOfStages.get(mapBundles.get(bundleId).Latest_Stage__c) < mapOfStages.get(String.valueOf(aR.get('s'))))
                                    mapBundles.get(bundleId).Latest_Stage__c = String.valueOf(aR.get('s'));
                            }   
                        }
                    }
                }
            }
        }    
        
        //Checking list for its size value and updating field values on Bundle records
        if(mapBundles.values().size() > 0) {
            Util.ByPassAllTriggers = true;
            update mapBundles.values();
            Util.ByPassAllTriggers = false;
        }
    }
    
    //Added By - Abhinav Sharma - 09/15/2014 - CR-20140429-5272
    /**
    *  @description    :   Method responsible for managing of (insertion/Updation/Deletion) of the Bundled Siblings corresponding to the Bundled Opportunities.
    * 
    *  @args           :   List of opportunities, Map of old Opportunities
    * 
    *  @return         :   void
    * 
    **/ 
    public static void manageBundledOppSiblings(List<Opportunity> newOpportunities, Map<Id, Opportunity> mapOldOpportunities) {
            
        //Set to hold the Bundles Id
        Set<Id> setBundle = new Set<Id>();
            
        //Loop through opportunity records
        for(Opportunity opp : newOpportunities != null ? newOpportunities : mapOldOpportunities.values()) {
            
            //Checking for the Insert request
            if(mapOldOpportunities == null && opp.Bundle__c != null)
                setBundle.add(opp.Bundle__c);
            
            //Checking for the Update request
            else if(mapOldOpportunities != null && newOpportunities != null 
                && (opp.Bundle__c != mapOldOpportunities.get(opp.Id).Bundle__c)) {
    
                //Checking lookup field value for null
                if(opp.Bundle__c != null)
                    setBundle.add(opp.Bundle__c);
                    
                //Checking for the old opportunity
                if(mapOldOpportunities.get(opp.Id) != null && mapOldOpportunities.get(opp.Id).Bundle__c != null)
                    setBundle.add(mapOldOpportunities.get(opp.Id).Bundle__c);
            }
            
            //Checking for the delete case
            if(newOpportunities == null && mapOldOpportunities != null 
                    && mapOldOpportunities.get(opp.Id) != null && mapOldOpportunities.get(opp.Id).Bundle__c != null)
                setBundle.add(mapOldOpportunities.get(opp.Id).Bundle__c);
        }
        
        //Managing Siblings
        manageSiblings(setBundle);
    }
    
    public static void manageSiblings(Set<Id> setBundles) {
         
        //Map to hold the Bundle Id as key and associated list of opportunities as value
        Map<Id, List<Opportunity>> mapBundleIdWithOpportunities = new Map<Id, List<Opportunity>>();
        
        //List of Opportunities
        List<Opportunity> listOpportunities = new List<Opportunity>();
        
        //Checking set for size value
        if(setBundles.size() > 0) {
        
            //Querying for the related records
            for(Opportunity opp : [Select ID, Bundle__c FROM Opportunity WHERE Bundle__c != null AND Bundle__c IN : setBundles]) {
                
                //Check if map key contains the key value and get the Values of the Map and add Id to it.
                if(mapBundleIdWithOpportunities.containsKey(opp.Bundle__c))
                    mapBundleIdWithOpportunities.get(opp.Bundle__c).add(opp);
                else
                    mapBundleIdWithOpportunities.put(opp.Bundle__c, new List<Opportunity>{opp}); 
                  
                //Populating list with opportunity records  
                listOpportunities.add(opp); 
            }
        
            //Map of Sibling Opportunities
            Map<String, List<Opportunity>> mapSiblingsOpportunities = new Map<String, List<Opportunity>>();
            
            //Loop through opportunity records
            for(Opportunity op : listOpportunities) {
                //Checking for Bundle existence
                if(op.Bundle__c != null) {
                    //Sibling records will only be there in case we are having multiple bundled opportunities associated to a Bundle
                    if(mapBundleIdWithOpportunities.get(op.Bundle__c) != null && mapBundleIdWithOpportunities.get(op.Bundle__c).size() > 1) {
                        //Loop through Bundled Opportunities associated to Bundle are in current context 
                        //Accordingly populating the map
                        for(Opportunity o : mapBundleIdWithOpportunities.get(op.Bundle__c)) {
                            if(o.Id == op.Id) {
                                continue;
                            } else {
                                //Check if map key contains the key value and get the Values of the Map and add Id to it.
                                if(mapSiblingsOpportunities.containsKey(op.Id + '-' + op.Bundle__c))
                                    mapSiblingsOpportunities.get(op.Id + '-' + op.Bundle__c).add(o);
                                else
                                    mapSiblingsOpportunities.put(op.Id + '-' + op.Bundle__c, new List<Opportunity>{o}); 
                            }
                        }
                    } 
                }
            }
    
            //List to hold the Bundle Siblings records will be inserted
            List<Bundled_Siblings__c> listSiblings = new List<Bundled_Siblings__c>();
            
            //Loop through map keys and adding Bundle Siblings into the list
            for(String key : mapSiblingsOpportunities.keySet()) {
                String oppId = key.split('-')[0];
                String bundleId = key.split('-')[1];
                for(Opportunity ops : mapSiblingsOpportunities.get(key)) {
                    Bundled_Siblings__c bS = new Bundled_Siblings__c();
                    bS.Bundle__c = ID.valueOf(bundleId);
                    bS.From__c = ID.valueOf(oppId);
                    bS.To__c = ops.Id;
                    listSiblings.add(bS);
                }
            }
            
            //Quering the pre-existing Bundle Siblings associated with Bundle parent records
            List<Bundled_Siblings__c> listSiblingsToBeDelete = [Select ID FROM Bundled_Siblings__c 
                                                                        WHERE Bundle__c != null AND Bundle__c IN : setBundles];
            
            //Make a try to delete existing Bundle Siblings
            if(listSiblingsToBeDelete != null && listSiblingsToBeDelete.size() > 0) {
                Util.byPassAllTriggers = true;
                delete listSiblingsToBeDelete;
                Util.byPassAllTriggers = false;       
            }
                
            //Inserting Siblings records with new combination
            if(listSiblings.size() > 0) {
                Util.byPassAllTriggers = true;
                insert listSiblings;
                Util.byPassAllTriggers = false;
            }
        }        
    }
     
    //Added By - Abhinav Sharma - 09-17-2014 - CR-20140429-5272
    /**
    *  Description    :    Method to populate Account field on the Bundle Opportunity with the value from the "Account" field on 
    *                      the associated child Opportunity records whenever the associated Opportunity record is inserted/updated.
    *
    *  Arguments      :    List of Opportunity , Map of old Opportunity 
    *
    *  Return Type    :   void
    *
    **/
    public static void populateAccountOnBundleOpportunity(List<Opportunity> newOpps, Map<Id, Opportunity> mapOldOpps) {
     
        //List to hold the current Context Opportunity records
        List<Opportunity> listOpp = newOpps != null ? newOpps: mapOldOpps.values();
         
        //Map to hold the "Bundle" records to update
        Map<Id, Bundle__c> mapBundleOpps = new Map<Id, Bundle__c>();
           
        //Loop through Opportunity records and populating map with parent Bundle records Id value
        for(Opportunity opp: [SELECT Id, AccountId, Bundle__c, Bundle__r.Account__c FROM Opportunity
                               WHERE Bundle__c != null AND Bundle__r.Account__c = null AND Id IN : listOpp 
                                   AND AccountId != null ORDER By CloseDate DESC]) {
              
             //Checking for parent Bundle Id value and Populate map with appropiate values;
             if(!mapBundleOpps.containsKey(opp.Bundle__c))
                mapBundleOpps.put(opp.Bundle__c, new Bundle__c (Id = opp.Bundle__c, Account__c = opp.AccountId));
        }
       
        //Checking map for size value
        if(mapBundleOpps.size() > 0) {
            Util.byPassAllTriggers = true;
            //Updating map of Bundle records
            update mapBundleOpps.values();
            Util.byPassAllTriggers = false;
            
        }
    }    
    
    //Added By - Abhinav Sharma - 08/28/2015 - CR-20140613-5790
    /**
     *  @description    :   Method to populate "Opportunity Initial PA Date" and "Initial Activity Date" fields on "Warm "
     *
     *  @args           :   Set<Id> setWarmLeadIds
     *
     *  @return         :   void
     *
    **/
    public static void populatePAsAndActivityFieldsOnWarmLeadMTMs(List<Opportunity> newOpportunities, Map<Id, Opportunity> mapOldOpportunities) {
        
        //Set to hold the opportunity Ids
        Set<Id> setOpportunities = new Set<Id>();
        
        //Loop through opportunity records
        for(Opportunity opp : newOpportunities) {
            
            if(mapOldOpportunities != null 
                && (
                    mapOldOpportunities.get(opp.Id).Initial_PA_Date__c != opp.Initial_PA_Date__c
                    ||
                    mapOldOpportunities.get(opp.Id).Initial_Activity_Date__c != opp.Initial_Activity_Date__c
                )
            ) {
                setOpportunities.add(opp.Id);        
            }
        } 
        
        //Map to hold the opportunity Id with with list of Warm Lead MTMs
        Map<Id, List<Warm_Lead_MtM__c>> mapWarmLeadMTMs = new Map<Id, List<Warm_Lead_MtM__c>>();
        
        //Map of warm Lead Mtms
        Map<id, Warm_Lead_MtM__c> mapWLMtms = new Map<id, Warm_Lead_MtM__c>();
        
        //Added by VH - 10/09/2015 - CR-20151009-9309
        if (setOpportunities.size() > 0) {
        
            //Loop through warm lead MTm records records associated to opportunity record and populating set accordingly
            for(Warm_Lead_MtM__c wlm : [SELECT ID, Opportunity__c, Opportunity_Initial_PA__c, Opportunity_Initial_Activity__c
                                        FROM Warm_Lead_MtM__c
                                        WHERE Opportunity__c != null 
                                        AND Opportunity__c IN : setOpportunities]) {
                
                //Checking for key in map                            
                if(mapWarmLeadMTMs.containsKey(wlm.Opportunity__c)) {  
                    
                    //Get the Values of the Map and add Id to it.  
                    mapWarmLeadMTMs.get(wlm.Opportunity__c).add(wlm);  
                    
                } else {  
                    
                    //Creat a new Set at values and add Id to it.  
                    mapWarmLeadMTMs.put(wlm.Opportunity__c, new List<Warm_Lead_MtM__c>{wlm});           
                }
            }
            
            //Loop through opportunity records
            for(Opportunity op : newOpportunities) {
                
                //Checking for key in map and if exist getting associated Warm lead MTMs
                if(mapWarmLeadMTMs.containsKey(op.id) && mapWarmLeadMTMs.get(op.id) != null
                   && mapWarmLeadMTMs.get(op.id).size() > 0) {
                       
                       //Loop through warm lead MTm records and populating fields values on them from Opportunity
                       for(Warm_Lead_MtM__c wlms : mapWarmLeadMTMs.get(op.id)) {
                           wlms.Opportunity_Initial_PA__c = op.Initial_PA_Date__c;  
                           wlms.Opportunity_Initial_Activity__c = op.Initial_Activity_Date__c;    
                           mapWLMtms.put(wlms.Id, wlms);
                       }            
                   }
            }
        }   
        
        //Intentionally not by passing triggers
        //Checking map for values
        if(mapWLMtms.values().size() > 0)
            update mapWLMtms.values();
    }
    
    /**
     *  @description    :   This method is used to update Program Opportunities according to Parent Opportunity 
     *
     *  @args           :   List<Opportunity>, Map<Id, Opportunity>
     *
     *  @return         :   void
     *
     *  @revision Log   :   V_1.0 - Created - Subhash Garhwal - CR-20160414-9762
     *
     **/
    public static void validateProgramOpportunities(List<Opportunity> newOpportunities, Map<Id, Opportunity> mapOldOpportunities) {
        
        //Set to hold the Parent Opportunities Id
        Set<Id> setParentOppIds = new Set<Id>();
        
        //Loop through the new Opportunity records
        for(Opportunity opp : newOpportunities) {
            
            //Check appropriate condition to execute trigger logic
            if(opp.Parent_Opportunity__c == null && (opp.AccountId != mapOldOpportunities.get(opp.Id).AccountId || opp.Closedate != mapOldOpportunities.get(opp.Id).Closedate)) {
                
                //Add Opportunity Id in set
                setParentOppIds.add(opp.Id);        
            }
        }
        
        //Check for set size
        if(setParentOppIds.size() > 0) {
            
            //List to update the Program Opportunities (Children Opps)
            List<Opportunity> programOpportunities = new List<Opportunity>();
            
            //Query through Program Opportunites
            for(Opportunity opp : [Select Id, AccountId, Closedate, Parent_Opportunity__c, Parent_Opportunity__r.AccountId,
                                          Parent_Opportunity__r.Closedate From Opportunity Where Parent_Opportunity__c IN : setParentOppIds
                                          AND Parent_Opportunity__r.RecordType.DeveloperName =: CPQConstants.OPPORTUNITY_RECORD_TYPE_DEVELOPERNAME_CONTRACT_LOA]) {
                
                //Update Record
                opp.AccountId = opp.Parent_Opportunity__r.AccountId;
                opp.Closedate = opp.Parent_Opportunity__r.Closedate;
                
                //Add reocrd in list
                programOpportunities.add(opp);                              
            }
            
            //Check list size and update record
            if(programOpportunities.size() > 0)
                update programOpportunities;
        }       
    }
    
    /**
     *  @description    :   This method is used to check the duplicate Program Opportunity on Same Parent Opportunity
     *                      Criteria form WORK ORDER :  Parent Opportunity on existing record EQUALS Parent Opportunity on new record
     *                                                  AND
     *                                                  Program__c on existing record EQUALS Program__c on new record
     *                                                  AND
     *                                                  Existing record is in a stage not equal to Closed Won, Closed Lost
     *                                                  AND
     *                                                  Admin Override = False
     *                                                  
     *                      Error MEG from WORK ORDER : There is an existing Program Opportunity already existing which meets the same criteria
     *                                                  as the one you are creating. Please use that record instead.
     *                                                  Record URL: (enter existing URL here so the user can click on it)                                               
     *      
     *
     *  @args           :   List<Opportunity>, Map<Id, Opportunity>
     *
     *  @return         :   void
     *
     *  @revision Log   :   V_1.0 - Created - Subhash Garhwal - CR-20160414-9762
     *
     **/
    public static void PreventManualDuplicateProgramOpportunities(List<Opportunity> newOpportunities, Map<Id, Opportunity> mapOldOpportunities) {
        
        //Set to hold the Parent Opportunity Id
        Set<Id> setParentOppIds = new Set<Id>();
        
        //Set to hold the Program Id
        Set<Id> setProgramIds = new Set<Id>();
        
        //Set to hold the Unique Identifier (Parent Opportunity + Program)
        Set<String> setProgramOppIdentifier = new Set<String>();
        
        //Set to hold the Program Opportunity Record Types
        Set<Id> setProgramOppRecordTypes = new Set<Id>();
        
        //Get Opportunity Record types
        Map<String, Id> rtmap = Util.recordtypemap('Opportunity');
        
        //Set to hold the Opportunity Ids
        Set<Id> setNewOppIds = new Set<Id>(); 
        
        //Loop over the Record Type Name and populate set
        for(String pORTName : CPQConstants.SET_OPPORTUNITY_CPQ_PROGRAM_OPP_RT_NAME) {
            
            //Check for Record Type Id
            if(rtmap.get(pORTName) != null)
                setProgramOppRecordTypes.add(rtmap.get(pORTName));  
        }
        
        //Loop over the Opportunities
        for(Opportunity opp : newOpportunities) {
            
            //Check for Opportunity Record Type
            if(opp.RecordTypeId != null && setProgramOppRecordTypes.contains(opp.RecordTypeId)) {
                
                //Check for appropriate condition
                if(opp.Program__c != null && opp.Parent_Opportunity__c != null && !opp.Admin_Override__c
                    && opp.StageName != CPQConstants.OPPORTUNITY_STAGE_CLOSED_WON && opp.StageName != CPQConstants.OPPORTUNITY_STAGE_CLOSED_LOST
                    && (mapOldOpportunities == null || opp.Admin_Override__c != mapOldOpportunities.get(opp.Id).Admin_Override__c
                        || opp.Program__c != mapOldOpportunities.get(opp.Id).Program__c || opp.Parent_Opportunity__c != mapOldOpportunities.get(opp.Id).Parent_Opportunity__c
                        || opp.StageName != mapOldOpportunities.get(opp.Id).StageName)) {
                    
                    //Add Opp Id in set
                    if(opp.Id != null)
                        setNewOppIds.add(opp.Id);
                        
                    //Create unique Identifier
                    String uK = opp.Parent_Opportunity__c + '-' + opp.Program__c;
                    
                    //Check unique Key in set
                    if(setProgramOppIdentifier.contains(uK))
                        throw new CustomException(CPQConstants.PROGRAM_OPPORTUNITY_DUPLICATE_ERROR_MESG);   
                    
                    //Add Unique Key in set
                    setProgramOppIdentifier.add(uK);
                    
                    //Add Parent Opportunity Id in set
                    setParentOppIds.add(opp.Parent_Opportunity__c);
                    
                    //Add Program Id in set
                    setProgramIds.add(opp.Program__c);
                } 
            }
        }
        
        //Check set size
        if(setProgramOppIdentifier.size() > 0) {
            
            //Query through existing record
            for(Opportunity opp : [Select Id, Name, Parent_Opportunity__c, Program__c, StageName, Admin_Override__c From Opportunity
                                   Where Parent_Opportunity__c IN : setParentOppIds AND Program__c IN : setProgramIds
                                   AND RecordTypeId IN : setProgramOppRecordTypes AND Id NOT IN : setNewOppIds
                                   AND Admin_Override__c = false AND StageName !=: CPQConstants.OPPORTUNITY_STAGE_CLOSED_WON
                                   AND Stagename !=: CPQConstants.OPPORTUNITY_STAGE_CLOSED_LOST]) {
                
                
                //Unique Identitier
                String uK = opp.Parent_Opportunity__c + '-' + opp.Program__c;
                
                //Check unique identitier in Set
                if(setProgramOppIdentifier.contains(uK))
                    throw new CustomException(CPQConstants.PROGRAM_OPPORTUNITY_DUPLICATE_ERROR_MESG);   
            }
        }
    }
    
    /**
     *  @description    :   This method is used to populate the renewal field values according to Original Opportunity
     *                      Criteria form WORK ORDER :  
     *
     *  @args           :   List<Opportunity>
     *
     *  @return         :   void
     *
     *  @revision Log   :   V_1.0 - Created - Subhash Garhwal - CR-20160414-9762
     *
     **/
    public static void syncRenewalOpp(List<Opportunity> newOpportunities) {
        
        //Set to hold the Contract Ids
        Set<Id> setContractIds = new Set<Id>();
        
        //Loop over the opportunities
        for(Opportunity opp : newOpportunities) {
            
            //Check for renewal opp
            if(opp.SBQQ__Renewal__c && opp.SBQQ__RenewedContract__c != null && !opp.SBQQ__Contracted__c)
                setContractIds.add(opp.SBQQ__RenewedContract__c);   
        }
        
        //Check for set size
        if(setContractIds.size() > 0) {
            
            //Map to hold the COntracts with all the related details
            Map<Id, Contract> mapContracts = new Map<Id, Contract>([Select Id, EndDate, SBQQ__Opportunity__c, SBQQ__Opportunity__r.OwnerId, SBQQ__Opportunity__r.Owner.IsActive, SBQQ__Opportunity__r.Opportunity_Nickname__c,
                                                                            SBQQ__Opportunity__r.RecordTypeId From Contract Where Id IN : setContractIds
                                                                            AND SBQQ__Opportunity__r.RecordType.DeveloperName =: CPQConstants.OPPORTUNITY_RECORD_TYPE_DEVELOPERNAME_CONTRACT_LOA]);
            
            //Loop over the opportunities
            for(Opportunity opp : newOpportunities) {
                
                //Check for renewal opp
                if(opp.SBQQ__Renewal__c && opp.SBQQ__RenewedContract__c != null && !opp.SBQQ__Contracted__c && mapContracts.containsKey(opp.SBQQ__RenewedContract__c)) {
                    
                    //Update Renewal Opp fields
                    opp.Opportunity_Nickname__c = mapContracts.get(opp.SBQQ__RenewedContract__c).SBQQ__Opportunity__r.Opportunity_Nickname__c;
                    opp.OwnerId = mapContracts.get(opp.SBQQ__RenewedContract__c).SBQQ__Opportunity__r.Owner.IsActive ? mapContracts.get(opp.SBQQ__RenewedContract__c).SBQQ__Opportunity__r.OwnerId : UserInfo.getUserId();
                    opp.StageName = CPQConstants.OPPORTUNITY_STAGE_ON_DECK;
                    opp.Type = CPQConstants.OPPORTUNITY_TYPE_CONTRACT_RENEWAL_OPPORTUNITY;
                    opp.CloseDate = mapContracts.get(opp.SBQQ__RenewedContract__c).EndDate;
                    opp.Calculated_Close_Date__c = opp.CloseDate;
                    opp.RecordTypeId = mapContracts.get(opp.SBQQ__RenewedContract__c).SBQQ__Opportunity__r.RecordTypeId;
                    
                    //Set flag to false to stop the Quote Line trigger execution
                    SBQQ_QuoteLineTriggerHelper.executeSyncProgramOpportunitiesLogic = false;
                    SBQQ_QuoteTriggerHelper.executeUpdateContractLOAStageLogic = false;
                }
            }
        }
    }
    
    /**
     *  @description    :   This method is used to Create Integrated accounts for renewal opps
     *                      Criteria form WORK ORDER :  Create Integrated Accounts records from original Opportunity:
     *                      If any Integrated Account records are linked to the original Contract Opp, clone the records
     *                      and link them to the newly created Contract Opp for the Renewal
     *
     *  @args           :   List<Opportunity>
     *
     *  @return         :   void
     *
     *  @revision Log   :   V_1.0 - Created - Subhash Garhwal - CR-20160414-9762
     *
     **/
    public static void createIntegratedAccountForRenewalOpps(List<Opportunity> newOpportunities) {
        
        //Map to hold the Renewal Opps with Contract Id
        Map<Id, Opportunity> mapContIdWithRenewalOpp = new Map<Id, Opportunity>();
        
        //Loop over the opportunities
        for(Opportunity opp : newOpportunities) {
            
            //Check for renewal opp
            if(opp.SBQQ__Renewal__c && opp.SBQQ__RenewedContract__c != null && !opp.SBQQ__Contracted__c) {
                
                //Add values in map
                mapContIdWithRenewalOpp.put(opp.SBQQ__RenewedContract__c, opp);
            }
        }
        
        //Check for set size
        if(mapContIdWithRenewalOpp.size() > 0) {
            
            //Map to hold the Original OppIds with Related RenewalOpp
            Map<Id, Opportunity> mapOriginalOppIdWithRenewalOpp = new Map<Id, Opportunity>();
            
            //Query through Contract
            for(Contract cont : [Select Id, SBQQ__Opportunity__c From Contract Where Id IN : mapContIdWithRenewalOpp.keySet()
                                        AND SBQQ__Opportunity__r.RecordType.DeveloperName =: CPQConstants.OPPORTUNITY_RECORD_TYPE_DEVELOPERNAME_CONTRACT_LOA]) {
                
                //Add Rnewal Opps in map
                mapOriginalOppIdWithRenewalOpp.put(cont.SBQQ__Opportunity__c,mapContIdWithRenewalOpp.get(cont.Id)); 
                
            }
            
            //Check for map size
            if(mapOriginalOppIdWithRenewalOpp.size() > 0) {
                
                //Set to hold the Original Opp Ids
                Set<Id> setOriginalOppIds = mapOriginalOppIdWithRenewalOpp.keySet();
                
                //Global describe
                Map<String, Schema.SObjectType> globalDescribe = Schema.getGlobalDescribe();
                
                //Query through the Integrated_Account__c
                List<Integrated_Account__c> originalIntegratedAccounts = (List<Integrated_Account__c>)Database.query(CPQUtility.buildSOQL(globalDescribe, 'Integrated_Account__c', '', ' Where Opportunity__c IN : setOriginalOppIds'));
                
                //Check for list size
                if(originalIntegratedAccounts.size() > 0) {
                    
                    //Clone all the records using deepclone method
                    List<Integrated_Account__c> clonedIntegratedAccounts = originalIntegratedAccounts.deepClone(false,true);
                    
                    //Loop over the Integrated_Account__c
                    for(Integer i = 0; i < originalIntegratedAccounts.size(); i++) {
                        
                        //Check Opportunity Id in map
                        if(mapOriginalOppIdWithRenewalOpp.containsKey(originalIntegratedAccounts[i].Opportunity__c))
                            clonedIntegratedAccounts[i].Opportunity__c = mapOriginalOppIdWithRenewalOpp.get(originalIntegratedAccounts[i].Opportunity__c).Id;
                    }
                    
                    //Insert cloned records
                    insert clonedIntegratedAccounts;
                }
            }
        }
    }
    
    /**
     *  @description    :   This method is used to Roll-up the Program Opportunity cound on the Parent Contract LOA opp (Total and Primary both)
     *                      
     *
     *  @args           :   List<Opportunity>, Map<Id, Opportunity>
     *
     *  @return         :   void
     *
     *  @revision Log   :   V_1.0 - Created - Subhash Garhwal - 07/14/2016 - CR-20160414-9762
     *
     **/
    public static void rollupProgramOpps(List<Opportunity> newOpportunities, Map<Id, Opportunity> mapOldOpportunities) {
        
        //Set to hold the Parent Opp Ids
        Set<Id> setParentOppIds = new Set<Id>();
        
        //Loop over the opportunities
        for(Opportunity opp : newOpportunities != null ? newOpportunities : mapOldOpportunities.values()) {
            
            //Insert Case
            if(mapOldOpportunities == null && opp.Parent_Opportunity__c != null)
                setParentOppIds.add(opp.Parent_Opportunity__c);
            
            //Update case
            if(newOpportunities != null && mapOldOpportunities != null && (opp.Program_Proposal_Status__c != mapOldOpportunities.get(opp.Id).Program_Proposal_Status__c
                || opp.Parent_Opportunity__c != mapOldOpportunities.get(opp.Id).Parent_Opportunity__c)) {
                    
                //Add new Parent Opp
                setParentOppIds.add(opp.Parent_Opportunity__c);
                
                //Check for old     
                if(mapOldOpportunities.get(opp.Id).Parent_Opportunity__c != null)
                    setParentOppIds.add(mapOldOpportunities.get(opp.Id).Parent_Opportunity__c);
            }
            
            //Delete case   
            if(newOpportunities == null && opp.Parent_Opportunity__c != null)
                setParentOppIds.add(opp.Parent_Opportunity__c);
        }
        
        //Check for Parent Opps size
        if(setParentOppIds.size() > 0) {
            
            //Map to hold the Parent Opportunities
            Map<Id, Opportunity> mapParentOpportunities = new Map<Id, Opportunity>();
            
            //Query through Parent Opps
            for(Opportunity opp : [Select Id From Opportunity Where Id IN : setParentOppIds AND RecordType.DeveloperName =: CPQConstants.OPPORTUNITY_RECORD_TYPE_DEVELOPERNAME_CONTRACT_LOA])
                mapParentOpportunities.put(opp.Id, new Opportunity(Id = opp.Id, Total_Program_Opps__c = 0,Primary_Program_Opps__c = 0));
            
            //Check for map size
            if(mapParentOpportunities.size() > 0) {
                
                //Aggrigate query through Program Opportunities to get Primary Opp count
                for(AggregateResult aR : [Select count(Id) cnt, Parent_Opportunity__c pO From Opportunity Where Parent_Opportunity__c IN : mapParentOpportunities.keySet()
                                                           AND RecordType.DeveloperName IN : CPQConstants.SET_OPPORTUNITY_CPQ_SPECIFIC_PROGRAM_OPP_RT_DEVELOPER_NAME
                                                           AND Program_Proposal_Status__c =: CPQConstants.PROGRAM_PROPOSAL_STATUS_PRIMARY_PROPOSAL
                                                           GROUP BY Parent_Opportunity__c]) {
                    
                    //Convert object to Id
                    Id pOId = Id.valueOf((String) aR.get('pO'));
                    
                    //Check Id in map
                    if(mapParentOpportunities.containsKey(pOId))
                        mapParentOpportunities.get(pOId).Primary_Program_Opps__c = Integer.valueOf(aR.get('cnt'));                                              
                }
                
                //Aggrigate query through Program Opportunities to get total Opp count
                for(AggregateResult aR : [Select count(Id) cnt, Parent_Opportunity__c pO From Opportunity Where Parent_Opportunity__c IN : mapParentOpportunities.keySet()
                                                           AND RecordType.DeveloperName IN : CPQConstants.SET_OPPORTUNITY_CPQ_SPECIFIC_PROGRAM_OPP_RT_DEVELOPER_NAME
                                                           GROUP BY Parent_Opportunity__c]) {
                    
                    //Convert object to Id
                    Id pOId = Id.valueOf((String) aR.get('pO'));
                    
                    //Check Id in map
                    if(mapParentOpportunities.containsKey(pOId))
                        mapParentOpportunities.get(pOId).Total_Program_Opps__c = Integer.valueOf(aR.get('cnt'));                                                
                }
                
                //By Pass all the trigger
                Util.byPassAllTriggers = true;
                
                //Update Opps
                update mapParentOpportunities.values();
                
                //By Pass all the trigger
                Util.byPassAllTriggers = false;
            }   
        }
    }
}