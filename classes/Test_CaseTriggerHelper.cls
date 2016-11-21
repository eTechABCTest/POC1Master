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
private class Test_CaseTriggerHelper {
/**
    Purpose         :   Test class for CaseTriggerHelper
                
    Created By       :  Abhinav Sharma
    
    Created Date    :   06/20/2014
    
    Revision Log    :   v1.0 - Created - Abhinav Sharma - CR-20140417-5120
                        v1.1 - Modified - Abhinav Sharma - CR-20140618-5845 - 07/03/2014
                        v1.2 - Modified - Abhinav Sharma - CR-20140629-6015 - 07/04/2014
                        v1.3 - Modified - Abhinav Sharma - CR-20140707-6093 - 08/06/2014
                        v1.4 - Modified - Ajit Surana - CR-20140812-6973 - 09/10/2014 - Added a new test method named "test_PopulateCaseFromEmailToCase"
                        v1.5 - Modified - Abhinav Sharma - CR-20140827-7164 - 10/08/2014
                        v1.6 - Modified - Abhinav Surana - 10/15/2014 - CR-20141001-7574
                        v1.7 - Modified - Ajit Surana - 11/16/2014 - CR-20141105-7987
                        v1.8 - Modified - Ajit Surana - 11/17/2014 - CR-20141105-7992
                        v1.9 - Modified - Abhinav Sharma - 11/26/2015 - CR-20151118-9394
                        v_1.10 - Modified By - Abhinav Sharma - 12/01/2015 - CR-20150616-9006 
 *                      v_1.11 - Modified By - Mahendra Swarnakar - 12/02/2015 - CR-20151118-9397
 *                      v_1.12 - Modified By - Abhinav Sharma - 02/15/2016 - CR-20150925-9267
 *                      v_1.13 - Modified By - Abhinav Sharma - 03/31/2016 - CR-20160224-9632
 *                      v_1.14 - Modified By - Abhinav Sharma - 06/15/2016 - CR-20150202-8628
 *                      v_1.15 - Modified By - Mahedra Swarnkar - 07/25/2016 - CR-20160229-9651
 *                      v_1.16 - Modified By - Mahendra Swarnkar - 08/27/2016 - CR-20160803-10082
 *
 *  Coverage        :   v_1.14 - CaseTriggerHelper - 95%
**/
    
    //Modified by - Abhinav Sharma - CR-20150202-8628 - To refactor the existing code
    /** Description : Method to test out whether:-
     *                  a) Member_Type__c field is populating as expected or not
     *                  b) Utility method to add business days is working as expected or not.
    **/
    static testmethod void myUnitTest_1() { 
    
        //Bypass Dupeblocker
        Util.IsTest(true);
        
        //Bypassing Triggers so then test data can be created easily
        Util.byPassAllTriggers = true;
        
        //Querying Details for "Member & Employee Support" record type on Case Object
        List<RecordType> rdType = [SELECT ID FROM RecordType Where sObjectType = 'Case' AND IsActive = true 
                                                AND DeveloperName = 'Member_Employee_Support'];
                
        //Query for queue                                
        List<QueueSobject> lstQueues = [SELECT Id, queue.Name, QueueId FROM QueueSobject 
                                            WHERE SobjectType = 'Case' and queue.name= 'Events & Member Support'];
        
        //Assert for the results
        System.assert(rdType != null);
        System.assert(lstQueues != null);
        
        //List to hold the Account records
        List<Account> accounts = new List<Account>();
        
        //Create an institution
        Account acct_1 = TestUtilities.CreateNewAccount(false);
        acct_1.Description = 'Testing RIAMLargeContract Testing';
        
        //Create an institution
        Account acct_2 = TestUtilities.CreateNewAccount(false);
        acct_2.Description = 'RIAMLargeContract';
        
        //Create an institution
        Account acct_3 = TestUtilities.CreateNewAccount(false);
        acct_3.Description = 'Testing RIAM';
        
        //Populating list with account records
        accounts.add(acct_1); accounts.add(acct_2); accounts.add(acct_3);
        
        //Insert accounts
        insert accounts;
        
        //List to hold the case records
        List<Case> cases = new List<Case>();
        
        //Create a sample case record to insert and test case trigger
        Case aCase = new Case(RecordTypeId = rdType[0].Id, Origin = 'Email', Subject = 'out of office', 
                                OwnerId = lstQueues[0].QueueId, Description = 'out of office');
                                
        //Create a sample case record to insert and test case trigger
        Case aCase_1 = new Case(RecordTypeId = rdType[0].Id, Origin = 'Email', Subject = 'Test 1', 
                                Description = 'test 1', AccountId = accounts[0].Id);
                                
        //Create a sample case record to insert and test case trigger
        Case aCase_2 = new Case(RecordTypeId = rdType[0].Id, Origin = 'Phone', Subject = 'Test 2', 
                                Description = 'test 2', AccountId = accounts[1].Id);
                                
        //Create a sample case record to insert and test case trigger
        Case aCase_3 = new Case(RecordTypeId = rdType[0].Id, Origin = 'Web', Subject = 'Test 3', 
                                Description = 'test 3', AccountId = accounts[2].Id);
                                
        //Create a sample case record to insert and test case trigger
        Case aCase_4 = new Case(RecordTypeId = rdType[0].Id, Origin = 'Email', Subject = 'Test OOO', 
                                OwnerId = lstQueues[0].QueueId, Description = 'Test 4');
                                
        //Create a sample case record to insert and test case trigger
        Case aCase_5 = new Case(RecordTypeId = rdType[0].Id, Origin = 'Email', Subject = 'Test Out of Offices', 
                                OwnerId = lstQueues[0].QueueId, Description = 'Test 5');
                                
        //Create a sample case record to insert and test case trigger
        Case aCase_6 = new Case(RecordTypeId = rdType[0].Id, Origin = 'Email', Subject = 'Test 6', 
                                OwnerId = lstQueues[0].QueueId, Description = 'Test out of the Office');
                                
        //Create a sample case record to insert and test case trigger
        Case aCase_7 = new Case(RecordTypeId = rdType[0].Id, Origin = 'Email', Subject = 'Automatic reply : Test', 
                                OwnerId = lstQueues[0].QueueId, Description = 'Test 6');
        
        //Populating list with records instances
        cases.add(aCase);   cases.add(aCase_1); cases.add(aCase_2); cases.add(aCase_3);
        cases.add(aCase_4); cases.add(aCase_5); cases.add(aCase_6); cases.add(aCase_7);
        
        //Start Test from here
        Test.startTest();
        
        //Enabling triggers so then helper class written logic can be execute on DML event
        Util.byPassAllTriggers = false;
        
        //Insert Case
        insert cases;
        
        //Stop Test here
        Test.stopTest();  
        
        //Querying case records
        cases = [SELECT ID, Member_Type__c FROM Case ORDER BY Subject ASC LIMIT 5];
        System.assertEquals(4, cases.size());  
        System.assertEquals('RIAMLargeContract', cases[0].Member_Type__c);
        System.assertEquals('RIAMLargeContract', cases[1].Member_Type__c);
        System.assertEquals(null, cases[2].Member_Type__c);
        
        //Updating the existing case records
        cases[1].AccountId = accounts[2].Id;
        cases[2].AccountId = accounts[1].Id;
        
        //Update case records
        update cases;
    
        //Querying case records
        cases = [SELECT ID, Member_Type__c FROM Case ORDER BY Subject ASC LIMIT 5];
        System.assertEquals(4, cases.size());  
        System.assertEquals('RIAMLargeContract', cases[0].Member_Type__c);
        System.assertEquals(null, cases[1].Member_Type__c);
        System.assertEquals('RIAMLargeContract', cases[2].Member_Type__c);
    
        //Disable triggers execution for avoiding the limits errors
        Util.byPassAllTriggers = true;
        
        //Testing Utility method for checking that it is doing calcualtion for bussiness days correctly or not
        Date date_1 = date.newinstance(2014, 7, 04);
        Date date_2 = date_1.addDays(1);
        Date date_3 = date_2.addDays(1);
        Date date_4 = date_3.addDays(1);
        Date date_5 = date_4.addDays(1);
        Date date_6 = date_5.addDays(1);
        Date date_7 = date_6.addDays(1);
        Date date_8 = date_7.addDays(1);
        Date date_9 = date_8.addDays(1);
        
        //Calling utility method and asserting for the results
        System.assert(!Util.IsWeekendDay(date_1));
        System.assert(date.parse('07/09/2014') == Util.AddBusinessDays(date_1, 3, null));
        
        //Calling utility method and Asserting for the results
        System.assert(Util.IsWeekendDay(date_2));
        System.assert(date.parse('07/09/2014') == Util.AddBusinessDays(date_2, 3, null));
        
        //Calling utility method and Asserting for the results
        System.assert(Util.IsWeekendDay(date_3));
        System.assert(date.parse('07/09/2014') == Util.AddBusinessDays(date_3, 3, null));
        
        //Calling utility method and asserting for the results
        System.assert(!Util.IsWeekendDay(date_4));
        System.assert(date.parse('07/10/2014') == Util.AddBusinessDays(date_4, 3, null));
        
        //Calling utility method and asserting for the results
        System.assert(!Util.IsWeekendDay(date_5));
        System.assert(date.parse('07/11/2014') == Util.AddBusinessDays(date_5, 3, null));
        
        //Calling utility method and asserting for the results
        System.assert(!Util.IsWeekendDay(date_6));
        System.assert(date.parse('07/14/2014') == Util.AddBusinessDays(date_6, 3, null));
        
        //Calling utility method and asserting for the results
        System.assert(!Util.IsWeekendDay(date_7));
        System.assert(date.parse('07/15/2014') == Util.AddBusinessDays(date_7, 3, null));
        
        //Calling utility method and asserting for the results
        System.assert(!Util.IsWeekendDay(date_8));
        System.assert(date.parse('07/16/2014') == Util.AddBusinessDays(date_8, 3, null));
        
        //Calling utility method and asserting for the results
        System.assert(Util.IsWeekendDay(date_9));
        System.assert(date.parse('07/16/2014') == Util.AddBusinessDays(date_9, 3, null));
        
        //Calling utility method and asserting for the results
        System.assert(Util.IsWeekendDay(date_9));
        System.assert(date.parse('07/18/2014') == Util.AddBusinessDays(date_9, 5, null));
    }
    
