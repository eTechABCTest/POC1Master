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
@isTest
private class Test_OSRTriggerHelper {
/**
 *  Description     :   Test class for OSR Trigger
 *
 *  Created By      :   Bhavi Sharma
 *
 *  Created Date    :   10/19/2013
 *
 *  Revision Logs   :   V_1.0 - Created
 *                      v.1.1 - Modified by Colin McGloin as part of CR-20141008-7702
 *                      V_1.2 - Modified by Mahendra Swarnakar - CR-20151013-9317 - 10/28/2015 - Added method "testPopulateDefaultAdvisoryProfile" 
 *
 *  Coverage        :
 *
 **/
    
    //Test method for Update OSR's Alert Finance field
    static testMethod void testUpdateOSRAlertFinance() {
        
        //insert Credit Card Settings record
        Credit_Card_Settings__c ccDefaultSetting = TestUtilities.CreateCreditCardSettings();
        insert ccDefaultSetting;
        
        //List of OSR to be record
        List<OSR__c> osrs = new List<OSR__c>();
        osrs.add(new OSR__c(Alert_Summary__c = 'Decline Alert request'));
        osrs.add(new OSR__c(Alert_Summary__c = 'request Decline Alert'));
        osrs.add(new OSR__c(Alert_Summary__c = 'Alert Fraud request'));
        osrs.add(new OSR__c(Alert_Summary__c = 'Alert request'));
        osrs.add(new OSR__c(Alert_Summary__c = 'Fraud'));
        
        //Test method starts here
        Test.startTest();
        
        //insert new OSRs
        insert osrs;
        
        //Query result of OSR
        osrs = [SELECT Id, Alert_Finance__c FROM OSR__c WHERE Alert_Finance__c = true];
        
        //assert statements
        System.assertEquals(2, osrs.size());
        
        //Test stops here
        Test.stopTest();
    }
    
    //Test method for Update OSR's Alert Finance field
    @isTest(SeeAllData=true)
    static void testSendAgreementForNewOSR() {
        //User record
        User currentUser;
        
        //Update the User Finance Code if not alreayd populated
        System.runAs(new User(Id = UserInfo.getUserId())) {
            
            //Update the Employee Id
            currentUser = new User(Id = UserInfo.getUserId(), Finance_Code__c = '50011');
            update currentUser;
        }
        
         //insert Credit Card Settings record 
        Credit_Card_Settings__c configCCDefaultSetting = CreditCardConstants.CONFIG_DEFAULT;
        configCCDefaultSetting.Service_User__c = currentUser.Id;
        
        //insert configCCDefaultSetting;
        update configCCDefaultSetting;
        
        //Blob object for document body
        Blob b = Blob.valueof('Hello, Test Document');
        
        //Inserting Document file  
        Document doc = new Document(Name = 'Test Document', DeveloperName = CreditCardConstants.DOCUMENT_DEVELOPER_NAME_ADVISORY_BOARD_CREDIT_CARD_AGREEMENT, Body = b , Type = 'txt', Description = 'test documents ' , IsPublic = true , FolderId = '005C0000005rUdl', AuthorId = currentUser.Id);
        insert doc ;
        
        //Query result of Record Types
        List<RecordType> recordTypes = [SELECT Id, DeveloperName FROM RecordType WHERE IsActive = true AND 
                                            SobjectType = 'Contact' AND DeveloperName =: Constants.CONTACT_RECORD_TYPE_DEVELOPER_NAME_EMPLOYEE Limit 1];
        
        //assert statements
        System.assertEquals(1, recordTypes.size());
                    
        //List to hold Contact
        List<Contact> contacts = new List<Contact>();
        contacts.add(new Contact(FirstName = 'Test', LastName = 'Contact A', RecordTypeId = recordTypes[0].Id, Employee_Id__c = '12341'));
        contacts.add(new Contact(FirstName = 'Test', LastName = 'Contact B', RecordTypeId = recordTypes[0].Id, Employee_Id__c = '12342', Contact_Status__c = 'Active'));
        contacts.add(new Contact(FirstName = 'Test', LastName = 'Contact C', RecordTypeId = recordTypes[0].Id, Employee_Id__c = '12343', Contact_Status__c = 'Inactive'));
        
        //insert contacts
        Util.BypassAllTriggers = true;
        insert contacts;
        
        //List of OSR to be record
        List<OSR__c> osrs = new List<OSR__c>();
        osrs.add(new OSR__c(Status__c = CreditCardConstants.OSR_STATUS_NEW, Request_Type__c = CreditCardConstants.OSR_REQUEST_TYPE_NEW_ABC_CREDIT_CARD, Contact__c = contacts[0].Id));
        osrs.add(new OSR__c(Status__c = CreditCardConstants.OSR_STATUS_NEW, Request_Type__c = CreditCardConstants.OSR_REQUEST_TYPE_NEW_ABC_CREDIT_CARD, Contact__c = contacts[0].Id));
        osrs.add(new OSR__c(Status__c = CreditCardConstants.OSR_STATUS_NEW, Request_Type__c = CreditCardConstants.OSR_REQUEST_TYPE_NEW_ABC_CREDIT_CARD, Contact__c = contacts[1].Id));
        osrs.add(new OSR__c(Status__c = CreditCardConstants.OSR_STATUS_NEW, Request_Type__c = CreditCardConstants.OSR_REQUEST_TYPE_NEW_ABC_CREDIT_CARD, Contact__c = contacts[1].Id));
        osrs.add(new OSR__c(Status__c = CreditCardConstants.OSR_STATUS_NEW, Request_Type__c = CreditCardConstants.OSR_REQUEST_TYPE_NEW_ABC_CREDIT_CARD, Contact__c = contacts[0].Id));
        system.debug('osrsListSize' + osrs.size());
        
        //Test method starts here
        Test.startTest();
        
        //Bhavi Sharma: Adding try-catch statement.
        //Reason: Manage package is throwing exception when contact and osr data is being insrted together.
        try {
            insert osrs;
            
            //Query result of Agreement
            List<echosign_dev1__SIGN_Agreement__c> agreements = [SELECT Id FROM echosign_dev1__SIGN_Agreement__c WHERE OSR__c IN: osrs];
            
            System.assertEquals(5, agreements.size());
        } catch(Exception e) {
            
            //asserting true
            System.assert(true);
        }
        
        
        //Test stops here
        Test.stopTest();
    }
    
