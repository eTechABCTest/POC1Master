/**
    Desription      :   This class wraps all of the Site User information in a single object (ie: EAB.com/Advisory.com).
  
    Created By      :   Victor Hanson
  
    Created Date    :   07/29/2014
  
    Revision Logs   :   v1.0 - Created
                        v1.1 - Modified By - Abhinav Sharma - 01-22-2015 - CR-20141007-7689
                        v1.2 - Modified By - Abhinav Sharma - 03-25-2015 - CR-20150305-8733
                        v1.3 - Modified By - Ajit Surana - 04-29-2015 - CR-20150415-8874
                        v1.4 - Modified By - Abhinav Sharma - 11/27/2015 - CR-20151118-9393 
**/ 
public class SiteUser {
    
    //empty constructor
    public SiteUser() { }
    
    //Site Profile associated with the Contact
    public Site_Profile__c site_Profile { get; set; }
    
    //Site Profile associated with the Contact
    public list<Site_Profile__c> site_Profiles {
        get {
            if (site_Profiles == null) site_Profiles = new list<Site_Profile__c>();
            return site_Profiles;
        }
        set;
    }
    
    public Site_User__c site_User { get; set; }
    
    //temporary access 
    public List<Temporary_Program_Access__c> TemporaryProgramAccess { get; set; }
    //subscriptions
    public List<Subscription__c> Subscriptions { get; set; }
    
    //eligible subscriptions
    public List<Eligible_Subscription_Option__c> EligibleSubscriptions { get; set; }
    
    //web program access
    public List<WebProgramAccess> webProgramAccessList { get; set; }
    
    //Added By - Abhinav Sharma - 22-01-2015 - CR-20141007-7689
    //Start from Here
    public String accountStatus {get; set;}
    public String accountRecordType {get; set;}
    public String accountFormalName {get; set;}
    //Upto Here
    
    //Added By - Abhinav Sharma - 03-25-2015 - CR-20150305-8733
    //Start From Here
    public Decimal rITDRenewalCV {get; set;}
    
    //Added By - Ajit Surana - 04-29-2015 - CR-20150415-8874
    //Start from Here
    public string strategicAccountSegment {get; set;}
    //Upto Here
    
    //Added By - Abhinav Sharma - 11/27/2015 - CR-20151118-9393
    //Start from here
    public string ProviderType {get; set;}
    public string BedSize {get; set;}
    public string RMRI {get; set;}
    public string Principal {get; set;}
    //Upto here
    
    public class WebConference {
        public WebConference() {}
        public String Name { get; set; }
        public String Url { get; set; }
        public String StartDate { get; set; }
        public String EndDate { get; set; }
        public Boolean IsCanceled { get; set; }
        public String Origin { get; set; }      // origin differentiates Cancel requests from the Admin Tool vs those that come direclty from user
        //Added By - Abhinav Sharma - 07/08/2014 - CR-20140228-4676 - Advisory.com Create new Webconference Registration email for ABI
        //Variable to hold the message type [For ex:- International or Domestic]
        public String MessageType {get; set;}
    }
    
    public class WebConferenceAttendee {
        public WebConferenceAttendee() {}
        public String User_Id { get; set; }
        public String Prefix { get; set; }
        public String FirstName { get; set; }
        public String LastName { get; set; }
        public String MiddleInitial { get; set; }
        public String Suffix { get; set; }
        public String Phone { get; set; }
        public String Fax { get; set; }
        public String Email { get; set; }
    }
    
    public class WebConferenceRegisteredBy {
        public WebConferenceRegisteredBy() {}
        public String User_Id { get; set; }
        public String Prefix { get; set; }
        public String FirstName { get; set; }
        public String LastName { get; set; }
        public String MiddleInitial { get; set; }
        public String Suffix { get; set; }
        public String Phone { get; set; }
        public String Fax { get; set; }
        public String Email { get; set; }
    }
    
    public List<Meeting_Utilization__c> MeetingUtilizations { 
        get {
            if (MeetingUtilizations == null) MeetingUtilizations = new List<Meeting_Utilization__c>();
            return MeetingUtilizations;
        }
        set;
    }
    
    public WebConference WebEvent { get; set; }
    public WebConferenceAttendee Attendee { get; set; }
    public WebConferenceRegisteredBy RegisteredBy { get; set; }
    
    
    // a advisory.com user class
    public string Site { get; set; }
    public boolean RegisterOther { get; set; }
    public boolean HasRegisteredAlready { get; set; }
    public String UniqueId { get; set; }
    public String InstitutionUniqueId { get; set; }
    public String Username { get; set; }
    public Integer User_Id { get; set; }
    public String PasswordResetUrl { get; set; }
    public String Phone { get; set; }
    public String Response { get; set; }
    public String Old_User_Id { get; set; }
    public String Password { get; set; }
    public Integer Organization_Id { get; set; }
    public String Job_Function { get; set; }
    public String Department { get; set; }
    public String EAB_Department { get; set; }
    public String EAB_Role { get; set; }
    public String First_Name { get; set; }
    public String Middle_Initial { get; set; }
    public String Last_Name { get; set; }
    public String Prefix { get; set; }
    public String Suffix { get; set; }
    public String Title { get; set; }
    public String Address1 { get; set; }
    public String Address2 { get; set; }
    public String Address3 { get; set; }
    public String City { get; set; }
    public String State { get; set; }
    public String Zip { get; set; }
    public String Country { get; set; }
    public String Office_Phone { get; set; }
    public String Office_Phone_Ext { get; set; }
    public String Fax_Phone { get; set; }
    public String Email_Address { get; set; }
    public String User_Status { get; set; }
    public String Last_Access { get; set; }
    public String Created_By { get; set; }
    public String Created_Date { get; set; }
    public String Modified_By { get; set; }
    public String Modified_Date { get; set; }
    public String Role { get; set; }
    public Boolean Temporary_User { get; set; }
    public String Email_Address2 { get; set; }
    public String Verify { get; set; }
    public String Verify_Date { get; set; }
    public Boolean ProgressTracking { get; set; }
    public Boolean RecognitionProgram { get; set; }
    public Boolean ProgressTrackingNotification { get; set; }
    public Boolean IgnoreLDD { get; set; }
    public Integer PTRecognitionProgramId { get; set; }
    public Boolean IsApproved { get; set; } // returns true/false based on whether or not a user was able to be authenticated
    public Boolean IsOnline { get; set; }
    public String Command { get; set; }
    public String Status_Code { get; set; } // status code for certain calls (ie: login could return E1, L1, L2, R1-3)
    public Boolean AuthenticateDomain { get; set; }
    public Boolean OneDayAccessGranted { get; set; }
    public Boolean Options_Change { get; set; }
    public Boolean PasscodeSent { get; set; }
    public Boolean Profile_Change { get; set; }
    public Boolean ReAuthEmailSent { get; set; }
    public String SFDateTime { get; set; }
    public String OneDayAccessGrantedDate { get; set; }
    public String DomainStillValid { get; set; }
    public String Org_Name { get; set; }
    public String Organization_Status { get; set; }
    public String Passcode { get; set; }
    public String AccountManagerFullName { get; set; }
    public String AccountManagerEmail { get; set; }
    public String AccountManagerPhoneNumber { get; set; }
    
