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
@isTest(seeAllData=false)
private class TestSFDCChangeRequestHelper {
/*
  Purpose      :   Test class for Trigger_SFDC_ChangeRequest
        
  Create By    :   Simplyforce Technology
  
  Created Date  :   05/29/2012
  
  Current Version  :   V1.0
  
  Revision Log  :  V1.0 - Created
                   V1.1 - Ajit Surana - Added new method (test_rollUpStorySizeDataOnSFDCRelease) - 04/18/2014 - CR-20140303-4690
                   V1.2 - Bhavi Sharma - 05/02/2014 - updated myUnitTest - CR-20140225-4635
                   V1.3 - Abhinav Sharma - 03/10/2015 - CR-20140508-5406            
  Coverage    :  100%
*/

    //Test 
    static testmethod void myUnitTest() {
        
        //System Administratot User
        User sysAdmin = [SELECT Name, Id FROM User 
                            WHERE Profile.Name = 'System Administrator' AND IsActive = true 
                            AND Name != 'Salesforce Administrator' AND FirstName != 'Salesforce' LIMIT 1];
        
        system.runAs(sysAdmin) {
        
            //Insert release record
            SFDC_Release__c release = new SFDC_Release__c (name = 'Test',  Target_Release_Date__c = Date.today());
            insert release;
            
            //Create a list of data to be inserted
            List<SFDC_Change_Request__c> changeRequests = new List<SFDC_Change_Request__c>();
            
            //Create records in list
            for(Integer i = 0; i < 200; i++) {
                
                //Insert data in change request
                changeRequests.add(new SFDC_Change_Request__c (Title__c = 'Test-' + i, Release__c = release.Id));
            }
            
            //Start Test from here 
            Test.startTest();
            
            //Insert changeRequest
            insert changeRequests;
            
            //Insert SFDC Modifications
            List<IS_System_Modification__c> modifications = new List<IS_System_Modification__c>();
            
            //create a component
            IS_System_Component__c component1 = new IS_System_Component__c(Name = 'will auto-populate',
                                                                           Object_Label__c = 'Account',
                                                                           Object_API_Name__c = 'Account',
                                                                           Object_Type__c = 'Object',
                                                                           Salesforce_Object_Id__c = '01I4B0000000007AAA',
                                                                           SOX_Object__c = FALSE);
            insert component1;
            
            //Loop through the change requests and create the modifications for each
            for(SFDC_Change_Request__c cR : changeRequests) {
                
                //add modification record in list
                modifications.add(new IS_System_Modification__c (Change_Request__c = cR.Id, Manual_Step__c = true, Label__c = 'Test', IS_System_Component__c = component1.Id));
            }
            
            //Insert modification data
            insert modifications;
            
            //Insert CRM Activities
            List<SFDC_Request_Comment__c> comments = new List<SFDC_Request_Comment__c>();
            
            //Loop through the change requests and create the comments for each
            for(SFDC_Change_Request__c cR : changeRequests) {
                
                //add modification record in list
                comments.add(new SFDC_Request_Comment__c(SFDC_Change_Request__c = cR.Id, Activity_Type__c = 'Analysis/Design', Time__c = 1));
            }
            
            //Insert comments data
            insert comments;
            
            //Assert for the result
            release = [Select No_of_Change_Requests__c, No_of_Modifications__c, No_of_Manual_Setup_Mods__c, Coding_Estimated_Hrs__c, Coding_Actual_Hrs__c,
                            Config_Estimated_Hrs__c, Config_Actual_Hrs__c, Design_Estimated_Hrs__c, Design_Actual_Hrs__c, IS_QA_Estimated_Hrs__c, 
                            IS_QA_Actual_Hrs__c, User_Documentation_Actual_Hrs__c from SFDC_Release__c where Id =: release.Id];
            
            System.assertEquals(changeRequests.size(), release.No_of_Change_Requests__c);
            System.assertEquals(modifications.size(), release.No_of_Modifications__c);
            System.assertEquals(modifications.size(), release.No_of_Manual_Setup_Mods__c);
            System.assertEquals(null, release.Coding_Estimated_Hrs__c);
            System.assertEquals(0, release.Coding_Actual_Hrs__c);
            System.assertEquals(null, release.Config_Estimated_Hrs__c);
            System.assertEquals(0, release.Config_Actual_Hrs__c);
            System.assertEquals(200, release.Design_Estimated_Hrs__c);
            System.assertEquals(200, release.Design_Actual_Hrs__c);
            System.assertEquals(null, release.IS_QA_Estimated_Hrs__c);
            System.assertEquals(0, release.IS_QA_Actual_Hrs__c);
            System.assertEquals(0, release.User_Documentation_Actual_Hrs__c);
            
            //Loop through the change requests and Update the fields 
            for(SFDC_Change_Request__c cR : changeRequests) {
                
                //Update the CR data
                cR.Coding_Estimated_Hrs__c = 1;
                cR.Config_Estimated_Hrs__c = 1;
                cR.Design_Estimated__c = 1;
                cR.IS_QA_Estimated_Hrs__c = 1;
                cR.SOX_Certification_Required__c = Constants.YES;
            }
            
            //Update data
            update changeRequests;
            
            comments = new List<SFDC_Request_Comment__c>();
            
            //Assert for the results
            //Loop through the change requests and create the comments for each
            for(SFDC_Change_Request__c cR : changeRequests) {
                
                //add modification record in list
                comments.add(new SFDC_Request_Comment__c(SFDC_Change_Request__c = cR.Id, Activity_Type__c = 'Analysis/Design', Time__c = 1));
                comments.add(new SFDC_Request_Comment__c(SFDC_Change_Request__c = cR.Id, Activity_Type__c = 'Coding', Time__c = 1));
                comments.add(new SFDC_Request_Comment__c(SFDC_Change_Request__c = cR.Id, Activity_Type__c = 'Configuration', Time__c = 1));
                comments.add(new SFDC_Request_Comment__c(SFDC_Change_Request__c = cR.Id, Activity_Type__c = 'QA', Time__c = 1));
                comments.add(new SFDC_Request_Comment__c(SFDC_Change_Request__c = cR.Id, Activity_Type__c = 'User Documentation', Time__c = 1));
                
            }
            
            //Insert comments data
            insert comments;
            
            //Assert for the result
            release = [Select No_of_Change_Requests__c, No_of_Modifications__c, No_of_Manual_Setup_Mods__c, Coding_Estimated_Hrs__c, Coding_Actual_Hrs__c,
                            Config_Estimated_Hrs__c, Config_Actual_Hrs__c, Design_Estimated_Hrs__c, Design_Actual_Hrs__c, IS_QA_Estimated_Hrs__c, 
                            IS_QA_Actual_Hrs__c, User_Documentation_Actual_Hrs__c from SFDC_Release__c where Id =: release.Id];
            
            System.assertEquals(200, release.Coding_Estimated_Hrs__c);
            System.assertEquals(200, release.Coding_Actual_Hrs__c);
            System.assertEquals(200, release.Config_Estimated_Hrs__c);
            System.assertEquals(200, release.Config_Actual_Hrs__c);
            System.assertEquals(200, release.Design_Estimated_Hrs__c);
            System.assertEquals(400, release.Design_Actual_Hrs__c);
            System.assertEquals(200, release.IS_QA_Estimated_Hrs__c);
            System.assertEquals(200, release.IS_QA_Actual_Hrs__c);
            System.assertEquals(200, release.User_Documentation_Actual_Hrs__c);
            
            //Loop through the change requests and blankout Release            
            for(SFDC_Change_Request__c cR : changeRequests) {
                
                //Blank out Release
                cR.Release__c = null;
                cR.Release_Change_Reason__c = 'Test';
            }
            
            //Update
            update changeRequests;
            
            //Assert for the result
            release = [Select No_of_Change_Requests__c, No_of_Modifications__c, No_of_Manual_Setup_Mods__c, Coding_Estimated_Hrs__c, Coding_Actual_Hrs__c,
                            Config_Estimated_Hrs__c, Config_Actual_Hrs__c, Design_Estimated_Hrs__c, Design_Actual_Hrs__c, IS_QA_Estimated_Hrs__c, 
                            IS_QA_Actual_Hrs__c, User_Documentation_Actual_Hrs__c from SFDC_Release__c where Id =: release.Id];
            
            System.assertEquals(0, release.Coding_Estimated_Hrs__c);
            System.assertEquals(0, release.Coding_Actual_Hrs__c);
            System.assertEquals(0, release.Config_Estimated_Hrs__c);
            System.assertEquals(0, release.Config_Actual_Hrs__c);
            System.assertEquals(0, release.Design_Estimated_Hrs__c);
            System.assertEquals(0, release.Design_Actual_Hrs__c);
            System.assertEquals(0, release.IS_QA_Estimated_Hrs__c);
            System.assertEquals(0, release.IS_QA_Actual_Hrs__c);
            System.assertEquals(0, release.User_Documentation_Actual_Hrs__c);
            
            //Loop through the change requests and populate Release back
            for(SFDC_Change_Request__c cR : changeRequests) {
                
                //Blank out Release
                cR.Release__c = release.Id;
                cR.Release_Change_Reason__c = 'Test1';
            }
            
            update changeRequests;
            
            //Assert for the result
            release = [Select No_of_Change_Requests__c, No_of_Modifications__c, No_of_Manual_Setup_Mods__c, Coding_Estimated_Hrs__c, Coding_Actual_Hrs__c,
                            Config_Estimated_Hrs__c, Config_Actual_Hrs__c, Design_Estimated_Hrs__c, Design_Actual_Hrs__c, IS_QA_Estimated_Hrs__c, 
                            IS_QA_Actual_Hrs__c, User_Documentation_Actual_Hrs__c from SFDC_Release__c where Id =: release.Id];
            
            System.assertEquals(200, release.Coding_Estimated_Hrs__c);
            System.assertEquals(200, release.Coding_Actual_Hrs__c);
            System.assertEquals(200, release.Config_Estimated_Hrs__c);
            System.assertEquals(200, release.Config_Actual_Hrs__c);
            System.assertEquals(200, release.Design_Estimated_Hrs__c);
            System.assertEquals(400, release.Design_Actual_Hrs__c);
            System.assertEquals(200, release.IS_QA_Estimated_Hrs__c);
            System.assertEquals(200, release.IS_QA_Actual_Hrs__c);
            System.assertEquals(200, release.User_Documentation_Actual_Hrs__c);
            
            //Delete the change requests
            delete changeRequests;
            
            //Assert for the result
            release = [Select No_of_Change_Requests__c, No_of_Modifications__c, No_of_Manual_Setup_Mods__c, Coding_Estimated_Hrs__c, Coding_Actual_Hrs__c,
                            Config_Estimated_Hrs__c, Config_Actual_Hrs__c, Design_Estimated_Hrs__c, Design_Actual_Hrs__c, IS_QA_Estimated_Hrs__c, 
                            IS_QA_Actual_Hrs__c, User_Documentation_Actual_Hrs__c from SFDC_Release__c where Id =: release.Id];
            
            System.assertEquals(0, release.No_of_Change_Requests__c);
            
            //Undelete the record
            undelete changeRequests;
            
            //Assert for the result
            release = [Select No_of_Change_Requests__c, No_of_Modifications__c, No_of_Manual_Setup_Mods__c, Coding_Estimated_Hrs__c, Coding_Actual_Hrs__c,
                            Config_Estimated_Hrs__c, Config_Actual_Hrs__c, Design_Estimated_Hrs__c, Design_Actual_Hrs__c, IS_QA_Estimated_Hrs__c, 
                            IS_QA_Actual_Hrs__c, User_Documentation_Actual_Hrs__c from SFDC_Release__c where Id =: release.Id];
            
            System.assertEquals(changeRequests.size(), release.No_of_Change_Requests__c);
            
            //Stop test here
            Test.stopTest();
        
        }
    }
    
