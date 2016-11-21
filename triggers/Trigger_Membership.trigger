/*
    Purpose:    This trigger is responsible for handling all the pre or post processing for
                any dml operation for Membership object

                Processes:
                1.  Copy Associate value from Owner's record to Membership's Owner Associate field


    Create By   :   Simplyforce Technology

    Created Date:   01/18/2012

    Current Version:    v1.4

    Revision Log:       v1.0 - Created
                        v1.1 - Bhavi - 06/15/2012 - Added after update event on trigger.
                                Delete  Key Member Contacts records if Membership Status does not starts with "Membership" - CR-20120518-905
                        V1.2 Bhavi - 11/07/2012 - CR-20121019-1641
                        V1.3 Bhavi - 03/28/2013 - CR-20121207-1868
                        V1.4 - Modified By - Abhinav Sharma - 07/07/2014 - CR-20140618-5849 - Catch DML errors in triggers to reduce exception emails to SFAdmin
                        V1.5 - Modified By - Ajit Surana - 03/28/2015 - CR-20150312-8758
                        V1.6 - Modified By - Abhinav Sharma - 09/03/2015 - CR-20150205-8660
                        V1.7 - Modified By - Jeffery Sun - 09/30/2015 - CR-20130328-2770					
*/
trigger Trigger_Membership on Membership__c (before insert, before update, after insert, after update, after delete) {

    try {
        
        //Updated by - Mahendra Swarnkar - 3/30/2016 - CR-20160107-9497 - removed the logic that  bypasses trigger_membership for users with the ABC Dataloader profile. starts from here
        
        // if bypass all triggers is set to true, return without processing
        if (Util.BypassAllTriggers) return;
		//Updated by - Mahendra Swarnkar - 3/30/2016 - CR-20160107-9497 - removed the logic that  bypasses trigger_membership for users with the ABC Dataloader profile. Ends here.

        //Check for the request type
        if(Trigger.isBefore) {

            //Check for the event type
            if(Trigger.isInsert || Trigger.isUpdate) {

                //Call Helper class method to update the Owner Associate
                MembershipTriggerHelper.populateOwnerAssociate(Trigger.New);

                //Call helper class method to update the membership status field on Membership record
                MembershipTriggerHelper.updateMembershipStatusByContracts(Trigger.New);

                //Call the helper class method to populate Assigned Marketer
                MembershipTriggerHelper.membershipPopulateAssignedMarketer(Trigger.New, Trigger.isBefore);

                //Added By - Abhinav Sharma - 09/03/2015 - CR-20150205-8660
                //Start from here
                //Calling helper class method
                MembershipTriggerHelper.populateFieldsOnMembershipInBeforeEvent(Trigger.new);
                //Upto here
            }
        } else if(Trigger.isAfter) {

            //Check if the insert event
            if(Trigger.isInsert) {

                //Call helper class method
                MembershipTriggerHelper.UpdateRelationshipGradeNotes(Trigger.New);

                //Call the helper class method to populate Assigned Marketer
                MembershipTriggerHelper.membershipPopulateAssignedMarketer(Trigger.New, Trigger.isBefore);

            } else if(Trigger.isUpdate) {

                //Call helper class method to update the Contact data
                MembershipTriggerHelper.populateContactData(Trigger.New);

                //Call helper class method
                MembershipTriggerHelper.UpdateRelationshipGradeNotes(Trigger.New);

                //Call the helper class method to populate Assigned Marketer
                MembershipTriggerHelper.membershipPopulateAssignedMarketer(Trigger.New, Trigger.isBefore);

            }

            //Added by - Ajit Surana - 03/28/2015 - CR-20150312-8758
            if(Trigger.isInsert || Trigger.isUpdate || Trigger.isDelete) {

                //Calling helper class method
                MembershipTriggerHelper.populateIndustryMemberOnAccount(Trigger.new, Trigger.oldMap);
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