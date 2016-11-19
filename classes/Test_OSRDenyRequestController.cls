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
private class Test_OSRDenyRequestController {
/**
*  Description     :   Test class for DeniedRequest
*
*  Created By      :   Mahendra Swarnkar
*
*  Created Date    :   10/27/2015
*
*  Revision Logs   :   V_1.0 - Created - CR-20150707-9062 - 10/26/2015 (Method:- TestUpdateOSRStatusToDeny)
*
*  Coverage        :   
*
**/

    //Setup test data that will be available for entire class
	@testSetup static void setup() {
		
		//Bypass all triggers
		Util.IsTest(true);
		util.ByPassAllTriggers = true;
		
        //User record
		User currentUser;
		
		//Update the User Finance Code if not alreayd populated
		System.runAs(new User(Id = UserInfo.getUserId())) {
			
			//Update the Employee Id
			currentUser = new User(Id = UserInfo.getUserId(), Finance_Code__c = '50011');
			update currentUser;
		}
		
		//Contact Instance
		Contact contact = TestUtilities.CreateNewContact(false);
		contact.Birthdate = System.today().addYears(-28);
		contact.Employee_ID__c = '50011';
		contact.Employee_User_Record__c = UserInfo.getUserId();
		
		//Insert Contact
		insert contact;
		
		//Provider Profile Instance
		Provider_Profile__c providerProfile = new Provider_Profile__c(Provider_Profile_ID__c = '2');
		
		//Insert Provider Profile
		insert providerProfile;
		
		//ABC Profile Instance
		ABC_Profile__c abcProfile = new ABC_Profile__c(Name = 'Test', 
															Over_aging_Warning_days__c = 35, 
															Over_aging_Maximum_days__c = 45, 
															Over_balance_Warning_threshold_1__c = .75, 
															Over_balance_Warning_threshold_2__c = .90, 
															Over_balance_Countdown_days__c = 3,
															Provider_Profile__c = providerProfile.Id);
		//Insert Provider Profile
		insert abcProfile;
		
		//Retrive OSR record type
        List<RecordType> listOSRRecordType = [Select Id, DeveloperName From RecordType Where DeveloperName =: CreditCardConstants.OSR_RECORD_TYPE_DEVELOPER_NAME_CREDIT_CARD_REQUEST  AND IsActive = TRUE];
        
		//List to hold OSR records
		List<OSR__c> listOsr = new List<OSR__c>();
		
		//Populating list
		listOsr.add(new OSR__c(Contact__c = contact.Id, RecordTypeId = listOSRRecordType[0].Id,
		 						Request_Type__c = CreditCardConstants.OSR_REQUEST_TYPE_NEW_ABC_CREDIT_CARD,
		                    	Status__c = CreditCardConstants.OSR_STATUS_PENDING_FINANCE,
		                    	Advisory_Profile__c = abcProfile.Id));
		listOsr.add(new OSR__c(Contact__c = contact.Id, RecordTypeId = listOSRRecordType[0].Id, 
								Request_Type__c = CreditCardConstants.OSR_REQUEST_TYPE_NEW_ABC_CREDIT_CARD,
		                    	Status__c = CreditCardConstants.OSR_STATUS_DENIED,
		                    	Advisory_Profile__c = abcProfile.Id));
		
		//Insert OSR records
		insert listOsr;
		
		//Enable all triggers
		util.ByPassAllTriggers = false;    
    }
    
    //Method to test OSR deny request functionality
    static testMethod void testUpdateOSRStatusToDeny() {
    	
    	//List to hold OSR records
		List<OSR__c> listOsr = [Select Id, Status__c From OSR__c];
		
        //Assert for results
        System.assert(listOsr != null);
		System.assertEquals(2,listOsr.size());
		
    	//Initilize Standard controller
        ApexPages.StandardController sc = new ApexPages.StandardController(listOsr[0]);
        
        //Initilize main controller
        OSRDenyRequestController controller  = new OSRDenyRequestController(sc);
        
        //Populating oSRId
        controller.oSRId = listOsr[0].Id;
        
        //Test Starts from here
        Test.startTest();
        
        //Calling Controller method
        controller.updateOSRStatusToDeny();
        
        //Qurery through OSR records
        List<OSR__c> listOSRResult = [Select Id, Status__c From OSR__c Where Id != null AND Id =:listOsr[0].Id];
        
        //Asserting for results
        System.assertEquals( CreditCardConstants.OSR_STATUS_DENIED, listOSRResult[0].Status__c);
		
		//Initilize Standard controller
        sc = new ApexPages.StandardController(listOsr[1]);
        
        //Initilize page controller
        controller  = new OSRDenyRequestController(sc);
        
        //Populating oSRId
        controller.oSRId = listOsr[1].Id;
        
        //Calling Controller method
        controller.updateOSRStatusToDeny();
        
        //Qurery through OSR records
        listOSRResult = [Select Id, Status__c From OSR__c Where Id != null AND Id =:listOsr[1].Id];
        
        //Asserting for results
        System.assertEquals(CreditCardConstants.OSR_STATUS_DENIED, listOSRResult[0].Status__c);
        
        //Asserting for results
        System.assert(ApexPages.hasMessages());
        
        //Query through ABC Profile records
        List<ABC_Profile__c> listABC = [Select Id From ABC_Profile__c limit 1];
        
        //Initilize page controller
        controller  = new OSRDenyRequestController(sc);
        
        //Populating oSRId
        controller.oSRId = listABC[0].Id;
        
        //Calling Controller method
        controller.updateOSRStatusToDeny();
        
        //Asserting for results
        System.assert(ApexPages.hasMessages());
        
        //Initilize page controller
        controller  = new OSRDenyRequestController(sc);
        
        //Populating oSRId
        controller.oSRId = null;
        
        //Calling Controller method
        controller.updateOSRStatusToDeny();
        
        //Asserting for results
        System.assert(ApexPages.hasMessages());
        
        //Test Ends here
        Test.stopTest();        
    }
}