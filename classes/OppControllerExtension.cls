/**
 *  Description     :  Controller class for OpportunityContractLOAEdit, OpportunityContractLOAView VF pages
 *
 *  Created By      :  Subhash Garhwal
 *
 *  Created Date    :  06/09/2016
 *
 *  Revision Logs   :   V_1.0 - Created - Subhash Garhwal - CR-20160414-9762 
 *                      V_1.1 - Modified - 10/12/2016 - Subhash Garhwal -  - Q2C Hypercare of Hypercare
 *
 **/
public with sharing class OppControllerExtension {
    
    //Define Properties
    
    //Instance of Opportunity
    public Opportunity opp {get;set;}
    
    //Variable to control flow of VF pages
    public String flowControl {get;set;}
    
    //Select option to display the possiable stage values according to stage value
    public List<SelectOption> stageValues {get;set;}
    
    //Flag to control Program Opp creation for Closed Opportunities
    public Boolean isParentClosed {get;set;}
    public String retURL {get;set;}
    public Boolean hideProgramOppNewButton {get;set;}
    
    //Local variables
    String parentOppId {get;set;}
    
    //Define constructor
    public OppControllerExtension(ApexPages.StandardController controller) {
        
        //Get Record
        opp = (Opportunity) controller.getRecord();
        
        //Call inIt
        inIt();     
    }
    
    /**
     *  @description    :   This method is used to load all the default properties
     *
     *  @args           :
     *
     *  @return         :   void
     *
     *  @revision Logs  :   Created - Subhash Garhwal - 06/09/2016 - CR-20160414-9762
     *
     **/
    public void inIt() {
        
        //Set Default values
        flowControl = '';
        stageValues = new List<SelectOption>();
        isParentClosed = false;
        parentOppId = '';
        hideProgramOppNewButton = false;
        
        //Variable to hold the Temp Opportunity
        Opportunity tempOpp = new Opportunity();
        
        //Get parent Opp Id
        parentOppId = ApexPages.currentPage().getParameters().get('pOppId');
            
        //Check for Opportunity record
        if(String.isBlank(opp.Id)) {
            
            //Set flow control variable properties
            flowControl = CPQConstants.OPPORTUNITY_INFO_SECTION_STAGE_ONE_NEW + ',' + CPQConstants.PROGRAM_OPP_PIPELINE_SECTION_NEW;
            
            //Opportunity Instance
            opp.OwnerId = UserInfo.getUserId(); 
            opp.StageName = CPQConstants.OPPORTUNITY_STAGE_ON_DECK;
            opp.Probability = 0;
            opp.Amount = 0;
            // **Removed this as per the updated Work Order - CM** // opp.Closedate = Date.newInstance(System.today().year(), System.today().month(), Date.daysInMonth(System.today().year(), System.today().month()));
            opp.Name = ApexPages.currentPage().getParameters().get('opp3');
            opp.RecordTypeId = ApexPages.currentPage().getParameters().get('RecordType');
            
            String accId = ApexPages.currentPage().getParameters().get('accId');
            
            //Set Stage Options for Contract LOA Opp
            stageValues = CPQConstants.OPPORTUNITY_ON_DECK_STAGE_OPTIONS;
            
            if(String.isNotBlank(accId))
                opp.AccountId = accId;
            
            //Check for Parent Opp
            if(String.isNotBlank(parentOppId) && parentOppId instanceof Id) {
                
                //Set Return URL
                retURL = parentOppId;
                
                //Query through Parent Opp to get details
                Opportunity parentOpp = [Select Id, AccountId, OwnerId, Closedate, StageName, IsClosed From Opportunity Where Id =: parentOppId];
                
                //Check for Closed Opp isParentClosed
                if(parentOpp.IsClosed || parentOpp.StageName == CPQConstants.OPPORTUNITY_STAGE_CONTRACT_REC_SEND_TO_FINANCE
                    || parentOpp.StageName == CPQConstants.OPPORTUNITY_STAGE_SEND_TO_FINANCE_OPP_REJECTED) {
                        
                    //Check flag to true
                    isParentClosed = true;
                    
                    return; 
                }
                
                //Query thotugh Opportunity Record Type
                List<RecordType> recordTypes = [Select Id, DeveloperName From RecordType Where SobjectType = 'Opportunity' AND
                                                        DeveloperName =: CPQConstants.OPPORTUNITY_RECORD_TYPE_DEVELOPERNAME_PROGRAM_PT_MARKETING LIMIT 1];
                
                //Populate Program Opp field value
                opp.RecordTypeId = recordTypes.size() > 0 ? recordTypes[0].Id : opp.RecordTypeId;
                opp.AccountId = parentOpp.AccountId;
                opp.Closedate = parentOpp.Closedate;
                opp.StageName = CPQConstants.OPPORTUNITY_STAGE_PROSPECT;
                opp.Parent_Opportunity__c = parentOpp.Id;
                opp.Source_Stage__c = CPQConstants.OPPORTUNITY_SOURCE_STAGE_ON_DECK; 
                opp.OwnerId = parentOpp.OwnerId;
                opp.Name = 'Will Auto-Populate';
                
                //Check for Parent Opp Stage
                if(parentOpp.StageName == CPQConstants.OPPORTUNITY_STAGE_ON_DECK)
                    stageValues = CPQConstants.PROG_OPPORTUNITY_ON_DECK_STAGE_OPTIONS;
                else {
                    
                    //Re-set Variable
                    stageValues = new List<SelectOption>();
                    
                    //Add Prospect value
                    stageValues.add(new SelectOption(CPQConstants.OPPORTUNITY_STAGE_PROSPECT,CPQConstants.OPPORTUNITY_STAGE_PROSPECT));
                    
                    if(parentOpp.StageName == CPQConstants.OPPORTUNITY_STAGE_ON_PIPELINE)
                        stageValues.addAll(CPQConstants.PROG_OPPORTUNITY_PIPELINE_STAGE_OPTIONS);
                    else if(parentOpp.StageName == CPQConstants.OPPORTUNITY_STAGE_CONTRACT_REC_SEND_TO_FINANCE)
                        stageValues.addAll(CPQConstants.PROG_OPPORTUNITY_CONTRACT_RECEIVED_STAGE_OPTIONS);
                    else if(parentOpp.StageName == CPQConstants.OPPORTUNITY_STAGE_CLOSED_WON)
                        stageValues.addAll(CPQConstants.PROG_OPPORTUNITY_CLOSED_WON_NON_PRIMARY_STAGE_OPTIONS);
                }   
            }
        } else {
            
            //Query on the oppoerunity to get the 
            tempOpp = [Select Id, StageName, RecordTypeId, RecordType.DeveloperName, IsClosed, Program_Proposal_Status__c, Contract_LOA_Opp_Stage__c,
                              Parent_Opportunity__c, Parent_Opportunity__r.StageName, Parent_Opportunity__r.IsClosed From Opportunity Where Id =: opp.Id];
            
            //Check for Record Type
            
            /***********************       Contract LOA Start             ********************/
            if(tempOpp.RecordType.DeveloperName == CPQConstants.OPPORTUNITY_RECORD_TYPE_DEVELOPERNAME_CONTRACT_LOA) {
            
                //Check for Stage values
                if(tempOpp.StageName == CPQConstants.OPPORTUNITY_STAGE_ON_DECK)
                    stageValues = CPQConstants.OPPORTUNITY_ON_DECK_STAGE_OPTIONS;
                else if(tempOpp.StageName == CPQConstants.OPPORTUNITY_STAGE_ON_PIPELINE)
                    stageValues = CPQConstants.OPPORTUNITY_ON_PIPELINE_STAGE_OPTIONS;
                else if(tempOpp.StageName == CPQConstants.OPPORTUNITY_STAGE_CONTRACT_REC_SEND_TO_FINANCE)
                    stageValues = CPQConstants.OPPORTUNITY_ON_CRSTF_STAGE_OPTIONS;
                else if(tempOpp.StageName == CPQConstants.OPPORTUNITY_STAGE_SEND_TO_FINANCE_OPP_REJECTED)
                    stageValues = CPQConstants.OPPORTUNITY_ON_STFR_STAGE_OPTIONS;
                
                //Check for Opportunity Stage to show and hide fields on VF pages (for Info section)
                if(CPQConstants.SET_OPPORTUNITY_STAGE_CONTRACT_LOA_VALUES.contains(tempOpp.StageName)) {
                    
                    flowControl = CPQConstants.OPPORTUNITY_INFO_SECTION_STAGE_TWO_OPEN + ',' + CPQConstants.OPPORTUNITY_MF_SECTION_STAGE_TWO_OPEN + ','
                                  + CPQConstants.OPPORTUNITY_OS_SECTION_STAGE_TWO_OPEN + ',' + CPQConstants.OPPORTUNITY_SI_SECTION_STAGE_TWO_THREE_OPEN + ',';
                    
                    //Add value for result section
                    if(tempOpp.StageName != CPQConstants.OPPORTUNITY_STAGE_ON_DECK)
                        flowControl = flowControl + CPQConstants.OPPORTUNITY_PIPELINE_SECTION_STAGE_TWO_OPEN + ','
                                      + CPQConstants.OPPORTUNITY_SB_SECTION_STAGE_TWO_THREE_OPEN_OR_CLOSED + ','
                                      + CPQConstants.OPPORTUNITY_RL_SECTION_STAGE_TWO_THREE + ',';
                    else
                        flowControl = flowControl + CPQConstants.OPPORTUNITY_SB_SECTION_STAGE_ONE_TWO_NEW + ',';
                        
                    //Check for Stage
                    if(tempOpp.StageName != CPQConstants.OPPORTUNITY_STAGE_ON_DECK && tempOpp.StageName != CPQConstants.OPPORTUNITY_STAGE_ON_PIPELINE)
                        flowControl += CPQConstants.OPPORTUNITY_RESULT_SECTION_STAGE_TWO_OPEN + ',';
                } 
                
                //Check for closed Opportunity
                if(tempOpp.IsClosed) {
                    
                    //Set variable values
                    flowControl = CPQConstants.OPPORTUNITY_INFO_SECTION_STAGE_THREE_CLOSED + ',' + CPQConstants.OPPORTUNITY_RESULT_SECTION_STAGE_TWO_OPEN
                                 + ',' + CPQConstants.OPPORTUNITY_MF_SECTION_STAGE_THREE_CLOSED + ',' + CPQConstants.OPPORTUNITY_PIPELINE_SECTION_STAGE_THREE_CLOSED
                                 + ',' + CPQConstants.OPPORTUNITY_SI_SECTION_STAGE_TWO_THREE_OPEN + ',' + CPQConstants.OPPORTUNITY_RL_SECTION_STAGE_TWO_THREE
                                 + ',' + CPQConstants.OPPORTUNITY_SB_SECTION_STAGE_TWO_THREE_OPEN_OR_CLOSED + ',' + CPQConstants.OPPORTUNITY_OS_SECTION_STAGE_TWO_OPEN;
                }
                
                //Check for Opp Stage 
                if(!CPQConstants.SET_CONTRACT_LOA_PIPELINE_PRIOR_STAGE_VALUES.contains(tempOpp.StageName))
                    hideProgramOppNewButton = true;
                    
                /***********************       Contract LOA End             ********************/
                
                /***********************       Program Opportunity Start         ********************/
            } else {
                
                //Check for Opportunity Stage
                //if(tempOpp.Parent_Opportunity__c != null && tempOpp.Parent_Opportunity__r.IsClosed) {
                    
                    //flowControl = CPQConstants.PROGRAM_OPP_INFO_SECTION_CLOSED_STAGE + ',' + CPQConstants.PROGRAM_OPP_CLOSED_ADVANCE;
                    
                //} else  {
                    
                //Check for Program_Proposal_Status__c
                if(String.isNotBlank(tempOpp.Program_Proposal_Status__c)) {
                    
                    //Set stage values according to Parent Opp  
                    if(tempOpp.Contract_LOA_Opp_Stage__c == CPQConstants.OPPORTUNITY_STAGE_ON_DECK)
                        stageValues = CPQConstants.PROG_OPPORTUNITY_ON_DECK_STAGE_OPTIONS;
                    else if (tempOpp.Contract_LOA_Opp_Stage__c == CPQConstants.OPPORTUNITY_STAGE_ON_PIPELINE)
                        stageValues = CPQConstants.PROG_OPPORTUNITY_PIPELINE_STAGE_OPTIONS;
                    else if (tempOpp.Contract_LOA_Opp_Stage__c == CPQConstants.OPPORTUNITY_STAGE_CONTRACT_REC_SEND_TO_FINANCE)
                        stageValues = CPQConstants.PROG_OPPORTUNITY_CONTRACT_RECEIVED_STAGE_OPTIONS;
                    
                    else if(tempOpp.Contract_LOA_Opp_Stage__c == CPQConstants.OPPORTUNITY_STAGE_CLOSED_WON) {
                        
                        //Query throguh Proposal/Quote Lines to check for Primary option
                        List<SBQQ__QuoteLine__c> quoteLines = [Select Id From SBQQ__QuoteLine__c Where Is_Primary_Quote__c = true AND Program_Opportunity__c =: tempOpp.Id LIMIT 1];
                        
                        //Check for list size
                        if(quoteLines.size() == 0) {
                            
                            //Re-set
                            stageValues = new List<SelectOption>();
                            
                            //Check for current values
                            if(tempOpp.StageName != CPQConstants.OPPORTUNITY_STAGE_CLOSED_LOST)
                                stageValues.add(new SelectOption(tempOpp.StageName, tempOpp.StageName));
                            
                            //Add addition stage values
                            stageValues.addAll(CPQConstants.PROG_OPPORTUNITY_CLOSED_WON_NON_PRIMARY_STAGE_OPTIONS); 
                        }
                    }   
                } else
                    stageValues = CPQConstants.PROG_OPPORTUNITY_ON_DECK_STAGE_OPTIONS;
                
                
                
                //Add Section details
                flowControl = CPQConstants.PROGRAM_OPP_INFO_SECTION_OPEN_STAGE + ',';
                
                //Commented Out - 08/17/2016 - Subhash Garhwal - Issue No 845 from Q2c wave 1
                //Check for Program Posposal status
                //if(String.isNotBlank(tempOpp.Program_Proposal_Status__c)) {
                    
                    //Commented Out - 08/17/2016 - Subhash Garhwal - Issue No 845 from Q2c wave 1
                    /*if(tempOpp.Contract_LOA_Opp_Stage__c == CPQConstants.OPPORTUNITY_STAGE_ON_DECK)
                        flowControl = flowControl + CPQConstants.PROGRAM_OPP_INFO_SECTION_OPEN_ON_DECK_STAGE + ',';
                    else
                        flowControl = flowControl + CPQConstants.PROGRAM_OPP_INFO_SECTION_OPEN_ADVANCE_STAGE + ',' + CPQConstants.PROGRAM_OPP_MSND_ADVANCE + ',';
                    */
                /*} else if(CPQConstants.SET_Program_Opp_ON_DECK_STAGES.contains(tempOpp.StageName)) {
                    
                    flowControl = flowControl + CPQConstants.PROGRAM_OPP_INFO_SECTION_OPEN_ON_DECK_STAGE + ',';
                } else
                    flowControl = flowControl + CPQConstants.PROGRAM_OPP_INFO_SECTION_OPEN_ADVANCE_STAGE + ',' + CPQConstants.PROGRAM_OPP_MSND_ADVANCE + ',';
                */
                
                //Added - 08/17/2016 - Subhash Garhwal - Issue No 845 from Q2c wave 1
                //Check for Program Opp Stage
                if(CPQConstants.SET_Program_Opp_ON_DECK_STAGES.contains(tempOpp.StageName))
                    flowControl = flowControl + CPQConstants.PROGRAM_OPP_INFO_SECTION_OPEN_ON_DECK_STAGE + ',';
                else if(CPQConstants.SET_Program_Opp_PIPELINE_CONTRACT_STAGES.contains(tempOpp.StageName))
                    flowControl = flowControl + CPQConstants.PROGRAM_OPP_INFO_SECTION_OPEN_ADVANCE_STAGE + ',' + CPQConstants.PROGRAM_OPP_MSND_ADVANCE + ',';
                else if(tempOpp.IsClosed)
                    flowControl = CPQConstants.PROGRAM_OPP_INFO_SECTION_CLOSED_STAGE + ',' + CPQConstants.PROGRAM_OPP_CLOSED_ADVANCE;
                
                //Add section detail in flow contol variable
                if(!tempOpp.IsClosed)
                    flowControl += CPQConstants.PROGRAM_OPP_OPEN_ADVANCE;
                
                //}
            }
        }
    }
    
    /**
     *  @description    :   This method is used to save the Program Opportunities
     *
     *  @args           :
     *
     *  @return         :   void
     *
     *  @revision Logs  :   Created - Subhash Garhwal - 06/28/2016 - CR-20160414-9762
     *
     **/
    public Pagereference doSave() {
        
        //Save Point to roll back changes
        Savepoint sp = Database.setSavepoint();
            
        try {
            
            //Check for Opportunity
            if(opp != null) {
                
                //Check for Parent Id
                if(String.isNotBlank(parentOppId)) {
                
                    //Check for Program
                    if(opp.Program__c != null) {
                        
                        //Query through record types
                        List<Program__c> program = [Select Id, Business_Line__c From Program__c Where Id =: opp.Program__c LIMIT 1];
                        
                        //Check for Program size
                        if(program.size() > 0) {
                            
                            //Get all the Opportunitt Record types
                            Map<String, Id> mapoppRecordTypeMap = Util.recordtypemap('Opportunity');
                            
                            //Check Business Line in map
                            if(CPQConstants.MAP_PROGRAM_OPP_RRECORD_TYPE_DN_WITH_PROGRAM_BL.containsKey(program[0].Business_Line__c)
                                && mapoppRecordTypeMap.containsKey(CPQConstants.MAP_PROGRAM_OPP_RRECORD_TYPE_DN_WITH_PROGRAM_BL.get(program[0].Business_Line__c)))
                                opp.RecordTypeId = mapoppRecordTypeMap.get(CPQConstants.MAP_PROGRAM_OPP_RRECORD_TYPE_DN_WITH_PROGRAM_BL.get(program[0].Business_Line__c));
                        }
                    }
                    
                    //Check for clone
                    if(String.isNotBlank(ApexPages.currentPage().getParameters().get('clone')) && ApexPages.currentPage().getParameters().get('clone') == '1') {
                        
                        //Instance of Opportunity
                        Opportunity cloneOpp = opp.clone();
                        
                        //Insert Cloned Opp
                        insert cloneOpp;
                        
                        //Return
                        return new Pagereference('/' +cloneOpp.Id);
                    
                    } else {
                        
                        //Upsert Opp
                        upsert opp;
                        
                        //Return
                        return new Pagereference('/' +opp.Id);
                    }
                } else {
                    
                    //Upsert Opp
                    upsert opp;
                    
                    //Return
                    return new Pagereference('/' +opp.Id);
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