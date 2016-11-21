/**
    VRH created this trigger to support CR-180 which involves
    updating Meeting/Teleconference counts on Memberships
    V_1.2 - Bhavi Sharma - 02/04/2014 - CR-20140124-4353
    V1.3 - Modified By - Abhinav Sharma - 07/07/2014 - CR-20140618-5849 - Catch DML errors in triggers to reduce exception emails to SFAdmin

**/
trigger MeetingUtilization on Meeting_Utilization__c (after delete, after insert, after update) {

    try {
    
        // if we are bypassing all triggers, return without processing
        if (Util.BypassAllTriggers) return;
        
        // to hold all of the membership Ids associated witht he teleconference records we are updating
        Set<Id> membershipIds = new Set<Id>();
        list<Meeting_Utilization__c> memberships = (Trigger.IsDelete)? Trigger.old : Trigger.new;
        for (Meeting_Utilization__c meeting : memberships)
            membershipIds.add(meeting.Membership__c);
            
        // update the memberships with the correct number of teleconferences
        MeetingUtilities.UpdateMeetingSummary(membershipIds);
        
        //Update Institution Roles
        MeetingUtilities.UpdateInteractionInformation(Trigger.New, Trigger.oldMap);
        
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