    //Modified by - Abhinav Sharma - CR-20150202-8628 - To refactor the existing code
    //Modified By - Mahendra Swarnakar - 12/02/2015 - CR-20151118-9397    
    //Modified By - Abhinav Sharma - 12/01/2015 - CR-20150616-9006 
    //Modified By - Ajit Surana - 11/17/2014 - CR-20141105-7992
    //Modified By- Ajit Surana - 11/16/2014 - CR-20141105-7987
    //Added by Ajit Surana - 09/10/2014 - CR-20140812-6973
    //Modified By - Mahendra Swarnakar - 8/31/2016 - CR-20160715-10014
    /** Description : Method to test out whether case fields updates and OOO type case deletion related funcationality is
     *                  working as expected or not.
    **/
    static testmethod void test_PopulateCaseFromEmailToCase() { 
    
        //Bypass Dupeblocker
        Util.IsTest(true);
        
        //Bypassing Triggers so then test data can be created easily
        Util.byPassAllTriggers = true;
        
        //Set of record types
        Set<String> setOfRecordTypeDeveloperNames = new Set<String>();
        setOfRecordTypeDeveloperNames.add(Constants.CASE_RECORD_TYPE_MEMBER_EMPLOYEE_SUPPORT);
        setOfRecordTypeDeveloperNames.add('PT_Support_Request');
        setOfRecordTypeDeveloperNames.add(Constants.CASE_RECORD_TYPE_WEBHELP);
        setOfRecordTypeDeveloperNames.add(Constants.CASE_RECORD_TYPE_ETECH_SUPPORT);
        
        //Querying Details for "Member & Employee Support" record type on Case Object
        List<RecordType> caseRecordTypes = [SELECT ID, DeveloperName FROM RecordType 
                                            Where sObjectType = 'Case' AND IsActive = true 
                                            AND DeveloperName IN : setOfRecordTypeDeveloperNames
                                            ORDER By DeveloperName ASC];
        //Assert for the results
        System.assert(caseRecordTypes != null);
        System.assert(caseRecordTypes.size() == 4);
        System.assert(caseRecordTypes[0].DeveloperName == Constants.CASE_RECORD_TYPE_ETECH_SUPPORT);
        System.assert(caseRecordTypes[1].DeveloperName == Constants.CASE_RECORD_TYPE_MEMBER_EMPLOYEE_SUPPORT);
        System.assert(caseRecordTypes[2].DeveloperName == 'PT_Support_Request');
        System.assert(caseRecordTypes[3].DeveloperName == Constants.CASE_RECORD_TYPE_WEBHELP);
        
        //Query for queue                                
        List<QueueSobject> queueList = [SELECT Id, queue.DeveloperName, QueueId FROM QueueSobject 
                                            WHERE SobjectType = 'Case' AND queue.DeveloperName != null 
                                            AND (
                                            queue.DeveloperName =: Constants.QUEUE_NAME_EVENTS_MEMBER_SUPPORT
                                            OR
                                            queue.DeveloperName =: Constants.QUEUE_NAME_WEBHELP
                                            OR
                                            queue.DeveloperName =: Constants.QUEUE_NAME_DATA_INTEGRATIONS
                                            )
                                       ORDER By queue.DeveloperName ASC
                                       ];
        //Assert for the results
        System.assert(queueList != null);
        System.assertEquals(queueList[0].queue.DeveloperName, Constants.QUEUE_NAME_DATA_INTEGRATIONS);
        System.assertEquals(queueList[1].queue.DeveloperName, Constants.QUEUE_NAME_EVENTS_MEMBER_SUPPORT);
        System.assertEquals(queueList[2].queue.DeveloperName, Constants.QUEUE_NAME_WEBHELP);
        
        //List to hold the case records
        List<Case> cases = new List<Case>();
        
        //Create a sample case record to insert
        Case aCase_1 = new Case(RecordTypeId = caseRecordTypes[1].Id, Origin = Constants.CASE_ORIGIN_MEETINGS, 
                                Subject = 'Test Record 1', 
                                OwnerId = queueList[0].QueueId, Description = 'Testing Meetings W2C Email');
                                
        //Create a sample case record to insert
        Case aCase_2 = new Case(RecordTypeId = caseRecordTypes[1].Id, Origin = Constants.CASE_ORIGIN_WEBCONFERENCES, 
                                Subject = 'Test Record 2', 
                                Description = 'Testing Webconferences W2C Email');
                                
        //Create a sample case record to insert
        Case aCase_3 = new Case(RecordTypeId = caseRecordTypes[1].Id, Origin = Constants.CASE_ORIGIN_CONFERENCE_ROOM_REQUESTS, 
                                Subject = 'Test Record 3', 
                                Description = 'Testing ConferenceRoomRequests W2C Email');
                                
        //Create a sample case record to insert
        Case aCase_4 = new Case(RecordTypeId = caseRecordTypes[1].Id, Origin = Constants.CASE_ORIGIN_TRAVEL, 
                                Subject = 'Test Record 4', 
                                Description = 'Testing Travel EmailW2C Email');
                                
        //Create a sample case record to insert
        Case aCase_5 = new Case(RecordTypeId = caseRecordTypes[1].Id, Origin = Constants.CASE_ORIGIN_VOICE_MAIL, 
                                Subject = 'Test Record 5', 
                                OwnerId = queueList[0].QueueId, Description = 'Testing Voice Mail W2C Email');
                                
        //Create a sample case record to insert
        Case aCase_6 = new Case(RecordTypeId = caseRecordTypes[1].Id, Origin = Constants.CASE_ORIGIN_ADVISORY, 
                                Subject = 'Test Record 6', 
                                OwnerId = queueList[0].QueueId, Description = 'Testing Advisory W2C Email');
        
        //Create a sample case record to insert
        Case aCase_7 = new Case(RecordTypeId = caseRecordTypes[1].Id, Origin = Constants.CASE_ORIGIN_EAB, 
                                Subject = 'Test Record 7', 
                                OwnerId = queueList[0].QueueId, Description = 'Testing EAB W2C Email');
        
        //Create a sample case record to insert
        Case aCase_8 = new Case(RecordTypeId = caseRecordTypes[1].Id, Origin = Constants.CASE_ORIGIN_ABI, 
                                Subject = 'Test Record 8', 
                                OwnerId = queueList[0].QueueId, Description = 'Testing ABI W2C Email');
        
        //Create a sample case record to insert
        Case aCase_9 = new Case(RecordTypeId = caseRecordTypes[0].Id, Origin = Constants.CASE_ORIGIN_EMAIL_TO_CASE_DATA_INTEGRATIONS, 
                                Subject = 'Test Record 9', 
                                OwnerId = queueList[0].QueueId, Description = 'Testing Data Integration W2C Email');
        
        //Create a sample case record to insert
        Case aCase_10 = new Case(RecordTypeId = caseRecordTypes[1].Id, Origin = Constants.CASE_ORIGIN_EAB_MEETINGS, 
                                Subject = 'Test Record 10', 
                                OwnerId = queueList[0].QueueId, Description = 'Testing EAB Meetings W2C Email');
        
        //Create a sample case record to insert
        Case aCase_11 = new Case(RecordTypeId = caseRecordTypes[1].Id, Origin = Constants.CASE_ORIGIN_EAB_MEETINGS, 
                                Subject = 'Test Record 11', 
                                OwnerId = queueList[0].QueueId, Description = 'Testing VoiceMail W2C Email 1',
                                SuppliedEmail = 'Mailer-daemon@advisory.com');
        
        //Create a sample case record to insert
        Case aCase_12 = new Case(RecordTypeId = caseRecordTypes[1].Id, Origin = 'Voice Mail', Subject = 'Test Record 12', 
                                OwnerId = queueList[0].QueueId, Description = 'Testing VoiceMail W2C Email 2',
                                SuppliedEmail = 'spamfilter@advisory.com');
        
        //Create a sample case record to insert
        Case aCase_13 = new Case(RecordTypeId = caseRecordTypes[3].Id, Origin = 'Voice Mail', Subject = 'Test Record 9 ooo', 
                                OwnerId = queueList[0].QueueId, Description = 'Testing VoiceMail W2C Email 3');
        
        //Create a sample case record to insert
        Case aCase_14 = new Case(RecordTypeId = caseRecordTypes[2].Id,
                                 Origin = 'Email', Subject = 'Test PT Record', 
                                 Description = 'Testing PT W2C Email');
        
        //Populating list with records instances
        cases.add(aCase_1);
        cases.add(aCase_2); cases.add(aCase_3);
        cases.add(aCase_4); cases.add(aCase_5);
        cases.add(aCase_6); cases.add(aCase_7);
        cases.add(aCase_8); cases.add(aCase_9);
        cases.add(aCase_10);
        cases.add(aCase_11); cases.add(aCase_12);
        cases.add(aCase_13); cases.add(aCase_14);
        
        //Start Test from here
        Test.startTest();
        
        //Enabling triggers so then helper class written logic can be execute on DML event
        Util.byPassAllTriggers = false;
        
        //Insert Case
        insert cases;
        
        //Stop Test here
        Test.stopTest();  
        
        //Querying case records
        cases = [SELECT ID, Origin, Type, Subject, OwnerId FROM Case ORDER By Subject ASC];
        
        //Asserts for getting correct results
        System.assertEquals(11, cases.size()); 
        
        System.assertEquals(Constants.EMAIL, cases[0].Origin);
        System.assertEquals(null, cases[0].Type);
        System.assertEquals('Test PT Record', cases[0].Subject);
        
        System.assertEquals(Constants.EMAIL, cases[1].Origin);
        System.assertEquals(Constants.CASE_ORIGIN_MEETINGS, cases[1].Type);
        System.assertEquals('Test Record 1', cases[1].Subject);
        System.assertEquals(queueList[1].QueueId, cases[1].OwnerID);
        
        System.assertEquals(Constants.CASE_ORIGIN_EAB_MEETINGS, cases[2].Origin);
        System.assertEquals(Constants.CASE_ORIGIN_MEETINGS, cases[2].Type);
        System.assertEquals('Test Record 10', cases[2].Subject);
        System.assertEquals(queueList[1].QueueId, cases[1].OwnerID);
        
        System.assertEquals(Constants.EMAIL, cases[3].Origin);
        System.assertEquals(Constants.CASE_ORIGIN_WEBCONFERENCES, cases[3].Type);
        System.assertEquals('Test Record 2', cases[3].Subject);
        System.assertEquals(queueList[1].QueueId, cases[1].OwnerID);
        
        System.assertEquals(Constants.EMAIL, cases[4].Origin);
        System.assertEquals(Constants.CASE_ORIGIN_CONFERENCE_ROOM_REQUESTS, cases[4].Type);
        System.assertEquals('Test Record 3', cases[4].Subject);
        System.assertEquals(queueList[1].QueueId, cases[1].OwnerID);
        
        System.assertEquals(Constants.EMAIL, cases[5].Origin);
        System.assertEquals(Constants.CASE_ORIGIN_TRAVEL, cases[5].Type);
        System.assertEquals('Test Record 4', cases[5].Subject);
        System.assertEquals(queueList[1].QueueId, cases[1].OwnerID);
        
        System.assertEquals(Constants.CASE_ORIGIN_VOICE_MAIL, cases[6].Origin);
        System.assertEquals(Constants.CASE_ORIGIN_VOICE_MAIL, cases[6].Type);
        System.assertEquals('Test Record 5', cases[6].Subject);
        System.assertEquals(queueList[1].QueueId, cases[1].OwnerID);
        
        System.assertEquals(Constants.EMAIL, cases[7].Origin);
        System.assertEquals(Constants.CASE_ORIGIN_ADVISORY, cases[7].Type);
        System.assertEquals('Test Record 6', cases[7].Subject);
        System.assertEquals(queueList[1].QueueId, cases[1].OwnerID);
        
        System.assertEquals(Constants.EMAIL, cases[8].Origin);
        System.assertEquals(Constants.CASE_ORIGIN_EAB, cases[8].Type);
        System.assertEquals('Test Record 7', cases[8].Subject);
        System.assertEquals(queueList[1].QueueId, cases[1].OwnerID);
        
        System.assertEquals(Constants.EMAIL, cases[9].Origin);
        System.assertEquals(Constants.CASE_ORIGIN_ABI, cases[9].Type);
        System.assertEquals('Test Record 8', cases[9].Subject);
        System.assertEquals(queueList[1].QueueId, cases[1].OwnerID);
        
        System.assertEquals(Constants.EMAIL, cases[10].Origin);
        System.assertEquals(Constants.CASE_ORIGIN_DATA_INTEGRATIONS, cases[10].Type);
        System.assertEquals('Test Record 9', cases[10].Subject);
    }
    
