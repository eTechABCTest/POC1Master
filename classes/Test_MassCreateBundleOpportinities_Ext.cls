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
/*
    Purpose             :    Test Class for MassCreateBundleOpportinities_Ext
    
    Created By          :    Abhinav Sharma - 09/17/2014 - CR-5272
    
    Last Modified By    :    Abhinav Sharma
    
    Current Version:    :    v1.0
    
    Revision Log:       :    v1.0 - Created
    
    Code Coverage       :    v1.0 - 09/17/2014 - MassCreateBundleOpportinities_Ext - 92%
                                                 MassCreateBundleOppConstants - 100%
                                                 MassCreateBundleOppUtility - 100%
*/
@isTest(seeAllData=false)
private class Test_MassCreateBundleOpportinities_Ext{

    //Test Method to test the "New" button functionality
    static testmethod void testNewButtonFunctionality() {
        
        //Bypassing trigger
        Util.BypassAllTriggers = true;
        Util.IsTest(true);
        
        //Set to hold the record types developer name string literals
        Set<String> recordTypesDeveloperNames = new Set<String>();
        recordTypesDeveloperNames.add(MassCreateBundleOppConstants.PT_MARKETING);
        recordTypesDeveloperNames.add(MassCreateBundleOppConstants.RI_MARKETING);
        recordTypesDeveloperNames.add(MassCreateBundleOppConstants.SOUTHWIND);
        
        //Record Types
        List<RecordType> rdNonBundleType = [Select ID, DeveloperName FROM RecordType Where sObjectType='Opportunity' AND IsActive = true 
                                                AND DeveloperName IN: recordTypesDeveloperNames];
        
        //Assert for the result
        System.assert(rdNonBundleType != null);
        System.assertEquals(3, rdNonBundleType.size());
        
        //list to hold bundle records
        List<Bundle__c> bundles = new List<Bundle__c>();
        
        //Create dummy data for testing Purpose
        Bundle__c bundle = new Bundle__c();
        bundle.Name = 'Test Record 1';
        
        //Insert record
        insert bundle;
        
        //Retrieving out details for the bundle object
        bundles = [SELECT ID, Name, Account__c, Program__c, Total_Count__c, Open_Count__c, Earliest_Stage__c,
                        Earliest_Close__c, Latest_Close__c, Latest_Stage__c, Lost_Count__c, Lost_Value__c,
                        Prorated_Open_Value__c, Won_Count__c, Won_Value__c, Growth__c, Margin__c, Population_Health__c,
                        Total_Value__c, Open_Value__c, OwnerId FROM Bundle__c WHERE ID =: bundle.ID];
                        
        //Asserting for the results
        System.assertEquals(1, bundles.size());
        System.assertEquals(null, bundles[0].Total_Count__c);
        System.assertEquals(null, bundles[0].Total_Value__c);
        System.assertEquals(null, bundles[0].Won_Count__c);
        System.assertEquals(null, bundles[0].Won_Value__c);
        System.assertEquals(null, bundles[0].Lost_Count__c);
        System.assertEquals(null, bundles[0].Lost_Value__c);
        System.assertEquals(null, bundles[0].Open_Count__c);
        System.assertEquals(null, bundles[0].Open_Value__c);
        System.assertEquals(null, bundles[0].Earliest_Close__c);
        System.assertEquals(null, bundles[0].Latest_Close__c);
        System.assertEquals(null, bundles[0].Earliest_Stage__c);
        System.assertEquals(null, bundles[0].Latest_Stage__c);
        System.assertEquals(null, bundles[0].Prorated_Open_Value__c);
        
        //List to hold the opportunity records
        List<Opportunity> bundledOpportunities = new List<Opportunity>();
        
        //Opportunity Instance
        Opportunity opp_1 = new Opportunity(StageName = 'Pending', CloseDate = System.today().addDays(5), Name = 'Test Opp 1', Amount = 2000, 
                                                RecordTypeId = rdNonBundleType[0].ID, Bundle__c = bundle.Id);
        Opportunity opp_2 = new Opportunity(StageName = 'Prospect', CloseDate = System.today().addDays(4), Name = 'Test Opp 2', 
                                                Amount = 3000, RecordTypeId = rdNonBundleType[1].ID);

        //Populating list with opportunity record instances and then try to insert them
        bundledOpportunities.add(opp_1);
        bundledOpportunities.add(opp_2);

        //Enabling the triggers again
        Util.BypassAllTriggers = false;
        
        //Setting flag values
        OpportunityTriggerHelper.EXECUTE_TRIGGER_BEFORE_UPDATE = true;
        OpportunityTriggerHelper.EXECUTE_TRIGGER_AFTER_UPDATE = true;
        
        //Insert Bundled opportunities
        insert bundledOpportunities;
        
        //Retrieving out details for the bundle object
        bundles = [SELECT ID, Name, Account__c, Program__c, Total_Count__c, Open_Count__c, Earliest_Stage__c,
                        Earliest_Close__c, Latest_Close__c, Latest_Stage__c, Lost_Count__c, Lost_Value__c,
                        Prorated_Open_Value__c, Won_Count__c, Won_Value__c, Growth__c, Margin__c, Population_Health__c,
                        Total_Value__c, Open_Value__c, OwnerId FROM Bundle__c WHERE ID =: bundle.ID];
        
        //Asserting for the results
        System.assertEquals(1, bundles.size());
        System.assertEquals(1, bundles[0].Total_Count__c);
        System.assertEquals(2000, bundles[0].Total_Value__c);
        System.assertEquals(0, bundles[0].Won_Count__c);
        System.assertEquals(0, bundles[0].Won_Value__c);
        System.assertEquals(0, bundles[0].Lost_Count__c);
        System.assertEquals(0, bundles[0].Lost_Value__c);
        System.assertEquals(1, bundles[0].Open_Count__c);
        System.assertEquals(2000, bundles[0].Open_Value__c);
        System.assertEquals(System.today().addDays(5), bundles[0].Earliest_Close__c);
        System.assertEquals(System.today().addDays(5), bundles[0].Latest_Close__c);
        System.assertEquals('Pending', bundles[0].Earliest_Stage__c);
        System.assertEquals('Pending', bundles[0].Latest_Stage__c);
        System.assertEquals(0, bundles[0].Prorated_Open_Value__c);
        
        //Disabling triggers again
        Util.BypassAllTriggers = true;
        
        //Start Testing from here
        Test.startTest();
        
        //Loading the VF page
        ApexPages.StandardController sc = new ApexPages.StandardController(bundle);
        MassCreateBundleOpportinities_Ext controller = new MassCreateBundleOpportinities_Ext(sc);
        
        //Asserting for the results
        System.assertEquals(1, controller.existingBundledOpportunities.size());
        System.assertEquals(bundledOpportunities[0].ID, controller.existingBundledOpportunities[0].opportunity.ID);
        
        //Calling methods
        controller.getOppRecordTypes();
        
        //Click on "New" button
        controller.navigateToNewOppRecordTypeSelection();
        
        //Select "PT Marketing" as a choice from the select option list
        controller.selectedRdType = MassCreateBundleOppConstants.PT_MARKETING;
        
        //Click on continue button
        controller.naviagteToOpportunityEditPage();
        
        //Populating opportunity instance on the standard opportunity edit page
        Opportunity opp_3 = new Opportunity(StageName = 'Outreach', CloseDate = System.today().addDays(4), Name = 'Test Opp 3', 
                                                Amount = 3000, RecordTypeId = rdNonBundleType[1].ID);
        
        //Enabling the triggers again
        Util.BypassAllTriggers = false;
        
        //Setting flag values
        OpportunityTriggerHelper.EXECUTE_TRIGGER_BEFORE_UPDATE = true;
        OpportunityTriggerHelper.EXECUTE_TRIGGER_AFTER_UPDATE = true;
        
        //Insert opportunity
        insert opp_3;
               
        //Test will stop Here
        Test.stopTest();    
        
        //Setting flag values
        OpportunityTriggerHelper.EXECUTE_TRIGGER_BEFORE_UPDATE = true;
        OpportunityTriggerHelper.EXECUTE_TRIGGER_AFTER_UPDATE = true;
        
        //Setting current page URL parameters
        ApexPages.currentPage().getParameters().put(MassCreateBundleOppConstants.ID_Paramter, bundle.ID);
        ApexPages.currentPage().getParameters().put(MassCreateBundleOppConstants.NEW_ID, opp_3.ID);
        
        //Calling page action method for keeping the page data in sync
        controller.linkingNewOpportunityToBundle();
        
        //Loading the VF page
        ApexPages.StandardController sc_1 = new ApexPages.StandardController(bundle);
        MassCreateBundleOpportinities_Ext controller_1 = new MassCreateBundleOpportinities_Ext(sc_1);
        
        //Asserting for the results
        System.assertEquals(2, controller_1.existingBundledOpportunities.size());
        
        //Retrieving out details for the bundle object
        bundles = [SELECT ID, Name, Account__c, Program__c, Total_Count__c, Open_Count__c, Earliest_Stage__c,
                        Earliest_Close__c, Latest_Close__c, Latest_Stage__c, Lost_Count__c, Lost_Value__c,
                        Prorated_Open_Value__c, Won_Count__c, Won_Value__c, Growth__c, Margin__c, Population_Health__c,
                        Total_Value__c, Open_Value__c, OwnerId FROM Bundle__c WHERE ID =: bundle.ID];
    
        //Asserting for the results
        System.assertEquals(1, bundles.size());
        System.assertEquals(2, bundles[0].Total_Count__c);
        System.assertEquals(5000, bundles[0].Total_Value__c);
        System.assertEquals(0, bundles[0].Won_Count__c);
        System.assertEquals(0, bundles[0].Won_Value__c);
        System.assertEquals(0, bundles[0].Lost_Count__c);
        System.assertEquals(0, bundles[0].Lost_Value__c);
        System.assertEquals(2, bundles[0].Open_Count__c);
        System.assertEquals(5000, bundles[0].Open_Value__c);
        System.assertEquals(System.today().addDays(4), bundles[0].Earliest_Close__c);
        System.assertEquals(System.today().addDays(5), bundles[0].Latest_Close__c);
        System.assertEquals('Pending', bundles[0].Earliest_Stage__c);
        System.assertEquals('Outreach', bundles[0].Latest_Stage__c);
        System.assertEquals(0, bundles[0].Prorated_Open_Value__c);
    }
    