    //Added by Ajit Surana - 04/18/2014 - CR-20140303-4690
    //Test method assign a value to each CR based on the Story Size field. Add all values together & populate this on release object.
    static testMethod void test_rollUpStorySizeDataOnSFDCRelease(){
        
        //Insert release record
        List<SFDC_Release__c> releaseList = new List<SFDC_Release__c> ();
        
        releaseList.add(new SFDC_Release__c(Name = 'Release 1.0', Target_Release_Date__c = Date.today()));
        releaseList.add(new SFDC_Release__c (Name = 'Release 2.0', Target_Release_Date__c = Date.today()));
        insert releaseList;  
        
        //Insert test 
        IS_System__c testISRecord = new IS_System__c (Name = 'IS Record');
        insert testISRecord;
        
        Id employeeRTId = Util.RecordTypeId('Contact', 'Employee');
        
        //Insert a test contact
        Contact contact = new Contact(LastName = 'TestContact', Email = 'test@test.com', Employee_User_Record__c = UserInfo.getUserId(),
                                    RecordTypeId = employeeRTId);
        insert contact;
       
        //Insert Change Request record
        List<SFDC_Change_Request__c> changeRequestList = new List<SFDC_Change_Request__c> ();
        
        changeRequestList.add(new SFDC_Change_Request__c(Title__c = 'Test CR 1.1', IS_System__c = testISRecord.Id, Priority__c = 'A-Critical', Status__c = '03-Approved', Users_Affected__c = 'All',
                                Requested_By2__c = contact.Id, Business_Operations_Contact2__c = contact.Id , Request_Description__c = 'Testing', 
                                Business_Justification__c = 'Test'));
        changeRequestList.add(new SFDC_Change_Request__c(Title__c = 'Test CR 1.1', IS_System__c = testISRecord.Id, Priority__c = 'A-Critical', Status__c = '03-Approved', Users_Affected__c = 'All',
                                Requested_By2__c = contact.Id, Business_Operations_Contact2__c = contact.Id , Request_Description__c = 'Testing', 
                                Business_Justification__c = 'Test'));
        changeRequestList.add(new SFDC_Change_Request__c (Title__c = 'Test CR 1.1', IS_System__c = testISRecord.Id, Priority__c = 'A-Critical', Status__c = '03-Approved', Users_Affected__c = 'All',
                                Requested_By2__c = contact.Id, Business_Operations_Contact2__c = contact.Id , Request_Description__c = 'Testing', 
                                Business_Justification__c = 'Test'));
        changeRequestList.add(new SFDC_Change_Request__c(Title__c = 'Test CR 1.1', IS_System__c = testISRecord.Id, Priority__c = 'A-Critical', Status__c = '03-Approved', Users_Affected__c = 'All',
                                Requested_By2__c = contact.Id, Business_Operations_Contact2__c = contact.Id , Request_Description__c = 'Testing', 
                                Business_Justification__c = 'Test'));
        
        //Start Test from here 
        Test.startTest();
        
        insert changeRequestList;
        
        //Assert for list size
        System.assert(changeRequestList.size()>0);
        
        //Move two CR's to first Release with both Story Size field & Release Change Reason field populated
        changeRequestList[0].Release__c = releaseList[0].Id;
        changeRequestList[0].Story_Size__c = 'S';
        changeRequestList[0].Release_Change_Reason__c = 'Updating record';
        
        changeRequestList[1].Release__c = releaseList[0].Id;
        changeRequestList[1].Story_Size__c = 'M';
        changeRequestList[1].Release_Change_Reason__c = 'Testing record';
        
        changeRequestList[2].Release__c = releaseList[1].Id;
        changeRequestList[2].Story_Size__c = 'XS';
        changeRequestList[2].Release_Change_Reason__c = 'Updating record';
        
        changeRequestList[3].Release__c = releaseList[1].Id;
        changeRequestList[3].Story_Size__c = 'L';
        changeRequestList[3].Release_Change_Reason__c = 'Testing record';
        
        //Update Change Request List
        update changeRequestList;
        
        //Query to retreive SFDC Release records associated with above Change Request records
        List<SFDC_Release__c> release = [Select Id, Story_Points__c from SFDC_Release__c where Id=: releaseList[0].Id];
        
        //Assert for the result 
        System.assert(release.size()>0);
        System.assertEquals(5, release[0].Story_Points__c);
        
        //Move first 2 CR's to secon Release so that Story Size on Release 1.0 is blank
        changeRequestList[2].Release__c = releaseList[0].Id;
        changeRequestList[2].Release_Change_Reason__c = 'Reviewing';
        
        //Update list
        update changeRequestList;
        
        //Query to retreive SFDC Release records
        release = [Select Id, Story_Points__c from SFDC_Release__c where Id=: releaseList[0].Id];
        
        //Assert for the result 
        System.assert(release.size()>0);
        System.assertEquals(6, release[0].Story_Points__c);
        
        //Now remove first 2 CR's from first Release so that its Story_Points__c field value gets updated
        delete changeRequestList[0];
        delete changeRequestList[1];
        
        //Query to retreive SFDC Release records
        release = [Select Id, Story_Points__c from SFDC_Release__c where Id=: releaseList[0].Id];
        
        //Assert for the result 
        System.assert(release.size()>0);
        System.assertEquals(1, release[0].Story_Points__c);
        
        //Now remove any 2 CR's from first Release so that its Story_Points__c field value updated to 0
        delete changeRequestList[2];
        
        //Query to retreive SFDC Release records
        release = [Select Id, Story_Points__c from SFDC_Release__c where Id=: releaseList[0].Id];
        
        //Assert for the result 
        System.assert(release.size()>0);
        System.assertEquals(0, release[0].Story_Points__c);
        
        //Stop Test from here 
        Test.stopTest();
        
    }
}