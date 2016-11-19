/*
    Purpose         :   Test class for Trigger_Task
                
    Create By       :   Simplyforce Technology
    
    Created Date    :   11/03/2011
    
    Current Version :   V1.1
    
    Revision Log    :   V1.0 - Created
						V1.1 - Modified By - Abhinav Sharma - 07/13/2016 - CR-20150202-8648  - A Refactor Code CR
	
	Coverage		:	V1.0 - TaskTriggerHelper - 83%
						V1.1 - TaskTriggerHelper - 98%
*/
@IsTest(SeeAllData=true)
private class Test_TaskTrigger {
    
    //Modified by - Abhinav Sharma - 07/13/2016 - CR-20150202-8648 - To refactor the existing code
    /** Description : Method to test out the notify user related functionality.
    **/
    static testmethod void testNotifyTaskCreator() { 
        
        //Bypass Dupeblocker and triggers
        Util.IsTest(true);
        Util.byPassAllTriggers = true;
        Util.IsTesting = true;
        
        //Create test data
        Task task = new Task(Subject = 'testSubject', Status = TaskTriggerHelper.STATUS_COMPLETED, 
                             Notify_Task_Creator__c = false);
        
        //start test from here 
        Test.startTest();
        
        //Enabling trigger again
		Util.byPassAllTriggers = false;        
        
        //insert the task record
        insert task;
        
        //Asserting for the results
        System.assert(task != null);
        
        //update the same task
        task.Notify_Task_Creator__c = true;
        update task;
        
        //Asserting for the results
        System.assert(task != null);
        
        //Asserting for the results
        Integer invocations = Limits.getEmailInvocations();
        System.assert(invocations != null);
        
        //stop test here
        Test.stopTest();
    }
    
    //Modified by - Abhinav Sharma - 07/13/2016 - CR-20150202-8648 - To refactor the existing code
    /** Description : Method to to check if the Testimonial task is being created, then create a new Feed item 
     * 					with user story. Added for CR-20140214-4512
     *
    **/
    @isTest(SeeAllData=true)
    static void testPostMemberImpactStory() {
        
        //Bypass Dupeblocker and triggers
        Util.IsTest(true);
        Util.byPassAllTriggers = true;
        Util.IsTesting = true;
        
        //Get the Testimonial Record Type
        List<RecordType> recordTypes = [Select Id from RecordType 
                                        WHERE Name =: Constants.RECORD_TYPE_TASK_DEVELOPER_NAME_TESTIMONIALS 
                                        AND SObjectType = 'Task' AND ISActive = true];
        
        //Asserting for the results
        System.assert(recordTypes != null);
        System.assertEquals(1, recordTypes.size());
        
        //Get the Account Record Type
        List<RecordType> accRecordTypes = [SELECT Id FROM RecordType 
                                            WHERE DeveloperName =: Constants.RECORD_TYPE_ACCOUNT_DEVELOPER_NAME_US_EDUCATION 
                                            AND SObjectType = 'Account' AND ISActive = true];
        
        //Asserting for the results
        System.assert(accRecordTypes != null);
        System.assertEquals(1, accRecordTypes.size());
        
        
        //AccountId
        Account account = TestUtilities.CreateNewAccount(false);
        account.RecordTypeId = accRecordTypes[0].Id;
        insert account;
        System.assert(account != null);
        
        //create test data
        Task task = new Task(Subject = Constants.TASK_SUBJECT_MEMBER_IMPACT_STORY, 
                             Description = 'TestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTesting',
                             Status = TaskTriggerHelper.STATUS_COMPLETED,
                             Additional_ABC_Attendees__c = 'Abhinav Sharma',
                             RecordTypeId = recordTypes[0].Id, WhatId = account.Id);
        
        //Start testing here
        Test.startTest();
        
        //Enabling trigger again
        Util.byPassAllTriggers = false;
        
        //insert Task
        insert task;
        
        //Check a New Feed Item is created related to the Task
        List<FeedItem> feedItems = [Select Id from FeedItem where ParentId != null AND ParentId =: task.WhatId];
        System.assertEquals(1, feedItems.size());
        
        //Stop testing
        Test.stopTest();
        
        //create test data
        task = new Task(Subject = Constants.TASK_SUBJECT_MEMBER_IMPACT_STORY, 
                             Status = TaskTriggerHelper.STATUS_COMPLETED,
                             Additional_ABC_Attendees__c = 'Abhinav Sharma',
                        	 Description = 'testing',
                             RecordTypeId = recordTypes[0].Id, WhatId = account.Id);
        insert task;
        
        //Check a New Feed Item is created related to the Task
        feedItems = [Select Id from FeedItem where ParentId != null AND ParentId =: task.WhatId];
        System.assertEquals(2, feedItems.size());
    }
    
