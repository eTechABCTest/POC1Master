/**
 *  Desription      :   Test Class for CommonAuth related classes
 *
 *  Created By      :   Jeffery Sun
 *  Created Date    :   02/22/2014
 *  Revision Logs   :   V1.0 - Created
 **/
@isTest
private class Test_CommonAuth {
    static testMethod void testCommonAuthController_cstor() {
        Util.IsTest(true);
        Util.IsTesting = true;
        Test.startTest();

        String jsonString = '{"Command":"SyncContact","CrimsonGuid":"9E8BBCCC-AD2F-4FF9-9D42-98CB58381931",' +
            '"CrimsonEmail":"someone@abc.com","FirstName":"FirstName","LastName":"LastName",' + 
            '"ProjectIds":["a0UC000000BMFJF"]}';
        ApexPages.currentPage().getParameters().put('req', CommonAuthHelper.Encode(jsonString));
        
        CommonAuthController controller = new CommonAuthController();
        
        Test.stopTest();
        
        System.assertEquals('SyncContact', controller.CommandName);
        System.assertEquals(null, controller.ErrorMessage);
        System.assertEquals(jsonString, controller.JSONRequest);
    }

    static testMethod void testCommonAuthController_cstor_EmptyRequest() {
        Util.IsTest(true);
        Util.IsTesting = true;
        Test.startTest();

        ApexPages.currentPage().getParameters().put('req', '');
        
        CommonAuthController controller = new CommonAuthController();
        
        Test.stopTest();
        
        System.assertEquals(null, controller.CommandName);
        System.assert(controller.ErrorMessage != null);
    }
    
    static testMethod void testCommonAuthController_cstor_InvalidCommand() {
        Util.IsTest(true);
        Util.IsTesting = true;
        Test.startTest();

        String jsonString = '{"Command":"notsupported"}';
        ApexPages.currentPage().getParameters().put('req', CommonAuthHelper.Encode(jsonString));
        
        CommonAuthController controller = new CommonAuthController();
        PageReference pageReference = controller.process();
        
        Test.stopTest();
        
        System.assert(controller.ErrorMessage != null);
    }
    
    static testMethod void testCommonAuthController_SynchContact_CreateNewContact() {
        Util.IsTest(true);
        Util.IsTesting = true;
        
        Account acc = new Account(Name = 'testacc', Account_Formal_Name__c = 'testacc');
        insert acc;
        Project__c project = new Project__c(Name = 'Test', Institution__c = acc.Id);
        insert project;
        
        Test.startTest();

        String jsonString = '{"Command":"SyncContact","CrimsonGuid":"9E8BBCCC-AD2F-4FF9-9D42-98CB58381931",' +
            '"CrimsonEmail":"someone@abc.com","FirstName":"FirstName","LastName":"LastName",' + 
            '"ProjectIds":["' + project.Id + '"]}';
        ApexPages.currentPage().getParameters().put('req', CommonAuthHelper.Encode(jsonString));
        
        CommonAuthController controller = new CommonAuthController();
        PageReference pageReference = controller.process();
        
        Test.stopTest();
       
        String jsonReturn = CommonAuthHelper.Decode(controller.JSONResponse);
        system.debug('@@jsonReturn: ' + jsonReturn);
        
        Contact c = [SELECT Id, AccountId, SIAM_GUID__c, SIAM_Email__c, Counter_Id__c FROM Contact
                     WHERE SIAM_GUID__c = '9E8BBCCC-AD2F-4FF9-9D42-98CB58381931' LIMIT 1];
       
        System.assert(jsonReturn.indexOf('"Successful":true') > 0);
        System.assert(jsonReturn.indexOf('"ErrorMessage":null') > 0);
        System.assert(jsonReturn.indexOf('"ContactDetail":{') > 0);
        System.assert(jsonReturn.indexOf('"SFContactId":"' + String.valueOf(c.Id).substring(0, 15) + '"') > 0);
        System.assert(jsonReturn.indexOf('"CounterId":"' + c.Counter_ID__c + '"') > 0);
        System.assert(jsonReturn.indexOf('"SFAccountId":"' + String.valueOf(c.AccountId).substring(0, 15) + '"') > 0);
    }
    
