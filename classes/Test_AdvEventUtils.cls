/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest
private class Test_AdvEventUtils {
    
    private static Presentation__c CreatePresentation(boolean CreateAndInsert) {
        // create the contact
        Contact con = TestUtilities.CreateNewContact(true);
        // create the meeting that the presentation will be associated with
        Meeting__c meeting = new Meeting__c(DateTime__c = system.now(), Type__c = 'Web Conference');
        insert meeting;
        // setup the presentation
        Presentation__c presentation = new Presentation__c(Contact__c = con.Id, 
                                                           Presentation_ID__c = '2629928b-6daf-49f0-833c-9bd81936ddb1',
                                                           Meeting__c = meeting.Id,
                                                           Microsite_ID__c = 'a906fc1a-26fb-4bdb-89c7-e8ec4dc18b0f');
        
        if (CreateAndInsert) insert presentation;
        return presentation;
    }
    
    private static Slide__c CreateSlide(boolean CreateAndInsert) {
        // create the contact
        Contact con = TestUtilities.CreateNewContact(true);
        
        // create the slide and set some defaults
        Slide__c slide = new Slide__c(Contact__c = con.Id,
                                      Slide_ID__c = '901ddf3c-f8a5-46f3-b58a-c7419500a40e',
                                      Presentation_ID__c = '2629928b-6daf-49f0-833c-9bd81936ddb1',
                                      Microsite_ID__c = 'a906fc1a-26fb-4bdb-89c7-e8ec4dc18b0f');
        
        if (CreateAndInsert) insert slide;
        return slide;
    }
    
    private static Related_Content__c CreateRelatedContent(boolean CreateAndInsert) {
        // create the contact
        Contact con = TestUtilities.CreateNewContact(true);
        // create the meeting that the presentation will be associated with
        Meeting__c meeting = new Meeting__c(DateTime__c = system.now(), Type__c = 'Web Conference');
        insert meeting;
        // create the slide and set some defaults
        Related_Content__c relatedContent = new Related_Content__c(Contact__c = con.Id,
        							  Meeting__c = meeting.Id,
                                      Related_Content_ID__c = '02135e6e-f453-49d7-babb-83dd90e738ff',
                                      Presentation_ID__c = '2629928b-6daf-49f0-833c-9bd81936ddb1',
                                      Microsite_ID__c = 'a906fc1a-26fb-4bdb-89c7-e8ec4dc18b0f');
        
        if (CreateAndInsert) insert relatedContent;
        return relatedContent;
    }
    
    
    // successfully save a new presentation
    static testMethod void Test_SavePresentation_Success() {
        // setup the unit test
        String command = 'SavePresentation';
        Contact con = TestUtilities.CreateNewContact(true);
        Meeting__c meeting = new Meeting__c(DateTime__c = system.now(), Type__c = 'Web Conference');
        insert meeting;
        
        // create the JSON String and encrypt
        String JSONString = '{"Command":"' + command + '",' +
                            '"MicrositeID":"abc123",' +
                            '"ContactId":"' + con.Id + '",' +
                            '"EventID":"' + meeting.Id + '",' +
                            '"PresentationID":"9483S42S"}';
        String encryptedString = EncryptionHelper.encryptString(JSONString);
        
        // instantiate the AdvEventUtils class and verify the Response
        AdvEventUtils eventUtils = new AdvEventUtils(encryptedString);
        system.assertEquals(AdvEventUtils.SUCCESS, eventUtils.pWrapper.Response);
        system.assertEquals(true, eventUtils.pWrapper.Successful);
        
        // get the resulting presentation and assert the data was mapped properly
        List<Presentation__c> presentations = [SELECT Id, Contact__c, Meeting__c, Microsite_ID__c, Presentation_Id__c 
                                                FROM Presentation__c 
                                                WHERE Contact__c = :con.Id];
        system.assertEquals(1, presentations.size());
        system.assertEquals(meeting.Id, presentations[0].Meeting__c);
        system.assertEquals('abc123', presentations[0].Microsite_ID__c);
        system.assertEquals('9483S42S', presentations[0].Presentation_Id__c);
        
        // Test updating the presentation
        
        // create the JSON String and encrypt
        JSONString = '{"Command":"' + command + '",' +
                            '"MicrositeID":"abc123",' +
                            '"ContactId":"' + con.Id + '",' +
                            '"EventID":"' + meeting.Id + '",' +
                            '"PresentationID":"9483S42S"}';
        encryptedString = EncryptionHelper.encryptString(JSONString);
        
        // instantiate the AdvEventUtils class and verify the Response
        eventUtils = new AdvEventUtils(encryptedString);
        system.assertEquals(AdvEventUtils.SUCCESS, eventUtils.pWrapper.Response);
        system.assertEquals(true, eventUtils.pWrapper.Successful);
        
        // get the resulting presentation and assert the data was mapped properly
        presentations = [SELECT Id, Contact__c, Meeting__c, Microsite_ID__c, Presentation_Id__c 
                                                FROM Presentation__c 
                                                WHERE Contact__c = :con.Id];
        system.assertEquals(1, presentations.size());
        system.assertEquals(meeting.Id, presentations[0].Meeting__c);
        system.assertEquals('abc123', presentations[0].Microsite_ID__c);
        system.assertEquals('9483S42S', presentations[0].Presentation_Id__c);
        
    }
    
