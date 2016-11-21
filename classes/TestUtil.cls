@istest
private class TestUtil
{
    /*
    Purpose:    Test Class Util
    
    Create By:          Jeremy Nottingham (SAP)
    
    Last Modified By:   Jeremy Nottingham (SAP) 5/19/11
    
    Current Version:    v1.2
    
    Revision Log:       v1.0 - (NB) Created code
                        v1.1 - (NB-2011-01-26 thru 2011-01-27) Added header, code comments, and reviewed code coverage
                        v1.2 - (JN 5/19/11) changed testmakememberships to not include deleting active Program records
                             - And added separate support to test resetRecordtypesettings
                        v1.3 - (CR-20130531-3103 - Bhavi Sharma - 07/12/2013) - Test method modified (testmakememberships_v2)
                        v1.4 - (SUNJ 12/19/13) - CR-20130118-2218
                    v1.5 - Modified By - Mahendra Swarnkar - 12/07/2015 - CR-20151109-9376 - Added a new test method to check functionality of "formatToAlphabatical" method in Util class.
                    v1.6 - Modified By - Mahendra Swarnkar - 08/27/2016 - CR-20160114-9520 - Added a new test method to check functionality of "businessHoursForStartAndEndDate" method in Util class.            
    Code Coverage as of 1/27/2011: 95%
    */
    
    static testmethod void testutil()
    { 
        //Bypass Dupeblocker
        Util.IsTest(true);
        Util.IsTesting = true;
        system.assertEquals(true, Util.IsTesting); 
    }
    
    static testmethod void testrtmap()
    { 
        //Bypass Dupeblocker
        Util.IsTest(true);
        //test recordtypemap() and also resetRecordtypeSettings()
        RecordType testrt = [select Id, Name, SObjectType from Recordtype limit 1];
        map<String, Id> rtmap = Util.recordtypemap(testrt.SObjectType);
        system.assertEquals(null, rtmap.get(testrt.Name));
        
        test.startTest();
        rtmap = Util.recordtypemap(testrt.SObjectType);
        system.assertEquals(null, rtmap.get(testrt.Name));
        
        test.stopTest();
    }
    
