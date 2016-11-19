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
 *   Purpose         :   Test class for Trigger_GTDMeasurementPeriod
 *            
 *   Create By       :   Subhash Garhwal
 *
 *   Created Date    :   11/25/2015
 *
 *   Revision Log    :   V_1.0 - Created - CR-20150729-9114
 * 
 *   Coverage        :   V_1.0 - 100%
 **/
@isTest(seeAllData = false)
private class Test_Trigger_GTDMeasurementPeriod {
    
    // TO DO: implement unit test
    static testMethod void testPreventDuplicates() {
        
        //Create List of Goal Template
        List<Goal_Type__c> goalTypes = new List<Goal_Type__c>();
        
        //Added new Record in list
        goalTypes.add(new Goal_Type__c(Name = 'GT 1', Base_Process__c = 'NBB', Description__c = 'Testing', Active__c = true, Standard_Goal__c = true));
        goalTypes.add(new Goal_Type__c(Name = 'GT 2', Base_Process__c = 'Activity', Description__c = 'Testing', Active__c = true, Standard_Goal__c = false));
        goalTypes.add(new Goal_Type__c(Name = 'GT 2', Base_Process__c = 'Activity', Description__c = 'Testing', Active__c = true, Standard_Goal__c = false));
        goalTypes.add(new Goal_Type__c(Name = 'GT 2', Base_Process__c = 'Activity', Description__c = 'Testing', Active__c = true, Standard_Goal__c = false));
        
        //Insert Goal Type
        insert goalTypes;
        
        //Assert
        System.assert(goalTypes.size() > 0);
        
        //Create List of Goal Template
        List<Standard_Goal__c> goalTemplates = new List<Standard_Goal__c>();
        
        //Add new GT in list
        goalTemplates.add(new Standard_Goal__c(Description__c = 'Testing', Standard_Type__c = 'Personal', Goal_Type__c = goalTypes[0].Id,
                                     Period_Start__c = System.today().addDays(1), Period_End__c = System.today().addDays(10)));
        
        //Insert Standard Goal(Goal Template)
        insert goalTemplates;
        
        //Create List of Goal Template Details
        List<Standard_Goal_Detail__c> gTDetails = new List<Standard_Goal_Detail__c>();
        
        //Add new records in list
        gTDetails.add(new Standard_Goal_Detail__c(Standard_Goal__c = goalTemplates[0].Id, Description__c = 'GTD Desc 1', Goal_Type__c = goalTypes[1].Id));
        gTDetails.add(new Standard_Goal_Detail__c(Standard_Goal__c = goalTemplates[0].Id, Description__c = 'GTD Desc 2', Goal_Type__c = goalTypes[1].Id));
        gTDetails.add(new Standard_Goal_Detail__c(Standard_Goal__c = goalTemplates[0].Id, Description__c = 'GTD Desc 3', Goal_Type__c = goalTypes[2].Id));
        gTDetails.add(new Standard_Goal_Detail__c(Standard_Goal__c = goalTemplates[0].Id, Description__c = 'GTD Desc 4', Goal_Type__c = goalTypes[3].Id));
        
        //Insert Standard Goal Detail(Goal Template Detail)
        insert gTDetails;
        
        // Create List of Goal Template
        List<Goal_Template_Detail_Measurement_Period__c> gTDPeriods = new List<Goal_Template_Detail_Measurement_Period__c>();
        
        //Added new Record in list
        gTDPeriods.add(new Goal_Template_Detail_Measurement_Period__c(Name = 'GTDMP 1', Goal_Template_Detail__c = gTDetails[0].Id, Measurement_Date__c = System.today()));
        gTDPeriods.add(new Goal_Template_Detail_Measurement_Period__c(Name = 'GTDMP 2', Goal_Template_Detail__c = gTDetails[0].Id, Measurement_Date__c = System.today()));
        gTDPeriods.add(new Goal_Template_Detail_Measurement_Period__c(Name = 'GTDMP 3', Goal_Template_Detail__c = gTDetails[1].Id, Measurement_Date__c = System.today().addDays(11)));
        gTDPeriods.add(new Goal_Template_Detail_Measurement_Period__c(Name = 'GTDMP 4', Goal_Template_Detail__c = gTDetails[1].Id, Measurement_Date__c = System.today().addDays(15)));
        
        //Method Start Here
        Test.startTest();
        
        try{
            
            //Insert
            insert gTDPeriods;
            
            //Assert
            System.assert(false, 'Duplicate record inserted.');
            
        }catch(Exception ex){
            
            //Assert of Result
            System.assert(ex.getMessage().contains(Label.ERROR_UNIQUENESS_GTDMP));
        }
        
        //Set Correct Data
        gTDPeriods[1].Measurement_Date__c = System.today().addDays(10);
        
        //Insert 
        insert gTDPeriods;
        
        //Query Through Goal Template Details Measurment Perioud
        List<Goal_Template_Detail_Measurement_Period__c> gTDMPList = [Select Id, Name, Goal_Template_Detail__r.Name, Measurement_Date__c From Goal_Template_Detail_Measurement_Period__c
                                                                                 WHERE Id IN : gTDPeriods ORDER BY Measurement_Date__c ASC];
        
        //Assert For Result
        System.assertEquals(4, gTDPeriods.size());
        System.assertEquals(System.today().addDays(10), gTDMPList[1].Measurement_Date__c);
       
        //Update 
        gTDPeriods[2].Measurement_Date__c = System.today().addDays(15);
        
        try{
            
            //Update
            update gTDPeriods[2];
            
            //Assert
            System.assert(false, 'Duplicate record inserted.');
            
        }catch(Exception ex){
            
            //Assert of Result
            System.assert(ex.getMessage().contains(Label.ERROR_UNIQUENESS_GTDMP));
        }
        
        //Method Stop Here
        Test.stopTest();
    }
}