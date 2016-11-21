/**
 *  Desription      :   Contain logic for CommonAuth Controller
 *
 *  Created By      :   Jeffery Sun
 *  Created Date    :   02/22/2014
 *  Revision Logs   :   V1.0 - Created
 **/
public without sharing class CommonAuthHelper {
    private final static String ErrorEmailSubject = '[CommonAuth Error]: Salesforce API';
    private final static String DefaultProjectRoleProjectType = 'Portal Only';
    private final static String DefaultProjectRoleRole = 'Portal Only';
    
    private class InstitutionChainInfo {
        public Account RootInstitution { get; set; }
        public Set<ID> AllInstitutionIds { get; set; }
        
        public InstitutionChainInfo() {
            this.AllInstitutionIds = new Set<ID>();
        }
    }
    
    public static String Decode(String input) {
        Common_Auth_Site__c setting = Common_Auth_Site__c.getInstance('CommonAuthHelper');
        String key = setting == null? '9WVAaQl734oCfJBIFrH1czDwueCOvDpOAI+wzbUTDm4=' : setting.AES256_Key__c;
        system.debug('##Key: ' + key);
        blob reqBlob = EncodingUtil.base64Decode(input);
        Blob decryptedData = Crypto.decryptWithManagedIV('AES256', EncodingUtil.base64Decode(key), reqBlob);
        return decryptedData.toString();
    }
    
    public static String Encode(String output) {
        Common_Auth_Site__c setting = Common_Auth_Site__c.getInstance('CommonAuthHelper');
        String key = setting == null? '9WVAaQl734oCfJBIFrH1czDwueCOvDpOAI+wzbUTDm4=' : setting.AES256_Key__c;
        system.debug('##Key: ' + key);
        blob blobData = blob.valueOf(output);
        blob encryptedBlob = Crypto.encryptWithManagedIV('AES256', EncodingUtil.base64Decode(key), blobData);
        return EncodingUtil.base64Encode(encryptedBlob);
    }

    public static void SendErrorEmail(String request, String errorMessage) {
        try {
            Common_Auth_Site__c setting = Common_Auth_Site__c.getInstance('CommonAuthHelper');
            String errorEmail = setting == null? '' : setting.Error_Email__c;
            String body = 'request:' + request + '\r\nError:\r\n' + errorMessage;
            system.debug('##Error Email: ' + errorEmail + ' :: ' + body);
            
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            mail.setToAddresses(new String[] {errorEmail});
            mail.setSubject(ErrorEmailSubject);
            mail.setHtmlBody(body);
            List<Messaging.SendEmailResult> results = Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
            if (!results.get(0).isSuccess()) {
                system.debug('##CommonAuthHelper - SendErrorEmail: ' + results.get(0).getErrors()[0].getStatusCode() + ' | ' + results.get(0).getErrors()[0].getMessage());
			}
        } catch(Exception ex) {
          	system.debug('##CommonAuthHelper - SendErrorEmail: ' + ex.getMessage() + ' on line number: ' + ex.getLineNumber() + '\n' + ex.getStackTraceString());
        }
    }

    public static CommonAuthSyncContactResponse SyncContact(CommonAuthSyncContactRequest caReq) {
        Contact contact;

        // Get All Institutions from project Ids
        InstitutionChainInfo orgChain = GetProjectInstitutionChain(caReq.ProjectIds);

        // Find Contact By Crimson UserName
        List<Contact> contacts = [SELECT Id, AccountId, SIAM_GUID__c, SIAM_Email__c, SIAM_Portal_Status__c, Counter_Id__c FROM Contact
                                  WHERE SIAM_Email__c = :caReq.CrimsonEmail AND Contact_Status__c = 'Active' LIMIT 1];
        system.debug('##Number of contacts found basing on CrimsonEmail: ' + contacts.size());        
        if(contacts.size() > 0) {
            contact = contacts.get(0);
            if(orgChain.AllInstitutionIds.contains(contact.AccountId)) {
                system.debug('##This is a good match basing on CrimsonEmail: ' + contact);
                UpdateContactAndProjectRoles(contact, caReq);
            } else {
                system.debug('##This is a bad match basing on CrimsonEmail: ' + contact);
                ClearContactAndProjectRoles(contact);
                contact = CreateContactAndProjectRoles(orgChain.RootInstitution, caReq);
            }
        } else {
            contacts = [SELECT Id, AccountId, LastName, Counter_ID__c, SIAM_GUID__c, SIAM_Email__c, SIAM_Portal_Status__c FROM Contact
                        WHERE (AccountId in :orgChain.AllInstitutionIds) AND (Email = :caReq.CrimsonEmail OR
                            Advisory_com_Email_Address__c = :caReq.CrimsonEmail OR Advisory_com_Email_Address2__c = :caReq.CrimsonEmail OR
                            Advisory_com_Preferred_Email_Address__c =: caReq.CrimsonEmail OR Eloqua_Email_Address__c = :caReq.CrimsonEmail) AND
                            (Contact_Status__c = 'Active')
                        ORDER BY Counter_ID__c DESC];
            Integer count = contacts.size();
            system.debug('##Number of contacts found basing on multi-emails: ' + count);
            if(count <= 0) {
                // We are going to use the CrimsonGuid to deal with email changes here.
                contacts = [SELECT Id, AccountId, LastName, Counter_ID__c, SIAM_GUID__c, SIAM_Email__c, SIAM_Portal_Status__c FROM Contact
                        	WHERE (SIAM_GUID__c = :caReq.CrimsonGuid) AND (Contact_Status__c = 'Active')
                           	ORDER BY Counter_ID__c DESC];
                count = contacts.size();
            	system.debug('##Number of contacts found basing on CrimsonGuid: ' + count);
            	if(count > 0) {
                    //system.debug('##Contact Search Result:' + contacts);
                	for(Contact c : contacts) {
                        if(contact == null && orgChain.AllInstitutionIds.contains(c.AccountId)) {
                            system.debug('##This is a good match basing on CrimsonGuid: ' + c);
                            contact = c;
                            UpdateContactAndProjectRoles(contact, caReq);
                        } else {
                            system.debug('##This is a bad match basing on CrimsonGuid: ' + c);
                            ClearContactAndProjectRoles(c);
                        }
                	}
                }
                
                // Still no good match, we will create a new contact.
                if(contact == null) {
                    contact = CreateContactAndProjectRoles(orgChain.RootInstitution, caReq);
                }
            } else if(count == 1) {
                contact = contacts.get(0);
                UpdateContactAndProjectRoles(contact, caReq);
            } else {
                //system.debug('##Contact Search Result:' + contacts);
                for(Contact c : contacts) {
                     if(c.LastName.equalsIgnoreCase(caReq.LastName)) {
                        contact = c;
                        break;
                    }
                    if(c.LastName.indexOfIgnoreCase(caReq.LastName) == 0) {
                        contact = c;
                        break;
                    }
                }
                
                if(contact == null) {
                    // Create Contact
                    contact = CreateContactAndProjectRoles(orgChain.RootInstitution, caReq);
                }
                else {
                    UpdateContactAndProjectRoles(contact, caReq);
                }
            }
        }
 
        CommonAuthSyncContactResponse response = new CommonAuthSyncContactResponse();
        response.Successful = true;
        response.ContactDetail.SFContactId = String.valueOf(contact.Id).substring(0, 15);
        response.ContactDetail.CounterId = contact.Counter_Id__c;
        response.ContactDetail.SFAccountId = String.valueOf(contact.AccountId).substring(0, 15);
        
        return response;
    }

    @future
    public static void DeactivateContactUserAccount(String contactId) {
        system.debug('##DeactivateContactUserAccount: ' + contactId);
        List<User> users = [SELECT Id FROM User WHERE IsActive = true AND ContactId = :contactId];
        if(users.size() > 0) {
            for(User user : users) {
            	user.IsActive = false;
            }
            UPDATE users;
        }        
    }
    
    public static CommonAuthDeactivateContactResponse DeactivateContact(CommonAuthDeactivateContactRequest caReq) {
        system.debug('##CommonAuthDeactivateContactResponse: ' + caReq.CrimsonEmail);
        
        // Find Contact By Crimson UserName
        List<Contact> contacts = [SELECT Id, AccountId, SIAM_GUID__c, SIAM_Email__c, SIAM_Portal_Status__c FROM Contact
                                  WHERE (SIAM_Email__c = :caReq.CrimsonEmail) AND (Contact_Status__c = 'Active') LIMIT 1];
        if(contacts.size() > 0) {
            Contact contact = contacts.get(0);
            ClearContactAndProjectRoles(contact);
        }
        
        CommonAuthDeactivateContactResponse response = new CommonAuthDeactivateContactResponse();
        response.Successful = true;
        return response;
    }
    
    public static InstitutionChainInfo GetProjectInstitutionChain(List<String> projectIds) {
        InstitutionChainInfo orgChain = new InstitutionChainInfo();
        
        Id rootInstitutionId;
        List<Project__c> projects = [SELECT Institution__c, Name FROM Project__c WHERE Id IN :projectIds];
        for(Project__c proj : projects) {
            if(!orgChain.AllInstitutionIds.contains(proj.Institution__c)) {
                orgChain.AllInstitutionIds.add(proj.Institution__c);
                //System.debug('##New Institution: ' +  proj.Name);
                rootInstitutionId = proj.Institution__c;
            }
        }
        
        boolean hasNew;
        // Get all parents
        do {
            hasNew = FALSE;
            List<Account> insts = [SELECT ParentId, Name FROM Account WHERE ID IN :orgChain.AllInstitutionIds];
            for(Account inst : insts) {
                if(inst.ParentId == null) {
                    rootInstitutionId = inst.Id;
                    //System.debug('##Root Institution: ' + inst.Id);
                } else if(!orgChain.AllInstitutionIds.contains(inst.ParentId)) {
                    orgChain.AllInstitutionIds.add(inst.ParentId);
                    hasNew = TRUE;
                    //System.debug('##New ParentId Institution: ' + inst.ParentId);
                }
            }
        } while (hasNew);
        
        // Then get all children
        do {
            hasNew = FALSE;
            List<Account> insts = [SELECT Id, Name FROM Account WHERE ParentId IN :orgChain.AllInstitutionIds];
            for(Account inst : insts) {
                if(!orgChain.AllInstitutionIds.contains(inst.Id)) {
                    orgChain.AllInstitutionIds.add(inst.Id);
                    hasNew = TRUE;
                    //System.debug('##New Id Institution: ' + inst.Name);
                }
            }
        } while (hasNew);
      
        orgChain.RootInstitution = [SELECT Id, Primary_Address_Line_1__c, Primary_Address_Line_2__c, Primary_Address_Line_3__c,
                                    Primary_City__c, Primary_State_Province__c, Primary_Postal_Code__c, Primary_Country__c
                                    FROM Account WHERE Id = :rootInstitutionId LIMIT 1];
        return orgChain;
    }
    
    public static Contact CreateContactAndProjectRoles(Account org, CommonAuthSyncContactRequest caReq) {
        System.debug('##CreateContactAndProjectRoles: ' + caReq.CrimsonEmail + ' in ' + org.Id);
        
        Contact c = new Contact(FirstName = caReq.FirstName, LastName = caReq.LastName, SIAM_GUID__c = caReq.CrimsonGuid,
            SIAM_Email__c = caReq.CrimsonEmail, SIAM_Portal_Status__c = 'Active', Email = caReq.CrimsonEmail,
            RecordTypeId = Util.RecordTypeId('Contact', 'External'),
            AccountId = org.Id, Primary_Address_Line_1__c = org.Primary_Address_Line_1__c,
            Primary_Address_Line_2__c = org.Primary_Address_Line_2__c, Primary_Address_Line_3__c = org.Primary_Address_Line_3__c,
            Primary_City__c = org.Primary_City__c, Primary_State_Province__c = org.Primary_State_Province__c,
            Primary_Postal_Code__c = org.Primary_Postal_Code__c, Primary_Country__c = org.Primary_Country__c);
        INSERT c;
        System.debug('##CreateContact: ' +  c.Id);
        
        Set<String> projectIds = new Set<String>();
        if(caReq.ProjectIds != null) projectIds.addAll(caReq.ProjectIds);
        UpsertContactProjectRole(c.Id, projectIds);
        
        Contact newContact = [SELECT Id, Counter_Id__c, AccountId FROM Contact
                              WHERE Id = :c.Id LIMIT 1];      
        return newContact;
    }
    
    public static void UpdateContactAndProjectRoles(Contact c, CommonAuthSyncContactRequest caReq) {
        Boolean isDirty = FALSE;
        
        if(c.SIAM_GUID__c != caReq.CrimsonGuid) {
            c.SIAM_GUID__c = caReq.CrimsonGuid;
            isDirty = TRUE;
        }
        if(c.SIAM_Email__c != caReq.CrimsonEmail) {
            c.SIAM_Email__c = caReq.CrimsonEmail;
            isDirty = TRUE;
        }
        if(c.SIAM_Portal_Status__c != 'Active') {
            c.SIAM_Portal_Status__c = 'Active';
            isDirty = TRUE;
        }
        
        Set<String> projectIds = new Set<String>();
        if(caReq.ProjectIds != null) projectIds.addAll(caReq.ProjectIds);
        UpsertContactProjectRole(c.Id, projectIds);
        
        if(isDirty) {
            UPDATE c;
            System.debug('##UpdateContact: ' +  c.Id);
        }
        
        UpdatePortalUserEmail(c.Id, caReq.CrimsonEmail);
    }

    public static void ClearContactAndProjectRoles(Contact c) {
        Boolean isDirty = FALSE;
        
        if(c.SIAM_GUID__c != null) {
            c.SIAM_GUID__c = null;
            isDirty = TRUE;
        }
        if(c.SIAM_Email__c != null) {
            c.SIAM_Email__c = null;
            isDirty = TRUE;
        }
        if(c.SIAM_Portal_Status__c != 'Deactivated') {
            c.SIAM_Portal_Status__c = 'Deactivated';
            isDirty = TRUE;
        }
        
        ClearContactProjectRole(c.Id);
        
        if(isDirty) {
            UPDATE c;
            System.debug('##ClearContact: ' +  c.Id);
        }
        
        DeactivateContactUserAccount(c.Id);
    }
    
    public static void UpsertContactProjectRole(String contactId, Set<String> projectIds) {
        List<Project_Role__c> tobeUpdated = new List<Project_Role__c>();
        Set<String> existingProjectIds = new Set<String>(); 
        for (Project_Role__c role : [SELECT Project__c, SIAM_Portal_Status__c FROM Project_Role__c
                                     WHERE Contact__c = :contactId]) {
            if(!existingProjectIds.contains(role.Project__c))
                existingProjectIds.add(role.Project__c);

            if(projectIds.contains(role.Project__c)) {
                if(role.SIAM_Portal_Status__c != 'Active') {
                    role.SIAM_Portal_Status__c = 'Active';
                    tobeUpdated.add(role);
                }
            } else {
                if(role.SIAM_Portal_Status__c != 'Inactive') {
                    role.SIAM_Portal_Status__c = 'Inactive';
                    tobeUpdated.add(role);
                }          
            }
        }

        List<Project_Role__c> tobeAdded = new List<Project_Role__c>();
        for(String projectId : projectIds) {
            if(!existingProjectIds.contains(projectId)) {
                Project_Role__c role = new Project_Role__c(Project__c = projectId, Contact__c = contactId,
                    SIAM_Portal_Status__c = 'Active', Project_Type__c = DefaultProjectRoleProjectType,
                    Role__c = DefaultProjectRoleRole);
                tobeAdded.add(role);
            }
        }

        if(tobeAdded.size() > 0)
            INSERT tobeAdded;
        
        if(tobeUpdated.size() > 0)
            UPDATE tobeUpdated;
    }

    public static void ClearContactProjectRole(String contactId) {
        List<Project_Role__c> tobeUpdated = new List<Project_Role__c>();
        for (Project_Role__c role : [SELECT SIAM_Portal_Status__c FROM Project_Role__c
                                     WHERE Contact__c = :contactId AND SIAM_Portal_Status__c != 'Inactive']) {
            role.SIAM_Portal_Status__c = 'Inactive';
            tobeUpdated.add(role);
        }
        
        if(tobeUpdated.size() > 0)
            UPDATE tobeUpdated;
    }
    
    public static void UpdatePortalUserEmail(Id contactId, String email) {
        List<User> tobeUpdated = new List<User>();
        for (User u : [SELECT Id, Email FROM User WHERE ContactId = :contactId AND userType = 'CSPLitePortal']) {
            u.Email = email;
            tobeUpdated.add(u);
        }
        
        if(tobeUpdated.size() > 0)
            UPDATE tobeUpdated;
    }
}