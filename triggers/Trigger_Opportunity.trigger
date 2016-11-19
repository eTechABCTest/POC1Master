/**
 *  Purpose         :   This trigger is to handle all the pre and post processing operations for Opportunity object
 *
 *  Create By       :   Bhavi Sharma
 *
 *  Created Date    :   01/31/2014
 *
 *  Revision Logs   :   V_1.0 - Created
 *                      V_1.1 - Modified By - Abhinav Sharma - 07/02/2014 - CR-20140502-5327
 *                      V_1.2 - Modified By - Abhinav Sharma - 08/26/2014 - CR-20140808-6940
 *                      V_1.3 - Modified By - Abhinav Sharma - 09/15/2014 - CR-20140429-5272
 *                      V_1.4 - Modified By - Abhinav sharma - 09/17/2014 - CR-20140429-5272
 *                      V_1.5 - Modified By - Abhinav Sharma - 09/19/2014 - CR-20140429-5272
 *                      v_1.6 - Modified By - Abhinav Sharma - 08/25/2015 - CR-20150820-9167
 *                      v_1.7 - Modified By - Abhinav Sharma - 08/28/2015 - CR-20140613-5790
 *                      V_1.8 - Modified By - Jeffery Sun - 09/30/2015 - CR-20130328-2770
 *                      v_1.9 - Modified By - Abhinav Sharma - 05/20/2016 - CR-20160308-9682
 *                      V_2.0 - Modified By - CJ Kelly - 6/20/2016 - Deactivated/reactivated to get around Data Load error pointing to this Trigger.
 *						V_2.1 - Modified By - Subhash Garhwal - 06/23/2016 - CR-20160414-9762
 *						V_2.2 - Modified By - Subhash Garhwal - 07/06/2016 - CR-20160414-9762
 *						V_2.3 - Modified By - Subhash Garhwal - 07/14/2016 - CR-20160414-9762
 **/
