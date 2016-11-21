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
private class Test_Trigger_WDCostCenter {
/**
 *   Purpose         :   Test class for Trigger_GoalTypeCreditType
 *            
 *   Create By       :   Subhash Garhwal
 *
 *   Created Date    :   12/19/2015
 *
 *   Revision Log    :   V_1.0 - Created - CR-20151123-9412
 * 
 *   Coverage        :   V_1.0 - 100%
 *
 **/

    static testMethod void testPreventDuplicate() {
        // TO DO: implement unit test
        
        //Create List of Value Type
        List<Value_Type__c> valueTypes = new List<Value_Type__c>();
        
        //Added new Record in list
        valueTypes.add(new Value_Type__c(Name = 'VT 1', Category__c = 'Department', Active__c = true, Values_Permitted__c = 'Date'));
        valueTypes.add(new Value_Type__c(Name = 'VT 2', Category__c = 'Department', Active__c = true, Values_Permitted__c = 'Text'));
        
        // Insert
        insert valueTypes;
        
        //Assert
        System.assert(valueTypes.size() > 0);
        
        //Create List of Goal Type
        List<WD_Cost_Center__c> costCenters = new List<WD_Cost_Center__c>();
        
        //Added new Record in list
        costCenters.add(new WD_Cost_Center__c(Name = 'Test CC 1', Department__c = valueTypes[0].Id));
        costCenters.add(new WD_Cost_Center__c(Name = 'Test CC 1', Department__c = valueTypes[0].Id));
        
        //Method Start Here
        Test.startTest();
        
        try{
            //Insert
            insert costCenters;
            
            //Assert
            System.assert(false, 'Duplicate record inserted.');
            
        }catch(Exception ex){
            
            //Assert of Result
            System.assert(ex.getMessage().contains(Label.ERROR_UNIQUENESS_WDCC));
        }
        //Set Correct Data
        costCenters[0].Name =  'Test CC 3';
        
        //upsert 
        upsert costCenters;
        
        //Query through Cost Center
        List<WD_Cost_Center__c> cCenterList = [Select Id, Name, Department__c From WD_Cost_Center__c
                                                                            WHERE Id IN : costCenters ORDER BY Name ASC];
        
        //Assert For Result
        System.assertEquals(2, costCenters.size());
    
        //Update 
        costCenters[0].Name =  'Test CC 1';
        
        try{
            
            //Update
            update costCenters[0];
            
            //Assert
            System.assert(false, 'Duplicate record inserted.');
            
        }catch(Exception ex){
            
            //Assert of Result
            System.assert(ex.getMessage().contains(Label.ERROR_UNIQUENESS_WDCC));
        }
        //Method Stop Here
        Test.stopTest();
    }
}