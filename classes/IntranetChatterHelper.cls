/**
 * 	Purpose			:	This class is to hold all the helper methods for Intranet Chatter
 * 
 * 	Created By		:	Bhavi Sharma
 * 
 * 	Created Date	:	09/12/2014
 * 
 * 	Revision Logs	:	V_1.0 - Created
 **/ 
public with sharing class IntranetChatterHelper {
	
	/**
	 *	@description	:	This method is to create a FeedItem based on the input 
	 * 
	 * 	@args			:	Parent Id, Feed body
	 * 
	 * 	@return			:	FeedItem instance
	 * 
	 **/
	public static FeedItem CreateFeedItem(Id parentId, String contentBody) {
		
		//Feed Item
		FeedItem feedItem;
		
		//Create a new feed
		if(parentId != null && String.isNotBlank(contentBody)) {
			
			feedItem = new FeedItem(ParentId = parentId, Body = contentBody);
			insert feedItem;
		}
		
		//return
		return feedItem;
	}  
}