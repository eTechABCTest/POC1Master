/**
 *  Desription      :   Standard Controller for Opportunity Detail Page.
 * 
 *  Created By      :   Abhinav Sharma
 * 
 *  Created Date    :   05/19/2016
 * 
 *  Revision Logs   :   V1.0 - Created - 05/19/2016 - CR-20160308-9682
 *
 **/ 
public with sharing class OpportunityControllerExtension {
    
    //Opportunity record
    public Opportunity opportunity {get; set;}
    
    //Standard Controller Constructor
    public OpportunityControllerExtension(ApexPages.StandardController stdController) {
    	opportunity = (Opportunity)stdController.getRecord(); 
    }
    
    //Added By Abhinav Sharma - 05/19/2016 - CR-20160308-9682
    /**
     *  @description    :   This future method will behave as "Onview trigger" for Opportunity Contact Role object.
     * 						Will keep "Main Contact" in sync with respect to the changes happened at OCR side.
     *
     *  @args           :    
     *
     *  @return         :   void
     *
    **/
    public void rollupOpportunityContactRoles() {
        OpportunityControllerExtension.rollupOpportunityContactsRolesFuture(opportunity.Id); 
    }
    
    //Future method to roll up values on opportunity record from the associated "Opportunity Contact Role" records
    @future(callout=false)
    public static void rollupOpportunityContactsRolesFuture(Id oppId)  {
        
        //Checking for the null value
        if(oppId != null) {
            
            //Opportunity instance
            List<Opportunity> opportunities = [Select ID, Main_Contact__c FROM Opportunity 
                                               	WHERE Id =: oppId];
            
            //Checking for null and size value
            if(opportunities != null && opportunities.size() > 0) {
                
                //Opportunity instance
                Opportunity opp = opportunities[0];

                //Allocate Memory to list
        		List<OpportunityContactRole> oppContactRole = new List<OpportunityContactRole>();
         
                //Fatching records from Opportunity Contact Role
                oppContactRole = [Select Id, ContactId From OpportunityContactRole 
                                    WHERE OpportunityId != null
                                    AND OpportunityId =: opp.Id
                                    AND IsPrimary = true];
            
                //Checking for size
                if(oppContactRole.size() > 0) {
                
                    //Checking for field value difference
                    if(oppContactRole[0].ContactId != opp.Main_Contact__c) {
                        opp.Main_Contact__c = oppContactRole[0].ContactId;
                        Util.BypassAllTriggers = true;
                        update opp;
                        Util.BypassAllTriggers = false;
                	} 
                    
            	} else {
                    
                    if(opp.Main_Contact__c != null) {
                        opp.Main_Contact__c = null;
                        Util.BypassAllTriggers = true;
                        update opp;
                        Util.BypassAllTriggers = false;
                    }
                }
            }
        }
    }
}