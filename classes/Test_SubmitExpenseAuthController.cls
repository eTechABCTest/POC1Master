/**
 * 	@description	:	Test class for the SubmitExpenseAuthController Class.
 * 
 * 	@Created By		:	Victor Hanson
 * 
 * 	@Change History	:	V1.0 - Created - 02/06/2015 - Victor Hanson - CR-20140520-5562
 * 
 **/
@isTest
public class Test_SubmitExpenseAuthController {
	
    //create an expense authorization and submit for approval
    static testMethod void testSubmitExpenseAuth() {
        //create a contact, budget G/L, meeting, registration, and expense authorization
        Contact con = TestUtilities.CreateNewContact(true);
        Cost_Center__c budgetGL = Test_ExpenseAuthTriggerHelper.createCostCenter(userInfo.getUserId(), true);
        Advisory_Event__c meeting = TestUtilities.createEvent(Constants.RECORD_TYPE_ID_ADV_EVENT_SERIES, budgetGL.Id, true);
        Event_Registration__c reg = TestUtilities.createRegistration(meeting.Id, con.Id, true);
        Expense_Authorization__c eAuth = new Expense_Authorization__c(Event_Registration__c = reg.Id,
                                                                      Start_Date__c = system.today(),
                                                                      End_Date__c = system.today(),
                                                                      Amount__c = 123,
                                                                      Status__c = 'New',
                                                                      Type__c = 'Accomodations');
        insert eAuth;
        
        //set the page reference
        PageReference pageRef = Page.SubmitExpenseAuth;
        test.setCurrentPage(pageRef);
        
        //instantiate the controller and set the page
        ApexPages.standardController standardController = new ApexPages.standardController(eAuth);
        SubmitExpenseAuthController controller = new SubmitExpenseAuthController(standardController);
        controller.submit();
        
        system.assertEquals(0, controller.errors.size());
    }
    
    //create an expense authorization and submit for approval - should throw an error because the budget g/l doesn't contain an approver
    static testMethod void testSubmitExpenseAuth_noApprover() {
        //create a contact, budget G/L, meeting, registration, and expense authorization
        Contact con = TestUtilities.CreateNewContact(true);
        Cost_Center__c budgetGL = Test_ExpenseAuthTriggerHelper.createCostCenter(null, true);
        Advisory_Event__c meeting = TestUtilities.createEvent(Constants.RECORD_TYPE_ID_ADV_EVENT_SERIES, budgetGL.Id, true);
        Event_Registration__c reg = TestUtilities.createRegistration(meeting.Id, con.Id, true);
        Expense_Authorization__c eAuth = new Expense_Authorization__c(Event_Registration__c = reg.Id,
                                                                      Start_Date__c = system.today(),
                                                                      End_Date__c = system.today(),
                                                                      Amount__c = 123,
                                                                      Status__c = 'New',
                                                                      Type__c = 'Accomodations');
        insert eAuth;
        
        //set the page reference
        PageReference pageRef = Page.SubmitExpenseAuth;
        test.setCurrentPage(pageRef);
        
        //instantiate the controller and set the page
        ApexPages.standardController standardController = new ApexPages.standardController(eAuth);
        SubmitExpenseAuthController controller = new SubmitExpenseAuthController(standardController);
        controller.submit();
        
        system.assertEquals(1, controller.errors.size());
        system.assertEquals(Label.ExpenseAuth_MissingApproverMessage, controller.errors[0]);
    }
    
    //create an expense authorization and submit for approval - should throw an error because the status != new
    static testMethod void testSubmitExpenseAuth_notNew() {
        //create a contact, budget G/L, meeting, registration, and expense authorization
        Contact con = TestUtilities.CreateNewContact(true);
        Cost_Center__c budgetGL = Test_ExpenseAuthTriggerHelper.createCostCenter(userInfo.getUserId(), true);
        Advisory_Event__c meeting = TestUtilities.createEvent(Constants.RECORD_TYPE_ID_ADV_EVENT_SERIES, budgetGL.Id, true);
        Event_Registration__c reg = TestUtilities.createRegistration(meeting.Id, con.Id, true);
        Expense_Authorization__c eAuth = new Expense_Authorization__c(Event_Registration__c = reg.Id,
                                                                      Start_Date__c = system.today(),
                                                                      End_Date__c = system.today(),
                                                                      Amount__c = 123,
                                                                      Status__c = 'Pending',
                                                                      Type__c = 'Accomodations');
        insert eAuth;
        
        //set the page reference
        PageReference pageRef = Page.SubmitExpenseAuth;
        test.setCurrentPage(pageRef);
        
        //instantiate the controller and set the page
        ApexPages.standardController standardController = new ApexPages.standardController(eAuth);
        SubmitExpenseAuthController controller = new SubmitExpenseAuthController(standardController);
        controller.submit();
        
        system.assertEquals(1, controller.errors.size());
    }
}