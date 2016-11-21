<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Alert_New_Client_HD</fullName>
        <ccEmails>newclientnotification@royall.com.abc</ccEmails>
        <description>Alert New Client (HD)</description>
        <protected>false</protected>
        <recipients>
            <recipient>sdascoli@royall.com.abc</recipient>
            <type>user</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Workflow_Email_Alert_Templates/Client_Alert_New_HD</template>
    </alerts>
    <rules>
        <fullName>New Client %28HD%29</fullName>
        <actions>
            <name>Alert_New_Client_HD</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Program_Package_Hardwick_Day__c.HD_Account_Status_formula__c</field>
            <operation>equals</operation>
            <value>New Client</value>
        </criteriaItems>
        <description>Initiates workflow when there&apos;s a new Hardwick Day client</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
</Workflow>
