//02/04/2014 - Bhavi Sharma - New methods added (UpdateInteractionInformation) - CR-20140124-4353
//02/14/2014 - CR-20120823-1396 - Remove subquery in Batch_MeetingUtilizations = Method modified (UpdateMeetingSummary) and (FindMemberships)
//04/18/2014 - CR-20140331-4909 - Updates to batch failure process - Modify by - Abhinav Sharma
public without sharing class MeetingUtilities {
    
    // get the number of meetings in the last 12 months for a given list of Utilization records
    public static void UpdateMeetingSummary(Set<Id> membershipIds) {
        // get all of the membership/opportunity records we are going to update
        List<Membership__c> memberships = FindMemberships(membershipIds);
        // pass these memberships on to the method that is going to process them
        UpdateMeetingSummary(memberships);
    }
    
    public static String UpdateMeetingSummary(List<Membership__c> memberships) {
        
        /** Commented by Abhinav Sharma 
            Added new logic to remove SOQL queries **/
        // now we have all Memberships with Memberships.Opportunities and Memberships.Meeting_Utilizations
        /*for (Membership__c membership : memberships) {
            // clear out the existing count fields
            membership.Membership_Meeting_Util_last_12_Mo__c = 0;
            membership.Membership_Teleconf_Util_last_12_Mo__c = 0;
            membership.Next_Teleconf_Start_Date__c = null;
            membership.Next_Meeting_Start_Date__c = null;
            membership.Closest_Active_Meeting_End_Date__c = null;
            membership.Closest_Teleconf_End_Date__c = null;
            
            // set the number of meetings attended for this membership in the past 12 months
            // go through each membership to determine the next closest start/end date
            for (Meeting_Utilization__c meeting : membership.Meeting_Utilizations__r) {
                if (meeting.Start_Date__c < system.today())
                    membership.Membership_Meeting_Util_last_12_Mo__c++;
                
                if (membership.Next_Meeting_Start_Date__c == null && meeting.Start_Date__c >= system.today())
                    membership.Next_Meeting_Start_Date__c = meeting.Start_Date__c;
                else if (membership.Next_Meeting_Start_Date__c < meeting.Start_Date__c && meeting.Start_Date__c > system.today())
                    membership.Next_Meeting_Start_Date__c = meeting.Start_Date__c;
                
                if (membership.Closest_Active_Meeting_End_Date__c == null && meeting.End_Date__c >= system.today().addDays(-365))
                    membership.Closest_Active_Meeting_End_Date__c = meeting.End_Date__c;
                else if (membership.Closest_Active_Meeting_End_Date__c > meeting.End_Date__c)
                    membership.Closest_Active_Meeting_End_Date__c = meeting.End_Date__c;
            }
            for (Utilization_Data_Object__c teleconf : membership.Teleconference_Utilizations__r) {
                if (teleconf.Start_Date__c < system.today())
                    membership.Membership_Teleconf_Util_last_12_Mo__c++;
                
                if (membership.Next_Teleconf_Start_Date__c == null && teleconf.Start_Date__c >= system.today())
                    membership.Next_Teleconf_Start_Date__c = teleconf.Start_Date__c;
                else if (membership.Next_Teleconf_Start_Date__c < teleconf.Start_Date__c && teleconf.Start_Date__c > system.today())
                    membership.Next_Teleconf_Start_Date__c = teleconf.Start_Date__c;
                
                if (membership.Closest_Teleconf_End_Date__c == null && teleconf.End_Date__c >= system.today().addDays(-365))
                    membership.Closest_Teleconf_End_Date__c = teleconf.End_Date__c;
                else if (membership.Closest_Teleconf_End_Date__c > teleconf.End_Date__c)
                    membership.Closest_Teleconf_End_Date__c = teleconf.End_Date__c;
            }
            
            
        } 
        
        /***Upto Here*/
        
        //Added By Abhinav Sharma - 02/14/2014 - CR-20120823-1396 - Remove subquery in Batch_MeetingUtilizations
        
        //Map to hold "Membsership Id" as key and List<Meeting_Utilization__c> as value
        Map<Id, List<Meeting_Utilization__c>> mapMembershipWithMemberUtilizations = new Map<Id, List<Meeting_Utilization__c>>();

        //Loop through "Membership Utilization" records associated with membership record
        for(Meeting_Utilization__c mU : [Select Start_Date__c, End_Date__c, Id, Membership__c FROM Meeting_Utilization__c 
                                        WHERE (Start_Date__c >= LAST_N_DAYS:365) AND Membership__c IN : memberships]) {
    
            //Check if map already has a record for the membership, then add in existing list
            if(mapMembershipWithMemberUtilizations.containsKey(mU.Membership__c)) {
              
                //Get the Values of the Map and add record to it.
                mapMembershipWithMemberUtilizations.get(mU.Membership__c).add(mU);
            
            } else {
              
                //Create a new List at values and add record to it.
                mapMembershipWithMemberUtilizations.put(mU.Membership__c, new List<Meeting_Utilization__c>{mU});  
            }
        }
        
        //Map to hold "Membsership Id" as key and List<Utilization_Data_Object__c> as value
        Map<Id, List<Utilization_Data_Object__c>> mapMembershipWithTeleconferenceUtilizations = new Map<Id, List<Utilization_Data_Object__c>>();
    
        //Loop through "Membership Utilization" records associated with membership record
        for(Utilization_Data_Object__c tU : [SELECT ID, Start_Date__c, End_Date__c, Membership__c FROM Utilization_Data_Object__c 
                                                    WHERE (Start_Date__c >= LAST_N_DAYS:365) AND Membership__c IN : memberships]) {
            
            //Check if map already has a record for the membership, then add in existing list
            if(mapMembershipWithTeleconferenceUtilizations.containsKey(tU.Membership__c)) {
              
                //Get the Values of the Map and add record to it.
                mapMembershipWithTeleconferenceUtilizations.get(tU.Membership__c).add(tU);
            
            } else {
              
                //Create a new List at values and add record to it.
                mapMembershipWithTeleconferenceUtilizations.put(tU.Membership__c, new List<Utilization_Data_Object__c>{tU});  
            }
        }

        //Loop through membership records
        for (Membership__c membership : memberships) {

            // clear out the existing count fields
            membership.Membership_Meeting_Util_last_12_Mo__c = 0;
            membership.Membership_Teleconf_Util_last_12_Mo__c = 0;
            membership.Next_Teleconf_Start_Date__c = null;
            membership.Next_Meeting_Start_Date__c = null;
            membership.Closest_Active_Meeting_End_Date__c = null;
            membership.Closest_Teleconf_End_Date__c = null;

            // set the number of meetings attended for this membership in the past 12 months
            // go through each membership to determine the next closest start/end date
            //Cheching if membership in current context have children "Teleconfrence Utilization" with it and if yes, then do all the calculations
            if(mapMembershipWithMemberUtilizations.get(membership.Id) != null) {
                    
                //Loop through children "Membership Utilization" records
                for (Meeting_Utilization__c meeting : mapMembershipWithMemberUtilizations.get(membership.Id)) {
        
                    if (meeting.Start_Date__c < system.today())
                        membership.Membership_Meeting_Util_last_12_Mo__c++;

                    if (membership.Next_Meeting_Start_Date__c == null && meeting.Start_Date__c >= system.today())
                        membership.Next_Meeting_Start_Date__c = meeting.Start_Date__c;
                    else if (membership.Next_Meeting_Start_Date__c < meeting.Start_Date__c && meeting.Start_Date__c > system.today())
                        membership.Next_Meeting_Start_Date__c = meeting.Start_Date__c;

                    if (membership.Closest_Active_Meeting_End_Date__c == null && meeting.End_Date__c >= system.today().addDays(-365))
                        membership.Closest_Active_Meeting_End_Date__c = meeting.End_Date__c;
                    else if (membership.Closest_Active_Meeting_End_Date__c > meeting.End_Date__c)
                        membership.Closest_Active_Meeting_End_Date__c = meeting.End_Date__c;
                }
            }

            //Cheching if membership in current context have children "Teleconfrence Utilization" with it and if yes, then do all the calculations
            if(mapMembershipWithTeleconferenceUtilizations.get(membership.Id) != null) {
                    
                //Loop through children "Teleconference Utilization" records
                for (Utilization_Data_Object__c teleconf : mapMembershipWithTeleconferenceUtilizations.get(membership.ID)) {
                
                    if (teleconf.Start_Date__c < system.today())
                        membership.Membership_Teleconf_Util_last_12_Mo__c++;

                    if (membership.Next_Teleconf_Start_Date__c == null && teleconf.Start_Date__c >= system.today())
                        membership.Next_Teleconf_Start_Date__c = teleconf.Start_Date__c;
                    else if (membership.Next_Teleconf_Start_Date__c < teleconf.Start_Date__c && teleconf.Start_Date__c > system.today())
                        membership.Next_Teleconf_Start_Date__c = teleconf.Start_Date__c;

                    if (membership.Closest_Teleconf_End_Date__c == null && teleconf.End_Date__c >= system.today().addDays(-365))
                        membership.Closest_Teleconf_End_Date__c = teleconf.End_Date__c;
                    else if (membership.Closest_Teleconf_End_Date__c > teleconf.End_Date__c)
                        membership.Closest_Teleconf_End_Date__c = teleconf.End_Date__c;
                }
            }
        }
        
        //String to hold the log Message
        String logMessage = '';
        
        // update the memberships
        if (memberships.size() > 0) {
            
            /** Added by Bhavi on 10/06/2012 - CR-20120913-1491 **/
            //Bypass triggers
            Util.BypassAllTriggers = true;
            /** Up To Here: Added by Bhavi on 10/06/2012 - CR-20120913-1491 **/
            
            //Modified By - Abhinav Sharma - 04/19/2014 - CR-20140331-4909
            if(System.isBatch()) {
                logMessage = Util.createLog(Database.update((memberships),false));
            } else {
                update memberships;
            }
        }
        //Returning log message string
        return logMessage;
    }
    
    //Update by Abhinav Sharma - Updated to remove SOQL queries 
    //CR-20120823-1396 - 02/14/2014 - Remove subquery in Batch_MeetingUtilizations
    public static List<Membership__c> FindMemberships(Set<Id> membershipIds) {
        List<Membership__c> membershipMap = [SELECT Name, Id, Membership_Meeting_Util_last_12_Mo__c, Membership_Teleconf_Util_last_12_Mo__c ,
                                            Next_Teleconf_Start_Date__c, Next_Meeting_Start_Date__c, Closest_Active_Meeting_End_Date__c, Closest_Teleconf_End_Date__c
                                            FROM Membership__c WHERE Id IN :membershipIds];
        return membershipMap;
    }
    
    /**
     *  @description    :   This method is to update the Interaction infomration on Institution Role
     *
     *  @args           :   List of new Member Utilizations records, Map of old Member Utilizations 
     *
     *  @return         :   void
     *
     **/
    public static void UpdateInteractionInformation(List<Meeting_Utilization__c> newMeetingUtilizations, Map<Id, Meeting_Utilization__c> mapOldMeetingUtilizations) {
        
        //Create a set to hold teh contact Ids
        Set<Id> contactIds = new Set<Id>();
        
        //Check if Interaction information need to be updated
        //Insert Scenerio
        if(newMeetingUtilizations != null && mapOldMeetingUtilizations == null) {
            
            //Loop through the new Member Utilizations
            for(Meeting_Utilization__c meetingUtilization : newMeetingUtilizations) {
                
                //Check for the Contact Id
                if(meetingUtilization.Contact__c != null && meetingUtilization.Institution__c != null && meetingUtilization.Start_Date__c != null) {
                    
                    //Add new contact Id
                    contactIds.add(meetingUtilization.Contact__c);
                }
            }
        } else if(newMeetingUtilizations != null && mapOldMeetingUtilizations != null) {
            //Update Scenerio   
            //Loop through the new Member Utilizations
            for(Meeting_Utilization__c meetingUtilization : newMeetingUtilizations) {
                
                //Check for the Contact Id
                //if Contact__c, Institution__c or CallType changed
                if(meetingUtilization.Contact__c != null && meetingUtilization.Institution__c != null 
                    && (meetingUtilization.Contact__c != mapOldMeetingUtilizations.get(meetingUtilization.Id).Contact__c 
                        || meetingUtilization.Institution__c != mapOldMeetingUtilizations.get(meetingUtilization.Id).Institution__c
                        || meetingUtilization.Start_Date__c != mapOldMeetingUtilizations.get(meetingUtilization.Id).Start_Date__c)
                ) {
                    
                    //Add Old contact Id 
                    if(meetingUtilization.Contact__c != mapOldMeetingUtilizations.get(meetingUtilization.Id).Contact__c && mapOldMeetingUtilizations.get(meetingUtilization.Id).Contact__c != null)
                        contactIds.add(mapOldMeetingUtilizations.get(meetingUtilization.Id).Contact__c);
                    
                    //Add new contact Id
                    contactIds.add(meetingUtilization.Contact__c);
                }
            }
        } else if(newMeetingUtilizations == null && mapOldMeetingUtilizations != null) {
            //Delete Scenerio
            //Loop through the new Member Utilizations
            for(Meeting_Utilization__c meetingUtilization : mapOldMeetingUtilizations.values()) {
                
                //Check for the Contact Id
                if(meetingUtilization.Contact__c != null && meetingUtilization.Institution__c != null && meetingUtilization.Start_Date__c != null) {
                    
                    //Add new contact Id
                    contactIds.add(meetingUtilization.Contact__c);
                }
            }
        }
        
        //Chekc if Institution Roles need to be updated
        if(contactIds.size() > 0)
             InstitutionRoleTriggerHelper.UpdateInteractionInformationByContactIds(null, contactIds, true);
    }
    
}