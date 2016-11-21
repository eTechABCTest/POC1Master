@isTest
private class TestBatch_Account {
	static testMethod void testBatch_Account() {
        Util.IsTest(true);
        Util.IsTesting = true;
        Util.IsBatch = true;
        Util.byPassAllTriggers = true;

	    Account a = TestUtilities.CreateNewAccount('Vendor', true);
	    a.Account_Formal_Name__c = 'Account Formal Name';
	    update a;
	    Program__c p = TestUtilities.CreateNewProgram('RI Marketer', 'TYGH', 'Yes', 'PT', false);
	    p.Renewal_Unit_Count__c = 2;
	    insert p;
	    Membership__c mem = TestUtilities.CreateNewMembership(a.Id, p.Id, false);
	    mem.Membership_Status_Text__c = 'Member';
	    insert mem;

		string query = 'select id, Name, EA_AE__c, Account_Formal_Name__c, Primary_State_Province__c, Primary_City__c,' 
			+ ' Account_Restriction_Status__c, BI_Memberships__c, Academies_Memberships__c, Hworks_Memberships__c,'
			+ ' (select id, userid from AccountTeamMembers where TeamMemberRole = \'AE or EA\'),'
			+ ' (select id, Restriction__r.Category__c from Restrictions_MtM__r '
			+ ' where Restriction__c != null and Restriction__r.Category__c != null and Restriction__r.Status__c != \'Retired\'),'
			+ ' (select id, Program__r.Business_Line__c, Renewal_Unit_Count__c from Memberships__r '
			+ ' where Membership_Status__c like \'Member%\' and  Program__r.Business_Line__c in (\'CM\', \'TD\', \'RI\', \'PT\') )'
			+ ' from Account WHERE Id = \'' + a.Id + '\''; 
		
		System.debug('### Test Batch Query String: ' + query);

	    Account a0 = [select id, Name, EA_AE__c, Account_Formal_Name__c, Primary_State_Province__c, Primary_City__c,
	    	Account_Restriction_Status__c, BI_Memberships__c, Academies_Memberships__c, Hworks_Memberships__c
	    	from Account WHERE Id = :a.Id];

test.StartTest(); 
		Batch_Account batch = new Batch_Account();
		batch.Query = query;
	    Database.executeBatch(batch);
test.StopTest();

	    Account a1 = [select id, Name, EA_AE__c, Account_Formal_Name__c, Primary_State_Province__c, Primary_City__c,
	    	Account_Restriction_Status__c, BI_Memberships__c, Academies_Memberships__c, Hworks_Memberships__c
	    	from Account WHERE Id = :a.Id];
	    System.assertNotEquals(a0.Name, a1.Name);
	    System.assertNotEquals(a0.BI_Memberships__c, a1.BI_Memberships__c);
	}
}