    static testmethod void testresetRecordtypesettings()
    { 
        //Bypass Dupeblocker
        Util.IsTest(true);
        //test resetRecordtypeSettings()
        list<Recordtype_Setting__c> rts = Recordtype_Setting__c.getall().values();
        delete rts;
        
        rts = Recordtype_Setting__c.getall().values();
        system.assertEquals(0, rts.size());
        
test.startTest();
        Util.resetRecordtypeSettings();
test.stopTest();
        
        rts = Recordtype_Setting__c.getall().values();
        system.assertNotEquals(0, rts.size());
        
    }
    
static testmethod void membershipOwnerCheckfromMemberships()
    { 
        //Bypass Dupeblocker
        Util.IsTest(true);
        Util.IsTesting = true;
        
        Id prfid = [select id from Profile where Name = 'Marketers' limit 1].id;
        system.assertnotEquals(null, prfid);
        
        list<User> users = new list<User>();
        for (Integer i = 0; i < 3; i++) {
            String digit = String.valueOf(i);
            users.add(new User(
                alias = 'user' + digit, 
                email='standarduser@advisory.com', 
                emailencodingkey='UTF-8', 
                lastname='Testing ' + digit, 
                languagelocalekey='en_US', 
                localesidkey='en_US', 
                profileid = prfid, 
                timezonesidkey='America/Los_Angeles', 
                username='testuser' + digit + '@advisory.com'
                ));
        }
        insert users;
        User u1 = users[0];
        
        //Contact con1 = [select Id, Name from Contact where Counter_ID__c = :u1.Employee_Contact_RecordID__c limit 1];
        Contact con1 = new Contact(
            LastName = 'testcontact');
        insert con1;
        
        Account a = new Account(Name = 'TestAccount', EA_AE__c = u1.Id, EA_Contact__c = con1.Id);
        insert a;
        
        Program__c p = new Program__c(Name='TestProg', Program_Acronym__c = 'ZTP');
        insert p;
        
        List<Opportunity> opps = new List<Opportunity>();
        Opportunity o1 = new Opportunity(AccountId = a.Id, StageName = 'Prospect', Chairman_s_Team_Rep__c = u1.Id, 
                                         Main_Contact__c = con1.Id, Start__c = system.today().addDays(-1), 
                                         CloseDate = system.today().addDays(1), Name = 'TestOpp', Amount = 1);
        opps.add(o1);
        
        List<Contract__c> contracts = new List<Contract__c>();
        
        Contract__c c = new Contract__c(Name = 'TestContract', Payer_Account__c = a.Id, Start__c = system.today().addDays(1), End__c = system.today().addDays(3));
        contracts.add(c);
        Contract__c c1 = new Contract__c(Name = 'TestContract', Status__c = 'Honorary', Payer_Account__c = a.Id,
            Start__c = system.today().addDays(-1), End__c = system.today().addDays(5),
            Negotiated_Amount__c = 1, Type__c = 'Renewal', Year__c = '2011', Program__c = p.Id, Join_Date__c = System.today(),
            Main_Contact__c = con1.Id, Invoice_Contact__c = con1.Id, Contract_Renewal_Opportunity__c = o1.Id);
        contracts.add(c1);
        
        insert contracts;
        
        List<Membership__c> membs = new List<Membership__c>();
        Membership__c m1 = new Membership__c(Account_Name__c = a.Id, Name = 'TestMemb1', Assigned_Marketer__c = u1.id, Earliest_Contract__c = c.Id);
        membs.add(m1);
        
        Membership__c m2 = new Membership__c(Account_Name__c = a.Id, Name = 'TestMemb1', Assigned_Marketer__c = u1.id, Active_Contract_Idenfied__c = c.Id);
        membs.add(m2);
        
        Membership__c m3 = new Membership__c(Account_Name__c = a.Id, Name = 'TestMemb1', Assigned_Marketer__c = u1.id, Earliest_Contract__c = c1.Id, Active_Contract_Idenfied__c = c1.Id);
        membs.add(m3);
        
        insert membs;
        
        set<id> memids = new set<Id>();
        memIds.add(m1.Id);
        memIds.add(m2.Id);
        
        insert opps;

test.startTest();
        
        Util.membershipOwnerCheckfromMemberships(memids);
             
test.stopTest();
        
        m1 = [select id, Assigned_Marketer__c, OwnerId from Membership__c where id = :m1.Id];
        system.assertEquals(m1.Assigned_Marketer__c, m1.OwnerId);
    }
    
