// CampaignController Extension
public without sharing class MailingCampaignController {
    private ApexPages.StandardController controller;
    public ID MailingCampaignId { get; set; }
    public boolean EmailSentSuccessfully { get; set; }
    
    public String xlsHeader {
        get {
            return '<?xml version="1.0"?>\n<?mso-application progid="Excel.Sheet"?>\n';
        }
    }
    public String EndTag {
        get {
            return '</Workbook>';
        }
    }
    public String EndWorksheetTag {
        get {
            return '</Worksheet>';
        }
    }
    public String MaterialsManagementEmail {
        get {
            // if this is the production environment, send the email to DSS materials management.  Otherwise send to the current user
            if (UserInfo.getOrganizationId().containsIgnoreCase('00DC0000000QHC4MAO'))
                return 'DSS_MaterialsManagement@advisory.com';
            else
                return UserInfo.getUserEmail();
        }
    }
    public string DateOfToday {
        get {
            return datetime.now().format('yyyy-MM-dd');
        }
    }
    public Campaign MailingCampaign {
        get {
            if(MailingCampaign == null) {
                MailingCampaign = [SELECT Id, Name, NumberOfContacts, Purchase_Order_Number__c, 
                                   Mailing_Title__c, Type_of_Mail__c, CreatedBy.Email, description
                                   FROM Campaign WHERE Id=:MailingCampaignId ];
            }
            return MailingCampaign;
        }
        set;
    }
    
    public integer MemberCount {
        get {
            if(MemberCount==0) {
                MemberCount = [SELECT COUNT() FROM CampaignMember WHERE CampaignId=:MailingCampaignId];
                if(MemberCount == null) MemberCount = 0;
            }
            return MemberCount;
        }
        set;
    }
    
    public Map<Integer, Publication__c> Publications {
        get {
            if(Publications == null) {
                Publications = new Map<Integer, Publication__c>();
                List<Publication__c> pubs = [SELECT DERF__c, Name, Stock_Num__c, Title__c FROM Publication__c
                                             where id IN (SELECT Publication__c FROM Publication_Item__c where Campaign__c=:MailingCampaignId)];
                for(integer i=0; i<pubs.size(); i++) {
                    Publications.put(i+1, pubs.get(i));
                }
            }
            return Publications;
        }
        set;
    }
    
    public Map<Integer, AttachmentWrapper> attachmentsWrapper {
        get {
            if(attachmentsWrapper == null) {
                attachmentsWrapper = new Map<Integer, AttachmentWrapper>();
                List<Attachment__c> atts = [SELECT Name, Paper_Type__c, Campaign__c, Text_Ink__c, Stapled__c,
                                            	Attachment_Id__c, of_Pages__c, Text_Sides__c, 
                                            	(Select Id, Name FROM attachments LIMIT 1)
                                                FROM Attachment__c
                                                WHERE Campaign__c != null 
                                                AND Attachment_ID__c != ''
                                                AND Attachment_ID__c != null 
                                                AND Campaign__c = : MailingCampaignId
                                                ORDER BY Name ASC];
                
                //Loop through custom attachments                                
                for(integer i=0; i < atts.size(); i++) {
                    if(atts.get(i) != null && atts.get(i).attachments != null && atts.get(i).attachments.size() > 0)
                    	attachmentsWrapper.put(i+1, new AttachmentWrapper(atts.get(i), atts.get(i).attachments[0]));
                }
            }
            return attachmentsWrapper;
        }
        set;
    }

    public map<integer, list<CampaignMember>> campaignMemberMap {
        get {
            if (campaignMemberMap == null) {
                campaignMemberMap = new map<integer, list<CampaignMember>>();
                list<CampaignMember> cmList = new list<CampaignMember>();
                
                for (integer i = 0; i < CampaignMembers.size(); i++) {
                    CampaignMember cm = CampaignMembers[i];
                    cmList.add(cm);
                    
                    if ((cmList.size() >= 1000) || (i == campaignMembers.size()-1)) {
                        //create a new list
                        //cmList = new list<CampaignMember> { cm };
                        campaignMemberMap.put(campaignMemberMap.size(), cmList);
                        //reset the list
                        cmList = new list<CampaignMember>();
                    }
                    
                }
            }
            return campaignMemberMap;
        }
        set;
    }
    
    public List<CampaignMember> CampaignMembers {
        get {
            if(CampaignMembers == null) {
                CampaignMemberS = [SELECT Mail_Piece_Id__c, CampaignId, Contact.Id, Contact.Name, Contact.Salutation, Contact.FirstName,
                                   Contact.LastName, Contact.Suffix__c, Contact.Title, Contact.Primary_Address_Line_1__c, Contact.Primary_Address_Line_2__c,
                                   Contact.Primary_Address_Line_3__c, Contact.Primary_City__c, Contact.Primary_Country__c, Contact.Primary_Postal_Code__c,
                                   Contact.Primary_State_Province__c, Contact.Phone, Contact.Fax, Contact.Email, Contact.Contact_Restriction_Status__c,
                                   Contact.Account.Id, Contact.Account.Name, Contact.Account.Account_Restriction_Status__c FROM CampaignMember
                                   WHERE CampaignId=:MailingCampaignId];
            }
            return CampaignMembers;
        }
        set;
    }
    
    public string csvHeader {
        get {
            return '"Mail Piece ID","Campaign Id","Contact Id","Contact Name","Prefix","First Name","Last Name","Suffix","Title","Institution Id",' + 
                '"Institution Name","Primary Address Line 1","Primary Address Line 2","Primary Address Line 3","Primary City","Primary State/Province",' +
                '"Primary Postal Code","Primary Country","Phone","Fax","Email","Contact Restriction Status","Institution Restriction Status"';
        }
    }
    
    public MailingCampaignController(ApexPages.StandardController controller) {
        this.controller = controller;
        MailingCampaignId  = ((Campaign) controller.getRecord()).Id;
    }
    
    private string emailBodyString {
        get {
            if (emailBodyString == null) {
                emailBodyString = '';
            }
            return emailBodyString;
        }
        set;
    }
    
    public PageReference SendEmail() {
        try {
            
            //create the email body string
            string emailBodyString = 'Materials Management Team, \r\r'
                + 'Attached is a mailing request form and accompanying documents.  Please let me know if you have any questions. \r\r'
                + 'Thanks! \r'
                + UserInfo.getName()
                + '\r\rSpecial Instruction:\r'
                + MailingCampaign.description;
            
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            mail.setSenderDisplayName(UserInfo.getName());
            mail.setSubject('Mailing List - ' + MailingCampaign.Name);
            mail.setToAddresses(new string[] {MaterialsManagementEmail});
            mail.setCCAddresses(new list<string> {MailingCampaign.CreatedBy.Email});
            mail.setPlainTextBody(emailBodyString);
            mail.saveAsActivity = false;
            
            // Reference the attachment page and pass in the account ID
            PageReference pfPO =  Page.MailingList_PO;
            pfPO.getParameters().put('id', MailingCampaignId);
            pfPO.setRedirect(true);      
            Messaging.EmailFileAttachment po = GetEmailFileAttachment(pfPO, MailingCampaign.Purchase_Order_Number__c + '.xls');
            
            PageReference pfCSV =  Page.MailingList_MemberList;
            pfCSV.getParameters().put('id', MailingCampaignId);
            pfCSV.setRedirect(true);      
            Messaging.EmailFileAttachment csv = GetEmailFileAttachment(pfCSV, MailingCampaign.Purchase_Order_Number__c + '.csv');
            
            //Adding records in the list
            List<Messaging.EmailFileAttachment> attachments = new List<Messaging.EmailFileAttachment>();
            attachments.add(po);
            attachments.add(csv);
            
            //Set to hold the attachment IDs
            Set<String> setAttachmentIDs = new Set<String>();
            
            //Loop through custom attachment records and populating set with values
            for(Attachment__c customAtt : [SELECT Attachment_ID__c, Campaign__c FROM Attachment__c
                                            WHERE Campaign__c != null 
                                            AND Attachment_ID__c != ''
                                            AND Attachment_ID__c != null 
                                            AND Campaign__c = : MailingCampaignId]) {
                setAttachmentIDs.add(customAtt.Attachment_ID__c);
            }
            
            //Checking set for size value
            if(setAttachmentIDs.size() > 0) {
            
                //Loop through attachment records
                for(Attachment att : [SELECT ID, Body, Name FROM Attachment WHERE ID IN : setAttachmentIDs]) {
                    Messaging.EmailFileAttachment efa = new Messaging.EmailFileAttachment();
                    efa.setFileName(att.Name);
                    efa.setBody(att.Body);
                    attachments.add(efa);
                }
            }
            
            //Adding all the attachments to the email
            if(attachments != null && attachments.size() > 0)
            	mail.setFileAttachments(attachments);
            
            // Sends the email
            Messaging.SendEmailResult [] results = Messaging.sendEmail(new Messaging.SingleEmailMessage[] {mail});   
            
            system.debug('@@Success?:' + results[0].isSuccess() + '  Errors:' + results[0].getErrors());
            if (results[0].isSuccess()) {
                ApexPages.addMessage( new ApexPages.Message( ApexPages.Severity.CONFIRM, 'Email sent successfully.' ) );
                // set the sent email value to true so that we don't render the main page block.
                EmailSentSuccessfully = true;
            }
            else {
                ApexPages.addMessage( new ApexPages.Message( ApexPages.Severity.ERROR, 'ERROR:' + results[0].getErrors() ) );
            }
        }
        catch (Exception ex) {
            ApexPages.addMessage( new ApexPages.Message( ApexPages.Severity.ERROR, ex.getMessage() ) );
        }
        
        return null;
    }
    
    public PageReference Cancel() {
        return controller.cancel();
    }
    
    private static Messaging.EmailFileAttachment GetEmailFileAttachment(PageReference pf, String fileName) {
        Blob b = pf.getContent();
        Messaging.EmailFileAttachment efa = new Messaging.EmailFileAttachment();
        efa.setFileName(fileName);
        efa.setBody(b);
        return efa;
    }
    
    public class AttachmentWrapper {
        
        public Attachment__c attachment {get; set;}
        public Attachment stdAttachment {get; set;}
        
        public AttachmentWrapper(Attachment__c attachment, Attachment stdAttachment) {
            this.attachment = attachment;
            this.stdAttachment = stdAttachment;
        }
    }
}