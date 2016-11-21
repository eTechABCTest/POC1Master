/*
    Purpose         :   Test methods to verify profile functionality.
                
    Create By       :   Victor Hanson
    
    Created Date    :   10/15/2015
    
    Revision Log    :   v1.0 Created - Victor Hanson - 10/15/2015 - CR-20151008-9307
                        
*/
@isTest
private class Test_ProfilePermissions {
	
    /**
     * 
     * @description: verify the ABC Dataloader and Finance Ops profiles have the "View All Data" permission enabled.
     * 
     **/
    static testMethod void testViewAllData() {
        set<string> profilesWithViewAllData = new set<string> { 'ABC Dataloader', 'Finance Ops', 'Specialist' };
        list<Profile> profiles = [SELECT Id, Name, PermissionsViewAllData FROM Profile WHERE Name IN :profilesWithViewAllData];
        for (Profile p : profiles) {
            system.assertEquals(true, p.PermissionsViewAllData, 'The profile "' + p.Name + '" should have the View All Data permission enabled.');
        }
    }
}