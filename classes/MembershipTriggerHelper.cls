/*
    Purpose         :   This class is helper class for trigger on Membership object.
                
    Create By       :   Simplyforce Technology
    
    Created Date    :   01/18/2012
    
    Current Version :   v1.0
    
    Revision Log    :   V_1.0 Created
                        V_1.1 New method added  - CR-20111122-239
                        V_1.2 Bhavi - 06/15/2012 - Added new method(deleteKeyMemberContactsForNonMembership) - CR-20120518-905
                        V_1.3 Bhavi - 12/11/2012 - Added new Method(membershipPopulateAssignedMarketer) - CR-20120208-389
                        V_1.4 Bhavi - 11/07/2012 - Added a new Methos(PopulateContactData) - CR-20121019-1641
                        V_1.5 Bhavi - 02/01/2013 - Modified UpdateRelationshipGradeNotes method to execute only when required - CR-20130131-2377
                        V_1.6 Bhavi - 02/02/2013 - CR-20121212-1898
                        V_1.7 Bhavi - 03/28/2013 - Added a new Method(updateRelationshipManagerOnProject) - CR-20121207-1868
                        V_1.8 Victor - 04/23/2013 - Added a new Method(PopulateMostRecentQACall) - CR-20121031-1669
                        V_1.9 Victor - 10/15/2013 - Bypass Triggers in populateContactData - CR-20130416-2879
                        V_2.0 Abhinav Sharma - 02/12/2014 - Refactor the method (membershipPopulateAssignedMarketer) - CR-20130911-3628
                        V_2.1 Bhavi Sharma - 03/18/2014 - Refactor the method (membershipPopulateAssignedMarketer) - removed all Inline queries - CR-20130911-3628 
                        V_2.2 Abhinav Sharma - 04/18/2014 - CR-20140331-4909 - Updates to batch failure process
                        V_2.3 Abhinav Sharma - 09/08/2014 - CR-20140515-5538 - QA Data Lag
                        V_2.4 Bhavi Sharma - 01/19/2015 - CR-20141119-8126 - Update PopulateMostRecentQACall method
                        V_2.5 Ajit Surana - 03/28/2015 - CR-20150312-8758 - Added a new method (populateIndustryMemberOnAccount)
                        V_2.6 Abhinav Sharma - 04/30/2015 - CR-20121218-1964 - Membership name not correct on batch insert
                        V_2.7 Mahendra swarnkar - 07/15/2015 - CR-20150520-8962 - Updated process_membership method
                        V_2.8 - Abhinav Surana - 09/03/2015 - CR-20150205-8660 - Added new method (populateFieldsOnMembershipInBeforeEvent)
                        V_2.9 - Modified By - Abhinav Sharma - 10/17/2015 - CR-20151008-9304 - Triggers repetative execution    
                        V_3.0 - Modified By - Victor Hanson - 02/16/2016 - CR-20160210-9596 - Fixed query row exception
                        V_3.1 - Modified By - Mahendra Swarnakar - 5/11/2016 - CR-20160219-9619 - Updated PopulateMostRecentQACall method to modify to sort the Membership events as per their grades
                        v_3.2 - Modified By - Mahendra Swarnakar - 8/25/2016 - CR-20160725-10063 - Modified StartDateTime Criteria, Use label to get value
                        v_3.3 - Modified By - Mahendra Swarnakar - 8/26/2016 - CR-20160606-9903 - Modified the Method PopulateMostRecentQACall.
                        v_3.4 - Modified By - Mahendra Swarnakar - 09/15/2016 - CR-20160519-9865
*/
public without sharing class MembershipTriggerHelper {
    
    //Flag is control the execution of UpdateRelationshipGradeNotes method
    public static Boolean EXECUTE_UPDATE_RELATIONSHIP_GRADE_NOTES = true;
    
    //Added By - Abhinav Sharma - 09/03/2015 - CR-20150205-8660
    /**
     *  @description    :   Method to populate fields on membership itself from the respective parent corresponding field value.
     *
     *  @args           :   List of new Membership
     *
     *  @return         :   void
     *
    **/
    public static void populateFieldsOnMembershipInBeforeEvent(List<Membership__c> newMemberships) {
        
        //Set of Contracts
        Set<Id> setContracts = new Set<Id>();
        
        //Loop through membership records
        for(Membership__c mem : newMemberships) {
            if(mem.Active_Contract_Idenfied__c != null)
                setContracts.add(mem.Active_Contract_Idenfied__c);
        }
        
        //map of contrats
        Map<Id, Contract__c> mapContracts = new Map<Id, Contract__c>();
        
        //Checking set for size value
        if(setContracts.size() > 0) {
            
            //Map of contracts
            for(Contract__c c : [SELECT ID, Main_Contact__c FROM Contract__c
                                    WHERE ID IN : setContracts]) {
                mapContracts.put(c.Id, c);        
            }
        }    
            
        //Loop through membership records
        for(Membership__c me : newMemberships) {
            if(me.Active_Contract_Idenfied__c != null) {
                if(mapContracts != null 
                    && mapContracts.containsKey(me.Active_Contract_Idenfied__c)
                    && mapContracts.get(me.Active_Contract_Idenfied__c) != null) {
                    me.Active_Contract_Main_Contact__c = mapContracts.get(me.Active_Contract_Idenfied__c).Main_Contact__c;       
                }
            } else {
                me.Active_Contract_Main_Contact__c = null;
            }
        }
    }
    
    //Getter method which return the Map of account field api name as a value with businessline picklist value as a key
    public static Map<String,String> getmapAvailableOutReachAccountsFields() {
        
        Map<String,String> mapAvailableOutReachAccount = new Map<String,String>();
        mapAvailableOutReachAccount.put('TD', 'Academy_Programs_Available_for_Outreach__c');
        mapAvailableOutReachAccount.put('PT', 'BI_Programs_Available_for_Outreach__c');
        mapAvailableOutReachAccount.put('RI', 'Core_Programs_Available_for_Outreach__c');
        
        return mapAvailableOutReachAccount;
    }
    
    //Getter method which return the Map of list of account field api name as a value with businessline picklist value as a key
    public static Map<String,List<String>> getmapBusinessLineAccountsFields() {
        
        Map<String,List<String>> mapBusinessLineAccount = new Map<String,List<String>>();
        mapBusinessLineAccount.put('PT', New List<String>{'Active_PT_Memberships__c', 'Paid_PT_Memberships__c', 'BI_Memberships__c' });
        mapBusinessLineAccount.put('RI', New List<String>{'Active_RI_Memberships__c', 'Paid_RI_Memberships__c', 'Core_Memberships__c'});
        mapBusinessLineAccount.put('TD', New List<String>{'Active_TD_Memberships__c', 'Paid_TD_Memberships__c', 'Academies_Memberships__c'});
        mapBusinessLineAccount.put('CM', New List<String>{'Active_CM_Memberships__c', 'Paid_CM_Memberships__c', 'Hworks_Memberships__c'});
        mapBusinessLineAccount.put('SW', New List<String>{'Active_SW_Memberships__c', 'Paid_SW_Memberships__c'});
        mapBusinessLineAccount.put('CLN', New List<String>{'Active_CLN_Memberships__c', 'Paid_CLN_Memberships__c'});
        return mapBusinessLineAccount;
    }
        
    // this method is to populate the Relationship_Grade_Notes__c from the membership and put them on the associated Opportunity
    public static void UpdateRelationshipGradeNotes(List<Membership__c> memberships) {
        
        //Check if method need to be executed
        if(MembershipTriggerHelper.EXECUTE_UPDATE_RELATIONSHIP_GRADE_NOTES) {
        
            // get all membership Ids
            Set<Id> membershipIds = new Set<Id>();
            for (Membership__c membership : memberships) {
                membershipIds.add(membership.Id);
            }
            
            // list of Opportunities to update
            List<Opportunity> oppsToUpdate = new List<Opportunity>();
            
            //Checking for the set size value
            if(membershipIds.size() > 0) {
            
                //Loop through opportunity records
                for (Opportunity opp : [SELECT Name, Id, Membership__c, Relationship_Grade_Notes__c, Membership__r.Relationship_Grade_Notes__c
                                            FROM Opportunity 
                                            WHERE Membership__c != null AND Membership__c IN :membershipIds]) {
                    
                    //Checking for value change                            
                    if (opp.Relationship_Grade_Notes__c != opp.Membership__r.Relationship_Grade_Notes__c) {
                        opp.Relationship_Grade_Notes__c = opp.Membership__r.Relationship_Grade_Notes__c;
                        oppsToUpdate.add(opp);
                    }
                }
            }    
            
            //Checking list for size value
            if (oppsToUpdate.size() > 0) {
                
                // disable opportunity triggers
                Util.Isbatch = true;
                Util.byPassAllTriggers = true;
                update oppsToUpdate;
                Util.byPassAllTriggers = false;
                Util.Isbatch = false;
            }
        }
    }
    
    //Modified By - Abhinav Sharma - 09/08/2014 - CR-20140515-5538
    //Bhavi Sharma - 01/19/2015 - CR-20141119-8126 - Return void instead of List of membership
    // Take a list of memberships with their associated Events where Cancelled_Did_Not_Occur = false
    // and populates the Most_Recent_QA_Call_* fields with the appropriate info.
    public static void PopulateMostRecentQACall(Set<Id> memIds) {
        
        //Cheching size for null and size value
        if(memIds != null && memIds.size() > 0) {
            
            //Query Memberships associated to events
            //Bhavi - Where class criteria updated to fetch the Membership__c records having StartDateTime less than 60 days
            //Abhinav - Modified Where class criteria updated to fetch the Membersship__c record having StartDateTime less than 90 days
            //Mahendra - 5/11/2016 - CR-20160219-9619 - Modified to sort the Membership events as per their grades
            //Mahendra Swarnkar - 8/25/2016 - CR-20160725-10063 - Modified StartDateTime Criteria, Use label to get value
            //Mahendra Swarnkar - 8/26/2016 - CR-20160606-9903 - Modified Event Type Criteria, to have Event_Type__c = 'RI QA Call' in the query string.
            list<Membership__c> memList = [select id, Most_Recent_QA_Call_Date__c, Most_Recent_QA_Call_Grade__c,
                Reason_for_No_QA_Call__c, Most_Recent_QA_Call_Recommend_Grade__c, Most_Recent_QA_Call_Renew_Grade__c,
                (select StartDateTime, Grade__c, Would_Refer__c, Would_Buy_Again__c, LastModifiedDate, Project_Sponsor_On_Call__c
                from Events  
                    where Cancelled_Did_Not_Occur__c = false 
                        AND StartDateTime < :system.today().addDays(Integer.valueOf(System.Label.POPULATE_MOST_RECENT_QA_CALL_ADD_DAYS)) 
                        AND (Event_Type__c = 'PT QA Call' 
                            OR Event_Type__c = 'CM QA Call'
                            OR Event_Type__c = 'RI QA Call') 
                    ORDER BY StartDateTime desc, Grade__c ASC
                    LIMIT 5)
                from Membership__c
                where id in :memIds];
            
            //loop through membership records
            for (Membership__c mem : memList) {
                //start blank
                mem.Most_Recent_QA_Call_Date__c = null;
                mem.Most_Recent_QA_Call_Grade__c = null;
                
                //Bhavi Sharma - 01/19/2015 - CR-20141119-8126 - Set default values
                mem.Most_Recent_QA_Call_Recommend_Grade__c = null;
                mem.Most_Recent_QA_Call_Renew_Grade__c =null;
                        
                // CR-1669 - find the most recent Event that should count as the Most Recent QA Call
                Event mostRecentQAEvent;
            
                //Checking if size value is greater than 1
                if (mem.Events != null && mem.Events.size() > 0) {
                    
                    // Event[0] is most recent, but we still need to see if other events occur on the same day
                    mostRecentQAEvent = mem.Events[0];
                    Date mostRecentQADate = mem.Events[0].StartDateTime.date();
                
                    //Checking if size value is greater than 1
                    if (mem.Events.size() > 1) {
                    
                        // lists to hold events that need to be compared
                        List<Event> eventsOnSameDate = new List<Event>();
                        List<Event> eventsWithProjSponsor = new List<Event>();
                    
                        // add the most recent qa event to the appropriate list(s)
                        eventsOnSameDate.add(mostRecentQAEvent);
                    
                        if (mostRecentQAEvent.Project_Sponsor_On_Call__c == 'Yes')
                            eventsWithProjSponsor.add(mostRecentQAEvent);
                        
                        //Loop through events
                        for (Event evt : mem.Events) {
                            
                            // if the event occurs on the same date, add to the list to compare later
                            if (evt.Id != mostRecentQAEvent.Id && evt.StartDateTime.date() > mostRecentQADate) {
                                
                                System.debug(' @@@@@ evt.StartDateTime ' + evt.StartDateTime);
                                System.debug(' @@@@@ mostRecentQADate ' + mostRecentQADate);
                     
                                // if the event has project sponsor = yes, then add to the project sponsor list
                                if (evt.Project_Sponsor_On_Call__c == 'Yes')
                                    eventsWithProjSponsor.add(evt);
                                
                                EventsOnSameDate.add(evt);
                                
                            }
                        }
                        
                        System.debug(' @@@@@ eventsWithProjSponsor ' + eventsWithProjSponsor);
                        System.debug(' @@@@@ EventsOnSameDate ' + EventsOnSameDate);
                        
                        if (eventsWithProjSponsor.size() == 1) {
                            mostRecentQAEvent = eventsWithProjSponsor[0];
                        }
                        else if (eventsWithProjSponsor.size() > 1) {
                            
                            mostRecentQAEvent = eventsWithProjSponsor[0];
                        
                            // get the most recently modified event where Project sponsor = yes
                            for (Event evt : eventsWithProjSponsor) {
                                if (evt.LastModifiedDate > mostRecentQAEvent.LastModifiedDate)
                                    mostRecentQAEvent = evt;
                                
                            }
                        }
                    
                        // only find the event with the most recent last modified date if
                        // there are no events with project sponsor = 'yes'
                        if (eventsOnSameDate.size() > 1 
                            && eventsWithProjSponsor.size() == 0) {
                            
                            for (Event evt : eventsOnSameDate) {
                                if (evt.LastModifiedDate > mostRecentQAEvent.LastModifiedDate)
                                    mostRecentQAEvent = evt;
                            }
                        }
                    }
                }
            
                /* Populate Most_Recent_QA_Call_Date and Most_Recent_QA_Call_Grade__c if there is such an event*/
                if (mostRecentQAEvent != null) {
                    mem.Most_Recent_QA_Call_Recommend_Grade__c = mostRecentQAEvent.Would_Refer__c;
                    mem.Most_Recent_QA_Call_Renew_Grade__c = mostRecentQAEvent.Would_Buy_Again__c;
                    mem.Most_Recent_QA_Call_Date__c = Date.newInstance(mostRecentQAEvent.StartDateTime.year(), mostRecentQAEvent.StartDateTime.month(), mostRecentQAEvent.StartDateTime.day());
                    mem.Most_Recent_QA_Call_Grade__c = mostRecentQAEvent.Grade__c;
                }
            }
        
            //Bhavi Sharma - 01/19/2015 - CR-20141119-8126 - Update teh membership and return null
            update memList;
        }
    }        
    
    //This method is to fetch the Associate value of the membership's record owner and 
    //populate Owner Associate with it
    public static void populateOwnerAssociate(List<Membership__c> memberships) {
        
        //Create a set to hold the owner ids of membership records
        Set<Id> ownerIds = new Set<Id>();
        
        //loop through the membership records and pouplate the ownerIds with membership owners
        for(Membership__c membership : memberships) {
            ownerIds.add(membership.OwnerId);
        }
        
        //Check ownerIds and get owner related data
        if(ownerIds.size() > 0){
            
            //Map to hold the users data
            Map<Id, User> userMap = new Map<Id, User>([Select Id, Associate__c from User where ID IN: ownerIds]);
            
            //Loop through the membership records and populate the Owner Associate data
            for(Membership__c membership : memberships) {
                
                //Check if map contains Membership owner and User has Associate populated on it
                if(userMap.containsKey(membership.OwnerId) && userMap.get(membership.OwnerId).Associate__c != membership.Owner_Associate__c) {
                    membership.Owner_Associate__c = userMap.get(membership.OwnerId).Associate__c;
                }
            }
        }
    }
    
    //This method is to update the Membership status text field on membership object whenever there is a change on Contract ABC record
    public static void updateMembershipStatusByContracts(List<Membership__c> listMembership) {
        
        //Create a set of Contract Ids related with membership records
        Set<Id> contracts = new Set<Id>();
        
        //loop through the membership records and populate data in set
        for(Membership__c membership : listMembership) {
            //Add Active_Contract_Idenfied__c in set if not null
            if(membership.Active_Contract_Idenfied__c != null) {
                contracts.add(membership.Active_Contract_Idenfied__c);
            }
            //Add Earliest_Contract__c in set if not null
            if(membership.Earliest_Contract__c != null) {
                contracts.add(membership.Earliest_Contract__c);
            }
            //Add Latest_Contract__c in set if not null
            if(membership.Latest_Contract__c != null) {
                contracts.add(membership.Latest_Contract__c);
            }
        }
        
        //Map of contracts
        Map<Id, Contract__c> mapContract = new Map<Id, Contract__c>();
        
        //Checking set for size value
        if(contracts.size() > 0) {
    
            //fetch related data from database from Contract ABC object
            mapContract = new Map<Id, Contract__c>([Select Id, Start__c, End__c, Status__c, Renewal_Opp_Status__c, Payer_Account__c from Contract__c
                                                                            where ID IN: contracts]);
        }            
                                                                        
        //Temporary variable to hold the membership status
        String memberShipStatus;
        
        //Loop through the membership records and prepare the data set to be updated
        for(Membership__c membership : listMembership) {
            
            //reset membership status text
            memberShipStatus = '';
            
            //Check if Earliest_Contract__r.Start__c is smaller then equals to today's date then set the Membership status as "Prospect - Pending Future Start Date"
            if(membership.Earliest_Contract__c != null && mapContract.containsKey(membership.Earliest_Contract__c) 
                    && (mapContract.get(membership.Earliest_Contract__c).Start__c == null 
                        || mapContract.get(membership.Earliest_Contract__c).Start__c > Date.today())) {
                memberShipStatus = Constants.PROSPECT_PENDING_FUTURE_START_DATE;
            } 
            //If Active contract's end date is greater then today's date
            else if(membership.Active_Contract_Idenfied__c != null && mapContract.containsKey(membership.Active_Contract_Idenfied__c) 
                    && mapContract.get(membership.Active_Contract_Idenfied__c).End__c != null 
                    && mapContract.get(membership.Active_Contract_Idenfied__c).End__c >= Date.today()) {
                    if(mapContract.get(membership.Active_Contract_Idenfied__c).Status__c != null 
                       && mapContract.get(membership.Active_Contract_Idenfied__c).Status__c == Constants.HONORARY) {
                        memberShipStatus = Constants.MEMBER_HONORARY;
                    } else if(membership.Payer_Status__c != null && membership.Payer_Status__c == Constants.PAYER){
                        memberShipStatus = Constants.MEMBER_PAYER;
                    } else {
                        memberShipStatus = Constants.MEMBER_INTEGRATED;
                    }
            } else if(membership.Latest_Contract__c != null && mapContract.containsKey(membership.Latest_Contract__c) 
                        && mapContract.get(membership.Latest_Contract__c).End__c != null 
                        && mapContract.get(membership.Latest_Contract__c).End__c < Date.today() 
                        && mapContract.get(membership.Latest_Contract__c).Renewal_Opp_Status__c != null 
                        && mapContract.get(membership.Latest_Contract__c).Renewal_Opp_Status__c != ''
                        && (mapContract.get(membership.Latest_Contract__c).Renewal_Opp_Status__c.toLowerCase().contains(Constants.PENDING)
                            || mapContract.get(membership.Latest_Contract__c).Renewal_Opp_Status__c.toLowerCase().contains(Constants.CONTRACT_RECEIVED))
                        ) {
                if (mapContract.get(membership.Latest_Contract__c).Status__c  == Constants.HONORARY) {
                    memberShipStatus = Constants.MEMBER_HONORARY_GRACE;
                } else if(mapContract.get(membership.Latest_Contract__c).Payer_Account__c != null 
                        && mapContract.get(membership.Latest_Contract__c).Payer_Account__c == membership.Account_Name__c) {
                    memberShipStatus = Constants.MEMBER_PAYER_GRACE;
                } else {
                    memberShipStatus = Constants.MEMBER_INTEGRATED_GRACE;
                }
            } else if(membership.Latest_Contract__c != null && mapContract.containsKey(membership.Latest_Contract__c) 
                        && mapContract.get(membership.Latest_Contract__c).End__c < Date.today() 
                        && mapContract.get(membership.Latest_Contract__c).End__c > (Date.today() - 270)
                        && (mapContract.get(membership.Latest_Contract__c).Renewal_Opp_Status__c == Constants.DROPPED
                            || mapContract.get(membership.Latest_Contract__c).Renewal_Opp_Status__c == Constants.VOIDER)) {
                memberShipStatus = Constants.PROSPECT_RECENT_DROP;
            } else if(membership.Earliest_Contract__c != null && mapContract.containsKey(membership.Earliest_Contract__c) 
                    && mapContract.get(membership.Earliest_Contract__c).Start__c >= date.newInstance(1960,01,01)) {
                if(membership.Active_Contract_Idenfied__c != null && mapContract.containsKey(membership.Active_Contract_Idenfied__c) 
                        && mapContract.get(membership.Active_Contract_Idenfied__c).Start__c > Date.today()) {
                    memberShipStatus = Constants.PROSPECT_PENDING_FUTURE_START;
                } else {
                    memberShipStatus = Constants.PROSPECT_PAST_MEMBER;
                }   
            } else {
                memberShipStatus = Constants.PROSPECT_PURE;
            }
            
            //Checking for difference in between statuses
            if(memberShipStatus != null && memberShipStatus != '') {
                if (membership.Membership_Status_Text__c != memberShipStatus)
                    membership.Membership_Status_Change_Date__c = system.today();
                membership.Membership_Status_Text__c = memberShipStatus;
            }
        }
    }
    
    //Modified by - Mahendra Swarnkar - 07/15/2015 - CR-20150520-8962
    //Starts from here
    public static Account process_membership(Account a, List<Membership__c> memberships) {

        //Map to hold the different values. Will be helpful while further applying below written logic
        Map<String,String> mapAvailableOutReachAccountFields = MemberShipTriggerHelper.getmapAvailableOutReachAccountsFields();
        Map<String, List<String>> mapBusinessLineAccountFields = MemberShipTriggerHelper.getmapBusinessLineAccountsFields();
        
        // if the memberships list is null, return the account immediately without attempting to process
        if (memberships == null) return a;
    
        //Loop through Memberships on Account
        for (Membership__c mem : memberships) {
            
            // check to see if the membership is active -- if so, add to the list of Active memberships VRH 3/5/12
            if (mem.Membership_Status__c != null 
                && !mem.Membership_Status__c.contains('Member - Payer')
                && mem.Program__c != null
                && mem.Program__r.Business_Line__c != null 
                && mapBusinessLineAccountFields != null
                && mapBusinessLineAccountFields.containsKey(mem.Program__r.Business_Line__c)
                && mapBusinessLineAccountFields.get(mem.Program__r.Business_Line__c) != null) {
    
                //Get value of the Account field   
                String paidValue = (String)a.get(mapBusinessLineAccountFields.get(mem.Program__r.Business_Line__c)[1]);
    
                // make sure that the membership isn't already in the list
                if (paidValue != null) {
    
                    //Create set from existing data
                    Set<String> uniqueProgramAcronyms = new Set<String>();
    
                    //Split data by space and add in set 
                    uniqueProgramAcronyms.addAll(paidValue.split(Constants.SPACE));
    
                    //Check if the value is not null
                    if(uniqueProgramAcronyms.contains(mem.Program__r.Program_Acronym__c)) {
    
                        //Do the appropriate and expected replacements
                        paidValue = paidValue.replace(Constants.SPACE + mem.Program__r.Program_Acronym__c, '')
                                             .replace(mem.Program__r.Program_Acronym__c, '');
    
                        //Set value of the corresponding and applicable account field on record instance
                        a.put(mapBusinessLineAccountFields.get(mem.Program__r.Business_Line__c)[1], paidValue);
                    }
                }
            }
    
            // check to see if the membership is active -- if so, add to the list of Active memberships VRH 3/5/12
            if (mem.Membership_Status__c  != null
                && (mem.Membership_Status__c.contains('Member - Payer')
                    || mem.Membership_Status__c.contains('Member - Integrated')
                    || mem.Membership_Status__c.contains('Member - Honorary'))) {
    
                //Check for the business line
                if (mem.Program__c != null
                    && mem.Program__r.Business_Line__c != null
                    && mapBusinessLineAccountFields != null
                    && mapBusinessLineAccountFields.containsKey(mem.Program__r.Business_Line__c)
                    && mapBusinessLineAccountFields.get(mem.Program__r.Business_Line__c) != null ) {
        
                    //Get value from the Accout field as per the business line  
                    String activeValue = (String)a.get(mapBusinessLineAccountFields.get(mem.Program__r.Business_Line__c)[0]);
                    String paidValue = (String)a.get(mapBusinessLineAccountFields.get(mem.Program__r.Business_Line__c)[1]);
                    
                    // make sure that the membership isn't already in the list
                    if (activeValue != null && !activeValue.contains(mem.Program__r.Program_Acronym__c)) {
    
                        activeValue += Constants.SPACE + mem.Program__r.Program_Acronym__c + ' ';
                        a.put(mapBusinessLineAccountFields.get(mem.Program__r.Business_Line__c)[0], activeValue);
                    }
    
                    //Check for membership status
                    if(mem.Membership_Status__c != null
                        && mem.Membership_Status__c.contains('Member - Payer')) {
    
                        // make sure that the membership isn't already in the list
                        if (paidValue != null) {
    
                            //Check if the value is not null
                            if(!paidValue.contains(mem.Program__r.Program_Acronym__c)) {
                            
                                paidValue += Constants.SPACE + mem.Program__r.Program_Acronym__c;
                                a.put(mapBusinessLineAccountFields.get(mem.Program__r.Business_Line__c)[1], paidValue);
                            }  
                            
                        } else {
    
                            paidValue = Constants.SPACE + mem.Program__r.Program_Acronym__c;
                            a.put(mapBusinessLineAccountFields.get(mem.Program__r.Business_Line__c)[1], paidValue );
                        }
                    }
                }
            }
    
            //Check for Program lookup on the membership
            if(mem.Program__c != null) {
    
                //Check for the Membership status and business line
                if (mem.Membership_Status__c != null
                    && mem.Membership_Status__c.startsWith('Member')
                    && mem.Program__r.Business_Line__c != null
                    && mapBusinessLineAccountFields.containsKey(mem.Program__r.Business_Line__c)
                    && mapBusinessLineAccountFields.get(mem.Program__r.Business_Line__c) != null) {
    
                    // Get Sums of Renewal Unit Count and return to account
                    if (mem.Program__r.Business_Line__c == 'PT'
                        || mem.Program__r.Business_Line__c == 'RI'
                        || mem.Program__r.Business_Line__c == 'TD'
                        || mem.Program__r.Business_Line__c == 'CM') {
    
                        //Checking map for size value    
                        if(mapBusinessLineAccountFields.get(mem.Program__r.Business_Line__c).size() >= 3) {  
                            if(a.get(mapBusinessLineAccountFields.get(mem.Program__r.Business_Line__c)[2]) != null) {
                                Decimal temp = (Decimal)a.get(mapBusinessLineAccountFields.get(mem.Program__r.Business_Line__c)[2]);
                                temp += mem.Renewal_Unit_Count__c != null ? mem.Renewal_Unit_Count__c : 0;
                                a.put(mapBusinessLineAccountFields.get(mem.Program__r.Business_Line__c)[2], temp);
                            }    
                        }        
                    }
                }
    
                // Get Program Acronyms of Programs Available for Outreach and return to account
                if(mem.Prospect_Status__c == 'Available for Outreach'
                    && mem.Renewal_Unit_Count__c == 1 
                    && mem.Program__r.Program_Acronym__c != null
                    && mem.Program__r.Business_Line__c != null
                    && mapAvailableOutReachAccountFields.containsKey(mem.Program__r.Business_Line__c)
                    && mapAvailableOutReachAccountFields.get(mem.Program__r.Business_Line__c) != null ) {
    
                    if(a.get(mapAvailableOutReachAccountFields.get(mem.Program__r.Business_Line__c)) != null) {     
                        String temp = (String) a.get(mapAvailableOutReachAccountFields.get(mem.Program__r.Business_Line__c));
                        temp += mem.Program__r.Program_Acronym__c + ' ';
                        a.put(mapAvailableOutReachAccountFields.get(mem.Program__r.Business_Line__c), temp);
                    }        
                }
            }
        }
    
        return a;
    }
    //Ends here

    
    //CR-20120208-389 - Moved teh logic from Membership_PopulateAssignedMarketer trigger to new method
    public static void membershipPopulateAssignedMarketer(List<Membership__c> newMemberShips, Boolean isBefore) {
        
        /*
        Purpose:    This Trigger populates the Assigned_Marketer__c field on the Membership object based on following logic
                    Program__r.New_Business_Marketer__c (text) is used to query AccountTeamMembers for the associated Account: 
                    Role = New_Business_Marketer__c
                    The resulting user is then set as Assigned_Marketer__c field
                    
                    Populates Membership Name based on the following criteria: <Account Name truncated to 55 characters> - <Program Acronym>
                    
                    Removes Earliest_Contract__c, Latest_Contract__c, and Active_Contract_Idenfied__c when Program or Account is null. 
                    
                    Populates Account fields 
                        RI Memberships: sum of Renewal_Unit_Count__c on Memberships on Account where Membership__r.Program__r.Business_Line__c = 'RI'
                        PT Memberships: sum of Renewal_Unit_Count__c on Memberships on Account where Membership__r.Program__r.Business_Line__c = 'PT'
                        TD Memberships: sum of Renewal_Unit_Count__c on Memberships on Account where Membership__r.Program__r.Business_Line__c = 'TD'
                        CM Memberships: sum of Renewal_Unit_Count__c on Memberships on Account where Membership__r.Program__r.Business_Line__c = 'CM'
                    
                    Updates OwnerID field based on the following criteria:
                    if (Membership_Status__c contains 'Prospect')
                        OwnerID = assigned marketer
                    else
                        OwnerID = owner of active contract renewal opportunity.
                    
        
        Create By:  Angela Williams (SAP Contractor)            
        
        Last Modified By:   Nathan Banas (SAP) - 1/24/2011
        
        Current Version:    v1.3
        
        Revision Log:       v1.0 - (AW) Created code
                            v1.1 - (JN-2010-12-15) Added requirements to update Account fields:
                                    RI Memberships
                                    PT Memberships
                                    TD Memberships
                                    CM Memberships
                            v1.2 - (NB-2011-01-19) Added requirements to update OwnerID field based on the following criteria:
                                    if (Membership_Status__c contains 'Prospect')
                                        OwnerID = assigned marketer
                                    else
                                        OwnerID = owner of active contract renewal opportunity.
                            v1.3 - (NB-2011-01-24) Added line to trigger to account for validation rule failures and bypass.  Code coverage reduced to 96%.
                            v1.4 - (Bhavi - 02/07/2012) Flag added not to execute the trigger if membership is updating as a result of user trigger
        Code Coverage as of 1/20/2011: 97%
        */  
        
        System.debug('Util.IsBatch: ' + Util.IsBatch );
        System.debug('system.isFuture: ' + system.isFuture());
        System.debug('Util.IsTrigger_ContractFieldUpdate: ' + Util.IsTrigger_ContractFieldUpdate);
        System.debug('Util.IsTrigger_Opportunity_ValidationAndFieldUpdates: ' + Util.IsTrigger_Opportunity_ValidationAndFieldUpdates);
        System.debug('Util.IsTrigger_EventPrewire: ' + Util.IsTrigger_EventPrewire);
        System.debug('Util.IsTrigger_EventUpdateFields: ' + Util.IsTrigger_EventUpdateFields);
        System.debug('Util.IsTrigger_ContractIntegratedAcctRunning: ' + Util.IsTrigger_ContractIntegratedAcctRunning);
        System.debug('Util.IsMembershipOwnerAssociateTrigger: ' + Util.IsMembershipOwnerAssociateTrigger);
        
        // Bypass this trigger if it is being called by another process
        if (Util.IsBatch 
            || system.isFuture() // VRH added 3/7/12
            || Util.IsTrigger_ContractFieldUpdate 
            || Util.IsTrigger_Opportunity_ValidationAndFieldUpdates 
            || Util.IsTrigger_EventPrewire 
            || Util.IsTrigger_EventUpdateFields
            || Util.IsTrigger_ContractIntegratedAcctRunning
            || Util.IsMembershipOwnerAssociateTrigger
            || Util.BypassAllTriggers) {
                // if any of these conditions are true, return immediately without processing
                return;
        }
            
        //This map holds all the new membership records being loaded
        Map<Id,Membership__c> membershipMap = new Map<Id,Membership__c>();
    
        //This list will hold all the account ids for the new Memberships
        List<Id> accIdList = new List<Id>();
    
        // Map to store Program Acronyms w/ the Program Id as the key
        Map<Id, String> progMap = new Map<Id, String>();
        
        // List to store program Ids
        List<Id> progIds = new List<Id>();
        
        // List to store Active Contract Ids
        //Comment By Bhavi - 02/02/2013 - Instead of List, Used Set to prevent from the duplicate Ids and unnecessary execution
        //List<Id> activeContractIds = new List<Id>();
        Set<Id> activeContractIds = new Set<Id>();
        Set<Id> latestContractIds = new Set<Id>();
        
        // Map to store Programs w/ Membership Id as the key
        Map<Id, Program__c> memToProgMap = new Map<Id, Program__c>();
        
        for(Membership__c mem: newMemberShips) {
        
            // Build a map of of Memberships related to Membership Ids
            membershipMap.put(mem.Id, mem);
            
            // Build a List of Account Ids
            accIdList.add(mem.Account_Name__c);
            
            // First step in building a map of New Business Marketers relating to Program Ids
            progMap.put(mem.Program__c, null);
            
            if(mem.Program__c != null)
                progIds.add(mem.Program__c);
                
             // NB 1/19/11 - Added below section to allow for Ownership updates
            if(mem.Active_Contract_Idenfied__c != null) {
            
                //Add Id In Set
                activeContractIds.add(mem.Active_Contract_Idenfied__c);
            
            } else if(mem.Latest_Contract__c != null) {
                
                //Bhavi - 02/02/2013 - CR-20121212-1898
                
                //If Active Contract is null, use latest Contract to Populate Owner
                latestContractIds.add(mem.Latest_Contract__c);
            }
        }
        
        // Map to store Accounts w/ the Account Id as the key 
        Map<Id,Account> accountMap = new Map<Id,Account>();
        
        //Map of contracts
        Map<Id, Contract__c> mapContracts = new Map<Id, Contract__c>();
        
        //Checking set for size value
        if(latestContractIds.size() > 0 || activeContractIds.size() > 0) {
        
            // Query for all related Active Contracts meeting criteria necessary to perform the steps within this code
            
            //Commented By Bhavi - 02/02/2013 - instead of List, Used map to reduce the looping statement
            //List<Contract__c> activeContracts = [Select Id, Payer_Account__c, Contract_Renewal_Opportunity__c, Contract_Renewal_Opportunity__r.OwnerId, Payer_Account__r.OwnerId from Contract__c where Id in :activeContractIds]; // NB 1/19/11 - Added to allow for Ownership updates
            mapContracts = new Map<Id, Contract__c>([Select Id, Payer_Account__c, 
                                                        Contract_Renewal_Opportunity__c, Contract_Renewal_Opportunity__r.OwnerId, 
                                                        Payer_Account__r.OwnerId FROM Contract__c 
                                                        WHERE (Id in :activeContractIds OR Id IN: latestContractIds) 
                                                        AND Contract_Renewal_Opportunity__c != null]);
        }    
        
        //Build a map of Contract_Renewal_Opportunity__c Owner Ids relating to Membership Ids
        Map<Id, Id> membToActContrOwner = new Map<Id, Id>();
        
        //Loop through memberships calling this trigger
        for(Membership__c mem: newMemberShips) {
        
            // If the Active Contract Identified field is not empty then process
            // If the Contract Id equals the Membership Active Contract Identified field value 
            //&& the Contract Renewal Opportunity field on Contracts isn't null, then process
            if(mem.Active_Contract_Idenfied__c != null && mapContracts.containsKey(mem.Active_Contract_Idenfied__c)) {
            
                // Add the Contract's Contract Renewal Opportunity to a map with Membership Id as the key
                membToActContrOwner.put(mem.id, mapContracts.get(mem.Active_Contract_Idenfied__c).Contract_Renewal_Opportunity__r.OwnerId);
            } else if(mem.Latest_Contract__c != null && mapContracts.containsKey(mem.Latest_Contract__c)) {
                
                //Bhavi - 02/02/2013 - CR-20121212-1898
                
                // If the Active Contract Identified field is not empty then process
                // If the Contract Id equals the Membership Active Contract Identified field value 
                //&& the Contract Renewal Opportunity field on Contracts isn't null, then process
            
                // Add the Contract's Contract Renewal Opportunity to a map with Membership Id as the key
                membToActContrOwner.put(mem.id, mapContracts.get(mem.Latest_Contract__c).Contract_Renewal_Opportunity__r.OwnerId);
            } 
        }
        
        //Checking list for size value
        if(accIdList.size() > 0) {
        
            //Modified By Abhinav Sharma - 02/13/2014 - CR-20130911-3628 - Refactor the MembershipTriggerHelper.membershipPopulateAssignedMarketer method so it doesn't attempt to directly assign Accounts to the AccountList   
            // Build a map of Accounts relating to Account Ids
            //Modified by Bhavi Sharma - 03/18/2014 - Removed inline queries and used direct queries for assignment
            for(Account acc: [select Id, Name, Core_Memberships__c, BI_Memberships__c, Academies_Memberships__c, Hworks_Memberships__c,
                                Paid_CM_Memberships__c, Paid_PT_Memberships__c, Paid_RI_Memberships__c, Paid_SW_Memberships__c, Paid_TD_Memberships__c, Paid_CLN_Memberships__c
                                from Account where Id IN: accIdList]) {
            
                accountMap.put(acc.Id, acc);
            }
        }    
        
        //Create a map of membership to hold teh memebership related to accounts
        Map<Id, List<Membership__c>> mapAccMemberships = new Map<Id, List<Membership__c>>();
        Map<Id, List<AccountTeamMember>> mapAccTeamMembers = new Map<Id, List<AccountTeamMember>>();
        
        boolean processAccMemberships = true;
        
        //Checking map for size value
        if(accountMap.keySet().size() > 0) {
            
            //CR-20160210-9596 - get the total number of memberships related to the corresponding accounts.
            //if the count is greater than 10,000 then do not process account memberhips, because it
            //will cause us to go over the CPU limit.  Instead, these records will be updated by the nightly Batch_Account_OutreachProgs_v2 job
            integer numAccMemberships = [SELECT COUNT()
                                         FROM Membership__c where Program__r.Business_line__c in ( 'RI', 'PT', 'TD', 'CM', 'SW', 'CLN') 
                                         AND Account_Name__c IN: accountMap.keySet() LIMIT 10001];
            
            if (numAccMemberships > 10000) 
                processAccMemberships = false;
            
            //CR-20160210-9596 - mapAccMemberships is only used in the case where this is after trigger, so only populate it in that instance.
            if (!isBefore && processAccMemberships) {
                //Fetch memberships related to account and popuplate map
                for(Membership__c m : [Select Id, Account_Name__c, Membership_Status_Text__c, Program__r.Business_Line__c, Program__r.Program_Acronym__c, 
                                       Prospect_Status__c, Membership_Status__c, Renewal_Unit_Count__c 
                                       from Membership__c where Program__r.Business_line__c in ( 'RI', 'PT', 'TD', 'CM', 'SW', 'CLN') 
                                       AND Account_Name__c IN: accountMap.keySet()]) {
                                           
                                           //Check if account has already been added in Map
                                           if(!mapAccMemberships.containsKey(m.Account_Name__c))
                                               mapAccMemberships.put(m.Account_Name__c, new List<Membership__c>());
                                           mapAccMemberships.get(m.Account_Name__c).add(m);
                                       }
            }
        
            //Fetch team members and populate in map
            for(AccountTeamMember aTM : [Select AccountId, UserId, TeamMemberRole from AccountTeamMember where AccountId IN: accountMap.keySet()]) {
                
                //Check if account has already been added in Map
                if(!mapAccTeamMembers.containsKey(aTM.AccountId))
                    mapAccTeamMembers.put(aTM.AccountId, new List<AccountTeamMember>());
                mapAccTeamMembers.get(aTM.AccountId).add(aTM);
            }
        } 
        
        //List of programs
        List<Program__c> programs = new List<Program__c>();
        map<id, Program__c> progid2progmap = new Map<Id, Program__c>();
        
        //Checking set for size value
        if(progIds.size() > 0) {
        
            // Query for all related Programs
            programs = [select Id, New_Business_Marketer__c, Business_line__c, Program_Acronym__c from Program__c where Id in :progIds];
        
            // Build a Map of Programs w/ Program Id as their key
            progid2progmap = new map<id, Program__c>(programs);
        
            // Loop through related Programs and add them to a map
            for(Program__c prgm: programs) {
            
                // Second step in building a map of New Business Marketers relating to Program Ids
                progMap.put(prgm.Id, prgm.New_Business_Marketer__c);
            }
        }    
        
        // Process only if the Trigger is a before trigger
        if (Trigger.IsBefore) {
        
            //Modify By - Abhinav Sharma - 04/30/2015 - CR-20121218-1964
            //replace membershipMap.values () with newMemberShips (Trigger.new list)
            /* Set Membership name */ 
            for (Membership__c mem : newMemberShips) {
            
                //Set naming convention in case the name is edited
                if(progid2progmap.containsKey(mem.Program__c) && progid2progmap.get(mem.Program__c) != null) {
             
                    Program__c prog = progid2progmap.get(mem.Program__c);
                    String accname = accountMap.get(mem.Account_Name__c) != null ? accountMap.get(mem.Account_Name__c).Name : '';
                    Integer maxaccnamelength = 55;
                    String suffix = ' - ';
                
                    if ((prog != null) && (prog.Program_Acronym__c != null) && (prog.Program_Acronym__c != 'null'))
                        suffix += prog.Program_Acronym__c;
                        
                    accname = accname.substring(0,(Math.min(maxaccnamelength, accname.length())));
                    mem.Name = accname + suffix;
                }
            }                
            
            /* Set Assigned Marketer */
                
            // This map will hold the mapping for membership record along with the identified Assigned Marketer
            Map<Id, String> membershipUserIdMap = new Map<Id, String>();
            
            for(Id idVal: membershipMap.KeySet()) {
                
                Membership__c mem = membershipMap.get(idVal);
                    
                //find Assigned Marketer
                if(accountMap.get(mem.Account_Name__c) != null) {
                    
                    List<AccountTeamMember> members = new List<AccountTeamMember>();
                        
                    if(mapAccTeamMembers.containsKey(mem.Account_Name__c))
                        members = mapAccTeamMembers.get(mem.Account_Name__c);
                        
                    // Loop through Account Team Members
                    for(AccountTeamMember membr: members) {
                            
                        // If the Program's New Business Marketer matches the current Account Team Member,
                        // add it to a map of Key: Membership Id / Value: Account Team Member User Id
                        // DAF - changed 9/27/11 & 10/1/11      if(progMap.get(mem.Program__c) == membr.TeamMemberRole)
                        if (progMap.get(mem.Program__c) != null) {
                            if(membr.TeamMemberRole.contains(progMap.get(mem.Program__c)))
                                membershipUserIdMap.put(mem.Id, membr.UserId);
                        }
                    }
                }
            }
            
            // Loop through each membership
            for(Membership__c mem: newMemberShips) {
                
                // Process only if the trigger is a before trigger
                if(isBefore) {
                        
                    // Set assigned Marketer
                    mem.Assigned_Marketer__c =  membershipUserIdMap.get(mem.Id);
                        
                    // Nathan B 1/5/11 - Added to set Active, Earliest, Latest Contract to Null when Program OR Account is null
                    if(mem.Account_Name__c == null || mem.Program__c == null) {
                        mem.Earliest_Contract__c = null;
                        mem.Latest_Contract__c = null;
                        mem.Active_Contract_Idenfied__c = null;
                    }
                }
                    
                // Set Owner based on Membership Status (Nathan B 1/19/11 - Added this to the process)
                if(mem.Membership_Status_Text__c.toLowerCase().contains('prospect')) {
                    
                    // When the Membership_Status contains 'Prospect', set the Membership's Owner equal to either the Assigned Marketer, or if null leave it the same
                    mem.OwnerId = mem.Assigned_Marketer__c != null ? mem.Assigned_Marketer__c : mem.OwnerId;
                }
                else {
                        
                    if(mem.Active_Contract_Idenfied__c != null && membToActContrOwner.containsKey(mem.Id)) {
                        
                        // When the Membership_Status does not contain 'Prospect', set the Membership's Owner equal to either the Active Contract Owner, or if null leave it the same
                        mem.OwnerId = membToActContrOwner.get(mem.Id);
                        
                    } else if(mem.Latest_Contract__c != null && membToActContrOwner.containsKey(mem.Id)) {
                            
                        //Bhavi - 02/02/2013 - CR-20121212-1898
                        
                        // When the Membership_Status does not contain 'Prospect', set the Membership's Owner equal to either the Active Contract Owner, or if null leave it the same
                        mem.OwnerId = membToActContrOwner.get(mem.Id);
                    }
                }
            }
        }
            
        // Process only if the trigger is an after trigger
        if (!isBefore) {
            
            // Build Program To Membership Map
            for(Membership__c mem: newMemberShips) {
                
                if(mem.Program__c != null) {
                    
                    for(Program__c p : programs) {
                        
                        if(mem.Program__c == p.Id) {
                            
                            memToProgMap.put(mem.Id, p);
                            
                            break;
                        }   
                    }
                }
            }
                
            /*
            Count the four different kinds of Memberships by Account
            Also provide the Program Acronyms for three different kinds of memberships            
            */
            
            //If statement for flag check - Added By - Mahendra Swarnakar - 09/15/2016 - CR-20160519-9865
            //Checking for flag which is responsible for handling the case when children are more than 10000 in count
            if(processAccMemberships) {
                
                // Loop through Accounts related to the Memberships that called this trigger
                //Modified By Abhinav Sharma - 02/13/2014 - CR-20130911-3628 - Refactor the MembershipTriggerHelper.membershipPopulateAssignedMarketer method so it doesn't attempt to directly assign Accounts to the AccountList   
                for (Account a : accountMap.values()) {
                
                    // Zero out the 4 kinds of Membership Counts on this Account & the 3 kinds of Membership Program Acronyms
                    a.Core_Memberships__c = 0;
                    a.BI_Memberships__c = 0;
                    a.Academies_Memberships__c = 0;
                    a.Hworks_Memberships__c = 0;
                    a.Core_Programs_Available_for_Outreach__c = '';
                    a.Academy_Programs_Available_for_Outreach__c = '';
                    a.BI_Programs_Available_for_Outreach__c = '';
                    
                    // clear out active membership list
                    a.Active_RI_Memberships__c = '';
                    a.Active_PT_Memberships__c = '';
                    a.Active_CM_Memberships__c = '';
                    a.Active_SW_Memberships__c = '';
                    a.Active_TD_Memberships__c = '';
                    a.Active_CLN_Memberships__c = '';
                    
                    // get a list of memberships from the institution to pass in to the process_Membership method
                    List<Membership__c> memberships = new List<Membership__c>();
                    if(mapAccMemberships.containsKey(a.Id))
                        memberships = mapAccMemberships.get(a.Id);
                    a = process_membership(a, memberships); 
                    
                    // Format the Programs Available for Outreach to remove blank spaces and ensure the max length is not exceeded then return the results to account
                    if (a.Academy_Programs_Available_for_Outreach__c != '')
                        a.Academy_Programs_Available_for_Outreach__c = 
                            a.Academy_Programs_Available_for_Outreach__c.trim().substring(0,Math.min(255, a.Academy_Programs_Available_for_Outreach__c.trim().length()));
                    if (a.BI_Programs_Available_for_Outreach__c != '')
                        a.BI_Programs_Available_for_Outreach__c = 
                            a.BI_Programs_Available_for_Outreach__c.trim().substring(0,Math.min(255, a.BI_Programs_Available_for_Outreach__c.trim().length()));
                    if (a.Core_Programs_Available_for_Outreach__c != '')
                        a.Core_Programs_Available_for_Outreach__c = 
                            a.Core_Programs_Available_for_Outreach__c.trim().substring(0,Math.min(255, a.Core_Programs_Available_for_Outreach__c.trim().length()));
                }
            
                // Update accounts
                //Modified By Abhinav Sharma - 02/13/2014 - CR-20130911-3628 - Refactor the MembershipTriggerHelper.membershipPopulateAssignedMarketer method so it doesn't attempt to directly assign Accounts to the AccountList   
                if (accountMap.values().size() > 0)
                    update accountMap.values();
                }
        }
    }
    
    //This method is to populate data in key contact
    public static void populateContactData(List<Membership__c> memberShips) {
        
        //Create a set to hold the appropriate membership records ids
        Set<Id> membershipIds = new Set<Id>();
        
        //Loop through the membership records and get all the records and add in set where Status starts with Membership
        for(Membership__c membership : memberShips) {
            
            //check for teh status value
            if(membership.Membership_Status__c != null && membership.Membership_Status__c.startsWith(Constants.MEMBER)) {
                
                //Add membership Id in set
                membershipIds.add(membership.Id);
            }       
        }
        
        //Create a Map to hold the contact data and maintain the uniqueness
        Map<Id, Contact> mapContact = new Map<Id, Contact>();
        
        //Check id there are records to process
        if(membershipIds.size() > 0) {
            
            //get appropriate Membership Key Contacts from database
            for(Membership_Key_Contact__c mKC : [Select Id, Pubs__c, Meetings__c, Membership__c, Membership__r.Program_Acronym__c, 
                    Contact__c, Contact__r.Membership_Contact_Pubs__c, Contact__r.Membership_Contact_Meetings__c from Membership_Key_Contact__c 
                    where Membership__c != null AND Membership__r.Program_Acronym__c != null AND Membership__r.Program_Acronym__c != '' 
                    AND Membership__c IN: membershipIds AND Contact__c != null AND (Pubs__c = true OR Meetings__c = true)]) {
                
                //Contact cloneContact
                Contact cloneContact;
                
                //Check for the contact and update contact's data
                if(mapContact.containsKey(mKC.Contact__c)) {
                    
                    //Get the contact record from map
                    cloneContact = mapContact.get(mKC.Contact__c); 
                } else {
                    
                    //Create a contact clone
                    cloneContact = new Contact(Id = mKC.Contact__c, Membership_Contact_Pubs__c = mKC.Contact__r.Membership_Contact_Pubs__c, 
                                                Membership_Contact_Meetings__c = mKC.Contact__r.Membership_Contact_Meetings__c);
                }
                
                //Populate Membership_Contact_Pubs__c field data
                if(mKC.Pubs__c == true) {
                    if(cloneContact.Membership_Contact_Pubs__c != null && cloneContact.Membership_Contact_Pubs__c != '' 
                            && (!cloneContact.Membership_Contact_Pubs__c.contains(mKC.Membership__r.Program_Acronym__c))) {
                            
                        //Set program acronym in cloneContact
                        cloneContact.Membership_Contact_Pubs__c += ', ' + mKC.Membership__r.Program_Acronym__c;
                    } else {
                            
                        //Set program acronym in cloneContact
                        cloneContact.Membership_Contact_Pubs__c = mKC.Membership__r.Program_Acronym__c;
                    }
                }
                
                //Populate Membership_Contact_Meetings__c field data
                if(mKC.Meetings__c == true) {
                    if(cloneContact.Membership_Contact_Meetings__c != null && cloneContact.Membership_Contact_Meetings__c != '' 
                            && (!cloneContact.Membership_Contact_Meetings__c.contains(mKC.Membership__r.Program_Acronym__c))) {
                            
                        //Set program acronym in cloneContact
                        cloneContact.Membership_Contact_Meetings__c += ', ' + mKC.Membership__r.Program_Acronym__c;
                    } else {
                            
                        //Set program acronym in cloneContact
                        cloneContact.Membership_Contact_Meetings__c = mKC.Membership__r.Program_Acronym__c;
                    }
                }
                    
                //Put the contact record in map
                mapContact.put(mKC.Contact__c, cloneContact);
            }
            
            //Check if there are records to update
            if(mapContact.size() > 0) {
                // we only want to populate 2 fields on the contact
                // so bypass all triggers when updating
                Util.BypassAllTriggers = true;
                update mapContact.values();
                Util.BypassAllTriggers = false;
            }
        }
    }
    
    //Added By - Ajit Surana - 03/28/2015 - CR-20150312-8758
    /**
     *  @description    :   Method is used to populate the Industry Member as true, if there is any child membership record with �Industry Member = true�.
     *
     *  @args           :   List of new Membership, Map of old Membership
     *
     *  @return         :   void
     *
     **/
    public static void populateIndustryMemberOnAccount(List<Membership__c> newMemberships, Map<Id, Membership__c> mapOldMemberships) {
    
        //Set to hold Account Id of Membership record
        Set<Id> accIds = new Set<Id>();
        
        //Insert or update use cases
        if(newMemberships!= null) {
        
            //Loop through Trigger.new
            for(Membership__c newMembership : newMemberships) {
                
                //Check for AccountId not null & adding AccountId into set
                if(newMembership.Account_Name__c != null)    
                    accIds.add(newMembership.Account_Name__c);
                
                //Check if Account is update on Membership record
                if(mapOldMemberships != null && (newMembership.Program__c != mapOldMemberships.get(newMembership.Id).Program__c
                    || newMembership.Account_Name__c != mapOldMemberships.get(newMembership.Id).Account_Name__c)) {
                    
                    if(newMembership.Account_Name__c != null)
                        accIds.add(newMembership.Account_Name__c);
                        
                    if(mapOldMemberships.get(newMembership.Id).Account_Name__c != null)
                        accIds.add(mapOldMemberships.get(newMembership.Id).Account_Name__c);
                }
            }
        //Delete use cases
        } else {
            
            //Loop through Trigger.new
            for(Membership__c oldMembership : mapOldMemberships.values()) {
                
                //Check for null & adding ProjectId into set
                if(oldMembership.Account_Name__c != null)    
                    accIds.add(oldMembership.Account_Name__c);
            }
        }
        
        //Checking set for size value
        if(accIds.size() > 0){
            
            //Set to hold Account Ids
            Set<Id> tempSetIDs = new Set<Id>();
            
            //Making a clone
            tempSetIDs.addAll(accIds);
            
            //Map of Account
            Map<Id, Account> mapAccounts = new Map<Id, Account>();
        
            //AggregateResult to get count of Membership for each Account
            for (AggregateResult ar: [Select Count(Id) MembershipCount, Account_Name__c accName From Membership__c 
                                        Where Account_Name__c != null AND Account_Name__c IN: accIds AND Industry_Member__c = true
                                        AND Active_Core_Membership__c = 1 GROUP BY Account_Name__c]){
                if(ar.get('accName') != null) { 
                    Account acct = new Account(Id=(Id)ar.get('accName'), Industry_Member__c = true);
                    mapAccounts.put((Id)ar.get('accName'), acct);
                    tempSetIDs.remove((Id)ar.get('accName'));
                }
            }
            
            //Checking set for the size value
            if(tempSetIDs.size()>0){
               
               //Loop through the ID values 
               for(Id aId: tempSetIDs){
                   Account acct = new Account(Id = aId, Industry_Member__c = false);
                   mapAccounts.put(aId, acct);
               }    
            }
            
            //Update the Account records 
            if(mapAccounts.values().size()>0){
                Util.byPassAllTriggers = true;
                update mapAccounts.values();
                Util.byPassAllTriggers = false;
            } 
        }
    }
}