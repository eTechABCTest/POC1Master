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
@isTest(seeAllData=false)
private class Test_Batch_CheckRestrictionExpiration {
    /**
        Purpose         :   Test class for Batch_CheckRestrictionExpiration
                    
        Create By       :   Abhinav Sharma
        
        Created Date    :   06/17/2015
        
        Revision Log    :   v1.0 - Created - Abhinav Sharma - CR-20150422-8901
    **/
    
    static testmethod void Batch_CheckRestrictionExpirationTest() { 
        
        //Bypass Dupeblocker
        Util.IsTest(true);
        
        // update restriction so that it is expired
        util.BypassAllTriggers = true;
        
        Account a = new Account(Name = 'DrewTestAccount', Account_Formal_Name__c = 'DrewTestAccount');
        insert a;
        
        Contact c = new Contact(LastName = 'TestContact');
        insert c;

        Restrictions__c r = new Restrictions__c(Expiration_Date__c = Date.today().addDays(5));
        insert r;

        Restricted_MtM__c rmtm = new Restricted_MtM__c(Account__c = a.Id, Contact__c = c.Id, Restriction__c = r.Id, Restriction_Expired__c = false);
        insert rmtm;
        
        r = [SELECT Id, Expiration_Date__c FROM Restrictions__c WHERE Id = :r.Id];
        
        r.Expiration_Date__c = system.today().addDays(-2);
        update r;
        util.BypassALltriggers = false;
        
        r = [SELECT Id, Expiration_Date__c FROM Restrictions__c WHERE Id = :r.Id];
        
        //Assert for the results
        system.assertEquals(system.today().addDays(-2), r.Expiration_Date__c);
        system.assertEquals(r.Id, rmtm.Restriction__c);
            
        //test will start from here
        test.StartTest();
        
        //Execute Batch
        Batch_CheckRestrictionExpiration batch = new Batch_CheckRestrictionExpiration();
        Database.executeBatch(batch,200);
        
        //Test will stop here
        test.StopTest();
        
        //Querying for the updated fields values and applying asserts accordingly
        Restricted_MtM__c retrmtm = [select Restriction_Expired__c, Restriction__r.Expiration_Date__c from Restricted_MtM__c where Id = :rmtm.Id];
        system.assertEquals(true, retrmtm.Restriction_Expired__c);
	}
}