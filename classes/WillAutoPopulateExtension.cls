/**
 *	Purpose			:	This class to work as a generic class for all the object where Name need to be populeted by "Will Auto Populate"
 *
 *	Created By		:	Bhavi Sharma
 *
 *	Created Date	:	08/30/2014
 *
 *	Revision Logs	:	V_1.0 - Created
 *
 **/ 
public with sharing class WillAutoPopulateExtension {
	
	//Redirect Page
	PageReference redirectPage;
	
	//Standard Controller Constructor
	public WillAutoPopulateExtension(ApexPages.StandardController controller) {
		
		//Create a new Pagereference 
		redirectPage = new PageReference('/' + controller.getRecord().getSobjectType().getDescribe().getKeyPrefix() + '/e' );
		
		//Check remove sfdc.override parameter from page
		//Loop through the parameters and add in new page referece sfdc.override
		for(String key : ApexPages.currentPage().getParameters().keySet()) {
			
			//in in new reference and remove 
			if(key != 'save_new')
				redirectPage.getParameters().put(key, ApexPages.currentPage().getParameters().get(key));
		}
		
		//nooverride parameter
		redirectPage.getParameters().put('nooverride', '1');
		redirectPage.getParameters().put('Name', 'Will Auto-Populate');
	}
	
	/**
	 * 	@description	:	This method is to redirect the user to the standard page and add a Name parameter in URL
	 * 
	 * 	@args			:	
	 * 
	 * 	@return			:	Standard PageReference
	 **/
	public PageReference redirect() {
		
		//redirect to 
		return redirectPage;
	} 
}