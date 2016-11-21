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
private class Test_SBQQ_QuoteLineTrigger {
/**
 *  Description     :   Test class to test the functionality of QuoteLine Trigger
 *            
 *  Create By       :   Subhash Garhwal
 *
 *  Created Date    :   06/24/2016
 *
 *  Revision Log    :   V_1.0 - Created - CR-20160414-9762  
 *
 *  Coverage        :    
 *
 **/
 
    //Setup Test data
    @testSetup static void setupTestData() {
        
        //Set Flag
        Util.BypassAllTriggers = true;
        
        //List to insert Program records
        List<Program__c> programs = new List<Program__c>();
        
        //Add Program Record in list
        programs.add(TestUtilities.CreateNewProgram(false));
        programs.add(TestUtilities.CreateNewProgram(false));
        programs.add(TestUtilities.CreateNewProgram(false));
        
        //Add additional field values
        programs[0].Business_line__c = CPQConstants.PROGRAM_BUSINESS_LINE_RI;
        programs[1].Business_line__c = CPQConstants.PROGRAM_BUSINESS_LINE_PT;
        programs[2].Business_line__c = CPQConstants.PROGRAM_BUSINESS_LINE_CLN;
        
        //Insert
        insert programs;
        
        //List of Product
        List<Product2> products = new List<Product2>();
        
        //Add new Products in List
        products.add(new Product2(Name = 'RI Product', Family = 'RI', Program__c = programs[0].Id, Program_or_Component__c = 'RI', IsActive = true,
                                  ProductCode = 'RIPRO'));
        
        products.add(new Product2(Name = 'PT Product', Family = 'PT', Program__c = programs[1].Id, Program_or_Component__c = 'PT', IsActive = true,
                                  ProductCode = 'PTPRO'));
        
        products.add(new Product2(Name = 'Consulting Product', Family = 'Consulting', Program__c = programs[2].Id, Program_or_Component__c = 'Consulting',
                                  IsActive = true, ProductCode = 'ConsultingPRO'));
        
        //Insert
        insert products;
        
        //Parent Opportunity
        List<RecordType> recordTypes = [Select Id, Name from RecordType Where SobjectType = 'Opportunity' AND IsActive = true
                                             AND DeveloperName IN : CPQConstants.SET_OPPORTUNITY_CPQ_RT_DEVELOPER_NAME ORDER BY DeveloperName];
        
        //Create new account
        Account acc = TestUtilities.CreateNewAccount(true);
        
        //List of Opportunity for Test 
        List<Opportunity> parentOpportunities = new List<Opportunity>();
        
        //Add Parent (Contract LOA) opportunities in list
        parentOpportunities.add(new Opportunity(Name = 'Will Auto Populate', AccountId = acc.Id, StageName = 'On Deck', CloseDate = System.today(),
                                                RecordTypeId = recordTypes[0].Id));
        
        parentOpportunities.add(new Opportunity(Name = 'Will Auto Populate', AccountId = acc.Id, StageName = 'On Deck', CloseDate = System.today(),
                                                RecordTypeId = recordTypes[0].Id));
        
        //Set Opportunity trigger flag (We don't need to execute opportunity trigger)
        OpportunityTriggerHelper.EXECUTE_TRIGGER_BEFORE_UPDATE = false;
        OpportunityTriggerHelper.EXECUTE_TRIGGER_AFTER_UPDATE = false;
        Util.BypassAllTriggers = true;
       
        //Insert List of Opportunity
        insert parentOpportunities;
        
    }
    
