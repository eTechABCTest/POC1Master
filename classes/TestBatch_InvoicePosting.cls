@isTest(seeAllData = true)
private class TestBatch_InvoicePosting {

    static testmethod void testInvoicePosting() {

        try {
            c2g__codaCompany__c company = [SELECT Id FROM c2g__codaCompany__c
                                           WHERE Name = 'The Advisory Board Company'];
            c2g__codaAccountingCurrency__c accountingCurrency = [SELECT Id FROM c2g__codaAccountingCurrency__c
                                                                 WHERE c2g__OwnerCompany__c = : company.Id AND Name='USD'];
            c2g__codaPeriod__c period = [SELECT c2g__Closed__c, Id FROM c2g__codaPeriod__c
                                         WHERE c2g__Closed__c = false AND c2g__Description__c ='Trading Period'
                                         AND c2g__OwnerCompany__c = : company.Id LIMIT 1];
            
            // greate a general ledger account for the c2g__CODAAccountsReceivableControl__c field on acct
            c2g.CODAAPIGeneralLedgerAccountTypes_3_0.enumType balanceSheet = 
                c2g.CODAAPIGeneralLedgerAccountTypes_3_0.enumType.BalanceSheet;
            c2g.CODAAPIGeneralLedgerAccountTypes_3_0.GeneralLedgerAccount glAcctStub =
                new c2g.CODAAPIGeneralLedgerAccountTypes_3_0.GeneralLedgerAccount();
            glAcctStub.BalanceSheet1 = '1';
            glAcctStub.Name = 'Test General Ledger 1';
            glAcctStub.ReportingCode = 'ABC-1234567890';
            glAcctStub.TypeRef = balanceSheet;
            c2g.CODAAPICommon.Reference glAcctRef = 
                c2g.CODAAPIGeneralLedgerAccount_3_0.CreateGeneralLedgerAccount(null, glAcctStub);
            c2g__codaGeneralLedgerAccount__c glAccount = new c2g__codaGeneralLedgerAccount__c();
            glAccount.c2g__ExternalId__c = glAcctRef.Id;
            glAccount.c2g__ReportingCode__c = 'ABC-1234567890-1';
            glAccount.c2g__Type__c = 'Balance Sheet';
            insert glAccount;
            
            Account a = new Account(Name = 'Test Account 1', Account_Formal_Name__c = 'Test Account',
                                    c2g__CODAAccountsReceivableControl__c = glAccount.Id,
                                    c2g__CODAAccountTradingCurrency__c = 'USD');
            insert a;
            
            Contact con = new Contact(AccountId = a.Id, FirstName = 'Test', LastName = 'Contact');
            insert con;
            
            Program__c p = new Program__c(Name = 'Test Program');
            insert p;
            
            Contract__c c = new Contract__c(Name = 'DAF Test', Payer_Account__c = a.Id, Status__c = 'ATL', Exchange_Rate__c = 1.0,
                                            Negotiated_Amount__c = 1000.0, Type__c = 'NBB', Start__c = date.today(),
                                            End__c = date.today(), Year__c = '2015', Join_Date__c = date.today(), 
                                            Main_Contact__c = con.Id, Invoice_Contact__c = con.Id, Program__c = p.Id);
            insert c;
            
            Product2 prod = [SELECT Id, Name FROM Product2 Limit 1]; 
            prod.c2g__CODASalesRevenueAccount__c = glAccount.Id;
            update prod;
            
            c2g__codaInvoice__c salesinvoice = new c2g__codaInvoice__c(c2g__Account__c = a.Id, c2g__Period__c = period.Id,
                c2g__InvoiceStatus__c = 'In Progress', ContractABC__c = c.Id, c2g__InvoiceCurrency__c = accountingCurrency.Id, 
                c2g__UsePartPeriods__c = false);
            insert salesinvoice;
            system.debug('##salesinvoice: ' + salesinvoice.id);
    /*        
            // Create directly
            c2g__codaInvoiceLineItem__c salesinvoiceitem = new c2g__codaInvoiceLineItem__c(c2g__Quantity__c = 1,
                c2g__TaxValue1__c = 0, c2g__Invoice__c = salesinvoice.Id, c2g__Product__c = prod.Id, c2g__UnitPrice__c = 10);
            insert salesinvoiceitem;
    */
            //Use API
            c2g.CODAAPICommon.Reference refInvoice = new c2g.CODAAPICommon.Reference();
            refInvoice.Id = salesinvoice.Id;
            c2g.CODAAPIInvoiceTypes_10_0.Invoice invoice = c2g.CODAAPISalesInvoice_10_0.GetInvoice(null, refInvoice);

            c2g.CODAAPIInvoiceLineItemTypes_10_0.InvoiceLineItem salesinvoiceitem = 
                new c2g.CODAAPIInvoiceLineItemTypes_10_0.InvoiceLineItem();
            salesinvoiceitem.Product = new c2g.CODAAPICommon.Reference(); 
            salesinvoiceitem.Product.Id = prod.Id; 
            salesinvoiceitem.UnitPrice = 200; 
            salesinvoiceitem.Quantity = 1; 
            salesinvoiceitem.LineDescription = '1 $200 Widget'; 
            salesinvoiceitem.TaxValue1 = 0; 
            salesinvoiceitem.UsePartPeriods = false; 
            invoice.LineItems.LineItemList.add(salesinvoiceitem);

            c2g.CODAAPICommon.Reference ref;
            //Create the Sales Invoice via the API 
            try {
            ref = c2g.CODAAPISalesInvoice_10_0.UpdateInvoice(null, invoice); 
            } catch(Exception e) {}

            system.debug('##salesinvoice after adding LineItems: ' + c2g.CODAAPISalesInvoice_10_0.GetInvoice(null, refInvoice));

test.StartTest(); 
            Batch_InvoicePosting batch = new Batch_InvoicePosting();
            batch.query = 'SELECT id FROM c2g__codaInvoice__c where id = \'' + salesinvoice.id + '\'';       
            Id batchId = Database.executeBatch(batch, 1);
            system.debug('##c2g__codaInvoice__c: ' + salesinvoice.id);
test.StopTest();

            c2g__codaInvoice__c invoice2 = [SELECT c2g__InvoiceStatus__c FROM c2g__codaInvoice__c
                                                  where id = :salesinvoice.id];
            system.assertEquals('Complete', invoice2.c2g__InvoiceStatus__c);
        }
        catch(Exception e){}
    }
    
