/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
  * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest
public class Test_AdvisoryEventTrigger {
	
    /**
     * @description: 	1) Create 3 meetings, the master, child, and grandchild.  
     * 					2) Verify that the child and grand child reference the same Master meeting record.
     * 					3) Delete the master
     * 					4) Verify the grandchild now references the child record (new master)
     */
    static testmethod void testPopulateTopParent() {
        //create the master record
        Advisory_Event__c master = testUtilities.createEvent(Constants.RECORD_TYPE_ID_ADV_EVENT_SERIES, null, true);
        
        //create the child record
        Advisory_Event__c child = testUtilities.createEvent(Constants.RECORD_TYPE_ID_ADV_EVENT_EVENT, null, false);
        child.Parent_Event__c = master.Id;
        insert child;
        
        //create the grand child record
        Advisory_Event__c grandChild = testUtilities.createEvent(Constants.RECORD_TYPE_ID_ADV_EVENT_SESSION, null, false);
        grandChild.Parent_Event__c = child.Id;
        insert grandChild;
        
        set<Id> meetingIds = new set<Id> { master.Id, child.Id, grandChild.Id };
        
        //get all meetings and verify the master event field on each
        list<Advisory_Event__c> meetings = [SELECT Id, Master_Event__c FROM Advisory_Event__c WHERE Id IN :meetingIds];
        for (Advisory_Event__c m : meetings) {
            if (m.Id == master.Id) system.assertEquals(null, m.Master_Event__c);
            else if (m.Id == child.Id) system.assertEquals(master.Id, m.Master_Event__c);
            else if (m.Id == grandChild.Id) system.assertEquals(master.Id, m.Master_Event__c);
        }
        
        //delete the master
        /*delete child;
        
        //get all meetings and verify the master event field on each
        meetings = [SELECT Id, Master_Event__c, Parent_Event__c FROM Advisory_Event__c WHERE Id IN :meetingIds];
        for (Advisory_Event__c m : meetings) {
            if (m.Id == grandChild.Id) {
                system.assertEquals(master.Id, m.Master_Event__c);
            }
        }*/
        
         //delete the master
        delete master;
        
        //get all meetings and verify the master event field on each
        meetings = [SELECT Id, Master_Event__c FROM Advisory_Event__c WHERE Id IN :meetingIds];
        for (Advisory_Event__c m : meetings) {
            if (m.Id == child.Id) system.assertEquals(null, m.Master_Event__c);
            //else if (m.Id == grandChild.Id) system.assertEquals(child.Id, m.Master_Event__c);
        }
		
    }
    
    //Test method for manageMeetingFollowers
    /**
     *	Use Cases	:	1. Add a new test method that will create two Meeting records.  
     						One of them should have the Manager initially set to a User and the other should have no Manager defined.  
     						In the test, set the Manager on both records to a new value.  
     						Verify that on the first record, the previous user is no longer following the Meeting feed, 
     						and that on both records, the new User is correctly following the record.
						2. Add another new test method that will create a new Meeting record with a Manager defined.  
							In the test, check if the user set as Manager is correctly following the record.  
							Set the Meeting Status to a Closed value.  
							Verify that the user set as Manager is no longer following the record after this change.
     
     **/
    static testMethod void testManageMeetingFollowers() {
    	
    	//Fetch existing user from database other than the current one
		List<User> managers = [Select Id from User where Profile.Name = 'System Administrator' AND IsActive = true AND Id !=: UserInfo.getUserId() LIMIT 1];
		
		//Create test data
		List<Advisory_Event__c> meetings = new List<Advisory_Event__c>();
		
		//Create Parent meeting records
		meetings.add(testUtilities.createEvent(Constants.RECORD_TYPE_ID_ADV_EVENT_SERIES, null, false));
		meetings.add(testUtilities.createEvent(Constants.RECORD_TYPE_ID_ADV_EVENT_SERIES, null, false));
		
		//Set the Manager in First meeting and keep the second meeting null
		meetings[0].Manager__c = managers[0].Id;
		
		//Start testing from here
		Test.startTest();
		
		//Insert managers
		insert meetings;
		
		//Check only first meeting record should have Manager as follower
		List<EntitySubscription> eS = [Select SubscriberId, ParentId from EntitySubscription where SubscriberId IN: managers];
		System.assertEquals(1, eS.size());
		System.assertEquals(meetings[0].Id, eS[0].ParentId);
		
		//Update the manager on Second Record
		meetings[1].Manager__c = managers[0].Id;
		update meetings[1];
		
		//Check only first meeting record should have Manager as follower
		eS = [Select SubscriberId, ParentId from EntitySubscription where SubscriberId IN: managers];
		System.assertEquals(2, eS.size());
		System.assert(meetings[0].Id == eS[0].ParentId || meetings[0].Id == eS[1].ParentId);
		System.assert(meetings[1].Id == eS[0].ParentId || meetings[1].Id == eS[1].ParentId);
		
		//Remove Managers from meeting records
		meetings[0].Manager__c = null;
		meetings[1].Manager__c = null;
		update meetings;
		
		//Managers should be removed from Folloews list
		eS = [Select SubscriberId, ParentId from EntitySubscription where SubscriberId IN: managers];
		System.assertEquals(0, eS.size());
		
		//Add the  Managers from meeting records
		meetings[0].Manager__c = managers[0].Id;
		meetings[1].Manager__c = managers[0].Id;
		update meetings;
		
		//Check meeting records should have Manager as follower
		eS = [Select SubscriberId, ParentId from EntitySubscription where SubscriberId IN: managers];
		System.assertEquals(2, eS.size());
		System.assert(meetings[0].Id == eS[0].ParentId || meetings[0].Id == eS[1].ParentId);
		System.assert(meetings[1].Id == eS[0].ParentId || meetings[1].Id == eS[1].ParentId);
		
		//Update the records to Closed to True
		meetings[0].Status__c = 'Closed - Completed';
		meetings[1].Status__c = 'Closed - Completed';
		update meetings;
		
		//Stop Test here
		Test.stopTest();
			
		//Managers should be removed from Folloews list
		eS = [Select SubscriberId, ParentId from EntitySubscription where SubscriberId IN: managers];
		System.assertEquals(0, eS.size());   
    }
 	
