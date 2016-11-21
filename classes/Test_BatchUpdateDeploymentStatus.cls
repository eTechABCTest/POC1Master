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
*/
@isTest
private class Test_BatchUpdateDeploymentStatus {
/**
 *	Purpose			:	Test class for Batch_UpdateDeploymentStatus
 *
 *	Created By		:	Bhavi Sharma
 *
 *	Created Date	:	05/14/2013
 *
 *	Revision Logs	:	V_1.0 - Created
 *
 *	Coverage		:	100% 	
 *
 **/ 
    static testMethod void myUnitTest() {
        
        //select Record types
		Id recordtypeId = [select id from RecordType where SObjectType = 'Deployment__c' and Name = :Constants.RECORD_TYPE_DEPLOYMENT_CMA_DEPLOYMENT].id;

		//Project type record
		Project__c project = new Project__c(Name = 'ProjectDemo');

		//Insert Project record
		insert project;

		//Deployment type record
		Deployment_Type__c deploy = new Deployment_Type__c(Name = 'Test Deployment Type');

		//insert
		insert deploy;

		//Deployment record
		//Create a list of deployment records to be inserted
		List<Deployment__c> deployments = new List<Deployment__c>();
		deployments.add(new Deployment__c(Name = 'DeploymentDemo1', Project__c = project.Id,Deployment_Type__c = deploy.Id, C_A_DS__c = Date.today(),
														CPM_Deployment_Status__c = 'Green', C_A_DC__c = Date.today()-2, RecordTypeId = recordtypeId));
		deployments.add(new Deployment__c(Name = 'DeploymentDemo2', Project__c = project.Id,Deployment_Type__c = deploy.Id, C_A_DS__c = Date.today(),
														CPM_Deployment_Status__c = 'Red', C_A_DC__c = Date.today()-2, RecordTypeId = recordtypeId));

		//Insert 
		insert deployments;
		
		//Start Test form here
		Test.StartTest();

		//Execute Batch job
		Database.executeBatch(new Batch_UpdateDeploymentStatus());

		//stop Test here
		Test.StopTest();

		//assert for the results
		for(Deployment__c deployment : [Select Id, CMA_Status_Formula__c, CPM_Deployment_Status__c from Deployment__c where Id IN: deployments]) {
		
			//assert statement
			System.assertEquals(deployment.CMA_Status_Formula__c, deployment.CPM_Deployment_Status__c);
		}
    }
}