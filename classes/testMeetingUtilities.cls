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
private class testMeetingUtilities {
	
	// pretty basic test to see if the meeting count is working properly
    static testmethod void testMeetingUtilizationCount() { 
        //Bypass Dupeblocker
        Util.IsTest(true);
    	Account a = TestUtilities.CreateNewAccount(true);
    	Program__c prog = TestUtilities.CreateNewProgram(false);
    	prog.Create_memberships__c = 'No';
    	insert prog;
        // create a membership
        Membership__c membership = TestUtilities.CreateNewMembership(a.Id, prog.Id, true);
        
        List<Meeting_Utilization__c> meetings = new List<Meeting_Utilization__c>();
        
        // create a couple of meeting utilization records
        Meeting_Utilization__c currentMeeting = new Meeting_Utilization__c();
        currentMeeting.Membership__c = membership.Id;
        currentMeeting.Start_Date__c = system.today().addDays(-5);
        currentMeeting.End_Date__c = system.today().addDays(-5);
        meetings.add(currentMeeting);
        
        Meeting_Utilization__c futureMeeting = new Meeting_Utilization__c();
        futureMeeting.Membership__c = membership.Id;
        futureMeeting.Start_Date__c = system.today().addDays(5);
        futureMeeting.End_Date__c = system.today().addDays(5);
        meetings.add(futureMeeting);
        
        List<Utilization_Data_Object__c> teleconferencesToInsert = new List<Utilization_Data_Object__c>();
        // create a teleconf utilization record
        Utilization_Data_Object__c teleconfUtilization = new Utilization_Data_Object__c();
        teleconfUtilization.Membership__c = membership.Id;
        teleconfUtilization.Start_Date__c = system.today().addDays(5);
        teleconfUtilization.End_Date__c = system.today().addDays(5);
        teleconferencesToInsert.add(teleconfUtilization);
        Utilization_Data_Object__c teleconfUtilization2 = new Utilization_Data_Object__c();
        teleconfUtilization2.Membership__c = membership.Id;
        teleconfUtilization2.Start_Date__c = system.today().addDays(-5);
        teleconfUtilization2.End_Date__c = system.today().addDays(-5);
        teleconferencesToInsert.add(teleconfUtilization2);
        // insert the meetings
        test.startTest();
        	insert meetings;
        	insert teleconferencesToInsert;
        test.stopTest();
        
        // grab the newly updated membership
		membership = [SELECT Name, Id, Membership_Meeting_Util_last_12_Mo__c, Membership_Teleconf_Util_last_12_Mo__c ,
					Next_Teleconf_Start_Date__c, Next_Meeting_Start_Date__c, Closest_Active_Meeting_End_Date__c, Closest_Teleconf_End_Date__c
					FROM Membership__c WHERE Id = :membership.Id];
    	
    	system.assertEquals(1, membership.Membership_Meeting_Util_last_12_Mo__c);
    	system.assertEquals(futuremeeting.Start_Date__c, membership.Next_Meeting_Start_Date__c);
    	system.assertEquals(currentMeeting.End_Date__c, membership.Closest_Active_Meeting_End_Date__c);
    }
    
