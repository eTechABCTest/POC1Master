//Modified By - Mahendra Swarnakar - 3/17/2016 - CR-20150908-9224 
public without sharing class MembershipViewController {
    
    public Membership__c Membership { get; set; }
    // read access to related list objects
    public boolean ReadAccess_MemKeyContact { get; set; }
    public boolean ReadAccess_Opportunity { get; set; }
    public boolean ReadAccess_MemInteraction { get; set; }
    public boolean ReadAccess_SyndicatedResearch { get; set; }
    public boolean ReadAccess_MeetingUtils { get; set; }
    public boolean ReadAccess_TeleconfUtils { get; set; }
    public boolean ReadAccess_OtherUtils { get; set; }
    public boolean ReadAccess_Projects { get; set; }
    
    //Added By - Mahendra Swarnakar - 3/17/2016 - CR-20150908-9224 - Starts From Here
    public boolean ReadAccess_StaffAssignments { get; set; }
    //Added By - Mahendra Swarnakar - 3/17/2016 - CR-20150908-9224 - Ends Here
    
    // customized version of the OpenActivity object
    public class EventOrTask implements Comparable {
        public Id ObjectId { get; set; }
        public Id WhoId { get; set; }
        public String WhoName { get; set; }
        public Id WhatId { get; set; }
        public String WhatName { get; set; }
        public String Subject { get; set; }
        public Date ActivityDate { get; set; }
        public Id OwnerId { get; set; }
        public String OwnerName { get; set; }
        public String EventType { get; set; }
        public boolean IsTask { get; set; }
        
        public EventOrTask(Event evt) {
            ObjectId = evt.Id;
            WhoId = evt.WhoId;
            WhoName = evt.Who.Name;
            WhatId = evt.WhatId;
            WhatName = evt.What.Name;
            Subject = evt.Subject;
            ActivityDate = evt.ActivityDate;
            OwnerId = evt.OwnerId;
            OwnerName = evt.Owner.Name;
            EventType = evt.Event_Type__c;
            IsTask = false;
        }
        
        public EventOrTask(Task tsk) {
            ObjectId = tsk.Id;
            WhoId = tsk.WhoId;
            WhoName = tsk.Who.Name;
            WhatId = tsk.WhatId;
            WhatName = tsk.What.Name;
            Subject = tsk.Subject;
            ActivityDate = tsk.ActivityDate;
            OwnerId = tsk.OwnerId;
            OwnerName = tsk.Owner.Name;
            EventType = tsk.Event_Type__c;
            IsTask = true;
        }
        
        // allows us to sort all EventOrTasks by ActivityDate DESC
        public Integer compareTo(Object compareTo) {
            EventOrTask wrapper = (EventOrTask) compareTo;
            if (ActivityDate == wrapper.ActivityDate) return 0;
            if (ActivityDate < wrapper.ActivityDate) return 1;
            return -1;        
        }
    }
    
    private Integer NumTasksToDisplay { get; set; }
    private Integer NumHistoricalTasksToDisplay { get; set; }
    private Integer NumMemberInteractionsToDisplay { get; set; }
    private Integer NumSyndicatedToDisplay { get; set; }
    
    // the number of records to increment the related lists by
    private Integer ItemIncrementor = 5;
    
    // incrementally increase the number of records to display and refresh the list
    public void ShowMoreTasks() {
        NumTasksToDisplay += ItemIncrementor;
        OpenEventOrTaskList = null;
    }
    
    public void ShowMoreActivityHistory() {
        NumHistoricalTasksToDisplay += ItemIncrementor;
        HistoricalEventOrTaskList = null;
    }
    
    public void ShowMoreMemberInteractions() {
        NumMemberInteractionsToDisplay += ItemIncrementor;
        MemberInteractions = null;
    }
    
    public void ShowMoreSyndicated() {
        NumSyndicatedToDisplay += ItemIncrementor;
        ResearchInteractions = null;
    }
    
    // get the total number of Events and Tasks - used to determine if the "show 5 more" link will be displayed below the Related List
    public Integer NumTasksAndEvents {
        get {
            integer numEvents = [SELECT COUNT()
                                 FROM Event 
                                 WHERE (WhatId IN :RelatedOpps.keySet() OR WhatId = :Membership.Id) 
                                 AND EndDateTime >= :DateTime.now() 
                                 LIMIT :NumTasksToDisplay + 1];
            integer numTasks = [SELECT COUNT()
                                FROM Task 
                                WHERE (WhatId IN :RelatedOpps.keySet() OR WhatId = :Membership.Id) 
                                AND ActivityDate >= :Date.today() 
                                LIMIT :NumTasksToDisplay + 1];
            NumTasksAndEvents = numEvents + numTasks;
            return NumTasksAndEvents;
        }
        set;
    }
    
    // list of all open events and tasks for the Membership and Child Opps
    public List<EventOrTask> OpenEventOrTaskList {
        get {
            if (OpenEventOrTaskList == null) {
                OpenEventOrTaskList = new List<EventOrTask>();
                // also add any events associated with the Membership or Related Opps
                List<Event> openEvents = [SELECT Id, Subject, ActivityDate, WhoId, WhatId, OwnerId, What.Name, Who.Name, 
                                          Event_Type__c, Owner.Name, What.Type
                                          FROM Event 
                                          WHERE (WhatId IN :RelatedOpps.keySet() OR WhatId = :Membership.Id) 
                                          AND EndDateTime >= :DateTime.now() 
                                          ORDER BY ActivityDate DESC LIMIT :NumTasksToDisplay];
                // add all of these events to our wrapper list
                for (Event evt : openEvents) {
                    OpenEventOrTaskList.add(new EventOrTask(evt));
                }
                
                // check for open tasks as well
                List<Task> openTasks = [SELECT Id, Subject, ActivityDate, WhoId, WhatId, OwnerId, What.Name, Who.Name,  
                                        Event_Type__c, Owner.Name, What.Type
                                        FROM Task 
                                        WHERE (WhatId IN :RelatedOpps.keySet() OR WhatId = :Membership.Id) 
                                        AND ActivityDate >= :Date.today() 
                                        ORDER BY ActivityDate DESC LIMIT :NumTasksToDisplay];
                // add all of these tasks to our wrapper list
                for (Task tsk : openTasks) {
                    OpenEventOrTaskList.add(new EventOrTask(tsk));
                }
                OpenEventOrTaskList.sort();
            }
            return OpenEventOrTaskList;
        }
        set;
    }
    
    public Integer NumHistoricalTasksAndEvents {
        get {
            integer numHistoricalEvents = [SELECT COUNT()
                                 FROM Event 
                                 WHERE (WhatId IN :RelatedOpps.keySet() OR WhatId = :Membership.Id) 
                                 AND EndDateTime < :DateTime.now() AND CreatedDate >= LAST_N_YEARS:2
                                 LIMIT :NumHistoricalTasksToDisplay + 1];
            integer numHistoricalTasks = [SELECT COUNT()
                                FROM Task 
                                WHERE (WhatId IN :RelatedOpps.keySet() OR WhatId = :Membership.Id) 
                                AND ActivityDate < :Date.today() AND CreatedDate >= LAST_N_YEARS:2
                                LIMIT :NumHistoricalTasksToDisplay + 1];
            NumHistoricalTasksAndEvents = numHistoricalEvents + numHistoricalTasks;
            return NumHistoricalTasksAndEvents;
        }
        set;
    }
    
    // list of all historical events and tasks for the Membership and Child Opps
    public List<EventOrTask> HistoricalEventOrTaskList {
        get {
            if (HistoricalEventOrTaskList == null) {
                HistoricalEventOrTaskList = new List<EventOrTask>();
                // also add any events associated with the Membership or Related Opps
                List<Event> historicalEvents = [SELECT Id, Subject, ActivityDate, WhoId, WhatId, OwnerId, What.Name, Who.Name,  
                                                Event_Type__c, Owner.Name, What.Type
                                                FROM Event 
                                                WHERE (WhatId IN :RelatedOpps.keySet() OR WhatId = :Membership.Id) 
                                                AND EndDateTime < :DateTime.now() AND CreatedDate >= LAST_N_YEARS:2
                                                LIMIT :NumHistoricalTasksToDisplay ALL ROWS];
                // add all of these events to our wrapper list
                for (Event evt : historicalEvents) {
                    HistoricalEventOrTaskList.add(new EventOrTask(evt));
                }
                
                // check for open tasks as well
                List<Task> historicalTasks = [SELECT Id, Subject, ActivityDate, WhoId, WhatId, OwnerId, What.Name, Who.Name,  
                                              Event_Type__c, Owner.Name, What.Type
                                              FROM Task 
                                              WHERE (WhatId IN :RelatedOpps.keySet() OR WhatId = :Membership.Id) 
                                              AND ActivityDate < :Date.today() AND CreatedDate >= LAST_N_YEARS:2
                                              LIMIT :NumHistoricalTasksToDisplay ALL ROWS];
                // add all of these tasks to our wrapper list
                for (Task tsk : historicalTasks) {
                    HistoricalEventOrTaskList.add(new EventOrTask(tsk));
                }
                HistoricalEventOrTaskList.sort();
            }
            return HistoricalEventOrTaskList;
        }
        set;
    }
    
    
    
    public MembershipViewController(ApexPages.StandardController controller) {
        //Initialize membership record 
        String memId = controller.getId();
        Membership = [SELECT Id, Name, Program__c, Account_Name__c, Program__r.Name, Account_Name__r.Name FROM Membership__c WHERE Id = :memId LIMIT 1];
        
        
        // Added the Staff Assignment Object in the object name list  - Mahendra Swarnakar - 3/17/2016 - CR-20150908-9224
        // determine which related lists we have access to
        List<String> objectNameList = new List<String> { 'Membership_Key_Contact__c', 'Meeting_Utilization__c', 'Opportunity',
                                                         'Utilization_Data_Object__c', 'Other_Utilization__c',
                                                         'Project__c', 'Call__c', 'Syndicated_Research_Interaction__c', 'Team_Membership__c' };
        Map<String, String> userPermissionMap = Util.CheckUserPermission(UserInfo.getUserId(), objectNameList, 'PermissionsRead');
        for (String objName : userPermissionMap.keySet()) {
            String hasAccess = userPermissionMap.get(objName);
            if (objName == 'Membership_Key_Contact__c' && hasAccess == 'true') ReadAccess_MemKeyContact = true;
            if (objName == 'Opportunity' && hasAccess == 'true') ReadAccess_Opportunity = true;
            else if (objName == 'Meeting_Utilization__c' && hasAccess == 'true') ReadAccess_MeetingUtils = true;
            else if (objName == 'Utilization_Data_Object__c' && hasAccess == 'true') ReadAccess_TeleconfUtils = true;
            else if (objName == 'Other_Utilization__c' && hasAccess == 'true') ReadAccess_OtherUtils = true;
            else if (objName == 'Project__c' && hasAccess == 'true') ReadAccess_Projects = true;
            else if (objName == 'Call__c' && hasAccess == 'true') ReadAccess_MemInteraction = true;
            else if (objName == 'Syndicated_Research_Interaction__c' && hasAccess == 'true') ReadAccess_SyndicatedResearch = true;
            
            //Added to set boolean flag according to user permissions for Staff Assignment Object related list - Mahendra Swarnakar - 3/17/2016 - CR-20150908-9224
            else if (objName == 'Team_Membership__c' && hasAccess == 'true') ReadAccess_StaffAssignments = true;
        }
        // set the default num of items to show in custom Related Lists
        NumTasksToDisplay = ItemIncrementor;
        NumHistoricalTasksToDisplay = ItemIncrementor;
        NumMemberInteractionsToDisplay = ItemIncrementor;
        NumSyndicatedToDisplay = ItemIncrementor;
    }
    
    // get the opportunities related to this Membership
    public Map<Id, Opportunity> RelatedOpps {
        get {
            if (RelatedOpps == null) {
                RelatedOpps = new Map<Id, Opportunity>([SELECT Id FROM Opportunity WHERE Membership__c = :Membership.Id]);
            }
            return RelatedOpps;
        }
        set;
    }
    
    // count the number of membership interactions
    public Integer NumMemberInteractions {
        get {
            // get all projects where Institution and Program are equal to Membership's institution / program
            Map<Id, Project__c> projectMap = new Map<Id, Project__c>([SELECT Id
                                         FROM Project__c 
                                         WHERE (Product__c != null AND Product__c = :Membership.Program__c 
                                         AND Institution__c != null AND Institution__c = :Membership.Account_Name__c)
                                         OR (Primary_Paid_Membership__c = :Membership.Id)]);
            NumMemberInteractions = [SELECT COUNT()
                                  FROM Call__c
                                  WHERE Member__c IN :projectMap.keySet() 
                                  AND CreatedDate >= LAST_N_YEARS:2
                                  LIMIT :NumMemberInteractionsToDisplay + 1];
            return NumMemberInteractions;
        }
        set;
    }
    
    public List<Call__c> MemberInteractions {
        get {
            if (MemberInteractions == null) {
                // get all projects where Institution and Program are equal to Membership's institution / program
                Map<Id, Project__c> projectMap = new Map<Id, Project__c>([SELECT Id
                                             FROM Project__c 
                                             WHERE (Product__c != null AND Product__c = :Membership.Program__c 
                                             AND Institution__c != null AND Institution__c = :Membership.Account_Name__c)
                                             OR (Primary_Paid_Membership__c = :Membership.Id)]);
                MemberInteractions = [SELECT Id, Name, Call_Brief_Notes__c, RecordType.Name, CreatedById,
                                      CreatedDate, Project_Name__c, Member__c, Member__r.Name
                                      FROM Call__c
                                      WHERE Member__c IN :projectMap.keySet() 
                                      AND CreatedDate >= LAST_N_YEARS:2 ORDER BY CreatedDate DESC
                                      LIMIT :NumMemberInteractionsToDisplay];
            }
            return MemberInteractions;
        }
        set;
    }
    
    // count the number of research interactions
    public Integer NumResearchInteractions {
        get {
            NumResearchInteractions = [SELECT COUNT()
                                        FROM Syndicated_Research_Interaction__c
                                        WHERE Institution__c = :Membership.Account_Name__c AND Primary_Program__c = :Membership.Program__c
                                        AND CreatedDate >= LAST_N_YEARS:2 
                                        LIMIT :NumSyndicatedToDisplay + 1];
            return NumResearchInteractions;
        }
        set;
    }
    
    public List<Syndicated_Research_Interaction__c> ResearchInteractions {
        get {
            if (ResearchInteractions == null) {
                ResearchInteractions = [SELECT Id, Name, Contact__c, Contact__r.Name, Researcher__c, Researcher__r.Name,
                                               
                                               
                                               Date_of_Interaction__c,
                                                Interaction_Type__c, Primary_Study__c, Primary_Study__r.Name,
                                               Primary_Program__c, Primary_Program__r.Name, Status__c
                                        FROM Syndicated_Research_Interaction__c
                                        WHERE Institution__c = :Membership.Account_Name__c AND Primary_Program__c = :Membership.Program__c
                                        AND CreatedDate >= LAST_N_YEARS:2 
                                        
                                        
                                        ORDER BY Date_Of_Interaction__c DESC
                                        LIMIT :NumSyndicatedToDisplay];
            }
            return ResearchInteractions;
        }
        set;
    }
    
}