public without sharing class IdeaController extends IdeaBaseController {
    public IdeaWrapper SingleIdea { get; set; }
    public List<IdeaCommentWrapper> IdeaCommentWrappers { get; set; }
    public IdeaCommentWrapper NewCommentWrapper { get; set; }
    public Attachment NewAttachment { get; set; }

    public List<Attachment> IdeaAttachments {
        get {
            if (IdeaAttachments == null) {
                IdeaAttachments = [SELECT Id, Name, Description FROM Attachment
                                    WHERE ParentId = :SingleIdea.WrappedItem.Id ORDER BY Name];
            }
            return IdeaAttachments;
        }
        private set;
    }

    public override PageReference Load() {
        PageReference pageRef = super.Load();
        if(pageRef != null) {
            return pageRef;
        }

        String Id = ApexPages.currentPage().getParameters().get('id');
        if (Id != null) {
            GetIdeaById(Id);
        } else {
           /*
           pageRef = new PageReference(HomepageUrl);
           pageRef.setRedirect(true);
           return pageRef;
           */
        }
        return null;
    }

    private void GetIdeaById(String id) {

        Advisory_Idea__c item = [SELECT Id, Title__c, Volunteer_Opportunities__c, Goal_Impact_Potential__c,
                                 High_Level_Description__c, Problem_or_Need_this_Addresses__c,
                                 Implementation_Date__c, Comments_Count__c, CreatedDate, TopIdea__c, Score__c,
                                 (SELECT Id, Comment__c, Commented_By__c, CreatedDate FROM Advisory_Idea_Comments__r ORDER BY CreatedDate desc),
                                 (SELECT Voted_By__c FROM Advisory_Idea_Votes__r)
                                 FROM Advisory_Idea__c WHERE Id = :Id LIMIT 1];

        SingleIdea = new IdeaWrapper(item, CurrentUser.ContactId);
        system.debug('##GetIdeaById: ' + SingleIdea);

        IdeaCommentWrappers = new List<IdeaCommentWrapper>();
        if(item.Advisory_Idea_Comments__r.size() > 0) {
            List<Id> commenterIds = new List<Id>();
            for(Advisory_Idea_Comment__c comment : item.Advisory_Idea_Comments__r){
                commenterIds.add(comment.Commented_By__c);
            }
            Map<Id,Contact> contacts = new Map<ID,Contact>([SELECT Id, Email, Name, Employee_User_Record__c
                FROM Contact WHERE Id IN :commenterIds]);
            List<Id> userIds = new List<Id>();
            for(Contact c : contacts.values()) {
                userIds.add(c.Employee_User_Record__c);
            }
            Map<Id,User> users = new Map<ID,User>([SELECT Id, SmallPhotoUrl FROM User WHERE Id IN :userIds]);
            for(Advisory_Idea_Comment__c comment : item.Advisory_Idea_Comments__r){
                IdeaCommentWrapper wrapper = new IdeaCommentWrapper(comment, contacts, users, CurrentUser.ContactId);
                IdeaCommentWrappers.add(wrapper);
            }
        }

        if(NewCommentWrapper == null) {
            NewCommentWrapper = new IdeaCommentWrapper(id, CurrentUser);
        }
        system.debug('##GetIdeaById: ' + IdeaCommentWrappers);

        NewAttachment = new Attachment (ParentId = id);
    }
}