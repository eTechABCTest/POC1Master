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
 /*
    Purpose             :    Test Class BundleSearchOrAddNewToOpp_Controller
    
    Created By          :    Abhinav Sharma - 09/18/2014 - CR-5272
    
    Last Modified By    :    Abhinav Sharma
    
    Current Version:    :    v1.0
    
    Revision Log:       :    v1.0 - Created
    
    Code Coverage       :    v1.0 - 91%
*/
@isTest(seeAllData = false)
private class Test_BundleSearchOrAddNewToOpp {

    static testMethod void myUnitTest() {
        
        //Bypassing trigger
        Util.BypassAllTriggers = true;
        Util.IsTest(true);
        
        //Record Types
        List<RecordType> rdNonBundleType = [Select ID, DeveloperName FROM RecordType Where sObjectType='Opportunity' AND IsActive = true AND DeveloperName = 'Southwind'];
        
        //Assert for the result
        System.assert(rdNonBundleType != null);
        System.assertEquals(1, rdNonBundleType.size());
        
        //Account
        Account acc = new Account (Name ='Test Account');
        insert acc;
        
        //list to hold the opportunity records
        List<Opportunity> opportunities = new List<Opportunity>();
        
        //List of Bundle records
        List<Bundle__c> bundles = new List<Bundle__c>();
        
        //Opportunity Instance
        Opportunity opp_1 = new Opportunity(StageName = 'Prospecting', CloseDate = System.today().addDays(5), Name = 'Test Opp 1', Amount = 2000, AccountId = acc.Id, 
                                                RecordTypeId = rdNonBundleType[0].ID);
        
        //Setting flag values
        OpportunityTriggerHelper.EXECUTE_TRIGGER_BEFORE_UPDATE = true;
        OpportunityTriggerHelper.EXECUTE_TRIGGER_AFTER_UPDATE = true;

        //Enabling triggers again
        Util.BypassAllTriggers = false;
        
        //Insert Bundled opportunities
        insert opp_1;
        
        //Start test from here
        Test.startTest();
        
        //Loading VF page and adding a new bundle to selcted opportunity as parent
        ApexPages.StandardController sc = new ApexPages.StandardController(opp_1);
        BundleSearchOrAddNewToOpp_Controller controller = new BundleSearchOrAddNewToOpp_Controller(sc);
        controller.opportunity = opp_1;
        controller.addNewBundleAndThenTagItToOpportunity(); 
        
        //Retrieving out the details
        opportunities = [SELECT ID, Bundle__c FROM Opportunity WHERE ID =: opp_1.Id LIMIT 1];
        bundles = [SELECT ID FROm Bundle__c LIMIT 3];
        
        //Asserting for the results
        System.assertEquals(1, bundles.size());
        System.assertEquals(true, opportunities[0].Bundle__c == bundles[0].Id);
        
        //Test will stop here
        Test.stopTest();
    }
    
    static testMethod void myUnitTest2() {
        
        //Bypassing trigger
        Util.BypassAllTriggers = true;
        Util.IsTest(true);
        
        //Record Types
        List<RecordType> rdNonBundleType = [Select ID, DeveloperName FROM RecordType Where sObjectType='Opportunity' AND IsActive = true AND DeveloperName = 'Southwind'];
        
        //Assert for the result
        System.assert(rdNonBundleType != null);
        System.assertEquals(1, rdNonBundleType.size());
        
        //Account
        Account acc = new Account (Name ='Test Account');
        insert acc;
        
        //Bundle 
        Bundle__c bundle = new Bundle__c();
        insert bundle;
        
        //list to hold the opportunity records
        List<Opportunity> opportunities = new List<Opportunity>();
        
        //Opportunity Instance
        Opportunity opp_1 = new Opportunity(StageName = 'Prospecting', CloseDate = System.today().addDays(5), Name = 'Test Opp 1', Amount = 2000, AccountId = acc.Id, 
                                                RecordTypeId = rdNonBundleType[0].ID);
        
        //Setting flag values
        OpportunityTriggerHelper.EXECUTE_TRIGGER_BEFORE_UPDATE = true;
        OpportunityTriggerHelper.EXECUTE_TRIGGER_AFTER_UPDATE = true;

        //Enabling triggers again
        Util.BypassAllTriggers = false;
        
        //Insert Bundled opportunities
        insert opp_1;
        
        //Start test from here
        Test.startTest();
        
        //Loading VF page and adding a searched bundle to selcted opportunity as parent
        ApexPages.StandardController sc = new ApexPages.StandardController(opp_1);
        BundleSearchOrAddNewToOpp_Controller controller = new BundleSearchOrAddNewToOpp_Controller(sc);
        controller.opportunity = opp_1;
        controller.opportunity.Bundle__c = bundle.Id;
        controller.tagSearchedBundleToOpportunity();
        
        //Retrieving out the details
        opportunities = [SELECT ID, Bundle__c FROM Opportunity WHERE ID =: opp_1.Id LIMIT 1];
        
        //Asserting for the results
        System.assertEquals(true, opportunities[0].Bundle__c == bundle.Id);
        
        //Test will stop here
        Test.stopTest();
    }
    
