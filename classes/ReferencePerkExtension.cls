public without sharing class ReferencePerkExtension {
	
    public final static Id RECORD_TYPE_ID_REF_PERK_TEMPLATE = Schema.SObjectType.Reference_Perk__c.getRecordTypeInfosByName().get('Perk Template').getRecordTypeId();
    public Reference_Perk__c referencePerk { get; set; }
    private ApexPages.StandardController stdController { get; set; }
    private Id recordTypeId {
        get {
            if (recordTypeId == null) {
                if (referencePerk.RecordTypeId != null)
                	recordTypeId = referencePerk.RecordTypeId;
                else
                    recordTypeId = ApexPages.currentPage().getParameters().get('RecordType');
            }
            return recordTypeId;
        }
        set;
    }
    
    public ReferencePerkExtension(ApexPages.StandardController stdController) {
        this.stdController = stdController;
        //setup the initial reference perk
        referencePerk = (Reference_Perk__c)stdController.getRecord();
    }
    
    /**
     * @description: redirect to the standard layout if this isn't a Perk Template
     **/
    public pageReference redirect() {
        PageReference pg = null;//new PageReference('/');
        if (referencePerk.RecordTypeId != RECORD_TYPE_ID_REF_PERK_TEMPLATE) {
            if (referencePerk.Id != null) {
                pg = stdController.edit();
            }
            else {
                //get key prefix so we can redirect to standard new page
                Schema.DescribeSObjectResult describeResult = stdController.getRecord().getSObjectType().getDescribe();
                pg = new PageReference('/' + describeResult.getKeyPrefix() + '/e?nooverride=1&RecordType');
                pg.getParameters().put('RecordType', recordTypeId);
                pg.setRedirect(true);
            }
            pg.getParameters().put('nooverride', '1');
            pg.getParameters().put('retURL', ApexPages.currentPage().getParameters().get('retURL'));
        }
        return pg;
    }
}