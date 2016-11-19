@isTest
public class Test_OutcomeExtension {
	
    /**
     * 
     * @description: create the outcome_warmlead__c custom setting
     * 
     **/
    public static void createOutcomeWarmLeadSetting() {
        //create warm lead custom setting
        Outcome_WarmLead__c leadSettings = new Outcome_WarmLead__c(Name = label.OutcomesProductLeadOAB,
                                                                  Lead_Origin__c = 'OAB',
                                                                  Qualification_Status__c = 'Unqualified',
                                                                  Grade__c = 'N/A',
                                                                  Marketing_Associate_Assignment__c = userinfo.getUserId(),
                                                                  Marketer_Assignment__c = userinfo.getUserId(),
                                                                  Status__c = 'Retained by Strategic Marketing',
                                                                  RecordType__c = Schema.SObjectType.Warm_Lead__c.getRecordTypeInfosByName().get('OAB').getRecordTypeId(),
                                                                  Lead_Event__c = 'Interaction_Type__c',
                                                                  Source_Object__c = 'Relationship Interaction',
                                                                  Account__c = 'Institution__c',
                                                                  Contact__c = 'Primary_Contact__c');
        insert leadSettings;
    }
    
    /**
     * 
     * @description: test setup that will be performed once and the data will be accessible to all test methods in this class
     * 
     **/
    @testSetup static void setup() {
        //create picklist custom settings
        Test_DynamicPicklist.createOutcomePicklist();
        //create outcome warm lead setting
        createOutcomeWarmLeadSetting();
    }
    
    /**
     * 
     * @description: Add outcome of the 'Other Outcome' record type.  Verify the user is redirected to the proper edit page.
     * 
     **/
    static testMethod void testRedirect_OtherOutcome() {
        //create relationship interaction
        Relationship_Interaction__c interaction = Test_RelationshipInteractionExtension.createRelationshipInteraction(null, null);
        
        //create a sample outcome
        Outcome__c outcome = new Outcome__c();
        
        // set the page reference and recordType = Other Outcome
        PageReference pageRef = Page.Outcome_Redirect;
        pageRef.getParameters().put('RecordType', OutcomeExtension.RECORD_TYPE_ID_OUTCOME_OTHER);
        test.setCurrentPage(pageRef);
        
        // instantiate the controller and set the page
        ApexPages.standardController standardController = new ApexPages.standardController(outcome);
        OutcomeExtension controller = new OutcomeExtension(standardController);
        
        //verify redirect
        system.assertEquals(true, controller.redirect().getURL().containsIgnoreCase('outcome_edit'));
    }
    
    /**
     * 
     * @description: Add outcome of the 'Relationship Interaction' record type.  Verify the user is redirected to the proper page.
     * 
     **/
    static testMethod void testRedirect_RelationshipInteraction() {
        //create relationship interaction
        Relationship_Interaction__c interaction = Test_RelationshipInteractionExtension.createRelationshipInteraction(null, null);
        
        //create a sample outcome
        Outcome__c outcome = new Outcome__c();
        
        // set the page reference and recordType = Other Outcome
        PageReference pageRef = Page.Outcome_Redirect;
        pageRef.getParameters().put('RecordType', OutcomeExtension.RECORD_TYPE_ID_OUTCOME_RELATIONSHIP_INTERACTION);
        test.setCurrentPage(pageRef);
        
        // instantiate the controller and set the page
        ApexPages.standardController standardController = new ApexPages.standardController(outcome);
        OutcomeExtension controller = new OutcomeExtension(standardController);
        
        //verify redirect
        system.assertEquals(true, controller.redirect().getURL().containsIgnoreCase('Interaction_Basic_Edit'));
    }
    
    /**
     * 
     * @description: 
     * 
     **/
    static testMethod void testRedirect_CreateOtherOutcome() {
        //create relationship interaction
        Relationship_Interaction__c interaction = Test_RelationshipInteractionExtension.createRelationshipInteraction(null, null);
        
        //create a sample outcome
        Outcome__c outcome = new Outcome__c();
        
        // set the page reference and recordType = Other Outcome
        PageReference pageRef = Page.Outcome_Edit;
        pageRef.getParameters().put('RecordType', OutcomeExtension.RECORD_TYPE_ID_OUTCOME_OTHER);
        pageRef.getParameters().put('previousInteraction', interaction.Id);
        test.setCurrentPage(pageRef);
        
        // instantiate the controller and set the page
        ApexPages.standardController standardController = new ApexPages.standardController(outcome);
        OutcomeExtension controller = new OutcomeExtension(standardController);
        
        //verify the outcome types dynamic picklist is populated with values
        system.assertEquals(true, controller.outcomeTypes.size() > 0, 'There should be at least one outcome type in the dynamic picklist.  Verify createOutcomePicklist() is being called in setup.');
        
        //populate required fields
        controller.outcome.Outcome_Type__c = 'Meeting Recruitment';
        controller.save();
        
        //get the outcome record that was generated
        list<Outcome__c> outcomes = [SELECT Id, Outcome_Type__c, Relationship_Interaction__c FROM Outcome__c WHERE Relationship_Interaction__c = :interaction.Id];
        system.assertEquals(1, outcomes.size());
    }
    
