<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>EA_Key_Fields_Changes_Notification</fullName>
        <description>EA Key Fields Changes Notification</description>
        <protected>false</protected>
        <recipients>
            <field>Business_Owner__c</field>
            <type>contactLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>unfiled$public/ET_Program_Perspective_Key_Fields_Changes_Notification</template>
    </alerts>
    <rules>
        <fullName>WF_Key_Fields_Changes_Notification</fullName>
        <actions>
            <name>EA_Key_Fields_Changes_Notification</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <formula>OR( 	ISCHANGED(Name), 	ISCHANGED(Effective_Start__c), 	ISCHANGED(Effective_End__c), 	ISCHANGED(Active__c) )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
