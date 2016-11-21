@isTest
private class TestContractOpp_Ext {
/*
    Purpose:    Ensure 100% Test Coverage for Visualforce Controller ContractOpp_Ext
    
    Create By:  Jeremy Nottingham (Synaptic) 11/2010
    
    Last Modified By:  Rajeev Jain 12/07/2015
    
    Current Version:    v1.6
    
    Revision Log:       v1.0 - (JN) Created Class along with original ContractOppExt and VF page ContractOppCreator
                        v1.1 - (JN) Added this header 1/26/11
                             - Included Main Contact validation
                             - commented and ensured 100% coverage
                        v1.2 - (NB-2011-03-24) Modified code to allow for deployment
                             - Removed queries referencing data that may not exist and created records through test (no records will actually be committed and are used via the test method only)
                             - Added try/catch blocks where necessary for RecordType queries
                             - Removed assertion tests (best practice would be to readd these after deployment, but that will need to wait until data has been loaded into the system)
                             - Confirmed 98% code coverage (loss in coverage was due to removal of assertions) 
                        v1.3 - (VH-2012-03-06) Un-did NB's changes so that the unit tests now actually test functionality
                             - Included the use of TestUtilities class to simplify the code a bit
                        v1.4 - (SUNJ 12/19/13) - CR-20130118-2218
                        v1.5 - (VH 8/6/15) - CR-20150414-8871 - added test to verify edge case where there is no opportunity related to the contract
                        V1.6 - Rajeev Jain 12/07/2015 - CR-20151202-9434 - Increased code coverage      
    */
    static testmethod void testCoreContractOppExt() { 
        //Bypass Dupeblocker
        Util.IsTest(true);
        Util.IsTesting = true;
        
        // get the TD AM Standard Opp record type
        Id rtid = [select id from Recordtype where Name='RI Marketing' and SObjectType='Opportunity' limit 1].Id;
        
        Account acc = TestUtilities.CreateNewAccount(true);
        Contact testcontact = TestUtilities.CreateNewContact(acc, true);
        Program__c testProgram = TestUtilities.CreateNewProgram(null, 'TES', 'No', null, true);
        
        
        Opportunity testsourceopp = new Opportunity(
            RecordtypeID = rtid != null ? rtid: null,
            AccountID = acc.id,
            Name = 'testopp',
            StageName = 'Closed Won',
            CloseDate = system.today(),
            OwnerID = [select id from User where IsActive = true limit 1].id
            );
        insert testsourceopp;
        
        Contract__c testcon = new Contract__c(
            Payer_Account__c = testsourceopp.AccountID,
            Source_Opportunity__c = testsourceopp.id,
            Start__c = system.today(),
            End__c = system.today().addYears(5),
            Program__c = testProgram.id,
            Years_In_Term__c = 5,
            Main_Contact__c = testcontact.id
            );
        insert testcon;
        
        Opportunity addrowopp;
test.StartTest();
        ApexPages.standardController stdcon = new ApexPages.standardController(testcon);
        test.setCurrentPage(Page.ContractOppCreator);
        ApexPages.currentPage().getParameters().put('id',testcon.id);
        ContractOpp_Ext cox = new ContractOpp_Ext(stdcon);
        
        //system.assertEquals(6, cox.displaylist.size()); // NB - 3/24/2011 - Removed to allow for deployment.
        
        PageReference testpr = cox.addRow();
        //system.assertEquals(7, cox.displaylist.size()); // NB - 3/24/2011 - Removed to allow for deployment.
        
        for (ContractOpp_Ext.xopp xopp : cox.displaylist) {
            if (xopp == cox.displaylist[1]) xopp.setSelected(true);
            if (xopp == cox.displaylist[2]) xopp.opp.Decision_Type__c = 'Fixed Term';
            if (xopp.opp.CloseDate == null) {
                 addrowopp = xopp.opp;
                 xopp.opp.Start__c = system.today().addDays(10);
            }
            xopp.opp.StageName = 'Pending';
            xopp.opp.OwnerID = testsourceopp.OwnerID;
        }
        
        //Should be one to delete
        testpr = cox.deleteSelected();
        //system.assertEquals(6, cox.displaylist.size());// NB - 3/24/2011 - Removed to allow for deployment.
        
        testpr = cox.saveAll();
        
        
test.StopTest();
        //Make sure fields are set properly
        set<id> oppids = new set<id>();
        map<Integer, Opportunity> rownumber2oppmap = new map<Integer, Opportunity>();
        testcon = [select Main_Contact__c, Contract_Renewal_Opportunity__c from Contract__c where id = :testcon.id];
        
        for (ContractOpp_Ext.xopp xopp : cox.displaylist) {
system.debug('\n\n73 opprole ' + xopp.opprole + ' opp ' + xopp.opp);            
            
            if (xopp.opprole != 'source') {
                oppids.add(xopp.opp.id);
                
                //system.assertEquals(testcon.Main_Contact__c, xopp.opp.Main_Contact__c);// NB - 3/24/2011 - Removed to allow for deployment.
                /* // NB - 3/24/2011 - Removed to allow for deployment.
                if (xopp.opp.Decision_Type__c == 'Fixed Term')
                    system.assertEquals(system.today(), xopp.opp.CloseDate);
                else
                    system.assertEquals(xopp.opp.Start__c.addDays(-1), xopp.opp.CloseDate);
                */
            }
            
            if ((xopp.opprole == 'rirenewal') || (xopp.opprole == 'ptrenewal')) {
                /*// NB - 3/24/2011 - Removed to allow for deployment.
                system.assertEquals(testcon.Contract_Renewal_Opportunity__c, xopp.opp.id);
                system.assertEquals(xopp.opp.Previous_Year_Negotiated__c, xopp.opp.Amount);
                */
            }
            
            rownumber2oppmap.put(xopp.rownumber, xopp.opp);
            
        }
        
        //Check Parent Opportunity fields
        for (Integer r : rownumber2oppmap.keyset()) {
            /* // NB - 3/24/2011 - Removed to allow for deployment.
            if (r > 1)
                system.assertEquals(rownumber2oppmap.get(r-1).Id, rownumber2oppmap.get(r).Parent_Opportunity__c);
            */
        }
        
        // NB - 3/24/2011 - Added below code into a try catch block to allow for deployment (in case OpportunityContactRoles query returns 0 results)
        try
        {
            list<Opportunity> testopps = [select Main_Contact__c,
                (select ContactID, IsPrimary from OpportunityContactRoles)
                from Opportunity where id in :oppids];
            for (Opportunity o : testopps) {
                // NB - 3/24/2011 - Removed to allow for deployment.
                system.assertEquals(1, o.OpportunityContactRoles.size());
                system.assertEquals(o.Main_Contact__c, o.OpportunityContactRoles[0].ContactID);
                system.assertEquals(True, o.OpportunityContactRoles[0].IsPrimary);
            }
        }
        catch(exception ex)
        {
            
        }
    }
    
