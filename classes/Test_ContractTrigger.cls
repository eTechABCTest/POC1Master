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
private class Test_ContractTrigger {
/**
 *  Description     :   Test class to test the functionality of ContractTriggerHelper Trigger
 *            
 *  Create By       :   Subhash Garhwal
 *
 *  Created Date    :   07/11/2016
 *
 *  Revision Log    :   V_1.0 - Created  
 *
 *  Coverage        :   100%
 *
 **/
    static testMethod void myUnitTest() {
        
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
        List<RecordType> recordTypes = [Select Id,Name from RecordType where SobjectType = 'Opportunity' AND isActive = true AND DeveloperName = 'Contract_LOA'];
        
        //Create new account
        Account acc = TestUtilities.CreateNewAccount(true);
        
        //List of Opportunity for Test 
        List<Opportunity> parentOpportunities = new List<Opportunity>();
        
        //Add Parent (Contract LOA) opportunities in list
        parentOpportunities.add(new Opportunity(Name = 'Will Auto Populate', AccountId = acc.Id, StageName = 'On Deck', CloseDate = System.today(),
                                                RecordTypeId = recordTypes[0].Id));
        
        parentOpportunities.add(new Opportunity(Name = 'Will Auto Populate', AccountId = acc.Id, StageName = 'On Deck', CloseDate = System.today(),
                                                RecordTypeId = recordTypes[0].Id));
        
        //Set Opportunity flag
        OpportunityTriggerHelper.EXECUTE_TRIGGER_BEFORE_UPDATE = false;
        OpportunityTriggerHelper.EXECUTE_TRIGGER_AFTER_UPDATE = false;
        Util.BypassAllTriggers = true;      
       
        //Insert List of Opportunity              
        insert parentOpportunities;
        
        //List of Quote
        List<SBQQ__Quote__c> quotes = new List<SBQQ__Quote__c>();
        
        //Add new quote record in list
        quotes.add(new SBQQ__Quote__c(SBQQ__Status__c = 'Draft', SBQQ__Type__c = 'Quote', SBQQ__Primary__c = true, SBQQ__Opportunity2__c = parentOpportunities[0].Id));
        quotes.add(new SBQQ__Quote__c(SBQQ__Status__c = 'Draft', SBQQ__Type__c = 'Quote', SBQQ__Primary__c = true, SBQQ__Opportunity2__c = parentOpportunities[1].Id));
        
        //Trigger Bypass
        Util.BypassAllTriggers = true;
        
        //Set Opportunity flag
        OpportunityTriggerHelper.EXECUTE_TRIGGER_BEFORE_UPDATE = false;
        OpportunityTriggerHelper.EXECUTE_TRIGGER_AFTER_UPDATE = false;
        
        //Test Start from here
        Test.startTest();
        
        //Insert list of Quote
        insert quotes;
        
        //List of quote line item to insert
        List<SBQQ__QuoteLine__c> quoteLines = new List<SBQQ__QuoteLine__c>();
        
        //Add new Quote lines n list
        quoteLines.add(new SBQQ__QuoteLine__c(SBQQ__Quote__c = quotes[0].Id, SBQQ__Product__c = products[1].Id, SBQQ__NetPrice__c = 100));
        quoteLines.add(new SBQQ__QuoteLine__c(SBQQ__Quote__c = quotes[1].Id, SBQQ__Product__c = products[1].Id, SBQQ__NetPrice__c = 500));
        
        //Trigger Bypass
        Util.BypassAllTriggers = true;
        
        //Insert
        insert quoteLines;
        
        //Test stop here
        Test.stopTest();
        
        //Update Opportunity with Stage Name
        parentOpportunities[0].StageName = 'Closed Won';
        parentOpportunities[0].SBQQ__Contracted__c = true;
        
        //Update Opportunity with Stage Name
        parentOpportunities[1].StageName = 'Closed Won';
        parentOpportunities[1].SBQQ__Contracted__c = true;
        
        //Trigger Bypass
        Util.BypassAllTriggers = true;
        
        //DML for update opportunities
        update parentOpportunities;
        
        //Bypass false trigger
        Util.BypassAllTriggers = false;
        
        //Test data of Integrated Account
        Integrated_Account__c integrateAcc = new Integrated_Account__c(Opportunity__c = parentOpportunities[0].Id, Integrated_Account__c = acc.Id);
        
        //Trigger Bypass
        Util.BypassAllTriggers = true;
        
        //Insert Integrated Account
        insert integrateAcc;
        
        //Bypass false
        Util.BypassAllTriggers = false;
        
        //Test data of Contract
        Contract con = new Contract(AccountId = acc.Id, SBQQ__Opportunity__c = parentOpportunities[0].Id, SBQQ__Quote__c = quotes[0].Id);
        
        //Insert contract record
        insert con;
        
        //Query record of contract aaabove created
        List<Contract> cons = [Select Id,SBQQ__Opportunity__c from Contract where SBQQ__Opportunity__c =: parentOpportunities[0].Id];
        
        //Assert
        System.assertEquals(1,cons.size());
        
        //Query records of Integrated account
        List<Integrated_Account__c> intAcc = [Select Id,Opportunity__c from Integrated_Account__c where Opportunity__c =: parentOpportunities[0].Id];
        
        //Assert
        System.assertEquals(1,intAcc.size());
        
        //Query Contarct Integrated Account record whhich is auto created by trigger
        List<Contract_Integrated_Accounts__c> conItnegrateAcc = [Select RecordTypeId, LOA_Contract__c, Integrated_Account__c, Account__c from Contract_Integrated_Accounts__c
                                                                            Where LOA_Contract__c =: con.Id];
        
        //Assert
        System.assertEquals(1,conItnegrateAcc.size());
        System.assertEquals(con.Id,conItnegrateAcc[0].LOA_Contract__c);
        System.assertEquals(intAcc[0].Id,conItnegrateAcc[0].Integrated_Account__c);
        System.assertEquals(acc.Id,conItnegrateAcc[0].Account__c);
        
        //Delete Contract Record
        delete con;
        
        //Query Contarct Integrated Account  record
        conItnegrateAcc = [Select RecordTypeId, LOA_Contract__c, Integrated_Account__c, Account__c from Contract_Integrated_Accounts__c
                                                                            Where Integrated_Account__c =: intAcc[0].Id];
        
        //Assert                                                                    
        System.assertEquals(0,conItnegrateAcc.size());
    }
}