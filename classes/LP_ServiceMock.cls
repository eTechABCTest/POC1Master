/**
 * 
 * 
 **/
@isTest
global class LP_ServiceMock implements HttpCalloutMock {
	
    public string methodName;
    public static final integer PROJECT_ID = 1111;
    
    private LiquidPlannerWrapper.LP_Project responseGetProject {
        get {
            if (responseGetProject == null) {
                responseGetProject = new LiquidPlannerWrapper.LP_Project();
                responseGetProject.name = 'Credit Card Phase 1';
                responseGetProject.id = PROJECT_ID;
            }
            return responseGetProject;
        }
        set;
    }
    
    private list<LiquidPlannerWrapper.LP_Tag> responseGetProjectTags {
        get {
            if (responseGetProjectTags == null) {
                responseGetProjectTags = new list<LiquidPlannerWrapper.LP_Tag>();
                LiquidPlannerWrapper.LP_Tag tag = new LiquidPlannerWrapper.LP_Tag();
                tag.text = Label.LP_Release_Creation_Tag; //tag that tells SF to create the Release record.
                responseGetProjectTags.add(tag);
            }
            return responseGetProjectTags;
        }
        set;
    }
    
    public map<string, string> methodNameToResponse {
        get {
            if (methodNameToResponse == null) {
                methodNameToResponse = new map<string, string> { 
                    'getProject' => JSON.serialize(responseGetProject),
                    'getProjectTags' => JSON.serialize(responseGetProjectTags)
                };
            }
            return methodNameToResponse;
        }
        set;
    }
    
    global HttpResponse respond(HTTPRequest req){
        HttpResponse res = new HttpResponse();
        res.setStatus('OK');
        res.setStatusCode(200);
        res.setBody(methodNameToResponse.get(methodName));
        return res;
    }
}