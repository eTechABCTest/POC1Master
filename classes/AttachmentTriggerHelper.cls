/*
    Purpose     :   Utility methods for Attachment Trigger
    
    Create By   :   Victor Hanson - 09/11/2013
    
    Revision Log:   v1.0 - Created
                    v1.1 - VH - 07/22/2014 - Modified - CR-20120806-1297
                    v1.2 - Abhinav Sharma - 03/24/2015 - CR-20141216-8336
                    v1.2 - Abhinav Sharma - 09/01/2016 - CR-20160224-9640 - Added new method (grantAdditionalSharingOnFiles)
*/
public class AttachmentTriggerHelper {
    
    // Determine whether or not a purchase request contains a document attachment.
    public static void hasPurchOrPymtRequestDoc(List<Attachment> triggerNew, Map<Id, Attachment> oldMap, boolean isDelete) {
        List<Attachment> attachments = new List<Attachment>();
        List<Purchase_Request__c> purchaseReqsToUpdate = new List<Purchase_Request__c>();
        List<Payment_Request__c> paymentReqsToUpdate = new List<Payment_Request__c>();
        if (isDelete) attachments = oldMap.values();
        else attachments = triggerNew;
        
        Set<Id> parentIds = new set<Id>();
        Set<Id> attachmentIds = new Set<Id>();
        for (Attachment att : attachments) {
            parentIds.add(att.ParentId);
            attachmentIds.add(att.Id);
        }
        
        // get purchase requests with attachments
        List<Purchase_Request__c> purchaseRequestMap = new List<Purchase_Request__c>();
        if (isDelete) {
            purchaseRequestMap = [SELECT Id, Has_Attachment__c, (SELECT Id, ContentType FROM Attachments WHERE NOT ID In :attachmentIds LIMIT 1)
                                  FROM Purchase_Request__c WHERE Id IN :parentIds];
        }
        else {
            purchaseRequestMap = [SELECT Id, Has_Attachment__c, (SELECT Id, ContentType FROM Attachments LIMIT 1)
                                  FROM Purchase_Request__c WHERE Id IN :parentIds];
        }
        
        for (Purchase_Request__c pr : purchaseRequestMap) {
            boolean hasAttachment = false;
            if (pr.Attachments != null && pr.Attachments.size() > 0) hasAttachment = true;
            if (pr.Has_Attachment__c != hasAttachment) {
                pr.Has_Attachment__c = hasAttachment;
                purchaseReqsToUpdate.add(pr);
            }
        }
        
        // get payment requests with attachments
        List<Payment_Request__c> paymentRequestMap = new List<Payment_Request__c>();
        if (isDelete) {
            paymentRequestMap = [SELECT Id, Has_Attachment__c, (SELECT Id, ContentType FROM Attachments WHERE NOT ID In :attachmentIds LIMIT 1)
                                  FROM Payment_Request__c WHERE Id IN :parentIds];
        }
        else {
            paymentRequestMap = [SELECT Id, Has_Attachment__c, (SELECT Id, ContentType FROM Attachments LIMIT 1)
                                  FROM Payment_Request__c WHERE Id IN :parentIds];
        }
        
        for (Payment_Request__c pr : paymentRequestMap) {
            boolean hasAttachment = false;
            if (pr.Attachments != null && pr.Attachments.size() > 0) hasAttachment = true;
            if (pr.Has_Attachment__c != hasAttachment) {
                pr.Has_Attachment__c = hasAttachment;
                paymentReqsToUpdate.add(pr);
            }
        }
        
        if (purchaseReqsToUpdate.size() > 0) update purchaseReqsToUpdate;
        if (paymentReqsToUpdate.size() > 0) update paymentReqsToUpdate;
    }
    
