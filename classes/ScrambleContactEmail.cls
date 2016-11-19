global class ScrambleContactEmail implements Database.Batchable<SObject>, Database.Stateful{
    String scrambleFrom { get; set; }
    String scrambleTo { get; set; }
    Double failedUpdates { get; set; }

    global ScrambleContactEmail(String scrambleFrom, String scrambleTo){
        this.scrambleFrom = scrambleFrom;
        this.scrambleTo = scrambleTo;
        failedUpdates = 0;
    }

    global Database.queryLocator start(Database.BatchableContext ctx){
        String filter = '%' + scrambleTo + '%';
        return Database.getQueryLocator(
            [SELECT Id, Email, Asst_Email__c, Advisory_com_Preferred_Email_Address__c FROM Contact
                WHERE (Email != null) AND (Email !=  '') AND (NOT (Email LIKE :filter))]
        );
    }

    global void execute(Database.BatchableContext ctx, List<Sobject> scope){
        List<Contact> contacts = (List<Contact>)scope;

        for(Integer i = 0; i < contacts.size(); i++){
            contact c = contacts[i];
            
            // scramble the contact's Assistant email field
            c.Asst_Email__c = getScrambledEmail(c.Asst_Email__c);
            
            // scramble the adv.com preferred email
            c.Advisory_com_Preferred_Email_Address__c = getScrambledEmail(c.Advisory_com_Preferred_Email_Address__c);

            // skip any test contacts using regex: t[0-9]+@advisory.com  (ie: t00234@advisory.com OR tn2162@eab.com)
            Pattern myPattern = Pattern.compile('tn?[0-9]+@(advisory|eab).com');
            Matcher myMatcher = myPattern.matcher(c.Email);
            // if it matches the expression, skip it
            if (myMatcher.matches()) continue;
            else c.Email = getScrambledEmail(string.escapeSingleQuotes(c.Email));
            
            c.Email = c.Email.replace('\\\'','\'');
            
            //populate required fields
            if (c.Primary_State_Province__c == null) c.Primary_State_Province__c = 'DC';
            
        }
        // VH 7/26/13 - Bypass all triggers
        util.BypassAllTriggers = true;
        List<Database.SaveResult> dsrs = Database.update(contacts, false);
        for(Database.SaveResult dsr : dsrs){
            if(!dsr.isSuccess()){
                failedUpdates++;
            }
        }
    }
    
    public String getScrambledEmail(String email) {
        
        // if the email is null, return immediately
        if (email == null) return email;
        
        // get the position of the search string (typically the '@' symbol)
        Integer pos = email.indexOf(scrambleFrom);
        
        // replace the scrambleFrom string with the scrambleTo string (ie: '@' -> '@junkabc.')
        if(pos >= 0) {
            email = email.replace(scrambleFrom, scrambleTo);
        } else {
            email = email + scrambleTo;
        }
        
        return email;
    }
    
    global void finish(Database.BatchableContext ctx){
        AsyncApexJob a = [SELECT id, ApexClassId, JobItemsProcessed, TotalJobItems, NumberOfErrors, CreatedBy.Email
                            FROM AsyncApexJob WHERE id = :ctx.getJobId()];

        String emailMessage = 'Your batch job ScrambleContactEmail has finished.\n\n'
            + 'It executed ' + a.totalJobItems + ' batches.  Of which, ' + a.jobitemsprocessed
            + ' processed without any exceptions thrown and ' + a.numberOfErrors
            + ' batches threw unhandled exceptions.  Of the batches that executed without error, '
            + failedUpdates + ' records were not updated successfully.';

        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        String[] toAddresses = new String[] {a.createdBy.email};
        mail.setToAddresses(toAddresses);
        mail.setReplyTo('noreply@salesforce.com');
        mail.setSenderDisplayName('Batch Job Summary');
        mail.setSubject('Batch job completed');
        mail.setPlainTextBody(emailMessage);
        mail.setHtmlBody(emailMessage);
        Messaging.sendEmail(new Messaging.SingleEmailMessage[]{ mail });
    }
}