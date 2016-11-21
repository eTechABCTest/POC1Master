/** 
  * Description     :   This class is to assign Case Team to Related case records of the Member support object
  *
  * Created By      :   Rajeev Jain(Simplyforce)
  *
  * Created Date    :   03/17/2016
  *
  * Version         :   V1.0 Created
  * 
  **/
public without sharing class MemberSupportCaseTeamMembersController {
    
    public Site_Issue__c memberSupport{get;set;}
    public List<CaseTeamMember> caseTeams{get;set;}
    public String retURL {get;set;}
    public List<CaseTeam> caseTeamList{get;set;}
    private List<Site_Issue__c> memberSupportList;
    public CaseTeamTemplateRecord caseTemplate{get;set;}
    public String caseTeamId{get;set;}
    
    //Class Constructor
    public MemberSupportCaseTeamMembersController(ApexPages.StandardController controller){
        
        //Get Record
        memberSupport = (Site_Issue__c)controller.getRecord();
        
        //Issue List
        memberSupportList = [select Id, Case__c from Site_Issue__c where Id = :memberSupport.Id];
        
        //Get Goal Template key prefix
        retURL = memberSupport.Id; 
        
        //Query on CaseTeamMemberObject based on Member Id passed in URL
        /*caseTeams = [select Id, ParentId, MemberId, Member.Name, TeamRoleId, TeamRole.Name,
                     TeamRole.AccessLevel, TeamRole.PreferencesVisibleInCSP
                     from CaseTeamMember where ParentId = :memberSupportList[0].Case__c];*/
        caseTemplate = new CaseTeamTemplateRecord();
        
        populateCaseTeam();
    }
    public Integer selectedRow{get;set;}
    
    private void populateCaseTeam(){
        
        List<CaseTeamTemplateRecord> caseTeamTemplates = [Select id, TeamTemplateId, ParentId, TeamTemplate.Id, TeamTemplate.Name, 
                                        TeamTemplate.Description From CaseTeamTemplateRecord  
                                        where ParentId = :memberSupportList[0].Case__c];
        
        //Prepare case Team List
        caseTeamList = new List<CaseTeam>();
        
        //check size
       if(caseTeamTemplates.size() > 0){
           Integer rowIndex = 0;
            for(CaseTeamTemplateRecord caseTeamTemplate : caseTeamTemplates){
                
                caseTeamList.add(new CaseTeam(caseTeamTemplate.Id, caseTeamTemplate.TeamTemplate.Name, caseTeamTemplate.TeamTemplateId, 
                                              null, 'Team',
                                             '-', true, caseTeamTemplate.ParentId, rowIndex));
                rowIndex++;
            }
        }
    }
    public void removeCaseTeam(){
        try{
            
            if(selectedRow != null && selectedRow <= caseTeamList.size() && caseTeamList[selectedRow] != null){
                
                CaseTeamTemplateRecord caseTemplate = new CaseTeamTemplateRecord(Id = caseTeamList[selectedRow].caseTeamId);
                delete caseTemplate;
                
                populateCaseTeam();
            }    
        }catch(Exception e){displayErrorMessages(e + '');}
    }
    
    public void addCaseTeam(){
        try{
            if(String.isNotBlank(caseTeamId) && memberSupportList[0].Case__c != null){
                
                //Create New Case Team record
                CaseTeamTemplateRecord caseTemplate = new CaseTeamTemplateRecord(ParentId = memberSupportList[0].Case__c, TeamTemplateId = caseTeamId);
                insert caseTemplate;
                populateCaseTeam();
            }
        }catch(Exception e){displayErrorMessages(e + '');}
    }
    
    /**
     *  @description    :   These method is used to display Error Messages on Page.
     *
     *  @args           :   Error Message as a String
     *
     *  @return         :   void
     *
     **/
     public static void displayErrorMessages(String msg){
        
        ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,msg);            
        ApexPages.addMessage(myMsg);        
     } 
    
    //Wrapper class to hold the Case Team Properties
    public class CaseTeam{
        
        public Id caseTeamId{get;set;}
        public String teamMemberName{get;set;}
        public Id teamMemberId{get;set;}
        public Id caseTeamRoleId{get;set;}
        public String caseTeamRoleName{get;set;}
        public String caseTeamRoleAccessLevel{get;set;}
        public Boolean caseTeamRolePreferenceVisibleInCSP{get;set;}
        public Id caseTeamParentId{get;set;}
        public Integer rowIndex{get;set;}
        //Class constructor
        public CaseTeam(Id caseTeamId, String teamMemberName, Id teamMemberId, Id caseTeamRoleId, String caseTeamRoleName, String caseTeamRoleAccessLevel, Boolean caseTeamRolePreferenceVisibleInCSP, Id caseTeamParentId, Integer rowIndex){
            
            this.caseTeamId = caseTeamId;
            this.teamMemberName = teamMemberName;
            this.teamMemberId = teamMemberId;
            this.caseTeamRoleId = caseTeamRoleId;
            this.caseTeamRoleName = caseTeamRoleName;
            this.caseTeamRoleAccessLevel = caseTeamRoleAccessLevel;
            this.caseTeamRolePreferenceVisibleInCSP = caseTeamRolePreferenceVisibleInCSP;
            this.caseTeamParentId = caseTeamParentId;
            this.rowIndex = rowIndex;
        }
    }
}