    //Modified by - Abhinav Sharma - 07/13/2016 - CR-20150202-8648 - To refactor the existing code
    /** Description : Method to test "populateFieldsOnConsolidatedInvoice" method related functaionalities.
    **/
    static testmethod void testpopulateFieldsOnConsolidatedInvoice() { 
        
        //Bypass Dupeblocker and triggers
        Util.IsTest(true);
        Util.byPassAllTriggers = true;
        Util.IsTesting = true;
        
        // This code runs as the system user
		Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator'];
        System.assert(p != null);
        
        //User (GMT Time Zone)
		User u = new User(Alias = 'standt', Email='standarduser@testorg.com', 
							EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
      						LocaleSidKey='en_US', ProfileId = p.Id, TimeZoneSidKey = 'GMT',
      						UserName=Math.random() + '@test.com');

		//Running code in context of a "GMT" time zone user
      	System.runAs(u) {
        
            //Account
            Account a = new Account(Name = 'testacc', Account_Formal_Name__c = 'Testing');
            insert a;
            System.assert(a != null);
            
            //List of consolidate invoice
            List<ConsolidatedInvoice__c> consolidatedInvoices = new List<ConsolidatedInvoice__c>([SELECT ID, Last_Follow_Up_Date__c,
                                                                                                  Last_Follow_Up_Note__c 
                                                                                                  FROM ConsolidatedInvoice__c 
                                                                                                  ORDER BY Name DESC LIMIT 1]);
            
            //Applying assert for the results
            if(consolidatedInvoices != null && consolidatedInvoices.size() > 0) {
                
                //Consolidated Invoice 
                ConsolidatedInvoice__c cI = consolidatedInvoices[0];
                cI.Last_Follow_Up_Date__c = null;
                cI.Last_Follow_Up_Note__c = null;
                Util.BypassAllTriggers = true;
                update cI;
                
                //Querying for the updated records
                consolidatedInvoices = [SELECT ID, Last_Follow_Up_Date__c, Last_Follow_Up_Note__c 
                                            FROM ConsolidatedInvoice__c
                                            WHERE ID =: cI.Id];
                
                //Asserting for the results
                System.assert(consolidatedInvoices != null);
                System.assertEquals(1, consolidatedInvoices.size());
                System.assertEquals(null, consolidatedInvoices[0].Last_Follow_Up_Date__c);
                System.assertEquals(null, consolidatedInvoices[0].Last_Follow_Up_Note__c);
                
                //Task record
                Task task_1 = new Task(Subject = 'testSubject 1', Status = TaskTriggerHelper.STATUS_COMPLETED, 
                                       Notify_Task_Creator__c = false, ActivityDate = System.today().addDays(-1),
                                       WhatId = cI.Id);
                
                //start test from here 
                Test.startTest();
            
                //Enable triggers again
                Util.BypassAllTriggers = false;
                
                //Insert
                insert task_1;
                
                //Querying for the updated records
                consolidatedInvoices = [SELECT ID, Last_Follow_Up_Date__c, Last_Follow_Up_Note__c 
                                            FROM ConsolidatedInvoice__c
                                            WHERE ID =: cI.Id];
               	
                //Asserting for the results
                System.assert(consolidatedInvoices != null);
                System.assertEquals(1, consolidatedInvoices.size());
                System.assertNotEquals(null, consolidatedInvoices[0].Last_Follow_Up_Date__c);
                System.assertNotEquals(null, consolidatedInvoices[0].Last_Follow_Up_Note__c);
                
                //Consolidated Invoice 
                cI = consolidatedInvoices[0];
                cI.Last_Follow_Up_Date__c = null;
                cI.Last_Follow_Up_Note__c = null;
                
                //Disbling triggers
                Util.BypassAllTriggers = true;
                update cI;
                
                //Update
                task_1.Status = TaskTriggerHelper.STATUS_COMPLETED;
                update task_1;
             	
                //Querying fields values for task records
                ConsolidatedInvoices = [SELECT ID, Last_Follow_Up_Date__c, Last_Follow_Up_Note__c FROM ConsolidatedInvoice__c
                                        WHERE ID =: cI.Id];
                
                //Asserting for the results
                System.assert(consolidatedInvoices != null);
                System.assertEquals(1, consolidatedInvoices.size());
                System.assertEquals(null, consolidatedInvoices[0].Last_Follow_Up_Date__c);
                System.assertEquals(null, consolidatedInvoices[0].Last_Follow_Up_Note__c);
                
                //Enable triggers again
                Util.BypassAllTriggers = false;
                
                //Updating task status
                task_1.Status = 'In progress';
                update task_1;
                
                //stop test here
                Test.stopTest();
                
                //Querying fields values for task records
                ConsolidatedInvoices = [SELECT ID, Last_Follow_Up_Date__c, Last_Follow_Up_Note__c FROM ConsolidatedInvoice__c
                                        WHERE ID =: cI.Id];
                
                //Asserting for the results
                System.assert(consolidatedInvoices != null);
                System.assertEquals(1, consolidatedInvoices.size());
                System.assertEquals(null, consolidatedInvoices[0].Last_Follow_Up_Date__c);
                
                //Disbling triggers
                Util.BypassAllTriggers = true;
                
                //Update
                task_1.Status = TaskTriggerHelper.STATUS_COMPLETED;
                update task_1;
             	
                //Querying fields values for task records
                ConsolidatedInvoices = [SELECT ID, Last_Follow_Up_Date__c, Last_Follow_Up_Note__c FROM ConsolidatedInvoice__c
                                        WHERE ID =: cI.Id];
                
                //Asserting for the results
                System.assert(consolidatedInvoices != null);
                System.assertEquals(1, consolidatedInvoices.size());
                System.assertEquals(null, consolidatedInvoices[0].Last_Follow_Up_Date__c);
            }
        }        
	}
    