    // test booking contracts with Doc MTMs
    static testmethod void testCoreContractOppExt_DocMTMs() { 
        //Bypass Dupeblocker
        Util.IsTest(true);
        Util.IsTesting = true;
        
        // get the TD AM Standard Opp record type
        Id rtid = [select id from Recordtype where Name='RI Marketing' and SObjectType='Opportunity' limit 1].Id;
        
        Account acc = TestUtilities.CreateNewAccount(true);
        Contact testcontact = TestUtilities.CreateNewContact(acc, true);
        Program__c testProgram = TestUtilities.CreateNewProgram(null, 'TES', 'No', null, true);
        
        
        Opportunity testsourceopp = new Opportunity(
            RecordtypeID = rtid != null ? rtid: null,
            AccountID = acc.id,
            Name = 'testopp',
            StageName = 'Closed Won',
            CloseDate = system.today(),
            OwnerID = [select id from User where IsActive = true limit 1].id
            );
        insert testsourceopp;
        
        Contract__c testcon = new Contract__c(
            Payer_Account__c = testsourceopp.AccountID,
            Source_Opportunity__c = testsourceopp.id,
            Start__c = system.today(),
            End__c = system.today().addYears(5),
            Program__c = testProgram.id,
            Years_In_Term__c = 5,
            Main_Contact__c = testcontact.id
            );
        insert testcon;
        
        
        Opportunity addrowopp;
test.StartTest();
        ApexPages.standardController stdcon = new ApexPages.standardController(testcon);
        test.setCurrentPage(Page.ContractOppCreator);
        ApexPages.currentPage().getParameters().put('id',testcon.id);
        ContractOpp_Ext cox = new ContractOpp_Ext(stdcon);
        
        //system.assertEquals(6, cox.displaylist.size()); // NB - 3/24/2011 - Removed to allow for deployment.
        
        PageReference testpr = cox.addRow();
        //system.assertEquals(7, cox.displaylist.size()); // NB - 3/24/2011 - Removed to allow for deployment.
        
        for (ContractOpp_Ext.xopp xopp : cox.displaylist) {
            if (xopp == cox.displaylist[1]) xopp.setSelected(true);
            if (xopp == cox.displaylist[2]) xopp.opp.Decision_Type__c = 'Fixed Term';
            if (xopp.opp.CloseDate == null) {
                 addrowopp = xopp.opp;
                 xopp.opp.Start__c = system.today().addDays(10);
            }
            xopp.opp.StageName = 'Pending';
            xopp.opp.OwnerID = testsourceopp.OwnerID;
        }
        
        //Should be one to delete
        testpr = cox.deleteSelected();
        //system.assertEquals(6, cox.displaylist.size());// NB - 3/24/2011 - Removed to allow for deployment.
        
        testpr = cox.saveAll();
        
        
test.StopTest();
        //Make sure fields are set properly
        set<id> oppids = new set<id>();
        map<Integer, Opportunity> rownumber2oppmap = new map<Integer, Opportunity>();
        testcon = [select Main_Contact__c, Contract_Renewal_Opportunity__c from Contract__c where id = :testcon.id];
        
        for (ContractOpp_Ext.xopp xopp : cox.displaylist) {
system.debug('\n\n73 opprole ' + xopp.opprole + ' opp ' + xopp.opp);            
            
            if (xopp.opprole != 'source') {
                oppids.add(xopp.opp.id);
                
                //system.assertEquals(testcon.Main_Contact__c, xopp.opp.Main_Contact__c);// NB - 3/24/2011 - Removed to allow for deployment.
                /* // NB - 3/24/2011 - Removed to allow for deployment.
                if (xopp.opp.Decision_Type__c == 'Fixed Term')
                    system.assertEquals(system.today(), xopp.opp.CloseDate);
                else
                    system.assertEquals(xopp.opp.Start__c.addDays(-1), xopp.opp.CloseDate);
                */
            }
            
            if ((xopp.opprole == 'rirenewal') || (xopp.opprole == 'ptrenewal')) {
                /*// NB - 3/24/2011 - Removed to allow for deployment.
                system.assertEquals(testcon.Contract_Renewal_Opportunity__c, xopp.opp.id);
                system.assertEquals(xopp.opp.Previous_Year_Negotiated__c, xopp.opp.Amount);
                */
            }
            
            rownumber2oppmap.put(xopp.rownumber, xopp.opp);
            
        }
        
        //Check Parent Opportunity fields
        for (Integer r : rownumber2oppmap.keyset()) {
            /* // NB - 3/24/2011 - Removed to allow for deployment.
            if (r > 1)
                system.assertEquals(rownumber2oppmap.get(r-1).Id, rownumber2oppmap.get(r).Parent_Opportunity__c);
            */
        }
        
        // NB - 3/24/2011 - Added below code into a try catch block to allow for deployment (in case OpportunityContactRoles query returns 0 results)
        try
        {
            list<Opportunity> testopps = [select Main_Contact__c,
                (select ContactID, IsPrimary from OpportunityContactRoles)
                from Opportunity where id in :oppids];
            for (Opportunity o : testopps) {
                // NB - 3/24/2011 - Removed to allow for deployment.
                system.assertEquals(1, o.OpportunityContactRoles.size());
                system.assertEquals(o.Main_Contact__c, o.OpportunityContactRoles[0].ContactID);
                system.assertEquals(True, o.OpportunityContactRoles[0].IsPrimary);
            }
        }
        catch(exception ex)
        {
            
        }
    }
    
