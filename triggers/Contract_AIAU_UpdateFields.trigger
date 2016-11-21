/*
    Purpose:        Membership - Membership is connected to Contract if
                        (Contract (Status__c = 'ATL' or Status__c = 'Honorary' or Status__c = 'Dropped')
                        AND (Membership Program == Contract Program)
                        AND ((Membership Account_Name__c == Contract.Payer_Account__c)
                            OR (There is a Contract Integrated Account on this Contract where Membership Account_Name__c = CIA.Account__c))

                        Field Updates
                            Earliest_Contract__c: Contract with earliest Start__c of all connected Contracts
                            Latest_Contract__c: Contract with latest End__c of all connected Contracts
                            Active_Contract_Idenfied__c:
                                    Contract with latest End__c from (list of Contracts where Start__c <= TODAY and End__c >= TODAY)
                                else:
                                    Contract with earliest Start__c from (list of Contracts where Start__c > TODAY)

                    Opportunity: Source Opportunity on triggering Contract record
                        Field Update
                            Signed_Opportunity_Contract__c: If this Contract has a Source_Opportunity__c, set that Opportunity's field Signed_Opportunity_Contract__c to triggering id

    Create By:  Nathan Banas (SAP) - 12/2010

    Last Modified By:   Drew Freeman - 3/7/2012

    Current Version:    v1.4

    Revision Log:       v1.0 - (NB) Created Trigger.
                        v1.1 - (JN) Added this Header, comments and test methods 1/24/2011
                        v1.2 - 10/13/2011 - (Simplyforce) Modified for CR-20111011-156
                        v1.3 - 03/07/2012 - (Drew Freeman) Modified for CR-105
                        v1.4 - Modified By - Abhinav Sharma - 07/07/2014 - CR-20140618-5849 - Catch DML errors in triggers to reduce exception emails to SFAdmin
                        v1.5 - Modified By - Jeffery Sun - 09/30/2015 - CR-20130328-2770
*/
trigger Contract_AIAU_UpdateFields on Contract__c (After Insert, After Update) {

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
            ContractUtilities.PopulateContractFields(trigger.newMap); // VRH broke a lot of this logic out in to a utility class
            System.Debug('### End Contract_AIAU_UpdateFields Trigger ###');
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