    // create a JSON string with an unknown command and make sure the error is handled
    static testMethod void Test_SavePresentation_Fail_BadCommand() {
        // setup the unit test
        String command = 'UnknownCommand';
        Contact con = TestUtilities.CreateNewContact(true);
        Meeting__c meeting = new Meeting__c(DateTime__c = system.now(), Type__c = 'Web Conference');
        insert meeting;
        
        // create the JSON String and encrypt
        String JSONString = '{"Command":"' + command + '",' +
                            '"MicrositeID":"abc123",' +
                            '"ContactId":"' + con.Id + '",' +
                            '"EventID":"' + meeting.Id + '",' +
                            '"PresentationID":"9483S42S"}';
        String encryptedString = EncryptionHelper.encryptString(JSONString);
        
        // instantiate the AdvEventUtils class and verify the Response
        AdvEventUtils eventUtils = new AdvEventUtils(encryptedString);
        system.assertNotEquals(AdvEventUtils.SUCCESS, eventUtils.pWrapper.Response);
        system.assertEquals(false, eventUtils.pWrapper.Successful);
    }
    
    static testMethod void Test_SaveRelatedContent() {
    	
    	// setup the unit test
        String command = 'SaveRelatedContent';
        
        // create the contact
        Contact con = TestUtilities.CreateNewContact(true);
        
        // create the meeting that the presentation will be associated with
        Meeting__c meeting = new Meeting__c(DateTime__c = system.now(), Type__c = 'Web Conference');
        insert meeting;
        
    	// create the JSON sring and encrypt it
    	AdvEventUtils.PresentationWrapper pWrapper = new AdvEventUtils.PresentationWrapper();
		pWrapper.Command = command;
		pWrapper.MicrositeID = '223MicrositeID';
		pWrapper.ContactId = con.Id;
		pWrapper.EventID = meeting.Id;
		pWrapper.RelatedContentId = '123RelatedContentID';
		pWrapper.PresentationID = '321PresentationId';
		string encryptedString = EncryptionHelper.encryptString(JSON.serialize(pWrapper));
		
		// instantiate the AdvEventUtils class and verify the Response
        AdvEventUtils eventUtils = new AdvEventUtils(encryptedString);
        system.assertEquals(AdvEventUtils.SUCCESS, eventUtils.pWrapper.Response);
        system.assertEquals(true, eventUtils.pWrapper.Successful);
        
        // get the resulting presentation and assert the data was mapped properly
        List<Related_Content__c> relatedContentList = [SELECT Id, Contact__c, Meeting__c, Microsite_ID__c, Presentation_Id__c, Related_Content_ID__c
                                                FROM Related_Content__c 
                                                WHERE Contact__c = :con.Id];
        system.assertEquals(1, relatedContentList.size());
        system.assertEquals(pWrapper.EventID, relatedContentList[0].Meeting__c);
        system.assertEquals(pWrapper.PresentationID, relatedContentList[0].Presentation_ID__c);
        system.assertEquals(pWrapper.RelatedContentId, relatedContentList[0].Related_Content_ID__c);
    }
    
