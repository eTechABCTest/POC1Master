@isTest
private class TestMembership_Key_Contact_UpdateFields
{
    /*
    Purpose:    Test Trigger Membership_Key_Contact_UpdateFields
    
    Create By:          
    
    Last Modified By:   Nathan Banas (SAP) - 1/25/2011
    
    Current Version:    v1.1
    
    Revision Log:       v1.0 - () Created code
                        v1.1 - (NB-2011-01-25) - Added header, code comments, and reviewed code coverage
                        
    Code Coverage as of 1/25/2011: 100%
    */
    
    // Test setting the name for new/updated Contracts based on: Payer Account Name, Program Acronym, and Start Year.
    static testmethod void Membership_Key_Contact_BIBU_UpdateFields()
    { 
        //Bypass Dupeblocker
        Util.IsTest(true);
        Util.IsTesting = true;
        
        Program__c prog = new Program__c(Name = 'tempname', Program_Acronym__c = 'TEST');
        insert prog;
        
        Site_Profile__c sProfile = Test_SiteUserHelper.CreateSiteProfile(SiteUserHelper.SITE_ADVISORY, true);
        
        Contact con = [SELECT Id, Name, Email FROM Contact WHERE Id = :sProfile.Contact__c];
        
        Membership__c testMembership1 = new Membership__c(
            Name='Test Membership 1',
            Program__c = prog.id);
        Membership__c testMembership2 = new Membership__c(
            Name='Test Membership 2',
            Program__c = prog.id);
        insert testMembership1;
        insert testMembership2;
        
        test.startTest();
        Membership_Key_Contact__c testMembershipKeyContact = new Membership_Key_Contact__c(
            Contact__c = con.id,
            Name='Test 1', 
            Role_Type__c = 'PT', 
            Role__c = 'Exec Sponsor', 
            Membership__c = testMembership1.Id);
        
        /* Test Insert */
        insert testMembershipKeyContact;
        
        testMembershipKeyContact = [select Id, Name, Membership__r.Program__r.Program_Acronym__c, Contact__r.FirstName, 
            Contact__r.LastName, Role__c 
            from Membership_Key_Contact__c where Id = :testMembershipKeyContact.Id];
        
        String calculatedname = testMembershipKeyContact.Contact__r.FirstName + ' ' + testMembershipKeyContact.Contact__r.LastName 
                + ' - ' + testMembershipKeyContact.Membership__r.Program__r.Program_Acronym__c 
                + ' - ' + testMembershipKeyContact.Role__c;
        
        System.AssertEquals(calculatedname.substring(0,Math.min(calculatedname.length(), 80)), 
                testMembershipKeyContact.Name);
        
        /* Test Update */
        // Test Role changed
        testMembershipKeyContact.Role_Type__c = 'HCIC programs';
        testMembershipKeyContact.Role__c = 'Key Contact';
        update testMembershipKeyContact;
        
        test.stopTest();
        
        testMembershipKeyContact = [select Id, Name, Membership__r.Program__r.Program_Acronym__c, Contact__r.FirstName, 
            Contact__r.LastName, Role__c 
            from Membership_Key_Contact__c where Id = :testMembershipKeyContact.Id];
        
        calculatedname = testMembershipKeyContact.Contact__r.FirstName + ' ' + testMembershipKeyContact.Contact__r.LastName 
                + ' - ' + testMembershipKeyContact.Membership__r.Program__r.Program_Acronym__c 
                + ' - ' + testMembershipKeyContact.Role__c;
        
        System.AssertEquals(calculatedname.substring(0,Math.min(calculatedname.length(), 80)), 
                testMembershipKeyContact.Name);
    }
}