    static testMethod void myUnitTest3() {
        
        //Bypassing trigger
        Util.BypassAllTriggers = true;
        Util.IsTest(true);
        
        //Loading page without passing any opportunity ID value in URL
        Opportunity opp = new Opportunity();
        
        //Start Test from here
        Test.startTest();
        
        try {
            //Loading the VF page
            ApexPages.StandardController sc = new ApexPages.StandardController(opp);
            BundleSearchOrAddNewToOpp_Controller controller = new BundleSearchOrAddNewToOpp_Controller(sc);
            controller.doCancel();
        } catch(Exception ex) {}
        
        //Stop Test here
        Test.stopTest();
    }
    
    static testMethod void myUnitTest4() {
    
        //Bypassing trigger
        Util.BypassAllTriggers = true;
        Util.IsTest(true);
        
        //Record Types
        List<RecordType> rdNonBundleType = [Select ID, DeveloperName FROM RecordType Where sObjectType='Opportunity' AND IsActive = true AND DeveloperName = 'Southwind'];
        
        //Assert for the result
        System.assert(rdNonBundleType != null);
        System.assertEquals(1, rdNonBundleType.size());
        
        //Account
        Account acc = new Account (Name ='Test Account');
        insert acc;
        
        //Opportunity Instance
        Opportunity opp_1 = new Opportunity(StageName = 'Prospecting', CloseDate = System.today().addDays(5), Name = 'Test Opp 1', Amount = 2000, AccountId = acc.Id, 
                                                RecordTypeId = rdNonBundleType[0].ID);
        insert opp_1;
        
        //Testing will start from here
        Test.startTest();
        
        //Loading the VF page
        ApexPages.StandardController sc = new ApexPages.StandardController(opp_1);
        BundleSearchOrAddNewToOpp_Controller controller = new BundleSearchOrAddNewToOpp_Controller(sc);
        
        //Selecting the opportunity record
        controller.opportunity = opp_1;
        controller.opportunity.StageName = null;
        controller.opportunity.Amount = null;
        try {
            controller.addNewBundleAndThenTagItToOpportunity();
        } catch(Exception ex) {}
        
        //Stop Test Here
        Test.stopTest();
    }
    
    static testMethod void myUnitTest5() {
        
        //Bypassing trigger
        Util.BypassAllTriggers = true;
        Util.IsTest(true);
        
        //Loading page without passing any opportunity ID value in URL
        Opportunity opp = new Opportunity();
        
        //Start Test from here
        Test.startTest();
        
        try {
            //Loading the VF page
            ApexPages.StandardController sc = new ApexPages.StandardController(opp);
            BundleSearchOrAddNewToOpp_Controller controller = new BundleSearchOrAddNewToOpp_Controller(sc);
            controller.tagSearchedBundleToOpportunity();
        } catch(Exception ex) {
             System.assert(ex.getMessage().contains(System.Label.BundleSearch_CL2));
        }
        
        //Stop Test here
        Test.stopTest();
    }
}