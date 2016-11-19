/**
    Purpose:    This controller is to override case new and edit functionaliry.(CR-4283)
                
    Create By:  Victor Hanson
    
    Created Date:   02/24/2014
    
    Revision Log:       v1 - VH - 02/24/2014 - Created
 **/
public without sharing class CaseListViewController{
	
    public final string LIST_VIEW_INPUT_REQUIRED = 'crimson_community_member_input_required';
    public final string LIST_VIEW_ALL_OPEN_CASES = 'crimson_community_all_open_cases';
    public final string LIST_VIEW_ALL_CLOSED_CASES = 'crimson_community_all_closed_cases';
    public final string LIST_VIEW_MY_OPEN_CASES = 'crimson_community_my_open_cases';
    public final string LIST_VIEW_MY_CLOSED_CASES = 'crimson_community_my_closed_cases';
    public final string CASE_STATUS_IN_PROGRESS = 'IN PROGRESS';
    public final string CASE_STATUS_RESPONSE_NEEDED = 'Response Needed';
    public final string CASE_STATUS_SOLUTION_PROVIDED = 'SOLUTION PROVIDED';
    
    public string fieldSetAPIName { get; set; }
    public string searchString { get; set; }
    public string selectedTileName { get; set; }
    public String SortExp = 'CaseNumber';
    public Integer size = 10;
    public integer numCases_All { get; set; }
    public integer numCases_New { get; set; }
    public integer numCases_In_Progress { get; set; }
    public integer numCases_Member_Response_Needed { get; set; }
    public integer numCases_Solution_Provided { get; set; }
    
    //Total number of records in the standard set controller
    public Integer NoOfRecords {
    	get {
    		return setCon.getResultSize();
    	}
    	set;
    }
    
    //Id of the Contact related to the portal user that is currently logged in
    public Id contactId {
    	get {
    		if (contactId == null && contact != null) contactId = contact.Id;
    		return contactId;
    	}
    	set;
    }
    
    //
    public string projectID {
    	get {
    		if (projectID == null) {
    			Community_Project_Source__c projSource = Community_Project_Source__c.getInstance(UserInfo.getUserId());
    			if (projSource != null) projectID = projSource.Project_Source_Id__c;
    		}
    		return projectID;
    	}
    	set;
    }
    public integer pageNo {
    	get {
    		pageNo = setCon.getPageNumber();
	    	//try {
	    		if (pageNoString != null && pageNoString.isNumeric()) {
	    			pageNo = integer.valueOf(pageNoString);
	    			//If the supplied value is outside the available range, set it to either the max or min available value
	    			if (pageNo > getTotalPages()) pageNo = getTotalPages();
	    			else if (pageNo < 1) pageNo = 1;
	    		}
	    	//}
	    	//catch(Exception ex) { }
	    	return pageNo;
    	}
    	set;
    }
    public string pageNoString {
    	get {
    		if (pageNoString == null) pageNoString = string.valueOf(setCon.getPageNumber());
    		return pageNoString;
    	}
    	set;
    }
    
    private void getCaseCountByStatus() {
    	
    	//Reset case counts
    	numCases_All = 0;
		numCases_New = 0;
		numCases_In_Progress = 0;
		numCases_Member_Response_Needed = 0;
		numCases_Solution_Provided = 0;
    	
    	string queryString = 'SELECT Id, Case_Status__c FROM Case WHERE IsClosed = false AND Visible_in_Portal__c = true ';
    	
    	if (fieldSetAPIName == LIST_VIEW_ALL_OPEN_CASES) {
	    	if (contact.PT_Community_Case_View__c == Constants.COMMUNITY_CASE_VIEW_ALL_PROJECT_CASES) {
	    		queryString += 'AND (ContactId = :contactId OR Member_Support_Ticket__c IN :memberSupportIdSet) ';
	    	}
    	}
    	else if (fieldSetAPIName == LIST_VIEW_MY_OPEN_CASES) {
    		queryString += 'AND ContactId = :contactId ';
    	}
    	else {
    		return;
    	}
    	
    	list<Case> cases = database.query(queryString);
    	
    	// loop through each case
    	for (Case c : cases) {
    		if (c.Case_Status__c == null) continue;
    		
			numCases_All++;
    		
    		if (c.Case_Status__c.equalsIgnoreCase('NEW')) {
    			numCases_New++;
    		}
    		else if (c.Case_Status__c.equalsIgnoreCase(CASE_STATUS_IN_PROGRESS)) {
    			numCases_In_Progress++;
    		}
    		else if (c.Case_Status__c.equalsIgnoreCase(CASE_STATUS_RESPONSE_NEEDED)) {
    			numCases_Member_Response_Needed++;
    		}
    		else if (c.Case_Status__c.equalsIgnoreCase(CASE_STATUS_SOLUTION_PROVIDED)) {
    			numCases_Solution_Provided++;
    		}
    	}
    }
    
    //Returns the fields from the specified field set
    private List<Schema.FieldSetMember> getFieldSetList(String fieldSetName, String ObjectName) {
        
        Schema.DescribeSObjectResult DescribeCaseSObj = Schema.SObjectType.Case;
        Schema.FieldSet fieldSetObj = DescribeCaseSObj.FieldSets.getMap().get(fieldSetName);
        return fieldSetObj.getFields(); 
    }
    
    //This method is to redicted the user on the appropriate page
    public PageReference redirect() {
        
        if (projectId != null) {
        	//get the contact from the custom setting
        	Community_Project_Source__c projSource = Community_Project_Source__c.getInstance(UserInfo.getUserId());
        	if (projSource == null) {
        		projSource = new Community_Project_Source__c(Name=UserInfo.getUserId(), Project_Source_Id__c=projectId);
        		upsert projSource;
        	}
        }
        
        //Create a new Pagereference instance
        PageReference pageRef = new pageReference('/');
        
        pageRef.setRedirect(false);
        
        return pageRef;
    }
    
    /**
     *  @description    :   Called in the Action portion of the Case_ListView VF page
     *						Redirect the user to the login page if the user comes to the list view page after their session has timed out
     *
     *  @args           :
     *
     *  @return         :   PageReference
     *
     **/
    public PageReference redirectToTimeout() {
    	
    	//if this is a guest user, direct them to the login page
        if (UserInfo.getUserType() == 'Guest') {
        	return Page.Timeout_PTCommunity;
        }
        
        return null;
    }
    
    //Constructor
    public CaseListViewController() {
        
        //Set the default view depending on whether or not the user can view all cases
        if (contact.PT_Community_Case_View__c == Constants.COMMUNITY_CASE_VIEW_ALL_PROJECT_CASES) {
       		fieldSetAPIName = LIST_VIEW_ALL_OPEN_CASES;
        }
        else {
        	fieldSetAPIName = LIST_VIEW_MY_OPEN_CASES;
        }
        
        //Get the project Id from the page url
        projectId = ApexPages.currentPage().getParameters().get('pid');
        
        //Default the current list page to 1
        pageNo = 1;
        
        //if there are no mem response needed cases, display in progress
		selectedTileName = CASE_STATUS_RESPONSE_NEEDED;
		if (setCon.getResultSize() == 0) {
			selectedTileName = CASE_STATUS_IN_PROGRESS;
			refresh();
		}
    }
    
    /**
     *  @description    :   Return the list of sObjects from 
     *
     *  @args           :
     *
     *  @return         :   PageReference
     *
     **/
    public list<Case> getCaseList() {
    	
    	if (setCon!= null) {
        	return (list<Case>) setCon.getRecords();
    	}
        	
        return new list<Case>();
    }
    
    private string orderByExpression {
    	get {
    		return ' ORDER BY ' + sortExpression + ' ' + sortDirection + ' LIMIT 900';
    	}
    	set;
    }
    
    public ApexPages.StandardSetController setCon {
        get{
            if(setCon == null){
            	
                string queryString = caseQuery +  whereClause + orderByExpression;
                
                setCon = new ApexPages.StandardSetController(Database.getQueryLocator(queryString));
                setCon.setPageSize(size);
                // get the record count for each case status
                getCaseCountByStatus();
            }
            return setCon;
        }set;
    }
    
    public string caseQueryFields {
    	get {
    		
    		//Add all fields in the field set to the query
    		string fieldAPINames = 'Project_Source_MS__r.Name, Id';
    		for(Schema.FieldSetMember fieldSetMemberObj : getFieldSetList(fieldSetAPIName, 'Case')) {
                if (fieldAPINames.length() > 0) fieldAPINames += ',';
                fieldAPINames += fieldSetMemberObj.getFieldPath();
            }
    		return fieldAPINames;
    	}
    	set;
    }
    
    public string caseQuery {
        get {
            if (caseQuery == null) {
                caseQuery = 'SELECT ' + caseQueryFields + ' FROM Case ';
            }
            return caseQuery;
        }
        set;
    }
    
    //Determines the where clause for the case query
    public string whereClause {
        get {
            if (whereClause == null) {
                
                //Get Cases associated with these member support records
                whereClause = 'WHERE ';
                
                if (fieldSetAPIName == LIST_VIEW_ALL_OPEN_CASES) {
                	if (contact.PT_Community_Case_View__c == Constants.COMMUNITY_CASE_VIEW_ALL_PROJECT_CASES) {
                		whereClause += '(ContactId = :contactId OR Member_Support_Ticket__c IN :memberSupportIdSet) ';
                	}
                	else {
                		whereClause += 'ContactId = :contactId ';
                	}
                        whereClause += 'AND IsClosed = false ';
                    
                    if (!selectedTileName.equalsIgnoreCase('ALL')) {
                    	 whereClause += 'AND Case_Status__c = \'' + selectedTileName + '\'';
                    }
                }
                else if (fieldSetAPIName == LIST_VIEW_ALL_CLOSED_CASES) {
                    whereClause += '(ContactId = :contactId OR Member_Support_Ticket__c IN :memberSupportIdSet) ' +
                        			'AND IsClosed = true ';
                }
                else if (fieldSetAPIName == LIST_VIEW_MY_OPEN_CASES) {
                    whereClause += 'ContactId = :contactId AND IsClosed = false ';
                    if (!selectedTileName.equalsIgnoreCase('ALL')) {
                    	 whereClause += 'AND Case_Status__c = \'' + selectedTileName + '\'';
                    }
                }
                else if (fieldSetAPIName == LIST_VIEW_MY_CLOSED_CASES) {
                    whereClause += 'ContactId = :contactId AND IsClosed = true ';
                }
                
                //Only display those cases where visible in portal is true
                whereClause += ' AND Visible_in_Portal__c = true ';
            }
            
            return whereClause;
        }
        set;
    }
    
    //Take the user to a specific page of pageinated results
    public void goToPage() {
    	caseQuery = null;
        setCon = null;
        whereClause = null;
        setCon.setPageNumber(pageNo);
    }
    
    //Refresh the list that is displayed
    public void refresh() {
    	caseQuery = null;
        setCon = null;
        whereClause = null;
        setCon.setPageNumber(1);
        pageNoString = '1';
    }
    
    public String sortExpression {
		get {
			return sortExp;
		}
     	set {
			//if the column is clicked on then switch between Ascending and Descending modes
			if (value == sortExp)
				sortDirection = (sortDirection == 'ASC')? 'DESC' : 'ASC';
			else
				sortDirection = 'ASC';
			sortExp = value;
		}
	}
    
    public String sortDirection {
		get {
			//if not column is selected 
			if (sortExpression == null || sortExpression == '' || sortDirection == null)
				return 'ASC';
            
			return sortDirection;
		}
		set;
		
	}
    
    //Picklists visible only to contacts where PT Community Case View = 'All Project Cases'
    private set<string> viewForAllProjContacts {
    	get {
    		if (viewForAllProjContacts == null) {
    			viewForAllProjContacts = new set<string> { LIST_VIEW_ALL_OPEN_CASES, LIST_VIEW_ALL_CLOSED_CASES };
    		}
    		return viewForAllProjContacts;
    	}
    	set;
    }
    
    public Contact contact {
    	get {
    		if (contact == null) {
    			contact = new Contact();
    			//Get the current user's contact
	        	contactId = [SELECT Id, ContactId FROM User WHERE Id = :UserInfo.getUserId()].ContactId;
	        	list<Contact> contacts = [SELECT Id, PT_Community_Case_View__c FROM Contact WHERE Id = :contactId];
	        	if (contacts.size() > 0) contact = contacts[0];
    		}
    		return contact;
    	}
    	set;
    }
    
    //Options for the Comment Type picklist
    public list<selectOption> viewPicklist {
        get {
            if (viewPicklist == null) {
                viewPicklist = new list<selectOption>();
                
                map<string, Schema.FieldSet> fieldSetMap = Schema.SObjectType.Case.FieldSets.getMap();
                for (string key : fieldSetMap.keySet()) {
                    
                    //Don't display the Input_Required list view because users should only see this when they first click on the cases tab
                    //Also, only display the ALL Open/Closed views if the PT Community Case View for that contact is set to view all project cases
                    if (key.equalsIgnoreCase(LIST_VIEW_INPUT_REQUIRED)
                    || (   viewForAllProjContacts.contains(key) 
                        && contact.PT_Community_Case_View__c != Constants.COMMUNITY_CASE_VIEW_ALL_PROJECT_CASES))
                    {
                    	continue;
                    }
                    	
                    	
                    viewPicklist.add(new selectOption(key, fieldSetMap.get(key).getLabel()));
                }
            }
            return viewPicklist;
        }
        set;
    }
    
    public set<Id> memberSupportIdSet {
    	 get {
    	 	if (memberSupportIdSet == null) {
    	 		memberSupportIdSet = new set<Id>();
    	 		
	    	 	//Get project roles
	            list<Project_Role__c> projectRoles = [SELECT Project__r.Id, Project__r.Name FROM Project_Role__c 
	                                                  WHERE Contact__c = :contactId
	                                                  AND Contact__c != null];
	            set<Id> projectIdSet = new set<Id>();
	            for (Project_Role__c pRole : projectRoles) projectIdSet.add(pRole.Project__c);
	            //Get member support records associated with these projects
	            list<Site_Issue__c> memberSupportList = [SELECT Id FROM Site_Issue__c WHERE Project__c IN :projectIdSet];
	            
	            for (Site_Issue__c ms : memberSupportList) memberSupportIdSet.add(ms.Id);
    	 	}
    	 	return memberSupportIdSet;
    	 }
    	 set; 
    }
	
	// returns the page number of the current page set
	public Integer ListStartNo {
		get {
			ListStartNo = ((setCon.getPageNumber() * size) - (size-1));
			return ListStartNo;
		}
		set;
	}
    
    // returns the page number of the current page set
	public Integer ListEndNo {
		get {
			ListEndNo = (setCon.getPageNumber() * size);
			if (ListEndNo > NoOfRecords)
				ListEndNo = NoOfRecords;
			return ListEndNo;
		}
		set;
	}
    
    public pageReference newCase() {
        PageReference pg = Page.Case_Edit_PTCommunity;
		pg.getParameters().put('retURL', ApexPages.currentPage().getUrl());
        return pg;
    }
    
    public Integer getTotalPages() {
    	decimal dtotalPages = (setCon.getResultSize() / setCon.getPageSize());
        dtotalPages = Math.floor(dtotalPages) + ((Math.mod(setCon.getResultSize(), setCon.getPageSize())>0) ? 1 : 0);
    	return Integer.valueOf(dtotalPages);
    }
    
    /** search for cases **/
    public pageReference search() {
    	
    	//clear the current search results and prepare to retreive the new results
    	refresh();
    	
        String querySOSL='';
        String querySQL=''; 
        String caseQry = '';
        if (searchString != null) searchString = string.escapeSingleQuotes(searchString);
        
        querySQL = caseQuery;
        caseQry += caseQueryFields + ' WHERE Visible_in_Portal__c = true AND ';
        if (contact.PT_Community_Case_View__c == Constants.COMMUNITY_CASE_VIEW_ALL_PROJECT_CASES) {
    		caseQry += '(ContactId = :contactId OR Member_Support_Ticket__c IN :memberSupportIdSet) ';
    	}
    	else {
    		caseQry += 'ContactId = :contactId ';
    	}
    	
        querySOSL = 'FIND\'*' + searchString + '*\'IN ALL FIELDS RETURNING Case(' + caseQry + ')';
        
        List<List<SObject>>  resultListOfList = search.query(querySOSL);
        
        if(resultListOfList[0] != null && resultListOfList[0].size() > 0){
        	
            querySQL += ' where id in (' + getRecordIds(resultListOfList[0]) + ') '
            			+ orderByExpression;
            
            setCon = new ApexPages.StandardSetController(Database.getQueryLocator(querySQL));
            setCon.setPageSize(size);
        }
        
        PageReference pg = Page.Case_Search_PTCommunity;
        pg.setRedirect(false);
        return pg;
    }
    
    public void refreshSearch() {
    	search();
    }
    
    /** method to concatenate ids of search results **/
   private string getRecordIds(List<SObject> sObjectList){
        string ids ='';integer i=0;
        for(SObject nextObj:sObjectList){
            if (ids.length() > 0) ids += ',';
            ids=ids+'\''+ nextObj.id + '\'';
        }
        return ids;
    
   }
    
}