/**
 *  Purpose         :   This batch is used to check for any cards that are nearing or over the threshold transcation limit.
 *
 *  Created By      :   Bhavi Sharma
 *
 *  Created Date    :   10/14/2013
 *
 *  Current Version :   V_1.0 - Created
 *                       
 **/
global class Batch_AccountTeamReplication implements Database.Batchable<SObject>, Database.AllowsCallouts, Database.Stateful {
    
    //Variables
    public String debugLog = '';
    public String SOQLQuery;
    
    //Execute Batch from UI 
    webservice static void executeAccountTeamReplication(String query) {
        
        //Execute the batch
        Batch_AccountTeamReplication controller = new Batch_AccountTeamReplication();
        controller.replicateAccountTeam(Database.query(query));
    }
    
    //Start method
    global Database.Querylocator start(Database.BatchableContext BC) {

        //Initialize
        debugLog = '';
        
        //return query result    
        if(SOQLQuery == null)
            return Database.getQueryLocator([SELECT Id, TeamMemberRole, UserId, AccountId FROM AccountTeamMember WHERE LastModifieddate = YESTERDAY order by AccountId]);
        else
            return Database.getQueryLocator(SOQLQuery);
    }

    //Execute method
    global void execute(Database.BatchableContext BC, List<AccountTeamMember> aTMs) {
        
        //Call method to replaicate team
        replicateAccountTeam(aTMs);
    }

    // Finish method
    global void finish(Database.BatchableContext BC) {
        
        //Check if any error occured and then send the email
        if(debugLog != '') {

            //Send batch status to the person who executed this batch
            Util.sendBatchStatus(BC.getJobId(), 'Batch_AccountTeamReplication', debugLog);
        }
    }
    
    /**
     * @description     :   This method is to replicate to account team in Team memebrship 
     * 
     * @args            :    List
     * 
     * @return          :    
     * 
     * */
    public void replicateAccountTeam(List<AccountTeamMember> aTMs) {
        
        //Set to hold teh institution Ids
        Set<Id> institutionIds = new Set<Id>();
        
        //Set to hold the Role Names
        Set<String> roleNames = new Set<String>();
        
        //Map to hold Roles with Name
        Map<String, Team_Role__c> mapTeamRoles = new Map<String, Team_Role__c>();
        
        //Map to hold teh ATM instance with uniqueKey
        Map<String, AccountTeamMember> mapAccountTeamMember = new Map<String, AccountTeamMember>();
        
        //Map to hold Team Membership instance with uniqueKey
        Map<String, Team_Membership__c> mapExistingTeamMembership = new Map<String, Team_Membership__c>();
        
        //List to hold the TMs to be created/updated
        List<Team_Membership__c> listTMs = new List<Team_Membership__c>();
        
        //Loop through the records and prepare a set of institutions to pull teh relavant records from Team membership object
        for(AccountTeamMember aTM : aTMs) {
            
            //Add in set adn Map
            institutionIds.add(aTM.AccountId);
        }
        
        //Loop through the records and prepare a set of institutions to pull teh relavant records from Team membership object
        for(AccountTeamMember aTM : [Select Id, TeamMemberRole, UserId, AccountId from AccountTeamMember where AccountId IN: institutionIds]) {
            
            //Add in set adn Map
            roleNames.add(aTM.TeamMemberRole);
            mapAccountTeamMember.put(aTM.AccountId + '-' + aTM.UserId + '-' + aTM.TeamMemberRole, aTM);     
        }
        
        //Pull the Roles data
        for(Team_Role__c tR : [Select Id, Name from Team_Role__c where Name IN: roleNames]) {
            
            //Populate Map
            mapTeamRoles.put(tR.Name, tR);
        }
        
        //Remaning Roles which do not have records
        roleNames.removeAll(mapTeamRoles.keySet());
        
        //List on New Team Roles
        Map<String, Team_Role__c> mapNewTeamRoles = new Map<String, Team_Role__c>();
        
        //Create Team Role for remaning
        for(String rName : roleNames) {
            
            //Team Role
            mapNewTeamRoles.put(rName, new Team_Role__c(Name = rName));
        }
        
        //Insert listTRs
        if(mapNewTeamRoles.size() > 0) {
            
            //Insert 
            insert mapNewTeamRoles.values();
            mapTeamRoles.putAll(mapNewTeamRoles);
        }
        //Pull the Relavant Team Membership Records
        for(Team_Membership__c tM :  [Select Id, Institution__c, Employee__c, Role__c, Role__r.Name from Team_Membership__c where Institution__c IN: institutionIds]) {
            
            //Add in Map
            mapExistingTeamMembership.put(tM.Institution__c + '-' + tM.Employee__c + '-' + tM.Role__r.Name, tM);
        }
        
        //Loop through the mapAccountTeamMember
        for(String roleKey : mapAccountTeamMember.keySet()) {
            
            //get the ATM Record
            AccountTeamMember aTM = mapAccountTeamMember.get(roleKey);
            
            //Check if this record doesn't exist in map, then create the new Team_Membership__c
            if(!mapExistingTeamMembership.containsKey(roleKey)) {
                
                //Create a new Teammembership record
                Team_Membership__c tM = new Team_Membership__c(Institution__c = aTM.AccountId, Employee__c = aTM.UserId, Role__c = mapTeamRoles.get(aTM.TeamMemberRole).Id, Start_date__c = Date.today());
                listTMs.add(tM);
            }
        
            //Remove this record from the Map
            mapExistingTeamMembership.remove(roleKey);
        }
        
        //Chekc What is remaining, and stamp end date on these remaning records
        for(Team_Membership__c tM : mapExistingTeamMembership.values()) {
            
            //Stamp Enddate
            tM.End_date__c = Date.today();
            listTMs.add(tM);
        }
        
        //Upsert records
        if(listTMs.size() > 0) {
            
            Database.UpsertResult[] srs =  Database.upsert(listTMs, false);
            for(Database.UpsertResult sr : srs) {
                if(!sr.isSuccess()) {
                    debuglog += '<br/>' + sr.getId() + ' failed to update.';
                    for(Database.Error err : sr.getErrors()) {
                        debuglog += '<br/>' + err.getMessage();
                    }
                }
            }
        }
    }
}