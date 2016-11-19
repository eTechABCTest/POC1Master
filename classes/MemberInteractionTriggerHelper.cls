/**
*   Purpose         :   This class is helper class for Trigger on Member Interactions.
*
*   Create By       :   Bhavi Sharma
*
*   Created Date    :   06/13/2013
*
*   Current Version :   v1.0
*
*   Revision Logs   :   v1.0 - Created - CR-20130228-2612
                        V_1.1 - Bhavi Sharma - 12/20/2013 - New method added(updateOpportunityELSSentCounter) - CR-20130925-3694
                        V_1.2 - 02/04/2014 - Bhavi Sharma - New methods added (UpdateInteractionInformationByContactIds) - CR-20140124-4353
                        V_1.3 - 04/18/2014 - Abhinav Sharma - New Method added (ValidateAndPopulateDataOnInteratcionRecords) - CR-20130730-3316
                        V_1.4 - Mahendra Swarnkar - CR-20160610-9915 - 08/27/2016 - Added new method "updateDateOfFirstELOnWarmLead"
**/
public without sharing class MemberInteractionTriggerHelper {
    
    //Method to populate lookup on MemberInteraction from associated Membership 
    public static void PopulateMemberInteractionData(List<Call__c> newMemberInteractions) {
        
        //Set for hold project Ids
        Set<Id> projectIds = new Set<Id>();
        
        //Loop through Trigger.new record
        for(Call__c memberInteraction : newMemberInteractions) {
            
            //Check MemberInteraction's Member__c value is not null
            if(memberInteraction.Member__c != null) {
                
                //add Project Id into set of Ids 
                projectIds.add(memberInteraction.Member__c);
            }
        } 
        
        //Check for size of ProjectIds set
        if(projectIds.size() > 0 ) {
                
            //Create a map instance of Key = ProjectId & Values = Project record
            Map<Id, Project__c> mapOfProjects = new Map<Id, Project__c>();
            
            //Loop through Projects list
            for(Project__c project : [SELECT Id, Primary_Paid_Membership__c, Primary_Paid_Membership__r.Account_Name__c FROM Project__c 
                                            WHERE Id IN:projectIds]) {
                
                //put Project record into map
                mapOfProjects.put(project.Id, project);
            }
            
            //check for mapOfProjects size
            if(mapOfProjects.size() > 0) {
                
                //Loop through Trigger.new record
                for(Call__c memberInteraction : newMemberInteractions) {
                    
                    //Check for mapOfProjects contains memberInteraction's project
                    if(mapOfProjects.containsKey(memberInteraction.Member__c )){
                        
                        memberInteraction.Institution__c = mapOfProjects.get(memberInteraction.Member__c).Primary_Paid_Membership__r.Account_Name__c;
                        memberInteraction.Membership__c = mapOfProjects.get(memberInteraction.Member__c).Primary_Paid_Membership__c;
                    }
                }
            }
        }
    }
    
    //Added By - Abhinav Sharma - 04/18/2014 - CR-20130730-3316 - Review MI field "Date in Last"
    /**
     *  @description    :   This method is to update the Call_Date__c on Interaction on the basis of below written logic:-
     *                      If Call_Date__c  is within the last 365 days then 
     *                           Date_in_Past_Year_Counter__c = 1,
     *                      If Call_Date__c is not within the last 365 days then 
     *                           Date_in_Past_Year_Counter__c = 0,
     *
     *  @args           :   List<Call__c> newMemberInteractions 
     *
     *  @return         :   void
     *
    **/
    public static void ValidateAndPopulateDataOnInteratcionRecords(List<Call__c> newMemberInteractions) {
        
        //Loop through list of membersh Interaction records
        for(Call__c mI : newMemberInteractions) {
            
            //Checking for Call Date field value (Proceed further only and only if it is having not null value with it)
            if(mI.Call_Date__c != null) {
                
                //If Call_Date__c  is within the last 365 days then setting Date_in_Past_Year_Counter__c = 1 otherwise 0
                //If Call_Date__c is in future then no value will be set for the field
                if(mI.Call_Date__c > System.today()) {
                    mI.Date_in_Past_Year_Counter__c = null;
                } else {
                    //Checking for status field value and if exist then excluding "Cancelled" or "Void - Delete" values
                    if(String.isBlank(mI.Current_Status__c) || (mI.Current_Status__c != 'Cancelled' && mI.Current_Status__c != 'Void - Delete')) {
                        if(mI.Call_Date__c >= System.today().addDays(-365))
                            mI.Date_in_Past_Year_Counter__c = 1;
                        else
                            mI.Date_in_Past_Year_Counter__c = 0;
                    } else {
                        mI.Date_in_Past_Year_Counter__c = null;
                    }
                }
            } else {
                mI.Date_in_Past_Year_Counter__c = null;
            }
        }
    }
    
    /**
     *  @description    :   This method is to update the ELS Sent counter on Parent Opportunities
     *
     *  @args           :   List of new member interactions, Map of old membership interactions
     *
     *  @return         :   void
     *
     **/ 
    public static void updateOpportunityELSSentCounter(List<Call__c> newMemberInteractions, Map<Id, Call__c> mapOldMemberInteractions ) {
        
        //Set to hold the Opportunity Ids where # of ELS Sent to be updated
        Set<Id> oppIds = new Set<Id>();
        
        //Loop through the records
        //Insert scenario
        if(newMemberInteractions != null && mapOldMemberInteractions == null) {
            
            //Loop through the records
            for(Call__c mI : newMemberInteractions) {
                
                //Check if insert case, then add opportunity in Set directly or in update scenario check if the Opportunity is changed of Status is changed
                if(mI.Opportunity__c != null && mI.Current_Status__c == Constants.MEMBER_INTERACTION_CURRENT_STATUS_COMPLETED)
                    oppIds.add(mI.Opportunity__c);
            }
        }
        
        //Update case
        if(newMemberInteractions != null && mapOldMemberInteractions != null) {
            
            //Loop through the records
            for(Call__c mI : newMemberInteractions) {
                
                //Check if insert case, then add opportunity in Set directly or in update scenario check if the Opportunity is changed of Status is changed
                if((mI.Opportunity__c !=  mapOldMemberInteractions.get(mI.Id).Opportunity__c) 
                    || ((mI.Current_Status__c == Constants.MEMBER_INTERACTION_CURRENT_STATUS_COMPLETED || mapOldMemberInteractions.get(mI.Id).Current_Status__c == Constants.MEMBER_INTERACTION_CURRENT_STATUS_COMPLETED) 
                        && mI.Current_Status__c != mapOldMemberInteractions.get(mI.Id).Current_Status__c)
                ) {
                    
                    //Add Opportunity Id in set
                    if(mI.Opportunity__c != null)
                        oppIds.add(mI.Opportunity__c);
                    if(mapOldMemberInteractions.get(mI.Id).Opportunity__c != null)
                        oppIds.add(mapOldMemberInteractions.get(mI.Id).Opportunity__c);  
                }
            }
        }
        
        //Delete Case
        if(newMemberInteractions == null && mapOldMemberInteractions != null) {
            
            //Loop through the records
            for(Call__c mI : mapOldMemberInteractions.values()) {
                
                //Check if insert case, then add opportunity in Set directly or in update scenario check if the Opportunity is changed of Status is changed
                if(mI.Opportunity__c != null && mI.Current_Status__c == Constants.MEMBER_INTERACTION_CURRENT_STATUS_COMPLETED)
                    oppIds.add(mI.Opportunity__c);
            }
        }
        
        //Check for the size and see if there are opprotunities to update
        if(oppIds.size() > 0) {
            
            //Create a list of Opportunities to be updated
            List<Opportunity> opportunities = new List<Opportunity>();
            
            //Set to hold the used opps
            Set<Id> usedOps = new Set<Id>();
            
            // Fetch count of all the Member Interactions grouped by OppId and Status = Completed
            for(AggregateResult aR : [Select Count(Id) cntELS, Opportunity__c oppId from Call__c where Opportunity__c != null 
                                                                            AND Current_Status__c =: Constants.MEMBER_INTERACTION_CURRENT_STATUS_COMPLETED
                                                                            AND Opportunity__c IN: oppIds Group by Opportunity__c]) {
                                                                                
                //Get the Opportunity Id
                Id oppId = (Id)aR.get('oppId');
                Integer totaolELS = (Integer)aR.get('cntELS');
                
                //Add in opportunity list
                opportunities.add(new Opportunity(Id = oppId, of_ELs_Sent__c = totaolELS));
                usedOps.add(oppId);
            }
            
            //Get the unused ids
            oppIds.removeAll(usedOps);
            
            //loop through the unused opps and set the counter to zero
            for(Id oppId : oppIds) {
                
                //Add in opportunity list
                opportunities.add(new Opportunity(Id = oppId, of_ELs_Sent__c = 0));
            }
            
            //Check if data to update
            if(opportunities.size() > 0) {
                
                //Bypass Triggers
                Util.BypassAllTriggers = true;
                update opportunities;
            }
        }
    }
    
    /**
     *  @description    :   This method is to update the Interaction infomration on Institution Role
     *
     *  @args           :   List of new Calls records, Map of old Calls 
     *
     *  @return         :   void
     *
     **/
    public static void UpdateInteractionInformation(List<Call__c> newCalls, Map<Id, Call__c> mapOldCalls) {
        
        //Create a set to hold teh contact Ids
        Set<Id> contactIds = new Set<Id>();
        
        //Check if Interaction information need to be updated
        //Insert Scenerio
        if(newCalls != null && mapOldCalls == null) {
            
            //Loop through the new Calls
            for(Call__c call : newCalls) {
                
                //Check for the Contact Id
                if(call.Contact__c != null && call.Institution__c != null && call.Call_Date__c != null) {
                    
                    //Add new contact Id
                    contactIds.add(call.Contact__c);
                }
            }
        } else if(newCalls != null && mapOldCalls != null) {
            //Update Scenerio   
            //Loop through the new Calls
            for(Call__c call : newCalls) {
                
                //Check for the Contact Id
                //if Contact__c, Institution__c or CallType changed
                if(call.Contact__c != null && call.Institution__c != null 
                    && (call.Contact__c != mapOldCalls.get(call.Id).Contact__c 
                        || call.Institution__c != mapOldCalls.get(call.Id).Institution__c
                        || call.Call_Date__c != mapOldCalls.get(call.Id).Call_Date__c)
                ) {
                    
                    //Add Old contact Id 
                    if(call.Contact__c != mapOldCalls.get(call.Id).Contact__c && mapOldCalls.get(call.Id).Contact__c != null)
                        contactIds.add(mapOldCalls.get(call.Id).Contact__c);
                    
                    //Add new contact Id
                    contactIds.add(call.Contact__c);
                }
            }
        } else if(newCalls == null && mapOldCalls != null) {
            //Delete Scenerio
            //Loop through the new Calls
            for(Call__c call : mapOldCalls.values()) {
                
                //Check for the Contact Id
                if(call.Contact__c != null && call.Institution__c != null && call.Call_Date__c != null) {
                    
                    //Add new contact Id
                    contactIds.add(call.Contact__c);
                }
            }
        }
        
        //Chekc if Institution Roles need to be updated
        if(contactIds.size() > 0)
             InstitutionRoleTriggerHelper.UpdateInteractionInformationByContactIds(null, contactIds, true);
    }
    
    public static void UpdateInteractionGradeNPD(List<Call__c> newCalls, Map<Id, Call__c> mapOldCalls) {
        
        //List of Calls
        List<Call__c> calls = newCalls != null ? newCalls : mapOldCalls.values();
        
        //Create a set to hold the project Ids
        Map<Id, Project__c> mapProjects = new Map<Id, Project__c>();
        
        //Loop thorugh the record and Populate the Project Set
        for(Call__c call : calls) {
            
            //Check for the project Id and add in map with default null
            if(call.Member__c != null && call.Call_Date__c != null && (!mapProjects.containsKey(call.Member__c)) && (!String.IsBlank(call.Interaction_Grade__c)))
                mapProjects.put(call.Member__c, new Project__c(Id = call.Member__c, Latest_Concept_GPA__c = null));
        }
        
        //Get Latest data and stamp on project
        for(Project__c project : [Select Id, (Select Interaction_Grade__c from Sponsor_Updates__r 
                                                where RecordType.DeveloperName = :Constants.RECORD_TYPE_CALL_DEVELOPER_NAME_NPD 
                                                order by Call_Date__c DESC limit 1)
                                    from Project__c where Id IN: mapProjects.keyset()]) {
    
            //Add record in list to be updated
            if(project.Sponsor_Updates__r != null && project.Sponsor_Updates__r.size() > 0)
                mapProjects.get(project.Id).Latest_Concept_GPA__c = project.Sponsor_Updates__r[0].Interaction_Grade__c;
        }

        //Check if data to update
        if(mapProjects.size() > 0) {

            //ByPass ALL trigger
            Util.BypassAllTriggers = true;
            update mapProjects.values();
        }
    }
    
    /**
     *  @description    :   Method to populate the field "Date Of First EL" on warm lead record with "Completion Date" field value on the Member Interaction object 
     *					    (if more than one Member Interation records, the record with the earliest non-NULL Completion Date), if:-
     							a) Member Interaction should be associated with an Opportunity (Opportunity__c)
							    b) Member Interaction Record type is "Southwind EL Request"
							    c) "Completion Date" field is not NULL
     * 
     *  @args           :   List of new Calls records, Map of old Calls 
     *
     *  @return         :   void
     *
    **/    
    public static void updateDateOfFirstELOnWarmLead(List<Call__c> newCalls, Map<Id, Call__c> mapOldCalls) {
    	                 
    	//Get all record types on case object
        Map<String, Id> caseRecordTypesMap = Util.recordtypemap(Constants.OBJECT_MEMBER_INTERACTION);
        Id rTypes = caseRecordTypesMap.get(Constants.MEMBER_INTERACTION_RT_SOUTHWIND);
        
        //Check for record type	
		if(rTypes != null) {	
         
	    	//Set to hold Member Intraction Ids
	    	Set<Id> setOpportunityIds = new Set<Id>();
	    	
	    	//Loop over new MI Records
	    	for(Call__c mI : newCalls != null ? newCalls : mapOldCalls.values()) {
	    		
	    		//Insert use case
	            if(newCalls != null && mapOldCalls == null && mI.RecordTypeId == rTypes && mI.Opportunity__c != null) 
	                setOpportunityIds.add(mI.Opportunity__c);
	            
	            //Update use case
	            if(newCalls != null && mapOldCalls != null) {
	                  
	                //Checking for the comment body/Is publised field change
	                if(mI.Opportunity__c != mapOldCalls.get(mI.Id).Opportunity__c 
	                	|| mI.Completion_Date__c != mapOldCalls.get(mI.Id).Completion_Date__c
	                    || mI.RecordTypeId != mapOldCalls.get(mI.Id).RecordTypeId 
	           		) {
	           			
	           			//Checking for fields values in the new instances of the MI records
	           			if(mI.Opportunity__c != null)
	           				setOpportunityIds.add(mI.Opportunity__c);	
	           				
	           			//Checking for fields values in the new instances of the MI records	
	           			if(mapOldCalls.containsKey(mI.Id) && mapOldCalls.get(mI.Id) != null
	           				&& mapOldCalls.get(mI.Id).Opportunity__c != null)
	                   		setOpportunityIds.add(mapOldCalls.get(mI.Id).Opportunity__c);  
					} 
	            }
	            
	            //Delete use case
	            if(newCalls == null && mapOldCalls != null && mI.Opportunity__c != null 
	               && mI.RecordTypeId == rTypes && mI.Completion_Date__c != null)  
	                setOpportunityIds.add(mI.Opportunity__c);
    		}
    		
    		//Check for set of OpportunityIds
        	if(setOpportunityIds.size() > 0) {
        		
        		//List to Update Warm Lead Records
		    	Map<Id, Warm_Lead__c> mapWarmLeadsTOBeUpdated = new Map<Id, Warm_Lead__c>();
		        
		        //Fetching parent opportunity records details along with their children warm lead and Member interaction records 
				for(opportunity opp : [SELECT Id , 
								  		(SELECT Id, Completion_Date__c FROM Member_Interactions11__r 
								  			WHERE Completion_Date__c != null 
								  				AND Opportunity__c != null
								  				AND Opportunity__c IN : setOpportunityIds
								  				AND RecordTypeId != null
								  				AND RecordTypeId =: rTypes
								  				ORDER BY Completion_Date__c ASC LIMIT 1),
								  			(SELECT Id, Opportunity__c, Warm_Lead__c FROM Warm_Leads_MtM__r
                                            	WHERE Warm_Lead__c != null 
                                             	AND Opportunity__c != null
                                            	AND Opportunity__c IN : setOpportunityIds)
								  		FROM Opportunity 
								  		WHERE Id IN: setOpportunityIds]) {

					//Checking if warm lead MtMs exists under opportunity record(s)
					if(opp.Warm_Leads_MtM__r != null && opp.Warm_Leads_MtM__r.size() > 0) {
						
						//Checking if "Member Interaction" records exists under "Opportunity" records
						if(opp.Member_Interactions11__r != null && opp.Member_Interactions11__r.size() > 0) {
							
							//Loop through warm lead MtM children records
                            for(Warm_Lead_MtM__c wL : opp.Warm_Leads_MtM__r)
                            	mapWarmLeadsTOBeUpdated.put(wL.Warm_Lead__c, new Warm_Lead__c(Id = wL.Warm_Lead__c, Date_Of_First_EL__c = opp.Member_Interactions11__r[0].Completion_Date__c)); 
						
                        } else {
							
							//Loop through warm lead children records
							for(Warm_Lead_MtM__c wLM : opp.Warm_Leads_MtM__r)
								mapWarmLeadsTOBeUpdated.put(wLM.Warm_Lead__c, new Warm_Lead__c(Id = wLM.Warm_Lead__c, Date_Of_First_EL__c = null)); 
						
						}
					}				 
				}
                
                //Check for update warm lead list size
    			if(mapWarmLeadsTOBeUpdated != null && mapWarmLeadsTOBeUpdated.values().size() > 0) {
    		
		    		//ByPass ALL trigger
		            Util.byPassAlltriggers = true;
		            
		            //update Lead warm records
		            update mapWarmLeadsTOBeUpdated.values();
		            
		            //Enabling trigger back
		            Util.byPassAlltriggers = false;
		    	}
            }
        }
    }
}