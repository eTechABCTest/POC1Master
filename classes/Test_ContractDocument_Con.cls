@isTest
private class Test_ContractDocument_Con
{
    /*
    Purpose:    Test Controller for a Visualforce page that combines creation of a Contract_Document__c record with attachment of a file to the newly-created record.
                    Page: ContractDocumemt
    
    Create By:  Yogesh (Synaptic) - 12/2010
    
    Last Modified By:   Nathan Banas (Synaptic) - 1/24/2011
    
    Current Version:    v1.1
    
    Revision Log:       v1.0 - (Yogesh) Created this controller class and accompanying test and VF modules
                        v1.1 - (Nathan Banas) Added comments and this header
    
    Code Coverage as of 1/24/2011: 100%
    */
  
    public static testmethod void DoTest()
    {
        Util.IsTesting = true;
     
        // Create Account
        Account acc = new Account();
        acc.Name='Test Trigger Account1';
        acc.Account_Formal_Name__c='Test Trigger Account1';
        acc.Primary_City__c = 'Washington';
        acc.Primary_State_Province__c = 'DC';
            
        insert acc;
         
        system.assert(acc.Id != null);
         
        // Create opportunity   
        Opportunity opp = new Opportunity();
        opp.AccountId = acc.Id;
        opp.Name = 'test';
        opp.CloseDate = system.today();
        opp.StageName = 'New';
         
        insert opp;
         
        system.assert(opp.Id != null);
         
         
        ApexPages.CurrentPage().getParameters().put('id',opp.Id);
         
        // Initialize object
        ContractDocument_Con cls = new ContractDocument_Con();
         
        cls.CurrentContractDocument.Name = 'Test';
        cls.CurrentContractDocument.Name__c = 'Test';
        cls.CurrentContractDocument.Account__c = acc.Id;
        cls.CurrentContractDocument.Type__c = 'Terms of Agreement';
        cls.CurrentContractDocument.Comments__c = 'Test';
        cls.CDAttachment.Name = 'Test.txt';
         
        blob blb = blob.valueof('test');
        cls.CDAttachment.body = blb;
         
        try
        {
            PageReference pr = cls.DoSave();
            system.assert(pr != null);
        }   
        catch(Exception ex)
        {
            system.debug(ex.getMessage());
        }
         
        try
        {
            PageReference pr = cls.DoCancel();  
           
            system.assert(pr != null);
        }   
        catch(Exception ex)
        {
            system.debug(ex.getMessage());
        }
    }
 
    public static testmethod void DoTest2()
    {
    
        Util.IsTesting = true;
     
        // Create Account
        Account acc = new Account();
        acc.Name='Test Trigger Account1';
        acc.Account_Formal_Name__c='Test Trigger Account1';
        acc.Primary_City__c = 'Washington';
        acc.Primary_State_Province__c = 'DC';
            
        insert acc;
         
        system.assert(acc.Id != null);
         
        // Create opportunity   
        Opportunity opp = new Opportunity();
        opp.AccountId = acc.Id;
        opp.Name = 'test';
        opp.CloseDate = system.today();
        opp.StageName = 'New';
         
        insert opp;
         
        system.assert(opp.Id != null);
         
         
        ApexPages.CurrentPage().getParameters().put('id',opp.Id);
         
        // Initialize object
        ContractDocument_Con cls = new ContractDocument_Con();
         
        cls.CurrentContractDocument.Name = 'Test';
        cls.CurrentContractDocument.Name__c = 'Test';
        cls.CurrentContractDocument.Account__c = acc.Id;
        cls.CurrentContractDocument.Type__c = 'Terms of Agreement';
        cls.CurrentContractDocument.Comments__c = 'Test';
        cls.CDAttachment.Name = 'Test.txt';
         
        try
        {
            PageReference pr = cls.DoSave();    
        }   
        catch(Exception ex)
        {
            system.debug(ex.getMessage());
        }
         
        try
        {
            PageReference pr = cls.DoCancel();  
           
            system.assert(pr != null);
        }   
        catch(Exception ex)
        {
            system.debug(ex.getMessage());
        }
    } 
  
    public static testmethod void DoTest3()
    {
        Util.IsTesting = true;
         
        // Create Account
        Account acc = new Account();
        acc.Name='Test Trigger Account1';
        acc.Account_Formal_Name__c='Test Trigger Account1';
        acc.Primary_City__c = 'Washington';
        acc.Primary_State_Province__c = 'DC';
            
        insert acc;
         
        system.assert(acc.Id != null);
         
        // Create opportunity   
        Opportunity opp = new Opportunity();
        opp.AccountId = acc.Id;
        opp.Name = 'test';
        opp.CloseDate = system.today();
        opp.StageName = 'New';
         
        insert opp;
         
        system.assert(opp.Id != null);
         
         
        ApexPages.CurrentPage().getParameters().put('id',opp.Id);
         
        // Initialize object
        ContractDocument_Con cls = new ContractDocument_Con();
         
        cls.CurrentContractDocument.Name = 'Test';
        cls.CurrentContractDocument.Name__c = 'Test';
        cls.CurrentContractDocument.Account__c = acc.Id;
        cls.CurrentContractDocument.Type__c = 'Terms of Agreement';
        cls.CurrentContractDocument.Comments__c = 'Test';
        
        try
        {
            PageReference pr = cls.DoSave();    
        }   
        catch(Exception ex)
        {
            system.debug(ex.getMessage());
        }
         
        try
        {
           PageReference pr = cls.DoCancel();   
           
           system.assert(pr != null);
        }   
        catch(Exception ex)
        {
            system.debug(ex.getMessage());
        }
    }
}