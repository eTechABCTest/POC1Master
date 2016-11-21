/*
  Purpose:
        The list controller for journal approval validation. Before a journal can be posted,
        the Approved checkbox must be checked.
        
  Initiative: IconATG FinancialForce PSA Implementation 
  Author:     William Rich
  Company:    IconATG
  Contact:    william.rich@iconatg.com
  Created:    3/22/2015
*/
public with sharing class JournalApprovalValidationListController {

    ApexPages.StandardSetController stdController;
    Set<Id> selectedJournalIds;
    Set<Id> approvedJournalIds;
    Set<Id> unapprovedJournalIds;
    private String baseURL;

    public JournalApprovalValidationListController(ApexPages.StandardSetController stdController) {
        this.stdController = stdController;
        this.baseURL = URL.getSalesforceBaseUrl().toExternalForm();
        this.selectedJournalIds = new Set<Id>();
        this.approvedJournalIds = new Set<Id>();
        this.unapprovedJournalIds = new Set<Id>();
    }

    public PageReference validateApprovalList() {
        if (this.stdController.getSelected().size() == 0) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.Error, 'No journals selected. Please select at least one journal to post.'));
        }
        else {
            ffbext__OneTouchSettings__c oneTouchSettings = ffbext__OneTouchSettings__c.getOrgDefaults();

            sObject[] selectedSObjects = stdController.getSelected();
            for (sObject selectedSObject : selectedSObjects) {
                this.selectedJournalIds.add(selectedSObject.Id);
            }

            List<c2g__codaJournal__c> journals = [
                select Id, Approved__c
                from c2g__codaJournal__c
                where Id in :selectedJournalIds 
            ];

            for (c2g__codaJournal__c journal : journals) {
                if (okToPost(oneTouchSettings, journal)) {
                    this.approvedJournalIds.add(journal.id);
                }
                else {
                    this.unapprovedJournalIds.add(journal.id);
                }
            }

            if (!this.unapprovedJournalIds.isEmpty()) {
                String emailMsg =  'Of ' + this.selectedJournalIds.size() + ' selected journals, the following journals were not approved for posting:\n';
                for (Id journalId : this.unapprovedJournalIds) {
                    emailMsg += this.baseURL + '/' + journalId + '\n';
                }
                sendEmail(emailMsg);
            }

            if (!this.approvedJournalIds.isEmpty()) {
                c2g.CODAAPICommon_5_0.Context context = new c2g.CODAAPICommon_5_0.Context();
                context.CompanyName = 'The Advisory Board Company';
                
                List<c2g.CODAAPICommon.Reference> values = new List<c2g.CODAAPICommon.Reference>();
                for (Id journalId : this.approvedJournalIds) {
                    c2g.CODAAPICommon.Reference value = new c2g.CODAAPICommon.Reference();
                    value.Id = journalId;
                    values.add(value);
                    System.debug('&&&&& adding selected journal ' + journalId);
                }

                try {
                    System.debug('&&&&& bulk posting journals');
                    c2g.CODAAPIJournal_5_0.BulkPostJournal(context, values);
                }
                catch (Exception e) {
                    String msg = 
                        'This message has been sent by FinancialForce Accounting to inform you that the bulk document posting process ' +
                        'you initiated has completed with the following errors:\n\n' + e.getMessage();
                    sendEmail(msg);
                }
            }
        }

        return null;
    }

    public PageReference back() {
        return stdController.cancel();
    }

    private boolean okToPost(ffbext__OneTouchSettings__c oneTouchSettings, c2g__codaJournal__c theJournal) {
        boolean okToPost = true;
        if (oneTouchSettings.EnableJournalApproval__c) {
            if (!theJournal.Approved__c) {
                okToPost = false;
            }
        }
        return okToPost;
    }

    public void sendEmail(String emailMsg) {
        List<User> userList = [
            select email
            from User
            where Id = :UserInfo.getUserId()
        ];

        if (!userList.isEmpty()) {
            String[] recipients = new List<String>();
            recipients.add(userList.get(0).Email);
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            mail.setToAddresses(recipients);
            mail.setSenderDisplayName('FF Journal Posting');
            mail.setSaveAsActivity(false);
            mail.setSubject('The Advisory Board Company: Journal Post');
            mail.setPlainTextBody(emailMsg);
            Messaging.reserveSingleEmailCapacity(recipients.size());
            
            if (!System.Test.isRunningTest()) {
                List<Messaging.SendEmailResult> results = Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
                
                if (results.get(0).isSuccess()) {
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.Info, 'Email sent to ' + recipients[0] + ' successfully'));
                } 
                else {
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.Error, 'The email failed to send: ' + results.get(0).getErrors().get(0).getMessage()));
                }
            }
        }
    }
}