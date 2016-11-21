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
private class Test_CaseController {
/**
    Purpose         :   Test class for CaseController and Case_trigger.(CR-20111219-287)
                
    Create By       :   Simplyforce Technology
    
    Created Date    :   12/28/2011
    
    Revision Log    :   v1.0 - Created
                        v2.0 - 2/7/14 - VH - Modified as part of CR-
                        v3.0 - 03/10/2015 - Ajit Surana - CR-20150127-8599 - testBlackoutDays
                        v4.0 - 06/02/2016 - Abhinav Sharma - CR-20150202-8625
                        v5.0 - 09/06/2016 - Abhinav Sharma - CR-20160114-9520

  	Coverage Log  :  v3.0 - CaseController - 70%
            		 v4.0 - CaseController - 95%
					 v5.0 - CaseController - 95%
**/    
    
    //Modified by - Abhinav Sharma - CR-20150202-8625 - To refactor the existing code
    /** Description : Method to test that field sync logic 
     *           is working perfectly or not FROM Member Support to Case side.
    **/ 
    static testmethod void testSyncMemberSupportToCase() {
        
        //Bypass all triggers
        Util.IsTest(true);
        Util.byPassAlltriggers = true;
        Util.isTesting = true;
        
        //Create test data for the Sync Fields custom setting that syncs Case -> Mem Support fields
        TestUtilities.createSyncFields();
        
        //Create a contact
        Contact contact = TestUtilities.CreateNewContact(true);
        
        //Create a project
        Project__c project = TestUtilities.CreateProject(true);
        
        // get the ABC Dataloader profile id
        Id dataloaderProfileId = System.Label.ABC_Dataloader_Profile_Id;
        
        //ABC Dataloader profile users
        List<User> users = [SELECT ID FROM User WHERE ProfileId =:dataloaderProfileId AND Isactive = true];
        
        //Checking for existance
        if(users != null && users.size() > 0) {
            
            //Running in context of ABC Dataloader user
            System.runAs(users[0]) {
                
                //Start test from here
                Test.startTest();
                
                //Enabling triggers
                Util.BypassAllTriggers = false;
                
                //Create a member support record - Record = 'Crimson Support Request' and Tier = 'Tier II' to make it create a case
                Site_Issue__c memberSupport = TestUtilities.createSiteIssue(project.Id, false);
                memberSupport.RecordTypeId = Constants.RECORD_TYPE_ID_SITE_ISSUE_CCA_SUPPORT_REQUEST;
                memberSupport.Tier__c = Constants.SITE_ISSUE_TIER_II;
                memberSupport.Site_Issue_Short_Description__c = 'subject';
                memberSupport.Crimson_Site_Issue_Description__c = 'description';
                memberSupport.Data_Load_Type__c = 'Current';
                memberSupport.Current_Results__c = 'test';
                memberSupport.Expected_Results__c = 'expected result';
                memberSupport.Interaction_Type__c = 'interactin type';
                memberSupport.Crimson_Site_Issue_Description__c = 'test';
                memberSupport.Site_Issue_Priority__c = 'High';
                memberSupport.Project__c = project.Id;
                memberSupport.Reported_By__c = contact.Id;
                memberSupport.Status__c = '06 - Issue Resolved - Ticket Closed';
                memberSupport.Steps_to_Reproduce__c = '';
                memberSupport.Button_Used__c = false;
                insert memberSupport;
                
                //Asserting for the results
                System.assert(memberSupport != null);
                
                //Get the updated members upport record
                memberSupport = [SELECT Id, Site_Issue_Short_Description__c, Case_Number__c, Status__c,
                                 Tier_I_Support_Analyst__c, Site_Issue_Priority__c, Interaction_Type__c, 
                                 RecordType.DeveloperName,
                                 Reported_By__c, Crimson_Site_Issue_Description__c FROM Site_Issue__c 
                                 WHERE Id = :memberSupport.Id];
               
                //Querying for case details
                Case aCase = [SELECT Id, Subject, CaseNumber, Priority, Origin, ContactId, Description, Member_Support_Ticket__c 
                              FROM Case WHERE Member_Support_Ticket__c = :memberSupport.Id];
               
                //Asserting for the results
                System.assert(aCase != null);
                system.assertEquals(aCase.Subject, memberSupport.Site_Issue_Short_Description__c);
                system.assertEquals(aCase.Priority, memberSupport.Site_Issue_Priority__c);
                system.assertEquals(aCase.Origin, memberSupport.Interaction_Type__c);
                system.assertEquals(aCase.ContactId, memberSupport.Reported_By__c);
                system.assertEquals(aCase.Description, memberSupport.Crimson_Site_Issue_Description__c);
                system.assertEquals(Constants.RECORD_TYPE_SITE_ISSUE_DEVELOPER_NAME_CCA_SUPPORT_REQUEST, memberSupport.RecordType.DeveloperName);
            
              //Stop Testing here
              Test.stopTest();
            }        
        }
    }
    
