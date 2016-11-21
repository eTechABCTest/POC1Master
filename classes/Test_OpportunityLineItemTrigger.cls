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
private class Test_OpportunityLineItemTrigger {
/**
 *  Description     :   Test class to test the functionality of OpportunityLineItemTrigger Trigger
 *            
 *  Create By       :   Subhash Garhwal
 *
 *  Created Date    :   07/11/2016
 *
 *  Revision Log    :   V_1.0 - Created 
 *
 *  Coverage        :   V_1.0 - 100% 
 *
 **/
    //Test method
    static testMethod void myUnitTest() {
        
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
        List<RecordType> recordTypes = [Select Id, Name from RecordType Where SobjectType = 'Opportunity' AND IsActive = true AND DeveloperName = 'Contract_LOA'];
        
        //Create new account
        Account acc = TestUtilities.CreateNewAccount(true);
        
        //List of Opportunity for Test 
        List<Opportunity> parentOpportunities = new List<Opportunity>();
        
        //Add Parent (Contract LOA) opportunities in list
        parentOpportunities.add(new Opportunity(Name = 'Will Auto Populate', AccountId = acc.Id,StageName = 'On Deck', SBQQ__Renewal__c = true, CloseDate = System.today(),
                                                RecordTypeId = recordTypes[0].Id));
        
        parentOpportunities.add(new Opportunity(Name = 'Will Auto Populate', AccountId = acc.Id, StageName = 'On Deck', SBQQ__Renewal__c = true, CloseDate = System.today(),
                                                RecordTypeId = recordTypes[0].Id));
        
        //Set Opportunity flag
        OpportunityTriggerHelper.EXECUTE_TRIGGER_BEFORE_UPDATE = false;
        OpportunityTriggerHelper.EXECUTE_TRIGGER_AFTER_UPDATE = false;
        
        //Test start here
        Test.startTest();
        
        //Insert List of Opportunity
        insert parentOpportunities;
        
        //Insert Test data of Price book
        PriceBook2 pB = new PriceBook2 (Name='Standard priceBook',Description = 'test');
        
        //Insert
        insert pB;
        
        //Std Price Book Id
        Id pricebookId = Test.getStandardPricebookId();
        
        //List of PriceBookEntry
        List<PricebookEntry> priceBookEntries = new List<PricebookEntry>();
        
        //Insert test data of price  book entry
        priceBookEntries.add(new PricebookEntry(Product2Id = products[0].Id, PriceBook2Id = pricebookId,Isactive = true, UnitPrice = 20.00));
        priceBookEntries.add(new PricebookEntry(Product2Id = products[0].Id, PriceBook2Id = pB.Id,
                                                           UnitPrice = 20.00,UseStandardPrice = false, Isactive = true));
        //insert
        insert priceBookEntries;
        
        //Test data of opportunity line item
        OpportunityLineItem oppLineItem = new OpportunityLineItem(OpportunityId = parentOpportunities[0].Id, PricebookEntryId = priceBookEntries[1].Id, Quantity = 1,
                                                                  UnitPrice = priceBookEntries[1].UnitPrice, ServiceDate = System.today());
        //Insert OpportunityLine Item
        insert oppLineItem;
        
        //Query Program opportunity created after insert Opportunity Line Item insert
        List<Opportunity> opportunity = [Select Id, Amount, OwnerId, AccountId, Probability, StageName, Source_Stage__c, Parent_Opportunity__c,
                                                                Program__c, CloseDate, RecordTypeId from Opportunity where Parent_Opportunity__c =: parentOpportunities[0].Id];
            
        //Assert
        System.assertEquals(1,opportunity.size());
        System.assertEquals(0,opportunity[0].Amount);
        System.assertEquals(acc.Id,opportunity[0].AccountId);
        System.assertEquals(CPQConstants.OPPORTUNITY_STAGE_PENDING,opportunity[0].StageName);
        System.assertEquals(products[0].Program__c,opportunity[0].Program__c);
        System.assertEquals(System.today(),opportunity[0].CloseDate);
        
        //Test stop
        Test.stopTest();
    }
    
