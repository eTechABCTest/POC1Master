@isTest
public class Idea_Test{
    static testMethod void IdeaUserHelper_TestCtor(){
        User user = CreateTestUser('TestUser');
        Contact contact = CreateTestContact(user, '666666');
        
        IdeaUserHelper helper = new IdeaUserHelper('666666');
        helper.FromContact(contact);
        system.assertEquals(user.Id, helper.UserId);
    }
    
    static testMethod void IdeaCommentWrapper_TestCtor(){
        User user = CreateTestUser('TestUser');
        Contact contact = CreateTestContact(user, '666666');
        
        IdeaUserHelper userhelper = new IdeaUserHelper('666666');
        userhelper.FromContact(contact);
        
        Advisory_Idea__c idea = new Advisory_Idea__c();
        Advisory_Idea_Comment__c comment = new Advisory_Idea_Comment__c(Advisory_Idea__c = idea.Id,
                                                                        Commented_By__c = contact.Id);
        //insert idea;
        
        IdeaCommentWrapper wrapper = new IdeaCommentWrapper(idea.Id, userhelper);
        system.assertEquals(true, wrapper.IsMyComment);
        
        Map<Id,Contact> contacts = new Map<Id,Contact>();
        contacts.put(contact.Id, contact);
        Map<Id,User> users = new Map<Id,User>();
        users.put(user.Id, user);
        IdeaCommentWrapper wrapper2 = new IdeaCommentWrapper(comment, contacts, users, contact.Id);
        system.assertEquals(true, wrapper2.IsMyComment);
    }
    
    static testMethod void IdeaController_TestLoad(){
        User user = CreateTestUser('TestUser');
        Contact contact = CreateTestContact(user, '123456');
        user.Finance_Code__c = '123456';
        update user;
        Advisory_Idea__c idea = new Advisory_Idea__c();
        idea.Title__c = 'Title';
        idea.High_Level_Description__c = 'Description';
        idea.Implementation_Date__c = 'Date';
        insert idea;
        Advisory_Idea_Comment__c comment = new Advisory_Idea_Comment__c(Advisory_Idea__c = idea.Id,
                                                                        Commented_By__c = contact.Id);
        IdeaWrapper ideaWrapper = new IdeaWrapper(idea, contact.Id);
        
        IdeaController controller = new IdeaController();
        controller.CurrentUser = new IdeaUserHelper('123456');
        ApexPages.currentPage().getParameters().put('id', idea.id);
        PageReference nextPage = controller.Load();
        system.assertEquals(nextPage, null);
        
        system.assertNotEquals(controller.HomePageUrl, null);
        system.assertNotEquals(controller.ViewUrl, null);
        system.assertEquals(controller.MyVote, null);
    }

    static testMethod void IdeaController_TestMyVote(){
        User user = CreateTestUser('TestUser');
        Contact contact = CreateTestContact(user, '123456');
        user.Finance_Code__c = '123456';
        update user;
        Advisory_Idea__c idea = new Advisory_Idea__c();
        idea.Title__c = 'Title';
        idea.High_Level_Description__c = 'Description';
        idea.Implementation_Date__c = 'Date';
        insert idea;
        Advisory_Idea_Comment__c comment = new Advisory_Idea_Comment__c(Advisory_Idea__c = idea.Id,
                                                                        Commented_By__c = contact.Id);
        insert comment;
        Advisory_Idea_Vote__c vote = new Advisory_Idea_Vote__c (Advisory_Idea__c = idea.Id,
                                                                   Voted_By__c = contact.Id);   
        insert vote;
		system.debug('##IdeaController_TestMyVote>vote: ' + vote);
        
        IdeaController controller = new IdeaController();
        controller.CurrentUser = new IdeaUserHelper('123456');
        ApexPages.currentPage().getParameters().put('id', idea.id);
        PageReference nextPage = controller.Load();
        system.assertEquals(nextPage, null);
        
        system.debug('##IdeaController_TestMyVote>controller.SingleIdea: ' + controller.SingleIdea);
        system.assertEquals(controller.SingleIdea.WrappedItem.id, idea.id);
        system.assertEquals(controller.SingleIdea.Title, idea.Title__c);
        system.assertEquals(controller.SingleIdea.TotalComments, 1);
        system.assertEquals(controller.SingleIdea.HasMyVote, true);
    }
    
