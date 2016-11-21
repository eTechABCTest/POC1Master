/**
 * 	Purpose:    REST Service to that accepts Project from LP and upserts the corresponding Release in SF.
 * 
 * 	Create By:  Victor Hanson
 * 
 * 	Created Date:   05/06/2015
 * 
 * 	Revision Log:	v1.0 - (Code Added) - Victor Hanson - Created
 **/
@RestResource(urlMapping='/LP_ProjectService/*')
global class LP_ProjectService {
	
    @HttpPost
    global static LiquidPlannerWrapper.LP_Project doPost() {
        RestRequest req = RestContext.request;
        LiquidPlannerWrapper.LP_Project project;
        String postBody;
        LP_ServiceUtils.type = req.requestURI.substring( req.requestURI.lastIndexOf('/') + 1 );
        
        try {
            postBody = req.requestBody.toString();
            project = (LiquidPlannerWrapper.LP_Project)JSON.deserialize(postBody,LiquidPlannerWrapper.LP_Project.class);
            //process the project
            LP_ServiceUtils.processProject(project);
        }
        catch(Exception ex) {
            if (project != null) {
                LP_ServiceUtils.Log(project.Id, postBody, JSON.serializePretty(project), ex);
            }
            else {
                system.debug('@@project is null:' + postBody);
            }
        }
        return project;
    }
}