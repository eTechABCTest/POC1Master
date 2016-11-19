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
@isTest(seeAllData = false)
private class Test_IntegrationTrigger {
	
/**
 *  Purpose         :   Test class for IntegrationTriggerUtil
 *
 *  Created By      :   
 *
 *  Created Date    :   
 *
 *  Revision Logs   :   V_1.0 - Created
 *                      V_1.1 - Modified by - Abhinav Sharma - 07/20/2016 - CR-20150202-8637 - A code refactor CR
 *
 *   Coverage       :   V_1.1 - 92% - IntegrationTriggerUtil
 * 								93% - IntegrationTriggerHelper
 *                       
 **/

	
	//Modified by - Abhinav Sharma - 07/20/2016 - CR-20150202-8637 - A code refactor CR
    /** Description : Method to test out that 
     *					a) "Department_Name__c" field value is populated as expected on "budget" record.
     *					b) Busget line records were created in expected manner or not
     *					whenever a DML statement will happen on the integration record(s) for "OpEx" type.
    **/
    static testmethod void testIntegrationBudget_OpEx() {
    	
    	//Bypass Dupeblocker and disbaling triggers for test data creation purpose
        Util.IsTest(true);
        Util.isTesting = true;
        Util.byPassAllTriggers = true;
        
        //Set up the Custom Setting
        list<RecordType> intRecType = [SELECT Id, DeveloperName 
        							   FROM RecordType 
        							   WHERE SobjectType = 'Integration__c' 
        							   AND IsActive = true 
        							   LIMIT 1];
        
        //Asserting for the results
        System.assert(intRecType != null);							   
        System.assert(intRecType.size() > 0);							   
        
        //Create integration record
        Integration_Job__c intjob = new Integration_Job__c();
        intjob.Name = intRecType[0].Id;
        intjob.Integration_Job_Name__c = intRecType[0].DeveloperName;
        
        //Insert integration record
        insert intjob;
        
        //Set up the Custom Setting for the Recordtype Settings
        list<RecordType_Setting__c> listRTSetting = new list<RecordType_Setting__c>();
        
        //Query over Budge object records type & create RecordType Setting records
        for(RecordType rtBudget : ([SELECT Id, DeveloperName 
        								FROM RecordType 
        								WHERE SObjectType = 'Budget__c'
        								AND IsActive = true])){
        	
        	//Record Type Setting									
        	RecordType_Setting__c rts = new RecordType_Setting__c();
        	rts.SObjectType__c = 'Budget__c';
        	rts.Name__c = rtBudget.DeveloperName;
        	rts.SFID__c = rtBudget.Id;
        	rts.Name = rtBudget.Id;
        	listRTSetting.add(rts);
        }
        
        //Insert records
        insert listRTSetting;
        
        //Asserting for the results
        System.assert(listRTSetting != null);							   
        System.assert(listRTSetting.size() > 0);	
       
        //Set up a Department
        Department__c dept = new Department__c();
        dept.Department_Number__c = '12345';
        dept.Name = 'Test Department';
        insert dept;
        
        //set up the Mapping
        list<Integration_Mapping__c> listIM = new list<Integration_Mapping__c>();
        
        //Hold Integration Job Developer name
        string intName = intjob.Integration_Job_Name__c;
        
        //Budget fields
        string obj = 'Budget__c';
        
        //Create integration mapping records
        Integration_Mapping__c IM01 = new Integration_Mapping__c(Integration_Name__c = intName,Stg_Field_Name__c = 'TextField01__c',SF_Object_Name__c = obj,SF_Object_Field__c = 'Department_Code__c');
        listIM.add(IM01);
        Integration_Mapping__c IM02 = new Integration_Mapping__c(Integration_Name__c = intName,Stg_Field_Name__c = 'TextField02__c',SF_Object_Name__c = obj,SF_Object_Field__c = 'Department_Name__c');
        listIM.add(IM02);
        Integration_Mapping__c IM03 = new Integration_Mapping__c(Integration_Name__c = intName,Stg_Field_Name__c = 'TextField03__c',SF_Object_Name__c = obj,SF_Object_Field__c = 'Account_Number__c');
        listIM.add(IM03);
        Integration_Mapping__c IM04 = new Integration_Mapping__c(Integration_Name__c = intName,Stg_Field_Name__c = 'TextField04__c',SF_Object_Name__c = obj,SF_Object_Field__c = 'Account_Name__c');
        listIM.add(IM04);
        Integration_Mapping__c IM05 = new Integration_Mapping__c(Integration_Name__c = intName,Stg_Field_Name__c = 'TextField05__c',SF_Object_Name__c = obj,SF_Object_Field__c = 'Description__c');
        listIM.add(IM05);
        Integration_Mapping__c IM06 = new Integration_Mapping__c(Integration_Name__c = intName,Stg_Field_Name__c = 'TextField06__c',SF_Object_Name__c = obj,SF_Object_Field__c = 'Asset_Category__c');
        listIM.add(IM06);
        Integration_Mapping__c IM07 = new Integration_Mapping__c(Integration_Name__c = intName,Stg_Field_Name__c = 'TextField07__c',SF_Object_Name__c = obj,SF_Object_Field__c = 'Fixed_Asset__c');
        listIM.add(IM07);
        Integration_Mapping__c IM22 = new Integration_Mapping__c(Integration_Name__c = intName,Stg_Field_Name__c = 'TextField22__c',SF_Object_Name__c = obj,SF_Object_Field__c = 'Budget_Item__c');
        listIM.add(IM22);
        Integration_Mapping__c IM23 = new Integration_Mapping__c(Integration_Name__c = intName,Stg_Field_Name__c = 'TextField23__c',SF_Object_Name__c = obj,SF_Object_Field__c = 'Unique_ID__c');
        listIM.add(IM23);
        Integration_Mapping__c IM24 = new Integration_Mapping__c(Integration_Name__c = intName,Stg_Field_Name__c = 'TextField24__c',SF_Object_Name__c = obj,SF_Object_Field__c = 'BudgetType');
        listIM.add(IM24);
		
		//Budget Line fields
		obj = 'Budget_Line__c';
        Integration_Mapping__c IM08 = new Integration_Mapping__c(Integration_Name__c = intName,Stg_Field_Name__c = 'TextField08__c',SF_Object_Name__c = obj,SF_Object_Field__c = 'Month__c');
        listIM.add(IM08);
        Integration_Mapping__c IM01n = new Integration_Mapping__c(Integration_Name__c = intName,Stg_Field_Name__c = 'Number01__c',SF_Object_Name__c = obj,SF_Object_Field__c = 'Amount__c');
        listIM.add(IM01n);
        Integration_Mapping__c IM09 = new Integration_Mapping__c(Integration_Name__c = intName,Stg_Field_Name__c = 'TextField09__c',SF_Object_Name__c = obj,SF_Object_Field__c = 'Year__c');
        listIM.add(IM09);
        Integration_Mapping__c IM10 = new Integration_Mapping__c(Integration_Name__c = intName,Stg_Field_Name__c = 'TextField10__c',SF_Object_Name__c = obj,SF_Object_Field__c = 'Jan__c');
        listIM.add(IM10);
        Integration_Mapping__c IM11 = new Integration_Mapping__c(Integration_Name__c = intName,Stg_Field_Name__c = 'TextField11__c',SF_Object_Name__c = obj,SF_Object_Field__c = 'Feb__c');
        listIM.add(IM11);
        Integration_Mapping__c IM12 = new Integration_Mapping__c(Integration_Name__c = intName,Stg_Field_Name__c = 'TextField12__c',SF_Object_Name__c = obj,SF_Object_Field__c = 'Mar__c');
        listIM.add(IM12);
        Integration_Mapping__c IM13 = new Integration_Mapping__c(Integration_Name__c = intName,Stg_Field_Name__c = 'TextField13__c',SF_Object_Name__c = obj,SF_Object_Field__c = 'Apr__c');
        listIM.add(IM13);
        Integration_Mapping__c IM14 = new Integration_Mapping__c(Integration_Name__c = intName,Stg_Field_Name__c = 'TextField14__c',SF_Object_Name__c = obj,SF_Object_Field__c = 'May__c');
        listIM.add(IM14);
        Integration_Mapping__c IM15 = new Integration_Mapping__c(Integration_Name__c = intName,Stg_Field_Name__c = 'TextField15__c',SF_Object_Name__c = obj,SF_Object_Field__c = 'Jun__c');
        listIM.add(IM15);
        Integration_Mapping__c IM16 = new Integration_Mapping__c(Integration_Name__c = intName,Stg_Field_Name__c = 'TextField16__c',SF_Object_Name__c = obj,SF_Object_Field__c = 'Jul__c');
        listIM.add(IM16);
        Integration_Mapping__c IM17 = new Integration_Mapping__c(Integration_Name__c = intName,Stg_Field_Name__c = 'TextField17__c',SF_Object_Name__c = obj,SF_Object_Field__c = 'Aug__c');
        listIM.add(IM17);
        Integration_Mapping__c IM18 = new Integration_Mapping__c(Integration_Name__c = intName,Stg_Field_Name__c = 'TextField18__c',SF_Object_Name__c = obj,SF_Object_Field__c = 'Sep__c');
        listIM.add(IM18);
        Integration_Mapping__c IM19 = new Integration_Mapping__c(Integration_Name__c = intName,Stg_Field_Name__c = 'TextField19__c',SF_Object_Name__c = obj,SF_Object_Field__c = 'Oct__c');
        listIM.add(IM19);
        Integration_Mapping__c IM20 = new Integration_Mapping__c(Integration_Name__c = intName,Stg_Field_Name__c = 'TextField20__c',SF_Object_Name__c = obj,SF_Object_Field__c = 'Nov__c');
        listIM.add(IM20);
        Integration_Mapping__c IM21 = new Integration_Mapping__c(Integration_Name__c = intName,Stg_Field_Name__c = 'TextField21__c',SF_Object_Name__c = obj,SF_Object_Field__c = 'Dec__c');
        listIM.add(IM21);
        
        //insert Integration Mapping records
        insert listIM;   
        
        //Asserting for the results
        System.assert(listIM != null);							   
        System.assert(listIM.size() > 0);		     
        
        //Add the Integration records
        list<Integration__c> intgs = new list<Integration__c>();
        
        //Cerate tntegration record
        Integration__c intg1 = new Integration__c();
        intg1.External_Id__c = '2';
        intg1.External_system__c = 'test';
        intg1.Number01__c    = null;
        intg1.TextField01__c = '12345';
        intg1.TextField02__c = 'Test Department';
        intg1.TextField03__c = '98765';
        intg1.TextField04__c = 'Software';
        intg1.TextField05__c = 'Software Maintenance';
        intg1.TextField06__c = '';
        intg1.TextField07__c = '';
        intg1.TextField08__c = '';
        intg1.TextField09__c = '2013';
        intg1.TextField10__c = '100';
        intg1.TextField11__c = '100';
        intg1.TextField12__c = '100';
        intg1.TextField13__c = '100';
        intg1.TextField14__c = '100';
        intg1.TextField15__c = '100';
        intg1.TextField16__c = '100';
        intg1.TextField17__c = '100';
        intg1.TextField18__c = '100';
        intg1.TextField19__c = '100';
        intg1.TextField20__c = '100';
        intg1.TextField21__c = '100';
        intg1.TextField22__c = 'Microsoft PowerPoint';
        intg1.TextField23__c = '12345'+'--'+'98765'+'--'+'Software Maintenance';
        intg1.TextField24__c = 'OpEx';
        intg1.RecordTypeId = intJob.Name;
        intg1.Operation__c = 'Insert';
        intg1.SFDC_Object__c = 'Budget__c';
        
        //Added record in list
        intgs.add(intg1);
        
        //Create integration record
        Integration__c intg2 = new Integration__c();
        intg2.External_Id__c = '2';
        intg2.External_system__c = 'test';
        intg2.Number01__c    = null;
        intg2.TextField01__c = '12345';
        intg2.TextField02__c = 'Test Department';
        intg2.TextField03__c = '98765';
        intg2.TextField04__c = 'Software';
        intg2.TextField05__c = 'Software Maintenance';
        intg2.TextField06__c = '';
        intg2.TextField07__c = '';
        intg2.TextField08__c = '';
        intg2.TextField09__c = '2014';
        intg2.TextField10__c = '110';
        intg2.TextField11__c = '120';
        intg2.TextField12__c = '130';
        intg2.TextField13__c = '140';
        intg2.TextField14__c = '150';
        intg2.TextField15__c = '160';
        intg2.TextField16__c = '170';
        intg2.TextField17__c = '180';
        intg2.TextField18__c = '190';
        intg2.TextField19__c = '120';
        intg2.TextField20__c = '121';
        intg2.TextField21__c = '122';
        intg2.TextField22__c = 'Microsoft PowerPoint';
        intg2.TextField23__c = '12345'+'--'+'98765'+'--'+'Software Maintenance';
        intg2.TextField24__c = 'OpEx';
        intg2.RecordTypeId = intJob.Name;
        intg2.Operation__c = 'Insert';
        intg2.SFDC_Object__c = 'Budget__c';
        
        //Added record in list
        intgs.add(intg2);
        
        //Define properties
        list<Integration__c> intResult = new list<Integration__c>();
        list<Budget__c> resultBudget = new list<Budget__c>();
        list<Budget_Line__c> resultBLI = new list<Budget_Line__c>();
        string uId = intg2.TextField23__c;
        
        //Run the test
        Test.startTest();
        
    	//Enabling triggers
    	Util.byPassAllTriggers = false;
    	
    	//Insert integration records
    	insert intgs;
    	
    	//Asserting for the results
        System.assert(intgs != null);							   
        System.assert(intgs.size() > 0);	
    	
    	//Querying for the integration records details
    	intResult = [SELECT Id, Status__c 
    					FROM Integration__c 
    					WHERE TextField23__c != null AND TextField23__c = :uId];
    					
		//Asserting for the results
        System.assert(intResult != null);							   
        System.assert(intResult.size() > 0);
    					
    	//Querying for the budget records details				
    	resultBudget = [SELECT Id, Account_Name__c, Budget_Item__c, Department_Name__c 
    					FROM Budget__c 
    					WHERE Unique_Id__c != null AND Unique_Id__c = :uId];
    					
    	//Asserting for the results
        System.assert(resultBudget != null);							   
        System.assert(resultBudget.size() > 0);					
    	
    	//Budget ID				
    	Id idBudget = resultBudget[0].Id;
    	
    	//Querying for the budget line records details
    	resultBLI = [SELECT Id, Budget__c, Year__c, Month__c, Amount__c 
						FROM Budget_Line__c 
						WHERE Budget__c != null AND Budget__c = :idBudget];
    
        //Test method stop here
        Test.stopTest();
        
        //Validate the results
        System.assert(resultBudget != null);
        system.assert(resultBudget.size() == 1);
        system.assertEquals('Test Department',resultBudget[0].Department_Name__c);
        System.assert(resultBLI != null);
        system.assert(resultBLI.size() == 24);
    }
    