    //Test Method to test the "Add" button functionality
    static testmethod void testAddButtonFunctionality() {
        
        //Bypassing trigger
        Util.BypassAllTriggers = true;
        Util.IsTest(true);
        
        //Set to hold the record types developer name string literals
        Set<String> recordTypesDeveloperNames = new Set<String>();
        recordTypesDeveloperNames.add(MassCreateBundleOppConstants.PT_MARKETING);
        recordTypesDeveloperNames.add(MassCreateBundleOppConstants.RI_MARKETING);
        recordTypesDeveloperNames.add(MassCreateBundleOppConstants.SOUTHWIND);
        
        //Record Types
        List<RecordType> rdNonBundleType = [Select ID, DeveloperName FROM RecordType Where sObjectType='Opportunity' AND IsActive = true 
                                                AND DeveloperName IN: recordTypesDeveloperNames];
        
        //Assert for the result
        System.assert(rdNonBundleType != null);
        System.assertEquals(3, rdNonBundleType.size());
        
        //list of bundle record
        List<Bundle__c> bundles = new List<Bundle__c>();
        
        //Create dummy data for testing Purpose
        Bundle__c bundle = new Bundle__c();
        bundle.Name = 'Test Record 1';
        
        //Insert record
        insert bundle;
        
        //Retrieving out details for the bundle object
        bundles = [SELECT ID, Name, Account__c, Program__c, Total_Count__c, Open_Count__c, Earliest_Stage__c,
                        Earliest_Close__c, Latest_Close__c, Latest_Stage__c, Lost_Count__c, Lost_Value__c,
                        Prorated_Open_Value__c, Won_Count__c, Won_Value__c, Growth__c, Margin__c, Population_Health__c,
                        Total_Value__c, Open_Value__c, OwnerId FROM Bundle__c WHERE ID =: bundle.ID];
        
        //Asserting for the results
        System.assertEquals(1, bundles.size());
        System.assertEquals(null, bundles[0].Total_Count__c);
        System.assertEquals(null, bundles[0].Total_Value__c);
        System.assertEquals(null, bundles[0].Won_Count__c);
        System.assertEquals(null, bundles[0].Won_Value__c);
        System.assertEquals(null, bundles[0].Lost_Count__c);
        System.assertEquals(null, bundles[0].Lost_Value__c);
        System.assertEquals(null, bundles[0].Open_Count__c);
        System.assertEquals(null, bundles[0].Open_Value__c);
        System.assertEquals(null, bundles[0].Earliest_Close__c);
        System.assertEquals(null, bundles[0].Latest_Close__c);
        System.assertEquals(null, bundles[0].Earliest_Stage__c);
        System.assertEquals(null, bundles[0].Latest_Stage__c);
        System.assertEquals(null, bundles[0].Prorated_Open_Value__c);
        
        //List to hold the opportunity records
        List<Opportunity> bundledOpportunities = new List<Opportunity>();
        
        //Opportunity Instance
        Opportunity opp_1 = new Opportunity(StageName = 'Pending', CloseDate = System.today().addDays(5), Name = 'Test Opp 1', Amount = 2000, 
                                                RecordTypeId = rdNonBundleType[0].ID, Bundle__c = bundle.Id);
        Opportunity opp_2 = new Opportunity(StageName = 'Prospect', CloseDate = System.today().addDays(4), Name = 'Test Opp 2', 
                                                Amount = 3000, RecordTypeId = rdNonBundleType[1].ID);

        //Populating list with opportunity record instances and then try to insert them
        bundledOpportunities.add(opp_1);
        bundledOpportunities.add(opp_2);

        //Enabling the triggers again
        Util.BypassAllTriggers = false;
        
        //Setting flag values
        OpportunityTriggerHelper.EXECUTE_TRIGGER_BEFORE_UPDATE = true;
        OpportunityTriggerHelper.EXECUTE_TRIGGER_AFTER_UPDATE = true;
        
        //Insert Bundled opportunities
        insert bundledOpportunities;
        
        //Retrieving out details for the bundle object
        bundles = [SELECT ID, Name, Account__c, Program__c, Total_Count__c, Open_Count__c, Earliest_Stage__c,
                        Earliest_Close__c, Latest_Close__c, Latest_Stage__c, Lost_Count__c, Lost_Value__c,
                        Prorated_Open_Value__c, Won_Count__c, Won_Value__c, Growth__c, Margin__c, Population_Health__c,
                        Total_Value__c, Open_Value__c, OwnerId FROM Bundle__c WHERE ID =: bundle.ID];
    
         //Asserting for the results
        System.assertEquals(1, bundles.size());
        System.assertEquals(1, bundles[0].Total_Count__c);
        System.assertEquals(2000, bundles[0].Total_Value__c);
        System.assertEquals(0, bundles[0].Won_Count__c);
        System.assertEquals(0, bundles[0].Won_Value__c);
        System.assertEquals(0, bundles[0].Lost_Count__c);
        System.assertEquals(0, bundles[0].Lost_Value__c);
        System.assertEquals(1, bundles[0].Open_Count__c);
        System.assertEquals(2000, bundles[0].Open_Value__c);
        System.assertEquals(System.today().addDays(5), bundles[0].Earliest_Close__c);
        System.assertEquals(System.today().addDays(5), bundles[0].Latest_Close__c);
        System.assertEquals('Pending', bundles[0].Earliest_Stage__c);
        System.assertEquals('Pending', bundles[0].Latest_Stage__c);
        System.assertEquals(0, bundles[0].Prorated_Open_Value__c);
        
        //Disabling triggers again
        Util.BypassAllTriggers = true;
        
        //Start Testing from here
        Test.startTest();
        
        //Loading the VF page
        ApexPages.StandardController sc = new ApexPages.StandardController(bundle);
        MassCreateBundleOpportinities_Ext controller = new MassCreateBundleOpportinities_Ext(sc);
        
        //Asserting for the results
        System.assertEquals(1, controller.existingBundledOpportunities.size());
        System.assertEquals(bundledOpportunities[0].ID, controller.existingBundledOpportunities[0].opportunity.ID);
    
        //Click on the "Add" button methods
        controller.navigateToAddExistingOppPage();
        
        //Selecting the existing Opportunity via opportunity lookup window
        controller.bSibling.From__c = bundledOpportunities[1].ID;
        
        //Enabling the triggers again
        Util.BypassAllTriggers = false;
        
        //Click on the "Add" button
        controller.addSelectedOpportunityToBundle();
        
        //Loading the VF page
        ApexPages.StandardController sc_1 = new ApexPages.StandardController(bundle);
        MassCreateBundleOpportinities_Ext controller_1 = new MassCreateBundleOpportinities_Ext(sc_1);
        
        //Asserting for the results
        System.assertEquals(2, controller.existingBundledOpportunities.size());
        
        //Retrieving out details for the bundle object
        bundles = [SELECT ID, Name, Account__c, Program__c, Total_Count__c, Open_Count__c, Earliest_Stage__c,
                        Earliest_Close__c, Latest_Close__c, Latest_Stage__c, Lost_Count__c, Lost_Value__c,
                        Prorated_Open_Value__c, Won_Count__c, Won_Value__c, Growth__c, Margin__c, Population_Health__c,
                        Total_Value__c, Open_Value__c, OwnerId FROM Bundle__c WHERE ID =: bundle.ID];
    
        //Asserting for the results
        System.assertEquals(1, bundles.size());
        System.assertEquals(2, bundles[0].Total_Count__c);
        System.assertEquals(5000, bundles[0].Total_Value__c);
        System.assertEquals(0, bundles[0].Won_Count__c);
        System.assertEquals(0, bundles[0].Won_Value__c);
        System.assertEquals(0, bundles[0].Lost_Count__c);
        System.assertEquals(0, bundles[0].Lost_Value__c);
        System.assertEquals(2, bundles[0].Open_Count__c);
        System.assertEquals(5000, bundles[0].Open_Value__c);
        System.assertEquals(System.today().addDays(4), bundles[0].Earliest_Close__c);
        System.assertEquals(System.today().addDays(5), bundles[0].Latest_Close__c);
        System.assertEquals('Pending', bundles[0].Earliest_Stage__c);
        System.assertEquals('Prospect', bundles[0].Latest_Stage__c);
        System.assertEquals(0, bundles[0].Prorated_Open_Value__c);
        
        //Current logged in user click on the add button again but this time select an opportunity via lookup window which already have tagged to the bundle record
        //Click on the "Add" button methods
        controller_1.navigateToAddExistingOppPage();
        
        //Selecting the existing Opportunity via opportunity lookup window
        controller_1.bSibling.From__c = bundledOpportunities[1].ID;
        
        //Click on the "Add" button
        try {
            controller_1.addSelectedOpportunityToBundle();
        } catch(Exception ex) {
            System.assert(ex.getMessage().contains(System.Label.Message_Opp_Already_Added));
        }
        
        //Stop the test here
        Test.stopTest();
    }
    