    //Modified by - Abhinav Sharma - CR-20150202-8625 - To refactor the existing code
    /** Description : Method to test that field sync logic 
     *           is working perfectly or not FROM Case to Member Support side.
    **/ 
    static testmethod void testSyncCaseToMemberSupport() {
        
        //Bypass all triggers
        Util.IsTest(true);
        Util.byPassAlltriggers = true;
        Util.isTesting = true;
        
        //Create test data for the Sync Fields custom setting that syncs Case -> Mem Support fields
        TestUtilities.createSyncFields();
        
        //Create a contact
        Contact contact = TestUtilities.CreateNewContact(true);
        
        //Create a project
        Project__c project = TestUtilities.CreateProject(true);
        
        //Create a sample case record associated with the Member Support record
        Case aCase = new Case(Subject = 'testSubject',
                              Status = '01-New',
                              Tier_I_Support_Analyst__c = UserInfo.getUserId(),
                              Priority = 'Low',
                              Origin = 'Incoming Call',
                              ContactId = contact.Id,
                              Description = 'Test Description',
                              RecordTypeId = Constants.RECORD_TYPE_ID_CASE_PT_SUPPORT, 
                              Current_Results__c = 'test current results',
                              Expected_Results__c = 'test expected results',
                              Project_Source_MS__c = project.Id,
                              Steps_to_Reproduce_MS__c = 'test steps to reproduce');
        
        //Perform the test by inserting the contact
        Test.startTest();
        
        //insert case
        insert aCase;
        
        //Asserting for the results
        System.assert(aCase != null);
        
        //Perform the synchronization
        CaseTriggerHelper.syncCaseToMemberSupport(new list<Case> { aCase }, new map<Id, Case>());
        
        //Stop test here
        Test.stopTest();
        
        //Get the updated members upport record
        Site_Issue__c memberSupport = [SELECT Id, Site_Issue_Short_Description__c, Case_Number__c, Current_Results__c, 
                         Tier_I_Support_Analyst__c, Site_Issue_Priority__c, Interaction_Type__c, RecordType.DeveloperName,
                         Reported_By__c, Crimson_Site_Issue_Description__c, Expected_Results__c, Project__c, Status__c, 
                         Steps_to_Reproduce__c
                         FROM Site_Issue__c 
                         WHERE Project__c != null
                         AND Project__c = :project.Id];
    
        //Asserting for the results
        System.assert(memberSupport != null);
        system.assertEquals(aCase.Subject, memberSupport.Site_Issue_Short_Description__c);
        system.assertEquals(aCase.CaseNumber, memberSupport.Case_Number__c);
        system.assertEquals(CaseTriggerHelper.caseToMemSupportPriority_Map.get(aCase.Priority), memberSupport.Site_Issue_Priority__c);
        system.assertEquals(aCase.Origin, memberSupport.Interaction_Type__c);
        system.assertEquals(aCase.ContactId, memberSupport.Reported_By__c);
        system.assertEquals(aCase.Description, memberSupport.Crimson_Site_Issue_Description__c);
        system.assertEquals(aCase.Current_Results__c, memberSupport.Current_Results__c);
        system.assertEquals(aCase.Expected_Results__c, memberSupport.Expected_Results__c);
        system.assertEquals(aCase.Project_Source_MS__c, memberSupport.Project__c);
        system.assertEquals(CaseTriggerHelper.caseToMemSupportStatus_SupportRT_Map.get(aCase.Status), memberSupport.Status__c);
        system.assertEquals(aCase.Steps_to_Reproduce_MS__c, memberSupport.Steps_to_Reproduce__c);
        system.assertEquals(Constants.RECORD_TYPE_SITE_ISSUE_DEVELOPER_NAME_CCA_SUPPORT_REQUEST, memberSupport.RecordType.DeveloperName);
    
      //Bypassing triggers
        Util.byPassAllTriggers = true;
        
        // instantiate the controller and set the page
        ApexPages.standardController standardController = new ApexPages.standardController(aCase);
        CaseController controller = new CaseController(standardController);
        
        //Setting return URL as null
        controller.retURL = 'null';
        controller.cancel();
        
        //Setting Id as null. So then it will results us as an exception while invoking the methods to commit the cases
        aCase = new Case(Id = null);
        
        try {
            controller.acceptButtonError = false;
          controller.acceptCase();    
        } catch(exception ex) {
            System.assertEquals(true, ex.getMessage().contains(TestUtilities.ID_NOT_SPECIFIED_IN_UPDATE_CALL));
        }   
        
        controller.caseObj = new Case(Id = null);
            
        try {
            controller.transferTier2();
        } catch(exception ex1) {
            System.assertEquals(true, ex1.getMessage().contains(TestUtilities.ID_NOT_SPECIFIED_IN_UPDATE_CALL));
        }
        
        try {
            controller.acceptCase();
        } catch(exception ex2) {
            System.assertEquals(true, ex2.getMessage().contains(TestUtilities.ID_NOT_SPECIFIED_IN_UPDATE_CALL));
        }
    }
    
    //Modified by - Abhinav Sharma - CR-20150202-8625 - To refactor the existing code
    /** Description : Method to test out "redirectToEdit" method based functionality. This methid basically redirects the 
     *           user to the appropriate Case edit page depending on if they are internal or portal user.
    **/ 
    static testmethod void testCaseRedirectToEdit() {
        
        //Temporarily bypass all triggers and dupeblocker
        Util.IsTest(true);
        Util.byPassAlltriggers = true;
        Util.isTesting = true;
        
        //Create test data for the Sync Fields custom setting that syncs Case -> Mem Support fields
        TestUtilities.createSyncFields();
        
        //Create a contact
        Contact contact = TestUtilities.CreateNewContact(true);
        
        //Create a project
        Project__c project = TestUtilities.CreateProject(true);
        
        //Create a sample case record
        Case aCase = new Case();
        
        // set the page reference
        PageReference pageRef = Page.Case_Redirect;
        test.setCurrentPage(pageRef);
        
        //Add RecordType param to page URL 
        ApexPages.currentPage().getParameters().put('RecordType', Constants.RECORD_TYPE_ID_CASE_PT_SUPPORT);
        
        // instantiate the controller and set the page
        ApexPages.standardController standardController = new ApexPages.standardController(aCase);
        CaseController controller = new CaseController(standardController);
        
        //Start Test from here
        Test.startTest();
        
        // verify the redirectTo returns the VF page
        system.assertEquals(true, controller.redirectToEdit().getUrl().toUpperCase().contains('CASE_EDIT_SUPPORTREQUEST'), 
                            'Record type PT Support should cause a redirect to Case_Edit VF Page.');
        
        //Stop Test here
        Test.stopTest();
    }
    
    //Modified by - Abhinav Sharma - CR-20150202-8625 - To refactor the existing code
    //Description : Method to test - Saving a PT Support case -- verify it creates a member support record
    static testmethod void testSaveCase_PTSupport() {
        
        //Temporarily bypass all triggers and dupeblocker
        Util.IsTest(true);
        Util.byPassAlltriggers = true;
        Util.isTesting = true;
        
        //Create test data for the Sync Fields custom setting that syncs Case -> Mem Support fields
        TestUtilities.createSyncFields();
        
        //Create a contact
        Contact contact = TestUtilities.CreateNewContact(true);
        
        //Create a project
        Project__c project = TestUtilities.CreateProject(true);
        
        //Create a sample case record
        Case aCase = new Case();
        
        // set the page reference
        PageReference pageRef = Page.Case_Edit_SupportRequest;
        test.setCurrentPage(pageRef);
        
        //Add RecordType param to page URL 
        ApexPages.currentPage().getParameters().put('RecordType', Constants.RECORD_TYPE_ID_CASE_PT_SUPPORT);
        
        // instantiate the controller and set the page
        ApexPages.standardController standardController = new ApexPages.standardController(aCase);
        CaseController controller = new CaseController(standardController);
        
        //set some default info on the case and member support records
        controller.caseObj.Status = '01-New';
        controller.caseObj.Tier_I_Support_Analyst__c = UserInfo.getUserId();
        controller.caseObj.Priority = 'Medium';
        controller.caseObj.Origin = 'Incoming Call';
        controller.caseObj.ContactId = contact.Id;
        controller.caseObj.Description = 'Test Description';
        controller.caseObj.Steps_to_Reproduce_MS__c = 'test steps to reproduce';
        controller.caseObj.Current_Results__c = 'test current results';
        controller.caseObj.Expected_Results__c = 'test expected results';
        controller.caseObj.Subject = 'test subject';
        controller.caseObj.PHI__c = true; //CR-20160113-9507
        controller.caseObj.Button_Used__c = true;
        
        //Populating member support instance
        controller.memberSupport.Support_Category__c = 'Other';
        controller.memberSupport.Browser__c = 'IE';
        controller.memberSupport.Browser_Version__c = '11';
        controller.memberSupport.Data_Load_Type__c = 'test';
        controller.memberSupport.Data_Load_Period_End__c = system.today().addDays(10);
        controller.memberSupport.Button_Used__c = true;
        
        //Setting internal comments
        controller.internalComments = 'Test';
        
        //Start test from here
        Test.startTest();
        
        //Enabling trigger
        Util.BypassAllTriggers = false;  
        
        //Invoking VF page based "Save" method for commiting the changes
         controller.save();
        
        //Stop Test here
        Test.stopTest();
        
        //Get the case and member support record
        aCase = [SELECT Id, Status, Priority, Description, Steps_to_Reproduce_MS__c, Current_Results__c, 
                 Expected_Results__c, Member_Support_Ticket__c, RecordTypeId, PHI__c
                 FROM Case WHERE Id = :controller.caseObj.Id];
        
        //Member Support
        Site_Issue__c memberSupport = [SELECT Id, Browser__c, Browser_Version__c, Created_from_Case__c, Current_Results__c, Current_User_Assigned__c,
                                       Expected_Results__c, Member_Information_Requested__c, Status_Detail__c, Case_Number__c, 
                                       Tier_I_Support_Analyst__c, Steps_to_Reproduce__c, Status__c, PHI__c
                                       FROM Site_Issue__c WHERE Id = :controller.memberSupport.Id];
        
        //Asserting for the results
        System.assert(memberSupport != null);
        System.assert(aCase != null);
        system.assertEquals(true, memberSupport.Created_from_Case__c);
        system.assertEquals(memberSupport.Id, aCase.Member_Support_Ticket__c);
        system.assertEquals(memberSupport.Steps_to_Reproduce__c, aCase.Steps_to_Reproduce_MS__c);
        system.assertEquals(memberSupport.Expected_Results__c, aCase.Expected_Results__c);
        system.assertEquals(memberSupport.Current_Results__c, aCase.Current_Results__c);
        system.assertEquals(Constants.RECORD_TYPE_ID_CASE_PT_SUPPORT, aCase.RecordTypeId);
        system.assertEquals('Medium', aCase.Priority,
                            'When the Case Priority is set to Medium and the Case is saved, '
                            + 'it should not return a different value after saving.');
        system.assertEquals(memberSupport.PHI__c, aCase.PHI__c, 'The PHI field should have been synchronized from Case to Member Support record.'); //CR-20160113-9507
    }
    
