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
private class Test_Trigger_GoalTypeBusinessTitle {
/**
  *   Purpose         :   Test class for Trigger_GoalTypeBusinessTitle
  *            
  *   Create By       :   Subhash Garhwal
  *
  *   Created Date    :   09/09/2015
  *
  *   Revision Log    :	  V_1.0 - Created - CR-20150729-9114
  *						
  *	  Coverage		  :	  100%
  *
  **/
	
	//Test Method for validateGTBTs() 
	static testMethod void myUnitTest() {
        
        //Create Goal Type
		List<Goal_Type__c> goalTypes = new List<Goal_Type__c>();
		
		//Add new goal type in list
		goalTypes.add(new Goal_Type__c(Name = 'TestGoalType1', Active__c = true, Base_Process__c = 'NBB', Description__c = 'Testing of Goal Type'));
		goalTypes.add(new Goal_Type__c(Name = 'TestGoalType2', Active__c = true, Base_Process__c = 'CM', Description__c = 'Testing of Goal Types'));
		goalTypes.add(new Goal_Type__c(Name = 'TestGoalType3', Active__c = false, Base_Process__c = 'Activity', Description__c = 'Testing of Goal'));
		goalTypes.add(new Goal_Type__c(Name = 'TestGoalType4', Active__c = false, Base_Process__c = 'Renewal', Description__c = 'Goal Type'));
		
		//Insert 
		insert goalTypes;
		
		//Create Value Type
		List<Value_Type__c> valueTypes = new List<Value_Type__c>();
		
		//Add Value Type in List
		valueTypes.add(new Value_Type__c(Name = 'Title', Values_Permitted__c = 'Date',Category__c = 'Business Title', Active__c = true, 
										 Rule__c = 'Staff member may have unlimited, overlapping records for this attribute' ));
		valueTypes.add(new Value_Type__c(Name = 'Title', Values_Permitted__c = 'Text', Category__c = 'Business Title', Active__c = true));
		valueTypes.add(new Value_Type__c(Name = 'Sales Role', Values_Permitted__c = 'Text', Category__c = 'Business Title',  Active__c = true));
		valueTypes.add(new Value_Type__c(Name = 'Tenure', Values_Permitted__c = 'Text', Category__c = 'Business Title',  Active__c = true));
		valueTypes.add(new Value_Type__c(Name = 'Tenure', Values_Permitted__c = 'Text', Category__c = 'Goals'));
		valueTypes.add(new Value_Type__c(Values_Permitted__c = 'Text',Category__c = 'Business Title', Active__c = true, 
										 Rule__c = 'Staff member may have unlimited, overlapping records for this attribute' ));
		valueTypes.add(new Value_Type__c(Name = 'Tenure', Values_Permitted__c = 'Text', Category__c = 'Business Title', Active__c = true, 
										 Rule__c = 'Staff member may have unlimited, overlapping records for this attribute' ));
		
		//Insert
		insert valueTypes;
		
		//Create Goal Type Business Title
		List<Goal_Type_Business_Title__c> gTBTs = new List<Goal_Type_Business_Title__c>();
		
		//Add Goal Type Business Title in list
		gTBTs.add(new Goal_Type_Business_Title__c(Name = 'Test', Business_Title__c = valueTypes[0].Id, Goal_Type__c = goalTypes[0].Id));
		gTBTs.add(new Goal_Type_Business_Title__c(Name = 'Test', Business_Title__c = valueTypes[0].Id, Goal_Type__c = goalTypes[0].Id));
		gTBTs.add(new Goal_Type_Business_Title__c(Name = 'Test', Business_Title__c = valueTypes[1].Id, Goal_Type__c = goalTypes[0].Id));
		
		//Start Testing from here
		Test.startTest();
		
		//Try to insert record that will throw an exception that will cover in catch part
		try {    
			
			//Insert
			insert gTBTs;
			
			//Assert for Result
			System.assert(false);
		}
		
		//Catch block to handle exception
		catch(Exception ex) {
		
			//Assert for Result
			System.assert(ex.getMessage().contains(Label.ERROR_UNIQUENESS_GTBT));
		}
		
		//Update value type
        gTBTs[1].Business_Title__c = valueTypes[1].Id;
        
        //Try to insert record that will throw an exception that will cover in catch part
		try {    
			
			//Insert
			insert gTBTs;
			
			//Assert for Result
			System.assert(false);
		}
		
		//Catch block to handle exception
		catch(Exception ex) {
		
			//Assert for Result
			System.assert(ex.getMessage().contains(Label.ERROR_UNIQUENESS_GTBT));
		}
		
        //Update value type
        gTBTs[1].Business_Title__c = valueTypes[2].Id;
        
        //Insert
		insert gTBTs;
		
		//Query through Goal Type Business Title
		List<Goal_Type_Business_Title__c> gTBTsFetch = [Select Id from Goal_Type_Business_Title__c where Id IN : gTBTs];
		
		//Assert for results
		System.assertEquals(3, gTBTsFetch.size());
		
		//Create Goal Type Business Title
		List<Goal_Type_Business_Title__c> gTBTnew = new List<Goal_Type_Business_Title__c>();
		
		gTBTnew.add(new Goal_Type_Business_Title__c(Name = 'Test', Business_Title__c = valueTypes[0].Id, Goal_Type__c = goalTypes[0].Id));
		
		//Try to insert record that will throw an exception that will cover in catch part
		try {    
			
			//Insert
			insert gTBTnew;
			
			//Assert for Result
			System.assert(false);
		}
		
		//Catch block to handle exception
		catch(Exception ex) {
		
			//Assert for Result
			System.assert(ex.getMessage().contains(Label.ERROR_UNIQUENESS_GTBT));
		}
			
		//Stop Test here
		Test.stopTest();
		
	}
}