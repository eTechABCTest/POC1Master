@isTest
private class Test_IntegrationMappingHelper {

    static testmethod void testUpdateIntegrationRecType(){
        
        list<RecordType> intRecType = [select Id, DeveloperName from RecordType where SobjectType = 'Integration__c' LIMIT 1];
        Integration_Job__c intjob = new Integration_Job__c();
        intjob.Name = intRecType[0].Id;
        intjob.Integration_Job_Name__c = intRecType[0].DeveloperName;
        insert intjob;
        
        Integration_Mapping__c im = new Integration_Mapping__c();
        im.Integration_Name__c = intJob.Integration_Job_Name__c;
        Id testId ;
        
        test.startTest();
        	insert im;
        	testId = im.Id;
        test.stopTest();
        
        Integration_Mapping__c imResult = [select Id, Integration_RecordTypeId__c from Integration_Mapping__c where Id = :testId];
        system.assertNotEquals(null,imResult.Integration_RecordTypeId__c);
        
    }
    
}