    static testMethod void testCommonAuthController_SynchContact_SIAMEmailSingleContact() {
        Util.IsTest(true);
        Util.IsTesting = true;
        
        Account acc = new Account(Name = 'testacc', Account_Formal_Name__c = 'testacc');
        insert acc;
        Project__c project = new Project__c(Name = 'Test', Institution__c = acc.Id);
        insert project;
        Contact cont = new Contact(FirstName = 'FirstName', LastName = 'LastName', SIAM_GUID__c = 'caReq.CrimsonGuid',
            SIAM_Email__c = 'someone@abc.com', Email = 'someone@abc.com', RecordTypeId = Util.RecordTypeId('Contact', 'External'),
            AccountId = acc.Id, Primary_Address_Line_1__c = 'Address_Line_1', Primary_Address_Line_2__c = 'Address_Line_2',
            Primary_Address_Line_3__c = 'Address_Line_3', Primary_City__c = 'City', Primary_State_Province__c = 'State',
            Primary_Postal_Code__c = 'Zip', Primary_Country__c = 'Country');
        INSERT cont;
        Project_Role__c role = new Project_Role__c(Project__c = project.Id, Contact__c = cont.Id,
            SIAM_Portal_Status__c = 'Inactive', Project_Type__c = 'CPM', Role__c = 'Other');
        INSERT role;
        Test.startTest();

        String jsonString = '{"Command":"SyncContact","CrimsonGuid":"9E8BBCCC-AD2F-4FF9-9D42-98CB58381931",' +
            '"CrimsonEmail":"someone@abc.com","FirstName":"FirstName","LastName":"LastName",' + 
            '"ProjectIds":["' + project.Id + '"]}';
        ApexPages.currentPage().getParameters().put('req', CommonAuthHelper.Encode(jsonString));
        
        CommonAuthController controller = new CommonAuthController();
        PageReference pageReference = controller.process();
        
        Test.stopTest();
       
        String jsonReturn = CommonAuthHelper.Decode(controller.JSONResponse);
        system.debug('@@jsonReturn: ' + jsonReturn);
        
        Contact c = [SELECT Id, AccountId, SIAM_GUID__c, SIAM_Email__c, Counter_Id__c FROM Contact
                     WHERE SIAM_GUID__c = '9E8BBCCC-AD2F-4FF9-9D42-98CB58381931' LIMIT 1];
        Project_Role__c r2 = [SELECT SIAM_Portal_Status__c FROM Project_Role__c
                              WHERE id = :role.Id LIMIT 1];
        System.assert(jsonReturn.indexOf('"Successful":true') > 0);
        System.assert(jsonReturn.indexOf('"SFContactId":"' + String.valueOf(cont.Id).substring(0, 15) + '"') > 0);
        System.assert(jsonReturn.indexOf('"SFAccountId":"' + String.valueOf(acc.Id).substring(0, 15) + '"') > 0);
        System.assertEquals('Active', r2.SIAM_Portal_Status__c);
    }
    
    static testMethod void testCommonAuthController_SynchContact_EmailSearchSingleContact() {
        Util.IsTest(true);
        Util.IsTesting = true;
        
        Account acc = new Account(Name = 'testacc', Account_Formal_Name__c = 'testacc');
        insert acc;
        Project__c project = new Project__c(Name = 'Test', Institution__c = acc.Id);
        insert project;
        
        Contact cont = new Contact(FirstName = 'FirstName2', LastName = 'LastName2', SIAM_GUID__c = 'caReq.CrimsonGuid',
            SIAM_Email__c = null, Email = 'someone@abc.com', RecordTypeId = Util.RecordTypeId('Contact', 'External'),
            AccountId = acc.Id, Primary_Address_Line_1__c = 'Address_Line_1', Primary_Address_Line_2__c = 'Address_Line_2',
            Primary_Address_Line_3__c = 'Address_Line_3', Primary_City__c = 'City', Primary_State_Province__c = 'State',
            Primary_Postal_Code__c = 'Zip', Primary_Country__c = 'Country');
        INSERT cont;
        
        Test.startTest();

        String jsonString = '{"Command":"SyncContact","CrimsonGuid":"9E8BBCCC-AD2F-4FF9-9D42-98CB58381931",' +
            '"CrimsonEmail":"someone@abc.com","FirstName":"FirstName","LastName":"LastName",' + 
            '"ProjectIds":["' + project.Id + '"]}';
        ApexPages.currentPage().getParameters().put('req', CommonAuthHelper.Encode(jsonString));
        
        CommonAuthController controller = new CommonAuthController();
        PageReference pageReference = controller.process();
        
        Test.stopTest();
       
        String jsonReturn = CommonAuthHelper.Decode(controller.JSONResponse);
        system.debug('@@jsonReturn: ' + jsonReturn);
        
        Contact c = [SELECT Id, AccountId, SIAM_GUID__c, SIAM_Email__c, Counter_Id__c FROM Contact
                     WHERE Id = :cont.Id LIMIT 1];
       
        System.assert(jsonReturn.indexOf('"Successful":true') > 0);
        System.assertEquals('someone@abc.com', c.SIAM_Email__c);
        System.assertEquals('9E8BBCCC-AD2F-4FF9-9D42-98CB58381931', c.SIAM_GUID__c);
    }