    /**
     * 
     * @description: 
     * 
     **/
    static testMethod void testPopulateWarmLeadDefaults() {
        //create a program
        Program__c program = TestUtilities.CreateNewProgram(true);
        
        //create relationship interaction
        Relationship_Interaction__c interaction = Test_RelationshipInteractionExtension.createRelationshipInteraction(null, null);
        
        //create a sample outcome
        Outcome__c outcome = new Outcome__c();
        
        // set the page reference and recordType = Product Lead (OAB)
        PageReference pageRef = Page.Outcome_Edit;
        pageRef.getParameters().put('RecordType', OutcomeExtension.RECORD_TYPE_ID_OUTCOME_PRODUCT_LEAD_OAB);
        pageRef.getParameters().put('previousInteraction', interaction.Id);
        test.setCurrentPage(pageRef);
        
        // instantiate the controller and set the page
        ApexPages.standardController standardController = new ApexPages.standardController(outcome);
        OutcomeExtension controller = new OutcomeExtension(standardController);
        
        //verify that one lead is populated by default
        system.assertEquals(interaction.Primary_Contact__c, controller.warmLeads[0].Contact__c, 'The first lead should be populated with the related interaction\'s primary contact.');
        system.assertEquals(2, controller.warmLeads.size(), 'Two leads should be present by default - one for primary contact from interaction and a blank record.');
        
        //set deafult values on the warm lead record
        controller.warmLeads[0].Contact_level__c = 'CXO';
        controller.warmLeads[0].Primary_Program__c = program.Id;
        
        //save
        controller.save();
        
        //verify no errors occurred
        system.assertEquals(new list<ApexPages.Message>(), apexPages.getMessages());
        
        //get the outcome record that was generated
        list<Outcome__c> outcomes = [SELECT Id, Outcome_Type__c, Relationship_Interaction__c FROM Outcome__c WHERE Relationship_Interaction__c = :interaction.Id];
        system.assertEquals(1, outcomes.size());
        
        //get the warm leads that were generated
        list<Warm_Lead__c> warmLeads = [SELECT Id, Grade__c, Lead_Date__c, Lead_Origin__c, Lead_Channel__c, Contact__c, Outcome_Type__c, Qualification_Status__c 
                                        FROM Warm_Lead__c WHERE Source_Interaction__c = :interaction.Id];
        Outcome_WarmLead__c defaults = Outcome_WarmLead__c.getInstance(label.OutcomesProductLeadOAB);
        system.assertEquals(1, warmLeads.size());
        system.assertEquals(defaults.Grade__c, warmLeads[0].Grade__c);
        system.assertEquals(defaults.Qualification_Status__c, warmLeads[0].Qualification_Status__c);
        system.assertEquals(defaults.Lead_Origin__c, warmLeads[0].Lead_Origin__c);
        system.assertEquals(interaction.Interaction_Type__c, warmLeads[0].Lead_Channel__c);
    }
    
    /**
     * 
     * @description: 
     * 
     **/
    static testMethod void testPopulateWarmLeadDefaults_Error() {
        //create a program
        Program__c program = TestUtilities.CreateNewProgram(true);
        
        //create relationship interaction
        Relationship_Interaction__c interaction = Test_RelationshipInteractionExtension.createRelationshipInteraction(null, null);
        
        //create a sample outcome
        Outcome__c outcome = new Outcome__c();
        
        // set the page reference and recordType = Product Lead (OAB)
        PageReference pageRef = Page.Outcome_Edit;
        pageRef.getParameters().put('RecordType', OutcomeExtension.RECORD_TYPE_ID_OUTCOME_PRODUCT_LEAD_OAB);
        pageRef.getParameters().put('previousInteraction', interaction.Id);
        test.setCurrentPage(pageRef);
        
        // instantiate the controller and set the page
        ApexPages.standardController standardController = new ApexPages.standardController(outcome);
        OutcomeExtension controller = new OutcomeExtension(standardController);
        
        //verify that one lead is populated by default
        system.assertEquals(interaction.Primary_Contact__c, controller.warmLeads[0].Contact__c, 'The first lead should be populated with the related interaction\'s primary contact.');
        system.assertEquals(2, controller.warmLeads.size(), 'Two leads should be present by default - one for primary contact from interaction and a blank record.');
        
        //set deafult values on the warm lead record
        controller.warmLeads[0].Contact_level__c = 'CXO';
        controller.warmLeads[0].Primary_Program__c = program.Id;
        
        //add a new lead
        controller.addLead();
        
        //save (should throw error)
        controller.save();
        
        //verify 1 error occurred
        system.assertEquals(1, apexPages.getMessages().size(), 'One error should have been returned because the lead details are not populated.');
        
        //remove the blank lead
        pageRef.getParameters().put('index', '2');
        system.assertEquals(2, controller.indexVal, 'index value should have been 2.');
        controller.removeLead();
        
        //save (should complete successfully)
        controller.save();
        //system.assertEquals(0, apexPages.getMessages().size());
        //get the warm leads that were generated
        list<Warm_Lead__c> warmLeads = [SELECT Id, Grade__c, Lead_Date__c, Lead_Origin__c, Lead_Channel__c, Contact__c, Outcome_Type__c, Qualification_Status__c 
                                        FROM Warm_Lead__c WHERE Source_Interaction__c = :interaction.Id];
        Outcome_WarmLead__c defaults = Outcome_WarmLead__c.getInstance(label.OutcomesProductLeadOAB);
    }
    
    
}