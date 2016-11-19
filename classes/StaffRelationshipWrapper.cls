/*
 *  Purpose         :   This class is to control the functionality of adding new Relationship from the create personal goal VF page.
 *                  
 *  Create By       :   Subhash Garhwal
 *  
 *  Created Date    :   09/19/2015
 *  
 *  Revision Log    :   V_1.0 Created - CR-20150729-9114
 *                  :   V_1.1 Modified - Rajeev Jain - 04/29/2016 - CR-20160301-9654 - Changed from and to relationship text confusion, Resolved bug found during development testing
 *                      
 **/
public with sharing class StaffRelationshipWrapper {
    
    //List of wrapper class. This list will hold the Staff Relationship records for currently selected Payee OR Personal Goal
    public List<StaffRelationship> listStaffRelationshipWrapper {get; set;}
    
    //Staff RelationShip Wrapper Blank Instance to Hold Popup Data, this Instance will be used to add new relationship and edit relationship
    public StaffRelationship newEditStaffRelationShip{get;set;}
    
    List<Relationship_Type__c> relationshipType;
    public Integer selectedStaffRelationshipIndex{get;set;}
    
    //Variable for Relationship Type filter
    public Staff_Relationship__c filterStaffRelationship {get; set;}
    
    //Filters
    public Boolean isLimitedToGoalDates {get; set;}
    public Boolean isEffectiveDate {get; set;}
    public Boolean isRelationshipType {get; set;}
    
    //Delete button
    public Boolean disableDelete {get; set;}
    
    /*************  These variables are used to manage the communication b/w main controller (CreatePersonalGoalsFromStdGoalController) and this class  *********/
    
    //Variable to hold the contact Id
    //This will populated with the Payee Id (contact Id) of selected Row
    public String payeeId {get;set;}
    
    //Set to hold the Staff Relationship Ids
    public Set<Id> setSRIds;
    public Set<Id> setRemovedSRIds;
    
    //Variable to control the staff Relationship behavior (To check which button (ICON) has been clicked (Payee or Personal Goal)).
    public String clickedICON {get;set;}
    
    //Set to hold the Staff Relationship Ids for Personal Goal
    public Set<Id> setPGSRIds; 
    
    //Use on all goals button
    public Boolean useOnAllGoals {get;set;}
    
    //Effective dates variable
    public Date startDate {get;set;}
    public Date endDate {get;set;}
     
    /********************   End   ***************************/
    
    //Constructor
    public StaffRelationshipWrapper(String payeeId, String clickedICON, Date startDate, Date endDate, Set<Id> setPGSRIds) {
        
        //Set Values
        this.payeeId = payeeId;
        this.clickedICON = clickedICON;
        this.startDate = startDate;
        this.endDate = endDate;
        this.setPGSRIds = setPGSRIds;
        
        //Call inIt
        inIt();
    }
    
    //Init method
    public void inIt() {
        
        //Instantiate Instances
        filterStaffRelationship = new Staff_Relationship__c(Start_Date__c = startDate, End_Date__c = endDate);
        listStaffRelationshipWrapper = new List<StaffRelationship>();
        
        //Initialize Blank Instance Wrapper
        newEditStaffRelationShip = new StaffRelationship(new Staff_Relationship__c(),'','','',false);
        relationshipType = new List<Relationship_Type__c>();
        
        //Check for clicked icon
        if(clickedICON == ISSPConstants.CLICKED_ICON_PERSONAL_GOAL) {
            
            //Set flags
            isLimitedToGoalDates = true;
            isEffectiveDate = false;    
        } else {
            
            //Set flags
            isLimitedToGoalDates = false;
            isEffectiveDate = true;
        }
        
        //Set defaults
        isRelationshipType = false;
        useOnAllGoals = false;
        setSRIds = new Set<Id>();
        setRemovedSRIds = new Set<Id>();
        
        //Load relationships
        loadExistingRelationships();
    }
    
    /**
     *  @description    :   This method is to load the existing relationships from selected contact
     *
     *  @args           :
     *
     *  @param          :   void
     *
     **/
    public void loadExistingRelationships() {
        
        //Reset values
        listStaffRelationshipWrapper = new List<StaffRelationship>();
        
        //Check for Payee Id
        if(String.isNotBlank(payeeId) && payeeId instanceof Id) {
            
            //SOQL Query
            String SOQLQuery = 'Select Id, From__c, From__r.Name, To__c, To__r.Name, Relationship__c, Relationship__r.Name, Relationship__r.Name_When_From__c, Relationship__r.Name_When_To__c, Start_Date__c,'
                               + 'End_Date__c From Staff_Relationship__c Where (From__c = \'' + payeeId + '\' OR To__c = \'' + payeeId + '\')';
            
            //Check for the filters
            
            //Check for LIMIT to goal checkbox
            if(isLimitedToGoalDates && clickedICON == ISSPConstants.CLICKED_ICON_PERSONAL_GOAL)
                SOQLQuery += ' AND Id IN : setPGSRIds';
            
            //Effective date filter
            if(isEffectiveDate) {
                
                //Check for Start and end dates
                if(filterStaffRelationship.Start_Date__c != null || filterStaffRelationship.End_Date__c != null) {
                    
                    //If both fields are not blank
                    if(filterStaffRelationship.Start_Date__c != null && filterStaffRelationship.End_Date__c != null) {
                        
                        //Date variables
                        Date tempStartDate = filterStaffRelationship.Start_Date__c; 
                        Date tempEndDate = filterStaffRelationship.End_Date__c;
                        
                        //Buils where caluse
                        SOQLQuery = SOQLQuery + ' AND ((Start_Date__c >= :tempStartDate AND Start_Date__c <=: tempEndDate) OR (End_Date__c >= :tempStartDate AND End_Date__c <=: tempEndDate)'
                                                + ' OR (Start_Date__c <: tempStartDate AND End_Date__c >: tempEndDate))';
                    
                        
                    } else if(filterStaffRelationship.Start_Date__c != null && filterStaffRelationship.End_Date__c == null) {
                        Date tempStartDate1 = filterStaffRelationship.Start_Date__c;
                        SOQLQuery += ' AND (Start_Date__c >= :tempStartDate1 OR End_Date__c = null OR (Start_Date__c < :tempStartDate1 AND End_Date__c >= :tempStartDate1))' ;
                
                    } else if(filterStaffRelationship.End_Date__c != null && filterStaffRelationship.Start_Date__c == null) {
                        Date tempEndDate1 = filterStaffRelationship.End_Date__c;
                        SOQLQuery += ' AND End_Date__c <= :tempEndDate1';
                    }
                }
            }
            //Relationship Type filter
            if(isRelationshipType && filterStaffRelationship.Relationship__c != null)
                SOQLQuery += ' AND Relationship__c = \'' + filterStaffRelationship.Relationship__c + '\'';
            
            SOQLQuery += ' Order by To__r.Name';
            System.debug('SOQLQuery::::::'+ SOQLQuery);
            
            //List of Staff Relationships
            List<Staff_Relationship__c> stffRelationships = (List<Staff_Relationship__c>)database.query(SOQLQuery);
            
            //Set to hold the contact Ids
            Set<Id> setConIds = new Set<Id>();
            
            //Loop through the staff Relationships
            for(Staff_Relationship__c sR : stffRelationships) {
                
                //Check for contact
                if(sR.To__c != null)
                    setConIds.add(sR.To__c);
            }
            
            // Modified By - Rajeev Jain - 10/05/2015 - staff reltionship Enhancment
            //Pull data from database
            for(Staff_Relationship__c sR : stffRelationships) {
                
                //Variables to hold the contact Info
                String conName = sR.From__c == payeeId ? sR.To__r.Name : sR.From__r.Name;
                String conId = sR.From__c == payeeId ? sR.To__c : sR.From__c;
                String relationship = '';
                
                //Check for realtionship
                if(sR.Relationship__c != null)
                    relationship = sR.From__c == payeeId ? sR.Relationship__r.Name_When_From__c : sR.Relationship__r.Name_When_To__c;
                
                //Instance of wrapper
                StaffRelationship sRW = new StaffRelationship(sR, relationship, conName, conId, setPGSRIds.contains(sR.Id) ? true : false);
                
                sRW.relationshipFromName = sR.Relationship__r.Name_When_From__c;
                sRW.relationshipToName = sR.Relationship__r.Name_When_To__c;
                sRW.defaultContact = sR.From__c == payeeId ? sR.From__r.Name : sR.To__r.Name;
                sRW.populatedContact = sR.From__c == payeeId ? sR.To__r.Name : sR.From__r.Name;
                
                //V_1.1 Modified - Rajeev Jain - 04/29/2016 - CR-20160301-9654 - Resolved from and To Text Confusion
                //Populate direction values
                sRW.directionList[0].setLabel('From : ' + sRW.defaultContact + ' - ' + sR.Relationship__r.Name_When_From__c + ' - ' + sRW.populatedContact);
                sRW.directionList[1].setLabel('To : ' + sRW.defaultContact + ' - ' + sR.Relationship__r.Name_When_To__c + ' - ' + sRW.populatedContact);
                //V_1.1 Modified - Rajeev Jain - 04/29/2016 - CR-20160301-9654 - Upto here
                
                //Set default direction
                sRW.selectedDirection = sR.From__c == payeeId ? 'From' : 'To';
                    
                //Add in wrapper
                listStaffRelationshipWrapper.add(sRW);
            }
            
            //Short the list
            listStaffRelationshipWrapper.sort();
        }
    }
    
    /**
     *  @description    :   This method is to delete the selected Relatioship account from list
     *
     *  @args           :
     *
     *  @param          :   void
     *
     **/
    public void delectRelationship() {
        
        try {
            
            //Reinitialize the complete list
            List<StaffRelationship> remainingRelationships = new List<StaffRelationship>();
            disableDelete = true;
            
            //Loop through the records and  
            for(StaffRelationship sRW : listStaffRelationshipWrapper) {
                
                //Do not consider the selected record   
                if(sRW.selected == false) {
                    
                    remainingRelationships.add(sRW);
                    
                    //Check if teh delete need to be still enabled
                    if(sRW.sR.Id == null)
                        disableDelete = false;
                }
                //Existing one can't be delete
                if(sRW.selected == true && sRW.sR.Id != null)
                    throw new CustomException('You may not delete existing relationships. You must end-date them instead.');
            }
            
            //Copy in existing list
            listStaffRelationshipWrapper = remainingRelationships;  
        } catch(Exception e) {
            
            //Add error on page
            ApexPages.addMessages(e);
            disableDelete = false;
        }
    }
    
    /**
     *  @description    :   This method is to add a new Relatioship
     *
     *  @args           :
     *
     *  @param          :   void
     *
     **/
    public void resetFilters() {
        
        //If view is selected, transfer will be disable and vice-versa
        if(isEffectiveDate == false) {
            
            //Reset
            filterStaffRelationship.Start_Date__c = null;
            filterStaffRelationship.End_Date__c = null; 
        }
        
        //Reset Relationship 
        if(isRelationshipType == false)
            filterStaffRelationship.Relationship__c = null;
    }
    
    /**
     *  @description    :   This method is to add Staff Relationships on the Personal goals as well
     *
     *  @args           :   
     *
     *  @return         :   void
     *
     **/
    public void addStaffRelationshiponPG() {
        
        //Loop through the what is populated on UI
        for(StaffRelationship sRW : listStaffRelationshipWrapper) {
            
            //Check for selected checkbox
            if(sRW.selected) {
                
                //Check if record is existing
                if(sRW.sR.Id != null) 
                    setSRIds.add(sRW.sR.Id);
                
                //Check goal checkbox and uncheck the original checkbox
                sRW.appliedonGoal = true;
                sRW.selected = false;
            }
        }
        
        //Page Message
        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'Selected relationships have been assigned to all related Goals for this payee.'));
            
    }
    
    /**
     *  @description    :   This method is to Refresh the result
     *
     *  @args           :
     *
     *  @param          :   void
     *
     **/
    public void refreshResults() {
        
        //If effective date filter is selected, Effective Start Date is Mandatory
        if(isEffectiveDate) {
            
            //Check if Transfer To is seletced
            if(filterStaffRelationship.Start_Date__c == null)
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'You must indicate a start date'));
        }
        
        //Check if error(s) exists
        if(ApexPages.hasMessages(ApexPages.Severity.ERROR))
            return;
            
        loadExistingRelationships();
    }
    
    /**
     *  @description    :   Save the entite request
     *
     *  @args           :   
     *
     *  @return         :   Pagereference
     *
     **/ 
    public void doSave() {
        
        //Create a savepoint
        Savepoint sp = Database.setSavepoint();
        
        try {
            
            //Insert data
            //Create a list of Staff relationsipship to be created 
            List<Staff_Relationship__c> staffRelationships = new List<Staff_Relationship__c>();
            
            //List to add all the Goals Staff relationships
            List<Staff_Relationship__c> tempStaffRelationships = new List<Staff_Relationship__c>();
            
            //Loop through the what is populated on UI
            for(StaffRelationship sRW : listStaffRelationshipWrapper) {
                
                //Check if contact is populated
                if(sRW.sR.To__c == null 
                    || sRW.sR.Relationship__c == null 
                    || sRW.sR.Start_Date__c == null 
                    || (sRW.sR.End_Date__c != null && sRW.sR.Start_Date__c > sRW.sR.End_Date__c))
                    throw new CustomException('Related to, Relationship, Start Date is mandatory for each item and Effective date should be valid.');       
            
                //Check for Goal checkbox
                if(sRW.appliedonGoal) {
                    
                    //Add Id in removed Set
                    if(sRW.sR.Id != null && setRemovedSRIds.contains(sRW.sR.Id))
                        setRemovedSRIds.remove(sRW.sR.Id);
                    
                    //Add Relationship in temp list
                    tempStaffRelationships.add(sRW.sR); 
                
                }else {
                    
                    //Add Id in removed Set
                    if(sRW.sR.Id != null) {
                        
                        //Add SR id in remove set
                        if(setSRIds.contains(sRW.sR.Id) || setPGSRIds.contains(sRW.sR.Id))
                            setRemovedSRIds.add(sRW.sR.Id);
                        
                        //Remove Ids from set
                        setSRIds.remove(sRW.sR.Id);
                        setPGSRIds.remove(sRW.sR.Id);
                        
                    }
                    
                    //Add in Staff Relationship list
                    staffRelationships.add(sRW.sR);
                }
                    
            }
            
            //Upsert records    
            if(staffRelationships.size() > 0 || tempStaffRelationships.size() > 0) {
                
                //Move records from the temp list
                staffRelationships.addAll(tempStaffRelationships);
                
                //Upsert
                upsert staffRelationships;
                
                //Check for any execption
                if(ApexPages.hasMessages(ApexPages.Severity.ERROR))
                    database.rollBack(sp);  
                
                
                //Loop through the Goals Staff Relationships
                //This list have the staff relationship Ids (call by reference feature)
                for(Staff_Relationship__c sR : tempStaffRelationships) {
                    
                    //Add sR Id in set
                    setSRIds.add(sR.Id);
                    
                    //Add Staff Relationship Id in set
                    setPGSRIds.add(sR.Id);
                }
            }
            
            loadExistingRelationships();
            
            //Page Message
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'Relationships have been saved.'));
        
        } catch(Exception e) {
            
            //Rollback the entire transaction
            database.rollBack(sp);
            
            //Add message on page
            ApexPages.addMessages(e);
        }
    }
    
    /**
     *  @description    :   Populate Direction Radio Options in Staff RelationShip popup
     *                  :   Added By - Rajeev Jain - 10/05/2015
     *
     *  @args           :   
     *
     *  @return         :   Pagereference
     *
     **/ 
     public void populateDirectionList(){
        
        //Query to get Default Contact Name
        List<Contact> fromContact = [select Id, Name from Contact where Id =: payeeId OR Id =: newEditStaffRelationShip.sR.From__c];
        
        //Check for contacts size
        if(fromContact.size() >= 2) {
        
            //From Name
            String fromName =  fromContact[0].Id == payeeId ? fromContact[0].Name : fromContact[1].Name;
            String populatedContactName =  fromContact[0].Id == newEditStaffRelationShip.sR.From__c ? fromContact[0].Name : fromContact[1].Name;
            
            //Query through the relationsip type
            relationshipType = [select Id, Name_When_From__c, Name_When_To__c from Relationship_Type__c where Id = :newEditStaffRelationShip.sR.Relationship__c];
            
            //Check for relationship types
            if(relationshipType.size() > 0) {
                
                //V_1.1 Modified - Rajeev Jain - 04/29/2016 - CR-20160301-9654 - Resolved from and To Text Confusion
                //Fill Direction List
                //Fill first option label
                newEditStaffRelationShip.directionList[0].setLabel('From : ' + fromName + ' - ' + relationshipType[0].Name_When_From__c + ' - ' + populatedContactName);
                newEditStaffRelationShip.directionList[1].setLabel('To : ' + fromName + ' - ' + relationshipType[0].Name_When_To__c + ' - ' + populatedContactName);
                //V_1.1 Modified - Rajeev Jain - 04/29/2016 - CR-20160301-9654 - Resolved from and To Text Confusion
                
                newEditStaffRelationShip.relationshipFromName = relationshipType[0].Name_When_From__c;
                newEditStaffRelationShip.relationshipToName = relationshipType[0].Name_When_To__c;
                newEditStaffRelationShip.defaultContact = fromContact[0].Id == payeeId ? fromContact[0].Name : fromContact[1].Name;
                newEditStaffRelationShip.populatedContact = fromContact[0].Id == newEditStaffRelationShip.sR.From__c ? fromContact[0].Name : fromContact[1].Name;   
            }
        }
     } 
     
     /**
     *  @description    :   Method to add new RelationShip in Wrapper List or update the existing item of the wrapper list through the popup.
     *                  :   Added By - Rajeev Jain - 10/05/2015
     *
     *  @args           :   
     *
     *  @return         :   Pagereference
     *
     **/ 
     public void saveNewStaffReltionShipData(){
        
        try{
            
            //Check for Staff Relationship
            if(newEditStaffRelationShip.sR.From__c != null) {
                
                //Instance of Staff Relationship
                Staff_Relationship__c sR = new Staff_Relationship__c();
                
                System.debug('###### : ' +newEditStaffRelationShip);
                //Check for Direction
                if(newEditStaffRelationShip.selectedDirection == 'From') {
                    
                    sR.From__c = payeeId;
                    sR.To__c = newEditStaffRelationShip.sR.From__c;
                    newEditStaffRelationShip.contactName = newEditStaffRelationShip.populatedContact;
                    newEditStaffRelationShip.contId = newEditStaffRelationShip.sR.From__c;
                    newEditStaffRelationShip.relationship = newEditStaffRelationShip.relationshipFromName;
                    
                } else if(newEditStaffRelationShip.selectedDirection == 'To') {
                    
                    sR.From__C = newEditStaffRelationShip.sR.From__c;
                    sR.To__c = payeeId;
                    newEditStaffRelationShip.contactName = newEditStaffRelationShip.populatedContact;
                    newEditStaffRelationShip.contId = newEditStaffRelationShip.sR.From__c;
                    newEditStaffRelationShip.relationship = newEditStaffRelationShip.relationshipToName;
                }
                
                //Populate StaffRelationShip Wrapper List with New Row Information
                newEditStaffRelationShip.sR.From__c = sR.From__c;
                newEditStaffRelationShip.sR.To__c = sR.To__c;
                
                System.debug('###### : ' +newEditStaffRelationShip);
                if(selectedStaffRelationshipIndex != null){
                
                    //UPdate Exisitng indexed item in the list with new information comes from the Popup
                    listStaffRelationshipWrapper[selectedStaffRelationshipIndex] = newEditStaffRelationShip;
                    
                    //Reset selectedStaffRelationshipIndex to null, so it will not afftect to add new StaffRelationship
                    selectedStaffRelationshipIndex = null;
                }else{
                    
                    //Add new instance to the wrapperlist
                    listStaffRelationshipWrapper.add(newEditStaffRelationShip);
                }
                newEditStaffRelationShip = new StaffRelationship(new Staff_Relationship__c(),'','','',false);
                disableDelete = false;
            }
            
        }catch(Exception e){
        }
     }
     
     //Edit RelationShip
    public void editRelationShip(){
        
        //Check if selectedStaffRelationshipIndex is not null
        if(selectedStaffRelationshipIndex != null && listStaffRelationshipWrapper.get(selectedStaffRelationshipIndex) != null ){
            
            //Populate StaffSelection Wrapper
            newEditStaffRelationShip =  listStaffRelationshipWrapper.get(selectedStaffRelationshipIndex);
            newEditStaffRelationShip.sR.From__c = newEditStaffRelationShip.selectedDirection == 'From' ? newEditStaffRelationShip.sR.To__c : newEditStaffRelationShip.sR.From__c;
        }
    }
    
    //Cancle all
    public void cancelAllPopupActions(){
        
        newEditStaffRelationShip = new StaffRelationship(new Staff_Relationship__c(),'','','',false);
        selectedStaffRelationshipIndex = null;  
    }
    
    //Wrapper class for Relationship
    //Modieifed By - Rajeev Jain - 10/05/2015 - Staff Relationship enhancment
    public class StaffRelationship implements Comparable {
        
        //Properties
        public Boolean selected {get; set;}
        public Staff_Relationship__c sR {get; set;}
        public String title {get;set;}
        public Boolean appliedonGoal {get;set;}
        
        //================== Added By Rajeev Jain - 10/05/2015 =======================
        
        //Hold RelationShip Name
        public String relationship {get;set;}
        
        //Hold from or to contact Name
        public String contactName{get;set;}
        
        //Hold from or to Contact Id
        public String contId{get;set;}
        
        //Select Option list, to display Radio button on the popup, like from and to
        public List<SelectOption> directionList{get;set;}
        
        //Holds selected radio value on the popup on the page
        public String selectedDirection{get;set;}
        public String relationshipFromName;
        public String relationshipToName;
        
        //Hold the Contact Id of from contact when the STD Goal Page loads first time it is populated in from contact on the popup
        public String defaultContact;
        
        //Populate when user select contact from the New relationship popup
        public String populatedContact;
        
        //================== Added By Rajeev Jain - 10/05/2015 ======================= upto here
        
        //Constructor
        //Modified By - Rajeev Jain - 10/05/2015, added additional param in constructor, Removed Title
        public StaffRelationship(Staff_Relationship__c sR, String relationship, String contactName, String contId, Boolean appliedonGoal) {
            
            //Set values
            this.sR = sR;
            
            //================== Added By Rajeev Jain - 10/05/2015 ======================= upto here
            this.relationship = relationship;
            this.contactName = contactName;
            this.contId = contId;
            
            //Fill the Direction List
            directionList = new List<SelectOption>();
            
            //Add Direction Option 
            directionList.add(new SelectOption('From','From :'));
            directionList.add(new SelectOption('To','To : '));
            
            //Default selected radio option on the popup screen
            selectedDirection = 'From';
            //================== Added By Rajeev Jain - 10/05/2015 ======================= upto here
            
            this.appliedonGoal = appliedonGoal;
            
            //Set defaults
            selected = false;
        }
        
        // Implement the compareTo() method
        public Integer compareTo(Object compareTo) {
        
            
            StaffRelationship compareToEmp = (StaffRelationship)compareTo;
            
            if (appliedonGoal == compareToEmp.appliedonGoal) return 0;
            if (compareToEmp.appliedonGoal && appliedonGoal != compareToEmp.appliedonGoal) return 1;
            return -1;        
        }
    }
}