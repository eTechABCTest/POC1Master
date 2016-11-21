/**
 *  Description     :  This class to hold all the utility properties for CPQ project
 *
 *  Created By      :  Subhash Garhwal
 *
 *  Created Date    :  06/22/2016
 *
 *  Revision Logs   :   V_1.0 - Created - Subhash Garhwal - CR-20160414-9762 
 *
 **/
public with sharing class CPQUtility {
    
    /**
     *  @description    :   This method is used to Opportunity Record Type Id with Developer Name
     *
     *  @args           :   
     *
     *  @return         :   Map<String, Id>
     *
     **/
    public static Map<String, Id> mapOpportutnityRecordType() {
        
        //Map to hold the Opportunity Record Type developer name with Id
        Map<String, Id> mapOppRTDNWithRTId = new Map<String, Id>();
        
        //Query through record type
        for(RecordType rT : [Select Id, DeveloperName From RecordType Where SobjectType = 'Opportunity']) {
            
            //Populate map
            mapOppRTDNWithRTId.put(rT.DeveloperName, rT.Id);
        }
        
        //Return
        return mapOppRTDNWithRTId;
    }
    
    /**
     *  @description    :   This method is used to get appropriate Record type for Program Opportunity according to Program Business Type
     *
     *  @args           :   
     *
     *  @return         :   Map<String, Id>
     *
     **/
    public static Map<String,Id> mapOppRTWithProgramBL() {
        
        //Map
        Map<String, Id> mapOppRTWithPBL = new Map<String, Id>();
        
        //Map to hold the Opportunity RT Developer Name with Record Type Id
        Map<String, Id> mapOppRTDNWithRTId = mapOpportutnityRecordType();
        
        //Populate map
        mapOppRTWithPBL.put(CPQConstants.program_Business_Line_RI, mapOppRTDNWithRTId.get(CPQConstants.OPPORTUNITY_RECORD_TYPE_DEVELOPERNAME_PROGRAM_RI_MARKETING));
        mapOppRTWithPBL.put(CPQConstants.PROGRAM_BUSINESS_LINE_PT, mapOppRTDNWithRTId.get(CPQConstants.OPPORTUNITY_RECORD_TYPE_DEVELOPERNAME_PROGRAM_PT_MARKETING));
        mapOppRTWithPBL.put(CPQConstants.QUOTE_LINE_PROGRAM_IDENTIFIER_CONSULTING, mapOppRTDNWithRTId.get(CPQConstants.OPPORTUNITY_RECORD_TYPE_DEVELOPERNAME_PROGRAM_CONSULTING_MANAGEMENT));
        
        //Return
        return mapOppRTWithPBL;
    }
    
    /**
     *  @description    :   This method is used to Populate Opportunity fields
     *
     *  @args           :   Opportunity, SBQQ__QuoteLine__c
     *
     *  @return         :   void
     *
     **/
    public static void populateProgramOppFields(Opportunity opp, SBQQ__QuoteLine__c tempQuoteLine) {
        
    }
    
    /**
     *  @description    :   This method is used to return all the opportunity default Probability values with corresponding stage
     *
     *  @args           :   
     *
     *  @return         :   Map<String, Decimal>
     *
     **/
    public static Map<String,Decimal> oppDefaultProbabilityWithStage() {
        
        //Map
        Map<String,Decimal> mapOppProbabilityWithStage = new Map<String,Decimal>();
        
        //Query
        for(OpportunityStage oS : [Select DefaultProbability, MasterLabel From OpportunityStage])
            mapOppProbabilityWithStage.put(oS.MasterLabel, oS.DefaultProbability);
        
        //Return
        return mapOppProbabilityWithStage;
    }
    
    /**
     *  @description    :   This method is used to calculate the amount for Program Opportunity
     *
     *  @args           :   Opportunity, List<SBQQ__QuoteLine__c>, Boolean
     *
     *  @return         :   void
     *
     *  @revision Log   :   V_1.0 - Created - Subhash Garhwal - CR-20160414-9762
     *						V_1.1 - Modified - 08/11/2016 - Subhash Garhwal - Added new logic for Proposal value (Amount) calculation for Program Opp.
     *								Original Request:
     *								While open, the NBB Program Opp will pull the Proposal Value from only the 1st year annual, travel, and
     *								implementation fees for the program.
	 *								a. If there is a primary proposal, the Program Opp will use figures from there.
	 *								b. If there is no primary, the Program Opp will use the 1st year totals from the proposal with the lowest total amountIdeally would use the 1st year totals from the proposal with the lowest 1st year total
	 *								c. This also applies if the Program Opp is Closed Lost 
     *
     **/
    public static void calculateProgramOppAmount(Opportunity opp, List<SBQQ__QuoteLine__c> quoteLines, Boolean isPrimary) {
        
        //Primary Program Flag
        Boolean isPrimaryProgram = false;
		
		//Set default Range
		opp.Range_High__c = 0;
		opp.Range_Low__c = 0;
		
		//Added - Subhash Garhwal - 08/11/2016
		Map<Id, Decimal> mapProgramOppsProposalValueCal = new Map<Id, Decimal>();
		
        //Loop over the Quote Lines
        for(SBQQ__QuoteLine__c qL : quoteLines) {
            
            //Check for Segment Index
			if(qL.SBQQ__SegmentIndex__c != null && qL.SBQQ__SegmentIndex__c == 1) {
            	
            	//Set Range High
	            if(qL.SBQQ__PackageTotal__c != null && opp.Range_High__c < qL.SBQQ__PackageTotal__c)
	            	opp.Range_High__c = qL.SBQQ__PackageTotal__c;
	            
	            //Set Range Low
	            if(qL.SBQQ__PackageTotal__c == null || opp.Range_Low__c > qL.SBQQ__PackageTotal__c)
	            	opp.Range_Low__c = qL.SBQQ__PackageTotal__c == null ? 0 : qL.SBQQ__PackageTotal__c;
	        }
            
            //Check for Primary flag and set Primary flag
            if(qL.Is_Primary_Quote__c)
            	opp.Program_Proposal_Status__c = CPQConstants.PROGRAM_PROPOSAL_STATUS_PRIMARY_PROPOSAL;
			else if(!isPrimaryProgram)
            	opp.Program_Proposal_Status__c = CPQConstants.OPPORTUNITY_STAGE_ALTERNATE_PROPOSAL;
            
            //Check for Primary flag
            if(qL.Is_Primary_Quote__c) {
            	
            	//Check for flag
            	if(!isPrimaryProgram)
            		mapProgramOppsProposalValueCal = new Map<Id, Decimal>();
            		
            	//Check for Segment Index
            	if(qL.SBQQ__SegmentIndex__c != null && qL.SBQQ__SegmentIndex__c == 1) {
            		
            		//Check for Proposal value in map
            		if(!mapProgramOppsProposalValueCal.containsKey(qL.SBQQ__Quote__c))
            			mapProgramOppsProposalValueCal.put(qL.SBQQ__Quote__c, 0);
            		
            		//Add Package total
            		if(qL.SBQQ__PackageTotal__c != null)
            			mapProgramOppsProposalValueCal.put(qL.SBQQ__Quote__c, mapProgramOppsProposalValueCal.get(qL.SBQQ__Quote__c) + qL.SBQQ__PackageTotal__c);	
            	}
            		
            	//Set variable to true to skip avarage calculation
                isPrimaryProgram = true;
            
            } else if(!isPrimaryProgram && qL.SBQQ__SegmentIndex__c != null && qL.SBQQ__SegmentIndex__c == 1) {
            	
            	//Check for Proposal value in map
        		if(!mapProgramOppsProposalValueCal.containsKey(qL.SBQQ__Quote__c))
        			mapProgramOppsProposalValueCal.put(qL.SBQQ__Quote__c, 0);
        		
        		//Add Package total
        		if(qL.SBQQ__PackageTotal__c != null)
        			mapProgramOppsProposalValueCal.put(qL.SBQQ__Quote__c, mapProgramOppsProposalValueCal.get(qL.SBQQ__Quote__c) + qL.SBQQ__PackageTotal__c);
            }
        }
        
        //Variable to hold the Proposal value
        Decimal proposalValue;
        
        //Loop over the map and get the min total
        for(Id qteId : mapProgramOppsProposalValueCal.keySet()) {
        	
        	//Check for proposalValue
        	if(proposalValue == null || proposalValue > mapProgramOppsProposalValueCal.get(qteId))
        		proposalValue = mapProgramOppsProposalValueCal.get(qteId);
        }
        
        //Update Program Opp Proposal amount
        opp.Amount =  proposalValue;
    }
    
    /**
     *  @description    :   This method is used to calculate the amount for Program Opportunity and delete Program Opportunities
     *
     *  @args           :   Set<Id>, Set<Id>
     *
     *  @return         :   void
     *
     *  @revision Log   :   V_1.0 - Created - Subhash Garhwal - CR-20160414-9762
     *
     **/
    @future public static void validateProgramOpportunities(Set<Id> setProgramOppIds, Set<Id> setQuoteLineIds) {
        
        //Check for set size
        if(setProgramOppIds.size() > 0) {
            
            //Set to delete the Program Opportunities
            Set<Id> setProgramOppIdsWithNoPL = setProgramOppIds;
            
            //Map to hold the Program Opportunity Id with all the related Quote Lines
            Map<Id, List<SBQQ__QuoteLine__c>> mapProgramOppIdWithQuoteLines = new Map<Id, List<SBQQ__QuoteLine__c>>();
            
            //Map to hold the Opportunity Record Typw with Program BL
            Map<String,Id> mapOppRTWithProgramBL = CPQUtility.mapOppRTWithProgramBL();
                
            //Qyery through the Quote Lines
            for(SBQQ__QuoteLine__c qL : [Select Id,Program_Opportunity__c, Program_Opportunity__r.RecordTypeId, Program_Opportunity__r.RecordType.DeveloperName,
												Program_Opportunity__r.StageName, Is_a_Program__c, SBQQ__Quote__c, SBQQ__Quote__r.SBQQ__Opportunity2__c,
												SBQQ__Quote__r.SBQQ__Opportunity2__r.AccountId, SBQQ__Quote__r.SBQQ__Opportunity2__r.Closedate,
												SBQQ__Product__c, SBQQ__Product__r.Program__c, SBQQ__Product__r.Program__r.Business_line__c,
												Is_Primary_Quote__c,SBQQ__PackageTotal__c, SBQQ__Quote__r.SBQQ__Opportunity2__r.Name, SBQQ__NetPrice__c,
												SBQQ__EffectiveQuantity__c, SBQQ__Existing__c, SBQQ__Renewal__c,SBQQ__ComponentTotal__c,SBQQ__RequiredBy__c,
												SBQQ__RequiredBy__r.SBQQ__Product__c, SBQQ__RequiredBy__r.SBQQ__Product__r.Program__c, Program_or_Component_Formula__c,
												SBQQ__RequiredBy__r.Program_or_Component_Formula__c, SBQQ__SegmentIndex__c
												From SBQQ__QuoteLine__c Where SBQQ__Quote__r.SBQQ__Opportunity2__c != null
                                                AND Program_Opportunity__c IN : setProgramOppIds AND Id NOT IN : setQuoteLineIds
                                                ORDER BY Is_a_Program__c ASC NULLS LAST]) {
                    
				//Check Program Opportunity Id in map
                if(!mapProgramOppIdWithQuoteLines.containsKey(qL.Program_Opportunity__c))
                    mapProgramOppIdWithQuoteLines.put(qL.Program_Opportunity__c, new List<SBQQ__QuoteLine__c>());
                
                //Add Quote Line in map
                mapProgramOppIdWithQuoteLines.get(qL.Program_Opportunity__c).add(qL);
            }
            
            //List to Opportunity (Program Opportunities) to update
			List<Opportunity> programOpportunities = new List<Opportunity>();
                
            //Check for map size
            if(mapProgramOppIdWithQuoteLines.size() > 0) {
                
                //Remove Program Opportunity Ids from set to prevent them to delete
                setProgramOppIdsWithNoPL.removeAll(mapProgramOppIdWithQuoteLines.keySet());
                
                //Loop over the Program Opportunity Ids
                for(Id pOId : mapProgramOppIdWithQuoteLines.keySet()) {
                    
                    //Instance of Opportunity
                    Opportunity opp = new Opportunity();
                    opp.Id = pOId;
                    
                    //Temp instance of Quote Line Item
                    SBQQ__QuoteLine__c tempQuoteLine = mapProgramOppIdWithQuoteLines.get(pOId)[0];
                    
                    //Check for Top-level Program
                    if(String.isNotBlank(tempQuoteLine.Program_or_Component_Formula__c) && CPQConstants.SET_QUOTE_LINE_PROGRAM_IDENTIFIERS.contains(tempQuoteLine.Program_or_Component_Formula__c) && mapOppRTWithProgramBL.containsKey(tempQuoteLine.Program_or_Component_Formula__c))
                    	
                    	opp.RecordTypeId = mapOppRTWithProgramBL.get(tempQuoteLine.Program_or_Component_Formula__c);
					else if(tempQuoteLine.SBQQ__RequiredBy__c != null && tempQuoteLine.SBQQ__RequiredBy__r.SBQQ__Product__c != null
							&& tempQuoteLine.SBQQ__RequiredBy__r.SBQQ__Product__r.Program__c != null &&
							mapOppRTWithProgramBL.containsKey(tempQuoteLine.SBQQ__RequiredBy__r.Program_or_Component_Formula__c))
						opp.RecordTypeId = mapOppRTWithProgramBL.get(tempQuoteLine.SBQQ__RequiredBy__r.Program_or_Component_Formula__c);
                    
                    //Call utility method to update Program Opportunity amount
                    calculateProgramOppAmount(opp, mapProgramOppIdWithQuoteLines.get(pOId), false);
                    
                    //Add Opportunity in list
                    programOpportunities.add(opp);
                }
            }
            
        	//Check for set size
            if(setProgramOppIdsWithNoPL.size() > 0) {
            	
            	//Loop Over Opportunity Ids
            	for(Id oppId : setProgramOppIdsWithNoPL) {
            		
            		//Instance of Opportunity
            		programOpportunities.add(new Opportunity(Id = oppId, Amount = 0, Program_Proposal_Status__c = CPQConstants.PROGRAM_PROPOSAL_STATUS_INACTIVE));
            	}
            }
            
            //Update Oppportunity
            if(programOpportunities.size() > 0)
                update programOpportunities;
        }
    }
    
    /**
     *  @description    :   This method is used to build the SOQL query string.
     *
     *  @args           :   Map<String, Schema.SObjectType>, String, Stirng, String
     *
     *  @return         :   String
     *
     *	@revision Log	:	V_1.0 - Created - Subhash Garhwal - CR-20160414-9762
     **/
    public static String buildSOQL(Map<String, Schema.SObjectType> globalDescribe, String objName, String additionRelationshipFields, String whereClause) {
        
        //SOQL query
        String SOQL = 'Select ';
        
        //Get the field of the object'
        for(String field : globalDescribe.get(objName).getDescribe().fields.getMap().keySet())
            SOQL += field + ',';
        
        //Check for addition fields
        if(String.isNotBlank(additionRelationshipFields))
        	SOQL += additionRelationshipFields;
        
        //Remove extra elements and add object
        SOQL = SOQL.removeEnd(',') + ' From ' + objName;
        
        //Check for Where Clause
        if(String.isNotBlank(whereClause))
        	SOQL += whereClause;
        
        //Return 
        return SOQL;
    }
}