    //Modified By - Abhinav Sharma - 03/24/2015 - CR-20141216-8336
    /**
     * @description:    If the attachment is being added to a Campaign with record type of Mailing Campaign,
     *                  only allow the user to upload PDF documents.  This is done because attachments are sent 
     *                  to DSS and if .doc or .docx attachments are included, they cannot be opened by mac users.
     * 
     * @params:         trigger.new
     * 
     **/
    public static void restrictMailingCampaignAttachmentToPDF(List<Attachment> attachments) {
        
        //Set to hold the campaign IDs
        Set<Id> campaignIds = new set<Id>();
        
        //Set to hold the custom attachment Ids
        Set<Id> setCustomAttachmentIds = new Set<Id>();
        
        //Loop through attachment records
        for (Attachment att : attachments) {
            
            //if the attachment is related to a campaign and the content type is NOT PDF, add to our campaignId set.
            if (att.ParentId != null && string.valueOf(att.ParentId.getSObjectType()) == 'Campaign' 
                && (att.ContentType == null || !att.ContentType.toUpperCase().contains('PDF'))) {
                campaignIds.add(att.ParentId);
            }
            
            //if the attachment is related to a custom attachment and the content type is NOT PDF, add it to the set
            if(att.ParentId != null && string.valueOf(att.ParentId.getSObjectType()) == 'Attachment__c'
                && (att.ContentType == null || !att.ContentType.toUpperCase().contains('PDF')))
                setCustomAttachmentIds.add(att.ParentId);
        }
        
        //Map to hold the custom Attachment ID as key and Campaign ID as value
        Map<Id, Id> mapCustomAttachmentIdWithCampaignId = new Map<Id, Id>();
        
        //Checking set for size value
        if(setCustomAttachmentIds.size() > 0) {
            
            //Loop through custom attachment records
            //Checking is related Campaign is of Record Type = "Mailing Campaign" 
            for(Attachment__c catt : [SELECT ID, Campaign__c FROM Attachment__c 
                                        WHERE ID IN : setCustomAttachmentIds AND Campaign__c != null]) {
                campaignIds.add(catt.Campaign__c);
                mapCustomAttachmentIdWithCampaignId.put(catt.Id, catt.Campaign__c);
            }
        }
                
        //only continue if at least one attachment is related to a Campaign
        if (campaignIds.size() > 0) {
            
            //get all Mailing List Campaigns
            map<Id, Campaign> mailingListCampaignMap = new map<Id, Campaign>([SELECT Id FROM Campaign
                                                        WHERE Id IN :campaignIds
                                                        AND RecordType.DeveloperName = :Label.Record_Type_Developer_Name_Mailing_Campaign]);
            
            if (mailingListCampaignMap.size() > 0) {
                
                for (Attachment att : attachments) {
                    
                    //if the attachment's parentId is in our list of Mailing List Campaigns, throw an error
                    if (att.ParentId != null && mailingListCampaignMap.containsKey(att.ParentId)) {
                        att.addError('Only PDF attachments are allowed on Mailing Campaigns.');
                    }
                    
                    //throwing error for custom attachment
                    if(att.ParentId != null && mapCustomAttachmentIdWithCampaignId != null && mapCustomAttachmentIdWithCampaignId.values().size() > 0
                        && mapCustomAttachmentIdWithCampaignId.containsKey(att.ParentId)
                        && mapCustomAttachmentIdWithCampaignId.get(att.ParentId) != null
                        && mailingListCampaignMap.containskey(mapCustomAttachmentIdWithCampaignId.get(att.ParentId))
                        && mailingListCampaignMap.get(mapCustomAttachmentIdWithCampaignId.get(att.ParentId)) != null) {
                        att.addError('Only PDF attachments are allowed on Mailing Campaigns.');
                    }
                }
            }
        }
    }  
    
