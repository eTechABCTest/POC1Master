/**
 * 	Description 	:	Helper class for Trigger Meeting
 * 
 * 	Created By		:	Bhavi Sharma
 * 
 * 	Created Date	:	02/22/2013
 * 
 * 	Revision Logs	:	V1.0 - Created
 * 						V1.1 - Modified - Victor Hanson - 1/26/15 - added method: populateTopParent
 						V1.2 - Modified - Bhavi Sharma - 02/23/15 - added method: manageMeetingFollowers
 						V1.3 - Modified - Bhavi Sharma - 03/03/15 - added method: createDefaultTeamMembers
 						V1.4 - Modified - Bhavi Sharma - 03/04/15 - added method: manageCloneRulesFromParent
 						V1.5 - Modified - Bhavi Sharma - 03/05/15 - added method: deleteRulesForUseForParent
 						
 * 
 **/
public class AdvisoryEventTriggerHelper {
	
	//This flag is to set the Registration creation limit
	public static Integer LIMIT_REGISTRATION_CREATE = 2000;
	
	public final static String USE_PARENT_S_RULES = 'Use parent\'s rules';
	public final static String CLONE_PARENT_S_RULES = 'Clone rules from parent';
	public final static String ESTABLISH_INDEPENDENT_RULES = 'Establish independent rules';
	
	//Map to Hold the appropriate unique rule field for each record type
	public static Map<String, String> mapRuleFieldsWithRecordTypeDeveloperName = new Map<String, String>{
																						'Rules_Programs__c' => 'Program',
																						'Rules_Thresholds__c' => 'Threshold',
																						'Rules_Titles__c' => 'Title'
																						};
	
	//Map to hold the Record Types
	public static Map<Id, RecordType> mapMeetingRecordTypes {
		
		get {
			//Check if it's null, only then query
			if(mapMeetingRecordTypes == null) {
				
				mapMeetingRecordTypes = new Map<Id, RecordType>([Select Id, Name, DeveloperName from RecordType where SObjectType = 'Advisory_Event__c' AND IsActive = true]);
			}
            return mapMeetingRecordTypes;
		}
	}
	
	//This map is to hold the mapping of Source Primary  role to Target Primary role for each record Type
	// Key = Meeting.RecordType.DeveloperName
	//Value = Map
		//Key = Child Team Member Role
		//Value = Parent Team Member Role
	public final static Map<String, Map<String, String>> MAP_RECORD_TYPE_WITH_TARGET_SOURCE_ROLE 
							= new Map<String, Map<String, String>> {
																	'Series' => new Map<String, String> {
																											'Series Planner' => 'Series Planner', 
																											'Series Coordinator' => 'Series Coordinator'
																										},
																	'Event' => new Map<String, String> {
																											'Event Planner' => 'Series Planner', 
																											'Event Coordinator' => 'Series Coordinator', 
																											'On Site Planner' => 'Series Planner'
																										},
																	'Session' => new Map<String, String> {
																											'Event Planner' => 'Event Planner', 
																											'Event Coordinator' => 'Event Coordinator', 
																											'On Site Planner' => 'Event Planner'
																										}
																};

