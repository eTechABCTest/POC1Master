/**
 * 	Purpose			:	This class is to hold the constants related to Credit Card functionality
 * 
 * 	Created By		:	Bhavi Sharma
 * 
 * 	Created Date	:	12/03/2014
 * 
 * 	Revision Logs	:	V_1.0 - Created
 *						V_1.1 - 06/18/2015 - Bhavi Sharma - Modiofied - CR-20141212-8307
 						V_1.2 - 10/23/2015 - Bhavi Sharma - Modiofied - New constants added
 						V_1.3 - 10/27/2015 - Mahendra Swarnakar - CR-20151013-9317 - Modiofied - New constants added
 						V_1.4 - 10/28/2015 - Mahendra Swarnakar - CR-20150707-9062 - Modiofied - New constants added 
 * 
 **/
public with sharing class CreditCardConstants {
	
    //get CC Default Settings instance  
    public static Credit_Card_Settings__c configDefaults = CreditCardConstants.CONFIG_DEFAULT;

	//constants
	
    //Commented/added by Mahendra Swarnakar - CR-20151013-9317 - 10/27/2015 
    //Starts from here
    //Public static String Default_Advisory_Profile = Label.Default_Advisory_Profile;
    Public static String PORTFOLIO_RECORd_TYPE_Employee_Payment_Account = 'Employee_Payment_Account';
    Public static String CREDIT_CARD_RECORd_TYPE_ABC_Staff_Credit_Card = 'ABC_Staff_Credit_Card';
    //Ends here
    //Added by Mahendra Swarnakar - CR-20150707-9062 - 10/27/2015
    //Start from here
	public final static String ID_ABSENCE_IN_URL = 'ERROR: No ID found in the URL';
	public final static String BACKSLASH_VAR = '/';
	public final static String UPDATING_OSR_STATUS_TO_DENIED = 'INFO: Updating OSR Status to Denied';
	public final static String OSR_ALREADY_HAVING_DENIED_STATUS = 'INFO: OSR is already having Denied status';
	public final static String NO_OSR_RECORD_FOUND = 'ERROR: No OSR record found for the ID value';
	public final static String ORIGIONAL_REQUEST_FIELD_EMPTY = 'Origional request field On OSR is required for further processing.';
    //Ends here
	
    public final static String ZERO = '00000';
    public final static String EMPCARDNUMFLAG = 'E';
    public final static String REQUEST_TYPE_POST = 'POST';
    public final static String SOAP_ACTION_ADD_CARD = 'http://fleetCredit.comdata.com/FleetCreditWS/addCard';
    public final static String SOAP_ACTION_INQUIRE_CARD = 'http://fleetCredit.comdata.com/FleetCreditWS/inquireCard';
    public final static String SOAP_ACTION_UPDATE_CARD = 'http://fleetCredit.comdata.com/FleetCreditWS/updateCard';
    public final static String SOAP_ACTION_INQUIRE_CUSTOMER_PROFILE_LIMITS = 'http://fleetCredit.comdata.com/FleetCreditWS/inquireCustomerProfileLimits';
    public final static String SOAP_ACTION_UPDATE_CUSTOMER_PROFILE_LIMITS = 'http://fleetCredit.comdata.com/FleetCreditWS/updateCustomerProfileLimits';
    public final static String SOAP_ACTION_INQUIRE_CARD_SECURITY_CODE = 'http://fleetCredit.comdata.com/FleetCreditWS/inquireCardSecurityCode';
    public final static String SOAP_ACTION_INQUIRE_CARD_PROFILE_LIMITS = 'http://fleetCredit.comdata.com/FleetCreditWS/inquireCardProfileLimits';
    public final static String SOAP_ACTION_UPDATE_CARD_PROFILE_LIMITS = 'http://fleetCredit.comdata.com/FleetCreditWS/updateCardProfileLimits';
    public final static String SOAP_ACTION_REAL_TIME_TRANSACTION_HISTORY = 'http://fleetCredit.comdata.com/FleetCreditWS/realTimeTransactionHistory';
    public final static String COMDATA_REQUEST_ENVELOPE_NAMESPACE_STRING = '<soapenv:Envelope xmlns:soapenv="' + configDefaults.xmlns_soapenv__c + '" xmlns:main="' + configDefaults.xmlns_main__c + '">';
    
    public final static String OSR_STATUS_NEW = 'New';
    public final static String OSR_STATUS_COMPLETE = 'Complete';
    public static final String OSR_STATUS_SENT_AGREEMENT = 'Pending Application';
    public static final String OSR_STATUS_RECEIVED_AGREEMENT = 'Pending Finance';
    public static final String OSR_STATUS_CANCELLED = 'Cancelled';
    public static final String OSR_STATUS_IN_PROGRESS = 'In Progress';
    public static final String OSR_STATUS_PENDING_FINANCE = 'Pending Finance';
    
    //Added by Mahendra Swarnakar - CR-20150707-9062 - 10/27/2015
    public final static String OSR_STATUS_DENIED = 'Denied';
    
    public static final String OSR_SUBJECT_CREATE_FRAUD_ALERT_ABC_CREDIT_CARD = 'Fraud Alert';
    public static final String OSR_SUBJECT_CREATE_DECLINE_ALERT_ABC_CREDIT_CARD = 'Decline Alert';
    public static final String OSR_SUBJECT_CREATE_OTHER_ALERT_ABC_CREDIT_CARD = 'Other Alert';
    
    public static final String OSR_REQUEST_TYPE_DECLINE_ALERT = 'Decline Alert';
    public static final String OSR_REQUEST_TYPE_DEACTIVATE_CARD = 'Deactivate Card';
    public static final String OSR_REQUEST_TYPE_FRAUD_ALERT = 'Fraud Alert';
    public static final String OSR_REQUEST_TYPE_OTHER_ALERT = 'Other Alert';
    public static final String OSR_REQUEST_TYPE_NEW_ABC_CREDIT_CARD = 'New ABC Credit Card';
    public static final String OSR_REQUEST_REASON_LEAVING_COMPANY = 'Leaving Company';
    public static final String OSR_REQUEST_TYPE_REPLACEMENT_ABC_CREDIT_CARD = 'Replacement ABC Credit Card';
    public static final String OSR_REQUEST_TYPE_DEACTIVATE_ABC_CREDIT_CARD = 'Deactivate ABC Credit Card';
    public static final String OSR_REQUEST_TYPE_REPLACEMENT_ABC_CREDIT_CARD_EXPEDITED = 'Replacement ABC Credit Card (Alternate Delivery)';
    
    
    public static final String OSR_ORIGIN_CREATE_VENDOR_ALERT = 'Vendor Alert';
    public static final String OSR_ORIGIN_TRAVEL_PORTAL = 'Travel Portal';
    
    public static final String OSR_PRIORITY_CREATE_URGENT = 'Urgent';
    public static final String OSR_PRIORITY_CREATE_MEDIUM = 'Medium';
    
    public static final String OSR_EXPEDITED_PROCESSING_APPROVAL_APPROVED = 'Approved';
    public static final String OSR_EXPEDITED_PROCESSING_APPROVAL_NOT_APPROVED = 'Not Approved';
    
    public static final String OSR_RECORD_TYPE_DEVELOPER_NAME_CREDIT_CARD_ALERT = 'Credit_Card_Alert';
    public static final String OSR_RECORD_TYPE_DEVELOPER_NAME_CREDIT_CARD_REQUEST = 'Credit_Card_Request';
    
    public static final String OSR_SUBJECT_CARD_OVER_LIMIT_DEACTIVATION_FAILED = 'Card Over Limit Deactivation Failed';
    public static final String OSR_SUBJECT_CARD_OVER_BALANCE_LIMIT_DEACTIVATED = 'Card Over Balance Limit Deactivated';
    public static final String OSR_SUBJECT_CARD_OVER_AGE_LIMIT_DEACTIVATED = 'Card Over Age Limit Deactivated';
    public static final String OSR_SUBJECT_EMPLOYEE_LEAVING = 'Employee Leaving - Deactivate ABC Staff Credit Card';
    
    public final static String OSR_REQUEST_REASON_LOST = 'Lost';
    public final static String OSR_REQUEST_REASON_STOLEN = 'Stolen';
    
    public static final String OSR_DECLINE_ALERT = 'Decline';
    public static final String OSR_DESCRIPTION_ERROR_MESSAGE = 'Error Message';
    public static final String OSR_REQUEST_REASON_CARD_OVER_CREDIT_AGE_LIMIT = 'Card Over Credit/Age Limit';
    public static final String OSR_PRIORITY_CREATE_HIGH = 'High';
    public static final String OSR_ORIGIN_SALESFORCE = 'Salesforce';
    
    public final static String CC_STATUS_VENDOR_APPROVAL = 'Vendor Approval';
    public final static String CC_STATUS_ACTIVE = 'Active';
    public final static String CC_STATUS_INACTIVE = 'Inactive';
    public final static String CC_STATUS_PENDING_ACTIVATION = 'Pending Activation';
    public final static String CC_STATUS_REQUEST_DECLINED = 'Request Declined';
    public final static String CC_STATUS_PENDING_DEACTIVATION = 'Pending Deactivation';
    public final static String CC_STATUS_DEACTIVATED = 'Deactivated';
    

    public final static String CC_SETUP_STATUS_PENDING_RESPONSE = 'Pending Response';
    public final static String CC_SETUP_STATUS_SUCCESS = 'Success';
    public final static String CC_SETUP_STATUS_NEW_REQUEST = 'New Request';
    public final static String CC_SETUP_STATUS_DECLINED = 'Declined';
    public final static String CC_SET_UP_STATUS_USER_ACTIVATED = 'User Activated';
    public final static String CC_SET_UP_STATUS_ACTIVATION_FAILED = 'Activation Failed';
    public final static String CC_SET_UP_STATUS_NEW_REQUEST = 'New Request';
    public final static String CC_SET_UP_STATUS_PENDING_ACTIVATION = 'Pending Activation';

    public final static String CC_DEACTIVATION_STATUS_PENDING_RESPONSE = 'Pending Response';
    public final static String CC_DEACTIVATION_STATUS_PENDING_REPLACEMENT_ACTIVATION = 'Pending Replacement Activation';
    public final static String CC_DEACTIVATION_STATUS_DEACTIVATED = 'Deactivated';

    public final static String CC_CARD_DELIVERY_OPTION_FEDEX_PRIORITY = 'FEDEX Priority';
    public final static String CC_CARD_DELIVERY_OPTION_UPS_2ND_DAY_AIR = 'UPS 2nd Day Air';
    
    public final static String CC_CARD_DEACTIVATION_REASON_LOST = 'Lost';
    public final static String CC_CARD_DEACTIVATION_REASON_STOLEN = 'Stolen';
    
    public static final String CC_DEFAULT_SETTINGS_NAME = 'CC Default Settings';
    
    //Portfolio
    public final static String PORTFOLIO_STATUS_DEACTIVATED = 'Deactivated';
    public final static String PORTFOLIO_STATUS_INACTIVE = 'Inactive';
    public final static String PORTFOLIO_STATUS_ACTIVATED = 'Activated';
    public final static String PORTFOLIO_DEACTIVATION_REASON_OVER_CREDIT_BALANNCE_LIMIT = 'Over Credit Balance Limit';
    public final static String PORTFOLIO_DEACTIVATION_REASON_OVER_AGE_LIMIT = 'Over Age Limit';
    public final static String PORTFOLIO_DEACTIVATION_REASON_OTHER = 'Other';
    
    //Added by Mahendra Swarnkar - CR-20150901-9211 -09/09/2015
    public final static String EMPLOYEE_NO_LONGER_EXISTS = 'Employee no longer exists';
    
    //Added By - Mahendra Swarnkar - 09/04/2015 - CR-20150731-9125
    public final static String EMPLOYEE_NOT_FOUND_IN_COMDATA = 'Employee Not Found in Comdata';
    public final static String EMPLOYEE_NUMBER_NOT_FOUND = 'EMPLOYEE NUMBER NOT FOUND';
    
	public static final String CCT_TRANSACTION_STATUS_AUTHORIZED = 'Authorized';
    public static final String CCT_TRANSACTION_STATUS_DECLINED = 'Declined';
    public static final String DOCUMENT_DEVELOPER_NAME_ADVISORY_BOARD_CREDIT_CARD_AGREEMENT = 'Advisory_Board_Credit_Card_Agreement';
    
    //Bhavi Sharma - 10/22/2015 - Warning Aging Constants
    public static final String PORTFOLIO_WARNING_TYPE_FIRST ='First';
    public static final String PORTFOLIO_WARNING_TYPE_SECOND ='Second';
    public static final String PORTFOLIO_WARNING_TYPE_THIRD ='Third';
    public static final String PORTFOLIO_WARNING_TYPE_DEACTIVATE ='Deactivate';
    
    public static final String PORTFOLIO_WARNING_EMAIL_STATUS_SEND_FIRST_WARNING ='Send First Warning';
    public static final String PORTFOLIO_WARNING_EMAIL_STATUS_FIRST_WARNING_SENT ='First Warning Sent';
    public static final String PORTFOLIO_WARNING_EMAIL_STATUS_SEND_SECOND_WARNING ='Send Second Warning';
    public static final String PORTFOLIO_WARNING_EMAIL_STATUS_SECOND_WARNING_SENT ='Second Warning Sent';
    public static final String PORTFOLIO_WARNING_EMAIL_STATUS_SEND_THIRD_WARNING ='Send Third Warning';
    public static final String PORTFOLIO_WARNING_EMAIL_STATUS_THIRD_WARNING_SENT ='Third Warning Sent';
    public static final String PORTFOLIO_WARNING_EMAIL_STATUS_DEACTIVATE_PORTFOLIO ='Deactivate Portfolio';
    public static final String PORTFOLIO_WARNING_EMAIL_STATUS_PORTFOLIO_DEACTIVATED ='Portfolio Deactivated';
    
    //OSR record creation field values
    public static final String USER_ALIAS_SFADMIN = 'SFADMIN';
    public static final String AGREEMENT_NAME_ADVISORY_BOARD_CREDIT_CARD_AGREEMENT = 'Advisory Board Credit Card Agreement';
    public static final String ASYNC_APEX_JOB_STATUS_HOLDING = 'Holding';
    public static final String ASYNC_APEX_JOB_STATUS_QUEUED = 'Queued';
    public static final String ASYNC_APEX_JOB_STATUS_PROCESSING = 'Processing';
    public static final String ASYNC_APEX_JOB_STATUS_PREPARING = 'Preparing';
    public static final Set<String> ASYNC_APEX_JOB_PENDING_STATUSES = new Set<String>{
                                                                                       CreditCardConstants.ASYNC_APEX_JOB_STATUS_HOLDING, 
                                                                                       CreditCardConstants.ASYNC_APEX_JOB_STATUS_QUEUED, 
                                                                                       CreditCardConstants.ASYNC_APEX_JOB_STATUS_PROCESSING, 
                                                                                       CreditCardConstants.ASYNC_APEX_JOB_STATUS_PREPARING
                                                                                    };
    
    public static final Set<String> OSR_AUTOMATED_UNBLOCKING_REQUEST_TYPES = new Set<String>{
                                                                                       CreditCardConstants.OSR_REQUEST_TYPE_REPLACEMENT_ABC_CREDIT_CARD,
                                                                                       CreditCardConstants.OSR_REQUEST_TYPE_REPLACEMENT_ABC_CREDIT_CARD_EXPEDITED,
                                                                                       CreditCardConstants.OSR_REQUEST_TYPE_DEACTIVATE_ABC_CREDIT_CARD
                                                                                    };
	
    //Credit Card Balance jobs names
    public final static Set<String> CC_BALANCE_JOB_NAMES = new Set<String>{'Batch_UpdateCardBalanceInComdata',
                                                                                'Sched_CheckOverLimits',
                                                                                'Batch_CheckWarningLimit',
                                                                                'Batch_CheckTransactionAgeLimit',
                                                                                'Batch_OverCreditLimit',
                                                                                'Batch_OverTransactionAgeLimit'};

	//Comdata request heder
    public static String COMDATA_REQUEST_ENVELOPE_HEADER {

        get {

            String evnelopeHeader = '<soapenv:Header>'
                                        + '<wsse:Security soapenv:mustUnderstand="1" xmlns:wsse="' + configDefaults.xmlns_wsse__c + '">'
                                            + '<wsse:UsernameToken wsu:Id="UsernameToken-12" xmlns:wsu="' + configDefaults.xmlns_wsu__c + '">'
                                                + '<wsse:Username>' + configDefaults.Username__c + '</wsse:Username>'
                                                + '<wsse:Password>' + configDefaults.Password__c + '</wsse:Password>'
                                            + '</wsse:UsernameToken>'
                                        + '</wsse:Security>'
                                    + '</soapenv:Header>';
            return evnelopeHeader;
        }
    }
	
	//Card Setting
	public static Credit_Card_Settings__c CARD_SETTINGS {
		get {
        	
    	    Credit_Card_Settings__c CARD_SETTINGS = new Credit_Card_Settings__c();
            
            //Query record
            List<Credit_Card_Settings__c> settings = [SELECT Id, Default_Portfolio_Profile__c, Company_Name__c, Staff_Card_Record_Type__c, Staff_Portfolio_Record_Type__c,
                                                        Staff_Portfolio_Profile__c, Portfolio_Record_Owner__c, Default_Portfolio_Status__c, Default_Delivery_Option__c,
                                                        Default_Card_Expiration_Months__c, Card_Vendor__c, New_Card_Status__c, New_Card_Set_Up_Status__c,
                                                        Alternate_Delivery_Attention_To__c, Alternate_Delivery_Address_1__c, Alternate_Delivery_Address_2__c,
                                                        Alternate_Delivery_City__c, Alternate_Delivery_State__c, Alternate_Delivery_Postal_Code__c
                                                        FROM Credit_Card_Settings__c WHERE Status__c = 'Active' limit 1];
            if (settings.size() > 0) 
            	CARD_SETTINGS = settings[0];
            return CARD_SETTINGS;
        }
    }
    
    //Variable to hold Comdata webservice defaults custom setting values
    public static Credit_Card_Settings__c CONFIG_DEFAULT {

        get {
            if (CONFIG_DEFAULT == null) {
                CONFIG_DEFAULT = new Credit_Card_Settings__c();
                //Get Comdata webservice Defaults values
                List<Credit_Card_Settings__c> configDefaultsList = [SELECT Name, Account_Code__c, CC_Default_Limit_Warning_Level__c, Staff_Portfolio_Profile__c, CC_Month_Cycle_Reset_Date__c,
                                                                Company_Name__c, Customer_Id__c, Decline_Alert_To_Finance__c, Endpoint__c, xmlns_soapenv__c, xmlns_main__c, xmlns_wsse__c, xmlns_wsu__c, Last_Transaction_Pull__c,
                                                                Mask_Card_Num_On_Create__c, Password__c, Username__c, Transaction_History_Days__c, Default_Delivery_Option_Code__c,
                                                                Statement_Email_Template__c, Card_Profile_Flag__c, Default_Card_Profile_Value__c, Default_Vendor_Card_Status__c,
                                                                Mask_Card_Num_on_Inquiry_Update__c, Portfolio_Record_Owner__c, Default_Portfolio_Status__c, Staff_Portfolio_Record_Type__c,
                                                                Expedited_Delivery_Option_Code__c, Default_Portfolio_Profile__c, Service_User__c,
                                                                Alternate_Delivery_Attention_To__c, Alternate_Delivery_Address_1__c, Alternate_Delivery_Address_2__c,
                                                                Alternate_Delivery_City__c, Alternate_Delivery_State__c, Alternate_Delivery_Postal_Code__c, Traveldesk_Email__c
                                                                FROM Credit_Card_Settings__c WHERE Name =: CC_DEFAULT_SETTINGS_NAME];
                if (configDefaultsList.size() > 0)
                    CONFIG_DEFAULT = configDefaultsList[0];
                else
                    CONFIG_DEFAULT = new Credit_Card_Settings__c();
            }
            return CONFIG_DEFAULT;
        }
    }
    
    public static Set<String> SET_UNITED_STATES = new Set<String>{'us', 'usa', 'united state', 'united states'};
    public static Map<String, String> MAP_COMDATA_STATUS_CODE_WITH_STATUS = new Map<String, String> {
    																									'A' => 'Active',
    																									'B' => 'Blocked',
    																									'C' => 'Clear',
    																									'F' => 'Fraud',
    																									'L' => 'Lost',
    																									'S' => 'Stolen'
    																								};
	
	//Map for Credit Card Alert service
	public static Map<String, String> MAP_CREDIT_CARD_ALERT_REASON = new Map<String, String> {
																								'exceeded your credit limit' => 'Exceeded Credit Limit',
    																							'enhanced risk monitoring' => 'Enhanced Risk Monitoring',
    																							'problem with the merchant code' => 'Merchant Code / MCC Issue',
    																							'expiration date entered is invalid' => 'Invalid Expiration Date',
    																							'error with the CVV code' => 'Invalid CVV'
																							};
}