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
private class Test_MemberInteractionContactMtMTrigger {
/**
    Purpose          :   Test class for Trigger_MemberInteractionContactMtM and MemberInteractionContactMtMTriggerHelper.
                
    Created By       :   Abhinav Sharma
    
    Created Date     :   08/24/2015
    /
    /evision Log     :   v1.0 - Created - 08/24/2015 - 90%
 **/
	
    //Added By - Abhinav Sharma - 08/24/2015 - CR-20150813-9155
    static testmethod void test_validateAttendeesForInteraction() {
        
        //Bypass Dupeblocker
        Util.IsTest(true);
        Util.BypassAllTriggers = true;
        
        // This code runs as the system user
		Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator'];
        
        //User (GMT Time Zone)
		User u = new User(Alias = 'standt', Email='standarduser@testorg.com', 
							EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
      						LocaleSidKey='en_US', ProfileId = p.Id, TimeZoneSidKey = 'GMT',
      						UserName=Math.random() + '@test.com',
                         	isActive = true);

		//Running code in context of a "GMT" time zone user
      	System.runAs(u) {
        
            //Account (institution)
            Account a = new Account(Name = 'testacc ' + Math.random(), Account_Formal_Name__c = 'test', Primary_City__c = 'test');
            insert a;
            
            //Create a list of Contact records
            List<Contact> conList = new List<Contact>();
            
            //create new Contact
            Contact con1 = new Contact(FirstName = 'Test1', LastName = 'Contact1', Email = 'test1@test.com',
                                        Phone = '2121212145', AccountId = a.Id);
            
            //create new Contact
            Contact con2 = new Contact(FirstName = 'Test2', LastName = 'Contact2', Email = 'test2@test.com',
                                        Phone = '3131313190', AccountId = a.Id);
            
            //create new Contact
            Contact con3 = new Contact(FirstName = 'Test3', LastName = 'Contact3', Email = 'test3@test.com',
                                        Phone = '4141414178', AccountId = a.Id);
            
            //create new Contact
            Contact con4 = new Contact(FirstName = 'Test4', LastName = 'Contact4', Email = 'test4@test.com',
                                        Phone = '5151515190', AccountId = a.Id);
            
            //Adding records into the list
            conList.add(con1);
            conList.add(con2);
            conList.add(con3);
            conList.add(con4);
            
            //Insert Contacts
            insert conList;
            
            //Querying eligible record type for interaction
            List<RecordType> rdTypes = [SELECT ID FROM RecordType 
                                        	WHERE IsActive = true
                                       		AND sObjectType = 'Relationship_Interaction__c'
                                       		AND DeveloperName = 'Basic_Interaction'];
            System.assert(rdTypes != null);
            
            //Relationship interaction record
            Relationship_Interaction__c rI = new Relationship_Interaction__c();
            rI.Name = 'Testing ' + Math.random();
            rI.Institution__c = a.Id;
            rI.Primary_Contact__c = conList[0].id;
            rI.Start_Date_Time__c = System.today();
            rI.End_Date_Time__c = System.today().addDays(3);
            rI.Interaction_Level__c = 'In person';
            rI.Interaction_Type__c = 'NASA Sumit';
            rI.Assigned_To__c = u.id;
            rI.RecordTypeId = rdTypes[0].Id;
            insert rI;
            
            //List of MTMs
            List<MemberInteractionContactMtM__c> listOfMtMs = new List<MemberInteractionContactMtM__c>();
            
            //MTM Record
            MemberInteractionContactMtM__c mtm_1 = new MemberInteractionContactMtM__c();
            mtm_1.Contact__c = conList[0].Id;
            mtm_1.Relationship_Interaction__c = rI.id;
            
            MemberInteractionContactMtM__c mtm_2 = new MemberInteractionContactMtM__c();
            mtm_2.Contact__c = conList[1].Id;
            mtm_2.Relationship_Interaction__c = rI.id;
            
            MemberInteractionContactMtM__c mtm_3 = new MemberInteractionContactMtM__c();
            mtm_3.Contact__c = conList[2].Id;
            mtm_3.Relationship_Interaction__c = rI.id;
            
            MemberInteractionContactMtM__c mtm_4 = new MemberInteractionContactMtM__c();
            mtm_4.Contact__c = conList[1].Id;
            mtm_4.Relationship_Interaction__c = rI.id;
            
            MemberInteractionContactMtM__c mtm_5 = new MemberInteractionContactMtM__c();
            mtm_5.Contact__c = conList[3].Id;
            mtm_5.Relationship_Interaction__c = rI.id;
            
            //Adding records into the list
            listOfMtMs.add(mtm_1);
            listOfMtMs.add(mtm_2);
            listOfMtMs.add(mtm_3);
            listOfMtMs.add(mtm_4);
            listOfMtMs.add(mtm_5);
            
            //Start test from here
            Test.startTest();
            
            //Enabling trigger again
            Util.BypassAllTriggers = false;
            
            try {
                //Enabling trigger again
            	Util.BypassAllTriggers = false;
            
                insert listOfMtMs;
                System.assert(false);
            } catch (DmlException e) {
                 System.assert(e.getDmlMessage(0).indexOf(System.Label.Error_Duplicate_Contact_Tagging) > -1);
            }
            
            listOfMtMs = [SELECT ID, Contact__c, Relationship_Interaction__c FROM MemberInteractionContactMtM__c];
            System.assertEquals(0, listOfMtMs.size());
            
            //Adding records into the list
            listOfMtMs = new List<MemberInteractionContactMtM__c>();
            listOfMtMs.add(mtm_1);
            listOfMtMs.add(mtm_2);
            listOfMtMs.add(mtm_3);
            listOfMtMs.add(mtm_5);
            
            //Enabling trigger again
            Util.BypassAllTriggers = false;
            
            //Inert MTM records
            insert listOfMtMs;
            
            //Applying assert to checking for the record rollback since error occured
            listOfMtMs = [SELECT ID, Contact__c, Relationship_Interaction__c FROM MemberInteractionContactMtM__c];
            System.assertEquals(4, listOfMtMs.size());
            
            //Stop test here
            Test.stopTest();
        }        
    }
    
