public class RelationshipInteractionExtension {
	
    //main record
    public Relationship_Interaction__c interaction { get; set; }
    //selected contact id
    public Id contactId { get; set; }
    //previous relationship interaction id
    public Id prevInteractionId { get; set; }
    
    /**
     * 
     * @description: constructor
     * 
     * @params: standard controller for the relationship interaction object
     * 
     **/
    public RelationshipInteractionExtension(ApexPages.StandardController controller) {
        
        //Initialize Relationship Interaction record
        interaction = RelationshipInteractionHelper.setDefaults((Relationship_Interaction__c)controller.getRecord());
        if (interaction.Id == null) interaction.Name = MassCreateBundleOppConstants.WILL_AUTO_POPULATE;
        
        //auto-populate from previous interaction
        getPreviousInteraction();
    }
    
    /**
     * 
     * @description: list of interaction contact mtms that are displayed in the interaction attendees section
     * 
     **/
    public list<RelationshipInteractionHelper.memInteractionContactWrapper> interactionAttendees {
        get {
            if (interactionAttendees == null) {
                interactionAttendees = new list<RelationshipInteractionHelper.memInteractionContactWrapper>();
                
                //get all current attendees
                list<MemberInteractionContactMtM__c> interactionContacts = [SELECT Id, Primary_Contact__c, Contact__c, Contact__r.Email, Contact__r.Phone,
                                                                            Contact__r.Title, Contact__r.Name, Relationship_Interaction__c
                                                                            FROM MemberInteractionContactMtM__c 
                                                                            WHERE Relationship_Interaction__c != null 
                                                                              AND Relationship_Interaction__c = :interaction.Id];
                for (MemberInteractionContactMtM__c iContact : interactionContacts) {
                    interactionAttendees.add(new RelationshipInteractionHelper.memInteractionContactWrapper(iContact));
                }
                
                //if there are no attendees, one here and another blank row below
                if (interactionAttendees.size() == 0) addInteractionAttendee();
                
                addInteractionAttendee(); //add one blank record, which will be disabled until user clicks green plus icon
            }
            return interactionAttendees;
        }
        set;
    }
    
    /**
     * 
     * @description: add interaction attendee to the attendees list
     * 
     **/
    public void addInteractionAttendee() {
        //return immediately if the last row's contact is null
        //if (interactionAttendees != null && interactionAttendees.size() > 0 && interactionAttendees[interactionAttendees.size()-1].contactMtM.Contact__c == null) return;
        
        RelationshipInteractionHelper.memInteractionContactWrapper wrapper = 
            new RelationshipInteractionHelper.memInteractionContactWrapper();
        wrapper.dummyInteraction.Institution__c = interaction.Institution__c;
        wrapper.contactMtM = new MemberInteractionContactMtM__c(Relationship_Interaction__c = interaction.Id);
        interactionAttendees.add(wrapper);
    }
    
    /**
     * 
     * @description: determines if a primary has been selected from the attendee list
     * 
     **/
    private boolean hasPrimary {
        get {
            hasPrimary = false;
            for (RelationshipInteractionHelper.memInteractionContactWrapper attendee : interactionAttendees) {
                if (attendee.contactMtM.Primary_Contact__c) {
                    hasPrimary = true;
                    break;
                }
            }
            return hasPrimary;
        }
        set;
    }
    
    /**
     * 
     * @description: get the attendee contact details
     * 
     **/
    public void getAttendeeDetails() {
        //get the contact
        list<Contact> contacts = [SELECT Id, Title, Email, Phone FROM Contact WHERE Id = :contactId];
        if (contacts.size() > 0) {
            Contact c = contacts[0];
            integer count = 0;
            for (RelationshipInteractionHelper.memInteractionContactWrapper attendee : interactionAttendees) {
                system.debug('@@c.Id:' + c.Id + '  attendee.dummyInteraction.Primary_Contact__c:' + attendee.dummyInteraction.Primary_Contact__c);
                if (c.Id == attendee.dummyInteraction.Primary_Contact__c) {
                    count++;
                    attendee.contactMtM.Contact__c = c.Id; //set the contact id on the membership interaction contact
                    attendee.Title = c.Title;
                    attendee.Email = c.Email;
                    attendee.Phone = c.Phone;
                    if (!hasPrimary || attendee.contactMtM.Primary_Contact__c) {
                        indexVal = count;
                        selectPrimary();
                    }
                }
            }
        }
    }
    
