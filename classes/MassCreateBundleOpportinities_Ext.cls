/**
*  Description      :   Class to hold the logic behind the "Mass Create Bundle Opportunity" functionality.
*
*  Created By       :   Abhinav Sharma
*
*  Created Date     :   09/15/2014
*
*  Revision Logs    :   V_1.0 - Created - CR-20140429-5272
*						V_1.1 - Modified by - Mahendra Swarnkar - 12/042015 - CR-20151022-9350
*
**/  
public with sharing class MassCreateBundleOpportinities_Ext {
    
    //Bundle
    public Bundle__c bundle {get; set;}
    
    //Existing already bundled opportunities list
    public List<MassCreateBundleOpportunityWrapper> existingBundledOpportunities {get; set;}
    
    //Collection's to hold Record Type details
    Set<String> recordTypesDeveloperNames;
    Map<Id, RecordType> mapRecordTypes;
    Map<String, ID> mapRecordTypeNameWithID;
    
    //List of wrapper class to hold the record Type details
    public List<RecordTypeWrapper> recordTypes {get; set;}
    
    //Variable to hold the selected row no value for the wrapper list on the page
    public Integer selectedRowNo {get; set;}
    
    //Boolean properties helpful in rendering on the page
    public Boolean isDisplayNewOppRdTypeSelectionSection {get; set;}
    public Boolean isDisplayDefaultSections {get; set;}
    public Boolean isDisplayAddExistingOppSection {get; set;}
    public Boolean displayIconAndlink {get; set;}
    public Boolean isHavingErrors {get; set;}
    
    //String to hold the selected record type value
    public string selectedRdType {get; set;}
    
    //Pagereference variable
    Pagereference pageRef;
    
    //Other Useful Collections
    List<Bundle__c> bundles;
    List<Opportunity> opportunitiesForUpsert;
    
    //Bundled Siblings
    public Bundled_Siblings__c bSibling {get; set;}
    
    //Opportunity Record Types Options list
    public List<SelectOption> getOppRecordTypes() {
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption(MassCreateBundleOppConstants.PT_MARKETING,MassCreateBundleOppConstants.PT_MARKETING_LABEL));
        options.add(new SelectOption(MassCreateBundleOppConstants.RI_MARKETING,MassCreateBundleOppConstants.RI_MARKETING_LABEL));
        
        //Modified by - Mahendra Swarnkar - 12/042015 - CR-20151022-9350 - updated the labelfrom southwind to Consulting & Management
        //Starts from here
        options.add(new SelectOption(MassCreateBundleOppConstants.SOUTHWIND,MassCreateBundleOppConstants.CONSULTING_AND_MANAGEMENT));
        //Ends here
        
        return options;
    }
    
    //Standard Controller
    public MassCreateBundleOpportinities_Ext(ApexPages.standardController stdController) {
        
        //Getting record details whom Id is there in URL parameters
        bundle = (Bundle__c)stdController.getRecord();
        
        //List to hold the bundle record details
        bundles = [SELECT ID, Name, Account__c, Account__r.Name, Program__c, Total_Count__c, Open_Count__c, Earliest_Stage__c,
                        Earliest_Close__c, Latest_Close__c, Latest_Stage__c, Lost_Count__c, Lost_Value__c,
                        Prorated_Open_Value__c, Won_Count__c, Won_Value__c, Growth__c, Margin__c, Population_Health__c,
                        Total_Value__c, Open_Value__c, OwnerId FROM Bundle__c WHERE ID =: bundle.ID];
        
        //Checking list for its size value
        if(bundles != null && bundles.size() > 0) {
            
            //Assigning updated instance to the variable
            bundle = bundles[0];
        
            //Memory allocation to wrapper list
            recordTypes = new List<RecordTypeWrapper>();
            bSibling = new Bundled_Siblings__c();
            
            //Setting default rendering settings for the page
            settingFlagsForDefaultRendering();
            displayIconAndlink = false;
            isHavingErrors = false;
            
            //Calling method to set the defaults on page load
            inIt();
            
        } else {
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, System.Label.Message_No_Bundle_Found));
        }
    }
    
    /**
    *   @description    :   Method to set the boolean flags helpful in setting default rendering on the page.
    *
    *   @args           :   void
    *
    *   @return         :   void
    *
    **/
    public void settingFlagsForDefaultRendering() {

        //Setting by default value for the flags
        isDisplayNewOppRdTypeSelectionSection = false;
        isDisplayDefaultSections = true;
        isDisplayAddExistingOppSection = false;
    }
    
    /**
    *   @description    :   Method to perform default logic on page load.
    *
    *   @args           :   void
    *
    *   @return         :   void
    *
    **/
    public void inIt() {
        
        //Memory allocation to the wrapper list's
        existingBundledOpportunities = new List<MassCreateBundleOpportunityWrapper>();
        
        //Set to hold the record types developer name string literals
        recordTypesDeveloperNames = new Set<String>();
        recordTypesDeveloperNames.add(MassCreateBundleOppConstants.PT_MARKETING);
        recordTypesDeveloperNames.add(MassCreateBundleOppConstants.RI_MARKETING);
        recordTypesDeveloperNames.add(MassCreateBundleOppConstants.SOUTHWIND);
        
        //Populating map's with record types details
        mapRecordTypes = new Map<Id, RecordType>();
        mapRecordTypeNameWithID = new Map<String, ID>();
        for(RecordType rdType : [SELECT ID, DeveloperName, Name, Description FROM RecordType 
                                    WHERE DeveloperName IN : recordTypesDeveloperNames AND IsActive = true
                                    AND sObjectType =: MassCreateBundleOppConstants.OPPORTUNITY]) {
            mapRecordTypes.put(rdType.id, rdType);
            mapRecordTypeNameWithID.put(rdType.DeveloperName.trim(), rdType.ID);
            recordTypes.add(new RecordTypeWrapper(rdType.Name, rdType.Description));
        }
            
        //Load existing bundled opportunites
        if(bundle.Id != null)
            loadExistingBundledOpportunities(bundle.Id);
    }
    
    /**
    *   @description    :   Method to do the update on newly created opportunity record for populating bundle lookup on it 
    *                       with the help of URL parameters.
    *
    *   @args           :   void
    *
    *   @return         :   void
    *
    **/
    public pagereference linkingNewOpportunityToBundle() {
    
        System.debug('@@@@@@@ new Id value ' + ApexPages.currentPage().getParameters().get(MassCreateBundleOppConstants.NEW_ID));
        //Checking for the bundle Id and newly opportunity Id parameters in the URL
        if(String.isNotBlank(ApexPages.currentPage().getParameters().get(MassCreateBundleOppConstants.NEW_ID))
            && String.isNotBlank(ApexPages.currentPage().getParameters().get(MassCreateBundleOppConstants.ID_Paramter))) {
            
            //Popualting bundle lookup on the newly created opportunity record
            Opportunity opp = new Opportunity(ID = ApexPages.currentPage().getParameters().get(MassCreateBundleOppConstants.NEW_ID));
            opp.Bundle__c = ApexPages.currentPage().getParameters().get(MassCreateBundleOppConstants.ID_Paramter);
            
            //Setting the flag value
            OpportunityTriggerHelper.EXECUTE_TRIGGER_BEFORE_UPDATE = true;
            OpportunityTriggerHelper.EXECUTE_TRIGGER_AFTER_UPDATE = true;
                    
            //try to update the opportunity record
            try {
                update opp;
                
                //Loading the VF page again for keeping the page variables updated after the update happens for newly added opportunity
                return navigateBackToDefaultPage();
                
            } catch(Exception ex) {
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, ex.getMessage()));
                return null;       
            }
        }
        return null;
    }
    
    /**
    *   @description    :   This method is responsible to return all the existing bundled opportunities related to selected Bundle record.
    *
    *   @args           :   Id bundleId
    *
    *   @return         :   void
    *
    **/
    public void loadExistingBundledOpportunities(Id bundleId) {
        
        try {
        
            //Proceed with below logic only if eligible record type exists in the system
            if(mapRecordTypes != null && mapRecordTypes.values().size() > 0) {
            
                //Intermediate variables
                Integer a = 0;
                
                String sOQLString = '';
                sOQLString += MassCreateBundleOppUtility.dynamicBuildingOpportunityQueryString();
                sOQLString += ' WHERE Bundle__c != null AND ';
                sOQLString += ' Bundle__c = \'' + bundleId + '\'';
                sOQLString += ' ORDER BY CloseDate DESC';
                System.debug('@@@@@@@ sOQLString ' + sOQLString);
                
                //Query all already bundled opportunities and then accordingly populating the wrapper list                        
                for(Opportunity opp : Database.query(sOQLString)) {
                                            
                    //Checking record type for its eligiblity
                    if(mapRecordTypes.get(opp.RecordTypeId) != null) {
                        existingBundledOpportunities.add(new MassCreateBundleOpportunityWrapper(false, opp, a, false));
                        a++;
                    }       
                }
            }
        } catch(Exception ex) {
                
            //In case of exception adding it to page for user convinience
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, ex.getMessage()));
        }
    }
    
    /**
    *   @description    :   Method for navigating user to the Opportunity record type selection custom screen for creating a new record.
    *
    *   @args           :   void
    *
    *   @return         :   void
    *
    **/
    public void navigateToNewOppRecordTypeSelection() {
        
        //Setting by default value for the flags
        isDisplayNewOppRdTypeSelectionSection = true;
        isDisplayDefaultSections = false;
        isDisplayAddExistingOppSection = false;
    }
    
    /**
    *   @description    :   Method for navigating user to opportunity standard page, on click at "Continue" button at page after record type selection. 
    *
    *   @args           :   void
    *
    *   @return         :   pagereference
    *
    **/
    public Pagereference naviagteToOpportunityEditPage() {
        
        //Checking if user have selected a valid value on the page for new opportunity record type
        if(String.isNotBlank(selectedRdType)) {
        
            //Setting opportunity record type value
            if(mapRecordTypeNameWithID != null && mapRecordTypeNameWithID.get(selectedRdType) != null) {
            
                pageRef = new Pagereference(MassCreateBundleOppConstants.OPP_EDIT_PAGE_INITIAL_PREFIX);
                pageRef.getParameters().put(MassCreateBundleOppConstants.RECORD_TYPE, mapRecordTypeNameWithID.get(selectedRdType));
                pageRef.getParameters().put(MassCreateBundleOppConstants.RETURL_URL, MassCreateBundleOppConstants.RETURN_PAGE_URL + bundle.id);
                pageRef.getParameters().put(MassCreateBundleOppConstants.SAVE_URL , MassCreateBundleOppConstants.RETURN_PAGE_URL + bundle.id);
                if(bundle.Account__c != null) {
                    pageRef.getParameters().put('opp4_lkid' , bundle.Account__c);
                    pageRef.getParameters().put('opp4' , bundle.Account__r.Name);
                }
                pageRef.setRedirect(true);
                return pageRef;
            } else {
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, System.Label.Message_Record_Type_Not_Exists));
                return null;
            }
        } else {
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, System.Label.Message_Wrong_WIth_RdType_Selection));
            return null;
        }
    }
    
    /**
    *   @description    :   Method to naviagte the user back to default VF page with complete page load. 
    *
    *   @args           :   void
    *
    *   @return         :   pagereference
    *
    **/
    public Pagereference navigateBackToDefaultPage() {
        pageRef = Page.MassCreateBundleOpportunities;
        pageRef.getParameters().put('id', bundle.id);
        pageRef.setRedirect(true);
        return pageRef;
    }
    
    /**
    *   @description    :   Method to naviagte user to "Add Opportunity" page and setting flag values for desired rendering on the page. 
    *
    *   @args           :   void
    *
    *   @return         :   void
    *
    **/
    public void navigateToAddExistingOppPage() {
    
        //Setting by default value for the flags
        isDisplayNewOppRdTypeSelectionSection = false;
        isDisplayDefaultSections = false;
        isDisplayAddExistingOppSection = true;
        
        //Re-Initializing variables
        bSibling = new Bundled_Siblings__c();
    }
    
    /**
    *   @description    :   Method to hold the logic for adding selected opportunity onto the associated bundle. 
    *
    *   @args           :   void
    *
    *   @return         :   pagereference
    *
    **/
    public pagereference addSelectedOpportunityToBundle() {
    
        //Checking if have selected an opportunity through the lookup
        if(bSibling.From__c != null) {
        
            //Current wrapper list size
            Integer b = existingBundledOpportunities.size();
            Map<Id, MassCreateBundleOpportunityWrapper> mapExistingOpportunities = new Map<Id, MassCreateBundleOpportunityWrapper>();
            
            //Loop through wrapper list and accordingly populating the records
            for(MassCreateBundleOpportunityWrapper exOpp : existingBundledOpportunities) {
                if(exOpp.Opportunity != null && exOpp.Opportunity.Id != null)
                    mapExistingOpportunities.put(exOpp.Opportunity.Id, exOpp);
            }
            
            //Checking if selected opportunity is already added to current bundle
            //If yes, then showing message to the users on page for convinience
            if(mapExistingOpportunities.containsKey(bSibling.From__c)) {
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, System.Label.Message_Opp_Already_Added));
                return null;
            } else {
                
                //Building query string
                String sOQLStr = MassCreateBundleOppUtility.dynamicBuildingOpportunityQueryString();
                sOQLStr += ' WHERE ID = \'' + bSibling.From__c + '\'';
                sOQLStr += ' LIMIT 1';
                System.debug('@@@@@@ sOQLStr ' + sOQLStr);
                
                //making query for the opportunity record and then addding it to the wrapper list
                try {
                    
                    //Re-Initialization opportunity records list
                    opportunitiesForUpsert = new List<Opportunity>();
                    
                    //Making a query for opportunity record and stamping bundle as parent on it
                    Opportunity opp = Database.query(sOQLStr);
                    opp.Bundle__c = bundle.Id;
                    existingBundledOpportunities.add(new MassCreateBundleOpportunityWrapper(false, opp, b, false));
                    opportunitiesForUpsert.add(opp);
                
                    //Checking list for its size value
                    if(opportunitiesForUpsert.size() > 0) {
                
                        try {
            
                            //Setting flag values
                            OpportunityTriggerHelper.EXECUTE_TRIGGER_BEFORE_UPDATE = true;
                            OpportunityTriggerHelper.EXECUTE_TRIGGER_AFTER_UPDATE = true;

                            //Update Opportunity record
                            update opportunitiesForUpsert;
                
                            //Retrieving Bundle latest details and then performing update on it
                            bundles = [SELECT ID, Name, Account__c, Program__c, Total_Count__c, Open_Count__c, Earliest_Stage__c,
                                        Earliest_Close__c, Latest_Close__c, Latest_Stage__c, Lost_Count__c, Lost_Value__c,
                                        Prorated_Open_Value__c, Won_Count__c, Won_Value__c, Growth__c, Margin__c, Population_Health__c,
                                        Total_Value__c, Open_Value__c, OwnerId  FROM Bundle__c WHERE ID =: bundle.ID];
                            bundle = bundles[0];
                            
                            //Redirecting user back to main VF page
                            return navigateBackToDefaultPage();
                         
                        } catch(Exception e) {
            
                            //In case of exception adding it to page for user convinience
                            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, e.getMessage()));
                            return null;
                        }
                    }
                } catch(Exception ex) {
            
                    //In case of exception adding it to page for user convinience
                    ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, ex.getMessage()));
                    return null;
                }   
            }
        
        } else {
            
            //Redirecting user back to main VF page
            return navigateBackToDefaultPage();
        }
        
        //return null
        return null;
    }
    
    /**
    *   @description    :   Method to hold the logic for removing the selected opportunity from the associated bundle. 
    *
    *   @args           :   void
    *
    *   @return         :   pagreference
    *
    **/
    public pagereference removeSelectedBundledOpportunities() {
    
        //Wrapper list of Bundled Opportunities
        List<MassCreateBundleOpportunityWrapper> wrapperList = new List<MassCreateBundleOpportunityWrapper>();
            
        //Making a clone
        wrapperList = existingBundledOpportunities;
        
        //Re-Intialization for wrapper list
        existingBundledOpportunities = new List<MassCreateBundleOpportunityWrapper>();
        
        //Set to hold the opportunity ids
        Set<Id> setOppIds = new Set<Id>();
        
        //Loop through wrapper list of bundled opportunities
        for(MassCreateBundleOpportunityWrapper wrp : wrapperList) {
            //Checking for the checkbox selection
            if(!wrp.selected) {
                existingBundledOpportunities.add(wrp);
            } else {
                if(wrp.opportunity.Id != null)
                    setOppIds.add(wrp.opportunity.Id);
            }
        }
        
        //Checking set for its size value
        if(setOppIds.size() > 0) {
        
            //Initializing opportunities record list
            opportunitiesForUpsert = new List<Opportunity>();
            
            //Loop through selected opportunity records
            for(Opportunity opp : [SELECT ID, StageName, Bundle__c FROM Opportunity WHERE ID IN : setOppIds]) {
                opp.Bundle__c = null;
                opportunitiesForUpsert.add(opp);    
            }
            
            //Checking list for its size value
            if(opportunitiesForUpsert.size() > 0) {
                try {
                
                    //Setting flag values
                    OpportunityTriggerHelper.EXECUTE_TRIGGER_BEFORE_UPDATE = true;
                    OpportunityTriggerHelper.EXECUTE_TRIGGER_AFTER_UPDATE = true;
                    
                    //Update Opportunities for remiving there bundle__c references from them
                    update opportunitiesForUpsert;
                    
                    //Re-Initailization of the wrapper list & making a clone
                    wrapperList = new List<MassCreateBundleOpportunityWrapper>();
                    wrapperList = existingBundledOpportunities;
                    existingBundledOpportunities = new List<MassCreateBundleOpportunityWrapper>();
                    
                    //Loop throug wrapper list
                    for(Integer i=0; i < wrapperList.size(); i++) {
                        MassCreateBundleOpportunityWrapper wrapInstance = wrapperList[i];
                        wrapInstance.rowNo = i;
                        existingBundledOpportunities.add(wrapInstance);
                    }
                    
                    //Retrieving Bundle latest details and then performing update on it
                    bundles = [SELECT ID, Name, Account__c, Program__c, Total_Count__c, Open_Count__c, Earliest_Stage__c,
                        Earliest_Close__c, Latest_Close__c, Latest_Stage__c, Lost_Count__c, Lost_Value__c,
                        Prorated_Open_Value__c, Won_Count__c, Won_Value__c, Growth__c, Margin__c, Population_Health__c,
                        Total_Value__c, Open_Value__c, OwnerId FROM Bundle__c WHERE ID =: bundle.ID];
                    bundle = bundles[0];
                    
                } catch(Exception e) {
                    
                    //In case of exception adding it to page for user convinience
                    ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, e.getMessage()));
                    return null;
                } 
            }
        }
        
        //return null value
        return null;
    }
    
    /**
    *   @description    :   Method to perform clone over the selected opportunity/opportunities records. 
    *
    *   @args           :   void
    *
    *   @return         :   void
    *
    **/
    public void cloneBundledOpportunity() {
        
        //Checking variable for null value which is there to hold row no for the wrapper list on which user have clicked
        //Clone button
        if(selectedRowNo != null) {
            
            //Wrapper instance - where clone button was hit by the user to perform the clonning
            MassCreateBundleOpportunityWrapper mw = existingBundledOpportunities[selectedRowNo];
            
            //Initializing opportunities record list
            opportunitiesForUpsert = new List<Opportunity>();
            opportunitiesForUpsert.add(mw.opportunity.clone(false));
            
            //Setting flag values
            OpportunityTriggerHelper.EXECUTE_TRIGGER_BEFORE_UPDATE = true;
            OpportunityTriggerHelper.EXECUTE_TRIGGER_AFTER_UPDATE = true;
        
            //Allow partial insert
            Database.UpsertResult[] results = Database.upsert(opportunitiesForUpsert,false);
            
            //Check if the record was created successfully
            if(results[0].isSuccess()) {
                
                //Mkaing a clone and adding it to the list at the last
                MassCreateBundleOpportunityWrapper cloneWrap = new MassCreateBundleOpportunityWrapper(mw.selected, opportunitiesForUpsert[0], existingBundledOpportunities.size(), false);
                existingBundledOpportunities.add(cloneWrap);
                
                //Re-Initailization of the variable
                selectedRowNo=null;
            
            } else {
                
                //Add error message
                existingBundledOpportunities[selectedRowNo].errorMessage = results[0].getErrors()[0].getMessage();
                existingBundledOpportunities[selectedRowNo].displayIconAndEditlink = true;
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Row#' + ' ' + (selectedRowNo+1) + ' - ' + existingBundledOpportunities[selectedRowNo].errorMessage + '\n'));
                displayIconAndlink = true;
            }
            
            //Retrieving Bundle latest details and then performing update on it
            bundles = [SELECT ID, Name, Account__c, Program__c, Total_Count__c, Open_Count__c, Earliest_Stage__c,
                        Earliest_Close__c, Latest_Close__c, Latest_Stage__c, Lost_Count__c, Lost_Value__c,
                        Prorated_Open_Value__c, Won_Count__c, Won_Value__c, Growth__c, Margin__c, Population_Health__c,
                        Total_Value__c, Open_Value__c, OwnerId FROM Bundle__c WHERE ID =: bundle.ID];
            bundle = bundles[0];
        }
    }
    
    /**
    *   @description    :   Method to commit the changes happens on the page to the database.
    *
    *   @args           :   void
    *
    *   @return         :   void
    *
    **/
    public void saveBundledOpportunities() {
    
        //List to hold the opportunity records
        opportunitiesForUpsert = new List<Opportunity>();
            
        //Loop through wrapper list and populating list of opportunity accordingly
        for(MassCreateBundleOpportunityWrapper mWrap : existingBundledOpportunities) {
            if(mWrap.opportunity != null)
                opportunitiesForUpsert.add(mWrap.opportunity);
        }
        
        //Checking list for its size value
        if(opportunitiesForUpsert.size() > 0) {
        
            //Map of bundle records
            Map<Id, Bundle__c> mapBundles = new Map<Id, Bundle__c>();
        
            //Setting flag values
            OpportunityTriggerHelper.EXECUTE_TRIGGER_BEFORE_UPDATE = true;
            OpportunityTriggerHelper.EXECUTE_TRIGGER_AFTER_UPDATE = true;
            isHavingErrors = false;
            
            //Allow partial insert
            Database.UpsertResult[] results = Database.upsert(opportunitiesForUpsert,false);
            
            //Process results for creating success and error file
            for(Integer i = 0; i < results.size(); i++) {
  
                //Result instance
                Database.UpsertResult result = results[i];
     
                //Check if the record was created successfully
                if(result.isSuccess()) {
                    existingBundledOpportunities[i].displayIconAndEditlink = false;
                    existingBundledOpportunities[i].errorMessage = null;
                    existingBundledOpportunities[i].opportunity = opportunitiesForUpsert[i];
                } else {
                    //Add error message
                    existingBundledOpportunities[i].errorMessage = result.getErrors()[0].getMessage();
                    existingBundledOpportunities[i].displayIconAndEditlink = true;
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Row#' + ' ' + (i+1) + ' - ' + existingBundledOpportunities[i].errorMessage + '\n'));
                    isHavingErrors = true;
                }
            }
                
            //Retrieving Bundle latest details and then performing update on it
            bundles = [SELECT ID, Name, Account__c, Program__c, Total_Count__c, Open_Count__c, Earliest_Stage__c,
                        Earliest_Close__c, Latest_Close__c, Latest_Stage__c, Lost_Count__c, Lost_Value__c,
                        Prorated_Open_Value__c, Won_Count__c, Won_Value__c, Growth__c, Margin__c, Population_Health__c,
                        Total_Value__c, Open_Value__c, OwnerId FROM Bundle__c WHERE ID =: bundle.ID];
            bundle = bundles[0];
            
            //Setting flag value
            displayIconAndlink = true;
        }
    }
    
    /**
    *   @description    :   Method to perform "Quick Save" on the page.
    *
    *   @args           :   void
    *
    *   @return         :   void
    *
    **/
    public void quickSaveAll() {
    
        //Saving Opportunities records
        saveBundledOpportunities();
    }
    
    /**
    *   @description    :   This method is responsible to perform "Save" over all the existing bundled opportunities & Bundle.
    *
    *   @args           :   void
    *
    *   @return         :   Pagereference
    *
    **/
    public Pagereference saveAll() {
        
        try {
            
            //Update Bundle Informations
            update bundle;
            
            //Perform Update over opportunity records too
            quickSaveAll();
        
            //Checking list for size and setting flag value
            if(existingBundledOpportunities.size() == 0)
                isHavingErrors = false;
            
            //Setting pagereference for redirecting back user to bundle detail page
            if(isHavingErrors)
                return null; 
            else        
                return cancelAll();
        
        } catch(Exception ex) {
                
            //In case of exception adding it to page for user convinience
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, ex.getMessage()));
            return null;
        }
    }
    
    /**
    *   @description    :   This method is responsible to hold the "Cancel" button logic with it.
    *
    *   @args           :   void
    *
    *   @return         :   Pagereference
    *
    **/
    public Pagereference cancelAll() {
        
        //Checking for the bundle Id value
        ////Setting pagereference for redirecting back user to bundle detail page or new bundle page
        if(bundle.Id != null) {
            if(String.isNotBlank(ApexPages.currentPage().getParameters().get(MassCreateBundleOppConstants.RETURL_URL)))
                pageRef = new Pagereference(ApexPages.currentPage().getParameters().get(MassCreateBundleOppConstants.RETURL_URL));
            else
                pageRef = new Pagereference(MassCreateBundleOppConstants.BACKSLASH + bundle.Id);
        } else {
            pageRef = new Pagereference(MassCreateBundleOppConstants.BUNDLE_RETURN_URL);
        }
        
        //Set redirect to true and navigate the user
        pageRef.setRedirect(true);
        return pageRef;
    }
    
    /**
    *   @description    :   Method for dynamically updating probability when selecting stage in the wrapper list of Bundled Opportunities. 
    *
    *   @args           :   void
    *
    *   @return         :   void 
    *
    **/
    public void changeStageNameInWrapperList() {
        
        try {
            
            //Checking for selected row value
            if(selectedRowNo != null) {
                
                //Checking & validating wrapper list
                if(existingBundledOpportunities != null && existingBundledOpportunities.size() > 0 
                    && (existingBundledOpportunities.size()-1) >= selectedRowNo
                    && existingBundledOpportunities[selectedRowNo].opportunity != null) {
                                
                    //String to hold the stage field value
                    String rowStageName = existingBundledOpportunities[selectedRowNo].opportunity.StageName;
                            
                    //Checking stage name for valid value
                    if(string.isNotBlank(rowStageName)) {
                        
                        //retrieving probability value corresponding to the stage name
                        Decimal probabilityValue = MassCreateBundleOppUtility.retrievingProbabilityForOpportunityStage(rowStageName);
                    
                        //Checking for value in the map
                        if (probabilityValue != null)
                            existingBundledOpportunities[selectedRowNo].opportunity.Probability = probabilityValue;
                        else
                            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, System.Label.INVALID_STAGE_VALUE));
                    }
                }
            }
        } catch(Exception ex) {
            //In case of exception adding it to page for user convinience
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, ex.getMessage()));
        }
    }
    
    //Wrapper class
    public class MassCreateBundleOpportunityWrapper {
        
        //Properties
        public boolean selected {get; set;}
        public Opportunity opportunity {get; set;}
        public integer rowNo {get; set;}
        public String errorMessage {get; set;}
        public Boolean displayIconAndEditlink {get; set;}
        
        //Calling condtructor
        public MassCreateBundleOpportunityWrapper(Boolean selected, Opportunity opportunity, Integer rowNo, Boolean displayIconAndEditlink) {
            
            //Setting defaults
            this.selected = selected;
            this.Opportunity = opportunity;
            this.rowNo = rowNo;
            this.displayIconAndEditlink = false;
        }
    }
    
    //Wrapper class for record type
    public class RecordTypeWrapper {
        
        //Variable to hold record type Name and Description
        public String RecordTypeName {get; set;}
        public String RecordTypeDescription {get; set;}
        
        //Constructor of wrapper class
        public RecordTypeWrapper(String RecordTypeName,String RecordTypeDescription) {
            
            this.RecordTypeName = RecordTypeName;
            this.RecordTypeDescription = RecordTypeDescription;
        }
    }
}