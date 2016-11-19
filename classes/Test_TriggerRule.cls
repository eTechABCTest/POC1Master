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
private class Test_TriggerRule {
    
    //test Uniqueness of rules
    static testMethod void testValidateRulesUniqueness() {
        
        //Start test from here
        Test.startTest();
        
        //Fetch the record Types from database
        List<RecordType> recordTypes = RuleTriggerHelper.mapRuleRecordTypes.values();
        
        //Create a test program record
        Program__c program = new Program__c(Name = 'TestProg', Program_Acronym__c = 'Test');
        insert program;
        
        //Create Parent meeting records
        Advisory_Event__c meeting = testUtilities.createEvent(Constants.RECORD_TYPE_ID_ADV_EVENT_SERIES, null, false);
        meeting.Rules_Programs__c = AdvisoryEventTriggerHelper.ESTABLISH_INDEPENDENT_RULES;
        meeting.Rules_Thresholds__c = AdvisoryEventTriggerHelper.ESTABLISH_INDEPENDENT_RULES;
        meeting.Rules_Titles__c = AdvisoryEventTriggerHelper.ESTABLISH_INDEPENDENT_RULES;
        insert meeting;
        
        //Create a list of Rules
        List<Rule__c> rules = new List<Rule__c>();
        
        //2 Records for each record type
        for(RecordType rType : recordTypes) {
            
            //Data
            rules.add(new Rule__c(Name = 'Test', Advisory_Event__c =  meeting.Id, RecordTypeId = rType.Id, Job_Function__c = 'Test', Threshold_Type__c = 'Test', Program__c = program.Id, Threshold_Number__c = 1));
        }
        
        //Try inserting the rules, it should be successfully inserted
        RuleTriggerHelper.EXECUTE_RULE_TRIGGER = true;
        insert rules;
        
        //Create the new records
        rules = new List<Rule__c>();
        
        //2 Records for each record type
        for(RecordType rType : recordTypes) {
            
            //Data
            rules.add(new Rule__c(Name = 'Test', Advisory_Event__c =  meeting.Id, RecordTypeId = rType.Id, Job_Function__c = 'Test', Threshold_Type__c = 'Test', Program__c = program.Id, Threshold_Number__c = 1));
        }
        
        //Try inserting the rules, it should throw an error for unique data
        try {
            RuleTriggerHelper.EXECUTE_RULE_TRIGGER = true;
            insert rules;
            
            //Fail test method, if records were passed
            System.assert(false, 'This was supposed to throw exception');
            
        } catch(Exception e) {
            
            //Pass the test
            System.assert(true);
        }
        
        //Stop test here
        Test.stopTest();
        
        //Query rules from database and assert for results
        rules = [Select Id from Rule__c];
        System.assertEquals(3, rules.size());
    }
    
    //test validatePrimaryRule and updateMeeting
    static testMethod void testValidatePrimaryRuleWhenNoRuleExistAlready() {
    	
    	//Fetch the record Types from database
        List<RecordType> recordTypes = [Select Id, Name, DeveloperName from RecordType 
        																where SObjectType = 'Rule__c' 
        																AND DeveloperName =: RuleTriggerHelper.RECORD_TYPE_RULE_DEVELOPER_NAME_PROGRAM 
        																AND IsActive = true];
        
        //Create a test program record
        Program__c program = new Program__c(Name = 'TestProg', Program_Acronym__c = 'Test');
        insert program;
        
        //Create Parent meeting records
        Advisory_Event__c meeting = testUtilities.createEvent(Constants.RECORD_TYPE_ID_ADV_EVENT_SERIES, null, false);
        meeting.Rules_Programs__c = AdvisoryEventTriggerHelper.ESTABLISH_INDEPENDENT_RULES;
        meeting.Rules_Thresholds__c = AdvisoryEventTriggerHelper.ESTABLISH_INDEPENDENT_RULES;
        meeting.Rules_Titles__c = AdvisoryEventTriggerHelper.ESTABLISH_INDEPENDENT_RULES;
        insert meeting;
        
        
        //Start test from here
        Test.startTest();
        
        //Create a Rule record
        Rule__c rule = new Rule__c(Name = 'Test', Advisory_Event__c =  meeting.Id, RecordTypeId = recordTypes[0].Id, Job_Function__c = 'Test', Threshold_Type__c = 'Test', Program__c = program.Id, Threshold_Number__c = 1);
        
        //Try inserting the rules, it should be successfully inserted
        RuleTriggerHelper.EXECUTE_RULE_TRIGGER = true;
        insert rule;
        
        //Stop Test here
        Test.stopTest();
        
        //This rule should be marked as Primary
        rule = [Select Primary__c, Advisory_Event__r.Primary_Program__c from Rule__c where Id =: rule.Id];
        System.assert(rule.Primary__c);
        System.assertEquals(program.Id, rule.Advisory_Event__r.Primary_Program__c);
    }
    
