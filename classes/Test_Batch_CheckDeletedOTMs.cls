@istest
class Test_Batch_CheckDeletedOTMs 
{
    /*
    Purpose:   Test class for Batch_CheckDeletedOTMs 
    
    Create By:          Jeremy Nottingham 8/31/11
    
    Last Modified By:   Jeremy Nottingham 9/2/11
    
    Current Version:    v1.1
    
    Revision Log:       v1.0 - (JN 8/31/11( Created code
                        v1.1 - (JN 9/2/11) finished test code
                        v1.3 - (SUNJ 12/19/13) Update Proposal_Value__c with Amount
    */
    
    static testmethod void test()
    { 
        //Bypass Dupeblocker
        Util.IsTest(true);
        Util.IsTesting = true;
        
        Profile prof = [select id from Profile limit 1];
        
        list<User> users = new list<User>();
        for (Integer i = 0; i < 4; i++) {
            String digit = String.valueOf(i);
            users.add(new User(
                alias = 'user' + digit, 
                email='standarduser@advisory.com', 
                emailencodingkey='UTF-8', 
                lastname='Testing ' + digit, 
                languagelocalekey='en_US', 
                localesidkey='en_US', 
                profileid = prof.id, 
                timezonesidkey='America/Los_Angeles', 
                username='testuser1971' + digit + '@advisory.com'
                ));
             
        }
        
        insert users;
        
        list<Account> accs = new list<Account>();
        Account a = new Account(Name = 'TestAccount', Account_Formal_Name__c = 'formaltest');
        accs.add(a);
        insert accs;       
        
        List<Opportunity> opps = new List<Opportunity>();
        
        Opportunity o1 = new Opportunity(
            AccountId = a.Id, 
            StageName = 'Prospect', 
            Start__c = system.today().addDays(-1), 
            CloseDate = system.today().addDays(1), 
            Name = 'TestOpp1', 
            Amount = 1,
            Chairman_s_Team_Rep__c = users[0].Id);
        opps.add(o1);
        Opportunity o2 = new Opportunity(
            AccountId = a.Id, 
            StageName = 'Prospect', 
            Start__c = system.today().addDays(-1), 
            CloseDate = system.today().addDays(1), 
            Name = 'TestOpp2', 
            Amount = 1,
            Chairman_s_Team_Rep__c = users[2].Id);
        opps.add(o2);
        insert opps;
        
        List<OpportunityTeamMember> OTMs = new List<OpportunityTeamMember>();
        OpportunityTeamMember otm1 = new OpportunityTeamMember(
            TeamMemberRole = 'RI - Chairman\'s Team',
            OpportunityId = o1.Id,
            UserId = users[0].Id
        );
        OTMs.add(otm1);
        OpportunityTeamMember otm2 = new OpportunityTeamMember(
            TeamMemberRole = 'RI - Chairman\'s Team',
            OpportunityId = o2.Id,
            UserId = users[2].Id
        );
        OTMs.add(otm2);
        
        insert OTMs;
        o1.Chairman_s_Team_Rep__c = otm1.UserId;
        o2.Chairman_s_Team_Rep__c = otm2.UserId;
        update o1;
        update o2;
        
        o1 = [select Chairman_s_Team_Rep__c from Opportunity where id = :o1.Id];
        system.assertEquals(otm1.UserId, o1.Chairman_s_Team_Rep__c);
        o2 = [select Chairman_s_Team_Rep__c from Opportunity where id = :o2.Id];
        system.assertEquals(otm2.UserId, o2.Chairman_s_Team_Rep__c);
        
        delete OTMs;
        
        OpportunityTeamMember otm4 = new OpportunityTeamMember(
            TeamMemberRole = 'RI - Chairman\'s Team',
            OpportunityId = o2.Id,
            UserId = users[1].Id
        );
        insert otm4;
        
Test.StartTest();
        String  BIChairman = 'PT - Chairman\\\'s Team';
        String  CoreChairman = 'RI - Chairman\\\'s Team';
        
        Batch_CheckDeletedOTMs sObjBatch_CheckDeletedOTMs = new Batch_CheckDeletedOTMs();
        sObjBatch_CheckDeletedOTMs.Query = 'Select Id, Chairman_s_Team_Rep__c,'
                + ' (Select TeamMemberRole, UserId from OpportunityTeamMembers where TeamMemberRole like \'%Chairman\\\'s Team%\''
                + ' limit 1)'
                + ' from Opportunity where Chairman_s_Team_Rep__c != null'
                + ' and (Id = \'' + o1.Id + '\' or Id = \'' + o2.Id + '\')';
        
        ID batchprocessid = Database.executeBatch(sObjBatch_CheckDeletedOTMs);
        
Test.StopTest();  
       
        o1 = [select Chairman_s_Team_Rep__c from Opportunity where id = :o1.Id];
        system.assertEquals(null, o1.Chairman_s_Team_Rep__c);
        o2 = [select Chairman_s_Team_Rep__c from Opportunity where id = :o2.Id];
        system.assertEquals(otm4.UserId, o2.Chairman_s_Team_Rep__c);
        
    }
    
         
}