    static testmethod void membershipOwnerCheckfromOpps()
    { 
        //Bypass Dupeblocker
        Util.IsTest(true);
        Util.IsTesting = true;
        Profile prof = [select id from Profile limit 1];
        list<User> users = new list<User>();
        for (Integer i = 0; i < 3; i++) {
            String digit = String.valueOf(i);
            users.add(new User(
                alias = 'user' + digit, 
                email='standarduser@advisory.com', 
                emailencodingkey='UTF-8', 
                lastname='Testing ' + digit, 
                languagelocalekey='en_US', 
                localesidkey='en_US', 
                timezonesidkey='America/Los_Angeles',
                ProfileId = prof.id, 
                username='testuser' + digit + '@advisory.com'
                ));
        }
        insert users; 
        User u1 = users[0];
        
        //Contact con1 = [select Id, Name from Contact where Counter_ID__c = :u1.Employee_Contact_RecordID__c limit 1];
        Contact con1 = new Contact(
            LastName = 'testcontact');
        insert con1;
        
        Account a = new Account(Name = 'TestAccount', EA_AE__c = u1.Id, EA_Contact__c = con1.Id);
        insert a;
        
        Program__c p = new Program__c(Name='TestProg', Program_Acronym__c = 'ZTP');
        insert p;
        
        List<Opportunity> opps = new List<Opportunity>();
        Opportunity o1 = new Opportunity(AccountId = a.Id, StageName = 'Prospect', Chairman_s_Team_Rep__c = u1.Id, 
                                         Main_Contact__c = con1.Id, Start__c = system.today().addDays(-1), 
                                         CloseDate = system.today().addDays(1), Name = 'TestOpp', Amount = 1);
        opps.add(o1);
        
        insert opps;
        
        List<Contract__c> contracts = new List<Contract__c>();
        
        Contract__c c = new Contract__c(Name = 'TestContract', Payer_Account__c = a.Id, Start__c = system.today().addDays(1), 
                                        End__c = system.today().addDays(3));
        contracts.add(c);
        Contract__c c1 = new Contract__c(Name = 'TestContract', Status__c = 'Honorary', Payer_Account__c = a.Id,
            Start__c = system.today().addDays(-1), End__c = system.today().addDays(5),
            Negotiated_Amount__c = 1, Type__c = 'Renewal', Year__c = '2011', Program__c = p.Id, Join_Date__c = System.today(),
            Main_Contact__c = con1.Id, Invoice_Contact__c = con1.Id, Contract_Renewal_Opportunity__c = o1.Id);
        contracts.add(c1);
        
        insert contracts;
        
        List<Membership__c> membs = new List<Membership__c>();
        Membership__c m1 = new Membership__c(Account_Name__c = a.Id, Name = 'TestMemb1', Assigned_Marketer__c = u1.id, 
                                             Active_Contract_Idenfied__c = c1.Id, Earliest_Contract__c = c1.Id);
        membs.add(m1);
        
        Membership__c m2 = new Membership__c(Account_Name__c = a.Id, Name = 'TestMemb1', Assigned_Marketer__c = u1.id, 
                                             Active_Contract_Idenfied__c = c.Id);
        membs.add(m2);
        insert membs;
        
        o1.Membership__c = m2.Id;
        
        //Start testing from here
        Test.startTest();
        
        //Update opportunity
        update o1;
        
        set<Id> selectoppids = new set<Id>();
        selectoppids.add(o1.Id);
        
        Util.membershipOwnerCheckfromOpps(selectoppids);
             
        Test.stopTest();
        
        //m1 = [select id, Assigned_Marketer__c, OwnerId from Membership__c where id = :m1.Id];
        //system.assertEquals(m1.Assigned_Marketer__c, m1.OwnerId);
    }
    
    static testmethod void testdeletememberships()
    { 
        //Bypass Dupeblocker
        Util.IsTest(true);
        Util.IsTesting = true;
        
        Account a = new Account(Name = 'testaccount');
        insert a;
        
        a = [select id, (select id from Memberships__r) from Account where id = :a.id];
        system.assertEquals(0, a.Memberships__r.size());
        
        
        List<Program__c> allprograms = new List<Program__c> (
            [select id From Program__c where Create_Memberships__c = 'Yes' limit 100]);
        
        List<Membership__c> newMsps = new List<Membership__c> ();
        for (Program__c prog: allprograms)
        {
            newMsps.add(new Membership__c (
                Program__c = prog.id, 
                Account_Name__c = a.id 
                ));
        }
        insert newMsps;     
        
        set<id> memids = new set<id>();
        for (Membership__c m : newMsps) memids.add(m.id);
        
        a = [select id, (select id from Memberships__r) from Account where id = :a.id];
        system.assertEquals(allprograms.size(), a.Memberships__r.size());
        
        test.startTest();
        Util.deleteMemberships(memids);
        test.stopTest();
        
        a = [select id, (select id from Memberships__r) from Account where id = :a.id];
        system.assertEquals(0, a.Memberships__r.size());
    }
    