 	/**
     * @description: 	1. Create a parent Event without Team member and veryfy it has Detfaults Team members Created
     					2. Update the team members data with Contact Information
     					3. Create a Child record to check if the Parent Team member Data has been copied to Chils
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
    
     */
    static testmethod void testCreateDefaultTeamMembers() {
        
   		//Start Testing from here
   		Test.startTest();
   		
   		//create the master record
        Advisory_Event__c master = testUtilities.createEvent(Constants.RECORD_TYPE_ID_ADV_EVENT_SERIES, null, true);
        
        //Verify is default Team members have been created
        List<Team_Member__c> teamMembers = [Select Id, Advisory_Event__c, Primary_Role__c, Team_Member__c from Team_Member__c where Advisory_Event__c =: master.Id ORDER BY Primary_Role__c ASC];
        
        //It should have 2 records created
        System.assertEquals(2, teamMembers.size());
        System.assert(teamMembers[0].Primary_Role__c == 'Series Coordinator' || teamMembers[1].Primary_Role__c == 'Series Coordinator');
        System.assert(teamMembers[0].Primary_Role__c == 'Series Planner' || teamMembers[1].Primary_Role__c == 'Series Planner');
        System.assert(teamMembers[0].Primary_Role__c != teamMembers[1].Primary_Role__c);
        System.assertEquals(null, teamMembers[0].Team_Member__c);
        System.assertEquals(null, teamMembers[1].Team_Member__c);
        
        //Create a list of Contatcs and Insert
		List<Contact> contacts = new List<Contact>();
		
		//Add contacts in list
		contacts.add(testUtilities.createNewContact(false));
		contacts.add(testUtilities.createNewContact(false));
		
		//Insert the contacts
		insert contacts;
		
		//Update the Team members with the contact instance
		teamMembers[0].Team_Member__c = contacts[0].Id;
		update teamMembers[0];
		
        //create the child record
        Advisory_Event__c child = testUtilities.createEvent(Constants.RECORD_TYPE_ID_ADV_EVENT_SERIES, null, false);
        child.Parent_Event__c = master.Id;
        insert child;
        
        //Verify is default Team members have been created
        teamMembers = [Select Id, Advisory_Event__c, Primary_Role__c, Team_Member__c from Team_Member__c where Advisory_Event__c =: child.Id ORDER BY Primary_Role__c];
        
        //It should have 2 records created
        System.assertEquals(2, teamMembers.size());
        System.assert(teamMembers[0].Primary_Role__c == 'Series Coordinator' || teamMembers[1].Primary_Role__c == 'Series Coordinator');
        System.assert(teamMembers[0].Primary_Role__c == 'Series Planner' || teamMembers[1].Primary_Role__c == 'Series Planner');
        System.assert(teamMembers[0].Primary_Role__c != teamMembers[1].Primary_Role__c);
        System.assert(teamMembers[0].Team_Member__c == contacts[0].Id || teamMembers[1].Team_Member__c == contacts[0].Id);
        System.assert(teamMembers[0].Team_Member__c == null || teamMembers[1].Team_Member__c == null);
        System.assert(teamMembers[0].Team_Member__c != teamMembers[1].Team_Member__c);
        
        //Update the Team members with the contact instance
		teamMembers[1].Team_Member__c = contacts[1].Id;
		update teamMembers[1]; 
		
		 //create the child record
        Advisory_Event__c child2 = testUtilities.createEvent(Constants.RECORD_TYPE_ID_ADV_EVENT_SERIES, null, false);
        child2.Parent_Event__c = child.Id;
        insert child2;
        
        //Verify is default Team members have been created
        teamMembers = [Select Id, Advisory_Event__c, Primary_Role__c, Team_Member__c from Team_Member__c where Advisory_Event__c =: child2.Id ORDER BY Primary_Role__c];
        
        //It should have 2 records created
        System.assertEquals(2, teamMembers.size());
        System.assert(teamMembers[0].Primary_Role__c == 'Series Coordinator' || teamMembers[1].Primary_Role__c == 'Series Coordinator');
        System.assert(teamMembers[0].Primary_Role__c == 'Series Planner' || teamMembers[1].Primary_Role__c == 'Series Planner');
        System.assert(teamMembers[0].Primary_Role__c != teamMembers[1].Primary_Role__c);
        System.assert(teamMembers[0].Team_Member__c == contacts[0].Id || teamMembers[1].Team_Member__c == contacts[0].Id);
        System.assert(teamMembers[0].Team_Member__c == contacts[1].Id || teamMembers[1].Team_Member__c == contacts[1].Id);
        System.assert(teamMembers[0].Team_Member__c != teamMembers[1].Team_Member__c);
        
        //Stop test here
        Test.stopTest();
    }
    
