/**
 * 	@description	:	Controller class for ESubmitExpenseAuth VF Page.
 * 
 * 	@Created By		:	Victor Hanson
 * 
 * 	@Change History	:	V1.0 - Created - 02/06/2015 - Victor Hanson - CR-20140520-5562
 * 
 **/
public class SubmitExpenseAuthController {
	
    private Expense_Authorization__c expenseAuth { get; set; }
    public list<string> errors { get; set; }
    
    public SubmitExpenseAuthController(ApexPages.StandardController stdController) {
        //get the record id
        expenseAuth = (Expense_Authorization__c) stdController.getRecord();
    }
    
    public pageReference submit() {
        
        //submit for approval and return any errors
        errors = ExpenseAuthTriggerHelper.submitExpenseForApproval(expenseAuth.Id);
        for (string e : errors) 
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e));
        
        //if there were no errors, return to the expense authorization record
        PageReference pg;
        if(errors.size() == 0)
            pg = new PageReference('/' + expenseAuth.Id);
        
        return pg;
    }
}