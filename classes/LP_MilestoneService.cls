/**
 * 	Purpose:    REST Service to that accepts Milestones from LP and upserts the corresponding Event in SF.
 * 
 * 	Create By:  Victor Hanson
 * 
 * 	Created Date:   05/06/2015
 * 
 * 	Revision Log:	v1.0 - (Code Added) - Victor Hanson - Created
 **/
@RestResource(urlMapping='/LP_MilestoneService')
global class LP_MilestoneService {
	
    @HttpPost
    global static LiquidPlannerWrapper.LP_Milestone doPost() {
        LiquidPlannerWrapper.LP_Milestone milestone;
        String postBody;
        
        try {
            postBody = RestContext.request.requestBody.toString();
            postBody = postBody.replace('"Task Type":', '"task_type":');
            milestone = (LiquidPlannerWrapper.LP_Milestone)JSON.deserialize(postBody,LiquidPlannerWrapper.LP_Milestone.class);
            //process the milestone
            LP_ServiceUtils.processEvent(milestone);
        }
        catch(Exception ex) { LP_ServiceUtils.Log(milestone.Id, postBody, JSON.serializePretty(milestone), ex); }
        return milestone;
    }
    
}