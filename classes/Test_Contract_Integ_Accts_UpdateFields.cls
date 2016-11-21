@isTest
private class Test_Contract_Integ_Accts_UpdateFields
{

    // Test updating Membership's Earliest Contract, Latest Contract, and Active Contract Identified fields
    static testmethod void testMembershipActiveContractfields()
    { 
        //Bypass Dupeblocker
        Util.IsTest(true);
        System.Debug('### TESTMETHOD BEGIN testMembershipActiveContractfields ###');
        
        test.startTest();
        
        Util.IsTesting = true;
        Util.IsTestingContractIntegratedAcct = true;
        
        //Removed 4/22/11 JN
        //Account testAcct1 = [select Id, Name from Account limit 1];
        Account testAcct1 = new Account(Name = 'testacct1', Account_Formal_Name__c = 'testacct1');
        insert testAcct1;
        
        //Removed 4/22/11 JN
        //Program__c[] testProgs = [select Id, Name, Program_Acronym__c, Create_Memberships__c from Program__c where Create_Memberships__c = 'No' and Program_Acronym__c != null limit 2];
        list<Program__c> testProgs = new list<Program__c>();
        for (Integer i = 0; i < 3; i++) {
            testProgs.add(new Program__c(Name = 'testprog', Program_Acronym__c = 'TEST'));
        }
        insert testProgs;
        Program__c testProg1 = testProgs[0];
        
        List<Membership__c> memInsert = new List<Membership__c>();
        
        Membership__c testMembership1 = new Membership__c(
            Name='Test Membership 1', 
            Account_Name__c=testAcct1.id, 
            Program__c=testProg1.id);
            
        memInsert.add(testMembership1);
        
        Membership__c testMembership2 = new Membership__c(
            Name='Test Membership 2', 
            Account_Name__c=testAcct1.id, 
            Program__c=testProg1.id);
        
        memInsert.add(testMembership2);
        
        insert memInsert;
        
        list<Contract__c> testContracts = new list<Contract__c>();
        Contract__c testContract1 = new Contract__c(
            Name='Test Contract',
            Payer_Account__c = testAcct1.Id,
            Program__c = testProg1.Id,
            Start__c = System.Today() - 3, 
            End__c = System.Today() + 3,
            Year__c = String.valueOf(system.today().Year()),
            Status__c = 'Dropped');
        testContracts.add(testContract1);
        Contract__c testContract2 = new Contract__c(
            Name='Test Contract',
            Payer_Account__c = testAcct1.Id,
            Program__c = testProgs[1].Id,
            Start__c = System.Today() - 3, 
            End__c = System.Today() + 3,
            Year__c = String.valueOf(system.today().Year()),
            Status__c = 'Dropped');
        testContracts.add(testContract2);   
        insert testContracts;
        
        system.debug('### Test Contract: ' + testContract1);
        list<Contract_Integrated_Accounts__c> cias = new list<Contract_Integrated_Accounts__c>();
        Contract_Integrated_Accounts__c cia1 = new Contract_Integrated_Accounts__c(
            Account__c = testAcct1.id,
            Contract__c = testContract1.id); 
        cias.add(cia1);
        Contract_Integrated_Accounts__c cia2 = new Contract_Integrated_Accounts__c(
            Account__c = testAcct1.id,
            Contract__c = testContract2.id); 
        cias.add(cia2);
        insert cias;
        
        cia1 = [select Id, Name, Account__c, Contract__c from Contract_Integrated_Accounts__c where Id = :cia1.id];
        system.debug('### Test Contract Integrated Account: ' + cia1);
        testMembership1 = [select Active_Contract_Idenfied__c, Earliest_Contract__c, Latest_Contract__c from Membership__c where id = :testMembership1.id];
        system.debug('### Test Membership1: ' + testMembership1);
        
        // Validate Membership Updates
        system.assertEquals(testContract1.id, testMembership1.Active_Contract_Idenfied__c);
        system.assertEquals(testContract1.id, testMembership1.Earliest_Contract__c);
        system.assertEquals(testContract1.id, testMembership1.Latest_Contract__c);
        
        // Validate Name
        testAcct1 = [select Id, Name from Account where id = :testAcct1.id];
        string nameChecker = testAcct1.Name.substring(0, Math.Min(55, testAcct1.Name.Length())) + ' - ' +
            testProg1.Program_Acronym__c + ' - '  + testContract1.Year__c + ' - Int';
        nameChecker = nameChecker.substring(0, Math.min(nameChecker.Length(), 80));
        
        system.debug('### Test Contract Integrated Account Name: ' + cia1.Name);
        system.debug('### Test Contract Integrated Account Expected Name: ' + nameChecker);
        
        system.assertEquals(nameChecker, cia1.Name);
        
test.stopTest();

        System.Debug('### TESTMETHOD END testMembershipActiveContractfields ###');
    }
    
