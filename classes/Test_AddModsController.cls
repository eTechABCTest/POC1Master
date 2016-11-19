/**
 * 
 * Desription      :   	test methods for the AddModsController class
 * 
 * Revision Logs   :   	v1.0 - Victor Hanson - 2/1/2016 - Created
 * 
 * 
 **/
@isTest
public class Test_AddModsController {
    
    /**
     * 
     * @description: Create a Change Request, 2 Components, 1 Modification, 2 IS Environments
     * 
     **/
    @testSetup
    static void setup() {
        //create a change request
        SFDC_Change_Request__c cr = new SFDC_Change_Request__c(Title__c = 'Demo Change Request',
                                                               Request_Description__c = 'demo',
                                                               Business_Justification__c = 'demo');
        insert cr;
        
        
        //create 2 components
        IS_System_Component__c component1 = new IS_System_Component__c(Name = 'will auto-populate',
                                                                       Object_Label__c = 'Account',
                                                                       Object_API_Name__c = 'Account',
                                                                       Object_Type__c = 'Object',
                                                                       Salesforce_Object_Id__c = '01I4B0000000007AAA',
                                                                       SOX_Object__c = TRUE);
        IS_System_Component__c component2 = new IS_System_Component__c(Name = 'will auto-populate',
                                                                       Object_Label__c = 'Contact',
                                                                       Object_API_Name__c = 'Contact',
                                                                       Salesforce_Object_Id__c = '01I4B0000000007BBB',
                                                                       Object_Type__c = 'Object',
                                                                       SOX_Object__c = FALSE);
        list<IS_System_Component__c> components = new list<IS_System_Component__c> { component1, component2 };
            insert components;
        
        //create 2 modifications
        IS_System_Modification__c mod1 = new IS_System_Modification__c(Change_Request__c = cr.Id,
                                                                       IS_System_Component__c = component1.Id,
                                                                       Type_Of_Modification__c = 'Modify',
                                                                       SOX_Object__c = FALSE);
        insert mod1;
        /*IS_System_Modification__c mod2 = new IS_System_Modification__c(Change_Request__c = cr.Id,
                                                                       IS_System_Component__c = component2.Id,
                                                                       Type_Of_Modification__c = 'Modify',
                                                                       SOX_Object__c = FALSE);
        list<IS_System_Modification__c> mods = new list<IS_System_Modification__c> { mod1, mod2 };
            insert mods;*/
        
        //create 3 IS Environments (2 active, 1 inactive)
        list<IS_Environment__c> envs = new list<IS_Environment__c>();
        IS_Environment__c dev1 = new IS_Environment__c(name = 'Dev1',
                                                       Common_Name__c = 'Dev1',
                                                       RecordTypeId = Schema.SObjectType.IS_Environment__c.getRecordTypeInfosByName().get('Sandbox Series').getRecordTypeId(),
                                                       Status__c = 'Active');
        envs.add(dev1);
        IS_Environment__c dev6 = new IS_Environment__c(name = 'Dev6',
                                                       Common_Name__c = 'Dev6',
                                                       RecordTypeId = Schema.SObjectType.IS_Environment__c.getRecordTypeInfosByName().get('Sandbox Series').getRecordTypeId(),
                                                       Status__c = 'Active');
        envs.add(dev6);
        IS_Environment__c dev8_inactive = new IS_Environment__c(name = 'Dev8',
                                                       RecordTypeId = Schema.SObjectType.IS_Environment__c.getRecordTypeInfosByName().get('Sandbox Series').getRecordTypeId(),
                                                       Status__c = 'Inactive');
        envs.add(dev8_inactive);
        insert envs;
        
        list<IS_Environment__c> sandboxes = new list<IS_Environment__c>();
        IS_Environment__c sb_dev1 = new IS_Environment__c(name = 'Dev1',
                                                       RecordTypeId = Schema.SObjectType.IS_Environment__c.getRecordTypeInfosByName().get('Salesforce Sandbox').getRecordTypeId(),
                                                       Sandbox_Series__c = dev1.Id,
                                                       Status__c = 'Active');
        sandboxes.add(sb_dev1);
        IS_Environment__c sb_dev6 = new IS_Environment__c(name = 'Dev6',
                                                       RecordTypeId = Schema.SObjectType.IS_Environment__c.getRecordTypeInfosByName().get('Salesforce Sandbox').getRecordTypeId(),
                                                       Sandbox_Series__c = dev6.Id,
                                                       Status__c = 'Active');
        sandboxes.add(sb_dev6);
        insert sandboxes;
    }
    