    //Test method modified as according CR-20130531-3103 By Bhavi Sharma
    static testmethod void testmakememberships_v2()
    { 
        //Bypass Dupeblocker
        Util.IsTest(true);
        Util.IsTesting = true;
        
        list<Program__c> progs = [select Id, Applicable_Segments__c from Program__c 
            where Create_Memberships__c = 'Yes' and Applicable_Segments__c includes ('US Hospital')];
        //if (progs.size() > 0) delete progs;
        Integer progcount = progs.size();
    
        progs = new list<Program__c>();
        for (Integer i = 1; i <= 2; i++) {
            progs.add(new Program__c(
                Name = 'prog ' + i,
                Program_Acronym__c = 'TEST' + i,
                Create_Memberships__c = 'Yes',
                Applicable_Segments__c = 'US Hospital'
                ));
        }
        Util.BypassAllTriggers = true;
        insert progs;
        Util.BypassAllTriggers = false;
        progCount += progs.size();
        
        //List to hold insert accounts records
        List<Account> accounts = new List<Account>();
        accounts.add(TestUtilities.CreateNewAccount('US Provider - Hospital', false));
        accounts.add(TestUtilities.CreateNewAccount('US Provider - System', false));
        accounts.add(TestUtilities.CreateNewAccount('US Provider Strategic', false));
        
        // bypass Triggers so we don't auto generate memberships initially
        Util.BypassAllTriggers = true;
        //insert list of accounts
        insert accounts;
        Util.BypassAllTriggers = false;
        
        //query result of Accounts records
        accounts = [select id, Name, (select id from Memberships__r) from Account where Id IN :accounts];
        
        //assert Statement
        System.assertEquals(3, accounts.size());
        
        //Test starts here
        test.startTest();
        
        //Call Util class method
        Util.makeMembershipsforAccounts(new set<id>{ accounts[0].id, accounts[1].Id, accounts[2].Id });   
        
        //Test stops here
        test.stopTest();
                
        //query result of Accounts records
        accounts = [select id, Name, (select id, Name, Program__r.Program_Acronym__c from Memberships__r) 
                    from Account 
                    where Id IN: accounts ORDER BY Name];
        
        //List to hold Membership data associated with account
        List<Membership__c> memberships = new List<Membership__c>();
        
        //Loop through accounts list 
        for(Account acc : accounts){
            
            //Loop through Account's membership list
            for (Membership__c mem : acc.Memberships__r) {
                
                //Check for Program's Program Acronym field value
                if (mem.Program__r.Program_Acronym__c == 'TEST1') {
                    
                    //assert statement
                    system.assertEquals(acc.Name + ' - ' + 'TEST1',mem.Name.substring(0,mem.Name.length()));
                }
                
                //Check for Program's Program Acronym field value
                if (mem.Program__r.Program_Acronym__c == 'TEST2') {
                    
                    //assert statement
                    system.assertEquals(acc.Name + ' - ' + 'TEST2',mem.Name.substring(0,mem.Name.length()));
                }
                
                //add membership into List
                memberships.add(mem);
            }
            
            system.assertEquals(progCount, acc.Memberships__r.size());
        }
        
    }
    
    static testmethod void testIsValidEmailAddress()
    {
        System.assertEquals(true,Util.isValidEmailAddress('bob.frost@advisory.com'));
        System.assertEquals(true,Util.isValidEmailAddress('BOB.FROST@ADVISORY.COM'));
        System.assertEquals(true,Util.isValidEmailAddress('bobfrost@advisory.com'));
        System.assertEquals(true,Util.isValidEmailAddress('BOBFROST@ADVISORY.COM'));
        System.assertEquals(false,Util.isValidEmailAddress('BOB.FROSTADVISORY.COM'));
        System.assertEquals(false,Util.isValidEmailAddress('BOB.FROST@ADVISORYCOM'));
        System.assertEquals(false,Util.isValidEmailAddress('BOB.FROST@ADVISORY.COMMM'));
        System.assertEquals(false,Util.isValidEmailAddress('BOB.FROST@ADVISORY.C'));        
    }
    
    static testmethod void testCreateSingleEmailInvalidRecipient()
    {
        Messaging.SingleEmailMessage email;
        List<String> recipientEmails = new List<String>{'johnsmith@advisory.com', 'bo@.com'};
        String replyTo = 'replyTo@advisory.com';
        String senderName = 'TestDisplayName';
        String subject = 'Test Subject';
        String emailMessage = 'This is a test!';
        email = Util.createSingleEmail(recipientEmails, replyTo, senderName, subject, emailMessage);
        System.assertEquals(null,email);
    }
    
    static testmethod void testCreateSingleEmailInvalidReplyTo()
    {
        Messaging.SingleEmailMessage email;
        List<String> recipientEmails = new List<String>{'johnsmith@advisory.com', 'test@advisory.com'};
        String replyTo = 'replyToadvisory.com';
        String senderName = 'TestDisplayName';
        String subject = 'Test Subject';
        String emailMessage = 'This is a test!';
        email = Util.createSingleEmail(recipientEmails, replyTo, senderName, subject, emailMessage);
        System.assertEquals(null,email);
    }
    
