@isTest
public class Test_RelationshipInteractionExtension {
    
    /**
     * 
     * @description: create a relationship interaction record
     * 
    **/
    public static Relationship_Interaction__c createRelationshipInteraction(Id accId, Id conId) {
        if (accId == null) accId = testUtilities.CreateNewAccount(true).Id;                         //create account
        if (conId == null) conId = testUtilities.CreateNewContact(new Account(Id=accId), true).Id;  //create contact
        Relationship_Interaction__c interaction = new Relationship_Interaction__c(Name = 'temp',
                                                                                  Institution__c = accId,
                                                                                  Primary_Contact__c = conId,
                                                                                  Start_Date_Time__c = datetime.now(),
                                                                                  End_Date_Time__c = datetime.now().addDays(1),
                                                                                  Interaction_Level__c = 'In-person',
                                                                                  Interaction_Type__c = 'OAB',
                                                                                  Comments__c = 'test comments',
                                                                                  Assigned_To__c = userinfo.getUserId());
        insert interaction;
        
        //create primary attendee
        createInteractionAttendee(interaction.Id, conId, true, true);
        
        return interaction;
    }
    
    public static MemberInteractionContactMtM__c createInteractionAttendee(Id relationshipId, Id conId, boolean isPrimary, boolean createAndInsert) {
        if (conId == null) {
            Account acc = testUtilities.CreateNewAccount(true);     //create account
            conId = testUtilities.CreateNewContact(acc, true).Id;   //create contact
        }
        //create attendee
        MemberInteractionContactMtM__c attendee = new MemberInteractionContactMtM__c(Contact__c = conId,
                                                                                     Primary_Contact__c = isPrimary,
                                                                                     Relationship_Interaction__c = relationshipId);
        if (createAndInsert) insert attendee;
        
        return attendee;
    }
    
    /**
     * 
     * @description: setup the unit test
     * 
     **/
    @testSetup
    static void setupTestData() {
        //setup dynamic picklist custom settings
        Test_DynamicPicklist.createInteractionPicklist();
        
        //create relationship interaction
        Relationship_Interaction__c interaction = createRelationshipInteraction(null, null);
        //Create List of Acount
        List<Account> acc = new List<Account>();
        acc.add(new Account(Name = 'testAcc1'));
        
        //Create List Of contact
        List<Contact> cont = new List<Contact>();
        cont.add(new Contact(Lastname = 'test1'));
        cont.add(new Contact(Lastname = 'test2'));        
          
        insert cont;
        //get the primary contact created in the testSetup method
        //Contact con = [SELECT Id, AccountId FROM Contact LIMIT 1];
        
        //create a few secondary attendees
        list<MemberInteractionContactMtM__c> secondaryAttendees = new list<MemberInteractionContactMtM__c>();
        for (integer i = 0; i < 2; i++) secondaryAttendees.add(createInteractionAttendee(interaction.Id, cont[i].Id, false, false));
        insert secondaryAttendees;
        
        //create other outcome
        Outcome__c outcome = new Outcome__c(Relationship_Interaction__c = interaction.Id,
                                            RecordTypeId = OutcomeExtension.RECORD_TYPE_ID_OUTCOME_OTHER,
                                            Outcome_Type__c = 'test',
                                            Description__c = 'test');
        insert outcome;
    }
    
    /**
     * 
     * @description: create a new relationship interaction via the VF page and add a primary contact
     * 
     **/
    static testmethod void createNewRelationshipInteraction() {
        //create account and contact
        Id accId = testUtilities.CreateNewAccount(true).Id;                         //create account
        Contact con = testUtilities.CreateNewContact(new Account(Id=accId), true);  //create contact
        Id conId = con.Id;
        
        //create a sample relationship interaction
        Relationship_Interaction__c interaction = new Relationship_Interaction__c();
        
        // set the page reference
        PageReference pageRef = Page.Interaction_Basic_Edit;
        test.setCurrentPage(pageRef);
        
        // instantiate the controller and set the page
        ApexPages.standardController standardController = new ApexPages.standardController(interaction);
        RelationshipInteractionExtension controller = new RelationshipInteractionExtension(standardController);
        
        //verify the name is set to auto populate
        system.assertEquals(MassCreateBundleOppConstants.WILL_AUTO_POPULATE, interaction.Name);
        
        //set some field values
        controller.interaction.Institution__c = accId;
        controller.interaction.Assigned_To__c = userinfo.getUserId();
        controller.interaction.Start_Date_Time__c = datetime.now();
        controller.interaction.End_Date_Time__c = datetime.now().addDays(1);
        controller.interaction.Interaction_Level__c = 'In-person';
        controller.interaction.Interaction_Type__c = 'NASA Visit';
        
        //ensure the dummy interaction accounts get set to the same value as the interaction
        controller.setAcct();
        
        //set the interaction attendee contact
        controller.contactId = conId;
        controller.interactionAttendees[0].dummyInteraction.Primary_Contact__c = conId;
        controller.getAttendeeDetails();
        
        //verify the attendee wrapper details were set properly
        system.assertEquals(con.Title, controller.interactionAttendees[0].Title);
        system.assertEquals(con.Email, controller.interactionAttendees[0].Email);
        system.assertEquals(con.Phone, controller.interactionAttendees[0].Phone);
        
        //add and remove an attendee
        controller.addInteractionAttendee();
        system.assertEquals(3, controller.interactionAttendees.size());
        
        //remove the newly added attendee
        controller.indexVal = controller.interactionAttendees.size()-1;
        controller.removeAttendee();
        system.assertEquals(2, controller.interactionAttendees.size());
        
        test.startTest();
        
        //perform the save
        controller.save(); 
        
        test.stopTest();
        
        //get the related attendees
        list<MemberInteractionContactMtM__c> attendees = [SELECT Id, Contact__c, Primary_Contact__c FROM MemberInteractionContactMtM__c WHERE Relationship_Interaction__c = :controller.interaction.Id];
        system.assertEquals(1, attendees.size());
        
        system.assertNotEquals(null, controller.interactionTypes, 'The dynamic picklist should be populated with a list of values.');
        system.assert(controller.interactionTypes.size() > 0);
    }
    
