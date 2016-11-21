/**
 *  Purpose         :   Test code for the ReferenceRequestExtension class
 * 
 *  Created By      :   Victor Hanson
 * 
 *  Created Date    :   1/13/2016
 * 
 * Revision Logs    :   V_1.0 - Created
 *
 **/ 
@isTest
public class Test_ReferenceRequestExtension {
    
    //setup test data
    @testSetup static void setup() {
        /**
         * @description:1) Setup 3 users with related contacts
         *              2) Create Program Collections/Collection Perspectives/Collection Perspective Children
         *              3) Create an Ambassador reference for a contact
         **/
        Test_ReferenceRequestController.setupTestData();
    }
    
    /**
     * @description: When a Reference Request is saved, simulate the process of adding Reference Request Contacts and submitting them for approval.
     **/
    static testMethod void testIdentifyContact() {
        
        util.BypassAllTriggers = true;
        //create the requesting contact record
        Contact reqContact = TestUtilities.CreateNewContact(false);
        reqContact.lastName = 'reqContact';
        reqContact.recordTypeId = Test_ReferenceRequestController.CONTACT_EXTERNAL_RT_ID;
        insert reqContact;
        util.BypassAllTriggers = false;
        
        //get the existing ambassador contact, which was created in testSetup
        Contact ambassadorContact = [SELECT Id FROM Contact WHERE LastName = 'Ambassador'];
        
        //create the membership related to the institution
        util.BypassAllTriggers = true;
        Membership__c mem = new Membership__c(Account_Name__c = reqContact.AccountId);
        insert mem;
        util.BypassAllTriggers = false;
        
    test.startTest();
        //create the Reference Request
        Reference_Request__c req = new Reference_Request__c(Request_Status__c = 'New',
                                                           Reference_Modules__c = 'CCC',
                                                           Requesting_Contact__c = reqContact.Id,
                                                           Requesting_Institution__c = reqContact.AccountId,
                                                           Source_Membership__c = mem.Id,
                                                           Date_Needed_By__c = Date.today(),
                                                           Number_of_References_Needed__c = 1,
                                                           Reference_Type_Needed__c = 'Individual',
                                                           Submitted_By__c = userInfo.getUserId());
        insert req;
        
        //set the page reference
        PageReference pageRef = Page.ReferenceFulfillment;
        test.setCurrentPage(pageRef);
        
        //Set currentpage parameters
        ApexPages.currentPage().getParameters().put('id', req.Id);
        
        //instantiate the controller
        ReferenceRequestExtension controller = new ReferenceRequestExtension(new ApexPages.StandardController(req));
        
        //add, and subsequently remove a reference request contact record
        controller.addRefContact();
        controller.indexVal = 3; // set the reference contact to remove to the second item in the list
        controller.removeRefContact();
        
        //select the ambassador reference contact
        controller.refConWrappers[0].referenceRequestContact.Reference_Contact__c = ambassadorContact.id;
        controller.indexVal = 2;
        controller.identifyContact();
        system.assertEquals('CCC', controller.refConWrappers[0].referenceRequestContact.Reference_Modules__c);
        
        //create the Reference Request Contact
        /*Reference_Request_Contact__c rrc = new Reference_Request_Contact__c(Reference_Contact__c = ambassadorContact.Id,
                                                                            Reference_Request__c = req.Id,
                                                                            Reference_Modules__c = 'CCC',
                                                                            Approval_Status__c = 'Pending',
                                                                            Reference_Lead__c = userInfo.getUserId());
        insert rrc;*/
        
    test.stopTest();
        
        //saveAndSend = true means that the user clicked the 'Send Recommendations' button
        controller.saveAndSend = true;
        controller.save();
        
        //verify there are no errors
        for(ApexPages.Message msg :  ApexPages.getMessages()) {
            if (msg.getSeverity() == ApexPages.Severity.ERROR) {
                //if there is an error, make sure it causes the test to fail
                system.assertEquals('ERROR', msg.getSummary());
            }
        }
        
        list<Reference_Request_Contact__c> refRequestContacts = [SELECT Id, Approval_Status__c FROM Reference_Request_Contact__c WHERE Reference_Request__c = :req.Id];
        system.assertEquals(1, refRequestContacts.size());
        system.assertEquals('Pending', refRequestContacts[0].Approval_Status__c);
    }
}