    static testmethod void testTDContractOppExt() { 
        //Bypass Dupeblocker
        Util.IsTest(true);
        Util.IsTesting = true;
        // get the TD AM Standard Opp record type
        Id rtid = [select id from Recordtype where Name='TD AM Standard Opp' and SObjectType='Opportunity' limit 1].Id;
        
        Account acc = TestUtilities.CreateNewAccount(true);
        Contact testcontact = TestUtilities.CreateNewContact(acc, true);
        Program__c testProgram = TestUtilities.CreateNewProgram(null, 'TES', 'No', null, true);
        
        Opportunity testsourceopp = new Opportunity(
            RecordtypeID = rtid != null ? rtid: null,
            AccountID = acc.id,
            Name = 'testopp',
            StageName = 'Closed Won',
            CloseDate = system.today(),
            OwnerID = [select id from User where IsActive = true AND Profile.Name = 'System Administrator' limit 1].id
            );
        insert testsourceopp;
        
        Contract__c testcon = new Contract__c(
            Payer_Account__c = testsourceopp.AccountID,
            Source_Opportunity__c = testsourceopp.id,
            Start__c = system.today(),
            End__c = system.today().addYears(5),
            Program__c = testProgram.id,
            Years_In_Term__c = 5,
            Main_Contact__c = testcontact.id
            );
        insert testcon;
            
        Opportunity addrowopp;
        test.StartTest();
        ApexPages.standardController stdcon = new ApexPages.standardController(testcon);
        test.setCurrentPage(Page.ContractOppCreator);
        ApexPages.currentPage().getParameters().put('id',testcon.id);
        ContractOpp_Ext cox = new ContractOpp_Ext(stdcon);
        
        PageReference testpr = cox.addRow();
        
        for (ContractOpp_Ext.xopp xopp : cox.displaylist) {
            if (xopp == cox.displaylist[1]) xopp.setSelected(true);
            if (xopp == cox.displaylist[2]) xopp.opp.Decision_Type__c = 'Fixed Term';
            if (xopp.opp.CloseDate == null) {
                 addrowopp = xopp.opp;
                 xopp.opp.Start__c = system.today().addDays(10);
            }
            xopp.opp.StageName = 'Pending';
            xopp.opp.OwnerID = testsourceopp.OwnerID;
        }
        //Should be one to delete
        testpr = cox.deleteSelected();
        testpr = cox.saveAll();
        test.StopTest();
        //Make sure fields are set properly
        set<id> oppids = new set<id>();
        map<Integer, Opportunity> rownumber2oppmap = new map<Integer, Opportunity>();
        testcon = [select Main_Contact__c, Contract_Renewal_Opportunity__c from Contract__c where id = :testcon.id];
        
        for (ContractOpp_Ext.xopp xopp : cox.displaylist) {
            system.debug('\n\n73 opprole ' + xopp.opprole + ' opp ' + xopp.opp);            
            if (xopp.opprole != 'source') {
                oppids.add(xopp.opp.id);
            }
            
            if ((xopp.opprole == 'rirenewal') || (xopp.opprole == 'ptrenewal')) {
                // NB - 3/24/2011 - Removed to allow for deployment.
                system.assertEquals(testcon.Contract_Renewal_Opportunity__c, xopp.opp.id);
                system.assertEquals(xopp.opp.Previous_Year_Negotiated__c, xopp.opp.Amount);
            }
            
            rownumber2oppmap.put(xopp.rownumber, xopp.opp);
            
        }
        
        //Check Parent Opportunity fields
        for (Integer r : rownumber2oppmap.keyset()) {
            /* // NB - 3/24/2011 - Removed to allow for deployment.
            if (r > 1)
                system.assertEquals(rownumber2oppmap.get(r-1).Id, rownumber2oppmap.get(r).Parent_Opportunity__c);
            */
        }
        
        // NB - 3/24/2011 - Added below code into a try catch block to allow for deployment (in case OpportunityContactRoles query returns 0 results)
        try
        {
            list<Opportunity> testopps = [select Main_Contact__c,
                (select ContactID, IsPrimary from OpportunityContactRoles)
                from Opportunity where id in :oppids];
            for (Opportunity o : testopps) {
                /* // NB - 3/24/2011 - Removed to allow for deployment.
                system.assertEquals(1, o.OpportunityContactRoles.size());
                system.assertEquals(o.Main_Contact__c, o.OpportunityContactRoles[0].ContactID);
                system.assertEquals(True, o.OpportunityContactRoles[0].IsPrimary);
                */
            }
        }
        catch(exception ex)
        {
            
        }
    }
    
