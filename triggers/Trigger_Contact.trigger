/**
 *  Description     :   This trigger is to handle all the pre and post processing operation for Contact record
 * 
 *  Created By      :   Bhavi
 * 
 *  Created Date    :   07/13/2012
 * 
 *  Revision Logs   :   V1.0 - Created
 *                      V1.1 - Code Added - Bhavi Sharma - 11/14/2013 - CR-20130419-2900
 *                      V1.2 - Code Added - Abhinav Sharma - 03-07-2014 - CR-20140204-4441
                        V_1.3 - Modified - Bhavi Sharma - 01/23/2015 - CR-20141209-8274 - New method added - resendBouncedAgreement()
                        V_1.4 - Modified - Subhash Garhwal - 07/02/2015 - CR-20150618-9014 - New method added - updateStaffAssignment
                        //Manual Merged By -Rajeev Jain - 11/09/2015
                        V_1.5 - Modified - Padmesh Soni - 17/08/2015 - CR-20150729-9114 - New method Added - createIncentiveChangeLog()
                        //Manual Merged By -Rajeev Jain - 11/09/2015 - upto here
                        V_1.6 - Modified By - Mahendra Swarnakar - CR-20150831-9207 - 11/25/2015 - Contact Edit Validation
                        V_1.7 - Modified By - Rajeev Jain - CR-20151120-9402 - 04/20/2016 - Modified createIncentiveChangeLog
                        V_1.8 - Modified By - Mahendra Swarnkar - 5/30/2016 - CR-20151209-9452 - Release 51
						V_1.9 - Modified By - Rajeev Jain - 06/24/2016 - Royall Migration - Royall SFDC Schema Release.
                                                                        - Merging of Shift_Contact_Trigger on Contact object, from Royall Instance to Corporate Instance
						V_1.9 Modified By - Mahendra swarnakar - 11/8/2015 - CR-20160729-10074
 * 
 **/
