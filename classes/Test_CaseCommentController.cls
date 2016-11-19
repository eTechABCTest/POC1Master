/**
 *  Purpose         :   This class is used to test the CaseCommentController class
 *
 *  Created By      :   Victor Hanson
 *
 *  Created Date    :   02/21/2014
 *
 *  Current Version :   v1.0 - Created
 **/
@isTest
private class Test_CaseCommentController{
    
    static testmethod void testCommentController_Save() {
    
        //Bypassing dupeblocker and triggers
        Util.isTest(true);
        Util.byPassAllTriggers = true;
        
        //Create test data for the Sync Fields custom setting that syncs Mem Support -> Case fields
        TestUtilities.createSyncFields();
        
        //Create a contact
        Contact contact = TestUtilities.CreateNewContact(false);
        contact.Email = 'testEmail@noreply.com';
        insert contact;
        
        //Create a project
        Project__c project = TestUtilities.createProject(true);
        
        //Create a member support record related to the project
        Site_Issue__c memberSupport = TestUtilities.createSiteIssue(project.Id, false);
        memberSupport.RecordTypeId = Constants.RECORD_TYPE_ID_SITE_ISSUE_CCA_SUPPORT_REQUEST;
        memberSupport.Reported_By__c = contact.Id;
        memberSupport.Status__c = '06 - Issue Resolved - Ticket Closed';
        
        //Enabling triggers again
        Util.byPassAllTriggers = false;
        
        //The member support trigger will create a related case
        insert memberSupport;
        
        //set the page reference
        PageReference pageRef = Page.CaseComment_MemberSupport;
        test.setCurrentPage(pageRef);
        
        //instantiate the controller and set the page
        ApexPages.standardController standardController = new ApexPages.standardController(memberSupport);
        CaseCommentController controller = new CaseCommentController(standardController);
        
        //Get the case related to the member support record
        Case msCase = [SELECT Id, Status, Member_Support_Ticket__c, ContactId FROM Case WHERE Member_Support_Ticket__c = :memberSupport.Id];
        
        if(msCase != null) {
        
            //Verify the case id matches the case in the controller
            system.assertEquals(msCase.Id, controller.msCase.Id);
            system.assertEquals(msCase.ContactId, contact.Id);
            
            //Set the comment body/comment type and Save
            controller.comment.CommentBody = 'test comment body - Input Required';
            controller.commentType = caseCommentController.COMMENT_TYPE_INPUT_REQUIRED;
            
            //Set isPublished to true
            controller.togglePublished();
            
            controller.save();
            
            //Set the comment body/comment type and Save
            controller.comment.CommentBody = 'test comment body - Email Member';
            controller.commentType = caseCommentController.COMMENT_TYPE_EMAIL_MEMBER;
            
            //Set isPublished to true
            controller.togglePublished();
            
            controller.save();
            
            if(ApexPages.getMessages().size() == 0) {
            
                //Get the caseComment, Case, and updated Member Support record
                memberSupport = [SELECT Id, Status__c FROM Site_Issue__c WHERE Id = :memberSupport.Id];
                msCase = [SELECT Id, Status FROM Case WHERE Id = :msCase.Id];
                list<CaseComment> comments = [SELECT Id, CommentBody, IsPublished FROM CaseComment WHERE ParentId = :msCase.Id];
            
                //assertions
                system.assertEquals(Constants.SITE_ISSUE_STATUS_MEMBER_INPUT_REQUESTED, memberSupport.Status__c);
                system.assertEquals(CaseTriggerHelper.memSupportToCaseStatus_SupportRT_Map.get(Constants.SITE_ISSUE_STATUS_MEMBER_INPUT_REQUESTED), 
                                    msCase.Status);
                system.assertEquals(true, comments[0].IsPublished);
                system.assertEquals(2, comments.size());
            }
        }
    }
    
    static testmethod void testCommentController_Save_Error() {
        
        //Bypassing dupeblocker and triggers
        Util.isTest(true);
        Util.byPassAllTriggers = true;
        
        //Create test data for the Sync Fields custom setting that syncs Mem Support -> Case fields
        TestUtilities.createSyncFields();
        
        //Create a project
        Project__c project = TestUtilities.createProject(true);
        
        //Create a member support record related to the project
        Site_Issue__c memberSupport = TestUtilities.createSiteIssue(project.Id, false);
        memberSupport.RecordTypeId = Constants.RECORD_TYPE_ID_SITE_ISSUE_CCA_SUPPORT_REQUEST;
        memberSupport.Status__c = '06 - Issue Resolved - Ticket Closed';
        
        //Enabling triggers again
        Util.byPassAllTriggers = false;
        
        //The member support trigger will create a related case
        insert memberSupport;
        
        //set the page reference
        PageReference pageRef = Page.CaseComment_MemberSupport;
        test.setCurrentPage(pageRef);
        
        //instantiate the controller and set the page
        ApexPages.standardController standardController = new ApexPages.standardController(memberSupport);
        CaseCommentController controller = new CaseCommentController(standardController);
        
        //Get the case related to the member support record
        Case msCase = [SELECT Id, Status, Member_Support_Ticket__c FROM Case WHERE Member_Support_Ticket__c = :memberSupport.Id];
        
        if(msCase != null) {
        
            //Verify the case id matches the case in the controller
            system.assertEquals(msCase.Id, controller.msCase.Id);
            
            //Set the comment body = null and Save
            controller.comment.CommentBody = null;
            controller.commentType = caseCommentController.COMMENT_TYPE_INPUT_REQUIRED;
            controller.save();
            
            //verify that there was an error since the commentBody is null
            system.assertEquals(1, ApexPages.getMessages().size());
            
            //verify there are 3 options available in the commentTypeList
            system.assertEquals(3, controller.commentTypeList.size());
        }
    }
    