    //Added By - Mahendra Swarnkar - 04/03/2016 - CR-20151229-9481
    static testmethod void test_validateAttendeesForMemberInteraction() {
        
        //Bypass Dupeblocker
        Util.IsTest(true);
        Util.BypassAllTriggers = true;
        
        // This code runs as the system user
		Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator'];
        
        //User (GMT Time Zone)
		User u = new User(Alias = 'standt', Email='standarduser@testorg.com', 
							EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
      						LocaleSidKey='en_US', ProfileId = p.Id, TimeZoneSidKey = 'GMT',
      						UserName=Math.random() + '@test.com',
                         	isActive = true);

		//Running code in context of a "GMT" time zone user
      	System.runAs(u) {
            
            //Project
            Project__c proj = new project__c(name = 'Test Project');
            insert proj;
            
            //Account (institution)
            Account a = new Account(Name = 'testacc ' + Math.random(), Account_Formal_Name__c = 'test', Primary_City__c = 'test');
            insert a;
            
            //Create a list of Contact records
            List<Contact> conList = new List<Contact>();
            
            //create new Contact
            Contact con1 = new Contact(FirstName = 'Test1', LastName = 'Contact1', Email = 'test1@test.com',
                                        Phone = '2121212145', AccountId = a.Id);
            
            //create new Contact
            Contact con2 = new Contact(FirstName = 'Test2', LastName = 'Contact2', Email = 'test2@test.com',
                                        Phone = '3131313190', AccountId = a.Id);
            
            //create new Contact
            Contact con3 = new Contact(FirstName = 'Test3', LastName = 'Contact3', Email = 'test3@test.com',
                                        Phone = '4141414178', AccountId = a.Id);
            
            //create new Contact
            Contact con4 = new Contact(FirstName = 'Test4', LastName = 'Contact4', Email = 'test4@test.com',
                                        Phone = '5151515190', AccountId = a.Id);
            
            //Adding records into the list
            conList.add(con1);
            conList.add(con2);
            conList.add(con3);
            conList.add(con4);
            
            //Insert Contacts
            insert conList;
            
            //Querying eligible record type for interaction
            List<RecordType> rdTypes = [SELECT ID FROM RecordType 
                                        	WHERE IsActive = true
                                       		AND sObjectType = 'Call__c'
                                       		AND DeveloperName = 'Standard'];
            System.assert(rdTypes != null);
            
            //Memberr interaction record
            Call__c mI = new Call__c();
            mI.RecordTypeId = rdTypes[0].Id;
            mI.Institution__c = a.Id;
            mI.Call_Brief_Notes__c = 'Test Subject';
            mI.Call_Date__c = System.today();
            mI.Current_Status__c = 'Scheduled';
            mI.Call_Type__c = 'Data Collection';
            mI.Senior_Member_On_Call__c = conList[0].id;
            mI.Member__c = proj.Id;
            insert mI;
            
            //List of MTMs
            List<MemberInteractionContactMtM__c> listOfMtMs = new List<MemberInteractionContactMtM__c>();
            
            //MTM Record
            MemberInteractionContactMtM__c mtm_1 = new MemberInteractionContactMtM__c();
            mtm_1.Contact__c = conList[0].Id;
            mtm_1.Member_Interaction__c = mI.id;
            
            MemberInteractionContactMtM__c mtm_2 = new MemberInteractionContactMtM__c();
            mtm_2.Contact__c = conList[1].Id;
            mtm_2.Member_Interaction__c = mI.id;
            
            MemberInteractionContactMtM__c mtm_3 = new MemberInteractionContactMtM__c();
            mtm_3.Contact__c = conList[2].Id;
            mtm_3.Member_Interaction__c = mI.id;
            
            MemberInteractionContactMtM__c mtm_4 = new MemberInteractionContactMtM__c();
            mtm_4.Contact__c = conList[1].Id;
            mtm_4.Member_Interaction__c = mI.id;
            
            MemberInteractionContactMtM__c mtm_5 = new MemberInteractionContactMtM__c();
            mtm_5.Contact__c = conList[3].Id;
            mtm_5.Member_Interaction__c = mI.id;
            
            //Adding records into the list
            listOfMtMs.add(mtm_1);
            listOfMtMs.add(mtm_2);
            listOfMtMs.add(mtm_3);
            listOfMtMs.add(mtm_4);
            listOfMtMs.add(mtm_5);
            
            //Start test from here
            Test.startTest();
            
            //Enabling trigger again
            Util.BypassAllTriggers = false;
            
            try {
                //Enabling trigger again
            	Util.BypassAllTriggers = false;
            
                insert listOfMtMs;
                System.assert(false);
            } catch (DmlException e) {
                 System.assert((e.getDmlMessage(0).indexOf(System.Label.Error_Duplicate_Contact_Tagging) > -1));
            }
            
            listOfMtMs = [SELECT ID, Contact__c, Member_Interaction__c FROM MemberInteractionContactMtM__c];
            System.assertEquals(0, listOfMtMs.size());
            
            //Adding records into the list
            listOfMtMs = new List<MemberInteractionContactMtM__c>();
            listOfMtMs.add(mtm_1);
            listOfMtMs.add(mtm_2);
            listOfMtMs.add(mtm_3);
            listOfMtMs.add(mtm_5);
            
            //Enabling trigger again
            Util.BypassAllTriggers = false;
            
            //Inert MTM records
            insert listOfMtMs;
            
            //Applying assert to checking for the record rollback since error occured
            listOfMtMs = [SELECT ID, Contact__c, Member_Interaction__c FROM MemberInteractionContactMtM__c];
            System.assertEquals(4, listOfMtMs.size());
            
            //Stop test here
            Test.stopTest();
        }        
    }
    
