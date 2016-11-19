public with sharing class IntranetPeopleController {

    public User UserData {get; set;}
    public String OfficeName {get; set;}
    //public String MapFileId {get; set;}
    //public Boolean renderMap {get; set;}
    public Intranet_Item__c UserOffice {get; set;}
    
    Id userId;
    
    public IntranetPeopleController(){
        
        //Get User Id
        userId = ApexPages.currentPage().getParameters().get('sfdc.userId');
        
        //Load the User Info
        findUserData();
        
    }
    
    public void findUserData(){
        
        //Get User if blank
        if(UserData == null){
            User U = [select Id, ABC_Department__c, ABC_Division__c, ABC_Function__c, Office__c, Workspace__c, Workspace_Floor__c, Workspace_Number__c, Workspace_Type__c 
                      from User where Id = :userId];
            UserData = U;
        }
        
        //Get User Office data if blank
        if(UserOffice == null){
            if(UserData.Office__c != null){
                Intranet_Item__c OfficeRecord = [select Id, Office_Name__c, Office_Short_Name__c, Location_Code__c from Intranet_Item__c where Id = :UserData.Office__c];
                
                //Set UserOffice and OfficeName
                UserOffice = OfficeRecord;
                OfficeName = OfficeRecord.Office_Short_Name__c;
            }
        }
    }
    
    public Id MapFileId{
        
        //Notes from http://salesforce.stackexchange.com/questions/16016/preview-chatter-file-in-visualforce/16017#16017
        get{
            if(MapFileId == null){
                if(UserOffice != null){
                    //Get the Ids for the latest version files linked to the Office record
                    List<Id> setFileLinks = new list<Id>();
                    List<ContentDocumentLink> fileLinks = [select ContentDocument.LatestPublishedVersionId from ContentDocumentLink where LinkedEntityId = :UserOffice.Id];
                    for(ContentDocumentLink fileLink : fileLinks){
                        setFileLinks.add(fileLink.ContentDocument.LatestPublishedVersionId);
                    }
                    
                    //Search the files for one matching Office and Floor
                    Id fileId;
                    for(ContentDocument doc : [select Id, Title from ContentDocument where LatestPublishedVersionId in :setFileLinks]){
                        try{
                            if(doc.Title.startsWith(UserOffice.Location_Code__c) && 
                               doc.Title.contains('Floor') &&
                               //if it has a value it may have a leading zero.  Need to covert to number value and then back to string to get rid of any leading zeros.
                               string.isNotEmpty(UserData.Workspace_Floor__c) && doc.Title.endsWith(string.valueOf(Integer.valueOf(UserData.Workspace_Floor__c)))){
                                   fileId = doc.Id;
                               }
                        }
                        catch (exception e) {
                        }
                    }
                    
                    ContentVersion[] latestVersionFile = [select Id from ContentVersion where ContentDocumentId = :fileId and isLatest = true];
                    
                    string filePathFull;
                    if(latestVersionFile.size() > 0){
                        MapFileId = latestVersionFile[0].Id;
                    }
                }else{
                    MapFileId = null;
                }
            }
            return MapFileId;
        }
        set;
    }
    
    public Boolean renderMap{
        get{
            return !(MapFileId == null);
        }
        set;
    }
}