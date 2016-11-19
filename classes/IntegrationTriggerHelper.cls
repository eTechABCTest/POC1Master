public class IntegrationTriggerHelper {

    public class LogRecord {
        public String ExternalSystem;
        public String ExternalId;
        public String SFDC_Object;
        public String SFDC_Id;    
        public String RecordTypeId;
        public String Operation;
        public Boolean isSuccess;
        public String FieldsUpdated;
        public String Message;
    }

    //public class BudgetLineRec{
    //  public String Year;
    //  public String Month;
    //  public Decimal Amount;
    //}

    //public class BudgetRec{
    //  public String DeptCode;
    //  public String DeptId;
    //  public String BudgetType;
    //  public String UniqueId;
    //  public String BudgetId;
    //  public String IntegrationId;
    //  public list<BudgetLineRec> BudgetLines;
    //}

    //public class FieldMap1{
    //  public map<string,string> fieldMap;
    //}

    //public class FieldMap1List1{
    //  public map<string,string> fieldMap;
    //  public list<FieldMap1> listFieldMaps;
    //}

    public static void processIntegration(list<Integration__c> newRecords) {

        //map of records to be processed grouped by recordtype
        map<Id,List<Integration__c>> mapRecTypeToRecs = new map<Id,List<Integration__c>>();

        //Get the list of Integration Jobs and RecTypeIds from the Custom Setting
        map<String,Integration_Job__c> mapIntJobs = Integration_Job__c.getAll();

        //start by building the map with the unique recordtypeids
        for(Integration__c iRec : newRecords){
            if(!mapRecTypeToRecs.containsKey(iRec.recordtypeid)) {
                mapRecTypeToRecs.put(iRec.recordtypeid,new list<Integration__c>());
            }
        }    
        system.debug('1 - mapRecTypeToRecs: '+mapRecTypeToRecs);

        //loop through records to be processed and build the map of items
        for(Integration__c i : newRecords) {

            //add the Integration record to the appropriate list by recordtypeid
            mapRecTypeToRecs.get(i.recordtypeid).add(i);

        }
        system.debug('2 - mapRecTypeToRecs: '+mapRecTypeToRecs);

        //Loop back through the map and if there are any records to process, call the appropriate method
        for(Id recType : mapRecTypeToRecs.keySet()) {
            if(mapRecTypeToRecs.get(recType).size() > 0) {
                String jobName = mapIntJobs.get(recType).Integration_Job_Name__c;

                /*
                //Upsert_EmployeeContactUser
                if(jobName == 'Upsert_EmployeeContactUser'){
                map<Id,list<Integration__c>> mapIntUpsertEmp = new map<Id,list<Integration__c>>();
                mapIntUpsertEmp.put(recType,mapRecTypeToRecs.get(recType));
                processUpsertEmployeeContactUser(mapIntUpsertEmp);
                system.debug('3 - mapIntUpsertEmp: '+mapIntUpsertEmp);
                }
                */

                //Budget Data
                if(jobName == 'Budget'){
                    map<Id,Integration__c> mapBudgetIntegrationRecs = new map<Id,Integration__c>();
                    for(Integration__c iBudget : mapRecTypeToRecs.get(recType)){
                        mapBudgetIntegrationRecs.put(iBudget.Id, iBudget);
                    }
                    processBudgetData(mapBudgetIntegrationRecs, recType);
                }
                
                //Job 3
            }
        }
    }

    public static void processBudgetData(map<Id,Integration__c> mapIntgBudget, Id intgRecType){

        //Add method for clearing old Integration record after 6 months?
        //Write Integration Log when this runs
        //Write status to Integration record when this runs

        //set field name variables
        string fieldUniqueId;
        string fieldBudgetType;

        //Added By - Abhinav Sharma - 08/11/2014 - CR-20140502-5332
        //Start FROM Here
        //Create a set named “setBudgetUniqueIds” to hold TextField23__c field’s values of the Integration records.
        Set<String> setBudgetUniqueIds = new Set<String>();
        for(Integration__c it : mapIntgBudget.values()) {
            if(String.isNotBlank(it.TextField23__c))
                setBudgetUniqueIds.add(it.TextField23__c);
        }
        //Upto here
        
        //query to get existing Budget records and build a map of Unique_Id's to Budget records
        String thisYear = string.valueOf(Date.today().year());
        map<Id,Budget__c> mapBudget = new map<Id,Budget__c>();
        map<string, Budget__c> mapUIdToBudget = new map<string, Budget__c>();
        map<string, Id> mapUIdToBudgetId = new map<string, Id>();
        
        //Modify By - Abhinav Sharma - 08/11/2014 - CR-20140502-5332 - Added Unique Id filters in the query
        for(Budget__c budget : [select Id, Name, RecordTypeId, RecordType.Name, Account_Name__c, Account_Number__c, Asset_Category__c, Budget_Item__c, 
                                    Department_Code__c, Department_Name__c, Department__c, Department_ID__c, Fixed_Asset__c, Last_Update_Sync__c, Unique_ID__c 
                                    //Jan__c, Feb__c, Mar__c, Apr__c, May__c, Jun__c, Jul__c, Aug__c, Sep__c, Oct__c, Nov__c, Dec__c, Year__c 
                                    from Budget__c WHERE Unique_Id__c != null AND Unique_Id__c IN : setBudgetUniqueIds]) {
        
            //build map Unique Id to existingBudget record
            mapBudget.put(budget.Id,budget);
            mapUIdToBudget.put(budget.Unique_ID__c,budget); 
            mapUIdToBudgetId.put(budget.Unique_ID__c, budget.Id);
        }

        //Get the RecordTypeIds for the Budget Object
        map<string,Id> mapBudgetRecTypeToId = Util.recordtypemap('Budget__c');
        system.debug('IntegrationTriggerHelper.processBudgetData - mapBudgetRecTypeToId: '+mapBudgetRecTypeToId);

        //get field mappings
        list<Integration_Mapping__c> listMapping = IntegrationTriggerUtil.getMappings(intgRecType);
        system.debug('IntegrationTriggerHelper.processBudgetData - listMapping: '+listMapping);

        //Build a map and reverse lookup for the mapping for Budget__c
        map<String,String> mapBudgetFields = IntegrationTriggerUtil.buildFieldMap(listMapping,'Budget__c');
        //map<string,string> mapBudgetFieldToMapping = IntegrationTriggerUtil.buildReverseLookupFieldMap(listMapping,'Budget__c');
        system.debug('IntegrationTriggerHelper.processBudgetData - mapBudgetFields: '+mapBudgetFields);
        //system.debug('IntegrationTriggerHelper.processBudgetData - mapBudgetFieldToMapping: '+mapBudgetFieldToMapping);

        //Build a map and reverse lookup for the mapping for Budget_Line__c
        map<String,String> mapBudgetLineFields = IntegrationTriggerUtil.buildFieldMap(listMapping,'Budget_Line__c');
        //map<String,String> mapBudgetLineFieldsToMapping = IntegrationTriggerUtil.buildReverseLookupFieldMap(listMapping,'Budget_Line__c');
        system.debug('IntegrationTriggerHelper.processBudgetData - mapBudgetLineFields: '+mapBudgetLineFields);
        //system.debug('IntegrationTriggerHelper.processBudgetData - mapBudgetLineFieldsToMapping: '+mapBudgetLineFieldsToMapping);

        //query to get Department record Ids
        map<string,Id> mapDeptCodeToDeptId = IntegrationTriggerUtil.getDeptCodeToIdMap();
        system.debug('IntegrationTriggerHelper.processBudgetData - mapDeptCodeToDeptId: '+mapDeptCodeToDeptId);

        //Call Utility method to build a list of months in order
        list<string> months = IntegrationTriggerUtil.listMonths();
        system.debug('IntegrationTriggerHelper.processBudgetData - months: '+months);

        //loop through Integration records and put the data in a data structure we can work with
        //map<string,BudgetRec> mapIntBudgetData = new map<string,BudgetRec>();
        map<Id,map<string,string>> mapIntBudgetFields = new map<Id,map<string,string>>();
        map<Id,map<string,string>> mapIntBudgetLineFields = new map<Id,map<string,string>>();
        map<string,set<Id>> mapUIdToIntegrationIds = new map<string,set<Id>>(); 

        for(Integration__c intRec : mapIntgBudget.values()){
            map<string,string> recBudget = new map<string,string>();
            
            //Loop through the list of Budget mapping fields and get the field names and values from this Integration record into a map
            for(string intBudgetField : mapBudgetFields.keySet()){
                
                string sfObjectFieldName = mapBudgetFields.get(intBudgetField);
                string sfObjectFieldValue = string.valueOf(intRec.get(intBudgetField));
                recBudget.put(sfObjectFieldName,sfObjectFieldValue);
            
                if(sfObjectFieldName.toUpperCase() == 'UNIQUE_ID__C'){
                    fieldUniqueId = sfObjectFieldName;
                }
                
                if(sfObjectFieldName.toUpperCase() == 'BUDGETTYPE'){
                    fieldBudgetType = sfObjectFieldName;
                }
            }

            system.debug('IntegrationTriggerHelper.processBudgetData - recBudget: '+recBudget);
            mapIntBudgetFields.put(intRec.Id,recBudget);

            map<string,string> recBudgetLine = new map<string,string>();

            //Loop through the list of BudgetLine mapping fields and get the field names and values from this Integration record into a map
            for(string intBudgetLineField : mapBudgetLineFields.keySet()) {
                string sfObjectFieldName = mapBudgetLineFields.get(intBudgetLineField);
                string sfObjectFieldValue = string.valueOf(intRec.get(intBudgetLineField));
                recBudgetLine.put(sfObjectFieldName,sfObjectFieldValue);
            }

            system.debug('IntegrationTriggerHelper.processBudgetData - recBudgetLine: '+recBudgetLine);
            mapIntBudgetLineFields.put(intRec.Id,recBudgetLine);
        }

        //For new Budget Records
        list<Budget__c> newBudgetRecs = new list<Budget__c>();
        map<Id,Integration__c> updIntRecs = new map<Id,Integration__c>();

        //Loop through Integration Budget records
        for(Integration__c intRec : mapIntgBudget.values()){
            
            Integration__c updIntRec = new Integration__c(); 
            updIntRec.Id = intRec.Id;
            system.debug('IntegrationTriggerHelper.processBudgetData - intRec: '+intRec);
        
            //Get the FieldValueMap for this Integration record
            map<string,string> thisIntBudgetRec = mapIntBudgetFields.get(intRec.Id);
            system.debug('IntegrationTriggerHelper.processBudgetData - thisIntBudgetRec: '+thisIntBudgetRec);
        
            //if unique Id exists in existing Budget rec map...
            if(mapUIdToBudget.containsKey(thisIntBudgetRec.get(fieldUniqueId))){
        
                //Update the status on this record and move to the next record
                updIntRec.Status__c = 'Budget__c record exists - no update';
                updIntRecs.put(updIntRec.Id,updIntRec);
            
            } else{

                //Create a new Budget record
                Budget__c newBudget = new Budget__c();
                
                //set additional fields based on mapping 
                for(string bField : thisIntBudgetRec.keySet()){
                    
                    if(bField == fieldBudgetType){
                    
                        //Set the Record Type for the new record
                        if(mapBudgetRecTypeToId.containsKey(thisIntBudgetRec.get(fieldBudgetType))){
                            
                            newBudget.RecordTypeId = mapBudgetRecTypeToId.get(thisIntBudgetRec.get(fieldBudgetType));
                        }
                    } else {    
                        newBudget.put(bField,thisIntBudgetRec.get(bField));
                    }
                }

                //Lookup and set the Department reference field
                if(newBudget.Department_Code__c != null && newBudget.Department_Code__c != '' && mapDeptCodeToDeptId.containsKey(newBudget.Department_Code__c)){
                    newBudget.Department__c = mapDeptCodeToDeptId.get(newBudget.Department_Code__c);
                }
                system.debug('IntegrationTriggerHelper.processBudgetData - newBudget record: '+newBudget);

                //add to the list to insert
                newBudgetRecs.add(newBudget);

                //Update the status on this Integration record
                updIntRec.Status__c = 'Budget record created - not yet inserted'; 
                updIntRecs.put(updIntRec.Id,updIntRec);

                //Add the current new Budget record value to the map of Unique Id values that are checked
                mapUIdToBudget.put(thisIntBudgetRec.get(fieldUniqueId),newBudget);

                //add the current Integration record to a list so the update can be verified later
                //mapNewBudgetToIntgId.put(newBudgetRecs.size()-1,intRec.Id);
            }

            //Add the UniqueId and Integration relationship to the map
            //if(mapUIdToIntegrationIds.containsKey(thisIntBudgetRec.get(fieldUniqueId))){
            //  mapUIdToIntegrationIds.get(thisIntBudgetRec.get(fieldUniqueId)).add(intRec.Id);
            //}else{
            //  mapUIdToIntegrationIds.put(thisIntBudgetRec.get(fieldUniqueId),new set<Id>(intRec.Id));
            //}
        }

        //insert the Budget records
        Database.SaveResult[] resultsBudget;
        
        try{
            resultsBudget = Database.insert(newBudgetRecs, false);
        }catch(Exception e){
            system.debug(e.getTypeName() + ' - ' + e.getCause() + ': ' + e.getMessage());
        }

        //Update the status of the Insert operation on the Integration record
        //map<Id,Integration__c> mapIntRecBudgetInsert = IntegrationTriggerUtil.updateSaveResults('Budget insert', resultsBudget, newBudgetRecs, mapNewBudgetToIntgId, mapIntgBudget);
        
        //mapIntgBudget = IntegrationTriggerUtil.updateSaveResults('Budget insert', resultsBudget, newBudgetRecs, mapNewBudgetToIntgId, mapIntgBudget);
        //Update the list of Integration records to be updated in Salesforce once done.
        //for(Id idInsert : mapIntRecBudgetInsert.keySet()){
        //if(updIntRecs.containsKey(idInsert)){
        //updIntRecs.put(idInsert,mapIntRecBudgetInsert);
        //}
        //}

        //Re-query to get Budget Records and re-build maps and sets
        mapBudget = new map<Id,Budget__c>();
        mapUIdToBudget = new map<string, Budget__c>();
        mapUIdToBudgetId = new map<string, Id>();

        //Modify By - Abhinav Sharma - 08/11/2014 - CR-20140502-5332 - Added Unique Id filters in the query
        for(Budget__c budget : [select Id, Name, RecordTypeId, RecordType.Name, Account_Name__c, Account_Number__c, Asset_Category__c, Budget_Item__c, 
            Department_Code__c, Department_Name__c, Department__c, Department_ID__c, Fixed_Asset__c, Last_Update_Sync__c, Unique_ID__c 
            //Jan__c, Feb__c, Mar__c, Apr__c, May__c, Jun__c, Jul__c, Aug__c, Sep__c, Oct__c, Nov__c, Dec__c, Year__c 
            from Budget__c WHERE Unique_Id__c != null AND Unique_Id__c IN : setBudgetUniqueIds]) {
            mapBudget.put(budget.Id,budget);
            mapUIdToBudget.put(budget.Unique_ID__c,budget); 
            mapUIdToBudgetId.put(budget.Unique_ID__c, budget.Id);
        }

        //Run a query loop to get existing Budget Lines for the Budget Ids in the set
        map<Id,Budget_Line__c> mapBudgetLine = new map<Id,Budget_Line__c>();
        map<Id,list<Budget_Line__c>> mapBudgetIdToBudgetLines = new map<Id,list<Budget_Line__c>>();
        map<Id,map<string,Budget_Line__c>> mapBudgetIdToYearMnthBudgetLine = new map<Id,map<string,Budget_Line__c>>();
        
        //Modified By - Abhinav Sharma - 08/11/2014 - Added Budget__c != null AND Year__c != null in the Query - CR-20140502-5332
        for(Budget_Line__c bl : [select Id, Year__c, Quarter__c, Month__c, Budget__c, Amount__c from Budget_Line__c where Budget__c != null AND Year__c != null AND Budget__c in :mapBudget.keySet() and  Year__c >= :thisYear]){
            //build map BudgetLineId to BudgetLine record 
            mapBudgetLine.put(bl.Id,bl);

            //build map BudgetId to List of related BudgetLine records
            if(mapBudgetIdToBudgetLines.containsKey(bl.Budget__c)){
                //add to existing list
                mapBudgetIdToBudgetLines.get(bl.Budget__c).add(bl);
            }else{
                //create new list and add
                list<Budget_Line__c> listBL = new list<Budget_Line__c>();
                listBL.add(bl);
                mapBudgetIdToBudgetLines.put(bl.Budget__c,listBL);
            } 

            //build map of BudgetId to map of Year-Mnth to BudgetLine record
            string BLYearMonth = bl.Year__c + '-' + bl.Month__c;
            if(mapBudgetIdToYearMnthBudgetLine.containsKey(bl.Budget__c)){
                //add to the existing map
                mapBudgetIdToYearMnthBudgetLine.get(bl.Budget__c).put(BLYearMonth,bl);
            }else{
                //create new map and add
                map<string,Budget_Line__c> mYMBL = new map<string,Budget_Line__c>();
                mYMBL.put(BLYearMonth,bl);
                mapBudgetIdToYearMnthBudgetLine.put(bl.Budget__c,mYMBL);
            }
        }
        system.debug('IntegrationTriggerHelper.processBudgetData - mapBudgetLine: '+mapBudgetLine);
        system.debug('IntegrationTriggerHelper.processBudgetData - mapBudgetIdToBudgetLines: '+mapBudgetIdToBudgetLines);
        system.debug('IntegrationTriggerHelper.processBudgetData - mapBudgetIdToYearMnthBudgetLine: '+mapBudgetIdToYearMnthBudgetLine);

        //list of Budget Line records to upsert
        list<Budget_Line__c> upsBudgetLines = new list<Budget_Line__c>();
        
        //Added By - Abhinav Sharma - 08/11/2014 - CR-20140502-5332
        //Start From here
        //Map to hold "Month", "Year" and "Unique Id" values as key and Budget line item record as value
        Map<String, Budget_Line__c> bLIMonthYearUniqueIdKeyWithBLI = new Map<String, Budget_Line__c>();
        
        //Map to hold the month name's as key and corresponding Fiscal Quarter as value
        Map<String, String> mapMonthWithFiscalQuarter = IntegrationTriggerUtil.MAP_MONTH_WITH_FISCAL_QUARTER;
        
        //Set to hold Budget Unique Id and Fiscal Quarter combined strngs as value
        Set<String> setBudgetUnqiueIdWithLineItemFiscalQuarters = new Set<String>();
        
        //Loop through integration records for populating collections with appropriate values
        for(Integration__c it : mapIntgBudget.values()) {
        
            //Checking and validating variables and collections for null/blank values
            if(mapUIdToBudgetId != null && mapIntBudgetFields != null && mapIntBudgetFields.get(it.Id) != null && fieldUniqueId != null 
                && mapUIdToBudgetId.containsKey(mapIntBudgetFields.get(it.Id).get(fieldUniqueId))
                && mapUIdToBudgetId.get(mapIntBudgetFields.get(it.Id).get(fieldUniqueId)) != null) {
                
                //Fecthing Budget record Id which is in current context
                Id currentBudgetId = mapUIdToBudgetId.get(mapIntBudgetFields.get(it.Id).get(fieldUniqueId));
                
                //Checking for budget record existance corresponding to the "Budget" record Id value
                if(mapBudget != null && mapBudget.get(currentBudgetId) != null) {
                    
                    //Budget record corresponding to the Id value
                    Budget__c currentBudgetRec = mapBudget.get(currentBudgetId);
                    
                    //Budget record recordtype name
                    String budgetRdType = currentBudgetRec.RecordType.Name;
                    
                    //Checking Budget record for "Unique Id" field value and validating it for null/blank value
                    if(String.isNotBlank(currentBudgetRec.Unique_Id__c)) {
                        
                        //Unique Id field value
                        String unqiueKeyString = currentBudgetRec.Unique_Id__c.trim().toLowerCase();
                        
                        //Checking if Budget Line Items exists for the "Budget" record
                        if(mapBudgetIdToBudgetLines != null && mapBudgetIdToBudgetLines.get(currentBudgetId) != null) {
                            
                            //Loop through "Budget Line" records associated with "Budget" record
                            for(Budget_Line__c bLI : mapBudgetIdToBudgetLines.get(currentBudgetId)) {
                                
                                //Only proceed further with the below written logic if and only if record belongs to "CapEx" record type 
                                if(String.isNotBlank(budgetRdType) && budgetRdType == 'CapEx') {
                                    
                                    //Checking if "Month" and "Year" fields value exist for the budget line itemr records
                                    if(String.isNotBlank(bLI.Month__c) && String.isNotBlank(bLI.Year__c) && String.isNotBlank(bLI.Quarter__c)) {
                                        
                                        //Populating collection with the appropriate combination of values
                                        bLIMonthYearUniqueIdKeyWithBLI.put(unqiueKeyString + '-' + bLI.Month__c.trim().toLowerCase() + '-' + bLI.Year__c.trim().toLowerCase(), bLI);
                                        setBudgetUnqiueIdWithLineItemFiscalQuarters.add(unqiueKeyString + '-' + bLI.Quarter__c);
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
        System.debug('@@@@@@@@@ bLIMonthYearUniqueIdKeyWithBLI earlier ' + bLIMonthYearUniqueIdKeyWithBLI);
        System.debug('@@@@@@@@@ setBudgetUnqiueIdWithLineItemFiscalQuarters earlier ' + setBudgetUnqiueIdWithLineItemFiscalQuarters);        
        
        //Upto Here

        //loop through incoming integration Budget records and create or update Budget Lines
        for(Integration__c i : mapIntgBudget.values()){

            //Get the BudgetFieldValueMap for this Integration record
            map<string,string> thisIntBudgetRec = mapIntBudgetFields.get(i.Id);
            system.debug('IntegrationTriggerHelper.processBudgetData - thisIntBudgetRec: '+thisIntBudgetRec);
            //Get the BudgetLineFieldValueMap for this Integration record
            map<string,string> thisIntBudgetLineRec = mapIntBudgetLineFields.get(i.Id);
            system.debug('IntegrationTriggerHelper.processBudgetData - thisIntBudgetLineRec: '+thisIntBudgetLineRec);

            //if unique Id exists in existing Budget rec map...
            system.debug('IntegrationTriggerHelper.processBudgetData - mapUIdToBudgetId: '+mapUIdToBudgetId);
            system.debug('IntegrationTriggerHelper.processBudgetData - thisIntBudgetRec.get(fieldUniqueId): '+thisIntBudgetRec.get(fieldUniqueId));
    
            if(mapUIdToBudgetId.containsKey(thisIntBudgetRec.get(fieldUniqueId))){
            
                Id currentBudgetId = mapUIdToBudgetId.get(thisIntBudgetRec.get(fieldUniqueId));
                Budget__c currentBudgetRec = mapBudget.get(currentBudgetId);
                system.debug('IntegrationTriggerHelper.processBudgetData - currentBudgetId: '+currentBudgetId);
                system.debug('IntegrationTriggerHelper.processBudgetData - currentBudgetRec: '+currentBudgetRec);

                //Get existing Budget Lines for this Budget Id
                list<Budget_Line__c> currentBudgetLines = mapBudgetIdToBudgetLines.get(currentBudgetId);

                //If the current record represents a CapEx Budget line...
                system.debug('IntegrationTriggerHelper.processBudgetData - currentBudgetRecType: '+currentBudgetRec.RecordTypeId+';'+currentBudgetRec.RecordType.Name);
                //if(mapBudgetRecTypeToId.get(currentBudgetRec.RecordTypeId) == 'CapEx'){
                string cBudgetType = currentBudgetRec.RecordType.Name;
                system.debug('IntegrationTriggerHelper.processBudgetData - cBudgetType: '+cBudgetType);
                
                //Modify By - Abhinav Sharma - 08/11/2014 - CR-20140502-5332
                if(cBudgetType == 'CapEx') {
                                        
                    string recYear = '';
                    
                    if(thisIntBudgetLineRec.containsKey('Year__c')){
                        recYear = thisIntBudgetLineRec.get('Year__c');
                    }
                    
                    string recMonth = '';
                    
                    if(thisIntBudgetLineRec.containsKey('Month__c')){
                        recMonth = thisIntBudgetLineRec.get('Month__c');
                    }
                    
                    Decimal recAmount = 0;
                    
                    if(thisIntBudgetLineRec.containsKey('Amount__c')){
                        recAmount = Decimal.valueOf(thisIntBudgetLineRec.get('Amount__c'));
                    }
                    
                    system.debug('IntegrationTriggerHelper.processBudgetData - recYear, recMonth, recAmount: '+recYear+';'+recMonth+';'+recAmount);

                    //Checking and validation variables for size and null/blank values
                    if(String.isNotBlank(recYear) && String.isNotBlank(recMonth) && recAmount != null && currentBudgetId != null && currentBudgetRec != null) {
                                
                        //Initialize variables
                        Budget_Line__c bli = null;
                               
                        //Unique Id field value
                        String unqiueKeyString = currentBudgetRec.Unique_Id__c.trim().toLowerCase();
                        String keyString = unqiueKeyString + '-' + recMonth.trim().toLowerCase() + '-' + recYear.trim().toLowerCase();
                                
                        //Checking for the key value in the map
                        if(bLIMonthYearUniqueIdKeyWithBLI.containsKey(keyString) && bLIMonthYearUniqueIdKeyWithBLI.get(keyString) != null) {
                            
                            //Populating Budget line instance & then putting this instance into the map corresponding to the constructed key value
                            bli = bLIMonthYearUniqueIdKeyWithBLI.get(keyString);
                            //Checking for difference in between amount value
                            if(recAmount != bli.Amount__c) {
                                bli.Amount__c = recAmount;
                                bLIMonthYearUniqueIdKeyWithBLI.put(keyString, bli);
                            }   
                        } else {
                                    
                            //Checking and validating that only one Budget line Item record will be there for a fiscal quarter    
                            if(mapMonthWithFiscalQuarter != null && mapMonthWithFiscalQuarter.get(recMonth.trim().toLowerCase()) != null) {
                                String fiscalUniqueKey = unqiueKeyString + '-' + mapMonthWithFiscalQuarter.get(recMonth.trim().toLowerCase());
                                if(!setBudgetUnqiueIdWithLineItemFiscalQuarters.contains(fiscalUniqueKey)) {    
                                    //Populating budget instance with field's values and then populating map according to the keystring value
                                    bli = new Budget_Line__c();
                                    bli.Budget__c = currentBudgetId;
                                    bli.Year__c = recYear;
                                    bli.Month__c = recMonth;
                                    bli.Amount__c = recAmount;
                                    bLIMonthYearUniqueIdKeyWithBLI.put(keyString, bli);
                                    setBudgetUnqiueIdWithLineItemFiscalQuarters.add(unqiueKeyString + '-' + mapMonthWithFiscalQuarter.get(recMonth.trim().toLowerCase()));
                                }
                            }
                        }
                    }
                }
                
                //If the current record represents an OpEx Budget line... 
                //if(mapBudgetRecTypeToId.get(currentBudgetRec.RecordTypeId) == 'OpEx'){
                if(cBudgetType == 'OpEx'){
                    string recYear = '';
                    if(thisIntBudgetLineRec.containsKey('Year__c')){
                        recYear = thisIntBudgetLineRec.get('Year__c');
                    }
                    //Loop through the months and get values for each month
                    for(string m : months){
                        string recMonth = m;
                        string fieldAmount = m + '__c';
                        Decimal recAmount = 0;
                        if(thisIntBudgetLineRec.containsKey(fieldAmount)){
                            //recAmount = Decimal.valueOf(thisIntBudgetLineRec.get(fieldAmount));
                            recAmount = IntegrationTriggerUtil.getDecimalValue(thisIntBudgetLineRec.get(fieldAmount));
                        }

                        //If the Budget Line exists, update it; If not, create it
                        Budget_Line__c blOpEx = null;
                        //if(currentBudgetLines != null && currentBudgetLines.size() > 0){
                        blOpEx = findBudgetLine(currentBudgetLines, recYear, recMonth, recAmount, currentBudgetId);
                        //}

                        //If Budget Line is not null, add to list to upsert.  If it is null, there was no update
                        if(blOpEx != null){
                            upsBudgetLines.add(blOpEx);
                        }  
                    }
                }
            }else{  
                //Unique_Id not found in Budget map
            }
        }
        
        System.debug('@@@@@@ bLIMonthYearUniqueIdKeyWithBLI final ' + bLIMonthYearUniqueIdKeyWithBLI);
        
        //If Budget Line is not null, add to list to upsert.  If it is null, there was no update
        if(bLIMonthYearUniqueIdKeyWithBLI.values().size() > 0) {
            upsBudgetLines.addAll(bLIMonthYearUniqueIdKeyWithBLI.values());
        }
        
        System.debug('@@@@@@@ upsBudgetLines ' + upsBudgetLines);

        //insert the Budget Line records
        Database.UpsertResult[] resultsBudgetLine;
        try{
            resultsBudgetLine = Database.upsert(upsBudgetLines, false);
        }catch(Exception e){
            system.debug(e.getTypeName() + ' - ' + e.getCause() + ': ' + e.getMessage());
        }

        /////////////////*************************HERE*****************//////////////////////////
        //Update the status of the Insert operation on the Integration record
        //mapIntgBudget = IntegrationTriggerUtil.updateSaveResults('Budget Line Upsert', resultsBudgetLine, newBudgetRecs, mapNewBudgetToIntgId, mapIntgBudget);

    }    

    public static Budget_Line__c findBudgetLine(list<Budget_Line__c> listBudgetLines, string iYear, string iMonth, decimal iAmount, Id iBudgetId) {
        
        Budget_Line__c bli = null;
        Boolean bFound = false;

        //determine if the year-month combination exists for the current budget
        if(listBudgetLines != null && listBudgetLines.size() > 0){
            for(Budget_Line__c line : listBudgetLines){
                if(line.Year__c == iYear){
                    if(line.Month__c == iMonth){
                        bFound = true;
                        //Budget Line exists - check if update is needed
                        if(line.Amount__c != iAmount){
                            bli = line;
                            bli.Amount__c = iAmount;
                        } //else, it is equal and no update needed, so null will be returned
                    }
                }
            }
        }

        //Check if the Year-Month was found.  If not, add a new Budget Line
        if(bFound == false){
            bli = new Budget_Line__c();
            bli.Budget__c = iBudgetId;
            bli.Year__c = iYear;
            bli.Month__c = iMonth;
            bli.Amount__c = iAmount;
        }

        return bli;
    }
    
    /*
    public static void processUpsertEmployeeContactUser(map<Id,list<Integration__c>> mapUpsertEmp){

        //get the mapping
        string intRecType = null;
        list<Integration__c> listUpsertEmp = new list<Integration__c>();
        for(Id i : mapUpsertEmp.keySet()){
            intRectype = i;

            listUpsertEmp.addAll(mapUpsertEmp.get(i));
        }
        system.debug('intRecType: '+intRectype);
        system.debug('listUpsertEmp: '+listUpsertEmp);

    //get field mappings
    list<Integration_Mapping__c> listMapping = IntegrationTriggerUtil.getMappings(intRecType);

    //Build a map for the mapping for Contacts
    map<String,String> mapContactFields = IntegrationTriggerUtil.buildFieldMap(listMapping,'Contact');

    //Build a map for the mapping for Users
    map<String,String> mapUserFields = IntegrationTriggerUtil.buildFieldMap(listMapping,'User');

    //Lists for record inserts
    list<Contact> updContacts = new list<Contact>();
    //list<User> updUsers = new list<User>();

    //Get the object field maps, so we can refer to the fields dynamically
    Map<String, Schema.SObjectField> fieldsContact = Schema.SObjectType.Contact.fields.getMap();
    Map<String, Schema.SObjectField> fieldsUser = Schema.SObjectType.User.fields.getMap();
    Map<String, Schema.SObjectField> fieldsIntegration = Schema.SObjectType.Integration__c.fields.getMap();

    //Loop through the integration records and create the Contact and User records
    for(Integration__c emp1 : listUpsertEmp){

    //Create the Contact record
    Contact c = new Contact();
    for(String stgField : mapContactFields.keySet()){
    c.put(mapContactFields.get(stgField),emp1.get(stgField));
    }
    system.debug('Contact: '+c);

    updContacts.add(c);
    }

    Database.UpsertResult[] resultsContact;
    //Upsert the Contacts 
    try{
    resultsContact = Database.upsert(updContacts);
    }catch(Exception e){
    system.debug(e.getTypeName() + ' - ' + e.getCause() + ': ' + e.getMessage());
    }   

    set<Id> IntegrationRecs = new set<Id>();
    for(Integration__c ir : listUpsertEmp){
    IntegrationRecs.add(ir.Id);
    }

    set<Id> updatedContactIds = new set<Id>();
    for(Contact ic : updContacts){
        updatedContactIds.add(ic.Id);
    }
    updateUsers(IntegrationRecs, updatedContactIds, mapUserFields);

    *//*
        //Set the values for the Integration Log
    }
    */
    
    /*   
    @future
    public static void updateUsers(set<Id> setUpsertEmp, set<Id> updatedContacts, map<String,String> mapUserFields){
    
        //Loop through the Integration records again and create the User records
        list<Integration__c> listUpsertEmp = [select Boolean01__c, Boolean02__c, Boolean03__c, Boolean04__c, Boolean05__c, Boolean06__c, CreatedById, CreatedDate, CurrencyIsoCode,Date01__c, Date02__c, Date03__c, Date04__c, Date05__c, DateTime01__c, DateTime02__c, DateTime03__c, DateTime04__c, DateTime05__c, IsDeleted,External_ID__c, External_system__c, Fields_Updated__c, Name, LastModifiedById, LastModifiedDate, LongText01__c, LongText02__c, Message__c,Number01__c, Number02__c, Number03__c, Number04__c, Number05__c, Number06__c, Number07__c, Number08__c, Number09__c, Number10__c, Operation__c,OwnerId, ConnectionReceivedId, Id, RecordTypeId, RecordType__c, SFDC_Id__c, SFDC_Object__c, ConnectionSentId, Status__c, SystemModstamp, TextField01__c, TextField02__c, TextField03__c, TextField04__c, TextField05__c, TextField06__c, TextField07__c, TextField08__c, TextField09__c, TextField10__c, TextField11__c, TextField12__c, TextField13__c, TextField14__c, TextField15__c, TextField16__c, TextField17__c, TextField18__c, TextField19__c, TextField20__c, TextField21__c, TextField22__c, TextField23__c, TextField24__c, TextField25__c, TextField26__c, TextField27__c, TextField28__c, TextField29__c, TextField30__c, TextField31__c, TextField32__c, TextField33__c, TextField34__c, TextField35__c, TextField36__c, TextField37__c, TextField38__c, TextField39__c, TextField40__c, TextField41__c, TextField42__c, TextField43__c, TextField44__c, TextField45__c, TextField46__c, TextField47__c, TextField48__c, TextField49__c, TextField50__c, TextField51__c, TextField52__c, TextField53__c, TextField54__c, TextField55__c, TextField56__c, TextField57__c, TextField58__c, TextField59__c, TextField60__c FROM Integration__c where Id in :setUpsertEmp];

        list<User> updUsers = new list<User>();

        list<Id> updContacts = new list<Id>();
        updContacts.addAll(updatedContacts);

        integer i = 0;

        for(Integration__c emp2 : listUpsertEmp){

            //Create the User record
            User u = new User();
            u.Employee_Contact_RecordID__c = updContacts[i];
            system.debug('Emp Contact Id: '+u.Employee_Contact_RecordID__c);
            
            for(String stgField : mapUserFields.keySet()){
                system.debug('stgField: '+stgField);
                u.put(mapUserFields.get(stgField),emp2.get(stgField));
            }
            system.debug('User: '+u);

            i++;
            updUsers.add(u);
        }

        Database.UpsertResult[] resultsUser;

        //Upsert the Users
        try{
            resultsUser = Database.upsert(updUsers);
        }catch(Exception e){
            system.debug(e.getTypeName() + ' - ' + e.getCause() + ': ' + e.getMessage());
        }
    }
    */
    
    /*
    public static void saveToLog(List<LogRecord> lLogs){

        List<Integration_Log__c> logsToInsert = new List<Integration_Log__c>();
        for(LogRecord log:lLogs){
        Integration_Log__c lr = new Integration_Log__c();
        lr.External_System__c = log.ExternalSystem;
        lr.External_Id__c = log.ExternalId;
        lr.SFDC_Object__c = log.SFDC_Object;
        lr.SFDC_Id__c = log.SFDC_Id;
        lr.RecordTypeId = log.RecordTypeId;
        lr.Operation__c = log.Operation;
        lr.isSuccess__c = log.isSuccess;
        lr.Fields_Updated__c = log.FieldsUpdated;
        lr.Message__c = log.Message;
        logsToInsert.add(lr);
        }
        system.debug('JRB....  Records to insert: '+logsToInsert);
        system.debug('JRB....  User='+UserInfo.getUserName()+', UserProfile='+UserInfo.getProfileId());
        insert logsToInsert;
    }  
    */
    
    /*

        //Save the results and update success flag
        try
        {
        Database.SaveResult[] results = Database.update(updatedOpps,false);
        updateSaveResults(results,updatedOpps,mapRecIdToLogList);
        }
        catch(Exception e)
        {
        System.debug(e.getTypeName() + ' - ' + e.getCause() + ': ' + e.getMessage());
        }

    */
}