trigger Trigger_Opportunity on Opportunity (before insert, before update, after insert, after update, after delete) {

    try {

        //Used for testing
        if(!Trigger.isDelete) {
            for(Opportunity opp: Trigger.new){
                //Throw Exception if requested
                if (Util.IsBreakMe) opp.addError('Requested Exception');
            }
        }

        //Bypass All Triggers
        if (Util.BypassAllTriggers) return;

        //Check for the request type
        if(Trigger.isBefore) {

            //Code from Opportunity_ValidationAndFieldUpdates trigger
            if(Util.IsTrigger_EventPrewire
                || Util.IsTrigger_EventUpdateFields
                || Util.IsBatch
                || Util.IsTrigger_NBBOppFields)
                return;

            //Check users profile
            Id dataloaderProfileId = label.ABC_Dataloader_Profile_Id;

            if(dataloaderProfileId != null && UserInfo.getProfileId() == dataloaderProfileId)
                return;  // DAF - added 10/29/11 - removed ABC Dataloader from running code

            //Modified By - Abhinav Sharma - Added Boolean flag for controlling the order of execution - CR-20140808-6940
            //Check for the event type
            if(Trigger.isInsert || (Trigger.isUpdate && OpportunityTriggerHelper.EXECUTE_TRIGGER_BEFORE_UPDATE)) {
            	
            	//Subhash Garhwal - 06/23/2016 - CR-20160414-9762
                //Call helper class method to validate program opportunities
                OpportunityTriggerHelper.PreventManualDuplicateProgramOpportunities(Trigger.new, Trigger.oldMap);
				
                //Only execute the trigger it is not executed yet
                if(Util.IsTrigger_Opportunity_ValidationAndFieldUpdates == false && Util.IsTrigger_WarmLeadMtm == false) {

                    Util.IsTrigger_Opportunity_ValidationAndFieldUpdates = true; // NB20110114 - Added to prevent duplicate execution

                    //Added by Ajit Surana - 03/13/2014 - CR-20140205-4458
                    //Call the helper class method to update opportunity records
                    if(Trigger.isUpdate)
                        OpportunityTriggerHelper.updateOpportunityNonSOXFields(Trigger.new, Trigger.oldMap);

                    //Call helper class method to execute the code for Opportunity_ValidationAndFieldUpdates
                    OpportunityTriggerHelper.opportunityValidationAndFieldUpdated(Trigger.New, Trigger.newMap, Trigger.oldMap);
                }

                //Merged from Opportunity Related fields updates trigger
                if(Util.IsTrigger_Task_PopulateNoOfRevisitField == false) {

                    //Merged from Opportunitt Related fields updates
                    //Bhavi - 04/30/2013 - CR-20130408-2835
                    //Call helper class method to update the Opportunity Field Active_Renewal__c
                    OpportunityTriggerHelper.populateFieldOnOpportunityWithMembership(Trigger.new, Trigger.oldMap);

                     //Check for the event type
                    if(Trigger.isUpdate) {

                        //Call the helper call method to update the "Initial Visit Date" on opportunity
                        OpportunityTriggerUtilities.updateInitialVisitDateByEventDate(Trigger.newMap);

                        // assigns lost opportunity contacts to market warming campaign
                        OpportunityTriggerHelper.assignOpptyContactsToMarketWarmingCampaign(trigger.newMap,trigger.oldMap);

                        OpportunityTriggerHelper.populateInitialVisitDate(Trigger.newMap);
                    }
                }

                //Added By - Abhinav Sharma - 09/19/2014 - CR-5272
                //Start from here
                //Calling helper class method
                if(Trigger.isInsert) {
                    OpportunityTriggerHelper.populateBundleNameOnOpportunities(trigger.new);
                    //Added By - Abhinav Sharma - 08/25/2015 - CR-20150820-9167
                    OpportunityTriggerHelper.applyValidationsOverOpportunityRecords(Trigger.new, Trigger.oldMap);
                    OpportunityTriggerHelper.doCalculationAndPopulateFieldsOnOpportunities(Trigger.new, Trigger.oldMap);
                    
                    //Subhash Garhwal - 07/06/2016 - CR-20160414-9762
                	//Call helper class method to sync Renewal Opps
                	OpportunityTriggerHelper.syncRenewalOpp(Trigger.new);
                }

                //Calling helper class method in update case
                if(Trigger.isUpdate && OpportunityTriggerHelper.EXECUTE_TRIGGER_BEFORE_UPDATE) {
                    
                    //Added By - Abhinav Sharma - 10/14/2015 - CR-20150831-9204
                    OpportunityTriggerHelper.populateCTAssignmentManagerEmail(Trigger.new);
                    
                    OpportunityTriggerHelper.populateBundleNameOnOpportunities(trigger.new);
                    
                    //Added By - Abhinav Sharma - 08/25/2015 - CR-20150820-9167
                    OpportunityTriggerHelper.applyValidationsOverOpportunityRecords(Trigger.new, Trigger.oldMap);
                    OpportunityTriggerHelper.doCalculationAndPopulateFieldsOnOpportunities(Trigger.new, Trigger.oldMap);
                }
                //Upto here

                //Do not fire after Update event again
                if(Trigger.isUpdate)
                    OpportunityTriggerHelper.EXECUTE_TRIGGER_BEFORE_UPDATE = false;
            }
        } else if(Trigger.isAfter) {

            //Modified By - Abhinav Sharma - Added Boolean flag for controlling the order of execution - CR-20140808-6940
            //Check for the event type
            if(Trigger.isUpdate && OpportunityTriggerHelper.EXECUTE_TRIGGER_AFTER_UPDATE) {
                    
                // update opp initial visit date on related events when the opportunity initial visit date is updated cr-3662
                OpportunityTriggerHelper.populateInitialVisitOnActivities(trigger.new, trigger.oldMap);

                // update Program / Program Abbreviation on related events when the opportunity's program is updated cr-1793
                OpportunityTriggerUtilities.populateProgramInfoToActivities(trigger.new, trigger.oldMap);

                //Bhavi - 01/11/2014 - CR-20130417-2892
                OpportunityTriggerHelper.updateWarmLeadInfoOnOpportunity(Trigger.New, Trigger.oldMap);

                //Added By - Abhinav Sharma - 08/28/2015 - CR-20140613-5790
                OpportunityTriggerHelper.populatePAsAndActivityFieldsOnWarmLeadMTMs(trigger.new, trigger.oldMap);
            }

            //Skip trigger if this is cascading from a different update trigger
            // or if bypass all triggers is true, return without processing
            if (Util.IsTrigger_NBBOppFields
                || Util.IsTrigger_EventPrewire
                || Util.IsTrigger_EventUpdateFields
                || Util.IsBatch
                || Util.IsTrigger_Task_PopulateNoOfRevisitField) return;

            //Check users profile
            Id dataloaderProfileId = label.ABC_Dataloader_Profile_Id;

            if(dataloaderProfileId != null && UserInfo.getProfileId() == dataloaderProfileId)
                return;  // DAF - added 10/29/11 - removed ABC Dataloader from running code

            //Insert and Update Event
            if (Trigger.isInsert || (Trigger.isUpdate && OpportunityTriggerHelper.EXECUTE_TRIGGER_AFTER_UPDATE)) {
                
                //Added By - Abhinav Sharma - 05/20/2016 - CR-20160308-9682
                //Start from here
                //Calling helper class method
                OpportunityTriggerHelper.syncOppMainContactAndPrimayOCR(Trigger.new, Trigger.oldMap);
                //Upto here
                    
                //Added By - Abhinav Sharma - 07/02/2014 - CR-20140502-5327
                //Start Here
                //Calling helper class method to update "Active Renewal Opportunity" field on membership records
                OpportunityTriggerHelper.updateOpportunitiesWithDesiredFieldValues(Trigger.new, Trigger.oldMap);
                //Upto Here

                //This method is to rollup the opportunity info on account level - CR-20130117-2187
                OpportunityTriggerHelper.rollupOppsDataOnAccount(Trigger.New);

                OpportunityTriggerUtilities.CalculateNextDecisionDate(trigger.new);

                // check to see if there are any contract documents that need to be synched with the Opportunity
                OpportunityTriggerUtilities.UpdateContractDocs(trigger.new, trigger.oldMap);

                OpportunityTriggerHelper.opportunitySignedContract(Trigger.New, Trigger.Old);

                //Bhavi - 11/07/2012 - CR-20121019-1641
                //Call helper class method to update the Pubs and Meeting data on Contact record
                OpportunityTriggerHelper.PopulateContactData(Trigger.newMap, Trigger.oldMap);

                OpportunityTriggerHelper.updateSalesTeamRole(Trigger.newMap, Trigger.oldMap);
            }

            //Update Event
            if(Trigger.isUpdate && OpportunityTriggerHelper.EXECUTE_TRIGGER_AFTER_UPDATE) {

                //Bhavi - 12/12/2012 - CR-20121106-1687
                //Call helper class method to set the agreement status to cancelled
                OpportunityTriggerHelper.validateAgreementsStatus(Trigger.newMap, Trigger.oldMap);

                OpportunityTriggerHelper.membershipOwnerCheckfromOpps(Trigger.New);
                
                //Subhash Garhwal - 06/23/2016 - CR-20160414-9762
                //Call helper class method to validate program opportunities
                OpportunityTriggerHelper.validateProgramOpportunities(Trigger.new, Trigger.oldMap);

            }

            //Added By - Abhinav Sharma - 09-17-2014 - CR-20140429-5272
            //Check for event
            if(Trigger.isInsert) {

                //Added By - Abhinav Sharma - 09/17/2014 - CR-20140429-5272
                //Call helper class method
                OpportunityTriggerHelper.populateAccountOnBundleOpportunity(Trigger.new, Trigger.oldMap);
                
                //Subhash Garhwal - 07/06/2016 - CR-20160414-9762
            	//Call helper class method to create IntegratedAccount for renewal Opps
            	OpportunityTriggerHelper.createIntegratedAccountForRenewalOpps(Trigger.new);
            }

            //Added By - Abhinav Sharma - 09/15/2014 - CR-20140429-5272
            //Start from here
            //Checking for the request type
            if(Trigger.isInsert || Trigger.isDelete) {

                //Calling Helper class method
                OpportunityTriggerHelper.rollUpSummaryFieldValuesOnBundleOpp(Trigger.new, Trigger.oldMap);
                OpportunityTriggerHelper.manageBundledOppSiblings(Trigger.new, Trigger.oldMap);

            }

            if(Trigger.isUpdate && OpportunityTriggerHelper.EXECUTE_TRIGGER_AFTER_UPDATE) {

                //Calling Helper class method
                OpportunityTriggerHelper.populateAccountOnBundleOpportunity(Trigger.new, Trigger.oldMap);
                OpportunityTriggerHelper.rollUpSummaryFieldValuesOnBundleOpp(Trigger.new, Trigger.oldMap);
                OpportunityTriggerHelper.manageBundledOppSiblings(Trigger.new, Trigger.oldMap);
                
            }
            
            //Subhash Garhwal - 06/23/2016 - CR-20160414-9762
            //Check for request type
            if(Trigger.isInsert || Trigger.isUpdate || Trigger.isDelete) {
            	
            	//Call helper class method to Rollup Program Opps
                OpportunityTriggerHelper.rollupProgramOpps(Trigger.new, Trigger.oldMap);
			}
            //Upto Here

            if(Trigger.isUpdate)
                OpportunityTriggerHelper.EXECUTE_TRIGGER_AFTER_UPDATE = false;
        }
    } catch(DMLException e) {

        //Added By Bhavi - 01/30/2014 - CR-20131205-4084
        //failed record
        String failedRecordId = e.getDmlId(0);
        String failureMessage = e.getDmlMessage(0);

        //Check for the status code and error message
        if(e.getDmlType(0) == StatusCode.FIELD_CUSTOM_VALIDATION_EXCEPTION
            && failureMessage.containsIgnoreCase('You must specify a contract document type')) {

            //Query Agreement record
            if(failedRecordId != null) {

                //Fetch related agreement record
                List<echosign_dev1__SIGN_Agreement__c> agreements = [Select Id, Name from echosign_dev1__SIGN_Agreement__c where Id =: failedRecordId];

                if(agreements.size() > 0) {

                    //Custom error message
                    //String errorMessage = 'Related Contract Document Type field on the related agreement <a href="/' + failedRecordId + '" target="_blank">' + agreements[0].Name + '</a> must be populated prior to saving the opportunity as ' + Trigger.New[0].StageName;
                    String errorMessage = Label.CONTRACT_DOCUMENT_TYPE_REQUIRED_CUSTOM_ERROR_MESSAGE;
                    errorMessage = errorMessage.replace('{!agreementId}', failedRecordId).replace('{!agreementName}', agreements[0].Name).replace('{!opportunityStage}', Trigger.New[0].StageName);

                    //Add Error Message on Page
                    if(Trigger.isDelete)
                        Trigger.Old[0].addError(errorMessage);
                    else
                        Trigger.New[0].addError(errorMessage);
                } else {
                    //Add Error Message on Page
                    if(Trigger.isDelete)
                        Trigger.Old[0].addError(failureMessage);
                    else
                        Trigger.New[0].addError(failureMessage);
                }
            }
        } else {

            //Add Error Message on Page
            if(Trigger.isDelete)
                Trigger.Old[0].addError(failureMessage);
            else
                Trigger.New[0].addError(failureMessage);
        }
    } catch(Exception e) {

        //Add Error Message on Page
        if(Trigger.isDelete)
            Trigger.Old[0].addError(e.getMessage());
        else
            Trigger.New[0].addError(e.getMessage());
    }
}