    //special logic for returning the bypass domain validation value that is stored on the Site Profile record
    public Boolean Bypass_Domain_Validation {
        get {
            if (Site_Profile != null) {
                return Site_Profile.Bypass_Domain_Validation__c;
            }
            return false;
        }
        set;
    }
    
    public String ChimpId { get; set; }
    public String Browser_Type { get; set; }
    public String ClientId { get; set; }
    
    // CR-732
    public String OrganizationName { get; set; }
    public String ProgramId { get; set; }
    public String Comments { get; set; }
    public String LeadChannel { get; set; }
    public String RequestPage { get; set; }
    public String RequestURL { get; set; }
    public String RequestObjectType { get; set; }
    
    // Field to determine where to send webservice responses
    public String EndpointURL { get; set; }
    
    // Fields added for Microsite project cr-1714
    public String LinkedIn { get; set; }
    public String Facebook { get; set; }
    public String Twitter { get; set; }
    public String Pinterest { get; set; }
    public String NameTag { get; set; }
    public String OrganizationNameTag { get; set; }
    public String Interests { get; set; }
    
    public boolean ShareInformation { get; set; }
    public boolean ShareEmail { get; set; }
    public boolean ShareFacebook { get; set; }
    public boolean ShareFax { get; set; }
    public boolean SharePhone { get; set; }
    public boolean ShareLinkedIn { get; set; }
    public boolean SharePinterest { get; set; }
    public boolean ShareInterests { get; set; }
    public boolean ShareImage { get; set; }
    public boolean ShareTwitter { get; set; }
    
    // field added so Chatter Plus users can update Contacts (CR-2067)
    public String Nickname { get; set; }
    public String Mobile { get; set; }
    public String ContactRecordType { get; set; }
    public String SecondaryAddressName { get; set; }
    public String SecondaryAddress1 { get; set; }
    public String SecondaryAddress2 { get; set ;}
    public String SecondaryAddress3 { get; set ;}
    public String SecondaryCity { get; set ;}
    public String SecondaryState { get; set ;}
    public String SecondaryPostalCode { get; set ;}
    public String SecondaryCountry { get; set ;}
    public String Description { get; set; }
    public String AccountId { get; set; }
    public boolean EmailOptOut { get; set; }
    public String Assistant { get; set; }
    public String AssistantPhone { get; set; }
    public String AssistantEmail { get; set; }
    public String ReportsToId { get; set; }
    public String PrevAccountId { get; set; }
    
    // fields added for CR-3029
    public String MicrositeID { get; set; }
    public String PresentationID { get; set; }
    public String EventID { get; set; }
    
    public class WebProgramAccess {
        public Integer siteProgramId { get; set; }
        public String siteProgramCode { get; set; }
        public String description { get; set; }
        
        public WebProgramAccess(Temporary_Program_Access__c tempAccess) {
            if (tempAccess.Site_Program_ID__c != null)
                siteProgramId = Integer.valueOf(tempAccess.Site_Program_ID__c);
                siteProgramCode = tempAccess.Web_Program__r.Web_Program__r.Program_Code_to_Member__c;
                description = tempAccess.Web_Program__r.Web_Program__r.Description__c;
        }
        
        public WebProgramAccess(Web_Program_Access_MTM__c webProgAccess) {
            if (webProgAccess.Adv_com_Program_Id__c != null)
                siteProgramId = Integer.valueOf(webProgAccess.Adv_com_Program_Id__c);
                siteProgramCode = webProgAccess.Web_Program__r.Program_Code_to_Member__c;
                description = webProgAccess.Web_Program__r.Description__c;
        }
    }
    
    /**
     * @description:    used for admin tool Contact search functionality
     * 
     **/
    public List<SiteControllerHelper.ContactWrapper> ContactWrappers {
        get {
            if (ContactWrappers == null) {
                ContactWrappers = new List<SiteControllerHelper.ContactWrapper>();
            }
            return ContactWrappers;
        }
        set;
    }
    
    /**
     * @description:    used for admin tool Institution search functionality
     * 
     **/
    public List<Account> Institutions {
        get {
            if (Institutions == null) {
                Institutions = new List<Account>();
            }
            return Institutions;
        }
        set;
    }
    
}