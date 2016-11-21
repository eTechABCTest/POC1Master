trigger Contact_Restriction_Status on Contact (before insert, before update, after update)
{
    /*
Purpose:    Set Contact Restriction Status on inserted records based on Account Restricted Status

Create By:  Jeremy Nottingham (SAP) 12/2010        

Last Modified By:   Jeremy Nottingham (SAP) 2/14/2011

Current Version:    v1.6

Revision Log:       v1.0 - () Created code
v1.1 - (NB-2011-01-25) - Added header, code comments, and reviewed code coverage
v1.2 - (JN 2/14/2011) - removed "After Update" from trigger. This will only run on a new Contact record.
v1.3 - Bhavi - 06/14/2012 - Added after update event on trigger. 
Existing code work work as it is and it will run only for before events.
Delete  Key Member Contacts records if contact is not Active - CR-20120518-905
v1.4 - (VH 10/15/2013) - Updated populateContactTitleFromEvent method parameters
v1.5 - (VH 01/06/2014) - Added trackLoginHistory method - CR-20130816-3463
v1.6 - Modified By - Abhinav Sharma - 07/07/2014 - CR-20140618-5849 - Catch DML errors in triggers to reduce exception emails to SFAdmin
*/
    
    try {
        
        // if bypass all triggers is true, return without processing
        if (util.BypassAllTriggers || Util.BypassContactRestrictionTrigger) return;
        
        //Added condition by Bhavi - 06/14/2012 - Existing code will run only for before events
        if(Trigger.isBefore) {
            
            if (trigger.isBefore && trigger.isUpdate) {
                
                // bypass all triggers when updating the events;
                Util.BypassAllTriggers = true;
                ContactTriggerUtilities.PopulateContactTitleFromEvent(trigger.new, trigger.oldMap);
                //Calling helper class method to manage the restriction status
                ContactTriggerUtilities.UpdateRestrictionStatus(trigger.new);
                Util.BypassAllTriggers = false;
                
                //Bhavi - 12/18/2013 - CR-20130816-3463
                //SiteUserHelper.trackLoginHistory(trigger.new, trigger.old);
                
                Set<Id> accids = new Set<Id>();
                // Loop through Contacts and build a list of Account Ids
                for (Contact c: Trigger.new)
                {
                    // Only add the Account Id if the Contact has an Account
                    If (c.accountid != null)
                        accids.add(c.accountid);
                }
                // If there are Account Ids from the Contacts that spawned this trigger, then process
                if (accids.size() != 0)
                {   
                    // Get a map of Accounts relating to these Contacts w/ the Account Id as the key
                    Map<Id, Account> allaccounts = new Map<Id, Account> ([select id, Account_Restriction_Status__c from account where Id in :accids ]);
                    
                    // Loop through Contacts that spawned this trigger
                    for (Contact c: Trigger.new)
                    {
                        // If the Contact has an account, then process it
                        if (c.accountid != null)
                        {
                            // Get the Account Restriction Status value and assign it to a variable
                            string s = allaccounts.get(c.accountid) != null ? allaccounts.get(c.accountid).Account_Restriction_Status__c : null;
                            
                            // If the Account has a restriction, add it to the Contact
                            if (s != null)
                                c.Contact_Restriction_Status__c =  'Account - '+ s.substring(0,Math.min(s.length(), 70)); // maximum length = 80, and "account - " = 10 letters         
                        }
                    }
                }
            }
        } else if(Trigger.isAfter) {
            
            //Check for the update event
            if(Trigger.isUpdate) {
                
                //Call the helper class methid to delete the Membership Key Contact related to the InActive Contacts
                ContactTriggerUtilities.deleteKeyMemberContactsForInActiveContacts(Trigger.New);            
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