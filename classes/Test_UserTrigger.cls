/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are 
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest(seeAllData = false)
private class Test_UserTrigger {
/*
    Purpose         :   Test class for Trigger_User
                
    Create By       :   Simplyforce Technology
    
    Created Date    :   01/19/2012
    
    Current Version :   V1.0
    
    Revision Log    :   V1.0 - Created
                        v1.1 - (SUNJ 12/19/13) - CR-20130118-2218
                        v1.2 - Ajit Surana - Added new method (test_updateOwnerManagerEmailOnOpportunities) - 04/19/2014 - CR-20140403-4951
                        v1.3 - Ajit Surana - Added new method (test_updateCTAssignmentManagerEmailOnOpportunities) - 04/29/2015 - CR-20140403-4951
                        v1.4 - Abhinav Sharma - Added new method (test_doUpdateOnOpportunitiesOnUserUpdate) -  08/26/2015 - CR-20150820-9167
                        v1.5 - Abhinav Sharma - 12/23/2015 - CR-20150706-9060 - Updated SF Admin opportunity record type reference 
                                with some other record type reference. Since it is mark eligible for deletion cycle.
                        v1.6 - Modified By - Abhinav Sharma - 06/14/2016 - CR-20150202-8649 - A Code Refactor CR
                        V1.7 - Modified By - Colin McGloin - 08/08/2016 - CR-20160414-9762 - Added new method "validateSteelbrickApproverAdded"
    
    Coverage        :   v1.6 -  97% - UserTriggerHelper
                                76% - Trigger_User
*/
    
    //HttpRequest instance
    static Httprequest req = new Httprequest();
    
    //instance of Mock service class 
    static CreditCardServiceMockClass mockController = new CreditCardServiceMockClass();
    
