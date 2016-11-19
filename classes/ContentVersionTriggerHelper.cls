/**
 *  Description     :   Helper class for ContentVersion object trigger i.e. Trigger_ContentVersion
 * 
 *  Created By      :   Abhinav Sharma    
 * 
 *  Created Date    :   09/01/2016
 * 
 *  Revision Logs   :   V_1.0 - Created - CR-20160224-9640
 *
**/ 
public without sharing class ContentVersionTriggerHelper {
    
    //Added By - Abhinav Sharma - CR-20160224-9640 - 09/01/2016
    /**
     *  @description    :   This method will grant/add additional access to Case/MS record(s) of the newly created file(s).  
     * 
     *  @args           :   List of ContentVersion
     * 
     *  @return         :   void
     * 
    **/ 
    public static void grantAdditionalSharingonFiles(List<ContentVersion> newContentVersions) {
        
        //Set of IDs
        Set<Id> setOfContentVersionIds = new Set<Id>();
        
        //Loop through ContentVersion records and populating collection with value
        for(ContentVersion cV : newContentVersions)
            setOfContentVersionIds.add(cV.Id);
        
        //Calling future method for further processing
        //this is because invoking record sharing is created by SFDC as post commit logic at end of Order of execution 
        processContentVersionRecords(setOfContentVersionIds);
    }    
    
    @future(callout=false)
    public static void processContentVersionRecords(Set<Id> setOfContentVersionIds) {
        
        //Checking & validating collection for null and size value
        if(setOfContentVersionIds != null && setOfContentVersionIds.size() > 0) {
            
            //List of content version (Type casting)
            list<ContentVersion> newContentVersions = [SELECT ID, ContentDocumentId, versionData, Title, FileType, 
                                                       Attachment_Parent_ID__c, Attachment_ID__c 
                                                       FROM ContentVersion
                                                       WHERE ID IN : setOfContentVersionIds];
            
            //Checking list for null and size value
            if(newContentVersions != null && newContentVersions.size() > 0) {
            
                //Set of ContentDocumentIDs associated with the new content version records
                Map<Id, ContentVersion> mapOfContentDocumentIDWIthContentVersionIDs = new Map<Id, ContentVersion>();
                
                //Loop through content version records
                for(ContentVersion cV : newContentVersions) {
                    if(cV.ContentDocumentId != null)
                        mapOfContentDocumentIDWIthContentVersionIDs.put(cV.ContentDocumentId, cV);
                }
            
                //Checking set for size value
                if(mapOfContentDocumentIDWIthContentVersionIDs.values().size() > 0) {
                
                    //Map to hold the content version Id as key and corresponding list of links as value
                    Map<Id, List<ContentDocumentLink>> mapOfContentVersionIdWithListOfLinks = new Map<Id, List<ContentDocumentLink>>();
                
                    //Content Document IDs string
                    String contentDocumentIdsStr = ContentVersionTriggerHelper.quotedString(mapOfContentDocumentIDWIthContentVersionIDs.keySet());
             
                    //Looping over the content document links records
                    //Checking for case and MS objects, to whom access is missing
                    for(ContentDocumentLink cL : Database.query('Select Id, LinkedEntityId, ContentDocumentId From ContentDocumentLink Where ' +
                                                                'ContentDocumentId != null AND LinkedEntityId != null AND ContentDocumentId IN ' + contentDocumentIdsStr)) {
                                                                
                        //Checking for key presence in the map and accordingly populating it to have the appropriate pair of values
                        if(mapOfContentVersionIdWithListOfLinks.containsKey(cL.ContentDocumentId)) 
                            mapOfContentVersionIdWithListOfLinks.get(cL.ContentDocumentId).add(cL);  
                        else  
                            mapOfContentVersionIdWithListOfLinks.put(cL.ContentDocumentId, new List<ContentDocumentLink>{cL});   
                    }
                    //Checking for the size of the map
                    if(mapOfContentVersionIdWithListOfLinks.values().size() > 0) {
                    
                        //Set to hold the parent case record Ids
                        Set<Id> parentCaseRecordsIds = new set<Id>();
                        
                        //Set to hold the parent MS record Ids
                        Set<Id> parentMSRecordsIds = new set<Id>();
                        
                        //Loop through content version records
                        for(ContentVersion cVn : newContentVersions) {
                            
                            //Checking document ID for null value
                            if(cVn.ContentDocumentId != null) {
                                
                                //Checking for key presence in the map
                                if(mapOfContentVersionIdWithListOfLinks.containsKey(cVn.ContentDocumentId)
                                   && mapOfContentVersionIdWithListOfLinks.get(cVn.ContentDocumentId) != null
                                  ) {
                                      //Loop through content version link records associated with current context "ContentVersion" record
                                      for(ContentDocumentLink cDL : mapOfContentVersionIdWithListOfLinks.get(cVn.ContentDocumentId)) {
                                          
                                          //Checking for LinkedEntityId " Case sObjectType" and accordingly setting correspodning 
                                          //flag values to true
                                          if(cDL.LinkedEntityId != null && String.valueOf(cDL.LinkedEntityId.getSObjectType()) == Constants.CASE_OBJECT)
                                              parentCaseRecordsIds.add(cDL.LinkedEntityId);
                                          
                                          //Checking for LinkedEntityId of "MS sObjectType" and accordingly setting correspodning 
                                          //flag values to true
                                          if(cDL.LinkedEntityId != null && String.valueOf(cDL.LinkedEntityId.getSObjectType()) == MemberSupportTriggerUtilities.MEMBER_SUPPORT_OBJECT)
                                              parentMSRecordsIds.add(cDL.LinkedEntityId); 
                                      }
                                  }
                            }
                        }
                        
                        //Map of MS records
                        Map<Id, Site_Issue__c> mapOfMemberSupports = new Map<Id, Site_Issue__c>();
                        
                        //Map of Case records
                        Map<Id, Case> mapOfCases = new Map<Id, Case>();
                        
                        //Checking for size value
                        if(parentCaseRecordsIds.size() > 0) {
                            
                            //Retrieving case records details from the database
                            mapOfCases = new Map<Id, Case>([SELECT ID, Member_Support_Ticket__c FROM Case
                                                            WHERE ID IN : parentCaseRecordsIds 
                                                            AND Member_Support_Ticket__c != null
                                                            AND RecordTypeId != null
                                                            AND RecordType.DeveloperName =: Constants.RECORD_TYPE_CASE_DEVELOPER_NAME_PT_SUPPORT_REQUEST]);
                        }
                    
                        //Checking for size value
                        if(parentMSRecordsIds.size() > 0) {
                            
                            //Retrieving case records details from the database
                            mapOfMemberSupports = new Map<Id, Site_Issue__c>([SELECT ID, 
                                                                              (SELECT ID 
                                                                               FROM Cases__r
                                                                               WHERE RecordTypeId != null
                                                                               AND RecordType.DeveloperName =: Constants.RECORD_TYPE_CASE_DEVELOPER_NAME_PT_SUPPORT_REQUEST 
                                                                              )
                                                                              FROM Site_Issue__c
                                                                              WHERE ID IN : parentMSRecordsIds
                                                                              AND RecordTypeId != null
                                                                              AND RecordType.DeveloperName =: Constants.RECORD_TYPE_SITE_ISSUE_DEVELOPER_NAME_CCA_SUPPORT_REQUEST
                                                                             ]);
                        }
                        
                        //List of links to be inserted
                        List<ContentDocumentLink> contentDocumentLinksToInsert = new List<ContentDocumentLink>();
    
                        //Loop through content version records
                        for(ContentVersion cVr : newContentVersions) {
                            
                            //Checking document ID for null value
                            if(cVr.ContentDocumentId != null) {
                                
                                //Checking for key presence in the map
                                if(mapOfContentVersionIdWithListOfLinks.containsKey(cVr.ContentDocumentId)
                                   && mapOfContentVersionIdWithListOfLinks.get(cVr.ContentDocumentId) != null
                                  ) {
                                      
                                    //Loop through content version link records associated with current context "ContentVersion" record
                                    for(ContentDocumentLink cDLi : mapOfContentVersionIdWithListOfLinks.get(cVr.ContentDocumentId)) {
                                      
                                        //If link is type of case and no sharing exists for MS then add it to the list
                                        if(cDLi.LinkedEntityId != null 
                                            && String.valueOf(cDLi.LinkedEntityId.getSObjectType()) == Constants.CASE_OBJECT) {
                                            
                                            //Checking in map for case instance and retrieving it's MS record details    
                                            if(mapOfCases.containsKey(cDLi.LinkedEntityId)
                                                && mapOfCases.get(cDLi.LinkedEntityId) != null) {
                                                
                                                //Share with MS record          
                                                ContentDocumentLink cdl4 = new ContentDocumentLink();
                                                cdl4.ContentDocumentId = cVr.ContentDocumentId;
                                                cdl4.LinkedEntityId = mapOfCases.get(cDLi.LinkedEntityId).Member_Support_Ticket__c;
                                                cdl4.ShareType = System.Label.CONTENTDOCUMENTLINK_SHARETYPE;
                                                cdl4.Visibility = System.Label.CONTENTDOCUMENTLINK_VISIBILITY;
                                                contentDocumentLinksToInsert.add(cdl4);    
                                            }    
                                        } else if(cDLi.LinkedEntityId != null 
                                            && String.valueOf(cDLi.LinkedEntityId.getSObjectType()) == MemberSupportTriggerUtilities.MEMBER_SUPPORT_OBJECT) {
                                            
                                            //Checking in map for MS instance and retrieving it's Case record details    
                                            if(mapOfMemberSupports.containsKey(cDLi.LinkedEntityId)
                                                && mapOfMemberSupports.get(cDLi.LinkedEntityId) != null) {
                                                    
                                                //Current context MS record instance
                                                Site_Issue__c sI = mapOfMemberSupports.get(cDLi.LinkedEntityId);
                                    
                                                //Checking for associated case record(s) existance
                                                if(sI.Cases__r != null && sI.Cases__r.size() > 0) {
                                                    
                                                    //Share with Case record          
                                                    ContentDocumentLink cdl3 = new ContentDocumentLink();
                                                    cdl3.ContentDocumentId = cVr.ContentDocumentId;
                                                    cdl3.LinkedEntityId = sI.Cases__r[0].Id;
                                                    cdl3.ShareType = System.Label.CONTENTDOCUMENTLINK_SHARETYPE;
                                                    cdl3.Visibility = System.Label.CONTENTDOCUMENTLINK_VISIBILITY;
                                                    contentDocumentLinksToInsert.add(cdl3);
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                        
                        //Checking for size value
                        if(contentDocumentLinksToInsert.size() > 0) {
                            
                            //Bypassing all triggers
                            Util.byPassAlltriggers = true;
                            
                            //Insert content document links
                            insert contentDocumentLinksToInsert;
                            
                            //Checking for the size of list
                            if(contentDocumentLinksToInsert.size() > 0) {
                            
                                //List of attachment
                                List<Attachment> attachments = new List<Attachment>();
                                
                                //Loop through newly created files records
                                for(ContentVersion doc : newContentVersions) {
                                    
                                    //List of parent IDs
                                    List<Id> listOfIds = new List<Id>();
                                    
                                    //Checking for size valye
                                    if(mapOfCases.keySet().size() > 0) {
                                        
                                        //insert an attachment on the current context Case record
                                        Attachment att = new Attachment();
                                        att.body = doc.versionData;
                                        att.Name = doc.Title;
                                        att.ContentType = doc.FileType;
                                        
                                        //Populating list with set value
                                        listOfIds.addAll(mapOfCases.keySet());
                                        att.ParentId = listOfIds[0];
                                        
                                        if(att.ParentId != null)
                                            attachments.add(att);
                                    }
                                    
                                    //Checking for size valye
                                    else if(mapOfMemberSupports.keySet().size() > 0) {
                                        
                                        //insert an attachment on the current context MS record
                                        Attachment att1 = new Attachment();
                                        att1.body = doc.versionData;
                                        att1.Name = doc.Title;
                                        att1.ContentType = doc.FileType;
                                        listOfIds.addAll(mapOfMemberSupports.keySet());
                                        att1.ParentId = listOfIds[0];
                                        
                                        if(att1.ParentId != null)
                                            attachments.add(att1);
                                        
                                        //Member Support Instance
                                        Site_Issue__c sI = mapOfMemberSupports.get(listOfIds[0]);
                                        
                                        //Checking for case records associated with MS record
                                        if(sI.Cases__r != null && sI.Cases__r.size() > 0) {
                                            
                                            //insert an attachment on the current context MS record
                                            Attachment att2 = new Attachment();
                                            att2.body = doc.versionData;
                                            att2.Name = doc.Title;
                                            att2.ContentType = doc.FileType;
                                            att2.ParentId = sI.Cases__r[0].Id;
                                        
                                            if(att2.ParentId != null)
                                                attachments.add(att2);
                                        }
                                    }
                                }
                    
                                //Checking for size value
                                if(attachments.size() > 0) {
                                    
                                    //Bypassing all triggers
                                    Util.byPassAlltriggers = true;
                                    
                                    //Insert attachments
                                    insert attachments;
                                    
                                    //Enabling again
                                    Util.byPassAlltriggers = false;
                                }
                            }
                        }
                    }        
                }
            }        
        }
    }

    //convert a Set<String> into a quoted, comma separated String literal for inclusion in a dynamic SOQL Query
    private static String quotedString(Set<ID> setOfStrings) {
        String newStr = '' ;
        
        //Loop through List of String
        for(ID myStr : setOfStrings) {
            
            String str = String.valueOf(myStr);
            newStr += '\'' + str + '\',';
        }
        
        newStr = newStr.lastIndexOf(',') > 0 ? '(' + newStr.substring(0,newStr.lastIndexOf(',')) + ')' : newStr ;
        
        return newStr;
    }    
}