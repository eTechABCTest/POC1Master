public without sharing class ResetSFPasswordController {
	
	public boolean IsSuccess { get; set; }
	public User ActiveUser { get; set; }
	public String ErrorMessage { get; set; }
	private String ActiveDirectoryId { get; set; }
	
	public ResetSFPasswordController() {
		// get the active directory id
		ActiveDirectoryId = FindActiveDirectoryId();
	}
	
	public String FindActiveDirectoryId() {
		String decryptedId;
		try {
			// encrypted version of hte active directory id
			String encryptedId = ApexPages.currentPage().getParameters().get('ActiveDirectoryID');
			// convert to blob and decrypt
			Blob encryptedBlob = EncodingUtil.base64Decode(encryptedId);
			decryptedId = EncryptionHelper.Decrypt(encryptedBlob);
		}
		catch(Exception ex) {
			ErrorMessage = ex.getMessage() + '  ActiveDirectoryId=' + ActiveDirectoryId;
			system.debug('@@Exception:' + ex);
		}
		
		return decryptedId;
	}
	
	public PageReference ResetPW() {
		
		// find the user associated with the Active Directory ID provided
        List<User> users = [SELECT Id, Email FROM User WHERE Active_Directory_ID__c = :activeDirectoryId AND IsActive = true];
        
        // assuming the user was found, send a password reset email to the user
        if (users.size() == 1) {
        	ActiveUser = users[0];
        	// if it's not a unit test, reset the password - CR-3677
        	if (!test.isRunningTest()) system.resetPassword(ActiveUser.Id, true);
            IsSuccess = true;
        }
        else IsSuccess = false;
        
        return null;
	}
	
	
}