    /**
     * @description	: 	Populates the masterAPIName field of a record looks up to a parent of the same record type.  
     * 					(ie: institution top parent Id could be populated using this method)
     * 
     * @params		: 	trigger.new, trigger.oldMap, object name, parent field name, master field name
     * 
     * @return		: 	void
     **/
    public static voId populateTopParent(list<SObject> newListSObj, map<Id, SObject> oldMapSObj, string objectAPIName, string parentAPIName, string masterAPIName) {
		
        list<SObject> sObjList = newListSObj;
        if (trigger.isDelete) sObjList = oldMapSObj.values();
        
        // Identify all the parents of the affected records
        Set<Id> objParents = new Set<Id>();
        if (newListSObj != null) {
            for(SObject obj : newListSObj)
                objParents.add((string)obj.get(parentAPIName));
        }
        
        // If we're inserting or updating, set the Master
        if(Trigger.isBefore && (Trigger.isInsert || Trigger.IsUpdate))
        {
			
            // Get the details of the parents, including their Master SObjs
            string parentQry = 'SELECT ' + masterAPIName + ', ' + parentAPIName.replace('__c', '__r') + '.' + masterAPIName + ' FROM ' + objectAPIName + ' WHERE Id IN :objParents';
            Map<Id, SObject> parentSObjs = new Map<Id, SObject>(database.query(parentQry));
            
            // Cycle through all the changed SObjs
            for(SObject SObj : newListSObj)
            {
                // If inserting and there's no parent, or 
                // updating and there's no change to the parent, 
                // do nothing
                if((Trigger.IsInsert && SObj.get(parentAPIName) == null) ||
                   (Trigger.IsUpdate && SObj.get(parentAPIName) == oldMapSObj.get(SObj.Id).get(parentAPIName)))
                {                
                    
                    //
                    // The following all assume a change to the parent
                    //
                    
                    // If the current Parent has been emptied, it has no master
                } else if(SObj.get(parentAPIName) == null)
                {
                    SObj.put(masterAPIName, null);
                    
                    // if the matching parent record has no parent, the current record uses
                    // the matching parent as its master
                } else if(parentSObjs.get((string)SObj.get(parentAPIName)).get(masterAPIName) == null)
                {
                    
                    SObj.put(masterAPIName, SObj.get(parentAPIName));
                    
                    // Otherwise, the current record uses the master of its parent as its master
                } else
                {
                   // string s = string.valueOf();
                    SObj.put(masterAPIName, parentSObjs.get((string)SObj.get(parentAPIName)).get(masterAPIName));                
                }
            }
            // If we're deleting or updating, set the children's master
        } else if(Trigger.isAfter && (Trigger.IsUpdate || Trigger.IsDelete))
        {
            Map<Id, Id> changedParents = new Map<Id, Id>();
            if(Trigger.IsDelete)
            {
                // Since we've deleted a SObj, let's Identify the deleted parent and
                // simply let the isUpdate trigger handle the re-parenting of the children
                for(SObject SObj : oldMapSObj.values())
                    changedParents.put(SObj.Id, null);
            } else
            {
                // If the Master has changed, let's capture the SObjs whose children need to be reset
                for(SObject SObj : newListSObj) {
                    if(SObj.get(masterAPIName) != oldMapSObj.get(SObj.Id).get(masterAPIName))
                        changedParents.put(SObj.Id, (string)SObj.get(masterAPIName));
                }
            }
            
            // If we've Identified any changed parents, let's update the appropriate children
            if(changedParents.size() > 0)
            {
				
                // Find all the related children
                set<Id> parentIdSet = changedParents.keySet();
                string childQry = 'SELECT ' + masterAPIName + ', ' + parentAPIName + ' FROM ' + objectAPIName + ' WHERE ' + parentAPIName + ' IN :parentIdSet';
                List<SObject> reParenting = new List<SObject>(database.query(childQry));
                
                if(reParenting.size() > 0)
                {
                    // Reset the childrens' Master to be the master of their parents
                    for(SObject SObj : reParenting)
                        SObj.put(masterAPIName, changedParents.get((string)SObj.get(parentAPIName)));
                    
                    update reParenting;
                }
            }
        }
    }
    
    /**
     * 	@description	:	This method is to manage the entity subscription for users
     							1. Calls the Chatter AddFollower method in the ChatterHelper class to add the record?s Manager to the feed.  
     							2. If there is a previous value for the Manager, calls the removeFollower method to remove the previous user.
     * 
     * 	@args			:	List of new and old meeting records
     * 
     * 	@return			:	void
     * 
     **/
    public static void manageMeetingFollowers(List<Advisory_Event__c> newMeetings, Map<Id, Advisory_Event__c> mapOldMeetings) {
    	
    	//Create a set to hold the follower users and following records
    	Set<String> setUsersWithRecordIdsToFollow = new Set<String>();
    	
    	//Create a set to hold the users to remove and records
    	Set<String> setUsersWithRecordIdsToUnFollow = new Set<String>();
    	
    	//Loop through the meeting records and populate set
    	for(Advisory_Event__c meeting : newMeetings) {
    		
    		//Insert Case
    		if(meeting.Manager__c != null && meeting.Is_Closed__c != true && mapOldMeetings == null) {
    			
    			//Add in list to create the Subscription record
    			setUsersWithRecordIdsToFollow.add(meeting.Manager__c + '-' + meeting.Id);
    		} else if(mapOldMeetings != null 
    			&& (meeting.Manager__c != mapOldMeetings.get(meeting.Id).Manager__c
    				|| meeting.Is_Closed__c != mapOldMeetings.get(meeting.Id).Is_Closed__c)) {
    			
    			//Update Case
				if(meeting.Manager__c != null
					&& ((meeting.Manager__c != mapOldMeetings.get(meeting.Id).Manager__c
						&& meeting.Is_Closed__c != true)
						|| 
						(meeting.Is_Closed__c != mapOldMeetings.get(meeting.Id).Is_Closed__c
						&& mapOldMeetings.get(meeting.Id).Is_Closed__c == true))) {
					
					//Add in list to create the Subscription record
    				setUsersWithRecordIdsToFollow.add(meeting.Manager__c + '-' + meeting.Id);
				}
				
				//Remove from Closed Meetings
				if(meeting.Manager__c != null
					&& meeting.Is_Closed__c != mapOldMeetings.get(meeting.Id).Is_Closed__c
					&& meeting.Is_Closed__c == true) {
					
					//Add in list to create the Subscription record
    				setUsersWithRecordIdsToUnFollow.add(mapOldMeetings.get(meeting.Id).Manager__c + '-' + meeting.Id);
				} 
				
				//Removed Old one
				if(mapOldMeetings.get(meeting.Id).Manager__c != null
					&& meeting.Manager__c != mapOldMeetings.get(meeting.Id).Manager__c) {
					
					//Add in list to remove the Subscription record
    				setUsersWithRecordIdsToUnFollow.add(mapOldMeetings.get(meeting.Id).Manager__c + '-' + meeting.Id);
				}
			}
    	}
    	
    	//Call helper class method to delete the Subscrition records
    	ChatterHelper.RemoveFollower(setUsersWithRecordIdsToUnFollow);
    	
    	//Call helper class method to create the Subscrition records
    	ChatterHelper.AddFollower(setUsersWithRecordIdsToFollow);
    }
    
