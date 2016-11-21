// - 06/12/2012 - Simplyforce(Bhavi) - Code modified as per the CR-20120417-730
// - 04/30/2013 - Victor - Code modified as per the CR-20130221-2554
// - 02/12/2014 - Abhinav Sharma (UpdateNextDecisionDate) method updated for CR-20130822-3489 - it uses System.Update() with AllOrNone = false so one failure won't cause the entire batch to fail.
// - 04/16/2014 - Abhinav Sharma - CR-20140321-4841 - (Added IsDeleted = false to the WHERE clause in the getTasksWithUpdatedProgInfo and getEventsWithUpdatedProgInfo methods)
// - 08/06/2014 - Ajit Surana - CR-20140717-6282 - (MembershipsWithOpps) method updated - Removed the Record Type criteria from Opportunity inline query.
// - 09/15/2014 - Abhinav Sharma - CR-20140429-5272 - Modified to removed the existing Bundle_Parent__c references & commenting of it
//- 04/03/2015 - Abhinav Surana - CR-20150220-8700 - Query modified at line# 167 - Added idDeleted = false and ALL ROWS to it
//Modified By - Abhinav Sharma - 10/17/2015 - CR-20151008-9304 - Triggers repetative execution
public without sharing class OpportunityTriggerUtilities {
    
    public static void UpdateContractDocs(List<Opportunity> triggerNew, Map<Id, Opportunity> triggerOldMap) {
        
        // return immediately if this is a mass insert/update -- should not need to connect docs in these scenarios
        if (triggerNew.size() > 1) return;
        
        Set<Id> contractIds = new Set<Id>();
        
        for (Opportunity newOpp : triggerNew) {
            Opportunity oldOpp = new Opportunity();
            if (triggerOldMap!= null) {
                oldOpp = triggerOldMap.get(newOpp.Id);
            }
            
            if (oldOpp != null) {
                if (newOpp.Signed_Opportunity_Contract__c != null && oldOpp.Signed_Opportunity_Contract__c != newOpp.Signed_Opportunity_Contract__c) {
                    contractIds.add(newOpp.Signed_Opportunity_Contract__c);
                }
                /* VRH 4/23/12 - per JMathews, we dont want to populate docs on opps Booked from contracts
                if (newOpp.Previous_Contract__c != null && oldOpp.Previous_Contract__c != newOpp.Previous_Contract__c) {
                    contractIds.add(newOpp.Previous_Contract__c);
                }*/
            }
            else {
                if (newOpp.Signed_Opportunity_Contract__c != null) {
                    contractIds.add(newOpp.Signed_Opportunity_Contract__c);
                }
                /* VRH 4/23/12 - per JMathews, we dont want to populate docs on opps Booked from contracts
                if (newOpp.Previous_Contract__c != null) {
                    contractIds.add(newOpp.Previous_Contract__c);
                }*/
            }
        }
        
        if (contractIds.size() > 0) {
            
            //Bhavi Sharma - 04/26/2013 - CR-20130227-2597 - Added condition to make the callout only if not current context is not batch or future
            if(!System.isFuture() && !System.isBatch())
                GlobalUtilities.ConnectDocsToContract(contractIds);
            
            //Bhavi Sharma - 04/26/2013 - CR-20130227-2597 - Added condition to make the callout only if not current context is not batch or future
            if(!System.isFuture() && !System.isBatch())
                GlobalUtilities.ConnectDocsToOpp(contractIds);
        }
    }
    
    public static void CalculateNextDecisionDate(List<Opportunity> triggerNew) {
        //List<Membership__c> membershipsToUpdate = new List<Membership__c>();
        Set<Id> memIds = new Set<Id>();
        for (Opportunity o : triggerNew)
            memIds.add(o.Membership__c);
        
        List<Membership__c> memberships = MembershipsWithOpps(memIds, triggerNew);
        
        // now run the logic to calculate the next decision date
        UpdateNextDecisionDate(memberships);
    }
    
    public static Set<Id> PTRenewalOppIds() {
        // get the PT Renewal opportunity record types
        Set<Id> RenewalRecordTypeIds = new Set<Id>();
        String ptContractMaintenance = Util.RecordTypeId('Opportunity', 'PT Contract Maintenance');
        String ptContractRenewal = Util.RecordTypeId('Opportunity', 'PT Contract Renewal');
        // add these ids to the list of renewal record types ids
        RenewalRecordTypeIds.add(ptContractMaintenance);
        RenewalRecordTypeIds.add(ptContractRenewal);
        return RenewalRecordTypeIds;
    }
    
    //Modified by - Ajit Surana - 08/06/2014 - CR-20140717-6282
    //Remove the Record Type criteria from Opportunity inline query
    public static List<Membership__c> MembershipsWithOpps(Set<Id> memIds, List<Opportunity> opps) {
        Set<Id> PTRenewalOppIds = PTRenewalOppIds();
        // get all memberships with the associated Opportunities
        List<Membership__c> memberships = [SELECT Id, Next_Decision_Date__c, 
                                        (SELECT Id, Start__c, Opt_Out_Date__c FROM Opportunities__r 
                                        WHERE StageName LIKE '%Pending%' AND Start__c >= :system.today() ORDER BY Start__c ASC) FROM Membership__c 
                                        WHERE Id IN :memIds];
        return memberships;
    }
    
    public static string UpdateNextDecisionDate(List<Membership__c> memberships) {
        // loop through all memberships and figure out the next decision date
        for (Membership__c m : memberships) {
            // clear out the next decision date for any memberships that are in the list
            m.Next_Decision_Date__c = null;
            
            // if there is an opportunity present, take the first value as the next decision date
            // (the proper sorting and filtering took place in the query)
            if (m.Opportunities__r.size() > 0) {
                // the earliest pending renewal opportunity
                Opportunity earliestPendingRenewalOpp = m.Opportunities__r[0];
                
                if (earliestPendingRenewalOpp.Opt_Out_Date__c != null) {
                    m.Next_Decision_Date__c = earliestPendingRenewalOpp.Opt_Out_Date__c;
                }
                else {
                    if (earliestPendingRenewalOpp.Start__c != null)
                        m.Next_Decision_Date__c = earliestPendingRenewalOpp.Start__c.addDays(-1);
                }
            }
        }
        
        Util.BypassAllTriggers = true;
        Util.IsBatch = true;
        
        // update all of our memberships
        //Modified By Abhinav Sharma - 02/12/2014 - Modify Batch_MembershipNextActivityDate to it uses System.Update() with AllOrNone = false so one failure won't cause the entire batch to fail.
        //Also, if there are failures in the database.saveResults[], they should be recorded and emailed to SFAdmin. - CR-20130718-3280
        //Database.update will be called only if current context is batch, else existing functionality willwork
        
        String logMessage = '';
        
        if(System.isBatch()) {
            
            logMessage = Util.createLog(Database.update((memberships),false));
        } else {
            update memberships;
        }
        
        Util.BypassAllTriggers = false;
        Util.IsBatch = false;
        return logMessage;
        
    }
    
    //CR-20111205-259
    //Static variable to hold the opportuny records to be updated
    public static Map<Id, Opportunity> opportunities;
    
    //Modified By - Abhinav Sharma - 09/15/2014 - CR-20140429-5272 - Removed the existing Bundle_Parent__c references
    // This method is to update the Initial Visit Date on opportunity object with the most recent active event
    //if no active event is there flag will be false
    public static void updateInitialVisitDateByEventDate(Map<Id, Opportunity> mapOpportunities){
        
        /*//Create a set to hold the Bundle Opportunity records
        Set<Id> bundleOpportunityIds = new Set<Id>();
        
        //Map to hold the Bundle opportunity data
        Map<Id, Opportunity> mapBundledOpportunity = new Map<Id, Opportunity>();*/
        
        //Check if code is running from Opportunity before context
        /*if(Trigger.isBefore && Trigger.New.size() > 0 && Trigger.New[0] instanceOf Opportunity) {
            
            //Commented By - Abhinav Sharma - 09/15/2014 - CR-20140429-5272 - Removed the existing Bundle_Parent__c references
            //Loop through the new records
            for(Opportunity opp : mapOpportunities.values()) {
                
                if(opp.Bundle_Parent__c != null)
                    bundleOpportunityIds.add(opp.Bundle_Parent__c);
            }
            
            //Populate data in map
            //mapBundledOpportunity = new Map<Id, Opportunity>([Select Id, Initial_Visit_Date__c from Opportunity where ID IN: bundleOpportunityIds]);
        }*/
        
        //Map to hold the Opportunity ID as key and corresponding event record as value
        Map<Id, Event> mapOppIdWithEvent = new Map<Id, Event>();
        
        //Modified By - Ajit Surana - 04/03/2015 - CR-20150220-8700 - Query modified - Added idDeleted = false and ALL ROWS to it
        //Loop through event records
        for(Event evt : [Select Id, StartDateTime, WhatId from Event WHERE WhatId != null AND WhatId IN : mapOpportunities.keySet()
                            AND isDeleted=false 
                            AND Cancelled_Did_Not_Occur__c = false  
                            AND (Event_Type__c =: Constants.EVENT_TYPE_OPPORTUNITY_VISIT_FOR_OPPORTUNITY_GOAL 
                                 OR (Event_Type__c =: Constants.EVENT_TYPE_IN_PERSON_VISIT AND 
                                     (Event_Purpose__c =: Constants.EVENT_PURPOSE_INITIAL OR Event_Purpose__c =: Constants.EVENT_PURPOSE_RELATIONSHIP_VISIT))
                                 OR Event_Type__c =: Constants.EVENT_TYPE_PROSPECT_MEETING_ATTENDEE_COUNT_AS_VISIT) 
                            ORDER BY StartDateTime ASC ALL ROWS]) {
            if(!mapOppIdWithEvent.containsKey(evt.WhatId))
                mapOppIdWithEvent.put(evt.WhatId, evt);                         
        }
        
        //Checking map for size value
        if(mapOpportunities.keySet().size() > 0) {
            
            //Modified By - Abhinav Sharma - 09/15/2014 - CR-20140429-5272 - Removed the existing Bundle_Parent__c references
            //if(OpportunityTriggerHelper.DO_NOT_EXECUTE == false) {
            //fecth all the events associated with the opportunities
            //and loop through the records to get the lastest active event
            for(Opportunity opp : [Select Id, Initial_Visit_Date__c 
                                        FROM Opportunity where Id IN : mapOpportunities.keySet()]) {
                
                //Commented By - Abhinav Sharma - 09/15/2014 - CR-20140429-5272 - Removed the existing Bundle_Parent__c references
                // - 06/12/2012 - Simplyforce(Bhavi) - Code modified as per the CR-20120417-730
                //Populate Initial_Visit_Date__c field iwith the Bundle_Parent__c's Initial_Visit_Date__c date .
                /*if(mapOpportunities.get(opp.Id).Bundle_Parent__c != null) {
                    if(opp.Bundle_Parent__c != null && opp.Bundle_Parent__r.Initial_Visit_Date__c != null) {
                    
                        //Set Initial Visit Date with Bundle Parent Opportunity Initial Visit Date
                        mapOpportunities.get(opp.Id).Initial_Visit_Date__c = opp.Bundle_Parent__r.Initial_Visit_Date__c;
                    } else if(mapBundledOpportunity.containsKey(mapOpportunities.get(opp.Id).Bundle_Parent__c)){
                        
                        //Set Initial Visit Date with Bundle Parent Opportunity Initial Visit Date
                        mapOpportunities.get(opp.Id).Initial_Visit_Date__c = mapBundledOpportunity.get(mapOpportunities.get(opp.Id).Bundle_Parent__c).Initial_Visit_Date__c;
                    }
                } else if(Trigger.New != null && Trigger.New.size() > 0 && Trigger.New[0] instanceOf Event && opp.Bundle_Parent__c != null && opp.Bundle_Parent__r.Initial_Visit_Date__c != null) {
                    
                    //Set Initial Visit Date with Bundle Parent Opportunity Initial Visit Date
                    mapOpportunities.get(opp.Id).Initial_Visit_Date__c = opp.Bundle_Parent__r.Initial_Visit_Date__c;
                }*/ 
                                            
                //Check if there is any active event is assciated 
                if(mapOppIdWithEvent.containsKey(opp.Id) && mapOppIdWithEvent.get(opp.Id) != null 
                    && mapOppIdWithEvent.get(opp.Id).StartDateTime != null) {
                    
                    //As discuseed with VH:If an event with a start date > the opportunity’s Initial Vistit Date, 
                    //that should not overwrite the earlier initial visit date on the Opportunity. However, 
                    //if a new event is created for a qualifying initial visit and the StartDateTime is LESS 
                    //than the current Initial Visit Date on the Opportunity, that should overwrite the 
                    //Opportunity’s Initial Visit date with the earliest visit date.
                    if(mapOpportunities.get(opp.Id).Initial_Visit_Date__c == null 
                        || mapOpportunities.get(opp.Id).Initial_Visit_Date__c > Date.valueOf(mapOppIdWithEvent.get(opp.Id).StartDateTime)) {
                        
                        //Not Cancelled latest event: So copy this date to opportunity's Initial Visit Date
                        mapOpportunities.get(opp.Id).Initial_Visit_Date__c = Date.valueOf(mapOppIdWithEvent.get(opp.Id).StartDateTime);
                    }
                } else {
                    
                    //No events associted with this opportunity record or all events have been cancelled so mark Initial Visit Date as null
                    mapOpportunities.get(opp.Id).Initial_Visit_Date__c = null;
                }
            }
        }    
    }
    
    // update the program and program abbreviation field on all tasks/events associated with an opportunity
    public static void populateProgramInfoToActivities(list<Opportunity> newOpps, Map<Id, Opportunity> oldOppMap) {
        
        // create a map of opportunities
        map<Id, Opportunity> mapOppsWithUpdatedPrograms = new map<Id, Opportunity>();
        
        // see if the opportunity's program changed
        for (Opportunity opp : newOpps) {
            
            // get the old opp if applicable
            Opportunity oldOpp;
            if (oldOppMap != null) 
                oldOpp = oldOppMap.get(opp.Id);
            
            if (oldOpp == null || opp.Program__c != oldOpp.Program__c) {
                
                mapOppsWithUpdatedPrograms.put(opp.Id, opp);
            }
        }

		//Checking map for size value        
        if (mapOppsWithUpdatedPrograms.size() > 0) {
            
            // get the opportunity map with program info
            mapOppsWithUpdatedPrograms = new map<Id, Opportunity>([SELECT Id, Program__c, Program__r.Program_Acronym__c, Program__r.Program_Abbreviation__c
                                          FROM Opportunity WHERE Id IN :mapOppsWithUpdatedPrograms.keySet()]);
            
            // for all opportunities that have updated program, we need to update their associated events/tasks
            list<Task> tasksToUpdate = getTasksWithUpdatedProgInfo(mapOppsWithUpdatedPrograms);
            list<Event> eventToUpdate = getEventsWithUpdatedProgInfo(mapOppsWithUpdatedPrograms);
            
            // bypass all triggers prior to update
            util.BypassAllTriggers = true;
            
            // update the tasks/events
            if (tasksToUpdate.size() > 0) update tasksToUpdate;
            if (eventToUpdate.size() > 0) update eventToUpdate;
            
            // turn off the trigger bypass
            util.BypassAllTriggers = false;
        }
    }
    
    //Modified By - Abhinav Sharma - 04/16/2014 - CR-20140321-4841 - Unable to change Opportunity Program if related Event is deleted 
    //Added IsDeleted = false to the WHERE clause
    public static list<Task> getTasksWithUpdatedProgInfo(map<Id, Opportunity> oppMap) {
        
    	// setup the list of tasks to return
        list<Task> tasksToReturn = new List<Task>();
    	
        //Checking for null value and size value
        if(oppMap != null && oppMap.keySet().size() > 0) {
        
            // setup the list of tasks to return
            tasksToReturn = [SELECT Id, WhatId, Program__c, Program_Abbreviation__c FROM Task 
                             	WHERE IsDeleted = false AND WhatId IN :oppMap.keySet() ALL ROWS];
        
            //Checking for size value
            if (tasksToReturn.size() > 0) {
                
                // populate the program / abbreviation on all tasks
                tasksToReturn = populateProgInfo_Tasks(oppMap, tasksToReturn);
            }
        }    
        return tasksToReturn;
    }
    
    //Modified By - Abhinav Sharma - 04/16/2014 - CR-20140321-4841 - Unable to change Opportunity Program if related Event is deleted 
    //Added IsDeleted = false to the WHERE clause
    public static list<Event> getEventsWithUpdatedProgInfo(map<Id, Opportunity> oppMap) {
        
        // setup the list of tasks to return
        list<Event> eventsToReturn = new List<Event>();
        
        //Checking for null value and size value
        if(oppMap != null && oppMap.keySet().size() > 0) {
        	eventsToReturn = [SELECT Id, WhatId, Program__c, Program_Abbreviation__c FROM Event 
        						WHERE IsDeleted = false AND WhatId IN :oppMap.keySet() ALL ROWS];
        
            //Checking for size value
        	if (eventsToReturn.size() > 0) {
            
                // populate the program / abbreviation on all events
                eventsToReturn = populateProgInfo_Events(oppMap, eventsToReturn);
        	}
        }
        return eventsToReturn;
    }
    
    // popualte the program and abbreviation info on a given list of events
    public static list<Event> populateProgInfo_Events(map<Id, Opportunity> oppMap, list<Event> events) {
        
        // get all tasks associated with these opps and update their program / program abbreviation
        for (Event e : events) {
            
            //Checking for null and size value
            if (oppMap != null && oppMap.containsKey(e.WhatId) && oppMap.get(e.WhatId) != null) {
                
                // get the asociated opp
                Opportunity opp = oppMap.get(e.WhatId);
                
                if (opp.Program__c != null) {
                    
                    // update the program / abbreviation
                    e.Program__c = opp.Program__r.Program_Acronym__c;
                    e.Program_Abbreviation__c = opp.Program__r.Program_Abbreviation__c;
                }
                else {
                    
                    e.Program__c = null;
                    e.Program_Abbreviation__c = null;
                }
            }
        }
        
        return events;
    }
    
    // popualte the program and abbreviation info on a given list of events   
    public static list<Task> populateProgInfo_Tasks(map<Id, Opportunity> oppMap, list<Task> tasks) {
        
        // get all tasks associated with these opps and update their program / program abbreviation
        for (Task t : tasks) {
            
            //Checking for null value and size value
            if (oppMap != null && oppMap.containsKey(t.WhatId) && oppMap.get(t.WhatId) != null) {
                
                // get the asociated opp
                Opportunity opp = oppMap.get(t.WhatId);
                
                if (opp.Program__c != null) {
                    
                    // update the program / abbreviation
                    t.Program__c = opp.Program__r.Program_Acronym__c;
                    t.Program_Abbreviation__c = opp.Program__r.Program_Abbreviation__c;
                }
                else {
                    
                    t.Program__c = null;
                    t.Program_Abbreviation__c = null;
                }
            }
        }
        
        return tasks;
    }  
}