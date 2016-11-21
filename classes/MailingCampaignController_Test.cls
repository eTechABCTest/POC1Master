@isTest
private class MailingCampaignController_Test {
    static testMethod void MailingCampaignController_TestCtor() {
        User dss = TestUtilities.CreateNewUser(null, true);
        Campaign MailingCampaign = new Campaign(Name = 'Test', Mailing_Title__c='Mailing-1');
        insert MailingCampaign;
        ApexPages.StandardController sc = new ApexPages.standardController(MailingCampaign);
        MailingCampaignController controller = new MailingCampaignController(sc);
        
        system.assertEquals(MailingCampaign.Id, controller.MailingCampaignId);
        system.assertEquals(MailingCampaign.Id, controller.MailingCampaign.Id);
        system.assertEquals(0, controller.CampaignMembers.size());
        //system.assertEquals(0, controller.MemberCount);
        system.assertEquals(0, controller.Publications.size());
        system.assert(controller.xlsHeader != null);
        system.assert(controller.csvHeader != null);
        system.assert(controller.EndTag != null);
        /*system.assert(controller.ABCContactCell != null);
        system.assert(controller.ABCContactName != null);
        system.assert(controller.ABCContactPhone != null);*/
        system.assert(controller.EndWorksheetTag != null);
        system.assert(controller.MaterialsManagementEmail != null);
        
        //Commented out by - Ajit Surana - 08/20/2014
        /*system.assert(controller.Instruction != null);
        system.assert(controller.RowCount > 0);
        system.assert(controller.Index1 > 0);
        system.assert(controller.Index2 > 0);
        system.assert(controller.Index3 > 0);
        system.assert(controller.Index4 > 0);
        system.assert(controller.Index5 > 0);
        system.assert(controller.Index6 > 0);
        system.assert(controller.Index7 > 0);*/
    }
}