    // successfully save a new slide
    static testMethod void Test_SaveSlide() {
        // setup the unit test
        String command = 'SaveSlide';
        
        // create the contact
        Contact con = TestUtilities.CreateNewContact(true);
        // create the meeting that the presentation will be associated with
        Meeting__c meeting = new Meeting__c(DateTime__c = system.now(), Type__c = 'Web Conference');
        insert meeting;
        
        // create the JSON String and encrypt
        String JSONString = '{"Command":"' + command + '",' +
                            '"MicrositeID":"223MicrositeID",' +
                            '"ContactId":"' + con.Id + '",' +
                            '"EventID":"' + meeting.Id + '",' +
                            '"SlideId":"54321",' +
                            '"PresentationID":"123PresentationID"}';
        String encryptedString = EncryptionHelper.encryptString(JSONString);
        
        // instantiate the AdvEventUtils class and verify the Response
        AdvEventUtils eventUtils = new AdvEventUtils(encryptedString);
        system.assertEquals(AdvEventUtils.SUCCESS, eventUtils.pWrapper.Response);
        system.assertEquals(true, eventUtils.pWrapper.Successful);
        
        // get the resulting presentation and assert the data was mapped properly
        List<Slide__c> slides = [SELECT Id, Contact__c, Microsite_ID__c, Presentation_Id__c 
                                                FROM Slide__c 
                                                WHERE Contact__c = :con.Id];
        system.assertEquals(1, slides.size());
        system.assertEquals('223MicrositeID', slides[0].Microsite_ID__c);
        system.assertEquals('123PresentationID', slides[0].Presentation_ID__c);
        
        // Test updating slide
        
        // create the JSON String and encrypt
        JSONString = '{"Command":"' + command + '",' +
                            '"MicrositeID":"223MicrositeID",' +
                            '"ContactId":"' + con.Id + '",' +
                            '"EventID":"' + meeting.Id + '",' +
                            '"SlideId":"54321",' +
                            '"PresentationID":"123PresentationID"}';
        encryptedString = EncryptionHelper.encryptString(JSONString);
        
        // instantiate the AdvEventUtils class and verify the Response
        eventUtils = new AdvEventUtils(encryptedString);
        system.assertEquals(AdvEventUtils.SUCCESS, eventUtils.pWrapper.Response);
        system.assertEquals(true, eventUtils.pWrapper.Successful);
        
        // get the resulting presentation and assert the data was mapped properly
        slides = [SELECT Id, Contact__c, Microsite_ID__c, Slide_ID__c 
                                                FROM Slide__c 
                                                WHERE Contact__c = :con.Id];
        system.assertEquals(1, slides.size());
        system.assertEquals('223MicrositeID', slides[0].Microsite_ID__c);
        system.assertEquals('54321', slides[0].Slide_ID__c);
        
        // create the JSON string and encrypt it
    	AdvEventUtils.PresentationWrapper pWrapper = new AdvEventUtils.PresentationWrapper();
		pWrapper.Command = 'IsSavedSlide';
		pWrapper.ContactId = con.Id;
		pWrapper.SlideID = slides[0].Slide_ID__c;
		encryptedString = EncryptionHelper.encryptString(JSON.serialize(pWrapper));
		
		// instantiate the AdvEventUtils class and determine whether or not the slide IsSaved
        eventUtils = new AdvEventUtils(encryptedString);
        system.assertEquals(AdvEventUtils.SUCCESS, eventUtils.pWrapper.Response);
        system.assertEquals(true, eventUtils.pWrapper.Successful);
		system.assertEquals(true, eventUtils.pWrapper.IsSaved);
		
		// create the JSON string and encrypt it
    	pWrapper = new AdvEventUtils.PresentationWrapper();
		pWrapper.Command = 'IsSavedSlide';
		pWrapper.ContactId = con.Id;
		pWrapper.SlideID = 'NOT_SAVED_SLIDE';
		encryptedString = EncryptionHelper.encryptString(JSON.serialize(pWrapper));
		
		// instantiate the AdvEventUtils class and determine whether or not the slide IsSaved
        eventUtils = new AdvEventUtils(encryptedString);
        system.assertEquals(AdvEventUtils.SUCCESS, eventUtils.pWrapper.Response);
        system.assertEquals(true, eventUtils.pWrapper.Successful);
		system.assertEquals(false, eventUtils.pWrapper.IsSaved);
		
		// create the JSON string and encrypt it
    	pWrapper = new AdvEventUtils.PresentationWrapper();
		pWrapper.Command = 'IsSavedSlide';
		pWrapper.ContactId = con.Id;
		pWrapper.SlideID = null;
		encryptedString = EncryptionHelper.encryptString(JSON.serialize(pWrapper));
		
		// instantiate the AdvEventUtils class and determine whether or not the slide IsSaved
        eventUtils = new AdvEventUtils(encryptedString);
        system.assertEquals(false, eventUtils.pWrapper.Successful);
		system.assertNotEquals(true, eventUtils.pWrapper.IsSaved);
    }
    
    // get related content that has been saved
    static testMethod void Test_GetSavedRelatedContent() {
    	
        // setup the unit test
        String command = 'GetSavedRelatedContent';
        
        // setup the presentations
        Presentation__c presentation1 = CreatePresentation(false);
        Presentation__c presentation2 = CreatePresentation(false);
        List<Presentation__c> presentationsToInsert = new List<Presentation__c> { presentation1, presentation2 };
        insert presentationsToInsert;
        
        // create the related content record
        Related_Content__c relatedContent = new Related_Content__c(Meeting__c = presentation1.Meeting__c, Contact__c = presentation1.Contact__c,
        														   Related_Content_Id__c = '123relatedContentID', 
        														   Presentation_ID__c = presentation1.Presentation_ID__c);
        insert relatedContent;
        
        // create the JSON string and encrypt it
    	AdvEventUtils.PresentationWrapper pWrapper = new AdvEventUtils.PresentationWrapper();
		pWrapper.Command = command;
		pWrapper.ContactId = presentation1.Contact__c;
		string encryptedString = EncryptionHelper.encryptString(JSON.serialize(pWrapper));
        
        // instantiate the AdvEventUtils class and verify the Response
        AdvEventUtils eventUtils = new AdvEventUtils(encryptedString);
        system.assertEquals(AdvEventUtils.SUCCESS, eventUtils.pWrapper.Response);
        system.assertEquals(true, eventUtils.pWrapper.Successful);
        
        // get the resulting list of presentations and assert the data was mapped properly
        List<AdvEventUtils.SavedRelatedContent> relatedContentList = eventUtils.pWrapper.RelatedContentList;
        system.assertEquals(1, relatedContentList.size());
        system.assertEquals(presentation1.Presentation_Id__c, relatedContentList[0].SavedPresentationID);
    }
    