    //Modified By - Abhinav Sharma - 09/01/2016 - CR-20160224-9640
    /**
     * @description:    If an attachment added to a case by member in community then create a new file corresponding to it
     *                  and then will share the newly created file with the related member support record.
     * 
     * @params:         trigger.new
     * 
     **/
    public static void grantAdditionalSharingOnFiles(List<Attachment> attachments) {
        
        //Set to hold the parent case record Ids
        Set<Id> parentCaseRecordsIds = new set<Id>();
       
        //Loop through attachment records
        for (Attachment att : attachments) {

            //if the attachment is related to a case then populate collection with parent case Id
            if (att.ParentId != null && String.valueOf(att.ParentId.getSObjectType()) == Constants.CASE_OBJECT)
                parentCaseRecordsIds.add(att.ParentId);
        }
        
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
        
        //Checking if we have eligible case records with us
        if(mapOfCases.values().size() > 0) {
            
    		//List of content versions
        	List<ContentVersion> listOfContentVersions = new list<ContentVersion>();
        
            //Loop through attachment records
            for(Attachment at : attachments) {
            
                //Checking for the field values
                if(at.ParentId != null && at.Name != null && at.body != null) {
                      
                      //Insert a new file record (Into private library of current logged in user)
                      ContentVersion doc = new ContentVersion();
                      doc.versionData = at.body;
                      doc.title = at.Name;
                      doc.pathOnClient = at.Name;
                      doc.FirstPublishLocationID = UserInfo.getUserId();
                      doc.Attachment_ID__c = at.Id;
                      doc.Attachment_Parent_ID__c = at.ParentId;
                      listOfContentVersions.add(doc);
                }
                
				//Checking list for size value
                if(listOfContentVersions.size() > 0) {
            
                    //Bypassing all triggers
                    Util.byPassAlltriggers = true;
                    
                    //Insert new file records (Into private library of current logged in user) 
                    insert listOfContentVersions;
                    
                    //Fetching uploaded documented related details from the database
                    List<ContentVersion> contentVersions = new List<ContentVersion>();
                    contentVersions = [SELECT ID, ContentDocumentId, Attachment_ID__c, Attachment_Parent_ID__c
                                       FROM ContentVersion 
                                       WHERE ID IN : listOfContentVersions];
                    
                    //list of sharing links
                    List<ContentDocumentLink> sharingLinks = new List<ContentDocumentLink>();
                    
                    //Loop through content version records
                    for(ContentVersion cV : contentVersions) {
                        
                        //Checking if attachment is associated with a case or member support
                        //if attached to case then add the additional sharing for the parent member support record
                        //if attached to MS record then add the additional sharing for the associated case record
                        if(String.isNotBlank(cv.Attachment_ID__c)
                            && string.isNotBlank(cv.Attachment_Parent_ID__c)   
                            && cv.Attachment_ID__c instanceOf ID
                            && cv.Attachment_Parent_ID__c instanceOf ID
                        ) {
                            
                            //if attached to case then add the additional sharing for the parent member support record
                            if(String.valueOf(ID.valueOf(cv.Attachment_Parent_ID__c).getSObjectType()) == Constants.CASE_OBJECT) {
                                
                                //Checking if current context case records exists in the map of cases
                                if(mapOfCases.containsKey(cv.Attachment_Parent_ID__c)
                                    && mapOfCases.get(cv.Attachment_Parent_ID__c) != null
                                ) {
                                    
                                    //Adding additional sharing for the parent MS record
                                    ContentDocumentLink cdl = new ContentDocumentLink();    
                                    cdl.ContentDocumentId = cV.ContentDocumentId;
                                    cdl.LinkedEntityId = mapOfCases.get(cv.Attachment_Parent_ID__c).Member_Support_Ticket__c;
                                    cdl.ShareType = System.Label.CONTENTDOCUMENTLINK_SHARETYPE;
                                    cdl.Visibility = System.Label.CONTENTDOCUMENTLINK_VISIBILITY;
                                    sharingLinks.add(cdl);    
                                    
                                    //Adding sharing access for the case record
                                    ContentDocumentLink cdl2 = new ContentDocumentLink();    
                                    cdl2.ContentDocumentId = cV.ContentDocumentId;
                                    cdl2.LinkedEntityId = mapOfCases.get(cv.Attachment_Parent_ID__c).Id;
                                    cdl2.ShareType = System.Label.CONTENTDOCUMENTLINK_SHARETYPE;
                                    cdl2.Visibility = System.Label.CONTENTDOCUMENTLINK_VISIBILITY;
                                    sharingLinks.add(cdl2);      
                                }
                            }
                        }
                    }

                    //Checking for the size value
                    if(sharingLinks.size() > 0) {
                        
                        //Bypassing all triggers
                        Util.byPassAlltriggers = true;
                        
                        //Insert links
                        insert sharingLinks;
                        
                        //Enabling again
                        Util.byPassAlltriggers = false;
                        
                    }    
            	}
        	}        
        }
    }        
}