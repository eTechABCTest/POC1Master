global class Batch_Opportunity_ClearVisitSummaries implements Database.Batchable<SObject>, Database.Stateful {

    /*
    Purpose:    To clear the Visit Summary fields on Opportunity 
    
    Create By:  Drew Freeman - 8/20/2011            
    
    Last Modified By:   
    
    Current Version:    v1.0
    
    Revision Log:       v1.1 - (SUNJ) Update Proposal_Value__c with Amount
                        v1.2 - Modified By - (Abhinav Sharma) - Finish Deleting fields from Release 29 - 06/02/2014 - CR-20131120-4008  
                        v1.3 - Modified By - Subhash Garhwal - 07/13/2016 - CR-20160414-9762
                        v1.4 - Modified By - Subhash Garhwal - 10/12/2016 - Q2C Hypercare of Hypercare 
    
    Code Coverage as of 1/26/2011: xx%
    */
    
    public string Query = null;
    
    String debuglog = '\n';
    Integer batchnum = 0;
    Integer totalprocessed = 0;
    Integer totalNeedingUpdated = 0;
    Integer totalSuccessfulUpdates = 0;
    
    global Batch_Opportunity_ClearVisitSummaries() {
    }
    
    global Database.queryLocator start(Database.BatchableContext ctx) {

        AsyncApexJob a = [SELECT id, ApexClassId, JobItemsProcessed, TotalJobItems, NumberOfErrors,  CreatedBy.Email 
            FROM AsyncApexJob 
            WHERE id = :ctx.getJobId()];
        
        System.debug('### Current Query: ' + Query);

        if(Query == null) {
            Query = 'select id, Trigger_Update__c, CreatedDate, Previous_Year_Visits__c, Previous_YTD_Visits__c, Current_YTD_Visits__c, ' +
            'X2012_Visits__c, X2013_Visits__c, ' + 
            'X2014_Visits__c, X2015_Visits__c from Opportunity where ' + 
            '((Previous_Year_Visits__c != 0) or (Previous_YTD_Visits__c != 0) or (Current_YTD_Visits__c != 0))';
        }
        
        System.debug('### Executing Batch for Query: ' + Query);
        
        return Database.getQueryLocator(Query);
    }
    
    global void execute(Database.BatchableContext ctx, list<Sobject> scope) {

        system.debug('### BEGIN BATCH_Opportunity_VisitSummaries ###');
        
        // Set bypass value to ensure triggers do not run
        Util.IsBatch = true;
        
        list<Opportunity> recordList = (list<Opportunity>)scope;
        
        DateTime BatchStartDateTime = System.now();
        
        List<Opportunity> oppsToUpdate = new List<Opportunity>();

        // Loop through Opportunities to zero the visit counts          
        for(Opportunity o : recordList) {

            // Increment counter of records processed
            totalprocessed++;

            o.Previous_Year_Visits__c = 0;
            o.Previous_YTD_Visits__c = 0;
            o.Current_YTD_Visits__c = 0;
            
            o.Trigger_Update__c = true;
            oppsToUpdate.add(o);
            totalNeedingUpdated++;
        }
            
        if(oppsToUpdate.size() > 0) {           
            // Update Opportunities to include Visit Summaries
            
            Database.SaveResult[] srs =  Database.update(oppstoupdate, false);
        
            for(Database.SaveResult sr : srs) {
                if(sr.isSuccess()) {
                    totalSuccessfulUpdates++;
                } else {
                    debuglog += '<br/>' + sr.getId() + ' failed to update.';
                    for(Database.Error err : sr.getErrors()) {
                        debuglog += '<br/>' + err.getMessage();
                    }
                }
            }
        }
        
        system.debug('### END Batch_Opportunity_ClearVisitSummaries ###');
    }
    
    global void finish(Database.BatchableContext ctx) {
        AsyncApexJob a = [SELECT id, ApexClassId, 
              JobItemsProcessed, 
              TotalJobItems, 
              NumberOfErrors, 
              CreatedBy.Email 
              FROM AsyncApexJob 
              WHERE id = :ctx.getJobId()];
        
         String emailMessage = 
            'Your batch job \"Batch_Opportunity_ClearVisitSummaries\" has finished.  It processed ' + totalprocessed + ' records in ' 
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
        mail.setSubject('Batch_Opportunity_VisitSummaries job completed');
        mail.setPlainTextBody(emailMessage);
        mail.setHtmlBody(emailMessage);
        
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
    }
    
    static testmethod void testBatch_Opportunity_ClearVisitSummaries() { 
        //Bypass Dupeblocker
        Util.IsTest(true);
        Util.IsTesting = true;
        
        Test.startTest();
        
        // Create Test Data
        Program__c testProg = new Program__c(Name = 'Test Prog', Program_Acronym__c = 'ZZT');
        insert testProg;
        
        Account testacct = new Account(Name = 'Test_Acct');
        insert testAcct;
        
        //Added - Subhash Garhwal - 07/13/2016 - CR-20160414-9762
        /***********              Start                 ************/
        
        // ensure that the record type custom setting has been updated with the correct values
        Util.resetRecordtypeSettings();
                                                                                             
        //List of Record Type setting
        List<Recordtype_Setting__c> recordTypesSetting = new List<Recordtype_Setting__c>();
        
        //Loop over the Record Types
        for(RecordType rT : [Select Id, Name, DeveloperName From RecordType Where DeveloperName IN ('Program_RI_Marketing', 'Program_PT_Marketing')]) {
            
            recordTypesSetting.add(new Recordtype_Setting__c(Name = rT.Id + 'DN', Name__c = rT.DeveloperName, SFID__c = rT.Id, SObjectType__c = 'Opportunity'));                                                                                        
        }
        
        //Insert
        insert recordTypesSetting;
        
        //Opportunity Record Type map
        Map<String, Id> rtmap = Util.recordtypemap('Opportunity');
        
        set<string> oppRecTypes = new set<String>{rtmap.get('RI Marketing'), rtmap.get('PT Marketing'), rtmap.get('Program – RI Marketing'), rtmap.get('Program – PT Marketing')};
        
        List<Opportunity> testOpps = new List<Opportunity>();
        
        for(integer i = 0; i<2; i++)
        {
            for(string oppRec : oppRecTypes)
            {
                Opportunity o = new Opportunity(Name = 'TestOpp' + i.format(), RecordTypeId = oppRec, Amount = 1, StageName ='Prospect', CloseDate = System.today(), Program__c = testProg.Id, AccountId = testAcct.Id);
                
                testOpps.add(o);
            }
        }
        insert(testOpps);
        
        Date startD = Date.newInstance(2004, System.Today().month(), System.Today().day());
        Time startT = System.now().time();
        Time endT = System.now().time().addHours(1);
                
        DateTime startDateTime = DateTime.newInstance(startD, startT);
        Date startDate = Date.newInstance(startDateTime.year(), startDateTime.month(), startDateTime.day());
        DateTime endDateTime = DateTime.newInstance(startD, endT);
        
        set<String> eventTypes = new set<String>{ 'In Person Visit', 'Phone Appointment' };     
        List<Event> testEvents = new List<Event>();
        List<Id> testOppIds = new List<Id>();
        
        for(integer x = 0 ; x < testOpps.size(); x++)
        {
            // Add opportunity Id to list
            testOppIds.add(testOpps[x].Id);
            
            // Create test events
            for(integer i = 0; i < 13; i++)
            {
                for(string evtType : eventTypes)
                {
                    /*
                    Counted Event Types:
                    "In Person Visit",
                    "Opportunity Visit - For Opportunity Goal",
                    "Prospect Meeting Attendee - Count as Visit"
                    */
                    
                    Event evnt = new Event(
                        whatId = testOpps[x].Id,
                        ActivityDate = startDate.addYears(i),
                        ActivityDateTime = startDateTime.addYears(i),
                        StartDateTime = startDateTime.addYears(i),
                        EndDateTime = endDateTime.addYears(i),
                        Event_Type__c = evtType);
                        
                    testEvents.add(evnt);
                    
                    if(x == 1)
                        break;
                }
            }
        }
        
        // Run Test Batch
        Batch_Opportunity_ClearVisitSummaries batch = new Batch_Opportunity_ClearVisitSummaries();
        batch.Query = 'select id, CreatedDate, Previous_Year_Visits__c, Previous_YTD_Visits__c, Current_YTD_Visits__c, ' +
                '(select Id, ActivityDate, StartDateTime, Event_Type__c from Events where Event_Type__c = \'In Person Visit\' OR ' +
                    ' Event_Type__c = \'Opportunity Visit - For Opportunity Goal\' OR ' +
                    ' Event_Type__c = \'Prospect Meeting Attendee - Count as Visit\') ' +
            'from Opportunity where Id = \'' + testOpps[0].Id + '\' OR Id = \'' + testOpps[1].Id + '\' Order By CreatedDate desc';
            
        System.debug('### Test Batch Query String: ' + batch.Query);
    
        Id batchId = Database.executeBatch(batch);
        
        system.assertNotEquals(null, batchId);
        
        Test.stopTest();
    }
}