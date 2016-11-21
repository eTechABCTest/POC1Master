/**
    Purpose         :   Controller to create custom Attachment record with user inputs from the VF page.(CR-20141216-8336)
                
    Created By      :   Abhinav Sharma
    
    Created Date    :   03/23/2015
    
    Current Version :   v1.0
    
    Revision Log    :   v1.0 - Abhinav Sharma - 03/23/2015 - CR-20141216-8336
                        
**/
public class UploadCustomAttachmentController {
    
    //Custom Attachment Instance
    public Attachment__c customAttachment {get; set;} 
    
    //Campaign
    public Campaign campaignObj {get; set;}
    
    //Properties
    public String fileName {get;set;}
    public transient Blob fileBody {get;set;}
    
    //Standard Controller
    public UploadCustomAttachmentController(ApexPages.StandardController controller) {
        
        //Memory allocation
        campaignObj = new Campaign();
        
        //Getting record details
        customAttachment = (Attachment__c)controller.getRecord();
        
        //Calling method to perform the default logic on VF page load
        inIt();
    }
    
    /**
        Description     :   Method to perform the default logic on page load.
        
        Param           :   void
        
        Return          :   void                
    
    **/ 
    public void inIt() {
        
        //Checking for the ID parameter in the URL  
        if(String.isNotBlank(ApexPages.currentPage().getParameters().get('parentid'))) {
            
            //Checking if key prefix of campaign object matches to the intial 3 characters of ID parameter
            //If case yes - Populating the campaign ID lookup on Custom Attachment record instance
            if(ApexPages.currentPage().getParameters().get('parentid').length() > 3
                &&  ApexPages.currentPage().getParameters().get('parentid').subString(0,3) == '701') {
                customAttachment.Campaign__c = ID.valueOf(ApexPages.currentPage().getParameters().get('parentid'));
                
                //Querying campaign details
                campaignObj = [SELECT ID, Name FROM Campaign 
                                    WHERE ID =: ID.valueOf(ApexPages.currentPage().getParameters().get('parentid'))];
            }   
        }
        
        resetAttachedFileParameters();
    }
    
    public void resetAttachedFileParameters() {
        
        fileName = '';
        fileBody = null;
    }
    
    /**
    * Upload process is:
    *  1. Insert new Attachment__c record
    *  2. Insert new Attachment with the new Attachment__c record as parent
    *  3. Update the Attachment__c record with the ID of the new Attachment
    **/
    public PageReference processUpload() {
    
        //Setting a save point for trasaction control        
        Savepoint sp = Database.setSavepoint();
        
        //Making a try to perform the logic
        try {
            
            //Checking if user have uploaded a file or not
            if(String.isNotBlank(fileName) && fileBody != null) {
            
                //Checking for the parentid parameter in the URL (i.e. Page was loaded from the "New Attachment" button
                if(String.isNotBlank(ApexPages.currentPage().getParameters().get('parentid'))) {
        
                    //Setting campaign ID as null
                    customAttachment.ID = null;
                
                    //1. Insert new Attachment__c record
                    insert customAttachment;
                    
                    //Checking for parent ID value
                    if(customAttachment.Id != null) {
                    
                        //Attachment
                        Attachment attachment = new Attachment();
                        attachment.body = this.fileBody;
                        attachment.name = this.fileName;
                        attachment.parentId = customAttachment.Id;
                        attachment.ContentType = attachment.name.subString(attachment.name.lastIndexOf('.'), attachment.name.length());
                        
                        // insert the attahcment
                        insert attachment;
                
                        //reset the file for the view state
                        fileBody = Blob.valueOf(' ');
                        
                        //Checking for attchment id value
                        if(attachment.Id != null) {
                    
                            // update the custom attachment record with some attachment info
                            Attachment__c cAttachment = [SELECT ID from Attachment__c
                                                                  WHERE ID = : customAttachment.Id];
                                                                        
                            cAttachment.Attachment_Id__c = attachment.Id;
                            update cAttachment;
                        }
                    }
                    return new PageReference('/' + ApexPages.currentPage().getParameters().get('parentid'));
                } else {
                    
                    if(String.isNotBlank(ApexPages.currentPage().getParameters().get('id'))) {
                        
                        customAttachment.ID = ID.valueOf(ApexPages.currentPage().getParameters().get('id'));
                        update customAttachment;
                        
                        //List of attachments
                        List<Attachment> attachments = [SELECT ID, body, Name, ContentType FROM Attachment 
                                                            WHERE ParentID =: ApexPages.currentPage().getParameters().get('id')];
                                                            
                        //Checking list for size value
                        if(attachments != null && attachments.size() > 0) {
                            
                            attachments[0].body = this.fileBody;
                            attachments[0].name = this.fileName;
                            attachments[0].ContentType = attachments[0].name.subString(attachments[0].name.lastIndexOf('.'), attachments[0].name.length());
                            update attachments[0];
                        }
                    }
                    return new PageReference('/' + ApexPages.currentPage().getParameters().get('id'));
                }
            } else {
                ApexPages.AddMessage(new ApexPages.Message(ApexPages.Severity.ERROR, System.Label.UploadCustomAttachment_CL1));  
                resetAttachedFileParameters();
                return null;
            }
        } catch (Exception e) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()));  
            resetAttachedFileParameters();
            Database.rollback(sp);
            return null;
        }
    }
    
    /**
        Description     :   Method to navigate user back to parent details page.
        
        Param           :   void
        
        Return          :   Pagereference                
    
    **/ 
    public PageReference doCancel() {
        if(String.isNotBlank( ApexPages.currentPage().getParameters().get('parentid')))
            return new PageReference('/' + ApexPages.currentPage().getParameters().get('parentid'));
        else
                return new PageReference('/' + ApexPages.currentPage().getParameters().get('id'));
    }     
}