    //Modified By - Abhinav Sharma - 06/14/2016 - CR-20150202-8649 - A Code Refactor CR
    //Added by Ajit Surana - 04/19/2014 - CR-20140403-4951
    /**
     * @description: Test method to test out the functionality which will update "Owner Manager Email" on Opportunity records 
     *                  when Manager has been updated on an User record(s).
     *               Test method to test out the functionality which will update CT Assignment's Manager Email on Opportunity records
     *                  When Manager has been updated on User record(s).
    **/
    static testMethod void test_UseCases1() {
        
        //Bypass Dupeblocker
        Util.IsTest(true);
        
        //Bypassing Triggers so then test data can be created easily
        Util.byPassAllTriggers = true;
        
        //Flag for triggers: this is just a test, don't do crazy things.
        Util.isTesting = true;
        
        //Get profile list
        List<Profile> testProfile = [Select Id, Name from Profile where Name = 'System Administrator'];
        
        //Assert for results
        System.assert(testProfile != null);
        System.assert(testProfile.size()>0);
                
        //Test User Create
        List<User> userList = new List<User>();
        
        //Adding user record instances into the list
        userList.add(new User(Username= Math.random()+'@abc.com', LastName='Test User1', FirstName='Test1', Email='testuser1@test.com',
                            Alias='Test1', EmailEncodingKey='UTF-8', languagelocalekey='en_US', ProfileId=testProfile[0].Id, 
                            timezonesidkey='America/Los_Angeles', localesidkey='en_US', EmployeeNumber = '12121212', IsActive = true));
        userList.add(new User(Username= Math.random()+'@abc.com', LastName='Test User2', FirstName='Test2', Email='testuser2@test.com',
                            Alias='Test2', EmailEncodingKey='UTF-8', languagelocalekey='en_US', ProfileId=testProfile[0].Id, 
                            timezonesidkey='America/Los_Angeles', localesidkey='en_US', EmployeeNumber = '12121212', IsActive = true));
        userList.add(new User(Username= Math.random()+'@abc.com', LastName='Test User3', FirstName='Test3', Email='testuser3@test.com',
                            Alias='Test3', EmailEncodingKey='UTF-8', languagelocalekey='en_US', ProfileId=testProfile[0].Id, 
                            timezonesidkey='America/Los_Angeles', localesidkey='en_US', EmployeeNumber = '121232412', IsActive = true));
        
        //Test starts from here
        Test.startTest();
        
        //Enable triggers again
        Util.byPassAllTriggers = false;
        
        //Insert users
        insert userList;
        
        //Disabling triggers
        Util.byPassAllTriggers = true;
        
        //Insert Account record
        Account acc = new Account(Name = 'Test Account');
        insert acc;
        System.assert(acc != null);
        
        //Insert Program record
        Program__c program = new Program__c(Name = 'Test Program', New_Business_Marketer__c = 'RI Marketer', 
                                            Program_Acronym__c = 'ZZZ', Create_memberships__c = 'No', Business_line__c = 'PT');
        insert program;
        System.assert(program != null);
        
        //Department Division Function
        Department_Division_Function__c dDF = new Department_Division_Function__c(Name = 'Test', Cost_Center__c = '1213');
        insert dDF;
        System.assert(dDF != null);
        
        //Record types for "Intranet Item" object
        List<RecordType> rdTypes = [SELECT ID FROM RecordType 
                                        WHERE IsActive = true 
                                        AND SobjectType = 'Intranet_Item__c' 
                                        AND DeveloperName =: UserTriggerHelper.RTName_Office];
        //Asserting for the results
        System.assert(rdTypes != null);
        System.assert(rdTypes.size() > 0);
        
        //Intranet Item
        Intranet_Item__c iT = new Intranet_Item__c(Name = 'Test-0', Location_Code__c = '11232', RecordTypeId = rdTypes[0].ID, 
                                                   Active_Status__c = 'Active', Office_Short_Name__c = 'Test',
                                                  Item_Type__c = 'App Link', Item_Title__c = 'Office',
                                                  Category_Name__c = 'A',Color_Set_Name__c = 'ColorSet');
        insert iT;
        
        //Getting Record Type Id Value for Opportunity
        List<RecordType> oppRecordTypes = [Select Id, Name FROM RecordType WHERE SobjectType = 'Opportunity' 
                                              AND IsActive = true
                                              AND DeveloperName = 'Southwind'];
        System.assert(oppRecordTypes != null);
        System.assert(oppRecordTypes.size() > 0);
        
        //Insert Opportunity record
        Opportunity opportunity = new Opportunity(Name = 'Test Opp', RecordTypeId = oppRecordTypes[0].ID, 
                                                  StageName = 'Prospect', Amount = 100, CloseDate = System.today(), 
                                                  AccountId = acc.Id, OwnerId = userList[0].Id,
                                                  CT_Assignment__c = userList[0].Id, CT_Pass_Status__c = 'Assigned', 
                                                      CT_Reneg_Attempt__c = 'No');
        
        insert opportunity;
        System.assert(opportunity != null);
        
        //Query to retrive "Owner Manager Email" field from Opportunity record
        List<Opportunity> oppList = [SELECT ID, Owner_Manager_Email__c, CT_Assignment_s_Manager__c FROM Opportunity 
                                        WHERE Id=: opportunity.Id];
        
        //Assert for the result
        System.assert(oppList != null);
        System.assert(oppList.size() > 0);
        System.assertEquals(null, oppList[0].Owner_Manager_Email__c);
        System.assertEquals(null, oppList[0].CT_Assignment_s_Manager__c);
        
        //Update first user Manager lookup to second user
        userList[0].ManagerId = userList[1].Id;
        
        //Disabling triggers
        Util.byPassAllTriggers = false;
        
        //Uodating user
        update userList;
        
        //Query to retrive "Owner Manager Email" field from Opportunity record
        oppList = [SELECT ID, Owner_Manager_Email__c FROM Opportunity WHERE Id=: opportunity.Id];
        
        //Assert for the result
        System.assert(oppList != null);
        System.assert(oppList.size()> 0);
        System.assertEquals('testuser2@test.com', oppList[0].Owner_Manager_Email__c);
        
        //Test stops from here
        Test.stopTest();
        
        //Update first user Manager lookup to second user
        userList[0].ManagerId = userList[2].Id;
        update userList;
        
        //Query to retrive "Owner Manager Email" field from Opportunity record
        oppList = [SELECT ID, Owner_Manager_Email__c, CT_Assignment_s_Manager__c FROM Opportunity 
                        WHERE Id=: opportunity.Id];
        
        //Assert for the result
        System.assert(oppList != null);
        System.assert(oppList.size() > 0);
        System.assertEquals('testuser3@test.com', oppList[0].Owner_Manager_Email__c);
        System.assertEquals('testuser3@test.com', oppList[0].CT_Assignment_s_Manager__c);
        
        //Update first user Manager lookup to second user
        userList[0].ManagerId = null;
        userList[0].Associate__c = UserInfo.getUserId();
        userList[0].Cost_Center__c = '1213';
        userList[0].ABC_Department__c = 'EAB';
        userList[0].Location_Code__c = '11232';
            
        //Enabling triggers
        Util.byPassAllTriggers=false;
        update userList;
            
        //Query to retrive "CT Assignment's Manager Email" field from Opportunity record
        oppList = [SELECT ID, CT_Assignment_s_Manager__c FROM Opportunity WHERE Id=: opportunity.Id];
            
        //Assert for the result
        System.assert(oppList != null);
        System.assert(oppList.size()>0);
        System.assertEquals(null, oppList[0].CT_Assignment_s_Manager__c);
        
        //Querying for the user details
        List<User> users = [SELECT ID, ABC_Department__c FROM User WHERE ID =: userList[0].ID];
        
        //Asserting for the results
        System.assert(users != null);
        System.assert(users.size() == 1);
        System.assertEquals(null, users[0].ABC_Department__c);
    }
    
