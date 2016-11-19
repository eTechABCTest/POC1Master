/*
    Purpose         :   This class is helper class for trigger on User object.
                
    Create By       :   Simplyforce Technology
    
    Created Date    :   01/18/2012
    
    Current Version :   v1.0
    
    Revision Log    :   V_1.1 Created
                        V_1.2 - Bhavi Sharma - 06/14/2013 - CR-20130411-2851
                        V_1.3 Ajit Surana - Added new method (updateOwnerManagerEmailOnOpportunities) -  04/19/2014 - CR-20140403-4951
                        V_1.4 Victor Hanson - Added new method (deactivateInactiveCommunityUsers) -  05/20/2014 - CR-4283
                        V_1.5 Jason Bennett - Added 3 new methods - populateUserInfoOffice,populateUserInfoDept,populateUserInfoWorkspace - 09/19/2014 - CR-6887
                        V_1.6 - Bhavi Sharma - 01/23/2015 - Added new method - deactivateCreditCardsForInactiveUsers - CR-20141209-8273
                        V_1.7 - Ajit Surana - 04/29/2015 - CR-20150112-8537 - Added a new method (updateCTAssignmentManagerEmailOnOpportunities) 
						V_1.8 - Abhinav Sharma - 08/25/2015 - CR-20150820-9167 - Added a new method - (doUpdateOnOpportunitiesOnUserUpdate)
						V_1.9 - Victor Hanson - 11/06/2015 - CR-20150427-8909 - updated method - (updateOwnerManagerEmailOnOpportunities)
*/
public without sharing class UserTriggerHelper {
    
    public final static string RTName_Office = 'Settings_Office';
    public final static string DEFAULT_OFFICE_CODE = 'DC';
    
    //This method is to update the Owner Associate field on membership records when associate gets update for a user record
    public static void updateMembershipRecords(Map<Id, User> usersOldMap, Map<Id, User> usersNewMap) {
        
        //Create a set of users where associate is not null and value is changed from last
        Map<Id, User> mapUser = new Map<Id, User>();
        
        //Loop through the users
        for(User user : usersNewMap.values()) {
            
            //check if associate field is not null and changed from last
            if(usersOldMap.get(user.Id).Associate__c != user.Associate__c) {
                mapUser.put(user.Id, user);
            }
        }
        
        //check all the membership records and Update all the membership records where Owner is from Map
        if(mapUser.size() > 0) {
            
            //Commented By Bhavi Sharma - 06/14/2013 - CR-20130411-2851
            /*/Create a new List of members to be updated
            List<Membership__c> memberships = [Select Id, OwnerId, Owner_Associate__c from Membership__c where OwnerId IN: mapUser.keySet() Limit: (Limits.getLimitQueryRows() - Limits.getQueryRows())];
            
            //fetch all the membership records and populate Owner Associate
            for(Membership__c membership : [Select Id, OwnerId, Owner_Associate__c from Membership__c where OwnerId IN: mapUser.keySet()]) {
                
                //check for the owner and populate the Owner Associate
                if(mapUser.containsKey(membership.OwnerId) && 
                    (mapUser.get(membership.OwnerId).Associate__c != membership.Owner_Associate__c)) {
                    
                    //Update Owner Associate on membership record
                    membership.Owner_Associate__c = mapUser.get(membership.OwnerId).Associate__c;
                    
                    //add membership record in the list to be updated
                    memberships.add(membership);
                }
            }
            
            //Check if there are records to update
            if(memberships.size() > 0) {
                Util.IsMembershipOwnerAssociateTrigger = true;
                update memberships;
            }*/
            
            //Added by Bhavi Sharma - 06/14/2013 - CR-20130411-2851
            Batch_UpdateMembershipOwnerAssociate batchToUpdate = new Batch_UpdateMembershipOwnerAssociate(mapUser);
            Database.executeBatch(batchToUpdate, 200);
        }
    }
    
    //Added by Ajit Surana - 04/19/2014 - CR-20140403-4951
    //VH Updated 11/06/2015 - CR-20150427-8909
    /**
     *  @description    : This method update "Owner Manager Email" on Opportunity records when Manager has been updated on User record.
     * 
     *  @args           : List of new User records, Map of old User records
     * 
     *  @return         : void
     * 
     **/
    public static void updateOwnerManagerEmailOnOpportunities(List<User> newUsers, Map<Id, User> mapOldUsers) {
        
        //Set to hold the user manager Ids when Manager has been updated on User record
        Set<Id> setOwnerUsers = new Set<Id>();
        
        //Loop through user records
        for(User usr : newUsers) {
            
            if(mapOldUsers.get(usr.Id) != null && usr.IsActive == true && mapOldUsers.get(usr.Id).ManagerId != usr.ManagerId)
                setOwnerUsers.add(usr.Id);
        }
        
        //Fetch all the opportunities where user is stamped as Owner and update opportunity?s Owner Manager Email with user 
        //manager email field value.
        List<Opportunity> opportunities = new List<Opportunity>();
        
		//VH Updated 11/06/2015 - CR-20150427-8909
        list<Opportunity> opps = [SELECT ID, Owner_Manager_Email__c, OwnerID, Owner.ManagerId, Owner.Manager.Email FROM Opportunity WHERE OwnerId IN : setOwnerUsers];
        
        //if opp size is greater than dmlRowLimit, start batch and return without attempting to update the opportunities
        if (opps.size() > Limits.getLimitDMLRows()) {
            Batch_OpportunityUpdateManagerEmail oppUpdateManagerBatch = new Batch_OpportunityUpdateManagerEmail(setOwnerUsers);
            database.executeBatch(oppUpdateManagerBatch, 1);
            return;
        }
        
        //Loop through opportunities where user is stamped
        for(Opportunity opp : opps) {
            if(opp.Owner.Manager.Email != opp.Owner_Manager_Email__c) {
                opp.Owner_Manager_Email__c = opp.Owner.Manager.Email;
                opportunities.add(opp);
            }
        }
        
        //Checking for list size
        if(opportunities.size() > 0) {
            Util.BypassAllTriggers = true;
            update opportunities;
            Util.BypassAllTriggers = false;
        }
    }

    //Added by Ajit Surana - 04/29/2015 - CR-20150112-8537
    /**
     *  @description    : This method will going to populate the email of Manager field on CT Assignment user detail page into the new "CT Assignment's Manager" field.
     * 
     *  @args           : List of new User records, Map of old User records
     * 
     *  @return         : void
     * 
     **/
    public static void updateCTAssignmentManagerEmailOnOpportunities(List<User> newUsers, Map<Id, User> mapOldUsers) {
      
        //Set to hold the user manager Ids when Manager has been updated on User record
        Set<Id> setOwnerUsers = new Set<Id>();

        //Loop through user records
        for(User usr : newUsers) {
        
            if(mapOldUsers != null && mapOldUsers.get(usr.Id) != null && usr.IsActive == true 
               	&& mapOldUsers.get(usr.Id).ManagerId != usr.ManagerId)
            	setOwnerUsers.add(usr.Id);
        }

        //Fetch all the opportunities where user is stamped as CT Assignment's manager and update opportunity's CT //Assignment's manager with user manager email field value.
        List<Opportunity> opportunities = new List<Opportunity>();   

        //Loop through opportunities where CT Assignment field is stamped
        for(Opportunity opp : [SELECT ID, CT_Assignment_s_Manager__c, CT_Assignment__c, CT_Assignment__r.ManagerId, 
                               	CT_Assignment__r.Manager.Email FROM Opportunity 
                                WHERE CT_Assignment__c != null AND CT_Assignment__c IN : setOwnerUsers]) {
        
            if(opp.CT_Assignment__r.Manager.Email != opp.CT_Assignment_s_Manager__c) {
                opp.CT_Assignment_s_Manager__c = opp.CT_Assignment__r.Manager.Email;
                opportunities.add(opp);
            }
        }

        //Checking for list size
        if(opportunities.size() > 0)
            update opportunities;
    }
    
    /**
    *
    *   @description: 
    *
    **/
    public static list<User> deactivateInactiveCommunityUsers(list<User> communityUsers) {
        
        //create a list of users with no active items
        list<User> usersToDeactivate = new list<User>();
        
        //get a map of Contact Id -> User contact ids associated with these users
        map<Id, User> contactIdToUserMap = new map<Id, User>();
        for (User u : communityUsers) if (u.ContactId != null) contactIdToUserMap.put(u.ContactId, u);
        
        //get all open cases for these users group by contactId and Id
        list<AggregateResult> openCases_AR = [SELECT Id, ContactId FROM Case 
                                              WHERE IsClosed = false AND ContactId IN :contactIdToUserMap.keySet()
                                              GROUP BY ContactId, Id];
        
        //get all active project roles associated with projects
        list<AggregateResult> activeProjectRoles_AR = [SELECT Id, Contact__c FROM Project_Role__c 
                                                    WHERE SIAM_Portal_Status__c = 'Active' AND Contact__c IN :contactIdToUserMap.keySet()
                                                    GROUP BY Contact__c, Id];
        
        //create a map of contact ids and related open case / active role ids
        map<Id, set<Id>> contactIdToActiveItems = new map<Id, Set<Id>>();
        
        //setup the map of contact id to set of ids
        for (Id cId : contactIdToUserMap.keySet()) {
            
            contactIdToActiveItems.put(cId, new set<Id>());
        }
        
        //add open cases to active items
        for (AggregateResult ar : openCases_AR) {
            
            set<Id> idSet = contactIdToActiveItems.get((string) ar.get('ContactId'));
            if (idSet == null) idSet = new set<Id>();
            
            idSet.add((string) ar.get('Id'));
            contactIdToActiveItems.put((string) ar.get('ContactId'), idSet);
        }
        
        for (AggregateResult ar : activeProjectRoles_AR) {
            
            set<Id> idSet = contactIdToActiveItems.get((string) ar.get('Contact__c'));
            if (idSet == null) idSet = new set<Id>();
            
            idSet.add((string) ar.get('Id'));
            contactIdToActiveItems.put((string) ar.get('Contact__c'), idSet);
        }
        
        for (User u : communityUsers) {
            
            system.debug('@@:' + u + '  ' + contactIdToActiveItems.get(u.ContactId));
            //if the number of active items for this user's contact is 0, deactivate them
            if (contactIdToActiveItems.get(u.ContactId) == null || contactIdToActiveItems.get(u.ContactId).size() == 0) {
                
                u.IsActive = false;
                usersToDeactivate.add(u);
            }
        }
        
        system.debug('@@UsersToDeactivate:' + usersToDeactivate);
        return usersToDeactivate;
    }
    
    /**
     *  @description    :   This method is to check if the User in being inserted or Updated(Cost Center Changes), then populate the values from Custom Setting
     * 
     *  @args           :   List of new users, Map of old users
     * 
     *  @return         :   void 
     * 
     **/
    public static void updateCostCenterRelatedData(List<User> newUsers, Map<Id, User> mapOldUsers)  {
        
        //Set for Cost  Center
        Set<String> setCostCenters = new Set<String>();
        
        //Loop through the records and prepare a set of Cost Center Id
        for(User user : newUsers) {
            
            //Chekc for the cost center
            //Either the record is new or Cost Center has been updated from last one
            if(String.isNotBlank(user.Cost_Center__c) 
                &&  (mapOldUsers == null || user.Cost_Center__c != mapOldUsers.get(user.Id).Cost_Center__c)) {
                
                //Add in Set
                setCostCenters.add(user.Cost_Center__c);
            }
        }
        
        //Check for the setCostCenters
        if(setCostCenters.size() > 0) {
            
            //Map to hold the DDF custom Setting data, key = Cost Center, Value = Record
            Map<String, Department_Division_Function__c> mapDDF = Util.getDepartmentDivisionFunctionByCostCenter(setCostCenters);
            
            //Loop through the records and Update the data
            for(User user : newUsers) {
                
                //Check for the cost center
                //Either the record is new or Cost Center has been updated from last one
                if(String.isNotBlank(user.Cost_Center__c) 
                    && (mapOldUsers == null || user.Cost_Center__c != mapOldUsers.get(user.Id).Cost_Center__c)
                    && mapDDF.containsKey(user.Cost_Center__c)) {
                        
                    //Depratment division function
                    if(mapDDF.keySet().contains(user.Cost_Center__c)){
                        Department_Division_Function__c dDF = mapDDF.get(user.Cost_Center__c);
                    
                        //Set Values
                        user.ABC_Department__c = dDF.Intranet_Department__c;
                        user.ABC_Division__c  = dDF.Intranet_Division__c;
                        user.ABC_Function__c = dDF.Intranet_Function__c;
                    }
                    system.debug('here!');
                        
                }
            }
        }
    }
    
    /**
     *  @description    :   This method is to update several User fields based on the Location_Code__c, which is updated by an integration with Workday.
     * 
     *  @args           :   List of new users, Map of old users
     * 
     *  @return         :   void 
     * 
     **/
    public static void populateUserInfoOffice(List<User> updatedUsers, map<Id,User> oldUserRec ){
        
        //If the Location_Code__c field values change...
        List<User> usersToUpdateOffice = new list<User>();
        Set<Id> userIds = new set<Id>();
        
        for(User u1 : updatedUsers){
            if(u1.Id != null && u1.Location_Code__c != oldUserRec.get(u1.Id).Location_Code__c){
                usersToUpdateOffice.add(u1);
                userIds.add(u1.Id);
            }
        }
        
        map<String,Id> Offices = new map<String,Id>();
        for(Intranet_Item__c o : [select id, Location_Code__c from Intranet_Item__c where RecordType.DeveloperName = :RTName_Office and Active_Status__c = 'Active' order by Office_Short_Name__c]){
            if(o.Location_Code__c != null && o.Location_Code__c != ''){
                Offices.put(o.Location_Code__c,o.Id);
            }
        }
        system.debug('UserTriggerHelper.populateUserInfoOffice - Offices map:'+Offices);
        
        for(User u2 : usersToUpdateOffice){
            if(u2.Location_Code__c == null || u2.Location_Code__c == ''){
                u2.Location_Code__c = DEFAULT_OFFICE_CODE;
            }
            if(Offices.containsKey(u2.Location_Code__c)){
                u2.Office__c = Offices.get(u2.Location_Code__c);
            }
        }
    }
    
        /**
     *  @description    :   This method is to update several User fields based on the Cost_Center__c, which is updated by an integration with Workday.
     * 
     *  @args           :   List of new users, Map of old users
     * 
     *  @return         :   void 
     * 
     **/
    /*
    public static void populateUserInfoDept(List<User> updatedUsers, map<Id,User> oldUserRec ){
        
        //If the Cost_Center__c field values change...
        List<User> usersToUpdateDept = new list<User>();
        
        for(User u1 : updatedUsers){
            if(u1.Cost_Center__c != oldUserRec.get(u1.Id).Cost_Center__c){
                usersToUpdateDept.add(u1);
            }
        }
        
        //get the list of Cost Centers and related info
        map<string,Department_Division_Function__c> ddf = new map<string,Department_Division_Function__c>();
        if(usersToUpdateDept.size() > 0){
            ddf = Department_Division_Function__c.getAll();
        }

        //if there are values in the custom setting, continue...
        if(ddf.keySet().size() > 0){
     
            //make a new map based on the Cost_Center field
            map<string,Department_Division_Function__c> ccDDF = new map<string,Department_Division_Function__c>();
            for(Department_Division_Function__c d : ddf.values()){
                ccDDF.put(d.Cost_Center__c,d);
            }
        
            for(User u2 : usersToUpdateDept){
                if(ccDDF.containsKey(u2.Cost_Center__c)){
                    u2.ABC_Department__c = ccDDF.get(u2.Cost_Center__c).Intranet_Department__c;
                    u2.ABC_Division__c = ccDDF.get(u2.Cost_Center__c).Intranet_Division__c;
                    u2.ABC_Function__c = ccDDF.get(u2.Cost_Center__c).Intranet_Function__c;
                }else{
                    u2.ABC_Department__c = '';
                    u2.ABC_Division__c = '';
                    u2.ABC_Function__c = '';
                }
            }
        }
                
       
    }  */
    
    /**
     *  @description    :   This method is to mark all the Active Created cards deactivated whenever a related user in marked as InActive in Salesforce
     * 
     *  @args           :   List of users
     *  
     *  @return         :   void
     * 
     **/
    public static void deactivateCreditCardsForInactiveUsers(List<User> users, Map<Id, User> mapOldUsers) {
        
        //Loop through the users records and createa set of AnActive users
        Set<Id> usersInActive = new Set<Id>();
        
        for(User user : users) {
            
            //Chekc if the user was Active aearlier and now marked has been InActive
            if(user.IsActive ==  false && mapOldUsers.get(user.Id).IsActive == true) {
                
                //Add in Set
                usersInActive.add(user.Id);
            }
        }
        
        //Check for the set size and fetch the related cards
        if(usersInActive.size() > 0) {
            
            //Resord Type Credit Card request
            List<RecordType> recordTypeOSRCreditCardRequest =[Select Id from RecordType where SObjectType = 'OSR__c' 
                                                            AND DeveloperName =: CreditCardConstants.OSR_RECORD_TYPE_DEVELOPER_NAME_CREDIT_CARD_REQUEST 
                                                            AND IsActive = true limit 1];
            
            ///List of OSRs to be created
            List<OSR__c> oSRs = new List<OSR__c>();
            
            //Map of portfolios to be deactivated
            Map<Id, Portfolio__c> mapPortfolios = new Map<Id, Portfolio__c>();
            
            //Fetch the related card records from Credit Card
            for(Credit_Card__c creditCard : [Select Id, Payment_Account__c, Payment_Account__r.Card_Holder__c from Credit_Card__c where Payment_Account__r.Card_Holder__r.Employee_User_Record__c IN: usersInActive]) {
                
                //Create a separate OSR record for each Card deactivation.
                //Creating an OSR will execute the OSRT trigger and then trigger will execute the Batch_ProcessOSRs to handle teh deactivation request
                oSRs.add(new OSR__c(Origin__c = CreditCardConstants.OSR_ORIGIN_TRAVEL_PORTAL, RecordTypeId = recordTypeOSRCreditCardRequest[0].Id, 
                                Request_Type__c = CreditCardConstants.OSR_REQUEST_TYPE_DEACTIVATE_ABC_CREDIT_CARD, Status__c = CreditCardConstants.OSR_STATUS_NEW, 
                                Related_Card__c = creditCard.Id, Contact__c = creditCard.Payment_Account__r.Card_Holder__c));
                
                //Add in Map to mark the Portfolio InActive
                //Updated by Mahendra Swarnakar - CR-20150901-9211 - 9/9/2015
                mapPortfolios.put(creditCard.Payment_Account__c, new Portfolio__c(Id = creditCard.Payment_Account__c, Status__c = CreditCardConstants.PORTFOLIO_STATUS_DEACTIVATED, Deactivation_Reason__c = CreditCardConstants.EMPLOYEE_NO_LONGER_EXISTS));
            }
            
            //Scheduled class
            Scheduler_DeactiveRelatedCards sched = new Scheduler_DeactiveRelatedCards();
            sched.oSRs = oSRs;
            sched.portfolios = mapPortfolios.values();
            
            //CRON_EXP 
            String day = string.valueOf(system.now().day());
            String month = string.valueOf(system.now().month());
            String hour = string.valueOf(system.now().hour());
            String minute = string.valueOf(system.now().minute() + 1);
            String second = string.valueOf(system.now().second());
            String year = string.valueOf(system.now().year());
        
            String strJobName = 'Job-' + second + '_' + minute + '_' + hour + '_' + day + '_' + month + '_' + year;
            String CRON_EXP = '0 ' + minute + ' ' + hour + ' ' + day + ' ' + month + ' ?' + ' ' + year;
            System.schedule(strJobName, CRON_EXP, sched);
        }
    }
    
    //Added by Abhinav Sharma - CR-20150820-9167 - 08/25/2015
    /**
     *  @description    : If any update happens on user "FirstName" or "LastName" field then this method will update all of opportunity
     * 					  records where that user was stamped there as "Marketer". They will ultimate keep the "Marketer Name" field
     * 					  in sync on those records.
     * 
     *  @args           : List of new User records, Map of old User records
     * 
     *  @return         : void
     * 
    **/
	public static void doUpdateOnOpportunitiesOnUserUpdate(List<User> users, Map<Id, User> mapOldUsers) {
        
        //Set to hold the user records Id value
        Set<Id> setEligibleUsersIds = new Set<Id>();
        
        //Loop through user records
        for(User usr : users) {
            
            //Checking for "FirstName" and "LastName" field's update on user records
            //Accordingly populating the set with Id values
            if(mapOldUsers != null
            	&& (
                	mapOldUsers.get(usr.Id).FirstName != usr.FirstName
                    ||
 					mapOldUsers.get(usr.Id).LastName != usr.LastName
                ) 
            ){
            	setEligibleUsersIds.add(usr.Id);    
            }
        }
        
        //Checking set for size value
        if(setEligibleUsersIds.size() > 0) {
            
            //Map of opportunities going to be update to keep the fields in sync
            Map<Id, Opportunity> mapOpportunities = new Map<Id, Opportunity>();
            
            //Loop through opportunity records and populating map accordingly
            for(Opportunity opp : [SELECT ID, Marketer__c FROM Opportunity
                                  	WHERE Marketer__c != null AND Marketer__c IN : setEligibleUsersIds]) {
                mapOpportunities.put(opp.Id, opp);
            }
            
            //Checking map for size value
            if(mapOpportunities.values().size() > 0)
                update mapOpportunities.values();
        }
    }
    
    //Added by Colin McGloin - 08/08/2016 - CR-20150112-9762
    /**
     *  @description    : Grabs all of the User Ids and passes through to the @Future method as needed
     * 
     *  @args           : List of new User records
     * 
     *  @return         : void
     * 
     **/ 
    
    public static void checkForOrCreateApproverRecord(List<User> users) {
        
        //List to contain all of the Ids
        List<Id> allUserIds = new List<Id> ();
        
        for (User usr : users){
            allUserIds.add(usr.Id);
        }
        
        //Pass the Ids through to the Future Method
        if (allUserIds.size() > 0){
            checkForOrCreateApproverRecordFuture(allUserIds);
        }
        
    }

	//Added by Colin McGloin - 08/08/2016 - CR-20150112-9762
    /**
     *  @description    : This method will insert a Steelbrick Approver record for the user when they are inserted
     * 
     *  @args           : List of new User Ids
     * 
     *  @return         : void
     * 
     **/
    @future
    public static void checkForOrCreateApproverRecordFuture(List<Id> users) {
        
        //List to hold the Users passed through
        List<User> UsersForApprovals = new List <User>();
        //List to hold new Steelbrick Approver records if needed
        List<sbaa__Approver__c> newApprovers = new List<sbaa__Approver__c>();
        
        UsersForApprovals = [SELECT Id,Name, UserType FROM User WHERE Id IN :Users];
        
        if (UsersForApprovals.size() > 0){
            
            for (User nUser : UsersForApprovals){
                if(nUser.UserType == 'Standard'){
                    //Add an Approver record if the new User is a Standard user
                    sbaa__Approver__c newApp = new sbaa__Approver__c (sbaa__User__c = nUser.Id, Name = nUser.Name);
                    newApprovers.add(newApp);
                }
            }
        }
        
        //If the list is greater than 0 then insert the new Approver records
        if (newApprovers.size() > 0){
            insert newApprovers;
        }
        
    }
}