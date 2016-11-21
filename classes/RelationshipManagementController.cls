/*
 *  Purpose         :   This class is to control the functionality of adding new Relationship
 *                  
 *  Create By       :   Bhavi Sharma
 *  
 *  Created Date    :   08/31/2015
 *  
 *  Revision Log    :   V_1.0 Created - CR-20150825-9182
 *                  :   V_2.0 Modified By - Rajeev Jain - 2/24/2016 - CR-20160121-9556 - Changed from and to relationship text confusion.
 *                      
 **/
public with sharing class RelationshipManagementController {
    
    //My relationship Master Instace
    public Staff_Relationship__c staffRelationship {get; set;}
    public Staff_Relationship__c transferStaffRelationship {get; set;}
    public Staff_Relationship__c filterStaffRelationship {get; set;}
    public String selectedView {get; set;}
    public Relationship_Type__c relatationType {get; set;}
    public List<StaffRelationshipWrapper> listStaffRelationshipWrapper {get; set;}
    
    //Create Blank Instance of StaffRelationshipWrapper that will be used to insert update New and existing staff Relationship.
    //Added By - Rajeev Jain - 10/06 -  Enhancment 
    public StaffRelationshipWrapper staffRelationWrapper{get;set;}
    public Integer selectedStaffRelationshipIndex{get;set;}
    //Added By - Rajeev Jain - 10/06 -  Enhancment - upto here
    
    //Filters
    public Boolean isCurrentlyActive {get; set;}
    public Boolean isEffectiveDate {get; set;}
    public Boolean isRelationshipType {get; set;}
    
    //Delete button
    public Boolean disableDelete {get; set;}
    
    List<Relationship_Type__c> relationshipType;
    
    //Get View
    public List<SelectOption> views {
        get {
            
            List<SelectOption> options = new List<SelectOption>();
            
            //Add in list
            options.add(new SelectOption('view', 'View existing Relationships'));
            options.add(new SelectOption('transfer', 'Transfer existing Relationships'));
            
            //Return
            return options;
        }
    }
    
    //Constructor
    public RelationshipManagementController() {
        
        //Init
        inIt(); 
    }
    
    //Init method
    private void inIt() {
        
        //Instantiate Instances
        staffRelationship = new Staff_Relationship__c();
        transferStaffRelationship = new Staff_Relationship__c();
        filterStaffRelationship = new Staff_Relationship__c();
        listStaffRelationshipWrapper = new List<StaffRelationshipWrapper>();
        relationshipType = new List<Relationship_Type__c>();
        
        //Set defaults
        selectedView = 'view';
        isCurrentlyActive = false;
        isEffectiveDate = false;
        isRelationshipType =  false;
        disableDelete = true;
        
        //Initialize Blank Instance Wrapper
        staffRelationWrapper = new StaffRelationshipWrapper(new Staff_Relationship__c(),'','','');
        
        //get the contactId from URL
        if(ApexPages.currentPage().getParameters().get('contactId') != null)
            staffRelationship.From__c = ApexPages.currentPage().getParameters().get('contactId');
        
        //get the relationship type from URL
        if(ApexPages.currentPage().getParameters().get('relationshipTypeId') != null) {
            
            filterStaffRelationship.Relationship__c = ApexPages.currentPage().getParameters().get('relationshipTypeId');
            isRelationshipType = true;
        }
        
        //Load Existing
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
        listStaffRelationshipWrapper = new List<StaffRelationshipWrapper>();
        
        //If From value is selected on screen, load relations
        if(staffRelationship.From__c != null) {
            
            //SOQL Query
            String SOQLQuery = 'Select Id, From__c, From__r.Name, To__c, To__r.Name, Relationship__c, Relationship__r.Name, Relationship__r.Name_When_From__c, Relationship__r.Name_When_To__c, Start_Date__c, End_Date__c from Staff_Relationship__c'
                                + ' Where (From__c = \'' + staffRelationship.From__c + '\' OR To__c = \'' + staffRelationship.From__c + '\')';
            
            //Check for the filters
            if(isCurrentlyActive) {
                
                SOQLQuery += ' AND (End_Date__c = null OR End_Date__c >= TODAY) AND Start_Date__c != null AND Start_Date__c <= TODAY ';
            }
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
                        Date startDate = filterStaffRelationship.Start_Date__c;
                        SOQLQuery += ' AND (Start_Date__c >= :startDate OR End_Date__c = null OR (Start_Date__c < :startDate AND End_Date__c >= :startDate))' ;
                
                    } else if(filterStaffRelationship.End_Date__c != null && filterStaffRelationship.Start_Date__c == null) {
                        Date endDate = filterStaffRelationship.End_Date__c;
                        SOQLQuery += ' AND End_Date__c <= :endDate';
                    }
                }
            }
            if(isRelationshipType && filterStaffRelationship.Relationship__c != null) {
                SOQLQuery += ' AND Relationship__c = \'' + filterStaffRelationship.Relationship__c + '\'';
            }
            
            SOQLQuery += ' Order by To__r.Name';
            
            //List of Staff Relationships
            List<Staff_Relationship__c> stffRelationships = (List<Staff_Relationship__c>)database.query(SOQLQuery);
            
            //Pull data from database
            for(Staff_Relationship__c sR : stffRelationships) {
                
                //Modified By - Rajeev Jain - 10/08 - Enhancment
                //Variables to hold the contact Info
                String conName = sR.From__c == staffRelationship.From__c ? sR.To__r.Name : sR.From__r.Name;
                String conId = sR.From__c == staffRelationship.From__c ? sR.To__c : sR.From__c;
                String relationship = '';
                
                //Check for realtionship
                if(sR.Relationship__c != null)
                    relationship = sR.From__c == staffRelationship.From__c ? sR.Relationship__r.Name_When_From__c : sR.Relationship__r.Name_When_To__c;
                
                //Instance of wrapper
                StaffRelationshipWrapper sRW = new StaffRelationshipWrapper(sR, relationship, conName, conId);
                
                sRW.relationshipFromName = sR.Relationship__r.Name_When_From__c;
                sRW.relationshipToName = sR.Relationship__r.Name_When_To__c;
                sRW.defaultContact = sR.From__c == staffRelationship.From__c ? sR.From__r.Name : sR.To__r.Name;
                sRW.populatedContact = sR.From__c == staffRelationship.From__c ? sR.To__r.Name : sR.From__r.Name;
                
                //V_2.0 Modified By - Rajeev Jain - 2/24/2016 - CR-20160121-9556
                //Populate direction values
                sRW.directionList[0].setLabel('From : ' + sRW.defaultContact + ' - ' + sR.Relationship__r.Name_When_From__c + ' - ' + sRW.populatedContact);
                sRW.directionList[1].setLabel('To : ' + sRW.defaultContact + ' - ' + sR.Relationship__r.Name_When_To__c + ' - ' + sRW.populatedContact);
                //V_2.0 Modified By - Rajeev Jain - 2/24/2016 - CR-20160121-9556 - Upto Here
                
                //Set default direction
                sRW.selectedDirection = sR.From__c == staffRelationship.From__c ? 'From' : 'To';
                
                
                //Add in wrapper
                listStaffRelationshipWrapper.add(sRW);
                
                //Modified By - Rajeev Jain - 10/08 - Enhancment - upto here
            }
        }
    }
    
    /**
     *  @description    :   This method is to reset View Selection
     *
     *  @args           :
     *
     *  @param          :   void
     *
     **/
    public void resetViews() {
        
        //If view is selected, transfer will be disable and vice-versa
        if(selectedView == 'view') {
            
            //Reset
            transferStaffRelationship.From__c = null;
            transferStaffRelationship.Start_Date__c = null; 
        }
    }
    
    /**
     *  @description    :   This method is to Reset filter selection and blank out values of associated fields
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
        //Rj - 10/06/2015 - Enhancment 
        //Check if RelationShip Type checkbox is not selected then reset its lookup value
        if(isRelationshipType == false)
            filterStaffRelationship.Relationship__c = null;
    }
    
    /**
     *  @description    :   This method is to refresh the relationship list based on what selected in filteres and relation ship view.
     *
     *  @args           :
     *
     *  @param          :   void
     *
     **/
    public void refreshResults() {
        
        //Check if the results based on the filters selection
        if(selectedView == 'transfer') {
            
            //Check if Transfer To is seletced
            if(transferStaffRelationship.From__c == null)
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Please indicate to whom this is being transferred, or change your choice to \'View existing relationships\''));
            if(transferStaffRelationship.Start_Date__c == null)
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Please indicate the effective date of the transfer'));
        }
        
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
     *  @description    :   This method is to delete the selected Relatioship account from list
     *
     *  @args           :
     *
     *  @param          :   void
     *
     **/
    //Modified By - rajeev - 10/08/2015 - Renamed function.
    public void deleteRelationship() {
        
        try {
            
            //Reinitialize the complete list
            List<StaffRelationshipWrapper> remainingRelationships = new List<StaffRelationshipWrapper>();
            disableDelete = true;
            
            //Loop through the records and  
            for(StaffRelationshipWrapper sRW : listStaffRelationshipWrapper) {
                
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
     *  @description    :   This method is to apply the master date on all childs
     *
     *  @args           :
     *
     *  @param          :   void
     *
     **/
    //Modidied By - Rajeev Jain - 10/07/2015 - Enhancment
    public void applyDates() {
        
        //Check if Start Date is not null
        if(isEffectiveDate && (filterStaffRelationship.Start_Date__c != null || filterStaffRelationship.End_Date__c != null)){
            
            //Loop through the records and  
            for(StaffRelationshipWrapper sRW : listStaffRelationshipWrapper) {
                
                //Check if the record was selected on UI, if yes, apply the master details
                if(sRW.selected == true) {
                    
                    //Check for non-blank dates
                    sRW.sR.Start_Date__c = filterStaffRelationship.Start_Date__c != null ? filterStaffRelationship.Start_Date__c : sRW.sR.Start_Date__c;
                    sRW.sR.End_Date__c = filterStaffRelationship.End_Date__c != null ? filterStaffRelationship.End_Date__c : sRW.sR.End_Date__c;
                }
            }
        //Can not apply null start date to selected relationship from, show error message on the page.
        }else if(isEffectiveDate && filterStaffRelationship.Start_Date__c == null && filterStaffRelationship.End_Date__c == null)
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'You must indicate either a start date or end date'));  
              
        //Modified By - Rajeev Jain - 10/07/2015 -  Enhancment - upto here
    }
    
    /**
     *  @description    :   Save the entite request
     *
     *  @args           :   
     *
     *  @return         :   Pagereference
     *
     **/ 
    public void save() {
        
        //Hold End Date corrosponging to Id of Staff relationship, so In case of Transfer view and any transaction rolled back we can reAssign those changes in the wrapper list.
        Map<Id,Date> mapDateToBeRolledBack = new Map<Id,Date>();
        
        //Create a savepoint
        Savepoint sp = Database.setSavepoint();
        
        try {
            
            //Check for the required fields
            if(staffRelationship.From__c == null) {
            
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Please enter data in all teh required fields'));
                return;
            }
            
            //Insert data
            //Create a list of Staff relationsipship to be created 
            List<Staff_Relationship__c> staffRelationships = new List<Staff_Relationship__c>();
            
            //Loop through the what is populated on UI
            for(StaffRelationshipWrapper sRW : listStaffRelationshipWrapper) {
                
                System.debug(':::::' + sRW.sR.To__c + ':::::' + sRW.sR.Relationship__c + ':::::' + sRW.sR.Start_Date__c + ':::::' + sRW.sR.End_Date__c);
                
                //Check if contact is populated
                if(sRW.sR.To__c == null 
                    || sRW.sR.Relationship__c == null 
                    || sRW.sR.Start_Date__c == null 
                    || (sRW.sR.End_Date__c != null && sRW.sR.Start_Date__c > sRW.sR.End_Date__c))
                    throw new CustomException('Related to, Relationship, Start Date is mandatory for each item and Effective date should be valid.');       
            }
            
            
            //If it's  a view, then update all the data
            if(selectedView == 'view') {
                
                //Loop through the what is populated on UI
                for(StaffRelationshipWrapper sRW : listStaffRelationshipWrapper) {
                    
                    //Check if contact is populated
                    if(sRW.sR.To__c == null 
                        || sRW.sR.Relationship__c == null 
                        || sRW.sR.Start_Date__c == null 
                        || (sRW.sR.End_Date__c != null && sRW.sR.Start_Date__c > sRW.sR.End_Date__c))
                        throw new CustomException('Related to, Relationship, Start Date is mandatory for each item and Effective date should be valid.');       
                
                    //Set values
                    //sRW.sR.From__c = staffRelationship.From__c;
                    staffRelationships.add(sRW.sR);
                }
                
                if(staffRelationships.size() > 0) {
                    upsert staffRelationships;  
                }
            } else if(selectedView == 'transfer') {
                system.debug('&&&&&&&&&&');
                //Validate Transfer request
                if(transferStaffRelationship.From__c == null
                    || transferStaffRelationship.Start_Date__c == null)
                    throw new CustomException('Transfer to and Effective as of, both these values are required.');
                
                //Validate request
                if(staffRelationship.From__c == transferStaffRelationship.From__c)
                    throw new CustomException('Transfer From and Transfer To should not be same.');
                    
                //Loop through the what is populated on UI
                for(StaffRelationshipWrapper sRW : listStaffRelationshipWrapper) {
                    system.debug('~~~~~~~~~');
                    //Check if contact is populated
                    if(sRW.selected == true) {
                        system.debug('!!!!!!!!!!!!');
                        //Fill the End date and Id in the map before changes, so in case of Rollback we can reAssign those changes to actual list
                        mapDateToBeRolledBack.put(sRW.sR.id, sRW.sR.End_Date__c);
                        
                        //Set values
                        sRW.sR.End_Date__c = transferStaffRelationship.Start_Date__c - 1;
                        staffRelationships.add(sRW.sR);
                        
                        //Create a clone
                        Staff_Relationship__c clonedSR = new Staff_Relationship__c();
                        
                        //Check for relation
                        if(sRW.sR.From__c == staffRelationship.From__c) {
                            system.debug('!!!!!@@@@@@');
                            clonedSR.From__c = transferStaffRelationship.From__c;
                            clonedSR.To__c = sRW.sR.To__c;  
                        
                        } else {
                            system.debug('@@@@@@@!!!!!');
                            clonedSR.From__c = sRW.sR.From__c;
                            clonedSR.To__c = transferStaffRelationship.From__c;
                        }
                        
                        clonedSR.Relationship__c = sRW.sR.Relationship__c;
                        clonedSR.Start_Date__c = transferStaffRelationship.Start_Date__c;
                        clonedSR.End_Date__c = null;
                        staffRelationships.add(clonedSR);
                    }
                }
            } 
            system.debug('&&&&&&*******'+staffRelationships.size());
            //Check for list size
            if(staffRelationships.size() > 0)
                upsert staffRelationships;
            
            if(ApexPages.hasMessages(ApexPages.Severity.ERROR)){
                system.debug('=========');
                //In Case of Roll Back, refresh the local instanc to show old changes
                rollBackStaffRelationShipWrapper(listStaffRelationshipWrapper,mapDateToBeRolledBack);
                database.rollBack(sp);  
            }    
            //Page Message
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'Changes saved!'));
            
            //If view option is �Transfer�
                //Change the view option to �View�
            if(selectedView == 'transfer') {
                
                selectedView = 'view';
            }
            
            loadExistingRelationships();    
        } catch(Exception e) {
            
            //In Case of Roll Back, refresh the local instanc to show old changes
            rollBackStaffRelationShipWrapper(listStaffRelationshipWrapper,mapDateToBeRolledBack);
            
            //Rollback the entire transaction
            database.rollBack(sp);
            
            //Add message on page
            ApexPages.addMessages(e);
        }
    }
    
    /** 
    *   @description    :   Method to Rolled Back local instance changes
    *                   :   @Added By - Rajeev Jain - 10/08/2015 - Enhancment
    *   
    *   @args           :   List of Wrapper
    *
    *   @return         :   void
    **/
    private void rollBackStaffRelationShipWrapper(List<StaffRelationshipWrapper> listStaffRelationshipWrapper, Map<Id,Date> mapDateToBeRolledBack){
        
        //Loop through what was populated on UI
        for(StaffRelationshipWrapper sRW : listStaffRelationshipWrapper) {
            
            //Check if contact is populated
            if(sRW.selected == true && mapDateToBeRolledBack != null && mapDateToBeRolledBack.containsKey(sRW.sR.id)) {
                
                //ReAssign old changes
                sRW.sR.End_Date__c = mapDateToBeRolledBack.get(sRW.sR.id);  
                    
            }
        }           
    }
    
    /**
     *  @description    :   Save the entite request
     *
     *  @args           :   
     *
     *  @return         :   Pagereference
     *
     **/ 
    public Pagereference saveAndClose() {
        
        //Save the entire request
        save();
        
        if(ApexPages.hasMessages(ApexPages.Severity.ERROR))
            return null;
        
        //If view option is �view�
            //Change the view option to �View�
        if(selectedView == 'view' && transferStaffRelationship.From__c == null) {
            
            //From
            return new PageReference('/' + staffRelationship.From__c);  
        } else if(transferStaffRelationship.From__c != null) {
            
            //transferred from
            return new PageReference('/' + transferStaffRelationship.From__c);      
        } else {
            
            return null;
        }
    }
    
    /**
     *  @description    :   Cancel the entite request
     *
     *  @args           :   
     *
     *  @return         :   Pagereference
     *
     **/ 
    public Pagereference cancel() {
        
        //cancel page
        //Redirect back to contact
        return new Pagereference('/' + staffRelationship.From__c);
    }
    
     /**
     *  @description    :   Populate Direction Radio Options in Staff RelationShip popup 
     *                  :   @Added By - Rajeev Jain - 10/06/2015 - Enhancment
     *
     *  @args           :   
     *
     *  @return         :   Pagereference
     *
     **/ 
     public void populateDirectionList(){
        
        //Query to get Default Contact Name
        List<Contact> fromContact = [select Id, Name from Contact where Id = : staffRelationship.From__c OR Id = :staffRelationWrapper.sR.From__c];
        
        //From Name
        String fromName =  fromContact[0].Id == staffRelationship.From__c ? fromContact[0].Name : fromContact[1].Name;
        String populatedContactName =  fromContact[0].Id == staffRelationWrapper.sR.From__c ? fromContact[0].Name : fromContact[1].Name;
        
        relationshipType = [select Id, Name_When_From__c, Name_When_To__c from Relationship_Type__c where Id = :staffRelationWrapper.sR.Relationship__c];
        
        //V_2.0 Modified By - Rajeev Jain - 2/24/2016 - CR-20160121-9556
        //Fill Direction List
        //Fill first option label
        staffRelationWrapper.directionList[0].setLabel('From : ' + fromName + ' - ' + relationshipType[0].Name_When_From__c + ' - ' + populatedContactName);
        staffRelationWrapper.directionList[1].setLabel('To : ' + fromName + ' - ' + relationshipType[0].Name_When_To__c + ' - ' + populatedContactName);
        //V_2.0 Modified By - Rajeev Jain - 2/24/2016 - CR-20160121-9556 - Upto here
        
        staffRelationWrapper.relationshipFromName = relationshipType[0].Name_When_From__c;
        staffRelationWrapper.relationshipToName = relationshipType[0].Name_When_To__c;
        staffRelationWrapper.defaultContact = fromContact[0].Id == staffRelationship.From__c ? fromContact[0].Name : fromContact[1].Name;
        staffRelationWrapper.populatedContact = fromContact[0].Id == staffRelationWrapper.sR.From__c ? fromContact[0].Name : fromContact[1].Name;
     } 
     
     /**
     *  @description    :   Method to save new or edit relation ship data from the popup
     *                  :   @Added By - Rajeev Jain - 10/06/2015 - Enhancment
     *
     *  @args           :   
     *
     *  @return         :   Pagereference
     *
     **/ 
     public void saveNewStaffReltionShipData(){
        
        try{
            
            //Check for Staff Relationship
            if(staffRelationWrapper.sR.From__c != null) {
                
                //Instance of Staff Relationship
                Staff_Relationship__c sR = new Staff_Relationship__c();
                
                //Query through the contact
                List<Contact> contacts = [Select Id,Name From Contact Where Id =: staffRelationWrapper.sR.From__c];
                
                //Check for Direction
                if(staffRelationWrapper.selectedDirection == 'From') {
                    
                    sR.From__c = staffRelationship.From__c;
                    sR.To__c = staffRelationWrapper.sR.From__c;
                    staffRelationWrapper.contactName = staffRelationWrapper.populatedContact;
                    staffRelationWrapper.contId = staffRelationWrapper.sR.From__c;
                    staffRelationWrapper.relationship = staffRelationWrapper.relationshipFromName;
                    
                } else if(staffRelationWrapper.selectedDirection == 'To') {
                    
                    sR.From__C = staffRelationWrapper.sR.From__c;
                    sR.To__c = staffRelationship.From__c;
                    staffRelationWrapper.contactName = staffRelationWrapper.populatedContact;
                    staffRelationWrapper.contId = staffRelationWrapper.sR.From__c;
                    staffRelationWrapper.relationship = staffRelationWrapper.relationshipToName;
                }
                
                //Populate StaffRelationShip Wrapper List with New Row Information
                staffRelationWrapper.sR.From__c = sR.From__c;
                staffRelationWrapper.sR.To__c = sR.To__c;
                
                if(selectedStaffRelationshipIndex != null){
                
                    //UPdate Exisitng indexed item in the list with new information comes from the Popup
                    listStaffRelationshipWrapper[selectedStaffRelationshipIndex] = staffRelationWrapper;
                    
                    //Reset selectedStaffRelationshipIndex to null, so it will not afftect to add new StaffRelationship
                    selectedStaffRelationshipIndex = null;
                }else{
                    
                    //Add new instance to the wrapperlist
                    listStaffRelationshipWrapper.add(staffRelationWrapper);
                }
                staffRelationWrapper = new StaffRelationshipWrapper(new Staff_Relationship__c(),'','','');
                disableDelete = false;
            }
            
        }catch(Exception e){
        }
     }
    
    /**
     *  @description    :   Method to edit staff relationship in popup
     *                  :   @Added By - Rajeev Jain - 10/06/2015 - Enhancment
     *
     *  @args           :   
     *
     *  @return         :   Pagereference
     *
     **/ 
    //Edit RelationShip
    public void editRelationShip(){
        
        //Check if selectedStaffRelationshipIndex is not null
        if(selectedStaffRelationshipIndex != null && listStaffRelationshipWrapper.get(selectedStaffRelationshipIndex) != null ){
            
            //Populate StaffSelection Wrapper
            staffRelationWrapper =  listStaffRelationshipWrapper.get(selectedStaffRelationshipIndex);
            staffRelationWrapper.sR.From__c = staffRelationWrapper.selectedDirection == 'From' ? staffRelationWrapper.sR.To__c : staffRelationWrapper.sR.From__c;
        }
    }
    
    /**
     *  @description    :   Method to cancel all things performed in popup for Add and Edit Staff Relationship
     *                  :   @Added By - Rajeev Jain - 10/06/2015 - Enhancment
     *
     *  @args           :   
     *
     *  @return         :   Pagereference
     *
     **/ 
    //Cancle all
    public void cancelAllPopupActions(){
        
        staffRelationWrapper = new StaffRelationshipWrapper(new Staff_Relationship__c(),'','','');
        selectedStaffRelationshipIndex = null;  
    }
    
    //Wrapper class for Relationship
    public class StaffRelationshipWrapper {
        
        //Properties
        public Boolean selected {get; set;}
        public Staff_Relationship__c sR {get; set;}
        public String relationship {get;set;}
        public String contactName{get;set;}
        public String contId{get;set;}
        public List<SelectOption> directionList{get;set;}
        public String selectedDirection{get;set;}
        public String relationshipFromName;
        public String relationshipToName;
        public String defaultContact;
        public String populatedContact;
        
        
        //Constructor
        public StaffRelationshipWrapper(Staff_Relationship__c sR, String relationship, String contactName, String contId) {
            
            //Set
            this.sR = sR;
            this.relationship = relationship;
            this.contactName = contactName;
            this.contId = contId;
            
            //Fill the Direction List
            directionList = new List<SelectOption>();
            
            //Add Direction Option 
            directionList.add(new SelectOption('From','From :'));
            directionList.add(new SelectOption('To','To : '));
            
            selectedDirection = 'From';
        }
    }
}