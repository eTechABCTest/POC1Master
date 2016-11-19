/**
  *  Purpose	 :    Populate the Program Abbreviation on existing events
  *                  
  *  Create By   :   Victor Hanson
  *  
  *  Created Date:   11/27/2013
  *  
  *  Revision Log:	v1.0 - Created
  *  				
 **/
global class Batch_Event_UpdateProgramAbbreviation implements Database.Batchable<SObject> {
	
	public String queryStr = null;
	public boolean isEvent = false;
	public String errors = '';
	public boolean allPrograms = false;
	
	//Override Start method
	global Database.queryLocator start(Database.BatchableContext ctx) {
		
		if (queryStr == null) {
			
			if (isEvent) {
				
				queryStr = 'SELECT Id, ActivityDate, Program__c, Program_Abbreviation__c, WhatId ' +
							'FROM Event WHERE IsRecurrence = false AND What.Type = \'Opportunity\' ORDER BY WhatId ASC ALL ROWS';
			}
			else {
				
				queryStr = 'SELECT Id, ActivityDate, Program__c, Program_Abbreviation__c, WhatId ' +
							'FROM Task WHERE IsRecurrence = false AND What.Type = \'Opportunity\' ORDER BY WhatId ASC ALL ROWS';
			}
		}
		
		// Query all Memberships with Future status
        return Database.getQueryLocator(queryStr);	
	}
	
	//Override execute method
	global void execute(Database.BatchableContext ctx, list<Sobject> scope) {
		
		list<Task> tasksToUpdate = new list<Task>();
		list<Event> eventsToUpdate = new list<Event>();
		
		set<Id> oppIdSet = new set<Id>();
		
		for (SObject o : scope) {
			oppIdSet.add((string)o.get('WhatId'));
		}
		
		map<Id, Opportunity> oppMap = new map<Id, Opportunity>([SELECT Id, Program__c, Program__r.Program_Acronym__c, Program__r.Program_Abbreviation__c
																FROM Opportunity WHERE ID IN :OppIdSet]);
		
		// depending on the type of object, put the records in a list
		if (isEvent) {
			list<Event> events = (list<Event>)scope;
			
			for (Event e : events) {
				
				// get the opportunity
				Opportunity opp = oppMap.get(e.WhatId);
				
				if (recentlyModifiedProgramMap.containsKey(opp.Program__c)) {
					
					Program__c updatedProgram = recentlyModifiedProgramMap.get(opp.Program__c);
					
					if (e.Program__c != updatedProgram.Program_Acronym__c || e.Program_Abbreviation__c != updatedProgram.Program_Abbreviation__c) {
						
						// update those 2 fields on the event and add to our update list
						e.Program__c = updatedProgram.Program_Acronym__c;
						e.Program_Abbreviation__c = updatedProgram.Program_Abbreviation__c;
						
						// add to our list to update
						eventsToUpdate.add(e);
					}
				}
			}
			
		}
		else if (!isEvent) {
			list<Task> tasks = (list<Task>)scope;
			
			for (Task t : tasks) {
				
				// get the opportunity
				Opportunity opp = oppMap.get(t.WhatId);
				
				if (recentlyModifiedProgramMap.containsKey(opp.Program__c)) {
					
					Program__c updatedProgram = recentlyModifiedProgramMap.get(opp.Program__c);
					if (t.Program__c != updatedProgram.Program_Acronym__c || t.Program_Abbreviation__c != updatedProgram.Program_Abbreviation__c) {
						
						// update those 2 fields on the event and add to our update list
						t.Program__c = updatedProgram.Program_Acronym__c;
						t.Program_Abbreviation__c = updatedProgram.Program_Abbreviation__c;
						
						// add to our list to update
						tasksToUpdate.add(t);
					}
				}
			}
		
		}
		
		// bypass all triggers
		Util.BypassAllTriggers = true;
		
		// update events
		if (eventsToUpdate.size() > 0) {
			
			try {
				
				Database.UpsertResult[] srList = Database.upsert(eventsToUpdate, false);
				
				// check each save result for errors and add any errors to the errors string which is sent in the results email
				processSaveResults(srList);
			}
			catch(Exception exceptionObj) {
				
	           errors += 'Caught Exception:' + exceptionObj.getMessage() + '<br/>';
	       } 
		}
	
		// update tasks
		if (tasksToUpdate.size() > 0) {
			
			try {
				
				Database.UpsertResult[] srList = Database.upsert(tasksToUpdate, false);
				
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
    	
    	Util.sendBatchStatus(ctx.getJobId(), 'Batch_Event_UpdateProgramAbbreviation', errors);
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
    
    public map<Id, Program__c> recentlyModifiedProgramMap {
    	
    	get {
    		
    		if (recentlyModifiedProgramMap == null) {
    			
    			recentlyModifiedProgramMap = new map<Id, Program__c>();
    			// get all programs modified in the 2 days
    			if (!allPrograms) {
	    			recentlyModifiedProgramMap = new map<Id, Program__c>([SELECT Id, Program_Acronym__c, Program_Abbreviation__c
							    										  FROM Program__c
							    										  WHERE LastModifiedDate >= :system.now().addDays(-2)]);
    			}
    			else {
    				recentlyModifiedProgramMap = new map<Id, Program__c>([SELECT Id, Program_Acronym__c, Program_Abbreviation__c
							    										  FROM Program__c]);
    			}
    		}
    		
    		return recentlyModifiedProgramMap;
    	}
    	set;
    }
    
}