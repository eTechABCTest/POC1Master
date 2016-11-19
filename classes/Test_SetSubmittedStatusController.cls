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
private class Test_SetSubmittedStatusController {
	
 /**
 *   Purpose         :   Test class for SetSubmittedStatusController
 *            
 *   Create By       :   Subhash Garhwal
 *
 *   Created Date    :   01/12/2015
 *
 *   Revision Log    :   
 * 
 *   Coverage        :   
 **/
 	//Test Method
    static testMethod void myUnitTest() {
    	// TO DO: implement unit test
        
        /********************       Create test data         **********************/
        
        //Query through the Personal Goal's record type
        List<RecordType> rTypes = [Select Id, DeveloperName From RecordType Where SobjectType = 'Personal_Goal__c' ORDER BY DeveloperName ASC];
        
        //Assert
        System.assertEquals(2, rTypes.size());
        
        //List of Personal Goal
        List<Personal_Goal__c> personalGoals = new List<Personal_Goal__c>();
         
        //Add new Personal Goal in list to insert
        personalGoals.add(new Personal_Goal__c(Description__c = 'PG 1', RecordTypeId = rTypes[1].Id, Status__c = 'Available', Amount__c = 1000));
        personalGoals.add(new Personal_Goal__c(Description__c = 'PG 2', RecordTypeId = rTypes[1].Id, Status__c = 'Former', Amount__c = 2000));
        personalGoals.add(new Personal_Goal__c(Description__c = 'PG 3', RecordTypeId = rTypes[1].Id, Status__c = 'Test', Amount__c = 3000));
        personalGoals.add(new Personal_Goal__c(Description__c = 'PG 4', RecordTypeId = rTypes[0].Id, Status__c = 'Available', Amount__c = 4000));
        
        //Insert
        insert personalGoals;
        
        //Assert
        System.assert(personalGoals.size() > 0); 
        
        //Start testing from here
		Test.startTest();
		
		//Query through the Personal Goals
		List<Personal_Goal__c> pGoals = [Select Id, Status__c from Personal_Goal__c Where Id IN : personalGoals ORDER BY Amount__c ASC];
		
		//Asserts for result
		System.assertEquals(4, pGoals.size());
		System.assertEquals('Available', pGoals[0].Status__c);
		System.assertEquals('Former', pGoals[1].Status__c);
		System.assertEquals('Test', pGoals[2].Status__c);
		System.assertEquals('Available', pGoals[3].Status__c);
		
		//Standard controller		
		ApexPages.StandardController sc = new ApexPages.standardController(new Personal_Goal__c());
		
		//Instance of controller
		SetSubmittedStatusController controller = new SetSubmittedStatusController(sc);
		
		//Call method to set the status of submission Personal Goal
		controller.setSubmittedStatus();
		
		//Query through the Personal Goals
		pGoals = [Select Id, Status__c from Personal_Goal__c Where Id IN : personalGoals ORDER BY Amount__c ASC];
		
		//Asserts for result
		System.assertEquals(4, pGoals.size());
		System.assertEquals('Available', pGoals[0].Status__c);
		System.assertEquals('Former', pGoals[1].Status__c);
		System.assertEquals('Test', pGoals[2].Status__c);
		System.assertEquals('Available', pGoals[3].Status__c);
		
		//Standard controller		
		sc = new ApexPages.standardController(personalGoals[0]);
		
		//Instance of controller
		controller = new SetSubmittedStatusController(sc);
		
		//Call method to set the status of submission Personal Goal
		controller.setSubmittedStatus();
		
		//Query through the Personal Goals
		pGoals = [Select Id, Status__c from Personal_Goal__c Where Id IN : personalGoals ORDER BY Amount__c ASC];
		
		//Asserts for result
		System.assertEquals(4, pGoals.size());
		System.assertEquals(ISSPConstants.PERSONAL_GOAL_STATUS_SUBMITTED, pGoals[0].Status__c);
		System.assertEquals('Former', pGoals[1].Status__c);
		System.assertEquals('Test', pGoals[2].Status__c);
		System.assertEquals('Available', pGoals[3].Status__c);
		
		//Standard controller		
		sc = new ApexPages.standardController(personalGoals[2]);
		
		//Instance of controller
		controller = new SetSubmittedStatusController(sc);
		
		//Call method to set the status of submission Personal Goal
		controller.setSubmittedStatus();
		
		//Query through the Personal Goals
		pGoals = [Select Id, Status__c from Personal_Goal__c Where Id IN : personalGoals ORDER BY Amount__c ASC];
		
		//Asserts for result
		System.assertEquals(4, pGoals.size());
		System.assertEquals(ISSPConstants.PERSONAL_GOAL_STATUS_SUBMITTED, pGoals[0].Status__c);
		System.assertEquals('Former', pGoals[1].Status__c);
		System.assertEquals('Test', pGoals[2].Status__c);
		System.assertEquals('Available', pGoals[3].Status__c);
		
		//Standard controller		
		sc = new ApexPages.standardController(personalGoals[3]);
		
		//Instance of controller
		controller = new SetSubmittedStatusController(sc);
		
		//Call method to set the status of submission Personal Goal
		controller.setSubmittedStatus();
		
		//Query through the Personal Goals
		pGoals = [Select Id, Status__c from Personal_Goal__c Where Id IN : personalGoals ORDER BY Amount__c ASC];
		
		//Asserts for result
		System.assertEquals(4, pGoals.size());
		System.assertEquals(ISSPConstants.PERSONAL_GOAL_STATUS_SUBMITTED, pGoals[0].Status__c);
		System.assertEquals('Former', pGoals[1].Status__c);
		System.assertEquals('Test', pGoals[2].Status__c);
		System.assertEquals('Available', pGoals[3].Status__c);
		
		//Set the standard set controller
		ApexPages.StandardSetController ssc = new ApexPages.StandardSetController(personalGoals);
		
		controller  = new SetSubmittedStatusController(ssc);
		
		//Call method to set the status of submission Personal Goal
		controller.setSubmittedStatus();
		
		//Query through the Personal Goals
		pGoals = [Select Id, Status__c from Personal_Goal__c Where Id IN : personalGoals ORDER BY Amount__c ASC];
		
		//Asserts for result
		System.assertEquals(4, pGoals.size());
		System.assertEquals(ISSPConstants.PERSONAL_GOAL_STATUS_SUBMITTED, pGoals[0].Status__c);
		System.assertEquals('Former', pGoals[1].Status__c);
		System.assertEquals('Test', pGoals[2].Status__c);
		System.assertEquals('Available', pGoals[3].Status__c);
		
		//Set the standard set controller
		ssc = new ApexPages.StandardSetController(personalGoals);
		ssc.setSelected(personalGoals);
		
		controller  = new SetSubmittedStatusController(ssc);
		
		//Call method to set the status of submission Personal Goal
		controller.setSubmittedStatus();
		
		//Query through the Personal Goals
		pGoals = [Select Id, Status__c from Personal_Goal__c Where Id IN : personalGoals ORDER BY Amount__c ASC];
		
		//Asserts for result
		System.assertEquals(4, pGoals.size());
		System.assertEquals(ISSPConstants.PERSONAL_GOAL_STATUS_SUBMITTED, pGoals[0].Status__c);
		System.assertEquals(ISSPConstants.PERSONAL_GOAL_STATUS_SUBMITTED, pGoals[1].Status__c);
		System.assertEquals('Test', pGoals[2].Status__c);
		System.assertEquals('Available', pGoals[3].Status__c);
		
		//Stop testing here
		Test.stopTest();                                   
    }
}