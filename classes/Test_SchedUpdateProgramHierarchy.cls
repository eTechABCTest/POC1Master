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
private class Test_SchedUpdateProgramHierarchy {

    //Setup test data first. This will be available in the entire class
	@testSetup static void setup() {
	
		// Create common Team Role
		Program__c program = new Program__c(Name = 'Test', Account_Management_Reporting_Business__c = 'PT', 
												Account_Management_Reporting_Vertical__c = 'Population Health',
												Account_Management_Reporting_Group__c = 'CCM', 
												Program_Acronym__c = 'BICM', 
												New_Business_Business__c = 'PT', 
												New_Business_Vertical__c = 'Crimson',
												New_Business_Group__c = 'CCM');
		insert program;
	}
	
	//Test Account Team Replication
	//When a new Team Member is added
	static testMethod void testUpdateProgramHierarchyWithAllNew() {
		
		//Query Program records
		Program__c program = [Select Id, Account_Management_Reporting_Business__c, Account_Management_Reporting_Vertical__c, 
									Account_Management_Reporting_Group__c, New_Business_Business__c, New_Business_Vertical__c, New_Business_Group__c,
									Program_Acronym__c from Program__c];
		
		//Start Test from here
		Test.startTest();
		
		//Call the method to create the PH records
		Sched_UpdateProgramHierarchy.updateProgramHierarchy();
		
		//Assert for the results
		List<Program_Hierarchy__c> pHs = [Select Id, Hierarchy_Unique_ID__c, Unique_ID__c, Division__c, Business__c, 
											Vertical__c, Group__c, Acronym__c, Start_date__c, End_date__c from Program_Hierarchy__c 
											where End_date__c = null AND Hierarchy_Unique_ID__c !=  null order by Hierarchy_Unique_ID__c] ;
		System.assertEquals(10, pHs.size());
		String uniqueKey = 'AM';
		
		System.assertEquals(uniqueKey, pHs[0].Hierarchy_Unique_ID__c);
		System.assertEquals(uniqueKey, pHs[0].Unique_ID__c);
		System.assertEquals('AM', pHs[0].Division__c);
		System.assertEquals(null, pHs[0].Business__c);
		System.assertEquals(null, pHs[0].Vertical__c);
		System.assertEquals(null, pHs[0].Acronym__c);
		System.assertEquals(Date.today(), pHs[0].Start_date__c);
		System.assertEquals(null, pHs[0].End_date__c);
		
		//Append unique key
		uniqueKey += '-' + program.Account_Management_Reporting_Business__c;
		
		System.assertEquals(uniqueKey, pHs[1].Hierarchy_Unique_ID__c);
		System.assertEquals(uniqueKey, pHs[1].Unique_ID__c);
		System.assertEquals('AM', pHs[1].Division__c);
		System.assertEquals(program.Account_Management_Reporting_Business__c, pHs[1].Business__c);
		System.assertEquals(null, pHs[1].Vertical__c);
		System.assertEquals(null, pHs[1].Acronym__c);
		System.assertEquals(Date.today(), pHs[1].Start_date__c);
		System.assertEquals(null, pHs[1].End_date__c);
		
		//Append unique key
		uniqueKey += '-' + program.Account_Management_Reporting_Vertical__c;
		
		System.assertEquals(uniqueKey, pHs[2].Hierarchy_Unique_ID__c);
		System.assertEquals(uniqueKey, pHs[2].Unique_ID__c);
		System.assertEquals('AM', pHs[2].Division__c);
		System.assertEquals(program.Account_Management_Reporting_Business__c, pHs[2].Business__c);
		System.assertEquals(program.Account_Management_Reporting_Vertical__c, pHs[2].Vertical__c);
		System.assertEquals(null, pHs[2].Acronym__c);
		System.assertEquals(Date.today(), pHs[2].Start_date__c);
		System.assertEquals(null, pHs[2].End_date__c);
		
		//Append unique key
		uniqueKey += '-' + program.Account_Management_Reporting_Group__c;
		
		System.assertEquals(uniqueKey, pHs[3].Hierarchy_Unique_ID__c);
		System.assertEquals(uniqueKey, pHs[3].Unique_ID__c);
		System.assertEquals('AM', pHs[3].Division__c);
		System.assertEquals(program.Account_Management_Reporting_Business__c, pHs[3].Business__c);
		System.assertEquals(program.Account_Management_Reporting_Vertical__c, pHs[3].Vertical__c);
		System.assertEquals(program.Account_Management_Reporting_Group__c, pHs[3].Group__c);
		System.assertEquals(null, pHs[3].Acronym__c);
		System.assertEquals(Date.today(), pHs[3].Start_date__c);
		System.assertEquals(null, pHs[3].End_date__c);
		
		//Append unique key
		uniqueKey += '-' + program.Program_Acronym__c;
		
		System.assertEquals(uniqueKey, pHs[4].Hierarchy_Unique_ID__c);
		System.assertEquals(uniqueKey, pHs[4].Unique_ID__c);
		System.assertEquals('AM', pHs[4].Division__c);
		System.assertEquals(program.Account_Management_Reporting_Business__c, pHs[4].Business__c);
		System.assertEquals(program.Account_Management_Reporting_Vertical__c, pHs[4].Vertical__c);
		System.assertEquals(program.Account_Management_Reporting_Group__c, pHs[4].Group__c);
		System.assertEquals(program.Program_Acronym__c, pHs[4].Acronym__c);
		System.assertEquals(Date.today(), pHs[4].Start_date__c);
		System.assertEquals(null, pHs[4].End_date__c);
		
		//NBB
		uniqueKey = 'NBB';
		
		System.assertEquals(uniqueKey, pHs[5].Hierarchy_Unique_ID__c);
		System.assertEquals(uniqueKey, pHs[5].Unique_ID__c);
		System.assertEquals('NBB', pHs[5].Division__c);
		System.assertEquals(null, pHs[5].Business__c);
		System.assertEquals(null, pHs[5].Vertical__c);
		System.assertEquals(null, pHs[5].Acronym__c);
		System.assertEquals(Date.today(), pHs[5].Start_date__c);
		System.assertEquals(null, pHs[5].End_date__c);
		
		//Append unique key
		uniqueKey += '-' + program.New_Business_Business__c;
		
		System.assertEquals(uniqueKey, pHs[6].Hierarchy_Unique_ID__c);
		System.assertEquals(uniqueKey, pHs[6].Unique_ID__c);
		System.assertEquals('NBB', pHs[6].Division__c);
		System.assertEquals(program.New_Business_Business__c, pHs[6].Business__c);
		System.assertEquals(null, pHs[6].Vertical__c);
		System.assertEquals(null, pHs[6].Acronym__c);
		System.assertEquals(Date.today(), pHs[6].Start_date__c);
		System.assertEquals(null, pHs[6].End_date__c);
		
		//Append unique key
		uniqueKey += '-' + program.New_Business_Vertical__c;
		
		System.assertEquals(uniqueKey, pHs[7].Hierarchy_Unique_ID__c);
		System.assertEquals(uniqueKey, pHs[7].Unique_ID__c);
		System.assertEquals('NBB', pHs[7].Division__c);
		System.assertEquals(program.New_Business_Business__c, pHs[7].Business__c);
		System.assertEquals(program.New_Business_Vertical__c, pHs[7].Vertical__c);
		System.assertEquals(null, pHs[7].Acronym__c);
		System.assertEquals(Date.today(), pHs[7].Start_date__c);
		System.assertEquals(null, pHs[7].End_date__c);
		
		//Append unique key
		uniqueKey += '-' + program.New_Business_Group__c;
		
		System.assertEquals(uniqueKey, pHs[8].Hierarchy_Unique_ID__c);
		System.assertEquals(uniqueKey, pHs[8].Unique_ID__c);
		System.assertEquals('NBB', pHs[8].Division__c);
		System.assertEquals(program.New_Business_Business__c, pHs[8].Business__c);
		System.assertEquals(program.New_Business_Vertical__c, pHs[8].Vertical__c);
		System.assertEquals(program.New_Business_Group__c, pHs[8].Group__c);
		System.assertEquals(null, pHs[8].Acronym__c);
		System.assertEquals(Date.today(), pHs[8].Start_date__c);
		System.assertEquals(null, pHs[8].End_date__c);
		
		//Append unique key
		uniqueKey += '-' + program.Program_Acronym__c;
		
		System.assertEquals(uniqueKey, pHs[9].Hierarchy_Unique_ID__c);
		System.assertEquals(uniqueKey, pHs[9].Unique_ID__c);
		System.assertEquals('NBB', pHs[9].Division__c);
		System.assertEquals(program.New_Business_Business__c, pHs[9].Business__c);
		System.assertEquals(program.New_Business_Vertical__c, pHs[9].Vertical__c);
		System.assertEquals(program.New_Business_Group__c, pHs[9].Group__c);
		System.assertEquals(program.Program_Acronym__c, pHs[9].Acronym__c);
		System.assertEquals(Date.today(), pHs[9].Start_date__c);
		System.assertEquals(null, pHs[9].End_date__c);
		
		for(Program_Hierarchy__c pH : pHs)
			pH.Start_date__c = Date.today() - 1;
		update pHs;
		
		//Update the Existing program records
		program.Account_Management_Reporting_Group__c = 'DCM';
		update program;
		
		//Call the method to create the PH records
		Sched_UpdateProgramHierarchy.updateProgramHierarchy();
		
		//Assert for the results
		pHs = [Select Id, Hierarchy_Unique_ID__c, Unique_ID__c, Division__c, Business__c, 
											Vertical__c, Group__c, Acronym__c, Start_date__c, End_date__c from Program_Hierarchy__c 
											where Hierarchy_Unique_ID__c !=  null order by Hierarchy_Unique_ID__c] ;
		System.assertEquals(12, pHs.size());
		uniqueKey = 'AM';
		
		System.assertEquals(uniqueKey, pHs[0].Hierarchy_Unique_ID__c);
		System.assertEquals(uniqueKey, pHs[0].Unique_ID__c);
		System.assertEquals('AM', pHs[0].Division__c);
		System.assertEquals(null, pHs[0].Business__c);
		System.assertEquals(null, pHs[0].Vertical__c);
		System.assertEquals(null, pHs[0].Acronym__c);
		System.assertEquals(Date.today()-1, pHs[0].Start_date__c);
		System.assertEquals(null, pHs[0].End_date__c);
		
		//Append unique key
		uniqueKey += '-' + program.Account_Management_Reporting_Business__c;
		
		System.assertEquals(uniqueKey, pHs[1].Hierarchy_Unique_ID__c);
		System.assertEquals(uniqueKey, pHs[1].Unique_ID__c);
		System.assertEquals('AM', pHs[1].Division__c);
		System.assertEquals(program.Account_Management_Reporting_Business__c, pHs[1].Business__c);
		System.assertEquals(null, pHs[1].Vertical__c);
		System.assertEquals(null, pHs[1].Acronym__c);
		System.assertEquals(Date.today()-1, pHs[1].Start_date__c);
		System.assertEquals(null, pHs[1].End_date__c);
		
		//Append unique key
		uniqueKey += '-' + program.Account_Management_Reporting_Vertical__c;
		
		System.assertEquals(uniqueKey, pHs[2].Hierarchy_Unique_ID__c);
		System.assertEquals(uniqueKey, pHs[2].Unique_ID__c);
		System.assertEquals('AM', pHs[2].Division__c);
		System.assertEquals(program.Account_Management_Reporting_Business__c, pHs[2].Business__c);
		System.assertEquals(program.Account_Management_Reporting_Vertical__c, pHs[2].Vertical__c);
		System.assertEquals(null, pHs[2].Acronym__c);
		System.assertEquals(Date.today()-1, pHs[2].Start_date__c);
		System.assertEquals(null, pHs[2].End_date__c);
		
		//Append unique key
		uniqueKey += '-CCM';
		
		System.assertEquals(uniqueKey, pHs[3].Hierarchy_Unique_ID__c);
		System.assertEquals(uniqueKey, pHs[3].Unique_ID__c);
		System.assertEquals('AM', pHs[3].Division__c);
		System.assertEquals(program.Account_Management_Reporting_Business__c, pHs[3].Business__c);
		System.assertEquals(program.Account_Management_Reporting_Vertical__c, pHs[3].Vertical__c);
		System.assertEquals('CCM', pHs[3].Group__c);
		System.assertEquals(null, pHs[3].Acronym__c);
		System.assertEquals(Date.today()-1, pHs[3].Start_date__c);
		System.assertEquals(Date.today(), pHs[3].End_date__c);
		
		//Append unique key
		uniqueKey += '-' + program.Program_Acronym__c;
		
		System.assertEquals(uniqueKey, pHs[4].Hierarchy_Unique_ID__c);
		System.assertEquals(uniqueKey, pHs[4].Unique_ID__c);
		System.assertEquals('AM', pHs[4].Division__c);
		System.assertEquals(program.Account_Management_Reporting_Business__c, pHs[4].Business__c);
		System.assertEquals(program.Account_Management_Reporting_Vertical__c, pHs[4].Vertical__c);
		System.assertEquals('CCM', pHs[4].Group__c);
		System.assertEquals(program.Program_Acronym__c, pHs[4].Acronym__c);
		System.assertEquals(Date.today()-1, pHs[4].Start_date__c);
		System.assertEquals(Date.today(), pHs[4].End_date__c);
		
		//Append unique key
		uniqueKey = uniqueKey.replaceAll('CCM', 'DCM').replaceAll('-BICM', '');
		
		System.assertEquals(uniqueKey, pHs[5].Hierarchy_Unique_ID__c);
		System.assertEquals(uniqueKey, pHs[5].Unique_ID__c);
		System.assertEquals('AM', pHs[5].Division__c);
		System.assertEquals(program.Account_Management_Reporting_Business__c, pHs[5].Business__c);
		System.assertEquals(program.Account_Management_Reporting_Vertical__c, pHs[5].Vertical__c);
		System.assertEquals(program.Account_Management_Reporting_Group__c, pHs[5].Group__c);
		System.assertEquals(null, pHs[5].Acronym__c);
		System.assertEquals(Date.today(), pHs[5].Start_date__c);
		System.assertEquals(null, pHs[5].End_date__c);
		
		//Append unique key
		uniqueKey += '-' + program.Program_Acronym__c;
		
		System.assertEquals(uniqueKey, pHs[6].Hierarchy_Unique_ID__c);
		System.assertEquals(uniqueKey, pHs[6].Unique_ID__c);
		System.assertEquals('AM', pHs[6].Division__c);
		System.assertEquals(program.Account_Management_Reporting_Business__c, pHs[6].Business__c);
		System.assertEquals(program.Account_Management_Reporting_Vertical__c, pHs[6].Vertical__c);
		System.assertEquals(program.Account_Management_Reporting_Group__c, pHs[6].Group__c);
		System.assertEquals(program.Program_Acronym__c, pHs[6].Acronym__c);
		System.assertEquals(Date.today(), pHs[6].Start_date__c);
		System.assertEquals(null, pHs[6].End_date__c);
		
		//Stop test here
		Test.stopTest();
	}
}