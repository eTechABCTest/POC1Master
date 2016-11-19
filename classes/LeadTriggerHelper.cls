/**
 *  Purpose         :   Helper class for Lead trigger
 *
 *  Create By       :   Bhavi Sharma
 *
 *  Created Date    :   01/31/2014
 *
 *  Revision Logs   :   V_1.0 - Created
 *                  :   V_1.1 - Ajit Surana - 4/30/2014 - CR-20140409-5021 - copyAddressToContactOnConversion method modified
 **/
public without sharing class LeadTriggerHelper {
    
    /**
     *  @description    :   This method is to copy the lead address to the contact record when lead is being created
     * 
     *  @args           :   List of new leads, Map of old leads
     * 
     *  @return         :   void
     * 
     **/
    public static void copyAddressToContactOnConversion(List<Lead> newLeads, Map<Id, Lead> mapOldLeads) {
        
        //Set to hold the account records Ids
        Set<Id> setInstitutionIds = new Set<Id>();   
        
        //Loop through lead records
        for(Lead ld : newLeads) {
            if(ld.IsConverted == true && ld.ConvertedAccountId != null 
                && ld.IsConverted != mapOldLeads.get(ld.Id).IsConverted) {
                setInstitutionIds.add(ld.ConvertedAccountId);
            }
        }
        
        //Map of account record
        Map<Id, Account> mapAccounts = new Map<Id, Account>([SELECT ID, Primary_Address_Line_1__c, Primary_City__c, 
                                        Primary_State_Province__c, Primary_Country__c, Primary_Postal_Code__c FROM Account 
                                        WHERE ID IN : setInstitutionIds]);
        
        //Create a list of contacts to be updated
        List<Contact> contacts = new List<Contact>();
        
        //Loop over newly inserted Lead records
        for(Lead lead : newLeads) {
            
            //Check if this is a converted lead
            if(lead.IsConverted == true && lead.ConvertedAccountId != null 
                && lead.IsConverted != mapOldLeads.get(lead.Id).IsConverted) {
                
                //Check if ConvertedAccountId, Address Line 1, City, Country and Postal Code are not null
                if((String.isBlank(lead.Address_Line_1__c) || String.isBlank(lead.City__c) || 
                    String.isBlank(lead.Country__c) || String.isBlank(lead.Postal_Code__c))){
                        
                    //Checking for value in the map
                    if(mapAccounts.get(lead.ConvertedAccountId) != null) {
                    
                        //Account record
                        Account account = mapAccounts.get(lead.ConvertedAccountId);
                    
                        //Populate contact's address data with the lead's related Institute address data
                        contacts.add(new Contact(Id = lead.ConvertedContactId, 
                                                    Primary_Address_Line_1__c  = account.Primary_Address_Line_1__c, 
                                                    Primary_City__c = account.Primary_City__c, 
                                                    Primary_State_Province__c = account.Primary_State_Province__c, 
                                                    Primary_Country__c  = account.Primary_Country__c, 
                                                    Primary_Postal_Code__c = account.Primary_Postal_Code__c));
                    }
                    
                } else{
                    
                    //Populate contact's address data with the lead address data 
                    contacts.add(new Contact(Id = lead.ConvertedContactId, Primary_Address_Line_1__c  = lead.Address_Line_1__c, 
                                            Primary_City__c = lead.City__c, Primary_State_Province__c = lead.State_Province__c, 
                                            Primary_Country__c  = lead.Country__c, Primary_Postal_Code__c = lead.Postal_Code__c));
                }
            }
        }
        
        //Update contacts
        if(contacts.size() > 0)
            update contacts;
    }
}