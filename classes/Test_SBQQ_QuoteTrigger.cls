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
private class Test_SBQQ_QuoteTrigger {
/**
 *	Description		:   Test class to test the functionality of SBQQ_QuoteTrigger Trigger
 *            
 *	Create By   	:   Subhash Garhwal
 *
 *  Created Date	:   06/27/2016
 *
 *	Revision Log    :   V_1.0 - Created - CR-20160414-9762  
 *
 *	Coverage		:	V_1.0 - 100% 
 *
 **/
 
    //Test method for SyncProgramOpportunities method
    static testMethod void testSyncProgramOpportunities() {
        // TO DO: implement unit test
        
        //Bypass Dupeblocker     
        Util.IsTest(true);
        Util.isTesting = true;
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
		
    	//Set Opportunity flag
        Util.BypassAllTriggers = true;
       
    	//Insert List of Opportunity
        insert parentOpportunities;
        
        //List of Program Opportunities
        List<Opportunity> programOpportunities = new List<Opportunity>();
        
        //Add new Program Opportunity in list
        programOpportunities.add(new Opportunity(Name = 'Will Auto Populate PO 1', RecordTypeId = recordTypes[0].Id, StageName = 'Active in SlowTrack',
        										 Program_Proposal_Status__c = 'Primary Proposal', Program__c = products[1].Program__c,
        										 Parent_Opportunity__c = parentOpportunities[0].Id, CloseDate = System.today()));
		
		programOpportunities.add(new Opportunity(Name = 'Will Auto Populate PO 1', RecordTypeId = recordTypes[0].Id, StageName = 'Active in SlowTrack',
        										 Program_Proposal_Status__c = 'Alternate Proposal', Program__c = products[2].Program__c,
        										 Parent_Opportunity__c = parentOpportunities[0].Id, CloseDate = System.today()));
        										 
		//Set Opportunity flag
        Util.BypassAllTriggers = true;
       
    	//Insert List of Opportunity
        insert programOpportunities;
        
        //List of Quote
        List<SBQQ__Quote__c> quotes = new List<SBQQ__Quote__c>();
        
        //Add new quote record in list
        quotes.add(new SBQQ__Quote__c(SBQQ__Status__c = 'Draft', SBQQ__Type__c = 'Quote', SBQQ__Primary__c = true, SBQQ__Opportunity2__c = parentOpportunities[0].Id));
        quotes.add(new SBQQ__Quote__c(SBQQ__Status__c = 'Draft', SBQQ__Type__c = 'Quote', SBQQ__Primary__c = false, SBQQ__Opportunity2__c = parentOpportunities[0].Id));
        
        //Set trigger flags
   		Util.BypassAllTriggers = false;
   		OpportunityTriggerHelper.EXECUTE_TRIGGER_BEFORE_UPDATE = false;
		OpportunityTriggerHelper.EXECUTE_TRIGGER_AFTER_UPDATE = false;
      
        //Insert list of Quote
        insert quotes;
        
        //Query through Contract LOA opps
        List<Opportunity> contractLOAOpps = [Select Id, StageName From Opportunity Where Id IN : parentOpportunities];
        
        //Assert for result
        System.assertEquals(1, contractLOAOpps.size());
        System.assertEquals('Pipeline', contractLOAOpps[0].StageName);
        
        //List of quote line item to insert
   		List<SBQQ__QuoteLine__c> quoteLines = new List<SBQQ__QuoteLine__c>();
   		
   		//Set trigger flags
   		Util.BypassAllTriggers = true;
   		
   		//Add new Quote lines n list
   		insert new SBQQ__QuoteLine__c(SBQQ__Quote__c = quotes[0].Id, SBQQ__Product__c = products[1].Id, SBQQ__NetPrice__c = 100,
   											  Program_Opportunity__c = programOpportunities[0].Id);
		
		//Set trigger flags
   		Util.BypassAllTriggers = true;
   		
   		insert new SBQQ__QuoteLine__c(SBQQ__Quote__c = quotes[1].Id, SBQQ__Product__c = products[2].Id, SBQQ__NetPrice__c = 500,
   											  Program_Opportunity__c = programOpportunities[1].Id);
		
   		//Test Start from here
   		Test.startTest();
   		
   		//Change Primary flag on the quote
   		quotes[0].SBQQ__Primary__c = false;
   		quotes[1].SBQQ__Primary__c = true;
   		
   		//Set trigger flags
   		Util.BypassAllTriggers = false;
   		OpportunityTriggerHelper.EXECUTE_TRIGGER_BEFORE_UPDATE = false;
		OpportunityTriggerHelper.EXECUTE_TRIGGER_AFTER_UPDATE = false;
		SBQQ_QuoteLineTriggerHelper.executeSyncProgramOpportunitiesLogic = false;
		
		//Update
		update quotes; 
		
		//Query through Program opps
        List<Opportunity> programOpps = [Select Id, Program_Proposal_Status__c From Opportunity Where Id =: programOpportunities[0].Id];
        
        //Assert for result
        System.assertEquals(1, programOpps.size());
        System.assertEquals('Alternate Proposal', programOpps[0].Program_Proposal_Status__c);
        
        //Query through Program opps
        programOpps = [Select Id, Program_Proposal_Status__c From Opportunity Where Id =: programOpportunities[1].Id];
        
        //Assert for result
        System.assertEquals(1, programOpps.size());
        System.assertEquals('Primary Proposal', programOpps[0].Program_Proposal_Status__c);
        
   		//Test Stop Here
   		Test.stopTest();
    }
}