    static testmethod void testCreateSingleEmailHappyPath()
    {
        Messaging.SingleEmailMessage email;
        List<String> recipientEmails = new List<String>{'johnsmith@advisory.com', 'test@advisory.com'};
        String replyTo = 'replyTo@advisory.com';
        String senderName = 'TestDisplayName';
        String subject = 'Test Subject';
        String emailMessage = 'This is a test!';
        email = Util.createSingleEmail(recipientEmails, replyTo, senderName, subject, emailMessage);
        System.assertEquals(recipientEmails,email.getToAddresses());
        System.assertEquals(replyTo,email.getReplyTo());
        System.assertEquals(senderName,email.getSenderDisplayName());
        System.assertEquals(subject,email.getSubject());
        System.assertEquals(emailMessage,email.getHtmlBody());
        System.assertEquals(emailMessage,email.getPlainTextBody());
    }
    
    static testmethod void testSendEmailHappyPath()
    {
        Messaging.SingleEmailMessage email;
        List<String> recipientEmails = new List<String>{'johnsmith@advisory.com', 'test@advisory.com'};
        String replyTo = 'replyTo@advisory.com';
        String senderName = 'TestDisplayName';
        String subject = 'Test Subject';
        String emailMessage = 'This is a test!';
        email = Util.createSingleEmail(recipientEmails, replyTo, senderName, subject, emailMessage);
        boolean result = Util.sendSingleEmail(email);
        System.assertEquals(true,result);
    }
    
    static testmethod void testSendEmailInvalidEmail()
    {
        Messaging.SingleEmailMessage email;
        List<String> recipientEmails = new List<String>{'johnsmith@advisory.com', 'test@advisory.com'};
        String replyTo = 'replyTo@advisory.com';
        String senderName = 'TestDisplayName';
        String subject = 'Test Subject';
        String emailMessage = 'This is a test!';
        email = Util.createSingleEmail(recipientEmails, replyTo, senderName, subject, emailMessage);
        email.setReplyTo('');
        boolean result = Util.sendSingleEmail(email);
        System.assertEquals(false,result);
    }
    
