/** 
  * Description     :   Controller class to create new reference perk.
  * 					Referenced on the "Add Eligible Perks" and "Add to Eligible References" buttons
  *
  * Created By      :   Rajeev Jain(Simplyforce)
  *
  * Created Date    :   12/15/2015
  *
  * Version         :   V1.0 Created - Refernece Tracking Project  - CR-20150826-9191
  **/
public without sharing class AddEligiblePerksController {
    
    //Reference Record Id got from URL Parameter
    private String refereneceId {get;set;}
    private String perkTemplateId {get;set;}
    
    //Get Data of Reference Record
    @TestVisible private List<Reference__c> references {get;set;}
    
    //Class Constants
    public final static String NO_ELIGIBLE_PERK_MESSAGE = 'No eligible Reference Perks found for this Reference.';
    public final static String REFERENCE_WAS_NOT_ELIGIBLE_FOR_ANY_REFERENCE_PERKS_INFO_MESSAGE = 'Reference Level must be Ambassador to be eligible for Reference Perks.';
    public final static String ELIGIBLE_REFERENCE_PERK_ALREADY_EXIST = 'Can\'t create new Reference Perk since there is already existing Reference Perk for selected Reference record';
    public final static String PERK_NOT_VALID = 'This perk is not valid.  Please choose a Perk Template with the "Available" status.';
    public final static String NO_ELIGIBLE_REFERENCE = 'No eligible References for this Perk.';
    public final static Id PERK_TEMPLATE_PERFORMANCE_TECHNOLOGY_RT_ID = Schema.SObjectType.Reference_Perk__c.getRecordTypeInfosByName().get(Label.PT).getRecordTypeId();
    
    //Return Url
    private String returnUrl{get;set;}
    
    //Class Constructor
    public AddEligiblePerksController(){
        
        //Get Refernece Id from page Parameter
        refereneceId = ApexPages.currentPage().getParameters().get('referenceId'); 
        perkTemplateId = ApexPages.currentPage().getParameters().get('perkTemplateId'); 
        
        //check for blank
        if(String.isNotBlank(refereneceId)){
            
            referenceInit();
        }else if (String.isNotBlank(perkTemplateId)) {
            system.debug('@@@');
            perkTemplateInit();
        }else{
            
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, REFERENCE_WAS_NOT_ELIGIBLE_FOR_ANY_REFERENCE_PERKS_INFO_MESSAGE + ' Click' + '<a href="/'+ refereneceId +'">here</a>' +'to go to previous page.'));
        }
    }
    
    /**
     * @description: get the reference record based on the referenceId
     **/
    private void referenceInit() {
        references = [select Id, IsActive__c, Reference_Level__c, Reference_Module__c, RecordTypeId, RecordType.DeveloperName 
                      from Reference__c where Id = :refereneceId AND RecordType.DeveloperName = :Label.PT
                      AND IsActive__c = true AND Reference_Level__c = 'Ambassador'];  
        
        returnUrl = '/' + refereneceId;
    }
    
    /**
     * @description: get the reference perk template record based on the perkTemplateId
     **/
    private void perkTemplateInit() {
        //get the perk template
        list<Reference_Perk__c> perks = [SELECT Id, Applicable_Reference_Module__c FROM Reference_Perk__c 
                                         WHERE Id = :perkTemplateId AND (Status__c = 'Available')];
        
        if (perks.size() > 0) {
            
            //select all references eligible for this perk template
            references = [SELECT Id, IsActive__c, Reference_Level__c, Reference_Module__c, RecordTypeId, RecordType.DeveloperName,
                          (SELECT Id FROM Reference_Perks__r WHERE Perk_Template__c = :perkTemplateId)
                          FROM Reference__c 
                          WHERE RecordType.DeveloperName = :Label.PT
                          AND IsActive__c = true
                          AND Reference_Level__c = 'Ambassador'
                          AND Reference_Module__c = :perks[0].Applicable_Reference_Module__c];
        }
        
        returnUrl = '/' + perkTemplateId;
    }
    
    /**
     *  @description    :   This method is used to Create New Eligible reference perk called from Reference perk related list on referece Record.
     *
     *  @args           :   
     *
     *  @return         :   void
     *
     **/
    private void addEligiblePerksForReference() {
        //check for the size
        if(references.size() > 0){
            
            //Create Return URL
            returnUrl = '/' + references[0].Id;
            
            //List New Reference Perk List
            List<Reference_Perk__c> newReferencePerks = new List<Reference_Perk__c>();
            
            //Query on Record Type and Get Id of it
            List<RecordType> recordTypes = [select Id, DeveloperName from RecordType where sObjectType = 'Reference_Perk__c' AND IsActive = true AND DeveloperName = :Label.PT];
            
            //Populate Record Type Id
            String recordTypeId = recordTypes.size() > 0 ? recordTypes[0].id : '';
            
            //Set of Perk Id
            Set<Id> perkIds = new Set<Id>();
            
            //Query on Refernece Perks
            for(Reference_Perk__c perk : [select Id, Applicable_Reference_Module__c, Status__c, RecordTypeId, RecordType.DeveloperName
                                          from Reference_Perk__c where Applicable_Reference_Module__c = :references[0].Reference_Module__c
                                          AND Status__c = 'Available' AND RecordType.DeveloperName = 'Perk_Template']){
                                              perkIds.add(perk.id);
                                              newReferencePerks.add(new Reference_Perk__c(RecordTypeId = recordTypeId, Perk_Template__c = perk.id, Reference__c = references[0].Id));     
                                          }
            
            //Query on Exisitng Refernece Perks
            List<Reference_Perk__c> existingReferencePerks = [select Id from Reference_Perk__c where RecordTypeId = :recordTypeId AND Perk_Template__c IN :perkIds AND Reference__c = :references[0].Id];
            
            if(existingReferencePerks.size() > 0){
                
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ELIGIBLE_REFERENCE_PERK_ALREADY_EXIST + ' Click' + '<a href="'+ returnUrl +'">here</a>' +'to go to previous page.'));
                return;
            }
            //Check the size of the List
            if(newReferencePerks.size() > 0){
                
                insert newReferencePerks;
                
                String referencePerksString = newReferencePerks.size()> 1 ? ' Reference Perks' : ' Reference Perk';
                
                //Add Page message if records successfully get inserted
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM, newReferencePerks.size() + referencePerksString+ ' have been added.  Click' + '<a href="'+ returnUrl +'">here</a>' +'to go to previous page.'));
            }else{
                
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, NO_ELIGIBLE_PERK_MESSAGE + ' Click' + '<a href="'+ returnUrl +'">here</a>' +'to go to previous page.')); 
            }       
        }else{
            
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, REFERENCE_WAS_NOT_ELIGIBLE_FOR_ANY_REFERENCE_PERKS_INFO_MESSAGE + ' Click' + '<a href="/'+ refereneceId +'">here</a>' +'to go to previous page.'));
        }
    }
    
    /**
     *  @description    :   This method is used to Create New Reference Perks on eligible References for the chosen Reference Perk Template
     *
     *  @args           :   
     *
     *  @return         :   void
     *
     **/
    private void addEligiblePerksForTemplate() {
        
        //Create Return URL
        returnUrl = '/' + perkTemplateId;
        
        if (references != null) {
            
            //List New Reference Perk List
            List<Reference_Perk__c> newReferencePerks = new List<Reference_Perk__c>();
            
            //if the reference doesn't already have the perk, add it to the insert list
            for (Reference__c ref : references) {
                if (ref.Reference_Perks__r.size() == 0) {
                    newReferencePerks.add(new Reference_Perk__c(name='will-auto populate',
                                                                RecordTypeId = PERK_TEMPLATE_PERFORMANCE_TECHNOLOGY_RT_ID,
                                                                Perk_Template__c = perkTemplateId,
                                                                Reference__c = ref.Id));
                }
            }
            
            //insert reference perks
            if (newReferencePerks.size() > 0) {
                insert newReferencePerks;
                
                //Add Page message if records successfully get inserted
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM, newReferencePerks.size() + ' Reference Perk(s) have been added.  Click' + '<a href="'+ returnUrl +'">here</a>' +'to go to previous page.'));
            } else {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, NO_ELIGIBLE_REFERENCE + ' Click' + '<a href="'+ returnUrl +'">here</a>' +'to go to previous page.'));
            }
        } else {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, PERK_NOT_VALID + ' Click' + '<a href="/'+ perkTemplateId +'">here</a>' +'to go to previous page.'));
        }
    }
    
    
    /**
     *  @description    :   This method is used to Create New Eligible reference perk called from Reference perk related list on referece Record.
     *
     *  @args           :   
     *
     *  @return         :   void
     *
     **/
     public void addEligiblePerks(){
        
        try{
            if(String.isNotBlank(refereneceId)){
                
                addEligiblePerksForReference();
            }else if (String.isNotBlank(perkTemplateId)) {
                
                addEligiblePerksForTemplate();
            }
        }catch(Exception e){
            
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage() + '<br/>' + e.getStackTraceString() + '<br/> Click' + '<a href="/'+ refereneceId +'">here</a>' +'to go to previous page.'));
        }       
     }
}