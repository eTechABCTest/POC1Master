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
private class Test_RelationshipManagementController {
/**
 *   Purpose         :   Test class for RelationshipManagementController
 *            
 *   Create By       :   Subhash Garhwal
 *
 *   Created Date    :   07/3/2015
 *
 *   Revision Log    :   V_1.0 - Created - CR-20150825-9182
 * 
 *   Coverage        :   V_1.0 - 
 **/
    //Test Method
    static testMethod void myUnitTest() {
        
        //Create an Account
        Account account = TestUtilities.CreateNewAccount(false);
        
        //Insert
        insert account;
        
        //LiSt of contact
        List<Contact> contacts = new List<Contact>();
        
        //Create a Contact
        contacts.add(new Contact(FirstName = 'Test 1', LastName = 'Contact 1', Email = 'test@test.com', AccountId = account.Id, Employee_User_Record__c = Userinfo.getUserId()));
        contacts.add(new Contact(FirstName = 'Test 2', LastName = 'Contact 2', Email = 'test@test.com', AccountId = account.Id, Employee_User_Record__c = Userinfo.getUserId()));
        contacts.add(new Contact(FirstName = 'Test 3', LastName = 'Contact 3', Email = 'test@test.com', AccountId = account.Id, Employee_User_Record__c = Userinfo.getUserId()));
        
        //Insert
        insert contacts;
        
        //LiSt of Relationship Type
        List<Relationship_Type__c> relationshipTypes = new List<Relationship_Type__c>();
        
        //Add Record in List
        relationshipTypes.add(new Relationship_Type__c(Name = 'Relationship Type 1', Business_Owner__c = contacts[0].Id, Name_When_From__c = 'Testing From', Name_When_To__c = 'Testing To'));
        relationshipTypes.add(new Relationship_Type__c(Name = 'Relationship Type 2', Business_Owner__c = contacts[0].Id, Name_When_From__c = 'Testing From', Name_When_To__c = 'Testing To'));
        relationshipTypes.add(new Relationship_Type__c(Name = 'Relationship Type 3', Business_Owner__c = contacts[1].Id, Name_When_From__c = 'Testing From', Name_When_To__c = 'Testing To'));
        
        //Insert
        insert relationshipTypes;
        system.debug('%%%%%%%%%%'+relationshipTypes);
        //List of Staff Relationship
        List<Staff_Relationship__c> staffRelationships = new List<Staff_Relationship__c>();
        
        //Add Record in list
        staffRelationships.add(new Staff_Relationship__c(Name = 'Staff Relationship 1', Relationship__c = relationshipTypes[0].Id, From__c = contacts[0].Id, Start_Date__c = System.today().addDays(1), End_Date__c = System.today().addDays(5), To__c = contacts[1].Id ));
        staffRelationships.add(new Staff_Relationship__c(Name = 'Staff Relationship 2', Relationship__c = relationshipTypes[1].Id, From__c = contacts[1].Id, Start_Date__c = System.today().addDays(6), End_Date__c = System.today().addDays(10), To__c = contacts[0].Id ));
        staffRelationships.add(new Staff_Relationship__c(Name = 'Staff Relationship 3', Relationship__c = relationshipTypes[2].Id, From__c = contacts[1].Id, Start_Date__c = System.today().addDays(11), End_Date__c = System.today().addDays(15), To__c = contacts[2].Id ));
        staffRelationships.add(new Staff_Relationship__c(Name = 'Staff Relationship 4', Relationship__c = relationshipTypes[2].Id, From__c = contacts[2].Id, Start_Date__c = System.today().addDays(11), End_Date__c = System.today().addDays(15), To__c = contacts[1].Id ));
        staffRelationships.add(new Staff_Relationship__c(Name = 'Staff Relationship 5', Relationship__c = relationshipTypes[1].Id, From__c = contacts[0].Id, Start_Date__c = System.today().addDays(-5), End_Date__c = System.today().addDays(-3), To__c = contacts[1].Id ));
        staffRelationships.add(new Staff_Relationship__c(Name = 'Staff Relationship 6', Relationship__c = relationshipTypes[1].Id, From__c = contacts[0].Id, Start_Date__c = System.today().addDays(-2), End_Date__c = System.today().addDays(-1), To__c = contacts[1].Id ));
        staffRelationships.add(new Staff_Relationship__c(Name = 'Staff Relationship 7', Relationship__c = relationshipTypes[1].Id, From__c = contacts[0].Id, Start_Date__c = System.today(), End_Date__c = System.today(), To__c = contacts[1].Id ));
        
        //Insert
        insert staffRelationships;
        
        Test.setCurrentPage(new Pagereference('XYZ'));
        
        //Test method start here
        Test.startTest();
        
        //Put Perameter From URL
        Apexpages.currentPage().getParameters().Put('contactId',contacts[0].Id);
        
        //Create instant
        RelationshipManagementController rMController = new RelationshipManagementController();
        
        //Assert for result  
        system.assertEquals(5,rMController.listStaffRelationshipWrapper.size());
        
        //Set isCurrentlyActive value 
        rMController.isCurrentlyActive = true;
        
        //Call Method
        rMController.refreshResults();
        
        //Result For Assert 
        system.assertEquals(1,rMController.listStaffRelationshipWrapper.size());
        
        //Set isEffectiveDate Check Box True 
        rMController.isEffectiveDate = true;
        
        //Set Start Date
        rMController.filterStaffRelationship.Start_Date__c = system.Today();
        
        //Call Method
        rMController.refreshResults();
        
        //Result For Assert 
        system.assertEquals(1,rMController.listStaffRelationshipWrapper.size());
        
        //Set isEffectiveDate Check Box True 
        rMController.isEffectiveDate = true;
        
        //Set Start Date
        rMController.filterStaffRelationship.Start_Date__c = system.Today();
        rMController.filterStaffRelationship.End_Date__c = system.Today();
        
        //Call Method
        rMController.refreshResults();
        
        //Result For Assert 
        system.assertEquals(1,rMController.listStaffRelationshipWrapper.size());
        
        //Set isRelationshipType Check Box True 
        rMController.isRelationshipType = true;
        
        //Set isEffectiveDate Check Box True 
        rMController.isEffectiveDate = true;
        
        //Set Start Date
        rMController.filterStaffRelationship.Start_Date__c = system.Today().addDays(-2);
        rMController.filterStaffRelationship.Relationship__c = relationshipTypes[1].Id;
        
        //Call Method
        rMController.refreshResults();
        
        //Result For Assert 
        system.assertEquals(1,rMController.listStaffRelationshipWrapper.size());
        
        //Set isEffectiveDate Check Box True 
        rMController.isEffectiveDate = true;
        
        //Set Start Date
        rMController.filterStaffRelationship.Start_Date__c = null;
        
        //Call Methood
        rMController.refreshResults();
        
        //Single Assert on Error Messages  
        System.assert(ApexPages.getMessages()[0].getDetail().contains( 'You must indicate a start date' )); 
        
        //Set value of option
        rMController.selectedView = 'transfer';
        
        //Set transfer value
        rMController.transferStaffRelationship.From__c = null;
        rMController.transferStaffRelationship.Start_Date__c = null;
        
        //Call Methood
        rMController.refreshResults();
        
        //Single Assert on Error Messages  
        System.assert(ApexPages.getMessages()[1].getDetail().contains('Please indicate to whom this is being transferred, or change your choice to \'View existing relationships\''));
        
        //Single Assert on Error Messages  
        System.assert(ApexPages.getMessages()[2].getDetail().contains('Please indicate the effective date of the transfer'));
        
        //Set value of option
        rMController.selectedView = 'view';
        
        //Call Methood
        rMController.resetViews();
        
        //Assert for Result
        System.assertEquals(null,rMController.transferStaffRelationship.From__c);
        System.assertEquals(null,rMController.transferStaffRelationship.Start_Date__c);
        
        //Set isEffectiveDate Check Box false 
        rMController.isEffectiveDate = false;
        
        //Call Methood
        rMController.resetFilters(); 
        
        //Assert for Result
        System.assertEquals(null,rMController.filterStaffRelationship.Start_Date__c);
        System.assertEquals(null,rMController.filterStaffRelationship.End_Date__c);
        
        //Set isEffectiveDate Check Box True 
        rMController.isEffectiveDate = true;
        
        //Set Start Date
        rMController.filterStaffRelationship.Start_Date__c = system.Today().addDays(-2);
        
        //Put Perameter From URL
        Apexpages.currentPage().getParameters().Put('contactId',contacts[0].Id);
        
        //Create instant
        rMController = new RelationshipManagementController();
        
        //Set value
        rMController.staffRelationship.From__c = null;
        
        //Call Methoods
        rMController.save();
        
        //Single Assert on Error Messages  
        System.assert(ApexPages.getMessages()[3].getDetail().contains( 'Please enter data in all teh required fields' )); 
        
        //Set value
        rMController.staffRelationship.From__c = contacts[0].Id;
        
        //Fell Data 
        rMController.listStaffRelationshipWrapper[4].sR.Start_Date__c = null;
        
        //Call Methoods
        rMController.save();
        
        //Single Assert on Error Messages  
        System.assert(ApexPages.getMessages()[4].getDetail().contains( 'Related to, Relationship, Start Date is mandatory for each item and Effective date should be valid' )); 
        
        //Put Perameter From URL
        Apexpages.currentPage().getParameters().Put('contactId',contacts[0].Id);
        
        //Create instant
        rMController = new RelationshipManagementController();
         
        //Assert for result
        system.assertEquals(5,rMController.listStaffRelationshipWrapper.size());
        
        //Set value of option
        rMController.selectedView = 'transfer';
        
        //Set transfer value
        rMController.transferStaffRelationship.From__c = null;
        rMController.transferStaffRelationship.Start_Date__c = null;
        
        //Call Methoods
        rMController.save();
        
        //Single Assert on Error Messages  
        System.assert(ApexPages.getMessages()[5].getDetail().contains( 'Transfer to and Effective as of, both these values are required.' )); 
        
        //Set value
        rMController.staffRelationship.From__c = contacts[1].Id;
        
        //Call Methoods
        rMController.refreshResults();
        
        //Assert for result
        System.assertEquals(5,rMController.listStaffRelationshipWrapper.size());
        
        //Call SelectOption
        List<SelectOption> sOList = rMController.views; 
        
        //Set isEffectiveDate Check Box True 
        rMController.isEffectiveDate = true;
        
        //Set Start Date
        rMController.filterStaffRelationship.Start_Date__c = system.Today().addDays(-2);
        rMController.filterStaffRelationship.End_Date__c = system.Today().addDays(-2);
        
        //Select row 
        rMController.listStaffRelationshipWrapper[0].selected = true;
        
        //Call Methoods
        rMController.applyDates();
        
        //Assert for result
        System.assertEquals(system.Today().addDays(-2),rMController.listStaffRelationshipWrapper[0].sR.Start_Date__c);
        System.assertEquals(system.Today().addDays(-2),rMController.listStaffRelationshipWrapper[0].sR.End_Date__c);
        
        rMController.isEffectiveDate = true;
        
        //Set Start Date
        rMController.filterStaffRelationship.Start_Date__c = null;
        rMController.filterStaffRelationship.End_Date__c = null;
        
        //Select row 
        rMController.listStaffRelationshipWrapper[0].selected = true;
        
        //Call Methoods
        rMController.applyDates();
        
        //Single Assert on Error Messages  
        System.assert(ApexPages.getMessages()[6].getDetail().contains( 'You must indicate either a start date or end date')); 
        
        //Result For Assert 
        system.assertEquals(5,rMController.listStaffRelationshipWrapper.size());
        
        rMController.listStaffRelationshipWrapper[0].selected = false;
        rMController.listStaffRelationshipWrapper[1].selected = false;
        rMController.listStaffRelationshipWrapper[2].selected = false;
        rMController.listStaffRelationshipWrapper[3].selected = false;
        rMController.listStaffRelationshipWrapper[4].selected = false;
        
        //Call Methoods
        rMController.deleteRelationship();
        
        //Select row
        rMController.listStaffRelationshipWrapper[4].selected = true;
        
        try{
             
            //Call Methoods
            rMController.deleteRelationship();
        
        }catch(Exception ex){
            
            //Single Assert on Error Messages  
            System.assert(ApexPages.getMessages()[7].getDetail().contains( 'You must indicate either a start date or end date.' )); 
        }
        
        //Create a new Staff Relationship
        rMController.staffRelationWrapper.sR.From__c = contacts[1].Id;
        rMController.staffRelationWrapper.sR.Relationship__c = relationshipTypes[0].Id;
        
        //Call Methoods
        rMController.populateDirectionList();
        
        //Call method to save the data
        rMController.saveNewStaffReltionShipData();
        
        //Assert for result 
        System.assertEquals(6,rMController.listStaffRelationshipWrapper.size());
        
        //Set Selected Row index
        rMController.selectedStaffRelationshipIndex = 1;
        
        //Call edit relationship method
        rMController.editRelationShip();
        
        //Assert for result 
        System.assertEquals(rMController.staffRelationWrapper,rMController.listStaffRelationshipWrapper.get(rMController.selectedStaffRelationshipIndex));
        
        //Test method stop here
        Test.stopTest();
        
    }
    
