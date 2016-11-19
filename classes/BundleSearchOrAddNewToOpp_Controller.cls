/**
*  Description      :   Controller class to hold the logic behind tagging of an existing bundle or creating a new bundle will be stamped on selected opportunity with it.
*
*  Created By       :   Abhinav Sharma
*
*  Created Date     :   09/18/2014
*
*  Revision Logs    :   V_1.0 - Created - CR-20140429-5272
*
**/ 
public with sharing class BundleSearchOrAddNewToOpp_Controller {
    
    //Opportunity
    public Opportunity opportunity {get; set;}
    public Bundle__c bundle {get; set;}
    
    //Standard controller
    public BundleSearchOrAddNewToOpp_Controller(ApexPages.standardController stdController) {
        
        //Popualting instance with opportunity record details is in current context
        opportunity = (Opportunity)stdController.getRecord();
        
        //List to hold the opportunity Id
        List<Opportunity> opportunities = [SELECT ID, Bundle__c, AccountId FROM Opportunity WHERE ID =: opportunity.Id];
        
        //Checking list for null and size value
        if(opportunities != null && opportunities.size() > 0) { 
        
            //populating instance with the updated details
            opportunity = opportunities[0];
            
            //Memory allocation
            bundle = new Bundle__c();
            
            //Populating bundle instance with the default field value
            bundle.OwnerId = UserInfo.getUserId();
            //bundle.Name = MassCreateBundleOppConstants.WILL_AUTO_POPULATE;
            if(opportunity.AccountId != null)
                bundle.Account__c = opportunity.AccountId;
        } else {
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, System.Label.BundleSearch_CL1));
        }
    }
    
    /**
    *   @description    :   Method to hold the the "Cancel" button logic with it. 
    *
    *   @args           :   void
    *
    *   @return         :   pagereference
    *
    **/
    public pagereference doCancel() {
    
        //Parereference variable
        Pagereference pageRef;
    
        //Checking for the ID value in the URL
        if(opportunity.Id != null) {
            pageRef = new Pagereference(MassCreateBundleOppConstants.BACKSLASH + opportunity.Id);
        } else {
            pageRef = new Pagereference(MassCreateBundleOppConstants.OPPORTUNITY_RETURN_URL);
        }
        
        //Set redirect to true and navigate the user
        pageRef.setRedirect(true);
        return pageRef;
    }
    
    /**
    *   @description    :   Method to tag existing bundle record onto the selected opportunity record.
    *
    *   @args           :   void
    *
    *   @return         :   pagereference
    *
    **/
    public pagereference tagSearchedBundleToOpportunity() {
    
        //Checking for the selected Bundle value
        if(opportunity.Bundle__c != null) {
        
            //Setting flag values
            OpportunityTriggerHelper.EXECUTE_TRIGGER_BEFORE_UPDATE = true;
            OpportunityTriggerHelper.EXECUTE_TRIGGER_AFTER_UPDATE = true;
            
            //Tagging the searched Bundle record onto the opportunity record
            update opportunity;
            
            //return user to the opportunity details page
            return doCancel();
        
        } else {
            
            //In case of exception adding it to page for user convinience
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, Label.BundleSearch_CL2));
            return null;
        }
    
        //return user to the opportunity details page (In case Id was absent then to tab view)
        return doCancel();
    }
    
    /**
    *   @description    :   Method to tag existing bundle record onto the selected opportunity record.
    *
    *   @args           :   void
    *
    *   @return         :   pagereference
    *
    **/
    public pagereference addNewBundleAndThenTagItToOpportunity() {
    
        //Re-Intializing Bundle lookup value
        opportunity.Bundle__c = null;
        
        //make a try to insert the bundle record with user inputted details
        try {
            insert bundle;
            
            //In case of success, stamping the bundle as parent the opportunity record
            opportunity.Bundle__c = bundle.Id;
            
            //Make atry to do the tagging
            try {
                update opportunity;
            
            } catch(Exception e) {
        
                 //In case of exception adding it to page for user convinience
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, e.getMessage()));
                return null;   
            }
        } catch(Exception ex) {
        
             //In case of exception adding it to page for user convinience
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, ex.getMessage()));
            return null;   
        }
                
        //return user to the opportunity details page (In case Id was absent then to tab view)
        return doCancel();
    }
}