    static testMethod void testCommonAuthController_SynchContact_MultipleExistingContacts() {
        Util.IsTest(true);
        Util.IsTesting = true;
        
        Account acc = new Account(Name = 'testacc', Account_Formal_Name__c = 'testacc');
        insert acc;
        Project__c project = new Project__c(Name = 'Test', Institution__c = acc.Id);
        insert project;

        Contact cont = new Contact(FirstName = 'FirstName', LastName = 'LastName',
            Email = 'someone@abc.com', RecordTypeId = Util.RecordTypeId('Contact', 'External'),
            AccountId = acc.Id, Primary_Address_Line_1__c = 'Address_Line_1', Primary_Address_Line_2__c = 'Address_Line_2',
            Primary_Address_Line_3__c = 'Address_Line_3', Primary_City__c = 'City', Primary_State_Province__c = 'State',
            Primary_Postal_Code__c = 'Zip', Primary_Country__c = 'Country');
        INSERT cont;
        system.debug('@@contact1: ' + cont);

        Contact cont2 = new Contact(FirstName = 'FirstName2', LastName = 'LastName2',
            Advisory_com_Email_Address__c = 'someone@abc.com', RecordTypeId = Util.RecordTypeId('Contact', 'External'),
            AccountId = acc.Id, Primary_Address_Line_1__c = 'Address_Line_1', Primary_Address_Line_2__c = 'Address_Line_2',
            Primary_Address_Line_3__c = 'Address_Line_3', Primary_City__c = 'City', Primary_State_Province__c = 'State',
            Primary_Postal_Code__c = 'Zip', Primary_Country__c = 'Country');
        INSERT cont2;
        system.debug('@@contact2: ' + cont2);
        
        Test.startTest();

        String jsonString = '{"Command":"SyncContact","CrimsonGuid":"9E8BBCCC-AD2F-4FF9-9D42-98CB58381931",' +
            '"CrimsonEmail":"someone@abc.com","FirstName":"FirstName","LastName":"LastName",' + 
            '"ProjectIds":["' + project.Id + '"]}';
        ApexPages.currentPage().getParameters().put('req', CommonAuthHelper.Encode(jsonString));
        
        CommonAuthController controller = new CommonAuthController();
        PageReference pageReference = controller.process();
        
        Test.stopTest();
       
        String jsonReturn = CommonAuthHelper.Decode(controller.JSONResponse);
        system.debug('@@jsonReturn: ' + jsonReturn);
        
        Contact c = [SELECT Id, AccountId, SIAM_GUID__c, SIAM_Email__c, Counter_Id__c FROM Contact
                     WHERE Id = :cont2.Id LIMIT 1];
       
        System.assert(jsonReturn.indexOf('"Successful":true') > 0);
        System.assertEquals('someone@abc.com', c.SIAM_Email__c);
        System.assertEquals('9E8BBCCC-AD2F-4FF9-9D42-98CB58381931', c.SIAM_GUID__c);
    }
    
