/**
 *  Purpose            :  	This class is used to draw Feed table on "Request Feed Transmission" page.
 *
 *  Created By         :   	Subhash Garhwal
 *
 *  Created Date       :   	12/30/2015
 *
 *  Current Version    :   	V_1.0
 *
 *  Revision Log       :   	V_1.0 - Created - CR-20151216-9464
 *
 **/
public with sharing class RequestFeedTransmissionWrapper {
	
	//Properties
	public String fGName {get;set;}
	public List<FeedGroupWrapper> feedGroupWrapperList {get;set;}
	
	//Constructor
    public RequestFeedTransmissionWrapper(String fGName, List<FeedGroupWrapper> feedGroupWrapperList){
    	
    	//Set values
    	this.fGName = fGName;
    	this.feedGroupWrapperList = feedGroupWrapperList;
    }
	
    //Wrapper class to hold the Feed Dynamic header
    public class FeedGroupWrapper implements Comparable {
        
        //Properties
        public Feed__c feedRecord {get;set;}
        public Boolean selected {get;set;}
        
        //Constructor
        public FeedGroupWrapper(Feed__c feedRecord) {
            
            //Set Values
            this.feedRecord = feedRecord;
            
            //Set defaults
            selected = true; 
        }
        
        // Implement the compareTo() method
	    public Integer compareTo(Object compareTo) {
	    
	        FeedGroupWrapper compareToEmp = (FeedGroupWrapper)compareTo;
	        
	        if (feedRecord.Name == compareToEmp.feedRecord.Name) return 0;
	        if (feedRecord.Name > compareToEmp.feedRecord.Name) return 1;
	        return -1;        
	    }
    }	
}