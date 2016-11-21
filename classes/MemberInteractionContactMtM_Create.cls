/**
 *  Desription      :   Class to display all the contacts related to the Research Study Interaction’s Institution record and when a user 
                         selects a particular contact record then a mTM record will get created for that Research Study Interaction record.
 * 
 *  Created By      :   Ajit Surana
 * 
 *  Created Date    :   09/15/2014
 * 
 *  Revision Logs   :   V1.0 - Created
 *                  :   V1.1 - Modified By - Ajit Surana - 11/14/2014 - CR-20141106-8005 
 **/ 
public class MemberInteractionContactMtM_Create {

    /*Properties*/
    
    //List to hold Wrapper records
    private List<MTMWrapper> mtMWrapperList {get; set;}
    
    //List to hold the contacts
    private List<Contact> Contacts;
    
    //List to hold the research study interation records
    List<Syndicated_Research_Interaction__c> risList;
    
    //Map to hold Contact records corresponding to mTM record instance
    Map<Id, MemberInteractionContactMtM__c> mapConMtMIds = new Map<Id, MemberInteractionContactMtM__c>();
    
    //Pagereference variable
    Pagereference pageRef;
    
    //Variable to hold contract record Id selected by the user on VF page
    public Id selectedContact {get; set;}
    
    /*Pagination Variables*/
    
    //Standard set controller instance
    public ApexPages.StandardSetController con {get; set;}
    
    // returns a list of wrapper objects for the sObjects in the current page set
    public List<MTMWrapper> getCategories() {
        
        //Initializing wrapper list
        mtMWrapperList = new List<MTMWrapper>();
        
        //Loop through standard controller records
        for (Contact category : (List<Contact>)con.getRecords()) {
            
            //Checking for the value in the map
            if(mapConMtMIds.containsKey(category.Id))
                mtMWrapperList.add(new MTMWrapper(true, category));
            else
                mtMWrapperList.add(new MTMWrapper(false, category));
        }
        
        //Returning wrapper list
        return mtMWrapperList;
    }
    
    /*Sorting Variables*/
    
    public String sortDirection {get; set;}
    private String sortExp = 'Name';
    
    public String sortExpression {
        
        get {
            return sortExp;
        }
        
        set {
       
            //if the column is clicked on then switch between Ascending and Descending modes
            if (value == sortExp)
                sortDirection = (sortDirection == 'ASC')? 'DESC' : 'ASC';
            else
                sortDirection = 'ASC';
       
            sortExp = value;
        }
    }
    
    public String getSortDirection() {
        
        //if not column is selected 
        if (sortExpression == null || sortExpression == '')
            return 'ASC';
        else
            return sortDirection;
    }
    
    public void setSortDirection(String value) {  
        sortDirection = value;
    }

    //Class constructor
    public MemberInteractionContactMtM_Create() {
        
        sortDirection ='ASC';
        
        //Memory allocations to the list
        mtMWrapperList = new List<MTMWrapper>();
        
        //Checking for the parent Id value
        if(String.isNotBlank(ApexPages.currentPage().getParameters().get('parentId'))) {
        
            //Getting Account Id related to Research Study Interaction records
            risList = [SELECT Id, Institution__c FROM Syndicated_Research_Interaction__c WHERE Id =: ApexPages.currentPage().getParameters().get('parentId')];
            
            //Checking if we have records to process further
            if (risList != null && risList.size()>0){
            
                //Fetching data from database
                for(MemberInteractionContactMtM__c mICMtM: [Select Id, Contact__c, Research_Study_Interaction__c 
                                                              FROM MemberInteractionContactMtM__c
                                                                    WHERE Research_Study_Interaction__c =: risList[0].Id]) {
                    
                    //Populate map
                    mapConMtMIds.put(mICMtM.Contact__c, mICMtM);   
                }
                
                //Looping over the Contact records related to RSI
                for (Contact cont : Database.query('SELECT Id, Name, Title, Email, Phone FROM Contact WHERE AccountId != null AND AccountId = \''+risList[0].Institution__c +'\'')){
                
                    //Checking if set contains above Contact Id
                    if(mapConMtMIds.containsKey(cont.Id)){
                        mtMWrapperList.add(new MTMWrapper(true,cont));
                    }else{
                        mtMWrapperList.add(new MTMWrapper(false,cont));
                    }
                }
                
                init();
            }
        }
    }
    