    //Modified by - Abhinav Sharma - CR-20150202-8625 - To refactor the existing code
    //Description : Method to test various use cases associated with saving a case of "PT Support" record type from community user.
    static testmethod void testSaveCase_CommunityUser_PTSupport() {
        
        //Temporarily bypass all triggers and dupeblocker
        Util.IsTest(true);
        Util.byPassAlltriggers = true;
        Util.isTesting = true;
        
        //Create test data for the Sync Fields custom setting that syncs Case -> Mem Support fields
        TestUtilities.createSyncFields();
        
        //Create a contact
        Contact contact = TestUtilities.CreateNewContact(true);
        
        //create a community user
        Profile portalProfile = [SELECT Id FROM Profile WHERE UserLicense.Name like '%High Volume Customer Portal' LIMIT 1];
        User communityUser = TestUtilities.CreateNewUser(portalProfile, false);
        communityUser.ContactId = contact.Id;
        insert communityUser;
        
        //Create a project
        Project__c project = TestUtilities.CreateProject(true);
        
        //runAs community user
        system.runAs(communityUser) {
            
            //Create a sample case record
            Case aCase = new Case();
            
            // set the page reference
            PageReference pageRef = Page.Case_Edit_PTCommunity;
            test.setCurrentPage(pageRef);
            
            //Add RecordType param to page URL 
            ApexPages.currentPage().getParameters().put('RecordType', Constants.RECORD_TYPE_ID_CASE_PT_SUPPORT);
            
            // instantiate the controller and set the page
            ApexPages.standardController standardController = new ApexPages.standardController(aCase);
            CaseController controller = new CaseController(standardController);
            
            //set some default info on the case and member support records
            controller.caseObj.Subject = 'test subject';
            controller.caseObj.Description = 'Test Description';
            controller.caseObj.Steps_to_Reproduce_MS__c = 'test steps to reproduce';
            controller.caseObj.Current_Results__c = 'test current results';
            controller.caseObj.Expected_Results__c = 'test expected results';
            controller.caseObj.ContactId = contact.Id;
            
            //Popualting memeber support instance
            controller.memberSupport.Support_Category__c = 'Other';
            controller.memberSupport.Browser__c = 'IE';
            controller.memberSupport.Browser_Version__c = '11';
            controller.memberSupport.Data_Load_Type__c = 'test';
            controller.memberSupport.Data_Load_Period_End__c = system.today().addDays(10);
            
            //verify the defaults for the community user are setup properly
            system.assertEquals(controller.caseObj.Origin, 'Community',
                                'Origin should default to Community when creating a case through community.');
            system.assertEquals(controller.caseObj.Priority, 'Low',
                                'Priority should default to Low when creating a case through community.');
            system.assertEquals(controller.caseObj.Status, Constants.CASE_STATUS_01_NEW,
                                'Case Status should be new when creating a case through community.');
            
            //Start Test from here
            Test.startTest();
            
            //Enabling triggers
            Util.BypassAllTriggers = false;
            
            //Clicking on the "Save" button
             PageReference pg = controller.save();
            
            //Stop Test here
            Test.stopTest();
            
            //Asserting for the results
            system.AssertNotEquals(null, pg);
            system.assertNotEquals(null, controller.caseObj.Id);
            
            system.assertEquals(controller.memberSupport.Visible_in_Portal__c, true,
                                'MemberSupport Visible in Portal should be new when creating a case through community.');
            
            //Enable Edit
            controller.isTierII = false;
            controller.isUnAssignedQueueAsOwner = true;
            controller.contactId = contact.Id;
            Boolean b = false;
            b = controller.showEdit;
            System.assert(b);
        }
    }
    
