<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Sends_an_email_to_notify_Content_manager_that_a_Scheduled_Item_is_ready_for_revi</fullName>
        <ccEmails>boardroomnews@advisory.com</ccEmails>
        <description>Sends an email to notify Content manager that a Scheduled Item is ready for review</description>
        <protected>false</protected>
        <senderType>CurrentUser</senderType>
        <template>Intranet/Intranet_Schedule_Ready_for_Review</template>
    </alerts>
    <rules>
        <fullName>Schedule Ready for Review</fullName>
        <actions>
            <name>Sends_an_email_to_notify_Content_manager_that_a_Scheduled_Item_is_ready_for_revi</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Intranet_Schedule__c.Active_Status__c</field>
            <operation>equals</operation>
            <value>Active</value>
        </criteriaItems>
        <criteriaItems>
            <field>Intranet_Schedule__c.Approval_Status__c</field>
            <operation>equals</operation>
            <value>Ready for Review</value>
        </criteriaItems>
        <description>Runs when an Intranet Schedule is updated to an Approval Status of &apos;Ready for Review&apos;</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
</Workflow>