    //Added By - Mahendra Swarnkar - 04/03/2016 - CR-20151229-9481
    static testmethod void test_validateAttendeesForReserachStudyInteraction() {
        
        //Bypass Dupeblocker
        Util.IsTest(true);
        Util.BypassAllTriggers = true;
        
        // This code runs as the system user
		Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator'];
        
        //User (GMT Time Zone)
		User u = new User(Alias = 'standt', Email='standarduser@testorg.com', 
							EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
      						LocaleSidKey='en_US', ProfileId = p.Id, TimeZoneSidKey = 'GMT',
      						UserName=Math.random() + '@test.com',
                         	isActive = true);

		//Running code in context of a "GMT" time zone user
      	System.runAs(u) {
        
            //Account (institution)
            Account a = new Account(Name = 'testacc ' + Math.random(), Account_Formal_Name__c = 'test', Primary_City__c = 'test');
            insert a;
            
            //Create a list of Contact records
            List<Contact> conList = new List<Contact>();
            
            //create new Contact
            Contact con1 = new Contact(FirstName = 'Test1', LastName = 'Contact1', Email = 'test1@test.com',
                                        Phone = '2121212145', AccountId = a.Id);
            
            //create new Contact
            Contact con2 = new Contact(FirstName = 'Test2', LastName = 'Contact2', Email = 'test2@test.com',
                                        Phone = '3131313190', AccountId = a.Id);
            
            //create new Contact
            Contact con3 = new Contact(FirstName = 'Test3', LastName = 'Contact3', Email = 'test3@test.com',
                                        Phone = '4141414178', AccountId = a.Id);
            
            //create new Contact
            Contact con4 = new Contact(FirstName = 'Test4', LastName = 'Contact4', Email = 'test4@test.com',
                                        Phone = '5151515190', AccountId = a.Id);
            
            //Adding records into the list
            conList.add(con1);
            conList.add(con2);
            conList.add(con3);
            conList.add(con4);
            
            //Insert Contacts
            insert conList;
            
            //Querying eligible record type for interaction
            List<RecordType> rdTypes = [SELECT ID FROM RecordType 
                                        	WHERE IsActive = true
                                       		AND sObjectType = 'Syndicated_Research_Interaction__c'
                                       		AND DeveloperName = 'Syndicated_Research_Interaction'];
            System.assert(rdTypes != null);
            
            //Research Study Interaction record
            Syndicated_Research_Interaction__c rSI = new Syndicated_Research_Interaction__c();
            rSI.RecordTypeId = rdTypes[0].Id;
            rSI.Name = 'Testing ' + Math.random();
            rSI.Institution__c = a.Id;
            rSI.Contact__c = conList[0].id;
            rSI.Date_of_Interaction__c = System.today();
            rSI.Interaction_Type__c = 'In-Person Meeting';
            rSI.Status__c = 'Scheduled';
            insert rSI;
            
            //List of MTMs
            List<MemberInteractionContactMtM__c> listOfMtMs = new List<MemberInteractionContactMtM__c>();
            
            //MTM Record
            MemberInteractionContactMtM__c mtm_1 = new MemberInteractionContactMtM__c();
            mtm_1.Contact__c = conList[0].Id;
            mtm_1.Research_Study_Interaction__c = rSI.id;
            
            MemberInteractionContactMtM__c mtm_2 = new MemberInteractionContactMtM__c();
            mtm_2.Contact__c = conList[1].Id;
            mtm_2.Research_Study_Interaction__c = rSI.id;
            
            MemberInteractionContactMtM__c mtm_3 = new MemberInteractionContactMtM__c();
            mtm_3.Contact__c = conList[2].Id;
            mtm_3.Research_Study_Interaction__c = rSI.id;
            
            MemberInteractionContactMtM__c mtm_4 = new MemberInteractionContactMtM__c();
            mtm_4.Contact__c = conList[1].Id;
            mtm_4.Research_Study_Interaction__c = rSI.id;
            
            MemberInteractionContactMtM__c mtm_5 = new MemberInteractionContactMtM__c();
            mtm_5.Contact__c = conList[3].Id;
            mtm_5.Research_Study_Interaction__c = rSI.id;
            
            //Adding records into the list
            listOfMtMs.add(mtm_1);
            listOfMtMs.add(mtm_2);
            listOfMtMs.add(mtm_3);
            listOfMtMs.add(mtm_4);
            listOfMtMs.add(mtm_5);
            
            //Start test from here
            Test.startTest();
            
            //Enabling trigger again
            Util.BypassAllTriggers = false;
            
            try {
                insert listOfMtMs;
                System.assert(false);
            } catch (DmlException e) {
                 System.assert(e.getDmlMessage(0).indexOf(System.Label.Error_Duplicate_Contact_Tagging) > -1);
            }
            
            listOfMtMs = [SELECT ID, Contact__c, Research_Study_Interaction__c FROM MemberInteractionContactMtM__c];
            System.assertEquals(0, listOfMtMs.size());
            
            //Adding records into the list
            listOfMtMs = new List<MemberInteractionContactMtM__c>();
            listOfMtMs.add(mtm_1);
            listOfMtMs.add(mtm_2);
            listOfMtMs.add(mtm_3);
            listOfMtMs.add(mtm_5);
            
            //Enabling trigger again
            Util.BypassAllTriggers = false;
            
            //Inert MTM records
            insert listOfMtMs;
            
            //Applying assert to checking for the record rollback since error occured
            listOfMtMs = [SELECT ID, Contact__c, Research_Study_Interaction__C FROM MemberInteractionContactMtM__c];
            System.assertEquals(4, listOfMtMs.size());
            
            //Stop test here
            Test.stopTest();
        }        
    }
}