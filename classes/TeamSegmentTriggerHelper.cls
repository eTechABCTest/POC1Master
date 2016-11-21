/**
 * 	Purpose			:	This class is to work as helper class for Team Segment Trigger
 * 
 * 	Created By		:	Bhavi Sharma
 * 
 *	Created Date	:	04/11/2015 
 * 
 * 	Revision Logs	:	V_1.0 - Created
 * 
 **/ 
public with sharing class TeamSegmentTriggerHelper {
	
	/**
	 *	@description	:	This methiod is to validate the data before inserting into database. If there is any error, display error message to user.
	 *
	 *	@args			:	List of Team Segments
	 *
	 *	@return			:	void
	 *
	 **/
	public static void validateTeamSegments(List<Team_Segment__c> teamSegments) {
		
		//Create a set to  hold the name of Segments
		Set<String> SegmentsNames = new Set<String>();
		
		//Loop through the Segments
		for(Team_Segment__c teamSegment : teamSegments)
			segmentsNames.add(teamSegment.Name);
			
		//Query database to check if there is already a record with the same name
		Integer existingCount = [Select count() from Team_Segment__c where Name IN: SegmentsNames AND ID NOT IN: teamSegments];
		
		//If there is any existing user, throww an error message to user
		if(existingCount > 0)
			throw new CustomException(Label.ERROR_UNIQUENESS_SEGMENT_NAME);
	}  
}