  //Modified By - Abhinav Sharma - CR-20160114-9520 - 09/06/2016    
    //Modified by - Abhinav Sharma - CR-20150202-8625 - To refactor the existing code
    //Description : Method to test various use cases associated with saving/updating a case of "PT Support" record type.
    static testmethod void testUpdateCase_PTSupport() {
        
        //Temporarily bypass all triggers and dupeblocker
        Util.IsTest(true);
        Util.byPassAlltriggers = true;
        Util.isTesting = true;
        
        //Create test data for the Sync Fields custom setting that syncs Case -> Mem Support fields
        TestUtilities.createSyncFields();
        
        //Create a contact
        Contact contact = TestUtilities.CreateNewContact(true);
        
        //Create a project
        Project__c project = TestUtilities.CreateProject(true);
        
        //Create a sample case record
        Case aCase = new Case();
        
        // set the page reference
        PageReference pageRef = Page.Case_Edit_SupportRequest;
        test.setCurrentPage(pageRef);
        
        //Add RecordType param to page URL 
        ApexPages.currentPage().getParameters().put('RecordType', Constants.RECORD_TYPE_ID_CASE_PT_SUPPORT);
        
        // instantiate the controller and set the page
        ApexPages.standardController standardController = new ApexPages.standardController(aCase);
        CaseController controller = new CaseController(standardController);
        
        //set some default info on the case and member support records
        controller.caseObj.Status = '01-New';
        controller.caseObj.Tier_I_Support_Analyst__c = UserInfo.getUserId();
        controller.caseObj.Priority = 'Low';
        controller.caseObj.Origin = 'Incoming Call';
        controller.caseObj.ContactId = contact.Id;
        controller.caseObj.Description = 'Test Description';
        controller.caseObj.Steps_to_Reproduce_MS__c = 'test steps to reproduce';
        controller.caseObj.Current_Results__c = 'test current results';
        controller.caseObj.Expected_Results__c = 'test expected results';
        controller.caseObj.Subject = 'test subject';
        controller.caseObj.Button_Used__c = true;
        
        //Populating member support instance
        controller.memberSupport.Support_Category__c = 'Other';
        controller.memberSupport.Browser__c = 'IE';
        controller.memberSupport.Browser_Version__c = '11';
        controller.memberSupport.Data_Load_Type__c = 'test';
        controller.memberSupport.Data_Load_Period_End__c = system.today().addDays(10);
        controller.memberSupport.Button_Used__c = true;
        controller.memberSupport.Browser_Used__c = '[';
        
        //Start test from here
        Test.startTest();
        
        //Enabling triggers
        Util.BypassAllTriggers = false;
        
        //save the case
        controller.save();
        
        //Get the case and member support record
        aCase = [SELECT Id, Status, Priority, Description, Steps_to_Reproduce_MS__c, Current_Results__c, 
                 Expected_Results__c, Member_Support_Ticket__c, RecordTypeId
                 FROM Case WHERE Id = :controller.caseObj.Id];
        
        //Member Support
        Site_Issue__c memberSupport = [SELECT Id, Browser__c, Browser_Version__c, Created_from_Case__c, Current_Results__c, Current_User_Assigned__c,
                                       Expected_Results__c, Member_Information_Requested__c, Status_Detail__c, Case_Number__c, 
                                       Tier_I_Support_Analyst__c, Steps_to_Reproduce__c, Status__c
                                       FROM Site_Issue__c WHERE Id = :controller.memberSupport.Id];
        
        //Asserting for the results
        system.assert(aCase != null);
        system.assert(memberSupport != null);
        system.assertEquals(true, memberSupport.Created_from_Case__c);
        system.assertEquals(memberSupport.Id, aCase.Member_Support_Ticket__c);
        system.assertEquals(memberSupport.Steps_to_Reproduce__c, aCase.Steps_to_Reproduce_MS__c);
        system.assertEquals(memberSupport.Expected_Results__c, aCase.Expected_Results__c);
        system.assertEquals(memberSupport.Current_Results__c, aCase.Current_Results__c);
        system.assertEquals(Constants.RECORD_TYPE_ID_CASE_PT_SUPPORT, aCase.RecordTypeId);
        if(CaseController.retrieveLoggedInUserDetails(UserInfo.getUserId()) != null) {
            User u = CaseController.retrieveLoggedInUserDetails(UserInfo.getUserId());
            system.assertEquals(u.FirstName + ' ' + u.LastName, memberSupport.Tier_I_Support_Analyst__c);
        }
        
        //Update Case field values
        controller.caseObj.Subject = null;
        controller.caseObj.ContactId = null;
        controller.caseObj.Steps_to_Reproduce_MS__c = null;
        controller.caseObj.Current_Results__c = null;
        controller.caseObj.Expected_Results__c = null;
        
        //Update Member Support field value
        controller.memberSupport.Support_Category__c = null;
        
        //Set boolean variable
        Boolean hasErr = controller.hasErrors;
        
        //Assert for result
        System.assertEquals(true, hasErr);
        
        //Update Member Support field value
        controller.memberSupport.Support_Category__c = 'Configuration/Site Error';
        
        //Set boolean variable
        hasErr = controller.hasErrors;
        
        //Assert for result
        System.assertEquals(true, hasErr);
    }
    
    //Modified by - Abhinav Sharma - CR-20150202-8625 - To refactor the existing code
    /** Description : Method to test the various use cases associated with saving/updating a case of 
     *           "PT Support" record type which will results as an error.
    **/           
    static testmethod void testSaveCase_PTSupport_Error() {
        
        //Temporarily bypass all triggers and dupeblocker
        Util.IsTest(true);
        Util.byPassAlltriggers = true;
        Util.isTesting = true;
        
        //Create test data for the Sync Fields custom setting that syncs Case -> Mem Support fields
        TestUtilities.createSyncFields();
        
        //Create a contact
        Contact contact = TestUtilities.CreateNewContact(true);
        
        //Create a project
        Project__c project = TestUtilities.CreateProject(true);
        
        //Create a sample case record
        Case aCase = new Case();
        
        //Set the page reference
        PageReference pageRef = Page.Case_Edit_SupportRequest;
        test.setCurrentPage(pageRef);
        
        //Add RecordType param to page URL 
        ApexPages.currentPage().getParameters().put('RecordType', Constants.RECORD_TYPE_ID_CASE_PT_SUPPORT);
        
        // instantiate the controller and set the page
        ApexPages.standardController standardController = new ApexPages.standardController(aCase);
        CaseController controller = new CaseController(standardController);
        
        //set some default info on the case and member support records
        controller.caseObj.Status = '01-New';
        controller.caseObj.Tier_I_Support_Analyst__c = UserInfo.getUserId();
        controller.caseObj.Priority = 'Low';
        controller.caseObj.Origin = 'Incoming Call';
        controller.caseObj.ContactId = contact.Id;
        controller.caseObj.Description = 'Test Description';
        controller.caseObj.Steps_to_Reproduce_MS__c = 'test steps to reproduce';
        controller.caseObj.Subject = 'test subject';
        
        //Set the support category to the value that makes the current/expected results fields required
        controller.memberSupport.Support_Category__c = 'Service Request / Task';
        controller.caseObj.Current_Results__c = null;
        controller.caseObj.Expected_Results__c = null;
        
        //save the case and verify an error was returned
        //Start test from hete
        test.startTest();
        
        //Enabling triggers
        Util.BypassAllTriggers = false;
        
        //Click on save button and asserting for the results
        PageReference pg = controller.save();
        System.assertEquals(null, pg);
        
        //Stop test here
        Test.stopTest();
    }
    
