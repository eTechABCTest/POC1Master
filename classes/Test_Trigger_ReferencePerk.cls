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
/**
    *   Purpose         :   Test class for Trigger_ReferencePerk
    *            
    *   Create By       :   Rajeev Jain
    *
    *   Created Date    :   12/22/2015
    *
    *   Revision Log    :   V_1.0
    * 
    *   Coverage        :   100% 
**/
@isTest(seeAlldata = false)
public class Test_Trigger_ReferencePerk {
    
    //Constants of record type developer name related to Reference_Perk sObject.
    public static final String PERK_TEMPLATE = 'Perk_Template';
   
    static testMethod void testValidateReferencePerk(){
        
        //setup test data
        Test_ReferenceRequestController.setupTestData();
        
        //Creating account.
        Account account = TestUtilities.CreateNewAccount(false);
        insert account;
        
        //Create Contact
        List<Contact> contacts = new List<Contact>();
        
        //Add new contact in list
        contacts.add(new Contact(FirstName = 'Test', LastName = 'Contact', Email = 'test@test.com', AccountId = account.Id, 
                                      Employee_User_Record__c = Userinfo.getUserId()));
        contacts.add(new Contact(FirstName = 'Test1', LastName = 'Contact1', Email = 'test1@test.com', AccountId = account.Id, 
                                      Employee_User_Record__c = Userinfo.getUserId()));
        contacts.add(new Contact(FirstName = 'Test2', LastName = 'Contact2', Email = 'test2@test.com', AccountId = account.Id, 
                                      Employee_User_Record__c = Userinfo.getUserId()));
        contacts.add(new Contact(FirstName = 'Test3', LastName = 'Contact3', Email = 'test3@test.com', AccountId = account.Id, 
                                      Employee_User_Record__c = Userinfo.getUserId()));
        
        //Insert
        insert contacts;
        
        //Creating membership record.
        Membership__c memberRecord = new Membership__c(Name='John', Account_Name__c = account.Id);
        insert memberRecord;
        
        //Fetching record type id where developer name is equals to Performance Teechnology.
        String reccordTypePerkTemplate ='' ;
        String recordTypePerfomanceTech ='';
        
        for(RecordType recordType :[select Id, DeveloperName from RecordType where sObjectType = 'Reference_Perk__c' ORDER BY DeveloperName]) {
            
            if(recordType.DeveloperName == Label.PT)
                recordTypePerfomanceTech = recordType.Id;
            if(recordType.DeveloperName == PERK_TEMPLATE)
                reccordTypePerkTemplate = recordType.Id;
        }
        
        Test.startTest();  
        
        //Creating Reference record.
        List<Reference__c> referenceRecords = new List<Reference__c>();
        referenceRecords.add(new Reference__c(Contact_Name__c = contacts[0].Id, Dedicated_Advisor__c = UserInfo.getUserId(), Membership__c = memberRecord .Id, Reference_Status__c = 'Vetted', Reference_Level__c = 'Ambassador', Reference_Module__c = 'CMA', Institution__c = account.Id, Reference_Vetter__c = userInfo.getUserId()));
        referenceRecords.add(new Reference__c(Contact_Name__c = contacts[1].Id, Dedicated_Advisor__c = UserInfo.getUserId(), Membership__c = memberRecord .Id, Reference_Status__c = 'Vetted', Reference_Level__c = 'Ambassador', Reference_Module__c = 'CMR', Institution__c = account.Id, Reference_Vetter__c = userInfo.getUserId()));
        referenceRecords.add(new Reference__c(Contact_Name__c = contacts[2].Id, Dedicated_Advisor__c = UserInfo.getUserId(), Membership__c = memberRecord .Id, Reference_Status__c = 'Vetted', Reference_Level__c = 'Ambassador', Reference_Module__c = 'CPRM', Institution__c = account.Id, Reference_Vetter__c = userInfo.getUserId()));
        referenceRecords.add(new Reference__c(Contact_Name__c = contacts[3].Id, Dedicated_Advisor__c = UserInfo.getUserId(), Membership__c = memberRecord .Id, Reference_Status__c = 'Vetted', Reference_Level__c = 'Ambassador', Reference_Module__c = 'CCC', Institution__c = account.Id, Reference_Vetter__c = userInfo.getUserId()));
        insert referenceRecords;
        
        //Assert to check if Newly insrted refrenece Record are Active
        //Reference Record would be Active if Reference_Status__c = 'Vetted'
        List<Reference__c> referenceRecordsList = [SELECT IsActive__c FROM Reference__c];
        System.assertEquals(5, referenceRecordsList.size());
        System.assertEquals(true, referenceRecordsList[1].IsActive__c);
        System.assertEquals(true, referenceRecordsList[2].IsActive__c);
      
        //Inserting Perk Templates Records.
        List<Reference_Perk__c> perkTemplates = new List<Reference_Perk__c>();
        perkTemplates.add(new Reference_Perk__c(Name = 'Test 1', RecordTypeId = reccordTypePerkTemplate,Event_Date__c=Date.today(),  Available_Date__c = Date.today(),Expiration_Date__c = Date.today().addDays(2), Applicable_Reference_Module__c = 'CMA'));
        perkTemplates.add(new Reference_Perk__c(Name = 'Test 1', RecordTypeId = reccordTypePerkTemplate,Event_Date__c=Date.today(),  Available_Date__c = Date.today(),Expiration_Date__c = Date.today().addDays(4), Applicable_Reference_Module__c = 'CMR'));
        perkTemplates.add(new Reference_Perk__c(Name = 'Test 1', RecordTypeId = reccordTypePerkTemplate,Event_Date__c=Date.today(),  Available_Date__c = Date.today(),Expiration_Date__c = Date.today().addDays(5), Applicable_Reference_Module__c = 'CPRM'));
        perkTemplates.add(new Reference_Perk__c(Name = 'Test 1', RecordTypeId = reccordTypePerkTemplate,Event_Date__c=Date.today(),  Available_Date__c = Date.today(),Expiration_Date__c = Date.today().addDays(6), Applicable_Reference_Module__c = 'CCC'));
        insert perkTemplates;
        
        //Fetching reference perk records from database.
        List<Reference_Perk__c> perkTemplatesList = [SELECT Id, Status__c, Expiration_Date__c, Applicable_Reference_Module__c FROM Reference_Perk__c ORDER BY Expiration_Date__c ];
        
        //Asserts
        System.assertEquals(true, perkTemplatesList[3].Applicable_Reference_Module__c == 'CCC');
        System.assertEquals(true, perkTemplatesList[3].Status__c == 'Available');
        System.assertEquals(4, perkTemplatesList.size());
   
        //Inserting new Reference Perk Records Populated with Refernece Record and Perk Template Record, complete Perk Eligibility Criteria
        List<Reference_Perk__c> referencePerkRecords = new List<Reference_Perk__c>(); 
        referencePerkRecords.add(new Reference_Perk__c(Name = 'Test 2', RecordTypeId = recordTypePerfomanceTech, Perk_Template__c = perkTemplates[0].Id, Acceptance_Date__c = Date.today(), Reference__c = referenceRecords[0].Id, Applicable_Reference_Module__c = 'CMA'));
        referencePerkRecords.add(new Reference_Perk__c(Name = 'Test 4', RecordTypeId = recordTypePerfomanceTech, Perk_Template__c = perkTemplates[1].Id, Acceptance_Date__c = Date.today(), Reference__c = referenceRecords[1].Id, Applicable_Reference_Module__c = 'CMR'));
        referencePerkRecords.add(new Reference_Perk__c(Name = 'Test 5', RecordTypeId = recordTypePerfomanceTech, Perk_Template__c = perkTemplates[2].Id, Acceptance_Date__c = Date.today(), Reference__c = referenceRecords[2].Id, Applicable_Reference_Module__c = 'CPRM'));
        referencePerkRecords.add(new Reference_Perk__c(Name = 'Test 6', RecordTypeId = recordTypePerfomanceTech, Perk_Template__c = perkTemplates[3].Id, Acceptance_Date__c = Date.today(), Reference__c = referenceRecords[3].Id, Applicable_Reference_Module__c = 'CCC'));
        insert referencePerkRecords;
        
        //Fetching reference perk records from database.
        List<Reference_Perk__c> referencePerkRecordList = [SELECT Id, Contact__c FROM Reference_Perk__c WHERE Perk_Template__c != null AND ID IN : referencePerkRecords ORDER BY Expiration_Date__c];
        System.assertEquals(4, referencePerkRecordList.size());
        System.assertEquals(true, referencePerkRecordList[2].Contact__c == referenceRecords[2].Contact_Name__c);
        System.assertEquals(true, referencePerkRecordList[1].Contact__c == referenceRecords[1].Contact_Name__c);
        System.assertEquals(true, referencePerkRecordList[0].Contact__c == referenceRecords[0].Contact_Name__c);
        
        //Cover exception Code in the trigger
        //Cresting a record for reference perk which will throw a exception.
        Reference_Perk__c refPerkTech = new Reference_Perk__c(Name = 'Test 1', RecordTypeId = reccordTypePerkTemplate,Event_Date__c=Date.today(),Acceptance_Date__c = Date.today(),  Available_Date__c = Date.today().addDays(-3),Expiration_Date__c = Date.today().addDays(-2), Applicable_Reference_Module__c = 'CCC');
        insert refPerkTech;
        
        try{
            //Fetching reference perk records from database.
            List<Reference_Perk__c> referencePerkRecords2 = [SELECT Id, Contact__c FROM Reference_Perk__c WHERE Event_Date__c <: Date.today()];
            delete referencePerkRecords2;
            
            Reference_Perk__c exceptionRefPerk = new Reference_Perk__c(Name = 'Test 2', RecordTypeId = Id.valueOF(recordTypePerfomanceTech), Perk_Template__c = refPerkTech.Id, Acceptance_Date__c = Date.today(), Reference__c = referenceRecords[0].Id, Applicable_Reference_Module__c = 'CMA');
            insert exceptionRefPerk;
        }
        catch(Exception e){}
        
        Test.stopTest();
    }
}