    static testMethod void testCommonAuthController_SynchContact_UpdateEmailBasingonGuid() {
        Util.IsTest(true);
        Util.IsTesting = true;
        
        Account acc = new Account(Name = 'testacc', Account_Formal_Name__c = 'testacc');
        insert acc;
        Project__c project = new Project__c(Name = 'Test', Institution__c = acc.Id);
        insert project;

        String jsonString = '{"Command":"SyncContact","CrimsonGuid":"9E8BBCCC-AD2F-4FF9-9D42-98CB58381931",' +
            '"CrimsonEmail":"someone@abc.com","FirstName":"FirstName","LastName":"LastName",' + 
            '"ProjectIds":["' + project.Id + '"]}';
        ApexPages.currentPage().getParameters().put('req', CommonAuthHelper.Encode(jsonString));
        
        CommonAuthController controller = new CommonAuthController();
        PageReference pageReference = controller.process();
        
        String jsonReturn = CommonAuthHelper.Decode(controller.JSONResponse);
        system.debug('@@jsonReturn1: ' + jsonReturn);
        
        Contact c = [SELECT Id, AccountId, SIAM_GUID__c, SIAM_Email__c, Counter_Id__c FROM Contact
                     WHERE SIAM_GUID__c = '9E8BBCCC-AD2F-4FF9-9D42-98CB58381931' LIMIT 1];
        
        Test.startTest();
        
        String jsonString2 = '{"Command":"SyncContact","CrimsonGuid":"9E8BBCCC-AD2F-4FF9-9D42-98CB58381931",' +
            '"CrimsonEmail":"someoneNew@abc.com","FirstName":"FirstName","LastName":"LastName",' + 
            '"ProjectIds":["' + project.Id + '"]}';
        ApexPages.currentPage().getParameters().put('req', CommonAuthHelper.Encode(jsonString2));
        
        CommonAuthController controller2 = new CommonAuthController();
        controller2.process();
        
        Test.stopTest();
      
        jsonReturn = CommonAuthHelper.Decode(controller.JSONResponse);
        system.debug('@@jsonReturn2: ' + jsonReturn);
        
        Contact c2 = [SELECT Id, AccountId, SIAM_GUID__c, SIAM_Email__c, Counter_Id__c FROM Contact
                     WHERE SIAM_GUID__c = '9E8BBCCC-AD2F-4FF9-9D42-98CB58381931' LIMIT 1];
        
        System.assertEquals(c.Id, c2.Id);
        System.assertEquals('someoneNew@abc.com', c2.SIAM_Email__c);
    }

    static testMethod void testCommonAuthController_DeactivateContact() {
        Util.IsTest(true);
        Util.IsTesting = true;
        
        Account acc = new Account(Name = 'testacc', Account_Formal_Name__c = 'testacc');
        insert acc;
        Project__c project = new Project__c(Name = 'Test', Institution__c = acc.Id);
        insert project;
        Contact cont = new Contact(FirstName = 'FirstName', LastName = 'LastName', SIAM_GUID__c = 'caReq.CrimsonGuid',
            SIAM_Email__c = 'someone@abc.com', Email = 'someone@abc.com', RecordTypeId = Util.RecordTypeId('Contact', 'External'),
            AccountId = acc.Id, Primary_Address_Line_1__c = 'Address_Line_1', Primary_Address_Line_2__c = 'Address_Line_2',
            Primary_Address_Line_3__c = 'Address_Line_3', Primary_City__c = 'City', Primary_State_Province__c = 'State',
            Primary_Postal_Code__c = 'Zip', Primary_Country__c = 'Country');
        INSERT cont;
        Project_Role__c role = new Project_Role__c(Project__c = project.Id, Contact__c = cont.Id,
            SIAM_Portal_Status__c = 'Active', Project_Type__c = 'CPM', Role__c = 'Other');
        INSERT role;
        
        Test.startTest();

        String jsonString = '{"Command":"DeactivateContact","CrimsonEmail":"' + cont.SIAM_Email__c + '"}';
        ApexPages.currentPage().getParameters().put('req', CommonAuthHelper.Encode(jsonString));
        
        CommonAuthController controller = new CommonAuthController();
        PageReference pageReference = controller.process();
        
        Test.stopTest();
        
        String jsonReturn = CommonAuthHelper.Decode(controller.JSONResponse);
        system.debug('@@jsonReturn: ' + jsonReturn);
        
        Contact c2 = [SELECT Id, AccountId, SIAM_GUID__c, SIAM_Email__c, Counter_Id__c FROM Contact
                      WHERE id = :cont.Id LIMIT 1];
        Project_Role__c r2 = [SELECT SIAM_Portal_Status__c FROM Project_Role__c
                      WHERE id = :role.Id LIMIT 1];
        
        System.assert(jsonReturn.indexOf('"Successful":true') > 0);
        System.assertEquals(null, c2.SIAM_Email__c);
        System.assertEquals(null, c2.SIAM_GUID__c);
        System.assertEquals('Inactive', r2.SIAM_Portal_Status__c);
    }
   
