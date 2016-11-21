@isTest
class Test_Event_UpdatePrewireField
{
    /*
        Purpose:    Test Trigger Event_UpdatePrewireField
        
        Create By:  Angela Williams (SAP Contractor)            
        
        Last Modified By:   Jeremy Nottingham (SAP) 2/15/2011
        
        Current Version:    v1.3
        
        Revision Log:       v1.0 - (AW) Created code
                            v1.1 - (NB-2011-01-20) Added header, code comments, and reviewed code coverage
                            v1.2 - (NB-2011-01-26) Updated code coverage results based on changes to remove Status filter
                            v1.3 - (JN 2/15/2011) Added StartDateTime to sample Events in testmethods
                            
        Code Coverage as of 1/26/2011: 97%
    */
    
    static testMethod void testCase1()
    {
        Util.IsTesting = true;
    
        // Retrive an Opportunity for Testing
        //Removed 4/22/11 JN
        //Opportunity opp = [select Id from Opportunity where StageName = 'Pending' limit 1];
        Account acc = new Account(Name = 'acc', Account_Formal_Name__c = 'acc');
        insert acc;
        
        Opportunity opp = new Opportunity(
            Name = 'testopp',
            AccountId = acc.id,
            StageName = 'Pending',
            CloseDate = Date.parse('10/14/2011')
            );
        insert opp;
        
        // Create Test Events
        List<Event> evntList = new List<Event>();
    
        Event tsk = new Event(WhatId = opp.Id, 
            Event_Type__c = 'Phone Appointment', 
            Event_Purpose__c = 'Prewire', 
            DurationInMinutes = 60, 
            StartDateTime = DateTime.parse('10/14/2011 11:46 AM').addDays(-5));
        
        evntList.add(tsk);
            
        Event tsk1 = new Event(WhatId = opp.Id, 
            Event_Type__c = 'Phone Appointment', 
            Event_Purpose__c = 'Prewire', 
            DurationInMinutes = 60, 
            StartDateTime = DateTime.parse('10/14/2011 11:46 AM').addDays(-5));
        evntList.add(tsk1);
        
        Event tsk2 = new Event(WhatId = opp.Id, 
            Event_Type__c = 'Phone Appointment', 
            Event_Purpose__c = 'Prewire', 
            DurationInMinutes = 60, 
            StartDateTime = system.now().addDays(7));
        
        evntList.add(tsk2);
        
        Test.startTest();
        
        //Test insert
        insert evntList;
        
        Test.stopTest();
        
        // Requery Opportunity
        opp = [select id, Prewire_Completed__c, How_many_prewires_were_completed__c from Opportunity where Id = :opp.Id];
    
        // Print the Opportunity Prewire Completed and How Many Prewires were Completed fields to the debug log
        system.debug('### Prewire Completed: ' + opp.Prewire_Completed__c);
        system.debug('### # Prewires Completed: ' + opp.How_many_prewires_were_completed__c);
    
        // Assert that the Opportunity Prewire Completed field value equals True
        system.assertEquals(True, opp.Prewire_Completed__c);
        
        // Assert that the Opportunity How Many Prewires Completed (or scheduled) field value equals 3
        system.assertEquals(3, opp.How_many_prewires_were_completed__c);
    
        //Test delete  
        system.debug('\n\n35delete');
        delete evntList[0];
        
        // Requery Opportunity
        opp = [select id, Prewire_Completed__c, How_many_prewires_were_completed__c, 
            (select id from Events where Event_Purpose__c = 'Prewire' and StartDateTime < :Date.parse('10/14/2011')
            ) from Opportunity where Id = :opp.Id];
        
        // Assert that the Opportunity Event Size eqauls 1
        system.assertEquals(1, opp.Events.size());
        
        // Assert that the Opportunity Prewire Completed field value equals True
        system.assertEquals(True, opp.Prewire_Completed__c);
        
        // Assert that the Opportunity How Many Prewires were Completed field value equals 1
        system.assertEquals(2, opp.How_many_prewires_were_completed__c);
    }
    