    //Modified by - Abhinav Sharma - CR-20150202-8628 - To refactor the existing code
    //Modified By - Abhinav Sharma - 11/26/2015 - CR-20151118-9394
    //Added by Abhinav Surana - 10/15/2014 - CR-20141001-7574
    /** Description : Method to test out the functionality of task records creation on insert of a case record of 
     * "Syndicated Services" record type.
    **/
    static testmethod void test_manageTasksForSyndicatedServices() { 
    
        //Bypass Dupeblocker
        Util.IsTest(true);
        
        //Bypassing Triggers so then test data can be created easily
        Util.byPassAllTriggers = true;
        
        //Querying Details for "Member & Employee Support" record type on Case Object
        List<RecordType> rdType = [SELECT ID FROM RecordType Where sObjectType = 'Case' AND IsActive = true 
                                                AND DeveloperName = 'Syndicated_Services'];
                
        //Query for queue                                
        List<QueueSobject> lstQueues = [SELECT Id, queue.Name, QueueId FROM QueueSobject 
                                            WHERE SobjectType = 'Case' and queue.name= 'Syndicated Services'];
        
        //Assert for the results
        System.assert(rdType != null);
        System.assert(lstQueues != null);
        
        //Record Type Setting list
        list<RecordType_Setting__c> listRTSettings = new list<RecordType_Setting__c>();

        //Record Type Setting instance
        RecordType_Setting__c rs = new RecordType_Setting__c(Name = 'Test1', Name__c = 'Syndicated Services', 
                                                                SFID__c = rdType[0].Id, SObjectType__c = 'Case');
        listRTSettings.add(rs);
        insert listRTSettings;
            
        //Profile    
        Profile p = [SELECT Id FROM Profile WHERE Name = 'System Administrator']; 
        
        //List to hold the users
        List<User> users = new List<User>();
      
        //User 1
        User user_1 = new User(Alias = 'standt', Email='standarduser@testorg.com', 
                            EmailEncodingKey='UTF-8', LastName='Testing1', LanguageLocaleKey='en_US', 
                            LocaleSidKey='en_US', ProfileId = p.Id, department = 'STP',
                            TimeZoneSidKey = 'GMT', UserName=Math.random() + '@test.com');
                            
        //User 2
        User user_2 = new User(Alias = 'standt', Email='standarduser@testorg1.com', 
                            EmailEncodingKey='UTF-8', LastName='Testing2', LanguageLocaleKey='en_US', 
                            LocaleSidKey='en_US', ProfileId = p.Id, department = 'STP',
                            TimeZoneSidKey='GMT', UserName=Math.random() + '@test.com');
                            
        //Populating list with the user instance
        users.add(user_1); users.add(user_2);
        insert users;

        //List to hold the case records
        List<Case> cases = new List<Case>();
        
        //List of tasks
        List<Task> tasks = new List<Task>();
        
        //Switching the context to User 1
        System.runAs(user_1) {
            
            //Create a sample case record to insert
            Case aCase_1 = new Case(RecordTypeId = rdType[0].Id, Origin = 'Meetings', Subject = 'Test Record 1', 
                                    OwnerId = lstQueues[0].QueueId, Description = 'Testing Meetings W2C Email', 
                                    Topic_Unknown__c = true, Date_of_Presentation__c = System.today(),
                                    Status = 'Test');
                                    
            //Create a sample case record to insert
            Case aCase_2 = new Case(RecordTypeId = rdType[0].Id, Origin = 'Webconferences', Subject = 'Test Record 2', 
                                    Description = 'Testing Webconferences W2C Email', Topic_Unknown__c = true,
                                    Date_of_Presentation__c = System.today(),
                                    Status = 'Tentative');
            
            //Populating list with records instances
            cases.add(aCase_1);   cases.add(aCase_2);
        
            //Start test from here
            Test.startTest();
            
            //Enabling triggers so then helper class written logic can be execute on DML event
            Util.byPassAllTriggers = false;
            
            //Insert Case
            insert cases;
            
            //Disable triggers
            Util.byPassAllTriggers = true;
            
            //Stop Test here
            Test.stopTest();
            
            //Querying case records
            cases = [SELECT ID, Hold_Expires__c, Date_of_Presentation__c FROM Case ORDER By Subject ASC LIMIT 3];
            
            //Asserts for getting correct results
            System.assertEquals(2, cases.size());
            System.assertEquals(null, cases[0].Hold_Expires__c);
            System.assertEquals(Util.AddBusinessDays(cases[1].Date_of_Presentation__c, 10, null), cases[1].Hold_Expires__c);
            
            //Query for the tasks records
            tasks = [SELECT ID, WhatId, Subject, OwnerId FROM Task WHERE WhatID IN : cases ORDER BY Subject ASC];
            
            //Asserts for getting correct results
            System.assertEquals(6, tasks.size());  
            System.assertEquals(cases[1].Id, tasks[0].WhatId);
            System.assertEquals(cases[1].Id, tasks[1].WhatId);
            System.assertEquals(cases[1].Id, tasks[2].WhatId);
            System.assertEquals(cases[1].Id, tasks[3].WhatId);
            System.assertEquals(cases[1].Id, tasks[4].WhatId);
            System.assertEquals(cases[1].Id, tasks[5].WhatId);
            System.assertEquals('3 day-out check-in call completed', tasks[0].Subject);
            System.assertEquals('Calendars held', tasks[1].Subject);
            System.assertEquals('Confirmation emailed and added to calendars', tasks[2].Subject);
            System.assertEquals('Logistics outreach completed', tasks[3].Subject);
            System.assertEquals('Materials sent to member', tasks[4].Subject);
            System.assertEquals('Presite call scheduled', tasks[5].Subject);
            System.assertEquals(users[0].Id,tasks[0].OwnerId);
            System.assertEquals(users[0].Id, tasks[1].OwnerId);
            System.assertEquals(users[0].Id, tasks[2].OwnerId);
            System.assertEquals(users[0].Id, tasks[3].OwnerId);
            System.assertEquals(users[0].Id, tasks[4].OwnerId);
            System.assertEquals(users[0].Id, tasks[5].OwnerId);
        }
        
        //Updating the case Owner
        cases[0].OwnerId = users[1].Id;
        cases[1].OwnerId = lstQueues[0].QueueId;
        cases[0].Status = 'Tentative';
        cases[1].Date_of_Presentation__c = null;                       
                                
        //Enabling triggers so then helper class written logic can be execute on DML event
        Util.byPassAllTriggers = false;
        
        //Updating cases
        update cases;
        
        //Disable triggers
        Util.byPassAllTriggers = true;
        
        //Querying case records
        cases = [SELECT ID, Hold_Expires__c, Date_of_Presentation__c FROM Case ORDER By Subject ASC LIMIT 3];
            
        //Asserts for getting correct results
        System.assertEquals(2, cases.size());
        System.assertNotEquals(null, cases[0].Hold_Expires__c);
        System.assertEquals(null, cases[1].Hold_Expires__c);
            
        //List of tasks
        tasks = new List<Task>();
        
        //Query for the tasks records
        tasks = [SELECT ID, WhatId, Subject, OwnerId FROM Task WHERE WhatID IN : cases ORDER BY Subject ASC];
        
        //Asserts for getting correct results
        System.assertEquals(6, tasks.size());  
        System.assertEquals(cases[0].Id, tasks[0].WhatId);
        System.assertEquals(cases[0].Id, tasks[1].WhatId);
        System.assertEquals(cases[0].Id, tasks[2].WhatId);
        System.assertEquals(cases[0].Id, tasks[3].WhatId);
        System.assertEquals(cases[0].Id, tasks[4].WhatId);
        System.assertEquals(cases[0].Id, tasks[5].WhatId);
        System.assertEquals('3 day-out check-in call completed', tasks[0].Subject);
        System.assertEquals('Calendars held', tasks[1].Subject);
        System.assertEquals('Confirmation emailed and added to calendars', tasks[2].Subject);
        System.assertEquals('Logistics outreach completed', tasks[3].Subject);
        System.assertEquals('Materials sent to member', tasks[4].Subject);
        System.assertEquals('Presite call scheduled', tasks[5].Subject);
        System.assertEquals(users[1].Id,tasks[0].OwnerId);
        System.assertEquals(users[1].Id, tasks[1].OwnerId);
        System.assertEquals(users[1].Id, tasks[2].OwnerId);
        System.assertEquals(users[1].Id, tasks[3].OwnerId);
        System.assertEquals(users[1].Id, tasks[4].OwnerId);
        System.assertEquals(users[1].Id, tasks[5].OwnerId);
    
        //Updating the case Owner
        cases[0].OwnerId = users[0].Id;
        cases[0].Date_of_Presentation__c = System.today().addDays(2);                  
        
        //Enabling triggers so then helper class written logic can be execute on DML event
        Util.byPassAllTriggers = false;
        
        //Updating cases
        update cases;
        Util.byPassAllTriggers = true;
        
        //Querying case records
        cases = [SELECT ID, Hold_Expires__c, Date_of_Presentation__c FROM Case ORDER By Subject ASC LIMIT 3];
            
        //Asserts for getting correct results
        System.assertEquals(2, cases.size());
        System.assertNotEquals(null, cases[0].Hold_Expires__c);
        System.assertEquals(null, cases[1].Hold_Expires__c);
        
        //List of tasks
        tasks = new List<Task>();
        
        //Query for the tasks records
        tasks = [SELECT ID, WhatId, Subject, OwnerId FROM Task WHERE WhatID IN : cases ORDER BY Subject ASC];
        
        //Asserts for getting correct results
        System.assertEquals(6, tasks.size());  
        System.assertEquals(cases[0].Id, tasks[0].WhatId);
        System.assertEquals(cases[0].Id, tasks[1].WhatId);
        System.assertEquals(cases[0].Id, tasks[2].WhatId);
        System.assertEquals(cases[0].Id, tasks[3].WhatId);
        System.assertEquals(cases[0].Id, tasks[4].WhatId);
        System.assertEquals(cases[0].Id, tasks[5].WhatId);
        System.assertEquals('3 day-out check-in call completed', tasks[0].Subject);
        System.assertEquals('Calendars held', tasks[1].Subject);
        System.assertEquals('Confirmation emailed and added to calendars', tasks[2].Subject);
        System.assertEquals('Logistics outreach completed', tasks[3].Subject);
        System.assertEquals('Materials sent to member', tasks[4].Subject);
        System.assertEquals('Presite call scheduled', tasks[5].Subject);
        System.assertEquals(users[0].Id,tasks[0].OwnerId);
        System.assertEquals(users[0].Id, tasks[1].OwnerId);
        System.assertEquals(users[0].Id, tasks[2].OwnerId);
        System.assertEquals(users[0].Id, tasks[3].OwnerId);
        System.assertEquals(users[0].Id, tasks[4].OwnerId);
        System.assertEquals(users[0].Id, tasks[5].OwnerId);
    }
    
