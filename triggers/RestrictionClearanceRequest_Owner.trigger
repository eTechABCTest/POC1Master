trigger RestrictionClearanceRequest_Owner on Restriction_Clearance_Request__c (before insert, after insert,  before update)
{
/*
    Purpose:    Populate the Owner of the RestrictionClearanceRequest from the associated Restriction's owner
                Restriction_Owner_2__c = Restriction__r.OwnerID
    
    Create By:  Mike Lofquist (SAP)         
    
    Last Modified By:   Nathan Banas (SAP) - 1/24/2011
    
    Current Version:    v1.1
    
    Revision Log:       v1.0 - (AW) Created code
                        v1.1 - (NB-2011-01-24) Added header, code comments, and reviewed code coverage
                        v1.2 - 11/07/2012 - Bhavi - CR-20120924-1526
                        v1.3 - Modified By - Abhinav Sharma - 07/07/2014 - CR-20140618-5849 - Catch DML errors in triggers to reduce exception emails to SFAdmin
*/
    try {
        
        //11/07/2012 - Bhavi - Condition added to execute the existing code only for before event
        if(Trigger.isBefore) {
        
            // List of Restriction Ids from RCRs calling this trigger
            Set<id> restids = new Set<id>();   
            
            // Build a list of Restriction Ids for the RCRs calling this trigger
            for (Restriction_Clearance_Request__c rcr: Trigger.new)
            {
                restids.add(rcr.Restriction__c);
            }
            
            // Map each restriction to it's Id
            Map<id, Restrictions__c> rests = new Map<id, Restrictions__c>([select id, ownerid from Restrictions__c where id in :restids ]);
            
            // If the Map of Restrictions isn't empty, process results 
            if (!rests.isempty())
            {
                // Loop through each RCR and populate Owner only if the Restriction Owner isn't null 
                for (Restriction_Clearance_Request__c rcr: Trigger.new)
                {
                    if (rcr.Restriction__c != null)
                    {
                        rcr.Restriction_Owner_2__c = rests.get(rcr.Restriction__c).ownerid;
                    }
                }       
            }
        } else {
            
            //11/07/2012 - Bhavi - CR-20120924-1526
            if(Trigger.isInsert) {
                
                //Call helper class method to update the related warm lead statsus accordingily
                RestrictionClearanceRequestHelper.updateWarmLeads(Trigger.New);
            }
        }
    //Catching DML Exceptions
    } catch(DMLException e) {

        //Add Error Message on Page
        if(Trigger.isDelete)
            Trigger.Old[0].addError(e.getDmlMessage(0));
        else
            Trigger.New[0].addError(e.getDmlMessage(0));

    //Catching all Exceptions
    } catch(Exception e) {

        //Add Error Message on Page
        if(Trigger.isDelete)
            Trigger.Old[0].addError(e.getMessage());
        else
            Trigger.New[0].addError(e.getMessage());
    }
}