/*
    Purpose:
       The Test class for  Record Level Security.  
            
    Author:     William Rich
    Company:    IconATG
    Contact:    william.rich@iconatg.com
    Created:    7/24/2015
*/

@isTest(SeeAllData=true)
public with sharing class RLSTest {
    
    static testMethod void testSharing() {
        createDefaultCurrency();

        pse__Region__c region = new pse__Region__c(Name = 'Test Region');
        insert region;

        insert new pse__Permission_Control__c(
            pse__User__c = UserInfo.getUserId(), 
            pse__Region__c = region.Id, 
            pse__Staffing__c = true
        );

        Contact resource = createResource(region);
        Contact pm = createPM(region);
        User gm = createUser();

        pse__Proj__c project = createProject(pm, gm, region);
        pse__Assignment__c assignment1 = createAssignment(project, resource);
        pse__Assignment__c assignment2 = createAssignment(project, resource);
        verifyProjectShares(project, resource, pm, gm);

        Test.startTest();

        pse__Timecard_Header__c timecard = createTimecard(project, resource);
        verifyTimecardShare(timecard, pm, gm);

        pse__Expense_Report__c expenseRpt = createExpenseReport(project, resource); 
        verifyExpenseReportShare(expenseRpt, pm, gm);

        pse__Expense__c expense = createExpense(expenseRpt, 'Air Fare');
        verifyExpenseShare(expense, pm, gm);

        Contact newpm = createPM(region);
        User newgm = createUser();
        project.pse__Project_Manager__c = newpm.Id;
        project.Group_Manager__c = newgm.Id;
        update project;

        verifyTimecardShare(timecard, newpm, newgm);
        verifyExpenseReportShare(expenseRpt, newpm, newgm);
        verifyExpenseShare(expense, newpm, newgm);

        Test.stopTest();
    }

    static pse__Proj__c createProject(Contact projMgr, User groupMgr, pse__Region__c region) {
        pse__Proj__c project = new pse__Proj__c(
            Name = 'Test Project',
            pse__Is_Active__c = true,
            pse__Is_Billable__c = true,
            pse__Allow_Timecards_Without_Assignment__c = true,
            pse__Allow_Expenses_Without_Assignment__c = true,
            pse__Project_Manager__c = projMgr.Id,
            pse__Start_Date__c = Date.today().toStartOfWeek(),
            pse__End_Date__c = Date.today().toStartOfWeek().addMonths(6),
            pse__Region__c = region.Id,
            Billable_Expense_Types_Apply__c = true,
            Group_Manager__c = groupMgr.Id
        );
        
        insert project;
        return project;
    }
    
    public static User createUser() {
        Profile p = [SELECT Id FROM Profile WHERE Name = 'System Administrator']; 
        
        long l = (long) (Math.random() * 10000000.0);
        String userId = String.valueOf(l);
        
        User u = new User(
            Alias = userId, 
            Email = userId + '@advisory.com.abc', 
            EmailEncodingKey = 'UTF-8', 
            LastName = 'TestUser', 
            LanguageLocaleKey = 'en_US', 
            LocaleSidKey = 'en_US', 
            ProfileId = p.Id, 
            TimeZoneSidKey = 'America/Los_Angeles', 
            UserName = userId + '@advisory.com.abc',
            IsActive = true
        );
        insert u;
        return u;
    }
    
    public static Contact createPM(pse__Region__c region) {
        User u = createUser();
        
        pse__Work_Calendar__c wc = new pse__Work_Calendar__c(Name='testPMCal');
        insert wc;
        
        Contact projMgr = new Contact(
            LastName = 'testPM',
            pse__Resource_Role__c = 'Project Manager',
            pse__Salesforce_User__c = u.Id,
            pse__Is_Resource__c = true,
            pse__Is_Resource_Active__c = true, 
            pse__Work_Calendar__c = wc.Id,
            MailingCountry = 'USA',
            pse__Region__c = region.Id
        );
        
        insert projMgr;
        return projMgr;
    }

    public static Contact createResource(pse__Region__c region) {
        
        List<Contact> cList = [select Id from Contact where pse__Salesforce_User__c=:UserInfo.getUserId()];
        for (Contact c : cList) {
            c.pse__Salesforce_User__c = null;
        }
        
        if (!cList.isEmpty()) {            
            update cList;
        }
        

        //User u = createUser();
                
        pse__Work_Calendar__c wc = new pse__Work_Calendar__c(Name='test');
        insert wc;
        
        Contact resource = new Contact(
            LastName = 'test',
            pse__Resource_Role__c = 'Consultant',
            pse__Salesforce_User__c = UserInfo.getUserId(),
            pse__Is_Resource__c = true,
            pse__Is_Resource_Active__c = true, 
            pse__Work_Calendar__c = wc.Id,
            MailingCountry = 'USA',
            pse__Region__c = region.Id
        );
        
        insert resource;
        return resource;
    }
    
    private static void createDefaultCurrency() {
        appirio_core__Currency__c usd;
        
        try {
            usd = [Select Id from appirio_core__Currency__c where appirio_core__Currency_Code__c = 'USD'];
        }
        catch(System.QueryException e) {
            usd = new appirio_core__Currency__c(
                Name = 'USD',
                appirio_core__Currency_Code__c = 'USD',
                appirio_core__Is_Corporate_Currency__c = true,
                appirio_core__Is_Test__c = false,
                appirio_core__Is_Void__c = false
            );

            insert usd;
        }       
        
        // rip out the current exchange rates and replace them if they are not present
        delete [Select Id from appirio_core__Currency_Exchange_Rate__c Where appirio_core__Currency__r.appirio_core__Currency_Code__c = 'USD'];
        
        appirio_core__Currency_Exchange_Rate__c rate = new appirio_core__Currency_Exchange_Rate__c(
            appirio_core__Currency__c = usd.Id,
            appirio_core__Effective_Date__c = Date.newInstance(2000, 1, 1),
            appirio_core__Is_Test__c = false,
            appirio_core__Is_Void__c = false,
            appirio_core__Rate__c = 1
        );
        
        insert rate;
    }
    
    private static pse__Timecard_Header__c createTimecard(pse__Proj__c project, Contact resource) {
        pse__Timecard_Header__c timecard = new pse__Timecard_Header__c(
            pse__Project__c = project.Id,
            pse__Resource__c = resource.Id,
            pse__Start_Date__c = Date.today().toStartOfWeek(),
            pse__End_Date__c = Date.today().toStartOfWeek().addDays(6),
            pse__Sunday_Hours__c = 0.0,
            pse__Monday_Hours__c = 8.0,
            pse__Tuesday_Hours__c = 8.0,
            pse__Wednesday_Hours__c = 8.0,
            pse__Thursday_Hours__c = 8.0,
            pse__Friday_Hours__c = 8.0,
            pse__Saturday_Hours__c = 0.0,
            pse__Status__c = 'Saved',
            pse__Approver__c = null
        );
        
        insert timecard;
        return timecard;
    }

    public static void verifyTimecardShare(pse__Timecard_Header__c timecard, Contact pm, User gm) {
        List<pse__Timecard_Header__Share> tShares = [
            select 
                ParentId,
                UserOrGroupId,
                RowCause,
                AccessLevel
            from pse__Timecard_Header__Share
            where 
                ParentId = :timecard.Id and
                (UserOrGroupId = :pm.pse__Salesforce_User__c or UserOrGroupId = :gm.Id)
        ];
        
        System.assertEquals(2, tShares.size());
        for (pse__Timecard_Header__Share tShare : tShares) {
            if (tShare.UserOrGroupId == pm.pse__Salesforce_User__c) {
                System.assertEquals(Schema.pse__Timecard_Header__Share.RowCause.pse__PSE_PM_Share__c, tShare.RowCause);
            }
            else {
                System.assertEquals(Schema.pse__Timecard_Header__Share.RowCause.pse__PSE_Member_Share__c, tShare.RowCause);
            }
            System.assertEquals('Edit', tShare.AccessLevel);
        }
    }
    
    private static pse__Expense_Report__c createExpenseReport(pse__Proj__c project, Contact resource) {
        pse__Expense_Report__c expenseRpt = new pse__Expense_Report__c(
            Name = 'Test Expense Report',
            pse__Resource__c = resource.Id,
            pse__Project__c = project.Id,
            pse__Status__c = 'Draft',
            pse__Submitted__c = false,
            pse__Approved__c = false,
            pse__Include_In_Financials__c = false,
            pse__Billable__c = true
        );
        insert expenseRpt;
        return expenseRpt;
    }
    
    public static void verifyExpenseReportShare(pse__Expense_Report__c expenseRpt, Contact pm, User gm) {
        List<pse__Expense_Report__Share> erShares = [
            select 
                ParentId,
                UserOrGroupId,
                RowCause,
                AccessLevel
            from pse__Expense_Report__Share
            where 
                ParentId = :expenseRpt.Id and
                (UserOrGroupId = :pm.pse__Salesforce_User__c or UserOrGroupId = :gm.Id)
        ];
        
        System.assertEquals(2, erShares.size());
        for (pse__Expense_Report__Share erShare : erShares) {
            if (erShare.UserOrGroupId == pm.pse__Salesforce_User__c) {
                System.assertEquals(Schema.pse__Expense_Report__Share.RowCause.pse__PSE_PM_Share__c, erShare.RowCause);
            }
            else {
                System.assertEquals(Schema.pse__Expense_Report__Share.RowCause.pse__PSE_Member_Share__c, erShare.RowCause);
            }
            System.assertEquals('Edit', erShare.AccessLevel);
        }
    }

    private static pse__Expense__c createExpense(pse__Expense_Report__c expenseRpt, String type) {
        pse__Expense__c expense = new pse__Expense__c(
            pse__Amount__c = 10.0,
            pse__Type__c = type,
            pse__Expense_Report__c = expenseRpt.Id,
            pse__Project__c = expenseRpt.pse__Project__c,
            pse__Expense_Date__c = Date.today().addDays(7),
            pse__Resource__c = expenseRpt.pse__Resource__c,
            pse__Description__c = 'Test Description',
            pse__Billable__c = true,
            pse__Non_Reimbursible__c = true,
            pse__Status__c = 'Draft',
            pse__Submitted__c = false,
            pse__Approved__c = false,
            pse__Include_In_Financials__c = false
        );

        insert expense;
        return expense;
    }

    public static void verifyExpenseShare(pse__Expense__c expense, Contact pm, User gm) {
        List<pse__Expense__Share> eShares = [
            select 
                ParentId,
                UserOrGroupId,
                RowCause,
                AccessLevel
            from pse__Expense__Share
            where 
                ParentId = :expense.Id and
                (UserOrGroupId = :pm.pse__Salesforce_User__c or UserOrGroupId = :gm.Id)
        ];
        
        System.assertEquals(2, eShares.size());
        for (pse__Expense__Share eShare : eShares) {
            if (eShare.UserOrGroupId == pm.pse__Salesforce_User__c) {
                System.assertEquals(Schema.pse__Expense__Share.RowCause.pse__PSE_PM_Share__c, eShare.RowCause);
            }
            else {
                System.assertEquals(Schema.pse__Expense__Share.RowCause.pse__PSE_Member_Share__c, eShare.RowCause);
            }
            System.assertEquals('Edit', eShare.AccessLevel);
        }
    }

    public static pse__Assignment__c createAssignment(pse__Proj__c project, Contact resource) {
        pse__Schedule__c schedule = new pse__Schedule__c(
            pse__Start_Date__c = project.pse__Start_Date__c,
            pse__End_Date__c = project.pse__End_Date__c,
            pse__Monday_Hours__c = 8.0,
            pse__Tuesday_Hours__c = 8.0,
            pse__Wednesday_Hours__c = 8.0,
            pse__Thursday_Hours__c = 8.0,
            pse__Friday_Hours__c = 8.0
        );
        insert schedule;
        
        pse__Assignment__c assignment = new pse__Assignment__c(
            pse__Schedule__c = schedule.Id,
            pse__Resource__c = resource.Id,
            pse__Bill_Rate__c = 200,
            pse__Cost_Rate_Amount__c = 100,
            pse__Project__c = project.Id
        );
        insert assignment;
        return assignment;
    }
    
    public static void verifyProjectShares(pse__Proj__c project, Contact resource, Contact pm, User gm) {
        List<pse__Proj__Share> pShares = [
            select 
                ParentId,
                UserOrGroupId,
                RowCause,
                AccessLevel
            from pse__Proj__Share
            where 
                ParentId = :project.Id and (
                    UserOrGroupId = :resource.pse__Salesforce_User__c or
                    UserOrGroupId = :pm.pse__Salesforce_User__c or
                    UserOrGroupId = :gm.id
                )
        ];
        
        // There are 4: assigned resource, pm, gm and one for the current user who owns the project.
        System.assertEquals(4, pShares.size());
    }
}