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
    Purpose             :    Test Class BundleRemoveController
    
    Created By          :    Abhinav Sharma - 09/19/2014 - CR-5272
    
    Last Modified By    :    Abhinav Sharma
    
    Current Version:    :    v1.0
    
    Revision Log:       :    v1.0 - Created
    
    Code Coverage       :    v1.0 - 09/19/2014 - 100%
*/
@isTest(seeAllData=false)
private class Test_BundleRemoveController {

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
        
        //Bundle
        Bundle__c testBundle = new Bundle__c (Name ='Test Bundle');
        insert testBundle;
        
        //list of opportunity records
        List<Opportunity> opportunities = new List<Opportunity>();
        
        //Opportunity
        Opportunity opp_1 = new Opportunity(StageName = 'Prospect', CloseDate = System.today().addDays(5), Name = 'Test Opp 3', Amount = 2000, 
                                                Bundle__c = testBundle.Id, RecordTypeId = rdNonBundleType[0].ID);
        
        //Start test from here
        Test.startTest();
        
        //Enabling the triggers
        Util.BypassAllTriggers = false;
        
        //Insert opportunity
        insert opp_1;
        
        //Asserting for the results
        //Retrieving out the details
        opportunities = [SELECT ID, Bundle__c FROM Opportunity WHERE ID =: opp_1.Id ORDER BY Name ASC];        
        
        //Assert for results
        System.assertEquals(1, opportunities.size());
        System.assertEquals(testBundle.Id, opportunities[0].Bundle__c);
        
        //Clicking on the "Remove Bundle" hyperlink for loading of VF page
        ApexPages.StandardController sc = new ApexPages.StandardController(opp_1);
        BundleRemoveController controller = new BundleRemoveController(sc);
        
        //Calling method to remove the bundle reference from the selected opportunity record
        controller.removeBundleFromOpportunity(); 
        
        //Asserting for the results
        //Retrieving out the details
        opportunities = [SELECT ID, Bundle__c FROM Opportunity WHERE ID =: opp_1.Id ORDER BY Name ASC];        
        
        //Assert for results
        System.assertEquals(1, opportunities.size());
        System.assertEquals(null, opportunities[0].Bundle__c);
        
        //Loading page without passing any opportunity ID value in URL
        Opportunity opp = new Opportunity();
        
        try {
        
            //Calling Class Constructor
            ApexPages.StandardController sc_1 = new ApexPages.StandardController(opp);
            BundleRemoveController controller_1 = new BundleRemoveController(sc_1);
            
            //Calling class method
            controller_1.removeBundleFromOpportunity();
        } catch(Exception ex) {}
        
        //testing the exception case
        opp_1.StageName = null;
        
        try {
        
            //Calling Class Constructor
            ApexPages.StandardController sc_2 = new ApexPages.StandardController(opp_1);
            BundleRemoveController controller_2 = new BundleRemoveController(sc_2);
            
            //Calling class method
            controller_2.removeBundleFromOpportunity();
        } catch(Exception ex) {}
        
        //Stop test here
        Test.stopTest();
    }
}