    //Modified By - Mahedra Swarnkar - 07/25/2016 - CR-20160229-9651
    //Modified by - Abhinav Sharma - CR-20150202-8628 - To refactor the existing code
    //Added By - Abhinav Sharma - 02/15/2016 - CR-20150925-9267
    /** Description : Method to test out "New_Member_Programs_RI__c" field is populating as expected or not.
    **/
    static testmethod void test_CasebeforeEventsLogics() { 
    
        //Bypass Dupeblocker
        Util.IsTest(true);
        
        //Bypassing Triggers so then test data can be created easily
        Util.byPassAllTriggers = true;
        
        //List to hold the Account records
        List<Account> accounts = new List<Account>();
        
        //Create an institution
        Account acct_1 = TestUtilities.CreateNewAccount(false);
        Account acct_2 = TestUtilities.CreateNewAccount(false);
        
        //Populating list with account records
        accounts.add(acct_1); accounts.add(acct_2); 
        
        //Insert accounts
        insert accounts;
        
        //Assert for the results
        System.assert(accounts != null);
        System.assert(accounts.size() == 2);     
        
        //Create program data
        List<Program__c> programs = new List<Program__c>();
        Program__c program_1 = new Program__c(Name = 'testName 1', Program_Acronym__c = 'testCode', 
                                              Business_line__c = 'RI', Status__c = 'Active');
        Program__c program_2 = new Program__c(Name = 'testName 2', Program_Acronym__c = 'testing', 
                                              Business_line__c = 'PT', Status__c = 'Active');
        Program__c program_3 = new Program__c(Name = 'testName 3', Program_Acronym__c = 'testing TD', 
                                              Business_line__c = 'TD', Status__c = 'Active');
        programs.add(program_1); programs.add(program_2); programs.add(program_3);
        insert programs;
        
        //Assert for the results
        System.assert(programs != null);
        System.assert(programs.size() == 3);
        
        //create Contract ABC test data
        List<Contract__c> contracts = new List<Contract__c>();
        Contract__c contractABC_1 = new Contract__c(Payer_Account__c = accounts[0].Id, Type__c = 'NBB', 
                                                    Program__c = programs[0].Id, Start__c = System.today().addDays(-5),
                                                    End__c = System.today().addDays(5));
        Contract__c contractABC_2 = new Contract__c(Payer_Account__c = accounts[0].Id, Type__c = 'NBB', 
                                                    Program__c = programs[1].Id, Start__c = System.today().addDays(-5),
                                                    End__c = System.today().addDays(7));
        Contract__c contractABC_3 = new Contract__c(Payer_Account__c = accounts[0].Id, Type__c = 'NBB', 
                                                    Program__c = programs[2].Id, Start__c = System.today().addDays(-5),
                                                    End__c = System.today().addDays(7));
        contracts.add(contractABC_1); contracts.add(contractABC_2); contracts.add(contractABC_3);
        insert contracts;
        
        //Assert for results
        System.assert(contracts != null);
        System.assert(contracts.size() == 3);
        
        //Querying Details for "Member & Employee Support" record type on Case Object
        List<RecordType> caseRdTypes = [SELECT ID, DeveloperName FROM RecordType 
                                        Where sObjectType = 'Case' 
                                        AND IsActive = true 
                                        AND DeveloperName IN ('Expert_Center', 'WebHelp' , 'Talent_Development')
                                        ORDER By DeveloperName ASC];
                
        //Assert for the results
        System.assert(caseRdTypes != null);
        System.assert(caseRdTypes.size() == 3);
        System.assert(caseRdTypes[0].DeveloperName == 'Expert_Center');
        System.assert(caseRdTypes[1].DeveloperName == 'Talent_Development');
        System.assert(caseRdTypes[2].DeveloperName == 'WebHelp');
        
        //Record Type Setting list
        list<RecordType_Setting__c> listRTSettings = new list<RecordType_Setting__c>();

        //Record Type Setting instance
        RecordType_Setting__c rs_1 = new RecordType_Setting__c(Name = 'Test1', 
                                                             Name__c = System.Label.CASE_NEW_MEMBER_RECORD_TYPE, 
                                                             SFID__c = caseRdTypes[0].Id, SObjectType__c = 'Case');
        RecordType_Setting__c rs_2 = new RecordType_Setting__c(Name = 'Test2', 
                                                             Name__c = 'Webhelp', 
                                                             SFID__c = caseRdTypes[2].Id, SObjectType__c = 'Case');
        RecordType_Setting__c rs_3 = new RecordType_Setting__c(Name = 'Test3', 
                                                             Name__c = 'Talent Development', 
                                                             SFID__c = caseRdTypes[1].Id, SObjectType__c = 'Case');
        listRTSettings.add(rs_1); listRTSettings.add(rs_2); listRTSettings.add(rs_3);
        insert listRTSettings;
        
        //List to hold the case records
        List<Case> cases = new List<Case>();
        
        //Create a sample case record to insert and test case trigger
        Case aCase_1 = new Case(RecordTypeId = caseRdTypes[0].Id, Origin = 'ABC1', Subject = 'Test', 
                                Description = 'Test', AccountId = accounts[0].Id);
                                
        //Create a sample case record to insert and test case trigger
        Case aCase_2 = new Case(RecordTypeId = caseRdTypes[2].Id, Origin = 'Email', Subject = 'Test 1', 
                                Description = 'test 1', AccountId = accounts[1].Id);
        
        //Create a sample case record to insert and test case trigger
        Case aCase_3 = new Case(RecordTypeId = caseRdTypes[1].Id, Origin = 'ABC2', Subject = 'Test 2', 
                                Description = 'test 2', AccountId = accounts[0].Id);
        
        //Populating list with case records
        cases.add(aCase_1); cases.add(aCase_2); cases.add(aCase_3); 
        
        //Start test from here
        Test.startTest();
        
        //Enabling triggers
        Util.byPassAllTriggers = false;
       
        //Insert cases
        insert cases;
        
        //Assert for the results
        System.assert(cases != null);
        System.assert(cases.size() == 3);
        
        //Asserting for the results
        cases = [SELECT ID, Origin, New_Member_Programs_RI__c, New_Member_Programs_TD__c FROM Case ORDER BY Origin ASC];
        
        //Assert for the results
        System.assert(cases != null);
        System.assert(cases.size() == 3);
        System.assertEquals('Email', cases[0].Origin);
        System.assertEquals(null, cases[0].New_Member_Programs_RI__c);
        System.assertEquals('ABC1', cases[1].Origin);
        System.assertEquals('testCode', cases[1].New_Member_Programs_RI__c);
        System.assertEquals('ABC2', cases[2].Origin);
        System.assertEquals('testing TD', cases[2].New_Member_Programs_TD__c);
        
        //Bypassing triggers
        Util.byPassAllTriggers = true;
        
        //Updating contracts
        contracts[1].Program__c = programs[0].Id;
        update contracts;
        
        //Changing fields values on the Cases
        cases[1].New_Member_Programs_RI__c = null;
        cases[0].New_Member_Programs_RI__c = 'Test';
        
        //Enabling triggers
        Util.byPassAllTriggers = false;
        
        //Update cases
        update cases;
        
        //Assert for the results
        System.assert(cases != null);
        System.assert(cases.size() == 3);
        
        //Asserting for the results
        cases = [SELECT ID, Origin, AccountID, New_Member_Programs_RI__c FROM Case ORDER BY Origin ASC];
            
        //Assert for the results
        System.assert(cases != null);
        System.assert(cases.size() == 3);
        System.assertEquals('Email', cases[0].Origin);
        System.assertEquals(null, cases[0].New_Member_Programs_RI__c);
        System.assertEquals('ABC1', cases[1].Origin);
        System.assertEquals('testCode,testCode', cases[1].New_Member_Programs_RI__c);
                
        //test will stop here
        Test.stopTest();
    }
    
