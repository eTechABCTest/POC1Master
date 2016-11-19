public class ReferenceRequestContactHelper {
    
    /**
     * @description: Submit all Reference Request Contacts for approval
     * 
     *  
     **/
    public static void submitForApproval(set<Id> referenceRequestContactIds) {
        for (Id rrcId : referenceRequestContactIds) {
            
            Approval.ProcessSubmitRequest app = new Approval.ProcessSubmitRequest();
            app.setObjectId(rrcId);
            Approval.ProcessResult result = Approval.process(app);
        }
    }
    
    /**
     * @description: populate the Approver field on all Reference Request Contacts
     * 
     * 
     **/
    public static void populateApprover(list<Reference_Request_Contact__c> refReqContacts) {
        //set of contact ids
        set<Id> contactIds = new set<Id>();
        set<string> applicableModules = new set<string>();
        for (Reference_Request_Contact__c rrc : refReqContacts) {
            contactIds.add(rrc.Reference_Contact__c);
            if (rrc.Reference_Modules__c != null) {
                list<string> modules = rrc.Reference_Modules__c.split('\r\n');
                applicableModules.addAll(modules);
            }
        }
        
        //get all contacts with applicable references
        map<Id, Contact> contactMap = new map<Id, Contact>([SELECT Id, Name, (SELECT Id, Dedicated_Advisor__c, NASA_Principal__c, Reference_Module__c FROM Reference_Modules__r 
                                                                        WHERE Reference_Module__c IN :applicableModules AND Reference_Module__c != null)
                                                            FROM Contact 
                                                            WHERE Id IN :contactIds]);// AND Id IN (SELECT Contact_Name__c FROM Reference__c) [vh commented out 2/2/16]
        
        //match the reference request contact to the related reference
        for (Reference_Request_Contact__c rrc : refReqContacts) {
            Contact c;
            if (contactMap != null)
                c = contactMap.get(rrc.Reference_Contact__c);
            //throw an error if the reference request contac does not have any applicable references
            if (c == null || c.Reference_Modules__r.size() == 0) {
                string name;
                if (c != null && c.Name != null) name = string.escapeSingleQuotes(c.Name);
                rrc.addError('The Contact \'' + name + '\' does not have any applicable references');
            }
            else {
                rrc.Approver__c = c.Reference_Modules__r[0].Dedicated_Advisor__c;
            }
        }
    }
}