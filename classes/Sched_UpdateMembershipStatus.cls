/**
  *  Purpose	 :	 Schedular for Batch_UpdateMembershipStatus
  *                  
  *  Create By   :   Simplyforce Technology
  *  
  *  Created Date:   06/21/2012
  *  
  *  Revision Log:	v1.0 - Created
  *  				
 **/
global class Sched_UpdateMembershipStatus implements Schedulable {

	//Override execute method
	 global void execute(SchedulableContext ctx) {
        
        //Kick-off batch job
        database.executeBatch(new Batch_UpdateMembershipStatus(), 200);
    }
     
    //Test method
    @isTest
    static void testSched() {
    	
    	//CRON Expression
    	String CRON_EXP = '0 0 0 3 9 ? 2022';
    	
    	//Start Test from here
    	Test.startTest();
    	
    	//Schedule job
    	System.schedule('testSched_UpdateMembershipStatus', CRON_EXP, new Sched_UpdateMembershipStatus());
    	
    	//Stop Testing here
    	Test.stopTest();
    }
}