    //Modified By - Abhinav Sharma - 06/14/2016 - CR-20150202-8649 - A Code Refactor CR
    //Added by Abhinav Surana - 08/26/2015 - CR-20150820-9167
    /**
     * @description: Test method to check If any update happens on user "FirstName" or "LastName" field then 
     *                  the corresponding code logic will update all of the opportunity records or not where that user was 
     *                  stamped there as "Marketer". This way it will ultimately keep the "Marketer Name" field
     *                  in sync on those records.
    **/
    static testMethod void test_doUpdateOnOpportunitiesOnUserUpdate(){
        
        //Bypass Dupeblocker
        Util.IsTest(true);
        
        //Bypassing Triggers so then test data can be created easily
        Util.byPassAllTriggers = true;
        
        //Flag for triggers: this is just a test, don't do crazy things.
        Util.isTesting = true;
        
        //Get profile list
        List<Profile> testProfile = [Select Id, Name from Profile where Name = 'System Administrator'];
        
        //Assert for results
        System.assert(testProfile != null);
        System.assert(testProfile.size()>0);
                
        //Test User Create
        List<User> userList = new List<User>();
        
        userList.add(new User(Username= Math.random()+'@abc.com', LastName='Test User1', FirstName='Test1', 
                              Email='testuser1@test.com',
                              Alias='Test1', EmailEncodingKey='UTF-8', languagelocalekey='en_US', 
                              ProfileId=testProfile[0].Id, 
                              timezonesidkey='America/Los_Angeles', localesidkey='en_US', 
                              EmployeeNumber = '12121212', IsActive = true));
        
        //Insert users
        insert userList;
        
        //Changing user context
        System.runAs(userList[0]) {
            
            //Account
            Account a = new Account(Name = 'testacc');
            insert a;
            System.assert(a != null);
            
            //Record types for "Intranet Item" object
            List<RecordType> iTrdTypes = [SELECT ID FROM RecordType 
                                            WHERE IsActive = true 
                                            AND SobjectType = 'Intranet_Item__c' 
                                            AND DeveloperName =: UserTriggerHelper.RTName_Office];
            //Asserting for the results
            System.assert(iTrdTypes != null);
            System.assert(iTrdTypes.size() > 0);
            
            //Intranet Item
            Intranet_Item__c iT = new Intranet_Item__c(Name = 'Test-0', Location_Code__c = '11232', RecordTypeId = iTrdTypes[0].ID, 
                                                       Active_Status__c = 'Active', Office_Short_Name__c = 'Test',
                                                      Item_Type__c = 'App Link', Item_Title__c = 'Office',
                                                      Category_Name__c = 'A',Color_Set_Name__c = 'ColorSet');
            insert iT;
            
            //Record Types
            List<RecordType> rdTypes = [Select ID, DeveloperName FROM RecordType 
                                            Where sObjectType='Opportunity' 
                                            AND IsActive = true AND DeveloperName = 'Southwind'];
        
            //Assert for the result
            System.assert(rdTypes != null);
            System.assertEquals(1, rdTypes.size());
        
            //List to hold the opportunity records
            List<Opportunity> opportunities = new List<Opportunity>();
        
            //Children Opportunities instances
            Opportunity opp_1 = new Opportunity(StageName = 'Prospect', CloseDate = System.today().addDays(8), 
                                                Name = 'Test Opp 1', Amount = 2000, Marketer__c = userList[0].id,
                                                RecordTypeId = rdTypes[0].ID);
            
            
            //Children Opportunities instances
            Opportunity opp_2 = new Opportunity(StageName = 'Prospect', CloseDate = System.today().addDays(7), 
                                                Name = 'Test Opp 1', Amount = 2000, Marketer__c = null,
                                                RecordTypeId = rdTypes[0].ID);
            
            
            //Children Opportunities instances
            Opportunity opp_3 = new Opportunity(StageName = 'Prospect', CloseDate = System.today().addDays(6), 
                                                Name = 'Test Opp 1', Amount = 2000, Marketer__c = userList[0].id, 
                                                RecordTypeId = rdTypes[0].ID);
            
            //Populating list with records
            opportunities.add(opp_1);
            opportunities.add(opp_2);
            opportunities.add(opp_3);
            
            //Enabing triggers again
            Util.ByPassAllTriggers = false;
    
            //Setting flag values
            OpportunityTriggerHelper.EXECUTE_TRIGGER_BEFORE_UPDATE = true;
            OpportunityTriggerHelper.EXECUTE_TRIGGER_AFTER_UPDATE = true;

            insert opportunities;
            
            //Retrieving out the details of the bundle record
            opportunities = [SELECT ID, Name, Marketer_Name__c 
                                   FROM Opportunity 
                                   ORDER BY CloseDate DESC];
        
            //Asserting for the results
            System.assertEquals(3, opportunities.size());
            System.assertEquals('Test1' + ' ' + 'Test User1', opportunities[0].Marketer_Name__c);
            System.assertEquals(null, opportunities[1].Marketer_Name__c);
            System.assertEquals('Test1' + ' ' + 'Test User1', opportunities[2].Marketer_Name__c);
            
            //Test starts from here
            Test.startTest();
            
            //Bypassing all triggers
            Util.byPassAllTriggers = false;

            //Setting flag values
            OpportunityTriggerHelper.EXECUTE_TRIGGER_BEFORE_UPDATE = true;
            OpportunityTriggerHelper.EXECUTE_TRIGGER_AFTER_UPDATE = true;
            
            //Update user first name field value
            userList[0].FirstName = 'Test2';
            update userList[0];
            
            //Retrieving out the details of the bundle record
            opportunities = [SELECT ID, Name, Marketer__c, Marketer_Name__c 
                                   FROM Opportunity 
                                   ORDER BY CloseDate DESC];
        
            //Asserting for the results
            System.assertEquals(3, opportunities.size());
            System.assertEquals('Test2' + ' ' + 'Test User1', opportunities[0].Marketer_Name__c);
            System.assertEquals(null, opportunities[1].Marketer_Name__c);
            System.assertEquals('Test2' + ' ' + 'Test User1', opportunities[2].Marketer_Name__c);           

            //Test will stop here
            Test.stopTest();
        }
    }  
    
