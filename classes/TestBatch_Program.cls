@isTest
private class TestBatch_Program {

	static testMethod void testBatch_Program() {

		Util.IsTest(true);
        Util.IsTesting = true;
        Util.IsBatch = true;
        Util.byPassAllTriggers = true;

	    Program__c p = TestUtilities.CreateNewProgram('RI Marketer', 'TYGH', 'Yes', 'PT', true);
		Program__c q = TestUtilities.CreateNewProgram('RI Marketer 2', 'TYGH', 'Yes', 'PT', false);
		q.Program_Formal_Name__c = 'Test';
		insert q;

	    String query = 'select id, Program_Acronym__c, Program_Formal_Name__c ' + 
	    		'from Program__c where id=\'' + p.Id + '\' or id=\'' + q.id + '\'';

	    Program__c p0 = [select Name from Program__c where id= :p.id];
	    Program__c q0 = [select Name from Program__c where id= :q.id];
        
Test.startTest();	
	
		Batch_Program batch = new Batch_Program();
		batch.Query = query;
	    Database.executeBatch(batch);
        
Test.stopTest();
        
        Program__c p1 = [select Name from Program__c where id= :p.id];
        Program__c q1 = [select Name from Program__c where id= :q.id];

        System.assertNotEquals(p0.Name, p1.Name);
        System.assertNotEquals(q0.Name, q1.Name);
	}
}