    static testMethod void IdeaListController_TestLoad(){
        User user = CreateTestUser('TestUser');
        Contact contact = CreateTestContact(user, '123456');
        user.Finance_Code__c = '123456';
        update user;
        Advisory_Idea__c idea = new Advisory_Idea__c();
        idea.Title__c = 'Title';
        idea.High_Level_Description__c = 'Description';
        idea.Implementation_Date__c = 'Date';
        insert idea;
        Advisory_Idea_Comment__c comment = new Advisory_Idea_Comment__c(Advisory_Idea__c = idea.Id,
                                                                        Commented_By__c = contact.Id);
        IdeaWrapper ideaWrapper = new IdeaWrapper(idea, contact.Id);
        
        IdeaListController controller = new IdeaListController();
        controller.CurrentUser = new IdeaUserHelper('123456');
        ApexPages.currentPage().getParameters().put('id', idea.id);
        ApexPages.currentPage().getParameters().put('show', 'id');
        PageReference nextPage = controller.Load();
        system.assertEquals(nextPage, null);
        
        IdeaWrapper idea1 = controller.IdeaWrappers.get(0);
        system.debug('##IdeaListController_TestLoad>idea1: ' + idea1);
        system.assertEquals(idea1.WrappedItem.id, idea.id);
        system.assertEquals(idea1.HasMyVote, false);
        
        system.assertEquals(controller.counter, 0);
		system.assertEquals(controller.total_size, 1);  
		system.assertEquals(controller.DisablePrevious, true);
        system.assertEquals(controller.DisableNext, true);
        system.assertEquals(controller.PageNumber, 1);
        system.assertEquals(controller.TotalPages, 1);
        system.assertEquals(controller.Filter, 'id');
        system.assertEquals(IdeaListController.TopRated5.size(), 0);
        
        controller.Beginning();
        controller.Previous();
        controller.Next();
        controller.End();
    }
    
    static testMethod void IdeaListController_TestVote(){
        User user = CreateTestUser('TestUser');
        Contact contact = CreateTestContact(user, '123456');
        user.Finance_Code__c = '123456';
        update user;
        Advisory_Idea__c idea = new Advisory_Idea__c();
        idea.Title__c = 'Title';
        idea.High_Level_Description__c = 'Description';
        idea.Implementation_Date__c = 'Date';
        insert idea;
        
        string result = IdeaListController.Vote(idea.id, contact.id);
      	system.assertEquals(result, '');
        
        Advisory_Idea__c item = [SELECT Id, Title__c, Volunteer_Opportunities__c, Goal_Impact_Potential__c,
                                 High_Level_Description__c, Problem_or_Need_this_Addresses__c,
                                 Implementation_Date__c, Comments_Count__c, CreatedDate, TopIdea__c, Score__c,
                                 (SELECT Id, Comment__c, Commented_By__c, CreatedDate FROM Advisory_Idea_Comments__r ORDER BY CreatedDate desc),
                                 (SELECT Voted_By__c FROM Advisory_Idea_Votes__r)
                                 FROM Advisory_Idea__c WHERE Id = :idea.id LIMIT 1];
        IdeaWrapper ideaWrapper = new IdeaWrapper(item, contact.id);
        system.assertEquals(ideaWrapper.HasMyVote, true);
        
        string result2 = IdeaListController.Vote(idea.id, contact.id);
        system.assertNotEquals(result2, '');
    } 

