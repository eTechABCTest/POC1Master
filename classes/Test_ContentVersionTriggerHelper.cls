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
public class Test_ContentVersionTriggerHelper {
    
    /**
     *  Purpose         :   Test class for ContentVersionTriggerHelper
     *               
     *  Created By      :   Abhinav Sharma
     *   
     *  Created Date    :   09/03/2016
     *   
     *  Revision Log    :   v1.0 - Created - Abhinav Sharma - CR-20160224-9640
     *                       
     *  Coverage        :   v_1.0 - ContentVersionTriggerHelper - 100%
    **/
    
    //Added By - Rajeev Jain - 09/09/2016 - CR-20160224-9640 - Method to Setup Common data in test class
    @testSetup static void setUpTestData() {
        
        //Bypass Dupeblocker
        Util.IsTest(true);
        Util.isTesting = true;
        
        //Bypassing Triggers so then test data can be created easily
        Util.byPassAllTriggers = true;
        
        //Create test data for the Sync Fields custom setting that syncs Mem Support -> Case fields
        TestUtilities.createSyncFields();
        
        //List to hold the Account records
        List<Account> accounts = new List<Account>();
        
        //Create an institution
        Account acct_1 = TestUtilities.CreateNewAccount(false);
        
        //Populating list with account records
        accounts.add(acct_1); 
        
        //Insert accounts
        insert accounts;
        
        //Querying Details for "Member & Employee Support" record type on Case Object
        List<RecordType> caseRdTypes = [SELECT ID, DeveloperName FROM RecordType 
                                        Where sObjectType = 'Case' 
                                        AND IsActive = true 
                                        AND DeveloperName = :Constants.RECORD_TYPE_CASE_DEVELOPER_NAME_PT_SUPPORT_REQUEST
                                        ORDER By DeveloperName ASC];
                                        
                                        
        //List to hold the case records
        List<Case> cases = new List<Case>();
        
        //Create a sample case record to insert and test case trigger
        Case aCase_1 = new Case(RecordTypeId = caseRdTypes[0].Id, Origin = 'ABC', Subject = 'Test', 
                                Description = 'Test', AccountId = accounts[0].Id);
       
        //Populating list with case records
        cases.add(aCase_1);
        
        //Enabling triggers
        Util.byPassAllTriggers = false;
       
        //Insert cases
        insert cases;
    }
    
    //Added By - Rajeev Jain - 09/09/2016 - CR-20160224-9640
    //This method test sharing of the files on the Member Support, Attachment of the file on MS, when file stamp on the case record
    static testmethod void testSharingFilesFromCaseToMemberSupportObj() {
        
        //Query on Case Records
        List<Case> cases = [select Id, RecordTypeId, Description, Origin, AccountId, Member_Support_Ticket__c from Case];
        
        //Start test from here
        Test.startTest();
        
        //Assert for the results
        System.assert(cases != null);
        System.assert(cases.size() == 1);
        
        //Now Assert for Results
        System.assertEquals(true,cases[0].Member_Support_Ticket__c != null);
              
        //Insert File On Case Object and See Attachment on the Case and See Sharing of the files on the Memeber Support and Check attachment as well
        //List of content versions
         
        ContentVersion versionDoc = new ContentVersion(Title = 'A08Floor', Description = 'This is the test Content Version Doc');
        versionDoc.Origin = 'H';
        versionDoc.ContentLocation = 'S'; 
        versionDoc.VersionData = Blob.valueOf('Unit Test Attachment Body');
        versionDoc.PathOnClient = 'test.pdf';
        versionDoc.FirstPublishLocationID = UserInfo.getUserId();
        insert versionDoc;
        
        List<ContentVersion> versionDocs = [select Id, ContentDocumentId from ContentVersion where Id = :versionDoc.Id];
        
        List<ContentDocument> contDoc = [select Id, Title from ContentDocument where Id = :versionDocs[0].ContentDocumentId];
        
         //Insert Content Document Link
        ContentDocumentLink contDocLink = new ContentDocumentLink();
        contDocLink.ContentDocumentId = contDoc[0].Id;
        contDocLink.LinkedEntityId = cases[0].Id;
        contDocLink.ShareType = 'V';
        insert contDocLink;
         
        //now uu
        //Query on Memeber Support Records and see if the file is visible below of the Member Support
        List<Site_Issue__c> issues = [select Id from Site_Issue__c where Id = :cases[0].Member_Support_Ticket__c];
        
        System.assertEquals(true, issues.size() > 0);
        
        //Stop Test
        Test.stopTest();
        
        //============ Since ContentVersion Library works as Webservice, so we have to wait for those asserts, in order to check correct results===========
        //Now convert member Support Id to LinkEntity Id
        String linkEntityID = issues[0].Id;
        
        //Now Query on Content Document Link if it is inserted for Member Support Record on the case object
        List<ContentDocumentLink> documentLink = [select Id, ContentDocumentId, LinkedEntityId from ContentDocumentLink where LinkedEntityId = :linkEntityID];
        
        //Assert to check if Document file inserted on Case record, has stamped on Parent Member Support Reocrd
        System.assertEquals(true, documentLink.size() > 0);
        System.assertEquals(true,documentLink[0].ContentDocumentId == contDoc[0].Id);
        
        //Qeury to Get Attachment on case's Record
        //When any file insert on Case record that must be shared with corrosponding Member Support record, 
        //along with this that file must be stamped as attachment, just below of the Case recod
        List<Attachment> attachmentList = [select Id, ParentId, body, Name, ContentType from Attachment where ParentId = :cases[0].Id];
        
        System.assertEquals(true, attachmentList.size() > 0);
        System.assertEquals(true,attachmentList[0].Name == contDoc[0].Title);
    }
    