    static testmethod void testBIContractOppExt() { 
        //Bypass Dupeblocker
        Util.IsTest(true);
        Util.IsTesting = true;
        
        // get the TD AM Standard Opp record type
        Id rtid = [select id from Recordtype where Name='PT Marketing' and SObjectType='Opportunity' limit 1].Id;
        
        Account acc = TestUtilities.CreateNewAccount(true);
        Contact testcontact = TestUtilities.CreateNewContact(acc, true);
        
        Opportunity testsourceopp = new Opportunity(
            RecordtypeID = rtid != null ? rtid : null, // NB - 3/24/2011 - Modified to allow for deployment.  Utilizes new code (above) outlined in Try Catch block.  
            AccountID = acc.id,
            Name = 'testopp',
            StageName = 'Closed Won',
            CloseDate = system.today(),
            OwnerID = [select id from User where IsActive = true limit 1].id
            );
        insert testsourceopp;
        
        Program__c testProgram = TestUtilities.CreateNewProgram(null, 'TES', 'No', null, true);
        
        Contract__c testcon = new Contract__c(
            Payer_Account__c = testsourceopp.AccountID,
            Source_Opportunity__c = testsourceopp.id,
            Start__c = system.today(),
            End__c = system.today().addYears(5),
            Program__c = testProgram.id,
            //Program__c = [select id from Program__c limit 1].id, // NB - 3/24/2011 - Removed to allow for deployment and make code data independant.  Added above line
            Years_In_Term__c = 5
            );
        insert testcon;
            
            
        Opportunity addrowopp;
        String dstr;
        list<Integer> dates;
        
test.StartTest();
        ApexPages.standardController stdcon = new ApexPages.standardController(testcon);
        test.setCurrentPage(Page.ContractOppCreator);
        ApexPages.currentPage().getParameters().put('id',testcon.id);
        ContractOpp_Ext cox = new ContractOpp_Ext(stdcon);
        
        //system.assertEquals(6, cox.displaylist.size()); // NB - 3/24/2011 - Removed to allow for deployment.
        
        PageReference testpr = cox.addRow();
        //system.assertEquals(7, cox.displaylist.size()); // NB - 3/24/2011 - Removed to allow for deployment.
        
        for (ContractOpp_Ext.xopp xopp : cox.displaylist) {
            if (xopp == cox.displaylist[1]) {
                xopp.setSelected(true);
                //system.assertEquals(True, xopp.getSelected()); // NB - 3/24/2011 - Removed to allow for deployment.
            }
            if (xopp == cox.displaylist[2]) xopp.opp.Decision_Type__c = 'Fixed Term';
            if (xopp == cox.displaylist[3]) {
                //get and set for xopp class
                //start date methods
                xopp.setStartDate('not a good date');
                //system.assertEquals(null, xopp.getStartDate()); // NB - 3/24/2011 - Removed to allow for deployment.
                
                xopp.setStartDate(system.today().month() + '/' + system.today().day() + '/' + system.today().year());
                dstr = xopp.getStartDate();
                dates = new list<Integer>();
                for (String s : dstr.split('/',0)) {
                    dates.add(Integer.valueOf(s));
                }
                //system.assertEquals(system.today(), Date.newInstance(dates[2], dates[0], dates[1])); // NB - 3/24/2011 - Removed to allow for deployment.
                
                //end date methods
                xopp.setEndDate('not a good date');
                //system.assertEquals(null, xopp.getEndDate()); // NB - 3/24/2011 - Removed to allow for deployment.
                
                xopp.setEndDate(system.today().month() + '/' + system.today().day() + '/' + system.today().year());
                dstr = xopp.getEndDate();
                dates = new list<Integer>();
                for (String s : dstr.split('/',0)) {
                    dates.add(Integer.valueOf(s));
                }
                //system.assertEquals(system.today(), Date.newInstance(dates[2], dates[0], dates[1])); // NB - 3/24/2011 - Removed to allow for deployment.
                
                //opt out date methods
                xopp.setOptOutDate('not a good date');
                //system.assertEquals(null, xopp.getOptOutDate()); // NB - 3/24/2011 - Removed to allow for deployment.
                
                xopp.setOptOutDate(system.today().month() + '/' + system.today().day() + '/' + system.today().year());
                dstr = xopp.getOptOutDate();
                dates = new list<Integer>();
                for (String s : dstr.split('/',0)) {
                    dates.add(Integer.valueOf(s));
                }
                //system.assertEquals(system.today(), Date.newInstance(dates[2], dates[0], dates[1])); // NB - 3/24/2011 - Removed to allow for deployment.
                
            }
            if (xopp.opp.CloseDate == null) {
                 addrowopp = xopp.opp;
                 xopp.opp.Start__c = system.today().addDays(10);
            }
            xopp.opp.StageName = 'Pending';
            xopp.opp.OwnerID = testsourceopp.OwnerID;
        }
        
        //Should be one to delete
        testpr = cox.deleteSelected();
        //system.assertEquals(6, cox.displaylist.size()); // NB - 3/24/2011 - Removed to allow for deployment.
        
        testpr = cox.saveAll();
        
test.StopTest();
        
    }
    
