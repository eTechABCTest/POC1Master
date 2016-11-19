trigger Program_BatchFields on Program__c (after insert, before insert, before update, after delete)
{
    /*
    Purpose:    Update Program Name with the following criteria: <Program_Acronym__c> - <Program_Formal_Name__c>;
                Create Memberships via batch for Programs on Insert
                Update Memberships via batch for Programs where:
                    - The New Business Marketer has changed
                    - The Program is being created
                    - The Program is being deleted
    
    Create By:          
    
    Last Modified By:   Nathan Banas (SAP) - 1/25/2011
    
    Current Version:    v1.4
    
    Revision Log:       v1.0 - () Created code
                        v1.1 - (NB-2011-01-25) - Added header, code comments, and reviewed code coverage
                        v1.2 - Simplyforce Technology - Bhavi - CR-20110912-12
                        v1.3 - Abhinav Sharma - 02/12/2014 - CR-20130718-3280
                        v1.4 - Modified By - Abhinav Sharma - 07/07/2014 - CR-20140618-5849 - Catch DML errors in triggers to reduce exception emails to SFAdmin
                        
    */
    
    try {
    
        // bypass flag
        if (Util.BypassAllTriggers) return;
        
        //Before delete
        set<id> progidstoupdate = new set<id>();
        set<id> progidstodelete = new set<id>();
        
        //If this is After Trigger, run the Make Memberships batch
        If (Trigger.IsInsert && Trigger.IsAfter)
        {
            //Make set of program ids with qualifications
            set<id> progids = new set<Id>();
            
            for (Program__c prog : Trigger.new)
            {
                if (prog.Create_memberships__c == 'Yes' && prog.Applicable_Segments__c != null)
                    progids.add(prog.id);
            }
            
            if (!Util.IsTesting) {
                
                //Bhavi Sharma - 04/26/2013 - CR-20130227-2597 - Added condition to make the callout only if not current context is not batch or future
                if(!System.isFuture() && !System.isBatch()) {
                    
                    //Run batch create on qualifying Programs
                    //Modified By Abhinav Sharma - 02/12/2014 - Added batch size 50 - CR-20130718-3280
                    Id batchprocessId = Database.executeBatch(new Batch_MakeMemberships(progids), 50);
                }
            }
        }
        
        //If Before Trigger, do field updates
        if (Trigger.IsBefore)
        {
            
            // schedule the batch to populate program abbreviation on all related events associated with opps that contain this programs
            ProgramTriggerHelper.scheduleProgramAbbreviationJob(trigger.new, trigger.oldMap);
            
            //We'll need a map of New Business Marketer roles by Program for Assigned Marketer later
            map<Id, String> progid2lookuprole = new map<Id, String>();
            
            // Loop through each Program that called this trigger
            for (Program__c prog : Trigger.new)
            {
                //New record or changed Program Acronym requires recalced name
                //Simplyforce Technology - Bhavi : Updated trigger to include the logic for executing the code on Program_Formal_Name__c field change
                prog.Name = prog.Program_Acronym__c + ' - ' + prog.Program_Formal_Name__c;
                
                //Changed New Business Marketer requires changing Membership field value
                if (Trigger.IsUpdate && Trigger.newmap.get(prog.id).New_Business_Marketer__c != Trigger.oldmap.get(prog.id).New_Business_Marketer__c)
                    progidstoupdate.add(prog.id);
                
            }//end for prog : Trigger.new
            
            //Update Assigned Marketers via batch (if necessary)
            if (progidstoupdate.size() > 0 && !Util.IsTesting) {
                
                //Bhavi Sharma - 04/26/2013 - CR-20130227-2597 - Added condition to make the callout only if not current context is not batch or future
                if(!System.isFuture() && !System.isBatch())
                    Id batchprocessid = Database.executeBatch(new Batch_UpdateMemberships(progidstoupdate, 'update'));
            }
    
        }//end if isbefore
        
        if(Trigger.isDelete && Trigger.isAfter)
        {
        System.debug('---------------- Step1');
            for (Program__c prog : Trigger.old)
            {
                //Deleting record requires deleting Memberships
                if (Trigger.IsDelete)
                    progidstodelete.add(prog.id);   
            }
            
            //Delete Memberships via batch (if necessary)
            if (progidstodelete.size() > 0 && !Util.IsTesting)
             //   Id batchprocessid = Database.executeBatch(new Batch_UpdateMemberships(progidstodelete, 'delete'));
             
             //SFDC Testing
            // Id batchprocessid = Database.executeBatch(new SFDC_Batch_UpdateMemberships(progidstodelete, 'delete'));
            
            System.debug('test');
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