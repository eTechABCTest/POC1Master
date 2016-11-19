/**
 *  Description     :  This class to hold all the constants properties for CPQ project
 *
 *  Created By      :  Subhash Garhwal
 *
 *  Created Date    :  06/09/2016
 *
 *  Revision Logs   :   V_1.0 - Created - Subhash Garhwal - CR-20160414-9762
 *                      V_1.1 - Modified - Subhash Garhwal - CR-20160830-10158 - Q2C Hypercare
 *                      V_1.2 - Modified - 10/12/2016 - Subhash Garhwal -  - Q2C Hypercare of Hypercare
 *
 **/
public class CPQConstants {
    
    //Variables
    public final static String CPQ_NEWOPPORTUNITY = 'CPQ_NewOpportunity';
    public final static String CPQ_OPPORTUNITYONDECK = 'CPQ_OpportunityOnDeck';
    public final static String CPQ_OPPORTUNITYPIPELINE = 'CPQ_OpportunityPipeline';
    public final static String CPQ_OPPORTUNITYCLOSEDWON = 'CPQ_OpportunityClosedWon';
    public final static String CPQ_OPPORTUNITYCLOSEDLOST = 'CPQ_OpportunityClosedLost';
    public final static String OPPORTUNITY_CONTRACT_LOA_NEW_AND_EDIT_PAGE_OPPORTUNITYCONTRACTLOAEDIT = 'OpportunityContractLOAEdit';
    public final static String PROGRAM_OPPORTUNITY_DUPLICATE_ERROR_MESG = 'Duplicate:  A Program Opportunity already exists for the selected Program.';
    public final static String CONTRACT_INT_ACC_RT_DN_STANDARD_CONTRACT = 'Standard_Contract';
    
    //Opportunity Stage
    public final static String OPPORTUNITY_STAGE_ON_DECK = 'On Deck';
    public final static String OPPORTUNITY_STAGE_ON_PIPELINE = 'Pipeline';
    public final static String OPPORTUNITY_STAGE_CLOSED_WON = 'Closed Won';
    public final static String OPPORTUNITY_STAGE_CLOSED_LOST = 'Closed Lost';
    public final static String OPPORTUNITY_STAGE_PROSPECT = 'Prospect';
    public final static String OPPORTUNITY_STAGE_ACTIVE_IN_SLOWTRACK = 'Active in SlowTrack';
    public final static String OPPORTUNITY_STAGE_ALTERNATE_PROPOSAL = 'Alternate Proposal';
    public final static String OPPORTUNITY_STAGE_CONTRACT_REC_SEND_TO_FINANCE = 'Contract Received - Send to Finance';
    public final static String OPPORTUNITY_STAGE_SEND_TO_FINANCE_OPP_REJECTED = 'Sent To Finance - Opp Rejected';
    public final static String OPPORTUNITY_STAGE_PENDING_RENEWAL_CALL_NOT_YET_OCCURED = 'Pending- Renewal Call Not Yet Occured';
    public final static String OPPORTUNITY_STAGE_PENDING = 'Pending';
    
    //Opportunity Type
    public final static String OPPORTUNITY_TYPE_CONTRACT_RENEWAL_OPPORTUNITY = 'Contract Renewal Opportunity';
    
    
    //Opportunity Source Stage
    public final static String OPPORTUNITY_SOURCE_STAGE_ON_DECK = 'On Deck';
    public final static String OPPORTUNITY_SOURCE_STAGE_PIPELINE = 'Pipeline';
    public final static String OPPORTUNITY_SOURCE_STAGE_RENEWAL = 'Renewal';
    
    //Opportunity Program Proposal Status 
    public final static String PROGRAM_PROPOSAL_STATUS_PRIMARY_PROPOSAL = 'Primary Proposal';
    public final static String PROGRAM_PROPOSAL_STATUS_INACTIVE = 'Inactive';
    