    // successfully save a new slide
    static testMethod void Test_GetSavedPresentations() {
        // setup the unit test
        String command = 'GetSavedPresentations';
        
        // setup the presentations
        Presentation__c presentation1 = CreatePresentation(false);
        Presentation__c presentation2 = CreatePresentation(false);
        List<Presentation__c> presentationsToInsert = new List<Presentation__c> { presentation1, presentation2 };
        insert presentationsToInsert;
        
        Slide_Note__c slideNote = new Slide_Note__c(Slide_ID__c = '123SlideID',
                                                    Presentation_ID__c = presentation1.Presentation_ID__c,
                                                    Contact__c = presentation1.Contact__c,
                                                    Notes__c = 'Slide Notes!');
        insert slideNote;
        
        // create the JSON String and encrypt
        String JSONString = '{"Command":"' + command + '",' +
                            '"ContactId":"' + presentation1.Contact__c + '"}';
        String encryptedString = EncryptionHelper.encryptString(JSONString);
        
        // instantiate the AdvEventUtils class and verify the Response
        AdvEventUtils eventUtils = new AdvEventUtils(encryptedString);
        system.assertEquals(AdvEventUtils.SUCCESS, eventUtils.pWrapper.Response);
        system.assertEquals(true, eventUtils.pWrapper.Successful);
        
        // get the resulting list of presentations and assert the data was mapped properly
        List<AdvEventUtils.SavedPresentation> presentations = eventUtils.pWrapper.Presentations;
        system.assertEquals(1, presentations.size());
        system.assertEquals(true, presentations[0].HasNotes);
        system.assertEquals(presentation1.Presentation_Id__c, presentations[0].SavedPresentationID);
    }
    
    // successfully save a new slide
    static testMethod void Test_GetSavedPresentations_withMicrositeID() {
        // setup the unit test
        String command = 'GetSavedPresentations';
        
        // setup the presentation
        Presentation__c presentation = CreatePresentation(true);
        
        // create the JSON String and encrypt
        String JSONString = '{"Command":"' + command + '",' +
                            '"ContactId":"' + presentation.Contact__c + '",' +
                            '"MicrositeID":"' + presentation.Microsite_ID__c + '"}';
        String encryptedString = EncryptionHelper.encryptString(JSONString);
        
        // instantiate the AdvEventUtils class and verify the Response
        AdvEventUtils eventUtils = new AdvEventUtils(encryptedString);
        system.assertEquals(AdvEventUtils.SUCCESS, eventUtils.pWrapper.Response);
        system.assertEquals(true, eventUtils.pWrapper.Successful);
        
        // get the resulting list of presentations and assert the data was mapped properly
        List<AdvEventUtils.SavedPresentation> presentations = eventUtils.pWrapper.Presentations;
        system.assertEquals(1, presentations.size());
        system.assertEquals(false, presentations[0].HasNotes);
        system.assertEquals(presentation.Presentation_Id__c, presentations[0].SavedPresentationID);
    }
    
    // get saved presentation slides
    static testMethod void Test_GetSavedSlides() {
        // setup the unit test
        String command = 'GetSavedSlides';
        Slide__c slide = CreateSlide(true);
        
        // create the presentation wrapper with command and contact id
        AdvEventUtils.PresentationWrapper wrapper = new AdvEventUtils.PresentationWrapper();
        wrapper.Command = command;
        wrapper.ContactID = slide.contact__c;
        String encryptedString = EncryptionHelper.encryptString(JSON.serialize(wrapper));
        
        // instantiate the AdvEventUtils class and verify the Response
        AdvEventUtils eventUtils = new AdvEventUtils(encryptedString);
        system.assertEquals(AdvEventUtils.SUCCESS, eventUtils.pWrapper.Response);
        system.assertEquals(true, eventUtils.pWrapper.Successful);
        
        // get the resulting list of presentations and assert the data was mapped properly
        List<AdvEventUtils.SavedSlide> slides = eventUtils.pWrapper.Slides;
        system.assertEquals(1, slides.size());
        system.assertNotEquals(null, slides[0].DateSaved);
        system.assertEquals(false, slides[0].HasNotes);
        system.assertEquals(slide.Slide_ID__c, slides[0].SavedSlideID);
    }
    
    static testMethod void Test_DeletePresentation() {
        // setup the unit test
        String command = 'DeletePresentation';
        
        // setup the presentation
        Presentation__c presentation = CreatePresentation(true);
        
        // create the JSON String and encrypt
        String JSONString = '{"Command":"' + command + '",' +
                            '"ContactId":"' + presentation.Contact__c + '",' +
                            '"PresentationID":"' + presentation.Presentation_Id__c + '"}';
        String encryptedString = EncryptionHelper.encryptString(JSONString);
        
        // instantiate the AdvEventUtils class and verify the Response
        AdvEventUtils eventUtils = new AdvEventUtils(encryptedString);
        system.assertEquals(AdvEventUtils.SUCCESS, eventUtils.pWrapper.Response);
        system.assertEquals(true, eventUtils.pWrapper.Successful);
        
        // find the presentation we inserted earlier (should be deleted)
        List<Presentation__c> presentations = [SELECT Id FROM Presentation__c WHERE Id = :presentation.Id];
        system.assertEquals(0, presentations.size());
    }
    
