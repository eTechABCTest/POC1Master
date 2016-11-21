//V_1.1 - Modified By - Rajeev Jain	- CR-20150618-9016 - 07/08/2015 - BoardRoom Mobile - Phase 2
//Description : Added new property in the Wrapper Class to Access JobLevel - 'JobLevleActual';
public class IntranetType {
    
    /****************************************  Current User Classes  ***************************************/
    public class UserSession{
        public string 	FirstName;
        public string	LastName;
        public Id		UserId;
        public string	AssignedOffice;
        public string	Workspace;
        public string	JobLevel;
        public string	Department;
        public string	Division;
        public string	Function;
        public string	ScreenSize;			//Possibly use this to determine which type of access method is used by screen size
        public string	AccessLocation;		//Where is the user accessing the content
        public string	Browser;
        public string	Device;
        public boolean	Manager;
        
        //V_1.1 - Modified By - Rajeev Jain	- CR-20150618-9016 - 07/08/2015 - BoardRoom Mobile - Phase 2
        public String  JobLevelActual;
    }


    
    
}