    //Test method
    static testMethod void myUnitTest() {
       
       //Bypass Dupeblocker     
        Util.IsTest(true);
        Util.isTesting = true;
        Util.BypassAllTriggers = true;
        
        //Get Products
        List<Product2> products = [Select Id, Name, Family, Program__c, Program_or_Component__c, IsActive, ProductCode From Product2];
        
        //Get Parent Opportunities
        List<Opportunity> parentOpportunities = [Select Id, Name, AccountId, StageName, CloseDate, RecordTypeId From Opportunity];
        
        //List of Quote
        List<SBQQ__Quote__c> quotes = new List<SBQQ__Quote__c>();
        
        //Add new quote record in list
        quotes.add(new SBQQ__Quote__c(SBQQ__Status__c = 'Draft', SBQQ__Type__c = 'Quote', SBQQ__Primary__c = true, SBQQ__Opportunity2__c = parentOpportunities[0].Id));
        quotes.add(new SBQQ__Quote__c(SBQQ__Status__c = 'Draft', SBQQ__Type__c = 'Quote', SBQQ__Primary__c = false, SBQQ__Opportunity2__c = parentOpportunities[0].Id));
        quotes.add(new SBQQ__Quote__c(SBQQ__Status__c = 'Draft', SBQQ__Type__c = 'Quote', SBQQ__Primary__c = true, SBQQ__Opportunity2__c = parentOpportunities[1].Id));
        
        
        //Set Opportunity flag
        Util.BypassAllTriggers = false;
        OpportunityTriggerHelper.EXECUTE_TRIGGER_BEFORE_UPDATE = false;
        OpportunityTriggerHelper.EXECUTE_TRIGGER_AFTER_UPDATE = false;
      
        //Insert list of Quote
        insert quotes;
        
        //List of quote line item to insert
        List<SBQQ__QuoteLine__c> quoteLines = new List<SBQQ__QuoteLine__c>();
        
        //Add new Quote lines n list
        quoteLines.add(new SBQQ__QuoteLine__c(SBQQ__Quote__c = quotes[0].Id, SBQQ__Product__c = products[2].Id, SBQQ__NetPrice__c = 100));
        quoteLines.add(new SBQQ__QuoteLine__c(SBQQ__Quote__c = quotes[1].Id, SBQQ__Product__c = products[2].Id, SBQQ__NetPrice__c = 500));
        
        //Test Start from here
        Test.startTest();
        
        //Execute triggers
        Util.BypassAllTriggers = false;
        
        //Insert
        insert quoteLines;
        
        //Test Stop Here
        Test.stopTest();
        
        //Query through the Opportunity records to get the details about program Opportunities
        List<Opportunity> programOpps = [Select Id, StageName, AccountId, Source_Stage__c, Closedate, Parent_Opportunity__r.StageName,
                                                Parent_Opportunity__r.CloseDate, Amount From Opportunity Where Parent_Opportunity__c =: parentOpportunities[0].Id];
        
        //Assert
        System.assertEquals(1, programOpps.size());
        System.assertEquals(CPQConstants.OPPORTUNITY_STAGE_ACTIVE_IN_SLOWTRACK, programOpps[0].StageName);
        System.assertEquals(programOpps[0].Parent_Opportunity__r.CloseDate, programOpps[0].Closedate);
        System.assertEquals(CPQConstants.OPPORTUNITY_STAGE_ON_PIPELINE, programOpps[0].Parent_Opportunity__r.StageName);
        
        //Delete Quote line
        delete quoteLines[0];
        
        //After deleting on Quote line
        //Query through the Opportunity records to get the details about program Opportunities
        programOpps = [Select Id, StageName, AccountId, Source_Stage__c, Closedate, Parent_Opportunity__r.StageName,
                                                Parent_Opportunity__r.CloseDate, Amount From Opportunity Where Parent_Opportunity__c =: parentOpportunities[0].Id];
        
        //Assert
        System.assertEquals(1, programOpps.size());
        System.assertEquals(CPQConstants.OPPORTUNITY_STAGE_ACTIVE_IN_SLOWTRACK, programOpps[0].StageName);
        System.assertEquals(programOpps[0].Parent_Opportunity__r.CloseDate, programOpps[0].Closedate);
        System.assertEquals(CPQConstants.OPPORTUNITY_STAGE_ON_PIPELINE, programOpps[0].Parent_Opportunity__r.StageName);
    
    }
    
    /**
     * Description  : Test method for update Quote line
     **/ 
     
