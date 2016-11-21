trigger Restrictions_NamingConvention on Restrictions__c (before insert, before update, after update, before delete)    
{
    /*
    Purpose:    Populate Restriction Name
                    Restriction Name should be: "<CatagoryName>-<Owner's Name>"
                If this Restriction is "Retired", update all Restriction Mtm records
    
    Create By:  Mike Lofquist (SAP)         
    
    Last Modified By:   Nathan Banas (SAP) - 1/24/2011
    
    Current Version:    v1.1
    
    Revision Log:       v1.0 - (AW) Created code
                        v1.1 - (NB-2011-01-24) Added header, code comments, and reviewed code coverage
                        v1.2 - Bhavi - 02/02/2013 - CR-20121212-1890     
                        v1.3 - Modified By - Abhinav Sharma - 07/07/2014 - CR-20140618-5849 - Catch DML errors in triggers to reduce exception emails to SFAdmin                   
*/
    try {
    
        /*  Naming Convention  */
        // return immediately without processing if either of these are true
        if (Util.BypassAllTriggers) return;
        
        if (Trigger.IsBefore && !trigger.isDelete) {
            // Create a list to store User Ids
            list <id> listUserIds = new list <id>();
                
            // Build a list of User Ids for the Restrictions calling this trigger
            for (Restrictions__c restriction : trigger.new)
            {
                listUserIds.add (restriction.OwnerID);        
            }
            
            // Query all associated User records for the Restrictions calling this trigger
            list <user> listUsers = [SELECT id, name FROM user WHERE id IN :listUserIds];
            
            // Loop through each Restriction record and set the name
            for (Restrictions__c restriction : trigger.new)
            {
                // Get the Restriction Catagory
                string categoryName = restriction.category__c;
                
                // Variable to store the Restriction Owner's Name
                string userName = '';
                
                // Loop through all associated users and get the name of the user for this restriction
                for (User u : listUsers)
                {
                    // If the current User's Id in the loop is equal to the current Restriction's Owner Id,
                    // then set the userName variable equal to the User's Name 
                    if (restriction.OwnerId == u.id)
                    {
                        userName = u.name;
                        break;
                    }        
                }
                
                // If the Restriction Name is not equal to "<CatagoryName>-<Owner's Name>" then set it
                if (restriction.name != categoryName+'-'+userName)
                    restriction.name = categoryName+'-'+userName;
            }
        } //end if Trigger.IsBefore
        
        
        /*  Deal with Retired restrictions  */
        /*if (Trigger.IsUpdate) {
            
            //Reset RunTrigger flag
            if (Trigger.IsBefore) {
                for (Restrictions__c r : Trigger.new) {
                    if (r.Run_Trigger__c) {
                        r.Run_Trigger__c = false;
                    }
                }
            }//end if Trigger.IsBefore
            
            //Initiate updates on all RMTMs on these restrictions
            if (Trigger.IsAfter) {
                set<id> restrictionids = new set<id>();
                for (Restrictions__c r : Trigger.new) {
                    restrictionids.add(r.id);
                }
                
                list<Restricted_MtM__c> rmtmstoupdate = [select id, Name, Run_Trigger__c from Restricted_MtM__c where Restriction__c in :restrictionids];
                
                //kick off triggers on all the rmtms attached to these restrictions
                if (rmtmstoupdate.size() > 0){
                    for (Restricted_MtM__c rmtm : rmtmstoupdate) {
                        rmtm.Run_Trigger__c = true;
                    }
                    update rmtmstoupdate;
                }
            } // end if Trigger.IsAfter
        } //end if Trigger.IsUpdate*/
        
        if (trigger.isAfter && !trigger.isDelete) {
            
            //CR-2712 - if we are updating more than 10,000 records, use a batch, otherwise process as usual
            RestrictionTriggerHelper.UpdateRelatedMtMsAndUpdateAccountContact(Trigger.oldMap);
            
            /*
            //Commented by Bhavi - 02/02/2013 - CR-20121212-1890
            //database.executeBatch(new Batch_RestrictionUpdate(trigger.newMap.keySet()), 1);
        
            //Added by Bhavi - 02/02/2013 - CR-20121212-1890
            //fetch all the restriction MtM records
            List<Restricted_MtM__c> resMtMs = [SELECT Id FROM Restricted_MtM__c WHERE Restriction__c IN :trigger.oldMap.keySet()];
            
            //Check for the size
            if(resMtMs.size() > 0)
                update resMtMs;
            */
            
        }
        
        if (trigger.isBefore && trigger.isDelete) {
            
            //Commented by Bhavi - 02/02/2013 - CR-20121212-1890
            // get all restriction mtm records
            /*Map<Id, Restricted_MtM__c> restMTMs = new Map<Id, Restricted_MtM__c>([SELECT Id FROM Restricted_MtM__c WHERE Restriction__c IN :trigger.oldMap.keySet()]);
            Batch_RestrictionUpdate batch = new Batch_RestrictionUpdate(restMTMs.keySet());
            batch.IsDelete = true; // flag this as a deletion batch
            database.executeBatch(batch, 1);*/
            
            //Added by Bhavi - 02/02/2013 - CR-20121212-1890
            RestrictionTriggerHelper.deleteRelatedMtMsAndUpdateAccountContact(Trigger.oldMap);
            
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