    static testmethod void testMeetingUtilizationCount_Delete() { 
        //Bypass Dupeblocker
        Util.IsTest(true);
    	Account a = TestUtilities.CreateNewAccount(true);
    	Program__c prog = TestUtilities.CreateNewProgram(false);
    	prog.Create_memberships__c = 'No';
    	insert prog;
        // create a membership
        Membership__c membership = TestUtilities.CreateNewMembership(a.Id, prog.Id, true);
        
        List<Meeting_Utilization__c> meetings = new List<Meeting_Utilization__c>();
        
        // create a couple of meeting utilization records
        Meeting_Utilization__c currentMeeting = new Meeting_Utilization__c();
        currentMeeting.Membership__c = membership.Id;
        currentMeeting.Start_Date__c = system.today().addDays(-5);
        currentMeeting.End_Date__c = system.today().addDays(-5);
        meetings.add(currentMeeting);
        
        Meeting_Utilization__c futureMeeting = new Meeting_Utilization__c();
        futureMeeting.Membership__c = membership.Id;
        futureMeeting.Start_Date__c = system.today().addDays(5);
        futureMeeting.End_Date__c = system.today().addDays(5);
        meetings.add(futureMeeting);
        
        List<Utilization_Data_Object__c> teleconferencesToInsert = new List<Utilization_Data_Object__c>();
        // create a teleconf utilization record
        Utilization_Data_Object__c teleconfUtilization = new Utilization_Data_Object__c();
        teleconfUtilization.Membership__c = membership.Id;
        teleconfUtilization.Start_Date__c = system.today().addDays(5);
        teleconfUtilization.End_Date__c = system.today().addDays(5);
        teleconferencesToInsert.add(teleconfUtilization);
        Utilization_Data_Object__c teleconfUtilization2 = new Utilization_Data_Object__c();
        teleconfUtilization2.Membership__c = membership.Id;
        teleconfUtilization2.Start_Date__c = system.today().addDays(-5);
        teleconfUtilization2.End_Date__c = system.today().addDays(-5);
        teleconferencesToInsert.add(teleconfUtilization2);
        // insert the meetings
        test.startTest();
        	insert meetings;
        	insert teleconferencesToInsert;
        	delete meetings;
        	delete teleconferencesToInsert;
        test.stopTest();
        
        // grab the newly updated membership
		membership = [SELECT Name, Id, Membership_Meeting_Util_last_12_Mo__c, Membership_Teleconf_Util_last_12_Mo__c ,
					Next_Teleconf_Start_Date__c, Next_Meeting_Start_Date__c, Closest_Active_Meeting_End_Date__c, Closest_Teleconf_End_Date__c
					FROM Membership__c WHERE Id = :membership.Id];
    	
    	system.assertEquals(0, membership.Membership_Meeting_Util_last_12_Mo__c);
    	system.assertEquals(null, membership.Next_Meeting_Start_Date__c);
    	system.assertEquals(null, membership.Closest_Active_Meeting_End_Date__c);
    	
    	system.assertEquals(0, membership.Membership_Teleconf_Util_last_12_Mo__c);
    	system.assertEquals(null, membership.Next_Teleconf_Start_Date__c);
    	system.assertEquals(null, membership.Closest_Teleconf_End_Date__c);
    }
    
