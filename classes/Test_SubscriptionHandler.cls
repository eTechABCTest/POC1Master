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
 * The @isTest class annotation in  dicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
/**
 *	Purpose         :   Test class for SubscriptionHandler
 *                
 *  Created By      :  
 *   
 *  Created Date    :   6/7/2013
 *   
 *  Revision Log    :   V1.0 - Created
 *						V1.1 - Modified by - Mahendra Swarnkar - 8/30/2016- CR-20160505-9830 
 *
 *  Coverage        :   V1.1 - 85%
**/
@isTest
private class Test_SubscriptionHandler {
    
    //Test method is to test the SubscriptionHandler
    static testMethod void testSubscribe() {
        
        //Bypass Dupeblocker
        Util.IsTest(true);
        
        //Create test data
        Account account = Test_SiteUserHelper.createNewAccount(true);
        
        Program__c program = TestUtilities.CreateNewProgram(true);
        
        Contract__c contract = new Contract__c(Name='Test1', Payer_Account__c = account.Id, Program__c = program.Id, Start__c = System.Today().addDays(-10), 
                                                    End__c = System.Today().addDays(355));
        insert contract;
        
        //Create Test membership record
        Membership__c member = new Membership__c(Name = 'Test Membership', Account_Name__c = account.Id, Program__c = program.Id, 
                                                    Active_Contract_Idenfied__c = contract.Id);
        
        //insert membership record and assert the result
        insert member;
        
        //Test Site Profile Data
        Site_Profile__c sProfile = Test_SiteUserHelper.createSiteProfile(account, SiteUserHelper.SITE_EAB, false);
        sProfile.Bypass_Domain_Validation__c = true;
        insert sProfile;
        
        Contact contact = [SELECT Id, Name FROM Contact WHERE Id = :sProfile.Contact__c];
        
        //Subscription_Option__c record to insert
        Subscription_Option__c sOption = new Subscription_Option__c(Name = 'Test');
        insert sOption;
        
        //Insert Subscription record
        Eligible_Subscription_Option__c eSOption = new Eligible_Subscription_Option__c(Program__c = program.Id, Related_Subscription__c = sOption.Id);
        insert eSOption;
        
        //Add query string parameter
        ApexPages.currentPage().getParameters().put('CID', contact.Id);
        ApexPages.currentPage().getParameters().put('sub', sOption.Id);
        ApexPages.currentPage().getParameters().put('radiobuttons', 'Test');
        
        //Start Test from here
        Test.startTest();

        //Instantiate controller
        SubscriptionHandler controller = new SubscriptionHandler();

        //Call Add Subscription Method
        controller.addSubscription();
	
        //Assert for the results
        List<Subscription__c> subscriptions = [Select Id from Subscription__c where Contact__c =: contact.Id AND Subscription_ID__c =: eSOption.Id];
        System.assertEquals(1, subscriptions.size());
        System.assert(true, controller.response.containsIgnoreCase('You have been successfully subscribed'));
    	
    	//Stop Test
    	Test.stopTest();
    }
    
