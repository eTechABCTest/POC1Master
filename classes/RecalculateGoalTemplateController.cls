/**
 *  Purpose         :   Controller for RecalculateGoalTemplate VF page.
 *  
 *  Created By      :   Subhash Garhwal
 * 
 *  Created Date    :   11/04/2015 
 * 
 *  Revision Logs   :   V_1.0 - Created - CR-20150729-9114
 * 
 **/
public with sharing class RecalculateGoalTemplateController {
	
	//Properties
	public List<SelectOption> periods {get;set;}
	public String selectedPeriod {get;set;}
	public List<Standard_Goal__c> goalTemplates {get;set;}
	
	//Local variables
	Map<Id, Incentive_Defaults__c> mapIncentiveDefaults;
	
	//Construcotr
    public RecalculateGoalTemplateController(ApexPages.StandardSetController controller) {
        
        //Get Selected records
        goalTemplates = (List<Standard_Goal__c>) controller.getSelected();
        
        //inIt method
        inIt();
    }
    
    /**
     *	@description	:	Method to load all the defaults properties
     *
     *	@args			:	
     *
     *	@return			:	void
     *
     **/
	public void inIt() {
		
		//Initilize all the properties
		periods = new List<SelectOption>();
		mapIncentiveDefaults = new Map<Id, Incentive_Defaults__c>();
		
		//Check for selected Goal Templates
		if(goalTemplates.size() > 0) {
		
			//Add None Option
			periods.add(new SelectOption('', '--NONE--'));
			
			//Query through the Incentive Defaults
			for(Incentive_Defaults__c incentiveDef : [Select Id, Name, Start__c, End__c From Incentive_Defaults__c Where Description__c != null
															 AND Category__c = 'Periods' ORDER BY Description__c ASC, Start__c ASC]) {
				
				//Populate the Options
				periods.add(new SelectOption(incentiveDef.Id, incentiveDef.Name));
				
				//Populate map
				mapIncentiveDefaults.put(incentiveDef.Id, incentiveDef);
			}
		}
	}
	
	/**
	 *	@description	:	This method is used for save
	 *
	 *	@args			:	
	 *
	 *	@return			:	Pagereference
	 *
	 **/
	public Pagereference doSave() {
		
		//Save Point
		SavePoint sP = Database.setSavepoint();
		
		try {
			
			//Check for selected Period
			if(String.isNotBlank(selectedPeriod) && mapIncentiveDefaults.containsKey(selectedPeriod)) {
			
				//Map to hold the Goal Template Details
				Map<Id, Standard_Goal_Detail__c> mapGoalTempDetails = new Map<Id, Standard_Goal_Detail__c>();
				
				//Map to hold the Baselines
				Map<Id, Standard_Goal_Detail__c> mapBaselines = new Map<Id, Standard_Goal_Detail__c>();
				
				//Map to hold the Parent Goal Template Details
				Map<Id, Standard_Goal_Detail__c> mapParentGTDs = new Map<Id, Standard_Goal_Detail__c>();
				
				//Temp list to hold the GTDs
				List<Standard_Goal_Detail__c> tempGoalTempDetails = new List<Standard_Goal_Detail__c>();
				
				//Query through the Goal Template Details
				for(Standard_Goal_Detail__c gTD : [Select Id, Name, Baseline__c, Baseline_Percentage__c, GT_Basline__c, Amount__c, Count__c, Percent__c,
														  Discount__c, Standard_Goal__c, Target_Type__c, Period__c, Period_Start__c,
														  Period_End__c,Standard_Goal__r.Amount__c,Standard_Goal__r.Counter__c, Standard_Goal__r.Percent__c,
														  Summary__c, Baseline__r.Amount__c, Baseline__r.Count__c, Baseline__r.Percent__c, Baseline__r.Summary__c,
														  Parent__c From Standard_Goal_Detail__c Where Standard_Goal__c IN : goalTemplates]) {
					
					//Check for Parent
					if(gTD.Parent__c == null && gTD.Summary__c)
						mapParentGTDs.put(gTD.Id, gTD);
					
					//Check for Target Type
					if(gTD.Target_Type__c == ISSPConstants.STANDARD_GOAL_DETAIL_TARGET_TYPE_PACED)
						mapGoalTempDetails.put(gTD.Id, gTD);
					
					else if(gTD.Target_Type__c == ISSPConstants.STANDARD_GOAL_DETAIL_TARGET_TYPE_EXPLICIT) {
						
						//Variables to hold the start and end date
						Date startDate = mapIncentiveDefaults.get(selectedPeriod).Start__c;
						Date endDate = mapIncentiveDefaults.get(selectedPeriod).End__c;
						
						//Check for start date
						if(gTD.Period_Start__c != null && gTD.Period_Start__c >= startDate)
							mapGoalTempDetails.put(gTD.Id, gTD);		
					}
				}
				
				//Check for GTD map size
				if(mapGoalTempDetails.size() > 0) {
				
					//Loop through the Goal Template Details
					for(Standard_Goal_Detail__c gTD : mapGoalTempDetails.values()) {
						
						//Check for Baseline
						if((gTD.Baseline__c == null || !mapGoalTempDetails.containsKey(gTD.Baseline__c) || gTD.GT_Basline__c == ISSPConstants.TEMPLATE_BASELINE
							|| gTD.Baseline__r.Summary__c == true) && gTD.Summary__c == false) {
							
							//Check for baseline
							if(gTD.GT_Basline__c == ISSPConstants.TEMPLATE_BASELINE && gTD.Baseline__c == null) {
								
								//Apply the Values
					            gTD.Amount__c = gTD.Baseline_Percentage__c != null && gTD.Baseline_Percentage__c > 0 && gTD.Standard_Goal__r.Amount__c != null
					            							? (gTD.Standard_Goal__r.Amount__c * gTD.Baseline_Percentage__c/100).setScale(0) : gTD.Standard_Goal__r.Amount__c;
					            
					            gTD.Count__c = gTD.Baseline_Percentage__c != null && gTD.Baseline_Percentage__c > 0 && gTD.Standard_Goal__r.Counter__c != null
					            							? (gTD.Standard_Goal__r.Counter__c * gTD.Baseline_Percentage__c/100).setScale(0) : gTD.Standard_Goal__r.Counter__c;
					            
					            gTD.Percent__c = gTD.Baseline_Percentage__c != null && gTD.Baseline_Percentage__c > 0 && gTD.Standard_Goal__r.Percent__c != null
					            							? (gTD.Standard_Goal__r.Percent__c * gTD.Baseline_Percentage__c/100).setScale(0) : gTD.Standard_Goal__r.Percent__c;
			            	
			            		//Check for Target Type
			            		if(gTD.Target_Type__c == ISSPConstants.STANDARD_GOAL_DETAIL_TARGET_TYPE_EXPLICIT)
			            			applyDiscount(gTD);	
			            			
			            	} else if(gTD.Baseline__c != null && (!mapGoalTempDetails.containsKey(gTD.Baseline__c) || gTD.Baseline__r.Summary__c == true))	{
			            		
			            		//Apply the Values
					            gTD.Amount__c = gTD.Baseline_Percentage__c != null && gTD.Baseline_Percentage__c > 0 && gTD.Baseline__r.Amount__c != null
					            							? (gTD.Baseline__r.Amount__c * gTD.Baseline_Percentage__c/100).setScale(0) : gTD.Baseline__r.Amount__c;
					            
					            gTD.Count__c = gTD.Baseline_Percentage__c != null && gTD.Baseline_Percentage__c > 0 && gTD.Baseline__r.Count__c != null
					            							? (gTD.Baseline__r.Count__c * gTD.Baseline_Percentage__c/100).setScale(0) : gTD.Baseline__r.Count__c;
					            
					            gTD.Percent__c = gTD.Baseline_Percentage__c != null && gTD.Baseline_Percentage__c > 0 && gTD.Baseline__r.Percent__c != null
					            							? (gTD.Baseline__r.Percent__c * gTD.Baseline_Percentage__c/100).setScale(0) : gTD.Baseline__r.Percent__c;
								
								//Check for Target Type
			            		if(gTD.Target_Type__c == ISSPConstants.STANDARD_GOAL_DETAIL_TARGET_TYPE_EXPLICIT)
			            			applyDiscount(gTD);
			            	}
			            	
			            	//Add GTD in map
			            	mapBaselines.put(gTD.Id, gTD);
			            } else if(gTD.Summary__c == false)
							tempGoalTempDetails.add(gTD);		
					}
					
					//Check for temp list size
					if(tempGoalTempDetails.size() > 0)
						doCalculations(tempGoalTempDetails, mapBaselines);
					
					//Update GTDs
					update mapGoalTempDetails.values();
					
					System.debug('######### : ' +mapParentGTDs);
					
					//Aggregate query on the Goal Template Details to get the sum on the Parent GTD
					for(AggregateResult aR : [Select Parent__c parent, SUM(Amount__c) amount, SUM(Count__c) counter, SUM(Percent__c) percent From
													Standard_Goal_Detail__c Where Standard_Goal__c IN : goalTemplates AND Parent__c != null
													GROUP BY Parent__c]) {
						
						//Parent GTD Id
	            		Id pGTDId = Id.valueOf(String.valueOf(aR.get('parent')));
	            		
	            		//Check Parent Id in map
	            		if(mapParentGTDs.containsKey(pGTDId)) {
	            			
	            			//Populate the map
	            			mapParentGTDs.get(pGTDId).Amount__c = Integer.valueOf(aR.get('amount'));
	            			mapParentGTDs.get(pGTDId).Count__c = Integer.valueOf(aR.get('counter'));
	            			mapParentGTDs.get(pGTDId).Percent__c = (Decimal) aR.get('percent');
	            			
		            		//Apply discount
							applyDiscount(mapParentGTDs.get(pGTDId));	
	            		}
	            	}
					System.debug('######### : ' +mapParentGTDs);
					
					//Check for Parent Map size
					if(mapParentGTDs.size() > 0)
						update mapParentGTDs.values();
				}
			}
			
			//Return to list view
			return new Pagereference('/' + Standard_Goal__c.sObjectType.getDescribe().getKeyPrefix());
		
		} catch(Exception e) {
            
            //Roll Back changes
            Database.rollback(sp);
            
            //Add Error on page
            ApexPages.addMessages(e);
        }
        
        //return
        return null;
	}
	
	/**
	 *	@description	:	This method is used to calculate the values for GTD
	 *
	 *	@args			:	List<Standard_Goal_Detail__c>, Map<Id, Standard_Goal_Detail__c>
	 *
	 *	@return			:	void
	 *
	 **/
	public void doCalculations(List<Standard_Goal_Detail__c> tempGoalTempDetails, Map<Id, Standard_Goal_Detail__c> mapBaselines) {
		
		//List to hold the GTDs
		List<Standard_Goal_Detail__c> tempGTDetails = new List<Standard_Goal_Detail__c>();
		
		//Loop through the standard goal details
		for(Standard_Goal_Detail__c gTD : tempGoalTempDetails) {
			
			//Check baseline Id in map
			if(mapBaselines.containsKey(gTD.Baseline__c)) {
				
				//GTD instance to hold the Baseline
				Standard_Goal_Detail__c baseline = mapBaselines.get(gTD.Baseline__c);
				
				//Apply the Values
	            gTD.Amount__c = gTD.Baseline_Percentage__c != null && gTD.Baseline_Percentage__c > 0 && baseline.Amount__c != null
	            							? (baseline.Amount__c * gTD.Baseline_Percentage__c/100).setScale(0) : baseline.Amount__c;
	            
	            gTD.Count__c = gTD.Baseline_Percentage__c != null && gTD.Baseline_Percentage__c > 0 && baseline.Count__c != null
	            							? (baseline.Count__c * gTD.Baseline_Percentage__c/100).setScale(0) : baseline.Count__c;
	            
	            gTD.Percent__c = gTD.Baseline_Percentage__c != null && gTD.Baseline_Percentage__c > 0 && baseline.Percent__c != null
			            							? (baseline.Percent__c * gTD.Baseline_Percentage__c/100).setScale(0) : baseline.Percent__c;
				
				//Check for Target Type
        		if(gTD.Target_Type__c == ISSPConstants.STANDARD_GOAL_DETAIL_TARGET_TYPE_EXPLICIT)
        			applyDiscount(gTD);
				
				//Add GTD in map
            	mapBaselines.put(gTD.Id, gTD);
            
            } else 
				tempGTDetails.add(gTD);
		}
		
		//Check for list size
		if(tempGTDetails.size() > 0)
			doCalculations(tempGTDetails, mapBaselines);	
	}
	
	/**
	 *	@description	:	This method is used to apply the discount
	 *
	 *	@args			:	Standard_Goal_Detail__c
	 *
	 *	@return			:	void
	 *
	 **/
	private void applyDiscount(Standard_Goal_Detail__c stdGD) {
		
		//Apply discount
        //Check for Discount field
        if(stdGD.Discount__c != null && stdGD.Discount__c > 0) {
            
            //Apply discount
            if(stdGD.Amount__c != null && stdGD.Amount__c > 0)
                stdGD.Amount__c -= (stdGD.Amount__c * (stdGD.Discount__c/100)).setScale(0);  
            else if(stdGD.Count__c != null && stdGD.Count__c > 0)
                stdGD.Count__c -= (stdGD.Count__c * (stdGD.Discount__c/100)).setScale(0);
            else if(stdGD.Percent__c != null && stdGD.Percent__c > 0)
                stdGD.Percent__c -= (stdGD.Percent__c * (stdGD.Percent__c/100)).setScale(2); 
        }
	}
}