/*
    Purpose         :   This class is helper class for  SFDC Change Request Trigger(CR-20120424-757).
                
    Create By       :   Simplyforce Technology
    
    Created Date    :   28/05/2012
    
    Current Version :   v1.0
    
    Revision Log    :   V_1.0 Created
                        V_1.1 Ajit Surana - 04/18/2014 - CR-20140303-4690 - Added new method (rollUpStorySizeDataOnSFDCRelease())
                        V_1.2- Bhavi Sharma - 05/02/2014 - CR-20140225-4635 - Updated rollUpDataOnSFDCRelease to rollup data when release field is getting changed
						V_1.21 Jason Bennett - 03/22/2016 - CR-20160317-9701 - Updated calculation of Manual Setup Mods for new method of tracking manual steps on CR Action Items
*/
public without sharing class SFDCChangeRequestTriggerHelper {
    
    /**
     * description 
     *              : This method determines if an update to the rolled-up values on the related Release(s) is needed, and 
     * 					then calls the function to update the rollup fields if so.
     * @param changeRequests
     *              : List of change requests currently in context
     * @return 
     *              : void
     */
    public static void checkIfRollupUpdateNeeded(List<SFDC_Change_Request__c> changeRequests) {
        
        //Create a set of Ids to hold the ids of SFDC Releases
        Set<Id> releasesIds = new Set<Id>();
        
        //Fields on SFDC Releases will be updated in case of Insert, Delete, Undelete and Update of change requests
        //In case of update, files will be updated if any of the fields on Change request is changed from the old value
        if(Trigger.isInsert || Trigger.isDelete || Trigger.isUndelete) {
            
            //Loop through the changeRequests records and add release ids in set
            for(SFDC_Change_Request__c cR : changeRequests) {
                
                //Add release Id in Set
                if(cR.Release__c != null)
                    releasesIds.add(cR.Release__c);
            }
        } else if(Trigger.isUpdate) {
                
            //Loop through the changeRequests records and add release ids in set
            for(SFDC_Change_Request__c cR : changeRequests) {
                
                //Get the old CR record
                SFDC_Change_Request__c oldCRInstance = (SFDC_Change_Request__c)Trigger.oldMap.get(cR.Id);
                
                //check if it is not a blank update or any of the roll up field value is getting changed
                if(cR.Release__c != oldCRInstance.Release__c 
                    || cR.of_Modifications__c != oldCRInstance.of_Modifications__c
                    || cR.Of_Manual_Setup_Mods__c != oldCRInstance.Of_Manual_Setup_Mods__c
                    || cR.Mods_with_Manual_Steps__c != oldCRInstance.Mods_with_Manual_Steps__c
                    || cR.SOX_Certification_Required__c != oldCRInstance.SOX_Certification_Required__c
                    || cR.Coding_Estimated_Hrs__c != oldCRInstance.Coding_Estimated_Hrs__c
                    || cR.Coding_Actual_Hours__c != oldCRInstance.Coding_Actual_Hours__c 
                    || cR.Config_Estimated_Hrs__c != oldCRInstance.Config_Estimated_Hrs__c 
                    || cR.Config_Actual_Hours__c != oldCRInstance.Config_Actual_Hours__c 
                    || cR.Design_Estimated__c != oldCRInstance.Design_Estimated__c 
                    || cR.Design_Actual_Hours__c != oldCRInstance.Design_Actual_Hours__c
                    || cR.IS_QA_Estimated_Hrs__c != oldCRInstance.IS_QA_Estimated_Hrs__c
                    || cR.IS_QA_Actual_Hours__c != oldCRInstance.IS_QA_Actual_Hours__c
                    || cR.Total_IS_CRM_Estimated_Hrs__c != oldCRInstance.Total_IS_CRM_Estimated_Hrs__c
                    || cR.Total_IS_CRM_Hrs__c != oldCRInstance.Total_IS_CRM_Hrs__c
                    || cR.User_Documentation_Actual_Hrs__c != oldCRInstance.User_Documentation_Actual_Hrs__c) {
                        
                    //Add release Id in Set
                    if(cR.Release__c != null)
                        releasesIds.add(cR.Release__c);
                    
                    //Added By Bhavi Sharma - 05/02/2014 - CR-20140225-4635
                    if(oldCRInstance.Release__c != null)
                        releasesIds.add(oldCRInstance.Release__c);
                }
            }
        }
        
        //Check if there are records to process
        if(releasesIds.size() > 0) {
            rollUpDataOnSFDCRelease(releasesIds);
        }
    }
    
    /**
     * description 
     *              : This method is to roll up SFDC Change request fields on SFDC Release object
     * @param changeRequests
     *              : Set of Release Ids for the Release records that need to be updated
     * @return 
     *              : void
     */
    public static void rollUpDataOnSFDCRelease(Set<Id> releaseIds) {
        
        //Verify that there are records to process
        if(releaseIds.size() > 0 && releaseIds != null) {
                    
            //Map to hold the release
            Map<Id, SFDC_Release__c> mapReleases = new Map<Id, SFDC_Release__c>();
            
            //Map to hold the Manual Step Counts
            Map<Id, Integer> mapReleaseToSteps = new map<Id,Integer>();
            
            //Fetch all the change requests, and group these records by SFDC Release.
            //Get Count and Sum for various fields
            List<AggregateResult> aggregateResultsForCR = [Select Count(ID) recordCount, SUM(of_Modifications__c) totalModifications,
                                        SUM(Of_Manual_Setup_Mods__c) totalmanualSetupMods, SUM(Mods_with_Manual_Steps__c) totalModsWithManualSteps,
                                        SOX_Certification_Required__c certRequired,
                                        SUM(Coding_Estimated_Hrs__c) totalCodingEstimatedHours, SUM(Coding_Actual_Hours__c) totalCodingActualHours,
                                        SUM(Config_Estimated_Hrs__c) totalConfigEstimatedHours, SUM(Config_Actual_Hours__c) totalConfigActualHours,
                                        SUM(Design_Estimated__c) totalDesignEstimatedHours, SUM(Design_Actual_Hours__c) totalDesignActualHours,
                                        SUM(IS_QA_Estimated_Hrs__c) totalISQAEstimatedHours, SUM(IS_QA_Actual_Hours__c) totalISQAActualHours,
                                        SUM(User_Documentation_Actual_Hrs__c) totalUDActualHours, Release__c release,
                                        SUM(Total_IS_CRM_Estimated_Hrs__c) totalISCRMEstimatedHours, SUM(Total_IS_CRM_Hrs__c) totalISCRMActualHours
                                        from SFDC_Change_Request__c where Release__c IN: releaseIds 
                                        GROUP BY ROLLUP(Release__c, SOX_Certification_Required__c)];
            
            //Get the count of manual steps for each Release
            List<AggregateResult> arReleaseManualSteps = [SELECT Count(Id) recordCount, IS_System_Modification__r.Change_Request__r.Release__c release
                                                          FROM CR_Action_Item__c
                                                          WHERE IS_System_Modification__r.Change_Request__r.Release__c in: releaseIds 
                                                          AND RecordTypeId = :Schema.SObjectType.CR_Action_Item__c.getRecordTypeInfosByName().get('Deployment Plan Step').getRecordTypeId()
                                                          AND IS_System_Modification__r.Delete_from_Design__c = FALSE
                                                          AND Action_Item_Status__c != 'Cancelled'
                                                          GROUP BY IS_System_Modification__r.Change_Request__r.Release__c];
            system.debug('SFDCChangeRequestTriggerHelper.rollUpDataOnSFDCRelease - arReleaseManualSteps = '+arReleaseManualSteps);
            
            //Load the results of the Manual Step query into a map
            for(AggregateResult arSteps : arReleaseManualSteps) {
                mapReleaseToSteps.put(Id.valueOf(String.valueOf(arSteps.get('release'))),Integer.valueOf(arSteps.get('recordCount')));
            }
            system.debug('SFDCChangeRequestTriggerHelper.rollUpDataOnSFDCRelease - mapReleaseToSteps = '+mapReleaseToSteps);
                                        
            //Do the processing only if aggregate query have results to process
            if(aggregateResultsForCR.size() > 0) {
                
                //Create an instance of SFDC Release object
                SFDC_Release__c release;
                
                //loop through the aggregate results
                for(AggregateResult aR : aggregateResultsForCR) {
                    
                    //Update data on release object
                    if(aR.get('release') != null) {
                        
                        //Release id
                        Id releaseId = Id.valueOf(String.valueOf(aR.get('release')));
              
                        //Create a clone for release record
                        if(!mapReleases.containsKey(releaseId))
                            mapReleases.put(releaseId, new SFDC_Release__c(Id = releaseId));
                        
                        release = mapReleases.get(releaseId);
                        
                        //Check if SOX_Certification_Required__c status is Yes
                        if(aR.get('certRequired') != null && String.valueOf(aR.get('certRequired')) == Constants.YES) {
                            
                            //Set the rollup data
                            if(aR.get('recordCount') != null) 
                                release.No_of_SOX_Requests__c = Integer.valueOf(aR.get('recordCount'));
                            
                            //Put back in map
                            mapReleases.put(release.Id, release);
                        } else if(aR.get('certRequired') == null) {
                        
                            //Set the rollup data
                            if(aR.get('recordCount') != null) 
                                release.No_of_Change_Requests__c = Integer.valueOf(aR.get('recordCount'));
                            if(aR.get('totalModifications') != null) 
                                release.No_of_Modifications__c = Integer.valueOf(aR.get('totalModifications'));
                            if(aR.get('totalmanualSetupMods') != null) 
                                release.No_of_Manual_Setup_Mods__c = Integer.valueOf(aR.get('totalmanualSetupMods'));
                            //JRB Add in the new method for counting the number of manual steps using CR Action Item
                            if(mapReleaseToSteps.containsKey(releaseId))
                                release.No_of_Manual_Setup_Mods__c = release.No_of_Manual_Setup_Mods__c + mapReleaseToSteps.get(releaseId);
                            if(aR.get('totalCodingEstimatedHours') != null) 
                                release.Coding_Estimated_Hrs__c = Double.valueOf(aR.get('totalCodingEstimatedHours'));
                            if(aR.get('totalCodingActualHours') != null) 
                                release.Coding_Actual_Hrs__c = Double.valueOf(aR.get('totalCodingActualHours'));
                            if(aR.get('totalConfigEstimatedHours') != null) 
                                release.Config_Estimated_Hrs__c = Double.valueOf(aR.get('totalConfigEstimatedHours'));
                            if(aR.get('totalConfigActualHours') != null) 
                                release.Config_Actual_Hrs__c = Double.valueOf(aR.get('totalConfigActualHours'));
                            if(aR.get('totalDesignEstimatedHours') != null) 
                                release.Design_Estimated_Hrs__c = Double.valueOf(aR.get('totalDesignEstimatedHours'));
                            if(aR.get('totalDesignActualHours') != null) 
                                release.Design_Actual_Hrs__c = Double.valueOf(aR.get('totalDesignActualHours'));
                            if(aR.get('totalISQAEstimatedHours') != null) 
                                release.IS_QA_Estimated_Hrs__c = Double.valueOf(aR.get('totalISQAEstimatedHours'));
                            if(aR.get('totalISQAActualHours') != null) 
                                release.IS_QA_Actual_Hrs__c = Double.valueOf(aR.get('totalISQAActualHours'));
                            if(aR.get('totalUDActualHours') != null) 
                                release.User_Documentation_Actual_Hrs__c = Double.valueOf(aR.get('totalUDActualHours'));
                            if(aR.get('totalISCRMEstimatedHours') != null) 
                                release.Total_IS_CRM_Estimated_Hrs__c = Double.valueOf(aR.get('totalISCRMEstimatedHours'));
                            if(aR.get('totalISCRMActualHours') != null) 
                                release.Total_IS_CRM_Actual_Hrs__c = Double.valueOf(aR.get('totalISCRMActualHours'));
                            
                            //Put back in map
                            mapReleases.put(release.Id, release);
                        }
                    }
                }
            } 
            
            for(Id releaseId : releaseIds) {
                
                //Set 0s where no record found
                if(!mapReleases.containsKey(releaseId ))
                    mapReleases.put(releaseId, new SFDC_Release__c(Id = releaseId, No_of_SOX_Requests__c = 0, No_of_Change_Requests__c = 0,
                                                            No_of_Modifications__c = 0, No_of_Manual_Setup_Mods__c = 0, 
                                                            Coding_Estimated_Hrs__c = 0, Coding_Actual_Hrs__c = 0, 
                                                            Config_Estimated_Hrs__c = 0, Config_Actual_Hrs__c = 0,
                                                            Design_Estimated_Hrs__c = 0, Design_Actual_Hrs__c = 0, 
                                                            IS_QA_Estimated_Hrs__c = 0, IS_QA_Actual_Hrs__c = 0,
                                                            Total_IS_CRM_Estimated_Hrs__c = 0, Total_IS_CRM_Actual_Hrs__c = 0,
                                                            User_Documentation_Actual_Hrs__c = 0));     
            }
            
            //Check if there are records to update
            if(mapReleases.size() > 0) {
                
                update mapReleases.values();
            }
        }
    }
    
    //Added by Ajit Surana - 04/18/2014 - CR-20140303-4690
    /**
     *  @description    : This method assign a value to each CR based on the Story Size field. Add all values together & populate this on release object. 
     * 
     *  @args           : List of new Change Request records, Map of old Change Request Id and instance 
     * 
     *  @return         : void
     * 
     **/
    public static void rollUpStorySizeDataOnSFDCRelease(List<SFDC_Change_Request__c> changeRequests, Map<Id, SFDC_Change_Request__c> mapOldChangeRequests) {
        
        //Map to hold the release Id as key and release record value
        Map<Id, SFDC_Release__c> mapRelease = new Map<Id, SFDC_Release__c>();
        
        //Loop through the Change Requests records
        if(changeRequests != null) {
            for(SFDC_Change_Request__c cR : changeRequests) {
                if(mapOldChangeRequests == null) {
                    if(cR.Release__c != null)
                        mapRelease.put(cR.Release__c, new SFDC_Release__c(Id=cR.Release__c, Story_Points__c = 0));
                } else {
                    if(cR.Story_Size__c != mapOldChangeRequests.get(cR.Id).Story_Size__c
                        || cR.Release__c != mapOldChangeRequests.get(cR.Id).Release__c) {
                        if(cR.Release__c != null)
                            mapRelease.put(cR.Release__c, new SFDC_Release__c(Id=cR.Release__c, Story_Points__c = 0));
                        if(mapOldChangeRequests.get(cR.Id).Release__c != null)
                           mapRelease.put(mapOldChangeRequests.get(cR.Id).Release__c, new SFDC_Release__c(Id=mapOldChangeRequests.get(cR.Id).Release__c, Story_Points__c = 0));
                    }    
                }      
            }
        } else {
            for(SFDC_Change_Request__c cR : mapOldChangeRequests.values()) {
                if(mapOldChangeRequests.get(cR.Id).Release__c != null)
                    mapRelease.put(mapOldChangeRequests.get(cR.Id).Release__c, new SFDC_Release__c(Id=mapOldChangeRequests.get(cR.Id).Release__c, Story_Points__c = 0));
            }
        }
                
        //Check if there are records to update
        if(mapRelease.size() > 0) {
            
            //Map to hold Story Size values combinations
            Map<String, Integer> mapStroySizes = new Map<String, Integer>{'XS'=>1,'S'=>2,'M'=>3,'L'=>5,'XL'=>7};
            
            //Map of release records
            Map<Id, Integer> mapReleaseIdWithStoryPoints = new Map<Id, Integer>();
        
            //Loop through change requests records already assigned to a release
            for(SFDC_Change_Request__c cR : [SELECT ID, Story_Size__c, Release__c FROM SFDC_Change_Request__c WHERE Release__c IN: mapRelease.keySet()]) {
                
                //Checking and validating for story size field value
                if(!String.isBlank(cR.Story_Size__c) && mapStroySizes.get(cR.Story_Size__c) != null) {
                    Decimal sumCount = mapRelease.get(cR.Release__c).Story_Points__c + mapStroySizes.get(cR.Story_Size__c);
                    mapRelease.put(cR.Release__c, new SFDC_Release__c(Id=cR.Release__c, Story_Points__c = sumCount));
                }
            }
            
            System.debug('@@@@@@ mapRelease ' + mapRelease);
        }
        
        //Checking for size value
        if(mapRelease.values().size() > 0)
            update mapRelease.values();
    }   
}