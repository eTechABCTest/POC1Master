global class Batch_MembershipKeyContact implements Database.Batchable<SObject>, Database.Stateful
{
    /*
    Purpose:    Populate Name = [Membership Key Contact's Membership Name (truncated to ensure the entire name is not too long)] ' - ' + [Membership Key Contact's Role__c]
                    
    Create By:      
    
    Last Modified By:   Nathan Banas (SAP) - 2/16/2011
    
    Current Version:    v1.2
    
    Revision Log:       v1.0 - () Created code
                        v1.1 - (NB-2011-01-28) Added header, code comments, and reviewed code coverage
                        v1.2 - (NB-2011-02-16) Added code coverage (79%)
    */
    
    String debuglog = '\n';
    Integer batchnum = 0;
    Integer totalprocessed = 0;
    public string Query = null;
    
    // Constructor
    global Batch_MembershipKeyContact()
    {
        if(Query == null)
        {
            Query = 'select id, Role__c, Membership__r.Name, Membership__r.Account_Name__r.Name, Membership__r.Program__r.Program_Acronym__c from Membership_Key_Contact__c';
        }
    }
    
    // Start(Database.BatchableContext) method from Database.Batchable class
    global Database.queryLocator start(Database.BatchableContext ctx)
    {
        AsyncApexJob a = [SELECT id, ApexClassId, JobItemsProcessed, TotalJobItems, NumberOfErrors,  CreatedBy.Email 
            FROM AsyncApexJob 
            WHERE id = :ctx.getJobId()];
        
        // Send email to indicate the start of this batch
        String emailMessage = 'Your batch job \"Update Membership_Key_Contact__c\" has been started.  Start Time: ' + system.now();
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        String[] toAddresses = new String[] {a.CreatedBy.email};
        mail.setToAddresses(toAddresses);
        mail.setReplyTo('noreply@salesforce.com');
        mail.setSenderDisplayName('ABC Salesforce batch'); 
        mail.setSubject('Batch Membership_Key_Contact__c job started');
        mail.setPlainTextBody(emailMessage);
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
        
        return Database.getQueryLocator(Query);
    }
    
    // Execute(Database.BatchableContext, list<Sobject>) method from Database.Batchable class
    global void execute(Database.BatchableContext ctx, list<Sobject> scope)
    {
        // Flag to indicate a batch is running
        Util.IsBatch = true;
        
        // Translate the list from the Query into a list of Membership Key Contacts
        list<Membership_Key_Contact__c> recordlist = (list<Membership_Key_Contact__c>)scope;
        
        // Describe the Membership Key Contact Name field and get it's max length
        Integer maxnamelength = Membership_Key_Contact__c.Name.getDescribe().getLength();
        
        // Confirm the max length is 80 characters
        system.assertEquals(80, maxnamelength);
        
        // Loop through Membership Key Contacts
        for (Membership_Key_Contact__c mk : recordlist)
        {
            /* Create Name */
            totalprocessed++;
            
            // Populate Suffix
            String suffix = '';
            
            if (mk.Role__c != null)
                suffix += ' - ' + mk.Role__c;
            
            // Define max Length (max field length - suffix length)
            Integer maxmemnamelength = maxnamelength - suffix.length();
            
            String longmemname = ' ';
            
            // Get the Membership Key Contact's Membership Name
            if (mk.Membership__r.Name != null)
                longmemname = mk.Membership__r.Name;
            
            // Truncate the Membership name if necessary to ensure the Membership Key Contact's Name is not too long
            String shortmemname = longmemname.substring(0,(Math.min(maxmemnamelength, longmemname.length())));
            
            try
            {
                // Confirm the name is not too long
                system.assert((shortmemname.length() <= 80), 'Name too long: ' + shortmemname);
                
                // Populate the Name of the Membership Key Contact
                mk.Name = shortmemname + suffix;
            }
            catch (Exception e)
            {
                debuglog += '55name ' + e.getMessage();
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                String[] toAddresses = new String[] {'jeremy.nottingham@synapticap.com'};
                
                mail.setToAddresses(toAddresses);
                mail.setReplyTo('noreply@salesforce.com');
                mail.setSenderDisplayName('Salesforce Batch'); 
                mail.setSubject('membership key contacts exception');
                mail.setPlainTextBody('line 55 membershipkeycontactbatch <br/>shortmemname ' + shortmemname + ' suffix ' + suffix 
                    + '<br/>error: ' + e.GetMessage());
                
                Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
            }
        }
        
        // Update Membership Key Contacts
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
        
        // Send email to confirm completion of this batch
        String emailMessage = 
          'Your batch job \"Update membership key contacts\" has finished.  It processed ' + totalprocessed + ' records in ' 
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
        mail.setSubject('membership key contacts Batch job completed');
        mail.setPlainTextBody(emailMessage);
        mail.setHtmlBody(emailMessage);
        
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
    }
    
    static testmethod void testBatch_MembershipKeyContact()
    { 
        //Bypass Dupeblocker
        Util.IsTest(true);
        string query = 'select id, Role__c, Membership__r.Name, Membership__r.Account_Name__r.Name, Membership__r.Program__r.Program_Acronym__c from Membership_Key_Contact__c limit 200';
        
        System.debug('### Test Batch Query String: ' + query);

        Test.startTest();
    
        Batch_MembershipKeyContact batch = new Batch_MembershipKeyContact();
        batch.Query = query;
    
        Id batchId = Database.executeBatch(batch);
        
        system.assertNotEquals(null, batchId);
               
        System.debug('### Launched Batch : '+batchId);
        
        Test.stopTest();
    }
}