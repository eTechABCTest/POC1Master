/**
*    Purpose         :   Scheduler class to send emails to PSE_resources(Contacts), by using the email template "PSA_Timecard_Pre_Reminder"
*                
*    Create By       :   Mahendra Swarnkar
*    
*    Created Date    :   09/20/2016
*    
*    Revision Log    :   V1.0 - Created By - Mahendra Swarnkar - CR-20160609-9909 
*                       
**/
global class Sched_SentEmailTimeCardPreReminder implements Schedulable {
    
    //Query String
    public String queryString ;
    
    //Scheduler's Execute method
    Global void execute(SchedulableContext sc) {
        
        //By Pass All the triggers
        Util.BypassAllTriggers = true;
        
        //Set Query string to default if it is blank
        if(String.isBlank(queryString)) {
            
            queryString = 'Select Id, Email From Contact '+
                'where ( Email != null OR Email != \'\') '+
                'AND Contact_Status__c = \'Active\' '+
                'AND pse__Is_Resource__c = True';
        }
        
        //Fetch the Email Template "PSA Timecard Pre-Reminder" record
        List<EmailTemplate> emailTemplates = [Select Id From EmailTemplate where DeveloperName = 'PSA_Timecard_Pre_Reminder' AND IsActive = true];
        
        //Fetch From Address 
        List<OrgWideEmailAddress> listOrgWideEmailAdd = [select Id from OrgWideEmailAddress where Address = 'noreply@advisory.com'];
        
        //Create a list of SingleEmailMessage instance
        List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();
        
        //Check for Email Template
        if(emailTemplates != null && emailTemplates.size() > 0){
            
            //Fetch All the Contacts and populate the Set with their email address
            for(Contact cont : Database.query(queryString)) {
                
                //Set to hold the Email address of all contacts
                List<String> toAddressContactEmails = new List<String>();
                
                //List to hold contact Ids
                List<Contact> listContactIds = new List<Contact>();
                
                //Check for contact email
                if(String.isNotBlank(cont.Email)){
                    toAddressContactEmails.add(cont.Email);
                    
                    //Create Email
                    Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                    mail.setTemplateId(emailTemplates[0].Id);
                    mail.setToAddresses(toAddressContactEmails);
                    mail.setSaveAsActivity(false);
                    mail.setTargetObjectId(cont.Id);
                    
                    //Setting From Address
                    if(listOrgWideEmailAdd != null && listOrgWideEmailAdd.size() > 0 )
                        mail.setOrgWideEmailAddressId(listOrgWideEmailAdd[0].Id);
                    
                    //Populating the emails
                    emails.add(mail);
                }
            }
        }
        
        //Check for size
        if(emails.size() > 0){
            
            //Send emails to respective emails addresses
            Messaging.sendEmail(emails);
        }
    }
    
}