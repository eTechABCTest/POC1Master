/* 
* Name          : Shift_RoyallResource_Trigger
* Author        : Shift CRM
* Description   : Manages REST callout
*
* Maintenance History: 
* Date ------------	Name  ----	Version ---	Remarks 
* 02/20/2013     	Hermes      1.0       	Initial
* 06/28/2016		Rajeev 		1.0			SFDC - Royall Schema Release - Migrated from Royall Enviournment
* 11/08/2016		Mahendra 	1.1			CR-20160729-10074
*/

trigger Shift_RoyallResource_Trigger on Royall_Resource__c (after update, before delete) {
	//enable trigger through custom setting
	// V_1.1 Updated By - Mahendra swarnakar - 11/8/2015 - CR-20160729-10074
	if (!system.isFuture() && !system.isScheduled() && !system.isBatch() && Shift_ChangeDelete_Callout.calloutSettings.Enable_Resource_Trigger__c) {
		if(Trigger.isUpdate && Trigger.isAfter){
			Shift_ChangeDelete_Callout.processRecords((List<SObject>)trigger.new, 'update', 'royalresource');
		}
		else if(Trigger.isDelete && Trigger.isBefore){
			Shift_ChangeDelete_Callout.processRecords((List<SObject>)trigger.old, 'delete', 'royalresource');
		}
	}
}