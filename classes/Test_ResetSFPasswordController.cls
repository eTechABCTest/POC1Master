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
private class Test_ResetSFPasswordController {

    static testMethod void testResetUser_Success() {
        // create a new active user with an Active Directory ID
        User u = TestUtilities.CreateNewUser(false);
        u.IsActive = true;
        u.Active_Directory_ID__c = 'BSmith';
        insert u;
        
        // Encrypt the Active Directory Id
        String encryptedId = EncryptionHelper.EncryptString(u.Active_Directory_ID__c);
        //encryptedId = EncodingUtil.urlEncode(encryptedId, 'UTF-8');
        
        // setup the page and parameters
        PageReference pageRef = Page.ResetSFPassword;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('ActiveDirectoryId', encryptedId);
        ResetSFPasswordController controller = new ResetSFPasswordController();
        
        // attempt the PW reset
        controller.ResetPW();
        
        // verify that the result came back successful
        system.assertEquals(true, controller.IsSuccess);
    }
    
    static testMethod void testResetUser_Fail() {
        // create a new active user with an Active Directory ID
        User u = TestUtilities.CreateNewUser(false);
        u.IsActive = true;
        u.Active_Directory_ID__c = 'BSmith';
        insert u;
        
        // Encrypt an incorrect Active Directory ID
        String encryptedId = EncryptionHelper.EncryptString('Non-ExistentID');
        
        // setup the page and parameters
        PageReference pageRef = Page.ResetSFPassword;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('ActiveDirectoryId', encryptedId);
        ResetSFPasswordController controller = new ResetSFPasswordController();
        
        // attempt the PW reset
        controller.ResetPW();
        
        // verify that the result came back as a failure
        system.assertEquals(false, controller.IsSuccess);
    }
}