/**
 *  Purpose         :   Controller for EditClarification VF page. 
 * 
 *  Created By      :   Subhash Garhwal
 * 
 *  Created Date    :   07/01/2015 
 * 
 *  Revision Logs   :   V_1.0 - Created - CR-20150618-9014
 * 
 **/
public with sharing class EditClarificationController {
    
    //Variables
    public Team_Membership__c staffAssign {get;set;}
    public Boolean isEdit {get;set;}
    public String sldOption {get;set;}
    public Boolean cloneRPPs {get;set;} 
    
    //List to hold available options
    public List<SelectOption> options {
        get {
            
            String startDate =  staffAssign.Start_date__c != null ? staffAssign.Start_date__c.format() : '';
            
             List<SelectOption> options = new List<SelectOption>{
                                             new SelectOption('Cancel', LABEL.Editclarification_Cancel),
                                         new SelectOption('New', LABEL.EditClarification_New + ' ' +startDate + '.'),
                                             new SelectOption('Edit', LABEL.EditClarification_Edit + ' ' + startDate + '.')
                                        };
            //Return
            return options;
        }
    }
    
    //Constructor
    public EditClarificationController(Apexpages.Standardcontroller controller) {
        
        //Get record
        staffAssign = (Team_Membership__c) controller.getRecord();
        
        //Set properties
        isEdit = false;
        sldOption = 'Cancel';
        cloneRPPs = false;
    }
    
    /**
     *  @description    :   Method is used to redirect user according to selected option.
     *
     *  @args           :   
     *
     *  @return         :   Pagereference
     *
     **/
    public Pagereference redirectUser() {
        
        //Check selected option values
        if(String.isNotBlank(sldOption)) {
            
            //Check for new case
            if(sldOption == 'New') {
                isEdit = false;
                
            //Edit case
            } else if(sldOption == 'Edit')
                isEdit = true;
            
            //Cancel case
            else if(sldOption == 'Cancel')
                return new Pagereference('/' + staffAssign.Id);
        }
        
        //Return
        return null;
    }
    
    /**
     *  @description    :   Method is used to redirect user on new Staff Assignment page
     *
     *  @args           :
     *
     *  @return         :   
     *
     **/
    public Pagereference doNew() {
        
        //Check for new case
        if(sldOption == 'New') {
                
            //Query through Staff Assignment
            List<Team_Membership__c> staffAssigns = [Select Id, Institution__c, Staff_member__c, Role__c From Team_Membership__c Where Id =: staffAssign.Id];
            
            //Check for size
            if(staffAssigns.size() > 0) {
                
                //Return URL String
                String returnURL = '/apex/RedirectWithVariables?redirect=Object--Team_Membership__c!!Name--Will Auto-Populates';
                
                //Check for Institution
                if(String.isNotBlank(staffAssigns[0].Institution__c))
                    returnURL += '!!Institution__c--' + staffAssigns[0].Institution__c;
                
                //Check for Staff member
                if(String.isNotBlank(staffAssigns[0].Staff_member__c))
                    returnURL += '!!Staff_member__c--' + staffAssigns[0].Staff_member__c;
                
                //Check for Role
                if(String.isNotBlank(staffAssigns[0].Role__c))
                    returnURL += '!!Role__c--' + staffAssigns[0].Role__c;
                
                //Pass additional Parameters in URL
                returnURL += '!!afterSaveURL--/apex/UpdateSourceStaffAssignment?sourceId=' + staffAssigns[0].Id +'-' + cloneRPPs + '!!returnURL--/' + staffAssign.Id; 
                
                //Redirect user on RedirectWithVariables VF page
                return new Pagereference(returnURL);    
            }
        
        } else if(sldOption == 'Edit')
            isEdit = true;
            
        //Cancel case
        else if(sldOption == 'Cancel')
            return new Pagereference('/' + staffAssign.Id);
        
        //Return
        return null;
    }
    
    /**
     *  @description    :   This method is used to save updated information for Staff Assignment
     *
     *  @args           :
     *
     *  @return         :   Pagereference
     *
     **/
    public Pagereference doSave() {
        
        try {
            
            //Check for Staff Assignment value
            if(staffAssign != null) {
                
                //Update
                update staffAssign;
                
                //Return
                return new Pagereference('/' + staffAssign.Id);
            }
        } catch(DMLException dmlExp) {
            
            //Add Error on page
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,dmlExp.getDmlMessage(0)));
            return null;
            
        }catch(Exception e) {
            //Add Error on page
            ApexPages.addMessages(e);
            return null;
        }
        
        //Return
        return null;
    }
}