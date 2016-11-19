/**
*  Description      :   Controller class to hold the logic behind removal of an existing tagged bundle from the selected opportunity record.
*
*  Created By       :   Abhinav Sharma
*
*  Created Date     :   09/19/2014
*
*  Revision Logs    :   V_1.0 - Created - CR-20140429-5272
*
**/ 
public with sharing class BundleRemoveController {
    
    //Opportunity
    public Opportunity opportunity {get; set;}
    
    //Calling Constructor
    public BundleRemoveController(ApexPages.standardController stdController) {
        
        //Popualting instance with opportunity record details is in current context
        opportunity = (Opportunity)stdController.getRecord();
    }
    
    /**
    *   @description    :   Method responsible for removing for Bundle from the selected opportunity record.
    *
    *   @args           :   void
    *
    *   @return         :   pagereference
    *
    **/
    public pagereference removeBundleFromOpportunity() {
        
        //Checking for the opportunity Id value
        if(opportunity.Id != null) {
            
            //Removing bundle from the opportunity and updating it
            opportunity.Bundle__c = null;
            opportunity.BundleName__c = null;
            try {
                update opportunity;
                return new pagereference(MassCreateBundleOppConstants.BACKSLASH + opportunity.Id);
            } catch(Exception ex) {
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, ex.getMessage()));
                return null;
            }
        } else {
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, System.Label.BundleRemoval_CL1));
            return null;
        }
    }
}