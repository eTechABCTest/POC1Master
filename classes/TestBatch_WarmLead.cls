@isTest
private class TestBatch_WarmLead {
	static testMethod void testBatch_WarmLead() {

		Util.IsTest(true);
        Util.IsTesting = true;
        Util.IsBatch = true;
        Util.byPassAllTriggers = true;

        User[] usrs = [select Id, Name from User where isActive = true and Profile.Name = 'System Administrator' limit 2];
        Program__c prog = new Program__c(
            Name = 'progname',
            Program_Acronym__c = 'TEST');
        insert prog;
        Warm_Lead__c testwl = new Warm_Lead__c(
            Name = 'tempname',
            Lead_Date__c = system.today(),
            Primary_Program__c = prog.id,
            Grade__c = '1',
            OwnerId = usrs[0].Id,
            Marketer_Assignment__c = usrs[1].Id
            );
        insert testwl;

        string query = 'select id, OwnerId, Marketer_Assignment__c from Warm_Lead__c '
        	+ 'WHERE id=\'' + testwl.id + '\'';

Test.startTest();
	
		Batch_WarmLead batch = new Batch_WarmLead();
		batch.Query = query;	
	    Id batchId = Database.executeBatch(batch);

Test.stopTest();
        
		Warm_Lead__c newwl = [select id, OwnerId, Marketer_Assignment__c from Warm_Lead__c
			WHERE id= :testwl.id];
	    System.assertEquals(newwl.Marketer_Assignment__c, newwl.OwnerId);
	    System.assertNotEquals(newwl.OwnerId, testwl.OwnerId);    
	}
}