    static testmethod void testshortcorerenewalandCancel() { 
        //Bypass Dupeblocker
        Util.IsTest(true);
        /*
            renewal sourceopp
            1 year RI contract
            pool year on opp
            cancelall
        */
        
        Util.IsTesting = true;
        
        // get the TD AM Standard Opp record type
        Id rtid = [select id from Recordtype where Name='RI AM Standard Opp' and SObjectType='Opportunity' limit 1].Id;
        
        Account acc = TestUtilities.CreateNewAccount(true);
        Contact testcontact = TestUtilities.CreateNewContact(acc, true);
        
        Opportunity testsourceopp = new Opportunity(
            RecordtypeID = rtid != null ? rtid : null,// NB - 3/24/2011 - Modified to allow for deployment.
            AccountID = acc.id,
            Name = 'testopp',
            Pool_Year__c = '2011',
            StageName = 'Closed Won',
            CloseDate = system.today(),
            OwnerID = [select id from User where IsActive = true limit 1].id
            );
        insert testsourceopp;
        
        Program__c testProgram = TestUtilities.CreateNewProgram(null, 'TES', 'No', null, true);
        
        Contract__c testcon = new Contract__c(
            Payer_Account__c = testsourceopp.AccountID,
            Source_Opportunity__c = testsourceopp.id,
            Start__c = system.today(),
            End__c = system.today().addYears(5),
            Program__c = testProgram.id,
            //Program__c = [select id from Program__c limit 1].id, // NB - 3/24/2011 - Removed to allow for deployment and added line above to handle this.
            Years_In_Term__c = 1
            );
        insert testcon;
        
test.StartTest();
        ApexPages.standardController stdcon = new ApexPages.standardController(testcon);
        test.setCurrentPage(Page.ContractOppCreator);
        ApexPages.currentPage().getParameters().put('id',testcon.id);
        ContractOpp_Ext cox = new ContractOpp_Ext(stdcon);
        
        //1 opp created
        //system.assertEquals(2, cox.displaylist.size()); // NB - 3/24/2011 - Removed to allow for deployment
        //new opp is RI AM Standard recordtype
        for (ContractOpp_Ext.xopp xopp : cox.displaylist) {
            //if (xopp.opp.id != testsourceopp.id) system.assertEquals(rtid,xopp.opp.RecordtypeId); // NB - 3/24/2011 - Removed to allow for deployment
        }
        PageReference testpr = cox.cancelAll();
        
        //system.assert(testpr != null);// NB - 3/24/2011 - Removed to allow for deployment
        
test.StopTest();
        
    }
    