    /**
     * 	@description	:	This method is to create the Team Member records on Event records when they are created.
     							When a new ABC Event is created, create default Team Member records, 
     							where some values will default based on the presence of correspondents on the ABC Event?s parent. 
     							If no parent is defined, or the parent does not have a Team Member with the indicated role, 
     							then a Team Member record is still created, but will not yet have a person defined.
     							Check the variable : MAP_RECORD_TYPE_WITH_SOURCE_TARGET_ROLE
     * 
     * 	@args			:	List of Meetings
     * 
     * 	@return			:	void
     * 
     **/
    public static void createDefaultTeamMembers(List<Advisory_Event__c> meetings) {
    	
    	//Create a set of Parent Meetings
    	Set<Id> parentMeetingsIds = new Set<Id>();
    	
    	//loop through the meetings and find the Parent Event
    	for(Advisory_Event__c meeting : meetings) {
    		
    		//Check for the Null
    		if(meeting.Parent_Event__c != null)
    			parentMeetingsIds.add(meeting.Parent_Event__c);
		}
		
		//Map to hold the parent meetings and related Team Members
		Map<Id, Map<String, Id>> mapParentWithTeamMemberRole = new Map<Id, Map<String, Id>>();
		
		//Check parentMeetingsIds size, query data
		if(parentMeetingsIds.size() > 0) {
			
			//Query Team Member Roles
			for(Team_Member__c teamMember : [Select Id, Advisory_Event__c, Primary_Role__c, Team_Member__c from Team_Member__c where Advisory_Event__c != null AND Advisory_Event__c IN: parentMeetingsIds AND Primary_Role__c != null]) {
				
				//Add data in Map
				if(!mapParentWithTeamMemberRole.containsKey(teamMember.Advisory_Event__c))
					mapParentWithTeamMemberRole.put(teamMember.Advisory_Event__c, new Map<String, Id>{});
				
				//Map roles with contact
				Map<String, Id> mapRole = mapParentWithTeamMemberRole.get(teamMember.Advisory_Event__c);
				mapRole.put(teamMember.Primary_Role__c, teamMember.Team_Member__c);
				
				//put this map back in original map
				mapParentWithTeamMemberRole.put(teamMember.Advisory_Event__c, mapRole);
			}
		}
		
		//List of teamMembers to be inserted
		List<Team_Member__c> teamMembers = new List<Team_Member__c>();
		
		//Now Loop through the new Meetings again, and create the defaults team member based on the record type
		//loop through the meetings and find the Parent Event
    	for(Advisory_Event__c meeting : meetings) {
    		
    		//Check for the record type first, and create the only appropriate team members
    		if(meeting.RecordTypeId != null
    			&& MAP_RECORD_TYPE_WITH_TARGET_SOURCE_ROLE.containsKey(mapMeetingRecordTypes.get(meeting.RecordTypeId).DeveloperName)) {
    			
    			//Get the mapping from map
    			Map<String, String> mapTargetSourceRoleMapping = MAP_RECORD_TYPE_WITH_TARGET_SOURCE_ROLE.get(mapMeetingRecordTypes.get(meeting.RecordTypeId).DeveloperName);
    			System.debug('mapTargetSourceRoleMapping:::::1'+ mapTargetSourceRoleMapping);
    			
    			//Check Parent Id, if not exists, then create the default Team Member for all Target Roles
	    		if(meeting.Parent_Event__c == null
	    			|| !mapParentWithTeamMemberRole.containsKey(meeting.Parent_Event__c)
	    			|| mapParentWithTeamMemberRole.get(meeting.Parent_Event__c).size() == 0) {
	    			
	    			System.debug('mapTargetSourceRoleMapping:::::3'+ mapTargetSourceRoleMapping);
    				
    				//Create the default Team member records
    				for(String targetRole : mapTargetSourceRoleMapping.keySet()) {
    					System.debug('mapTargetSourceRoleMapping:::::2'+ mapTargetSourceRoleMapping);
    					
    					//Create a new Team Member record
    					teamMembers.add(new Team_Member__c(Advisory_Event__c = meeting.Id, Primary_Role__c = targetRole, Team_Member__c = null));
    				}
    			} else if(mapParentWithTeamMemberRole.containsKey(meeting.Parent_Event__c)
    				&& mapParentWithTeamMemberRole.get(meeting.Parent_Event__c).size() > 0) {
    				
    				//Exsiting Roles and Contacts
    				Map<String, Id> mapExistingRoleWithTeamMember = mapParentWithTeamMemberRole.get(meeting.Parent_Event__c);
    				
    				//Loop through the map and check if there is any existing team Member
    				//If yes, then add the same
    				//Else create a default team member record
    				//Create the default Team member records
    				for(String targetRole : mapTargetSourceRoleMapping.keySet()) {
    					
    					//Source role
    					String sourceRole = mapTargetSourceRoleMapping.get(targetRole);
    					
    					//Check if role already exsits on parent, the use the same contact, else create default
    					if(mapExistingRoleWithTeamMember.containsKey(sourceRole)) {
    						
    						//Create a new Team Member record and with existing Contact
    						teamMembers.add(new Team_Member__c(Advisory_Event__c = meeting.Id, Primary_Role__c = targetRole, Team_Member__c = mapExistingRoleWithTeamMember.get(sourceRole)));
    					} else {
    						
    						//Create a new Team Member record and with existing Contact
    						teamMembers.add(new Team_Member__c(Advisory_Event__c = meeting.Id, Primary_Role__c = targetRole, Team_Member__c = null));
    					}
    				}	
    			}
    		}
    	}
    	
    	//Check for the size and insert the results
    	if(teamMembers.size() > 0)
    		insert teamMembers;
    }
    