    //Modified by - Abhinav Sharma - CR-20150202-8628 - To refactor the existing code
    //Added By - Abhinav Sharma - 03/31/2016 - CR-20160224-9632
    /** Description : Few fields on case object can not be changed directly without using custom detail page button and this
     *                  test method is test out/validate the same.
    **/
    static testmethod void test_CasebeforeEventsLogics2() { 
        
        //Bypass Dupeblocker
        Util.IsTest(true);
        
        //Bypassing Triggers so then test data can be created easily
        Util.byPassAllTriggers = true;
        
        //Flag for triggers: this is just a test, don't do crazy things.
        Util.isTesting = true;
        
        //Create test data for the Sync Fields custom setting that syncs Mem Support -> Case fields
        TestUtilities.createSyncFields();
        
        //Get profile list
        List<Profile> testProfile = [Select Id, Name from Profile where Name = 'System Administrator'];
        
        //Assert for results
        System.assert(testProfile != null);
        System.assert(testProfile.size()>0);
                
        //Test User Create
        List<User> userList = new List<User>();
        
        //Adding user record instances into the list
        userList.add(new User(Username= Math.random()+'@abc.com', LastName='Test User1', FirstName='Test1', Email='testuser1@test.com',
                            Alias='Test1', EmailEncodingKey='UTF-8', languagelocalekey='en_US', ProfileId=testProfile[0].Id, 
                            timezonesidkey='America/Los_Angeles', localesidkey='en_US', EmployeeNumber = '121212123', IsActive = true));
        userList.add(new User(Username= Math.random()+'@abc.com', LastName='Test User2', FirstName='Test2', Email='testuser2@test.com',
                            Alias='Test2', EmailEncodingKey='UTF-8', languagelocalekey='en_US', ProfileId=testProfile[0].Id, 
                            timezonesidkey='America/Los_Angeles', localesidkey='en_US', EmployeeNumber = '121212124', IsActive = true));

        insert userList;
        
        //Asserting for the results
        System.assert(userList != null);
        System.assert(userList.size() == 2);
        
        //Run as user
        System.runAs(userList[0]) {
            
            //List to hold the Account records
            List<Account> accounts = new List<Account>();
        
            //Create an institution
            Account acct_1 = TestUtilities.CreateNewAccount(false);
            
            //Populating list with account records
            accounts.add(acct_1); 
            
            //Insert accounts
            insert accounts;
            
            //Assert for the results
            System.assert(accounts != null);
            System.assert(accounts.size() == 1);
            
            //Contact
            Contact con = TestUtilities.CreateNewContact(false);
            insert con;
            System.assert(con != null);
            
            //Querying Details for "Member & Employee Support" record type on Case Object
            List<RecordType> caseRdTypes = [SELECT ID, DeveloperName FROM RecordType 
                                            Where sObjectType = 'Case' 
                                            AND IsActive = true 
                                            AND DeveloperName IN ('PT_Support_Request', 'IRC_Request', 'International')
                                            ORDER By DeveloperName ASC];
                    
            //Assert for the results
            System.assert(caseRdTypes != null);
            System.assert(caseRdTypes.size() == 3);
            System.assert(caseRdTypes[0].DeveloperName == 'International');
            System.assert(caseRdTypes[1].DeveloperName == 'IRC_Request');
            System.assert(caseRdTypes[2].DeveloperName == 'PT_Support_Request');
            
            //Record Type Setting list
            list<RecordType_Setting__c> listRTSettings = new list<RecordType_Setting__c>();
    
            //Record Type Setting instance
            RecordType_Setting__c rs_1 = new RecordType_Setting__c(Name = 'Test1', 
                                                                 Name__c = 'PT Support Request', 
                                                                 SFID__c = caseRdTypes[2].Id, SObjectType__c = 'Case');
            RecordType_Setting__c rs_2 = new RecordType_Setting__c(Name = 'Test2', 
                                                                 Name__c = 'IRC Request', 
                                                                 SFID__c = caseRdTypes[1].Id, SObjectType__c = 'Case');
            RecordType_Setting__c rs_3 = new RecordType_Setting__c(Name = 'Test3', 
                                                                 Name__c = 'International', 
                                                                 SFID__c = caseRdTypes[0].Id, SObjectType__c = 'Case');
            listRTSettings.add(rs_1);
            listRTSettings.add(rs_2);
            listRTSettings.add(rs_3);
            insert listRTSettings;
            
            //Assert for the results
            System.assert(listRTSettings != null);
            System.assert(listRTSettings.size() == 3);
            
            //Useful collections
            map<string, string> mapStatusesMStoCase = CaseTriggerHelper.memSupportToCaseStatus_SupportRT_Map;
            map<string, string> mapStatusePTLoadCaseToMS = CaseTriggerHelper.caseToMemSupportStatus_DataLoadRT_Map;
            map<string, string> mapStatusePTLoadMStoCase = CaseTriggerHelper.memSupportToCaseStatus_DataLoadRT_Map;
            map<string, string> mapPriorityMStoCase = CaseTriggerHelper.memSupportToCasePriority_Map;
            
            //list of cases
            List<Case> cases = new List<Case>();
            
            //Create a sample case record to insert and test case trigger
            Case aCase_1 = new Case(RecordTypeId = caseRdTypes[2].Id, Origin = 'ABC1', Subject = 'Test1', 
                                    Description = 'Test1', AccountId = accounts[0].Id);
            Case aCase_2 = new Case(RecordTypeId = caseRdTypes[1].Id, Origin = 'ABC2', Subject = 'Test2', 
                                    Description = 'Test2', AccountId = accounts[0].Id);
            Case aCase_3 = new Case(RecordTypeId = caseRdTypes[0].Id, Origin = 'ABC3', Subject = 'Test3',
                                    Description = 'Test3', AccountId = accounts[0].Id);
            
            //Populating list with case records
            cases.add(aCase_1);
            cases.add(aCase_2);
            cases.add(aCase_3);
            
            //Start test from here
            Test.startTest();
            
            //Enabling triggers
            Util.byPassAllTriggers = false;
           
            //Insert cases
            insert cases;
            
            //Assert for the results
            System.assert(cases != null);
            System.assert(cases.size() == 3);
            
            //Asserting for the results
            cases = [SELECT ID, Status, Button_Used__c FROM Case ORDER BY Origin ASC LIMIT 5];
                
            //Assert for the results
            System.assert(cases != null);
            System.assert(cases.size() == 3);
            System.assert(cases[0].Status == '01-New');
            System.assert(cases[0].Button_Used__c == false);
            
            //Stop test here
            Test.stopTest();
            
            //Enabling triggers
            Util.byPassAllTriggers = false;
            
            //Making a try to update the status value
            try {
                
                //Setting the flags
                CaseTriggerHelper.IS_ALREADY_EXECUTED_ONCE = false;
                CaseTriggerHelper.IS_UPDATE_HAPPENS_ON_INSERT_EVENT = false; 
                
                //Updating cases
                cases[0].Status = '10-In Progress';
                cases[0].OwnerId = userList[1].Id;
                cases[0].Tier_I_Support_Analyst__c = userList[1].Id;
                update cases;
                
            } catch(Exception ex) {
                System.assert(ex.getMessage().contains(System.Label.ERROR_CASE_DIRECT_FIELDS_CHANGES));
            }
            
            //Updating case with field values
            cases[0].Member_Facing_Resolution_Summary__c = 'Test';
            cases[0].Status = '90-Closed';
            cases[0].ContactId = con.Id;
            update cases[0];
        }            
    }
    
    //Modified by - Abhinav Sharma - CR-20150202-8628 - To refactor the existing code
    /** Description : Method to test :- 
     *               a) Case contains a deadline date < 5 days in the future and no Deadline Reason, watch it fail
     *               b) Case contains a deadline date on a black out date, watch it fail
     *               c) Otherwise pass
    **/ 
    static testmethod void testDeadlineValidationRule() { 
        
        //Bypass Dupeblocker
        Util.IsTest(true);
        Util.BypassAllTriggers = true;
        Util.isTesting = true;
        
        //Universal start date
        Date universalStartDate = date.newInstance(0001, 1, 1); 
        
        //Fetching expert center record type
        Id expertCentersRTTypeId = Util.RecordTypeId(Constants.CASE_OBJECT, TestUtilities.INTERNATIONAL_CASE_RECORD_TYPE);
        
        //Asserting for the results
        System.assert(expertCentersRTTypeId != null);
        
        //Create a Blackout Days record
        Case_Blackout_Days__c cBD = new Case_Blackout_Days__c(Name = 'X-MAX', Blackout_Begin_Date__c = Date.today(), 
                                                                Blackout_End_Date__c = Date.today());
        insert cBD;
        
        //Create a sample case record to insert and test case trigger
        Case aCase = new Case(RecordTypeId = expertCentersRTTypeId, DeadLine__c = Date.today());
        
        //Variable to hold the created date
        Date createdDate = Date.today();
        
        //Start testing from here
        Test.startTest();
        
        //Enabling triggers for testing purpose
        Util.BypassAllTriggers = false;
        
        // because this case contains a deadline date < 5 days in the future and no Deadline Reason, watch it fail
        try {
            
            //Inser case
            insert aCase;
            
            //update the deadline to < 5 days in the future.
            aCase.DeadLine__c = system.today();
            update aCase;
            
            //Fail Test method if records get created
            System.assert(false);
            
        } catch(Exception e) {
            
            //Pass test method
            System.assert(true);
            System.assertEquals(true, e.getMessage().contains(TestUtilities.DEADLINE_REASON_NOT_POPULATED_ERROR));
        }
        
        // now add a deadline reason and 
        aCase.Deadline_Reason__c = 'test';
        
        //Enabling triggers
        Util.BypassAllTriggers = false;
        
        // because this case contains a deadline date on black out date, watch it fail
        try {
            
            //Inser case
            insert aCase;
            
            //Fail Test method if records get created
            System.assert(false);
            
        } catch(Exception e) {
            
            //Pass test method
            System.assert(true);
            System.assertEquals(true, e.getMessage().contains(TestUtilities.SELECTED_DEADLINE_DATE_ERROR));
        }
        
        //Update deadline on a case record
        aCase.Deadline__c  = Date.today() + 1;
        insert aCase;
        
        // get the inserted case
        List<Case> cases = [SELECT Id, Num_Business_Days_to_Deadline__c FROM Case WHERE Id = :aCase.Id];
        
        //Asset for the results
        System.assert(cases != null);
        System.assertEquals(1, cases.size());
        
        //Stop testing here
        Test.stopTest();
    }
 
    //Modified by - Abhinav Sharma - CR-20150202-8628 - To refactor the existing code
    /** Description : Method to test :- 
     *               a) On case insert it should throw an exception as case deadline is equals to black out begin date 
     *                  and user field and case owner both are same.
     *               b) Case contains a deadline date on a black out date, watch it fail
     *               c) Otherwise pass
    **/ 
    static testmethod void testBlackoutDays() { 
    
        //Bypass Dupeblocker
        Util.IsTest(true);
        Util.byPassAlltriggers = true;
        Util.isTesting = true;
        
        //Start Date and End Date
        Date startDate = Date.today() + 10;
        Date endDate = Date.today() + 14;
        
        //Create test data
        Case_Blackout_Days__c caseBlackoutDays = new Case_Blackout_Days__c(Type__c = 'Vacation', 
                                                                           Blackout_Begin_Date__c = startDate, 
                                                                           Blackout_End_Date__c = endDate, 
                                                                           User__c = UserInfo.getUserId());
        insert caseBlackoutDays;
        
        //Account
        Account a = new Account();
        a.Name = 'testAcct' + crypto.getRandomInteger();
        insert a;
        
        //International case record type
        Id contactEmployeeRTTypeId = Util.RecordTypeId(TestUtilities.CONTACT_OBJECT, TestUtilities.CONTACT_EMPLOYEE_RECORD_TYPE);
        System.assert(contactEmployeeRTTypeId != null);
        
        //create new Contact
        Contact contact = new Contact(FirstName = 'Test', LastName = 'Contact1', Email = 'test1@test.com',
                                    Phone = '21212121', AccountId = a.Id, RecordtypeId = contactEmployeeRTTypeId);
        insert contact;
        
        //Case expert center record type
        Id expertCentersRTTypeId = Util.RecordTypeId(Constants.CASE_OBJECT, TestUtilities.INTERNATIONAL_CASE_RECORD_TYPE);
        System.assert(expertCentersRTTypeId != null);
        
        //Create a sample case record to insert and test case trigger
        Case caseObj = new Case(DeadLine__c = startDate, Origin = 'Email', Subject = 'Test 1', Status = '01-New',
                                Description = 'test 1', AccountId = a.Id, Priority = 'Low', ContactId = contact.Id);
        caseObj.Deadline_Reason__c = 'this is a test'; // must give it a deadline reason if the deadline is < 7 days
        caseObj.RecordTypeId = expertCentersRTTypeId;
        
        //CaseController class instance
        CaseController controller;
        
        //start test from here
        Test.startTest();
        
        //Enabling triggers
        Util.byPassAlltriggers = false;
        
        //insert case object and it should throw exception as case daedline is equals 
        //to blackout begin date and User is case owner is same
        try {
            
            //Insert case
            insert caseObj;
            
            //update the deadline to blackout begin date.
            caseObj.DeadLine__c = startDate;
            update caseObj;
            
            System.assert(false);
            
        } catch(Exception e) {
            
            System.assert(true);
            System.assertEquals(true, e.getMessage().contains(TestUtilities.SELECTED_DEADLINE_DATE_ERROR));
            
            //Set current page parameters
            ApexPages.currentPage().getParameters().put('deadLine', String.valueOf(caseObj.Deadline__c));
            ApexPages.currentPage().getParameters().put('ownerId', UserInfo.getUserId());
            
            //instrantiate controller
            controller = new CaseController(new ApexPages.StandardController(caseObj));
            System.assert(controller.listCaseBlackoutDays != null);
            System.assertEquals(1, controller.listCaseBlackoutDays.size());
        }
        
        //Diabling triggers
        Util.byPassAlltriggers = true;
        
        //Query a different user from syatem and update the blackout record
        List<User> listUser = [Select Id from User where Id !=: UserInfo.getUserId() limit 1];
        
        //Check the users size and update the caseBlackoutDays
        if(listUser != null && listUser.size() > 0) {
            
            //Update case black out date user field reference
            caseBlackoutDays.User__c = listUser[0].Id;
            update caseBlackoutDays;
            
            //Enabling triggers
            Util.byPassAlltriggers = false;
            
            //insert case object and it should be inserted now as the blackout record and case owner are different
            insert caseObj;
        }
        
        //stop test here
        Test.stopTest();
    }
    