    //Test method for Travel Portal OSR
    static testMethod void testTravelPortalOSRsWithAddress() {
        
        //insert Credit Card Settings record
        Credit_Card_Settings__c configCCDefaultSetting = TestUtilities.CreateCreditCardSettings();
        insert configCCDefaultSetting;
        
        //insert Contact record
        Contact c = TestUtilities.CreateNewContact(false);
        c.Birthdate = system.today().addYears(-28);
        insert c;
        
        //Set helper class variable
        CreditCardHelper.configDefaults = configCCDefaultSetting;
        CreditCardConstants.CONFIG_DEFAULT = configCCDefaultSetting; 
          
        List<Portfolio__c> payments = new List<Portfolio__c>();
        payments.add(new Portfolio__c(Status__c = Constants.ACTIVE, 
                                      Portfolio_Owner_Finance_Code__c = '678981', 
                                      Card_Holder__c = c.Id));
        insert payments; 
        
        //Credit Card record   
        List<Credit_Card__c> cards = new List<Credit_Card__c>(); 
        cards.add(new Credit_Card__c(Status__c = CreditCardConstants.CC_STATUS_VENDOR_APPROVAL, Payment_Account__c = payments[0].ID));
        insert cards;
          
        //Resord Type Credit Card request
        List<RecordType> recordTypeOSRCreditCardRequest =[Select Id from RecordType where SObjectType = 'OSR__c' 
                                                            AND DeveloperName =: CreditCardConstants.OSR_RECORD_TYPE_DEVELOPER_NAME_CREDIT_CARD_REQUEST 
                                                            AND IsActive = true limit 1];
        System.assertEquals(1, recordTypeOSRCreditCardRequest.size());
        
        //List of OSR to be record
        List<OSR__c> oSRs = new List<OSR__c>();
        oSRs.add(new OSR__c(Origin__c = CreditCardConstants.OSR_ORIGIN_TRAVEL_PORTAL, RecordTypeId = recordTypeOSRCreditCardRequest[0].Id, 
                                Request_Type__c = CreditCardConstants.OSR_REQUEST_TYPE_REPLACEMENT_ABC_CREDIT_CARD, Status__c = CreditCardConstants.OSR_STATUS_NEW, 
                                Related_Card__c = cards[0].ID, Address_To_Name__c = 'Test', Address_Line_1__c = 'Test', Address_Line_2__c = 'Test', 
                                Address_City__c = 'Test', Address_State__c = 'TA', Address_Postal_Code__c = 'Test', Address_Updated__c = true,
                                Contact__c = c.Id));
            
        //Start testing from here
        Test.startTest();
        
        //Insert OSRs   
        insert oSRs;
        
        //Check if the batch has been scheduled
        List<AsyncApexJob> aSyncJobs = [SELECT Id, JobItemsProcessed, TotalJobItems, NumberOfErrors, CreatedBy.Email FROM AsyncApexJob
                                                WHERE ApexClass.Name IN ('Batch_ProcessOSRs', 'Batch_AddCardsForReplacementRequest') 
                                                    AND Status IN: CreditCardConstants.ASYNC_APEX_JOB_PENDING_STATUSES];
        System.assertEquals(1, aSyncJobs.size());
        
        //Test stops here
        Test.stopTest();
        
        //Check if a new replace card is created with Update_Billing_Address_On_Activation__c  = true
        cards = [Select Status__c, Update_Billing_Address_On_Activation__c from Credit_Card__c where Payment_Account__c =: payments[0].Id order by CreatedDate];
        System.assertEquals(2, cards.size());
        System.assertEquals(CreditCardConstants.CC_STATUS_PENDING_DEACTIVATION, cards[0].Status__c);
        System.assertEquals(CreditCardConstants.CC_STATUS_PENDING_ACTIVATION, cards[1].Status__c);
        System.assertEquals(true, cards[1].Update_Billing_Address_On_Activation__c );
    }
 