    static testMethod void testSubscribe_Error() {
        
        //Bypass Dupeblocker
        Util.IsTest(true);
        
        //Create test data
        Account account = Test_SiteUserHelper.createNewAccount(true);
        
        Program__c program = TestUtilities.CreateNewProgram(true);
        
        Contract__c contract = new Contract__c(Name='Test1', Payer_Account__c = account.Id, Program__c = program.Id, Start__c = System.Today().addDays(-10), 
                                                    End__c = System.Today().addDays(355));
        insert contract;
        
        //Create Test membership record
        Membership__c member = new Membership__c(Name = 'Test Membership', Account_Name__c = account.Id, Program__c = program.Id, 
                                                    Active_Contract_Idenfied__c = contract.Id);
        
        //insert membership record and assert the result
        insert member;
        
        //Test Site Profile Data
        Site_Profile__c sProfile = Test_SiteUserHelper.createSiteProfile(account, SiteUserHelper.SITE_EAB, false);
        sProfile.Bypass_Domain_Validation__c = true;
        insert sProfile;
        
        Contact contact = [SELECT Id, Name FROM Contact WHERE Id = :sProfile.Contact__c];
        
        //Subscription_Option__c record to insert
        Subscription_Option__c sOption = new Subscription_Option__c(Name = 'Test');
        insert sOption;
        
        //Insert Subscription record
        Eligible_Subscription_Option__c eSOption = new Eligible_Subscription_Option__c(Program__c = program.Id, Related_Subscription__c = sOption.Id);
        insert eSOption;
        
        //Make CID null -- this should produce an error
        ApexPages.currentPage().getParameters().put('CID', null);
        ApexPages.currentPage().getParameters().put('sub', sOption.Id);
        ApexPages.currentPage().getParameters().put('radiobuttons', 'Test');
        
        //Start Test from here
        Test.startTest();

        //Instantiate controller
        SubscriptionHandler controller = new SubscriptionHandler();

        //Call Add Subscription Method
        controller.addSubscription();
	
        //Make sure no subscription was created
        List<Subscription__c> subscriptions = [Select Id from Subscription__c where Contact__c =: contact.Id AND Subscription_ID__c =: eSOption.Id];
        System.assertEquals(0, subscriptions.size());
        
    	//Stop Test
    	Test.stopTest();
    }
	