    //test validatePrimaryRule and updateMeeting
    static testMethod void testValidatePrimaryRuleWhenPrimaryRulesExistAlready() {
    	
    	//Fetch the record Types from database
        List<RecordType> recordTypes = [Select Id, Name, DeveloperName from RecordType 
        																where SObjectType = 'Rule__c' 
        																AND DeveloperName =: RuleTriggerHelper.RECORD_TYPE_RULE_DEVELOPER_NAME_PROGRAM 
        																AND IsActive = true];
        
        //Create a test program record
        Program__c program = new Program__c(Name = 'TestProg', Program_Acronym__c = 'Test');
        insert program;
        Program__c program2 = new Program__c(Name = 'TestProg', Program_Acronym__c = 'Test');
        insert program2;
        
        //Create Parent meeting records
        Advisory_Event__c meeting = testUtilities.createEvent(Constants.RECORD_TYPE_ID_ADV_EVENT_SERIES, null, false);
        meeting.Rules_Programs__c = AdvisoryEventTriggerHelper.ESTABLISH_INDEPENDENT_RULES;
        meeting.Rules_Thresholds__c = AdvisoryEventTriggerHelper.ESTABLISH_INDEPENDENT_RULES;
        meeting.Rules_Titles__c = AdvisoryEventTriggerHelper.ESTABLISH_INDEPENDENT_RULES;
        insert meeting;
        
        
        //Create a Rule record
        List<Rule__c> rules = new List<Rule__c>();
        rules.add(new Rule__c(Name = 'ATest', Advisory_Event__c =  meeting.Id, RecordTypeId = recordTypes[0].Id, Job_Function__c = 'A-Test', Threshold_Type__c = 'Test', Program__c = program.Id, Threshold_Number__c = 1, Primary__c = true));

        //Try inserting the rules, it should be successfully inserted
        RuleTriggerHelper.EXECUTE_RULE_TRIGGER = true;
        insert rules;
        
        //Start Test
        Test.startTest();
        
        //Create a Rule record
        rules = new List<Rule__c>();
        rules.add(new Rule__c(Name = 'BTest', Advisory_Event__c =  meeting.Id, RecordTypeId = recordTypes[0].Id, Job_Function__c = 'B-Test', Threshold_Type__c = 'Test', Program__c = program2.Id, Threshold_Number__c = 1, Primary__c = true));
        
        //Try inserting the rules, it should be successfully inserted
        RuleTriggerHelper.EXECUTE_RULE_TRIGGER = true;
        insert rules;
        
        //Stop Test here
        Test.stopTest();
        
        //Fetch the rules order by created date, firstone should be set to not primary and secont one as Primary. 
        //Meeting record should be updated with Second Rule Program
        rules = [Select Primary__c, Advisory_Event__r.Primary_Program__c from Rule__c where Advisory_Event__c = : meeting.Id Order by Job_Function__c ASC];
        System.assert(!rules[0].Primary__c);
        System.assert(rules[1].Primary__c);
        System.assertEquals(program2.Id, rules[1].Advisory_Event__r.Primary_Program__c);
    }
    