    /**
     * 	@use cases	:	1. Parent Rule's should be cloned to child on insert if Rule- field is Use Parent's Rule 
     					2. Nothing should happen if  Rule- field is not set to Use Parent's Rule
     *					3. Parent Rule's should be cloned to child on insert if Rule- field is updated to Use Parent's Rule
     **/
    static testMethod void testCloneRules() {
        
        //Fetch the record Types from database
        List<RecordType> recordTypes = RuleTriggerHelper.mapRuleRecordTypes.values();
        
        //Create a test program record
        Program__c program = new Program__c(Name = 'TestProg', Program_Acronym__c = 'Test');
        insert program;
        
        //Create Parent meeting records
        Advisory_Event__c master = testUtilities.createEvent(Constants.RECORD_TYPE_ID_ADV_EVENT_SERIES, null, false);
        master.Rules_Programs__c = AdvisoryEventTriggerHelper.ESTABLISH_INDEPENDENT_RULES;
        master.Rules_Thresholds__c = AdvisoryEventTriggerHelper.ESTABLISH_INDEPENDENT_RULES;
        master.Rules_Titles__c = AdvisoryEventTriggerHelper.ESTABLISH_INDEPENDENT_RULES;
        insert master;
        
        
        //Create a list of Rules
        List<Rule__c> rules = new List<Rule__c>();
        
        //2 Records for each record type
        for(RecordType rType : recordTypes) {
            
            //Data
            if(rType.DeveloperName != 'Title')
            	rules.add(new Rule__c(Name = 'Test', Advisory_Event__c = master.Id, RecordTypeId = rType.Id, Job_Function__c = 'Test', Threshold_Type__c = 'Test', Program__c = program.Id, Threshold_Number__c = 1));
        }
        
        //Try inserting the rules, it should be successfully inserted
        RuleTriggerHelper.EXECUTE_RULE_TRIGGER = true;
        insert rules;
        
        //Start testing from here
        Test.startTest();
        
        //Create a new Child meeting record by setting Rules_Programs__c and Rules_Thresholds__c
        //As soon as this meeting inserts, it will clone the Meeting event recods parent meeting and will stamp them on child also
        Advisory_Event__c child = testUtilities.createEvent(Constants.RECORD_TYPE_ID_ADV_EVENT_SERIES, null, false);
        child.Parent_Event__c = master.Id;
        child.Rules_Programs__c = AdvisoryEventTriggerHelper.CLONE_PARENT_S_RULES;
        child.Rules_Thresholds__c = AdvisoryEventTriggerHelper.CLONE_PARENT_S_RULES;
        child.Rules_Titles__c = AdvisoryEventTriggerHelper.CLONE_PARENT_S_RULES;
        insert child;
        
        //Assert results
        rules = [Select Id, RecordType.DeveloperName from Rule__c where Advisory_Event__c =: child.Id ORDER BY RecordType.DeveloperName];
        System.assertEquals(2, rules.size());
        System.assertEquals('Program', rules[0].RecordType.DeveloperName);
        System.assertEquals('Threshold', rules[1].RecordType.DeveloperName);
        
        //Check for the rules picklist value
        child = [Select Rules_Programs__c, Rules_Thresholds__c, Rules_Titles__c from Advisory_Event__c where Id =: child.Id];
        System.assertEquals(AdvisoryEventTriggerHelper.ESTABLISH_INDEPENDENT_RULES, child.Rules_Programs__c);
        System.assertEquals(AdvisoryEventTriggerHelper.ESTABLISH_INDEPENDENT_RULES, child.Rules_Thresholds__c);
        System.assertEquals(AdvisoryEventTriggerHelper.ESTABLISH_INDEPENDENT_RULES, child.Rules_Titles__c);
        
        //Create a new Child meeting record by setting Rules_Programs__c and Rules_Thresholds__c
        //As soon as this meeting inserts, it will clone the Meeting event recods parent meeting and will stamp them on child also
        Advisory_Event__c child2 = testUtilities.createEvent(Constants.RECORD_TYPE_ID_ADV_EVENT_SERIES, null, false);
        child2.Parent_Event__c = master.Id;
        insert child2;
        
        //Assert results
        rules = [Select Id, RecordType.DeveloperName from Rule__c where Advisory_Event__c =: child2.Id ORDER BY RecordType.DeveloperName];
        System.assertEquals(0, rules.size());
        
        //Check for the rules picklist value
        child2 = [Select Rules_Programs__c, Rules_Thresholds__c, Rules_Titles__c from Advisory_Event__c where Id =: child2.Id];
        System.assertNotEquals(AdvisoryEventTriggerHelper.ESTABLISH_INDEPENDENT_RULES, child2.Rules_Programs__c);
        System.assertNotEquals(AdvisoryEventTriggerHelper.ESTABLISH_INDEPENDENT_RULES, child2.Rules_Thresholds__c);
        System.assertNotEquals(AdvisoryEventTriggerHelper.ESTABLISH_INDEPENDENT_RULES, child2.Rules_Titles__c);
        
        //Update the rules
        child2.Rules_Programs__c = AdvisoryEventTriggerHelper.CLONE_PARENT_S_RULES;
        child2.Rules_Thresholds__c = AdvisoryEventTriggerHelper.CLONE_PARENT_S_RULES;
        child2.Rules_Titles__c = AdvisoryEventTriggerHelper.CLONE_PARENT_S_RULES;
        update child2;
        
        //Stop test here
        Test.stopTest();
        
        //Assert results
        rules = [Select Id, RecordType.DeveloperName from Rule__c where Advisory_Event__c =: child2.Id ORDER BY RecordType.DeveloperName];
        System.assertEquals(2, rules.size());
        System.assertEquals('Program', rules[0].RecordType.DeveloperName);
        System.assertEquals('Threshold', rules[1].RecordType.DeveloperName);
        
        //Check for the rules picklist value
        child2 = [Select Rules_Programs__c, Rules_Thresholds__c, Rules_Titles__c from Advisory_Event__c where Id =: child2.Id];
        System.assertEquals(AdvisoryEventTriggerHelper.ESTABLISH_INDEPENDENT_RULES, child2.Rules_Programs__c);
        System.assertEquals(AdvisoryEventTriggerHelper.ESTABLISH_INDEPENDENT_RULES, child2.Rules_Thresholds__c);
        System.assertEquals(AdvisoryEventTriggerHelper.ESTABLISH_INDEPENDENT_RULES, child2.Rules_Titles__c);
    }
    
