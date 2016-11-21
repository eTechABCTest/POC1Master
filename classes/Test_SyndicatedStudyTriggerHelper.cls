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
private class Test_SyndicatedStudyTriggerHelper {
/**
 *  Description     :   Test class for SyndicatedStudyTriggerHelper
 *
 *  Created By      :   Ajit Surana
 *
 *  Created Date    :   07/10/2014
 *
 *  Revision Logs   :   V_1.0 - Created
 *                      V_1.1 - Modified By - Abhinav Sharma - CR-20150202-8647 - 07/13/2016 - A code refactor CR						
 *
 *  Coverage        :	V_1.1 - SyndicatedStudyTriggerHelper - 100%
 * 						V_1.2 - SyndicatedStudyTriggerHelper - 100%   
 *
 **/

    //Modified By - Abhinav Sharma - CR-20150202-8647 - 07/13/2016 - A code refactor CR
    /** Description : Method to test out the process only "NPD" records and will update the Research Study record
	 *                GPA field value with interactions Product Concept Grade field average values.
    **/
    static testMethod void myUnitTest() {
        
        //Bypass Dupeblocker and triggers
        Util.IsTest(true);
        Util.byPassAllTriggers = true;
        Util.IsTesting = true;
        
        //Create Account
        Account acct = TestUtilities.CreateNewAccount(false);
        insert acct;
        System.assert(acct != null);
        
        // create a contact with a title
        Contact con = TestUtilities.CreateNewContact(false);
        con.Title = 'Head Honcho';
        con.AccountId = acct.Id;
        insert con;
    	System.assert(con != null);
        
        //List to hold the record type
        List<RecordType> recordTypes = new List<RecordType>();
        
        //Set to hold the record type names
        Set<String> recordTypeNames = new Set<String>();
        recordTypeNames.add('NPD');
        recordTypeNames.add('Syndicated_Study');
        
        //loop through record types and populating the collection with records
        for(RecordType rType : [Select Id FROM RecordType WHERE sobjectType = 'Syndicated_Study__c'
                                AND DeveloperName IN : recordTypeNames
                                AND IsActive = true]) {
            recordTypes.add(rType);
        }
        
        //Asserting for the results
        System.assert(recordTypes != null);
        System.assertEquals(2, recordTypes.size());
        
        //List to hold the Account records
        List<Syndicated_Study__c> sStudyList = new List<Syndicated_Study__c>();
        
        //Making data for Syndicated Study records
        sStudyList.add(new Syndicated_Study__c(Name = 'Test1', GPA__c = '', RecordTypeId = recordTypes[0].Id, Research_Type__c = 'Test1'));
        sStudyList.add(new Syndicated_Study__c(Name = 'Test2', GPA__c = '', RecordTypeId = recordTypes[0].Id, Research_Type__c = 'Test2'));
        sStudyList.add(new Syndicated_Study__c(Name = 'Test3', Year__c = '2014', RecordTypeId = recordTypes[1].Id, Research_Type__c = 'Test3'));
        
        //Test starts from here 
        Test.startTest();
        
        //Enabling triggers again
        Util.byPassAllTriggers = false;
        
        //Insert Syndicated study records
        insert sStudyList;
        
        //Asserts for results
        System.assert(sStudyList != null);
        System.assertEquals(3, sStudyList.size());
        
        //Disabling triggers
        Util.byPassAllTriggers = true;
        
        //Retriveing record type related details
        List<RecordType> sdRIRdTypes = [SELECT Id FROM RecordType WHERE sobjectType = 'Syndicated_Research_Interaction__c'
                                			AND DeveloperName = 'NPD'
                                			AND IsActive = true];
        //Asserting for the results
        System.assert(sdRIRdTypes != null);
      	System.assertEquals(1, sdRIRdTypes.size());
        
        //List to hold the Syndicated Research Interaction records
        List<Syndicated_Research_Interaction__c> sRIList = new List<Syndicated_Research_Interaction__c>();
        
        //Making data for Syndicated Research Interaction records
        sRIList.add(new Syndicated_Research_Interaction__c(Primary_Study__c = sStudyList[0].Id, Name = 'Test1', Product_Concept_Grade__c = 'A', Contact__c = con.Id, RecordTypeId = sdRIRdTypes[0].Id, Status__c = 'Test1'));
        sRIList.add(new Syndicated_Research_Interaction__c(Primary_Study__c = sStudyList[0].Id, Name = 'Test2', Product_Concept_Grade__c = 'A', Contact__c = con.Id, RecordTypeId = sdRIRdTypes[0].Id, Status__c = 'Test1'));
        sRIList.add(new Syndicated_Research_Interaction__c(Primary_Study__c = sStudyList[0].Id, Name = 'Test3', Product_Concept_Grade__c = 'B', Contact__c = con.Id, RecordTypeId = sdRIRdTypes[0].Id, Status__c = 'Test1'));
        sRIList.add(new Syndicated_Research_Interaction__c(Primary_Study__c = sStudyList[0].Id, Name = 'Test1', Product_Concept_Grade__c = 'B', Contact__c = con.Id, RecordTypeId = sdRIRdTypes[0].Id, Status__c = 'Test1'));
        sRIList.add(new Syndicated_Research_Interaction__c(Primary_Study__c = sStudyList[0].Id, Name = 'Test2', Product_Concept_Grade__c = 'A', Contact__c = con.Id, RecordTypeId = sdRIRdTypes[0].Id, Status__c = 'Test1'));
        sRIList.add(new Syndicated_Research_Interaction__c(Primary_Study__c = sStudyList[0].Id, Name = 'Test3', Product_Concept_Grade__c = 'C', Contact__c = con.Id, RecordTypeId = sdRIRdTypes[0].Id, Status__c = 'Test1'));
        sRIList.add(new Syndicated_Research_Interaction__c(Primary_Study__c = sStudyList[0].Id, Name = 'Test1', Product_Concept_Grade__c = 'C', Contact__c = con.Id, RecordTypeId = sdRIRdTypes[0].Id, Status__c = 'Test1'));
        sRIList.add(new Syndicated_Research_Interaction__c(Primary_Study__c = sStudyList[0].Id, Name = 'Test2', Product_Concept_Grade__c = 'B', Contact__c = con.Id, RecordTypeId = sdRIRdTypes[0].Id, Status__c = 'Test1'));
        sRIList.add(new Syndicated_Research_Interaction__c(Primary_Study__c = sStudyList[0].Id, Name = 'Test3', Product_Concept_Grade__c = 'A', Contact__c = con.Id, RecordTypeId = sdRIRdTypes[0].Id, Status__c = 'Test1'));
        sRIList.add(new Syndicated_Research_Interaction__c(Primary_Study__c = sStudyList[1].Id, Name = 'Test1', Product_Concept_Grade__c = 'A', Contact__c = con.Id, RecordTypeId = sdRIRdTypes[0].Id, Status__c = 'Test1'));
        sRIList.add(new Syndicated_Research_Interaction__c(Primary_Study__c = sStudyList[1].Id, Name = 'Test2', Product_Concept_Grade__c = 'B', Contact__c = con.Id, RecordTypeId = sdRIRdTypes[0].Id, Status__c = 'Test1'));
        sRIList.add(new Syndicated_Research_Interaction__c(Primary_Study__c = sStudyList[2].Id, Name = 'Test3', Product_Concept_Grade__c = 'C', Contact__c = con.Id, RecordTypeId = sdRIRdTypes[0].Id, Status__c = 'Test1'));
        sRIList.add(new Syndicated_Research_Interaction__c(Primary_Study__c = sStudyList[2].Id, Name = 'Test1', Product_Concept_Grade__c = 'A', Contact__c = con.Id, RecordTypeId = sdRIRdTypes[0].Id, Status__c = 'Test1'));
        
        //Insert Syndicated Research Interaction records
        insert sRIList;
        
        //Asserts for results
        System.assert(sRIList != null);
        System.assertEquals(13, sRIList.size());
        
        //Update test Syndicated Study records
        sStudyList[0].GPA__c = '';
        sStudyList[1].GPA__c = '';
        sStudyList[2].GPA__c = '';
        
        //Enabling triggers
        Util.byPassAllTriggers = false;
        
        //update the records
        update sStudyList;
        
        //Disabling triggers
        Util.byPassAllTriggers = true;
        
        //Query through Syndicated study records
        List<Syndicated_Study__c> sSList = [SELECT Id, Name , GPA__c 
                                            FROM Syndicated_Study__c 
                                            WHERE RecordType.DeveloperName = 'NPD'
                                            ORDER By Research_Type__c ASC];
        
        //Assert for results
        System.assert(sSList != null);
        System.assertEquals(2, sSList.size());
        System.assertEquals('3.22', sSList[0].GPA__c);
        System.assertEquals('3.50', sSList[1].GPA__c);
        
        //Test stops here 
        Test.stopTest();
        
        //Update Syndicated Research Interaction records
        sRIList[0].Product_Concept_Grade__c = 'C';
        sRIList[0].Primary_Study__c = sStudyList[1].Id;
        sRIList[1].Primary_Study__c = null;
        sRIList[3].Product_Concept_Grade__c = '';
        sRIList[10].Product_Concept_Grade__c = 'B';
        sRIList[10].Primary_Study__c = sStudyList[0].Id;
        
        //update Syndicated Research Interaction records
        update sRIList;
        
        //Doing blank update on all test Syndicated Study records
        sStudyList[0].GPA__c = '';
        sStudyList[1].GPA__c = '';
        sStudyList[2].GPA__c = '';
        
        //Enabling triggers
        Util.byPassAllTriggers = false;
        
        //update the records
        update sStudyList;
        
        //Diabling triggers
        Util.byPassAllTriggers = true;
        
        //Retrieving updated details from the database
        sSList = [SELECT Id, Name , GPA__c 
                  FROM Syndicated_Study__c 
                  WHERE RecordType.DeveloperName = 'NPD'
                  ORDER By Research_Type__c ASC];
        
        //Asserting for the results
        System.assert(sSList != null);
        System.assertEquals(2, sSList.size());
        System.assertEquals('3.00', sSList[0].GPA__c);
        System.assertEquals('3.00', sSList[1].GPA__c);
        
        //List to hold the Syndicated Research Interaction records (Will be delete)
        List<Syndicated_Research_Interaction__c> sRIRecordsList = new List<Syndicated_Research_Interaction__c>();
        
        //Populating collection with the records
        sRIRecordsList.add(sRIList[0]);
        sRIRecordsList.add(sRIList[9]);
        
        //Delete Syndicated study records
        delete sRIRecordsList;
        
        //Query through Syndicated Research Interaction records
        sRIRecordsList = [Select Id From Syndicated_Research_Interaction__c];
        
        //Asserting for the results
        System.assert(sRIRecordsList != null);
        System.assertEquals(11, sRIRecordsList.size());
        
        //Doing blank update on all test Syndicated Study records
        sStudyList[0].GPA__c = '';
        sStudyList[1].GPA__c = '';
        sStudyList[2].GPA__c = '';
        
        //Enabling triggers
        Util.byPassAllTriggers = false;
        
        //update the records
        update sStudyList;
        
        //Diabling triggers
        Util.byPassAllTriggers = true;
        
        //Retrieving updated details from the database
        sSList = [SELECT Id, Name , GPA__c 
                  FROM Syndicated_Study__c 
                  WHERE RecordType.DeveloperName = 'NPD'
                  ORDER By Research_Type__c ASC];
        
        //Asserting for the results
        System.assert(sSList != null);
        System.assertEquals(2, sSList.size());
        System.assertEquals('3.00', sSList[0].GPA__c);
        System.assertEquals(null, sSList[1].GPA__c);  
    }
}