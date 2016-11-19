/**
 *  Description     :  Helper class for the ReferenceModule trigger
 *
 *  Revision Logs   :   v1.0 - 12/10/2015 - Created - Victor Hanson - Reference Tracking project (CR-20150826-9191)
 *                  :   V1.1 - 09/05/2016 - Modified - Rajeev Jain - CR-20160809-10096 
 **/
public without sharing class ReferenceTriggerHelper {
    
    public static final string DELIMITER = '; \r\n';
    
    /**
    * @description: return the reference status string for all references for the contact and accounts provided
    **/
    public static string getReferenceStatusString(list<Reference__c> referenceModules) {
        map<string, list<string>> referenceMap = new map<string, list<string>>();
        for (Reference__c reference : referenceModules) {
            list<string> refModules = referenceMap.get(reference.RecordType.Name);
            if (refModules == null) refModules = new list<string>();
            
            if (reference.Reference_Status__c == 'Vetted' && (reference.Reference_Level__c == 'Gold Standard' || reference.Reference_Level__c == 'Ambassador')) {
                refModules.add(reference.Reference_Module__c);
                referenceMap.put(reference.RecordType.Name, refModules);
            }
        }
        
        //add the values to a list
        list<string> refs = new list<string>();
        for (string rtName : referenceMap.keySet()) refs.add(rtName + ': ' + string.join(referenceMap.get(rtName), '; '));
        string retVal = string.join(refs, DELIMITER);
        return retVal;
    }
    
    /**
     * @description: update the Reference Program Status field on the references related Accounts/Contacts
     *               if the Reference Level changes.
     **/
    public static void updateReferenceStatusString(list<Reference__c> referenceModules, map<Id, Reference__c> oldMapReferenceModules) {
        //get a list of all contacts and institutions that need recalculated
        set<Id> cIds = new set<Id>();
        set<Id> aIds = new set<Id>();
        for (Reference__c reference : referenceModules) {
            Reference__c oldModule;
            if (oldMapReferenceModules != null) oldModule = oldMapReferenceModules.get(reference.Id);
            //if reference level has changed, add related contact/account records to the set of ids
            if (reference.Reference_Level__c != null && (oldModule == null || oldModule.Reference_Level__c != reference.Reference_Level__c || oldModule.Reference_Status__c != reference.Reference_Status__c)) {
                cIds.add(reference.Contact_Name__c);
                aIds.add(reference.Institution__c);
            }
        }
        
        if (cIds.size() > 0 || aIds.size() > 0) {
            //get all accounts and contacts and their related reference references
            list<Contact> cons = [SELECT Id, Reference_Program_Status__c, 
                                  (SELECT Id, Reference_Level__c, Reference_Hierarchy__c, Reference_Status__c, Reference_Module__c, RecordType.Name FROM Reference_Modules__r 
                                   WHERE Reference_Level__c != null
                                  ORDER BY RecordType.Name ASC)
                                  FROM Contact WHERE Id IN :cIds];
            list<Account> accts = [SELECT Id, Reference_Program_Status__c, Institution_Reference_Level__c,
                                   (SELECT Id, Reference_Level__c, Reference_Hierarchy__c, Reference_Status__c, Reference_Module__c, RecordType.Name FROM References__r 
                                    WHERE Reference_Level__c != null
                                   ORDER BY RecordType.Name ASC)
                                   FROM Account WHERE Id IN :aIds];
            
            for (Contact c : cons) {
                c.Reference_Program_Status__c = getReferenceStatusString(c.Reference_Modules__r);
            }
            
            for (Account a : accts) {
                a.Reference_Program_Status__c = getReferenceStatusString(a.References__r);
                
                //set the highest reference level (ie: Gold Standard or Ambassador)
                string refLevel = null;
                for (Reference__c reference : a.References__r) {
                    if (reference.Reference_Status__c == 'Vetted') {
                        if (reference.Reference_Level__c == 'Ambassador') {
                            refLevel = 'Ambassador';
                            break;
                        } else if (reference.Reference_Level__c == 'Gold Standard') {
                            refLevel = 'Gold Standard';
                        }
                    }
                }
                a.Institution_Reference_Level__c = refLevel;
            }
            
            util.BypassAllTriggers = true;
            if (cons.size() > 0) update cons;
            
            util.BypassAllTriggers = true;
            if (accts.size() > 0) update accts;
            util.BypassAllTriggers = false;
        }
    }
    
    /**
     * @description:    The starting point is always the Collection Perspective record where Program Collection is ‘Performance Technology’ 
     *                  (same as the record type name on the Reference record) and Perspective is ‘Reference Tracking’.
     *                   
     *                  When there is only one module selected, use the Business Owner on the Collection Perspective Child Record for the selected module.  
     *                  For example, if CCC is selected, then use the Collection Perspective Child record where Collection Perspective is PT-Ref Tracking and Program Collection is CCC.
     *                   
     *                  When multiple modules are selected, use Business Owner on the main Collection Perspective record.
     * 
     **/
    public static Id getReferenceLeadId(string modules, string recordTypeName) {
        Id referenceLeadId;
        list<string> moduleNames = new list<string>();
        list<string> moduleList;
        if (modules != null) moduleList = modules.split(';');
        else {
            return null;
        }
        
        list<string> parentModuleNames = new list<string>(); 
        for (string i : moduleList) {
            //if this is CCC and CMA -- get the business owner for the CCC and CMA collection perspective child.
            //if this is just CMA -- get the business owner for the collection perspective child record for CMA (related to ref tracking - PT[record type name])
            list<string> moduleSplit = i.split(':');
            moduleNames.add(moduleSplit[moduleSplit.size()-1].trim());
            
            //if there are parent modules (ie: panCrimson: aaa or CMA: bbb) selected,
            //record them so we can select the correct collection perspective child record
            if (moduleSplit.size() > 1)
                parentModuleNames.add(moduleSplit[moduleSplit.size()-2].trim());
        }
        
        //create the query
        string qry = 'SELECT Id, Name, Business_Owner__r.Employee_User_Record__c, Program_Perspective__r.Perspective__r.Name, '
            + 'Program_Perspective__r.Program_Group__r.Name, Program_Perspective__r.Business_Owner__r.Employee_User_Record__c '
            + 'FROM Program_Relationship__c '
            + 'WHERE Program_Perspective__r.Perspective__r.Name = \'' + Label.Reference_Tracking + '\' ';
        
        if (parentModuleNames.size() > 0)
            qry += 'AND Program_Perspective__r.Program_Group__r.Name = \'' + parentModuleNames[0] + '\' '; //ie: CMA
        else {
            qry += 'AND Program_Perspective__r.Program_Group__r.Name = \'' + recordTypeName + '\' '; //ie: PT
            //if this is a module with no sub-module (ie: HP, iRound), get the program collection child record's business owner
            qry += 'AND Program_Group__r.Name = \'' + moduleNames[0] + '\'';
        }
        
        system.debug('*******' + qry);
        //dynamically query for program collection records
        list<Program_Relationship__c> programCollections = database.query(qry);
        
        if (programCollections.size() > 0) {
            
            //populate the Reference Lead based on the 2 scenarios below
             if (moduleList.size() == 1) {
                //reference lead is CollectionPerspectiveChild.Business_Owner
                referenceLeadId = programCollections[0].Business_Owner__r.Employee_User_Record__c;
            }
            else {
                //reference lead is CollectionPerspectiveChild.Business_Owner
                referenceLeadId = programCollections[0].Program_Perspective__r.Business_Owner__r.Employee_User_Record__c;
            }
        }      
        
        if (referenceLeadId == null) throw new customException('No Business Owner found for Program Perspective with Program Collection Name in \'' + moduleNames + '\'');
        return referenceLeadId;
    }
    
    /**
     * 
     * @description: set default values for Reference Lead, Dedicated Advisor, and NASA Principal/AP
     * 
     **/
    public static void setReferenceDefaults(list<Reference__c> references) {
        setReferenceLead(references);
        setDedicatedAdvisor(references);
        setNASAPrincipal(references);
    }
    
    //V1.1 - 09/05/2016 - Modified - Rajeev Jain - CR-20160809-10096
    //Changes the logic now to populate Dedicated_Advisor__c field on the Reference each time,
    // 1 - Populate when Dedicated_Advisor__c is null 
    // 2 - check each time on the parent project DA field, if it is different from current DA on Reference then repopulate with Parent Project's DA.
    /**
     * @description: set the Dedicated Advisor field if it's blank
     **/
    public static void setDedicatedAdvisor(list<Reference__c> references) {
        
        //Set to hold the membership Ids
        set<Id> membershipIds = new set<Id>();
        
        //Loop through reference records and populating collection with IDs
        for (Reference__c r : references) {
            if (r.Membership__c != null)
                membershipIds.add(r.Membership__c);
        }
        
        //Checking for size value
        if (membershipIds.size() > 0) {
            
            //get the membership and project info
            map<Id, Membership__c> membershipMap = new map<Id, Membership__c>([SELECT Id, 
                                                                               Primary_Project__r.Dedicated_Advisor__c 
                                                                               FROM Membership__c 
                                                                               WHERE Id IN :membershipIds 
                                                                               AND Primary_Project__c != null]);
            
            //Checking for size value and accordingly bypassing the further logic
            if (membershipMap.size() == 0) 
                return;
            
            //Loop over on references
            for (Reference__c r : references) {
                
                //Get membership records
                Membership__c mem = membershipMap.get(r.Membership__c);
                
                //Now check if DA field is differen then on Primary Project on the Membership 
                if (mem != null 
                    && (
                        r.Dedicated_Advisor__c == null 
                        || 
                        (r.Dedicated_Advisor__c != mem.Primary_Project__r.Dedicated_Advisor__c)
                    )
                ) {
                    //Added due to presence of a validation rule i.e. "Dedicated_Advisor_Required"
            		r.Dedicated_Advisor__c = mem.Primary_Project__r.Dedicated_Advisor__c;
                }
            }
        }
    }
    //V1.1 - 09/05/2016 - Modified - Rajeev Jain - CR-20160809-10096 - Upto here
    
    /**
     * @description: default the Reference Lead field
     **/
    public static void setReferenceLead(list<Reference__c> references) {
        
        //Set to hold the reference IDs
        set<Id> rtIds = new set<Id>();
        
        //loop through reference records
        for (Reference__c r : references) {
            if(r.RecordTypeId != null)
            	rtIds.add(r.RecordTypeId);
        }
        
        //Checking for size value
        if(rtIds.size() > 0) {
            
            //map of all reference record types
        	map<Id, RecordType> recordTypeMap = new map<Id, RecordType>([SELECT Id, Name FROM RecordType WHERE Id IN :rtIds]);
        
            //Loop through reference records
            for (Reference__c r : references) {
                
                //Record type details
                RecordType rt = recordTypeMap.get(r.RecordTypeId);
                
                //reference lead Id
                Id referenceLeadId = getReferenceLeadId(r.Reference_Module__c, rt.Name);
                
                //Checking for null value and populating field with updated value
                if (referenceLeadId != null) 
                    r.Reference_Lead__c = referenceLeadId;
            }
        }
    }
    
    //V1.1 - 09/05/2016 - Modified - Rajeev Jain - CR-20160809-10096
    //Changes the logic now to populate Dedicated_Advisor__c field on the Reference each time,
    // 1 - Populate when r.NASA_Principal__c, r.NASA_Associate_Principal__c are null 
    // 2 - check each time on the parent Contact's,Account's NASA_Principal__c and Associate_Principal__c field and is changed, then repopulate on r.NASA_Principal__c, r.NASA_Associate_Principal__c fields
    /**
     * @description: set the NASA Principal/AP fields if they're blank
     **/
    public static void setNASAPrincipal(list<Reference__c> references) {
        
        //Set to hold the contact Ids
        set<Id> contactIds = new set<Id>();
        
        //Loop through reference records
        for (Reference__c r : references) {
            
            //Checking for field value
            if (String.isNotBlank(r.Member_Type__c) && r.Member_Type__c == 'NASA') {
                if(r.Contact_Name__c != null)
                    contactIds.add(r.Contact_Name__c);
            }
        }
        
        //Checking for size value
        if (contactIds.size() > 0) {
            
            //Map of contact
            map<Id, Contact> cons = new map<Id, Contact>([SELECT Id, AccountId, Account.RecordType.DeveloperName, 
                                                          Account.Principal__c, Account.Associate_Principal__c 
                                                          FROM Contact 
                                                          WHERE Id IN :contactIds]);
            
            //Loop through reference records
            for (Reference__c r : references) {
                
                //Contact
                Contact con = cons.get(r.Contact_Name__c);
                
                //Checking for null value and bypassing the logic accordingly
                if (con == null) 
                    continue;
                
                //Populating institution field on reference record
                r.Institution__c = con.AccountId;
                
                //Checking for field value
                if (con != null 
                	&& String.isNotBlank(r.Member_Type__c) 
                    && r.Member_Type__c == 'NASA') {
                    
                    //if the nasa principal/ap fields are blank, populate them
                    if (r.NASA_Principal__c == null || (r.NASA_Principal__c != con.Account.Principal__c))
                        r.NASA_Principal__c = con.Account.Principal__c;
                    if (r.NASA_Associate_Principal__c == null || (r.NASA_Associate_Principal__c != con.Account.Associate_Principal__c))
                        r.NASA_Associate_Principal__c = con.Account.Associate_Principal__c;
                }
            }
        }
    }
    //V1.1 - 09/05/2016 - Modified - Rajeev Jain - CR-20160809-10096 - Upto  here
    
    /**
     * @description: 
     **/
    public static void setReferenceLead(list<Reference_Request__c> referenceRequests) {
        
        //Set of reference request record type IDs
        set<Id> rtIds = new set<Id>();
        
        //Loop through reference request records
        for (Reference_Request__c r : referenceRequests) {
            
            //Checking for the null value and populating the collection
            if(r.RecordTypeId != null)
            	rtIds.add(r.RecordTypeId);
        }
        
        //Checking for the size value
        if(rtIds.size() > 0) {
			
			//map of all reference record types
        	map<Id, RecordType> recordTypeMap = new map<Id, RecordType>([SELECT Id, Name 
                                                                         	FROM RecordType WHERE Id IN : rtIds]);
        	
            //Loop through reference request records and updating fields values on it's instances
            for (Reference_Request__c r : referenceRequests) {
                
                //Record Type details
                RecordType rt = recordTypeMap.get(r.RecordTypeId);
                
                //Reference Lead ID
                Id referenceLeadId = getReferenceLeadId(r.Reference_Modules__c, rt.Name);
                
                //Checking for null value and set field value
                if (referenceLeadId != null) 
                    r.Reference_Lead__c = referenceLeadId;
            }            
        }
    }
}