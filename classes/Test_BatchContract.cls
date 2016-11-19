@isTest
private class Test_BatchContract{

    static testmethod void testBatch_Contract()
    { 
        //Bypass Dupeblocker
        Util.IsTest(true);
        Test.startTest();
        
        string query = 'select id, Payer_Account__r.Name, Program__r.Program_Acronym__c, Program__r.Business_Line__c, Start__c, ' + 
            'Source_Opportunity__c, Source_Opportunity__r.Recordtype.Name, Source_Opportunity__r.Marketer__c, Source_Opportunity__r.OwnerID, End__c ' +
            'from Contract__c limit 200';
        
        System.debug('### Test Batch Query String: ' + query);
    
        Batch_Contract batch = new Batch_Contract();
        batch.Query = query;
    
        Id batchId = Database.executeBatch(batch);
        
        system.assertNotEquals(null, batchId);
               
        System.debug('### Launched Batch : '+batchId);
        
        Test.stopTest();
    }
}