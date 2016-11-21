/**
 * Desription      :   	test class for the ISUseCaseHelper class
 * 
 * Revision Logs   :   	v1.0 - Victor Hanson - 10/30/2015 - Created
 **/
@isTest
public class Test_ISUseCaseHelper {
	
    //static title so we can query for the record easily
    public static string ucTitle = 'Use Case 122';
    
    @testsetup
    static void setup() {
        //create IS Use Case
        IS_Use_Case__c uc = new IS_Use_Case__c(Title__c=ucTitle,
                                               RecordTypeId = ISUseCaseHelper.IS_UC_RT_USE_CASE,
                                               Status__c = 'Active',
                                               Update_Type__c = Label.UC_Update_Type_Major);
        insert uc;
    }
    
    /**
     * @description: Create a Use Case, change the Update Type to Major, Minor, Revision, and Major again
     * 				 Validate that the Version Number is updated properly.  
     * 				 Major or Minor update types should result in the creation of a new IS Use Case record with record type 'Version History'.
     **/
    static testmethod void testUpdateVersionNumber() {
        //get the initial version number and make some initial assertions
        IS_Use_Case__c uc = [SELECT Id, Version_Number__c, Update_Type__c, Status__c, Description__c FROM IS_Use_Case__c WHERE Title__c = :ucTitle LIMIT 1];
        system.assertEquals('1.00.00', uc.Version_Number__c, 'The use case was inserted with update type = "Major", so the version should be 1.00.00');
        system.assertEquals(null, uc.Update_Type__c, 'The Update Type field should change back to null after every save.');
        
        //make an update and change update type to "Minor"
        uc.Description__c = 'Updated description!';
        uc.Update_Type__c = Label.UC_Update_Type_Minor;
        update uc;
        
        //get the updated use case and make assertions
        uc = [SELECT Id, Version_Number__c, Update_Type__c, Status__c, Description__c FROM IS_Use_Case__c WHERE Id = :uc.Id];
        system.assertEquals('1.01.00', uc.Version_Number__c, 'The use case was inserted with update type = "Minor", so the version should be 1.01.00');
        system.assertEquals(null, uc.Update_Type__c, 'The Update Type field should change back to null after every save.');
        
        //make a revision
        uc.Update_Type__c = Label.UC_Update_Type_Revision;
        update uc;
        
        //get the updated use case and make assertions
        uc = [SELECT Id, Version_Number__c, Update_Type__c, Status__c, Description__c FROM IS_Use_Case__c WHERE Id = :uc.Id AND RecordTypeId = :ISUseCaseHelper.IS_UC_RT_USE_CASE];
        system.assertEquals('1.01.01', uc.Version_Number__c, 'The use case was inserted with update type = "Revision", so the version should be 1.01.01');
        
        //make some update and change Update Type = "Major"
        uc.Description__c = 'Major Update To The Description';
        uc.Update_Type__c = Label.UC_Update_Type_Major;
        update uc;
        
        uc = [SELECT Id, Version_Number__c, Update_Type__c, Status__c, Description__c FROM IS_Use_Case__c WHERE Id = :uc.Id AND RecordTypeId = :ISUseCaseHelper.IS_UC_RT_USE_CASE];
        system.assertEquals('2.01.01', uc.Version_Number__c, 'The use case was inserted with update type = "Major", so the version should be 2.01.01');
        IS_Use_Case__c ucHistory = [SELECT Id, Version_Number__c, Update_Type__c, Status__c, Description__c FROM IS_Use_Case__c WHERE Title__c = :ucTitle AND RecordTypeId = :ISUseCaseHelper.IS_UC_RT_VERSION_HISTORY AND Version_Number__c = '1.01.01' ORDER BY CreatedDate DESC LIMIT 1];
        system.assertEquals('1.01.01', ucHistory.Version_Number__c, 'The version history record should reflect the last updated values, so the version should be 1.01.01');
    }
}