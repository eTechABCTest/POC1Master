/**
 *  Purpose         :   Apex class to hold the Goal Template Clone logic. This is used on the list view clone and detail page clone button.
 *                      SDD Description
 *
 *                      Clones the entire Goal Template schema, with the following clarifications:
 *                      •   Accepts a parameter to allow for the cloning of selected items from a list view (based on native checkboxes).
 *                          If called via the override of the Clone button on a detail page, assumes that single Goal Template.
 *                      •   Clone all fields as-is with the exception of Description, which is prefixed with “Clone of: “
 *                      •   Clone the following object records:
 *                      •   Goal Template Detail
 *                      •   Goal Template Business Title
 *                      •   Goal Template Detail Pacing
 *                      •   Condition (for both the Goal Template and the Goal Template Details)
 *                      
 *  
 *  Created By      :   Subhash Garhwal
 * 
 *  Created Date    :   10/23/2015
 * 
 *  Revision Logs   :   V_1.0 - Created - CR-20150729-9114
 * 
 **/
public without sharing class CloneGoalTemplateController {
    
    //Variables
    public Standard_Goal__c goalTemplate {get;set;}
    public List<Standard_Goal__c> goalTemplates {get;set;}
    public String retURL {get;set;}
    
    //This constructor will use for individual clone button (Detail Page clone button)
    //Constructor
    public CloneGoalTemplateController(ApexPages.StandardController controller) {
        
        //Get Record
        goalTemplate = (Standard_Goal__c)controller.getRecord();
        
    }
    
    //This constructor will use for list view clone button
    //Construcotr
    public CloneGoalTemplateController(ApexPages.StandardSetController controller) {
        
        //Get Selected records
        goalTemplates = (List<Standard_Goal__c>) controller.getSelected();
        
        //Get Goal Template key prefix
        retURL = Standard_Goal__c.sObjectType.getDescribe().getKeyPrefix();
    }
    
    /**
     *  @description    :   This method is used to clone the Goal Template (s)
     *
     *  @args           :   
     *
     *  @return         :   Pagereference
     *
     **/
    public Pagereference cloneGoalTemplates() {
        
        //Save point
        Savepoint sp = Database.setSavepoint();
        
        try {
            
            //Set to hold the Goal Template Ids
            Set<Id> setGTIds = new Set<Id>();
            
            //Check for detail page record (Detail Page clone case)
            if(goalTemplate != null && goalTemplate.Id != null)
                setGTIds.add(goalTemplate.Id);
            
            //Check for selected records (list view clone case)
            if(goalTemplates != null && goalTemplates.size() > 0) {
                
                //Loop through the records
                for(Standard_Goal__c gT : goalTemplates)
                    setGTIds.add(gT.Id);    
            }
            
            //Check for set size
            if(setGTIds.size() > 0) {
                
                //Global describe
                Map<String, Schema.SObjectType> globalDescribe = Schema.getGlobalDescribe();
                
                //Query through the Goal Templates
                List<Standard_Goal__c> originalGoalTemplates = (List<Standard_Goal__c>)Database.query(buildSOQL(globalDescribe, 'Standard_Goal__c') + ' Where Id IN : setGTIds');
                
                //Check for list size
                if(originalGoalTemplates.size() > 0) {
                    
                    //Clone the Goal Templates using the stabdard salesforce Deepclone method
                    List<Standard_Goal__c> clonedGoalTemplates = originalGoalTemplates.deepClone(false,true);
                    
                    //Map to hold the exising (original GT's Id as key) and cloned GTs as values
                    //This map will use in the Goal Template children mapping
                    Map<Id, Standard_Goal__c> mapGoalTemplates = new Map<Id, Standard_Goal__c>();
                    
                    //Loop through the Original cloned records
                    for(Integer i = 0; i < originalGoalTemplates.size(); i++) {
                        
                        //Update the Description
                        clonedGoalTemplates[i].Description__c = (ISSPConstants.CLONED_GOAL_TEMPLATE_DESCRIPTION_PREPEND_VALUE + originalGoalTemplates[i].Description__c).left(50);
                        
                        //Populate the map
                        mapGoalTemplates.put(originalGoalTemplates[i].Id, clonedGoalTemplates[i]);
                    }
                    
                    //Insert Cloned records
                    insert mapGoalTemplates.values();
                    
                    //Query through the Goal Template Business title
                    List<Standard_Goal_Sales_Role__c> originalGTBTitles = (List<Standard_Goal_Sales_Role__c>)Database.query(buildSOQL(globalDescribe,
                                                                                'Standard_Goal_Sales_Role__c') + ' Where Standard_Goal__c IN : setGTIds');
                    
                    //Check for GTBT list
                    if(originalGTBTitles.size() > 0) {
                        
                        //Clone the GTBT
                        List<Standard_Goal_Sales_Role__c> clonedGTBTitles = originalGTBTitles.deepClone(false,true);
                        
                        //Loop thriugh the Cloned list
                        for(Standard_Goal_Sales_Role__c gTBT : clonedGTBTitles) {
                            
                            //Check for Goal template Id
                            if(mapGoalTemplates.containsKey(gTBT.Standard_Goal__c))
                                gTBT.Standard_Goal__c = mapGoalTemplates.get(gTBT.Standard_Goal__c).Id;
                        }
                        
                        //Insert GTBT
                        insert clonedGTBTitles;
                    }
                    
                    //Query through the Goal Template Details
                    List<Standard_Goal_Detail__c> originalGoalTempDetails = (List<Standard_Goal_Detail__c>)Database.query(buildSOQL(globalDescribe,
                                                                             'Standard_Goal_Detail__c') + ' Where Standard_Goal__c IN : setGTIds');
                    
                    //Map to hold the Original GTD Id with cloned GTD
                    Map<Id, Standard_Goal_Detail__c> mapGoalTempDetails = new Map<Id, Standard_Goal_Detail__c>();
                    
                    //Set to hold the GTD Ids
                    Set<Id> setGTDIds = new Set<Id>();
                        
                    //Check for GTD size
                    if(originalGoalTempDetails.size() > 0) {
                        
                        //Clone the GTD
                        List<Standard_Goal_Detail__c> clonedGoalTempDetails = originalGoalTempDetails.deepClone(false,true);
                        
                        //Loop through the GTD
                        for(Integer i = 0; i < clonedGoalTempDetails.size(); i++) {
                            
                            //Update the GT
                            if(mapGoalTemplates.containsKey(clonedGoalTempDetails[i].Standard_Goal__c))
                                clonedGoalTempDetails[i].Standard_Goal__c = mapGoalTemplates.get(clonedGoalTempDetails[i].Standard_Goal__c).Id;
                            
                            //Populate the map
                            mapGoalTempDetails.put(originalGoalTempDetails[i].Id, clonedGoalTempDetails[i]);
                        }
                        
                        //Insert GTDs
                        System.debug(':::::'+ mapGoalTempDetails.values());
                        insert mapGoalTempDetails.values();
                        
                        //Loop through the GTD to update the Baseline and Parent (both fields are self lookup)
                        for(Standard_Goal_Detail__c gTD : mapGoalTempDetails.values()) {
                            
                            //Check for parent
                            if(gTD.Parent__c != null && mapGoalTempDetails.containsKey(gTD.Parent__c))
                                gTD.Parent__c = mapGoalTempDetails.get(gTD.Parent__c).Id;
                            
                            //Check for Baseline
                            if(gTD.Baseline__c != null && mapGoalTempDetails.containsKey(gTD.Baseline__c))
                                gTD.Baseline__c = mapGoalTempDetails.get(gTD.Baseline__c).Id;
                        }
                        
                        //Update GTDs
                        update mapGoalTempDetails.values();
                        
                        //Set to hold the GTD Ids
                        setGTDIds = mapGoalTempDetails.keySet();
                              
                        //Query through the GTD Pacings
                        List<Standard_Goal_Detail_Pacing__c> originalGTDPacings = (List<Standard_Goal_Detail_Pacing__c>)Database.query(buildSOQL(
                                                                                                        globalDescribe,'Standard_Goal_Detail_Pacing__c')
                                                                                                        + ' Where Standard_Goal_Detail__c IN : setGTDIds');
                        
                        //Check for list size
                        if(originalGTDPacings.size() > 0) {
                            
                            //Clone the GTD Pacings using SF standard clone method
                            List<Standard_Goal_Detail_Pacing__c> clonedGTDPacings = originalGTDPacings.deepClone(false,true);
                            
                            //Loop through the cloned pacing records and update GT and GTDs on it
                            for(Standard_Goal_Detail_Pacing__c gTDP : clonedGTDPacings) {
                                
                                //Check for Goal Teemplate
                                if(mapGoalTemplates.containsKey(gTDP.Standard_Goal__c))
                                    gTDP.Standard_Goal__c = mapGoalTemplates.get(gTDP.Standard_Goal__c).Id;
                                
                                //Check for Standard Goal Detail
                                if(mapGoalTempDetails.containsKey(gTDP.Standard_Goal_Detail__c))
                                    gTDP.Standard_Goal_Detail__c = mapGoalTempDetails.get(gTDP.Standard_Goal_Detail__c).Id;
                            }
                            
                            //Insert GTD Pacings
                            insert clonedGTDPacings;
                        }
                        
                        //Query through the GTD Measurement Periods
                        List<Goal_Template_Detail_Measurement_Period__c> originalGTDMPeriods = (List<Goal_Template_Detail_Measurement_Period__c>)Database.query(buildSOQL(
                                                                                                        globalDescribe,'Goal_Template_Detail_Measurement_Period__c')
                                                                                                        + ' Where Goal_Template_Detail__c IN : setGTDIds');
                        
                        System.debug('####### : ' +originalGTDMPeriods);
                        
                        //Check for list size
                        if(originalGTDMPeriods.size() > 0) {
                            
                            //Clone the GTDMP using SF standard clone method
                            List<Goal_Template_Detail_Measurement_Period__c> clonedGTDMPeriods = originalGTDMPeriods.deepClone(false,true);
                            
                            //Loop through the cloned GTDMP records and update GTDs on it
                            for(Goal_Template_Detail_Measurement_Period__c gTDMP : clonedGTDMPeriods) {
                                
                                //Check for Goal Template Detail
                                if(mapGoalTempDetails.containsKey(gTDMP.Goal_Template_Detail__c))
                                    gTDMP.Goal_Template_Detail__c = mapGoalTempDetails.get(gTDMP.Goal_Template_Detail__c).Id;
                            }
                            
                            System.debug('####### : ' +clonedGTDMPeriods);
                            //Insert GTDMP
                            insert clonedGTDMPeriods;
                        }
                    }
                    
                    //List of Conditions
                    List<Condition__c> originalConditions = (List<Condition__c>)Database.query(buildSOQL(globalDescribe, 'Condition__c') 
                                                                                            + ' Where Standard_Goal__c IN : setGTIds'
                                                                                            + ' OR Standard_Goal_Detail__c IN : setGTDIds');
                    
                    //Check for conditions
                    if(originalConditions.size() > 0) {
                        
                        //List of Conditions
                        List<Condition__c> clonedConditions = originalConditions.deepClone(false,true);
                        
                        //Loop through the clonedConditions
                        for(Condition__c con : clonedConditions) {
                            
                            //Check for GT
                            if(mapGoalTemplates.containsKey(con.Standard_Goal__c))
                                con.Standard_Goal__c = mapGoalTemplates.get(con.Standard_Goal__c).Id;
                            
                            //Check for GTD
                            if(mapGoalTempDetails.containsKey(con.Standard_Goal_Detail__c))
                                con.Standard_Goal_Detail__c = mapGoalTempDetails.get(con.Standard_Goal_Detail__c).Id;
                        }
                        
                        //Insert condtions
                        insert clonedConditions;
                    }
                    
                    //Check for Goal Template
                    if(goalTemplate != null && goalTemplate.Id != null)
                        return new Pagereference('/' + mapGoalTemplates.get(goalTemplate.Id).Id);
                }
            }
            //return
            return new Pagereference('/' + retURL);
            
        } catch(Exception e) {
            
            //Roll Back changes
            Database.rollback(sp);
            
            //Add Error on page
            ApexPages.addMessages(e);
        }
    
    return null;
    }
    
    /**
     *  @description    :   This method is used to build the SOQL query string.
     *
     *  @args           :   Map<String, Schema.SObjectType>, String
     *
     *  @return         :   String
     *
     **/
    public String buildSOQL(Map<String, Schema.SObjectType> globalDescribe, String objName) {
        
        //SOQL query
        String SOQL = 'Select ';
        
        //Get the field of the object'
        for(String field : globalDescribe.get(objName).getDescribe().fields.getMap().keySet())
            SOQL += field + ',';
        
        //Remove extra elements and add object
        SOQL = SOQL.removeEnd(',') + ' From ' + objName;
        
        //Return 
        return SOQL;
        
    }
}