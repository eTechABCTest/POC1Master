/**
 *	Purpose			:	This class is to schedule the Program Hierarchy
 *
 *	Created By		:	Bhavi Sharma
 *
 *	Created Date	:	04/09/2015
 *
 *	Revision Logs	:	V_1.0 - Created 
 *
 **/ 
global class Sched_UpdateProgramHierarchy implements Schedulable {
	
	//Execute Schedular
	global void execute(SchedulableContext ctx) {
		
        //Update Hierarchy
        Sched_UpdateProgramHierarchy.updateProgramHierarchy();
	}
	
	/**
	 * 	@description	:	This method is to pick all the Program Hierarchy records and keep them upto dated
	 * 
	 * 	@args			:	
	 * 
	 * 	@return			:	void
	 *
	 **/
	webservice static void updateProgramHierarchy() {
		
		//Query all the Existing records and prepare a map with of them
		//Key => Unique Id
		//Value => Program Hierarchy Id
		Map<String, Id> mapExistingProgramHierarchy = new Map<String, Id>();
		
		//Map to hold all the records to be created as new in System
		Map<String, Program_Hierarchy__c> mapNewProgramHierarchy = new Map<String, Program_Hierarchy__c>();
        
        //Set to hold the herarchy values have been processed
        Set<String> setProcessedHierarchies = new Set<String>();
        
        //Query through Record type
        List<RecordType> rTypes = [Select Id From RecordType Where sobjectType = 'Program_Hierarchy__c' AND DeveloperName = 'Hierarchy'];
		 
		//Loop through the exsiting records and prepare a map
		for(Program_Hierarchy__c pH : [Select Id, Hierarchy_Unique_ID__c, Unique_ID__c, Division__c, Business__c, 
											Vertical__c, Group__c, Acronym__c, Start_date__c, End_date__c from Program_Hierarchy__c 
											where Hierarchy_Unique_ID__c !=  null]) {
			
			//Put in map
			mapExistingProgramHierarchy.put(pH.Hierarchy_Unique_ID__c, pH.Id);
        }
		
		//Create a Map to hold the Program records with all possible scenario
		Map<String, List<Program_Hierarchy__c>> mapCurrentApplicableProgramHierarchy = new Map<String, List<Program_Hierarchy__c>>();
		
		//Fetch program data from database
		for(Program__c p : [Select Id, Account_Management_Reporting_Business__c, Account_Management_Reporting_Vertical__c, 
									Account_Management_Reporting_Group__c, New_Business_Business__c, New_Business_Vertical__c, New_Business_Group__c,
									Program_Acronym__c from Program__c]) {
			
			/***************************** Account Management *****************************/
			//Create AM unique key
			String hierarchyUniqueId = 'AM';
			
            //Check if this is already created then remove from map, else create
            if(!mapExistingProgramHierarchy.containsKey(hierarchyUniqueId) && !setProcessedHierarchies.contains(hierarchyUniqueId)) {
				mapNewProgramHierarchy.put(hierarchyUniqueId, new Program_Hierarchy__c(Name = hierarchyUniqueId, Hierarchy_Unique_ID__c = hierarchyUniqueId, Unique_ID__c = hierarchyUniqueId, Division__c = 'AM', Start_date__c = Date.today(), RecordTypeId = rTypes[0].Id));
            } else {
                mapExistingProgramHierarchy.remove(hierarchyUniqueId);
                setProcessedHierarchies.add(hierarchyUniqueId);
            }	
			//Account_Management_Reporting_Business__c
			if(String.isNotBlank(p.Account_Management_Reporting_Business__c)){
				
				//Modify unique Id
				hierarchyUniqueId += '-' + p.Account_Management_Reporting_Business__c;
				
				//Check if this is already created then remove from map, else create
                if(!mapExistingProgramHierarchy.containsKey(hierarchyUniqueId) && !setProcessedHierarchies.contains(hierarchyUniqueId)) {

                    mapNewProgramHierarchy.put(hierarchyUniqueId, new Program_Hierarchy__c(Name = hierarchyUniqueId, Hierarchy_Unique_ID__c = hierarchyUniqueId, Unique_ID__c = hierarchyUniqueId, Division__c = 'AM', Start_date__c = Date.today(), Business__c = p.Account_Management_Reporting_Business__c,RecordTypeId = rTypes[0].Id));
				} else {
                    mapExistingProgramHierarchy.remove(hierarchyUniqueId);
                    setProcessedHierarchies.add(hierarchyUniqueId);
                }	
			}
			
			//Account_Management_Reporting_Vertical__c
			if(String.isNotBlank(p.Account_Management_Reporting_Vertical__c)){
				
				//Modify unique Id
				hierarchyUniqueId += '-' + p.Account_Management_Reporting_Vertical__c;
				
				//Check if this is already created then remove from map, else create
                if(!mapExistingProgramHierarchy.containsKey(hierarchyUniqueId) && !setProcessedHierarchies.contains(hierarchyUniqueId)) {
					mapNewProgramHierarchy.put(hierarchyUniqueId, new Program_Hierarchy__c(Name = hierarchyUniqueId, Hierarchy_Unique_ID__c = hierarchyUniqueId, Unique_ID__c = hierarchyUniqueId, Division__c = 'AM', Start_date__c = Date.today(), Business__c = p.Account_Management_Reporting_Business__c, Vertical__c = p.Account_Management_Reporting_Vertical__c,RecordTypeId = rTypes[0].Id));
            	} else {
                    mapExistingProgramHierarchy.remove(hierarchyUniqueId);
                    setProcessedHierarchies.add(hierarchyUniqueId);
                }	
			}
			
			//Account_Management_Reporting_Group__c
			if(String.isNotBlank(p.Account_Management_Reporting_Group__c)){
				
				//Modify unique Id
				hierarchyUniqueId += '-' + p.Account_Management_Reporting_Group__c;
				
				//Check if this is already created then remove from map, else create
                if(!mapExistingProgramHierarchy.containsKey(hierarchyUniqueId) && !setProcessedHierarchies.contains(hierarchyUniqueId)) {
					mapNewProgramHierarchy.put(hierarchyUniqueId, new Program_Hierarchy__c(Name = hierarchyUniqueId, Hierarchy_Unique_ID__c = hierarchyUniqueId, Unique_ID__c = hierarchyUniqueId, Division__c = 'AM', Start_date__c = Date.today(), Business__c = p.Account_Management_Reporting_Business__c, Vertical__c = p.Account_Management_Reporting_Vertical__c, Group__c = p.Account_Management_Reporting_Group__c, RecordTypeId = rTypes[0].Id));
				} else {
                    mapExistingProgramHierarchy.remove(hierarchyUniqueId);
                    setProcessedHierarchies.add(hierarchyUniqueId);
                }	
			}
			
			//AM Program_Acronym__c
			if(String.isNotBlank(p.Program_Acronym__c)){
				
				//Modify unique Id
				hierarchyUniqueId += '-' + p.Program_Acronym__c;
				
				//Check if this is already created then remove from map, else create
                if(!mapExistingProgramHierarchy.containsKey(hierarchyUniqueId) && !setProcessedHierarchies.contains(hierarchyUniqueId)) {
					mapNewProgramHierarchy.put(hierarchyUniqueId, new Program_Hierarchy__c(Name = hierarchyUniqueId, Hierarchy_Unique_ID__c = hierarchyUniqueId, Unique_ID__c = hierarchyUniqueId, Division__c = 'AM', Start_date__c = Date.today(), Business__c = p.Account_Management_Reporting_Business__c, Vertical__c = p.Account_Management_Reporting_Vertical__c, Group__c = p.Account_Management_Reporting_Group__c, Acronym__c = p.Program_Acronym__c, RecordTypeId = rTypes[0].Id));
				} else {
                    mapExistingProgramHierarchy.remove(hierarchyUniqueId);
                    setProcessedHierarchies.add(hierarchyUniqueId);
                }	
			}
			/***************************** Account Management *****************************/
			
			
			/***************************** NBB *****************************/
			//Create NBB unique key
			hierarchyUniqueId = 'NBB';
			
			//Check if this is already created then remove from map, else create
                                        if(!mapExistingProgramHierarchy.containsKey(hierarchyUniqueId) && !setProcessedHierarchies.contains(hierarchyUniqueId)) {
				mapNewProgramHierarchy.put(hierarchyUniqueId, new Program_Hierarchy__c(Name = hierarchyUniqueId, Hierarchy_Unique_ID__c = hierarchyUniqueId, Unique_ID__c = hierarchyUniqueId, Division__c = 'NBB', Start_date__c = Date.today(), RecordTypeId = rTypes[0].Id));
			} else {
                mapExistingProgramHierarchy.remove(hierarchyUniqueId);
                setProcessedHierarchies.add(hierarchyUniqueId);
            }	
			//New_Business_Business__c
			if(String.isNotBlank(p.New_Business_Business__c)){
				
				//Modify unique Id
				hierarchyUniqueId += '-' + p.New_Business_Business__c;
				
				//Check if this is already created then remove from map, else create
                if(!mapExistingProgramHierarchy.containsKey(hierarchyUniqueId) && !setProcessedHierarchies.contains(hierarchyUniqueId)) {
					mapNewProgramHierarchy.put(hierarchyUniqueId, new Program_Hierarchy__c(Name = hierarchyUniqueId, Hierarchy_Unique_ID__c = hierarchyUniqueId, Unique_ID__c = hierarchyUniqueId, Division__c = 'NBB', Start_date__c = Date.today(), Business__c = p.New_Business_Business__c, RecordTypeId = rTypes[0].Id));
				} else {
                    mapExistingProgramHierarchy.remove(hierarchyUniqueId);
                    setProcessedHierarchies.add(hierarchyUniqueId);
                }	
			}
			
			//New_Business_Vertical__c
			if(String.isNotBlank(p.New_Business_Vertical__c)){
				
				//Modify unique Id
				hierarchyUniqueId += '-' + p.New_Business_Vertical__c;
				
				//Check if this is already created then remove from map, else create
                if(!mapExistingProgramHierarchy.containsKey(hierarchyUniqueId) && !setProcessedHierarchies.contains(hierarchyUniqueId)) {
					mapNewProgramHierarchy.put(hierarchyUniqueId, new Program_Hierarchy__c(Name = hierarchyUniqueId, Hierarchy_Unique_ID__c = hierarchyUniqueId, Unique_ID__c = hierarchyUniqueId, Division__c = 'NBB', Start_date__c = Date.today(), Business__c = p.New_Business_Business__c, Vertical__c = p.New_Business_Vertical__c,RecordTypeId = rTypes[0].Id));
				} else {
                    mapExistingProgramHierarchy.remove(hierarchyUniqueId);
                    setProcessedHierarchies.add(hierarchyUniqueId);
                }	
			}
			
			//New_Business_Group__c
			if(String.isNotBlank(p.New_Business_Group__c)){
				
				//Modify unique Id
				hierarchyUniqueId += '-' + p.New_Business_Group__c;
				
				//Check if this is already created then remove from map, else create
                if(!mapExistingProgramHierarchy.containsKey(hierarchyUniqueId) && !setProcessedHierarchies.contains(hierarchyUniqueId)) {
					mapNewProgramHierarchy.put(hierarchyUniqueId, new Program_Hierarchy__c(Name = hierarchyUniqueId, Hierarchy_Unique_ID__c = hierarchyUniqueId, Unique_ID__c = hierarchyUniqueId, Division__c = 'NBB', Start_date__c = Date.today(), Business__c = p.New_Business_Business__c, Vertical__c = p.New_Business_Vertical__c, Group__c = p.New_Business_Group__c, RecordTypeId = rTypes[0].Id));
				} else {
                    mapExistingProgramHierarchy.remove(hierarchyUniqueId);
                    setProcessedHierarchies.add(hierarchyUniqueId);
                }	
			}
			
			//AM Program_Acronym__c
			if(String.isNotBlank(p.Program_Acronym__c)){
				
				//Modify unique Id
				hierarchyUniqueId += '-' + p.Program_Acronym__c;
				
				//Check if this is already created then remove from map, else create
                if(!mapExistingProgramHierarchy.containsKey(hierarchyUniqueId) && !setProcessedHierarchies.contains(hierarchyUniqueId)) {
					mapNewProgramHierarchy.put(hierarchyUniqueId, new Program_Hierarchy__c(Name = hierarchyUniqueId, Hierarchy_Unique_ID__c = hierarchyUniqueId, Unique_ID__c = hierarchyUniqueId, Division__c = 'NBB', Start_date__c = Date.today(), Business__c = p.New_Business_Business__c, Vertical__c = p.New_Business_Vertical__c, Group__c = p.New_Business_Group__c, Acronym__c = p.Program_Acronym__c, RecordTypeId = rTypes[0].Id));
				} else {
                    mapExistingProgramHierarchy.remove(hierarchyUniqueId);
                    setProcessedHierarchies.add(hierarchyUniqueId);
                }	
			}
			/***************************** NBB *****************************/
		}
		
		//mapNewProgramHierarchy map have all the PH records to be created
		//mapExistingProgramHierarchy has all teh records to be ended
		if(mapNewProgramHierarchy.size() > 0)
			insert mapNewProgramHierarchy.values();
		
		//mapExistingProgramHierarchy
		if(mapExistingProgramHierarchy.size() > 0) {
			
            //List of record to update
            List<Program_Hierarchy__c> pHierarchies = new List<Program_Hierarchy__c>();
            
			//Update end date
			for(Id pHId : mapExistingProgramHierarchy.values())
				pHierarchies.add(new Program_Hierarchy__c(Id = pHId, End_date__c = Date.today()));
			update pHierarchies;
		}
	}
}