global class Batch_NBB implements Database.Batchable<SObject>, Database.Stateful
{
    /*
    Purpose:    Update the NBB Name based on the following criteria:
                    - If NBB has a related Opportunity:
                        - Name = 'NBB - ' + [NBB Opportunity Account Name (truncated if necessary)] + ' - ' + [NBB Opportunity Program Acronym] + ' - ' + [NBB ATL Date]
                        (If Program Acronym or ATL Date are null their values will not be included in the name)
                    - If NBB does not have a related Opportunity:
                        - Name = 'NBB'
                    
    Create By:      
    
    Last Modified By:   Nathan Banas (SAP) - 2/24/2011
    
    Current Version:    v1.2
    
    Revision Log:       v1.0 - () Created code
                        v1.1 - (NB-2011-01-28) Added header, code comments, and reviewed code coverage
                        v1.2 - (NB-2011-02-24) - Added line to track how many records were looked at ('totalprocessed++;')
    */
    
    String debuglog = '\n';
    Integer batchnum = 0;
    Integer totalprocessed = 0;
    public string Query = null;
    
    // Constructor
    global Batch_NBB()
    {
        if(Query == null)
        {
            Query = 'select id, ATL_Date__c, OwnerID, Opportunity__c, Opportunity__r.Program__r.Program_Acronym__c, ' + 
                'Opportunity__r.Account.Name from NBB__c';
        }
    }
    
    // Start(Database.BatchableContext) method from Database.Batchable class
    global Database.queryLocator start(Database.BatchableContext ctx)
    {
        AsyncApexJob a = [SELECT id, ApexClassId, JobItemsProcessed, TotalJobItems, NumberOfErrors,  CreatedBy.Email 
            FROM AsyncApexJob 
            WHERE id = :ctx.getJobId()];
        
        // Send email to indicating the start of this batch
        String emailMessage = 'Your batch job \"Update NBB\" has been started.  Start Time: ' + system.now();
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        String[] toAddresses = new String[] {a.CreatedBy.email};
        mail.setToAddresses(toAddresses);
        mail.setReplyTo('noreply@salesforce.com');
        mail.setSenderDisplayName('ABC Salesforce batch'); 
        mail.setSubject('Batch NBB job started');
        mail.setPlainTextBody(emailMessage);
        
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
        
        return Database.getQueryLocator(Query);
    }
    
    // Execute(Database.BatchableContext, list<Sobject>) method from Database.Batchable class
    global void execute(Database.BatchableContext ctx, list<Sobject> scope)
    {
        // Convert the query of Sobjects into a list of NBB records
        list<NBB__c> recordlist = (list<NBB__c>)scope;
        
        set<Id> ownerids = new set<id>();
        
        // Create a list of NBB Owner Ids
        for ( NBB__c n : recordlist)
        {
            ownerids.add(n.OwnerID);
        }
        
        // Build a map of NBB Owners (Users) w/ their Id as the key
        map<id, User> userid2usermap = new map<id, User>([select id, LastName from User where id in :ownerids]);
        
        // Describe the NBB Name field and retrieve it's max length
        Integer maxnamelength = NBB__c.Name.getDescribe().getLength();
        
        // Loop through all NBB records
        for (NBB__c n : recordlist)
        {
            /* Update NBB Name */
            String prefix = 'NBB - ';
            
            // If the NBB is associated to an Opportunity then process
            if (n.Opportunity__c != null)
            {
                //name
                String suffix;
                if (n.Opportunity__r.Program__r.Program_Acronym__c != null)
                    suffix = ' - ' + n.Opportunity__r.Program__r.Program_Acronym__c;
                else
                    suffix = '';
                
                if (userid2usermap.get(n.OwnerID) != null)
                    suffix += ' - ' + userid2usermap.get(n.OwnerID).LastName;
                    
                if (n.ATL_Date__c != null)
                    suffix += ' - ' + n.ATL_Date__c.format();
                     
                Integer maxaccnamelength = maxnamelength - suffix.length() - prefix.length();
                String longaccname = n.Opportunity__r.Account.Name;
                String shortaccname = longaccname.substring(0, Math.min(maxaccnamelength, longaccname.length()));
                
                n.Name = prefix + shortaccname + suffix;
            }
            else // If the NBB is not associated to an Opportunity then set the name to 'NBB'
                n.Name = 'NBB';
            
            totalprocessed++; // NB - 2011-02-24 - Added line to track how many records were looked at.
        }
        
        try
        {
            update recordlist;
        }
        catch (Exception e)
        {
            debuglog += e.getMessage();
        }
    }
    
    // Finish(Database.BatchableContext) method from Database.Batchable class
    global void finish(Database.BatchableContext ctx)
    {
        AsyncApexJob a = [SELECT id, ApexClassId, 
              JobItemsProcessed, 
              TotalJobItems, 
              NumberOfErrors, 
              CreatedBy.Email 
              FROM AsyncApexJob 
              WHERE id = :ctx.getJobId()];
        
        // Send email to confirming completion of this batch
        String emailMessage = 
          'Your batch job \"Update NBBs\" has finished.  It processed ' + totalprocessed + ' records in ' 
        + a.totalJobItems +
        ' batches.  Of which, ' 
        + a.jobitemsprocessed 
        + ' processed without any exceptions thrown and ' 
        + a.numberOfErrors 
        + ' batches threw unhandled exceptions.<br/><br/>'
        + '<br/>Log of process:<br/>'
        + debuglog;
        
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        String[] toAddresses = new String[] {a.CreatedBy.email};
        
        mail.setToAddresses(toAddresses);
        mail.setReplyTo('noreply@salesforce.com');
        mail.setSenderDisplayName('Salesforce Batch'); 
        mail.setSubject('NBB Batch job completed');
        mail.setPlainTextBody(emailMessage);
        mail.setHtmlBody(emailMessage);
        
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
    }

    static testmethod void testBatch_NBB()
    { 
        //Bypass Dupeblocker
        Util.IsTest(true);
        Test.startTest();
        
        string query = 'select id, ATL_Date__c, OwnerID, Opportunity__c, Opportunity__r.Program__r.Program_Acronym__c, ' + 
            'Opportunity__r.Account.Name from NBB__c limit 200';
        
        System.debug('### Test Batch Query String: ' + query);
    
        Batch_NBB batch = new Batch_NBB();
        batch.Query = query;
    
        Id batchId = Database.executeBatch(batch);
        
        system.assertNotEquals(null, batchId);
               
        System.debug('### Launched Batch : '+batchId);
        
        Test.stopTest();
    }
}