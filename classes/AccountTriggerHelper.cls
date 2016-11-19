/*
 *  Purpose         :   This class is helper class for trigger on Membership object.
 *
 *  Create By       :   Simplyforce Technology(Bhavi)
 *
 *  Created Date    :   09/04/2012
 *
 *  Revision Log    :   V_1.0 Created
 *                      V_1.1 Modified - 9/5/13 - VH - Added method to require comments upon approval rejection
                        V_1.2 Modified - 12/18/13 - VH - CR-3734 & CR-3556
                        V_1.3 Modified - 03/05/2014 - Abhinav Sharma - CR-20140131-4429
                        V_1.4 Modified - 03/05/2014 - Abhinav Sharma - CR-20140204-4441
                        V_1.5 Modified - 03-10-2014 - CR-20140220-4547 - Modify method (rollupChildAcctDataToParents)
                        V_1.6 Modified - 04/03/2014 - CR-20140201-4431 - Commented Out Method getAccountWithoutSharing(Id acctId)
                        V_1.7 Modified - 07/03/2014 - CR-20140618-5845 - Add Institution Description to Expert Center Case layout
                        V_1.8 Modified - Ajit Surana - 02/03/2015 - CR-20141216-8346
                        V_1.9 Modified - Jeffery Sun - 09/30/2015 - CR-20130328-2770
                        V_1.10 Modified - Rajeev Jain - 06/07/2016 - Royall Migration - Royall SFDC Schema Release - Distinction of Royall Account with EAB Accounts - Work on AfterInsert,Update,Delete
                        V_1.11 Modified - Rajeev Jain - 06/24/2016 - Royall Migration - Royall SFDC Schema Release - Manual merging of the code written in 'shift_update_acc_years_status' AccountTrigger in Royall Instance
						V_1.12 - Modified By - Abhinav Sharma - 06/30/2016 - CR-20160419-9779 - Modify method (countryToRegionMap)
						V_1.13 - Modified By - Mahendra Swarnkar - 07/28/2016 - CR-20160419-9779 - Modify method (countryToRegionMap) as per the following UAT changes
									1) Update the "Caribbean" region with the "Latin America" region.
									2) Moving India from the Australasia region to the Middle East Region
						V_1.14 - Modified By - Mahendra Swarnkar - CR-20160802-10078 - 09/05/2016
 *
 **/
