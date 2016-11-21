/**
    Desription      :   Contains Helper methods for site functionality (ie: EAB.com/Advisory.com).
  
    Created By      :   Victor Hanson
  
    Created Date    :   07/29/2014
  
    Revision Logs   :   v1 - Created
 **/ 
global class SiteSubscriptionHelper {
    
    // get the eligible subscription data
    public static List<SubscriptionWrapper> FindSubscriptionOptions(Contact contact) {
        
        List<SubscriptionWrapper> subWrapperList = new List<SubscriptionWrapper>();
        Map<String, List<Subscription__c>> subscriptionMap = new Map<String, List<Subscription__c>>();
        Map<String, List<Eligible_Subscription_Option__c>> eligibleSubscriptionMap = new Map<String, List<Eligible_Subscription_Option__c>>();
        Set<Id> relatedSubscriptionIdSet = new Set<Id>(); //VRH 2/21/13 - moved in to the if stmt above so we don't add duplicative subscriptions
        
        // get all Subscription Options
        Set<Id> subOptionIds = new Set<Id>();
        for (Subscription__c sub : contact.Subscriptions__r) subOptionIds.add(sub.Subscription_ID__r.Related_Subscription__c);
        
        // get all subscription options with Attachments
        Map<Id, Subscription_Option__c> SubOptWithAttachments = new Map<Id, Subscription_Option__c>([SELECT Id, (SELECT Id, ContentType FROM Attachments ORDER BY CreatedDate ASC) FROM Subscription_Option__c WHERE Id IN :subOptionIds]);
        
        Set<Id> activeEligibleSubscriptions = new Set<Id>();
        
        for (Subscription__c subscription : contact.Subscriptions__r) {
            // add the existing subscription id to our list of existing subs so we don't pull duplicates
            relatedSubscriptionIdSet.add(subscription.Subscription_Id__r.Related_Subscription__c);
            activeEligibleSubscriptions.add(subscription.Subscription_Id__c);
            // create the subscription wrapper
            SubscriptionWrapper actualSubscription = new SubscriptionWrapper();
            actualSubscription.IsSubscribed = true;
            actualSubscription.Category = subscription.Subscription_ID__r.Related_Subscription__r.Subscription_Category__c;
            actualSubscription.EligibleSubscriptionIdList = new List<Id> { subscription.Subscription_ID__c }; // VRH 2/21/13 - can probably get rid of this concept of EligibleSubIdLIST -- because there should only be 1 subscription now.
                actualSubscription.Description = Subscription.Subscription_ID__r.Related_Subscription__r.Description__c;
            actualSubscription.EligibleSubscriptionId = subscription.Subscription_ID__c;
            actualSubscription.SubscriptionDisplayName = subscription.Subscription_Name__c.split(' - ')[0];
            actualSubscription.ApplicableSegments = subscription.Subscription_Id__r.Program__r.Applicable_Segments__c;
            //Get the name to use for sorting by removing the first word in the name if needed
            actualSubscription.SubscriptionSortName = GetSortName(actualSubscription.SubscriptionDisplayName);
            
            // see if there is an image attached to the Subscription Option
            Subscription_Option__c subOpt = SubOptWithAttachments.get(subscription.Subscription_Id__r.Related_Subscription__c);
            if (subOpt != null && subOpt.Attachments.size() > 0)
                actualSubscription.AttachmentId = subOpt.Attachments[0].Id;
            
            subWrapperList.add(actualSubscription);
        }
        
        // get active memberships from acct
        List<Membership__c> memberships = [SELECT Name, Program__c FROM Membership__c WHERE Membership_Status__c LIKE 'Member%' AND Account_Name__c = :contact.AccountId];
        
        // VH 12/27/12 - find temp program access and get those progs as well
        List<Temporary_Program_Access__c> tempAccessList = [SELECT Id, Web_Program__r.Membership_Program__c FROM Temporary_Program_Access__c WHERE Contact__c = :contact.Id AND Start_Date__c <= TODAY AND End_Date__c >= TODAY  LIMIT 500];
        
        Set<Id> programIds = new Set<Id>();
        for (Membership__c m : memberships)
            programIds.add(m.Program__c);
        
        for (Temporary_Program_Access__c ta : tempAccessList)
            programIds.add(ta.Web_Program__r.Membership_Program__c);
        
        // get a list of subscription options
        List<Eligible_Subscription_Option__c> eligibleSubscriptions = [SELECT Id, Name, Name__c, Related_Subscription__c, Related_Subscription__r.Description__c, Program__c, Related_Subscription__r.Subscription_Name_Ext__c, 
        															  Related_Subscription__r.Legacy_Subscription_ID__c, Related_Subscription__r.Subscription_Category__c, Related_Subscription__r.Subscription_Status__c, 
        															  Related_Subscription__r.Name, Program__r.Applicable_Segments__c
                                                                       FROM Eligible_Subscription_Option__c 
                                                                       WHERE (
                                                                           Program__c IN :programIds 
                                                                           AND Related_Subscription__c NOT IN :relatedSubscriptionIdSet 
                                                                           AND ID NOT IN :activeEligibleSubscriptions 
                                                                           AND Related_Subscription__r.Subscription_Status__c = 'Active'
                                                                       )
                                                                       /*OR ( 
                                                                           Related_Subscription__c NOT IN :relatedSubscriptionIdSet 
                                                                           AND ID NOT IN :activeEligibleSubscriptions 
                                                                           AND Related_Subscription__r.Subscription_Status__c = 'Active'
                                                                           AND Related_Subscription__r.Available_To_All__c = true
                                                                       )*/];
        
        for (Eligible_Subscription_Option__c eso : eligibleSubscriptions) {
            
            List<Eligible_Subscription_Option__c> esoList = eligibleSubscriptionMap.get(eso.Related_Subscription__c);
            if (esoList == null) {
                esoList = new List<Eligible_Subscription_Option__c> { eso };
            }
            else continue;
            //esoList.add(eso);  VRH 2/21/13 - moved in to the if stmt above so we don't add duplicative subscriptions
            eligibleSubscriptionMap.put(eso.Related_Subscription__c, esoList);
        }
        
        // get all subscription options with Attachments
        Map<Id, Subscription_Option__c> eligSubOptWithAttachments = new Map<Id, Subscription_Option__c>([SELECT Id, (SELECT Id, ContentType FROM Attachments ORDER BY CreatedDate ASC) FROM Subscription_Option__c WHERE Id IN :eligibleSubscriptionMap.keySet()]);
        
        for (List<Eligible_Subscription_Option__c> esoList : eligibleSubscriptionMap.values()) {
            // create the subscription wrapper
            SubscriptionWrapper subWrapper = new SubscriptionWrapper(esoList);
            
            // see if there is an image attached to the Subscription Option
            Subscription_Option__c subOpt = eligSubOptWithAttachments.get(esoList[0].Related_Subscription__c);
            if (subOpt != null && subOpt.Attachments.size() > 0)
                subWrapper.AttachmentId = subOpt.Attachments[0].Id;
            
            subWrapperList.add(subWrapper);
        }
        return subWrapperList;
    }
    
    /*private static list<Subscription__c> getSubscriptionsToInsert(Id contactId, list<Eligible_Subscription_Option__c> eligSubOptions) {
        
        // list of subscriptions to return
        list<Subscription__c> subscriptionsToReturn = new list<Subscription__c>();
        
        // get any current subscriptions for this program
        Set<Id> subOptionIdSet = new Set<Id>();
        List<Subscription__c> activeSubscriptions = [SELECT Id, Subscription_ID__c, Subscription_Status__c, Subscription_ID__r.Related_Subscription__c
                                                    FROM Subscription__c 
                                                    WHERE Contact__c = :contactId AND Termination_Date__c = null];
        // get all of the subscription option ID's for active subscriptions so we don't create dupes.
        for (Subscription__c sub : activeSubscriptions) {
            subOptionIdSet.add(sub.Subscription_ID__r.Related_Subscription__c);
        }
        system.debug('@@eligSubOptions:' + eligSubOptions);
        // for each eligible subscription option, create a subscription if the Subscription Option is not in our set
        for (Eligible_Subscription_Option__c eligibleSubscription : eligSubOptions) {
            if (subOptionIdSet.contains(eligibleSubscription.Related_Subscription__c)) continue;
            else {
                Subscription__c newSubscription = new Subscription__c();
                newSubscription.Contact__c = contactId;
                newSubscription.Send_Notification_Email__c = true;
                newSubscription.Activation_Date__c = system.now();
                newSubscription.Subscription_ID__c = eligibleSubscription.Id;
                newSubscription.Auto_Subscribed__c = true;
                newSubscription.Subscription_Status__c = SiteController.SUBSCRIPTION_ACTIVE;
                subscriptionsToReturn.add(newSubscription);
                // add this subscription option to the list of active subscriptions so we don't inset dupes
                subOptionIdSet.add(eligibleSubscription.Related_Subscription__c);
            }
        }
        system.debug('@@subscriptionsToReturn:' + subscriptionsToReturn);
        return subscriptionsToReturn;
    }*/
    
    public static String GetSortName(String fullName) {
        String retName = fullName;
        String upperName = fullName.ToUpperCase();
        //Check first if the term contains a space
        if(fullName.contains(' ')){
            String firstWord = upperName.split(' ')[0];
            system.debug('AdvUtils.SortName - firstWord: '+firstWord);
            //If the first word of the term is in the set of words to ignore...
            if(Constants.SORT_IGNORE_WORDS.contains(firstWord)) {
                //get the name without the first word
                retName = fullName.right(fullName.length() - firstWord.length()).trim();
                //retName = retName.trim();
            }
        }
        system.debug('AdvUtils.SortName - retName: '+retName);
        return retName;       
    }
    
    global class SubscriptionWrapper implements Comparable {
        
        // Implement the compareTo() method 
        
        global Integer compareTo(Object compareTo) {
            SubscriptionWrapper compareToWrapper = (SubscriptionWrapper)compareTo;
            if (SubscriptionSortName == compareToWrapper.SubscriptionSortName) return 0;
            if (SubscriptionSortName > compareToWrapper.SubscriptionSortName) return 1;
            return -1;        
        }
        
        public Id EligibleSubscriptionId { get; set; }
        public List<Id> EligibleSubscriptionIdList { get; set; }
        public boolean IsSubscribed { get; set; }
        public String Description { get; set; }
        public String Category { get; set; }
        public String SubscriptionDisplayName { get; set; }
        public String AttachmentId { get; set; }
        public String SubscriptionSortName { get; set; }
        public string ApplicableSegments { get; set; }
        
        public SubscriptionWrapper(List<Eligible_Subscription_Option__c> eligibleSubscriptions) {
            for (Eligible_Subscription_Option__c eligibleOption : eligibleSubscriptions) {
                if (EligibleSubscriptionIdList == null) EligibleSubscriptionIdList = new List<Id>();
                EligibleSubscriptionIdList.add(eligibleOption.Id);
            }
            EligibleSubscriptionId = eligibleSubscriptions[0].Id;
            IsSubscribed = false;
            Category = eligibleSubscriptions[0].Related_Subscription__r.Subscription_Category__c;
            Description = eligibleSubscriptions[0].Related_Subscription__r.Description__c;
            SubscriptionDisplayName = eligibleSubscriptions[0].Name__c.split(' - ')[0];
            //Get the name to use for sorting by removing the first word in the name if needed
            SubscriptionSortName = GetSortName(SubscriptionDisplayName);
            ApplicableSegments = eligibleSubscriptions[0].Program__r.Applicable_Segments__c;
        }
        
        public SubscriptionWrapper() {
            
        }
        
    }
    
}