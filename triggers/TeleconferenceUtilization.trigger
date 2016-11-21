/**
    VRH created this trigger to support CR-180 which involves
    updating Meeting/Teleconference counts on Memberships
    //V1.0 - Created
    //V1.1 - Modified By - Abhinav Sharma - 07/07/2014 - CR-20140618-5849 - Catch DML errors in triggers to reduce exception emails to SFAdmin
**/
trigger TeleconferenceUtilization on Utilization_Data_Object__c (after delete, after insert, after update) {

    try {
    
        // to hold all of the membership Ids associated witht he teleconference records we are updating
        Set<Id> membershipIds = new Set<Id>();
    
        list<Utilization_Data_Object__c> teleconferences = (Trigger.IsDelete)? Trigger.old : Trigger.new;
    
        for (Utilization_Data_Object__c teleconference : teleconferences)
            membershipIds.add(teleconference.Membership__c);
            
        // update the memberships with the correct number of teleconferences
        MeetingUtilities.UpdateMeetingSummary(membershipIds);
    
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