    /**
     *	@description	:	This method is to clone the Rules from Parent. 
     						Rules for the current ABC Event are managed according to the selection of any of the �Rules � � picklist fields.
								If set to �Clone rules from Parent�:
									o   Clone the parent�s rules for that rule type
									o   Set the value of the picklist to �Establish independent rules�
     *
     *	@args			:	List of new meeting records, Old meeting records map
     *
     *	@return			:	void
     *
     **/
	public static void manageCloneRulesFromParent(List<Advisory_Event__c> newMeetings, Map<Id, Advisory_Event__c> mapOldMeetings) {
		
		//Create a set of Parent Events with Id, and rules type they have
		Map<Id, Set<String>> mapParentMeetingsWithType = new Map<Id, Set<String>>();
		
		//This set is to hold the record types developer names which need to be queried from parent
		Set<String> setRecordTypesDeveloperName = new Set<String>();
		
		//Create a list of Meeting records to update with value "Estabalished"
		List<Advisory_Event__c> establishedMeetings = new List<Advisory_Event__c>();
		
		//Loop through the records
		for(Advisory_Event__c meeting : newMeetings) {
			
			//Check for the meeting record's Parent and Value for the rule field
			if((meeting.Rules_Programs__c == CLONE_PARENT_S_RULES
					|| meeting.Rules_Thresholds__c == CLONE_PARENT_S_RULES
					|| meeting.Rules_Titles__c == CLONE_PARENT_S_RULES)
				&& (mapOldMeetings == null 
					|| mapOldMeetings.get(meeting.Id).Rules_Programs__c != meeting.Rules_Programs__c
					|| mapOldMeetings.get(meeting.Id).Rules_Thresholds__c != meeting.Rules_Thresholds__c
					|| mapOldMeetings.get(meeting.Id).Rules_Titles__c != meeting.Rules_Titles__c)
			) {
				
				//Set Value to established rule
				Advisory_Event__c establishedMeeting = new Advisory_Event__c(Id = meeting.Id);
				
				//Check if mapParentMeetingsWithType has an instance
				if(meeting.Parent_Event__c != null && !mapParentMeetingsWithType.containsKey(meeting.Parent_Event__c))
					mapParentMeetingsWithType.put(meeting.Parent_Event__c, new Set<String>{});
				
				//Loop through the Rules field and check if any of the value was change
				for(String fieldName : mapRuleFieldsWithRecordTypeDeveloperName.keyset()) {
					
					//Chekc for old and new
					if(meeting.get(fieldName) != null 
						&& String.valueOf(meeting.get(fieldName)) == CLONE_PARENT_S_RULES
						&& (mapOldMeetings == null 
							|| mapOldMeetings.get(meeting.Id).get(fieldName) == null 
							|| String.valueOf(meeting.get(fieldName)) != String.valueOf(mapOldMeetings.get(meeting.Id).get(fieldName)))
					) {
						
						//Set Established
						establishedMeeting.put(fieldName, ESTABLISH_INDEPENDENT_RULES);
						
						//Add Record Type Name in Map
						if(meeting.Parent_Event__c != null)
							mapParentMeetingsWithType.get(meeting.Parent_Event__c).add(mapRuleFieldsWithRecordTypeDeveloperName.get(fieldName));
					}
					
					//Add in global record type set
					if(meeting.Parent_Event__c != null)
						setRecordTypesDeveloperName.addAll(mapParentMeetingsWithType.get(meeting.Parent_Event__c));
				}
				
				//Add in list to be updated
				establishedMeetings.add(establishedMeeting);
			}
		}
		
		//Query data from Parent Event
		if(mapParentMeetingsWithType.size() >= 0) {
			
			//Set a map to hold the Parent Meeting Id, with it's Rule Record Type and Rules
			Map<Id, Map<String, List<Rule__c>>> mapParentMeetingRuleswitRecordType = new Map<Id, Map<String, List<Rule__c>>>(); 
			Set<Id> parentMeetingsIdsSet = mapParentMeetingsWithType.keySet();
				
			//Prepare the query to fetch the rule data
			String SOQLQuery = 'Select Id ';
	                
	        //fetch fields from fieldset to support the dynamic behaviour
	        for(Schema.FieldSetMember f : SObjectType.Rule__c.FieldSets.RuleCloningList.getFields())
	            SOQLQuery += ', ' + f.getFieldPath();
	        SOQLQuery += ' FROM Rule__c where Advisory_Event__c IN: parentMeetingsIdsSet AND RecordType.DeveloperName IN: setRecordTypesDeveloperName';
	        
	        System.debug('SOQLQuery query is:::::'+ SOQLQuery);
	        
	        //Query Parent Rules
			for(Rule__c rule : (List<Rule__c>)database.query(SOQLQuery)) {
				
				//Add in map
				if(!mapParentMeetingRuleswitRecordType.containsKey(rule.Advisory_Event__c))
	                mapParentMeetingRuleswitRecordType.put(rule.Advisory_Event__c, new Map<String, List<Rule__c>>{});
					
				//Check if record type is already in map
				Map<String, List<Rule__c>> mapRecordTypeWithRules = mapParentMeetingRuleswitRecordType.get(rule.Advisory_Event__c);
				String ruleRecordTypeDeveloperName = RuleTriggerHelper.mapRuleRecordTypes.get(rule.RecordTypeId).DeveloperName;
				if(!mapRecordTypeWithRules.containsKey(ruleRecordTypeDeveloperName))
					mapRecordTypeWithRules.put(ruleRecordTypeDeveloperName, new List<Rule__c>{});
				
				//Add rule and put it back in map
				mapRecordTypeWithRules.get(ruleRecordTypeDeveloperName).add(rule);
				mapParentMeetingRuleswitRecordType.put(rule.Advisory_Event__c, mapRecordTypeWithRules);
			}
			
			//Now Loop through the new records again and create the lost of rules to be cloned
			List<Rule__c> completeCloneRulesList = new List<Rule__c>();
			
			//Iterate list
			//Loop through the records
			for(Advisory_Event__c meeting : newMeetings) {
				
				//Check for the meeting record's Parent and Value for the rule field
				if(meeting.Parent_Event__c != null
					&& (meeting.Rules_Programs__c == CLONE_PARENT_S_RULES
						|| meeting.Rules_Thresholds__c == CLONE_PARENT_S_RULES
						|| meeting.Rules_Titles__c == CLONE_PARENT_S_RULES)
					&& (mapOldMeetings == null 
						|| mapOldMeetings.get(meeting.Id).Rules_Programs__c != meeting.Rules_Programs__c
						|| mapOldMeetings.get(meeting.Id).Rules_Thresholds__c != meeting.Rules_Thresholds__c
						|| mapOldMeetings.get(meeting.Id).Rules_Titles__c != meeting.Rules_Titles__c)
				) {
					
					//Loop through the Rules field and check if any of the value was change
					for(String fieldName : mapRuleFieldsWithRecordTypeDeveloperName.keyset()) {
						
						//Get the Existing Parent Rules related to this record
						Map<String, List<Rule__c>> mapRTypesWithRules = mapParentMeetingRuleswitRecordType.get(meeting.Parent_Event__c);
						
						//Check for old and new
						if(meeting.get(fieldName) != null 
							&& String.valueOf(meeting.get(fieldName)) == CLONE_PARENT_S_RULES
							&& (mapOldMeetings == null 
								|| mapOldMeetings.get(meeting.Id).get(fieldName) == null 
								|| String.valueOf(meeting.get(fieldName)) != String.valueOf(mapOldMeetings.get(meeting.Id).get(fieldName)))
						) {
							
							//Get the related record type developer name
							String recordTypeDeveloperName = mapRuleFieldsWithRecordTypeDeveloperName.get(fieldName);
	                        
							//Check if this field need to be processed
							if(mapRTypesWithRules == null || !mapRTypesWithRules.containsKey(recordTypeDeveloperName))
								continue;
							
							//Related
							List<Rule__c> relatedRules = mapRTypesWithRules.get(recordTypeDeveloperName);
							
							//Clone this records and Update the ABC Event Id
							List<Rule__c> clonedRelatedRules = relatedRules.deepClone(false);
							
							for(Rule__c rule : clonedRelatedRules) {
								
								//Copy Event Id
								rule.Advisory_Event__c = meeting.Id;	
							}
							
							//Add in main list
							completeCloneRulesList.addAll(clonedRelatedRules);
						}
					}
				}
			}
			
			//Insert rules
			if(completeCloneRulesList.size() > 0)
				insert completeCloneRulesList;
		}
				
		//Update meetings
		if(establishedMeetings.size() > 0)
			update establishedMeetings;
	}
	