    static testMethod void Test_DeleteRelatedContent() {
    	
        // setup the unit test
        String command = 'DeleteRelatedContent';
        
        // setup the presentation
        Presentation__c presentation = CreatePresentation(true);
        
        // create the related content record
        Related_Content__c relatedContent = new Related_Content__c(Meeting__c = presentation.Meeting__c, Contact__c = presentation.Contact__c,
        														   Related_Content_Id__c = '123relatedContentID');
        insert relatedContent;
        
        // create the JSON sring and encrypt it
    	AdvEventUtils.PresentationWrapper pWrapper = new AdvEventUtils.PresentationWrapper();
		pWrapper.Command = command;
		pWrapper.RelatedContentID = relatedContent.Related_Content_ID__c;
		pWrapper.ContactId = relatedContent.Contact__c;
		pWrapper.EventID = relatedContent.Meeting__c;
		pWrapper.RelatedContentId = '123RelatedContentID';
		string encryptedString = EncryptionHelper.encryptString(JSON.serialize(pWrapper));
		
        // instantiate the AdvEventUtils class and verify the Response
        AdvEventUtils eventUtils = new AdvEventUtils(encryptedString);
        system.assertEquals(AdvEventUtils.SUCCESS, eventUtils.pWrapper.Response);
        system.assertEquals(true, eventUtils.pWrapper.Successful);
        
        // find the presentation we inserted earlier (should be deleted)
        List<Related_Content__c> relatedContentList = [SELECT Id FROM Related_Content__c WHERE Id = :relatedContent.Id];
        system.assertEquals(0, relatedContentList.size());
    }
    
    static testMethod void Test_DeleteSlide() {
        // setup the unit test
        String command = 'DeleteSlide';
        
        // setup the presentation
        Slide__c slide = CreateSlide(true);
        
        // create the JSON String and encrypt
        String JSONString = '{"Command":"' + command + '",' +
                            '"ContactId":"' + slide.Contact__c + '",' +
                            '"SlideID":"' + slide.Slide_ID__c + '"}';
        String encryptedString = EncryptionHelper.encryptString(JSONString);
        
        // instantiate the AdvEventUtils class and verify the Response
        AdvEventUtils eventUtils = new AdvEventUtils(encryptedString);
        system.assertEquals(AdvEventUtils.SUCCESS, eventUtils.pWrapper.Response);
        system.assertEquals(true, eventUtils.pWrapper.Successful);
        
        // find the presentation we inserted earlier (should be deleted)
        List<Slide__c> slides = [SELECT Id FROM Slide__c WHERE Id = :slide.Id];
        system.assertEquals(0, slides.size());
    }
    
    static testMethod void Test_SaveSlideNote() {
        // setup the unit test
        String command = 'SaveSlideNotes';
        String notes = 'These are test notes';
        
        // setup the slide
        Slide__c slide = CreateSlide(true);
        
        // create the JSON String and encrypt
        String JSONString = '{"Command":"' + command + '",' +
                            '"NoteString":"' + notes + '",' +
                            '"ContactId":"' + slide.Contact__c + '",' +
                            '"SlideId":"' + slide.Slide_ID__c + '",' +
                            '"PresentationID":"' + slide.Presentation_ID__c + '"}';
        String encryptedString = EncryptionHelper.encryptString(JSONString);
        
        // instantiate the AdvEventUtils class and verify the Response
        AdvEventUtils eventUtils = new AdvEventUtils(encryptedString);
        system.assertEquals(AdvEventUtils.SUCCESS, eventUtils.pWrapper.Response);
        system.assertEquals(true, eventUtils.pWrapper.Successful);
        
        // get the resulting presentation and assert the data was mapped properly
        List<Slide_Note__c> slideNotes = [SELECT Id, Presentation_ID__c, Notes__c, Slide_ID__c 
                                                FROM Slide_Note__c 
                                                WHERE Slide_ID__c = :slide.Slide_ID__c];
        system.assertEquals(1, slideNotes.size());
        system.assertEquals(slide.Presentation_ID__c, slideNotes[0].Presentation_ID__c);
        system.assertEquals(notes, slideNotes[0].Notes__c);
        
        /// test updating the slide note
        string notes_Updated = 'These are updated slide notes!';
        
        // create the JSON String and encrypt
        JSONString = '{"Command":"' + command + '",' +
                            '"NoteString":"' + notes_Updated + '",' +
                            '"ContactId":"' + slide.Contact__c + '",' +
                            '"SlideId":"' + slide.Slide_ID__c + '",' +
                            '"PresentationID":"' + slide.Presentation_ID__c + '"}';
        encryptedString = EncryptionHelper.encryptString(JSONString);
        
        // instantiate the AdvEventUtils class and verify the Response
        eventUtils = new AdvEventUtils(encryptedString);
        system.assertEquals(AdvEventUtils.SUCCESS, eventUtils.pWrapper.Response);
        system.assertEquals(true, eventUtils.pWrapper.Successful);
        
        // get the resulting presentation and assert the data was mapped properly
        slideNotes = [SELECT Id, Presentation_ID__c, Notes__c, Slide_ID__c 
                                                FROM Slide_Note__c 
                                                WHERE Slide_ID__c = :slide.Slide_ID__c];
        system.assertEquals(1, slideNotes.size());
        system.assertEquals(slide.Presentation_ID__c, slideNotes[0].Presentation_ID__c);
        system.assertEquals(notes_Updated, slideNotes[0].Notes__c);
        
    }
    
