public class OutcomeExtension {
	
    public Outcome__c outcome { get; set; }
     public string fDescription { get; set; }
    public static final Id RECORD_TYPE_ID_OUTCOME_OTHER = Schema.SObjectType.Outcome__c.getRecordTypeInfosByName().get('Other Outcome').getRecordTypeId();
    public static final Id RECORD_TYPE_ID_OUTCOME_PRODUCT_LEAD_OAB = Schema.SObjectType.Outcome__c.getRecordTypeInfosByName().get('Product Lead (OAB)').getRecordTypeId();
    public static final Id RECORD_TYPE_ID_OUTCOME_RELATIONSHIP_INTERACTION = Schema.SObjectType.Outcome__c.getRecordTypeInfosByName().get('Relationship Interaction').getRecordTypeId();
    public static final Id RECORD_TYPE_ID_WARM_LEAD_OAB = Schema.SObjectType.Warm_Lead__c.getRecordTypeInfosByName().get('OAB').getRecordTypeId();
    
    /**
     * 
     * @description: constructor
     * 
     **/
    public OutcomeExtension(ApexPages.StandardController controller) {
        //Initialize Outcome record
        outcome = (Outcome__c)controller.getRecord();
        
        //set the record type and interaction on the outcome
        Id rtId = ApexPages.currentPage().getParameters().get('RecordType');
        if (rtId != null) outcome.RecordTypeId = rtId;
        if (interaction != null && outcome.Relationship_Interaction__c == null) outcome.Relationship_Interaction__c = interaction.Id;
    }
    
    /**
     * 
     * @description: add a new lead to the warmLeads list
     * 
     **/
    public void addLead() {
        warmLeads.add(createWarmLead());
    }
    
    /**
     * 
     * @description: create a new warm lead, default the recordtype, interaction, institution, and add to lead list
     * 
     **/
    public Warm_Lead__c createWarmLead() {
        Warm_Lead__c lead = new Warm_Lead__c(RecordTypeId = RECORD_TYPE_ID_WARM_LEAD_OAB,
                                            Outcome_Type__c = label.OutcomesProductLeadOAB);
        if (interaction != null) {
            lead.Source_Interaction__c = interaction.Id;
            lead.Account__c = interaction.Institution__c;
            lead.Contact__c = interaction.Primary_Contact__c;
        }
        return lead;
    }
    
    /**
     * 
     * @description: list of warm leads related to the outcome
     * 
     **/
    public list<Warm_Lead__c> warmLeads {
        get {
            if (warmLeads == null) {
                warmLeads = new list<Warm_Lead__c>();
                if (interaction != null && interaction.Id != null) {
                    Warm_Lead__c wl = createWarmLead();
                    warmLeads.add(wl);
                }
                warmLeads.add(createWarmLead());
            }
            return warmLeads;
        }
        set;
    }
    
    /**
     * 
     * @description: redirect the user based on their record type selection
     * 
     **/
    public pageReference redirect() {
        pageReference pg;
        if (outcome.RecordTypeId == RECORD_TYPE_ID_OUTCOME_RELATIONSHIP_INTERACTION) {
            pg = Page.Interaction_Basic_Edit;
            pg.getParameters().put('previousInteraction', RelationshipInteractionHelper.getPreviousinteractionId());
        }
        else {
            pg = Page.Outcome_Edit;
            pg.getParameters().put('previousInteraction', RelationshipInteractionHelper.getPreviousinteractionId());
            pg.getParameters().put('RecordType', outcome.RecordTypeId);
            pg.getParameters().put('Id', outcome.Id);
            pg.setRedirect(true);
        }
        pg.getParameters().put('retURL', ApexPages.currentPage().getParameters().get('retURL'));
        return pg;
    }
    
    /**
     * 
     * @description: determines whether or not to display the madd add/edit lead section
     * 
     **/
    public boolean showLeads {
        get {
            return outcome.RecordTypeId == RECORD_TYPE_ID_OUTCOME_PRODUCT_LEAD_OAB;
        }
        set;
    }
    
    /**
     * 
     * @description: relationship interaction related to this outcome
     * 
     **/
    public Relationship_Interaction__c interaction {
        get {
            if (interaction == null && (interactionId != null || outcome.Relationship_Interaction__c != null)) {
                list<Relationship_Interaction__c> interactions = [SELECT Id, Name, Institution__c, Primary_Contact__c, Title__c, Email__c, Phone__c, Assigned_To__c, Status__c, 
                                                                  Start_Date_Time__c, End_Date_Time__c, CreatedById, LastModifiedById, RecordTypeId, OwnerId 
                                                                  FROM Relationship_Interaction__c 
                                                                  WHERE Id = :interactionId OR Id = :outcome.Relationship_Interaction__c];
                if (interactions.size() > 0) interaction = interactions[0];
            }
            return interaction;
        }
        set;
    }
    
