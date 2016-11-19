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
private class Test_Trigger_StandardGoal {
  /**
    *   Purpose         :   Test class for Trigger_StandardGoal
    *            
    *   Create By       :   Padmesh Soni
    *
    *   Created Date    :   08/11/2015
    *
    *   Revision Log    :	V_1.0 - Created -  CR-20150729-9114
    * 
    *	Coverage		:	V_1.0 - 100%
    **/
  
	//Test method for uncheckActiveFields method 
    static testMethod void myUnitTest() {
        
		//Create an institution
		Account account = TestUtilities.CreateNewAccount(false);
		
		//Insert
		insert account;
		
		//Create a Contact
		Contact contact = new Contact(FirstName = 'Test', LastName = 'Contact', Email = 'test@test.com', AccountId = account.Id, 
									  Employee_User_Record__c = Userinfo.getUserId());
		
		//Insert
		insert contact;
		
		//Create Goal Types
		List<Goal_Type__c> goalTypes = new List<Goal_Type__c>();
		
		//Add new goal type in list
		goalTypes.add(new Goal_Type__c(Name = 'TestGoalType1', Active__c = true, Standard_Goal__c = true, Base_Process__c = 'NBB', Description__c = 'Testing of Goal Type'));
		goalTypes.add(new Goal_Type__c(Name = 'TestGoalType2', Active__c = true, Standard_Goal__c = true, Base_Process__c = 'CM', Description__c = 'Testing of Goal Types'));
		goalTypes.add(new Goal_Type__c(Name = 'TestGoalType3', Active__c = false, Standard_Goal__c = true, Base_Process__c = 'Activity', Description__c = 'Testing of Goal'));
		goalTypes.add(new Goal_Type__c(Name = 'TestGoalType4', Active__c = false, Standard_Goal__c = true, Base_Process__c = 'Renewal', Description__c = 'Goal Type'));
		
		//Insert 
		insert goalTypes;

        //Create Standard Goals
		List<Standard_Goal__c> standardGoals = new List<Standard_Goal__c>();
		
		//Add new Standard Goals in list
		standardGoals.add(new Standard_Goal__c(Name = 'StandardGoal1', Active__c = true, Amount__c = 100, Business_Owner__c = contact.Id,
											   Description__c = 'Testing of Standard Goal', Goal_Type__c = goalTypes[0].Id, 
											   Period_Start__c = System.today(), Period_End__c = System.today().addDays(4)));
		standardGoals.add(new Standard_Goal__c(Name = 'StandardGoal2', Active__c = true, Amount__c = 200, Business_Owner__c = contact.Id,
											   Description__c = 'Testing of Standard Goal', Goal_Type__c = goalTypes[1].Id,
											   Period_Start__c = System.today().addDays(10), Period_End__c = System.today().addDays(20)));
		standardGoals.add(new Standard_Goal__c(Name = 'StandardGoal3', Active__c = false, Amount__c = 300, Business_Owner__c = contact.Id,
											   Description__c = 'Testing of Standard Goal', Goal_Type__c = goalTypes[1].Id, 
											   Period_Start__c = System.today().addDays(25), Period_End__c = System.today().addDays(30)));
		//Insert 
		insert standardGoals;
							   
	    //Create Standard Goal Details
		List<Standard_Goal_Detail__c> standardGoalDetails = new List<Standard_Goal_Detail__c>();
		
		//Add new Standard Goal Details in list
		standardGoalDetails.add(new Standard_Goal_Detail__c(Name = 'StandardGoalDetail1', Active__c = true, Description__c = 'Testing',
														    Standard_Goal__c = standardGoals[0].Id));
		standardGoalDetails.add(new Standard_Goal_Detail__c(Name = 'StandardGoalDetail2', Active__c = true, Description__c = 'Testing',
														    Standard_Goal__c = standardGoals[0].Id));
		standardGoalDetails.add(new Standard_Goal_Detail__c(Name = 'StandardGoalDetail3', Active__c = true, Description__c = 'Testing',
														    Standard_Goal__c = standardGoals[1].Id));
		standardGoalDetails.add(new Standard_Goal_Detail__c(Name = 'StandardGoalDetail4', Active__c = true, Description__c = 'Testing',
														    Standard_Goal__c = standardGoals[1].Id));
		standardGoalDetails.add(new Standard_Goal_Detail__c(Name = 'StandardGoalDetail5', Active__c = true, Description__c = 'Testing',
														    Standard_Goal__c = standardGoals[2].Id));
		
		//Insert 
		insert standardGoalDetails;
														    
		//Start testing from here
		Test.startTest();
		
		//Change the Active Field value to false
		standardGoals[0].Active__c = false;
		standardGoals[1].Active__c = false;
		
		//Update Standard Goal 
		update standardGoals;
		
		//Query Through Standard Goal Details
		List<Standard_Goal_Detail__c> sGD = [Select Id, Name, Active__c From Standard_Goal_Detail__c];
		
		//Assert for results
		System.assertEquals(false, sGD[0].Active__c);        
		System.assertEquals(false, sGD[1].Active__c);        
		System.assertEquals(false, sGD[2].Active__c);        
		
		//Stop Testing here
		Test.stopTest();
	}
}