    //Test Method
    static testMethod void myUnitTest2() {
        
        //Create an Account
        Account account = TestUtilities.CreateNewAccount(false);
        
        //Insert
        insert account;
        
        //LiSt of contact 
        List<Contact> contacts = new List<Contact>();
        
        //Create a Contact
        contacts.add(new Contact(FirstName = 'Test 1', LastName = 'Contact 1', Email = 'test@test.com', AccountId = account.Id, Employee_User_Record__c = Userinfo.getUserId()));
        contacts.add(new Contact(FirstName = 'Test 2', LastName = 'Contact 2', Email = 'test@test.com', AccountId = account.Id, Employee_User_Record__c = Userinfo.getUserId()));
        contacts.add(new Contact(FirstName = 'Test 3', LastName = 'Contact 3', Email = 'test@test.com', AccountId = account.Id, Employee_User_Record__c = Userinfo.getUserId()));
        
        //Insert
        insert contacts;
        
        //LiSt of Relationship Type
        List<Relationship_Type__c> relationshipTypes = new List<Relationship_Type__c>();
        
        //Add Record in List
        relationshipTypes.add(new Relationship_Type__c(Name = 'Relationship Type 1', Business_Owner__c = contacts[0].Id, Name_When_From__c = 'Testing From', Name_When_To__c = 'Testing To'));
        
        //Insert
        insert relationshipTypes;
        
        //List of Staff Relationship
        List<Staff_Relationship__c> staffRelationships = new List<Staff_Relationship__c>();
        
        //Add Record in list
        staffRelationships.add(new Staff_Relationship__c(Name = 'Staff Relationship 1', Relationship__c = relationshipTypes[0].Id, From__c = contacts[0].Id, Start_Date__c = System.today().addDays(1), End_Date__c = System.today().addDays(5), To__c = contacts[1].Id ));
        
        //Insert
        insert staffRelationships;
        
        //Test method start here
        Test.startTest(); 
        
        //Put Perameter From URL
        Apexpages.currentPage().getParameters().Put('contactId',contacts[0].Id);
        
        //Create instant
        RelationshipManagementController rMController = new RelationshipManagementController();
        
        //Assert for result
        system.assertEquals(1,rMController.listStaffRelationshipWrapper.size());
        
        //Call SelectOption
        List<SelectOption> sOList = rMController.views;
        
        //Set value of option
        rMController.selectedView = 'transfer';

        //Select row 
        rMController.listStaffRelationshipWrapper[0].selected = true;
        
        //Set transfer value
        rMController.transferStaffRelationship.From__c = contacts[2].Id;
        rMController.transferStaffRelationship.Start_Date__c = system.Today().addDays(4);
        
        //Call Methoods
        rMController.save();
        
        //Assert for result
        System.assertEquals(system.Today().addDays(3),rMController.listStaffRelationshipWrapper[0].sR.End_Date__c);
        
        //Set views
        rMController.selectedView = 'view';
        
        //Set data
        rMController.transferStaffRelationship.From__c = null;
        
        //Call method
        Pagereference pR = rMController.saveAndClose();
        
        //Assert for result
        System.assert(pR.getUrl().contains(contacts[0].Id));
        
        //Test method Stop here
        Test.stopTest();
        
    }
    
