global class Batch_Contract implements Database.Batchable<SObject>, Database.Stateful
{
    /*
    Purpose:    Perform the following actions:
                    - Update Contract Name as follows: [acc name] - [ prog acro] - [Year__c]
                    - Update Contract Invoice Contact based on Opportunity Contact Roles
                    - Update Business_Line_From_Trigger__c, used for Roll Up Summary filtering
                    - Update Contract Negotiated By based on the following:
                        - Contract Source Opportunity not null AND (Source Opportunity Recordtype Name equals 'RI Marketing' OR Source Opportunity Recordtype Name equals 'PT Marketing'
                            - c.Negotiated_By__c = c.Source_Opportunity__r.Marketer__c;
                        - Contract Source Opportunity not null
                            - c.Negotiated_By__c = c.Source_Opportunity__r.OwnerId;
                    - Update Contract Active checkbox
                        - Contract Start >= today && Contract End >= today then true else false
    Create By:          
    
    Last Modified By:   Jeremy Nottingham (SAP) - 5/9/2011
    
    Current Version:    v1.2
    
    Revision Log:       v1.0 - () Created code
                        v1.1 - (NB-2011-01-28) Added header, code comments, and reviewed code coverage
                        v1.2 - (JN 5/9/11) Changed naming convention for Contract to use Year__c instead of Start__c.Year() - 1
    */
    
    String debuglog = '\n';
    Integer batchnum = 0;
    Integer totalprocessed = 0;
    public string Query = null; 
    
    global Batch_Contract()
    {
        if(Query == null)
        {
            Query = 'select id, Payer_Account__r.Name, Program__r.Program_Acronym__c, Program__r.Business_Line__c, Start__c, ' + 
            'Source_Opportunity__c, Source_Opportunity__r.Recordtype.Name, Source_Opportunity__r.Marketer__c, Source_Opportunity__r.OwnerID, End__c ' +
            'from Contract__c';
        }
    }
    
    // Start(Database.BatchableContext) method from Database.Batchable class
    global Database.queryLocator start(Database.BatchableContext ctx)
    {
        AsyncApexJob a = [SELECT id, ApexClassId, JobItemsProcessed, TotalJobItems, NumberOfErrors,  CreatedBy.Email 
            FROM AsyncApexJob 
            WHERE id = :ctx.getJobId()];
        
        // Send email indicating the start of this batch
        String emailMessage = 'Your batch job \"Update Contract__c\" has been started.  Start Time: ' + system.now();
            
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        String[] toAddresses = new String[] {a.CreatedBy.email};
        
        mail.setToAddresses(toAddresses);
        mail.setReplyTo('noreply@salesforce.com');
        mail.setSenderDisplayName('ABC Salesforce batch'); 
        mail.setSubject('Batch Contract__c job started');
        mail.setPlainTextBody(emailMessage);
        
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
        
        // Query all Contracts
        return Database.getQueryLocator(Query);
    }
    
    // Execute(Database.BatchableContext, list<Sobject>) method from Database.Batchable class
    global void execute(Database.BatchableContext ctx, list<Sobject> scope)
    {
        Util.isBatch = true;
        
        // Convert the queried Contracts into a list of Contracts
        list<Contract__c> recordlist = (list<Contract__c>)scope;
        
        // Describe the Contract Name object and get it's max length
        Integer maxnamelength = Contract__c.Name.getDescribe().getLength();
        
        // Set to store Source Opportunity Ids
        set<Id> sourceoppids = new set<id>();
        
        // Loop through Contracts from query and build a list of Source Opportunities
        for (Contract__c c : recordlist)
        {
            if (c.Source_Opportunity__c != null)
                sourceoppids.add(c.Source_Opportunity__c);
        }
        
        // Map of Source Opportunities w/ their Id as the key
        map<id, Opportunity> oppid2oppmap = new map<id, Opportunity>([select id, (select id, ContactID, Role from OpportunityContactRoles where Role = 'Invoice Contact')
            from Opportunity where id in :sourceoppids]);
        
        // Loop through Contracts
        for (Contract__c c : recordlist)
        {
            // From Contract trigger
            
            /* Update Name as follows: [acc name] - [ prog acro] - [TEXT(Year__c)] */
            String suffix = '';
            
            if ((c.Program__c != null) && ( c.Program__r.Program_Acronym__c != null))
                suffix = ' - ' + c.Program__r.Program_Acronym__c;
                
            if (c.Year__c != null)
                suffix += ' - ' + c.Year__c; //(Integer.valueOf(c.Start__c.year()) - 1);
                
            Integer maxaccname = maxnamelength - suffix.length();
            
            if ((c.Payer_Account__c != null) && (c.Payer_Account__r.Name != null))
            {
                String fullaccname = c.Payer_Account__r.Name;
                String shortname = fullaccname.substring(0,Math.min(fullaccname.length(), maxaccname));
                c.Name = shortname + suffix;
            }
            else
            {
                c.Name = 'Unknown Institution' + suffix;
            }
            
            
            /* Update Invoice Contact */
            if (oppid2oppmap.keyset().contains(c.Source_Opportunity__c) && oppid2oppmap.get(c.Source_Opportunity__c).OpportunityContactRoles != null)
            {
                // Loop through Source Opportunity Contact Roles matching a Role of 'Invoice Contact' and set the Contract's Invoice Contact
                // If multiple are specified, only the last one will be listed.
                for (OpportunityContactRole ocr : oppid2oppmap.get(c.Source_Opportunity__c).OpportunityContactRoles)
                {
                    c.Invoice_Contact__c = ocr.ContactId;
                }
            }


            /* Update Business_Line_From_Trigger__c, used for Roll Up Summary filtering */
            if ((c.Program__c != null) || (c.Program__r.Business_Line__c != null))
                c.Business_Line_From_Trigger__c = c.Program__r.Business_Line__c;
            
            
            //From Opp trigger
            /* Update Negotiated By */
            if ((c.Source_Opportunity__c != null) && ((c.Source_Opportunity__r.Recordtype.Name == 'RI Marketing') || (c.Source_Opportunity__r.Recordtype.Name == 'PT Marketing'))) 
            {
                if (c.Source_Opportunity__r.Marketer__c != null)
                    c.Negotiated_By__c = c.Source_Opportunity__r.Marketer__c;
            }
            else if(c.Source_Opportunity__c != null)
            {
                c.Negotiated_By__c = c.Source_Opportunity__r.OwnerID;
            }
            
            
            /* Set Active checkbox */
            if (c.Start__c <= system.today() && c.End__c >= system.today())
                c.Active__c = true;
            else
                c.Active__c = false;
        }
        
        // Update Contracts
        try
        {
            update recordlist;
        }
        catch (Exception e)
        {
            // Record any errors to a debuglog variable that will be returned in the completion email
            debuglog += e.getMessage();
        }
    }
    
    // Finished(Database.BatchableContext) method from Database.Batchable class
    global void finish(Database.BatchableContext ctx)
    {
        AsyncApexJob a = [SELECT id, ApexClassId, 
              JobItemsProcessed, 
              TotalJobItems, 
              NumberOfErrors, 
              CreatedBy.Email 
              FROM AsyncApexJob 
              WHERE id = :ctx.getJobId()];
        
        // Send email indicating the completion of this batch
        String emailMessage = 
          'Your batch job \"Update Contract__c\" has finished.  It processed ' + totalprocessed + ' records in ' 
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
        mail.setSubject('Contract__c Batch job completed');
        mail.setPlainTextBody(emailMessage);
        mail.setHtmlBody(emailMessage);
        
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
    }

    static testmethod void testBatch_Contract()
    { 
        //Bypass Dupeblocker
        Util.IsTest(true);
        Test.startTest();
        
        string query = 'select id, Payer_Account__r.Name, Program__r.Program_Acronym__c, Program__r.Business_Line__c, Start__c, ' + 
            'Source_Opportunity__c, Source_Opportunity__r.Recordtype.Name, Source_Opportunity__r.Marketer__c, Source_Opportunity__r.OwnerID, End__c ' +
            'from Contract__c limit 200';
        
        System.debug('### Test Batch Query String: ' + query);
    
        Batch_Contract batch = new Batch_Contract();
        batch.Query = query;
    
        Id batchId = Database.executeBatch(batch);
        
        system.assertNotEquals(null, batchId);
               
        System.debug('### Launched Batch : '+batchId);
        
        Test.stopTest();
    }
}