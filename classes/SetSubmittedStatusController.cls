/**
 *  Purpose         :   Apex class to hold the Personal Goal Status logic. This is used on the list view and detail page buttons.
 *                      
 *                      SDD Description :
 *                      Takes a list of Personal Goal IDs as a parameter, and updates the Status value of each to “Submitted”.
 *
 *                      Considerations:
 *                         Only applies the change if the record type is “Proposed Goal”
 *                         Only applies the change if the Status is “Available” or “Former”
 *                         After execution when launched from list view button, redirects to list view
 *                         After execution when launched from page detail button, redirects to detail page
 *
 *                      
 *  
 *  Created By      :   Subhash Garhwal
 * 
 *  Created Date    :   12/01/2015
 * 
 *  Revision Logs   :   V_1.0 - Created - CR-20151120-9407
 *                  :   V_2.0 - Modified By - Rajeev Jain - CR-20160115-9545 - To sync status of Goal snapshot when Proposed goal get submitted. 
 * 
 **/
public with sharing class SetSubmittedStatusController {
    
    //Variables
    public Personal_Goal__c personalGoal {get;set;}
    public List<Personal_Goal__c> personalGoals {get;set;}
    public String retURL {get;set;}
    
    //This constructor will use for individual PG button (Detail Page button)
    //Constructor
    public SetSubmittedStatusController(ApexPages.StandardController controller) {
        
        //Get Record
        personalGoal = (Personal_Goal__c)controller.getRecord();
        
        //Get Goal Template key prefix
        retURL = personalGoal.Id;
    }
    
    //This constructor will use for list view button
    //Construcotr
    public SetSubmittedStatusController(ApexPages.StandardSetController controller) {
        
        //Get Selected records
        personalGoals = (List<Personal_Goal__c>) controller.getSelected();
        
        //Get Goal Template key prefix
        retURL = Personal_Goal__c.sObjectType.getDescribe().getKeyPrefix();
    }
    
    /**
     *  @description    :   This method is used to set the status of the selected PGs
     *
     *  @args           :   
     *
     *  @return         :   Pagereference
     *
     **/
    public Pagereference setSubmittedStatus() {
        
        //Save point
        Savepoint sp = Database.setSavepoint();
        
        try {
            
            //List to hold the Personal Goals
            List<Personal_Goal__c> personalGoalsToUpdate = new List<Personal_Goal__c>();
            
            //Check for Personal Goal 
            if(personalGoals == null)
                personalGoals = new List<Personal_Goal__c>();
            
            //Check for Personal GOal
            if(personalGoal == null)
                personalGoal = new Personal_Goal__c();
            
            //Set to hold the snapshot Ids
            Set<Id> setSSIds = new Set<Id>();
            
            //Query through the Personal Goals
            for(Personal_Goal__c pG : [Select Id, Status__c, Primary_Goal__c, Primary_Goal__r.Active_Proposal__c, Active__c From Personal_Goal__c Where (Id IN : personalGoals OR Id =: personalGoal.Id)
                                              AND RecordType.DeveloperName =: ISSPConstants.PERSONAL_GOAL_RECORD_TYPE_PROPOSAL
                                              AND Status__c IN : ISSPConstants.SET_PERSONAL_GOAL_STATUS]) {
                
                //Update Personal Goal Status
                pG.Status__c = ISSPConstants.PERSONAL_GOAL_STATUS_SUBMITTED;
                
                //Check for SS
                if(!setSSIds.contains(pG.Primary_Goal__c)) {
                    
                    //Check for Perposed goal
                    if(pG.Active__c && pG.Primary_Goal__c != null && pG.Primary_Goal__r.Active_Proposal__c == pG.Id) {
                        
                        //Add SS Id in set
                        setSSIds.add(pG.Primary_Goal__c);
                        
                        //Add 
                        personalGoalsToUpdate.add(new Personal_Goal__c(Id = pG.Primary_Goal__c, Status__c = ISSPConstants.PERSONAL_GOAL_STATUS_SUBMITTED));
                    }
                }
                
                //Add Personal Goal in list
                personalGoalsToUpdate.add(pG);
                                             
            }
            
            //Check for list size
            if(personalGoalsToUpdate.size() > 0)
                update personalGoalsToUpdate;
            
            //return
            return new Pagereference('/' + retURL);
            
        } catch(Exception e) {
            
            //Roll Back changes
            Database.rollback(sp);
            
            //Add Error on page
            ApexPages.addMessages(e);
        }
        
        return null;
    }
}