    //Opportunity Record Type Developer Name
    public final static String OPPORTUNITY_RECORD_TYPE_DEVELOPERNAME_CONTRACT_LOA = 'Contract_LOA';
    public final static String OPPORTUNITY_RECORD_TYPE_DEVELOPERNAME_PROGRAM_PT_MARKETING = 'Program_PT_Marketing';
    public final static String OPPORTUNITY_RECORD_TYPE_NAME_PROGRAM_PT_MARKETING = 'Program – PT Marketing';
    public final static String OPPORTUNITY_RECORD_TYPE_DEVELOPERNAME_PROGRAM_RI_MARKETING = 'Program_RI_Marketing';
    public final static String OPPORTUNITY_RECORD_TYPE_NAME_PROGRAM_RI_MARKETING = 'Program – RI Marketing';
    public final static String OPPORTUNITY_RECORD_TYPE_DEVELOPERNAME_PROGRAM_CONSULTING_MANAGEMENT = 'Program_Consulting_Management';
    public final static String OPPORTUNITY_RECORD_TYPE_DEVELOPERNAME_PROGRAM_PT_MAINTENANCE = 'Program_PT_Maintenance';
    public final static String OPPORTUNITY_RECORD_TYPE_NAME_PROGRAM_PT_CONTRACT_MAINTENANCE = 'Program – PT Contract Maintenance';
    public final static String OPPORTUNITY_RECORD_TYPE_DEVELOPERNAME_PROGRAM_PT_RENEWAL = 'Program_PT_Renewal';
    public final static String OPPORTUNITY_RECORD_TYPE_NAME_PROGRAM_PT_CONTRACT_RENEWAL = 'Program – PT Contract Renewal';
    public final static String OPPORTUNITY_RECORD_TYPE_DEVELOPERNAME_PROGRAM_RI_MAINTENANCE = 'Program_RI_Maintenance';
    public final static String OPPORTUNITY_RECORD_TYPE_NAME_PROGRAM_RI_AM_FIRST_YEAR_OPP = 'Program – RI AM First Year Opp';
    public final static String OPPORTUNITY_RECORD_TYPE_DEVELOPERNAME_PROGRAM_RI_RENEWAL = 'Program_RI_Renewal';
    public final static String OPPORTUNITY_RECORD_TYPE_NAME_PROGRAM_RI_AM_STANDARD_OPP = 'Program – RI AM Standard Opp';
    
    
    //Variables to control the flow of sections on the OpportunityContractLOAEdit and OpportunityContractLOAView pages
    public final static String OPPORTUNITY_INFO_SECTION_STAGE_ONE_NEW = 'V1_INFO_New';
    public final static String OPPORTUNITY_INFO_SECTION_STAGE_TWO_OPEN = 'V2_INFO_Open';
    public final static String OPPORTUNITY_INFO_SECTION_STAGE_THREE_CLOSED = 'V3_INFO_Closed';
    public final static String OPPORTUNITY_RESULT_SECTION_STAGE_TWO_OPEN = 'V2_Result_Open';
    public final static String OPPORTUNITY_MF_SECTION_STAGE_TWO_OPEN = 'V2_MF_Open';
    public final static String OPPORTUNITY_MF_SECTION_STAGE_THREE_CLOSED = 'V3_MF_Closed';
    public final static String OPPORTUNITY_PIPELINE_SECTION_STAGE_TWO_OPEN = 'V2_Pipeline_Open';
    public final static String OPPORTUNITY_PIPELINE_SECTION_STAGE_THREE_CLOSED = 'V3_Pipeline_Closed';
    public final static String OPPORTUNITY_SB_SECTION_STAGE_ONE_TWO_NEW = 'V1_2_SB_New';
    public final static String OPPORTUNITY_SB_SECTION_STAGE_TWO_THREE_OPEN_OR_CLOSED = 'V2_3_SB_Open_Closed';
    public final static String OPPORTUNITY_OS_SECTION_STAGE_TWO_OPEN = 'V2_OS_Open';
    public final static String OPPORTUNITY_SI_SECTION_STAGE_TWO_THREE_OPEN = 'V2_3_SI_Open';
    public final static String OPPORTUNITY_RL_SECTION_STAGE_TWO_THREE = 'RL2_3_Open_Close';
    
    //Variables to control the flow of scetions for Program Opportunities
    public final static String PROGRAM_OPP_INFO_SECTION_OPEN_STAGE = 'V1_INFO_OPEN_STAGE';
    public final static String PROGRAM_OPP_INFO_SECTION_OPEN_ON_DECK_STAGE = 'V1_INFO_Open_ON_DECK';
    public final static String PROGRAM_OPP_INFO_SECTION_OPEN_ADVANCE_STAGE = 'V1_INFO_ADVANCE_STAGE';
    public final static String PROGRAM_OPP_INFO_SECTION_CLOSED_STAGE = 'V1_INFO_Closed';
    public final static String PROGRAM_OPP_PIPELINE_SECTION_NEW = 'V2_PIPELINE_NEW';
    public final static String PROGRAM_OPP_OPEN_ADVANCE = 'V2_OPEN_ADVANCE';
    public final static String PROGRAM_OPP_CLOSED_ADVANCE = 'V2_CLOSED_ADVANCE';
    public final static String PROGRAM_OPP_MSND_ADVANCE = 'V2_MSND_ADVANCE_STAGE';
    
