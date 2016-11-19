/**
 *  Description     :   Helper class for Project object trigger.
 *
 *  Created By      :   Bhavi Sharma
 *
 *  Created Date    :   03/25/2013
 *
 *  Revision Logs   :   V_1.0 - Created
                        V_1.1 - Bhavi Sharma - 04/26/2013 - New method added (UpdateProjectByMembershipEvent)- CR-20130408-2822
                        V_1.2 - Bhavi Sharma - 05/17/2013 - Code modified & method added (isChanged) - CR-20130116-2186
                        V_1.2 - Bhavi Sharma - 05/31/2013 - New method added (updateProjectByCurrentRenewalOpportunity) - CR-20130328-2773
                        V_1.3 - Bhavi Sharma - 06/28/2013 - Code commented in method (updateMembershipData) - CR-20130617-3170
                        V_1.4 - Bhavi Sharma - 10/21/2013 - Method updated (updateMembershipData) - CR-20130529-3091
                        V_1.5 - Bhavi Sharma - 12/23/2013 - New method added(UpdateSiteIssueByProject) - CR-20130813-3414
                        V_1.6 - Abhinav Sharma - 03/01/2014 - CR-20140214-4520 - Remove following lines from code
                        V_1.7 - Abhinav Sharma - 03/03/2014 - CR-20130829-3543 - CMA - Elapsed Time Field - Moved to Prod Team
                        V_1.8 - Abhinav Sharma - 03/03/2014 - CR-20140220-4549 - Remove following lines from code
                        V1.9 - Abhinav Sharma - 04/03/2014 - CR-20140220-4549 - Remove Following Lines from code
                        V_1.10 - Abhinav Sharma -  04/29/2014 - CR-20140403-4958 - Modified method: populateFirstDeploymentSignedOff
                        V_1.11 - Ajit Surana - 09/08/2014 - CR-20140716-6256 - Exclude Project Record Type "SSC" from populateFirstDeploymentSignedOff() method
                        V_1.12 - Ajit Surana - 09/08/2014 - CR-20140513-5475 - CMA Project - New Field - Data Lag Month (Method commented out)
                        V_1.13 - Abhinav Sharma - 10/17/2014 - CR-20140826-7138 - New method populateDeploymentSignOffOldest added.
                        V_1.13 - Abhinav Sharma - 10/18/2014 - CR-20140221-4576 - Removed reference of Opportunity_Refresh__c field.
                        V_1.14 - Abhinav Sharma - 11/25/2014 - CR-20141106-8010 - Revert change to Site Live field on SSC projects 
                        V_1.15 - Abhinav Sharma - 06/13/2015 - CR-20150601-8976 - Added new method (validateAndPopulateProjectFields)
                        V_1.16 - Abhinav Sharma - 07/29/2015 - CR-20150709-9070 - Added new method (populateProjectFieldsFromChildren)
                        V_1.17 - Abhinav Sharma - 08/24/2015 - CR-20150127-8596 - Modified existing method (populateProjectFieldsFromChildren)
                        V_1.18 - Abhinav Sharma - 10/20/2015 - CR-20151016-9329 - Modified existing method (populateProjectFieldsFromChildren)
                        V_1.19 - Mahedra Swarnkar - 07/05/2016 - CR-20160229-9651 - Added a new Method "populateCaseFieldsFromProject" to populate case fields from Project
                        V_1.20 - Mahendra Swarnkar - CR-20160420-9785 - 09/01/2016 - Added a new Methods "populateMarketDataPeriodFieldsOnProject" and "populateProjectFieldsFromMemberSupport" to populate the Market data period begin and Market data period End Fields on Project 
**/
public without sharing class ProjectTriggerHelper {
    
    public final static String STATUS_22_PRODUCTION_MIGRATION_COMPLETE = '22 - Production Migration Complete';
    
    //Added By - Mahendra Swarnkar - CR-20160420-9785 - 09/01/2016 - Starts From Here
    public final static String DATA_LOADTYPE_CURRENT = 'Current';
    public final static String DATA_LOADTYPE_OFF_CYCLE_DATA_LOAD_AND_OR_MIGRATION = 'Off Cycle - Data Load and/or Migration';
    public final static String DATA_LOADTYPE_OFF_CYCLE_MIGRATION = 'Off Cycle - Migration Only';
    public final static String MEMBER_SUPPORT_API_NAME = 'Site_Issue__c';
	public final static String MEMBER_SUPPORT_RECORDTYPE_CMA_DATA_LOAD_MIGRATION = 'CMA Data Load/Migration';
    //Added By - Mahendra Swarnkar - CR-20160420-9785 - 09/01/2016 - End Here            
    
    //This method is to set the data on Membership object
    public static void updateMembershipData(List<Project__c> newProjects, Map<Id, Project__c> mapOldProjects) {

        //Create a set of membership Ids
        Set<Id> membershipIds = new Set<Id>();

        //Loop through the Projects and get membership data
        for(Project__c project : newProjects) {

           //Check if membership is not Null
            if(project.Primary_Paid_Membership__c != null
                && (mapOldProjects == null || isChanged(project, mapOldProjects.get(project.Id)))) {

                //Add in membership set
                membershipIds.add(project.Primary_Paid_Membership__c);
            }

            //Add Olfd Membership records Ids
            if(mapOldProjects != null && mapOldProjects.get(project.Id).Primary_Paid_Membership__c != null
                && project.Primary_Paid_Membership__c != mapOldProjects.get(project.Id).Primary_Paid_Membership__c) {

                //Add in membership set
                membershipIds.add(mapOldProjects.get(project.Id).Primary_Paid_Membership__c);
            }
        }

        //Check if records to Process
        if(membershipIds.size() > 0) {

            //Get Membership records from database
            Map<Id, Membership__c> mapMemberships = new Map<Id, Membership__c>([Select Id, Primary_Project__c, Renewal_Opp_Owner__c from Membership__c
                                                                                    where Id IN: membershipIds]);

            //Check for the mebership records
            if(mapMemberships.size() > 0) {

                //Replaced List of records with map of records - Abhinav Sharma - 05/03/2014 - Modified since Taylor got duplicate Id error while historical update - CR-20140403-4958
                //List of membersip records to be updated
                Map<Id, Membership__c> membershipsMap = new Map<Id, Membership__c>();

                //List of Projects to be updated with The membership information
                List<Project__c> projects = new List<Project__c>();

                //Loop through the New Projects
                for(Project__c project : newProjects) {

                    //Check if membership is not Null
                    if(project.Primary_Paid_Membership__c != null
                        && (mapOldProjects == null || isChanged(project, mapOldProjects.get(project.Id)) )) {

                        //Check if there membership do not have Primary_Project__c stamped on it
                        if(mapMemberships.containsKey(project.Primary_Paid_Membership__c)) {

                            //Get Membership object data
                            Membership__c ms = mapMemberships.get(project.Primary_Paid_Membership__c);

                            //Check if primary project is stamped on it
                            if(ms.Primary_Project__c == null || ms.Primary_Project__c == project.Id) {

                                //Create membership instance
                                Membership__c membership = new Membership__c(Id = ms.Id);

                                //Update the Membership record with
                                membership.Primary_Project__c = project.Id;

                                //Bhavi Sharma - 10/21/2013 - CR-20130529-3091
                                if(project.Project_Phase__c != null &&
                                    (project.Project_Phase__c.startsWith('0 - ')
                                        || project.Project_Phase__c.startsWith('1 - ')
                                        || project.Project_Phase__c.startsWith('2 - ')
                                        || project.Project_Phase__c.startsWith('3 - ')
                                        || project.Project_Phase__c.startsWith('4 - '))
                                ) {
                                    membership.BA_Assignment2__c = project.Implementation_Business_Analyst__c;
                                } else
                                    membership.BA_Assignment2__c = project.Recurring_Business_Analyst__c;

                                membership.DA_Assignment2__c = project.Dedicated_Advisor__c;
                                
                                //CR-20140214-4520 - Remove following lines from code 
                                //Commented By Abhinav Sharma - 03-01-2014
                                //membership.Value_Pod__c = project.EHBI_Value_Pod__c;
                                membership.Implementation_Pod__c = project.Implementation_Pod__c;
                                membership.Delivery_Project_Phase__c = project.Project_Phase__c;
                                membership.Relationship_Grade__c = project.Relationship_Grade__c;
                                membership.Relationship_Grade_Notes__c = project.Relationship_Grade_Notes__c;
                                membership.Realized_ROI__c = project.Realized_ROI__c;
                                membership.Site_Live__c = project.Date_Site_Live__c;
                                membership.Path_to_ROI_Grade__c = project.Path_to_ROI__c;
                                membership.Executive_Engagement_Grade__c = project.Executive_Engagement__c;
                                membership.Member_Expectations_Grade__c = project.Institution_Expectations__c;

                                //Code modified - Bhavi Sharma - CR-20130116-2186
                                membership.Active_Outreach_Program__c = project.CMA_Outreach_Program__c;
                                membership.CMA_Current_Activated_Initiatives__c = project.CMA_Current_Activated_Initiatives__c;
                                
                                //CR-20140220-4549 - Remove following lines from code 
                                //Commented By Abhinav Sharma - 03-04-2014
                                //membership.CMA_Initiative_Last_Updated__c = project.CMA_Initiative_Last_Updated__c;
                                membership.CRM_Usage__c = project.CMA_CRM_Usage__c;
                                membership.Goals_and_Work_Plan_Call_Actual__c = project.Goals_Planning__c;
                                membership.Goals_and_Work_Plan_Call_Projected__c = project.Goals_and_Work_Plan_Call_Projected__c;
                                membership.Initial_Opp_Assessment_Actual__c = project.Initial_Opp_Assessment_Presented__c;
                                membership.Initial_Opp_Assessment_Target__c = project.Initial_Opp_Assessment_Projected_Target__c;
                                membership.Initial_Value_Meeting_Projected__c = project.Initial_Value_Meeting_Projected__c;
                                membership.Initial_Value_Meeting_Actual__c = project.initial_value_meeting__c;
                                membership.Initiatives_Series_1__c = project.Initiatives_Series_1__c;
                                membership.Institution_CRM_System__c = project.CMA_CRM_System__c;
                                membership.Institution_Perception_Use_of_Site_Data__c = project.Institution_Perception_Use_of_Site_Data__c;
                                membership.Last_Case_Study__c = project.Date_LastCaseStudy__c;
                                membership.Last_Cohort_Summit_Attendance__c = project.Date_Last_Cohort_Summit_Attendance__c;
                                membership.Last_Onsite__c = project.Date_Last_Onsite__c;
                                
                                //Commented By - Abhinav Sharma - 10/18/2014 - CR-20140221-4576 
                                //membership.Last_Opportunity_Refresh__c = project.Opportunity_Refresh__c;
                                membership.Last_Sponsor_Update__c = project.date_last_sponsor_update__c;
                                membership.Last_Value_Summit__c = project.Last_Value_Summit__c;
                                membership.Launch_and_Onboarding_Planning_Actual__c = project.Launch_and_Onboarding_Planning__c;
                                membership.Launch_Onboarding_Planning_Projected__c = project.Launch_Onboarding_Planning_Projected__c;
                                membership.Licensed_Providers__c = project.CPM_Licensed_Providers__c;
                                membership.Next_Onsite_Target__c = project.Next_Onsite_Target__c;
                                membership.Next_Opportunity_Refresh_Target__c = project.Opportunity_Refresh_Target__c;
                                membership.Next_Sponsor_Update_Target__c = project.Next_Sponsor_Update_Target__c;
                                membership.Notes_Dedicated_Advisor__c = project.Notes_Dedicated_Advisor__c;
                                membership.Outreach_Plan_Development_Actual__c = project.Outreach_Plan_Development_Actual__c;
                                membership.Outreach_Plan_Development_Projected__c = project.Outreach_Plan_Development_Projected__c;
                                membership.Primary_Relationship_Risk_Category__c = project.Primary_Relationship_Risk_Category__c;
                                membership.PT_Member_Health__c = project.PT_Member_Health__c;
                                membership.Regular_Call_Schedule__c = project.Regular_Call_Schedule__c;
                                membership.Reference_Ambassador_Comments__c = project.Reference_Ambassador_Comments__c;
                                membership.Reference_Ready__c = project.Reference_Ready__c;
                                membership.Relationship_Trending__c = project.Relationship_Trending__c;
                                membership.ROI_Framework_Actual__c = project.ROI_Framework_Actual__c;
                                membership.ROI_Framework_Projected__c = project.ROI_Framework_Projected__c;
                                membership.ROI_Review_Actual__c = project.ROI_Review__c;
                                membership.ROI_Review_Target__c = project.ROI_Review_Target__c;
                                membership.Secondary_Relationship_Risk_Category__c = project.Relationship_Risk_Category_2__c;
                                //Commented By Abhinav Sharma - 04/03/2014 - CR-20140220-4549
                                //membership.Series_1_Initiatives_Activated_Actual__c = project.Series_1_Initiatives_Activated_Actual__c;
                                membership.Series_1_Initiatives_Activated_Target__c = project.Series_1_Initiatives_Activated_Target__c;
                                //Commented By Abhinav Sharma - 04/03/2014 - CR-20140220-4549
                                //membership.Series_1_Initiatives_Created_Actual__c = project.Series_1_Initiatives_Created_Actual__c;
                                membership.Series_1_Initiatives_Created_Target__c = project.Series_1_Initiatives_Created_Target__c;
                                membership.Service_Plan_Delivery_Actual__c = project.Service_Plan_Delivery_Actual__c;
                                membership.Service_Plan_Delivery_Projected__c = project.Service_Plan_Delivery_Projected__c;
                                membership.Value_Team__c = project.Value_Team__c;
                                membership.Value_Team_Comments__c = project.Value_Team_Comments__c;

                                //Update the Membership record with
                                membershipsMap.put(membership.Id, membership);
                            }
                            //Code commented - Bhavi Sharma - 06/28/2013 - CR-20130617-3170
                            /* else {

                                throw new CustomException(Label.ERROR_ALREADY_PROJECT_ASSOCIATED);
                            }*/
                        }
                    }

                    //Check for the old records
                    if(mapOldProjects != null && mapOldProjects.get(project.Id).Primary_Paid_Membership__c != null
                        && project.Primary_Paid_Membership__c != mapOldProjects.get(project.Id).Primary_Paid_Membership__c) {

                        //Check if there membership do not have Primary_Project__c stamped on it
                        if(mapMemberships.containsKey(mapOldProjects.get(project.Id).Primary_Paid_Membership__c)) {

                            //Get Membership object data
                            Membership__c ms = mapMemberships.get(mapOldProjects.get(project.Id).Primary_Paid_Membership__c);

                            //Create membership instance
                            Membership__c membership = new Membership__c(Id = ms.Id);

                            //Update the Membership record with
                            membership.Primary_Project__c = null;
                            membership.BA_Assignment2__c = null;
                            membership.DA_Assignment2__c = null;
                            
                            //CR-20140214-4520 - Remove following lines from code 
                            //Commented By Abhinav Sharma - 03-01-2014
                            //membership.Value_Pod__c = null;
                            membership.Implementation_Pod__c = null;
                            membership.Delivery_Project_Phase__c = null;
                            membership.Relationship_Grade__c = null;
                            membership.Relationship_Grade_Notes__c = null;
                            membership.Realized_ROI__c = null;
                            membership.Site_Live__c = null;
                            membership.Path_to_ROI_Grade__c = null;
                            membership.Executive_Engagement_Grade__c = null;
                            membership.Member_Expectations_Grade__c = null;

                            //Code modified - Bhavi Sharma - CR-20130116-2186
                            membership.Active_Outreach_Program__c = null;
                            membership.CMA_Current_Activated_Initiatives__c = null;
                            
                            //CR-20140220-4549 - Remove following lines from code 
                            //Commented By Abhinav Sharma - 03-04-2014
                            //membership.CMA_Initiative_Last_Updated__c  = null;
                            membership.CRM_Usage__c  = null;
                            membership.Goals_and_Work_Plan_Call_Actual__c = null;
                            membership.Goals_and_Work_Plan_Call_Projected__c  = null;
                            membership.Initial_Opp_Assessment_Actual__c  = null;
                            membership.Initial_Opp_Assessment_Target__c  = null;
                            membership.Initial_Value_Meeting_Projected__c  = null;
                            membership.Initial_Value_Meeting_Actual__c  = null;
                            membership.Initiatives_Series_1__c  = null;
                            membership.Institution_CRM_System__c  = null;
                            membership.Institution_Perception_Use_of_Site_Data__c = null;
                            membership.Last_Case_Study__c  = null;
                            membership.Last_Cohort_Summit_Attendance__c = null;
                            membership.Last_Onsite__c  = null;
                            membership.Last_Opportunity_Refresh__c = null;
                            membership.Last_Sponsor_Update__c  = null;
                            membership.Last_Value_Summit__c  = null;
                            membership.Launch_and_Onboarding_Planning_Actual__c = null;
                            membership.Launch_Onboarding_Planning_Projected__c  = null;
                            membership.Licensed_Providers__c  = null;
                            membership.Next_Onsite_Target__c  = null;
                            membership.Next_Opportunity_Refresh_Target__c = null;
                            membership.Next_Sponsor_Update_Target__c  = null;
                            membership.Notes_Dedicated_Advisor__c  = null;
                            membership.Outreach_Plan_Development_Actual__c  = null;
                            membership.Outreach_Plan_Development_Projected__c  = null;
                            membership.Primary_Relationship_Risk_Category__c  = null;
                            membership.PT_Member_Health__c  = null;
                            membership.Regular_Call_Schedule__c  = null;
                            membership.Reference_Ambassador_Comments__c  = null;
                            membership.Reference_Ready__c  = null;
                            membership.Relationship_Trending__c  = null;
                            membership.ROI_Framework_Actual__c  = null;
                            membership.ROI_Framework_Projected__c  = null;
                            membership.ROI_Review_Actual__c  = null;
                            membership.ROI_Review_Target__c  = null;
                            membership.Secondary_Relationship_Risk_Category__c = null;
                            membership.Series_1_Initiatives_Activated_Actual__c  = null;
                            membership.Series_1_Initiatives_Activated_Target__c  = null;
                            //Commented By Abhinav Sharma - 04/03/2014 - CR-20140220-4549
                            membership.Series_1_Initiatives_Created_Actual__c  = null;
                            membership.Series_1_Initiatives_Created_Target__c  = null;
                            membership.Service_Plan_Delivery_Actual__c  = null;
                            membership.Service_Plan_Delivery_Projected__c  = null;
                            membership.Value_Team__c  = null;
                            membership.Value_Team_Comments__c = null;

                            //Update the Membership record with
                            membershipsMap.put(membership.Id, membership);
                        }
                    }

                }
                System.debug('@@@@ memberships ' + membershipsMap.values());
                //Update membership records
                if(membershipsMap.values().size() > 0) {

                    //No need to execute any trigger
                    Util.BypassAllTriggers = true;
                    update membershipsMap.values();
                }
            }
        }
    }

    //This method is to update PT QA Call Event DT & PT QA Call Recommended Score fields on Project__c object - CR-20130408-2822
    public static void UpdateProjectByMembershipEvent(List<Project__c> listNewProjects, Map<Id, Project__c> mapOldProjects){

        //Set of Memberships associated with Project
        Set<Id> setMembershipIds = new Set<Id>();

        //Loop through the Trigger.new
        for(Project__c project : listNewProjects){

            //Check Project is data and execute the code only if require
            if(project.Primary_Paid_Membership__c != null ){

                //add membership into set
                setMembershipIds.add(project.Primary_Paid_Membership__c);
            }
        }

        //Check if there is any data to process
        if(setMembershipIds.size() >0){

            //Create map for Memebership with Event
            Map<Id,Event> mapMembershipWithEvent = new Map<Id,Event>();

            //get data from data base and loop through the results
            for(Event event : [SELECT StartDateTime, Cancelled_Did_Not_Occur__c, Would_Buy_Again__c, ActivityDate, WhatId
                                          FROM Event
                                            WHERE WhatId IN :setMembershipIds
                                                AND RecordType.DeveloperName =: Constants.RECORD_TYPE_EVENT_DEVELOPER_NAME_BI_QA_CALL
                                                AND Cancelled_Did_Not_Occur__c = false AND StartDateTime < Last_N_Days:364]){

                //Check Same membership hold event
                if(mapMembershipWithEvent.containsKey(event.WhatId)) {

                    //Event instance get from map
                    Event existingEvent = mapMembershipWithEvent.get(event.WhatId);

                    //Check most recent event
                    if(event.StartDateTime > existingEvent.StartDateTime) {

                        //put Id = Membership , Key = Event Record
                        mapMembershipWithEvent.put(event.WhatId, event);
                    }
                } else {

                    //put Id = Membership , Key = Event Record
                    mapMembershipWithEvent.put(event.WhatId, event);
                }
            }

            //Loop through trigger.new
            for(Project__c project : listNewProjects){

                //Check map is already contains the membership associate with project
                if(project.Primary_Paid_Membership__c != null && mapMembershipWithEvent.containsKey(project.Primary_Paid_Membership__c)) {

                    //Get event
                    Event event = mapMembershipWithEvent.get(project.Primary_Paid_Membership__c);

                    //Check event's Start Date Time
                    project.PT_QA_Call_Event_DT__c = event.StartDateTime;

                    //Check event's Would Renew
                    if(event.Would_Buy_Again__c != null && event.Would_Buy_Again__c != '' && event.Would_Buy_Again__c.isNumeric()) {

                        //assigning event's field Would renew value to Project
                        project.PT_QA_Call_Recommended_Score__c = Integer.valueOf(event.Would_Buy_Again__c);
                    } else{

                        //Set null
                        project.PT_QA_Call_Recommended_Score__c = null;
                    }
                }
            }
        }
    }

    //Code modified - Bhavi Sharma - CR-20130116-2186
    //Boolean method for comparison of project data to its previous data
    public static Boolean isChanged(Project__c newProject, Project__c oldProject){

        //CR-20140214-4520 - Remove following lines from code -  || newProject.EHBI_Value_Pod__c != oldProject.EHBI_Value_Pod__c 
        //CR-20140220-4549 - Remove following lines from code - || newProject.CMA_Initiative_Last_Updated__c != oldProject.CMA_Initiative_Last_Updated__c
        //Specified condition removed from If statement By Abhinav Sharma - 03-01-2014
        //Removed By Abhinav Sharma - 04/03/2014 - CR-20140220-4549
        //|| newProject.Series_1_Initiatives_Activated_Actual__c != oldProject.Series_1_Initiatives_Activated_Actual__c
        //|| newProject.Series_1_Initiatives_Created_Actual__c != oldProject.Series_1_Initiatives_Created_Actual__c 
        //Check for newProject data is not equal to oldProject data
        if(newProject.Primary_Paid_Membership__c != oldProject.Primary_Paid_Membership__c
                    || newProject.Project_Phase__c != oldProject.Project_Phase__c
                    || newProject.Implementation_Business_Analyst__c != oldProject.Implementation_Business_Analyst__c
                    || newProject.Recurring_Business_Analyst__c != oldProject.Recurring_Business_Analyst__c
                    || newProject.Dedicated_Advisor__c != oldProject.Dedicated_Advisor__c
                    || newProject.Implementation_Pod__c != oldProject.Implementation_Pod__c
                    || newProject.Project_Phase__c != oldProject.Project_Phase__c
                    || newProject.Relationship_Grade__c != oldProject.Relationship_Grade__c
                    || newProject.Relationship_Grade_Notes__c != oldProject.Relationship_Grade_Notes__c
                    || newProject.Realized_ROI__c != oldProject.Realized_ROI__c
                    || newProject.Date_Site_Live__c != oldProject.Date_Site_Live__c
                    || newProject.Path_to_ROI__c != oldProject.Path_to_ROI__c
                    || newProject.Executive_Engagement__c != oldProject.Executive_Engagement__c
                    || newProject.Institution_Expectations__c != oldProject.Institution_Expectations__c
                    || newProject.CMA_Outreach_Program__c != oldProject.CMA_Outreach_Program__c
                    || newProject.CMA_Current_Activated_Initiatives__c != oldProject.CMA_Current_Activated_Initiatives__c
                    || newProject.CMA_CRM_Usage__c != oldProject.CMA_CRM_Usage__c
                    || newProject.Goals_Planning__c != oldProject.Goals_Planning__c
                    || newProject.Goals_and_Work_Plan_Call_Projected__c != oldProject.Goals_and_Work_Plan_Call_Projected__c
                    || newProject.Initial_Opp_Assessment_Presented__c != oldProject.Initial_Opp_Assessment_Presented__c
                    || newProject.Initial_Opp_Assessment_Projected_Target__c != oldProject.Initial_Opp_Assessment_Projected_Target__c
                    || newProject.Initial_Value_Meeting_Projected__c != oldProject.Initial_Value_Meeting_Projected__c
                    || newProject.initial_value_meeting__c != oldProject.initial_value_meeting__c
                    || newProject.Initiatives_Series_1__c != oldProject.Initiatives_Series_1__c
                    || newProject.CMA_CRM_System__c != oldProject.CMA_CRM_System__c
                    || newProject.Institution_Perception_Use_of_Site_Data__c != oldProject.Institution_Perception_Use_of_Site_Data__c
                    || newProject.Date_LastCaseStudy__c != oldProject.Date_LastCaseStudy__c
                    || newProject.Date_Last_Cohort_Summit_Attendance__c != oldProject.Date_Last_Cohort_Summit_Attendance__c
                    || newProject.Date_Last_Onsite__c != oldProject.Date_Last_Onsite__c
                    
                    //Commented By Abhinav Sharma - 10/18/2014 - CR-20140221-4576
                    //|| newProject.Opportunity_Refresh__c != oldProject.Opportunity_Refresh__c
                    
                    || newProject.date_last_sponsor_update__c != oldProject.date_last_sponsor_update__c
                    || newProject.Last_Value_Summit__c != oldProject.Last_Value_Summit__c
                    || newProject.Launch_and_Onboarding_Planning__c != oldProject.Launch_and_Onboarding_Planning__c
                    || newProject.Launch_Onboarding_Planning_Projected__c != oldProject.Launch_Onboarding_Planning_Projected__c
                    || newProject.CPM_Licensed_Providers__c != oldProject.CPM_Licensed_Providers__c
                    || newProject.Next_Onsite_Target__c != oldProject.Next_Onsite_Target__c
                    || newProject.Opportunity_Refresh_Target__c != oldProject.Opportunity_Refresh_Target__c
                    || newProject.Next_Sponsor_Update_Target__c != oldProject.Next_Sponsor_Update_Target__c
                    || newProject.Notes_Dedicated_Advisor__c != oldProject.Notes_Dedicated_Advisor__c
                    || newProject.Outreach_Plan_Development_Actual__c != oldProject.Outreach_Plan_Development_Actual__c
                    || newProject.Outreach_Plan_Development_Projected__c != oldProject.Outreach_Plan_Development_Projected__c
                    || newProject.Primary_Relationship_Risk_Category__c != oldProject.Primary_Relationship_Risk_Category__c
                    || newProject.PT_Member_Health__c != oldProject.PT_Member_Health__c
                    || newProject.Regular_Call_Schedule__c != oldProject.Regular_Call_Schedule__c
                    || newProject.Reference_Ambassador_Comments__c != oldProject.Reference_Ambassador_Comments__c
                    || newProject.Reference_Ready__c != oldProject.Reference_Ready__c
                    || newProject.Relationship_Trending__c != oldProject.Relationship_Trending__c
                    || newProject.ROI_Framework_Actual__c != oldProject.ROI_Framework_Actual__c
                    || newProject.ROI_Framework_Projected__c != oldProject.ROI_Framework_Projected__c
                    || newProject.ROI_Review__c != oldProject.ROI_Review__c
                    || newProject.ROI_Review_Target__c != oldProject.ROI_Review_Target__c
                    || newProject.Relationship_Risk_Category_2__c != oldProject.Relationship_Risk_Category_2__c
                    || newProject.Series_1_Initiatives_Activated_Target__c != oldProject.Series_1_Initiatives_Activated_Target__c
                    || newProject.Series_1_Initiatives_Created_Target__c != oldProject.Series_1_Initiatives_Created_Target__c
                    || newProject.Service_Plan_Delivery_Actual__c != oldProject.Service_Plan_Delivery_Actual__c
                    || newProject.Service_Plan_Delivery_Projected__c != oldProject.Service_Plan_Delivery_Projected__c
                    || newProject.Value_Team__c != oldProject.Value_Team__c
                    || newProject.Value_Team_Comments__c != oldProject.Value_Team_Comments__c){

            return true;
        } else {

            return false;
        }
    }

    //Bhavi Sharma - 05/31/2013 - CR-20130328-2773
    //This method is to pull the "Source Contract Type" and "Special Committments" data from current renewal opportunities
    //and will stamp these values on Project object in "Current Contract Risk Type" and "Special Considerations" fields
    //Current renewal opportunity will be idestified with opportunties related to PPM(Primary Paid Membership) on Project
    public static void updateProjectByCurrentRenewalOpportunity(List<Project__c> projects) {

        //Create a set of membership ids
        Set<Id> membershipIds = new Set<Id>();

        //Loop through the project data and create a set of membership records
        for(Project__c project : projects) {

            //Check if PPM is not null on record
            if(project.Primary_Paid_Membership__c != null) {

                //Add in set
                membershipIds.add(project.Primary_Paid_Membership__c);
            }
        }

        //Check for the size and process results
        if(membershipIds.size() > 0) {

            //String to hold teh current yeat
            String currentYear = String.valueOf(Date.today().year());

            //Create a map to hold teh Membership with Current renewal opportunities
            Map<Id, Opportunity> mapMembershipWithOpportunity = new Map<Id, Opportunity>();

            //Query all the opporutnity records related to membership
            for(Opportunity opportunity : [Select Id, Membership__c, Pool_Year__c, Pool_Date__c, Source_Contract_Type__c, Special_Commitments__c from Opportunity where
                                            Membership__c IN: membershipIds
                                            AND (
                                                    Pool_Year__c =: currentYear
                                                    OR (Pool_Date__c > TODAY AND Pool_Date__c < NEXT_N_QUARTERS:2)
                                                    OR (IsClosed = false AND Pool_Date__c < TODAY AND Pool_Date__c > LAST_N_QUARTERS:4)
                                                )
                                            ]) {

                //Add opportunity record in map if not already exists
                if(mapMembershipWithOpportunity.containsKey(opportunity.Membership__c)) {

                    //Get opportunity data from Map
                    Opportunity existingOpportunity = mapMembershipWithOpportunity.get(opportunity.Membership__c);

                    //1. Check if existingOpportunity is in current Year, no need to do anything then
                    //2. existingOpportunity is not in current Year, but current opportunity is, replace the Opportunity record
                    //3. existingOpportunity is in Next 2 Quaters, no need to do anythin
                    //4. existingOpportunity is not in Next 2 quarters, but current opportunity is, replace the Opportunity record
                    //5. No need to change existingOpportunity record as thsi will be from Last 4 quarters already
                    if(existingOpportunity.Pool_Year__c == currentYear) {

                        //move to next record
                        continue;
                    } else if(opportunity.Pool_Year__c == currentYear) {

                        //replace opportunity record in map
                        mapMembershipWithOpportunity.put(opportunity.Membership__c, opportunity);
                    } else if(existingOpportunity.Pool_Date__c > Date.today()) {

                        //move to next record
                        continue;
                    } else if(opportunity.Pool_Date__c > Date.today()) {

                        //replace opportunity record in map
                        mapMembershipWithOpportunity.put(opportunity.Membership__c, opportunity);
                    }
                } else {

                    //Add opportunity in map
                    mapMembershipWithOpportunity.put(opportunity.Membership__c, opportunity);
                }
            }

            //Loop through the project records
            for(Project__c project : projects) {

                //Check if Membership is not null
                if(project.Primary_Paid_Membership__c != null && mapMembershipWithOpportunity.containsKey(project.Primary_Paid_Membership__c)) {

                    //Populate data from opportunity's "Source Contract Type" and "Special Committments" fields to project's "Current Contract Risk Type" and "Special Considerations"
                    project.Current_Contract_Risk_Type__c = mapMembershipWithOpportunity.get(project.Primary_Paid_Membership__c).Source_Contract_Type__c;
                    project.CPM_Special_Considerations__c = mapMembershipWithOpportunity.get(project.Primary_Paid_Membership__c).Special_Commitments__c;
                }
            }
        }
    }
    
    //Code added By - Bhavi Sharma - 12/23/2013 - CR-20130813-3414
    /**
     *  @description    :   Whenever Implementation_Pod__c or Crimson_Data_Lag__c field is updated on Project record:
                                a. Query all the related Member Support records where record type is not equals to CMA Data Load/Migration and CMA Initial Deployment Support.
                                b. Update Member Support's Implementation_Pod_1__c and Crimson_Data_Lag_1__c with the Project's Implementation_Pod__c and Crimson_Data_Lag__c.
     * 
     *  @args           :   List of new project records, Map of old project Id and instance 
     * 
     *  @return         :   void
     * 
     **/
    public static void UpdateSiteIssueByProject(List<Project__c> listNewProjects, Map<Id, Project__c> mapOldProjects) {

        //List of ProjectId which have either change in Implementation_Pod__c or Crimson_Data_Lag__c or both
        List<Project__c> projects = new List<Project__c>();

        //Loop through new list
        for(Project__c project : listNewProjects) {

            //Check Project__c field is not null
            if(project.Implementation_Pod__c != mapOldProjects.get(project.Id).Implementation_Pod__c 
                || project.Application__c != mapOldProjects.get(project.Id).Application__c) {

                //add Project in List
                projects.add(project);
            }
        }

        //Check for the project size
        if(projects.size() > 0) {
            
            //Query all the Site issues related to these Projects and record type not in CMA Data Load/Migration and CMA Initial Deployment Support
            //Set to hold recordType names
            Set<String> recordTypeNames = New Set<String>();
            recordTypeNames.add('CMA Data Load/Migration');
            recordTypeNames.add('CMA Initial Deployment Support');
            
            //fetch all the records to be updated
            List<Site_Issue__c> siteIssues = [Select Id, RecordType.Name, Project__r.Application__c, Project__r.Implementation_Pod__c, Project__r.Crimson_Data_Lag__c from Site_Issue__c where Project__c IN: projects AND RecordType.Name NOT IN: recordTypeNames];
            
            //Loop through Site Issues to be updated
            for(Site_Issue__c siteIssue : siteIssues) {
                
                //Update Site Issue data
                siteIssue.Project_Implementation_Pod_1__c = siteIssue.Project__r.Implementation_Pod__c;
                siteIssue.Crimson_Data_Lag_1__c = siteIssue.Project__r.Crimson_Data_Lag__c;
                
                //Added by Bhavi - 02/10/2014 - CR-20131213-4161
                //Check if it's CPM Data Load, then populate Application Version from Parent project
                if(siteIssue.RecordType.Name.equalsIgnoreCase('CPM Data Load'))
                    siteIssue.Application_Version__c = siteIssue.Project__r.Application__c;
            }
            
            //check for the size
            if(siteIssues.size() > 0) {
                
                //Turnoff all the triggers
                Util.BypassAllTriggers = true;
                
                update siteIssues;    
            }
        }
    }
    
    //Modified By - Ajit Surana - 09/08/2014 - CR-20140716-6256 - Exclude Project Record Type "SSC" from this method
    //Added By - Abhinav Sharma - 03-03-2014 - CR-20130829-3543 - CMA - Elapsed Time Field - Moved to Prod Team
    //Modified By - Abhinav Sharma -  04/29/2014 - CR-20140403-4958 - Site Live - Target, Actual - not completed with 3968
    //Modified By - Abhinav Sharma - 11/25/2014 - CR-20141106-8010 - Revert change to Site Live field on SSC projects
    /**
     *  @description    :   Method to set First_Deployment_Signed_Off__c field on the Project with the earliest value from the "Deployment Sign Off (Actual)" field on 
     *                      the associated Deployment record whenever the project record is updated.
     *
     *  @args           :   List of projects
     *
     *  @return         :   void
     *
    **/
    public static void populateFirstDeploymentSignedOff(List<Project__c> newProjects) {
        
        //Set to hold the project ids
        Set<Id> setProjectIds = new Set<Id>();
        
        //Loop through project records
        for(Project__c pro : newProjects)
            setProjectIds.add(pro.Id);
            
        //Chech set size before executing the further logic
        if(setProjectIds.size() == 0)
            return;
            
        //Map of Projects
        Map<Id, Project__c> mapProjects = new Map<Id, Project__c>();
        
        //Modified By - Ajit Surana - CR-20140716-6256 - 09/08/2014 - Added an extra filter of Record Type not equal to 'SSC'
        //Modified By - Abhinav Sharma - 11/25/2014 - CR-20141106-8010 - Removed filter of record type not equals to 'SSC'    
        //Querying project record with the oldest value from the "Deployment Sign Off (Actual)" field on the associated Deployment record     
        for(Project__c project : [SELECT Id, First_Deployment_Signed_Off__c, Date_Site_Live__c, Site_Live_Target__c, 
                                     (SELECT Id, C_A_DC__c, C_E_DC__c FROM Deployments__r 
                                         WHERE C_A_DC__c != null ORDER BY C_A_DC__c ASC LIMIT 1)
                                FROM Project__c WHERE Id IN : setProjectIds]) {
            
            //Only Process the record if found and
            if(project.Deployments__r.size() > 0) {

                //Add record in the list to be updated
                project.First_Deployment_Signed_Off__c = project.Deployments__r[0].C_A_DC__c;
                project.Date_Site_Live__c = project.Deployments__r[0].C_A_DC__c;
                project.Site_Live_Target__c = project.Deployments__r[0].C_E_DC__c;
                    
                //Adding record back into newMap values
                mapProjects.put(project.ID, project);
            
            } 
        }
        
        //Modified By - Ajit Surana - CR-20140716-6256 - 09/08/2014 - Added an extra filter of Record Type not equal to 'SSC'
        //Modified By - Abhinav Sharma - 11/25/2014 - CR-20141106-8010 - Removed filter of record type not equals to 'SSC'   
        //Populating map with oldest Deployment Sign Off(Expected) field value in case when no deployment record will have Deployment Sign Off (Actual) field populated with them
        //Querying project record with the oldest value from the "Deployment Sign Off (Actual)" field on the associated Deployment record     
        for(Project__c project : [SELECT Id, First_Deployment_Signed_Off__c, Date_Site_Live__c, Site_Live_Target__c, 
                                     (SELECT Id, C_A_DC__c, C_E_DC__c FROM Deployments__r 
                                         WHERE C_E_DC__c != null ORDER BY C_E_DC__c ASC LIMIT 1)
                                FROM Project__c WHERE Id IN : setProjectIds AND ID NOT IN : mapProjects.keySet()]) {
            
            //Only Process the record if found and
            if(project.Deployments__r.size() > 0) {

                //Add record in the list to be updated
                project.First_Deployment_Signed_Off__c = project.Deployments__r[0].C_A_DC__c;
                project.Date_Site_Live__c = project.Deployments__r[0].C_A_DC__c;
                project.Site_Live_Target__c = project.Deployments__r[0].C_E_DC__c;
                    
                //Adding record back into newMap values
                mapProjects.put(project.ID, project);
            }   
        }
        
        //Loop through project records        
        for(Project__c proj : newProjects) {
            //Checking for value in the map
            if(mapProjects.containsKey(proj.Id)) {
                proj.First_Deployment_Signed_Off__c = mapProjects.get(proj.Id).First_Deployment_Signed_Off__c;
                proj.Date_Site_Live__c = mapProjects.get(proj.Id).Date_Site_Live__c; 
                proj.Site_Live_Target__c = mapProjects.get(proj.Id).Site_Live_Target__c;
            } else {
                proj.First_Deployment_Signed_Off__c = null;
                proj.Date_Site_Live__c = null; 
                proj.Site_Live_Target__c = null;
            }       
        }
    }
    
    //Added By - Ajit Surana - 09/08/2014 - CR-20140513-5475
    /*public static Integer calculateLastDayOfMonth(Project__c project){
        
        //Variables helpful in calculation
        Integer sumOfDates = 0;
        Integer loadFrequency = 0;
        Integer lastDayOfMonth;

        //Checking & validating field value for blank/null value
        if(project.Current_Data_Period_New__c != null && String.isNotBlank(project.Data_Lag_Month__c)) {
            
            //Making calculation for "Load Frequency" field 
            If(project.Load_Frequency__c == 'Monthly')
                loadFrequency = 1;
            else if(project.Load_Frequency__c == 'Quarterly')
                loadFrequency = 3;
            else
                loadFrequency = 0;
                
            System.debug('@@@@@ loadFrequency ' + loadFrequency);
            
            //Variable to hold the intermediate calculations for fields
            sumOfDates = project.Current_Data_Period_New__c.month() + Integer.valueOf(project.Data_Lag_Month__c) + loadFrequency;
            System.debug('@@@@@ sumOfDates ' + sumOfDates);
            
            //Calculation for getting last day of the month based on the other fields value
            lastDayOfMonth = (Date.newinstance((project.Current_Data_Period_New__c.year() + sumOfDates/12), (Math.mod(sumOfDates, 12)+1), 1) - 1).day();
            System.debug('@@@@@ lastDayOfMonth ' + lastDayOfMonth);
            System.debug('@@@@@@@@ date value ' + (Date.newinstance((project.Current_Data_Period_New__c.year() + sumOfDates/12), (Math.mod(sumOfDates, 12)+1), 1) - 1));
        }
        
        return lastDayOfMonth;
    }*/
    
    //Added By - Abhinav Sharma - 10/17/2014 - CR-20140826-7138
    /**
     *  @description    :   Method is used to autopopulate the Deployment Sign-Off (Oldest) field on Project when a related Deployment record is 
     *                      created/updated/deleted and the Project's Record Type = "RCS".
     *                          1)  "Deployment Sign-Off (Oldest)" should be automatically updated to the oldest Deployment Sign Off (Actual) date.
     *
     *  @args           :   List of deployments, Map of old Deployments
     *
     *  @return         :   void
     *
     **/
    public static void populateDeploymentSignOffOldest(List<Project__c> newProjects, Map<Id, Project__c> mapOldProjects) {
        
        //Set to hold Project Id of Deployment record
        Set<Id> projectIds = new Set<Id>();
        
        //Query result of RCS record Type of Project sobject
        Id rcsRecordTypeId = [Select Id FROM RecordType WHERE SobjectType = 'Project__c' AND DeveloperName = 'RCS' AND IsActive = true].Id;
        
        //Map to hold key=> ProjectId & value=> instance of Project sobject
        Map<Id, Project__c> mapProjectToBeUpdated = new Map<Id, Project__c>();
        
        if(rcsRecordTypeId != null) {
        
            //Loop through Trigger.new
            for(Project__c newProject : newProjects) {
                
                //Check if Project is update on Deployment from previous
                if(newProject.RecordTypeId == rcsRecordTypeId && mapOldProjects != null 
                        && newProject.Deployment_Sign_Off_Oldest__c != mapOldProjects.get(newProject.Id).Deployment_Sign_Off_Oldest__c)
                    projectIds.add(newProject.Id);
            }
        }
    
        if(projectIds.size() > 0)
            mapProjectToBeUpdated = DeploymentTriggerHelper.getRCSProjectToUpdate(projectIds);
        
        //update the Projects with their "Deployment Sign-Off (Oldest)"
        if(mapProjectToBeUpdated.size() > 0)
            update mapProjectToBeUpdated.values();
    }
    
    //Added By - Abhinav Sharma - 06/13/2015 - CR-20150601-8976
    /**
     *  @description    :   Method to validate and then populate fields on project records. (On before events)
     * 
     *  @args           :   List of projects
     *
     *  @return         :   void
     *
     **/
    public static void validateAndPopulateProjectFields(List<Project__c> projects) {
        
        //Map of project record types'
        Map<Id, RecordType> mapRecordTypes = new Map<Id, RecordType>([SELECT ID FROM RecordType 
                                                                        WHERE sObjectType = 'Project__c'
                                                                            AND IsActive = true
                                                                            AND DeveloperName = 'Talent_Development']);

        //Loop through project records
        for(Project__C proj : projects) {
            
            //Checking and then executing below written logic for specific record type of project object
            if(proj.recordTypeId != null 
                && mapRecordTypes != null 
                && mapRecordTypes.containsKey(proj.recordTypeId)
                &&mapRecordTypes.get(proj.recordTypeId) != null) {
                
                //Checking "Service Date Start" field for null value
                if(proj.Service_Date_Start__c != null) {
                   
                    //Populating fields on project records accordingly
                    proj.Welcome_Call_Expected__c = proj.Service_Date_Start__c + 21;
                    proj.Project_Planning_Call_Projected__c = proj.Service_Date_Start__c + 60;
                    proj.Service_Plan_Delivery_Projected__c = proj.Service_Date_Start__c + 70;
               
                } else {
                    
                    //Populating fields on project records accordingly
                    proj.Welcome_Call_Expected__c = null;
                    proj.Project_Planning_Call_Projected__c = null;
                    proj.Service_Plan_Delivery_Projected__c = null;
               }
            }
        }
    }
    
    //Modified By - Abhinav Sharma - 10/20/2015 - CR-20151016-9329 
    //Added By - Abhinav Sharma - 07/29/2015 - CR-20150709-9070
    /**
     *  @description    :   Method to validate and then populate PRM Version field on project records. (On before events)
     * 
     *  @args           :   List of projects
     *
     *  @return         :   void
     *
    **/
    public static void populateProjectFieldsFromChildren(List<Project__c> newProjects, Map<Id, Project__c> mapOldProjects) {
        
        //Set to hold the project Ids
        Set<id> setProjectsIds = new Set<Id>();
        
        //Loop through project records and populating the set accordingly
        for(Project__c p : newProjects)
            setProjectsIds.add(p.Id);
        
        //Checking set for size value
        if(setProjectsIds.size() > 0) {
            
            //Map to hold the Project ID as key and Most recent MS record as value
            Map<Id, Site_Issue__c> mapProjectWithMostRecentMS = new Map<Id, Site_Issue__c>();
        
            //Modified By - Abhinav Sharma - 10/20/2015 - CR-20151016-9329 - Added additional filter criteria for Data_Load_Type__c
            //Querying MS records associated with the project records and fulling all the eligibilty criteria's
            for(Project__c pro : [Select ID, 
                                    (SELECT ID, Project__c, PRM_Application_Version__c FROM Site_Issues__r 
                                     WHERE Project__c  != null AND Project__c IN : newProjects
                                     AND RecordType.DeveloperName = 'CMA_Data_Load_Production'
                                     AND Site_Issue_Close_Date__c != null
                                     AND Status__c =: ProjectTriggerHelper.STATUS_22_PRODUCTION_MIGRATION_COMPLETE
                                     AND Data_Load_Type__c = 'PRM Migration'
                                     ORDER BY Site_Issue_Close_Date__c DESC LIMIT 1)
                                 FROM Project__c WHERE ID IN : setProjectsIds]) {
                                 
                //Checking for value in the map and populating it if value does exist in prior
                if(!mapProjectWithMostRecentMS.containsKey(pro.ID) 
                   && pro.Site_Issues__r != null && pro.Site_Issues__r.size() > 0)
                    mapProjectWithMostRecentMS.put(pro.ID, pro.Site_Issues__r[0]);
            }
        
            //Added By - Abhinav Sharma - 08/24/2015 - CR-20150127-8596
            //Start from here
            //Map of Projects
            Map<Id, Project__c> mapProjects = new Map<Id, Project__c>();
        
            //Query for the "Member Support" record types (CPRM Data Load)
            List<RecordType> recordTypes = [SELECT Id FROM RecordType 
                                                WHERE sObjectType = 'Site_Issue__c' 
                                                AND DeveloperName = 'CPRM_Data_Load' 
                                                AND isActive = true];
            
            //Checking record type for it's existance
            if(recordTypes != null && recordTypes.size() > 0) {
        
                //Loop through parent project records and populating CPRM_Current_Data_Period__c field on the Project 
                //with the "Most recent" Data_Load_Period_End__c field value of "CPRM Data Load Ticket".
                for(Project__c project : [SELECT Id, CPRM_Current_Data_Period__c,
                                            (SELECT Id, Data_Load_Period_End__c FROM Site_Issues__r 
                                                WHERE RecordTypeId != null
                                                AND RecordTypeId IN : recordTypes
                                                AND Status__c = '15 - Cross-Verification Completed'
                                                AND Data_Load_Period_End__c != null 
                                                ORDER BY Data_Load_Period_End__c DESC LIMIT 1)
                                          FROM Project__c WHERE Id IN : setProjectsIds]) {
                    
                    //Only Process the record if found
                    if(project.Site_Issues__r.size() > 0) {
                        project.CPRM_Current_Data_Period__c = project.Site_Issues__r[0].Data_Load_Period_End__c;
                        mapProjects.put(project.Id, project);
                        
                    } else {
                        
                        //Add record in the list to be updated
                        if(project.CPRM_Current_Data_Period__c != null) {
                            project.CPRM_Current_Data_Period__c = null;
                            mapProjects.put(project.Id, project);
                        }        
                    }
                }
            }                
            //Upto here
            
            //Loop through new project records as populating field on them
            for(Project__c pro : newProjects) {
                
                //Checking if we are having MS record in the map corresponding to project ID value
                if(mapProjectWithMostRecentMS != null
                    && mapProjectWithMostRecentMS.containsKey(pro.ID) 
                    && mapProjectWithMostRecentMS.get(pro.Id) != null) {
                    
                    //Populating fields with values
                    pro.PRM_Version__c = mapProjectWithMostRecentMS.get(pro.Id).PRM_Application_Version__c;    
                
                } else {
                
                    //Populating fields with values
                    pro.PRM_Version__c = null;  
                }
                
                //Added By - Abhinav Sharma - 08/24/2015 - CR-20150127-8596
                //Start from here
                //Checking and populating field's values on project record
                if(mapProjects != null
                    && mapProjects.containsKey(pro.Id)
                    && mapProjects.get(pro.Id) != null) {
                        
                    //Populating fields with values
                    pro.CPRM_Current_Data_Period__c = mapProjects.get(pro.Id).CPRM_Current_Data_Period__c;    
                }
                //Upto here
            }
        }
    }
    
    //Added By - - Mahedra Swarnkar - 07/05/2016 - CR-20160229-9651 - to populate case fields from Project
    /**
     *  @description    :   Method to populate the Cases object fields from Projects.
     * 
     *  @args           :   List of projects, map of old projects
     *
     *  @return         :   void
     *
    **/
    public static void populateCaseFieldsFromProject(List<Project__c> newProjects, Map<Id, Project__c> mapOldProjects) {
        
        //Set to hold the eligible Projects
        Set<Id> setProjectIds = new Set<Id>();
        
        
        //Populate the setProjectIds
        for(Project__c proj : newProjects) {
            
            //Check the conditions
            if(mapOldProjects == null 
                ||(  mapOldProjects != null 
                    && ( 
                        proj.Membership_Advisor_Relationship_Manager__c != mapOldProjects.get(proj.Id).Membership_Advisor_Relationship_Manager__c
                        || proj.Dedicated_Advisor__c != mapOldProjects.get(proj.Id).Dedicated_Advisor__c
                        || proj.Program_Associate__c != mapOldProjects.get(proj.Id).Program_Associate__c
                        || proj.No_of_Participants__c != mapOldProjects.get(proj.Id).No_of_Participants__c
                        || proj.Cohort_ID_s__c != mapOldProjects.get(proj.Id).Cohort_ID_s__c
                        || proj.X1_2_Day__c != mapOldProjects.get(proj.Id).X1_2_Day__c
                        || proj.Full_Day__c != mapOldProjects.get(proj.Id).Full_Day__c
                        || proj.Contract_Start_Date__c != mapOldProjects.get(proj.Id).Contract_Start_Date__c
                        || proj.Internal_Strat_Session_NPI_Actual__c != mapOldProjects.get(proj.Id).Internal_Strat_Session_NPI_Actual__c
                        || proj.Service_Date_Start__c != mapOldProjects.get(proj.Id).Service_Date_Start__c
                        || proj.Name != mapOldProjects.get(proj.Id).Name
                    )
                )
            ) {
                setProjectIds.add(proj.Id);
            }
        }
        
        if(setProjectIds.size() > 0) {
            Map<Id, Case> mapCase = new Map<Id, Case>([Select Id, RM__c, DA__c, Associate__c, No_of_Participants__c, Cohort_ID__c, Half_Day_or_Full_Day__c, 
                                                        Contract_Service_Start__c, Contract_Service_End__c, Service_Start__c, Project_Source_MS__c,
                                                        Project_Source_MS__r.Membership_Advisor_Relationship_Manager__r.Name, 
                                                        Project_Source_MS__r.Dedicated_Advisor__r.Name, 
                                                        Project_Source_MS__r.Program_Associate__r.Name,
                                                        Project_Source_MS__r.No_of_Participants__c, 
                                                        Project_Source_MS__r.Cohort_ID_s__c,  Project_Source_MS__r.X1_2_Day__c, 
                                                        Project_Source_MS__r.Full_Day__c, Project_Source_MS__r.Contract_Start_Date__c, 
                                                        Project_Source_MS__r.Internal_Strat_Session_NPI_Actual__c, Project_Source_MS__r.Service_Date_Start__c,
                                                        Project_Source_MS__r.Name,
                                                        Contract__c, Contract__r.End__c
                                                        From Case Where Project_Source_MS__c != null and Project_Source_MS__c IN : setProjectIds]);
            if(mapCase != null && mapCase.values() != null && mapCase.values().size() > 0 ) {
                
                //List of cases to be updated
                List<Case> listCaseToBeUpdate = new List<Case>();
                for(Case tdCas : mapCase.values()) {
                    
                    if(tdCas.Project_Source_MS__c != null) {
                    
                        //Populate the Case fields
                        tdCas.RM__c = tdCas.Project_Source_MS__r.Membership_Advisor_Relationship_Manager__r.Name;
                        tdCas.DA__c = tdCas.Project_Source_MS__r.Dedicated_Advisor__r.Name;
                        tdCas.Associate__c = tdCas.Project_Source_MS__r.Program_Associate__r.Name;
                        tdCas.No_of_Participants__c = tdCas.Project_Source_MS__r.No_of_Participants__c;
                        tdCas.Cohort_ID__c = tdCas.Project_Source_MS__r.Cohort_ID_s__c;
                        
                        if(tdCas.Project_Source_MS__r.X1_2_Day__c != null)
                            tdCas.Half_Day_or_Full_Day__c = '1/2 Day';
                        else {
                            if(tdCas.Project_Source_MS__r.Full_Day__c != null)
                                tdCas.Half_Day_or_Full_Day__c = 'Full Day';
                            else
                                tdCas.Half_Day_or_Full_Day__c = null;
                        }
                        
                        tdCas.Contract_Service_Start__c = tdCas.Project_Source_MS__r.Contract_Start_Date__c;
                        tdCas.Contract_Service_End__c = tdCas.Project_Source_MS__r.Internal_Strat_Session_NPI_Actual__c;
                        tdCas.Service_Start__c = tdCas.Project_Source_MS__r.Service_Date_Start__c;
                        
                        if(tdCas.Contract__c != null && tdCas.Contract__r.End__c != null)
                            tdCas.Project_Year__c =  tdCas.Project_Source_MS__r.Name + ' - ' + tdCas.Contract__r.End__c.year();
                        else
                            tdCas.Project_Year__c =  tdCas.Project_Source_MS__r.Name + ' - ' + 'null';
                            
                        listCaseToBeUpdate.add(tdCas);
                    }
                    else{
                        
                        //Populate the case fields to default values.
                        tdCas.RM__c = null;
                        tdCas.DA__c = null;
                        tdCas.Associate__c = null;
                        tdCas.No_of_Participants__c = null;
                        tdCas.Cohort_ID__c = null;
                        tdCas.Half_Day_or_Full_Day__c = null;
                        tdCas.Contract_Service_Start__c = null;
                        tdCas.Contract_Service_End__c = null;
                        tdCas.Service_Start__c = null;
                        
                        if(tdCas.Contract__c != null && tdCas.Contract__r.End__c != null)
                            tdCas.Project_Year__c =  'null - ' + tdCas.Contract__r.End__c.year();
                        else
                            tdCas.Project_Year__c =  'null - null';
                        
                    }
                }
                
                if(listCaseToBeUpdate.size() > 0 ) {
                    Util.byPassAllTriggers = true;
                    update listCaseToBeUpdate;
                    Util.byPassAllTriggers = false;
                }   
            }
        }
    }
    
    /**
      * @Description    :   Method to Populate project fields with member support field values
      *						
      * @args           :   List<Project__c>,Map<Id, Project__c> 
      *
      * @return         :   void
      *
      * @Version        :   V1.0 - Created By - Mahendra Swarnkar - CR-20160420-9785 - 09/01/2016
    **/
    public static void populateProjectFieldsFromMemberSupport(List<Project__c> newProjects, Map<Id, Project__c> mapOldProjects) {
    	
        //Set to hold the eligible Projects
        Set<Id> setProjectIds = new Set<Id>();
        
        //Populate the setProjectIds
        for(Project__c proj : newProjects) {
            
            //Check the conditions
            if(mapOldProjects != null 
                && ( 
                    proj.Market_Data_Period_Begin__c != mapOldProjects.get(proj.Id).Market_Data_Period_Begin__c
                    || proj.Market_Data_Period_End__c != mapOldProjects.get(proj.Id).Market_Data_Period_End__c
                ) 
            ) {
                //Populate the setProjectIds
                setProjectIds.add(proj.Id);
            }
        }
        
        //Method call to populate the data period fields on Project from most recent Member support
        if(setProjectIds.size() > 0){
        
        	Map<Id, Project__c> projects = populateMarketDataPeriodFieldsOnProject(setProjectIds);
        	
        	if(projects != null)
        	//Populate the MArket data field values
        	for(Project__c proj : newProjects) {
        		if(projects.containsKey(proj.Id)
        			&& projects.get(proj.Id) != null
        		){
        			proj.Market_Data_Period_Begin__c = projects.get(proj.Id).Market_Data_Period_Begin__c;
					proj.Market_Data_Period_End__c = projects.get(proj.Id).Market_Data_Period_End__c;
        		}
        	}
        }     
    }
    
    /**
      * @Description    :   Method to Populate following project fields:-
      *                     	1)	populate "Market Data period begin" with "Market Data period begin" field value on most recent MS
      *							2)	populate "Market Data period End" with "Market Data period End" field value on most recent MS
       *
      * @args           :   List<Project__c>
      *
      * @return         :   void
      *
      * @Version        :   V1.0 - Created By - Mahendra Swarnkar - CR-20160420-9785 - 09/01/2016
    **/
    public static Map<Id, Project__c> populateMarketDataPeriodFieldsOnProject(Set<Id> projects) {
    	
    	Map<Id, Project__c> mapProjectsToBeUpdated;
    	
        //Check for Size
        if(projects != null && projects.size() > 0){
            
            //Id Of Member Support Record type "CMA Data Load/Migration"
            Id cmaDataLoadMigrationRtypeId = Util.RecordTypeId(MEMBER_SUPPORT_API_NAME, MEMBER_SUPPORT_RECORDTYPE_CMA_DATA_LOAD_MIGRATION);
            
            //Check for size
            if(cmaDataLoadMigrationRtypeId != null){
                 
                //map to hold the project records to be updated
                mapProjectsToBeUpdated = new Map<Id, Project__c>();
                
                //Inline Query through Project records to update the Mrket data period begin and End fields with Most recent MS fields  
                for(Project__c pro : [Select Id, Market_Data_Period_Begin__c, Market_Data_Period_End__c, 
                                                   (
                                                     Select Id, Market_Data_Period_Begin__c, Market_Data_Period_End__c 
                                                       From Site_Issues__r where 
                                                       recordTypeId =: cmaDataLoadMigrationRtypeId
                                                       AND Status__c =: STATUS_22_PRODUCTION_MIGRATION_COMPLETE
                                                       AND Site_Issue_Close_Date__c != null
                                                       AND 
                                                       (
                                                           Data_Load_Type__c =: DATA_LOADTYPE_CURRENT 
                                                           OR Data_Load_Type__c =: DATA_LOADTYPE_OFF_CYCLE_DATA_LOAD_AND_OR_MIGRATION
                                                           OR Data_Load_Type__c =: DATA_LOADTYPE_OFF_CYCLE_MIGRATION
                                                       )
                                                      ORDER BY LastModifiedDate desc LIMIT 1
                                                   ) 
                                                   From Project__c where ID IN : projects
                                                 ]) {
                    
                    //Setting fields value to default values
                    pro.Market_Data_Period_Begin__c = null;
                    pro.Market_Data_Period_End__c = null;
                    
                    //Populate the Project feilds 
                    if(pro.Site_Issues__r != null && pro.Site_Issues__r.size() > 0){
                        
                        pro.Market_Data_Period_Begin__c = pro.Site_Issues__r[0].Market_Data_Period_Begin__c;
                        pro.Market_Data_Period_End__c = pro.Site_Issues__r[0].Market_Data_Period_End__c;
                    }
                    
                    //Populate the Project List to be updated
                    mapProjectsToBeUpdated.put(pro.Id, pro);
                }   
            }
        }
    	return mapProjectsToBeUpdated;
    }
}