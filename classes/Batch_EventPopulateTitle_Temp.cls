global class Batch_EventPopulateTitle_Temp implements Database.Batchable<SObject>, Database.Stateful {
	global final String Query;
	global Batch_EventPopulateTitle_Temp(String q){
		Date dt = Date.today();
		String datetoday = String.valueof(dt);
		Query = q;
		if (Query == null) {
			Query='SELECT Id, WhatId, WhoId, Title__c FROM Event WHERE WhoId != null';
		}
	} 
	global Database.QueryLocator start(Database.BatchableContext BC)
	{
		return Database.getQueryLocator(Query);
	}
	global void execute(Database.BatchableContext BC,List<sObject> scope)
	{
		List<Event> Events = (List<Event>)scope;
		Util.BypassAllTriggers = true;
		ContactTriggerUtilities.PopulateContactTitleFromEvent(Events);
		update Events;
		Util.BypassAllTriggers = false;
	}
	
	
	global void finish(Database.BatchableContext BC)
	{
		
	}
}