    //Test Method to test the "Remove" button functionality
    static testmethod void testRemoveAndSaveButtonFunctionality() {
        
        //Bypassing trigger
        Util.BypassAllTriggers = true;
        Util.IsTest(true);
        
        //Set to hold the record types developer name string literals
        Set<String> recordTypesDeveloperNames = new Set<String>();
        recordTypesDeveloperNames.add(MassCreateBundleOppConstants.PT_MARKETING);
        recordTypesDeveloperNames.add(MassCreateBundleOppConstants.RI_MARKETING);
        recordTypesDeveloperNames.add(MassCreateBundleOppConstants.SOUTHWIND);
        
        //Record Types
        List<RecordType> rdNonBundleType = [Select ID, DeveloperName FROM RecordType Where sObjectType='Opportunity' AND IsActive = true 
                                                AND DeveloperName IN: recordTypesDeveloperNames];
        
        //Assert for the result
        System.assert(rdNonBundleType != null);
        System.assertEquals(3, rdNonBundleType.size());
        
        //List to hold the Bundle records
        List<Bundle__c> bundles = new List<Bundle__c>();
        
        //Create dummy data for testing Purpose
        Bundle__c bundle = new Bundle__c();
        bundle.Name = 'Test Record 1';
        
        //Insert record
        insert bundle;
        
        //Retrieving out details for the bundle object
        bundles = [SELECT ID, Name, Account__c, Program__c, Total_Count__c, Open_Count__c, Earliest_Stage__c,
                        Earliest_Close__c, Latest_Close__c, Latest_Stage__c, Lost_Count__c, Lost_Value__c,
                        Prorated_Open_Value__c, Won_Count__c, Won_Value__c, Growth__c, Margin__c, Population_Health__c,
                        Total_Value__c, Open_Value__c, OwnerId FROM Bundle__c WHERE ID =: bundle.ID];
                        
        //Asserting for the results
        System.assertEquals(1, bundles.size());
        System.assertEquals(null, bundles[0].Total_Count__c);
        System.assertEquals(null, bundles[0].Total_Value__c);
        System.assertEquals(null, bundles[0].Won_Count__c);
        System.assertEquals(null, bundles[0].Won_Value__c);
        System.assertEquals(null, bundles[0].Lost_Count__c);
        System.assertEquals(null, bundles[0].Lost_Value__c);
        System.assertEquals(null, bundles[0].Open_Count__c);
        System.assertEquals(null, bundles[0].Open_Value__c);
        System.assertEquals(null, bundles[0].Earliest_Close__c);
        System.assertEquals(null, bundles[0].Latest_Close__c);
        System.assertEquals(null, bundles[0].Earliest_Stage__c);
        System.assertEquals(null, bundles[0].Latest_Stage__c);
        System.assertEquals(null, bundles[0].Prorated_Open_Value__c);
        
        //List to hold the opportunity records
        List<Opportunity> bundledOpportunities = new List<Opportunity>();
        
        //Opportunity Instance
        Opportunity opp_1 = new Opportunity(StageName = 'Pending', CloseDate = System.today().addDays(5), Name = 'Test Opp 1', Amount = 2000, 
                                                RecordTypeId = rdNonBundleType[0].ID, Bundle__c = bundle.Id);
        Opportunity opp_2 = new Opportunity(StageName = 'Prospect', CloseDate = System.today().addDays(3), Name = 'Test Opp 2', 
                                                Amount = 3000, RecordTypeId = rdNonBundleType[1].ID, Bundle__c = bundle.Id);
        Opportunity opp_3 = new Opportunity(StageName = 'Outreach', CloseDate = System.today().addDays(4), Name = 'Test Opp 3', Amount = 4000, 
                                                RecordTypeId = rdNonBundleType[0].ID, Bundle__c = bundle.Id);
        
        //Populating list with opportunity record instances and then try to insert them
        bundledOpportunities.add(opp_1);
        bundledOpportunities.add(opp_2);
        bundledOpportunities.add(opp_3);

        //Enabling the triggers again
        Util.BypassAllTriggers = false;
        
        //Setting flag values
        OpportunityTriggerHelper.EXECUTE_TRIGGER_BEFORE_UPDATE = true;
        OpportunityTriggerHelper.EXECUTE_TRIGGER_AFTER_UPDATE = true;
        
        //Insert Bundled opportunities
        insert bundledOpportunities;
            
        //Disabling triggers again
        Util.BypassAllTriggers = true;
        
        //Start Testing from here
        Test.startTest();
        
        //Loading the VF page
        ApexPages.StandardController sc = new ApexPages.StandardController(bundle);
        MassCreateBundleOpportinities_Ext controller = new MassCreateBundleOpportinities_Ext(sc);
        
        //Asserting for the results
        System.assertEquals(3, controller.existingBundledOpportunities.size());
        
        //Retrieving out details for the bundle object
        bundles = [SELECT ID, Name, Account__c, Program__c, Total_Count__c, Open_Count__c, Earliest_Stage__c,
                        Earliest_Close__c, Latest_Close__c, Latest_Stage__c, Lost_Count__c, Lost_Value__c,
                        Prorated_Open_Value__c, Won_Count__c, Won_Value__c, Growth__c, Margin__c, Population_Health__c,
                        Total_Value__c, Open_Value__c, OwnerId FROM Bundle__c WHERE ID =: bundle.ID];
    
        //Asserting for the results
        System.assertEquals(1, bundles.size());
        System.assertEquals(3, bundles[0].Total_Count__c);
        System.assertEquals(9000, bundles[0].Total_Value__c);
        System.assertEquals(0, bundles[0].Won_Count__c);
        System.assertEquals(0, bundles[0].Won_Value__c);
        System.assertEquals(0, bundles[0].Lost_Count__c);
        System.assertEquals(0, bundles[0].Lost_Value__c);
        System.assertEquals(3, bundles[0].Open_Count__c);
        System.assertEquals(9000, bundles[0].Open_Value__c);
        System.assertEquals(System.today().addDays(3), bundles[0].Earliest_Close__c);
        System.assertEquals(System.today().addDays(5), bundles[0].Latest_Close__c);
        System.assertEquals('Pending', bundles[0].Earliest_Stage__c);
        System.assertEquals('Outreach', bundles[0].Latest_Stage__c);
        System.assertEquals(0, bundles[0].Prorated_Open_Value__c);
        
        //Select any two records out of 3
        controller.existingBundledOpportunities[0].selected = true;
        controller.existingBundledOpportunities[2].selected = true;
        
        //Enabling triggers again
        Util.BypassAllTriggers = false;
        
        //Click on "Remove" button
        controller.removeSelectedBundledOpportunities();
        
        //Asserting for the results
        System.assertEquals(1, controller.existingBundledOpportunities.size());
        
        //Retrieving out details for the bundle object
        bundles = [SELECT ID, Name, Account__c, Program__c, Total_Count__c, Open_Count__c, Earliest_Stage__c,
                        Earliest_Close__c, Latest_Close__c, Latest_Stage__c, Lost_Count__c, Lost_Value__c,
                        Prorated_Open_Value__c, Won_Count__c, Won_Value__c, Growth__c, Margin__c, Population_Health__c,
                        Total_Value__c, Open_Value__c, OwnerId FROM Bundle__c WHERE ID =: bundle.ID];
    
        //Asserting for the results
        System.assertEquals(1, bundles.size());
        System.assertEquals(1, bundles[0].Total_Count__c);
        System.assertEquals(4000, bundles[0].Total_Value__c);
        System.assertEquals(0, bundles[0].Won_Count__c);
        System.assertEquals(0, bundles[0].Won_Value__c);
        System.assertEquals(0, bundles[0].Lost_Count__c);
        System.assertEquals(0, bundles[0].Lost_Value__c);
        System.assertEquals(1, bundles[0].Open_Count__c);
        System.assertEquals(4000, bundles[0].Open_Value__c);
        System.assertEquals(System.today().addDays(4), bundles[0].Earliest_Close__c);
        System.assertEquals(System.today().addDays(4), bundles[0].Latest_Close__c);
        System.assertEquals('Outreach', bundles[0].Earliest_Stage__c);
        System.assertEquals('Outreach', bundles[0].Latest_Stage__c);
        System.assertEquals(0, bundles[0].Prorated_Open_Value__c);
        
        //Stop the test here
        Test.stopTest();
        
        //Click on "Save" button
        controller.saveAll();
        
        //Disable triggers
        Util.BypassAllTriggers = true;
        
        //Setting stageName value to a specific one which is having dependencies over other field before updating the record
        controller.existingBundledOpportunities[0].Opportunity.StageName = 'Active in FastTrack';
        
        //Click on "Save" button
        try {
            controller.saveAll();
        } catch(Exception ex) {}
        
        //Loading the VF page
        ApexPages.StandardController sc_1 = new ApexPages.StandardController(bundle);
        MassCreateBundleOpportinities_Ext controller_1 = new MassCreateBundleOpportinities_Ext(sc_1);
        
        //Setting stageName value to a specific one which is having dependencies over other field before updating the record
        controller_1.existingBundledOpportunities[0].Opportunity.StageName = null;
        
        //Click on "Save" button
        try {
            controller_1.saveAll();
        } catch(Exception ex) {}
    
        //Loading the VF page
        ApexPages.StandardController sc_2 = new ApexPages.StandardController(bundle);
        MassCreateBundleOpportinities_Ext controller_2 = new MassCreateBundleOpportinities_Ext(sc_2);
        
        //Setting stageName value to a specific one which is having dependencies over other field before updating the record
        controller_2.existingBundledOpportunities[0].selected = true;
        controller_2.existingBundledOpportunities[0].Opportunity.StageName = 'Active in FastTrack';
        try {
            controller_2.removeSelectedBundledOpportunities();
        } catch(Exception ex) {}
    }
    
