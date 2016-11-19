/**
 * Description  :   Controller class for ModifyGoals Visualforce Page.
 * 
 * Created By   :   Rajeev Jain
 * 
 * Created Date :   02/17/2015 - CR-20160115-9542
 * 
 * Revision Log :   V_1.0 - Created
 *              :   V_1.1 - Modified - Rajeev Jain - 04/15/2016 - ISSP Deployment E - CR-20160302-9661
 * 
 * */
public without sharing class ModifyGoalsController {
    
    /* List to hold personal Goal Records
     * Will used in Grid on the page to display of one or more PGs identified in the calling environment. 
     * Multiple PGs may be selected from either a list view or a related list on the Personal Plan, 
     * Goal Template, or Goal Template Details objects.
     * */
     //This list can be modified on the page
    public List<Personal_Goal__c> filteredPgs {get;set;}
    
    //This list will be used only for when option is void selected on the page
    private List<Personal_Goal__c> filteredPgsForVoid {get;set;}
    
    //Perosnal Goal Status Set, which will decide to filte the Perosnal Goal filter list on the Screen
    public Static Set<String> PERSONAL_GOAL_STATUS = new Set<String>{'Available', 'Pending', 'Payee Approved'};
    
    //PG Void Submtted Status
    public final static String PERSONAL_GOAL_STATUS_VOID_SUBMITTED = 'Void Submitted';
    
    //Property to Hold selected fielter value
    public String selectedFilterValue{get;set;}
    
    //Blank Perosnal Goal Instance to show some fiter option, like Start and End Date
    public Personal_Goal__c personalGoal{get;set;}
    
    //Boolean value, which states if User submitted for plan managmeent
    public Boolean isSubmitForPlanManagement{get;set;}
    
    //Option 2 Next Step text, display when option 2 is selected on the screen
    public Static String createNexProposalText{
        get{
            if(createNexProposalText == null)
                createNexProposalText = 'you\'ll be taken the create Goals page, where you can adjust the proposals as needed'; 
            return createNexProposalText;
        }
    } 
    
    //Hold filtered list size which used to enable and disable filter option on the Screen.
    public static Integer filteredSize = 0;
    
    //Hold Page Return URL
    private String returnURL;
    
    //Static List of Select Option, which will be treadted as Radio Button on the Screen
    public Static List<SelectOption> pgFilterOptions{
        
        get{
            if(pgFilterOptions == null){
                pgFilterOptions = new List<SelectOption>();
                pgFilterOptions.add(new SelectOption('Cancel','Cancel : make no change'));
                if(filteredSize == 0){
                    
                    pgFilterOptions.add(new SelectOption('Create','Create new proposal(s)',true));
                    pgFilterOptions.add(new SelectOption('Modify','Modify date(s)/Supersedes',true));
                    pgFilterOptions.add(new SelectOption('Void','Void goal(s)',true));
                }else{
                    pgFilterOptions.add(new SelectOption('Create','Create new proposal(s)',false));
                    pgFilterOptions.add(new SelectOption('Modify','Modify date(s)/Supersedes',false));
                    pgFilterOptions.add(new SelectOption('Void','Void goal(s)',false));
                }
            }
            return pgFilterOptions;
        }
    }
    
    //Constructor - Inititalized when called from Detail Page Button/ Edit Override
    public ModifyGoalsController(ApexPages.StandardController controller) {
        
        //Tem instance for PG
        Personal_Goal__c pg;
        
        //Get Record to be modified
        pg = (Personal_Goal__c)controller.getRecord();
        
        //Initialize Page Properties
        selectedFilterValue = 'Cancel';
        
        //Perosnal Goal Instance to hold the some date filter option
        personalGoal = new Personal_Goal__c();
        
        //Check to show if the all pgs in grid are eligible for Submitted Status
        isSubmitForPlanManagement = true;
                                
        //Check if Pg is Qualified to add in filtered list or not
        if(pg != null){
            
            //Filter the Record based on Some Criteria
            filteredPgs = [select Id, Name, Payee__c, Payee__r.Name, Primary_Goal__c, Primary_Goal__r.Active_Proposal__c, Active__c, Standard_Goal__c, Standard_Goal__r.Name, Standard_Goal_Detail__c, Goal_Type__c, Supersedes__c, Active_Proposal__c,
                                    Parent_Personal_Goal__c, Period_End__c, Period_Start__c, Personal_Plan__c, Status__c, Submission_Status__c
                                    from Personal_Goal__c where Id = :pg.Id AND (Status__c IN :PERSONAL_GOAL_STATUS OR Status__c Like '%Submitted%')
                                        AND RecordType.DeveloperName = :ISSPConstants.PERSONAL_GOAL_RECORD_TYPE_PROPOSAL order By Payee__r.Name, Standard_Goal__r.Name ASC];
                                        
            //Populate Personal Goal Instance which is used for applying Global action using 3rd option on the Page, with current personal Goal coming through the URL.
            if(filteredPgs.size() > 0 )
                personalGoal = filteredPgs[0];
            
            filteredPgsForVoid = filteredPgs;
            
            //Populate min and max filter options
            populateMinAndMaxEndDates();
            
            //Get Goal Template key prefix
            returnURL = '/' + pg.Id;    
        }
        //Get List Size
        filteredSize = filteredPgs.size();
    }
    //Constructor - Inititalized when called from List view button either on realted list or list view
    public ModifyGoalsController(ApexPages.StandardSetController controller) {
        
        //Hold List of Personal Goal
        //Get Record
        List<Personal_Goal__c> selectedPGs = (List<Personal_Goal__c>)controller.getSelected();
        
        
        //Initialize Page Properties
        selectedFilterValue = 'Cancel';
        personalGoal = new Personal_Goal__c();
        isSubmitForPlanManagement = true;
        
        if(selectedPGs != null && selectedPGs.size() > 0){
            
            //Initialize
            filteredPgs = [select Id, Name, Payee__c, Payee__r.Name, Primary_Goal__c, Primary_Goal__r.Active_Proposal__c, Active__c, Standard_Goal__c, Standard_Goal__r.Name, Standard_Goal_Detail__c, Goal_Type__c, Supersedes__c, Active_Proposal__c,
                                    Parent_Personal_Goal__c, Period_End__c, Period_Start__c, Personal_Plan__c, Status__c, Submission_Status__c
                                    from Personal_Goal__c where Id IN :selectedPGs AND (Status__c IN :PERSONAL_GOAL_STATUS OR Status__c Like '%Submitted%')
                                        AND RecordType.DeveloperName = :ISSPConstants.PERSONAL_GOAL_RECORD_TYPE_PROPOSAL order By Payee__r.Name, Standard_Goal__r.Name ASC];
            
            filteredPgsForVoid = filteredPgs;
            
            populateMinAndMaxEndDates();
            
            filteredSize = filteredPgs.size(); 
        }
        
        returnURL = ApexPages.currentPage().getParameters().get('retURL');
        
        if(String.isBlank(returnURL))
            returnURL = '/' + Personal_Goal__c.sObjectType.getDescribe().getKeyPrefix();    
    }
    
    /**
     *  @description    :   This method is used to Populate Min Start Date and Max End Date filter Option on the Screen
     *
     *  @args           :
     *
     *  @return         :   void
     *
    **/
    private void populateMinAndMaxEndDates(){
        
        if(filteredPgs.size() > 0 ){
            
            Date minStartDate, maxEndDate;
            
            minStartDate = filteredPgs[0].Period_Start__c;
            maxEndDate = filteredPgs[0].Period_End__c;
            
            //Populate Min and Max Date on Personal Goal Instance which used for filtering based on start and end dates
            for(Integer i=1;i<filteredPgs.size();i++){
                
                //Check lowest start date   
                if(filteredPgs[i].Period_Start__c < minStartDate)
                    minStartDate = filteredPgs[i].Period_Start__c;
                if(filteredPgs[i].Period_End__c > maxEndDate)
                    maxEndDate = filteredPgs[i].Period_End__c;          
            }
            
            //Populate Min and Max
            personalGoal.Period_Start__c = minStartDate;
            personalGoal.Period_End__c = maxEndDate;
        }
    }
    
    /**
     *  @description    :   Page Action Method - Run Based on Fitler Option selected on the screen
     *
     *  @args           :
     *
     *  @return         :   void
     *
    **/
    public PageReference proceedWithSelection(){
        
        //Blank Page Reference, populate based on what selected user on the screen.
        PageReference pageReference;
        
        //Save Point to roll back changes
        Savepoint sp = Database.setSavepoint();
        
        try{
            
            if(selectedFilterValue.equalsIgnoreCase('Cancel')){
                if(String.isNotBlank(returnURL))
                    pageReference = new PageReference(returnURL);   
                    
            }else if(selectedFilterValue.equalsIgnoreCase('Create')){
                Personal_Goal__C pg = filteredPgs != null && filteredPgs.size() > 0 ? filteredPgs[0] : new Personal_Goal__C();
                
                pageReference = new PageReference('/apex/CreatePersonalGoalsFromStdGoal?id=' + pg.Standard_Goal__c + '&payeeId=' + pg.Payee__c);
            }else if(selectedFilterValue.equalsIgnoreCase('Modify')){
                
                //Check for Valid Start and End Date
                if(personalGoal.Period_Start__c == null){
                    
                    displayErorMessage('Start date must be populated'); 
                    return null;
                }else{
                    
                    //List to Hold Goal Snapshot
                    List<Personal_Goal__c> goalSnapShots = new List<Personal_Goal__c>();
                    
                    //Loop over each of the Pg, Populates Submitted Status, if User Selected isSubmitForPlanManagement checkbox as true on the screen.
                    if(isSubmitForPlanManagement){
                        
                        for(Personal_Goal__c pgGoal : filteredPgs){
                            
                            pgGoal.Period_Start__c = personalGoal.Period_Start__c;
                            pgGoal.Period_End__c = personalGoal.Period_End__c;  
                            //pgGoal.Supersedes__c = personalGoal.Supersedes__c;
                            pgGoal.Status__c = ISSPConstants.PERSONAL_GOAL_STATUS_SUBMITTED;
                            
                            if(pgGoal.Primary_Goal__c != null){
                                goalSnapShots.add(new Personal_Goal__c(Id = pgGoal.Primary_Goal__c, Period_Start__c = personalGoal.Period_Start__c, Period_End__c = personalGoal.Period_End__c, Status__c = ISSPConstants.PERSONAL_GOAL_STATUS_SUBMITTED)); 
                            }
                        }   
                    }else{
                        
                        for(Personal_Goal__c pgGoal : filteredPgs){
                            
                            pgGoal.Period_Start__c = personalGoal.Period_Start__c;
                            //pgGoal.Supersedes__c = personalGoal.Supersedes__c;
                            pgGoal.Period_End__c = personalGoal.Period_End__c;
                            
                            if(pgGoal.Primary_Goal__c != null){
                                goalSnapShots.add(new Personal_Goal__c(Id = pgGoal.Primary_Goal__c, Period_Start__c = personalGoal.Period_Start__c, Period_End__c = personalGoal.Period_End__c));   
                            }   
                        }
                    }
                    
                    //Update all proposed goal
                    update filteredPgs; 
                    
                    //Update Goal Snapshot
                    update goalSnapShots;
                    
                    //Create Page Reference and Redirect To Calling URL
                    if(String.isNotBlank(returnURL))
                        pageReference = new PageReference(returnURL);             
                }
            }else if(selectedFilterValue.equalsIgnoreCase('Void')){
                
                //Goal snapshots for void
                List<Personal_Goal__c> snapshotsForVoid = new List<Personal_Goal__c>();
                
                //Set to hold the snapshot Ids
                Set<Id> setSSIds = new Set<Id>();
                
                //Loop over each Pg and change the status to void then update all
                for(Personal_Goal__c pgGoal : filteredPgsForVoid){
                    
                    /*** 03/02/2016 - QA issue fix, this will not match with current SDD update**/
                    if(pgGoal.Status__c == ISSPConstants.PERSONAL_GOAL_STATUS_SUBMITTED){
                        pgGoal.Status__c = ISSPConstants.PERSONAL_GOAL_STATUS_AVAILABLE;
                        
                        //Check for SS
                        if(!setSSIds.contains(pgGoal.Primary_Goal__c)) {
                            
                            //Check for Perposed goal
                            if(pgGoal.Active__c && pgGoal.Primary_Goal__c != null && pgGoal.Primary_Goal__r.Active_Proposal__c == pgGoal.Id) {
                                
                                //Add SS Id in set
                                setSSIds.add(pgGoal.Primary_Goal__c);
                                
                                //Add 
                                snapshotsForVoid.add(new Personal_Goal__c(Id = pgGoal.Primary_Goal__c, Status__c = ISSPConstants.PERSONAL_GOAL_STATUS_AVAILABLE));
                            }
                        }
                    }else if(pgGoal.Status__c == ISSPConstants.PERSONAL_GOAL_STATUS_PAYEE_APPROVED || pgGoal.Status__c == ISSPConstants.PERSONAL_GOAL_STATUS_PENDING){
                        pgGoal.Status__c = PERSONAL_GOAL_STATUS_VOID_SUBMITTED;
                        
                        //Check for SS
                        if(!setSSIds.contains(pgGoal.Primary_Goal__c)) {
                            
                            //Check for Perposed goal
                            if(pgGoal.Active__c && pgGoal.Primary_Goal__c != null && pgGoal.Primary_Goal__r.Active_Proposal__c == pgGoal.Id) {
                                
                                //Add SS Id in set
                                setSSIds.add(pgGoal.Primary_Goal__c);
                                
                                //Add 
                                snapshotsForVoid.add(new Personal_Goal__c(Id = pgGoal.Primary_Goal__c, Status__c = PERSONAL_GOAL_STATUS_VOID_SUBMITTED));
                            }
                        }
                    }
                }
                //update data
                update filteredPgsForVoid;
                
                //Update Snapshot as well
                update snapshotsForVoid;
                
                if(String.isNotBlank(returnURL))
                    pageReference = new PageReference(returnURL);
            }
        
        }catch(Exception e){
            
            //Roll Back changes
            Database.rollback(sp);
            
            displayErorMessage(e+'');
        }
        
        return pageReference;
    } 
    
    /** Display Error Message on the Page **/
    public void displayErorMessage(String msg){
        
        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, msg));
    }
}