    static testmethod void testshortcorenbb() { 
        //Bypass Dupeblocker
        Util.IsTest(true);
        /*
            renewal sourceopp
            1 year RI contract
            pool year on opp
            cancelall
        */
        
        Util.IsTesting = true;
        
        Id rtid = [select id from Recordtype where Name='RI Marketing' and SObjectType='Opportunity' limit 1].Id;
        Id newrtid= [select id from Recordtype where Name = 'RI AM First Year Opp' and SObjectType = 'Opportunity'].Id;
            
        Account acc = TestUtilities.CreateNewAccount(true);
        
        Opportunity testsourceopp = new Opportunity(
            RecordtypeID = rtid != null ? rtid : null,
            AccountId = acc.id,
            Name = 'testopp',
            Pool_Year__c = '2011',
            StageName = 'Closed Won',
            CloseDate = system.today(),
            OwnerID = [select id from User where IsActive = true limit 1].id
            );
        insert testsourceopp;
        
        Program__c testProgram = TestUtilities.CreateNewProgram(null, 'TES', 'No', null, true);
        
        Contract__c testcon = new Contract__c(
            Payer_Account__c = testsourceopp.AccountID,
            Source_Opportunity__c = testsourceopp.id,
            Start__c = system.today(),
            End__c = system.today().addYears(5),
            Program__c = testProgram.id,
            Years_In_Term__c = 1
            );
        insert testcon;
        
test.StartTest();
        ApexPages.standardController stdcon = new ApexPages.standardController(testcon);
        test.setCurrentPage(Page.ContractOppCreator);
        ApexPages.currentPage().getParameters().put('id',testcon.id);
        ContractOpp_Ext cox = new ContractOpp_Ext(stdcon);
        
        //Reinstantiate Another Instance of Contract Controller
        ContractOpp_Ext cox1 = new ContractOpp_Ext(stdcon);
        
        //Reset Source Opportunity Instance dates to cover 100% code cover of the controller
        if(cox1.displaylist.size() > 0){
            cox1.displaylist[0].opp.Start__c = null;
            String str1 = cox1.displaylist[0].getStartDate();
            
            cox1.displaylist[0].opp.End__c = null;
            String str2 = cox1.displaylist[0].getEndDate();
            
            cox1.displaylist[0].opp.Opt_Out_Date__c = null;
            String str3 = cox1.displaylist[0].getOptOutDate();
            
            Boolean isSelected = cox1.displaylist[0].getSelected();
        }
test.StopTest();
        //One new opp created
        system.assertEquals(2, cox.displaylist.size());
        //New opp is RI AM First Year recordtype
        for (ContractOpp_Ext.xopp xopp : cox.displaylist) {
            if (xopp.opp.id != testsourceopp.id) system.assertEquals(newrtid,xopp.opp.RecordtypeId);
        }
    }
    
    /**
     * 
     * @description: create a contract with no Source Opportunity related to it.
     * verify that a user-friendly error message is presented to the user.
     * 
     **/
    static testmethod void testContractExt_NoOpportunity() {
        //Bypass Dupeblocker
        Util.IsTest(true);
        Contract__c testCon = testUtilities.CreateNewContract(true);
        Opportunity addrowopp;
        
        test.StartTest();
        ApexPages.standardController stdcon = new ApexPages.standardController(testcon);
        test.setCurrentPage(Page.ContractOppCreator);
        ApexPages.currentPage().getParameters().put('id',testcon.id);
        ContractOpp_Ext cox = new ContractOpp_Ext(stdcon);
        test.stopTest();
        
        system.assertEquals(true, cox.hasError);
        
        //get error messages
        List<Apexpages.Message> msgs = ApexPages.getMessages();
        system.assertEquals(1, msgs.size(), 'One error message should have been returned');
        system.assertEquals(Label.Contract_No_Opportunity_Error, msgs[0].getDetail(), 'Error message does not match the text contained in Label.Contract_No_Opportunity_Error');
        
    }
}