    //Test Method to test the "Clone" button functionality
    static testmethod void testCloneAndQuickSaveButtonFunctionality() {
        
        //Bypassing trigger
        Util.BypassAllTriggers = true;
        Util.IsTest(true);
        
        //Set to hold the record types developer name string literals
        Set<String> recordTypesDeveloperNames = new Set<String>();
        recordTypesDeveloperNames.add(MassCreateBundleOppConstants.PT_MARKETING);
        recordTypesDeveloperNames.add(MassCreateBundleOppConstants.RI_MARKETING);
        recordTypesDeveloperNames.add(MassCreateBundleOppConstants.SOUTHWIND);
        
        //Record Types
        List<RecordType> rdNonBundleType = [Select ID, DeveloperName FROM RecordType Where sObjectType='Opportunity' AND IsActive = true 
                                                AND DeveloperName IN: recordTypesDeveloperNames];
        
        //Assert for the result
        System.assert(rdNonBundleType != null);
        System.assertEquals(3, rdNonBundleType.size());
        
        //List to hold the Bundle records
        List<Bundle__c> bundles = new List<Bundle__c>();
        
        //Create dummy data for testing Purpose
        Bundle__c bundle = new Bundle__c();
        bundle.Name = 'Test Record 1';
        
        //Insert record
        insert bundle;
        
        //Retrieving out details for the bundle object
        bundles = [SELECT ID, Name, Account__c, Program__c, Total_Count__c, Open_Count__c, Earliest_Stage__c,
                        Earliest_Close__c, Latest_Close__c, Latest_Stage__c, Lost_Count__c, Lost_Value__c,
                        Prorated_Open_Value__c, Won_Count__c, Won_Value__c, Growth__c, Margin__c, Population_Health__c,
                        Total_Value__c, Open_Value__c, OwnerId FROM Bundle__c WHERE ID =: bundle.ID];
                        
        //Asserting for the results
        System.assertEquals(1, bundles.size());
        System.assertEquals(null, bundles[0].Total_Count__c);
        System.assertEquals(null, bundles[0].Total_Value__c);
        System.assertEquals(null, bundles[0].Won_Count__c);
        System.assertEquals(null, bundles[0].Won_Value__c);
        System.assertEquals(null, bundles[0].Lost_Count__c);
        System.assertEquals(null, bundles[0].Lost_Value__c);
        System.assertEquals(null, bundles[0].Open_Count__c);
        System.assertEquals(null, bundles[0].Open_Value__c);
        System.assertEquals(null, bundles[0].Earliest_Close__c);
        System.assertEquals(null, bundles[0].Latest_Close__c);
        System.assertEquals(null, bundles[0].Earliest_Stage__c);
        System.assertEquals(null, bundles[0].Latest_Stage__c);
        System.assertEquals(null, bundles[0].Prorated_Open_Value__c);
        
        //List to hold the opportunity records
        List<Opportunity> bundledOpportunities = new List<Opportunity>();
        
        //Opportunity Instance
        Opportunity opp_1 = new Opportunity(StageName = 'Pending', CloseDate = System.today().addDays(5), Name = 'Test Opp 1', Amount = 2000, 
                                                RecordTypeId = rdNonBundleType[0].ID, Bundle__c = bundle.Id);
        Opportunity opp_2 = new Opportunity(StageName = 'Prospect', CloseDate = System.today().addDays(3), Name = 'Test Opp 2', 
                                                Amount = 3000, RecordTypeId = rdNonBundleType[1].ID, Bundle__c = bundle.Id);
        Opportunity opp_3 = new Opportunity(StageName = 'Prospect', CloseDate = System.today().addDays(4), Name = 'Test Opp 3', Amount = 4000, 
                                                RecordTypeId = rdNonBundleType[0].ID, Bundle__c = bundle.Id);
        
        //Populating list with opportunity record instances and then try to insert them
        bundledOpportunities.add(opp_1);
        bundledOpportunities.add(opp_2);
        bundledOpportunities.add(opp_3);

        //Enabling the triggers again
        Util.BypassAllTriggers = false;
        
        //Setting flag values
        OpportunityTriggerHelper.EXECUTE_TRIGGER_BEFORE_UPDATE = true;
        OpportunityTriggerHelper.EXECUTE_TRIGGER_AFTER_UPDATE = true;
        
        //Insert Bundled opportunities
        insert bundledOpportunities;
        
        //Disabling triggers again
        Util.BypassAllTriggers = true;
        
        //Start Testing from here
        Test.startTest();
        
        //Loading the VF page
        ApexPages.StandardController sc = new ApexPages.StandardController(bundle);
        MassCreateBundleOpportinities_Ext controller = new MassCreateBundleOpportinities_Ext(sc);
        
        //Asserting for the results
        System.assertEquals(3, controller.existingBundledOpportunities.size());
        
        //Retrieving out details for the bundle object
        bundles = [SELECT ID, Name, Account__c, Program__c, Total_Count__c, Open_Count__c, Earliest_Stage__c,
                        Earliest_Close__c, Latest_Close__c, Latest_Stage__c, Lost_Count__c, Lost_Value__c,
                        Prorated_Open_Value__c, Won_Count__c, Won_Value__c, Growth__c, Margin__c, Population_Health__c,
                        Total_Value__c, Open_Value__c, OwnerId FROM Bundle__c WHERE ID =: bundle.ID];
    
        //Asserting for the results
        System.assertEquals(1, bundles.size());
        System.assertEquals(3, bundles[0].Total_Count__c);
        System.assertEquals(9000, bundles[0].Total_Value__c);
        System.assertEquals(0, bundles[0].Won_Count__c);
        System.assertEquals(0, bundles[0].Won_Value__c);
        System.assertEquals(0, bundles[0].Lost_Count__c);
        System.assertEquals(0, bundles[0].Lost_Value__c);
        System.assertEquals(3, bundles[0].Open_Count__c);
        System.assertEquals(9000, bundles[0].Open_Value__c);
        System.assertEquals(System.today().addDays(3), bundles[0].Earliest_Close__c);
        System.assertEquals(System.today().addDays(5), bundles[0].Latest_Close__c);
        System.assertEquals('Pending', bundles[0].Earliest_Stage__c);
        System.assertEquals('Prospect', bundles[0].Latest_Stage__c);
        System.assertEquals(0, bundles[0].Prorated_Open_Value__c);
        
        //Select any record for clonning
        controller.selectedRowNo = 1;
        
        //Changing stage on the page
        controller.changeStageNameInWrapperList();
        
        //Enabling triggers again
        Util.BypassAllTriggers = false;
        
        //Click on "Clone" button
        controller.cloneBundledOpportunity();
        
        //Asserting for the results
        System.assertEquals(4, controller.existingBundledOpportunities.size());
        
        //Retrieving out details for the bundle object
        bundles = [SELECT ID, Name, Account__c, Program__c, Total_Count__c, Open_Count__c, Earliest_Stage__c,
                        Earliest_Close__c, Latest_Close__c, Latest_Stage__c, Lost_Count__c, Lost_Value__c,
                        Prorated_Open_Value__c, Won_Count__c, Won_Value__c, Growth__c, Margin__c, Population_Health__c,
                        Total_Value__c, Open_Value__c, OwnerId FROM Bundle__c WHERE ID =: bundle.ID];
    
        //Asserting for the results
        System.assertEquals(1, bundles.size());
        System.assertEquals(4, bundles[0].Total_Count__c);
        System.assertEquals(13000, bundles[0].Total_Value__c);
        System.assertEquals(0, bundles[0].Won_Count__c);
        System.assertEquals(0, bundles[0].Won_Value__c);
        System.assertEquals(0, bundles[0].Lost_Count__c);
        System.assertEquals(0, bundles[0].Lost_Value__c);
        System.assertEquals(4, bundles[0].Open_Count__c);
        System.assertEquals(13000, bundles[0].Open_Value__c);
        System.assertEquals(System.today().addDays(3), bundles[0].Earliest_Close__c);
        System.assertEquals(System.today().addDays(5), bundles[0].Latest_Close__c);
        System.assertEquals('Pending', bundles[0].Earliest_Stage__c);
        System.assertEquals('Prospect', bundles[0].Latest_Stage__c);
        System.assertEquals(0, bundles[0].Prorated_Open_Value__c);
        
        //Stop the test here
        Test.stopTest();
        
        //Changing the amount value on the page and click on quick save button
        controller.existingBundledOpportunities[0].Opportunity.Amount = 3000;
        
        //Click on Quick save button to commit the changes to the database
        controller.quickSaveAll();
        
        //Retrieving out details for the bundle object
        bundles = [SELECT ID, Name, Account__c, Program__c, Total_Count__c, Open_Count__c, Earliest_Stage__c,
                        Earliest_Close__c, Latest_Close__c, Latest_Stage__c, Lost_Count__c, Lost_Value__c,
                        Prorated_Open_Value__c, Won_Count__c, Won_Value__c, Growth__c, Margin__c, Population_Health__c,
                        Total_Value__c, Open_Value__c, OwnerId FROM Bundle__c WHERE ID =: bundle.ID];
    
        //Asserting for the results
        System.assertEquals(1, bundles.size());
        System.assertEquals(4, bundles[0].Total_Count__c);
        System.assertEquals(14000, bundles[0].Total_Value__c);
        System.assertEquals(0, bundles[0].Won_Count__c);
        System.assertEquals(0, bundles[0].Won_Value__c);
        System.assertEquals(0, bundles[0].Lost_Count__c);
        System.assertEquals(0, bundles[0].Lost_Value__c);
        System.assertEquals(4, bundles[0].Open_Count__c);
        System.assertEquals(14000, bundles[0].Open_Value__c);
        System.assertEquals(System.today().addDays(3), bundles[0].Earliest_Close__c);
        System.assertEquals(System.today().addDays(5), bundles[0].Latest_Close__c);
        System.assertEquals('Pending', bundles[0].Earliest_Stage__c);
        System.assertEquals('Prospect', bundles[0].Latest_Stage__c);
        System.assertEquals(0, bundles[0].Prorated_Open_Value__c);
        
        //Disable triggers
        Util.BypassAllTriggers = true;
        
        //Setting stageName value to a specific one which is having dependencies over other field before updating the record
        controller.existingBundledOpportunities[0].Opportunity.StageName = 'Active in FastTrack';
        
        //Click on "Save" button
        try {
            controller.quickSaveAll();
        } catch(Exception ex) {}
        
        //Setting stageName value to a specific one which is having dependencies over other field before updating the record
        controller.existingBundledOpportunities[0].Opportunity.StageName = 'Active in FastTrack';
        controller.selectedRowNo = 0;
        
        //Click on "Clone" button
        controller.cloneBundledOpportunity();
        
        //By any means user have selected an invalid selection for the stage name field
        controller.existingBundledOpportunities[controller.selectedRowNo].opportunity.StageName = 'XYZ';
        try {
            //Changing stage on the page
            controller.changeStageNameInWrapperList();
        } catch(Exception ex) {
            System.assert(ex.getMessage().contains(System.Label.INVALID_STAGE_VALUE));
        } 
    }
    
