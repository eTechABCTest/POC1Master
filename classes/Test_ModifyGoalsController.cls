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
private class Test_ModifyGoalsController {
/** 
 * Description  :   Unit test method for ModifyGoalsController .
 *
 * Created By   :   Rajiv Jain  
 *                
 * Created Date :   02/18/2016    
 *
 * Converage    :
 *
 * version      :   V1.0
 *
 * UpdatedBy    :       
 **/
    
    /**
     *  @description    :   This method is used to set the data for ModifyGoalsController in test class
     *
     *  @param  :   
     *
     *  @Crbyeated  :   Rajiv Jain
     *
     *  @created date   :   02/18/2016
     **/
     @testSetup static void setup() {
        
        //List of record type
        List<RecordType> recordTypes = [select Id, DeveloperName From RecordType Where SObjectType = 'Personal_Goal__c' 
                                        AND DeveloperName IN ('Personal_Goal', 'Proposal') ORDER BY DeveloperName ASC LIMIT 2];
        
        //Create Personal Goal
        List<Personal_Goal__c> personalGoals = new List<Personal_Goal__c>();
        
        //Add new Personal Goal in list
        personalGoals.add(new Personal_Goal__c(Name = 'PersonalGoal1', Active__c = true, RecordTypeId = recordTypes[0].Id,
                                               Description__c = 'Testing', Amount__c = 100, 
                                               Status__c = 'Available', Period_Start__c = System.today().addDays(1), Period_End__c = System.today().addDays(10)));
        //Add new Personal Goal in list
        personalGoals.add(new Personal_Goal__c(Name = 'PersonalGoal2', Active__c = true, RecordTypeId = recordTypes[1].Id,
                                               Description__c = 'Testing', Amount__c = 100, 
                                               Status__c = 'Available', Period_Start__c = System.today().addDays(12), Period_End__c = System.today().addDays(20)));
        //Add new Personal Goal in list
        personalGoals.add(new Personal_Goal__c(Name = 'PersonalGoal3', Active__c = true, RecordTypeId = recordTypes[1].Id,
                                               Description__c = 'Testing', Amount__c = 100, 
                                               Status__c = 'Available', Period_Start__c = System.today().addDays(21), Period_End__c = System.today().addDays(40)));
        //Insert personal goals list
        insert personalGoals;
     
     }     
      /**
     *  @description    :   test method is used to validate the functionlity of ModifyGoalsController.
     *
     *  @args           :   void
     * 
     *  @param          :   
     *
     *  @Created        :   Rajiv Jain
     *
     *  @created date   :   02/18/2016
     *
     *  @updatedBy      :
     **/
    static testMethod void validateModifyGoalsControllerFuctionality() {
        
            //List of record type
            List<RecordType> recordTypes = [select Id, DeveloperName From RecordType Where SObjectType = 'Personal_Goal__c' 
                                        AND DeveloperName IN ('Personal_Goal', 'Proposal') ORDER BY DeveloperName ASC LIMIT 2];
        
            //Test starts from here.
            Test.startTest();
            
            //List of personal goals record that is of Proposal record type.
            List<Personal_Goal__c> personalGoals = [SELECT Id ,Name, recordTypeId FROM Personal_Goal__c WHERE RecordType.DeveloperName = :ISSPConstants.PERSONAL_GOAL_RECORD_TYPE_PROPOSAL];
            
            //Assert for result
            System.AssertEquals(3,personalGoals.size());
            
            //Initiallizing the controllers variable of select option.
            List<SelectOption> soList = ModifyGoalsController.pgFilterOptions;
            
            //Set filtered size to 0.
            ModifyGoalsController.filteredSize = 0;
            
            //Initiallizing the controllers variable of select option.
            soList = ModifyGoalsController.pgFilterOptions;
            
            //Instantiate the standard controller and pass the record of personl goals.
            ApexPages.StandardController sc = new ApexPages.StandardController(personalGoals[0]);
                    
            //Passing the standard controller records to constructor of controller.
            ModifyGoalsController controller = new ModifyGoalsController(sc);
            
            System.assertEquals(1, ModifyGoalsController.filteredSize);
            
            //Initiallizing the controllers variable of select option.
            soList = ModifyGoalsController.pgFilterOptions;
            
           //Calling the method of controller.
            Pagereference pegRef = controller.proceedWithSelection();
            
            //Set the value for selectedFilterValue as create.
            controller.selectedFilterValue = 'Create';
            
            //Initiallizing  the controller varible.
            String str = ModifyGoalsController.createNexProposalText;
            
            //Calling the method of controller when selectedFilterValue is equals to  create.
            pegRef = controller.proceedWithSelection();
            
            //Set the value for selectedFilterValue as modify.
            controller.selectedFilterValue = 'Modify';
            
            //Calling the method of controller when selectedFilterValue is equals to  create.
            pegRef = controller.proceedWithSelection();
            
            //Set controller's variable as false
            controller.isSubmitForPlanManagement = false;
            
            //Calling the method of controller when selectedFilterValue is equals to  create.
            pegRef = controller.proceedWithSelection();
            
            //Set the value for selectedFilterValue as void.
            controller.selectedFilterValue = 'Void';
            
            //Calling the method of controller when selectedFilterValue is equals to  create.
            pegRef = controller.proceedWithSelection();
            //Assert
            System.assertEquals(1, controller.filteredPgs.size());
            
             //Data of personal goal when period start is null.
            Personal_Goal__c personalGoal = new Personal_Goal__c(Name = 'PersonalGoal1',Period_Start__c = Date.today(),  Active__c = true, RecordTypeId = recordTypes[0].Id,
                                               Description__c = 'Testing', Amount__c = 100, 
                                               Status__c = 'Available');
            //insert personal goal.
            insert personalGoal;
            
            //Passing the personal goal to constructor.
            sc = new ApexPages.StandardController(personalGoal);
            
            controller = new ModifyGoalsController(sc);
            
            //Set the value for selectedFilterValue as modify.
            controller.selectedFilterValue = 'Modify';
            
            //Calling the method of controller when selectedFilterValue is equals to  create.
            pegRef = controller.proceedWithSelection();
         
            
            ApexPages.StandardSetController sc1 = new ApexPages.StandardSetController(new List<Personal_Goal__c>{personalGoals[0], personalGoals[1]});
            sc1.setSelected(new List<Personal_Goal__c>{personalGoals[0], personalGoals[1]});
        
            //Constructor
            controller = new ModifyGoalsController(sc1);  
            //Test stop here.
            Test.stopTest();
            
    }
}