    public final static string APEX_URL_INITIAL_PREFIX = '/apex/';
    public final static string BACK_SLASH_VAR = '/';
    public final static string NO_OVERRIDE = 'nooverride';
    public final static string ID_PARAM = 'id';
    public final static string RETURL = 'retURL';
    public final static string CONFIRMATIONTOKEN = '_CONFIRMATIONTOKEN';
    public final static string RECORD_EDIT = '/e';
    
    //Quote Line variables
    public final static string QUOTE_LINE_IS_PROGRAM_RI = 'RI';
    public final static string QUOTE_LINE_IS_PROGRAM_PT = 'PT';
    public final static string QUOTE_LINE_IS_PROGRAM_CONSULTING = 'Consulting';
    
    //Program Business Line
    public final static string PROGRAM_BUSINESS_LINE_RI = 'RI';
    public final static string PROGRAM_BUSINESS_LINE_PT = 'PT';
    public final static string PROGRAM_BUSINESS_LINE_CLN = 'CLN';
    
    //Quote Line/Product Identifiers
    public final static String QUOTE_LINE_PROGRAM_IDENTIFIER_CONSULTING = 'Consulting';
    
    //Quote Line SubscriptionCategory values
    public final static String QUOTE_LINE_PROGRAM_SUBSCRIPTIONCATEGORY_ANNUAL_FEE = 'Annual Fee';
    public final static String QUOTE_LINE_PROGRAM_SUBSCRIPTIONCATEGORY_TRAVEL_FEE = 'Travel Fee';
    public final static String QUOTE_LINE_PROGRAM_SUBSCRIPTIONCATEGORY_INITIATION = 'Initiation';
    
    //Set to hold the SubscriptionCategory
    public final static Set<String> QUOTE_LINE_PROGRAM_SUBSCRIPTIONCATEGORY = new Set<String>{'Annual Fee', 'Travel Fee', 'Initiation'};
    
    //Set to hold the QuoteLine Program_or_Component__c values
    public final static Set<String> SET_QUOTE_LINE_PROGRAM_IDENTIFIERS = new Set<String>{'RI','PT', 'Consulting'};
    
    //Set to hold Opportunity Stage values for Opportunity Pipeline Section on OpportunityContractLOAEdit, OpportunityContractLOAView VF pages
    public final static Set<String> SET_OPPORTUNITY_STAGE_CONTRACT_LOA_VALUES = new Set<String>{'On Deck','Pipeline', 'Contract Received - Send to Finance', 'Sent To Finance - Opp Rejected'};
    
    //Set to hold the Opportunity Record Type DeveloperName's (CPQ related)
    public final static Set<String> SET_OPPORTUNITY_CPQ_RT_DEVELOPER_NAME = new Set<String>{'Contract_LOA', 'Program_Consulting_Management',
                                                                                            'Program_PT_Marketing', 'Program_RI_Marketing',
                                                                                            'Program_PT_Maintenance', 'Program_PT_Renewal',
                                                                                            'Program_RI_Maintenance', 'Program_RI_Renewal'};
    
    //Set to hold all the Program Opportunity Record Type DeveloperName
    public final static Set<String> SET_OPPORTUNITY_CPQ_PROGRAM_OPP_RT_DEVELOPER_NAME = new Set<String>{'Program_Consulting_Management',
                                                                                            'Program_PT_Marketing', 'Program_RI_Marketing',
                                                                                            'Program_PT_Maintenance', 'Program_PT_Renewal',
                                                                                            'Program_RI_Maintenance', 'Program_RI_Renewal'};
                                                                                            
    //Set to hold all the Program Opportunity Record Type Name
    public final static Set<String> SET_OPPORTUNITY_CPQ_PROGRAM_OPP_RT_NAME = new Set<String>{'Program – Consulting & Management',
                                                                                            'Program – PT Marketing', 'Program – RI Marketing',
                                                                                            'Program – PT Contract Maintenance', 'Program – PT Contract Renewal',
                                                                                            'Program – RI AM First Year Opp', 'Program – RI AM Standard Opp'};
    
