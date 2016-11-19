/**
 *  Purpose         :   Test code for the ReferencePerkExtension class
 * 
 *  Created By      :   Victor Hanson
 * 
 *  Created Date    :   1/13/2016
 * 
 * Revision Logs    :   V_1.0 - Created
 *
 **/ 
@isTest
public class Test_ReferencePerkExtension {
    
    /**
     * 
     * @description: when going to the ReferencePerk VF page, if the record type != Perk Template, redirect to standard edit page.
     * 
     **/
    static testMethod void testRedirect_true() {
        //set the page reference
        PageReference pageRef = Page.ReferencePerk;
        test.setCurrentPage(pageRef);
        
        //Set currentpage parameters so record type is Perk Template
        ApexPages.currentPage().getParameters().put('RecordType', Schema.SObjectType.Reference_Perk__c.getRecordTypeInfosByName().get(Label.PT).getRecordTypeId());
        
        //instantiate the controller
        Reference_Perk__c refPerk = new Reference_Perk__c();
        ReferencePerkExtension controller = new ReferencePerkExtension(new ApexPages.standardController(refPerk));
        
        //execute the redirect method
        PageReference pg = controller.redirect();
        
        system.assertNotEquals(null, pg);
    }
    
    /**
     * 
     * @description: when going to the ReferencePerk VF page, if the record type == Perk Template, do not redirect (return null).
     * 
     **/
    static testMethod void testRedirect_false() {
        //set the page reference
        PageReference pageRef = Page.ReferencePerk;
        test.setCurrentPage(pageRef);
        
        //Set currentpage parameters so record type is Perk Template
        ApexPages.currentPage().getParameters().put('RecordType', ReferencePerkExtension.RECORD_TYPE_ID_REF_PERK_TEMPLATE);
        
        //instantiate the controller
        Reference_Perk__c refPerk = new Reference_Perk__c(RecordTypeId = ReferencePerkExtension.RECORD_TYPE_ID_REF_PERK_TEMPLATE);
        ReferencePerkExtension controller = new ReferencePerkExtension(new ApexPages.standardController(refPerk));
        
        //execute the redirect method
        PageReference pg = controller.redirect();
        
        system.assertEquals(null, pg);
    }
    
}