    // Test deleting Membership's Earliest Contract, Latest Contract, and Active Contract Identified fields
    static testmethod void testdeleteMembershipActiveContractfields()
    { 
        //Bypass Dupeblocker
        Util.IsTest(true);
        System.Debug('### TESTMETHOD BEGIN testdeleteMembershipActiveContractfields ###');
        
        
        Util.IsTesting = true;
        //Util.IsTestingContractIntegratedAcct = true;
        
        //Removed 4/22/11 for new data JN
        //list<Account> testAccts = [select Id, Name from Account limit 2];
        list<Account> testAccts = new list<Account>();
        for (Integer i = 0; i < 3; i++) {
            testAccts.add(new Account(Name = 'testacct', Account_Formal_Name__c = 'testacct' + String.valueOf(i)));
        }
        insert testAccts;
        
        Account testAcct1 = testAccts[0];
        Account testAcct2 = testAccts[1];
        //Removed 4/22/11 JN
        //Program__c[] testProgs = [select Id, Name, Program_Acronym__c, Create_Memberships__c from Program__c where Create_Memberships__c = 'No' and Program_Acronym__c != null limit 2];
        list<Program__c> testProgs = new list<Program__c>();
        for (Integer i = 0; i < 3; i++) {
            testProgs.add(new Program__c(Name = 'testprog', Program_Acronym__c = 'TEST'));
        }
        insert testProgs;
            
        Program__c testProg1 = testProgs[0];
        
        List<Membership__c> memInsert = new List<Membership__c>();
        
        Membership__c testMembership1 = new Membership__c(
            Name='Test Membership 1', 
            Account_Name__c=testAcct1.id, 
            Program__c=testProg1.id);
            
        memInsert.add(testMembership1);
        
        insert memInsert;
        
        list<Contract__c> testContracts = new list<Contract__c>();
        Contract__c testContract1 = new Contract__c(
            Name='Test Contract',
            Payer_Account__c = testAcct1.Id,
            Program__c = testProg1.Id,
            Start__c = System.Today() - 5, 
            End__c = System.Today() + 3,
            Year__c = String.valueOf(system.today().Year()),
            Status__c = 'Dropped');
        testContracts.add(testContract1);
        Contract__c testContract2 = new Contract__c(
            Name='Test Contract',
            Payer_Account__c = testAcct2.Id,
            Program__c = testProg1.Id,
            Start__c = System.Today() - 3, 
            End__c = System.Today() + 5,
            Year__c = String.valueOf(system.today().Year()),
            Status__c = 'Dropped');
        testContracts.add(testContract2);   
        insert testContracts;
        
        list<Contract_Integrated_Accounts__c> cias = new list<Contract_Integrated_Accounts__c>();
        Contract_Integrated_Accounts__c cia2 = new Contract_Integrated_Accounts__c(
            Account__c = testAcct1.id,
            Contract__c = testContract2.id); 
        cias.add(cia2);
        insert cias;
        
        testMembership1 = [select Active_Contract_Idenfied__c, Earliest_Contract__c, Latest_Contract__c from Membership__c where id = :testMembership1.id];
        system.debug('### Test Membership1: ' + testMembership1);
        
        // Validate Membership Updates
        system.assertEquals(testContract1.id, testMembership1.Earliest_Contract__c);
        system.assertEquals(testContract2.id, testMembership1.Latest_Contract__c);
        system.assertEquals(testContract2.id, testMembership1.Active_Contract_Idenfied__c);
        
test.startTest();
system.debug('\n\n156 delete');     
        delete cias;
test.stopTest();
        testMembership1 = [select Active_Contract_Idenfied__c, Earliest_Contract__c, Latest_Contract__c from Membership__c where id = :testMembership1.id];
        system.debug('### Test Membership1: ' + testMembership1);
        
        // Validate Membership Updates
        system.assertEquals(testContract1.id, testMembership1.Earliest_Contract__c);
        system.assertEquals(testContract1.id, testMembership1.Latest_Contract__c);
// DAF - 03-13-12        system.assertEquals(testContract1.id, testMembership1.Active_Contract_Idenfied__c);
        
        
        System.Debug('### TESTMETHOD END testdeleteMembershipActiveContractfields ###');
    }