    static testMethod void Test_GetSlideNotes() {
        // setup the unit test
        String command = 'GetSlideNotes';
        String notes = 'These are test notes';
        
        // setup the slide
        Slide__c slide = CreateSlide(true);
        
        // create the slide note
        Slide_Note__c slideNote = new Slide_Note__c(Contact__c = slide.Contact__c, 
                                                    Slide_ID__c = slide.Slide_ID__c, 
                                                    Presentation_ID__c = slide.Presentation_ID__c,
                                                    Notes__c = notes);
        insert slideNote;
        
        // create the JSON String and encrypt
        String JSONString = '{"Command":"' + command + '",' +
                            '"ContactId":"' + slide.Contact__c + '",' +
                            '"SlideId":"' + slide.Slide_ID__c + '"}';
        String encryptedString = EncryptionHelper.encryptString(JSONString);
        
        // instantiate the AdvEventUtils class and verify the Response
        AdvEventUtils eventUtils = new AdvEventUtils(encryptedString);
        system.assertEquals(AdvEventUtils.SUCCESS, eventUtils.pWrapper.Response);
        system.assertEquals(true, eventUtils.pWrapper.Successful);
        
        // get the resulting presentation and assert the data was mapped properly
        String slideNotes = eventUtils.pWrapper.NoteString;
        system.assertEquals(notes, slideNotes);
        
    }
    
    static testMethod void Test_GetPresentationNotes() {
        // setup the unit test
        String command = 'GetPresentationNotes';
        String notes = 'These are test notes';
        String notes2 = 'Second set of notes';
        
        // setup 2 slides associated with the same presentation
        Slide__c slide1 = CreateSlide(false);
        Slide__c slide2 = CreateSlide(false);
        slide2.Presentation_ID__c = slide1.Presentation_ID__c;
        slide2.Contact__c = slide1.Contact__c;
        List<Slide__c> slidesToInsert = new List<Slide__c> { slide1, slide2 };
        insert slidesToInsert;
        
        // create the slide note1
        Slide_Note__c slideNote1 = new Slide_Note__c(Contact__c = slide1.Contact__c, 
                                                    Slide_ID__c = slide1.Slide_ID__c, 
                                                    Presentation_ID__c = slide1.Presentation_ID__c,
                                                    Notes__c = notes);
        // create the slide note2
        Slide_Note__c slideNote2 = new Slide_Note__c(Contact__c = slide2.Contact__c, 
                                                    Slide_ID__c = slide2.Slide_ID__c, 
                                                    Presentation_ID__c = slide2.Presentation_ID__c,
                                                    Notes__c = notes2);
        List<Slide_Note__c> slideNotesToInsert = new List<Slide_Note__c> { slideNote1, slideNote2 };
        insert slideNotesToInsert;
        
        // create the JSON String and encrypt
        String JSONString = '{"Command":"' + command + '",' +
                            '"ContactId":"' + slide1.Contact__c + '",' +
                            '"PresentationID":"' + slide1.Presentation_ID__c + '"}';
        String encryptedString = EncryptionHelper.encryptString(JSONString);
        
        // instantiate the AdvEventUtils class and verify the Response
        AdvEventUtils eventUtils = new AdvEventUtils(encryptedString);
        system.assertEquals(AdvEventUtils.SUCCESS, eventUtils.pWrapper.Response);
        system.assertEquals(true, eventUtils.pWrapper.Successful);
        
        // get the resulting presentation and assert the data was mapped properly
        List<AdvEventUtils.SlideNote> slideNotes = eventUtils.pWrapper.Notes;
        system.assertEquals(2, slideNotes.size());
        
    }
    
    
    static testMethod void Test_ShareSlide() {
        String command = 'ShareSlide';
        
        util.BypassAllTriggers = true;
        util.IsTest(true);
        
        // setup the unit test
        List<String> recipientEmails = new List<String> { 'MSmith@advisory.com', 'LWayne@advisory.com' };
        Contact shareSender_contact = TestUtilities.CreateNewContact(false);
        Contact shareRecipient_contact = TestUtilities.CreateNewContact(false);
        shareRecipient_contact.Email = 'MSmith@advisory.com';
        List<Contact> conList = new List<Contact> { shareRecipient_contact, shareSender_contact };
        insert conList;
        
        // setup the slide
        Slide__c slide = CreateSlide(true);
        
        // create the command with params for generating JSON
        AdvEventUtils.PresentationWrapper wrapper = new AdvEventUtils.PresentationWrapper();
        wrapper.Command = command;
        wrapper.MicrositeID = slide.Microsite_ID__c;
        wrapper.ContactID = shareSender_contact.Id;
        wrapper.SlideID = slide.Slide_ID__c;
        wrapper.PresentationID = slide.Presentation_ID__c;
        wrapper.IncludesNotes = true;
        wrapper.Recipients = recipientEmails;
        
        // create the JSON String and encrypt
        String JSONString = JSON.serialize(wrapper);
        String encryptedString = EncryptionHelper.encryptString(JSONString);
        
        // instantiate the AdvEventUtils class and verify the Response
        AdvEventUtils eventUtils = new AdvEventUtils(encryptedString);
        system.assertEquals(AdvEventUtils.SUCCESS, eventUtils.pWrapper.Response);
        system.assertEquals(true, eventUtils.pWrapper.Successful);
        
        // get the meeting shares that were generated
        List<Shared_Presentation__c> meetingShares = [SELECT Id, Presentation_ID__c, Includes_Notes__c, Slide_ID__c 
                                                FROM Shared_Presentation__c 
                                                WHERE Slide_ID__c = :slide.Slide_ID__c];
        system.assertEquals(2, meetingShares.size());
        system.assertEquals(true, meetingShares[0].Includes_Notes__c);
        system.assertEquals(true, meetingShares[1].Includes_Notes__c);
        
        // verify the Recipient_Emails_Not_Found__c field is filled in properly
        List<Shared_Presentation__c> meetingShares_VerifyRecipients = [SELECT Id, Recipient_Emails_Not_Found__c 
                                                FROM Shared_Presentation__c 
                                                WHERE Slide_ID__c = :slide.Slide_ID__c AND Contact__c = :shareRecipient_contact.Id];
        system.assertEquals(1, meetingShares_VerifyRecipients.size());
        List<Shared_Presentation__c> meetingShares_VerifyRecipients_NotFound = [SELECT Id, Recipient_Emails_Not_Found__c 
                                                FROM Shared_Presentation__c 
                                                WHERE Slide_ID__c = :slide.Slide_ID__c AND Contact__c = null];
        system.assert(meetingShares_VerifyRecipients_NotFound[0].Recipient_Emails_Not_Found__c.equalsIgnoreCase('LWayne@advisory.com'));
    }
    