    public void init(){
    
        //build the full sort expression
        string sortFullExp = sortExpression  + ' ' + sortDirection;
       
        //Memory allocations to the list
        mtMWrapperList = new List<MTMWrapper>();
        
        //query the database based on the sort expression
        contacts = Database.query('Select Id, Name, Title, Email, Phone from Contact WHERE AccountId != null AND AccountId = \''+risList[0].Institution__c +'\'  order by ' + sortFullExp + ' NULLS LAST');
       
        con = new ApexPages.StandardSetController(contacts);
        con.setPageSize(1000);
        
    }
    
    //Method to perform save over records
    public PageReference doSave() {
    
        try{
            //List to hold MTM records
            List<MemberInteractionContactMtM__c> memInteractionContactList = new List<MemberInteractionContactMtM__c>();
            
            //List to hold MTM records that need to be deleted
            List<MemberInteractionContactMtM__c> memInteractionContactsToDelete = new List<MemberInteractionContactMtM__c>();
            
            //Loop through Wrapper list and checking for the user selection
            for(MTMWrapper mtMWrap : mtMWrapperList) {
                
                if(mtMWrap.isSelected) {
                    if(mapConMtMIds.containsKey(mtMWrap.con.Id))
                        memInteractionContactList.add(mapConMtMIds.get(mtMWrap.con.Id));
                    else
                        memInteractionContactList.add(new MemberInteractionContactMtM__c(Research_Study_Interaction__c = ApexPages.currentPage().getParameters().get('parentId'), Contact__c = mtMWrap.con.Id));
                }else{
                    if(mapConMtMIds.containsKey(mtMWrap.con.Id))
                        memInteractionContactsToDelete.add(mapConMtMIds.get(mtMWrap.con.Id));
                }    
            }
            
            //Checking if list has records to process
            if(memInteractionContactList.size()>0){
                
                Util.byPassAllTriggers = true;
                database.upsert(memInteractionContactList,false);
                Util.byPassAllTriggers = false;
            }
                
            //Checking if list has records to process
            if(memInteractionContactsToDelete.size()>0){
                
                Util.byPassAllTriggers = true;
                database.delete(memInteractionContactsToDelete,false);
                Util.ByPassAllTriggers = false;
            }
                
        }catch(Exception ex) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, ex.getMessage()));
           
        }
        
        pageRef = new Pagereference('/' + ApexPages.currentPage().getParameters().get('parentId'));
        pageRef.setRedirect(true);
        return pageRef;     
    }
    
    //Method to handle the cancelling logic
    public Pagereference doCancel() {
        pageRef = new Pagereference('/' + ApexPages.currentPage().getParameters().get('parentId'));
        pageRef.setRedirect(true);
        return pageRef;
    }
    
    /*Pagination navigation related methods*/
    
    // indicates whether there are more records after the current page set.
    public Boolean hasNext {
        get {
            return con.getHasNext();
        }
        set;
    }
    
    // indicates whether there are more records before the current page set.
    public Boolean hasPrevious {
        get {
            return con.getHasPrevious();
        }
        set;
    }
    
    // returns the page number of the current page set
    public Integer pageNumber {
        get {
            return con.getPageNumber();
        }
        set;
    }
    
    // returns the first page of records
    public void first() {
        con.first();
    }
    
    // returns the last page of records
    public void last() {
        con.last();
    }
    
    // returns the previous page of records
    public void previous() {
         con.previous();
    }
    
    // returns the next page of records
    public void next() {
         con.next();
    }
    
    //Wrapper class
    public class MTMWrapper {
        
        //Properties
        public Boolean isSelected {get; set;}
        public Contact con {get; set;}
        
        //Constructor
        public mTMWrapper(Boolean isSelected, Contact con) {
            this.isSelected= isSelected;
            this.con= con;
        }
    }
}