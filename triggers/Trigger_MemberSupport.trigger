/**
    Purpose         :   This trigger to handle all the processing for member support object.(CR-20140506-5363)
                
    Create By       :   Colin McGloin
    
    Created Date    :   8/28/2015
    
    Revision Logs   :   V_1.0 - Created - 8/28/2015 - Code Refactoring - Merging MemberSupportTrigger & site_issue_virtual_rollups - CR-20140506-5363
    					V_1.1 - Modified By - Abhinav Sharma - 11/28/2015 - CR-20150601-8977
						V_1.2 - Modified by - Mahendra Swarnakar - 02/15/2016 - CR-20151210-9456
						V_1.3 - Modified By - Abhinav Sharma - 04/01/2016 - CR-20160224-9632
						V_1.4 - Modified By - Mahendra Swarnkar - 08/24/2016 - CR-20160114-9520
						V_1.5 - Modified by - Mahendra Swarnkar - CR-20160420-9785 - 09/01/2016
**/
trigger Trigger_MemberSupport on Site_Issue__c (before insert, before update, after insert, after update, after delete) {
    
    try {
        
        if (Util.BypassAllTriggers) 
            return;
        
        if (trigger.isBefore && !trigger.isDelete) {
            
            //CR-4283
            MemberSupportTriggerUtilities.populateTier1Name(trigger.new);
        }
        
        //Code added by Bhavi Sharma - 06/04/2013 - CR-20130328-2773
        //Check for the request type
        if(Trigger.isBefore) {
            
            // check to see if the owner of this record needs to be updated
            MemberSupportTriggerUtilities.CalculateAssignment(trigger.oldMap, trigger.new);
            
            //Check for the event type
            //Added isUpdate flag - Bhavi Sharma - 02/24/2014 - CR-20131213-4161
            if(Trigger.isInsert || Trigger.isUpdate) {
                
                //Added By - Abhinav Sharma - 04/01/2016 - CR-20160224-9632
                //Start from here
                MemberSupportTriggerUtilities.validateFieldsValueChangesForCrimsonAndPTDataLoadMS(Trigger.new, Trigger.OldMap);
                //Upto here
                
                //Modified By - Abhinav Sharma - 11/28/2015 - CR-20150601-8977
                //Start from here
                //Added By - Abhinav Sharma - 01/29/2015 - CR-20141218-8363
                MemberSupportTriggerUtilities.populateCPRMDataLoadFields(Trigger.new, Trigger.OldMap);
                //Upto Here
                
                //Added By - Abhinav Sharma - 12/02/2015 - CR-20140623-5897
                MemberSupportTriggerUtilities.populateManagerFields(Trigger.new);
                
                //Call helper class method
                MemberSupportTriggerUtilities.UpdateSiteIssueByProject(Trigger.new, Trigger.isUpdate);
                
                //Call helper class method
                MemberSupportTriggerUtilities.populateConsecutivelyDelyedOnSiteIssue(Trigger.new);
                
                //CR-3856
                MemberSupportTriggerUtilities.populateProgramType(trigger.new);
                
                //CR-9760
                MemberSupportTriggerUtilities.populateInstitutionFormalName(trigger.new);
                
                //Added by - Mahendra Swarnkar - 08/24/2016 - CR-20160114-9520
                MemberSupportTriggerUtilities.calculateBusinessHoursAges(Trigger.new, Trigger.oldMap);
                
                //Added by - Mahendra Swarnkar - CR-20160420-9785 - 09/01/2016
                MemberSupportTriggerUtilities.populateMarketDataPeriodFields(Trigger.new, Trigger.oldMap);
            }
            
            //Added By Ajeet Surana - 05/06/2015 -  CR-20140813-6993
            //Start From here
            //Check for the event type
            if(Trigger.isInsert) {
                
                //Call helper class method
                MemberSupportTriggerUtilities.validateAndPopulateQANotes(Trigger.new);
            }
            //End here
            
        } else if(Trigger.isAfter) {
            
            //Check for the event type
            if(Trigger.isInsert || Trigger.isUpdate) {
                
                //Added By - Ajit Surana - 10/16/2014 - CR-20140725-6664
                //Start from here
                //Calling helper class method to update the data
                MemberSupportTriggerUtilities.updateEstimatedProdTeamTransitionDateOnProject(Trigger.new, Trigger.oldMap);
                MemberSupportTriggerUtilities.updateExpectedFileReceivedDateOnProject(Trigger.new, Trigger.oldMap);
                //Upto here
                
                //Call helper class method to update the data
                MemberSupportTriggerUtilities.UpdateProjectBySiteIssue(Trigger.new, Trigger.oldMap);
            }
               
            //Check for type
            if(Trigger.isInsert || Trigger.isUpdate) {
                
                //Modified by - Mahendra Swarnakar - 02/15/2016 - CR-20151210-9456
                //Start from here
                //updates projects when member support records are updated
                MemberSupportTriggerUtilities.updateRelatedProjects(trigger.new);
                //Upto here
            
                //Modified By - Abhinav Sharma - 03-10-2014 - CR-20140224-4603 - Email auto-firing to Members
                //call MemberSupportTriggerUtilities's method 
                if(MemberSupportTriggerUtilities.EXECUTE_SEND_DATA_LOAD_AUTO_EMAIL) {
                    
                    //Added By - Ajit Surana - 02/27/2015 - CR-20150106-8468
                    MemberSupportTriggerUtilities.validateContactFlagValues(Trigger.new, Trigger.oldMap);
                    
                    //call MemberSupportTriggerUtilities's method 
                    MemberSupportTriggerUtilities.SendDataLoadAutoEmail(Trigger.new, Trigger.oldMap);
                    MemberSupportTriggerUtilities.EXECUTE_SEND_DATA_LOAD_AUTO_EMAIL = false;
                }
            }
            
            //Added By - Abhinav Sharma - 07/12/2014 - CR-20140422-5173
            //Start From Here
            //Checking for the request type
            if(Trigger.isInsert) {
                //Calling Helper Class method
                MemberSupportTriggerUtilities.UpdateAssigndToContactOnSiteIssueByProject(Trigger.new);
            }
            //Upto Here
            //Code added by Bhavi Sharma - 02/01/2014 - CR-20140113-4265
            
            //Check for the event type
            if(Trigger.isInsert || Trigger.isUpdate || Trigger.isDelete) {
                
                //Added By Bhavi Sharma - 02/01/2014 - CR-20140113-4265
                MemberSupportTriggerUtilities.updatePunctualityOfLoadsOnTheBasisOfFileRecToNextDataUploadValue(Trigger.New, Trigger.oldMap);
            
                //Re-added by - Mahendra Swarnakar - 02/15/2016 - CR-20151210-9456
                //Added By - Abhinav Sharma - 07/29/2015 - CR-20150709-9070
                MemberSupportTriggerUtilities.populateFieldsOnAssociatedProject(Trigger.New, Trigger.oldMap);
                
                //Re-added by - Mahendra Swarnakar - 02/15/2016 - CR-20151210-9456
                //Added By - Abhinav Sharma - 08/24/2015 - CR-20150127-8596
                MemberSupportTriggerUtilities.populateCPRMCurrentDataPeriodOnProject(Trigger.New, Trigger.oldMap);	
            	
                //Added by - Mahendra Swarnkar - CR-20160420-9785 - 09/01/2016
                MemberSupportTriggerUtilities.populateMarketDataPeriodFieldsOnProject(Trigger.new, Trigger.oldMap);
            }
            
            if (!trigger.isDelete) {
                
                //Determine if a case record needs to be created or synchronized.  CR-4283
                MemberSupportTriggerUtilities.syncMemberSupportToCase(trigger.new, trigger.oldMap);
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