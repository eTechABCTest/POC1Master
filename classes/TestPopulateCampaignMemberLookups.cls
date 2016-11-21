/*  
    Revision Logs : V1.1 :  Simplyforce-Bhavi[12/13/2011] - Added method to test the CR-20111012-161
*/

@isTest
private class TestPopulateCampaignMemberLookups {

    static testmethod void PopulateCampaignMemberLookupsTest() { 
    
        //Bypass Dupeblocker
        Util.IsTest(true);
        Util.IsTesting = true;
        
        //Bypassing triggers
        Util.byPassAllTriggers = true;
        
        Profile prof = [select Id from Profile where Name = 'System Administrator'];
        list<User> users = new list<User>();
        try {
            for (Integer i = 0; i <= 1; i++) {
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
                    username='testuserxyz' + digit + '@advisory.com'));
            } 
            insert users; 
        } catch (Exception e) { // in case no more users can be added
            users = [select Id, Username from User where isActive = true limit 2]; 
        }

        Program__c prog = new Program__c(
            Name = 'testprog', 
            Program_Acronym__c = 'TEST', 
            Status__c = 'Active', 
            Create_Memberships__c = 'Yes',
            OwnerId = users[0].id);
        insert prog;
        
        Account a = new Account(Name = 'testacc');
        insert a;

        RecordType rtc = [select Id from RecordType where Name = 'External' and SobjectType = 'Contact' and IsActive = true];

        Contact con = new Contact(Firstname = 'Test', Lastname = 'Person', RecordTypeId = rtc.Id, AccountId = a.Id);
        insert con;
        
        //Start Test from here
        Test.startTest();
        
        //Enabling triggers again
        Util.byPassAllTriggers = false;

        Campaign c = new Campaign(Name = 'Test Campaign');
        insert c;

        CampaignMember cm = new CampaignMember(CampaignId = c.Id, ContactId = con.Id, 
            Marketer_Username__c = users[0].Username,  
            MA_Username__c = users[1].Username,  
            Program_Acronym__c = 'TEST');
        insert cm;

        CampaignMember cmret = [select Marketer_Assignment__c, MA_Assignment__c, Primary_Program__c from CampaignMember where Id = :cm.Id];
        system.assertEquals(users[0].Id, cmret.Marketer_Assignment__c);
        system.assertEquals(users[1].Id, cmret.MA_Assignment__c);
        system.assertEquals(prog.Id, cmret.Primary_Program__c);
        
        //Stop Test here
        Test.stopTest();
    }

    static testmethod void PopulateInsensitiveCampaignMemberLookupsTest() { 
        
        //Bypass Dupeblocker
        Util.IsTest(true);
        Util.IsTesting = true;
        
        //Bypassing triggers
        Util.byPassAllTriggers = true;
        
        Profile prof = [select Id from Profile where Name = 'System Administrator'];
        list<User> users = new list<User>();
        try {
            for (Integer i = 0; i <= 1; i++) {
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
                    username='testuserxyz' + digit + '@advisory.com'));
            } 
            insert users; 
        } catch (Exception e) { // in case no more users can be added
            users = [select Id, Username from User where isActive = true limit 2]; 
        }

        Program__c prog = new Program__c(
            Name = 'testprog', 
            Program_Acronym__c = 'TEST', 
            Status__c = 'Active', 
            Create_Memberships__c = 'Yes',
            OwnerId = users[0].id);
        insert prog;
        
        Account a = new Account(Name = 'testacc');
        insert a;

        RecordType rtc = [select Id from RecordType where Name = 'External' and SobjectType = 'Contact' and IsActive = true];

        Contact con = new Contact(Firstname = 'Test', Lastname = 'Person', RecordTypeId = rtc.Id, AccountId = a.Id);
        insert con;

        //Test will start from here
        Test.startTest();
        
        //Enabling triggers
        Util.byPassAllTriggers = false;
        
        Campaign c = new Campaign(Name = 'Test Campaign');
        insert c;

        CampaignMember cm = new CampaignMember(CampaignId = c.Id, ContactId = con.Id, 
            Marketer_Username__c = users[0].Username.toUpperCase(),  
            MA_Username__c = users[1].Username.toUpperCase(),  
            Program_Acronym__c = 'TEST');
        insert cm;

        CampaignMember cmret = [select Marketer_Assignment__c, MA_Assignment__c, Primary_Program__c from CampaignMember where Id = :cm.Id];
        system.assertEquals(users[0].Id, cmret.Marketer_Assignment__c);
        system.assertEquals(users[1].Id, cmret.MA_Assignment__c);
        system.assertEquals(prog.Id, cmret.Primary_Program__c);
        
        //Test will stop here
        Test.stopTest();
    }
}