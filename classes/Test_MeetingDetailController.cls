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
private class Test_MeetingDetailController {

    static testMethod void testButtonsVisibility() {
        
		//Create Test Data
		//Create Parent meeting records
		Advisory_Event__c meeting = TestUtilities.createEvent(Constants.RECORD_TYPE_ID_ADV_EVENT_SERIES, null, true);
		meeting.Rules_Titles__c = 'Test';
		meeting.Rules_Thresholds__c = 'Test';
		meeting.Rules_Programs__c = 'Test';
		update meeting;
		
		//Start Testing from here
		Test.startTest();
		
		//Create the Controller instance
		MeetingDetailController controller = new MeetingDetailController(new ApexPages.StandardController(meeting));
		
		//Reinstantiate new controller
		meeting.Rules_Titles__c = 'Use parent\'s rules';
		meeting.Rules_Thresholds__c = 'Use parent\'s rules';
		update meeting;
		
		//Create the Controller instance
		MeetingDetailController controller2 = new MeetingDetailController(new ApexPages.StandardController(meeting));
		
		//Stop test here
		Test.stopTest();
		
		System.assert(controller.displayNewTitleButton);
		System.assert(controller.displayNewThresholdButton);
		System.assert(controller.displayNewProgramButton);
		
		//Buttons will not be displayed
		System.assert(!controller2.displayNewTitleButton);
		System.assert(!controller2.displayNewThresholdButton);
		System.assert(controller2.displayNewProgramButton);
	}
}