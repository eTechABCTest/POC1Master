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
private class Test_RelationshipInteractionTrigger {
    
    /**
        Purpose         :   Test class for RelationshipInteractionTriggerHelper
                    
        Create By       :   Abhinav Sharma
        
        Created Date    :   10/20/2015
        
        Revision Log    :   v1.0 - Created - Abhinav Sharma - CR-20150930-9283 - 10/20/2015 - 96% code coverage
    **/

    //Common test data setup for entire test class
    @testSetup static void setup() {
        
        //Bypassing triggers
        Util.isTest(true);
        Util.byPassAllTriggers = true;
        
        //Account
        Account account = new Account(Name = 'Baptist Healthcare System - Louisville', 
                                        Account_Formal_Name__c = ' Baptist Healthcare System - Louisville - KY');
        insert account;
        
        //Retreiving "External" Record type for Contact object
        RecordType externalRecordType = [SELECT ID, DeveloperName FROM RecordType 
                                            WHERE SobjectType = 'Contact' AND IsActive = true AND DeveloperName = 'External' LIMIT 1];
        System.assert(externalRecordType != null);
        
        // Create a test Contact
        Contact c = new Contact(accountid = account.id , Lastname = 'testing ' + String.valueOf(Math.random()), recordtypeid = externalRecordType.ID);
        insert c;
        
        //List of record types
        List<RecordType> rdTypes = [SELECT ID FROM RecordType WHERE sObjectType = 'Relationship_Interaction__c'
                                    AND IsActive = true AND DeveloperName = 'Basic_Interaction'];
        System.assert(rdTypes != null);

        //Create common test relationship interactions
        List<Relationship_Interaction__c> testRIs = new List<Relationship_Interaction__c>();
        
        // This code runs as the system user
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator'];
        
        //User (GMT Time Zone)
        User u = new User(Alias = 'standt', Email='standarduser@testorg.com', 
                            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                            LocaleSidKey='en_US', ProfileId = p.Id, TimeZoneSidKey = 'GMT',
                            UserName=Math.random() + '@test.com');

        //Running code in context of a "GMT" time zone user
        System.runAs(u) {
        
            //Populating list with multiple RI records instances
            for(Integer i=0;i<3;i++) {
                testRIs.add(new Relationship_Interaction__c(Name = 'TestAcct ' + i, Institution__c = account.Id, 
                                                            Start_Date_Time__c = System.now(), RecordTypeId = rdTypes[0].Id,
                                                            Interaction_Type__c = '1-on-1 Networking CXO Networking',
                                                            Primary_Contact__c = c.Id, Assigned_To__c = u.Id,
                                                            End_Date_Time__c = System.now().addDays(5), Interaction_Level__c = 'testing'));
            }
            
            //Enabling triggers
            Util.byPassAllTriggers = false;
            insert testRIs;
        }        
    }
    