    //Test Method
    static testMethod void myUnitTest3() {
        
        //Create an Account
        Account account = TestUtilities.CreateNewAccount(false);
        
        //Insert
        insert account;
        
        //LiSt of contact 
        List<Contact> contacts = new List<Contact>();
        
        //Create a Contact
        contacts.add(new Contact(FirstName = 'Test 1', LastName = 'Contact 1', Email = 'test@test.com', AccountId = account.Id, Employee_User_Record__c = Userinfo.getUserId()));
        contacts.add(new Contact(FirstName = 'Test 2', LastName = 'Contact 2', Email = 'test@test.com', AccountId = account.Id, Employee_User_Record__c = Userinfo.getUserId()));
        
        //Insert
        insert contacts;
        
        //LiSt of Relationship Type
        List<Relationship_Type__c> relationshipTypes = new List<Relationship_Type__c>();
        
        //Add Record in List
        relationshipTypes.add(new Relationship_Type__c(Name = 'Relationship Type 1', Business_Owner__c = contacts[0].Id, Name_When_From__c = 'Testing From', Name_When_To__c = 'Testing To'));
        
        //Insert
        insert relationshipTypes;
        
        //List of Staff Relationship
        List<Staff_Relationship__c> staffRelationships = new List<Staff_Relationship__c>();
        
        //Add Record in list
        staffRelationships.add(new Staff_Relationship__c(Name = 'Staff Relationship 1', Relationship__c = relationshipTypes[0].Id, From__c = contacts[0].Id, Start_Date__c = System.today().addDays(1), End_Date__c = System.today().addDays(5), To__c = contacts[1].Id ));
        
        //Insert
        insert staffRelationships;
        
        //Test method start here
        Test.startTest();
        
        //Put Perameter From URL
        Apexpages.currentPage().getParameters().Put('contactId',contacts[0].Id);
        
        //Create instant
        RelationshipManagementController rMController = new RelationshipManagementController();
        
        //Set Value
        rMController.selectedView = 'transfer';
        rMController.transferStaffRelationship.From__c = contacts[1].Id;
        rMController.transferStaffRelationship.Start_Date__c = system.Today().addDays(4);
        
        //Call Method
        Pagereference pR = rMController.saveAndClose();
        
        //Assert for result
        System.assert(pR.getUrl().contains(contacts[1].Id));
          
        //Call Method
        pR = rMController.cancel();
        
        //Assert for result
        System.assert(pR.getUrl().contains(contacts[0].Id));
        
            
        //Test method stop here
        Test.stopTest();
    }
}