    //Modified By - Abhinav Sharma - 06/14/2016 - CR-20150202-8649 - A Code Refactor CR
    /**
     * @description: Test method to check deactivateCreditCardsForInactiveUsers methods based use cases and functionalities.
    **/
    static testMethod void deactivateCreditCardsForInactiveUsers() {
        
        //Bypass Dupeblocker
        Util.IsTest(true);
        
        //Bypassing Triggers so then test data can be created easily
        Util.byPassAllTriggers = true;
        
        //Flag for triggers: this is just a test, don't do crazy things.
        Util.isTesting = true;
        
        //Get profile list
        List<Profile> testProfile = [Select Id, Name from Profile where Name = 'System Administrator'];
        
        //Assert for results
        System.assert(testProfile != null);
        System.assert(testProfile.size()>0);
                
        //Test User Create
        List<User> userList = new List<User>();
        
        userList.add(new User(Username= Math.random()+'@abc.com', LastName='Test User1', FirstName='Test1', 
                              Email='testuser1@test.com', Alias='Test1', EmailEncodingKey='UTF-8', languagelocalekey='en_US', 
                              ProfileId=testProfile[0].Id, timezonesidkey='America/Los_Angeles', localesidkey='en_US', 
                              EmployeeNumber = '12121212', IsActive = true));
        
        //Run as user
        System.RunAs(new User(Id = UserInfo.getUserId())) {
            insert userList;
        }
        
        //insert Credit Card Settings record
        Credit_Card_Settings__c configCCDefaultSetting = TestUtilities.CreateCreditCardSettings();
        insert configCCDefaultSetting;
                    
        //Set helper class variable
        CreditCardHelper.configDefaults = configCCDefaultSetting;
        CreditCardConstants.CONFIG_DEFAULT = configCCDefaultSetting;
        
        //Query result of Record Types
        List<RecordType> recordTypes = [SELECT Id, DeveloperName FROM RecordType WHERE IsActive = true AND 
                                            SobjectType = 'Contact' 
                                            AND DeveloperName =: Constants.CONTACT_RECORD_TYPE_DEVELOPER_NAME_EMPLOYEE Limit 1];
        
        //assert statements
        System.assert(recordTypes != null);
        System.assertEquals(1, recordTypes.size());
                    
        //List to hold Contact and insert contacts
        List<Contact> contacts = new List<Contact>();
        contacts.add(new Contact(FirstName = 'Test', LastName = 'Contact 1', RecordTypeId = recordTypes[0].Id, 
                                 Employee_Id__c = '1241', Legal_First_Name__c = 'Test1',
                                 Legal_Last_Name__c = 'Contact 1', Personal_Address_Line_1__c = 'Abc Street', 
                                 Personal_Address_Line_2__c = 'Test', Personal_Address_PostalCode__c = '32234', 
                                 Personal_Address_City__c = 'Dallas', Personal_Address_State__c = 'CA', 
                                 Employee_User_Record__c = userList[0].Id));
        
        //Insert contact
        insert contacts;
        
        //Payment Account record
        List<Portfolio__c> payments = new List<Portfolio__c>();
        payments.add(new Portfolio__c(Status__c = Constants.ACTIVE, Card_Holder__c = contacts[0].Id, 
                                            Portfolio_Owner_Finance_Code__c = '678981'));
        insert payments;
        
        //Encrypt the card Number
        String encryptNumber1 = CreditCardService.Encrypt('5567356025410226');
        String encryptNumber2 = CreditCardService.Encrypt('5567356025410227');
        
        //Credit Card record   
        List<Credit_Card__c> cards = new List<Credit_Card__c>(); 
        cards.add(new Credit_Card__c(Card_Number__c = encryptNumber1, Status__c = CreditCardConstants.CC_STATUS_ACTIVE, 
                                     Payment_Account__c = payments[0].Id, 
                                     Card_Set_up_Status__c = CreditCardConstants.CC_SETUP_STATUS_SUCCESS, 
                                     Card_Requested_By__c = contacts[0].Id));
        insert cards;
        
        //Start Testing from here
        Test.startTest();
        
        //Initialize method number for deactivateCreditCard
        CreditCardServiceMockClass.methodNumber = 3;
        
        //Response of deactivateCreditCard request
        HttpService.response = mockController.respond(req);
        
        //Enable all the Triggers
        Util.BypassAllTriggers = false;
                   
        //Deactivate the User record. This should trigger the OSR trigger and then Batch and user should be get deactivated
        //Run as user
        System.RunAs(new User(Id = UserInfo.getUserId())) {
            userList[0].IsActive = false;
            update userList;
        }
        
        //Stop testing here
        Test.stopTest();
    }
    
