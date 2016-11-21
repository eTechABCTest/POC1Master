public without sharing class CaseCommentController {
	
    //Wrapper necessary to format the createdDateTime to the user's locale.  Otherwise it formats in GMT on the VF page.
    public class caseCommentWrapper {
        public CaseComment comment { get; set; }
        public string createdDateString { get; set; }
        public caseCommentWrapper(CaseComment comment) {
            this.comment = comment;
            this.createdDateString = comment.CreatedDate.format();
        }
    }
    
    //Constants and variables
    public static final string COMMENT_TYPE_INPUT_REQUIRED = 'Member_Input_Required';
    public static final string COMMENT_TYPE_EMAIL_MEMBER = 'Email_Member';
    public Site_Issue__c memberSupport { get; set; }
    public string commentType { get; set; }
    public string userName { get; set; }
    public Id case_Id { get; set; }
    public CaseComment comment { 
        get {
            if (comment == null) comment = new CaseComment();
            return comment;
        }
        set;
    }
    
    
    //Custom Constructor
    public CaseCommentController() {
        
        //Get the case
        Id memberSupportId = ApexPages.currentPage().getParameters().get('parent_id');
        userName = ApexPages.currentPage().getParameters().get('userName');
        
        //get the site issue if member support Id != null - Used on CaseComment_MemberSupport_Wrapper page
        if (memberSupportId != null)
        	memberSupport = [SELECT Id, Status__c FROM Site_Issue__c WHERE Id = :memberSupportId];
    }
    
    //Standard Constructor
    public CaseCommentController(ApexPages.StandardController controller) {
        
        //Get the siteIssue recordId
        memberSupport = (Site_Issue__c) controller.getRecord();
        userName = UserInfo.getName();
    }
    
    //Save the caseComment and perform any additonal actions that are necessary
    public pageReference Save() {
    	
        //String to hold any error messages
    	string errorMsg;
        
        if (comment.CommentBody == null || comment.CommentBody == '') {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Comment: You must enter a value'));
			return null;
        }
        
        //Set a savepoint in case the memSupport upserts but caseComment has errors
    	SavePoint sp = Database.setSavePoint();
        
        try {
        	
        	string prependText = '';
        	
        	if (userName != null)
            	prependText = '[Support Analyst: ' + userName + '] ';
            
            if (commentType == COMMENT_TYPE_INPUT_REQUIRED) {
            	
            	//If case is closed, do not allow the Input Required comment type because it would re-open the case
            	if (msCase.isClosed) {
            		//Return errors to the VF Page
					ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 
						'Comment Type: Member Input Required is not allowed after the case has been closed.'));
					return null;
            	}
            	
            	//Update the member support status with input required
                memberSupport.Status__c = Constants.SITE_ISSUE_STATUS_MEMBER_INPUT_REQUESTED;
                memberSupport.Member_Information_Requested__c = system.now();
                update memberSupport;
                
                //Prepend the comment type
                prependText += '[Member Input Required]';
            }
            else if (commentType == COMMENT_TYPE_EMAIL_MEMBER) {
            	
            	//Prepend the comment type
                prependText += '[Email Sent To Member]';
            }
            
            //prepend the user name if applicable
            if (prependText != null)
            	comment.CommentBody = prependText + '\r\n' + comment.CommentBody;
            
            comment.ParentId = msCase.Id;
            insert comment;
        }
        catch(DMLException ex) {
			//Return DML errors to the VF Page
			errorMsg = ex.getDMLMessage(0) + ex.getStackTraceString();
		}
		catch(Exception ex) {
			//Return any errors to the VF Page
			errorMsg = ex.getMessage() + ex.getStackTraceString();
		}
        
        if (errorMsg != null) {
            //Rollback the transaction
			database.rollback(sp);
            
			//Return errors to the VF Page
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, errorMsg));
			return null;
		}
        
        //Refresh the list of case comments if the save was successful
        commentWrapperList = null;
        
        //Clear the caseComment contents
        clearComment();
        
        return null;
    }
    
    //Clear the comments and comment type
    public void clearComment() {
        comment = null;
        commentType = '';
    }
    
    //Get the case
    public Case msCase {
        get {
            if (msCase == null) {
                msCase = new Case();
                list<Case> caseList = new list<Case>();
                if (case_Id != null) {
                	caseList = [SELECT Id, Subject, Description, CaseNumber, ContactId, IsClosed, Member_Support_Ticket__c,
                                	(SELECT CommentBody, CreatedBy.Name, CreatedDate 
                                         FROM CaseComments
                                         WHERE IsPublished = true
                                         ORDER BY CreatedDate DESC)
   							  FROM Case WHERE Id = :case_Id];
                }
                else {
	                caseList = [SELECT Id, ContactId, Contact.FirstName, CaseNumber, Description, Subject, Status, IsClosed
	                                       FROM Case WHERE Member_Support_Ticket__c = :memberSupport.Id];
                }
                if (caseList.size() > 0) msCase = caseList[0];
            }
            
            return msCase;
        }
        set;
    }
    
    //List of case comments associated with the member support record
    public list<caseCommentWrapper> commentWrapperList { 
        get {
            if (commentWrapperList == null) {
                list<CaseComment> commentList = [SELECT Id, ParentId, CommentBody, IsPublished, CreatedById, CreatedBy.Name, CreatedDate
                                                 FROM CaseComment
                                                 WHERE ParentId = :msCase.Id ORDER BY CreatedDate DESC];
                commentWrapperList = new list<caseCommentWrapper>();
                for (CaseComment caseComment : commentList) commentWrapperList.add(new caseCommentWrapper(caseComment));
            }
            return commentWrapperList;
        }
        set;
    }
    
    public void togglePublished() {
        if (commentType == COMMENT_TYPE_INPUT_REQUIRED || commentType == COMMENT_TYPE_EMAIL_MEMBER)
        	comment.IsPublished = true;
    }
    
    //Options for the Comment Type picklist
    public list<selectOption> commentTypeList {
        get {
            if (commentTypeList == null) {
                commentTypeList = new list<selectOption>();
                commentTypeList.add(new selectOption('', 'Case Comment'));
                commentTypeList.add(new selectOption(COMMENT_TYPE_INPUT_REQUIRED, 'Member Input Required'));
                commentTypeList.add(new selectOption(COMMENT_TYPE_EMAIL_MEMBER, 'Send Email to Member'));
            }
            return commentTypeList;
        }
        set;
    }
}