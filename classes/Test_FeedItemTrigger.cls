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
 /** 
 *  V_2.0 - Modified By - Rajeev Jain - 2/18/2016 - CR-20160203-9580 
            @Description : Replace Column__c with Attribute__c field. Updated logic which was checking based on column, now will check for unique attribute.
 **/
@isTest(seeAllData=false)
private class Test_FeedItemTrigger {

    //Setup test data first. This will be available in the entire class
    @testSetup static void setup() {
    
        // Create common Team Role
        Feed__c feed1 = new Feed__c(Name = 'ATest', Output_Filename__c = 'test1', Sequence__c = 1);
        insert feed1;
        
        // Create common Team Role
        Feed__c feed2 = new Feed__c(Name = 'BTest', Output_Filename__c = 'test2', Sequence__c = 2);
        insert feed2;
        
        //Sample Feed Item
        Feed_Item__c fI1 = new Feed_Item__c(Feed_Identifier__c = feed1.Id, Attribute__c = 'Attribute01', 
                                            Column_label__c = 'Column Label', Output_Order__c = 1,
                                            Output_data_type__c = 'Text');
        insert fI1;
    }
    
    //Test method to check the valid Team role
    static testMethod void testValidateFeedItems() {
        
        //Query Institution and Team role records
        List<Feed__c> feeds = [Select Id from Feed__c order by Name ASC];
        
        //Feed Item
        Feed_Item__c fI = new Feed_Item__c(Feed_Identifier__c = feeds[0].Id, Attribute__c = 'Attribute01', 
                                           Column_label__c = 'Column Label', Output_Order__c = 1,
                                           Output_data_type__c = 'Text');
        
        //Start Testing from here
        Test.startTest();
        
        //Try to insert team role
        try {
            insert fI;
            
            //If the role get added, that means trigger is not working as expected and fail the test method
            System.assert(false, 'Duplaicate Feed Item was added.');
        } catch(Exception e) {
            
            //Check teh exception message and pass the test method
            System.assert(e.getMessage().contains(Label.ERROR_UNIQUENESS_FEED_ITEM));
        }
        
        //Change the Name and the insert. It should be inserted successfully this time
        fI.Attribute__c = 'Attribute02';
        insert fI;
        
        //Try to update the Start Date with a date already exists
        try {
            fI.Attribute__c = 'Attribute01';
            update fI;
            
            //If the role get added, that means trigger is not working as expected and fail the test method
            System.assert(false, 'Duplaicate Feed Item was added.');
        } catch(Exception e) {
            
            //Check teh exception message and pass the test method
            System.assert(e.getMessage().contains(Label.ERROR_UNIQUENESS_FEED_ITEM));
        }
        
        //Try to update  without changing anything, Just to amke sure record in not referencing it's own instance
        fI.Attribute__c = 'Attribute02';
        update fI;
            
        //Try to update with a different value
        fI.Attribute__c = 'Attribute03';
        update fI;
        
        //Stop Test
        Test.stopTest();
    }
}