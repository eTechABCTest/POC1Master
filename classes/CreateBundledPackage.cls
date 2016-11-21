//Will delete in future release
public class CreateBundledPackage {
    public CreateBundledPackage(ApexPages.StandardController controller) {
    }
}

/*
    Purpose:            To allow the user to created bundled packages - supports CreateBundledPackage VF page
    Created By:         Drew Freeman
    Last Modified By:   Drew Freeman - 02-10-12
    Current Version:    v1.0
    Revision Log:       v1.0 - (DF) Created code
                        v1.1 - (Bhavi) - Modifed error messages - CR-20121127-1794
                        v1.2 - Modified by - Abhinav Surana - 09/15/2014 - CR-20140429-5272 - Updated the class name with 'zzz' prefix
                        v1.3 - Abhinav Sharma - Modified to removed the existing Bundle_Parent__c references & commenting of it - 09/15/2014 - CR-20140429-5272
*/

    /* public String ID {get; set;}
     public String ProgName {get; set;}
     public List<Program__c> progs {get; set;}
     public Opportunity o {get; set;}
     public Boolean err {get; set;}

    public CreateBundledPackage(ApexPages.StandardController controller) {

    ID = System.currentPageReference().getParameters().get('oid');
    if (ID == null) {return;}

    //Modified By - Abhinav Sharma - 09/15/2014 - CR-20140429-5272 - Removed the existing Bundle_Parent__c references
    o = [select StageName, CloseDate, Program__r.Id, Is_the_Evaluation_Competitive__c, Program__r.Business_line__c, Program__r.Available_to_Bundle__c, Program__r.Program_Formal_Name__c, Program__r.Program_Acronym__c, program__r.create_memberships__c  from Opportunity where Id = :ID];

    System.debug('***** BUSINESS LINE: ' + o.Program__r.Business_line__c);
    ProgName = o.Program__r.Program_Acronym__c + ' - ' + o.Program__r.Program_Formal_Name__c;
    
    err = false;
    if (o.program__r.create_memberships__c != 'No') {
      // opp's program says it can't be bundled
      ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR, Label.ERROR_NO_PROGRAM_AVAILABLE_TO_BUNDLE_WITH_YES);
          ApexPages.addMessage(msg);
      err = true;
      return;
    }
    
    if (!o.Program__r.Available_to_Bundle__c) {
      // opp can't be bundled - no bundle program on it now
      ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR, Label.ERROR_NO_EVALUATION_OPPTY_AS_PROGRAM_NA_TO_BUNDLE);
          ApexPages.addMessage(msg);
      err = true;
      return;
    }
    if (o.Program__r.Business_line__c == null) {
      // no program on opp message
        ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR, Label.ERROR_PROGRAM_NA_BLANK_BUSINESS_LINE);
            ApexPages.addMessage(msg);
      err = true;
      return;
    }

    Map<Id, Program__c> progmap = new Map<Id, Program__c>([select Id, Presented__c, Evaluated__c, Program_Formal_Name__c, Program_Acronym__c, Business_line__c, Bundle_ID__c,    
      Bundled_Opportunity_ID__c from Program__c where Business_line__c = :o.Program__r.Business_line__c and Available_to_Bundle__c = true and Id != :o.Program__r.Id]);
//    Set<Id> progIDs = new Set<Id>();
//    for (Integer i = 0; i < progs.size(); i++) {
//      progIDs.add(progs[i].Id);
//    }

    String soql = getFields('Bundle_MTM__c','Parent_Opportunity__c = \'' + ID + '\'');
    List<Bundle_MTM__c> bunmtm = Database.query(soql);
    Program__c currprog; 
    if (bunmtm.size() > 0) {
      for (Bundle_MTM__c b : bunmtm) {
        if (progmap.containsKey(b.Program__c)) {
          currprog = progmap.get(b.Program__c); 
          currprog.Bundle_ID__c = b.Id;
          if (b.Bundled_Opportunity__c != null) {
//            currprog.Editable__c = false;
            currprog.Evaluated__c = true;
            currprog.Presented__c = true;
            currprog.Bundled_Opportunity_ID__c = b.Bundled_Opportunity__c;
          }
          if (b.Presented__c) {
            currprog.Presented__c = true;
          }
          progmap.put(b.Program__c, currprog);
        }
      }  
    }

    progs = progmap.values();
    return;
    }

    //
    public PageReference clickPresented() {
    for (Program__c p : progs) {
      if (p.Evaluated__c) {
        p.Presented__c = true;
      }
      if (p.Bundled_Opportunity_ID__c != null) {
        p.Evaluated__c = true;
        p.Presented__c = true;
      }
    }
    return null;
    }


  public PageReference DoClone() {

    If (err) {return null;}  // if they press the create button when there's an error
    
    Boolean OppAlreadyCreated = false;
    for (Program__c p : progs) {
      if (p.Evaluated__c) {
        p.Presented__c = true;
      }
      if (p.Bundled_Opportunity_ID__c != null) {
        p.Evaluated__c = true;
        p.Presented__c = true;
        OppAlreadyCreated = true;
      }
    }

    String soql = getFields('Opportunity','Id = \'' + ID + '\'');
    Opportunity o = (Opportunity)Database.query(soql);
    List<Opportunity> insOpp = new List<Opportunity>();
    for (Program__c p :progs) {
      if ((p.Evaluated__c) && (p.Bundled_Opportunity_ID__c == null)) {  // no opp created for this one yet
        Opportunity cloneOpp = new Opportunity();
        cloneOpp = o.clone(false, true);
        //Commented By - Abhinav Sharma - 09/02/2014 - CR-20140429-5272 - Removed the existing Bundle_Parent__c references
        //cloneOpp.Bundle_Parent__c = ID;
        cloneOpp.Program__c = p.Id;
        cloneOpp.StageName = 'Active in Fasttrack';
        cloneOpp.Is_there_are_hard_next_step__c = 'Yes';
        cloneOpp.Are_They_Evaluating__c = 'Yes';
        cloneOpp.Marketing_Warming_Effort__c = null;
        // VH 9/26/13 CR-2992
        if (cloneOpp.Is_the_Evaluation_Competitive__c == null)
          cloneOpp.Is_the_Evaluation_Competitive__c = 'Null';
        // ADDED LINES 135-138 BY TSCONIERS PER CR-20120829-1434
        Pattern parentNamePattern = Pattern.compile('\\-\\W[A-Z]{3,5}');
        Matcher parentNameMatcher = parentNamePattern.matcher(cloneOpp.Name);
        String childName = parentNameMatcher.replaceFirst('- '+p.Program_Acronym__c);
        cloneOpp.Name = childName;
        insOpp.add(cloneOpp);        
      }
    }
    
    Util.IsBatch = true;
    // insert child opps
    try {
      for (Integer i = 0; i < insOpp.size(); i++) {
        if (!insOpp[i].Owner.IsActive)
          insOpp[i].OwnerId = Userinfo.getUserId();
      }
      
      insert insOpp;
    } catch (DMLException e) {  // error - try to fix owner to current user
      for (Integer i = 0; i < insOpp.size(); i++) {
        insOpp[i].OwnerId = Userinfo.getUserId();
      }
      try {  // try again to save child opps
        insert insOpp;
      } catch (DMLException e2) {  // still has an error, report it
        ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR, e2.getMessage());
            ApexPages.addMessage(msg);
        return null;
      }        
    }
    //Util.IsBatch = false;
    
    Id boID;
    Integer n = 0;
    List<Bundle_MTM__c> upsBundle = new List<Bundle_MTM__c>();
    List<Bundle_MTM__c> delBundle = new List<Bundle_MTM__c>();
    for (Program__c p :progs) {
      if ((!p.Presented__c) && (p.Bundle_ID__c != null) && (p.Bundled_Opportunity_ID__c == null)) {  // bundle MTM was created now not wanted, no opps, delete it
        delBundle.add(new Bundle_MTM__c(Id = p.Bundle_ID__c));
        continue;
      }
      if (p.Presented__c) {
        boID = p.Bundled_Opportunity_ID__c;  // either the existing opp id or null
        if ((p.Evaluated__c) & (p.Bundled_Opportunity_ID__c == null)) {  // no opp created yet
          boID = insOpp[n].Id;
          n += 1;
        }
        upsBundle.add(new Bundle_MTM__c(Id = p.Bundle_ID__c, Parent_Opportunity__c = ID, Bundled_Opportunity__c = boID, Program__c = p.Id, Evaluated__c = p.Evaluated__c, Presented__c = p.Presented__c));
      }
    }
    upsert upsBundle;
    delete delBundle;
  
    if (insOpp.size() > 0) {

      if (!OppAlreadyCreated) { 
        o.CloseDate = date.today();
        o.StageName = 'Closed Lost';
        o.Primary_Reason_Lost__c = 'Evaluations Moved to Evaluation Opps';
        o.Marketing_Warming_Effort__c = 'NO';
        update o;
            
      }

      List<OpportunityContactRole> insOCR = new List<OpportunityContactRole>();
      soql = getFields('OpportunityContactRole','OpportunityId = \'' + ID + '\'');
      List<OpportunityContactRole> ocr = Database.query(soql);
      for (Opportunity op: insOpp) {
        for (OpportunityContactRole oc : ocr) {
          OpportunityContactRole cloneOCR = oc.clone(false, true);
          cloneOCR.OpportunityId = op.Id;
          insOCR.add(cloneOCR);
        }
      }
      insert insOCR;
  
      List<Warm_Lead_MtM__c> insWLM = new List<Warm_Lead_MtM__c>();
      soql = getFields('Warm_Lead_MtM__c','Opportunity__c = \'' + ID + '\'');
      List<Warm_Lead_MtM__c> wlm = Database.query(soql);
      for (Opportunity op: insOpp) {
        for (Warm_Lead_MtM__c wl : wlm) {
          Warm_Lead_MtM__c cloneWLM = wl.clone(false, true);
          cloneWLM.Opportunity__c = op.Id;
          insWLM.add(cloneWLM);
        }
      }
      insert insWLM;
    } // if insOpp > 0
    
    Util.IsBatch = false;
    
    PageReference pageRef = new PageReference('/' + ID);
        return pageRef;
  }

  // Return's the page to it's detail view.
  public PageReference Cancel() {
    PageReference pageRef = new PageReference('/' + ID);
        return pageRef;
  }

  // This is a utility field that creates a query for all fields in a given object.
  // TODO: THIS METHOD SHOULD BE MOVED TO A UTILITY CLASS.
  public static string getFields(String objectName, String whereClause){ 

    String selects = ''; 
    if (whereClause == null || whereClause == ''){ return null; } 
    // Get a map of field name and field token 
    Map<String, Schema.SObjectField> fMap = Schema.getGlobalDescribe().get(objectName.toLowerCase()).getDescribe().Fields.getMap(); 
    list<string> selectFields = new list<string>(); 
    if (fMap != null){ 
      for (Schema.SObjectField ft : fMap.values()){ // loop through all field tokens (ft) 
        Schema.DescribeFieldResult fd = ft.getDescribe(); // describe each field (fd) 
        if (fd.isCreateable()){ // field is creatable 
          selectFields.add(fd.getName()); 
        } 
      } 
    } 
    if (!selectFields.isEmpty()){ 
      for (string s:selectFields){ 
        selects += s + ','; 
      } 
      if (selects.endsWith(',')){selects = selects.substring(0,selects.lastIndexOf(','));} 
    } 
    return 'SELECT ' + selects + ' FROM ' + objectName + ' WHERE ' + whereClause; 
  } 
}*/