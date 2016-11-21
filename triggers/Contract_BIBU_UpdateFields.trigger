/*
    Purpose:    Update various Contract and related Membership fields:
                    Contract
                        Name: AcctName(truncated to 55 characters) + ' - ' + Program Acronym + ' - ' + Year__c;
                        Business_Line_From_Trigger__c: Copied from associated Program__r.Business_Line__c
                        Active__c: True if Start__c <= Today and End__c >= Today
                        Join_Date__c: Join Date of previous Contract on Source Opp, if applicable. Note: only runs on insert
                        Previous_Contract__c: Source_Opportunity__r.Previous_Contract__c, if not null

    Created By:     Nathan Banas (SAP) - 11/2010

    Last Modified By:   Jeremy Nottingham (SAP) - 5/6/2011

    Current Version:    v1.5

    Revision Log:       v1.0 - (JB-11/2010) Created this trigger.
                        v1.1 - (JN - 1/27/2011) - Added this header
                            - Added logic to populate triggingrecord.Previous_Contract__c = Source_Opportunity__r.Previous_Contract__c
                        v1.2 - (JN 5/6/11) Removed Invoice Contact field update logic
                             - Join Date: changed to only run on insert, not update
                        v1.3 - 10/13/2011 - (Simplyforce) Modified for CR-20111011-156
                        v1.4 - 04/09/2012 - (Simplyforce) Modified for CR-20111122-239
                        v1.5 - Modified By - Abhinav Sharma - 07/07/2014 - CR-20140618-5849 - Catch DML errors in triggers to reduce exception emails to SFAdmin
                        v1.6 - Modified By - Jeffery Sun - 09/30/2015 - CR-20130328-2770

*/
trigger Contract_BIBU_UpdateFields on Contract__c (before insert, before update, after update) {

    try {

        // if bypass all triggers is true, return without processing
        if (util.BypassAllTriggers) return;

        //Flag to execute the trigger only in valid conditions
        Boolean executeTrigger = true;

        //check if the user is not related to data loader profile only then execute the complete logic
        Id dataloaderProfileId = label.ABC_Dataloader_Profile_Id;

        //check if the current user belong to ABC Data loader profile and do not execute teh trigger in this case
        if(dataloaderProfileId != null && UserInfo.getProfileId() == dataloaderProfileId) {
            executeTrigger = false;
        }

        //execute the trigger only if executeTrigger flag is true
        if(executeTrigger) {
            System.Debug('### Begin Contract_BIBU_UpdateFields Trigger ###');

            //Look for flags to skip reaction
            if (!Util.IsBatch && !Util.IsTrigger_Invoice)
            {
                //Condition added By Bhavi : 04/09/2012 : CR-20111122-239
                //Check for the request type
                if(Trigger.isBefore) {

                    //Check for the event type
                    if(Trigger.isInsert || Trigger.isUpdate) {
                        System.Debug('### Begin Contract Name Update ###');
                        Integer maxacctnamelength = 55;

                        List<Id> PayerAccountIds = new List<Id>();
                        List<Id> ProgramIds = new List<Id>();

                        for(Contract__c c : Trigger.New)
                        {
                            PayerAccountIds.Add(c.Payer_Account__c);
                            ProgramIds.Add(c.Program__c);
                        }

                        Map<ID, Account> PayerAccountInfo = new Map<ID, Account>([select id, Name from Account where Id in :PayerAccountIds]);
                        Map<ID, Program__c> ProgramInfo = new Map<Id, Program__c>([select id, Program_Acronym__c from Program__c where Id in :ProgramIds]);

                        for(Contract__c c : Trigger.New)
                        {
                            string AcctName = '';
                            string ProgAcronym = '';
                            String YearString = '';

                            if(c.Payer_Account__c != null)
                            {
                                if(PayerAccountInfo.get(c.Payer_Account__c).Name != null)
                                    AcctName = PayerAccountInfo.get(c.Payer_Account__c).Name;
                            }
                            AcctName = AcctName.substring(0,Math.min(AcctName.length(), maxacctnamelength));

                            if(c.Program__c != null)
                            {
                                if(ProgramInfo.get(c.Program__c) != null)
                                    ProgAcronym = ProgramInfo.get(c.Program__c).Program_Acronym__c;
                            }

                            if (c.Year__c != null) YearString = c.Year__c;

                            System.Debug('### Contract Name Insert ###');
                            System.Debug('### Current Name: ' + c.Name + ' ###');
                            System.Debug('### Changing Name To: ' + AcctName + ' - ' + ProgAcronym + ' - ' + YearString + ' ###');

                            c.Name = AcctName + ' - ' + ProgAcronym + ' - ' + YearString;

                        }
                        System.Debug('### End Contract Name Update ###');

                        //////////////////////////////////////////////////////

                        System.Debug('### Begin Contract Business Line From Trigger Update ###');

                        List<Id> ListProgramIds = new List<Id>();
                        List<Program__c> ListPrograms = new List<Program__c>();

                        for(Contract__c c : Trigger.New)
                        {
                            if(c.Program__c != null)
                            {
                                ListProgramIds.add(c.Program__c);
                            }
                        }

                        ListPrograms = [select Id, Business_Line__c from Program__c where Id in :ListProgramIds];

                        if(ListPrograms.size() > 0)
                        {
                            for(Contract__c c : Trigger.New)
                            {
                                for(Program__c p : ListPrograms)
                                {
                                    if(c.Program__c == p.Id)
                                    {
                                        if(c.Business_Line_From_Trigger__c != p.Business_Line__c)
                                            c.Business_Line_From_Trigger__c = p.Business_Line__c;

                                        break;
                                    }
                                }
                            }
                        }

                        System.Debug('### End Contract Business Line From Trigger Update ###');

                        //////////////////////////////////////////////////////


                        List<Id> OppIds = new List<Id>();

                        for(Contract__c c : Trigger.New)
                        {
                            if(c.Source_Opportunity__c != null)
                                OppIds.add(c.Source_Opportunity__c);
                        }
                        System.Debug('### Begin Contract Active__c, Invoice Contact, Previous_Contract__c & Join Date Update ###');

                        map<id, Opportunity> oppid2oppmap = new map<id, Opportunity>([select Previous_Contract__r.Join_Date__c, Previous_Contract__c, Recordtype.Name,
                            (select Id, ContactId from OpportunityContactRoles where Role = 'Invoice Contact')
                            from Opportunity where id in : OppIds]);
                        for(Contract__c c : Trigger.New)
                        {

                            //Set Active checkbox
                            if ((c.Start__c != null) && (c.End__c != null)) {
                                if ((c.Start__c <= system.today()) && (c.End__c >= system.today() ) )
                                    c.Active__c = true;
                                else
                                    c.Active__c = false;
                            } else {
                                c.Active__c = false;
                            }

                            if(c.Source_Opportunity__c != null)
                            {
                                //Find source opp for this contract
                                Opportunity sourceOpp = oppid2oppmap.get(c.Source_Opportunity__c);

                                /* Removed 5/6/11 JN
                                //Set Invoice Contact
                                for (OpportunityContactRole cr : sourceOpp.OpportunityContactRoles)
                                {
                                    c.Invoice_Contact__c = cr.ContactId;
                                    break;
                                }
                                */

                                //Set Previous Contract to Previous Contract on source Opp
                                if (sourceOpp.Previous_Contract__c != null)
                                {
                                    c.Previous_Contract__c = sourceOpp.Previous_Contract__c;
                                }

                                //update Join Date from source Opportunity.Previous Contract join date
                                if ((Trigger.IsInsert) && (sourceOpp.Previous_Contract__r.Join_Date__c != null))
                                {
                                    c.Join_Date__c = sourceOpp.Previous_Contract__r.Join_Date__c;
                                }

                            }
                        }

                        System.Debug('### End Contract Invoice Contact, Previous_Contract__c & Join Date Update ###');
                    }
                } else if(Trigger.isAfter) {

                    //Check for the event Type
                    if(Trigger.isUpdate) {

                        //Call helper class method to update the membership status field on Membership record
                        ContractABCTriggerHelper.updateMembershipStatusByContracts(Trigger.newMap);
                    }
                }

            }

            System.Debug('### End Contract_BIBU_UpdateFields Trigger ###');
        }
    //Catching DML Exceptions
    } catch(DMLException e) {

        //Add Error Message on Page
        if(Trigger.isDelete)
            Trigger.Old[0].addError(e.getDmlMessage(0));
        else
            Trigger.New[0].addError(e.getDmlMessage(0));

    //Catching all Exceptions
    } catch(Exception e) {

        //Add Error Message on Page
        if(Trigger.isDelete)
            Trigger.Old[0].addError(e.getMessage());
        else
            Trigger.New[0].addError(e.getMessage());
    }
}