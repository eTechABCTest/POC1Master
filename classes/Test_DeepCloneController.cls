@isTest
public class Test_DeepCloneController{
    
    public static testmethod void testDeepClone () {
        
        //Create test data
        Util.BypassAllTriggers = true;
        
        //create 2 new contacts
        Contact c1 = testUtilities.CreateNewContact(false);
        Contact c2 = testUtilities.CreateNewContact(false);
        list<Contact> contacts = new list<Contact> { c1, c2 };
        insert contacts;        
        
        //create a new campaign
        Id mailingCampaignId = [SELECT Id FROM RecordType WHERE DeveloperName = 'Mailing_Campaign' AND IsActive = true LIMIT 1].Id;
        Campaign campaign = new Campaign(Name = 'Mailing Campaign 1',
                                        IsActive = true,
                                        Status = 'In Progress',
                                        RecordTypeId = mailingCampaignId);
        insert campaign;
        
        Util.BypassAllTriggers = false;
        
        //create 2 campaign members
        CampaignMember cm1 = new CampaignMember(CampaignId = campaign.Id, ContactId = c1.Id);
        CampaignMember cm2 = new CampaignMember(CampaignId = campaign.Id, ContactId = c2.Id);
        list<CampaignMember> cmList = new list<CampaignMember> { cm1, cm2 };
        insert cmList;
        
        //Go to Page
        PageReference pageRef = Page.DeepClone;
        Test.setCurrentPage(pageRef);
        
        //Set Parameters to be passed in 
        ApexPages.currentPage().getParameters().put('Id', campaign.Id);
        ApexPages.currentPage().getParameters().put('childobjecttypes', 'CampaignMember');
        
        
        // Instantiate a new controller with all parameters in place
        DeepCloneController controller = new DeepCloneController();
        
        //Simulate intial action call on page
        controller.cloneOnLoad();
        
        //Check there are now two Campaigns
        list<Campaign> testresults = [Select Id, Name from Campaign];
        system.assertequals(2,testresults.size());
        
        //Check there are now four CampaignMembers
        list<CampaignMember> testcresults = [Select Id, CampaignId from CampaignMember];
        system.assertequals(4,testcresults.size());
        
    }
}