    // prewire complete should only be true if a prewire activity has a startdatetime < today
    static testMethod void testPrewireComplete()
    {
        Util.IsTesting = true;
    
        // Retrive an Opportunity for Testing
        //Removed 4/22/11 JN
        //Opportunity opp = [select Id from Opportunity where StageName = 'Pending' limit 1];
        Account acc = new Account(Name = 'acc', Account_Formal_Name__c = 'acc');
        insert acc;
        
        Opportunity opp = new Opportunity(
            Name = 'testopp',
            AccountId = acc.id,
            StageName = 'Pending',
            CloseDate = Date.parse('10/14/2011')
            );
        insert opp;
        
        // Create Test Events
        List<Event> evntList = new List<Event>();
    
        Event tsk = new Event(WhatId = opp.Id, 
            Event_Type__c = 'Phone Appointment', 
            Event_Purpose__c = 'Prewire', 
            DurationInMinutes = 60, 
            StartDateTime = system.today().addDays(5));
        
        evntList.add(tsk);
        
        Test.startTest();
        
        //Test insert
        insert evntList;
        
        Test.stopTest();
        
        // Requery Opportunity
        opp = [select id, Prewire_Completed__c, How_many_prewires_were_completed__c from Opportunity where Id = :opp.Id];
    
        // Print the Opportunity Prewire Completed and How Many Prewires were Completed fields to the debug log
        system.debug('### Prewire Completed: ' + opp.Prewire_Completed__c);
        system.debug('### # Prewires Completed: ' + opp.How_many_prewires_were_completed__c);
    
        // Assert that the Opportunity Prewire Completed field value equals False becasue the prewire is in the future!
        system.assertEquals(False, opp.Prewire_Completed__c);
        
        // Assert that the Opportunity How Many Prewires Completed (or scheduled) field value equals 1
        system.assertEquals(1, opp.How_many_prewires_were_completed__c);
    }
    
    // prewire complete should only be true if a prewire activity has a startdatetime < today
    static testMethod void testPrewireCanceled()
    {
        Util.IsTesting = true;
    
        // Retrive an Opportunity for Testing
        //Removed 4/22/11 JN
        //Opportunity opp = [select Id from Opportunity where StageName = 'Pending' limit 1];
        Account acc = new Account(Name = 'acc', Account_Formal_Name__c = 'acc');
        insert acc;
        
        Opportunity opp = new Opportunity(
            Name = 'testopp',
            AccountId = acc.id,
            StageName = 'Pending',
            CloseDate = Date.parse('10/14/2011')
            );
        insert opp;
        
        // Create Test Events
        List<Event> evntList = new List<Event>();
    
        Event tsk = new Event(WhatId = opp.Id, 
            Event_Type__c = 'Phone Appointment', 
            Event_Purpose__c = 'Prewire', 
            DurationInMinutes = 60, 
            Cancelled_Did_Not_Occur__c = true,
            StartDateTime = system.today().addDays(5));
        
        evntList.add(tsk);
        
        Test.startTest();
        
        //Test insert
        insert evntList;
        
        Test.stopTest();
        
        // Requery Opportunity
        opp = [select id, Prewire_Completed__c, How_many_prewires_were_completed__c from Opportunity where Id = :opp.Id];
    
        // Print the Opportunity Prewire Completed and How Many Prewires were Completed fields to the debug log
        system.debug('### Prewire Completed: ' + opp.Prewire_Completed__c);
        system.debug('### # Prewires Completed: ' + opp.How_many_prewires_were_completed__c);
    
        // Assert that the Opportunity Prewire Completed field value equals False becasue the prewire is in the future!
        system.assertEquals(False, opp.Prewire_Completed__c);
        
        // Assert that the Opportunity How Many Prewires Completed (or scheduled) field value equals 1
        system.assertEquals(0, opp.How_many_prewires_were_completed__c);
    }

