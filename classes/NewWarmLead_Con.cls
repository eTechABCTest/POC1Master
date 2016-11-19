public with sharing class NewWarmLead_Con {
    /*
    Purpose:    Visualforce controller to handle 
                    conditional redirection of New Warm Lead Action
                    If New Warm Lead is OAB Recordtype, support creation of Warm Lead and OAB Lead Passer records.
    
    Created By:     Yogesh (SAP) - 11/2010
    
    Last Modified By:   Abhinav Sharma - 10/17/2014    
    Current Version:    v1.4
    
    Revision Log:       v1.0 - (Y) Created controller to support visualforce page
                        v1.1 - (JN 12/2010) Added redirect capability to allow creating OAB WL from same button as other recordtypes
                        v1.2 - (JN 4/28/11) Changed reference to hard coded Warm Lead object prefix to a string derived from Schema.describe action.
                        v1.3 - Bhavi Sharma - 04/18/2014 - Updated class to populate the campaign and Lead event field, when Warm Lead is being created from Campaign - CR-20140224-4597
                        v1.4 - Abhinav Sharma - 10/17/2014 - updated class to pre-populate grade and lead date field , when new warm lead has record type 'OAB' - CR-20140904-7233
                        v1.5 - Abhinav Sharma - 13/01/2015 - Did the URL Encoding - CR-20141110-8036 
    */
 
  // public properties
  public Warm_Lead__c WarmLead {get;set;}
  public String OABrtid;
  public List<OAB_Lead_Passer__c> listOAB {get;set;}
  
  string prefix = Warm_Lead__c.sobjectType.getDescribe().getKeyPrefix();
  String retURL; 
  
  public Warm_Lead_MtM__c Warm_Lead_MtM {get;set;}
  
  Opportunity opp;
  
  //Variable to hold the OAB record type Id value
  Id recordTypeOABId;
  
  // constructor
  public NewWarmLead_Con(ApexPages.StandardController stdController){
  
      //Added By Abhinav Sharma - 13/01/2015 - CR-20141110-8036
      //Start from here
      for (String key: ApexPages.CurrentPage().getParameters().keySet())
          ApexPages.CurrentPage().getParameters().put(key, EncodingUtil.urlEncode(ApexPages.CurrentPage().getParameters().get(key),'UTF-8')); 
      
      //Upto here
                  
    map<String, STring> parms = ApexPages.CurrentPage().getParameters();
    
    string WarmLeadRecordTypeId = null;
    string OABRecordTypeId = null;
    
    for(RecordType rt : [Select Id From RecordType Where Name = 'OAB' and SObjectType = 'Warm_Lead__c' AND IsActive = true]){
        OABrtid = rt.id;
        WarmLeadRecordTypeId = rt.Id;
        recordTypeOABId = rt.Id;
    }
    
    for(RecordType rt : [Select Id From RecordType Where Name = 'Standard' AND SObjectType = 'OAB_Lead_Passer__c' AND IsActive = true Limit 1]){
        OABRecordTypeId = rt.Id;
    }
    
    //Commented By Bhavi Sharma - 04/18/2014 - CR-20140224-4597
    //WarmLead = new Warm_Lead__c();
    
    //Added By Bhavi Sharma - 04/18/2014 - CR-20140224-4597
    if(stdController != null)
        WarmLead = (Warm_Lead__c)stdController.getRecord();
    else
        WarmLead = new Warm_Lead__c();
        
    WarmLead.Name = system.today().format() + ' New Warm Lead';
    WarmLead.Lead_Channel__c = 'OAB';
    WarmLead.Status__c = 'Pending';
    WarmLead.RecordTypeId = WarmLeadRecordTypeId;
    
    listOAB = new List<OAB_Lead_Passer__c>();
    
    for(integer i=0; i<4; i++){
        OAB_Lead_Passer__c oab = new OAB_Lead_Passer__c();
        
        oab.RecordTypeId = OABRecordTypeId;
        oab.Credit_Date__c = system.today();
        
        listOAB.add(oab);
    }
    
    
    if(ApexPages.CurrentPage().getParameters().get('OppId') != null){
        list<Opportunity> opps = [Select Id, AccountID, Account.Name, Program__c From Opportunity Where Id = : ApexPages.CurrentPage().getParameters().get('OppId') Limit 1];
        if (opps.size() > 0) {
            opp = opps[0];
            
            Warm_Lead_MtM = new Warm_Lead_MtM__c();
            Warm_Lead_MtM.Opportunity__c = opp.Id;
            
            WarmLead.Name = system.today().format();
            
            if(opp.Account.Name != null){
                WarmLead.Name = WarmLead.Name + '-' + opp.Account.Name;
            }
            WarmLead.Primary_Program__c = opp.Program__c;
            WarmLead.Account__c = opp.AccountID;
        }
    }
    
    retURL = ApexPages.CurrentPage().getParameters().get('retURL');
    
  }
  
  public PageReference DoCancel(){
    PageReference pageref = new PageReference('/home/home.jsp');
    if (opp != null) {
        pageref = new PageReference('/' + opp.id);
    } else {
        //Removed 4/28/11 JN
        //return new PageReference('/a0L');
        if (retURL != null) pageref = new PageReference(retURL);
    }   
    return pageref;
  }
  
  // Save warm lead and OAB lead passer
  public PageReference DoSave(){
    PageReference pr = null;
    
    Boolean AtLeastOneOAB = false;
    for(OAB_Lead_Passer__c oab : listOAB){
        if(oab.Passer__c != null) AtLeastOneOAB = true;
    }
    
    //Only do inserts if there's at least 1 AOB Lead Passer in the list
    if (AtLeastOneOAB) {
        try{
            // insert warm lead
            database.upsert(WarmLead, true);
            Warm_Lead__c tempWL = [select Id, Primary_Program__r.Program_Acronym__c from Warm_Lead__c where id = :WarmLead.id];
            
            List<OAB_Lead_Passer__c> listOABNew = new List<OAB_Lead_Passer__c>();
            
            set<id> passerids = new set<id>();
            for(OAB_Lead_Passer__c oab : listOAB) passerids.add(oab.Passer__c);
            map<id, Contact> passerid2conmap = new map<id, Contact>([select id, LastName from Contact where id in :passerids]);
            
            for(OAB_Lead_Passer__c oab : listOAB){
                if(oab.Passer__c != null){
                    oab.Warm_Lead__c = WarmLead.Id;
                    oab.Name = system.today().format() + ' - ' 
                        + ((opp != null) ? opp.Account.Name + ' - ' : '') 
                        + tempWL.Primary_Program__r.Program_Acronym__c + ' - ' 
                        + passerid2conmap.get(oab.Passer__c).LastName;
                        // check to make sure the name isn't too long
                        if (oab.Name.length() > 80)
                            oab.Name = oab.Name.subString(0,80);
                    listOABNew.add(oab);
                }
            }
            
            // insert OAB lead passers
            if(listOABNew.size() > 0){
                database.upsert(listOABNew, true);
            }
            
            //Insert Warm Lead MtM if we have enough info
            if(Warm_Lead_MtM != null){
                Warm_Lead_MtM.Warm_Lead__c = WarmLead.Id;
                
                database.upsert(Warm_Lead_MtM, true);
            }
            
            pr = new PageReference('/' +WarmLead.Id );
            
        } catch(Exception ex){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ex.getMessage()));   
        }
        
        
    } else { //else if AtLeastOneOAB
        //return error message
        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'You must specify at least one OAB Lead Passer.'));
    }
    return pr;
  }//end DoSave()
    
    public PageReference redirect()
    {
        PageReference pr = null;

        //if not "OAB" recordtype, redirect to standard New page
        if (ApexPages.CurrentPage().getParameters().get('oppid') == null) //(ApexPages.CurrentPage().getParameters().get('RecordType') != OABrtid.substring(0,15)) {
        {
            String newpageref = '/' + prefix + '/e'; //?Name=' + system.today().format() + ' New Warm Lead&nooverride=1';
            
            if ((retURL != null) && (retURL.contains('eid='))) {
                retURL = '/' + (retURL.split('eid=',0))[1].substring(0,15);
            }
            
            //Removed 4/28/11 JN
            //newpageref += '&RecordType=' + ApexPages.CurrentPage().getParameters().get('Recordtype');
            //Restored 7/28/11 DAF
            newpageref += '?RecordType=' + ApexPages.CurrentPage().getParameters().get('Recordtype');

            system.debug('\n\nnewpageref ' + newpageref);           
            pr = new PageReference(newpageref);
            pr.getParameters().put('Name', system.today().format() + ' New Warm Lead');
            pr.getParameters().put('retURL', retURL);
            
            pr.getParameters().put('nooverride', '1');
        
            //Added By Bhavi Sharma - 04/18/2014 - CR-20140224-4597
            //Check if warm lead's campaign is not null, then populate the campaign data on Warm Lead
            if(WarmLead.Campaign__c != null) {
                
                //Fetch campaign data
                List<Campaign> campaigns = [Select Channel__c from Campaign where Id =: WarmLead.Campaign__c AND Channel__c != null limit 1];
                if(campaigns.size() > 0) {
                    
                    //Get WarmLead's Lead Event Field Id from Custom Setting
                    List<Configuration_Manager__c> config = [Select Parameter_Value__c from Configuration_Manager__c where Parameter_Key__c =: Constants.WL_LEAD_EVENT_SCHEMA_ID AND Parameter_Value__c != null LIMIT 1];
                    
                    if(config.size() > 0) {
                        
                        //Check if schema id is defined , then put it in request parameter
                        pr.getParameters().put(config[0].Parameter_Value__c, campaigns[0].Channel__c);
                    }
                }
            }
             
            //Loop throgh the remaining page parameters and put all them back in URL
            for(String key : ApexPages.currentPage().getParameters().keyset()) {
                
                //Remove the unnecessary parameters from the page request URL
                if(key != 'sfdc.override' && key != 'scontrolCaching' && key != 'save_new')
                    pr.getParameters().put(key, ApexPages.currentPage().getParameters().get(key));        
            }
            
            //Added By Abhinav Sharma - 10/17/2014 - CR-20140904-7233
            //Start FROM Here
            //Check if current record type is "OAB" then pre-populate Grade and lead date field 
            if(ApexPages.CurrentPage().getParameters().get('Recordtype') == recordTypeOABId) {
                pr.getParameters().put('00NC00000055phC', '2');
                String todaysDate = String.valueOf(System.today().month()) + '/' + String.valueOf(System.today().day()) + '/' + String.valueOf(System.today().year());
                pr.getParameters().put('00NC00000055phN', todaysDate);
            }
            //Upto Here
        } 
        
        return pr;
    }
}