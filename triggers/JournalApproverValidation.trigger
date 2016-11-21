/*
  Purpose:
        A journal can be approved only by a user that did not create it.
        
  Initiative: IconATG FinancialForce PSA Implementation 
  Author:     William Rich
  Company:    IconATG
  Contact:    william.rich@iconatg.com
  Created:    3/28/2015
*/
trigger JournalApproverValidation on c2g__codaJournal__c (before update) {
    for (c2g__codaJournal__c newJournal : Trigger.new) {
        c2g__codaJournal__c oldJournal = Trigger.oldMap.get(newJournal.Id);
        if (newJournal.Approved__c == true && oldJournal.Approved__c == false) {
            if (newJournal.CreatedById == UserInfo.getUserId()) {
                newJournal.AddError('The user who created the journal cannot also approve it.');
            }
        }
    }
}