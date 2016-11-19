/*
Purpose:    Extention controller for OppNewOverride VF page used to override the Opportunity 'New' button.  Includes test method.

Create By:  Nathan Banas (SAP)          

Last Modified By:   Jeremy Nottingham (SAP) - 4/28/2011

Current Version:    v1.3

Revision Log:       v1.0 - (NB) Created code
                    v1.1 - (NB-2011-01-24) Added header, code comments, and reviewed code coverage
                    v1.2 - (NB-2011-03-24) Modified test method to ensure data is not required for deployment
                    v1.3 - (JN 4/28/11) Modified references to field IDs for prepopulating. Modified to not specify IDs.
                    v1.4 - Modified - 06/09/2016 - Subhash Garhwal - CR-20160414-9762 - Added logic for Record Type (CPQ related)
                    v1.5 - Modified by - Mahnedra Swarnkar - 8/11/2016 - CR-20160810-10101 - Merged the code From RoyallDev SB to Test SB for CR-10101.
                    
Code Coverage as of 3/24/2011: 98% (1 line not tested and unnecessary)
*/
public with sharing class OppNewOverrideExt {
    
    //Variablrs
    private ApexPages.StandardController controller;
    public String retURL {get; set;}
    public String saveNewURL {get; set;}
    public String rType {get; set;}
    public String cancelURL {get; set;}
    public String ent {get; set;}
    public String confirmationToken {get; set;}
    public String accountID {get; set;}
    public String campaignID {get; set;}
    public String contactID {get; set;}
    public String programID {get; set;}
    
    //Constructor
    public OppNewOverrideExt(ApexPages.StandardController controller) {
        
        
        this.controller = controller;
        
        retURL = ApexPages.currentPage().getParameters().get('retURL');
        rType = ApexPages.currentPage().getParameters().get('RecordType');
        cancelURL = ApexPages.currentPage().getParameters().get('cancelURL');
        ent = ApexPages.currentPage().getParameters().get('ent');
        confirmationToken = ApexPages.currentPage().getParameters().get('_CONFIRMATIONTOKEN');
        saveNewURL = ApexPages.currentPage().getParameters().get('save_new_url');
        accountID = ApexPages.currentPage().getParameters().get('accid');
        campaignID = ApexPages.currentPage().getParameters().get('campid');
        //Replaced 4/28/11 JN
        //contactID = ApexPages.currentPage().getParameters().get('CF00NT0000001KCRW');
        //Replaced 4/28/11 JN
        //programID = ApexPages.currentPage().getParameters().get('CF00NT0000001K8qO');
        
    }
    
    //Method to redirect users
    public PageReference redirect() {
        
        PageReference returnURL = ApexPages.currentPage();
        
        //Map to hold the Opportunity Record Types
        Map<Id, RecordType> mapOpportunityRecordTypes = CPQConstants.MAP_OPPORTUNITY_RECORD_TYPE;
        
        //Check for record types
        if(mapOpportunityRecordTypes.containsKey(rType)
            && mapOpportunityRecordTypes.get(rType).DeveloperName == CPQConstants.OPPORTUNITY_RECORD_TYPE_DEVELOPERNAME_CONTRACT_LOA) {
            
            // Redirect if Record Type corresponds to custom VisualForce page
            returnURL = new PageReference(CPQConstants.APEX_URL_INITIAL_PREFIX + CPQConstants.OPPORTUNITY_CONTRACT_LOA_NEW_AND_EDIT_PAGE_OPPORTUNITYCONTRACTLOAEDIT);
        }
        else {
            // Redirect to standard page layout if record type does not match
            returnURL = new PageReference('/006/e');
        }
        
        System.debug('########## : '+returnURL);
        returnURL.getParameters().put('retURL', retURL);
        returnURL.getParameters().put('RecordType', rType);
        returnURL.getParameters().put('cancelURL', cancelURL);
        returnURL.getParameters().put('ent', ent);
        returnURL.getParameters().put('_CONFIRMATIONTOKEN', confirmationToken);
        returnURL.getParameters().put('save_new_url', saveNewURL);
        returnURL.getParameters().put('nooverride', '1');
        
        //Modified by - Mahnedra Swarnkar - 8/11/2016 - CR-20160810-10101 - Merged the code From RoyallDev SB to Test SB for CR-10101. - Starts from here
        //VH 8/10/16 CR-20160810-10101
        if (rType == null || !OpportunityTriggerHelper.OPPORTUNITY_ROYALL_RT_ID.contains(rType))
        //Modified by - Mahnedra Swarnkar - 8/11/2016 - CR-20160810-10101 - Merged the code From RoyallDev SB to Test SB for CR-10101. - Ends here
            returnURL.getParameters().put('opp3', 'Will Auto-Populate'); // Set Name = 'Will Auto-Populate'
        
        if (accountID != null){
            returnURL.getParameters().put('accid', accountID);
        }
        
        if (campaignID != null) {
            returnURL.getParameters().put('campid', campaignID);
        }
        
        /* Removed 4/28/11 JN
        IF (contactID != null)
        {
            returnURL.getParameters().put('CF00NT0000001KCRW', contactID);
        }
        
        IF (programID != null)
        {
            returnURL.getParameters().put('CF00NT0000001K8qO', programID);
        }
        */
        //Add any references to custom fields in URL (start with CF)
        for (String keystring : ApexPages.CurrentPage().getParameters().keyset()) {
            if ((keystring.length() > 15) && (keystring.substring(0,2) == 'CF')) {
                returnURL.getParameters().put(keystring, ApexPages.CurrentPage().getParameters().get(keystring));
            }
        }
                
        
        returnURL.setRedirect(true);
        
        return returnURL;
    }
    
    public static testmethod void TestCase()
    { 
        //Bypass Dupeblocker
        Util.IsTest(true);
        Util.IsTesting = true;
        
        test.startTest();
        
        PageReference pageRef = Page.OppNewOverride;
        Test.setCurrentPage(pageRef);
        
        /*
        // NB - 03/24/11 - Removed due to coverage failures during deployment
        Account testAccount = [select Id, Name from Account where Name != null limit 1];
        Contact testContact = [select Id, Name from Contact where Name != null limit 1];
        Program__c testProgram = [select Id from Program__c limit 1];
        Campaign testCampaign = [select Id from Campaign limit 1];
        User testUser = [select Id, Name from User where isActive = true limit 1];*/
        
        Account testAccount = new Account(Name='testAcct', Account_Formal_Name__c='testAcct');
        insert testAccount;
        
        Contact testContact = new Contact(FirstName='Test', LastName='Contact', AccountId = testAccount.Id);
        Program__c testProgram = new Program__c(Name='Test Program', Program_Acronym__c = 'TES', Program_Formal_Name__c='Test Program');
        Campaign testCampaign = new Campaign(Name='Test Campaign', EndDate=system.today());
        
        insert testContact;
        insert testProgram;
        insert testCampaign;
        
        User testUser = [select Id, Name from User where isActive = true and Profile.Name = 'System Administrator' limit 1]; // NB - 3/24/11 - Left this query to existing data in place since we will always have one active user during a deployment
        
        
        Opportunity testOpportunity = new Opportunity(
            AccountId = testAccount.Id,
            Name = 'Test',
            StageName = 'Pending',
            CloseDate = System.today(),
            Marketer__c = testUser.Id);
        insert testOpportunity;    
        
        ApexPages.StandardController stdcontroller = new ApexPages.StandardController(testOpportunity);
        OppNewOverrideExt controller = new OppNewOverrideExt(stdcontroller);
      
        String nextPage = stdcontroller.save().getUrl();

        // Verify that page fails without parameters  
    
        System.assertNotEquals(null, nextPage);

        // Add parameters to page URL  
      
        // Instantiate a new controller with all parameters in the page  
    
        controller = new OppNewOverrideExt(stdcontroller); 

        controller.accountID = testAccount.Id;
        controller.contactID = testContact.Id;
        controller.programID = testProgram.Id;
        controller.campaignID = testCampaign.Id;

        nextPage = controller.redirect().getUrl();

        // Verify that the success page displays  
    
        System.assertNotEquals(null, nextPage);
        
        test.stopTest();
    }
}