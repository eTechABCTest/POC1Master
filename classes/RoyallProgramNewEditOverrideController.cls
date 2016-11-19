/**
 *  Description     :   Helper class for Program_New_Edit_Override VF page.
 *  
 *  Created By      :   Subhash Garhwal (Simplyforce)
 *
 *  Created Date    :   02/11/2016
 *
 *  Deprecated      :   
 *
 *  Revision Logs   :  v1.0 - Created
 * 					:  V1.0 - Modified - Rajeev Jain - 06/16/2016 - SFDC schema Release - Manual Code Migration from Royall Enviournment, Rename this class with Preceeding text Royall
 *  
 **/
public with sharing class RoyallProgramNewEditOverrideController {
    
    //Properties
    
    //Program (Royall) instancc
    public Royall_Program__c program {get;set;}
    
    //Constructor
    public RoyallProgramNewEditOverrideController(ApexPages.StandardController controller) {
        
        //Get Record
        program = (Royall_Program__c) controller.getRecord();
    }
    
    /**
     *  @description    :   Method is used to save the program record
     *
     *  @args           :
     *
     *  @return         :   Pagereference
     *
     *  @created By     :   Subhash Garhwal (Simplyforce)
     *
     *  @revision Logs  :   V1.1 - 02/11/2016 - Created
     *
     **/
    public Pagereference doSave() {
         
        //Save Point to roll back changes
        Savepoint sp = Database.setSavepoint();
            
        try {
        
            //Check for program
            if(program != null) {
                
                //Check for Campaign SubType
                if(String.isNotBlank(program.Campaign_SubType__c)){
                    
                    //Check for Sub Type picklist values and remove corresponding field values
                    
                    if(!program.Campaign_SubType__c.contains(ProgramConstants.CAMPAIGN_SUBTYPE_AM_IP_NAME))
                        program.QTY_AM_IP_Name__c = null;
                    
                    if(!program.Campaign_SubType__c.contains(ProgramConstants.CAMPAIGN_SUBTYPE_AM_NEW_NAME))
                        program.QTY_AM_new_name__c = null;
                        
                    if(!program.Campaign_SubType__c.contains(ProgramConstants.CAMPAIGN_SUBTYPE_AM_PRE_NAME))
                        program.QTY_AM_PRE_Name__c = null;
                    
                    if(!program.Campaign_SubType__c.contains(ProgramConstants.CAMPAIGN_SUBTYPE_SE_IP_NAME_CLIENT_PROVIDED))
                        program.QTY_SE_IP_Name_Client__c = null;
                    
                    if(!program.Campaign_SubType__c.contains(ProgramConstants.CAMPAIGN_SUBTYPE_SE_IP_NAME_ROYALL_GENERATED))
                        program.QTY_SE_IP_Name_Royall__c = null;
                    
                    if(!program.Campaign_SubType__c.contains(ProgramConstants.CAMPAIGN_SUBTYPE_SE_NEW_NAME))
                        program.QTY_SE_New_Name__c = null;
                    
                    if(!program.Campaign_SubType__c.contains(ProgramConstants.CAMPAIGN_SUBTYPE_SE_PRE_NAME))
                        program.QTY_SE_PRE_Name__c = null;
                    
                    if(!program.Campaign_SubType__c.contains(ProgramConstants.CAMPAIGN_SUBTYPE_SS_PRE_NEW_NAME)) {
                        
                        //Set fields to null
                        program.QTY_SS_New_Name__c = null;
                        program.Postage_Cost_SS_New__c = null;
                        program.Program_Cost_SS_New__c = null;
                    }
                    
                    if(!program.Campaign_SubType__c.contains(ProgramConstants.CAMPAIGN_SUBTYPE_SS_PRE_PRE_NAME)) {
                        
                        //Set fields to null
                        program.QTY_SS_PRE_Name__c = null;
                        program.Postage_Cost_SS_PRE__c = null;
                        program.Program_Cost_SS_PRE__c = null;
                    }
                } else {
                	
                	//Set all the properties to null
                	program.QTY_AM_IP_Name__c = null;
					program.QTY_AM_new_name__c = null;
					program.QTY_AM_PRE_Name__c = null;
					program.QTY_SE_IP_Name_Client__c = null;
					program.QTY_SE_IP_Name_Royall__c = null;
					program.QTY_SE_New_Name__c = null;
					program.QTY_SE_PRE_Name__c = null;
					program.QTY_SS_New_Name__c = null;
					program.Postage_Cost_SS_New__c = null;
					program.Program_Cost_SS_New__c = null;
					program.QTY_SS_PRE_Name__c = null;
					program.Postage_Cost_SS_PRE__c = null;
					program.Program_Cost_SS_PRE__c = null;
                }
                
                //Get parameter values from URL
                String isClone = ApexPages.currentPage().getParameters().get('clone');
                
                //Check for value
                if(String.isNotBlank(isClone) && isClone == '1') {
                	
                	//Clone the current record
                	Royall_Program__c clonedProgram = program.clone();
                	
                	//Insert
                	insert clonedProgram;
                	
                	//Return 
                	return new Pagereference('/' +clonedProgram.Id);
                } else {
                	
                	//Upsert program
	                upsert program;
	                    
	                //Return 
	                return new Pagereference('/' +program.Id);	
                }
            }
        }catch(Exception e) {
                
            //Roll Back changes
            Database.rollback(sp);
            
            //Add Error on page
            ApexPages.addMessages(e);
            return null;
        }
        
        return null;
    }
}