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
@isTest(seeAlldata = false)
private class Test_Trigger_JobTitle {
 /**
	*   Purpose         :   Test class for Trigger_JobTitle
    *            
    *   Create By       :   Subhash Garhwal
    *
    *   Created Date    :   09/14/2015
    *
    *   Revision Log    :	V_1.0 - Created - CR-20150825-9182
    * 
    *	Coverage		:	V_1.0 - 
    **/
    static testMethod void testValidateJobTitle(){
        
        //List of Value Type
		List<Value_Type__c> valueTypes = new List<Value_Type__c>();
		
		valueTypes.add(new Value_Type__c(Values_Permitted__c = 'Date',Category__c = 'Business Title'));
		valueTypes.add(new Value_Type__c(Values_Permitted__c = 'Text', Category__c = 'Business Title'));
		
		//Insert
		insert valueTypes;
		
		//List of Job Title
		List<Job_Title__c> jobTitles = new List<Job_Title__c>();
		
		//Add record in list
		jobTitles.add(new Job_Title__c(Name = 'Test 1', Business_Title__c = valueTypes[0].Id));
		jobTitles.add(new Job_Title__c(Name = 'Test 2', Business_Title__c = valueTypes[0].Id));
		jobTitles.add(new Job_Title__c(Name = 'Test 3', Business_Title__c = valueTypes[1].Id));
		jobTitles.add(new Job_Title__c(Name = 'Test 1', Business_Title__c = valueTypes[1].Id));
		
		//Method Start Here
		Test.startTest();
		
		try{
			
			//Insert
			insert jobTitles;
		
		}catch(Exception ex){
			
			//Assert for Result
	    	System.assert(ex.getMessage().contains(Label.DUPLICATE_JOB_TITLE));
		
		}
		
		//Change Record data
		jobTitles[3].Name = 'Test 4';
		
		//Insert
		insert jobTitles;
		
		//Assert For Result
		system.assertEquals(4,jobTitles.size());
		
		//Update Record
		jobTitles[0].Business_Title__c = valueTypes[1].Id;
		jobTitles[3].Business_Title__c = valueTypes[0].Id;
		
		//Assert For Result
		system.assertEquals(4,jobTitles.size());
		
		//Update
		update jobTitles;
			
		//Update Record
		jobTitles[0].Name = 'Test 3';
		
		try{
			
			//Update
			update jobTitles;
		
		}catch(Exception ex){
			
			//Assert for Result
	    	System.assert(ex.getMessage().contains(Label.DUPLICATE_JOB_TITLE));
		
		}
		
		//Method Stop Here
		Test.stopTest();
    }
}