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
private class Test_SyndicatedRITriggerHelper {
    
/**
 *		Purpose			:	Test class for SyndicatedRITriggerHelper
 *               
 * 		Created By      :	Ajit Surana
 *   
 *   	Created Date    :   06/30/2014
 *   
 *   	Revision Log    :   v1.0 - Created - Ajit Surana
 * 							v1.1 - Modified By - Abhinav Sharma - 07/13/2016 - CR-20150202-8646 - To refactor the existing code
 *
 *		Coverage		:	v_1.0 - SyndicatedRITriggerHelper - 90%
 *							v_1.1 - SyndicatedRITriggerHelper - 100%
**/

    //Modified by - Abhinav Sharma - 07/13/2016 - CR-20150202-8646 - To refactor the existing code
    /** Description : Method to test 
     * 					a) Whether the helper class method is only processing "NPD" records with data in the GPA field 
     * 					and whenever a new interaction record is added or existing record is updated/deleted, then it 
     * 					will update the parent Research Study record with Research Study’s GPA field = A = 
     * 					# of NPD interactions with Product Concept Grade = A, B=# of NPD interactions
     *                  with Product Concept Grade = B, c=# of NPD interactions with Product Concept Grade = C
     * 					b) Method will process only "NPD" records and then populate the Instution lookup field with associated contact institution reference.
    **/
    static testMethod void test_populateGPAOnSyndicatedStudy() {
        
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
        
        //Retriveing record type related details
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
        
        //Insert Syndicated study records
        insert sStudyList;
        
        //Assert for the results
        System.assert(sStudyList != null);
        System.assert(sStudyList.size() == 3);
        
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
        sRIList.add(new Syndicated_Research_Interaction__c(Primary_Study__c = sStudyList[0].Id, Name = 'Test2', Product_Concept_Grade__c = 'A', Contact__c = con.Id, RecordTypeId = sdRIRdTypes[0].Id, Status__c = 'Test2'));
        sRIList.add(new Syndicated_Research_Interaction__c(Primary_Study__c = sStudyList[0].Id, Name = 'Test3', Product_Concept_Grade__c = 'B', Contact__c = con.Id, RecordTypeId = sdRIRdTypes[0].Id, Status__c = 'Test3' ));
        sRIList.add(new Syndicated_Research_Interaction__c(Primary_Study__c = sStudyList[0].Id, Name = 'Test1', Product_Concept_Grade__c = 'B', Contact__c = con.Id, RecordTypeId = sdRIRdTypes[0].Id, Status__c = 'Test4' ));
        sRIList.add(new Syndicated_Research_Interaction__c(Primary_Study__c = sStudyList[0].Id, Name = 'Test2', Product_Concept_Grade__c = 'A', Contact__c = con.Id, RecordTypeId = sdRIRdTypes[0].Id, Status__c = 'Test5' ));
        sRIList.add(new Syndicated_Research_Interaction__c(Primary_Study__c = sStudyList[0].Id, Name = 'Test3', Product_Concept_Grade__c = 'C', Contact__c = con.Id, RecordTypeId = sdRIRdTypes[0].Id, Status__c = 'Test6' ));
        sRIList.add(new Syndicated_Research_Interaction__c(Primary_Study__c = sStudyList[0].Id, Name = 'Test1', Product_Concept_Grade__c = 'C', Contact__c = con.Id, RecordTypeId = sdRIRdTypes[0].Id, Status__c = 'Test7' ));
        sRIList.add(new Syndicated_Research_Interaction__c(Primary_Study__c = sStudyList[0].Id, Name = 'Test2', Product_Concept_Grade__c = 'B', Contact__c = con.Id, RecordTypeId = sdRIRdTypes[0].Id, Status__c = 'Test8' ));
        sRIList.add(new Syndicated_Research_Interaction__c(Primary_Study__c = sStudyList[0].Id, Name = 'Test3', Product_Concept_Grade__c = 'A', Contact__c = con.Id, RecordTypeId = sdRIRdTypes[0].Id, Status__c = 'Test9' ));
        sRIList.add(new Syndicated_Research_Interaction__c(Primary_Study__c = sStudyList[1].Id, Name = 'Test1', Product_Concept_Grade__c = 'A', Contact__c = con.Id, RecordTypeId = sdRIRdTypes[0].Id, Status__c = 'Test10' ));
        sRIList.add(new Syndicated_Research_Interaction__c(Primary_Study__c = sStudyList[1].Id, Name = 'Test2', Product_Concept_Grade__c = 'B', Contact__c = con.Id, RecordTypeId = sdRIRdTypes[0].Id, Status__c = 'Test11' ));
        sRIList.add(new Syndicated_Research_Interaction__c(Primary_Study__c = sStudyList[2].Id, Name = 'Test3', Product_Concept_Grade__c = 'C', Contact__c = con.Id, RecordTypeId = sdRIRdTypes[0].Id, Status__c = 'Test12' ));
        sRIList.add(new Syndicated_Research_Interaction__c(Primary_Study__c = sStudyList[2].Id, Name = 'Test1', Product_Concept_Grade__c = 'A', Contact__c = con.Id, RecordTypeId = sdRIRdTypes[0].Id, Status__c = 'Test13' ));
        
        //Test starts from here 
        Test.startTest();
        
        //Enabling triggers
        Util.byPassAllTriggers = false;
        
        //Insert Syndicated Research Interaction records
        insert sRIList;
        
        //Asserts for results
        System.assert(sRIList != null);
        System.assert(sRIList.size() == 13);
        
        //Querying for "Syndicated Study Interaction" records updated details
        //Asserting for the results
        for(Syndicated_Research_Interaction__c sRI : [SELECT ID, Institution__c, Contact__c, RecordTypeId
                                                      FROM Syndicated_Research_Interaction__c]) {
            System.assertNotEquals(null, sRI.Contact__c);
            System.assertEquals(acct.Id, sRI.Institution__c);
            System.assertEquals(sdRIRdTypes[0].Id, sRI.RecordTypeId);                                              
        }
        
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
        
        //Update Syndicated Research Interaction records
        sRIList[0].Product_Concept_Grade__c = 'C';
        sRIList[0].Primary_Study__c = sStudyList[1].Id;
        sRIList[1].Primary_Study__c = null;
        sRIList[3].Product_Concept_Grade__c = '';
        sRIList[10].Product_Concept_Grade__c = 'B';
        sRIList[10].Primary_Study__c = sStudyList[0].Id;
        
        //Update Syndicated Research interactions
        update sRIList;
        
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
        
        //Test stops here 
        Test.stopTest();
        
        //Delete Syndicated study records
        delete sRIRecordsList;
        
        //Query through Syndicated Research Interaction records
        sRIRecordsList = [Select Id From Syndicated_Research_Interaction__c];
        
        //Asserting for the results
        System.assert(sRIRecordsList != null);
        System.assertEquals(11, sRIRecordsList.size());
        
        //Retrieving updated details from the database
        sSList = [SELECT Id, Name , GPA__c 
                  FROM Syndicated_Study__c 
                  WHERE RecordType.DeveloperName = 'NPD'
                  ORDER By Research_Type__c ASC];
        
        //Asserting for the results
        System.assert(sSList != null);
        System.assertEquals(2, sSList.size());
        System.assertEquals('3.00', sSList[0].GPA__c);
        System.assertEquals('0.0', sSList[1].GPA__c);
    }
}