    //Modified by - Abhinav Sharma - CR-20150202-8625 - To refactor the existing code
    /** Description : Method to test the various use cases associated with "Accept Case" button
     *           which will results as an error.
    **/           
    static testmethod void testAcceptCase_Error() {
        
        //Temporarily bypass all triggers and dupeblocker
        Util.IsTest(true);
        Util.byPassAlltriggers = true;
        Util.isTesting = true;
        
        //Create test data for the Sync Fields custom setting that syncs Case -> Mem Support fields
        TestUtilities.createSyncFields();
        
        //Create a contact
        Contact contact = TestUtilities.CreateNewContact(true);
        
        //Create a project
        Project__c project = TestUtilities.CreateProject(true);
        
        //Enabling triggers
        Util.BypassAllTriggers = false;
        
        //Create a Member Support
        Site_Issue__c memberSupport = TestUtilities.createSiteIssue (project.Id, false);
        memberSupport.Status__c = '06 - Issue Resolved - Ticket Closed';
        insert memberSupport;
        
        //Create a sample case record
        Case bCase = new Case();
        
        // set the page reference
        PageReference pageRef = Page.Case_Edit_SupportRequest;
        test.setCurrentPage(pageRef);
        
        //Add RecordType param to page URL 
        ApexPages.currentPage().getParameters().put('RecordType', Constants.RECORD_TYPE_ID_CASE_PT_SUPPORT);
        
        // instantiate the controller and set the page
        ApexPages.standardController standardController = new ApexPages.standardController(bCase);
        CaseController controller = new CaseController(standardController);
        
        //set some default info on the case and member support records
        controller.caseObj.Status = '90-Closed';
        controller.caseObj.Tier_I_Support_Analyst__c = UserInfo.getUserId();
        controller.memberSupport.Tier__c = 'Tier II';
        controller.caseObj.Priority = 'Low';
        controller.caseObj.Origin = 'Incoming Call';
        controller.caseObj.ContactId = contact.Id;
        controller.caseObj.Description = 'Test Description';
        controller.caseObj.Steps_to_Reproduce_MS__c = 'test steps to reproduce';
        
        //Start test from here
        Test.startTest();
        
        //Accept the case and verify an error was returned
        PageReference pg = controller.acceptCase();
        system.assertEquals(null, pg);
        
        //Stop Test here
        Test.stopTest();
        
        //Assert that we received 1 error message for trying to Accept Case with Case.Status = 90-Closed
        system.assert(ApexPages.getMessages() != null);
        system.assertEquals(1, ApexPages.getMessages().size());
        
    }
    
    //Modified by - Abhinav Sharma - CR-20150202-8625 - To refactor the existing code
    /** Description : Method to test the various use cases associated with "Transfer Tier II" button.
     *
    **/ 
    static testmethod void testTransferTier2() {
        
        //Temporarily bypass all triggers and dupeblocker
        Util.IsTest(true);
        Util.byPassAlltriggers = true;
        Util.isTesting = true;
        
        //create project manager user
        User projectManagerUser = TestUtilities.CreateNewUser(true);
        
        //Create test data for the Sync Fields custom setting that syncs Case -> Mem Support fields
        TestUtilities.createSyncFields();
        
        //Create a contact
        Contact contact = TestUtilities.CreateNewContact(true);
        
        //Create a project
        Project__c project = TestUtilities.CreateProject(false);
        project.Project_Manager__c = projectManagerUser.Id;
        insert project;
        
        //Enabling triggers
        Util.BypassAllTriggers = false;
        
        //Create a Tier I, CCA Support, Member Support record
        Site_Issue__c memberSupport = TestUtilities.createSiteIssue (project.Id, false);
        memberSupport.RecordTypeId = Constants.RECORD_TYPE_ID_SITE_ISSUE_CCA_SUPPORT_REQUEST;
        memberSupport.Visible_In_Portal__c = true;
        memberSupport.Reported_By__c = contact.Id;
        memberSupport.Tier__c = Constants.SITE_ISSUE_TIER_I;
        memberSupport.Interaction_Type__c = 'Support Analyst Request';
        memberSupport.Status__c = '06 - Issue Resolved - Ticket Closed';
        insert memberSupport;
        
        //Asserting for the results
        System.assert(memberSupport != null);
        
        //get the related case that should have been generated
        Case aCase = [SELECT Id, Deadline__c, Member_Support_Ticket__c, Project_Source_MS__c, Tier_MS__c  
                        FROM Case WHERE Member_Support_Ticket__c = :memberSupport.Id];
        
        //Asserting for the results
        System.assert(aCase != null);
        
        //Set the page reference
        PageReference pageRef = Page.Case_TransferTier;
        test.setCurrentPage(pageRef);
        
        // instantiate the controller and set the page
        ApexPages.standardController standardController = new ApexPages.standardController(aCase);
        CaseController controller = new CaseController(standardController);
        
        //Start test from here
        Test.startTest();
        
        //Click on "Transfer Tier II" 
        PageReference pg = controller.transferTier2();
        system.assertNotEquals(null, pg);
        
        //Stop Test here
        Test.stopTest();
        
        //Asserting for the results
        aCase = [SELECT id, Tier_MS__c, Member_Support_Ticket__c FROM Case WHERE Id = :aCase.Id];
        system.assertEquals(Constants.SITE_ISSUE_TIER_II, aCase.Tier_MS__c);
        
        memberSupport = [SELECT id, Tier__c, OwnerId FROM Site_Issue__c WHERE Id = :memberSupport.Id];
        system.assertEquals(Constants.SITE_ISSUE_TIER_II, memberSupport.Tier__c);
        
    }
    
    //Modified by - Abhinav Sharma - CR-20150202-8625 - To refactor the existing code
    /** Description : Method to test the various use cases associated with "Transfer Tier II" button
     *           Which will results as an error.
    **/
    static testmethod void testTransferTier2_Error() {
        
        //Temporarily bypass all triggers and dupeblocker
        Util.IsTest(true);
        Util.byPassAlltriggers = true;
        Util.isTesting = true;
        
        //create project manager user
        User projectManagerUser = TestUtilities.CreateNewUser(true);
        
        //Create test data for the Sync Fields custom setting that syncs Case -> Mem Support fields
        TestUtilities.createSyncFields();
        
        //Create a contact
        Contact contact = TestUtilities.CreateNewContact(true);
        
        //Create a project
        Project__c project = TestUtilities.CreateProject(false);
        project.Project_Manager__c = projectManagerUser.Id;
        insert project;
        
        //Enabling triggers
        util.BypassAllTriggers = false;
        
        //Create a Tier II, CCA Support, Member Support record.  Since it's already in Tier II status, 
        //it should throw an error
        Site_Issue__c memberSupport = TestUtilities.createSiteIssue (project.Id, false);
        memberSupport.RecordTypeId = Constants.RECORD_TYPE_ID_SITE_ISSUE_CCA_SUPPORT_REQUEST;
        memberSupport.Visible_In_Portal__c = true;
        memberSupport.Reported_By__c = contact.Id;
        memberSupport.Tier__c = Constants.SITE_ISSUE_TIER_II;
        memberSupport.Reported_By__c = contact.ID;
        memberSupport.Interaction_Type__c = 'Support Analyst Request';
        memberSupport.Status__c = '06 - Issue Resolved - Ticket Closed';
        memberSupport.Button_Used__c = true;
        insert memberSupport;
        
        //get the related case that should have been generated
        Case aCase = [SELECT Id, Deadline__c, Member_Support_Ticket__c, Project_Source_MS__c  
                        FROM Case WHERE Member_Support_Ticket__c = :memberSupport.Id];
        
        // set the page reference
        PageReference pageRef = Page.Case_TransferTier;
        test.setCurrentPage(pageRef);
        
        // instantiate the controller and set the page
        ApexPages.standardController standardController = new ApexPages.standardController(aCase);
        CaseController controller = new CaseController(standardController);
        
        //Start test from here
        Test.startTest();
        
        //Transfer to tier II
        PageReference pg = controller.transferTier2();
        system.assertEquals(null, pg);
        
        //Stop Test here
        Test.stopTest();
        
        //Assert that we received 1 error message for trying to Accept Case with Case.Status = 90-Closed
        system.assert(ApexPages.getMessages() != null);
        system.assertEquals(1, ApexPages.getMessages().size());
    }
    