public without sharing class AccountTriggerHelper {

    //Commented By Abhinav Sharma - 04/03/2014 - CR-20140201-4431
    // get the institution with OpenActivities / ActivityHistories - this can only be done in a class without sharing
    /*public static Account getAccountWithoutSharing(Id acctId) {

        return [SELECT Id, Name, RecordTypeId, RecordType.Name, RecordType.DeveloperName,
                   (SELECT Id, Subject, ActivityDate, WhoId, AccountId, IsTask, OwnerId FROM ActivityHistories
                    ORDER BY ActivityDate DESC NULLS LAST, LastModifiedDate DESC LIMIT 70),
                   (SELECT Id, Subject, ActivityDate, WhoId, AccountId, IsTask, OwnerId FROM OpenActivities
                    ORDER BY ActivityDate DESC NULLS LAST, LastModifiedDate DESC LIMIT 70)
                   FROM Account WHERE Id = :acctId];
    }*/

    
    // CR-3556 check to see if the Fast Track rollup field has been updated.
    // If so, update any parent institutions so they can receive the updated info
    public static void populateParentAcctRollups(list<Account> accounts, map<Id, Account> oldAccounts) {

        set<Id> parentAcctsToUpdate = new set<Id>();

        for (Account acct : accounts) {

            // get the old account
            Account oldAcct = oldAccounts.get(acct.Id);

            if (oldAcct != null) {

                if (acct.Fast_Track__c != oldAcct.Fast_Track__c ||
                    acct.Fast_Track_Units__c != oldAcct.Fast_Track_Units__c ||
                    acct.PT_Renewal_CV__c != oldAcct.PT_Renewal_CV__c ||
                    acct.RI_TD_Renewal_CV__c != acct.RI_TD_Renewal_CV__c ||
                    acct.At_Risk_Renewal__c != oldAcct.At_Risk_Renewal__c ||
                    acct.Total_Contract_Value__c != oldAcct.Total_Contract_Value__c ||
                    acct.ParentId != oldAcct.ParentId)
                {

                    // if the parent id was removed from the account, add that parent to our list to update
                    if (acct.ParentId == null && oldAcct.ParentId != null)
                        parentAcctsToUpdate.add(oldAcct.ParentId);

                    if (acct.ParentId != null)
                        parentAcctsToUpdate.add(acct.ParentId);
                }
            }
        }

        System.debug('@@@@@ parentAcctsToUpdate ' + parentAcctsToUpdate);

        if (parentAcctsToUpdate.size() > 0) {

            // send these ids to the method that will update their rollup values
            rollupChildAcctDataToParents(parentAcctsToUpdate);
        }
    }

    //Modfied By - Abhinav Sharma - 03-10-2014 - CR-20140220-4547 - Formula should include Parent and all Child data below it
    // CR-3556 update 6 fields with rollup data.  This cannot be done via rollup fields because this is only a lookup relationship
    public static void rollupChildAcctDataToParents(set<Id> parentAcctIds) {

        // aggregate query for all fields
        list<AggregateResult> aggResults = [SELECT ParentId, SUM(At_Risk_Renewal__c)AtRiskRenewal, SUM(Fast_Track__c)FastTrackDollars,
                                            SUM(Fast_Track_Units__c)FastTrackUnits, SUM(PT_Renewal_CV__c)PTRenewalCV,
                                            SUM(RI_TD_Renewal_CV__c)RITDRenewal, SUM(Total_Contract_Value__c)TotalContractValue
                                            FROM Account WHERE ParentId IN:parentAcctIds GROUP BY ParentId];

        //Updated By - Abhinav Sharma - 03-10-2014 - CR-20140220-4547
        // get all parent institutions and update them with the
        map<Id, Account> parentAcctMap = new map<Id, Account>([SELECT Id, At_Risk_Renewal_System__c, Fast_Track_System__c,
                                                               Fast_Track_Units_System__c, PT_Renewal_CV_System__c,
                                                               RI_TD_Renewal_CV_System__c, Total_Contract_Value_System__c,
                                                               At_Risk_Renewal__c, Fast_Track__c, Fast_Track_Units__c, PT_Renewal_CV__c,
                                                               RI_TD_Renewal_CV__c, Total_Contract_Value__c
                                                               FROM Account WHERE Id IN :parentAcctIds]);

        // loop through each acct and populate the rollup data
        for (AggregateResult ar : aggResults) {

           //Commented By - Abhinav Sharma - 03-10-2014 - CR-20140220-4547 - Formula should include Parent and all Child data below it
           // get the account
           /*Account acct = parentAcctMap.get( string.valueOf( ar.get('ParentId') ) );
            acct.At_Risk_Renewal_System__c = double.valueOf( ar.get('AtRiskRenewal') );
            acct.Fast_Track_System__c = double.valueOf( ar.get('FastTrackDollars') );
            acct.Fast_Track_Units_System__c = double.valueOf( ar.get('FastTrackUnits') );
            acct.PT_Renewal_CV_System__c = double.valueOf( ar.get('PTRenewalCV') );
            acct.RI_TD_Renewal_CV_System__c = double.valueOf( ar.get('RITDRenewal') );
            acct.Total_Contract_Value_System__c = double.valueOf( ar.get('TotalContractValue') );*/

            //Added By - Abhinav Sharma - 03-10-2014 - CR-20140220-4547 - Formula should include Parent and all Child data below it
             if(ar.get('ParentId') != null && parentAcctMap.get(string.valueOf( ar.get('ParentId') ) ) != null) {

                Account acct = parentAcctMap.get( string.valueOf( ar.get('ParentId') ) );

                if(ar.get('AtRiskRenewal') != null) {
                    if(acct.At_Risk_Renewal__c != null)
                        acct.At_Risk_Renewal_System__c = double.valueOf( ar.get('AtRiskRenewal') ) + acct.At_Risk_Renewal__c;
                    else
                        acct.At_Risk_Renewal_System__c = double.valueOf( ar.get('AtRiskRenewal') );
                }

                if(ar.get('FastTrackDollars') != null) {
                    if(acct.Fast_Track__c != null)
                        acct.Fast_Track_System__c = double.valueOf( ar.get('FastTrackDollars') ) + acct.Fast_Track__c;
                    else
                        acct.Fast_Track_System__c = double.valueOf( ar.get('FastTrackDollars') );
                }

                if(ar.get('FastTrackUnits') != null) {
                    if(acct.Fast_Track_Units__c != null)
                        acct.Fast_Track_Units_System__c = double.valueOf( ar.get('FastTrackUnits') ) + acct.Fast_Track_Units__c;
                    else
                        acct.Fast_Track_Units_System__c = double.valueOf( ar.get('FastTrackUnits') );
                }

                if(ar.get('PTRenewalCV') != null) {
                    if(acct.PT_Renewal_CV__c != null)
                        acct.PT_Renewal_CV_System__c = double.valueOf( ar.get('PTRenewalCV') ) + acct.PT_Renewal_CV__c;
                    else
                        acct.PT_Renewal_CV_System__c = double.valueOf( ar.get('PTRenewalCV') );
                }

                if(ar.get('RITDRenewal') != null) {
                    if(acct.RI_TD_Renewal_CV__c != null)
                        acct.RI_TD_Renewal_CV_System__c = double.valueOf( ar.get('RITDRenewal') ) + acct.RI_TD_Renewal_CV__c;
                    else
                        acct.RI_TD_Renewal_CV_System__c = double.valueOf( ar.get('RITDRenewal') );
                }

                if(ar.get('TotalContractValue') != null) {
                    if(acct.Total_Contract_Value__c != null)
                        acct.Total_Contract_Value_System__c = double.valueOf( ar.get('TotalContractValue') ) + acct.Total_Contract_Value__c;
                    else
                        acct.Total_Contract_Value_System__c = double.valueOf( ar.get('TotalContractValue') );
                }
            }
        }

        // update values
        if (parentAcctMap.size() > 0)
            update parentAcctMap.values();
    }

    public static void RequireCommentsForAppRejection(List<Account> triggerNew) {
        // map to hold accounts with approval requests in process
        Map<Id, Account> acctMap = new Map<Id, Account>();
        for (Account acct : triggerNew) {
            if (acct.Approval_Comment_Check__c == 'Requested') {
                acctMap.put(acct.Id, acct);
                // Reset the field value to null,
                // so that the check is not repeated,
                // next time the object is updated
                acct.Approval_Comment_Check__c = null;
            }
        }

        if (!acctMap.isEmpty()) {
            // Get the last approval process step for the approval processes,
            // and check the comments.
            for (ProcessInstance pi : [SELECT TargetObjectId,
                                        (SELECT Id, StepStatus, Comments FROM Steps WHERE StepStatus = 'Rejected' ORDER BY CreatedDate DESC LIMIT 1 )
                                       FROM ProcessInstance
                                       WHERE TargetObjectId In :acctMap.keySet()
                                       AND Id IN (SELECT ProcessInstanceId FROM ProcessInstanceStep WHERE StepStatus = 'Rejected')
                                       ORDER BY CreatedDate DESC LIMIT 1])
            {
                system.debug('@@Status:' + pi.Steps[0].StepStatus + '  Comments:' + pi.Steps[0].Comments);
                // If no comment exists, then prevent the object from saving.
                if ((pi.Steps[0].Comments == null ||
                    pi.Steps[0].Comments.trim().length() == 0))
                {
                    acctMap.get(pi.TargetObjectId).addError('Please provide a reason for your rejection.');
                }
            }
        }
    }

    // begin the approval process for any institutions that are created by a user with ABC Dataloader profile
    public static void BeginVendorApproval(List<Account> accounts) {
        // return immediately if the profileId is not ABC Dataloader
        // all vendors that require approval are generated by the ABC Dataloader profile with a record size = 1
        if (UserInfo.getProfileId() != label.ABC_Dataloader_Profile_Id || accounts.size() > 1) return;

        // get the Vendor record type id
        Id vendorRTId;
        List<RecordType> recordTypes = [SELECT Id FROM RecordType WHERE SObjectType='Account' AND IsActive=true AND DeveloperName='Vendor' LIMIT 1];
        if (recordTypes.size() > 0) vendorRTId = recordTypes[0].Id;

        // check each institution to see whether it needs approval
        for (Account a : accounts) {
            system.debug('@@Vendor Approval acct:' + a.Id + '  RecordTypeId:' + a.RecordTypeId);
            // make sure the recordType is Vendor
            if (a.RecordTypeId == vendorRTId) {
                // Create an approval request for the account
                Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
                req1.setComments('Submitting request for approval.');
                req1.setObjectId(a.id);

                // Submit the approval request for the account
                Approval.ProcessResult result = Approval.process(req1);
                system.debug('@@Vendor Approval result' + result);
            }
        }
    }

    //This method is to populate the Top Parent lookup Id field with the Appropriate value
    public static void populateTopParentInstitute(List<Account> institutes) {

        //Loop through the account records and create a set of parent ids
        Set<Id> setParentIds = new Set<Id>();

        //Loop through the account records
        for(Account acc : institutes) {

            //Add parentid in set if not null
            if(acc.ParentId != null) {

                //Add in set
                setParentIds.add(acc.ParentId);
            } else {

                //Set null to parent
                acc.Top_Parent_Institution__c = null;
            }
        }

        //Check for the parent size
        if(setParentIds.size()>0) {

            //Get account data from database
            Map<Id,Account> mapAccounts = new Map<Id,Account>([SELECT Id , Top_Parent_Institution__c From Account where Id IN : setParentIds]);

            //Loop through the in context account records
            for(Account acc : institutes) {

                //Check for the ParentId
                if(acc.ParentId != null && mapAccounts.containsKey(acc.ParentId)) {

                    //Get account from map
                    Account parentAcc = mapAccounts.get(acc.ParentId);

                    //check for top parentid
                    if(parentAcc.Top_Parent_Institution__c != null)
                        acc.Top_Parent_Institution__c = parentAcc.Top_Parent_Institution__c;
                    else
                        acc.Top_Parent_Institution__c = parentAcc.Id;
                }
            }
        }
    }

    // map of account record types
    public static Map<String, Id> AccountRTMap {
        get {
            if (AccountRTMap == null) {
                AccountRTMap = new Map<String, Id>();
                AccountRTMap = Util.recordtypemap('Account');
            }
            return AccountRTMap;
        }
        set;
    }

    // populate the region based on the Account's Primary Country
    public static void populateRegion(list<Account> accounts) {

        for (Account acct : accounts) {

            string regionStr;

            // make sure primary country is not null
            if (acct.Primary_Country__c != null) {

                // see if the primary country is in our map
                if (countryToRegionMap.containsKey(acct.Primary_Country__c))
                    regionStr = countryToRegionMap.get(acct.Primary_Country__c);
                else
                    regionStr = acct.Primary_Country__c;
            }

            acct.Region__c = regionStr;
        }
    }
	
    //V_1.13 - Modified By - Mahendra Swarnkar - 07/28/2016 - CR-20160419-9779 - Updated the existing mapping
    //Modified By - Abhinav Sharma - 06/30/2016 - CR-20160419-9779 - Updated the existing mapping
    //Modified By Ajit Surana - 02/03/2015 - CR-20141216-8346 - Updated Region
    //Modified By Abhinav Sharma - 03/05/2014 - CR-20140131-4429 - Updated Region
    // map of Country -> Region
    private static map<String, String> countryToRegionMap {

        get {

            if (countryToRegionMap == null) {

                // create a new map and assign the proper values
                countryToRegionMap = new map<string, string> {
                    'Afghanistan' => 'Middle East', 'Aland Islands' => 'Europe', 'Albania' => 'Europe', 'Algeria' => 'Africa',
                    'American Samoa' => 'Australasia', 'Andorra' => 'Europe', 'Angola' => 'Africa', 'Anguilla' => 'Latin America',
                    'Antartica' => 'Antarctica', 'Antigua and Barbuda' => 'Latin America', 'Argentina' => 'Latin America',
                    'Armenia' => 'Europe', 'Aruba' => 'Latin America', 'Australia' => 'Australasia', 'Austria' => 'Europe',
                    'Azerbaijan' => 'Europe', 'Bahamas' => 'Latin America', 'Bahrain' => 'Middle East', 'Bangladesh' => 'Australasia',
                    'Barbados' => 'Latin America', 'Belarus' => 'Europe', 'Belgium' => 'Europe', 'Belize' => 'Latin America',
                    'Benin' => 'Africa', 'Bermuda' => 'Latin America', 'Bhutan' => 'Australasia', 'Bolivia' => 'Latin America',
                    'Bosnia and Herzegovina' => 'Europe', 'Botswana' => 'Africa', 'Bouvet Island' => 'Africa', 'Brazil' => 'Latin America',
                    'British Indian Ocean Territory' => 'Australasia', 'Brunei Darussalam' => 'Australasia', 'Bulgaria' => 'Europe',
                    'Burkina Faso' => 'Africa', 'Burundi' => 'Africa', 'Cambodia' => 'Australasia', 'Cameroon' => 'Africa',
                    'Canada' => 'Canada', 'Cape Verde' => 'Africa', 'Cayman Islands' => 'Latin America', 'Central African Republic' => 'Africa',
                    'Chad' => 'Africa', 'Chile' => 'Latin America', 'China' => 'Australasia', 'Christmas Island' => 'Australasia',
                    'Cocos Islands' => 'Australasia', 'Colombia' => 'Latin America', 'Comoros' => 'Africa', 'Congo' => 'Africa',
                    'Congo, The Democratic Republic of' => 'Africa', 'Cook Islands' => 'Australasia', 'Costa Rica' => 'Latin America',
                    'Cote D\'ivoire' => 'Africa', 'Croatia' => 'Europe', 'Cuba' => 'Latin America', 'Cyprus' => 'Europe',
                    'Czech Republic' => 'Europe', 'Denmark' => 'Europe', 'Djibouti' => 'Africa', 'Dominica' => 'Latin America',
                    'Dominican Republic' => 'Latin America', 'Ecuador' => 'Latin America', 'Egypt' => 'Africa', 'El Salvador' => 'Latin America',
                    'Equatorial Guinea' => 'Africa', 'Eritrea' => 'Africa', 'Estonia' => 'Europe', 'Ethiopia' => 'Africa',
                    'Falkland Islands' => 'Latin America', 'Faroe Islands' => 'Europe', 'Fiji' => 'Australasia',
                    'Finland' => 'Europe', 'France' => 'Europe', 'French Guiana' => 'Latin America', 'French Polynesia' => 'Australasia',
                    'French Southern Territories' => 'Australasia', 'Gabon' => 'Africa', 'Gambia' => 'Africa', 'Georgia' => 'Europe',
                    'Germany' => 'Europe', 'Ghana' => 'Africa', 'Gibraltar' => 'Europe', 'Greece' => 'Europe', 'Greenland' => 'Europe',
                    'Grenada' => 'Latin America', 'Guadeloupe' => 'Latin America', 'Guam' => 'Australasia', 'Guatemala' => 'Latin America',
                    'Guernsey' => 'Europe', 'Guinea' => 'Africa', 'Guinea-Bissau' => 'Africa', 'Guyana' => 'Latin America',
                    'Haiti' => 'Latin America', 'Heard Island and McDonald Island' => 'Australasia',
                    'Holy See (Vatican City State)' => 'Europe', 'Honduras' => 'Latin America', 'Hong Kong' => 'Australasia',
                    'Hungary' => 'Europe', 'Iceland' => 'Europe', 'India' => 'Middle East', 'Indonesia' => 'Australasia',
                    'Iran' => 'Middle East', 'Iraq' => 'Middle East', 'Ireland' => 'Europe', 'Isle of Man' => 'Europe',
                    'Israel' => 'Middle East', 'Italy' => 'Europe', 'Jamaica' => 'Latin America', 'Japan' => 'Australasia',
                    'Jersey' => 'Europe', 'Jordan' => 'Middle East', 'Kazakhstan' => 'Australasia', 'Kenya' => 'Africa',
                    'Kiribati' => 'Australasia', 'Korea, Democratic People\'s Republic of' => 'Australasia',
                    'Korea, Republic of Korea' => 'Australasia', 'Kuwait' => 'Middle East', 'Kyrgyzstan' => 'Australasia',
                    'Lao People\'s Democratic Republic' => 'Australasia', 'Latvia' => 'Europe', 'Lebanon' => 'Middle East',
                    'Lesotho' => 'Europe', 'Liberia' => 'Africa', 'Libyan Arab Jamahiriya' => 'Africa', 'Liechtenstein' => 'Europe',
                    'Lithuania' => 'Europe', 'Luxembourg' => 'Europe', 'Macao' => 'Australasia', 'Macedonia' => 'Europe',
                    'Madagascar' => 'Africa', 'Malawi' => 'Africa', 'Malaysia' => 'Australasia', 'Maldives' => 'Australasia',
                    'Mali' => 'Africa', 'Malta' => 'Europe', 'Marshall Islands' => 'Australasia', 'Martinique' => 'Latin America',
                    'Mauritania' => 'Africa', 'Mauritius' => 'Africa', 'Mayotte' => 'Africa', 'Mexico' => 'Latin America',
                    'Micronesia' => 'Australasia', 'Moldova' => 'Europe', 'Monaco' => 'Europe', 'Mongolia' => 'Australasia',
                    'Montenegro' => 'Europe', 'Montserrat' => 'Latin America', 'Morocco' => 'Africa', 'Mozambique' => 'Africa',
                    'Myanmar' => 'Australasia', 'Namibia' => 'Africa', 'Nauru' => 'Australasia', 'Nepal' => 'Australasia',
                    'Netherlands' => 'Europe', 'New Caledonia' => 'Australasia', 'New Zealand' => 'Australasia',
                    'Nicaragua' => 'Latin America', 'Niger' => 'Africa', 'Nigeria' => 'Africa', 'Niue' => 'Australasia',
                    'Norfolk Island' => 'Australasia', 'Northern Mariana Islands' => 'Australasia', 'Norway' => 'Europe',
                    'Oman' => 'Middle East', 'Pakistan' => 'Middle East', 'Palau' => 'Australasia',
                    'Palestinian Territory, Occupied' => 'Middle East', 'Panama' => 'Latin America', 'Papua New Guinea' => 'Australasia',
                    'Paraguay' => 'Latin America', 'Peru' => 'Latin America', 'Philippines' => 'Australasia', 'Pitcairn' => 'Australasia',
                    'Poland' => 'Europe', 'Portugal' => 'Latin America', 'Puerto Rico' => 'Latin America', 'Qatar' => 'Middle East',
                    'Republic of Panama' => 'Latin America', 'Reunion' => 'Africa', 'Romania' => 'Europe', 'Russia' => 'Australasia',
                    'Russian Federation' => 'Australasia', 'Rwanda' => 'Africa', 'Saint Barthélemy' => 'Latin America',
                    'Saint Helena' => 'Africa', 'Saint Kitt and Nevis' => 'Latin America', 'Saint Lucia' => 'Latin America',
                    'Saint Martin' => 'Latin America', 'Saint Pierre and Miquelon' => 'Canada',
                    'Saint Vincent and the Grenadines' => 'Latin America', 'Samoa' => 'Australasia', 'San Marino' => 'Europe',
                    'Sao Tome and PrincipeSenegal' => 'Africa', 'Saudi Arabia' => 'Middle East', 'Serbia' => 'Europe',
                    'Seychelles' => 'Africa', 'Sierra Leone' => 'Africa', 'Singapore' => 'Australasia', 'Slovakia' => 'Europe',
                    'Slovenia' => 'Europe', 'Solomon Islands' => 'Australasia', 'Somalia' => 'Africa', 'South Africa' => 'Africa',
                    'South Georgia and South Sandwich' => 'Latin America', 'Spain' => 'Latin America', 'Sri Lanka' => 'Australasia',
                    'Sudan' => 'Africa', 'Suriname' => 'Latin America', 'Svalbard and Jan Mayen' => 'Europe',
                    'Swaziland' => 'Africa', 'Sweden' => 'Europe', 'Switzerland' => 'Europe',
                    'Syrian Arab Republic' => 'Middle East', 'Taiwan' => 'Australasia', 'Tajikistan' => 'Australasia',
                    'Tanzania' => 'Africa', 'Thailand' => 'Australasia', 'Timor-Leste' => 'Australasia', 'Togo' => 'Africa',
                    'Tokelau' => 'Australasia', 'Tonga' => 'Australasia', 'Trinidad and Tobago' => 'Latin America', 'Tunisia' => 'Africa',
                    'Turkey' => 'Europe', 'Turkmenistan' => 'Australasia', 'Turks and Caicos' => 'Latin America', 'Tuvalu' => 'Australasia',
                    'Uganda' => 'Africa', 'Ukraine' => 'Europe', 'United Arab Emirates' => 'Middle East', 'United Kingdom' => 'UK',
                    'United States' => 'United States', 'Uruguay' => 'Latin America', 'Uzbekistan' => 'Australasia',
                    'Vanuatu' => 'Australasia', 'Venezuela' => 'Latin America', 'Viet Nam' => 'Australasia',
                    'Virgin Islands, British' => 'Latin America', 'Virgin Islands, US' => 'Latin America', 'Wallis and Futuna' => 'Australasia',
                    'Western Sahara' => 'Africa', 'Yemen' => 'Middle East', 'Zambia' => 'Africa', 'Zimbabwe' => 'Africa'
                };
            }
            return countryToRegionMap;
        }
        set;
    }

    //Added By Abhinav Sharma - CR-20140204-4441 - Restriction status not being updated properly as part of nightly batch job
    /**
     *  @description    :   This method is to delete all Restriction MtM records related to that Accounts when deleted.
     *
     *  @args           :   List of old Account records
     *
     *  @return         :   void
     *
     **/
     public static void deleteAllRestrictionMtMRecords(List<Account> deletedAccounts) {

        //List to hold the Restriction MtM records
        List<Restricted_MtM__c> restrictedMtms = [SELECT ID FROM Restricted_MtM__c WHERE Account__c != null AND Account__c IN : deletedAccounts];

        //Checking list for size value
        if(restrictedMtms != null && restrictedMtms.size() > 0)
            delete restrictedMtms;
     }

     //Added By Abhinav Sharma - 07/03/2014 - CR-20140618-5845
    /**
     *  @description    :   This method is there to update "Member Type" field on case records associated to account record according to its description field value.
     *
     *  @args           :   List of new Accounts, Map of old Account
     *
     *  @return         :   void
     *
     **/
    public static void updateChildrenCasesMemberTypeFieldValue(List<Account> newAccounts, Map<Id, Account> mapOldAccounts) {

        //Set to hold the Account Ids
        Set<Id> setAccountIds = new Set<Id>();

        //Loop through new Account records and filtering out the records for whom "Key Notes" (Description) field got changes
        for(Account acc : newAccounts) {
            if(mapOldAccounts.get(acc.Id).Description != acc.Description) {
                setAccountIds.add(acc.Id);
            }
        }

        //Map to hold the Account records
        Map<Id, Account> mapAccounts = new Map<Id, Account>([SELECT ID, Description FROM Account WHERE Id IN : setAccountIds]);

        //Map of Case records going to be updated with "Member Type" field value
        Map<Id, Case> mapCasesToBeUpdated = new Map<Id, Case>();

        //Retrieving out all the children Case object records associated to eligible account records
        for(Case cs : [SELECT Id, Member_Type__c, AccountId FROM Case WHERE AccountId IN : setAccountIds]) {

            //Checking for difference in between field values
            if(mapAccounts != null && mapAccounts.get(cs.AccountId) != null) {

                //Checking if description field value containing specified string with it or not
                if(mapAccounts.get(cs.AccountId).Description != null && mapAccounts.get(cs.AccountId).Description.contains(Constants.RIAM_LARGE_CONTRACTS)) {
                    if(cs.Member_Type__c != Constants.RIAM_LARGE_CONTRACTS) {
                        cs.Member_Type__c = Constants.RIAM_LARGE_CONTRACTS;
                        mapCasesToBeUpdated.put(cs.Id, cs);
                    }
                } else {
                    //Checking for null & blank value
                    if(!String.isBlank(cs.Member_Type__c)) {
                        cs.Member_Type__c = '';
                        mapCasesToBeUpdated.put(cs.Id, cs);
                    }
                }

            } else {

                //Checking for null & blank value
                if(!String.isBlank(cs.Member_Type__c)) {
                    cs.Member_Type__c = '';
                    mapCasesToBeUpdated.put(cs.Id, cs);
                }
            }
        }

        //Checking for size value && then performing the updates
        if(mapCasesToBeUpdated.values().size() > 0) {
            Util.BypassAllTriggers = true;
            update mapCasesToBeUpdated.values();
            Util.BypassAllTriggers = false;
        }
    }
    
    //V_1.10 - Added By - Rajeev Jain - 06/07/2016 - 
    /**
     *  @description    :   This method is used to Increase/Decrease Royall Child field counter on Parent Account, when any Royall child account insert/update/delete
     *
     *  @args           :   List of new Accounts, Map of old Account
     *
     *  @return         :   void
     *
     **/
     public static void updateRoyallChildCounter(List<Account> newAccounts, Map<Id, Account> oldAccountsMap){
     	
     	//Map to hold the Parent Account Instance with fields which needs to be update(Royall Child Counter) corrospondiing to its Id
     	Map<Id, Account> mapAccountsForUpdate = new Map<Id, Account>();
     	
     	Set<String> royallRecordTypes = new Set<String>{'Royall_Admissions_Graduate', 'Royall_Admissions_Undergraduate', 'Royall_Advancement'};
     	
     	//Loop over account Records
     	for(Account acc : newAccounts != null ? newAccounts : oldAccountsMap.values()){
     		
     		//Insert Case
     		if(oldAccountsMap == null && acc.ParentId != null)
     			mapAccountsForUpdate.put(acc.ParentId, new Account(Id = acc.ParentId, Royall_Children__c = 0));
     		
     		//Update Case
     		if(oldAccountsMap != null && newAccounts != null && 
     				((acc.ParentId != oldAccountsMap.get(acc.id).ParentId || acc.RecordTypeId != oldAccountsMap.get(acc.id).RecordTypeId)
     				|| (acc.r_Current_Year_Account_Status__c != oldAccountsMap.get(acc.id).r_Current_Year_Account_Status__c
     					&& (String.isBlank(acc.r_Current_Year_Account_Status__c) || String.isBlank(oldAccountsMap.get(acc.id).r_Current_Year_Account_Status__c)))
     				|| (acc.r_Current_Year_Status__c != oldAccountsMap.get(acc.id).r_Current_Year_Status__c
     					&& (String.isBlank(acc.r_Current_Year_Status__c) || String.isBlank(oldAccountsMap.get(acc.id).r_Current_Year_Status__c)))
     				|| (acc.r_Previous_Year_Account_Status__c != oldAccountsMap.get(acc.id).r_Previous_Year_Account_Status__c
     					&& (String.isBlank(acc.r_Previous_Year_Account_Status__c) || String.isBlank(oldAccountsMap.get(acc.id).r_Previous_Year_Account_Status__c)))
     				|| (acc.r_Previous_Year_Status__c != oldAccountsMap.get(acc.id).r_Previous_Year_Status__c
     					&& (String.isBlank(acc.r_Previous_Year_Status__c) || String.isBlank(oldAccountsMap.get(acc.id).r_Previous_Year_Status__c)))
     				|| (acc.r_Next_Year_Account_Status__c != oldAccountsMap.get(acc.id).r_Next_Year_Account_Status__c
     					&& (String.isBlank(acc.r_Next_Year_Account_Status__c) || String.isBlank(oldAccountsMap.get(acc.id).r_Next_Year_Account_Status__c)))
     				|| (acc.r_Next_Year_Status__c != oldAccountsMap.get(acc.id).r_Next_Year_Status__c
     					&& (String.isBlank(acc.r_Next_Year_Status__c) || String.isBlank(oldAccountsMap.get(acc.id).r_Next_Year_Status__c)))
     				|| (acc.r_hd_current_year_account_status__c != oldAccountsMap.get(acc.id).r_hd_current_year_account_status__c
     					&& (String.isBlank(acc.r_hd_current_year_account_status__c) || String.isBlank(oldAccountsMap.get(acc.id).r_hd_current_year_account_status__c)))
     				|| (acc.r_HD_Current_Year_Engagement_Status__c != oldAccountsMap.get(acc.id).r_HD_Current_Year_Engagement_Status__c
     					&& (String.isBlank(acc.r_HD_Current_Year_Engagement_Status__c) || String.isBlank(oldAccountsMap.get(acc.id).r_HD_Current_Year_Engagement_Status__c)))
     				|| (acc.r_HD_Next_Year_Account_Status__c != oldAccountsMap.get(acc.id).r_HD_Next_Year_Account_Status__c
     					&& (String.isBlank(acc.r_HD_Next_Year_Account_Status__c) || String.isBlank(oldAccountsMap.get(acc.id).r_HD_Next_Year_Account_Status__c)))
     				|| (acc.r_HD_Next_Year_Engagement_Status__c != oldAccountsMap.get(acc.id).r_HD_Next_Year_Engagement_Status__c
     					&& (String.isBlank(acc.r_HD_Next_Year_Engagement_Status__c) || String.isBlank(oldAccountsMap.get(acc.id).r_HD_Next_Year_Engagement_Status__c)))
     				|| (acc.r_HD_Previous_Year_Account_Status__c != oldAccountsMap.get(acc.id).r_HD_Previous_Year_Account_Status__c
     					&& (String.isBlank(acc.r_HD_Previous_Year_Account_Status__c) || String.isBlank(oldAccountsMap.get(acc.id).r_HD_Previous_Year_Account_Status__c)))
     				|| (acc.r_HD_Previous_Year_Engagement_Status__c != oldAccountsMap.get(acc.id).r_HD_Previous_Year_Engagement_Status__c
     					&& (String.isBlank(acc.r_HD_Previous_Year_Engagement_Status__c) || String.isBlank(oldAccountsMap.get(acc.id).r_HD_Previous_Year_Engagement_Status__c)))
     			)){
				
				//Add in map if new Parent Id is not null
				if(acc.ParentId != null)
					mapAccountsForUpdate.put(acc.ParentId, new Account(Id = acc.ParentId, Royall_Children__c = 0));
				
				///Add in map if Old Parent Id is not null
				if(oldAccountsMap.get(acc.id).ParentId != null)
					mapAccountsForUpdate.put(oldAccountsMap.get(acc.id).ParentId, new Account(Id = oldAccountsMap.get(acc.id).ParentId, Royall_Children__c = 0));	
			}
			
			//Delete case
			if(newAccounts == null && acc.ParentId != null)
				mapAccountsForUpdate.put(acc.ParentId, new Account(Id = acc.ParentId, Royall_Children__c = 0));		
     	}
     	
     	//Check for the size
     	if(mapAccountsForUpdate.size() > 0){
     		
     		//Query on the Child records with Aggregate Results
     		for(AggregateResult ar : [select count(Id) ct, ParentId pA 
     									from Account where ParentId IN : mapAccountsForUpdate.keySet()
     									AND RecordType.DeveloperName IN : royallRecordTypes 
     									AND (r_Current_Year_Account_Status__c != null OR 
     									r_Current_Year_Status__c != null OR r_Previous_Year_Account_Status__c != null OR
     									r_Previous_Year_Status__c != null OR r_Next_Year_Account_Status__c != null OR 
     									r_Next_Year_Status__c != null OR r_hd_current_year_account_status__c != null OR
     									r_HD_Current_Year_Engagement_Status__c != null OR r_HD_Next_Year_Account_Status__c != null OR 
     									r_HD_Next_Year_Engagement_Status__c != null OR r_HD_Previous_Year_Account_Status__c != null OR 
     									r_HD_Previous_Year_Engagement_Status__c != null) GROUP BY ParentId]){
				Id parentId = Id.valueOf(String.valueOf(ar.get('pA')));
				
				//Check if Map contains key then Set Child records
				if(mapAccountsForUpdate.containsKey(parentId))
					mapAccountsForUpdate.get(parentId).Royall_Children__c = Integer.valueOf(ar.get('ct'));		
			}
			
			//Bypass Account trigger for ReRun
			Util.BypassAllTriggers = true;
			
			//Update the map values
			update mapAccountsForUpdate.values();
			
			//Reset Flag
			Util.BypassAllTriggers = false;
     	}
     }
     
     //V_1.10 - Added By - Rajeev Jain - 06/07/2016 - 
    /**
     *  @description    :   This method handle royall specific code, which is migrated from Royall enviournment. 
     *
     *  @args           :   List of new Accounts, Map of old Account
     *
     *  @return         :   void
     *
     **/
     public static void updateRoyallAccountYearStatus(List<Account> newAccounts, Map<Id, Account> newAccountMap){
     	
     	// control trigger execution
	    if (!Test.isRunningTest() && !Account_Status_Management__c.getOrgDefaults().Enable_Update_Account_Status_Trigger__c)
	        return;
	        
	    //Calculate the current Fiscal year using shift_fical_year class
    	Integer currentFY = shift_get_fiscal_year.current();
	    
		// Map to hold the accounts  roll up status fields and Concurrent active years counter
	    Map<Id, String> theCurrentStatus = new Map<Id, String>();
	    Map<Id, String> thePastStatus = new Map<Id, String>();
	    Map<Id, String> theNextStatus = new Map<Id, String>(); 
	    
	    // Variables used to remenber previous values and keep track of concurrent active years
    	Map<Id, list<Integer>> theAccountYearMap = new Map<Id, List<Integer>>();
    	
    	for (Program_Package__c p : [Select Id, Name, Account__c, Fiscal_Year__c, Client_Status_New__c
    									from Program_Package__c
        								where Account__c in: newAccountMap.keySet()order by Account__c asc, Fiscal_Year__c asc]) {
			
			//Get the status for Previous, Current and Next Fiscal Year
            if (p.Fiscal_Year__c != null){      
                if (Integer.valueOf(p.Fiscal_Year__c) == currentFY) {
                    theCurrentStatus.put(p.Account__c, p.Client_Status_New__c);
                    //theCurrentAccountStatus.put(p.Account__c, p.R_Account_Status__c);
                }
                if (Integer.valueOf(p.Fiscal_Year__c) == currentFY+1) {
                    theNextStatus.put(p.Account__c, p.Client_Status_New__c);
                    //theNextAccountStatus.put(p.Account__c, p.R_Account_Status__c);
                }
                if (Integer.valueOf(p.Fiscal_Year__c) == currentFY-1) {
                    thePastStatus.put(p.Account__c, p.Client_Status_New__c);
                    //thePastAccountStatus.put(p.Account__c, p.R_Account_Status__c);
                }
    
                // Keep count of Concurrent active years based on Client status being Secured or Committed.
                if (p.Client_Status_New__c == 'Secured' || p.Client_Status_New__c == 'Committed') {
                    if (!theAccountYearMap.containskey(p.Account__c)) {
                        List<Integer> temp = new List<Integer>();
                        temp.add(Integer.valueOf(p.Fiscal_Year__c));
                        theAccountYearMap.put(p.Account__c, temp);
                    } else {
                        if (theAccountYearMap.get(p.Account__c).get(theAccountYearMap.get(p.Account__c).size()-1) - Integer.valueOf(p.Fiscal_Year__c) == -1) {
                            theAccountYearMap.get(p.Account__c).add(Integer.valueOf(p.Fiscal_Year__c));
                        } else {
                            theAccountYearMap.get(p.Account__c).clear();
                            theAccountYearMap.get(p.Account__c).add(Integer.valueOf(p.Fiscal_Year__c));
                        }
                    }
                }
            } 
    	}
    	
    	// Save the roll up fields on the accounts
        for (Account a : newAccounts){
        	
            //Engagement Status
            if (theCurrentStatus.get(a.Id) != null) {
                a.r_Current_Year_Status__c = theCurrentStatus.get(a.Id); 
            } else {
                a.r_Current_Year_Status__c = null;
            }    
                
            if (thePastStatus.get(a.Id) != null) {
                a.r_Previous_Year_Status__c = thePastStatus.get(a.Id); 
            } else {    
                a.r_Previous_Year_Status__c = null;
            }    

            if (theNextStatus.get(a.Id) != null) {
                a.r_Next_Year_Status__c = theNextStatus.get(a.Id); 
            } else {    
                a.r_Next_Year_Status__c = null;
            }
        }	   
     }
     
     /**
      * @Description    :   Method to Populate Solutions Flag field formula.
      *                     solutions Flag Formula Check for:-
      *                     B.1) Formula should check the Institution hierarchy to determine the highest Solution Flag 
      *                          based on the Current & Parent Accounts (ie: Current Account, Parent Account, Top Parent Account)
      *                     B.2) The Formula should display the highest Solutions Flag based on the value in 
      *                          the current and parent/top parent institution's "Solution Status" field.
      *
      * @args           :   List<Site_Issue__c>, Map<Id, Site_Issue__c> msMap
      *
      * @return         :   
      *
      * @Version        :   V1.0 - Created By - Mahendra Swarnkar - CR-20160802-10078 - 09/05/2016
    **/
    public static void populateSolutionFlagFieldOnAccount(List<Account> newAccounts, Map<Id, Account> mapOldAccounts) {
        
        //Set of eligible accounts Ids
        Set<Id> setOfEligibleAccountIds = new Set<Id>();
        
        //Set of eligible Grad parent accounts Ids which are needs to be updated on there update
        Set<Id> setOfEligibleGrandParentAccountIds = new Set<Id>();
        
        //Populate the Account ids set
        for(Account acc : newAccounts) {
            
            //Checking for Update/Insert use case
            if(
                mapOldAccounts == null
                ||
                (
                    mapOldAccounts != null
                    && 
                    (
                        acc.Solution_Adopted__c != mapOldAccounts.get(acc.Id).Solution_Adopted__c
                        || acc.Solution_Status__c != mapOldAccounts.get(acc.Id).Solution_Status__c
                        || acc.ParentId != mapOldAccounts.get(acc.Id).ParentId
                    )
                )
            ){
                setOfEligibleAccountIds.add(acc.Id);
                
                if(acc.ParentId == null) {
                    setOfEligibleGrandParentAccountIds.add(acc.Id);    
                }
            }
        }    
    
        //List to hold the Account Ids
        Set<Id> setParentAccountId = new Set<Id>();
        
        //Map to hold the Grand parent Accounts instance.
        Map<Id, Account> mapGrandParentAccounts = new Map<Id, Account>();
        
        //Checking for size value
        if(setOfEligibleAccountIds.size() > 0) {
            
            //Populate the Account ids set
            for(Account acc : [SELECT Id, ParentId, Parent.ParentId, Solution_Adopted__c, 
                                Solutions_Flag_Image_Holder__c, Solution_Status__c 
                                FROM Account 
                                WHERE Id IN : setOfEligibleAccountIds]){
                
                //Checking for the 1st level parent                    
                if(acc.ParentId != null) {
                    
                    //Populating set with the 1st level parent ID value
                    setParentAccountId.add(acc.ParentId);
                    
                    //Checking for the 2nd level parent ID value
                    if(acc.Parent.ParentId != null)
                        setParentAccountId.add(acc.Parent.ParentId);
                }
                
                //Adding the current context record instance into the set
                setParentAccountId.add(acc.Id);
                
                //populate the Grand parent map
                if(setOfEligibleGrandParentAccountIds.size () > 0 
                    && setOfEligibleGrandParentAccountIds.contains(acc.Id)
                ) {
                    mapGrandParentAccounts.put(acc.Id, acc);               
                }
            }
            
            //Checking for the size value
            if(setParentAccountId.size() > 0){
            
                //Retreving the children records along with 1st and 2nd level parents details
                Map<Id, Account> mapAccounts = new Map<Id, Account> ([Select Id, Solution_Adopted__c, 
                                                                          Solutions_Flag_Image_Holder__c, Solution_Status__c,
                                                                          ParentId, Parent.Solutions_Flag_Image_Holder__c,
                                                                          Parent.Solution_Status__c, 
                                                                          Parent.ParentId, Parent.Solution_Adopted__c,
                                                                          Parent.Parent.Solutions_Flag_Image_Holder__c,
                                                                          Parent.Parent.Solution_Status__c,
                                                                          Parent.Parent.Solution_Adopted__c
                                                                      FROM Account 
                                                                      WHERE (
                                                                                ParentId != null 
                                                                                AND 
                                                                                ParentId IN : setParentAccountId
                                                                            ) 
                                                                            OR (
                                                                                Parent.ParentId != null 
                                                                                AND 
                                                                                Parent.ParentId IN : setParentAccountId
                                                                            ) 
                                                                            OR(
                                                                                ParentId = null
                                                                                AND
                                                                                Id IN : setParentAccountId
                                                                            )
                                                                       ]);
                
                //Checking for the size value
                if(mapAccounts.values().size() > 0) {
                
                    //Map to hold the account record Id as key and List of parent records as a value
                    Map<Id, List<Account>> mapAccountIDWithListOfParents = new Map<Id, List<Account>>();
                
                    //Loop through retrieved account records
                    for(Account acc : mapAccounts.values()) {   
                        
                        //Checking for the grand parent   
                        if(acc.parentId == null) {
                            
                            if(!mapAccountIDWithListOfParents.containsKey(acc.Id))
                                mapAccountIDWithListOfParents.put(acc.Id, new List<Account>());
                        }
                        
                        
                        //Checking for the 1st level parent
                        if(acc.parentId != null) {
                            
                           if(!mapAccountIDWithListOfParents.containsKey(acc.Id))
                                mapAccountIDWithListOfParents.put(acc.Id, new List<Account>{new Account(Id = acc.parentId, 
                                                                                                        Solution_Adopted__c = acc.Parent.Solution_Adopted__c, 
                                                                                                        Solutions_Flag_Image_Holder__c = acc.Parent.Solutions_Flag_Image_Holder__c, 
                                                                                                        Solution_Status__c = acc.Parent.Solution_Status__c
                                                                                                        )});
                            else
                                mapAccountIDWithListOfParents.get(acc.Id).add(new Account(Id = acc.parentId, 
                                                                                          Solution_Adopted__c = acc.Parent.Solution_Adopted__c, 
                                                                                          Solutions_Flag_Image_Holder__c = acc.Parent.Solutions_Flag_Image_Holder__c, 
                                                                                          Solution_Status__c = acc.Parent.Solution_Status__c));
                        }
                        
                        //Checking for the 2nd level of parent   
                        if(acc.parentId != null && acc.parent.parentId != null) {
                            
                            if(!mapAccountIDWithListOfParents.containsKey(acc.Id))
                                mapAccountIDWithListOfParents.put(acc.Id, new List<Account>{new Account(Id = acc.parentId, 
                                                                                                        Solution_Adopted__c = acc.Parent.Solution_Adopted__c, 
                                                                                                        Solutions_Flag_Image_Holder__c = acc.Parent.Solutions_Flag_Image_Holder__c, 
                                                                                                        Solution_Status__c = acc.Parent.Solution_Status__c)});
                            else
                                mapAccountIDWithListOfParents.get(acc.Id).add(new Account(Id = acc.Parent.parentId, 
                                                                                         Solution_Adopted__c = acc.Parent.Parent.Solution_Adopted__c, 
                                                                                         Solutions_Flag_Image_Holder__c = acc.Parent.Parent.Solutions_Flag_Image_Holder__c, 
                                                                                         Solution_Status__c = acc.Parent.Parent.Solution_Status__c));
                        }          
                    }
                    
                    //Checking for size and null value
                    if(mapAccountIDWithListOfParents.size() > 0
                        && mapAccountIDWithListOfParents.keySet() != null
                        && mapAccountIDWithListOfParents.keySet().size() > 0
                    ) {
                        
                        //Map of Solution Status with precedence order
                        Map<String, Integer> mapSolutionStatusValueWithOrder = new Map<String, Integer>();
                        mapSolutionStatusValueWithOrder.put('Active', 2);
                        mapSolutionStatusValueWithOrder.put('Former', 1);
                        mapSolutionStatusValueWithOrder.put('blank', 0);
                        
                        //Map to hold the child account ID as key and corresponding "highest" solution status value 
                        //amongs all the parents as value
                        Map<Id, String> mapOfAccIdWithOverallHighestSolutionStatus = new Map<Id, String>();
                        
                        //Loop through children records Ids (of 1st level children or 2nd level children)
                        //For ex:- A1 and A2   
                        for(Id childAccId : mapAccountIDWithListOfParents.keySet()){
                            
                            //For the Case of Grand parent update case
                            if(mapAccountIDWithListOfParents.get(childAccId) != null && mapAccountIDWithListOfParents.get(childAccId).size() == 0 ){
                                
                                //Check for conditions and then determine accordingly for Active, former, [Blank] Image type
                                if(mapAccounts.containsKey(childAccId)
                                   	&& mapAccounts.get(childAccId) != null
                                    && mapAccounts.get(childAccId).ParentId == null
                                   	&& mapAccounts.get(childAccId).Solution_Adopted__c != null
                                ) {   
                                    //Check for the status
                                    if(
                                        mapAccounts.get(childAccId).Solution_Status__c == 'Active'
                                       	|| mapAccounts.get(childAccId).Solution_Status__c == 'Former'
                                    ){
                                        mapOfAccIdWithOverallHighestSolutionStatus.put(childAccId, mapAccounts.get(childAccId).Solution_Status__c.trim());
                                    }else{
                                        mapOfAccIdWithOverallHighestSolutionStatus.put(childAccId, 'blank');
                                    }
                                }
                                else
                                    mapOfAccIdWithOverallHighestSolutionStatus.put(childAccId, 'blank');
                            }
                            
                            //loop through associated parent IDs
                            //For ex:- (A2->A3), (A1 --> (A2, A3))
                            for(Account parentAcc : mapAccountIDWithListOfParents.get(childAccId)) {
                                
                                //Checking for the blank/null value for the "Solution Status" field
                                if(String.isNotBlank(parentAcc.Solution_Status__c)) {
                                    
                                    //Checking for the presence of child record Id as key in the map
                                    if(!mapOfAccIdWithOverallHighestSolutionStatus.containsKey(childAccId))
                                        mapOfAccIdWithOverallHighestSolutionStatus.put(childAccId, parentAcc.Solution_Status__c.trim());
                                    else {
                                        if(mapOfAccIdWithOverallHighestSolutionStatus.get(childAccId) != null
                                          &&
                                          mapSolutionStatusValueWithOrder.containsKey(mapOfAccIdWithOverallHighestSolutionStatus.get(childAccId))
                                          &&
                                          mapSolutionStatusValueWithOrder.get(mapOfAccIdWithOverallHighestSolutionStatus.get(childAccId)) != null
                                          &&
                                          mapSolutionStatusValueWithOrder.containsKey(parentAcc.Solution_Status__c.trim())
                                          &&
                                          mapSolutionStatusValueWithOrder.get(parentAcc.Solution_Status__c.trim()) != null
                                        ) {
                                            if(mapSolutionStatusValueWithOrder.get(mapOfAccIdWithOverallHighestSolutionStatus.get(childAccId)) < mapSolutionStatusValueWithOrder.get(parentAcc.Solution_Status__c.trim()))
                                                mapOfAccIdWithOverallHighestSolutionStatus.put(childAccId, parentAcc.Solution_Status__c.trim());
                                        }
                                    }
                                } else {
                                    if(!mapOfAccIdWithOverallHighestSolutionStatus.containsKey(childAccId))
                                        mapOfAccIdWithOverallHighestSolutionStatus.put(childAccId, 'blank');
                                }
                            }    
                        }
                        
                        //Checking for map size and null value
                        if(mapOfAccIdWithOverallHighestSolutionStatus.values() != null
                            && mapOfAccIdWithOverallHighestSolutionStatus.values().size() > 0) {
                            
                            //Loop through children records Ids (of 1st level children or 2nd level children)
                            //For ex:- A1 and A2   
                            for(Id chAccId : mapAccountIDWithListOfParents.keySet()) {
                                
                                //Checking for key presence in the map
                                if(mapOfAccIdWithOverallHighestSolutionStatus.containsKey(chAccId)
                                  &&
                                  mapOfAccIdWithOverallHighestSolutionStatus.get(chAccId) != null
                                ) {
                                    //Checking for key and value in map
                                    if(mapAccounts.containsKey(chAccId)
                                      && mapAccounts.get(chAccId) != null
                                      && String.isNotBlank(mapAccounts.get(chAccId).Solution_Status__c)
                                      && mapSolutionStatusValueWithOrder.containsKey(mapAccounts.get(chAccId).Solution_Status__c.trim())
                                      && mapSolutionStatusValueWithOrder.get(mapAccounts.get(chAccId).Solution_Status__c.trim()) != null
                                    ) {
                                        
                                        //Child is having highest value
                                        if(mapSolutionStatusValueWithOrder.get(mapOfAccIdWithOverallHighestSolutionStatus.get(chAccId)) < mapSolutionStatusValueWithOrder.get(mapAccounts.get(chAccId).Solution_Status__c.trim()))
                                            mapOfAccIdWithOverallHighestSolutionStatus.put(chAccId, mapAccounts.get(chAccId).Solution_Status__c.trim());
                                    }                                                          
                                }
                            }        
                                
							//Map of account records to be updated
                            Map<Id, Account> mapOfAccountsToBeUpdated = new Map<Id, Account>();
                              
                            if(mapOfAccIdWithOverallHighestSolutionStatus.keySet() != null
                                && mapOfAccIdWithOverallHighestSolutionStatus.keySet().size() > 0
                            ) {
                                
                                //Loop through map keys
                                for(Id cId : mapOfAccIdWithOverallHighestSolutionStatus.keySet()) {
                                    if(mapOfAccIdWithOverallHighestSolutionStatus.get(cId) == 'blank')
                                        mapOfAccountsToBeUpdated.put(cId, new Account(Id = cId, Solutions_Flag_Image_Holder__c = null));
                                    else
                                        mapOfAccountsToBeUpdated.put(cId, new Account(Id = cId, Solutions_Flag_Image_Holder__c = mapOfAccIdWithOverallHighestSolutionStatus.get(cId)));
                                }
                            }
                          
                            //Checking map for the size value
                            if(mapOfAccountsToBeUpdated.values() != null
                                && mapOfAccountsToBeUpdated.values().size() > 0) {
                                
                                //Bypassing all the triggers
                                Util.byPassAllTriggers = true;
                                    
                                //Update accounts
                                update mapOfAccountsToBeUpdated.values();
                                    
                                //Enabling triggers again
                                Util.BypassAllTriggers = false;    
                            }    
                        }
                    }        
                }
            }
        }
    }
}