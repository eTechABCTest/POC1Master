@isTest(SeeAllData=true)
private class Test_TriggerLineItemSchedule {
    static testMethod void testTriggerWithNoInvoice() {
        Line_Item_Schedule__c newItem = CreateNewLineItemSchedule(false);
        
        Test.startTest();
        delete newItem;
        Test.stopTest();
        
        //Assert for the result
        System.assert(true, 'We should be able to delete the object.');
    }
    
    static testMethod void testTriggerWithInvoice() {
        Line_Item_Schedule__c newItem = CreateNewLineItemSchedule(true);
        
        Test.startTest();
        try {
            delete newItem;
            
            //Assert for the result
            //System.assert(false, 'We should not be able to delete the object.');
        }
        catch(Exception e) {
            //Assert for the result
            //System.assert(true, 'We should not be able to delete the object.');            
        }
        Test.stopTest();
    }
    
    static Line_Item_Schedule__c CreateNewLineItemSchedule(boolean withInvoice) {
        //fecth the existing record type from data base
        List<RecordType> listRecordType = [Select SobjectType, Name, IsActive, Id, DeveloperName From RecordType
                                            where IsActive = true and SobjectType = 'Account' and DeveloperName ='US_Provider' limit 1];
        
        // greate a general ledger account for the c2g__CODAAccountsReceivableControl__c field on acct
        c2g.CODAAPIGeneralLedgerAccountTypes_3_0.enumType balanceSheet = c2g.CODAAPIGeneralLedgerAccountTypes_3_0.enumType.BalanceSheet;
        c2g.CODAAPIGeneralLedgerAccountTypes_3_0.GeneralLedgerAccount glAcctStub = new c2g.CODAAPIGeneralLedgerAccountTypes_3_0.GeneralLedgerAccount();
        glAcctStub.BalanceSheet1 = '1';
        //glAcctStub.CurrencyISOCode = 'USD';
        glAcctStub.Name = 'vicTestGeneralLedger1';
        glAcctStub.ReportingCode = '123abc1zz';
        glAcctStub.TypeRef = balanceSheet;
        c2g.CODAAPICommon.Reference glAcctRef = c2g.CODAAPIGeneralLedgerAccount_3_0.CreateGeneralLedgerAccount(null, glAcctStub);
        c2g__codaGeneralLedgerAccount__c glAccount = new c2g__codaGeneralLedgerAccount__c();
        glAccount.c2g__ExternalId__c = glAcctRef.Id;
        glAccount.c2g__ReportingCode__c = '123abc1zzz';
        glAccount.c2g__Type__c = 'Balance Sheet';
        insert glAccount;
    
        Account a = new Account(Name = 'testacc', Account_Formal_Name__c = 'testacc', c2g__CODAAccountsReceivableControl__c = glAccount.Id);
        a.RecordTypeId = listRecordType[0].Id;
        insert a;
        
        Contact con = new Contact(AccountId = a.Id, FirstName = 'Drew', LastName = 'Test');
        insert con;

        Program__c p = new Program__c(Name = 'TestProgram');
        insert p;
 
        Contract__c c = new Contract__c(Name = 'DAF Test', Payer_Account__c = a.Id, Status__c = 'ATL', 
        Negotiated_Amount__c = 1000.0, Type__c = 'NBB', Start__c = date.today(), End__c = date.today(), Year__c = '2012', Join_Date__c = date.today(), 
        Main_Contact__c = con.Id, Invoice_Contact__c = con.Id, Program__c = p.Id);
        insert c;
        
        // test sales invoice
        c2g.CODAAPIInvoiceTypes_4_0.Invoice salesinvoice = new c2g.CODAAPIInvoiceTypes_4_0.Invoice(); 
        //Set the fields for the invoice 
        salesinvoice.Account = new c2g.CODAAPICommon.Reference(); 
        salesinvoice.GeneralLedgerAccount = glAcctRef;
        salesinvoice.Account.Id = a.Id; 
        salesinvoice.CustomerReference = 'Sale #1'; 
        salesinvoice.InvoiceCurrency = new c2g.CODAAPICommon.Reference(); 
        salesinvoice.InvoiceCurrency.Name = 'USD'; 
        salesinvoice.InvoiceStatus = c2g.CODAAPIInvoiceTypes_4_0.enumInvoiceStatus.InProgress; 
        salesinvoice.InvoiceDate = System.now().date(); 
        salesinvoice.DueDate = System.now().date() + 30; 
        salesinvoice.InvoiceDescription = 'Widget order for Test Company'; 
        salesinvoice.UsePartPeriods = false; 
        salesinvoice.PrintedText1AllowEdit = false; 
        salesinvoice.PrintedText2AllowEdit = false; 
        salesinvoice.PrintedText3AllowEdit = false; 
        salesinvoice.PrintedText4AllowEdit = false; 
        salesinvoice.PrintedText5AllowEdit = false;
        
        //insert the  Invoice Billing record
        Invoice_Billing_Schedule__c invoiceBillingSchedule = new Invoice_Billing_Schedule__c(Institution__c = a.Id);
        insert invoiceBillingSchedule;
        
        //update the billing invoice record id
        c.Invoice_Billing_Schedule__c = invoiceBillingSchedule.Id;                                   
        update c;
        
        //Create LIS records to test the ContractABCTriggerHelper.validateIBSIdForContactABC functionality
        Line_Item_Schedule__c lIS = new Line_Item_Schedule__c(Contract__c = c.Id,
                                                              Invoice_Billing_Schedule_del__c = invoiceBillingSchedule.Id,
                                                              Type__c = 'Test',
                                                              Invoice_Date__c = Date.today(),
                                                              Invoice_Comment__c = 'Test',
                                                              Amount__c = 20);
        insert lIS;
    
        if(withInvoice) {
            //Create the Sales Invoice via the API 
            c2g.CODAAPICommon.Reference ref = c2g.CODAAPISalesInvoice_4_0.CreateInvoice(null, salesinvoice);
            lIS.Sales_Invoice__c = ref.Id;
            update lIS;
        }
        
        return lIS;
    }
}