	//Modified by - Mahendra Swarnkar - 8/30/2016- CR-20160505-9830 
	//Modified by - Mahendra Swarnkar -2/8/2016- CR-20151222-9476     
    //Test method is to test the SubscriptionHandler
    static testMethod void testUnSubscribe() {
        
        //Bypass Dupeblocker
        Util.IsTest(true);
        
        //Create test data
        Account account = Test_SiteUserHelper.createNewAccount(true);
        
        Program__c program = TestUtilities.CreateNewProgram(true);
        
        Contract__c contract = new Contract__c(Name='Test1', Payer_Account__c = account.Id, Program__c = program.Id, Start__c = System.Today().addDays(-10), 
                                                    End__c = System.Today().addDays(355));
        insert contract;
        
        //Create Test membership record
        Membership__c member = new Membership__c(Name = 'Test Membership', Account_Name__c = account.Id, Program__c = program.Id, 
                                                    Active_Contract_Idenfied__c = contract.Id);
        
        //insert membership record and assert the result
        insert member;
        
        //Test Site Profile Data
        Site_Profile__c sProfile = Test_SiteUserHelper.createSiteProfile(account, SiteUserHelper.SITE_EAB, false);
        sProfile.Bypass_Domain_Validation__c = true;
        insert sProfile;
        
        Contact contact = [SELECT Id, Name FROM Contact WHERE Id = :sProfile.Contact__c];
        
        //Subscription_Option__c record to insert
        Subscription_Option__c sOption = new Subscription_Option__c(Name = 'Test');
        insert sOption;
        
        //Insert Subscription record
        Eligible_Subscription_Option__c eSOption = new Eligible_Subscription_Option__c(Program__c = program.Id, Related_Subscription__c = sOption.Id);
        insert eSOption;
        
        //Create a Subscription__c record
        Subscription__c subscription = new Subscription__c(Contact__c = contact.Id, Subscription_ID__c = eSOption.Id);
        insert subscription;
        
        //Added by - Mahendra Swarnkar -2/8/2016- CR-20151222-9476
        //Starts from here
        //List to hold subscriptions records
        List<Subscription__c> subscriptns = new List<Subscription__c>();
        subscriptns.add(new Subscription__c(Contact__c = contact.Id, Subscription_ID__c = eSOption.Id, Termination_Date__c = System.now().addDays(-1)));
        subscriptns.add(new Subscription__c(Contact__c = contact.Id, Subscription_ID__c = eSOption.Id, Termination_Date__c = System.now().addDays(1)));
        subscriptns.add(new Subscription__c(Contact__c = contact.Id, Subscription_ID__c = eSOption.Id));
        subscriptns.add(new Subscription__c(Contact__c = contact.Id, Subscription_ID__c = eSOption.Id));
        
        //Insert subscriptions records
        insert subscriptns;
        //Ends here
        
        //Test Starts from here
        Test.startTest();
        
        //Instantiate controller
        SubscriptionHandler controller = new SubscriptionHandler();
        
        subscription = [SELECT Id, Subscription_Option_Id__c, Contact__c FROM Subscription__c WHERE Id = :subscription.Id];
                
		//Add query string parameter
        ApexPages.currentPage().getParameters().put('CID', contact.Id);
        ApexPages.currentPage().getParameters().put('sub', subscription.Subscription_Option_Id__c);
        ApexPages.currentPage().getParameters().put('radiobuttons', 'Test');
		
		// re-instantiate the controller
		controller = new SubscriptionHandler();
		
        //Call Remove Subscription Method
        controller.removeSubscription();
        
        //Assert for the results
        List<Subscription__c> subscriptions = [Select Subscription_Status__c from Subscription__c where Contact__c =: contact.Id
        				 //AND Subscription_ID__c =: eSOption.Id
        				 ];
        System.assertEquals(5, subscriptions.size());
        System.assertEquals(Constants.INACTIVE_UNSUBSCRIBED_BY_MEMBER + ' - Test', subscriptions[0].Subscription_Status__c);
        System.assertEquals(Constants.INACTIVE_UNSUBSCRIBED_BY_MEMBER + ' - Test', subscriptions[2].Subscription_Status__c);
         
        //Update Contact records
        contact.Unsubscribe_All_Date__c = System.Today().addDays(20);
        contact.HasOptedOutOfEmail = false;
        
        //Update Contact records
        update contact;
              
		//Add query string parameter
        ApexPages.currentPage().getParameters().put('CID', contact.Id);
        ApexPages.currentPage().getParameters().put('sub', Label.UNSUB_ALL_IDENTIFIER);
        ApexPages.currentPage().getParameters().put('radiobuttons', 'Test');
		
		// re-instantiate the controller
		controller = new SubscriptionHandler();
		
        //Call Remove Subscription Method
        controller.removeSubscription();
        
        //Retrive Subcribe records
        subscriptns = [SELECT Id, Subscription_Option_Id__c, Contact__c, Termination_Date__c, Subscription_Status__c 
        			   FROM Subscription__c WHERE Contact__c = :contact.Id AND Subscription_Status__c != null 
        			   AND Termination_Date__c != null];
        
        //Asssert for results
        System.assertEquals(5, subscriptns.size());
        System.assertEquals(Constants.INACTIVE_UNSUBSCRIBED_BY_MEMBER + ' - Test', subscriptions[0].Subscription_Status__c);
        System.assertEquals(Constants.INACTIVE_UNSUBSCRIBED_BY_MEMBER + ' - Test', subscriptions[1].Subscription_Status__c);
        System.assertEquals(Constants.INACTIVE_UNSUBSCRIBED_BY_MEMBER + ' - Test', subscriptions[2].Subscription_Status__c);
        System.assertEquals(Constants.INACTIVE_UNSUBSCRIBED_BY_MEMBER + ' - Test', subscriptions[3].Subscription_Status__c);
         
        //Retrive Contact Records to check updation
        List<Contact> contactRetriveRecords = [Select Id,Unsubscribe_All_Date__c,HasOptedOutOfEmail From Contact Where Id =: contact.Id];
        
        //Asssert for results
        System.assertEquals(System.Today(), contactRetriveRecords[0].Unsubscribe_All_Date__c);
        System.assertEquals(true, contactRetriveRecords[0].HasOptedOutOfEmail);
        
        //Stop Test here
        Test.stopTest();
    }
}