    //Modified by - Abhinav Sharma - CR-20150202-8625 - To refactor the existing code
    /** Description : Method to test cancel button related funcationality.
    **/
    static testMethod void testCancel() {
        
        //Temporarily bypass all triggers and dupeblocker
        Util.IsTest(true);
        Util.byPassAlltriggers = true;
        Util.isTesting = true;
        
        //Create a sample case record
        Case aCase = new Case();
        
        // set the page reference
        PageReference pageRef = Page.Case_Edit_SupportRequest;
        test.setCurrentPage(pageRef);
        
        //create a test return URL
        string testReturnURL = 'http://www.google.com/';
        
        //Start test from here
        Test.startTest();
        
        //Add RecordType param to page URL 
        ApexPages.currentPage().getParameters().put('RecordType', Constants.RECORD_TYPE_ID_CASE_PT_SUPPORT);
        ApexPages.currentPage().getParameters().put('retURL', testReturnURL);
        
        // instantiate the controller and set the page
        ApexPages.standardController standardController = new ApexPages.standardController(aCase);
        CaseController controller = new CaseController(standardController);
        system.assertEquals(testReturnURL, controller.cancel().getURL());
        
        //set the retURL to null and verify it sends the user back to the standard case view page
        controller.retURL = 'null';
        controller.cancel();
        
        //Stop Test here
        Test.stopTest();
    }
    
    //Modified by - Abhinav Sharma - CR-20150202-8625 - To refactor the existing code
    /** Description : Method to test redirecting the user to a standard case edit page based funcationality.
    **/
    static testMethod void redirectToEdit_Standard() {
        
        //Temporarily bypass all triggers and dupeblocker
        Util.IsTest(true);
        Util.byPassAlltriggers = true;
        Util.isTesting = true;
        
        //Case expert center record type
        Id expertCentersRTTypeId = Util.RecordTypeId(Constants.CASE_OBJECT, TestUtilities.EXPERT_CENTER_CASE_RECORD_TYPE);
        System.assert(expertCentersRTTypeId != null);
        
        //Create a sample case record
        Case aCase = new Case();
        
        // set the page reference
        PageReference pageRef = Page.Case_Edit_SupportRequest;
        test.setCurrentPage(pageRef);
        
        //create a test return URL
        string testReturnURL = 'http://www.google.com/';
        
        //Add RecordType param to page URL 
        ApexPages.currentPage().getParameters().put('RecordType', expertCentersRTTypeId);
        
        //Start test from here
        Test.startTest();
        
        // instantiate the controller and set the page
        ApexPages.standardController standardController = new ApexPages.standardController(aCase);
        CaseController controller = new CaseController(standardController);
        
        //verify the redirectToEdit pageReference contains the standard Case object prefix "500"
        system.assertEquals(true, controller.redirectToEdit().getURL().contains('500'));
        
        //Stop test here
        Test.stopTest();
    }
    
    //Modified by - Abhinav Sharma - CR-20150202-8625 - To refactor the existing code
    /** Description : Method to test redirecting the user to a standard case view page based funcationality.
    **/
    static testMethod void testRedirectToView_Standard() {
        
        //Temporarily bypass all triggers and dupeblocker
        Util.IsTest(true);
        Util.byPassAlltriggers = true;
        Util.isTesting = true;
        
        //Create test data for the Sync Fields custom setting that syncs Case -> Mem Support fields
        TestUtilities.createSyncFields();
        
        //Create a contact
        Contact contact = TestUtilities.CreateNewContact(true);
        
        //Create a project
        Project__c project = TestUtilities.CreateProject(true);
        
        //Create a sample case record associated with the Member Support record
        Case aCase = new Case(Subject = 'testSubject',
                              Status = '01-New',
                              Tier_I_Support_Analyst__c = UserInfo.getUserId(),
                              Priority = 'Low',
                              Origin = 'Incoming Call',
                              ContactId = contact.Id,
                              Description = 'Test Description',
                              RecordTypeId = Constants.RECORD_TYPE_ID_CASE_PT_SUPPORT, 
                              Current_Results__c = 'test current results',
                              Expected_Results__c = 'test expected results',
                              Project_Source_MS__c = project.Id,
                              Steps_to_Reproduce_MS__c = 'test steps to reproduce');
        
        insert aCase;
        
        // set the page reference
        PageReference pageRef = Page.Case_Edit_SupportRequest;
        test.setCurrentPage(pageRef);
        
        //create a test return URL
        string testReturnURL = 'http://www.google.com/';
        
        //Add RecordType param to page URL 
        ApexPages.currentPage().getParameters().put('RecordType', Constants.RECORD_TYPE_ID_CASE_PT_SUPPORT);
        
        //Start test from here
        Test.startTest();
        
        // instantiate the controller and set the page
        ApexPages.standardController standardController = new ApexPages.standardController(aCase);
        CaseController controller = new CaseController(standardController);
        
        //verify the redirectToEdit pageReference contains the nooverride parameter
        system.assertEquals(true, controller.redirectToView().getURL().contains('nooverride'));
        
        //Stop Test here
        Test.stopTest();
    }
    
