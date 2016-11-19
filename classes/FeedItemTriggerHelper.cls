/**
 *  Purpose         :   This class is to work as helper class for Feed Item Trigger
 * 
 *  Created By      :   Bhavi Sharma
 * 
 *  Created Date    :   04/02/2015
 * 
 *  Revision Logs   :   V_1.0 - Created
 *                  :   V_2.0 - Modified By - Rajeev Jain - 02/18/2016 - CR-20160203-9580 - Replaced Column__c with Attribute__C field in the code
 * 
 **/ 
public with sharing class FeedItemTriggerHelper {
    
    /**
     *  @description    :   This methiod is to validate the data before inserting into database. If there is any error, display error message to user.
     *
     *  @args           :   List of Feed Items
     *
     *  @return         :   void
     *
     **/
    public static void validateFeedItems(List<Feed_Item__c> feedItems) {
        
        //Create a set to hold the unique key of feed item
        Set<String> feedItemsKeys = new Set<String>();
        
        //Set to hold teh parent feeds
        Set<Id> feedIds = new Set<Id>();
        
        //Loop through the roles
        for(Feed_Item__c fI : feedItems) {
            
            //Generate Unique Key
            String uniqueKey = '';
            if(fI.Feed_Identifier__c != null)
                uniqueKey += fI.Feed_Identifier__c;
            if(fI.Attribute__c != null)
                uniqueKey += fI.Attribute__c;
            if(fI.Column_label__c != null)
                uniqueKey += fI.Column_label__c;
            if(fI.Output_Order__c != null)
                uniqueKey += fI.Output_Order__c;
            
            //Add feeds in Set
            feedIds.add(fI.Feed_Identifier__c);
            
            //Add keys in set
            feedItemsKeys.add(uniqueKey);
        }
        
        //Query database to check if there is already a record with the same name
        for(Feed_Item__c fI : [Select Id, Feed_Identifier__c, Attribute__c, Column_label__c, Output_Order__c from Feed_Item__c 
                                                                                where Feed_Identifier__c IN: feedIds AND ID NOT IN: feedItems]) {
            
            //Generate Unique Key
            String uniqueKey = '';
            if(fI.Feed_Identifier__c != null)
                uniqueKey += fI.Feed_Identifier__c;
            if(fI.Attribute__c != null)
                uniqueKey += fI.Attribute__c;
            if(fI.Column_label__c != null)
                uniqueKey += fI.Column_label__c;
            if(fI.Output_Order__c != null)
                uniqueKey += fI.Output_Order__c;
                
            //Check if any new record has same unique key
            if(feedItemsKeys.contains(uniqueKey))
                throw new CustomException(Label.ERROR_UNIQUENESS_FEED_ITEM);
        }
    } 
}