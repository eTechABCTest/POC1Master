@isTest
private class Test_RestrictionClearanceRequest_Owner
{
    /*
    Purpose:    Test Trigger RestrictionClearanceRequest_Owner
    
    Create By:  Mike Lofquist (SAP)         
    
    Last Modified By:   Nathan Banas (SAP) - 1/24/2011
    
    Current Version:    v1.1
    
    Revision Log:       v1.0 - (AW) Created code
                        v1.1 - (NB-2011-01-24) Added header, code comments, and reviewed code coverage
                        
    Code Coverage as of 1/24/2011: 100%
    */
     
    static testmethod void myUnitTest()
    { 
        //Bypass Dupeblocker
        Util.IsTest(true);
        // Select any Restriction within the system
        // Removed 4/21/11 for new data 
        //List<Restrictions__c> rests = [select id, ownerid from Restrictions__c limit 2];
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
                username='testuser1971' + digit + '@advisory.com'
                ));
        }
        insert users;
        
        list<Restrictions__c> rests = new list<Restrictions__c>();
        Date nextWeek = system.today().addDays(7);
        for (Integer i = 0; i < 4; i++) {
            rests.add(new Restrictions__c(
                Name = 'testrestriction',
                Expiration_Date__c = nextWeek,
                OwnerId = users[0].id));
        }
        insert rests;
        List<Restrictions__c> restrictions = [SELECT Id, Expiration_Date__c, Status__c FROM Restrictions__c WHERE Id IN :rests];
        system.assertEquals(nextWeek, restrictions[0].Expiration_Date__c);
        system.assertEquals('Active', restrictions[0].Status__c);
        
        /*****************************************/
        //Flag for testing mode on triggers
        Util.IsTest(true);
        
        Account a = new Account(Name='Temp Name', Account_Formal_Name__c = '1', Primary_City__c = 'city', Primary_State_Province__c  = 'VA');
        insert a;
        
        Program__c prog = new Program__c(Name = 'progname', Program_Acronym__c = 'TEST');
        insert prog;
        
        Warm_Lead__c testwl = new Warm_Lead__c(Name = 'tempname', Lead_Date__c = system.today(), Account__c = a.id,  Primary_Program__c = prog.id,
                                                Grade__c = '1');
        insert testwl;

        // Create a test RCR
        List<Restriction_Clearance_Request__c> RCRs = new List<Restriction_Clearance_Request__c>();
        
        Restriction_Clearance_Request__c rcr1 = new Restriction_Clearance_Request__c(Restriction__c = rests[0].id, Warm_Lead__c = testwl.Id,
                                                                                     DateLastMarketingOutreachtoContact__c = Date.Today(), Marketer__c = UserInfo.getUserId());
        RCRs.add(rcr1);
        Restriction_Clearance_Request__c rcr2 = new Restriction_Clearance_Request__c(Restriction__c = rests[3].id,
                                                                                     DateLastMarketingOutreachtoContact__c = Date.Today(), Marketer__c = UserInfo.getUserId());
        RCRs.add(rcr2);
        Restriction_Clearance_Request__c rcr3 = new Restriction_Clearance_Request__c(Restriction__c = rests[0].id,
                                                                                     DateLastMarketingOutreachtoContact__c = Date.Today(), Marketer__c = UserInfo.getUserId());
        RCRs.add(rcr3);
        
        test.startTest();
        
        // Insert test RCR
        insert(RCRs);
        
        //Assert for the result
        testwl = [Select Status__c from Warm_Lead__c where Id =: testwl.Id];
        System.assertEquals(Constants.STATUS_WARM_LEAD_PENDING_RESTRICTION_CLEARANCE, testwl.Status__c);
        
        rcr3.Restriction__c = rests[1].Id;
        
        update rcr3;
        
        test.stopTest();
        
        // Requery the RCR
        rcr1 = [select Restriction_Owner_2__c from Restriction_Clearance_Request__c where id = :rcr1.id ];
        rcr2 = [select Restriction_Owner_2__c from Restriction_Clearance_Request__c where id = :rcr2.id ];
        rcr3 = [select Restriction_Owner_2__c from Restriction_Clearance_Request__c where id = :rcr3.id ];
        
        // Assert RCR Owner pulled over Owner from Restriction on Inserts & Updates
        System.assertEquals(rests[0].ownerid, rcr1.Restriction_Owner_2__c);
        //System.assertNotEquals(rests[0].ownerid, rcr2.Restriction_Owner_2__c);
        //System.assertNotEquals(rests[1].ownerid, rcr2.Restriction_Owner_2__c);
        System.assertEquals(rests[1].ownerid, rcr3.Restriction_Owner_2__c);
    }
}