    //Modified by - Abhinav Sharma - CR-20150202-8628 - To refactor the existing code
    /** Description : Method to test :- 
     *               a) On case insert it should throw exception as case daedline is equals to 
                        blackout begin date and User on blackout is null
     *               b) Otherwise pass
    **/ 
    static testmethod void testBlackoutDays1() {
        
        //Bypass Dupeblocker
        Util.IsTest(true);
        Util.byPassAlltriggers = true;
        Util.isTesting = true;
        
        //Start Date and End Date
        Date startDate = Date.today() + 10;
        Date endDate = Date.today() + 14;
        
        //Create test data
        Case_Blackout_Days__c caseBlackoutDays = new Case_Blackout_Days__c(Blackout_Begin_Date__c = startDate, 
                                                                           Blackout_End_Date__c = endDate);
        insert caseBlackoutDays;
        
        //Account
        Account a = new Account();
        a.Name = 'testAcct' + crypto.getRandomInteger();
        insert a;
        
        //Create a contact
        Contact contact = TestUtilities.CreateNewContact(true);
        
        //Case Controller Instance
        CaseController controller;
        
        //Case expert center record type
        Id expertCentersRTTypeId = Util.RecordTypeId(Constants.CASE_OBJECT, TestUtilities.INTERNATIONAL_CASE_RECORD_TYPE);
        System.assert(expertCentersRTTypeId != null);
        
        //Create a sample case record to insert and test case trigger
        Case caseObj = new Case(DeadLine__c = startDate, Subject = 'Test 1', Status = '01-New',
                                Description = 'test 1', AccountId = a.Id, Priority = 'Low', ContactId = contact.Id,
                                Origin = 'Email');
        caseObj.Deadline_Reason__c = 'this is a test'; // must give it a deadline reason if the deadline is < 7 days
        caseObj.RecordTypeId = expertCentersRTTypeId;
        
        //Start Test from here
        Test.startTest();
        
        //Enabling trigger again
        Util.byPassAlltriggers = false;
        
        //insert case object and it should throw exception as case daedline is equals to 
        //blackout begin date and User on blackout is null
        try {
            
            //Insert Case
            insert caseObj;
            
            //update the deadline to blackout begin date.
            caseObj.DeadLine__c = startDate;
            update caseObj;
            
            System.assert(false);
            
        } catch(Exception e) {
            
            System.assert(true);
            System.assertEquals(true, e.getMessage().contains(TestUtilities.SELECTED_DEADLINE_DATE_ERROR));
            
            //Set currentpage parameters
            ApexPages.currentPage().getParameters().put('deadLine', String.valueOf(caseObj.Deadline__c));
            ApexPages.currentPage().getParameters().put('ownerId', caseObj.OwnerId);
            
            //instrantiate controller
            controller = new CaseController(new ApexPages.StandardController(caseObj));
            System.assert(controller.listCaseBlackoutDays != null);
            System.assertEquals(1, controller.listCaseBlackoutDays.size());
        }
        
        //stop test here
        Test.stopTest();
    }
    
    //Modified by - Abhinav Sharma - CR-20150202-8628 - To refactor the existing code
    /** Description : Method to test :- 
     *               a) On case insert, it should throw exception as case deadline is equals to blackout begin date 
     *                  and User on blackout is null
     *               b) Otherwise pass
    **/ 
    static testmethod void testBlackoutDays2() {
        
        //Bypass Dupeblocker
        Util.IsTest(true);
        Util.byPassAlltriggers = true;
        Util.isTesting = true;
        
        //Start date and End date
        Date startDate = Date.today() + 10;
        Date endDate = Date.today() + 14;
        
        //Create test data
        Case_Blackout_Days__c caseBlackoutDays = new Case_Blackout_Days__c(Blackout_Begin_Date__c = startDate, 
                                                                           Blackout_End_Date__c = endDate);
        insert caseBlackoutDays;
        
        //Account
        Account a = new Account();
        a.Name = 'testAcct' + crypto.getRandomInteger();
        insert a;
        
        //Create a contact
        Contact contact = TestUtilities.CreateNewContact(true);
        
        //Case controller instance
        CaseController controller;
        
        //Case expert center record type
        Id expertCentersRTTypeId = Util.RecordTypeId(Constants.CASE_OBJECT, TestUtilities.INTERNATIONAL_CASE_RECORD_TYPE);
        System.assert(expertCentersRTTypeId != null);
        
        //Create a sample case record to insert and test case trigger
        Case caseObj = new Case(RecordTypeId = expertCentersRTTypeId, Origin = 'Email', Subject = 'Test 1', Status = '01-New',
                                Description = 'test 1', AccountId = a.Id, Priority = 'Low', ContactId = contact.Id);
        
        //Start test from here
        Test.startTest();
        
        //Enabling trigger
        Util.byPassAlltriggers = false;
        
        //insert case object and it should throw exception as case daedline is equals to 
        //blackout begin date and User on blackout is null
        try {
            insert caseObj;
        } catch(Exception e) {
            System.assertEquals(true, e.getMessage().contains(TestUtilities.SELECTED_DEADLINE_DATE_ERROR));
        }
        
        //Enabling triggers again
        Util.byPassAlltriggers = false;
        
        //update case deadline date
        caseObj.Deadline__c = startDate - 1;
        upsert caseObj;
        System.assert(true);
        
        //Disabling triggers
        Util.byPassAlltriggers = true;
        
        //update caseBlackoutDays for user is null
        caseBlackoutDays.Type__c = 'Vacation';
        caseBlackoutDays.User__c = UserInfo.getUserId();
        update caseBlackoutDays;

        //Enabling triggers
        Util.byPassAlltriggers = false;
        
        //update case object and it should throw exception as case daedline is equals to blackout begin date 
        //and User on blackout is same as case owner
        try {
            caseObj.Deadline__c = startDate;
            update caseObj;
            System.assert(false);
        } catch(Exception e) {
            System.assert(true);
            System.assertEquals(true, e.getMessage().contains(TestUtilities.SELECTED_DEADLINE_DATE_ERROR));
            
            //Set currentpage parameters
            ApexPages.currentPage().getParameters().put('deadLine', String.valueOf(caseObj.Deadline__c));
            ApexPages.currentPage().getParameters().put('ownerId', UserInfo.getUserId());
            
            //instrantiate controller
            controller = new CaseController(new ApexPages.StandardController(caseObj));
            System.assert(controller.listCaseBlackoutDays != null);
            System.assertEquals(1, controller.listCaseBlackoutDays.size());
        }
        
        //Test stops here
        Test.stopTest();
        
        //Enabling triggers
        Util.byPassAlltriggers = false;
        
        //update case deadline date
        caseObj.Deadline__c = startDate - 3;
        upsert caseObj;
        System.assert(true);
        
        //Set currentpage parameters
        ApexPages.currentPage().getParameters().put('deadLine', String.valueOf(caseObj.Deadline__c));
        ApexPages.currentPage().getParameters().put('ownerId', caseObj.OwnerId);
        
        //instrantiate controller
        controller = new CaseController(new ApexPages.StandardController(caseObj));
        System.assert(controller.listCaseBlackoutDays != null);
        System.assertEquals(0, controller.listCaseBlackoutDays.size());
    }    
    
    //Added by - Abhinav Sharma - CR-20150202-8628 - To refactor the existing code
    /** Description : Method to test out field sync logic in between MS and cases.
    **/ 
    static testmethod void testSyncMemSupportWithCase() {
        
        //Bypassing all triggers
        Util.BypassAllTriggers = true;
        
        //Create test data for the Sync Fields custom setting that syncs Mem Support -> Case fields
        TestUtilities.createSyncFields();
        
        //Create a project
        Project__c project = TestUtilities.createProject(true);
        
        //Create a member support record related to the project
        Site_Issue__c memberSupport = TestUtilities.createSiteIssue(project.Id, false);
        memberSupport.RecordTypeId = Constants.RECORD_TYPE_ID_SITE_ISSUE_CCA_SUPPORT_REQUEST;
        memberSupport.Status__c = '06 - Issue Resolved - Ticket Closed';
        
        //Enabling triggers back
        Util.BypassAllTriggers = false;
        
        test.startTest();
        insert memberSupport;
        test.stopTest();
        
        //Get the related case and confirm the correct field values synced
        Case msCase = [SELECT Id, Subject, CaseNumber, Priority, Origin, ContactId, Description, RecordType.DeveloperName
                       FROM Case WHERE Member_Support_Ticket__c = :memberSupport.Id];
        //Get the updated member support record
        memberSupport = [SELECT Id, Site_Issue_Short_Description__c, Case_Number__c, Site_Issue_Priority__c, 
                         Interaction_Type__c, Reported_By__c, Crimson_Site_Issue_Description__c
                         FROM Site_Issue__c WHERE Id = :memberSupport.Id];
        
        system.assertNotEquals(null, msCase,
                               'A case record should have been auto-generated based on the Member Support record.');
        system.assertEquals(memberSupport.Site_Issue_Short_Description__c, msCase.Subject,
                            'The Site Issue Short Description should have synchronized with Case.Subject.');
        system.assertEquals(memberSupport.Case_Number__c, msCase.CaseNumber,
                            'The Support Issue Number should have synchronized with Case.CaseNumber.');
        system.assertEquals(memberSupport.Site_Issue_Priority__c, msCase.Priority);
        system.assertEquals(memberSupport.Interaction_Type__c, msCase.Origin);
        system.assertEquals(memberSupport.Reported_By__c, msCase.ContactId);
        system.assertEquals(memberSupport.Crimson_Site_Issue_Description__c, msCase.Description);
        system.assertEquals(msCase.RecordType.DeveloperName, Constants.RECORD_TYPE_CASE_DEVELOPER_NAME_PT_SUPPORT_REQUEST);
    }
    