    //02/14/2014 - CR-20120823-1396 - Remove subquery in Batch_MeetingUtilizations - Updated By Abhinav Sharma for making testing senario more bulkified
    // test the MeetingUtilizations batch that will run nightly
    // to ensure all meeting utilization counts are up to date on memberships
    static testmethod void testBatch_MeetingUtilizations() { 
    	
        //Bypass Dupeblocker
        Util.IsTest(true);
    	
    	//Account
    	Account a = TestUtilities.CreateNewAccount(true);
    	
    	//Program
    	Program__c prog = TestUtilities.CreateNewProgram(false);
    	prog.Create_memberships__c = 'No';
    	insert prog;
        
        //Create a membership
        Membership__c membership = TestUtilities.CreateNewMembership(a.Id, prog.Id, false);
        membership.Next_Meeting_Start_Date__c = system.today().addDays(-5);
        
        // bypass all triggers so we can insert this membership with a date < today in the Next_Meeting_Start_Date field
        // This will ensure that our membership gets processed in the batch
        Util.BypassAllTriggers = true;
        	insert membership;
        Util.BypassAllTriggers = false;
        
        //List to hold the "Meeting Utilities" records
        List<Meeting_Utilization__c> meetings = new List<Meeting_Utilization__c>();
        
        //Inserting more than 200 meeting utilization records
        for(Integer i=0; i< 201; i++) {
        	// create a couple of meeting utilization records
	        Meeting_Utilization__c currentMeeting = new Meeting_Utilization__c();
	        currentMeeting.Membership__c = membership.Id;
	        currentMeeting.Start_Date__c = system.today().addDays(-5);
	        currentMeeting.End_Date__c = system.today().addDays(-5);
	        meetings.add(currentMeeting);    
        }
        
        //Adding future meeting
        Meeting_Utilization__c futureMeeting = new Meeting_Utilization__c();
        futureMeeting.Membership__c = membership.Id;
        futureMeeting.Start_Date__c = system.today().addDays(5);
        futureMeeting.End_Date__c = system.today().addDays(5);
        meetings.add(futureMeeting);
        
        // bypass all triggers when inserting so that the trigger doesn't auto-populate the meeting dates/numbers
        Util.BypassAllTriggers = true;
        insert meetings;
        Util.BypassAllTriggers = false;
        
        //List to hold the "Teleconference Utilities" records
        List<Utilization_Data_Object__c> teleconferences = new List<Utilization_Data_Object__c>();
        
        //Inserting more than 200 meeting utilization records
        for(Integer i=0; i< 201; i++) {
        	Utilization_Data_Object__c currentteleconfUtilization = new Utilization_Data_Object__c();
    		currentteleconfUtilization.Membership__c = membership.Id;
	        currentteleconfUtilization.Start_Date__c = system.today().addDays(-5);
	        currentteleconfUtilization.End_Date__c = system.today().addDays(-5);
	        teleconferences.add(currentteleconfUtilization);
        }
        
        //Create a teleconf utilization record
        Utilization_Data_Object__c futureteleconfUtilization = new Utilization_Data_Object__c();
        futureteleconfUtilization.Membership__c = membership.Id;
        futureteleconfUtilization.Start_Date__c = system.today().addDays(5);
        futureteleconfUtilization.End_Date__c = system.today().addDays(5);
        teleconferences.add(futureteleconfUtilization);
        
        // bypass all triggers when inserting so that the trigger doesn't auto-populate the meeting dates/numbers
        Util.BypassAllTriggers = true;
        insert teleconferences;
        Util.BypassAllTriggers = false;
        
        // run the Batch_MeetingUtilizations to set these records correctly
        Test.startTest();
        
    	//Constructor Initialization
    	Batch_MeetingUtilizations batch = new Batch_MeetingUtilizations();
        	
    	// override the standard query so that we only pull our membership record
    	/*batch.Query='SELECT Name, Id, Membership_Meeting_Util_last_12_Mo__c, Membership_Teleconf_Util_last_12_Mo__c ,' +
			'Next_Teleconf_Start_Date__c, Next_Meeting_Start_Date__c, Closest_Active_Meeting_End_Date__c, Closest_Teleconf_End_Date__c,' +
			'(Select Start_Date__c, End_Date__c, Id FROM Meeting_Utilizations__r WHERE (Start_Date__c >= LAST_N_DAYS:365)), ' +
			'(SELECT Start_Date__c, End_Date__c  FROM Teleconference_Utilizations__r WHERE (Start_Date__c >= LAST_N_DAYS:365)) FROM Membership__c ' +
			'WHERE ((Next_Teleconf_Start_Date__c < TODAY OR Next_Meeting_Start_Date__c < TODAY) ' +
			'OR (Closest_Active_Meeting_End_Date__c < LAST_N_DAYS:365 OR Closest_Teleconf_End_Date__c < LAST_N_DAYS:365)) AND Id = \'' + membership.Id + '\'';*/
		
		batch.Query='SELECT Name, Id, Membership_Meeting_Util_last_12_Mo__c, Membership_Teleconf_Util_last_12_Mo__c ,' +
			'Next_Teleconf_Start_Date__c, Next_Meeting_Start_Date__c, Closest_Active_Meeting_End_Date__c, Closest_Teleconf_End_Date__c FROM Membership__c ' +
			'WHERE ((Next_Teleconf_Start_Date__c < TODAY OR Next_Meeting_Start_Date__c < TODAY) ' +
			'OR (Closest_Active_Meeting_End_Date__c < LAST_N_DAYS:365 OR Closest_Teleconf_End_Date__c < LAST_N_DAYS:365)) AND Id = \'' + membership.Id + '\'';
		
    	//Execute Batch
    	Database.executebatch(batch);
        	
        //Stop test here
        Test.stopTest();
        
        // grab the newly updated membership
		membership = [SELECT Name, Id, Membership_Meeting_Util_last_12_Mo__c, Membership_Teleconf_Util_last_12_Mo__c ,
					Next_Teleconf_Start_Date__c, Next_Meeting_Start_Date__c, Closest_Active_Meeting_End_Date__c, Closest_Teleconf_End_Date__c
					FROM Membership__c WHERE Id = :membership.Id];
    	
    	//Assert result for membership count's , with the correct Next Meeting Start/End dates
    	system.assertEquals(202, meetings.size());
    	system.assertEquals(201, membership.Membership_Meeting_Util_last_12_Mo__c);
    	system.assertEquals(meetings[201].Start_Date__c, membership.Next_Meeting_Start_Date__c);
    	system.assertEquals(meetings[200].End_Date__c, membership.Closest_Active_Meeting_End_Date__c);
    	system.assertEquals(202, teleconferences.size());
    	system.assertEquals(201, membership.Membership_Teleconf_Util_last_12_Mo__c);
    	system.assertEquals(teleconferences[201].Start_Date__c, membership.Next_Teleconf_Start_Date__c);
    	system.assertEquals(teleconferences[200].End_Date__c, membership.Closest_Teleconf_End_Date__c);
    }
}