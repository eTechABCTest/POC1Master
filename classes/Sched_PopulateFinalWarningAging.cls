/**
 *  Description     :   This class is to check if any of the Portfolio in under the Final  Warning Aging  limit and then updat that field
 *
 *  Created By      :   Bhavi Sharma
 *
 *  Created Date    :   12/03/2014
 *
 *  Revision Logs   :   V_1.0 - Created
 *						V_1.2 - 10/23/2015 - Bhavi Sharma - CR-20151019-9335 - Deactivation will be handled by Scheduled Job now
 *
 **/
global class Sched_PopulateFinalWarningAging implements Schedulable {
    
    //execute method
    global void execute(SchedulableContext SC) {
        
        //Calculate Warning Email Status and Warning dates
        Sched_PopulateFinalWarningAging.calculateFinalWarningAging();
    }
    
    //Static method so it can be executed from anywhere
    public static void calculateFinalWarningAging() {
        
        //Fetch all the portfoli records under Final warning aging
        List<Portfolio__c> portfolios = [Select Id, Oldest_Transaction__c, Is_Oldest_Transaction_Over_Warning_Days__c, Oldest_Transaction_Days__c,
                                                Warning_Type__c, Warning_Email_Status__c, Status__c, Deactivation_Reason__c, Final_Warning_Aging__c,
                                                Advisory_Profile__r.Over_aging_Warning_days__c, 
                                                Advisory_Profile__r.Over_aging_Maximum_days__c from Portfolio__c 
                                                where 
                                                //Pull the records fits in First Threshold
                                                (Is_Oldest_Transaction_Over_Warning_Days__c = true
                                                    AND Warning_Type__c =: CreditCardConstants.PORTFOLIO_WARNING_TYPE_FIRST
                                                    AND Warning_Email_Status__c !=: CreditCardConstants.PORTFOLIO_WARNING_EMAIL_STATUS_SEND_FIRST_WARNING
                                                    AND Warning_Email_Status__c !=: CreditCardConstants.PORTFOLIO_WARNING_EMAIL_STATUS_FIRST_WARNING_SENT
                                                ) OR
                                                //Pull the records fits in Second Threshold
                                                (Is_Oldest_Transaction_Over_Warning_Days__c = true
                                                    AND Warning_Type__c =: CreditCardConstants.PORTFOLIO_WARNING_TYPE_SECOND
                                                    AND Warning_Email_Status__c !=: CreditCardConstants.PORTFOLIO_WARNING_EMAIL_STATUS_SEND_SECOND_WARNING
                                                    AND Warning_Email_Status__c !=: CreditCardConstants.PORTFOLIO_WARNING_EMAIL_STATUS_SECOND_WARNING_SENT
                                                ) OR
                                                //Pull the records fits in Third Threshold
                                                (Is_Oldest_Transaction_Over_Warning_Days__c = true
                                                    AND Warning_Type__c =: CreditCardConstants.PORTFOLIO_WARNING_TYPE_THIRD
                                                    AND Warning_Email_Status__c !=: CreditCardConstants.PORTFOLIO_WARNING_EMAIL_STATUS_SEND_THIRD_WARNING
                                                    AND Warning_Email_Status__c !=: CreditCardConstants.PORTFOLIO_WARNING_EMAIL_STATUS_THIRD_WARNING_SENT
                                                ) OR
                                                //Pull the records fits in Final Threshold
                                                (Is_Oldest_Transaction_Over_Warning_Days__c = true
                                                    AND Warning_Type__c =: CreditCardConstants.PORTFOLIO_WARNING_TYPE_DEACTIVATE
                                                    AND Warning_Email_Status__c !=: CreditCardConstants.PORTFOLIO_WARNING_EMAIL_STATUS_DEACTIVATE_PORTFOLIO
                                                    AND Warning_Email_Status__c !=: CreditCardConstants.PORTFOLIO_WARNING_EMAIL_STATUS_PORTFOLIO_DEACTIVATED
                                                ) OR
                                                //Pull the records fits in blank warning criteria and activation again
                                                (Warning_Type__c !=: CreditCardConstants.PORTFOLIO_WARNING_TYPE_DEACTIVATE
                                                    AND Status__c =: CreditCardConstants.PORTFOLIO_STATUS_DEACTIVATED
                                                    AND Deactivation_Reason__c =: CreditCardConstants.PORTFOLIO_DEACTIVATION_REASON_OVER_AGE_LIMIT
                                                )
                                         ];
                                                        
        //Loop through the records and populate the Final_Warning_Aging__c
        for(Portfolio__c portfolio : portfolios) {
            
            //First Warning Portfolios
            if(portfolio.Is_Oldest_Transaction_Over_Warning_Days__c == true
                && portfolio.Warning_Type__c == CreditCardConstants.PORTFOLIO_WARNING_TYPE_FIRST
                && portfolio.Warning_Email_Status__c != CreditCardConstants.PORTFOLIO_WARNING_EMAIL_STATUS_SEND_FIRST_WARNING
                && portfolio.Warning_Email_Status__c != CreditCardConstants.PORTFOLIO_WARNING_EMAIL_STATUS_FIRST_WARNING_SENT) {
                
                //Set the warning type
                portfolio.Warning_Email_Status__c = CreditCardConstants.PORTFOLIO_WARNING_EMAIL_STATUS_SEND_FIRST_WARNING;
                        
            } 
            
            //Check for teh records applicable for second threshold
            else if(portfolio.Is_Oldest_Transaction_Over_Warning_Days__c == true
                && portfolio.Warning_Type__c == CreditCardConstants.PORTFOLIO_WARNING_TYPE_SECOND
                && portfolio.Warning_Email_Status__c != CreditCardConstants.PORTFOLIO_WARNING_EMAIL_STATUS_SEND_SECOND_WARNING
                && portfolio.Warning_Email_Status__c != CreditCardConstants.PORTFOLIO_WARNING_EMAIL_STATUS_SECOND_WARNING_SENT) {
                
                //Set the warning type
                portfolio.Warning_Email_Status__c = CreditCardConstants.PORTFOLIO_WARNING_EMAIL_STATUS_SEND_SECOND_WARNING;
                        
            } 
            
            //Check for teh records applicable for third threshold
            else if(portfolio.Is_Oldest_Transaction_Over_Warning_Days__c == true
                && portfolio.Warning_Type__c == CreditCardConstants.PORTFOLIO_WARNING_TYPE_THIRD
                && portfolio.Warning_Email_Status__c != CreditCardConstants.PORTFOLIO_WARNING_EMAIL_STATUS_SEND_THIRD_WARNING
                && portfolio.Warning_Email_Status__c != CreditCardConstants.PORTFOLIO_WARNING_EMAIL_STATUS_THIRD_WARNING_SENT) {
                
                //Set the warning type
                portfolio.Warning_Email_Status__c = CreditCardConstants.PORTFOLIO_WARNING_EMAIL_STATUS_SEND_THIRD_WARNING;
                    
            } 
            
            //Check for the records applicable for deactivattion
            else if(portfolio.Is_Oldest_Transaction_Over_Warning_Days__c == true
                && portfolio.Warning_Type__c == CreditCardConstants.PORTFOLIO_WARNING_TYPE_DEACTIVATE
                && portfolio.Warning_Email_Status__c != CreditCardConstants.PORTFOLIO_WARNING_EMAIL_STATUS_DEACTIVATE_PORTFOLIO
                && portfolio.Warning_Email_Status__c != CreditCardConstants.PORTFOLIO_WARNING_EMAIL_STATUS_PORTFOLIO_DEACTIVATED) {
                
                //Set the warning type
                portfolio.Warning_Email_Status__c = CreditCardConstants.PORTFOLIO_WARNING_EMAIL_STATUS_DEACTIVATE_PORTFOLIO;
                portfolio.Status__c = CreditCardConstants.PORTFOLIO_STATUS_DEACTIVATED;
                portfolio.Deactivation_Reason__c = CreditCardConstants.PORTFOLIO_DEACTIVATION_REASON_OVER_AGE_LIMIT;
                        
            }
            
            //Check for the records can be activated again
            if((portfolio.Oldest_Transaction_Days__c == null 
            	|| portfolio.Oldest_Transaction_Days__c <= portfolio.Advisory_Profile__r.Over_aging_Maximum_days__c) 
                && portfolio.Status__c == CreditCardConstants.PORTFOLIO_STATUS_DEACTIVATED
                && portfolio.Deactivation_Reason__c == CreditCardConstants.PORTFOLIO_DEACTIVATION_REASON_OVER_AGE_LIMIT) {
                
                //Set the warning type
                portfolio.Status__c = CreditCardConstants.PORTFOLIO_STATUS_ACTIVATED;
            }
            
            //Set the date value
            if(portfolio.Oldest_Transaction__c != null) {
	            
	            Date finalWarningAging = portfolio.Oldest_Transaction__c + (Integer)portfolio.Advisory_Profile__r.Over_aging_Maximum_days__c;
	            if(portfolio.Is_Oldest_Transaction_Over_Warning_Days__c == true && portfolio.Final_Warning_Aging__c != finalWarningAging)
	                portfolio.Final_Warning_Aging__c = finalWarningAging;
	            else if(portfolio.Is_Oldest_Transaction_Over_Warning_Days__c == false && portfolio.Final_Warning_Aging__c != null)
	                portfolio.Final_Warning_Aging__c = null;
            } else
            	portfolio.Final_Warning_Aging__c = null;
        }

        //Ceck for the size and run update
        if(portfolios.size() > 0)
            update portfolios;
    }
}