    static testMethod void Test_SharePresentation() {
        String command = 'SharePresentation';
        
        util.BypassAllTriggers = true;
        util.IsTest(true);
        
        // setup the unit test
        List<String> recipientEmails = new List<String> { 'MSmith@advisory.com', 'LWayne@advisory.com' };
        Contact shareSender_contact = TestUtilities.CreateNewContact(false);
        Contact shareRecipient_contact = TestUtilities.CreateNewContact(false);
        shareRecipient_contact.Email = 'MSmith@advisory.com';
        List<Contact> conList = new List<Contact> { shareRecipient_contact, shareSender_contact };
        insert conList;
        
        // setup the presentation
        Presentation__c presentation = CreatePresentation(true);
        
        // create the command with params for generating JSON
        AdvEventUtils.PresentationWrapper wrapper = new AdvEventUtils.PresentationWrapper();
        wrapper.Command = command;
        wrapper.MicrositeID = presentation.Microsite_ID__c;
        wrapper.ContactID = shareSender_contact.Id;
        wrapper.PresentationID = presentation.Presentation_ID__c;
        wrapper.IncludesNotes = true;
        wrapper.Recipients = recipientEmails;
        
        // create the JSON String and encrypt
        String JSONString = JSON.serialize(wrapper);
        String encryptedString = EncryptionHelper.encryptString(JSONString);
        
        // instantiate the AdvEventUtils class and verify the Response
        AdvEventUtils eventUtils = new AdvEventUtils(encryptedString);
        system.assertEquals(AdvEventUtils.SUCCESS, eventUtils.pWrapper.Response);
        system.assertEquals(true, eventUtils.pWrapper.Successful);
        
        // get the meeting shares that were generated
        List<Shared_Presentation__c> meetingShares = [SELECT Id, Presentation_ID__c, Includes_Notes__c, Slide_ID__c 
                                                FROM Shared_Presentation__c 
                                                WHERE Presentation_ID__c = :presentation.Presentation_ID__c];
        system.assertEquals(2, meetingShares.size());
        system.assertEquals(true, meetingShares[0].Includes_Notes__c);
        system.assertEquals(true, meetingShares[1].Includes_Notes__c);
        
        // verify the Recipient_Emails_Not_Found__c field is filled in properly
        List<Shared_Presentation__c> meetingShares_VerifyRecipients = [SELECT Id, Recipient_Emails_Not_Found__c 
                                                FROM Shared_Presentation__c 
                                                WHERE Presentation_ID__c = :presentation.Presentation_ID__c
                                                AND Contact__c = :shareRecipient_contact.Id];
        system.assertEquals(1, meetingShares_VerifyRecipients.size());
        List<Shared_Presentation__c> meetingShares_VerifyRecipients_NotFound = [SELECT Id, Recipient_Emails_Not_Found__c 
                                                FROM Shared_Presentation__c 
                                                WHERE Presentation_ID__c = :presentation.Presentation_ID__c AND Contact__c = null];
        system.assert(meetingShares_VerifyRecipients_NotFound[0].Recipient_Emails_Not_Found__c.equalsIgnoreCase('LWayne@advisory.com'));
    }
    
