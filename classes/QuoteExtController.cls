public with sharing class QuoteExtController {
    private Id quoteId;
    public SBAA__Approval__c[] approvals {get; set;}
    public
        QuoteExtController(ApexPages.StandardController
                           stdController) {
                               quoteId = stdController.getId();
                           }
    public PageReference onSubmit() {
        if (quoteId != null) {
            SBAA.ApprovalAPI.submit(quoteId, SBAA__Approval__c.Quote__c);
        }
        return new PageReference('/' + quoteId);
    }
    
    //Modified by Colin McGloin - 7/28 to add Opportunity Stage validation
    public PageReference onRecall() {
        
        //Get the Quote Record and associated Opportunity    
        SBQQ__Quote__c recordQuote = [SELECT Id, SBQQ__Opportunity2__c FROM SBQQ__Quote__c  WHERE Id = :quoteId];
        
        for (Opportunity opp : [SELECT Id, StageName From Opportunity WHERE Id = :recordQuote.SBQQ__Opportunity2__c]){
            
            //Check to see if the Stage is equal to 'Contract Received - Send to Finance' - if it is then add error and return null so the user sees the error message on the VF page
            if (opp.StageName == CPQConstants.OPPORTUNITY_STAGE_CONTRACT_REC_SEND_TO_FINANCE || opp.StageName == CPQConstants.OPPORTUNITY_STAGE_CLOSED_WON || opp.StageName == CPQConstants.OPPORTUNITY_STAGE_CLOSED_LOST){
                recordQuote.addError(Label.RecallQuoteError);
                return null;
            }
            
            else {
                if (quoteId != null) {
                    SBAA.ApprovalAPI.recall(quoteId, SBAA__Approval__c.Quote__c);
                }
                return new PageReference('/' + quoteId);
                
            }
            
        }
        return new PageReference('/' + quoteId);
    }
    
    public PageReference onPreview() {
        if (quoteId != null) {
            approvals = SBAA.ApprovalAPI.preview(quoteId,
                                                 SBAA__Approval__c.Quote__c);
        }
        return null;
    }
}