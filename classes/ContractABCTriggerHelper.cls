/*
    Purpose:    This class is helper class for trigger on Contract ABC object.
                
    Create By:  Simplyforce Technology
    
    Created Date:   09/18/2011
    
    Current Version:    v1.0
    
    Revision Log:   V1.0 Created
                    V_1.1 - 10/26/2011 - Method added to update the Contract's child  Line Item Schedules with the Invoice billing Schedule Id
                    V_1.2 - 10/26/2011 - Method added not to update the invoice billing schedule id as null if LIS is associated with the records
                    V_1.3 - 08/25/2015 - Modified By - Abhinav Sharma - 08/25/2015 - CR-20150820-9167 - Added new method (doUpdateOnOpportunitiesOnContractABCTypeUpdate)
                    V_1.4 - 09/03/2015 - Modified By - Abhinav Sharma - 09/03/2015 - CR-20150205-8660 - Added a new method (updateActiveMembershipMainContact)
                    v_1.5 - 10/17/2015 - Modified By - Abhinav Sharma - CR-20151008-9304 - Triggers repetative execution
                    v_1.6 - 02/13/2016 - Modified By - Abhinav Sharma - CR-20150925-9267
                    v_1.7 -  07/05/2016 -Modified By - Mahedra Swarnkar -CR-20160229-9651 - Updated the method "populateFieldsOnCaseFromContract" to add the logic to populate New_Member_Programs_TD__c field on case
*/
public without sharing class ContractABCTriggerHelper {
    
    //variable to stop the recursive execution of th trigger
    public static Boolean isContractABCTriggerExecuted = false;
    
    //Method to populate fields on contract ABC object in before events
    public static void populateAndValidateContractFields(List<Contract__c> contracts, Map<Id, Contract__c> mapOldContracts) {
        
        /*Collection's useful, while building logic to populate fields on Contract ABC records*/
        //Start from here
        
        //Memory allocation to collections
        Set<Id> setPayerAccountsIds = new Set<Id>();
        Set<Id> setProgramsIds = new Set<Id>();
        Set<Id> setOpportunityIds = new Set<Id>();
        
        //Loop through contract record and populating collections with value
        for(Contract__c c : contracts) {
            
            //Checking "Payer Account" field for null value and accordingly populating the set with appropriate values
            if(c.Payer_Account__c != null)
                setPayerAccountsIds.add(c.Payer_Account__c);
                
            //Checking program field for null value and accordingly populating the set with appropriate values
            if(c.Program__c != null)    
                setProgramsIds.add(c.Program__c);
                
            //Checking source opportunity field for null value and accordingly populating the set with appropriate values
            if(c.Source_Opportunity__c != null) 
                setOpportunityIds.add(c.Source_Opportunity__c); 
        }
    
        //Map of Accounts
        Map<Id, Account> mapPayerAccountsInfo = new Map<Id, Account>();
        
        //Map of programs
        Map<Id, Program__c> mapProgramsInfo = new Map<Id, Program__c>();
        
        //Map of source opportunities
        map<Id, Opportunity> mapSourceOpportunities = new Map<Id, Opportunity>();
        
        //Checking set for size value and populating the map with retrieved account records
        if(setPayerAccountsIds.size() > 0)
            mapPayerAccountsInfo = new Map<Id, Account>([SELECT Id, Name FROM Account WHERE Id IN : setPayerAccountsIds]);

        //Checking set for size value and populating the map with retrieved program records
        if(setProgramsIds.size() > 0)
            mapProgramsInfo = new Map<Id, Program__c>([SELECT Id, Program_Acronym__c, Business_Line__c FROM Program__c 
                                                        WHERE Id IN : setProgramsIds]);
                                                        
        //Checking set for the size value and populating the map with retrived opportunity records
        if(setOpportunityIds.size() > 0)
            mapSourceOpportunities = new Map<Id, Opportunity>([SELECT Id, Previous_Contract__c, Previous_Contract__r.Join_Date__c, 
                                                                (SELECT Id, ContactId FROM OpportunityContactRoles 
                                                                    WHERE Role = 'Invoice Contact')
                                                                FROM Opportunity 
                                                                WHERE Id IN : setOpportunityIds]);
        //Upto here                                                     

        //Variable to hold the Max length allowed for account name string literal
        Integer maxacctnamelength = 55;
    
        //Loop through contract records and populating name field with ("Account Name - Program Acronym - Year") combined string value
        for(Contract__c c : contracts) {
            
            /*Logic to populate name field on contract ABC records*/
            //Start from here
            //Temprary variables
            String acctName = '';
            String progAcronym = '';
            String yearString = '';

            //Checking payer account for null value and populating account name temparary variable with value
            if(c.Payer_Account__c != null) {
                if(mapPayerAccountsInfo.containsKey(c.Payer_Account__c) && mapPayerAccountsInfo.get(c.Payer_Account__c) != null)
                    acctName = mapPayerAccountsInfo.get(c.Payer_Account__c).Name;
            }
            
            //Truncating account string if exceeding allowed characters limit
            if(acctName != '')
                acctName = acctName.substring(0,Math.min(acctName.length(), maxacctnamelength));

            //Checking program for null value and populating program acronym temparary variable with value
            if(c.Program__c != null) {
                if(mapProgramsInfo.containsKey(c.Program__c) && mapProgramsInfo.get(c.Program__c) != null)
                    progAcronym = mapProgramsInfo.get(c.Program__c).Program_Acronym__c;
            }

            //Checking "Year__c" field for null value and populating year temparary variable with value
            if (c.Year__c != null) 
                yearString = c.Year__c;

            //concatenation string literal to have a combined string and then populating name field with it 
            c.Name = acctName + ' - ' + progAcronym + ' - ' + yearString; 
            //Upto here
            
            /*Logic to populate Business Line (From Trigger) [Business_Line_From_Trigger__c] field on contract ABC records*/
            //Start from here 
            //Checking for value in map and accordingly populating "Business Line (From Trigger)" field on contract ABC records
            if(mapProgramsInfo.containsKey(c.Program__c) && mapProgramsInfo.get(c.Program__c) != null) {
                if(c.Business_Line_From_Trigger__c != mapProgramsInfo.get(c.Program__c).Business_Line__c)
                        c.Business_Line_From_Trigger__c = mapProgramsInfo.get(c.Program__c).Business_Line__c;
            }
            //Upto here
            
            /*Logic to populate Active (Active__c) field on contract ABC records*/      
            //Start from here
            //Set Active checkbox
            if ((c.Start__c != null) && (c.End__c != null)) {
                if ((c.Start__c <= system.today()) && (c.End__c >= system.today())) 
                    c.Active__c = true;
                else
                    c.Active__c = false; 
            } else {
                c.Active__c = false;
            }
            //Upto Here
            
            /*Logic to populate Previous Contract (Previous_Contract__c) field on contract ABC records*/        
            //Start from here
            //Checking for Source Opportunity for this contract and then setting Previous Contract on contract from Previous Contract on source Opp
            if (c.Source_Opportunity__c != null
                && mapSourceOpportunities.containsKey(c.Source_Opportunity__c) 
                && mapSourceOpportunities.get(c.Source_Opportunity__c) != null
                && mapSourceOpportunities.get(c.Source_Opportunity__c).Previous_Contract__c != null) 
                c.Previous_Contract__c = mapSourceOpportunities.get(c.Source_Opportunity__c).Previous_Contract__c;
            //Upto here
            
            /*Logic to update/populate Join Date from source Opportunity.Previous Contract join date on contract ABC records*/
            //Start from here
            //update Join Date from source Opportunity.Previous Contract join date
            //Join Date populate/update logic will only execute for insert use cases
            if (mapOldContracts == null 
                && c.Source_Opportunity__c != null
                && mapSourceOpportunities.containsKey(c.Source_Opportunity__c) 
                && mapSourceOpportunities.get(c.Source_Opportunity__c) != null
                && mapSourceOpportunities.get(c.Source_Opportunity__c).Previous_Contract__c != null
                && mapSourceOpportunities.get(c.Source_Opportunity__c).Previous_Contract__r.Join_Date__c != null)
                c.Join_Date__c = mapSourceOpportunities.get(c.Source_Opportunity__c).Previous_Contract__r.Join_Date__c;
            //Upto Here
        }
    }
        
    //This method is to update the Membership status text field on membership object whenever there is a change on Contract ABC record
    public static void updateMembershipStatusByContracts(Map<Id, Contract__c> mapContract) {
    
        //Create a list of membership records to be updated
        List<Membership__c> memberShipsToBeUpdated = new List<Membership__c>();
        
        //Temporary variable to hold the membership status
        String memberShipStatus;
        
        //Checking map for null and size value
        if(mapContract != null && mapContract.values().size() > 0) {
        
            //Loop through the membership records and prepare the data set to be updated
            for(Membership__c membership : [Select Id, Payer_Status__c, Active_Contract_Idenfied__r.Status__c, Active_Contract_Idenfied__r.Start__c, 
                                                Latest_Contract__r.Status__c, Membership_Status__c, 
                                                Earliest_Contract__r.Start__c, Latest_Contract__r.Start__c, Account_Name__c,
                                                Active_Contract_Idenfied__r.End__c, Latest_Contract__r.Payer_Account__c, 
                                                Active_Contract_Idenfied__r.Payer_Account__c,
                                                Latest_Contract__r.Renewal_Opp_Status__c, Earliest_Contract__r.Status__c, Latest_Contract__r.End__c 
                                                from Membership__c 
                                                WHERE (Active_Contract_Idenfied__c != null AND Active_Contract_Idenfied__c IN: mapContract.keySet())
                                                        OR 
                                                        (Earliest_Contract__c != null AND Earliest_Contract__c IN: mapContract.keySet())
                                                        OR 
                                                        (Latest_Contract__c != null AND Latest_Contract__c IN: mapContract.keySet())]) {
            
                //Check if Earliest_Contract__r.Start__c is smaller then equals to today's date then set the Membership status as "Prospect - Pending Future Start Date"
                if(membership.Earliest_Contract__r.Start__c == null || membership.Earliest_Contract__r.Start__c > Date.today()) {
                    memberShipStatus = Constants.PROSPECT_PENDING_FUTURE_START_DATE;
                } 
                //If Active contract's end date is greater then today's date
                else if(membership.Active_Contract_Idenfied__r.End__c != null && membership.Active_Contract_Idenfied__r.End__c >= Date.today()) {
                    if(membership.Active_Contract_Idenfied__r.Status__c != null && membership.Active_Contract_Idenfied__r.Status__c == Constants.HONORARY) {
                        memberShipStatus = Constants.MEMBER_HONORARY;
                    } else if(membership.Payer_Status__c != null && membership.Payer_Status__c == Constants.PAYER){
                        memberShipStatus = Constants.MEMBER_PAYER;
                    } else {
                        memberShipStatus = Constants.MEMBER_INTEGRATED;
                    }
                } else if(membership.Latest_Contract__r.End__c != null && membership.Latest_Contract__r.End__c < Date.today() 
                            && membership.Latest_Contract__r.Renewal_Opp_Status__c != null 
                            && membership.Latest_Contract__r.Renewal_Opp_Status__c != ''
                            && (membership.Latest_Contract__r.Renewal_Opp_Status__c.toLowerCase().contains(Constants.PENDING)
                                || membership.Latest_Contract__r.Renewal_Opp_Status__c.toLowerCase().contains(Constants.CONTRACT_RECEIVED))
                            ) {
                    if (membership.Latest_Contract__r.Status__c  == Constants.HONORARY) {
                        memberShipStatus = Constants.MEMBER_HONORARY_GRACE;
                    } else if(membership.Latest_Contract__r.Payer_Account__c != null && membership.Latest_Contract__r.Payer_Account__c == membership.Account_Name__c) {
                        memberShipStatus = Constants.MEMBER_PAYER_GRACE;
                    } else {
                        memberShipStatus = Constants.MEMBER_INTEGRATED_GRACE;
                    }
                } else if(membership.Latest_Contract__r.End__c < Date.today() 
                            && membership.Latest_Contract__r.End__c > (Date.today() - 270)
                            && (membership.Latest_Contract__r.Renewal_Opp_Status__c == Constants.DROPPED
                                || membership.Latest_Contract__r.Renewal_Opp_Status__c == Constants.VOIDER)) {
                    memberShipStatus = Constants.PROSPECT_RECENT_DROP;
                } else if(membership.Earliest_Contract__r.Start__c >= date.newInstance(1960,01,01)) {
                    if(membership.Active_Contract_Idenfied__r.Start__c > Date.today()) {
                        memberShipStatus = Constants.PROSPECT_PENDING_FUTURE_START;
                    } else {
                        memberShipStatus = Constants.PROSPECT_PAST_MEMBER;
                    }   
                } else {
                    memberShipStatus = Constants.PROSPECT_PURE;
                }
                
                //Checking for the value change and according populating the list with records
                if(membership.Membership_Status__c != memberShipStatus) {
                    membership.Membership_Status_Text__c = memberShipStatus;
                    membership.Membership_Status_Change_Date__c = system.today();
                    memberShipsToBeUpdated.add(membership);
                }
            }
        
            //Check for the list size and update the recors if needed
            if(memberShipsToBeUpdated.size() > 0) {
                update memberShipsToBeUpdated;
            }
        }        
    }
    
    //This method is to update the Total_Negotiated_Amt__c on Invoice_Billing_Schedule__c record 
    //with sum of Negotiated_Amount__c field of related Contract__c records
    public static void updateTotalNegotiatedAmount(List<Contract__c> contracts) {
        
        //prepare a set of related invoice billing schedule records
        Set<Id> iBSRecords = new Set<Id>();
        
        //loop through the records list
        for(Contract__c contract : contracts){
            
            //check if invoice billing schedule record id is not null, then add it into the set
            if(contract.Invoice_Billing_Schedule__c != null){
                iBSRecords.add(contract.Invoice_Billing_Schedule__c);
            }
        }
        
        //clone of billing schedule
        Set<Id> cloneIBSRecords = new Set<Id>();
        
        //Checking set for size value
        if(iBSRecords.size() > 0) {
        
            //get the aggregate sum of Negotiated_Amount__c field from  Contract__c records
            AggregateResult[] results = [Select Invoice_Billing_Schedule__c iBSId, SUM(Negotiated_Amount__c) totalAmout from Contract__c
                                         WHERE Invoice_Billing_Schedule__c != null AND Invoice_Billing_Schedule__c in: iBSRecords 
                                         GROUP BY Invoice_Billing_Schedule__c];
            
            //List of Invoice_Billing_Schedule__c records to be updated
            List<Invoice_Billing_Schedule__c> listIBSRecords = new List<Invoice_Billing_Schedule__c>();
        
            //Set to hold the ids of the records found
            Set<Id> usedIBSRecords = new Set<Id>(); 
            
            //loop through the results
            for(AggregateResult result : results) {
                
                //add Invoice_Billing_Schedule__c id in set 
                usedIBSRecords.add((Id)result.get('iBSId'));
                
                //add record in the list need to be updated
                listIBSRecords.add(new Invoice_Billing_Schedule__c(Id = (Id)result.get('iBSId'), Total_Negotiated_Amt__c = (Decimal)result.get('totalAmout')));
            }
        
            //remove the records have been used from iBSRecords
            cloneIBSRecords = iBSRecords;
            cloneIBSRecords.removeAll(usedIBSRecords);
            
            //update records with  total amount 
            //loop through the results
            for(ID unusedId : cloneIBSRecords) {
                
                //add record in the list need to be updated
                listIBSRecords.add(new Invoice_Billing_Schedule__c(Id = unusedId, Total_Negotiated_Amt__c = 0));
            }
        
            //update the listIBSRecords
            if(listIBSRecords.size() > 0) {
                Util.byPassAllTriggers = true;
                update listIBSRecords;
                Util.byPassAllTriggers = false;
            }
        }
    }    
    
    //update Contract's child line item schedules with the invoice billing schedule id
    public static void updateLISWithContractABCIBS(List<Contract__c> records) {
        
        //Variable to hold the clone of Line Item schedule
        List<Line_Item_Schedule__c>  lineItemScheduleClone = new List<Line_Item_Schedule__c>();
        
        //Variable to hold the master Line Item schedule
        List<Line_Item_Schedule__c>  lisToBeDeleted = new List<Line_Item_Schedule__c>();
        
        //Checking list for null and size value
        if(records != null && records.size() > 0) {
        
            //retrive all the LIS records related to Contracts
            //inner query to fetch all trhe LIS item related with contratcs
            //update the LIS's IBS id if it's different
            for(Contract__c contractABC : [SELECT Id, Invoice_Billing_Schedule__c, 
                                            (SELECT Contract__c, Invoice_Billing_Schedule_del__c, Amount__c, 
                                                Invoice_Comment__c, Invoice_Date__c, Type__c from Line_Item_Schedule__r) 
                                            FROM Contract__c WHERE Id IN : records]) {
            
                //loop through the lis records
                if(contractABC.Line_Item_Schedule__r != null && contractABC.Line_Item_Schedule__r.size() > 0) {
                    
                    //create a temporary list to add te records to be deleted
                    List<Line_Item_Schedule__c>  tempListToBeDeleted = new List<Line_Item_Schedule__c>();
                    
                    //loop through the related contracts and create a list to be deleted
                    for(Line_Item_Schedule__c lisRecord : contractABC.Line_Item_Schedule__r) {
                        
                        //check if contract's IBS is different then LIS IBS id then update the LIS record with the same id
                        if(contractABC.Invoice_Billing_Schedule__c != null 
                           && lisRecord.Invoice_Billing_Schedule_del__c != contractABC.Invoice_Billing_Schedule__c) {
                            tempListToBeDeleted.add(lisRecord);
                        }
                    }
                    
                    //Create a clone of teh contracts records
                    List<Line_Item_Schedule__c>  cloneList = tempListToBeDeleted.deepClone(false);
                    
                    //Loop through line item schedules
                    for(Line_Item_Schedule__c lisRecord : cloneList) {
                        
                        //check if contract's IBS is different then LIS IBS id then update the LIS record with the same id
                        if(contractABC.Invoice_Billing_Schedule__c != null && lisRecord.Invoice_Billing_Schedule_del__c != contractABC.Invoice_Billing_Schedule__c) {
                            lisRecord.Invoice_Billing_Schedule_del__c = contractABC.Invoice_Billing_Schedule__c;
                            lineItemScheduleClone.add(lisRecord);
                        }
                    }
                    
                    //add the master LIS in the list to be deleted
                    lisToBeDeleted.addAll(tempListToBeDeleted);
                }
            }
        
            //update the LIS records
            if(lineItemScheduleClone.size() > 0) {
                Util.byPassAllTriggers = true;
                insert lineItemScheduleClone;
                Util.byPassAllTriggers = false;
            }
                
            //delete the master Contract records
            if(lisToBeDeleted.size() > 0) 
                delete lisToBeDeleted;
        }
    }    
    
    //This method is to check wheather LIS is associated with the Contract ABC record, if yes then don't allow IBS id as null
    public static void validateIBSIdForContactABC(List<Contract__c> records) {
        
        //Create a collection of the records to be processed
        List<Contract__c> nullIBSContracts = new List<Contract__c>();
        
        //loop through the Contract ABC records and create a collection of Contracts having IBS as Null
        for(Contract__c contractABC : records) {
            
            //check if IBS is null then add teh record in list
            if(contractABC.Invoice_Billing_Schedule__c == null) {
                nullIBSContracts.add(contractABC);
            }
        }
        
        //Checking list for size value
        if(nullIBSContracts.size() > 0) {
        
            //query to database to check whether these contractABC records have LIS associated with them or not
            //if yes then throw the exception that IBS cannot be null for contracts having LIS associated with them.
            for(Contract__c contractABC : [Select Id, 
                                            (Select Id from Line_Item_Schedule__r limit 1) 
                                           from Contract__c where Id in: nullIBSContracts ]) {
                
                //check for the Line_Item_Schedule__r size
                if(contractABC.Line_Item_Schedule__r != null && contractABC.Line_Item_Schedule__r.size() > 0) {
                    throw new CustomException('You cannot remove the Invoice Billing Schedule link for contracts that have Line Item Schedules.'
                                                + 'To remove the Invoice Billing Schedule link you must first delete all child Line Item Schedules.');
                }
            }
        }        
    }
    
    //Added by Abhinav Sharma - CR-20150820-9167 - 08/25/2015
    /**
     *  @description    : If any update happens on "Type__c" field then this method will update all of opportunity
     *                    records where contract ABC was stamped there as "Contract Signed Opportunity". 
     *                    They will ultimately keep the "Renewal Contract Type" field
     *                    in sync on those records.
     * 
     *  @args           : List of new contract ABC records, Map of old contract ABC records
     * 
     *  @return         : void
     * 
    **/
    public static void doUpdateOnOpportunitiesOnContractABCTypeUpdate(List<Contract__c> contracts, Map<Id, Contract__c> mapOldContracts) {
        
        //Set to hold the user records Id value
        Set<Id> setEligibleContractsIds = new Set<Id>();
        
        //Loop through contract records
        for(Contract__c con : contracts) {
            
            //Checking for "Type__c" field update/change on contract records
            //Accordingly populating the set with Id values
            if(mapOldContracts != null
                && (
                    mapOldContracts.get(con.Id).Type__c != con.Type__c
                ) 
            ){
                setEligibleContractsIds.add(con.Id);    
            }
        }
        
        //Checking set for size value
        if(setEligibleContractsIds.size() > 0) {
            
            //Map of opportunities going to be update to keep the fields in sync
            Map<Id, Opportunity> mapOpportunities = new Map<Id, Opportunity>();
            
            //Loop through opportunity records and populating map accordingly
            for(Opportunity o : [SELECT ID, Signed_Opportunity_Contract__c, Signed_Opportunity_Contract__r.Type__c, Renewal_Contract_Type__c 
                                    FROM Opportunity
                                    WHERE Signed_Opportunity_Contract__c != null 
                                    AND Signed_Opportunity_Contract__c IN : setEligibleContractsIds]) {
                if(o.Renewal_Contract_Type__c != o.Signed_Opportunity_Contract__r.Type__c) {
                    o.Renewal_Contract_Type__c = o.Signed_Opportunity_Contract__r.Type__c;
                    mapOpportunities.put(o.Id, o);
                }
            }

            //Checking map for size value
            if(mapOpportunities.values().size() > 0) {
                Util.byPassAllTriggers = true;
                update mapOpportunities.values();
                Util.byPassAllTriggers = false;
            }
        }
    }
    
    //Added By - Abhinav Sharma - 09/03/2015 - CR-20150205-8660
    /**
     *  @description    : This method is there to populate "Active Membership Main Contact" field on associated membership records
     *                    with the "Main Contact" value from the parent contract record.
     * 
     *  @args           : List of new contract ABC records, Map of old contract ABC records
     * 
     *  @return         : void
     * 
    **/
    public static void updateActiveMembershipMainContact(List<Contract__c> contracts, Map<Id, Contract__c> mapOldContracts) {
        
        //Map of Contracts ABC records
        Map<Id, Contract__c> mapContracts = new Map<Id, Contract__c>();

        //Loop through contract records
        for(Contract__c con : contracts) {

            //Checking for the field value change and accordingly populating map with values
            if(mapOldContracts != null && (mapOldContracts.get(con.Id).Main_Contact__c != con.Main_Contact__c))
                mapContracts.put(con.Id, new Contract__c(Id = con.Id, Main_Contact__c = con.Main_Contact__c));
        }
        
        //Checking for map values size
        if(mapContracts.values().size() > 0) {

            //Map of memberships
            Map<Id, Membership__c> mapMembership = new Map<Id, Membership__c>();

            //Loop through opportunity records and populating map accordingly
            for(Membership__c member : [SELECT ID, Active_Contract_Main_Contact__c, Active_Contract_Idenfied__c FROM Membership__c
                                            WHERE Active_Contract_Idenfied__c != null
                                            AND Active_Contract_Idenfied__c IN : mapContracts.keySet()]) {
                //Checking for the null value and populating fields value
                if(mapContracts.get(member.Active_Contract_Idenfied__c) != null) {
                    if(member.Active_Contract_Main_Contact__c != mapContracts.get(member.Active_Contract_Idenfied__c).Main_Contact__c)
                    mapMembership.put(member.Id, new Membership__c(Id = member.Id , Active_Contract_Main_Contact__c =  mapContracts.get(member.Active_Contract_Idenfied__c).Main_Contact__c));    
                }                               
            }
            
            //Checking map for size value
            if(mapMembership.values().size() > 0) {
                Util.BypassAllTriggers = true;
                update mapMembership.values();
                Util.BypassAllTriggers = false;
            }
        }    
    }
    
    //Modified By - Mahedra Swarnkar - 07/05/2016 - CR-20160229-9651 - Added logic to populate New_Member_Programs_TD__c field on case
    //Added By - Abhinav Sharma - 02/13/2016 - CR-20150925-9267
    /**
     *  @description    :   Whenever a new Contract is Inserted (after insert) or the Start/End date fields are changed (after update) 
     *                      and the related Program's Business Line = RI, perform an update on all Cases related to that Institution. 
     * 
     *  @args           :   List of new contract ABC records, Map of old contract ABC records
     * 
     *  @return         :   void
     * 
    **/
    public static void populateFieldsOnCaseFromContract(List<Contract__c> contracts, Map<Id, Contract__c> mapOldContracts) {
        
        //Set to hold the parent account IDs
        Set<Id> parentAccountIds = new Set<Id>();
        
        //Set to hold the Contract IDs
        Set<Id> setContractIds = new Set<Id>();
        
        //Loop through contract records
        for(Contract__c cABC : contracts) {
            
            //populating setContractIds
            if(mapOldContracts == null || (mapOldContracts != null && cABC.End__c != mapOldContracts.get(cABC.Id).End__c))
                setContractIds.add(cABC.Id);
            
            //Checking for fields values
            if(cABC.Payer_Account__c != null) {
                    
                //Checking for the event type (Insert and Update case)
                if(mapOldContracts == null || (mapOldContracts != null && contracts !=  null
                                                && 
                                                (cABC.Payer_Account__c != mapOldContracts.get(cABC.Id).Payer_Account__c
                                                || 
                                                cABC.Business_Line__c != mapOldContracts.get(cABC.Id).Business_Line__c
                                                ||
                                                cABC.Type__c != mapOldContracts.get(cABC.Id).Type__c
                                                ||
                                                cABC.Start__c != mapOldContracts.get(cABC.Id).Start__c
                                                ||
                                                cABC.End__c != mapOldContracts.get(cABC.Id).End__c
                                                 ||
                                                cABC.Program__c != mapOldContracts.get(cABC.Id).Program__c
                                                )
                                              ) 
                ) { 
                    parentAccountIds.add(cABC.Payer_Account__c);     
                    
                    //Old Account record Id value (In case account got changed on contract record)
                    if(mapOldContracts != null && mapOldContracts.get(cABC.Id).Payer_Account__c != null)
                        parentAccountIds.add(mapOldContracts.get(cABC.Id).Payer_Account__c);
                }
            }
        }
        
        //List to hold the case records to be Updated 
        List<Case> listCaseToBeUpdated = new List<Case>();
        
        //Check for Size
        if(setContractIds.size() > 0) {
            
            //Query through Case records 
            for(Case tdCase : [Select Id, Project_Year__c, Project_Source_MS__c, Project_Source_MS__r.Name, Contract__c, Contract__r.End__c
                                 From Case where RecordTypeId =: Util.RecordTypeId('Case', 'Talent Development') AND Contract__c != null AND Contract__c IN : setContractIds]) {
                
                if(tdCase.Project_Source_MS__c != null ) {
                    
                    if(tdCase.Contract__c != null && tdCase.Contract__r.End__c != null )
                        tdCase.Project_Year__c =  tdCase.Project_Source_MS__r.Name + ' - ' + tdCase.Contract__r.End__c.year();
                    else
                        tdCase.Project_Year__c =  tdCase.Project_Source_MS__r.Name + ' - null';
                }
                else{
                    
                    if(tdCase.Contract__c != null && tdCase.Contract__r.End__c != null )
                        tdCase.Project_Year__c =  'null - ' + tdCase.Contract__r.End__c.year();
                    else
                        tdCase.Project_Year__c =  'null - null';
                }
				listCaseToBeUpdated.add(tdCase);
            }   
        } 
        
        
        //Map to hold  account Id as a key and list of related contracts as values
        Map<Id, List<Contract__c>> mapAccountWithContracts = new Map<Id, list<Contract__c>>();
        
        //Checking set for size value
        if(parentAccountIds.size() > 0) {
        
            //Loop through contract records
            for(Contract__c cABC : [SELECT ID, Program_Acronym__c, Payer_Account__c, Start__c, End__c, Business_Line__c
                                    FROM Contract__c
                                    WHERE Payer_Account__c != null 
                                    AND Payer_Account__c IN : parentAccountIds
                                    AND Type__c =: Constants.CONTRACT_TYPE_NBB 
                                    AND (
                                            Business_Line__c =: System.Label.CASE_NEW_MEMBER_PROGRAMS_TYPE
                                            OR Business_Line__c = 'TD'
                                        )
                                    AND Start__c != null
                                    AND End__c != null
                                    ORDER By End__c DESC]) {
                                        
                //Checking for parent account presence and populating map accordingly                       
                if(mapAccountWithContracts.containsKey(cABC.Payer_Account__c)) 
                    mapAccountWithContracts.get(cABC.Payer_Account__c).add(cABC);  
                else   
                    mapAccountWithContracts.put(cABC.Payer_Account__c, new List<Contract__c>{cABC});   
            }
        }
            
        //Get all record types on case object
        Map<String, Id> caseRecordTypesMap = Util.recordtypemap(Constants.CASE_OBJECT);
        
        //Set to hold the eligible record type IDs
        Set<Id> eligibleCaseRecordTypes = new Set<Id>();
        
        //Map to hold the case record type Id as key and correspodning record type label as value
        Map<Id, String>  mapRecordTypes = new Map<Id, String>();
        
        //Looping over map keyset and accordingly populating collection with map retrieved values
        for(String recordTypeLabel : caseRecordTypesMap.keySet()) {
            if(recordTypeLabel != null 
               && (
                    recordTypeLabel.equalsIgnoreCase(System.Label.CASE_NEW_MEMBER_RECORD_TYPE)
                    || recordTypeLabel.equalsIgnoreCase('Talent Development')
                  )
               && caseRecordTypesMap.get(recordTypeLabel) != null   
              )
                eligibleCaseRecordTypes.add(caseRecordTypesMap.get(recordTypeLabel));
                
            //Populating map to hold the case record type Id as key and correspodning record type label as value
            if(String.isNotBlank(recordTypeLabel) 
               && caseRecordTypesMap.containsKey(recordTypeLabel)
               && caseRecordTypesMap.get(recordTypeLabel) != null)
                mapRecordTypes.put(caseRecordTypesMap.get(recordTypeLabel), recordTypeLabel);       
        }          
            
        //Checking if eligible case record type exists or not
        if(eligibleCaseRecordTypes != null && eligibleCaseRecordTypes.size() > 0 
           && parentAccountIds != null && parentAccountIds.size() > 0) {
                
            //Map of cases
            Map<Id, Case> mapOfCases = new Map<Id, Case>([SELECT ID, AccountID, New_Member_Programs_RI__c, New_Member_Programs_TD__c, CreatedDate, RecordTypeId  FROM Case 
                                                          WHERE AccountId != null
                                                          AND AccountId IN : parentAccountIds
                                                          AND RecordTypeId IN: eligibleCaseRecordTypes]);  
                                                                
            //Checking if eligible cases are associated with the contract records
            if(mapOfCases != null && mapOfCases.keySet().size() > 0) {
                    
                //Map of case records, will going to update with fields values
                Map<Id, Case> mapOfCasesWillUpdate = new Map<Id, Case>();
                
                //Loop over case records
                for(Case c : mapOfCases.values()) {
                        
                    //Temporary variable to hold the contracts program acronyms Concatenated string literal value
                    String programAcromyms = '';
                    String programAcromymsForTD = '';   
                
                    //Checking for eligible contract records presence and then accordingly concatenating "Program Acronyms" string literal
                    if(mapAccountWithContracts != null && mapAccountWithContracts.containsKey(c.AccountId) 
                        && mapAccountWithContracts.get(c.AccountId) != null 
                        && mapAccountWithContracts.get(c.AccountId).size() > 0) {
                        
                        //getting created date GTM time zone value (for comparision in between value)    
                        Date myDate = Date.newInstance(c.CreatedDate.year(), c.CreatedDate.month(), c.CreatedDate.day());
                        Time myTime = Time.newInstance(0, 0, 0, 0);
                        DateTime dt = DateTime.newInstanceGMT(myDate, myTime);
                               
                        //Loop through contract records
                        for(Contract__c conABC : mapAccountWithContracts.get(c.AccountId)) {
                            //Checking and validating contract "Start" and "End" dates with respect to the case record 
                            //which is in current context
                            if(conABC.Start__c <= dt && conABC.End__c >= dt) {
                                
                                if(mapRecordTypes.get(c.RecordTypeId).equalsIgnoreCase(System.Label.CASE_NEW_MEMBER_RECORD_TYPE)  && conABC.Business_Line__c == 'RI' )
                                    programAcromyms += conABC.Program_Acronym__c + Constants.COMMA;
                                        
                                if(mapRecordTypes.get(c.RecordTypeId).equalsIgnoreCase('Talent Development') && conABC.Business_Line__c == 'TD')
                                    programAcromymsForTD += conABC.Program_Acronym__c + Constants.COMMA;
                            }
                        }
                               
                        //Removing additional "," from the end of concatenated string literal (if exists)
                        if(programAcromyms != '') {
                               
                            //Trim the white spaces
                            programAcromyms = programAcromyms.trim();
                               
                            //Checking if last character of string literal is "Comma" or not
                            if(programAcromyms.substring((programAcromyms.length()-1), programAcromyms.length()) == Constants.COMMA)
                                programAcromyms = programAcromyms.removeEnd(Constants.COMMA);
                        }
                        
                        //Removing additional "," from the end of concatenated string literal (if exists)
                        if(programAcromymsForTD != '') {
                               
                            //Trim the white spaces
                            programAcromymsForTD = programAcromymsForTD.trim();
                               
                            //Checking if last character of string literal is "Comma" or not
                            if(programAcromymsForTD.substring((programAcromymsForTD.length()-1), programAcromymsForTD.length()) == Constants.COMMA)
                                programAcromymsForTD = programAcromymsForTD.removeEnd(Constants.COMMA);
                        }
                    } else {
                        programAcromyms = '';
                        programAcromymsForTD = '';
                    }
                    
                    //First checking for the difference in between new and old value and accordingly Setting field value on the case records
                    if(c.New_Member_Programs_RI__c != programAcromyms) {
                        c.New_Member_Programs_RI__c = programAcromyms;  
                        mapOfCasesWillUpdate.put(c.Id, c);
                    }
                    
                    //First checking for the difference in between new and old value and accordingly Setting field value on the case records
                    if(c.New_Member_Programs_TD__c != programAcromymsForTD ) {
                        c.New_Member_Programs_TD__c = programAcromymsForTD ;  
                        mapOfCasesWillUpdate.put(c.Id, c);
                    }                           
                }
                    
                //Checking for size value
                if(mapOfCasesWillUpdate != null && mapOfCasesWillUpdate.values().size() > 0) {
                    Util.byPassAlltriggers = true;
                    update mapOfCasesWillUpdate.values();
                    Util.byPassAlltriggers = false;
                }
            }                                   
        }
        
        //Checking for size value
        //Updating the case records
        if(listCaseToBeUpdated.size() > 0){
            
            Util.byPassAlltriggers = true;
            update listCaseToBeUpdated;
            Util.byPassAlltriggers = false;
        }
    }
}