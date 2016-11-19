/*
 *	Purpose			:	This class is to control the functionality of adding new Change Batch
 *                  
 *  Create By       :   Subhash Garhwal
 *  
 *  Created Date    :   09/29/2015
 *  
 *  Revision Log    :   V_1.0 Created - CR-20150729-9114
 *                      
 **/
public with sharing class CreateChangeBatchController {
	
	//Variables
	public Incentive_Change_Batch__c incentiveCBatch {get;set;}
	public List<Incentive_Change_Log__c> incentiveChangeLogs {get;set;}
	
	//Constructor
	public CreateChangeBatchController(ApexPages.StandardSetController controller) {
		
		//Initilize 
		incentiveCBatch = new Incentive_Change_Batch__c();
		
		//Get selected
		incentiveChangeLogs = (List<Incentive_Change_Log__c>) controller.getSelected();
		
		//Check for list size
		if(incentiveChangeLogs == null || incentiveChangeLogs.size() == 0)
			//Add Error on page
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Please select at least one record'));
            
    }
	
	/**
	 *	@description	:	Method to save the change batch record
	 *
	 *	@args			:	
	 *
	 *	@return			:	Pagereference
	 *
	 **/
	public Pagereference doSave() {
		
		//Save Point to roll back changes
        Savepoint sp = Database.setSavepoint();
        
        try {
        	
        	//Check for ICL size
        	if(incentiveChangeLogs == null || incentiveChangeLogs.size() == 0)
        		throw new CustomException('Please select at least one record');
        	
        	//Insert the Batch record
        	if(incentiveCBatch != null) {
        		
        		//Insert
        		insert incentiveCBatch;
        		
        		//Loop through the Incentive Change log records to populate the Batch
        		for(Incentive_Change_Log__c iCL : incentiveChangeLogs) {
        			
        			//Update batch
        			iCL.Incentive_Change_Batch__c = incentiveCBatch.Id;
        		}
        		
        		//Update ICL
        		update incentiveChangeLogs;
        		
        		//Return
        		return new Pagereference('/' + incentiveCBatch.Id);
        	}
        } catch(DMLException dmlExp) {
            
            //Roll Back changes
            Database.rollback(sp);
            incentiveCBatch.Id = null;
            
            //Add Error on page
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,dmlExp.getDmlMessage(0)));
            return null;
            
        }catch(Exception e) {
            
            //Roll Back changes
            Database.rollback(sp);
            incentiveCBatch.Id = null;
            
            //Add Error on page
            ApexPages.addMessages(e);
            return null;
        }
        
        //Return
        return null;
    }
}