/**
 * 	Purpose:    This class contains liquid planner classes that are used for the LP / SF integration.
 * 
 * 	Create By:  Victor Hanson
 * 
 * 	Created Date:   05/06/2015
 * 
 * 	Revision Log:	v1.0 - (Code Added) - Victor Hanson - Created
 **/
global with sharing class LiquidPlannerWrapper {
	
    /**
     * @description: 
     **/
    global class LP_Milestone {
		global string activity_Id;
        global string created_by;
        global string change_type;
		global string description;
		global string external_reference;
		global integer id;
		global boolean is_done;
		global boolean is_on_hold;
		global boolean is_shared;
		//global double max_effort;
		global string name;
		global integer owner_id;
		global integer package_id;
        global list<string> parent_crumbs;
		global integer parent_id;
        global integer project_id;
        global date started_on;
        global LP_Milestone_Custom_Fields custom_field_values;
        global list<LP_Assignment> assignments;
	}
    
    /**
     * @description: LP_Project is the equivalent of a Release or a Level III CR in SF
     **/
	global class LP_Project {
		global Integer client_id;
        global string change_type;
		global DateTime delay_until;
		global String description;
		global DateTime done_on;
		global String external_reference;
		global Integer id;
		global boolean is_done;
		global boolean is_on_hold;
		//global double max_effort;
		global String name;
		global Integer owner_id;
		global Integer parent_id;
        global Integer project_id;
		global DateTime promise_by;
        global DateTime latest_finish;
        global string type;
	}
    
    /**
     * @description: 
     **/
    global class LP_Milestone_Custom_Fields {
        global string task_type;
    }
    
    /**
     * @description: 
     **/
    global class LP_Assignment {
        global integer person_Id;
        global string type;
    }
    
    // LP_Member is the equivalent of a User in salesforce
	public class LP_Member {
		public String first_name, last_name;
		public String email;
		public Integer id;
	}
    
    // LP_Tag represents a hashtag on the project
	public class LP_Tag {
		public String text;
		public String email;
        public Integer item_id;
		public Integer id;
	}
	
	/*// LP_Account is the root organizatoin info for the whole LP instance
	public class LP_Account {
		public Integer id;
		public String type;
		public Integer created_by, updated_by;
		public DateTime created_at, updated_at;
		public String avatar_url;
		public String company;
		public String timezone;
		public String first_name, last_name;
		public String user_name;
		public String email;
		public LP_Workspace[] workspaces; // TODO: LiquidPlannerWorkspace[]
		public Integer last_workspace_id;
		public Integer disabled_workspaces_count;
	}
	
	// LP_Task is sort of like a L1 or L2 CR in SF, although if a L2 CR is associated with a release, it translates to an LP_Project
	public class LP_Task {
		public Integer id;
		public String name;
		public String description;
		public DateTime done_on;
		public String external_reference;
		public boolean is_done;
		public boolean is_on_hold;
		public Integer max_effort;
		public Integer owner_id;
		public DateTime started_on;
		public Integer parent_id;
		
	}
	
	public class LP_Workspace {
		public String company_name;
		public DateTime created_at, updated_at;
		public Integer created_by, updated_by;
		public Integer default_units;
		public String description;
		public String hours_per_day;
		public Integer inbox_id;
		public Integer id;
		public String name;
		public Integer owner_id;
		public Integer root_id;
		public Integer week_start;
	}
	
	public class LP_Dependency {
		public Integer prerequisite_item_id;
		public Integer id;
	}
	
	// LP_Link stores links to Change Requests and Documents in SF
	public class LP_Link {
		public String description;
		public Integer id;
		public Integer item_id;
		public String url;
	}
	
	// LP_Note stores information about the CR like 'why do you need it' and 'optional:recommended solution'
	public class LP_Note {
		public Integer id;
		public String note;
	}
	
	// LP_Folder
	public class LP_Folder {
		public DateTime delay_until;
		public String description;
		public Date done_on;
		public String external_reference;
		public Integer id;
		public boolean is_done;
		public boolean is_on_hold;
		public String max_effort;
		public String name;
		public Integer owner_id;
		public Integer parent_id;
		public Date promise_by;
	}
	
	// LP_Estimate
	public class LP_Estimate {
		public Integer high;
		public Integer low;
		public Integer id;
	}
	
	
	/*public static final String LP_URL = 'https://app.liquidplanner.com/api';
	// TODO: read the email/pass from a custom setting
	public static final String LP_EMAIL = 'vhanson222@yahoo.com';
	public static final String LP_PASS = 'xxxxxxxxxx';
	
	// return the workspace id -- this is used in almost all calls to Liquid Planner
	public static String WORKSPACE_ID {
		get {
			if (WORKSPACE_ID == null) {
				Liquid_Planner__c lpSettings = Liquid_Planner__c.getOrgDefaults();
				if (lpSettings.Workspace_Id__c == null) {
					// send callout to get workspace ID
					LP_Account lpAccount = LiquidPlannerUtils.getAccount();
					if (lpAccount != null && lpAccount.Id != null) {
						WORKSPACE_ID = String.valueOf(lpAccount.workspaces[0].Id);
						lpSettings.Workspace_Id__c = WORKSPACE_ID;
						upsert lpSettings;
					}
				}
				else {
					WORKSPACE_ID = lpSettings.Workspace_Id__c;
				}
			}
			return WORKSPACE_ID;
		}
		set;
	}
    
    // return a map of <FirstName + ' ' + LastName, LP_Member>
	public static Map<String, LP_Member> getMembers() {
		Map<String, LP_Member> nameToMemberMap = new Map<String, LP_Member>();
		HttpResponse res = LiquidPlannerUtils.doGet('/workspaces/' + WORKSPACE_ID + '/members');
		List<LP_Member> members = (List<LP_Member>) JSON.deserialize(res.getBody(), List<LP_Member>.class);
		for (LP_Member member : members) {
			String name = member.first_name + ' ' + member.last_name;
			nameToMemberMap.put(name, member);
		}
		return nameToMemberMap;
	}
	
	public static String Create_LP_URL(Integer item_id) {
		String url = 'https://app.liquidplanner.com/space/' + WORKSPACE_ID + '/projects/show/' + string.valueOf(item_id);
		return url;
	}*/
}