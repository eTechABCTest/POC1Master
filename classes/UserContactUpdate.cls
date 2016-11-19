global class UserContactUpdate implements Database.Batchable<sObject>{
    date runDate = date.today();
    
    global UserContactUpdate(date runDateParameter){
        if(runDateParameter != null)runDate=runDateParameter;
    }

    global Iterable<sObject> start (Database.Batchablecontext BC){
        integer queryLimit = 10000;
        if(Test.isRunningTest() == true)queryLimit = 5;
        //query  users
        list<user> usersToRunFlow = new list<user>([
            SELECT id, Alias FROM user WHERE IsPortalEnabled <> true AND isActive = true AND alias = 'SFADMIN' LIMIT :queryLimit]);
        return usersToRunFlow;
    }
    global void execute(Database.BatchableContext BC, List<user> scope){
        for(user u :scope){
            Map<String, Object> myMap = new Map<String, Object>();
            myMap.put('userid', u.id);
           // myMap.put('RunDate', runDate);
            Flow.Interview.ContactPermissionSetOOTOupdate myFlow;
            myFlow = new Flow.Interview.ContactUpdate(myMap);
            try{
            myFlow.start();
            }catch(exception e){
                        system.debug('ContactUpdate flow error user='+u.id);
            }
        }
    }

    global void finish (Database.Batchablecontext BC){
        AsyncApexJob a = [Select Id
                          ,Status
                          ,NumberOfErrors
                          ,JobItemsProcessed
                          ,TotalJobItems
                          ,CreatedBy.Email
                          from AsyncApexJob where Id =
                          :BC.getJobId()];
        // Create and send an email with the results of the batch.
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        
        mail.setToAddresses(new String[] {'sfadmin@advisory.com'});
        mail.setReplyTo('sfadmin@advisory.com');
        mail.setSenderDisplayName('Contact Update Batch');
        mail.setSubject('Contact Update Batch ' + a.Status);
        mail.setPlainTextBody('The batch apex job processed ' + a.TotalJobItems +' batches with ' + a.NumberofErrors + ' failures.');
 
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });     
    }


/*  
    //To run this from console
    UserContactUpdate b = new UserContactUpdate(null);
    //OR
    UserContactUpdate b = new UserContactUpdate(date.newinstance(1960, 2, 17));
    Database.executeBatch(b,50);
*/

}