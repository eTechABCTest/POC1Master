/**
    Purpose         :   Helper class for Trigger on Project Role Object.
                
    Created By      :   Abhinav Sharma
    
    Created Date    :   03/03/2015
    
    Current Version :   v1.0
    
    Revision Log    :   v1.0 - Abhinav Sharma - 03/03/2015 - CR-20141222-8389 - Added methods (validateProjectKeyRole, validateExistanceOfPrimaryRoles)
                        
**/
public class ProjectRoleTriggerHelper {

    //Added By - Abhinav Sharma - CR-20141222-8389 - 03/03/2015
    /**
     *  @description    :  Method to check and validate that primary Project Role can only be added once.  
     *
     *  @args           :   List of project roles, Boolean isBefore
     * 
     *  @return         :   void
     * 
    **/ 
    public static void validateExistanceOfPrimaryRoles(List<Project_Role__c> newProjectRoles, Map<Id, Project_Role__c> mapOldProjectRoles) {
        
        //Set to hold the project IDs
        Set<Id> setProjectIds = new Set<Id>();
        
        //Set to hold the role values
        Set<String> setOfPrimaryRoles = new Set<String>();
        setOfPrimaryRoles.add('Executive Sponsor');
        setOfPrimaryRoles.add('Contract Signer');
        setOfPrimaryRoles.add('Implementation Lead');
        setOfPrimaryRoles.add('Value Lead');
        
        //Loop through new project role records
        for(Project_Role__c pR : newProjectRoles) {
            
            //Checking and validating for role field values
            if(mapOldProjectRoles == null || (mapOldProjectRoles != null && mapOldProjectRoles.get(pR.Id) != null 
                                                && mapOldProjectRoles.get(pR.Id).Role__c != pR.Role__c)) {
                if(pR.Project__c != null)      
                    setProjectIds.add(pR.Project__c);
                    
                if(mapOldProjectRoles != null && mapOldProjectRoles.get(pR.Id) != null
                    && mapOldProjectRoles.get(pR.Id).Project__c != null)
                    setProjectIds.add(mapOldProjectRoles.get(pR.Id).Project__c);
            }
        }
        
        //Set to hold the project record types IDs - needs to be excluded for the role standardization logic
        Set<ID> setExcludedRecordTypes = new Set<ID>();
        for(RecordType rd : [SELECT ID FROM RecordType WHERE sObjectType = 'Project__c' AND IsActive = true
                                    AND (DeveloperName = 'Univ' OR DeveloperName = 'NPD' OR DeveloperName = 'ABSS'
                                            OR DeveloperName = 'SSC' OR DeveloperName = 'Southwind' OR DeveloperName = 'TI'
                                                OR DeveloperName = 'Consulting')])
            setExcludedRecordTypes.add(rd.Id);
        
        //Map of Projects
        Map<Id, Project__c> mapProjects = new Map<Id, Project__c>([SELECT ID, RecordTypeId FROM Project__c 
                                                                    WHERE ID IN : setProjectIds AND RecordTypeID NOT IN : setExcludedRecordTypes]);
        
        //Map to hold the Project Id - Role combined string as key and corresponding record count as value
        Map<String, Integer> mapProjectIdAndRoleKeyWithRecordCount = new Map<String, Integer>();
            
        //Loop through change requests records already assigned to a release
        for(Project_Role__c pRol : [SELECT ID, Role__c, Project__c FROM Project_Role__c 
                                            WHERE Project__c != null AND Project__c IN: mapProjects.keySet()]) {
                
            //Checking for the primary role values and accordingly populating the map                                
            if(String.isNotBlank(pRol.Role__c) && setOfPrimaryRoles.contains(pRol.Role__c)) {
                if(mapProjectIdAndRoleKeyWithRecordCount.containsKey(pRol.Project__c + '-' + pRol.Role__c))
                     mapProjectIdAndRoleKeyWithRecordCount.put(pRol.Project__c + '-' + pRol.Role__c, mapProjectIdAndRoleKeyWithRecordCount.get(pRol.Project__c + '-' + pRol.Role__c) + 1);
                else
                    mapProjectIdAndRoleKeyWithRecordCount.put(pRol.Project__c + '-' + pRol.Role__c, 1); 
            }       
        }
        
        //Loop through new project role records
        for(Project_Role__c pRole : newProjectRoles) {
            if(pRole.project__c != null && String.isNotBlank(pRole.Role__c)
                && mapProjectIdAndRoleKeyWithRecordCount != null  
                && mapProjectIdAndRoleKeyWithRecordCount.get(pRole.project__c + '-' + pRole.Role__c) != null
                && mapProjectIdAndRoleKeyWithRecordCount .get(pRole.project__c + '-' + pRole.Role__c) > 1) {
                pRole.addError(System.Label.Error_Message_Primary_Role_Already_Exists);
            }
        }
    }
    