    //Test Method to test various other miscellaneous behaviours of the VF page
    static testmethod void testMiscellaneousbehaviours() {
    
        //Bypassing trigger
        Util.BypassAllTriggers = true;
        Util.IsTest(true);
        
        //Loading page without passing bundle record ID value in the URL
        Bundle__c bundle = new Bundle__c();
        
        //Test will stop here
        Test.startTest();
        
        try {
        
            //Loading the VF page
            ApexPages.StandardController sc = new ApexPages.StandardController(bundle);
            MassCreateBundleOpportinities_Ext controller = new MassCreateBundleOpportinities_Ext(sc);
            
        } catch(Exception ex) {
            System.assert(ex.getMessage().contains(System.Label.Message_No_Bundle_Found));
        }
         
        //Test will stop here
        Test.stopTest();
    }
    
    //Test Method to test various other miscellaneous behaviours of the VF page
    static testmethod void testMiscellaneousbehaviours_1() {
    
        //Bypassing trigger
        Util.BypassAllTriggers = true;
        Util.IsTest(true);
        
        //Create dummy data for testing Purpose
        Bundle__c testBundle = new Bundle__c();
        insert testBundle;
        
        //Start test from here
        Test.startTest();
        
        //Loading the VF page
        ApexPages.StandardController sc_2 = new ApexPages.StandardController(testBundle);
        MassCreateBundleOpportinities_Ext controller_2 = new MassCreateBundleOpportinities_Ext(sc_2);
        
        //By any means user by pass the record type selection before proceeding further to new Opportunity standard page
        controller_2.selectedRdType = '';
        try {
            controller_2.naviagteToOpportunityEditPage();     
        } catch(Exception ex) {
            System.assert(ex.getMessage().contains(System.Label.Message_Wrong_WIth_RdType_Selection));
        }
        
        //Loading the VF page
        ApexPages.StandardController sc_3 = new ApexPages.StandardController(testBundle);
        MassCreateBundleOpportinities_Ext controller_3 = new MassCreateBundleOpportinities_Ext(sc_3);
        
        //By any means user have selected record type selection other than desired choices
        controller_3.selectedRdType = 'XYZ';
        try {
            controller_3.naviagteToOpportunityEditPage();     
        } catch(Exception ex) {
            System.assert(ex.getMessage().contains(System.Label.Message_Record_Type_Not_Exists));
        }
        
        //Loading the VF page
        ApexPages.StandardController sc_4 = new ApexPages.StandardController(testBundle);
        MassCreateBundleOpportinities_Ext controller_4 = new MassCreateBundleOpportinities_Ext(sc_4);
        
        //Setting paramters in the URL so then retURL paramters will be set in the URL
        ApexPages.currentPage().getParameters().put(MassCreateBundleOppConstants.ID_Paramter, testBundle.ID);
        ApexPages.currentPage().getParameters().put(MassCreateBundleOppConstants.RETURL_URL, 'testing');
        
        //user click on "Cancel" all button but bundle Id is not there in the URL
        controller_4.cancelAll();
        
        //Click on "Save" button when no opportunity was tagged to that bundle
        controller_4.saveAll();
        
        //Loading the VF page
        ApexPages.StandardController sc_5 = new ApexPages.StandardController(testBundle);
        MassCreateBundleOpportinities_Ext controller_5 = new MassCreateBundleOpportinities_Ext(sc_5);
        
        //By any means user have selected record type selection other than desired choices
        controller_5.bundle.Id = null;
        
        //user click on "Cancel" all button but bundle Id is not there in the URL
        controller_5.cancelAll();
        
        //Test will stop here
        Test.stopTest();
    }
    
