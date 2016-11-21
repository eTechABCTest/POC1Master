trigger JournalBatchIntegrationRuleEngine on Journal_Upload_Lines__c (before insert) {
ffirule.IntegrationRuleEngine.triggerHandler();
}