    //Added By - Abhinav Sharma - CR-20141222-8389 - 03/03/2015
    /**
     *  @description    :  Method to update the flag “Key Roles Identified” on “Project” record as TRUE.
     *                     If we are having Project Role associated to it with below each below listed roles:-
     *                          Executive Sponsor
     *                          Contract Signer
     *                          Implementation Lead
     *                          Value Lead
     *                     If not then false.
     * 
     *  @args           :   List of project roles, map of old project roles
     * 
     *  @return         :   void
     * 
    **/ 
    public static void validateProjectKeyRole(List<Project_Role__c> newProjectRoles, Map<Id, Project_Role__c> mapOldProjectRoles) {
        
        //Set of Project Ids
        Set<Id> setProjectIds = new Set<Id>();
        
        //Map of Projects
        Map<Id, Project__c> mapProjects = new Map<Id, Project__c>();
        
        //Loop through the Project Roles records
        if(newProjectRoles != null) {
            
            //Loop through new project role records
            for(Project_Role__c pR : newProjectRoles) {
                
                //Insert case
                if(mapOldProjectRoles == null) {
                    if(pR.Project__c != null)
                        setProjectIds.add(pR.Project__c);
                //Update Case
                } else {
                    if(pR.Project__c != null)
                        setProjectIds.add(pR.Project__c);
                    if(mapOldProjectRoles.get(pR.Id).Project__c != null)
                        setProjectIds.add(mapOldProjectRoles.get(pR.Id).Project__c);
                }      
            }
        //Delete Case
        } else {
            for(Project_Role__c pRole : mapOldProjectRoles.values()) {
                if(mapOldProjectRoles.get(pRole.Id).Project__c != null)
                    setProjectIds.add(mapOldProjectRoles.get(pRole.Id).Project__c);
            }
        }
         
        //Check if there are records to update
        if(setProjectIds.size() > 0) {
            
            //Set to hold the role values
            Set<String> setRoles = new Set<String>();
            setRoles.add('Executive Sponsor');
            setRoles.add('Contract Signer');
            setRoles.add('Implementation Lead');
            setRoles.add('Value Lead');
            
            //Set to hold the project record types IDs - needs to be excluded for the role standardization logic
            Set<ID> setExcludedRecordTypes = new Set<ID>();
            for(RecordType rd : [SELECT ID FROM RecordType WHERE sObjectType = 'Project__c' AND IsActive = true
                                    AND (DeveloperName = 'Univ' OR DeveloperName = 'NPD' OR DeveloperName = 'ABSS'
                                            OR DeveloperName = 'SSC' OR DeveloperName = 'Southwind' OR DeveloperName = 'TI')])
                setExcludedRecordTypes.add(rd.Id);
        
            //Map of ELigible Projects
            mapProjects = new Map<Id, Project__c>([SELECT ID, RecordTypeId, Key_Roles_Identified__c FROM Project__c 
                                                                                    WHERE ID IN : setProjectIds 
                                                                                    AND RecordTypeID NOT IN : setExcludedRecordTypes]);
            
            //Map to hold the project Id as key and set of corresponding project roles role field values
            Map<Id, Set<String>> mapProjectIdWithSetOfRoles = new Map<Id, Set<String>>();
            
            //Loop through change requests records already assigned to a release
            for(Project_Role__c pRol : [SELECT ID, Role__c, Project__c FROM Project_Role__c 
                                                WHERE Project__c != null AND Project__c IN: mapProjects.keySet()]) {
                                                    
                if(mapProjectIdWithSetOfRoles.containsKey(pRol.Project__c))
                    mapProjectIdWithSetOfRoles.get(pRol.Project__c).add(pRol.Role__c);
                else
                    mapProjectIdWithSetOfRoles.put(pRol.Project__c, new Set<String>{pRol.Role__c}); 
            }
            
            //Loop through map keys
            for(String key : mapProjectIdWithSetOfRoles.keySet()) {
                if(mapProjectIdWithSetOfRoles.containsKey(key) && mapProjectIdWithSetOfRoles.get(key) != null && mapProjects.get(key) != null) {
                    if(mapProjectIdWithSetOfRoles.get(key).containsAll(setRoles))
                        mapProjects.get(key).Key_Roles_Identified__c = true;
                    else
                        mapProjects.get(key).Key_Roles_Identified__c = false;
                }
            }
        }
        
        //Checking for size value
        if(mapProjects.values().size() > 0) {
            Util.BypassAllTriggers = true;
            update mapProjects.values(); 
            Util.BypassAllTriggers = false;
        }       
    }
}