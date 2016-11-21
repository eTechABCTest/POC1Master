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
    *   Purpose         :   Test class for AddEligiblePerksController.
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
public with sharing class Test_AddEligiblePerksController {
    
    //Constants of record type developer name related to Reference_Perk sObject.
    public static final String PERK_TEMPLATE = 'Perk_Template';
    
    @testSetup
    static void setup() {
        //setup the collection data
        Test_ReferenceRequestController.setupTestData();
    }
    
    static testMethod void testValidateReferenceFunctionality(){
        
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
                recordTypePerfomanceTech = String.valueOf(recordType.Id);
            if(recordType.DeveloperName == PERK_TEMPLATE)
                reccordTypePerkTemplate = String.valueOf(recordType.Id);
        }
       
        Test.startTest();
        
        //Inserting Reference record.
        List<Reference__c> referenceRecords = new List<Reference__c>();
        referenceRecords.add(new Reference__c(Contact_Name__c = contacts[0].Id, Projected_Vetting_Date__c = Date.today(), Dedicated_Advisor__c = userInfo.getUserId(), Membership__c = memberRecord .Id, Reference_Status__c = 'Vetted', Reference_Level__c = 'Ambassador', Reference_Module__c = 'CPRM', Institution__c = account.Id, Reference_Vetter__c = userInfo.getUserId() ));
        referenceRecords.add(new Reference__c(Contact_Name__c = contacts[1].Id, Projected_Vetting_Date__c = Date.today(), Dedicated_Advisor__c = userInfo.getUserId(), Membership__c = memberRecord .Id, Reference_Status__c = 'Vetted', Reference_Level__c = 'Ambassador', Reference_Module__c = 'CPRM', Institution__c = account.Id, Reference_Vetter__c = userInfo.getUserId() ));
        referenceRecords.add(new Reference__c(Contact_Name__c = contacts[2].Id, Projected_Vetting_Date__c = Date.today(), Dedicated_Advisor__c = userInfo.getUserId(), Membership__c = memberRecord .Id, Reference_Status__c = 'Vetted', Reference_Level__c = 'Ambassador', Reference_Module__c = 'CPRM', Institution__c = account.Id, Reference_Vetter__c = userInfo.getUserId() ));
        referenceRecords.add(new Reference__c(Contact_Name__c = contacts[3].Id, Projected_Vetting_Date__c = Date.today(), Dedicated_Advisor__c = userInfo.getUserId(), Membership__c = memberRecord .Id, Reference_Status__c = 'Vetted', Reference_Level__c = 'Ambassador', Reference_Module__c = 'CPRM', Institution__c = account.Id, Reference_Vetter__c = userInfo.getUserId() ));
        referenceRecords.add(new Reference__c(Contact_Name__c = contacts[3].Id, Projected_Vetting_Date__c = Date.today(), Dedicated_Advisor__c = userInfo.getUserId(), Membership__c = memberRecord .Id, Reference_Status__c = 'Vetted', Reference_Level__c = 'Ambassador', Reference_Module__c = 'CPRM', Institution__c = account.Id, Reference_Vetter__c = userInfo.getUserId() ));
        insert referenceRecords;
        
        ApexPages.currentPage().getParameters().put('referenceId', referenceRecords[2].Id );
        
        //Making instatnce of controller.
        AddEligiblePerksController controller = new AddEligiblePerksController();
        
        //Calling Page functions
        controller.addEligiblePerks();
        
        //Assert.
        System.assert(ApexPages.getMessages()[0].getDetail().contains( AddEligiblePerksController.NO_ELIGIBLE_PERK_MESSAGE ));
        
        //Inseting Perk Template Records which can be used by Controller to created its related Reference Perk Records
        List<Reference_Perk__c> perkTemplateRecords = new List<Reference_Perk__c>();
        
        perkTemplateRecords.add(new Reference_Perk__c(Name = 'Test 1', RecordTypeId = reccordTypePerkTemplate,Event_Date__c=Date.today(),  Available_Date__c = Date.today(),Expiration_Date__c = Date.today().addDays(2), Applicable_Reference_Module__c = 'CPRM'));
        perkTemplateRecords.add(new Reference_Perk__c(Name = 'Test 1', RecordTypeId = reccordTypePerkTemplate,Event_Date__c=Date.today(),  Available_Date__c = Date.today(),Expiration_Date__c = Date.today().addDays(3), Applicable_Reference_Module__c = 'CMA'));
        perkTemplateRecords.add(new Reference_Perk__c(Name = 'Test 1', RecordTypeId = reccordTypePerkTemplate,Event_Date__c=Date.today(),  Available_Date__c = Date.today(),Expiration_Date__c = Date.today().addDays(4), Applicable_Reference_Module__c = 'CCC'));
        perkTemplateRecords.add(new Reference_Perk__c(Name = 'Test 1', RecordTypeId = reccordTypePerkTemplate,Event_Date__c=Date.today(),  Available_Date__c = Date.today(),Expiration_Date__c = Date.today().addDays(5), Applicable_Reference_Module__c = 'CMGA'));
        perkTemplateRecords.add(new Reference_Perk__c(Name = 'Test 1', RecordTypeId = reccordTypePerkTemplate,Event_Date__c=Date.today(),  Available_Date__c = Date.today(),Expiration_Date__c = Date.today().addDays(6), Applicable_Reference_Module__c = 'PRM'));
        insert perkTemplateRecords;
        
        ApexPages.currentPage().getParameters().put('referenceId', referenceRecords[0].Id );
        controller = new AddEligiblePerksController();
        controller.addEligiblePerks();
        
        //Assert.
        System.assert(ApexPages.getMessages()[1].getDetail().contains(' have been added'));
        
        //Query on New Refernece Perks Records Created from the Controller
        List<Reference_Perk__c> newRefernecePerks = [select Id, Perk_Template__c, RecordType.DeveloperName from Reference_Perk__c where Reference__c = :referenceRecords[0].Id];
        System.assertEquals(true, newRefernecePerks[0].Perk_Template__c == perkTemplateRecords[0].id);
        System.assertEquals(true, newRefernecePerks[0].RecordType.DeveloperName == Label.PT);
        
        controller.references = new List<Reference__c>();
        controller.addEligiblePerks();
        
        System.assert(ApexPages.getMessages()[0].getDetail().contains( AddEligiblePerksController.NO_ELIGIBLE_PERK_MESSAGE ));
        
        controller.references.add(new Reference__c(Contact_Name__c = contacts[0].Id, Membership__c = memberRecord .Id, Reference_Status__c = 'Vetted', Reference_Level__c = 'Pipeline', Reference_Module__c = 'CPRM', Institution__c = account.Id ));
        
        //Call for to cover catch exception
        try{
            controller.addEligiblePerks();
        }catch(Exception e){}
        
        Test.stopTest();
    }
    
    /*
     *  This static method executes when wrong reference id get from URL. 
     */
    static testMethod void testValidateInvalidReferenId(){
        ApexPages.currentPage().getParameters().put('referenceId', '' );
        
        try{
            //Making instatnce of controller.
            AddEligiblePerksController controller = new AddEligiblePerksController();
        }catch(Exception e){}       
    }
    
    /**
     * @description: simulate the user clicking the "Add to Eligible References" button on a Reference Perk Template record
     **/
    static testMethod void testAddEligiblePerksForTemplate(){
        
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
                recordTypePerfomanceTech = String.valueOf(recordType.Id);
            if(recordType.DeveloperName == PERK_TEMPLATE)
                reccordTypePerkTemplate = String.valueOf(recordType.Id);
        }
        
        //Inseting Perk Template Records which can be used by Controller to created its related Reference Perk Records
        Reference_Perk__c cccPerk = new Reference_Perk__c(Name = 'Test 1', RecordTypeId = reccordTypePerkTemplate,Event_Date__c=Date.today().addDays(-50),  
                                                          Available_Date__c = Date.today().addDays(-50),Expiration_Date__c = Date.today().addDays(-50), Applicable_Reference_Module__c = 'CMA');
        insert cccPerk;
       
        Test.startTest();
        
        //Inserting Reference record.
        List<Reference__c> referenceRecords = new List<Reference__c>();
        referenceRecords.add(new Reference__c(Contact_Name__c = contacts[0].Id, Projected_Vetting_Date__c = Date.today(), Dedicated_Advisor__c = userInfo.getUserId(), Membership__c = memberRecord .Id, Reference_Status__c = 'Vetted', Reference_Level__c = 'Ambassador', Reference_Module__c = 'CMA', Institution__c = account.Id, Reference_Vetter__c = userInfo.getUserId()));
        referenceRecords.add(new Reference__c(Contact_Name__c = contacts[1].Id, Projected_Vetting_Date__c = Date.today(), Dedicated_Advisor__c = userInfo.getUserId(), Membership__c = memberRecord .Id, Reference_Status__c = 'Vetted', Reference_Level__c = 'Ambassador', Reference_Module__c = 'CMA', Institution__c = account.Id, Reference_Vetter__c = userInfo.getUserId()));
        referenceRecords.add(new Reference__c(Contact_Name__c = contacts[2].Id, Projected_Vetting_Date__c = Date.today(), Dedicated_Advisor__c = userInfo.getUserId(), Membership__c = memberRecord .Id, Reference_Status__c = 'Vetted', Reference_Level__c = 'Ambassador', Reference_Module__c = 'CMA', Institution__c = account.Id, Reference_Vetter__c = userInfo.getUserId()));
        referenceRecords.add(new Reference__c(Contact_Name__c = contacts[3].Id, Projected_Vetting_Date__c = Date.today(), Dedicated_Advisor__c = userInfo.getUserId(), Membership__c = memberRecord .Id, Reference_Status__c = 'Vetted', Reference_Level__c = 'Ambassador', Reference_Module__c = 'CMA', Institution__c = account.Id, Reference_Vetter__c = userInfo.getUserId()));
        referenceRecords.add(new Reference__c(Contact_Name__c = contacts[3].Id, Projected_Vetting_Date__c = Date.today(), Dedicated_Advisor__c = userInfo.getUserId(), Membership__c = memberRecord .Id, Reference_Status__c = 'Vetted', Reference_Level__c = 'Ambassador', Reference_Module__c = 'CMA', Institution__c = account.Id, Reference_Vetter__c = userInfo.getUserId()));
        insert referenceRecords;
        
        ApexPages.currentPage().getParameters().put('perkTemplateId', cccPerk.Id );
        
        //Making instatnce of controller.
        AddEligiblePerksController controller = new AddEligiblePerksController();
        
        //Calling Page functions
        controller.addEligiblePerks();
        
        //Assert.
        System.assert(ApexPages.getMessages()[0].getDetail().contains( AddEligiblePerksController.PERK_NOT_VALID ));
        
        
        //update the reference perk so it's available
        cccPerk.Event_Date__c=Date.today();
        cccPerk.Available_Date__c=Date.today();
        cccPerk.Expiration_Date__c=Date.today().addDays(2);
        update cccPerk;
        
        
        ApexPages.currentPage().getParameters().put('perkTemplateId', cccPerk.Id);
        controller = new AddEligiblePerksController();
        controller.addEligiblePerks();
        
        //Assert.
        //system.assertEquals('yes', ApexPages.getMessages()[1].getDetail());
        System.assert(ApexPages.getMessages()[1].getDetail().contains('have been added'));
        
        //Query on New Refernece Perks Records Created from the Controller
        List<Reference_Perk__c> newRefernecePerks = [select Id, Perk_Template__c, RecordType.DeveloperName from Reference_Perk__c where Reference__c = :referenceRecords[0].Id];
        System.assertEquals(true, newRefernecePerks[0].Perk_Template__c == cccPerk.id);
        System.assertEquals(true, newRefernecePerks[0].RecordType.DeveloperName == Label.PT);
        
        controller.references = new List<Reference__c>();
        controller.addEligiblePerks();
        
        System.assert(ApexPages.getMessages()[0].getDetail().contains( AddEligiblePerksController.PERK_NOT_VALID ));
        
        controller.references.add(new Reference__c(Contact_Name__c = contacts[0].Id, Membership__c = memberRecord .Id, Reference_Status__c = 'Vetted', Reference_Level__c = 'Pipeline', Reference_Module__c = 'CMA', Institution__c = account.Id ));
        
        //Call for to cover catch exception
        try{
            controller.addEligiblePerks();
        }catch(Exception e){}
        
        Test.stopTest();
    }
}