    //Test method
    static testMethod void TestQuoteLineUpdate() {
       
       //Bypass Dupeblocker     
        Util.IsTest(true);
        Util.isTesting = true;
        Util.BypassAllTriggers = true;
        
         //Get Products
        List<Product2> products = [Select Id, Name, Family, Program__c, Program_or_Component__c, IsActive, ProductCode From Product2];
        
        //Get Parent Opportunities
        List<Opportunity> parentOpportunities = [Select Id, Name, AccountId, StageName, CloseDate, RecordTypeId From Opportunity];
       
        //List of Quote
        List<SBQQ__Quote__c> quotes = new List<SBQQ__Quote__c>();
        
        //Add new quote record in list
        quotes.add(new SBQQ__Quote__c(SBQQ__Status__c = 'Draft', SBQQ__Type__c = 'Quote', SBQQ__Primary__c = true, SBQQ__Opportunity2__c = parentOpportunities[0].Id));
        quotes.add(new SBQQ__Quote__c(SBQQ__Status__c = 'Draft', SBQQ__Type__c = 'Quote', SBQQ__Primary__c = false, SBQQ__Opportunity2__c = parentOpportunities[0].Id));
        quotes.add(new SBQQ__Quote__c(SBQQ__Status__c = 'Draft', SBQQ__Type__c = 'Quote', SBQQ__Primary__c = true, SBQQ__Opportunity2__c = parentOpportunities[1].Id));
        
        //Set Opportunity flag
        Util.BypassAllTriggers = false;
        OpportunityTriggerHelper.EXECUTE_TRIGGER_BEFORE_UPDATE = false;
        OpportunityTriggerHelper.EXECUTE_TRIGGER_AFTER_UPDATE = false;
      
        //Insert list of Quote
        insert quotes;
        
        //List of quote line item to insert
        List<SBQQ__QuoteLine__c> quoteLines = new List<SBQQ__QuoteLine__c>();
        
        //Add new Quote lines n list
        quoteLines.add(new SBQQ__QuoteLine__c(SBQQ__Quote__c = quotes[0].Id, SBQQ__Product__c = products[2].Id, SBQQ__NetPrice__c = 100));
        quoteLines.add(new SBQQ__QuoteLine__c(SBQQ__Quote__c = quotes[1].Id, SBQQ__Product__c = products[2].Id, SBQQ__NetPrice__c = 500));
        
        //Test Start from here
        Test.startTest();
        
        //Execute triggers
        Util.BypassAllTriggers = false;
        
        //Insert
        insert quoteLines;
        
        //Test Stop Here
        Test.stopTest();
        
        //Query through the Opportunity records to get the details about program Opportunities
        List<Opportunity> programOpps = [Select Id, StageName, AccountId, Source_Stage__c, Closedate, Parent_Opportunity__r.StageName,
                                                Parent_Opportunity__r.CloseDate, Amount From Opportunity Where Parent_Opportunity__c =: parentOpportunities[0].Id];
        
        //Assert
        System.assertEquals(1, programOpps.size());
        System.assertEquals(CPQConstants.OPPORTUNITY_STAGE_ACTIVE_IN_SLOWTRACK, programOpps[0].StageName);
        System.assertEquals(programOpps[0].Parent_Opportunity__r.CloseDate, programOpps[0].Closedate);
        System.assertEquals(CPQConstants.OPPORTUNITY_STAGE_ON_PIPELINE, programOpps[0].Parent_Opportunity__r.StageName);
        
        Util.BypassAllTriggers = false;
        OpportunityTriggerHelper.EXECUTE_TRIGGER_BEFORE_UPDATE = false;
        OpportunityTriggerHelper.EXECUTE_TRIGGER_AFTER_UPDATE = false;
        
        //Update Quote Lines
        quoteLines[0].SBQQ__Product__c = products[1].Id;
        update quoteLines;
        
        //Query through the Opportunity records to get the details about program Opportunities
        programOpps = [Select Id, StageName, AccountId, Source_Stage__c, Closedate, Parent_Opportunity__r.StageName,
                                                Parent_Opportunity__r.CloseDate, Amount From Opportunity Where Parent_Opportunity__c =: parentOpportunities[1].Id];
        
        //Assert
        System.assertEquals(0, programOpps.size());
    }
}