/**
*   Purpose:    This class is to hold the constant values
*
*   Created By:  Simplyforce Technology
*
*   Created Date:   10//2011
*
*   Current Version:    v1.0
*
*    Revision Log:       V1.1 - (Code Added)- Bhavi Sharma - 08/10/2013 - Credit Card Project
*                        V1.2 - (Code Added)- Ajit Surana - 03/13/2014 - CR-20140205-4458
*                        V1.3 - (Code Added)- Victor Hanson - 04/03/2014 - Crimson Community Project
*                        V1.4 - (Code added) - Abhinav Sharma - 06/11/2014 - CR-20140610-5763
*                        v1.5 - (Code Added) - Abhinav Sharma - 07/03/2014 - CR-20140618-5845
*                        v1.6 - (Code Added) - Abhinav Sharma - 07/04/2014 - CR-20140629-6015
*                        v1.7 - (Code Added) - Abhinav Sharma - 08/05/2014 - CR-20140610-5761
*                        v1.8 - (Code Added) - Abhinav Sharma - 08/06/2014 - CR-20140707-6093
*                        v1.9 - (Code Added) - Abhinav Sharma - 08/12/2014 - CR-20140425-5234
*                        v1.10 - (Code Added) - Abhinav Sharma - 08/13/2014 - CR-20140604-5691
*                        v1.11 - (Code Added) - Abhinav Sharma - 08/14/2014 - CR-20140723-6571
*                        v1.12 - (Code Added) - Ajit Surana - 01/21/2015 - CR-20150102-8430
*						 v1.13 - (Code Added) - Victor Hanson - 01/27/2015 - CR-20140520-5562
*                        v1.14 - (Code Deleted) - Jeffery Sun - 10/01/2015 - CR-20130328-2770 (ABC_DATALOADER_PROFILE_ID)
*						 v1.16 - (Code Added) - - Abhinav Sharma - CR-20150914-9243 - 11/27/2015
*						 v1.15 - (Code Added) - Abhinav Sharma - CR-20151118-9397 - 12/22/2015
*						 v1.16 - (Code Added) - Abhinav Sharma - CR-20150925-9267 - 02/11/2016
*						 V1.17 - (Code Added) - Mahendra Swarnkar - CR-20160114-9520 - 08/23/2016
*						 V1.18 - (Code Added) - Mahendra Swarnkar - CR-20160610-9915 - 08/27/2016
*						 V1.19 - (Code Added) - Mahendra Swarnkar - CR-20160729-10075 - 08/27/2016
*						 V1.20 - (Code Added) - Mahendra Swarnkar - CR-20160715-10014 - 9/2/2016
*						 V1.20 - Modified by - Mahendra Swarnkar - CR-20160126-9564 - 9/3/2016	- Update "RECORD_TYPE_ID_ACCOUNT_VENUE" value
**/
public without sharing class Constants {

    //ATL status value of Contract's Status field
    public final static String STATUS_ATL = 'ATL';
    public final static String PROSPECT_PENDING_FUTURE_START_DATE = 'Prospect - Pending Future Start Date';
    public final static String MEMBER_HONORARY = 'Member - Honorary';
    public final static String MEMBER_PAYER = 'Member - Payer';
    public final static String MEMBER_INTEGRATED = 'Member - Integrated';
    public final static String PENDING = 'pending';
    public final static String CONTRACT_RECEIVED = 'contract received';
    public final static String HONORARY = 'Honorary';
    public final static String MEMBER_HONORARY_GRACE = 'Member - Honorary (Grace)';
    public final static String MEMBER_PAYER_GRACE = 'Member - Payer (Grace)';
    public final static String MEMBER_INTEGRATED_GRACE = 'Member - Integrated (Grace)';
    public final static String DROPPED = 'Dropped';
    public final static String VOIDER = 'Void';
    public final static String PROSPECT_RECENT_DROP = 'Prospect - Recent Drop';
    public final static String PROSPECT_PENDING_FUTURE_START = 'Prospect - Pending Future Start';
    public final static String PROSPECT_PAST_MEMBER = 'Prospect - Past Member';
    public final static String PROSPECT_PURE = 'Prospect - Pure';
    public final static String CLOSED = 'Closed';
    public final static String PAYER = 'Payer';
    public final static String EVENT_TYPE_OPPORTUNITY_VISIT_FOR_OPPORTUNITY_GOAL = 'Opportunity Visit - For Opportunity Goal';
    public final static String EVENT_TYPE_IN_PERSON_VISIT = 'In Person Visit';
    public final static String EVENT_TYPE_ADDITIONAL_CONTACT_MEETING = 'Additional Contact Meeting';
    public final static String EVENT_TYPE_PROSPECT_MEETING_ATTENDEE_COUNT_AS_VISIT = 'Prospect Meeting Attendee - Count as Visit';
    public final static String NEGATIVE_FEEDBACK_PRODUCT = 'Product';
    public final static String NEGATIVE_FEEDBACK_PRODUCT_AND_MARKETING = 'Product & Marketing';
    public final static String NEGATIVE_FEEDBACK_MARKETING = 'Marketing';
    public final static String EMAIL_SUBJECT_DISTRIBUTION_LIST = 'QA Call with Negative Feedback';
    public final static String YES = 'Yes';
    public final static String ACTIVE = 'Active';
    public final static String MEMBER = 'Member';
    public final static String CLOSED_WON = 'Closed Won';
    public final static String CLOSED_LOST = 'Closed Lost';
    public final static String DISQUALIFIED = 'Disqualified';
    public final static String RESTRICTION_UPDATED_NOTIFICATION = 'Restriction_Updated_Notification';
    public final static String ERROR_CANNOT_ADD_CONTACT_TO_INACTIVE_INSTITUTION = 'New Contacts cannot be added to non-Active Institutions.';
    public final static String ERROR_NO_CONTACT_ERROR = 'No contact associated with account(s) or No contact have valid email address.';
    public final static String ERROR_NO_RESTRICTION_EMAIL_TEMPLATE_DEFINED = 'No email template defined for restriction notifiction';
    public final static String ERROR_CHANGE_REQUEST_EMAIL_HANDLER_NO_USER_EXITS = 'No user exist with this email Id';
    public final static String SALESFORCE_HELP = 'Salesforce Help';
    public final static String STATUS_WARM_LEAD_PENDING_RESTRICTION_CLEARANCE = 'Pending Restriction Clearance';
    public final static String RENEWAL = 'Renewal';
    public final static String EVENT_PURPOSE_INITIAL = 'Initial';
    public final static String EVENT_PURPOSE_RELATIONSHIP_VISIT = 'Relationship Visit';
    public final static String INACTIVE_UNSUBSCRIBED_BY_MEMBER = 'Inactive - Unsubscribed by Member';
    public final static String BLANK = '';
    public final static String SPACE = ' ';
    public final static String COMMA = ',';
    public final static String STAGE_OPPORTUNITY_CLOSED_LOST = 'Closed Lost';
    public final static String STAGE_OPPORTUNITY_VOID = 'Void';
    public final static String STAGE_OPPORTUNITY_DROPPED = 'Dropped';
    public final static String STATUS_AGREEMENT_CANCELLED_DECLINED = 'Cancelled / Declined';
    public final static String STATUS_AGREEMENT_OUT_FOR_SIGNATURE = 'Out for Signature';
    public final static String STATUS_AGREEMENT_SIGNED = 'Signed';
    public final static String STATUS_OSR_PENDING_APPLICATION = 'Pending Application';
    public final static String STATUS_OSR_PENDING_FINANCE = 'Pending Finance';
    public final static String PROFILE_ABC_DATA_LOADER = 'ABC Dataloader';
    public final static String STATUS_MEMBER_UTILIZATION_CANCELLED = 'Cancelled';
    public final static Set<String> STAGES_SET_OPEN_OPPROTUNITIES = new Set<String>{'Prospect',
                                                                                    'Outreach',
                                                                                    'Initial Visit Scheduled',
                                                                                    'Prewire',
                                                                                    'Active in FastTrack',
                                                                                    'Active in SlowTrack',
                                                                                    'Verbal Yes',
                                                                                    'Contract Received - Send to Finance'};

    //Record Types
    public final static String RECORD_TYPE_OPPORTUNITY_PT_CONTRACT_MAINTENANCE = 'PT Contract Maintenance';
    public final static String RECORD_TYPE_OPPORTUNITY_PT_CONTRACT_RENEWAL = 'PT Contract Renewal';
    public final static String RECORD_TYPE_OPPORTUNITY_RI_AM_FIRST_YEAR_OPP = 'RI AM First Year Opp';
    public final static String RECORD_TYPE_OPPORTUNITY_RI_AM_STANDARD_OPP = 'RI AM Standard Opp';
    public final static String RECORD_TYPE_EVENT_DEVELOPER_NAME_BI_QA_CALL = 'BI_QA_Call';
    public final static String RECORD_TYPE_SITE_ISSUE_DEVELOPER_NAME_CCC_DATA_LOAD = 'CCC_Data_Load';
    public final static String RECORD_TYPE_SITE_ISSUE_DEVELOPER_NAME_CCA_DATA_LOAD = 'CCA_Data_Load';
    public final static String RECORD_TYPE_SITE_ISSUE_DEVELOPER_NAME_CRIMSON_SUPPORT_REQUEST = 'Crimson_Support_Request';
    public final static String RECORD_TYPE_SITE_ISSUE_DEVELOPER_NAME_CMA_DATA_LOAD_MIGRATION = 'CMA_Data_Load_Production';
    public final static String RECORD_TYPE_SITE_ISSUE_DEVELOPER_NAME_COMPASS_SUPPORT_ISSUE = 'Compass_Support_Issue';
    public final static String RECORD_TYPE_SITE_ISSUE_DEVELOPER_NAME_CMA_INITIAL_DEPLOYMENT_SUPPORT = 'CMA_Data_Load';
    public final static String RECORD_TYPE_SITE_ISSUE_DEVELOPER_NAME_CPM_DATA_LOAD = 'CPM_Data_Load';
    public final static String RECORD_TYPE_SITE_ISSUE_DEVELOPER_NAME_CCI_DATA_LOAD = 'CCI_Data_Load';
    public final static String RECORD_TYPE_SITE_ISSUE_DEVELOPER_NAME_EHBI_DATA_LOAD = 'EHBI_Data_Load';
    public final static String RECORD_TYPE_DEPLOYMENT_COMPASS_CONNECT_DEPLOYMENT = 'Compass Connect Deployment';
    public final static String RECORD_TYPE_DEPLOYMENT_CMA_DEPLOYMENT = 'CMA Deployment';
    public final static String RECORD_TYPE_CALL_DEVELOPER_NAME_NPD = 'NPD';
    public final static String RECORD_TYPE_CASE_PT_SUPPORT_REQUEST = 'PT Support Request';
    public final static String RECORD_TYPE_CASE_PT_DATA_LOAD = 'PT Data Load';
    public final static String RECORD_TYPE_SITE_ISSUE_CCA_DATA_LOAD = 'CCA Data Load';
    public final static String RECORD_TYPE_SITE_ISSUE_CCA_SUPPORT_REQUEST = 'Crimson Support Request';
    public final static String RECORD_TYPE_SITE_ISSUE_DEVELOPER_NAME_CCA_SUPPORT_REQUEST = 'CCA_Support_Request';
    public final static String RECORD_TYPE_CASE_DEVELOPER_NAME_PT_SUPPORT_REQUEST = 'PT_Support_Request';
    public final static String RECORD_TYPE_CASE_DEVELOPER_NAME_PT_DATA_LOAD = 'PT_DATA_LOAD';
    //Added By Bhavi Sharma - 04/18/2014 - CR-20140414-5064
    public final static String RECORD_TYPE_ACCOUNT_DEVELOPER_NAME_INTERNATIONAL_EDUCATION = 'International_Education';
    public final static String RECORD_TYPE_ACCOUNT_DEVELOPER_NAME_US_EDUCATION = 'US_Education';
    //Added by Victor Hanson - 01/27/2015
    public final static Id RECORD_TYPE_ID_ADV_EVENT_SERIES = Schema.SObjectType.Advisory_Event__c.getRecordTypeInfosByName().get('Series').getRecordTypeId();
    public final static Id RECORD_TYPE_ID_ADV_EVENT_SESSION = Schema.SObjectType.Advisory_Event__c.getRecordTypeInfosByName().get('Session').getRecordTypeId();
    public final static Id RECORD_TYPE_ID_ADV_EVENT_EVENT = Schema.SObjectType.Advisory_Event__c.getRecordTypeInfosByName().get('Event').getRecordTypeId();
    public final static Id RECORD_TYPE_ID_ACCOUNT_VENUE = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Vendor or Venue').getRecordTypeId();


    //Added Constants on - 03/11/2014 - Abhinav Sharma - CR-20140108-4243 - CMA - MS - Version Workflow Update
    public final static String STATUS_X_DUPLICATE_CANCELLED = 'X - Duplicate/Cancelled';

    //Added Constants on - 03-14-2014 - Abhinav Sharma -  CR-20131107-3938
    public final static String STATUS_22_PRODUCTION_MIGRATION_COMPLETE = '22 - Production Migration Complete';

    //Event Record Type
    public final static String RECORD_TYPE_EVENT_DEVELOPER_NAME_PT_AM = 'BI_AM';
    public final static String RECORD_TYPE_EVENT_DEVELOPER_NAME_RI_AM = 'Core_AM';
    public final static String RECORD_TYPE_EVENT_DEVELOPER_NAME_TD_AM = 'TD_AM';
    public final static String RECORD_TYPE_EVENT_DEVELOPER_NAME_PT_MARKETING = 'BI_Marketing';
    public final static String RECORD_TYPE_EVENT_DEVELOPER_NAME_RI_MARKETING = 'Core_Marketing';

    //CR-20140214-4512
    public final static String RECORD_TYPE_TASK_DEVELOPER_NAME_TESTIMONIALS = 'Testimonials';
    public final static String TASK_SUBJECT_MEMBER_IMPACT_STORY = 'Member Impact';

    //Added constants on - 03/13/2014 - Ajit Surana - CR-20140205-4458
    public final static String EDITABLE_FIELD_AFTER_OPP_IS_CLOSED = 'Editable field after Opp is closed';
    public final static String PROFILE_EDIT_FIELDS_WHEN_OPP_IS_CLOSED = 'Profile edit fields when Opp is closed';
    public final static String STAGE_OPPORTUNITY_SENT_TO_FINANCE_OPP_REJECTED = 'Sent to Finance - Opp Rejected';

    //Added constants on - 07/18/2013 - Bhavi Sharma - Version Issue with 'CMA' contained record type
    public final static String CMA = 'CMA';

    //Added Constants on - 4/24/2013 - Bhavi Sharma
    public final static String CURRENT = 'Current';
    public final static String HISTORICAL_RELOAD = 'Historical/Reload';
    public final static String CRIMSON_SUPPORT_REQUEST_SITE_ISSUE_SUPPORT_CATEGORY_PRODUCTION_MIGRATION = 'Production Migration';

    //Added Constants on - 1/21/2015 - Ajit Surana - CR-20150102-8430
    public final static String SITE_BUILD = 'Site Build';
    public final static String PART_OF_BUILD = 'Part of Build';

    //Added Constants on - 06/12/2013 - Bhavi Sharma - CR-20120716-1142
    public final static String EMAIL_TEMPLATE_DATA_LOAD = 'DATA LOAD EMAIL TEMPLATE';
    public final static String STATUS_SITE_ISSUE_22_SENT_EMAIL_UPDATE = '22- Sent Email Update';
    public final static String STATUS_SITE_ISSUE_10_CLOSED_MEMBER_NOTIFIED = '10 - Closed, Member Notified';
    public final static String ORG_WIDE_EMAIL_DISPLAY_NAME_CRIMSON_SUPPORT = 'CrimsonSupport';
    public final static String PROJECT_NAME_CCC = 'CCC';

    //Added Constants on - 06/13/2013 - Bhavi Sharma - CR-20130228-2612
    public final static String RECORD_TYPE_MEMBER_INTERACTION_QA_CALL = 'QA Call';
    public final static String RECORD_TYPE_CONTACT_NAME_EMPLOYEE = 'Employee';

    //Added Constants on - 06/13/2013 - Bhavi Sharma - CR-20121130-1808
    public final static String RECORD_TYPE_NAME_WARM_LEAD_STANDARD = 'Standard';

    //Added Constants on - 12/20/2013 - Bhavi Sharma - CR-20130925-3694
    public final static String MEMBER_INTERACTION_CURRENT_STATUS_COMPLETED = '7 - Completed';

    //Added Constants on - 07/03/2014 - Abhinav Sharma - CR-20140618-5845
    public final static String RIAM_LARGE_CONTRACTS = 'RIAMLargeContract';

    //Added Constants on - 07/04/2014 - Abhinav Sharma -  CR-20140629-6015
    public final static String CASE_RECORD_TYPE_IRC_REQUEST = 'IRC_Request';
    public final static String IRC_REQUEST_RESPONSE = 'IRC Request Response';
    public final static String CASE_NUMBER = 'Case Number';
    public final static String COLON = ':';
    public final static String ACCT_MGR = 'AcctMgr';
    public final static String MEMBER_READY_RESPONSE = 'Member Ready Response';
    public final static String IRCREQUEST = 'IRCRequest';

    //Added Constants on - 08/05/2014 - Abhinav Sharma - CR-20140610-5761
    //Start From Here
    public static Map<string, integer> MAP_WARM_LEAD_EVENTS {
        get {
            //Map to hold the warm lead event values proceedings
            map<string, integer> mapLeadEvents = new map<string, integer>();
            mapLeadEvents.put('Direct to Visit', 1);
            mapLeadEvents.put('Prospect Meeting', 2);
            mapLeadEvents.put('Breakout', 3);
            mapLeadEvents.put('HSPI Summit', 4);
            mapLeadEvents.put('Strategy Retreat', 5);
            mapLeadEvents.put('Webinar', 6);
            mapLeadEvents.put('Tradeshow', 7);
            mapLeadEvents.put('Speaking Engagement', 8);
            mapLeadEvents.put('CG - Archived Webinar', 9);
            mapLeadEvents.put('CG - Research', 10);
            mapLeadEvents.put('CG - Case Study', 11);
            mapLeadEvents.put('CG - Tool', 12);
            mapLeadEvents.put('CG - Whitepaper', 13);
            mapLeadEvents.put('CG - Benchmarks', 14);
            mapLeadEvents.put('CG - Video', 15);
            mapLeadEvents.put('CG - Infographic', 16);
            mapLeadEvents.put('Request Access', 17);
            mapLeadEvents.put('Other', 18);
            return mapLeadEvents;
        }
    }
    //Upto Here

    //Added Constants on - 08/06/2014 - Abhinav Sharma -  - CR-20140707-6093
    //Start From Here
    public static Set<String> SET_OOO_AND_AUTOMATIC_REPLY {
        get {
            Set<String> setoutOfOfficesStrings = new Set<String>();
            setoutOfOfficesStrings.add('out of offices');
            setoutOfOfficesStrings.add('out of office');
            setoutOfOfficesStrings.add('out of the office');
            setoutOfOfficesStrings.add('ooo');
            setoutOfOfficesStrings.add('automatic reply');
            return setoutOfOfficesStrings;
        }
    }
    public final static string CASE_RECORD_TYPE_MEMBER_EMPLOYEE_SUPPORT = 'Member_Employee_Support';
    public final static string CASE_OBJECT = 'Case';
    public final static string QUEUE_EVENTS_MEMBER_SUPPORT = 'Events & Member Support';
    public final static string EMAIL = 'Email';
    //Upto Here

    //Added By - Abhinav Sharma - 08/12/2014 - CR-20140425-5234
    //Start From Here
    public final static string LI_Tag = 'ii';
    public final static string LESS_THAN = '<';
    public final static string GREATER_THAN = '>';
    public final static string IMAGE_TAG = 'image';
    public final static string ATTACHMENT_LINK_PREFIX = '/servlet/servlet.FileDownload?file=';
    //Upto Here

    //Added By - Abhinav Sharma - 08/13/2014 - CR-20140604-5691
    //Start FROM Here
    public static Set<String> SET_INSTITUTION_INACTIVE_TYPE_STATUS {
        get {
            Set<String> setOfStatuses = new Set<String>();
            setOfStatuses.add('Inactive - Closed');
            setOfStatuses.add('Inactive - Duplicate');
            setOfStatuses.add('Inactive - Other');
            return setOfStatuses;
        }
    }
    //Upto here

    //Added By - Abhinav Sharma - 08/14/2014 - CR-20140723-6571
    //Start FROM Here
    public static Set<String> SET_REGISTRATION_CANCELLED_STATUS {
        get {
            Set<String> setCancelledStatuses = new Set<String>();
            setCancelledStatuses.add('Cancelled');
            setCancelledStatuses.add('VOID');
            return setCancelledStatuses;
        }
    }
    public final static string ERROR_ALREADY_REGISTERED = 'ERROR_ALREADY_REGISTERED';
    //Upto here

    //Get IS CRM queue id
    public static Id QUEUE_ID_IS_CRM {
        get {

            //get the IS CRM queue Id
            List<Group> isCRM = [Select Id from Group where Name = 'IS CRM'];

            //Check if IS CRM queue is there
            if(isCRM.size() > 0)
                return isCRM[0].Id;

            return null;
        }
    }

    // get the Salesforce Administrator User's ID
    //Refactored By Doug Roberts - 08/31/2015 - Removed constant definition and updated code to point to custom label
 	//public static Id SF_ADMIN_USER_ID {
 	//	get {
 	//			if (SF_ADMIN_USER_ID == null) {
 	//				SF_ADMIN_USER_ID = [SELECT Id FROM User WHERE Name = 'Salesforce Administrator' LIMIT 1].Id;
 	//			}
 	//			return SF_ADMIN_USER_ID;
  	//		}
 	//	set;
 	//	}

    public final static String CONTACT_STATUS_ACTIVE = 'Active';
    public final static String CONTACT_STATUS_INACTIVE = 'Inactive';
    public final static String CONTACT_RECORD_TYPE_DEVELOPER_NAME_EMPLOYEE = 'Employee';

    //
    public final static String PROJECT_PUNCTUALITY_OF_LOADS_TYPICALLY_LATE = 'Typically Late';
    public final static String PROJECT_PUNCTUALITY_OF_LOADS_ALWAYS_ON_TIME = 'Always on Time';
    public final static String PROJECT_PUNCTUALITY_OF_LOADS_TBD = 'TBD';

    //Added By Bhavi
    public static Set<String> SET_UNITED_STATES = new Set<String>{'us', 'usa', 'united state', 'united states'};

    //Added by Ajit Surana - 03/13/2014 - CR-20140205-4458
    /**
     *  @description  :  This varibale is to create a static Map of custom Setting, so it is not being queried all the timeting) and return set
     *                   Key = Parameter Key, Value = List<Parameter Values>
     *
     *  @args         :
     *
     *  @return       :  Map<String, List<Configuration_Manager__c>>
     *
     **/
    public static Map<String, Set<String>> MAP_CONFIGURATION_MANAGER {

        get {
            if(MAP_CONFIGURATION_MANAGER == null) {

                MAP_CONFIGURATION_MANAGER = new Map<String, Set<String>>();

                //Get all values from custom setting
                List<Configuration_Manager__c> configs = Configuration_Manager__c.getAll().values();

                //Loop through all the custom setting records
                for(Configuration_Manager__c config : configs) {

                    //Check if Parameter Key is not null
                    if(String.IsBlank(config.Parameter_Key__c))
                        continue;

                    //Check if map already has Parameter Key
                    if(MAP_CONFIGURATION_MANAGER.containsKey(config.Parameter_Key__c))
                        MAP_CONFIGURATION_MANAGER.get(config.Parameter_Key__c).add(config.Parameter_Value__c.toLowerCase());
                    else
                        MAP_CONFIGURATION_MANAGER.put(config.Parameter_Key__c, new Set<String>{config.Parameter_Value__c.toLowerCase()});
                }
            }
            return MAP_CONFIGURATION_MANAGER;
        }
    }

    //JRB 2013-12-17 Constant added for CR-20130610-3134
    public static final Set<String> SORT_IGNORE_WORDS = new Set<String>{'A','AN','THE'};

    //Bhavi Sharma - 04/18/2014 - CR-20140224-4597
    public static final String WL_LEAD_EVENT_SCHEMA_ID = 'WL_Lead_Event_Schema_Id';


    //Constants added for CR-4283
    public static final string ERROR_MODS_NOT_AVAILABLE_TO_TIER_I = 'Mirrored fields cannot be modified on the Case record.  ' +
                                                              'Please have the Tier II group update the record.';
    public static final string ERROR_MODS_NOT_AVAILABLE_TO_TIER_II_OR_III = 'Mirrored fields cannot be modified on the Member Support record.  ' +
                                                              'Please have the Tier I group update the record.';
    public static final string SITE_ISSUE_TIER_I = 'Tier I';
    public static final string SITE_ISSUE_TIER_II = 'Tier II';
    public static final string SITE_ISSUE_TIER_III = 'Tier III';
    public static final string SITE_ISSUE_STATUS_MEMBER_INPUT_REQUESTED = '03.1 - Member Input Required';
    public static final string COMMUNITY_CASE_VIEW_MY_CASES = 'My Cases';
    public static final string COMMUNITY_CASE_VIEW_ALL_PROJECT_CASES = 'All Project Cases';
    public static final string CASE_STATUS_01_NEW = '01-New';
    public static final string CASE_STATUS_10_IN_PROGRESS = '10-In Progress';
    public static final string CASE_STATUS_90_CLOSED = '90-Closed';
    public static final string ERROR_CANNOT_TRANFER_TIER_II = 'Case must be Tier I in order to transfer to Tier II.';
    public static final string SIAM_PORTAL_STATUS_ACTIVE = 'Active';
    public static final string SIAM_PORTAL_STATUS_INACTIVE = 'Inactive';

    public static Id RECORD_TYPE_ID_CASE_PT_SUPPORT {
        get {
            if (RECORD_TYPE_ID_CASE_PT_SUPPORT == null) {
                RECORD_TYPE_ID_CASE_PT_SUPPORT = Util.RecordTypeId('Case', RECORD_TYPE_CASE_PT_SUPPORT_REQUEST);
            }
            return RECORD_TYPE_ID_CASE_PT_SUPPORT;
        }
        set;
    }

    public static Id RECORD_TYPE_ID_CASE_PT_DATA_LOAD {
        get {
            if (RECORD_TYPE_ID_CASE_PT_DATA_LOAD == null) {
                RECORD_TYPE_ID_CASE_PT_DATA_LOAD = Util.RecordTypeId('Case', RECORD_TYPE_CASE_PT_DATA_LOAD);
            }
            return RECORD_TYPE_ID_CASE_PT_DATA_LOAD;
        }
        set;
    }

    public static Id RECORD_TYPE_ID_SITE_ISSUE_CCA_SUPPORT_REQUEST {
        get {
            if (RECORD_TYPE_ID_SITE_ISSUE_CCA_SUPPORT_REQUEST == null) {
                RECORD_TYPE_ID_SITE_ISSUE_CCA_SUPPORT_REQUEST = Util.RecordTypeId('Site_Issue__c', RECORD_TYPE_SITE_ISSUE_CCA_SUPPORT_REQUEST);
            }
            return RECORD_TYPE_ID_SITE_ISSUE_CCA_SUPPORT_REQUEST;
        }
        set;
    }

    public static Id RECORD_TYPE_ID_SITE_ISSUE_CCA_DATA_LOAD {
        get {
            if (RECORD_TYPE_ID_SITE_ISSUE_CCA_DATA_LOAD == null) {
                RECORD_TYPE_ID_SITE_ISSUE_CCA_DATA_LOAD = Util.RecordTypeId('Site_Issue__c', RECORD_TYPE_SITE_ISSUE_CCA_DATA_LOAD);
            }
            return RECORD_TYPE_ID_SITE_ISSUE_CCA_DATA_LOAD;
        }
        set;
    }
    public static list<Sync_Field__c> SYNC_FIELDS_LIST {
        get {
            if (SYNC_FIELDS_LIST == null) SYNC_FIELDS_LIST = Sync_Field__c.getall().values();
            return SYNC_FIELDS_LIST;
        }
        set;
    }


    //Tier2Unassigned queue.  Queue is assigned when changing from Tier 1 to Tier 2
    public static Group tier2SupportQueue {
        get {
            if (tier2SupportQueue == null) {
                list<Group> queues = [SELECT Id FROM Group WHERE DeveloperName = 'Tier_II_Support' AND Type = 'Queue'];
                if (queues.size() > 0) tier2SupportQueue = queues[0];
            }
            return tier2SupportQueue;
        }
        set;
    }

    //Tier1Support queue
    public static Group tier1SupportQueue {
        get {
            if (tier1SupportQueue == null) {
                list<Group> queues = [SELECT Id FROM Group WHERE DeveloperName = 'Tier_I_Support' AND Type = 'Queue'];
                if (queues.size() > 0) tier1SupportQueue = queues[0];
            }
            return tier1SupportQueue;
        }
        set;
    }

    //Tier1Unassigned queue.  Queue is assigned when creating a case from the portal
    public static Group tier1UnassignedQueue {
        get {
            if (tier1UnassignedQueue == null) {
                list<Group> queues = [SELECT Id FROM Group WHERE DeveloperName = 'Tier_I_Unassigned' AND Type = 'Queue'];
                if (queues.size() > 0) tier1UnassignedQueue = queues[0];
            }
            return tier1UnassignedQueue;
        }
        set;
    }
    //JRB*/
    
    //Added By - Abhinav Sharma - CR-20150914-9243 - 11/27/2015
    //Starts from here
    public static final string CASE_RECORD_TYPE_EAB_CUSTOM = 'EAB_Custom';
    public static final string REFERENCE_STR = 'referenceString';
    public static final string TYPE_PARAMETER = 'type';
    //Upto Here
    
    //Added By - Abhinav Sharma - CR-20151118-9397 - 12/22/2015
    //Starts from here
    public static final string CASE_ORIGIN_MEETINGS = 'Meetings';
    public static final string CASE_ORIGIN_WEBCONFERENCES = 'Webconferences';
    public static final string CASE_ORIGIN_CONFERENCE_ROOM_REQUESTS = 'ConferenceRoomRequests';
    public static final string CASE_ORIGIN_TRAVEL = 'Travel';
    public static final string CASE_ORIGIN_VOICE_MAIL = 'Voice Mail';
    public static final string CASE_ORIGIN_ADVISORY = 'Advisory';
    public static final string CASE_ORIGIN_EAB = 'EAB';
    public static final string CASE_ORIGIN_ABI = 'ABI';
    public static final string CASE_ORIGIN_DATA_INTEGRATIONS = 'Data Integrations';
    public static final String CASE_ORIGIN_EMAIL_TO_CASE_DATA_INTEGRATIONS = 'Email to Case: Data Integration';
    public static final string CASE_ORIGIN_EAB_MEETINGS = 'EAB Meetings';
    public static final String CASE_RECORD_TYPE_WEBHELP = 'WebHelp';
    public static final String QUEUE_NAME_EVENTS_MEMBER_SUPPORT = 'Events_Member_Support';
    public static final String QUEUE_NAME_WEBHELP = 'WebHelp';
    public static final String QUEUE_NAME_DATA_INTEGRATIONS = 'Data_Integrations';
    public static final String CASE_RECORD_TYPE_ETECH_SUPPORT = 'eTech_Support';
    public static final String MAILER_DAEMON_ADVISORY_COM = 'mailer-daemon@advisory.com';
    public static final String SPAM_FILTER_ADVISORY_COM = 'spamfilter@advisory.com';
    //Upto Here
    
    //Added By - Abhinav Sharma - CR-20150925-9267 - 02/11/2016
    //Start from here
    public static final String CONTRACT_TYPE_NBB = 'NBB';
    //Upto here
    
    //V1.17 - Added by - Mahendra Swarnkar - CR-20160114-9520 - 08/23/2016
    
    //Business Hours Constant
    public static String START_BUSINESS_HOURS = '8:30 AM';
    public static String END_BUSINESS_HOURS = '5:30 PM';
    
    //V1.17 - Added by - Mahendra Swarnkar - CR-20160114-9520 - 08/23/2016 - Upto here
    
    //V1.18 - Added by - Mahendra Swarnkar - CR-20160114-9520 - 08/27/2016  
    public static final String MEMBER_INTERACTION_RT_SOUTHWIND = 'Southwind EL Request';
    public static final String OBJECT_MEMBER_INTERACTION = 'Call__c';
    
    //V1.18 - Added by - Mahendra Swarnkar - CR-20160114-9520 - 08/27/2016 - Upto here
    
    //V1.19 - Added by - Mahendra Swarnkar - CR-20160729-10075 - 08/27/2016 - Starts From Here
    //Case record type "Expert center" developer Name
    public final static String CASE_RECORD_TYPE_EXPERT_CENTER = 'Expert_Center';
    
    //Property to get/return the list of records from Internal_Applicable_Email_Suffix custom meta data type
    public static List<Internal_Applicable_Email_Suffix__mdt> LIST_OF_INTERNAL_APPLICABLE_EMAIL_SUFFIXES {

        get {
        	
        	//If true then user is in Production else SandBox.
			Boolean isProductionInstance = Util.IS_PRODUCTION_INSTANCE;
			
            //Checking for the null value
            if(LIST_OF_INTERNAL_APPLICABLE_EMAIL_SUFFIXES == null) {
                
                //Memory allocation
                LIST_OF_INTERNAL_APPLICABLE_EMAIL_SUFFIXES = new List<Internal_Applicable_Email_Suffix__mdt>();
                
                //For production instance
                if(isProductionInstance) {
                    
                    //Retrieving details from the database
                    LIST_OF_INTERNAL_APPLICABLE_EMAIL_SUFFIXES = [SELECT ID, DeveloperName, 
                                                                  Eligible_Email_Domain__c, Applicable_Record_Types__c, 
                                                                  Object_API_Name__c, Production__c
                                                              	  FROM Internal_Applicable_Email_Suffix__mdt 
                                                                  WHERE Production__c = true];
                } else {
                    
                    //Retrieving details from the database
                    LIST_OF_INTERNAL_APPLICABLE_EMAIL_SUFFIXES = [SELECT ID, DeveloperName, 
                                                                  Eligible_Email_Domain__c, Applicable_Record_Types__c, 
                                                                  Object_API_Name__c, Production__c
                                                              	  FROM Internal_Applicable_Email_Suffix__mdt];
                }
            }
            
            //returning list of records
            return LIST_OF_INTERNAL_APPLICABLE_EMAIL_SUFFIXES;
        }
 	}
    //V1.19 - Added by - Mahendra Swarnkar - CR-20160729-10075 - 08/27/2016 - Ends Here 
    
    //Mahendra Swarnkar - CR-20160715-10014 - 9/2/2016
    public final static String CASE_TYPE_VOICE_MAIL = 'Voice Mail';
    
}