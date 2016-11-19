/**
 *  Purpose         :   Test class for Sched_SentEmailTimeCardPreReminder
 *
 *  Created By      :   Mahendra Swarnkar
 *  
 *  Created Date    :   09/20/2016
 *
 *  Revision Log    :   V1.0 - Created By - Mahendra Swarnkar - CR-20160609-9909  
 *
 *  Code Coverage   :   100 %
 *
 **/
@isTest(SeeAllData = false)
private  class Test_Sched_SentEmailTimeCardPreReminder {
    
    static testMethod void myUnitTest() {
        
        //Insert contact 
        List<Contact> contacts = new List<Contact>();
        Contact con = TestUtilities.CreateNewContact(false);
        con.Contact_Status__c = 'Active';
        con.Email = 'Test@test.com';
        con.pse__Is_Resource__c = true;
        insert con;
        
        //Test starts from here
        Test.startTest();
        
        //instance of Scheduler
        Sched_SentEmailTimeCardPreReminder sh1 = new Sched_SentEmailTimeCardPreReminder();
        
        //Cron expression string
        String sch = '0 0 23 * * ?';
        
        //schedule the scheduler
        system.schedule('Test Schedule', sch, sh1);
        
        //Test stops from here
        Test.stopTest(); 
    }
}