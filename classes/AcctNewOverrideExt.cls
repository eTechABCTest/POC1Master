public with sharing class AcctNewOverrideExt
{
	/*
	Purpose: 	Extention controller for AcctNewOverride VF page used to override the Account 'New' button.  Includes test method.
	
	Create By: 	Nathan Banas (SAP)			
	
	Last Modified By: 	Nathan Banas (SAP) - 4/21/2011
	
	Current Version: 	v1.2
	
	Revision Log:		v1.0 - (NB) Created code
						v1.1 - (NB-2011-01-24) Added header, code comments, and reviewed code coverage
						v1.2 - (NB-2011-04-21) Modified test method to be remove the reliance on data being present within the system
						
	Code Coverage as of 1/24/2011: 97% (1 line not tested and unnecessary)
	Code Coverage as of 4/21/2011: 97% (1 line not tested and unnecessary)
	*/
	
    private ApexPages.StandardController controller;
    public String retURL {get; set;}
    public String saveNewURL {get; set;}
    public String rType {get; set;}
    public String cancelURL {get; set;}
    public String ent {get; set;}
    public String confirmationToken {get; set;}
    //public String accountID {get; set;}
    //public String campaignID {get; set;}
    public String contactID {get; set;}
    
    public AcctNewOverrideExt(ApexPages.StandardController controller)
    {
        this.controller = controller;
        
        retURL = ApexPages.currentPage().getParameters().get('retURL');
        rType = ApexPages.currentPage().getParameters().get('RecordType');
        cancelURL = ApexPages.currentPage().getParameters().get('cancelURL');
        ent = ApexPages.currentPage().getParameters().get('ent');
        confirmationToken = ApexPages.currentPage().getParameters().get('_CONFIRMATIONTOKEN');
        saveNewURL = ApexPages.currentPage().getParameters().get('save_new_url');
        //contactID = ApexPages.currentPage().getParameters().get('CF00NT0000001KIcn');
    }
    
    public PageReference redirect()
    {
        PageReference returnURL;
            
        IF(rType == 'xxxxxxxxxxxxxxx')
        {
            // Redirect if Record Type corresponds to custom VisualForce page
            returnURL = new PageReference('/apex/insert_VF_Page_Here');
        }
        ELSE
        {
            // Redirect to standard page layout if record type does not match
            returnURL = new PageReference('/001/e');
        }
        
        returnURL.getParameters().put('retURL', retURL);
        returnURL.getParameters().put('RecordType', rType);
        returnURL.getParameters().put('cancelURL', cancelURL);
        returnURL.getParameters().put('ent', ent);
        returnURL.getParameters().put('_CONFIRMATIONTOKEN', confirmationToken);
        returnURL.getParameters().put('save_new_url', saveNewURL);
        returnURL.getParameters().put('nooverride', '1');
        returnURL.getParameters().put('acc2', 'Will Auto-Populate'); // Set Name = 'Will Auto-Populate'
        
        /*IF (contactID != null)
        {
            returnURL.getParameters().put('CF00NT0000001KIcn', contactID);
        }*/
        
        returnURL.setRedirect(true);
        
        return returnURL;
    }
    
    public static testmethod void TestCase()
    { 
        //Bypass Dupeblocker
        Util.IsTest(true);
    	Util.IsTesting = true;
    	
    	test.startTest();
    	
        PageReference pageRef = Page.AcctNewOverride;
        Test.setCurrentPage(pageRef);
        
        //Account testAccount = [select Id, Name from Account where Name != null limit 1];
        Account testAccount = new Account(Name = 'Test');
        insert testAccount;
        
        //Contact testContact = [select Id, Name from Contact where Name != null limit 1];
        Contact testContact = new Contact(FirstName = 'Test', LastName = 'Contact', AccountId = testAccount.Id);
        insert testContact;
        
        ApexPages.StandardController stdcontroller = new ApexPages.StandardController(testAccount);
        AcctNewOverrideExt controller = new AcctNewOverrideExt(stdcontroller);
      
        String nextPage = stdcontroller.save().getUrl();

        // Verify that page fails without parameters  
    
        System.assertNotEquals(null, nextPage);

        // Add parameters to page URL  
      
        // Instantiate a new controller with all parameters in the page  
    
        controller = new AcctNewOverrideExt(stdcontroller); 
        
        controller.contactID = testContact.id;

		nextPage = controller.redirect().getUrl();

        // Verify that the success page displays  
    
        System.assertNotEquals(null, nextPage);
        
        test.stopTest();
    }
}