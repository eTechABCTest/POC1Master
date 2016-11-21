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
private class Test_SBQQ_SubscriptionTrigger {
/**
  *   Purpose         :   Test class for SBQQ_SubscriptionTrigger
  *            
  *   Create By       :   Subhash Garhwal
  * 
  *   Created Date    :   07/25/2016
  *
  *   Revision Log    :   V_1.0 - Created - Subhash Garhwal - CR-20160414-9762
  * 
  *   Coverage        :   V_1.0 - 93%
  **/
      
    //Test method to test the functionality of syncProgramOppsWithSubscriptions and validateProgramOpportunities methods   
    static testMethod void myUnitTest() {
        
        // TO DO: implement unit test
                
        //Bypass Flags
        Util.IsTest(true);
        Util.isTesting = true;
        Util.byPassAllTriggers = true;
        
        //Query through Opportunity Record Types
        List<RecordType> recordTypes = [Select Id,DeveloperName From RecordType Where SobjectType = 'Opportunity' AND DeveloperName IN : CPQConstants.SET_OPPORTUNITY_CPQ_RT_DEVELOPER_NAME ORDER BY DeveloperName ASC];
        
        //Create Recordtype_Setting__c custom setting data for Opportunity record types
        List<Recordtype_Setting__c> recordTypesSetting = new List<Recordtype_Setting__c>();
        
        //Loop over the Record Types and add data in custom setting
        for(RecordType rT : recordTypes)
            recordTypesSetting.add(new Recordtype_Setting__c(Name = rT.DeveloperName, Name__c = rT.DeveloperName, SFID__c = rT.Id, SObjectType__c = 'Opportunity'));
        
        //Insert
        insert recordTypesSetting;
        
        //List to insert Program records
        List<Program__c> programs = new List<Program__c>();
        
        //Add Program Record in list
        programs.add(TestUtilities.CreateNewProgram(false));
        programs.add(TestUtilities.CreateNewProgram(false));
        
        //Add additional field values
        programs[0].Business_line__c = CPQConstants.PROGRAM_BUSINESS_LINE_RI;
        programs[1].Business_line__c = CPQConstants.PROGRAM_BUSINESS_LINE_PT;
        
        //ByPass all triggers
        Util.byPassAllTriggers = true;
        
        //Insert
        insert programs;
        
        //List of Product
        List<Product2> products = new List<Product2>();
        
        //Add new Products in List
        products.add(new Product2(Name = 'RI Product', Family = 'RI', Program__c = programs[0].Id, Program_or_Component__c = 'RI', IsActive = true,
                                  ProductCode = 'RIPRO'));
        
        products.add(new Product2(Name = 'PT Product', Family = 'PT', Program__c = programs[1].Id, Program_or_Component__c = 'PT', IsActive = true,
                                  ProductCode = 'PTPRO'));
        
        products.add(new Product2(Name = 'PT Product Annual Fee', Family = 'PT', Program_or_Component__c = 'Annual Fee', IsActive = true,
                                  ProductCode = 'PTPROAnnualFee', SBQQ__Component__c = true));
        
        products.add(new Product2(Name = 'RI Product Implementation Fee', Family = 'RI', Program_or_Component__c = 'Implementation Fee', IsActive = true,
                                  ProductCode = 'RIPROImple', SBQQ__Component__c = true));
        
        //ByPass all triggers
        Util.byPassAllTriggers = true;
        
        //Insert
        insert products;
        
        //List of SBQQ__ProductOption__c
        List<SBQQ__ProductOption__c> productOptions = new List<SBQQ__ProductOption__c>();
        
        //Add in option in list
        productOptions.add(new SBQQ__ProductOption__c(SBQQ__ConfiguredSKU__c = products[0].Id, SBQQ__OptionalSKU__c = products[2].Id,
                                                      SBQQ__Type__c = 'Component', SBQQ__Selected__c = true, SBQQ__Number__c = 10));
        
        productOptions.add(new SBQQ__ProductOption__c(SBQQ__ConfiguredSKU__c = products[1].Id, SBQQ__OptionalSKU__c = products[3].Id,
                                                      SBQQ__Type__c = 'Component', SBQQ__Selected__c = true, SBQQ__Number__c = 5));
                                                      
        //Bypass triggers
        Util.byPassAllTriggers = true;
        
        //Insert
        insert productOptions;
        
        //Account
        Account acc = new Account(Name = 'Test Account');
        
        //Bypass triggers
        Util.byPassAllTriggers = true;
        
        //Insert
        insert acc;
        
        //List of Membership__c
        List<Membership__c> memberships = new List<Membership__c>();
        
        //Add Membership record in list
        memberships.add(new Membership__c(Name = 'Member 1', Account_Name__c = acc.Id, Program__c = products[0].Program__c));
        
        //Bypass triggers
        Util.byPassAllTriggers = true;
        
        //Insert
        insert memberships;
        
        //List of Opportunity (Contract LOA Opps)
        List<Opportunity> contractLOAOpps = new List<Opportunity>();
        
        //Add Opportunity Records in list
        //Create Opportunity record 
        contractLOAOpps.add(new Opportunity(Name = 'Test 1', Opportunity_Nickname__c = 'Contract LOA Opp 1', StageName = CPQConstants.OPPORTUNITY_STAGE_ON_DECK, Amount = 4.00, CloseDate = Date.today(),
                                        RecordTypeId = recordTypes[0].Id, Competitor_Notes__c = 'ABC 1', CT_Pass_Status__c = 'Assigned', 
                                        CT_Reneg_Attempt__c = 'No', AccountId = acc.Id));
        
        contractLOAOpps.add(new Opportunity(Name = 'Test 2', Opportunity_Nickname__c = 'Contract LOA Opp 2', StageName = CPQConstants.OPPORTUNITY_STAGE_ON_DECK, Amount = 4.00, CloseDate = Date.today(), 
                                        RecordTypeId = recordTypes[0].Id, Competitor_Notes__c = 'ABC 2',CT_Pass_Status__c = 'Assigned',
                                        CT_Reneg_Attempt__c = 'No', AccountId = acc.Id));
        
        //ByPass triggers
        Util.byPassAllTriggers = true;                                            
        
        //Insert 
        insert contractLOAOpps;
        
        //Assert
        System.assert(contractLOAOpps.size() > 0);
        
        //List to hold the Program Opps
        List<Opportunity> programOpps = new List<Opportunity>();
        
        //Add Program Opps in list 
        programOpps.add(new Opportunity(Name = 'Test 1', StageName = 'Active in SlowTrack', Amount = 4.00, CloseDate = Date.today(),
                                        RecordTypeId = recordTypes[3].Id, Competitor_Notes__c = 'Test 1', CT_Pass_Status__c = 'Assigned', 
                                        CT_Reneg_Attempt__c = 'No', Parent_Opportunity__c = contractLOAOpps[0].Id,  AccountId = acc.Id,
                                        Program__c = products[0].Program__c, Program_Proposal_Status__c = CPQConstants.PROGRAM_PROPOSAL_STATUS_PRIMARY_PROPOSAL));
        
        programOpps.add(new Opportunity(Name = 'Test 2', StageName = 'Active in SlowTrack', Amount = 5.00,CloseDate = Date.today(), 
                                        RecordTypeId = recordTypes[3].Id, Competitor_Notes__c = 'Test 2',CT_Pass_Status__c = 'Assigned',
                                        CT_Reneg_Attempt__c = 'No', Parent_Opportunity__c = contractLOAOpps[1].Id,  AccountId = acc.Id,
                                        Program__c = products[1].Program__c, Program_Proposal_Status__c = CPQConstants.PROGRAM_PROPOSAL_STATUS_PRIMARY_PROPOSAL));
        
        //ByPass trigger
        Util.BypassAllTriggers = true;
        
        //Insert Program Opp
        insert programOpps;
        
        //Assert
        System.assert(programOpps.size() > 0);
        
        //List of Quote
        List<SBQQ__Quote__c> quotes = new List<SBQQ__Quote__c>();
        
        //Add new quote record in list
        quotes.add(new SBQQ__Quote__c(SBQQ__Status__c = 'Draft', SBQQ__Type__c = 'Quote', SBQQ__Primary__c = true, SBQQ__StartDate__c = System.today(),
                                      SBQQ__EndDate__c = System.today().addYears(3), SBQQ__Opportunity2__c = contractLOAOpps[0].Id));
        
        quotes.add(new SBQQ__Quote__c(SBQQ__Status__c = 'Draft', SBQQ__Type__c = 'Quote', SBQQ__Primary__c = false, SBQQ__StartDate__c = System.today(),
                                      SBQQ__EndDate__c = System.today().addYears(3), SBQQ__Opportunity2__c = contractLOAOpps[0].Id));
        
        quotes.add(new SBQQ__Quote__c(SBQQ__Status__c = 'Draft', SBQQ__Type__c = 'Quote', SBQQ__Primary__c = true, SBQQ__StartDate__c = System.today(),
                                      SBQQ__EndDate__c = System.today().addYears(3),SBQQ__Opportunity2__c = contractLOAOpps[1].Id));
        
        Util.BypassAllTriggers = true;
      
        //Insert list of Quote
        insert quotes;
        
        //List of quote line item to insert
        List<SBQQ__QuoteLine__c> quoteLines = new List<SBQQ__QuoteLine__c>();
        
        //Add new Quote lines n list
        quoteLines.add(new SBQQ__QuoteLine__c(SBQQ__Quote__c = quotes[0].Id, SBQQ__Product__c = products[0].Id, SBQQ__NetPrice__c = 100, Program_Opportunity__c = programOpps[0].Id,
                                              Program_or_Component__c = 'PT'));
        quoteLines.add(new SBQQ__QuoteLine__c(SBQQ__Quote__c = quotes[1].Id, SBQQ__Product__c = products[0].Id, SBQQ__NetPrice__c = 100, Program_Opportunity__c = programOpps[0].Id,
                                              Program_or_Component__c = 'PT'));
        quoteLines.add(new SBQQ__QuoteLine__c(SBQQ__Quote__c = quotes[2].Id, SBQQ__Product__c = products[1].Id, SBQQ__NetPrice__c = 500, Program_Opportunity__c = programOpps[1].Id,
                                              Program_or_Component__c = 'RI'));
                                          
        //Bypass triggers
        Util.BypassAllTriggers = true;
        
        //Insert
        insert quoteLines;
        
        //List of supporting Portals
        List<SBQQ__QuoteLine__c> supportingQuoteLines = new List<SBQQ__QuoteLine__c>();
        
        //Start testing from here
        Test.startTest();
        
        //Add Supporting quote lines
        supportingQuoteLines.add(new SBQQ__QuoteLine__c(SBQQ__Quote__c = quotes[0].Id, SBQQ__Product__c = products[2].Id, SBQQ__NetPrice__c = 100,
                                                        Program_Opportunity__c = programOpps[0].Id,
                                                        SBQQ__RequiredBy__c = quoteLines[0].Id, SBQQ__StartDate__c = System.today(), SBQQ__EndDate__c = System.today().addDays(365),
                                                        SBQQ__Quantity__c = 1, SBQQ__Number__c = 1, SBQQ__PricingMethod__c = 'List', Program_or_Component__c = products[2].Product_Category__c,
                                                        SBQQ__SegmentLabel__c = 'Year 1', SBQQ__SegmentIndex__c = 1, SBQQ__SegmentKey__c = '1' + String.valueOf(Math.random())));
        
        supportingQuoteLines.add(new SBQQ__QuoteLine__c(SBQQ__Quote__c = quotes[1].Id, SBQQ__Product__c = products[2].Id, SBQQ__NetPrice__c = 100,
                                                        Program_Opportunity__c = programOpps[0].Id, 
                                                        SBQQ__RequiredBy__c = quoteLines[1].Id, SBQQ__StartDate__c = System.today().adddays(366), SBQQ__EndDate__c = System.today().addDays(720),
                                                        SBQQ__Quantity__c = 1, SBQQ__Number__c = 1, SBQQ__PricingMethod__c = 'List',Program_or_Component__c = products[2].Product_Category__c,
                                                        SBQQ__SegmentLabel__c = 'Year 2', SBQQ__SegmentIndex__c = 2, SBQQ__SegmentKey__c = '2' + String.valueOf(Math.random())));
        
        supportingQuoteLines.add(new SBQQ__QuoteLine__c(SBQQ__Quote__c = quotes[1].Id, SBQQ__Product__c = products[2].Id, SBQQ__NetPrice__c = 100,
                                                        Program_Opportunity__c = programOpps[0].Id, 
                                                        SBQQ__RequiredBy__c = quoteLines[1].Id, SBQQ__StartDate__c = System.today().adddays(721), SBQQ__EndDate__c = System.today().addDays(1085),
                                                        SBQQ__Quantity__c = 1, SBQQ__Number__c = 1, SBQQ__PricingMethod__c = 'List',Program_or_Component__c = products[2].Product_Category__c,
                                                        SBQQ__SegmentLabel__c = 'Year 3', SBQQ__SegmentIndex__c = 3, SBQQ__SegmentKey__c = '3' + String.valueOf(Math.random())));
        
        supportingQuoteLines.add(new SBQQ__QuoteLine__c(SBQQ__Quote__c = quotes[2].Id, SBQQ__Product__c = products[3].Id, SBQQ__NetPrice__c = 100,
                                                        Program_Opportunity__c = programOpps[1].Id,
                                                        SBQQ__RequiredBy__c = quoteLines[2].Id, SBQQ__StartDate__c = System.today(), SBQQ__EndDate__c = System.today().addYears(1),
                                                        SBQQ__Quantity__c = 1, SBQQ__Number__c = 3, SBQQ__PricingMethod__c = 'List', Program_or_Component__c = products[3].Product_Category__c,
                                                        SBQQ__SegmentLabel__c = 'Year 1',  SBQQ__SegmentKey__c = '1' + String.valueOf(Math.random())));
        
        supportingQuoteLines.add(new SBQQ__QuoteLine__c(SBQQ__Quote__c = quotes[1].Id, SBQQ__Product__c = products[3].Id, SBQQ__NetPrice__c = 100,
                                                        Program_Opportunity__c = programOpps[1].Id, 
                                                        SBQQ__RequiredBy__c = quoteLines[1].Id, SBQQ__StartDate__c = System.today().adddays(366), SBQQ__EndDate__c = System.today().addDays(720),
                                                        SBQQ__Quantity__c = 1, SBQQ__Number__c = 1, SBQQ__PricingMethod__c = 'List',Program_or_Component__c = products[3].Product_Category__c,
                                                        SBQQ__SegmentLabel__c = 'Year 2', SBQQ__SegmentIndex__c = 2, SBQQ__SegmentKey__c = '2' + String.valueOf(Math.random())));
        
        supportingQuoteLines.add(new SBQQ__QuoteLine__c(SBQQ__Quote__c = quotes[1].Id, SBQQ__Product__c = products[3].Id, SBQQ__NetPrice__c = 100,
                                                        Program_Opportunity__c = programOpps[1].Id, 
                                                        SBQQ__RequiredBy__c = quoteLines[1].Id, SBQQ__StartDate__c = System.today().adddays(721), SBQQ__EndDate__c = System.today().addDays(1085),
                                                        SBQQ__Quantity__c = 1, SBQQ__Number__c = 1, SBQQ__PricingMethod__c = 'List',Program_or_Component__c = products[3].Product_Category__c,
                                                        SBQQ__SegmentLabel__c = 'Year 3', SBQQ__SegmentIndex__c = 3, SBQQ__SegmentKey__c = '3' + String.valueOf(Math.random())));
        
        //ByPass triggers
        Util.BypassAllTriggers = true;
        
        //Insert 
        insert supportingQuoteLines;
        
        //Update Contract LOA Opps stage to Closed Won
        contractLOAOpps[0].StageName = 'Closed Won';
        contractLOAOpps[0].SBQQ__Contracted__c = true;
        contractLOAOpps[1].StageName = 'Closed Won';
        contractLOAOpps[1].SBQQ__Contracted__c = true;
        
        //Bypass triggers
        Util.BypassAllTriggers = true;
        
        //Update
        update contractLOAOpps[0];
        
        //List of Contract records
        List<Contract> contracts = new List<Contract>();
        
        //Add new contract record in list
        contracts.add(new Contract(AccountId = acc.Id, SBQQ__Opportunity__c = contractLOAOpps[0].Id, SBQQ__Quote__c = quotes[0].Id,
                                   Status = 'Draft', StartDate = quotes[0].SBQQ__StartDate__c, ContractTerm = quotes[0].SBQQ__StartDate__c.monthsBetween(quotes[0].SBQQ__EndDate__c)));
                                   
        contracts.add(new Contract(AccountId = acc.Id, SBQQ__Opportunity__c = contractLOAOpps[0].Id, SBQQ__Quote__c = quotes[1].Id,
                                   Status = 'Draft', StartDate = quotes[1].SBQQ__StartDate__c, ContractTerm = quotes[1].SBQQ__StartDate__c.monthsBetween(quotes[0].SBQQ__EndDate__c)));
        
        contracts.add(new Contract(AccountId = acc.Id, SBQQ__Opportunity__c = contractLOAOpps[1].Id, SBQQ__Quote__c = quotes[2].Id,
                                   Status = 'Draft', StartDate = quotes[2].SBQQ__StartDate__c, ContractTerm = quotes[2].SBQQ__StartDate__c.monthsBetween(quotes[0].SBQQ__EndDate__c)));
        
        //Bypass triggers
        Util.BypassAllTriggers = true;
        
        //Insert
        insert contracts;
        
        //List of Subscription
        List<SBQQ__Subscription__c> subscriptions = new List<SBQQ__Subscription__c>();
        
        //Add new subscription record in list
        subscriptions.add(new SBQQ__Subscription__c(SBQQ__Quantity__c = 1, SBQQ__QuoteLine__c = quoteLines[0].Id, SBQQ__Product__c = products[0].Id,
                                                    SBQQ__Account__c = acc.Id, SBQQ__ListPrice__c = 0, SBQQ__Contract__c = contracts[0].Id,
                                                    SBQQ__NetPrice__c = 0, SBQQ__CustomerPrice__c = 0, SBQQ__ProrateMultiplier__c = 2,
                                                    Status__c = 'Committed'));
        
        /*subscriptions.add(new SBQQ__Subscription__c(SBQQ__Quantity__c = 1, SBQQ__QuoteLine__c = supportingQuoteLines[0].Id,
                                                    SBQQ__Product__c = products[2].Id, SBQQ__Account__c = acc.Id, SBQQ__ListPrice__c = 0,
                                                    SBQQ__Contract__c = contracts[0].Id, SBQQ__NetPrice__c = 0, SBQQ__CustomerPrice__c = 0,
                                                    SBQQ__ProrateMultiplier__c = 2, Status__c = 'Committed', SBQQ__SegmentStartDate__c = supportingQuoteLines[0].SBQQ__StartDate__c,
                                                    SBQQ__SegmentEndDate__c = supportingQuoteLines[0].SBQQ__EndDate__c));
        
        subscriptions.add(new SBQQ__Subscription__c(SBQQ__Quantity__c = 1, SBQQ__QuoteLine__c = supportingQuoteLines[1].Id,
                                                    SBQQ__Product__c = products[2].Id, SBQQ__Account__c = acc.Id, SBQQ__ListPrice__c = 0,
                                                    SBQQ__Contract__c = contracts[0].Id, SBQQ__NetPrice__c = 0, SBQQ__CustomerPrice__c = 0,
                                                    SBQQ__ProrateMultiplier__c = 2, Status__c = 'Committed', SBQQ__SegmentStartDate__c = supportingQuoteLines[1].SBQQ__StartDate__c,
                                                    SBQQ__SegmentEndDate__c = supportingQuoteLines[1].SBQQ__EndDate__c));
        
        subscriptions.add(new SBQQ__Subscription__c(SBQQ__Quantity__c = 1, SBQQ__QuoteLine__c = supportingQuoteLines[2].Id,
                                                    SBQQ__Product__c = products[2].Id, SBQQ__Account__c = acc.Id, SBQQ__ListPrice__c = 0,
                                                    SBQQ__Contract__c = contracts[0].Id, SBQQ__NetPrice__c = 0, SBQQ__CustomerPrice__c = 0,
                                                    SBQQ__ProrateMultiplier__c = 2, Status__c = 'Committed', SBQQ__SegmentStartDate__c = supportingQuoteLines[2].SBQQ__StartDate__c,
                                                    SBQQ__SegmentEndDate__c = supportingQuoteLines[2].SBQQ__EndDate__c));
        
        subscriptions.add(new SBQQ__Subscription__c(SBQQ__Quantity__c = 1, SBQQ__QuoteLine__c = supportingQuoteLines[3].Id,
                                                    SBQQ__Product__c = products[3].Id, SBQQ__Account__c = acc.Id, SBQQ__ListPrice__c = 0,
                                                    SBQQ__Contract__c = contracts[0].Id, SBQQ__NetPrice__c = 0, SBQQ__CustomerPrice__c = 0,
                                                    SBQQ__ProrateMultiplier__c = 2, Status__c = 'Committed', SBQQ__SegmentStartDate__c = supportingQuoteLines[3].SBQQ__StartDate__c,
                                                    SBQQ__SegmentEndDate__c = supportingQuoteLines[3].SBQQ__EndDate__c));
        
        subscriptions.add(new SBQQ__Subscription__c(SBQQ__Quantity__c = 1, SBQQ__QuoteLine__c = supportingQuoteLines[4].Id,
                                                    SBQQ__Product__c = products[3].Id, SBQQ__Account__c = acc.Id, SBQQ__ListPrice__c = 0,
                                                    SBQQ__Contract__c = contracts[0].Id, SBQQ__NetPrice__c = 0, SBQQ__CustomerPrice__c = 0,
                                                    SBQQ__ProrateMultiplier__c = 2, Status__c = 'Committed', SBQQ__SegmentStartDate__c = supportingQuoteLines[4].SBQQ__StartDate__c,
                                                    SBQQ__SegmentEndDate__c = supportingQuoteLines[4].SBQQ__EndDate__c));
        
        subscriptions.add(new SBQQ__Subscription__c(SBQQ__Quantity__c = 1, SBQQ__QuoteLine__c = supportingQuoteLines[5].Id,
                                                    SBQQ__Product__c = products[3].Id, SBQQ__Account__c = acc.Id, SBQQ__ListPrice__c = 0,
                                                    SBQQ__Contract__c = contracts[0].Id, SBQQ__NetPrice__c = 0, SBQQ__CustomerPrice__c = 0,
                                                    SBQQ__ProrateMultiplier__c = 2, Status__c = 'Committed', SBQQ__SegmentStartDate__c = supportingQuoteLines[5].SBQQ__StartDate__c,
                                                    SBQQ__SegmentEndDate__c = supportingQuoteLines[5].SBQQ__EndDate__c));*/
        
        
        //Bypass triggers
        Util.BypassAllTriggers = false;
        OpportunityTriggerHelper.EXECUTE_TRIGGER_BEFORE_UPDATE = false;
        OpportunityTriggerHelper.EXECUTE_TRIGGER_AFTER_UPDATE = false;
        
        //Insert
        insert subscriptions;
        
        //Query thoguh Program Opportunities
        List<Opportunity> proOpps = [Select Id, Name From Opportunity Where RecordType.DeveloperName IN : CPQConstants.SET_OPPORTUNITY_CPQ_PROGRAM_OPP_RT_DEVELOPER_NAME AND Id NOT IN : programOpps];
        
        //Assert for result
        //System.assert(programOpps.size() > 0);
        
        //Delete subscription record
        //delete subscriptions[2];
        
        //Stop testing here
        Test.stopTest();
    }
}