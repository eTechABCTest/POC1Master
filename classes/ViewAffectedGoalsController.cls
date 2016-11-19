/**
 *  Purpose         :   ViewAffectedGoals VF page controller class.
 *                      This controller holds the logic to view the affected goal for selected incentive change batch. 
 *  
 *  Created By      :   Rajeev Jain
 * 
 *  Created Date    :   04/25/2016
 * 
 *  Revision Logs   :   V_1.0 - Created - CR-20151120-9402
 * 
 **/
public with sharing class ViewAffectedGoalsController {
    
      //Std controller variable
    public Incentive_Change_Batch__c iCB {get;set;}
    
    //Variable to provide the functionality to change the batch 
    public Affected_Goal__c affectedGoal {get;set;}
    
    //List to display the header for change type
    public List<String> dynamicHeaders {get;set;}
    
     //List to display Incentive Change logs for selected change type in popup
    public List<Incentive_Change_Log__c> incentiveChangeLogs {get;set;}
    
     //Map to hold the ChangeType with Incentive Change log
    public Map<String, List<Incentive_Change_Log__c>> mapChangeTypwWithICLs{get;set;} 
    
    //Set to hold the change Types
    private Set<String> setChangeTypes;
    
    //String to hold the selected change type value
    public String selectedChangeType{get;set;}
    
    //List to display Affected Goals on the page
    public List<AffectedGoalsWrapper> affectedGoals{get;set;} 
    
    //Map to hold the Set of Affected Goal Ids, corrosponding to each Personal Goal Ids
    Map<Id, Set<Id>> mapPgIdsWithAgIds{get;set;}
    
    //List of Change Type which will be displayed on the page
    public List<SelectOption> changeTypes {
        get{
            if(changeTypes == null){
                
                changeTypes = new List<SelectOption>();
                changeTypes.add(new SelectOption(ISSPConstants.INCENTIVE_CHANGE_LOG_CHANGE_TYPE_DEFAULT_SELECT_OPTION_VALUE, ISSPConstants.INCENTIVE_CHANGE_LOG_CHANGE_TYPE_DEFAULT_SELECT_OPTION));
                
                //Check for unique set values 
                if(setChangeTypes.size() > 0){
                    for(String str : setChangeTypes)
                        changeTypes.add(new SelectOption(str,str));        
                }
                    
            }
            return changeTypes;
        }set;
    }
    //Constructor
    public ViewAffectedGoalsController(ApexPages.StandardController controller) {
        
        //Get values
        iCB = (Incentive_Change_Batch__c)controller.getRecord();
        
        //inIt
        inIt();
    }
    
    /**
     *  @description    :   This method is used to load all the initial properties
     *
     *  @args           :   
     *
     *  @return         :   void
     *
     **/
    public void inIt() {
        
        //Initilize properties
        affectedGoal = new Affected_Goal__c();
        selectedChangeType = ISSPConstants.INCENTIVE_CHANGE_LOG_CHANGE_TYPE_DEFAULT_SELECT_OPTION_VALUE;
        
         //Check for incentive change batch
         if(iCB != null)
            affectedGoal.Change_Batch__c = iCB.Id;
        
        //Load affected goals
         loadAffectedGoals();
    }
    
    /**
     *  @description    :   This method is used to load the affectedGoals
     *
     *  @args           :   
     *
     *  @return         :   void
     *
     **/
    public void loadAffectedGoals() { 
        
         //Initilize properties
        affectedGoals = new List<AffectedGoalsWrapper>();
        dynamicHeaders = new List<String>();
        mapChangeTypwWithICLs = new Map<String, List<Incentive_Change_Log__c>>();
        incentiveChangeLogs = new List<Incentive_Change_Log__c>();
        setChangeTypes = new Set<String>();
        mapPgIdsWithAgIds = new Map<Id, Set<Id>>();
        
        //Check for Change Batch
        if(affectedGoal.Change_Batch__c != null) {
            
            //Map to hold the Affected Personal Goal Ids with change type
            Map<Id, String> mapAPGIdWithChangeTypes = new Map<Id, String>();
            
            //Map to hold Id corrosponding to change Type
            Map<Id, Set<String>> mapAPGIdWithChangeTypesSet = new Map<Id, Set<String>>();
            
            //Set to hold the payee (Contact) Ids
            Set<Id> setPayeeIds = new Set<Id>();
            
            //Set to hold the Incentive Change Log Ids
            Set<String> setICLIds = new Set<String>();
            
            //Set to hold Personal Goal Id
            Set<Id> pgIds = new Set<Id>();
            
            //Query through the Affected goal
            for(Affected_Goal__c aG : [Select Id, Personal_Goal__c,Personal_Goal__r.Payee__c, Incentive_Change_Log__c, Incentive_Change_Log__r.Name,
                                              Incentive_Change_Log__r.Change_Type__c, Incentive_Change_Log__r.Change_Element__c, Completed__c, Incentive_Change_Log__r.Change_Record__c
                                                From Affected_Goal__c Where Personal_Goal__c != null
                                              AND Incentive_Change_Batch__c =: affectedGoal.Change_Batch__c
                                                AND Completed__c != true]) {
                //Add Payee Id in set
                if(aG.Personal_Goal__r.Payee__c != null)
                    setPayeeIds.add(aG.Personal_Goal__r.Payee__c);  
                
                pgIds.add(aG.Personal_Goal__c);
                
                //Check change type in set
                if(!setChangeTypes.contains(aG.Incentive_Change_Log__r.Change_Element__c)){
                    setChangeTypes.add(aG.Incentive_Change_Log__r.Change_Element__c);
                    dynamicHeaders.add(aG.Incentive_Change_Log__r.Change_Element__c);
                }
                
                 //Add Change type in set
                if(!mapChangeTypwWithICLs.containsKey(aG.Incentive_Change_Log__r.Change_Element__c) && !setICLIds.contains(aG.Incentive_Change_Log__c))
                    mapChangeTypwWithICLs.put(aG.Incentive_Change_Log__r.Change_Element__c, new List<Incentive_Change_Log__c>());
                
                //Add incentive change log in map
                if(!setICLIds.contains(aG.Incentive_Change_Log__c))
                    mapChangeTypwWithICLs.get(aG.Incentive_Change_Log__r.Change_Element__c).add(aG.Incentive_Change_Log__r);
                
                //Add Incentive Change Log Id in set
                setICLIds.add(aG.Incentive_Change_Log__c);
                                                    
                //Add Personal Goal Id in map
                mapAPGIdWithChangeTypes.put(aG.Personal_Goal__c, aG.Incentive_Change_Log__r.Change_Element__c);
                
                //
                if(!mapAPGIdWithChangeTypesSet.containsKey(aG.Personal_Goal__c)) 
                    mapAPGIdWithChangeTypesSet.put(aG.Personal_Goal__c, new Set<String>());
                
                mapAPGIdWithChangeTypesSet.get(aG.Personal_Goal__c).add(aG.Incentive_Change_Log__r.Change_Element__c);
                                                           
                //Add Affecte goal in set and then add those to corrosponding to each map
                if(!mapPgIdsWithAgIds.containsKey(aG.Personal_Goal__c))
                    mapPgIdsWithAgIds.put(aG.Personal_Goal__c, new Set<Id>());
                
                //Add Ag Id in the Map
                mapPgIdsWithAgIds.get(aG.Personal_Goal__c).add(ag.Id);
            }
            
             //Check for set size
            if(pgIds.size() > 0) {
                
                //SOQL String
                String SOQL = 'Select Id, Name, Amount__c, Count__c, Percent__c, Payee__c, Payee__r.Name From Personal_Goal__c Where Id IN : pgIds';
                
                 //Order By
                SOQL += ' ORDER BY Payee__r.Name,Name ASC';
                
                 for(Personal_Goal__c pG : database.query(SOQL)) {
                    
                    //Instance of wrapper
                    AffectedGoalsWrapper aGW = new AffectedGoalsWrapper();
                    
                    //Set properties
                    aGW.conName = pG.Payee__r.Name;
                    aGW.conId = pG.Payee__r.Id;
                    aGW.personalGoal = pG;
                    aGW.showSelected = mapAPGIdWithChangeTypes.containsKey(pG.Id) ? true : false;
                    aGW.selected = false;
                    aGW.changeTypeStrings = '';
                    //aGW.changeType = mapAPGIdWithChangeTypes.containsKey(pG.Id) ? mapAPGIdWithChangeTypes.get(pG.Id) : '';
                    aGW.changeTypesMap = new Map<String,Integer>();
                    
                    If(mapAPGIdWithChangeTypesSet.containsKey(pG.Id)){
                        System.debug('Check Change Type String ::: ' + mapAPGIdWithChangeTypesSet.get(pG.Id));
                        for(String str: mapAPGIdWithChangeTypesSet.get(pG.Id)){
                            if(mapChangeTypwWithICLs.containsKey(str)){
                                aGW.changeTypeStrings += '_' + str + '_' + '-';
                                aGW.changeTypesMap.put(str, mapChangeTypwWithICLs.get(str).size());
                            }
                        }
                        
                        aGW.changeTypeStrings  = aGW.changeTypeStrings.removeEnd('-');
                    }
                    if(mapChangeTypwWithICLs.containsKey(aGW.changeType))
                        aGW.iclSize = mapChangeTypwWithICLs.get(aGW.changeType).size();
                    
                    //Add Wrapper instance in list
                    affectedGoals.add(aGW);
                }
                
                 //Loop through the personal goals
                /*for(Personal_Goal__c pG : database.query(SOQL)) {
                    
                    If(mapAPGIdWithChangeTypesSet.containsKey(pG.Id)){
                        
                        for(String str: mapAPGIdWithChangeTypesSet.get(pG.Id)){
                            
                            //Instance of wrapper
                            AffectedGoalsWrapper aGW = new AffectedGoalsWrapper();
                            
                            //Set properties
                            aGW.conName = pG.Payee__r.Name;
                            aGW.conId = pG.Payee__r.Id;
                            aGW.personalGoal = pG;
                            aGW.showSelected = mapAPGIdWithChangeTypes.containsKey(pG.Id) ? true : false;
                            aGW.selected = false;
                            aGW.changeType = str;
                            
                            if(mapChangeTypwWithICLs.containsKey(aGW.changeType))
                                aGW.iclSize = mapChangeTypwWithICLs.get(str).size();
                            
                            //Add Wrapper instance in list
                            affectedGoals.add(aGW);
                        }
                    }
                    
                }*/
            }
           
            //Check affectedGoals size
            if(affectedGoals.size() > 0 && selectedChangeType != ISSPConstants.INCENTIVE_CHANGE_LOG_CHANGE_TYPE_DEFAULT_SELECT_OPTION_VALUE){
               
                //Temp list to hold the filtered Goals
                List<AffectedGoalsWrapper> tempList = new List<AffectedGoalsWrapper>();
                
                dynamicHeaders = new List<String>();
                dynamicHeaders.add(selectedChangeType);
                for(AffectedGoalsWrapper ag : affectedGoals){
                    
                    if(ag.changeTypesMap.containsKey(selectedChangeType)){
                        tempList.add(ag);
                    }
                        
                }
                //ReAssign this list to affectedGoals
                affectedGoals = tempList;
            }
        }
    }
    /**
     *  @description    :   Method is used to get the perticular change type's ICLs
     *
     *  @args           :   
     *
     *  @return         :   void
     *
     **/
    public void loadIncentiveChangeLogs() {
        
        //Re-Initilize list
        incentiveChangeLogs = new List<Incentive_Change_Log__c>();
        
        //Variable to get the change type
        String changeType = ApexPages.currentPage().getParameters().get('changeType');
        
        //Check for change type
        if(String.isNotBlank(changeType) && mapChangeTypwWithICLs.containsKey(changeType))
            incentiveChangeLogs.addAll(mapChangeTypwWithICLs.get(changeType));
        
        //Blank parameter
        ApexPages.currentPage().getParameters().put('changeType','');   
                
    }
    
    /**
     *  @description    :   Method is used to save the changes
     *
     *  @args           :   
     *
     *  @return         :   Pagereference
     *
     **/
    public void doSave() {
        
        //Save Point to roll back changes
        Savepoint sp = Database.setSavepoint();
        try {
            
            //Map to hold the Ag instance corrosponding to its Id
            Map<Id, Affected_Goal__c> mapAffectedGoalsForUpdate = new Map<Id, Affected_Goal__c>();
            
            //Loop through the wrapper
            for(AffectedGoalsWrapper aGW : affectedGoals) {
                
                //Check for selected box
                if(aGW.selected && mapPgIdsWithAgIds.containsKey(aGW.personalGoal.Id)){
                    
                    //Loop over each set of Affected goal Id and mark that as completed
                    for(Id agId : mapPgIdsWithAgIds.get(aGW.personalGoal.Id))
                        mapAffectedGoalsForUpdate.put(agId, new Affected_Goal__c(Id = agId, Completed__c = true));    
                }
            }
            
            //Check for list size
            if(mapAffectedGoalsForUpdate.size() > 0){
                update mapAffectedGoalsForUpdate.values();
                loadAffectedGoals();
            }
        }Catch(Exception e){
            
             //Roll Back changes
            Database.rollback(sp);
            
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, e + ''));
        }
    }
    //Wrapper class to hold the affected goals data
    Public class AffectedGoalsWrapper {
        
        //Variable
        public String conName{get;set;}
        public String conId{get;set;}
        public Personal_Goal__c personalGoal{get;set;}
        public Boolean showSelected{get;set;}
        public Boolean selected{get;set;}
        public String changeType{get;set;}
        public Integer iclSize{get;set;}
        public String changeTypeStrings{get;set;}
        public Map<String,Integer> changeTypesMap{get;set;}
        
        //Constructor
        public AffectedGoalsWrapper() {}
    }
}