public class IntegrationTriggerUtil {

    public static list<Integration_Mapping__c> getMappings(string recTypeId){
        
        //get field mappings
        list<Integration_Mapping__c> listMapping = [select Id, Integration_Name__c, Integration_RecordTypeId__c, SF_Object_Field__c, 
                                                    SF_Object_Name__c, Stg_Field_Name__c from Integration_Mapping__c
                                                    where Integration_RecordtypeId__c = :recTypeId];
        system.debug('listMapping: '+listMapping);
        
        return listMapping;
    }
    
    public static map<String,String> buildFieldMap(list<Integration_Mapping__c> intMap, string sfObject){
        map<String,String> mapFields = new map<String,String>();
        for(Integration_Mapping__c im : intMap){
            if(im.SF_Object_Name__c == sfObject){
                mapFields.put(im.stg_Field_Name__c,im.SF_Object_Field__c);
            }
        }
        system.debug('IntegrationTriggerUtil.buildReverseLookupFieldMap - mapFields: '+mapFields);
        
        return mapFields;
    }
    
    public static map<string,string> buildReverseLookupFieldMap(list<Integration_Mapping__c> intMap, string sfObject){
        map<string,string> mapFields = new map<string,string>();
        for(Integration_Mapping__c im : intMap){
            if(im.SF_Object_Name__c == sfObject){
                mapFields.put(im.SF_Object_Field__c,im.stg_Field_Name__c);
            }
        }
        system.debug('IntegrationTriggerUtil.buildReverseLookupFieldMap - mapFields: '+mapFields);
        
        return mapFields;
    }
    
    public static string getFieldName(map<string,string> mapObjectToMapping, string objectField){
        string returnField = '';
        if(mapObjectToMapping.containsKey(objectField)){
            returnField = mapObjectToMapping.get(objectField);
        }
        return returnField;
    }

    public static map<string,Id> getDeptCodeToIdMap(){
        //query to get Department record Ids
        map<string,Id> mapDeptCodeToDeptId = new map<string,Id>();
        for(Department__c dept : [select Id, Name, Department_Number__c from Department__c]){
            //build map of Dept number to DepartmentId
            mapDeptCodeToDeptId.put(dept.Department_Number__c, dept.Id);
        }
        system.debug('IntegrationTriggerHelper.processBudgetData - mapDeptCodeToDeptId: '+mapDeptCodeToDeptId);
        return mapDeptCodeToDeptId;     
    }

    //Logs the status of the Save/Insert operation on each Integration record
    public static map<Id,Integration__c> updateSaveResults(String OperationName, Database.SaveResult[] results, list<SObject> updatedRecs, map<integer,Id> mapResultRecToIntgId, map<Id,Integration__c> mapIntegration){
        if(results != null){
            //Update the status of the Insert operation on the Integration record
            system.debug('results list: '+results);
            system.debug('updatedRecs: '+updatedRecs);
            system.debug('mapResultRecToIntgId: '+mapResultRecToIntgId);
            system.debug('mapIntegration: '+mapIntegration);
            for(Integer x = 0; x <= results.size()-1; x++){
                system.debug('updatedRecs['+x+']: '+updatedRecs[x]);
                system.debug('results['+x+']: '+results[x]);
                mapIntegration.get(mapResultRecToIntgId.get(x)).isSuccess__c = results[x].isSuccess();
                if(!results[x].isSuccess()){
                    String msg = 'Error occurred when verifying the record saved properly.';
                    mapIntegration.get(mapResultRecToIntgId.get(x)).Message__c = msg + '  ' + results[x].getErrors()[0].getStatusCode()+' - '+results[x].getErrors()[0].getFields()+' - '+results[x].getErrors()[0].getMessage();
                    mapIntegration.get(mapResultRecToIntgId.get(x)).Status__c += ';Failed - '+OperationName;
                }
            }
        }
        return mapIntegration;
    }

