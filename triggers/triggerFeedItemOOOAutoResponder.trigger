//V1.0 - Created
//V1.1 - Modified By - Abhinav Sharma - 07/07/2014 - CR-20140618-5849 - Catch DML errors in triggers to reduce exception emails to SFAdmin
trigger triggerFeedItemOOOAutoResponder on FeedItem (after insert) {

    try {

        // bypass flag
        if (Util.BypassAllTriggers) return;
        
        //Calling Helper Class Method
        ChatterHelper.OOOAutoRespondFeedItems(Trigger.newMap.keySet());
    
    //Catching DML Exceptions
    } catch(DMLException e) {

        //Add Error Message on Page
        if(Trigger.isDelete)
            Trigger.Old[0].addError(e.getDmlMessage(0));
        else
            Trigger.New[0].addError(e.getDmlMessage(0));

    //Catching all Exceptions
    } catch(Exception e) {

        //Add Error Message on Page
        if(Trigger.isDelete)
            Trigger.Old[0].addError(e.getMessage());
        else
            Trigger.New[0].addError(e.getMessage());
    }
}