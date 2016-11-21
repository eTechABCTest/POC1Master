/** @Modified By - Rajeev Jain - 06/28/2016 - SFDC Royall Migration - Migrated from Royall Enviournment to Corporate Instance
 * 
 * */
public with sharing class CreateRollup 
{   
	public Rollup_Definition__c objRollupDefinition {get;set;}
	//Function for inserting rollup detail in custom object
	/** 

    * \Method createRollupDefinition() 
    
    * \param none
    
    * \return none
    
    */ 
    public string createRollupDefinition(String rollupName ,String objAggregate,String fieldAggregate,String aggregateFunction ,String rollupCriteria)    
    {
        objRollupDefinition = new Rollup_Definition__c(Name__c = rollupName, Object_Aggregated__c = objAggregate,
                                                            Field_Aggregated__c = fieldAggregate,Aggregate_Function__c = aggregateFunction,Criteria__c = rollupCriteria);
        insert objRollupDefinition;  
        return objRollupDefinition.Id;                                          
    }
    @IsTest
    static void testCreateRollup()
    {
        CreateRollup obj = new CreateRollup();
        obj.createRollupDefinition('testRollup','testAgg','testField','testAggFunction','testCriteria');
        Rollup_Definition__c obj1 = [Select Name__c from Rollup_Definition__c where Name__c =: 'testRollup'];
        system.assertEquals(obj1.Name__c,'testRollup');
    }
}