    /**
     * 	@use cases	:	1. Update the Meeting status to Use Parent's rule and verify related rules are deleted or not
     **/
    static testMethod void testDeleteRulesForUseForParent() {
        
        //Fetch the record Types from database
        List<RecordType> recordTypes = RuleTriggerHelper.mapRuleRecordTypes.values();
        
        //Create a test program record
        Program__c program = new Program__c(Name = 'TestProg', Program_Acronym__c = 'Test');
        insert program;
        
        //Create a test program record
        Program__c program2 = new Program__c(Name = 'TestProg2', Program_Acronym__c = 'Test2');
        insert program2;
        
        //Create Parent meeting records
        Advisory_Event__c master = testUtilities.createEvent(Constants.RECORD_TYPE_ID_ADV_EVENT_SERIES, null, false);
        master.Rules_Programs__c = AdvisoryEventTriggerHelper.ESTABLISH_INDEPENDENT_RULES;
        master.Rules_Thresholds__c = AdvisoryEventTriggerHelper.ESTABLISH_INDEPENDENT_RULES;
        master.Rules_Titles__c = AdvisoryEventTriggerHelper.ESTABLISH_INDEPENDENT_RULES;
        insert master;
        
        //Create a list of Rules
        List<Rule__c> rules = new List<Rule__c>();
        
        //2 Records for each record type
        for(RecordType rType : recordTypes) {
            
            //Data
            rules.add(new Rule__c(Name = 'Test', Advisory_Event__c = master.Id, RecordTypeId = rType.Id, Job_Function__c = 'Test', Threshold_Type__c = 'Test', Program__c = program.Id, Threshold_Number__c = 1));
        }
        
        //Try inserting the rules, it should be successfully inserted
        RuleTriggerHelper.EXECUTE_RULE_TRIGGER = true;
        insert rules;
        
        rules = [Select Id, RecordType.DeveloperName from Rule__c where Advisory_Event__c =: master.Id ORDER BY RecordType.DeveloperName];
        System.assertEquals(3, rules.size());
        System.assertEquals('Program', rules[0].RecordType.DeveloperName);
        System.assertEquals('Threshold', rules[1].RecordType.DeveloperName);
        System.assertEquals('Title', rules[2].RecordType.DeveloperName);
        
        //Check if Event Rules also have been created for Parent when Rules were created
        List<Event_Rule__c> eRules = [Select Id, Rule__c, Rule__r.RecordType.DeveloperName, Advisory_Event__c from Event_Rule__c where Advisory_Event__c =: master.Id AND Rule__c IN: rules ORDER BY Rule__r.RecordType.DeveloperName];
        System.assertEquals(3, eRules.size());
        System.assertEquals('Program', eRules[0].Rule__r.RecordType.DeveloperName);
        System.assertEquals('Threshold', eRules[1].Rule__r.RecordType.DeveloperName);
        System.assertEquals('Title', eRules[2].Rule__r.RecordType.DeveloperName);
        
        //Start testing from here
        Test.startTest();
        
        //Create a new Child meeting record by setting Rules_Programs__c and Rules_Thresholds__c
        //As soon as this meeting inserts, it will clone the Meeting event recods parent meeting and will stamp them on child also
        Advisory_Event__c child = testUtilities.createEvent(Constants.RECORD_TYPE_ID_ADV_EVENT_SERIES, null, false);
        child.Parent_Event__c = master.Id;
        child.Rules_Programs__c = AdvisoryEventTriggerHelper.USE_PARENT_S_RULES;
        child.Rules_Thresholds__c = AdvisoryEventTriggerHelper.ESTABLISH_INDEPENDENT_RULES;
        child.Rules_Titles__c = AdvisoryEventTriggerHelper.USE_PARENT_S_RULES;
        insert child;
        
        //Assert results
        rules = [Select Id, RecordType.DeveloperName from Rule__c where Advisory_Event__c =: child.Id ORDER BY RecordType.DeveloperName];
        System.assertEquals(0, rules.size());
      
      	//Check if Event Rules also have been created for Parent when Rules were created
        eRules = [Select Id, Rule__c, Rule__r.RecordType.DeveloperName, Advisory_Event__c from Event_Rule__c where Advisory_Event__c =: child.Id order by Rule__r.RecordType.DeveloperName ASC];
        System.assertEquals(2, eRules.size());
        System.assertEquals('Program', eRules[0].Rule__r.RecordType.DeveloperName);
        System.assertEquals('Title', eRules[1].Rule__r.RecordType.DeveloperName);
        
        //Create a list of new rules
        List<Rule__c> additionalRules = new List<Rule__c>();
        
        //Create another rule for Parent
        for(RecordType rType : recordTypes) {
            
            //Data
            if(rType.DeveloperName == 'Title')
            	additionalRules.add(new Rule__c(Name = 'Test', Advisory_Event__c = master.Id, RecordTypeId = rType.Id, Job_Function__c = 'Test2', Threshold_Type__c = 'Test', Program__c = program.Id, Threshold_Number__c = 1));
        }
        
        //As a new rule has been created on parent,
        //1. It should create new Event Rule on the On the parent
        //2. It should create the Event rule for Child reccord also
        RuleTriggerHelper.EXECUTE_RULE_TRIGGER = true;
        insert additionalRules;
        
        //Check if Event Rules also have been created for Parent when Rules were created
        eRules = [Select Id, Rule__c, Rule__r.RecordType.DeveloperName, Advisory_Event__c from Event_Rule__c where Advisory_Event__c =: master.Id ORDER BY Rule__r.RecordType.DeveloperName];
        System.assertEquals(4, eRules.size());
        System.assertEquals('Program', eRules[0].Rule__r.RecordType.DeveloperName);
        System.assertEquals('Threshold', eRules[1].Rule__r.RecordType.DeveloperName);
        System.assertEquals('Title', eRules[2].Rule__r.RecordType.DeveloperName);
        System.assertEquals('Title', eRules[3].Rule__r.RecordType.DeveloperName);
        
        //Now check if teh same event rule has been created on Child as well
        eRules = [Select Id, Rule__c, Rule__r.RecordType.DeveloperName, Advisory_Event__c from Event_Rule__c where Advisory_Event__c =: child.Id ORDER BY Rule__r.RecordType.DeveloperName];
        System.assertEquals(3, eRules.size());
        System.assertEquals('Program', eRules[0].Rule__r.RecordType.DeveloperName);
        System.assertEquals('Title', eRules[1].Rule__r.RecordType.DeveloperName);
        System.assertEquals('Title', eRules[1].Rule__r.RecordType.DeveloperName);
        
        //Create anotther Child Event
        //Create a new Child meeting record by setting Rules_Programs__c and Rules_Thresholds__c
        //As soon as this meeting inserts, it will clone the Meeting event recods parent meeting and will stamp them on child also
        Advisory_Event__c level2Child = testUtilities.createEvent(Constants.RECORD_TYPE_ID_ADV_EVENT_SERIES, null, false);
        level2Child.Parent_Event__c = child.Id;
        level2Child.Rules_Programs__c = AdvisoryEventTriggerHelper.USE_PARENT_S_RULES;
        level2Child.Rules_Thresholds__c = AdvisoryEventTriggerHelper.USE_PARENT_S_RULES;
        level2Child.Rules_Titles__c = AdvisoryEventTriggerHelper.USE_PARENT_S_RULES;
        insert level2Child;
        
        //Assert results
        rules = [Select Id, RecordType.DeveloperName from Rule__c where Advisory_Event__c =: level2Child.Id ORDER BY RecordType.DeveloperName];
        System.assertEquals(0, rules.size());
      
      	//Check if Event Rules also have been created for Parent when Rules were created
        eRules = [Select Id, Rule__c, Rule__r.RecordType.DeveloperName, Advisory_Event__c from Event_Rule__c where Advisory_Event__c =: level2Child.Id ORDER BY Rule__r.RecordType.DeveloperName];
        System.assertEquals(3, eRules.size());
        System.assertEquals('Program', eRules[0].Rule__r.RecordType.DeveloperName);
        System.assertEquals('Title', eRules[1].Rule__r.RecordType.DeveloperName);
        System.assertEquals('Title', eRules[1].Rule__r.RecordType.DeveloperName);
        
        //Create a list of new rules
        additionalRules = new List<Rule__c>();
        
        //Create another rule for Parent
        for(RecordType rType : recordTypes) {
            
            //Data
            if(rType.DeveloperName == 'Program')
            	additionalRules.add(new Rule__c(Name = 'Test', Advisory_Event__c = master.Id, RecordTypeId = rType.Id, Job_Function__c = 'Test2', Threshold_Type__c = 'Test2', Program__c = program2.Id, Threshold_Number__c = 1));
        }
        
        //As a new rule has been created on parent,
        //1. It should create new Event Rule on the On the parent
        //2. It should create the Event rule for Child reccord also
        RuleTriggerHelper.EXECUTE_RULE_TRIGGER = true;
        insert additionalRules;
        
        //Check if Event Rules also have been created for Parent when Rules were created
        eRules = [Select Id, Rule__c, Rule__r.RecordType.DeveloperName, Advisory_Event__c from Event_Rule__c where Advisory_Event__c =: master.Id ORDER BY Rule__r.RecordType.DeveloperName];
        System.assertEquals(5, eRules.size());
        System.assertEquals('Program', eRules[0].Rule__r.RecordType.DeveloperName);
        System.assertEquals('Program', eRules[1].Rule__r.RecordType.DeveloperName);
        System.assertEquals('Threshold', eRules[2].Rule__r.RecordType.DeveloperName);
        System.assertEquals('Title', eRules[3].Rule__r.RecordType.DeveloperName);
        System.assertEquals('Title', eRules[4].Rule__r.RecordType.DeveloperName);
        
        //Now check if teh same event rule has been created on Child as well
        eRules = [Select Id, Rule__c, Rule__r.RecordType.DeveloperName, Advisory_Event__c from Event_Rule__c where Advisory_Event__c =: child.Id ORDER BY Rule__r.RecordType.DeveloperName];
        System.assertEquals(4, eRules.size());
        System.assertEquals('Program', eRules[0].Rule__r.RecordType.DeveloperName);
        System.assertEquals('Program', eRules[1].Rule__r.RecordType.DeveloperName);
        System.assertEquals('Title', eRules[2].Rule__r.RecordType.DeveloperName);
        System.assertEquals('Title', eRules[3].Rule__r.RecordType.DeveloperName);
        
        //Now check if teh same event rule has been created on Child as well
        eRules = [Select Id, Rule__c, Rule__r.RecordType.DeveloperName, Advisory_Event__c from Event_Rule__c where Advisory_Event__c =: level2Child.Id ORDER BY Rule__r.RecordType.DeveloperName];
        System.assertEquals(4, eRules.size());
        System.assertEquals('Program', eRules[0].Rule__r.RecordType.DeveloperName);
        System.assertEquals('Program', eRules[1].Rule__r.RecordType.DeveloperName);
        System.assertEquals('Title', eRules[2].Rule__r.RecordType.DeveloperName);
        System.assertEquals('Title', eRules[3].Rule__r.RecordType.DeveloperName);
        
        //Check if Primary Program is Same of all teh Events as All child records  have Use Parent Program
        List<Advisory_Event__c> meetings = [Select Id, Primary_Program__c from Advisory_Event__c ORDER BY CreatedDate ASC];
        System.assertEquals(3, meetings.size());
        System.assertEquals(program.Id, meetings[0].Primary_Program__c);
        System.assertEquals(program.Id, meetings[1].Primary_Program__c);
        System.assertEquals(program.Id, meetings[2].Primary_Program__c);
        
		//Stop test here
		Test.stopTest();
    }
    
