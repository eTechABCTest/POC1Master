/**
 * 
 * Desription      :   	Controller class for the AddMods VF Page.
 * 
 * Revision Logs   :   	v1.0 - Victor Hanson - 10/30/2015 - Created
 * 
 * 
 **/
public class AddModsController {
	
    //Id of the change request, passed in via params
    public string changeRequestId { get; set; }
    
    /**
     * 
     * @description: returns a map of RecordTypes for the Change Request object.  ie: map<RecordType.Name, RecordType.Id>
     * 
     **/
    public static map<string, string> recordTypeNameToIdMap {
        get {
            if (recordTypeNameToIdMap == null) {
                Id simpleModRTId = Schema.SObjectType.IS_System_Modification__c.getRecordTypeInfosByName().get('Simple').getRecordTypeId();
                Id complexModRTId = Schema.SObjectType.IS_System_Modification__c.getRecordTypeInfosByName().get('Complex').getRecordTypeId();
                
                recordTypeNameToIdMap = new map<string, string>{'Simple' => simpleModRTId, 'Complex' => complexModRTId};
            }
            return recordTypeNameToIdMap;
        }
        set;
    }
    
    /***
     * 
     * @description: creates the IS System Components and SFDC 
     * 
     **/
    @RemoteAction
    public static string insertComponent(List<ComponentWrapper.Component> components, Id changeRequestId){
        list<IS_System_Modification__c> modsToUpsert = new list<IS_System_Modification__c>();
        map<string, IS_System_Component__c> systemComponentsToInsert = new map<string, IS_System_Component__c>();
        
        //create a map of sfId => component
        map<string, ComponentWrapper.Component> sfIdToComonentMap = new map<string, ComponentWrapper.Component>();
        //get a list of all existing components
        for (ComponentWrapper.Component c : components) {
            sfIdToComonentMap.put(c.sfId, c);
        }
        list<IS_System_Component__c> existingComponents = [SELECT Id, Salesforce_Object_Id__c FROM IS_System_Component__c WHERE Salesforce_Object_Id__c IN :sfIdToComonentMap.keySet()];
        
        //map of existing components
        map<string, Id> sfIdToComponentIdMap = new map<string, Id>();
        for (IS_System_Component__c ec : existingComponents) sfIdToComponentIdMap.put(ec.Salesforce_Object_Id__c, ec.Id);
        
        //Get IS System Component key prefix
        String ISSystemComponentPrefix = IS_System_Component__c.sObjectType.getDescribe().getKeyPrefix();
        
        // 1) UPSERT IS COMPONENT BASED ON SFID
        for (ComponentWrapper.Component c : components) {
            IS_System_Component__c aComponent = new IS_System_Component__c();
            if (sfIdToComponentIdMap.containsKey(c.sfId)) {
                aComponent = new IS_System_Component__c(Id = sfIdToComponentIdMap.get(c.sfId));
            }
            aComponent.Name = 'will auto-populate';
            aComponent.Salesforce_Object_Id__c = c.sfId;
            aComponent.Object_Type__c = c.itemType;
            aComponent.Object_Label__c = c.apiName; //see if jeffery can send the label
            aComponent.Object_API_Name__c = c.apiName;
            aComponent.Object_Last_Modified_By__c = c.lastModifiedBy;
            aComponent.Object_Created_By__c = c.createdBy;
            if (c.lastModifiedDateTime != null) aComponent.Object_Last_Modified__c = formatDateTime(c.lastModifiedDateTime);
            if (c.createdDateTime != null) aComponent.Object_Created__c = formatDateTime(c.createdDateTime);
            //Based on the ID Prefix, verify that the parent id is of the type IS System Component
            if (c.parentSFId != null && c.parentSFId.indexOf(ISSystemComponentPrefix) == 0) aComponent.Parent__c = c.parentSFId;
            
            systemComponentsToInsert.put(c.sfId, aComponent);
        }
        
        upsert systemComponentsToInsert.values();
        
        // 2) CREATE THE MODIFICATIONS ON THE CR BASED ON THE SELECTED COMPONENTS
        for (IS_System_Component__c isComponent : systemComponentsToInsert.values()) {
            ComponentWrapper.Component c = sfIdToComonentMap.get(isComponent.Salesforce_Object_Id__c);
            
            modsToUpsert.add(new IS_System_Modification__c(Id = c.modId,
                                                           RecordTypeId = recordTypeNameToIdMap.get(c.recordTypeName),
                                                           IS_System_Component__c = isComponent.Id,
                                                           Change_Request__c = changeRequestId,
                                                           Description__c = c.description,
                                                           Type_of_Modification__c = c.modType,
                                                           Mod_Owner__c = c.modOwnerId));
        }
        
        upsert modsToUpsert;
        
        return 'Success';
    }
    
