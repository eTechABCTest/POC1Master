/*
 *  Purpose         :   This class is helper class for trigger on Restriction object.
 *              
 *  Created By      :   Simplyforce Technology
 *  
 *  Created Date    :   10/08/2011
 *  
 *  Current Version :   v1.0
 *  
 *  Revision Log    :   v1.0 - Created
 *                      v1.1 - Bhavi - 02/02/2013 - Added new method(deleteRelatedMtMsAndUpdateAccountContact) - CR-20121212-1890
                        v1.2 - Ajit Surana - 03/7/2014 - CR-20140204-4450 - Update the RestrictionTriggerHelper to withoutSharing mode.
                        v1.3 - Ajit Surana - 03/10/2014 - CR-20140204-4450 - Code modified (DeleteProcess)
						v1.4 - Modified By - Mahendra Swarnkar - 05/19/2016 - CR-20160512-9853
*/
public without sharing class RestrictionTriggerHelper {

    //This method is to update the Owner_Details__c on Restrictions__c record 
    //with the value of actual Ownerid field
    public static void updateOwnerDetailsField(List<Restrictions__c> restrictions) {
        
        //loop through the restrictions and copy the owner id value to owner details field
        for(Restrictions__c restriction : restrictions) {
            
            //copy owner id value
            restriction.Owner_Details__c = restriction.OwnerId;
        }
    }
    
    // set whether or not the retriction is expired.
    public static void SetExpiration(List<Restricted_MtM__c> triggerNew) {
        for (Restricted_MtM__c rmtm : triggerNew) {
            if (rmtm.Run_Trigger__c) rmtm.Run_Trigger__c = false;

            if ((rmtm.Restriction_Expired__c) && (rmtm.Restriction_Expiration_Date__c >= Date.today())) {
                rmtm.Restriction_Expired__c = false;
            }   // DAF - added 11/15/11 - mark MtM as unexpired
        }
    }
    
    // delete
    public static void DeleteProcess(Map<Id, Restricted_MtM__c> triggerMap) {
        Set<Id> accountIds = new Set<Id>();
            Set<Id> contactIds = new Set<Id>();
            for (Restricted_MtM__c rMTM : triggerMap.values()) {
                //rMTM.Restriction__c = null;
                if (rMTM.Account__c != null) accountIds.add(rMTM.Account__c);
                if (rMTM.Contact__c != null) contactIds.add(rMTM.Contact__c);
            }
            
            //Updated by Ajit Surana -03/10/2014 - CR-20140204-4450
            //On deleting RestricitionMtM record both Account & Contact Restriction Status is set to null.
            //Query to retreive all account and contact records
            List<Account> acctList = [SELECT Account_Restriction_Status__c FROM Account WHERE Id IN :accountIds];
            
            List<Contact> conList = [SELECT Contact_Restriction_Status__c FROM Contact WHERE Id IN :contactIds OR AccountId IN: accountIds];
            
            //Go through each record and remove the restriction status
            for (Account a : acctList)
                a.Account_Restriction_Status__c = '';
            for (Contact c : conList)
                c.Contact_Restriction_Status__c = '';
            
            //Update all records
            if (acctList.size() > 0)
                update acctList;
            
            if (conList.size() > 0)
                update conList;
            
            // if it is delete, remove the restriction status and update all active restriction MTMs on the account/contact
            List<Contact> deletedMTMContacts = [SELECT Id, Contact_Restriction_Status__c,
                                            (SELECT Id FROM Restrictions_MtM__r WHERE Id NOT IN :triggerMap.keySet() LIMIT 1)
                                             FROM Contact WHERE Id IN :contactIds];
            List<Account> deletedMTMAccounts = [SELECT Id, Account_Restriction_Status__c,
                                            (SELECT Id FROM Restrictions_MtM__r WHERE Id NOT IN :triggerMap.keySet() LIMIT 1)
                                             FROM Account WHERE Id IN :accountIds];
            
            List<Restricted_MtM__c> activeRestrictions = new List<Restricted_MtM__c>();
            
            // first, update the contacts/accounts with no restriction status
            for (Contact c : deletedMTMContacts) {
                c.Contact_Restriction_Status__c = '';
                if (c.Restrictions_MtM__r.size() > 0)
                    activeRestrictions.addAll(c.Restrictions_MtM__r);
            }
            if (deletedMTMContacts.size() > 0)
                update deletedMTMContacts;
            
            for (Account a : deletedMTMAccounts) {
                a.Account_Restriction_Status__c = '';
                if (a.Restrictions_MtM__r.size() > 0)
                    activeRestrictions.addAll(a.Restrictions_MtM__r);
            }
            if (deletedMTMAccounts.size() > 0)
                update deletedMTMAccounts;

            if (activeRestrictions.size() > 0)
                update activeRestrictions;
    }
    
    public static void UpdateRelatedMtMsAndUpdateAccountContact(Map<Id, Restrictions__c> mapOldRestrictions) {
        
        //Find out how many records are going to be updated - CR-2712
        List<Restricted_MtM__c> resMtMs = [SELECT Id, Account__c, Contact__c FROM Restricted_MtM__c WHERE Restriction__c IN :mapOldRestrictions.keySet()];
        
        // get all account and contact ids
        Set<id> acctIds = new Set<Id>();
        Set<id> conIds = new Set<Id>();
        for (Restricted_MtM__c rmtm : resMtMs) {
            if (rmtm.Account__c != null) acctIds.add(rmtm.Account__c);
            else if (rmtm.Contact__c != null) conIds.add(rmtm.Contact__c);
        }
        Integer numContacts = [SELECT COUNT() FROM Contact WHERE (AccountId IN :acctIds OR Id IN :conIds)];
        
        // if we have more than 10,000 records to update, use the batch method
        Integer totalRecords = numContacts + conIds.size() + acctIds.size();
        if (totalRecords > 2000) {
            if (!System.isFuture() && !System.isBatch())
                database.executeBatch(new Batch_RestrictionUpdate(trigger.newMap.keySet()), 1);
        } else {
            //Check for the size
            if(resMtMs.size() > 0)
                update resMtMs;
        }
    }
    
    //This method is to update the Account and Contact on Restriction delete
    public static void deleteRelatedMtMsAndUpdateAccountContact(Map<Id, Restrictions__c> mapOldRestrictions) {
        
        //fetch all the related MtMs
        Map<Id, Restricted_MtM__c> restMTMs = new Map<Id, Restricted_MtM__c>([SELECT Id, Account__c, Contact__c FROM Restricted_MtM__c 
                                                                                WHERE Restriction__c IN: mapOldRestrictions.keySet()]);
        
        //Process records for deleted restriction records
        if(restMTMs.size() > 0) {
            
            //This set is to hold the account Ids
            Set<Id> acctIds = new Set<Id>();
            
            //This set is to hold the contact Ids
            Set<Id> conIds = new Set<Id>();
            
            //Loop through the deleted restriction records
            for (Restricted_MtM__c rMTM : restMTMs.values()) {
                
                //Check for the accout Id and add in set
                if (rMTM.Account__c != null) 
                    acctIds.add(rMTM.Account__c);
                
                //Check for the contact Id and add in set
                if (rMTM.Contact__c != null) 
                    conIds.add(rMTM.Contact__c);
            }
            
            // get all accounts and contacts associated with this restriction
            List<Account> accts = [SELECT Account_Restriction_Status__c FROM Account WHERE Id IN :acctIds];
            List<Contact> cons = [SELECT Contact_Restriction_Status__c FROM Contact WHERE Id IN :conIds];
            
            //If we have more than 10,000 records, update via batch -- otherwise continue processing CR-2712
            Integer totalRecords = accts.size() + cons.size() + restMTMs.size();
            
            //Modified By - Mahendra Swarnkar - 05/19/2016 - CR-20160512-9853
            if (totalRecords > 2000 && !system.isBatch() && !system.isFuture()) {
                Batch_RestrictionUpdate batch = new Batch_RestrictionUpdate(restMTMs.keySet());
                batch.IsDelete = true; // flag this as a deletion batch
                database.executeBatch(batch, 1);
                // return immediately
                return;
            }
            
            // go through each record and remove the restriction status
            for (Account a : accts)
                a.Account_Restriction_Status__c = '';
            for (Contact c : cons)
                c.Contact_Restriction_Status__c = '';
            
            // set flags so we bypass triggers
            Util.BypassAllTriggers = true;
            CRMfusionDBR101.DB_Globals.triggersDisabled = true;
            
            // update them
            if (accts.size() > 0)
                update accts;
            if (cons.size() > 0)
                update cons;
            
            Util.IsBatch = false;
            Util.BypassAllTriggers = false;
            
            // deleting these restriction mtm records will properly update the associated institution/contact
            delete restMTMs.values();
            CRMfusionDBR101.DB_Globals.triggersDisabled = false;        
        }
    }
}