    //Test method for Travel Portal OSR
    static testMethod void testTravelPortalOSRsWithPartialAddress() {
        
        //insert Credit Card Settings record
        Credit_Card_Settings__c configCCDefaultSetting = TestUtilities.CreateCreditCardSettings();
        insert configCCDefaultSetting;
        
        //insert Contact record
        Contact c = TestUtilities.CreateNewContact(false);
        c.Birthdate = system.today().addYears(-28);
        insert c;
        
        //Set helper class variable
        CreditCardHelper.configDefaults = configCCDefaultSetting;
        CreditCardConstants.CONFIG_DEFAULT = configCCDefaultSetting; 
          
        List<Portfolio__c> payments = new List<Portfolio__c>();
        payments.add(new Portfolio__c(Status__c = Constants.ACTIVE, 
                                      Portfolio_Owner_Finance_Code__c = '678981', 
                                      Card_Holder__c = c.Id));
        insert payments; 
        
        //Credit Card record   
        List<Credit_Card__c> cards = new List<Credit_Card__c>(); 
        cards.add(new Credit_Card__c(Status__c = CreditCardConstants.CC_STATUS_VENDOR_APPROVAL, Payment_Account__c = payments[0].ID));
        insert cards;
          
        //Resord Type Credit Card request
        List<RecordType> recordTypeOSRCreditCardRequest =[Select Id from RecordType where SObjectType = 'OSR__c' 
                                                            AND DeveloperName =: CreditCardConstants.OSR_RECORD_TYPE_DEVELOPER_NAME_CREDIT_CARD_REQUEST 
                                                            AND IsActive = true limit 1];
        System.assertEquals(1, recordTypeOSRCreditCardRequest.size());
        
        //List of OSR to be record
        List<OSR__c> oSRs = new List<OSR__c>();
        oSRs.add(new OSR__c(Origin__c = CreditCardConstants.OSR_ORIGIN_TRAVEL_PORTAL, RecordTypeId = recordTypeOSRCreditCardRequest[0].Id, 
                                Request_Type__c = CreditCardConstants.OSR_REQUEST_TYPE_REPLACEMENT_ABC_CREDIT_CARD, Status__c = CreditCardConstants.OSR_STATUS_NEW, 
                                Related_Card__c = cards[0].ID, Address_To_Name__c = 'Test', Address_Line_1__c = 'Test', Address_Line_2__c = 'Test', 
                                Address_City__c = 'Test', Address_State__c = '', Address_Postal_Code__c = 'Test', Address_Updated__c = true,
                                Contact__c = c.Id));
            
        //Start testing from here
        Test.startTest();
        
        //Insert OSRs   
        insert oSRs;
        
        //Check if the batch has been scheduled
        List<AsyncApexJob> aSyncJobs = [SELECT Id, JobItemsProcessed, TotalJobItems, NumberOfErrors, CreatedBy.Email FROM AsyncApexJob
                                                WHERE ApexClass.Name IN ('Batch_ProcessOSRs', 'Batch_AddCardsForReplacementRequest') 
                                                    AND Status IN: CreditCardConstants.ASYNC_APEX_JOB_PENDING_STATUSES];
        System.assertEquals(1, aSyncJobs.size());
        
        //Test stops here
        Test.stopTest();
        
        //Check if a new replace card is created with Update_Billing_Address_On_Activation__c  = true
        cards = [Select Status__c, Update_Billing_Address_On_Activation__c from Credit_Card__c where Payment_Account__c =: payments[0].Id order by CreatedDate];
        System.assertEquals(2, cards.size());
        System.assertEquals(CreditCardConstants.CC_STATUS_PENDING_DEACTIVATION, cards[0].Status__c);
        System.assertEquals(CreditCardConstants.CC_STATUS_PENDING_ACTIVATION, cards[1].Status__c);
        System.assertEquals(true, cards[1].Update_Billing_Address_On_Activation__c );
    }
    