    /**
     * 
     * @description: test the insertComponent() method
     * 
     **/
    static testMethod void testAddMods() {
        //get the change request created in setup
        SFDC_Change_Request__c cr = [SELECT Id FROM SFDC_Change_Request__c WHERE Title__c = 'Demo Change Request' LIMIT 1];
        //get the 2 IS Components created in test setup
        list<IS_System_Component__c> systemComponents = [SELECT Id, Salesforce_Object_Id__c FROM IS_System_Component__c WHERE (Object_API_Name__c = 'Account' OR Object_API_Name__c = 'Contact') ORDER BY Object_API_Name__c ASC];
        //get the is system mod created in test setup
        IS_System_Modification__c mod1 = [SELECT Id FROM IS_System_Modification__c WHERE Change_Request__c = :cr.Id];
        // set the page reference
        PageReference pageRef = Page.AddMods;
        test.setCurrentPage(pageRef);
        //set the change request id
        ApexPages.currentPage().getParameters().put('Id', cr.Id);
        //instantiate the controller
        AddModsController controller = new AddModsController();
        //verify the controller variables are populated correctly
        system.assertEquals(cr.Id, controller.changeRequest.Id, 'The changeRequest should have been populated with the CR related to the Id supplied in the page params.');
        system.assertEquals(2, controller.sandboxOptions.size()); //only the active IS Environments should display in the list, so we should only have 2 (dev1 & dev6)
        
        /** END OF TEST SETUP **/
        test.startTest();
        //create 2 mods
        list<ComponentWrapper.Component> components = new list<ComponentWrapper.Component>();
        ComponentWrapper.Component component1 = new ComponentWrapper.Component();
        component1.modId = mod1.Id;//setting the mod id for this record to simulate a user updating an existing record
        component1.sfId = systemComponents[0].Salesforce_Object_Id__c;
        component1.recordTypeName = 'Simple';
        component1.description = 'updated Account modification description!';
        component1.lastModifiedDateTime = '2011-03-24T17:02:48';
        component1.modType = 'Modify';
        component1.modOwnerId = userInfo.getUserId();
        components.add(component1);
        ComponentWrapper.Component component2 = new ComponentWrapper.Component();
        component2.sfId = systemComponents[1].Salesforce_Object_Id__c;
        component2.recordTypeName = 'Simple';
        component2.description = 'test account mod description.';
        component2.modType = 'Modify';
        component2.modOwnerId = userInfo.getUserId();
        components.add(component2);
        string results = addModsController.insertComponent(components, cr.Id);
        test.stopTest();
        
        system.assertEquals('Success', results);
        
        //get the component and verify the last modified date time was parsed correctly
        list<IS_System_Component__c> c = [SELECT Id, Object_Last_Modified__c FROM IS_System_Component__c WHERE Object_Last_Modified__c != null];
        system.assertEquals(1, c.size());
        
        //get all mods related to this CR
        list<IS_System_Modification__c> mods = [SELECT Id, Description__c, IS_System_Component__c FROM IS_System_Modification__c WHERE Change_Request__c = :cr.Id];
        system.assertEquals(2, mods.size());
        system.debug('@@@:' + JSON.serializePretty(mods));
        for (IS_System_Modification__c m : mods) {
            if (m.Id == mod1.Id) {
                system.assertEquals('updated Account modification description!', m.Description__c);
            }
        }
        
    }
    
    /**
     * 
     * @description: test the existingMods_JSON() method
     * 
     **/
    static testMethod void existingMods_JSON() {
        //get the change request created in setup
        SFDC_Change_Request__c cr = [SELECT Id FROM SFDC_Change_Request__c WHERE Title__c = 'Demo Change Request' LIMIT 1];
        //get the 2 IS Components created in test setup
        list<IS_System_Component__c> systemComponents = [SELECT Id, Object_Label__c, Salesforce_Object_Id__c FROM IS_System_Component__c WHERE (Object_API_Name__c = 'Account' OR Object_API_Name__c = 'Contact') ORDER BY Object_API_Name__c ASC];
        //get the is system mod created in test setup
        IS_System_Modification__c mod1 = [SELECT Id FROM IS_System_Modification__c WHERE Change_Request__c = :cr.Id];
        // set the page reference
        PageReference pageRef = Page.AddMods;
        test.setCurrentPage(pageRef);
        //set the change request id
        ApexPages.currentPage().getParameters().put('Id', cr.Id);
        //instantiate the controller
        AddModsController controller = new AddModsController();
        
        //verify that the account modification was returned when calling existingMods_JSON()
        system.assert(controller.existingMods_JSON.containsIgnoreCase('01I4B0000000007AAA'));
    }
}