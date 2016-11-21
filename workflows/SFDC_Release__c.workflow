<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Notify_Integration_Teams_of_Upcoming_Salesforce_Release</fullName>
        <ccEmails>ETLSupport@advisory.com</ccEmails>
        <description>Notify Integration Teams of Upcoming Salesforce Release</description>
        <protected>false</protected>
        <recipients>
            <recipient>kadakiar@advisory.com.abc</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>narayana@advisory.com.abc</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>thyagarr@advisory.com.abc</recipient>
            <type>user</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>IS_CRM/Notify_Integration_Teams_of_Upcoming_Salesforce_Changes</template>
    </alerts>
    <rules>
        <fullName>Release Status - Ready for SOX Certification</fullName>
        <actions>
            <name>Notify_Integration_Teams_of_Upcoming_Salesforce_Release</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>SFDC_Release__c.Status__c</field>
            <operation>equals</operation>
            <value>Ready for SOX Certification</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>SFCD Release%3A Backup Production Task</fullName>
        <actions>
            <name>SFDC_Release_Backup_Production</name>
            <type>Task</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>SFDC_Release__c.Status__c</field>
            <operation>equals</operation>
            <value>Ready for Deployment</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>SFDC Release%3A Run Audit Trail</fullName>
        <actions>
            <name>SFDC_Release_Run_Setup_Audit_Train</name>
            <type>Task</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>SFDC_Release__c.Status__c</field>
            <operation>equals</operation>
            <value>Deployed</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <tasks>
        <fullName>SFDC_Release_Backup_Production</fullName>
        <assignedTo>sfadmin@advisory.com</assignedTo>
        <assignedToType>user</assignedToType>
        <description>Create a task as a Reminder to backup Production BEFORE deploying</description>
        <dueDateOffset>0</dueDateOffset>
        <notifyAssignee>true</notifyAssignee>
        <priority>High</priority>
        <protected>false</protected>
        <status>Not Started</status>
        <subject>SFDC Release: Backup Production</subject>
    </tasks>
    <tasks>
        <fullName>SFDC_Release_Run_Setup_Audit_Train</fullName>
        <assignedTo>sfadmin@advisory.com</assignedTo>
        <assignedToType>user</assignedToType>
        <description>View Setup Audit Trail -- run in Excel, save config changes for deployment; attach to Release record.</description>
        <dueDateOffset>0</dueDateOffset>
        <notifyAssignee>true</notifyAssignee>
        <priority>High</priority>
        <protected>false</protected>
        <status>Not Started</status>
        <subject>SFDC Release: Run Setup Audit Train</subject>
    </tasks>
</Workflow>
