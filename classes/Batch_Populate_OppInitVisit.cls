/**
  *  Purpose     :    Populate the Opp Initial Visit Date and Activity Date Clone field on all activities
  *                  
  *  Create By   :   Victor Hanson
  *  
  *  Created Date:   11/27/2013
  *  
  *  Revision Log:  v1.0 - Created
  *              :  v1.1 - Modified by - Ajit Surana - 02/25/2015 - CR-20140605-5714
  *                 
 **/
global class Batch_Populate_OppInitVisit implements Database.Batchable<SObject> {
    
    public String queryStr = null;
    public boolean isEvent = false;
    public String errors = '';
    
    //Override Start method
    global Database.queryLocator start(Database.BatchableContext ctx) {
        
        if (queryStr == null) {
            
            if (isEvent) {
                
                //Remove Activity_Date_Copy__c from the Query by - Ajit Surana - 02/25/2015 - CR-20140605-5714
                queryStr = 'SELECT Id, ActivityDate, StartDateTime, What.Type, WhatId, Opp_Initial_Visit_Date__c ' +
                            'FROM Event WHERE IsRecurrence = false ORDER BY WhatId ASC ALL ROWS';
            }
            else {
                
                //Remove Activity_Date_Copy__c from the Query by - Ajit Surana - 02/25/2015 - CR-20140605-5714
                queryStr = 'SELECT Id, ActivityDate, What.Type, WhatId, Opp_Initial_Visit_Date__c ' +
                            'FROM Task WHERE IsRecurrence = false ORDER BY WhatId ASC ALL ROWS';
            }
        }
        
        // Query all Memberships with Future status
        return Database.getQueryLocator(queryStr);  
    }
    
    //Override execute method
    global void execute(Database.BatchableContext ctx, list<Sobject> scope) {
        
        list<Task> tasks = new list<Task>();
        list<Event> events = new list<Event>();
        
        set<Id> oppIdSet = new set<Id>();
        
        for (SObject o : scope) {
            oppIdSet.add((string)o.get('WhatId'));
        }
        
        map<Id, Opportunity> oppMap = new map<Id, Opportunity>([SELECT Id, Initial_Visit_Date__c 
                                                                FROM Opportunity WHERE ID IN :OppIdSet]);
        
        // depending on the type of object, put the records in a list
        if (isEvent) {
            events = (list<Event>)scope;
            
            for (Event e : events) {
                
                //Commented by - Ajit Surana - 02/25/2015 - CR-20140605-5714
                //e.Activity_Date_Copy__c = e.StartDateTime.date();
                
                Opportunity relatedOpp = oppMap.get(e.WhatId);
                
                if (relatedOpp != null && relatedOpp.Initial_Visit_Date__c != null) {
                    
                    e.Opp_Initial_Visit_Date__c = relatedOpp.Initial_Visit_Date__c;
                }
            }
            
        }
        else if (!isEvent) {
            tasks = (list<Task>)scope;
            
            for (Task t : tasks) {
                
                //Commented by - Ajit Surana - 02/25/2015 - CR-20140605-5714
                //t.Activity_Date_Copy__c = t.ActivityDate;
                
                // try to get the opp associated with this
                Opportunity relatedOpp = oppMap.get(t.WhatId);
                if (relatedOpp != null && relatedOpp.Initial_Visit_Date__c != null) {
                    
                    t.Opp_Initial_Visit_Date__c = relatedOpp.Initial_Visit_Date__c;
                }
            }
            
        }
        
        // bypass all triggers
        Util.BypassAllTriggers = true;
        
        // update events
        if (events.size() > 0) {
            
            try {
                
                Database.UpsertResult[] srList = Database.upsert(events, false);
                
                // check each save result for errors and add any errors to the errors string which is sent in the results email
                processSaveResults(srList);
            }
            catch(Exception exceptionObj) {
                
               errors += 'Caught Exception:' + exceptionObj.getMessage() + '<br/>';
           }  
        }
    
        // update tasks
        if (tasks.size() > 0) {
            
            try {
                
                Database.UpsertResult[] srList = Database.upsert(tasks, false);
                
                // check each save result for errors and add any errors to the errors string which is sent in the results email
                processSaveResults(srList);
            }
            catch(Exception exceptionObj) {
                
               errors += 'Caught Exception:' + exceptionObj.getMessage() + '<br/>';
           }
        }
            
        Util.BypassAllTriggers = false;
    }
    
     // Override Finish method
    global void finish(Database.BatchableContext ctx) {
        
        Util.sendBatchStatus(ctx.getJobId(), 'Batch_Populate_OppInitVisit', errors);
    }
    
    public void processSaveResults(list<Database.UpsertResult> srList)  {
        
        // Iterate through each returned result
        for (Database.UpsertResult sr : srList) {
            if (!sr.isSuccess()) {
                // Operation failed, so get all errors                
                for(Database.Error err : sr.getErrors()) {
                    
                    String errString = 'The following error has occurred: ' + err.getStatusCode() + ': ' +
                                    err.getMessage() + 'fields that affected this error: ' + err.getFields();
                    errors += errString + '<br/>\r\n';
                    System.debug('@@' + errString);                    
                }
            }
        }
    }
    
    
}