    //Added By - Abhinav Sharma - 07/12/2016 - CR-20160609-9913
    static testmethod void test_CasebeforeEventsLogics3() { 
        
        //Bypass Dupeblocker
        Util.IsTest(true);
        
        //Bypassing Triggers so then test data can be created easily
        Util.byPassAllTriggers = true;
        
        //List to hold the Account records
        List<Account> accounts = new List<Account>();
        
        //Create an institution
        Account acct_1 = TestUtilities.CreateNewAccount(false);
        acct_1.Platinum_Services__c = false;
        
        //Populating list with account records
        accounts.add(acct_1); 
        
        //Insert accounts
        insert accounts;
        
        //Assert for the results
        System.assert(accounts != null);
        System.assert(accounts.size() == 1);
        
        //create contact
        Contact c = TestUtilities.CreateNewContact(accounts[0], false);
        c.AccountId = accounts[0].Id;
        insert c;
        
        //Querying Details for "Member & Employee Support" record type on Case Object
        List<RecordType> caseRdTypes = [SELECT ID, DeveloperName FROM RecordType 
                                        Where sObjectType = 'Case' 
                                        AND IsActive = true 
                                        AND DeveloperName IN ('Expert_Center')
                                        ORDER By DeveloperName ASC];
                
        //Assert for the results
        System.assert(caseRdTypes != null);
        System.assert(caseRdTypes.size() == 1);
        System.assert(caseRdTypes[0].DeveloperName == 'Expert_Center');
        
        //Record Type Setting list
        list<RecordType_Setting__c> listRTSettings = new list<RecordType_Setting__c>();

        //Record Type Setting instance
        RecordType_Setting__c rs_1 = new RecordType_Setting__c(Name = 'Test1', 
                                                             Name__c = 'Expert Center', 
                                                             SFID__c = caseRdTypes[0].Id, SObjectType__c = 'Case');
        listRTSettings.add(rs_1);
        insert listRTSettings;
        
        //List to hold the case records
        List<Case> cases = new List<Case>();
        
        //Create a sample case record to insert and test case trigger
        Case aCase_1 = new Case(RecordTypeId = caseRdTypes[0].Id, Origin = 'ABC', Subject = 'Test', 
                                Description = 'Test', ContactId = c.Id, Deadline__c = System.today().addDays(1));
       
        //Populating list with case records
        cases.add(aCase_1); 
        
        //Start test from here
        Test.startTest();
        
        //Enabling triggers
        Util.byPassAllTriggers = false;
       
        //Making a try to update the status value
        try {
            
            //Setting the flags
            CaseTriggerHelper.IS_ALREADY_EXECUTED_ONCE = false;
            CaseTriggerHelper.IS_UPDATE_HAPPENS_ON_INSERT_EVENT = false; 
            
            //Insert cases
            insert cases;
            
        } catch(Exception ex) {
            System.debug(ex.getMessage().contains(System.Label.ERROR_Deadline_Reason_required));
        }
        
        //Updating fields values on the case instance
        cases[0].Origin = System.Label.ORIGIN_MEMBER_PRIORITY;
        
        //Making a try to update the status value
        try {
            
            //Setting the flags
            CaseTriggerHelper.IS_ALREADY_EXECUTED_ONCE = false;
            CaseTriggerHelper.IS_UPDATE_HAPPENS_ON_INSERT_EVENT = false; 
            
            //Insert cases
            insert cases;
            
        } catch(Exception ex) {
            System.debug(ex.getMessage().contains(System.Label.ERROR_Deadline_Reason_Reqd_for_Member_Priority));
        }
        
        //Stop test here
        Test.stopTest();
    }
    
    //Added By - Mahedra Swarnkar - 07/05/2016 - CR-20160229-9651
    static testmethod void test_populateCaseFields() {
        
        //Bypass Dupeblocker
        Util.IsTest(true);
        
        //Bypassing Triggers so then test data can be created easily
        Util.byPassAllTriggers = true;
        
        //Profile    
        Profile p = [SELECT Id FROM Profile WHERE Name = 'System Administrator']; 
        
        //List to hold the users
        List<User> users = new List<User>();
      
        //User 1
        User user_1 = new User(Alias = 'standt', Email='standarduser@testorg.com', 
                            EmailEncodingKey='UTF-8', LastName='Testing1', LanguageLocaleKey='en_US', 
                            LocaleSidKey='en_US', ProfileId = p.Id, department = 'STP',
                            TimeZoneSidKey = 'GMT', UserName=Math.random() + '@test.com');
                            
        //User 2
        User user_2 = new User(Alias = 'standt', Email='standarduser@testorg1.com', 
                            EmailEncodingKey='UTF-8', LastName='Testing2', LanguageLocaleKey='en_US', 
                            LocaleSidKey='en_US', ProfileId = p.Id, department = 'STP',
                            TimeZoneSidKey='GMT', UserName=Math.random() + '@test.com');
        //User 3
        User user_3 = new User(Alias = 'standt', Email='standarduser@testorg2.com', 
                            EmailEncodingKey='UTF-8', LastName='Testing3', LanguageLocaleKey='en_US', 
                            LocaleSidKey='en_US', ProfileId = p.Id, department = 'STP',
                            TimeZoneSidKey='GMT', UserName=Math.random() + '@test.com');
                            
        //Populating list with the user instance
        users.add(user_1); users.add(user_2); users.add(user_3);
        insert users;
        
        //Create an institution
        Account account = TestUtilities.CreateNewAccount(false);
        
        //Insert accounts
        insert account;
        
        //create contact
        Contact c = TestUtilities.CreateNewContact(account, false);
        c.AccountId = account.Id;
        insert c;
        
        //Create program data
        List<Program__c> programs = new List<Program__c>();
        Program__c program_1 = new Program__c(Name = 'testName 1', Program_Acronym__c = 'testing TD', 
                                              Business_line__c = 'TD', Status__c = 'Active');
        Program__c program_2 = new Program__c(Name = 'testName 2', Program_Acronym__c = 'testing', 
                                              Business_line__c = 'TD', Status__c = 'Active');
        programs.add(program_1); programs.add(program_2);
        insert programs;
        
        //Assert for the results
        System.assert(programs != null);
        System.assert(programs.size() == 2);
        
        
        //create Contract ABC test data
        List<Contract__c> contracts = new List<Contract__c>();
        Contract__c contractABC_1 = new Contract__c(Payer_Account__c = account.Id, Type__c = 'NBB', 
                                                    Program__c = programs[0].Id, Start__c = System.today().addDays(-5),
                                                    End__c = System.today().addDays(5));
        Contract__c contractABC_2 = new Contract__c(Payer_Account__c = account.Id, Type__c = 'NBB', 
                                                    Program__c = programs[1].Id, Start__c = System.today().addDays(-5),
                                                    End__c = System.today().addDays(7));
        
        contracts.add(contractABC_1); contracts.add(contractABC_2);
        insert contracts;
        
        //Assert for the results
        System.assert(contracts != null);
        System.assert(contracts.size() == 2);
        
        //create Contract ABC test data
        List<Project__c> projects = new List<Project__c>();
        Project__c project_1 = new Project__c( Name = 'Test1', Membership_Advisor_Relationship_Manager__c = users[0].Id, 
                                               Dedicated_Advisor__c = users[1].Id, Program_Associate__c = users[2].Id, 
                                               No_of_Participants__c = 1, Cohort_ID_s__c = 'Test_Cohort', X1_2_Day__c = 1, 
                                               Contract_Start_Date__c = System.today().addDays(-2), 
                                               Internal_Strat_Session_NPI_Actual__c = System.today().addDays(2), 
                                               Service_Date_Start__c = System.today().addDays(-1));
        
        Project__c project_2 = new Project__c( Name = 'Test2', Membership_Advisor_Relationship_Manager__c = users[1].Id, 
                                               Dedicated_Advisor__c = users[2].Id, Program_Associate__c = users[0].Id, 
                                               No_of_Participants__c = 2, Cohort_ID_s__c = 'Test_Cohort', Full_Day__c = 1, 
                                               Contract_Start_Date__c = System.today().addDays(-2), 
                                               Internal_Strat_Session_NPI_Actual__c = System.today().addDays(2), 
                                               Service_Date_Start__c = System.today().addDays(-1));
        
        projects.add(project_1); projects.add(project_2);
        insert projects;
        
        //Assert for the results
        System.assert(projects != null);
        System.assert(projects.size() == 2);
        
        //Querying Details for "Member & Employee Support" record type on Case Object
        List<RecordType> caseRdTypes = [SELECT ID, DeveloperName FROM RecordType 
                                        Where sObjectType = 'Case' 
                                        AND IsActive = true 
                                        AND DeveloperName IN ('Talent_Development')];
                
        //Assert for the results
        System.assert(caseRdTypes != null);
        System.assert(caseRdTypes.size() == 1);
        System.assert(caseRdTypes[0].DeveloperName == 'Talent_Development');
        
        //Record Type Setting list
        list<RecordType_Setting__c> listRTSettings = new list<RecordType_Setting__c>();

        //Record Type Setting instance
        RecordType_Setting__c rs_1 = new RecordType_Setting__c(Name = 'Test1', 
                                                             Name__c = 'Talent Development', 
                                                             SFID__c = caseRdTypes[0].Id, SObjectType__c = 'Case');
        listRTSettings.add(rs_1);
        insert listRTSettings;
        
        //List to hold the case records
        List<Case> cases = new List<Case>();
        
        //Create a sample case record to insert and test case trigger
        cases.add(new Case(RecordTypeId = caseRdTypes[0].Id, Origin = 'ABC', Subject = 'Test', 
                                Description = 'Test', ContactId = c.Id, Deadline__c = System.today().addDays(1),
                                Project_Source_MS__c = projects[0].Id, Contract__c = contracts[0].Id));
        
        //Create a sample case record to insert and test case trigger
        cases.add(new Case(RecordTypeId = caseRdTypes[0].Id, Origin = 'ABC1', Subject = 'Test', Description = 'Test2',
                           ContactId = c.Id, Deadline__c = System.today().addDays(1), Contract__c = contracts[0].Id));
        
        //Create a sample case record to insert and test case trigger
        cases.add(new Case(RecordTypeId = caseRdTypes[0].Id, Origin = 'ABC2', Subject = 'Test', Description = 'Test3',
                           ContactId = c.Id, Deadline__c = System.today().addDays(1)));
        
        //Start test from here
        Test.startTest();
        
        //Insert Cases
        Util.byPassAllTriggers = false;
        insert cases;
        
        //By pass all the triggers
        Util.byPassAllTriggers = true;
        
        //Query through Cases
        cases = [Select Id, RM__c, DA__c, Associate__c, No_of_Participants__c, Cohort_ID__c, Half_Day_or_Full_Day__c, 
                 Contract_Service_Start__c, Contract_Service_End__c, Service_Start__c, Project_Year__c FROM Case Where Project_Source_MS__c != null ];
        
        //Asserts on results
        System.assertEquals(1, cases.size());
        System.assertEquals('Testing1', cases[0].RM__c);
        System.assertEquals('Testing2', cases[0].DA__c);
        System.assertEquals('Testing3', cases[0].Associate__c);
        System.assertEquals(1, cases[0].No_of_Participants__c);
        System.assertEquals('Test_Cohort', cases[0].Cohort_ID__c);
        System.assertEquals('1/2 Day', cases[0].Half_Day_or_Full_Day__c);
        System.assertEquals(System.today().addDays(-2), cases[0].Contract_Service_Start__c);
        System.assertEquals(System.today().addDays(2), cases[0].Contract_Service_End__c);
        System.assertEquals(System.today().addDays(-1), cases[0].Service_Start__c);
        System.assert((cases[0].Project_Year__c.contains(' - 2016')));
        
        //update Case to change the Project source
        cases[0].Project_Source_MS__c = projects[1].Id;
        
        //Enable All the Triggers 
        Util.byPassAllTriggers = false;
        
        //Update the case
        update cases;
        
        //By pass all the triggers
        Util.byPassAllTriggers = true;
        
        //Query through Cases
        cases = [Select Id, RM__c, DA__c, Associate__c, No_of_Participants__c, Cohort_ID__c, Half_Day_or_Full_Day__c, 
                 Contract_Service_Start__c, Contract_Service_End__c, Service_Start__c, Project_Year__c FROM Case Where Project_Source_MS__c != null ];
        
        //Asserts on results
        System.assertEquals(1, cases.size());
        System.assertEquals('Testing2', cases[0].RM__c);
        System.assertEquals('Testing3', cases[0].DA__c);
        System.assertEquals('Testing1', cases[0].Associate__c);
        System.assertEquals(2, cases[0].No_of_Participants__c);
        System.assertEquals('Test_Cohort', cases[0].Cohort_ID__c);
        System.assertEquals('Full Day', cases[0].Half_Day_or_Full_Day__c);
        System.assert((cases[0].Project_Year__c.contains(' - 2016')));
        //Stop test here
        Test.stopTest();
    }
    
