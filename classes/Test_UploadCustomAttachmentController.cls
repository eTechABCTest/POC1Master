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
private class Test_UploadCustomAttachmentController {
    
    /**
        Purpose         :   Test class for UploadCustomAttachmentController class.
                    
        Created By      :   Abhinav Sharma
        
        Created Date    :   03/24/2015
        
        Current Version :   v1.0
        
        Revision Log    :   v1.0 - Abhinav Sharma - 03/24/2015 - CR-20141216-8336
                        
    **/

    static testMethod void myUnitTest() {
        
        //Bypass Dupeblocker
        Util.IsTest(true);
        
        //Bypassing Triggers so then test data can be created easily
        Util.byPassAllTriggers = true;
        
        //Querying Details for "Member & Employee Support" record type on Case Object
        List<RecordType> rdType = [SELECT ID FROM RecordType Where sObjectType = 'Campaign' AND IsActive = true 
                                                AND DeveloperName = 'Mailing_Campaign'];
        
        //Assert for result
        System.assert(rdType != null);
        
        //Camapign record
        Campaign mailingCampaign = new Campaign(Name = 'Test', Mailing_Title__c='Mailing-1', RecordTypeId = rdType[0].ID);
        insert mailingCampaign;
        
        //Custom Attachment
        Attachment__c customAttachment = new Attachment__c();
        
        //Start test from here
        Test.startTest();
        
        Test.setCurrentPageReference(new PageReference('Page.UploadCustomAttachment'));
        System.currentPageReference().getParameters().put('parentid', mailingCampaign.Id);
        
        //Load the VF page
        ApexPages.StandardController sc = new ApexPages.standardController(customAttachment);
        UploadCustomAttachmentController controller = new UploadCustomAttachmentController (sc);
        
        //CLicking on the Attach file button
        controller.processUpload();
        controller.doCancel();
        
        //Stop Test here
        Test.stopTest();
    }
    
    static testMethod void myUnitTest_1() {
        
        //Bypass Dupeblocker
        Util.IsTest(true);
        
        //Bypassing Triggers so then test data can be created easily
        Util.byPassAllTriggers = true;
        
        //Querying Details for "Member & Employee Support" record type on Case Object
        List<RecordType> rdType = [SELECT ID FROM RecordType Where sObjectType = 'Campaign' AND IsActive = true 
                                                AND DeveloperName = 'Mailing_Campaign'];
        
        //Assert for result
        System.assert(rdType != null);
        
        //Camapign record
        Campaign mailingCampaign = new Campaign(Name = 'Test', Mailing_Title__c='Mailing-1', RecordTypeId = rdType[0].ID);
        insert mailingCampaign;
        
        //Custom Attachment
        Attachment__c customAttachment = new Attachment__c();
        
        //Start test from here
        Test.startTest();
        
        Test.setCurrentPageReference(new PageReference('Page.UploadCustomAttachment'));
        System.currentPageReference().getParameters().put('parentid', mailingCampaign.Id);
        
        //Load the VF page
        ApexPages.StandardController sc = new ApexPages.standardController(customAttachment);
        UploadCustomAttachmentController controller = new UploadCustomAttachmentController (sc);
        
        //Enabling triggers again
        Util.byPassAllTriggers = false;
        
        controller.fileName = 'testfile.PDF';
        controller.fileBody = Blob.valueOf('Unit Test Attachment Body');
        
        //CLicking on the Attach file button
        controller.processUpload();
        
        //Stop Test here
        Test.stopTest();
    }
    