    /**
     * 
     * @description: This function  is called when a radio button is clicked
     * 
     **/
    Public void selectPrimary() {
        //Using the index, set the boolean flag on the wrapper class variable to TRUE, all other rows are set to FALSE
        for(integer i=0; i < interactionAttendees.size(); i++) {
            if(i == indexVal - 1) {
                interactionAttendees[i].contactMtM.Primary_Contact__c = true;
                interaction.Primary_Contact__c = interactionAttendees[i].contactMtM.Contact__c;
                
            }
            else
                interactionAttendees[i].contactMtM.Primary_Contact__c = false;
        }
    }
    
    /**
     * 
     * @description:	save relationship interaction, attendees, and delete any deleted attendees
     * 
     * @return: 		return to the interaction detail page
     * 
     **/
    public pageReference save() {
        //set a save point
        Savepoint sp = Database.setSavepoint();
        
        try {
            if (!hasPrimary) throw new CustomException('A Primary Contact must be selected in the Interaction Attendees list');
            
            if (attendeesToDelete.size() > 0) {
                delete attendeesToDelete;
            }
            
            upsert interaction;
            
            //create the related outcome if the outcome isn't null
            if (outcome != null) insert outcome;
            
            //make sure attendees have the relationship interaction field populated
            for (MemberInteractionContactMtM__c attendee : attendeesToUpsert) {
                if (attendee.Relationship_Interaction__c == null) attendee.Relationship_Interaction__c = interaction.Id;
            }
            upsert attendeesToUpsert;
            
        }
        catch(DMLException ex) {
            Database.rollback(sp); //rollback save
            ApexPages.addMessage( new ApexPages.Message( ApexPages.Severity.ERROR, ex.getDMLMessage(0) ) );
            system.debug('@@DML Exception:' + ex + '  - ' + ex.getStackTraceString());
            return null;
        }
        catch(Exception ex) {
            Database.rollback(sp); //rollback save
            ApexPages.addMessage( new ApexPages.Message( ApexPages.Severity.ERROR, ex.getMessage() ) );
            system.debug('@@Exception:' + ex + '  - ' + ex.getStackTraceString());
            return null;
        }
        
        return new PageReference('/' + interaction.Id);
    }
    
    /**
     * 
     * @description: remove the selected row and add record to deletion list if applicable
     * 
     **/
    public void removeAttendee() {
        MemberInteractionContactMtM__c contactMtM = interactionAttendees.get(indexVal-1).contactMtM;
        if (contactMtM.Primary_Contact__c) interaction.Primary_Contact__c = null;
        //if the interaction has already been inserted, add to deletion list
        if (contactMtM.Id != null) {
            attendeesToDelete.add(contactMtM);
        }
        
        interactionAttendees.remove(indexVal-1);
    }
    
    /**
     * 
     * @description: Get the index (row number) of the selected contact
     * 
     **/
    public integer indexVal {
        get {
            try {
                indexVal = Integer.valueof(System.currentpagereference().getparameters().get('index'));
            }
            catch(exception e) {
                if (indexVal == null) indexVal = 0;
            }
            return indexVal;
        }
        set;
	}
    
    /**
     * 
     * @description: list of attendees to delete once the user clicks save
     * 
     **/
    public list<MemberInteractionContactMtM__c> attendeesToDelete {
        get {
            if (attendeesToDelete == null) {
                attendeesToDelete = new list<MemberInteractionContactMtM__c>();
            }
            return attendeesToDelete;
        }
        set;
    }
    
    /**
     * 
     * @description: 
     * 
     **/
    public list<MemberInteractionContactMtM__c> attendeesToUpsert {
        get {
            attendeesToUpsert = new list<MemberInteractionContactMtM__c>();
            for (RelationshipInteractionHelper.memInteractionContactWrapper interactionWrapper : interactionAttendees) {
                if (interactionWrapper.contactMtM.Contact__c != null) attendeesToUpsert.add(interactionWrapper.contactMtM);
            }
            return attendeesToUpsert;
        }
        set;
    }
    
