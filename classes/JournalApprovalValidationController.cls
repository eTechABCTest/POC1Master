/*
  Purpose:
        The controller for journal approval validation. Before a journal can be posted,
        the Approved checkbox must be checked.
        
  Initiative: IconATG FinancialForce PSA Implementation 
  Author:     William Rich
  Company:    IconATG
  Contact:    william.rich@iconatg.com
  Created:    3/21/2015
*/
public with sharing class JournalApprovalValidationController {

    ApexPages.StandardController stdController;
    Id theJournalId;

    public JournalApprovalValidationController(ApexPages.StandardController stdController) {
        this.stdController = stdController;
        this.theJournalId = stdController.getId();
    }

    public PageReference validateApproval() {

        PageReference pgRef = null;

        if (okToPost()) {
            //https://advisory--ffdc1--ffgl.cs24.visual.force.com/apex/journalpost?scontrolCaching=1&id=a1e19000000TOb1
            pgRef = new PageReference('/apex/ffgl__journalpost');
            Map<String, String> parameters = pgRef.getParameters();
                    
            parameters.put('scontrolCaching', '1');
            parameters.put('retURL', ApexPages.currentPage().getParameters().get('retURL'));
            parameters.put('cancelURL', ApexPages.currentPage().getParameters().get('cancelURL'));
            parameters.put('id', theJournalId);
            
            pgRef.setRedirect(true);
        }
        else {
            String msg = 'This journal must be approved before it can be posted.';
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.Error, msg));
        }

        return pgRef;
    }

    public PageReference cancel() {
        return this.stdController.cancel();
    }

    private boolean okToPost() {
        ffbext__OneTouchSettings__c oneTouchSettings = ffbext__OneTouchSettings__c.getOrgDefaults();

        c2g__codaJournal__c theJournal = [
            select Approved__c
            from c2g__codaJournal__c
            where Id = :theJournalId
        ];

        boolean okToPost = true;
        if (oneTouchSettings.EnableJournalApproval__c) {
            if (!theJournal.Approved__c) {
                okToPost = false;
            }
        }
        return okToPost;
    }
}