    //Set to hold all the Program Opportunity Record Type DeveloperName (PT Record Types)
    public final static Set<String> SET_OPPORTUNITY_CPQ_PROGRAM_OPP_RT_DEVELOPER_NAME_PT = new Set<String>{'Program_Consulting_Management',
                                                                                                           'Program_PT_Maintenance',
                                                                                                           'Program_PT_Renewal',
                                                                                                           'Program_PT_Marketing'};
    
    //Set to hold all the Program Opportunity Record Type DeveloperName (RI Record Types)
    public final static Set<String> SET_OPPORTUNITY_CPQ_PROGRAM_OPP_RT_DEVELOPER_NAME_RI = new Set<String>{'Program_RI_Maintenance',
                                                                                                           'Program_RI_Renewal',
                                                                                                           'Program_RI_Marketing'};
                                                                                            
    //Set to hold all the Program Opportunity Record Type DeveloperName
    public final static Set<String> SET_OPPORTUNITY_CPQ_SPECIFIC_PROGRAM_OPP_RT_DEVELOPER_NAME = new Set<String>{'Program_Consulting_Management',
                                                                                            'Program_PT_Marketing', 'Program_RI_Marketing'};
    
    //Map to hold Opportunity Record Types
    public final static Map<Id, RecordType> MAP_OPPORTUNITY_RECORD_TYPE = new Map<Id, RecordType>([Select Id, Name, DeveloperName From RecordType Where SobjectType = 'Opportunity' AND isActive = true]);
    
    //Map to hold the VF pages name with appropriate record type names
    public final static Map<String, String> MAP_OPPORTUNITY_RECORD_TYPE_WITH_DETAIL_VF_PAGE_NAME = new Map<String, String>{
                                                                                            'Southwind' => 'Opportunity_Consulting_And_Management',
                                                                                            'Contract_LOA' => 'OpportunityContractLOAView',
                                                                                            'Program_Consulting_Management' => 'OpportunityProgramOppNBBDetailView',
                                                                                            'Program_PT_Marketing' => 'OpportunityProgramOppNBBDetailView',
                                                                                            'Program_RI_Marketing' => 'OpportunityProgramOppNBBDetailView'
                                                                                            };
                                                                                            
    //Map to hold the Opportunity Stage values prior to 'Active in Slow Track' according to record types
    public final static Map<String, Set<String>> MAP_OPPORTUNITY_STAGE_PRIOR_TO_AIST_WITH_RECORD_TYPE = new Map<String, Set<String>> {
                                                                                                    'Program_PT_Marketing' => new Set<String>{'Prospect', 'Outreach', 'Initial Visit Scheduled', 'Prewire'},
                                                                                                    'Program_RI_Marketing' => new Set<String>{'Prospect', 'Outreach', 'Initial Visit Scheduled', 'Prewire'},
                                                                                                    'Program_Consulting_Management' => new Set<String>{'Prospect', 'Outreach', 'Phone Appointment Scheduled','Initial Visit Scheduled','Proposal In Progress'}
                                                                                                    };
                                                                                                    