    static testMethod void myUnitTest_2() {
        
        //Bypass Dupeblocker
        Util.IsTest(true);
        
        //Bypassing Triggers so then test data can be created easily
        Util.byPassAllTriggers = true;
        
        //Querying Details for "Member & Employee Support" record type on Case Object
        List<RecordType> rdType = [SELECT ID FROM RecordType Where sObjectType = 'Campaign' AND IsActive = true 
                                                AND DeveloperName = 'Mailing_Campaign'];
        
        //Assert for result
        System.assert(rdType != null);
        
        //Camapign record
        Campaign mailingCampaign = new Campaign(Name = 'Test', Mailing_Title__c='Mailing-1', RecordTypeId = rdType[0].ID);
        insert mailingCampaign;
        
        //Custom Attachment
        Attachment__c customAttachment = new Attachment__c(Paper_Type__c = 'Blank Letterhead Stock (23440A)', Campaign__c = mailingCampaign.ID);
        insert customAttachment;
        
        //Attachment
        Attachment attach=new Attachment();     
        attach.Name='Unit Test Attachment';
        Blob bodyBlob = Blob.valueOf('Unit Test Attachment Body');
        attach.body = bodyBlob;
        attach.parentId = customAttachment.id;
        attach.ContentType = '.pdf';
        insert attach;
        
        //Start test from here
        Test.startTest();
        
        Test.setCurrentPageReference(new PageReference('Page.UploadCustomAttachment'));
        System.currentPageReference().getParameters().put('id', customAttachment.Id);
        
        //Load the VF page
        ApexPages.StandardController sc = new ApexPages.standardController(customAttachment);
        UploadCustomAttachmentController controller = new UploadCustomAttachmentController (sc);
        
        controller.fileName = 'testfile.PDF';
        controller.fileBody = Blob.valueOf('Unit Test Attachment Body');
        
        //CLicking on the Attach file button
        controller.processUpload();
        controller.doCancel();
        
        //Stop Test here
        Test.stopTest();
    }
    
    static testMethod void myUnitTest_3() {
        
        //Bypass Dupeblocker
        Util.IsTest(true);
        
        //Bypassing Triggers so then test data can be created easily
        Util.byPassAllTriggers = true;
        
        //Querying Details for "Member & Employee Support" record type on Case Object
        List<RecordType> rdType = [SELECT ID FROM RecordType Where sObjectType = 'Campaign' AND IsActive = true 
                                                AND DeveloperName = 'Mailing_Campaign'];
        
        //Assert for result
        System.assert(rdType != null);
        
        //Camapign record
        Campaign mailingCampaign = new Campaign(Name = 'Test', Mailing_Title__c='Mailing-1', RecordTypeId = rdType[0].ID);
        insert mailingCampaign;
        
        //Custom Attachment
        Attachment__c customAttachment = new Attachment__c(Paper_Type__c = 'Blank Letterhead Stock (23440A)',
                                                            Campaign__c = mailingCampaign.ID);
        insert customAttachment;
        
        //Attachment
        Attachment attach=new Attachment();     
        attach.Name='Unit Test Attachment';
        Blob bodyBlob = Blob.valueOf('Unit Test Attachment Body');
        attach.body = bodyBlob;
        attach.parentId = customAttachment.id;
        attach.ContentType = '.pdf';
        insert attach;
        
        //Start test from here
        Test.startTest();
        
        Test.setCurrentPageReference(new PageReference('Page.UploadCustomAttachment'));
        System.currentPageReference().getParameters().put('id', customAttachment.Id);
        
        //Load the VF page
        ApexPages.StandardController sc = new ApexPages.standardController(customAttachment);
        UploadCustomAttachmentController controller = new UploadCustomAttachmentController (sc);
        
        controller.fileName = 'testfile.XML';
        controller.fileBody = Blob.valueOf('Unit Test Attachment Body');
        
        //Inabling trigger again
        Util.byPassAllTriggers = true;
        
        //CLicking on the Attach file button
        try {
            controller.processUpload();
        } catch(Exception ex) {
            System.assert(ex.getMessage().contains('Only PDF attachments are allowed on Mailing Campaigns'), 'message=' + ex.getMessage());    
        }
        
        //Stop Test here
        Test.stopTest();
    }
}