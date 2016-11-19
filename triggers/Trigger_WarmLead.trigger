/*
    Purpose:    This trigger is responsible for handling all the pre or post processing for
                any dml operation for Warm Lead object 
    
    Create By   :       Simplyforce Technology
    
    Created Date:       10/31/2012
    
    Current Version:    v1.4
    
    Revision Log:       v1.0 - Created
                        v1.1 - Modified - Bhavi - 4/24/2013 -CR-20130411-2856
                        v1.2 - Modified(before, after delete event added) - Bhavi - 12/13/2013 - CR-20130417-2892
                        v1.3 - Bhavi Sharma - 02/22/2014 - CR-20140121-4302
                        v1.4 - Modified By - Abhinav Sharma - 07/07/2014 - CR-20140618-5849 - Catch DML errors in triggers to reduce exception emails to SFAdmin
                        v1.5 - Modified By - Abhinav Sharma - 08/14/2014 - CR-20140623-5887 - Leveleven Follow Up Development work
                        v1.6 - Modified By - Abhinav Sharma - 11/24/2014 - CR-20141029-7923 - Initial Visit Date Trigger on Warm Leads
						v1.7 - Modified By - Victor Hanson - 06/29/2015 - CR-20150129-8609 - added reference to populateDefaultValues method
						v1.8 - Modified By - Abhinav Sharma - 10/20/2015 - CR-20150908-9227 - added reference to populateReportingLeadChannel method
*/
trigger Trigger_WarmLead on Warm_Lead__c (after insert, after update, before insert, before update, before delete,  after delete) {
    
    try {
        
        //Bypassing trigger according to the flag value
        if (Util.BypassAllTriggers) 
            return;
        
        //Check for the request type
        if(Trigger.isBefore) {
            
            //Check for the event type
            if(Trigger.isInsert || Trigger.isUpdate) {
                
                //Call the helper class method to set the name
                WarmLeadTriggerHelper.setName(Trigger.New);
                WarmLeadTriggerHelper.populateReportingLeadChannel(Trigger.New);
            }
            
            if (trigger.isInsert) {
                
                //method to default values when source interaction and outcome type are populated
                WarmLeadTriggerHelper.populateDefaultValues(trigger.new);
            }
            
            //Check for the event type
            if(Trigger.isUpdate) {
             
                //Added By - Abhinav Sharma - 11/24/2014 - CR-20141029-7923
                //Call helper class method
                WarmLeadTriggerHelper.populateInitialVisitDate(Trigger.new);
            }
            
            //Code added by Bhavi - 12/13/2013 - CR-20130417-2892
            //Check for event type 
            else if(Trigger.isDelete) {
                
                //Call the helper class method to delete related WarmLeadMtM records 
                WarmLeadTriggerHelper.populateOpportunityCountOfSourcedWarmLead(Trigger.Old, Trigger.isBefore);
            }
            
        } else {
        
            //Allows this object to be used in the Compete App
            //Added as part of CR-5887
            //ePrize_Zemzu.SCBCustomContestEvaluator.evaluate('Warm_Lead__c',Trigger.new,Trigger.old);
            
            //Check for the event type
            if(Trigger.isInsert || Trigger.isUpdate) {
                
                //Check if the method has not already been executed
                if(WarmLeadTriggerHelper.EXECUTE_TRIGGER_CREATE_MATCHING_WARM_LEADS_MTM) {
    
                    //Call the helper class method to create the MtM records
                    //Bhavi Sharma - 4/24/2013 -CR-20130411-2856
                    WarmLeadTriggerHelper.UpdateStatusOfRelatedOpp(Trigger.newMap, Trigger.oldMap);           
                }
            
                //After update
                if(Trigger.isUpdate) {
                    
                    //Call helper class to update the opportunity's sourced warm lead information if lead date changed
                    WarmLeadTriggerHelper.populateOpportunityCountOfSourcedWarmLead(Trigger.New, Trigger.oldMap);
                }
            }
            
            //Code added by Bhavi - 12/13/2013 - CR-20130417-2892
            //Check for event type 
            else if(Trigger.isDelete) {
                
                //Call the helper class method to delete related WarmLeadMtM records 
                WarmLeadTriggerHelper.populateOpportunityCountOfSourcedWarmLead(Trigger.Old, Trigger.isBefore);
            }
            
            //Added By Bhavi Sharma - 02/22/2014 - CR-20140121-4302
            //Update Most Recent Lead Information to Contact
            WarmLeadTriggerHelper.updateLeadInfoOnContact(Trigger.New, Trigger.oldMap);
        }
        
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