	//Modified by - Abhinav Sharma - 07/20/2016 - CR-20150202-8637 - A code refactor CR
    /** Description : Method to test out that 
     *					a) "Department_Name__c" field value is populated as expected on "budget" record.
     *					b) Busget line records were created in expected manner or not
     *					whenever a DML statement will happen on the integration record(s) for "CapEx" type.
    **/
    static testmethod void testIntegrationBudget_CapEx() {
    	
    	//Bypass Dupeblocker and disbaling triggers for test data creation purpose
        Util.IsTest(true);
        Util.isTesting = true;
        Util.byPassAllTriggers = true;
       
        //Set up the test
        //Set up the Custom Setting for the Integration Job
        list<RecordType> intRecType = [SELECT Id, DeveloperName 
        								FROM RecordType 
        								WHERE SobjectType = 'Integration__c' 
        								AND IsActive = true
        								LIMIT 1];
        								
		//Asserting for the results
        System.assert(intRecType != null);							   
        System.assert(intRecType.size() > 0);	
        
        //Create integration job record
        Integration_Job__c intjob = new Integration_Job__c();
        intjob.Name = intRecType[0].Id;
        intjob.Integration_Job_Name__c = intRecType[0].DeveloperName;
        insert intjob;
        
        //Set up the Custom Setting for the Recordtype Settings
        list<RecordType_Setting__c> listRTSetting = new list<RecordType_Setting__c>();
        
        //Query over Budget records type
        for(RecordType rtBudget : ([SELECT Id, DeveloperName 
        								FROM RecordType 
        								WHERE SObjectType = 'Budget__c'
        								AND IsActive = true
        ])){
        	
        	RecordType_Setting__c rts = new RecordType_Setting__c();
        	rts.SObjectType__c = 'Budget__c';
        	rts.Name__c = rtBudget.DeveloperName;
        	rts.SFID__c = rtBudget.Id;
        	rts.Name = rtBudget.Id;
        	listRTSetting.add(rts);
        }
        
        //Insert record
        insert listRTSetting;
        
        //Asserting for the results
        System.assert(listRTSetting != null);							   
        System.assert(listRTSetting.size() > 0);
       
        //Set up a Department
        Department__c dept = new Department__c();
        dept.Department_Number__c = '12345';
        dept.Name = 'Test Department';
        insert dept;
        
        //set up the Mapping
        list<Integration_Mapping__c> listIM = new list<Integration_Mapping__c>();
        
        //IM Record 1a
        Integration_Mapping__c IM1a = new Integration_Mapping__c();
        IM1a.Integration_Name__c = intjob.Integration_Job_Name__c;
        IM1a.Stg_Field_Name__c = 'TextField01__c';
        IM1a.SF_Object_Name__c = 'Budget__c';
        IM1a.SF_Object_Field__c = 'Department_Code__c';
        listIM.add(IM1a);
        
		//IM Record 1b
        Integration_Mapping__c IM1b = new Integration_Mapping__c();
        IM1b.Integration_Name__c = intjob.Integration_Job_Name__c;
        IM1b.Stg_Field_Name__c = 'TextField02__c';
        IM1b.SF_Object_Name__c = 'Budget__c';
        IM1b.SF_Object_Field__c = 'Department_Name__c';
        listIM.add(IM1b);
        
        //IM Record 1c
        Integration_Mapping__c IM1c = new Integration_Mapping__c();
        IM1c.Integration_Name__c = intjob.Integration_Job_Name__c;
        IM1c.Stg_Field_Name__c = 'TextField03__c';
        IM1c.SF_Object_Name__c = 'Budget__c';
        IM1c.SF_Object_Field__c = 'Account_Number__c';
        listIM.add(IM1c);
        
        //IM Record 2
        Integration_Mapping__c IM2 = new Integration_Mapping__c();
        IM2.Integration_Name__c = intjob.Integration_Job_Name__c;
        IM2.Stg_Field_Name__c = 'TextField04__c';
        IM2.SF_Object_Name__c = 'Budget__c';
        IM2.SF_Object_Field__c = 'Account_Name__c';
        listIM.add(IM2);
        
        //IM Record 3
        Integration_Mapping__c IM3 = new Integration_Mapping__c();
        IM3.Integration_Name__c = intjob.Integration_Job_Name__c;
        IM3.Stg_Field_Name__c = 'TextField05__c';
        IM3.SF_Object_Name__c = 'Budget__c';
        IM3.SF_Object_Field__c = 'Description__c';
        listIM.add(IM3);
        
        //IM Record 4
        Integration_Mapping__c IM4 = new Integration_Mapping__c();
        IM4.Integration_Name__c = intjob.Integration_Job_Name__c;
        IM4.Stg_Field_Name__c = 'TextField06__c';
        IM4.SF_Object_Name__c = 'Budget__c';
        IM4.SF_Object_Field__c = 'Asset_Category__c';
        listIM.add(IM4);
        
        //IM Record 5
        Integration_Mapping__c IM5 = new Integration_Mapping__c();
        IM5.Integration_Name__c = intjob.Integration_Job_Name__c;
        IM5.Stg_Field_Name__c = 'TextField07__c';
        IM5.SF_Object_Name__c = 'Budget__c';
        IM5.SF_Object_Field__c = 'Fixed_Asset__c';
        listIM.add(IM5);
        
        //IM Record 6
        Integration_Mapping__c IM6 = new Integration_Mapping__c();
        IM6.Integration_Name__c = intjob.Integration_Job_Name__c;
        IM6.Stg_Field_Name__c = 'TextField08__c';
        IM6.SF_Object_Name__c = 'Budget_Line__c';
        IM6.SF_Object_Field__c = 'Month__c';
        listIM.add(IM6);
        
        //IM Record 7
        Integration_Mapping__c IM7 = new Integration_Mapping__c();
        IM7.Integration_Name__c = intjob.Integration_Job_Name__c;
        IM7.Stg_Field_Name__c = 'Number01__c';
        IM7.SF_Object_Name__c = 'Budget_Line__c';
        IM7.SF_Object_Field__c = 'Amount__c';
        listIM.add(IM7);
        
        //IM Record 8
        Integration_Mapping__c IM8 = new Integration_Mapping__c();
        IM8.Integration_Name__c = intjob.Integration_Job_Name__c;
        IM8.Stg_Field_Name__c = 'TextField09__c';
        IM8.SF_Object_Name__c = 'Budget_Line__c';
        IM8.SF_Object_Field__c = 'Year__c';
        listIM.add(IM8);
        
        //IM Record 9
        Integration_Mapping__c IM9 = new Integration_Mapping__c();
        IM9.Integration_Name__c = intjob.Integration_Job_Name__c;
        IM9.Stg_Field_Name__c = 'TextField22__c';
        IM9.SF_Object_Name__c = 'Budget__c';
        IM9.SF_Object_Field__c = 'Budget_Item__c';
        listIM.add(IM9);
        
        //IM Record 10
        Integration_Mapping__c IM10 = new Integration_Mapping__c();
        IM10.Integration_Name__c = intjob.Integration_Job_Name__c;
        IM10.Stg_Field_Name__c = 'TextField23__c';
        IM10.SF_Object_Name__c = 'Budget__c';
        IM10.SF_Object_Field__c = 'Unique_Id__c';
        listIM.add(IM10);
        
        //IM Record 11
        Integration_Mapping__c IM11 = new Integration_Mapping__c();
        IM11.Integration_Name__c = intjob.Integration_Job_Name__c;
        IM11.Stg_Field_Name__c = 'TextField24__c';
        IM11.SF_Object_Name__c = 'Budget__c';
        IM11.SF_Object_Field__c = 'BudgetType';
        listIM.add(IM11);        
        
        //insert Integration Mapping records
        insert listIM;
        
        //Asserting for the results
        System.assert(listIM != null);							   
        System.assert(listIM.size() > 0);
        
        //Add the Integration records
        list<Integration__c> intgs = new list<Integration__c>();
        
        //Create integration record
        Integration__c intg1 = new Integration__c();
        intg1.External_Id__c = '2';
        intg1.External_system__c = 'test';
        intg1.Number01__c    = 4995;
        intg1.TextField01__c = '12345';
        intg1.TextField02__c = 'Test Department';
        intg1.TextField03__c = '98765';
        intg1.TextField04__c = 'Software';
        intg1.TextField05__c = 'Software Purchase';
        intg1.TextField06__c = 'Business Tools';
        intg1.TextField07__c = 'Microsoft PowerPoint';
        intg1.TextField08__c = 'Mar';
        intg1.TextField09__c = '2013';
        intg1.TextField10__c = '';
        intg1.TextField11__c = '';
        intg1.TextField12__c = '';
        intg1.TextField13__c = '';
        intg1.TextField14__c = '';
        intg1.TextField15__c = '';
        intg1.TextField16__c = '';
        intg1.TextField17__c = '';
        intg1.TextField18__c = '';
        intg1.TextField19__c = '';
        intg1.TextField20__c = '';
        intg1.TextField21__c = '';
        intg1.TextField22__c = 'Microsoft PowerPoint';
        intg1.TextField23__c = '12345'+'--'+'98765'+'--'+'Software Maintenance';
        intg1.TextField24__c = 'CapEx';
        intg1.RecordTypeId = intJob.Name;
        intg1.Operation__c = 'Insert';
        intg1.SFDC_Object__c = 'Budget__c';
        
        //Added recrord in list
        intgs.add(intg1);
        
        //Create interation record
        Integration__c intg2 = new Integration__c();
        intg2.External_Id__c = '2';
        intg2.External_system__c = 'test';
        intg2.Number01__c    = 5149;
        intg2.TextField01__c = '12345';
        intg2.TextField02__c = 'Test Department';
        intg2.TextField03__c = '98765';
        intg2.TextField04__c = 'Software';
        intg2.TextField05__c = 'Software Purchase';
        intg2.TextField06__c = 'Business Tools';
        intg2.TextField07__c = 'Microsoft PowerPoint';
        intg2.TextField08__c = 'Jun';
        intg2.TextField09__c = '2013';
        intg2.TextField10__c = '';
        intg2.TextField11__c = '';
        intg2.TextField12__c = '';
        intg2.TextField13__c = '';
        intg2.TextField14__c = '';
        intg2.TextField15__c = '';
        intg2.TextField16__c = '';
        intg2.TextField17__c = '';
        intg2.TextField18__c = '';
        intg2.TextField19__c = '';
        intg2.TextField20__c = '';
        intg2.TextField21__c = '';
        intg2.TextField22__c = 'Microsoft PowerPoint';
        intg2.TextField23__c = '12345'+'--'+'98765'+'--'+'Software Maintenance';
        intg2.TextField24__c = 'CapEx';
        intg2.RecordTypeId = intJob.Name;
        intg2.Operation__c = 'Insert';
        intg2.SFDC_Object__c = 'Budget__c';
        
        //Added recrord in list
        intgs.add(intg2);
        
        //Define properties
        list<Integration__c> intResult = new list<Integration__c>();
        list<Budget__c> resultBudget = new list<Budget__c>();
        list<Budget_Line__c> resultBLI = new list<Budget_Line__c>();
        string uId = intg2.TextField23__c;
        
        //Run the test
        Test.startTest();
        
    	//Enabling trigger
    	Util.byPassAllTriggers = false;
        
        //Insert integartion records	
    	insert intgs;
    	
    	//Asserting for the results
        System.assert(intgs != null);							   
        System.assert(intgs.size() > 0);
        
        //Querying for the integration records details
    	intResult = [SELECT Id, Status__c 
    					FROM Integration__c 
    					WHERE TextField23__c != null AND TextField23__c = :uId];
    					
		//Asserting for the results
        System.assert(intResult != null);							   
        System.assert(intResult.size() > 0);
    					
    	//Querying for the budget records details				
    	resultBudget = [SELECT Id, Account_Name__c, Budget_Item__c, Department_Name__c 
    					FROM Budget__c 
    					WHERE Unique_Id__c != null AND Unique_Id__c = :uId];
    					
    	//Asserting for the results
        System.assert(resultBudget != null);							   
        System.assert(resultBudget.size() > 0);					
    	
    	//Budget ID				
    	Id idBudget = resultBudget[0].Id;
    	
    	//Querying for the budget line records details
    	resultBLI = [SELECT Id, Budget__c, Year__c, Month__c, Amount__c 
						FROM Budget_Line__c 
						WHERE Budget__c != null AND Budget__c = :idBudget];
    	
        //Test method stop here
        test.stopTest();
        
        //Validate the results
        System.assert(resultBudget != null);
        system.assert(resultBudget.size() == 1);
        system.assertEquals('Test Department',resultBudget[0].Department_Name__c);
        System.assert(resultBLI != null);
        system.assert(resultBLI.size() == 2);
    }
	