	/**
	 * 	@description	:	deleteRulesForUseForParent
	 * 						  	If set to �Use parent�s rules�:
									o   Do not allow any insertion of rules for that rule type
									o   #2) Delete any existing rules for that type from the current ABC Event.
	 * 
	 * 	@args			:	List of rules being updated
	 * 
	 * 	@return			:	void
	 * 
	 **/
	public static void deleteRulesForUseForParent(List<Advisory_Event__c> newMeetings, Map<Id, Advisory_Event__c> mapOldMeetings) {
		
		//Create a set of Parent Events with Id, and rules type they have
		Map<Id, Set<String>> mapMeetingsWithType = new Map<Id, Set<String>>();
		Map<Id, Set<String>> mapParentMeetingsWithType = new Map<Id, Set<String>>();
		Map<Id, Set<Id>> mapParentWithNewMeetings = new Map<Id, Set<Id>>();
		
		//Create a list of Advisory Events to be updated with the Primary Program field
		Map<Id, Advisory_Event__c> mapMeetings = new Map<Id, Advisory_Event__c>();
		
		//This set is to hold the record types developer names which need to be queried from parent
		Set<String> setRecordTypesDeveloperName = new Set<String>();
		
		//Loop through the meetings and check if New value is Use Parent's rule
		//Loop through the records
		for(Advisory_Event__c meeting : newMeetings) {
			
			//Check for the meeting record's Parent and Value for the rule field
			if((meeting.Rules_Programs__c == USE_PARENT_S_RULES
					|| meeting.Rules_Thresholds__c == USE_PARENT_S_RULES
					|| meeting.Rules_Titles__c == USE_PARENT_S_RULES)
				&& (mapOldMeetings == null 
					|| mapOldMeetings.get(meeting.Id).Rules_Programs__c != meeting.Rules_Programs__c
					|| mapOldMeetings.get(meeting.Id).Rules_Thresholds__c != meeting.Rules_Thresholds__c
					|| mapOldMeetings.get(meeting.Id).Rules_Titles__c != meeting.Rules_Titles__c)
			) {
				
				//Check if mapMeetingsWithType has an instance
				if(!mapMeetingsWithType.containsKey(meeting.Id))
					mapMeetingsWithType.put(meeting.Id, new Set<String>{});
				if(!mapParentMeetingsWithType.containsKey(meeting.Parent_Event__c))
					mapParentMeetingsWithType.put(meeting.Parent_Event__c, new Set<String>{});
				if(!mapParentWithNewMeetings.containsKey(meeting.Parent_Event__c))
					mapParentWithNewMeetings.put(meeting.Parent_Event__c, new Set<Id>{});
				
				//Loop through the Rules field and check if any of the value was change
				for(String fieldName : mapRuleFieldsWithRecordTypeDeveloperName.keyset()) {
					
					//Chekc for old and new
					if(meeting.get(fieldName) != null 
						&& String.valueOf(meeting.get(fieldName)) == USE_PARENT_S_RULES
						&& (mapOldMeetings == null 
							|| mapOldMeetings.get(meeting.Id).get(fieldName) == null 
							|| String.valueOf(meeting.get(fieldName)) != String.valueOf(mapOldMeetings.get(meeting.Id).get(fieldName)))
					) {
						
						//Add Record Type Name in Map
						mapMeetingsWithType.get(meeting.Id).add(mapRuleFieldsWithRecordTypeDeveloperName.get(fieldName));
						mapParentMeetingsWithType.get(meeting.Parent_Event__c).add(mapRuleFieldsWithRecordTypeDeveloperName.get(fieldName));
						mapParentWithNewMeetings.get(meeting.Parent_Event__c).add(meeting.Id);
					}
					
					//Add in global record type set
					setRecordTypesDeveloperName.addAll(mapMeetingsWithType.get(meeting.Id));
				}
			}	
		}
		
		//Query data from Parent Event
		if(mapMeetingsWithType.size() == 0)
			return;
			
		//Set a map to hold the Parent Meeting Id, with it's Rule Record Type and Rules
		Map<Id, Map<String, List<Rule__c>>> mapParentMeetingRuleswitRecordType = new Map<Id, Map<String, List<Rule__c>>>(); 
		Set<Id> parentMeetingsIdsSet = mapMeetingsWithType.keySet();
		
		//List to hold the rules to be deleted
		List<Rule__c> rulesToDelete = new List<Rule__c>();
		List<Event_Rule__c> eRulesToDelete = new List<Event_Rule__c>();
		List<Event_Rule__c> eRulesToCreate = new List<Event_Rule__c>();
			
		//Query Parent Rules
		for(Rule__c rule : [Select Id, Advisory_Event__c, RecordType.DeveloperName FROM Rule__c where Advisory_Event__c IN: parentMeetingsIdsSet AND RecordType.DeveloperName IN: setRecordTypesDeveloperName]) {
			
			//Check and add in list to be deleted
			if(mapMeetingsWithType.containsKey(rule.Advisory_Event__c) && mapMeetingsWithType.get(rule.Advisory_Event__c).contains(rule.RecordType.DeveloperName))
                rulesToDelete.add(rule);
		}
		
		//Query Parent Rules
		for(Event_Rule__c eRule : [Select Id, Advisory_Event__c, Rule__r.RecordType.DeveloperName FROM Event_Rule__c where Advisory_Event__c IN: parentMeetingsIdsSet AND Rule__r.RecordType.DeveloperName IN: setRecordTypesDeveloperName]) {
			
			//Check and add in list to be deleted
			if(mapMeetingsWithType.containsKey(eRule.Advisory_Event__c) && mapMeetingsWithType.get(eRule.Advisory_Event__c).contains(eRule.Rule__r.RecordType.DeveloperName))
                eRulesToDelete.add(eRule);
		}
		
		//Query Parent Rules
		System.debug('mapParentMeetingsWithType:::::'+ mapParentMeetingsWithType + '-----' + setRecordTypesDeveloperName);
		for(Event_Rule__c rule : [Select Id, Advisory_Event__c, Advisory_Event__r.Primary_Program__c, Rule__c, Rule__r.RecordType.DeveloperName FROM Event_Rule__c where Advisory_Event__c IN: mapParentMeetingsWithType.keySet() AND Rule__r.RecordType.DeveloperName IN: setRecordTypesDeveloperName]) {
			System.debug('rule:::::'+ rule.Advisory_Event__r.Primary_Program__c);
			//Check and add in list to be deleted
			if(mapParentMeetingsWithType.containsKey(rule.Advisory_Event__c) && mapParentMeetingsWithType.get(rule.Advisory_Event__c).contains(rule.Rule__r.RecordType.DeveloperName)) {
                for(Id meetingId : mapParentWithNewMeetings.get(rule.Advisory_Event__c)) {
            		
            		//Add in list
            		eRulesToCreate.add(new Event_Rule__c(Advisory_Event__c = meetingId, Rule__c = rule.Rule__c));
            		System.debug('Record Type:::::'+ rule.Rule__r.RecordType.DeveloperName);
            		if(rule.Rule__r.RecordType.DeveloperName == 'Program' && !mapMeetings.containsKey(rule.Advisory_Event__c))
            			mapMeetings.put(rule.Advisory_Event__c, new Advisory_Event__c(Id = meetingId, Primary_Program__c = rule.Advisory_Event__r.Primary_Program__c)); 	
                }
            }
		}
		System.debug('mapMeetings::::: '+ mapMeetings);
		//Check for the size and delete the list
		if(rulesToDelete.size() > 0)
			delete rulesToDelete;
		if(eRulesToDelete.size() > 0)
			delete eRulesToDelete;
		if(eRulesToCreate.size() > 0)
			insert eRulesToCreate;
		if(mapMeetings.size() > 0)
			update mapMeetings.values();
	}
	