    //Test Method to test various other miscellaneous behaviours of the VF page
    static testmethod void testMiscellaneousbehaviours_2() {
    
        //Bypassing trigger
        Util.BypassAllTriggers = true;
        Util.IsTest(true);
        
        //Create dummy data for testing Purpose
        Bundle__c testBundle = new Bundle__c();
        insert testBundle;
        
        //Start test from here
        Test.startTest();
        
        //Loading the VF page
        ApexPages.StandardController sc_1 = new ApexPages.StandardController(testBundle);
        MassCreateBundleOpportinities_Ext controller_1 = new MassCreateBundleOpportinities_Ext(sc_1);
        
        //User have not choose any lookup value on the page
        controller_1.bSibling.From__c = null;
        controller_1.addSelectedOpportunityToBundle();
        
        //Set to hold the record types developer name string literals
        Set<String> recordTypesDeveloperNames = new Set<String>();
        recordTypesDeveloperNames.add(MassCreateBundleOppConstants.PT_MARKETING);
        recordTypesDeveloperNames.add(MassCreateBundleOppConstants.RI_MARKETING);
        recordTypesDeveloperNames.add(MassCreateBundleOppConstants.SOUTHWIND);
        
        //Record Types
        List<RecordType> rdNonBundleType = [Select ID, DeveloperName FROM RecordType Where sObjectType='Opportunity' AND IsActive = true 
                                                AND DeveloperName IN: recordTypesDeveloperNames];
        
        //Assert for the result
        System.assert(rdNonBundleType != null);
        System.assertEquals(3, rdNonBundleType.size());
        
        //Testing Exception cases
        Opportunity opp_1 = new Opportunity(StageName = 'Prospect', CloseDate = System.today().addDays(5), Name = 'Test Opp 3', Amount = 2000, 
                                                RecordTypeId = rdNonBundleType[0].ID);
        
        //Insert opportunity
        insert opp_1;
           
        //Loading the VF page
        ApexPages.StandardController sc_2 = new ApexPages.StandardController(testBundle);
        MassCreateBundleOpportinities_Ext controller_2 = new MassCreateBundleOpportinities_Ext(sc_2);
        
        //Setting field values
        opp_1.stageName = null;
        opp_1.Amount = null;
        
        //Asserting for the results
        System.assertEquals(0, controller_1.existingBundledOpportunities.size());
        controller_2.bSibling.From__c = opp_1.Id;
        
        //Calling action method
        try {
            controller_2.addSelectedOpportunityToBundle();
        } catch(Exception ex) {}
        
        //Calling action method
        try {
            controller_2.saveAll();
        } catch(Exception ex) {}
        
        //Test will stop here
        Test.stopTest();
    }
}