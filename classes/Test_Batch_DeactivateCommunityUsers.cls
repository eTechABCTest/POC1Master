/**
 *  Description     :   Test Batch_DeactivateInactiveCommunityUsers, which updates inactive community users.
 *
 *  Created By      :	Victor Hanson
 *
 *  Created Date    :   05/22/2014
 *
 *  Revision Logs   :   V1.0 - Created
 *
 **/
@isTest
private class Test_Batch_DeactivateCommunityUsers {
	
    static testmethod void testBatch_DeactivateCommunityUsers() {
        
        Util.BypassAllTriggers = true;
        
        User u1, u2, u3, sysAdmin;
        
        //add profile to the community profiles custom setting
        list<Profile> communityProfiles = [SELECT Id, Name FROM Profile WHERE UserType = 'CSPLitePortal' LIMIT 1];
        Profile sysAdminProfile = [SELECT id FROM Profile WHERE Id = :UserInfo.getProfileId()];
        
        Community_Profiles__c cp  = new Community_Profiles__c(name='Community Profile 1',
                                                              Profile_Name__c = communityProfiles[0].Name);
        insert cp;
        
        User thisUser = [ select Id from User where Id = :UserInfo.getUserId() ];
        System.runAs ( thisUser ) {
            
            //create three contacts to associated with active users
            Contact c1 = TestUtilities.CreateNewContact(false);
            Contact c2 = TestUtilities.CreateNewContact(false);
            Contact c3 = TestUtilities.CreateNewContact(false);
            list<Contact> contacts = new list<Contact> { c1, c2, c3 };
                insert contacts;
            
            //create three active users with the community profile
            u1 = TestUtilities.CreatenewUser(communityProfiles[0], false);
            u2 = TestUtilities.CreatenewUser(communityProfiles[0], false);
            u3 = TestUtilities.CreatenewUser(communityProfiles[0], false);
            sysAdmin = TestUtilities.CreatenewUser(sysAdminProfile, false);
            u1.FirstName = 'User1';
            u2.FirstName = 'User2';
            u3.FirstName = 'User3';
            u1.ContactId = c1.Id;
            u2.ContactId = c2.Id;
            u3.ContactId = c3.Id;
            u1.IsActive = true;
            u2.IsActive = true;
            u3.IsActive = true;
            list<User> users = new list<User> { u1, u2, u3, sysAdmin };
                insert users;
            
            //Create a project
            Project__c project = TestUtilities.CreateProject(true);
            
            //Create a case associated with the contact for u1 (ie: c1)
            Case aCase = new Case(Subject = 'testSubject',
                                  Status = '01-New',
                                  Tier_I_Support_Analyst__c = UserInfo.getUserId(),
                                  Priority = 'Low',
                                  Origin = 'Incoming Call',
                                  ContactId = c1.Id,
                                  Description = 'Test Description',
                                  RecordTypeId = Constants.RECORD_TYPE_ID_CASE_PT_SUPPORT, 
                                  Current_Results__c = 'test current results',
                                  Expected_Results__c = 'test expected results',
                                  Project_Source_MS__c = project.Id,
                                  Steps_to_Reproduce_MS__c = 'test steps to reproduce');
            insert aCase;
            
            //create a Project Role for c2
            Project_Role__c projectRole = new Project_Role__c(Project__c = project.Id, 
                                                              Contact__c = c2.Id, 
                                                              SIAM_Portal_Status__c = 'Active');
            insert projectRole;
            
            Util.BypassAllTriggers = false;
        }
        
        system.runAs(sysAdmin) {
            //exeute the batch
            test.startTest();
            database.executeBatch(new Batch_DeactivateInactiveCommunityUsers());
            test.stopTest();
        }
        
        //get the users and see which ones are inactive
        list<User> users = [SELECT Id, ContactId, IsActive FROM User WHERE Id = :u1.Id OR Id = :u2.Id OR Id = :u3.Id];
        
        for (User u : users) {
            if (u.Id == u1.Id) system.assertEquals(true, u.IsActive);
            if (u.Id == u2.Id) system.assertEquals(true, u.IsActive);
            if (u.Id == u3.Id) system.assertEquals(false, u.IsActive);
        }
    }
}