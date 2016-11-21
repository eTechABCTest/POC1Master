/**
 * 	Purpose			:	This class is to work as helper class for Team Role Trigger
 * 
 * 	Created By		:	Bhavi Sharma
 * 
 *	Created Date	:	03/31/2015 
 * 
 * 	Revision Logs	:	V_1.0 - Created
 *						V_1.1 - Modified By - Subhash Garhwal - 07/02/2015 - CR-20150618-9014 - New method added - validateDelete
 * 
 **/ 
public with sharing class TeamRoleTriggerHelper {
	
	/**
	 *	@description	:	This methiod is to validate the data before inserting into database. If there is any error, display error message to user.
	 *
	 *	@args			:	List of Team Roles
	 *
	 *	@return			:	void
	 *
	 **/
	public static void validateTeamRoles(List<Team_Role__c> teamRoles) {
		
		//Create a set to  hold the name of roles
		Set<String> rolesNames = new Set<String>();
		
		//Loop through the roles
		for(Team_Role__c teamRole : teamRoles) {
			
			//Check team Role in set
			if(rolesNames.contains(teamRole.Name))
				throw new CustomException(Label.ERROR_UNIQUENESS_ROLE_NAME);
				
			//Add Role name
			rolesNames.add(teamRole.Name);
		}
			
		//Query database to check if there is already a record with the same name
		Integer existingCount = [Select count() from Team_Role__c where Name IN: rolesNames AND ID NOT IN: teamRoles];
		
		//If there is any existing user, throww an error message to user
		if(existingCount > 0)
			throw new CustomException(Label.ERROR_UNIQUENESS_ROLE_NAME);
	}
	
	/**
	 *	@description	:	This method is to check if Assignment Role (Staff Role) is used on any Staff Assignment than don't allow user to delete it.
	 *
	 *	@args			:	List<Team_Role__c>
	 *
	 *	@return			:	void 
	 *
	 **/ 
	public static void validateDelete(List<Team_Role__c> teamRoles) {
		
		//Query through Staff Assignment
		List<Team_Membership__c> teamMemberships = [Select Id From Team_Membership__c Where Role__c IN : teamRoles];
		
		//If there is any Staff Assignment which is using Assignment Role (Staff Role), throw an eror message to user
		if(teamMemberships.size() > 0)
			throw new CustomException(Label.ASSIGNMENT_ROLE_IN_USE);	
	}
	
	/**
     *	@decription	:	This method is used to update all the related Staff Assignments name, if Team Role name is changed.
     *					For this we will blank update all the related Staff Assignments, do to this Renaming workflow will execute and update SA names according	
     *
     *	@args		:	List<Contact>, Map<Id, Contact>
     *
     *	@return		:	void
     *
     **/
	public static void updateStaffAssignment(List<Team_Role__c> teamRoles, Map<Id, Team_Role__c> mapOldTeamRoles) {
		
		//Set to hold Team Roles Ids
		Set<Id> setTMIds = new Set<Id>();
		
		//Loop through Team_Role__c
		for(Team_Role__c tR : teamRoles) {
			
			//Check for appropriate condition
			if(tR.Name != mapOldTeamRoles.get(tR.Id).Name)
				setTMIds.add(tR.Id);
		}
		
		//Check for set size
		if(setTMIds.size() > 0) {
			
			//List of Staff Assignment
			List<Team_Membership__c> teamMemberships = [Select Id, Staff_member__r.FirstName, Staff_member__r.LastName, Role__c,
															   Role__r.Name From Team_Membership__c Where Role__c IN : setTMIds];
			
			//Loop through Staff Assignment
			for(Team_Membership__c tM : teamMemberships)
				tM.Name = Util.parseNull(tM.Staff_member__r.FirstName) + ' ' + Util.parseNull(tM.Staff_member__r.LastName) + '-' + Util.parseNull(tM.Role__r.Name);
			
			//Check for list size
			if(teamMemberships.size() > 0)
				update teamMemberships;
		}
	}
}