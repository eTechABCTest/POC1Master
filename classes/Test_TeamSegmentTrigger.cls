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
private class Test_TeamSegmentTrigger {

	//Setup test data first. This will be available in the entire class
	@testSetup static void setup() {
	
		// Create common Team Segment
		Team_Segment__c teamSegment = new Team_Segment__c(Name = 'UniqueName');
		insert teamSegment;
	}
    
	//Test method to check the valid Team segment
    static testMethod void testValidateTeamSegments() {
        
        //Start Testing from here
        Test.startTest();
        
        //Create duplicate team segment
        Team_Segment__c teamSegment = new Team_Segment__c(Name = 'UniqueName');
		
		//Try to insert team segment
		try {
			insert teamSegment;
			
			//If the segment get added, that means trigger is not working as expected and fail the test method
			System.assert(false, 'Duplaicate Team Segment was added.');
		} catch(Exception e) {
			
			//Check teh exception message and pass the test method
			System.assert(e.getMessage().contains(Label.ERROR_UNIQUENESS_SEGMENT_NAME));
		}
		
		//Change the Name and the insert. It should be inserted successfully this time
		teamSegment.Name = 'UniqueName II';
		insert teamSegment;
		
		//Try to update the Name with a name already exists
		try {
			teamSegment.Name = 'UniqueName';
			update teamSegment;
			
			//If the segment get added, that means trigger is not working as expected and fail the test method
			System.assert(false, 'Duplaicate Team Segment was added.');
		} catch(Exception e) {
			
			//Check teh exception message and pass the test method
			System.assert(e.getMessage().contains(Label.ERROR_UNIQUENESS_SEGMENT_NAME));
		}
		
		//Try to update  without changing anything, Just to amke sure record in not referencing it's own instance
		teamSegment.Name = 'UniqueName II';
		update teamSegment;
		
		//Try to update with a different name
		teamSegment.Name = 'UniqueName I';
		update teamSegment;
		
		//Stop Test
		Test.stopTest();
	}
}