    //Test method 
    //Test repeated opportunity line item
    static testMethod void myUnitTest1() {
        
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
        List<RecordType> recordTypes = [Select Id,Name from RecordType where SobjectType = 'Opportunity' AND isActive = true AND DeveloperName = 'Contract_LOA'];
        
        //Create new account
        Account acc = TestUtilities.CreateNewAccount(true);
        
        //List of Opportunity for Test 
        List<Opportunity> parentOpportunities = new List<Opportunity>();
        
        //Add Parent (Contract LOA) opportunities in list
        parentOpportunities.add(new Opportunity(Name = 'Will Auto Populate', AccountId = acc.Id,StageName = 'On Deck', SBQQ__Renewal__c = true, CloseDate = System.today(),
                                                RecordTypeId = recordTypes[0].Id));
        
        parentOpportunities.add(new Opportunity(Name = 'Will Auto Populate', AccountId = acc.Id, StageName = 'On Deck', SBQQ__Renewal__c = true, CloseDate = System.today(),
                                                RecordTypeId = recordTypes[0].Id));
        
        //Set Opportunity flag
        OpportunityTriggerHelper.EXECUTE_TRIGGER_BEFORE_UPDATE = false;
        OpportunityTriggerHelper.EXECUTE_TRIGGER_AFTER_UPDATE = false;
        
        //Test start here
        Test.startTest();
        
        //Insert List of Opportunity
        insert parentOpportunities;
                
        //Price Book
        PriceBook2 pB = new PriceBook2 (Name='Standard priceBook',Description = 'test');
        
        //Insert
        insert pB;
        
        //Std Price Book Id
        Id pricebookId = Test.getStandardPricebookId();
        
        //List of PriceBookEntry
        List<PricebookEntry> priceBookEntries = new List<PricebookEntry>();
        
        //Insert test data of price  book entry
        priceBookEntries.add(new PricebookEntry(Product2Id = products[0].Id, PriceBook2Id = pricebookId, Isactive = true, UnitPrice = 20.00));
        priceBookEntries.add(new PricebookEntry(Product2Id = products[0].Id, PriceBook2Id = pB.Id,
                                                           UnitPrice = 20.00,UseStandardPrice = false, Isactive = true));
        //insert
        insert priceBookEntries;
        
        //List of OpportunityLineItem
        List<OpportunityLineItem> oppLineItems = new List<OpportunityLineItem>();
        
        //Test data of opportunity line item
        oppLineItems.add(new OpportunityLineItem(OpportunityId = parentOpportunities[0].Id, PricebookEntryId = priceBookEntries[1].Id, Quantity = 1,
                                                                  UnitPrice = priceBookEntries[1].UnitPrice, ServiceDate = System.today()));
        
        //Test data of opportunity line item
        oppLineItems.add(new OpportunityLineItem(OpportunityId = parentOpportunities[0].Id, PricebookEntryId = priceBookEntries[1].Id, Quantity = 1,
                                                                   UnitPrice = priceBookEntries[1].UnitPrice, ServiceDate = System.today()));
        
        //Insert
        insert oppLineItems;
        
        //Query Program opportunity created after insert Opportunity Line Item insert
        List<Opportunity> opportunity = [Select Id, Amount, OwnerId, AccountId, Probability, StageName, Source_Stage__c, Parent_Opportunity__c,
                                                                Program__c, CloseDate, RecordTypeId from Opportunity where Parent_Opportunity__c =: parentOpportunities[0].Id];
            
        //Assert
        System.assertEquals(1,opportunity.size());
        System.assertEquals(0,opportunity[0].Amount);
        System.assertEquals(acc.Id,opportunity[0].AccountId);
        System.assertEquals(CPQConstants.OPPORTUNITY_STAGE_PENDING,opportunity[0].StageName);
        System.assertEquals(products[0].Program__c,opportunity[0].Program__c);
        System.assertEquals(System.today(),opportunity[0].CloseDate);
        
        //Test stop
        Test.stopTest();
    }
}