    //SelectOption list to display Opportunity stage according to current opp stage
    public final static List<SelectOption> OPPORTUNITY_ON_DECK_STAGE_OPTIONS = new List<SelectOption>{new SelectOption('On Deck','On Deck'), new SelectOption('Closed Lost','Closed Lost')};
    public final static List<SelectOption> OPPORTUNITY_ON_PIPELINE_STAGE_OPTIONS = new List<SelectOption>{new SelectOption('Pipeline','Pipeline'), new SelectOption('Contract Received - Send to Finance','Contract Received - Send to Finance'), new SelectOption('Closed Lost','Closed Lost')};
    public final static List<SelectOption> OPPORTUNITY_ON_CRSTF_STAGE_OPTIONS = new List<SelectOption>{new SelectOption('Contract Received - Send to Finance','Contract Received - Send to Finance'), new SelectOption('Sent To Finance - Opp Rejected','Sent To Finance - Opp Rejected'), new SelectOption('Closed Won','Closed Won'), new SelectOption('Closed Lost','Closed Lost')};
    public final static List<SelectOption> OPPORTUNITY_ON_STFR_STAGE_OPTIONS = new List<SelectOption>{new SelectOption('Pipeline','Pipeline'), new SelectOption('Contract Received - Send to Finance','Contract Received - Send to Finance'), new SelectOption('Sent To Finance - Opp Rejected','Sent To Finance - Opp Rejected'), new SelectOption('Closed Won','Closed Won'), new SelectOption('Closed Lost','Closed Lost')};
    public final static List<SelectOption> PROG_OPPORTUNITY_ON_DECK_STAGE_OPTIONS = new List<SelectOption>{new SelectOption('Prospect','Prospect'), new SelectOption('Outreach','Outreach'), new SelectOption('Initial Visit Scheduled','Initial Visit Scheduled'), new SelectOption('Prewire','Prewire'), new SelectOption('Closed Lost','Closed Lost')};
    public final static List<SelectOption> PROG_OPPORTUNITY_PIPELINE_STAGE_OPTIONS = new List<SelectOption>{new SelectOption('Active in SlowTrack','Active in SlowTrack'), new SelectOption('Active in FastTrack','Active in FastTrack'), new SelectOption('Verbal Yes','Verbal Yes'), new SelectOption('Closed Lost','Closed Lost')};
    public final static List<SelectOption> PROG_OPPORTUNITY_CONTRACT_RECEIVED_STAGE_OPTIONS = new List<SelectOption>{new SelectOption('Contract Received - Send to Finance','Contract Received - Send to Finance'), new SelectOption('Closed Won','Closed Won'), new SelectOption('Closed Lost','Closed Lost')};
    public final static List<SelectOption> PROG_OPPORTUNITY_CLOSED_WON_NON_PRIMARY_STAGE_OPTIONS = new List<SelectOption>{new SelectOption('Closed Lost','Closed Lost')};
    
    //Program Opportunity On Deck stages
    public final static Set<String> SET_Program_Opp_ON_DECK_STAGES = new Set<String>{'Prospect', 'Outreach', 'Initial Visit Scheduled', 'Prewire'};
    public final static Set<String> SET_Program_Opp_PIPELINE_CONTRACT_STAGES = new Set<String>{'Active in SlowTrack', 'Active in FastTrack', 'Verbal Yes', 'Contract Received - Send to Finance', 'Sent To Finance - Opp Rejected'};
    
    //Set to hold Program Business line values
    public final static Set<String> SET_PROGRAM_BUSINESS_LINE_VALUES = new Set<String>{'RI','PT','CLN'};
    
    //Modified - 10/12/2016 - Subhash Garhwal - Change Record type developername to Name 
    //Map to hold the Program Opportunities Record Type according to selected Program's Business Line
    public final static Map<String, String> MAP_PROGRAM_OPP_RRECORD_TYPE_DN_WITH_PROGRAM_BL = new Map<String, String> {
                                                                                                                        'PT' => 'Program – PT Marketing',
                                                                                                                        'RI' => 'Program – RI Marketing',
                                                                                                                        'SW' => 'Program – Consulting & Management'
                                                                                                                      };
    
    //Set to hold the Contract Opp Stage values prior to Pipeline
    public final static Set<String> SET_CONTRACT_LOA_PIPELINE_PRIOR_STAGE_VALUES = new Set<String>{'On Deck'};
    
    //Set to hold the Program Opportunities Record Type Developer Name to apply check in OpportunityTriggerHelper (Line : 580)
    public final static Set<String> SET_PROGRAM_OPP_RENEWAL_MAINTENANCE_RECORDTYPE_DN = new Set<String>{
                                                                                                        'Program_PT_Renewal', 'Program_PT_Maintenance',
                                                                                                        'Program_RI_Renewal', 'Program_RI_Maintenance',
                                                                                                        'Core_AM_Standard_Opp','Core_AM_First_Year_Opp',
                                                                                                        'BI_Contract_Maintenance','BI_Contract_Renewal'
                                                                                                        };
    
    //Map to hold the Program type with corresponding Renewal Opp Record types developerName Consulting
    public final static Map<String,String> MAP_PROGRAM_TYPE_WITH_RENEWAL_RECORDTYPE_DEVELOPERNAME = new Map<String, String> {'RI' => 'Program – RI AM Standard Opp',
                                                                                                         'PT' => 'Program – PT Contract Renewal',
                                                                                                         'Consulting' => 'Program – Consulting & Management'};
    
    //Set to hold the Proposal/Quote Status 
    public final static Set<String> SET_QUOTE_STATUS_VALUES = new Set<String>{'In Review', 'Approved'};
    
    //Added - 09/13/2016 - Subhash Garhwal - CR-20160830-10158
    public final static String PRODUCT_CATEGORY_INITIATION_FEE = 'Initiation Fee';
}