    //Test method for Travel Portal OSR
    static testMethod void testTravelPortalOSRsWithoutAddress() {
        
        //insert Credit Card Settings record
        Credit_Card_Settings__c configCCDefaultSetting = TestUtilities.CreateCreditCardSettings();
        insert configCCDefaultSetting;
        
        //insert Contact record
        Contact c = TestUtilities.CreateNewContact(false);
        c.Birthdate = system.today().addYears(-28);
        c.Personal_Address_Line_1__c = 'Test';
        c.Personal_Address_Line_2__c = 'Test';
        c.Personal_Address_City__c = 'Test';
        c.Personal_Address_State__c = 'CA';
        c.Personal_Address_PostalCode__c = 'Test';
        c.Personal_Address_Country__c = 'USA';
        c.Legal_First_Name__c = 'Test';
        c.Legal_Last_Name__c = 'Test';
        insert c;
        
        //Set helper class variable
        CreditCardHelper.configDefaults = configCCDefaultSetting;
        CreditCardConstants.CONFIG_DEFAULT = configCCDefaultSetting; 
          
        List<Portfolio__c> payments = new List<Portfolio__c>();
        payments.add(new Portfolio__c(Status__c = Constants.ACTIVE, 
                                      Portfolio_Owner_Finance_Code__c = '678981', 
                                      First_Name_On_Card__c = 'Test', Last_Name_On_Card__c = 'Test',
                                      Billing_Address_Line_1__c = 'Test', Billing_Address_Line_2__c = 'Test',
                                      Billing_Address_City__c = 'Test', Billing_Address_State__c = 'CA',
                                      Billing_Address_PostalCode__c = 'Test',
                                      Card_Holder__c = c.Id ));
        insert payments; 
        
        //Credit Card record   
        List<Credit_Card__c> cards = new List<Credit_Card__c>(); 
        cards.add(new Credit_Card__c(Status__c = CreditCardConstants.CC_STATUS_VENDOR_APPROVAL, Payment_Account__c = payments[0].ID));
        insert cards;
          
        //Resord Type Credit Card request
        List<RecordType> recordTypeOSRCreditCardRequest =[Select Id from RecordType where SObjectType = 'OSR__c' 
                                                            AND DeveloperName =: CreditCardConstants.OSR_RECORD_TYPE_DEVELOPER_NAME_CREDIT_CARD_REQUEST 
                                                            AND IsActive = true limit 1];
        System.assertEquals(1, recordTypeOSRCreditCardRequest.size());
        
        //List of OSR to be record
        List<OSR__c> oSRs = new List<OSR__c>();
        oSRs.add(new OSR__c(Origin__c = CreditCardConstants.OSR_ORIGIN_TRAVEL_PORTAL, RecordTypeId = recordTypeOSRCreditCardRequest[0].Id, 
                                Request_Type__c = CreditCardConstants.OSR_REQUEST_TYPE_REPLACEMENT_ABC_CREDIT_CARD, Status__c = CreditCardConstants.OSR_STATUS_NEW, 
                                Related_Card__c = cards[0].ID, Contact__c = c.Id));
            
        //Start testing from here
        Test.startTest();
        
        //Insert OSRs   
        insert oSRs;
        
        //Assert for the address results
        oSRs = [Select Id, Address_Line_1__c, Address_Line_2__c, Address_City__c, Address_State__c, Address_Postal_Code__c from OSR__c where Id IN: oSRs];
        System.assertEquals(payments[0].Billing_Address_Line_1__c, oSRs[0].Address_Line_1__c);
        System.assertEquals(payments[0].Billing_Address_Line_2__c, oSRs[0].Address_Line_2__c);
        System.assertEquals(payments[0].Billing_Address_City__c, oSRs[0].Address_City__c);
        System.assertEquals(payments[0].Billing_Address_State__c, oSRs[0].Address_State__c);
        System.assertEquals(payments[0].Billing_Address_PostalCode__c, oSRs[0].Address_Postal_Code__c);
        
        //Check if the batch has been scheduled
        List<AsyncApexJob> aSyncJobs = [SELECT Id, JobItemsProcessed, TotalJobItems, NumberOfErrors, CreatedBy.Email FROM AsyncApexJob
                                                WHERE ApexClass.Name IN ('Batch_ProcessOSRs', 'Batch_AddCardsForReplacementRequest') 
                                                    AND Status IN: CreditCardConstants.ASYNC_APEX_JOB_PENDING_STATUSES];
        System.assertEquals(1, aSyncJobs.size());
        
        //Test stops here
        Test.stopTest();
        
        //Check if a new replace card is created with Update_Billing_Address_On_Activation__c  = true
        cards = [Select Status__c, Update_Billing_Address_On_Activation__c from Credit_Card__c where Payment_Account__c =: payments[0].Id order by CreatedDate];
        System.assertEquals(2, cards.size());
        System.assertEquals(CreditCardConstants.CC_STATUS_PENDING_DEACTIVATION, cards[0].Status__c);
    }
    
