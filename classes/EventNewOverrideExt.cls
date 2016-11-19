public with sharing class EventNewOverrideExt
{
    /*
    Purpose:    Extention controller for EventNewOverride VF page used to override the Event 'New' button.  Includes test method.
    
    Create By:  Nathan Banas (SAP)          
    
    Last Modified By:   Nathan Banas (SAP) - 4/21/2011
    
    Current Version:    v1.2
    
    Revision Log:       v1.0 - (NB) Created code
                        v1.1 - (NB-2011-01-24) Added header, code comments, and reviewed code coverage
                        v1.2 - (NB-2011-04-21) Modified test method to be remove the reliance on data being present within the system
                        v1.3 - Modified By - Abhinav Sharma - 08/14/2014 - CR-20140505-5346
                        v1.4 - Modified By - Abhinav Sharma - 11/11/2014 - CR-20140915-7358
						v1.5 - Modified By - Abhinav Sharma - 03/19/2016 - CR-20160114-9516 - Fixed issue caught in existing funcationality while UAT
                        
    Code Coverage as of 1/24/2011: 97% (1 line not tested and unnecessary)
    Code Coverage as of 4/21/2011: 97% (1 line not tested and unnecessary)
    */  
    
    private ApexPages.StandardController controller;
    public String retURL {get; set;}
    public String saveNewURL {get; set;}
    public String rType {get; set;}
    public String cancelURL {get; set;}
    public String ent {get; set;}
    public String confirmationToken {get; set;}
    public String whatID {get; set;}
    public String whoID {get; set;}
    public Id RecordId {get; set;}
    public String pageURL { get; set; }
    public String queryString { get; set; }
    public String RecordTypeName { get; set; }
    
    //Added By - Abhinav Sharma - 08/14/2014 - CR-20140505-5346
    public List<string> leftselected{get;set;}
    public List<string> rightselected{get;set;} 
    Set<string> leftvalues = new Set<string>();
    Set<string> rightvalues = new Set<string>();
    
    public boolean IsPTMarketing {
        get {
            if (IsPTMarketing == null) {
                IsPTMarketing = false;
                String PTMarketingRTId = Util.RecordTypeId('Event', 'PT Marketing');
                if (RecordId == PTMarketingRTId || Evt.RecordTypeId == PTMarketingRTId)
                    IsPTMarketing = true;
                    RecordTypeName = 'PT Marketing';
            }
            return IsPTMarketing;
        }
        set;
    }
    
    public List<Attachment> EmailAttachments {
        get {
            if (EmailAttachments == null)
                EmailAttachments = new List<Attachment>();
            return EmailAttachments;
        }
        set;
    }
    
    public String NameFile { get; set; }
    //public Attachment ContentFile { get; set; }
    
    public Attachment EmailAttachment {
        get {
            if (EmailAttachment == null)
                EmailAttachment = new Attachment();
            return EmailAttachment;
        }
        set;
    }
    
    public PageReference SaveDoc() {
        EmailAttachment.Name = NameFile;
        Attachment newAttachment = EmailAttachment.Clone();
        
        // determine parent id
        if (Evt.Id != null)
            newAttachment.ParentId = Evt.Id;
        else if (whatID != null)
            newAttachment.ParentId = whatID;
        else if (WhoId != null)
            newAttachment.ParentId = WhoId;
        
        // make sure the attachment is valid, if not, throw an error
        if (newAttachment.Body == null ||  newAttachment.Name == null) {
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, 'No file was selected.');
            ApexPages.addMessage(myMsg);
            return null;
        }
        if (newAttachment.ParentId == null ||  newAttachment.ParentId == null) {
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, 'Please enter a value in the "Related To" field prior to adding attachments.');
            ApexPages.addMessage(myMsg);
            return null;
        }
        
        try {
            insert newAttachment;
        }
        catch(Exception ex) {
            return null;
        }
        
        // set attachment body to null (viewstate issues)
        newAttachment.body = null;
        EmailAttachments.add(newAttachment);
        EmailAttachment = new Attachment();
        return null;
    }
    
    public void ReAssociateDocs() {
        List<Attachment> attachmentsToUpdate = new List<Attachment>();
        List<Attachment> attachmentsToDelete = new List<Attachment>();
        Set<Id> attIds = new Set<Id>();
        
        for (Attachment a : EmailAttachments) {
            if (a.ParentId != Evt.Id ) {
                attIds.add(a.Id);
            }
        }
        
        // get all temp attachments
        List<Attachment> existingAttachments = [SELECT Id, ParentId, Body, ContentType, Name, Description 
                                                FROM Attachment WHERE Id IN :attIds LIMIT 1000];
        
        for (Attachment a : existingAttachments) {
            if (a.ParentId != Evt.Id) {
                Attachment newAttachment = new Attachment();
                newAttachment.Body = a.Body;
                newAttachment.Name = a.Name;
                newAttachment.Description = a.Description;
                newAttachment.ContentType = a.ContentType;
                newAttachment.ParentId = Evt.Id;
                
                attachmentsToDelete.add(a);
                attachmentsToUpdate.add(newAttachment);
            }
        }
        
        if (attachmentsToUpdate.size() > 0)
            upsert attachmentsToUpdate;
            
        if (attachmentsToDelete.size() > 0)
            delete attachmentsToDelete;
    }
    
    public String AttachmentToRemove { get; set; }
    
    public PageReference RemoveAttachment() {
        for (integer i = 0; i < EmailAttachments.size(); i++) {
            Attachment a = EmailAttachments[i];
            if (a.Name == AttachmentToRemove) {
                delete a;
                EmailAttachments.remove(i);
            }
        }
        return null;
    }
    
    public integer DifferenceInMinutse(datetime firstDT, datetime secondDT){  
        long dt1 = firstDT.getTime() / 1000 / 60;  //getTime gives us milliseconds, so divide by 1000 for seconds  
        long dt2 = secondDT.getTime() / 1000 / 60;
        double d = dt1 - dt2;
        integer retVal = d.intValue();
        if (retVal > 1400)
            return null;
        return retVal;
    }
    
    public PageReference selectclick(){
        //rightselected.clear();
        for(String s : leftselected){
            leftvalues.remove(s);
            rightvalues.add(s);
        }
        return null;
    }
     
    public PageReference unselectclick(){
        //leftselected.clear();
        for(String s : rightselected){
            rightvalues.remove(s);
            leftvalues.add(s);
        }
        return null;
    }
    
    public List<SelectOption> getunSelectedValues(){
        List<SelectOption> options = new List<SelectOption>();
        List<string> tempList = new List<String>();
        tempList.addAll(leftvalues);
        tempList.sort();
        for(string s : tempList)
            options.add(new SelectOption(s,s));
        return options;
    }
 
    public List<SelectOption> getSelectedValues(){
        List<SelectOption> options1 = new List<SelectOption>();
        List<string> tempList = new List<String>();
        tempList.addAll(rightvalues);
        tempList.sort();
        for(String s : tempList)
            options1.add(new SelectOption(s,s));
        return options1;
    }
    
    public pagereference cancel() {
        
        // Create PageReference for creating a new sObject and add any inbound query string parameters.  
        PageReference pr = new PageReference('/' + Evt.WhatId);  
        
        // Don't redirect with the viewstate of the current record.  
        pr.setRedirect(true);  
        return pr; 
    }
    
    public PageReference Save() {  
        try {  
            
            Evt.DurationInMinutes = DifferenceInMinutse(Evt.EndDateTime, Evt.StartDateTime);
            Evt.ActivityDateTime = Evt.StartDateTime;
            
            //String variable
            String resourceString = '';
            for(String option : rightvalues) {
                resourceString += option + ';';
            }
            
            Evt.Syndicated_Resources__c = resourceString;
            
            // Save the current sObject  
            upsert Evt;
            
            // re-associate any documents that may have been added
            ReAssociateDocs();
            
            // Create PageReference for creating a new sObject and add any inbound query string parameters.  
            PageReference pr = new PageReference('/' + Evt.WhatId);  
            
            // Don't redirect with the viewstate of the current record.  
            pr.setRedirect(true);  
            return pr;  
        
        } catch(Exception e) {  
        
            // Don't redirect if something goes wrong. May be a validation or trigger issue on save.  
            ApexPages.addMessages(e);  
            return null;  
        }  
    } 
    
    //Modified By - Abhinav Sharma - 03/19/2016 - CR-20160114-9516 
    public PageReference SaveAndNewTask() {  
        try {  
            Evt.ActivityDateTime = Evt.StartDateTime;
            Evt.DurationInMinutes = DifferenceInMinutse(Evt.EndDateTime, Evt.StartDateTime);
            
            //String variable
            String resourceString = '';
            for(String option : rightvalues) {
                resourceString += option + ';';
            }
            
            Evt.Syndicated_Resources__c = resourceString;
                
            // Save the current sObject  
            upsert Evt;
            
            //Modified By - Abhinav Sharma - 03/19/2016 - CR-20160114-9516
            //Start from here 
            //Pagereference
            PageReference pr;
            
            //Checking if event instance for fields values
            if(Evt.WhatId != null && Evt.Id != null && Evt.What.Name == null) {
                
                //List of events
                List<Event> events = new List<Event>();
                
                //Retrieving event details
                events = [SELECT ID, WhatId, What.Name FROM Event WHERE ID =: Evt.Id 
                          												AND WhatId != null
                         												AND WhatId =: Evt.WhatId];
                
                //Checking for the size value
                if(events.size() > 0) {
                	
                    // Create PageReference for creating a new sObject and add any inbound query string parameters.  
                    pr = new PageReference('/setup/ui/recordtypeselect.jsp?ent=Task&save_new_url=/00T/e?tsk3=' + EncodingUtil.urlEncode(events[0].What.Name, 'UTF-8') + '&retURL=/' + events[0].Id);  
            		pr.getParameters().put('who_id', whoID); // Set WhoId
                    
                    if(Evt.WhatId != null)
                		pr.getParameters().put('what_id', Evt.WhatId); // Set WhatId
                	else
                    	pr.getParameters().put('what_id', whatId); // Set WhatId
                    
                    // Don't redirect with the viewstate of the current record.  
                    pr.setRedirect(true);  
                    return pr;  
                
                } else {
                    return null;
                }
            } else {
                
            	// Create PageReference for creating a new sObject and add any inbound query string parameters.  
                pr = new PageReference('/setup/ui/recordtypeselect.jsp?ent=Task&save_new_url=/00T/e?tsk3=' + EncodingUtil.urlEncode(Evt.What.Name, 'UTF-8') + '&retURL=/' + Evt.Id);  
                pr.getParameters().put('who_id', whoID); // Set WhoId
                
                if(Evt.WhatId != null)
               		pr.getParameters().put('what_id', Evt.WhatId); // Set WhatId
                else
                    pr.getParameters().put('what_id', whatId); // Set WhatId
                
                // Don't redirect with the viewstate of the current record.  
                pr.setRedirect(true);  
                return pr;  
            }
            //Upto here
        } catch(Exception e) {
            
            // Don't redirect if something goes wrong. May be a validation or trigger issue on save.  
            ApexPages.addMessages(e);  
            return null;  
        }  
    }  
    
    public PageReference SaveAndNew() {  
        try {  
            Evt.ActivityDateTime = Evt.StartDateTime;
            Evt.DurationInMinutes = DifferenceInMinutse(Evt.EndDateTime, Evt.StartDateTime);
            
            //String variable
            String resourceString = '';
            for(String option : rightvalues) {
                resourceString += option + ';';
            }
          
            Evt.Syndicated_Resources__c = resourceString;
                
            // Save the current sObject  
            upsert Evt;  
            
            //Modified By - Abhinav Sharma - 03/19/2016 - CR-20160114-9516
            //Start from here
            //Pagereference
            PageReference pr;
            
            //Checking if event instance for fields values
            if(Evt.WhatId != null && Evt.Id != null && Evt.What.Name == null) {
                
                //List of events
                List<Event> events = new List<Event>();
                
                //Retrieving event details
                events = [SELECT ID, WhatId, What.Name FROM Event WHERE ID =: Evt.Id 
                          												AND WhatId != null
                         												AND WhatId =: Evt.WhatId];
                
                //Checking for the size value
                if(events.size() > 0) {
                	
                    // Create PageReference for creating a new sObject and add any inbound query string parameters.  
                    pr = new PageReference('/setup/ui/recordtypeselect.jsp?ent=Event&save_new_url=/00U/e?evt3=' + EncodingUtil.urlEncode(events[0].What.Name, 'UTF-8') + '&retURL=/' + events[0].Id);  
            		
                    if(Evt.WhatId != null)
                		pr.getParameters().put('what_id', Evt.WhatId); // Set WhatId
                	else
                    	pr.getParameters().put('what_id', whatId); // Set WhatId
                 
                    // Don't redirect with the viewstate of the current record.  
                    pr.setRedirect(true);  
                    return pr;  
                
                } else {
                    return null;
                }
            } else {
                
            	// Create PageReference for creating a new sObject and add any inbound query string parameters.  
                pr = new PageReference('/setup/ui/recordtypeselect.jsp?ent=Event&save_new_url=/00U/e?evt3=' + EncodingUtil.urlEncode(Evt.What.Name, 'UTF-8') + '&retURL=/' + Evt.Id);  
                
                if(Evt.WhatId != null)
                	pr.getParameters().put('what_id', Evt.WhatId); // Set WhatId
                else
                    pr.getParameters().put('what_id', whatId); // Set WhatId
                
                // Don't redirect with the viewstate of the current record.  
                pr.setRedirect(true);  
                return pr;  
                
            }
            //Upto here
        } catch(Exception e) {  
            
            // Don't redirect if something goes wrong. May be a validation or trigger issue on save.  
            ApexPages.addMessages(e);  
            return null;  
        }  
    }  
    
    public boolean IsRIMarketing {
        get {
            if (IsRIMarketing == null) {
                IsRIMarketing = false;
                String IsRIMarketingRTId = Util.RecordTypeId('Event', 'RI Marketing');
                if (rType == IsRIMarketingRTId || Evt.RecordTypeId == IsRIMarketingRTId)
                    IsRIMarketing = true;
                    RecordTypeName = 'RI Marketing';
            }
            return IsRIMarketing;
        }
        set;
    }
    
    public boolean IsRIAM {
        get {
            if (IsRIAM == null) {
                IsRIAM = false;
                String IsRIAMRTId = Util.RecordTypeId('Event', 'RI AM');
                if (rType == IsRIAMRTId || Evt.RecordTypeId == IsRIAMRTId)
                    IsRIAM = true;
                    RecordTypeName = 'RI AM';
            }
            return IsRIAM;
        }
        set;
    }
    
    public boolean IsPTAM {
        get {
            if (IsPTAM == null) {
                IsPTAM = false;
                String IsPTAMRTId = Util.RecordTypeId('Event', 'PT AM');
                if (rType == IsPTAMRTId || Evt.RecordTypeId == IsPTAMRTId)
                    IsPTAM = true;
                    RecordTypeName = 'PT AM';
            }
            return IsPTAM;
        }
        set;
    }
    
    public boolean IsPTQACall {
        get {
            if (IsPTQACall == null) {
                IsPTQACall = false;
                String IsPTQACallRTId = Util.RecordTypeId('Event', 'PT QA Call');
                if (rType == IsPTQACallRTId || Evt.RecordTypeId == IsPTQACallRTId)
                    IsPTQACall = true;
                    RecordTypeName = 'PT QA Call';
            }
            return IsPTQACall;
        }
        set;
    }
    
    public boolean IsTDAM {
        get {
            if (IsTDAM == null) {
                IsTDAM = false;
                String IsTDAMRTId = Util.RecordTypeId('Event', 'TD AM');
                if (rType == IsTDAMRTId || Evt.RecordTypeId == IsTDAMRTId)
                    IsTDAM = true;
                    RecordTypeName = 'TD AM';
            }
            return IsTDAM;
        }
        set;
    }
    
    //Added By - Abhinav Sharma- 11/11/2014 - CR-20140915-7358
    public boolean IsRIQACall {
        get {
            if (IsRIQACall == null) {
                IsRIQACall = false;
                String RIQACallRTId = Util.RecordTypeId('Event', 'RI QA Call');
                
                if (rType == RIQACallRTId || Evt.RecordTypeId == RIQACallRTId)
                    IsRIQACall = true;
                    RecordTypeName = 'RI QA Call';
            }
            return IsRIQACall;
        }
        set;
    }
    
    public boolean IsNew {
        get {
            if (IsNew == null) {
                if (RecordId != null)
                    IsNew = false;
                else
                    IsNew = true;
            }
            return IsNew;
        }
        set;
    }
    
    public List<selectOption> ShowAsOptions {
        get {
            if (ShowAsOptions == null) {
                ShowAsOptions = new List<selectOption>();
                ShowAsOptions.add(new selectOption('Busy', 'Busy')); 
                ShowAsOptions.add(new selectOption('Out Of Office', 'Out Of Office')); 
                ShowAsOptions.add(new selectOption('Free', 'Free')); 
            }
            return ShowAsOptions;
        }
        set;
    }
    
    // the Event record
    public Event Evt {
        get {
            if (Evt == null) {
                if (RecordId != null) {
                    Set<String> additionalFields = new Set<String>{ 'RecordType.Name', 'Who.Phone', 'What.Name', 'Who.Name', '(SELECT Name, Id, ParentId, Description FROM Attachments)' };
                    string queryString = FieldDescribes.FullItemBaseQuery('Event', additionalFields) + ' WHERE Id = \'' + RecordId + '\' ALL ROWS';
                    List<Event> events = database.query(queryString);
                    if (events.size() > 0) {
                        Evt = events[0];
                    }
                }
                else {
                    Evt = new Event();
                }
            }
            return Evt;
        }
        set;
    }
     
    public EventNewOverrideExt(ApexPages.StandardController controller) {
        
        // get the record Id
        RecordId = controller.getId();
        this.controller = controller;
        
        // Keep track of any inbound query string parameters so they can be passed along when creating a new record  
        /*List<string> pageUrls = new List<string>();
        try {
            pageUrls = ApexPages.currentPage().getUrl().split('\\?');  
            queryString = pageUrls[1];
        }
        catch(Exception ex) {}*/
        
        retURL = ApexPages.currentPage().getParameters().get('retURL');
        rType = ApexPages.currentPage().getParameters().get('RecordType');
        cancelURL = ApexPages.currentPage().getParameters().get('cancelURL');
        ent = ApexPages.currentPage().getParameters().get('ent');
        confirmationToken = ApexPages.currentPage().getParameters().get('_CONFIRMATIONTOKEN');
        saveNewURL = ApexPages.currentPage().getParameters().get('save_new_url');
        whatID = ApexPages.currentPage().getParameters().get('what_id');
        whoID = ApexPages.currentPage().getParameters().get('who_id');
        pageURL = ApexPages.currentPage().getUrl();
        
        if (whatID != null && Evt.WhatId == null)
            Evt.WhatId = whatID;
        if (whoID != null && Evt.WhoId == null && whoID.startsWith('003'))
            Evt.WhoId = whoId;
        
        if (rType != null)
            Evt.RecordTypeId = rType;
        
        if (Evt.Subject == null)
            Evt.Subject = 'Will Auto-Populate';
            
        // populate attachments
        for (Attachment a : Evt.Attachments)
            EmailAttachments.add(a);
            
        //Added By - Abhinav Sharma - 08/14/2014 - CR-20140505-5346
        //Memory allocation
        leftselected = new List<String>();
        rightselected = new List<String>();
        
        //List to hold Contact "Employee" record type details
        List<RecordType> contactRdTypes = [SELECT ID FROM RecordType WHERE sObjectType = 'Contact' AND IsActive = true
                                            AND DeveloperName = 'Employee'];
                                            
        //Checking list for null and size value
        if(contactRdTypes != null && contactRdTypes.size() > 0) {                      
        
            //Loop through Contact records which are belongings to Record Type = 'Employee' and for them 
            //Syndicated Resource = true/Expert? = true
            for(Contact con : [SELECT ID, Name FROM Contact WHERE RecordTypeId =: contactRdTypes[0].Id 
                                AND Expert__c = true ORDER BY Name ASC]) {
                //Adding contact's name into the left side list of options
                leftvalues.add(con.name);                    
            }
        }
        
        //Checking if event record exists in database or not
        if(Evt.Id != null) {
            if(Evt.Syndicated_Resources__c != null) {
                if(Evt.Syndicated_Resources__c.split(';').size() > 0) {
                    for(Integer i =0; i< Evt.Syndicated_Resources__c.split(';').size(); i++) {
                        String contactName = Evt.Syndicated_Resources__c.split(';')[i];
                        rightValues.add(contactName);
                        leftvalues.remove(contactName);
                    }
                } else {
                    if(Evt.Syndicated_Resources__c != '') {
                        rightValues.add(Evt.Syndicated_Resources__c);
                        leftvalues.remove(Evt.Syndicated_Resources__c);
                    }
                }
            }
        }
    }
    
    public PageReference redirect() {
        PageReference returnURL;
        
        //Modified By - Abhinav Sharma - 11/11/2014 - CR-20140915-7358
        //Added extra check for "IsRIQACall" record type
        //if(IsPTMarketing || IsRIMarketing)
        if(IsPTMarketing || IsRIMarketing || IsRIAM || IsPTAM || IsPTQACall || IsTDAM || IsRIQACall)
        {
            /*// if we are already on the Event_Edit page, do not redirect
            if (pageURL.contains('Event_Edit'))
                return null;
            // Redirect if Record Type corresponds to custom VisualForce page
            returnURL = new PageReference('/apex/Event_Edit');
            if (RecordId != null)
                returnURL.getParameters().put('RecordType', recordId);
            else if (Evt.RecordTypeId != null)
                returnURL.getParameters().put('RecordType', Evt.RecordTypeId);*/
            return null;
        }
        else
        {
            if (recordId != null) {
                returnURL = new PageReference('/' + recordId + '/e');
                returnURL.getParameters().put('evt5', 'Will Auto-Populate'); // Set Name = 'Will Auto-Populate'
                returnURL.getParameters().put('what_id', whatID); // Set WhatId
                returnURL.getParameters().put('who_id', whoID); // Set WhatId
            }
            else { //if it is a new event, bring the user to the new event standard page
                // Redirect to standard page layout if record type does not match
                returnURL = new PageReference('/00U/e');
            }
        }
        
        returnURL.getParameters().put('RecordType', rType);
        returnURL.getParameters().put('cancelURL', cancelURL);
        returnURL.getParameters().put('ent', ent);
        returnURL.getParameters().put('_CONFIRMATIONTOKEN', confirmationToken);
        returnURL.getParameters().put('save_new_url', saveNewURL);
        returnURL.getParameters().put('nooverride', '1');
        returnURL.getParameters().put('retURL', retURL);
                
        returnURL.setRedirect(true);
        
        return returnURL;
    }   
}