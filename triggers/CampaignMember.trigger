/**
    Purpose         :   Trigger for Campaign Member object.

    Created By      :   Victor Hanson

    Created Date    :   06/24/2014

    Current Version :   V_1.0
    
    Revision Log    :   V_1.0 - Created
 **/
trigger CampaignMember on CampaignMember (before insert, before update) {
    
    //return immediately if bypass flag is active
    if (util.BypassAllTriggers) return;
    
    if (trigger.isBefore) {
        
        //if the campaign member is marked undeliverable, update the # undeliverable mailings on the contact
        CampaignMemberTriggerHelper.updateUndeliverableMailings(trigger.new, trigger.oldMap);
        
        if (trigger.isInsert) {
            
            CampaignMemberTriggerHelper.PopulateCampaignMemberLookups(trigger.new);
        }
    }
}