    static testMethod void IdeaListController_TestPostComment(){
        User user = CreateTestUser('TestUser');
        Contact contact = CreateTestContact(user, '123456');
        user.Finance_Code__c = '123456';
        update user;
        Advisory_Idea__c idea = new Advisory_Idea__c();
        idea.Title__c = 'Title';
        idea.High_Level_Description__c = 'Description';
        idea.Implementation_Date__c = 'Date';
        insert idea;
        
        string result = IdeaListController.PostComment(idea.id, contact.id, 'Comment 1');
      	system.assertEquals(result, '');
        
        string result2 = IdeaListController.PostComment(idea.id, contact.id, 'Comment 2');
        system.assertEquals(result2, '');
        
        Advisory_Idea__c item = [SELECT Id, Title__c, Volunteer_Opportunities__c, Goal_Impact_Potential__c,
                                 High_Level_Description__c, Problem_or_Need_this_Addresses__c,
                                 Implementation_Date__c, Comments_Count__c, CreatedDate, TopIdea__c, Score__c,
                                 (SELECT Id, Comment__c, Commented_By__c, CreatedDate FROM Advisory_Idea_Comments__r ORDER BY CreatedDate desc),
                                 (SELECT Voted_By__c FROM Advisory_Idea_Votes__r)
                                 FROM Advisory_Idea__c WHERE Id = :idea.id LIMIT 1];
        IdeaWrapper ideaWrapper = new IdeaWrapper(item, contact.id);
        system.assertEquals(ideaWrapper.TotalComments, 2);
    } 

    static testMethod void IdeaBaseController_TestLoginRedirect() {
        IdeaListController controller = new IdeaListController();
        
        PageReference nextPage = controller.Load();
        system.assertEquals(nextPage.getUrl(), IdeaBaseController.LoginUrl);
        
        ApexPages.currentPage().getParameters().put('id', '123456');
        PageReference nextPage2 = controller.Load();
        system.assertEquals(nextPage2.getUrl(), IdeaBaseController.LoginUrl + '?id=123456');        
    }

    static testMethod void IdeaBaseController_TestAfterAuthRedirect() {
        User user = CreateTestUser('TestUser');
        Contact contact = CreateTestContact(user, '123456');
        user.Finance_Code__c = '123456';
        update user;
        
        IdeaListController controller = new IdeaListController();
        controller.CurrentUser = new IdeaUserHelper('123456');

        ApexPages.currentPage().getParameters().put('u', 'something');
        ApexPages.currentPage().getParameters().put('id', '1234567890');
        PageReference nextPage = controller.Load();
        system.assertEquals(nextPage.getUrl(), controller.HomePageUrl + '?id=1234567890');        
    }
    
    static testMethod void IdeaAuthController_TestSSO(){
        User user = CreateTestUser('TestUser');
        user.Finance_Code__c = '123456';
        update user;
        
        System.runAs(user) {
            IdeaAuthController controller = new IdeaAuthController();
            
            PageReference nextPage = controller.Load();
            system.assertNotEquals(nextPage, null);
            
            String encrypted = nextPage.getParameters().get('u');
            String secret = IdeaBaseController.Decrypt(EncodingUtil.base64Decode(encrypted));
            system.assertEquals(secret, user.Finance_Code__c);
        }
    }
    
    private static User CreateTestUser(String name) {
        Profile p = [select id from profile where name='System Administrator'];
        
        User user = new User(alias = name, email = name + '@asdfg.junk', emailencodingkey = 'UTF-8',
                             firstName = 'Test', lastname = name, languagelocalekey = 'en_US', localesidkey = 'en_US',
                             profileid = p.Id, timezonesidkey = 'America/Los_Angeles', username = name + '@asdfg.junk');
        
        insert user;
        system.debug('##IdeaListController_Test>CreateTestUser: ' + user);
        
        return user;
    }
    
    private static Contact CreateTestContact(User user, String employeeId) {
        util.BypassAllTriggers = true;
        
        Id ExternalRecordType = Util.recordtypemap('Contact').get('Employee');
        if (ExternalRecordType == null) {
            // reset record type settings
            Util.resetRecordtypeSettings();
            ExternalRecordType = Util.recordtypemap('Contact').get('Employee');
        }
        Account acct = TestUtilities.CreateNewAccount(true);
        
        Contact cont = new Contact(email = user.Email, firstName = user.FirstName, LastName=user.LastName,
                                   RecordTypeId = ExternalRecordType, Employee_User_Record__c = user.Id, AccountId = acct.Id);
        insert cont;
        system.debug('##IdeaListController_Test>CreateTestContact: ' + cont);
        
        return cont;
    }
}