trigger Trigger_Contact on Contact (before update, before insert, before delete, after update, after insert, after delete) {
    
    // if a trigger bypass is active, return immediately without processing
    if (Util.BypassAllTriggers)  {
        return;
    }
    
    // set this flag to true so we don't have duplicate execution going on
    SiteUserHelper.IsTriggerContact = true;
    
    //Check for the request Type
    if(Trigger.isBefore) {
        
        if (trigger.isInsert) {
            
            // Code Added - VH - 1/7/14
            ContactTriggerUtilities.validateContactBeforeInsert(trigger.new);
        }
        
        //Added By - Mahendra Swarnakar - CR-20150831-9207 - 11/25/2015 - Contact Edit Validation
        //Start from here
        if(Trigger.isInsert || Trigger.isUpdate) {
            
            
            //Calling Helper class method
            ContactTriggerUtilities.validateContactFieldsForInvalidPhrase(trigger.new, trigger.oldMap);
        }
        //Upto here
        
        if (trigger.isUpdate && !trigger.isDelete) {
            ContactSiteHelper.CheckInstitutionChange(trigger.new, trigger.oldMap);
        }
        
        //Check for the event type
        if(Trigger.isDelete) {
    
            //Validate contact record before deleting
            ContactTriggerUtilities.validateContactBeforeDelete(Trigger.Old);
            
            //Added By Abhinav Sharma on 03-07-2014 - CR-20140204-4441 - Restriction status not being updated properly as part of nightly batch job
            //Calling Helper class method
            ContactTriggerUtilities.deleteAllRestrictionMtMRecords(trigger.old);
            
            //V_1.8 - Added By - Rajeev Jain - 06/24/2016 - Royall Migration - Royall SFDC Schema Release.
            //V_1.9 Modified By - Mahendra swarnakar - 11/8/2015 - CR-20160729-10074
            if (!system.isFuture() && !system.isScheduled() && !system.isBatch() && Shift_ChangeDelete_Callout.calloutSettings.Enable_Contact_Trigger__c) {
                Shift_ChangeDelete_Callout.processRecords((List<SObject>)trigger.old, 'delete', 'Contact');
            }
        }
    }
    
    if (Trigger.IsAfter) {
        
        if (trigger.isUpdate) {
            
            //VH 8/18/14 - EAB - if the contact's email changes, update the site profile username
            ContactSiteHelper.updateSiteProfilesFromContact(trigger.new, trigger.oldMap);
            
            //Modified By - Bhavi Sharma - 01/23/2015 - CR-20141209-8274 - Call helper class method for resending the agreement
            if(ContactTriggerUtilities.EXECUTE_RESEND_BOUNCED_AGREEMENT == true) {
                ContactTriggerUtilities.resendBouncedAgreement(Trigger.New, Trigger.oldMap);
                System.debug('ContactTriggerUtilities.EXECUTE_RESEND_BOUNCED_AGREEMENT:::::' + ContactTriggerUtilities.EXECUTE_RESEND_BOUNCED_AGREEMENT + DateTime.now());
            }
            
            //Call Method to update the related portfolio
            ContactTriggerUtilities.updateContactPersonalAddressUpdated(Trigger.New, Trigger.oldMap);
            
            //Added by - Subhash Garhwal - 07/02/2015 - 07/02/2015 - CR-20150618-9014
            //Call helper class method.
            //This method is used to rename all the related SA name if contact name is changed
            ContactTriggerUtilities.updateStaffAssignment(Trigger.new, Trigger.oldMap);
            
            //Added By - Mahendra swarnakar - 09/18/2015 - CR-20150819-9165
            //Call helper class method.
            //This Method update the related Research Study Interaction if Institution is changed
            ContactTriggerUtilities.populateInstitutionLookUpFieldForNPD(Trigger.new, Trigger.oldMap);
            
            //Manual Merger By - Rajeev Jain - 11/09/2015
            //Added by - Padmesh Soni - 17/08/2015 - CR-20150729-9114     
            //V_1.7 - moved from here to below code - Rajeev Jain - 04/20/2016 - CR-20151120-9402
            //call the Helper class.
            //This method is used to create Incentive Change Log Records when contacts are created or updated
            //ContactTriggerUtilities.createIncentiveChangeLog(Trigger.new, Trigger.oldMap); 
            //Manual Merger By - Rajeev Jain - 11/09/2015 - upto here
            
             System.debug('@@@@@@@@@@@@@@@@@system.isFuture()' +system.isFuture()+system.isScheduled()+system.isBatch());
            
            ///V_1.8 - Added By - Rajeev Jain - 06/24/2016 - Royall Migration - Royall SFDC Schema Release.
            //V_1.9 Modified By - Mahendra swarnakar - 11/8/2015 - CR-20160729-10074
            if (!system.isFuture() && !system.isScheduled() && !system.isBatch() && Shift_ChangeDelete_Callout.calloutSettings.Enable_Contact_Trigger__c) {
                
				system.debug('###########################IN CONDITION ####' );                
                Shift_ChangeDelete_Callout.processRecords((List<SObject>)trigger.new, 'update', 'Contact');
            }
        }
        //V_1.7 - Added By - Rajeev Jain - 04/20/2016 - CR-20151120-9402
        if(Trigger.isInsert || Trigger.isUpdate) {
            
            //Added By - Mahendra Swarnkar - 5/30/2016 - CR-20151209-9452 - Release 51
            //Start from here
            // To populate the "Marketing Asssociated Sign Off Date" value on User record with "Marketing Asssociated Sign Off Date" field value on the contact
            ContactTriggerUtilities.populateMASignOffDateOnUser(trigger.new, trigger.oldMap);         
        	//Added By - Mahendra Swarnkar - 5/30/2016 - CR-20151209-9452 - Release 51 - Ends here
        	//Upto here
            
            //Rajeev Jain - Moved from above commented code to here, in order to call it at both event(Insert and Update)
            ContactTriggerUtilities.createIncentiveChangeLog(Trigger.new, Trigger.oldMap);  
        }
    }
}