    static testMethod void testMostRecentNBBVisit()
    {
        Util.IsTrigger_EventPrewire = true;
        Util.IsTesting = true;
        Datetime testdt = DateTime.parse('10/14/2011 11:46 AM');
        // ensure that the record type custom setting has been updated with the correct values
        Util.resetRecordtypeSettings();
        ID rtid = Util.recordtypemap('Opportunity').get('RI Marketing');
        Id evrtid = Util.recordtypemap('Event').get('RI Marketing');
        system.debug('\n\n43 evrtid ' + evrtid);
        
        Account a = new Account(Account_Formal_Name__c = 'testacct', Name = 'testacct');
        insert a;
        
        Program__c prog = new Program__c(Name = 'tempname', Program_Acronym__c = 'TEST');
        insert prog;
        
        Membership__c m = new Membership__c(
            name = 'tempname',
            Program__c = prog.id,
            Account_Name__c = a.id);
        insert m;
        
        m = [select Most_Recent_NBB_Visit__c, Program__r.Program_Acronym__c from Membership__c where id = :m.id];
        system.assertEquals(null, m.Most_Recent_NBB_Visit__c);
        system.assertEquals('TEST', m.Program__r.Program_Acronym__c);
        
        //connected membership
        Opportunity o = new Opportunity(
            Name = 'testname', 
            AccountID = a.id, 
            CloseDate = Date.parse('10/14/2011'), 
            StageName = 'Closed Won', 
            RecordtypeID = rtid,
            Membership__c = m.id,
            Program__c = prog.id);
        //no prog, no membership
        Opportunity o1 = new Opportunity(
            Name = 'testname', 
            AccountID = a.id, 
            CloseDate = Date.parse('10/14/2011'), 
            StageName = 'Closed Won', 
            RecordtypeID = rtid);
        //connected membership1
        Opportunity o2 = new Opportunity(
            Name = 'testname', 
            AccountID = a.id, 
            CloseDate = Date.parse('10/14/2011'), 
            StageName = 'Closed Won', 
            RecordtypeID = rtid,
            Membership__c = m.id,
            Program__c = prog.id);
            
        insert o;
        
        insert o1;
        
        insert o2;
        o2 = [select Membership__c from Opportunity where id = :o2.id];
        system.assertEquals(m.id, o2.Membership__c);
        
        system.debug('\n\n78 opp o ' + o.id);  
        
        list<Event> testeventlist = new list<Event>();
        
        //connected opp (counts) - should be most recent first after insert
        testeventlist.add(new Event(
            WhatID = o.id,
            EndDateTime = testdt.addDays(-5),
            StartDateTime = testdt.addDays(-5),
            ActivityDate = testdt.date().addDays(-5),
            Event_Type__c = 'In Person Visit',
            //Old_Product_Field__c = null, Removed by CM 12/20/2013 CR-1991
            IsAllDayEvent = true,
            RecordtypeID = evrtid   
            ));
            
        //connected opp (counts) - should be most recent first after update
        testeventlist.add(new Event(
            WhatID = o2.id,
            EndDateTime = testdt.addDays(-6),
            StartDateTime = testdt.addDays(-6),
            ActivityDate = testdt.date().addDays(-6),
            Event_Type__c = 'In Person Visit',
            //Old_Product_Field__c = prog.Program_Acronym__c, Removed by CM 12/20/2013 CR-1991
            IsAllDayEvent = true,
            RecordtypeID = evrtid   
            ));
            
        //unconnected opp (shouldn't count)
        testeventlist.add(new Event(
            WhatID = o1.id,
            EndDateTime = testdt.addDays(-1),
            StartDateTime = testdt.addDays(-1),
            ActivityDate = testdt.date().addDays(-1),
            Event_Type__c = 'Opportunity Visit - For Opportunity Goal',
            //Old_Product_Field__c = null, Removed by CM 12/20/2013 CR-1991
            IsAllDayEvent = true,
            RecordtypeID = evrtid       
            ));
            
        //Account, same Program Acronym (counts) - should be most recent after update
        testeventlist.add(new Event(
            WhatID = a.id,
            EndDateTime = testdt.addDays(-10),
            StartDateTime = testdt.addDays(-10),
            ActivityDate = testdt.date().addDays(-10),
            Event_Type__c = 'Opportunity Visit - For Opportunity Goal',
            //Old_Product_Field__c = 'TEST', Removed by CM 12/20/2013 CR-1991
            IsAllDayEvent = true,
            RecordtypeID = evrtid       
            ));
            
        //Account, diff Program Acronym (shouldn't count)
        testeventlist.add(new Event(
            WhatID = a.id,
            EndDateTime = testdt.addDays(-2),
            StartDateTime = testdt.addDays(-2),
            ActivityDate = testdt.date().addDays(-2),
            Event_Type__c = 'In Person Visit',
            //Old_Product_Field__c = 'BADTEST', Removed by CM 12/20/2013 CR-1991
            IsAllDayEvent = true,
            RecordtypeID = evrtid       
            ));
            
        //No WhatID (shouldn't count)
        testeventlist.add(new Event(
            EndDateTime = testdt.addDays(-2),
            StartDateTime = testdt.addDays(-2),
            ActivityDate = testdt.date().addDays(-2),
            Event_Type__c = 'In Person Visit',
            //Old_Product_Field__c = 'BADTEST',
            IsAllDayEvent = true,
            RecordtypeID = evrtid       
            ));
    
		Test.startTest();
        insert testeventlist;
        
        m = [select Most_Recent_NBB_Visit__c from Membership__c where id = :m.id];
        
        system.assertEquals(Date.parse('10/14/2011').addDays(-5), m.Most_Recent_NBB_Visit__c);
        
        //change which one is most recent
        map<id, Event> id2evtmap = new map<id, Event>(testeventlist);
        testeventlist = [select EndDateTime, ActivityDate from Event where id in :id2evtmap.keyset()];
        system.debug('\n\n133all events ' + testeventlist);    
        for (Event e : testeventlist)
        {
            //Find the one that was 5 days ago, change it to 15 days ago. That will promote the 10 days ago one.
            if (e.ActivityDate == testdt.date().addDays(-5))
            {
                e.EndDateTime = testdt.addDays(-15);
                e.ActivityDate = Date.parse('10/14/2011').addDays(-15);
                
                system.debug('\n\n137test e ' + e);
                            
                //update e;
                break;
            }
        }
        
        Test.stopTest();
        
        update testeventlist;
        m = [select Most_Recent_NBB_Visit__c from Membership__c where id = :m.id];
        testeventlist = [select EndDateTime, ActivityDate from Event where id in :id2evtmap.keyset()];
        for (Event e : testeventlist)
        {
            system.debug('\n\n148 date ' + e.ActivityDate);
        }
        
        system.assertEquals(testdt.dateGMT().addDays(-6), m.Most_Recent_NBB_Visit__c);
    }
    
}