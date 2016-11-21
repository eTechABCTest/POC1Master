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
@isTest(seeAllData = false )
private class Test_Trigger_StaffHistory {
/**
  *   Purpose         :   Test class for Trigger_StaffHistory
  *            
  *   Create By       :   Subhash Garhwal
  *
  *   Created Date    :   08/24/2015
  *
  *   Revision Log    : V_1.0 - Created - CR-20150825-9182 
  *                     V_1.1 - Modified - Subhash Garhwal - CR-20150825-9182 - 09/02/2015 - New method added - Add new test method for onChange method
  *                     V_1.2 - MOdified - Rajeev Jain - 05/06/2016 - ISSP Deployment E - Corrected asserts as per the updated loogice of CreateIncentiveChange log method
  * 
  * Coverage        :   98%
  *                     V_1.1 - 98%
  **/
    
    //This method for CreateIncentiveChangeLog method
    static testMethod void testCreateIncentiveChangeLog() {
        
        //Create an institution
        Account account = TestUtilities.CreateNewAccount(false);
        
        //Insert
        insert account;
        
        //Create a Contact
        Contact contact = new Contact(FirstName = 'Test', LastName = 'Contact', Email = 'test@test.com', AccountId = account.Id, Employee_User_Record__c = Userinfo.getUserId());
        
        //Insert
        insert contact;
        
        //List of Value Type
        List<Value_Type__c> valueTypes = new List<Value_Type__c>();
        
        valueTypes.add(new Value_Type__c(Values_Permitted__c = 'Date',Category__c = 'Goals'));
        valueTypes.add(new Value_Type__c(Values_Permitted__c = 'Text', Category__c = 'Goals'));
        
        //Insert
        insert valueTypes;
        
        //List of Staff History
        List<Staff_History__c> staffHistory = new List<Staff_History__c>();

        //Add new Staff History in list.
        staffHistory.add(new Staff_History__c(Staff_Member__c = contact.Id, Value_Type__c = valueTypes[0].Id, Start_Date__c = System.today().addDays(1), Date_Value__c = System.today()));
        staffHistory.add(new Staff_History__c(Staff_Member__c = contact.Id, Value_Type__c = valueTypes[1].Id, Start_Date__c = System.today().addDays(5), End_Date__c = System.today().addDays(10), Text_Value__c = 'Testing'));
        staffHistory.add(new Staff_History__c(Staff_Member__c = contact.Id, Value_Type__c = valueTypes[1].Id, Start_Date__c = System.today().addDays(15), End_Date__c = System.today().addDays(20), Text_Value__c = 'Testing2'));
        staffHistory.add(new Staff_History__c(Staff_Member__c = contact.Id, Value_Type__c = valueTypes[1].Id, Start_Date__c = System.today().addDays(25), End_Date__c = System.today().addDays(30), Text_Value__c = 'Testing3'));
        
        //Test start here
        Test.startTest();
        
        //Insert 
        insert staffHistory;
        
        //Query Through Incentive Change Log
        List<Incentive_Change_Log__c> incentives = [Select Id, Name, Staff_History__c From Incentive_Change_Log__c Where Staff_History__c IN : staffHistory];
        
        //Assert for result
        System.assertEquals(4, incentives.size());
        System.assertEquals(staffHistory[0].Id, incentives[0].Staff_History__c);
        System.assertEquals(staffHistory[1].Id, incentives[1].Staff_History__c);
        System.assertEquals(staffHistory[2].Id, incentives[2].Staff_History__c);
        System.assertEquals(staffHistory[3].Id, incentives[3].Staff_History__c);
        
        //Update Staff Attributes fields values to execute the create incentive change log logic
        staffHistory[0].Date_Value__c = System.today().addDays(2);
        staffHistory[1].Text_Value__c = 'Update';
        staffHistory[2].Start_Date__c = System.today().addDays(16);
        staffHistory[3].End_Date__c = System.today().addDays(31);
        
        //Update
        update staffHistory;
        
        //Query Through Incentive Change Log
        incentives = [Select Id, Name, Staff_History__c,Change_Type__c, Start_Date__c, End_Date__c From Incentive_Change_Log__c Where Staff_History__c IN : staffHistory AND Id NOT IN : incentives];
        
        //Assert for result
        System.assertEquals(2, incentives.size());
        System.assertEquals(staffHistory[2].Id, incentives[0].Staff_History__c);
        System.assertEquals(staffHistory[3].Id, incentives[1].Staff_History__c);
        System.assertEquals('Modified', incentives[0].Change_Type__c);
        System.assertEquals('Modified', incentives[1].Change_Type__c);
        
        //Test stop here
        Test.stopTest();
    }
    
