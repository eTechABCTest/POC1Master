public with sharing class AdvEventController {
	
	private String EncryptedRequest { get; set; }
	
	public String Response { get; set; }
	
	public AdvEventController() {
		// get the encrypted request
		EncryptedRequest = ApexPages.currentPage().getParameters().get('req');
	}
	
	public void Initialize() {
		if (EncryptedRequest != null) {
			String debugMode = ApexPages.currentPage().getParameters().get('debug');
			// create an instance of the eventUtils class, which will decrypt the request and perform the desired action
			AdvEventUtils eventUtils = new AdvEventUtils(EncryptedRequest);
			// encrypt the reponse
			if (debugMode == 'true') Response = JSON.serialize(eventUtils.pWrapper);
			else Response = eventUtils.getEncryptedWrapper();
		}
	}
	
}