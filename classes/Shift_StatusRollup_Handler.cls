/* 
* Name          : Shift_StatusRollup_Handler
* Author        : Shift CRM
* Description   : Calculates program package account status based on previous fiscal year.
*          Calculates engagement status and account status rollups on account.
*
* Maintenance History: 
* Date ------------  Name  ----  Version ---  Remarks 
* 07/14/2014       Hermes      1.0         Initial
* 07/18/2014       Hermes      1.1         Refactor status logic
* 06/16/2016     Rajeev     1.2      SFDC Roayall Schema Release - Manauly migrated code from Royall Enviournment to Corporate Instance - 
* 09/20/2016        Subhash     1.3         CR-20160817-10134 
*/

public without sharing class Shift_StatusRollup_Handler {
  
    //constants
    public static final String  EXISTING_CLIENT = 'Existing Client';
  public static final String  NEW_CLIENT = 'New Client';
  public static final String  STATUS_COMMITTED = 'Committed';
  public static final String  STATUS_SECURED = 'Secured';
  public static final String  STATUS_LOST = 'Lost';
    
    //bypass variable to ensure we don't get in to a recursive update situation
    public static boolean bypassSetAcctStatus {
        get {
            if (bypassSetAcctStatus == null) bypassSetAcctStatus = false;
            return bypassSetAcctStatus;
        }
        set;
    }
    
    /**
     * 
     * @description: Update the Account Status field to either "New Customer" or "Existing Customer" 
     *         based on whether or not there was a program package for the previous year where Engagement Status != "Lost".
     * 
     **/
    public static void setAccountStatus(list<Program_Package__c> ppList) {
        
        if (bypassSetAcctStatus) return;
        bypassSetAcctStatus = true;
        
        set<Id> ppIds = new set<Id>();
        set<Id> accountIds = new set<Id>();
        list<Program_Package__c> ppToUpdate = new list<Program_Package__c>();
        map<string, Program_Package__c> FYToPPMap = new map<string, Program_Package__c>();
        
        for (Program_Package__c pp : ppList) {
            accountIds.add(pp.Account__c);
            ppIds.add(pp.Id);
            if (pp.Client_Status_New__c != STATUS_LOST)
                FYToPPMap.put(pp.Account__c + '-' + integer.valueOf(pp.Fiscal_Year__c), pp);
        }
        
        list<Account> accountsToUpdate = new list<Account>();
        
        list<Account> accounts = [SELECT Id,
                                  (SELECT Id, Fiscal_Year__c, FY_Date__c, Account__c, Account_Status__c, Client_Status_New__c
                                   FROM Program_Packages__r 
                                   WHERE Client_Status_New__c != :STATUS_LOST AND Fiscal_Year__c != null AND ID NOT IN :ppIds)
                                  FROM Account 
                                  WHERE Id IN :accountIds];
        
        
        for (Account a : accounts) {
            for (Program_Package__c pp : a.Program_Packages__r) FYToPPMap.put(pp.Account__c + '-' + integer.valueOf(pp.Fiscal_Year__c), pp);
        }
        
        //see which pp records need to be updated
        for (Account a : accounts) {
            ppToUpdate = getPPToUpdate(a.Program_Packages__r, FYToPPMap, ppToUpdate);
        }
        
        
        getPPToUpdate(ppList, FYToPPMap, new list<Program_Package__c>());
        
        if (ppToUpdate.size() > 0) update ppToUpdate;
    }
    
    /**
     * 
     * @description: Update the Account Status field to either "New Client" or "Existing Client"
     * 
     * @return value: list of program packages with the account status field updated
     * 
     **/
    private static list<Program_Package__c> getPPToUpdate(list<Program_Package__c> ppList, map<string, Program_Package__c> FYToPPMap, list<Program_Package__c> ppUpdateList) {
        for (Program_Package__c pp : ppList) {

            if (FYToPPMap.containsKey(pp.Account__c + '-' + (integer.valueOf(pp.Fiscal_Year__c)-1))) {
                Program_Package__c prevYearPP = FYToPPMap.get(pp.Account__c + '-' + (integer.valueOf(pp.Fiscal_Year__c)-1));
                if (prevYearPP.Client_Status_New__c != null) {
                    if (pp.Account_Status__c != EXISTING_CLIENT && pp.Client_Status_New__c != null) {
                        pp.Account_Status__c = EXISTING_CLIENT;
                        ppUpdateList.add(pp);
                    }
                    else if (pp.Client_Status_New__c == null) {
                        pp.Account_Status__c = null;
                        ppUpdateList.add(pp);
                    }
                }
                else if (pp.Client_Status_New__c != null) {
                    pp.Account_Status__c = NEW_CLIENT;
                    ppUpdateList.add(pp);
                }
                else {
                    pp.Account_Status__c = null;
                    ppUpdateList.add(pp);
                }
            }
            else if (pp.Account_Status__c != NEW_CLIENT && pp.Client_Status_New__c != null) {
                pp.Account_Status__c = NEW_CLIENT;
                ppUpdateList.add(pp);
            }
            else if (pp.Account_Status__c == NEW_CLIENT || pp.Account_Status__c == EXISTING_CLIENT) {
                if (pp.Client_Status_New__c == null) {
                    pp.Account_Status__c = null;
                    ppUpdateList.add(pp);
                }
            }
            else {
                pp.Account_Status__c = null;
                ppUpdateList.add(pp);
            }
        }
        
        return ppUpdateList;
    }
    
    /**
     * 
     * @description: Update the Account Status field to either "New Customer" or "Existing Customer" 
     *         based on whether or not there was a program package for the previous year where Engagement Status != "Lost".
     * 
     **/
    public static void setAccountStatus(list<Program_Package_Hardwick_Day__c> ppList) {
        
        if (bypassSetAcctStatus) return;
        bypassSetAcctStatus = true;
        
        set<Id> ppIds = new set<Id>();
        set<Id> accountIds = new set<Id>();
        list<Program_Package_Hardwick_Day__c> ppToUpdate = new list<Program_Package_Hardwick_Day__c>();
        map<string, Program_Package_Hardwick_Day__c> FYToPPMap = new map<string, Program_Package_Hardwick_Day__c>();
        
        for (Program_Package_Hardwick_Day__c pp : ppList) {
            accountIds.add(pp.Account__c);
            ppIds.add(pp.Id);
            if (pp.Client_Engagement_Status_HD__c != STATUS_LOST)
                FYToPPMap.put(pp.Account__c + '-' + integer.valueOf(pp.Fiscal_Year_HD__c), pp);
        }
        
        list<Account> accountsToUpdate = new list<Account>();
        
        list<Account> accounts = [SELECT Id,
                                  (SELECT Id, Fiscal_Year_HD__c, FY_Date_HD__c, Account__c, HD_Account_Status__c, Client_Engagement_Status_HD__c
                                   FROM HD_Program_Packages__r 
                                   WHERE Client_Engagement_Status_HD__c != :STATUS_LOST AND Fiscal_Year_HD__c != null AND ID NOT IN :ppIds)
                                  FROM Account 
                                  WHERE Id IN :accountIds];
        
        
        for (Account a : accounts) {
            for (Program_Package_Hardwick_Day__c pp : a.HD_Program_Packages__r) FYToPPMap.put(pp.Account__c + '-' + integer.valueOf(pp.Fiscal_Year_HD__c), pp);
        }
        
        //see which pp records need to be updated
        for (Account a : accounts) {
            ppToUpdate = getPPToUpdate(a.HD_Program_Packages__r, FYToPPMap, ppToUpdate);
        }
        
        
        getPPToUpdate(ppList, FYToPPMap, new list<Program_Package_Hardwick_Day__c>());
        
        if (ppToUpdate.size() > 0) update ppToUpdate;
    }
    
    /**
     * 
     * @description: Update the Account Status field to either "New Client" or "Existing Client"
     * 
     * @return value: list of program packages with the account status field updated
     * 
     **/
    private static list<Program_Package_Hardwick_Day__c> getPPToUpdate(list<Program_Package_Hardwick_Day__c> ppList, map<string, Program_Package_Hardwick_Day__c> FYToPPMap, list<Program_Package_Hardwick_Day__c> ppUpdateList) {
        for (Program_Package_Hardwick_Day__c pp : ppList) {

            if (FYToPPMap.containsKey(pp.Account__c + '-' + (integer.valueOf(pp.Fiscal_Year_HD__c)-1))) {
                Program_Package_Hardwick_Day__c prevYearPP = FYToPPMap.get(pp.Account__c + '-' + (integer.valueOf(pp.Fiscal_Year_HD__c)-1));
                if (prevYearPP.Client_Engagement_Status_HD__c != null) {
                    if (pp.HD_Account_Status__c != EXISTING_CLIENT && pp.Client_Engagement_Status_HD__c != null) {
                        pp.HD_Account_Status__c = EXISTING_CLIENT;
                        ppUpdateList.add(pp);
                    }
                    else if (pp.Client_Engagement_Status_HD__c  == null) {
                        pp.HD_Account_Status__c = null;
                        ppUpdateList.add(pp);
                    }
                }
                else if (pp.Client_Engagement_Status_HD__c != null) {
                    pp.HD_Account_Status__c = NEW_CLIENT;
                    ppUpdateList.add(pp);
                }
                else {
                    pp.HD_Account_Status__c = null;
                    ppUpdateList.add(pp);
                }
            }
            else if (pp.HD_Account_Status__c != NEW_CLIENT && pp.Client_Engagement_Status_HD__c != null) {
                pp.HD_Account_Status__c = NEW_CLIENT;
                ppUpdateList.add(pp);
            }
            else if (pp.HD_Account_Status__c == NEW_CLIENT || pp.HD_Account_Status__c == EXISTING_CLIENT) {
                if (pp.Client_Engagement_Status_HD__c == null) {
                    pp.HD_Account_Status__c = null;
                    ppUpdateList.add(pp);
                }
            }
            else {
                pp.HD_Account_Status__c = null;
                ppUpdateList.add(pp);
            }
        }
        
        return ppUpdateList;
    }
    
    //Commented - 9/20/2016 - Subhash Garhwal - CR-20160817-10134
    /**************************************************
    Program_Package_Hardwick_Day__c - Trigger Handlers
    ***************************************************/
    /*public static void OnAfterUpdate(List<Program_Package_Hardwick_Day__c> updatedPP) {
        OnAfterInsert(updatedPP);
    }

  public static void OnAfterInsert(List<Program_Package_Hardwick_Day__c> newPP) {
    // Find the program packages that Fiscal Year or Client Status changed and save the account Id
        set<Id> accountId_set = new set<Id>();
        for (Program_Package_Hardwick_Day__c pphd : newPP) {
            accountId_set.add(pphd.Account__c);
        }

        if (!system.isFuture() && !system.isScheduled() && !system.isBatch() && !accountId_set.isEmpty()) 
          asyncStatusRollupHDUpdate(accountId_set);
  }

  public static void OnAfterDelete(List<Program_Package_Hardwick_Day__c> deletedPP) {
    OnAfterInsert(deletedPP);
  }

    public static void OnUndelete(List<Program_Package_Hardwick_Day__c> undeletedPP) {
        OnAfterInsert(undeletedPP);
    } */
    
    //Commented - 9/20/2016 - Subhash Garhwal - CR-20160817-10134
    /**************************************************
    Program_Package__c - Trigger Handlers
    **************************************************/
    /*public static void OnAfterUpdate(List<Program_Package__c> updatedPP) {
        OnAfterInsert(updatedPP);
    }

  public static void OnAfterInsert(List<Program_Package__c> newPP) {
    // Find the program packages that Fiscal Year or Client Status changed and save the account Id
        set<Id> accountId_set = new set<Id>();
        for (Program_Package__c pphd : newPP) {
            accountId_set.add(pphd.Account__c);
        }

        if (!system.isFuture() && !system.isScheduled() && !system.isBatch() && !accountId_set.isEmpty()) 
          asyncStatusRollupUpdate(accountId_set);
  }

  public static void OnAfterDelete(List<Program_Package__c> deletedPP) {
    OnAfterInsert(deletedPP);
  }

    public static void OnUndelete(List<Program_Package__c> undeletedPP) {
        OnAfterInsert(undeletedPP);
    } */

    /**************************************************
                    ASYNC METHODS
        -update program package account status
        -force update account rollups
    **************************************************/
    //Commented - 9/20/2016 - Subhash Garhwal - CR-20160817-10134
    /*public static void asyncStatusRollupHDUpdate(set<id> accountId_set) {
        //updateProgramPackageHDAccountStatus(accountId_set);
        updateAccountRollups(accountId_set, true);
    } */

    /*public static void asyncStatusRollupUpdate(set<id> accountId_set) {
        //updateProgramPackageAccountStatus(accountId_set);
        updateAccountRollups(accountId_set, false);
    }*/

    //Update Account Rollups
    /*public static void updateAccountRollups(set<id> accountId_set, boolean updateHD) {

        //Calculate the current Fiscal year using shift_fical_year class
        integer currentFY = shift_get_fiscal_year.current();
        
        List<Account> accountList = new List<Account> ([SELECT Id, r_r_HD_Next_Year_Account_Status__c, r_r_hd_current_year_account_status__c, r_r_HD_Previous_Year_Account_Status__c,
                                                                r_r_HD_Next_Year_Engagement_Status__c, r_r_HD_Current_Year_Engagement_Status__c, r_r_HD_Previous_Year_Engagement_Status__c,
                                                                r_Next_Year_Account_Status__c, r_Previous_Year_Account_Status__c, r_Current_Year_Account_Status__c,
                                                                r_r_Next_Year_Status__c, r_r_Previous_Year_Status__c, r_r_Current_Year_Status__c
                                                            FROM Account 
                                                            WHERE Id IN:accountId_set]);
        //Calculate Program Package HD Rollups
        if(updateHD) {
            updateHDrollups(accountList, accountId_set, currentFY);
        }
        //Calculate Program Package Rollups
        else {
            updateRollups(accountList, accountId_set, currentFY);
        }

        //Update Rollup Fields
        update accountList;
    }*/
    
    //Commented - 9/20/2016 - Subhash Garhwal - CR-20160817-10134
    //Calculate program package rollups
    /*public static void updateRollups(List<Account> accountList, set<id> accountId_set, integer currentFY) {
        //Map of Program Packages for the new account   
        list<Program_Package__c> theProgPackList = new list<Program_Package__c>([
                        Select Id, Name, Account__c, Fiscal_Year__c, Client_Status_New__c,Account_Status__c  
                        from Program_Package__c
                        where Account__c in: accountId_set
                            order by Account__c asc, Fiscal_Year__c asc]);   
        
        // Map to hold the accounts  roll up status fields and Concurrent active years counter
        map<Id, string> theCurrentStatus = new map<Id, string>();
        map<Id, string> thePastStatus = new map<Id, string>();
        map<Id, string> theNextStatus = new map<Id, string>();    
        map<Id, string> theCurrentAccountStatus = new map<Id, string>();
        map<Id, string> thePastAccountStatus = new map<Id, string>();
        map<Id, string> theNextAccountStatus = new map<Id, string>();   

      // Variables used to remenber previous values and keep track of concurrent active years
      map<Id, list<integer>> theAccountYearMap = new map<Id, list<integer>>();
 
        for (Program_Package__c p : theProgPackList) {
        
            //Get the status for Previous, Current and Next Fiscal Year
            if (p.Fiscal_Year__c != null){      
                if (integer.valueOf(p.Fiscal_Year__c) == currentFY) {
                    theCurrentStatus.put(p.Account__c, p.Client_Status_New__c);
                    theCurrentAccountStatus.put(p.Account__c, p.Account_Status__c );
                }
                if (integer.valueOf(p.Fiscal_Year__c) == currentFY+1) {
                    theNextStatus.put(p.Account__c, p.Client_Status_New__c);
                    theNextAccountStatus.put(p.Account__c, p.Account_Status__c );
                }
                if (integer.valueOf(p.Fiscal_Year__c) == currentFY-1) {
                    thePastStatus.put(p.Account__c, p.Client_Status_New__c);
                    thePastAccountStatus.put(p.Account__c, p.Account_Status__c );
                }
            } 
        }
        
        // Save the roll up fields on the accounts
        for (Account a : accountList){
            //Engagement Status
            if (theCurrentStatus.get(a.Id) != null) {
                a.r_r_Current_Year_Status__c = theCurrentStatus.get(a.Id); 
            } else {
                a.r_r_Current_Year_Status__c = null;
            }    
                
            if (thePastStatus.get(a.Id) != null) {
                a.r_r_Previous_Year_Status__c = thePastStatus.get(a.Id); 
            } else {    
                a.r_r_Previous_Year_Status__c = null;
            }    

            if (theNextStatus.get(a.Id) != null) {
                a.r_r_Next_Year_Status__c = theNextStatus.get(a.Id); 
            } else {    
                a.r_r_Next_Year_Status__c = null;
            }

            //1.3 Account Status
            if (theCurrentAccountStatus.get(a.Id) != null) {
                a.r_Current_Year_Account_Status__c = theCurrentAccountStatus.get(a.Id); 
            } else {
                a.r_Current_Year_Account_Status__c = null;
            }    
                
            if (thePastAccountStatus.get(a.Id) != null) {
                a.r_Previous_Year_Account_Status__c = thePastAccountStatus.get(a.Id); 
            } else {    
                a.r_Previous_Year_Account_Status__c = null;
            }    

            if (theNextAccountStatus.get(a.Id) != null) {
                a.r_Next_Year_Account_Status__c = theNextAccountStatus.get(a.Id); 
            } else {    
                a.r_Next_Year_Account_Status__c = null;
            }
        }   
    }
    */
    //Commented - 9/20/2016 - Subhash Garhwal - CR-20160817-10134
    //Calculate program package HD rollups
    /*public static void updateHDrollups(List<Account> accountList, set<id> accountId_set, integer currentFY) {
        //Map of Program Packages for the new account   
        list<Program_Package_Hardwick_Day__c> theProgPackList = new list<Program_Package_Hardwick_Day__c>([
                Select Id, Account__c, Fiscal_Year_HD__c, Client_Engagement_Status_HD__c, HD_Account_Status__c 
                    from Program_Package_Hardwick_Day__c
                    where Account__c in: accountId_set
                    order by Account__c asc, Fiscal_Year_HD__c asc]);   

      // Engagement Status Maps
      map<Id, string> thePastStatus = new map<Id, string>();
      map<Id, string> theCurrentStatus = new map<Id, string>();
      map<Id, string> theNextStatus = new map<Id, string>();    

      //Account Status Maps
      map<Id, string> thePastAccountStatus = new map<Id, string>();
      map<Id, string> theCurrentAccountStatus = new map<Id, string>();
      map<Id, string> theNextAccountStatus = new map<Id, string>();  

      //Concurrent Years
      map<Id, list<integer>> theAccountYearMap = new map<Id, list<integer>>();

        for (Program_Package_Hardwick_Day__c p : theProgPackList) {        
            //Get the status for Previous, Current and Next Fiscal Year
            if (p.Fiscal_Year_HD__c != null){      
                                
                if (integer.valueOf(p.Fiscal_Year_HD__c) == currentFY-1) {
                  thePastStatus.put(p.Account__c, p.Client_Engagement_Status_HD__c);
                  thePastAccountStatus.put(p.Account__c, p.HD_Account_Status__c);
                }

              if (integer.valueOf(p.Fiscal_Year_HD__c) == currentFY) {
                  theCurrentStatus.put(p.Account__c, p.Client_Engagement_Status_HD__c);
                  theCurrentAccountStatus.put(p.Account__c, p.HD_Account_Status__c);
              }

              if (integer.valueOf(p.Fiscal_Year_HD__c) == currentFY+1) {
                  theNextStatus.put(p.Account__c, p.Client_Engagement_Status_HD__c);
                  theNextAccountStatus.put(p.Account__c, p.HD_Account_Status__c);
              }
            } 
        }        

        // Save the roll up fields on the accounts
        for (Account a : accountList){
            //Engagement Status
            if (thePastStatus.containsKey(a.Id))
                a.r_r_HD_Previous_Year_Engagement_Status__c = thePastStatus.get(a.Id); 
            else   
                a.r_r_HD_Previous_Year_Engagement_Status__c = null;

            if (theCurrentStatus.containsKey(a.Id))
                a.r_r_HD_Current_Year_Engagement_Status__c = theCurrentStatus.get(a.Id); 
            else
                a.r_r_HD_Current_Year_Engagement_Status__c = null;  

            if (theNextStatus.containsKey(a.Id)) 
                a.r_r_HD_Next_Year_Engagement_Status__c = theNextStatus.get(a.Id);            
            else 
                a.r_r_HD_Next_Year_Engagement_Status__c = null;

            //Account Status
            if (thePastAccountStatus.containsKey(a.Id))
                a.r_r_HD_Previous_Year_Account_Status__c = thePastAccountStatus.get(a.Id); 
            else   
                a.r_r_HD_Previous_Year_Account_Status__c = null;

            if (theCurrentAccountStatus.containsKey(a.Id))
                a.r_r_hd_current_year_account_status__c = theCurrentAccountStatus.get(a.Id); 
            else
                a.r_r_hd_current_year_account_status__c = null;  

            if (theNextAccountStatus.containsKey(a.Id)) 
                a.r_r_HD_Next_Year_Account_Status__c = theNextAccountStatus.get(a.Id);            
            else 
                a.r_r_HD_Next_Year_Account_Status__c = null;
        }
    } */
    
    /**
     *  @description        :   Method is used to call when need to Program Package Rollups Account's fields
     *
     *  @args               :   List<Program_Package__c> newProgPacks, Map<Id,Program_Package__c> oldMapProgPack
     *
     *  @return             :   Void
     *
     *  @revision Logs      :   V_1.1 - Created - 07/11/2016 - Subhash Garhwal
     *
     **/
    public static void accountRollupsRoyal(List<Program_Package__c> newProgPacks, Map<Id,Program_Package__c> oldMapProgPack) {
        
        //Check for Not Schedule, Not Batch, Not Future
        if (!system.isFuture() && !system.isScheduled() && !system.isBatch()) { 
            
            //Calculate the current Fiscal year using shift_fical_year class
            Integer currentFY = shift_get_fiscal_year.current();
            
            //Map to hold Account Id with Accounts
            Map<Id, Account> mapAccountToBeUpdated = new Map<Id, Account>();
        
            //Loop over new List of Program packages
            for(Program_Package__c pp : newProgPacks != null ? newProgPacks : oldMapProgPack.values()) {
                    
                    //Insert case
                    if(newProgPacks != null && oldMapProgPack == null && pp.Account__c != null)
                        mapAccountToBeUpdated.put(pp.Account__c, new Account(Id = pp.Account__c, r_Current_Year_Status__c = null, r_Previous_Year_Status__c = null,
                                                                     r_Next_Year_Status__c = null, r_Current_Year_Account_Status__c = null,
                                                                     r_Previous_Year_Account_Status__c = null, r_Next_Year_Account_Status__c = null));
                        
                    //Update Case
                    if(newProgPacks != null && oldMapProgPack != null && (pp.Fiscal_Year__c != oldMapProgPack.get(pp.Id).Fiscal_Year__c 
                       || pp.Client_Status_New__c != oldMapProgPack.get(pp.Id).Client_Status_New__c 
                       || pp.Account_Status__c != oldMapProgPack.get(pp.Id).Account_Status__c
                       || pp.Account__c != oldMapProgPack.get(pp.Id).Account__c)) {
                        
                        //Check for Account
                        if(pp.Account__c != null)
                            mapAccountToBeUpdated.put(pp.Account__c, new Account(Id = pp.Account__c, r_Current_Year_Status__c = null, r_Previous_Year_Status__c = null,
                                                                     r_Next_Year_Status__c = null, r_Current_Year_Account_Status__c = null,
                                                                     r_Previous_Year_Account_Status__c = null, r_Next_Year_Account_Status__c = null));
                        
                        //Check for Old Account
                        if(oldMapProgPack.get(pp.Id).Account__c != null)
                            mapAccountToBeUpdated.put(oldMapProgPack.get(pp.Id).Account__c, new Account(Id = oldMapProgPack.get(pp.Id).Account__c, r_Current_Year_Status__c = null, r_Previous_Year_Status__c = null,
                                                                     r_Next_Year_Status__c = null, r_Current_Year_Account_Status__c = null,
                                                                     r_Previous_Year_Account_Status__c = null, r_Next_Year_Account_Status__c = null));
                    }
                    
                    //Delete Case
                    if(newProgPacks == null && pp.Account__c != null)
                        mapAccountToBeUpdated.put(pp.Account__c, new Account(Id = pp.Account__c, r_Current_Year_Status__c = null, r_Previous_Year_Status__c = null,
                                                                     r_Next_Year_Status__c = null, r_Current_Year_Account_Status__c = null,
                                                                     r_Previous_Year_Account_Status__c = null, r_Next_Year_Account_Status__c = null));

            }
            
            //Check for account size and Ids
            if(mapAccountToBeUpdated.size() > 0) {
        
                //Loop over List of Program Packages
                for(Program_Package__c p : [Select Id, Name, Account__c, Fiscal_Year__c, Client_Status_New__c, Account_Status__c
                                                                   From Program_Package__c Where Account__c IN : mapAccountToBeUpdated.keySet() AND Fiscal_Year__c != null 
                                                                        ORDER BY Account__c ASC, Fiscal_Year__c ASC]) {
                    
                    //Check if map conatins Account Id realted to progaram packages
                    if(mapAccountToBeUpdated.containsKey(p.Account__c)) {
                        
                        //Check if Fiscal year equals to Current Fiscal year    
                        if (Integer.valueOf(p.Fiscal_Year__c) == currentFY) {
                            
                            //Populated Account'S field Current Year Status and Current Year Account Status by PP fields
                            mapAccountToBeUpdated.get(p.Account__c).r_Current_Year_Status__c = p.Client_Status_New__c;
                            mapAccountToBeUpdated.get(p.Account__c).r_Current_Year_Account_Status__c = p.Account_Status__c;
                        }
                        
                        //Check if fiscal year is less 1 year from current fiscal year
                        if(Integer.valueOf(p.Fiscal_Year__c) == currentFY + 1) {
                           
                            //Populated Account'S field Next Year Status and NExt Year Account Status by PP fields
                            mapAccountToBeUpdated.get(p.Account__c).r_Next_Year_Status__c = p.Client_Status_New__c;
                            mapAccountToBeUpdated.get(p.Account__c).r_Next_Year_Account_Status__c = p.Account_Status__c;
                        }
                        
                        //Check if fiscal year is greater than 1 year from current fiscal year
                        if(Integer.valueOf(p.Fiscal_Year__c) == currentFY-1) {
                            
                            //Populated Account'S field Prevous Year Status and previous Year Account Status by PP fields
                            mapAccountToBeUpdated.get(p.Account__c).r_Previous_Year_Status__c = p.Client_Status_New__c;
                            mapAccountToBeUpdated.get(p.Account__c).r_Previous_Year_Account_Status__c = p.Account_Status__c;
                        }
                    }
                }
                
                //Update Accounts
                if(mapAccountToBeUpdated.values().size() > 0)
                    update mapAccountToBeUpdated.values();
            }
        }
     }

    /**
     *  @description        :   Method is used to call when need to Program Package Rollups Account's fields
     *
     *  @args               :   List<Program_Package__c> newProgPacks, Map<Id,Program_Package__c> oldMapProgPack
     *
     *  @return             :   Void
     *
     *  @revision Logs      :   V_1.1 - Created - 07/11/2016 - Subhash Garhwal
     *
     **/
    public static void accountRollupsHD(List<Program_Package_Hardwick_Day__c> newProgPacksHD, Map<Id,Program_Package_Hardwick_Day__c> oldMapProgPackHD) {
        
        //Check for Not Schedule, Not Batch, Not Future
        if (!system.isFuture() && !system.isScheduled() && !system.isBatch()) { 
            
            //Calculate the current Fiscal year using shift_fical_year class
            Integer currentFY = shift_get_fiscal_year.current();
            
            //Map to hold Account Id with Accounts
            Map<Id, Account> mapAccountToBeUpdatedHD = new Map<Id, Account>();
        
            //Loop over new List of Program packages
            for(Program_Package_Hardwick_Day__c pPD : newProgPacksHD != null ? newProgPacksHD : oldMapProgPackHD.values()) {
                    
                //Insert case
                if(newProgPacksHD != null && oldMapProgPackHD == null && pPD.Account__c != null)
                    mapAccountToBeUpdatedHD.put(pPD.Account__c, new Account(Id = pPD.Account__c, r_HD_Previous_Year_Engagement_Status__c = null, r_HD_Current_Year_Engagement_Status__c = null,
                                                                            r_HD_Next_Year_Engagement_Status__c = null, r_HD_Previous_Year_Account_Status__c = null,
                                                                            r_hd_current_year_account_status__c = null, r_HD_Next_Year_Account_Status__c = null));
                
                //Update Case
                if(newProgPacksHD != null && oldMapProgPackHD != null && (pPD.Fiscal_Year_HD__c != oldMapProgPackHD.get(pPD.Id).Fiscal_Year_HD__c
                    || pPD.Client_Engagement_Status_HD__c != oldMapProgPackHD.get(pPD.Id).Client_Engagement_Status_HD__c
                    || pPD.HD_Account_Status__c != oldMapProgPackHD.get(pPD.Id).HD_Account_Status__c
                    || pPD.Account__c != oldMapProgPackHD.get(pPD.Id).Account__c)) {
                        
                    //Check for Account
                    if(pPD.Account__c != null)
                    mapAccountToBeUpdatedHD.put(pPD.Account__c, new Account(Id = pPD.Account__c, r_HD_Previous_Year_Engagement_Status__c = null, r_HD_Current_Year_Engagement_Status__c = null,
                                                                     r_HD_Next_Year_Engagement_Status__c = null, r_HD_Previous_Year_Account_Status__c = null,
                                                                     r_hd_current_year_account_status__c = null, r_HD_Next_Year_Account_Status__c = null));
                        
                    //Check for Old Account
                    if(oldMapProgPackHD.get(pPD.Id).Account__c != null)
                        mapAccountToBeUpdatedHD.put(oldMapProgPackHD.get(pPD.Id).Account__c, new Account(Id = oldMapProgPackHD.get(pPD.Id).Account__c, r_HD_Previous_Year_Engagement_Status__c = null, r_HD_Current_Year_Engagement_Status__c = null,
                                                                     r_HD_Next_Year_Engagement_Status__c = null, r_HD_Previous_Year_Account_Status__c = null,
                                                                     r_hd_current_year_account_status__c = null, r_HD_Next_Year_Account_Status__c = null));
                            
                }
                    
                //Delete Case
                if(newProgPacksHD == null && pPD.Account__c != null)
                    mapAccountToBeUpdatedHD.put(pPD.Account__c, new Account(Id = pPD.Account__c, r_HD_Previous_Year_Engagement_Status__c = null, r_HD_Current_Year_Engagement_Status__c = null,
                                                                     r_HD_Next_Year_Engagement_Status__c = null, r_HD_Previous_Year_Account_Status__c = null,
                                                                     r_hd_current_year_account_status__c = null, r_HD_Next_Year_Account_Status__c = null));
            }
            
            //Check for account size and Ids
            if(mapAccountToBeUpdatedHD.size() > 0) {
        
                //Loop over List of Program Packages HD
                for (Program_Package_Hardwick_Day__c p : [Select Id, Account__c, Fiscal_Year_HD__c, Client_Engagement_Status_HD__c,
                                                                HD_Account_Status__c from Program_Package_Hardwick_Day__c
                                                                Where Account__c IN : mapAccountToBeUpdatedHD.keySet() AND Fiscal_Year_HD__c != null
                                                                ORDER BY Account__c ASC, Fiscal_Year_HD__c ASC]) {
                    
                    //Check Account Id in map
                    if(mapAccountToBeUpdatedHD.containsKey(p.Account__c)) {
                        
                        //Check if Fiscal year HD equals to Current Fiscal year    
                        if (Integer.valueOf(p.Fiscal_Year_HD__c) == currentFY) {
                            
                            //Populated Account'S field Current Year Engagement Status and Current Year Account Status by PPHD fields
                            mapAccountToBeUpdatedHD.get(p.Account__c).r_HD_Current_Year_Engagement_Status__c = p.Client_Engagement_Status_HD__c;
                            mapAccountToBeUpdatedHD.get(p.Account__c).r_hd_current_year_account_status__c = p.HD_Account_Status__c;
                        }
                        
                        //Check if fiscal year HD is greater than 1 year from current fiscal year
                        if (Integer.valueOf(p.Fiscal_Year_HD__c) == currentFY + 1) {
                            
                            //Populated Account'S field Next Year Engagement Status and Next Year Account Status by PPHD fields
                            mapAccountToBeUpdatedHD.get(p.Account__c).r_HD_Next_Year_Engagement_Status__c = p.Client_Engagement_Status_HD__c;
                            mapAccountToBeUpdatedHD.get(p.Account__c).r_HD_Next_Year_Account_Status__c = p.HD_Account_Status__c;
                        }
                        
                        //Check if fiscal year HD is less than 1 year from current fiscal year 
                        if (Integer.valueOf(p.Fiscal_Year_HD__c) == currentFY - 1) {
                            
                            //Populated Account'S field previous Year Engagement Status and previous Year Account Status by PPHD fields
                            mapAccountToBeUpdatedHD.get(p.Account__c).r_HD_Previous_Year_Engagement_Status__c = p.Client_Engagement_Status_HD__c;
                            mapAccountToBeUpdatedHD.get(p.Account__c).r_HD_Previous_Year_Account_Status__c = p.HD_Account_Status__c;
                        }       
                    }
                }
                
                //Update Accounts
                if(mapAccountToBeUpdatedHD.values().size() > 0)
                    update mapAccountToBeUpdatedHD.values();
            }
        }
    }
}