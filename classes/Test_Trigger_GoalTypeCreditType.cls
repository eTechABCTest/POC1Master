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
 
 /**
 *   Purpose         :   Test class for Trigger_GoalTypeCreditType
 *            
 *   Create By       :   Subhash Garhwal
 *
 *   Created Date    :   12/02/2015
 *
 *   Revision Log    :   V_1.0 - Created - CR-20150729-9114
 * 
 *   Coverage        :   V_1.0 - 100%
 **/
@isTest(seeAllData = false)
private class Test_Trigger_GoalTypeCreditType {

    // TO DO: implement unit test
    static testMethod void testPreventDuplicates() {
        
        //Create List of Goal Type
        List<Goal_Type__c> goalTypes = new List<Goal_Type__c>();
        
        //Added new Record in list
        goalTypes.add(new Goal_Type__c(Name = 'GT 1', Base_Process__c = 'NBB', Description__c = 'Testing', Active__c = true, Standard_Goal__c = true));
        goalTypes.add(new Goal_Type__c(Name = 'GT 2', Base_Process__c = 'Activity', Description__c = 'Testing', Active__c = true, Standard_Goal__c = false));
        
        //Insert Goal Type
        insert goalTypes;
        
        //Assert
        System.assert(goalTypes.size() > 0);
        
        //Create List of Value Type
        List<Value_Type__c> valueTypes = new List<Value_Type__c>();
        
        //Added new Record in list
        valueTypes.add(new Value_Type__c(Name = 'VT 1', Category__c = 'Credit type', Active__c = true, Values_Permitted__c = 'Date'));
        valueTypes.add(new Value_Type__c(Name = 'VT 1', Category__c = 'Credit type', Active__c = true, Values_Permitted__c = 'Text'));
        
        //Insert Value Types
        insert valueTypes;
        
        //Assert
        System.assert(valueTypes.size() > 0);
        
        //Create List of Value Type
        List<Goal_Type_Credit_Type__c> gTCreditTypes = new List<Goal_Type_Credit_Type__c>();
        
        //Added new Record in list
        gTCreditTypes.add(new Goal_Type_Credit_Type__c(Name = 'GTCT 1', Goal_Type__c = goalTypes[0].Id, Credit_Type__c = valueTypes[0].Id));
        gTCreditTypes.add(new Goal_Type_Credit_Type__c(Name = 'GTCT 2', Goal_Type__c = goalTypes[0].Id, Credit_Type__c = valueTypes[0].Id));
        
        
        //Method Start Here
        Test.startTest();
        
        try{
            //Insert
            insert gTCreditTypes;
            
            //Assert
            System.assert(false, 'Duplicate record inserted.');
            
        }catch(Exception ex){
            
            //Assert of Result
            System.assert(ex.getMessage().contains(Label.ERROR_UNIQUENESS_GTCT));
        }
        //Set Correct Data
        gTCreditTypes[0].Credit_Type__c =  valueTypes[1].Id;
        
        //upsert 
        upsert gTCreditTypes;
        
        //Query Through Goal Template Details Measurment Perioud
        List<Goal_Type_Credit_Type__c> gTCTPList = [Select Id, Name, Credit_Type__c From Goal_Type_Credit_Type__c
                                                                                 WHERE Id IN : gTCreditTypes ORDER BY Credit_Type__c ASC];
        
        //Assert For Result
        System.assertEquals(2, gTCreditTypes.size());
        System.assertEquals(valueTypes[1].Id, gTCreditTypes[0].Credit_Type__c);
        
        //Method Stop Here
        Test.stopTest();
    }
}