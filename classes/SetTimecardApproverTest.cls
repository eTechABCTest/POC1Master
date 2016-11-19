/*
    Purpose:
       The Test class for the SetTimecardApprover trigger.
            
    Initiative: IconATG PSA Implementation
    Author:     William Rich
    Company:    IconATG
    Contact:    william.rich@iconatg.com
    Created:    9/16/2013
*/

@isTest(SeeAllData=false)
private class SetTimecardApproverTest {
    
    static testMethod void testPMApprover() {
        pse__Triggers__c pseTriggers = pse__Triggers__c.getInstance();
        pseTriggers.pse__Resource_Geolocation_Trigger_Disabled__c = true;
        pseTriggers.pse__Res_Request_Geolocation_Trigger_Disabled__c = true;
        upsert pseTriggers;
        
        createConfigValue();
        createDefaultCurrency();
        
        pse__Region__c region = new pse__Region__c(
            Name = 'Test Region'
        );
        insert region;
        
        Contact projMgr = createPM(region);
        pse__Proj__c project = createProject(projMgr, region, false);
        
        Contact resource = createResource(region);
        
        Test.startTest();
        
        pse__Timecard_Header__c timecard = newTimecard(project, resource);
        
        Test.stopTest();
        
        pse__Timecard_Header__c timecard1 = [
            select pse__Approver__c 
            from pse__Timecard_Header__c
            where Id = :timecard.Id
        ];
        
        System.assertEquals(projMgr.pse__Salesforce_User__c, timecard1.pse__Approver__c); 
    }
    
    static testMethod void testMgrApprover() {
        pse__Triggers__c pseTriggers = pse__Triggers__c.getInstance();
        pseTriggers.pse__Resource_Geolocation_Trigger_Disabled__c = true;
        pseTriggers.pse__Res_Request_Geolocation_Trigger_Disabled__c = true;
        upsert pseTriggers;
        
        createConfigValue();
        createDefaultCurrency();
        
        pse__Region__c region = new pse__Region__c(
            Name = 'Test Region'
        );
        insert region;
        
        Contact projMgr = createPM(region);
        pse__Proj__c project = createProject(projMgr, region, true);
        
        Contact resource = createResource(region);
        
        User mgr = createUser();
        User me = [select ManagerId from User where Id = :UserInfo.getUserId()];
        me.ManagerId = mgr.Id;
        update me;
        
        Test.startTest();
        
        pse__Timecard_Header__c timecard = newTimecard(project, resource);
        
        Test.stopTest();
        
        pse__Timecard_Header__c timecard1 = [
            select pse__Approver__c 
            from pse__Timecard_Header__c
            where Id = :timecard.Id
        ];
        
        System.assertEquals(mgr.Id, timecard1.pse__Approver__c); 
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
    
    static pse__Proj__c createProject(Contact projMgr, pse__Region__c region, boolean useReportingMgr) {
        pse__Proj__c project = new pse__Proj__c(
            Name='Test Project',
            pse__Is_Active__c=true,
            pse__Is_Billable__c=true,
            pse__Allow_Timecards_Without_Assignment__c=true,
            pse__Allow_Expenses_Without_Assignment__c=true,
            pse__Project_Manager__c = projMgr.Id,
            pse__Start_Date__c = Date.today().toStartOfWeek(),
            pse__End_Date__c = Date.today().toStartOfWeek().addMonths(6),
            pse__Region__c = region.Id,
            Use_Reporting_Manager_as_Approver__c = useReportingMgr
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
            Email = userId + '@iconatg.com', 
            EmailEncodingKey = 'UTF-8', 
            LastName = 'TestUser', 
            LanguageLocaleKey = 'en_US', 
            LocaleSidKey = 'en_US', 
            ProfileId = p.Id, 
            TimeZoneSidKey = 'America/Los_Angeles', 
            UserName = userId + '@iconatg.com',
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
    	/*
        List<Contact> cList = [select Id from Contact where pse__Salesforce_User__c=:UserInfo.getUserId()];
        for (Contact c : cList) {
            c.pse__Salesforce_User__c = null;
        }
        
        if (!cList.isEmpty()) {            
            update cList;
        }
        */
        
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
    
    private static pse__Timecard_Header__c newTimecard(pse__Proj__c project, Contact resource) {
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
    
    private static void createConfigValue() {
        List<appirio_core__Config_Value__c> configValues = [
            select Id, appirio_core__Value__c
            from appirio_core__Config_Value__c
            where appirio_core__Config_Option__r.Name = 'AssignProjectManagerToTimecardApprover'
        ];
        
        appirio_core__Config_Value__c configValue = null;
        if (configValues.isEmpty()) {
            List<appirio_core__Config_Option__c> configOptions = [
                select Id
                from appirio_core__Config_Option__c
                where Name = 'AssignProjectManagerToTimecardApprover'
            ];
            
            appirio_core__Config_Option__c assignPMOption = null;
            if (configOptions.isEmpty()) {
                List<appirio_core__Config_Group__c> configGroups = [
                    select Id
                    from appirio_core__Config_Group__c
                    where Name = 'ASM Triggers'
                ];
                
                appirio_core__Config_Group__c asmTriggers = null;
                if (configGroups.isEmpty()) {
                    asmTriggers = new appirio_core__Config_Group__c(
                        Name = 'ASM Triggers',
                        appirio_core__Key__c = 'asm-triggers'
                    );
                    insert asmTriggers;
                }
                else {
                    asmTriggers = configGroups.get(0);
                }
                
                assignPMOption = new appirio_core__Config_Option__c(
                    Name = 'AssignProjectManagerToTimecardApprover',
                    appirio_core__Config_Group__c = asmTriggers.Id,
                    appirio_core__Allow_Multiple_Values__c = false,
                    appirio_core__Type__c = 'Boolean'
                );
                insert assignPMOption;
            }
            else {
                assignPMOption = configOptions.get(0);
            }
            
            configValue = new appirio_core__Config_Value__c(
                appirio_core__Value__c = 'false',
                appirio_core__Config_Option__c = assignPMOption.Id
            );
        }
        else {
            configValue = configValues.get(0);
        }
        
        configValue.appirio_core__Value__c = 'false';
        upsert configValue;
    }
}