    /**
     * 
     * @description: create a new relationship interaction via the VF page.  
     *                  1) Do not populate all the required fields and verify an error is returned.
     *                  2) Do not select a Primary Contact and verify an error is returned.
     * 
     **/
    static testmethod void createNewRelationshipInteraction_error() {
        //create account and contact
        Id accId = testUtilities.CreateNewAccount(true).Id;                         //create account
        Contact con = testUtilities.CreateNewContact(new Account(Id=accId), true);  //create contact
        Id conId = con.Id;
        
        //create a sample relationship interaction
        Relationship_Interaction__c interaction = new Relationship_Interaction__c();
        
        // set the page reference
        PageReference pageRef = Page.Interaction_Basic_Edit;
        test.setCurrentPage(pageRef);
        
        // instantiate the controller and set the page
        ApexPages.standardController standardController = new ApexPages.standardController(interaction);
        RelationshipInteractionExtension controller = new RelationshipInteractionExtension(standardController);
        
        //verify the name is set to auto populate
        system.assertEquals(MassCreateBundleOppConstants.WILL_AUTO_POPULATE, interaction.Name);
        
        //set some field values
        controller.interaction.Institution__c = accId;
        controller.interaction.Assigned_To__c = userinfo.getUserId();
        controller.interaction.Start_Date_Time__c = datetime.now();
        controller.interaction.End_Date_Time__c = datetime.now().addDays(1);
        controller.interaction.Interaction_Level__c = 'In-person';
        controller.interaction.Interaction_Type__c = 'NASA Visit';
        
        //ensure the dummy interaction accounts get set to the same value as the interaction
        controller.setAcct();
        
        //set the interaction attendee contact
        controller.contactId = conId;
        controller.interactionAttendees[0].dummyInteraction.Primary_Contact__c = conId;
        controller.getAttendeeDetails();
        
        //verify the attendee wrapper details were set properly
        system.assertEquals(con.Title, controller.interactionAttendees[0].Title);
        system.assertEquals(con.Email, controller.interactionAttendees[0].Email);
        system.assertEquals(con.Phone, controller.interactionAttendees[0].Phone);
        
        //add and remove an attendee
        controller.addInteractionAttendee();
        system.assertEquals(3, controller.interactionAttendees.size());
        
        //remove the newly added attendee
        controller.indexVal = controller.interactionAttendees.size()-1;
        controller.removeAttendee();
        system.assertEquals(2, controller.interactionAttendees.size());
        
        //remove the start date
        controller.interaction.Start_Date_Time__c = null;
        
        test.startTest();
        
        //perform the save
        controller.save(); 
        
        test.stopTest();
        
        //verify an error occurred
        List<Apexpages.Message> msgs = ApexPages.getMessages();
        system.assertEquals(1, msgs.size(), 'Start date was null - this should have caused an error on save.');
    }
    
    /**
     * 
     * @description: test adding an outcome of type 'Relationship Interaction'.  Verify fields default based on the original interaction.
     * 
    **/
    static testMethod void testPreviousInteraction() {
        //get the primary contact created in the testSetup method
        Contact con = [SELECT Id, AccountId FROM Contact LIMIT 1];
        
        //get the sample relationship interaction
        Relationship_Interaction__c interaction = [SELECT Id, Institution__c, OwnerId FROM Relationship_Interaction__c LIMIT 1];
        
        // set the page reference
        PageReference pageRef = Page.Interaction_Basic_Edit;
        pageRef.getParameters().put('previousInteraction', interaction.Id);
        test.setCurrentPage(pageRef);
        
        // instantiate the controller and set the page
        ApexPages.standardController standardController = new ApexPages.standardController(interaction);
        RelationshipInteractionExtension controller = new RelationshipInteractionExtension(standardController);
        
        //verify the previous interaction was loaded
        system.assertNotEquals(null, controller.prevInteractionId);
        system.assertEquals(con.AccountId, controller.interaction.Institution__c);
    }
    
    /**
     * 
     * @description: Verify the custom related lists on the relationship interaction view VF page contains the correct values.
     * 
    **/
    static testMethod void testInteractionView_RelatedLists() {
        //get the sample relationship interaction
        Relationship_Interaction__c interaction = [SELECT Id, Institution__c, OwnerId FROM Relationship_Interaction__c LIMIT 1];
        
        // set the page reference
        PageReference pageRef = Page.Interaction_Basic_View;
        test.setCurrentPage(pageRef);
        
        // instantiate the controller and set the page
        ApexPages.standardController standardController = new ApexPages.standardController(interaction);
        RelationshipInteractionExtension controller = new RelationshipInteractionExtension(standardController);
        
        //verify the previous interaction was loaded
        system.assertEquals(1, controller.otherOutcomes.size());
        system.assertEquals(3, controller.attendees.size());
    }
}