    /**
     * 
     * @description: 
     * 
     **/
    public void setAcct() {
        system.debug('@@interaction.Institution__c:' + interaction.Institution__c);
        for (RelationshipInteractionHelper.memInteractionContactWrapper attendee : interactionAttendees) {
            attendee.dummyInteraction.Institution__c = interaction.Institution__c;
        }
    }
    
    /**
     * 
     * @description: get the other outcomes which are rendered on the Interaction_Basic_View VF Page
     * 
     **/
    public list<Outcome__c> otherOutcomes {
        get {
            if (otherOutcomes == null) {
                String outcomeQuery = 'Select Id';
                
                //Get fields from field set
                for(Schema.FieldSetMember f : SObjectType.Outcome__c.FieldSets.OutcomeRelatedList.getFields()) {
                    outcomeQuery += ',' + f.getFieldPath();
                }
                
                outcomeQuery += ' from Outcome__c where Relationship_Interaction__c = \'' + interaction.Id + '\' AND RecordType.DeveloperName = \'' + label.Outcome_RT_Dev_Name + '\'';
                otherOutcomes = Database.query(outcomeQuery);
            }
            return otherOutcomes;
        }
        set;
    }
    
    /**
     * 
     * @description: returns a list of interaction attendees displayed in the related list on the view page
     * 
     **/
    public list<MemberInteractionContactMtM__c> attendees {
        get {
            if (attendees == null) {
                String interactionQuery = 'Select Id';
                
                //Get fields from field
                for(Schema.FieldSetMember f : SObjectType.MemberInteractionContactMtM__c.FieldSets.InteractionRelatedList.getFields()) {
                    interactionQuery += ',' + f.getFieldPath();
                }
                
                interactionQuery += ' from MemberInteractionContactMtM__c where Relationship_Interaction__c = \'' + interaction.Id + '\'';
                attendees = Database.query(interactionQuery);
            }
            return attendees;
        }
        set;
    }
    
    /**
     * 
     * @description: sets interaction defaults based on the previous relationship interaction
     * 
     **/
    public void getPreviousInteraction() {
        //get the record id
        prevInteractionId = RelationshipInteractionHelper.getPreviousInteractionId();
        if (prevInteractionId != null) {
            Relationship_Interaction__c previousInteraction = [SELECT Id, RecordTypeId, Source_Interaction__c, Institution__c, Assigned_To__c 
                                   FROM Relationship_Interaction__c 
                                   WHERE id = :prevInteractionId];
            interaction.RecordTypeId = previousInteraction.RecordTypeId;
            interaction.Source_Interaction__c = prevInteractionId;
            interaction.Institution__c = previousInteraction.Institution__c;
            interaction.Assigned_To__c = previousInteraction.Assigned_To__c;
        }
    }
    
    /**
     * 
     * @description: 	if the previous interaction id is populated, this means the record is being created from a new outcome
     * 					so we need to generate the outcome to be inserted upon save.
     * 
     **/
    private boolean createOutcome {
        get {
            return prevInteractionId != null;
        }
        set;
    }
    
    private Outcome__c outcome {
        get {
            if (createOutcome) {
                outcome = new Outcome__c(RecordTypeId = OutcomeExtension.RECORD_TYPE_ID_OUTCOME_RELATIONSHIP_INTERACTION,
                                         Relationship_Interaction__c = prevInteractionId,
                                         Result_Interaction__c = interaction.Id);
            }
            return outcome;
        }
        set;
    }
    
    /**
     * 
     * @description: dynamic picklist pulled from the picklist / picklistUsage / picklistEntity custom settings
     * 
     **/
    public list<SelectOption> interactionTypes {
        get {
            if (interactionTypes == null) {
                DynamicPicklist dp = new DynamicPicklist('Relationship_Interaction__c', 'Interaction_Type__c');
                interactionTypes = dp.getPicklistValues();
            }
            return interactionTypes;
        }
        set;
    }
}