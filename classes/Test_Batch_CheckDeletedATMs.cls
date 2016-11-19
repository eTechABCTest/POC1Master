@istest
private class Test_Batch_CheckDeletedATMs 
{
/*
    Purpose:   Test class for Batch_CheckDeletedATMs 
    
    Create By:          Jeremy Nottingham (Synaptic) 8/30/11
    
    Last Modified By:   Jeremy Nottingham (Synaptic) 8/30/11
    
    Current Version:    v1.0
    
    Revision Log:       v1.0 -  (JN 8/30/11) Created code
    
    */  
    static testmethod void test()
    { 
        //Bypass Dupeblocker
        Util.IsTest(true);
        Util.IsTesting = true;
        
        Profile prof = [select id from Profile limit 1];
        list<User> users = new list<User>();
        for (Integer i = 0; i < 8; i++) 
        {
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
        
        list<Account> Accounts = new list<Account>();
        
        Account acc1 = new Account(
            Name = 'TestAccount', 
            Account_Formal_Name__c = 'formaltest',
            EA_AE__c = users[1].id);
       Accounts.add(acc1);
        Account acc2 = new Account(
            Name = 'TestAccount', 
            Account_Formal_Name__c = 'formaltest',
            EA_AE__c = users[0].id);
        Accounts.add(acc2);
        
        insert Accounts;       
        
        list<Contact> cons = new list<Contact>();
        
        //This is going to be the EA Contact
        Contact con4 = new Contact(AccountId = acc1.id,
                                LastName = 'testlast4', 
                                Employee_User_Record__c = users[2].Id
                                );
        cons.add(con4);
        
        insert cons;
        
        
        AccountTeamMember atm1 = new AccountTeamMember(
                                        AccountId = acc1.Id,
                                        UserId = users[2].Id,
                                        TeamMemberRole = 'AE or EA'
                                        );
                                        
        
        Database.SaveResult[]  lsr = Database.Insert(new list<AccountTeamMember>{atm1});

        //Test code for Batch_MonitorATMs
Test.StartTest();
        
        Batch_CheckDeletedATMs Batch_CheckDeletedATMsObj = new Batch_CheckDeletedATMs();
        Batch_CheckDeletedATMsObj.Query = 'Select Id, EA_AE__c, EA_Contact__c,'
                + ' (Select TeamMemberRole, UserId from AccountTeamMembers where TeamMemberRole like \'%Executive Advisor&\''
                + ' or TeamMemberRole like \'%Account Exec%\' or TeamMemberRole = \'AE or EA\' limit 1)'
                + ' from Account where (EA_AE__c != null or EA_Contact__c != null)'
                + ' and (Id = \'' + acc1.Id + '\' or Id = \'' + acc2.Id + '\')';
        ID batchprocessid1 = Database.executeBatch(Batch_CheckDeletedATMsObj);
        
Test.StopTest(); 
       
        // Check if account's EA_AE equals ATM's user Id
        acc1 = [select EA_AE__c, EA_Contact__c from Account where Id = :acc1.Id];
        acc2 = [select EA_AE__c, EA_Contact__c from Account where Id = :acc2.Id];
        system.assertEquals(atm1.UserId, acc1.EA_AE__c);
        system.assertEquals(con4.Id, acc1.EA_Contact__c);
        system.assertEquals(null, acc2.EA_AE__c);
        system.assertEquals(null, acc2.EA_Contact__c);
        
         
    }
    
}