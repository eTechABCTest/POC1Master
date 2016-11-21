/**
    Purpose:        Helper class for the CaseComment trigger.(CR-4283)
                
    Create By:      Victor Hanson
    
    Created Date:   06/02/2014
    
    Current Version : V1.1
    
    Revision Log:   v1.0 - VH - 06/02/2014 - Created
                    v1.1 - Modified By - Abhinav Sharma - 07/07/2014 - CR-20140618-5849 - Catch DML errors in triggers to reduce exception emails to SFAdmin
                    v1.2 - Modified By - Mahendra Swarnkar - 7/4/2016 -  CR-20160603-9890 - Added populateMostRecentPublicCaseComment method
                    v1.3 - Modified By - Abhinav Sharma - 09/05/2016 - CR-20160114-9520
**/
trigger CaseComment on CaseComment (after insert, after update, after delete) {

    try {
      
      //By Pass trigger check
      if (Util.BypassAllTriggers) return;
      
      //Check evevt type
        if (trigger.isAfter) {
            
            //Added By - Abhinav Sharma - 09/05/2016 - CR-20160114-9520
            //Start from here
            //Checking for the request type
            //Calling helper class method to populate "First_Comment_Date_Time__c" on parent case
            if(Trigger.isInsert)
              CaseCommentTriggerHelper.populateFirstCommentDateTimeOnParentCase(trigger.new);
            //Upto here
            
            //Check request type
            if(Trigger.isInsert || Trigger.isUpdate){
            
              //update the case comment notify flag on the case CR-4283
              CaseCommentTriggerHelper.populateCaseCommentNotify(trigger.new, trigger.oldMap);
          }
        
          //Added by Mahendra Swarnkar 7/4/2016 - CR-20160603-9890  
          if(Trigger.isInsert || Trigger.isUpdate || Trigger.isDelete) {
                  
                  //Calling helper class method to populate Most Recent CaseComment on member support
                  CaseCommentTriggerHelper.populateMostRecentPublicCaseComment(Trigger.New, Trigger.oldMap);        
      }
        }
    
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