    static testMethod void testEncodeDecode() {
        String myText = 'This is my original text';
        System.assertEquals(myText, CommonAuthHelper.Decode(CommonAuthHelper.Encode(myText)));
    }
    
    static testMethod void testCommonAuthSyncContactRequest_fromJSON() {
        String jsonString = '{"Command":"SyncContact","CrimsonGuid":"9E8BBCCC-AD2F-4FF9-9D42-98CB58381931",' +
            '"CrimsonEmail":"someone@abc.com","FirstName":"FirstName","LastName":"LastName",' + 
            '"ProjectIds":[ "a0UC000000BMFJF","a0UC000000BMFJG" ]}';
        CommonAuthSyncContactRequest request = CommonAuthSyncContactRequest.fromJSON(jsonString);
        System.assertEquals('SyncContact', request.Command);
        System.assertEquals('9E8BBCCC-AD2F-4FF9-9D42-98CB58381931', request.CrimsonGuid);
        System.assertEquals('someone@abc.com', request.CrimsonEmail);
        System.assertEquals('FirstName', request.FirstName);
        System.assertEquals('LastName', request.LastName);
        System.assertEquals(2, request.ProjectIds.size());
        System.assertEquals('a0UC000000BMFJF', request.ProjectIds.get(0));
        System.assertEquals('a0UC000000BMFJG', request.ProjectIds.get(1));
    }
    
    static testMethod void testCommonAuthDeactivateContactRequest_fromJSON() {
        String jsonString = '{"Command":"DeactivateContact","CrimsonEmail":"someone@abc.com"}';
        CommonAuthDeactivateContactRequest request = CommonAuthDeactivateContactRequest.fromJSON(jsonString);
        System.assertEquals('DeactivateContact', request.Command);
        System.assertEquals('someone@abc.com', request.CrimsonEmail);
    }

    static testMethod void testCommonAuthBaseRequest_fromJSON() {
        String jsonString = '{"CrimsonGuid":"9E8BBCCC-AD2F-4FF9-9D42-98CB58381931","CrimsonEmail":"someone@abc.com",' +
            '"FirstName":"FirstName","LastName":"LastName","ProjectIds":[ "a0UC000000BMFJF","a0UC000000BMFJG" ],' +
            '"Command":"SyncContact"}';
        CommonAuthBaseRequest request = CommonAuthBaseRequest.fromJSON(jsonString);
        System.assertEquals('SyncContact', request.Command);
    }
    
    static testMethod void testCommonAuthSyncContactResponse_toJSON() {
        CommonAuthSyncContactResponse response = new CommonAuthSyncContactResponse();
        response.Successful = true;
        response.ContactDetail.SFContactId = 'a0UC000000BMFJF';
        response.ContactDetail.CounterId = 'C0000001';
        response.ContactDetail.SFAccountId = 'a0UC000000BMFJG';
        String jsonString = response.toJSON();
        System.assert(jsonString.indexOf('"Successful":true') > 0);
        System.assert(jsonString.indexOf('"ErrorMessage":null') > 0);
        System.assert(jsonString.indexOf('"ContactDetail":{') > 0);
        System.assert(jsonString.indexOf('"SFContactId":"a0UC000000BMFJF"') > 0);
        System.assert(jsonString.indexOf('"CounterId":"C0000001"') > 0);
        System.assert(jsonString.indexOf('"SFAccountId":"a0UC000000BMFJG"') > 0);
    }
    
    static testMethod void testCommonAuthDeactivateContactResponse_toJSON() {
        CommonAuthDeactivateContactResponse response = new CommonAuthDeactivateContactResponse();
        response.Successful = true;
        String jsonString = response.toJSON();
        System.assert(jsonString.indexOf('"Successful":true') > 0);
        System.assert(jsonString.indexOf('"ErrorMessage":null') > 0);
    }
}