/**
 * 
 * Desription      :   	helper class for the IS Use Case object
 * 
 * Revision Logs   :   	v1.0 - Victor Hanson - 10/30/2015 - Created
 * 
 * 
 **/
public class ISUseCaseHelper {
    
    //record type ids for the IS Use Case object
    public final static Id IS_UC_RT_USE_CASE = Schema.SObjectType.IS_Use_Case__c.getRecordTypeInfosByName().get('Use Case').getRecordTypeId();
    public final static Id IS_UC_RT_VERSION_HISTORY = Schema.SObjectType.IS_Use_Case__c.getRecordTypeInfosByName().get('Version History').getRecordTypeId();
    
    /**
     * @description: create a cloned version of the old record when update type is "major" or "minor"
     **/
    public static void cloneOldUC(list<IS_Use_Case__c> useCases, map<Id, IS_Use_Case__c> oldMapUseCases) {
        list<IS_Use_Case__c> useCasesToClone = new list<IS_Use_Case__c>();
        for (IS_Use_Case__c uc : useCases) {
            IS_Use_Case__c oldUC = oldMapUseCases.get(uc.Id);
            if (uc.Versioned_Status__c && 
                uc.Update_Type__c != null && 
                (uc.Update_Type__c.equalsIgnoreCase(Label.UC_Update_Type_Major) ||
                 uc.Update_Type__c.equalsIgnoreCase(Label.UC_Update_Type_Minor))) 
            {
                //add the cloned version of the old UC to our list
                IS_Use_Case__c clonedUC = oldUC.clone();
                clonedUC.Latest_Version__c = uc.Id;
                clonedUC.RecordTypeId = IS_UC_RT_VERSION_HISTORY;
                clonedUC.Use_Case_Reference_Text__c = uc.Use_Case_Reference__c;
                clonedUC.Use_Case_Reference_Unique__c = null;
                clonedUC.Use_Case_Reference_Version__c = uc.Use_Case_Reference__c + '--' + uc.Version_Number__c;
                clonedUC.Status__c = 'Inactive';
                useCasesToClone.add(clonedUC);
            }
        }
        if (useCasesToClone.size() > 0) insert useCasesToClone;
    }
    
    /**
    * @description: update the version number based on the update type
    **/
    public static void incrementVersionNumber(list<IS_Use_Case__c> useCases) {
        for (IS_Use_Case__c uc : useCases) {
            
            if (uc.Versioned_Status__c) {
                //update the version number
                uc.Version_Number__c = getVersionNumber(uc);
                
                //change the update type back to a blank value
                //uc.Update_Type__c = null;
            }
        }
    }
    
    /**
     * @description: return the version number from a use case based on the update type
     **/
    public static string getVersionNumber(IS_Use_Case__c uc) {
        //split the version number
        list<string> versions = uc.Version_Number__c.split('\\.');
        if (versions.size() < 3) throw new customException('Version number should be in the format #.##.##');
        
        integer major = integer.valueOf(versions[0]);
        integer minor = integer.valueOf(versions[1]);
        integer revision = integer.valueOf(versions[2]);
        
        if (uc.Update_Type__c != null) {
            if (uc.Update_Type__c.equalsIgnoreCase(Label.UC_Update_Type_Major)) major += 1;
            else if (uc.Update_Type__c.equalsIgnoreCase(Label.UC_Update_Type_Minor)) minor += 1;
            else if (uc.Update_Type__c.equalsIgnoreCase(Label.UC_Update_Type_Revision)) revision += 1;
        }
        //concatenate the various version types to populate the version number
        return major + '.' + lPad(minor, 2) + '.' + lPad(revision, 2);
    }
    
    /**
     * @description: leftPads the value with the specified number of zeros
     **/
    public static string lPad(integer val, integer numChars) {
        string valStr = string.valueOf(val);
        if (valStr.length() < numChars) valStr = valStr.leftPad(numChars, '0');
        return valStr;
    }
}