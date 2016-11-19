@isTest
private class Test_AttributeIcons {

	//public static Id isSCId;
	//public static Id sfdcRelId;
	//public static Id sfdcCRId;
	//public static Id isSMId;
	public static final string isscName = 'This ThisCrazyTestField';

    @testSetup
    static void setup() {
        //create the is system component
        IS_System_Component__c isSC = new IS_System_Component__c(RecordTypeId = Schema.SObjectType.IS_System_Component__c.getRecordTypeInfosByName().get('Configuration').getRecordTypeId(),
                                              Name = 'will-autopopulate',
                                              Object_Type__c = 'Custom Field',
                                              Object_Label__c = isscName,
                                              Object_API_Name__c = isscName,
                                              Integration_Use__c = TRUE,
                                              Managed_Package_Related__c = TRUE,
                                              SOX_Object__c = TRUE);
        insert isSC;
        //isSCId = isSC.Id;
        
        //create the release
        SFDC_Release__c sfdcRel = new SFDC_Release__c(Name = 'Test Release 2');
        insert sfdcRel;
        //sfdcRelId = sfdcRel.Id;

        //create the change request
        SFDC_Change_Request__c sfdcCR = new SFDC_Change_Request__c(RecordTypeId = Schema.SObjectType.SFDC_Change_Request__c.getRecordTypeInfosByName().get('Level II').getRecordTypeId(),
        									  	Title__c = 'Test Change Request',
        									  	Release__c = sfdcRel.Id);
        insert sfdcCR;
        //sfdcCRId = sfdcCR.Id;

        //create the is system modification
        IS_System_Modification__c isSM = new IS_System_Modification__c(RecordTypeId = Schema.SObjectType.IS_System_Modification__c.getRecordTypeInfosByName().get('Complex').getRecordTypeId(),
                                                 IS_System_Component__c = isSC.Id,
                                                 Change_Request__c = sfdcCR.Id,
                                                 Type_of_Modification__c = 'Add',
                                                 High_Impact_Mod__c = TRUE,
                                                 High_Impact_Mod_Type__c = 'Deletion',
                                                 Duplicate_Mod_On_CR__c = TRUE,
                                                 Duplicate_Mod_On_Release__c = TRUE,
                                                 Double_Deployment__c = TRUE);
        insert isSM;
        //isSMId = isSM.Id;
       
    }
	
	static testmethod void test_AttributeISSysComponentExtension() {
		
		Component.Apex.OutputPanel pnl1;
		Component.Apex.OutputPanel pnl2;
		Boolean scIntegrationUse = false;
		Boolean scManagedPackage = false;
		Boolean scSOXObject = false;
		Boolean smIntegrationUse = false;
		Boolean smManagedPackage = false;
		Boolean smSOXObject = false;
		Boolean smHighImpact = false;
		Boolean smDoubleDeployment = false;
		Boolean smDuplicateCR = false;
		Boolean smDuplicateRel = false;

		//Get the IS Sys Comp record
		//system.debug('isSCId:'+isSCId);
		//IS_System_Component__c isSysComp = [SELECT Id, Name FROM IS_System_Component__c WHERE Id = :isSCId];
		IS_System_Component__c isSysComp = [SELECT Id, Name FROM IS_System_Component__c WHERE Object_Label__c = :isscName];
		system.debug('Test_AttributeIcons.test_AttributeISSysComponentExtension - isSysComp: '+isSysComp);

		//Get the IS Sys Mod record
		IS_System_Modification__c isSysMod = [SELECT Id, Name FROM IS_System_Modification__c WHERE IS_System_Component__c = :isSysComp.Id];
		system.debug('Test_AttributeIcons.test_AttributeISSysComponentExtension - isSysMod: '+isSysMod);

		//Run the test
		test.startTest();
		
		//Test with the IS System Component record
		ApexPages.StandardController sc1 = new ApexPages.StandardController(isSysComp);
		AttributesISSysComponentExtension AttrSysCompExt1 = new AttributesISSysComponentExtension(sc1);
		pnl1 = AttrSysCompExt1.getDynamicOutputPanel();
		scIntegrationUse = AttrSysCompExt1.isIntegration;
		scManagedPackage = AttrSysCompExt1.isManagedPackage;
		scSOXObject = AttrSysCompExt1.isSOX;

		//Test with the IS System Modification record
		ApexPages.StandardController sc2 = new ApexPages.StandardController(isSysMod);
		AttributesISSysComponentExtension AttrSysCompExt2 = new AttributesISSysComponentExtension(sc2);
		pnl2 = AttrSysCompExt2.getDynamicOutputPanel();
		smIntegrationUse = AttrSysCompExt2.isManagedPackage;
		smHighImpact = AttrSysCompExt2.isHighImpact;
		smSOXObject = AttrSysCompExt2.isSOX;

		test.stopTest();

		//Verify the results
		system.assertNotEquals(null,pnl1);
		system.assertNotEquals(null,pnl2);
		system.assertEquals(TRUE,scIntegrationUse);
		system.assertEquals(TRUE,scSOXObject);
		system.assertEquals(TRUE,smSOXObject);
		system.assertEquals(TRUE,smHighImpact);

	}
	
	static testmethod void test_AttributeChangeRequestExtension() {
		// Implement test code
	}
	
}