    //Added By - Mahendra Swarnkar - 08/27/2016 - CR-20160803-10082 
    /***
     @ This Method will test 
     @  1) Populating deadline functionality for following case record types :- 
     @         IRC request, Expert Center, Talent Development, Syndicated Services.
     @  2) populating priority field on expert center cases. 
    ***/
    static testmethod void test_CasebeforeEventsLogics4() { 
        
        //Bypass Dupeblocker
        Util.IsTest(true);
        
        //Bypassing Triggers so then test data can be created easily
        Util.byPassAllTriggers = true;
        
        //List to hold the Account records
        List<Account> accounts = new List<Account>();
        
        //Create institutions
        Account acct_1 = TestUtilities.CreateNewAccount(false);
        acct_1.Platinum_Services__c = True;
        acct_1.Account_Formal_Name__c = 'Acc1';
        
        Account acct_2 = TestUtilities.CreateNewAccount(false);
        acct_2.Account_Formal_Name__c = 'Acc2';
        //Populating list with account records
        accounts.add(acct_1);
        accounts.add(acct_2); 
        
        //Insert accounts
        insert accounts;
        accounts = [Select Id, Platinum_Services__c From Account Order By Account_Formal_Name__c ASC];
        
        //Assert for the results
        System.assert(accounts != null);
        System.assert(accounts.size() == 2);
        System.assert(accounts[0].Platinum_Services__c, true);
        
        //List to hold the Contact records
        List<Contact> contacts = new List<Contact>();
        
        //create contact
        Contact c = TestUtilities.CreateNewContact(accounts[0], false);
        c.AccountId = accounts[0].Id;
        contacts.add(c);
        
        //create contact
        Contact c1 = TestUtilities.CreateNewContact(accounts[0], false);
        c1.AccountId = accounts[1].Id;
        contacts.add(c1);
        
        //Insert Contacts
        insert contacts;
        
        //Querying Details for record types on Case Object
        List<RecordType> caseRdTypes = [SELECT ID, DeveloperName FROM RecordType 
                                        Where sObjectType = 'Case' 
                                        AND IsActive = true 
                                        AND DeveloperName IN ('Expert_Center','IRC_Request', 'Syndicated_Services', 'Talent_Development')
                                        ORDER By DeveloperName ASC];
                
        //Assert for the results
        System.assert(caseRdTypes != null);
        System.assert(caseRdTypes.size() == 4);
        System.assert(caseRdTypes[0].DeveloperName == 'Expert_Center');
        System.assert(caseRdTypes[1].DeveloperName == 'IRC_Request');
        System.assert(caseRdTypes[2].DeveloperName == 'Syndicated_Services');
        System.assert(caseRdTypes[3].DeveloperName == 'Talent_Development');
        
        //Record Type Setting list
        list<RecordType_Setting__c> listRTSettings = new list<RecordType_Setting__c>();

        //Record Type Setting instance
        RecordType_Setting__c rs_1 = new RecordType_Setting__c(Name = 'Test1', 
                                                             Name__c = 'Expert Center', 
                                                             SFID__c = caseRdTypes[0].Id, SObjectType__c = 'Case');
        //Record Type Setting instance
        RecordType_Setting__c rs_2 = new RecordType_Setting__c(Name = 'Test2', 
                                                             Name__c = 'IRC Request', 
                                                             SFID__c = caseRdTypes[1].Id, SObjectType__c = 'Case');
        
        //Record Type Setting instance
        RecordType_Setting__c rs_3 = new RecordType_Setting__c(Name = 'Test3', 
                                                             Name__c = 'Syndicated Services', 
                                                             SFID__c = caseRdTypes[2].Id, SObjectType__c = 'Case');
        
        //Record Type Setting instance
        RecordType_Setting__c rs_4 = new RecordType_Setting__c(Name = 'Test4', 
                                                             Name__c = 'Talent Development', 
                                                             SFID__c = caseRdTypes[3].Id, SObjectType__c = 'Case');                                                                  
        listRTSettings.add(rs_1);
        listRTSettings.add(rs_2);
        listRTSettings.add(rs_3);
        listRTSettings.add(rs_4);
        insert listRTSettings;
        
        //List to hold the case records
        List<Case> cases = new List<Case>();
        
        //Create a sample case record to insert and test case trigger
        //1.Expert Center Type Case 
        Case aCase_1 = new Case(RecordTypeId = caseRdTypes[0].Id, Origin = 'ABC', Subject = 'Test', 
                                Description = 'Test', ContactId = contacts[0].Id, Deadline__c = System.today().addDays(1), 
                                Deadline_Reason__c = 'ABC1');
        
        Case aCase_1a = new Case(RecordTypeId = caseRdTypes[0].Id, Origin = 'ABC', Subject = 'Test', 
                                Description = 'Test', ContactId = contacts[0].Id, Deadline__c = System.today().addDays(4), 
                                Deadline_Reason__c = 'ABC9');
        
        Case aCase_2 = new Case(RecordTypeId = caseRdTypes[0].Id, Origin = System.Label.ORIGIN_MEMBER_PRIORITY, Subject = 'Test',
                                Description = 'Test', ContactId = contacts[1].Id, Deadline__c = System.today().addDays(1), 
                                Deadline_Reason__c = 'ABC2');
        
        Case aCase_2a = new Case(RecordTypeId = caseRdTypes[0].Id, Origin = System.Label.ORIGIN_MEMBER_PRIORITY, Subject = 'Test',
                                Description = 'Test', ContactId = contacts[1].Id, Deadline__c = System.today().addDays(9), 
                                Deadline_Reason__c = 'ABC91');
        
        Case aCase_3 = new Case(RecordTypeId = caseRdTypes[0].Id, Origin = 'ABC', Subject = 'Test',
                                Description = 'Test', ContactId = contacts[1].Id, Deadline__c = System.today().addDays(1), 
                                Deadline_Reason__c = 'ABC3');
        
        Case aCase_3a = new Case(RecordTypeId = caseRdTypes[0].Id, Origin = 'ABC', Subject = 'Test',
                                Description = 'Test', ContactId = contacts[1].Id, Deadline__c = System.today().addDays(10), 
                                Deadline_Reason__c = 'ABC92');
        
        //2.IRC Request Type Case
        Case aCase_4 = new Case(RecordTypeId = caseRdTypes[1].Id, Origin = 'Other', Subject = 'Test', 
                                Description = 'Test', ContactId = contacts[0].Id, Deadline__c = System.today().addDays(1), 
                                Deadline_Reason__c = 'ABC4');
                                       
        //3.Syndicated Services Type Case
        Case aCase_5 = new Case(RecordTypeId = caseRdTypes[2].Id, Origin = 'ABC', Subject = 'Test', Topic_Unknown__c = true,
                                Description = 'Test', ContactId = contacts[0].Id, Deadline__c = System.today().addDays(1), 
                                Deadline_Reason__c = 'ABC5');
                                
        Case aCase_6 = new Case(RecordTypeId = caseRdTypes[2].Id, Origin = 'ABC', Subject = 'Test', Topic_Unknown__c = true,
                                Description = 'Test', ContactId = contacts[1].Id, Deadline__c = System.today().addDays(1), 
                                Deadline_Reason__c = 'ABC6');
        
        //4.Talent Development Type Case
        Case aCase_7 = new Case(RecordTypeId = caseRdTypes[3].Id, Origin = 'ABC', Subject = 'Test', Topic_Unknown__c = true,
                                Description = 'Test', ContactId = contacts[0].Id, Deadline__c = System.today().addDays(1), 
                                Deadline_Reason__c = 'ABC7');
       
        Case aCase_8 = new Case(RecordTypeId = caseRdTypes[3].Id, Origin = 'ABC', Subject = 'Test', Topic_Unknown__c = true,
                                Description = 'Test', ContactId = contacts[1].Id, Deadline__c = System.today().addDays(1), 
                                Deadline_Reason__c = 'ABC8');
      
        //Populating list with case records
        cases.add(aCase_1);
        cases.add(aCase_1a);
        cases.add(aCase_2);
        cases.add(aCase_2a);
        cases.add(aCase_3);
        cases.add(aCase_3a);
        cases.add(aCase_4);
        cases.add(aCase_5);
        cases.add(aCase_6);
        cases.add(aCase_7);
        cases.add(aCase_8); 
        
        //Start test from here
        Test.startTest();
        
        //Enabling triggers
        Util.byPassAllTriggers = false;
            
        //Setting the flags
        CaseTriggerHelper.IS_ALREADY_EXECUTED_ONCE = false;
        CaseTriggerHelper.IS_UPDATE_HAPPENS_ON_INSERT_EVENT = false; 
        
        //Insert cases
        insert cases;
        cases = [Select Id, Deadline__c, Priority, Deadline_Reason__c From Case ORDER By Deadline_Reason__c ASC];
        
        //Asserts for results
        System.assertEquals(cases.size(), 11);
        
        if(!Util.IsWeekendDay(System.today())) {
        
            //Asserts for DeadLine fields
            System.assertEquals(cases[0].Deadline__c, System.today().addDays(1));
            System.assertEquals(cases[1].Deadline__c, System.today().addDays(1));
            System.assertEquals(cases[2].Deadline__c, System.today().addDays(1) );
            System.assertEquals(cases[3].Deadline__c, Util.AddBusinessDays(System.today(), Integer.valueOf(System.Label.IRC_DeadLine_Default), null) );
            System.assertEquals(cases[4].Deadline__c, Util.AddBusinessDays(System.today(), Integer.valueOf(System.Label.SyndicatedServices_DeadLine_Platinum_True_Default), null));
            System.assertEquals(cases[5].Deadline__c, Util.AddBusinessDays(System.today(), Integer.valueOf(System.Label.SyndicatedServices_DeadLine_Platinum_False_Default), null));
            System.assertEquals(cases[6].Deadline__c, Util.AddBusinessDays(System.today(), Integer.valueOf(System.Label.ExpertCenter_DeadLine_Platinum_True_Default), null) );
            System.assertEquals(cases[7].Deadline__c, System.today().addDays(1));
            
            System.assertEquals(cases[8].Deadline_Reason__c, 'ABC9');
            System.assertEquals(cases[9].Deadline_Reason__c, 'ABC91'); 
            System.assertEquals(cases[10].Deadline_Reason__c, 'ABC92');
		}
        
        //Updating fields values on the case instance
        cases[0].Deadline__c = System.today().addDays(1);
        cases[1].Deadline__c = Util.AddBusinessDays(System.today(), 10, null);
        cases[2].Deadline__c = Util.AddBusinessDays(System.today(), 8, null);
        
        //Setting the flags
        CaseTriggerHelper.IS_ALREADY_EXECUTED_ONCE = false;
        CaseTriggerHelper.IS_UPDATE_HAPPENS_ON_INSERT_EVENT = false; 
        
        //Insert cases
        update cases;
        
        cases = [Select Id, Deadline__c, Priority From Case ORDER By Deadline_Reason__c ASC];
        
        if(!Util.IsWeekendDay(System.today())) {
        
            //Asserts for results
            System.assertEquals(cases.size(), 11);
        }
        
        //Stop test here
        Test.stopTest();
    }
}