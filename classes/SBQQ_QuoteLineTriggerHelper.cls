/**
*  Description     :  Helper class for SBQQ_QuoteLineTrigger trigger.
*
*  Created By      :  Subhash Garhwal
*
*  Created Date    :  06/22/2016
*
*  Revision Logs   :   V_1.0 - Created - Subhash Garhwal - CR-20160414-9762
*                      V_1.1 - Modified - 08/10/2016 - Subhash Garhwal - CR-20160414-9762 - Added a new method "validateQuoteYearOneDiscount"
*                      V_1.2 - Modified - 08/19/2016 - Subhash Garhwal - CR-20160414-9762 - Added a new method "updateStandardPricing" and moved 
*                                                                                           syncProgramOpportunities method logic in future mmethod to avoid SOQL limit.    
*
**/
public without sharing class SBQQ_QuoteLineTriggerHelper {
    
    //Flag to contol the Quote Line trigger execution
    public static Boolean executeSyncProgramOpportunitiesLogic = true;
    
    //Flag to check update case with insert
    public static Boolean isUpdateWithInsert = false;
    
    /**
     *  @description    :   Moved "Update of proposal line" process builder logic into this method.
     *                      This method is used to calculate Standard Pricing of proposal line.
     *
     *  @args           :   List<SBQQ__QuoteLine__c>, Map<Id, SBQQ__QuoteLine__c>
     *
     *  @return         :   void
     *
     *  @revision Log   :   V_1.0 - 08/19/2016 - Created - Subhash Garhwal - CR-20160414-9762
     *
     **/
    public static void updateStandardPricing(List<SBQQ__QuoteLine__c> quoteLines, Map<Id, SBQQ__QuoteLine__c> mapOldQuoteLines) {
        
        //Loop over the quote Lines
        for(SBQQ__QuoteLine__c qL : quoteLines) {
            
            //Check trigger condition
            if(mapOldQuoteLines == null || qL.Standard_Price_Percentage__c != mapOldQuoteLines.get(qL.Id).Standard_Price_Percentage__c
                || qL.SBQQ__CustomerTotal__c != mapOldQuoteLines.get(qL.Id).SBQQ__CustomerTotal__c
                || qL.Standard_Pricing__c != mapOldQuoteLines.get(qL.Id).Standard_Pricing__c) {
                
                //Check for SBQQ__CustomerTotal__c
                if(qL.SBQQ__CustomerTotal__c != null) {
                    
                    //Check for Standard_Price_Percentage__c
                    if(qL.Standard_Price_Percentage__c != null && qL.Standard_Price_Percentage__c > 0)
                        qL.Standard_Pricing__c = Math.ROUND((qL.SBQQ__CustomerTotal__c * qL.Standard_Price_Percentage__c) + qL.SBQQ__CustomerTotal__c);
                    else
                        qL.Standard_Pricing__c = Math.ROUND(qL.SBQQ__CustomerTotal__c);
                }       
            }
        }
    }
    
    /**
     *  @description    :   This method is used to Create/Update/Delete the Program Opportunity (Child of Contract LOA Opp) according to created/updated/
     *                      deleted Quote Line/Proposal Line Record.
     *                      Details form WORK ORDER (Process): Create a Proposal quote on an opportunity with one or more Program Opps.  The Program(s) added to
     *                                               the Opp prior to the Proposal being created are not automatically pulled in to the Proposal.
     *                                               When the Proposal is saved, the Program(s) selected in the Proposal will be either added or
     *                                               updated and the Opp Stage is updated to 'Active in Slow Track'.
     *
     *  @args           :   List<SBQQ__QuoteLine__c>, Map<Id, SBQQ__QuoteLine__c>
     *
     *  @return         :   void
     *
     *  @revision Log   :   V_1.0 - Created - Subhash Garhwal - CR-20160414-9762
     *
     **/
    public static void syncProgramOpportunities(List<SBQQ__QuoteLine__c> quoteLines, Map<Id, SBQQ__QuoteLine__c> mapOldQuoteLines) {
        
        //Check for insert case
        if(quoteLines != null && mapOldQuoteLines == null)
            isUpdateWithInsert = true;
            
        //Check for new quote lines (Insert/Update case)
        if(quoteLines != null && quoteLines.size() > 0) {
            
            //Map to hold the Unique key (Parent Opp Id + Program Id) as key and list of Quote Line Item as value
            Map<String, List<SBQQ__QuoteLine__c>> mapQuoteLineItemWithUniqueIdentifier = new Map<String, List<SBQQ__QuoteLine__c>>();
            
            //Set to hold the Parent Opportunities Id. This will use to get all the Children Opp (Program Opportunities)
            Set<Id> setParentOppIds = new Set<Id>();
            
            //Set to hold the Program Ids. This will use to get all th Children Opp (Program Opportunities)
            Set<Id> setProgramIds = new Set<Id>();
            
            //Set to hold the Program Opportunites Ids that need to delete
            Set<Id> setProgramOppIdsToDelete = new Set<Id>();
            
            //Set to hold the Quote Lines Ids
            Set<Id> setQuoteLineIds = new Set<Id>();
            
            //Set to hold the Quote Line Ids to avoid duplicate record for proposal value calculation
            Set<Id> setValidQuoteLineIds = new Set<Id>();
            
            //Query through Quote Lines
            for(SBQQ__QuoteLine__c qL : [Select Id,Program_Opportunity__c, Program_Opportunity__r.RecordTypeId, Program_Opportunity__r.RecordType.DeveloperName,
                                         Program_Opportunity__r.StageName, Is_a_Program__c, SBQQ__Quote__c, SBQQ__Quote__r.SBQQ__Opportunity2__c,
                                         SBQQ__Quote__r.SBQQ__Opportunity2__r.AccountId, SBQQ__Quote__r.SBQQ__Opportunity2__r.Closedate,
                                         SBQQ__Product__c, SBQQ__Product__r.Program__c, SBQQ__Product__r.Program__r.Business_line__c,
                                         Is_Primary_Quote__c,SBQQ__PackageTotal__c, SBQQ__Quote__r.SBQQ__Opportunity2__r.Name, SBQQ__NetPrice__c,
                                         SBQQ__EffectiveQuantity__c, SBQQ__Existing__c, SBQQ__Renewal__c,SBQQ__ComponentTotal__c,SBQQ__RequiredBy__c,
                                         SBQQ__RequiredBy__r.SBQQ__Product__c, SBQQ__RequiredBy__r.SBQQ__Product__r.Program__c, Program_or_Component_Formula__c,
                                         SBQQ__RequiredBy__r.Program_or_Component_Formula__c, SBQQ__SegmentIndex__c
                                         From SBQQ__QuoteLine__c Where Id IN : quoteLines AND SBQQ__Quote__r.SBQQ__Opportunity2__c != null
                                         ORDER BY Program_or_Component_Formula__c ASC NULLS LAST]) {
                                           
                 //Check for appropriate condition
                 if(mapOldQuoteLines != null && (isUpdateWithInsert || qL.SBQQ__Product__c != mapOldQuoteLines.get(qL.Id).SBQQ__Product__c
                    || qL.SBQQ__NetPrice__c != mapOldQuoteLines.get(qL.Id).SBQQ__NetPrice__c
                    || qL.SBQQ__EffectiveQuantity__c != mapOldQuoteLines.get(qL.Id).SBQQ__EffectiveQuantity__c
                    || qL.SBQQ__Existing__c != mapOldQuoteLines.get(qL.Id).SBQQ__Existing__c
                    || qL.SBQQ__ComponentTotal__c != mapOldQuoteLines.get(qL.Id).SBQQ__ComponentTotal__c
                    || qL.SBQQ__RequiredBy__c != mapOldQuoteLines.get(qL.Id).SBQQ__RequiredBy__c)) {
                    
                    //Reset flag
                    isUpdateWithInsert = false;
                    
                         
                    //Check for Opportunity and Program
                    if(qL.SBQQ__Quote__c != null && qL.SBQQ__Quote__r.SBQQ__Opportunity2__c != null) {
                            
                        //Add Parent Opportunity Ids in set
                        setParentOppIds.add(qL.SBQQ__Quote__r.SBQQ__Opportunity2__c);
                            
                        //Unique Identifier
                        String uniqueIdentifier = '';
                            
                        //Check for Top-level Quote Line
                        if(((String.isNotBlank(qL.Program_or_Component_Formula__c) && CPQConstants.SET_QUOTE_LINE_PROGRAM_IDENTIFIERS.contains(qL.Program_or_Component_Formula__c))
                            || qL.SBQQ__RequiredBy__c == null) && qL.SBQQ__Product__c != null && qL.SBQQ__Product__r.Program__c != null) {
                                    
                            //Add Program in set
                            setProgramIds.add(qL.SBQQ__Product__r.Program__c);
                                    
                            //Create unique Identifier
                            uniqueIdentifier = qL.SBQQ__Quote__r.SBQQ__Opportunity2__c + '-' + qL.SBQQ__Product__r.Program__c;  
                                    
                        } else if(qL.SBQQ__RequiredBy__c != null && qL.SBQQ__RequiredBy__r.SBQQ__Product__c != null && qL.SBQQ__RequiredBy__r.SBQQ__Product__r.Program__c != null) {
                                    
                            //Add Program in set
                            setProgramIds.add(qL.SBQQ__RequiredBy__r.SBQQ__Product__r.Program__c);
                            
                            //Create unique Identifier
                            uniqueIdentifier = qL.SBQQ__Quote__r.SBQQ__Opportunity2__c + '-' + qL.SBQQ__RequiredBy__r.SBQQ__Product__r.Program__c;
                        }
                            
                        //Check for Unique Identifier
                        if(String.isNotBlank(uniqueIdentifier)) {
                            
                            //Check unique key in map
                            if(!mapQuoteLineItemWithUniqueIdentifier.containsKey(uniqueIdentifier))
                                mapQuoteLineItemWithUniqueIdentifier.put(uniqueIdentifier, new List<SBQQ__QuoteLine__c>());
                            
                            //Add Quote Line into map
                            mapQuoteLineItemWithUniqueIdentifier.get(uniqueIdentifier).add(qL);
                            
                            //Add Id in set
                            setValidQuoteLineIds.add(qL.Id);
                        }
                    }
                        
                    //Check for product change case
                    if(mapOldQuoteLines != null && qL.Program_Opportunity__c != null &&
                       (qL.SBQQ__Product__c != mapOldQuoteLines.get(qL.Id).SBQQ__Product__c || qL.Program_or_Component_Formula__c != mapOldQuoteLines.get(qL.Id).Program_or_Component_Formula__c
                        || qL.SBQQ__RequiredBy__c != mapOldQuoteLines.get(qL.Id).SBQQ__RequiredBy__c)) {
                            
                            setQuoteLineIds.add(qL.Id);
                            setProgramOppIdsToDelete.add(qL.Program_Opportunity__c);
                    }
                }
             }
            
            //Check for mapQuoteLineItemWithUniqueIdentifier
            if(mapQuoteLineItemWithUniqueIdentifier.size() > 0) {
                
                //List to parse all the required values into the future method
                //Items in list : 1 = mapQuoteLineItemWithUniqueIdentifier, 2 = setParentOppIds, 3 = setProgramIds, 4 = setValidQuoteLineIds
                List<String> requiredCollections = new List<String>();
                
                //serialize variables
                requiredCollections.add(JSON.serializePretty(mapQuoteLineItemWithUniqueIdentifier));
                requiredCollections.add(JSON.serializePretty(setParentOppIds));
                requiredCollections.add(JSON.serializePretty(setProgramIds));
                requiredCollections.add(JSON.serializePretty(setValidQuoteLineIds));
                
                //Call future method
                validateParentOpportunities(requiredCollections);
                
            }
            
            //Call utility method to delete/update existing program opps
            CPQUtility.validateProgramOpportunities(setProgramOppIdsToDelete, setQuoteLineIds);
            
        } else {
            
            //Set to hold the Program Opportunities Id. This set will use to delete the quote line related program opportunities 
            Set<Id> setProgramOppIdsToDelete = new Set<Id>();
            
            //Delete Case
            for(SBQQ__QuoteLine__c qL : mapOldQuoteLines.values()) {
                
                //Check for Program Opportunity
                if(qL.Program_Opportunity__c != null)
                    setProgramOppIdsToDelete.add(qL.Program_Opportunity__c);    
            }
            
            //Call utility method to delete/update existing program opps
            CPQUtility.validateProgramOpportunities(setProgramOppIdsToDelete, new Set<Id>());
        }
    }
    
    /**
*   @description    :   If a Quote has a variance in Discounts between Years in a category then the field "Yearly Discount Variance" on the
*                       Quote should be marked as true
*                       If the quote line is edited or deleted and there are no associated Quote Lines which meet the criteria from number 1
*                       – then the field on the associated Quote should be marked as false
*
*   @args           :   List<SBQQ__QuoteLine__c>, Map<Id, SBQQ__QuoteLine__c>
*
*   @return         :   void
*
*   @revision Log   :   V_1.0 - Created - Subhash Garhwal - 08/10/2016 - Requested By Colin - CR-20160414-9762
*
**/
    public static void validateQuoteYearOneDiscount(List<SBQQ__QuoteLine__c> quoteLines, Map<Id, SBQQ__QuoteLine__c> mapOldQuoteLines) {
        
        //Map to hold the quotes
        Map<Id, SBQQ__Quote__c> mapQuotes = new Map<Id, SBQQ__Quote__c>();
        
        //Loop over quote lines
        for(SBQQ__QuoteLine__c qL : quoteLines != null ? quoteLines : mapOldQuoteLines.values()) {
            
            //Insert Case
            if(mapOldQuoteLines == null && qL.SBQQ__Quote__c != null)
                mapQuotes.put(qL.SBQQ__Quote__c, new SBQQ__Quote__c(Id = qL.SBQQ__Quote__c, Yearly_Discount_Variance__c = false));
            
            //Update case
            if(mapOldQuoteLines != null && quoteLines != null &&
               (qL.SBQQ__Quote__c != mapOldQuoteLines.get(qL.Id).SBQQ__Quote__c || qL.SBQQ__Discount__c != mapOldQuoteLines.get(qL.Id).SBQQ__Discount__c
                || qL.SBQQ__SubscriptionCategory__c  != mapOldQuoteLines.get(qL.Id).SBQQ__SubscriptionCategory__c
                || qL.SBQQ__Product__c  != mapOldQuoteLines.get(qL.Id).SBQQ__Product__c
                || qL.SBQQ__RequiredBy__c  != mapOldQuoteLines.get(qL.Id).SBQQ__RequiredBy__c
                || qL.SBQQ__AdditionalDiscountAmount__c != mapOldQuoteLines.get(qL.Id).SBQQ__AdditionalDiscountAmount__c)) {
                    
                    //Check for quote
                    if(qL.SBQQ__Quote__c != null)
                        mapQuotes.put(qL.SBQQ__Quote__c, new SBQQ__Quote__c(Id = qL.SBQQ__Quote__c, Yearly_Discount_Variance__c = false));
                    
                    //Check for old quote
                    if(mapOldQuoteLines.get(qL.Id).SBQQ__Quote__c != null)
                        mapQuotes.put(mapOldQuoteLines.get(qL.Id).SBQQ__Quote__c, new SBQQ__Quote__c(Id = mapOldQuoteLines.get(qL.Id).SBQQ__Quote__c, Yearly_Discount_Variance__c = false));                    
                }
            
            //Delete case
            if(quoteLines == null && qL.SBQQ__Quote__c != null)
                mapQuotes.put(qL.SBQQ__Quote__c, new SBQQ__Quote__c(Id = qL.SBQQ__Quote__c, Yearly_Discount_Variance__c = false));  
        }
        
        //Check for size
        if(mapQuotes.size() > 0) {
            
            //Map to hold the quote Lines with Quote
            Map<Id, Map<String, Map<String, Integer>>> mapQuoteWithQuoteLines = new Map<Id, Map<String, Map<String,Integer>>>();
        
            //Query through QuoteLines
            for(SBQQ__QuoteLine__c qL : [Select Id, SBQQ__Quote__c, SBQQ__Product__c, SBQQ__SubscriptionCategory__c , SBQQ__Discount__c, SBQQ__RequiredBy__c,
                                                SBQQ__RequiredBy__r.SBQQ__Product__c, SBQQ__AdditionalDiscountAmount__c ,Discount_Custom__c From SBQQ__QuoteLine__c Where SBQQ__Quote__c IN :mapQuotes.keySet()]) {
                
                //Check for required values
                if(qL.SBQQ__SubscriptionCategory__c != null && CPQConstants.QUOTE_LINE_PROGRAM_SUBSCRIPTIONCATEGORY.contains(qL.SBQQ__SubscriptionCategory__c)) {
                    
                    
                    //Create a uniqe Key (Product - SubscriptionCategory)
                    String uniqeIdentifier = qL.SBQQ__Product__c + '-' + qL.SBQQ__SubscriptionCategory__c;
                    
                    //String to hold discount
                    String discount;
                    
                    //Check to see the user is using USD or % dropdown option
                    if (qL.SBQQ__Discount__c == null && qL.SBQQ__AdditionalDiscountAmount__c != null){
                        discount = String.valueOf(qL.Discount_Custom__c);
                    }
                    //Check for discount
                    else if(qL.SBQQ__Discount__c == null || qL.SBQQ__Discount__c == 0 || qL.SBQQ__Discount__c == 0.00)
                        discount = 'null';
                    else
                        discount = String.valueOf(qL.SBQQ__Discount__c);
                    
                    //Check Quote Id in map
                    if(!mapQuoteWithQuoteLines.containsKey(qL.SBQQ__Quote__c))
                        mapQuoteWithQuoteLines.put(qL.SBQQ__Quote__c, new Map<String, Map<String, Integer>>());
                    
                    //Check unique key in map
                    if(!mapQuoteWithQuoteLines.get(qL.SBQQ__Quote__c).containsKey(uniqeIdentifier))
                        mapQuoteWithQuoteLines.get(qL.SBQQ__Quote__c).put(uniqeIdentifier, new Map<String, Integer>());
                    
                    //Check discount in map
                    if(!mapQuoteWithQuoteLines.get(qL.SBQQ__Quote__c).get(uniqeIdentifier).containsKey(discount))
                        mapQuoteWithQuoteLines.get(qL.SBQQ__Quote__c).get(uniqeIdentifier).put(discount, 0);
                    
                    
                    //Increase counter
                    Integer discountCounter = mapQuoteWithQuoteLines.get(qL.SBQQ__Quote__c).get(uniqeIdentifier).get(discount) + 1;
                    
                    //Populate counter in map
                    mapQuoteWithQuoteLines.get(qL.SBQQ__Quote__c).get(uniqeIdentifier).put(discount, discountCounter);
                }   
            }
            
            //Check for map size
            if(mapQuoteWithQuoteLines.size() > 0) {
                
                //Loop over quote Ids
                for(Id qId : mapQuoteWithQuoteLines.keySet()) {
                    
                    //Loop through unique identifiers
                    for(String uK : mapQuoteWithQuoteLines.get(qId).keySet()) {
                        
                        //Check for map size
                        if(mapQuoteWithQuoteLines.get(qId).get(uK).size() > 1 && mapQuotes.containsKey(qId))
                            mapQuotes.get(qId).Yearly_Discount_Variance__c = true;  
                            
                    }
                }
            }
            
            //Update
            update mapQuotes.values();
        }
    }
    
    /**
     *  @description    :   Method to validate the Program Opportunities for quote/Proposal lines. @Future annotation is used to avoid the SOQL limit.
     *
     *  @args           :   List<String>
     *
     *  @return         :   void
     *
     *  @revision Log   :   V_1.0 - 08/19/2016 - Created - Subhash Garhwal - CR-20160414-9762 - 
     *
     **/
    @future
    public static void validateParentOpportunities(List<String> requiredCollections) {
        
        //Check for list size
        if(requiredCollections.size() == 4) {
            
            //Map to hold the Unique key (Parent Opp Id + Program Id) as key and list of Quote Line Item as value
            Map<String, List<SBQQ__QuoteLine__c>> mapQuoteLineItemWithUniqueIdentifier = (Map<String, List<SBQQ__QuoteLine__c>>)JSON.deserialize(requiredCollections[0], Map<String, List<SBQQ__QuoteLine__c>>.class);
            
            //Set to hold the Parent Opportunities Id. This will use to get all the Children Opp (Program Opportunities)
            Set<Id> setParentOppIds = (Set<Id>)JSON.deserialize(requiredCollections[1], Set<Id>.class);
            
            //Set to hold the Program Ids. This will use to get all th Children Opp (Program Opportunities)
            Set<Id> setProgramIds = (Set<Id>)JSON.deserialize(requiredCollections[2], Set<Id>.class);
            
            //Set to hold the Quote Line Ids to avoid duplicate record for proposal value calculation
            Set<Id> setValidQuoteLineIds = (Set<Id>)JSON.deserialize(requiredCollections[3], Set<Id>.class);
            
            //Map to hold the Unique key (Parent Opp Id + Program Id) as key and Opportunity as value
            //This map will use to upsert Program Opportunities and update Parent Opportunity
            Map<String, Opportunity> mapProgramOpportunities = new Map<String, Opportunity>();
            
            //Map to hold the Opportunity Record Type with Program BL
            Map<String,Id> mapOppRTWithProgramBL = CPQUtility.mapOppRTWithProgramBL();
            
            //Map to hold the Default Probability according to Stage
            Map<String, Decimal> mapStageWithDefaultProbability = CPQUtility.oppDefaultProbabilityWithStage();
            
            //Map to hold the Program Opportunity Id with list of related Quote Lines
            Map<Id, List<SBQQ__QuoteLine__c>> mapProgramOppIdWithQuoteLines = new Map<Id, List<SBQQ__QuoteLine__c>>();
            
            //Query through Quote Lines
            for(SBQQ__QuoteLine__c qL : [Select Id,Program_Opportunity__c, Program_Opportunity__r.RecordTypeId, Program_Opportunity__r.RecordType.DeveloperName,
                                         Program_Opportunity__r.StageName, Is_a_Program__c, SBQQ__Quote__c, SBQQ__Quote__r.SBQQ__Opportunity2__c,
                                         SBQQ__Quote__r.SBQQ__Opportunity2__r.AccountId, SBQQ__Quote__r.SBQQ__Opportunity2__r.Closedate,
                                         SBQQ__Product__c, SBQQ__Product__r.Program__c, SBQQ__Product__r.Program__r.Business_line__c,
                                         Is_Primary_Quote__c,SBQQ__PackageTotal__c, SBQQ__Quote__r.SBQQ__Opportunity2__r.Name, SBQQ__NetPrice__c,
                                         SBQQ__EffectiveQuantity__c, SBQQ__Existing__c, SBQQ__Renewal__c,SBQQ__ComponentTotal__c,SBQQ__RequiredBy__c,
                                         SBQQ__RequiredBy__r.SBQQ__Product__c, SBQQ__RequiredBy__r.SBQQ__Product__r.Program__c, Program_or_Component_Formula__c,
                                         SBQQ__RequiredBy__r.Program_or_Component_Formula__c, SBQQ__SegmentIndex__c
                                         From SBQQ__QuoteLine__c Where Id NOT IN : setValidQuoteLineIds AND Program_Opportunity__r.Parent_Opportunity__c IN : setParentOppIds
                                         AND Program_Opportunity__r.Program__c IN : setProgramIds]) {
                                             
                                             //Check Opportunity Id in map
                                             if(!mapProgramOppIdWithQuoteLines.containsKey(qL.Program_Opportunity__c))
                                                 mapProgramOppIdWithQuoteLines.put(qL.Program_Opportunity__c, new List<SBQQ__QuoteLine__c>());
                                             
                                             //Add Quote line into map
                                             mapProgramOppIdWithQuoteLines.get(qL.Program_Opportunity__c).add(qL);                                      
                                         }
            
            //Query over the Program Opportunities
            for(Opportunity opp : [Select Id, Program__c, Parent_Opportunity__c, StageName, Program__r.Business_line__c, Range_High__c,
                                   Range_Low__c, RecordType.DeveloperName From Opportunity Where Parent_Opportunity__c IN : setParentOppIds
                                   AND Program__c IN : setProgramIds]) {
                                       
                                       //Create unique Identifier
                                       String uniqueIdentifier = opp.Parent_Opportunity__c + '-' + opp.Program__c;
                                       
                                       //Check unique Identifier in Quote Line map
                                       if(mapQuoteLineItemWithUniqueIdentifier.containsKey(uniqueIdentifier)) {
                                           
                                           //Set Opportunity Stage
                                           opp.StageName = CPQConstants.OPPORTUNITY_STAGE_ACTIVE_IN_SLOWTRACK;
                                           
                                           //List of QUote Lines
                                           List<SBQQ__QuoteLine__c> tempQuoteLines = mapQuoteLineItemWithUniqueIdentifier.get(uniqueIdentifier);
                                           
                                           //Check Opportunity Id in map
                                           if(mapProgramOppIdWithQuoteLines.containsKey(opp.Id))
                                               tempQuoteLines.addAll(mapProgramOppIdWithQuoteLines.get(opp.Id));
                                           
                                           //Call utility class method to calculate amount
                                           CPQUtility.calculateProgramOppAmount(opp, tempQuoteLines, false);
                                           
                                           //Populate map with Opportunity
                                           mapProgramOpportunities.put(uniqueIdentifier, opp);  
                                       } 
                                   }
            
            //Loop over the mapQuoteLineItemWithUniqueIdentifier key set to create new Program Opportunity
            for(String uK : mapQuoteLineItemWithUniqueIdentifier.keySet()) {
                
                //Check unique key in Program Opps map
                if(!mapProgramOpportunities.containsKey(uK)) {
                    
                    //Temp Instance Quote Line to populate Program Opps fields
                    SBQQ__QuoteLine__c tempQuoteLine = mapQuoteLineItemWithUniqueIdentifier.get(uK)[0];
                    
                    //Instance of Program Opportunity
                    Opportunity opp = new Opportunity();
                    
                    //Check for Top-level Quote Line
                    if((String.isNotBlank(tempQuoteLine.Program_or_Component_Formula__c) &&  CPQConstants.SET_QUOTE_LINE_PROGRAM_IDENTIFIERS.contains(tempQuoteLine.Program_or_Component_Formula__c))
                       || tempQuoteLine.SBQQ__RequiredBy__c == null) {
                           
                           //Set Program
                           opp.Program__c = tempQuoteLine.SBQQ__Product__r.Program__c;
                           
                           //Check for Record Type
                           if(mapOppRTWithProgramBL.containsKey(tempQuoteLine.Program_or_Component_Formula__c))
                               opp.RecordTypeId = mapOppRTWithProgramBL.get(tempQuoteLine.Program_or_Component_Formula__c);
                           else
                               opp.RecordTypeId = mapOppRTWithProgramBL.get(CPQConstants.PROGRAM_BUSINESS_LINE_PT);
                           
                       } else if(tempQuoteLine.SBQQ__RequiredBy__c != null && tempQuoteLine.SBQQ__RequiredBy__r.SBQQ__Product__c != null
                                 && tempQuoteLine.SBQQ__RequiredBy__r.SBQQ__Product__r.Program__c != null) {
                                     
                                     //Set Program      
                                     opp.Program__c = tempQuoteLine.SBQQ__RequiredBy__r.SBQQ__Product__r.Program__c;
                                     
                                     if(mapOppRTWithProgramBL.containsKey(tempQuoteLine.SBQQ__RequiredBy__r.Program_or_Component_Formula__c))
                                         opp.RecordTypeId = mapOppRTWithProgramBL.get(tempQuoteLine.SBQQ__RequiredBy__r.Program_or_Component_Formula__c);           
                                     
                                 }else
                                     opp.RecordTypeId = mapOppRTWithProgramBL.get(CPQConstants.PROGRAM_BUSINESS_LINE_PT);
                    
                    //Populate field values
                    opp.Name = 'Will auto Populate';
                    opp.AccountId = tempQuoteLine.SBQQ__Quote__r.SBQQ__Opportunity2__r.AccountId;
                    opp.Parent_Opportunity__c = tempQuoteLine.SBQQ__Quote__r.SBQQ__Opportunity2__c;
                    opp.StageName = CPQConstants.OPPORTUNITY_STAGE_ACTIVE_IN_SLOWTRACK;
                    opp.Probability = mapStageWithDefaultProbability.get(CPQConstants.OPPORTUNITY_STAGE_ACTIVE_IN_SLOWTRACK);
                    opp.Source_Stage__c = CPQConstants.OPPORTUNITY_SOURCE_STAGE_PIPELINE;
                    opp.Closedate =  tempQuoteLine.SBQQ__Quote__r.SBQQ__Opportunity2__r.Closedate;
                    opp.Admin_Override__c = true;
                    
                    //Call utility method to calculate amount
                    CPQUtility.calculateProgramOppAmount(opp, mapQuoteLineItemWithUniqueIdentifier.get(uK), false);
                    
                    //Add Opportunity in map
                    mapProgramOpportunities.put(uK, opp);
                }
            }
            
            //Check for Program Opportunity size
            if(mapProgramOpportunities.size() > 0) {
                
                //Upsert
                upsert mapProgramOpportunities.values();
                
                //List to update the Quote Lines
                List<SBQQ__QuoteLine__c> quoteLinesToUpdate = new List<SBQQ__QuoteLine__c>();
                
                //Loop over the Quote Line Map
                for(String uK : mapQuoteLineItemWithUniqueIdentifier.keySet()) {
                    
                    //Loop over the quote lines
                    for(SBQQ__QuoteLine__c qL : mapQuoteLineItemWithUniqueIdentifier.get(uK)) {
                        
                        //Check the unique key in map
                        if(mapProgramOpportunities.containsKey(uK) && qL.Program_Opportunity__c != mapProgramOpportunities.get(uK).Id) {
                            
                            //Set Program Opportunity
                            qL.Program_Opportunity__c = mapProgramOpportunities.get(uK).Id;
                            
                            //Add Quote Line in list
                            quoteLinesToUpdate.add(qL);
                        }       
                    }
                }
                
                //Check for list size
                if(quoteLinesToUpdate.size() > 0) {
                    
                    //By Pass all the trigger process
                    Util.BypassAllTriggers = true;
                    
                    //Update
                    update quoteLinesToUpdate;
                    
                    Util.BypassAllTriggers = false;
                }
            }
        }
    }
}