    //Modified by - Abhinav Sharma - CR-20150202-8625 - To refactor the existing code
    /** Description : Method to test redirecting the user to a case view page based funcationality for community user.
    **/
    static testMethod void testRedirectToView_CommunityUser() {
        
        //Temporarily bypass all triggers and dupeblocker
        Util.IsTest(true);
        Util.byPassAlltriggers = true;
        Util.isTesting = true;
        
        //Create test data for the Sync Fields custom setting that syncs Case -> Mem Support fields
        TestUtilities.createSyncFields();
        
        //Create a contact
        Contact contact = TestUtilities.CreateNewContact(true);
        
        //create a community user
        Profile portalProfile = [SELECT Id FROM Profile WHERE UserLicense.Name like '%High Volume Customer Portal' LIMIT 1];
        User communityUser = TestUtilities.CreateNewUser(portalProfile, false);
        communityUser.ContactId = contact.Id;
        insert communityUser;
        
        //Create 2 projects and set the project manager
        Project__c project_Active = TestUtilities.CreateProject(false);
        project_Active.Project_Manager__c = communityUser.Id;
        Project__c project_Inactive = TestUtilities.CreateProject(false);
        project_Inactive.Project_Manager__c = communityUser.Id;
        list<Project__c> projects = new list<Project__c> { project_Active, project_Inactive };
        insert projects;
        
        //Create 2 project roles
        Project_Role__c pRole_Active = new Project_Role__c(Name='Test',
                                                   Project_Type__c = 'CCC',
                                                   Role__c = 'Implementation Leader',
                                                   Contact__c = contact.Id,
                                                   Project__c = project_Active.Id,
                                                   SIAM_Portal_Status__c = Constants.SIAM_PORTAL_STATUS_ACTIVE);
        Project_Role__c pRole_Inactive = new Project_Role__c(Name='Test',
                                                   Project_Type__c = 'CCC',
                                                   Role__c = 'Implementation Leader',
                                                   Contact__c = contact.Id,
                                                   Project__c = project_Inactive.Id,
                                                   SIAM_Portal_Status__c = Constants.SIAM_PORTAL_STATUS_INACTIVE);
        list<Project_Role__c> pRoles = new list<Project_Role__c> { pRole_Active, pRole_Inactive };
        insert pRoles;
        
        //Enabling triggers
        Util.BypassAllTriggers = false;
        
        //Create a sample case record associated with the Member Support record
        Case aCase = new Case(Subject = 'testSubject',
                              Status = '01-New',
                              Tier_I_Support_Analyst__c = UserInfo.getUserId(),
                              Priority = 'Low',
                              Origin = 'Incoming Call',
                              ContactId = contact.Id,
                              Description = 'Test Description',
                              RecordTypeId = Constants.RECORD_TYPE_ID_CASE_PT_SUPPORT, 
                              Current_Results__c = 'test current results',
                              Expected_Results__c = 'test expected results',
                              Project_Source_MS__c = project_Active.Id,
                              Steps_to_Reproduce_MS__c = 'test steps to reproduce');
        insert aCase;
        
        //Asserting for the results
        System.assert(aCase != null);
        
        //get the case
        aCase = [SELECT Id, Member_Support_Ticket__c FROM Case WHERE Id = :aCase.Id];
        
        //get the member support record
        Site_Issue__c memberSupport = [SELECT Id, Tier__c FROM Site_Issue__c WHERE Id = :aCase.Member_Support_Ticket__c];
        System.assert(memberSupport != null);
        
        //Updating member support
        memberSupport.Tier__c = Constants.SITE_ISSUE_TIER_I;
        memberSupport.Button_Used__c = true;
        update memberSupport;
        
        //runAs community user
        system.runAs(communityUser) {
            
            // set the page reference
            PageReference pageRef = Page.Case_Edit_PTCommunity;
            test.setCurrentPage(pageRef);
            
            //Add RecordType param to page URL 
            ApexPages.currentPage().getParameters().put('RecordType', Constants.RECORD_TYPE_ID_CASE_PT_SUPPORT);
            
            // instantiate the controller and set the page
            ApexPages.standardController standardController = new ApexPages.standardController(aCase);
            CaseController controller = new CaseController(standardController);
            
            //set the case contact to the current user's contact
            controller.caseObj.contactId = controller.ContactId;
            
            //Start test from here
            Test.startTest();
            
            //Asserting for the results
            system.assertEquals(true, controller.redirectToView().getURL().toLowerCase().contains('case_view_supportrequest_community'),
                               'Community Users should be redirected to the case_view_supportrequest_community VF page for PT Support and Data Load '
                             + 'record types.  Actual:' + controller.redirectToView().getURL().toLowerCase());
            
            //set contactId to null, then get the contactId
            controller.ContactId = null;
            system.assertEquals(contact.Id, controller.ContactId,
                                'ContactId should be the same as the currently logged in user.');
            
            controller.caseObj.RecordTypeId = Constants.RECORD_TYPE_ID_CASE_PT_SUPPORT;
            
            system.assertEquals(controller.caseObj.contactId, controller.ContactId);
            system.assertEquals(false, controller.isTierII);
            system.assertEquals(controller.caseObj.RecordTypeId, Constants.RECORD_TYPE_ID_CASE_PT_SUPPORT);
            
            system.assertEquals(false, controller.showEdit,
                                'showEdit should be false when case owner is not an unassigned queue.');
            
            system.assertNotEquals(0, controller.closedCaseStatusList.size(),
                                'ClosedCaseStatusList should have at least one value.');
                                
            system.assertEquals(5, controller.communitySupportCategoryOptions.size(),
                                'The number of community support category options should be 5.');
            
            system.assertEquals(false, controller.isTierII,
                                'isTierII should be false when the Tier is not equal to Tier II.');
            
            //refresh project options and verify they are not null
            controller.refreshProjOptions();
            system.assertEquals(1, controller.projectOptions.size(),
                                'ProjectOptions should have one record associated with it, since this Contact ' +
                                'has one project role related to the project with SIAM Portal Status = Active.');
            
            //Update Case Record Type
            aCase.RecordTypeId = Constants.RECORD_TYPE_ID_CASE_PT_DATA_LOAD;
            update aCase;
            
            //Invoking the redirect methods in non-portal user context for PT Data Load cases
            controller.isPortalUser = false;
            controller.redirectToEdit();
            controller.redirectToView();
            
            //Invoking the redirect methods in portal user context for PT Data Load cases
            controller.isPortalUser = true;
            controller.redirectToEdit();
            controller.redirectToView();
            
            //Setting current user as "Technical Project Manager"
          controller.projectManagerId = null;
          
            //Update case id as null value
            controller.caseObj = new Case(Id = null);
            
            try {
                controller.transferTier2();
            } catch(exception ex) {
                System.assertEquals(true, ex.getMessage().contains(TestUtilities.ID_NOT_SPECIFIED_IN_UPDATE_CALL));
            }
            
            try {
                controller.acceptCase();
            } catch(exception ex1) {
              System.assertEquals(true, ex1.getMessage().contains(TestUtilities.ID_NOT_SPECIFIED_IN_UPDATE_CALL));    
            }
            
            try {
                controller.save();
            } catch(exception ex2) {
                System.assertEquals(true, ex2.getMessage().contains(TestUtilities.ID_NOT_SPECIFIED_IN_UPDATE_CALL));
            }
            
            //Stop Test here
            Test.stopTest();
        }
    }
    