    //test method to apply assertion over helper class method responsible for populating name field value of RI records
    @isTest static void test_populateNameOnReleationshipInteractions() {
        
        // This code runs as the system user
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator'];
        
        //User (GMT Time Zone)
        User u = new User(Alias = 'standt', Email='standarduser@testorg.com', 
                            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                            LocaleSidKey='en_US', ProfileId = p.Id, TimeZoneSidKey = 'GMT',
                            UserName=Math.random() + '@test.com');

        //Running code in context of a "GMT" time zone user
        System.runAs(u) {
        
            //Start test from here
            Test.startTest();
            
            //List to hold the relationship interactions records
            List<Relationship_Interaction__c> listRInteractions = new List<Relationship_Interaction__c>();
            
            //Get the relationship interaction data via SOQL query
            listRInteractions = [SELECT ID, Name, Start_Date_Time__c FROM Relationship_Interaction__c ORDER By Name ASC LIMIT 5];
            
            //Asserting for the results
            String startDateTimeStr = RelationshipInteractionTriggerHelper.processStartDateTime(listRInteractions[0].Start_Date_Time__c);
            
            //Asserting for the results
            System.assertEquals(3, listRInteractions.size());
            
            //11/11/2015
            if(startDateTimeStr.length() == 10) {
                System.assertEquals('Baptist Healthcare System - Louisville --' + startDateTimeStr + '-1-on-1 Networking CXO Net-01', listRInteractions[0].Name);
                System.assertEquals('Baptist Healthcare System - Louisville --' + startDateTimeStr + '-1-on-1 Networking CXO Net-02', listRInteractions[1].Name);
                System.assertEquals('Baptist Healthcare System - Louisville --' + startDateTimeStr + '-1-on-1 Networking CXO Net-03', listRInteractions[2].Name);
            //11/1/2015    
            } else if(startDateTimeStr.length() == 9) {
                System.assertEquals('Baptist Healthcare System - Louisville --' + startDateTimeStr + '-1-on-1 Networking CXO Netw-01', listRInteractions[0].Name);
                System.assertEquals('Baptist Healthcare System - Louisville --' + startDateTimeStr + '-1-on-1 Networking CXO Netw-02', listRInteractions[1].Name);
                System.assertEquals('Baptist Healthcare System - Louisville --' + startDateTimeStr + '-1-on-1 Networking CXO Netw-03', listRInteractions[2].Name);
            //1/1/2015    
            } else if (startDateTimeStr.length() == 8) {
                System.assertEquals('Baptist Healthcare System - Louisville --' + startDateTimeStr + '-1-on-1 Networking CXO Netwo-01', listRInteractions[0].Name);
                System.assertEquals('Baptist Healthcare System - Louisville --' + startDateTimeStr + '-1-on-1 Networking CXO Netwo-02', listRInteractions[1].Name);
                System.assertEquals('Baptist Healthcare System - Louisville --' + startDateTimeStr + '-1-on-1 Networking CXO Netwo-03', listRInteractions[2].Name);
            }
            
            //Deleting a relationship interaction record
            delete listRInteractions[1];
            
            //Get the relationship interaction data via SOQL query
            listRInteractions = [SELECT ID, Name FROM Relationship_Interaction__c ORDER By Name ASC LIMIT 5];
            
            //Asserting for the results
            System.assertEquals(2, listRInteractions.size());
            
            //11/11/2015
            if(startDateTimeStr.length() == 10) {
                System.assertEquals('Baptist Healthcare System - Louisville --' + startDateTimeStr + '-1-on-1 Networking CXO Net-01', listRInteractions[0].Name);
                System.assertEquals('Baptist Healthcare System - Louisville --' + startDateTimeStr + '-1-on-1 Networking CXO Net-02', listRInteractions[1].Name);
            //11/1/2015    
            } else if(startDateTimeStr.length() == 9) {
                System.assertEquals('Baptist Healthcare System - Louisville --' + startDateTimeStr + '-1-on-1 Networking CXO Netw-01', listRInteractions[0].Name);
                System.assertEquals('Baptist Healthcare System - Louisville --' + startDateTimeStr + '-1-on-1 Networking CXO Netw-02', listRInteractions[1].Name);
            //1/1/2015    
            } else if (startDateTimeStr.length() == 8) {
                System.assertEquals('Baptist Healthcare System - Louisville --' + startDateTimeStr + '-1-on-1 Networking CXO Netwo-01', listRInteractions[0].Name);
                System.assertEquals('Baptist Healthcare System - Louisville --' + startDateTimeStr + '-1-on-1 Networking CXO Netwo-02', listRInteractions[1].Name);
            }
            
            //Update use case
            listRInteractions[0].Interaction_Type__c = 'AB';
            update listRInteractions[0];
            
            //Get the relationship interaction data via SOQL query
            listRInteractions = [SELECT ID, Name FROM Relationship_Interaction__c ORDER By Name ASC LIMIT 5];
            
            //Asserting for the results
            //Asserting for the results
            System.assertEquals(2, listRInteractions.size());
            
            //11/11/2015
            if(startDateTimeStr.length() == 10) {
                System.assertEquals('Baptist Healthcare System - Louisville --' + startDateTimeStr + '-1-on-1 Networking CXO Networ', listRInteractions[0].Name);
                System.assertEquals('Baptist Healthcare System - Louisville --' + startDateTimeStr + '-AB', listRInteractions[1].Name);
            //11/1/2015    
            } else if(startDateTimeStr.length() == 9) {
                System.assertEquals('Baptist Healthcare System - Louisville --' + startDateTimeStr + '-1-on-1 Networking CXO Network', listRInteractions[0].Name);
                System.assertEquals('Baptist Healthcare System - Louisville --' + startDateTimeStr + '-AB', listRInteractions[1].Name);
            //1/1/2015    
            } else if (startDateTimeStr.length() == 8) {
                System.assertEquals('Baptist Healthcare System - Louisville --' + startDateTimeStr + '-1-on-1 Networking CXO Networki', listRInteractions[0].Name);
                System.assertEquals('Baptist Healthcare System - Louisville --' + startDateTimeStr + '-AB', listRInteractions[1].Name);
            }
            
            //Stop test here
            Test.stopTest();
            
            //Disabling trigger agains
            Util.byPassAllTriggers = true;
            
            //Updating institution formal name to null/blank value
            List<Account> accounts = [SELECT Id, Account_Formal_Name__c FROM Account 
                                        WHERE Account_Formal_Name__c != null AND Account_Formal_Name__c != '' LIMIT 3];
            System.assert(accounts != null);
            System.assertEquals(1, accounts.size());
            accounts[0].Account_Formal_Name__c = null;
            update accounts[0];
            
            //Enabling trigger agains
            Util.byPassAllTriggers = false;
            
            //Updating Interaction type on RI records
            listRInteractions[0].Interaction_Type__c = 'BC';
            listRInteractions[1].Interaction_Type__c = 'BC';
            update listRInteractions;
            
            //Get the relationship interaction data via SOQL query
            listRInteractions = [SELECT ID, Name FROM Relationship_Interaction__c ORDER By Name ASC LIMIT 5];
            
            //Asserting for the results
            //Asserting for the results
            System.assertEquals(2, listRInteractions.size());
            System.assertEquals('null-' + startDateTimeStr + '-BC-01', listRInteractions[0].Name);
            System.assertEquals('null-' + startDateTimeStr + '-BC-02', listRInteractions[1].Name);
        }        
    }
}