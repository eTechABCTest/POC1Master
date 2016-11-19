public class SandboxSetup {
    
    public static final string ABC = 'abc';
    public static final string JOB_TYPE_REPORT_RUN = '8';
    public static final string JOB_TYPE_DASHBOARD_REFRESH = '3';
    
    public SandboxSetup(set<string> adminUserEmails, boolean updateUsersToSystemAdmin, boolean deleteSchedReports) {
        if (adminUserEmails != null) emails = adminUserEmails;
        if (updateUsersToSystemAdmin) updateUsers();
        if (deleteSchedReports) deleteScheduledReports();
    }
    
    public set<string> emails {
        get {
            if (emails == null) { emails = new set<string>();
                /*emails = new set<string> {    
                        'abhinav@simplyforce.com', 'adairj@advisory.com', 
                        'ajit.k.surana@simplyforce.com', 'bassik@advisory.com', 
                        'baxters@advisory.com', 'bennettj@advisory.com', 
                        'berrongj@advisory.com', 'simplyforce@advisory.com', 
                        'brennemk@advisory.com', 'dohertym@advisory.com', 
                        'gerharde@advisory.com', 'hansonv@advisory.com', 
                        'mcgloinc@advisory.com', 'tribaj@advisory.com', 
                        'wolfsont@advisory.com', 'gonnetk@advisory.com', 
                        'nealb@advisory.com', 'sfadmin@advisory.com',
                        'robinsoka@advisory.com', 'redmand@advisory.com', 
                        'daltonm@advisory.com'
                };*/
            }
            return emails;
        }
        set;
    }
    
    /**
     * @description: update profile to system admin and role to Private Executive for all users identified by username in the "emails" variable
     **/
    public void updateUsers() {
        list<User> usersToUpdate = new list<User>();
        list<User> users = [SELECT Id, ProfileId, Email, Username, UserRoleId FROM User WHERE Username IN :emailToEmailsWithSuffixMap.keySet()];
        for (User u : users) {
            boolean isChanged = false;
            if (u.ProfileId != sysAdminProfileId) {
                u.UserRoleId = privateExecRoleId;
                u.ProfileId = sysAdminProfileId;
                isChanged = true;
            }
            if (u.Email != emailToEmailsWithSuffixMap.get(u.Username)) {
                u.Email = emailToEmailsWithSuffixMap.get(u.Username);
                isChanged = true;
            }
            //if the user is changed, update them.  
            //This is not ideal, but updating many users at once caused an Internal SF Error, so we have to do them one-off
            if (isChanged) update u;
        }
    }
    
    /**
     * @description: update email from 'tribaj@advisory.com' to 'tribaj@advisory.com.abc.dev2'
     **/
    public map<string, string> emailToEmailsWithSuffixMap {
        get {
            if (emailToEmailsWithSuffixMap == null) {
                emailToEmailsWithSuffixMap = new map<string, string>();
                for (string email : emails) {
                    emailToEmailsWithSuffixMap.put((email + '.' + ABC + '.' + sandboxName).toLowerCase(), email);
                }
            }
            return emailToEmailsWithSuffixMap;
        }
        set;
    }
            
    /**
     * @description: url in format "advisory--dev2.Salesforce.com".  Return the dev2 portion.
     **/
    public string sandboxName {
        get {
            if (sandboxName == null) {
                string s = URL.getSalesforceBaseUrl().getHost().split('\\.')[0];
                return s.replace('advisory--', '');
            }
            return sandboxName;
        }
        set;
    }
    
    /**
     * @description: get the Private Executive role id
     **/
    public Id privateExecRoleId {
        get {
            if (privateExecRoleId == null) {
                privateExecRoleId = [SELECT Id FROM UserRole WHERE Name = 'Private Executive' LIMIT 1].Id;
            }
            return privateExecRoleId;
        }
        set;
    }
    
    /**
     * @description: get the System Admin Profile id
     **/
    public Id sysAdminProfileId {
        get {
            if (sysAdminProfileId == null) {
                sysAdminProfileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1].Id;
            }
            return sysAdminProfileId;
        }
        set;
    }
    
    
    /**
     *  Delete scheduled report/dashboard jobs from sandboxes (NOTE: Needs to be a batch job because there are more than 150 jobs to delete)
    **/
    public void deleteScheduledReports() {
        list<CronTrigger> jobs = [SELECT Id FROM CronTrigger 
                                  WHERE CronJobDetail.JobType = :JOB_TYPE_REPORT_RUN 
                                     OR CronJobDetail.JobType = :JOB_TYPE_DASHBOARD_REFRESH 
                                  LIMIT 150];
        
        for (CronTrigger job : jobs)
            system.abortJob(job.Id);
    }
    
}