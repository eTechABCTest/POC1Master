/*
  Purpose:
        The test class for the JournalApprovalValidationController 
        
  Initiative: IconATG FinancialForce PSA Implementation 
  Author:     William Rich
  Company:    IconATG
  Contact:    william.rich@iconatg.com
  Created:    3/21/2015
*/

@isTest(SeeAllData=true)
private class JournalApprovalValidationControllerTest {
    
    static testMethod void testJournalApprovalValidation() { 
        ffbext__OneTouchSettings__c oneTouchSettings = ffbext__OneTouchSettings__c.getOrgDefaults();
        oneTouchSettings.EnableJournalApproval__c = true;
        update oneTouchSettings;

         c2g__codaJournal__c journal = new c2g__codaJournal__c(
            c2g__Type__c = 'Manual Journal',
            ffgl__DeriveCurrency__c = true,
            ffgl__DerivePeriod__c = true,
            c2g__JournalStatus__c = 'In Progress',
            c2g__JournalDate__c = Date.today(),
            Registered_Date__c = Date.today(),
            Approved__c = false
        );
        insert journal;
        
        c2g__codaJournal__c journal_1 = [
            select Name
            from c2g__codaJournal__c
            where Id = :journal.Id
        ];

        c2g__codaGeneralLedgerAccount__c glAccount = new c2g__codaGeneralLedgerAccount__c(
            Name = '99999999999 - Test GLA',
            c2g__ReportingCode__c = '99999999999',
            c2g__Type__c = 'Balance Sheet'
        );
        insert glAccount;

        c2g__codaDimension1__c dim1 = new c2g__codaDimension1__c(
            Name = 'Test Dim1',
            c2g__ReportingCode__c = 'zZzZzZzZzZzZzZ'
        );
        insert dim1;

        Decimal amount = 10.0;
        List<c2g__codaJournalLineItem__c> jLineItems = new List<c2g__codaJournalLineItem__c>();
        c2g__codaJournalLineItem__c jLineItem_1 = new c2g__codaJournalLineItem__c(
            c2g__LineNumber__c = 1,
            c2g__Journal__c = journal.Id,
            c2g__LineType__c = 'General Ledger Account',
            c2g__GeneralLedgerAccount__c = glAccount.Id,
            c2g__Value__c = amount,
            c2g__LineDescription__c = 'Test JLA',
            c2g__Dimension1__c = dim1.Id
        );
        jLineItems.add(jLineItem_1);

        c2g__codaJournalLineItem__c jLineItem_2 = new c2g__codaJournalLineItem__c(
            c2g__LineNumber__c = 2,
            c2g__Journal__c = journal.Id,
            c2g__LineType__c = 'General Ledger Account',
            c2g__GeneralLedgerAccount__c = glAccount.Id,
            c2g__Value__c = -amount,
            c2g__LineDescription__c = 'Test JLA',
            c2g__Dimension1__c = dim1.Id
        );
        jLineItems.add(jLineItem_2);
        insert jLineItems;

        ApexPages.StandardController stdController = new ApexPages.StandardController(journal);
        JournalApprovalValidationController journalController = new JournalApprovalValidationController(stdController);
        
        Test.startTest();

        journalController.validateApproval();
        List<ApexPages.Message> msgs = ApexPages.getMessages();
        System.assertEquals(1, msgs.size());
        journalController.cancel();

        User approver = createUser();
        System.runAs(approver) {
            journal.Approved__c = true;
            update journal;

            journalController.validateApproval();
        }

        Test.stopTest();

        journal_1 = [
            select Name, Approved__c
            from c2g__codaJournal__c
            where Id = :journal.Id
        ];
        System.assertEquals(true, journal_1.Approved__c);        
	}
    
