/**
 *  Desription      :   Utility class for the Advisory.com Event App
 * 
 *  Created By      :   Victor Hanson
 * 
 *  Created Date    :   06/03/2013
 * 
 *  Revision Logs   :   V1.0 - Created
 *
 **/ 
public without sharing class AdvEventUtils {
	
	public static final String SUCCESS = 'Success';
	
	// Presentation class
	public class SavedPresentation {
		public SavedPresentation() { }
		public String SavedPresentationID { get; set; }
		public String SavedMicrositeID { get; set; }
		public DateTime DateSaved { get; set; }
		public boolean HasNotes {
			get {
				if (HasNotes == null) HasNotes = false;
				return HasNotes;
			}
			set;
		}
	}
	
	// Slide class
	public class SavedSlide {
		public SavedSlide() { }
		public String SavedSlideID { get; set; }
		public String SavedPresentationID { get; set; }
		public String SavedMicrositeID { get; set; }
		public boolean HasNotes {
			get {
				if (HasNotes == null) HasNotes = false;
				return HasNotes;
			}
			set;
		}
		public DateTime DateSaved { get; set; }
	}
	
	// Related Content class
	public class SavedRelatedContent {
		public SavedRelatedContent() { }
		public String SavedRelatedContentID { get; set; }
		public String SavedPresentationID { get; set; }
		public String MicrositeID { get; set; }
		public DateTime DateSaved { get; set; }
	}
	
	// Slide Note class
	public class SlideNote {
		public SlideNote() { }
		public String SavedPresentationID { get; set; }
		public String SavedMicrositeID { get; set; }
		public DateTime DateSaved { get; set; }
		public String SlideID { get; set; }
		public String Notes { get; set; }
	}
	
	// wrapper class to hold Presentation, Slide, Slide Notes, and Response
	public class PresentationWrapper {
		public String Command { get; set; }
		
		public String ContactID { get; set; }
		public String MicrositeID { get; set; }
		public String EventID { get; set; }
		public String PresentationID { get; set; }
		public String RelatedContentID { get; set; }
		public String SlideID { get; set; }
		public String NoteString { get; set; }
		public boolean IncludesNotes { get; set; }
		public DateTime DateSaved { get; set; }
		
		public List<String> Recipients {
			get {
				if (Recipients == null) Recipients = new List<String>();
				return Recipients;
			}
			set;
		} 
		public List<String> SharedEmails {
			get {
				if (SharedEmails == null) SharedEmails = new List<String>();
				return SharedEmails;
			}
			set;
		}
		public List<SavedPresentation> Presentations {
			get {
				if (Presentations == null) Presentations = new List<SavedPresentation>();
				return Presentations;
			}
			set;
		}
		public List<SavedSlide> Slides {
			get {
				if (Slides == null) Slides = new List<SavedSlide>();
				return Slides;
			}
			set;
		}
		public List<SlideNote> Notes {
			get {
				if (Notes == null) Notes = new List<SlideNote>();
				return Notes;
			}
			set;
		}
		public List<SavedRelatedContent> RelatedContentList {
			get {
				if (RelatedContentList == null) RelatedContentList = new List<SavedRelatedContent>();
				return RelatedContentList;
			}
			set;
		}
		
		public boolean IsSaved { get; set; }
		public String Response { get; set; }
		public boolean Successful { get; set; }
	}
	
	private Map<String, Object> WrapperMap { get; set; }
	
	public PresentationWrapper pWrapper {
		get {
			if (pWrapper == null) pWrapper = new PresentationWrapper();
			return pWrapper;
		}
		set;
	}
	
	private String DecryptedString { get; set; }
	
	public String getEncryptedWrapper() {
		// serialize the wrapper
        String origData = JSON.serialize(pWrapper);
        blob blobData = blob.valueOf(origData);
        blob encryptedBlob = Crypto.encryptWithManagedIV('AES256', SiteControllerHelper.KEY, blobData);
        String encryptedString = EncodingUtil.base64Encode(encryptedBlob);
        return encryptedString;
    }
	
	// take in an encrypted request
	public AdvEventUtils(String encryptedRequest) {
		try {
			// convert the string in to a blob to be decrypted
			blob encryptedBlob = EncodingUtil.base64Decode(encryptedRequest);
			DecryptedString = EncryptionHelper.decrypt(encryptedBlob);
			pWrapper = (PresentationWrapper)JSON.deserialize(DecryptedString, AdvEventUtils.PresentationWrapper.class);
			
			// check for errors to ensure the ContactID and EventID are valid
			CheckErrors();
			
			// perform whatever action is being requested
			PerformAction();
			
		}
		catch(Exception ex) {
			pWrapper.Response = 'Error: ' + ex.getMessage() + ' on line stack: ' + ex.getStackTraceString();
			pWrapper.Successful = false;
		}
	}
	
	private void CheckErrors() {
		if (pWrapper.EventID != null) {
			List<Meeting__c> meetings = [SELECT Id FROM Meeting__c WHERE Id = :pWrapper.EventID LIMIT 1];
			if (meetings.size() == 0) throw new customException('Error: No meeting found with ID ' + pWrapper.EventID);
		}
		if (pWrapper.ContactID != null) {
			List<Contact> contacts = [SELECT Id FROM Contact WHERE Id = :pWrapper.ContactID LIMIT 1];
			if (contacts.size() == 0) throw new customException('Error: No contact found with ID ' + pWrapper.ContactID);
		}
	}
	
	// perform the requested action
	private void PerformAction() {
		// based on the command, determine which action must be performed
		if (pWrapper.Command == null) throw new customException('No command specified.');
		else if (pWrapper.Command.equalsIgnoreCase('SavePresentation')) SavePresentation();
		else if (pWrapper.Command.equalsIgnoreCase('SaveSlide')) SaveSlide();
		else if (pWrapper.Command.equalsIgnoreCase('GetSavedPresentations')) GetSavedPresentations();
		else if (pWrapper.Command.equalsIgnoreCase('GetSavedSlides')) GetSavedSlides();
		else if (pWrapper.Command.equalsIgnoreCase('IsSavedSlide')) IsSavedSlide();
		else if (pWrapper.Command.equalsIgnoreCase('DeletePresentation')) DeletePresentation();
		else if (pWrapper.Command.equalsIgnoreCase('DeleteSlide')) DeleteSlide();
		else if (pWrapper.Command.equalsIgnoreCase('SharePresentation')) ShareEventMaterial();
		else if (pWrapper.Command.equalsIgnoreCase('ShareSlide')) ShareEventMaterial();
		else if (pWrapper.Command.equalsIgnoreCase('LogRelatedContentShared')) ShareEventMaterial();
		else if (pWrapper.Command.equalsIgnoreCase('SaveSlideNotes')) SaveSlideNotes();
		else if (pWrapper.Command.equalsIgnoreCase('GetSlideNotes')) GetSlideNotes();
		else if (pWrapper.Command.equalsIgnoreCase('GetPresentationNotes')) GetPresentationNotes();
		else if (pWrapper.Command.equalsIgnoreCase('SaveRelatedContent')) SaveRelatedContent();
		else if (pWrapper.Command.equalsIgnoreCase('GetSavedRelatedContent')) GetSavedRelatedContent();
		else if (pWrapper.Command.equalsIgnoreCase('DeleteRelatedContent')) DeleteRelatedContent();
		else throw new customException('Urecognized Command: ' + pWrapper.Command);
		
		// if we get to here, then the command was successful
		pWrapper.Response = SUCCESS;
		pWrapper.Successful = true;
	}
	
	private Presentation__c SavePresentation() {
		// check to see if a presentation is already saved for this contact / presentation id
		List<Presentation__c> existingPresentations = [SELECT Id FROM Presentation__c
													   WHERE Contact__c = :pWrapper.ContactID 
													   AND Presentation_ID__c = :pWrapper.PresentationID LIMIT 1];
		
		// create a new Presentation and populate the fields accordingly
		Presentation__c presentation = new Presentation__c();
		if (existingPresentations.size() > 0) presentation = existingPresentations[0];
		else presentation.Contact__c = pWrapper.ContactID;
		presentation.Presentation_ID__c = pWrapper.PresentationID;
		presentation.Meeting__c = pWrapper.EventID;
		presentation.Microsite_ID__c = pWrapper.MicrositeID;
		upsert presentation;
		return presentation;
	}
	
	private Slide__c SaveSlide() {
		// check to see if a Slide is already saved for this contact / slide id
		List<Slide__c> existingSlides = [SELECT Id FROM Slide__c
													   WHERE Contact__c = :pWrapper.ContactID 
													   AND Slide_ID__c = :pWrapper.SlideID LIMIT 1];
		
		
		// create a new Presentation and populate the fields accordingly
		Slide__c sld = new Slide__c();
		if (existingSlides.size() > 0) sld = existingSlides[0];
		else sld.Contact__c = pWrapper.ContactID;
		sld.Slide_ID__c = pWrapper.SlideID;
		sld.Presentation_ID__c = pWrapper.PresentationID;
		sld.Meeting__c = pWrapper.EventID;
		sld.Microsite_ID__c = pWrapper.MicrositeID;
		upsert sld;
		return sld;
	}
	
	private Related_Content__c SaveRelatedContent() {
		
		// check to see if Related Content is already saved for this contact / RC id
		List<Related_Content__c> existingRC = [SELECT Id FROM Related_Content__c
													   WHERE Contact__c = :pWrapper.ContactID 
													   AND Related_Content_ID__c = :pWrapper.RelatedContentID LIMIT 1];
		
		
		// create a new Presentation and populate the fields accordingly
		Related_Content__c rc = new Related_Content__c();
		if (existingRC.size() > 0) rc = existingRC[0];
		else rc.Contact__c = pWrapper.ContactID;
		rc.Related_Content_ID__c = pWrapper.RelatedContentID;
		rc.Presentation_ID__c = pWrapper.PresentationID;
		rc.Meeting__c = pWrapper.EventID;
		rc.Microsite_ID__c = pWrapper.MicrositeID;
		upsert rc;
		return rc;
	}
	
	private Slide_Note__c SaveSlideNotes() {
		
		// check for existing notes on this slide
		List<Slide_Note__c> existingNotes  = [SELECT Id FROM Slide_Note__c 
											   WHERE Contact__c = :pWrapper.ContactID AND Slide_ID__c = :pWrapper.SlideID];
		
		// create a new Presentation and populate the fields accordingly
		Slide_Note__c sNote = new Slide_Note__c();
		if (existingNotes.size() > 0) sNote = existingNotes[0];
		else sNote.Contact__c = pWrapper.ContactID;
		sNote.Slide_ID__c = pWrapper.SlideID;
		sNote.Presentation_ID__c = pWrapper.PresentationID;
		sNote.Microsite_ID__c = pWrapper.MicrositeID;
		sNote.Meeting__c = pWrapper.EventID;
		sNote.Notes__c = pWrapper.NoteString;
		upsert sNote;
		return sNote;
	}
	
	private void GetSavedPresentations() {
		String contactId = pWrapper.ContactID;
		String micrositeId = pWrapper.MicrositeID;
		// build the query string
		String queryString = 'SELECT Id, Contact__c, Microsite_ID__c, Meeting__c, Presentation_ID__c, LastModifiedDate '+
							 'FROM Presentation__c WHERE Contact__c = :contactId';
		if (pWrapper.MicrositeID != null) queryString += ' AND Microsite_ID__c = :micrositeId';
		
		// query for presentations that fit criteria
		List<Presentation__c> presentations = database.query(queryString);
		
		Set<String> presExternalIdSet = new Set<String>();
		for (Presentation__c p : presentations) presExternalIdSet.add(p.Presentation_ID__c);
		
		// get all slides w/ slide notes
		List<Slide_Note__c> slideNotes = [SELECT Presentation_ID__c FROM Slide_Note__c
										  WHERE Contact__c = :pWrapper.ContactID AND Presentation_ID__c IN :presExternalIdSet];
		
		// create a map of presentations with notes
		// Map<ProjectId, HasNotes(true/false)>
		Map<String, boolean> presentationToHasNotesMap = new Map<String, boolean>();
		for (Slide_Note__c slideNote : slideNotes) {
			presentationToHasNotesMap.put(slideNote.Presentation_ID__c, true);
		}
		
		// place each result in our wrapper
		for (Presentation__c p : presentations) {
			// see if the presentation ID has notes
			boolean hasNotes = presentationToHasNotesMap.get(p.Presentation_ID__c);
			// create the presentation wrapper
			SavedPresentation newPresentation = new SavedPresentation();
			newPresentation.SavedMicrositeID = p.Microsite_ID__c;
			newPresentation.SavedPresentationID = p.Presentation_ID__c;
			newPresentation.DateSaved = p.LastModifiedDate;
			newPresentation.HasNotes = hasNotes;
			pWrapper.Presentations.add(newPresentation);
		}
		
	}
	
	// Given a contactID and SlideID, return whether or not the slide IsSaved
	private void IsSavedSlide() {
		String contactId = pWrapper.ContactID;
		String slideId = pWrapper.SlideID;
		
		// Ensure the SlideID is provided
		if (pWrapper.SlideID == null) {
			throw new customException('Error: SlideID is required');
		}
		
		// build the query string
		String queryString = 'SELECT Id, Slide_ID__c, LastModifiedDate, Presentation_ID__c, Microsite_ID__c '+
							 'FROM Slide__c WHERE Contact__c = :contactId' +
							 ' AND Slide_ID__c = :slideId';
		
		// query for presentations that fit criteria
		List<Slide__c> slides = database.query(queryString);
		
		// Ensure the SlideID is provided
		if (slides.size() > 0) {
			pWrapper.IsSaved = true;
		}
		else {
			pWrapper.IsSaved = false;
		}
	}
	
	private void GetSavedSlides() {
		String contactId = pWrapper.ContactID;
		String micrositeId = pWrapper.MicrositeID;
		// build the query string
		String queryString = 'SELECT Id, Slide_ID__c, LastModifiedDate, Presentation_ID__c, Microsite_ID__c '+
							 'FROM Slide__c WHERE Contact__c = :contactId';
		if (pWrapper.MicrositeID != null) queryString += ' AND Microsite_ID__c = :micrositeId';
		
		// query for presentations that fit criteria
		List<Slide__c> slides = database.query(queryString);
		
		Set<String> slideIdSet = new Set<String>();
		for (Slide__c s : slides) slideIdSet.add(s.Slide_ID__c);
		
		List<Slide_Note__c> slideNotes = [SELECT Id, Slide_ID__c FROM Slide_Note__c
										  WHERE Contact__c = :pWrapper.ContactID AND Slide_ID__c IN :slideIdSet];
		
		// create a map of slides with notes
		// Map<SlideID, HasNotes(true/false)>
		Map<String, boolean> slideToHasNotesMap = new Map<String, boolean>();
		for (Slide_Note__c slideNote : slideNotes) {
			slideToHasNotesMap.put(slideNote.Slide_ID__c, true);
		}
		
		// place each result in our wrapper
		for (Slide__c s : slides) {
			// see if the slide ID has notes
			boolean hasNotes = slideToHasNotesMap.get(s.Slide_ID__c);
			// create the slide wrapper
			SavedSlide newSlide = new SavedSlide();
			newSlide.SavedSlideID = s.Slide_ID__c;
			newSlide.SavedMicrositeID = s.Microsite_ID__c;
			newSlide.SavedPresentationID = s.Presentation_ID__c;
			newSlide.DateSaved = s.LastModifiedDate;
			newSlide.HasNotes = hasNotes;
			pWrapper.Slides.add(newSlide);
		}
		
	}
	
	private void GetSavedRelatedContent() {
		String contactId = pWrapper.ContactID;
		String micrositeId = pWrapper.MicrositeID;
		// build the query string
		String queryString = 'SELECT Id, Related_Content_ID__c, LastModifiedDate, Presentation_ID__c, Microsite_ID__c '+
							 'FROM Related_Content__c WHERE Contact__c = :contactId';
		if (pWrapper.MicrositeID != null) queryString += ' AND Microsite_ID__c = :micrositeId';
		
		// query for presentations that fit criteria
		List<Related_Content__c> relatedContentList = database.query(queryString);

		// place each result in our wrapper
		for (Related_Content__c rc : relatedContentList) {
			// create the related content wrapper
			SavedRelatedContent newSavedRelatedContent = new SavedRelatedContent();
			newSavedRelatedContent.SavedRelatedContentID = rc.Related_Content_ID__c;
			newSavedRelatedContent.MicrositeID = rc.Microsite_ID__c;
			newSavedRelatedContent.SavedPresentationID = rc.Presentation_ID__c;
			newSavedRelatedContent.DateSaved = rc.LastModifiedDate;
			pWrapper.RelatedContentList.add(newSavedRelatedContent);
		}
		
	}
	
	private void DeletePresentation() {
		// query for presentations that fit criteria
		List<Presentation__c> presentations = [SELECT Id  FROM Presentation__c 
											   WHERE Contact__c = :pWrapper.ContactID AND Presentation_ID__c = :pWrapper.PresentationID];
		
		// ensure we returned at least one result
		if (presentations.size() > 0) delete presentations;
		else throw new customException('No Presentation with ID: ' + pWrapper.PresentationID + '  and ContactID:' + pWrapper.ContactID);
	}
	
	private void DeleteSlide() {
		// query for presentations that fit criteria
		List<Slide__c> slides = [SELECT Id FROM Slide__c 
								 WHERE Contact__c = :pWrapper.ContactID AND Slide_ID__c = :pWrapper.SlideID];
		
		// ensure we returned at least one result
		if (slides.size() > 0) delete slides;
		else throw new customException('No Slide with SlideID: ' + pWrapper.SlideID + '  and ContactID:' + pWrapper.ContactID);
	}
	
	private void GetSlideNotes() {
		// query for slide notes that fit criteria
		List<Slide_Note__c> slideNotes = [SELECT Id, Contact__c, Notes__c, Slide_ID__c, Microsite_ID__c, Presentation_ID__c, LastModifiedDate
										  FROM Slide_Note__c 
										  WHERE Contact__c = :pWrapper.ContactID AND Slide_ID__c = :pWrapper.SlideID];
		
		if (slideNotes.size() > 0) {
			pWrapper.MicrositeID = slideNotes[0].Microsite_ID__c;
			pWrapper.PresentationID = slideNotes[0].Presentation_ID__c;
			pWrapper.NoteString = slideNotes[0].Notes__c;
			pWrapper.DateSaved = slideNotes[0].LastModifiedDate;
		}
	}
	
	private void DeleteRelatedContent() {
		// query for related content that fit criteria
		List<Related_Content__c> relatedContent = [SELECT Id FROM Related_Content__c 
											   WHERE Contact__c = :pWrapper.ContactID AND Related_Content_ID__c = :pWrapper.RelatedContentID];
		
		// ensure we returned at least one result
		if (relatedContent.size() > 0) delete relatedContent;
		else throw new customException('No Presentation with ID: ' + pWrapper.RelatedContentID + '  and ContactID:' + pWrapper.ContactID);
	}
	
	private void GetPresentationNotes() {
		
		// query for presentations that fit criteria
		List<Slide_Note__c> slideNotes = [SELECT Id, Contact__c, Notes__c, Slide_ID__c, Microsite_ID__c, Presentation_ID__c, LastModifiedDate
										  FROM Slide_Note__c 
										  WHERE Contact__c = :pWrapper.ContactID AND Presentation_ID__c = :pWrapper.PresentationID];
		
		// place each result in our wrapper
		for (Slide_Note__c sn : slideNotes) {
			SlideNote slideNote = new SlideNote();
			slideNote.SlideID = sn.Slide_ID__c;
			slideNote.Notes = sn.Notes__c;
			slideNote.SavedMicrositeID = sn.Microsite_ID__c;
			slideNote.SavedPresentationID = sn.Presentation_ID__c;
			slideNote.DateSaved = sn.LastModifiedDate;
			pWrapper.Notes.add(slideNote);
		}
		
	}
	
	private void ShareEventMaterial() {
		if (pWrapper.SharedEmails.size() > 0) pWrapper.Recipients.addAll(pWrapper.SharedEmails);
		List<Contact> contacts = [SELECT Id, Email FROM Contact WHERE Email IN :pWrapper.Recipients AND Id != :pWrapper.ContactID AND Email != null];
		Set<String> emailsWithoutContact_Set = new Set<String>();
		// create a map of <Email, Contact>
		Map<String, Contact> emailToContactMap = new Map<String, Contact>();
		for (Contact con : contacts) emailToContactMap.put(con.Email, con);
		// create a list of Shared_Presentation__c records that will be inserted
		List<Shared_Presentation__c> sharesToInsert = new List<Shared_Presentation__c>();
		
		// create a Shared_Presentation__c record if the recipients (SharedEmails) contact is found
		for (String email : pWrapper.Recipients) {
			email = email.toLowerCase();
			Contact con = emailToContactMap.get(email);
			if (con == null) {
				emailsWithoutContact_Set.add(email);
				continue;
			}
			Shared_Presentation__c newShareRecipient = CreateSharedEventMaterial(pWrapper.ContactId, con.Id, null);
			sharesToInsert.add(newShareRecipient);
		}
		
		// create a comma delimited list of email addresses that dont have contacts
		String emailsWithoutContact_String;
		for (string email : emailsWithoutContact_Set) {
			if (emailsWithoutContact_String == null) emailsWithoutContact_String = email;
			else emailsWithoutContact_String += ', ' + email;
		}
		
		// create a meeting to contact MtM record for the original Contact that shared
		if (emailsWithoutContact_String != null) sharesToInsert.add( CreateSharedEventMaterial(pWrapper.ContactID, null, emailsWithoutContact_String) );
		
		if (sharesToInsert.size() > 0) insert sharesToInsert;
	}
	
	private Shared_Presentation__c CreateSharedEventMaterial(Id sharedByContactId, Id contactId, String recipientEmailsNotFound) {
		Shared_Presentation__c sharedEventMaterial = new Shared_Presentation__c();
		sharedEventMaterial.RecordTypeId = sharedEventMaterialRecordType;
		sharedEventMaterial.Shared_By__c = sharedByContactId;
		sharedEventMaterial.Contact__c = contactId;
		sharedEventMaterial.Microsite_ID__c = pWrapper.MicrositeID;
		if (pWrapper.IncludesNotes != null)
			sharedEventMaterial.Includes_Notes__c = pWrapper.IncludesNotes;
		sharedEventMaterial.Presentation_ID__c = pWrapper.PresentationID;
		sharedEventMaterial.Slide_ID__c = pWrapper.SlideID;
		sharedEventMaterial.Related_Content_ID__c = pWrapper.RelatedContentID;
		sharedEventMaterial.Recipient_Emails_Not_Found__c = recipientEmailsNotFound;
		return sharedEventMaterial;
	}
	
	private Id sharedEventMaterialRecordType {
		get {
			if (sharedEventMaterialRecordType == null) {
				if (pWrapper.PresentationID != null && pWrapper.SlideID == null && pWrapper.RelatedContentID == null)
					sharedEventMaterialRecordType = Util.RecordTypeId('Shared_Presentation__c', 'Shared Presentation');
				else if (pWrapper.SlideID != null && pWrapper.RelatedContentID == null)
					sharedEventMaterialRecordType = Util.RecordTypeId('Shared_Presentation__c', 'Shared Slide');
				else if (pWrapper.RelatedContentID != null)
					sharedEventMaterialRecordType = Util.RecordTypeId('Shared_Presentation__c', 'Shared Related Content');
				else 
					sharedEventMaterialRecordType = Util.RecordTypeId('Shared_Presentation__c', 'Shared Presentation');
			}
			return sharedEventMaterialRecordType;
		}
		set;
	}
	
}