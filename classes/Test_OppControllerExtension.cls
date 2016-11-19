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
private class Test_OppControllerExtension {
/**
  *   Purpose         :   Test class for OppControllerExtension
  *            
  *   Create By       :   Subhash Garhwal
  * 
  *   Created Date    :   07/11/2016
  *
  *   Revision Log    :   V_1.0 - Created - Subhash Garhwal - CR-20160414-9762
  * 
  *   Coverage        :   V_1.0 - 
  **/
      
    // TO DO: implement unit test     
    static testMethod void myUnitTest() {
        
        /***************      Test data        **************/
        
        //Bypass Dupeblocker
        Util.IsTest(true);
        
        //ByPass all the triggers
        Util.byPassAllTriggers = true;
        
        //Account
        Account acc = new Account(Name = 'Test Account');
        
        //Insert
        insert acc;
        
        //Assert
        System.assert(acc != null);
        
        //Query through record type to get Opp record types
        List<RecordType> recordTypes = [Select Id From RecordType Where SobjectType = 'Opportunity' AND DeveloperName IN : CPQConstants.SET_OPPORTUNITY_CPQ_RT_DEVELOPER_NAME ORDER BY DeveloperName ASC];
        
        //Instance of Opportunity
        Opportunity opp = new Opportunity(CloseDate = System.today().addDays(10));
        
        //Start Testing from here
        Test.startTest();
        
        //Pass Parameters in URL
        ApexPages.currentPage().getParameters().put('opp3', 'Will Auto Populate');
        ApexPages.currentPage().getParameters().put('RecordType', recordTypes[0].Id);
        ApexPages.currentPage().getParameters().put('accId', acc.Id);
        
        //Standard controller       
        ApexPages.StandardController sc = new ApexPages.standardController(opp);
        
        //Controller
        OppControllerExtension controller = new OppControllerExtension(sc);
        
        //Assert for result
        System.assertEquals(CPQConstants.OPPORTUNITY_INFO_SECTION_STAGE_ONE_NEW + ',' + CPQConstants.PROGRAM_OPP_PIPELINE_SECTION_NEW, controller.flowControl);
        System.assertEquals(recordTypes[0].Id, controller.opp.RecordTypeId);
        System.assertEquals(acc.Id, controller.opp.AccountId);
        
        //Call Save method
        controller.doSave();
        
        //Query through Opportunities
        List<Opportunity> opps = [Select Id, Name, CloseDate From Opportunity];
        
        //Assert for result
        System.assertEquals(1, opps.size());
        
        /***********    Program Opp Testing (When Parent Opp is On Deck stage)     **********/
        //Set Parent Id in URL
        ApexPages.currentPage().getParameters().put('pOppId', opps[0].Id);
        
        //Set Standard Controller
        sc = new ApexPages.standardController(new Opportunity(Program_Proposal_Status__c = 'Alternate Proposal'));
        
        //controller
        controller = new OppControllerExtension(sc);
        
        //Asserts for result
        System.assertEquals(opps[0].Id, controller.opp.Parent_Opportunity__c);
        System.assertEquals(acc.Id, controller.opp.AccountId);
        System.assertEquals(opps[0].CloseDate, controller.opp.CloseDate);
        System.assertEquals(CPQConstants.OPPORTUNITY_STAGE_PROSPECT, controller.opp.StageName);
        System.assertEquals(CPQConstants.OPPORTUNITY_SOURCE_STAGE_ON_DECK, controller.opp.Source_Stage__c);
        
        //Call Save method
        controller.doSave();
        
        /***********    Program Opp Testing (When Parent Opp is On Deck stage) End     **********/
        
        //Instance of Quote
        SBQQ__Quote__c quote = new SBQQ__Quote__c(SBQQ__BillingName__c = 'quotes 1', SBQQ__Opportunity2__c = opps[0].Id, SBQQ__Primary__c = true);
        
        //Insert
        insert quote;
        
        //Set Standard Controller
        sc = new ApexPages.standardController(opps[0]);
        
        //controller
        controller = new OppControllerExtension(sc);
        
        //Asset for result
        System.assertEquals(CPQConstants.OPPORTUNITY_ON_DECK_STAGE_OPTIONS, controller.stageValues);
        System.assert(String.isNotBlank(controller.flowControl));
        
        //Change Opp stage
        controller.opp.StageName = 'Pipeline';
        
        //Call do save method
        controller.doSave();
        
        //Query through Opportunities
        opps = [Select Id, Name From Opportunity Where Parent_Opportunity__c = null];
        
        //Assert for result
        System.assertEquals(1, opps.size());
        
        /***********    Program Opp Testing (When Parent Opp is Piepline stage)     **********/
        //Set Parent Id in URL
        ApexPages.currentPage().getParameters().put('pOppId', opps[0].Id);
        
        //Set Standard Controller
        sc = new ApexPages.standardController(new Opportunity());
        
        //controller
        controller = new OppControllerExtension(sc);
        
        //Query through Program Opps
        List<Opportunity> programOpportunities = [Select Id From Opportunity Where Parent_Opportunity__c =: opps[0].Id];
        
        //Set Standard Controller
        sc = new ApexPages.standardController(new Opportunity());
        
        //controller
        controller = new OppControllerExtension(sc);
        
        /***********    Program Opp Testing (When Parent Opp is On Deck stage) End     **********/
        
        //Set Standard Controller
        sc = new ApexPages.standardController(opps[0]);
        
        //controller
        controller = new OppControllerExtension(sc);
        
        //Asset for result
        System.assertEquals(CPQConstants.OPPORTUNITY_ON_PIPELINE_STAGE_OPTIONS, controller.stageValues);
        System.assert(String.isNotBlank(controller.flowControl));
        
        //Change Opp stage
        controller.opp.StageName = CPQConstants.OPPORTUNITY_STAGE_CONTRACT_REC_SEND_TO_FINANCE;
        
        //Call do save method
        controller.doSave();
        
        //Query through Opportunities
        opps = [Select Id, Name From Opportunity Where Parent_Opportunity__c = null];
        
        //Assert for result
        System.assertEquals(1, opps.size());
        
        /***********    Program Opp Testing (When Parent Opp is Send to Finance stage)     **********/
        
        //Set Parent Id in URL
        ApexPages.currentPage().getParameters().put('pOppId', opps[0].Id);
        
        //Set Standard Controller
        sc = new ApexPages.standardController(new Opportunity());
        
        //controller
        controller = new OppControllerExtension(sc);
        
        //Query through Program Opps
        programOpportunities = [Select Id From Opportunity Where Parent_Opportunity__c =: opps[0].Id];
        
        //Set Standard Controller
        sc = new ApexPages.standardController(programOpportunities[0]);
        
        //controller
        controller = new OppControllerExtension(sc);
        
        /***********    Program Opp Testing (When Parent Opp is On Deck stage) End     **********/
        
        //Set Standard Controller
        sc = new ApexPages.standardController(opps[0]);
        
        //controller
        controller = new OppControllerExtension(sc);
        
        //Asset for result
        System.assertEquals(CPQConstants.OPPORTUNITY_ON_CRSTF_STAGE_OPTIONS, controller.stageValues);
        System.assert(String.isNotBlank(controller.flowControl));
        
        //Change Opp stage
        controller.opp.StageName = CPQConstants.OPPORTUNITY_STAGE_SEND_TO_FINANCE_OPP_REJECTED;
        
        //Call do save method
        controller.doSave();
        
        //Query through Opportunities
        opps = [Select Id, Name From Opportunity Where Parent_Opportunity__c = null];
        
        //Assert for result
        System.assertEquals(1, opps.size());
        
        /***********    Program Opp Testing (When Parent Opp is Finance Rejected Stage stage)     **********/
        //Set Parent Id in URL
        ApexPages.currentPage().getParameters().put('pOppId', opps[0].Id);
        
        //Set Standard Controller
        sc = new ApexPages.standardController(new Opportunity());
        
        //controller
        controller = new OppControllerExtension(sc);
        
        //Query through Program Opps
        programOpportunities = [Select Id From Opportunity Where Parent_Opportunity__c =: opps[0].Id];
        
        //Set Standard Controller
        sc = new ApexPages.standardController(programOpportunities[0]);
        
        //controller
        controller = new OppControllerExtension(sc);
        
        
        /***********    Program Opp Testing End     **********/
        
        //Query through Opportunities
        opps = [Select Id, Name From Opportunity Where Parent_Opportunity__c = null];
        
        //Assert for result
        System.assertEquals(1, opps.size());
        
        //Set Standard Controller
        sc = new ApexPages.standardController(opps[0]);
        
        //controller
        controller = new OppControllerExtension(sc);
        
        //Asset for result
        System.assertEquals(CPQConstants.OPPORTUNITY_ON_STFR_STAGE_OPTIONS, controller.stageValues);
        System.assert(String.isNotBlank(controller.flowControl));
        
        //Closed Opp case
        controller.opp.StageName = CPQConstants.OPPORTUNITY_STAGE_CLOSED_WON;
        
        //call do Save method
        controller.doSave();
        
        /***********    Program Opp Testing (When Parent Opp is Finance Rejected Stage stage)     **********/
        //Set Parent Id in URL
        ApexPages.currentPage().getParameters().put('pOppId', opps[0].Id);
        
        //Set Standard Controller
        sc = new ApexPages.standardController(new Opportunity());
        
        //controller
        controller = new OppControllerExtension(sc);
        
        //Query through Program Opps
        programOpportunities = [Select Id From Opportunity Where Parent_Opportunity__c =: opps[0].Id];
        
        //Set Standard Controller
        sc = new ApexPages.standardController(programOpportunities[0]);
        
        //controller
        controller = new OppControllerExtension(sc);
        
        //Change Program Opp stage
        controller.opp.StageName = CPQConstants.OPPORTUNITY_STAGE_CLOSED_WON;
        
        //Call doSave method
        controller.doSave();
        /***********    Program Opp Testing End     **********/
        
        //Query through Program Opps
        programOpportunities = [Select Id From Opportunity Where Parent_Opportunity__c =: opps[0].Id];
        
        //Set Standard Controller
        sc = new ApexPages.standardController(programOpportunities[0]);
        
        //controller
        controller = new OppControllerExtension(sc);
        
        //Stop Test here
        Test.stopTest();
    }
}