    //Added by - Abhinav Sharma - 07/13/2016 - CR-20150202-8648 - To refactor the existing code
    /** Description : Method to test "populateFieldsOnConsolidatedInvoice" method related functaionalities.
    **/
    static testmethod void testpopulateFieldsOnConsolidatedInvoice1() { 
        
        //Bypass Dupeblocker and triggers
        Util.IsTest(true);
        Util.byPassAllTriggers = true;
        Util.IsTesting = true;
        
        // This code runs as the system user
		Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator'];
        System.assert(p != null);
        
        //User (GMT Time Zone)
		User u = new User(Alias = 'standt', Email='standarduser@testorg.com', 
							EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
      						LocaleSidKey='en_US', ProfileId = p.Id, TimeZoneSidKey = 'GMT',
      						UserName=Math.random() + '@test.com');

		//Running code in context of a "GMT" time zone user
      	System.runAs(u) {
        
            //Account
            Account a = new Account(Name = 'testacc', Account_Formal_Name__c = 'Testing');
            insert a;
            System.assert(a != null);
            
            //List of consolidate invoice
            List<ConsolidatedInvoice__c> consolidatedInvoices = new List<ConsolidatedInvoice__c>([SELECT ID, Last_Follow_Up_Date__c,
                                                                                                  Last_Follow_Up_Note__c 
                                                                                                  FROM ConsolidatedInvoice__c 
                                                                                                  ORDER BY Name DESC LIMIT 1]);
            
            //Applying assert for the results
            if(consolidatedInvoices != null && consolidatedInvoices.size() > 0) {
                
                //Consolidated Invoice 
                ConsolidatedInvoice__c cI = consolidatedInvoices[0];
                cI.Last_Follow_Up_Date__c = null;
                cI.Last_Follow_Up_Note__c = null;
                Util.BypassAllTriggers = true;
                update cI;
                
                //Querying for the updated records
                consolidatedInvoices = [SELECT ID, Last_Follow_Up_Date__c, Last_Follow_Up_Note__c 
                                            FROM ConsolidatedInvoice__c
                                            WHERE ID =: cI.Id];
                
                //Asserting for the results
                System.assert(consolidatedInvoices != null);
                System.assertEquals(1, consolidatedInvoices.size());
                System.assertEquals(null, consolidatedInvoices[0].Last_Follow_Up_Date__c);
                System.assertEquals(null, consolidatedInvoices[0].Last_Follow_Up_Note__c);
                
                //List of Tasks
                List<Task> tasks = [SELECT ID FROM Task 
                                    WHERE WhatId != null AND WhatId =: CI.Id];
                
                //Checking for the null and size value
                if(tasks != null && tasks.size() > 0)
                    delete tasks;
                
                //Task record
                Task task_1 = new Task(Subject = 'testSubject 1', Status = 'In progress', 
                                       Notify_Task_Creator__c = false, ActivityDate = System.today().addDays(1),
                                       WhatId = cI.Id);
                
                //start test from here 
                Test.startTest();
            
                //Enable triggers again
                Util.BypassAllTriggers = false;
                
                //Insert
                insert task_1;
                
                //Asserting for the results
                System.assert(task_1 != null);
                
                //Updateing task
                task_1.Status = TaskTriggerHelper.STATUS_COMPLETED;
                update task_1;
                
                //Querying for the updated records
                consolidatedInvoices = [SELECT ID, Last_Follow_Up_Date__c, Last_Follow_Up_Note__c 
                                            FROM ConsolidatedInvoice__c
                                            WHERE ID =: cI.Id];
                
                //Asserting for the results
                System.assert(consolidatedInvoices != null);
                System.assertEquals(1, consolidatedInvoices.size());
                System.assertNotEquals(null, consolidatedInvoices[0].Last_Follow_Up_Date__c);
                System.assertNotEquals(null, consolidatedInvoices[0].Last_Follow_Up_Note__c);
                
                //Stop test here
                Test.stopTest();
            	
                //Delete
                delete task_1;
                
                //Querying for the updated records
                consolidatedInvoices = [SELECT ID, Last_Follow_Up_Date__c, Last_Follow_Up_Note__c 
                                            FROM ConsolidatedInvoice__c
                                            WHERE ID =: cI.Id];
                
                //Asserting for the results
                System.assert(consolidatedInvoices != null);
                System.assertEquals(1, consolidatedInvoices.size());
            }
        }        
	}
}