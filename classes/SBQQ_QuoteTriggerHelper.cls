/**
 *  Description     :  Helper class for SBQQ_QuoteTrigger trigger.
 *
 *  Created By      :  Subhash Garhwal
 *
 *  Created Date    :  06/23/2016
 *
 *  Revision Logs   :   V_1.0 - Created - Subhash Garhwal - CR-20160414-9762 
 *
 **/
public without sharing class SBQQ_QuoteTriggerHelper {
    
    //Flag to contol the Quote Line trigger execution
    public static Boolean executeUpdateContractLOAStageLogic = true;
    
    //Set to hold the Program Opportunity Ids
    //This set will populate in before delete trigger and being used in after delete trigger.
    //Reason : Need to validate Program Opportunities of Child Quote Line and on the deleation of the Master record, child record also deleted
    //but child trigger not executed.
    static Set<Id> setProgramOpportunitiesId = new Set<Id>();
    
    /**
     *  @description    :   This method is used to update the Contract LOA Opportunity stage to Pipeline
     *
     *  @args           :   List<SBQQ__Quote__c>
     *
     *  @return         :   void
     *
     *  @revision Log   :   V_1.0 - Created - Subhash Garhwal - CR-20160414-9762
     *
     **/
    public static void updateContractLOAStage(List<SBQQ__Quote__c> quotes) {
        
        //Set to hold the Contract LOA Id
        Set<Id> setContractLOAIds = new Set<Id>();
        
        //Loop over Quotes
        for(SBQQ__Quote__c quote : quotes) {
            
            //Check for Contract LOA Opp
            if(quote.SBQQ__Opportunity2__c != null)
                setContractLOAIds.add(quote.SBQQ__Opportunity2__c); 
        }
        
        //Check for set size
        if(setContractLOAIds.size() > 0) {
            
            //List to update the contract LOA opps
            List<Opportunity> opportunities = new List<Opportunity>();
            
            //Query through contract LOA Opps
            for(Opportunity opp : [Select Id, StageName From Opportunity Where Id IN : setContractLOAIds]) {
                
                //Check for stage
                if(opp.StageName != CPQConstants.OPPORTUNITY_STAGE_ON_PIPELINE) {
                    
                    //Change Opp stage to pipeline
                    opp.StageName = CPQConstants.OPPORTUNITY_STAGE_ON_PIPELINE;
                    
                    //Add Opportunity in list
                    opportunities.add(opp);
                }
            }
            
            //Check for list size
            if(opportunities.size() > 0)
                update opportunities;
        }
    }
     
        
    /**
     *  @description    :   This method is used to update Program Opportunities according to Primary Quoute. 
     *                      Details from Work Order (Process) : Set a Proposal as the Primary for the Opp.  Once saved, the Program(s) on the Proposal will
     *                                                          be updated to reflect the Proposal status.  Any Programs on a different Proposal that
     *                                                          changed from Primary to not-Primary are updated to reflect the Proposal status.
     *
     *  @args           :   List<SBQQ__Quote__c>, Map<Id, SBQQ__Quote__c>
     *
     *  @return         :   void
     *
     *  @revision Log   :   V_1.0 - Created - Subhash Garhwal - CR-20160414-9762
     *
     **/
    public static void syncProgramOpportunities(List<SBQQ__Quote__c> quotes, Map<Id, SBQQ__Quote__c> mapOldQuotes) {
        
        //Set to hold the Quote Ids
        Set<Id> setQuoteIds = new Set<Id>();
        
        //Loop over the new quotes
        for(SBQQ__Quote__c quote : quotes) {
            
            //Check SBQQ__Primary__c checkbox
            if(quote.SBQQ__Primary__c != mapOldQuotes.get(quote.Id).SBQQ__Primary__c)
                setQuoteIds.add(quote.Id);  
        }
        
        //Check for set size to proceed further
        if(setQuoteIds.size() > 0) {
            
            //Map to hold the Program Opportunity Id with list of quote lines
            Map<Id, List<SBQQ__QuoteLine__c>> mapParentOppIdWithQuoteLines = new Map<Id, List<SBQQ__QuoteLine__c>>();
            
            //Query through the Quote Lines
            for(SBQQ__QuoteLine__c qL : [Select Id,Program_Opportunity__c, Program_Opportunity__r.RecordTypeId, Program_Opportunity__r.RecordType.DeveloperName,
                                                Program_Opportunity__r.StageName, Is_a_Program__c, SBQQ__Quote__c, SBQQ__Quote__r.SBQQ__Opportunity2__c,
                                                SBQQ__Quote__r.SBQQ__Opportunity2__r.AccountId, SBQQ__Quote__r.SBQQ__Opportunity2__r.Closedate,
                                                SBQQ__Product__c, SBQQ__Product__r.Program__c, SBQQ__Product__r.Program__r.Business_line__c,
                                                Is_Primary_Quote__c,SBQQ__PackageTotal__c, SBQQ__Quote__r.SBQQ__Opportunity2__r.Name, SBQQ__NetPrice__c,
                                                SBQQ__EffectiveQuantity__c, SBQQ__Existing__c, SBQQ__Renewal__c,SBQQ__ComponentTotal__c,SBQQ__RequiredBy__c,
                                                SBQQ__RequiredBy__r.SBQQ__Product__c, SBQQ__RequiredBy__r.SBQQ__Product__r.Program__c, Program_or_Component_Formula__c,
                                                SBQQ__RequiredBy__r.Program_or_Component_Formula__c, SBQQ__SegmentIndex__c
                                                From SBQQ__QuoteLine__c
                                                Where SBQQ__Quote__c IN : setQuoteIds AND Program_Opportunity__c != null
                                                ORDER BY Program_or_Component_Formula__c ASC NULLS LAST]) {
                
                //Check Program Opportunity Id in map
                if(!mapParentOppIdWithQuoteLines.containsKey(qL.Program_Opportunity__c))
                    mapParentOppIdWithQuoteLines.put(qL.Program_Opportunity__c, new List<SBQQ__QuoteLine__c>());
                
                //Add Quote Line in list
                mapParentOppIdWithQuoteLines.get(qL.Program_Opportunity__c).add(qL);                                    
            }
            
            //Check for Program Opportunities
            if(mapParentOppIdWithQuoteLines.size() > 0) {
                
                //Map to update the Program Opportunities
                Map<Id,Opportunity> mapOpportunities = new Map<Id,Opportunity>();
                
                //Loop over Program Opportunity Ids
                for(Id proOppId : mapParentOppIdWithQuoteLines.keySet()) {
                    
                    //Variable to calculate the Amount for Program Opportunity
                    Decimal programOppAmount = 0;
                    Boolean isPrimaryProgram = false;
                    
                    //Instance of Opportunity
                    Opportunity opp = new Opportunity();
                    
                    //Set Id
                    opp.Id = proOppId;
                    
                    //Call utility method to perform the calculations
                    CPQUtility.calculateProgramOppAmount(opp, mapParentOppIdWithQuoteLines.get(proOppId), true);
                    
                    //Add Program Opportunity
                    mapOpportunities.put(proOppId, opp);
                }
                
                //Check for map size
                if(mapOpportunities.size() > 0)
                    upsert mapOpportunities.values();       
            }
        }       
    }
    
    /**
     *  @description    :   This method is used to populate setProgramOpportunitiesId set
     *
     *  @args           :   List<SBQQ__Quote__c>
     *
     *  @return         :   void
     *
     *  @revision Log   :   V_1.0 - Created - 08/11/2016 - Subhash Garhwal - CR-20160414-9762
     *
     **/
    public static void populateSetProgramOpportunitiesId(List<SBQQ__Quote__c> quotes) {
        
        //Initlize set
        setProgramOpportunitiesId = new Set<Id>();
        
        //Query through Quote Lines
        for(SBQQ__QuoteLine__c qL : [Select Id, Program_Opportunity__c From SBQQ__QuoteLine__c Where SBQQ__Quote__c IN : quotes AND Program_Opportunity__c != null])
            setProgramOpportunitiesId.add(qL.Program_Opportunity__c);       
    }
    
    /**
     *  @description    :   This method is used to populate validate Program Opportunities of related quote lines
     *
     *  @args           :   
     *
     *  @return         :   void
     *
     *  @revision Log   :   V_1.0 - Created - 08/11/2016 - Subhash Garhwal - CR-20160414-9762
     *
     **/
    public static void validateProgramOpportunities() {
        
        //Check for Program Opp set
        if(setProgramOpportunitiesId != null && setProgramOpportunitiesId.size() > 0)
            CPQUtility.validateProgramOpportunities(setProgramOpportunitiesId, new Set<Id>());
    }
}