    //Added By - Mahendra Swarnkar - 12/07/2015 - CR-20151109-9376
    static testmethod void testformatToAlphabatical(){
        
        //String variable
        String value = 'ABC @abc# a1$ Z&XA^';
        
        //Test Starts from here
        Test.startTest();
        
        //Method call
        String value1 = Util.formatToAlphabatical(value);
        
        //Assert on results
        system.assertEquals('ABC abc a ZXA', value1);
        
        //Test stop here
        Test.stopTest();
    }
    //v1.6 - Added By - Mahendra Swarnkar - 08/27/2016 - CR-20160114-9520 
    static testMethod void testBusinessHoursForStartAndEndDate(){
    
        //Bypass Dupeblocker
        Util.IsTest(true);
        Util.isTesting = true;
        
        //Bypassing Triggers so then test data can be created easily
        Util.byPassAllTriggers = true;
        
        //List to hold Case Blackout Date
        List<Case_Blackout_Days__c> holidays =  new List<Case_Blackout_Days__c>();
        
        //Create holiday records
        holidays.add(new Case_Blackout_Days__c(Name = 'Holiday' ,Blackout_Begin_Date__c = Date.parse('08/25/2016'), 
                                              Blackout_End_Date__c = Date.parse('08/30/2016'),  Type__c = 'US Company Holiday'));
        holidays.add(new Case_Blackout_Days__c(Name = 'Holiday' ,Blackout_Begin_Date__c = Date.parse('09/15/2016'), 
                                              Blackout_End_Date__c = Date.parse('09/30/2016'),  Type__c = 'US Company Holiday'));
        holidays.add(new Case_Blackout_Days__c(Name = 'Holiday' ,Blackout_Begin_Date__c = Date.parse('08/01/2016'), 
                                              Type__c = 'In-day'));
        
        insert holidays;
        
        //Start test from here
        Test.startTest();
        
        //Checking whether current is holiday or not
        Boolean isHoliday = Util.IsACompanyHoliday(Date.parse('08/25/2016'), holidays);
        System.assertEquals(true, isHoliday);
        isHoliday = Util.IsACompanyHoliday(Date.parse('08/24/2016'), holidays);
        System.assertEquals(false, isHoliday);
        isHoliday = Util.IsACompanyHoliday(Date.parse('09/20/2016'), holidays);
        System.assertEquals(true, isHoliday);
        isHoliday = Util.IsACompanyHoliday(Date.parse('09/25/2016'), holidays);
        System.assertEquals(true, isHoliday);
        isHoliday = Util.IsACompanyHoliday(Date.parse('08/01/2016'), holidays);
        System.assertEquals(true, isHoliday);
        
        //Checking for business time in total minutes
        Integer totalMinutes = Util.calculateBusinessHoursInMinute('08:30 AM');
        System.assert(totalMinutes != null);
        System.assertEquals(510, totalMinutes);
        totalMinutes = Util.calculateBusinessHoursInMinute('05:30 PM');
        System.assert(totalMinutes != null);
        System.assertEquals(1050, totalMinutes);
        
        //Checking for total business hour in minutes
        totalMinutes = Util.businessHoursForStartAndEndDate(DateTime.parse('08/25/2016 08:30 AM'), DateTime.parse('08/31/2016 05:30 PM'), holidays);
        System.assert(totalMinutes != null);
        System.assertEquals(540, totalMinutes);
        
        totalMinutes = Util.businessHoursForStartAndEndDate(DateTime.parse('08/30/2016 11:30 AM'), DateTime.parse('09/03/2016 09:30 PM'), holidays);
        System.assert(totalMinutes != null);
        System.assertEquals(1620, totalMinutes);
        
        totalMinutes = Util.businessHoursForStartAndEndDate(DateTime.parse('09/10/2016 05:30 PM'), DateTime.parse('09/30/2016 09:30 AM'), holidays);
        System.assert(totalMinutes != null);
        System.assertEquals(1620, totalMinutes);
        
        totalMinutes = Util.businessHoursForStartAndEndDate(DateTime.parse('10/10/2016 05:30 AM'), DateTime.parse('10/30/2016 09:30 AM'), holidays);
        System.assert(totalMinutes != null);
        System.assertEquals(8100, totalMinutes);
        
        totalMinutes = Util.businessHoursForStartAndEndDate(DateTime.parse('09/12/2016 10:30 AM'), DateTime.parse('09/13/2016 03:30 PM'), holidays);
        System.assert(totalMinutes != null);
        System.assertEquals(840, totalMinutes);
        
        totalMinutes = Util.businessHoursForStartAndEndDate(DateTime.parse('09/13/2016 10:30 AM'), DateTime.parse('09/13/2016 03:30 PM'), holidays);
        System.assert(totalMinutes != null);
        System.assertEquals(300, totalMinutes);
        
        totalMinutes = Util.businessHoursForStartAndEndDate(DateTime.parse('09/13/2016 08:30 AM'), DateTime.parse('09/13/2016 05:30 PM'), holidays);
        System.assert(totalMinutes != null);
        System.assertEquals(540, totalMinutes);
        
        totalMinutes = Util.businessHoursForStartAndEndDate(DateTime.parse('09/13/2016 08:30 AM'), DateTime.parse('09/13/2016 04:30 PM'), holidays);
        System.assert(totalMinutes != null);
        System.assertEquals(480, totalMinutes);
        
        totalMinutes = Util.businessHoursForStartAndEndDate(DateTime.parse('09/13/2016 10:30 AM'), DateTime.parse('09/13/2016 06:30 PM'), holidays);
        System.assert(totalMinutes != null);
        System.assertEquals(420, totalMinutes);
        
        Boolean isProduction = Util.IS_PRODUCTION_INSTANCE;
        Boolean isnotCompanyHoliday = Util.IsNotACompanyHoliday(System.today(), Util.LIST_OF_COMPANY_HOLIDAYS);
        String parseNull = Util.parseNull(null); 
        Integer bussinessDaysDiff = Util.bussinessDaysDifferenceInBetweenDates(System.today(), System.today().addDays(10));
        String daysString = Util.calculateDayOfDate(System.today());
        Date dt = Util.AddBusinessDays(System.today(), 3, null);
        
        //Stop test here
        Test.stopTest();
    }
}