    /**
     * 
     * @description: custom save process used to validate warm leads, upsert leads, upsert outcomes, and delete any leads that were deleted
     * 
     **/
    public pageReference save() {
        //set a save point
        Savepoint sp = Database.setSavepoint();
        
        try {
            if (showLeads) {
                //validate warm leads
                validateWarmLeads();
                //insert leads
                upsert leadsToUpsert;
                
                //create an outcome for each lead
                upsert outcomeList;
                
                if (leadsToDelete.size() > 0) {
                    delete leadsToDelete;
                }
            }
            else {
                upsert outcome;
            }
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
     * @description: verify contact, contact level, and primary program are present on all leads being upserted
     * 
     **/
    public void validateWarmLeads() {
        for (Warm_Lead__c lead : leadsToUpsert) {
            //system.debug('@@@validateWarmLeads contact:' + lead.Contact__c);
            if (lead.Contact__c == null || 
                lead.Contact_Level__c == null || 
                lead.Primary_Program__c == null) 
            {
                throw new customException(Label.OutcomesProductLeadRequiredField);
            }
        }
    }
    
    /**
     * 
     * @description: previous interaction id pulled from url parameters.
     * 
     **/
    public Id interactionId {
        get {
            if (interactionId == null) {
                interactionId = RelationshipInteractionHelper.getPreviousinteractionId();
            }
            return interactionId;
        }
        set;
    }
    
    /**
     * 
     * @description: dynamic picklist - pulled from the picklist / picklistUsage / picklistEntity custom settings
     * 
     **/
    public list<SelectOption> outcomeTypes {
        get {
            if (outcomeTypes == null) {
                DynamicPicklist dp = new DynamicPicklist('Outcome__c', 'Outcome_Type__c');
                outcomeTypes = dp.getPicklistValues();
            }
            return outcomeTypes;
        }
        set;
    }
    
    /**
     * 
     * @description: remove the selected row and add record to deletion list if applicable
     * 
     **/
    public void removeLead() {
        Warm_Lead__c lead = warmLeads.get(indexVal-1);
        //if the lead has already been inserted, add to deletion list
        if (lead.Id != null) {
            leadsToDelete.add(lead);
        }
        
        warmLeads.remove(indexVal-1);
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
     * @description: list of leads to delete once the user clicks save
     * 
     **/
    public list<Warm_Lead__c> leadsToDelete {
        get {
            if (leadsToDelete == null) leadsToDelete = new list<Warm_Lead__c>();
            return leadsToDelete;
        }
        set;
    }
    
    /**
     * 
     * @description: list of leads to upsert once the user clicks save
     * 
     **/
    public list<Warm_Lead__c> leadsToUpsert {
        get {
            leadsToUpsert = warmLeads.clone();
            //remove the last warm lead because that will never be inserted - it's there as a placeholder
            leadsToUpsert.remove(leadsToUpsert.size()-1);
            return leadsToUpsert;
        }
        set;
    }
    
    /**
     * 
     * @description: list of outcomes to be linked to the related leads and inserted.
     * 
     **/
    public list<Outcome__c> outcomeList {
        get {
            outcomeList = new list<Outcome__c>();
            for (Warm_Lead__c lead : leadsToUpsert) {
                if (lead.Id != null) {
                    outcomeList.add(new Outcome__c(RecordTypeId=RECORD_TYPE_ID_OUTCOME_PRODUCT_LEAD_OAB,
                                                   Relationship_Interaction__c=interaction.Id,
                                                   Result_Warm_Lead__c=lead.Id));
                }
            }
            return outcomeList;
        }
        set;
    }
    
    /**
     * 
     * @description: warm lead that is used to display the rich text comments field.
     * 
     **/
    public Warm_Lead__c dummyLead {
        get {
            if (dummyLead == null) dummyLead = new Warm_Lead__c();
            return dummyLead;
        }
        set;
    }
    
    /**
     * 
     * @description: set the rich text comments field on the warm lead
     * 
     **/
    public void setRichTextDescription() {
        Warm_Lead__c lead = warmLeads.get(indexVal-1);
        lead.Comments__c = fDescription;
    }
}