    //Added By - Abhinav Sharma - 06/14/2016 - CR-20150202-8649 - A Code Refactor CR
    /**
     * @description: Test method to check deactivateInactiveCommunityUsers methods based use cases and functionalities.
    **/
    static testmethod void testDeactivateInactiveCommunityUsers() {
        
        //Bypass Dupeblocker
        Util.IsTest(true);
        
        //Bypassing Triggers so then test data can be created easily
        Util.byPassAllTriggers = true;
        
        //Flag for triggers: this is just a test, don't do crazy things.
        Util.isTesting = true;
        
        //User Instances
        User u1, u2, u3, sysAdmin;
        
        //add profile to the community profiles custom setting
        list<Profile> communityProfiles = [SELECT Id, Name FROM Profile WHERE UserType = 'CSPLitePortal' LIMIT 1];
        
        //Asserting for the results
        System.assert(communityProfiles != null);
        System.assert(communityProfiles.size() > 0);
        
        //System Admin profile
        Profile sysAdminProfile = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];
        System.assert(sysAdminProfile != null);
        
        //Community profile
        Community_Profiles__c cp  = new Community_Profiles__c(name='Community Profile 1',
                                                              Profile_Name__c = communityProfiles[0].Name);
        insert cp;
        
        //Asserting for the results
        System.assert(cp != null);
        
