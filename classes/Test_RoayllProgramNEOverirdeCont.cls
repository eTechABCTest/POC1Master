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
  *     Description     :  Test Class for "ProgramNewEditOverrideController" Controller To test the funtionality
  *
  *     Created By      :   Subhash Garhwal
  *
  *     Created Date    :   2/11/2016
  *     
  *     Code Coverage   :   98%
  * 
  *     Revision Logs   :   V1.0 - Created
  *     
  *     Deprecated      :   None                         
  **/ 
@isTest(SeeAllData = false)
private class Test_RoayllProgramNEOverirdeCont {
	
     /**
      *     Description     :   Test method to test the funtionallity of  "doSave" method.
      *
      *     Created By      :   Subhash Garhwal
      *
      *     Created Date    :   2/11/2016
      * 
      *     Revision Logs   :   V1.0 - Created
      *
    **/ 
    static testMethod void testdoSave() {
        
        //Create Test account record
        Account account = new Account(Name = 'Test');
        
        //Insert
        insert account;
        
        //Create Test record of programPackage
        Program_Package__c programPackage = new Program_Package__c(Name = 'Test programPackage ', Account__c = account.Id, Fiscal_Year__c = '2015',
                                                                    At_Risk_Reason__c = 'Data');
        //Insert
        insert programPackage;
        
        //Create Test record of program
        Royall_Program__c program = new Royall_Program__c(Name = 'program', Program_Package__c = programPackage.Id, Contact_Quantity__c = 12,Probability__c = 20, Postage_Cost__c = 2,
                                            Target_Audience_New__c = 'Undergrad Accounts', Type__c = 'Re-engagement', Status__c = 'Proposed', Proposal_Sent__c = Date.today(),
                                            Campaign_New__c = 'Senior Search/PRE Fulfillment', Campaign_SubType__c = 'SS/PRE: New Name; SS/PRE: PRE Name',Program_Cost__c = 2, 
                                            QTY_SS_New_Name__c = 6, Postage_Cost_SS_New__c = 1, Program_Cost_SS_New__c = 1,
                                            QTY_SS_PRE_Name__c  = 6, Postage_Cost_SS_PRE__c = 1, Program_Cost_SS_PRE__c = 1);
        
        //Create Test record of program
        Royall_Program__c testprogram = new Royall_Program__c(Name = 'Test program', Program_Package__c = programPackage.Id, Contact_Quantity__c = 12,Probability__c = 20, Postage_Cost__c = 5,
                                                Target_Audience_New__c = 'Undergrad Accounts', Type__c = 'Re-engagement', Status__c = 'Proposed', Proposal_Sent__c = Date.today(),
                                                Campaign_New__c = 'Senior Search/PRE Fulfillment', Campaign_SubType__c = 'SS/PRE: New Name; SS/PRE: PRE Name', QTY_AM_IP_Name__c = 1,Program_Cost__c = 5, 
                                                QTY_AM_new_name__c = 1, QTY_AM_PRE_Name__c = 1, QTY_SE_IP_Name_Client__c = 1, QTY_SE_IP_Name_Royall__c = 1,
                                                QTY_SE_PRE_Name__c = 1, QTY_SS_New_Name__c = 1, Postage_Cost_SS_New__c = 1, Program_Cost_SS_New__c = 1,
                                                QTY_SS_PRE_Name__c  = 1, Postage_Cost_SS_PRE__c = 1, Program_Cost_SS_PRE__c = 1);
        
        
        //Create Test record of program
        Royall_Program__c testprogramCSNull = new Royall_Program__c(Name = 'Test program CsNull', Program_Package__c = programPackage.Id,Probability__c = 20,
                                            Target_Audience_New__c = 'Undergrad Accounts', Type__c = 'Re-engagement', Status__c = 'Proposed', Proposal_Sent__c = Date.today(),
                                            Campaign_New__c = 'Senior Search/PRE Fulfillment',Campaign_SubType__c = null);
        
        //Start test here
        Test.startTest();
        
        //Create instance of  StandardController
        ApexPages.StandardController standardController = new ApexPages.standardController(program); 
        
        //Create instance of  Controller
        RoyallProgramNewEditOverrideController controller = new RoyallProgramNewEditOverrideController(standardController);
        
        //Calling controller method                             
        Pagereference pagereference = controller.doSave();
        
        //Query List of Program__c
        List<Royall_Program__c> programs = [Select Id, Name, Program_Package__c, QTY_AM_IP_Name__c, QTY_AM_new_name__c, QTY_AM_PRE_Name__c, QTY_SE_IP_Name_Client__c,
                                        QTY_SE_IP_Name_Royall__c, QTY_SE_PRE_Name__c, QTY_SS_New_Name__c, Postage_Cost_SS_New__c, Program_Cost_SS_New__c,
                                        QTY_SS_PRE_Name__c, Postage_Cost_SS_PRE__c, Program_Cost_SS_PRE__c,Postage_Cost__c,Program_Cost__c From Royall_Program__c];
        //Assert result
        System.assertEquals(null, programs[0].QTY_AM_IP_Name__c);
        System.assertEquals(null, programs[0].QTY_AM_new_name__c);
        System.assertEquals(null, programs[0].QTY_AM_PRE_Name__c );
        System.assertEquals(null, programs[0].QTY_SE_IP_Name_Client__c );
        System.assertEquals(null, programs[0].QTY_SE_IP_Name_Royall__c );
        System.assertEquals(null, programs[0].QTY_SE_PRE_Name__c );
        System.assertEquals(6, programs[0].QTY_SS_New_Name__c );
        System.assertEquals(1, programs[0].Postage_Cost_SS_New__c );
        System.assertEquals(1, programs[0].Program_Cost_SS_New__c );
        System.assertEquals(6, programs[0].QTY_SS_PRE_Name__c );
        System.assertEquals(1, programs[0].Postage_Cost_SS_PRE__c );
        System.assertEquals(1, programs[0].Program_Cost_SS_PRE__c );
        System.assertEquals(2, programs[0].Postage_Cost__c);
        System.assertEquals(2, programs[0].Program_Cost__c);
          
        //Reinisitiolaize controller
        standardController = new ApexPages.standardController(testprogram);
        
        //Reinisitiolaize  Controller
        controller = new RoyallProgramNewEditOverrideController(standardController);
        
        //Calling controller method                             
        pagereference = controller.doSave();
     
        //Query List of Royall_Program__c
        List<Royall_Program__c> programsNull = [Select Id, Name, Program_Package__c, QTY_AM_IP_Name__c, QTY_AM_new_name__c, QTY_AM_PRE_Name__c, QTY_SE_IP_Name_Client__c,
                                        QTY_SE_IP_Name_Royall__c, QTY_SE_PRE_Name__c, QTY_SS_New_Name__c, Postage_Cost_SS_New__c, Program_Cost_SS_New__c,
                                        QTY_SS_PRE_Name__c, Postage_Cost_SS_PRE__c, Program_Cost_SS_PRE__c From Royall_Program__c Where Name =  'Test program'];
        
        //Assert Results
        System.assertEquals(0, programsNull.size());
        
        //Reinisitiolaize controller
        standardController = new ApexPages.standardController(testprogramCSNull);
        
        //Reinisitiolaize  Controller
        controller = new RoyallProgramNewEditOverrideController(standardController);
        
        //Calling controller method                             
        pagereference = controller.doSave();
        
        programs = [Select Id, Name, Program_Package__c, QTY_AM_IP_Name__c, QTY_AM_new_name__c, QTY_AM_PRE_Name__c, QTY_SE_IP_Name_Client__c,
                                        QTY_SE_IP_Name_Royall__c, QTY_SE_PRE_Name__c, QTY_SS_New_Name__c, Postage_Cost_SS_New__c, Program_Cost_SS_New__c,
                                        QTY_SS_PRE_Name__c, Postage_Cost_SS_PRE__c, Program_Cost_SS_PRE__c,Postage_Cost__c,Program_Cost__c From Royall_Program__c];
        
        //Assert Results
        System.assertEquals(2, programs.size());
                                  
        //Finish method
        Test.stopTest();  
        
    }
}