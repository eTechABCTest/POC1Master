/**
 *  Description     :   This class is helper class for triggers on Contract Integrated Accounts
 * 
 *  Created By      :   Bhavi Sharma
 * 
 *  Created Date    :   03/22/2013
 * 
 *  Revision Logs   :   V_1.0 - Created
 *                      V_1.1 - 04/19/2014 - CR-20140331-4909 - Updates to batch failure process - method modified (populateContractsOnMembership)
 * 
 **/ 
public without sharing class ContractIntegratedAccountsTriggerHelper {
    
    //Method to update the memberships with contracts
    public static string populateContractsOnMembership(List<Contract__c> contracts) {
    
        //String to hold the log Message
        String logMessage = '';
        
        //Check for the records size
        if(contracts != null && contracts.size() > 0) {
            
            /** Find the Memberships for these Contracts that need updated **/
            // Set to store Account Ids
            Set<Id> accIds = new Set<Id>();
            
            // Set to store Program Ids
            Set<Id> progIds = new Set<Id>();
            
            Set<Id> memOwnerNeeded = new Set<Id>(); // DAF - added 12-15-11
            
            // Map of a List Contracts associated to their Account Id as a key
            Map<Id, List<Contract__c>> accId2ConListMap = new Map<Id, List<Contract__c>>();
            
            //get full list of changed Contracts and Contract Integrated Accounts to use for checking on Memberships
            List<Contract__c> allCons = [Select Id, Payer_Account__c, Program__c, Start__c, End__c, Active__c,
                (Select Account__c from Contract_Integrated_Accounts__r)
                from Contract__c where Id in :contracts and (Status__c = 'ATL' or Status__c = 'Honorary' or Status__c = 'Dropped')];
            
            //split out the Contracts according to which Account they're associated with
            for (Contract__c c : allCons) {
            
                // Add the Contract's Payer Account Id to a list of Account Ids
                accIds.add(c.Payer_Account__c);
                
                // Add the Contract's Program Id to a list of Program Ids
                progids.add(c.Program__c);
                
                // If the Map of Contracts to Account Ids already contains a key for the Account, add the Contract to the list for the existing key,
                // otherwise add a new key for the Account and a list containing the Contract
                if (accId2ConListMap.containsKey(c.Payer_Account__c))
                    accId2ConListMap.get(c.Payer_Account__c).add(c);
                else
                    accId2ConListMap.put(c.Payer_Account__c, new List<Contract__c> { c });
                
                //Associate this Contract with Accounts according to Contract Integrated Accounts also (1 Contract may be in multiple lists, if there are CIAs)
                for (Contract_Integrated_Accounts__c cia : c.Contract_Integrated_Accounts__r) {// Loop through Contract Integrated Accounts for this Contract
                
                    // Add the Contract Integrated Account Account Id to a list of Account Ids
                    accIds.add(cia.Account__c);
                    
                    // If the Map of Contracts to Account Ids already contains a key for the Account, add the Contract to the list for the existing key,
                    // otherwise add a new key for the Account and a list containing the Contract
                    if (accId2ConListMap.containsKey(cia.Account__c))
                        accId2ConListMap.get(cia.Account__c).add(c);
                    else
                        accId2ConListMap.put(cia.Account__c, new list<Contract__c> { c });
                }
            }
            
            //Get full list of all Memberships that might possibly match our list
            Map<Id, Membership__c> allMems = new Map<Id, Membership__c>([select id, Program__c, Account_Name__c 
                from Membership__c where Program__c in :progIds and Account_Name__c in :accIds]);
            
            //Narrow list down to only Memberships that actually match directly with one of our Contracts, narrow down by Account first
            Map<Id, Membership__c> MembershipstoCheckMap = new Map<Id, Membership__c>();
            
            // Loop through all Memberships associated to the Accounts from these Contracts
            for (Membership__c m : allMems.values()) {
            
                // If the Account Id To Contract map contains a record for this Membership's Account then process
                // (there should be no reason for this condition, but it's better to have it than not)
                if (accId2ConListMap.containsKey(m.Account_Name__c)) {
                
                    for (Contract__c c : accId2ConListMap.get(m.Account_Name__c)) {
                    
                        // If the Contract's Program equals the Membership's Program then store the Membership in a map w/ it's Id as a key 
                        if (c.Program__c == m.Program__c) {
                            MembershipstoCheckMap.put(m.id, m);
                            memOwnerNeeded.add(m.id);   //DAF - added 12-15-11
                        }
                    }
                }
            }
            
            /* Go through the Memberships identified above (MembershipstoCheck) to see what needs to be done.  */
            
            //get set of Contract Ids on the basis of matching Contract Integrated Accounts 
            List<Contract_Integrated_Accounts__c> ciaList = [select Id, Account__c, Contract__c, Contract__r.Program__c 
                from Contract_Integrated_Accounts__c where (Account__c in :accIds) and (Contract__r.Program__c in :progIds)
                and (Contract__r.Status__c = 'ATL' or Contract__r.Status__c = 'Honorary' or Contract__r.Status__c = 'Dropped')];
            
            // Set to store Contract Ids from the related Contract Integrated Accounts 
            Set<Id> ciaContractIds = new Set<Id>();
            
            // Loop through Contract Integrated Accounts and build a list of associated Contract Ids based on memberships
            for(Contract_Integrated_Accounts__c cia : ciaList) {
            
                // Loop through Memberships associated to the related Accounts
                for (Membership__c m : MembershipstoCheckMap.values()) {
                
                    // If the Contract Integrated Account Contract Program and Membership Program are equal
                    // AND the Contract Integrated Account Account and the Membership Account are equal, 
                    // then add the Contract Id to a list
                    if ((cia.Contract__r.Program__c == m.Program__c) && (cia.Account__c == m.Account_Name__c))
                        ciaContractIds.add(cia.Contract__c);
                }
            }
            
            // Build a list of Cotracts from the Contract Ids found from above
            List<Contract__c> listContracts = [select Id, Active__c, Join_Date__c, Start__c, End__c, Program__c, Payer_Account__c,
                (select Id, Account__c from Contract_Integrated_Accounts__r where Account__c in :accIds)
                from Contract__c 
                where ((id in :ciaContractIds) or (Payer_Account__c in :accids and Program__c in :progids))
                and (Status__c = 'ATL' or Status__c = 'Honorary' or Status__c = 'Dropped')]; // Nathan B 1/5/11 - Added Status condition
            
            // Map of Contracts w/ their Id as the key
            Map<Id, Contract__c> conId2ConMap = new Map<Id, Contract__c>(listContracts);
            
            // Map of Contracts w/ their Account Id as the key
            Map<Id, List<Contract__c>> accId2ContractListMap = new Map<Id, List<Contract__c>>();
            
            // Map a list of Contract Ids w/ their associated Account Id as the key
            Map<Id, set<Id>> accId2ContractIdSetMap = new Map<Id, Set<Id>>(); //acc id to Contract IDs, to make sure we don't add the same Contract twice
            
            // Loop through contracts (and Contract Integrated Accounts) for identified Memberships and put in sets by account number
            for (Contract__c c : listContracts) {
            
                if (accId2ContractIdSetMap.get(c.Payer_Account__c) == null) 
                    accId2ContractIdSetMap.put(c.Payer_Account__c, new set<id>{c.Id});
                else
                    accId2ContractIdSetMap.get(c.Payer_Account__c).add(c.Id);
                    
                // Loop through entire list of Contract Integrated Accounts on this Contract as possible connections. 1/11/11 jn
                for (Contract_Integrated_Accounts__c cia : c.Contract_Integrated_Accounts__r) {
                
                    if (accId2ContractIdSetMap.get(cia.Account__c) == null) 
                        accId2ContractIdSetMap.put(cia.Account__c, new set<id>{c.id});
                    else
                        accId2ContractIdSetMap.get(cia.Account__c).add(c.id);
                }
            } //end for contracts
            
            //convert id sets into a map of contract lists w/ account ID as the key
            for (Id i : accId2ContractIdSetMap.keySet())
            {
                accId2ContractListMap.put(i,new list<Contract__c>());
                
                for (Id cid : accId2ContractIdSetMap.get(i))
                {
                    accId2ContractListMap.get(i).add(conId2ConMap.get(cid));
                }
            }
            
            // Loop through all Memberships that need to be checked
            for (Membership__c m : MembershipstoCheckMap.values()) {
            
                // Set the Earliest, Latest, and Active Contract field values to null
                m.Earliest_Contract__c = null;
                m.Latest_Contract__c = null;
                m.Active_Contract_Idenfied__c = null;
                m.Join_Date_Most_Recent__c = null;
                
                // Variables to temporarily store Earliest, Latest, Latest Active, and Earliest Future Contracts
                Contract__c earliestContract;
                Contract__c latestContract;
                Contract__c latestActiveContract;
                Contract__c earliestFutureContract;
                Date mostRecentJoinDate = null;
                
                // If this membership has a Program and an Account then process
                if(m.Program__c != null && m.Account_Name__c != null) {
                
                    // If the Membership's Account has Contracts associated, then process
                    if (accId2ContractListMap.get(m.Account_Name__c) != null) {
                    
                        // Loop through list of contracts for membership Institution(Account)
                        for (Contract__c acon : accId2ContractListMap.get(m.Account_Name__c)) {
                        
                            // Skip processing if the Contract's Program and the Membership's Program do not match
                            if (acon.Program__c != m.Program__c)
                                continue; 
                            
                            //earliest contract
                            if (acon.Start__c != null && (earliestContract == null  || acon.Start__c < earliestContract.Start__c)) 
                                earliestContract = acon;
                            
                            //latest contract
                            if (acon.End__c != null && (latestContract == null || acon.End__c > latestContract.End__c)) 
                                latestContract = acon;
                            
                            //active contract idenfied
                            if (acon.Start__c != null && acon.End__c != null && acon.Start__c <= system.today() && acon.End__c >= system.today()
                                && (latestActiveContract == null || acon.End__c > latestActiveContract.End__c)) {
                            
                                latestActiveContract = acon;
                            }
                            
                            //earliest Future Contract (to use for Active Contract Idenfied if there is none found within its dates)
                            if (acon.Start__c != null && acon.End__c != null && acon.Start__c > system.today()
                                && (earliestFutureContract == null || acon.Start__c < earliestFutureContract.Start__c))
                            {
                                earliestFutureContract = acon;
                            }
                            
                            //Bhavi Sharma - 04/26/2013 - Set oldest date as mostRecentJoinDate
                            if(acon.Active__c == true && acon.Join_Date__c != null && (mostRecentJoinDate == null || acon.Join_Date__c < mostRecentJoinDate )) {
                                
                                //Set join date as most recent
                                mostRecentJoinDate = acon.Join_Date__c;
                            } 
                        }
                        
                        if (latestActiveContract == null)
                            latestActiveContract = earliestFutureContract;
                    }
                    
                    //put calculated values, if they were found, into the appropriate fields
                    if (earliestContract != null)
                        m.Earliest_Contract__c = earliestContract.id;
                        
                    if (latestContract != null)
                        m.Latest_Contract__c = latestContract.id;
                        
                    if (latestActiveContract != null)
                        m.Active_Contract_Idenfied__c = latestActiveContract.id;
                        
                    if(mostRecentJoinDate != null)
                        m.Join_Date_Most_Recent__c = mostRecentJoinDate;
                    
                }
            }
            
            //Modified By - Abhinav Sharma - 04/19/2014 - CR-20140331-4909 - Updates to batch failure process 
            // If there are Memberships needing update, then update and record errors to the debuglog variable
            if (MembershipstoCheckMap.values().size() > 0) {
            
                if (!Util.IsTesting) { 
                    logMessage = membershipOwnerCheckfromMemberships(memOwnerNeeded);   //DAF - added 12-15-11 - update membership ownership
                }
                
                //Modified By - Abhinav Sharma - 04/19/2014 - CR-20140331-4909
                if(System.isBatch()) {
                    logMessage = Util.createLog(Database.update((MembershipstoCheckMap.values()),false));
                } else {
                    update MembershipstoCheckMap.values();
                }
            }
        }
        
        //Returning log message string
        return logMessage;      
    }
    
    // DAF - added below 12-16-11
    public static string membershipOwnerCheckfromMemberships(set<id> memids) {
    
        //For the Membership IDs presented, if the Renewal Opportunity on the Contract that is Active_Contract_Idenfied__c on a (Prospect Status) Membership, 
        //change the owner on that Membership to be the owner on the renewal Opportunity
        //If membership status contains 'Prospect' then owner = assigned marketer, else owner = owner of active contract renewal opportunity.  
        //there should be a check put in place so that if the relevant field is not populated the owner will not be changed.
        system.debug('@@ INSIDE MEMBERSHIP OWNER CHECK FROM MEMBERSHIPS: IDS:' + memids);
        list<Membership__c> memstocheck = [select id, Membership_Status__c, OwnerID, Active_Contract_Idenfied__c, Assigned_Marketer__r.Id, Active_Contract_Idenfied__r.Contract_Renewal_Opportunity__c, 
            Active_Contract_Idenfied__r.Contract_Renewal_Opportunity__r.OwnerID, Assigned_Marketer__c, Active_Contract_Idenfied__r.Contract_Renewal_Opportunity__r.StageName, 
            Active_Contract_Idenfied__r.Contract_Renewal_Opportunity__r.Owner.IsActive, Assigned_Marketer__r.IsActive   //DAF 12-15-11 added two fields // VH 2/15/12 added 1 field (stagename)
            from Membership__c
            where id in :memids];
        
        list<Membership__c> memstoupdate = new list<Membership__c>();
        Set<Id> ActiveContractIdentifiedIDs = new Set<Id>();    //DAF added 02-07-12        
        Map<Id, Id> NewMembershipOwner = new Map<Id, Id>();
        Set<Id> MembershipAddedIDs = new Set<Id>(); //DAF added 02-07-12    
        system.debug('@@memstocheck:' + memstocheck.size() + memstocheck); 
        
        //String to hold the log Message
        String logMessage = '';
         
        //Go through Memberships to see if any need changed
        for (Membership__c m : memstocheck) {
            system.debug('## (for loop) MEM CHECK' + m);
            // VH 2/15/12 - if member status contains prospects, or is member-integrated or member-payer, update the owner to assigned marketer
            if(m.Membership_Status__c.toLowerCase().contains('prospect') ||
                m.Membership_Status__c.toLowerCase().contains('member - integrated') ||
                m.Membership_Status__c.toLowerCase().contains('member - payer'))
            {
                system.debug('## line 418' + m.Id + '  ' + m.Assigned_Marketer__r.Id + '      ' + m.OwnerId);
                system.debug('## (1st if stmt) MEM CHECK' + m);
                if (m.Active_Contract_Idenfied__r.Contract_Renewal_Opportunity__r.StageName != null) {
                    system.debug('## contract renewal opportunity stage != null');
                    if (m.Active_Contract_Idenfied__r.Contract_Renewal_Opportunity__r.StageName.toLowerCase().contains('pending') &&
                        (m.Membership_Status__c.toLowerCase().contains('member - integrated') || m.Membership_Status__c.toLowerCase().contains('member - payer'))) {
                        
                        system.debug('## (Opp Owner) Updating member owner id FROM: ' + m.OwnerId + ' TO: ' + m.Active_Contract_Idenfied__r.Contract_Renewal_Opportunity__r.OwnerID);
                        // make OwnerId = OpportunityOwnerId
                        m.OwnerID = m.Active_Contract_Idenfied__r.Contract_Renewal_Opportunity__r.OwnerID;
                        memstoupdate.add(m);
                        NewMembershipOwner.put(m.Active_Contract_Idenfied__c, m.Active_Contract_Idenfied__r.Contract_Renewal_Opportunity__r.OwnerID);   //DAF added 02-07-12
                        ActiveContractIdentifiedIDs.add(m.Active_Contract_Idenfied__c); //DAF added 02-07-12
                        MembershipAddedIDs.add(m.Id);
                        continue;
                        
                    }
                }
                system.debug('## line 417');
                system.debug('## line 418' + m.Assigned_Marketer__c + '      ' + m.OwnerId);
                //Sets the Owner equal to the Assigned Marketer, if there is one.
                if ((m.Assigned_Marketer__c != null) && (m.OwnerID != m.Assigned_Marketer__c)) {
                    system.debug('## (2nd if stmt) MEM CHECK' + m);
                    if (m.Assigned_Marketer__r.IsActive) {
                        system.debug('## (3rd if stmt) MEM CHECK' + m);
                        system.debug('## (Assigned Marketer) Updating member owner id FROM: ' + m.OwnerId + ' TO: ' + m.Active_Contract_Idenfied__r.Contract_Renewal_Opportunity__r.OwnerID);
                        m.OwnerID = m.Assigned_Marketer__c;
                        memstoupdate.add(m);
                        NewMembershipOwner.put(m.Active_Contract_Idenfied__c, m.Assigned_Marketer__c);  //DAF added 02-07-12
                        ActiveContractIdentifiedIDs.add(m.Active_Contract_Idenfied__c); //DAF added 02-07-12
                        MembershipAddedIDs.add(m.Id);
                    }
                }
            } else {
                system.debug('### Membership Status != Prospect - Owner Update (Current Owner=' + m.OwnerId +' / Status=' + m.Membership_Status__c + ' / Active Contract=' + m.Active_Contract_Idenfied__c + ')');
                // Set the Membership's Owner equal to the Active Contract's Renewal Opp Owner, if there is an active contract with a renewal Opp.
                if ((m.Active_Contract_Idenfied__c != null) && (m.Active_Contract_Idenfied__r.Contract_Renewal_Opportunity__c != null))
                {
                    if (m.Active_Contract_Idenfied__r.Contract_Renewal_Opportunity__r.Owner.IsActive) {
                        m.OwnerID = m.Active_Contract_Idenfied__r.Contract_Renewal_Opportunity__r.OwnerID;
                        memstoupdate.add(m);
                        NewMembershipOwner.put(m.Active_Contract_Idenfied__c, m.Active_Contract_Idenfied__r.Contract_Renewal_Opportunity__r.OwnerID);   //DAF added 02-07-12
                        ActiveContractIdentifiedIDs.add(m.Active_Contract_Idenfied__c); //DAF added 02-07-12
                        MembershipAddedIDs.add(m.Id);
                    }
                }
            }   
            
        }
        for (Membership__c m : [select Id, OwnerId, Active_Contract_Idenfied__c from Membership__c where Active_Contract_Idenfied__c in :ActiveContractIdentifiedIDs and Id not in :MembershipAddedIDs AND Active_Contract_Idenfied__c != null]) {
            system.debug('## Updating member owner id FROM: ' + m.OwnerId + ' TO: something');
            if (NewMembershipOwner.containsKey(m.Active_Contract_Idenfied__c)) {
                m.OwnerId = NewMembershipOwner.get(m.Active_Contract_Idenfied__c);
                memstoupdate.add(m);
            }
        }       
        
        if (memstoupdate.size() > 0) {
            
            //Modified By - Abhinav Sharma - 04/19/2014 - CR-20140331-4909
            if(System.isBatch()) {
                logMessage = Util.createLog(Database.update((memstoupdate),false));
            } else {
                update memstoupdate;
            }
        } 
        
        //Returning log message string
        return logMessage;
    }
}