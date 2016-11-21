/**
 *  Description     :   Helper class for Relationship Interaction object
 * 
 *  Created By      :   Abhinav Sharma    
 * 
 *  Created Date    :   10/19/2015
 * 
 *  Revision Logs   :   V_1.0 - Created - CR-20150930-9283 - 10/19/2015 - Added new method 
 * 						(populateNameOnReleationshipInteractions,processAccountFormalName,processStartDateTime,processInteractionType)
 **/ 
public without sharing class RelationshipInteractionTriggerHelper {
	
	public final static Integer INSTITUTION_NAME_MAX_ALLOWED_LENGTH = 40;
	public final static String BACKSLASH_VAR = '/';
	public final static String DASH_VAR = '-';
    public final static String KEYWORD_NULL = 'null';
    public final static Integer NAME_FIELD_MAX_CHAR_LIMIT = 80;
    
	
    //Added By - Abhinav Sharma - CR-20150930-9283 - 10/19/2015
    /**
     *  @description    :   Method to populate name field with appropriate value on "Relationship Interaction" records. 
     * 
     *  @args           :   List of relationship interaction, Map of relationship interaction
     * 
     *  @return         :   void
     * 
    **/ 
    public static void populateNameOnReleationshipInteractions(List<Relationship_Interaction__c> newRIs, Map<Id,Relationship_Interaction__c> oldMapRIs) {
    
    	/*Logic to populate name field value on "Relationship Interaction" records*/
    	//Map of relationship interaction records
    	Set<Id> setInstitutionIds = new Set<Id>();
    	
    	//Set top hold Start Dates
    	Set<Date> startDates = new Set<Date>();
    	
    	//Set to hold Interaction Type
    	Set<String> interactionTypes = new Set<String>();
    
    	//Loop through relationship interaction records
    	for(Relationship_Interaction__c rI : newRIs != null ? newRIs : oldMapRIs.values()) {
    		
    		//Insert case
    		if(oldMapRIs == null) {
    			
    			//Populate Set
    			if(rI.Institution__c != null)
    				setInstitutionIds.add(rI.Institution__c);
				if(rI.Start_Date_Time__c != null)
    				startDates.add(rI.Start_Date_Time__c.date());
				if(rI.Interaction_Type__c != null)
    				interactionTypes.add(rI.Interaction_Type__c);
			}
    			
    			
    		//Update case
    		if(oldMapRIs != null && newRIs != null
    			&& (rI.Institution__c != oldMapRIs.get(rI.Id).Institution__c
    				|| rI.Start_Date_Time__c != oldMapRIs.get(rI.Id).Start_Date_Time__c
    				|| rI.Interaction_Type__c != oldMapRIs.get(rI.Id).Interaction_Type__c)
              ) {
				//Populate Set
    			if(rI.Institution__c != null)
    				setInstitutionIds.add(rI.Institution__c);
				if(rI.Start_Date_Time__c != null)
    				startDates.add(rI.Start_Date_Time__c.date());
				if(rI.Interaction_Type__c != null)
    				interactionTypes.add(rI.Interaction_Type__c);
			
    			//Populate Set
    			if(oldMapRIs.get(rI.Id).Institution__c != null)
    				setInstitutionIds.add(oldMapRIs.get(rI.Id).Institution__c);
				if(oldMapRIs.get(rI.Id).Start_Date_Time__c != null)
    				startDates.add(oldMapRIs.get(rI.Id).Start_Date_Time__c.date());
				if(oldMapRIs.get(rI.Id).Interaction_Type__c != null)
    				interactionTypes.add(oldMapRIs.get(rI.Id).Interaction_Type__c);
            }	
            
            //Delete case
            if(oldMapRIs != null && newRIs == null) {
        		
        		//Populate Set
    			if(oldMapRIs.get(rI.Id).Institution__c != null)
    				setInstitutionIds.add(oldMapRIs.get(rI.Id).Institution__c);
				if(oldMapRIs.get(rI.Id).Start_Date_Time__c != null)
    				startDates.add(oldMapRIs.get(rI.Id).Start_Date_Time__c.date());
				if(oldMapRIs.get(rI.Id).Interaction_Type__c != null)
    				interactionTypes.add(oldMapRIs.get(rI.Id).Interaction_Type__c);    	
            }
        }
    	
    	//Checking map for size value
    	if(setInstitutionIds.size() > 0) {
    		
    		//Map of accounts
    		Map<Id, Account> mapAccounts = new Map<Id, Account>([SELECT Id, Account_Formal_Name__c FROM Account
    																WHERE ID IN : setInstitutionIds]);
    																
			//Map to hold the "Account Formal name (first 40 characters)-Start/Date Time-Interaction Type-Institution Id" as key 
			//and correspodning RI records as value
			Map<String, List<Relationship_Interaction__c>> mapExistingRINameKeyWithListOfRIs = new Map<String, List<Relationship_Interaction__c>>();
            List<Relationship_Interaction__c> rInteractions = new List<Relationship_Interaction__c>();
			
			//Loop through rI records and populating map accordingly
			for(Relationship_Interaction__c reIn : [SELECT Id, Name, Institution__c, Interaction_Type__c, Start_Date_Time__c 
													FROM Relationship_Interaction__c
													WHERE Institution__c != null AND Institution__c IN : setInstitutionIds 
													AND DAY_ONLY(convertTimezone(Start_Date_Time__c)) IN: startDates
													AND Interaction_Type__c IN: interactionTypes
													ORDER BY CreatedDate ASC]) {
				//temporary varibles
				String rInteractionNameKey = '';
				rInteractionNameKey = processAccountFormalName(reIn, mapAccounts, reIn.Name) + DASH_VAR + processStartDateTime(reIn.Start_Date_Time__c);
				rInteractionNameKey += DASH_VAR + reIn.Interaction_Type__c + DASH_VAR + reIn.Institution__c;
				System.debug('rInteractionNameKey:::::'+ rInteractionNameKey);
                //Checking for key in the map and accordingly populating the map with desired key-value pair                                        
				if(mapExistingRINameKeyWithListOfRIs.containsKey(rInteractionNameKey)) 
					mapExistingRINameKeyWithListOfRIs.get(rInteractionNameKey).add(reIn);  
				else  
					mapExistingRINameKeyWithListOfRIs.put(rInteractionNameKey, new List<Relationship_Interaction__c>{reIn});
			}
			
			//Map of relationship interaction - will be updated with name field value
			Map<Id, Relationship_Interaction__c> mapRIsToBeUpdate = new Map<Id, Relationship_Interaction__c>();
																
			//Loop through the mapExistingRINameKeyWithListOfRIs Map
			for(String riNameKey : mapExistingRINameKeyWithListOfRIs.keySet()) {
                
                //temporary variables    
				String rINametempValue = '';
				String rINameValue = '';
                
        	    //If the Relationship Interaction Name is the same for 2 or more records, increment the ID number starting with 1
                if(mapExistingRINameKeyWithListOfRIs.get(riNameKey).size() > 1) {
                    Integer counter_value = 1;
                    
                    //Loop through RI records and incrementing the ID number by 1 (each time)
                    for(Relationship_Interaction__c rI : mapExistingRINameKeyWithListOfRIs.get(riNameKey)) {
                    	
                    	System.debug('rI.Name:::::'+ rI.Name);
                    	
                        //temporary and intermediate key value
                        rINametempValue = '';
                    	rINametempValue = processAccountFormalName(rI, mapAccounts, rI.Name) + DASH_VAR + processStartDateTime(rI.Start_Date_Time__c);
						rINametempValue += DASH_VAR + rI.Interaction_Type__c;
						String counterSuffix = String.valueOf(counter_value);
                        if(counterSuffix.length() == 1)
                        	counterSuffix = '0' + counterSuffix;
                        rINametempValue += DASH_VAR + counterSuffix;
						
                        //Initializing the string literal - which will hold the name field value
                        rINameValue = '';
						rINameValue = processAccountFormalName(rI, mapAccounts, rI.Name) + DASH_VAR + processStartDateTime(rI.Start_Date_Time__c);
                    
						//Checking rIName for 80 character limits
						if(String.isNotBlank(rINametempValue) && rINametempValue.trim().length() > NAME_FIELD_MAX_CHAR_LIMIT) {
							
							//Truncate Interaction Type
							String truncatedInteractionType = processInteractionType(rINametempValue, rI.Interaction_Type__c);
							System.debug('truncatedInteractionType:::::'+ truncatedInteractionType);
							truncatedInteractionType = truncatedInteractionType.left(NAME_FIELD_MAX_CHAR_LIMIT - rINameValue.length() + 2 + counterSuffix.length());
							System.debug('truncatedInteractionType:::::'+ truncatedInteractionType);
							rINameValue += DASH_VAR + truncatedInteractionType;
							System.debug('rINameValue:::::'+ rINameValue);
						} else {
							rINameValue += DASH_VAR + rI.Interaction_Type__c;
							System.debug('rINameValue:::::'+ rINameValue);
						}
						System.debug('rINameValue:::::'+ rINameValue);
                        //Populating name field with value and populating map with instance of records
                        //Check if the name is already same, don't need to perform update DML on the record, else do
                        	
                        rINameValue = rINameValue + DASH_VAR + counterSuffix;
                        if(rI.Name != rINameValue) {
                        	
                        	//Check if name is still exceeding 80 chanracters, pull the left 80
                        	if(rINameValue.length() > NAME_FIELD_MAX_CHAR_LIMIT)
                        		rINameValue = rINameValue.left(NAME_FIELD_MAX_CHAR_LIMIT);
                        		
                        	rI.Name = rINameValue;
                        	mapRIsToBeUpdate.put(rI.Id, rI);
                        }
                        
                        //Update the counter for teh next record
                        counter_value++;
                    }
                } else {
                	
                	//Get the record
                    Relationship_Interaction__c rI = mapExistingRINameKeyWithListOfRIs.get(riNameKey)[0];
                    
                    //temporary and intermediate key value   
					rINametempValue = processAccountFormalName(rI, mapAccounts, rI.Name) + DASH_VAR + processStartDateTime(rI.Start_Date_Time__c);
					rINametempValue += DASH_VAR + rI.Interaction_Type__c;
					
                    //String literal - which will hold the name field value
                    rINameValue = processAccountFormalName(rI, mapAccounts, rI.Name) + DASH_VAR + processStartDateTime(rI.Start_Date_Time__c);
            
					//Checking rIName for 80 character limits
					if(String.isNotBlank(rINametempValue) && rINametempValue.trim().length() > NAME_FIELD_MAX_CHAR_LIMIT) {
						
						//Truncate Interaction Type
						String truncatedInteractionType = processInteractionType(rINametempValue, rI.Interaction_Type__c);
						truncatedInteractionType = truncatedInteractionType.left(NAME_FIELD_MAX_CHAR_LIMIT - rINameValue.length() + 1);
						rINameValue += DASH_VAR + truncatedInteractionType;
					} else {
						rINameValue += DASH_VAR + rI.Interaction_Type__c;
					}
					
                    //Populating name field with value and populating map with instance of records
					//Check if the name is already same, don't need to perform update DML on the record, else do
                    if(mapExistingRINameKeyWithListOfRIs.get(riNameKey)[0].Name != rINameValue) {
						
						//Check if name is still exceeding 80 chanracters, pull the left 80
                    	if(rINameValue.length() > NAME_FIELD_MAX_CHAR_LIMIT)
                    		rINameValue = rINameValue.left(NAME_FIELD_MAX_CHAR_LIMIT);
                        	
						mapExistingRINameKeyWithListOfRIs.get(riNameKey)[0].Name = rINameValue;
                    	mapRIsToBeUpdate.put(mapExistingRINameKeyWithListOfRIs.get(riNameKey)[0].Id, mapExistingRINameKeyWithListOfRIs.get(riNameKey)[0]);
					}
                }
			}
			
            //Checking for the size value
            if(mapRIsToBeUpdate.values().size() > 0) {
                
                //As all the processing is being done by the above code, no need to perform any additional logic
                Util.byPassAllTriggers = true;
                
                update mapRIsToBeUpdate.values();
                
                //Reactivate teh triggers
                Util.byPassAllTriggers = false;
            }
		}
	}
	
    //Added By - Abhinav Sharma - CR-20150930-9283 - 10/19/2015
    /**
     *  @description    :   Method to process the account Formal Name string value to truncate it. if exceeding max allowed chanracter limit. 
     * 
     *  @args           :   Relationship_Interaction__c rI, Map<Id, Account> mapInstitutions, String accName
     * 
     *  @return         :   String
     * 
    **/
	public static String processAccountFormalName(Relationship_Interaction__c rI, Map<Id, Account> mapInstitutions, String accName) {
		
		//Checking for the eligibility and null value
		if(String.IsNotBlank(accName) && mapInstitutions != null && rI != null) {
			
			//Checking of key presence in map of accounts
			if(rI.Institution__c != null && mapInstitutions.containsKey(rI.Institution__c) 
            	&& mapInstitutions.get(rI.Institution__c) != null) {
						
				//institution account name is exceeding 40 characters limit
				if(mapInstitutions.get(rI.Institution__c).Account_Formal_Name__c != null) {
					if(mapInstitutions.get(rI.Institution__c).Account_Formal_Name__c.trim().length() > INSTITUTION_NAME_MAX_ALLOWED_LENGTH) {
						accName = mapInstitutions.get(rI.Institution__c).Account_Formal_Name__c.trim();
						accName = accName.subString(0, INSTITUTION_NAME_MAX_ALLOWED_LENGTH);
					} else {
						accName = mapInstitutions.get(rI.Institution__c).Account_Formal_Name__c.trim();
					}
				} else {
					
					//Treat 	
					accName = KEYWORD_NULL;		
				}
			}
		}
		
		//Returning string value
		return accName;	
	}
	
    //Added By - Abhinav Sharma - CR-20150930-9283 - 10/19/2015
    /**
     *  @description    :   Method to process start date/time field and to form the desired string literal value of it. 
     * 
     *  @args           :   DateTime startDateTime
     * 
     *  @return         :   String
     * 
    **/
	public static String processStartDateTime(DateTime startDateTime) {
		
		//String variable to hold the start date time value
		String startDateTimeStr = '';
			
		//Checking date field for null value
		if(startDateTime != null) {
			startDateTimeStr = startDateTime.date().format();
		}
		
		//Returning start date/time string literal
		return startDateTimeStr;
	}
	
    //Added By - Abhinav Sharma - CR-20150930-9283 - 10/19/2015
    /**
     *  @description    :   Method to truncate interaction type. If name key string is exceeding 80 characters limit. 
     * 
     *  @args           :   String rICombinedString, String interactionType
     * 
     *  @return         :   String
     * 
    **/
	public static String processInteractionType(String rICombinedString, String interactionType) {
		
		//Truncated Interaction Type value
		String truncatedInteractionType = ''; 
		
		//Checking string literals for blank/null value
		// If string literal still exceeding 80 characters then truncate Interaction Type.
		if(String.isNotBlank(rICombinedString) && rICombinedString.trim().length() > NAME_FIELD_MAX_CHAR_LIMIT) {
			if(String.isNotBlank(interactionType) && String.isNotBlank(interactionType)) {
				Integer comibinedNameStringLength = rICombinedString.trim().length();
				Integer interactionTypeStringLength = interactionType.trim().length();
				Integer additionalCharacters = (rICombinedString.trim().length() - NAME_FIELD_MAX_CHAR_LIMIT);
				if(interactionTypeStringLength > additionalCharacters)
					truncatedInteractionType = interactionType.subString(0, (interactionTypeStringLength-additionalCharacters));
				else
					truncatedInteractionType = '';		
			}
		}
		
        //Returning truncated interaction type value
		return truncatedInteractionType;
	}
}