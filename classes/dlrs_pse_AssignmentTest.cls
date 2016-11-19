/**
 * Auto Generated and Deployed by the Declarative Lookup Rollup Summaries Tool package (dlrs)
 **/
@IsTest
private class dlrs_pse_AssignmentTest
{
    private static testmethod void testTrigger()
    {
        // Force the dlrs_pse_AssignmentTrigger to be invoked, fails the test if org config or other Apex code prevents this.
        dlrs.RollupService.testHandler(new pse__Assignment__c(pse__Bill_Rate__c = 5.0));
    }
}