    //test validatePrimaryRule and updateMeeting
    static testMethod void testUpdateMeeting() {
    	
    	//Fetch the record Types from database
        List<RecordType> recordTypes = [Select Id, Name, DeveloperName from RecordType 
        																where SObjectType = 'Rule__c' 
        																AND DeveloperName =: RuleTriggerHelper.RECORD_TYPE_RULE_DEVELOPER_NAME_TITLE
        																AND IsActive = true];
        
        //Create Parent meeting records
        Advisory_Event__c meeting = testUtilities.createEvent(Constants.RECORD_TYPE_ID_ADV_EVENT_SERIES, null, false);
        meeting.Rules_Programs__c = AdvisoryEventTriggerHelper.ESTABLISH_INDEPENDENT_RULES;
        meeting.Rules_Thresholds__c = AdvisoryEventTriggerHelper.ESTABLISH_INDEPENDENT_RULES;
        meeting.Rules_Titles__c = AdvisoryEventTriggerHelper.ESTABLISH_INDEPENDENT_RULES;
        insert meeting;
        
        //Create a Rule record
        Rule__c rule1 = new Rule__c(Name = 'ATest', Advisory_Event__c =  meeting.Id, RecordTypeId = recordTypes[0].Id, Job_Function__c = 'A-Test', Threshold_Type__c = 'Test', Threshold_Number__c = 1, Primary__c = true);
		RuleTriggerHelper.EXECUTE_RULE_TRIGGER = true;
        RuleTriggerHelper.EXECUTE_RULE_UNIQUENESS= true;
        insert rule1;
		
        //Start Test
        Test.startTest();
        
        //Check for the Title_String Value on Meeting 
        meeting = [Select Title_String__c from Advisory_Event__c where Id =: meeting.Id];
        System.assertEquals('A-Test', meeting.Title_String__c);
        
        //Create a Rule record
        Rule__c rule2 = new Rule__c(Name = 'BTest', Advisory_Event__c = meeting.Id, RecordTypeId = recordTypes[0].Id, Job_Function__c = 'B-Test', Threshold_Type__c = 'Test', Threshold_Number__c = 1, Primary__c = true);
        RuleTriggerHelper.EXECUTE_RULE_TRIGGER = true;
        RuleTriggerHelper.EXECUTE_RULE_UNIQUENESS= true;
        insert rule2;
        
        //Check for the Title_String Value on Meeting 
        meeting = [Select Title_String__c from Advisory_Event__c where Id =: meeting.Id];
        System.assertEquals('A-Test///B-Test', meeting.Title_String__c);
        
        //Update Use Case
        rule2.Job_Function__c = 'C-Test';
        RuleTriggerHelper.EXECUTE_RULE_TRIGGER = true;
        RuleTriggerHelper.EXECUTE_RULE_UNIQUENESS= true;
        update rule2;
        
        //Check for the Title_String Value on Meeting 
        meeting = [Select Title_String__c from Advisory_Event__c where Id =: meeting.Id];
        System.assertEquals('A-Test///C-Test', meeting.Title_String__c);
        
        //Update Case, Not Null
        rule2.Job_Function__c = 'B-Test';
        RuleTriggerHelper.EXECUTE_RULE_TRIGGER = true;
        RuleTriggerHelper.EXECUTE_RULE_UNIQUENESS= true;
        update rule2;
        
        //Check for the Title_String Value on Meeting 
        meeting = [Select Title_String__c from Advisory_Event__c where Id =: meeting.Id];
        System.assertEquals('A-Test///B-Test', meeting.Title_String__c);
        
        //Delete case
        RuleTriggerHelper.EXECUTE_RULE_TRIGGER = true;
        RuleTriggerHelper.EXECUTE_RULE_UNIQUENESS= true;
        delete rule2;
        
        //Check for the Title_String Value on Meeting 
        meeting = [Select Title_String__c from Advisory_Event__c where Id =: meeting.Id];
        System.assertEquals('A-Test', meeting.Title_String__c);
        
        //Delete case
        RuleTriggerHelper.EXECUTE_RULE_TRIGGER = true;
        RuleTriggerHelper.EXECUTE_RULE_UNIQUENESS= true;
        delete rule1;
        
        //Check for the Title_String Value on Meeting 
        meeting = [Select Title_String__c from Advisory_Event__c where Id =: meeting.Id];
        System.assertEquals(null, meeting.Title_String__c);
        
        //Stop Test here
        Test.stopTest();
    }
    
    /**
     * 	@use cases	:	1. Parent Rule's should be cloned to child on insert if Rule- field is Use Parent's Rule 
     					2. Nothing should happen if  Rule- field is not set to Use Parent's Rule
     *					3. Parent Rule's should be cloned to child on insert if Rule- field is updated to Use Parent's Rule
     **/
    static testMethod void testValidateRulesBeforeInsert() {
        
        //Fetch the record Types from database
        List<RecordType> recordTypes = RuleTriggerHelper.mapRuleRecordTypes.values();
        
        //Create a test program record
        Program__c program = new Program__c(Name = 'TestProg', Program_Acronym__c = 'Test');
        insert program;
        
        //Create Parent meeting records
        Advisory_Event__c master = testUtilities.createEvent(Constants.RECORD_TYPE_ID_ADV_EVENT_SERIES, null, false);
        master.Rules_Programs__c = AdvisoryEventTriggerHelper.USE_PARENT_S_RULES;
        master.Rules_Thresholds__c = AdvisoryEventTriggerHelper.USE_PARENT_S_RULES;
        insert master;
        
        //Create a list of Rules
        List<Rule__c> rules = new List<Rule__c>();
        
        //2 Records for each record type
        for(RecordType rType : recordTypes) {
            
            //Data
            rules.add(new Rule__c(Name = 'Test', Advisory_Event__c = master.Id, RecordTypeId = rType.Id, Job_Function__c = 'Test', Threshold_Type__c = 'Test', Program__c = program.Id, Threshold_Number__c = 1));
        }
        
        //Start testing from here
        Test.startTest();
        
        //Try inserting the rules, it should throw exception
        RuleTriggerHelper.EXECUTE_RULE_TRIGGER = true;
        
        try {
        	
        	//Insert
        	insert rules;
        	
        	//Fail the test method if records get inserted
        	System.assert(false);
        } catch(Exception e) {
    		
    		//Chekc for the exception message
    		System.assert(e.getMessage().containsIgnoreCase(Label.ERROR_BLOCKED_INSERT_USE_PARENT_S_RULE));
        }
        
        //Stop test here
        Test.stopTest();
    }
}