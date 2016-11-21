@isTest
private class TestProgram_BatchFields
{
    /*
    Purpose:    Test Trigger Program_BatchFields
    
    Create By:          
    
    Last Modified By:   Nathan Banas (SAP) - 1/25/2011
    
    Current Version:    v1.1
    
    Revision Log:       v1.0 - () Created code
                        v1.1 - (NB-2011-01-25) - Added header, code comments, and reviewed code coverage
                        
    Code Coverage as of 1/25/2011: 88%
    */
    
    static testmethod void testBatchFields()
    { 
        //Bypass Dupeblocker
        Util.IsTest(true);
        //set testing flag for batches
        Util.IsTesting = true;
        
        //The marketer we will compare against
        Id ProperMarketerID;
        
        // Removed 4/21/11 JN to replace with new data
        // Account a = [select Id, (select Id, TeamMemberRole, UserID from AccountTeamMembers) from Account limit 1];
        Account a = new Account(Name = 'testacc', Account_Formal_Name__c = 'testacc');
        insert a;
        
        //Find Team Member with testing role: "RI Clinical Marketer" if they exist
        //Removed 4/21/11 JN
        /*
        for (AccountTeamMember atm : a.AccountTeamMembers)
        {
            if (atm.TeamMemberRole == 'RI Clinical Marketer')
                ProperMarketerId = atm.UserId;
        }
        */
        Profile prof = [select id from Profile limit 1];
        list<User> users = new list<User>();
        for (Integer i = 0; i < 2; i++) {
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
                username='testuser' + digit + '@advisory.com'
                ));
            
        }
        insert users;
        
        List<AccountTeamMember> testATMs = new List<AccountTeamMember>();
        AccountTeamMember newatm1 = new AccountTeamMember( 
            AccountID = a.id,
            TeamMemberRole = 'RI Clinical Marketer',
            UserId = users[0].id);
        
        testATMs.add(newatm1);
        
        AccountTeamMember newatm2 = new AccountTeamMember(
            AccountID = a.id,
            TeamMemberRole = 'TD Marketer',
            UserId = users[1].id);
        
        testATMs.add(newatm2);
            
        insert testATMs;
        ProperMarketerId = newatm1.UserId;
        
        list<Program__c> testprogs = new list<Program__c>();
        
        Program__c p1 = new Program__c(
            Program_Acronym__c = 'TEST',
            Program_Formal_Name__c = 'testprogram formal name',
            Create_Memberships__c = 'No',
            New_Business_Marketer__c = 'RI Clinical Marketer');
        
        testprogs.add(p1);
            
        Program__c p2 = new Program__c(
            Program_Acronym__c = 'TEST',
            Program_Formal_Name__c = 'testprogram formal name',
            Create_Memberships__c = 'Yes',
            New_Business_Marketer__c = 'RI Clinical Marketer');
        
        testprogs.add(p2);
            
        Program__c p3 = new Program__c(
            Program_Acronym__c = 'TEST',
            Program_Formal_Name__c = 'testprogram formal name',
            Create_Memberships__c = 'Yes',
            Applicable_Segments__c = 'US Corporate',
            New_Business_Marketer__c = 'RI Clinical Marketer');
        
        testprogs.add(p3);  
            
test.StartTest();
        insert testprogs;
        
        p1.New_Business_Marketer__c = 'TD Marketer';
        update p1;
        
        Program__c testprog = [select Name, (select id from Memberships__r) from Program__c where id = :p2.id];
        
        newatm1 = [select UserId from AccountTeamMember where AccountID = :a.id and TeamMemberRole = 'RI Clinical Marketer' limit 1];
        
        //Show Name populated properly
        system.assertEquals('TEST - testprogram formal name', testprog.Name);
        
        //show Assigned Marketer populated properly
        system.assertEquals(newatm1.UserId, ProperMarketerId);
        
        delete testprog;
test.StopTest();
    }
}