    static testMethod void Test_ShareRelatedContent() {
        String command = 'LogRelatedContentShared';
        
        util.BypassAllTriggers = true;
        util.IsTest(true);
        
        // setup the unit test
        List<String> recipientEmails = new List<String> { 'MSmith@advisory.com', 'LWayne@advisory.com' };
        Contact shareSender_contact = TestUtilities.CreateNewContact(false);
        Contact shareRecipient_contact = TestUtilities.CreateNewContact(false);
        shareRecipient_contact.Email = 'MSmith@advisory.com';
        List<Contact> conList = new List<Contact> { shareRecipient_contact, shareSender_contact };
        insert conList;
        
        // setup the presentation
        Related_Content__c relatedContent = CreateRelatedContent(true);
        
        // create the command with params for generating JSON
        AdvEventUtils.PresentationWrapper wrapper = new AdvEventUtils.PresentationWrapper();
        wrapper.Command = command;
        wrapper.MicrositeID = relatedContent.Microsite_ID__c;
        wrapper.ContactID = shareSender_contact.Id;
        wrapper.RelatedContentID = relatedContent.Related_Content_ID__c;
        wrapper.SharedEmails = recipientEmails;
        
        // create the JSON String and encrypt
        String JSONString = JSON.serialize(wrapper);
        String encryptedString = EncryptionHelper.encryptString(JSONString);
        
        // instantiate the AdvEventUtils class and verify the Response
        AdvEventUtils eventUtils = new AdvEventUtils(encryptedString);
        system.assertEquals(AdvEventUtils.SUCCESS, eventUtils.pWrapper.Response);
        system.assertEquals(true, eventUtils.pWrapper.Successful);
        
        // get the shared event material records that were generated
        List<Shared_Presentation__c> sharedEventMaterials = [SELECT Id, Presentation_ID__c, Includes_Notes__c, Slide_ID__c, RecordTypeId
                                                FROM Shared_Presentation__c 
                                                WHERE Related_Content_ID__c = :relatedContent.Related_Content_ID__c];
        system.assertEquals(2, sharedEventMaterials.size());
        system.assertEquals(false, sharedEventMaterials[0].Includes_Notes__c);
        system.assertEquals(Util.RecordTypeId('Shared_Presentation__c', 'Shared Related Content'), sharedEventMaterials[0].RecordTypeId, 
        					'The record type of this shared event material record should be related content.');
        
        // verify the Recipient_Emails_Not_Found__c field is filled in properly
        List<Shared_Presentation__c> sharedEventMaterial_VerifyRecipients = [SELECT Id, Recipient_Emails_Not_Found__c 
                                                FROM Shared_Presentation__c 
                                                WHERE Related_Content_ID__c = :relatedContent.Related_Content_ID__c
                                                AND Contact__c = :shareRecipient_contact.Id];
        system.assertEquals(1, sharedEventMaterial_VerifyRecipients.size());
        List<Shared_Presentation__c> sharedEventMaterial_VerifyRecipients_NotFound = [SELECT Id, Recipient_Emails_Not_Found__c 
                                                FROM Shared_Presentation__c 
                                                WHERE Related_Content_ID__c = :relatedContent.Related_Content_ID__c AND Contact__c = null];
        system.assert(sharedEventMaterial_VerifyRecipients_NotFound[0].Recipient_Emails_Not_Found__c.equalsIgnoreCase('LWayne@advisory.com'));
    }
    
    /*static testMethod void Test_RequestAccess() {
        // setup the unit test
        String command = 'SaveWarmLead';
        
        // setup adv.com user contact
        Contact con = TestUtilities.CreateAdvUserContact(true);
        // get the institution
        Account institution = [SELECT Account_Formal_Name__c FROM Account WHERE Id = :con.AccountId LIMIT 1];
        
        // setup the presentation
        Presentation__c presentation = CreatePresentation(true);
        
        // create the wrapper object
        AdvUser wrapper = new AdvUser();
        wrapper.MicrositeID = presentation.Microsite_ID__c;
        wrapper.PresentationID = presentation.Presentation_ID__c;
        wrapper.EventID = presentation.Meeting__c;
        wrapper.First_Name = con.FirstName;
        wrapper.Last_Name = con.LastName;
        wrapper.Title = con.Title;
        wrapper.OrganizationName = institution.Account_Formal_Name__c;
        wrapper.City = con.Primary_City__c;
        wrapper.State = con.Primary_State_Province__c;
        wrapper.Email_Address = con.Email;
        wrapper.Comments = 'test comments';
        wrapper.Command = command;
        
        // create the JSON String and encrypt
        String JSONString = JSON.serialize(wrapper);
        String encryptedString = EncryptionHelper.encryptString(JSONString);
        
        // set the page reference
        PageReference pageRef = Page.AdvisorySite;
        Test.setCurrentPage(pageRef);
        
        // Add parameters to page URL 
        ApexPages.currentPage().getParameters().put('req', encryptedString);
        
        // Instantiate controller
        AdvisorySiteController controller = new AdvisorySiteController();
        controller.initialize();
        
        // get the response
        system.debug('@@controller.JSONResponseDecrypted:' + AdvUtils.Decrypt(EncodingUtil.base64Decode(controller.JSONResponse)));
        String decryptedJSONResponse = AdvUtils.Decrypt(EncodingUtil.base64Decode(controller.JSONResponse));
        // verify the response was succesful
        system.assertEquals(true, decryptedJSONResponse.contains('Success'));
        
        List<Warm_Lead__c> warmLeads = [SELECT Id, Primary_Program__c, advisory_com_initiating_page_program__c, Comments__c, Sub_Type__c, Lead_Origin__c
                                            FROM Warm_Lead__c WHERE advisory_com_logged_in_status__c = 'No'];
        
        // verify the warm lead field values
        system.assertEquals(1, warmLeads.size());
        
    }*/
	
    
}