/**
 *  Desription      :   Main entry point for CommonAuth API
 *
 *  Created By      :   Jeffery Sun
 *  Created Date    :   02/22/2014
 *  Revision Logs   :   V1.0 - Created
 **/
public without sharing class CommonAuthController {   
    public String JSONResponse { get; set; }
    public String JSONRequest { get; set; }
    public String ErrorMessage { get; set; }
    public String CommandName { get; set; }
    
    public CommonAuthController() {
         try {
            // get the encrypted request
            Map<String, String> parameters = ApexPages.currentPage().getParameters();
            if(!parameters.containsKey('req')) {
            	ErrorMessage = 'Error: No required [req] parameter.';
            } else { 
                String req = parameters.get('req');
                JSONRequest = CommonAuthHelper.Decode(req);
                system.debug('##CommonAuthController - cstor: ' + JSONRequest);
    
                if(JSONRequest == null) {
                    ErrorMessage = 'Error: Empty Request.';
                } else {
                    CommonAuthBaseRequest request = CommonAuthBaseRequest.fromJSON(JSONRequest);
                    if(request != null) {
                        if(request.Command.equalsIgnoreCase('SyncContact')) {
                            CommandName = 'SyncContact';
                        } else if(request.Command.equalsIgnoreCase('DeactivateContact')) {
                            CommandName = 'DeactivateContact';
                        } else {
                            ErrorMessage = 'Error: Not Implemented - ' + request.Command + '.';                    
                        }
                    } else {
                        ErrorMessage = 'Error: Invalid Request.';
                    }
                }
			}
		}
        catch(Exception ex) {
            system.debug('##CommonAuthController - cstor: ' + ex.getMessage() + ' on line number: ' + ex.getLineNumber() + '\n' + ex.getStackTraceString());
            ErrorMessage = 'Error: ' + ex.getMessage() + ' on line number: ' + ex.getLineNumber() + '\n' + ex.getStackTraceString();
        }
    }

    public PageReference process() {
        if(ErrorMessage == null) {
            Savepoint sp = Database.setSavepoint();
            
            try {
                if(CommandName == 'SyncContact') {
                    CommonAuthSyncContactRequest request = CommonAuthSyncContactRequest.fromJSON(JSONRequest);
                    CommonAuthSyncContactResponse response = CommonAuthHelper.SyncContact(request);
                    
                    String json = response.toJSON();
                    System.debug('##CommonAuthController - process - SyncContact: ' +  json);
                    JSONResponse = CommonAuthHelper.Encode(json);
                    return null;
                }
                
                if(CommandName == 'DeactivateContact') {
                    CommonAuthDeactivateContactRequest request = CommonAuthDeactivateContactRequest.fromJSON(JSONRequest);
                    CommonAuthDeactivateContactResponse response = CommonAuthHelper.DeactivateContact(request);
                    
                    String json = response.toJSON();
                    System.debug('##CommonAuthController - process - DeactivateContact: ' +  json);
                    JSONResponse = CommonAuthHelper.Encode(json);
                    return null;
                }
            }
            catch(Exception ex) {
                Database.rollback(sp);
                system.debug('##CommonAuthController - process: ' + ex.getMessage() + ' on line number: ' + ex.getLineNumber() + '\n' + ex.getStackTraceString());
                ErrorMessage = 'Error: ' + ex.getMessage() + ' on line number: ' + ex.getLineNumber() + '\n' + ex.getStackTraceString();
            }
        }
        
        CommonAuthSyncContactResponse response = new CommonAuthSyncContactResponse();
        response.Successful = false;
        response.ErrorMessage = ErrorMessage;       
        JSONResponse = CommonAuthHelper.Encode(response.toJSON());
        CommonAuthHelper.SendErrorEmail(JSONRequest, ErrorMessage);
        return null;
    }
}