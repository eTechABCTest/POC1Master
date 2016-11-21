/**
*   Purpose         :   Helper class for Deployment object trigger.
* 
*   Created By      :   Bhavi Sharma    
* 
*   Created Date    :   05/25/2013
* 
*   Current Version :   V_1.0 - Created -   CR-20130328-2773
*                       V_2.0 - Modified -  CR-20130612-3154 - Added method: updateDeploymentStatus
*                       V_3.0 - Modified -  CR-20130829-3543 - Abhinav Sharma - 03-03-2014 - Added method: populateFirstDeploymentSignedOff
*                       V_4.0 - Modified -  CR-20140403-4958 - Site Live - Target, Actual - not completed with 3968 - Abhinav Sharma - 04/29/2014 - Modified method: populateFirstDeploymentSignedOff
*                       V_5.0 - Modified -  CR-20140408-5000 - Abhinav Sharma - 05-01-2014 - Added new method: populateDeploymentDataOnProject   
*                       V_6.0 - Modified - CR-20140716-6256 - Ajit Surana - 09/08/2014 - Exclude Project Record Type "SSC" from populateFirstDeploymentSignedOff() method    
*                       V_7.0 - Modified - CR-20140826-7138 - Abhinav Sharma - 10/17/2014 - CR-20140826-7138 - New methods getRCSProjectToUpdate 
*                                          & populateDeploymentSignOffOldestOnProject added.
*                       V_8.0 - Modified - CR-20141106-8010 - Abhinav Sharma - 11/25/2014 - Revert change to Site Live field on SSC projects
*                       V_9.0 - Modified BY - Abhinav Sharma - 02/03/2015 - CR-20141218-8365 - New method added - updateCalculatedDateFields
*						V_10.0 - Modified By - Abhinav Sharma - 10/20/2015 - CR-20150623-9023 - Updated existing method (updateCalculatedDateFields)
**/ 
public without sharing class DeploymentTriggerHelper {

    //Modified By - Abhinav Sharma - 10/20/2015 - CR-20150623-9023
    //Added BY - Abhinav Sharma - 02/03/2015 - CR-20141218-8365
    /**
     *  @description    :   Method to populate Date fields on deployment with desired calculated values on CPRM Record Types.
     *
     *  @args           :   List of deployments
     *
     *  @return         :   void
     *
     **/
    public static void updateCalculatedDateFields(List<Deployment__c> newDeployments) {
        
        //Set to hold the record types developername string literals
        Set<String> setRdTypeDeveloperNames = new Set<string>();
        setRdTypeDeveloperNames.add('CPRM_Deployment');
        setRdTypeDeveloperNames.add('Data_Hub_Deployment');
        
        //Map of deployment record type
        Map<Id, RecordType> mapRdTypes = new Map<Id, RecordType>([SELECT ID, DeveloperName FROM RecordType 
                                        WHERE SobjectType = 'Deployment__c' AND IsActive = true 
                                        AND DeveloperName IN : setRdTypeDeveloperNames]);
        
        //Checking map for size and null value
        if(mapRdTypes != null && mapRdTypes.size() > 0) {
            
            //Loop through new Deployment records   
            for(Deployment__c dep : newDeployments) {
                
                //Perform calculation and populating field for "CPRM Deployment" record type
                if(mapRdTypes.containsKey(dep.RecordTypeId) 
                	&& mapRdTypes.get(dep.RecordTypeId) != null
                  	&& mapRdTypes.get(dep.RecordTypeId).DeveloperName == 'CPRM_Deployment') {
                
                    //Performing caluclation for the date fields
                    
                    //Template_Sent_Expected__c
                    if(dep.C_A_DS__c != null)
                        dep.Template_Sent_Expected__c  = dep.C_A_DS__c + 2;
                    else
                        dep.Template_Sent_Expected__c = null;
                        
                    //C_E_TPC__c
                    if(dep.C_A_DS__c != null)
                        dep.C_E_TPC__c = dep.C_A_DS__c + 14;
                    else
                        dep.C_E_TPC__c = null;
                        
                    //Redlining_Complete_Expected__c
                    if(dep.Template_Sent_Expected__c != null)
                        dep.Redlining_Complete_Expected__c  = dep.Template_Sent_Expected__c + 21;
                    else
                        dep.Redlining_Complete_Expected__c = null;
                      
                    //Legal_Complete_Expected__c
                    if(dep.Redlining_Complete_Expected__c != null)
                        dep.Legal_Complete_Expected__c = dep.Redlining_Complete_Expected__c + 21;
                    else
                        dep.Legal_Complete_Expected__c = null;
                        
                    //C_E_IDI__c
                    if(dep.Legal_Complete_Expected__c != null)
                        dep.C_E_IDI__c = dep.Legal_Complete_Expected__c + 2;
                    else
                        dep.C_E_IDI__c = null;
                     
                    //Feedback_on_Initial_Data_Expected__c 
                    if(dep.C_E_IDI__c != null)
                        dep.Feedback_on_Initial_Data_Expected__c  = dep.C_E_IDI__c + 14;
                    else
                        dep.Feedback_on_Initial_Data_Expected__c = null;  
                        
                    //C_E_CDI__c
                    if(dep.Feedback_on_Initial_Data_Expected__c != null)
                        dep.C_E_CDI__c = dep.Feedback_on_Initial_Data_Expected__c + 7;
                    else
                         dep.C_E_CDI__c = null;
                         
                    //C_E_DDC__c
                    if(dep.C_E_CDI__c != null)
                        dep.C_E_DDC__c = dep.C_E_CDI__c + 14;
                    else
                         dep.C_E_DDC__c = null;
                         
                    //Data_Sent_to_Vendor_Expected__c 
                    if(dep.C_E_DDC__c != null)
                        dep.Data_Sent_to_Vendor_Expected__c = dep.C_E_DDC__c + 7;
                    else
                         dep.Data_Sent_to_Vendor_Expected__c = null;
                       
                    //DAS_Received_Expected__c  
                    if(dep.Data_Sent_to_Vendor_Expected__c  != null) 
                        dep.DAS_Received_Expected__c = dep.Data_Sent_to_Vendor_Expected__c + 15;
                    else
                        dep.DAS_Received_Expected__c = null;
                        
                    //DAS_Approved_Expected__c 
                    if(dep.DAS_Received_Expected__c != null) 
                        dep.DAS_Approved_Expected__c  = dep.DAS_Received_Expected__c + 2;
                    else
                        dep.DAS_Approved_Expected__c = null;
                        
                    //C_E_ISBC__c 
                    if(dep.DAS_Approved_Expected__c != null) 
                        dep.C_E_ISBC__c = dep.DAS_Approved_Expected__c + 16;
                    else
                        dep.C_E_ISBC__c = null;
                        
                    //C_E_IVC__c 
                    if(dep.C_E_ISBC__c != null) 
                        dep.C_E_IVC__c = dep.C_E_ISBC__c + 2;
                    else
                        dep.C_E_IVC__c = null;
                        
                    //UAT_Diagnostics_Call_Expected__c 
                    if(dep.C_E_IVC__c != null) 
                        dep.UAT_Diagnostics_Call_Expected__c = dep.C_E_IVC__c + 5;
                    else
                        dep.UAT_Diagnostics_Call_Expected__c = null;
                        
                    //UAT_Onsite_Expected__c
                    if(dep.UAT_Diagnostics_Call_Expected__c != null) 
                        dep.UAT_Onsite_Expected__c = dep.UAT_Diagnostics_Call_Expected__c + 2;
                    else
                        dep.UAT_Onsite_Expected__c = null;
                        
                    //C_E_DC__c
                    if(dep.UAT_Onsite_Expected__c != null) 
                        dep.C_E_DC__c = dep.UAT_Onsite_Expected__c + 30;
                    else
                        dep.C_E_DC__c = null;
                        
                    //Expected_Recurring_Update_Sign_Off2__c
                    if(dep.UAT_Onsite_Expected__c != null) 
                        dep.Expected_Recurring_Update_Sign_Off2__c = dep.UAT_Onsite_Expected__c + 30;
                    else
                        dep.Expected_Recurring_Update_Sign_Off2__c = null;
                }
                
                //Perform calculation and populating field for "Data Hub Deployment" record types
                if(mapRdTypes.containsKey(dep.RecordTypeId) 
                	&& mapRdTypes.get(dep.RecordTypeId) != null
                	&& mapRdTypes.get(dep.RecordTypeId).DeveloperName == 'Data_Hub_Deployment') {
                	 
                   	//Data Acquisition Call (Expected) (Data_Acquisition_Call_Expected__c)
                   	if(dep.Welcome_Call_Expected__c != null)
                    	dep.Data_Acquisition_Call_Expected__c  = dep.Welcome_Call_Expected__c + 5;
                    else
                        dep.Data_Acquisition_Call_Expected__c = null;
                   
                   	//Feed Transport setup complete(Expected) (Feed_Transport_setup_complete_Expected__c)
                   	if(dep.Data_Acquisition_Call_Expected__c != null)
                   		dep.Feed_Transport_setup_complete_Expected__c  = dep.Data_Acquisition_Call_Expected__c + 5;
                    else
                        dep.Feed_Transport_setup_complete_Expected__c = null;
                        
                   	//Receive Test Data (Expected) (Receive_Test_Data_Expected__c)
                   	if(dep.Feed_Transport_setup_complete_Expected__c != null)
                    	dep.Receive_Test_Data_Expected__c  = dep.Feed_Transport_setup_complete_Expected__c + 3;
                    else
                        dep.Receive_Test_Data_Expected__c = null;
                        
                   	//Extract data in ECDM (Expected) (Extract_data_in_ECDM_Expected__c)
                   	if(dep.Receive_Test_Data_Expected__c != null)
                    	dep.Extract_data_in_ECDM_Expected__c  = dep.Receive_Test_Data_Expected__c + 5;
                    else
                        dep.Extract_data_in_ECDM_Expected__c = null;
                   
                   	//Transform data ECDM to ICDM (Exp.) (Transform_data_ECDM_to_ICDM_Exp__c)
                   	if(dep.Extract_data_in_ECDM_Expected__c != null)
                    	dep.Transform_data_ECDM_to_ICDM_Exp__c  = dep.Extract_data_in_ECDM_Expected__c + 3;
                    else
                        dep.Transform_data_ECDM_to_ICDM_Exp__c = null;
                        
                   	//ICDM sample data diagnostics (Expected) (ICDM_sample_data_diagnostics_Expected__c)
                   	if(dep.Transform_data_ECDM_to_ICDM_Exp__c != null)
                    	dep.ICDM_sample_data_diagnostics_Expected__c  = dep.Transform_data_ECDM_to_ICDM_Exp__c + 2;
                    else
                        dep.ICDM_sample_data_diagnostics_Expected__c = null;
                   
                   	//ICDM sample data diagnostic resolved Exp (ICDM_sample_data_diagnostic_resolved_Exp__c)
                   	if(dep.ICDM_sample_data_diagnostics_Expected__c != null)
                    	dep.ICDM_sample_data_diagnostic_resolved_Exp__c  = dep.ICDM_sample_data_diagnostics_Expected__c + 5;
                    else
                        dep.ICDM_sample_data_diagnostic_resolved_Exp__c = null;
                    
                   	//Historical Data Received (Expected) (Historical_Data_Received_Expected__c)
                   	if(dep.ICDM_sample_data_diagnostic_resolved_Exp__c != null)
                    	dep.Historical_Data_Received_Expected__c  = dep.ICDM_sample_data_diagnostic_resolved_Exp__c + 3;
                    else
                        dep.Historical_Data_Received_Expected__c = null;
                   
                   	//ICDM historical data diagnostics (Exp.) (ICDM_historical_data_diagnostics_Exp__c)
                   	if(dep.Historical_Data_Received_Expected__c != null)
                    	dep.ICDM_historical_data_diagnostics_Exp__c  = dep.Historical_Data_Received_Expected__c + 1;
                    else
                        dep.ICDM_historical_data_diagnostics_Exp__c = null;
                        
					//ICDM historical data diags resolved(Exp) (ICDM_historical_data_diags_resolved_Exp__c)
					if(dep.ICDM_historical_data_diagnostics_Exp__c != null)
                    	dep.ICDM_historical_data_diags_resolved_Exp__c  = dep.ICDM_historical_data_diagnostics_Exp__c + 8;
                    else
                        dep.ICDM_historical_data_diags_resolved_Exp__c = null;
                    
                   	//Enrichment service setup complete (Exp.) (Enrichment_service_setup_complete_Exp__c)
                   	if(dep.ICDM_historical_data_diags_resolved_Exp__c != null)
                    	dep.Enrichment_service_setup_complete_Exp__c  = dep.ICDM_historical_data_diags_resolved_Exp__c + 2;
                    else
                        dep.Enrichment_service_setup_complete_Exp__c = null;
                    
                   	//Enrichment service diagnostics (Exp.) (Enrichment_service_diagnostics_Exp__c)
                   	if(dep.Enrichment_service_setup_complete_Exp__c != null)
                    	dep.Enrichment_service_diagnostics_Exp__c  = dep.Enrichment_service_setup_complete_Exp__c + 1;
                    else
                        dep.Enrichment_service_diagnostics_Exp__c = null;
                    
                    //Enrichment service diags resolved (Exp.) (Enrichment_service_diags_resolved_Exp__c)
                    if(dep.Enrichment_service_diagnostics_Exp__c != null)
                    	dep.Enrichment_service_diags_resolved_Exp__c  = dep.Enrichment_service_diagnostics_Exp__c + 5;
                    else
                        dep.Enrichment_service_diags_resolved_Exp__c = null;
                        
                   	//Data Handoff to Product (Expected) (Data_Handoff_to_Product_Expected__c)
                   	if(dep.Enrichment_service_diags_resolved_Exp__c != null)
                    	dep.Data_Handoff_to_Product_Expected__c  = dep.Enrichment_service_diags_resolved_Exp__c + 1;
                    else
                        dep.Data_Handoff_to_Product_Expected__c = null;
                        
                   	//Internal Validation Complete (Expected) (C_E_IVC__c)
                   	if(dep.Data_Handoff_to_Product_Expected__c != null)
                    	dep.C_E_IVC__c  = dep.Data_Handoff_to_Product_Expected__c + 5;
                    else
                        dep.C_E_IVC__c = null;
                        
                   	//Recurring Update Sign-Off (Expected) (Recurring_Update_Sign_Off_Expected__c)
                   	if(dep.C_E_IVC__c != null)
                    	dep.Recurring_Update_Sign_Off_Expected__c  = dep.C_E_IVC__c + 15;
                    else
                        dep.Recurring_Update_Sign_Off_Expected__c = null;
 				}         
            }   
        }
    }
    
    //This method is set to Data on Project object 
    public static void rollupDeploymentDataOnProject(List<Deployment__c> newDeployments, Map<Id, Deployment__c> mapOldDeployments){
        
        //Prepare a set of Project Ids
        Set<Id> projIds = new Set<Id>();
        
        //Loop through new Deployment record for get project Id
        for(Deployment__c deployment : newDeployments){
            
            //Project Ids set
            if(mapOldDeployments == null && deployment.Project__c != null)
                projIds.add(deployment.Project__c);
            
            if(mapOldDeployments != null 
                && mapOldDeployments.get(deployment.Id) != null 
            	&& (deployment.Project__c != mapOldDeployments.get(deployment.Id).Project__c
              		|| deployment.C_A_DC__c != mapOldDeployments.get(deployment.Id).C_A_DC__c
                    || deployment.Move_to_Production_Team_Expected__c != mapOldDeployments.get(deployment.Id).Move_to_Production_Team_Expected__c
                   )
              ) {
                if(deployment.Project__c != null)   
            		projIds.add(deployment.Project__c);  
        	}
        }
    
        //Map of Project object record with Key = Id and Value = Project Object
        Map<Id, Project__c> mapProjects = new Map<Id, Project__c>();
        
        //Query data of Deployment list
        List<Deployment__c> listDeployments = [SELECT Name, C_A_DC__c, Move_to_Production_Team_Expected__c, CMA_Status_Formula__c, Project__c 
                                                        FROM Deployment__c WHERE Project__c IN : projIds ];
        
        //Loop through Deployment's Trigger.new
        for(Deployment__c deployment : listDeployments){
            
            if(!mapProjects.containsKey(deployment.Project__c)){
            
                //put in map with Key = ProjectId, value = Project record
                mapProjects.put(deployment.Project__c, new Project__c(Id = deployment.Project__c, Move_to_Production_Team_Expected__c = null, 
                                    Final_Deployment_Sign_Off_Date__c = null 
                                    //No_of_Active_Green_Deployments__c = 0,
                                    //No_of_Active_Red_Deployments__c = 0, 
                                    //No_of_Active_Yellow_Deployments__c = 0, 
                                    //No_of_Historical_Green_Deployments__c = 0,
                                    //No_of_Historical_Red_Deployments__c = 0, 
                                    //No_of_Historical_Yellow_Deployments__c = 0
                                    ));
            }
            
            //Check map contains projectId of Deployment
            if(mapProjects.containsKey(deployment.Project__c)){
                
                //Get project instance from map
                Project__c project = mapProjects.get(deployment.Project__c);
                
                System.debug('###Name'+deployment.Name);
                System.debug('###Red'+deployment.CMA_Status_Formula__c );
                //Check specific criteria for Historical and Active Red Deployment
                if(deployment.CMA_Status_Formula__c == 'Red'){
                    
                    if(deployment.C_A_DC__c != null){
                        
                        //project.No_of_Historical_Red_Deployments__c +=1; 
                    }
                    //project.No_of_Active_Red_Deployments__c +=1;
                }
                //Check specific criteria for Historical and Active Green Deployment    
                if(deployment.CMA_Status_Formula__c == 'Green'){
                    
                    if(deployment.C_A_DC__c != null){
                        
                        //project.No_of_Historical_Green_Deployments__c +=1;
                    }
                    //project.No_of_Active_Green_Deployments__c +=1;
                }
                
                //Check specific criteria for Historical and Active Yellow Deployment
                if(deployment.CMA_Status_Formula__c == 'Yellow'){
                    
                    if(deployment.C_A_DC__c != null){
                        
                        //project.No_of_Historical_Yellow_Deployments__c +=1;
                    }
                    //project.No_of_Active_Yellow_Deployments__c +=1;
                }
                
                //Check for maximum of Current Deployment Sign of (Actual) of Deployment
                if(project.Final_Deployment_Sign_Off_Date__c == null 
                    || deployment.C_A_DC__c > project.Final_Deployment_Sign_Off_Date__c)
                    project.Final_Deployment_Sign_Off_Date__c = deployment.C_A_DC__c; 
                
                //Check for maximum of Move to Prod Team Expected of Deployment
                if(project.Move_to_Production_Team_Expected__c == null 
                    || deployment.Move_to_Production_Team_Expected__c > project.Move_to_Production_Team_Expected__c)
                    project.Move_to_Production_Team_Expected__c = deployment.Move_to_Production_Team_Expected__c;
                
                mapProjects.put(project.Id,project);
                System.debug('####'+mapProjects);
            }
        }
        //Query rollup data with aggregate 
        /*List<AggregateResult> aggregateResults = [SELECT Max(C_A_DC__c)deploySign, Max(Move_to_Production_Team_Expected__c) prodExp, Project__c projId 
                                                        FROM Deployment__c WHERE Project__c IN : projIds Group By Project__c];
        
        //Check list of aggregate query size                                            
        if(aggregateResults.size() > 0){
            
            //Loop through aggregateResults list
            for(AggregateResult agg : aggregateResults){
                
                //Check not null criteria
                if(agg.get('deploySign') != null && agg.get('projId') != null){
                    
                    //Project Id
                    Id projectId = Id.valueOf(String.valueOf(agg.get('projId')));
                    
                    //add values in map
                    mapProjects.put(projectId, new Project__c(Id = projectId, Move_to_Production_Team_Expected__c = Date.valueOf(agg.get('prodExp')), 
                                    Final_Deployment_Sign_Off_Date__c = Date.valueOf(agg.get('deploySign'))));
                }
            }
        }*/
        
        System.debug('####'+mapProjects.size());
        //Check for map size
        if(mapProjects.size() > 0)
            util.BypassAllTriggers = true;
            update mapProjects.values();
        
    }
    
    // CR-3154
    // This method sets the deployment status field for the Deployment record when RecordType = Compass Connect Deployment
    // because this executes in the beforeUpdate portion of the trigger, we don't actually need to perform the update in the method
    public static void updateDeploymentStatus(List<Deployment__c> newDeployments){
        
        String Compass_Connect_RTID = Util.RecordTypeId('Deployment__c', Constants.RECORD_TYPE_DEPLOYMENT_COMPASS_CONNECT_DEPLOYMENT);
        for (Deployment__c newDeployment : newDeployments) {
            if (newDeployment.RecordTypeId == Compass_Connect_RTID) {
                String deploymentStatus;
                Date expected_TechnicalPlanning = newDeployment.C_E_TPC__c;
                Date expected_InitialDataIn = newDeployment.C_E_IDI__c;
                Date expected_CompleteDataIn = newDeployment.C_E_CDI__c;
                Date expected_DataDiagComplete = newDeployment.C_E_DDC__c;
                Date expected_InitSiteBuildComplete = newDeployment.C_E_IDC__c;
                Date expected_InternalValidationComplete = newDeployment.C_E_IVC__c;
                Date expected_DeploymentSignoff = newDeployment.C_E_DC__c;
                Date expected_RecurringUpdateSignOff = newDeployment.Expected_Recurring_Update_Sign_Off2__c;
                
                Date actual_TechnicalPlanning = newDeployment.C_A_TPC__c;
                Date actual_InitialDataIn = newDeployment.C_A_IDI__c;
                Date actual_CompleteDataIn = newDeployment.C_A_CDI__c;
                Date actual_DataDiagComplete = newDeployment.C_A_DDC__c;
                Date actual_InitSiteBuildComplete = newDeployment.C_A_ISBC__c;
                Date actual_InternalValidationComplete = newDeployment.C_A_IVC__c;
                Date actual_DeploymentSignoff = newDeployment.C_A_DC__c;
                Date actual_RecurringUpdateSignOff = newDeployment.Actual_Recurring_Update_Sign_Off__c;
                
                // create some date variables to hold data as it compares to the most current actual date completed
                Date actual_CurrentDate, actual_PreviousDate, expected_CurrentDate, expected_PreviousDate, 
                     expected_NextDate, expected_NextDate2;
                
                // figure out the which dates we need to compare by only taking the latest 2 expected vs actual dates
                if (actual_RecurringUpdateSignOff != null) {
                    system.debug('@@actual_RecurringUpdateSignOff:' + actual_RecurringUpdateSignOff);
                    expected_PreviousDate   = expected_DeploymentSignoff;
                    expected_CurrentDate    = expected_RecurringUpdateSignOff;
                    actual_PreviousDate = actual_DeploymentSignoff;
                    actual_CurrentDate  = actual_RecurringUpdateSignOff;
                }
                else if (actual_DeploymentSignoff != null) {
                    system.debug('@@actual_DeploymentSignoff:' + actual_DeploymentSignoff);
                    expected_PreviousDate   = expected_InternalValidationComplete;
                    expected_CurrentDate    = expected_DeploymentSignoff;
                    actual_PreviousDate = actual_InternalValidationComplete;
                    actual_CurrentDate  = actual_DeploymentSignoff;
                }
                else if (actual_InternalValidationComplete != null) {
                    system.debug('@@actual_InternalValidationComplete:' + actual_InternalValidationComplete);
                    expected_PreviousDate   = expected_InitSiteBuildComplete;
                    expected_CurrentDate    = expected_InternalValidationComplete;
                    expected_NextDate   = actual_DeploymentSignoff;
                    expected_NextDate2  = actual_RecurringUpdateSignOff;
                    actual_PreviousDate = actual_InitSiteBuildComplete;
                    actual_CurrentDate  = actual_InternalValidationComplete;
                }
                else if (actual_InitSiteBuildComplete != null) {
                    system.debug('@@actual_InitSiteBuildComplete:' + actual_InitSiteBuildComplete);
                    expected_PreviousDate   = expected_DataDiagComplete;
                    expected_CurrentDate    = expected_InitSiteBuildComplete;
                    expected_NextDate   = expected_InternalValidationComplete;
                    expected_NextDate2  = expected_DeploymentSignoff;
                    actual_PreviousDate = actual_DataDiagComplete;
                    actual_CurrentDate  = actual_InitSiteBuildComplete;
                }
                else if (actual_DataDiagComplete != null) {
                    system.debug('@@actual_DataDiagComplete:' + actual_DataDiagComplete);
                    expected_PreviousDate   = expected_CompleteDataIn;
                    expected_CurrentDate    = expected_DataDiagComplete;
                    expected_NextDate   = expected_InitSiteBuildComplete;
                    expected_NextDate2 = expected_InternalValidationComplete;
                    actual_PreviousDate = actual_CompleteDataIn;
                    actual_CurrentDate  = actual_DataDiagComplete;
                }
                else if (actual_CompleteDataIn != null) {
                    system.debug('@@actual_CompleteDataIn:' + actual_CompleteDataIn);
                    expected_PreviousDate   = expected_InitialDataIn;
                    expected_CurrentDate    = expected_CompleteDataIn;
                    expected_NextDate   = expected_DataDiagComplete;
                    expected_NextDate2 = expected_InitSiteBuildComplete;
                    actual_PreviousDate = actual_InitialDataIn;
                    actual_CurrentDate  = actual_CompleteDataIn;
                }
                else if (actual_InitialDataIn != null) {
                    system.debug('@@actual_InitialDataIn:' + actual_InitialDataIn);
                    expected_PreviousDate   = expected_TechnicalPlanning;
                    expected_CurrentDate    = expected_InitialDataIn;
                    expected_NextDate   = expected_CompleteDataIn;
                    expected_NextDate2 = expected_DataDiagComplete;
                    actual_PreviousDate = actual_TechnicalPlanning;
                    actual_CurrentDate  = actual_InitialDataIn;
                }
                else if (actual_TechnicalPlanning != null) {
                    system.debug('@@actual_TechnicalPlanning:' + actual_TechnicalPlanning);
                    expected_CurrentDate    = expected_TechnicalPlanning;
                    expected_NextDate   = expected_InitialDataIn;
                    expected_NextDate2 = expected_CompleteDataIn;
                    actual_CurrentDate  = actual_TechnicalPlanning;
                }
                else if (actual_TechnicalPlanning == null) {
                    system.debug('@@actual_TechnicalPlanning is null');
                    expected_CurrentDate    = expected_TechnicalPlanning;
                    expected_NextDate   = expected_InitialDataIn;
                    expected_NextDate2 = expected_CompleteDataIn;
                    actual_CurrentDate  = system.today();
                }
                
                if (actual_CurrentDate != null) {
                    if (actual_CurrentDate <= expected_CurrentDate) {
                        if (expected_NextDate != null && 
                            expected_NextDate2 != null &&
                            expected_NextDate < system.today() && 
                            expected_NextDate2 < system.today())
                        {// missed 2 expected dates in the future
                            deploymentStatus = 'Red';
                        }
                        else if (expected_NextDate != null &&
                            expected_NextDate < system.today())
                        {// missed 1 expected date in the future
                            deploymentStatus = 'Yellow';
                        }
                        else {// no missed expected dates
                            deploymentStatus = 'Green';
                        }
                    }
                    if (actual_CurrentDate > expected_CurrentDate) {
                        if (actual_PreviousDate == null) {
                            if (expected_NextDate != null && 
                                expected_NextDate < system.today()) 
                            {
                                    // we are two milestones behind
                                    deploymentStatus = 'Red';
                            }
                            else {
                                deploymentStatus = 'Yellow';
                            }
                        }
                        else if (actual_PreviousDate != null && actual_PreviousDate > expected_PreviousDate) {
                            // previous and current milestones missed expected date
                            deploymentStatus = 'Red';
                        }
                        else {// only 1 missed expected date
                            deploymentStatus = 'Yellow';
                        }
                    }
                }
                
                if (deploymentStatus != null) newDeployment.CPM_Deployment_Status__c = deploymentStatus;
                system.debug('@@deploymentStatus:' + deploymentStatus);
            }
        }
    }
    
    //Modified By - Ajit Surana - 09/08/2014 - CR-20140716-6256 - Exclude Project Record Type "SSC" from this method
    //Added By - Abhinav Sharma - 03-03-2014 - CR-20130829-3543 - CMA - Elapsed Time Field - Moved to Prod Team
    //Modified By - Abhinav Sharma - 04/29/2014 - CR-20140403-4958 - Site Live - Target, Actual - not completed with 3968
    //Modified By - Abhinav Sharma - 11/25/2014 - CR-20141106-8010 - Revert change to Site Live field on SSC projects 
    /**
     *  @description    :   Method to set First_Deployment_Signed_Off__c field on the Project with the earliest value from the "Deployment Sign Off (Actual)" field on 
     *            the associated Deployment records whenever the associated Deployment record is inserted/updated.
     *
     *  @args           :   List of deployments, Map of old Deployments
     *
     *  @return         :   void
     *
     **/
    public static void populateFirstDeploymentSignedOff(List<Deployment__c> newDeployments, Map<Id, Deployment__c> mapOldDeployments) {
        
        //Set to hold Parent Project Ids
        Set<Id> setProjectsIds = new Set<Id>();

        //List to hold the current Context Deployment records
        List<Deployment__c> listDeployments = newDeployments != null ? newDeployments : mapOldDeployments.values();

        //Loop through deployment records and populating set with parent project records Id value
        for(Deployment__c deploy : listDeployments) {
          
            //Checking for parent project Id value and applying some other valid validations use cases
            if(deploy.Project__c != null && ((newDeployments != null && mapOldDeployments != null && (deploy.C_A_DC__c != mapOldDeployments.get(deploy.Id).C_A_DC__c || deploy.C_E_DC__c != mapOldDeployments.get(deploy.Id).C_E_DC__c))
                              || (newDeployments != null && mapOldDeployments == null)
                              || (newDeployments == null && mapOldDeployments != null)
            )) {
                setProjectsIds.add(deploy.Project__c);  
            }
        }
        
        //Chech set size before executing the further logic
        if(setProjectsIds.size() == 0)
            return;
          
        //List to hold the "Project" records to update
        Map<Id, Project__c> mapAllprojects = new Map<Id, Project__c>();
        
        //Map of Projects
        Map<Id, Project__c> mapProjects = new Map<Id, Project__c>();
        
        //Modified By - Ajit Surana - CR-20140716-6256 - 09/08/2014 - Added an extra filter of Record Type not equal to 'SSC'
        //Modified By - Abhinav Sharma - CR-20141106-8010 - 11/25/2014 - Removing filter of Record Type not equals to 'SSC'
        //Loop through parent project records and populating First_Deployment_Signed_Off__c field on the Project with the earliest value from the "Deployment Sign Off (Actual)" field. 
        for(Project__c project : [SELECT Id, First_Deployment_Signed_Off__c, Date_Site_Live__c, Site_Live_Target__c,
                       (SELECT Id, C_A_DC__c, C_E_DC__c FROM Deployments__r WHERE C_A_DC__c != null ORDER BY C_A_DC__c ASC LIMIT 1)
                          FROM Project__c WHERE Id IN : setProjectsIds]) {
        
            //Populating map with the values
            mapAllprojects.put(project.Id, project);
            
            //Modified By - Abhinav Sharma - 04/29/2014 - CR-20140403-4958
            //Populating project.Date_Site_Live__c with Oldest deployment record's Deployment Sign Off (Actual) field value
            //Populating First_Deployment_Signed_Off__c field on the Project with oldest value from the "Deployment Sign Off (Actual)" field on the associated Deployment records
            //Populating project.Site_Live_Target__c field on the project with Deployment Sign Off (Expected) field value from the deployment having oldest deployment sign off (actual) field value
            //Only Process the record if found and
            if(project.Deployments__r.size() > 0) {

                //Add record in the list to be updated
                project.First_Deployment_Signed_Off__c = project.Deployments__r[0].C_A_DC__c;
                project.Date_Site_Live__c = project.Deployments__r[0].C_A_DC__c;
                project.Site_Live_Target__c = project.Deployments__r[0].C_E_DC__c;
                mapProjects.put(project.Id, project);
            
            } 
        }
        
        //Modified By - Ajit Surana - CR-20140716-6256 - 09/08/2014 - Added an extra filter of Record Type not equal to 'SSC'
        //Modified By - Abhinav Sharma - CR-20141106-8010 - 11/25/2014 - Removing filter of Record Type not equals to 'SSC'
        //Loop through parent project records and populating First_Deployment_Signed_Off__c field on the Project with the earliest value from the "Deployment Sign Off (Actual)" field. 
        for(Project__c project : [SELECT Id, First_Deployment_Signed_Off__c, Date_Site_Live__c, Site_Live_Target__c,
                       (SELECT Id, C_A_DC__c, C_E_DC__c FROM Deployments__r WHERE C_E_DC__c != null ORDER BY C_E_DC__c ASC LIMIT 1)
                          FROM Project__c WHERE Id IN : setProjectsIds AND ID NOT IN : mapProjects.keySet()]) {
        
            //Modified By - Abhinav Sharma - 04/29/2014 - CR-20140403-4958
            //Populating project.Date_Site_Live__c with Oldest deployment record's Deployment Sign Off (Actual) field value
            //Populating First_Deployment_Signed_Off__c field on the Project with oldest value from the "Deployment Sign Off (Actual)" field on the associated Deployment records
            //Populating project.Site_Live_Target__c field on the project with Deployment Sign Off (Expected) field value from the deployment having oldest deployment sign off (actual) field value
            //Only Process the record if found and
            if(project.Deployments__r.size() > 0) {

                //Add record in the list to be updated
                project.First_Deployment_Signed_Off__c = project.Deployments__r[0].C_A_DC__c;
                project.Date_Site_Live__c = project.Deployments__r[0].C_A_DC__c;
                project.Site_Live_Target__c = project.Deployments__r[0].C_E_DC__c;
                mapProjects.put(project.Id, project);
            
            } 
        }
        
        //Checking map for size value
        if(mapAllprojects.values().size() > 0) {
        
            //Loop through map values
            for(Project__c project : mapAllprojects.values()) {
                
                //Checking for the value in the map
                if(!mapProjects.containsKey(project.Id)) {
                    project.First_Deployment_Signed_Off__c = null;
                    project.Date_Site_Live__c = null;
                    project.Site_Live_Target__c = null;
                } else {
                    mapAllprojects.put(project.Id, mapProjects.get(project.Id));
                }
            }
            
            //Updating list of projects 
            update mapAllprojects.values();
        }
    }     
    
    //Added By - Abhinav Sharma - 05/01/2014 - CR-20140408-5000
    /**
     *  @description    :   Method to rollup values from Deployment on the Project object.
     *
     *  @args           :   List of deployments, Map of old Deployments
     *
     *  @return         :   void
     *
     **/
    public static void populateDeploymentDataOnProject(List<Deployment__c> newDeployments, Map<Id, Deployment__c> mapOldDeployments) {
        
        //Map to hold the Project Id as key and project record as value
        Map<Id, Project__c> mapProjects = new Map<Id, Project__c>();
        
        //Retreiving SSM Record type for deployment object
        RecordType ssmRdType = [SELECT ID, DeveloperName FROM RecordType WHERE SobjectType = 'Deployment__c' AND IsActive = true AND DeveloperName = 'SSM_Deployment' LIMIT 1];
        
        //Checking for record type existence
        if(ssmRdType != null) {
        
            //Loop through the Deployment records
            if(newDeployments != null) {
                for(Deployment__c deploy : newDeployments) {
                    
                    //Populating map in the case of insert event
                    if(mapOldDeployments == null) {
                        if(deploy.Project__c != null && deploy.RecordTypeId == ssmRdType.ID)
                            mapProjects.put(deploy.Project__c, new Project__c(Id=deploy.Project__c, Actual_Risk_Payment_w_Sign_Off__c = 0, 
                                            Total_Actual_Revenue_to_Date__c = 0, Minimum_Market_Basket_Size__c = 0));
                    
                    //Populating the map in the case of update event after applying all the required validations
                    } else {
                        
                        //Checking and validating deployment record fields for appropriate values and value change
                        if(deploy.Contingent_Revenue_Invoiced__c != mapOldDeployments.get(deploy.Id).Contingent_Revenue_Invoiced__c
                            || deploy.Total_Actual_Revenue_to_Date__c != mapOldDeployments.get(deploy.Id).Total_Actual_Revenue_to_Date__c
                            || deploy.Actual_Market_Basket_Size__c != mapOldDeployments.get(deploy.Id).Actual_Market_Basket_Size__c
                            || deploy.Project__c != mapOldDeployments.get(deploy.Id).Project__c) {
                                
                            if(deploy.Project__c != null && deploy.RecordTypeId == ssmRdType.ID)
                                mapProjects.put(deploy.Project__c, new Project__c(Id=deploy.Project__c, Actual_Risk_Payment_w_Sign_Off__c = 0, 
                                                Total_Actual_Revenue_to_Date__c = 0, Minimum_Market_Basket_Size__c = 0));
                            if(mapOldDeployments.get(deploy.Id).Project__c != null && deploy.RecordTypeId == ssmRdType.ID)
                               mapProjects.put(mapOldDeployments.get(deploy.Id).Project__c, new Project__c(Id=mapOldDeployments.get(deploy.Id).Project__c, Actual_Risk_Payment_w_Sign_Off__c = 0, 
                                                Total_Actual_Revenue_to_Date__c = 0, Minimum_Market_Basket_Size__c = 0));
                        }    
                    }      
                }
              
            //Populating map in the case of delete event    
            } else {
                for(Deployment__c deploy : mapOldDeployments.values()) {
                    if(mapOldDeployments.get(deploy.Id).Project__c != null && deploy.RecordTypeId == ssmRdType.ID)
                        mapProjects.put(mapOldDeployments.get(deploy.Id).Project__c, new Project__c(Id=mapOldDeployments.get(deploy.Id).Project__c, Actual_Risk_Payment_w_Sign_Off__c = 0, 
                                            Total_Actual_Revenue_to_Date__c = 0, Minimum_Market_Basket_Size__c = 0));
                }
            }
        
            //Chech size of map before executing the further logic   
            if(mapProjects.size() > 0) {
            
                //Loop through deployment record associated to the project records are of "SSM Deplopyment" record type
                for(Deployment__c deployment : [SELECT ID, Contingent_Revenue_Invoiced__c, Total_Actual_Revenue_to_Date__c, Actual_Market_Basket_Size__c,
                                                Project__c FROM Deployment__c WHERE Project__c != null AND Project__c IN: mapProjects.keySet() AND RecordType.DeveloperName = 'SSM_Deployment']){
                            
                    //Initializing variable helpful in calculations 
                    Decimal tcrInvoiceCount = 0;
                    Decimal tarDateCount = 0;
                    Decimal tmbSizeCount = 0;
                        
                    //Checking if "Total Contingent Revenue Invoice" field on Project & "Contingent Revenue Invoiced" on Deployment is not null 
                    if(deployment.Contingent_Revenue_Invoiced__c!= null && mapProjects.get(deployment.Project__c).Actual_Risk_Payment_w_Sign_Off__c!= null)
                        tcrInvoiceCount = mapProjects.get(deployment.Project__c).Actual_Risk_Payment_w_Sign_Off__c + deployment.Contingent_Revenue_Invoiced__c;
                        
                    //Checking if "Total Actual Revenue to Date" field on Project & "Total Actual Revenue to Date" on Deployment is not null
                    if(deployment.Total_Actual_Revenue_to_Date__c!= null && mapProjects.get(deployment.Project__c).Total_Actual_Revenue_to_Date__c!= null)
                        tarDateCount = mapProjects.get(deployment.Project__c).Total_Actual_Revenue_to_Date__c + deployment.Total_Actual_Revenue_to_Date__c;
                        
                    //Checking if "Total LOA Market Basket Size" field on Project & "Actual Market Basket Size" on Deployment is not null
                    if(deployment.Actual_Market_Basket_Size__c!= null && mapProjects.get(deployment.Project__c).Minimum_Market_Basket_Size__c!= null)
                        tmbSizeCount = mapProjects.get(deployment.Project__c).Minimum_Market_Basket_Size__c + deployment.Actual_Market_Basket_Size__c;
                        
                    mapProjects.put(deployment.Project__c, new Project__c(Id=deployment.Project__c, Actual_Risk_Payment_w_Sign_Off__c = tcrInvoiceCount,
                                                                                Total_Actual_Revenue_to_Date__c = tarDateCount, Minimum_Market_Basket_Size__c = tmbSizeCount));
                }
            }
        
            //Checking for size value  
            if(mapProjects.values().size() > 0)
                update mapProjects.values();    
        }
    }
    
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
    public static void populateDeploymentSignOffOldestOnProject(List<Deployment__c> newDeployments, Map<Id, Deployment__c> mapOldDeployments) {
        
        //Set to hold Project Id of Deployment record
        Set<Id> projectIds = new Set<Id>();
        
        //Map to hold key=> ProjectId & value=> instance of Project sobject
        Map<Id, Project__c> mapProjectToBeUpdated = new Map<Id, Project__c>();
        
        //Check for only in case of Insertion or Updation
        if(newDeployments != null) {
        
            //Loop through Trigger.new
            for(Deployment__c newDeployment : newDeployments) {
                
                //Check for null & adding ProjectId into set
                if(newDeployment.Project__c != null)    
                    projectIds.add(newDeployment.Project__c);
                
                //Check if Project is update on Deployment from previous
                if(mapOldDeployments != null && newDeployment.Project__c != mapOldDeployments.get(newDeployment.Id).Project__c)
                    projectIds.add(mapOldDeployments.get(newDeployment.Id).Project__c);
            }
        } else {
            
            //Loop through Trigger.new
            for(Deployment__c oldDeployment : mapOldDeployments.values()) {
                
                //Check for null & adding ProjectId into set
                if(oldDeployment.Project__c != null)    
                    projectIds.add(oldDeployment.Project__c);
            }
        }
        
        if(projectIds.size() > 0)
            mapProjectToBeUpdated = DeploymentTriggerHelper.getRCSProjectToUpdate(projectIds);
        
        //update the Projects with their "Deployment Sign-Off (Oldest)"
        if(mapProjectToBeUpdated.size() > 0) {
            
            Util.BypassAllTriggers = true;
            update mapProjectToBeUpdated.values();
        }
    }
    
    //Added By - Abhinav Sharma - 10/17/2014 - CR-20140826-7138
    /**
     *  @description    :   Method is used as generic bunch of logic to get a map of RCS projects which are need to updated 
     *                      for Deployment_Sign_Off_Oldest__c field values. 
     *
     *  @args           :   List of deployments, Map of old Deployments
     *
     *  @return         :   void
     *
     **/
    public static Map<Id, Project__c> getRCSProjectToUpdate(Set<Id> projectIds) {
        
        //Map to hold key=> ProjectId & value=> instance of Project sobject
        Map<Id, Project__c> mapRCSProjects = new Map<Id, Project__c>();
        
        //Loop through query result of Project who is related to "RCS" recordType 
        for(Project__c rcsProject : [SELECT Id FROM Project__c WHERE Id IN: projectIds AND RecordType.DeveloperName = 'RCS']) {
            
            //Check for ProjectId of Deployment is not process already
            //and populate the Map
            mapRCSProjects.put(rcsProject.Id, new Project__c(Id = rcsProject.Id, Deployment_Sign_Off_Oldest__c = null));
        }
        
        //Check for size of mapProjectToBeUpdated
        if(mapRCSProjects.size() > 0) {
            
            //Loop through aggregate results for finding oldest  Deployment Sign Off (Actual) date
            for(AggregateResult aResult : [SELECT MIN(C_A_DC__c) minSignOffActual, Project__c FROM Deployment__c 
                                                WHERE Project__c != null AND Project__c IN: mapRCSProjects.keyset() GROUP BY Project__c]) {
                
                //Getting and store the Aggregate result of Project Id
                Id projectId = (Id)aResult.get('Project__c'); 
                
                //Check ProjectId is already contians into map
                if(mapRCSProjects.containsKey(projectId)) {
                    
                    //Getting and store the Aggregate result of Minimum function of Deployment Sign Off (Actual)
                    //add store the date value into Project's "Deployment Sign-Off (Oldest)" 
                    mapRCSProjects.get(projectId).Deployment_Sign_Off_Oldest__c = (Date)aResult.get('minSignOffActual');
                }
            }
        }
        
        return mapRCSProjects;
    }       
}