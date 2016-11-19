public class Util {
    /*
    Purpose:    Utility class to serve as a class to store methods that are commonly used as well as provide static variables to bypass triggers when necessary.
    
    Create By:          Jeremy Nottingham (SAP)
    
    Last Modified By:   Jeremy Nottingham (SAP) - 5/13/2011
    
    Current Version:    v1.1
    
    Revision Log:       v1.0 - (NB) Created code
                        v1.1 - (NB-2011-01-27) Added header, code comments, and reviewed code coverage
                        v1.2 - (JN 5/13/11) Removed call to reset recordtypes settings from recordtypemap()
                        v1.3 - (Bhavi 02/07/2012) Added a new flag "IsMembershipOwnerTrigger"
                        v1.4 - (Bhavi 07/12/2013) Added new Key & values in map (makeMembershipsforAccounts) - CR-20130531-3103
                        v1.5 - (Abhinav Sharma 02/12/2014) - If there are failures in the database.saveResults[], they should be recorded and emailed to SFAdmin.  (sendBatchStatus) - CR-20130718-3280
                        v1.6 -  Added new methods (IsWeekendDay & AddBusinessDays) - Abhinav Sharma - 07/04/2014 - CR-20140629-6015
                        V1.7 -  Modified By - Subhash Garhwal - 07/06/2015 - CR-20150618-9014 - New method added - parseNull
                        V1.8 -  Modified By - Mahendra Swarnkar - 12/07/2015 - CR-20151109-9376 - New method added - formatToAlphabatical
                        V1.9 -  Modified By - Mahendra Swarnkar- CR-20160428-9806 - 5/9/2016 - Transformed makeMembershipsforAccounts method into a simple apex method 
                                    that will call Batch_Create_Memberships batch to create memberships
                        V1.10 -  Modified By - Mahendra Swarnkar- CR-20160425-9796 - 5/23/2016 - updated teh getter/setter method "accountRT2SegmentMap" to add "US Independent School" => "US Independent School".
                        V1.11 -  Modified By - Mahendra Swarnkar- CR-20160609-9913 - 7/7/2016 - Added method "companyHolidays" and "IsNotACompanyHoliday" and modify the existing method "AddBusinessDays".
                        V1.12 -  Modified By - Abhinav Sharma - CR-20160114-9520 - 08/23/2016 - Added following three methods.
                                               1 - "IsACompanyHoliday" - To check whether company holiday
                                               2 - "calculateBusinessHoursInMinute" - To calculate business hours
                                               3 - " businessHoursForStartAndEndDate" - To calculate business hours b/w two dates
                        V1.13 -  Modified By - Mahendra Swarnkar - CR-20160729-10075 - 08/27/2016 - Added a new method "isProductionInstance" to identify SB/Production Instance.
    */
    
    public class CustomException extends Exception {}
    public static Boolean IsTesting = false; //flag for triggers: this is just a test, don't do crazy things.
    public static Boolean IsBatch = false; // calling trigger from a batch, no reaction necessary
    public static Boolean IsBreakMe = false; // for testing, request to throw an exception
    public static Boolean ScheduleHasRun = false; //testing Scheduled Apex 
    public static Boolean TrackHistoryHasRun = false;
    public static String TestVariable = ''; //testing various
    
    //Various trigger flags to avoid unnecessary cascades
    public static Boolean IsMembershipOwnerAssociateTrigger = false;
    public static Boolean IsTrigger_WarmLeadMtM = false;
    public static Boolean IsTrigger_EventPrewire = false;
    public static Boolean IsTrigger_EventUpdateFields = false;
    public static Boolean IsTrigger_NBBOppFields = false;
    public static Boolean IsTrigger_ContractFieldUpdate = false;
    public static Boolean IsTrigger_ContractIntegratedAcctRunning = false;
    public static Boolean IsTestingContractIntegratedAcct = false; // Used in Test Method for Contract Integrated Accounts Update Fields and related trigger
    public static Boolean IsTrigger_AccountNameEAMemberships = false;
    public static Boolean IsTrigger_Opportunity_ValidationAndFieldUpdates = false;
    public static Boolean IsTrigger_Task_PopulateNoOfRevisitField = false;
    public static Boolean BypassAllTriggers = false;
    public static Boolean BypassContactRestrictionTrigger = false;
    public static Boolean IsTrigger_Invoice = false; // FOR FFDC fix
    public static Boolean isPopulateInitVisitOnActivities_Future = false;
    
    public static void IsTest(boolean isRunningTest) {
        if (isRunningTest) {
            // bypass dupeblocker and other triggers
            CRMfusionDBR101.DB_Globals.triggersDisabled = true;
            Util.IsTesting = true;
        }
        else {
            // don't bypass dupeblocker
            CRMfusionDBR101.DB_Globals.triggersDisabled = false;
            Util.IsTesting = false;
        }
    }
    
    public static void disableDupeBlocker(boolean disableDB) {
        if (disableDB) {
            // bypass dupeblocker
            CRMfusionDBR101.DB_Globals.triggersDisabled = true;
        }
        else {
            // don't bypass dupeblocker
            CRMfusionDBR101.DB_Globals.triggersDisabled = false;
        }
    }
    
    public static map<String, Id> recordtypemap(String Obj) 
    {
        map<String, Id> returnmap = new map<String, Id>();
        list<Recordtype_Setting__c> rtslist = Recordtype_Setting__c.getall().values();
        
        for (Recordtype_Setting__c rts : rtslist) {
            if (rts.SObjectType__c == Obj) returnmap.put(rts.Name__c, rts.SFID__c);
        }
        return returnmap;
    }
    
    public static Id RecordTypeId(String Obj, String RecordTypeName) 
    {
        Id RetId;
        list<Recordtype_Setting__c> rtslist = Recordtype_Setting__c.getall().values();
        
        for (Recordtype_Setting__c rts : rtslist) {
            if (rts.SObjectType__c == Obj) {
                if (rts.Name__c == RecordTypeName)
                    return rts.SFID__c;
            }
        }
        // if we get here, it means we didn't find the id -- reset all settings and try again
        resetRecordTypeSettings();
        
        rtslist = Recordtype_Setting__c.getall().values();
        for (Recordtype_Setting__c rts : rtslist) {
            if (rts.SObjectType__c == Obj) {
                if (rts.Name__c == RecordTypeName)
                    return rts.SFID__c;
            }
        }
        
        // if we got here, just return null -- we couldn't find the record type id
        return null;
    }
    
    public static void resetRecordtypeSettings()
    {
        /* This will clear out and refill the Custom Settings we use to keep track of Recordtypes. Mostly called only from recordtypemap */
        
        //get list and delete it
        list<Recordtype_Setting__c> rtslist = Recordtype_Setting__c.getall().values();
        delete rtslist;
        
        //Make a new list and insert it
        list<Recordtype_Setting__c> newrtss = new list<Recordtype_Setting__c>();
        list<Recordtype> rts = [select id, SObjectType, Name from RecordType];
        for (Recordtype rt : rts) {
            newrtss.add(new Recordtype_Setting__c(
                SFID__c = String.ValueOf(rt.Id),
                Name = String.ValueOf(rt.Id),
                Name__c = rt.Name,
                SObjectType__c = rt.SObjectType));
        } 
        insert newrtss;
        rtslist = newrtss;
    }
    
    // Account Record Type to Applicable Segment Map
    public static map<string, string> accountRT2SegmentMap {
        get {
            
            if (accountRT2SegmentMap == null) {
                
                //Modified By -Mahendra Swarnkar- CR-20160425-9796 - 5/23/2016 Added the Mapping ['US Independent School'=>'US Independent School']  
                accountRT2SegmentMap = new map<string, string> {
                    'International Corporate'=>'International Corporate',
                    'International Education'=>'International Education',
                    'International HCIC'=>'International HCIC',
                    'International Physician Practice'=>'International Physician Practice',
                    'International Provider'=>'International Hospital',
                    'US Corporate'=>'US Corporate',
                    'US Education'=>'US Education',
                    'US HCIC'=>'US HCIC',
                    'US Provider'=>'US Hospital',
                    'US Provider - System'=>'US Hospital',
                    'US Provider - Hospital'=>'US Hospital',
                    'US Provider Strategic'=>'US Hospital',
                    'US Physician Practice'=>'US Physician Practice',
                    'US Independent School'=>'US Independent School',
                    'Other'=>'Other',
                    'US Physician Practice - Network'=>'US Physician Practice - Network'    
                 };
            }
            
            return accountRT2SegmentMap;
        }
        set;
    }
    
    /*Updated By -Mahendra Swarnkar- CR-20160428-9806 - 5/9/2016 - Transformed this method into a simple apex method 
     *   that calls Batch_Create_Memberships batch to create memberships 
    */
    //Code modified By - Bhavi Sharma - CR-20130531-3103
    //Key and Value('US Provider Strategic'=>'US Hospital') assign in map instance for generate Membership record
    //on Account of "US Provider Strategic" type
    public static void makeMembershipsforAccounts(set<id> accountIds) {
        
        //String to hold the Coma saparated Account Ids
        String idString = '';
        
        //Check for Size
        if(accountIds != null && accountIds.size() > 0){
             
            //Loop through Acount Ids 
            for(ID str : accountIds)
                idString += '\'' + String.valueof(str) + '\',';
    
            idString = idString.lastIndexOf(',') > 0 ? '(' + idString.substring(0,idString.lastIndexOf(',')) + ')' : idString ;
            
            //Check for emptyness of string
            if(String.isNotEmpty(idString)) {
                
                //Query string for Batch
                String queryStr = 'Select ID, Name, Recordtype.Name FROM Account WHERE ID != null AND ID IN ' + idString;
                
                //Batch Instance 
                Batch_Create_Memberships con = new Batch_Create_Memberships();
                con.soqlstr = queryStr;
                
                //Execute the batch to create the Membership records
                Database.executeBatch(con, Integer.valueOf(System.Label.SIZE_FOR_BATCH_CREATE_MEMBERSHIPS));   
            }
        }
    }
    
    @future 
    public static void deleteMemberships(set<id> MembershipIds)
    {
        list<Membership__c> membershipstodelete = [select id from Membership__c where id in :MembershipIds];
        delete membershipstodelete;
    }
    
    @future
    public static void membershipOwnerCheckfromOpps(set<id> selectoppids)
    {
        //For the Opportunity IDs presented, if it is a Renewal Opportunity on a Contract that is Active_Contract_Idenfied__c on a (Prospect Status) Membership, 
        //change the owner on that Membership to be the owner on the renewal Opportunity
        
        //Get list of Memberships by querying Contracts and then Memberships
        Map<Id, Contract__c> cons = new Map<Id, Contract__c>([select Contract_Renewal_Opportunity__r.Membership__c from Contract__c where Contract_Renewal_Opportunity__c in :selectoppids]);
        //set<id> memids = new set<id>();
        //for (Contract__c c : cons) memids.add(c.Contract_Renewal_Opportunity__r.Membership__c);
        
        list<Membership__c> memstocheck = [select id, Assigned_Marketer__r.IsActive, Membership_Status__c, OwnerID, Active_Contract_Idenfied__c, Active_Contract_Idenfied__r.Contract_Renewal_Opportunity__c, 
            Active_Contract_Idenfied__r.Contract_Renewal_Opportunity__r.OwnerID, Active_Contract_Idenfied__r.Contract_Renewal_Opportunity__r.StageName, Assigned_Marketer__c, 
            Active_Contract_Idenfied__r.Contract_Renewal_Opportunity__r.Owner.IsActive  //DAF 12-15-11 added two fields
            from Membership__c
            where Active_Contract_Idenfied__c IN :cons.keySet()];

//      for Membership__c m : memstocheck
//      Map<Id, IsActive> usrActive = new Map<Id, IsActive>();      
 


        list<Membership__c> memstoupdate = new list<Membership__c>();
        
        //Go through Memberships to see if any need changed
        for (Membership__c m : memstocheck) {
            
            system.debug('\n### Membership Status: ' + m.Membership_Status__c);
            
            system.debug('### Membership Status != Prospect - Owner Update (Current Owner=' + m.OwnerId +' / Status=' + m.Membership_Status__c + ' / Active Contract=' + m.Active_Contract_Idenfied__c + ')');
            system.debug('### Active Contract Identified = ' + m.Active_Contract_Idenfied__c + ' Active Renewal Opp = ' + m.Active_Contract_Idenfied__r.Contract_Renewal_Opportunity__c);
            // Set the Membership's Owner equal to the Active Contract's Renewal Opp Owner, if there is an active contract with a renewal Opp.
            if ((m.Active_Contract_Idenfied__c != null) && (m.Active_Contract_Idenfied__r.Contract_Renewal_Opportunity__c != null))
            {
                if ((m.Membership_Status__c.toLowerCase() == 'member - integrated (grace)' ||
                        m.Membership_Status__c.toLowerCase() == 'member - payer (grace)' || m.Membership_Status__c.toLowerCase().contains('prospect')) &&
                        !m.Active_Contract_Idenfied__r.Contract_Renewal_Opportunity__r.stageName.toLowerCase().contains('pending')) {
                            //Sets the Owner equal to the Assigned Marketer, if there is one.
                    if ((m.Assigned_Marketer__c != null) && (m.OwnerID != m.Assigned_Marketer__c)) {
                        system.debug('## (2nd if stmt) MEM CHECK' + m);
                        if (m.Assigned_Marketer__r.IsActive) {
                            system.debug('## (3rd if stmt) MEM CHECK' + m);
                            system.debug('## (Assigned Marketer) Updating member owner id FROM: ' + m.OwnerId + ' TO: ' + m.Active_Contract_Idenfied__r.Contract_Renewal_Opportunity__r.OwnerID);
                            m.OwnerID = m.Assigned_Marketer__c;
                            memstoupdate.add(m);
                        }
                    }
                }
                else if (m.Active_Contract_Idenfied__r.Contract_Renewal_Opportunity__r.Owner.IsActive) {    // DAF 12-15-11 added IF
                    system.debug('### membership being updated to = ' + m.Active_Contract_Idenfied__r.Contract_Renewal_Opportunity__r.OwnerID);
                    m.OwnerID = m.Active_Contract_Idenfied__r.Contract_Renewal_Opportunity__r.OwnerID;
                    memstoupdate.add(m);
                }
                
            }
            
        }
        system.debug('## membership size: ' + memstoupdate);
        if (memstoupdate.size() > 0) update memstoupdate;
    }

    
    @future
    public static void membershipOwnerCheckfromMemberships(set<id> memids)
    {
        //For the Membership IDs presented, if the Renewal Opportunity on the Contract that is Active_Contract_Idenfied__c on a (Prospect Status) Membership, 
        //change the owner on that Membership to be the owner on the renewal Opportunity
        //If membership status contains 'Prospect' then owner = assigned marketer, else owner = owner of active contract renewal opportunity.  
        //there should be a check put in place so that if the relevant field is not populated the owner will not be changed.
        
        list<Membership__c> memstocheck = [select id, Membership_Status__c, OwnerID, Active_Contract_Idenfied__c, Active_Contract_Idenfied__r.Contract_Renewal_Opportunity__c, 
            Active_Contract_Idenfied__r.Contract_Renewal_Opportunity__r.OwnerID, Assigned_Marketer__c, 
            Active_Contract_Idenfied__r.Contract_Renewal_Opportunity__r.Owner.IsActive, Assigned_Marketer__r.IsActive   //DAF 12-15-11 added two fields
            from Membership__c
            where id in :memids];
        
        
        list<Membership__c> memstoupdate = new list<Membership__c>();
        Set<Id> ActiveContractIdentifiedIDs = new Set<Id>();    //DAF added 02-07-12        
        Map<Id, Id> NewMembershipOwner = new Map<Id, Id>();
        Set<Id> MembershipAddedIDs = new Set<Id>(); //DAF added 02-07-12        
        //Go through Memberships to see if any need changed
        for (Membership__c m : memstocheck) {
            
            if(m.Membership_Status__c.toLowerCase().contains('prospect'))
            {
                system.debug('### Membership Status != Prospect - Owner Update (Current Owner=' + m.OwnerId +' / Status=' + m.Membership_Status__c + ' / Assigned Marketer=' + m.Assigned_Marketer__c + ')');
                
                //Sets the Owner equal to the Assigned Marketer, if there is one.
                if ((m.Assigned_Marketer__c != null) && (m.OwnerID != m.Assigned_Marketer__c)) {
                    if (m.Assigned_Marketer__r.IsActive) {
                        m.OwnerID = m.Assigned_Marketer__c;
                        memstoupdate.add(m);
                        NewMembershipOwner.put(m.Active_Contract_Idenfied__c, m.Assigned_Marketer__c);  //DAF added 02-07-12
                        ActiveContractIdentifiedIDs.add(m.Active_Contract_Idenfied__c); //DAF added 02-07-12
                        MembershipAddedIDs.add(m.Id);
                    }
                }
                
            } else {
                system.debug('### Membership Status != Prospect - Owner Update (Current Owner=' + m.OwnerId +' / Status=' + m.Membership_Status__c + ' / Active Contract=' + m.Active_Contract_Idenfied__c + ')');
                
                // Set the Membership's Owner equal to the Active Contract's Renewal Opp Owner, if there is an active contract with a renewal Opp.
                if ((m.Active_Contract_Idenfied__c != null) && (m.Active_Contract_Idenfied__r.Contract_Renewal_Opportunity__c != null))
                {
                    if (m.Active_Contract_Idenfied__r.Contract_Renewal_Opportunity__r.Owner.IsActive) {
                        m.OwnerID = m.Active_Contract_Idenfied__r.Contract_Renewal_Opportunity__r.OwnerID;
                        memstoupdate.add(m);
                        NewMembershipOwner.put(m.Active_Contract_Idenfied__c, m.Active_Contract_Idenfied__r.Contract_Renewal_Opportunity__r.OwnerID);   //DAF added 02-07-12
                        ActiveContractIdentifiedIDs.add(m.Active_Contract_Idenfied__c); //DAF added 02-07-12
                        MembershipAddedIDs.add(m.Id);
                    }
                }
            }   
            
        }

// DAF added below 02-07-12
        for (Membership__c m : [select Id, OwnerId, Active_Contract_Idenfied__c from Membership__c where Active_Contract_Idenfied__c in :ActiveContractIdentifiedIDs and Id not in :MembershipAddedIDs AND Active_Contract_Idenfied__c != null]) {
            if (NewMembershipOwner.containsKey(m.Active_Contract_Idenfied__c)) {
                m.OwnerId = NewMembershipOwner.get(m.Active_Contract_Idenfied__c);
                memstoupdate.add(m);
            }
        }       
// DAF added above 02-07-12
        
        if (memstoupdate.size() > 0) update memstoupdate;
    }
    
    public static Messaging.SingleEmailMessage createSingleEmail(List<String> recipients, String replyTo, String SenderName, String subject, String message)
    {
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        try
        {
            for(String recipient : recipients)
            {
                if(!isValidEmailAddress(recipient))
                {
                    throw new CustomException(recipient + ' is not a valid email address.');
                }
            }
            if(!isValidEmailAddress(replyTo))
            {
                throw new CustomException(replyTo + ' is not a valid email address.');
            }
            mail.setToAddresses(recipients);
            mail.setReplyTo(replyTo);
            mail.setSenderDisplayName(SenderName); 
            mail.setSubject(subject);
            mail.setPlainTextBody(message);
            mail.setHtmlBody(message);
            return mail;
         }
            catch(CustomException e)
            {
                System.debug('***** Error in createSingleEmail: ' + e.getMessage());
                return null;
            }
    }
    
    public static boolean sendSingleEmail(Messaging.SingleEmailMessage email)
    {
        try
        {
            List<Messaging.SendEmailResult> results = Messaging.sendEmail(new Messaging.SingleEmailMessage[] { email });
            if(results.get(0).isSuccess())
            {
                return true;
            }
            else
            {
                return false;
            }
        }
        catch(System.EmailException e)
        {
            System.debug('***** Error in sendSingleEmail: ' + e.getMessage());
            return false;
        }
    }
    
    // make sure that this is a valid email address
    public static boolean isValidEmailAddress(String emailAddress)
    {
        Pattern emailRegex = Pattern.compile('[a-zA-Z0-9._%-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,4}');
        Matcher regexMatcher = emailRegex.matcher(emailAddress);
        if(regexMatcher.matches())
        {
            return true;
        }
        else
        {
            return false;
        }
    } 
    
    // verify that the user has the required permissions on the object
    // @param accessLevel can be: PermissionsRead, PermissionsCreate, PermissionsDelete
    public static Map<String, String> CheckUserPermission(String userId, List<String> objectNames, String accessLevel) {
        // add all object names to the map and associated set (used for query)
        Map<String, String> objToAccessMap = new Map<String, String>();
        for (String objName : objectNames) objToAccessMap.put(objName, '');
        Set<String> objectNameSet = objToAccessMap.keySet();
        Set<String> validAccessLevelOptions = new Set<String> { 'PermissionsRead', 'PermissionsCreate', 'PermissionsDelete' };
        if (userId == null || ObjectNames == null || ObjectNames.size() == 0 || !validAccessLevelOptions.contains(accessLevel)) {
            objToAccessMap = new Map<String, String> { 'Error' => 'invalid data' };
            return objToAccessMap;
        }
        
        boolean isRead, isCreate, isDelete;
        if (accessLevel.contains('PermissionsRead')) isRead = true;
        else if (accessLevel.contains('PermissionsCreate')) isCreate = true;
        else if (accessLevel.contains('PermissionsDelete')) isDelete = true;
        
        try {
            List<User> users = [SELECT Id, ProfileID, Name FROM User WHERE Id = :userId and IsActive = true LIMIT 1];
            if (users.size() == 0){
                objToAccessMap = new Map<String, String> { 'Error' => 'Invalid User Id:' + userId };
                return objToAccessMap;
            }
            
            // set of all unique permission set ids
            Set<Id> permSetIdSet = new Set<Id>();
            // get permission set assignments for one-off permission sets
            List<PermissionSetAssignment> psAssignments = [SELECT AssigneeId, PermissionSetId 
                                                           FROM PermissionSetAssignment 
                                                           WHERE AssigneeId = :users[0].Id];
            for (PermissionSetAssignment psa : psAssignments) permSetIdSet.add(psa.PermissionSetId);
            //get all profile permissions
            map<Id, PermissionSet> profPermissionSets = new map<Id, PermissionSet>([select id from permissionset where PermissionSet.ProfileId = :users[0].ProfileId]);
            permSetIdSet.addAll(profPermissionSets.keySet());
            
            // get the user's object level permissions
            Id profileId = users[0].ProfileId;
            String permissionQuery = 'SELECT Id, SObjectType, PermissionsRead, PermissionsCreate, PermissionsDelete ' +
                                 'FROM ObjectPermissions ' +
                                 'WHERE parentId IN :permSetIdSet ' +
                                 ' AND sObjectType IN :objectNameSet AND ' + accessLevel + ' = true';
            
            // query for object permissions for this user's profile
            List<ObjectPermissions> ops = database.query(permissionQuery);
            system.debug('@@op:' + ops);
            for (ObjectPermissions op : ops) {
                if (op.PermissionsRead && isRead) {
                    objToAccessMap.put(op.SObjectType, 'true');
                }
                else if (op.PermissionsCreate && isCreate) {
                    objToAccessMap.put(op.SObjectType, 'true');
                }
                else if (op.PermissionsDelete && isDelete) {
                    objToAccessMap.put(op.SObjectType, 'true');
                }
                else {
                    objToAccessMap.put(op.SObjectType, 'false');
                }
            }
        }
        catch(exception ex) {
            objToAccessMap.put('Error', ex.getMessage() + '  Stack Trace:' + ex.getStackTraceString());
        }
        
        return objToAccessMap;
        
    }
    
    //Code added by - Bhavi Sharma - 07/11/2013
    //Method for create log of DML insert or update opertion
    public Static String createLog(Database.SaveResult[] saveResults) {
        
        //String to hold Log message
        String logMessage = '';
            
        // Iterate through each returned result
        for (Database.SaveResult saveResult : saveResults) {
            
            //Check for successing
            if (!saveResult.isSuccess()) {
                
                //Operation failed, so get all errors
                for(Database.Error err : saveResult.getErrors()) {
                    System.debug('@@@@@ err.getMessage() ' + err.getMessage());
                    //create log message 
                    logMessage += err.getStatusCode() + '&nbsp;' + err.getMessage() + '<br>';
                }
            }
        }
        
        //return logmessage
        return logMessage;
    }
    
    //Code added by - Bhavi Sharma - 07/11/2013
    //Method for create log of DML delete opertion
    public Static String createLog(Database.DeleteResult[] deleteResults) {
        
        //String to hold Log message
        String logMessage = '';
        
        //Iterate through each returned result
        for(Database.DeleteResult deleteResult : deleteResults) {
            
            //Check for success
            if (!deleteResult.isSuccess()) {
            
                //Operation failed, so get all errors
                for(Database.Error err : deleteResult.getErrors()) {
                    
                    //create log message 
                    logMessage += err.getStatusCode() + '&nbsp;' + err.getMessage() + '<br>';
                }
            }
        }
        
        //return logmessage
        return logMessage;
    }
    
    //Code added by - Bhavi Sharma - 07/11/2013
    //Method for create log of DML upsert opertion
    public Static String createLog(Database.UpsertResult[] upsertResults) {
        
        //String to hold Log message
        String logMessage = '';
        
        //Iterate through each returned result
        for(Database.UpsertResult upsertResult : upsertResults) {
            
            //Check for success
            if (!upsertResult.isSuccess()) {
            
                //Operation failed, so get all errors
                for(Database.Error err : upsertResult.getErrors()) {
                    
                    //create log message 
                    logMessage += err.getStatusCode() + '&nbsp;' + err.getMessage() + '<br>';
                }
            }
        }
        
        //return logmessage
        return logMessage;
    }
    
    /**
     *  @description    :   Method for create log of DML opertion errors in HTML format.
     *
     *  @args           :   Database.Errors[]
     *
     *  @return         :   String
     *
     **/
    public Static String errorHTMLLog(Database.Error [] errors) {

        //String to hold Log message
        String errorHTMLLogs = '';

        //Operation failed, so get all errors
        for(Database.Error err : errors) {

            //create log message
            errorHTMLLogs += '<tr><td>' + err.getStatusCode() + '</td><td>' + err.getMessage() + '</td></tr>';
        }

        //Check if error log is not null
        if(errorHTMLLogs != '')
            errorHTMLLogs = '<table border="1"><tr><th>StatusCode</th><th>Message</th></tr>' + errorHTMLLogs + '</table>';

        //return logmessage
        return errorHTMLLogs;
    }

    /**
     *  @description    :   This method is to send the batch status email
                            Example:
                            global void finish(Database.BatchableContext ctx) {
     *
     *                          Utility.sendBatchStatus(ctx.getJobId(), 'Batch_Example', errors);
     *                      }
     *
     *  @args           :   Batch Id, Batch Name, message
     *
     *  @return         :
     *
     **/
    public Static void sendBatchStatus(Id batchJobId, String batchName, String errors) {

        //Query the asynchronous jobs results
        AsyncApexJob aSyncJob = [SELECT Id, JobItemsProcessed, TotalJobItems, NumberOfErrors, CreatedBy.Email FROM AsyncApexJob
                            WHERE id = :batchJobId];

        // Send email indicating the completion of this batch
        String emailMessage = 'Your batch job \"' + batchName + '\" has finished.  It processed job items'
                    + aSyncJob.totalJobItems +
                    ' batches.  Of which, '
                    + aSyncJob.JobItemsProcessed
                    + ' processed without any exceptions thrown and '
                    + aSyncJob.numberOfErrors
                    + ' batches threw unhandled exceptions.' + '<br>' + errors;

            //Send batch status to the person who executed this batch
        EmailHandler.sendEmail(aSyncJob.CreatedBy.Email, batchName + ' has been completed', emailMessage, errors);
    }
    
    //Added By - Abhinav Sharma - If there are failures in the database.saveResults[], they should be recorded and emailed to SFAdmin. - CR-20130718-3280
    /**
     *  @description    :   This method is to send the batch status email
                            Example:
                            global void finish(Database.BatchableContext ctx) {
     *
     *                          Utility.sendBatchStatus(ctx.getJobId(), 'Batch_Example', errors, 'test@test.com');
     *                      }
     *
     *  @args           :   Batch Id, Batch Name, message, emailRecipient
     *
     *  @return         :   void
     *
     **/
    public Static void sendBatchStatus(Id batchJobId, String batchName, String errors, String emailRecipient) {

        //Query the asynchronous jobs results
        AsyncApexJob aSyncJob = [SELECT Id, JobItemsProcessed, TotalJobItems, NumberOfErrors, CreatedBy.Email FROM AsyncApexJob
                            WHERE id = :batchJobId];

        // Send email indicating the completion of this batch
        String emailMessage = 'Your batch job \"' + batchName + '\" has finished.  It processed job items'
                    + aSyncJob.totalJobItems +
                    ' batches.  Of which, '
                    + aSyncJob.JobItemsProcessed
                    + ' processed without any exceptions thrown and '
                    + aSyncJob.numberOfErrors
                    + ' batches threw unhandled exceptions.' + '<br>' + errors;

        //Send batch status to the person who executed this batch
        EmailHandler.sendEmail(emailRecipient, batchName + ' has been completed', '', emailMessage);
    }    
    
    //Added By - Abhinav Sharma - CR-20140629-6015 - 07/04/2014
    /**
     *  @description    :   This method will return true in case when date passed to it belongs to weekend.
     *
     *  @args           :   Date dateParam
     *
     *  @return         :   boolean
     *
     **/
    public static boolean IsWeekendDay(Date dateParam) {
        
        //Boolean variable will be set to true for weekend date
        Boolean result = false;
        
        //Recover the starting day of the week
        Date startOfWeek = dateParam.toStartOfWeek();
        
        //Days difference count in between the dates
        Integer dayOfWeek  = startOfWeek.daysBetween(dateParam);
        
        //Making decision on the basis of days difference count and accordingly setting the boolean variable 
        result = dayOfWeek == 0 || dayOfWeek == 6 ? true : false;
        
        //Returning resultant boolean value
        return result;
    }
    
    // Modified By - Mahendra Swarnakar - CR-20160609-9913 - 7/7/2016- Addedd logic to included the Company holidays to decide the deadline dates on records 
    //Added By - Abhinav Sharma - CR-20140629-6015 - 07/04/2014
    /**
     *  @description    :   Method responsible to add specific bussiness dayes in a date passed by user to it.
     *                      Will be helpful in setting deadline dates on records.
     *
     *  @args           :   Date startDate, Integer bussinessDaysToAdd, List<Case_Blackout_Days__c >
     *
     *  @return         :   Date
     *
    **/
    public static Date AddBusinessDays(Date startDate, Integer bussinessDaysToAdd, List<Case_Blackout_Days__c > holidays) {
    
        //Checking variables for null value
        if(startDate != null && bussinessDaysToAdd != null) {
      
            //Add or decrease in BusinessDaysToAdd days 
            Date finalDate = StartDate;
            
            //Addition Direction
            Integer direction = bussinessDaysToAdd < 0 ? -1 : 1;

            //Making the days related calculations        
            while(bussinessDaysToAdd != 0) {
        
                //Adding days in user passed date value
                finalDate = finalDate.addDays(direction);
                
                //Modified By - Mahendra Swarnakar - CR-20160609-9913 - 7/7/2016 - Added an extra check to check for the Company holiday 
                //In case of week days reducing the count by direction value               
                if (!isWeekendDay(finalDate)  && IsNotACompanyHoliday(finalDate, holidays)) {
                    bussinessDaysToAdd -= direction;
                }
            }
            
            //Debugging for the final resultant date value
            System.debug('@@@@ Finally Constructed Date ' + finalDate);
            
            //Returning finally constructed date value
            return finalDate;
        }
        
        return null;
   }
   
    /**
     *  @description    :   This method is to get the Department Division Functions by Cost Center values
     *
     *  @args           :   Set of cost centers
     *
     *  @return         :   Map of Department_Division_Function__c
     *
     **/
    public static Map<String, Department_Division_Function__c> getDepartmentDivisionFunctionByCostCenter(Set<String> setCostCenter) {
        
        //Create a Map to hold the Custom Setting data
        Map<String, Department_Division_Function__c> mapDepartmentDivisionFunction = new Map<String, Department_Division_Function__c>();
        
        //Check for the settings
        if(setCostCenter == null || setCostCenter.size() == 0)
            return mapDepartmentDivisionFunction;
        
        //Get Custom Setting Data 
        for(Department_Division_Function__c dDF : [Select Id, Cost_Center__c, Intranet_Department__c, Intranet_Division__c, Intranet_Function__c from Department_Division_Function__c where Cost_Center__c != null AND Cost_Center__c IN: setCostCenter]) {
            
            //Add in map
            if(!mapDepartmentDivisionFunction.containsKey(dDF.Cost_Center__c))
                mapDepartmentDivisionFunction.put(dDF.Cost_Center__c, dDF);
        }
        
        //return mapDepartmentDivisionFunction
        return mapDepartmentDivisionFunction;
    }  
    
    //Added By - Abhinav Sharma - CR-20141218-8363 - 06/02/2015
    /**
     *  @description    :   Method to determine day value for a date
     *
     *  @args           :   Date dateValue
     *
     *  @return         :   String
     *
    **/
    public static String calculateDayOfDate(Date dateValue) {
        
        //String to hold the day value
        String dayValue = '';
        
        //Starting date
        Date startDate = date.newInstance(0001, 1, 1); 
        
        //List to hold the all days
        List<String> listDay = new List<String>{'Saturday' , 'Sunday' , 'Monday' , 'Tuesday' , 'Wednesday' , 'Thursday' , 'Friday'};
        
        //Determining day value for the date field
        Integer remainder = Math.mod(startDate.daysBetween(dateValue) , 7);
        dayValue = listDay.get(remainder);
        
        //returning day value
        return dayValue;
    } 
    
    //Added By - Abhinav Sharma - CR-20141218-8363 - 06/02/2015
    /**
     *  @description    :   Method to determine the difference in between two dates excluding weekends.
     *
     *  @args           :   Date sdate, Date edate
     *
     *  @return         :   Integer
     *
    **/
    public static integer bussinessDaysDifferenceInBetweenDates(Date sdate, Date edate) {
    
      //Processing dates for weekends
      if(Util.calculateDayOfDate(edate) == 'Saturday')
          edate = edate.addDays(+2);
          
      if(Util.calculateDayOfDate(edate) == 'Sunday')
          edate = edate.addDays(+1);
          
      if(Util.calculateDayOfDate(sdate) == 'Saturday')
          sdate = sdate.addDays(-1);
          
      if(Util.calculateDayOfDate(sdate) == 'Sunday')
          sdate = sdate.addDays(-2);
      
      //Total Days in between dates
      integer wDay = sdate.daysBetween(edate) ;
      
      //Weekends days
      integer count = 0;
      
      //Positive use cases
      if(sdate < edate) {
          while (sdate < edate) {
              if (Util.IsWeekendDay(sdate))
                  count = count + 1;
              sdate = sdate.addDays(1);
          }
      }
      
      //Negative use cases
      if(sdate > edate) {
          while (edate < sdate) {
              if (Util.IsWeekendDay(edate))
                  count = count + 1;
              edate = edate.addDays(1);
          }
      }
     
     //Returning the bussiness days difference in between two dates
     if(wDay > 0)
         return (wDay-count);
     else if(wDay < 0)
         return (wDay+count);
     else
         return 0;
    }
    
    /**
      * @Description    :   Check for Null and if yes, then return blank
      *
      * @args           :   String
      *
      * @return         :   string
      *
      **/
    public static String parseNull(String value) {
     
        //Return blank if value is null
        if(value == null)
            return '';
  
        //return original value
        return value;
    }
    
    /**
      * @Description    :   Remove the special characters and digits, then return the formatted value
      *
      * @args           :   String
      *
      * @return         :   string
      *
      * @Version        :   V1.0 - Created By - Mahendra Swarnkar - 12/07/2015 - CR-20151109-9376
      **/
    public static String formatToAlphabatical(String value) {
        if(String.isNotBlank(value))
            return (value.replaceAll('-', ' ')).replaceAll('[^a-zA-Z ]','');
        return value;
    }
    
    
    /**
      * @Description    :   Method to get all the respective company holidays
      *
      * @args           :   
      *
      * @return         :   List<Holiday>
      *
      * @Version        :   V1.0 - Created By - Mahendra Swarnkar - CR-20160609-9913 - 7/7/2016
      **/
    public static List<Case_Blackout_Days__c> companyHolidays() {
        
        //Querying for all company holidays records
        List<Case_Blackout_Days__c> holidays = [SELECT ID, Blackout_Begin_Date__c FROM Case_Blackout_Days__c];
        return holidays;
    }
    
    /**
      * @Description    :   Method to get all the respective company holidays
      *
      * @args           :   
      *
      * @return         :   List<Holiday>
      *
      * @Version        :   V1.0 - Created By - Mahendra Swarnkar - CR-20160609-9913 - 7/7/2016
    **/
    public static List<Case_Blackout_Days__c> LIST_OF_COMPANY_HOLIDAYS {

        get {
            
            if(LIST_OF_COMPANY_HOLIDAYS == null) {
                
                //Retrieve case balck out days from the system which are of non individual type
                LIST_OF_COMPANY_HOLIDAYS = [SELECT ID, Blackout_Begin_Date__c, Blackout_End_Date__c, User__c
                                                FROM Case_Blackout_Days__c
                                                WHERE User__c = null];
            }
            
            //Return value
            return LIST_OF_COMPANY_HOLIDAYS;
        }
    }
    
    /**
      * @Description    :   Method to check that the respective date is a company holiday or not.
      *
      * @args           :   date,List<Case_Blackout_Date__c>
      *
      * @return         :   boolean
      *
      * @Version        :   V1.0 - Created By - Mahendra Swarnkar - CR-20160609-9913 - 7/7/2016
      **/
    public static boolean IsNotACompanyHoliday(Date currentDate, List<Case_Blackout_Days__c> holidays) {
        
        //Check for size
        if(holidays != null && holidays.size() > 0 ) {
            
            //Loop through company holidays
            for(Case_Blackout_Days__c hDay : holidays) {        
                
                //checking for the respective date is a company holiday or not
                if(currentDate.daysBetween(hDay.Blackout_Begin_Date__c ) == 0)
                    return false;
            }
        }
        return true;
    }
    
    //Added By - Abhinav Sharma - 08/23/2016 - CR-20160114-9520
    /**
      * @Description    :   Method to check whether the respective date is a company holiday or not.
      * 
      * @args           :   Date currentDate, List<Case_Blackout_Days__c> holidays
      *
      * @return         :   boolean
      *
      * @Version        :   V1.0 - Created By - Mahendra Swarnkar - CR-20160114-9520 - 08/23/2016
    **/
    public static boolean IsACompanyHoliday(Date currentDate, List<Case_Blackout_Days__c> holidays) {
        
        //Check for size
        if(holidays != null && holidays.size() > 0) { 
            
            //Loop through company holidays
            for(Case_Blackout_Days__c hDay : holidays) {        
                
                //checking for the respective date is a company holiday or not
                if(hDay.Blackout_End_Date__c != null){
                    
                    if(currentDate >= hDay.Blackout_Begin_Date__c && currentDate <= hDay.Blackout_End_Date__c)
                        return true;
                
                } else {
                    if(currentDate.daysBetween(hDay.Blackout_Begin_Date__c) == 0)
                        return true;
                }
            }
        }
        return false;
    }

    //Added By - Abhinav Sharma - 08/23/2016 - CR-20160114-9520
    /**
      * @Description    :   Method to calculate total of business hours in minute for Any time passed in ('8:30 AM/PM') format
      *
      * @args           :   Time in Local Time zone format (String businessTime)
      *
      * @return         :   Integer
      *
      * @Version        :   V1.0 - Created By - Mahendra Swarnkar - CR-20160114-9520 - 08/23/2016
    **/
    //Calculate Business Hours in Minute
    public static Integer calculateBusinessHoursInMinute(String businessTime){
        
        //Split and identify AM and PM
        List<String> splittedBusinessTime = businessTime.split(' ');
        
        //Now split time in Hours and in Minute(e.g. 8:30 AM, here 8 is hour and 30 is minute)
        List<String> splittedTime = splittedBusinessTime[0].split(':');
        
        Integer totalHours = 0;
        
        ////8*60 - Minute
        //Calcualte Hours in minute based on AM and PM
        if(splittedBusinessTime[1].equalsIgnoreCase('AM') && splittedTime[0] != '12')
            totalHours = (Integer.valueOf(splittedTime[0])*60) + Integer.valueOf(splittedTime[1]);
        else if(splittedBusinessTime[1].equalsIgnoreCase('AM') && splittedTime[0] == '12')
            totalHours = Integer.valueOf(splittedTime[1]);
        
        ////(5+12)*60+30 - Minute*/             
        else if(splittedBusinessTime[1].equalsIgnoreCase('PM') && splittedTime[0] != '12')
            totalHours = ((Integer.valueOf(splittedTime[0])+12)*60) + Integer.valueOf(splittedTime[1]);
        else if(splittedBusinessTime[1].equalsIgnoreCase('PM') && splittedTime[0] == '12')
            totalHours = (12*60) + Integer.valueOf(splittedTime[1]);
            
        return totalHours;
    }
    
    //Added By - Abhinav Sharma - 08/23/2016 - CR-20160114-9520
    /**
      * @Description    :   Method to calculate total of business hours in minute for Start Date and End Date
      *
      * @args           :   Start DateTime, EndDateTime, Start BusinessHours In A DAY(e.g. 8:30 AM), 
      *                     End BusinessHours In A Day(e.g. 5:30PM)
      *
      * @return         :   Integer
      *
      * @Version        :   V1.0 - Created By - Mahendra Swarnkar - CR-20160114-9520 - 08/23/2016
    **/
    public static Integer businessHoursForStartAndEndDate(DateTime startDateTime, DateTime endDateTime, List<Case_Blackout_Days__c> holidays){
        
        Integer totalBusinesHoursMinute = 0;
        
        Integer startBuinessHoursMinute = Util.calculateBusinessHoursInMinute(Constants.START_BUSINESS_HOURS);
        Integer endBusinessHoursMinute = Util.calculateBusinessHoursInMinute(Constants.END_BUSINESS_HOURS);
        
        //Now loop between these days and calculate total business days
        for(Date init = startDateTime.date().addDays(1); init<endDateTime.date(); init = init.addDays(1)){
            
            //Skip any calculation if Date is in Weekday or Black Out day/Holiday
            if(Util.IsWeekendDay(init) || Util.IsACompanyHoliday(init, holidays))
                continue;
            
            totalBusinesHoursMinute += (endBusinessHoursMinute-startBuinessHoursMinute);
        }
        
        //Set Start Date Null if Start Date is in weekday and black out day
        startDateTime = Util.IsWeekendDay(startDateTime.date()) || Util.IsACompanyHoliday(startDateTime.date(), holidays) ? null : startDateTime;
        endDateTime = Util.IsWeekendDay(endDateTime.date()) || Util.IsACompanyHoliday(endDateTime.date(), holidays) ? null : endDateTime;
        
        //Check if Start Date Time and End Date Time Matches
        if(startDateTime != null && endDateTime != null && startDateTime.date() == endDateTime.date()){
            
            List<String> formatedStartDateTime = startDateTime.format().split(' ');
            Integer startTimeMinute = calculateBusinessHoursInMinute(formatedStartDateTime[1]+ ' ' + formatedStartDateTime[2]);
            
            List<String> formatedEndDateTime = endDateTime.format().split(' ');
            Integer endTimeMinute = calculateBusinessHoursInMinute(formatedEndDateTime[1] + ' ' + formatedEndDateTime[2]);
            
            //Add start date hourss
            if(startTimeMinute <= startBuinessHoursMinute && endTimeMinute >= endBusinessHoursMinute)
                totalBusinesHoursMinute += (endBusinessHoursMinute - startBuinessHoursMinute);
            else if(startTimeMinute <= startBuinessHoursMinute && endTimeMinute > startBuinessHoursMinute && endTimeMinute < endBusinessHoursMinute)
                totalBusinesHoursMinute += (endTimeMinute - startBuinessHoursMinute);
            else if(startTimeMinute > startBuinessHoursMinute && startTimeMinute < endBusinessHoursMinute && endTimeMinute >= endBusinessHoursMinute)
                totalBusinesHoursMinute += (endBusinessHoursMinute - startTimeMinute);
            else if(startTimeMinute > startBuinessHoursMinute && startTimeMinute < endBusinessHoursMinute && endTimeMinute > startBuinessHoursMinute && endTimeMinute < endBusinessHoursMinute)
                totalBusinesHoursMinute += (endTimeMinute - startTimeMinute);
                
        } else {
            
            //Calculalte if startDateTime is not null
            if(startDateTime != null){
                
                List<String> formatedStartDateTime = startDateTime.format().split(' ');
                Integer startTimeMinute = calculateBusinessHoursInMinute(formatedStartDateTime[1]+ ' ' + formatedStartDateTime[2]);
                
                //Add start date hourss
                if(startTimeMinute <= startBuinessHoursMinute)
                    totalBusinesHoursMinute += (endBusinessHoursMinute - startBuinessHoursMinute);
                else if(startTimeMinute > startBuinessHoursMinute && startTimeMinute < endBusinessHoursMinute)
                    totalBusinesHoursMinute += (endBusinessHoursMinute - startTimeMinute);
            }
            
            if(endDateTime != null){
                
                List<String> formatedEndDateTime = endDateTime.format().split(' ');
                
                Integer endTimeMinute = calculateBusinessHoursInMinute(formatedEndDateTime[1] + ' ' + formatedEndDateTime[2]);
                
                //Add End date hourss
                if(endTimeMinute >= endBusinessHoursMinute)
                    totalBusinesHoursMinute += (endBusinessHoursMinute - startBuinessHoursMinute);
                else if(endTimeMinute < endBusinessHoursMinute && endTimeMinute > startBuinessHoursMinute)
                    totalBusinesHoursMinute += (endTimeMinute - startBuinessHoursMinute);
                
            }   
        }
        
        return totalBusinesHoursMinute;
    }
     
    /**
      * @Description    :   Method to Identify for the Production OR Sandbox Instance.
      *
      * @args           :   
      *
      * @return         :   Boolean
      *
      * @Version        :   V1.0 - Created By - Mahendra Swarnkar - CR-20160729-10075 - 08/27/2016
    **/
    public static Boolean IS_PRODUCTION_INSTANCE {

        get {
            
            //Checking for the null value
            if(IS_PRODUCTION_INSTANCE == null) {
                
                //Setting flag value to false
            	IS_PRODUCTION_INSTANCE = false;
            
                //Fetching organization related details
        		List<Organization> organizations = [SELECT Id, IsSandbox  
                                                    FROM Organization 
                                                    LIMIT 1];
        		
                //Checking for the list size and value
        		if(organizations != null 
                   && organizations.size() > 0 
                   && organizations[0].IsSandbox == false)
             		IS_PRODUCTION_INSTANCE = true;   
        
            }
            
            //Return value
            return IS_PRODUCTION_INSTANCE;
        }
    }
}