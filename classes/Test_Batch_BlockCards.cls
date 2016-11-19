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
private class Test_Batch_BlockCards {
/**
 *  Description     :   Test class for Batch_BlockCards
 *
 *  Created By      :   Bhavi Sharma
 *
 *  Created Date    :   12/8/2014
 *
 *  Revision Logs   :   V_1.0 - Created
 * 						V_1.1 - Modified - 12/1/2015- By Mahendra Swarnkar - Removed the Credit_Limit__c field reference, as it will no longer in use.
 *
 *  Coverage        :   90%
 *
 **/
    //Method to test functionality of Batch_BlockCards
    static testMethod void myUnitTest() {
        
        //List of contacts
        List<Contact> contacts = new List<Contact>();
        contacts.add(new Contact(LastName = 'Test'));
        contacts.add(new Contact(LastName = 'Test'));
        contacts.add(new Contact(LastName = 'Test'));
        contacts.add(new Contact(LastName = 'Test'));
        insert contacts;
        
        //Create a Provider Profile instance
        Provider_Profile__c pP = new Provider_Profile__c(Provider_Profile_ID__c = '2');
        insert pP;
        
        //Create a test ABC Profile record
        ABC_Profile__c abcProfile = new ABC_Profile__c(Name = 'Test', 
                                                            Over_aging_Warning_days__c = 35, 
                                                            Over_aging_Maximum_days__c = 45, 
                                                            Over_balance_Warning_threshold_1__c = .75, 
                                                            Over_balance_Warning_threshold_2__c = .90, 
                                                            Over_balance_Countdown_days__c = 3,
                                                            Credit_Limit__c = 1000,
                                                            Provider_Profile__c = pP.Id);
        insert abcProfile;
        
        //List of portfolio
        List<Portfolio__c> portfolios = new List<Portfolio__c>();
        portfolios.add(new Portfolio__c(Name = 'Test-1', Card_Holder__c = contacts[0].Id, Status__c = CreditCardConstants.PORTFOLIO_STATUS_DEACTIVATED,
                        Final_warning_Balance__c = Date.Today().addDays(-3), Balance__c = 2000,
                        Deactivation_Reason__c = CreditCardConstants.PORTFOLIO_DEACTIVATION_REASON_OVER_CREDIT_BALANNCE_LIMIT,
                        Advisory_Profile__c = abcProfile.Id));
        insert portfolios;
        System.debug('::::::::::' + [Select Utilized_Balance__c, Final_warning_Balance__c, Deactivation_Reason__c, Status__c from Portfolio__c where Id =: portfolios[0].Id]);
        
        //List of Credit card
        List<Credit_Card__c> creditCards = new List<Credit_Card__c>();
        creditCards.add(new Credit_Card__c(Name = 'Credit Card-1', Payment_Account__c = portfolios[0].Id, Status__c = CreditCardConstants.CC_STATUS_ACTIVE,
                            Card_Deactivation_Status__c = null, Card_Employee_Number__c = 'A1234'));
        insert creditCards;
        System.debug('::::::::::' + [Select Utilized_Balance__c, Final_warning_Balance__c, Deactivation_Reason__c, Status__c from Portfolio__c where Id =: portfolios[0].Id]);
        
        //Update Portfolio
        portfolios[0].Status__c = CreditCardConstants.PORTFOLIO_STATUS_DEACTIVATED;
        update portfolios;
        
        //Test starts here
        Test.startTest();
        
        //Initilize batch
        Batch_BlockCards bc  = new Batch_BlockCards();   
        Database.executeBatch(bc, 10);      
        
        //Test stoops here   
        Test.stopTest();
        
        //Query through Credit cards
        System.debug('::::::::::' + [Select Payment_Account__r.Utilized_Balance__c, Payment_Account__r.Final_warning_Balance__c, Payment_Account__r.Deactivation_Reason__c, Payment_Account__r.Status__c, Status__c, Card_Deactivation_Status__c from Credit_Card__c where Id =: creditCards[0].Id]);
        creditCards = [Select Status__c, Card_Deactivation_Status__c, Card_Deactivation_Reason__c From Credit_Card__c WHERE ID IN: creditCards Order by Card_Employee_Number__c];
        
        //Assert for results
        System.assertEquals(CreditCardConstants.CC_STATUS_DEACTIVATED, creditCards[0].Status__c);
        System.assertEquals(CreditCardConstants.CC_DEACTIVATION_STATUS_DEACTIVATED, creditCards[0].Card_Deactivation_Status__c);
    }
}