    //This method for preventDuplicates method
    static testMethod void testPreventDuplicates() {
        
        //Create an institution
        Account account = TestUtilities.CreateNewAccount(false);
        
        //Insert
        insert account;
        
        //Create a Contact
        List<Contact> contacts = new List<Contact>();
        contacts.add(new Contact(FirstName = 'Test1', LastName = 'Contact1', Email = 'test@test1.com', AccountId = account.Id, Employee_User_Record__c = Userinfo.getUserId()));
        contacts.add(new Contact(FirstName = 'Test2', LastName = 'Contact2', Email = 'test@test2.com', AccountId = account.Id, Employee_User_Record__c = Userinfo.getUserId()));
        contacts.add(new Contact(FirstName = 'Test3', LastName = 'Contact3', Email = 'test@test3.com', AccountId = account.Id, Employee_User_Record__c = Userinfo.getUserId()));
        contacts.add(new Contact(FirstName = 'Test4', LastName = 'Contact4', Email = 'test@test4.com', AccountId = account.Id, Employee_User_Record__c = Userinfo.getUserId()));
        contacts.add(new Contact(FirstName = 'Test5', LastName = 'Contact5', Email = 'test@test4.com', AccountId = account.Id, Employee_User_Record__c = Userinfo.getUserId()));
    
        //Insert
        insert contacts;
        
        //List of Value Type
        List<Value_Type__c> valueTypes = new List<Value_Type__c>();
        
        valueTypes.add(new Value_Type__c(Values_Permitted__c = 'Date', Category__c = 'Earnings', Rule__c = 'Staff member may have unlimited, overlapping records for this attribute'));
        valueTypes.add(new Value_Type__c(Values_Permitted__c = 'Date', Category__c = 'Earnings', Rule__c = 'Staff member may have unlimited, overlapping records for this attribute'));
        valueTypes.add(new Value_Type__c(Values_Permitted__c = 'Date', Category__c = 'Earnings', Rule__c = 'Staff member may have multiple, non-overlapping records for this attribute'));
        valueTypes.add(new Value_Type__c(Values_Permitted__c = 'Date', Category__c = 'Earnings', Rule__c = 'Staff member may have multiple, non-overlapping records for this attribute'));
        valueTypes.add(new Value_Type__c(Values_Permitted__c = 'Text', Category__c = 'Goals', Rule__c = 'Staff member may have only one record for this attribute'));
        valueTypes.add(new Value_Type__c(Values_Permitted__c = 'Text', Category__c = 'Goals', Rule__c = 'Staff member may have only one record for this attribute'));
        valueTypes.add(new Value_Type__c(Values_Permitted__c = 'Text', Category__c = 'Goals', Rule__c = 'Staff member may have only one record associated with this category'));
        valueTypes.add(new Value_Type__c(Values_Permitted__c = 'Text', Category__c = 'Goals', Rule__c = 'Staff member may have only one record associated with this category'));
        valueTypes.add(new Value_Type__c(Values_Permitted__c = 'Text', Category__c = 'Goals', Rule__c = 'Staff member may have multiple, non-overlapping records for this category'));
        valueTypes.add(new Value_Type__c(Values_Permitted__c = 'Text', Category__c = 'Goals', Rule__c = 'Staff member may have multiple, non-overlapping records for this category'));
        
        //Insert
        insert valueTypes;
        
        //List of Staff History
        List<Staff_History__c> staffHistorys = new List<Staff_History__c>();

        //Add new Staff History in list.
        staffHistorys.add(new Staff_History__c(Staff_Member__c = contacts[0].Id, Value_Type__c = valueTypes[0].Id, Start_Date__c = System.today().addDays(-10), End_Date__c = System.today().addDays(-5), Date_Value__c = System.today().addDays(1)));
        staffHistorys.add(new Staff_History__c(Staff_Member__c = contacts[0].Id, Value_Type__c = valueTypes[1].Id, Start_Date__c = System.today().addDays(-4), End_Date__c = System.today().addDays(-1), Date_Value__c = System.today().addDays(2)));
        staffHistorys.add(new Staff_History__c(Staff_Member__c = contacts[1].Id, Value_Type__c = valueTypes[2].Id, Start_Date__c = System.today().addDays(1), End_Date__c = System.today().addDays(4), Date_Value__c = System.today().addDays(3)));
        staffHistorys.add(new Staff_History__c(Staff_Member__c = contacts[1].Id, Value_Type__c = valueTypes[3].Id, Start_Date__c = System.today().addDays(5), End_Date__c = System.today().addDays(9), Date_Value__c = System.today().addDays(4)));
        staffHistorys.add(new Staff_History__c(Staff_Member__c = contacts[2].Id, Value_Type__c = valueTypes[4].Id, Start_Date__c = System.today().addDays(10), End_Date__c = System.today().addDays(14), Text_Value__c = 'Testing'));
        staffHistorys.add(new Staff_History__c(Staff_Member__c = contacts[2].Id, Value_Type__c = valueTypes[5].Id, Start_Date__c = System.today().addDays(15), End_Date__c = System.today().addDays(19), Text_Value__c = 'Testing1'));
        staffHistorys.add(new Staff_History__c(Staff_Member__c = contacts[3].Id, Value_Type__c = valueTypes[6].Id, Start_Date__c = System.today().addDays(20), End_Date__c = System.today().addDays(24), Text_Value__c = 'Testing2'));
        staffHistorys.add(new Staff_History__c(Staff_Member__c = contacts[3].Id, Value_Type__c = valueTypes[7].Id, Start_Date__c = System.today().addDays(25), End_Date__c = System.today().addDays(30), Text_Value__c = 'Testing3'));
        staffHistorys.add(new Staff_History__c(Staff_Member__c = contacts[4].Id, Value_Type__c = valueTypes[8].Id, Start_Date__c = System.today().addDays(31), End_Date__c = System.today().addDays(34), Text_Value__c = 'Testing4'));
        staffHistorys.add(new Staff_History__c(Staff_Member__c = contacts[4].Id, Value_Type__c = valueTypes[9].Id, Start_Date__c = System.today().addDays(32), End_Date__c = System.today().addDays(40), Text_Value__c = 'Testing5'));
        
        //Test start here
        Test.startTest();
        
        //Change Record data
        staffHistorys[3].Value_Type__c = valueTypes[2].Id;
        staffHistorys[3].Start_Date__c = System.today().addDays(3);
        
        try{
            
            //Update
            Insert staffHistorys;
         
        }catch(Exception ex){
            
            //Assert for Result 
            System.assert(ex.getMessage().contains(Label.SA_OVERLAPPING_FOR_ATTRIBUTE));
        }
        
        //Change Staff History Record
        staffHistorys[3].Value_Type__c = valueTypes[3].Id;
        staffHistorys[3].Start_Date__c = System.today().addDays(5);
       
        try{
            
            //Insert 
            insert staffHistorys;
        
        }catch(Exception ex){
            
            //Assert for Result
            System.assert(ex.getMessage().contains(Label.SA_ONLY_HAVE_ONE_RECORD_FOR_THIS_CATEGORY));
        }
        
        //Update Value Type
        valueTypes[6].Category__c = 'Other';
        
        //Update
        update valueTypes[6];
        
        //Update record
        staffHistorys[5].Value_Type__c = valueTypes[4].Id;
        staffHistorys[5].Staff_Member__c = contacts[2].Id; 
        
        try{
            
            //Insert
            insert staffHistorys;
        
        }catch(Exception ex){
            
            //Assert for Result 
            System.assert(ex.getMessage().contains(Label.SA_ONLY_HAVE_ONE_RECORD_PER_ATTRIBUTE));
        }
        
        //Change staff History record data
        staffHistorys[5].Value_Type__c = valueTypes[5].Id;

        try{
            
            //Insert
            insert staffHistorys;
        
        }catch(Exception ex){
            
            //Assert for Result 
            System.assert(ex.getMessage().contains(Label.SA_OVERLAPPING_FOR_CATEGORY));
        }
        
        //Update Value Type 
        valueTypes[8].Category__c = 'Other';
        
        //Update
        update valueTypes[8];
         
        //Change Staff History Field Value
        staffHistorys[9].Start_Date__c = System.today().addDays(35);
        
        //Insert
        insert staffHistorys;
        
        //Assert For Result
        System.assertEquals(10,staffHistorys.size()); 
        
        //Update Staff History Record
        staffHistorys[3].Value_Type__c = valueTypes[2].Id;
        staffHistorys[3].Start_Date__c = System.today().addDays(3);
        
        try{
            
            //Update
            update staffHistorys[3];
        
        }catch(Exception ex){
            
            //Assert for Result 
            System.assert(ex.getMessage().contains(Label.SA_OVERLAPPING_FOR_ATTRIBUTE));
        }
        
        //Update Value Type
        valueTypes[6].Category__c = 'Goals';
        
        //Update
        update valueTypes[6];
        
        staffHistorys[7].Value_Type__c = valueTypes[6].Id;
       
        try{
            
            //Update 
            update staffHistorys[7];
        
        }catch(Exception ex){
            
            //Assert for Result
            System.assert(ex.getMessage().contains(Label.SA_ONLY_HAVE_ONE_RECORD_FOR_THIS_CATEGORY));
        }
        
        //Update record
        staffHistorys[5].Value_Type__c = valueTypes[4].Id;
        staffHistorys[5].Staff_Member__c = contacts[2].Id; 
        
        try{
            
            //Insert
            update staffHistorys[5];
        
        }catch(Exception ex){
            
            //Assert for Result 
            System.assert(ex.getMessage().contains(Label.SA_ONLY_HAVE_ONE_RECORD_PER_ATTRIBUTE));
        }
        
        //Update Value Type 
        valueTypes[8].Category__c = 'Goals';
        
        //Update
        update valueTypes[8];
        
        //Change staff History record data
        staffHistorys[9].End_Date__c = System.today().addDays(32);
        try{
            
            //update 
            update staffHistorys[9];
         
        }catch(Exception ex){
             
            //Assert for Result 
            System.assert(ex.getMessage().contains(Label.SA_OVERLAPPING_FOR_CATEGORY));
        }
        
        //Change staff History record data
        staffHistorys[9].Start_Date__c = System.today().addDays(32);
        
        try{
            
            //update 
            update staffHistorys[9];
         
        }catch(Exception ex){
             
            //Assert for Result 
            System.assert(ex.getMessage().contains(Label.SA_OVERLAPPING_FOR_CATEGORY));
        }
        
        //Change staff History record data
        staffHistorys[9].End_Date__c = System.today().addDays(36);
        
        try{
            
            //update 
            update staffHistorys[9];
         
        }catch(Exception ex){
            
            //Assert for Result 
            System.assert(ex.getMessage().contains(Label.SA_OVERLAPPING_FOR_CATEGORY));
        }
        
        //Query Through Staff History
        List<Staff_History__c>sHList = [Select Id From Staff_History__c Where Id IN: staffHistorys];
        
        //Assert for result
        system.assertEquals(10,sHList.size());
        
        //Update Contact
        contacts[0].FirstName = 'Update FirstName';
        contacts[1].LastName = 'Update LastName';
        
        //Update
        update contacts;
        
        //Update Value Type 
        valueTypes[8].Rule__c = 'Staff member may have unlimited, overlapping records for this attribute';
        
        //Update
        update valueTypes[8];
        
        //Query Through Staff History
        sHList = [Select Id,Value_Type__r.Rule__c From Staff_History__c Where Id IN: staffHistorys AND Value_Type__r.Rule__c =: 'Staff member may have unlimited, overlapping records for this attribute'];
        
        //Assert for result
        system.assertEquals(3,sHList.size());
        
        //Update Value Type
        valueTypes[7].Category__c = 'Goals'; 
        valueTypes[7].Rule__c = 'Staff member may have only one record associated with this category';
        valueTypes[8].Category__c = 'Goals'; 
        valueTypes[8].Rule__c = 'Staff member may have only one record associated with this category';
        
        //Update
        update valueTypes[7];
        update valueTypes[8];
        
        //Update Staff History
        staffHistorys[8].Start_Date__c = System.today().addDays(32);
        
        try{
            
            //Update 
            update staffHistorys[8];
        
        }catch(Exception ex){
            
            //Assert for Result
            System.assert(ex.getMessage().contains(Label.SA_ONLY_HAVE_ONE_RECORD_FOR_THIS_CATEGORY));
        }
        
        //Test start here
        Test.stopTest();
    }
        
