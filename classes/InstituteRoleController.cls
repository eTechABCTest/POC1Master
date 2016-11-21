/*
    Purpose:    This class is  to prevent duplicate roles on an institution for the roles that appear in the
                pick list (i.e., should not be able to enter a 'CNO' role if one already exists)..
                
    Create By:  Simplyforce Technology
    
    Created Date:   10/09/2011
    
    Current Version:    v1.0
    
    Revision Log:       01/13/2014 - Victor Hanson - Added the 2 US Provider record types (CR-20130903-3556)
*/
public with sharing class InstituteRoleController {
    
    //property to hold the account
    public Account account{get; set;}
    public Institution_Roles__c instituteRole{get;set;}
    public Map<String, Institution_Roles__c> mapInstitutionRoles{get;set;}
    public List<Institution_Roles__c> listUnusedInstituteRoles{get; set;}
    
    //property to hold teh record type of institution
    String recordType;
    
    //create a new lidt to hold teh institute role records in sorted format
    List<Institution_Roles__c> sortedList = new List<Institution_Roles__c>();
    
    public List<Institution_Roles__c> listInstitutionRoles {
        get {
            
            //return the final result
            return sortedList;
        }
    }
    
    //variable to replicate the behaviour of dependent picklist in code
    Map<String, Set<String>> rolesWithRecordType = new Map<String, Set<String>>();
    
    //constructor
    public InstituteRoleController(ApexPages.StandardController controller) {
        
        instituteRole = (Institution_Roles__c)controller.getRecord();
        
        //check if edit case then catch the instute and other data
        if(instituteRole.Id != null)
            instituteRole = [Select Id, Institution__c from Institution_Roles__c where Id =: instituteRole.Id];
        
        //intialized list of the duplicate records so these can be deleted from the page
        listUnusedInstituteRoles = new List<Institution_Roles__c>();
        
        //Populate the record type map
        rolesWithRecordType.put('US Provider - Hospital', new Set<String>{'CDO','CEO','CFO','CIO','CMO','CNO','COO','CQO','VP HR','VP Marketing/Planning'});
        rolesWithRecordType.put('US Provider - System', new Set<String>{'CDO','CEO','CFO','CIO','CMO','CNO','COO','CQO','VP HR','VP Marketing/Planning'});
        rolesWithRecordType.put('US Provider Strategic', new Set<String>{'CDO','CEO','CFO','CIO','CMO','CNO','COO','CQO','VP HR','VP Marketing/Planning'});
        rolesWithRecordType.put('International Provider', new Set<String>{'CDO - Head of Development','CEO - Head of Organization','CFO - Head of Finance','CIO - Head of Information Technology','CMO - Medical Director','CNO - Head of Nursing','COO - Head of Operations','CQO - Head of Quality','VP HR - Head of Human Resources','VP Marketing/Planning - Head of Mktg/Planning'});
        rolesWithRecordType.put('US Education', new Set<String>{'EAB: Assoc VP (Provost) of Acad Affairs','EAB: Assoc VP of Finance & Admin','EAB: Chief Information Officer','EAB: Community College President','EAB: Dean of Students','EAB: Dir. of Mkting & Online Ed (COE #2)','EAB: Director of Facilities','EAB: Director of Procurement','EAB: Head of Admissions/Enrollment','EAB: President, Four-Year Institution','EAB: Provost & VP of Academic Affairs','EAB: VP of Advancement','EAB: VP of Enrollment','EAB: VP of Finance & Administration/CBO','EAB: VP of Human Resources','EAB: VP of Online Education (COE #1)','EAB: VP of Research','EAB: VP of Student Affairs'});
        rolesWithRecordType.put('International Education', new Set<String>{'EAB: Assoc VP (Provost) of Acad Affairs','EAB: Assoc VP of Finance & Admin','EAB: Chief Information Officer','EAB: Community College President','EAB: Dean of Students','EAB: Dir. of Mkting & Online Ed (COE #2)','EAB: Director of Facilities','EAB: Director of Procurement','EAB: Head of Admissions/Enrollment','EAB: President, Four-Year Institution','EAB: Provost & VP of Academic Affairs','EAB: VP of Advancement','EAB: VP of Enrollment','EAB: VP of Finance & Administration/CBO','EAB: VP of Human Resources','EAB: VP of Online Education (COE #1)','EAB: VP of Research','EAB: VP of Student Affairs'});
        rolesWithRecordType.put('US Corporate', new Set<String>{'CEO','CFO','COO','VP Business Development - Head of BD','VP Marketing - Head of Marketing','VP of HR - Head of HR','VP Sales - Head of Sales','VP Strategy - Head of Strategy'});
        rolesWithRecordType.put('International Corporate', new Set<String>{'CEO','CFO','COO','VP Business Development - Head of BD','VP Marketing - Head of Marketing','VP of HR - Head of HR','VP Sales - Head of Sales'});
        rolesWithRecordType.put('US HCIC', new Set<String>{'CEO','CFO','CMO','COO','VP Business Development - Head of BD','VP Marketing - Head of Marketing','VP of HR - Head of HR','VP Provider Relations - Head of Provider Relations','VP Sales - Head of Sales','VP Strategy - Head of Strategy'});
        rolesWithRecordType.put('International HCIC', new Set<String>{'CEO','CFO','CMO','COO','VP Business Development - Head of BD','VP Marketing - Head of Marketing','VP of HR - Head of HR','VP Provider Relations - Head of Provider Relations','VP Sales - Head of Sales','VP Strategy - Head of Strategy'});
        
        //check if the account id not equals to null
        if(ApexPages.currentPage().getParameters().get('accId') != null && ApexPages.currentPage().getParameters().get('accId') != '') {
            instituteRole.Institution__c = ApexPages.currentPage().getParameters().get('accId');
        }
        
        List<Account> institutes = [Select Id, RecordType.DeveloperName, Record_Type_Text__c from Account where Id =: instituteRole.Institution__c];
        
        if (institutes.size() > 0) account = institutes[0];
        
        //get the institute record type and draw the appropriate roles on the screen
        if(ApexPages.currentPage().getParameters().get('recordType') != null && ApexPages.currentPage().getParameters().get('recordType') != '') {
            recordType = ApexPages.currentPage().getParameters().get('recordType');
        } else if(institutes.size() > 0){
            recordType = institutes[0].Record_Type_Text__c;
        }
        
        //initialize the map
        mapInstitutionRoles = new Map<String, Institution_Roles__c>();
        
        //check the institute record type and only create the appropriate role's rows on the screen 
        Set<String> allowedRoles = new Set<String>();
        
        //check if teh recordtype is not null and exists in map
        if(recordType != null && recordType != '' && rolesWithRecordType.containsKey(recordType)) {
            
            allowedRoles = rolesWithRecordType.get(recordType);
        
            //check for the recordType and add the appropriate roles rows, In case of other all roles will be added
            if(!('Other'.equalsIgnoreCase(recordType))) {
                
                //get all the account related Institution_Roles__c
                for(Institution_Roles__c instRule : [Select Id, Name, Role__c, Contact__c, ABC_Owner__c, Type_of_Contact__c, Last_Interaction__c, Next_Interaction__c, 
                                                        Assignment_Comment__c from Institution_Roles__c
                                                        where Institution__c =: instituteRole.Institution__c and Role__c != null]) {
        
                    if(allowedRoles.contains(instRule.Role__c)) {
                        //check if same role is added two times in existing list then add it in to the unUsed list to allow user to delete these records
                        if(mapInstitutionRoles.containsKey(instRule.Role__c)) {
                            listUnusedInstituteRoles.add(instRule);
                        } else {
                            //add data in map
                            mapInstitutionRoles.put(instRule.Role__c, instRule);
                        }
                    } else {
                        //add data in map
                        listUnusedInstituteRoles.add(instRule);
                    }
                }
            } else {
                
                //get all the account related Institution_Roles__c
                for(Institution_Roles__c instRule : [Select Id, Name, Contact__c, Assignment_Comment__c, Role__c from Institution_Roles__c
                                                 where Institution__c =: instituteRole.Institution__c and Role__c != null]) {
        
                    //check if same role is added two times in existing list then add it in to the unUsed list to allow user to delete these records
                    if(mapInstitutionRoles.containsKey(instRule.Role__c)) {
                        listUnusedInstituteRoles.add(instRule);
                    } else {
                        //add data in map
                        mapInstitutionRoles.put(instRule.Role__c, instRule);
                    }
                }
            }
            
            System.debug('@@@@@ mapInstitutionRoles before ' + mapInstitutionRoles);
                    
            //describe the picklist field and add the remaing record with a fresh institute rule
            Schema.DescribeFieldResult F = Institution_Roles__c.Role__c.getDescribe();
            List<Schema.PicklistEntry> P = F.getPicklistValues();
            
            for(Schema.PicklistEntry pickListObj : P) {
                
                //check for the recordType and add the appropriate roles rows, In case of other all roles will be added
                if(!('Other'.equalsIgnoreCase(recordType))) {
                    if(allowedRoles.contains(pickListObj.getValue())) {
                        if(!mapInstitutionRoles.containskey(pickListObj.getValue())) {
                            //add data in map
                            mapInstitutionRoles.put(pickListObj.getValue(), new Institution_Roles__c(Institution__c = instituteRole.Institution__c, Role__c = pickListObj.getValue()));
                        }
                    }
                } else {
                    System.debug('@@@@@ pickListObj.getValue() ' + pickListObj.getValue());
                    System.debug('@@@@@ mapInstitutionRoles ' + mapInstitutionRoles);
                    if(!mapInstitutionRoles.containskey(pickListObj.getValue())) {
                            //add data in map
                        mapInstitutionRoles.put(pickListObj.getValue(), new Institution_Roles__c(Institution__c = instituteRole.Institution__c, Role__c = pickListObj.getValue()));
                    }
                    System.debug('@@@@@ mapInstitutionRoles After ' + mapInstitutionRoles);
                }
            }
        }
        
        //get the roles set and process the result the get the data in sorted format
        List<String> roles = new List<String>();
        roles.addAll(mapInstitutionRoles.keySet());
        
        //sort roles
        roles.sort();
        
        for(String roleName : roles) {
            sortedList.add(mapInstitutionRoles.get(roleName));
        }
    }
    
    //method to save the institution roles and redirect back to the account page
    //rows will contact will only be saled, rest will be discarded.
    public PageReference save() {
        
        //create a savepoint to roll back the transaction in case of exception
        Savepoint sp = Database.setSavePoint();
        
        try {
            //List of roles to be saved
            List<Institution_Roles__c> listToUpsert = new List<Institution_Roles__c>();
            
            //loop through the listInstitutionRoles
            for(Institution_Roles__c role : listInstitutionRoles) {
                
                //check for the contact id on role
                if(role.Contact__c != null) {
                    listToUpsert.add(role);
                }
            }
            
            //check for the list size and perform the dml operation
            if(listToUpsert.size() > 0) 
                upsert listToUpsert;
                
            return new PageReference('/' + instituteRole.Institution__c);
        } catch(Exception e) {
            
            //rollback the complete transaction
            database.rollback(sp);
            
            //add exception message at the page
            ApexPages.addMessages(e);
        }
            
        return null;
    }
    
    //property to hold the Id of Institution role record to be deleted
    public Id instituteRoleId {get; set;}
    
    //this method is to delete the selected institute role and remain the same page
    //this records are garbage in the syatem
    public void deleteInstituteRole() {
        
        //Create a save point to roll back the transaction in case of exception
        SavePoint sp = Database.setSavePoint();
        
        try {
            Database.delete(instituteRoleId);
            
            //retrieve the real time data
            listUnusedInstituteRoles = [Select Id, Name, Contact__c, Assignment_Comment__c, Role__c from Institution_Roles__c
                                                 where Id IN: listUnusedInstituteRoles ];
        } catch(Exception e) {
            
            //roll back the complete transaction in case of exception
            database.rollback(sp);
            
            //add error message on page
            ApexPages.addMessages(e);
        }
    }
}