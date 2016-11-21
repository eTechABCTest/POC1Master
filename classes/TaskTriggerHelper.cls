/*
    Purpose         :   This class is helper class for trigger on Task object.
                
    Create By       :   Simplyforce Technology
    
    Created Date    :   11/03/2011
    
    Current Version :   v1.0
    
    Revision Log    :   V_1.1 Created
                        V_1.2 - 03/07/2014 - Bhavi Sharma - New Method Added(postMemberImpactStory) - CR-20140214-4512
                        V_1.3 - 04/18/2014 - Bhavi Sharma - Modfied(postMemberImpactStory) - CR-20140414-5064
                        V_1.4 - Modified by - Ajit Surana - 02/25/2015 - CR-20140605-5714 - Commented the populateActivityDateCopy method
						V_1.5 - Modified By - Abhinav Sharma - 06/15/2015 - CR-20150416-8890 - Added new method (populateFieldsOnConsolidatedInvoice)
*/
public without sharing class TaskTriggerHelper {
    
    //final variables
    public final static String STATUS_COMPLETED = 'Completed';
    public final static String SENDER_DISPLAY_NAME = 'Advisory Support';
    public static Map<Id, User> mapUser = new Map<Id, User>();
    
    //This method is to send teh email to Task creatot if task status is completed
    //and Notify Task Owner check box is true.
    public static void notifyTaskCretor(List<Task> oldRecords, List<Task> newRecords) {
        
        //Create a set of user ids to fetch teh user information as the relationship fields can not be tracked directly
        Set<Id> userIds = new Set<Id>();
        
        //loop through the records
        for(Task task : newRecords) {
            userIds.add(task.OwnerId);
            userIds.add(task.CreatedById);
        }
        
        //fetch the user data
        mapUser = new Map<Id, User>([Select Id, Name, Email from User where Id IN: userIds]);
        
        //loop through the tasks
        for(Integer i = 0; i < newRecords.size(); i++) {
            
            //check if task status was not "Completed" and "Notify Task Creator" was unchecked
            if(oldRecords != null && oldRecords.size() > 0) {
                if(newRecords[i].Status != null && newRecords[i].Status != '' 
                    && STATUS_COMPLETED.equalsIgnoreCase(newRecords[i].Status) && newRecords[i].Notify_Task_Creator__c == true
                    && (newRecords[i].Status != oldRecords[i].Status || newRecords[i].Notify_Task_Creator__c != oldRecords[i].Notify_Task_Creator__c)) {
                    
                    //send email to task creator
                    senEmail(newRecords[i]);
                }
            } else if(newRecords[i].Status != null && newRecords[i].Status != '' 
                    && STATUS_COMPLETED.equalsIgnoreCase(newRecords[i].Status) && newRecords[i].Notify_Task_Creator__c == true) {
                    senEmail(newRecords[i]); 
            }
        }
    }
    
    //Commented by - Ajit Surana - 02/25/2015 - CR-20140605-5714  
    public static void populateActivityDateCopy(list<Task> newTaskList) {
        
        // loop through each task and populate the activity date copy
       /* for (Task tsk : newTaskList) {
            
            // update the activity date copy field
            tsk.Activity_Date_Copy__c = tsk.ActivityDate;
        }*/
    }
    
    //method to send an email to task creator
    private static void senEmail(Task task) {
        
        // Create a new single email message object
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        
        //check if user exists in map
        if(mapUser.containsKey(task.CreatedById)) {
            
            // Strings to hold the email address to which we are sending the email.
            List<String> toAddresses = new List<String>{mapUser.get(task.CreatedById).Email};
            
            // Assign the addresses for the To and CC lists to the mail object.
            mail.setToAddresses(toAddresses);
            
            // Specify the name used as the display name.
            mail.setSenderDisplayName(SENDER_DISPLAY_NAME);
            
            // Specify the subject line for your email address.
            mail.setSubject(' A Task you created is now complete'); 
            
            // Specify the text content of the email.
            String emailBody;
            
            emailBody = task.Subject + ', assigned to ' + mapUser.get(task.OwnerId).Name + ' is complete.' +
                         '<BR/><a href=\'' + System.URL.getSalesforceBaseUrl().toExternalForm() + '/' + task.Id + '\'>Click here to view the task</a>' ;
            
            //set html plain body
            mail.setHtmlBody(emailBody);
            
            // Send the email you have created.
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
        }
    }
    
    /**
     *  @description    :   This method is to check if the Testimonial task is being created, then create a new Feed item with user story
     *
     *  @args           :   List of New Tasks
     *
     *  @retun          :   void
     *
     **/
    public static void postMemberImpactStory(List<Task> tasks) {
        
        //Get the Testimonial Record Type
        List<RecordType> recordTypes = [Select Id from RecordType where Name =: Constants.RECORD_TYPE_TASK_DEVELOPER_NAME_TESTIMONIALS AND SObjectType = 'Task'];
        if(recordTypes.size() == 0)
            throw new CustomException('Testimonials Record Type not found.');
        
        //Added By Bhavi Sharma - 04/18/2014 - CR-20140414-5064
        //Set to hold the account Ids
        Set<Id> accountIds = new Set<Id>();
        
        //Loop through the task over here and populate the account Id set
        for(Task t : tasks) {
            
            //Check if it's Member Impact Story
            if(t.RecordTypeId == recordTypes[0].Id && t.Subject == Constants.TASK_SUBJECT_MEMBER_IMPACT_STORY && t.WhatId != null && t.WhatId.getSobjectType() == Schema.Account.sObjectType) {
                
                //Populate account id in set
                accountIds.add(t.WhatId);   
            }
        }    
                
        //Don't do anything if set is blank
        if(accountIds.size() == 0)
            return;
        
        //Fetch account records from database along with Record Type
        Map<Id, Account> mapAccounts = new Map<Id, Account>([Select Id, RecordType.DeveloperName from Account 
                                                                    where Id IN: accountIds AND RecordType.DeveloperName IN (:Constants.RECORD_TYPE_ACCOUNT_DEVELOPER_NAME_US_EDUCATION, :Constants.RECORD_TYPE_ACCOUNT_DEVELOPER_NAME_INTERNATIONAL_EDUCATION)]);
        
        //List of feed items
        List<FeedItem> feedItems = new List<FeedItem>();
        
        //Loop through the list of Task and check if it's a Member Sgare Story
        for(Task t : tasks) {
            
            //Check if it's Member Impact Story
            if(t.RecordTypeId == recordTypes[0].Id && t.Subject == Constants.TASK_SUBJECT_MEMBER_IMPACT_STORY && t.WhatId != null && t.WhatId.getSobjectType() == Schema.Account.sObjectType) {
                
                String submittedBy = UserInfo.getUserName();
                
                if(!String.IsBlank(t.Additional_ABC_Attendees__c)) {
                    
                    //Add Submitted By
                    submittedBy = t.Additional_ABC_Attendees__c.subStringBefore('(').subStringBefore('-');
                } 
                
                //Variable to hold task body
                String body; 
                
                //Check if task description is not null
                if(!String.IsBlank(t.Description)) {
                    
                    //Check if Description is more that 4800 chanracters, than append a Suffix in last to tell user to go the the task detail record to read the complete story
                    if(t.Description.length() > 4800) {
                        
                        body = t.Description.subString(0, 4800) + '.....\r\n';
                        body += 'Go to the task record to read the complete story.';
                    } else {
                        body = t.Description;
                    }
                    
                    //Added By Bhavi Sharma - 04/18/2014 - CR-20140414-5064
                    //Variable to Hold HASH TAG
                    String HASH_TAG = '#HCMemberImpact';
                    
                    //Check if what Id is in Account map, then it's a edication account and assign it #EABMemberImpactStory tag
                    //Else #HCMemberImpactStory
                    if(mapAccounts.containsKey(t.WhatId))
                        HASH_TAG = '#EABMemberImpact';
                    
                    //Add Hash Tag and Submitter Name
                    body = HASH_TAG + ' submitted by ' + submittedBy + '\r\n' + body;
                    System.debug('Body:::::' + body);
                    
                    //Create a new Feed Item
                    String fullRecordURL = URL.getSalesforceBaseUrl().toExternalForm() + '/' + t.Id;
                    feedItems.add(new FeedItem(ParentId = t.WhatId, Body = body, LinkUrl = fullRecordURL, Type = 'LinkPost', Title = Constants.TASK_SUBJECT_MEMBER_IMPACT_STORY ));
                }
            }
        }
        
        //Post feeds
        if(feedItems.size() > 0)
            insert feedItems;
    }
    
    //Added By - Abhinav Sharma - 06/15/2015 - CR-20150416-8890
    /**
     *  @description    :   This method is to pull out the most recent "Last Modified Date" value from 
     * 						the most recent activity task in "Activity History". 
							Then there to populate “Last Follow-Up Date” on consolidate invoice.  
							Similarly, will pull out the associated task/subject that corresponds with 
							the "Last Modified Date" pulled into the “Last Follow Up Note” field on consolidated. 
     *
     *  @args           :   List of New Tasks, Map of old tasks
     *
     *  @retun          :   void
     *
    **/
    public static void populateFieldsOnConsolidatedInvoice(List<Task> tasks, Map<Id, Task> mapOldTasks) {

        //Map of consolidated invoices
        Map<Id, ConsolidatedInvoice__c> mapConsolidatedInvoices = new Map<Id, ConsolidatedInvoice__c>();

        //Checking new record list for null value
        if(tasks != null) {
    
            //Loop through task records
            for(Task tsk : tasks) {
    
                //Insert case
                if(mapOldTasks == null) {
    
                    if(tsk.Status == TaskTriggerHelper.STATUS_COMPLETED 
                        && tsk.WhatId != null 
                        && tsk.WhatId.getSObjectType() == Schema.ConsolidatedInvoice__c.SobjectType)
                        mapConsolidatedInvoices.put(tsk.WhatId, new ConsolidatedInvoice__c(ID = tsk.WhatId, Last_Follow_Up_Date__c = null, Last_Follow_Up_Note__c = null));
                }
            
            	//Update use case
            	if(mapOldTasks != null) {
    
                    //Checking for the field value change on task record update
                    if(tsk.WhatId != mapOldTasks.get(tsk.Id).WhatId
                        || tsk.Status != mapOldTasks.get(tsk.Id).Status
                      	|| tsk.LastModifiedDate != mapOldTasks.get(tsk.Id).LastModifiedDate) {
        
                        //Checking and validating task records for fields values   
                        if(tsk.Status == TaskTriggerHelper.STATUS_COMPLETED 
                            && tsk.WhatId != null 
                            && tsk.WhatId.getSObjectType() == Schema.ConsolidatedInvoice__c.SobjectType)
                            mapConsolidatedInvoices.put(tsk.WhatId, new ConsolidatedInvoice__c(ID = tsk.WhatId, Last_Follow_Up_Date__c = null, Last_Follow_Up_Note__c = null));
        
                        if(mapOldTasks.get(tsk.Id).Status == TaskTriggerHelper.STATUS_COMPLETED
                            && mapOldTasks.get(tsk.Id).WhatID != null
                            && mapOldTasks.get(tsk.Id).WhatId.getSObjectType() == Schema.ConsolidatedInvoice__c.SobjectType)
                            mapConsolidatedInvoices.put(mapOldTasks.get(tsk.Id).WhatID, new ConsolidatedInvoice__c(ID = mapOldTasks.get(tsk.Id).WhatID, Last_Follow_Up_Date__c = null, Last_Follow_Up_Note__c = null));
                    }       
            	}
            }        
        }  
	
        //Delete use cases
        else {
    
            //Loop through old records
            for(Task tk : mapOldTasks.values()) {
    
                if(mapOldTasks.get(tk.Id).Status == TaskTriggerHelper.STATUS_COMPLETED
                    && mapOldTasks.get(tk.Id).WhatID != null
                    && mapOldTasks.get(tk.Id).WhatId.getSObjectType() == Schema.ConsolidatedInvoice__c.SobjectType)
                    mapConsolidatedInvoices.put(mapOldTasks.get(tk.Id).WhatID, new ConsolidatedInvoice__c(ID = mapOldTasks.get(tk.Id).WhatID, Last_Follow_Up_Date__c = null, Last_Follow_Up_Note__c = null));
            }
        }   

        //Checking set for size value
        if(mapConsolidatedInvoices != null && mapConsolidatedInvoices.size() > 0) {
    
            //Loop through opportunity records
            for(ConsolidatedInvoice__c con : [SELECT ID, Last_Follow_Up_Date__c, Last_Follow_Up_Note__c,
                                                (SELECT ID, LastmodifiedDate, Subject FROM ActivityHistories
                                                ORDER BY LastmodifiedDate DESC LIMIT 1)
                                                FROM ConsolidatedInvoice__c 
                                                WHERE ID IN : mapConsolidatedInvoices.keySet()]) {
    
                //Checking if map contains the consolidated invoice record
                if(mapConsolidatedInvoices.containsKey(con.Id) && mapConsolidatedInvoices.get(con.Id) != null) {
					
                    //Checking for associated ActivityHistories list size value
                    if(con.ActivityHistories != null 
                       	&& con.ActivityHistories.size() > 0
                      	&& con.ActivityHistories[0].LastModifiedDate != null) {
                     	mapConsolidatedInvoices.get(con.Id).Last_Follow_Up_Date__c = Date.valueof(con.ActivityHistories[0].LastModifiedDate);
                        mapConsolidatedInvoices.get(con.Id).Last_Follow_Up_Note__c = con.ActivityHistories[0].Subject;
                   } else {
                    	mapConsolidatedInvoices.get(con.Id).Last_Follow_Up_Date__c = null;
                    	mapConsolidatedInvoices.get(con.Id).Last_Follow_Up_Note__c = null;
                    }    
                }
            }
    
            //Updating consolidated invoice records
            Util.BypassAllTriggers = true;
            update mapConsolidatedInvoices.values();
            Util.BypassAllTriggers = false;
        }
    }        
}