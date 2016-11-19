/*
    Purpose         -   This Batch is update the Opportunities field Active Renewal which are associated with Memberships
                        with specific criteria.     
    
    Create By       -   Bhavi Sharma  
    
    Created Date    -   05/01/2013 
    
    Current Version -   v1.0 -  CR-20130408-2835      
                        v1.1 - Modified By - Abhinav Sharma - CR-20140502-5327 - 07/02/2014 
    
*/
global class Batch_OpportunityPopulateRenewalFlag implements Database.Batchable<SObject>, Database.Stateful {
    
    //String variable to hold the entire log message string value
    global String debugLog;
    
    //Batch Constructor
    global Batch_OpportunityPopulateRenewalFlag() {
        debugLog = '';
    }
    
    //Start Method
    global Database.Querylocator start(Database.BatchableContext BC){
        
        //return query result
        return Database.getQueryLocator([SELECT Id From Membership__c]);
    }
    
    //Execute Logic
    global void execute(Database.BatchableContext BC, List<SObject> scope) {
        
        //String variable to hold the error message string in case of any failure
        String logMessage = '';
        
        //List of Membership
        List<Membership__c> listMembership = (List<Membership__c>)scope;
        
        //Set of Record type Name
        Set<String> setRecordTypeName = new Set<String>();
        setRecordTypeName.add(Constants.RECORD_TYPE_OPPORTUNITY_PT_CONTRACT_MAINTENANCE);
        setRecordTypeName.add(Constants.RECORD_TYPE_OPPORTUNITY_PT_CONTRACT_RENEWAL);
        setRecordTypeName.add(Constants.RECORD_TYPE_OPPORTUNITY_RI_AM_FIRST_YEAR_OPP);
        setRecordTypeName.add(Constants.RECORD_TYPE_OPPORTUNITY_RI_AM_STANDARD_OPP);
        
        //Map for record to update Key = MembershipId & Value = OpportunityRecord
        Map<Id, Opportunity> mapOpportuntiyMembership = new Map<Id,Opportunity>();
        
        //Set to hold membership Ids
        Set<Id> membershipIds = new Set<Id>();
        
        //Map to hold the Membership recoords to be updated
        Map<Id, Membership__c> mapMemberships = new Map<Id, Membership__c>(); 
        
        //Loop through membership records 
        for(Membership__c membership : listMembership) {
            
            //Add membership Ids in Set
            membershipIds.add(membership.Id);   
        }
        
        //Loop through Opportunities which are associate with Memberships 
        for(Opportunity opp : [SELECT Id, Membership__c, Active_Renewal__c, IsClosed, Pool_Date__c FROM Opportunity WHERE  
                                        RecordType.Name IN: setRecordTypeName AND Membership__c != null AND Membership__c IN: membershipIds
                                        AND IsClosed = false]) {
             
            //Check map contains Membership
            if(mapOpportuntiyMembership.containsKey(opp.Membership__c)){
                
                //Exiting opportunity
                Opportunity existingOpportunity = mapOpportuntiyMembership.get(opp.Membership__c);
                
                //Check specific criteria for Present, Past, Future Pool_Date__c
                if(existingOpportunity.Pool_Date__c.year() == Date.today().year() 
                    || (existingOpportunity.Pool_Date__c.year() < Date.today().year() && (opp.Pool_Date__c.year() > Date.today().year() || existingOpportunity.Pool_Date__c.year() > opp.Pool_Date__c.year()))
                    || (existingOpportunity.Pool_Date__c.year() > Date.today().year() && existingOpportunity.Pool_Date__c.year() < opp.Pool_Date__c.year()))
                    continue;
                else {
                
                    //Mark is Active on currect record
                    opp.Active_Renewal__c = true;
                    
                    //add in list to be updated
                    mapOpportuntiyMembership.put(opp.Membership__c, opp);
                    
                    //Added By - Abhinav Sharma - CR-20140502-5327 - 07/02/2014 
                    //Start From Here
                    //Initializing Membership Object Instanace & then populating its fields with appropriate values
                    Membership__c membership = new Membership__c(Id = opp.Membership__c);
                    membership.Active_Renewal_Opportunity__c = opp.Id;
                    mapMemberships.put(membership.Id, membership);
                    //Upto Here
                }
            } else {
                
                opp.Active_Renewal__c = true;
                mapOpportuntiyMembership.put(opp.Membership__c, opp); 
                
                //Added By - Abhinav Sharma - CR-20140502-5327 - 07/02/2014 
                //Start From Here
                //Initializing Membership Object Instanace & then populating its fields with appropriate values
                Membership__c membershp = new Membership__c(Id = opp.Membership__c);
                membershp.Active_Renewal_Opportunity__c = opp.Id;
                mapMemberships.put(membershp.Id, membershp);
                //Upto Here
            }
        }
        
        //Modified By - Abhinav Sharma - CR-20140502-5327 - 07/02/2014 
        //Start From Here
        //Check for size value
        if(mapOpportuntiyMembership.size()  > 0){
            
            //ByPass all triggers 
            Util.BypassAllTriggers = true;
            
            //Update List of Opportunities and recording error messages will be emailed to the SFAdmin 
            logMessage = Util.createLog(Database.update((mapOpportuntiyMembership.values()),false));
            
            //Checking errors log messages string for blank value and append it to final error message string only and only if it have proper value with it
            if(logMessage != '') 
                debugLog += logMessage;
        }
        //Upto Here
        
        //Added By - Abhinav Sharma - CR-20140502-5327 - 07/02/2014 
        //Start From Here
        //Check for size value
        if(mapMemberships.size() > 0){
            
            //ByPass all triggers 
            Util.BypassAllTriggers = true;
            
            //Update List of memberships and recording error messages will be emailed to the SFAdmin 
            logMessage = Util.createLog(Database.update((mapMemberships.values()),false));
            
            //Checking errors log messages string for blank value and append it to final error message string only and only if it have proper value with it
            if(logMessage != '') 
                debugLog += logMessage;
        }           
        //Upto Here
    }
    
    //finish method 
    global void finish(Database.BatchableContext BC) {
        
        //Added By CR-20140502-5327 - 07/02/2014
        //Start Here
        //Checking logMessage string for blank value but if it does not have blank value with it then emailed it to SFAdmin.
        if(debugLog != '') {
            
            //User Instance
            //Refactored By Doug Roberts - 08/31/2015 - Remove query for SF user email and change to custom label
            //List<User> sfAdminUser = [Select Email FROM User WHERE Name = 'Salesforce Administrator' AND IsActive = true AND Profile.Name = 'System Administrator' AND Email!= null LIMIT 1];
            
            //Send log to admin
            //if(sfAdminUser.size() > 0)
                Util.sendBatchStatus(BC.getJobId(), 'Batch_OpportunityPopulateRenewalFlag', debugLog, Label.Salesforce_Admin_Email);
        }
        //Upto Here
    }
}