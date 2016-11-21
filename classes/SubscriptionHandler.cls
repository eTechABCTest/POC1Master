/**
 *  Desription      :   Controller for managing subscription
 *
 *  Created By      :   Bhavi Sharma
 *
 *  Created Date    :   03/15/2013
 *
 *  Revision Logs   :   V1.0 - Created
 * 						V1.1 -Modified by - Mahendra Swarnkar -2/8/2016- CR-20151222-9476
 * 						v1.2 - Modified By - Abhinav Sharma - 05/20/2016 - CR-20160506-9837 
 *						v1.3 - Modified By - Mahendra Swarnkar - 8/30/206 - CR-20160505-9830
 *
 **/
public without sharing class SubscriptionHandler {

    //Properties
    private String contactId;
    private String subscriptionId;
    public String subscriptionName{get;set;}
    private String reason;
    public string response { get; set; }
    public static final string UNSUBSCRIBE_SUCCESS = 'Unsubscribe_Success';

    //Constructor
    public SubscriptionHandler() {

        //Check for the request parameter
        if(ApexPages.currentPage().getParameters().get('CID') != null)
            contactId = ApexPages.currentPage().getParameters().get('CID');
        if(ApexPages.currentPage().getParameters().get('sub') != null)
            subscriptionId = ApexPages.currentPage().getParameters().get('sub');
        if(ApexPages.currentPage().getParameters().get('radiobuttons') != null)
            reason = ApexPages.currentPage().getParameters().get('radiobuttons');
    }

    //Add subscription
    public PageReference addSubscription() {

        try {

            //Check for the subscription Id
            if(subscriptionId instanceof Id) {

                //Check if this is a valid Subscription Option
                List<Subscription_Option__c> subs = [Select Id, Name from Subscription_Option__c where Id =: subscriptionId];

                if(subs.size() == 0)
                    throw new CustomException(Label.ERROR_INVALID_SUBSCRIPTION_ID_SUBSCRIBE);
            } else
                throw new CustomException(Label.ERROR_INVALID_SUBSCRIPTION_ID_SUBSCRIBE);

            //get the contact id from database
            List<Contact> contacts = new List<Contact>();

            //Check for the contact Id
            if(contactId instanceof Id) {

                //get the contact id from database
                contacts = [Select Email, AccountId from Contact where Id =: contactId AND Email != null limit 1];

                //Check for the contacts
                if(contacts.size() == 0)
                    throw new CustomException(Label.ERROR_INVALID_CONTACT_ID_SUBSCRIBE);
            } else
                throw new CustomException(Label.ERROR_INVALID_CONTACT_ID_SUBSCRIBE);

            //Check for the eligibility
            List<SiteProfileSubscriptionUploadController.ContactWrapper> cntWrappers = SiteProfileSubscriptionUploadController.CreateContactWrappers(null, contacts[0].Id, subscriptionId);

            //Check if for the results
            if(cntWrappers != null && cntWrappers.size() > 0) {

                //Check if subscription need to be created
                if(cntWrappers[0].SubscriptionEligibility == SiteProfileSubscriptionUploadController.SUBSCRIBE_SUCCESSFUL) {

                    //get the subsription record from database
                    List<Subscription_Option__c> sOptions = [Select Name from Subscription_Option__c where
                                                Id = :cntWrappers[0].EligSubOption.Related_Subscription__c limit 1];
                    subscriptionName = sOptions[0].Name;

                    //Create a subscription record is contact is eligible
                    Subscription__c subscription = new Subscription__c(Contact__c = contactId, Subscription_ID__c = cntWrappers[0].EligSubOption.Id,
                                                                    Activation_Date__c = DateTime.now(), Subscription_Status__c = Constants.ACTIVE);

                    //Insert data in database;
                    insert subscription;

                    //Success Message
                    response = SiteUserHelper.RESPONSE_SUCCESS;
                } else
                    throw new CustomException(cntWrappers[0].SubscriptionEligibility);
            } else
                throw new CustomException(cntWrappers[0].SubscriptionEligibility);
        } catch(Exception e) {

            response = e.getMessage();

            //Check if error message is SUBSCRIBE_FAIL_NOT_ELIGIBLE, customized it to ERROR_INVALID_CONTACT_ID_SUBSCRIBE
            if(response.equalsIgnoreCase(SiteProfileSubscriptionUploadController.SUBSCRIBE_FAIL_NOT_ELIGIBLE))
                response = Label.ERROR_INVALID_CONTACT_ID_SUBSCRIBE;
            else if (response.equalsIgnoreCase(SiteProfileSubscriptionUploadController.SUBSCRIBE_FAIL_ALREADY_SUBSCRIBED))
                response = Label.ERROR_ALREADY_SUBSCRIBED_USER;
        }
		
        //create the pageReference that will redirect to the correct site
        PageReference pgRef = new PageReference(siteDomain + '/Members/Subscriptions');
        pgRef.getParameters().put('subName', subscriptionName);
        pgRef.getParameters().put('response', response);
        
        //return null
        return pgRef;
    }
	
	//Modified by - Mahendra Swarnkar - 8/30/206 - CR-20160505-9830
    //Remove Subscription
    public Pagereference removeSubscription() {

        try {

            //Create a list of subscription
            List<Subscription__c> subscriptions = new List<Subscription__c>();
            
            //Map of contacts
			Map<Id, Contact> mapOfConatctsToBeUpdated = new Map<Id, Contact>();
			
			//Check for the subscription Id
			if(String.isNotBlank(subscriptionId) 
            	&& subscriptionId.trim().equalsIgnoreCase(System.Label.UNSUB_ALL_IDENTIFIER)
            	&& String.isNotBlank(contactId)) {
                    
                //Checking if contactId is a salesforce ID type instance
                if(contactId instanceof Id) {  
				
                    //Fetching all the subscriptions associated with the current context contact instance
					for(Contact con : [SELECT Id, Unsubscribe_All_Date__c, HasOptedOutOfEmail, 
                                       (SELECT Id, Termination_Date__c, Subscription_Status__c, Subscription_Name__c 
                                        	FROM Subscriptions__r
                                       ) 
                                       FROM Contact 
                                       WHERE Id =: contactId]){
					
                        //Populating collection to have contact updated instances for further updates
                        mapOfConatctsToBeUpdated.put(con.Id, new Contact(Id = con.Id, Unsubscribe_All_Date__c = System.Today(), HasOptedOutOfEmail = true));
					
                        //Loop thgrough subscription records and populating fields values on it's instances, in order to get them mark as "unsubscribed"                   	
                        for (Subscription__c subscription : con.Subscriptions__r) {
                            
                            //Update subscription with termination date/reason
                            subscription.Termination_Date__c = DateTime.now();
                            subscription.Subscription_Status__c = Constants.INACTIVE_UNSUBSCRIBED_BY_MEMBER;
                            
                            //Append the subscription reason in Subscription status message
                            if(reason != null && reason != '')
                                subscription.Subscription_Status__c += ' - ' + reason;
                         
                            //Update subscription with termination date/reason
                            subscriptions.add(subscription);
                    	}
                	}
                    
                    //Checking for the size value and updating subscriptions records for unsubscribing them
                    if(subscriptions != null && subscriptions.size() > 0)
                        update subscriptions;
                        
                    //Checking for the size value and updating contact records with fields values
                    if(mapOfConatctsToBeUpdated != null && mapOfConatctsToBeUpdated.values().size() > 0)
                        update mapOfConatctsToBeUpdated.values();
                	
                    //Success Message
            		response = System.Label.UNSUBSCRIBE_ALL_SUCCESS;
                
                } else {
                    
                    //throw Invalid contact ID error
                    throw new CustomException(Label.ERROR_INVALID_CONTACT_ID_UNSUBSCRIBE);
                }
            } else {
                
                //Checking if subscriptionid variable is a valid salesforce ID
                if(subscriptionId instanceof Id) {
                
                    //Modified by Mahendra Swarnkar - 2/8/2016 - CR-20151222-9476
                    //Updated the Query to remove the "and Temrination_date__c = null" filter from the soql query 
                    //and add an additional clause at last as " ORDER BY Termination_Date__c DESC NULLS FIRST"
                    //Check if this is a valid subscription
                    subscriptions = [Select Id, Subscription_Name__c, Subscription_Status__c from Subscription__c where
                                                        Subscription_Option_Id__c != null AND Subscription_ID__r.Related_Subscription__c =: subscriptionId AND
                                                        Contact__c != null AND Contact__c =: contactId ORDER BY Termination_Date__c DESC NULLS FIRST];
                    
                    //Checking for size value and appopriately throwing the error
                    if(subscriptions.size() == 0)
                        throw new CustomException(Label.ERROR_INVALID_SUBSCRIPTION_ID_UNSUBSCRIBE);
                
                //throw Invaild Subscription ID error    
                } else
                    throw new CustomException(Label.ERROR_INVALID_SUBSCRIPTION_ID_UNSUBSCRIBE);

                //get the contact id from database
                List<Contact> contacts = new List<Contact>();

                //Check for the contact Id is a valid salesforce ID
                if(contactId instanceof Id) {
    
                    //get the contact id from database
                    contacts = [Select Email, AccountId from Contact where Id =: contactId AND Email != null limit 1];
    
                    //Check for the contacts
                    if(contacts.size() == 0)
                        throw new CustomException(Label.ERROR_INVALID_CONTACT_ID_UNSUBSCRIBE);
            	
                //throw Invaild Contact ID error    
                } else
                	throw new CustomException(Label.ERROR_INVALID_CONTACT_ID_UNSUBSCRIBE);
                
                //Checking for the size value
                if(subscriptions != null && subscriptions.size() > 0) {
                    
                	//Loop through subscription records
                    for (Subscription__c subscription : subscriptions) {
                        
                        //Update subscription with termination date/reason
                        subscription.Termination_Date__c = DateTime.now();
                        subscription.Subscription_Status__c = Constants.INACTIVE_UNSUBSCRIBED_BY_MEMBER;
                        subscriptionName = subscription.Subscription_Name__c;
                        
                        //Append the subscription reason in Subscription status message
                        if(reason != null && reason != '')
                            subscription.Subscription_Status__c += ' - ' + reason;
                    }

                    //Update data in database;
                    update subscriptions;    
                }
			
            	//Success Message
            	response = UNSUBSCRIBE_SUCCESS;
            }
		
    	} catch(Exception e) {

            //Get error message
            response = e.getMessage();
        }
        
        //create the pageReference that will redirect to the correct site
        PageReference pgRef = new PageReference(siteDomain + '/Members/Subscriptions');
        pgRef.getParameters().put('subName', subscriptionName);
        pgRef.getParameters().put('response', response);
        
        //return null
        return pgRef;
    }
    
    //determine if this is an eab subscription
    private boolean isEAB {
        get {
            if (isEAB == null) {
                isEAB = false;
                list<Eligible_Subscription_Option__c> eligSubOptions = [SELECT Id, Program__r.Applicable_Segments__c FROM Eligible_Subscription_Option__c WHERE Related_Subscription__c = :subscriptionId LIMIT 1];
                if (eligSubOptions.size() > 0) {
                    if (eligSubOptions[0].Program__r.Applicable_Segments__c != null &&  eligSubOptions[0].Program__r.Applicable_Segments__c.containsIgnoreCase('Education')) {
                        isEAB = true;
                    }
                }
            }
            return isEAB;
        }
        set;
    }
    
    
    //determine if we should redirect to eab.com or advisory.com
    private string siteDomain {
        get {
            if (siteDomain == null) {
                Sitecore_Settings__c settings = SiteUserHelper.sitecoreSettings;
                string subdomain = 'www';
                if (settings.Advisory_Password_Reset_URL__c != null) {
                    subdomain = settings.Advisory_Password_Reset_URL__c.replaceAll('https://', '').split('\\.')[0];
                }
                siteDomain = 'https://' + subdomain + '.advisory.com';
                if (isEAB) siteDomain = 'https://' + subdomain + '.eab.com';
            }
            return siteDomain;
        }
        set;
    }
}