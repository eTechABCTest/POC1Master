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
 *   Purpose         :   Test class for Trigger_PGMeasurementPeriod
 *            
 *   Create By       :   Subhash Garhwal
 *
 *   Created Date    :   11/5/2015
 *
 *   Revision Log    :   V_1.0 - Created - CR-20150729-9114
 * 
 *   Coverage        :   V_1.0 - 100%
 **/
@isTest(seeAllData = false)
private class Test_Trigger_PGMeasurementPeriod {
	
	// TO DO: implement unit test
    static testMethod void testPreventDuplicates() {
        
        
        //List of record type
        List<RecordType> recordTypes = [select Id, DeveloperName From RecordType Where SObjectType = 'Personal_Goal__c' 
                                        AND DeveloperName IN ('Personal_Goal', 'Proposal') ORDER BY DeveloperName ASC LIMIT 2];
        
        //Create Personal Goal
        List<Personal_Goal__c> personalGoals = new List<Personal_Goal__c>();
        
        //Add new Personal Goal in list
        personalGoals.add(new Personal_Goal__c(Name = 'PersonalGoal1', Active__c = true, RecordTypeId = recordTypes[0].Id, Amount__c = 100, 
                                               Description__c = 'Testing 1',Period_Start__c = System.today().addDays(1), Period_End__c = System.today().addDays(10)));
        //Add new Personal Goal in list
        personalGoals.add(new Personal_Goal__c(Name = 'PersonalGoal2', Active__c = true, RecordTypeId = recordTypes[0].Id, Amount__c = 100,
                                               Description__c = 'Testing 2', Period_Start__c = System.today().addDays(12), Period_End__c = System.today().addDays(20)));
        //Add new Personal Goal in list
        personalGoals.add(new Personal_Goal__c(Name = 'PersonalGoal3', Active__c = true, RecordTypeId = recordTypes[0].Id, Amount__c = 100,
                                               Description__c = 'Testing 3', Period_Start__c = System.today().addDays(21), Period_End__c = System.today().addDays(40)));
        
        //Insert Persoanl Goal
        insert personalGoals;
        
        //List of Personal Goal Measurement Period
        List<Personal_Goal_Measurement_Period__c> pGMPeriods = new List<Personal_Goal_Measurement_Period__c>();
        
        //Added new Record in list
        pGMPeriods.add(new Personal_Goal_Measurement_Period__c(Name = 'PGMP 1', Personal_Goal__c = personalGoals[0].Id, Measurement_Date__c = System.today()));
        pGMPeriods.add(new Personal_Goal_Measurement_Period__c(Name = 'PGMP 2', Personal_Goal__c = personalGoals[0].Id, Measurement_Date__c = System.today()));
        pGMPeriods.add(new Personal_Goal_Measurement_Period__c(Name = 'PGMP 3', Personal_Goal__c = personalGoals[1].Id, Measurement_Date__c = System.today().addDays(10)));
        pGMPeriods.add(new Personal_Goal_Measurement_Period__c(Name = 'PGMP 4', Personal_Goal__c = personalGoals[1].Id, Measurement_Date__c = System.today().addDays(15)));
        
        //Method Start Here
        Test.startTest();
        
        try{
        	
        	//Insert
        	insert pGMPeriods;
        }catch(Exception ex){
        	
        	//Assert of Result
        	System.assert(ex.getMessage().contains(Label.ERROR_UNIQUENESS_PGMP));
        }
        
        //Set Correct Data
        pGMPeriods[1].Measurement_Date__c = System.today().addDays(10);
        
        //Insert 
        insert pGMPeriods;
        
        //Assert For Result
        System.assertEquals(4, pGMPeriods.size());
        
        //Query Through Personal Goal Measurment Perioud
        List<Personal_Goal_Measurement_Period__c> pGMPList = [Select Id, Name, Personal_Goal__c, Personal_Goal__r.Name, Measurement_Date__c From Personal_Goal_Measurement_Period__c];
        
        //Assert For Result
        System.assertEquals(System.today().addDays(10), pGMPList[1].Measurement_Date__c);
       
        //Update 
        pGMPeriods[2].Measurement_Date__c = System.today().addDays(15);
        
        try{
        	
        	//Update
        	update pGMPeriods[2];
        }catch(Exception ex){
        	
        	//Assert of Result
        	System.assert(ex.getMessage().contains(Label.ERROR_UNIQUENESS_PGMP));
        }
        
        //Method Stop Here
        Test.stopTest();
        
    }
}