    // Test updating Membership's Earliest Contract, Latest Contract, and Active Contract Identified fields with CIAs
    static testmethod void testCIATriggerMembershipFields()
    { 
        //Bypass Dupeblocker
        Util.IsTest(true);
        System.Debug('### TESTMETHOD BEGIN testCIATriggerMembershipFields ###');
        
        Util.IsTesting = true;
        
        // INSERT TEST //
        // Create new test Accounts
        list<Account> testaccs = new list<Account>();
        Account testAcct1 = new Account(Name='Test Trigger Account1', Account_Formal_Name__c='Test Trigger Account1', Primary_City__c = 'Washington', Primary_State_Province__c = 'DC'); // Create account of 'Other' record Type
        testaccs.add(testAcct1);
        Account testAcct2 = new Account(Name='Test Trigger Account1', Account_Formal_Name__c='Test Trigger Account1', Primary_City__c = 'Washington', Primary_State_Province__c = 'DC'); // Create account of 'Other' record Type
        testaccs.add(testAcct2);
        Account testAcct3 = new Account(Name='Test Trigger Account1', Account_Formal_Name__c='Test Trigger Account1', Primary_City__c = 'Washington', Primary_State_Province__c = 'DC'); // Create account of 'Other' record Type
        testaccs.add(testAcct3);
        insert testaccs;
        
        // Create new test Program for use as the Program on the Contract
        Program__c testProg1 = new Program__c(Name='Test Trigger Program', Program_Acronym__c='ZZZ', Create_memberships__c='No'); // Create program
        
        insert testProg1;
        
       // Create Memberships
        list<Membership__c> testmems = new list<Membership__c>();
        Membership__c testMembership1 = new Membership__c(
            Name='Test Membership 1', 
            Account_Name__c=testAcct1.id, 
            Program__c=testProg1.id);
        testmems.add(testMembership1);
        Membership__c testMembership2 = new Membership__c(
            Name='Test Membership 2', 
            Account_Name__c=testAcct2.id, 
            Program__c=testProg1.id);
        testmems.add(testMembership2);
        
        insert testmems;
        
        // Create new test Contracts
        list<Contract__c> testcontracts = new list<Contract__c>();
        
        Contract__c testContract1 = new Contract__c(
            Name='Test Contract', 
            Payer_Account__c = testAcct1.Id, 
            Program__c = testProg1.Id, 
            Start__c = System.Today() - 3, 
            End__c = System.Today() + 3 ,
            Status__c = 'Dropped'
            );
        testcontracts.add(testContract1);
        Contract__c testContract2 = new Contract__c(
            Name='Test Contract', 
            Payer_Account__c = testAcct2.Id, 
            Program__c = testProg1.Id, 
            Start__c = System.Today() - 3000, 
            End__c = System.Today() - 2000 ,
            Status__c = 'Dropped'
            );
        testcontracts.add(testContract2);
        Contract__c testContract3 = new Contract__c(
            Name='Test Contract', 
            Payer_Account__c = testAcct3.Id, 
            Program__c = testProg1.Id, 
            Start__c = System.Today() +1000, 
            End__c = System.Today() + 2000 ,
            Status__c = 'Dropped'
            );
        testcontracts.add(testContract3);
            
        // TEST INSERT //
        // Insert
        insert testcontracts;
        
        //Connect testContract1 to testMembership2
        list<Contract_Integrated_Accounts__c> testcias = new list<Contract_Integrated_Accounts__c>();
        testcias.add(new Contract_Integrated_Accounts__c(
            Name = 'testcia',
            Contract__c = testContract1.id,
            Account__c = testAcct2.id
            ));
        testcias.add(new Contract_Integrated_Accounts__c(
            Name = 'testcia',
            Contract__c = testContract3.id,
            Account__c = testAcct2.id
            ));
        insert testcias;
        
        testContract1 = new Contract__c(Id = testContract1.id, Start__c = system.today().addDays(-4));
        testContract3 = new Contract__c(Id = testContract3.id, Name = 'testnameupdate');
        testcontracts = new list<Contract__c>{testContract1, testContract3};
            
test.startTest();
system.debug('\n\n184 withcias update')   ;    
        update testcontracts;
test.stopTest();       
       
        testmems = [select Active_Contract_Idenfied__c, Earliest_Contract__c, Latest_Contract__c from Membership__c where id in :testmems];
system.debug('\n\ntestMembership1 ' + testMembership1);         
        for (Membership__c mem : testmems) {
            if (mem.id == testMembership1.id) {
                system.assertEquals(testContract1.id, mem.Active_Contract_Idenfied__c);
                system.assertEquals(testContract1.id, mem.Earliest_Contract__c);
                system.assertEquals(testContract1.id, mem.Latest_Contract__c);
        
            }
            //reflects testContract1 as well as testContract2 and 3
            if (mem.id == testMembership2.id) {
                system.assertEquals(testContract1.id, mem.Active_Contract_Idenfied__c);
                system.assertEquals(testContract2.id, mem.Earliest_Contract__c);
                system.assertEquals(testContract3.id, mem.Latest_Contract__c);
            }
        }
        
System.Debug('### TESTMETHOD END testCIATriggerMembershipFields ###');
    }
    
    
    // Test updating Contract's status from an 'Active' status to one that is 'Inactive' (pending, closed, void)
    static testmethod void testUpdateContractStatus()
    { 
        //Bypass Dupeblocker
        Util.IsTest(true);
        System.Debug('### TESTMETHOD BEGIN testCIATriggerMembershipFields ###');
        
        Util.IsTesting = true;
        
        // INSERT TEST //
        // Create new test Accounts
        list<Account> testaccs = new list<Account>();
        Account testAcct1 = TestUtilities.CreatenewAccount(false);
        testaccs.add(testAcct1);
        Account testAcct2 = TestUtilities.CreatenewAccount(false);
        testaccs.add(testAcct2);
        Account testAcct3 = TestUtilities.CreatenewAccount(false);
        testaccs.add(testAcct3);
        insert testaccs;
        
        // Create new test Program for use as the Program on the Contract
        Program__c testProg1 = TestUtilities.CreateNewProgram(false);
        testProg1.Create_memberships__c = 'No';
        insert testProg1;
        
       // Create Memberships
        list<Membership__c> testmems = new list<Membership__c>();
        Membership__c testMembership1 = TestUtilities.CreateNewMembership(testAcct1.Id, testProg1.Id, false);
        testmems.add(testMembership1);
        Membership__c testMembership2 = TestUtilities.CreateNewMembership(testAcct2.Id, testProg1.Id, false);
        testmems.add(testMembership2);
        
        insert testmems;
        
        // Create new test Contracts
        list<Contract__c> testcontracts = new list<Contract__c>();
        
        Contract__c testContract1 = new Contract__c(
            Name='Test Contract', 
            Payer_Account__c = testAcct1.Id, 
            Program__c = testProg1.Id, 
            Start__c = System.Today() - 3, 
            End__c = System.Today() + 3 ,
            Status__c = 'Dropped'
            );
        testcontracts.add(testContract1);
        Contract__c testContract2 = new Contract__c(
            Name='Test Contract', 
            Payer_Account__c = testAcct2.Id, 
            Program__c = testProg1.Id, 
            Start__c = System.Today() - 3000, 
            End__c = System.Today() - 2000 ,
            Status__c = 'Dropped'
            );
        testcontracts.add(testContract2);
        Contract__c testContract3 = new Contract__c(
            Name='Test Contract', 
            Payer_Account__c = testAcct3.Id, 
            Program__c = testProg1.Id, 
            Start__c = System.Today() +1000, 
            End__c = System.Today() + 2000 ,
            Status__c = 'Dropped'
            );
        testcontracts.add(testContract3);
        
        insert testcontracts;
        
        //Connect testContract1 to testMembership2
        list<Contract_Integrated_Accounts__c> testcias = new list<Contract_Integrated_Accounts__c>();
        testcias.add(new Contract_Integrated_Accounts__c(
            Name = 'testcia',
            Contract__c = testContract1.id,
            Account__c = testAcct2.id
            ));
        testcias.add(new Contract_Integrated_Accounts__c(
            Name = 'testcia',
            Contract__c = testContract3.id,
            Account__c = testAcct2.id
            ));
        insert testcias;
        
        testContract1 = new Contract__c(Id = testContract1.id, Start__c = system.today().addDays(-4), Status__c = 'Pending');
        testContract3 = new Contract__c(Id = testContract3.id, Name = 'testnameupdate');
        testcontracts = new list<Contract__c>{testContract1, testContract3};
            
        test.startTest();
            system.debug('\n\n184 withcias update')   ;    
            update testcontracts;
        test.stopTest();       
       
        testmems = [select Active_Contract_Idenfied__c, Earliest_Contract__c, Latest_Contract__c from Membership__c where id in :testmems];
        system.debug('\n\ntestMembership1 ' + testMembership1);         
        for (Membership__c mem : testmems) {
            if (mem.id == testMembership1.id) {
                system.assertEquals(null, mem.Active_Contract_Idenfied__c);
                system.assertEquals(null, mem.Earliest_Contract__c);
                system.assertEquals(null, mem.Latest_Contract__c);
        
            }
            //reflects testContract1 as well as testContract2 and 3
            if (mem.id == testMembership2.id) {
                system.assertEquals(testContract3.Id, mem.Active_Contract_Idenfied__c);
                system.assertEquals(testContract2.id, mem.Earliest_Contract__c);
                system.assertEquals(testContract3.id, mem.Latest_Contract__c);
            }
        }
        
System.Debug('### TESTMETHOD END testCIATriggerMembershipFields ###');
    }

