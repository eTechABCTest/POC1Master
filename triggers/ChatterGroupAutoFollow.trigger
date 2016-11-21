/*
	Author:			Scott Grabo
	Created: 		9/30/2014	
	Description:	Calls the Chatter Group auto-follow logic
	Called by:		User (trigger)
	Consumes:		UserChatterGroupAutoFollow
	Calls:			UserChatterGroupAutoFollow.AddToGroups
	Change log:		9/30/2014 - Creation
*/
trigger ChatterGroupAutoFollow on User (after insert, after update) 
{
	UserChatterGroupAutoFollow.callFuture_AddToGroup(Trigger.newMap.keySet(), Trigger.isUpdate);
}