        User thisUser = [SELECT Id from User where Id = :UserInfo.getUserId()];
        
        //Run as current context user
        System.runAs (thisUser) {
            
            //create three contacts to associated with active users
            Contact c1 = TestUtilities.CreateNewContact(false);
            Contact c2 = TestUtilities.CreateNewContact(false);
            Contact c3 = TestUtilities.CreateNewContact(false);
            
            //List of contacts
            list<Contact> contacts = new list<Contact> { c1, c2, c3 };
            insert contacts;
            
            //create three active users with the community profile
            u1 = TestUtilities.CreatenewUser(communityProfiles[0], false);
            u2 = TestUtilities.CreatenewUser(communityProfiles[0], false);
            u3 = TestUtilities.CreatenewUser(communityProfiles[0], false);
            sysAdmin = TestUtilities.CreatenewUser(sysAdminProfile, false);

            //Populating fields value on the user records            
            u1.FirstName = 'User1';
            u2.FirstName = 'User2';
            u3.FirstName = 'User3';
            u1.ContactId = c1.Id;
            u2.ContactId = c2.Id;
            u3.ContactId = c3.Id;
            u1.IsActive = true;
            u2.IsActive = true;
            u3.IsActive = true;
            
            //Inserting users
            list<User> users = new list<User> { u1, u2, u3, sysAdmin };
            insert users;
            
            //Create a project
            Project__c project = TestUtilities.CreateProject(true);
            
            //Create a case associated with the contact for u1 (ie: c1)
            Case aCase = new Case(Subject = 'testSubject',
                                  Status = '01-New',
                                  Tier_I_Support_Analyst__c = UserInfo.getUserId(),
                                  Priority = 'Low',
                                  Origin = 'Incoming Call',
                                  ContactId = c1.Id,
                                  Description = 'Test Description',
                                  RecordTypeId = Constants.RECORD_TYPE_ID_CASE_PT_SUPPORT, 
                                  Current_Results__c = 'test current results',
                                  Expected_Results__c = 'test expected results',
                                  Project_Source_MS__c = project.Id,
                                  Steps_to_Reproduce_MS__c = 'test steps to reproduce');
            insert aCase;
            
            //create a Project Role for c2
            Project_Role__c projectRole = new Project_Role__c(Project__c = project.Id, 
                                                              Contact__c = c2.Id, 
                                                              SIAM_Portal_Status__c = 'Active');
            insert projectRole;
        }
        
        //Executing as system admin user
        system.runAs(sysAdmin) {
            
            //Start test from here
            test.startTest();
            
            //Executing batch job
            Database.executeBatch(new Batch_DeactivateInactiveCommunityUsers());
            
            //Stop test here
            test.stopTest();
        }
        
        //get the users and see which ones are inactive
        list<User> users = [SELECT Id, ContactId, IsActive FROM User WHERE Id = :u1.Id OR Id = :u2.Id OR Id = :u3.Id];
        