    //Added by - Abhinav Sharma - CR-20150202-8625 - To refactor the existing code
    /** Description : Method to test whether various useful getter and setter are working as expected or not
    **/
    static testMethod void testHelperGetterSetterFuncationality() {
        
        //Temporarily bypass all triggers and dupeblocker
        Util.IsTest(true);
        Util.byPassAlltriggers = true;
        Util.isTesting = true;
        
        //Create test data for the Sync Fields custom setting that syncs Case -> Mem Support fields
        TestUtilities.createSyncFields();
        
        //Create a contact
        Contact contact = TestUtilities.CreateNewContact(true);
        
        //create a community user
        Profile portalProfile = [SELECT Id FROM Profile WHERE UserLicense.Name like '%High Volume Customer Portal' LIMIT 1];
        User communityUser = TestUtilities.CreateNewUser(portalProfile, false);
        communityUser.ContactId = contact.Id;
        insert communityUser;
        
        //Create 2 projects and set the project manager
        Project__c project_Active = TestUtilities.CreateProject(false);
        project_Active.Project_Manager__c = communityUser.Id;
        Project__c project_Inactive = TestUtilities.CreateProject(false);
        project_Inactive.Project_Manager__c = communityUser.Id;
        list<Project__c> projects = new list<Project__c> { project_Active, project_Inactive };
        insert projects;
        
        //Create 2 project roles
        Project_Role__c pRole_Active = new Project_Role__c(Name='Test',
                                                   Project_Type__c = 'CCC',
                                                   Role__c = 'Implementation Leader',
                                                   Contact__c = contact.Id,
                                                   Project__c = project_Active.Id,
                                                   SIAM_Portal_Status__c = Constants.SIAM_PORTAL_STATUS_ACTIVE);
        Project_Role__c pRole_Inactive = new Project_Role__c(Name='Test',
                                                   Project_Type__c = 'CCC',
                                                   Role__c = 'Implementation Leader',
                                                   Contact__c = contact.Id,
                                                   Project__c = project_Inactive.Id,
                                                   SIAM_Portal_Status__c = Constants.SIAM_PORTAL_STATUS_INACTIVE);
        list<Project_Role__c> pRoles = new list<Project_Role__c> { pRole_Active, pRole_Inactive };
        insert pRoles;
        
        //Enabling triggers
        Util.BypassAllTriggers = false;
        
        //Create a sample case record associated with the Member Support record
        Case aCase = new Case(Subject = 'testSubject',
                              Status = '01-New',
                              Tier_I_Support_Analyst__c = UserInfo.getUserId(),
                              Priority = 'Low',
                              Origin = 'Incoming Call',
                              ContactId = contact.Id,
                              Description = 'Test Description',
                              RecordTypeId = Constants.RECORD_TYPE_ID_CASE_PT_SUPPORT, 
                              Current_Results__c = 'test current results',
                              Expected_Results__c = 'test expected results',
                              Project_Source_MS__c = project_Active.Id,
                              Steps_to_Reproduce_MS__c = 'test steps to reproduce');
        insert aCase;
        
        //Asserting for the results
        System.assert(aCase != null);
        
        //get the case
        aCase = [SELECT Id, Member_Support_Ticket__c FROM Case WHERE Id = :aCase.Id];
        
        //get the member support record
        Site_Issue__c memberSupport = [SELECT Id, Tier__c FROM Site_Issue__c WHERE Id = :aCase.Member_Support_Ticket__c];
        System.assert(memberSupport != null);
        
        //Disabling triggers again
        Util.BypassAllTriggers = true;
        
        // set the page reference
        PageReference pageRef = Page.Case_Edit_PTCommunity;
        test.setCurrentPage(pageRef);
        
        //Add RecordType param to page URL 
        ApexPages.currentPage().getParameters().put('RecordType', Constants.RECORD_TYPE_ID_CASE_PT_SUPPORT);
        
        // instantiate the controller and set the page
        ApexPages.standardController standardController = new ApexPages.standardController(aCase);
        CaseController controller = new CaseController(standardController);
        
        //set the case contact to the current user's contact
        controller.caseObj.contactId = controller.ContactId;
        
        //Start test from here
        Test.startTest();
        
        //Setting URL parameters and invoking controller instance
        ApexPages.currentPage().getParameters().put('id', aCase.Id);
        CaseController caseContlr = new CaseController(); 
        
        //Filling the selectOption list from controlller
        List<selectOption> browserOptions = caseContlr.browserUsedOptions;
    
        //Assert for result
        System.assertNotEquals(null, browserOptions);
        
        //List of Attachment
        List<Attachment> attachmentList = new List<Attachment>();
        attachmentList.add(new Attachment(Name = 'Test',ContentType = 'Text', Description = 'Testing', 
                                          Body = Blob.valueOf('Test'),
                                          parentId = aCase.Id));
        
        //Insert Attachment
        insert attachmentList;
        
        //Clear the list
        attachmentList.clear();
        
        //Filling Attachment list from controller
        attachmentList = caseContlr.attachments;
        
        //Assert for result
        System.assertNotEquals(null, attachmentList);
        System.assertEquals(1, attachmentList.size());
        
        //Calling TestUtilities's method to insert CaseComment
        CaseComment caseComnt = TestUtilities.createNewCaseComment(aCase,true);
        
        //Filling CaseComment list form controller
        List<CaseComment> caseCommentsList = caseContlr.caseComments;
        
        //Assert for result
        System.assertNotEquals(null,caseCommentsList);
        System.assertEquals(1,caseCommentsList.size());
        
        //Stop test here
        Test.stopTest();  
    }
    
    /**
     * @description:  1) Create Contact, Project and Case record.
     *           2) Select Gold Partner – Synergy and assign to a user
     *           3) Load constructor from this user
     * 
     * Revision Log:  V1.0
     **/
    static testMethod void testInGoldPartnerSynergyUserContext() {
        
        // temporarily bypass all triggers
        Util.BypassAllTriggers = true;
        
        //Create a contact
        Contact contact = TestUtilities.CreateNewContact(true);
        
        //Create project and set the project manager
        Project__c project_Active = TestUtilities.CreateProject(false);
        project_Active.Project_Manager__c = UserInfo.getUserId();
        insert project_Active;    
        
        //Create a sample case record associated with the Member Support record
        Case aCase = new Case(Subject = 'testSubject',
                              Status = '01-New',
                              Tier_I_Support_Analyst__c = UserInfo.getUserId(),
                              Priority = 'Low',
                              Origin = 'Incoming Call',
                              ContactId = contact.Id,
                              Description = 'Test Description',
                              RecordTypeId = Constants.RECORD_TYPE_ID_CASE_PT_SUPPORT, 
                              Current_Results__c = 'test current results',
                              Expected_Results__c = 'test expected results',
                              OwnerId = Constants.tier1UnassignedQueue.Id,
                              Steps_to_Reproduce_MS__c = 'test steps to reproduce');
        
        insert aCase;
        
        //List of Profile
        List<Profile> profiles = [SELECT Id FROM Profile WHERE Name = 'Gold Partner – Synergy'];
        System.assert(profiles != null);
        System.assert(profiles.size() == 1);
        
        //User record
        User user = new User(Alias = 'GPartner', Email='goldpartner@testing.com', ContactId = contact.ID,
                             EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                             LocaleSidKey='en_US', ProfileId = profiles[0].Id, department = 'STP',
                             TimeZoneSidKey='America/Los_Angeles', UserName=Math.random() + '@test.com');
            
        //Loading the VF page in context of "Gold Partner – Synergy" user context
        System.runAs(user) {
            
            //Start test from here
            Test.startTest();
            
            //StandardSetController instance
            ApexPages.StandardController sc = new ApexPages.StandardController(aCase);
          CaseController ac = new CaseController(sc);
            
            //Simple controller
            CaseController controller = new CaseController();
            
            //Setting current user as "Technical Project Manager"
          controller.projectManagerId = UserInfo.getUserId();
            
            //List of cases
            List<Case> cases = new List<Case>();
            cases.add(aCase);
            
            //Standard Set Controller constructor
            ApexPages.StandardSetController sc1 = new ApexPages.standardSetController(cases);
      CaseController sSetCon = new CaseController(sc1);
            
            //Stop test here
            Test.stopTest();
        }
    }
}