    static testMethod void testJournalApprovalValidationList() { 
        ffbext__OneTouchSettings__c oneTouchSettings = ffbext__OneTouchSettings__c.getOrgDefaults();
        oneTouchSettings.EnableJournalApproval__c = true;
        update oneTouchSettings;

         c2g__codaJournal__c journal = new c2g__codaJournal__c(
            c2g__Type__c = 'Manual Journal',
            ffgl__DeriveCurrency__c = true,
            ffgl__DerivePeriod__c = true,
            c2g__JournalStatus__c = 'In Progress',
            c2g__JournalDate__c = Date.today(),
            Registered_Date__c = Date.today(),
            Approved__c = false
        );
        insert journal;
        
        c2g__codaJournal__c journal_1 = [
            select Name
            from c2g__codaJournal__c
            where Id = :journal.Id
        ];

        c2g__codaGeneralLedgerAccount__c glAccount = new c2g__codaGeneralLedgerAccount__c(
            Name = '99999999999 - Test GLA',
            c2g__ReportingCode__c = '99999999999',
            c2g__Type__c = 'Balance Sheet'
        );
        insert glAccount;

        c2g__codaDimension1__c dim1 = new c2g__codaDimension1__c(
            Name = 'Test Dim1',
            c2g__ReportingCode__c = 'zZzZzZzZzZzZzZ'
        );
        insert dim1;

        Decimal amount = 10.0;
        List<c2g__codaJournalLineItem__c> jLineItems = new List<c2g__codaJournalLineItem__c>();
        c2g__codaJournalLineItem__c jLineItem_1 = new c2g__codaJournalLineItem__c(
            c2g__LineNumber__c = 1,
            c2g__Journal__c = journal.Id,
            c2g__LineType__c = 'General Ledger Account',
            c2g__GeneralLedgerAccount__c = glAccount.Id,
            c2g__Value__c = amount,
            c2g__LineDescription__c = 'Test JLA',
            c2g__Dimension1__c = dim1.Id
        );
        jLineItems.add(jLineItem_1);

        c2g__codaJournalLineItem__c jLineItem_2 = new c2g__codaJournalLineItem__c(
            c2g__LineNumber__c = 2,
            c2g__Journal__c = journal.Id,
            c2g__LineType__c = 'General Ledger Account',
            c2g__GeneralLedgerAccount__c = glAccount.Id,
            c2g__Value__c = -amount,
            c2g__LineDescription__c = 'Test JLA',
            c2g__Dimension1__c = dim1.Id
        );
        jLineItems.add(jLineItem_2);
        insert jLineItems;

        List<c2g__codaJournal__c> journalList = new List<c2g__codaJournal__c>();
        journalList.add(journal);

         c2g__codaJournal__c unapprovedJournal = new c2g__codaJournal__c(
            c2g__Type__c = 'Manual Journal',
            ffgl__DeriveCurrency__c = true,
            ffgl__DerivePeriod__c = true,
            c2g__JournalStatus__c = 'In Progress',
            c2g__JournalDate__c = Date.today(),
            Registered_Date__c = Date.today(),
            Approved__c = false
        );
        insert unapprovedJournal;
        journalList.add(unapprovedJournal);
        
        ApexPages.StandardSetController stdController = new ApexPages.StandardSetController(journalList);
        stdController.setSelected(journalList);
        JournalApprovalValidationListController journalController = new JournalApprovalValidationListController(stdController);
        
        Test.startTest();

        User approver = createUser();
        System.runAs(approver) {
            journal.Approved__c = true;
            update journal;

            journalController.validateApprovalList();
        }

        journalController.back();

        Test.stopTest();

        journal_1 = [
            select Name, Approved__c
            from c2g__codaJournal__c
            where Id = :journal.Id
        ];
        System.assertEquals(true, journal_1.Approved__c);        
    }
    
    static testMethod void testJournalApproverValidation() { 
         c2g__codaJournal__c journal = new c2g__codaJournal__c(
            c2g__Type__c = 'Manual Journal',
            ffgl__DeriveCurrency__c = true,
            ffgl__DerivePeriod__c = true,
            c2g__JournalStatus__c = 'In Progress',
            c2g__JournalDate__c = Date.today(),
            Registered_Date__c = Date.today(),
            Approved__c = false
        );
        insert journal;
        
        try {
            // Should throw and exception because the approver is the same as the creator.
            journal.Approved__c = true;
            update journal;
            System.assertEquals(true, false);
        }
        catch (Exception e) {
            c2g__codaJournal__c approvedJournal = [
                select Approved__c
                from c2g__codaJournal__c
                where Id = :journal.Id
            ];

            System.assertEquals(false, approvedJournal.Approved__c);
       }

        User approver = createUser();
        System.runAs(approver) {
            try {
                journal.Approved__c = true;
                update journal;

                c2g__codaJournal__c approvedJournal = [
                    select Approved__c
                    from c2g__codaJournal__c
                    where Id = :journal.Id
                ];

                System.assertEquals(true, approvedJournal.Approved__c);
            }
            catch (Exception e) {
                System.assertEquals(true, false);
            }

        }
    }

    public static User createUser() {
        Profile p = [SELECT Id FROM Profile WHERE Name = 'System Administrator']; 
        
        long l = (long) (Math.random() * 10000000.0);
        String userId = String.valueOf(l);
        
        User u = new User(
            Alias = userId, 
            Email = userId + '@advisory.com', 
            EmailEncodingKey = 'UTF-8', 
            LastName = 'TestUser', 
            LanguageLocaleKey = 'en_US', 
            LocaleSidKey = 'en_US', 
            ProfileId = p.Id, 
            TimeZoneSidKey = 'America/Los_Angeles', 
            UserName = userId + '@advisory.com',
            IsActive = true
        );
        insert u;
        return u;
    }
}