	//Added by - Abhinav Sharma - 07/20/2016 - CR-20150202-8637 - A code refactor CR
    /** Description : Method to test out that the functionality associated with the Util type of methods. 
     *					Those current exists in "IntegrationTriggerUtil" class.
     *	
    **/
	static testMethod void testUtilUseCases() {
		
		//Bypass Dupeblocker and disbaling triggers for test data creation purpose
        Util.IsTest(true);
        Util.isTesting = true;
        Util.byPassAllTriggers = true;
    	
    	//set up the Mapping
        list<Integration_Mapping__c> listIM = new list<Integration_Mapping__c>();
        
        //Budget fields
        string obj = 'Budget__c';
        
        //Create Integration Map record
        Integration_Mapping__c IM01 = new Integration_Mapping__c(Integration_Name__c = 'IM 1',Stg_Field_Name__c = 'TextField01__c',SF_Object_Name__c = obj,SF_Object_Field__c = 'Department_Code__c');
        listIM.add(IM01);
        
        //Insert
        insert listIM;
        
        //Create instance
        IntegrationTriggerUtil controller = new IntegrationTriggerUtil();
        
        //Call method
        IntegrationTriggerUtil.buildReverseLookupFieldMap(listIM, obj);
        
        //Create map of string
        Map<String, String> mapObjectToMapping = new Map<String, String>();
        
        //Put value in map
        mapObjectToMapping.put('ABC', 'ABC');
        mapObjectToMapping.put('ABC2', 'ABC2');
        
        //Define properties to hold object field
        String objectField = 'ABC';
        
        //Call method
        IntegrationTriggerUtil.getFieldName(mapObjectToMapping, objectField);
        
        //Query over Integration recordtype
        list<RecordType> intRecType = [select Id, DeveloperName from RecordType where SobjectType = 'Integration__c' LIMIT 1];
        
        //Create Integration Job record
        Integration_Job__c intjob = new Integration_Job__c();
        intjob.Name = intRecType[0].Id;
        intjob.Integration_Job_Name__c = intRecType[0].DeveloperName;
        
        //Insert Integration record
        insert intjob;
        
        //Created Integration records
        Integration__c intg = new Integration__c();
        intg.External_Id__c = '2';
        intg.External_system__c = 'test';
        intg.Number01__c    = 1234;
        intg.TextField01__c = '12345';
        intg.TextField02__c = 'Test Department';
        intg.TextField03__c = '98765';
        intg.TextField04__c = 'Software';
        intg.TextField05__c = 'Software Maintenance';
        intg.TextField06__c = '';
        intg.TextField07__c = '';
        intg.TextField08__c = '';
        intg.TextField09__c = '2013';
        intg.TextField10__c = '100';
        intg.TextField11__c = '100';
        intg.TextField12__c = '100';
        intg.TextField13__c = '100';
        intg.TextField14__c = '100';
        intg.TextField15__c = '100';
        intg.TextField16__c = '100';
        intg.TextField17__c = '100';
        intg.TextField18__c = '100';
        intg.TextField19__c = '100';
        intg.TextField20__c = '100';
        intg.TextField21__c = '100';
        intg.TextField22__c = 'Microsoft PowerPoint';
        intg.TextField23__c = '12345'+'--'+'98765'+'--'+'Software Maintenance';
        intg.TextField24__c = 'OpEx';
        intg.RecordTypeId = intJob.Name;
        intg.Operation__c = 'Insert';
        intg.SFDC_Object__c = 'Budget__c';
        intg.isSuccess__c = true;
        
        //Insert record
        insert intg;
        
        //Add the Integration records
        list<Integration__c> intgs = new list<Integration__c>();
        
        //Creare Integration record
        Integration__c intg1 = new Integration__c();
        intg1.External_Id__c = '2';
        intg1.External_system__c = 'test';
        intg1.Number01__c    = 123;
        intg1.TextField01__c = '12345';
        intg1.TextField02__c = 'Test Department';
        intg1.TextField03__c = '98765';
        intg1.TextField04__c = 'Software';
        intg1.TextField05__c = 'Software Maintenance';
        intg1.TextField06__c = '';
        intg1.TextField07__c = '';
        intg1.TextField08__c = '';
        intg1.TextField09__c = '2013';
        intg1.TextField10__c = '100';
        intg1.TextField11__c = '100';
        intg1.TextField12__c = '100';
        intg1.TextField13__c = '100';
        intg1.TextField14__c = '100';
        intg1.TextField15__c = '100';
        intg1.TextField16__c = '100';
        intg1.TextField17__c = '100';
        intg1.TextField18__c = '100';
        intg1.TextField19__c = '100';
        intg1.TextField20__c = '100';
        intg1.TextField21__c = '100';
        intg1.TextField22__c = 'Microsoft PowerPoint';
        intg1.TextField23__c = '12345'+'--'+'98765'+'--'+'Software Maintenance';
        intg1.TextField24__c = 'OpEx';
        intg1.RecordTypeId = intJob.Name;
        intg1.Operation__c = 'Insert';
        intg1.SFDC_Object__c = 'Budget__c';
        intg1.isSuccess__c = true;
        
        //Added record in list
        intgs.add(intg1);
        
        //Create Integration records
        Integration__c intg2 = new Integration__c();
        
        //Added record in list
        intgs.add(intg2);
        
        //Budget
        Budget__c bdg = new Budget__c(Account_Name__c = 'Test', Budget_Item__c = 'Test', Unique_Id__c = intg1.TextField23__c);
        insert bdg;
        
        //budget Line
        List<Budget_Line__c> bdgList = new List<Budget_Line__c>();
        Budget_Line__c bdgL = new Budget_Line__c(Year__c = '2016', Month__c = 'Jan', Amount__c = 2222, Budget__c = bdg.ID);
        bdgList.add(bdgL);
        insert bdgList;
        
        //Calling helper class method
        IntegrationTriggerHelper.findBudgetLine(bdgList, '2016', 'Jan', 2000, bdg.Id);
        
        //Tedst method start here
        Test.startTest();
        
        //Enabling trigger
        Util.byPassAllTriggers = false;
        
        //Insert Records
        Database.SaveResult[] results = Database.Insert(intgs,false);
        
        //Create map to hold Integration records ID 
        Map<integer,Id> mapResultRecToIntgId = new Map<integer,Id>();
        
        //Added Integration record in with integer value
        mapResultRecToIntgId.put(0, intg.Id);
        mapResultRecToIntgId.put(1, intg.Id);
        
        //Map to hold Integration record with Id
        Map<Id,Integration__c> mapIntegration =new Map<Id,Integration__c>();
        mapIntegration.put(intg.Id, intg);
        
        //Lit to hold Sobject Records
        List<SObject> updatedRecs = new List<SObject>();
        
        //Added record in list
        updatedRecs.add(intg1);
        updatedRecs.add(intg2);
        
        //Call method
        IntegrationTriggerUtil.updateSaveResults('Insert', results, updatedRecs, mapResultRecToIntgId, mapIntegration);
        
        //Upsert integration records
        Database.UpsertResult[]  results2 = Database.Upsert(intgs);
        
        //Call method to upsert records
        IntegrationTriggerUtil.updateSaveResults('Upsert', results2, updatedRecs, mapResultRecToIntgId, mapIntegration);
        
        //Setting null as a value for the string variable
        string src = null;
       
        //Call mehtod
        IntegrationTriggerUtil.getDecimalValue(src);
        
        //Test method stop here
        Test.stopTest();
    }
}