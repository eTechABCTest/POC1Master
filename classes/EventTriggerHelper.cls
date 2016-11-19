/**
 *  Purpose         :   Helper class for teh Trigger Event
 *
 *  Created By      :   Bhavi Sharma
 *
 *  Created Date    :   01/19/2015
 *
 *  Revision Logs   :   V_1.0 - Created  (CR-20141119-8126)
 *                      V_1.1 - Modified By - Mahendra Swarnkar - 05/16/2015 - CR-20150401-8835 -Added new method (updateNextActivityDate)
 *                      V_1.2 - Modified By - Abhinav Sharma - 08/26/2015 - CR-20140613-5790 - Added new methods (populatePAsAndActivityFieldsOnOpportunity, populatePAsAndActivityFields)
 *                      V_1.3 - Modified By - Abhinav Sharma - 09/04/2015 - CR-20150817-9161 - Added new method (updateEventHistoryTrackingFields)
 *                      V_1.4 - Modified By - Abhinav Sharma - 11/24/2015 - CR-20150929-9281 - Modified existing method (updateEventHistoryTrackingFields)
 *                      v_1.5 - Modified By - Mahendra Swarnakar - 8/26/2016 - CR-20160606-9903 - Modified the Method populateMostRecentQACall.
**/
public without sharing class EventTriggerHelper {

    //Control  the execution of trigger
    public static Boolean EXECUTE_TRIGGER = true;
    
    //Added By - Abhinav Sharma - 09/04/2015 - CR-20150817-9161
    //Modified By - Abhinav Sharma - 11/24/2015 - CR-20150929-9281
    /**
     *  @description    :   Method to populate history tracking type fields on Activity of Event Type = 'In Person Visit'
     *
     *  @args           :   List of new events, Old evenets map
     *
     *  @return         :   void
     *
    **/
    public static void updateEventHistoryTrackingFields(List<Event> newEvents, Map<Id, Event> mapOldEvents) {
        
        //Map of events
        Map<Id, Event> mapEventsOnStartDateTimeGotModified = new Map<Id, Event>();
        Map<Id, Event> mapEventsOnCancelledDidNotOccurGotModified = new Map<Id, Event>();
        Map<Id, Event> mapEventsWithEventTypeChange = new Map<Id, Event>();
        
        //Loop through event records
        for(Event ev : newEvents) {
            
            //Insert use case
            if(mapOldEvents == null) {

                if(ev.Cancelled_Did_Not_Occur__c != null && ev.Cancelled_Did_Not_Occur__c)
                    mapEventsOnCancelledDidNotOccurGotModified.put(ev.Id, ev);
            }
            
            //Update use case
            if(mapOldEvents != null) {

                //Populating map with appropriate values if Start Date got modified on event record
                if(ev.StartDateTime != mapOldEvents.get(ev.Id).StartDateTime)
                    mapEventsOnStartDateTimeGotModified.put(ev.Id, ev);
                
                //Populating map with appropriate values if Cancelled/Did Not Occur got modified on event record
                if(ev.Cancelled_Did_Not_Occur__c != mapOldEvents.get(ev.Id).Cancelled_Did_Not_Occur__c)
                    mapEventsOnCancelledDidNotOccurGotModified.put(ev.Id, ev);
                
                //Checking for the "Event Type" field change and populating map accordingly
                if(ev.Event_Type__c != mapOldEvents.get(ev.Id).Event_Type__c)
                    mapEventsWithEventTypeChange.put(ev.Id, ev);
            }
        }
        
        //Loop through event records
        for(Event eve : newEvents) {
            
            //Checking for event type
            if(eve.Event_Type__c != null && eve.Event_Type__c.toLowerCase().trim() == System.Label.Event_Type_IN_Person_Visit) {
            
                //Checking for values in map and accordingly populating the field's with value
                if(mapEventsOnStartDateTimeGotModified.containsKey(eve.Id)
                    && mapEventsOnStartDateTimeGotModified.get(eve.Id) != null) {
                    eve.Start_Date_Time_Last_Modified_Date__c = System.now();    
                
                    if(eve.of_Times_Start_Date_Time_Updated__c == null)
                        eve.of_Times_Start_Date_Time_Updated__c = 1;
                    else
                        eve.of_Times_Start_Date_Time_Updated__c = eve.of_Times_Start_Date_Time_Updated__c + 1;
                }
                
                //Checking for values in map and accordingly populating the field's with value
                if(mapEventsOnCancelledDidNotOccurGotModified.containsKey(eve.Id)
                    && mapEventsOnCancelledDidNotOccurGotModified.get(eve.Id) != null) {
                    eve.Cancelled_Did_Not_Occur_Last_Modify_Date__c = System.now(); 
                }
                
                //Added by - Abhinav Sharma - CR-20150929-9281
                //Start from here
                //On an event record insert. if it having "Event Type" field 
                //value equals to "In Person Visit" then only "Initial Start Date/Time" field will populate 
                //to have "Start Date/Time" field value.
                if(mapOldEvents == null)
                    eve.Initial_Start_Date_Time__c = eve.StartDateTime;
                
                //Checking for the event type field change
                if(mapEventsWithEventTypeChange.containsKey(eve.Id)
                    && mapEventsWithEventTypeChange.get(eve.Id) != null)
                    eve.Initial_Start_Date_Time__c = eve.StartDateTime;
                
                //Upto Here
                
            } else {
                eve.Start_Date_Time_Last_Modified_Date__c = null;    
                eve.of_Times_Start_Date_Time_Updated__c = null;
                eve.Cancelled_Did_Not_Occur_Last_Modify_Date__c = null;
            }        
        }
    }

    /**
     *  @description    :   Method to populate Next Activity Date field value on Opportunity record 
     *                      on the basis of associated events corresponding field value.
     *
     *  @args           :   List of new events, Old evenets map
     *
     *  @return         :   void
     *
     **/
    public static void updateNextActivityDate(List<Event> newEvents, Map<Id, Event> mapOldEvents) {

        //Map of opportunity
        Map<Id, Opportunity> mapOpportunites = new Map<Id, Opportunity>();
        
        //Map of eligible event record types
        Map<Id, RecordType> mapEventRecordTypes =  new Map<Id, RecordType>([SELECT id , DeveloperName FROM RecordType 
                                                    WHERE DeveloperName IN ('BI_Marketing' , 'Core_Marketing')
                                                    AND IsActive = true 
                                                    AND SobjectType = 'Event']);
        
        //Insert/update use cases
        if(newEvents != null) {
            
            //Loop through trigger.new event records
            for(Event e : newEvents) {
                
                //Insert use case
                if(mapOldEvents == null) {
                    
                    //Checking and validating for additional filters
                    if(e.WhatId != null 
                        && e.WhatId.getSObjectType() == Schema.Opportunity.SobjectType
                        && e.Cancelled_Did_Not_Occur__c == false
                        && e.RecordTypeId != null
                        && mapEventRecordTypes != null
                        && mapEventRecordTypes.get(e.RecordTypeId) != null)
                        mapOpportunites.put(e.WhatId, new Opportunity(Id = e.WhatId, Next_Activity_Date__c = null));       
                }    
                    
                //Update use case
                if(mapOldEvents != null) {
                    
                    //Checking for the field value change on event update
                    if(e.StartDateTime != mapOldEvents.get(e.Id).StartDateTime 
                       || e.WhatId != mapOldEvents.get(e.Id).WhatId
                       || e.Event_Type__c != mapOldEvents.get(e.Id).Event_Type__c
                       || e.RecordTypeId != mapOldEvents.get(e.Id).RecordTypeId
                       || e.Cancelled_Did_Not_Occur__c != mapOldEvents.get(e.Id).Cancelled_Did_Not_Occur__c) {
                       
                        //Checking and validating for additional filters
                        if(e.WhatId != null 
                            && e.WhatId.getSObjectType() == Schema.Opportunity.SobjectType
                            && e.RecordTypeId != null
                            && mapEventRecordTypes != null
                            && mapEventRecordTypes.get(e.RecordTypeId) != null )
                            mapOpportunites.put(e.WhatId, new Opportunity(Id = e.WhatId, Next_Activity_Date__c = null));          
                        
                        if(mapOldEvents.get(e.Id).WhatId != null 
                            && mapOldEvents.get(e.Id).WhatId.getSObjectType() == Schema.Opportunity.SobjectType
                            && mapOldEvents.get(e.Id).RecordTypeId != null
                            && mapEventRecordTypes != null
                            && mapEventRecordTypes.get(mapOldEvents.get(e.Id).RecordTypeId) != null )
                            mapOpportunites.put(mapOldEvents.get(e.Id).WhatId, new Opportunity(Id = mapOldEvents.get(e.Id).WhatId, Next_Activity_Date__c = null)); 
                           
                    }
                }
            }
        }
        
        //Delete use case
        else {
            
            //Loop through trigger.old event records
            for(Event et : mapOldEvents.values()) {
                
                if(mapOldEvents.get(et.Id).WhatId != null 
                   && et.WhatId.getSObjectType() == Schema.Opportunity.SobjectType
                   && et.Cancelled_Did_Not_Occur__c == false
                   && et.RecordTypeId != null
                   && mapEventRecordTypes != null
                   && mapEventRecordTypes.get(et.RecordTypeId) != null)
                   mapOpportunites.put(mapOldEvents.get(et.Id).WhatId, new Opportunity(Id = mapOldEvents.get(et.Id).WhatId, Next_Activity_Date__c = null)); 
            }
        }
        
        //Checking set for size value
        if(mapOpportunites != null && mapOpportunites.size() > 0) {
            
            //Loop through opportunity records
            for(Opportunity opp : [SELECT ID, Next_Activity_Date__c,
                                    (SELECT ID, WhatId, StartDateTime FROM events 
                                     WHERE WhatId != null AND WhatId IN : mapOpportunites.keySet()
                                        AND RecordTypeID != null AND RecordTypeID IN : mapEventRecordTypes.keySet()
                                        AND Cancelled_Did_Not_Occur__c = false
                                        AND StartDateTime != null AND StartDateTime > TODAY
                                        ORDER BY StartDateTime ASC LIMIT 1)
                                  FROM Opportunity WHERE ID IN : mapOpportunites.keySet()]) {
                
                //Checking for associated events list size value
                if(opp.events != null && opp.events.size() > 0) {
                     if(mapOpportunites.containsKey(opp.Id) && mapOpportunites.get(opp.Id) != null 
                       && opp.events[0].StartDateTime != null)
                        mapOpportunites.get(opp.Id).Next_Activity_Date__c = Date.valueof(opp.events[0].StartDateTime);       
                }
            }
            
            //Updating opportunity records
            util.BypassAllTriggers = true;
            update mapOpportunites.values();
            util.BypassAllTriggers = false;
        }
    }
   
    /**
     *  @description    :   This method is to check if event is being created, updated or deleted, 
     *                      update the most recent membership data on Opporutnity
     *
     *  @args           :   List of new events, Old evenets map
     *
     *  @return         :   void
     *
     **/
    public static void populateMostRecentQACall(List<Event> newEvents, Map<Id, Event> mapOldEvents) {

        //Create a set of membership ids
        Set<Id> membershipIds = new Set<Id>();

        //Insert
        if(newEvents != null && mapOldEvents == null) {

            //Loop through the records
            for(Event event : newEvents) {

                //Check if event is related to membership
                if(event.WhatId != null && event.WhatId.getSObjectType() == Schema.Membership__c.SobjectType) {

                    //Add in set to be processed
                    membershipIds.add(event.WhatId);
                }
            }
        } else if(newEvents != null && mapOldEvents != null) {

            //Chekc if event was and is realted to membership or any of the event attribute has been changed
            //Loop through the records
            for(Event event : newEvents) {
                
                //Mahendra - 5/11/2016 - CR-20160219-9619 - Modified to add a check when Event Grades are changed
                //Mahendra - 8/26/2016 - CR-20160606-9903 - Modified to add a check when Event record type is changed
                //Check if event is related to membership
                if(event.WhatId != null && event.WhatId.getSObjectType() == Schema.Membership__c.SobjectType &&
                        (event.WhatId != mapOldEvents.get(event.Id).WhatId
                            || event.Cancelled_Did_Not_Occur__c !=  mapOldEvents.get(event.Id).Cancelled_Did_Not_Occur__c
                            || event.StartDateTime !=  mapOldEvents.get(event.Id).StartDateTime
                            || event.Event_Type__c !=  mapOldEvents.get(event.Id).Event_Type__c
                            || event.Grade__c !=  mapOldEvents.get(event.Id).Grade__c
                            || event.RecordTypeId !=  mapOldEvents.get(event.Id).RecordTypeId)) {

                    //Add in set to be processed
                    membershipIds.add(event.WhatId);
                }

                //Chekc if Old was not null and related to membership
                if(mapOldEvents.get(event.Id).WhatId != null
                    && mapOldEvents.get(event.Id).WhatId.getSObjectType() == Schema.Membership__c.SobjectType
                    && event.WhatId != mapOldEvents.get(event.Id).WhatId) {

                    //Add in set to be processed
                    membershipIds.add(mapOldEvents.get(event.Id).WhatId);
                }
            }
        } else if(newEvents == null && mapOldEvents != null) {

            //Loop through the records
            for(Event event : mapOldEvents.values()) {

                //Check if event is related to membership
                if(event.WhatId != null && event.WhatId.getSObjectType() == Schema.Membership__c.SobjectType) {

                    //Add in set to be processed
                    membershipIds.add(event.WhatId);
                }
            }
        }

        //Check for the membership set size and call the method to reset the data
        if(membershipIds.size() > 0) {

            //Call the helper class method
            MembershipTriggerHelper.PopulateMostRecentQACall(membershipIds);
        }
    }
    
    //Added By - Abhinav Sharma- 08/26/2015 - CR-20140613-5790 - New Fields to track PAs
    /**
     *  @description    :   This method is to update the PA's and Activities fields on Opporutnity record,
     *                      if an event is being created, updated or deleted under it.
     *                      
     *  @args           :   List of new events, Old evenets map
     *
     *  @return         :   void
     *
    **/
    public static void populatePAsAndActivityFieldsOnOpportunity(List<Event> newEvents, Map<Id, Event> mapOldEvents) {
        
        //Map of Opportunities
        Map<Id, Opportunity> mapOpportunities = new Map<Id, Opportunity>();
                
        //Loop through event records
        for(Event eve : newEvents != null ? newEvents : mapOldEvents.values()) {
            
            //Insert case
            if(mapOldEvents == null && eve.WhatId != null && eve.WhatId.getSObjectType() == Schema.Opportunity.SobjectType)
                mapOpportunities.put(eve.WhatId, new Opportunity(ID = eve.WhatId,
                                                                 Initial_PA_Date__c = null,
                                                                 Initial_Activity_Date__c = null,
                                                                 Current_YTD_Initial_Pas__c = null,
                                                                 Prev_YTD_Initial_Pas__c = null,
                                                                 Scheduled_Initial_Pas__c = null,
                                                                 Current_Year_Initial_Pas__c = null,
                                                                 Previous_Year_Initial_Pas__c = null,
                                                                 Current_YTD_Initial_Activities__c = null,
                                                                 Prev_YTD_Initial_Activities__c = null,
                                                                 Scheduled_Initial_Activities__c = null,
                                                                 Current_Year_Initial_Activities__c = null,
                                                                 Previous_Year_Initial_Activities__c = null,
                                                                 Total_Initial_Pas__c = null,
                                                                 Total_Initial_Activities__c = null));
            
            //Update case
            if(mapOldEvents != null 
               && (
                   eve.WhatId != mapOldEvents.get(eve.Id).WhatId
                    || eve.Event_Purpose__c != mapOldEvents.get(eve.Id).Event_Purpose__c
                    || eve.Event_Type__c != mapOldEvents.get(eve.Id).Event_Type__c
                    || eve.Cancelled_Did_Not_Occur__c != mapOldEvents.get(eve.Id).Cancelled_Did_Not_Occur__c
                    || eve.Count__c != mapOldEvents.get(eve.Id).Count__c
                    || eve.ActivityDate != mapOldEvents.get(eve.Id).ActivityDate
                  )
            ) {
                
                //Checking for null value
                if(eve.WhatId != null && eve.WhatId.getSObjectType() == Schema.Opportunity.SobjectType)
                    mapOpportunities.put(eve.WhatId, new Opportunity(ID = eve.WhatId,
                                                                     Initial_PA_Date__c = null,
                                                                     Initial_Activity_Date__c = null,
                                                                     Current_YTD_Initial_Pas__c = null,
                                                                     Prev_YTD_Initial_Pas__c = null,
                                                                     Scheduled_Initial_Pas__c = null,
                                                                     Current_Year_Initial_Pas__c = null,
                                                                     Previous_Year_Initial_Pas__c = null,
                                                                     Current_YTD_Initial_Activities__c = null,
                                                                     Prev_YTD_Initial_Activities__c = null,
                                                                     Scheduled_Initial_Activities__c = null,
                                                                     Current_Year_Initial_Activities__c = null,
                                                                     Previous_Year_Initial_Activities__c = null,
                                                                     Total_Initial_Pas__c = null,
                                                                     Total_Initial_Activities__c = null));
                
                //Checking for null value        
                if(mapOldEvents.get(eve.Id).WhatId != null && mapOldEvents.get(eve.Id).WhatId.getSObjectType() == Schema.Opportunity.SobjectType)
                    mapOpportunities.put(mapOldEvents.get(eve.Id).WhatId, new Opportunity(ID = mapOldEvents.get(eve.Id).WhatId,
                                                                                          Initial_PA_Date__c = null,
                                                                                          Initial_Activity_Date__c = null,
                                                                                          Current_YTD_Initial_Pas__c = null,
                                                                                          Prev_YTD_Initial_Pas__c = null,
                                                                                          Scheduled_Initial_Pas__c = null,
                                                                                          Current_Year_Initial_Pas__c = null,
                                                                                          Previous_Year_Initial_Pas__c = null,
                                                                                          Current_YTD_Initial_Activities__c = null,
                                                                                          Prev_YTD_Initial_Activities__c = null,
                                                                                          Scheduled_Initial_Activities__c = null,
                                                                                          Current_Year_Initial_Activities__c = null,
                                                                                          Previous_Year_Initial_Activities__c = null,
                                                                                          Total_Initial_Pas__c = null,
                                                                                          Total_Initial_Activities__c = null));        
            }
            
            //Delete Case
            if(newEvents == null && mapOldEvents != null && mapOldEvents.get(eve.Id).WhatId != null && mapOldEvents.get(eve.Id).WhatId.getSObjectType() == Schema.Opportunity.SobjectType)
                mapOpportunities.put(mapOldEvents.get(eve.Id).WhatId, new Opportunity(ID = mapOldEvents.get(eve.Id).WhatId,
                                                                                        Initial_PA_Date__c = null,
                                                                                        Initial_Activity_Date__c = null,
                                                                                        Current_YTD_Initial_Pas__c = null,
                                                                                        Prev_YTD_Initial_Pas__c = null,
                                                                                        Scheduled_Initial_Pas__c = null,
                                                                                        Current_Year_Initial_Pas__c = null,
                                                                                        Previous_Year_Initial_Pas__c = null,
                                                                                        Current_YTD_Initial_Activities__c = null,
                                                                                        Prev_YTD_Initial_Activities__c = null,
                                                                                        Scheduled_Initial_Activities__c = null,
                                                                                        Current_Year_Initial_Activities__c = null,
                                                                                        Previous_Year_Initial_Activities__c = null,
                                                                                        Total_Initial_Pas__c = null,
                                                                                        Total_Initial_Activities__c = null));  
        }
        
        //Checking set for size value
        if(mapOpportunities.values().size() > 0) {
            
            //Populating opportunity fields values
            mapOpportunities = populatePAsAndActivityFields(mapOpportunities);
            
            //Updating opportunity records
            if(mapOpportunities.values().size() > 0)
                update mapOpportunities.values();
        }
    }
    
    //Added By - Abhinav Sharma- 08/26/2015 - CR-20140613-5790 - New Fields to track PAs
    public static Map<Id, Opportunity> populatePAsAndActivityFields(Map<Id, Opportunity> mapOpps) {
        
        //Checking map for null and size value
        if(mapOpps != null && mapOpps.values().size() > 0) {
                
            //Set to hold the event purpose values - eligible for PA types
            Set<String> setEventPurposeForPAs = new Set<String>();
            setEventPurposeForPAs.add('Initial');
            setEventPurposeForPAs.add('Intro PA');
            
            //Querying PA's events and accordingly populating PA's fields on related opportunity
            for(Event ev : [SELECT ID, ActivityDate, WhatId FROM Event
                                WHERE WhatId != null AND WhatId IN : mapOpps.keySet()
                                    AND Event_Type__c = 'Phone Appointment'
                                    AND Event_Purpose__c IN : setEventPurposeForPAs
                                    AND Cancelled_Did_Not_Occur__c = false
                                    AND Count__c = 1
                                    AND ActivityDate != null AND IsDeleted = false ALL ROWS]) {
                
                //Checking if map contains the key in it                        
                if(mapOpps.containsKey(ev.WhatId) 
                    && mapOpps.get(ev.WhatId) != null) {
                    
                    //Initial_PA_Date__c
                    if(mapOpps.get(ev.WhatId).Initial_PA_Date__c == null) {
                        mapOpps.get(ev.WhatId).Initial_PA_Date__c = ev.ActivityDate;
                    } else {
                        if(mapOpps.get(ev.WhatId).Initial_PA_Date__c > ev.ActivityDate) {
                            mapOpps.get(ev.WhatId).Initial_PA_Date__c = ev.ActivityDate;
                        }
                    }        
                    
                    //Count all related PA’s with Activity Date is in current year and less or equal to today.
                    //Current_YTD_Initial_Pas__c
                    if(ev.ActivityDate.Year() == System.today().year()
                        && ev.ActivityDate <= System.today()) {
                        if(mapOpps.get(ev.WhatId).Current_YTD_Initial_Pas__c == null)
                            mapOpps.get(ev.WhatId).Current_YTD_Initial_Pas__c = 1;
                        else
                            mapOpps.get(ev.WhatId).Current_YTD_Initial_Pas__c = mapOpps.get(ev.WhatId).Current_YTD_Initial_Pas__c + 1;
                    }
                        
                    //Previous Year same Date value as Today
                    Date previousYearTodaysDate = Date.newinstance((System.today().year()-1), System.today().month(), System.today().day());    
                        
                    //Count all related Initial PAs for which Activity Date is in previous year and less than today’s date minus one year.
                    //Prev_YTD_Initial_Pas__c
                    if(ev.ActivityDate.Year() == (System.today().year() - 1)
                        && ev.ActivityDate < previousYearTodaysDate) {
                        if(mapOpps.get(ev.WhatId).Prev_YTD_Initial_Pas__c == null)
                            mapOpps.get(ev.WhatId).Prev_YTD_Initial_Pas__c = 1;
                        else
                            mapOpps.get(ev.WhatId).Prev_YTD_Initial_Pas__c = mapOpps.get(ev.WhatId).Prev_YTD_Initial_Pas__c + 1;    
                    }
                        
                    //Count all related Initial PAs for which Activity Date is greater than today.   
                    //Scheduled_Initial_Pas__c 
                    if(ev.ActivityDate > System.today()) {
                        if(mapOpps.get(ev.WhatId).Scheduled_Initial_Pas__c == null)
                            mapOpps.get(ev.WhatId).Scheduled_Initial_Pas__c = 1;
                        else
                            mapOpps.get(ev.WhatId).Scheduled_Initial_Pas__c = mapOpps.get(ev.WhatId).Scheduled_Initial_Pas__c + 1;    
                    }  
                        
                    //Count all related Initial PAs for which Activity Date is in current year. 
                    //Current_Year_Initial_Pas__c  
                    if(ev.ActivityDate.Year() == System.today().year()) {
                         if(mapOpps.get(ev.WhatId).Current_Year_Initial_Pas__c == null)
                            mapOpps.get(ev.WhatId).Current_Year_Initial_Pas__c = 1;
                        else
                            mapOpps.get(ev.WhatId).Current_Year_Initial_Pas__c = mapOpps.get(ev.WhatId).Current_Year_Initial_Pas__c + 1;  
                    } 
                        
                    //Count all related Initial PAs for which Activity Date is in previous year.
                    //Previous_Year_Initial_Pas__c   
                    if(ev.ActivityDate.Year() == (System.today().year()-1)) {
                        if(mapOpps.get(ev.WhatId).Previous_Year_Initial_Pas__c == null)
                            mapOpps.get(ev.WhatId).Previous_Year_Initial_Pas__c = 1;
                        else
                            mapOpps.get(ev.WhatId).Previous_Year_Initial_Pas__c = mapOpps.get(ev.WhatId).Previous_Year_Initial_Pas__c + 1; 
                    }
                    
                    //Total_Initial_Pas__c    
                    if(mapOpps.get(ev.WhatId).Total_Initial_Pas__c == null)
                        mapOpps.get(ev.WhatId).Total_Initial_Pas__c = 1;
                    else
                        mapOpps.get(ev.WhatId).Total_Initial_Pas__c = mapOpps.get(ev.WhatId).Total_Initial_Pas__c + 1;    
                }
            }
            
            //Querying Activity events and accordingly populating Activity type fields on related opportunity
            for(Event e : [SELECT ID, ActivityDate, WhatId FROM Event
                                WHERE WhatId != null AND WhatId IN : mapOpps.keySet()
                                    AND Event_Type__c != 'Additional Contact Meeting'
                                    AND Event_Purpose__c IN : setEventPurposeForPAs
                                    AND Cancelled_Did_Not_Occur__c = false
                                    AND Count__c = 1
                                    AND ActivityDate != null AND IsDeleted = false ALL ROWS]) {
                                        
                //Checking if map contains the key in it                        
                if(mapOpps.containsKey(e.WhatId) 
                    && mapOpps.get(e.WhatId) != null) {
                        
                    //Minimum Activity Date of the activities on the opportunity
                    //Initial_Activity_Date__c
                    if(mapOpps.get(e.WhatId).Initial_Activity_Date__c == null) {
                        mapOpps.get(e.WhatId).Initial_Activity_Date__c = e.ActivityDate;
                    } else {
                        if(mapOpps.get(e.WhatId).Initial_Activity_Date__c > e.ActivityDate) {
                            mapOpps.get(e.WhatId).Initial_Activity_Date__c = e.ActivityDate;
                        }
                    }      
                    
                    //Count all related activities’s with Activity Date is in current year and less or equal to today.
                    //Current_YTD_Initial_Activities__c
                    if(e.ActivityDate.Year() == System.today().year()
                        && e.ActivityDate <= System.today()) {
                        if(mapOpps.get(e.WhatId).Current_YTD_Initial_Activities__c == null)
                            mapOpps.get(e.WhatId).Current_YTD_Initial_Activities__c = 1;
                        else
                            mapOpps.get(e.WhatId).Current_YTD_Initial_Activities__c = mapOpps.get(e.WhatId).Current_YTD_Initial_Activities__c + 1;
                    }    
                        
                    //Previous Year same Date value as Today
                    Date previousYearTodaysDate = Date.newinstance((System.today().year()-1), System.today().month(), System.today().day());    
                    
                    //Count all related Initial activities for which Activity Date is in previous year and less than today’s date minus one year.
                    //Prev_YTD_Initial_Activities__c
                    if(e.ActivityDate.Year() == (System.today().year() - 1)
                        && e.ActivityDate < previousYearTodaysDate) {
                        if(mapOpps.get(e.WhatId).Prev_YTD_Initial_Activities__c == null)
                            mapOpps.get(e.WhatId).Prev_YTD_Initial_Activities__c = 1;
                        else
                            mapOpps.get(e.WhatId).Prev_YTD_Initial_Activities__c = mapOpps.get(e.WhatId).Prev_YTD_Initial_Activities__c + 1;    
                    }    
                        
                    //Count all related Initial PAs for which Activity Date is greater than today.
                    //Scheduled_Initial_Activities__c    
                    if(e.ActivityDate > System.today()) {
                        if(mapOpps.get(e.WhatId).Scheduled_Initial_Activities__c == null)
                            mapOpps.get(e.WhatId).Scheduled_Initial_Activities__c = 1;
                        else
                            mapOpps.get(e.WhatId).Scheduled_Initial_Activities__c = mapOpps.get(e.WhatId).Scheduled_Initial_Activities__c + 1;    
                    }      
                        
                    //Count all related Initial PAs for which Activity Date is in current year.  
                    //Current_Year_Initial_Activities__c 
                    if(e.ActivityDate.Year() == System.today().year()) {
                         if(mapOpps.get(e.WhatId).Current_Year_Initial_Activities__c == null)
                            mapOpps.get(e.WhatId).Current_Year_Initial_Activities__c = 1;
                        else
                            mapOpps.get(e.WhatId).Current_Year_Initial_Activities__c = mapOpps.get(e.WhatId).Current_Year_Initial_Activities__c + 1;  
                    } 
                        
                    //Count all related Initial PAs for which Activity Date is in previous year.
                    //Previous_Year_Initial_Activities__c   
                    if(e.ActivityDate.Year() == (System.today().year()-1)) {
                        if(mapOpps.get(e.WhatId).Previous_Year_Initial_Activities__c == null)
                            mapOpps.get(e.WhatId).Previous_Year_Initial_Activities__c = 1;
                        else
                            mapOpps.get(e.WhatId).Previous_Year_Initial_Activities__c = mapOpps.get(e.WhatId).Previous_Year_Initial_Activities__c + 1; 
                    }  
                        
                    //Total_Initial_Activities__c    
                    if(mapOpps.get(e.WhatId).Total_Initial_Activities__c == null)
                        mapOpps.get(e.WhatId).Total_Initial_Activities__c = 1;
                    else
                        mapOpps.get(e.WhatId).Total_Initial_Activities__c = mapOpps.get(e.WhatId).Total_Initial_Activities__c + 1;      
                }                            
            }    
        }
        return mapOpps;
    }
}