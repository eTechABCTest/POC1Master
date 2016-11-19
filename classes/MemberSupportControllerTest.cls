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
@isTest(seeAllData=false)
private class MemberSupportControllerTest {
    
    /**
    Purpose         :   Test class for MemberSupportController
                
    Create By       :   Abhinav Sharma
    
    Created Date    :   04/06/2016
    
    Revision Log    :   v1.0 - Created - CR-20160224-9632 - 04/06/2016	
	**/
	static testmethod void testSyncInBetweenCaseToMS() {
        
        //Bypass all triggers
        Util.BypassAllTriggers = true;
        
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
                              Steps_to_Reproduce_MS__c = 'test steps to reproduce',
                              Button_Used__c = true);
        
        //Perform the test by inserting the contact
        test.startTest();
        
        //Enabling triggers
        Util.BypassAllTriggers = false;

        //Insert Case
        insert aCase;
        System.assert(aCase != null);
        
        //Querying for records and asserting for the results
        List<Site_Issue__c> memberSupports = new List<Site_Issue__c>();
        memberSupports = [SELECT ID, Tier__c FROM Site_Issue__c];
        System.assert(memberSupports != null);
        System.assert(memberSupports.size() == 1);
        
        //List of cases
        List<Case> cases = [SELECT ID, Tier_MS__c, Status, Project_Source_MS__c, 
                      		OwnerId, Tier_I_Support_Analyst__c, Member_Support_Ticket__c 
                       		FROM Case 
                            WHERE Member_Support_Ticket__c != null
                            AND Member_Support_Ticket__c IN : memberSupports];
        
        System.assert(cases != null);
        System.assert(cases.size() == 1);
        System.assertEquals('01-New', cases[0].Status);
        System.assert(cases[0].Project_Source_MS__c == project.Id);
        System.assert(cases[0].Member_Support_Ticket__c == memberSupports[0].ID);
        memberSupports = [SELECT ID, Tier__c FROM Site_Issue__c];
        
        //Calling controller
        ApexPages.StandardController sc = new ApexPages.StandardController(memberSupports[0]);
        MemberSupportController con = new MemberSupportController(sc);
        
        try {
        
            //Clicking on "Accept Issue Button"
        	con.acceptIssue();
        
        } catch(Exception ex) {
            
            //Asserting for the results
            System.assert(ex.getMessage().contains(System.Label.ERROR_TIER_I_ACCEPT_BUTTON));
        }
        
        //Disabling triggers
        Util.BypassAllTriggers = true;
        
        //Update tier value on MS
        memberSupports[0].Tier__c = Constants.SITE_ISSUE_TIER_I;
        memberSupports[0].Button_Used__c = true;
        update memberSupports;
        
        //Setting "Tier I Support Analyst" to have blank/null value
        cases[0].Tier_I_Support_Analyst__c = null;
        cases[0].Button_Used__c = true;
        update cases;
        
        //Enabling triggers
        Util.BypassAllTriggers = false;
        
        //Stop test here
        Test.stopTest();
        
        //Calling controller
        ApexPages.StandardController sc1 = new ApexPages.StandardController(memberSupports[0]);
        MemberSupportController con1 = new MemberSupportController(sc1);
        
        //Clicking on the button
        con1.acceptButtonError = false;
        con1.acceptIssue();  
        
        //List of cases
        cases = [SELECT ID, Tier_MS__c, Status, Project_Source_MS__c, 
                      		OwnerId, Tier_I_Support_Analyst__c, Member_Support_Ticket__c 
                       		FROM Case 
                            WHERE Member_Support_Ticket__c != null
                            AND Member_Support_Ticket__c IN : memberSupports];
        
        System.assert(cases != null);
        System.assert(cases.size() == 1);
        System.assert(cases[0].Project_Source_MS__c == project.Id);
        System.assert(cases[0].Member_Support_Ticket__c == memberSupports[0].ID);
    }  
}