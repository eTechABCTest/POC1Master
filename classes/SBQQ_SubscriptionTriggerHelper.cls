/**
 *  Description     :  Helper class for SBQQ_SubscriptionTrigger trigger.
 *
 *  Created By      :  Subhash Garhwal
 *
 *  Created Date    :  06/30/2016
 *
 *  Revision Logs   :   V_1.0 - Created - Subhash Garhwal - CR-20160414-9762 
 *                      V_1.1 - Modified - 08/01/2016 - Subhash Garhwal - CR-20160414-9762 - Added new method validateProgramOpportunities
 *                      V_1.2 - Modified - 09/13/2016 - Subhash Garhwal - CR-20160830-10158 - Updated syncProgramOppsWithSubscriptions method to change
 *                                                                                            calculations for Previous Year Negotiated field value.
                        V_1.3 - Modified - 09/27/2016 - Subhash Garhwal - CR 10158 - Populateed LOA_Contract__c field
                        V_1.4 - Modified - 10/12/2016 - Subhash Garhwal -  - Q2C Hypercare of Hypercare
 *
 **/
public without sharing class SBQQ_SubscriptionTriggerHelper {
    
    /**
     *  @description    :   This method is used to create/update Program Opportunities for Subscription records under the Contract record according 
     *                      Segment Index and Record Type:
     *                      Details from Work Order:
     *                      1. PT Program Opps (PT record types): 
     *                          i). 1st Subscription will goes under the original Program Opp.
     *                          ii). For the middle term Subscriptions, create Opps with record type 'Program - PT Maintenance'.
     *                              If the entire term is only 2 years, then there will not be any Maintenance Opps.
     *                          iii). For the final term Subscription, create Opps with record type 'Program - PT Renewal'.
     *                               There will always only be one of this type for each Program.
     *
     *                      2. RI Program Opps (RI Record Types):
     *                          i). 1st Subscription will goes under the original Program Opp.
     *                          ii). For the second year Subscription (first year after the initial Marketing Opp), create Opps with record type
     *                              'Program - RI AM First Year Opp'.  If the entire term is only 2 years, then there only be a Marketing Opp and
     *                              a First Year Opp.
     *                          iii). For the following year Subscription(s), create Opps with record type 'Program - RI AM Standard Opp'.
     *
     *                      3. Link the Subscription records:
     *                          i). If a top-level Program (Subscription), link it to the parent Contract Opportunity.
     *                          ii). If a renewable item (Subscription) record, link to the Program Opp record with the same Program association and same Segment Index
     *
     *                      4. Top-level Subscription:
     *                          Is A Program != nulll (Subscription.SBQQ__QuoteLine__c.Is_A_Program__c)
     *                          Segment Index == null
     *                          Related Product == null
     *                            
     *                      5. Renewal Subscription:
     *                          Is A Program == nulll (Subscription.SBQQ__QuoteLine__c.Is_A_Program__c)
     *                          Segment Index != null
     *                          Related Product != null
     *
     *  @args           :   Set<Id>
     *
     *  @return         :   void
     *
     *  @revision Log   :   V_1.0 - Created - 06/30/2016 - Subhash Garhwal - CR-20160414-9762
     *                      V_1.2 - Modified - 09/13/2016 - Subhash Garhwal - CR-20160830-10158 - Updated method to change calculations for
     *                                                                                            Previous Year Negotiated field value.
     *                      Details from Work Order: Verify that the ‘Previous Year Negotiated’ field on the renewal year Program Opp records does not
     *                                               include the amount related to a Product where Product Category = ‘Initiation Fee’
     *
     **/
    public static void syncProgramOppsWithSubscriptions(Set<Id> setSubscriptionIds) {
        
        //Map to hold the Max no of Subscriptions with Contract
        Map<Id,Integer> mapContWithMaxSubscriptions = new Map<Id, Integer>();
        
        //Map to hold the Opportunity Id as key and related Contract records as value
        Map<Id, Set<Id>> mapOppIdWithRelatedContractIds = new Map<Id, Set<Id>>();
        
        //Map to hold the Subscription Records with corresponding Contract
        Map<Id, List<SBQQ__Subscription__c>> mapContractIdWithSubscriptions = new Map<Id, List<SBQQ__Subscription__c>>();
        
        //Query through the Subscription Record
        List<SBQQ__Subscription__c> subscriptions = [Select Id, SBQQ__Contract__c, SBQQ__Contract__r.SBQQ__Opportunity__c, Segment_Index__c, Segment_Label__c,
                                               Related_Product__c, SBQQ__QuoteLine__c, SBQQ__QuoteLine__r.Is_a_Program__c, SBQQ__QuoteLine__r.Program_or_Component__c,SBQQ__QuoteLine__r.SBQQ__Product__c,
                                               SBQQ__QuoteLine__r.SBQQ__Product__r.Program__c, SBQQ__QuoteLine__r.SBQQ__RequiredBy__c, SBQQ__QuoteLine__r.SBQQ__RequiredBy__r.SBQQ__Product__c,
                                               SBQQ__QuoteLine__r.SBQQ__RequiredBy__r.SBQQ__Product__r.Program__c, SBQQ__CustomerPrice__c,Customer_Total__c,
                                               SBQQ__SegmentEndDate__c, SBQQ__SegmentStartDate__c, SBQQ__Product__c, SBQQ__Product__r.Product_Category__c From SBQQ__Subscription__c Where Id IN : setSubscriptionIds
                                               AND SBQQ__Contract__r.SBQQ__Opportunity__r.RecordType.DeveloperName =: CPQConstants.OPPORTUNITY_RECORD_TYPE_DEVELOPERNAME_CONTRACT_LOA
                                               AND SBQQ__Contract__r.SBQQ__Opportunity__r.SBQQ__Contracted__c = true AND Opportunity__c = null
                                               ORDER BY Segment_Index__c ASC NULLS FIRST];
                                                
        //Loop over Subscriptions 
        for(SBQQ__Subscription__c sub: subscriptions) {
            
            //Check Contract Id in map
            if(!mapContractIdWithSubscriptions.containsKey(sub.SBQQ__Contract__c))
                mapContractIdWithSubscriptions.put(sub.SBQQ__Contract__c, new List<SBQQ__Subscription__c>());
            
            //Add Subscription record in list
            mapContractIdWithSubscriptions.get(sub.SBQQ__Contract__c).add(sub);
            
            //Check Opportunity Id in map
            if(!mapOppIdWithRelatedContractIds.containsKey(sub.SBQQ__Contract__r.SBQQ__Opportunity__c))
                mapOppIdWithRelatedContractIds.put(sub.SBQQ__Contract__r.SBQQ__Opportunity__c, new Set<Id>());
            
            //Add Contract Id in map
            mapOppIdWithRelatedContractIds.get(sub.SBQQ__Contract__r.SBQQ__Opportunity__c).add(sub.SBQQ__Contract__c);
            
            //Check unique Identifier in map
            if(!mapContWithMaxSubscriptions.containsKey(sub.SBQQ__Contract__c))
                mapContWithMaxSubscriptions.put(sub.SBQQ__Contract__c, (Integer) sub.Segment_Index__c);
            else if(mapContWithMaxSubscriptions.get(sub.SBQQ__Contract__c) == null || mapContWithMaxSubscriptions.get(sub.SBQQ__Contract__c) < sub.Segment_Index__c)
                mapContWithMaxSubscriptions.put(sub.SBQQ__Contract__c, (Integer) sub.Segment_Index__c);
        }
        
        //Check for opportunity size
        if(mapOppIdWithRelatedContractIds.size() > 0) {
            
            //Map to hold the Program Opportunities with corresponding Contract records
            Map<Id, Map<Id, Opportunity>> mapContIdWithProgramOpps = new Map<Id, Map<Id,Opportunity>>();
            
            //Map to hold the existing renewal Program Opps (Key = Contract Id + '-' + Program Id + '-' + Segment Index and Value : Program Opportunity)
            Map<String, Opportunity> mapExistingRenewalProgramOpportunities = new Map<String, Opportunity>();
            
            //Added - 09/13/2016 - Subhash Garhwal - CR-20160830-10158
            //Map to hold the Previous Year Negotiated values(Key = Contract Id + '-' + Program Id + '-' + Segment Index and Value : Decimal)
            Map<String, Decimal> mapPreviousYearNegotiatedValues = new Map<String, Decimal>();
            
            //Set to hold the Account Ids
            //This will use to get the membership records
            Set<Id> setAccountIds = new Set<Id>();
            
            //Set to hold the Program Ids
            Set<Id> setProgramIds = new Set<Id>();
            
            //Query through the Program Opportunities
            for(Opportunity opp : [Select Id, Amount, AccountId, Program__c, RecordTypeId, RecordType.DeveloperName, Parent_Opportunity__c,Segment_Index__c
                                          From Opportunity
                                          Where Parent_Opportunity__c IN : mapOppIdWithRelatedContractIds.keySet()
                                          AND RecordType.DeveloperName IN : CPQConstants.SET_OPPORTUNITY_CPQ_PROGRAM_OPP_RT_DEVELOPER_NAME
                                          AND Program__c != null]) {
                
                //Check opportunity Id
                if(mapOppIdWithRelatedContractIds.containsKey(opp.Parent_Opportunity__c)) {
                    
                    //Add Account Id in set
                    setAccountIds.add(opp.AccountId);
                    setProgramIds.add(opp.Program__c);
                    
                    //Loop over the Contract Ids
                    for(Id contId : mapOppIdWithRelatedContractIds.get(opp.Parent_Opportunity__c)) {
                        
                        //Check for Segment value
                        if(opp.Segment_Index__c == null) {
                            
                            //Check Contract Id in map
                            if(!mapContIdWithProgramOpps.containsKey(contId))
                                mapContIdWithProgramOpps.put(contId, new Map<Id,Opportunity>());
                            
                            //Add Program Opportunity in map
                            mapContIdWithProgramOpps.get(contId).put(opp.Program__c, opp);  
                        
                        } else {
                            
                            //Unique Identifier
                            mapExistingRenewalProgramOpportunities.put(contId + '-' + opp.Program__c + '-' + opp.Segment_Index__c, opp);        
                        }
                    }
                }                               
            }
            
            //Check for Program Opprtunities
            if(mapContIdWithProgramOpps.size() > 0) {
                
                //Map to hold the Membership Record Id with combination of account Id and program Id
                Map<String, Id> mapAccIdAndProIdWithMembershipId = new Map<String, Id>();
                
                //Query through the membership record
                for(Membership__c mem : [Select Id, Account_Name__c, Program__c From Membership__c Where Account_Name__c IN : setAccountIds AND Program__c IN : setProgramIds])
                    mapAccIdAndProIdWithMembershipId.put(mem.Account_Name__c + '-' + mem.Program__c, mem.Id);
                
                //List to update the Subscription records
                List<SBQQ__Subscription__c> subscriptionsToUpdate = new List<SBQQ__Subscription__c>();
                
                //Map to insert Cloned Program Opps (Key = Contract Id + '-' + Program Id + '-' + Segment Index and Value : Program Opportunity)
                Map<String, Opportunity> mapProgramOpportunities = new Map<String, Opportunity>();
                
                //Map to Hold the Subscription records (Key = Contract Id + '-' + Program Id + '-' + Segment Index and Value : List of Subscription)
                Map<String, List<SBQQ__Subscription__c>> mapSubscriptions = new Map<String, List<SBQQ__Subscription__c>>();
                
                //Get Opportunity Record types
                Map<String, Id> rtmap = Util.recordtypemap('Opportunity');
                
                //Loop over the Contract Ids
                for(Id contId : mapContractIdWithSubscriptions.keySet()) {
                    
                    //Loop over the subscription record
                    for(SBQQ__Subscription__c sub : mapContractIdWithSubscriptions.get(contId)) {
                        
                        //Top-Level Subscription
                        if(sub.SBQQ__QuoteLine__c != null && String.isNotBlank(sub.SBQQ__QuoteLine__r.Program_or_Component__c) && CPQConstants.SET_QUOTE_LINE_PROGRAM_IDENTIFIERS.contains(sub.SBQQ__QuoteLine__r.Program_or_Component__c)
                            && (sub.Segment_Index__c == null || sub.Segment_Index__c <= 0) && String.isBlank(sub.Related_Product__c)) {
                                
                            //Stamp the Subscription under the Parent Opportunity
                            sub.Opportunity__c = sub.SBQQ__Contract__r.SBQQ__Opportunity__c;
                            
                            //Add Subscription record in list
                            subscriptionsToUpdate.add(sub);     
                        
                        //Renewal Subscriptions
                        } else if((sub.SBQQ__QuoteLine__c == null || String.isBlank(sub.SBQQ__QuoteLine__r.Program_or_Component__c)
                                    || !CPQConstants.SET_QUOTE_LINE_PROGRAM_IDENTIFIERS.contains(sub.SBQQ__QuoteLine__r.Program_or_Component__c))
                                    && sub.Segment_Index__c != null && sub.Segment_Index__c > 0 && String.isNotBlank(sub.Related_Product__c)) {
                            
                            //Check Program Id in the map to verifiy if their is any Program Opportunity with Program
                            if(mapContIdWithProgramOpps.containsKey(contId) && sub.SBQQ__QuoteLine__c != null && sub.SBQQ__QuoteLine__r.SBQQ__RequiredBy__c != null
                                && sub.SBQQ__QuoteLine__r.SBQQ__RequiredBy__r.SBQQ__Product__c != null && sub.SBQQ__QuoteLine__r.SBQQ__RequiredBy__r.SBQQ__Product__r.Program__c != null
                                && mapContIdWithProgramOpps.get(contId).containsKey(sub.SBQQ__QuoteLine__r.SBQQ__RequiredBy__r.SBQQ__Product__r.Program__c)){
                                
                                //Instance of opportunity
                                Opportunity originalProOpp = mapContIdWithProgramOpps.get(contId).get(sub.SBQQ__QuoteLine__r.SBQQ__RequiredBy__r.SBQQ__Product__r.Program__c);
                                
                                //Check for Segment Index (If Segment index is one in that stamp subscription under the original Program Opp)
                                if(sub.Segment_Index__c == 1) {
                                    
                                    //Update Opportunity Amount
                                    if(!mapProgramOpportunities.containsKey('ParentOpp-' + originalProOpp.Id))
                                        originalProOpp.Amount = 0;
                                    
                                    originalProOpp.Amount = sub.SBQQ__CustomerPrice__c != null ? originalProOpp.Amount + sub.SBQQ__CustomerPrice__c : originalProOpp.Amount;
                                    
                                    //Added - 09/27/2016 - Subhash Garhwal - CR 10158 - Populateed LOA_Contract__c field
                                    originalProOpp.LOA_Contract__c = sub.SBQQ__Contract__c;
                                     
                                    //Add cloned Opportunity into map
                                    mapProgramOpportunities.put('ParentOpp-' + originalProOpp.Id, originalProOpp);
                                    
                                    //Stamp the Subscription under the Parent Opportunity
                                    sub.Opportunity__c = originalProOpp.Id;
                                    
                                    //Add Subscription record in list
                                    subscriptionsToUpdate.add(sub);
                                    
                                    //Added - 09/13/2016 - Subhash Garhwal - CR-20160830-10158 
                                    if(sub.SBQQ__CustomerPrice__c != null && sub.SBQQ__Product__c != null &&
                                        (sub.SBQQ__Product__r.Product_Category__c == null || sub.SBQQ__Product__r.Product_Category__c != CPQConstants.PRODUCT_CATEGORY_INITIATION_FEE)) {
                                        
                                        //Put original opportunity in map
                                        if(!mapPreviousYearNegotiatedValues.containsKey('ParentOpp-' + originalProOpp.Id))
                                            mapPreviousYearNegotiatedValues.put('ParentOpp-' + originalProOpp.Id, 0);
                                        
                                        //Add subscription price into map
                                        mapPreviousYearNegotiatedValues.put('ParentOpp-' + originalProOpp.Id, mapPreviousYearNegotiatedValues.get('ParentOpp-' + originalProOpp.Id) + sub.SBQQ__CustomerPrice__c);      
                                    }
                                } else {
                                    
                                    //Create a unique Identifier
                                    String uK = contId + '-' + originalProOpp.Program__c + '-' + sub.Segment_Index__c;
                                    
                                    //Added - 09/13/2016 - Subhash Garhwal - CR-20160830-10158 
                                    if(sub.SBQQ__CustomerPrice__c != null && sub.SBQQ__Product__c != null &&
                                        (sub.SBQQ__Product__r.Product_Category__c == null || sub.SBQQ__Product__r.Product_Category__c != CPQConstants.PRODUCT_CATEGORY_INITIATION_FEE)) {
                                        
                                        //Put original opportunity in map
                                        if(!mapPreviousYearNegotiatedValues.containsKey(uK))
                                            mapPreviousYearNegotiatedValues.put(uK, 0);
                                        
                                        //Add subscription price into map
                                        mapPreviousYearNegotiatedValues.put(uK, mapPreviousYearNegotiatedValues.get(uK) + sub.SBQQ__CustomerPrice__c);      
                                    }
                                    
                                    //Instance of Opportunity
                                    Opportunity proOpp = new Opportunity();
                                    
                                    //Check Unique key in map
                                    if(mapProgramOpportunities.containsKey(uK))
                                        proOpp = mapProgramOpportunities.get(uK);
                                    
                                    //Check for existing record
                                    else if(mapExistingRenewalProgramOpportunities.containsKey(uK))
                                        proOpp = mapExistingRenewalProgramOpportunities.get(uK);
                                    else {
                                        
                                        //Clone the record
                                        proOpp = originalProOpp.clone();
                                        proOpp.Amount = 0;
                                    }
                                        
                                    //Check UK in map
                                    if(!mapProgramOpportunities.containsKey(uK)) {
                                        
                                        
                                        //Check for Program Opportunity Record Type (PT)
                                        if(CPQConstants.SET_OPPORTUNITY_CPQ_PROGRAM_OPP_RT_DEVELOPER_NAME_PT.contains(originalProOpp.RecordType.DeveloperName)) {
                                            
                                            //Check for Segment Index and set Record Type
                                            if(sub.Segment_Index__c != mapContWithMaxSubscriptions.get(contId))
                                                proOpp.RecordTypeId = rtmap.get(CPQConstants.OPPORTUNITY_RECORD_TYPE_NAME_PROGRAM_PT_CONTRACT_MAINTENANCE);
                                            else if(sub.Segment_Index__c == mapContWithMaxSubscriptions.get(contId))
                                                proOpp.RecordTypeId = rtmap.get(CPQConstants.OPPORTUNITY_RECORD_TYPE_NAME_PROGRAM_PT_CONTRACT_RENEWAL);
                                            
                                            //Set PT record types specific fields
                                            proOpp.StageName = CPQConstants.OPPORTUNITY_STAGE_PENDING_RENEWAL_CALL_NOT_YET_OCCURED;
                                                
                                        //RI Record Type
                                        } else if(CPQConstants.SET_OPPORTUNITY_CPQ_PROGRAM_OPP_RT_DEVELOPER_NAME_RI.contains(originalProOpp.RecordType.DeveloperName)) {
                                            
                                            //Check for segment index and set Record Type
                                            if(sub.Segment_Index__c == 2 && sub.Segment_Index__c < mapContWithMaxSubscriptions.get(contId))
                                                proOpp.RecordTypeId = rtmap.get(CPQConstants.OPPORTUNITY_RECORD_TYPE_NAME_PROGRAM_RI_AM_FIRST_YEAR_OPP);
                                            else
                                                proOpp.RecordTypeId = rtmap.get(CPQConstants.OPPORTUNITY_RECORD_TYPE_NAME_PROGRAM_RI_AM_STANDARD_OPP);
                                            
                                            //Set PT record types specific fields
                                            proOpp.StageName = CPQConstants.OPPORTUNITY_STAGE_PENDING;
                                        }
                                        
                                        //Populate comman field values
                                        proOpp.Admin_Override__c = true;
                                        proOpp.Segment_Index__c = sub.Segment_Index__c;
                                        proOpp.Amount = 0;
                                        proOpp.CloseDate = sub.SBQQ__SegmentStartDate__c;
                                        proOpp.Start__c = sub.SBQQ__SegmentStartDate__c;
                                        proOpp.End__c = sub.SBQQ__SegmentEndDate__c;
                                        
                                        //Check for Membership
                                        if(mapAccIdAndProIdWithMembershipId.containskey(originalProOpp.AccountId + '-' + originalProOpp.Program__c))
                                            proOpp.Membership__c = mapAccIdAndProIdWithMembershipId.get(originalProOpp.AccountId + '-' + originalProOpp.Program__c);
                                        
                                        //Updated - 09/13/2016 - Subhash Garhwal - CR-20160830-10158 - Update Previous_Year_Negotiated__c value from Amount to mapPreviousYearNegotiatedValues map value 
                                        //Check for segment Index
                                        if(sub.Segment_Index__c == 2)
                                            proOpp.Previous_Year_Negotiated__c = mapPreviousYearNegotiatedValues.get('ParentOpp-' + originalProOpp.Id);
                                        else {
                                            
                                            //Check Previous record in map
                                            String previousUK = contId + '-' + originalProOpp.Program__c + '-' + (sub.Segment_Index__c - 1);
                                            
                                            //Check previous key in map
                                            if(mapProgramOpportunities.containsKey(previousUK)) {
                                                
                                                proOpp.Previous_Year_Negotiated__c = mapPreviousYearNegotiatedValues.get(previousUK);
                                                //proOpp.CloseDate = mapProgramOpportunities.get(previousUK).End__c;
                                            }
                                        }    
                                    }
                                    
                                    //Add additional amount
                                    proOpp.Amount = sub.SBQQ__CustomerPrice__c != null ? proOpp.Amount + sub.SBQQ__CustomerPrice__c : proOpp.Amount;
                                    
                                    //Added - 09/27/2016 - Subhash Garhwal - CR 10158 - Populateed LOA_Contract__c field
                                    proOpp.LOA_Contract__c = sub.SBQQ__Contract__c;
                                    
                                    //Add cloned Opportunity into map
                                    mapProgramOpportunities.put(uK, proOpp);
                                    
                                    //Check unique key in map
                                    if(!mapSubscriptions.containsKey(uK))
                                        mapSubscriptions.put(uK, new List<SBQQ__Subscription__c>());
                                    
                                    //Add Subscription record in map
                                    mapSubscriptions.get(uK).add(sub);
                                }
                            } 
                        } 
                    }
                }
                
                //Check for Program Opps
                if(mapProgramOpportunities.size() > 0) {
                    
                    //Insert
                    upsert mapProgramOpportunities.values();
                    
                    //Loop over the Subscription map
                    for(String uK : mapSubscriptions.keySet()) {
                        
                        //Check unique combination in program opps set
                        if(mapProgramOpportunities.containsKey(uK)) {
                            
                            //Loop over the subscription records
                            for(SBQQ__Subscription__c sub : mapSubscriptions.get(uK)) {
                                
                                //Update Opportunity
                                sub.Opportunity__c = mapProgramOpportunities.get(uK).Id;
                                
                                //Add Subscription in list
                                subscriptionsToUpdate.add(sub);
                            }
                        }
                    }
                }
                
                //Check for list size
                if(subscriptionsToUpdate.size() > 0)
                    update subscriptionsToUpdate;
            }
        }
    }
    
    /**
     *  @description    :   This method is used to update the Proposal Value on the Parent Opportunity (Program Opportunity), if subscription
     *                      Amount get changed
     *                      Details from UC# 7.11: A Subscription record needs to be editable by Finance Ops, according to Shelley Daniels.
     *                                             This is where corrections to the amounts or dates, such as contract red-lines, would need to be made.
     *                                             Only Finance Ops needs the ability to edit.  When edited, the total Proposal Value on the related
     *                                             Program Opp needs to be updated to the sum of the related Subscription records.  
     *
     *  @args           :   List<SBQQ__Subscription__c>, Map<Id, SBQQ__Subscription__c>
     *
     *  @return         :   void
     *
     *  @revision Log   :   V_1.0 - Created - 07/30/2016 - Subhash Garhwal - CR-20160414-9762
     *
     **/
    public static void validateProgramOpportunities(List<SBQQ__Subscription__c> subscriptions, Map<Id, SBQQ__Subscription__c> mapOldSubscriptions) {
        
        //Map to hold the Program Opportunity
        Map<Id, Opportunity> mapProgramOpportunities = new Map<Id, Opportunity>();
        
        //Loop over the subscription
        for(SBQQ__Subscription__c sub : subscriptions != null ? subscriptions : mapOldSubscriptions.values()) {
            
            //Update case
            if(mapOldSubscriptions != null && sub.Segment_Index__c != null && sub.Segment_Index__c > 0 &&
                (sub.SBQQ__CustomerPrice__c != mapOldSubscriptions.get(sub.Id).SBQQ__CustomerPrice__c || sub.Opportunity__c != mapOldSubscriptions.get(sub.Id).Opportunity__c)) {
                
                //Check for new Opportunity
                if(sub.Opportunity__c != null)
                    mapProgramOpportunities.put(sub.Opportunity__c, new Opportunity(Id = sub.Opportunity__c, Amount = 0));
                
                //Check for old Opportunity
                if(mapOldSubscriptions.get(sub.Id).Opportunity__c != null)
                    mapProgramOpportunities.put(mapOldSubscriptions.get(sub.Id).Opportunity__c, new Opportunity(Id = mapOldSubscriptions.get(sub.Id).Opportunity__c, Amount = 0));  
            }
            
            //Delete case
            if(subscriptions == null && sub.Segment_Index__c != null && sub.Segment_Index__c > 0 && sub.Opportunity__c != null)
                mapProgramOpportunities.put(sub.Opportunity__c, new Opportunity(Id = sub.Opportunity__c, Amount = 0));  
        }
        
        //Check for map size
        if(mapProgramOpportunities.size() > 0) {
            
            //Aggregate query through subscription record
            for(AggregateResult aR : [Select SUM(SBQQ__CustomerPrice__c) cP, Opportunity__c opp From SBQQ__Subscription__c
                                             Where Opportunity__c IN : mapProgramOpportunities.keySet() AND SBQQ__CustomerPrice__c != null GROUP BY Opportunity__c]) {
                
                //Get Opportunity Id
                Id oppId = Id.valueOf(String.valueOf(aR.get('opp')));
                
                //Check Opportunity Id in map
                if(mapProgramOpportunities.containsKey(oppId))
                    mapProgramOpportunities.get(oppId).Amount = (Decimal) aR.get('cP');                                 
            }
            
            //Update Opportunities
            update mapProgramOpportunities.values();
        
        }
    }
}