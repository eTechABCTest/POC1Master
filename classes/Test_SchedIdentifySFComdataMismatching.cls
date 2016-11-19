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
private class Test_SchedIdentifySFComdataMismatching {
/**
 *  Description     :   Test class for Sched_IdentifySFComdataMismatching
 *
 *  Created By      :   Bhavi Sharma
 *
 *  Created Date    :   05/19/2015
 *
 *  Revision Logs   :   V_1.0 - Created
 *
 *  Coverage        :
 *
 **/
    //test method
    static testMethod void testScheduler() {
 		
 		Credit_Card_Settings__c configCCDefaultSetting = TestUtilities.CreateCreditCardSettings();
        insert configCCDefaultSetting; 
        
        //Set helper class variable
        CreditCardHelper.configDefaults = configCCDefaultSetting;
        CreditCardConstants.CONFIG_DEFAULT = configCCDefaultSetting;
        
        //String for the Job Id
        String jobId;
        
        //test starts here
        Test.startTest();
                
        //initialize response method number
        CreditCardServiceMockClass.methodNumber = 2;
        
        //instance of scheduler class
        Sched_IdentifySFComdataMismatching schedIdentifySFComdataMismatching = new Sched_IdentifySFComdataMismatching();
        
        //string to hold cron expression
        String sch = '0 0 23 * * ?';
           
        //call the schedule method of sytem
        jobId = System.schedule('Test_SchedIdentifySFComdataMismatching', sch, schedIdentifySFComdataMismatching);
    
        //test stops here
        Test.stopTest();
        
        //Verify the results
        CronTrigger testJob = [select Id, TimesTriggered, NextFireTime from CronTrigger where Id = :jobId LIMIT 1];
        system.assertNotEquals(null,testJob.NextFireTime);   	
    }
}