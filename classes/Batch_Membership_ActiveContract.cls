global class Batch_Membership_ActiveContract implements Database.Batchable<SObject>, Database.Stateful
{
    /*
    Purpose:    In-Place batch to update all Membership records, ideally only run once after data import.
        
                For each Membership, query Contracts and Contract Integrated Accounts to figure out which Contract is the 
                Earliest, 
                Latest  
                Active Identified 
                Owner
                  If Membership_Status__c contains 'Prospect'
                    Assigned_Marketer__c
                  Else
                    Active_Contract_Identified__r.Contract_Renewal_Opportunity__r.OwnerID
                  If null, no change    
    Create By:      
    
    Last Modified By:   Nathan Banas (SAP) - 1/28/2011
    
    Current Version:    v1.2
    
    Revision Log:       v1.0 - () Created code
                        v1.1 - (JN-2011-01-11) Updated to include additional parameters
                        v1.2 - (NB-2011-01-28) Added header, code comments, and reviewed code coverage
                        v1.3 - (Bhavi Sharma) - 04/26/2013 - CR-20130111-2110 - Update Membership's Join_Date_Most_Recent__c field with the oldest Join_Date__c value from all active Contracts
    */
     
    String debuglog = '\n';
    
    // Query to be used to pull Memberships
    global String querystring = 'select id, Program__c, Account_Name__c,'
            + ' Earliest_Contract__c, Latest_Contract__c, Active_Contract_Idenfied__c, Batch_Status__c, Membership_Status__c, Assigned_Marketer__c, OwnerId'
            + ' from Membership__c'
            + ' where Program__c != null and Account_Name__c != null ORDER BY CreatedDate ASC';
            //+ ' and Batch_Status__c != \'012711\'';
            //+ ' limit 200';
    Integer batchnum = 0;
    Integer totalprocessed = 0;
    
    // Constructor
    global Batch_Membership_ActiveContract()
    {
            
    }
    
    // Start(Database.BatchableContext) method from Database.Batchable class
    global Database.queryLocator start(Database.BatchableContext ctx)
    {
        AsyncApexJob a = [SELECT id, ApexClassId, JobItemsProcessed, TotalJobItems, NumberOfErrors,  CreatedBy.Email 
            FROM AsyncApexJob 
            WHERE id = :ctx.getJobId()]; 
        
        // Send email to indicate the start of this batch
        String emailMessage = 'Your batch job \"Update Membership__c\" has been started.  Start Time: ' + system.now()
            + '<br/>Query: \"' + querystring;
            
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        String[] toAddresses = new String[] {a.CreatedBy.email};
        
        mail.setToAddresses(toAddresses);
        mail.setReplyTo('noreply@salesforce.com');
        mail.setSenderDisplayName('ABC Salesforce batch'); 
        mail.setSubject('Batch Membership__c Active Contract job started');
        mail.setPlainTextBody(emailMessage);
        
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
        
        return Database.getQueryLocator(querystring);
    }
    
    // Execute(Database.BatchableContext, list<Sobject>) method from Database.Batchable class
    global void execute(Database.BatchableContext ctx, list<Sobject> scope)
    {
        Util.IsBatch = true;
        
        list<Membership__c> recordlist = (list<Membership__c>)scope;
        list<Membership__c> memstoupdate = new list<Membership__c>();
        set<id> updatememids = new set<id>();
        set<Id> accids = new set<id>();
        set<Id> progids = new set<id>();
        set<Id> ciaContractIds = new set<id>();
        debuglog += 'start of batch. ' + recordlist[0].id;
        
        //get big sets of Accounts and Programs
        for (Membership__c m : recordlist)
        {
            accids.add(m.Account_Name__c);
            progids.add(m.Program__c);
        }
        
        //get set of Contract Ids on the basis of matching Contract Integrated Accounts 
        List<Contract_Integrated_Accounts__c> ciaList = [select Id, Account__c, Contract__c, Contract__r.Program__c from Contract_Integrated_Accounts__c 
            where (Account__c in :accids) 
            and (Contract__r.Program__c in :progids)];
        
        // Build a list of Contract Ids related to Contract Integrated Accounts
        for(Contract_Integrated_Accounts__c cia : ciaList)
        {
            for (Membership__c m : recordlist)
            {
                if (cia.Contract__c != null && cia.Contract__r.Program__c == m.Program__c && cia.Account__c == m.Account_Name__c)
                {
                    //Found a match between this CIA/Contract and current Membership. Add it to the good list.
                    ciaContractIds.add(cia.Contract__c);
                }
            }
        }
        
        // Query Contracts based on listed from above
        list<Contract__c> contracts = [select id, Active__c, Join_Date__c, Start__c, End__c, Program__c, Payer_Account__c, 
            Contract_Renewal_Opportunity__c, Contract_Renewal_Opportunity__r.OwnerId,
            (select id, Account__c from Contract_Integrated_Accounts__r where Account__c in :accids)
            from Contract__c 
            where ((id in :ciaContractIds) or (Payer_Account__c in :accids and Program__c in :progids))
            and (Status__c = 'ATL' or Status__c = 'Honorary' or Status__c = 'Dropped') AND Active__c = true]; // Nathan B 1/5/11 - Added Status condition
        
        // Map to store list of Contracts w/ their Id as the key
        map<id, Contract__c> conid2conmap = new map<id, Contract__c>(contracts);
        
        debuglog += '<br/>accounts found: ' + accids.size() + ' progs found: ' + progids.size() + ' contracts found: ' + contracts.size();
        
        map<id, list<Contract__c>> accid2contractlistmap = new map<id, list<Contract__c>>();
        map<id, set<Id>> accid2contractidsetmap = new map<id, set<id>>(); //acc id to Contract IDs, to make sure we don't add the same Contract twice
        
        //go through contracts (and Contract Integrated Accounts) for identified Memberships and put in sets by account number
        for (Contract__c c : contracts)
        {
            if (accid2contractidsetmap.get(c.Payer_Account__c) == null) 
                accid2contractidsetmap.put(c.Payer_Account__c, new set<id>{c.id});
            else
                accid2contractidsetmap.get(c.Payer_Account__c).add(c.id);
                
            //Go through entire list of Contract Integrated Accounts on this Contract as possible connections. 1/11/11 jn
            for (Contract_Integrated_Accounts__c cia : c.Contract_Integrated_Accounts__r)
            {
                if (accid2contractidsetmap.get(cia.Account__c) == null) 
                    accid2contractidsetmap.put(cia.Account__c, new set<id>{c.id});
                else
                    accid2contractidsetmap.get(cia.Account__c).add(c.id);
            }
        } //end for contracts
        
        //convert id sets into contract lists by account ID
        for (Id i : accid2contractidsetmap.keyset())
        {
            accid2contractlistmap.put(i,new list<Contract__c>());
            for (Id cid : accid2contractidsetmap.get(i))
            {
                accid2contractlistmap.get(i).add(conid2conmap.get(cid));
            }
        }
        
        // create a variable to use for debugging
        String thisdebuglog = '';
        
        // Loop through all Memberships
        for (Membership__c m : recordlist)
        {
            totalprocessed++;
            /*m.Batch_Status__c = '012711';
            m.Earliest_Contract__c = null;
            m.Latest_Contract__c = null;
            m.Active_Contract_Idenfied__c = null;
            m.Join_Date_Most_Recent__c = null;*/
             
             // Create placeholders for the Earliest, Latest, Latest Active, and Earliest Future Contracts
            Contract__c earliestContract = null;
            Contract__c latestContract = null;
            Contract__c latestActiveContract = null;
            Contract__c earliestFutureContract = null;
            Date mostRecentJoinDate = null;
            
            // Process only if the Membership's Program and Account are not null
            if(m.Program__c != null && m.Account_Name__c != null)
            {
                // Process only if we can retrieve Contracts associated w/ the Membership's account
                if (accid2contractlistmap.get(m.Account_Name__c) != null)
                {
                    //go through list of contracts for membership Institution(Account)
                    for (Contract__c acon : accid2contractlistmap.get(m.Account_Name__c)) {
                        if (acon.Program__c != m.Program__c) continue; 
                        /*
                        //earliest contract
                        if ((acon.Start__c != null) 
                            && ((earliestContract == null)  || (acon.Start__c < earliestContract.Start__c))) 
                        {
                            earliestContract = acon;
                        }
                        
                        //latest contract
                        if ((acon.End__c != null)
                            && ((latestContract == null) || (acon.End__c > latestContract.End__c))) 
                        {
                            latestContract = acon;
                        }
                        
                        //active contract idenfied
                        if ((acon.Start__c != null) 
                            && (acon.End__c != null)
                            && (acon.Start__c <= system.today()) 
                            && (acon.End__c >= system.today())
                            && ((latestActiveContract == null) || (acon.End__c > latestActiveContract.End__c)))
                        {
                            latestActiveContract = acon;
                        }
                        
                        //earliest Future Contract (to use for Active Contract Idenfied if there is none found within its dates)
                        if ((acon.Start__c != null) 
                            && (acon.End__c != null)
                            && (acon.Start__c > system.today())
                            && ((earliestFutureContract == null) || (acon.Start__c < earliestFutureContract.Start__c)))
                        {
                            earliestFutureContract = acon;
                        }*/
                        
                        //Bhavi Sharma - 04/26/2013 - Set oldest date as mostRecentJoinDate
                        if(acon.Active__c == true && acon.Join_Date__c != null && (mostRecentJoinDate == null || acon.Join_Date__c < mostRecentJoinDate )) {
                        	
                        	//Set join date as most recent
                        	mostRecentJoinDate = acon.Join_Date__c;
                        }    
                        
                    }//end for acon
                    
                    /*if (latestActiveContract == null)
                        latestActiveContract = earliestFutureContract;
                    */
                } //end if account and program null
                
                //put calculated values into appropriate fields
                /*if (earliestContract != null)
                    m.Earliest_Contract__c = earliestContract.id;
                if (latestContract != null)
                    m.Latest_Contract__c = latestContract.id;
                if (latestActiveContract != null)
                    m.Active_Contract_Idenfied__c = latestActiveContract.id;*/
                if(mostRecentJoinDate != null) {
                	m.Join_Date_Most_Recent__c = mostRecentJoinDate;
                	memstoupdate.add(m);
                }
                  /*  
                //Membership Owner section
                if (m.Membership_Status__c != null && m.Membership_Status__c.contains('Prospect')) {
                    if (m.Assigned_Marketer__c != null) m.OwnerId = m.Assigned_Marketer__c;
                } else if ((latestActiveContract != null) && (latestActiveContract.Contract_Renewal_Opportunity__c != null )) 
                {
                    m.OwnerId = latestActiveContract.Contract_Renewal_Opportunity__r.OwnerId;
                }
                */
            }//end for m 
        }
        
        // Update Memberships
        try
        {
        	Util.IsBatch = true;
            Util.BypassAllTriggers = true;
            if (memstoupdate.size() > 0) update memstoupdate;
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
          'Your batch job \"Update Membership__c active/earliest/latest contract\" has finished.  It processed ' + totalprocessed + ' records in ' 
        + a.totalJobItems +
        ' batches.  Of which, ' 
        + (a.jobitemsprocessed - a.numberOfErrors)
        + ' batches processed without any exceptions thrown and ' 
        + a.numberOfErrors 
        + ' batches threw unhandled exceptions.<br/><br/>'
        + ' Total Processed: ' + totalprocessed
        + '<br/>Log of process:<br/>'
        + debuglog;
        
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        String[] toAddresses = new String[] {a.CreatedBy.email};
        
        mail.setToAddresses(toAddresses);
        mail.setReplyTo('noreply@salesforce.com');
        mail.setSenderDisplayName('Salesforce Batch'); 
        mail.setSubject('Membership__c Batch Active Contract job completed');
        mail.setPlainTextBody(emailMessage);
        mail.setHtmlBody(emailMessage);
        
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
    }
    
    static testmethod void testBatch_Membership_ActiveContract()
    { 
        //Bypass Dupeblocker
        Util.IsTest(true);
        Util.IsTesting = true;
        
        //Account acc = [select id from Account limit 1];
        Account acc = new Account(Name = 'testacc', Account_Formal_Name__c = 'testacc');
        insert acc;
        
        //Program__c prog = [select id from Program__c limit 1];
        Program__c prog = new Program__c(Name = 'testprog', Program_Acronym__c = 'TEST');
		insert prog;
		
        Membership__c testmem = new Membership__c(
            Account_Name__c = acc.id,
            Program__c = prog.id);
        insert testmem;
        
test.startTest();
        Batch_Membership_ActiveContract bmac = new Batch_Membership_ActiveContract();
        bmac.querystring = 'select id, Program__c, Account_Name__c,'
            + ' Earliest_Contract__c, Latest_Contract__c, Active_Contract_Idenfied__c, Batch_Status__c'
            + ' from Membership__c'
            + ' where id = \'' + testmem.id + '\''
            + ' limit 20';
        Database.executeBatch(bmac);
test.StopTest();
    }
}