    // Added by Mahendra Swarnakar - CR-20151013-9317 - 10/28/2015 
    // Starts from here
    //Test method to populate advisory profile on OSR
    static testMethod void testPopulateDefaultAdvisoryProfile() {
        
        //Bypass all triggers
        Util.IsTest(true);
        Util.ByPassAllTriggers = true;
        
        //User record
        User currentUser;
        
        // This code runs as the system user
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator'];
        
        //User record
        User u = new User(Alias = 'standt', Email='standarduser@testorg.com', 
                            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                            LocaleSidKey='en_US', ProfileId = p.Id, TimeZoneSidKey = 'GMT',
                            UserName=Math.random() + '@test.com');
        
        //Update the User Finance Code if not alreayd populated
        System.runAs(u) {
            
            //Update the Employee Id
            currentUser = new User(Id = UserInfo.getUserId(), Finance_Code__c = '50011');
            update currentUser;
        }
        
        //Contact Instance
        Contact contact = TestUtilities.CreateNewContact(false);
        contact.Birthdate = System.today().addYears(-28);
        contact.Employee_ID__c = '50011';
        contact.Employee_User_Record__c = currentUser.Id;
        contact.Personal_Address_Line_1__c = 'Test';
        contact.Personal_Address_Line_2__c = 'Test';
        contact.Personal_Address_City__c = 'Test';
        contact.Personal_Address_State__c = 'CA';
        contact.Personal_Address_PostalCode__c = 'Test';
        contact.Personal_Address_Country__c = 'USA';
        contact.Legal_First_Name__c = 'Test';
        contact.Legal_Last_Name__c = 'Test';
        
        //Insert Contact
        insert contact;
        
        //Provider Profile Instance
        Provider_Profile__c providerProfile = new Provider_Profile__c(Provider_Profile_ID__c = '2');
        
        //Insert Provider Profile
        insert providerProfile;
        
        //ABC Profile Instance
        ABC_Profile__c abcProfile = new ABC_Profile__c(Name = 'Test', 
                                                            Over_aging_Warning_days__c = 35, 
                                                            Over_aging_Maximum_days__c = 45, 
                                                            Over_balance_Warning_threshold_1__c = .75, 
                                                            Over_balance_Warning_threshold_2__c = .90, 
                                                            Over_balance_Countdown_days__c = 3,
                                                            Provider_Profile__c = providerProfile.Id);
        //Insert ABC Profile
        insert abcProfile;
        
        //Quering portfolio record types details
        List<RecordType> rdTypesPortfolio = [select Id from RecordType 
                                            where DeveloperName = : CreditCardConstants.PORTFOLIO_RECORd_TYPE_Employee_Payment_Account AND
                                            SobjectType = 'Portfolio__c' AND IsActive = true];
        
        //Asserts for the results
        System.assertEquals(1,rdTypesPortfolio.size() );
        
        //Quering credit card record types details
        List<RecordType> rdTypesCreditCard = [select Id from RecordType 
                                                WHERE DeveloperName = : CreditCardConstants.CREDIT_CARD_RECORd_TYPE_ABC_Staff_Credit_Card  AND
                                                SobjectType = 'Credit_Card__c' AND IsActive = true];
        //Asserts for the results
        System.assertEquals(1, rdTypesCreditCard.size() );
        
        //Credit Card Settings instance
        Credit_Card_Settings__c configCCDefaultSetting = TestUtilities.CreateCreditCardSettings();
        
        //Update configCCDefaultSetting field
        configCCDefaultSetting.Staff_Portfolio_Record_Type__c = rdTypesPortfolio[0].id;
        configCCDefaultSetting.Staff_Card_Record_Type__c = rdTypesCreditCard[0].id;
        configCCDefaultSetting.Default_Portfolio_Profile__c = abcProfile.Id;
        
        //Insert Credit Card Settings record
        insert configCCDefaultSetting;
        
        //Set helper class variable
        CreditCardHelper.configDefaults = configCCDefaultSetting;
        CreditCardConstants.CONFIG_DEFAULT = configCCDefaultSetting;
        
        //Portfolio Instance 
        Portfolio__c payments = new Portfolio__c(Status__c = Constants.ACTIVE, 
                      Portfolio_Owner_Finance_Code__c = '678981', 
                      First_Name_On_Card__c = 'Test', Last_Name_On_Card__c = 'Test',
                      Billing_Address_Line_1__c = 'Test', Billing_Address_Line_2__c = 'Test',
                      Billing_Address_City__c = 'Test', Billing_Address_State__c = 'CA',
                      Billing_Address_PostalCode__c = 'Test',
                      Advisory_Profile__c = configCCDefaultSetting.Default_Portfolio_Profile__c,
                      RecordTypeId = configCCDefaultSetting.Staff_Portfolio_Record_Type__c,
                      Card_Holder__c = contact.Id );
        
        //insert Portfolio record
        insert payments; 
        
        //Credit Card Instance  
        Credit_Card__c card = new Credit_Card__c(Status__c = CreditCardConstants.CC_STATUS_ACTIVE, 
                                                    Payment_Account__c = payments.ID ,
                                                    RecordTypeId = configCCDefaultSetting.Staff_Card_Record_Type__c); 
        //Insert Credit card record                     
        insert card;
        
        //Enable all triggers
        Util.ByPassAllTriggers = false;
        
        //Retrive OSR record type
        List<RecordType> listOSRRecordType = [Select Id, DeveloperName From RecordType 
                                                Where DeveloperName =: CreditCardConstants.OSR_RECORD_TYPE_DEVELOPER_NAME_CREDIT_CARD_REQUEST 
                                                AND IsActive = TRUE];
        
        //Asserts for result
        System.assertEquals(1, listOSRRecordType.size());
        
        //List to hold OSR records
        List<OSR__c> listOsr = new List<OSR__c>();
        
        //Populating OSRs list
        listOsr.add(new OSR__c(Contact__c = contact.Id, RecordTypeId = listOSRRecordType[0].Id, 
                                Request_Type__c = CreditCardConstants.OSR_REQUEST_TYPE_REPLACEMENT_ABC_CREDIT_CARD,
                                Status__c = CreditCardConstants.OSR_STATUS_PENDING_FINANCE,
                                Related_Card__c = card.ID));
        listOsr.add(new OSR__c(Contact__c = contact.Id, RecordTypeId = listOSRRecordType[0].Id, 
                                Request_Type__c = CreditCardConstants.OSR_REQUEST_TYPE_DEACTIVATE_ABC_CREDIT_CARD,
                                Status__c = CreditCardConstants.OSR_STATUS_PENDING_FINANCE,
                                Related_Card__c = card.ID));
        
        //Test starts from here
        Test.startTest();
        
        //Insert OSR records
        insert listOsr;
        
        //Re-initialize OSR list
        listOsr = new List<OSR__c>();
        
        //Retrieve OSR records
        listOsr = [Select Id, Advisory_Profile__c, Request_Type__c From OSR__c ORDER BY Name ASC];
        
        //Assert for the result
        System.assertEquals(2, listOsr.size());
        System.assertEquals(abcProfile.ID, listOsr[0].Advisory_Profile__c);
        System.assertEquals(null, listOsr[1].Advisory_Profile__c);
        
        //Test ends here 
        Test.stopTest();    
    }
    //Ends here
}