    static testmethod void testInvoicePosting_InvalidData() {

        try {
            c2g__codaCompany__c company = [SELECT Id FROM c2g__codaCompany__c
                                           WHERE Name = 'The Advisory Board Company'];
            c2g__codaAccountingCurrency__c accountingCurrency = [SELECT Id FROM c2g__codaAccountingCurrency__c
                                                                 WHERE c2g__OwnerCompany__c = : company.Id AND Name='USD'];
            c2g__codaPeriod__c period = [SELECT c2g__Closed__c, Id FROM c2g__codaPeriod__c
                                         WHERE c2g__Closed__c = false AND c2g__Description__c ='Trading Period'
                                         AND c2g__OwnerCompany__c = : company.Id LIMIT 1];
            
            // greate a general ledger account for the c2g__CODAAccountsReceivableControl__c field on acct
            c2g.CODAAPIGeneralLedgerAccountTypes_3_0.enumType balanceSheet = 
                c2g.CODAAPIGeneralLedgerAccountTypes_3_0.enumType.BalanceSheet;
            c2g.CODAAPIGeneralLedgerAccountTypes_3_0.GeneralLedgerAccount glAcctStub =
                new c2g.CODAAPIGeneralLedgerAccountTypes_3_0.GeneralLedgerAccount();
            glAcctStub.BalanceSheet1 = '1';
            glAcctStub.Name = 'Test General Ledger 1';
            glAcctStub.ReportingCode = 'ABC-1234567890';
            glAcctStub.TypeRef = balanceSheet;
            c2g.CODAAPICommon.Reference glAcctRef = 
                c2g.CODAAPIGeneralLedgerAccount_3_0.CreateGeneralLedgerAccount(null, glAcctStub);
            c2g__codaGeneralLedgerAccount__c glAccount = new c2g__codaGeneralLedgerAccount__c();
            glAccount.c2g__ExternalId__c = glAcctRef.Id;
            glAccount.c2g__ReportingCode__c = 'ABC-1234567890-1';
            glAccount.c2g__Type__c = 'Balance Sheet';
            insert glAccount;
            
            Account a = new Account(Name = 'Test Account 1', Account_Formal_Name__c = 'Test Account',
                                    c2g__CODAAccountsReceivableControl__c = glAccount.Id,
                                    c2g__CODAAccountTradingCurrency__c = 'USD');
            insert a;
            
            Contact con = new Contact(AccountId = a.Id, FirstName = 'Test', LastName = 'Contact');
            insert con;
            
            Program__c p = new Program__c(Name = 'Test Program');
            insert p;
            
            Contract__c c = new Contract__c(Name = 'DAF Test', Payer_Account__c = a.Id, Status__c = 'ATL', Exchange_Rate__c = 1.0,
                                            Negotiated_Amount__c = 1000.0, Type__c = 'NBB', Start__c = date.today(),
                                            End__c = date.today(), Year__c = '2015', Join_Date__c = date.today(), 
                                            Main_Contact__c = con.Id, Invoice_Contact__c = con.Id, Program__c = p.Id);
            insert c;
            
            c2g__codaInvoice__c salesinvoice = new c2g__codaInvoice__c(c2g__Account__c = a.Id, c2g__Period__c = period.Id,
                c2g__InvoiceStatus__c = 'In Progress', ContractABC__c = c.Id, c2g__InvoiceCurrency__c = accountingCurrency.Id, 
                c2g__UsePartPeriods__c = false);
            insert salesinvoice;
            system.debug('##salesinvoice: ' + salesinvoice.id);

test.StartTest(); 
            Batch_InvoicePosting batch = new Batch_InvoicePosting();
            batch.query = 'SELECT id FROM c2g__codaInvoice__c where id = \'' + salesinvoice.id + '\'';       
            Id batchId = Database.executeBatch(batch, 1);
            system.debug('##c2g__codaInvoice__c: ' + salesinvoice.id);
test.StopTest();

            c2g__codaInvoice__c invoice2 = [SELECT c2g__InvoiceStatus__c FROM c2g__codaInvoice__c
                                                  where id = :salesinvoice.id];
            system.assertEquals('In Progress', invoice2.c2g__InvoiceStatus__c);
        }
        catch(Exception e){}
    }  
}