    static testmethod void testCommentController_CommentList() {
        
        //Bypassing dupeblocker and triggers
        Util.isTest(true);
        Util.byPassAllTriggers = true;
        
        //Create test data for the Sync Fields custom setting that syncs Mem Support -> Case fields
        TestUtilities.createSyncFields();
        
        //Create a project
        Project__c project = TestUtilities.createProject(true);
        
        //Create a member support record related to the project
        Site_Issue__c memberSupport = TestUtilities.createSiteIssue(project.Id, false);
        memberSupport.RecordTypeId = Constants.RECORD_TYPE_ID_SITE_ISSUE_CCA_SUPPORT_REQUEST;
        memberSupport.Status__c = '06 - Issue Resolved - Ticket Closed';
        
        //Enabling triggers again
        Util.byPassAllTriggers = false;
        
        //The member support trigger will create a related case
        insert memberSupport;
        
        //Get the case related to the member support record
        Case msCase = [SELECT Id, Status, Member_Support_Ticket__c FROM Case WHERE Member_Support_Ticket__c = :memberSupport.Id];
        
        if(msCase != null) {
        
            //Add a couple of comments and associate them with the msCase
            CaseComment comment_published = new CaseComment(commentBody = 'this is a published comment',
                                                            isPublished = true,
                                                            parentId = msCase.Id);
            CaseComment comment_private = new CaseComment(commentBody = 'this is an internal comment',
                                                          isPublished = false,
                                                          parentId = msCase.Id);
            list<CaseComment> caseCommentList = new list<CaseComment> { comment_published, comment_private };
            insert caseCommentList;
            
            //set the page reference
            PageReference pageRef = Page.CaseComment_MemberSupport;
            test.setCurrentPage(pageRef);
            
            //instantiate the controller and set the page
            ApexPages.standardController standardController = new ApexPages.standardController(memberSupport);
            CaseCommentController controller = new CaseCommentController(standardController);
            
            //Verify the case id matches the case in the controller
            system.assertEquals(msCase.Id, controller.msCase.Id);
            
            //Set the comment body = null and Save
            controller.comment.CommentBody = null;
            controller.commentType = caseCommentController.COMMENT_TYPE_INPUT_REQUIRED;
            controller.save();
            
            //verify that there are 2 comments in the wrapper list
            system.assertEquals(2, controller.commentWrapperList.size());
        }
    }
    
    static testmethod void testCommentController_Save_CustomController() {
        
        //Bypassing dupeblocker and triggers
        Util.isTest(true);
        Util.byPassAllTriggers = true;
        
        //Create test data for the Sync Fields custom setting that syncs Mem Support -> Case fields
        TestUtilities.createSyncFields();
        
        //Create a project
        Project__c project = TestUtilities.createProject(true);
        
        //create a contact
        Contact con = TestUtilities.CreateNewContact(true);
        
        //Create a member support record related to the project
        Site_Issue__c memberSupport = TestUtilities.createSiteIssue(project.Id, false);
        memberSupport.RecordTypeId = Constants.RECORD_TYPE_ID_SITE_ISSUE_CCA_SUPPORT_REQUEST;
        memberSupport.Reported_By__c = con.Id;
        memberSupport.Status__c = '06 - Issue Resolved - Ticket Closed';
        
        //Enabling triggers again
        Util.byPassAllTriggers = false;
        
        //The member support trigger will create a related case
        insert memberSupport;
        
        //Get the case related to the member support record
        Case msCase = [SELECT Id, Status, Member_Support_Ticket__c, ContactId FROM Case WHERE Member_Support_Ticket__c = :memberSupport.Id];
        
        if(msCase != null) {
        
            //Set currentpage parameters
            ApexPages.currentPage().getParameters().put('parent_Id', memberSupport.Id);
            ApexPages.currentPage().getParameters().put('userName', 'Mike');
            
            //instantiate the controller and set the page
            CaseCommentController controller = new CaseCommentController();
            
            //set the caseId
            controller.case_Id = msCase.Id;
            
            //Verify the case id matches the case in the controller
            system.assertEquals(msCase.Id, controller.msCase.Id);
            
            //Set the comment body/comment type and Save
            controller.comment.CommentBody = 'test comment body - Email Member';
            controller.commentType = caseCommentController.COMMENT_TYPE_EMAIL_MEMBER;
            
            //Set isPublished to true
            controller.togglePublished();
            
            controller.save();
            
            //get the case comment
            list<CaseComment> caseComments = [SELECT Id, commentBody FROM CaseComment WHERE parentId = :msCase.Id];
            
            //verify that there is 1 comment in the list
            system.assertEquals(1, caseComments.size());
            system.assertEquals(true, caseComments[0].commentBody.contains('[Support Analyst: Mike]'),
                               'When userName is not null, the userName should be included in the Comment body in brackets '
                             + 'like "[Support Analyst: Mike]"');
        } 
    }
}