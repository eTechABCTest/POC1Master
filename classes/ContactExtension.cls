public without sharing class ContactExtension {
    
    public static final String CONTACT_QUERY = 'SELECT Advisory_com_Share_Twitter__c,Advisory_com_Send_Password_Notification__c,EAB_Department__c ,EAB_Role__c,' +
                                    'LeadSource,Advisory_com_Modified_Date__c,Legacy_Contact_ID__c,Primary_Address_Line_2__c,Suffix__c,MailingCity,Function__c,Account.Name, Account.Organization_Id__c,CreatedById,ConnectionSentId,Department_Code__c,OtherPhone,Bypass_Domain_Validation__c,' +
                                    'IsDeleted,Advisory_com_Created_Date__c,RecordTypeId,RecordType.DeveloperName,Advisory_com_Old_User_ID__c,SystemModstamp,AssistantPhone,Role_Tags__c,OtherStreet,Advisory_com_PT_Recognition_ProgramID__c,HasOptedOutOfEmail,Advisory_com_User_Status__c,' +
                                    'Primary_City__c,Primary_State_Province__c,Advisory_com_Share_Interests__c,CreatedDate,OwnerId,Advisory_com_Modified_By__c,JigsawContactId,Employee_ID__c,Legacy_Institution_Directory_Code_del__c,' +
                                    'Vendor__c,Advisory_com_Fax_Phone__c,Eloqua_Lead_Rating__c,OtherCity,Advisory_com_Twitter__c,LastCURequestDate,LastName,Secondary_State_Province__c,Previous_Institution_Record__c,LastModifiedById,' +
                                    'Main_Contact__c,Advisory_com_Share_Pinterest__c,MailingCountry,ReportsToId,User_Status__c,Advisory_com_Preferred_Email_Address__c,Advisory_com_Email_Address__c,MobilePhone,Title,Active_Directory__c,Asst_Notes_del__c,' +
                                    'Middle_Name__c,Record_Type__c,Advisory_com_Title__c,Expert__c,Advisory_com_Last_Access__c,EmailBouncedDate,MailingStreet,Department_Description__c,Advisory_com_Share_Email__c,Advisory_com_Integration_Errors__c,' +
                                    'HomePhone,Advisory_com_Share_Phone__c,Organization_Id__c,Advisory_com_RecognitionProgram__c,Advisory_com_Email_Address2__c,EmailBouncedReason,Primary_Address_Line_3__c,Advisory_com_Role__c,FirstName,Secondary_Postal_Code__c,' +
                                    'Advisory_com_Organization_Name_Tag__c,AssistantName,BI_Core_Record_Types__c,Advisory_com_LinkedIn__c,Advisory_com_Ignore_LDD__c,Primary_Country__c,Active_PSS__c,Salutation,Eloqua_Email__c,Secondary_Address_Name__c,Phone,Secondary_Address_Line_3__c,' +
                                    'ABCO_Relationship__c,Advisory_com_Facebook__c,OtherState,Advisory_com_Share_Information__c,Legacy_Institution_Directory_Code__c,Asst_Email__c,LastActivityDate,Advisory_com_Pinterest__c,Description,Advisory_com_Verify_Date__c,Advisory_com_Share_LinkedIn__c,Contact_Status__c,' +
                                    'Advisory_com_Progress_Track_Notification__c,Counter_ID__c,Fax,Universal_Email_Opt_Out__c,Management_Level__c,Employee_User_Record__c,HasOptedOutOfFax,Advisory_com_Job_Function__c,' +
                                    'LastCUUpdateDate,Email,DoNotCall,Advisory_com_Share_Fax__c,tempMergeRank__c,Secondary_City__c,Advisory_com_Created_By__c,Advisory_com_Share_Facebook__c,MailingState,Contact_Restriction_Status_2__c,Legacy_Contact_ID_del__c,tempMergeMaster__c,Address_Notes__c,' +
                                    'ConnectionReceivedId,Secondary_Country__c,Advisory_com_Name_Tag__c,Primary_Address_Line_1__c,Advisory_Board_Fellow__c,Department,Department_External_Description__c,Contact_Restriction_Status__c,Create_Advisory_com_User_Account__c,Membership_Contact_Meetings__c,LastModifiedDate,Id,' +
                                    'Asst_Notes__c,Advisory_com_Progress_Tracking__c,Primary_Postal_Code__c,Name,Birthdate,Advisory_com_Temporary_User__c,AccountId,Advisory_com_Interests__c,Membership_Contact_Pubs__c,MasterRecordId,Advisory_com_Password_Reset_Token__c,' +
                                    'OtherPostalCode,Advisory_com_Share_Image__c,MailingPostalCode,Historical_Linker__c,Secondary_Address_Line_1__c,Nickname__c,GUID__c,Advisory_com_Department__c,OtherCountry,Secondary_Address_Line_2__c,Universal_Email_Opt_Out_del__c' +
                                    ' FROM Contact';
    
    public static final String CONTACT_QUEUE_QUERY = 'SELECT Secondary_Address_Name__c,EAB_Department__c ,EAB_Role__c,Advisory_com_User_Status__c,Secondary_Address_Line_3__c,Key_Notes__c,Asst_Email__c,Primary_Address_Line_2__c,Reports_To__c,Suffix__c,CreatedById,ConnectionSentId,Asst_Phone__c,IsDeleted,SystemModstamp,Salutation__c,Email__c,Management_Level__c,Primary_City__c,' +
                                    'Primary_State_Province__c,Last_Name__c,First_Name__c,Errors__c,CreatedDate,OwnerId,Assistant__c,Secondary_City__c,LastModifiedById,ConnectionReceivedId,Advisory_com_Preferred_Email_Address__c,Secondary_Country__c,Primary_Address_Line_1__c,Secondary_State_Province__c,Previous_Inst_Record__c,' +
                                    'Create_Advisory_com_User_Account__c,Previous_Institution_Record__c,LastModifiedDate,Id,Middle_Name__c,Phone__c,Primary_Postal_Code__c,Record_Type__c,Name,Contact__c,Primary_Address_Line_3__c,Email_Opt_Out__c,Mobile__c,HasErrors__c,Secondary_Postal_Code__c,Secondary_Address_Line_1__c,' +
                                    'Nickname__c,Title__c,Secondary_Address_Line_2__c,Institution_Name__c,Primary_Country__c,Function__c' +
                                    ' FROM Contact_Queue__c';
    
    // the redirect url
    public String RedirectURL { get; set; }
    
    // the Advisory.com User Object
    public SiteUser sUser {
        get {
            if (sUser == null) sUser = new SiteUser();
            return sUser;
        }
        set;
    }
    
    // dynamically grab the picklist values for Management_Level__c from the contact picklist
    public List<SelectOption> ManagementLevelOptions {
        get {
            if (ManagementLevelOptions == null) {
                ManagementLevelOptions = new List<SelectOption>();
                
                // add a default
                ManagementLevelOptions.add(new SelectOption('', ''));
                
                // add the unique picklist entries to the picklist
                Schema.DescribeFieldResult fieldResult = Contact.Management_Level__c.getDescribe();
                List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
                for(Schema.PicklistEntry f : ple) {
                    ManagementLevelOptions.add(new SelectOption(f.getLabel(), f.getValue()));
                }
            }
            return ManagementLevelOptions;
        }
        set;
    }
    
    public List<SelectOption> ConstituencyOptions {
        get {
            if (ConstituencyOptions == null) {
                ConstituencyOptions = new List<SelectOption>();
                
                // add a default
                ConstituencyOptions.add(new SelectOption('', ''));
                
                // add the unique picklist entries to the picklist
                Schema.DescribeFieldResult fieldResult = Contact.Function__c.getDescribe();
                List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
                for(Schema.PicklistEntry f : ple) {
                    ConstituencyOptions.add(new SelectOption(f.getLabel(), f.getValue()));
                }
            }
            return ConstituencyOptions;
        }
        set;
    }
    
    // dynamically grab the picklist values for EAB_Role__c from the contact picklist
    public List<SelectOption> EABRoleOptions {
        get {
            if (EABRoleOptions == null) {
                EABRoleOptions = new List<SelectOption>();
                
                // add a default
                EABRoleOptions.add(new SelectOption('', ''));
                
                // add the unique picklist entries to the picklist
                Schema.DescribeFieldResult fieldResult = Contact.EAB_Role__c.getDescribe();
                List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
                for(Schema.PicklistEntry f : ple) {
                    EABRoleOptions.add(new SelectOption(f.getLabel(), f.getValue()));
                }
            }
            return EABRoleOptions;
        }
        set;
    }
    
    // dynamically grab the picklist values for EAB_Department__c from the contact picklist
    public List<SelectOption> EABDepartmentOptions {
        get {
            if (EABDepartmentOptions == null) {
                EABDepartmentOptions = new List<SelectOption>();
                
                // add a default
                EABDepartmentOptions.add(new SelectOption('', ''));
                
                // add the unique picklist entries to the picklist
                Schema.DescribeFieldResult fieldResult = Contact.EAB_Department__c.getDescribe();
                List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
                for(Schema.PicklistEntry f : ple) {
                    EABDepartmentOptions.add(new SelectOption(f.getLabel(), f.getValue()));
                }
            }
            return EABDepartmentOptions;
        }
        set;
    }
    
    // override the default save functionality to redirect the user to a custom contact view page
    public PageReference SaveOverride() {
        try {
            
            // populate all the fields on the Advisory.com User object
            sUser = SiteUserHelper.PopulateSiteUserFromConQueue(Con, ContactQueue, sUser);
            
            // get the user's email address
            User currentUser = [SELECT Email FROM User WHERE Id = :UserInfo.getUserId()];
            
            // set the Modified By to the current user's email address so the system doesn't think this update
            // came from the actual adv.com user
            sUser.Modified_By = currentUser.Email;
            
            // encrypt the sUser
            String encryptedRegistrationRequest = EncryptionHelper.Encrypt(sUser);
            String request_EncryptedURLEncoded = EncodingUtil.urlEncode(encryptedRegistrationRequest, 'UTF-8');
            String baseURL = SiteUserHelper.sitecoreSettings.Advisory_com_SF_URL__c;
            // example baseURL: http://advisorytest.advsfdc.cs14.force.com/Query
            String parameterString = 'req=' + request_EncryptedURLEncoded;
             
            HTTPResponse hTTPRes;
            HTTPRequest req = new HttpRequest();
            req.setTimeout(120000);
            req.setEndpoint(baseURL);
            req.setBody(parameterString);
            req.setMethod('POST');
            HTTP http = new HTTP();
            String body = '';
            hTTPRes = http.send(req);
            body = hTTPRes.getBody();
             
            SiteUser sUser = SiteUserHelper.getSiteUser(body);
            
            // based on the response, either redirect the user to the detail page of the Contact they just updated, or keep them at the edit contact page with an error message
            if (sUser.Response.toLowerCase() == 'success') {
                return new PageReference('/' + sUser.UniqueId);
            }
            else {
                // try to return a more user friendly error message
                String errorMsg = sUser.Response;
                if (errorMsg.equalsIgnoreCase(SiteUserHelper.ERROR_INVALID_DOMAIN))
                    errorMsg = 'The email address provided does not contain a valid domain for that institution.';
                else if (errorMsg.equalsIgnoreCase(SiteUserHelper.ERROR_EXISTING_INACTIVE_USER))
                    errorMsg = 'The email address provided matches the address of an inactive advisory.com user.';
                else if (errorMsg.equalsIgnoreCase(SiteUserHelper.ERROR_EXISTING_ACTIVE_USER))
                    errorMsg = 'The email address provided matches the address of an active advisory.com user.';
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, errorMsg)); 
                return null;
            }
        }
        catch (Exception ex) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ex.getMessage()));
            return null;
        }
        
    }
    
    // get the RecordTypeId of the "Contact"."External" record type -- this is the only record type chatter users have access to
    public Id RecordTypeId {
        get {
            if (RecordTypeId == null) {
                RecordTypeId = Util.recordtypemap('Contact').get('External');
            }
            return RecordTypeId;
        }
        set;
    }
    
    public Account Acct {
        get {
            if (Acct == null) {
                Acct = new Account();
                String accountId = ApexPages.currentPage().getParameters().get('AccountId');
                if (accountId != null) {
                    List<Account> accts = [SELECT Id, Primary_Address_Line_1__c, Primary_Address_Line_2__c, Primary_Address_Line_3__c,
                                        Primary_City__c, Primary_State_Province__c, Primary_Postal_Code__c, Primary_Country__c
                                        FROM Account WHERE Id = :accountId LIMIT 1];
                    if (accts.size() > 0)
                        Acct = accts[0];
                }
            }
            return Acct;
        }
        set;
    }
    
    // the main contact
    public Contact Con {
        get {
            if (Con == null) {
                Con = new Contact();
                Con.RecordTypeId = RecordTypeId;
                if (ContactId != null) {
                    string queryString = CONTACT_QUERY + ' WHERE Id = \'' + ContactId + '\'';
                    List<Contact> contacts = database.query(queryString);
                    if (contacts.size() > 0)
                        Con = contacts[0];
                }
            }
            return Con;
        }
        set;
    }
    
    // the main Contact_Queue__c record
    public Contact_Queue__c ContactQueue {
        get {
            if (ContactQueue == null) {
                ContactQueue = new Contact_Queue__c();
                
                if (Con.Id != null) { // if there is already a contact and we are simply editing
                    // copy down all the contact field values in to the Contact Queue record
                    ContactQueue = SiteUserHelper.PopulateContactQueueFromContact(Con);
                }
                else if (Acct != null && Acct.Id != null) { // otherwise, this is a new Contact record
                    // set some defaults based on the account that the contact is associated with
                    ContactQueue.Institution_Name__c = Acct.Id;
                    ContactQueue.Primary_Address_Line_1__c = Acct.Primary_Address_Line_1__c;
                    ContactQueue.Primary_Address_Line_2__c = Acct.Primary_Address_Line_2__c;
                    ContactQueue.Primary_Address_Line_3__c = Acct.Primary_Address_Line_3__c;
                    ContactQueue.Primary_City__c = Acct.Primary_City__c;
                    ContactQueue.Primary_State_Province__c = Acct.Primary_State_Province__c;
                    ContactQueue.Primary_Postal_Code__c = Acct.Primary_Postal_Code__c;
                    ContactQueue.Primary_Country__c = Acct.Primary_Country__c;
                }
            }
            return ContactQueue;
        }
        set;
    }
    
    // get the contact owner so that we can get details such as the Name and display it on the VF page
    public User ContactOwner {
        get {
            if (ContactOwner == null && Con.Id != null) {
                ContactOwner = [SELECT Name, Id FROM User WHERE Id = :Con.OwnerId];
            }
            return ContactOwner;
        }
        set;
    }
    
    public String ContactId { get; set; }
    
    public ContactExtension() { }
    
    public ContactExtension(ApexPages.StandardController stdController) {
        ContactId = ApexPages.currentPage().getParameters().get('id');
    }
    
    public PageReference Redirect() {
        Pagereference pg = null;
        // get the profile for the current user
        Profile prof = [SELECT Id, Name FROM Profile WHERE Id = :UserInfo.getProfileId() LIMIT 1];
        
        // if the user type != chatter only, redirect the user to the standard contact edit page
        if (!prof.Name.Contains('Chatter')
          && prof.name != 'Syndicated - Research Admin - Restricted 15'
          && prof.Name != 'Syndicated - General Research - Restricted 15') {
            if (ContactId != null)
                pg = new PageReference('/' + ContactId + '/e');
            else
                pg = new PageReference('/003/e?RecordType=012C0000000BkFC');
        }
        
        return pg;
    }
    
}