    static testMethod void testAssignSource() {
        
        //Profile    
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator']; 
      
        //User
        User u = new User(Alias = 'standt', Email='standarduser@testorg.com', 
                            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                            LocaleSidKey='en_US', ProfileId = p.Id, department = 'STP',
                            TimeZoneSidKey='America/Los_Angeles', UserName=Math.random() + '@test.com');

        //Create an institution
        Account account = TestUtilities.CreateNewAccount(false);
        
        //Insert
        insert account;
        
        //Create a Contact
        Contact contact = new Contact(FirstName = 'Test', LastName = 'Contact', Email = 'test@test.com', AccountId = account.Id, Employee_User_Record__c = Userinfo.getUserId());
        
        //Insert
        insert contact;
        
        //List of Value Type
        List<Value_Type__c> valueTypes = new List<Value_Type__c>();
        
        valueTypes.add(new Value_Type__c(Values_Permitted__c = 'Date',Category__c = 'Goals'));
        valueTypes.add(new Value_Type__c(Values_Permitted__c = 'Text', Category__c = 'Goals'));
        
        //Insert Value Type
        insert valueTypes;
            
        //List of Staff History
        List<Staff_History__c> staffHistory = new List<Staff_History__c>();

        //Add new Staff History in list.
        staffHistory.add(new Staff_History__c(Staff_Member__c = contact.Id, Value_Type__c = valueTypes[0].Id, Start_Date__c = System.today().addDays(1), End_Date__c = System.today().addDays(5), Date_Value__c = System.today().addDays(1)));
        staffHistory.add(new Staff_History__c(Staff_Member__c = contact.Id, Value_Type__c = valueTypes[1].Id, Start_Date__c = System.today().addDays(6), End_Date__c = System.today().addDays(9), Text_Value__c = 'Testing'));
        staffHistory.add(new Staff_History__c(Staff_Member__c = contact.Id, Value_Type__c = valueTypes[1].Id, Start_Date__c = System.today().addDays(10), End_Date__c = System.today().addDays(15), Text_Value__c = 'Testing2'));
     
        //Test start here
        Test.startTest();
        
        System.runAs(u){
            
            //Insert Staff History 
            insert staffHistory;

            //Query over Staff Relationship
            List<Staff_History__c> staffHistoryRecords = [select Id,Source__c From Staff_History__c];
            
            //Assert for result
            System.assertEquals('Native', staffHistoryRecords[0].Source__c);
            System.assertEquals('Native', staffHistoryRecords[1].Source__c);
            System.assertEquals('Native', staffHistoryRecords[2].Source__c);
        }
        
        //Test stop here
        Test.stopTest();    
    }
    
