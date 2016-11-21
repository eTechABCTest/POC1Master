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
      * Description     :   Test class for MemberSupportCaseTeamMembersController.
      *
      * Created By      :   Rajeev Jain(Simplyforce)
      *
      * Created Date    :   03/19/2015
      *
      * Version         :   V1.0 Created
      * 
      **/
    @isTest(seeAllData = false)
    public class Test_MSCaseTeamMembersController {
        
         /**
         *  @description    :   This method is used to set the data for TimeSheetInvoiceGeneratingBatch in test class
         *
         *  @param  :   
         *
         *  @Crbyeated  :   Rajeev Jain(Simplyforce)
         *
         *  @created date   :   03/19/2015
         **/
         @testSetup static void setup() {
    
            //Inserting CaseTeamTemplaate record 
            CaseTeamTemplate prefefinedCaseTeam = new CaseTeamTemplate(Name = 'PreDefined Case' , Description = 'testing');
            insert prefefinedCaseTeam ;
            
           
          }
        
        
         //Test methods for addNewCondition method
         static testMethod void myUnitTest() {
            
            //Create an institution  
            Account account = TestUtilities.CreateNewAccount(false);
            //Insert
            insert account;
            
            //fetching account
            List<Account> accounts = [SELECT Id, Name FROM Account ];
            
            //Create a Contact
            Contact contact = new Contact(FirstName = 'Test', LastName = 'Contact', Email = 'milliman@synergy.com', AccountId = accounts[0].Id, 
                                          Employee_User_Record__c = Userinfo.getUserId());
            
            //Insert
            insert contact;
            
            //Insert Case
            Case newCase = new Case(ContactId = contact.Id, Subject = 'Test', Status = '01-New', 
                                 Priority = 'Low', Description = 'Data Load for Employee Contact');
            insert newCase;
            
            //Insert Member Support
            Site_Issue__C memberSupport = new Site_Issue__C(Institution__c  = account.Id, Contact__c = contact.Id,
                                                           Assigned_To_Contact__c = contact.Id, PIC_Status__c = '',
                                                           Site_Issue_Priority__c = '', Data_Type__c = '',
                                                           Maintenance_Quarter__c = 'Unknown', Maintenance_Year__c = 'Unknown',
                                                           Maintenance_Payer__c = 'Unknown', Maintenance_Type__c = 'Unknown',
                                                           Case__c = newCase.Id, Data_Load_Type__c = 'Other', Data_Load_Period_End__c = date.today());
            insert memberSupport;
            
            
            //Query on caseTeamTemplate.
            List<caseteamtemplate> caseTeamTemps = [SELECT Id, Name, Description FROM caseteamtemplate ORDER BY LastModiFiedDate];
            
            //Assert
            System.assertEquals('PreDefined Case', caseTeamTemps[caseTeamTemps.size() - 1].Name);
            System.assertEquals('testing', caseTeamTemps[caseTeamTemps.size() - 1].Description);
            
            //Inserting caseTeamTemplaterecord.
            CaseTeamTemplateRecord caseJunction = new CaseTeamTemplateRecord(ParentId = newCase.Id, TeamTemplateId = caseTeamTemps[caseTeamTemps.size() - 1].Id);
            insert caseJunction;
            
            Test.startTest();
            
            //Instantiate Standard Controller
            ApexPages.StandardController standardController = new ApexPages.standardController(memberSupport); 
            
            //Create instance of  Controller
            MemberSupportCaseTeamMembersController controller = new MemberSupportCaseTeamMembersController(standardController);
            
            //set the selected row of the controller.
            controller.selectedRow = 0;
            
            //Calling the controller method 
            controller.removeCaseTeam();
            
            //Query on case team template record  
            Integer count = [SELECT count() FROM CaseTeamTemplateRecord];
            
            //Assert
            System.assertEquals(0, count);
            
            //Query on 
            //Set the controllers variable
            controller.caseTeamId = newCase.Id;
            
            try{
                //Calling the controller method to add case team.
                controller.addCaseTeam();
            }
            catch(Exception e){ }
            
            controller.caseTeamId = caseTeamTemps[caseTeamTemps.size() - 1].Id;
            
            //Calling the controller method to add case team.
            controller.addCaseTeam();
            
            //Query on case team template record  
            Integer count2 = [SELECT count() FROM CaseTeamTemplateRecord];
            
            //Assert
            System.assertEquals(1, count2);
            
            Test.stopTest();
            
           controller.caseTeams = new List<CaseTeamMember>();
            
        }    
    }