/**
 *  Purpose            :    This class is used to for "Request Feed Transmission" page.
 *
 *  Created By         :    Subhash Garhwal
 *
 *  Created Date       :    12/30/2015
 *
 *  Current Version    :    V_1.0
 *
 *  Revision Log       :    V_1.0 - Created - Feed Management - CR-20151216-9464
 *
 **/
public without sharing class RequestFeedTransmissionController {

	//Properties
    public List<String> headers {get;set;}
    public List<RequestFeedTransmissionWrapper> requestedFeeds {get;set;}
    public String selectedView {get; set;}
    public Date selectedDate {get; set;}
    public String selectedTime {get;set;}
    public String selectedTP {get;set;}
    public Feed__c feedInstance {get;set;}
    public Boolean isReadyOnly {get;set;}
    public Boolean isSuccess{get;set;}
    public static final String SUCCESS_MSG = 'Feed request successfully submitted.';
    String retURL;
    
    //Get View
	public List<SelectOption> views {
    	get {
            
            List<SelectOption> viewOptions = new List<SelectOption>();
            
            //Add in list
            viewOptions.add(new SelectOption('Now', 'Now'));
            viewOptions.add(new SelectOption('Custom', ''));
            
            //Return
            return viewOptions;
        }
    }
    
	//Get Time
    public List<SelectOption> timeViews {
    	get {
    		//Return
            return ISSPConstants.TIMEOPTIONS;
        }
    }
    
	//Get View
    public List<SelectOption> aMPMOptions {
        
    	get {
            //Return
            return ISSPConstants.AMPMOPTIONS;
        }
    }
        
    //Constructor
    public RequestFeedTransmissionController() {
    	
    	//Get the URL
    	retURL = ApexPages.currentPage().getParameters().get('returnURL');
        
        //inIt
        inIt();
    }
    
    /**
     *  @description    :   This method is to load all the inital properties
     *
     *  @param          :
     *
     *  @return         :   void
     **/
    public void inIt(){
        
        //Initialize properties
        requestedFeeds = new List<RequestFeedTransmissionWrapper>();
        headers = new List<String>();
        feedInstance = new Feed__c(Feed_Date_Temp__c = Date.today().addDays(1));
        isReadyOnly = false;
        
        //Set defaults
        selectedView = 'Now';
        selectedTime = '2:00';
        selectedTP = 'AM';
        
        //Query on the Profile
        List<Profile> profiles = [Select Id From Profile Where Name =: ISSPConstants.PROFILE_SYSTEM_ADMINISTRATOR LIMIT 1];
        
        //Query through the PermissionSetAssignment to check if Master Feed Manager Permission set is assigned to current user.
        List<PermissionSetAssignment> permissionSetAssignments = [Select PermissionSetId From PermissionSetAssignment Where AssigneeId =: UserInfo.getUserId()
        																 AND PermissionSet.Name =: ISSPConstants.PERMISSION_SET_MASTER_FEED_MANAGER];
		
		//Check for list size
		if(permissionSetAssignments.size() == 0 && (profiles.size() == 0 || profiles[0].Id != UserInfo.getProfileId()))
			isReadyOnly = true;
        
        //Call Method
        loadFeedData();
    }
    
    /**
     *  @description    :   This method is used to load the personal goal data
     *
     *  @args           :
     *
     *  @return         :   void
     *
     **/
    public void loadFeedData() {
        
        //Re-Initialize properties
        requestedFeeds = new List<RequestFeedTransmissionWrapper>();
        headers = new List<String>();
        
        //Ma to hold the list of Feeds with Feed Group
        Map<String, List<RequestFeedTransmissionWrapper.FeedGroupWrapper>> mapFeedsWithFG = new Map<String, List<RequestFeedTransmissionWrapper.FeedGroupWrapper>>();
        
        //Query on Feed
        //Criteria
        //1. Feed Items with at least 1 feed item
        for(Feed__c fD : [Select Id, Name, Execution_Requested__c, Feed_Group__c From Feed__c Where Feed_Items__c >= 1 AND Feed_Group__c != null ORDER BY Feed_Group__c ASC]){
            
            //Check Group Name
            if(!mapFeedsWithFG.containsKey(fD.Feed_Group__c)){
                       
                //Add Header in list
                headers.add(fD.Feed_Group__c);
                
                //Put Value Corresponding to group
                mapFeedsWithFG.put(fD.Feed_Group__c, new List<RequestFeedTransmissionWrapper.FeedGroupWrapper>());        
            }
            //Add Feed record in map
            mapFeedsWithFG.get(fD.Feed_Group__c).add(new RequestFeedTransmissionWrapper.FeedGroupWrapper(fD));
        }
        
        //Variable to hold the map rows counter
        Integer maxRows = 0;
        
        //Loop through the map key set
        for(String fG : mapFeedsWithFG.keySet()) {
        	
        	//Check for size
        	if(maxRows < mapFeedsWithFG.get(fG).size())
        		maxRows = mapFeedsWithFG.get(fG).size();
        }
        
        //Loop over headers list
        //This loop is used to populate the feed list (List that is displying data on the page)
        for(String header : headers){
              
            //create new list
            List<RequestFeedTransmissionWrapper.FeedGroupWrapper> feedGroupsWrapper = new List<RequestFeedTransmissionWrapper.FeedGroupWrapper>();
            
            //Check header value in map
            if(mapFeedsWithFG.containsKey(header))
            	feedGroupsWrapper.addAll(mapFeedsWithFG.get(header));
            
            //Sort
            feedGroupsWrapper.sort();
            
            //Get Size
            Integer rowsSize = mapFeedsWithFG.get(header).size();  
              
            //Loop Over mapFeedsWithFG keyset
            for(Integer i = rowsSize; i < maxRows; i++)
                feedGroupsWrapper.add(new RequestFeedTransmissionWrapper.FeedGroupWrapper(new Feed__c()));
            
            //Add Group in the main wrapper list
            requestedFeeds.add(new RequestFeedTransmissionWrapper(header,feedGroupsWrapper));
        }
        
        System.debug('############ : ' +requestedFeeds);
    }
    
    /**
     *	@description	:	This method is used to perform the save logic
     *
     *	@args			:	
     *
     *	@return			:	Pagereference
     *
     **/
	public Pagereference doSave(){
		
		//Save Point to roll back changes
        Savepoint sp = Database.setSavepoint();
        
		try {
			
			//DateTime variable to update the Execution Requested
			DateTime executionRequestedDT;
			
			//Check for selected Submit Option
			if(String.isNotBlank(selectedView)) {
				
				//Check for option
				if(selectedView == ISSPConstants.EXECUTION_REQUESTED_NOW)
					executionRequestedDT = System.now();
				else {
					
					//Check for date
					if(feedInstance.Feed_Date_Temp__c == null)
						throw new CustomException(ISSPConstants.PLEASE_SELECT_DATE);
					
					//Integer to hold the Hours and Minutes
					Integer hours = Integer.valueOf(selectedTime.substringBefore(':'));
					Integer minutes = Integer.valueOf(selectedTime.substringAfter(':'));
					
					//Check for Time Period
					if(selectedTP == ISSPConstants.PM_TIME_PERIOD)
						hours += 12;
					
					//Create DateTime
					executionRequestedDT = DateTime.newInstance(feedInstance.Feed_Date_Temp__c, Time.newInstance(hours,minutes,0,0));
					
					//Check for DateTime
					if(executionRequestedDT < System.now())
						throw new CustomException(ISSPConstants.SELECTED_DATETIME_SHOULD_BE_IN_FUTURE);	
				}
				
				//List to update the Feed records
				List<Feed__c> feeds = new List<Feed__c>();
				
				//Loop through the Feed recods wrapper to update the Execution Requested
				for(RequestFeedTransmissionWrapper rFTW : requestedFeeds) {
					
					//Loop through the Feeds records
					for(RequestFeedTransmissionWrapper.FeedGroupWrapper fGW : rFTW.feedGroupWrapperList) {
						
						//Check if record is selected or not
						if(fGW.selected && fGW.feedRecord.Id != null && (fGW.feedRecord.Execution_Requested__c == null || fGW.feedRecord.Execution_Requested__c < executionRequestedDT)) {
							
							//Update Date
							fGW.feedRecord.Execution_Requested__c = executionRequestedDT;
							
							//Add record in list
							feeds.add(fGW.feedRecord);	
						}
					}
				}
				
				//Check for list
				if(feeds.size() > 0)
					update feeds;
				
				//Check for retURL
				/*if(String.isNotBlank(retURL))
					return new Pagereference(retURL);*/
				String successMsg = '';
                
                if(String.isNotBlank(retURL)){
                	successMsg = SUCCESS_MSG + ' Click' + '<a href="'+ retURL +'">here</a>' +'to go to previous page.';     
                }
                
                //Set to true
                isSuccess = true;
                
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, successMsg));
				return null;
			}
		}catch(Exception e) {
            
            //Roll Back changes
            Database.rollback(sp);
            
            isSuccess = false;
            
            //Add Error on page
            ApexPages.addMessages(e);
            return null;
        }
        
        return null;
	}
	
	//Cancel method
	public Pagereference doCancel() {
		
		//Check for retURL
		if(String.isNotBlank(retURL))
			return new Pagereference(retURL);
		
		return null;
	}
}