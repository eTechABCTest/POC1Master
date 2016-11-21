trigger SiteProfile on Site_Profile__c (before insert, before update, after insert, after update, after delete) {
	
    if (trigger.isBefore && trigger.isInsert) {
        //populate the Site Profile Created By field
        SiteProfileTriggerHelper.updateSiteProfileCreatedBy(trigger.new);
    }
    
    //return immediately if one of the bypass flags are true
    if (Util.BypassAllTriggers || SiteProfileTriggerHelper.bypassSiteProfileTrigger) return;
    
    /** before **/
    if (trigger.isBefore) {
        
        //check for other site profiles with the same Username + Type
        SiteProfileTriggerHelper.siteProfileDupeCheck(trigger.new);
        
        //synchronize some contact info with the site profile
        SiteProfileTriggerHelper.synchronizeContactWithSiteProfile(trigger.new, trigger.oldMap);
        
        //if the username was changed, synchronize that username across the Contact and all related site profiles
        SiteProfileTriggerHelper.synchronizeSiteProfileWithContact(trigger.new, trigger.oldMap);
        
        //validate the site profiles have an eligible domain
        SiteProfileTriggerHelper.validateEligibleDomain(trigger.new, trigger.oldMap);
        
        if (trigger.isInsert) {
            
            //create the siteUser if necessary, and validate that this profile should be created (ie: Domain validation).
            SiteProfileTriggerHelper.createSiteProfile(trigger.new);
        }
        
        if (trigger.isUpdate) {
            SiteUserHelper.trackLoginHistory(trigger.new, trigger.old);
        }
        
    }
    
    /** after **/
    if (trigger.isAfter) {
        
        SiteProfileTriggerHelper.updateSiteProfileCount(trigger.new, trigger.oldMap);
        
        if(trigger.isInsert) {
            
            SiteProfileTriggerHelper.sendVerificationEmail(trigger.newMap.keySet());
        }
        
    }
}