    //Modified - Subhash Garhwal - CR-20150825-9182 - 09/02/2015 - New method added - onChangeValue
    //This method for onChangeValues method
    static testMethod void myUnitTest() {
    
        //Create an institution
        Account account = TestUtilities.CreateNewAccount(false);
        
        //Insert
        insert account;
        
        //Create a Contact
        Contact contact = new Contact(FirstName = 'Test', LastName = 'Contact', Email = 'test@test.com', AccountId = account.Id, Employee_User_Record__c = Userinfo.getUserId());
        
        //Insert
        insert contact;
        
        //List of Value Type
        List<Value_Type__c> valueTypes = new List<Value_Type__c>();
        
        valueTypes.add(new Value_Type__c(Values_Permitted__c = 'Date',Category__c = 'Goals',  Use_As_Value__c = true));
        valueTypes.add(new Value_Type__c(Values_Permitted__c = 'Text', Category__c = 'Goals', Use_As_Value__c = true));
        
        //Insert
        insert valueTypes;
        
        //List of Staff History
        List<Staff_History__c> staffHistories = new List<Staff_History__c>();
        
        //Add new Staff History in list.
        staffHistories.add(new Staff_History__c(Staff_Member__c = contact.Id, Value_Type__c = valueTypes[1].Id, 
                                                Start_Date__c = System.today().addDays(1), End_Date__c = System.today().addDays(5),
                                               Text_Value__c = 'Testing',Checkbox_Value__c = false));
        staffHistories.add(new Staff_History__c(Staff_Member__c = contact.Id, Value_Type__c = valueTypes[1].Id, 
                                                Start_Date__c = System.today().addDays(6), End_Date__c = System.today().addDays(10),
                                                Text_Value__c = 'Testing1', Percent_Value__c = 10));
        staffHistories.add(new Staff_History__c(Staff_Member__c = contact.Id, Value_Type__c = valueTypes[1].Id, 
                                                Start_Date__c = System.today().addDays(11), End_Date__c = System.today().addDays(15), 
                                                Text_Value__c = 'Testing2', Number_Value__c = 50));
        staffHistories.add(new Staff_History__c(Staff_Member__c = contact.Id, Value_Type__c = valueTypes[1].Id, 
                                                Start_Date__c = System.today().addDays(16), End_Date__c = System.today().addDays(20), 
                                                Text_Value__c = 'Testing3'));
        
        //Test start here
        Test.startTest();
        
        //Insert
        insert staffHistories;
        
        //List of Staff History
        List<Staff_History__c> staffHistory = [Select Id, Checkbox_Value__c, Date_Value__c, Number_Value__c, Percent_Value__c from Staff_History__c];
        
        //Assert for results
        System.assertEquals(false, staffHistory[0].Checkbox_Value__c);
        System.assertEquals(false, staffHistory[3].Checkbox_Value__c);
        System.assertEquals(null, staffHistory[0].Date_Value__c);
        System.assertEquals(null, staffHistory[2].Number_Value__c);
        System.assertEquals(null, staffHistory[1].Percent_Value__c);
        
        //Test stop here
        Test.stopTest();    
    }  
}