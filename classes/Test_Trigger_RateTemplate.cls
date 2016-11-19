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
 *   Purpose         :   Test class for Trigger_RateTemplate
 *            
 *   Create By       :   Subhash Garhwal
 *
 *   Created Date    :   10/8/2015
 *
 *   Revision Log    :   V_1.0 - Created - CR-20150729-9114
 * 
 *   Coverage        :   V_1.0 - 
 **/
@isTest(seeAllData = false)
private class Test_Trigger_RateTemplate {
    
    // TO DO: implement unit test
    static testMethod void TestValidateRateTemplates() {
        
        //List of Rate Templates
        List<Rate_Template__c> rateTemplates = new List<Rate_Template__c>();
        
        //Add record in list
        rateTemplates.add(new Rate_Template__c(Name = 'RT 1', Active__c = true));
        rateTemplates.add(new Rate_Template__c(Name = 'RT 1', Active__c = true));
        rateTemplates.add(new Rate_Template__c(Name = 'RT 3', Active__c = true));
        rateTemplates.add(new Rate_Template__c(Name = 'RT 4', Active__c = true));
        
        //Method Start Here
        Test.startTest();
        
        try{
            //Insert
            insert rateTemplates;
        }catch(Exception ex){
            
            //Assert for Result
            System.assert(ex.getMessage().contains(Label.DUPLICATE_RATE_TEMPLATE));
        }
        
        rateTemplates[1].Name = 'RT 2';
        
        //Insert
        insert rateTemplates;
        
        //Methof Stop Here
        Test.stopTest();
        
    }
    
    // TO DO: implement unit test
    static testMethod void validateBeforeDelete() {
        
        //List of Rate Templates
        List<Rate_Template__c> rateTemplates = new List<Rate_Template__c>();
        
        //Add record in list
        rateTemplates.add(new Rate_Template__c(Name = 'RT 1', Active__c = true));
        rateTemplates.add(new Rate_Template__c(Name = 'RT 2', Active__c = true));
        rateTemplates.add(new Rate_Template__c(Name = 'RT 3', Active__c = true));
        rateTemplates.add(new Rate_Template__c(Name = 'RT 4', Active__c = true));
        
        //Insert
        insert rateTemplates;
        
        //List of record type
        List<RecordType> recordTypes = [select Id, DeveloperName From RecordType Where SObjectType = 'Personal_Goal__c' 
                                        AND DeveloperName IN ('Personal_Goal', 'Proposal') ORDER BY DeveloperName ASC LIMIT 2];
        
        //Create Personal Goal
        List<Personal_Goal__c> personalGoals = new List<Personal_Goal__c>();
        
        //Add new Personal Goal in list
        personalGoals.add(new Personal_Goal__c(Name = 'PersonalGoal1', Active__c = true, RecordTypeId = recordTypes[0].Id, Amount__c = 100, Rate_Template__c =  rateTemplates[0].Id,
                                               Description__c = 'Testing 1',Period_Start__c = System.today().addDays(1), Period_End__c = System.today().addDays(10)));
        //Add new Personal Goal in list
        personalGoals.add(new Personal_Goal__c(Name = 'PersonalGoal2', Active__c = true, RecordTypeId = recordTypes[0].Id, Amount__c = 100, Rate_Template__c =  rateTemplates[1].Id,
                                               Description__c = 'Testing 2', Period_Start__c = System.today().addDays(12), Period_End__c = System.today().addDays(20)));
        //Add new Personal Goal in list
        personalGoals.add(new Personal_Goal__c(Name = 'PersonalGoal3', Active__c = true, RecordTypeId = recordTypes[0].Id, Amount__c = 100, Rate_Template__c =  rateTemplates[2].Id,
                                               Description__c = 'Testing 3', Period_Start__c = System.today().addDays(21), Period_End__c = System.today().addDays(40)));
        
        //Insert Persoanl Goal
        insert personalGoals;
            
        //Method Start Here
        Test.startTest();
        //Assert For Result
        system.assertEquals(4, rateTemplates.size());
        
        try{
            
            //Delete
            delete rateTemplates[0];
            
            //Assert
            system.assert(false);
            
        }catch(Exception ex){
            
            //Assert for Result
            System.assert(ex.getMessage().contains(Label.RATE_TEMPLATE_IN_USE));
        }
        
        //Query Through Rate Template
        List<Rate_Template__c> RTList = [select Id From Rate_Template__c];
        
        //Assert For Result
        system.assertEquals(4, RTList.size());
        
          
        //Update rate template
        personalGoals[0].Rate_Template__c =  rateTemplates[3].Id;
        
        //Update Personal Goal
        update personalGoals;
          
        List<Personal_Goal__c> pGList1 = [Select Id, Rate_Template__c From Personal_Goal__c Where Rate_Template__c =: rateTemplates[0].Id];
        
        
        //Delete
        //delete rateTemplates[0];
        
        //Query Through Rate Template
        RTList = [select Id From Rate_Template__c];
        
        //Assert For Result
        //system.assertEquals(3, RTList.size());
        
        //Methof Stop Here
        Test.stopTest();
         
    }
}