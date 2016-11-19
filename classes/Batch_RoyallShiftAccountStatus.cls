/**
 *	Purpose			:	Batch is using to Upadte information on Account realted to Program Package/HD	
 *
 *	Created By		:	Subhash Garhwal	
 *
 *	Created Date	:	07/08/2016	
 *
 *	Rivision Log	:	V_1.1 - Created	
 *						V_1.2 - Moved - 9/20/2016 - Subhash Garhwal - CR-20160817-10134 - Moved class from Royall Instance and Renamed to "Batch_RoyallShiftAccountStatus" From "Batch_ShiftAccountStatus".
 *
 **/
global class Batch_RoyallShiftAccountStatus implements Database.Batchable<sobject> { 
	 
	/**
	 * @description		:	Batch class Start method
	 *
 	 * @args			:	Database.BatchableContext bc
	 *
	 * @return			:	Database.QueryLocator
	 **/
	global Database.QueryLocator start(Database.BatchableContext bc){
		
		//Added - Subhash Garhwal - 9/20/2016 - CR-20160817-10134
		//Set to hold the Royall Record types developer name
		Set<String> setRoyallRecordTypes = new Set<String>{'Royall_Admissions_Graduate', 'Royall_Admissions_Undergraduate', 'Royall_Advancement'};
		
		//SOQL query string
		String queryString = 'Select Id,r_Current_Year_Status__c From Account Where RecordType.DeveloperName IN : setRoyallRecordTypes';
   		
   		//return query
		return Database.getQueryLocator(queryString);
		
	}
	
	/**
	 * Description		:	Batch class execute method
	 *
	 * Args				:	Database.batchableContext bc, List<Account> scope
	 *
	 * Return			:	Void
	 **/
	global void execute(Database.batchableContext bc, List<Account> scope ) {
		
		//Calculate the current Fiscal year using shift_fical_year class
	    Integer currentFY = shift_get_fiscal_year.current();
	    
		//Map Of Account to be update 
		Map<Id,Account> mapOfAccountsTobeUpdated = new Map<Id, Account>();
		
		//Loop over list of Account
		for(Account acc : scope) {
			
			//Populated map
			mapOfAccountsTobeUpdated.put(acc.Id, new Account(Id = acc.Id,r_Current_Year_Status__c = null, r_Previous_Year_Status__c = null, 
																r_Next_Year_Status__c = null, r_Current_Year_Account_Status__c = null,
																r_Previous_Year_Account_Status__c = null, r_Next_Year_Account_Status__c = null,
																r_HD_Previous_Year_Engagement_Status__c = null, r_HD_Current_Year_Engagement_Status__c = null,
																r_HD_Next_Year_Engagement_Status__c = null, r_HD_Previous_Year_Account_Status__c = null,
   																r_hd_current_year_account_status__c = null, r_HD_Next_Year_Account_Status__c = null));
		}
		
		//Method calling for program package
		programPackage(mapOfAccountsTobeUpdated, scope,currentFY);
		
		//Method call for program package
		programPackageHD(mapOfAccountsTobeUpdated, scope,currentFY);
		
		//Check map value size and update accounts
		if(mapOfAccountsTobeUpdated.values().size() > 0) 
			update mapOfAccountsTobeUpdated.values();
		
	}
	
	/**
	 * @description		:	Batch class finish method
	 *
	 * @args			:	Database.batchableContext bc
	 *
	 * @return			:	Void
	 **/
	global void finish(Database.batchableContext bc){
	}
	
	/**
	 * @description		:	Method is using into batch execute method for popuplate Account fields for Program package information
	 *
	 * @args			:	Map<Id,Account> mapOfAccountsTobeUpdated, List<Account> scope, Integer currentFY
	 *
	 * @return			:	Void
	 **/
	public void programPackage(Map<Id,Account> mapOfAccountsTobeUpdated, List<Account> scope, Integer currentFY) {
		
		//List of Program Package related to set of Account Ids
	    List<Program_Package__c> progPackList = new List<Program_Package__c>([Select Id, Name, Account__c, Fiscal_Year__c, Client_Status_New__c,
	    											Account_Status__c from Program_Package__c where Account__c in: scope
	                        						order by Account__c asc, Fiscal_Year__c asc]); 
	                        						
		for(Program_Package__c p : progPackList) {
			
			//Check if map conatins Account Id realted to progaram packages
        	if(mapOfAccountsTobeUpdated.containsKey(p.Account__c)) {
                		
                		
				//Get the status for Previous, Current and Next Fiscal Year
	            if (p.Fiscal_Year__c != null){  
	            	
	            	//Check if Fiscal year equals to Current Fiscal year    
	                if (integer.valueOf(p.Fiscal_Year__c) == currentFY) {
	                	
	                	//Populated Account'S field Current Year Status and Current Year Account Status by PP fields
	            		mapOfAccountsTobeUpdated.get(p.Account__c).r_Current_Year_Status__c = p.Client_Status_New__c;
	            		mapOfAccountsTobeUpdated.get(p.Account__c).r_Current_Year_Account_Status__c = p.Account_Status__c;
	            	}
	          		
	          		
	          		//Check if fiscal year is less 1 year from current fiscal year
	                if (integer.valueOf(p.Fiscal_Year__c) == currentFY+1) {
	                   	
		        		//Populated Account'S field Next Year Status and NExt Year Account Status by PP fields
		        		mapOfAccountsTobeUpdated.get(p.Account__c).r_Next_Year_Status__c = p.Client_Status_New__c;
		        		mapOfAccountsTobeUpdated.get(p.Account__c).r_Next_Year_Account_Status__c = p.Account_Status__c;
	                	
	            	}
	            	
	            	//Check if fiscal year is greater than 1 year from current fiscal year
	                if (integer.valueOf(p.Fiscal_Year__c) == currentFY-1) {
	                   	
		        		//Populated Account'S field Prevous Year Status and previous Year Account Status by PP fields
		        		mapOfAccountsTobeUpdated.get(p.Account__c).r_Previous_Year_Status__c = p.Client_Status_New__c;
		        		mapOfAccountsTobeUpdated.get(p.Account__c).r_Previous_Year_Account_Status__c = p.Account_Status__c;
	                }
	            } 
        	}
        }
	}
	
	/**
	 * @description		:	Method is using into batch execute method for popuplate Account fields for Program packageHD information
	 *
	 * @args			:	Map<Id,Account> mapOfAccountsTobeUpdated, List<Account> scope, Integer currentFY
	 *
	 * @return			:	Void
	 **/
	public void programPackageHD(Map<Id,Account> mapOfAccountsTobeUpdated, List<Account> scope, Integer currentFY) {
		
		//List Of  Program Packages HD
	    List<Program_Package_Hardwick_Day__c> progPackHDList = new list<Program_Package_Hardwick_Day__c>([Select Id, Account__c, Fiscal_Year_HD__c,
    														 	Client_Engagement_Status_HD__c, HD_Account_Status__c from Program_Package_Hardwick_Day__c
                												where Account__c in: scope order by Account__c asc, Fiscal_Year_HD__c asc]);  
                												
		//Loop over List of Program Packages HD
        for (Program_Package_Hardwick_Day__c pHD : progPackHDList) {
        	
        	//Check if map conatins Account Id related to progaram packages HD
        	if(mapOfAccountsTobeUpdated.containsKey(pHD.Account__c)) {
                		
	            //Get the status for Previous, Current and Next Fiscal Year HD
	            if (pHD.Fiscal_Year_HD__c != null){  
	            	
	            	//Check if Fiscal year HD equals to Current Fiscal year    
	                if (integer.valueOf(pHD.Fiscal_Year_HD__c) == currentFY) {
	                	
                		//Populated Account'S field Current Year Engagement Status and Current Year Account Status by PPHD fields
                		mapOfAccountsTobeUpdated.get(pHD.Account__c).r_HD_Current_Year_Engagement_Status__c = pHD.Client_Engagement_Status_HD__c;
                		mapOfAccountsTobeUpdated.get(pHD.Account__c).r_hd_current_year_account_status__c = pHD.HD_Account_Status__c;
	          		}
	          		
	          		//Check if fiscal year HD is greater than 1 year from current fiscal year
	                if (integer.valueOf(pHD.Fiscal_Year_HD__c) == currentFY+1) {
	                   
	                   	//Populated Account'S field Next Year Engagement Status and Next Year Account Status by PPHD fields
                		mapOfAccountsTobeUpdated.get(pHD.Account__c).r_HD_Next_Year_Engagement_Status__c = pHD.Client_Engagement_Status_HD__c;
                		mapOfAccountsTobeUpdated.get(pHD.Account__c).r_HD_Next_Year_Account_Status__c = pHD.HD_Account_Status__c;
	            	}
	            	
	            	//Check if fiscal year HD is less than 1 year from current fiscal year 
	                if (integer.valueOf(pHD.Fiscal_Year_HD__c) == currentFY-1) {
	                   
	                   	//Populated Account'S field previous Year Engagement Status and previous Year Account Status by PPHD fields
	            		mapOfAccountsTobeUpdated.get(pHD.Account__c).r_HD_Previous_Year_Engagement_Status__c = pHD.Client_Engagement_Status_HD__c;
	            		mapOfAccountsTobeUpdated.get(pHD.Account__c).r_HD_Previous_Year_Account_Status__c = pHD.HD_Account_Status__c;
	                }
	            } 
        	}
        } 
	}
}