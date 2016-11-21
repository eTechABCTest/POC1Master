public class RelationshipInteractionHelper {
	
    public static Relationship_Interaction__c setDefaults(Relationship_Interaction__c interaction) {
        if (interaction.OwnerId == null) interaction.OwnerId = UserInfo.getUserId();
        return interaction;
    }
    
    /**
     * @description: membership interaction contact wrapper class
     **/
    public class memInteractionContactWrapper {
        public memInteractionContactWrapper(MemberInteractionContactMtM__c iContact) {
            this.contactMTM = iContact;
            this.Title = iContact.Contact__r.Title;
            this.Email = iContact.Contact__r.Email;
            this.Phone = iContact.Contact__r.Phone;
        }
        public memInteractionContactWrapper() {}
        public MemberInteractionContactMtM__c contactMTM { get; set; }
        public string Title { get; set; }
        public string Email { get; set; }
        public string Phone { get; set; }
        public Relationship_Interaction__c dummyInteraction {
            get {
                if (dummyInteraction == null) dummyInteraction = new Relationship_Interaction__c();
                return dummyInteraction;
            }
            set;
        }
    }
    
    public static Id getPreviousInteractionId() {
        //get the record id
        return ApexPages.currentPage().getParameters().get('previousInteraction');
    }
    
}