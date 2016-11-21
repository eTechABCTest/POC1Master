@isTest
public class Test_GoogleAnalyticsController {
	
    /**
     * @description: Create a couple different types of objects, take their ids and create web service logs.  
     * 				 Verify the correct info is saved on the web service log via the trigger utilities.
     **/
    static testmethod void testWebServiceLogTrigger() {
        //create a contact
        Contact c = TestUtilities.CreateNewContact(true);
        
        string contactView = '/' + c.Id;
        string contactEdit = '/' + c.Id + '/e';
        string contactTab = '/' + string.valueOf(c.Id).subString(0, 3) + '/o';
        string homeTab = '/home/home.jsp';
        
        test.StartTest();
        test.setCurrentPage(Page.GoogleAnalytics);
        ApexPages.currentPage().getParameters().put('id', c.id);
        GoogleAnalyticsController controller = new GoogleAnalyticsController();
        test.stopTest();
        
        system.assertEquals(false, controller.enableTracking);
        
        controller.url = contactView;
        controller.getAnalyticsData();
        system.assertEquals(true, controller.enableTracking);
        //verify the correct info has been populated based on the url
        system.assertEquals('View', controller.activityType);
        system.assertEquals(c.Id, controller.recordId);
        system.assertEquals('Contact', controller.objAPIName);
        system.assertEquals('Contact', controller.objName);
        system.assertNotEquals(null, controller.usr);
        
        //clear the prefix maps, simulating a new object - ensure the code will get the new object
        controller.prefixToAPINameMap.clear();
        controller.prefixToObjectMap.clear();
        
        controller.url = contactEdit;
        controller.getAnalyticsData();
		system.assertEquals(null, controller.errorMsg);
        //verify the correct info has been populated based on the url
        system.assertEquals('Edit', controller.activityType);
        system.assertEquals(c.Id, controller.recordId);
        system.assertEquals('Contact', controller.objAPIName);
        system.assertEquals('Contact', controller.objName);
        system.assertNotEquals(null, controller.usr);
        
        controller.url = contactTab;
        controller.getAnalyticsData();
        //verify the correct info has been populated based on the url
        system.assertEquals('Tab', controller.activityType);
        system.assertEquals(string.valueOf(c.Id).subString(0, 3), controller.recordId);
        system.assertEquals('Contact', controller.objAPIName);
        system.assertEquals('Contact', controller.objName);
        system.assertNotEquals(null, controller.usr);
        system.assertEquals('Salesforce', controller.licenseType);
    }
    
}