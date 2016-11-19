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
private class TestBatch_RoyallShiftAccountStatus {
	
/**
 *	@Purpose		:	Test class for tetsing Batch(Batch_RoyallShiftAccountStatus)functionalityis using to Upadte information on Account realted to Program Package/HD	
 *
 *	@Created By		:	Subhash Garhwal		
 *
 *	@Created Date	:	07-08-2016	
 *
 *	@Rivision Log	:	V1.0 - Created
 *						V_1.1 - Moved - 9/20/2016 - Subhash Garhwal - CR-20160817-10134 - Moved class from Royall Instance	
 *
**/
    static testMethod void myUnitTest() {
        
        //Added - Subhash Garhwal - 9/20/2016 - CR-20160817-10134
        List<RecordType> recordTypes = [Select Id From RecordType Where SobjectType = 'Account' AND DeveloperName IN ('Royall_Admissions_Graduate', 'Royall_Admissions_Undergraduate', 'Royall_Advancement') LIMIT 3];
        //Account test data
        List<Account> accounts = new List<Account>();
        
        //Account data
        accounts.add(new Account(Name = 'Test', RecordTypeId = recordTypes[0].Id));
        accounts.add(new Account(Name = 'Testing Acc', RecordTypeId = recordTypes[1].Id));
        
        //Insert Account
        insert accounts;
        
        Integer currentFY = shift_get_fiscal_year.current();  
        
        //Query list of Accounts
        List<Account> accs = [Select Id, r_Current_Year_Status__c, r_Previous_Year_Status__c, r_Next_Year_Status__c, r_Current_Year_Account_Status__c,
										r_Previous_Year_Account_Status__c, r_Next_Year_Account_Status__c,r_HD_Previous_Year_Engagement_Status__c,
										r_HD_Current_Year_Engagement_Status__c, r_HD_Next_Year_Engagement_Status__c, r_HD_Previous_Year_Account_Status__c,
   										r_hd_current_year_account_status__c, r_HD_Next_Year_Account_Status__c from Account];
   		
   		//Assert
   		System.assertEquals(Null,accs[0].r_Previous_Year_Account_Status__c);
   		
   		//List of program Package						
		List<Program_Package__c> progPacks = new List<Program_Package__c>();
		
		//Test satrt here
		Test.startTest();
		
		//Test data of  Program Package
		progPacks.add(new Program_Package__c(Name = 'PackageT1', Account__c = accs[0].Id, Fiscal_Year__c = String.valueOf(String.ValueOf(currentFY - 1)),
											Client_Status_New__c = 'At Risk', Account_Status__c = 'Existing Client'));
		progPacks.add(new Program_Package__c(Name = 'PackageT2', Account__c = accs[0].Id, Fiscal_Year__c = String.valueOf(String.ValueOf(currentFY)),
											Client_Status_New__c = 'Secured', Account_Status__c = 'Existing Client'));
		progPacks.add(new Program_Package__c(Name = 'PackageT3', Account__c = accs[0].Id, Fiscal_Year__c = String.valueOf(String.ValueOf(currentFY + 1)),
											Client_Status_New__c = 'Committed', Account_Status__c = 'New Client'));
		
		progPacks.add(new Program_Package__c(Name = 'PackageT11', Account__c = accs[1].Id, Fiscal_Year__c = String.valueOf(String.ValueOf(currentFY - 1)),
											Client_Status_New__c = 'At Risk', Account_Status__c = 'Existing Client'));
		progPacks.add(new Program_Package__c(Name = 'PackageT12', Account__c = accs[1].Id, Fiscal_Year__c = String.valueOf(String.ValueOf(currentFY)),
											Client_Status_New__c = 'Secured', Account_Status__c = 'Existing Client'));
		progPacks.add(new Program_Package__c(Name = 'PackageT13', Account__c = accs[1].Id, Fiscal_Year__c = String.valueOf(String.ValueOf(currentFY + 1)),
											Client_Status_New__c = 'Committed', Account_Status__c = 'New Client'));
					
		//Insert Program Package							
		insert progPacks;
		
		//List of Program Package HD
		List<Program_Package_Hardwick_Day__c> progPackHD = new List<Program_Package_Hardwick_Day__c>();
		
		//test data of Program PackageHD
		progPackHD.add(new Program_Package_Hardwick_Day__c(Name = 'TestHd1', Account__c =accs[0].Id,Fiscal_Year_HD__c = String.valueOf(String.ValueOf(currentFY - 1)),
    														 	Client_Engagement_Status_HD__c = 'Secured', HD_Account_Status__c = 'Existing Client'));
		progPackHD.add(new Program_Package_Hardwick_Day__c(Name = 'TestHd2', Account__c =accs[0].Id,Fiscal_Year_HD__c = String.valueOf(String.ValueOf(currentFY)),
    														 	Client_Engagement_Status_HD__c = 'Committed', HD_Account_Status__c = 'New Client'));
		progPackHD.add(new Program_Package_Hardwick_Day__c(Name = 'TestHd3', Account__c =accs[0].Id,Fiscal_Year_HD__c = String.valueOf(String.ValueOf(currentFY + 1)),
    														 	Client_Engagement_Status_HD__c = 'In Play', HD_Account_Status__c = 'New Client'));
		
		progPackHD.add(new Program_Package_Hardwick_Day__c(Name = 'TestHd11', Account__c =accs[1].Id,Fiscal_Year_HD__c = String.valueOf(String.ValueOf(currentFY - 1)),
    														 	Client_Engagement_Status_HD__c = 'Secured', HD_Account_Status__c = 'Existing Client'));
		progPackHD.add(new Program_Package_Hardwick_Day__c(Name = 'TestHd21', Account__c =accs[1].Id,Fiscal_Year_HD__c = String.valueOf(String.ValueOf(currentFY)),
    														 	Client_Engagement_Status_HD__c = 'Committed', HD_Account_Status__c = 'New Client'));
		progPackHD.add(new Program_Package_Hardwick_Day__c(Name = 'TestHd31', Account__c =accs[1].Id,Fiscal_Year_HD__c = String.valueOf(String.ValueOf(currentFY + 1)),
    														 	Client_Engagement_Status_HD__c = 'In Play', HD_Account_Status__c = 'New Client'));
		
		//Insert Program Package Hd
		insert progPackHD;
		
		//Execute batch
   		Batch_RoyallShiftAccountStatus batch = new Batch_RoyallShiftAccountStatus();
		Database.executeBatch(batch);
   		
   		//Test Stop here
		Test.stopTest();	
		
		//Query Account records
		accs = [Select Id, r_Current_Year_Status__c, r_Previous_Year_Status__c, r_Next_Year_Status__c, r_Current_Year_Account_Status__c,
										r_Previous_Year_Account_Status__c, r_Next_Year_Account_Status__c,r_HD_Previous_Year_Engagement_Status__c,
										r_HD_Current_Year_Engagement_Status__c, r_HD_Next_Year_Engagement_Status__c, r_HD_Previous_Year_Account_Status__c,
   										r_hd_current_year_account_status__c, r_HD_Next_Year_Account_Status__c from Account order by Name];
   		
   		//Assert
   		System.assertEquals('Secured',accs[0].r_Current_Year_Status__c);
   		System.assertEquals('At Risk',accs[0].r_Previous_Year_Status__c);
   		System.assertEquals('Committed',accs[0].r_Next_Year_Status__c);
   		System.assertEquals('Existing Client',accs[0].r_Current_Year_Account_Status__c);
   		System.assertEquals('Existing Client',accs[0].r_Previous_Year_Account_Status__c);
   		System.assertEquals('New Client',accs[0].r_Next_Year_Account_Status__c);
   		
   		System.assertEquals('Secured',accs[1].r_Current_Year_Status__c);
   		System.assertEquals('At Risk',accs[1].r_Previous_Year_Status__c);
   		System.assertEquals('Committed',accs[1].r_Next_Year_Status__c);
   		System.assertEquals('Existing Client',accs[1].r_Current_Year_Account_Status__c);
   		System.assertEquals('Existing Client',accs[1].r_Previous_Year_Account_Status__c);
   		System.assertEquals('New Client',accs[1].r_Next_Year_Account_Status__c);
   		
   		System.assertEquals('Committed',accs[0].r_HD_Current_Year_Engagement_Status__c);
   		System.assertEquals('In Play',accs[0].r_HD_Next_Year_Engagement_Status__c);
   		System.assertEquals('Existing Client',accs[0].r_HD_Previous_Year_Account_Status__c);
   		System.assertEquals('New Client',accs[0].r_hd_current_year_account_status__c);
   		System.assertEquals('New Client',accs[0].r_HD_Next_Year_Account_Status__c);  
   		System.assertEquals('Secured',accs[0].r_HD_Previous_Year_Engagement_Status__c);
   		
   		System.assertEquals('Committed',accs[1].r_HD_Current_Year_Engagement_Status__c);
   		System.assertEquals('In Play',accs[1].r_HD_Next_Year_Engagement_Status__c);
   		System.assertEquals('Existing Client',accs[1].r_HD_Previous_Year_Account_Status__c);
   		System.assertEquals('New Client',accs[1].r_hd_current_year_account_status__c);
   		System.assertEquals('New Client',accs[1].r_HD_Next_Year_Account_Status__c);
   		System.assertEquals('Secured',accs[1].r_HD_Previous_Year_Engagement_Status__c);
   						
    }
}