    //Logs the status of the Upsert operation on each Integration record
    public static map<Id,Integration__c> updateSaveResults(String OperationName, Database.UpsertResult[] results, list<SObject> updatedRecs, map<integer,Id> mapResultRecToIntgId, map<Id,Integration__c> mapIntegration){
        if(results != null){
            //Update the status of the Insert operation on the Integration record
            system.debug('results list: '+results);
            system.debug('updatedRecs: '+updatedRecs);
            system.debug('mapResultRecToIntgId: '+mapResultRecToIntgId);
            system.debug('mapIntegration: '+mapIntegration);
            for(Integer x = 0; x <= results.size()-1; x++){
                system.debug('updatedRecs['+x+']: '+updatedRecs[x]);
                system.debug('results['+x+']: '+results[x]);
                mapIntegration.get(mapResultRecToIntgId.get(x)).isSuccess__c = results[x].isSuccess();
                if(!results[x].isSuccess()){
                    String msg = 'Error occurred when verifying the record saved properly.';
                    mapIntegration.get(mapResultRecToIntgId.get(x)).Message__c = msg + '  ' + results[x].getErrors()[0].getStatusCode()+' - '+results[x].getErrors()[0].getFields()+' - '+results[x].getErrors()[0].getMessage();
                    mapIntegration.get(mapResultRecToIntgId.get(x)).Status__c += ';Failed - '+OperationName;
                }
            }
        }
        return mapIntegration;
    }   
    
    public static list<String> listMonths()
    {
        list<string> m = new list<string>();
        m.add('Jan');
        m.add('Feb');
        m.add('Mar');
        m.add('Apr');
        m.add('May');
        m.add('Jun');
        m.add('Jul');
        m.add('Aug');
        m.add('Sep');
        m.add('Oct');
        m.add('Nov');
        m.add('Dec');
        
        return m;
    }
    
    public static decimal getDecimalValue(string src)
    {
        decimal num;
        if(src == null){
            num = 0;
        }else{
            num = decimal.valueOf(src);
        }
        return num;
    }
    
    /*
    //Logs the status of the Save/Insert operation on each Integration record
    public static void updateSaveResults(String TargetObject, Database.SaveResult[] results, List<sObject> updatedRecs, map<Id,List<Integration__c>> mapRecToLogs)
    {
        if(results != null)
        {
            system.debug('results list: '+results);
            system.debug('updatedRecs: '+updatedRecs);
            system.debug('mapRecToLogs: '+mapRecToLogs);
            for(Integer x = 0; x <= updatedRecs.size()-1; x++)
            {
                system.debug('updatedRecs['+x+']: '+updatedRecs[x]);
                system.debug('results['+x+']: '+results[x]);
                //system.debug('mapRecToLogIds.get(updatedRecs['+x+'].Id).isSuccess__c: '+mapRecordToLog.get(updatedRecs[x].Id).isSuccess__c);
                for(Integration__c intLog : mapRecToLogs.get(updatedRecs[x].Id))
                {
                    intLog.isSuccess__c = results[x].isSuccess();
                    if(!results[x].isSuccess())
                    {
                        String msg = 'Error occurred when verifying the record saved properly.';
                        intLog.Message__c = msg + '  ' + results[x].getErrors()[0].getStatusCode()+' - '+results[x].getErrors()[0].getFields()+' - '+results[x].getErrors()[0].getMessage();
                        intLog.Status__c += ';Failed - ' + TargetObject;
                    }else{
                        intLog.Status__c += ';Success - ' + TargetObject;
                    }
                        
                }
            }
        }       
    }
    */
    
    //Added By - Abhinav Sharma - 08/11/2014 - CR-20140502-5332
    /**
     *  @description    :  Getter method to construct a map of month value as key and corresponding Fiscal Quarter value.
    **/
    public static Map<String, String> MAP_MONTH_WITH_FISCAL_QUARTER {
    
        get {
        
            //Map to hold the value
            Map<String, String> mapMonthWithQuarterValue = new Map<String, String>();
            mapMonthWithQuarterValue.put('jan', 'Q1');
            mapMonthWithQuarterValue.put('feb', 'Q1');
            mapMonthWithQuarterValue.put('mar', 'Q1');
            mapMonthWithQuarterValue.put('apr', 'Q2');
            mapMonthWithQuarterValue.put('may', 'Q2');
            mapMonthWithQuarterValue.put('jun', 'Q2');
            mapMonthWithQuarterValue.put('jul', 'Q3');
            mapMonthWithQuarterValue.put('aug', 'Q3');
            mapMonthWithQuarterValue.put('sep', 'Q3');
            mapMonthWithQuarterValue.put('oct', 'Q4');
            mapMonthWithQuarterValue.put('nov', 'Q4');
            mapMonthWithQuarterValue.put('dec', 'Q4'); 
            return mapMonthWithQuarterValue;
            
        }
    }
}