@IsTest(SeeAllData=true)
public class BluebookController_TestUtilities {
    public static testmethod void TestLoadData() { 
        //Bypass Dupeblocker
        Util.IsTest(true);
        Account a = new Account(
            Name = 'Institution1',
            Account_Formal_Name__c = 'test',
            Blue_Book_Institution_ID__c = 'BBId1');
        insert a;
    
        BluebookController ctl = new BluebookController();
        ctl.InTestMode = true;
        ctl.loadData();
        
        System.Assert(ctl.Result.indexOf('Page is downloaded successfully.') == 0);
        System.Assert(ctl.Result.indexOf('There are 3 bluebook items.') > 0);
    }
}