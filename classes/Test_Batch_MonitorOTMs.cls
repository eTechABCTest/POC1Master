/*
    Purpose:   Test class for Batch_MonitorOTMs 
    
    Create By:          Pratik
    
    Last Modified By:   Pratik 8/05/11
    
    Current Version:    v1.0
    
    Revision Log:       v1.0 -  Created code
                        v1.1 - (SUNJ 12/19/13) - CR-20130118-2218
    */
@istest
class Test_Batch_MonitorOTMs 
{
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
        
        Opportunity o2 = new Opportunity(
            AccountId = a.Id, 
            StageName = 'Prospect', 
            Start__c = system.today().addDays(-1), 
            CloseDate = system.today().addDays(1), 
            Name = 'TestOpp1', 
            Amount = 1);
        opps.add(o2);
        insert opps;
        
        List<OpportunityTeamMember> OTMs = new List<OpportunityTeamMember>();
        OpportunityTeamMember otm4 = new OpportunityTeamMember(
            TeamMemberRole = 'RI - Chairman\'s Team',
            OpportunityId = o2.Id,
            UserId = users[1].Id
        );
        OTMs.add(otm4);
        
        insert OTMs;
        
        o2 = [select Chairman_s_Team_Rep__c from Opportunity where Id = :o2.id];
        system.assertEquals(null, o2.Chairman_s_Team_Rep__c);
        
Test.StartTest();
        String  PTChairman = 'PT - Chairman\\\'s Team';
        String  RIChairman = 'RI - Chairman\\\'s Team';
        
        Batch_MonitorOTMs sObjBatch_MonitorOTMs = new Batch_MonitorOTMs();
        sObjBatch_MonitorOTMs.Query = 'Select a.Opportunity.Name,a.isDeleted,a.UserId,a.User.Name,a.TeamMemberRole,'
            + ' a.Id,a.OpportunityId From OpportunityTeamMember a where (a.OpportunityId = \'' + o2.Id + '\')'
                + ' and (a.lastModifiedDate = LAST_N_DAYS:3)'
                + ' and (a.TeamMemberRole=\'' + PTChairman + '\' or a.TeamMemberRole=\'' + RIChairman +'\')'
            + ' and a.OpportunityId = \'' + o2.Id + '\' limit 200 all rows';
        
        ID batchprocessid = Database.executeBatch(sObjBatch_MonitorOTMs);
        
Test.StopTest();  
       
        o2 = [select Chairman_s_Team_Rep__c from Opportunity where id = : o2.id];
        system.assertEquals(otm4.UserId, o2.Chairman_s_Team_Rep__c);
        
    }
    
         
}