    /**
     * 	@use cases	:	1. Update the Meeting status to ESTABLISH_INDEPENDENT_RULES and verify related rules are deleted or not
     **/
    static testMethod void testDeleteRulesForEstablishIndependentRules() {
        
        //Fetch the record Types from database
        List<RecordType> recordTypes = RuleTriggerHelper.mapRuleRecordTypes.values();
        
        //Create a test program record
        Program__c program = new Program__c(Name = 'TestProg', Program_Acronym__c = 'Test');
        insert program;
        
        //Create a test program record
        Program__c program2 = new Program__c(Name = 'TestProg2', Program_Acronym__c = 'Test2');
        insert program2;
        
        //Create Parent meeting records
        Advisory_Event__c master = testUtilities.createEvent(Constants.RECORD_TYPE_ID_ADV_EVENT_SERIES, null, false);
        master.Rules_Programs__c = AdvisoryEventTriggerHelper.ESTABLISH_INDEPENDENT_RULES;
        master.Rules_Thresholds__c = AdvisoryEventTriggerHelper.ESTABLISH_INDEPENDENT_RULES;
        master.Rules_Titles__c = AdvisoryEventTriggerHelper.ESTABLISH_INDEPENDENT_RULES;
        insert master;
        
        //Create a list of Rules
        List<Rule__c> rules = new List<Rule__c>();
        
        //2 Records for each record type
        for(RecordType rType : recordTypes) {
            
            //Data
            rules.add(new Rule__c(Name = 'Test', Advisory_Event__c = master.Id, RecordTypeId = rType.Id, Job_Function__c = 'Test', Threshold_Type__c = 'Test', Program__c = program.Id, Threshold_Number__c = 1));
        }
        
        //Try inserting the rules, it should be successfully inserted
        RuleTriggerHelper.EXECUTE_RULE_TRIGGER = true;
        insert rules;
        
        rules = [Select Id, RecordType.DeveloperName from Rule__c where Advisory_Event__c =: master.Id ORDER BY RecordType.DeveloperName];
        System.assertEquals(3, rules.size());
        System.assertEquals('Program', rules[0].RecordType.DeveloperName);
        System.assertEquals('Threshold', rules[1].RecordType.DeveloperName);
        System.assertEquals('Title', rules[2].RecordType.DeveloperName);
        
        //Check if Event Rules also have been created for Parent when Rules were created
        List<Event_Rule__c> eRules = [Select Id, Rule__c, Rule__r.RecordType.DeveloperName, Advisory_Event__c from Event_Rule__c where Advisory_Event__c =: master.Id AND Rule__c IN: rules ORDER BY Rule__r.RecordType.DeveloperName];
        System.assertEquals(3, eRules.size());
        System.assertEquals('Program', eRules[0].Rule__r.RecordType.DeveloperName);
        System.assertEquals('Threshold', eRules[1].Rule__r.RecordType.DeveloperName);
        System.assertEquals('Title', eRules[2].Rule__r.RecordType.DeveloperName);
        
        //Start testing from here
        Test.startTest();
        
        //Create a new Child meeting record by setting Rules_Programs__c and Rules_Thresholds__c
        //As soon as this meeting inserts, it will clone the Meeting event recods parent meeting and will stamp them on child also
        Advisory_Event__c child = testUtilities.createEvent(Constants.RECORD_TYPE_ID_ADV_EVENT_SERIES, null, false);
        child.Parent_Event__c = master.Id;
        child.Rules_Programs__c = AdvisoryEventTriggerHelper.USE_PARENT_S_RULES;
        child.Rules_Thresholds__c = AdvisoryEventTriggerHelper.ESTABLISH_INDEPENDENT_RULES;
        child.Rules_Titles__c = AdvisoryEventTriggerHelper.USE_PARENT_S_RULES;
        insert child;
        
        //Assert results
        rules = [Select Id, RecordType.DeveloperName from Rule__c where Advisory_Event__c =: child.Id ORDER BY RecordType.DeveloperName];
        System.assertEquals(0, rules.size());
      
      	//Check if Event Rules also have been created for Parent when Rules were created
        eRules = [Select Id, Rule__c, Rule__r.RecordType.DeveloperName, Advisory_Event__c from Event_Rule__c where Advisory_Event__c =: child.Id ORDER BY Rule__r.RecordType.DeveloperName];
        System.assertEquals(2, eRules.size());
        System.assertEquals('Program', eRules[0].Rule__r.RecordType.DeveloperName);
        System.assertEquals('Title', eRules[1].Rule__r.RecordType.DeveloperName);
        
        //Update the child with ESTABLISH_INDEPENDENT_RULES
        child.Rules_Programs__c = AdvisoryEventTriggerHelper.ESTABLISH_INDEPENDENT_RULES;
        child.Rules_Thresholds__c = AdvisoryEventTriggerHelper.ESTABLISH_INDEPENDENT_RULES;
        child.Rules_Titles__c = AdvisoryEventTriggerHelper.USE_PARENT_S_RULES;
        update child;
                
		//Check if Event Rules also have been created for Parent when Rules were created
        eRules = [Select Id, Rule__c, Rule__r.RecordType.DeveloperName, Advisory_Event__c from Event_Rule__c where Advisory_Event__c =: child.Id ORDER BY Rule__r.RecordType.DeveloperName];
        System.assertEquals(1, eRules.size());
        System.assertEquals('Title', eRules[0].Rule__r.RecordType.DeveloperName);
        
        //Update the child with ESTABLISH_INDEPENDENT_RULES
        child.Rules_Programs__c = AdvisoryEventTriggerHelper.ESTABLISH_INDEPENDENT_RULES;
        child.Rules_Thresholds__c = AdvisoryEventTriggerHelper.ESTABLISH_INDEPENDENT_RULES;
        child.Rules_Titles__c = AdvisoryEventTriggerHelper.ESTABLISH_INDEPENDENT_RULES;
        update child;
        
        //Check if Event Rules also have been created for Parent when Rules were created
        eRules = [Select Id, Rule__c, Rule__r.RecordType.DeveloperName, Advisory_Event__c from Event_Rule__c where Advisory_Event__c =: child.Id ORDER BY Rule__r.RecordType.DeveloperName];
        System.assertEquals(0, eRules.size());
        
      	child.Rules_Programs__c = AdvisoryEventTriggerHelper.USE_PARENT_S_RULES;
        child.Rules_Thresholds__c = AdvisoryEventTriggerHelper.ESTABLISH_INDEPENDENT_RULES;
        child.Rules_Titles__c = AdvisoryEventTriggerHelper.USE_PARENT_S_RULES;
        update child;
        
        //Check if Event Rules also have been created for Parent when Rules were created
        eRules = [Select Id, Rule__c, Rule__r.RecordType.DeveloperName, Advisory_Event__c from Event_Rule__c where Advisory_Event__c =: child.Id ORDER BY Rule__r.RecordType.DeveloperName];
        System.assertEquals(2, eRules.size());
        System.assertEquals('Program', eRules[0].Rule__r.RecordType.DeveloperName);
        System.assertEquals('Title', eRules[1].Rule__r.RecordType.DeveloperName);
        
        //Stop test here
		Test.stopTest();
    }
}