    static testmethod void testContractUpdateMembershipFields()
    { 
        //Bypass Dupeblocker
        Util.IsTest(true);
        /*  Make sure Membership fields are being set properly */
        //set flags to keep triggers out of the way
        Util.IsTesting = true;
        //Util.IsBatch = true;
        
        list<Account> testaccs = new list<Account>();
        Account a1origPayer = new Account(Name = 'testacc', Account_Formal_Name__c = 'testacc1');
        testaccs.add(a1origPayer);
        Account a2newPayer = new Account(Name = 'testacc', Account_Formal_Name__c = 'testacc2');
        testaccs.add(a2newPayer);
        Account a3cia = new Account(Name = 'testacc', Account_Formal_Name__c = 'testacc3');
        testaccs.add(a3cia);
        insert testaccs;
        
        Contact c = new Contact(LastName = 'test', AccountID = a3cia.id);
        insert c;
        
        Program__c prog = new Program__c(Name = 'testprog');
        insert prog;
        
        list<Membership__c> mems = new list<Membership__c>();
        mems.add(new Membership__c(
            Account_Name__c = a3cia.id,
            Program__c = prog.id,
            Name = 'testmem'
            ));
        //mems.add( new Membership__c(
        //  Account_Name__c = a3.id,
        //  Program__c = prog.id,
        //  Name = 'testmem'
        //  ));
        //mems.add( new Membership__c(
        //  Account_Name__c = a3.id,
        //  Program__c = prog.id,
        //  Name = 'testmem'
        //  ));
        insert mems;
        
        list<Contract__c> contracts = new list<Contract__c>();
        
        //Negotiated Amount, Type, Start, End, Year, Program, Join Date, Payer Account, Main Contact, and Invoice Contact
        //three contracts, one for each Account     
        contracts.add(new Contract__c(
            Payer_Account__c = a1origPayer.id,
            Program__c = prog.id,
            Status__c = 'ATL',
            Start__c = system.today().addDays(-1194),
            End__c = system.today().addDays(-828),
            Year__c = '2010',
            Main_Contact__c = c.id,
            Invoice_Contact__c = c.id,
            Join_Date__c = system.today().addYears(-5),
            Type__c = 'NBB',
            Negotiated_Amount__c = 100,
            Active__c = False
            ));
        contracts.add(new Contract__c(
            Payer_Account__c = a1origPayer.id,
            Program__c = prog.id,
            Status__c = 'ATL',
            Start__c = system.today().addDays(-829),
            End__c = system.today().addDays(-465),
            Year__c = '2011',
            Main_Contact__c = c.id,
            Invoice_Contact__c = c.id,
            Join_Date__c = system.today().addYears(-5),
            Type__c = 'NBB',
            Negotiated_Amount__c = 100
            ));
        contracts.add(new Contract__c(
            Payer_Account__c = a2newPayer.id,
            Program__c = prog.id,
            Status__c = 'ATL',
            Start__c = system.today().addDays(-464),
            End__c = system.today().addDays(-99),
            Year__c = '2012',
            Main_Contact__c = c.id,
            Invoice_Contact__c = c.id,
            Join_Date__c = system.today().addYears(-5),
            Type__c = 'NBB',
            Negotiated_Amount__c = 100,
            Active__c = true
            ));
        contracts.add(new Contract__c(
            Payer_Account__c = a2newPayer.id,
            Program__c = prog.id,
            Status__c = 'ATL',
            Start__c = system.today().addDays(-100),
            End__c = system.today().addDays(265),
            Year__c = '2013',
            Main_Contact__c = c.id,
            Invoice_Contact__c = c.id,
            Join_Date__c = system.today().addYears(-5),
            Type__c = 'NBB',
            Negotiated_Amount__c = 100,
            Active__c = true
            ));
system.debug('\n\n151 insert');     
        insert contracts;
        
        //a Contract Integrated Account, previously on Contract with A1, but now on contract with A2, and CIA account = A3 
        //(This will link the A1 Contract to the A2 Membership.)
        contracts = [select Join_Date__c, Active__c, Start__c, Payer_Account__c from Contract__c where id in :contracts];
        List<Contract_Integrated_Accounts__c> lCIAs1 = new list<Contract_Integrated_Accounts__c>();
        List<Contract_Integrated_Accounts__c> lCIAs2 = new list<Contract_Integrated_Accounts__c>();
        Contract__c activeContract;
        for (Contract__c con : contracts) {
            if (con.Payer_Account__c == a1origPayer.id) {
                Contract_Integrated_Accounts__c testcia1 = new Contract_Integrated_Accounts__c(
                    Contract__c = con.id,
                    Account__c = a3cia.id);
                
                //insert testcia1;
                lCIAs1.add(testcia1);
            }
            else if (con.Payer_Account__c == a2newPayer.id) {
                Contract_Integrated_Accounts__c testcia2 = new Contract_Integrated_Accounts__c(
                    Contract__c = con.id,
                    Account__c = a3cia.id);
                
                //insert testcia2;
                lCIAs2.add(testcia2);
            }
            if(con.Active__c == true){
                system.debug('CONTRACT: '+con);
                activeContract = con;
            }
            //asserts
            //if (con.Start__c > system.today()) {
            //  system.assertEquals(true, con.Active__c);
            //}
        }
        insert lCIAs2;
        insert lCIAs1;
        
        //Create query string to test batch on these contracts
        String querystring = 'select id , start__c, end__c, Program__c, Payer_Account__c, lastmodifieddate, active__c from Contract__c'
            + ' where id in (';
        Boolean FirstField = true;
        for (Contract__c con : contracts) {
            if (FirstField) {
                FirstField = false;
            } else {
                querystring += ', ';
            }
            querystring += '\'' + con.id + '\'';
        }
        querystring += ')';
system.debug('\n\n136 testing query ' + querystring);       
        
        mems = [select Join_Date_Most_Recent__c, Account_Name__c, Active_Contract_Idenfied__c, Earliest_Contract__c, Latest_Contract__c 
            from Membership__c where id in :mems];
        for (Membership__c mem : mems) {
            system.debug('JRB- MEMREC : ' + mem);
            //system.assertEquals(null, mem.Active_Contract_Idenfied__c);
            system.assertEquals(activeContract.Id, mem.Active_Contract_Idenfied__c);
            system.assertNotEquals(null, mem.Earliest_Contract__c);
            //system.assertEquals(null, mem.Latest_Contract__c);
            system.assertEquals(activeContract.Id, mem.Latest_Contract__c);
            system.assertEquals(activeContract.Join_Date__c, mem.Join_Date_Most_Recent__c);
        }
        /*
test.StartTest();

        Batch_ConfirmActiveContract bcac = new Batch_ConfirmActiveContract();
        bcac.query = querystring;
        Database.executeBatch(bcac, 50);
system.debug('\n\n150 stoptest');       

test.StopTest();        
        *//*
test.StartTest();

        Batch_Membership_ActiveContract bcac = new Batch_Membership_ActiveContract();
        //bcac.query = querystring;
        Database.executeBatch(bcac, 50);
system.debug('\n\n150 stoptest');       

test.StopTest();    
        *//*
        //Verify we set all the Membership fields correctly.
        mems = [select Account_Name__c, Active_Contract_Idenfied__c, Active_Contract_Idenfied__r.Start__c, 
            Earliest_Contract__c, Earliest_Contract__r.Start__c,
            Latest_Contract__c, Latest_Contract__r.End__c
            from Membership__c where id in :mems];
            
        for (Membership__c mem : mems) {
            if (mem.Account_Name__c == a3cia.id) { //should only have the A1 contract
                system.assertEquals(system.today().addDays(-100), mem.Active_Contract_Idenfied__r.Start__c);
                system.assertEquals(system.today().addDays(-100), mem.Earliest_Contract__r.Start__c);
                system.assertEquals(system.today().addDays(265), mem.Latest_Contract__r.End__c);
            //} else if (mem.Account_Name__c == a2.id) { //Has Contracts A1 and A2, through Contract Integrated Accounts
            //  system.assertEquals(system.today().addDays(-10), mem.Active_Contract_Idenfied__r.Start__c);
            //  system.assertEquals(system.today().addDays(-100), mem.Earliest_Contract__r.Start__c);
            //  system.assertEquals(system.today().addDays(355), mem.Latest_Contract__r.End__c);
            //} else if (mem.Account_Name__c == a3.id) { //Has Active Contract, but both Contracts are in future
            //  system.assertEquals(system.today().addDays(900), mem.Active_Contract_Idenfied__r.Start__c);
            //  system.assertEquals(system.today().addDays(900), mem.Earliest_Contract__r.Start__c);
            //  system.assertEquals(system.today().addDays(1005), mem.Latest_Contract__r.End__c);
            }
            
        }
        */
    }   


}