    //Added By - Rajeev Jain - 09/09/2016 - CR-20160224-9640
    //This method test sharing of the files on the Member Support, Attachment of the file on MS, when file stamp on the case record
    static testmethod void testSharingFilesFromMemberSupportObjToCase() {
        
        //Query on Case Records
        List<Case> cases = [select Id, RecordTypeId, Description, Origin, AccountId, Member_Support_Ticket__c from Case];
        
        //Start test from here
        Test.startTest();
        
        //Assert for the results
        System.assert(cases != null);
        System.assert(cases.size() == 1);
        
        //Now Assert for Results
        System.assertEquals(true,cases[0].Member_Support_Ticket__c != null);
              
        //Insert File On Case Object and See Attachment on the Case and See Sharing of the files on the Memeber Support and Check attachment as well
        //List of content versions
         
        ContentVersion versionDoc = new ContentVersion(Title = 'A08Floor', Description = 'This is the test Content Version Doc');
        versionDoc.Origin = 'H';
        versionDoc.ContentLocation = 'S'; 
        versionDoc.VersionData = Blob.valueOf('Unit Test Attachment Body');
        versionDoc.PathOnClient = 'test.pdf';
        versionDoc.FirstPublishLocationID = UserInfo.getUserId();
        insert versionDoc;
        
        List<ContentVersion> versionDocs = [select Id, ContentDocumentId from ContentVersion where Id = :versionDoc.Id];
        
        List<ContentDocument> contDoc = [select Id, Title from ContentDocument where Id = :versionDocs[0].ContentDocumentId];
        
         //Insert Content Document Link
        ContentDocumentLink contDocLink = new ContentDocumentLink();
        contDocLink.ContentDocumentId = contDoc[0].Id;
        contDocLink.LinkedEntityId = cases[0].Member_Support_Ticket__c;
        contDocLink.ShareType = 'V';
        insert contDocLink;
         
        //now uu
        //Query on Memeber Support Records and see if the file is visible below of the Member Support
        List<Site_Issue__c> issues = [select Id from Site_Issue__c where Id = :cases[0].Member_Support_Ticket__c];
        
        System.assertEquals(true, issues.size() > 0);
        
        //Stop Test
        Test.stopTest();    
        
        //============ Since ContentVersion Library works as Webservice, so we have to wait for those asserts, in order to check correct results===========
        //Now convert Case Id to LinkEntity Id
        String linkEntityID = cases[0].Id;
        
        //Now Query on Content Document Link if it is inserted for Case Record on the Member Support Record
        List<ContentDocumentLink> documentLink = [select Id, ContentDocumentId, LinkedEntityId from ContentDocumentLink where LinkedEntityId = :linkEntityID];
        
        //Assert to check if Document file inserted on Ms record, has stamped on Child Case Record
        System.assertEquals(true, documentLink.size() > 0);
        System.assertEquals(true,documentLink[0].ContentDocumentId == contDoc[0].Id);
        
        //Qeury to Get Attachment on Ms Record
        //When any file insert on Ms that must be shared with corrosponding Case record, 
        //along with this that file must be stamped as attachment, just below of the Ms recod
        List<Attachment> attachmentList = [select Id, ParentId, body, Name, ContentType from Attachment where ParentId = :cases[0].Member_Support_Ticket__c];
        
        System.assertEquals(true, attachmentList.size() > 0);
        System.assertEquals(true,attachmentList[0].Name == contDoc[0].Title);
    }
}