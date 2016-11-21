/**
 *  Description     :   This class is to check if any of the Portfolio in under the Final  Warning Balance  limit and then updat that field
 *
 *  Created By      :   Bhavi Sharma
 *
 *  Created Date    :   11/04/2015
 *
 *  Revision Logs   :   V_1.0 - Created
 *
 **/
global class Sched_PopulateFinalWarningBalance implements Schedulable {
    
    //execute method
    global void execute(SchedulableContext SC) {
        
        //Calculate Warning Email Status and Warning dates
        Sched_PopulateFinalWarningBalance.calculateFinalWarningBalance();
    }
    
    //Static method so it can be executed from anywhere
    public static void calculateFinalWarningBalance() {
        
        //Fetch all the portfoli records under Final warning aging
        List<Portfolio__c> portfolios = [Select Id, Status__c, Deactivation_Reason__c, Last_Over_Balance_Warning_Sent_On__c, 
        										Final_warning_Balance__c, Over_balance_Countdown_days__c, Utilized_Balance__c,
        										Advisory_Profile__r.Over_balance_Countdown_days__c
        										from Portfolio__c 
                                                where 
                                                //Only pull the Credit Card if it's active and over limit
                                                Utilized_Balance__c > 100 AND
                                                Status__c =: CreditCardConstants.PORTFOLIO_STATUS_ACTIVATED
                                         ];
                                                        
        //Loop through the records and populate the Final_Warning_Aging__c
        for(Portfolio__c portfolio : portfolios) {
            
            //Countdown days
            Decimal countdownDays = portfolio.Over_balance_Countdown_days__c != null ? portfolio.Over_balance_Countdown_days__c : portfolio.Advisory_Profile__r.Over_balance_Countdown_days__c;
            System.debug('countdownDays:::::' + countdownDays);
            //Card deactivation date
            Date deactivationDate = Date.today() + Integer.valueOf(countdownDays);
        	if(portfolio.Final_warning_Balance__c != deactivationDate)
        		portfolio.Final_warning_Balance__c = deactivationDate;
            System.debug('Utilized_Balance__c:::::' + portfolio.Utilized_Balance__c);
            //First Warning Portfolios
            if(portfolio.Over_balance_Countdown_days__c == null || portfolio.Over_balance_Countdown_days__c > 0) {
                
                //Send the email right away to user
                portfolio.Last_Over_Balance_Warning_Sent_On__c = Datetime.Now();
            } else {
            	
            	//Deactivate the card along with the reason
            	portfolio.Status__c = CreditCardConstants.PORTFOLIO_STATUS_DEACTIVATED;
            	portfolio.Deactivation_Reason__c = CreditCardConstants.PORTFOLIO_DEACTIVATION_REASON_OVER_CREDIT_BALANNCE_LIMIT;
            }
        }

        //Ceck for the size and run update
        if(portfolios.size() > 0)
            update portfolios;
    }
}