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
 *   Purpose         :   Test class for RequestFeedTransmission Page.
 *            
 *   Create By       :   Subhash Garhwal
 *
 *   Created Date    :   01/05/2016
 *
 *   Revision Log    :   V_1.0 - Created - CR-20151216-9465
 *                   :   V_2.0 - Modified By - Rajeev  Jain - 2/18/2016 - CR-20160203-9580 - Replaced Column__c with Attribute__C
 * 
 *   Coverage        :   V_1.0 - 
 **/

@isTest(seeAllData = false)
private class RequestFeedTransmissionControllerTest {
    
    //Test method
    static testMethod void myUnitTest1() {
        
        //Create new list for Feed 
        List<Feed__c> feeds = new List<Feed__c>();
        
        //Add record in list
        feeds.add(new Feed__c(Name = 'Feed 1', Feed_Group__c = 'FG 1', Execution_Requested__c = System.Today().addDays(-5), Feed_Identifier__c = 'Identifier 1', Sequence__c = 1, Output_Filename__c = 'FName 1', Output_File_Type__c = 'CSV'));
        feeds.add(new Feed__c(Name = 'Feed 2', Feed_Group__c = 'FG 1', Execution_Requested__c = System.Today().addDays(5), Feed_Identifier__c = 'Identifier 2', Sequence__c = 2, Output_Filename__c = 'FName 2', Output_File_Type__c = 'CSV'));
        feeds.add(new Feed__c(Name = 'Feed 3', Feed_Group__c = 'FG 2', Execution_Requested__c = System.Today().addDays(-5), Feed_Identifier__c = 'Identifier 3', Sequence__c = 3, Output_Filename__c = 'FName 3', Output_File_Type__c = 'CSV'));
        feeds.add(new Feed__c(Name = 'Feed 4', Feed_Group__c = 'FG 2', Execution_Requested__c = System.Today().addDays(5), Feed_Identifier__c = 'Identifier 4', Sequence__c = 4, Output_Filename__c = 'FName 4', Output_File_Type__c = 'Text', Output_Delimiter__c = 'a'));
        feeds.add(new Feed__c(Name = 'Feed 5', Feed_Group__c = 'FG 3', Execution_Requested__c = System.Today().addDays(-5), Feed_Identifier__c = 'Identifier 5', Sequence__c = 5, Output_Filename__c = 'FName 5', Output_File_Type__c = 'Text', Output_Delimiter__c = 'b'));
        feeds.add(new Feed__c(Name = 'Feed 6', Feed_Group__c = 'FG 3', Execution_Requested__c = System.Today().addDays(5), Feed_Identifier__c = 'Identifier 6', Sequence__c = 6, Output_Filename__c = 'FName 6', Output_File_Type__c = 'Text', Output_Delimiter__c = 'c'));
        feeds.add(new Feed__c(Name = 'Feed 7', Feed_Group__c = 'FG 3', Execution_Requested__c = System.Today().addDays(10), Feed_Identifier__c = 'Identifier 7', Sequence__c = 7, Output_Filename__c = 'FName 7', Output_File_Type__c = 'Text', Output_Delimiter__c = 'd'));
        
        //Insert 
        insert feeds;
        
        //Create new list for Feed Item
        List<Feed_Item__c> feedItems = new List<Feed_Item__c>();
        
        //Add record in list
        feedItems.add(new Feed_Item__c(Feed_Identifier__c = feeds[0].Id, Attribute__c = 'Attribute01', Column_label__c = 'Columnlabel1', Output_Data_Type__c = 'Text', Output_Order__c = 1));
        feedItems.add(new Feed_Item__c(Feed_Identifier__c = feeds[0].Id, Attribute__c = 'Attribute02', Column_label__c = 'Columnlabel2', Output_Data_Type__c = 'Text', Output_Order__c = 2));
        feedItems.add(new Feed_Item__c(Feed_Identifier__c = feeds[1].Id, Attribute__c = 'Attribute03', Column_label__c = 'Columnlabel3', Output_Data_Type__c = 'Text', Output_Order__c = 1));
        feedItems.add(new Feed_Item__c(Feed_Identifier__c = feeds[2].Id, Attribute__c = 'Attribute04', Column_label__c = 'Columnlabel4', Output_Data_Type__c = 'Text', Output_Order__c = 1));
        feedItems.add(new Feed_Item__c(Feed_Identifier__c = feeds[3].Id, Attribute__c = 'Attribute05', Column_label__c = 'Columnlabel5', Output_Data_Type__c = 'Text', Output_Order__c = 1));
        feedItems.add(new Feed_Item__c(Feed_Identifier__c = feeds[4].Id, Attribute__c = 'Attribute06', Column_label__c = 'Columnlabel6', Output_Data_Type__c = 'Text', Output_Order__c = 1));
        
        //Insert
        insert feedItems;
        
        //Test method start here  
        Test.startTest();
        
        //Controller Instante
        RequestFeedTransmissionController controller = new RequestFeedTransmissionController();
        
         //Call SelectOption
        List<SelectOption> sOList = controller.views;
        List<SelectOption> sTimeList = controller.timeViews;
        List<SelectOption> sAMPMList = controller.aMPMOptions;
        
        //Assert for result
        System.assertEquals(3, controller.headers.size());
        System.assertEquals(3, controller.requestedFeeds.size());
        System.assertEquals(2, controller.requestedFeeds[0].feedGroupWrapperList.size());
        System.assertEquals(2, controller.requestedFeeds[1].feedGroupWrapperList.size());
        System.assertEquals(2, controller.requestedFeeds[2].feedGroupWrapperList.size());
        
        //Select record
        controller.requestedFeeds[0].feedGroupWrapperList[0].selected = true;
        
        //Call method
        controller.doSave();
        
        //Query through Feed   Where Execution_Requested__c =: System.Today()
        List<Feed__c> feedList = [Select Id, Name, Execution_Requested__c, Feed_Group__c from Feed__c];
        
        //Assert for result
        System.assertEquals(7 ,feedList.size());
        
        //Put Url
        ApexPages.currentPage().getParameters().put('returnURL','Test');
        
        //Re-Inislizatioin
        controller = new RequestFeedTransmissionController();
        
        //Set value
        controller.selectedView = 'Custom';
        
        //Select record
        controller.requestedFeeds[0].feedGroupWrapperList[0].selected = true;
        
        //Set Date
        controller.feedInstance.Feed_Date_Temp__c = null;
        
        //Check Exception
        try{
            //Call method
            controller.doSave();
            
        }catch(Exception ex){
            
            //Assert for result
            System.assert(ApexPages.getMessages()[0].getDetail().contains(ISSPConstants.SELECTED_DATETIME_SHOULD_BE_IN_FUTURE));
        }
        
        //Set Date
        controller.feedInstance.Feed_Date_Temp__c = System.Today().addDays(-5);
        
        //Check Exception
        try{
            //Call method
            controller.doSave();
            
        }catch(Exception ex){
            
            //Assert for result
            System.assert(ApexPages.getMessages()[0].getDetail().contains(ISSPConstants.SELECTED_DATETIME_SHOULD_BE_IN_FUTURE));
        }
        
        //Set Time
        controller.feedInstance.Feed_Date_Temp__c = System.Today().addDays(30);
        controller.selectedTime = '1:00';
        controller.selectedTP = 'PM';
        
        //Call method
        controller.doSave();
        
        //Query through feed
        feedList = [Select Id, Name, Execution_Requested__c, Feed_Group__c from Feed__c];
          
        //Change Date/Time to String
        String dateString = string.valueOfGmt(feedList[0].Execution_Requested__c);
        
        //Assert for result  
        System.assertEquals(7 ,feedList.size());
        System.assertEquals('Feed 1' ,feedList[0].Name);
        System.assertEquals('FG 1' ,feedList[0].Feed_Group__c);
        //System.assertEquals(controller.feedInstance.Feed_Date_Temp__c,feedList[0].Execution_Requested__c);
        
        //To cover exception
        //Re-Inislizatioin
        controller = new RequestFeedTransmissionController();
        
        //Set value
        controller.selectedView = 'Custom';
        
        //Select record
        controller.requestedFeeds[0].feedGroupWrapperList[0].selected = true;
        
        //Call method
        controller.doCancel();
        
        //Test method stop here
        Test.stopTest();
    }
}