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
@isTest
private class Test_AssociateContractABCwithInvoice {
    /*
    Purpose:            Test class for AssociateContractABCWithInvoiceBilling class
   
    Revision Log:       v1.0 - (Bhavi-10/02/2011) Created code.
						v1.1 - Modified By - Mahendra Swarnkar - 4/2/2016 - CR-20160113-9513
    
    Code Coverage:      94%
                        
    */

    static testMethod void myUnitTest() {
        
        //create Test Data
        Util.IsTesting = true;
        
        //payer Account
        Account payerAccount = new Account(Name = 'Test Account');
        insert payerAccount;
        
        //Insert Program
        Program__c program = new Program__c(Name = 'Test program', Create_memberships__c = 'NO', Business_line__c = 'CLN');
        insert program;
        
        //Insert Contract ABC
        Contract__c contractABC = new Contract__c(Name = 'Test Contract Data', Payer_Account__c = payerAccount.Id, Program__c = program.Id);
        insert contractABC;
        
        //Set the request parameter for controller
        ApexPages.currentPage().getParameters().put('accountPayerId', contractABC.Payer_Account__c);
        ApexPages.currentPage().getParameters().put('contractABCId', contractABC.Id);
        
        //start test from here
        Test.startTest();
        
        //instantiate AssociateContractABCWithInvoiceBilling instance
        AssociateContractABCWithInvoiceBilling controller = new AssociateContractABCWithInvoiceBilling(new ApexPages.StandardController(new Invoice_Billing_Schedule__c()));
        
        //assert for billing Schedule institution id
        System.assertEquals(payerAccount.Id, controller.invoiceBillingShed.Institution__c);
        
        //call the save detail method
        controller.save();
        
        //assert for the result
        Integer counter = [Select count() from Invoice_Billing_Schedule__c where Institution__c =: payerAccount.Id];
        System.assertEquals(1, counter);
        
        //Query trough Contract ABC record
        contractABC = [Select Id, Invoice_Billing_Schedule__c,Invoice_Billing_Schedule__r.Division__c from Contract__c where Id =: contractABC.Id];
        
        //Asserts on results
        System.assertEquals(controller.invoiceBillingShed.Id, contractABC.Invoice_Billing_Schedule__c);
        System.assertEquals('CLN', contractABC.Invoice_Billing_Schedule__r.Division__c);
        
        //Update Program's Business Line field value to SW
        program.Business_line__c = 'SW';
        update program;
        
        //Re-instantiate AssociateContractABCWithInvoiceBilling instance
        controller = new AssociateContractABCWithInvoiceBilling(new ApexPages.StandardController(new Invoice_Billing_Schedule__c()));
        
        //call the save detail method
        controller.save();
        
        //Query trough Contract ABC record
        contractABC = [Select Id, Invoice_Billing_Schedule__c,Invoice_Billing_Schedule__r.Division__c from Contract__c where Id =: contractABC.Id];
        
        //Asserts on results
        System.assertEquals('SW', contractABC.Invoice_Billing_Schedule__r.Division__c);
        
        //Update Program's Business Line field value to other than SW and CLN
        program.Business_line__c = 'PT';
        update program;
       
        //Re-instantiate AssociateContractABCWithInvoiceBilling instance
        controller = new AssociateContractABCWithInvoiceBilling(new ApexPages.StandardController(new Invoice_Billing_Schedule__c()));
        
        //call the save detail method
        controller.save();
        
        //Query trough Contract ABC record
        contractABC = [Select Id, Invoice_Billing_Schedule__c,Invoice_Billing_Schedule__r.Division__c from Contract__c where Id =: contractABC.Id];
        
        //Asserts on results
        System.assertEquals('ABC Corporate', contractABC.Invoice_Billing_Schedule__r.Division__c);
        
        //set invalid id in URL
        ApexPages.currentPage().getParameters().put('contractABCId', 'Invalid Id');
        
        //call the save detail method
        controller.save();
        
        //Check for the page messages
        System.assert(ApexPages.hasMessages(ApexPages.Severity.ERROR));
        
        //remove contractABCId from request parameter
        ApexPages.currentPage().getParameters().remove('contractABCId');
        
        //call the save detail method
        controller.save();
        
        //Check for the page messages
        //System.assert(ApexPages.hasMessages(ApexPages.Severity.INFO));
        
        //stop test here
        Test.stopTest();
    }
}