        //Looping over users records and asserting for the results
        for (User u : users) {
            if (u.Id == u1.Id) system.assertEquals(true, u.IsActive);
            if (u.Id == u2.Id) system.assertEquals(true, u.IsActive);
            if (u.Id == u3.Id) system.assertEquals(false, u.IsActive);
        }
    }  
    
    //Added By - Abhinav Sharma - 06/14/2016 - CR-20150202-8649 - A Code Refactor CR
    /**
     * @description: Test method to check whether apex trigger is catching the exceptions properly or not.
    **/
    static testMethod void test_ExceptionBasedUseCases() {
        
        //Bypass Dupeblocker
        Util.IsTest(true);
        
        //Bypassing Triggers so then test data can be created easily
        Util.byPassAllTriggers = true;
        
        //Flag for triggers: this is just a test, don't do crazy things.
        Util.isTesting = true;
        
        //Get profile list
        List<Profile> testProfile = [Select Id, Name from Profile where Name = 'System Administrator'];
        
        //Assert for results
        System.assert(testProfile != null);
        System.assert(testProfile.size()>0);
                
        //Test User Create
        List<User> userList = new List<User>();
        
        //Adding user record instances into the list
        userList.add(new User(Username= Math.random()+'@abc.com', LastName='Test User1', FirstName='Test1', Email='testuser1@test.com',
                            Alias='Test1', EmailEncodingKey='UTF-8', languagelocalekey='en_US', ProfileId=testProfile[0].Id, 
                            timezonesidkey='America/Los_Angeles', localesidkey='en_US', EmployeeNumber = '12121212', IsActive = true));
        userList.add(new User(Username= Math.random()+'@abc.com', LastName='Test User2', FirstName='Test2', Email='testuser2@test.com',
                            Alias='Test2', EmailEncodingKey='UTF-8', languagelocalekey='en_US', ProfileId=testProfile[0].Id, 
                            timezonesidkey='America/Los_Angeles', localesidkey='en_US', EmployeeNumber = '12121212', IsActive = true));
        userList.add(new User(Username= Math.random()+'@abc.com', LastName='Test User3', FirstName='Test3', Email='testuser3@test.com',
                            Alias='Test3', EmailEncodingKey='UTF-8', languagelocalekey='en_US', ProfileId=testProfile[0].Id, 
                            timezonesidkey='America/Los_Angeles', localesidkey='en_US', EmployeeNumber = '121232412', IsActive = true));
        
        //Test starts from here
        Test.startTest();
        
        //Enable triggers again
        Util.byPassAllTriggers = false;
        
        //Insert users
        insert userList;
        
        //Disabling triggers
        Util.byPassAllTriggers = true;
        
        //Insert Account record
        Account acc = new Account(Name = 'Test Account');
        insert acc;
        System.assert(acc != null);
        
        //Insert Program record
        List<Program__c> programs = new List<Program__c>();
        Program__c program = new Program__c(Name = 'Test Program', New_Business_Marketer__c = 'RI Marketer', 
                                            Program_Acronym__c = 'ZZZ', Create_memberships__c = 'No', Business_line__c = 'PT');
        Program__c program1 = new Program__c(Name = 'Test Program', New_Business_Marketer__c = 'RI Marketer', 
                                            Program_Acronym__c = 'ZZZ', Create_memberships__c = 'No', Business_line__c = 'PT');
        programs.add(program);
        programs.add(program1);
        insert programs;
        System.assert(programs != null);
        
        //Insert scope records
        List<Scope__c> scopes = new List<Scope__c>();
        scopes.add(new Scope__c(Name='test1', Active__c = true));
        insert scopes;
        
        //Insert Scope MtM records
        List<Scope_MtM__c> scopeMtMs = new List<Scope_MtM__c>();
        scopeMtMs.add(new Scope_MtM__c(Name = 'Test' , Program__c = programs[0].Id, Scope__c = scopes[0].Id ));
        insert scopeMtMs;
        
        //Getting Record Type Id Value for Opportunity
        List<RecordType> oppRecordTypes = [Select Id, Name FROM RecordType WHERE SobjectType = 'Opportunity' 
                                              AND IsActive = true
                                              AND DeveloperName = 'Southwind'];
        System.assert(oppRecordTypes != null);
        System.assert(oppRecordTypes.size() > 0);
        
        //Insert Opportunity record
        Opportunity opportunity = new Opportunity(Name = 'Test Opp', RecordTypeId = oppRecordTypes[0].ID, 
                                                  StageName = 'Prospect', Amount = 100, CloseDate = System.today(), 
                                                  AccountId = acc.Id, OwnerId = userList[0].Id,  Program__c = programs[0].Id,
                                                  CT_Assignment__c = userList[0].Id, CT_Pass_Status__c = 'Assigned', 
                                                  CT_Reneg_Attempt__c = 'No', Scope_MtM__c = scopeMtMs[0].Id);
        
        insert opportunity;
        System.assert(opportunity != null);
        
        //Query to retrive "Owner Manager Email" field from Opportunity record
        List<Opportunity> oppList = [SELECT ID, Owner_Manager_Email__c, CT_Assignment_s_Manager__c FROM Opportunity 
                                        WHERE Id=: opportunity.Id];
        
        //Assert for the result
        System.assert(oppList != null);
        System.assert(oppList.size() > 0);
        System.assertEquals(null, oppList[0].Owner_Manager_Email__c);
        System.assertEquals(null, oppList[0].CT_Assignment_s_Manager__c);
        
        //Update first user Manager lookup to second user
        userList[0].ManagerId = userList[1].Id;
        
        //Enabling triggers
        Util.byPassAllTriggers = false;
        
        //Uodating user
        update userList;
        
        //Query to retrive "Owner Manager Email" field from Opportunity record
        oppList = [SELECT ID, Owner_Manager_Email__c FROM Opportunity WHERE Id=: opportunity.Id];
        
        //Assert for the result
        System.assert(oppList != null);
        System.assert(oppList.size()> 0);
        System.assertEquals('testuser2@test.com', oppList[0].Owner_Manager_Email__c);
        
        //Test stops from here
        Test.stopTest();
        
        //Update first user Manager lookup to second user
        userList[0].ManagerId = userList[2].Id;
        update userList;
        
        //Query to retrive "Owner Manager Email" field from Opportunity record
        oppList = [SELECT ID, Owner_Manager_Email__c, CT_Assignment_s_Manager__c FROM Opportunity 
                        WHERE Id=: opportunity.Id];
        
        //Assert for the result
        System.assert(oppList != null);
        System.assert(oppList.size() > 0);
        System.assertEquals('testuser3@test.com', oppList[0].Owner_Manager_Email__c);
        System.assertEquals('testuser3@test.com', oppList[0].CT_Assignment_s_Manager__c);
        
        //Enabling triggers
        Util.byPassAllTriggers = true;
        
        scopeMtMs[0].Program__c = programs[1].Id;
        update scopeMtMs;
        
        //Enabling triggers
        Util.byPassAllTriggers = false;
        
        //Update first user Manager lookup back to first user
        userList[0].ManagerId = userList[1].Id;
        try {update userList;}
        catch(Exception ex) {}
    }
    
    //Added by Colin McGloin - 08/08/2016 - CR-20160414-9762
    static testmethod void validateSteelbrickApproverAdded () {
        
        //Start Test
        Test.startTest();
        
        //Add a new User
        User test1 = new User();
        Profile aProfile = [SELECT Id FROM Profile LIMIT 1];
        
        test1.Alias = 'tUser';
        test1.Email = 'tUser@noreply.com';
        test1.EmailEncodingKey = 'UTF-8';
        test1.FirstName = 'The';
        test1.LastName = 'Batman';
        test1.ProfileId = aProfile.Id;
        test1.Username = 'tUser@noreply'+crypto.getRandomLong()+'.com';
        test1.TimeZoneSidKey = 'America/New_York';
        test1.LanguageLocaleKey = 'en_US';
        test1.LocaleSidKey = 'en_US';
        
        insert test1;
        
        //Stopping Test to test assertions on @future method
        Test.stopTest();
        
        //Query for the created Steelbrick record
        List<sbaa__Approver__c> approvers = [SELECT Id, Name, sbaa__User__c FROM sbaa__Approver__c WHERE Name = 'The Batman'];
        
        //Check that an Approver record was found and the Approver resource matched the user entered
        System.assertEquals(1, approvers.size());
        System.assertEquals(test1.Id, approvers[0].sbaa__User__c);
        
    }    
}