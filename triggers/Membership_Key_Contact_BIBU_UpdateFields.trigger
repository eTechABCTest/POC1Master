/*
    Purpose:    Set name of Membership record to "Left([First Name] [Last Name] - [Program Acronym] - [Role],80)"               
    
    Create By:          
    
    Last Modified By:   Nathan Banas (SAP) - 1/25/2011
    
    Current Version:    v1.2
    
    Revision Log:       v1.0 - () Created code
                        v1.1 - (NB-2011-01-25) - Added header, code comments, and reviewed code coverage
                        v1.2 - Modified By - Abhinav Sharma - 07/07/2014 - CR-20140618-5849 - Catch DML errors in triggers to reduce exception emails to SFAdmin
*/
trigger Membership_Key_Contact_BIBU_UpdateFields on Membership_Key_Contact__c (before insert, before update) {
    
    try {
    
        // Bypass process if this trigger was called by a batch or BypassAllTriggers
        if(Util.IsBatch || Util.BypassAllTriggers) return;
        
        // auto-generate subscriptions (CR-6629)
        SiteUserHelper.CreateAutoSubscriptions(trigger.new, trigger.oldMap);
        
        // List to store Membership Ids relating to the MKCs that spawned this trigger
        List<Id> MembershipIds = new List<Id>();
        
        // List to store Contact Ids relating to the MKCs that spawned this trigger
        set<id> ContactIds = new set<id>();
        
        // Map to store memberships for the MKCs that called this trigger
        List<Membership__c> Memberships = new List<Membership__c>();
        
        // Map to store the MKC's Membership Ids in a map w/ the MKC Id as the key
        map<id, id> mkcid2mid = new map<id, id>(); 
        
        // Loop through Membership_Key_Contacts that spawned this trigger
        for(Membership_Key_Contact__c mkc : Trigger.New)
        {
            // If the Membership Key Contact has a Membership assigned, process
            if(mkc.Membership__c != null)
            {
                // Add the MKC's Membership Id to a list
                MembershipIds.add(mkc.Membership__c);
                
                // Add the MKC's Contact Id to a list
                contactIds.add(mkc.Contact__c);
                
                // Add the MKC's Membership Id to a map w/ the MKC Id as the key
                mkcid2mid.put(mkc.id, mkc.Membership__c);
            }
        }
        
        // Query all Memberships related to the MKC's that spawned this trigger
        Memberships = [select Id, Program__c, Program__r.Program_Acronym__c from Membership__c where Id in :MembershipIds];
        
        // Map to store Memberships w/ their Id as the key
        map<id, Membership__c> memid2memmap = new map<id, Membership__c>(Memberships);
        
        // Query all Contacts and store them in a Map w/ their Id as the key
        map<id, Contact> conid2conmap = new map<id, Contact>([select FirstName, LastName from Contact where id in :contactIds]);
        
        System.Debug('### Memberships Found: ' + Memberships.size() + ' ###');
        
        // Process only if there are memberships related to the MKCs that called this trigger
        if(Memberships.size() > 0)
        {
            // Get the max field length of the MKC Name field (should be 80)
            Integer maxnamelength = Membership_Key_Contact__c.Name.getDescribe().getLength();
            
            // Loop through each MKC
            for(Membership_Key_Contact__c mkc : Trigger.New)
            {
                // If the trigger was called by an Insert action or the trigger was called by an Update action
                // and the MKC's Contact, Membership, or Role has changed, then process 
                if(Trigger.isInsert ||
                    (Trigger.isUpdate && (mkc.Contact__c != Trigger.oldmap.get(mkc.id).Contact__c ||
                    mkc.Membership__c != Trigger.oldmap.get(mkc.id).Membership__c ||
                    mkc.Role__c != Trigger.oldmap.get(mkc.id).Role__c)))
                {
                    //Make name for Membership record: Left([First Name] [Last Name] - [Program Acronym] - [Role],80)
                    String longname = ' ';
                    
                    // If the MKC has a Contact, start setting the new Name field
                    if (mkc.Contact__c != null)
                    {
                        // Set the first part of the Long Name (<First Name>)
                        if (conid2conmap.get(mkc.Contact__c).FirstName != null)
                            longname += conid2conmap.get(mkc.Contact__c).FirstName;
                        
                        // Set the second part of the Long Name (<Last Name>)   
                        if (conid2conmap.get(mkc.Contact__c).LastName != null)
                            longname += ' ' + conid2conmap.get(mkc.Contact__c).LastName;
                        
                        // Add a seperator ( - ) to the Name
                        longname +=  ' - ';
                    }
                    
                    // If the MKC has an associated Membership, and that Membership has a Program whose Acronym is not Null then add the Program Acronym to the new Name
                    if (mkc.Membership__c != null && memid2memmap.get(mkc.Membership__c).Program__c != null && memid2memmap.get(mkc.Membership__c).Program__r.Program_Acronym__c != null) 
                        longname += memid2memmap.get(mkc.Membership__c).Program__r.Program_Acronym__c;
                    
                    // If the MKC has a Role, then add a separator then the Role to the new Name
                    if (mkc.Role__c != null)
                        longname += ' - ' + mkc.Role__c;
                    
                    // Perform field truncation to ensure the new name does not go over the max length of the Name field (should be max 80)
                    mkc.name = longname.substring(0,Math.min(maxnamelength, longname.length()));
                }
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