	/**
	 * 	@description	:	deleteRulesForUseForParent
	 * 						  	If set to ESTABLISH_INDEPENDENT_RULES
									o   #1) Delete any existing rules for that type from the current ABC Event.
	 * 
	 * 	@args			:	List of rules being updated
	 * 
	 * 	@return			:	void
	 * 
	 **/
	public static void deleteRulesForEstablishedIndependentRule(List<Advisory_Event__c> newMeetings, Map<Id, Advisory_Event__c> mapOldMeetings) {
		
		//Create a set of Parent Events with Id, and rules type they have
		Map<Id, Set<String>> mapMeetingsWithType = new Map<Id, Set<String>>();
		
		//This set is to hold the record types developer names which need to be queried from parent
		Set<String> setRecordTypesDeveloperName = new Set<String>();
		
		//Loop through the meetings and check if New value is Use Parent's rule
		//Loop through the records
		for(Advisory_Event__c meeting : newMeetings) {
			
			//Check for the meeting record's Parent and Value for the rule field
			if((meeting.Rules_Programs__c == ESTABLISH_INDEPENDENT_RULES && mapOldMeetings.get(meeting.Id).Rules_Programs__c == USE_PARENT_S_RULES)
				|| (meeting.Rules_Thresholds__c == ESTABLISH_INDEPENDENT_RULES && mapOldMeetings.get(meeting.Id).Rules_Thresholds__c == USE_PARENT_S_RULES)
				|| (meeting.Rules_Titles__c == ESTABLISH_INDEPENDENT_RULES && mapOldMeetings.get(meeting.Id).Rules_Titles__c == USE_PARENT_S_RULES)
			) {
				
				//Check if mapMeetingsWithType has an instance
				if(!mapMeetingsWithType.containsKey(meeting.Id))
					mapMeetingsWithType.put(meeting.Id, new Set<String>{});
				
				//Loop through the Rules field and check if any of the value was change
				for(String fieldName : mapRuleFieldsWithRecordTypeDeveloperName.keyset()) {
					
					//Chekc for old and new
					if(meeting.get(fieldName) != null 
						&& String.valueOf(meeting.get(fieldName)) == ESTABLISH_INDEPENDENT_RULES
						&& mapOldMeetings.get(meeting.Id).get(fieldName) != null 
						&& String.valueOf(mapOldMeetings.get(meeting.Id).get(fieldName)) == USE_PARENT_S_RULES
					) {
						
						//Add Record Type Name in Map
						mapMeetingsWithType.get(meeting.Id).add(mapRuleFieldsWithRecordTypeDeveloperName.get(fieldName));
					}
					
					//Add in global record type set
					setRecordTypesDeveloperName.addAll(mapMeetingsWithType.get(meeting.Id));
				}
			}	
		}
		
		//Query data from Parent Event
		if(mapMeetingsWithType.size() == 0)
			return;
			
		//List to hold the rules to be deleted
		List<Event_Rule__c> eRulesToDelete = new List<Event_Rule__c>();
			
		//Query Parent Rules
		for(Event_Rule__c eRule : [Select Id, Advisory_Event__c, Rule__r.RecordType.DeveloperName FROM Event_Rule__c where Advisory_Event__c IN: mapMeetingsWithType.keySet() AND Rule__r.RecordType.DeveloperName IN: setRecordTypesDeveloperName]) {
			
			//Check and add in list to be deleted
			if(mapMeetingsWithType.containsKey(eRule.Advisory_Event__c) && mapMeetingsWithType.get(eRule.Advisory_Event__c).contains(eRule.Rule__r.RecordType.DeveloperName))
                eRulesToDelete.add(eRule);
		}
		
		//Check for the size and delete the list
		if(eRulesToDelete.size() > 0)
			delete eRulesToDelete;
	}
}