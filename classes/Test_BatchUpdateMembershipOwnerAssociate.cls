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
private class Test_BatchUpdateMembershipOwnerAssociate {
/**
 *	Purpose			:	Test class for Batch_UpdateMembershipOwnerAssociate
 *
 *	Create By		:	Bhavi Sharma
 *
 *	Created Date	:	06/14/2013
 *
 *	Current Version	:	v1.0
 *
 *	Revision Logs	:	v1.0 - Created - CR-20130411-2851
 *
 *	Coverage			:	100%
 *
 **/
    static testMethod void myUnitTest() {
        
        //Find user with Profile = System Adminsitrator
        Profile sysAdminProfile = [Select id from Profile where Name = 'System Administrator' limit 1];
        
        //Create user record
        User usr1 = new User(Alias = 'standt', Email='standarduser@testorg.com', EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
            				LocaleSidKey='en_US', ProfileId = sysAdminProfile.Id, TimeZoneSidKey='America/Los_Angeles',UserName=Math.random()+'@testorg.com');
        
        insert usr1;
        
        //Create user record
        User usr2 = new User(Alias = 'standt', Email='test@testorg.com', EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
            				LocaleSidKey='en_US', ProfileId = sysAdminProfile.Id, TimeZoneSidKey='America/Los_Angeles',UserName=Math.random()+'@testorg.com', Associate__c = usr1.Id);
       
        insert usr2;
        
        //Create user record
        User usr3 = new User(Alias = 'standt', Email='test3@testorg.com', EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
            				LocaleSidKey='en_US', ProfileId = sysAdminProfile.Id, TimeZoneSidKey='America/Los_Angeles',UserName=Math.random()+'@testorg.com');
        
        insert usr3;
        
        //insert Membership record
        Membership__c membership = new Membership__c(Name = 'Test-Membership', OwnerId = usr2.Id);
        insert membership;
        
        //Test starts here
        Test.startTest();
        
        //Query result of Membership
        membership = [SELECT Owner_Associate__c FROM Membership__c WHERE Id =: membership.Id];
        
        //assert statment
        System.assertEquals(usr1.Id, membership.Owner_Associate__c);
        
        //update usr2
        usr2.Associate__c = usr3.Id;
        Util.BypassAllTriggers = false;
        update usr2;
        
        //test stop here
        Test.stopTest();
        
        //Query result of Membership
        membership = [SELECT Owner_Associate__c FROM Membership__c WHERE Id =: membership.Id];
        
        //assert statment
        System.assertEquals(usr3.Id, membership.Owner_Associate__c);
    }
}