    /**
     * 
     * @description: convert date/time in to a format that SF can understand.
     * 
     **/
    public static DateTime formatDateTime(string dtString) {
        list<string> dtParts = dtString.split('T');
        DateTime dt;
        if (dtParts.size() == 2) {
            list<string> dateParts = dtParts[0].split('-');
            list<string> timeParts = dtParts[1].split(':');
            
            dt = DateTime.newInstanceGmt(integer.valueOf(dateParts[0]), integer.valueOf(dateParts[1]), integer.valueOf(dateParts[2]), 
                                                  integer.valueOf(timeParts[0]), integer.valueOf(timeParts[1]), integer.valueOf(timeParts[2]));
        }
        return dt;
    }
    
    
    /**
     * @description: constructor
     **/
    public AddModsController() {
        changeRequestId = ApexPages.currentPage().getParameters().get('id');
    }
    
    /**
     * @description: get the related change request
     **/
    public SFDC_Change_Request__c changeRequest {
        get {
            if (changeRequest == null && changeRequestId != null) {
                changeRequest = [SELECT Id, Release__r.Dev_Sandbox__r.Sandbox_Series__r.Common_Name__c FROM SFDC_Change_Request__c WHERE Id = :changeRequestId];
            }
            return changeRequest;
        }
        set;
    }
    
    /**
     * 
     * @description: displays the available sandbox options in the Sandboxes picklist.
     * 
     **/
    public list<string> sandboxOptions {
        get {
            if (sandboxOptions == null) {
                sandboxOptions = new list<string>();
                //query all sandboxes
                AggregateResult[] groupedResults = [SELECT 
                                                    Sandbox_Series__r.Common_Name__c name
                                                    FROM IS_Environment__c 
                                                    WHERE Status__c = 'Active' 
                                                    AND RecordTypeId = :Schema.SObjectType.IS_Environment__c.getRecordTypeInfosByName().get('Salesforce Sandbox').getRecordTypeId()
                                                    GROUP BY 
                                                    Sandbox_Series__r.Common_Name__c
                                                    ORDER BY 
                                                    Sandbox_Series__r.Common_Name__c ASC];
                for (AggregateResult ar : groupedResults)  {
                    sandboxOptions.add((string) ar.get('name'));
                }
            }
            return sandboxOptions;
        }
        set;
    }
    
    /**
     * 
     * @description: returns a JSON string containing all existing Modifications on the related CR.
     * 				 This allows us to Edit existing mods.
     * 
     **/
    public string existingMods_JSON {
        get {
            return getExistingMods_JSON(changeRequestId);
        }
        set;
    }
    
    /**
     * 
     * @description: this remote action gets all existing mods and returns them in the form of a JSON string.
     * 
     **/
    @RemoteAction
    public static string getExistingMods_JSON(string changeRequestId) {
        map<string, IS_System_Modification__c> existingModMap = new map<string, IS_System_Modification__c>();
        for (IS_System_Modification__c mod : [SELECT Id, Description__c, Type_of_Modification__c, IS_System_Component__r.Salesforce_Object_Id__c,
                                              RecordType.Name, Mod_Owner__c
                                              FROM IS_System_Modification__c 
                                              WHERE Change_Request__c = :changeRequestId AND IS_System_Component__r.Salesforce_Object_Id__c != null]) 
        {
            if (mod.Description__c != null) mod.Description__c = mod.Description__c.escapeJava();
            
            existingModMap.put(mod.IS_System_Component__r.Salesforce_Object_Id__c, mod);
        }
        string existingMods_JSON = JSON.serialize(existingModMap);
        return existingMods_JSON;
    }
}