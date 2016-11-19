<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>SFDC_ReqComment_Notification_email_to_Owner</fullName>
        <description>SFDC ReqComment Notification email to Owner</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>IS_CRM/SFDC_ReqComment_Notification</template>
    </alerts>
    <rules>
        <fullName>SFDC ReqComment Notification to BusContact</fullName>
        <active>false</active>
        <description>send an email to Request Business Contact when new comment made by another person</description>
        <formula>SFDC_Change_Request__r.Business_Operations_Contact2__r.Employee_User_Record__c &lt;&gt; CreatedById</formula>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>SFDC ReqComment Notification to Owner</fullName>
        <actions>
            <name>SFDC_ReqComment_Notification_email_to_Owner</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <description>send an email to Request Owner when new comment made by another person</description>
        <formula>SFDC_Change_Request__r.OwnerId  &lt;&gt; CreatedById</formula>
        <triggerType>onCreateOnly</triggerType>
    </rules>
</Workflow>
